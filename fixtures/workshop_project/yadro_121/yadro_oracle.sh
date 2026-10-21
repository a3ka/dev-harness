#!/usr/bin/env bash
# Контракт 121 (CMP-BCK-003) — ОРАКУЛ ядра БД 001–004: судит репозиторий
# Complior-back (или мини-мир toy_yadro121 той же раскладки) по инвариантам
# «применить ядро раннером 129 и доказать RLS, версии, финансовые инварианты,
# админ-аудит». Единый источник грамматики — пин pin_yadro121.json рядом с
# оракулом (зона architect, implementer изменить не может); маркеры свойств —
# литералы из текста миграций 001–004 и карточки CMP-BCK-003. Оракул ТОЛЬКО
# ЧИТАЕТ проверяемое дерево; поведенческие пробы идут в одноразовых копиях во
# временном каталоге SCRATCH.
#
#   Поведенческий ранг (уроки Б1/Б2 круга 1; арбитраж 121 — П1–П7): маркеры и
#   rc раннера НЕ доказывают SQL-проверок. Поэтому:
#   — тесты test:core суждаются МУТАЦИЯМИ СВОЙСТВ (Б1): на одноразовой копии
#     свойство повреждается (toy: флаги движка toy_pg.js; продукт: живой SQL
#     DAMAGE против PG18 в одноразовом docker-контейнере) — набор ОБЯЗАН
#     краснеть; безусловно зелёный/комментарийный набор остаётся зелёным на
#     повреждённом мире и отвергается причиной testy-pustye. ПЕРЕД каждой
#     мутацией — контрольный повтор на ЦЕЛОМ мире в тех же условиях (П1):
#     побочная краснота одноразового состояния дерева/кластера (mkdir/EEXIST,
#     CREATE ROLE) становится краснотой на честном мире — правдивый диагноз
#     testy-ne-zelenye с именем пробы; кластерное состояние после DAMAGE
#     восстанавливает САМ оракул (П2: поле revert пина, обязательно).
#   — evidence НЕ свидетельство само по себе (Б2): ОДНА функция грамматики
#     записи (П3) применяется и к записям дерева, и к КАЖДОЙ свежей записи
#     прогона (engine/db/роль ТОЧНЫМ равенством/непустые sql/errors +
#     SQLSTATE-алфавит/errors_min); run_key свежей записи продукта — живой
#     расчёт, записей дерева — константа пина run_key_expected (П5); PGlite
#     под меткой RUNTIME красен (evidence-ne-native) — признак движка
#     читается из записи прогона, а не из правимого руками поля mode.
#
# Вызов:
#   yadro_oracle.sh --model          самопроверка: честный мини-мир зелёный,
#                                    каждый декой отвергнут ровно своей причиной
#   yadro_oracle.sh --repo <корень>  судить продуктовое дерево Complior-back
#
# Выход: 0 — все клетки зелёные; 1 — ОТКАЗ: yadro121: <причина> (алфавит
# замкнут, имена и расшифровки — pin_yadro121.json .prichiny); 2 —
# неправильный вызов либо NEEDS_ENV (поведенческая проба неизмерима в этом
# окружении: нет node/npm/node_modules/pg/docker — названная граница, не успех).
#
pin2() { jq -r --arg sec "$2" "$1" "$PIN"; }
# NEEDS_ENV-честность (образец 109, К5): неизмеримая клетка — rc 2 с границей,
# никогда успех. Живые мутационные пробы продукта (PG18 в docker) оракул
# исполняет только при наличии docker; без него — rc 2 (не зелень): полный
# объём несут lane CI продукта на стенде и судьи (контракт 121, приёмка 4–5).
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PIN="$HERE/pin_yadro121.json"
TOY_SRC="$HERE/toy_yadro121"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/yadro121-XXXXXX")"
PG_CID=""

cleanup() { [ -n "$PG_CID" ] && docker rm -f "$PG_CID" >/dev/null 2>&1; rm -rf "$SCRATCH"; }
trap cleanup EXIT

[ -f "$PIN" ] || { echo "ОТКАЗ: yadro121: pin-otsutstvuet (батарея повреждена)" >&2; exit 2; }
pin() { jq -r "$1" "$PIN"; }
fail() { echo "ОТКАЗ: yadro121: $1" >&2; exit 1; }
needs_env() { echo "NEEDS_ENV: yadro121: $1" >&2; exit 2; }
NAT="$(pin .product.evidence.native_mode)"
PGL="$(pin .product.evidence.pglite_mode)"
LIVE_V=""; LIVE_K=""

