#!/usr/bin/env bash
# Контракт 112 — красная батарея структурной проверки подключения проекта
# (Complior-back / Complior-mob) к режиму проекта 996.
#
# Предмет клетки — НЕ собственная логика батареи, а исполнимая проверка:
# клетки подключения гоняют `scripts/check_project_connection.sh --repo <мир>`
# (модели: честные профили, ожидание rc 0; обманки: ожидание rc 1 +
# ИМЕНОВАННАЯ причина из алфавита причин проверки). Клетки канона
# (K1-kanon-polnyj / D15-kanon-nepolnyj / D18-kanon-lishnij /
# D19-kanon-prioritet / D20-standarty-kanon-nepolnyj) гоняют литеральный
# оракул kanon_back_2030.sh
# (перечень 2030 §3: полнота + лишние + приоритеты). Батарея строит
# одноразовые миры (git init + литеральные профили) в mktemp-каталоге
# $TMPDIR — никаких сетевых обменов и записей вне него; имя автора в путях
# scratch не участвует.
#
# Ожидаемые значения в клетках — ТОЛЬКО литералы (Н-351): коды возврата и
# имена причин записаны строками ниже и НЕ вычисляются кодом продукта.
# Соответствие входа и ветви отказа (Н-39) держится КОДОМ диспетчеризации
# клеток этого файла (мир + мутация + ожидание в одном case); контракт несёт
# инварианты и rc-команды, не привязки.
#
# Анти-плацебо полного прогона (правило 3 — клетка предъявлена красной против
# своего обмана):
#   (1) неизвестная клетка → rc 2 (диспетчеризация не заглушка `true`);
#   (2) state-слепая контрмодель — модель-эталон минус блок проверки state
#       (вырезается sed-ом по sentinels STATE-112-BEG/END) — ОБЯЗАНА дать
#       расхождение на D14-state-vne-repo и D16-state-symlink-zveno (внешние
#       цели обеих обманок СУЩЕСТВУЮТ — арбитраж 112 П-1/П-2), иначе плацебо;
#   (3) клетки канона двунаправлены: K1 ловит оракул-заглушку «всё красно»,
#       D15/D18/D19/D20 — «всё зелено».
#
# Диспетчеризация: --cell <имя> (одна клетка) | --model (против эталона) |
# без аргументов (полный прогон против продукта).
# Выход: 0 — все клетки совпали; 1 — расхождение (печатается по клетке:
# ожидание/факт/причина); 2 — неправильный вызов.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TOOLS="$(cd "$HERE/../../.." && pwd -P)"
CHECKER="$TOOLS/scripts/check_project_connection.sh"
ORACLE="$HERE/kanon_back_2030.sh"
SCRATCH="${TMPDIR:-/tmp}"

# ── литеральные ожидания (Н-351) ────────────────────────────────────────────
RC_MODEL=0      # честная модель → rc 0
RC_DECEPTIVE=1  # обманка → rc 1
REASON_PROFIL="ОТКАЗ: подключение: profil"
REASON_PATHS="ОТКАЗ: подключение: workflowPaths"
REASON_KOMANDY="ОТКАЗ: подключение: komandy"
REASON_REMOTE="ОТКАЗ: подключение: kanon-remote"
REASON_CANON="ОТКАЗ: подключение: source-canon"
REASON_KANON2030="ОТКАЗ: kanon-2030: kanon-nepolnyj"
REASON_KANON2030_LISHNIJ="ОТКАЗ: kanon-2030: kanon-lishnij"
REASON_KANON2030_PRIORITET="ОТКАЗ: kanon-2030: kanon-prioritet"

WORLD=""

