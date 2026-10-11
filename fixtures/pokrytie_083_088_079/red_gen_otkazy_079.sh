#!/usr/bin/env bash
# Семья 079, часть Р1: генератор 083 — именованные отказы (нерезолв И-3/И-1,
# баланс И-4) на ТОЮ-реестрах. Дыра покрытия: Г4/Г5/Г8 батареи ci_gen_083 судят
# ТОЛЬКО конформный живой реестр и ВЫХОД генератора; ветвь «отказ rc 1, файлы
# не трогаются» и свойство «rc 0 ⇒ блок в границе И-4» не судимы ни одной
# существующей клеткой (аудит 079).
#
# Использование: bash red_gen_otkazy_079.sh <корень> [Р1-нерезолв Р1-баланс …]
#   [--gen <файл>]  — подменить генератор тою-мира (стаб-пак/диффпроба).
# Коды: 0 — все судимые клетки зелёные; 1 — есть красная; 2 — нечем проверить.
#
# Клетки (вход → ожидание; оракул — в памяти батареи ДО вызова субъекта):
#   Р1-нерезолв   ДВА тою-мира, по одному на класс нерезолва И-3 (генератор
#                 отказывает на ПЕРВОМ нерезолве — один прогон один класс):
#                 мир-A: a6→npm run NO_SUCH_KEY (ключа нет в package.json);
#                 мир-B: b1→bash netu/takogo.sh (пути нет в дереве).
#                 Каждый: --check → rc 1, stderr именует свой класс
#                 (a6/NO_SUCH_KEY; b1/netu/takogo.sh); --write → rc 1, ci.yml
#                 побайтово неизменен (md5 снят ДО вызова).
#                 Позитив-контроль: конформный реестр --write rc 0, --check rc 0.
#   Р1-баланс     тою-реестр 5×100 + 7×1 (total=507, K=6, граница
#                 ceil(507/6)+100=185; наивная раздача парами даёт 200 > 185,
#                 LPT — 101): --write → ЛИБО rc 0 и блок JOBS в границе И-4
#                 (нагрузки считает оракул батареи; пустой блок — красное),
#                 ЛИБО rc 1 с именованной причиной баланса; rc 0 с внеграничным
#                 блоком — красное «как получилось».
#
# PAK (стаб → клетка; дефект; Н-39 — привязка здесь, не в прозе контракта):
#   д1 → Р1-нерезолв  генератор принимает нерезолвящийся реестр (rc 0 / пишет):
#                      наблюдаем на входе Р1-нерезолв (честный rc 1); диффпроба —
#                      на конформном реестре д1 ведёт себя как честный (rc 0).
#   д2 → Р1-баланс    генератор пишет «как получилось» (наивная раздача
#                      парами 100+100=200 > 185 без отказа): наблюдаем на входе
#                      Р1-баланс; диффпроба — стаб-пак: реестр 12×10 (граница 30,
#                      наивная раздача 20 ≤ 30 — стаб как честный).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${1:-$HERE/../..}" 2>/dev/null && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
shift || true
GEN=""
kletki=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --gen) GEN="$2"; shift 2 ;;
    *) kletki+=("$1"); shift ;;
  esac
done
SRCGEN="$ROOT/scripts/gen_ci_steps.sh"
[ -f "$SRCGEN" ] || { printf 'NOT_IMPLEMENTED: нет генератора %s\n' "$SRCGEN" >&2; exit 2; }

KRASNYH=0; ZELENYH=0
zeleno() { printf 'ЗЕЛЕНО: %s\n' "$1"; ZELENYH=$((ZELENYH+1)); }
krasno() { printf 'КРАСНО: %s\n' "$1"; KRASNYH=$((KRASNYH+1)); }
nado() { [ "${#kletki[@]}" -eq 0 ] || case " ${kletki[*]} " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }
SCR="$(mktemp -d "${TMPDIR:-/tmp}/pokrytie079-gen.XXXXXX")" || exit 2
trap 'rm -rf -- "$SCR"' EXIT