# ── структурные клетки (один код для продукта и мини-мира) ──────────────────
# Сравнения литеральные (grep -Fq / sha256sum / jq); маркеры читаются по
#строчно (содержат пробелы); причины — замкнутый алфавит пина.
struktura() { # $1 корень, $2 секция пина (product|toy)
  local ROOT="$1" SEC="$2"
  local i sha entry f marker ev
  local MANI="$ROOT/server/infrastructure/migrations/manifest.json"
  for i in 001_core.sql 002_rls.sql 003_finance.sql 004_runtime_role_fixes.sql; do
    [ -f "$ROOT/migrations/$i" ] || fail migracii-izmeneny
    sha="$(sha256sum "$ROOT/migrations/$i" | cut -d' ' -f1)"
    [ "$sha" = "$(pin ".$SEC.migrations_sha256[\"$i\"]")" ] || fail migracii-izmeneny
    # манифест обязан нести sha256 каждого из 001–004 (формат продукта и
    # мини-мира различается полями — общая грамматика: литерал хэша)
    grep -Fq "$sha" "$MANI" || fail ranner-otsutstvuet
  done
  if [ "$SEC" = toy ]; then entry="$(pin .toy.runner_entry)"; else entry="$(pin .product.runner.entry)"; fi
  [ -f "$ROOT/$entry" ] || fail ranner-otsutstvuet
  [ -f "$MANI" ] || fail ranner-otsutstvuet
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    [ -f "$ROOT/$f" ] || fail testy-otsutstvuyut
  done < <(pin '.core_tests | keys[]')
  while IFS= read -r marker; do
    grep -Fq -- "$marker" "$ROOT/tests/integration/core/rls.test.js" || fail rls-bez-force
  done < <(pin '.core_tests["tests/integration/core/rls.test.js"][]')
  while IFS= read -r marker; do
    grep -Fq -- "$marker" "$ROOT/tests/integration/core/immutable.test.js" || fail versii-ne-immutable
  done < <(pin '.core_tests["tests/integration/core/immutable.test.js"][]')
  while IFS= read -r marker; do
    grep -Fq -- "$marker" "$ROOT/tests/integration/core/finance_journal.test.js" || fail zhurnal-bez-balansa
  done < <(pin '.core_tests["tests/integration/core/finance_journal.test.js"][]')
  while IFS= read -r marker; do
    grep -Fq -- "$marker" "$ROOT/tests/integration/core/admin_audit.test.js" || fail audit-bez-konteksta
  done < <(pin '.core_tests["tests/integration/core/admin_audit.test.js"][]')
  jq -e --arg s "$(pin .product.wiring.package_script)" '.scripts[$s] != null' \
    "$ROOT/package.json" >/dev/null 2>&1 || fail provodka-otsutstvuet
  grep -Fq "$(pin .product.wiring.lane_literal)" "$ROOT/tests/tools/run_backend_ci.py" 2>/dev/null \
    || fail provodka-otsutstvuet
  evidence_grammatika "$ROOT" "$SEC"
}

# ── evidence-грамматика (Б2): запись прогона, а не декларация ────────────────
# П3 (арбитраж 121): ОДНА функция грамматики ОДНОЙ записи — для дерева и для
# свежих записей прогона; дублирование двух грамматик было дефектом круга 2
# (свежая запись не судилась вовсе — B2a–B2g зелёные).
zapis_grammatika() { # $1 run.json; $2 секция пина (product|toy); $3 происхождение (derevo|fresh)
  local F="$1" SEC="$2" ORIG="$3"
  local dir SSRE EMIN fld NE RE ROLES PAT is_nat is_pgl
  NE="$(pin2 '.[$sec].evidence.native_engine' "$SEC")"
  # Круг 3→4 (П4/П5): значения evidence сравниваются ТОЧНО над ИСХОДНЫМ
  # JSON-значением ВНУТРИ jq — shell $( ) срезает завершающие LF и принимал
  # role/run_key с хвостовым "\n" (вердикт krug3-fail); $( ) остаётся только
  # на JSON-коде (@json / массив пина), где LF заэкранирован и потерь нет.
  is_nat="$(jq -r --arg n "$NAT" '(.mode // "") == $n' "$F" 2>/dev/null)"
  is_pgl="$(jq -r --arg p "$PGL" '(.mode // "") == $p' "$F" 2>/dev/null)"
  if [ "$ORIG" = fresh ]; then
    # свежая запись оракульного прогона — только native RUNTIME (B2e)
    [ "$is_nat" = true ] || fail evidence-ne-native
  fi
  if [ "$is_pgl" = true ]; then
    # историческая PGlite-запись дерева: признак движка из записи, не поля mode
    jq -e --arg e "$NE" '(.engine // "") != $e' "$F" >/dev/null 2>&1 || fail evidence-ne-native
  elif [ "$is_nat" = true ]; then
    jq -e --arg e "$NE" '(.engine // "") == $e' "$F" >/dev/null 2>&1 || fail evidence-ne-native
    RE="$(pin2 '.[$sec].evidence.native_db_regex' "$SEC")"
    if [ "$SEC" = product ] && [ "$ORIG" = fresh ]; then
      # свежая продуктовая запись: db — ТОЧНО version() живого контейнера
      jq -e --arg v "$LIVE_V" '(.db // "") == $v' "$F" >/dev/null 2>&1 || fail evidence-ne-native
    else
      jq -e --arg re "$RE" '(.db // "") | test($re)' "$F" >/dev/null 2>&1 || fail evidence-ne-native
    fi
    jq -e '(.sql|type)=="array" and (.sql|length)>0 and all(.sql[]; (type=="string" and length>0))' \
      "$F" >/dev/null 2>&1 || fail evidence-otsutstvuet
    # native_fields присутствуют (B2g: «запись без поля роли» — не native-запись)
    while IFS= read -r fld; do
      jq -e --arg f "$fld" 'getpath([$f]) != null' "$F" >/dev/null 2>&1 || fail evidence-otsutstvuet
    done < <(pin '.product.evidence.native_fields[]')
    # роль — ТОЧНОЕ равенство множеству runtime_roles ВНУТРИ jq, не подстрока
    # (П4, B2h; круг 3: «brokeros_api\n» проходил shell-сравнением со срезанным LF)
    ROLES="$(pin2 '.[$sec].evidence.runtime_roles' "$SEC")"
    jq -e --argjson roles "$ROLES" \
      '(.role|type)=="string" and ((.role as $r | ($roles | index($r))) != null)' \
      "$F" >/dev/null 2>&1 || fail evidence-ne-native
    # ошибки: SQLSTATE-алфавит пина и непустой message; минимум по секции (П4)
    SSRE="$(pin2 '.[$sec].evidence.sqlstate_regex // .product.evidence.sqlstate_regex' "$SEC")"
    jq -e --arg re "$SSRE" '(.errors|type)=="array" and all(.errors[]?; ((.sqlstate|type)=="string") and (.sqlstate|test($re)) and (((.message // "")|length)>0))' \
      "$F" >/dev/null 2>&1 || fail evidence-ne-native
    EMIN="$(pin2 '.[$sec].evidence.errors_min' "$SEC")"
    jq -e --argjson m "${EMIN:-0}" '(.errors|length) >= $m' "$F" >/dev/null 2>&1 || fail evidence-otsutstvuet
    # run_key: непустота и ВСЕ равенства — ТОЧНО внутри jq над ИСХОДНЫМ
    # JSON-значением (П5, круг 3: «<константа>\n» проходил срезанным сравнением)
    jq -e '(.run_key|type)=="string" and (.run_key|length)>0' "$F" >/dev/null 2>&1 \
      || fail evidence-chuzhoj-klyuch
    if [ "$SEC" = toy ]; then
      # мини-мир: ключ сверяется с файлом и ledger ТОЙ ЖЕ записи; файл run_key —
      # текстовый: его единственный завершающий \n — формат файла, не значения
      dir="$(dirname "$F")"
      [ -f "$dir/run_key" ] || fail evidence-chuzhoj-klyuch
      jq -e --rawfile kf "$dir/run_key" '.run_key == ($kf | rtrimstr("\n"))' "$F" >/dev/null 2>&1 \
        || fail evidence-chuzhoj-klyuch
      # ledger: паттерн — JSON-код значения (@json экранирует LF — без потерь)
      PAT="$(jq -j '.run_key | @json' "$F" 2>/dev/null)"
      [ -n "$PAT" ] || fail evidence-chuzhoj-klyuch
      grep -Fq "\"run_key\":$PAT" "$dir/schema_migration.jsonl" 2>/dev/null || fail evidence-chuzhoj-klyuch
    elif [ "$ORIG" = fresh ]; then
      # свежая продуктовая запись: ключ — ЖИВОЙ прогон этого контейнера (б)
      jq -e --arg k "$LIVE_K" '.run_key == $k' "$F" >/dev/null 2>&1 || fail evidence-chuzhoj-klyuch
    else
      # П5: записи дерева — константа пина (ledger 001–004 детерминирован)
      jq -e --arg k "$(pin .product.evidence.run_key_expected)" '.run_key == $k' "$F" >/dev/null 2>&1 \
        || fail evidence-chuzhoj-klyuch
    fi
  else
    # алфавит меток закрыт пином: ни RUNTIME, ни PGLITE (в т.ч. с хвостовым LF)
    # — не запись грамматики; иначе она молча выпадала из всех ветвей проверки
    fail evidence-ne-native
  fi
  # запрещённые ключи аудита — в любой записи обеих меток (как в круге 2)
  jq -e '([paths(scalars) as $p | ($p | map(tostring) | join("."))
          | select(. == "secret_locator" or . == "account_reference"
                   or endswith(".secret_locator") or endswith(".account_reference"))] | length) == 0' \
    "$F" >/dev/null 2>&1 || fail evidence-sekrety
}

