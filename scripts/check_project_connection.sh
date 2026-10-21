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
#   • глобальная проверка символов В КАЖДОМ токене ДО семейство-специфичной
#     логики: БЕЛЫЙ набор [A-Za-z0-9._/@:=+,-] (только литералы CI —
#     `node backend/scripts/gen-contracts.js --check`, `npm --prefix backend
#     run smoke:image`, `npm --prefix mobile run typecheck`, `--prefix`, `--check`).
#     ВСЁ прочее (включая ' " \ { } ~ | & ; ( ) < > ` $ * ? [ ] ! # % ^ пробельные,
#     управляющие, NUL) = отказ ДО канонизации (закрывает класс обхода shell —
#     снятие кавычек, раскрытие {a,}/~, обратная косая);
#   • ровно один опциональный --prefix; повторный --prefix = форма не закрыта;
#   • путь файла и --prefix ТОЛЬКО относительные и канонизируются ВНУТРЬ $R
#     через `cd && pwd -P` (полная канонизация каталога и родителя файла);
#     для ЛИСТА файла дополнительно realpath через `readlink -f`, чтобы
#     листовой symlink НАРУЖУ репо тоже отвергался (как и каталог-симлинк);
#     абсолютный/..-побег/листовой-symlink-наружу/симлинк-звено-наружу = отказ;
#   • форма npm закрыта: `npm [--prefix D] run <s>|test`; хвост = отказ;
#     голое имя без `run` = отказ;
#   • значения kanon-remote / workflowPaths.<k> / state / source-canon path
#     читаются БАЙТ-В-БАЙТ (через сравнение длины в jq и bash — иначе
#     `$(jq -r …)` срезает хвостовые \n, а NUL обрывает строку в bash);
#     хвостовые \n / NUL / управляющие = отказ именованной причиной того же
#     алфавита.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TOOLS="$(cd "$HERE/.." && pwd -P)"

REPO=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:-}"; shift 2 ;;
    --repo=*) REPO="${1#--repo=}"; shift ;;
    *) printf 'check_project_connection: неизвестный аргумент: %s\n' "$1" >&2; exit 2 ;;
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

# ── read_strict: чтение JSON-string БАЙТ-В-БАЙТ без потери хвоста ───────────
# Проблема: bash `$(jq -r …)` СРЕЗАЕТ все хвостовые \n, а NUL обрывает строку
# (bash хранит байты до первого NUL включительно). Это значит, что канон-
# remote с хвостовым \n или workflowPaths/state/source-canon.path с
# хвостовым \n/NUL принимаются как «чистые», хотя контракт (стр. 84)
# требует БАЙТ-в-БАЙТ. Решение: заворачиваем значение в уникальные sentinels
# PODKL_A/PODKL_B и сравниваем длину в jq с длиной в bash — расхождение
# означает потерю (хвостовые \n или NUL). Sentinel-строки — 32-байтные
# литералы, в URL/путях не встречаются (URL/relative paths — только ASCII
# printable + /). $1=jq-path (с ведущей точкой — нормальный jq-path), populates
# $VAL byte-equal. rc 0 ok / 1 truncated or jq error.
read_strict() {  # $1 jq-path (с ведущей точкой; типовое: .a.b.c или .a.b.c[N].d) → populates $VAL byte-equal; rc=0 ok / 1 mismatch|jq-err
  local jq_len sent p_path
  PODKL_A='__PODKL_A_d3b1e7a4f8c2__qr5t9j2k__'  # 32-байтный sentinel, нет в URL/путях
  PODKL_B='__PODKL_B_9c2f4a7e1d8b__wp6s3h5m__'  # 32-байтный sentinel, нет в URL/путях
  # p_path — путь с ведущей точкой (jq-path). getpath+split НЕ различает
  # `[N]` от обычной точки, поэтому используем прямую интерполяцию пути в
  # jq-выражение (все точки вызова пишем сами — user-input не принимаем).
  p_path="$1"
  [ -n "$p_path" ] || { VAL=""; return 1; }
  # Базовая санитизация: путь должен начинаться с ".". Если нет — добавляем.
  case "$p_path" in
    .*) ;;
    *) p_path=".$p_path" ;;
  esac
  if ! jq_len=$(printf '%s' "$OUT" | \
        PODKL_A="$PODKL_A" PODKL_B="$PODKL_B" \
        jq -r "$p_path | length // 0" 2>/dev/null); then
    VAL=""; return 1
  fi
  if ! sent=$(printf '%s' "$OUT" | \
        PODKL_A="$PODKL_A" PODKL_B="$PODKL_B" \
        jq -jr "$p_path // \"\" | env.PODKL_A + . + env.PODKL_B + \"\\n\"" 2>/dev/null); then
    VAL=""; return 1
  fi
  # bash $() срезал хвостовой \n: sent = "<A><canon><B>"
  VAL="${sent#"$PODKL_A"}"
  VAL="${VAL%"$PODKL_B"}"
  if [ "${#VAL}" != "$jq_len" ]; then
    # расхождение: либо хвостовые \n (bash их срезал), либо NUL внутри
    # (bash обрезал до первого NUL); в обоих случаях байт-в-байт сравнение
    # невозможно — отказываем именованной причиной на стороне вызывающего.
    VAL=""; return 1
  fi
  return 0
}

