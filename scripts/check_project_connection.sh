#!/usr/bin/env bash
# scripts/check_project_connection.sh — структурная проверка подключения
# репозитория к режиму проекта 996 (контракт 112).
#
# CLI: --repo <каталог>
#   (допустимы оба: --repo PATH и --repo=PATH).
#
# Алфавит причин (ЕДИН с батареей red_podkljuchenie_112.sh — носитель байтов
# ожиданий — батарея, контракт не дублирует; каждая причина — отдельная
# строка вида `ОТКАЗ: подключение: <имя>: <деталь>`):
#
#   profil         — резолвер не принял профиль/слой; или алфавит/обязательные
#                    ключи не сошлись (язык вне {rust,typescript,bash,javascript};
#                    schemaVersion≠1; repoId/canonicalRemote/ci.workflow/etc.
#                    пусты; пины слоя расходятся; sourceCanon неверного типа)
#   workflowPaths  — workflowPaths.<key> отсутствует / абсолютный / не каталог /
#                    реально канонизируется вне корня клона (включая state)
#   kanon-remote   — git.canonicalRemote ≠ буквальному `git remote get-url origin`
#                    (сравнение ЦЕЛЫХ строк байт-в-байт, норма-класс 037)
#   komandy        — commands.<k> пуст, равен `true`, имеет оператор/подстановку
#                    оболочки в любом токене, или ссылается на путь, которого
#                    нет в дереве репо (npm-скрипт не зарегистрирован,
#                    node/python3-файл отсутствует); также форма вне семейств
#                    {npm,node,python3} или не закрыта (ровно один --prefix,
#                    run <s>|test без хвоста)
#   source-canon   — объявленный в sourceCanon.sources[].path отсутствует /
#                    абсолютный (анти-плацебо: явная проверка существования —
#                    не дубль по дереву от workflowPaths)
#
# Грамматика профиля — ТОЛЬКО действующий profile_resolver.sh (996, норма
# «второй валидатор запрещён»). Этот скрипт читает результат резолвера и
# судит структурные свойства эффективного профиля + состояние дерева клона.
#
# Коды возврата:
#   0 — подключение структурно цело (все 4 шва зелёные; могут быть как
#       честные 0 причин, так и 0 причин при логически-пустых секциях);
#   1 — есть ≥1 именованный отказ (каждый — отдельная строка stderr; rc
#       НЕ «первый-стоп» — все 4 шва прогоняются целиком);
#   2 — неправильный вызов (нет --repo, нет jq, нет каталога, неизвестный
#       аргумент).
#
# Семантика komandy НЕ СЛАБЕЕ эталонной модели (контракт 112 §Конструкция;
# вердикты судей кругов 1–2 «реализация должна быть не слабее модели»):
#   • глобальная проверка операторов/подстановок оболочки В КАЖДОМ токене
#     ДО семейство-специфичной логики (| & ; ( ) < > ` $); ловит и `|| true`,
#     и `| cat`, и метасимвол в имени файла/--prefix/script;
#   • ровно один опциональный --prefix; повторный --prefix = форма не закрыта;
#   • путь файла и --prefix ТОЛЬКО относительные и канонизируются ВНУТРЬ $R
#     через `cd && pwd -P` (полная канонизация каталога; для файлов —
#     канонизация родителя); абсолютный/..-побег/листовой-symlink-наружу = отказ;
#   • форма npm закрыта: `npm [--prefix D] run <s>|test`; хвост = отказ;
#     голое имя без `run` = отказ.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TOOLS="$(cd "$HERE/.." && pwd -P)"

REPO=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:-}"; shift 2 ;;
    --repo=*) REPO="${1#--repo=}"; shift ;;
    *) printf 'check_project_connection: неизвестный аргумент: %s\n' >&2; exit 2 ;;
  esac