make_world() {  # $1 = back|mob → путь мира
  local v="$1" d
  d="$(mktemp -d "$SCRATCH/podkljuchenie112-world-XXXXXX")" || return 9
  git -C "$d" init -q
  case "$v" in
    back)
      git -C "$d" remote add origin https://github.com/a3ka/Complior-back.git
      mkdir -p "$d/.harness/contracts" "$d/.harness/verdicts" "$d/.harness/registry" "$d/.harness/fixtures" \
               "$d/.github/workflows" "$d/backend/scripts" "$d/tools" "$d/contracts" "$d/db" "$d/docs/backend"
      touch "$d/.github/workflows/ci.yml" "$d/backend/scripts/gen-contracts.js" \
            "$d/Complior_Backend_Architecture_v3_14_RU.md" "$d/AGENTS.md" "$d/STRUCTURE.md" \
            "$d/contracts/BrokerOS_Unified_OpenAPI_v3.yaml" \
            "$d/db/001_core.sql" "$d/db/002_rls.sql" "$d/db/003_finance.sql" \
            "$d/db/004_runtime_role_fixes.sql" "$d/db/005_service_routing_and_effect_controls.sql" \
            "$d/db/006_deadline_basis_and_provenance.sql" "$d/db/007_standalone_profile_assets.sql" \
            "$d/db/008_service_authorization_lifecycle.sql" "$d/db/009_service_route_isolation.sql" \
            "$d/db/010_ux114_owners.sql" "$d/db/011_profile_contact_extensions.sql" \
            "$d/db/012_evb_issuance_owner.sql" "$d/db/013_profile_release_permissions.sql" \
            "$d/db/014_api_reads_migration_ledger.sql" \
            "$d/docs/ARCHITECTURE.md" "$d/docs/CODING-STANDARDS.md" "$d/docs/DATABASE.md" "$d/docs/RUNBOOK.md" \
            "$d/docs/backend/PORT-PLAN.md" "$d/docs/backend/DONOR-INVENTORY.md" \
            "$d/docs/backend/AUTH-AND-DB-DECISIONS.md" "$d/backend/structure-policy.json"
      printf '%s\n' '{"scripts":{"test":"node --test","lint":"eslint .","smoke:image":"node scripts/smoke-image.js"}}' > "$d/backend/package.json"
      printf '%s\n' '{ "schemaVersion": 1, "version": "1", "projectId": "Complior-back", "workspaceId": "Complior-back" }' > "$d/.harness/project-layer.json"
      # sourceCanon — ПОЛНЫЙ перечень 2030 §3 (26 источников = 18 priority 0 +
      # 8 priority 1, v2: оба стандарта подняты в priority 0 — слово владельца
      # 2026-10-20 ~13:45; Н-351: литералы, носитель перечня — kanon_back_2030.sh,
      # здесь — те же байты мира). contextPack — слово владельца 13:45 п.2:
      # оба стандарта обязательны (mandatory) ролям бэкенда; mob — БЕЗ них.
      cat > "$d/harness.project.json" <<'JSON'
{
  "schemaVersion": 1,
  "repoId": "Complior-back",
  "language": "javascript",
  "projectLayer": { "version": "1", "profilePath": ".harness/project-layer.json" },
  "workflowPaths": { "contracts": ".harness/contracts", "verdicts": ".harness/verdicts", "registry": ".harness/registry", "fixtures": ".harness/fixtures", "state": ".harness" },
  "commands": {
    "test": "npm --prefix backend test",
    "build": "npm --prefix backend run smoke:image",
    "typecheck": "node backend/scripts/gen-contracts.js --check",
    "lint": "npm --prefix backend run lint"
  },
  "git": { "canonicalRemote": "https://github.com/a3ka/Complior-back.git" },
  "ci": { "workflow": ".github/workflows/ci.yml" },
  "contextPack": {
    "rows": [
      { "kind": "map", "path": "docs/ARCHITECTURE.md", "roles": "architect,implementer,reviewer,adversary", "mandatory": true, "why": "карта архитектуры бэкенда — слово владельца 2026-10-20 ~13:45 UTC" },
      { "kind": "rules", "path": "docs/CODING-STANDARDS.md", "roles": "architect,implementer,reviewer,adversary", "mandatory": true, "why": "стандарт структуры и стиля бэкенда — слово владельца 2026-10-20 ~13:45 UTC" }
    ]
  },
  "sourceCanon": {
    "sources": [
      { "path": "Complior_Backend_Architecture_v3_14_RU.md", "priority": 0 },
      { "path": "contracts/BrokerOS_Unified_OpenAPI_v3.yaml", "priority": 0 },
      { "path": "db/001_core.sql", "priority": 0 },
      { "path": "db/002_rls.sql", "priority": 0 },
      { "path": "db/003_finance.sql", "priority": 0 },
      { "path": "db/004_runtime_role_fixes.sql", "priority": 0 },
      { "path": "db/005_service_routing_and_effect_controls.sql", "priority": 0 },
      { "path": "db/006_deadline_basis_and_provenance.sql", "priority": 0 },
      { "path": "db/007_standalone_profile_assets.sql", "priority": 0 },
      { "path": "db/008_service_authorization_lifecycle.sql", "priority": 0 },
      { "path": "db/009_service_route_isolation.sql", "priority": 0 },
      { "path": "db/010_ux114_owners.sql", "priority": 0 },
      { "path": "db/011_profile_contact_extensions.sql", "priority": 0 },
      { "path": "db/012_evb_issuance_owner.sql", "priority": 0 },
      { "path": "db/013_profile_release_permissions.sql", "priority": 0 },
      { "path": "db/014_api_reads_migration_ledger.sql", "priority": 0 },
      { "path": "docs/ARCHITECTURE.md", "priority": 0 },
      { "path": "docs/CODING-STANDARDS.md", "priority": 0 },
      { "path": "AGENTS.md", "priority": 1 },
      { "path": "STRUCTURE.md", "priority": 1 },
      { "path": "docs/DATABASE.md", "priority": 1 },
      { "path": "docs/RUNBOOK.md", "priority": 1 },
      { "path": "docs/backend/PORT-PLAN.md", "priority": 1 },
      { "path": "docs/backend/DONOR-INVENTORY.md", "priority": 1 },
      { "path": "docs/backend/AUTH-AND-DB-DECISIONS.md", "priority": 1 },
      { "path": "backend/structure-policy.json", "priority": 1 }
    ],
    "gate": ["python3", "tools/check_source_trace.py"]
  }
}
JSON
      ;;
    mob)
      git -C "$d" remote add origin https://github.com/a3ka/Complior-mob.git
      mkdir -p "$d/.harness/contracts" "$d/.harness/verdicts" "$d/.harness/registry" "$d/.harness/fixtures" \
               "$d/.github/workflows" "$d/mobile/scripts"
      touch "$d/.github/workflows/mobile.yml"
      printf '%s\n' '{"scripts":{"test":"jest --ci --runInBand","lint":"node scripts/check-structure.cjs","typecheck":"tsc --noEmit","doctor":"expo-doctor","build":"expo export --platform web"}}' > "$d/mobile/package.json"
      printf '%s\n' '{ "schemaVersion": 1, "version": "1", "projectId": "Complior-mob", "workspaceId": "Complior-mob" }' > "$d/.harness/project-layer.json"
      cat > "$d/harness.project.json" <<'JSON'
{
  "schemaVersion": 1,
  "repoId": "Complior-mob",
  "language": "typescript",
  "projectLayer": { "version": "1", "profilePath": ".harness/project-layer.json" },
  "workflowPaths": { "contracts": ".harness/contracts", "verdicts": ".harness/verdicts", "registry": ".harness/registry", "fixtures": ".harness/fixtures", "state": ".harness" },
  "commands": {
    "test": "npm --prefix mobile test",
    "build": "npm --prefix mobile run build",
    "typecheck": "npm --prefix mobile run typecheck",
    "lint": "npm --prefix mobile run lint"
  },
  "git": { "canonicalRemote": "https://github.com/a3ka/Complior-mob.git" },
  "ci": { "workflow": ".github/workflows/mobile.yml" }
}
JSON
      ;;
    *) printf 'bateria: неизвестный вариант мира: %s\n' "$v" >&2; return 2 ;;
  esac
  printf '%s' "$d"
}