evidence_grammatika() { # $1 корень, $2 секция пина (product|toy) — записи дерева
  local ROOT="$1" SEC="$2"
  local EVD ev found_run="нет" found_pgl="нет"
  EVD="$(pin .product.evidence.dir)"
  while IFS= read -r ev; do
    [ -f "$ev" ] || continue
    jq -e --arg n "$NAT" '(.mode // "") == $n' "$ev" >/dev/null 2>&1 && found_run="да"
    jq -e --arg p "$PGL" '(.mode // "") == $p' "$ev" >/dev/null 2>&1 && found_pgl="да"
    zapis_grammatika "$ev" "$SEC" derevo
  done < <(find "$ROOT/$EVD" -name run.json 2>/dev/null | LC_ALL=C sort)
  [ "$found_run" = "да" ] || fail evidence-otsutstvuet
  [ "$found_pgl" = "да" ] || fail evidence-razdelenie
}

# ── поведенческая проба повреждённой копии (продукт и мини-мир) ─────────────
damage_probe() { # $1 корень, $2 тип (product|toy)
  local ROOT="$1" TIP="$2" cpdir="$SCRATCH/dmg-$2" rc out dmgfile
  command -v node >/dev/null 2>&1 || { echo "NEEDS_ENV: yadro121: node отсутствует" >&2; exit 2; }
  mkdir -p "$cpdir/server/infrastructure/migrations" "$cpdir/migrations"
  cp "$ROOT"/migrations/0*.sql "$cpdir/migrations/" 2>/dev/null
  cp "$ROOT/server/infrastructure/migrations/run.js" "$cpdir/server/infrastructure/migrations/"
  cp "$ROOT/server/infrastructure/migrations/manifest.json" "$cpdir/server/infrastructure/migrations/"
  if [ "$TIP" = product ]; then
    [ -d "$ROOT/node_modules/pg" ] || { echo "NEEDS_ENV: yadro121: нет $ROOT/node_modules/pg (npm ci)" >&2; exit 2; }
    ln -s "$ROOT/node_modules" "$cpdir/node_modules"
  fi
  dmgfile="$(pin .product.runner.damage_file)"
  pin '.toy.damage_append' | tee -a "$cpdir/migrations/$dmgfile" | wc -c >/dev/null
  rm -rf "$SCRATCH/dmg-state"
  if [ "$TIP" = product ]; then
    out="$(cd "$cpdir" && MIGRATION_DATABASE_URL="$(pin .product.runner.env_stub)" \
      node server/infrastructure/migrations/run.js --through 004 2>&1)"; rc=$?
  else
    out="$(cd "$cpdir" && TOY_LEDGER_DIR="$SCRATCH/dmg-state" node server/infrastructure/migrations/run.js --through 004 2>&1)"; rc=$?
  fi
  [ "$rc" -eq 1 ] || fail ranner-ne-otkazyvaet
  printf '%s' "$out" | grep -Fq "$(pin .product.runner.damage_refusal)" || fail ranner-ne-otkazyvaet
}

