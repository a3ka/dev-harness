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
#       no-copy оставляет сентинел); И (adversary 093-v4 BLOCKS, арбитраж
#       093-adversary-round-cap-v1 Р-4(б)) $AGENT_ROOT заранее несёт
#       ЧИТАЕМЫЕ (0644) stale credential-носители четырёх форм — .env,
#       .env.local (шаблон .env.*), sub/.env (вложенный: exclude-шаблон
#       rsync не топ-уровневый), .ssh/id_rsa → после install с rc 0 НИ
#       ОДНОГО из четырёх путей НЕТ (список в памяти клетки ДО вызова) и
#       find по именам .env/.env.*/.ssh на любой глубине ПУСТ; либо
#       install отказал rc≠0 строкой «ОТКАЗ:» с литеральным путём одного
#       из четырёх носителей (второй допустимый исход Р-4(а)).
#       Выбран критерий ОТСУТСТВИЯ, не «недоступен uid агента»: в
#       toy-мире chown — шим (exit 0, root-операция под harness-uid), и
#       «chown вне uid / chmod 000» наблюдать нечем — клетка бежит под
#       uid станции и прочтёт любой режим; отсутствие пути наблюдаемо
#       побайтно. rsync --delete БЕЗ --delete-excluded excluded-записи у
#       получателя НЕ трогает (замер 3 арбитража) — честный 96ec3a5b
#       здесь КРАСЕН именованно.
#     мир F дополнительно: toy-источник $MAIN_DST несёт свой .env-сентинел
#       (как станционный источник зеркала, замер 4 арбитража) → после
#       install в $AGENT_ROOT нет .env (исключение не снято), а sha256
#       источника .env до/после совпадает (зачистка — только у
#       получателя; источник не меняется ни на байт, Р-4(а)).
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

# Источник несёт свой .env-сентинел (как станционный $MAIN_DST, замер 4
# арбитража; содержимое — искусственное, станционный секрет не читается).
# ОРАКУЛ (правило 8): sha256 источника .env — в память ДО вызова; после
# install: источник неизменен побайтно, у получателя .env нет.
printf '%s\n' 'TOY_SRC_ENV_SENTINEL=not-a-real-credential' > "$SCRATCH/main/.env"
chmod 600 "$SCRATCH/main/.env"
SRC_ENV_SHA="$(sha256sum <"$SCRATCH/main/.env" | cut -d' ' -f1)"
case "$SRC_ENV_SHA" in ''|*[!0-9a-f]*) \
  printf 'NOT_IMPLEMENTED: оракул источника .env не снят (%s)\n' "$SRC_ENV_SHA" >&2; exit 2 ;; esac

# Носители credential у получателя: имена, которые provision_agent_code
# ИСКЛЮЧАЕТ из копии — и которые rsync --delete без --delete-excluded у
# получателя НЕ удаляет (adversary 093-v4). Единый источник грамматики имён
# для find ниже и для списка stale-путей мира S.
carriers_under() { # $1=каталог → абсолютные пути записей-носителей на любой глубине
  find "$1" \( -name '.env' -o -name '.env.*' -o -name '.ssh' \) -print 2>/dev/null | LC_ALL=C sort
}
src_env_unchanged() { # → 0 если источник .env на месте и sha == оракулу
  [ -f "$SCRATCH/main/.env" ] || return 1
  [ "$(sha256sum <"$SCRATCH/main/.env" | cut -d' ' -f1)" = "$SRC_ENV_SHA" ]
}

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
# Мир S, stale credential-носители (adversary 093-v4): ЧИТАЕМЫЕ 0644, четыре
# формы — топ-уровневый .env, .env.local (шаблон .env.*), вложенный sub/.env,
# .ssh/id_rsa. Список путей — В ПАМЯТИ клетки до вызова субъекта (правило 8).
mkdir -p "$SCRATCH/agent_root_S/sub" "$SCRATCH/agent_root_S/.ssh"
STALE_PATHS=(
  "$SCRATCH/agent_root_S/.env"
  "$SCRATCH/agent_root_S/.env.local"
  "$SCRATCH/agent_root_S/sub/.env"
  "$SCRATCH/agent_root_S/.ssh/id_rsa"
)
for p in "${STALE_PATHS[@]}"; do
  printf '%s\n' 'OLD-RW-CREDENTIAL-SENTINEL' > "$p"
  chmod 644 "$p"
  [ -r "$p" ] || { printf 'NOT_IMPLEMENTED: stale-носитель %s не создан читаемым\n' "$p" >&2; exit 2; }