jq_set() {  # $1 файл, $2 jq-фильтр входа (мутация ОБМАНКИ, не ожидания)
  local f="$1" filt="$2" t
  t="$(mktemp "$SCRATCH/podkljuchenie112-mut-XXXXXX")" || return 9
  jq "$filt" "$f" > "$t" && mv "$t" "$f"
}

run_cell() {  # $1 имя, $2 ожидаемый rc, $3 ожидаемая причина («-» = нет), $4 проверяющий (умолчание $CHECKER)
  local name="$1" want_rc="$2" want_reason="$3" chk="${4:-$CHECKER}" out rc=0 verdict=NEVER
  [ -x "$chk" ] || { printf 'КЛЕТКА %s: ОЖИДАНИЕ rc=%s причина=%s ФАКТ=НЕТ_ПРОВЕРКИ (%s отсутствует — предмет не реализован)\n' "$name" "$want_rc" "${want_reason#ОТКАЗ: }" "$chk" >&2; return 1; }
  out="$(bash "$chk" --repo "$WORLD" 2>&1)"; rc=$?
  if [ "$rc" -eq "$want_rc" ]; then
    verdict=OK
    if [ "$want_reason" != "-" ] && ! printf '%s' "$out" | grep -Fq "$want_reason"; then
      verdict=NET_PRICHINY; printf 'КЛЕТКА %s: rc=%s совпал, причины `%s` нет в выводе: %s\n' "$name" "$rc" "$want_reason" "$out" >&2
    fi
  else
    printf 'КЛЕТКА %s: ОЖИДАНИЕ rc=%s ФАКТ rc=%s вывод=%s\n' "$name" "$want_rc" "$rc" "$out" >&2
  fi
  [ "$verdict" = OK ]
}

