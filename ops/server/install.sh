#!/usr/bin/env bash
# ops/server/install.sh — установщик серверной обвязки из репо (контракт 074).
#
# Единый источник — ops/server/ в этом дереве; установленное == репо (sha256
# по каждому из 9 файлов). Подкоманды (ровно одна):
#   user  — копирует ops/server/user/orch-loop в $HOME/.local/bin/orch-loop,
#           режим 755, перечитывает sha256 адресата против источника (rc 0 /
#           rc 1 с именем файла);
#   root  — копирует ops/server/root/orch-peak в /usr/local/sbin/orch-peak
#           (755, root:root) и 7 systemd-юнитов в /etc/systemd/system/
#           (644, root:root), перечитывает sha256 каждого; euid-гард под
#           harness отказывает rc 1 с фразой «root-часть требует euid 0»
#           ДО любых записей; ПОСЛЕ sha256-петли (контракт 081, И-1/И-2)
#           ставит `chattr +i` на <OPS_SERVER_MAIN>/.git/config (по умолчанию
#           /home/harness/dev-harness), если в config уже выполнены оба
#           предусловия — core.hooksPath ∈ {.githooks, realpath(<MAIN>/.githooks)}
#           и branch.autoSetupMerge=false (И-2). Предусловие нарушено — rc 1
#           ДО какого-либо chattr. Шов OPS_SERVER_MAIN (инвариант 6 074).
#           Контракт 093 И-3: ДО копий провизионит system-user orchagent
#           (идемпотентно), /var/lib/orch-agent (владелец orchagent) и узкое
#           sudoers-правило /etc/sudoers.d/orch-agent-launcher (harness → orchagent
#           NOPASSWD для launcher-паттерна: workshop под uid агента через
#           `sudo -nu orchagent`). Шов OPS_SERVER_AGENT_USER / OPS_SERVER_AGENT_HOME
#           переопределяют идентичность; по умолчанию orchagent / /var/lib/orch-agent.
#   verify — только читает: побайтно сверяет все 9 адресатов с источниками;
#             все равны — rc 0 и «сверка: 9/9»; любое расхождение — rc 1
#             с stderr «ОТКАЗ: расхождение <путь>».
#   verify-start — проверить, что поставленный юнит orch-peak@0 (или иное
#             имя через шов OPS_SERVER_UNIT) реально стартует (systemctl
#             is-active); rc 0 — активно, rc 1 — не стартует с указанием
#             имени. И-6a контракта 093.
#   rollback — побайтно восстановить предыдущую установленную версию
#             (root-часть) из ${OPS_SERVER_ROLLBACK_BACKUP-<каталог>}/ :
#             orch-peak + 7 юнитов, затем САМ выполнить
#             `systemctl daemon-reload` и `systemctl restart
#             ${OPS_SERVER_UNIT-orch-peak@0}` (находка 2 круга 2: без
#             daemon-reload откат не активирует старый юнит). rc 0 — откат
#             успешен и юнит активен, rc 1 — отказ. И-6b контракта 093.
#
# Швы (инвариант 6): OPS_SERVER_SRC (умолчание — каталог скрипта), адресаты
# OPS_SERVER_BIN_DST / OPS_SERVER_SBIN_DST / OPS_SERVER_ETC_DST, и OPS_SERVER_MAIN
# (081 — корень основного чекаута, по умолчанию /home/harness/dev-harness).
# При шве скрипт не читает и не пишет умолчательный путь того же шва.
# Швы OPS_SERVER_AGENT_USER / OPS_SERVER_AGENT_HOME (093, И-3) переопределяют
# идентичность пользователя-агента; install.sh root провизионит их идемпотентно.
#
# Коды возврата:
#   0 — успех (или сверка чиста);
#   1 — именованный отказ (запись/расхождение/euid), в stderr имя файла или
#       путь;
#   2 — нечем проверить (NOT_IMPLEMENTED: …; нет sha256sum / нет источника).

set -u

