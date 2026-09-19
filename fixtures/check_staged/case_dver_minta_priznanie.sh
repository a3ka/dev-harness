# ПРИЧИНА: вне зоны: registry/contracts.tsv
#
# Контракт 031, ветвь ii (минт-признание в check_zones.sh): путь registry/contracts.tsv
# под автором orchestrator исключается из суда зон ⟺ дельта коммита по этому пути —
# только-добавление строк грамматики манифеста ∧ для каждой строки тег
# id/CONTRACT/<NNN> жив локально ∧ tag-object-sha == sha строки.
# Зелёный — check_zones на toy с честным закоммиченным минтом (rc 0).
# Красный — check_zones на toy с закоммиченной правкой существующей строки манифеста
# (не-минтная дельта того же пути): «вне зоны: registry/contracts.tsv» — НЕ
# признание пропускает, потому что дельта — правка, не только-добавление.
set -uo pipefail
. "$(dirname "$0")/_repo.sh"
: "${WORK:?WORK должен быть определён раннером}"

g() {
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" \
      -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      -c init.defaultBranch=main "$@"
}
toy_origin() {
  local r="$1" orig="${1%/}-origin.git"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q --bare "$orig"
  git -C "$orig" symbolic-ref HEAD refs/heads/main 2>/dev/null || true
  g "$r" remote add origin "$orig"
  g "$r" push -q origin main
}
make_repo_orchzone() {
  local r="$1"
  mkdir -p "$r/contracts" "$r/scripts"
  {
    printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n'
    printf 'ЗОНА implementer: scripts/\n'
    printf 'ЗОНА orchestrator: HANDOFF.md\n'
  } > "$r/contracts/001-x.md"
  printf 'исходный файл в зоне\n' > "$r/scripts/a.sh"
  printf '# передача\n' > "$r/HANDOFF.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name orchestrator
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email orchestrator@local
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config commit.gpgsign false
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config core.hooksPath /dev/null
  g "$r" add -A
  g "$r" commit -q -m 'основание'
  g "$r" tag -a frozen/contracts/001/1 -m 'контракт утверждён'
}
mint_tag_avtoritet() {
  local r="$1" n="$2"
  g "$r" tag -a "id/CONTRACT/$n" -m 'выдача (фикстура)'
  g "$r" push -q origin "refs/tags/id/CONTRACT/$n"
}
stage_row() {
  local r="$1" n="$2" sha="$3"
  mkdir -p "$r/registry"
  printf '%s → %s\n' "$n" "$sha" >> "$r/registry/contracts.tsv"
  g "$r" add -A
}
commit_kak() {  # автор ЛОКАЛЬНОГО конфига (set_author выставил orchestrator)
  local r="$1" msg="$2"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$r" -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q -m "$msg"
}

# ── зелёный: честный минт, закоммиченный orchestrator'ом (open window) ────────
GREEN="$WORK/repo_green"
make_repo_orchzone "$GREEN"
toy_origin "$GREEN"
mint_tag_avtoritet "$GREEN" "030"
set_author "$GREEN" orchestrator
sha="$(git -C "$GREEN" rev-parse "refs/tags/id/CONTRACT/030")"
stage_row "$GREEN" "030" "$sha"
commit_kak "$GREEN" "манифест: выдача 030 (orchestrator)"
"$BARRIER" "$GREEN" || true   # check_zones на toy

# ── красный: правка существующей строки манифеста (не-минт) ───────────────────
RED="$WORK/repo_red"
make_repo_orchzone "$RED"
toy_origin "$RED"
mint_tag_avtoritet "$RED" "031"
# Коммитим первую строку манифеста авторитетом — потом переминтим и поправим sha.
set_author "$RED" orchestrator
stage_row "$RED" "031" "$(git -C "$RED" rev-parse "refs/tags/id/CONTRACT/031")"
commit_kak "$RED" "реестр: резерв 031"
g "$RED" tag -d "id/CONTRACT/031" >/dev/null
mint_tag_avtoritet "$RED" "031"   # свежий sha на новый тег
# Правка существующей строки (не-минтная дельта): sed перезаписывает sha.
new_sha="$(git -C "$RED" rev-parse "refs/tags/id/CONTRACT/031")"
sed -i "s/^031 → .*$/031 → $new_sha/" "$RED/registry/contracts.tsv"
g "$RED" add -A
commit_kak "$RED" "правка строки манифеста 031 (не-минт)"
"$BARRIER" "$RED" || true   # check_zones откажет: дельта не только-добавление