done
# Вырожденный мир S красен как НЕЧЕМ проверять: find обязан видеть ровно
# ТЕ ЖЕ записи ДО вызова (.env, .env.local, sub/.env, .ssh — 4 строки:
# .ssh/id_rsa внутри .ssh не матчится по имени, матчится каталог .ssh).
PRE_CARRIERS="$(carriers_under "$SCRATCH/agent_root_S")"
pre_n="$(printf '%s\n' "$PRE_CARRIERS" | grep -c .)"
if [ "$pre_n" -ne 4 ]; then
  printf 'NOT_IMPLEMENTED: вырожденный мир S — find видит %s носителей вместо 4 до вызова\n' "$pre_n" >&2
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
# Мир F, носители: источник несёт .env — у получателя его быть не должно
# (исключение снято → копия источника = credential у агента), источник
# неизменен побайтно (зачистка только у получателя, Р-4(а)).
carF="$(carriers_under "$SCRATCH/agent_root_F")"
if [ -n "$carF" ]; then
  printf 'КРАСНО: мир F: credential-носитель скопирован из источника в runtime агента (исключение .env/.env.*/.ssh снято, И-4):\n%s\n' "$carF" >&2
  exit 1
fi
src_env_unchanged || { printf 'КРАСНО: мир F: источник %s изменён или удалён install (зачистка обязана быть только у получателя, Р-4(а))\n' "$SCRATCH/main/.env" >&2; exit 1; }

# ── Мир S: старая/подменённая станция (сентинел ДО install) ──────────────────
run_install "$SCRATCH/agent_root_S" "$SCRATCH/inst_S"; rcS=$?
if [ "$rcS" -ne 0 ]; then
  # Второй допустимый исход Р-4(а): именованный отказ rc≠0 — строка «ОТКАЗ:»
  # лога обязана нести ЛИТЕРАЛЬНЫЙ путь одного из stale-носителей из памяти
  # клетки: четыре файла STALE_PATHS либо четыре записи find до вызова
  # (PRE_CARRIERS — включая каталог .ssh); grep -F по пути, не по подстроке
  # «.env» где угодно. Любой иной отказ — провал провизионинга, как прежде.
  named=0
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    if grep -F -- "$p" "$SCRATCH/inst_S" | grep -q '^ОТКАЗ:'; then named=1; break; fi
  done < <(printf '%s\n' "${STALE_PATHS[@]}" "$PRE_CARRIERS")
  if [ "$named" -eq 1 ]; then
    src_env_unchanged || { printf 'КРАСНО: мир S: отказ именован, но источник %s изменён или удалён install\n' "$SCRATCH/main/.env" >&2; exit 1; }
    printf 'мир S: install отказал rc=%s именованно по stale-носителю (допустимый исход Р-4(а)):\n%s\n' \
      "$rcS" "$(grep '^ОТКАЗ:' "$SCRATCH/inst_S" | head -n 3)" >&2
  else
    printf 'КРАСНО: install root в мире S (старая станция) rc=%s — провизионинг кода агента отказал без именованного stale-носителя:\n%s\n' \
      "$rcS" "$(tail -n 3 "$SCRATCH/inst_S")" >&2
    exit 1
  fi
else
  shaS="$(sha256sum <"$SCRATCH/agent_root_S/workshop" | cut -d' ' -f1)"
  if [ "$shaS" != "$ORACLE_SHA" ]; then
    printf 'КРАСНО: мир S: устаревший/подменённый workshop пережил install (sha256 %s ≠ оракулу %s) — код агента не скопирован (no-copy, adversary 093-v3)\n' \
      "$shaS" "$ORACLE_SHA" >&2
    exit 1
  fi
  # Stale credential-носители (adversary 093-v4): каждый из четырёх путей
  # из памяти — ОТСУТСТВУЕТ (-e ложно: chmod 000/chown в toy-мире не
  # наблюдаемы, см. шапку); затем find по именам на любой глубине — пуст.
  survived=""
  for p in "${STALE_PATHS[@]}"; do
    [ -e "$p" ] && survived="$survived$p"$'\n'
  done
  if [ -n "$survived" ]; then
    printf 'КРАСНО: мир S: старый credential-носитель пережил install root (rc 0, читаем uid агента после chown root:root 0644) — rsync --delete без --delete-excluded не трогает excluded-записи у получателя (adversary 093-v4):\n%s' "$survived" >&2
    exit 1
  fi
  carS="$(carriers_under "$SCRATCH/agent_root_S")"
  if [ -n "$carS" ]; then
    printf 'КРАСНО: мир S: после install в runtime агента остались записи .env/.env.*/.ssh вне списка памяти (adversary 093-v4):\n%s\n' "$carS" >&2
    exit 1
  fi
  src_env_unchanged || { printf 'КРАСНО: мир S: источник %s изменён или удалён install (зачистка обязана быть только у получателя, Р-4(а))\n' "$SCRATCH/main/.env" >&2; exit 1; }
fi

printf 'ЗЕЛЁНО(093-9): runtime агента вне /home/harness: код /opt/orch-agent + состояние /var/lib/orch-agent, без .local/bin и группы harness (Рв2-6); install root доставляет workshop побайтовно в мирах F/S (оракул sha256 в памяти — adversary 093-v3 закрыт); stale .env/.env.*/sub/.env/.ssh у получателя не переживают install, источник .env неизменен (adversary 093-v4 закрыт)\n' >&2
exit 0
