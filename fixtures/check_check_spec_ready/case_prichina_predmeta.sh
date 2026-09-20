# ПРИЧИНА: спек-гейт 036: проба красна без заявленной причины
# Мета-барьер ловит: честный spec-preflight на честной пробе (rc=1 с суффиксом
# «→ красная: <фраза>» и выводом, несущим фразу) = rc 0 «OK» — ре-фриз реализованного
# предмета видит зелёное, асимметрия названа в контракте 036 §В1-семантика; ослабленный
# черновик (проба rc=1 без суффикса) = rc 1 «красна без заявленной причины» (Н-38/Н-113,
# «любая краснота проходит предполёт»). Тестовая пара сшита с г2 red_prichina_predmeta.
set -euo pipefail
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

# make_toy <каталог>: создаёт пустой git-репозиторий с базовым деревом.
make_toy() {
  local r="$1"
  mkdir -p "$r/contracts" "$r/verdicts/critic"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name Фикстура
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email fixture@local
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config commit.gpgsign false
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config core.hooksPath /dev/null
}
g() {
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" \
      -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      "$@"
}
write_commit() {
  local r="$1" priemka="$2"
  { printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Приёмка\n'
    printf '%s\n' "$priemka" ; } > "$r/contracts/001-x.md"
  g "$r" add -A && g "$r" commit -q -m 'основание'
}

# Зелёный контроль: честная проба (rc=1, причина в выводе и в суффиксе).
G="$WORK/green"; make_toy "$G"
write_commit "$G" '- `bash honest.sh` → красная: HONEST_REASON'
printf 'echo HONEST_REASON >&2\nexit 1\n' > "$G/honest.sh"
chmod +x "$G/honest.sh"
"$BARRIER" "$G" contracts/001-x.md

# Красное: проба rc=1 без суффикса (т.е. без «→ красная: <фраза>»).
R="$WORK/red"; make_toy "$R"
write_commit "$R" '- `bash weak.sh`'
printf 'exit 1\n' > "$R/weak.sh"
chmod +x "$R/weak.sh"
"$BARRIER" "$R" contracts/001-x.md