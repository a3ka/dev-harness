#!/usr/bin/env bash
# Красная/зелёная батарея 074 «серверная обвязка — единый источник в репо».
#
# ПРЕДМЕТ (инварианты контракта 074):
#   к1  user-установка сходится побайтно: ops/server/user/orch-loop →
#       ${OPS_SERVER_BIN_DST}/orch-loop, режим 755, sha256 == пин станции
#       (оракул — в памяти батареи, снят ДО вызова субъекта), умолчальный
#       путь назначения не трогается;
#   к1b user-перечитывание ПОСЛЕ записи (B3, адверсарий r2: tee без
#       перечитывания проходил батарею): ДВА канала порчи адресата
#       */orch-loop. (1) шины cp/cat/install в PATH (B1, адверсарий r1);
#       (2) СТРУКТУРНЫЙ — LD_PRELOAD-interposer korrupt_write_074.c,
#       собранный в скратче прогона: первый write-класс-вызов (write/
#       pwrite64/writev/fwrite/fwrite_unlocked/copy_file_range/sendfile/
#       sendfile64/syscall-номера) в дескриптор, открытый на запись по
#       пути */orch-loop, несёт испорченный байт — ЛЮБОЙ механизм
#       копирования (cp/cat/install/tee/dd/python/rsync, shell-редирект)
#       получает испорченную запись; счётчик испорченных записей — в
#       журнале ORCH074_CORRUPT_LOG (неинертность канала самодоказуема).
#       Честный субъект обязан отказать rc 1 «расхождение» с именем файла;
#       ленивый — даёт rc 0 и красен. Остаточный предел (назван, не
#       расширяется): rename-класс (mv внутри одной ФС не пишет байты) и
#       прямые сисколлы мимо PLT/syscall(2) у статически слинкованного
#       субъекта; для симуляции различение несут стаб s7 и канальные
#       пробы cp/cat/install/tee/dd/python3;
#   к2  verify на зелёном мире: все 9 адресатов == репо → rc 0 и строка
#       «сверка: 9/9»;
#   к3  verify на расхождении — ПАРАМЕТРИЗОВАНО по всем девяти адресатам:
#       каждый искажается по очереди (user-файл, root-файл, 7 юнитов) →
#       rc 1, stderr несёт «расхождение» и ИМЯ искажённого; субъект,
#       сверяющий одно имя из девяти, красен на остальных восьми пробах;
#   к4  euid-гард root-части: запуск под harness → rc 1, stderr «root-часть
#       требует euid 0», по швовым адресатам ничего не записано;
#   к5  копии в репо побайтно == станции (9 sha256-пинов, живой съём
#       2026-10-02); к5b — живая сверка с самой станцией, когда файлы
#       станции читаемы (в CI — пропуск с пометкой, не зелёное);
#   к6  ops/server/README.md несёт чек-строки инвентаря: 9 имён механизмов
#       и 13 тем (журналы, send-keys, гашение omp, маркер, вкл/выкл,
#       настройка станции);
#   к7  указатели: первая секция HANDOFF «ГДЕ МЫ» и раздел роли
#       «Автоперезапуск orch-loop…» содержат строки-указатели на
#       ops/server/README.md; строка-носитель orch_restart сохранена
#       побайтово; потолок роли 51200.
#
# Н-39 (привязки к входам — здесь, в коде, не в прозе контракта):
#   s1 «копирует без сверки» — sha256-проверка нейтрализована; наблюдаем на
#      входе к3: расхождение dst/репо (orch-ctx.timer искажён) — честный
#      предмет даёт rc 1 с именем файла, s1 молчит и даёт rc 0;
#   s2 «root-часть исполняется под harness» — euid-гард снят; наблюдаем на
#      входе к4: честный предмет отказывает без записей, s2 ставит
#      orch-peak в швовой адресат и возвращает rc 0;
#   s3 «тихая мутация байтов» — user-установка дописывает байт; наблюдаем
#      на входе к1: sha256 установленного orch-loop против пина в памяти;
#   s4 «неполная установка» — user-копирование пропущено; наблюдаем на
#      входе к1: установленного файла нет вовсе;
#   s5 «README без инвентаря» — документ-заглушка без чек-строк; вход к6;
#   s6 «указатели не приземлены» — HANDOFF/роль без строки-указателя; вход к7;
#   s7 «user скопировал, но не перечитал» — перечитывание sha256 в
#      user-ветви нейтрализовано; вход к1b: cp-шина портит запись —
#      честный субъект отказывает rc 1, s7 молчит и даёт rc 0.
#
# Семантика: rc 0 — честные клетки зелёные + все стабы пойманы + диффпроба
# зелёная; rc 1 — «предмет отсутствует» (г0, ДО реализации), любая красная
# клетка или живой стаб; rc 2 — нечем проверить.
# FIXSIM=1 (А-318) — честная симуляция install.sh в скратче обязана дать
# rc 0 ЦЕЛИКОМ; симуляция throwaway, в дереве репо её нет.
# LANDSIM=1 — дерево с УЖЕ приземлёнными указателями 9-10 (вердикт критика
# к1, блокирующая 1): батарея обязана дать rc 0 и ДО, и ПОСЛЕ реального
# приземления указателей — отрицательный мир s6 строится СРЕЗАНИЕМ
# строк-указателей из текущих документов, а не копированием «до приземления».
#
# Использование:
#   bash fixtures/ops_server/red_server_obvjazka_074.sh
#   FIXSIM=1 bash fixtures/ops_server/red_server_obvjazka_074.sh
#   LANDSIM=1 bash fixtures/ops_server/red_server_obvjazka_074.sh
#   OPS_ROOT=<дерево-субъекта> bash fixtures/ops_server/red_server_obvjazka_074.sh

set -uo pipefail


HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$(cd "$HERE/../.." && pwd)}"
OPS_ROOT="${OPS_ROOT:-$REPO_ROOT}"
SUBJ="$OPS_ROOT/ops/server/install.sh"
# Источник миров (зелёный мир, шов OPS_SERVER_SRC) — снапшот ДЕРЕВА БАТАРЕИ:
# батарея живёт в дереве, где ops/server-копии уже приземлены пачкой архитектора.
OPS_SRC="$REPO_ROOT/ops/server"

command -v sha256sum >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет sha256sum\n' >&2; exit 2; }
command -v python3  >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3\n'  >&2; exit 2; }

SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/ops074.XXXXXX")" || { printf 'ОТКАЗ: mktemp\n' >&2; exit 2; }
trap 'rm -rf "$SCRATCH"' EXIT

# ── структурный корруптор к1b (B3, адверсарий r2): исходник — в семье батареи,
# сборка — в скратче прогона (бинарник в репо не живёт). Нет компилятора —
# канал «любой механизм» мёртв, это НЕ зелёное: rc 2 NOT_IMPLEMENTED.
KORRUPT_SRC="$HERE/korrupt_write_074.c"
KORRUPT_SO="$SCRATCH/korrupt_write_074.so"
build_interposer() {
  command -v cc >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет cc — interposer к1b не собирается, канал «любой механизм» мёртв (B3)\n' >&2; exit 2; }
  cc -shared -fPIC -O2 -Wall -o "$KORRUPT_SO" "$KORRUPT_SRC" 2>"$SCRATCH/cc.err" || {
    printf 'NOT_IMPLEMENTED: interposer не компилируется: %s\n' "$(tail -3 "$SCRATCH/cc.err")" >&2; exit 2; }
}
build_interposer

fails=0
red() { fails=$((fails + 1)); printf '  КРАСНО: %s\n' "$*"; }

# ── пины: живая станция 2026-10-02 (sha256sum, сверено с inventory слова владельца) ──
declare -A PIN=(
  ['user/orch-loop']='fad71b1540965d84ed4f3f54759ba76b43628e2be9b91bc9405be62a34a63e2d'
  ['root/orch-peak']='9dbf1ba880171a8865f172e8b072ef246ca20be24ab3ed611949bfb5b1bb4983'
  ['root/systemd/orch-peak@.service']='a7e4e4453ae5fdc4e47758143d8b313ce0fe2b97ad187e3a34c317eaabca1a8f'
  ['root/systemd/orch-peak-warn.timer']='c1aca85614566ce281b90e51001a3158d10bac6366470c09c29ba9ed0921bc01'
  ['root/systemd/orch-peak-stop.timer']='94d909b200c8c0ed000ae96ef3aa8c672aa0467f7269b97ad21d852fbb6e0d3a'
  ['root/systemd/orch-peak-start.timer']='21ec472f90e4328b7b49e90beed5742c0ee2e679f01b195e530bec60fef8a4d0'
  ['root/systemd/orch-peak-reenable.timer']='ac7e888b54efb983a686ad7bd25041f5ad87ac74a502e79253dcc4403db3fa50'
  ['root/systemd/orch-peak-reenable.service']='d80d820e0a300d93e367a613f1bee85361b989c88ad2c9ede4d89e69962920db'
  ['root/systemd/orch-ctx.timer']='dcb7718c6a3a21b50bd08f4c476b058f986ca77b8e70e04ac0327fbe4a202d77'
)
declare -A STATION=(
  ['user/orch-loop']='/home/harness/.local/bin/orch-loop'
  ['root/orch-peak']='/usr/local/sbin/orch-peak'
  ['root/systemd/orch-peak@.service']='/etc/systemd/system/orch-peak@.service'
  ['root/systemd/orch-peak-warn.timer']='/etc/systemd/system/orch-peak-warn.timer'
  ['root/systemd/orch-peak-stop.timer']='/etc/systemd/system/orch-peak-stop.timer'
  ['root/systemd/orch-peak-start.timer']='/etc/systemd/system/orch-peak-start.timer'
  ['root/systemd/orch-peak-reenable.timer']='/etc/systemd/system/orch-peak-reenable.timer'
  ['root/systemd/orch-peak-reenable.service']='/etc/systemd/system/orch-peak-reenable.service'
  ['root/systemd/orch-ctx.timer']='/etc/systemd/system/orch-ctx.timer'
)
UNITS='orch-peak@.service orch-peak-warn.timer orch-peak-stop.timer orch-peak-start.timer orch-peak-reenable.timer orch-peak-reenable.service orch-ctx.timer'

hash_of() { sha256sum <"$1" | cut -d' ' -f1; }

ROLE_ANCHOR='## Автоперезапуск orch-loop и два слота (слова владельца 2026-10-01)'
ROLE_PTR='- **Обвязка сервера:** единый источник — ops/server/README.md (инвентарь, журналы, вкл/выкл, настройка станции).'
ROLE_KEEP='  `bash scripts/orch_restart.sh` — через 20 с рестарт с чистым контекстом,'
HANDOFF_PTR='- Серверная обвязка станции — единый источник: ops/server/README.md (инвентарь механизмов, установка, настройка).'
ROLE_CEILING=51200