# ── поведенческое трио мини-мира: пустая база / повтор / повреждение ────────
toy_trio() { # $1 корень мини-мира
  local ROOT="$1" ST="$SCRATCH/trio" L
  rm -rf "$ST"; mkdir -p "$ST"
  (cd "$ROOT" && TOY_LEDGER_DIR="$ST" node server/infrastructure/migrations/run.js --through 004) >/dev/null 2>&1
  L="$( [ -f "$ST/schema_migration.jsonl" ] && wc -l < "$ST/schema_migration.jsonl" || echo 0 )"
  [ "$L" -eq 4 ] || fail ledger-pustoj
  L="$( [ -f "$ST/applied.log" ] && wc -l < "$ST/applied.log" || echo 0 )"
  [ "$L" -eq 4 ] || fail ledger-pustoj
  grep -Fq '"num":"001"' "$ST/schema_migration.jsonl" || fail ledger-pustoj
  grep -Fq '"num":"004"' "$ST/schema_migration.jsonl" || fail ledger-pustoj
  (cd "$ROOT" && TOY_LEDGER_DIR="$ST" node server/infrastructure/migrations/run.js --through 004) >/dev/null 2>&1
  [ "$(wc -l < "$ST/applied.log")" -eq 4 ] || fail povtor-ddl
  [ "$(wc -l < "$ST/schema_migration.jsonl")" -eq 4 ] || fail povtor-ddl
}

