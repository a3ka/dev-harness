#!/usr/bin/env bash
# android-e2e на серверном раннере (995 v+1): единственный владелец эмулятора и
# повтора — этот скрипт. Проверка памяти → AVD прогона → СВОЙ эмулятор без окна →
# установка release-APK → полный набор Maestro. При красном наборе и канонической
# сигнатуре обрыва adb-транспорта в выводе ТЕКУЩЕЙ попытки: диагностика ДО
# остановки → остановка ТОЛЬКО собственного эмулятора по его PID → новый
# эмулятор + готовность + установка → ровно ОДИН повтор полного набора.
# Готовность и повтор — только при живом owned PID новой инкарнации: kill -0
# перед каждым состояние-меняющим вызовом инкарнации (настройки, установка,
# набор); мёртвый owned PID при отвечающем serial (чужой/старый эмулятор) —
# именованный отказ.
# Второй красный — итоговый красный (RECOVERED/EXHAUSTED), третьей попытки нет;
# продуктовый отказ не повторяется и не стирается. Общий сервер adb и чужие
# процессы не трогаются: ни широких завершателей по маске, ни разрыва сессий
# сервера, ни переподключения офлайн-устройства — только собственный PID.
# Вызов из mobile/: bash scripts/ci-e2e.sh <путь к APK>
set -euo pipefail
APK="$1"
AVD="ci-${GITHUB_RUN_ID:-local}-${GITHUB_RUN_ATTEMPT:-1}"
PORT=5560
SERIAL="emulator-$PORT"
IMAGE="system-images;android-36;google_apis;x86_64"
MIN_FREE_GB=8
KANON='device offline|adb: device not found|device [^ ]* not found|DeviceServerDiedException'
PODHOD_MAX=2

avail=$(awk '/MemAvailable/ {print int($2/1048576)}' /proc/meminfo)
if [ "$avail" -lt "$MIN_FREE_GB" ]; then
  echo "ОТКАЗ: на станции свободно ${avail} ГБ < ${MIN_FREE_GB} ГБ — эмулятор не запускаю" >&2
  exit 1
fi

AVDM="$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager"
avdmanager() { "$AVDM" "$@"; }
ADB="adb"
EMU_PID=""
EMU_LOG=""
POKOLENIE=0

# Остановка собственного эмулятора: только PID, полученный при запуске; TERM,
# ограниченное ожидание выхода, при зависании — KILL того же PID. Чужие процессы
# и общий adb-сервер не затрагиваются.
ostanovit_svoyo() {
  if [ -n "$EMU_PID" ] && kill -0 "$EMU_PID" 2>/dev/null; then
    kill "$EMU_PID" 2>/dev/null || true
    local i=0
    while kill -0 "$EMU_PID" 2>/dev/null && [ "$i" -lt 10 ]; do
      i=$((i + 1))
      sleep 1
    done
    kill -9 "$EMU_PID" 2>/dev/null || true
  fi
  EMU_PID=""
}

# Жизнь новой инкарнации: owned PID обязан быть жив перед каждым
# состояние-меняющим вызовом инкарнации (настройки, установка, набор) — без
# единого вызова наружу между проверкой и действием. Мёртвый owned PID при
# отвечающем serial (чужой/старый эмулятор на порту) новой инкарнацией не
# считается: успех adb по serial его не заменяет.
zhiv_svoyo() {
  if [ -z "$EMU_PID" ] || ! kill -0 "$EMU_PID" 2>/dev/null; then
    echo "ОТКАЗ: owned PID эмулятора мёртв (поколение ${POKOLENIE}, pid ${EMU_PID:-нет}) — новая инкарнация не подтверждена, чужой/старый процесс на порту ${SERIAL} не принимается" >&2
    return 1
  fi
}

cleanup() {
  trap - EXIT
  ostanovit_svoyo
  avdmanager delete avd -n "$AVD" >/dev/null 2>&1 || true
}

zapusti_emulator() {
  POKOLENIE=$((POKOLENIE + 1))
  EMU_LOG="emulator-$AVD-p${POKOLENIE}.log"
  emulator -avd "$AVD" -port "$PORT" -no-window -no-audio -no-boot-anim -no-snapshot \
    -gpu swiftshader_indirect >"$EMU_LOG" 2>&1 &
  EMU_PID=$!
}

