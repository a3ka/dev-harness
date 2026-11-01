#!/usr/bin/env bash
# ЯДРО ДВОЙНИКОВ СТРОГОГО СТОРОЖА (контракт 152 «oom-sessii-i-zamki», И-1).
# Сторож «без эмуляторов/нативных сборок в scope сессии станции» перехватывает
# ИСПОЛНЕНИЕ, а не текст команды (урок арбитража 148: статическая грамматика
# открытого языка shell — недо-приближение; решающий оракул — прогон с
# двойниками в PATH и журналом). Каждый файл-имя рядом — двухстрочный вход
# `exec _jadro.sh "$@"`; имя запрета = basename $0 из ЗАМКНУТОГО списка
# установки (это НАШИ имена, не чужой ввод).
#
# ФАКТ SCOPE — ЯДРО ЗНАНИИ, НЕ ENV (И-2): /proc/self/cgroup содержит юнит
# orch-session-<pid>-<n>.scope (грамматика ops/server/user/orch-loop) —
# kernel-факт, который дочерний процесс изменить не может (env-маркер
# ORCH_SESSION_SCOPE=1, выставляемый orch-loop, — ВТОРОЙ канал для песочницы
# батареи; снятие env агентом kernel-факт не отменяет).
#
# СЧЁТ ЭМУЛЯТОРОВ ≤2 НА СТАНЦИИ (И-4): только имена семейства эмулятора,
# только ВНЕ scope (внутри — запрет безусловный); считаются живые процессы
# qemu-system (pgrep -f, шаблон с [q]-приёмом против само-матчей pgrep,
# собственный pid исключён literals). Предел — Astra mob-ci-razdelenie п.342.
#
# ЖУРНАЛ (И-5): ${XDG_STATE_HOME:-$HOME/.local/state}/dev-harness/
# strogo-stancii.tsv, строка TSV: UTC, kontekst(scope|stanca), imja, argv.
# Пишется ТОЛЬКО на отказах (pass-through владельца не журналируется).
#
# ОТКАЗЫ rc 1 (именованные, stderr «ОТКАЗ: <ИМЯ>: …»):
#   STROGO_SCOPE            запрет в scope сессии станции (правило 31.10)
# [S1 imja] имя запрета — ПЕРВЫЙ аргумент от файла-имени (замкнутый список
# установки; $0 здесь — сам _jadro.sh и имени запрета не несёт).
imja="$1"
[ -n "$imja" ] || { printf 'NOT_IMPLEMENTED: _jadro.sh зовётся без имени запрета\n' >&2; exit 2; }
shift
# (имя уже принято первым аргументом выше)

# [S2 fakt-scope] kernel-факт cgroup ИЛИ env-маркер orch-loop.
v_scope=0
if [ -r /proc/self/cgroup ] && grep -qE 'orch-session-[0-9]+-[0-9]+\.scope' /proc/self/cgroup; then
  v_scope=1
fi
if [ "${ORCH_SESSION_SCOPE:-0}" = "1" ]; then
  v_scope=1
fi

# [S3 spisok-semejstv] семейства запрета; expo судится по токенам argv
# (литеральные равенства — норма 041; разделитель ОС уже разделила argv).
zapret=0
case "$imja" in
  emulator|emulator-headless|qemu-system|qemu-system-*|prebuild) zapret=1 ;;
  gradle|cmake|clang|clang++)                                     zapret=1 ;;
  expo)                                                           zapret=0 ;;
  *)                                                              zapret=0 ;;
esac
if [ "$imja" = "expo" ]; then
  for a in "$@"; do
    if [ "$a" = "run:android" ] || [ "$a" = "prebuild" ]; then
      zapret=1
    fi
  done
fi

zhurnal() {  # <kontekst>
  local f d
  d="${XDG_STATE_HOME:-$HOME/.local/state}/dev-harness"
  f="$d/strogo-stancii.tsv"
  mkdir -p "$d" 2>/dev/null || return 0
  printf '%s\t%s\t%s\t' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$1" "$imja" >> "$f"
  printf '%q ' "$@" >> "$f"
  printf '\n' >> "$f"
}

if [ "$v_scope" = "1" ] && [ "$zapret" = "1" ]; then
  zhurnal scope
  printf 'ОТКАЗ: STROGO_SCOPE: %s не запускается в scope сессии станции — правило станции 2026-10-31: эмуляторы Android и нативные сборки идут на CI-раннерах (кадры — CI диаг-PR)\n' "$imja" >&2
  exit 1
fi

# [S4 schetchik] предел ≤2 эмуляторов станции — только семейство эмулятора и только вне scope.
case "$imja" in
  emulator|emulator-headless|qemu-system|qemu-system-*)
    if ! command -v pgrep >/dev/null 2>&1; then
      printf 'NOT_IMPLEMENTED: нет pgrep — счёт эмуляторов станции невозможен (fail-closed)\n' >&2
      exit 2
    fi
    n="$(pgrep -f '[q]emu-system' 2>/dev/null | grep -vFx "$$" | wc -l | tr -d ' ')"
    case "$n" in ''|*[!0-9]*) n=2 ;; esac
    if [ "$n" -ge 2 ]; then
      zhurnal stanca
      printf 'ОТКАЗ: STROGO_EMULJATORY_LIMIT: на станции %s живых qemu-system (предел — 2, Astra mob-ci-razdelenie п.342); запуск третьего запрещён\n' "$n" >&2
      exit 1
    fi
    ;;
esac

# [S5 propusk] pass-through: первый настоящий бинарник в PATH ВНЕ каталога
# этого двойника (иначе рекурсия). Не найден — rc 127 с именованной причиной.
moj_kat="$(cd "$(dirname "$0")" && pwd -P)" || exit 127
oldifs="$IFS"
IFS=:
for d in $PATH; do
  IFS="$oldifs"
  [ -n "$d" ] || continue
  [ -x "$d/$imja" ] || continue
  kuda="$(cd "$d" 2>/dev/null && pwd -P)" || continue
  [ "$kuda" = "$moj_kat" ] && continue
  exec "$d/$imja" "$@"
done
IFS="$oldifs"
printf 'ОТКАЗ: STROGO_NASTOJASHCHIJ_NET: настоящего %s в PATH нет (после каталога двойников)\n' "$imja" >&2
exit 127
