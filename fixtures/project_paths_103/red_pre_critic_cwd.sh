#!/usr/bin/env bash
# Клетка И-2 «pre_critic на проектном репо не зависит от cwd» (контракт 103).
# Вход: `pre_critic.sh --repo <R> tasks/h/NNN-….md` (путь контракта — от
# корня ПРОЕКТА по workflowPaths.contracts, не от корня харнеса). Три cwd:
# корень проекта, подкаталог проекта, посторонний каталог /tmp/dev-harness-verify.
# Тогда: (а) полный контракт — rc 0 из всех трёх cwd; (б) контракт без
# КОНТЕКСТ:-строк — rc 1 из всех трёх cwd и первая строка stderr побайтово
# одинакова. Обман (путь от cwd) → из постороннего cwd «не найден» (rc 2) → красно.
# (в) Нога (г) формы вооружается ПРОФИЛЬНЫМ реестром по эффективному
# workflowPaths.registry из profile_resolver.sh (Рв96-2): мир со слоем ВНЕ репо
# (репо-слой без workflowPaths, слой по HARNESS_PROJECT_LAYER_ROOT=<мир>/layer),
# в R есть tasks/reg/contracts.tsv; полный контракт → rc 0; контракт без
# КОНТЕКСТ: → rc 1 со словом «форма». Второй резолвер (свой jq по R) значения не
# видит, нога молча разоружается → rc 0 → красно.
# (г)/(д) Ноги (а)/(б) на --repo ВООРУЖЕНЫ (Frontier И-2: npm-гейты зовутся с R;
# Рв96-3/Рв96-13): контракт ПОЛНОЙ формы 779 с «ПЕРЕСЕЧЕНИЕ» не по грамматике
# 043 → rc 1 из трёх cwd, первая строка stderr несёт маркер «precision-gate»
# (нога (а)); контракт полной формы 780 с ложным замером 036 (`= 99 census`)
# → rc 1 из трёх cwd, маркер «spec-ready» (нога (б)). Входы ортогональны
# (на 779 spec-ready зелен, на 780 precision зелен): снятая либо условная на
# --repo нога (а) даёт на 779 rc 0 или чужой маркер → красно; то же для (б) на
# 780 (мутанты PC3a/PC3b ревьюера, реализация круга 1).
# Клетка прогоняет все входы, каждый красен своей строкой.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t103_pre_critic)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: pre-critic-cwd: предмет отсутствует: scripts/pre_critic.sh\n' >&2; exit 1; }
W="$(_t103_world i2)" || exit 2
trap '_t103_cleanup "$W"; _t103_cleanup "${W2:-}"' EXIT
R="$W/repo"
mkdir -p "$W/vne"
itog=0

bez_formy() {  # <репо>: контракт 778 без строк КОНТЕКСТ:
  _t103_contract "$1/tasks/h/778-bez.md" 778
  sed -i '/^КОНТЕКСТ:/d' "$1/tasks/h/778-bez.md"
  git -C "$1" add -A; git -C "$1" commit -qm 'контракт без формы'
}
run() {  # <cwd> <репо> <контракт> → печатает "rc<TAB>первая строка stderr"
  local rc err
  err="$(cd "$1" && bash "$SUBJ" --repo "$2" "$3" 2>&1 >/dev/null)"; rc=$?
  printf '%s\t%s' "$rc" "$(printf '%s\n' "$err" | head -n 1)"
}
# otkaz_iz_treh_cwd <метка> <репо> <контракт> <маркер>: из корня проекта rc 1 и
# маркер в первой строке stderr; из подкаталога и постороннего cwd — тот же вердикт побайтово.
otkaz_iz_treh_cwd() {
  local label="$1" repo="$2" c="$3" marker="$4" ref res cwd
  ref="$(run "$repo" "$repo" "$c")"
  if [ "${ref%%	*}" != "1" ]; then
    printf 'КРАСНО: %s: %s из корня проекта rc=%s (ждали 1 «%s»): %s\n' "$label" "$c" "${ref%%	*}" "$marker" "${ref#*	}" >&2; itog=1; return
  fi
  if ! printf '%s\n' "${ref#*	}" | grep -Fq -- "$marker"; then
    printf 'КРАСНО: %s: отказ без маркера «%s»: %s\n' "$label" "$marker" "${ref#*	}" >&2; itog=1; return
  fi
  for cwd in "$repo/tasks" "$W/vne"; do
    res="$(run "$cwd" "$repo" "$c")"
    if [ "$res" != "$ref" ]; then
      printf 'КРАСНО: %s: вердикт зависит от cwd=%s\n--- корень: %s\n--- здесь:  %s\n' "$label" "$cwd" "$ref" "$res" >&2; itog=1; return
    fi
  done
  printf -- '— %s: три cwd, вердикт один («%s»)\n' "$label" "$marker"
}

