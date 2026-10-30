#!/usr/bin/env bash
# 150 (prichinnyy-zamer-obryva): причинный замер обрыва эмулятора экранного
# работника. Основа — §10 verdicts/consultant/obryv-emulyatora-mob-astra-v1.md
# и п.2 решения владельца 2026-10-26 (docs/owner/2026-10-26-obryv-emulyatora-v2.md):
# измерение В ТОМ ЖЕ прогоне, ДО остановки/повтора, ограниченный объём, redacted.
#
# Подпрограммы (вызывается ЭКРАННЫМ РАБОТНИКОМ из .github/workflows/mobile.yml,
# обёртка 150: старт ДО экранного шага, сбор ПОСЛЕ — см. contract 150):
#   start  — системный снимок + фоновый сэмплер (setsid, pidfile в spool);
#   sbor   — стоп сэмплера, ГЕЙТ по канонической сигнатуре обрыва adb (141)
#            в output_namespace РАБОТНИКА (после wipe повторной попытки —
#            зелёный/восстановленный итог не публикует), сбор ограниченного
#            redacted артефакта.
#   --sempler — внутренний цикл сэмплера (не для прямого вызова).
#
# Инварианты 150:
#   - замер НИКОГДА не меняет итог job: start/sbor выходят 0, собственные
#     отказы — именованные маркеры в stderr/stdout (ловец — батарея 150 и
#     пункт ревьюеру «живой красный run с артефактом»), НЕ rc;
#   - сэмплер ЛЕГКИЙ: <=1 Гц локальных чтений (/proc, cgroup, pgrep,
#     `adb devices` — без транспорта устройства), <=1 adb-пробы гостя в 15 с
#     (boot_id/adbd/uptime, timeout 3 c, только при state=device); НИКАКИХ
#     bugreport/dumpsys/полных дампов;
#   - редакция секретов (ghp_/github_pat_/AKIA/PRIVATE KEY/Bearer) по ВСЕМ
#     текстам артефакта; env не публикуется (в снимок идут только метки
#     GITHUB_RUN_ID/GITHUB_RUN_ATTEMPT/GITHUB_JOB/RUNNER_NAME);
#   - объём: сэмплер <=2700 строк и <=512 KiB, каждый файл артефакта
#     <=512 KiB, артефакт целиком <=2 MiB, хвосты tail -n 200/400;
#   - гейт судит ТОЛЬКО output_namespace работника: grep по всему воркспейсу
#     или чужим каталогам — обманная широта (класс 141, Astra §9).
set -u

ZAMER_VERSIJA='150/1'
SIGNATURY_RE='device offline|adb: device not found|device [^ ]* not found|DeviceServerDiedException'
KLETKA_SEMPLEROV_MAKS=2700
FAJL_MAKS_BAJT=524288
ARTEFAKT_MAKS_BAJT=2097152
PROBA_KAZHDYH=15
PROBA_TIMEOUT_S=3

ubyto() { printf '%s\n' "$*" >&2; }

# ---- аргументы ----------------------------------------------------------------
EKRAN="${EKRAN:-}" NS="${NS:-}" SERIAL="${SERIAL:-}" SPOOL="${SPOOL:-}" OUT="${OUT:-}"
while [ $# -gt 0 ]; do
  case "$1" in
    start|sbor) KMD="$1"; shift; continue ;;
    --sempler) KMD='sempler'; shift; continue ;;
    --ekran) EKRAN="$2"; shift 2 ;;
    --ns) NS="$2"; shift 2 ;;
    --serial) SERIAL="$2"; shift 2 ;;
    --spool) SPOOL="$2"; shift 2 ;;
    --out) OUT="$2"; shift 2 ;;
    *) ubyto "ZAMER_ARG_NEIZVESTEN: $1"; [ "$KMD" = sbor ] && exit 0; exit 0 ;;
  esac
done
KMD="${KMD:-}"

