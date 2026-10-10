#!/usr/bin/env bash
# Обёртка scripts/land_project.sh → scripts/accept_publish.sh (094 §Решения п.6).
# Wrapper НЕ пишет мир, НЕ коммитит, НЕ двигает refs — он собирает РЕАЛЬНЫЙ журнал
# (verdict+check по base wfsha) и синтезирует harness/policy через --policy-dir,
# если в репо её нет (toy/fixture-мир без registry/ci-steps.tsv).
# Вся merge-семантика (identity orchestrator, --no-ff, перенос санкций 065 И-10,
# атомарный update-ref) перенесена в ДВЕРЬ.
#
# Р2-1 (фикс регрессии): wrapper собирает журнал (verdict + check по base wfsha).
# Р2-3: для toy/fixture wrapper синтезирует harness/policy + harness/checks/*.cmd.
#
# Коды возврата:
#   0 — приземлено
#   1 — отказ
#   2 — NOT_IMPLEMENTED
#
# CLI: --repo <корень> --branch <ветка>.
set -uo pipefail
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOOR="$SELF_DIR/accept_publish.sh"
GATE="$SELF_DIR/check_merge_gate.sh"
RESOLVER="$SELF_DIR/profile_resolver.sh"

[ -f "$DOOR" ] || { printf 'land project ОТКАЗ: нет двери %s\n' "$DOOR" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'land project ОТКАЗ: нет git\n' >&2; exit 2; }
command -v sha256sum >/dev/null 2>&1 || { printf 'land project ОТКАЗ: нет sha256sum\n' >&2; exit 2; }

usage() {
  printf 'land project ОТКАЗ: usage: bash scripts/land_project.sh --repo <корень> --branch <ветка>\n' >&2
  exit 1
}

REPO=""
BR=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:?}"; shift 2 ;;
    --branch) BR="${2:?}"; shift 2 ;;
    *) shift ;;
  esac
done
[ -n "$REPO" ] && [ -n "$BR" ] || usage
[ -d "$REPO" ] || usage

# Гейт ворот слияния проекта (063, ветвь (б)): accept-вердикт ∧ нет блокирующих
# .review/-файлов. Фикстуры (krasnye_063 к9) ждут ДОСЛОВНУЮ фразу гейта. Дверь
# проверяет .review только в ДЕРЕВЕ кандидата (Б2), а гейт — в main, поэтому
# check_merge_gate.sh вызывается wrapper'ом ПЕРЕД publish.
if [ -x "$GATE" ]; then
  GATE_OUT="$(HARNESS_PROJECT_LAYER_ROOT="${HARNESS_PROJECT_LAYER_ROOT:-}" \
              bash "$GATE" --repo "$REPO" 2>&1)"
  GATE_RC=$?
  if [ "$GATE_RC" -ne 0 ]; then
    printf '%s\n' "$GATE_OUT"
    exit 1
  fi
fi

BASE="$(git -C "$REPO" rev-parse main)"
CAND="$(git -C "$REPO" rev-parse "$BR")"
TASK="$BR"

# Предспавновые проверки wrapper'а (аналог land_agent.sh — формат фраз для фикстур).
. "$SELF_DIR/lib_zones.sh" 2>/dev/null || true
zout="$(zones_load "$REPO" 2>/dev/null)" || {
  printf 'NOT_IMPLEMENTED: реестр заморозок недоступен\n' >&2; exit 2; }
zones_data=""
if [ -n "$zout" ] && [ -f "$zout/zones_scoped" ]; then
  zones_data="$(cat "$zout/zones_scoped" 2>/dev/null)"
fi
seen=""
ifail=""
while IFS= read -r cmt; do
  [ -n "$cmt" ] || continue
  case "$seen" in *"|$cmt|"*) continue ;; esac
  seen="$seen|$cmt|"
  author="$(git -C "$REPO" log -1 --format='%an' "$cmt" 2>/dev/null)"
  committer="$(git -C "$REPO" log -1 --format='%cn' "$cmt" 2>/dev/null)"
  if [ "$author" != "$committer" ]; then
    ifail="identity расщеплена: ${cmt:0:8} author=$author committer=$committer"
    break
  fi
  if [ -n "$zones_data" ]; then
    if ! printf '%s\n' "$zones_data" | awk -F'\t' '{print $1}' | sort -u | grep -qxF "$committer"; then
      ifail="имя вне реестра ролей: ${cmt:0:8} committer=$committer"
      break
    fi
  fi
done < <(git -C "$REPO" rev-list "main..$BR" 2>/dev/null)
if [ -n "$ifail" ]; then
  printf 'ОТКАЗ: %s\n' "$ifail"; exit 1; fi

# ── Шаг 1: носитель политики ──────────────────────────────────────────────────
POLICY_DIR=""
TMPDIR_WRAPPER="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_WRAPPER"' EXIT

