#!/usr/bin/env bash
# Контракт 119 — красная батарея импорта бандла 3.15 (аддитивное слияние).
#
# Предмет клетки — НЕ логика батареи, а вердикт ОРАКУЛА import315_oracle.sh
# над миром: m-baza — база без импорта (rc 1 import-otsutstvuet); k-model —
# честная модель model_import315_119.sh (rc 0); d*-клетки — модель + ОДНА
# мутация (обманка обязана быть поймана ИМЕНОВАННОЙ причиной; соответствие
# входа и ветви держится кодом диспетчеризации — мир + мутация + ожидание в
# одном case, Н-39; ожидания — литералы, Н-351).
# Круг 3 (арбитраж 119-b2, П1–П3): d21/d22 — писатель-пустышки генератора
# (generator-ne-pishet, пробы W1/W2 оракула; мир d22 закоммичен), d23 —
# непустой known-failures при зелёном валидаторе (known-failures-nepust, jq).
# v2 (форк n119-zona-lane, ОТВЕЧЕНО (А)): d24 — R-1 немигрированный spec-3.14
# красен на смешанном дереве (spec314-kreven); d25 — «зелёный через
# known-failures» (known-failures-nepust); d26/d27/d28 — пропуск
# extension-операций / ослабление профиля core / неопределённые профили
# (spec314-noop, пробы оракула); d29/d30/d31/d32 — R-2 обманки app/schemas:
# руками, sha подогнан, --check обойдён, пересборка не детерминирована
# (gencontracts-rashozhdenie / schemas-rashozhdenie / gencontracts-noop /
# gencontracts-ne-pishet). Круг 2 v2 (вердикт contracts-119-v2-krug1-fail,
# R-2/Б1): d33 — writer и --check СОГЛАСОВАНЫ на пустом документе при честной
# metadata (обе lane зелёные, published непуст) — различим ТОЛЬКО независимой
# от писателя проекционной сверкой openapi.json с published (schemas-proekcija).
# Арбитраж 119 v2 (П2): d34 — writer и --check согласованы на ПЕРЕСТАНОВКЕ
# operationId двух операций ядра при честной metadata (множества имён не
# меняются, обе lane зелёные) — различим ТОЛЬКО полной независимой сборкой
# оракула из САМОГО published (канон jq -S, cmp — schemas-proekcija).
#
# Режимы: без аргументов — суд ПРОДУКТА (живой клон Complior-back; путь из
# IMPORT315_119_BACK, умолчание /tmp/dev-harness-verify/Architect119/back):
# сегодня rc 1 import-otsutstvuet (красное предъявление на базе), после
# импорта implementer — rc 0. --model — все клетки против оракула (rc 0).
# --cell <имя> — одна клетка (неизвестное имя → rc 2).
#
# Анти-плацебо (исполнимые предъявления, см. контракт §Приёмка):
#   (1) неизвестная клетка → rc 2; (2) стаб-оракул «всё зелено»
#   (IMPORT315_119_ORACLE=stab_vsegda_zelenyj.sh) → --model rc 1: обманки
#   ушли зелёными; (3) стаб «всё красно» → rc 1: k-model сломан;
#   (4) контрмодель оракула без блока аддитивности (sed по сентинелам
#   ADDITIV-315-BEG/END) обязана вернуть rc 0 на d12/d13 (мутации вне
#   производных генератора, накрытые регенерацией) → расхождение поймано.
#
# Миры одноразовые (mktemp $TMPDIR), git-коммиты миров локальны, network нет.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ORACLE="${IMPORT315_119_ORACLE:-$HERE/import315_oracle.sh}"
MODEL="$HERE/model_import315_119.sh"
BUNDLE="$HERE/toy_bundle315"
SCRATCH="${TMPDIR:-/tmp}"

# ── литеральные ожидания (Н-351) ────────────────────────────────────────────
RC_OK=0
RC_REF=1
R_IMPORT="import-otsutstvuet"
R_CAS="additivnost-cas"
R_CONSUMER="poterya-consumer"
R_REASONCODE="additivnost-reasoncode"
R_CORE="core-zamenen"
R_GENCHECK="generator-bez-check"
R_VOSPR="vosproizvodimost"
R_MANIFEST="manifest-rashozhdenie"
R_FILES="files-sha256-rashozhdenie"
R_KOREN="raskladka-vtoroj-koren"
R_STATUS="status-nechestnyj"
R_KNOWN="known-issues-nepolnyj"
R_ISTOR="istorika-podmenena"
R_SQL="sql-izmenen"
R_VALID="validator-kreven"
R_OWNERS="owners-rashozhdenie"
R_SOSTAV="sostav-rashozhdenie"
R_GENNOOP="generator-noop"
R_VALNOOP="validator-noop"
R_GENPIS="generator-ne-pishet"
R_KFNEPUST="known-failures-nepust"
R_SP314K="spec314-kreven"
R_SP314N="spec314-noop"
R_SCHEMAS="schemas-rashozhdenie"
R_GENCON="gencontracts-rashozhdenie"
R_GENCONOOP="gencontracts-noop"
R_GENCONPIS="gencontracts-ne-pishet"
R_SCHEMPROJ="schemas-proekcija"