# ── tok_safe: проверка токена по БЕЛОМУ набору символов ─────────────────────
# Каждый токен команды целиком из [A-Za-z0-9._/@:=+,-]; всё прочее —
# отказ до семейство-специфичной логики. Закрывает класс обхода: shell
# перед исполнением СНИМАЕТ кавычки (' ") и обратную косую (\) и раскрывает
# {a,}/~, поэтому проверка «оператор/подстановка» недостаточна —
# нужен ПОЗИТИВНЫЙ алфавит (только литералы CI: --prefix, --check, run, test,
# node, npm, python3, basename с ./-/_).
# $1 токен → rc 0 если ВСЕ символы из белого списка, иначе rc 1.
tok_safe() {  # $1 token → 0 если whitelist, иначе 1
  case "$1" in
    *[^A-Za-z0-9._/@:=+-]*|'') return 1 ;;
    *) return 0 ;;
  esac
}

# ── canon_R: ЕДИНЫЙ хелпер канонизации «внутрь $R» (совет 050 A7)
#   $1=raw $2=label $3=kind( dir | file ) $4=reason
# Семантика — НЕ СЛАБЕЕ модели:
#   • каталог: cd "$R/$raw" && pwd -P (полная канонизация; симлинк-ЗВЕНО наружу
#     и `..`-побег = отказ);
#   • файл: канонизируется РОДИТЕЛЬ (cd + pwd -P), затем ЛИСТ через
#     `readlink -f` — листовой symlink наружу = отказ (закрывает A3; раньше
#     канонизировался только родитель и файл-снаружи проходил);
#   • абсолютный — ВСЕГДА отказ; пишет причину $4 + деталь;
#   • успех: REAL=канон_путь, return 0; ошибка: fail $4 + return 1.
canon_R() {  # $1=raw $2=label $3=kind $4=reason; sets REAL
  local raw="$1" label="$2" kind="$3" reason="$4" target parent dir_real base file_real
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
  # ФАЙЛ: канонизируем родителя (cd && pwd -P), затем ЛИСТ через readlink -f
  # (если лист — symlink, его realpath тоже обязан быть внутри $R).
  if [ ! -e "$target" ] && [ ! -L "$target" ]; then
    fail "$reason" "$label: файла нет в дереве: $raw"; return 1
  fi
  parent="$(dirname -- "$target")"
  base="$(basename -- "$target")"
  dir_real="$(cd "$parent" 2>/dev/null && pwd -P || true)"
  [ -n "$dir_real" ] || { fail "$reason" "$label: канонизация родителя не удалась: $raw"; return 1; }
  case "$dir_real" in
    "$R"|"$R"/*) ;;
    *) fail "$reason" "$label канонически вне репо: $raw → $dir_real/$base"; return 1 ;;
  esac
  file_real="$dir_real/$base"
  # Канонизация ЛИСТА: если это symlink (включая «битый»), его realpath
  # обязан тоже лежать внутри $R — иначе это листовой-побег.
  if [ -L "$file_real" ]; then
    file_real="$(readlink -f -- "$file_real" 2>/dev/null || true)"
    [ -n "$file_real" ] || { fail "$reason" "$label: лист-symlink канонизация не удалась: $raw"; return 1; }
    case "$file_real" in
      "$R"|"$R"/*) ;;
      *) fail "$reason" "$label листовой-symlink вне репо: $raw → $file_real"; return 1 ;;
    esac
  fi
  [ -f "$file_real" ] || { fail "$reason" "$label: не regular file (лист не файл): $raw"; return 1; }
  REAL="$file_real"
  return 0
}

# ── workflowPaths.*: 4 ключа + канонизация каталога внутрь $R ──────────────
for k in contracts verdicts registry fixtures; do
  if ! read_strict ".workflowPaths.$k.value"; then
    fail workflowPaths "workflowPaths.$k: значение содержит хвостовые \\n/NUL/управляющие (длина jq ≠ bash — байт-в-байт невозможно)"
    continue
  fi
  [ -n "$VAL" ] || { fail workflowPaths "workflowPaths.$k отсутствует в эффективном профиле"; continue; }
  canon_R "$VAL" "workflowPaths.$k" "dir" workflowPaths || true
done

# ── state: независимая секция (НЕ вырезаемая как контрмодель; анти-плацебо)
# state читается из эффективного профиля, по умолчанию = ".harness" (на
# случай, когда профиль опускает ключ — резолвер может не вернуть);
# чтение БАЙТ-В-БАЙТ через read_strict (иначе хвостовой \n принимается).
# Если ключа нет — VAL пуст; используем литерал ".harness".
if ! read_strict '.workflowPaths.state.value'; then
  fail workflowPaths "workflowPaths.state: значение содержит хвостовые \\n/NUL/управляющие"
else
  [ -n "$VAL" ] || VAL=".harness"
  canon_R "$VAL" "workflowPaths.state" "dir" workflowPaths || true
fi

# ── kanon-remote: целые строки байт-в-байт ─────────────────────────────────
# Чтение канона через read_strict (иначе `$(jq -r …)` срезает хвостовой \n,
# а NUL обрывает bash-строку — контрольный пример Adv112r3 с \n в каноне
# проходит как «равный origin»). orig получаем из git — он чистый.
if ! read_strict '.git.value.canonicalRemote'; then
  fail kanon-remote "git.canonicalRemote содержит хвостовые \\n/NUL/управляющие (длина jq ≠ bash — БАЙТ-в-БАЙТ сравнение невозможно)"
elif [ -z "$VAL" ]; then
  fail kanon-remote "git.canonicalRemote пуст"
else
  canon="$VAL"
  orig="$(git -C "$R" remote get-url origin 2>/dev/null || true)"
  if [ -z "$orig" ]; then
    fail kanon-remote "git remote get-url origin пуст (нет origin в клоне)"
  elif [ "$canon" != "$orig" ]; then
    fail kanon-remote "канон профиля ≠ origin клона (БАЙТ В БАЙТ): '${canon}' ≠ '${orig}'"
  fi
fi

# ── komandy: глобальная проверка символов В КАЖДОМ токене (БЕЛЫЙ набор) ─────
# Модель (model_check_connection.sh, KOMANDY-112-BEG/END) делает ту же
# проверку ДО семейство-специфичной логики. Здесь — БЕЛЫЙ набор символов
# tok_safe: каждый токен целиком из [A-Za-z0-9._/@:=+,-]; всё прочее — отказ
# по форме. Закрывает обход через {a,}, ~, ' ", обратную косую (раньше
# shell шага CI снимал кавычки/раскрывал и токен был «принят» формой, а
# исполнялся совсем другой файл).
#
# Чтение значения команды — БАЙТ-В-БАЙТ через read_strict: хвостовой \n
# трактовался как пустая команда (bash `$(jq -r)` срезает), и обход
# `npm --prefix mobile test\n` проходил как «`npm --prefix mobile test`».
for k in test build typecheck lint; do
  if ! read_strict ".commands.$k.value"; then
    fail komandy "commands.$k: значение содержит хвостовые \\n/NUL/управляющие (длина jq ≠ bash — байт-в-байт невозможно)"
    continue
  fi
  v="$VAL"
  [ -n "$v" ] || { fail komandy "commands.$k пусто (резолвер пробил — наш gate ловит)"; continue; }
  case "$v" in
    true) fail komandy "commands.$k замаскировано как 'true'"; continue ;;
    true\ *) fail komandy "commands.$k замаскировано как 'true*' (только пробелы/мусор после true): $v"; continue ;;
  esac
  # Разбираем команду на токены. set -f локально: иначе '*'/'[abc]' раскрылось
  # бы как glob относительно cwd.
  # shellcheck disable=SC2206
  set -f; toks=($v); set +f
  # Проверка БЕЛОГО набора символов на КАЖДОМ токене ДО семейство-специфичной
  # логики (модель: та же tok_safe; раньше была чёрная op_obolochki, она
  # ловила операторы shell, но shell сам СНИМАЕТ кавычки/'/'/'/'/'/\\'/'/'
  # и раскрывает {a,}/~ — поэтому нужен позитивный алфавит).
  bad_tok=""
  for ((j=0; j<${#toks[@]}; j++)); do
    if ! tok_safe "${toks[$j]}"; then bad_tok="${toks[$j]}"; break; fi
  done
  if [ -n "$bad_tok" ]; then
    fail komandy "commands.$k: токен вне белого алфавита [A-Za-z0-9._/@:=+,-] (токен: $bad_tok): $v"
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
# Чтение path через read_strict (хвостовые \n/NUL отлавливаются на этом шаге;
# иначе canon_R смотрит на $R/.harness/foo\n, не находит и шумит «нет в
# дереве», а не тем же алфавитом причины).
sc="$(printf '%s' "$OUT" | jq -r '.sourceCanon.value.sources // [] | length')"
if [ "$sc" != "0" ] && [ -n "$sc" ]; then
  for idx in $(seq 0 $((sc-1))); do
    if ! read_strict ".sourceCanon.value.sources[$idx].path"; then
      fail source-canon "источник #$idx: значение содержит хвостовые \\n/NUL/управляющие (длина jq ≠ bash — байт-в-байт невозможно)"
      continue
    fi
    sp="$VAL"
    [ -n "$sp" ] || { fail source-canon "источник #$idx: пустой path"; continue; }
    canon_R "$sp" "источник #$idx" "file" source-canon || true
  done
fi

exit "$itog"
