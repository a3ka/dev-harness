#!/usr/bin/env bash
# Клетка 9 (Рв2-6, слово владельца 2026-10-12) контракта 093 v2 — runtime
# агента ВНЕ /home/harness: исполняемый код агента (omp) живёт в
# /opt/orch-agent, состояние/сессии — /var/lib/orch-agent; orchagent НЕ
# входит в группу harness и НЕ получает доступа к .local/bin/.config
# владельца станции. Два слоя:
#   ТЕКСТ — правила R1–R5 по грамматике приёмки 050 («правило»; прецедент —
#   приёмка п.8 grep-строки; контракт 093 §Клетки п.9 дословно, критерий
#   не меняется):
#     R1 install.sh провизионит код агента в /opt/orch-agent → grep непуст;
#     R2 orch-loop ведёт агента из /opt/orch-agent → grep непуст;
#     R3 состояние /var/lib/orch-agent заявлено в обоих → grep непуст;
#     R4 никто не ведёт агента в станционный ~/.local/bin → grep пуст;
#     R5 orchagent не добавляется в группу harness → grep пуст.
#   ПОВЕДЕНИЕ (adversary 093-v3 BLOCKS: текстовая клетка пропускала no-copy
#   мутант — rsync в provision_agent_code заменён успешным no-op,
#   декларации путей оставлены): toy-root install РЕАЛЬНЫМ install.sh root
#   (прецедент клетки 1: шимы id/chown/chattr/lsattr, toy-адресаты швов;
#   шов OPS_SERVER_AGENT_ROOT делает провизионинг кода агента достижимым
#   в шов-мире) в ДВУХ мирах, каждый — своё предъявление:
#     мир F (чистая станция): $AGENT_ROOT заранее ОТСУТСТВУЕТ → после
#       install: workshop существует, исполним, sha256 == оракулу;
#     мир S (старая/подменённая станция): $AGENT_ROOT/workshop заранее
#       несёт ИНЫЕ байты (сентинел ≠ источнику) → после install:
#       sha256 == оракулу (честный rsync --delete затирает старое;
#       no-copy оставляет сентинел).
#   Оракул — sha256 workshop источника (toy-MAIN), снятый В ПАМЯТЬ ДО
#   вызова субъекта (правило 8): источник после вызова не перечитывается,
#   установленное сверяется только с памятью клетки. Мутант no-copy красен
#   в ОБЕИХ мирах (F: install отказал именованно «нет исполняемого
#   workshop»; S: байты установленного ≠ оракулу).
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

# ── ПОВЕДЕНИЕ (adversary 093-v3): install root доставляет runtime агента ─────
command -v rsync >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: нет rsync (поведенческая проба клетки 9)\n' >&2; exit 2; }
command -v sha256sum >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: нет sha256sum\n' >&2; exit 2; }

SCRATCH="$(mktemp -d /tmp/dev-harness-verify/ops-granica-9-XXXXXX)" || { printf 'NOT_IMPLEMENTED: mktemp\n' >&2; exit 2; }
trap 'rm -rf "$SCRATCH"' EXIT

# Toy-мир установщика (прецедент клетки 1): шимы root-станции в PATH,
# toy-адресаты всех швов; доверенный чекаут toy-main несёт workshop —
# источник кода агента.
mkdir -p "$SCRATCH/bin" "$SCRATCH/main/.git" "$SCRATCH/main/.githooks" \
  "$SCRATCH/sbin" "$SCRATCH/etc" "$SCRATCH/bindst" "$SCRATCH/sudoers" \
  "$SCRATCH/agent_home" "$SCRATCH/rollback"

# id: root-гард субъекта обязан проходить (модель euid 0, прецедент клетки 1).
printf '%s\n' '#!/usr/bin/env bash' \
  '[ "${1:-}" = "-u" ] && { printf "0\n"; exit 0; }' \
  'printf "uid=0(root) gid=0(root) groups=0(root)\n"; exit 0' > "$SCRATCH/bin/id"
# chown: реальный chown root:root под harness-uid отказал бы EPERM — модель
# root-станции (прецедент клетки 6/1); chattr/lsattr — блок 081 на toy-конфиге.
printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "$SCRATCH/bin/chown"
printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "$SCRATCH/bin/chattr"
printf '%s\n' '#!/usr/bin/env bash' \
  'for a in "$@"; do [ "$a" = "--" ] && continue; case "$a" in -*) continue;; esac' \
  '  printf -- "----i--------- %s\n" "$a"; break; done' \
  'exit 0' > "$SCRATCH/bin/lsattr"
chmod 755 "$SCRATCH"/bin/{id,chown,chattr,lsattr}

printf '%s\n' '[core]' '	hooksPath = .githooks' '[branch]' '	autoSetupMerge = false' \
  > "$SCRATCH/main/.git/config"