cg_katalog() {
  # каталог cgroup раннера: явный ZAMER_CGROUP_DIR (проверяемость батареи),
  # иначе v2-путь из /proc/self/cgroup, иначе /sys/fs/cgroup
  if [ -n "${ZAMER_CGROUP_DIR:-}" ]; then printf '%s' "$ZAMER_CGROUP_DIR"; return 0; fi
  local rel
  rel="$(awk -F: '$1==0{print $3; exit}' /proc/self/cgroup 2>/dev/null)"
  if [ -n "$rel" ] && [ -d "/sys/fs/cgroup$rel" ]; then printf '/sys/fs/cgroup%s' "$rel"; return 0; fi
  printf '/sys/fs/cgroup'
}

chitaj() { # файл-значение-по-умолчанию
  if [ -r "$1" ]; then cat "$1" 2>/dev/null; else printf '%s' "$2"; fi
}

pole() { # fajl regex umolchanie: poslednij token pervoj sovpavshej stroki, bez 'kljuch='
  local v
  v="$(grep -m1 -E "$2" "$1" 2>/dev/null | awk '{print $NF}' | sed -E 's/^.*=//' | tr -d '\r')"
  [ -n "$v" ] || v="$3"
  printf '%s' "$v"
}

pole_avg10() { # fajl: avg10 iz stroki 'some avg10=X ...' (psi)
  local v
  v="$(grep -m1 'some avg10' "$1" 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i ~ /^avg10=/){sub(/^avg10=/,"",$i); print $i; exit}}' | tr -d '\r')"
  [ -n "$v" ] || v='-'
  printf '%s' "$v"
}

redakt_fajl() { # редакция секретов в одном текстовом файле
  sed -i -E \
    -e 's/ghp_[A-Za-z0-9]{16,}/«REDACTED:ghp»/g' \
    -e 's/github_pat_[A-Za-z0-9_]{16,}/«REDACTED:pat»/g' \
    -e 's/AKIA[0-9A-Z]{16}/«REDACTED:aws»/g' \
    -e 's/-----BEGIN [A-Z ]*PRIVATE KEY-----/«REDACTED:key»/g' \
    -e 's/Bearer [A-Za-z0-9._~+\/-]{16,}/«REDACTED:bearer»/g' \
    "$1" 2>/dev/null || true
}

ogranych() { # файл-потолок-байт: обрезать с маркером, если длиннее
  local f="$1" potolok="$2" razmer
  [ -f "$f" ] || return 0
  razmer="$(stat -c%s "$f" 2>/dev/null || echo 0)"
  if [ "$razmer" -gt "$potolok" ]; then
    head -c "$potolok" "$f" > "$f.obrez" 2>/dev/null && mv "$f.obrez" "$f"
    printf '\n[OBRIZANO: potolok %d bajt]\n' "$potolok" >> "$f"
  fi
}

adb_server_pid() { pgrep -f 'adb.*fork-server' 2>/dev/null | head -1; }

# ---- start ----------------------------------------------------------------------
if [ "$KMD" = start ]; then
  PORT_IZ_SERIAL="${SERIAL#emulator-}"
  EMU_RE="qemu-system-x86_64.*-port $PORT_IZ_SERIAL"
  mkdir -p "$SPOOL" 2>/dev/null || { ubyto 'ZAMER_START_OTKAZ: spool ne sozdajotsja'; exit 0; }
  CG="$(cg_katalog)"
  {
    printf 'zamer-versija=%s\n' "$ZAMER_VERSIJA"
    printf 'utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'ekran=%s serial=%s ns=%s\n' "$EKRAN" "$SERIAL" "$NS"
    printf 'run_id=%s attempt=%s job=%s runner=%s\n' \
      "${GITHUB_RUN_ID:--}" "${GITHUB_RUN_ATTEMPT:--}" "${GITHUB_JOB:--}" "${RUNNER_NAME:--}"
    printf 'nproc=%s\n' "$(nproc 2>/dev/null || echo '-')"
    printf 'uptime=%s\n' "$(uptime 2>/dev/null || echo '-')"
    printf 'free_m=%s\n' "$(free -m 2>/dev/null | awk 'NR==2{print $2" total "$7" avail"}')"
    printf 'netns=%s\n' "$(readlink /proc/self/ns/net 2>/dev/null || echo '-')"
    printf 'adb_server_start=%s\n' "$(adb_server_pid || echo '-')"
    printf 'cgroup=%s\n' "$CG"
    printf 'emu_re=%s\n' "$EMU_RE"
  } > "$SPOOL/sistemnyj-snimok.txt"
  # сэмплер: отдельная сессия — переживает выход шага; pidfile для стопа
  setsid env SEMPLER_EMU_RE="$EMU_RE" SEMPLER_SERIAL="$SERIAL" \
    SEMPLER_SPOOL="$SPOOL" SEMPLER_CG="$CG" bash "$0" --sempler \
    > "$SPOOL/sempler.log" 2>&1 < /dev/null &
  printf '%s\n' "$!" > "$SPOOL/pid"
  printf 'ZAMER_START: sempler zapushchen (ekran %s, serial %s)\n' "$EKRAN" "$SERIAL"
  exit 0