# ── честная симуляция install.sh (FIXSIM, throwaway — А-318) ──────────────────
write_sim() { # <путь>
  cat >"$1" <<'SIMEOF'
#!/usr/bin/env bash
# FIXSIM 074 — честная симуляция ops/server/install.sh (throwaway, живёт только
# в скратче батареи; в дереве репо её нет и не будет). Грамматика = инварианты
# контракта 074: user|root|verify, швы адресатов/источника, sha256-конвергенция,
# euid-гард root-части, именованные отказы с именем файла.
set -u
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_ROOT="${OPS_SERVER_SRC:-$SELF_DIR}"
BIN_DST="${OPS_SERVER_BIN_DST:-$HOME/.local/bin}"
SBIN_DST="${OPS_SERVER_SBIN_DST:-/usr/local/sbin}"
ETC_DST="${OPS_SERVER_ETC_DST:-/etc/systemd/system}"
UNITS='orch-peak@.service orch-peak-warn.timer orch-peak-stop.timer orch-peak-start.timer orch-peak-reenable.timer orch-peak-reenable.service orch-ctx.timer'
command -v sha256sum >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет sha256sum\n' >&2; exit 2; }
[ -f "$SRC_ROOT/user/orch-loop" ] && [ -f "$SRC_ROOT/root/orch-peak" ] || {
  printf 'NOT_IMPLEMENTED: нет источника ops/server (user/orch-loop, root/orch-peak)\n' >&2; exit 2; }
usage() { printf 'NOT_IMPLEMENTED: использование: ops/server/install.sh user|root|verify\n' >&2; exit 2; }
die_write() { printf 'ОТКАЗ: запись %s\n' "$1" >&2; exit 1; }
check_one() { # <dst> <src>
  #__ANCHOR_S1__
  [ -f "$1" ] || { printf 'ОТКАЗ: расхождение %s (нет файла)\n' "$1" >&2; return 1; }
  a="$(sha256sum <"$1" | cut -d' ' -f1)"
  b="$(sha256sum <"$2" | cut -d' ' -f1)"
  [ "$a" = "$b" ] || { printf 'ОТКАЗ: расхождение %s\n' "$1" >&2; return 1; }
}
[ $# -eq 1 ] || usage
case "$1" in
  user)
    mkdir -p "$BIN_DST" || die_write "$BIN_DST"
    skip_copy=0
    #__ANCHOR_S4__
    [ "$skip_copy" -eq 1 ] || cp -- "$SRC_ROOT/user/orch-loop" "$BIN_DST/orch-loop" || die_write "$BIN_DST/orch-loop"
    chmod 755 "$BIN_DST/orch-loop" || die_write "$BIN_DST/orch-loop"
    #__ANCHOR_S7__
    #__ANCHOR_S3__
    check_one "$BIN_DST/orch-loop" "$SRC_ROOT/user/orch-loop" || exit 1
    printf 'установлено: %s/orch-loop\n' "$BIN_DST"
    ;;
  root)
    root_ok=0; [ "$(id -u)" -eq 0 ] && root_ok=1
    #__ANCHOR_S2__
    [ "$root_ok" -eq 1 ] || { printf 'ОТКАЗ: root-часть требует euid 0\n' >&2; exit 1; }
    mkdir -p "$SBIN_DST" "$ETC_DST" || die_write "$SBIN_DST $ETC_DST"
    cp -- "$SRC_ROOT/root/orch-peak" "$SBIN_DST/orch-peak" || die_write "$SBIN_DST/orch-peak"
    chmod 755 "$SBIN_DST/orch-peak" || die_write "$SBIN_DST/orch-peak"
    chown root:root "$SBIN_DST/orch-peak" || die_write "$SBIN_DST/orch-peak"
    for u in $UNITS; do
      cp -- "$SRC_ROOT/root/systemd/$u" "$ETC_DST/$u" || die_write "$ETC_DST/$u"
      chmod 644 "$ETC_DST/$u" || die_write "$ETC_DST/$u"
      chown root:root "$ETC_DST/$u" || die_write "$ETC_DST/$u"
    done
    rc=0
    check_one "$SBIN_DST/orch-peak" "$SRC_ROOT/root/orch-peak" || rc=1
    for u in $UNITS; do check_one "$ETC_DST/$u" "$SRC_ROOT/root/systemd/$u" || rc=1; done
    [ "$rc" -eq 0 ] && printf 'установлено: root-часть (orch-peak + 7 юнитов)\n'
    exit "$rc"
    ;;
  verify)
    rc=0
    check_one "$BIN_DST/orch-loop" "$SRC_ROOT/user/orch-loop" || rc=1
    check_one "$SBIN_DST/orch-peak" "$SRC_ROOT/root/orch-peak" || rc=1
    for u in $UNITS; do check_one "$ETC_DST/$u" "$SRC_ROOT/root/systemd/$u" || rc=1; done
    [ "$rc" -eq 0 ] && printf 'сверка: 9/9\n'
    exit "$rc"
    ;;
  *) usage ;;
esac
SIMEOF
}

