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

CELLS="m-baza k-model d1-cas-ifmatch d2-poterya-consumer d3-reasoncode d4-core-zamenen d5-generator-bez-check d6-generator-ne-idempotent d7-manifest-vret d8-files-sha256-staryj d9-vtoroj-koren d10-status-nechestnyj d11-known-issues-soglasovanno-nepolnyj d12-istorika-podmenena d13-sql-izmenen d16-validator-kreven d17-owners-nedostavleny d18-generator-noop d19-validator-noop d20-extension-pustoj d21-generator-pisatel-noop d22-generator-vosstanavlivaet-iz-git d23-known-failures-nepust"

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
  esac
}

expect_rc() { case "$1" in m-baza|d1-cas-ifmatch|d2-poterya-consumer|d3-reasoncode|d4-core-zamenen|d5-generator-bez-check|d6-generator-ne-idempotent|d7-manifest-vret|d8-files-sha256-staryj|d9-vtoroj-koren|d10-status-nechestnyj|d11-known-issues-soglasovanno-nepolnyj|d12-istorika-podmenena|d13-sql-izmenen|d16-validator-kreven|d17-owners-nedostavleny|d18-generator-noop|d19-validator-noop|d20-extension-pustoj|d21-generator-pisatel-noop|d22-generator-vosstanavlivaet-iz-git|d23-known-failures-nepust) echo 1;; k-model) echo 0;; *) echo 2;; esac; }
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
