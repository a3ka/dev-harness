#!/usr/bin/env bash
# Барьер приёмки scoped-селектора (контракт 006). Гоняет `<корень>/scripts/scope_select.sh` по
# ветвям а–л на ПОРОЖДЁННЫХ игрушечных git-деревьях и УТВЕРЖДАЕТ выбор/режим/код/причину.
# Образец — `check_metering.sh`: предмет (`scope_select.sh`) объявляет `НЕ БАРЬЕР:`, барьер —
# этот файл; фикстуры `fixtures/check_scope_select/` предъявляют ЕГО красным, подавая сломанный
# scope_select в подставном дереве.
#
# КОНТРАКТ ВЫВОДА scope_select (закреплён здесь, реализация конформна):
#   stdout: `MODE: full|scoped|needs-full`, затем строки `KEY: <ключ>` (для scoped, 0+);
#   stderr: ДЛЯ SCOPED И NEEDS-FULL — строка `SCOPED: … — не для приёмки`; диагностика/причина;
#   код: 0 — выборка готова (full|scoped), 1 — ошибка использования (неизвестный ключ/case,
#        пустой --scope), 2 — нечем проверить / нужен полный (needs-full: 0 задетых, нет git).
#
# Каждая ветвь называет ПРИЧИНУ отказа при провале — подстрока печатается ТОЛЬКО на красном
# (её и грепает фикстура). Зелёная ветвь причину НЕ печатает.
#
#   bash scripts/check_scope_select.sh [<корень>] [<ветвь>]
#     <корень> — где лежит scripts/scope_select.sh (умолчание — корень репозитория);
#     <ветвь>  — одна из а б в г д е ж з и к л (умолчание — все).
#
# Коды возврата: 0 — все запрошенные ветви зелены, 1 — ветвь провалена, 2 — нечем проверить.
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null LC_ALL="${LC_ALL:-C.UTF-8}"

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${1:-$(cd "$SELF_DIR/.." && pwd)}"
WANT="${2:-all}"
ROOT="$(cd "$ROOT" 2>/dev/null && pwd || echo "$ROOT")"
SEL="$ROOT/scripts/scope_select.sh"

die()  { printf 'ОТКАЗ ветвь (%s): %s\n' "$1" "$2" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

command -v git >/dev/null 2>&1 || skip "нет git — игрушечные деревья не построить"
[ -f "$SEL" ] || skip "нет $SEL — предмет проверки отсутствует"

TMP_ROOT="$SELF_DIR/../tmp"; mkdir -p "$TMP_ROOT" 2>/dev/null || skip "каталог tmp не создать"
WORK="$(mktemp -d "$TMP_ROOT/check_scope_select.XXXXXX")" || skip "mktemp не смог"
WORK="$(cd "$WORK" && pwd -P)"
export GIT_CEILING_DIRECTORIES="$WORK"
trap 'rm -rf "$WORK"' EXIT

gg() {  # git в подставном дереве, герметично
  local r="$1"; shift
  git -C "$r" -c user.name=Проба -c user.email=probe@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null -c init.defaultBranch=main "$@"
}

# Строит подставной репозиторий: два барьера a,b; библиотека lib_x (сорсится b); фикстуры;
# README как «доки». Печатает БАЗУ (sha основания) в переменную BASE.
build_repo() {  # <каталог>
  local r="$1"
  mkdir -p "$r/scripts" "$r/fixtures/a" "$r/fixtures/b"
  printf '#!/usr/bin/env bash\n# Коды возврата: 0 — ок, 1 — отказ\nexit 0\n' > "$r/scripts/a.sh"
  printf '#!/usr/bin/env bash\n# Коды возврата: 0 — ок, 1 — отказ\n. "$(dirname "$0")/lib_x.sh"\nexit 0\n' > "$r/scripts/b.sh"
  printf '#!/usr/bin/env bash\n# НЕ БАРЬЕР: общая библиотека, сорсится b\nlim() { echo 10; }\n' > "$r/scripts/lib_x.sh"
  printf '# ПРИЧИНА: заглушка a\nexit 1\n' > "$r/fixtures/a/case_bad.sh"
  printf '# ПРИЧИНА: заглушка b\nexit 1\n' > "$r/fixtures/b/case_bad.sh"
  printf 'документация\n' > "$r/README.md"
  git init -q -b main "$r"
  gg "$r" add -A; gg "$r" commit -q -m основание
  BASE="$(gg "$r" rev-parse HEAD)"
}

# Прогон селектора: печатает «rc<TAB>stdout» в глобальные RC/OUT/ERRLOG.
run_sel() {  # <репо> <аргументы...>
  local r="$1"; shift
  OUT="$( "$SEL" "$r" "$@" 2>"$WORK/err" )"; RC=$?
  ERR="$(cat "$WORK/err")"
}

has() { case "$2" in *"$1"*) return 0 ;; *) return 1 ;; esac; }

