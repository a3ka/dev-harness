# Профиль батареи гигиены парсинга для scripts/ci_klass.sh (контракт 087, норма 041 —
# новый гард чужого ввода: строки uchet реестра registry/ci-steps.tsv, пути дерева из
# git ls-tree, JSON артефактов GitHub API). Живое предъявление — строка Ж1 контракта 087:
#   bash fixtures/parsing_hygiene_battery/run_battery.sh ci_klass   → rc 0
# (после реализации; ДО реализации — 4 класса пробиты: субъекта нет).
#
# Реюз, не переизобретение: toy-мир, поддельный curl и оракул — каркас семьи
# fixtures/ci_b_087/_toy.sh (t87_setup, t87_art/t87_arts, t87_h).
KL_REPO="$(cd "$HERE/../.." && pwd -P)"
KL_SUBJ="$KL_REPO/scripts/ci_klass.sh"
# shellcheck disable=SC1091
. "$KL_REPO/fixtures/ci_b_087/_toy.sh"
KL_T=''
KL_API='https://api.github.test/repos/toy/repo'

_kl_world() {  # мир строится один раз на прогон профиля
  [ -n "$KL_T" ] && return 0
  KL_T="$(mktemp -d "${TMPDIR:-/tmp}/battery_ci_klass.XXXXXX")" || return 1
  trap 'rm -rf "$KL_T"' EXIT
  t87_setup "$KL_T" || { printf 'мир не построен\n' >&2; return 1; }
}
_kl() {  # <cwd> <аргументы…> → KL_OUT, KL_RC
  local cwd="$1"
  shift
  if [ ! -f "$KL_SUBJ" ]; then KL_OUT="предмет отсутствует: scripts/ci_klass.sh"; KL_RC=127; return; fi
  KL_OUT="$(cd "$cwd" && PATH="$T87_BIN:$PATH" CI_KLASS_API="$KL_API" bash "$KL_SUBJ" "$@" 2>&1)"; KL_RC=$?
}
_kl_klass() {  # <база> <вариант> <ожид-класс> <метка>
  _kl "$T87_W" klass "$1" "$2"
  [ "$KL_RC" -eq 0 ] && [ "$KL_OUT" = "$3" ] && return 0
  printf '%s: klass rc %s, «%s» ≠ %s\n' "$4" "$KL_RC" "$KL_OUT" "$3" >&2
  return 1
}

battery_delimiter_collision() {
  # Байты-разделители соседних слоёв ВНУТРИ значений: TAB — разделитель полей ls-tree и
  # реестра — внутри учётного пути «verdicts/a<TAB>b.md» (правка обязана остаться учётной);
  # перевод строки — разделитель записей текстового ls-tree — внутри КОДОВОГО пути
  # «scripts/p<LF>verdicts/q.sh», чей хвост похож на учётный путь (правка обязана быть кодом).
  _kl_world || return 1
  _kl_klass "$T87_C0" "$T87_U_tab" uchet 'TAB в учётном пути' || return 1
  _kl_klass "$T87_C0" "$T87_K_nl" kod 'LF в кодовом пути с учётным хвостом' || return 1
  return 0
}

battery_regex_injection() {
  # «.» значения uchet — литерал: «HANDOFF.md» не матчит код «HANDOFFxmd»; граница каталога
  # — «/»: «docs/» не матчит код «docsx/a.sh»; имя артефакта сверяется литерально: имя
  # «tyazhelyj-<H>x» при законном head_sha доказательством не является.
  _kl_world || return 1
  _kl_klass "$T87_C0" "$T87_K_handoffx" kod '«.» как любой символ' || return 1
  _kl_klass "$T87_C0" "$T87_K_docsx" kod 'префикс каталога без «/»' || return 1
  t87_fake_reset
  t87_arts "$(t87_art "$T87_ART$(t87_h "$T87_Q")x" "$T87_Q")"
  _kl "$T87_W" dokaz "$T87_Q"
  if [ "$KL_RC" -ne 1 ]; then
    printf 'имя артефакта с суффиксом принято: rc %s, %s\n' "$KL_RC" "$KL_OUT" >&2
    return 1
  fi
  return 0
}

battery_silent_drop() {
  # (а) Последняя строка uchet реестра БЕЗ перевода строки (forks/) — цикл, теряющий
  # хвост без LF, делает forks/ кодом: правка forks/ обязана остаться учётной.
  # (б) Законное доказательство — ПОСЛЕДНИМ в списке артефактов после трёх негодных:
  # разбор, судящий только первый элемент, молча теряет его.
  _kl_world || return 1
  _kl_klass "$T87_SD0" "$T87_SD1" uchet 'последняя строка uchet без LF' || return 1
  t87_fake_reset
  t87_arts "$(t87_art "$T87_ART$(t87_h "$T87_Q")x" "$T87_Q")" \
           "$(t87_art "$T87_ART$(t87_h "$T87_Q")" "$T87_Q" true)" \
           "$(t87_art "$T87_ART$(t87_h "$T87_Q")" "$T87_P")" \
           "$(t87_art "$T87_ART$(t87_h "$T87_Q")" "$T87_Q")"
  _kl "$T87_W" dokaz "$T87_Q"
  if [ "$KL_RC" -ne 0 ] || [ "$KL_OUT" != "dokaz $T87_Q" ]; then
    printf 'доказательство последним потеряно: rc %s, %s\n' "$KL_RC" "$KL_OUT" >&2
    return 1
  fi
  return 0
}

battery_self_application_green() {
  # Субъект на СВОЁМ дереве: hash HEAD — 64 hex, klass HEAD HEAD — uchet; strip своим
  # хешем на клоне живого репо — rc 0 (реестр живого дерева в грамматике И-1).
  local h c
  _kl "$KL_REPO" hash HEAD
  if [ "$KL_RC" -ne 0 ] || ! [[ "$KL_OUT" =~ ^[0-9a-f]{64}$ ]]; then
    printf 'hash HEAD живого дерева: rc %s, %s\n' "$KL_RC" "$KL_OUT" >&2
    return 1
  fi
  h="$KL_OUT"
  _kl "$KL_REPO" klass HEAD HEAD
  [ "$KL_RC" -eq 0 ] && [ "$KL_OUT" = uchet ] || { printf 'klass HEAD HEAD: rc %s, %s\n' "$KL_RC" "$KL_OUT" >&2; return 1; }
  _kl_world || return 1
  c="$KL_T/self"
  t87_git clone -q "$KL_REPO" "$c" || { printf 'клон живого репо не построен\n' >&2; return 1; }
  cp "$KL_SUBJ" "$c/scripts/ci_klass.sh.self"
  KL_OUT="$(cd "$c" && bash scripts/ci_klass.sh.self strip "$h" 2>&1)"; KL_RC=$?
  [ "$KL_RC" -eq 0 ] || { printf 'strip своим хешем на клоне: rc %s, %s\n' "$KL_RC" "$KL_OUT" >&2; return 1; }
  return 0
}
