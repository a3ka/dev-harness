#!/usr/bin/env bash
# ops/server/install.sh — установщик серверной обвязки из репо (контракт 074).
#
# Единый источник — ops/server/ в этом дереве; установленное == репо (sha256
# по каждому из 9 файлов). Подкоманды (ровно одна):
#   user  — копирует ops/server/user/orch-loop в $HOME/bin/orch-loop,
#           режим 755, перечитывает sha256 адресата против источника (rc 0 /
#           rc 1 с именем файла);
#   root  — копирует ops/server/root/orch-peak в /usr/local/sbin/orch-peak
#           (755, root:root) и 7 systemd-юнитов в /etc/systemd/system/
#           (644, root:root), перечитывает sha256 каждого; euid-гард под
#           harness отказывает rc 1 с фразой «root-часть требует euid 0»
#           ДО любых записей; при копировании bootstrap-библиотеки
#           lib_session.sh → <SBIN_DST>/lib_session.sh (644, root:root) пишет
#           её sha256-манифест <адресат>.sha256 (444, root:root) — доверенная
#           запись root-bootstrap orch-peak (И-1; А-1 круга 5); ПОСЛЕ
#           sha256-петли (контракт 081, И-1/И-2)
#           ставит `chattr +i` на <OPS_SERVER_MAIN>/.git/config (по умолчанию
#           /home/harness/dev-harness), если в config уже выполнены оба
#           предусловия — core.hooksPath ∈ {.githooks, realpath(<MAIN>/.githooks)}
#           и branch.autoSetupMerge=false (И-2). Предусловие нарушено — rc 1
#           ДО какого-либо chattr. Шов OPS_SERVER_MAIN (инвариант 6 074).
#           Контракт 093 И-6b: ДО копий сохраняет снимок ПРЕДЫДУЩЕЙ
#           установленной версии (orch-peak + lib_session.sh + 7 юнитов,
#           побайтово, атомарной заменой каталога) в
#           ${OPS_SERVER_ROLLBACK_BACKUP-<SBIN_DST>/.rollback} — со второй
#           установки (первой снимать нечего). Контракт 093 И-3: ПОСЛЕ
#           sha256-петли и блокировки провизионит system-user orchagent
#           (идемпотентно, БЕЗ группы harness — Рв2-6), /var/lib/orch-agent
#           (владелец orchagent), узкое sudoers-правило
#           /etc/sudoers.d/orch-agent-launcher (harness → orchagent
#           NOPASSWD для launcher-паттерна: workshop под uid агента через
#           `sudo -nu orchagent`) и — v2, Рв2-6 — исполняемый код агента
#           в /opt/orch-agent (зеркальная копия доверенного чекаута
#           OPS_SERVER_MAIN, rsync -a --delete, root:root, БЕЗ .env*:
#           публикационный токен агенту недоступен, И-4; пользовательские
#           пути станции не используются) — ТОЛЬКО в
#           производственном контуре (нет швов OPS_SERVER_SBIN_DST/
#           OPS_SERVER_ETC_DST); в шов-мире провизионинг пропускается
#           (тест-мир строит идентичность агента сам, шимами getent/sudo
#           — 085). Швы OPS_SERVER_AGENT_USER / OPS_SERVER_AGENT_HOME
#           переопределяют идентичность; по умолчанию orchagent /
#           /var/lib/orch-agent. Шов OPS_SERVER_AGENT_ROOT переопределяет
#           корень кода агента (по умолчанию /opt/orch-agent).
#   verify — только читает: побайтно сверяет все 9 адресатов с источниками;
#             все равны — rc 0 и «сверка: 9/9»; любое расхождение — rc 1
#             с stderr «ОТКАЗ: расхождение <путь>».
#   verify-start — проверить, что поставленный юнит orch-peak@0 (или иное
#             имя через шов OPS_SERVER_UNIT) ЗАВЕРШИЛ НОВЫЙ запуск ЭТОЙ
#             пробы (контракт 093 v2, Рв2-5: юнит — ONESHOT, после успеха
#             ActiveState=inactive — НОРМА, не сбой): сам выдаёт
#             systemctl restart, затем требует Result=success И свежий
#             ExecMainExitTimestamp (позже момента запуска пробы — старый
#             успех за новый запуск не считается); rc 0 — завершён
#             успешно, свежий запуск; rc 1 — именованный отказ с указанием
#             имени юнита. И-6a контракта 093.
#   rollback — побайтно восстановить предыдущую установленную версию
#             (root-часть) из ${OPS_SERVER_ROLLBACK_BACKUP-<каталог>}/ :
#             orch-peak + lib_session.sh + 7 юнитов (что есть в снимке),
#             затем САМ выполнить `systemctl daemon-reload` и `systemctl
#             restart ${OPS_SERVER_UNIT-orch-peak@0}` (находка 2 круга 2:
#             без daemon-reload откат не активирует старый юнит) и
#             ДОКАЗАТЬ ЗАВЕРШЕНИЕ НОВОГО запуска тем же критерием oneshot
#             (Result=success И свежий ExecMainExitTimestamp позже T0
#             отката; ActiveState=inactive — норма). rc 0 — откат успешен
#             и юнит завершил новый запуск успешно; rc 1 — именованный
#             отказ (нет каталога/снимка, расхождение, запуск не завершён
#             успехом или не свеж); rc 2 — нет systemctl. И-6b, Рв2-5.
#
# Швы (инвариант 6): OPS_SERVER_SRC (умолчание — каталог скрипта), адресаты
# OPS_SERVER_BIN_DST / OPS_SERVER_SBIN_DST / OPS_SERVER_ETC_DST, и OPS_SERVER_MAIN
# (081 — корень основного чекаута, по умолчанию /home/harness/dev-harness).
# При шве скрипт не читает и не пишет умолчательный путь того же шва.
# Швы OPS_SERVER_AGENT_USER / OPS_SERVER_AGENT_HOME (093, И-3) переопределяют
# идентичность пользователя-агента; install.sh root провизионит их идемпотентно.
# Шов OPS_SERVER_AGENT_ROOT (093, И-3 v2, Рв2-6) переопределяет корень
# исполняемого кода агента (по умолчанию /opt/orch-agent).
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
BIN_DST="${OPS_SERVER_BIN_DST-$HOME/bin}"
SBIN_DST="${OPS_SERVER_SBIN_DST-/usr/local/sbin}"
ETC_DST="${OPS_SERVER_ETC_DST-/etc/systemd/system}"
MAIN_DST="${OPS_SERVER_MAIN-/home/harness/dev-harness}"
UNITS='orch-peak@.service orch-peak-warn.timer orch-peak-stop.timer orch-peak-start.timer orch-peak-reenable.timer orch-peak-reenable.service orch-ctx.timer'
# Контракт 093 И-6b: каталог предыдущей версии для rollback.
STATE_BACKUP_DIR="${OPS_SERVER_ROLLBACK_BACKUP-$SBIN_DST/.rollback}"
# Контракт 093 И-3: идентичность пользователя-агента (idempotent provisioning).
AGENT_USER="${OPS_SERVER_AGENT_USER-orchagent}"
AGENT_HOME="${OPS_SERVER_AGENT_HOME-/var/lib/orch-agent}"
SUDOERS_DROP="${OPS_SERVER_SUDOERS_DROP-/etc/sudoers.d/orch-agent-launcher}"
# Контракт 093 И-3 (Рв2-6, v2): корень исполняемого кода агента.
AGENT_ROOT="${OPS_SERVER_AGENT_ROOT-/opt/orch-agent}"

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

