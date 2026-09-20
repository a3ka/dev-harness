# ПРИЧИНА: спек-гейт 036: census вне корня
# Мета-барьер ловит: census-глоб, физически (readlink -f) разрешающийся ЗА пределы
# канонического корня через symlink (арбитраж 036 корень А, эксплоит к3: `a ->
# ../outside`, глоб `a/*.txt` лексически чист — ни `..`, ни ведущий `/` в самом
# глобе нет, лексический ранний барьер к2 его пропускает) = rc 1 «census вне
# корня: <элемент> разрешается вне дерева-кандидата»; symlink ВНУТРИ корня (`b ->
# probes`, глоб `b/*.txt` — разрешение остаётся физически внутри дерева) = rc 0
# «OK», легален (арбитраж 036 корень А, замер 3.3: запрещается не переход по
# ссылке, а физический выход РАЗРЕШЁННОГО объекта за канонический корень).
# Тестовая пара сшита с вердиктом arbiter glob-mutacija-036.md (74c1f8d).
set -euo pipefail
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

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
  local r="$1" contract="$2"
  printf '%s\n' "$contract" > "$r/contracts/001-x.md"
  g "$r" add -A && g "$r" commit -q -m 'основание'
}

# Зелёный контроль: symlink ВНУТРИ корня (b -> probes), глоб b/*.txt — физическое
# разрешение остаётся внутри дерева-кандидата, легально (арбитраж 036 замер 3.3).
G="$WORK/green"; make_toy "$G"
mkdir -p "$G/probes"
printf 'x\n' > "$G/probes/g1.txt"
ln -s probes "$G/b"
write_commit "$G" '# контракт 001
## Предмет
подставной предмет
## Приёмка
замер: `ls b/*.txt | wc -l` = 1 census b/*.txt'
"$BARRIER" "$G" contracts/001-x.md

# Красное: symlink ЗА пределы корня (a -> ../outside), глоб a/*.txt лексически
# чист (нет `..` в самом глобе) — эксплоит к3 арбитража 036, физическое
# разрешение уходит из дерева-кандидата в соседний каталог.
OUTSIDE="$WORK/red-outside"
mkdir -p "$OUTSIDE"
printf 'x\n' > "$OUTSIDE/out.txt"
R="$WORK/red"; make_toy "$R"
ln -s ../red-outside "$R/a"
write_commit "$R" '# контракт 001
## Предмет
подставной предмет
## Приёмка
замер: `ls a/*.txt | wc -l` = 1 census a/*.txt'
"$BARRIER" "$R" contracts/001-x.md