CELLS="m-baza k-model d1-cas-ifmatch d2-poterya-consumer d3-reasoncode d4-core-zamenen d5-generator-bez-check d6-generator-ne-idempotent d7-manifest-vret d8-files-sha256-staryj d9-vtoroj-koren d10-status-nechestnyj d11-known-issues-soglasovanno-nepolnyj d12-istorika-podmenena d13-sql-izmenen d16-validator-kreven d17-owners-nedostavleny d18-generator-noop d19-validator-noop d20-extension-pustoj d21-generator-pisatel-noop d22-generator-vosstanavlivaet-iz-git d23-known-failures-nepust d24-spec314-nemigrirovan d25-spec314-known-failures d26-spec314-propusk-extension d27-spec314-oslablenie-core d28-spec314-profili-neopredeleny d29-schemas-rukami d30-schemas-sha-podognan d31-gencontracts-check-obhozhden d32-gencontracts-nedeterminirovan d33-gencontracts-pustoj-dokument d34-gencontracts-perestanovka-operationid"

make_base_world() {  # → путь мира (мини-Complior-back 5.8.4, импорта нет)
  local d
  d="$(mktemp -d "$SCRATCH/import315-world-XXXXXX")" || return 9
  mkdir -p "$d/docs/contracts" "$d/docs/data" "$d/tests/spec-3.14" "$d/tests/tools" "$d/migrations"
  cat > "$d/docs/contracts/BrokerOS_Unified_OpenAPI_v3.yaml" <<'YAML'
openapi: 3.1.0
info:
  title: BrokerOS Unified (toy)
  version: 5.8.4
paths:
  /disclosures/{id}/acknowledge:
    post:
      operationId: acknowledgeDisclosure
      parameters:
        - name: If-Match
          in: header
          required: true
          schema: {type: string}
      responses:
        '200':
          description: ok
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ActionRequest'
  /actions:
    post:
      operationId: requestAction
      parameters:
        - name: If-Match
          in: header
          required: true
          schema: {type: string}
      responses:
        '200': {description: ok}
components:
  schemas:
    ActionRequest:
      type: object
      properties:
        reason:
          $ref: '#/components/schemas/ReasonCode'
    ReasonCode:
      type: string
      enum: [OK, APPROVAL_ACTION_ALREADY_DISPATCHED, CAS_STALE]
YAML
  printf '%s\n' '{"cas_operations":{"acknowledgeDisclosure":"If-Match обязателен (strong, VERSIONED_TARGET_CAS)","requestAction":"If-Match обязателен с исключениями pause/stop"}}' \
    > "$d/docs/contracts/backend-5_8_4-alignment.json"
  # реальная грамматика базы: подтверждённые записи БЕЗ id (operation_id +
  # adoption_status), как в продукте (50 из 53 без id); потребители и их
  # consumers-проекция в operation-index сохраняются идентично (Б3)
  printf '%s\n' '{"workflow_consumers":[{"operation_id":"acknowledgeDisclosure","kind":"frame","adoption_status":"confirmed_5_8_4","automatic_on_entry":false,"guard":"Explicit disclosure acknowledge; strong If-Match required"},{"operation_id":"requestAction","kind":"frame","adoption_status":"confirmed_5_8_4","automatic_on_entry":false,"guard":"Action request with If-Match exceptions pause/stop"}]}' \
    > "$d/docs/contracts/frontend-consumer-bindings.json"
  printf '%s\n' '{"operations":[{"operation_id":"acknowledgeDisclosure","consumers":[{"kind":"frame","adoption_status":"confirmed_5_8_4","guard":"Explicit disclosure acknowledge; strong If-Match required"}]},{"operation_id":"requestAction","consumers":[{"kind":"frame","adoption_status":"confirmed_5_8_4","guard":"Action request with If-Match exceptions pause/stop"}]}]}' \
    > "$d/docs/contracts/operation-index.json"
  VS01="$(sha256sum "$d/docs/contracts/BrokerOS_Unified_OpenAPI_v3.yaml" | cut -d' ' -f1)"
  printf '{"package_version":"3.14.2.2","operations":2,"schemas":2,"consumers":2,"required_files":["docs/contracts/BrokerOS_Unified_OpenAPI_v3.yaml","docs/contracts/frontend-consumer-bindings.json"],"vs01_spec_freeze":{"status":"FROZEN_FOR_IMPLEMENTATION","api":"5.8.4","sha256":"%s"}}\n' "$VS01" \
    > "$d/docs/VERSION_MANIFEST.json"
  printf '%s\n' 'import sys; print("PASS_STATIC failures=[]"); sys.exit(0)' > "$d/tests/spec-3.14/validate_contract_v3_9.py"
  printf '%s\n' '{"spec_version":"5.8.4","failure_ids":[],"fingerprints":{}}' \
    > "$d/tests/tools/contract-validator-known-failures.json"
  printf '%s\n' 'import subprocess,sys; sys.exit(0)  # базовая эра: без --check' \
    > "$d/tests/tools/generate_derived.py"
  printf 'CREATE TABLE t1 (id int);\n' > "$d/migrations/001_core.sql"
  printf 'ALTER TABLE t1 ENABLE ROW LEVEL SECURITY;\n' > "$d/migrations/002_rls.sql"
  printf '{"tests/spec-3.14/": "пакетные проверки комплекта 3.14"}\n' > "$d/structure-policy.json"
  printf 'mini Complior-back 5.8.4 (base)\n' > "$d/README.md"
  printf '*.genstamp\n' > "$d/.gitignore"
  git -C "$d" init -q
  git -C "$d" -c user.name=toy -c user.email=toy@local add -A
  git -C "$d" -c user.name=toy -c user.email=toy@local commit -qm "base 5.8.4"
  printf '%s\n' "$d"
}

