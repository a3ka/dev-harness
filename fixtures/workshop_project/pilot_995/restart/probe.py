#!/usr/bin/env python3
# БАРЬЕР-ГУАРД контракта 995 v+1 (§ПРОВОДКА): судит ПОСТАВЛЯЕМЫЕ артефакты —
# mobile/scripts/ci-e2e.sh продукта (единственный владелец эмулятора и
# повтора: перезапуск СВОЕГО эмулятора и один повтор набора) и живой
# fixtures/workshop_project/pilot_995/maestro_probe.py (редактированная
# публикация диагностики обеих попыток) — ПОВЕДЕНЧЕСКИ: replay настоящего
# скрипта в замкнутом PATH с подложными adb/emulator/avdmanager/maestro/pkill
# (сценарий задаёт rc набора, сигнатуры, junit-провалы, состояние транспорта,
# загрузку/установку/стабильность; журнал вызовов — оракул) и replay пробы
# P с тем же сценарием поверх модели S.
# Правило 8: оракул source.json снят в память ДО вызова субъекта; модели и
# носители — sha256. Н-39: обманные стабы — мутации моделей КОДОМ
# (STAB_MUTACII), привязки — stab_vhod source.json; рассинхрон множеств —
# rc 2 ORACLE_TAMPERED. Имена прогонов (GITHUB_RUN_ID) и имена кадров
# порождает РАННЕР (Н-408/арбитраж 142): ожидания строятся от сгенерированного
# входа в памяти, не от фиксированных констант.
"""Батарея 995 v+1 (restart/): перезапуск собственного эмулятора и один повтор
полного набора в ci-e2e.sh по канонической сигнатуре обрыва adb-транспорта.

Режимы:
  (без флага)  --repo R отсутствует и MOB_REPO не задан → rc 1 SUBJECT_ABSENT
                 с перечнем всех входов (зелень без субъекта невозможна);
  (без флага)  --repo R / MOB_REPO → субъект = R/mobile/scripts/ci-e2e.sh
                 (P-клетки судят живой maestro_probe.py харнесса);
  --model      контроль входов на моделях;
  --stabs      контроль + матрица обманных стабов (SVJAZI N);
  --matrix     синоним --stabs;
  --schet X    печатает одно число (kejsy|staby|svjazi|modeli) и выходит.
Коды возврата: 0 — зелено; 1 — красный вход либо стаб прошёл (STAB_ZHIV)
либо нет субъекта (SUBJECT_ABSENT); 2 — нечем проверять (ORACLE_TAMPERED,
дрейф модели/носителей/живого P).
"""
import argparse
import hashlib
import json
import os
import random
import re
import shutil
import signal
import subprocess
import sys
import tempfile
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
MODEL = HERE / 'model'
NOSITELI = HERE / 'nositeli'
LIVE_P = HERE.parent / 'maestro_probe.py'
SUBJECT_REL = 'mobile/scripts/ci-e2e.sh'
BASH = '/usr/bin/bash' if Path('/usr/bin/bash').is_file() else 'bash'
REAL_AWK = shutil.which('awk') or '/usr/bin/awk'

# ── свип смерти (арбитраж verdicts/arbitration/contracts-995-v2-arbitraz.md) ──
# B1: каждый подложный вызов adb/sleep/maestro (и старт подложного emulator)
# пишет строку «<tool> <args>» в ОТДЕЛЬНЫЙ файл $SCENARIJ_KATALOG/vyzovy;
# журнал zapisi и прежние ожидания — байт-неизменны. B2: якорь второй
# инкарнации — первый EMULATOR_STOP журнала (маркер NACHALO2); маркер пишут
# ТОЛЬКО родительские шимы adb/sleep/maestro — субъект последовательного
# выполнения, второй писатель дал бы второй маркер и сломал счёт k;
# «sleep 1» окна остановки старого PID точкой не считается. Смерть k-й точки
# назначается ПОСЛЕ эффекта вызова (trap EXIT): TERM второму EMULATOR_START
# журнала (при гонке fork→printf — дождаться строки, ограниченно), ожидание
# его EMULATOR_STOP (fifo, ограниченно), строка «SMERT <k> pid=<…>» в трассу.


def _svip_prolog(tool, smert=None, jakor=True):
    """Пролог шима свипа: строка трассы vyzovy (всегда) и arm смерти k-й
    точки. smert: None — смерти нет (maestro; emulator — и якоря нет: он
    дочерний); 'da' — всякая строка этого шима есть точка (adb); shell-условие
    — точка при его истинности (sleep: любая, кроме «sleep 1»)."""
    telo = '__v="${SCENARIJ_KATALOG:?}/vyzovy"\n'
    if jakor:
        telo += ("if grep -q '^EMULATOR_STOP ' \"${SCENARIJ_ZAPISI:?}\" && "
                 "! grep -q '^NACHALO2$' \"$__v\"; then "
                 "printf 'NACHALO2\\n' >>\"$__v\"; fi\n")
    telo += "printf '%s %s\\n' " + tool + ' "$*" >>"$__v"\n'
    if smert is None:
        return telo
    uslovie = 'if [ -n "${SCENARIJ_SMERT_TOCHKA:-}" ]'
    if smert != 'da':
        uslovie += ' && ' + smert
    uslovie += '; then'
    return telo + uslovie + '''
  __k=0; __n=0
  while IFS= read -r __l; do
    case "$__l" in
      NACHALO2) __n=1; __k=0 ;;
      SMERT\\ *|emulator\\ *|maestro\\ *|sleep\\ 1) : ;;
      *) [ "$__n" = 1 ] && __k=$((__k + 1)) ;;
    esac
  done <"$__v"
  if [ "$__n" = 1 ] && [ "$__k" = "${SCENARIJ_SMERT_TOCHKA}" ]; then
    __smert() {
      __i=0; __owned=""
      while [ "$__i" -lt 100 ]; do
        __owned=$(grep '^EMULATOR_START ' "${SCENARIJ_ZAPISI:?}" | sed -n '2p'); __owned=${__owned##* }
        [ -n "$__owned" ] && break
        __i=$((__i + 1)); read -t 0.05 __x <>"${SCENARIJ_RYCHKA:?}" || true
      done
      kill "$__owned" 2>/dev/null || true
      __i=0
      while [ "$__i" -lt 60 ] && ! grep -q "^EMULATOR_STOP ${__owned}$" "${SCENARIJ_ZAPISI:?}"; do
        __i=$((__i + 1)); read -t 0.05 __x <>"${SCENARIJ_RYCHKA:?}" || true
      done
      printf 'SMERT %s pid=%s\\n' "$__k" "$__owned" >>"$__v"
    }
    trap __smert EXIT
  fi
fi
'''

# ── подложные команды replay (замкнутый алфавит; всё иное — 127) ────────────