mk_gen_mir() { # <dir> <реестр-файл>
  local d="$1" k
  mkdir -p "$d/registry" "$d/.github/workflows" "$d/scripts" "$d/fixtures"
  cat > "$d/package.json" <<'EOF'
{ "name": "toy", "scripts": { "check:alpha": "bash fixtures/alpha.sh", "check:beta": "bash fixtures/beta.sh", "check:gamma": "bash fixtures/gamma.sh", "check:delta": "bash fixtures/delta.sh", "check:eps": "bash fixtures/eps.sh", "check:zeta": "bash fixtures/zeta.sh" } }
EOF
  for k in alpha beta gamma delta eps zeta; do
    printf '#!/usr/bin/env bash\nexit 0\n' > "$d/fixtures/$k.sh"
  done
  cat > "$d/.github/workflows/ci.yml" <<'EOF'
name: ci
on: [push]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      # BEGIN GENERATED CI JOBS (083)
      # END GENERATED CI JOBS (083)
  antiplacebo:
    runs-on: ubuntu-latest
    steps:
      # BEGIN GENERATED CI SHARDS (083)
      # END GENERATED CI SHARDS (083)
EOF
  cp -- "${2}" "$d/registry/ci-steps.tsv"
  if [ -n "$GEN" ]; then cp -- "$GEN" "$d/scripts/gen_ci_steps.sh"
  else cp -- "$SRCGEN" "$d/scripts/gen_ci_steps.sh"; fi
}

REG_KONFORM="$SCR/reg-konform.tsv"
printf 'lanes\t6\nstep\ta1\t10\tnpm run check:alpha\nstep\ta2\t10\tnpm run check:beta\nstep\ta3\t10\tnpm run check:gamma\nstep\ta4\t10\tnpm run check:delta\nstep\ta5\t10\tnpm run check:eps\nstep\ta6\t10\tnpm run check:zeta\nshard\tap1\tshard_a\n' > "$REG_KONFORM"
REG_NPM="$SCR/reg-npm.tsv"
printf 'lanes\t6\nstep\ta1\t10\tnpm run check:alpha\nstep\ta2\t10\tnpm run check:beta\nstep\ta3\t10\tnpm run check:gamma\nstep\ta4\t10\tnpm run check:delta\nstep\ta5\t10\tnpm run check:eps\nstep\ta6\t10\tnpm run NO_SUCH_KEY\n' > "$REG_NPM"
REG_BASH="$SCR/reg-bash.tsv"
printf 'lanes\t6\nstep\ta1\t10\tnpm run check:alpha\nstep\ta2\t10\tnpm run check:beta\nstep\ta3\t10\tnpm run check:gamma\nstep\ta4\t10\tnpm run check:delta\nstep\ta5\t10\tnpm run check:eps\nstep\tb1\t10\tbash netu/takogo.sh\n' > "$REG_BASH"
REG_BALANS="$SCR/reg-balans.tsv"
{ printf 'lanes\t6\n'
  printf 'step\tw1\t100\tnpm run check:alpha\n'
  printf 'step\tw2\t100\tnpm run check:beta\n'
  printf 'step\tw3\t100\tnpm run check:gamma\n'
  printf 'step\tw4\t100\tnpm run check:delta\n'
  printf 'step\tw5\t100\tnpm run check:eps\n'
  for i in 6 7 8 9 10 11 12; do printf 'step\tw%s\t1\tnpm run check:zeta\n' "$i"; done
} > "$REG_BALANS"

