#!/usr/bin/env bash
# Барьер приёмки ИНТЕГРАЦИИ scoped-режима в раннер (контракт 006, тир 2). Гоняет
# `<корень>/scripts/verify_antiplacebo.sh --changed` на ПОРОЖДЁННОМ игрушечном дереве и
# УТВЕРЖДАЕТ:
#   (л) ФИЛЬТР: при правке одного барьера прогнан ТОЛЬКО он («барьеров: 1»), не весь набор —
#       ловит фильтр, который выронил бы выбранный барьер либо не сузил выборку;
#   (м) СОХРАНЕНИЕ ОТКАЗА: выбранный барьер, чьё красное НЕ предъявлено (сломан), краснит scoped
#       ТОЧНО как полный — ловит раннер, глотающий отказ выбранного в scoped-режиме (обход 2).
# Слепок (н) — СТРУКТУРНО: §Предмет обязывает интеграцию быть фильтром над существующим циклом,
# слепок брекетит цикл и кодом фильтра не трогается; держат существующие фикстуры
# fixtures/verify_antiplacebo/ (запись вне $WORK), которые в scoped-режиме идут тем же кодом.
#
# Образец — check_metering/check_scope_select: предмет (`verify_antiplacebo.sh --changed`) пишет
# ИСПОЛНИТЕЛЬ; этот барьер и fixtures/check_scoped_run/ — АРХИТЕКТОРА; фикстуры предъявляют ЕГО
# красным, подавая обманный verify_antiplacebo в подставной корень.
#
#   bash scripts/check_scoped_run.sh [<корень>] [<ветвь>]
#     <корень> — где лежит scripts/verify_antiplacebo.sh (умолчание — корень репозитория);
#     <ветвь>  — л | м (умолчание — обе).
#
# Коды возврата: 0 — запрошенные ветви зелены, 1 — ветвь провалена, 2 — нечем проверить.
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null LC_ALL="${LC_ALL:-C.UTF-8}"

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${1:-$(cd "$SELF_DIR/.." && pwd)}"
WANT="${2:-all}"
ROOT="$(cd "$ROOT" 2>/dev/null && pwd || echo "$ROOT")"
VA="$ROOT/scripts/verify_antiplacebo.sh"