ADB_SH = r'''#!/usr/bin/env bash
# Подложный adb батареи 995 restart: замкнутый алфавит подкоманд ci-e2e;
# состояние транспорта — файл $SCENARIJ_KATALOG/transport (obryv|ok),
# поколение эмулятора — счётчик EMULATOR_START в журнале. Всё иное — 127.
z="${SCENARIJ_ZAPISI:?}"
k="${SCENARIJ_KATALOG:?}"
''' + _svip_prolog('adb', 'da') + r'''
pokolenie() { local p f pid emu; p=$(grep -c '^EMULATOR_START ' "$z" 2>/dev/null); p=${p:-0}
  # стартующий (форк есть, строки EMULATOR_START ещё нет) эмулятор тоже считается:
  # иначе гонка fork→printf отдаёт чужое поколение первому adb-вызову готовности
  # (наблюдалось параллельными прогонами --model, СОВЕТ критика 995 v2)
  emu="${0%/*}/emulator"
  for f in $(grep -laF -- "$emu" /proc/[0-9]*/cmdline 2>/dev/null); do
    pid=${f#/proc/}; pid=${pid%/cmdline}
    grep -qE "^EMULATOR_START [^ ]+ ${pid}\$" "$z" 2>/dev/null || { p=$((p + 1)); break; }
  done
  echo "$p"; }
pole() { local IFS=,; read -ra ch <<<"$1"; echo "${ch[$(( $2 - 1 ))]:-}"; }
transport() { cat "$k/transport" 2>/dev/null || echo ok; }
if [ "${1:-}" = "devices" ]; then
  printf 'ADB_DEVICES\n' >>"$z"
  echo 'List of devices attached'
  if [ "$(transport)" = ok ]; then printf 'emulator-5560\tdevice\n'; else printf '%s\n' "${SCENARIJ_ADB_DEVICES_OBRYV:-}"; fi
  exit 0
fi
case "$*" in
  *start-server*) printf 'ADB_STARTSERVER\n' >>"$z"; exit 0 ;;
esac
if [ "${1:-}" = "-s" ] && [ "${2:-}" = "emu" ]; then
  printf 'ADB_EMU_KILL\n' >>"$z"; exit 0
fi
case "$*" in
  *"reconnect offline"*) printf 'ADB_RECONNECT\n' >>"$z"; exit 0 ;;
  *kill-server*) printf 'ADB_KILL_SERVER\n' >>"$z"; exit 0 ;;
  *"wait-for-device"*)
    if [ -n "${SCENARIJ_VISYA_POKOLENIE:-}" ] && [ "$(pokolenie)" = "${SCENARIJ_VISYA_POKOLENIE}" ]; then
      exec 3<>"${SCENARIJ_RYCHKA:?}"
      read -t 120 x <&3 || true
    elif [ -n "${SCENARIJ_EMULATOR_SMERT:-}" ] && [ "$(pole "${SCENARIJ_EMULATOR_SMERT}" "$(pokolenie)")" = srazu ]; then
      # смерть сразу после EMULATOR_START: дать ей проявиться до kill -0 субъекта
      # (родитель всегда обгоняет стартующего ребёнка — проверено t-kill0)
      exec 3<>"${SCENARIJ_RYCHKA:?}"
      read -t 0.6 x <&3 || true
    fi
    exit 0 ;;
  *"getprop sys.boot_completed"*)
    __b="$(pole "${SCENARIJ_BOOT:-ok}" "$(pokolenie)")"
    if [ "$__b" = ne-zagruzilsja ]; then echo 0
    elif [ "$__b" = pozdno ]; then
      # boot pozdno (B3, арбитраж 995 v2): первый getprop инкарнации отвечает 0 —
      # тело boot-цикла входит в трассу свипа; счёт по vyzovy (своя строка уже дописана)
      __g=0
      while IFS= read -r __l; do
        case "$__l" in
          NACHALO2) __g=0 ;;
          *getprop\ sys.boot_completed*) __g=$((__g + 1)) ;;
        esac
      done <"$__v"
      if [ "$__g" -le 1 ]; then echo 0; else echo 1; fi
    else echo 1; fi
    exit 0 ;;
  *get-state*) if [ "$(transport)" = ok ]; then echo device; else echo offline; fi; exit 0 ;;
  *"pm path"*) if [ "$(transport)" = ok ]; then exit 0; else exit 1; fi ;;
  *"settings put global"*) exit 0 ;;
  *"install -r"*)
    if [ "$(pole "${SCENARIJ_INSTALL:-ok}" "$(pokolenie)")" = otkaz ]; then
      printf 'ADB_INSTALL rc=1\n' >>"$z"; exit 1
    fi
    printf 'ADB_INSTALL rc=0\n' >>"$z"
    if [ -n "${SCENARIJ_TRANSPORT_POSLE_INSTALL:-}" ]; then
      printf '%s\n' "$SCENARIJ_TRANSPORT_POSLE_INSTALL" >"$k/transport"
    fi
    exit 0 ;;
  *"shell cat /proc/sys/kernel/random/boot_id"*)
    printf 'ADB_BOOT_ID\n' >>"$z"
    if [ "$(transport)" = ok ]; then echo "${SCENARIJ_BOOT_ID:-b995-sintetika}"; exit 0; else exit 1; fi ;;
  *"shell pidof adbd"*)
    printf 'ADB_ADBD\n' >>"$z"
    if [ "$(transport)" = ok ]; then echo 4242; exit 0; else exit 1; fi ;;
  *"shell logcat"*)
    printf 'ADB_LOGCAT\n' >>"$z"
    if [ -n "${SCENARIJ_EMULATOR_SMERT:-}" ] && [ "$(pole "${SCENARIJ_EMULATOR_SMERT}" "$(pokolenie)")" = posle-logcat ]; then
      # смерть между готовностью и вторым набором: эмулятор умирает по этому
      # событию журнала; задержка даёт ему выйти и быть убранным до kill -0
      exec 3<>"${SCENARIJ_RYCHKA:?}"
      read -t 0.8 x <&3 || true
    fi
    if [ "$(transport)" = ok ]; then
      [ -n "${SCENARIJ_LOGCAT:-}" ] && printf '%s' "$SCENARIJ_LOGCAT" | tr '\037' '\n'
      exit 0
    fi
    echo 'error: устройство недоступно' >&2; exit 1 ;;
esac
printf 'ADB_VNE_ALFAVITA: %s\n' "$*" >&2
exit 127
'''

EMULATOR_SH = r'''#!/usr/bin/env bash
# Подложный emulator батареи 995 restart: ЖИВОЙ процесс-владение — пишет
# EMULATOR_START <avd> <pid> в журнал, печатает стартовый журнал инкарнации
# (S перенаправляет его в emulator-*.log), ставит транспорт в ok и блокируется
# до TERM (trap пишет EMULATOR_STOP) или до истечения бюджета блокировки.
# Ось «владение инкарнацией» (исправление FAIL критика 995 v2):
# SCENARIJ_EMULATOR_SMERT по поколению — srazu (умирает сразу после
# EMULATOR_START, транспорт уже ok: serial продолжает отвечать чужой/старой
# инкарнацией), posle-logcat (умирает, увидев новую строку ADB_LOGCAT после
# своего старта — диагностика boot между готовностью и вторым набором),
# posle-maestro (умирает, увидев вторую строку MAESTRO — после старта второго
# набора). Смерть пишет EMULATOR_STOP сама.
z="${SCENARIJ_ZAPISI:?}"
k="${SCENARIJ_KATALOG:?}"
''' + _svip_prolog('emulator', jakor=False) + r'''
avd=""
prev=""
for a in "$@"; do
  if [ "$prev" = "-avd" ]; then avd="$a"; fi
  prev="$a"
done
pole() { local IFS=,; read -ra ch <<<"$1"; echo "${ch[$(( $2 - 1 ))]:-}"; }
printf 'EMULATOR_START %s %s\n' "${avd:-?}" "$$" >>"$z"
printf 'emulator: старт инкарнации avd=%s pid=%s\n' "${avd:-?}" "$$"
if [ -n "${SCENARIJ_EMULATOR_LOG:-}" ]; then
  printf '%s' "$SCENARIJ_EMULATOR_LOG" | tr '\037' '\n'
fi
printf 'ok\n' >"$k/transport"
pok=$(grep -c '^EMULATOR_START ' "$z" 2>/dev/null); pok=${pok:-0}
smert=$(pole "${SCENARIJ_EMULATOR_SMERT:-}" "$pok")
if [ "$smert" = srazu ]; then
  printf 'EMULATOR_STOP %s\n' "$$" >>"$z"
  exit 0
fi
trap 'printf "EMULATOR_STOP %s\n" "$$" >>"$z"; exit 0' TERM INT
if [ "$smert" = posle-logcat ] || [ "$smert" = posle-maestro ]; then
  if [ "$smert" = posle-logcat ]; then obrazec='^ADB_LOGCAT$'; else obrazec='^MAESTRO '; fi
  baz=$(grep -c "$obrazec" "$z" 2>/dev/null); baz=${baz:-0}
  i=0
  exec 4<>"${SCENARIJ_RYCHKA:?}"
  while [ "$i" -lt 560 ]; do
    tek=$(grep -c "$obrazec" "$z" 2>/dev/null); tek=${tek:-0}
    [ "$tek" -gt "$baz" ] && break
    i=$((i + 1))
    read -t 0.05 x <&4 || true
  done
  printf 'EMULATOR_STOP %s\n' "$$" >>"$z"
  exit 0
fi
exec 3<>"${SCENARIJ_RYCHKA:?}"
read -t 25 x <&3 || true
printf 'EMULATOR_STOP %s\n' "$$" >>"$z"
exit 0
'''

PKILL_SH = ('#!/usr/bin/env bash\n'
            '# Подложный pkill батареи 995 restart: НИКОГО не убивает, только '
            'фиксирует вызов.\nz="${SCENARIJ_ZAPISI:?}"\n'
            'printf \'PKILL_VYZVAN %s\\n\' "$*" >>"$z"\nexit 0\n')