# Источник кода агента и ОРАКУЛ (правило 8): sha256 workshop снимается В
# ПАМЯТЬ ДО вызова субъекта; после install источник не перечитывается.
printf '%s\n' '#!/usr/bin/env bash' 'echo toy-agent-runtime-v1' > "$SCRATCH/main/workshop"
chmod 755 "$SCRATCH/main/workshop"
ORACLE_SHA="$(sha256sum <"$SCRATCH/main/workshop" | cut -d' ' -f1)"
case "$ORACLE_SHA" in ''|*[!0-9a-f]*) \
  printf 'NOT_IMPLEMENTED: оракул workshop не снят (%s)\n' "$ORACLE_SHA" >&2; exit 2 ;; esac

# Мир S: заранее устаревший/подменённый runtime (сентинел ≠ источнику —
# вырожденный мир S красен как НЕЧЕМ проверять, пустая проба не зелёнится).
mkdir -p "$SCRATCH/agent_root_S"
printf '%s\n' '#!/usr/bin/env bash' 'echo STALE-workshop-OLD' > "$SCRATCH/agent_root_S/workshop"
chmod 755 "$SCRATCH/agent_root_S/workshop"
STALE_SHA="$(sha256sum <"$SCRATCH/agent_root_S/workshop" | cut -d' ' -f1)"
if [ "$STALE_SHA" = "$ORACLE_SHA" ]; then
  printf 'NOT_IMPLEMENTED: вырожденный мир S (сентинел == источнику)\n' >&2
  exit 2
fi

run_install() { # $1=AGENT_ROOT $2=логфайл → rc установщика
  env PATH="$SCRATCH/bin:$PATH" HOME="$SCRATCH" \
    OPS_SERVER_SRC="$ROOT/ops/server" \
    OPS_SERVER_BIN_DST="$SCRATCH/bindst" \
    OPS_SERVER_SBIN_DST="$SCRATCH/sbin" \
    OPS_SERVER_ETC_DST="$SCRATCH/etc" \
    OPS_SERVER_MAIN="$SCRATCH/main" \
    OPS_SERVER_ROLLBACK_BACKUP="$SCRATCH/rollback" \
    OPS_SERVER_AGENT_USER="toyagent" \
    OPS_SERVER_AGENT_HOME="$SCRATCH/agent_home" \
    OPS_SERVER_SUDOERS_DROP="$SCRATCH/sudoers/launch" \
    OPS_SERVER_AGENT_ROOT="$1" \
    bash "$SUBJ_INSTALL" root >"$2" 2>&1
}

# ── Мир F: чистая станция (AGENT_ROOT отсутствует ДО install) ────────────────
run_install "$SCRATCH/agent_root_F" "$SCRATCH/inst_F"; rcF=$?
if [ "$rcF" -ne 0 ]; then
  printf 'КРАСНО: install root в мире F (чистая станция) rc=%s — провизионинг кода агента отказал:\n%s\n' \
    "$rcF" "$(tail -n 3 "$SCRATCH/inst_F")" >&2
  exit 1
fi
if [ ! -f "$SCRATCH/agent_root_F/workshop" ]; then
  printf 'КРАСНО: мир F: runtime агента не доставлен — нет %s (no-copy, adversary 093-v3)\n' \
    "$SCRATCH/agent_root_F/workshop" >&2
  exit 1
fi
[ -x "$SCRATCH/agent_root_F/workshop" ] || { printf 'КРАСНО: мир F: установленный workshop не исполним\n' >&2; exit 1; }
shaF="$(sha256sum <"$SCRATCH/agent_root_F/workshop" | cut -d' ' -f1)"
if [ "$shaF" != "$ORACLE_SHA" ]; then
  printf 'КРАСНО: мир F: байты установленного workshop ≠ источнику (sha256 %s ≠ оракул %s — adversary 093-v3)\n' \
    "$shaF" "$ORACLE_SHA" >&2
  exit 1
fi

# ── Мир S: старая/подменённая станция (сентинел ДО install) ──────────────────
run_install "$SCRATCH/agent_root_S" "$SCRATCH/inst_S"; rcS=$?
if [ "$rcS" -ne 0 ]; then
  printf 'КРАСНО: install root в мире S (старая станция) rc=%s — провизионинг кода агента отказал:\n%s\n' \
    "$rcS" "$(tail -n 3 "$SCRATCH/inst_S")" >&2
  exit 1
fi
shaS="$(sha256sum <"$SCRATCH/agent_root_S/workshop" | cut -d' ' -f1)"
if [ "$shaS" != "$ORACLE_SHA" ]; then
  printf 'КРАСНО: мир S: устаревший/подменённый workshop пережил install (sha256 %s ≠ оракулу %s) — код агента не скопирован (no-copy, adversary 093-v3)\n' \
    "$shaS" "$ORACLE_SHA" >&2
  exit 1
fi

printf 'ЗЕЛЁНО(093-9): runtime агента вне /home/harness: код /opt/orch-agent + состояние /var/lib/orch-agent, без .local/bin и группы harness (Рв2-6); install root доставляет workshop побайтовно в мирах F/S (оракул sha256 в памяти — adversary 093-v3 закрыт)\n' >&2
exit 0
