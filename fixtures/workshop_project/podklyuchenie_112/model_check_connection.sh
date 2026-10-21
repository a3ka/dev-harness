#!/usr/bin/env bash
# МОДЕЛЬ-ЭТАЛОН scripts/check_project_connection.sh (контракт 112).
# Эталон шва для красной батареи red_podkljuchenie_112.sh --model: показывает,
# как выглядит честная проверка подключения. Реализацию в scripts/ пишет
# implementer по контракту; модель НЕ продукт и не заменяет его.
#
# Алфавит причин — ЕДИНЫЙ с будущим продуктом (батарея несёт его побайтово):
#   profil / workflowPaths / kanon-remote / komandy / source-canon
# Грамматика профиля — ТОЛЬКО действующий profile_resolver.sh (996: второй
# валидатор сырого профиля запрещён); модель читает его эффективный вывод.
# Сравнение remote — буквальное равенство целых строк БАЙТ-В-БАЙТ (037;
# круг 4: хвостовые LF/NUL не срезаются оболочкой).
# Пороговые правила: 0 — подключение структурно цело; 1 — ≥1 именованный
# отказ; 2 — неправильный вызов.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TOOLS="$(cd "$HERE/../../.." && pwd -P)"

REPO=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:-}"; shift 2 ;;
    --repo=*) REPO="${1#--repo=}"; shift ;;
    *) printf 'model: неизвестный аргумент: %s\n' "$1" >&2; exit 2 ;;
  esac