SLEEP_SH = ('#!/usr/bin/env bash\n'
            '# Мгновенный sleep батареи 995 restart; ИСКЛЮЧЕНИЕ sleep 1 — окно\n'
            '# остановки OWNED PID модели (TERM → ожидание → KILL): реальных 0.05 с,\n'
            '# чтобы TERM-обработка эмулятора успела дописать EMULATOR_STOP до KILL\n'
            '# (при мгновенном окне под параллельной нагрузкой KILL обгонял trap).\n'
            '# Свип смерти (арбитраж 995 v2): каждый вызов — строка трассы vyzovy;\n'
            '# «sleep 1» окна остановки старого PID точкой смерти НЕ является.\n'
            + _svip_prolog('sleep', '[ "${1:-}" != 1 ]') +
            'if [ "${1:-}" = 1 ]; then\n'
            '  exec 3<>"${SCENARIJ_RYCHKA:?}"\n'
            '  read -t 0.05 x <&3 || true\n'
            'fi\n'
            'exit 0\n')

PS_SH = ('#!/usr/bin/env bash\n'
         '# Подложный ps батареи 995 restart: одна сценарная строка adb-сервера.\n'
         '[ -n "${SCENARIJ_PS_ADB:-}" ] && echo "$SCENARIJ_PS_ADB"\nexit 0\n')

AWK_SH = ('#!/usr/bin/env bash\n'
          '# Подложный awk батареи 995 restart: /proc/meminfo — сценарный, '
          'прочее — системный awk.\n'
          'case "$*" in */proc/meminfo*) echo "${SCENARIJ_MEMINFO:-61000000}"; exit 0;; esac\n'
          'exec ' + REAL_AWK + ' "$@"\n')

AVDMANAGER_SH = r'''#!/usr/bin/env bash
# Подложный avdmanager батареи 995 restart: create — каталог AVD с config.ini
# (под sed -i), delete — успех; всё иное — 127.
z="${SCENARIJ_ZAPISI:?}"
if [ "${1:-}" = "create" ] && [ "${2:-}" = "avd" ]; then
  imja=""
  prev=""
  for a in "$@"; do
    if [ "$prev" = "-n" ]; then imja="$a"; fi
    prev="$a"
  done
  cat >/dev/null
  mkdir -p "${ANDROID_AVD_HOME:?}/${imja:?}.avd"
  printf 'hw.ramSize=4096\nhw.device.name=pixel_7\n' \
    >"${ANDROID_AVD_HOME:?}/${imja:?}.avd/config.ini"
  printf 'AVDMANAGER_CREATE %s\n' "$imja" >>"$z"
  exit 0
fi
if [ "${1:-}" = "delete" ]; then
  imja=""
  prev=""
  for a in "$@"; do
    if [ "$prev" = "-n" ]; then imja="$a"; fi
    prev="$a"
  done
  printf 'AVDMANAGER_DELETE %s\n' "$imja" >>"$z"
  exit 0
fi
printf 'AVDMANAGER_VNE_ALFAVITA: %s\n' "$*" >&2
exit 127
'''

MAESTRO_SH = r'''#!/usr/bin/env bash
# Подложный maestro батареи 995 restart: сценарный игрок ПОПЫТКИ — счётчик
# вызовов, rc/junit-провалы/сигнатуры/кадры из SCENARIJ_MAESTRO_*; после
# прогона ставит транспорт по SCENARIJ_TRANSPORT_POSLE. Секрет (если задан
# окружением P) рассеивается в текстовые каналы — redaction обязан его снять.
z="${SCENARIJ_ZAPISI:?}"
k="${SCENARIJ_KATALOG:?}"
''' + _svip_prolog('maestro') + r'''
out=""
tod=""
prev=""
for a in "$@"; do
  case "$prev" in
    --output) out="$a" ;;
    --test-output-dir) tod="$a" ;;
  esac
  prev="$a"
done
if [ -z "$out" ] || [ -z "$tod" ]; then
  printf 'MAESTRO_VNE_ALFAVITA: %s\n' "$*" >&2
  exit 127
fi
pole() { local IFS=,; read -ra ch <<<"$1"; echo "${ch[$(( $2 - 1 ))]:-}"; }
n=$(( $(cat "$k/maestro_schet" 2>/dev/null || echo 0) + 1 ))
echo "$n" >"$k/maestro_schet"
rc=$(pole "${SCENARIJ_MAESTRO_RC:-0}" "$n"); rc=${rc:-0}
sig=$(pole "${SCENARIJ_MAESTRO_SIGNATURA:-}" "$n")
trn=$(pole "${SCENARIJ_MAESTRO_TRANSPORT_NEUDACHI:-0}" "$n"); trn=${trn:-0}
prd=$(pole "${SCENARIJ_MAESTRO_PRODUKT_NEUDACHI:-0}" "$n"); prd=${prd:-0}
tekst=$(pole "${SCENARIJ_MAESTRO_PRODUKT_TEKST:-Продуктовая проверка не прошла}" "$n")
mkdir -p "$tod"
if [ "${SCENARIJ_MAESTRO_BEZOTCHETA:-}" = da ]; then
  : >"$out"
  printf 'MAESTRO %s rc=%s\n' "$n" "$rc" >>"$z"
  posle=$(pole "${SCENARIJ_TRANSPORT_POSLE:-ok}" "$n"); printf '%s\n' "${posle:-ok}" >"$k/transport"
  exit "$rc"
fi
{
  printf '<?xml version="1.0"?>\n'
  printf '<testsuite name="pilot" attempt="%s" rc="%s">\n' "$n" "$rc"
  i=0
  while [ "$i" -lt "$trn" ]; do
    i=$((i + 1))
    printf '<testcase name="transport-%s"><failure message="обрыв транспорта">%s</failure><system-out>%s</system-out></testcase>\n' \
      "$i" "${sig:-device offline}" "${PILOT_DEMO_CODE:-}"
  done
  i=0
  while [ "$i" -lt "$prd" ]; do
    i=$((i + 1))
    printf '<testcase name="produkt-%s"><failure message="провал проверки">%s</failure><system-out>%s</system-out></testcase>\n' \
      "$i" "$tekst" "${PILOT_DEMO_CODE:-}"
  done
  if [ "$trn" -eq 0 ] && [ "$prd" -eq 0 ]; then
    printf '<testcase name="pilot-first-run"/><testcase name="pilot-welcome"/><testcase name="pilot-restart"/>\n'
  fi
  printf '</testsuite>\n'
} >"$out"
printf '{"attempt": %s, "code": "%s"}\n' "$n" "${PILOT_DEMO_CODE:-}" >"$tod/commands.json"
if [ "$rc" -eq 0 ]; then
  for imja in pilot-first-run pilot-welcome pilot-restart; do
    printf 'synthetic-png-attempt-%s' "$n" >"$tod/$imja.png"
  done
else
  kadry=$(pole "${SCENARIJ_MAESTRO_PNG_KRASNYJ:-ekran-otkaza-a1.png,ekran-otkaza-a2.png}" "$n")
  IFS=',' read -ra spisok <<<"$kadry"
  for imja in "${spisok[@]}"; do
    [ -n "$imja" ] && printf 'synthetic-png-attempt-%s' "$n" >"$tod/$imja"
  done
fi
i=0
while [ "$i" -lt "$trn" ]; do
  i=$((i + 1))
  echo "Command failed (host:transport:emulator-5560): ${sig:-device offline}"
done
i=0
while [ "$i" -lt "$prd" ]; do
  i=$((i + 1))
  echo "$tekst"
done
printf 'MAESTRO %s rc=%s\n' "$n" "$rc" >>"$z"
posle=$(pole "${SCENARIJ_TRANSPORT_POSLE:-ok}" "$n"); printf '%s\n' "${posle:-ok}" >"$k/transport"
exit "$rc"
'''

UTILITY_ALFAVIT = ('bash', 'sed', 'grep', 'tr', 'cp', 'rm', 'mkdir', 'cat',
                   'seq', 'date', 'readlink')

OKRUZHENIE_ACTIONS = {
    'GITHUB_ACTIONS': 'true',
    'CI': 'true',
    'GITHUB_RUN_ATTEMPT': '1',
    'GITHUB_RUN_NUMBER': '4242',
    'GITHUB_WORKFLOW': 'mobile',
    'GITHUB_JOB': 'android-e2e',
    'GITHUB_EVENT_NAME': 'push',
    'GITHUB_SHA': '9950beef9950beef9950beef9950beef9950beef',
    'GITHUB_REF': 'refs/heads/main',
    'GITHUB_ACTOR': 'battery-995',
    'RUNNER_OS': 'Linux',
    'RUNNER_ARCH': 'X64',
    'RUNNER_NAME': 'selfhosted-995',
}