# Контракт 093 И-3 (Рв2-6, v2): исполняемый код агента — /opt/orch-agent.
# Провизионится ИЗ доверенного чекаута $MAIN_DST (root-оператор запускает
# установщик из него): зеркальная копия rsync -a --delete (идемпотентно),
# БЕЗ креденшл станции — .env/.env.* исключены ДО копии (публикационный
# токен агенту недоступен, И-4). Владелец root:root: код агентом НЕ
# перезаписывается (целостность кода); состояние/сессии агента —
# $AGENT_HOME (/var/lib/orch-agent), НЕ здесь. Постусловие: каталог на
# месте, workshop исполняем. Любой отказ — rc 1 с именованной причиной.
provision_agent_code() {
  [ -d "$MAIN_DST" ] \
    || { printf 'ОТКАЗ: нет источника кода агента: %s\n' "$MAIN_DST" >&2; return 1; }
  command -v rsync >/dev/null 2>&1 \
    || { printf 'NOT_IMPLEMENTED: нет rsync\n' >&2; exit 2; }
  mkdir -p "$AGENT_ROOT" || die_write "$AGENT_ROOT"
  rsync -a --delete --exclude='.env' --exclude='.env.*' --exclude='.ssh' \
    "$MAIN_DST"/ "$AGENT_ROOT"/ || die_write "$AGENT_ROOT"
  chown -R root:root "$AGENT_ROOT" 2>/dev/null || die_write "chown -R $AGENT_ROOT"
  chmod 755 "$AGENT_ROOT" || die_write "chmod $AGENT_ROOT"
  [ -x "$AGENT_ROOT/workshop" ] \
    || { printf 'ОТКАЗ: в %s нет исполняемого workshop\n' "$AGENT_ROOT" >&2; return 1; }
  printf 'провизионинг кода агента: %s (из %s, без .env*)\n' "$AGENT_ROOT" "$MAIN_DST"
}