# ── Б1, мини-мир: test:core ИСПОЛНЯЕТ проверки и краснеет на поломке ─────────
povedencheskie_proby_toy() { # $1 корень мини-мира (одноразовая копия)
  local ROOT="$1" fresh from to MUT
  command -v npm >/dev/null 2>&1 || needs_env "npm отсутствует — toy test:core не исполняется"
  command -v node >/dev/null 2>&1 || needs_env "node отсутствует"
  # честный мир: набор зелёный, evidence пишется самим тестом
  (cd "$ROOT" && npm run -s test:core) >/dev/null 2>&1 || fail model-razbita
  fresh="$(find "$ROOT/docs/evidence/core" -mindepth 1 -maxdepth 1 -type d -name '*.native' -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)"
  [ -n "$fresh" ] && [ -f "$fresh/run.json" ] || fail model-razbita
  # П3: грамматика свежей записи — ТА ЖЕ функция, что и для дерева (П6-б/в)
  zapis_grammatika "$fresh/run.json" toy fresh
  # мутационные пробы (Б1) с контрольным повтором П1: в копии $SCRATCH/mut
  # прогон БЕЗ sed обязан быть зелёным (иначе — одноразовая побочка,
  # testy-ne-zelenye с именем пробы), с sed — красным (testy-pustye иначе)
  while IFS=$'\t' read -r from to; do
    [ -n "$from" ] || continue
    rm -rf "$SCRATCH/mut"; cp -r "$ROOT" "$SCRATCH/mut"; rm -rf "$SCRATCH/mut/.toy-state"
    MUT="$SCRATCH/mut/tests/helpers/toy_pg.js"
    if ! (cd "$SCRATCH/mut" && npm run -s test:core) >/dev/null 2>&1; then
      fail "testy-ne-zelenye: набор красен на честном мире при повторе (контроль перед мутацией $from)"
    fi
    sed -i "s|$from|$to|" "$MUT"
    grep -Fq "$to" "$MUT" || fail model-razbita
    if (cd "$SCRATCH/mut" && npm run -s test:core) >/dev/null 2>&1; then fail testy-pustye; fi
  done < <(pin '.toy.engine_mutations[] | [.from,.to] | @tsv')
}

