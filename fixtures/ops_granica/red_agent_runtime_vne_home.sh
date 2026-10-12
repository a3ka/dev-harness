#!/usr/bin/env bash
# Клетка 9 (Рв2-6, слово владельца 2026-10-12) контракта 093 v2 — runtime
# агента ВНЕ /home/harness: исполняемый код агента (omp) живёт в
# /opt/orch-agent, состояние/сессии — /var/lib/orch-agent; orchagent НЕ
# входит в группу harness и НЕ получает доступа к .local/bin/.config
# владельца станции. Правила (грамматика приёмки 050 — «правило»; прецедент
# — приёмка п.8 grep-строки) по тексту субъекта:
#   R1 install.sh провизионит код агента в /opt/orch-agent → grep непуст;
#   R2 orch-loop ведёт агента из /opt/orch-agent → grep непуст;
#   R3 состояние /var/lib/orch-agent заявлено в обоих → grep непуст;
#   R4 никто не ведёт агента в станционный ~/.local/bin → grep пуст;
#   R5 orchagent не добавляется в группу harness → grep пуст.
# На ТЕКУЩЕМ HEAD (агентский код достижим только из /home/harness/.local/bin
# станции) R1/R2 КРАСНО — до-v2 расположение агента (Рв2-6).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${OPS093_ROOT:-$(cd "$HERE/../.." && pwd)}"
SUBJ_INSTALL="$ROOT/ops/server/install.sh"
SUBJ_LOOP="$ROOT/ops/server/user/orch-loop"
[ -f "$SUBJ_INSTALL" ] || { printf 'NOT_IMPLEMENTED: нет субъекта %s\n' "$SUBJ_INSTALL" >&2; exit 2; }
[ -f "$SUBJ_LOOP" ] || { printf 'NOT_IMPLEMENTED: нет субъекта %s\n' "$SUBJ_LOOP" >&2; exit 2; }

count_in() { # $1=ERE $2=файл → число строк-вхождений в stdout
  grep -Ec -- "$1" "$2" || true
}

# ── R1: код агента провизионится в /opt/orch-agent ───────────────────────────
n="$(count_in '/opt/orch-agent' "$SUBJ_INSTALL")"
if [ "$n" -eq 0 ]; then
  printf 'КРАСНО: install.sh не провизионит код агента в /opt/orch-agent (агентский исполняемый код живёт в /home/harness — Рв2-6): 0/ожидалось ≥1\n' >&2
  exit 1
fi

# ── R2: пускач ведёт агента из /opt/orch-agent ───────────────────────────────
n="$(count_in '/opt/orch-agent' "$SUBJ_LOOP")"
if [ "$n" -eq 0 ]; then
  printf 'КРАСНО: orch-loop не ведёт агента из /opt/orch-agent (omp открывается станционным путём /home/harness/.local/bin — Рв2-6): 0/ожидалось ≥1\n' >&2
  exit 1
fi

# ── R3: состояние/сессии агента — /var/lib/orch-agent в обоих ────────────────
ni="$(count_in '/var/lib/orch-agent' "$SUBJ_INSTALL")"
nl="$(count_in '/var/lib/orch-agent' "$SUBJ_LOOP")"
if [ "$ni" -eq 0 ] || [ "$nl" -eq 0 ]; then
  printf 'КРАСНО: состояние агента /var/lib/orch-agent не заявлено (install.sh: %s, orch-loop: %s — ожидалось ≥1 в обоих)\n' \
    "$ni" "$nl" >&2
  exit 1
fi

# ── R4: станционный ~/.local/bin не используется для агента ─────────────────
n="$(count_in '\.local/bin' "$SUBJ_INSTALL")"; n2="$(count_in '\.local/bin' "$SUBJ_LOOP")"
if [ "$((n + n2))" -ne 0 ]; then
  printf 'КРАСНО: субъект ведёт агента в станционный ~/.local/bin (install.sh: %s, orch-loop: %s — ожидалось 0)\n' \
    "$n" "$n2" >&2
  exit 1
fi

# ── R5: orchagent НЕ добавляется в группу harness ────────────────────────────
n="$(count_in '[-]a?G[[:space:]]+([^"]*harness)' "$SUBJ_INSTALL")"
if [ "$n" -ne 0 ]; then
  printf 'КРАСНО: install.sh добавляет orchagent в группу harness (%s вхождений — ожидалось 0, Рв2-6)\n' "$n" >&2
  exit 1
fi

printf 'ЗЕЛЁНО(093-9): runtime агента вне /home/harness: код /opt/orch-agent + состояние /var/lib/orch-agent, без .local/bin и группы harness (Рв2-6)\n' >&2
exit 0