fi

# ---- sempler (внутренний) --------------------------------------------------------
if [ "$KMD" = sempler ]; then
  EMU_RE="${SEMPLER_EMU_RE:-}" SERIAL="${SEMPLER_SERIAL:-}" SPOOL="${SEMPLER_SPOOL:-}" CG="${SEMPLER_CG:-}"
  trap 'exit 0' TERM INT
  n=0
  boot_id='-' adbd='-' guptime='-'
  printf '# ts epoch | emu_pid | emu_state | adb_state | boot_id | adbd_pid | guest_uptime_s | cg_mem_current | cg_ev_high | cg_ev_max | cg_ev_oom | cg_cpu_throttled_nr | cg_cpu_throttled_us | psi_cpu_avg10 | psi_mem_avg10 | host_memavail_kib\n' \
    > "$SPOOL/sampler.tsv"
  while :; do
    n=$((n + 1))
    ts="$(date +%s 2>/dev/null || echo 0)"
    pids="$(pgrep -f "$EMU_RE" 2>/dev/null | sort -n | tr '\n' ',')"
    [ -n "$pids" ] || pids='-'
    stany=''
    if [ "$pids" != '-' ]; then
      for p in $(pgrep -f "$EMU_RE" 2>/dev/null | sort -n); do
        s="$(awk '{print $3; exit}' "/proc/$p/stat" 2>/dev/null)" || s='?'
        stany="$stany${s:+$s,}"
      done
    fi
    [ -n "$stany" ] || stany='-'
    adb_state="$(adb devices 2>/dev/null | awk -v s="$SERIAL" '$1==s{print $2}')"
    [ -n "$adb_state" ] || adb_state='-'
    if [ $((n % PROBA_KAZHDYH)) -eq 0 ] && [ "$adb_state" = device ]; then
      otv="$(timeout "$PROBA_TIMEOUT_S" adb -s "$SERIAL" shell \
        'getprop ro.boot_id; pidof adbd; cat /proc/uptime' 2>/dev/null | tr -d '\r')"
      if [ -n "$otv" ]; then
        b="$(printf '%s\n' "$otv" | sed -n '1p')"; a="$(printf '%s\n' "$otv" | sed -n '2p')"; u="$(printf '%s\n' "$otv" | sed -n '3p' | awk '{print $1}')"
        [ -n "$b" ] && boot_id="$b"
        [ -n "$a" ] && adbd="$a"
        [ -n "$u" ] && guptime="$u"
      fi
    fi
    cg_mem="$(chitaj "$CG/memory.current" -)"
    cg_hi="$(pole "$CG/memory.events" '^high[[:space:]]' '-')"
    cg_mx="$(pole "$CG/memory.events" '^max[[:space:]]' '-')"
    cg_oom="$(pole "$CG/memory.events" '^oom[[:space:]]' '-')"
    cg_tn="$(pole "$CG/cpu.stat" '^nr_throttled[[:space:]]' '-')"
    cg_tu="$(pole "$CG/cpu.stat" '^throttled_usec[[:space:]]' '-')"
    psi_c="$(pole_avg10 "$CG/cpu.pressure")"
    psi_m="$(pole_avg10 "$CG/memory.pressure")"
    host_av="$(awk '/^MemAvailable:/{print $2; exit}' /proc/meminfo 2>/dev/null)"; [ -n "$host_av" ] || host_av='-'
    printf '%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n' \
      "$ts" "$pids" "$stany" "$adb_state" "$boot_id" "$adbd" "$guptime" \
      "$cg_mem" "$cg_hi" "$cg_mx" "$cg_oom" "$cg_tn" "$cg_tu" "$psi_c" "$psi_m" "$host_av" \
      >> "$SPOOL/sampler.tsv"
    if [ "$n" -ge "$KLETKA_SEMPLEROV_MAKS" ]; then
      printf '\n[SEMPLER OSTANOVLEN: potolok %s strok]\n' "$KLETKA_SEMPLEROV_MAKS" >> "$SPOOL/sampler.tsv"
      break
    fi
    razmer="$(stat -c%s "$SPOOL/sampler.tsv" 2>/dev/null || echo 0)"
    if [ "$razmer" -gt "$FAJL_MAKS_BAJT" ]; then
      printf '\n[SEMPLER OSTANOVLEN: potolok %d bajt]\n' "$FAJL_MAKS_BAJT" >> "$SPOOL/sampler.tsv"
      break
    fi
    sleep 1
  done
  exit 0