cell() {  # $1 имя клетки → мир + мутация + ожидания (привязка входа к ветви — здесь, Н-39)
  local name="$1"
  WORLD="$(make_world back)" || return 9
  # Обманные миры подключения back несут language=typescript: алфавит
  # действующего резолвера сегодня не содержит javascript (живой разрыв P1
  # контракта 112, закрытие — implementer), и отказ обманки обязан
  # определяться её собственной мутацией, а не останавливаться на profil
  # алфавита. Модель M1 остаётся javascript — честный профиль продукта и
  # отдельная клетка разрыва.
  as_typescript() { jq_set "$WORLD/harness.project.json" '.language="typescript"'; }
  case "$name" in
    M1-back-model)            run_cell "$name" "$RC_MODEL" "-" ;;
    M2-mob-model)
      WORLD="$(make_world mob)" || return 9
      run_cell "$name" "$RC_MODEL" "-" ;;
    K1-kanon-polnyj)          run_cell "$name" "$RC_MODEL" "-" "$ORACLE" ;;
    D1-pustaja-komanda)       as_typescript; jq_set "$WORLD/harness.project.json" '.commands.test=""'
                              run_cell "$name" "$RC_DECEPTIVE" "$REASON_PROFIL" ;;
    D2-komanda-true)          as_typescript; jq_set "$WORLD/harness.project.json" '.commands.lint="true"'
                              run_cell "$name" "$RC_DECEPTIVE" "$REASON_KOMANDY" ;;
    D3-skripta-net)           as_typescript; jq_set "$WORLD/harness.project.json" '.commands.test="npm --prefix backend run net-takoj-skript"'
                              run_cell "$name" "$RC_DECEPTIVE" "$REASON_KOMANDY" ;;
    D4-chuzoj-remote)         as_typescript; jq_set "$WORLD/harness.project.json" '.git.canonicalRemote="https://github.com/a3ka/Complior-mob.git"'
                              run_cell "$name" "$RC_DECEPTIVE" "$REASON_REMOTE" ;;
    D5-put-vne-repo)          as_typescript
                              # внешняя цель СУЩЕСТВУЕТ (арбитраж 112 П-1): отказ — по
                              # каноническому положению, не по отсутствию цели
                              VNEE="$(mktemp -d "$SCRATCH/podkljuchenie112-vneshnie-verdikty-XXXXXX")"
                              VNESH_112="../$(basename "$VNEE")" jq_set "$WORLD/harness.project.json" '.workflowPaths.verdicts=$ENV.VNESH_112'
                              run_cell "$name" "$RC_DECEPTIVE" "$REASON_PATHS" ;;
    D6-symlink-pobeg)         as_typescript
                              rm -rf "$WORLD/.harness/contracts"
                              VNEE="$(mktemp -d "$SCRATCH/podkljuchenie112-vneshnee-XXXXXX")"
                              ln -s "$VNEE" "$WORLD/.harness/contracts"
                              run_cell "$name" "$RC_DECEPTIVE" "$REASON_PATHS" ;;
    D7-net-workflow)          as_typescript; jq_set "$WORLD/harness.project.json" '.ci.workflow=".github/workflows/net-takogo.yml"'
                              run_cell "$name" "$RC_DECEPTIVE" "$REASON_PROFIL" ;;
    D8-net-sostojanija)       as_typescript; rm -rf "$WORLD/.harness"
                              run_cell "$name" "$RC_DECEPTIVE" "$REASON_PROFIL" ;;
    D9-prioritet-bool)        as_typescript; jq_set "$WORLD/harness.project.json" '.sourceCanon.sources[0].priority=true'
                              run_cell "$name" "$RC_DECEPTIVE" "$REASON_PROFIL" ;;
    D10-istochnik-net)        as_typescript; jq_set "$WORLD/harness.project.json" '.sourceCanon.sources[1].path="docs/NET-TAKOGO.md"'
                              run_cell "$name" "$RC_DECEPTIVE" "$REASON_CANON" ;;
    D13-net-kataloga-kontr)   as_typescript; rm -rf "$WORLD/.harness/contracts"
                              run_cell "$name" "$RC_DECEPTIVE" "$REASON_PATHS" ;;
    D14-state-vne-repo)       as_typescript
                              # внешняя цель СУЩЕСТВУЕТ (арбитраж 112 П-1)
                              VNEE="$(mktemp -d "$SCRATCH/podkljuchenie112-vneshnee-state-XXXXXX")"
                              VNESH_112="../$(basename "$VNEE")" jq_set "$WORLD/harness.project.json" '.workflowPaths.state=$ENV.VNESH_112'
                              run_cell "$name" "$RC_DECEPTIVE" "$REASON_PATHS" ;;
    D16-state-symlink-zveno)  as_typescript
                              # симлинк-ЗВЕНО в середине пути (не лист), внешняя цель
                              # существует (арбитраж 112 П-2): красна и против
                              # existence-only, и против «лист не симлинк»
                              VNEE="$(mktemp -d "$SCRATCH/podkljuchenie112-vneshnee-link-XXXXXX")"
                              mkdir -p "$VNEE/state"
                              ln -s "$VNEE" "$WORLD/lnk"
                              jq_set "$WORLD/harness.project.json" '.workflowPaths.state="lnk/state"'
                              run_cell "$name" "$RC_DECEPTIVE" "$REASON_PATHS" ;;
    D17-state-absoljutnyj)    as_typescript
                              # абсолютный СУЩЕСТВУЮЩИЙ внешний каталог (арбитраж 112
                              # П-3): отказ по форме «не абсолютный», не по отсутствию
                              VNEE="$(mktemp -d "$SCRATCH/podkljuchenie112-vneshnee-absoljut-XXXXXX")"
                              VNESH_112="$VNEE" jq_set "$WORLD/harness.project.json" '.workflowPaths.state=$ENV.VNESH_112'
                              run_cell "$name" "$RC_DECEPTIVE" "$REASON_PATHS" ;;
    D11-mob-bez-typecheck)
      WORLD="$(make_world mob)" || return 9
      jq_set "$WORLD/harness.project.json" 'del(.commands.typecheck)'
      run_cell "$name" "$RC_DECEPTIVE" "$REASON_KOMANDY" ;;
    D12-mob-ssh-remote)
      WORLD="$(make_world mob)" || return 9
      jq_set "$WORLD/harness.project.json" '.git.canonicalRemote="ssh://git@github.com/a3ka/Complior-mob.git"'
      run_cell "$name" "$RC_DECEPTIVE" "$REASON_REMOTE" ;;
    D15-kanon-nepolnyj)       jq_set "$WORLD/harness.project.json" \
                                '.sourceCanon.sources=[.sourceCanon.sources[0], (.sourceCanon.sources[] | select(.path=="AGENTS.md"))]'
                              run_cell "$name" "$RC_DECEPTIVE" "$REASON_KANON2030" "$ORACLE" ;;
    D18-kanon-lishnij)        # полный перечень + источник вне перечня 2030 §3 (П-4)
                              touch "$WORLD/docs/UNAPPROVED.md"
                              jq_set "$WORLD/harness.project.json" '.sourceCanon.sources += [{path: "docs/UNAPPROVED.md", priority: 0}]'
                              run_cell "$name" "$RC_DECEPTIVE" "$REASON_KANON2030_LISHNIJ" "$ORACLE" ;;
    D19-kanon-prioritet)      # подмена приоритетов при полном множестве путей (П-5)
                              jq_set "$WORLD/harness.project.json" \
                                '(.sourceCanon.sources[] | select(.path=="Complior_Backend_Architecture_v3_14_RU.md") | .priority) = 1 | (.sourceCanon.sources[] | select(.path=="AGENTS.md") | .priority) = 0'
                              run_cell "$name" "$RC_DECEPTIVE" "$REASON_KANON2030_PRIORITET" "$ORACLE" ;;
    D20-standarty-kanon-nepolnyj)
                              # v2 (слово владельца 2026-10-20 ~13:45, форк n112):
                              # профиль back БЕЗ обоих стандартов — docs/ARCHITECTURE.md
                              # и docs/CODING-STANDARDS.md не объявлены (прочие 24
                              # источника доставлены) → kanon-nepolnyj
                              jq_set "$WORLD/harness.project.json" \
                                '.sourceCanon.sources |= map(select(.path != "docs/ARCHITECTURE.md" and .path != "docs/CODING-STANDARDS.md"))'
                              run_cell "$name" "$RC_DECEPTIVE" "$REASON_KANON2030" "$ORACLE" ;;
    *) return 2 ;;
  esac
}