done
[ -n "$REPO" ] && [ -d "$REPO" ] || { printf 'check_project_connection: нет --repo <каталог>\n' >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { printf 'check_project_connection: нет jq\n' >&2; exit 2; }
R="$(cd "$REPO" && pwd -P)"

itog=0
fail() { printf 'ОТКАЗ: подключение: %s: %s\n' "$1" "$2" >&2; itog=1; }

# ── profil: грамматика, слой, пин, обязательные ключи — действующий резолвер ─
export HARNESS_PROJECT_LAYER_ROOT="${HARNESS_PROJECT_LAYER_ROOT:-$R}"
if ! OUT="$(bash "$TOOLS/scripts/profile_resolver.sh" --repo "$R" 2>&1)"; then
  printf 'ОТКАЗ: подключение: profil: %s\n' "$(printf '%s' "$OUT" | head -1)" >&2
  exit 1
fi

# Дополнительные структурные проверки (после того как резолвер принял
# грамматику): пустота ключей git/ci/прочих обязательных полей.
# Резолвер тоже это проверяет (см. profile_resolver.sh check_object_strings
# и И-4), но здесь — явный gate с тем же алфавитом причин, чтобы причина
# `profil` была именованной, даже если резолвер не пробил строгий gate
# (страховка от дрейфа шва 996).
for k in git.value.canonicalRemote ci.value.workflow repoId.value language.value projectLayer.value.profilePath; do
  v="$(printf '%s' "$OUT" | jq -r --arg p "$k" 'getpath($p | split(".")) // empty')"
  [ -n "$v" ] || fail profil "резолвер принял, но отсутствует: $k"
done

# ── canon_R: ЕДИНЫЙ хелпер канонизации «внутрь $R» (совет 050 A7)
#   $1=raw $2=label $3=kind( dir | file ) $4=reason
# Семантика — НЕ СЛАБЕЕ модели:
#   • каталог: cd "$R/$raw" && pwd -P (полная канонизация; симлинк-ЛИСТ наружу
#     и `..`-побег = отказ);
#   • файл: cd "dirname $R/$raw" && pwd -P (родитель целиком) + basename;
#   • абсолютный — ВСЕГДА отказ; пишет причину $4 + деталь;
#   • успех: REAL=канон_путь, return 0; ошибка: fail $4 + return 1.
canon_R() {  # $1=raw $2=label $3=kind $4=reason; sets REAL
  local raw="$1" label="$2" kind="$3" reason="$4" target parent dir_real base
  if [ -z "$raw" ]; then fail "$reason" "$label: пустой путь"; return 1; fi
  case "$raw" in
    /*) fail "$reason" "$label абсолютный: $raw"; return 1 ;;
    *) target="$R/$raw" ;;
  esac
  if [ "$kind" = "dir" ] || [ -d "$target" ]; then
    if [ ! -d "$target" ]; then fail "$reason" "$label: не каталог: $raw"; return 1; fi
    dir_real="$(cd "$target" 2>/dev/null && pwd -P || true)"
    [ -n "$dir_real" ] || { fail "$reason" "$label: канонизация не удалась: $raw"; return 1; }
    case "$dir_real" in
      "$R"|"$R"/*) REAL="$dir_real"; return 0 ;;
      *) fail "$reason" "$label канонически вне репо: $raw → $dir_real"; return 1 ;;
    esac
  fi
  parent="$(dirname -- "$target")"
  base="$(basename -- "$target")"
  if [ ! -e "$target" ]; then fail "$reason" "$label: файла нет в дереве: $raw"; return 1; fi
  dir_real="$(cd "$parent" 2>/dev/null && pwd -P || true)"
  [ -n "$dir_real" ] || { fail "$reason" "$label: канонизация родителя не удалась: $raw"; return 1; }
  case "$dir_real" in
    "$R"|"$R"/*) REAL="$dir_real/$base"; return 0 ;;
    *) fail "$reason" "$label канонически вне репо: $raw → $dir_real/$base"; return 1 ;;
  esac
}

# ── workflowPaths.*: 4 ключа + канонизация каталога внутрь $R ──────────────
for k in contracts verdicts registry fixtures; do
  v="$(printf '%s' "$OUT" | jq -r --arg k "$k" ".workflowPaths.$k.value // empty")"
  [ -n "$v" ] || { fail workflowPaths "workflowPaths.$k отсутствует в эффективном профиле"; continue; }
  canon_R "$v" "workflowPaths.$k" "dir" workflowPaths || true
done

# ── state: независимая секция (НЕ вырезаемая как контрмодель; анти-плацебо)
# state читается из эффективного профиля, по умолчанию = ".harness" (на
# случай, когда профиль опускает ключ — резолвер может не вернуть).
v="$(printf '%s' "$OUT" | jq -r '.workflowPaths.state.value // ".harness"')"
canon_R "$v" "workflowPaths.state" "dir" workflowPaths || true

# ── kanon-remote: целые строки байт-в-байт ─────────────────────────────────
canon="$(printf '%s' "$OUT" | jq -r '.git.value.canonicalRemote // empty')"
orig="$(git -C "$R" remote get-url origin 2>/dev/null || true)"
if [ -z "$canon" ] || [ -z "$orig" ]; then
  fail kanon-remote "канон или origin пуст: канон='${canon:-<пусто>}' origin='${orig:-<пусто>}'"
elif [ "$canon" != "$orig" ]; then
  fail kanon-remote "канон профиля ≠ origin клона: '${canon}' ≠ '${orig}'"
fi

# ── komandy: глобальная проверка операторов оболочки В КАЖДОМ токене ─────────
# Модель (model_check_connection.sh, KOMANDY-112-BEG/END) делает ту же
# проверку ДО семейство-специфичной логики: токен содержит оператор/подстановку
# оболочки (`| & ; ( ) < > ` $) — отказ по форме, до канонизации путей.
# Здесь — единая семантика: операторы в любом токене = komandy-отказ; форма
# npm/node|python3 проверяется семейство-специфичной логикой ниже.
op_obolochki() {  # $1 токен → 0 если найден оператор/подстановка
  case "$1" in
    *'|'*|*'&'*|*';'*|*'('*|*')'*|*'<'*|*'>'*|*'`'*|*'$'*) return 0 ;;
    *) return 1 ;;
  esac
}

for k in test build typecheck lint; do
  v="$(printf '%s' "$OUT" | jq -r --arg k "$k" ".commands.$k.value // empty")"
  [ -n "$v" ] || { fail komandy "commands.$k пусто (резолвер пробил — наш gate ловит)"; continue; }
  case "$v" in
    true) fail komandy "commands.$k замаскировано как 'true'"; continue ;;
    true\ *) fail komandy "commands.$k замаскировано как 'true*' (только пробелы/мусор после true): $v"; continue ;;
  esac
  # Разбираем команду на токены. set -f локально: иначе '*'/'[abc]' раскрылось
  # бы как glob относительно cwd.
  # shellcheck disable=SC2206
  set -f; toks=($v); set +f
  # Проверка операторов оболочки на КАЖДОМ токене ДО семейство-специфичной
  # логики (модель: op_obolochki). Анти-обход F3: токен `|` ловится как
  # оператор (раньше impl ловил только подстроку '|-' и пропускал '||').
  bad_tok=""
  for ((j=0; j<${#toks[@]}; j++)); do
    if op_obolochki "${toks[$j]}"; then bad_tok="${toks[$j]}"; break; fi
  done
  if [ -n "$bad_tok" ]; then
    fail komandy "commands.$k: оператор/подстановка оболочки в команде (токен: $bad_tok): $v"
    continue
  fi
  family="${toks[0]:-}"
  case "$family" in
    node|python3)
      # node|python3 <файл> [доп. токены без метасимволов оболочки].
      # Метасимволы в любом токене уже отвергнуты глобальной проверкой выше.
      file="${toks[1]:-}"
      [ -n "$file" ] || { fail komandy "commands.$k: нет пути после '$family'"; continue; }
      if canon_R "$file" "commands.$k" "file" komandy; then
        [ -f "$REAL" ] || fail komandy "commands.$k: файла нет в дереве: $file (real: $REAL)"
      fi
      continue
      ;;
    npm)
      # npm — закрытый набор: ровно один опциональный --prefix; затем либо
      # `run <s>` либо `test`. Любой хвост после `test` или после `run <s>` —
      # отказ (F3 закрытая форма); голое имя без run = отказ.
      dir="$R"
      if [ "${toks[1]:-}" = "--prefix" ]; then
        # Ровно один --prefix: если следующий токен — опять --prefix, форма
        # не закрыта. Повторный --prefix в иной позиции — тоже отказ.
        dnext="${toks[2]:-}"
        [ -n "$dnext" ] || { fail komandy "commands.$k: --prefix без значения: $v"; continue; }
        if [ "${toks[3]:-}" = "--prefix" ]; then
          fail komandy "commands.$k: повторный --prefix — форма не закрыта: $v"
          continue
        fi
        if ! canon_R "$dnext" "commands.$k: --prefix" "dir" komandy; then continue; fi
        dir="$REAL"
        cmd_i=3
      else
        cmd_i=1
      fi
      cur="${toks[$cmd_i]:-}"
      [ -n "$cur" ] || { fail komandy "commands.$k: пустой хвост после разбора npm: $v"; continue; }
      case "$cur" in
        run)
          script_i=$((cmd_i+1))
          script="${toks[$script_i]:-}"
          [ -n "$script" ] || { fail komandy "commands.$k: 'run' без имени скрипта <s>: $v"; continue; }
          extra_i=$((script_i+1))
          [ "$extra_i" -ge "${#toks[@]}" ] || { fail komandy "commands.$k: лишние токены после 'run <s>' — форма не закрыта: $v"; continue; }
          ;;
        test)
          extra_i=$((cmd_i+1))
          [ "$extra_i" -ge "${#toks[@]}" ] || { fail komandy "commands.$k: лишние токены после 'test' — форма не закрыта: $v"; continue; }
          script="test"
          ;;
        *)
          fail komandy "commands.$k: вне закрытой формы 'run <s>'|'test' (npm): $v"
          continue
          ;;
      esac
      pj="$dir/package.json"
      [ -f "$pj" ] || { fail komandy "commands.$k: нет $pj"; continue; }
      if ! jq -e --arg s "$script" '.scripts[$s] // null | type == "string"' "$pj" >/dev/null 2>&1; then
        fail komandy "commands.$k: скрипта '$script' нет в ${pj#"$R"/}"
      fi
      continue
      ;;
    *)
      fail komandy "commands.$k вне известных семейств (npm|node|python3): $v"
      continue
      ;;
  esac
done

# ── source-canon: каждый объявленный источник существует ВНУТРИ $R ─────────
sc="$(printf '%s' "$OUT" | jq -r '.sourceCanon.value.sources // [] | length')"
if [ "$sc" != "0" ] && [ -n "$sc" ]; then
  for idx in $(seq 0 $((sc-1))); do
    sp="$(printf '%s' "$OUT" | jq -r --argjson i "$idx" '.sourceCanon.value.sources[$i].path // empty')"
    [ -n "$sp" ] || { fail source-canon "источник #$idx: пустой path"; continue; }
    if canon_R "$sp" "источник #$idx" "file" source-canon; then
      [ -f "$REAL" ] || fail source-canon "источник отсутствует: $sp (real: $REAL)"
    fi
  done
fi

exit "$itog"