# ── И-6 v2 (Рв2-5, слово владельца 2026-10-12): доказательство завершения ───
# oneshot-запуска. Юнит — oneshot: ActiveState=inactive после успеха — НОРМА;
# критерий завершённости — Result=success И СВЕЖИЙ ExecMainExitTimestamp
# (позже t0 — момента start/restart ЭТОЙ пробы: старый успех за новый запуск
# не считается — обманный стаб s8 «stale-запуск»). Формат штампа: ns-целое
# (systemctl-шимы тест-миров, date +%s%N) либо дата systemd живой станции
# («Sun 2026-04-05 20:57:59 UTC») — обе формы приводятся к наносекундам и
# сравниваются с t0. Печатает именованную причину отказа (имя юнита
# добавляет вызывающий).
oneshot_new_run_done() { # <юнит> <t0-ns>: rc 0 ⟺ Result=success И штамп>t0
  local unit="$1" t0="$2" props result stamp stamp_ns
  props="$("$SYSTEMCTL" show "$unit" -p Result -p ExecMainExitTimestamp 2>&1)" \
    || { printf 'не прочитаны свойства завершения'; return 1; }
  result="$(printf '%s\n' "$props" | sed -n 's/^Result=//p' | tail -n 1)"
  stamp="$(printf '%s\n' "$props" | sed -n 's/^ExecMainExitTimestamp=//p' | tail -n 1)"
  if [ "$result" != success ]; then
    printf 'Result=%s' "${result:-<пусто>}"
    return 1
  fi
  case "$stamp" in
    '') printf 'нет ExecMainExitTimestamp'
        return 1 ;;
    *[!0-9]*)
        # живая станция: дата systemd → наносекунды
        stamp_ns="$(date -d "$stamp" +%s%N 2>/dev/null || true)"
        case "$stamp_ns" in
          ''|*[!0-9]*) printf 'ExecMainExitTimestamp не разобран: %s' "$stamp"
                       return 1 ;;
        esac
        stamp="$stamp_ns" ;;
  esac
  if [ "$stamp" -le "$t0" ]; then
    printf 'успех СТАРЫЙ: ExecMainExitTimestamp не свежий'
    return 1
  fi
  return 0
}
# ── разбор подкоманды ────────────────────────────────────────────────────────
[ $# -eq 1 ] || usage
case "$1" in
  user)
    # user-часть: orch-loop → ~/bin, режим 755, sha256 против источника.
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
    # ── И-6b (093): снимок ПРЕДЫДУЩЕЙ установленной версии ДО копий ───────
    # Побайтово: orch-peak + lib_session.sh + 7 юнитов; атомарная замена
    # каталога (tmp + mv). rollback восстанавливает ИМЕННО этот снимок —
    # «v1 → v2 → rollback → на месте v1». Первая установка: снимать нечего,
    # каталог не создаётся (Р1-1 круга 1: прежний код снимок не писал,
    # README обещал несуществующее).
    prev=0
    for f in "$SBIN_DST/orch-peak" "$SBIN_DST/lib_session.sh"; do
      [ -f "$f" ] && prev=1
    done
    for u in $UNITS; do [ -f "$ETC_DST/$u" ] && prev=1; done
    if [ "$prev" -eq 1 ]; then
      SNAP="$STATE_BACKUP_DIR.new.$$"
      rm -rf "$SNAP"; mkdir -p "$SNAP" || die_write "$SNAP"
      snap_cp() { # <адресат>: в снимок, если существует
        [ -f "$1" ] || return 0
        cp -- "$1" "$SNAP/${1##*/}" || die_write "$SNAP/${1##*/}"
      }
      snap_cp "$SBIN_DST/orch-peak"; snap_cp "$SBIN_DST/lib_session.sh"
      for u in $UNITS; do snap_cp "$ETC_DST/$u"; done
      rm -rf "$STATE_BACKUP_DIR"
      mv -- "$SNAP" "$STATE_BACKUP_DIR" || die_write "$STATE_BACKUP_DIR"
      printf 'снимок предыдущей версии: %s\n' "$STATE_BACKUP_DIR"
    fi
    mkdir -p "$SBIN_DST" "$ETC_DST" || die_write "$SBIN_DST $ETC_DST"
    cp -- "$SRC_ROOT/root/orch-peak" "$SBIN_DST/orch-peak" \
      || die_write "$SBIN_DST/orch-peak"
    chmod 755 "$SBIN_DST/orch-peak" || die_write "$SBIN_DST/orch-peak"
    chown root:root "$SBIN_DST/orch-peak" || die_write "$SBIN_DST/orch-peak"
    rc=0
    check_one "$SBIN_DST/orch-peak" "$SRC_ROOT/root/orch-peak" || rc=1
    # Контракт 093 И-1: bootstrap-библиотека — установленный root:root файл
    # рядом с orch-peak. Источник — scripts/lib_session.sh из репо (читается
    # только при установке, в root-режиме); orch-peak в root-контексте читает
    # ТОЛЬКО установленный путь, не ${REPO}.
    BOOTSTRAP_SRC="$SRC_ROOT/../../scripts/lib_session.sh"
    BOOTSTRAP_DST="$SBIN_DST/lib_session.sh"
    if [ -f "$BOOTSTRAP_SRC" ]; then
      # прежняя версия уже в $STATE_BACKUP_DIR (снимок И-6b выше); отдельная
      # .bak-копия рядом с адресатом удалена (мёртвый вес, Р1-1 круга 1)
      cp -- "$BOOTSTRAP_SRC" "$BOOTSTRAP_DST" || die_write "$BOOTSTRAP_DST"
      chmod 644 "$BOOTSTRAP_DST" || die_write "$BOOTSTRAP_DST"
      chown root:root "$BOOTSTRAP_DST" || die_write "$BOOTSTRAP_DST"
      check_one "$BOOTSTRAP_DST" "$BOOTSTRAP_SRC" || rc=1
      # А-1 (adversary 093-v2, круг 5): sha256-манифест установленной
      # bootstrap-библиотеки — доверенная запись root-bootstrap orch-peak
      # (И-1: подмена sha256 → именованный отказ сторожа ДО source).
      # Атомарная замена (tmp + mv): повторной установке не нужно право
      # записи в сам 444-файл; root:root 444 — перезапись не-root'ом
      # невозможна.
      BOOTSTRAP_SHA="$BOOTSTRAP_DST.sha256"
      BOOTSTRAP_SHA_NEW="$BOOTSTRAP_SHA.new.$$"
      if sha256sum <"$BOOTSTRAP_DST" | cut -d' ' -f1 > "$BOOTSTRAP_SHA_NEW" && [ -s "$BOOTSTRAP_SHA_NEW" ]; then
        chmod 444 "$BOOTSTRAP_SHA_NEW" || { rm -f "$BOOTSTRAP_SHA_NEW"; die_write "$BOOTSTRAP_SHA"; }
        chown root:root "$BOOTSTRAP_SHA_NEW" || { rm -f "$BOOTSTRAP_SHA_NEW"; die_write "$BOOTSTRAP_SHA"; }
        mv -f -- "$BOOTSTRAP_SHA_NEW" "$BOOTSTRAP_SHA" || die_write "$BOOTSTRAP_SHA"
      else
        rm -f "$BOOTSTRAP_SHA_NEW"
        printf 'ОТКАЗ: не записан sha256-манифест %s\n' "$BOOTSTRAP_SHA" >&2
        rc=1
      fi
    fi
    for u in $UNITS; do
      cp -- "$SRC_ROOT/root/systemd/$u" "$ETC_DST/$u" \
        || die_write "$ETC_DST/$u"
      chmod 644 "$ETC_DST/$u" || die_write "$ETC_DST/$u"
      chown root:root "$ETC_DST/$u" || die_write "$ETC_DST/$u"
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

    # Контракт 093 И-3: провизионирование system-user orchagent ПОСЛЕ копий
    # и блокировки .git/config, ТОЛЬКО в производственном контуре — когда
    # НЕ заданы швы адресатов root-части (OPS_SERVER_SBIN_DST/ETC_DST).
    # В шов-мире (песочницы 074/081/090/093-клеток) настоящий useradd и
    # /etc/sudoers.d из тест-мира ломали бы его rc (регрессия 081-И2 круга
    # 1: rc установщика в песочнице становился 1) — тест-мир строит
    # идентичность агента сам (шимы getent/sudo, прецедент 085).
    # Исполняется ТОЛЬКО если rc=0 на этой точке; отказ provisioning —
    # rc=1 (без прямого exit), затем общий exit "$rc".
    if [ "$rc" -eq 0 ]; then
      if [ -n "${OPS_SERVER_SBIN_DST:-}" ] || [ -n "${OPS_SERVER_ETC_DST:-}" ]; then
        printf 'шов-мир: провизионинг %s и кода агента пропущен (тест-мир по швам адресатов)\n' "$AGENT_USER"
      else
        provision_orchagent || rc=1
        provision_agent_code || rc=1
      fi
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
    # И-6a контракта 093 v2 (Рв2-5): юнит — ONESHOT; ActiveState=inactive
    # после успеха — НОРМА, не сбой. Установка root-части завершена ⟺ юнит
    # ЗАВЕРШИЛ НОВЫЙ запуск ЭТОЙ пробы: сами выдаём restart, затем требуем
    # Result=success И свежий ExecMainExitTimestamp (позже T0 пробы).
    # Швы OPS_SERVER_UNIT (умолчание orch-peak@0) и OPS_SERVER_SYSTEMCTL
    # (умолчание systemctl) — для тест-миров с systemctl-шимом.
    UNIT="${OPS_SERVER_UNIT-orch-peak@0}"
    SYSTEMCTL="${OPS_SERVER_SYSTEMCTL-systemctl}"
    command -v "$SYSTEMCTL" >/dev/null 2>&1 \
      || { printf 'NOT_IMPLEMENTED: нет %s\n' "$SYSTEMCTL" >&2; exit 2; }
    t0="$(date +%s%N)"
    "$SYSTEMCTL" restart "$UNIT" >/dev/null 2>&1 \
      || { printf 'юнит не стартует: %s (restart отказал)\n' "$UNIT" >&2; exit 1; }
    why="$(oneshot_new_run_done "$UNIT" "$t0")" \
      || { printf 'юнит не стартует: %s (%s)\n' "$UNIT" "$why" >&2; exit 1; }
    printf 'установлено: юнит %s завершён успешно, свежий запуск (Result=success; ActiveState=inactive — норма oneshot)\n' "$UNIT"
    exit 0
    ;;
  rollback)
    # И-6b контракта 093 v2 (Рв2-5): побайтное восстановление предыдущей
    # установленной версии (снимок пишется `install.sh root` ДО копий — см.
    # шапку). Откат САМ несёт `systemctl daemon-reload` (находка 2 круга 2:
    # без daemon-reload откат не активирует старый юнит), перезапускает юнит
    # и ДОКАЗЫВАЕТ ЗАВЕРШЕНИЕ НОВОГО запуска критерием oneshot (И-6:
    # Result=success + свежий ExecMainExitTimestamp; ActiveState=inactive —
    # норма). Последовательность приёма: v1 → v2 → rollback (БЕЗ install
    # между) → юнит завершил новый запуск успешно ИМЕННО на v1.
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
    # пустой снимок = предыдущей версии нет (первая установка не снимает)
    have=0
    for f in orch-peak lib_session.sh; do [ -f "$BACKUP/$f" ] && have=1; done
    for u in $UNITS; do [ -f "$BACKUP/$u" ] && have=1; done
    if [ "$have" -eq 0 ]; then
      printf 'ОТКАЗ: нет предыдущей версии: снимок пуст: %s\n' "$BACKUP" >&2
      exit 1
    fi
    if [ -f "$BACKUP/orch-peak" ]; then
      cp -- "$BACKUP/orch-peak" "$SBIN_DST/orch-peak" \
        || { printf 'ОТКАЗ: запись %s/orch-peak\n' "$SBIN_DST" >&2; exit 1; }
      chmod 755 "$SBIN_DST/orch-peak" || die_write "$SBIN_DST/orch-peak"
      chown root:root "$SBIN_DST/orch-peak" || die_write "$SBIN_DST/orch-peak"
    fi
    if [ -f "$BACKUP/lib_session.sh" ]; then
      cp -- "$BACKUP/lib_session.sh" "$SBIN_DST/lib_session.sh" \
        || { printf 'ОТКАЗ: запись %s/lib_session.sh\n' "$SBIN_DST" >&2; exit 1; }
      chmod 644 "$SBIN_DST/lib_session.sh" || die_write "$SBIN_DST/lib_session.sh"
      chown root:root "$SBIN_DST/lib_session.sh" || die_write "$SBIN_DST/lib_session.sh"
      # А-1 (круг 5): манифест пишется заново под восстановленную библиотеку —
      # v1-библиотека с v2-манифестом = отказ И-1 у сторожа; откат обязан
      # вернуть РАБОТОСПОСОБНУЮ версию. Атомарная замена, как при установке.
      ROLL_SHA="$SBIN_DST/lib_session.sh.sha256"
      ROLL_SHA_NEW="$ROLL_SHA.new.$$"
      if sha256sum <"$SBIN_DST/lib_session.sh" | cut -d' ' -f1 > "$ROLL_SHA_NEW" && [ -s "$ROLL_SHA_NEW" ]; then
        chmod 444 "$ROLL_SHA_NEW" || { rm -f "$ROLL_SHA_NEW"; die_write "$ROLL_SHA"; }
        chown root:root "$ROLL_SHA_NEW" || { rm -f "$ROLL_SHA_NEW"; die_write "$ROLL_SHA"; }
        mv -f -- "$ROLL_SHA_NEW" "$ROLL_SHA" || die_write "$ROLL_SHA"
      else
        rm -f "$ROLL_SHA_NEW"
        printf 'ОТКАЗ: не записан sha256-манифест %s\n' "$ROLL_SHA" >&2
        exit 1
      fi
    fi
    n_units=0
    for u in $UNITS; do
      if [ -f "$BACKUP/$u" ]; then
        cp -- "$BACKUP/$u" "$ETC_DST/$u" \
          || { printf 'ОТКАЗ: запись %s/%s\n' "$ETC_DST" "$u" >&2; exit 1; }
        chmod 644 "$ETC_DST/$u" || die_write "$ETC_DST/$u"
        chown root:root "$ETC_DST/$u" || die_write "$ETC_DST/$u"
        n_units=$((n_units + 1))
      fi
    done
    # Откат — единый акт: reload + restart + доказательство ЗАВЕРШЕНИЯ
    # НОВОГО запуска (И-6b v2, Рв2-5: юнит oneshot, ActiveState=inactive —
    # норма; Result=success И свежий ExecMainExitTimestamp позже T0 отката —
    # старый успех не считается; переустановка ПОСЛЕ отката маскирует
    # неработоспособность — находка 2 круга 2; отказ — именованный).
    command -v "$SYSTEMCTL" >/dev/null 2>&1 \
      || { printf 'NOT_IMPLEMENTED: нет %s\n' "$SYSTEMCTL" >&2; exit 2; }
    t0="$(date +%s%N)"
    "$SYSTEMCTL" daemon-reload >/dev/null 2>&1 \
      || { printf 'ОТКАЗ: rollback: daemon-reload не удался\n' >&2; exit 1; }
    "$SYSTEMCTL" restart "$UNIT" >/dev/null 2>&1 \
      || { printf 'ОТКАЗ: rollback: restart %s не удался\n' "$UNIT" >&2; exit 1; }
    why="$(oneshot_new_run_done "$UNIT" "$t0")" \
      || { printf 'ОТКАЗ: юнит не завершил новый запуск после отката: %s (%s)\n' "$UNIT" "$why" >&2; exit 1; }
    # Самопроверка: адресаты побайтово = BACKUP. Без install между откатом и
    # наблюдением.
    rc=0
    for f in orch-peak lib_session.sh; do
      if [ -f "$BACKUP/$f" ]; then check_one "$SBIN_DST/$f" "$BACKUP/$f" || rc=1; fi
    done
    for u in $UNITS; do
      if [ -f "$BACKUP/$u" ]; then check_one "$ETC_DST/$u" "$BACKUP/$u" || rc=1; fi
    done
    # А-1 (круг 5): манифест согласован с установленной библиотекой — иначе
    # откат оставил бы сторожа, который откажется стартовать (И-1).
    if [ -f "$SBIN_DST/lib_session.sh.sha256" ]; then
      [ "$(cut -d' ' -f1 "$SBIN_DST/lib_session.sh.sha256")" = "$(sha256sum <"$SBIN_DST/lib_session.sh" | cut -d' ' -f1)" ] \
        || { printf 'ОТКАЗ: расхождение %s\n' "$SBIN_DST/lib_session.sh.sha256" >&2; exit 1; }
    fi
    if [ "$rc" -ne 0 ]; then
      printf 'ОТКАЗ: откат не восстановил адресаты побайтово\n' >&2
      exit 1
    fi
    printf 'откат выполнен: orch-peak + %d юнитов из %s; юнит завершил новый запуск успешно (Result=success, свежий ExecMainExitTimestamp)\n' "$n_units" "$BACKUP"
    exit 0
    ;;
  *) usage ;;
esac