usage() { printf 'использование: %s [--cell <имя>] [--model]\n' "$0" >&2; exit 2; }

if [ "${1:-}" = "--model" ]; then
  [ $# -eq 1 ] || usage
  PODKLJUCHENIE_112_CHECKER="$HERE/model_check_connection.sh" bash "$0"
  exit $?
fi


if [ -n "${PODKLJUCHENIE_112_CHECKER:-}" ]; then
  CHECKER="$PODKLJUCHENIE_112_CHECKER"
fi

if [ "${1:-}" = "--cell" ]; then
  [ -n "${2:-}" ] || usage
  cell "$2"; rc=$?
  [ -n "$WORLD" ] && rm -rf "$WORLD"
  [ "$rc" -eq 2 ] && usage
  exit "$rc"
fi
[ $# -eq 0 ] || usage
# полный прогон: 23 клетки (3 модели + 20 обманок) + анти-плацебо (1)–(3)
# Факты по клетке печатаются ТОЛЬКО при расхождении; итог — число клеток
# (зелёных/красных) и код возврата, не слово PASS.
itog=0; zelen=0; krasno=0
for c in M1-back-model M2-mob-model K1-kanon-polnyj D1-pustaja-komanda D2-komanda-true \
         D3-skripta-net D4-chuzoj-remote D5-put-vne-repo D6-symlink-pobeg D7-net-workflow \
         D8-net-sostojanija D9-prioritet-bool D10-istochnik-net D13-net-kataloga-kontr \
         D14-state-vne-repo D16-state-symlink-zveno D17-state-absoljutnyj \
         D11-mob-bez-typecheck D12-mob-ssh-remote D15-kanon-nepolnyj \
         D18-kanon-lishnij D19-kanon-prioritet D20-standarty-kanon-nepolnyj; do
  if cell "$c"; then zelen=$((zelen+1)); else krasno=$((krasno+1)); itog=1; fi
  [ -n "$WORLD" ] && rm -rf "$WORLD"; WORLD=""
done
if cell __net_takoj_kletki__ 2>/dev/null; then
  printf 'bateria: неизвестная клетка не дала rc 2 — диспетчеризация плацебо\n' >&2; itog=1
fi
[ -n "$WORLD" ] && rm -rf "$WORLD"; WORLD=""
# анти-плацебо (2): state-слепая контрмодель (эталон минус блок state) обязана
# дать расхождение на D14 и D16 (внешние цели существуют) — иначе проверка
# state не предъявлена красной.
STAB="$(mktemp "$SCRATCH/podkljuchenie112-stab-state-XXXXXX")" || exit 9
sed -e '/STATE-112-BEG/,/STATE-112-END/d' -e "s|^TOOLS=.*|TOOLS=\"$TOOLS\"|" "$HERE/model_check_connection.sh" > "$STAB"
chmod +x "$STAB"
for stab_cell in D14-state-vne-repo D16-state-symlink-zveno; do
  if PODKLJUCHENIE_112_CHECKER="$STAB" bash "$0" --cell "$stab_cell"; then
    printf 'bateria: state-слепая контрмодель прошла %s — клетка плацебо\n' "$stab_cell" >&2; itog=1
  fi
done
rm -f "$STAB"
printf 'ИТОГ 112: клеток 23, зелёных %s, красных %s, rc=%s\n' "$zelen" "$krasno" "$itog"
exit "$itog"
