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
#                           откатом PAL, не нормой → ОТВЕРГНУТ с маркером
#                           LEGACY_MODE (сегодня v1 ПРИНИМАЕТ пин → красная —
#                           главный флип предмета);
#   к3 «без отката»       — enabled:true + isolation.backend: btrfs: заявляет
#                           ФС-зависимый бэкенд без отката в норме →
#                           ОТВЕРГНУТ с маркером PINNED_BACKEND;
#   к4 «хардкод copy»     — isolation.backend: rcopy: на btrfs-домашней саботирует
#                           сабволюмы → ОТВЕРГНУТ с маркером PINNED_BACKEND;
#   к5 «изоляция выключена» — enabled: false → ОТВЕРГНУТ с маркером
#                           «enabled: false»;
#   к6 «enabled без backend» — половина нормы, авто-детект не объявлен →
#                           ОТВЕРГНУТ с маркером HALF;
#   к7 «backend не там»   — backend: auto ВЛОЖЕН в task.isolation (путь ключа
#                           перепутан с легаси) → ОТВЕРГНУТ с маркером
#                           LEGACY_PATH;
#   к8 «выключено при auto» — enabled: false + ПРАВИЛЬНЫЙ верхнеуровневый
#                           isolation.backend: auto (различитель Б2 вердикта
#                           4305580): обход «v2 проверяет backend, игнорирует
#                           enabled» принимает этот вход → ОТВЕРГНУТ с причиной
#                           «enabled: false» в отказе;
#   к9 «sibling-isolation» — enabled:true живёт в ДРУГОМ ключе task-блока
#                           (sibling: `retry:`/`  isolation:`/`    enabled: true`),
#                           верхнеуровневый backend:auto на месте. omp видит
#                           `task.isolation.enabled` = false (рантайм не
#                           спускается в retry); структурная грамматика обязана
#                           отвергнуть как HALF (одна половина нормы вне
#                           глубины task.isolation) — находка Р-1;
#   к10 «deep-isolation»  — enabled:true живёт в task.nested.isolation (глубже
#                           task.isolation); верхнеуровневый backend:auto на
#                           месте. omp видит `task.isolation.enabled` = false.
#                           Структурная грамматика отвергает как HALF — Р-1;
#   к11 «trailing-backend»— верхнеуровневый `isolation:`/`  backend: auto btrfs`
#                           (хвост значения); omp PAL откатывается в дефолт
#                           auto, но замороженная грамматика «значение с
#                           хвостом не совпадают» (инв. 4) требует
#                           PINNED_BACKEND — Р-2;
#   к12 «extra-nested-backend» — backend:auto ВЛОЖЕН в `isolation:`/`  extra:`
#                           (не на верхнеуровневой глубине пары), а честный
#                           task.isolation.enabled:true объявлен. Структурная
#                           грамматика обязана различать верхнюю группу и
#                           вложение (С-2) — отказ HALF;
#   к13 «чужой-enabled» — task:/isolation:/enabled: false СОСЕДСТВУЕТ с
#                           task:/other:/enabled: true + верхний backend:auto.
#                           Барьер не должен «проглотить» true из другой
#                           подсекции: omp видит enabled=false, ветвь
#                           обязана отвергнуть с «enabled: false» — Р-1
#                           различение по флагу in_task_isol.
# Анти-таутология: оракул — rc живой ветви izolcfg настоящего барьера (никаких
# копий грамматики здесь); каждая клетка ожидает честное поведение ветви на
# СВОЁМ входе; привязка вход↔клетка↔ожидание — этот код (Н-39, канон Arb064).
# Записи живых прогонов на ветке v1: к2 красна (v1 ПРИНИМАЕТ легаси-пин —
# главный флип предмета), к8 красна (v1 отвергает БЕЗ именованной причины
# «enabled: false»). Усиление по вердикту адверсария 067-v1 (Д1/Д2): клетки
# к9–к13 суживают структурную грамматику (Р-1/Р-2/С-2), к2–к7 пинуют
# именованные причины LEGACY_MODE/PINNED_BACKEND/LEGACY_PATH/HALF (прецедент
# 005).
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

ORDER=(к1-norma-avto к2-stab-legasi-pin к3-stab-pin-btrfs к4-stab-hardkod-rcopy к5-vykljucheno к6-bez-backend к7-backend-ne-tam к8-vykljucheno-s-backend к9-sibling-stab к10-deep-stab к11-trailing-backend к12-extra-nested-backend к13-chuzhoj-enabled)
declare -A ST RAN

# run_cell <имя> <ожидание: accept|reject> [обязательная подстрока причины] —
# живой прогон ветви izolcfg барьера. Третий аргумент — различитель Б2 (вердикт
# 4305580) И усиление по адверсарию 067-v1 Д2: причина отказа обязана нести
# именованный маркер LEGACY_MODE/LEGACY_PATH/PINNED_BACKEND/HALF/«enabled: false»
# ДОСЛОВНО (grep -F); v1 отвергает к2/к3/к4/к5/к6/к7/к8 БЕЗ различения причины
# (мутант «awk мимо PATH» с общей причиной «причина не записана» проходит их
# зелёными) — пинуемый 3-й аргумент закрывает обход.
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
run_cell к2-stab-legasi-pin reject 'LEGACY_MODE'

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
run_cell к3-stab-pin-btrfs reject 'PINNED_BACKEND'

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
run_cell к4-stab-hardkod-rcopy reject 'PINNED_BACKEND'

# ── к5: изоляция выключена
mk_cell к5-vykljucheno
cat > "$WORK/к5-vykljucheno/.omp/config.yml" <<'EOF'
# Конфигурация (игрушечная — клетка к5 батареи 067: изоляции нет)
task:
  isolation:
    enabled: false