# ── Б1/Б2, продукт: живые мутационные пробы на одноразовой PG18 (docker) ────
mutacionnye_proby_produkta() { # $1 корень продукта
  local ROOT="$1" IMG DB PW CID PORT URL CP i fresh V K name dsql rvt nfresh rc
  command -v node >/dev/null 2>&1 || needs_env "node отсутствует"
  command -v npm  >/dev/null 2>&1 || needs_env "npm отсутствует"
  [ -d "$ROOT/node_modules/pg" ] || needs_env "нет $ROOT/node_modules/pg (npm ci)"
  command -v docker >/dev/null 2>&1 || needs_env "docker отсутствует — мутационные пробы ядра требуют одноразовой PG18 (стенд 109 / судьи)"
  docker info >/dev/null 2>&1 || needs_env "docker-демон не отвечает — PG18 не поднимается (стенд 109 / судьи)"
  IMG="$(pin .product.mutations.docker_image)"
  DB="$(pin .product.mutations.db)"
  PW="$(pin .product.mutations.admin_password)"
  CID="yadro121-pg-$$"
  docker run --rm -d --name "$CID" -e POSTGRES_PASSWORD="$PW" -e POSTGRES_DB="$DB" \
    -p 127.0.0.1::5432 "$IMG" >/dev/null 2>&1 || needs_env "не удалось поднять $IMG (pull/демон)"
  PG_CID="$CID"
  for i in $(seq 1 60); do
    docker exec "$CID" pg_isready -U postgres -h 127.0.0.1 >/dev/null 2>&1 && break
    sleep 0.5
  done
  PORT="$(docker port "$CID" 5432/tcp | head -1 | awk -F: '{print $NF}')"
  [ -n "$PORT" ] || fail model-razbita
  URL="postgres://postgres:$PW@127.0.0.1:$PORT/$DB"
  CP="$SCRATCH/prod"
  mkdir -p "$CP"
  cp -r "$ROOT/migrations" "$ROOT/server" "$ROOT/tests" "$ROOT/package.json" "$CP/" 2>/dev/null || fail model-razbita
  mkdir -p "$CP/docs"
  cp -r "$ROOT/docs/evidence" "$CP/docs/" 2>/dev/null || true
  ln -s "$ROOT/node_modules" "$CP/node_modules"
  # (а) честный мир: применить ядро раннером, ledger 4, test:core зелёный
  (cd "$CP" && MIGRATION_DATABASE_URL="$URL" node server/infrastructure/migrations/run.js --through 004) \
    >/dev/null 2>&1 || fail testy-ne-zelenye
  [ "$(docker exec "$CID" psql -At -U postgres -d "$DB" -c 'select count(*) from control.schema_migration' 2>/dev/null)" = "4" ] \
    || fail ledger-pustoj
  V="$(docker exec "$CID" psql -At -U postgres -d "$DB" -c 'select version()' 2>/dev/null)"
  K="$(docker exec "$CID" psql -At -U postgres -d "$DB" -c "$(pin .product.evidence.run_key_sql)" 2>/dev/null | sha256sum | cut -d' ' -f1)"
  # П5: живой ключ обязан равняться константе пина — ledger 001–004
  # детерминирован (version|name|file_sha256); расхождение = пин и мир разошлись
  [ "$K" = "$(pin .product.evidence.run_key_expected)" ] || fail model-razbita
  LIVE_V="$V"; LIVE_K="$K"
  touch "$SCRATCH/marker"
  (cd "$CP" && COMPLIOR_TEST_PG_ADMIN_URL="$URL" npm run -s test:core) >/dev/null 2>&1 || fail testy-ne-zelenye
  # (б) evidence пишется самим тестом: грамматика П3 к КАЖДОЙ свежей записи
  # (не только первой по сортировке — дефект B2f круга 2)
  nfresh=0
  while IFS= read -r fresh; do
    [ -n "$fresh" ] || continue
    zapis_grammatika "$fresh" product fresh
    nfresh=$((nfresh + 1))
  done < <(find "$CP/docs/evidence/core" -name run.json -newer "$SCRATCH/marker" 2>/dev/null | LC_ALL=C sort)
  [ "$nfresh" -ge 1 ] || fail evidence-otsutstvuet
  # (в) DAMAGE-пробы (П1/П2): контроль на ЦЕЛОМ мире в тех же условиях → rc 0
  # обязан (одноразовая побочка = testy-ne-zelenye с именем пробы) → DAMAGE →
  # краснота обязана (testy-pustye иначе) → кластерное состояние восстанавливает
  # САМ оракул (revert пина; поле обязательно — model-razbita при отсутствии)
  while IFS=$'\t' read -r name dsql rvt; do
    [ -n "$name" ] || continue
    [ -n "$rvt" ] || fail model-razbita
    docker exec "$CID" psql -q -U postgres -d postgres \
      -c "DROP DATABASE $DB WITH (FORCE)" -c "CREATE DATABASE $DB" >/dev/null 2>&1 || fail model-razbita
    (cd "$CP" && MIGRATION_DATABASE_URL="$URL" node server/infrastructure/migrations/run.js --through 004) \
      >/dev/null 2>&1 || fail testy-ne-zelenye
    if ! (cd "$CP" && COMPLIOR_TEST_PG_ADMIN_URL="$URL" npm run -s test:core) >/dev/null 2>&1; then
      fail "testy-ne-zelenye: набор красен на честном мире при повторе (контроль перед мутацией $name)"
    fi
    docker exec "$CID" psql -q -U postgres -d "$DB" -c "$dsql" >/dev/null 2>&1 || fail model-razbita
    if (cd "$CP" && COMPLIOR_TEST_PG_ADMIN_URL="$URL" npm run -s test:core) >/dev/null 2>&1; then
      fail testy-pustye
    fi
    docker exec "$CID" psql -q -U postgres -d "$DB" -c "$rvt" >/dev/null 2>&1 || fail model-razbita
  done < <(pin '.product.mutations.damage[] | [.name,.sql,.revert] | @tsv')
  docker rm -f "$CID" >/dev/null 2>&1; PG_CID=""
}

# ── суд продуктового дерева ─────────────────────────────────────────────────
sudit_produkt() {
  local ROOT="$1"
  [ -n "$ROOT" ] && [ -d "$ROOT" ] || { echo "использование: yadro_oracle.sh --repo <корень>" >&2; exit 2; }
  [ -d "$ROOT/migrations" ] || fail migracii-izmeneny
  struktura "$ROOT" product
  damage_probe "$ROOT" product
  mutacionnye_proby_produkta "$ROOT"
  exit 0
}