rehash_files() {  # $1 = мир: пересбор FILES.sha256 по правилу генератора —
  # обманка, заменяющая tracked-файл, обязана накрыть следы инвентарём, чтобы
  # её дефект наблюдался в СВОЕЙ ветви (Н-39), а не в files-sha256 (Н-201-класс)
  local W="$1"
  (cd "$W" && python3 - <<'PY'
import hashlib, subprocess
from pathlib import Path
R = Path('.').resolve()
names = subprocess.check_output(['git', 'ls-files', '-z', '--cached', '--others',
                                 '--exclude-standard'], cwd=R).decode().split('\0')
inv = sorted(n for n in names if n and n != 'FILES.sha256' and (R / n).is_file())
(R / 'FILES.sha256').write_text(''.join(
    hashlib.sha256((R / n).read_bytes()).hexdigest() + '  ' + n + '\n' for n in inv))
PY
  )
}

mutate() {  # $1 = клетка, $2 = мир (после model_import315_119.sh)
  local c="$1" W="$2" PUB="$2/docs/contracts/BrokerOS_Unified_OpenAPI_v3.yaml"
  case "$c" in
    d1-cas-ifmatch)
      python3 - "$PUB" <<'PY'
import sys
p = sys.argv[1]; s = open(p).read()
i = s.index('operationId: acknowledgeDisclosure')
j = s.index('operationId: requestAction')
head, tail = s[:j], s[j:]
head = head.replace('required: true', 'required: false', 1)
open(p, 'w').write(head + tail)
PY
      ;;
    d2-poterya-consumer)
      jq 'del(.workflow_consumers[0])' "$W/docs/contracts/frontend-consumer-bindings.json" > "$W/bind.tmp"
      mv "$W/bind.tmp" "$W/docs/contracts/frontend-consumer-bindings.json"
      ;;
    d3-reasoncode)
      sed -i 's/APPROVAL_ACTION_ALREADY_DISPATCHED, //' "$PUB"
      ;;
    d4-core-zamenen)
      cp "$BUNDLE/sources/core.openapi.yaml" "$W/docs/sources/backend-3.15/core.openapi.yaml"
      ;;
    d5-generator-bez-check)
      printf '%s\n' 'print("ОШИБКА: --check не поддерживается (генератор бандла)")\nimport sys; sys.exit(3)' \
        > "$W/tests/tools/generate_derived.py"
      rehash_files "$W"
      ;;
    d6-generator-ne-idempotent)
      mv "$W/tests/tools/generate_derived.py" "$W/tests/tools/generate_derived_real.py"
      printf '%s\n' 'import pathlib, subprocess, sys, time' \
        'here = pathlib.Path(__file__).parent' \
        'rc = subprocess.run([sys.executable, str(here / "generate_derived_real.py")] + sys.argv[1:]).returncode' \
        '(here / "gen-stamp.genstamp").open("a").write("regen %d\\n" % time.time_ns())' \
        'sys.exit(rc)' > "$W/tests/tools/generate_derived.py"
      rehash_files "$W"
      ;;
    d7-manifest-vret)
      jq '.operations += 1' "$W/docs/VERSION_MANIFEST.json" > "$W/mani.tmp"
      mv "$W/mani.tmp" "$W/docs/VERSION_MANIFEST.json"
      ;;
    d8-files-sha256-staryj)
      printf '\n' >> "$W/README.md"
      ;;
    d9-vtoroj-koren)
      mkdir "$W/Complior_Backend_v3_15"
      cp "$BUNDLE/README_RU.md" "$W/Complior_Backend_v3_15/"
      ;;
    d10-status-nechestnyj)
      jq '(.workflow_consumers[] | select(.operation_id=="createPlateOrder") | .adoption_status) = "confirmed_5_8_4"' \
        "$W/docs/contracts/frontend-consumer-bindings.json" > "$W/bind.tmp"
      mv "$W/bind.tmp" "$W/docs/contracts/frontend-consumer-bindings.json"
      ;;
    d11-known-issues-soglasovanno-nepolnyj)
      # Б5: ОБА реестра согласованно теряют id (валидатор зелён — declared ⊆
      # registry); красное доказывает ТОЛЬКО пин оракула, не сверка двух
      # подконтрольных импорту файлов
      printf '%s\n' '{"ids":["kfz-termination-consumer-gap"]}' > "$W/tests/spec-3.15/known-issues-315.json"
      printf '%s\n' '{"ids":["kfz-termination-consumer-gap"]}' > "$W/docs/sources/backend-3.15/provenance/KNOWN-ISSUES-DECLARED.json"
      rehash_files "$W"
      ;;
    d12-istorika-podmenena)
      cp "$BUNDLE/sources/core.openapi.yaml" "$W/docs/history/3_14/BrokerOS_Unified_OpenAPI_v3.yaml"
      (cd "$W" && python3 tests/tools/generate_derived.py >/dev/null 2>&1)
      ;;
    d13-sql-izmenen)
      printf '\n-- sneaky\n' >> "$W/migrations/001_core.sql"
      (cd "$W" && python3 tests/tools/generate_derived.py >/dev/null 2>&1)
      ;;
    d16-validator-kreven)
      printf '%s\n' 'import sys; print("ВАЛИДАТОР ОТКАЗ: сломан"); sys.exit(1)' \
        > "$W/tests/spec-3.15/validate_import_315.py"
      rehash_files "$W"
      ;;
    d17-owners-nedostavleny)
      jq '.tables=[.tables[0]]' "$W/docs/data/physical-model.json" > "$W/pm.tmp"
      mv "$W/pm.tmp" "$W/docs/data/physical-model.json"
      ;;
    d18-generator-noop)
      printf '%s\n' 'import sys; sys.exit(0)  # noop: --check всегда зелёный' \
        > "$W/tests/tools/generate_derived.py"
      rehash_files "$W"
      ;;
    d19-validator-noop)
      printf '%s\n' 'print("PASS_IMPORT315 failures=[] known_failures=0")  # noop' \
        > "$W/tests/spec-3.15/validate_import_315.py"
      rehash_files "$W"
      ;;
    d20-extension-pustoj)
      # Б1: пустой extension при самосогласованном дереве (FILES пересобран);
      # производные честные — расхождение ловит ТОЛЬКО пин состава (sha
      # extension ≠ бандлу), до ветвей генератора/манифеста
      printf 'openapi: 3.1.0\ninfo:\n  title: empty\n  version: 5.9.0\npaths:\ncomponents:\n' \
        > "$W/docs/sources/backend-3.15/platform-extension.yaml"
      rehash_files "$W"
      ;;
    d21-generator-pisatel-noop)
      # Б2а (арбитраж 119, П1): писатель-пустышка при исправном --check;
      # режется пробой W1 оракула — writer без аргументов обязан восстановить
      # устаревший производный до байтов судимого дерева (generator-ne-pishet)
      python3 - "$W/tests/tools/generate_derived.py" <<'PY'