SEKRET = 'synthetic-private-995v2'


def sha256_bytes(b):
    return hashlib.sha256(b).hexdigest()


def oshibka_orakula(msg):
    print('ORACLE_TAMPERED: %s' % msg, file=sys.stderr)
    return 2


def load_source():
    src = json.loads((HERE / 'source.json').read_text(encoding='utf-8'))
    if src.get('kontrakt') != '995-cmp-mob-001-android-pilot':
        raise RuntimeError('kontrakt != 995')
    if set(src['stab_vhod']) != set(STAB_MUTACII):
        raise RuntimeError('stab_vhod != STAB_MUTACII')
    for k, svjazi in src['stab_vhod'].items():
        if not svjazi:
            raise RuntimeError('стаб %s без привязок: проверка исчезает' % k)
        for v in svjazi:
            if v not in src['kejsy']:
                raise RuntimeError('стаб %s связан с неизвестным входом %s' % (k, v))
    pins = src['nositeli']
    for otn, imja_f in (('model/ci-e2e.sh', MODEL / 'ci-e2e.sh'),
                        ('model/maestro_probe.py', MODEL / 'maestro_probe.py'),
                        ('nositeli/ci-e2e-staryj.sh', NOSITELI / 'ci-e2e-staryj.sh'),
                        ('nositeli/maestro_probe-staryj.py', NOSITELI / 'maestro_probe-staryj.py')):
        if sha256_bytes(imja_f.read_bytes()) != pins[otn]:
            raise RuntimeError('пин %s не сходится' % otn)
    return src


# ── sandbox -------------------------------------------------------------------

def zapisat_shim(put, tekst):
    put.write_text(tekst, encoding='utf-8')
    put.chmod(0o755)


def postavit_sandbox(katalog):
    """Каталог replay: bindir (шимы+симлинки), android/avd home, workspace,
    сценарный каталог (журнал, транспорт, fifo). Возвращает пути и env."""
    bin_ = katalog / 'bindir'
    bin_.mkdir(parents=True)
    for imja, tekst in (('adb', ADB_SH), ('emulator', EMULATOR_SH),
                        ('maestro', MAESTRO_SH), ('pkill', PKILL_SH),
                        ('sleep', SLEEP_SH), ('ps', PS_SH), ('awk', AWK_SH)):
        zapisat_shim(bin_ / imja, tekst)
    for u in UTILITY_ALFAVIT:
        cel = Path('/usr/bin') / u
        if not cel.exists():
            raise RuntimeError('утилита PATH replay отсутствует: %s' % u)
        (bin_ / u).symlink_to(cel)
    android_home = katalog / 'android-home'
    avdm = android_home / 'cmdline-tools' / 'latest' / 'bin' / 'avdmanager'
    avdm.parent.mkdir(parents=True)
    zapisat_shim(avdm, AVDMANAGER_SH)
    avd_home = katalog / 'avd-home'
    avd_home.mkdir()
    scen = katalog / 'scenarij'
    scen.mkdir()
    (scen / 'zapisi').write_text('', encoding='utf-8')
    # B1: трасса вызовов свипа смерти — отдельный файл, журнал zapisi не трогает
    (scen / 'vyzovy').write_text('', encoding='utf-8')
    (scen / 'transport').write_text('ok\n', encoding='utf-8')
    rychka = scen / 'rychka'
    os.mkfifo(str(rychka))
    ws = katalog / 'workspace'
    (ws / '.maestro').mkdir(parents=True)
    (ws / '.maestro/rehearsal.yaml').write_text('synthetic-flow-995\n', encoding='utf-8')
    apk = katalog / 'apk'
    apk.mkdir()
    (apk / 'release.apk').write_bytes(b'synthetic-not-an-apk-995')
    env = {
        'PATH': str(bin_),
        'HOME': str(katalog),
        'ANDROID_HOME': str(android_home),
        'ANDROID_AVD_HOME': str(avd_home),
        'SCENARIJ_ZAPISI': str(scen / 'zapisi'),
        'SCENARIJ_KATALOG': str(scen),
        'SCENARIJ_RYCHKA': str(rychka),
    }
    return ws, apk / 'release.apk', env


SCENA_KLJUCHI = {
    'maestro_rc': 'SCENARIJ_MAESTRO_RC',
    'maestro_signatura': 'SCENARIJ_MAESTRO_SIGNATURA',
    'maestro_transport_neudachi': 'SCENARIJ_MAESTRO_TRANSPORT_NEUDACHI',
    'maestro_produkt_neudachi': 'SCENARIJ_MAESTRO_PRODUKT_NEUDACHI',
    'maestro_produkt_tekst': 'SCENARIJ_MAESTRO_PRODUKT_TEKST',
    'maestro_png_krasnyj': 'SCENARIJ_MAESTRO_PNG_KRASNYJ',
    'maestro_bezotcheta': 'SCENARIJ_MAESTRO_BEZOTCHETA',
    'transport_posle': 'SCENARIJ_TRANSPORT_POSLE',
    'boot': 'SCENARIJ_BOOT',
    'stabil': 'SCENARIJ_STABIL',
    'install': 'SCENARIJ_INSTALL',
    'adb_devices_obryv': 'SCENARIJ_ADB_DEVICES_OBRYV',
    'boot_id': 'SCENARIJ_BOOT_ID',
    'logcat': 'SCENARIJ_LOGCAT',
    'emulator_log': 'SCENARIJ_EMULATOR_LOG',
    'meminfo': 'SCENARIJ_MEMINFO',
    'ps_adb': 'SCENARIJ_PS_ADB',
    'visya_pokolenie': 'SCENARIJ_VISYA_POKOLENIE',
    'transport_posle_install': 'SCENARIJ_TRANSPORT_POSLE_INSTALL',
    'emulator_smert': 'SCENARIJ_EMULATOR_SMERT',
    'smert_tochka': 'SCENARIJ_SMERT_TOCHKA',
}


def scena_v_env(env, scena):
    for k, imja in SCENA_KLJUCHI.items():
        if k in scena and scena[k] is not None:
            v = scena[k]
            if isinstance(v, list):
                v = ','.join(str(x) for x in v)
            env[imja] = str(v)


def ubrat_osirotkov(zapisi):
    for line in zapisi:
        if line.startswith('EMULATOR_START '):
            try:
                os.kill(int(line.split()[2]), signal.SIGKILL)
            except (ValueError, ProcessLookupError, PermissionError, OSError):
                pass


def zapisi_pidy(zapisi):
    return [line.split()[2] for line in zapisi if line.startswith('EMULATOR_START ')]


def podstavit_pidy(ozhidanie, fakt_pidy, avd):
    vyh = []
    for line in ozhidanie:
        line = line.replace('@avd@', avd)
        for i, pid in enumerate(fakt_pidy, 1):
            line = line.replace('@p%d@' % i, pid)
        vyh.append(line)
    return vyh


# ── replay субъекта S ---------------------------------------------------------

def ispolnit_s(subj_bytes, kejs, koren, okr, run_id):
    avd = 'ci-%s-1' % run_id
    katalog = koren / ('s-%s-%s' % (okr.lower(), run_id))
    katalog.mkdir()
    ws, apk, env = postavit_sandbox(katalog)
    if kejs.get('staryj_artefakt'):
        stale = ws / 'maestro-out'
        stale.mkdir()
        (stale / 'stale-marker').write_text(
            'device offline из прогона прошлой попытки\n', encoding='utf-8')
    scena_v_env(env, kejs['scena'])
    env['GITHUB_RUN_ID'] = run_id
    env['GITHUB_RUN_ATTEMPT'] = '1'
    if okr == 'ACTIONS':
        env.update(OKRUZHENIE_ACTIONS)
    skript = ws / 'ci-e2e.sh'
    skript.write_bytes(subj_bytes)
    skript.chmod(0o755)
    try:
        r = subprocess.run([BASH, str(skript), str(apk)], cwd=str(ws), env=env,
                           capture_output=True, text=True, timeout=90)
    except subprocess.TimeoutExpired:
        zapisi = (katalog / 'scenarij' / 'zapisi').read_text(encoding='utf-8').splitlines()
        ubrat_osirotkov(zapisi)
        return {'prichina': 'TIMEOUT replay (субъект завис)'}
    zapisi = (katalog / 'scenarij' / 'zapisi').read_text(encoding='utf-8').splitlines()
    vyzovy = (katalog / 'scenarij' / 'vyzovy').read_text(encoding='utf-8').splitlines()
    ubrat_osirotkov(zapisi)
    return {'rc': r.returncode, 'stdout': r.stdout, 'stderr': r.stderr,
            'zapisi': zapisi, 'vyzovy': vyzovy,
            'pidy': zapisi_pidy(zapisi), 'ws': ws, 'avd': avd}


