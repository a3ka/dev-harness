#!/usr/bin/env bash
# Каркас семьи done_task_096 (контракт 096, круг 1) — toy-миры, субъект,
# разметка doneProfile/issue-state/candidates.tsv/spend.tsv/state.tsv.
#
# Субъект: scripts/done_project.sh (грамматика — model/dover.sh, честная
# модель). Клетки берут субъект из DT096_SUBJECT (раннер ставит real|model),
# корень дерева — из DT096_ROOT. Миры — ТОЛЬКО
# /tmp/dev-harness-verify/done-task-096-** (Н-85/А-122), каждая клетка вычищает
# свой мир за собой (trap).
#
# Носители круга 1 — РЕАЛЬНЫЕ пути и грамматики (слово владельца: «не
# изобретать второй источник истины»):
#   <repo>/harness/done-profile.tsv           — doneProfile (toy-носитель, И-0);
#                                              kind TAB key TAB value;
#                                              kinds: repoId, projectId,
#                                              issueField, tagFormat,
#                                              contracts, commands, docs,
#                                              issuePolicy;
#   <repo>/harness/issue-state.tsv            — issue state (И-8): строки
#                                              url TAB status TAB projectField
#                                              TAB projectFieldValue;
#   <repo>/registry/candidates.tsv            — публикации 094 (И-7): строки
#                                              published TAB object_id TAB merge
#                                              TAB seq;
#   <repo>/registry/spend.tsv                 — учёт расхода (И-9): строки
#                                              task TAB commit TAB duration_min
#                                              TAB ci_min TAB cost TAB
#                                              interventions TAB notes;
#   <repo>/.omp/done/<NNN>.state.tsv          — состояние ступеней (И-15):
#                                              step TAB status TAB ts;
#                                              .omp — вне git-индекса.
#
# Оракулы-sha клетка читает САМА в память (git rev-parse / sha256sum) ДО
# вызова субъекта (правило 8): диск проверяемого не перечитывается ПОСЛЕ
# исполнения субъекта.
set -uo pipefail

t96_ni() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

_t96_subject() {  # путь субъекта: DT096_SUBJECT | <корень>/scripts/done_project.sh
  if [ -n "${DT096_SUBJECT:-}" ]; then printf '%s\n' "$DT096_SUBJECT"; return 0; fi
  local root="${DT096_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  printf '%s\n' "$root/scripts/done_project.sh"
}

# _t96_profile_minimal <repo> <projectId> <NNN> <class> — записать toy done-profile
# с минимальным составом для одной задачи: repoId/projectId/contracts/commands/docs/issuePolicy.
_t96_profile_minimal() {
  local r="$1" pid="$2" nnn="$3" klass="$4"
  mkdir -p "$r/harness"
  {
    printf 'repoId=%s\n' "toy-096"
    printf 'projectId=%s\n' "$pid"
    printf 'issueField=closed\n'
    printf 'tagFormat=done/project/%s/<v>\n' "$pid"
    printf 'contracts\t%s\t%s\n' "$nnn" "$klass"
    case "$klass" in
      code)
        printf 'command\tcode\tlint\tbash ./scripts/lint.sh\n'
        printf 'command\tcode\tbuild\tbash ./scripts/build.sh\n'
        printf 'command\tcode\tsecrets\tbash ./scripts/secrets.sh\n'
        printf 'doc\tcode\tCODING-STANDARDS.md\n'
        printf 'issuePolicy\tcode\tclose\n'
        ;;
      doc)
        printf 'command\tdoc\tmarkdownlint\tbash ./scripts/markdownlint.sh\n'
        printf 'doc\tdoc\tCHANGELOG.md\n'
        printf 'issuePolicy\tdoc\tclose\n'
        ;;
      research)
        printf 'command\tresearch\tadr-create\tbash ./scripts/adr-new.sh\n'
        printf 'doc\tresearch\tdecisions/%s-research.md\n' "$nnn"
        printf 'issuePolicy\tresearch\treference\n'
        ;;
    esac
  } >"$r/harness/done-profile.tsv"
}

