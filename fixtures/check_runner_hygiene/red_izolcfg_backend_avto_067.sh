#!/usr/bin/env bash
# КРАСНОЕ 067 (задача (б) владельца): isolation.backend: auto — конфиг изоляции
# спавна не пиннит файловую систему машины.
#
# СУБЪЕКТ: норма ключей .omp/config.yml + ветвь izolcfg барьера
# scripts/check_runner_hygiene.sh (грамматика ветви — часть предмета 067).
# СЕГОДНЯ (ДО реализации): конфиг живого дерева несёт легаси-пин
# task.isolation.mode: btrfs (пин машины: на ext4-сервере PAL omp сам откатывается
# в копию …/wt/<id>/m — замер 2026-10-01 в контракте 067 §Предмет); ветвь izolcfg
# (v1) благословляет легаси-пин и не знает новых ключей → ветвей 8, красных 3
# (к1, к2, к8 — записи живых прогонов в контракте 067 §Красные предъявления).
# ПОСЛЕ реализации (ОДНИМ коммитом: конфиг + ветвь izolcfg v2 + toy _lib.sh + строки
# ролей): ветвей 8, красных 0, зелёных 8.
#
# ГРАММАТИКА нормы (единый источник omp://tools/task.md:116 + omp://settings.md
# «Field-level migrations»; буквальные ключи):
#   task.isolation.enabled: true — вложенный ключ: `task:` → `  isolation:` →
#     `    enabled: true`;
#   isolation.backend: auto — ВЕРХНЕУРОВНЕВАЯ группа `isolation:` (БЕЗ отступа,
#     НЕ task.isolation.backend) → `  backend: auto`;
#   enum бэкендов omp (замкнутый): auto apfs btrfs zfs reflink overlayfs projfs
#     block-clone rcopy; легаси task.isolation.mode: <backend> мигрирует рантаймом
#     в enabled:true + isolation.backend:<backend> — пин машины, нормой 067 запрещён.
#
# Обманки привязаны к входам, где их дефект наблюдаем (Н-39; код фикстуры, не проза):
#   к1 «норма auto»       — честная пара ключей → ПРИНЯТ (сегодня v1 не знает
#                           ключей → красная);
#   к2 «без авто-детекта» — легаси task.isolation.mode: btrfs (ровно нынешнее
#                           живое дерево): btrfs-only, на ext4 живёт внутренним
#                           откатом PAL, не нормой → ОТВЕРГНУТ (сегодня v1
#                           ПРИНИМАЕТ пин → красная — главный флип предмета);
#   к3 «без отката»       — enabled:true + isolation.backend: btrfs: заявляет
#                           ФС-зависимый бэкенд без отката в норме → ОТВЕРГНУТ;
#   к4 «хардкод copy»     — isolation.backend: rcopy: на btrfs-домашней саботирует
#                           сабволюмы → ОТВЕРГНУТ;
#   к5 «изоляция выключена» — enabled: false → ОТВЕРГНУТ;
#   к6 «enabled без backend» — половина нормы, авто-детект не объявлен → ОТВЕРГНУТ;
#   к7 «backend не там»   — backend: auto ВЛОЖЕН в task.isolation (путь ключа
#                           перепутан с легаси) → ОТВЕРГНУТ;
#   к8 «выключено при auto» — enabled: false + ПРАВИЛЬНЫЙ верхнеуровневый
#                           isolation.backend: auto (различитель Б2 вердикта
#                           4305580): обход «v2 проверяет backend, игнорирует
#                           enabled» принимает этот вход → ОТВЕРГНУТ с причиной
#                           «enabled: false» в отказе.
# Анти-таутология: оракул — rc живой ветви izolcfg настоящего барьера (никаких
# копий грамматики здесь); каждая клетка ожидает честное поведение ветви на
# СВОЁМ входе; привязка вход↔клетка↔ожидание — этот код (Н-39, канон Arb064).
# Записи живых прогонов на ветке v1: к2 красна (v1 ПРИНИМАЕТ легаси-пин —
# главный флип предмета), к8 красна (v1 отвергает БЕЗ именованной причины
# «enabled: false»).
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
BARRIER="$ROOT/scripts/check_runner_hygiene.sh"
HYG="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
. "$HYG/_lib.sh"