write_sim_readme() { # <путь> — README честной симуляции: несёт ВСЕ чек-строки к6
  cat >"$1" <<'RMDEOF'
# ops/server — серверная обвязка станции (единый источник в репо)

Симуляция FIXSIM: инвентарь ниже несёт все чек-строки клетки к6 батареи 074.

## Инвентарь механизмов (копии побайтно, источник — живая станция)

- orch-loop — обёртка хоста: перезапуск ведущей сессии по маркеру; user-часть, установлен в ~/.local/bin/orch-loop.
- orch-peak — пауза оркестратора на пиковые часы z.ai (warn|stop|start|check|ctx); root-часть, /usr/local/sbin/orch-peak, root:root 755.
- orch-peak@.service — oneshot-юнит вызова orch-peak %i; /etc/systemd/system/.
- orch-peak-warn.timer — предупреждение в панель (Mon..Fri 13:40 Asia/Singapore).
- orch-peak-stop.timer — проверка «всё закоммичено и отправлено», гашение omp (14:00).
- orch-peak-start.timer — ввод команды запуска цикла в панель (18:00).
- orch-peak-reenable.timer — однократное включение паузы 2026-10-08 00:00 Asia/Singapore.
- orch-peak-reenable.service — enable warn/stop/start таймеров, disable себя.
- orch-ctx.timer — сторож контекста ведущей сессии (раз в 15 минут).

## Журналы

~/orch-loop.log; /var/log/orch-peak.log; ~/orch-peak-report.txt; /var/lib/orch-peak (state).

## Включение/выключение

Включить: systemctl enable --now orch-peak-warn.timer orch-peak-stop.timer orch-peak-start.timer.
Выключить: systemctl disable --now тех же таймеров. Стоп обёртки: touch ~/orch-loop.stop.

## Как обвязка касается сессии

send-keys в панель tmux оркестратора (сообщения владельцу); гашение omp kill'ом
по маркеру; маркер /tmp/dev-harness-verify/orch-restart ставит дверь перезапуска
(scripts/orch_restart.sh, контракт 072) либо сторож контекста.

## Настройка станции

Пользователь harness без sudo; rootless Docker; Node 26; omp по пину;
gh-вход a3ka и GITHUB_TOKEN в .env; клоны ~/odelix/*.

## Установка из репо

bash ops/server/install.sh user; root-часть: sudo bash ops/server/install.sh root;
сверка установленного с репо: bash ops/server/install.sh verify (rc != 0 зовёт файл).
RMDEOF
}

# ── документы мира: роль/HANDOFF с указателями или без ────────────────────────
# Вердикт критика к1 (блокирующая 1): отрицательный мир (0) строится
# СРЕЗАНИЕМ строк-указателей из ТЕКУЩИХ документов (фильтрация grep -Fxv), а
# не копированием «до приземления» — после реализации инвариантов 9-10
# честные роль/HANDOFF несут указатели, и мир без указателей обязан
# оставаться без них независимо от состояния честного дерева. Мир с
# указателями (1) идемпотентен: уже стоящая строка не дублируется.
build_docs() { # <каталог> <указатели:1|0>
  # C2 (адверсарий r1): одна мера с клеткой к7 — «указатель приземлён»
  # судится по ПЕРВОЙ секции «ГДЕ МЫ» (инвариант 10: «В ПЕРВОЙ секции»),
  # не grep'ом по всему HANDOFF: на судимом дереве строка стоит в старой
  # секции, целый файл говорил «приземлён», к7 по первой секции краснел.
  # Мир с указателями применяет их к первой секции ИДЕМПОТЕНТНО (уже
  # стоит — копия как есть); роль мерится той же мерой — разделом якоря.
  mkdir -p "$1/ops/server" "$1/roles"
  write_sim_readme "$1/ops/server/README.md"
  if [ "$2" -eq 1 ]; then
    if awk -v a="$ROLE_ANCHOR" 'index($0,a)==1{f=1;next} f && /^## /{exit} f' \
        "$REPO_ROOT/roles/orchestrator.md" | grep -Fxq -- "$ROLE_PTR"; then
      cp -- "$REPO_ROOT/roles/orchestrator.md" "$1/roles/orchestrator.md"
    else
      awk -v a="$ROLE_ANCHOR" -v ptr="$ROLE_PTR" \
        'index($0,a)==1 && !d {print; print ptr; d=1; next} {print}' \
        "$REPO_ROOT/roles/orchestrator.md" >"$1/roles/orchestrator.md"
    fi
    if awk '!d && index($0,"## ГДЕ МЫ")==1{f=1;d=1;next} f && /^## /{exit} f' \
        "$REPO_ROOT/HANDOFF.md" | grep -Fxq -- "$HANDOFF_PTR"; then
      cp -- "$REPO_ROOT/HANDOFF.md" "$1/HANDOFF.md"
    else
      awk -v ptr="$HANDOFF_PTR" \
        '!d && index($0,"## ГДЕ МЫ")==1 {print; print ptr; d=1; next} {print}' \
        "$REPO_ROOT/HANDOFF.md" >"$1/HANDOFF.md"
    fi
  else
    grep -Fxv -e "$ROLE_PTR" -e "$HANDOFF_PTR" -- \
      "$REPO_ROOT/roles/orchestrator.md" >"$1/roles/orchestrator.md"
    grep -Fxv -e "$ROLE_PTR" -e "$HANDOFF_PTR" -- \
      "$REPO_ROOT/HANDOFF.md" >"$1/HANDOFF.md"
  fi
}

build_sim_tree() { # <каталог>: 9 копий + симуляция install.sh + доки с указателями
  mkdir -p "$1/ops/server/user" "$1/ops/server/root/systemd"
  cp -- "$REPO_ROOT/ops/server/user/orch-loop" "$1/ops/server/user/"
  cp -- "$REPO_ROOT/ops/server/root/orch-peak" "$1/ops/server/root/"
  local u=''
  for u in $UNITS; do cp -- "$REPO_ROOT/ops/server/root/systemd/$u" "$1/ops/server/root/systemd/"; done
  write_sim "$1/ops/server/install.sh"; chmod 755 "$1/ops/server/install.sh"
  build_docs "$1" 1
}

patch_sim() { # <файл> <якорь> <замена> — единственный якорь, иначе отказ
  python3 - "$1" "$2" "$3" <<'PYEOF'
import sys
path, anchor, repl = sys.argv[1], sys.argv[2], sys.argv[3]
s = open(path, encoding='utf-8').read()
assert s.count(anchor) == 1, 'якорь не единственный: %r' % anchor
open(path, 'w', encoding='utf-8').write(s.replace(anchor, repl, 1))
PYEOF
}

# ── клетки честной части (0 = зелёная, 1 = красная) ───────────────────────────
cell_k1() { # <subject>: user-конвергенция
  local W="$SCRATCH/k1" rc
  rm -rf "$W"; mkdir -p "$W/bin" "$W/home"
  OPS_SERVER_SRC="$OPS_SRC" OPS_SERVER_BIN_DST="$W/bin" HOME="$W/home" \
    bash "$1" user >"$W/out" 2>"$W/err"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'k1: rc=%s (%s)\n' "$rc" "$(tail -1 "$W/err")"; return 1; }
  [ -f "$W/bin/orch-loop" ] || { printf 'k1: установленного orch-loop нет\n'; return 1; }
  [ "$(hash_of "$W/bin/orch-loop")" = "${PIN['user/orch-loop']}" ] || { printf 'k1: байты orch-loop разошлись с пином\n'; return 1; }
  [ "$(stat -c%a "$W/bin/orch-loop")" = 755 ] || { printf 'k1: режим orch-loop не 755\n'; return 1; }
  [ ! -e "$W/home/.local/bin/orch-loop" ] || { printf 'k1: записано в умолчательный путь $HOME/.local/bin\n'; return 1; }
  grep -q 'установлено:' "$W/out" || { printf 'k1: нет строки «установлено:»\n'; return 1; }
  return 0
}

cell_k1b() { # <subject>: user-перечитывание sha256 ПОСЛЕ записи (структурный корруптор)
  # Вердикт критика к1 (совет :113): отказ обязана давать САМА команда
  # установки на расхождении после записи, а не только verify. B1
  # (адверсарий r1): субъекты, копирующие мимо cp (cat > dst, install -m
  # 755) БЕЗ перечитывания, проходили cp-шину. B3 (адверсарий r2, ЖИВОЙ
  # прогон): tee-копирование без перечитывания проходило ВСЕ шины —
  # перечисление механизмов не масштабируется. Структурное закрытие:
  # LD_PRELOAD-interposer портит первый write-класс-вызов в дескриптор,
  # открытый на запись по пути */orch-loop (какой бы механизм ни звал —
  # цель спрашивается у ядра через /proc/self/fd, так что наследованные
  # после exec дескрипторы и dup2 внутри dd тоже накрыты); шины
  # cp/cat/install в PATH остаются второй, независимой парой контроля.
  # Неинертность канала самодоказуема: interposer ведёт счёт испорченных
  # записей в $W/korrupt.log. Остаточный предел (назван, не
  # расширяется): rename-класс (mv внутри одной ФС байтов не пишет) и
  # прямые сисколлы мимо PLT/syscall(2) у статически слинкованного
  # субъекта; различение на симуляции несут стаб s7 и канальные пробы.
  local W="$SCRATCH/k1b" rc h real_cp real_cat real_install
  rm -rf "$W"; mkdir -p "$W/bin" "$W/home" "$W/shim"
  real_cp="$(command -v cp)"
  real_cat="$(command -v cat)"
  real_install="$(command -v install)"
  cat >"$W/shim/cp" <<CPEOF
#!/usr/bin/env bash
$real_cp "\$@"; rc=\$?
for a in "\$@"; do last="\$a"; done
case "\$last" in */orch-loop) printf 'X' >>"\$last" ;; esac
exit "\$rc"
CPEOF
  cat >"$W/shim/cat" <<CATEOF
#!/usr/bin/env bash
$real_cat "\$@"; rc=\$?
exec 4>&1
dst="\$(readlink -f /proc/self/fd/4 2>/dev/null || true)"
exec 4>&-
case "\$dst" in */orch-loop) printf 'X' >>"\$dst" ;; esac
exit "\$rc"
CATEOF
  cat >"$W/shim/install" <<INSEOF