done
[ -n "$REPO" ] && [ -d "$REPO" ] || { printf 'model: нет --repo <каталог>\n' >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { printf 'model: нет jq\n' >&2; exit 2; }
R="$(cd "$REPO" && pwd -P)"

itog=0
fail() { printf 'ОТКАЗ: подключение: %s: %s\n' "$1" "$2" >&2; itog=1; }

# ── profil: грамматика и слой — действующий резолвер ────────────────────────
export HARNESS_PROJECT_LAYER_ROOT="${HARNESS_PROJECT_LAYER_ROOT:-$R}"
if ! OUT="$(bash "$TOOLS/scripts/profile_resolver.sh" --repo "$R" 2>&1)"; then
  printf 'ОТКАЗ: подключение: profil: %s\n' "$(printf '%s' "$OUT" | head -1)" >&2
  exit 1
fi

# ── workflowPaths (+ state): внутрь репо, каталог, без симлинк-побега ───────
# Круг 4 (A2 судьи круга 3): значения НЕ проходят через command substitution —
# она срезает хвостовые LF и выбрасывает NUL; байты значения пишутся jq -j в
# файл и проверяются на управляющие байты ДО всякого использования: NUL/LF/
# CR/TAB в имени пути невозможны в файловой системе, «принятое» с ними
# значение жило бы только в усечённой оболочкой копии.
CHISTYJ_112="$(mktemp "${TMPDIR:-/tmp}/model112-znachenie-XXXXXX")" || exit 9
upravljajushhij_bajt() {  # $1 файл → 0, если в его байтах есть NUL/LF/CR/TAB
  ! LC_ALL=C tr -d '\000\012\015\011' < "$1" | cmp -s - "$1"
}
for k in contracts verdicts registry fixtures; do
  printf '%s' "$OUT" | jq -j --arg k "$k" '.workflowPaths[$k].value // empty' > "$CHISTYJ_112"
  if upravljajushhij_bajt "$CHISTYJ_112"; then
    fail workflowPaths "workflowPaths.$k несёт управляющий байт (NUL/LF/CR/TAB)"; continue
  fi
  v="$(cat "$CHISTYJ_112")"
  [ -n "$v" ] || { fail workflowPaths "workflowPaths.$k отсутствует в эффективном профиле"; continue; }
  case "$v" in /*) fail workflowPaths "workflowPaths.$k абсолютный: $v"; continue ;; esac
  p="$R/$v"
  [ -d "$p" ] || { fail workflowPaths "workflowPaths.$k не каталог: $v"; continue; }
  real="$(cd "$p" && pwd -P)"
  case "$real" in "$R"|"$R"/*) ;; *) fail workflowPaths "workflowPaths.$k канонически вне репо: $v" ;; esac
done
# STATE-112-BEG: state проверяется НЕЗАВИСИМО workflow-каталогов и файла слоя
# (батарея 112 вырезает этот блок по sentinels в state-слепую контрмодель —
# правило 3: клетки D14-state-vne-repo и D16-state-symlink-zveno обязаны быть
# красными против неё).
printf '%s' "$OUT" | jq -j '.workflowPaths.state.value // ".harness"' > "$CHISTYJ_112"
if upravljajushhij_bajt "$CHISTYJ_112"; then
  fail workflowPaths "state несёт управляющий байт (NUL/LF/CR/TAB)"
else
  v="$(cat "$CHISTYJ_112")"
  case "$v" in /*) fail workflowPaths "state абсолютный: $v" ;; *)
    p="$R/$v"; [ -d "$p" ] || fail workflowPaths "state не каталог: $v"
    real="$(cd "$p" 2>/dev/null && pwd -P || printf '%s' "$p")"
    case "$real" in "$R"|"$R"/*) ;; *) fail workflowPaths "state канонически вне репо: $v" ;; esac ;; esac
fi
# STATE-112-END

# ── kanon-remote: канон профиля = буквальный origin клона, БАЙТ-В-БАЙТ ──────
# Круг 4 (A2 ревьюера / блокер адверсария): сравнение через command
# substitution невозможно — `$(jq -r …)` срезает хвостовые LF и выбрасывает
# NUL; байты канона (jq -j, без суффикса) и байты `git remote get-url origin`
# (git печатает значение + РОВНО ОДИН собственный завершающий LF — он и
# только он срезается) пишутся в файлы и сравниваются cmp-ом: хвостовой \n,
# \n\n, NUL в каноне = отказ kanon-remote.
kanon_f="$(mktemp "${TMPDIR:-/tmp}/model112-kanon-XXXXXX")" || exit 9
orig_f="$(mktemp "${TMPDIR:-/tmp}/model112-orig-XXXXXX")" || exit 9
printf '%s' "$OUT" | jq -j '.git.value.canonicalRemote // empty' > "$kanon_f"
if ! git -C "$R" remote get-url origin > "$orig_f" 2>/dev/null; then : > "$orig_f"; fi
if [ "$(wc -c < "$orig_f")" -gt 0 ] && [ "$(tail -c1 "$orig_f" | od -An -tu1 | tr -dc '0-9')" = 10 ]; then
  head -c $(( $(wc -c < "$orig_f") - 1 )) "$orig_f" > "${orig_f}.n"
else
  cp "$orig_f" "${orig_f}.n"
fi
[ -s "$kanon_f" ] || fail kanon-remote "канон профиля пуст или отсутствует"
[ -s "${orig_f}.n" ] || fail kanon-remote "у клона нет origin (get-url пуст)"
cmp -s "$kanon_f" "${orig_f}.n" || fail kanon-remote \
  "канон профиля ≠ origin клона (байт-в-байт): $(wc -c < "$kanon_f") байт против $(wc -c < "${orig_f}.n")"
rm -f "$kanon_f" "$orig_f" "${orig_f}.n"

# KOMANDY-112-BEG: komandy — непустые, не `true`, реальны в дереве, форма
# ЗАКРЫТА (v3 — судьи круга 1: F1/F2/F3; круг 4 — B1/A3 судей круга 3).
# Путь файла и значение --prefix — ТОЛЬКО относительные и канонизируются
# ВНУТРЬ $R (абсолютный путь и `..`-побег = отказ); ЛИСТ файла/package.json
# и звенья пути разрешаются readlink -f (листовой symlink наружу = отказ,
# A3). КАЖДЫЙ токен команды — целиком из белого набора
# [A-Za-z0-9._/@:=+,-]: кавычки, `\`, {,}, ~, *, ?, [, ], !, #, %, ^,
# управляющие байты и NUL = отказ ДО канонизации (B1: раскрытие оболочки
# меняет исполняемый путь относительно проверенного литерала); хвост после
# `run <s>`/`test` = отказ; голое имя без `run` = отказ. Честные литералы CI
# принимаются: `node|python3 <файл> [аргументы]` (например `node
# backend/scripts/gen-contracts.js --check`) и `npm [--prefix D] run <s>|
# `test` (включая `npm --prefix backend run smoke:image` и `npm --prefix
# mobile run typecheck|lint|test`). Батарея 112 вырезает этот блок по
# sentinels в komandy-слепую контрмодель — правило 3: все клетки
# `D<NN>-komanda-*` (D34–D59, круги 3–4) обязаны быть красными против неё.
npm_script_ok() {  # $1 = package.json, $2 = имя скрипта
  jq -e --arg s "$2" '.scripts[$s] != null' "$1" >/dev/null 2>&1
}
op_obolochki() {  # $1 токен → 0 (=нарушение формы), если токен НЕ целиком из
  # белого набора [A-Za-z0-9._/@:=+,-] (круг 4, B1: прежний чёрный список
  # операторов пропускал кавычки/`\\`/{,}/~/глоб — shell менял исполняемый
  # путь относительно проверенного литерала; отказ — ДО канонизации).
  case "$1" in
    *[!A-Za-z0-9._/@:=+,-]*|'') return 0 ;;
    *) return 1 ;;
  esac
}
for k in test build typecheck lint; do
  v="$(printf '%s' "$OUT" | jq -r --arg k "$k" '.commands[$k].value // empty')"
  if [ -z "$v" ] || [ "$v" = "true" ]; then fail komandy "commands.$k пустая или замаскирована true"; continue; fi
  set -f
  # shellcheck disable=SC2206
  toks=($v)
  set +f
  forma="ok"
  for t in "${toks[@]}"; do
    op_obolochki "$t" && forma="operator"
  done
  if [ "$forma" = "operator" ]; then fail komandy "commands.$k: токен вне белого набора [A-Za-z0-9._/@:=+,-]: $v"; continue; fi
  case "${toks[0]}" in
    node|python3)
      f="${toks[1]-}"
      if [ -z "$f" ]; then fail komandy "commands.$k: нет файла после ${toks[0]}"; continue; fi
      case "$f" in
        /*) fail komandy "commands.$k: путь файла абсолютный: $f"; continue ;;
      esac
      fp="$(cd "$R/$(dirname "$f")" 2>/dev/null && pwd -P)"
      [ -n "$fp" ] || { fail komandy "commands.$k: каталог файла не читается: $f"; continue; }
      case "$fp" in "$R"|"$R"/*) ;; *) fail komandy "commands.$k: файл канонически вне дерева: $f"; continue ;; esac
      # круг 4 (A3): ЛИСТ тоже канонизируется — листовой symlink наружу
      # (`-f` молча следует ссылке) = отказ
      real="$(readlink -f -- "$fp/$(basename "$f")" 2>/dev/null || true)"
      case "$real" in
        "$R"|"$R"/*) [ -n "$real" ] && [ -f "$real" ] || fail komandy "commands.$k: файла нет в дереве: $f" ;;
        *) fail komandy "commands.$k: файл канонически вне дерева (лист-symlink): $f" ;;
      esac
      continue ;;
    npm) ;;
    *) fail komandy "commands.$k вне известных семейств (npm/node/python3): $v"; continue ;;
  esac
  dir="$R"; i=0
  if [ "${toks[$((i+1))]-}" = "--prefix" ]; then
    d="${toks[$((i+2))]-}"
    if [ -z "$d" ]; then fail komandy "commands.$k: --prefix без значения: $v"; continue; fi
    case "$d" in
      /*) fail komandy "commands.$k: --prefix абсолютный: $d"; continue ;;
    esac
    dir="$(cd "$R/$d" 2>/dev/null && pwd -P)"
    if [ -z "$dir" ]; then fail komandy "commands.$k: каталог --prefix не читается: $d"; continue; fi
    case "$dir" in "$R"|"$R"/*) ;; *) fail komandy "commands.$k: --prefix канонически вне дерева: $d"; continue ;; esac
    i=2
  fi
  cur="${toks[$((i+1))]-}"
  case "$cur" in
    run)
      script="${toks[$((i+2))]-}"
      if [ -z "$script" ]; then fail komandy "commands.$k: run без имени скрипта: $v"; continue; fi
      if [ $((i+3)) -lt ${#toks[@]} ]; then fail komandy "commands.$k: хвост после 'run <скрипт>' — форма не закрыта: $v"; continue; fi ;;
    test)
      script="test"
      if [ $((i+2)) -lt ${#toks[@]} ]; then fail komandy "commands.$k: хвост после 'test' — форма не закрыта: $v"; continue; fi ;;
    *) fail komandy "commands.$k: npm вне закрытой формы 'run <скрипт>'|'test': $v"; continue ;;
  esac
  pj="$dir/package.json"
  # круг 4 (A3): ЛИСТ package.json канонизируется — листовой symlink наружу
  # = отказ (`-f` один следует ссылке и молчит)
  real="$(readlink -f -- "$pj" 2>/dev/null || true)"
  case "$real" in
    "$R"|"$R"/*) [ -f "$real" ] || { fail komandy "commands.$k: нет $pj"; continue; } ;;
    *) fail komandy "commands.$k: package.json канонически вне дерева (лист-symlink)"; continue ;;
  esac
  npm_script_ok "$pj" "$script" || fail komandy "commands.$k: скрипта '$script' нет в ${pj#"$R"/}"
done
# KOMANDY-112-END

# ── source-canon: объявленные источники существуют (грамматика — резолвер) ──
# Круг 4 (A2/A3/A8): байты пути — jq -j в файл (без срезания LF/NUL);
# канонизация ВСЕГО пути readlink -f закрывает и листовой, и звенный symlink
# наружу (симметрия модель/продукт, A8).
n="$(printf '%s' "$OUT" | jq -r '.sourceCanon.value.sources // empty | length')"
[ "$n" = "0" ] || [ -z "$n" ] || for idx in $(seq 0 $((n-1))); do
  printf '%s' "$OUT" | jq -j ".sourceCanon.value.sources[$idx].path" > "$CHISTYJ_112"
  if upravljajushhij_bajt "$CHISTYJ_112"; then
    fail source-canon "источник несёт управляющий байт (NUL/LF/CR/TAB)"; continue
  fi
  sp="$(cat "$CHISTYJ_112")"
  case "$sp" in /*) fail source-canon "источник абсолютный: $sp" ;; *)
    real="$(readlink -f -- "$R/$sp" 2>/dev/null || true)"
    case "$real" in
      "$R"|"$R"/*) [ -n "$real" ] && [ -f "$real" ] || fail source-canon "источник отсутствует: $sp" ;;
      *) fail source-canon "источник канонически вне репо: $sp" ;;
    esac ;;
  esac
done

rm -f "$CHISTYJ_112"
exit "$itog"