import sys
p = sys.argv[1]
src = open(p).read()
open(p, 'w').write('import sys\nif "--check" not in sys.argv: sys.exit(0)\n' + src)
PY
      rehash_files "$W"
      ;;
    d22-generator-vosstanavlivaet-iz-git)
      # Б2а (арбитраж 119, П2): пустышка второго порядка — писатель =
      # «восстанови выходы из git», --check исходный. Режется ТОЛЬКО пробой W2
      # (генерация на ином входе), поэтому мир ЗАКОММИЧЕН: без коммита restore
      # вернёт базовые FILES/выходы, расходясь с судимым деревом, и клетку поймает
      # П1 (W1), а не своя ветвь (замер 9 арбитража; Н-39)
      python3 - "$W/tests/tools/generate_derived.py" <<'PY'
import sys
p = sys.argv[1]
src = open(p).read()
open(p, 'w').write('import subprocess, sys\n'
                   'if "--check" not in sys.argv:\n'
                   '    subprocess.run(["git", "checkout", "-q", "--", "docs/contracts", '
                   '"docs/VERSION_MANIFEST.json", "FILES.sha256"])\n'
                   '    sys.exit(0)\n' + src)
PY
      rehash_files "$W"
      git -C "$W" -c user.name=toy -c user.email=toy@local commit -qam "d22: writer = git-restore, мир закоммичен"
      ;;
    d23-known-failures-nepust)
      # Б2б (арбитраж 119, П3): валидатор без проверки пустоты + непустой реестр.
      # ОБЕ правки сразу — иначе клетку ловит validator-kreven, а не своя ветвь;
      # пустоту реестра проверяет оракул по файлу (known-failures-nepust)
      python3 - "$W/tests/spec-3.15/validate_import_315.py" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