# ── самопроверка модели: честный мини-мир + декои ───────────────────────────
# Каждый декой — копия мини-мира с ОДНОЙ мутацией; мутации привязаны к анкерам
# КОДА мини-мира (Н-39: привязка по коду батареи, не по прозе контракта):
# run.js («shaNow !== e.sha256», «if (seen.has(e.num)) continue;»,
# «appendLedger(e);»), тесты-маркеры, jq-мутации evidence, run_core.js
# («run_key: runKey», «sql: db.executed», «role: 'brokeros_api'»,
# «errors: db.errors», «const state = fs.mkdtempSync» — П6 арбитража 121),
# toy_pg.js (флаги свойств), и Б1-декой «безусловно зелёные тесты с маркерами»
# (обход круга 1). Декой обязан уйти rc 1 РОВНО своей причиной; rc 0/2 или
# чужая причина = orakul-slep. Всего декоев: 16 (11 круга 2 + 3 П6 + 2 круга 3:
# LF-обход точного равенства П4/П5 — роль/ключ записи дерева с хвостовым «\n»).
sudit_model() {
  local d n want M rc got
  local SERVER RLS FIN EVN EVP TMP CORE
  # ── мутации-декои: каждая — функция с ОДНОЙ правкой по анкеру кода ────────
  mut_pustaya_baza()     { sed -i 's/appendLedger(e);/;/' "$SERVER"; }
  mut_povtornyj_ddl()    { sed -i 's/if (seen.has(e.num)) continue;/if (false) continue;/' "$SERVER"; }
  mut_checksum_slep()    { sed -i 's/shaNow !== e.sha256/false/' "$SERVER"; }
  mut_rls()              { sed -i 's/FORCE ROW LEVEL SECURITY/FORCE ROW LEVEL (no force)/' "$RLS"; }
  mut_zhurnal()          { sed -i 's/finance_journal/jurnal_bez_imeni/' "$FIN"; }
  mut_audit()            { jq '.audit.after.secret_locator = "s3://x"' "$EVN" > "$TMP" && mv "$TMP" "$EVN"; }
  # Б2-обход круга 1: PGlite переименован в RUNTIME. Полная переклейка
  # (mode+engine+db) уходит evidence-razdelenie; переклейка одного поля mode
  # ловится признаком движка из записи — evidence-ne-native.
  mut_bez_razdeleniya()  { jq '.mode = "RUNTIME" | .engine = "toy-native" | .db = "ToyPostgreSQL 18.6 toy, toy-native"' "$EVP" > "$TMP" && mv "$TMP" "$EVP"; }
  mut_dvizhok_podmena()  { jq '.mode = "RUNTIME"' "$EVP" > "$TMP" && mv "$TMP" "$EVP"; }
  # Б1-обход круга 1: тесты без проверок — только маркеры и безусловная зелень;
  # оракул ловит их МУТАЦИОННОЙ пробой (движок сломан — набор всё ещё зелёный).
  mut_testy_pustye() {
    local f markers m
    while IFS=$'\t' read -r f markers; do
      [ -n "$f" ] || continue
      {
        echo "'use strict';"
        echo "const { test } = require('node:test');"
        echo "test('unconditional green', () => {});"
        tr ',' '\n' <<<"$markers" | while IFS= read -r m; do echo "// $m"; done
      } > "$SCRATCH/dek/$f"
    done < <(pin '.core_tests | to_entries[] | [.key, (.value|join(","))] | @tsv')
  }
  # evidence пишется тестом, но с подменённым/пустым содержимым (Б2)
  mut_klyuch_chuzhoj()   { sed -i 's/run_key: runKey/run_key: "deadbeef"/' "$CORE"; }
  mut_sql_pustoj()       { sed -i 's/sql: db.executed/sql: []/' "$CORE"; }
  # П6 (арбитраж 121): декои под новые клетки — «одноразовая побочка»
  # (mkdir без recursive первым оператором run_core.js: первый прогон зелёный,
  # контрольный повтор П1 перед мутацией красен EEXIST → testy-ne-zelenye),
  # «свежая роль вне множества» и «свежий SQLSTATE вне алфавита» (грамматика
  # свежей записи П3/П4 → evidence-ne-native)
  mut_odnorazovaya()     { sed -i "s|const state = fs.mkdtempSync|fs.mkdirSync('docs/evidence/core/odnorazovyj'); const state = fs.mkdtempSync|" "$CORE"; }
  mut_rol_postgres()     { sed -i "s|role: 'brokeros_api'|role: 'postgres'|" "$CORE"; }
  mut_sqlstate_vne()     { sed -i "s|errors: db.errors|errors: [{ sqlstate: 'wrong', message: 'x' }]|" "$CORE"; }
  # Круг 3 (П4/П5, вердикт krug3-fail): LF-обход точного равенства — запись
  # дерева с ролью/ключом с завершающим «\n»; сравнение ИСХОДНОГО JSON-значения
  # внутри jq обязано отвергнуть (shell-срезка LF принимала оба)
  mut_rol_lf()            { jq '.role = "brokeros_api\n"' "$EVN" > "$TMP" && mv "$TMP" "$EVN"; }
  mut_klyuch_lf()         { jq '.run_key = (.run_key + "\n")' "$EVN" > "$TMP" && mv "$TMP" "$EVN"; }
  rm -rf "$SCRATCH/honest"
  cp -r "$TOY_SRC" "$SCRATCH/honest"
  rm -rf "$SCRATCH/honest/.toy-state"
  struktura "$SCRATCH/honest" toy
  toy_trio "$SCRATCH/honest"
  damage_probe "$SCRATCH/honest" toy
  povedencheskie_proby_toy "$SCRATCH/honest"
  local dekos=(
    'pustaya-baza|ledger-pustoj|mut_pustaya_baza'
    'povtornyj-ddl|povtor-ddl|mut_povtornyj_ddl'
    'checksum-slep|ranner-ne-otkazyvaet|mut_checksum_slep'
    'rls-bez-force|rls-bez-force|mut_rls'
    'zhurnal-bez-balansa|zhurnal-bez-balansa|mut_zhurnal'
    'audit-bez-redakcii|evidence-sekrety|mut_audit'
    'bez-razdeleniya|evidence-razdelenie|mut_bez_razdeleniya'
    'dvizhok-podmena|evidence-ne-native|mut_dvizhok_podmena'
    'testy-pustye|testy-pustye|mut_testy_pustye'
    'klyuch-chuzhoj|evidence-chuzhoj-klyuch|mut_klyuch_chuzhoj'
    'sql-pustoj|evidence-otsutstvuet|mut_sql_pustoj'
    'odnorazovaya-pobochka|testy-ne-zelenye|mut_odnorazovaya'
    'svezhaya-rol-postgres|evidence-ne-native|mut_rol_postgres'
    'svezhij-sqlstate-vne|evidence-ne-native|mut_sqlstate_vne'
    'derevnaya-rol-lf|evidence-ne-native|mut_rol_lf'
    'derevnyj-klyuch-lf|evidence-chuzhoj-klyuch|mut_klyuch_lf'
  )
  for d in "${dekos[@]}"; do
    n="${d%%|*}"; want="$(printf '%s' "${d#*|}" | cut -d'|' -f1)"; M="$(printf '%s' "${d#*|}" | cut -d'|' -f2-)"
    rm -rf "$SCRATCH/dek"; cp -r "$TOY_SRC" "$SCRATCH/dek"; rm -rf "$SCRATCH/dek/.toy-state"
    SERVER="$SCRATCH/dek/server/infrastructure/migrations/run.js"
    RLS="$SCRATCH/dek/tests/integration/core/rls.test.js"
    FIN="$SCRATCH/dek/tests/integration/core/finance_journal.test.js"
    CORE="$SCRATCH/dek/tests/integration/core/run_core.js"
    EVN="$SCRATCH/dek/docs/evidence/core/20261021T000000Z.native/run.json"
    EVP="$SCRATCH/dek/docs/evidence/core/20261021T000000Z.pglite/run.json"
    TMP="$SCRATCH/dek/evidence.tmp"
    eval "$M"
    got="$( { struktura "$SCRATCH/dek" toy && toy_trio "$SCRATCH/dek" && damage_probe "$SCRATCH/dek" toy && povedencheskie_proby_toy "$SCRATCH/dek"; } 2>&1 )"
    rc=$?
    [ "$rc" -eq 1 ] || { echo "ОТКАЗ: yadro121: orakul-slep (декой $n rc=$rc, ждали 1)" >&2; exit 1; }
    printf '%s' "$got" | grep -Fq "$want" \
      || { echo "ОТКАЗ: yadro121: orakul-slep (декой $n: причина не «$want»)" >&2; exit 1; }
  done
  echo "yadro121: model ok: честный мини-мир зелёный (поведенческие пробы test:core пройдены); декоев отвергнуто ровно своими причинами: ${#dekos[@]}" >&2
  exit 0
}

case "${1:-}" in
  --model) sudit_model ;;
  --repo)  sudit_produkt "${2:-}" ;;
  *) echo "использование: yadro_oracle.sh --model | --repo <корень>" >&2; exit 2 ;;
esac