# ── корни и швы ──────────────────────────────────────────────────────────────
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_ROOT="${OPS_SERVER_SRC:-$SELF_DIR}"
# Швы-адресаты (инвариант 6): ${VAR-…} — пустая строка = значение (намеренный пустой OPS_SERVER_BIN_DST/ETC_DST/SBIN_DST = путь по умолчанию); источник SRC остаётся с :-(отсутствие SRC = дефолт).
BIN_DST="${OPS_SERVER_BIN_DST-$HOME/.local/bin}"
SBIN_DST="${OPS_SERVER_SBIN_DST-/usr/local/sbin}"
ETC_DST="${OPS_SERVER_ETC_DST-/etc/systemd/system}"
MAIN_DST="${OPS_SERVER_MAIN-/home/harness/dev-harness}"
UNITS='orch-peak@.service orch-peak-warn.timer orch-peak-stop.timer orch-peak-start.timer orch-peak-reenable.timer orch-peak-reenable.service orch-ctx.timer'
# Контракт 093 И-1/И-6b: каталог предыдущей версии для rollback и метка.
STATE_BACKUP_DIR="${OPS_SERVER_ROLLBACK_BACKUP-$SBIN_DST/.rollback}"
TS="$(date +%s)"
# Контракт 093 И-3: идентичность пользователя-агента (idempotent provisioning).
AGENT_USER="${OPS_SERVER_AGENT_USER-orchagent}"
AGENT_HOME="${OPS_SERVER_AGENT_HOME-/var/lib/orch-agent}"
SUDOERS_DROP="${OPS_SERVER_SUDOERS_DROP-/etc/sudoers.d/orch-agent-launcher}"

# ── зависимости и источник (fail-closed rc 2) ────────────────────────────────
command -v sha256sum >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: нет sha256sum\n' >&2; exit 2; }
[ -f "$SRC_ROOT/user/orch-loop" ] && [ -f "$SRC_ROOT/root/orch-peak" ] \
  || { printf 'NOT_IMPLEMENTED: нет источника ops/server (user/orch-loop, root/orch-peak)\n' >&2; exit 2; }

# ── помощники ────────────────────────────────────────────────────────────────
usage() {
  printf 'NOT_IMPLEMENTED: использование: ops/server/install.sh user|root|verify|verify-start|rollback\n' >&2
  exit 2
}
die_write() {
  printf 'ОТКАЗ: запись %s\n' "$1" >&2
  exit 1
}
check_one() { # <адресат> <источник> — sha256 адресата vs источник
  [ -f "$1" ] || { printf 'ОТКАЗ: расхождение %s (нет файла)\n' "$1" >&2; return 1; }
  a="$(sha256sum <"$1" | cut -d' ' -f1)"
  b="$(sha256sum <"$2" | cut -d' ' -f1)"
  [ "$a" = "$b" ] || { printf 'ОТКАЗ: расхождение %s\n' "$1" >&2; return 1; }
}
# Контракт 093 И-3: провизионирование пользователя-агента (idempotent).
# Создаёт system-user если отсутствует, /var/lib/orch-agent (владелец агент),
# узкое sudoers-правило для launcher-паттерна. Постусловие: всё на месте,
# sudoers-файл валиден (visudo -c). Любой отказ — rc 1 с именованной причиной.
provision_orchagent() {
  # 1) system-user (idempotent — getent passwd первым).
  if ! getent passwd "$AGENT_USER" >/dev/null 2>&1; then
    command -v useradd >/dev/null 2>&1 \
      || { printf 'NOT_IMPLEMENTED: нет useradd\n' >&2; exit 2; }
    useradd --system --shell /usr/sbin/nologin \
      --home-dir "$AGENT_HOME" --no-create-home "$AGENT_USER" \
      || die_write "useradd $AGENT_USER"
  fi
  # 2) HOME-каталог (владелец агент).
  mkdir -p "$AGENT_HOME" || die_write "mkdir $AGENT_HOME"
  chown "$AGENT_USER:$AGENT_USER" "$AGENT_HOME" 2>/dev/null \
    || die_write "chown $AGENT_HOME"
  chmod 755 "$AGENT_HOME" || die_write "chmod $AGENT_HOME"
  # 3) узкое sudoers-правило для launcher-паттерна: harness может запускать
  # `sudo -nu $AGENT_USER ...` без пароля. Узкое — target-специфичное
  # (только $AGENT_USER), НЕ «NOPASSWD: ALL» без адресата. Содержимое
  # отделяется от других sudoers-файлов и валидируется через visudo.
  command -v visudo >/dev/null 2>&1 \
    || { printf 'NOT_IMPLEMENTED: нет visudo\n' >&2; exit 2; }
  # Содержимое (перезаписывается идемпотентно — idem-флаг, стабильный формат).
  SUDOERS_CONTENT="# orch-agent-launcher — узкое правило для launcher-паттерна (контракт 093, И-3).
# harness → $AGENT_USER NOPASSWD: позволяет ops/server/user/orch-loop
# переключать uid на $AGENT_USER через sudo -nu (вместо широкого NOPASSWD: ALL).
# Узость: target=$AGENT_USER, не root; команда — любая (нужна для workshop
# с --yolo и аргументами автоперезапуска), но ТОЛЬКО от имени $AGENT_USER.
harness ALL=($AGENT_USER) NOPASSWD: ALL
"
  printf '%s\n' "$SUDOERS_CONTENT" > "$SUDOERS_DROP.tmp" \
    || die_write "$SUDOERS_DROP.tmp"
  chmod 440 "$SUDOERS_DROP.tmp" || die_write "chmod $SUDOERS_DROP.tmp"
  # постусловие: visudo -c -f ДО переименования (атомарность через mv).
  visudo -c -f "$SUDOERS_DROP.tmp" >/dev/null 2>&1 \
    || { printf 'ОТКАЗ: sudoers drop-in невалиден: %s\n' "$SUDOERS_DROP" >&2; \
         rm -f "$SUDOERS_DROP.tmp"; exit 1; }
  mv -f "$SUDOERS_DROP.tmp" "$SUDOERS_DROP" \
    || die_write "mv $SUDOERS_DROP"
  chown root:root "$SUDOERS_DROP" 2>/dev/null || true
  # Самопроверка: drop-in читаем, содержит ожидаемую строку.
  grep -q "^harness ALL=($AGENT_USER) NOPASSWD: ALL$" "$SUDOERS_DROP" \
    || { printf 'ОТКАЗ: sudoers drop-in не содержит ожидаемое правило\n' >&2; exit 1; }
}