[ -f "$BARRIER" ] || { printf 'КРАСНОЕ 067: нет субъекта-барьера %s\n' "$BARRIER" >&2; exit 1; }
[ -f "$HYG/_ref_runner.sh" ] || { printf 'КРАСНОЕ 067: нет _ref_runner.sh семьи\n' >&2; exit 1; }
WORK="$(mktemp -d "${TMPDIR:-/tmp}/red067.XXXXXX")" || { printf 'КРАСНОЕ 067: mktemp отказал\n' >&2; exit 1; }

# mk_cell <имя> — зелёный корень по конвенции семьи (_lib.sh), конфиг пишет клетка.
mk_cell() {
  mk_green_root "$WORK/$1"
}

ORDER=(к1-norma-avto к2-stab-legasi-pin к3-stab-pin-btrfs к4-stab-hardkod-rcopy к5-vykljucheno к6-bez-backend к7-backend-ne-tam к8-vykljucheno-s-backend)
declare -A ST RAN

# run_cell <имя> <ожидание: accept|reject> [обязательная подстрока причины] —
# живой прогон ветви izolcfg барьера. Третий аргумент — различитель Б2 (вердикт
# 4305580): причина отказа обязана нести его ДОСЛОВНО (grep -F); v1 отвергает
# к8 без именованной причины → клетка красная, обход «v2 без проверки enabled»
# даёт rc 0 → тоже красная, честная v2 — зелёная.
run_cell() {
  local name="$1" expect="$2" reason="${3:-}" rc
  bash "$BARRIER" "$WORK/$name" izolcfg >"$WORK/$name.out" 2>"$WORK/$name.err"
  rc=$?
  RAN[$name]=1; ST[$name]=1
  if [ "$expect" = accept ]; then
    if [ "$rc" -eq 0 ] && grep -q '(izolcfg)' "$WORK/$name.err"; then
      ST[$name]=0
    else
      printf 'ВЕТВЬ %s красная: ожидался ПРИЁМ нормы (rc 0 + ok (izolcfg)), получено rc=%s: %s\n' "$name" "$rc" "$(tr '\n' ' ' < "$WORK/$name.err")" >&2
    fi
  else
    if [ "$rc" -eq 1 ] && grep -q 'ОТКАЗ ветвь (izolcfg)' "$WORK/$name.err" \
       && { [ -z "$reason" ] || grep -qF -- "$reason" "$WORK/$name.err"; }; then
      ST[$name]=0
    else
      printf 'ВЕТВЬ %s красная: ожидался ОТКАЗ rc=1 с именованной причиной «ОТКАЗ ветвь (izolcfg)»%s, получено rc=%s: %s\n' "$name" "${reason:+ и дословной «$reason»}" "$rc" "$(tr '\n' ' ' < "$WORK/$name.err")" >&2
    fi
  fi
}

# ── к1: честная норма — task.isolation.enabled: true + верхнеуровневая isolation.backend: auto
mk_cell к1-norma-avto
cat > "$WORK/к1-norma-avto/.omp/config.yml" <<'EOF'
# Конфигурация (игрушечная — клетка к1 батареи 067: честная норма auto)
tools:
  approvalMode: always-ask

task:
  isolation:
    enabled: true

isolation:
  backend: auto
EOF
run_cell к1-norma-avto accept

# ── к2: стаб «без авто-детекта» — легаси-пин mode: btrfs (нынешнее живое дерево)
mk_cell к2-stab-legasi-pin
cat > "$WORK/к2-stab-legasi-pin/.omp/config.yml" <<'EOF'
# Конфигурация (игрушечная — клетка к2 батареи 067: легаси-пин машины)
tools:
  approvalMode: always-ask

task:
  isolation:
    mode: btrfs
EOF
run_cell к2-stab-legasi-pin reject