def proglat(spisok, limit=4):
    return ' | '.join(spisok[:limit]) + (' …' if len(spisok) > limit else '')


def sud_publikaciju(ws, ozh):
    prichiny = []
    if ozh.get('diag_net'):
        if (ws / 'maestro-out/diagnostics').exists():
            prichiny.append('диагностика опубликована, ожидалось отсутствие')
        return prichiny
    if 'report' in ozh:
        p = ws / 'maestro-out/report.xml'
        if not p.is_file():
            prichiny.append('нет maestro-out/report.xml')
        else:
            telo = p.read_text(encoding='utf-8')
            for m in ozh['report']:
                if m not in telo:
                    prichiny.append('report.xml без %r' % m)
    if ozh.get('report_net') and (ws / 'maestro-out/report.xml').is_file():
        prichiny.append('report.xml существует, ожидалось отсутствие')
    if 'png' in ozh:
        fakt = sorted(f.name for f in (ws / 'maestro-out').glob('*.png')) if (ws / 'maestro-out').is_dir() else []
        if fakt != sorted(ozh['png']):
            prichiny.append('кадры вершины: %s (ожидались %s)' % (fakt, sorted(ozh['png'])))
    if 'png_attempt' in ozh and (ws / 'maestro-out').is_dir():
        n = ozh['png_attempt']
        for f in (ws / 'maestro-out').glob('*.png'):
            if f.read_bytes() != ('synthetic-png-attempt-%s' % n).encode():
                prichiny.append('кадр %s не попытки %s' % (f.name, n))
    for num, treb in (ozh.get('diag') or {}).items():
        d = ws / 'maestro-out/diagnostics' / ('attempt-%s' % num)
        for imja in treb.get('fajly', []):
            if not (d / imja).is_file():
                prichiny.append('diagnostics/attempt-%s: нет %s' % (num, imja))
        for imja in treb.get('net_fajlov', []):
            if (d / imja).is_file():
                prichiny.append('diagnostics/attempt-%s: лишний %s' % (num, imja))
        man = d / 'diag/manifest.txt'
        if man.is_file():
            telo = man.read_text(encoding='utf-8')
            for m in treb.get('manifest', []):
                if m not in telo:
                    prichiny.append('manifest attempt-%s без %r' % (num, m))
        for imja, tekst in (treb.get('fajl_tekst') or {}).items():
            p = d / imja
            if p.is_file() and p.read_text(encoding='utf-8') != tekst:
                prichiny.append('diagnostics/attempt-%s/%s: текст расходится' % (num, imja))
    if ozh.get('staryj_istirat') and (ws / 'maestro-out/stale-marker').is_file():
        prichiny.append('просроченный артефакт не стёрт публикацией')
    return prichiny


def sud_s_replay(subj_bytes, kejs, koren):
    ozh = kejs['ozhidanie']
    for okr in ('CHISTYJ', 'ACTIONS'):
        run_id = '%09d' % random.randrange(10 ** 9)
        fakt = ispolnit_s(subj_bytes, kejs, koren, okr, run_id)
        if 'prichina' in fakt:
            return fakt['prichina']
        prichiny = []
        if fakt['rc'] != ozh.get('rc', 0):
            prichiny.append('rc=%d (ожидался %d)' % (fakt['rc'], ozh.get('rc', 0)))
        ozh_zapisi = podstavit_pidy(ozh.get('zapisi', []), fakt['pidy'], fakt['avd'])
        if fakt['zapisi'] != ozh_zapisi:
            prichiny.append('записи: [%s] ≠ [%s]' % (proglat(fakt['zapisi']),
                                                     proglat(ozh_zapisi)))
        vyvod = fakt['stdout'] + '\n' + fakt['stderr']
        for m in ozh.get('vyvod', []):
            if m not in vyvod:
                prichiny.append('нет маркера вывода: %r' % m)
        for m in ozh.get('neto', []):
            if m in vyvod:
                prichiny.append('лишний маркер вывода: %r' % m)
        prichiny += sud_publikaciju(fakt['ws'], ozh.get('publikacija') or {})
        if prichiny:
            return '%s: %s' % (okr, prichiny[0])
    return None

# ── свип смерти: клетка s-svip (арбитраж 995 v2, перечень B4) ─────────────────

def _svip_tochki(vyzovy):
    """Перечень точек смерти из чистого replay: строки трассы после якоря
    NACHALO2 (первый EMULATOR_STOP журнала — граница второй инкарнации) до
    ПЕРВОГО вызова maestro (не включая): смерть после старта второго набора —
    клетка (г), не точка свипа. Строки emulator (дочерний шим — порядок с
    гонкой fork→printf), «sleep 1» окна остановки старого PID и служебные
    SMERT точками не считаются; счёт РАННЕРА и счёт шимов — одно правило."""
    if 'NACHALO2' not in vyzovy:
        return []
    tochki = []
    for l in vyzovy[vyzovy.index('NACHALO2') + 1:]:
        if l.startswith('maestro '):
            break
        if l.startswith('SMERT ') or l.startswith('emulator ') or l == 'sleep 1':
            continue
        tochki.append(l)
    return tochki


def _svip_prichiny(fakt, ozh, state):
    """ОДНО ожидание точки k, вычисленное ДО вызова субъекта (B4): rc 1;
    MAESTRO 2 нет; RECOVERED нет; именованный ОТКАЗ owned PID; публикация
    попытки 1; после SMERT — ни одной строки алфавита состояние-меняющих
    вызовов инварианта 8 (единый источник — ozh['alfavit_sostojanij'])."""
    if 'prichina' in fakt:
        return fakt['prichina']
    prichiny = []
    if fakt['rc'] != ozh.get('rc', 1):
        prichiny.append('rc=%d (ожидался %d)' % (fakt['rc'], ozh.get('rc', 1)))
    if any(l.startswith('MAESTRO 2') for l in fakt['zapisi']):
        prichiny.append('MAESTRO 2 вызван')
    vyvod = fakt['stdout'] + '\n' + fakt['stderr']
    for m in ozh.get('vyvod', []):
        if m not in vyvod:
            prichiny.append('нет маркера вывода: %r' % m)
    for m in ozh.get('neto', []):
        if m in vyvod:
            prichiny.append('лишний маркер вывода: %r' % m)
    smert = [i for i, l in enumerate(fakt['vyzovy']) if l.startswith('SMERT ')]
    if not smert:
        prichiny.append('точка смерти не сработала: нет строки SMERT')
    else:
        posle = [l for l in fakt['vyzovy'][smert[0] + 1:] if state.match(l)]
        if posle:
            prichiny.append('состояние-меняющие вызовы ПОСЛЕ смерти: %s'
                            % proglat([p[:60] for p in posle]))
    prichiny += sud_publikaciju(fakt['ws'], ozh.get('publikacija') or {})
    return '; '.join(prichiny)


def sud_svip(subj_bytes, kejs, koren, bystro=False):
    """Клетка inkarnacija-smert-svip: свип смерти owned PID второй инкарнации
    по КАЖДОЙ точке замкнутого алфавита. Перечень точек выводится ЧИСТЫМ
    replay (N — не константа; N=0 — красная «нет второй инкарнации»); для
    каждого k = 1..N — replay со smert_tochka=k (смерть ПОСЛЕ эффекта вызова
    k). bystro — остановка на первом красном k (матрица --stabs). Окружение
    CHISTYJ достаточно (ACTIONS удваивает цену, не добавляя точек)."""
    ozh = kejs['ozhidanie']
    state = re.compile(ozh['alfavit_sostojanij'])
    fakt = ispolnit_s(subj_bytes, dict(kejs, scena=dict(kejs['scena'])), koren,
                      'CHISTYJ', '%09d' % random.randrange(10 ** 9))
    if 'prichina' in fakt:
        return fakt['prichina']
    tochki = _svip_tochki(fakt['vyzovy'])
    if not tochki:
        print('SVIP N=0: нет второй инкарнации (якорь NACHALO2 не встречен)')
        return 'SVIP: нет второй инкарнации (N=0; якорь NACHALO2 не встречен в трассе)'
    krasnye = []
    pervyj = None
    for k, vyzov in enumerate(tochki, 1):
        fakt = ispolnit_s(subj_bytes,
                          dict(kejs, scena=dict(kejs['scena'], smert_tochka=str(k))),
                          koren, 'CHISTYJ', '%09d' % random.randrange(10 ** 9))
        prichina = _svip_prichiny(fakt, ozh, state)
        print('SVIP k=%2d %-58s %s' % (k, vyzov[:58], 'ok' if not prichina else 'KRASNO'))
        if prichina:
            krasnye.append(k)
            if pervyj is None:
                pervyj = 'k=%d (%s): %s' % (k, vyzov[:70], prichina)
            if bystro:
                break
    print('SVIP itog: N=%d, krasnykh %d%s'
          % (len(tochki), len(krasnye),
             (' (k=%s)' % ','.join(str(k) for k in krasnye)) if krasnye else ''))
    return pervyj