#!/usr/bin/env bash
$real_install "\$@"; rc=\$?
for a in "\$@"; do last="\$a"; done
case "\$last" in */orch-loop) printf 'X' >>"\$last" ;; esac
exit "\$rc"
INSEOF
  chmod 755 "$W/shim/cp" "$W/shim/cat" "$W/shim/install"
  rm -f "$W/korrupt.log"
  PATH="$W/shim:$PATH" LD_PRELOAD="$KORRUPT_SO" ORCH074_CORRUPT_LOG="$W/korrupt.log" \
    OPS_SERVER_SRC="$OPS_SRC" OPS_SERVER_BIN_DST="$W/bin" \
    HOME="$W/home" bash "$1" user >"$W/out" 2>"$W/err"; rc=$?
  local nkor=0
  [ -f "$W/korrupt.log" ] && nkor="$(grep -c . "$W/korrupt.log")"
  if [ -f "$W/bin/orch-loop" ]; then h="$(hash_of "$W/bin/orch-loop")"; else h=none; fi
  if [ "$h" = "${PIN['user/orch-loop']}" ]; then
    if [ "$nkor" -gt 0 ]; then
      printf 'k1b: interposer учёл %s порч, но байты адресата целы — канал мёртв (Н-39)\n' "$nkor"
      return 1
    fi
    printf '  k1b: все каналы порчи инертны (субъект не пишет байты — rename-класс, остаточный предел) — проба не судит, перечитывание судится стабом s7 и канальными пробами\n'
    return 0
  fi
  [ "$rc" -ne 0 ] || { printf 'k1b: rc=0 на испорченной записи (interposer: %s, шины: cp/cat/install) — user-часть не перечитывает sha256\n' "$nkor"; return 1; }
  grep -q 'расхождение' "$W/err" || { printf 'k1b: отказ без маркера «расхождение»\n'; return 1; }
  grep -Fq 'orch-loop' "$W/err" || { printf 'k1b: отказ без имени файла\n'; return 1; }
  printf '  k1b: субъект отказался на испорченной записи (interposer испортил записей: %s)\n' "$nkor"
  return 0
}

green_world() { # <bin> <sbin> <etc>: 9 адресатов == репо (ставит батарея)
  mkdir -p "$1" "$2" "$3"
  cp -- "$OPS_SRC/user/orch-loop" "$1/orch-loop"; chmod 755 "$1/orch-loop"
  cp -- "$OPS_SRC/root/orch-peak" "$2/orch-peak"; chmod 755 "$2/orch-peak"
  local u
  for u in $UNITS; do cp -- "$OPS_SRC/root/systemd/$u" "$3/$u"; chmod 644 "$3/$u"; done
}

