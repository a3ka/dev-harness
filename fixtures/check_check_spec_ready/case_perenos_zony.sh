# ПРИЧИНА: спек-гейт 036: перенос зоны
# Мета-барьер ловит: валидный СПАСЕНО-перенос (ЗОНА сужена в v2, СПАСЕНО покрывает
# исторические коммиты по выпавшему пути) = rc 0 «OK»; перенос зоны без СПАСЕНО = rc 1
# «перенос зоны». Тестовая пара сшита с г4 red_perenos_zony_036.
set -euo pipefail
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

make_repo() {
  local r="$1" declaration="${2:-}"
  mkdir -p "$r/contracts" "$r/verdicts/critic" "$r/scripts" "$r/tmp"
  {
    printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n'
    [ -n "$declaration" ] && printf '%s\n' "$declaration"
  } > "$r/contracts/001-x.md"
  printf 'accept\nвердикт критика\n' > "$r/verdicts/critic/contracts-001-v1.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name Фикстура
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email fixture@local
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config commit.gpgsign false
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config core.hooksPath /dev/null
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" add -A
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" -c user.name=Фикстура -c user.email=fixture@local -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q -m 'основание'
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" tag -a frozen/contracts/001/1 -m 'v1 утверждён'
}
g() {
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" \
      -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      "$@"
}
freeze_ver() {
  local r="$1" v="$2" decl="$3"
  {
    printf '# контракт 001 v%s\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n' "$v"
    printf '%s\n' "$decl"
  } > "$r/contracts/001-x.md"
  printf 'accept\nвердикт критика v%s\n' "$v" > "$r/verdicts/critic/contracts-001-v$v.md"
  g "$r" add -A && g "$r" commit -q -m "v$v"
  g "$r" tag -a "frozen/contracts/001/$v" -m "v$v утверждён"
}

# Зелёный контроль: валидный СПАСЕНО-перенос.
T="$WORK/green"; make_repo "$T" 'ЗОНА implementer: scripts/foo.sh scripts/bar.sh'
printf 'foo\n' > "$T/scripts/foo.sh"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$T" -c user.name=implementer -c user.email=impl@local -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$T" -c user.name=implementer -c user.email=impl@local -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q -m 'исторический коммит по foo'
FOO_SHA=$(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$T" rev-parse HEAD)
freeze_ver "$T" 2 "ЗОНА implementer: scripts/bar.sh
СПАСЕНО implementer: $FOO_SHA — перенос в семейство Y"
"$BARRIER" "$T" contracts/001-x.md

# Красное: перенос зоны без СПАСЕНО.
R="$WORK/red"; make_repo "$R" 'ЗОНА implementer: scripts/foo.sh scripts/bar.sh'
printf 'foo\n' > "$R/scripts/foo.sh"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" -c user.name=implementer -c user.email=impl@local -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" -c user.name=implementer -c user.email=impl@local -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q -m 'исторический коммит по foo'
freeze_ver "$R" 2 'ЗОНА implementer: scripts/bar.sh'
"$BARRIER" "$R" contracts/001-x.md