# ── replay пробы P ------------------------------------------------------------

P_ENV_KLJUCHI = ('SCENARIJ_ZAPISI', 'SCENARIJ_KATALOG', 'SCENARIJ_RYCHKA',
                 'SCENARIJ_MAESTRO_RC', 'SCENARIJ_MAESTRO_SIGNATURA',
                 'SCENARIJ_MAESTRO_TRANSPORT_NEUDACHI', 'SCENARIJ_MAESTRO_PRODUKT_NEUDACHI',
                 'SCENARIJ_MAESTRO_PRODUKT_TEKST', 'SCENARIJ_MAESTRO_PNG_KRASNYJ',
                 'SCENARIJ_MAESTRO_BEZOTCHETA', 'SCENARIJ_TRANSPORT_POSLE',
                 'SCENARIJ_BOOT', 'SCENARIJ_STABIL', 'SCENARIJ_INSTALL',
                 'SCENARIJ_ADB_DEVICES_OBRYV', 'SCENARIJ_BOOT_ID', 'SCENARIJ_LOGCAT',
                 'SCENARIJ_EMULATOR_LOG', 'SCENARIJ_MEMINFO', 'SCENARIJ_PS_ADB',
                 'SCENARIJ_VISYA_POKOLENIE', 'GITHUB_RUN_ID', 'GITHUB_RUN_ATTEMPT',
                 'ANDROID_HOME', 'ANDROID_AVD_HOME')


def ispolnit_p(p_subj, scena, koren, dop_args=()):
    # P ставится в изолированный stsen-каталог рядом с pilot.yaml харнесса:
    # проба грузит (HERE/'pilot.yaml') от СВОЕГО места — модели и носители
    # живут без собственной копии потока.
    katalog = koren / ('p-%09d' % random.randrange(10 ** 9))
    katalog.mkdir()
    ws, apk, env = postavit_sandbox(katalog)
    scena_v_env(env, scena)
    env['GITHUB_RUN_ID'] = '%09d' % random.randrange(10 ** 9)
    env['GITHUB_RUN_ATTEMPT'] = '1'
    repo = katalog / 'repo'
    (repo / 'mobile/scripts').mkdir(parents=True)
    (repo / 'mobile/.maestro').mkdir(parents=True)
    (repo / 'mobile/scripts/ci-e2e.sh').write_bytes((MODEL / 'ci-e2e.sh').read_bytes())
    (repo / 'mobile/.maestro/rehearsal.yaml').write_text('synthetic-flow-995\n', encoding='utf-8')
    kod = katalog / 'code'
    kod.write_text(SEKRET + '\n', encoding='utf-8')
    out = katalog / 'out'
    zapisi_f = katalog / 'scenarij' / 'zapisi'
    env2 = dict(os.environ)
    env2['PATH'] = env['PATH'] + os.pathsep + os.environ.get('PATH', os.defpath)
    for k in P_ENV_KLJUCHI:
        if k in env:
            env2[k] = env[k]
    stsen = katalog / 'pstsen'
    stsen.mkdir()
    p_fajl = stsen / 'maestro_probe.py'
    if isinstance(p_subj, str):
        p_fajl.write_text(p_subj, encoding='utf-8')
    else:
        p_fajl.write_bytes(Path(p_subj).read_bytes())
    (stsen / 'pilot.yaml').write_bytes((HERE.parent / 'pilot.yaml').read_bytes())
    komanda = [sys.executable, str(p_fajl), '--repo', str(repo), '--apk', str(apk),
               '--code-file', str(kod), '--out', str(out)] + list(dop_args)
    try:
        r = subprocess.run(komanda, cwd=str(katalog), env=env2,
                           capture_output=True, text=True, timeout=120)
        rc, vyhod, oshibki = r.returncode, r.stdout, r.stderr
    except subprocess.TimeoutExpired:
        zapisi = zapisi_f.read_text(encoding='utf-8').splitlines()
        ubrat_osirotkov(zapisi)
        return {'prichina': 'TIMEOUT replay пробы (P не остановила дерево субъекта)'}
    zapisi = zapisi_f.read_text(encoding='utf-8').splitlines()
    time.sleep(0.6)
    pidy = zapisi_pidy(zapisi)
    zhivy = [p for p in pidy if Path('/proc/%s' % p).exists()]
    ubrat_osirotkov(zapisi)
    return {'rc': rc, 'stdout': vyhod, 'stderr': oshibki, 'out': out,
            'zapisi': zapisi, 'zhivye_pidy': zhivy}


def sud_p_replay(p_subj, kejs, koren):
    ozh = kejs['ozhidanie']
    dop = ['--timeout', '3'] if kejs.get('proba_timeout') else []
    fakt = ispolnit_p(p_subj, kejs['scena'], koren, dop_args=dop)
    if 'prichina' in fakt:
        return fakt['prichina']
    prichiny = []
    if fakt['rc'] != ozh.get('rc', 0):
        prichiny.append('rc=%d (ожидался %d)' % (fakt['rc'], ozh.get('rc', 0)))
    vyvod = fakt['stdout'] + '\n' + fakt['stderr']
    for m in ozh.get('vyvod', []):
        if m not in vyvod:
            prichiny.append('нет маркера вывода: %r' % m)
    for m in ozh.get('neto', []):
        if m in vyvod:
            prichiny.append('лишний маркер вывода: %r' % m)
    out = fakt['out']
    if ozh.get('out_report_net'):
        if (out / 'report.xml').is_file():
            prichiny.append('report.xml опубликован, ожидалось отсутствие')
    else:
        p = out / 'report.xml'
        if not p.is_file():
            prichiny.append('нет опубликованного report.xml')
        else:
            telo = p.read_text(encoding='utf-8')
            for m in ozh.get('out_report', []):
                if m not in telo:
                    prichiny.append('report.xml без %r' % m)
    if 'out_png' in ozh:
        fakt_png = sorted(f.name for f in out.glob('*.png'))
        if fakt_png != sorted(ozh['out_png']):
            prichiny.append('кадры публикации: %s (ожидались %s)' % (fakt_png, sorted(ozh['out_png'])))
    for num, imena in (ozh.get('out_diag') or {}).items():
        for imja in imena:
            if not (out / 'diagnostics' / ('attempt-%s' % num) / imja).is_file():
                prichiny.append('публикация без diagnostics/attempt-%s/%s' % (num, imja))
    for imja in ozh.get('net_v_out', []):
        if list(out.rglob(imja)):
            prichiny.append('в публикации лишнее: %s' % imja)
    if out.is_dir():
        for f in out.rglob('*'):
            if f.is_file() and SEKRET.encode() in f.read_bytes():
                prichiny.append('секрет в публикации: %s' % f.relative_to(out))
                break
    if SEKRET in vyvod:
        prichiny.append('секрет в выводе пробы')
    if ozh.get('redaktor'):
        najden = False
        if (out / 'diagnostics').is_dir():
            for f in (out / 'diagnostics').rglob('*'):
                if f.is_file() and b'[REDACTED]' in f.read_bytes():
                    najden = True
                    break
        if not najden:
            prichiny.append('нет [REDACTED] в опубликованной диагностике')
    if ozh.get('protsessy_mertvy') and fakt['zhivye_pidy']:
        prichiny.append('живые процессы субъекта: %s' % fakt['zhivye_pidy'])
    return prichiny[0] if prichiny else None


# ── структурные клетки --------------------------------------------------------