want() { [ "$WANT" = all ] || [ "$WANT" = "$1" ]; }

# Известные ветви (диспетчер fail-closed — неизвестное имя НЕ зеленеет молча).
KNOWN_BRANCHES="а б в г д е ж з и к л"
if [ "$WANT" != all ]; then
  found=0
  for k in $KNOWN_BRANCHES; do [ "$WANT" = "$k" ] && found=1; done
  [ "$found" -eq 1 ] || { printf 'ОТКАЗ диспетчер: неизвестная ветвь «%s» (допустимы: %s)\n' \
                                   "$WANT" "$KNOWN_BRANCHES" >&2; exit 1; }
fi

# ── ветви ──────────────────────────────────────────────────────────────────────
if want а; then
  R="$WORK/а"; build_repo "$R"
  run_sel "$R" --scope zzz
  [ "$RC" = 1 ] || die а "неизвестный ключ zzz принят кодом $RC — селектор обязан отвергнуть кодом 1"
  has zzz "$ERR$OUT" || die а "отказ по неизвестному ключу не назвал ключ zzz"
  printf '  ok   (а) неизвестный ключ отвергнут\n' >&2
fi

if want б; then
  R="$WORK/б"; build_repo "$R"
  run_sel "$R" --scope
  [ "$RC" = 1 ] || die б "пустой --scope принят кодом $RC — обязан отвергнуть кодом 1"
  printf '  ok   (б) пустой --scope отвергнут\n' >&2
fi

if want в; then
  R="$WORK/в"; build_repo "$R"
  run_sel "$R" --scope a/case_zzz
  [ "$RC" = 1 ] || die в "неизвестный case a/case_zzz принят кодом $RC — обязан отвергнуть кодом 1"
  has case "$ERR$OUT" || die в "отказ по неизвестному case не назвал case"
  printf '  ok   (в) неизвестный case отвергнут\n' >&2
fi

if want г; then
  R="$WORK/г"; build_repo "$R"
  printf 'ещё документация\n' >> "$R/README.md"; gg "$R" add -A; gg "$R" commit -q -m docs
  run_sel "$R" --changed "$BASE"
  [ "$RC" = 2 ] || die г "дифф только по докам дал код $RC, ожидался 2 (needs-full: нечем проверить)"
  has needs-full "$OUT" || die г "режим не needs-full при пустой выборке"
  has "0 задет" "$ERR$OUT" || die г "не названо «0 задетых» при пустой выборке"
  has SCOPED: "$ERR" || die г "needs-full не напечатал машинный маркер «SCOPED:» на stderr — отличим только от scoped по MODE"
  printf '  ok   (г) доки-only → needs-full код 2, маркер SCOPED:\n' >&2
fi

if want д; then
  R="$WORK/д"; build_repo "$R"
  run_sel "$R" --changed 0000000000000000000000000000000000000000
  [ "$RC" = 2 ] || die д "нерезолвимая база дала код $RC, ожидался 2 (fail-closed), НЕ 0-успех"
  NG="$WORK/д_notgit"; mkdir -p "$NG/scripts"
  run_sel "$NG" --changed HEAD
  [ "$RC" = 2 ] || die д "не-git дерево дало код $RC, ожидался 2 (fail-closed)"
  printf '  ok   (д) нерезолвимая база и не-git дерево → 2\n' >&2
fi

if want е; then
  R="$WORK/е"; build_repo "$R"
  printf '# правка\n' >> "$R/scripts/b.sh"; gg "$R" add -A; gg "$R" commit -q -m 'правка b'
  run_sel "$R" --changed "$BASE"
  [ "$RC" = 0 ] || die е "правка барьера b дала код $RC, ожидался 0 (scoped)"
  has "MODE: scoped" "$OUT" || die е "режим не scoped при правке одного барьера"
  has "KEY: b" "$OUT" || die е "барьер b не выбран при его правке"
  has "KEY: a" "$OUT" && die е "барьер a выбран, хотя не задет — выборка не сужена"
  printf '  ok   (е) правка b → scoped, ровно ключ b\n' >&2
fi

if want ж; then
  R="$WORK/ж"; build_repo "$R"
  printf 'lim2() { echo 20; }\n' >> "$R/scripts/lib_x.sh"; gg "$R" add -A; gg "$R" commit -q -m 'правка lib'
  run_sel "$R" --changed "$BASE"
  [ "$RC" = 0 ] || die ж "правка библиотеки дала код $RC, ожидался 0 (full)"
  has "MODE: full" "$OUT" || die ж "правка библиотеки не дала полную выборку — недобор задетых барьеров"
  printf '  ok   (ж) правка библиотеки → full\n' >&2
