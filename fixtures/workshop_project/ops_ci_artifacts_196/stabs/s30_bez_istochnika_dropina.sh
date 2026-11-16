#!/usr/bin/env bash
# model/install-artifacts.sh — исполнительная модель (спека) подкоманды
# `install.sh artifacts` и её части verify (контракт 196 §Предмет И-8..И-13).
# НЕ продакшн: живёт в фикстуре; реализация implementer'а в ops/server/install.sh
# несёт те же фразы побайтово. Источник ставимых файлов — шов OPS_SERVER_SRC
# (как у настоящего install.sh): $SRC/root/ci-artifacts-clean,
# $SRC/root/systemd/ci-artifacts-clean.{service,timer} и
# $SRC/root/gh-runner-complior-ci-artifacts.conf (drop-in моб-раннера).
#
# Подкоманды: artifacts | verify-artifacts | usage
#
# Швы: OPS_SERVER_SRC, OPS_SERVER_SBIN_DST (умолчание /usr/local/sbin),
# OPS_SERVER_ETC_DST (/etc/systemd/system), OPS_SERVER_CI_ARTIFACTS
# (/var/lib/ci-artifacts), OPS_SERVER_CI_ARTIFACTS_MOB_OWNER (harness),
# OPS_SERVER_CI_ARTIFACTS_BACK_OWNER (ci-back), OPS_SERVER_CI_ARTIFACTS_GROUP
# (harness), OPS_SERVER_SYSTEMCTL (systemctl).
#
# Коды: 0 — успех; 1 — именованный отказ; 2 — NOT_IMPLEMENTED.
set -u

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_ROOT="${OPS_SERVER_SRC:-$SELF_DIR}"
SBIN_DST="${OPS_SERVER_SBIN_DST-/usr/local/sbin}"
ETC_DST="${OPS_SERVER_ETC_DST-/etc/systemd/system}"
CIART_ROOT="${OPS_SERVER_CI_ARTIFACTS-/var/lib/ci-artifacts}"
MOB_OWNER="${OPS_SERVER_CI_ARTIFACTS_MOB_OWNER-harness}"
BACK_OWNER="${OPS_SERVER_CI_ARTIFACTS_BACK_OWNER-ci-back}"
CIART_GROUP="${OPS_SERVER_CI_ARTIFACTS_GROUP-harness}"
SYSTEMCTL="${OPS_SERVER_SYSTEMCTL-systemctl}"

CLEAN_SRC="$SRC_ROOT/root/ci-artifacts-clean"
SVC_SRC="$SRC_ROOT/root/systemd/ci-artifacts-clean.service"
TMR_SRC="$SRC_ROOT/root/systemd/ci-artifacts-clean.timer"
DROPIN_SRC="$SRC_ROOT/root/gh-runner-complior-ci-artifacts.conf"
CLEAN_DST="$SBIN_DST/ci-artifacts-clean"
SVC_DST="$ETC_DST/ci-artifacts-clean.service"
TMR_DST="$ETC_DST/ci-artifacts-clean.timer"
# юниты моб-раннера станции (вне репо): drop-in ставится по наличию юнита
RUNNER_UNITS="gh-runner-complior gh-runner-complior-2"

