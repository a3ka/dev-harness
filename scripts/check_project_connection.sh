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
#   komandy        — commands.<k> пуст, равен `true`, или ссылается на путь,
#                    которого нет в дереве репо (npm-скрипт не зарегистрирован,
#                    node/python3-файл отсутствует); также вне семейств
#                    {npm,node,python3}
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
# Анти-плацебо (правило 3 контракта 112):
#   • D14 (workflowPaths.state выходит из репо) — должно давать сбой, потому
#     что секция state проверяется НЕЗАВИСМО от иных workflow-каталогов:
#     симлинки/e ..-звенья разрешаются канонизацией и проверяются на
#     попадание в $R.
#   • D16 (симлинк-ЗВЕНО в середине пути state) — проверка — реальный
#     `cd && pwd -P` на родительский каталог (НЕ просто `-d`); именно
#     `cd && pwd -P` разрешает ВСЕ звенья по всему пути (а не только лист),
#     поэтому симлинк в середине пути и `..`-звено в любом сегменте
#     обнаруживаются одной и той же канонизацией.
#   • Проверка state НЕ вырезаема (в отличие от state-слепой контрмодели):
#     секция идёт отдельным блоком после workflowPaths.* и читает каталог
#     РЕАЛЬНО.
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

# ── helper: канонизация И ПРОВЕРКА каталога внутри репо. ───────────────────
# Возвращает 0 если есть каталог внутри $R после канонизации, иначе 1 + причина.
# Используется для workflowPaths.* и для state — отдельная секция (анти-плацебо
# D14/D16, правило 3): здесь НЕ «существование + not ..», а реальная
# канонизация ПОЛНОГО пути через `cd $p && pwd -P` — pwd -P разворачивает ВСЕ
# симлинки и ..-звенья по всему пути, а не только лист, поэтому D16 (симлинк
# в середине пути) и `..`-звено в любом сегменте обнаруживаются.
check_inside_dir() {  # $1=имя_ключа $2=значение_пути $3=без_умалч (1=state проверяется независимо, вырезаемо контрмоделью)
  local key="$1" v="$2" no_default="${3:-0}" def_val=".harness"
  if [ "$no_default" -eq 0 ]; then
    [ -n "$v" ] || { fail workflowPaths "$key отсутствует в эффективном профиле"; return 1; }
  fi
  case "$v" in /*) fail workflowPaths "$key абсолютный: $v"; return 1 ;; esac
  local p="$R/$v"
  [ -d "$p" ] || { fail workflowPaths "$key не каталог: $v"; return 1; }
  # Канонизация каталога: `cd && pwd -P` разворачивает симлинки и `..`-звенья
  # по ВСЕМУ пути, не только по листу (анти-плацебо D16: «промежуточное
  # симлинк-звено» обходилось бы при leaf-only проверке).
  local real
  real="$(cd "$p" 2>/dev/null && pwd -P || true)"
  if [ -z "$real" ]; then
    fail workflowPaths "$key канонизация не удалась: $v"
    return 1
  fi
  # Канонический путь может совпасть с $R (например state=«.harness» —
  # сам подкаталог верхнего уровня, реально $R/.harness → после cd $R/.harness
  # и pwd -P должен дать $R/.harness). Если же звено уводит наружу — отказ.
  case "$real" in
    "$R"|"$R"/*) return 0 ;;
    *) fail workflowPaths "$key канонически вне репо: $v → $real"; return 1 ;;
  esac
}

# ── workflowPaths.*: 4 ключа + ПРОВЕРКА существования + канонизация внутрь ─
for k in contracts verdicts registry fixtures; do
  v="$(printf '%s' "$OUT" | jq -r --arg k "$k" ".workflowPaths.$k.value // empty")"
  check_inside_dir "workflowPaths.$k" "$v" 0 || true
done

# ── state: независимая секция (НЕ вырезаемая как контрмодель) ──────────────
# Логика: тот же check_inside_dir. ВАЖНО: путь читается из эффективного
# профиля (.workflowPaths.state.value), по умолчанию = ".harness" (на
# случай, когда профиль опускает state — резолвер может не вернуть ключ;
# модель и контракт 112 §Конструкция говорят одно: state — это допустимый
# по умолчанию .harness, если профиль явно его не объявил).
v="$(printf '%s' "$OUT" | jq -r '.workflowPaths.state.value // ".harness"')"
check_inside_dir "workflowPaths.state" "$v" 1 || true

# ── kanon-remote: целые строки байт-в-байт ─────────────────────────────────
canon="$(printf '%s' "$OUT" | jq -r '.git.value.canonicalRemote // empty')"
orig="$(git -C "$R" remote get-url origin 2>/dev/null || true)"
if [ -z "$canon" ] || [ -z "$orig" ]; then
  fail kanon-remote "канон или origin пуст: канон='${canon:-<пусто>}' origin='${orig:-<пусто>}'"
elif [ "$canon" != "$orig" ]; then
  fail kanon-remote "канон профиля ≠ origin клона: '${canon}' ≠ '${orig}'"
fi

# ── komandy: каждая команда — допустимое семейство + файл/пакет ВНУТРИ $R ─
# Контракт 112 §Конструкция, ветвь komandy: семейство
# `npm [--prefix D] run <s>|test` → скрипт <s> есть в D/package.json;
# семейство `node|python3 <файл>` → файл есть в дереве; прочие формы —
# отказ (закрытый набор семейств). Здесь — СТРОЖЕ модели: канонизация
# реального пути (а не конкатенация строк) требует попадания в $R (анти-
# обход F1 «абсолютный путь принимается» и F2 «.. не канонизируется»);
# хвост после «test» или после «run <s>» запрещён (F3 «закрытая форма»);
# для node|python3 токены после файла допустимы только без метасимволов
# оболочки (литерал back: `node backend/scripts/gen-contracts.js --check`).
# Правило выбора зафиксировано комментарием выше, и в коде не гасится.
# Канонизирующий хелпер: real_path = $R/$raw канонически; вне $R → отказ.
canon_inside_R() {  # $1=raw $2=label; экспортирует REAL через косвенное имя
  local _raw="$1" _label="$2" _p _real
  case "$_raw" in /*) _p="$_raw" ;; *) _p="$R/$_raw" ;; esac
  # Канонизируем РОДИТЕЛЯ файла (cd требует каталог): ../ звенья и
  # симлинки разворачиваются по всему пути, не только по листу.
  local _parent _base _preal
  _parent="$(dirname -- "$_p")"
  _base="$(basename -- "$_p")"
  _preal="$(cd "$_parent" 2>/dev/null && pwd -P || true)"
  [ -n "$_preal" ] || { fail komandy "$_label: путь не канонизируется (вне файловой системы): $_raw"; return 1; }
  _real="$_preal/$_base"
  case "$_real" in "$R"|"$R"/*) REAL="$_real"; return 0 ;; *)
    fail komandy "$_label: канонически вне репо: $_raw → $_real"; return 1 ;;
  esac
}
for k in test build typecheck lint; do
  v="$(printf '%s' "$OUT" | jq -r --arg k "$k" ".commands.$k.value // empty")"
  [ -n "$v" ] || { fail komandy "commands.$k пусто (резолвер пробил — наш gate ловит)"; continue; }
  case "$v" in
    true) fail komandy "commands.$k замаскировано как 'true'"; continue ;;
    true\ *) fail komandy "commands.$k замаскировано как 'true*' (только пробелы/мусор после true): $v"; continue ;;
  esac
  # Разбираем команду на токены. Локально set -f (A3): иначе значение токена
  # `*` или `[abc]` раскрылось бы как glob относительно cwd.
  # shellcheck disable=SC2206
  set -f; toks=($v); set +f
  family="${toks[0]:-}"
  case "$family" in
    node|python3)
      # node|python3 <файл> [доп. токены без метасимволов оболочки]
      file="${toks[1]:-}"
      [ -n "$file" ] || { fail komandy "commands.$k: нет пути после '$family'"; continue; }
      REAL=""
      if canon_inside_R "$file" "commands.$k"; then
        [ -f "$REAL" ] || { fail komandy "commands.$k: файла нет в дереве: $file (real: $REAL)"; continue; }
        # Хвостовые токены: КАЖДЫЙ без метасимволов оболочки. Список —
        # операторы оболочки (`|| ; && | & > <`) и подстановки ($ ` " ' \).
        bad=""
        for ((j=2; j<${#toks[@]}; j++)); do
          case "${toks[$j]}" in
            *\|-*|*\&*|*\;*|*\(*|*\)*|*\<*|*\>*|*\$*|*\`*|*"\\"*|*"'"*|*"'"*) bad="${toks[$j]}"; break ;;
          esac
        done
        [ -z "$bad" ] || { fail komandy "commands.$k: токен после файла содержит метасимвол оболочки: $bad"; continue; }
      fi
      continue
      ;;
    npm)
      # npm — закрытый набор: «npm [--prefix D] test» либо «npm [--prefix D] run <s>».
      # Любой хвост после «test» или после «run <s>» — отказ (F3).
      dir="$R"; i=0
      while :; do
        nxt=$((i+1))
        [ "$nxt" -lt "${#toks[@]}" ] || break
        [ "${toks[$nxt]}" = "--prefix" ] || break
        dnext_i=$((i+2))
        [ "$dnext_i" -lt "${#toks[@]}" ] || { fail komandy "commands.$k: --prefix без значения: $v"; continue 2; }
        dnext="${toks[$dnext_i]}"
        REAL=""
        if ! canon_inside_R "$dnext" "commands.$k: --prefix"; then continue 2; fi
        dir="$REAL"
        i=$dnext_i
      done
      cmd_i=$((i+1))
      cur="${toks[$cmd_i]:-}"
      [ -n "$cur" ] || { fail komandy "commands.$k: пустой хвост после разбора npm: $v"; continue; }
      case "$cur" in
        run)
          script_i=$((cmd_i+1))
          script="${toks[$script_i]:-}"
          [ -n "$script" ] || { fail komandy "commands.$k: 'run' без имени скрипта <s>: $v"; continue; }
          extra_i=$((script_i+1))
          [ "$extra_i" -ge "${#toks[@]}" ] || { fail komandy "commands.$k: лишние токены после 'run <s>': $v"; continue; }
          ;;
        test)
          extra_i=$((cmd_i+1))
          [ "$extra_i" -ge "${#toks[@]}" ] || { fail komandy "commands.$k: лишние токены после 'test': $v"; continue; }
          script="test"
          ;;
        *)
          fail komandy "commands.$k: вне закрытой формы 'run <s>'|'test' (npm): $v"; continue
          ;;
      esac
      pj="$dir/package.json"
      [ -f "$pj" ] || { fail komandy "commands.$k: нет $pj"; continue; }
      if ! jq -e --arg s "$script" '.scripts[$s] // null | type == "string"' "$pj" >/dev/null 2>&1; then
        fail komandy "commands.$k: скрипта '$script' нет в ${pj#"$R"/}/package.json"
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
# Канонизируем относительный путь через `cd && pwd -P`, чтобы поймать
# `..`-побег (как и в komandy) — анти-плацебо симметричен с workflowPaths.
# Абсолютный путь — отказ по той же причине, что для workflowPaths.
sc="$(printf '%s' "$OUT" | jq -r '.sourceCanon.value.sources // [] | length')"
if [ "$sc" != "0" ] && [ -n "$sc" ]; then
  for idx in $(seq 0 $((sc-1))); do
    sp="$(printf '%s' "$OUT" | jq -r --argjson i "$idx" '.sourceCanon.value.sources[$i].path // empty')"
    if [ -z "$sp" ]; then
      fail source-canon "источник #$idx: пустой path"
      continue
    fi
    case "$sp" in
      /*) fail source-canon "источник абсолютный: $sp"; continue ;;
      *) p="$R/$sp" ;;
    esac
    preal="$(cd "$(dirname -- "$p")" 2>/dev/null && pwd -P || true)"
    if [ -z "$preal" ]; then
      fail source-canon "источник вне файловой системы: $sp"
      continue
    fi
    real="$preal/$(basename -- "$p")"
    case "$real" in
      "$R"|"$R"/*) ;;
      *) fail source-canon "источник канонически вне репо: $sp → $real"; continue ;;
    esac
    [ -f "$real" ] || { fail source-canon "источник отсутствует: $sp (real: $real)"; continue; }
  done
fi

exit "$itog"