needle = "if kf['failure_ids'] or kf['fingerprints']:"
assert needle in s, 'валидатор не содержит ожидаемой проверки'
open(p, 'w').write(s.replace(needle, 'if False:'))
PY
      printf '%s\n' '{"spec_version":"5.8.4","failure_ids":["hidden-import-failure"],"fingerprints":{"hidden-import-failure":"abc"}}' \
        > "$W/tests/tools/contract-validator-known-failures.json"
      rehash_files "$W"
      ;;
    d24-spec314-nemigrirovan)
      # R-1: валидатор эры одного профиля — требование ['5.8.x'] ко ВСЕМ
      # операциям; на смешанном дереве (extension 5.9.0) красен
      # current_exact_version — ровно боль lane package после импорта
      python3 - "$W/tests/spec-3.14/validate_contract_v3_9.py" <<'PY'
import sys
p = sys.argv[1]
open(p, 'w').write(
    '''#!/usr/bin/env python3
# валидатор ДО миграции (один профиль): все операции обязаны жить на 5.8.x
import sys
from pathlib import Path
R = Path(__file__).resolve().parents[2]
f = []
for ln in (R / 'docs/contracts/BrokerOS_Unified_OpenAPI_v3.yaml').read_text().split('\\n'):
    s = ln.strip()
    if s.startswith('operationId:'):
        pass
    elif s.startswith('x-supported-contract-versions:') and s.split(':', 1)[1].strip() != "['5.8.x']":
        f.append('current_exact_version')
print(('FAIL_STATIC' if f else 'PASS_STATIC') + ' failures=[' + ', '.join(f) + ']')
sys.exit(1 if f else 0)
''')
PY
      rehash_files "$W"
      ;;
    d25-spec314-known-failures)
      # (а-1) «зелёный через known-failures»: отказы вычитаются реестром
      # подавлений. ТРИ правки сразу (паттерн d23): spec-3.15 валидатор тоже
      # не краснеет на непустом реестре, иначе клетку ловит validator-kreven,
      # а не своя ветвь; наблюдаемость обманки — НЕПУСТОЙ реестр (инвариант
      # файла known-failures-nepust, оракул судит файл, не вывод валидатора)
      # Круг 2 (совет критика): подавление вставляется ПЕРЕД печатью, ПОСЛЕ
      # сбора failures — прямой запуск двойника исполним (без UnboundLocalError)
      python3 - "$W/tests/spec-3.14/validate_contract_v3_9.py" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
needle = "    print('%s failures=[%s]' % ('PASS_STATIC' if not failures else 'FAIL_STATIC',"
assert needle in s, 'валидатор не содержит ожиданной точки печати'
sup = ("    import json as _json\n"
       "    _kf = _json.loads((R / 'tests/tools/contract-validator-known-failures.json').read_text())\n"
       "    failures = [f for f in failures if f not in _kf['failure_ids']]  # подавление\n")
open(p, 'w').write(s.replace(needle, sup + needle))
PY
      python3 - "$W/tests/spec-3.15/validate_import_315.py" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