usage() {
  printf 'NOT_IMPLEMENTED: использование: install-artifacts.sh artifacts|verify-artifacts\n' >&2
  exit 2
}
die_write() {
  printf 'ОТКАЗ: запись %s\n' "$1" >&2
  exit 1
}
check_one() { # <адресат> <источник>
  [ -f "$1" ] || { printf 'ОТКАЗ: расхождение %s (нет файла)\n' "$1" >&2; return 1; }
  a="$(sha256sum <"$1" | cut -d' ' -f1)"
  b="$(sha256sum <"$2" | cut -d' ' -f1)"
  [ "$a" = "$b" ] || { printf 'ОТКАЗ: расхождение %s\n' "$1" >&2; return 1; }
}
# существующий каталог уже годен (режим/владелец верны) — не трогаем его:
# факт станции 2026-11-16: корни созданы оператором, дрейф chown/chmod
# запрещён (И-9г); владелец/группа читаются stat'ом (в шов-мире — шим
# конфигурации мира, на станции — живой stat)
existing_matches() { # <каталог> <режим> <владелец:группа>
  [ "$(stat -c %a -- "$1")" = "$2" ] || return 1
  [ "$(stat -c %U:%G -- "$1")" = "$3" ] || return 1
  return 0
}
refuse_existing() { # <путь> — расходящийся существующий корень (И-9г)
  printf 'ОТКАЗ: существующий корень расходится: %s\n' "$1" >&2
  exit 1
}
# родительский корень артефактов: root:root 0755 (факт станции)
provision_base() { # <каталог>
  if [ -L "$1" ]; then
    printf 'ОТКАЗ: репо — символьная ссылка: %s\n' "$1" >&2
    exit 1
  fi
  if [ -e "$1" ]; then
    [ -d "$1" ] || { printf 'ОТКАЗ: репо — символьная ссылка: %s\n' "$1" >&2; exit 1; }
    existing_matches "$1" 755 root:root || refuse_existing "$1"
  else
    mkdir -p -- "$1" || die_write "$1"
    chown root:root -- "$1" || die_write "chown $1"
    chmod 755 -- "$1" || die_write "chmod $1"
  fi
}
# корень репо: <владелец> — И-9/И-10; существующий с верными владельцем/
# режимом 2750 принимается идемпотентно БЕЗ chown/chmod, расходящийся —
# именованный отказ без молчаливого переформатирования (И-9г)
provision_root() { # <каталог> <владелец>
  if [ -L "$1" ]; then
    printf 'ОТКАЗ: репо — символьная ссылка: %s\n' "$1" >&2
    exit 1
  fi
  if [ -e "$1" ]; then
    [ -d "$1" ] || { printf 'ОТКАЗ: репо — символьная ссылка: %s\n' "$1" >&2; exit 1; }
    existing_matches "$1" 2750 "$2:$CIART_GROUP" || refuse_existing "$1"
  else
    mkdir -p -- "$1" || die_write "$1"
    chown "$2:$CIART_GROUP" -- "$1" || die_write "chown $1"
    chmod 2750 -- "$1" || die_write "chmod $1"
  fi
}

check_root() { # <корень репо> <владелец> — И-10
  if [ ! -d "$1" ] || [ "$(stat -c %a -- "$1")" != "2750" ]; then
    printf 'ОТКАЗ: расхождение ci-artifacts: %s\n' "$1" >&2
    return 1
  fi
  # владелец/группа — И-10: сверяются stat'ом; в шов-мире stat перехватывается
  # шимом конфигурации мира (%U:%G — из конфигурации, %a — реальный stat),
  # на станции — живой stat (вердикт v2, совет а: ветка предъявляема)
  if [ "$(stat -c %U:%G -- "$1")" != "$2:$CIART_GROUP" ]; then
    printf 'ОТКАЗ: расхождение ci-artifacts: %s\n' "$1" >&2
    return 1
  fi
}

# drop-in моб-раннера (И-9е): ставится ТОЛЬКО при наличии юнита-раннера в
# $ETC_DST; содержимое — байт-в-байт из репо-источника: ровно ReadWritePaths
# на корень моба (без него ProtectSystem=strict даёт EROFS записи CI моба)
install_dropin() { # <юнит>
  dropin_dir="$ETC_DST/$1.service.d"
  dropin_dst="$dropin_dir/ci-artifacts.conf"
  mkdir -p -- "$dropin_dir" || die_write "$dropin_dir"
  cp -- "$DROPIN_SRC" "$dropin_dst" || die_write "$dropin_dst"
  chmod 644 -- "$dropin_dst" || die_write "$dropin_dst"
  chown root:root -- "$dropin_dst" || die_write "$dropin_dst"
  check_one "$dropin_dst" "$DROPIN_SRC" || exit 1
}

command -v sha256sum >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: нет sha256sum\n' >&2; exit 2; }

[ "$#" -eq 1 ] || usage
MODE="$1"