fi

if want з; then
  for kind in add delete rename role; do
    R="$WORK/з_$kind"; build_repo "$R"
    case "$kind" in
      add)    printf '#!/usr/bin/env bash\n# Коды возврата: 0 — ок\nexit 0\n' > "$R/scripts/c.sh" ;;
      delete) rm "$R/scripts/a.sh" ;;
      rename) mv "$R/scripts/a.sh" "$R/scripts/aa.sh" ;;
      role)   printf '#!/usr/bin/env bash\n# НЕ БАРЬЕР: был барьером\nexit 0\n' > "$R/scripts/a.sh" ;;
    esac
    gg "$R" add -A; gg "$R" commit -q -m "$kind"
    run_sel "$R" --changed "$BASE"
    { [ "$RC" = 0 ] && has "MODE: full" "$OUT"; } || [ "$RC" = 2 ] \
      || die з "$kind дал код $RC / режим не full — A/D/R/смена-роли обязаны вести к полной выборке"
  done
  printf '  ok   (з) add/delete/rename/смена-роли → full\n' >&2
fi

if want и; then
  R="$WORK/и"; build_repo "$R"
  run_sel "$R" --scope a/case_bad
  [ "$RC" = 0 ] || die и "case-уровень a/case_bad дал код $RC, ожидался 0"
  has "KEY: a/case_bad" "$OUT" || die и "case-уровень не выбрал ровно a/case_bad"
  printf '  ok   (и) case-уровень выбирает ровно свой case\n' >&2
fi

if want к; then
  R="$WORK/к"; build_repo "$R"
  printf '# правка\n' >> "$R/scripts/b.sh"; gg "$R" add -A; gg "$R" commit -q -m 'правка b'
  run_sel "$R" --changed "$BASE"
  has "SCOPED:" "$ERR$OUT" || die к "scoped-режим не напечатал маркер «SCOPED:» — неотличим от полного"
  has "MODE: scoped" "$OUT" || die к "нет машинного маркера «MODE: scoped» на stdout"
  # Та же проверка на needs-full: маркер ОБЯЗАН быть и там (контракт §Предмет, шапка барьера).
  # Используем ОТДЕЛЬНЫЙ свежий репо, чтобы HEAD имел только docs-изменения над BASE.
  R2="$WORK/к_nf"; build_repo "$R2"
  printf '# ещё документации\n' >> "$R2/README.md"; gg "$R2" add -A; gg "$R2" commit -q -m docs
  run_sel "$R2" --changed "$BASE"
  [ "$RC" = 2 ] || die к "docs-only не дал needs-full код 2 — теряется сценарий (г)"
  has needs-full "$OUT" || die к "режим не needs-full на docs-only"
  has SCOPED: "$ERR" || die к "needs-full не напечатал машинный маркер «SCOPED:» — отличим от полного НЕ по маркеру"
  printf '  ok   (к) scoped и needs-full помечены SCOPED: (неавторитетность — у потребителя)\n' >&2
# (л) — git-отсутствие: игрушку строим при доступном git (для setup), а ВЫЗОВ селектора делаем
# с PATH, где `git` НЕ виден → код 2 (fail-closed). Сузить claim «нет git → 2» (было спрятано за
# `command -v git || skip`) было бы сменой предмета контракта — на это имеет право только
# владелец; исполняемый тест против подмены PATH дешевле.
fi

if want л; then
  R="$WORK/л"; build_repo "$R"
  NOGIT="$WORK/nogit"; mkdir -p "$NOGIT"
  for b in /usr/bin/*; do case "$(basename "$b")" in git) ;; *) ln -s "$b" "$NOGIT/$(basename "$b")" 2>/dev/null || true ;; esac; done
  [ ! -e "$NOGIT/git" ] || die л "симлинк git не удалён из PATH-каталога — fail-closed не проверен"
  ORIG_PATH="$PATH"
  PATH="$NOGIT" run_sel "$R" --changed "$BASE"
  PATH="$ORIG_PATH"
  [ "$RC" = 2 ] || die л "PATH без git дал код $RC, ожидался 2 (fail-closed) — предмет контракта §3 подменой PATH не доказан"
  has SCOPED: "$ERR" || die л "needs-full при отсутствии git не напечатал SCOPED: (как и в ветви (г))"
  printf '  ok   (л) git-отсутствие (PATH без git) → код 2 + SCOPED:\n' >&2
fi

printf 'check_scope_select: ветви «%s» зелены\n' "$WANT" >&2
exit 0