wait_stable() {
  local ok=0 i
  for i in $(seq 1 40); do
    if [ "$($ADB -s "$SERIAL" get-state 2>/dev/null)" = "device" ] &&
       $ADB -s "$SERIAL" shell pm path com.complior.mobile >/dev/null 2>&1; then
      ok=$((ok + 1)); [ "$ok" -ge 3 ] && return 0
    else
      ok=0
    fi
    sleep 2
  done
  echo "ОТКАЗ: эмулятор $SERIAL не стабилизировался (adb offline, поколение $POKOLENIE)" >&2
  return 1
}

# Готовность инкарнации: загрузка (реальная граница wall-clock 390 с И потолок
# итераций), настройки анимаций, установка APK с проверкой итога, стабильность
# транспорта. Каждый отказ — именованный, Maestro не запускается.
gotovnost() {
  local deadline=$((SECONDS + 390)) i=0 zagruzilsja=1 s
  zhiv_svoyo || return 1
  $ADB -s "$SERIAL" wait-for-device
  while [ "$($ADB -s "$SERIAL" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]; do
    i=$((i + 1))
    if [ "$i" -ge 130 ] || [ "$SECONDS" -ge "$deadline" ]; then zagruzilsja=0; break; fi
    sleep 3
  done
  if [ "$zagruzilsja" != "1" ]; then
    echo "ОТКАЗ: эмулятор не загрузился за 390 с (поколение $POKOLENIE)" >&2
    return 1
  fi
  for s in window_animation_scale transition_animation_scale animator_duration_scale; do
    zhiv_svoyo || return 1
    $ADB -s "$SERIAL" shell settings put global "$s" 0
  done
  zhiv_svoyo || return 1
  $ADB -s "$SERIAL" install -r "$APK" >/dev/null || {
    echo "ОТКАЗ: установка APK не удалась (поколение $POKOLENIE)" >&2
    return 1
  }
  wait_stable
}

# Причинный замер (§10 консультации Astra): снимок ДО набора и при отказе —
# до любой остановки. Недоступное поле честно помечается, отсутствие данных не
# превращается в пустой «успешный» журнал.
diag_snapshot() {   # $1=каталог, $2=фаза: boot|otkaz, $3=номер попытки
  local d="$1" faza="$2" n="$3" mono ost
  mkdir -p "$d"
  read -r mono ost _ < /proc/uptime || mono='<недоступно>'
  {
    echo "== ${faza} attempt=${n} pokolenie=${POKOLENIE} serial=${SERIAL} avd=${AVD} port=${PORT}"
    echo "utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "monotonic=${mono}"
    echo "run=${GITHUB_RUN_ID:-local} github_attempt=${GITHUB_RUN_ATTEMPT:-1} local_attempt=${n}"
    echo "apk=${APK##*/}"
    echo "emulator_pid=${EMU_PID:-net} emulator_log=${EMU_LOG}"
    echo "emulator_start_jiffies=$(awk '{print $22}' "/proc/${EMU_PID}/stat" 2>/dev/null || echo '<недоступно>')"
    echo "netns=$(readlink "/proc/$$/ns/net" 2>/dev/null || echo '<недоступно>')"
    echo "adb_server=$(ps -eo pid,etimes,args 2>/dev/null | grep -m1 '[a]db.*fork-server' || echo '<недоступно>')"
    echo "mem_available_kb=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)"
    echo "cgroup_memory_current=$(cat /sys/fs/cgroup/memory.current 2>/dev/null || echo '<недоступно>')"
    echo "cgroup_memory_events=$(cat /sys/fs/cgroup/memory.events 2>/dev/null || echo '<недоступно>')"
    echo "cgroup_cpu_stat=$(cat /sys/fs/cgroup/cpu.stat 2>/dev/null || echo '<недоступно>')"
    echo "psi_cpu=$(cat /sys/fs/cgroup/cpu.pressure 2>/dev/null || echo '<недоступно>')"
    echo "psi_memory=$(cat /sys/fs/cgroup/memory.pressure 2>/dev/null || echo '<недоступно>')"
    echo "psi_io=$(cat /sys/fs/cgroup/io.pressure 2>/dev/null || echo '<недоступно>')"
    echo "psi_host_cpu=$(cat /proc/pressure/cpu 2>/dev/null || echo '<недоступно>')"
    echo "guest_boot_id=$($ADB -s "$SERIAL" shell cat /proc/sys/kernel/random/boot_id 2>/dev/null | tr -d '\r' || echo '<недоступно>')"
    echo "adbd_pid=$($ADB -s "$SERIAL" shell pidof adbd 2>/dev/null | tr -d '\r' || echo '<недоступно>')"
  } >>"$d/manifest.txt"
  $ADB devices -l >"$d/adb-devices.txt" 2>/dev/null || printf '<adb недоступен>\n' >"$d/adb-devices.txt"
  if [ "$faza" = "boot" ]; then
    $ADB -s "$SERIAL" shell logcat -d -t 200 >"$d/logcat-do.txt" 2>&1 || printf '<logcat недоступен до набора>\n' >"$d/logcat-do.txt"
  else
    $ADB -s "$SERIAL" shell logcat -d -t 200 >"$d/logcat-posle.txt" 2>&1 || printf '<logcat недоступен: транспорт>\n' >"$d/logcat-posle.txt"
  fi
  if [ -f "$EMU_LOG" ]; then cp "$EMU_LOG" "$d/emulator.log"; fi
}

NABOR_RC=0
zapusk_nabora() {   # $1 = номер попытки; полный набор Maestro в свой каталог
  local n="$1"
  rm -rf "podhod-$n/test" "podhod-$n/report.xml" "podhod-$n/maestro.log"
  mkdir -p "podhod-$n/test"
  set +e
  maestro --device "$SERIAL" test --format junit --output "podhod-$n/report.xml" \
    --test-output-dir "podhod-$n/test" .maestro >"podhod-$n/maestro.log" 2>&1
  NABOR_RC=$?
  set -e
}

# Право на повтор (995 v3, живой формат Maestro): тело JUnit-провала при обрыве
# транспорта — «Unknown error», каноническая сигнатура живёт в per-flow
# артефактах упавшего флоу (commands.json/logs его папки в test-вывод). Набор
# транспортный ⟺ (а) сигнатура есть в артефактах ТЕКУЩЕЙ попытки (её журнал,
# её JUnit, её test-вывод — не эхо, не прошлые попытки, не diagnostics) И
# (б) КАЖДЫЙ упавший testcase JUnit либо сам несёт сигнатуру в теле провала,
# либо сопоставлен РОВНО ОДНОЙ папке своего флоу (живое правило Maestro ниже)
# и сигнатура есть в ЕЁ commands.json или logs/maestro.log. Упавший флоу без
# сигнатуры в своих артефактах (продуктовая неудача, «Unknown error» без
# свидетеля), отсутствующая, переименованная или задвоенная папка — продуктовый
# отказ: повтор не выполняется, красное не стирается (fail-closed на смешанном
# наборе).

# Живое правило Maestro (995 v3, серия 799bbc890, живой артефакт art5b:): имя
# каталога флоу = имя testcase с «/», заменёнными на «_» — единственное
# НАБЛЮДАЕМОЕ живое преобразование (testcase «999 tabs — четыре вкладки
# Start/Vorgänge/Schutz/Post и вторичный профиль» ↔ каталог «…Start_Vorgänge_
# Schutz_Post…»); прочие символы (пробелы, кириллица, «—», «→», глоб-
# метасимволы) сохраняются как есть. Помощник ОДИН для повтора и публикации:
# кандидат = ровно одно преобразованное имя; на stdout — все каталоги
# кандидата по меткам времени test-вывода; никакой ДРУГОЙ testcase набора не
# даёт тот же кандидат (дубль «/»-vs-«_») — иначе rc 1. Неизвестное живое
# преобразование иных символов ⇒ каталога нет ⇒ тот же fail-closed
# (консервативно: повтора нет, flows не публикуются).
imja_kataloga() {   # $1 = podhod-N; $2 = имя testcase; $3 = все имена testcase
  local d="$1" imja="$2" vse="$3" kandidat ts drugoe dubl
  kandidat=${imja//\//_}
  dubl=0
  while IFS= read -r drugoe; do
    [ -n "$drugoe" ] || continue
    if [ "${drugoe//\//_}" = "$kandidat" ] && [ "$drugoe" != "$imja" ]; then
      dubl=1
    fi
  done <<<"$vse"
  [ "$dubl" = 0 ] || return 1
  for ts in "$d"/test/*; do
    if [ -d "$ts/$kandidat" ]; then
      printf '%s\n' "$ts/$kandidat"
    fi
  done
}

transportnaya_prichina() {   # $1 = podhod-N; rc 0 = транспортная
  local d="$1" txt lenta imja blok katalog vse_imena spisok
  grep -rqE "$KANON" "$d/maestro.log" "$d/report.xml" "$d/test" 2>/dev/null || return 1
  [ -f "$d/report.xml" ] || return 0
  txt=$(tr -d '\n' <"$d/report.xml" | grep -oE '<testcase[^>]*>|<(failure|error)[^<]*' || true)
  [ -n "$txt" ] || return 0
  vse_imena=$(printf '%s\n' "$txt" | sed -n 's/.* name="\([^"]*\)".*/\1/p')
  imja=""
  while IFS= read -r lenta; do
    [ -n "$lenta" ] || continue
    case "$lenta" in
      '<testcase '*)
        imja=$(printf '%s' "$lenta" | sed -n 's/.* name="\([^"]*\)".*/\1/p') ;;
      '<failure'*|'<error'*)
        [ -n "$imja" ] || return 1
        blok="$lenta"
        if printf '%s\n' "$blok" | grep -qE "$KANON"; then
          imja=""
          continue
        fi
        spisok=$(imja_kataloga "$d" "$imja" "$vse_imena") || return 1
        katalog=""
        while IFS= read -r papka; do
          [ -n "$papka" ] || continue
          [ -z "$katalog" ] || return 1
          katalog="$papka"
        done <<<"$spisok"
        [ -n "$katalog" ] || return 1
        grep -qE "$KANON" "$katalog/commands.json" "$katalog/logs/maestro.log" 2>/dev/null || return 1
        imja="" ;;
    esac
  done <<<"$txt"
  return 0
}