die()  { printf 'ОТКАЗ ветвь (%s): %s\n' "$1" "$2" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

command -v git >/dev/null 2>&1 || skip "нет git — игрушку не построить"
[ -f "$VA" ] || skip "нет $VA — предмет проверки отсутствует"

TMP_ROOT="$SELF_DIR/../tmp"; mkdir -p "$TMP_ROOT" 2>/dev/null || skip "tmp не создать"
WORK="$(mktemp -d "$TMP_ROOT/check_scoped_run.XXXXXX")" || skip "mktemp не смог"
WORK="$(cd "$WORK" && pwd -P)"; export GIT_CEILING_DIRECTORIES="$WORK"
trap 'rm -rf "$WORK"' EXIT

gg() { git -C "$1" -c user.name=T -c user.email=t@l -c commit.gpgsign=false \
       -c core.hooksPath=/dev/null -c init.defaultBranch=main "${@:2}"; }

# Строит валидное антиплацебо-дерево: барьеры a,b ($0-относительный маркер) + их фикстуры +
# встроенный корректный scope_select (НЕ БАРЬЕР). Если $2=broken — фикстура b НЕ предъявляет
# красное (маркер не снимается), полный раннер обязан покраснеть на b. Печатает BASE в глоб. BASE.
build_toy() {  # <каталог> [broken]
  local r="$1" broken="${2:-}"
  mkdir -p "$r/scripts" "$r/fixtures/a" "$r/fixtures/b"
  local x
  for x in a b; do
    cat > "$r/scripts/$x.sh" <<EOF
#!/usr/bin/env bash
# Коды возврата: 0 — маркер есть, 1 — нет
d="\$(cd "\$(dirname "\$0")/.." && pwd)"
[ -f "\$d/mark" ] || { echo "нет mark ($x)" >&2; exit 1; }
EOF
    chmod +x "$r/scripts/$x.sh"
  done
  # честные фикстуры: зелёный контроль (маркер есть) → порча (снят) → красное
  for x in a b; do
    cat > "$r/fixtures/$x/case_$x.sh" <<EOF
# ПРИЧИНА: нет mark ($x)
set -euo pipefail
mkdir -p "\$WORK/w"; touch "\$WORK/w/mark"
BARRIER_ROOT="\$WORK/w" "\$BARRIER"
rm -f "\$WORK/w/mark"
BARRIER_ROOT="\$WORK/w" "\$BARRIER"
EOF
  done
  if [ "$broken" = broken ]; then
    # b НЕ снимает маркер → красное не предъявлено → полный раннер краснеет на b
    cat > "$r/fixtures/b/case_b.sh" <<EOF
# ПРИЧИНА: нет mark (b)
set -euo pipefail
mkdir -p "\$WORK/w"; touch "\$WORK/w/mark"
BARRIER_ROOT="\$WORK/w" "\$BARRIER"
BARRIER_ROOT="\$WORK/w" "\$BARRIER"
EOF
  fi
  cat > "$r/scripts/scope_select.sh" <<'EOF'
#!/usr/bin/env bash
# НЕ БАРЬЕР: игрушечный селектор
r="$1"; base="${3:-}"
ch="$(git -C "$r" diff --name-only "$base" HEAD 2>/dev/null)" || { echo "MODE: needs-full"; exit 2; }
keys=""
for p in $ch; do case "$p" in scripts/*.sh) k="${p#scripts/}"; k="${k%.sh}"; [ "$k" = scope_select ] && continue; keys="$keys $k" ;; esac; done
[ -n "${keys// /}" ] || { echo "SCOPED: 0 задетых" >&2; echo "MODE: needs-full"; exit 2; }
echo "SCOPED: не для приёмки" >&2; echo "MODE: scoped"; for k in $keys; do echo "KEY: $k"; done
EOF
  chmod +x "$r/scripts/scope_select.sh"
  gg "$r" init -q -b main .
  gg "$r" add -A; gg "$r" commit -q -m base
  BASE="$(gg "$r" rev-parse HEAD)"
}

run_va() { OUT="$( "$VA" "$@" 2>&1 )"; RC=$?; }
want() { [ "$WANT" = all ] || [ "$WANT" = "$1" ]; }

if want л; then
  T="$WORK/л"; build_toy "$T"
  printf '# правка\n' >> "$T/scripts/b.sh"; gg "$T" commit -q -am 'правка b'
  run_va "$T" --changed "$BASE"
  printf '%s\n' "$OUT" | grep -q 'барьеров: 1' \
    || die л "правка одного барьера дала не «барьеров: 1» — фильтр не сузил выборку. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '%s\n' "$OUT" | grep -q 'b/case_b.sh' \
    || die л "выбранный барьер b не прогнан — фильтр выронил задетое"
  printf '%s\n' "$OUT" | grep -q 'a/case_a.sh' \
    && die л "барьер a прогнан, хотя не задет — выборка не сужена"
  printf '  ok   (л) фильтр: прогнан ровно выбранный b\n' >&2
fi

if want м; then
  T="$WORK/м"; build_toy "$T" broken
  printf '# правка\n' >> "$T/scripts/b.sh"; gg "$T" commit -q -am 'правка b'
  run_va "$T"; full_rc="$RC"
  [ "$full_rc" != 0 ] || die м "полный прогон на сломанном b дал 0 — тест не про предмет (b обязан краснеть)"
  run_va "$T" --changed "$BASE"
  [ "$RC" != 0 ] || die м "scoped проглотил отказ выбранного b (полный=$full_rc, scoped=0) — ветви отказа не сохранены"
  printf '  ok   (м) отказ выбранного барьера сохранён в scoped (полный=%s, scoped=%s)\n' "$full_rc" "$RC" >&2
fi

printf 'check_scoped_run: ветви «%s» зелены\n' "$WANT" >&2
exit 0