needle = "if kf['failure_ids'] or kf['fingerprints']:"
assert needle in s, 'валидатор не содержит ожидаемой проверки'
open(p, 'w').write(s.replace(needle, 'if False:'))
PY
      printf '%s\n' '{"spec_version":"5.8.4","failure_ids":["createPlateOrder_profile","current_exact_version"],"fingerprints":{}}' \
        > "$W/tests/tools/contract-validator-known-failures.json"
      rehash_files "$W"
      ;;
    d26-spec314-propusk-extension)
      # (а-2) валидатор судит только core-операции: отказ ветви extension
      # выключен (первое вхождение append — ветвь extension, НЕ elif core:
      # иначе core-ветвь ловит маркер 5.9.0 и валидатор краснеет на конформном
      # дереве); различим ТОЛЬКО пробой оракула (перевранный маркер расширения)
      python3 - "$W/tests/spec-3.14/validate_contract_v3_9.py" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
needle = "failures.append('%s_profile' % op)"
assert s.count(needle) == 2, 'валидатор не содержит двух ожидаемых ветвей'
head, sep, tail = s.partition(needle)
open(p, 'w').write(head + "pass  # пропуск extension-операций" + tail)
PY
      rehash_files "$W"
      ;;
    d27-spec314-oslablenie-core)
      # (а-3) ослабление профиля core: переводы core-операции на любой иной
      # профиль не отказывают (ветвь core выключена); различим пробой оракула
      python3 - "$W/tests/spec-3.14/validate_contract_v3_9.py" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
needle = "        elif marker is not None:"
assert needle in s, 'валидатор не содержит ожидаемой ветви'
open(p, 'w').write(s.replace(needle, "        elif False:  # ослабление профиля core"))
PY
      rehash_files "$W"
      ;;
    d28-spec314-profili-neopredeleny)
      # (а-4) открытый алфавит: любые маркеры принимаются, замкнутость
      # {ядро без маркера, extension ровно ['5.9.0']} не проверяется;
      # различим пробой оракула (неопределённый профиль ['9.9.9'])
      python3 - "$W/tests/spec-3.14/validate_contract_v3_9.py" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
needle = "            if marker != \"['%s']\" % ext_v:"
assert needle in s, 'валидатор не содержит ожидаемой ветви'
open(p, 'w').write(s.replace(needle, "            if marker is None:  # алфавит профилей открыт"))
PY
      rehash_files "$W"
      ;;
    d29-schemas-rukami)
      # (б) app/schemas/openapi.json отредактирован руками: source.json
      # по-прежнему сходится с published, но пересборка отличается байтами —
      # ловит сухой --check оракула (gencontracts-rashozhdenie)
      printf '/* hand-edit */\n' >> "$W/app/schemas/openapi.json"
      rehash_files "$W"
      ;;
    d30-schemas-sha-podognan)
      # (б) source.json подогнан руками: source_sha256 указывает на снапшот
      # БАЗЫ (история 3_14), а не на смежный published — сам R-2; ловит
      # файловая ветвь оракула (schemas-rashozhdenie), до запуска --check
      BASE_SHA="$(sha256sum "$W/docs/history/3_14/BrokerOS_Unified_OpenAPI_v3.yaml" | cut -d' ' -f1)"
      jq --arg s "$BASE_SHA" '.source_sha256 = $s' "$W/app/schemas/source.json" > "$W/src.tmp"
      mv "$W/src.tmp" "$W/app/schemas/source.json"
      rehash_files "$W"
      ;;
    d31-gencontracts-check-obhozhden)
      # (б) --check обойдён: сравнение всегда зелёное, писатель честный;
      # различим ТОЛЬКО пробой оракула (устаревший производный обязан краснеть)
      python3 - "$W/tests/tools/gen-contracts.js" <<'PY'
import sys
p = sys.argv[1]
src = open(p).read()
open(p, 'w').write("if (process.argv.includes('--check')) process.exit(0);  // обход --check\n" + src)
PY
      rehash_files "$W"
      ;;
    d32-gencontracts-nedeterminirovan)
      # (в) пересборка не детерминирована: писатель дописывает метку времени
      # в производный после генерации; на конформном дереве и под --check
      # зелён — различим пробой W1-зеркала (писатель обязан восстановить
      # байты судимого дерева; cmp ловит дрейф)
      cat >> "$W/tests/tools/gen-contracts.js" <<'JS'
// [d32] недетерминизм писателя: метка времени в производном
if (!process.argv.includes('--check')) {
  try { require('node:fs').appendFileSync(
    path.join(REPO, 'app', 'schemas', 'openapi.json'), '/* regen ' + Date.now() + ' */\n'); } catch (e) {}
}
JS
      rehash_files "$W"
      ;;
    d33-gencontracts-pustoj-dokument)
      # (г) ОБХОД критика круга 1 v2 (R-2/Б1): генератор строит docJson не из
      # YAML, а константой '{}' — metadata (source_sha256, api_version, openapi)
      # остаётся честной из настоящего published, checker сравнивает диск с той
      # же константой; писатель И check согласованы, обе lane зелёные — весь
      # опубликованный API исчез из app/schemas. Различим ТОЛЬКО проекционной
      # сверкой оракула (состав против САМОГО published, не против генератора)
      python3 - "$W/tests/tools/gen-contracts.js" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