EOF
run_cell к5-vykljucheno reject 'enabled: false'

# ── к6: половина нормы — enabled без backend
mk_cell к6-bez-backend
cat > "$WORK/к6-bez-backend/.omp/config.yml" <<'EOF'
# Конфигурация (игрушечная — клетка к6 батареи 067: авто-детект не объявлен)
task:
  isolation:
    enabled: true
EOF
run_cell к6-bez-backend reject 'HALF'

# ── к7: backend не там — вложен в task.isolation (легаси-путь)
mk_cell к7-backend-ne-tam
cat > "$WORK/к7-backend-ne-tam/.omp/config.yml" <<'EOF'
# Конфигурация (игрушечная — клетка к7 батареи 067: путь ключа перепутан)
task:
  isolation:
    enabled: true
    backend: auto
EOF
run_cell к7-backend-ne-tam reject 'LEGACY_PATH'

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

# ── к9 (Р-1, находка ревьюера): «sibling-isolation» — task:/retry:/isolation:
# enabled:true (не в task.isolation, а в SIBLING-подсекции task.isolation-
# СОСЕДА retry.isolation). Верхнеуровневый backend:auto на месте. omp видит
# task.isolation.enabled = false. Структурная грамматика izolcfg v2 обязана
# отличить `  isolation:` под `task:` (фактический isolex) от `  isolation:`
# под `retry:` (sibling, omp игнорирует) — Р-1 fix: `in_task_isol` сбрасывается
# на любой верхнеуровневой строке + новая верxнеypовневая `isolation:` обнуляет
# предыдущий контекст. Ожидание: HALF (включена не та подсекция, omp видит
# выключенную изоляцию при заявленном backend:auto).
mk_cell к9-sibling-stab
cat > "$WORK/к9-sibling-stab/.omp/config.yml" <<'EOF'
# Конфигурация (игрушечная — клетка к9 батареи 067: sibling-isolation)
task:
  maxConcurrency: 4
retry:
  isolation:
    enabled: true

isolation:
  backend: auto
EOF
run_cell к9-sibling-stab reject 'HALF'

# ── к10 (Р-1): «deep-isolation» — task:/nested:/isolation:/</4 пробела/>enabled:
# true (на глубине 4, не на task.isolation=4). Верхнеуровневый backend:auto.
# omp видит task.isolation.enabled = false. Р-1 fix: вложенные ключи task.isolation
# привязаны к РОВНО четырём пробелам + (mode|backend|enabled):; ключ на 6
# пробелах не регистрируется. Ожидание: HALF.
mk_cell к10-deep-stab
cat > "$WORK/к10-deep-stab/.omp/config.yml" <<'EOF'
# Конфигурация (игрушечная — клетка к10 батареи 067: deep-isolation)
task:
  nested:
    isolation:
      enabled: true

isolation:
  backend: auto
EOF
run_cell к10-deep-stab reject 'HALF'

# ── к11 (Р-2): «trailing-backend» — backend: auto btrfs (хвост значения);
# awk v2 брал $2 (первое слово) → сравнение проходило как `auto`, отказ не
# срабатывал. Р-2 fix: сравнение значения ЦЕЛИКОМ (после среза # комментария
# и хвостовых пробелов) → значение != auto → PINNED_BACKEND. omp PAL
# откатывается в дефолт auto, но замороженный инв. 4 требует литерального
# сравнения. Ожидание: PINNED_BACKEND.
mk_cell к11-trailing-backend
cat > "$WORK/к11-trailing-backend/.omp/config.yml" <<'EOF'
# Конфигурация (игрушечная — клетка к11 батареи 067: trailing backend)
task:
  isolation:
    enabled: true

isolation:
  backend: auto btrfs
EOF
run_cell к11-trailing-backend reject 'PINNED_BACKEND'

# ── к12 (С-2): «extra-nested-backend» — backend:auto в `isolation:`/`  extra:`
# (вложен в дополнительную подсекцию), а честный task.isolation.enabled:true
# объявлен. Структурная грамматика должна различать верхнюю группу и
# вложение: верхний backend прикреплён к `^  backend:` (ровно 2 пробела);
# вложенный на 4 пробелах не считается верхним. Ожидание: HALF.
mk_cell к12-extra-nested-backend
cat > "$WORK/к12-extra-nested-backend/.omp/config.yml" <<'EOF'
# Конфигурация (игрушечная — клетка к12 батареи 067: extra-nested backend)
task:
  isolation:
    enabled: true

isolation:
  extra:
    backend: auto
EOF
run_cell к12-extra-nested-backend reject 'HALF'

# ── к13 (Р-1, чужой-enabled): task:/isolation:/enabled: false СОСЕДСТВУЕТ с
# task:/other:/enabled: true + верхний backend:auto. Барьер НЕ должен
# «проглотить» true из другой подсекции task (omp видит task.isolation.enabled=
# false); ветвь должна закрыть `in_task_isol` на любой `  <key>:` СОСЕДНЕЙ
# глубины 2, не только на новой верхнеуровневой. Р-1 fix: `in_task_isol &&
# /^  [^[:space:]#]/ { in_task_isol = 0; next }` — заглушка глубины 2
# закрывает task.isolation. Ожидание: «enabled: false».
mk_cell к13-chuzhoj-enabled
cat > "$WORK/к13-chuzhoj-enabled/.omp/config.yml" <<'EOF'
# Конфигурация (игрушечная — клетка к13 батареи 067: чужой-enabled)
task:
  isolation:
    enabled: false
  other:
    enabled: true

isolation:
  backend: auto
EOF
run_cell к13-chuzhoj-enabled reject 'enabled: false'

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