# ПРИЧИНА: спек-гейт 036: замер расходится
# Мета-барьер ловит: согласованный замер (заявлено N, команда даёт N, гейт САМ
# пересчитывает глоб → N) = rc 0 «OK»; расходящийся замер (заявлено N, но census-глоб
# покрывает больше/меньше файлов — обход 035-класса, Б3 дословно «printf 999» при
# пустом глобе) = rc 1 «расходится». Тестовая пара сшита с г3/г3б red_zamer_036.
set -euo pipefail
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

make_toy() {
  local r="$1"
  mkdir -p "$r/contracts" "$r/verdicts/critic" "$r/probes"
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
mk3() {
  local r="$1"
  printf 'x\n' > "$r/probes/g1.sh"
  printf 'x\n' > "$r/probes/g2.sh"
  printf 'x\n' > "$r/probes/g3.sh"
  g "$r" add -A && g "$r" commit -q -m 'основание: три файла'
}
write_commit() {
  local r="$1" contract="$2"
  printf '%s\n' "$contract" > "$r/contracts/001-x.md"
  g "$r" add -A && g "$r" commit -q -m 'контракт'
}

# Зелёный контроль: согласованный замер (3 файла, команда даёт 3, гейт пересчитывает 3).
G="$WORK/green"; make_toy "$G"; mk3 "$G"
write_commit "$G" '# контракт 001
## Предмет
подставной предмет
## Приёмка
замер: `ls probes/g*.sh | wc -l` = 3 census probes/g*.sh'
"$BARRIER" "$G" contracts/001-x.md

# Красное: расходящийся замер (заявлено 2, команда даёт 2, глоб покрывает 3 файла).
R="$WORK/red"; make_toy "$R"; mk3 "$R"
write_commit "$R" '# контракт 001
## Предмет
подставной предмет
## Приёмка
замер: `grep -l шляпа probes/g*.sh | wc -l` = 2 census probes/g*.sh'
"$BARRIER" "$R" contracts/001-x.md