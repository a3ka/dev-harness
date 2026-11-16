#!/usr/bin/env bash
# model/install-artifacts.sh — исполнительная модель (спека) подкоманды
# `install.sh artifacts` и её части verify (контракт 196 §Предмет И-8..И-12).
# НЕ продакшн: живёт в фикстуре; реализация implementer'а в ops/server/install.sh
# несёт те же фразы побайтово. Источник ставимых файлов — шов OPS_SERVER_SRC
# (как у настоящего install.sh): $SRC/root/ci-artifacts-clean и
# $SRC/root/systemd/ci-artifacts-clean.{service,timer}.
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
CLEAN_DST="$SBIN_DST/ci-artifacts-clean"
SVC_DST="$ETC_DST/ci-artifacts-clean.service"
TMR_DST="$ETC_DST/ci-artifacts-clean.timer"

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
# корень артефактов: <владелец> — И-9/И-10
provision_root() { # <каталог> <владелец>
  if [ -e "$1" ] || [ -L "$1" ]; then
    if [ -L "$1" ]; then
      printf 'ОТКАЗ: репо — символьная ссылка: %s\n' "$1" >&2
      exit 1
    fi
    if [ ! -d "$1" ]; then
      printf 'ОТКАЗ: репо — символьная ссылка: %s\n' "$1" >&2
      exit 1
    fi
  else
    mkdir -p -- "$1" || die_write "$1"
  fi
  chown "$2:$CIART_GROUP" -- "$1" || die_write "chown $1"
  chmod 2775 -- "$1" || die_write "chmod $1"
}

check_root() { # <корень репо> <владелец> — И-10
  if [ ! -d "$1" ] || [ "$(stat -c %a -- "$1")" != "2775" ]; then
    printf 'ОТКАЗ: расхождение ci-artifacts: %s\n' "$1" >&2
    return 1
  fi
  # владелец/группа — только в производственном контуре (без швов адресатов):
  # в шов-мире chown — шим журнала, stat соврал бы о владельце
  if [ -z "${OPS_SERVER_SBIN_DST:-}" ] && [ -z "${OPS_SERVER_ETC_DST:-}" ]; then
    if [ "$(stat -c %U:%G -- "$1")" != "$2:$CIART_GROUP" ]; then
      printf 'ОТКАЗ: расхождение ci-artifacts: %s\n' "$1" >&2
      return 1
    fi
  fi
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
    # ── И-9/И-10: корни /var/lib/ci-artifacts/<репо> идемпотентно ────────────
    mkdir -p -- "$CIART_ROOT" || die_write "$CIART_ROOT"
    chown root:root -- "$CIART_ROOT" || die_write "chown $CIART_ROOT"
    chmod 755 -- "$CIART_ROOT" || die_write "chmod $CIART_ROOT"
    provision_root "$CIART_ROOT/Complior-mob" "$MOB_OWNER"
    provision_root "$CIART_ROOT/Complior-back" "$BACK_OWNER"
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
    # И-10: корни репо — режим 2775 в обоих контурах (клетка verify-roots),
    # владелец/группа — в производственном (без швов адресатов)
    check_root "$CIART_ROOT/Complior-mob" "$MOB_OWNER" || exit 1
    check_root "$CIART_ROOT/Complior-back" "$BACK_OWNER" || exit 1
    printf 'ci-artifacts: сверка 3/3\n'
    exit 0
    ;;
  *) usage ;;
esac