# Публикация (995 v4): финальная попытка публикуется ЖИВОЙ структурой её
# test-вывода целиком — как v1 (каталог maestro-out = test-output-dir:
# report.xml, maestro.log и ВСЁ дерево «<метка-времени>/<флоу>/…» — commands.json,
# logs/, manifest.json, takeScreenshot/*.png). Вложенные кадры читают
# потребители публикации: P пробы (rglob по maestro-out: кадры pilot-first-run/
# pilot-welcome/pilot-restart вне diagnostics, иначе именованный отказ
# неполного evidence) и rehearsal-гейт продукта (рекурсивный поиск
# rehearsal-before/after.png в maestro-out, ровно один непустой каждого имени).
# Кадры/деревья НЕфинальных попыток не публикуются (как в v2/v3: первая попытка
# живёт только текстом в diagnostics/attempt-N/ и flows упавших); текстовая
# диагностика ВСЕХ попыток — в maestro-out/diagnostics; просроченные артефакты
# публикация стирает. Форма test-вывода не переупаковывается: верхние файлы
# копируются файлами, деревья — деревьями (кадры байт-в-байт).
opublikovat() {   # $1 = номер финальной попытки
  local n="$1" d num f ts
  rm -rf maestro-out
  mkdir -p maestro-out/diagnostics
  if [ -f "podhod-$n/report.xml" ]; then
    cp "podhod-$n/report.xml" maestro-out/report.xml
  fi
  if [ -f "podhod-$n/maestro.log" ]; then
    cp "podhod-$n/maestro.log" maestro-out/maestro.log
  fi
  for ts in "podhod-$n"/test/*; do
    [ -e "$ts" ] || continue
    cp -R "$ts" maestro-out/
  done
  for d in podhod-*/diag; do
    [ -d "$d" ] || continue
    num=${d#podhod-}; num=${num%%/*}
    mkdir -p "maestro-out/diagnostics/attempt-$num/diag"
    cp "$d"/* "maestro-out/diagnostics/attempt-$num/diag/" 2>/dev/null || true
    if [ -f "podhod-$num/maestro.log" ]; then cp "podhod-$num/maestro.log" "maestro-out/diagnostics/attempt-$num/maestro.log"; fi
    if [ -f "podhod-$num/report.xml" ]; then cp "podhod-$num/report.xml" "maestro-out/diagnostics/attempt-$num/report.xml"; fi
    if [ -f "podhod-$num/test/commands.json" ]; then cp "podhod-$num/test/commands.json" "maestro-out/diagnostics/attempt-$num/test-commands.json"; fi
    opublikovat_potoki "$num"
  done
}

# Диагностика упавших флоу (995 v3, видимость причины живого формата): per-flow
# commands.json и logs/maestro.log ТОЛЬКО упавших флоу попытки — в
# diagnostics/attempt-N/flows/<имя>/. Папка флоу сопоставляется ТЕМ ЖЕ живым
# правилом Maestro (помощник imja_kataloga: «/»→«_», дубль «/»-vs-«_» и
# отсутствие папки — не публикуется). Прочие артефакты флоу (кадры, манифест)
# не публикуются: кадры нефинальных попыток наружу не выходят, объём
# публикации ограничен двумя текстовыми файлами на упавший флоу. Имя флоу с
# «/» заменяется на «∕» — выход за каталог публикации невозможен.
opublikovat_potoki() {   # $1 = номер попытки
  local num="$1" txt lenta imja bezop potok spisok vse_imena
  [ -f "podhod-$num/report.xml" ] || return 0
  txt=$(tr -d '\n' <"podhod-$num/report.xml" | grep -oE '<testcase[^>]*>|<(failure|error)[^<]*' || true)
  [ -n "$txt" ] || return 0
  vse_imena=$(printf '%s\n' "$txt" | sed -n 's/.* name="\([^"]*\)".*/\1/p')
  imja=""
  while IFS= read -r lenta; do
    [ -n "$lenta" ] || continue
    case "$lenta" in
      '<testcase '*)
        imja=$(printf '%s' "$lenta" | sed -n 's/.* name="\([^"]*\)".*/\1/p') ;;
      '<failure'*|'<error'*)
        [ -n "$imja" ] || continue
        bezop=${imja//\//∕}
        if spisok=$(imja_kataloga "podhod-$num" "$imja" "$vse_imena"); then
          while IFS= read -r potok; do
            [ -n "$potok" ] || continue
            if [ -d "$potok" ]; then
              mkdir -p "maestro-out/diagnostics/attempt-$num/flows/$bezop"
              if [ -f "$potok/commands.json" ]; then cp "$potok/commands.json" "maestro-out/diagnostics/attempt-$num/flows/$bezop/commands.json"; fi
              if [ -f "$potok/logs/maestro.log" ]; then cp "$potok/logs/maestro.log" "maestro-out/diagnostics/attempt-$num/flows/$bezop/maestro.log"; fi
            fi
          done <<<"$spisok"
        fi
        imja="" ;;
    esac
  done <<<"$txt"
}