def sud_strukturu(podtip, subj_s_bytes, src):
    if podtip == 'kanon-bajt':
        if subj_s_bytes is None:
            return 'SKRIPT_OTSUTSTVUET'
        if sha256_bytes(subj_s_bytes) != src['nositeli']['model/ci-e2e.sh']:
            return 'SKRIPT_RASHOZHDENIE: байты субъекта ≠ модели (копия байт-в-байт)'
        return None
    if podtip == 'zhyvoj-p-kanon':
        if not LIVE_P.is_file():
            return 'P_ZHIVOJ_NET: maestro_probe.py отсутствует'
        if sha256_bytes(LIVE_P.read_bytes()) != src['nositeli']['model/maestro_probe.py']:
            return 'P_DRIFT: живой maestro_probe.py ≠ модели'
        return None
    if subj_s_bytes is None:
        return 'SKRIPT_OTSUTSTVUET'
    telo = subj_s_bytes.decode('utf-8', errors='replace')
    if podtip == 'zapret-stroki':
        for obrazec in src['zapret_strok']:
            if obrazec in telo:
                return 'ZAPRETNYY_VYZOV: %r в тексте субъекта' % obrazec
        return None
    if podtip == 'kanon-signatury':
        kanon = src['signatury_regex']
        n = telo.count(kanon)
        if n != src['signatur_vstrech']['s']:
            return 'PODMENA_SIGNATURY: вхождений канона %d, ожидалось %d' % (
                n, src['signatur_vstrech']['s'])
        ostavshijsja = telo.replace(kanon, '')
        for s in src['signatury_ostatok_zapret']:
            if s in ostavshijsja:
                return 'PODMENA_SIGNATURY: обрывок сигнатуры вне канона: %r' % s
        return None
    return 'неизвестный podtip struktura'


# ── обманные стабы (Н-39: мутации моделей КОДОМ) ------------------------------

def _zameni(t, staryj, novyj):
    if t.count(staryj) != 1:
        raise RuntimeError('цель мутации не единственна (вхождений %d): %r'
                           % (t.count(staryj), staryj[:60]))
    return t.replace(staryj, novyj)


def s_bez_restarta(b):
    return _zameni(b, '  ostanovit_svoyo\n  zapusti_emulator\n  gotovnost || {',
                   '  $ADB -s "$SERIAL" reconnect offline >/dev/null 2>&1 || true\n'
                   '  wait_stable || {')


def s_retry_vseh(b):
    return _zameni(b, 'if ! transportnaya_prichina "podhod-$n"; then', 'if false; then')


def s_tretja_popytka(b):
    return _zameni(b, 'PODHOD_MAX=2', 'PODHOD_MAX=3')


def s_glotajet_diag(b):
    b = _zameni(b, '  diag_snapshot "podhod-$n/diag" boot "$n"', '  :')
    return _zameni(b, '  diag_snapshot "podhod-$n/diag" otkaz "$n"', '  :')


def s_diag_posle_stopa(b):
    return _zameni(b, '  ostanovit_svoyo\n  zapusti_emulator\n  gotovnost || {',
                   '  zapusti_emulator\n  ostanovit_svoyo\n  gotovnost || {')


def s_pkill_vmesto_pida(b):
    return _zameni(b, '    kill "$EMU_PID" 2>/dev/null || true',
                   '    pkill -f "qemu-system-x86_64.*-avd $AVD" 2>/dev/null || true')


def s_kill_server_v_stope(b):
    return _zameni(b, '    kill "$EMU_PID" 2>/dev/null || true',
                   '    $ADB kill-server >/dev/null 2>&1 || true\n'
                   '    kill "$EMU_PID" 2>/dev/null || true')


def s_nasledovanie_signatur(b):
    return _zameni(b, 'grep -rqE "$KANON" "$d/maestro.log" "$d/report.xml" "$d/test" 2>/dev/null || return 1',
                   'grep -rqE "$KANON" . 2>/dev/null || return 1')


def s_signatura_suzhena(b):
    return _zameni(b, "KANON='device offline|adb: device not found|device [^ ]* not found|DeviceServerDiedException'",
                   "KANON='device offline|DeviceServerDiedException'")


def s_signatura_rasshirena(b):
    return _zameni(b, "KANON='device offline|adb: device not found|device [^ ]* not found|DeviceServerDiedException'",
                   "KANON='device offline|adb: device not found|device [^ ]* not found|DeviceServerDiedException|INSTALL_FAILED'")


def s_bez_publikacii_diagnostiki(b):
    return _zameni(b, '  for d in podhod-*/diag; do', '  for d in net-takikh-*/diag; do')


def s_png_obeih(b):
    return _zameni(b, '  for f in "podhod-$n"/test/*.png; do', '  for f in podhod-*/test/*.png; do')


def s_bez_recovered(b):
    return _zameni(b, '      echo "RECOVERED: обрыв adb-транспорта попытки $((n-1)) пережит перезапуском собственного эмулятора; попытка ${n} зелёная" >&2',
                   '      :')


def s_exhausted_zelenyj(b):
    return _zameni(b, 'exit "$itog"', 'exit 0')


def s_propusk_boot_proverki(b):
    return _zameni(b, '  while [ "$($ADB -s "$SERIAL" shell getprop sys.boot_completed 2>/dev/null | tr -d \'\\r\')" != "1" ]; do',
                   '  while false; do')


def s_bez_zhizni(b):
    # «только EMULATOR_START без проверки жизни PID» — модель критика: ни одна
    # из проверок не различает мёртвый owned PID при отвечающем serial
    return _zameni(b, '  if [ -z "$EMU_PID" ] || ! kill -0 "$EMU_PID" 2>/dev/null; then',
                   '  if false; then')


def s_zhizn_tolko_na_gotovnosti(b):
    # «проверка жизни только на готовности, не перед вторым набором»:
    # смерть МЕЖДУ готовностью и вторым набором не ловится
    return _zameni(b, '  if [ "$n" -gt 1 ]; then\n    zhiv_svoyo || {',
                   '  if false; then\n    zhiv_svoyo || {')

def s_zhizn_perenesena(b):
    # контрмодель критика 2/2 ДОСЛОВНО (Critic995b/mutate995.py): проверка жизни
    # перед install перенесена к wait-for-device — на свипе красна (install
    # исполняется после смерти; арбитраж 995 v2, замер 5, перечень C1)
    b = _zameni(b, '  zhiv_svoyo || return 1\n  $ADB -s "$SERIAL" install -r "$APK"',
                '  $ADB -s "$SERIAL" install -r "$APK"')
    return _zameni(b, '  $ADB -s "$SERIAL" wait-for-device\n',
                   '  $ADB -s "$SERIAL" wait-for-device\n  zhiv_svoyo || return 1\n')


def s_zhizn_ne_pered_nastrojkami(b):
    # модель OBJECT (edb0cf0a…): строка A1 (zhiv_svoyo первой в теле цикла
    # настроек) удалена — находка арбитра (замер 4): после смерти на
    # wait-for-device/getprop исполняются оставшиеся settings put на чужом
    # отвечающем serial; красна на свипе (перечень C2)
    return _zameni(b, '  for s in window_animation_scale transition_animation_scale animator_duration_scale; do\n'
                      '    zhiv_svoyo || return 1\n'
                      '    $ADB -s "$SERIAL" shell settings put global "$s" 0\n',
                   '  for s in window_animation_scale transition_animation_scale animator_duration_scale; do\n'
                      '    $ADB -s "$SERIAL" shell settings put global "$s" 0\n')


def s_bez_itoga_stabil(b):
    return _zameni(b, '  echo "ОТКАЗ: эмулятор $SERIAL не стабилизировался (adb offline, поколение $POKOLENIE)" >&2\n  return 1',
                   '  return 0')


def s_bez_pamyati(b):
    return _zameni(b, 'if [ "$avail" -lt "$MIN_FREE_GB" ]; then', 'if false; then')


def s_install_ignoriruet(b):
    return _zameni(b, '  $ADB -s "$SERIAL" install -r "$APK" >/dev/null || {\n'
                      '    echo "ОТКАЗ: установка APK не удалась (поколение $POKOLENIE)" >&2\n'
                      '    return 1\n'
                      '  }',
                   '  $ADB -s "$SERIAL" install -r "$APK" >/dev/null || true')


def p_bez_redakcii(t):
    return _zameni(t, "dest.write_bytes(raw.replace(secret.encode(), b'[REDACTED]'))",
                   'dest.write_bytes(raw)')