old = ("  const docJson = `${execFileSync('python3', ['-c', PY, path.join(REPO, SOURCE)],"
       " { encoding: 'utf8' }).trimEnd()}\\n`;\n"
       "  const doc = JSON.parse(docJson);\n")
assert old in s, 'генератор не содержит ожидаемого построения docJson'
new = ("  const docJson = '{}\\n';  // [d33] согласованный пустой производный\n"
       "  const doc = JSON.parse(execFileSync('python3', ['-c', PY, path.join(REPO, SOURCE)],"
       " { encoding: 'utf8' }));\n")
open(p, 'w').write(s.replace(old, new))
PY
      (cd "$W" && node tests/tools/gen-contracts.js)
      rehash_files "$W"
      ;;
    d34-gencontracts-perestanovka-operationid)
      # (г) ОБХОД критика круга 2 v2 (Б1; арбитраж 119 v2 П2): writer строит
      # docJson из YAML, но с ОБМЕНОМ operationId двух операций ядра
      # (acknowledge POST ↔ actions POST); metadata честна (source_sha256 =
      # sha256 настоящего published, api_version/openapi без изменений),
      # checker сравнивает диск с той же перестановкой — --check зелёный,
      # множества имён/путь×метод/схем НЕ меняются, обе lane зелёные; связь
      # operationId↔путь×метод потеряна. Различим ТОЛЬКО полной независимой
      # сборкой оракула из САМОГО published (канон jq -S, cmp)
      python3 - "$W/tests/tools/gen-contracts.js" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
old = ("  const docJson = `${execFileSync('python3', ['-c', PY, path.join(REPO, SOURCE)],"
       " { encoding: 'utf8' }).trimEnd()}\\n`;\n"
       "  const doc = JSON.parse(docJson);\n")
assert old in s, 'генератор не содержит ожидаемого построения docJson'
new = ("  const doc = JSON.parse(execFileSync('python3', ['-c', PY, path.join(REPO, SOURCE)],"
       " { encoding: 'utf8' }));\n"
       "  // [d34] согласованная перестановка operationId ядра (metadata честна)\n"
       "  [doc.paths['/disclosures/{id}/acknowledge'].post.operationId,\n"
       "   doc.paths['/actions'].post.operationId] =\n"
       "   [doc.paths['/actions'].post.operationId,\n"
       "    doc.paths['/disclosures/{id}/acknowledge'].post.operationId];\n"
       "  const docJson = JSON.stringify(doc) + '\\n';\n")
open(p, 'w').write(s.replace(old, new))
PY
      (cd "$W" && node tests/tools/gen-contracts.js)
      rehash_files "$W"
      ;;
  esac
}