case "$MODE" in
  artifacts)
    # ── И-8: euid-гард ДО любых записей ─────────────────────────────────────
    if [ "$(id -u)" -ne 0 ]; then
      printf 'ОТКАЗ: artifacts-часть требует euid 0\n' >&2
      exit 1
    fi
    # ── И-9: предусловия ДО записей: источники и учётные записи ─────────────
    [ -f "$CLEAN_SRC" ] || { printf 'ОТКАЗ: нет источника: %s\n' "$CLEAN_SRC" >&2; exit 1; }
    [ -f "$SVC_SRC" ] || { printf 'ОТКАЗ: нет источника: %s\n' "$SVC_SRC" >&2; exit 1; }
    [ -f "$TMR_SRC" ] || { printf 'ОТКАЗ: нет источника: %s\n' "$TMR_SRC" >&2; exit 1; }
    # стаб s30: предусловие drop-in-источника удалено (дефект наблюдаем
    # на входе install-precondition: мир без drop-in-источника)
    getent passwd "$MOB_OWNER" >/dev/null 2>&1 \
      || { printf 'ОТКАЗ: нет пользователя: %s\n' "$MOB_OWNER" >&2; exit 1; }
    getent passwd "$BACK_OWNER" >/dev/null 2>&1 \
      || { printf 'ОТКАЗ: нет пользователя: %s\n' "$BACK_OWNER" >&2; exit 1; }
    getent group "$CIART_GROUP" >/dev/null 2>&1 \
      || { printf 'ОТКАЗ: нет группы: %s\n' "$CIART_GROUP" >&2; exit 1; }
    # ── И-11: копии с sha256-перечитыванием ─────────────────────────────────
    mkdir -p -- "$SBIN_DST" "$ETC_DST" || die_write "$SBIN_DST $ETC_DST"
    cp -- "$CLEAN_SRC" "$CLEAN_DST" || die_write "$CLEAN_DST"
    chmod 755 -- "$CLEAN_DST" || die_write "$CLEAN_DST"
    chown root:root -- "$CLEAN_DST" || die_write "$CLEAN_DST"
    check_one "$CLEAN_DST" "$CLEAN_SRC" || exit 1
    cp -- "$SVC_SRC" "$SVC_DST" || die_write "$SVC_DST"
    chmod 644 -- "$SVC_DST" || die_write "$SVC_DST"
    chown root:root -- "$SVC_DST" || die_write "$SVC_DST"
    cp -- "$TMR_SRC" "$TMR_DST" || die_write "$TMR_DST"
    chmod 644 -- "$TMR_DST" || die_write "$TMR_DST"
    chown root:root -- "$TMR_DST" || die_write "$TMR_DST"
    check_one "$SVC_DST" "$SVC_SRC" || exit 1
    check_one "$TMR_DST" "$TMR_SRC" || exit 1
    # ── И-9/И-10: корни /var/lib/ci-artifacts идемпотентно, по факту ────────
    provision_base "$CIART_ROOT"
    provision_root "$CIART_ROOT/Complior-mob" "$MOB_OWNER"
    provision_root "$CIART_ROOT/Complior-back" "$BACK_OWNER"
    # ── И-9(е): drop-in'ы моб-раннера по наличию юнита, ДО daemon-reload ────
    for unit in $RUNNER_UNITS; do
      if [ -f "$ETC_DST/$unit.service" ]; then
        install_dropin "$unit"
      fi
    done
    # ── И-12: включение таймера ──────────────────────────────────────────────
    command -v "$SYSTEMCTL" >/dev/null 2>&1 \
      || { printf 'NOT_IMPLEMENTED: нет %s\n' "$SYSTEMCTL" >&2; exit 2; }
    "$SYSTEMCTL" daemon-reload >/dev/null 2>&1 \
      || { printf 'ОТКАЗ: systemctl daemon-reload\n' >&2; exit 1; }
    "$SYSTEMCTL" enable --now ci-artifacts-clean.timer >/dev/null 2>&1 \
      || { printf 'ОТКАЗ: ci-artifacts-clean.timer не включён\n' >&2; exit 1; }
    printf 'установлено: ci-artifacts (скрипт + 2 юнита + корни %s)\n' "$CIART_ROOT"
    exit 0
    ;;
  verify-artifacts)
    # ── И-13: условная сверка (прецедент 189 «не установлены — не расхождение»)
    if [ ! -e "$CLEAN_DST" ] && [ ! -e "$SVC_DST" ] && [ ! -e "$TMR_DST" ]; then
      printf 'ci-artifacts: не установлены (sudo bash ops/server/install.sh artifacts)\n'
      exit 0
    fi
    rc=0
    check_one "$CLEAN_DST" "$CLEAN_SRC" || rc=1
    check_one "$SVC_DST" "$SVC_SRC" || rc=1
    check_one "$TMR_DST" "$TMR_SRC" || rc=1
    if [ "$rc" -ne 0 ]; then
      exit 1
    fi
    # И-10: корни репо — режим 2750 в обоих контурах (клетка verify-roots),
    # владелец/группа — в производственном (без швов адресатов)
    check_root "$CIART_ROOT/Complior-mob" "$MOB_OWNER" || exit 1
    check_root "$CIART_ROOT/Complior-back" "$BACK_OWNER" || exit 1
    # И-10: drop-in'ы моб-раннера — условная сверка: юнит есть → сверяется
    # sha256 с репо-источником, юнита нет → не расхождение (клетка
    # verify-runner-dropin)
    for unit in $RUNNER_UNITS; do
      if [ -f "$ETC_DST/$unit.service" ]; then
        check_one "$ETC_DST/$unit.service.d/ci-artifacts.conf" "$DROPIN_SRC" || exit 1
      fi
    done
    printf 'ci-artifacts: сверка 3/3\n'
    exit 0
    ;;
  *) usage ;;
esac
