#!/usr/bin/env bash
# scripts/lib_session.sh — общая библиотека для предмета (б) двери и
# предмета (г) сторожа (контракт 080, инв. 13). ЕДИНСТВЕННЫЙ источник
# current_session_dir / live_subagents_in; без неё дверь и сторож
# расходятся молча на новом SESS_GLOB (правило «имена аргументов и
# путей живут в одном месте»). Bootstrap-импорт: `if [ -f … ]; then .
# … ; fi` (прецедент freeze_contract.sh и mint_line.sh).
#
# Не источник зон — `scripts/lib_zones.sh` другой домен; не обвязка
# root-only (это пользовательская библиотека — `runuser -u harness` под
# orch-peak, прямой вызов под orch_restart.sh).

# Тест-шовы — путь умолчания глобит orch-сессионный журнал (один файл
# на сессию, НЕ субагентские). Подмена — переменной окружения.
: "${ORCH_SESS_GLOB:=$HOME/.local/state/dev-harness-sessions/*/zones/dev/.omp/profiles/dev/agent/sessions/--home-harness-dev-harness--/*.jsonl}"

# current_session_dir — каталог САМОГО СВЕЖЕГО session-уровня .jsonl по mtime
# (та же логика, что `cur_ctx` в `orch-peak`). Возвращает одну строку —
# абсолютный путь каталога вида
# `<...>/sessions/--home-harness-dev-harness--/<TS>_<UUID>`. Пусто (rc 0)
# при отсутствии session-файлов: вызывающий СУДИТ пустоту как «нет
# сессии» и трактует как «нет живых субагентов» (проход по ноге 3 двери).
current_session_dir() {
  local f
  # shellcheck disable=`SC2086`
  f="$(ls -t $ORCH_SESS_GLOB 2>/dev/null | head -1)" || return 0
  [ -n "$f" ] || return 0
  # SESS_DIR = dirname(session.jsonl) / basename(session.jsonl без .jsonl):
  # каталог сессии — sibling самого свежего session-уровня .jsonl,
  # имя = basename файла без расширения (конвенция orch-peak live).
  printf '%s/%s' "$(dirname -- "$f")" "$(basename -- "$f" .jsonl)"
}

# live_subagents_in <sess_dir> — список СВЕЖИХ субагентских .jsonl
# (mtime > now-120s) в каталоге сессии. Печатает имена через запятую,
# в алфавитном порядке (basename без .jsonl). Пустая строка — нет
# свежих субагентов. Каталог отсутствует или пуст → пустая строка.
# Используется:
#   * `scripts/orch_restart.sh` — нога (б): свежий субагент → rc 1
#     «живые субагенты: <имена>»;
#   * `ops/server/root/orch-peak` — ветка CTX_HARD: опрос до
#     `ORCH_HARD_GRACE`; на истечении — принудительный маркер и
#     «живые субагенты погибнут: <имена>» в отчёт.
live_subagents_in() {
  local sess_dir="${1:-}"
  [ -n "$sess_dir" ] && [ -d "$sess_dir" ] || { return 0; }
  local now
  now="$(date +%s)"
  local -a names=()
  local f mt age name
  # Субагентские журналы могут иметь имена с ведущей точкой (например,
  # `.LiveAgent.jsonl` — скрытый субагент). bash-glob по умолчанию НЕ
  # включает dotfiles, поэтому перечисление «*.jsonl» молча пропускает
  # свежий `.LiveAgent.jsonl» — дверь поставит маркер при живом
  # субагенте (адверсарий 080-v3 I1). Включаем dotglob на время
  # перечисления и сразу снимаем — иначе задеть другие ветви файла
  # (например, вызов `lib_session.sh` внутри orch-peak, который может
  # опираться на glob-семантику родительского шелла).
  local prev_dotglob=0
  shopt -q dotglob 2>/dev/null && prev_dotglob=1
  shopt -s dotglob nullglob
  for f in "$sess_dir"/*.jsonl; do
    [ -e "$f" ] || continue
    mt="$(stat -c %Y "$f" 2>/dev/null || echo 0)"
    age=$((now - mt))
    [ "$age" -lt 120 ] || continue
    name="$(basename -- "$f" .jsonl)"
    names+=("$name")
  done
  if [ "$prev_dotglob" -eq 0 ]; then
    shopt -u dotglob 2>/dev/null || true
  fi
  shopt -u nullglob 2>/dev/null || true
  [ "${#names[@]}" -gt 0 ] || return 0
  local IFS=$'\n'
  # shellcheck disable=`SC2207`
  local sorted=( $(printf '%s\n' "${names[@]}" | LC_ALL=C sort) )
  unset IFS
  local first=1 n out=""
  for n in "${sorted[@]}"; do
    if [ "$first" -eq 1 ]; then out="$n"; first=0
    else out="$out,$n"
    fi
  done
  printf '%s' "$out"
}