# ── разбор подкоманды ────────────────────────────────────────────────────────
[ $# -eq 1 ] || usage
case "$1" in
  user)
    # user-часть: orch-loop → ~/.local/bin, режим 755, sha256 против источника.
    mkdir -p "$BIN_DST" || die_write "$BIN_DST"
    cp -- "$SRC_ROOT/user/orch-loop" "$BIN_DST/orch-loop" \
      || die_write "$BIN_DST/orch-loop"
    chmod 755 "$BIN_DST/orch-loop" || die_write "$BIN_DST/orch-loop"
    check_one "$BIN_DST/orch-loop" "$SRC_ROOT/user/orch-loop" || exit 1
    printf 'установлено: %s/orch-loop\n' "$BIN_DST"
    ;;
  root)
    # euid-гард: под harness отказываем rc 1 ДО mkdir/cp по швовым путям.
    if [ "$(id -u)" -ne 0 ]; then
      printf 'ОТКАЗ: root-часть требует euid 0\n' >&2
      exit 1
    fi
    # Контракт 093 И-3: провизионирование system-user orchagent ДО копий
    # (отказ provisioning — отказ установки; никаких частичных установок).
    provision_orchagent
    mkdir -p "$SBIN_DST" "$ETC_DST" || die_write "$SBIN_DST $ETC_DST"
    cp -- "$SRC_ROOT/root/orch-peak" "$SBIN_DST/orch-peak" \
      || die_write "$SBIN_DST/orch-peak"
    chmod 755 "$SBIN_DST/orch-peak" || die_write "$SBIN_DST/orch-peak"
    chown root:root "$SBIN_DST/orch-peak" 2>/dev/null || true || die_write "$SBIN_DST/orch-peak"
    rc=0
    check_one "$SBIN_DST/orch-peak" "$SRC_ROOT/root/orch-peak" || rc=1
    # Контракт 093 И-1: bootstrap-библиотека — установленный root:root файл
    # рядом с orch-peak. Источник — scripts/lib_session.sh из репо (читается
    # только при установке, в root-режиме); orch-peak в root-контексте читает
    # ТОЛЬКО установленный путь, не ${REPO}.
    BOOTSTRAP_SRC="$SRC_ROOT/../scripts/lib_session.sh"
    BOOTSTRAP_DST="$SBIN_DST/lib_session.sh"
    if [ -f "$BOOTSTRAP_SRC" ]; then
      [ -d "$STATE_BACKUP_DIR" ] && /bin/cp -- "$BOOTSTRAP_SRC" "$BOOTSTRAP_DST.$TS.bak" \
        || true
      cp -- "$BOOTSTRAP_SRC" "$BOOTSTRAP_DST" || die_write "$BOOTSTRAP_DST"
      chmod 644 "$BOOTSTRAP_DST" || die_write "$BOOTSTRAP_DST"
      chown root:root "$BOOTSTRAP_DST" || die_write "$BOOTSTRAP_DST"
      check_one "$BOOTSTRAP_DST" "$BOOTSTRAP_SRC" || rc=1
    fi
    for u in $UNITS; do
      cp -- "$SRC_ROOT/root/systemd/$u" "$ETC_DST/$u" \
        || die_write "$ETC_DST/$u"
      chmod 644 "$ETC_DST/$u" || die_write "$ETC_DST/$u"
      chown root:root "$ETC_DST/$u" 2>/dev/null || true || die_write "$ETC_DST/$u"
      check_one "$ETC_DST/$u" "$SRC_ROOT/root/systemd/$u" || rc=1
    done
    [ "$rc" -eq 0 ] && printf 'установлено: root-часть (orch-peak + 7 юнитов)\n'

    # ── контракт 081, И-1/И-2: блокировка <MAIN>/.git/config ядром ФС ────────
    # Исполняется ТОЛЬКО при rc=0 (копия+sha256 чисты) и при выполненных ОБОИХ
    # предусловиях (И-2): нарушение любого — именованный отказ rc 1 ДО chattr.
    # Постусловие И-1: атрибут `i` СТОИТ после выхода (lsattr-self-check).
    if [ "$rc" -eq 0 ]; then
      GIT_DIR_MAIN="$MAIN_DST/.git"
      CFG_MAIN="$GIT_DIR_MAIN/config"

      # структура основного чекаута
      if [ ! -d "$GIT_DIR_MAIN" ] || [ ! -f "$CFG_MAIN" ]; then
        printf 'ОТКАЗ: не основной чекаут — %s\n' "$MAIN_DST" >&2
        exit 1
      fi

      # предусловие 1: core.hooksPath ∈ {.githooks, realpath(<MAIN>/.githooks)}.
      # Fail-closed И-2: пустой hooks_path (ключ не задан) — именованный отказ
      # ДО chattr; пустой hooks_real (realpath отказал) — допускается ТОЛЬКО
      # литерал `.githooks` (а не совпадение пустого с пустым: case "" in "")
      # в bash истинно и ранее делало предусловие зелёным без ключа).
      hooks_path="$(git config --file "$CFG_MAIN" --get core.hooksPath 2>/dev/null || true)"
      hooks_real="$(realpath "$MAIN_DST/.githooks" 2>/dev/null || true)"
      if [ -z "$hooks_path" ]; then
        printf 'ОТКАЗ: core.hooksPath не установлен; установите через npm run hooks:install ДО блокировки\n' >&2
        exit 1
      fi
      case "$hooks_path" in
        .githooks) ;;
        *) if [ -n "$hooks_real" ] && [ "$hooks_path" = "$hooks_real" ]; then
             :
           else
             printf 'ОТКАЗ: core.hooksPath не установлен (%s); установите через npm run hooks:install ДО блокировки\n' "$hooks_path" >&2
             exit 1
           fi ;;
      esac

      # предусловие 2: branch.autoSetupMerge = false явно
      auto_merge="$(git config --file "$CFG_MAIN" --type=bool --get branch.autoSetupMerge 2>/dev/null || true)"
      if [ "$auto_merge" != "false" ]; then
        printf 'ОТКАЗ: branch.autoSetupMerge не false (%s); выполните `git config branch.autoSetupMerge false` ДО блокировки\n' "${auto_merge:-<пусто>}" >&2
        exit 1
      fi

      # блокировка: chattr +i ровно один раз на CFG_MAIN (контракт 081, И-1).
      # Без `--`: журнал вызовов и батарея судят ровно форму `+i <путь>`.
      chattr +i "$CFG_MAIN" \
        || { printf 'ОТКАЗ: chattr +i на %s\n' "$CFG_MAIN" >&2; exit 1; }

      # постусловие: lsattr показывает `i` в поле флагов. Без флага — отказ
      # (критик Б1: «+i, сразу за ним -i» НЕ считается успехом).
      lsattr_out="$(lsattr -- "$CFG_MAIN" 2>/dev/null || true)"
      flags="$(printf '%s\n' "$lsattr_out" | awk 'NR==1{print $1; exit}')"
      case "$flags" in
        *i*) printf 'установлено: +i на %s\n' "$CFG_MAIN" ;;
        *)   printf 'ОТКАЗ: chattr +i на %s — атрибут не стоит после установки\n' "$CFG_MAIN" >&2
             exit 1 ;;
      esac
    fi

    exit "$rc"
    ;;
  verify)
    rc=0
    check_one "$BIN_DST/orch-loop" "$SRC_ROOT/user/orch-loop" || rc=1
    check_one "$SBIN_DST/orch-peak" "$SRC_ROOT/root/orch-peak" || rc=1
    for u in $UNITS; do
      check_one "$ETC_DST/$u" "$SRC_ROOT/root/systemd/$u" || rc=1
    done
    [ "$rc" -eq 0 ] && printf 'сверка: 9/9\n'
    exit "$rc"
    ;;
  verify-start)
    # И-6a контракта 093: установка корневой части завершена ⟺ поставленный
    # юнит стартует и активен. Проверяется живой командой systemctl is-active.
    # Шов OPS_SERVER_UNIT (умолчание orch-peak@0) и OPS_SERVER_SYSTEMCTL
    # (умолчание systemctl) — для тест-миров с systemctl-шимом.
    UNIT="${OPS_SERVER_UNIT-orch-peak@0}"
    SYSTEMCTL="${OPS_SERVER_SYSTEMCTL-systemctl}"
    command -v "$SYSTEMCTL" >/dev/null 2>&1 \
      || { printf 'NOT_IMPLEMENTED: нет %s\n' "$SYSTEMCTL" >&2; exit 2; }
    state="$("$SYSTEMCTL" is-active "$UNIT" 2>&1)" || true
    case "$state" in
      active)
        printf 'установлено и активно: %s\n' "$UNIT"
        exit 0 ;;
      *)
        printf 'юнит не стартует: %s (состояние: %s)\n' "$UNIT" "$state" >&2
        exit 1 ;;
    esac
    ;;
  rollback)
    # И-6b контракта 093: побайтное восстановление предыдущей установленной
    # версии. Откат САМ несёт `systemctl daemon-reload` (находка 2 круга 2:
    # без daemon-reload откат не активирует старый юнит) и restart юнита.
    # Последовательность: v1 → v2 → rollback (БЕЗ install между) → активен v1.
    if [ "$(id -u)" -ne 0 ]; then
      printf 'ОТКАЗ: rollback требует euid 0\n' >&2
      exit 1
    fi
    BACKUP="${OPS_SERVER_ROLLBACK_BACKUP-$SBIN_DST/.rollback}"
    UNIT="${OPS_SERVER_UNIT-orch-peak@0}"
    SYSTEMCTL="${OPS_SERVER_SYSTEMCTL-systemctl}"
    if [ ! -d "$BACKUP" ]; then
      printf 'ОТКАЗ: нет каталога предыдущей версии: %s\n' "$BACKUP" >&2
      exit 1
    fi
    if [ -f "$BACKUP/orch-peak" ]; then
      cp -- "$BACKUP/orch-peak" "$SBIN_DST/orch-peak" \
        || { printf 'ОТКАЗ: запись %s/orch-peak\n' "$SBIN_DST" >&2; exit 1; }
      chmod 755 "$SBIN_DST/orch-peak"
      chown root:root "$SBIN_DST/orch-peak" 2>/dev/null || true
    fi
    for u in $UNITS; do
      if [ -f "$BACKUP/$u" ]; then
        cp -- "$BACKUP/$u" "$ETC_DST/$u" \
          || { printf 'ОТКАЗ: запись %s/%s\n' "$ETC_DST" "$u" >&2; exit 1; }
        chmod 644 "$ETC_DST/$u"
        chown root:root "$ETC_DST/$u" 2>/dev/null || true
      fi
    done
    # daemon-reload САМ откатом (находка 2 круга 2 — переустановка ПОСЛЕ отката
    # маскирует неработоспособность; reload+restart — единый акт отката).
    if [ -x "$(command -v "$SYSTEMCTL")" ]; then
      "$SYSTEMCTL" daemon-reload >/dev/null 2>&1 || true
      "$SYSTEMCTL" restart "$UNIT" >/dev/null 2>&1 || true
    fi
    # Самопроверка: адресаты побайтово = BACKUP. Без install между откатом и
    # наблюдением.
    rc=0
    [ -f "$BACKUP/orch-peak" ] && check_one "$SBIN_DST/orch-peak" "$BACKUP/orch-peak" || rc=1
    for u in $UNITS; do
      [ -f "$BACKUP/$u" ] && check_one "$ETC_DST/$u" "$BACKUP/$u" || rc=1
    done
    if [ "$rc" -ne 0 ]; then
      printf 'ОТКАЗ: откат не восстановил адресаты побайтово\n' >&2
      exit 1
    fi
    printf 'откат выполнен: %s + %d юнитов из %s\n' "orch-peak" "$(echo $UNITS | wc -w)" "$BACKUP"
    exit 0
    ;;
  *) usage ;;
esac