fi

# ---- sbor -----------------------------------------------------------------------
if [ "$KMD" = sbor ]; then
  PORT_IZ_SERIAL="${SERIAL#emulator-}"
  # (1) стоп сэмплера — до всего остального
  if [ -f "$SPOOL/pid" ]; then
    spid="$(cat "$SPOOL/pid" 2>/dev/null)"
    if [ -n "$spid" ] && kill -0 "$spid" 2>/dev/null; then
      kill -TERM "$spid" 2>/dev/null || true
      for _ in 1 2 3 4 5 6 7 8 9 10; do
        kill -0 "$spid" 2>/dev/null || break
        sleep 0.2 2>/dev/null || sleep 1
      done
      kill -0 "$spid" 2>/dev/null && { kill -KILL "$spid" 2>/dev/null || true; ubyto 'ZAMER_SEMPLER_ZHIV: pribyl posle TERM i KILL'; }
    fi
  else
    ubyto 'ZAMER_SEMPLER_PIDFILE_NET: start ne ispolnjalsja?'
  fi
  # (2) ГЕЙТ: артефакт публикуется ТОЛЬКО при сигнатуре обрыва в ns работника
  if [ ! -d "$NS" ]; then
    printf 'ZAMER_SBOR: ns %s net — artefakt ne publikuetsja\n' "$NS"
    exit 0
  fi
  sovpadenija="$(grep -rlE "$SIGNATURY_RE" "$NS" 2>/dev/null | head -20)"
  if [ -z "$sovpadenija" ]; then
    printf 'ZAMER_SBOR: signatur obryva v %s net — artefakt ne publikuetsja\n' "$NS"
    exit 0
  fi
  # (3) сбор: собственные отказы — маркеры, rc всегда 0 (итог job не меняем)
  {
    mkdir -p "$OUT"
    cp "$SPOOL/sampler.tsv" "$OUT/sampler.tsv" 2>/dev/null || ubyto 'ZAMER_SBOR_OTKAZ: sampler.tsv ne skopirovan'
    cp "$SPOOL/sistemnyj-snimok.txt" "$OUT/sistemnyj-snimok.txt" 2>/dev/null || ubyto 'ZAMER_SBOR_OTKAZ: sistemnyj-snimok ne skopirovan'
    # adb-сервер и устройства СЕЙЧАС (смена против старта — различитель Astra §5.4)
    pid_v_starte="$(pole "$OUT/sistemnyj-snimok.txt" '^adb_server_start' '-')"
    pid_sejchas="$(adb_server_pid || echo '-')"
    {
      printf 'adb_server_start=%s\n' "$pid_v_starte"
      printf 'adb_server_sbor=%s\n' "$pid_sejchas"
      if [ "$pid_v_starte" != "$pid_sejchas" ] && [ "$pid_v_starte" != '-' ] && [ "$pid_sejchas" != '-' ]; then
        printf 'ADB_SERVER_SMENILSJA: %s -> %s\n' "$pid_v_starte" "$pid_sejchas"
      fi
      printf 'adb_devices_sejchas:\n'
      adb devices -l 2>/dev/null || printf 'NEVERSJA: adb devices\n'
    } > "$OUT/adb-server-i-ustrojstva.txt"
    # финальные пробы гостя (могут быть недоступны — честный маркер, не пустота)
    if timeout "$PROBA_TIMEOUT_S" adb -s "$SERIAL" shell getprop ro.boot_id \
        > "$OUT/boot_id_final.txt" 2>&1; then
      : 
    else
      printf 'NEVERSJA: ustrojstvo %s ne otvechaet (boot_id na moment sbora nedostupen — sm. poslednij iz sampler.tsv)\n' "$SERIAL" > "$OUT/boot_id_final.txt"
    fi
    if timeout "$PROBA_TIMEOUT_S" adb -s "$SERIAL" logcat -d -t 200 \
        > "$OUT/logcat.txt" 2>&1; then
      :
    else
      printf 'NEVERSJA: logcat na moment sbora nedostupen (obryv transporta) — poslednij zhivoj Sm. logcat-kolco nizhe\n' > "$OUT/logcat.txt"
    fi
    # хвосты журналов эмулятора воркспейса (поколения S: emulator-*-p*.log)
    : > "$OUT/emulator-log-hvost.txt"
    schet=0
    for f in $(ls -t emulator-*.log 2>/dev/null | head -2); do
      schet=$((schet + 1))
      printf '== %s (poslednie 200 strok) ==\n' "$f" >> "$OUT/emulator-log-hvost.txt"
      tail -n 200 "$f" 2>/dev/null >> "$OUT/emulator-log-hvost.txt" || ubyto "ZAMER_SBOR_OTKAZ: hvost $f"
    done
    [ "$schet" -gt 0 ] || printf 'NET emulator-*.log v vorkspejse\n' >> "$OUT/emulator-log-hvost.txt"
    # найденные сигнатуры (файл:строка, <=20)
    grep -rnE -m 20 "$SIGNATURY_RE" "$NS" 2>/dev/null > "$OUT/signatury.txt" || true
    # редакция секретов по ВСЕМ текстам артефакта
    redakcij=0
    for f in "$OUT"/*; do
      case "$f" in *.tsv) ;; *) redakt_fajl "$f" ;; esac
    done
    # sampler.tsv — тоже редакровать (boot_id не секрет, но правило одно)
    redakt_fajl "$OUT/sampler.tsv"
    # границы объёма
    for f in "$OUT"/*; do ogranych "$f" "$FAJL_MAKS_BAJT"; done
    razmer_itog="$(du -sb "$OUT" 2>/dev/null | awk '{print $1}')"
    if [ "${razmer_itog:-0}" -gt "$ARTEFAKT_MAKS_BAJT" ]; then
      ubyto 'ZAMER_SBOR_OTKAZ: artefakt vyshe potolka — rezh logcat/emulator hvosty'
      ogranych "$OUT/logcat.txt" 262144
      ogranych "$OUT/emulator-log-hvost.txt" 262144
    fi
    {
      printf 'reshenie=publikuem: signatura obryva v ns rabotnika\n'
      printf 'ekran=%s serial=%s ns=%s\n' "$EKRAN" "$SERIAL" "$NS"
      printf 'utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
      printf 'run_id=%s attempt=%s\n' "${GITHUB_RUN_ID:--}" "${GITHUB_RUN_ATTEMPT:--}"
      printf 'zagolovok_adb_server=%s\n' "$pid_v_starte"
      printf 'zamer-versija=%s\n' "$ZAMER_VERSIJA"
    } > "$OUT/itog.txt"
    printf 'ZAMER_SBOR: artefakt sobran v %s\n' "$OUT"
  } || ubyto 'ZAMER_SBOR_OTKAZ: sbor ne zavershilsja (sm. markery vyshe)'
  exit 0
fi

ubyto "ZAMER_KMD_NEIZVESTEN: ${KMD:-pusto}"
exit 0