trap cleanup EXIT
echo no | avdmanager create avd --force -n "$AVD" -k "$IMAGE" -d pixel_7 >/dev/null
sed -i 's/^hw.ramSize=.*/hw.ramSize=2048/' "$ANDROID_AVD_HOME/$AVD.avd/config.ini"
$ADB start-server >/dev/null

itog=0
n=1
zapusti_emulator
gotovnost || exit 1
while :; do
  rm -rf "podhod-$n"
  mkdir -p "podhod-$n"
  diag_snapshot "podhod-$n/diag" boot "$n"
  if [ "$n" -gt 1 ]; then
    zhiv_svoyo || {
      echo "ОТКАЗ: owned PID новой инкарнации мёртв непосредственно перед набором ${n} — Maestro не запускается, повтор не расходуется, итог попытки $((n - 1)) сохранён" >&2
      itog=1
      opublikovat "$((n - 1))"
      break
    }
  fi
  zapusk_nabora "$n"
  if [ "$NABOR_RC" -eq 0 ]; then
    if [ "$n" -gt 1 ]; then
      echo "RECOVERED: обрыв adb-транспорта попытки $((n-1)) пережит перезапуском собственного эмулятора; попытка ${n} зелёная" >&2
    fi
    opublikovat "$n"
    exit 0
  fi
  diag_snapshot "podhod-$n/diag" otkaz "$n"
  if [ "$n" -ge "$PODHOD_MAX" ]; then
    echo "EXHAUSTED: попытка ${n} красная (rc=${NABOR_RC}) — итог красный, третьей попытки нет" >&2
    itog=$NABOR_RC
    opublikovat "$n"
    break
  fi
  if ! transportnaya_prichina "podhod-$n"; then
    echo "ОТКАЗ продуктовый: попытка ${n} красная (rc=${NABOR_RC}) без транспортной причины — повтор не выполняется" >&2
    itog=$NABOR_RC
    opublikovat "$n"
    break
  fi
  echo "ПОВТОР: обрыв adb-транспорта попытки ${n} по канонической сигнатуре — диагностика сохранена, перезапуск собственного эмулятора, один повтор набора" >&2
  ostanovit_svoyo
  zapusti_emulator
  gotovnost || {
    echo "ОТКАЗ: перезапуск эмулятора не дал готовности (поколение $POKOLENIE)" >&2
    itog=1
    opublikovat "$n"
    break
  }
  n=$((n + 1))
done
exit "$itog"