# ── Р1-нерезолв ───────────────────────────────────────────────────────────────
if nado Р1-нерезолв; then
  imja_ok=1; trog=0
  for spec in "A:$REG_NPM:a6:NO_SUCH_KEY" "B:$REG_BASH:b1:netu/takogo.sh"; do
    imja="${spec%%:*}"; rest="${spec#*:}"
    reg="${rest%%:*}"; rest="${rest#*:}"
    k="${rest%%:*}"; tok="${rest#*:}"
    M="$SCR/m-neresolv-$imja"; mk_gen_mir "$M" "$reg"
    md5_do="$(md5sum "$M/.github/workflows/ci.yml" | cut -d' ' -f1)"
    out="$(bash "$M/scripts/gen_ci_steps.sh" --check --root "$M" 2>&1)"; rcc=$?
    outw="$(bash "$M/scripts/gen_ci_steps.sh" --write --root "$M" 2>&1)"; rcw=$?
    md5_posle="$(md5sum "$M/.github/workflows/ci.yml" | cut -d' ' -f1)"
    grep -q "$k" <<<"$out" && grep -q "$tok" <<<"$out" || imja_ok=0
    [ "$rcc" -eq 1 ] || imja_ok=0
    if [ "$rcw" -ne 1 ] || [ "$md5_do" != "$md5_posle" ]; then imja_ok=0; trog=1; fi
  done
  if [ "$imja_ok" -eq 1 ] && [ "$trog" -eq 0 ]; then
    zeleno "Р1-нерезолв: оба класса (npm-ключ, bash-путь) именованы rc 1, --write rc 1, ci.yml не тронут"
  else
    krasno "Р1-нерезолв: имена-классов:$imja_ok файлы-тронуты:$trog: $out$outw"
  fi
  # позитив-контроль: конформный реестр (пустые блоки ДО write — дрейф по умолчанию)
  MK="$SCR/m-konform"; mk_gen_mir "$MK" "$REG_KONFORM"
  bash "$MK/scripts/gen_ci_steps.sh" --write --root "$MK" >/dev/null 2>&1; rcw=$?
  bash "$MK/scripts/gen_ci_steps.sh" --check --root "$MK" >/dev/null 2>&1; rck=$?
  if [ "$rcw" -eq 0 ] && [ "$rck" -eq 0 ]; then
    zeleno "Р1-нерезолв/контроль: конформный реестр --write rc 0, --check rc 0"
  else
    krasno "Р1-нерезолв/контроль: конформный реестр write=$rcw check=$rck (клетка красна на конформном входе)"
  fi
fi

# ── Р1-баланс ─────────────────────────────────────────────────────────────────
if nado Р1-баланс; then
  M="$SCR/m-balans"; mk_gen_mir "$M" "$REG_BALANS"
  out="$(bash "$M/scripts/gen_ci_steps.sh" --write --root "$M" 2>&1)"; rc=$?
  granica=$(( (507 + 5) / 6 + 100 ))   # total=507, K=6: ceil(507/6)+maxw = 85+100 = 185
  maxload=0; nkeys=0; load=0
  while IFS= read -r line; do
    case "$line" in
      *keys:*) ;;
      *) continue ;;
    esac
    nkeys=$((nkeys+1)); load=0
    for k in $line; do
      case "$k" in
        w1|w2|w3|w4|w5) load=$((load+100)) ;;
        w6|w7|w8|w9|w10|w11|w12) load=$((load+1)) ;;
      esac
    done
    [ "$load" -gt "$maxload" ] && maxload="$load"
  done < <(sed -n '/BEGIN GENERATED CI JOBS (083)/,/END GENERATED CI JOBS (083)/p' "$M/.github/workflows/ci.yml")
  if [ "$rc" -eq 0 ] && [ "$nkeys" -eq 0 ]; then
    krasno "Р1-баланс: rc 0, но блок JOBS пуст/не записан — баланс не судим: $out"
  elif [ "$rc" -eq 0 ]; then
    if [ "$maxload" -le "$granica" ]; then
      zeleno "Р1-баланс: rc 0, max load=$maxload ≤ границы $granica (И-4)"
    else
      krasno "Р1-баланс: rc 0 «как получилось»: max load=$maxload > границы $granica (И-4): $out"
    fi
  elif [ "$rc" -eq 1 ] && grep -qi 'баланс' <<<"$out"; then
    zeleno "Р1-баланс: именованный отказ по балансу (rc 1): $out"
  else
    krasno "Р1-баланс: rc=$rc без именованного отказа по балансу (max load=$maxload, граница $granica): $out"
  fi
fi

printf 'red_gen_otkazy_079.sh: зелёных %d, красных %d\n' "$ZELENYH" "$KRASNYH"
[ "$KRASNYH" -eq 0 ] || exit 1
[ "$ZELENYH" -gt 0 ] || exit 2
exit 0