# ── к3: стаб «без отката» — явный пин btrfs новыми ключами
mk_cell к3-stab-pin-btrfs
cat > "$WORK/к3-stab-pin-btrfs/.omp/config.yml" <<'EOF'
# Конфигурация (игрушечная — клетка к3 батареи 067: пин btrfs без отката)
task:
  isolation:
    enabled: true

isolation:
  backend: btrfs
EOF
run_cell к3-stab-pin-btrfs reject

# ── к4: стаб «хардкод copy» — пин rcopy
mk_cell к4-stab-hardkod-rcopy
cat > "$WORK/к4-stab-hardkod-rcopy/.omp/config.yml" <<'EOF'
# Конфигурация (игрушечная — клетка к4 батареи 067: хардкод копии)
task:
  isolation:
    enabled: true

isolation:
  backend: rcopy
EOF
run_cell к4-stab-hardkod-rcopy reject

# ── к5: изоляция выключена
mk_cell к5-vykljucheno
cat > "$WORK/к5-vykljucheno/.omp/config.yml" <<'EOF'
# Конфигурация (игрушечная — клетка к5 батареи 067: изоляции нет)
task:
  isolation:
    enabled: false
EOF
run_cell к5-vykljucheno reject

# ── к6: половина нормы — enabled без backend
mk_cell к6-bez-backend
cat > "$WORK/к6-bez-backend/.omp/config.yml" <<'EOF'
# Конфигурация (игрушечная — клетка к6 батареи 067: авто-детект не объявлен)
task:
  isolation:
    enabled: true
EOF
run_cell к6-bez-backend reject

# ── к7: backend не там — вложен в task.isolation (легаси-путь)
mk_cell к7-backend-ne-tam
cat > "$WORK/к7-backend-ne-tam/.omp/config.yml" <<'EOF'
# Конфигурация (игрушечная — клетка к7 батареи 067: путь ключа перепутан)
task:
  isolation:
    enabled: true
    backend: auto
EOF
run_cell к7-backend-ne-tam reject

# ── к8 (Б2, вердикт 4305580): изоляция выключена ПРИ правильном backend —
# различающая пара к5 (тот же дефект enabled: false, но вторая половина нормы
# на месте): обход «v2 проверяет backend: auto, игнорирует enabled» принимает
# этот вход; честная v2 обязана отвергнуть с причиной «enabled: false».
mk_cell к8-vykljucheno-s-backend
cat > "$WORK/к8-vykljucheno-s-backend/.omp/config.yml" <<'EOF'
# Конфигурация (игрушечная — клетка к8 батареи 067: изоляция выключена, backend правильный)
task:
  isolation:
    enabled: false

isolation:
  backend: auto
EOF
run_cell к8-vykljucheno-s-backend reject 'enabled: false'

# ── Сводка: пустая выборка = дефект фикстуры (правило мер роли) ───────────────
RED=0; GRN=0; UNRUN=""
for m in "${ORDER[@]}"; do
  if [ -z "${RAN[$m]:-}" ]; then UNRUN="$UNRUN $m"; ST[$m]=1; fi
  if [ "${ST[$m]}" = 1 ]; then RED=$((RED+1)); else GRN=$((GRN+1)); fi
  printf 'ВЕТВЬ %s %s\n' "$m" "$([ "${ST[$m]}" = 1 ] && printf красная || printf зелёная)"
done
printf 'ИТОГ 067: ветвей %d, красных %d, зелёных %d\n' "${#ORDER[@]}" "$RED" "$GRN"
if [ -n "$UNRUN" ]; then
  printf 'КРАСНОЕ 067: клетки не прогнаны (дефект фикстуры):%s\n' "$UNRUN" >&2
  exit 1
fi
if [ "$RED" -ne 0 ]; then
  printf 'КРАСНОЕ 067: красных %d из %d — реализация 067 (конфиг + ветвь izolcfg v2) не в дереве\n' "$RED" "${#ORDER[@]}" >&2
  exit 1
fi
rm -rf "$WORK"
exit 0