def p_bez_diagnostiki(t):
    return _zameni(t, 'for path, raw in sorted(files.items()):',
                   "for path, raw in sorted(k for k in files.items() if 'diagnostics' not in k[0].parts):")


def p_bez_timeout_publikacii(t):
    return _zameni(t, '                publikovat_do_vyhoda(stdout, stderr)',
                   '                pass')


def p_bez_sobytija(t):
    return _zameni(t, "print('995 sobytie: ' + line.strip()[:200])",
                   "sys.stdout.write('')")


def p_privatnoe_v_publikaciju(t):
    return _zameni(t, "publication = private / 'maestro-out'", 'publication = private')


S_STABY = {
    's-bez-restarta': s_bez_restarta,
    's-retry-vseh': s_retry_vseh,
    's-tretja-popytka': s_tretja_popytka,
    's-glotajet-diag': s_glotajet_diag,
    's-diag-posle-stopa': s_diag_posle_stopa,
    's-pkill-vmesto-pida': s_pkill_vmesto_pida,
    's-kill-server-v-stope': s_kill_server_v_stope,
    's-nasledovanie-signatur': s_nasledovanie_signatur,
    's-signatura-suzhena': s_signatura_suzhena,
    's-signatura-rasshirena': s_signatura_rasshirena,
    's-bez-publikacii-diagnostiki': s_bez_publikacii_diagnostiki,
    's-png-obeih': s_png_obeih,
    's-bez-recovered': s_bez_recovered,
    's-exhausted-zelenyj': s_exhausted_zelenyj,
    's-propusk-boot-proverki': s_propusk_boot_proverki,
    's-bez-itoga-stabil': s_bez_itoga_stabil,
    's-bez-pamyati': s_bez_pamyati,
    's-install-ignoriruet': s_install_ignoriruet,
    's-bez-zhizni': s_bez_zhizni,
    's-zhizn-tolko-na-gotovnosti': s_zhizn_tolko_na_gotovnosti,
    's-zhizn-perenesena': s_zhizn_perenesena,
    's-zhizn-ne-pered-nastrojkami': s_zhizn_ne_pered_nastrojkami,
}

P_STABY = {
    'p-bez-redakcii': p_bez_redakcii,
    'p-bez-diagnostiki': p_bez_diagnostiki,
    'p-bez-timeout-publikacii': p_bez_timeout_publikacii,
    'p-bez-sobytija': p_bez_sobytija,
    'p-privatnoe-v-publikaciju': p_privatnoe_v_publikaciju,
}

STAB_MUTACII = dict(S_STABY)
STAB_MUTACII.update(P_STABY)


# ── суд клетки ----------------------------------------------------------------

def sud_kejs(imja, kejs, src, subj_s, subj_p, koren, bystro=False):
    tip = kejs['tip']
    if tip == 's-replay':
        if subj_s is None:
            return ('KRASNO', 'SKRIPT_OTSUTSTVUET')
        prichina = sud_s_replay(subj_s, kejs, koren)
        return ('ok', None) if prichina is None else ('KRASNO', prichina)
    if tip == 's-svip':
        if subj_s is None:
            return ('KRASNO', 'SKRIPT_OTSUTSTVUET')
        prichina = sud_svip(subj_s, kejs, koren, bystro=bystro)
        return ('ok', None) if prichina is None else ('KRASNO', prichina)
    if tip == 'p-replay':
        if subj_p is None:
            return ('KRASNO', 'PROBA_OTSUTSTVUET')
        prichina = sud_p_replay(subj_p, kejs, koren)
        return ('ok', None) if prichina is None else ('KRASNO', prichina)
    if tip == 'struktura':
        prichina = sud_strukturu(kejs['podtip'], subj_s, src)
        return ('ok', None) if prichina is None else ('KRASNO', prichina)
    if tip == 'nositel':
        if kejs['podtip'] == 's':
            prichina = sud_s_replay((NOSITELI / 'ci-e2e-staryj.sh').read_bytes(), kejs, koren)
        else:
            prichina = sud_p_replay(NOSITELI / 'maestro_probe-staryj.py', kejs, koren)
        ozh = kejs['ozhidanie'].get('krasno')
        if prichina is None:
            return ('KRASNO', 'OZHIDALOS_KRASNO: старая реализация прошла батарею')
        if ozh and not prichina.startswith(ozh):
            return ('KRASNO', 'INAJA_PRICHINA: %s (ожидалась %r)' % (prichina, ozh))
        return ('ok', prichina)
    return ('KRASNO', 'неизвестный tip')


# ── прогон --------------------------------------------------------------------

def progona(subj_s, subj_p, src, koren, pechatat=True):
    krasnye = 0
    for imja, kejs in src['kejsy'].items():
        ishod, prichina = sud_kejs(imja, kejs, src, subj_s, subj_p, koren)
        if ishod == 'KRASNO':
            krasnye += 1
        if pechatat:
            if ishod == 'ok':
                print('CASE %s ok' % imja)
            else:
                print('CASE %s KRASNO (%s)' % (imja, prichina))
    return (0 if krasnye == 0 else 1)


def main():
    ap = argparse.ArgumentParser(add_help=False)
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--stabs', action='store_true')
    ap.add_argument('--matrix', action='store_true')
    ap.add_argument('--repo')
    ap.add_argument('--schet')
    args, _ = ap.parse_known_args()

    try:
        src = load_source()
    except (RuntimeError, OSError, KeyError, ValueError) as e:
        return oshibka_orakula(str(e))

    if args.schet:
        if args.schet == 'kejsy':
            print(len(src['kejsy']))
        elif args.schet == 'staby':
            print(len(src['stab_vhod']))
        elif args.schet == 'svjazi':
            print(sum(len(v) for v in src['stab_vhod'].values()))
        elif args.schet == 'modeli':
            print(len([p for p in MODEL.iterdir() if p.is_file()]))
        elif args.schet == 'nositeli':
            print(len([p for p in NOSITELI.iterdir() if p.is_file()]))
        else:
            return oshibka_orakula('неизвестный --schet: %s' % args.schet)
        return 0

    model_s = (MODEL / 'ci-e2e.sh').read_bytes()
    model_p = MODEL / 'maestro_probe.py'
    live_p = LIVE_P if LIVE_P.is_file() else None

    koren = Path(tempfile.mkdtemp(prefix='baterija995r-'))
    try:
        if args.model:
            return progona(model_s, model_p, src, koren)
        if args.stabs or args.matrix:
            rc_kontrol = progona(model_s, model_p, src, koren)
            if rc_kontrol != 0:
                print('ORACLE_TAMPERED: контроль моделей не зелёный', file=sys.stderr)
                return 2
            svjazi_itog = 0
            zhivye = 0
            for imja_staba in sorted(src['stab_vhod']):
                if imja_staba in S_STABY:
                    subj_s2 = S_STABY[imja_staba](model_s.decode('utf-8')).encode('utf-8')
                    subj_p2 = model_p
                else:
                    subj_p2 = P_STABY[imja_staba](model_p.read_text(encoding='utf-8'))
                    subj_s2 = model_s
                for vhod in src['stab_vhod'][imja_staba]:
                    ishod, prichina = sud_kejs(vhod, src['kejsy'][vhod], src,
                                               subj_s2, subj_p2, koren, bystro=True)
                    if ishod == 'KRASNO':
                        print('STAB %s %s KRASEN' % (imja_staba, vhod))
                        svjazi_itog += 1
                    else:
                        print('STAB %s %s ZHIV (%s/%s)' % (imja_staba, vhod, ishod, prichina))
                        zhivye += 1
            print('SVJAZI %d' % svjazi_itog)
            print('zhivykh %d' % zhivye)
            return 0 if zhivye == 0 else 1

        repo = args.repo or os.environ.get('MOB_REPO')
        subj_s = None
        if repo:
            put = Path(repo) / SUBJECT_REL
            if put.is_file():
                subj_s = put.read_bytes()
            else:
                print('SUBJECT_ABSENT: %s не найден; входы ниже красные' % put, file=sys.stderr)
        else:
            print('SUBJECT_ABSENT: нет --repo/MOB_REPO; зелень без субъекта невозможна',
                  file=sys.stderr)
        if subj_s is None:
            for imja in src['kejsy']:
                print('CASE %s KRASNO (SUBJECT_ABSENT)' % imja)
            return 1
        return progona(subj_s, live_p, src, koren)
    finally:
        shutil.rmtree(str(koren), ignore_errors=True)


if __name__ == '__main__':
    sys.exit(main())