# ── (а)/(б): слой в репо, три cwd ──
bez_formy "$R"
for cwd in "$R" "$R/tasks" "$W/vne"; do
  res="$(run "$cwd" "$R" tasks/h/777-toy.md)"; rc="${res%%	*}"
  if [ "$rc" -ne 0 ]; then
    printf 'КРАСНО: i2: полный контракт из cwd=%s: rc=%s (ждали 0): %s\n' "$cwd" "$rc" "${res#*	}" >&2; itog=1
  fi
done
otkaz_iz_treh_cwd i2 "$R" tasks/h/778-bez.md 'форма'

# ── (г)/(д): ноги (а)/(б) вооружены на --repo — красный гейт харнеса = отказ с маркером ноги ──
_t103_contract "$R/tasks/h/779-peresechenie.md" 779
printf 'ПЕРЕСЕЧЕНИЕ implementer: scripts/toy.sh без номера\n' >>"$R/tasks/h/779-peresechenie.md"
_t103_contract "$R/tasks/h/780-zamer.md" 780
printf '\nзамер: `ls tasks/h/*.md | wc -l` = 99 census tasks/h/*.md\n' >>"$R/tasks/h/780-zamer.md"
git -C "$R" add -A; git -C "$R" commit -qm 'контракты с красными гейтами (а)/(б)'
otkaz_iz_treh_cwd i2г "$R" tasks/h/779-peresechenie.md 'precision-gate'
otkaz_iz_treh_cwd i2д "$R" tasks/h/780-zamer.md 'spec-ready'

# ── (в): слой вне репо — нога (г) вооружена по резолверу ──
W2="$(_t103_world_sloj_vne i2-sloj)" || exit 2
R2="$W2/repo"
export HARNESS_PROJECT_LAYER_ROOT="$W2/layer"
[ -r "$R2/tasks/reg/contracts.tsv" ] || { printf 'КРАСНО: i2в: мир сломан — нет tasks/reg/contracts.tsv\n' >&2; exit 2; }
bez_formy "$R2"
res="$(run "$W/vne" "$R2" tasks/h/777-toy.md)"
if [ "${res%%	*}" != "0" ]; then
  printf 'КРАСНО: i2в: полный контракт при слое вне репо: rc=%s (ждали 0): %s\n' "${res%%	*}" "${res#*	}" >&2; itog=1
fi
res="$(run "$W/vne" "$R2" tasks/h/778-bez.md)"
if [ "${res%%	*}" != "1" ] || ! printf '%s\n' "${res#*	}" | grep -Fq 'форма'; then
  printf 'КРАСНО: i2в: нога (г) не вооружена профильным реестром по резолверу при слое вне репо (rc=%s, ждали 1 «форма»): %s\n' "${res%%	*}" "${res#*	}" >&2; itog=1
else
  printf -- '— i2в: слой вне репо, нога (г) вооружена\n'
fi
exit "$itog"