# _t96_world <slug> [class] [projectId] [NNN] [extras…] — toy-мир: репо с
# минимальным составом для одной задачи. class по умолчанию code, projectId
# по умолчанию toy, NNN по умолчанию 096. Печатает каталог мира.
# extras — произвольные команды (после cd в repo), напр. «файл изменён» или
# «находка добавлена».
_t96_world() {
  local slug="$1" klass="${2:-code}" pid="${3:-toy}" nnn="${4:-096}"
  shift; shift; shift; shift
  local d
  d="/tmp/dev-harness-verify/done-task-096-${slug}-$$-${RANDOM}"
  mkdir -p "$d/repo" || t96_ni "мир не строится: $d"
  git init -q --initial-branch=main "$d/repo" 2>/dev/null || t96_ni "git init"
  git -C "$d/repo" config user.name orchestrator
  git -C "$d/repo" config user.email orchestrator@dev-harness.local
  mkdir -p "$d/repo/registry" "$d/repo/.review" "$d/repo/harness" \
           "$d/repo/decisions" "$d/repo/scripts" "$d/repo/.omp/done" \
           "$d/repo/contracts" "$d/repo/docs"

  # Минимальный контракт-носитель (Приёмка + ЗОНА)
  cat >"$d/repo/contracts/${nnn}-toy.md" <<EOF
# Контракт ${nnn} (toy)

## Приёмка

- (toy) критерий приёмки один

ЗОНА architect fixtures/done_task_096/ fixtures/_krasnye_096.sh contracts/${nnn}-*.md
ЗОНА implementer scripts/done_project.sh scripts/done_contract.sh scripts/lint.sh scripts/build.sh scripts/secrets.sh scripts/markdownlint.sh scripts/adr-new.sh CODING-STANDARDS.md CHANGELOG.md decisions/ registry/spend.tsv harness/done-profile.tsv

## Предмет

toy-предмет.
EOF

  _t96_profile_minimal "$d/repo" "$pid" "$nnn" "$klass"

  # Минимальный рабочий реестр spend (пустой)
  : >"$d/repo/registry/spend.tsv"
  # Кандидаты — пусто (добавит клетка, если нужны)
  : >"$d/repo/registry/candidates.tsv"
  # Issue state — по умолчанию «closed:complete + doneStatus=completed»
  # для ускорения клеток (клетки про issue/поле перезапишут это)
  printf 'https://example.com/issue/096\tclosed:complete\tdoneStatus\tcompleted\n' >"$d/repo/harness/issue-state.tsv"
  # Pre-set done-теги: done/contracts/096/1 на main (038-канал),
  # done/project/toy/1 — гард сам поставит в И-10 (это нормальный flow).

  # Файлы-носители для зон (минимальные) — в main
  mkdir -p "$d/repo/fixtures"
  printf '# zone-stub for 096\n' >"$d/repo/fixtures/_krasnye_096.sh"

  # Базовый коммит на main: контракт + минимальный harness + zone stubs
  git -C "$d/repo" add -A
  git -C "$d/repo" commit -qm "base: contract $nnn + doneProfile ($klass) + zone-stubs"
  # 038-канал: установить done/contracts/096/1 на base (харнес-тег; «вы» 038
  # были бы предыдущим витком — здесь это простое pre-set, чтобы зелёные
  # сценарии клеток не падали в И-10 из-за отсутствия тега)
  git -C "$d/repo" tag -f "done/contracts/${nnn}/1" "HEAD^{}" 2>/dev/null || true
  git -C "$d/repo" checkout -qb cand

  # Заглушка-cand: добавим простую строку в существующий файл В ЗОНЕ,
  # чтобы merge-tree всегда имел непустой diff по зоне
  mkdir -p "$d/repo/fixtures"
  printf '\n' >>"$d/repo/fixtures/_krasnye_096.sh"
  printf '# cand baseline append\n' >>"$d/repo/fixtures/_krasnye_096.sh"
  git -C "$d/repo" add -A
  git -C "$d/repo" commit -qm 'cand: baseline zone append'

  # Выполнение extras (доп. изменения в cand)
  if [ $# -gt 0 ]; then
    for cmd in "$@"; do
      ( cd "$d/repo" && eval "$cmd" )
    done
    git -C "$d/repo" add -A 2>/dev/null || true
    git -C "$d/repo" commit -qm 'cand: extras' 2>/dev/null || true
  fi

  git -C "$d/repo" checkout -q main
  printf '%s\n' "$d"
}

# _t96_cleanup <каталог-мира> — регистрируется trap'ом клетки
_t96_cleanup() { rm -rf "$1" 2>/dev/null || true; }

# _t96_sha7 <rev> — короткий sha-7 для --commit-sha
_t96_sha7() { git -C "$2" rev-parse --short=7 "$1" 2>/dev/null || true; }

# _t96_sha40 <repo> <rev>
_t96_sha40() { git -C "$1" rev-parse --verify "$2" 2>/dev/null || true; }

# _t96_object_id <repo> <task> <target> <base> <candidate> <merge> <policyVersion> —
# sha256 канонической строки из 7 полей (прецедент 094 И-1б); на этом круге
# использует содержимое harness/policy (toy-носитель рядом с done-profile).
_t96_object_id() {
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "$4" "$5" "$6" "$7" \
    | sha256sum | cut -d' ' -f1
}

# _t96_published_row <journal> <oid> <merge> <seq>
_t96_published_row() { printf 'published\t%s\t%s\t%s\n' "$2" "$3" "$4" >>"$1"; }