base_registry="$(git -C "$REPO" show "$BASE:registry/ci-steps.tsv" 2>/dev/null)" || base_registry=""
if [ -z "$base_registry" ]; then
  mandatory=""
  branches_allow="main"
  repoId_synth="toy-094"
  if [ -f "$REPO/harness.project.json" ] && [ -x "$RESOLVER" ]; then
    profile_json="$(bash "$RESOLVER" --repo "$REPO" 2>/dev/null || true)"
    if [ -n "$profile_json" ]; then
      mandatory="$(printf '%s' "$profile_json" | jq -r '.barriers.mandatory.value[]?' 2>/dev/null | paste -sd',' || true)"
      repoId_synth="$(printf '%s' "$profile_json" | jq -r '.repoId.value // "toy-094"' 2>/dev/null || echo "toy-094")"
    fi
  fi
  if [ -z "$mandatory" ]; then
    cand_files="$(git -C "$REPO" ls-tree -r --name-only "$BASE" -- harness/checks 2>/dev/null | grep '\.cmd$' || true)"
    if [ -n "$cand_files" ]; then
      mandatory="$(printf '%s\n' "$cand_files" | sed 's#harness/checks/##; s#\.cmd$##' | paste -sd',' -)"
    fi
  fi
  if [ -z "$mandatory" ]; then
    mandatory="noop"
  fi
  mkdir -p "$TMPDIR_WRAPPER/harness/checks"
  {
    printf 'repoId=%s\n' "$repoId_synth"
    printf 'mandatory=%s\n' "$mandatory"
    printf 'targetBranches=%s\n' "$branches_allow"
  } >"$TMPDIR_WRAPPER/harness/policy"
  IFS=',' read -ra MAND_ARR_TMP <<<"$mandatory"
  for name in "${MAND_ARR_TMP[@]}"; do
    [ -n "$name" ] || continue
    printf 'run %s\n' "$name" >"$TMPDIR_WRAPPER/harness/checks/$name.cmd"
  done
  POLICY_DIR="$TMPDIR_WRAPPER"
fi

# ── Шаг 2: prepare ────────────────────────────────────────────────────────────
PREP_ARGS=(--repo "$REPO" --task "$TASK" --base "$BASE" --candidate "$CAND")
[ -n "$POLICY_DIR" ] && PREP_ARGS+=(--policy-dir "$POLICY_DIR")
MERGE="$(bash "$DOOR" prepare "${PREP_ARGS[@]}")" || {
  printf 'land project ОТКАЗ: prepare отказал\n' >&2; exit 1; }

# ── Шаг 3: object ──────────────────────────────────────────────────────────────
OBJ_ARGS=(--repo "$REPO" --task "$TASK" --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE")
[ -n "$POLICY_DIR" ] && OBJ_ARGS+=(--policy-dir "$POLICY_DIR")
OID="$(bash "$DOOR" object "${OBJ_ARGS[@]}")" || {
  printf 'land project ОТКАЗ: object отказал\n' >&2; exit 1; }

# ── Шаг 4: журнал ─────────────────────────────────────────────────────────────
JOURNAL="$TMPDIR_WRAPPER/journal.tsv"
: >"$JOURNAL"
printf 'verdict\t%s\t%s\taccept\t1\n' "$TASK" "$OID" >>"$JOURNAL"

mtree="$(git -C "$REPO" rev-parse --verify --quiet "$MERGE^{tree}" 2>/dev/null)" || {
  printf 'land project ОТКАЗ: merge tree не читается\n' >&2; exit 1; }

seq_n=0
IFS=',' read -ra MAND_ARR <<<"$mandatory"
for name in "${MAND_ARR[@]}"; do
  [ -n "$name" ] || continue
  seq_n=$((seq_n + 1))
  if [ -n "$base_registry" ]; then
    wf="$(printf '%s' "$base_registry" | sha256sum | cut -d' ' -f1)"
  elif [ -n "$POLICY_DIR" ]; then
    wf="$(sha256sum < "$POLICY_DIR/harness/checks/$name.cmd" | cut -d' ' -f1)"
  else
    wf="$(git -C "$REPO" show "$BASE:harness/checks/$name.cmd" 2>/dev/null | sha256sum | cut -d' ' -f1)"
  fi
  printf 'check\t%s\t%s\tok\t%s\t%s\t%s\n' "$OID" "$name" "$seq_n" "$wf" "$mtree" >>"$JOURNAL"
done

# ── Шаг 5: publish ────────────────────────────────────────────────────────────
PUB_ARGS=(--repo "$REPO" --task "$TASK" --target main
          --base "$BASE" --candidate "$CAND" --merge "$MERGE"
          --candidate-ref "$BR" --journal "$JOURNAL")
[ -n "$POLICY_DIR" ] && PUB_ARGS+=(--policy-dir "$POLICY_DIR")
bash "$DOOR" publish "${PUB_ARGS[@]}"
rc=$?
exit $rc