expect_rc() { case "$1" in m-baza|d1-cas-ifmatch|d2-poterya-consumer|d3-reasoncode|d4-core-zamenen|d5-generator-bez-check|d6-generator-ne-idempotent|d7-manifest-vret|d8-files-sha256-staryj|d9-vtoroj-koren|d10-status-nechestnyj|d11-known-issues-soglasovanno-nepolnyj|d12-istorika-podmenena|d13-sql-izmenen|d16-validator-kreven|d17-owners-nedostavleny|d18-generator-noop|d19-validator-noop|d20-extension-pustoj|d21-generator-pisatel-noop|d22-generator-vosstanavlivaet-iz-git|d23-known-failures-nepust|d24-spec314-nemigrirovan|d25-spec314-known-failures|d26-spec314-propusk-extension|d27-spec314-oslablenie-core|d28-spec314-profili-neopredeleny|d29-schemas-rukami|d30-schemas-sha-podognan|d31-gencontracts-check-obhozhden|d32-gencontracts-nedeterminirovan|d33-gencontracts-pustoj-dokument|d34-gencontracts-perestanovka-operationid) echo 1;; k-model) echo 0;; *) echo 2;; esac; }
expect_reason() {
  case "$1" in
    m-baza) echo "$R_IMPORT";;
    k-model) echo "IMPORT315_OK";;
    d1-cas-ifmatch) echo "$R_CAS";;
    d2-poterya-consumer) echo "$R_CONSUMER";;
    d3-reasoncode) echo "$R_REASONCODE";;
    d4-core-zamenen) echo "$R_CORE";;
    d5-generator-bez-check) echo "$R_GENCHECK";;
    d6-generator-ne-idempotent) echo "$R_VOSPR";;
    d7-manifest-vret) echo "$R_MANIFEST";;
    d8-files-sha256-staryj) echo "$R_FILES";;
    d9-vtoroj-koren) echo "$R_KOREN";;
    d10-status-nechestnyj) echo "$R_STATUS";;
    d11-known-issues-soglasovanno-nepolnyj) echo "$R_KNOWN";;
    d12-istorika-podmenena) echo "$R_ISTOR";;
    d13-sql-izmenen) echo "$R_SQL";;
    d16-validator-kreven) echo "$R_VALID";;
    d17-owners-nedostavleny) echo "$R_OWNERS";;
    d18-generator-noop) echo "$R_GENNOOP";;
    d19-validator-noop) echo "$R_VALNOOP";;
    d20-extension-pustoj) echo "$R_SOSTAV";;
    d21-generator-pisatel-noop) echo "$R_GENPIS";;
    d22-generator-vosstanavlivaet-iz-git) echo "$R_GENPIS";;
    d23-known-failures-nepust) echo "$R_KFNEPUST";;
    d24-spec314-nemigrirovan) echo "$R_SP314K";;
    d25-spec314-known-failures) echo "$R_KFNEPUST";;
    d26-spec314-propusk-extension) echo "$R_SP314N";;
    d27-spec314-oslablenie-core) echo "$R_SP314N";;
    d28-spec314-profili-neopredeleny) echo "$R_SP314N";;
    d29-schemas-rukami) echo "$R_GENCON";;
    d30-schemas-sha-podognan) echo "$R_SCHEMAS";;
    d31-gencontracts-check-obhozhden) echo "$R_GENCONOOP";;
    d32-gencontracts-nedeterminirovan) echo "$R_GENCONPIS";;
    d33-gencontracts-pustoj-dokument) echo "$R_SCHEMPROJ";;
    d34-gencontracts-perestanovka-operationid) echo "$R_SCHEMPROJ";;
  esac
}

run_cell() {  # $1 = клетка → 0 совпало / 1 расхождение
  local c="$1" W out rc erc ereason verdict
  W="$(make_base_world)" || return 9
  if [ "$c" != "m-baza" ]; then
    bash "$MODEL" "$W" >/dev/null 2>&1 || { echo "клетка $c: модель импорта упала"; rm -rf "$W"; return 1; }
  fi
  mutate "$c" "$W"
  out="$(bash "$ORACLE" "$W" 2>&1)"; rc=$?
  erc="$(expect_rc "$c")"; ereason="$(expect_reason "$c")"
  if [ "$rc" = "$erc" ] && echo "$out" | grep -q "$ereason"; then
    echo "клетка $c: ЗЕЛЁНАЯ (rc=$rc, ${ereason})"
    verdict=0
  else
    echo "клетка $c: КРАСНАЯ — ожидание rc=$erc/${ereason}, факт rc=$rc, вывод: $(echo "$out" | tail -1)"
    verdict=1
  fi
  rm -rf "$W"
  return $verdict
}

MODE="${1:-}"
case "$MODE" in
  --cell)
    C="${2:-}"
    found=0
    for x in $CELLS; do [ "$x" = "$C" ] && found=1; done
    [ "$found" = 1 ] || { echo "ОТКАЗ: неизвестная клетка: $C" >&2; exit 2; }
    run_cell "$C"
    exit $?
    ;;
  --model)
    total=0; green=0; red=0; rcacc=0
    for c in $CELLS; do
      total=$((total + 1))
      if run_cell "$c"; then green=$((green + 1)); else red=$((red + 1)); rcacc=1; fi
    done
    echo "ИТОГ 119: клеток $total, зелёных $green, красных $red, rc=$rcacc"
    exit $rcacc
    ;;
  "")
    REPO="${IMPORT315_119_BACK:-/tmp/dev-harness-verify/Architect119/back}"
    if [ ! -d "$REPO" ]; then
      echo "ОТКАЗ: продукт-репозиторий недоступен: $REPO (задай IMPORT315_119_BACK)" >&2
      exit 2
    fi
    out="$(bash "$ORACLE" "$REPO" 2>&1)"; rc=$?
    echo "ПРОДУКТ $REPO:"
    echo "$out"
    echo "ИТОГ 119 (продукт): rc=$rc"
    exit $rc
    ;;
  *)
    echo "использование: red_import315_119.sh [--model | --cell <имя> | <нет: продукт>]" >&2
    exit 2
    ;;
esac
