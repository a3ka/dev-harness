#!/usr/bin/env bash
# Клетка 8 (И-8, «Выход» п.1 — фикстурная половина) контракта 093.
# ПРЕДМЕТ (дословно; арбитраж 093 РЕШЕНИЕ п.1/П6а — граница УНАСЛЕДОВАНА):
#   вход-Б: клетка НЕ строит namespace и НЕ переключает uid; первой
#     ступенью, ДО любых попыток чтения, меряет УНАСЛЕДОВАННОЕ:
#     euid процесса ≠ uid владельца станции (владелец = uid-owner корня
#     чекаута $OPS093_ROOT); запуск под владельцем станции → rc 1
#     «раннер запущен под uid владельца станции: граница не установлена
#     снаружи»; под uid агента — попытки ТОЛЬКО ЧТЕНИЯ (без записи —
#     Н-219) реальных путей списка И-3 → каждая неуспешна (EACCES на
#     живой станции); успех чтения любого пути → rc 1 с именем пути;
#     ни одна не успешна → половина-Б зелёна.
#   вход-А (наблюдатель): вся семья прогнана подряд под фоновым
#     наблюдателем множества чтения реального orch-peak (подпуть SESS_GLOB
#     $UHOME/.local/state/dev-harness-sessions/*/zones/dev/.omp/profiles/dev/agent/sessions/--home-harness-dev-harness--/**
#     + /var/lib/orch-peak/**, опрос 0.05с, полный список путей+mtime,
#     без фильтра по имени — прецедент/техника 090
#     red_hermetic_no_real_sessions.sh) — реализация implementer; до неё
#     rc 2 NOT_IMPLEMENTED именованный, не тихий.
#
# Половина-Б реализована архитектором в до-заморозочном носителе: она
# измеряет среду САМОГО раннера (не субъект) и не зависит от implementer.
# Обманные стабы клетки 8 — в коде самой клетки (прецедент 090), два:
# (i) запись под множество чтения реального orch-peak (половина-А);
# (ii) самопереключение uid внутри раннера/клетки (половина-Б) — на входе
#     euid владельца станции, первый же замер ДО переключения даёт rc 1.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${OPS093_ROOT:-$(cd "$HERE/../.." && pwd)}"
[ -d "$ROOT" ] || { printf 'ОТКАЗ: корень %s не каталог\n' "$ROOT" >&2; exit 2; }

# ── Половина-Б, ступень 1: УНАСЛЕДОВАННЫЙ euid (до любых чтений) ─────────────
EUID_NOW="$(id -u)"
OWNER_UID="$(stat -c %u "$ROOT")" || { printf 'ОТКАЗ: не прочитан uid владельца %s\n' "$ROOT" >&2; exit 2; }
if [ "$EUID_NOW" = "$OWNER_UID" ]; then
  printf 'раннер запущен под uid владельца станции: граница не установлена снаружи (И-8б, арбитраж 093)\n' >&2
  exit 1
fi

# ── Половина-Б, ступень 2: попытки ТОЛЬКО ЧТЕНИЯ (Н-219) реальных путей И-3 ──
# HOME владельца станции — из passwd по OWNER_UID; абсолютный /var/lib/orch-peak
# входит в перечень безусловно (≥1 попытка всегда — пустая выборка красна).
OWNER_HOME="$(getent passwd "$OWNER_UID" | cut -d: -f6)"
[ -n "$OWNER_HOME" ] || { printf 'NOT_IMPLEMENTED: не определён HOME владельца станции (uid %s) — список И-3 неполон\n' "$OWNER_UID" >&2; exit 2; }
PYTII="${OWNER_HOME}/.ssh
${OWNER_HOME}/.ssh/authorized_keys
${OWNER_HOME}/.ssh/config
${OWNER_HOME}/.config
${OWNER_HOME}/.local/state/dev-harness-sessions
/var/lib/orch-peak"
popytki=0
utechki=''
while IFS= read -r p; do
  [ -n "$p" ] || continue
  popytki=$((popytki + 1))
  if [ -d "$p" ]; then
    ls "$p" >/dev/null 2>&1 && utechki="$utechki $p"
  else
    cat "$p" >/dev/null 2>&1 && utechki="$utechki $p"
  fi
done <<<"$PYTII"
if [ "$popytki" -eq 0 ]; then
  printf 'ОТКАЗ: ни одной попытки чтения — пустая выборка красна (И-8б)\n' >&2
  exit 1
fi
if [ -n "$utechki" ]; then
  printf 'контрольный путь станции прочитан под uid агента:%s (И-8б)\n' "$utechki" >&2
  exit 1
fi
printf 'половина-Б: граница унаследована (euid=%s ≠ владельца=%s), попыток чтения %s, утечек нет\n' "$EUID_NOW" "$OWNER_UID" "$popytki" >&2

# ── Половина-А: наблюдатель множества чтения реального orch-peak ─────────────
printf 'NOT_IMPLEMENTED: половина-А (наблюдатель) ждёт implementer (контракт 093 §Клетки, клетка 8)\n' >&2
exit 2