cell_k2() { # <subject>: verify зелёного мира
  local W="$SCRATCH/k2" rc
  rm -rf "$W"; green_world "$W/bin" "$W/sbin" "$W/etc"
  OPS_SERVER_SRC="$OPS_SRC" OPS_SERVER_BIN_DST="$W/bin" \
    OPS_SERVER_SBIN_DST="$W/sbin" OPS_SERVER_ETC_DST="$W/etc" \
    bash "$1" verify >"$W/out" 2>"$W/err"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'k2: rc=%s на зелёном мире (%s)\n' "$rc" "$(tail -1 "$W/err")"; return 1; }
  grep -q 'сверка: 9/9' "$W/out" || { printf 'k2: нет строки «сверка: 9/9»\n'; return 1; }
  return 0
}

cell_k3() { # <subject>: verify расхождения — ПАРАМЕТРИЗОВАНО по всем девяти адресатам
  # Вердикт критика к1 (блокирующая 2): проба обязана ловить расхождение
  # ЛЮБОГО из девяти файлов, иначе verify, сверяющий один orch-ctx.timer,
  # проходит приёмку. Каждый адресат искажается по очереди: user-файл,
  # root-файл, каждый из 7 юнитов.
  local rel base W rc dst
  for rel in "${!PIN[@]}"; do
    base="${rel##*/}"
    W="$SCRATCH/k3_${rel//\//_}"
    rm -rf "$W"; green_world "$W/bin" "$W/sbin" "$W/etc"
    case "$rel" in
      root/systemd/*) dst="$W/etc/$base" ;;
      root/*)         dst="$W/sbin/$base" ;;
      *)              dst="$W/bin/$base" ;;
    esac
    printf 'X' >>"$dst"
    OPS_SERVER_SRC="$OPS_SRC" OPS_SERVER_BIN_DST="$W/bin" \
      OPS_SERVER_SBIN_DST="$W/sbin" OPS_SERVER_ETC_DST="$W/etc" \
      bash "$1" verify >"$W/out" 2>"$W/err"; rc=$?
    [ "$rc" -ne 0 ] || { printf 'k3[%s]: rc=0 — сверка слепа к этому адресату\n' "$rel"; return 1; }
    grep -q 'расхождение' "$W/err" || { printf 'k3[%s]: отказ без маркера «расхождение»\n' "$rel"; return 1; }
    grep -Fq -- "$base" "$W/err" || { printf 'k3[%s]: отказ без имени файла %s\n' "$rel" "$base"; return 1; }
  done
  return 0
}

cell_k4() { # <subject>: euid-гард root-части под harness
  local W="$SCRATCH/k4" rc
  rm -rf "$W"; mkdir -p "$W/sbin" "$W/etc"
  OPS_SERVER_SRC="$OPS_SRC" OPS_SERVER_SBIN_DST="$W/sbin" \
    OPS_SERVER_ETC_DST="$W/etc" bash "$1" root >"$W/out" 2>"$W/err"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'k4: rc=%s под harness (ожидался 1)\n' "$rc"; return 1; }
  grep -q 'root-часть требует euid 0' "$W/err" || { printf 'k4: отказ без фразы «root-часть требует euid 0»\n'; return 1; }
  [ ! -e "$W/sbin/orch-peak" ] || { printf 'k4: root-часть записала orch-peak под harness\n'; return 1; }
  [ -z "$(ls -A "$W/etc")" ] || { printf 'k4: root-часть записала юниты под harness\n'; return 1; }
  return 0
}

cell_k5() { # пины репо: 9 копий дерева-субъекта == станция
  local rel f
  for rel in "${!PIN[@]}"; do
    f="$OPS_ROOT/ops/server/$rel"
    [ -f "$f" ] || { printf 'k5: нет ops/server/%s\n' "$rel"; return 1; }
    [ "$(hash_of "$f")" = "${PIN[$rel]}" ] || { printf 'k5: ops/server/%s разошёлся с пином станции\n' "$rel"; return 1; }
  done
  return 0
}

cell_k5b() { # живая станция: сверка станции с пинами (в CI — пропуск с пометкой)
  local rel all=1
  for rel in "${!STATION[@]}"; do [ -r "${STATION[$rel]}" ] || all=0; done
  if [ "$all" -eq 0 ]; then
    printf '  станция: файлы станции не читаемы (CI) — живая сверка пропущена, судят пины репо (к5)\n'
    return 0
  fi
  for rel in "${!STATION[@]}"; do
    [ "$(hash_of "${STATION[$rel]}")" = "${PIN[$rel]}" ] || { printf 'k5b: станция %s разошлась с пином\n' "${STATION[$rel]}"; return 1; }
  done
  printf '  станция: 9/9 побайтно совпали (живая сверка)\n'
  return 0
}

README_NAMES='orch-loop orch-peak orch-peak@.service orch-peak-warn.timer orch-peak-stop.timer orch-peak-start.timer orch-peak-reenable.timer orch-peak-reenable.service orch-ctx.timer'
README_TOPICS='журнал send-keys omp гашен маркер включ выключ rootless Node 26 GITHUB_TOKEN a3ka ~/odelix/ sudo'

cell_k6() { # <docroot>: чек-строки README
  local r="$1/ops/server/README.md" t
  [ -s "$r" ] || { printf 'k6: нет ops/server/README.md\n'; return 1; }
  for t in $README_NAMES; do
    grep -Fq -- "$t" "$r" || { printf 'k6: README не называет %s\n' "$t"; return 1; }
  done
  for t in $README_TOPICS; do
    grep -Fqi -- "$t" "$r" || { printf 'k6: README без темы «%s»\n' "$t"; return 1; }
  done
  return 0
}

cell_k7() { # <docroot>: указатели HANDOFF/роли, носитель, потолок
  local role="$1/roles/orchestrator.md" ho="$1/HANDOFF.md" sz
  [ -f "$role" ] && [ -f "$ho" ] || { printf 'k7: нет роли или HANDOFF в мире\n'; return 1; }
  awk -v a="$ROLE_ANCHOR" 'index($0,a)==1{f=1;next} f && /^## /{exit} f' "$role" >"$SCRATCH/k7.role"
  grep -Fxq -- "$ROLE_PTR" "$SCRATCH/k7.role" || { printf 'k7: в разделе роли нет строки-указателя на ops/server/README.md\n'; return 1; }
  grep -Fxq -- "$ROLE_KEEP" "$SCRATCH/k7.role" || { printf 'k7: строка-носитель orch_restart не сохранена побайтово\n'; return 1; }
  awk '!d && index($0,"## ГДЕ МЫ")==1{f=1;d=1;next} f && /^## /{exit} f' "$ho" >"$SCRATCH/k7.ho"
  grep -Fxq -- "$HANDOFF_PTR" "$SCRATCH/k7.ho" || { printf 'k7: в первой секции ГДЕ МЫ нет строки-указателя\n'; return 1; }
  sz=$(wc -c <"$role")
  [ "$sz" -le "$ROLE_CEILING" ] || { printf 'k7: роль %s байт > потолка %s\n' "$sz" "$ROLE_CEILING"; return 1; }
  return 0
}

# ── стаб-пак: 7 обманных стабов, у каждого свой вход (Н-39) ───────────────────
SIM="$SCRATCH/sim_install.sh"
write_sim "$SIM"

make_stub() { # <имя> <якорь> <замена>
  mkdir -p "$SCRATCH/stubs/$1"
  cp -- "$SIM" "$SCRATCH/stubs/$1/install.sh"
  patch_sim "$SCRATCH/stubs/$1/install.sh" "$2" "$3" || return 1
  return 0
}

caught=0; stub_total=0; diffok=0; diff_total=0
diff_run() { # <клетка> <аргумент>: честная пара обязана быть зелёной
  diff_total=$((diff_total + 1))
  if "$1" "$2" >/dev/null 2>&1; then
    diffok=$((diffok + 1))
  else
    red "диффпроба: $1 красная на честной симуляции/честных документах"
  fi
}

run_stub_pack() {
  local spec nm anc repl cell sim_docs
  sim_docs="$SCRATCH/simdocs"
  build_docs "$sim_docs" 1
  for spec in \
    's1|#__ANCHOR_S1__|return 0|cell_k3' \
    's2|#__ANCHOR_S2__|root_ok=1|cell_k4' \
    's3|#__ANCHOR_S3__|printf X >> "$BIN_DST/orch-loop"|cell_k1' \
    's4|#__ANCHOR_S4__|skip_copy=1|cell_k1' \
    's7|#__ANCHOR_S7__|check_one() { return 0; }|cell_k1b'
  do
    IFS='|' read -r nm anc repl cell <<<"$spec"
    stub_total=$((stub_total + 1))
    if ! make_stub "$nm" "$anc" "$repl"; then
      red "стаб $nm не построен: якорь снесён (Н-39)"
      continue
    fi
    if "$cell" "$SCRATCH/stubs/$nm/install.sh" >/dev/null 2>&1; then
      red "стаб $nm жив: клетка $cell зелёная на обмане (Н-39)"
    else
      printf '  стаб %s пойман (вход %s)\n' "$nm" "$cell"
      caught=$((caught + 1))
    fi
  done
  # s5 «README без инвентаря» — вход к6
  stub_total=$((stub_total + 1))
  build_docs "$SCRATCH/doc_s5" 1
  printf '# ops/server\nЗаглушка без инвентаря.\n' >"$SCRATCH/doc_s5/ops/server/README.md"
  if cell_k6 "$SCRATCH/doc_s5" >/dev/null 2>&1; then
    red 'стаб s5 жив: чек-строки к6 зелёные на заглушке README (Н-39)'
  else
    printf '  стаб s5 пойман (вход cell_k6)\n'
    caught=$((caught + 1))
  fi
  # s6 «указатели не приземлены» — вход к7
  stub_total=$((stub_total + 1))
  build_docs "$SCRATCH/doc_s6" 0
  if cell_k7 "$SCRATCH/doc_s6" >/dev/null 2>&1; then
    red 'стаб s6 жив: к7 зелёная без строк-указателей (Н-39)'
  else
    printf '  стаб s6 пойман (вход cell_k7)\n'
    caught=$((caught + 1))
  fi
  # диффпроба: тот же вход на честной симуляции/честных документах — зеркально стабам
  diff_run cell_k3 "$SIM"
  diff_run cell_k4 "$SIM"
  diff_run cell_k1 "$SIM"
  diff_run cell_k1 "$SIM"
  diff_run cell_k1b "$SIM"
  diff_run cell_k6 "$sim_docs"
  diff_run cell_k7 "$sim_docs"
  printf 'стаб-пак: %d/%d поймано, диффпроба: %d/%d\n' "$caught" "$stub_total" "$diffok" "$diff_total"
  return 0
}

# ── канальные пробы к1b (B1/B3, адверсары r1/r2): на каждый механизм ───────────
# копирования — ДВЕ вариации симуляции: честная (копирует механизмом,
# перечитывает sha256 ПОСЛЕ записи) обязана ЗЕЛЕНЕТЬ на к1b — канал порчи
# портит адресат, честный отказывается rc 1 «расхождение»; ленивая (тот же
# механизм, перечитывание нейтрализовано) обязана быть ПОЙМАННОЙ красным.
# Отрицательные пробы обязательны для КАЖДОГО канала: канал, не поймавший
# своего ленивого, — дефект канала, а не предмета. Множество механизмов:
# cp/cat/install — шины PATH + interposer (B1); tee/dd/python3 — ТОЛЬКО
# interposer (B3: вход живого обхода адверсария r2 — tee-мир проходил
# батарею с rc 0, шин для этих механизмов нет).
K1B_CP_LINE='cp -- "$SRC_ROOT/user/orch-loop" "$BIN_DST/orch-loop" || die_write "$BIN_DST/orch-loop"'
run_k1b_channels() {
  local mech repl hd ld out rc ch=0 cc=0
  for mech in cp cat install tee dd python3; do
    case "$mech" in
      cat) repl='{ cat -- "$SRC_ROOT/user/orch-loop" >"$BIN_DST/orch-loop"; } || die_write "$BIN_DST/orch-loop"' ;;
      install) repl='install -m 755 -- "$SRC_ROOT/user/orch-loop" "$BIN_DST/orch-loop" || die_write "$BIN_DST/orch-loop"' ;;
      tee) repl='{ tee "$BIN_DST/orch-loop" <"$SRC_ROOT/user/orch-loop" >"$BIN_DST/chan-null"; } || die_write "$BIN_DST/orch-loop"' ;;
      dd) repl='dd if="$SRC_ROOT/user/orch-loop" of="$BIN_DST/orch-loop" status=none || die_write "$BIN_DST/orch-loop"' ;;
      python3) repl='python3 -c '\''import shutil,sys; shutil.copyfile(sys.argv[1], sys.argv[2])'\'' "$SRC_ROOT/user/orch-loop" "$BIN_DST/orch-loop" || die_write "$BIN_DST/orch-loop"' ;;
      *) repl='' ;;
    esac
    hd="$SCRATCH/chan_${mech}_honest"; ld="$SCRATCH/chan_${mech}_lazy"
    mkdir -p "$hd" "$ld"
    cp -- "$SIM" "$hd/install.sh"; cp -- "$SIM" "$ld/install.sh"
    if [ -n "$repl" ]; then
      patch_sim "$hd/install.sh" "$K1B_CP_LINE" "$repl"
      patch_sim "$ld/install.sh" "$K1B_CP_LINE" "$repl"
    fi
    patch_sim "$ld/install.sh" '#__ANCHOR_S7__' 'check_one() { return 0; }'
    out="$(cell_k1b "$hd/install.sh" 2>&1)"; rc=$?
    if [ "$rc" -eq 0 ] && ! printf '%s\n' "$out" | grep -q 'инертн'; then
      ch=$((ch + 1))
    else
      red "канал $mech: честная вариация не доказана на к1b (красна или канал инертен — зелёное без порчи)"
    fi
    if cell_k1b "$ld/install.sh" >/dev/null 2>&1; then
      red "канал $mech: ленивая вариация (без перечитывания) жива на к1b (Н-39)"
    else
      cc=$((cc + 1))
      printf '  канал %s: честный отказался, ленивый пойман\n' "$mech"
    fi
  done
  printf 'к1b-каналы: честные %d/6, ленивые пойманы %d/6\n' "$ch" "$cc"
  return 0
}

# ── LANDSIM (вердикт критика к1, блокирующая 1): дерево с приземлёнными ───────
# указателями — батарея обязана быть зелёной на дереве, где роль/HANDOFF УЖЕ
# несут строки-указатели (инварианты 9-10 применены к текущим документам
# идемпотентно), субъект — честная симуляция; REPO_ROOT переводится на
# скратч-дерево, чтобы отрицательные миры стаб-пака строились из ПРИЗЕМЛЁННЫХ
# документов: мир s6 обязан лишаться указателей срезанием, а не копированием
# «до приземления». Даёт rc 0 и до, и после реального приземления.
if [ "${LANDSIM:-0}" = "1" ]; then
  T="$SCRATCH/landed"
  build_sim_tree "$T"
  REPO_ROOT="$T"; OPS_SRC="$T/ops/server"
  OPS_ROOT="$T"; SUBJ="$T/ops/server/install.sh"
  printf 'LANDSIM: дерево с приземлёнными указателями %s (throwaway)\n' "$T"
# ── FIXSIM (А-318): честная симуляция в скратче — батарея обязана позеленеть ──
elif [ "${FIXSIM:-0}" = "1" ]; then
  T="$SCRATCH/tree"
  build_sim_tree "$T"
  OPS_ROOT="$T"
  SUBJ="$T/ops/server/install.sh"
  printf 'FIXSIM: честная симуляция install.sh в %s (throwaway, А-318)\n' "$T"
fi

# ── г0: предмет отсутствует (живое красное ДО реализации) ─────────────────────
if [ ! -f "$SUBJ" ]; then
  printf 'ОТКАЗ: предмет отсутствует — в дереве нет ops/server/install.sh\n' >&2
  run_stub_pack
  printf 'итог 074: красных клеток=%d стабы=%d/%d\n' "$fails" "$caught" "$stub_total"
  exit 1
fi

# ── честная часть ─────────────────────────────────────────────────────────────
printf 'честная часть (субъект %s):\n' "$SUBJ"
honest=0; htotal=7
for cell in cell_k1 cell_k2 cell_k3 cell_k4; do
  if "$cell" "$SUBJ"; then honest=$((honest + 1)); else red "$cell"; fi
done
if cell_k5; then honest=$((honest + 1)); else red 'cell_k5'; fi
cell_k5b || red 'cell_k5b'
cell_k1b "$SUBJ" || red 'cell_k1b'
if cell_k6 "$OPS_ROOT"; then honest=$((honest + 1)); else red 'cell_k6'; fi
if cell_k7 "$OPS_ROOT"; then honest=$((honest + 1)); else red 'cell_k7'; fi
printf 'честная часть: %d/%d зелёная\n' "$honest" "$htotal"

run_stub_pack
run_k1b_channels

printf 'итог 074: красных клеток=%d стабы=%d/%d\n' "$fails" "$caught" "$stub_total"
if [ "$fails" -ne 0 ] || [ "$caught" -ne "$stub_total" ]; then exit 1; fi
exit 0
