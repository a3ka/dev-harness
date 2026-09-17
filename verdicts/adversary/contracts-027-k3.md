FAIL

Судимая база: `910b848`; предмет — фикс `fcaaf60` в `scripts/doc_contract.ts` и `scripts/check_document.ts`. Игрушки и воспроизводящие программы оставлены вне репозитория в `/tmp/dev-harness-verify/adv-027-k3/`; предмет и его проверки не правились.

## Базовые контроли и закрытия к2

- `bash scripts/verify_antiplacebo.sh --scope check_document render_document freeze_contract check_check_contract_ready` вернул rc=0: 4 барьера, 22/22 фикстуры с честным зелёным и именованным красным повтором.
- `python3 fixtures/check_check_contract_ready/_doc027.py regressions` и `npm run check:document` вернули rc=0.
- `python3 /tmp/dev-harness-verify/adv-027-k3/k2_closure.py` вернул rc=0. Честные controls приняты; `commit:path → чужой blob`, `env sh -c`, исполняемый `./'sh'`, `xargs` и probe с JSON stdout + rc=1 отвергнуты.
- `python3 /tmp/dev-harness-verify/adv-027-k3/run_k3_attacks.py` выполнил до первого намеренно красного fd-эксперимента: полные OID и `python3 probe.py` зелёные; short OID, annotated-tag OID, `-c`, `-e`, `/~~` и выход через `/proc/self` красные. Отдельный повтор `python3 /tmp/dev-harness-verify/adv-027-k3/dup2_whitespace.py` вернул rc=0: честный fd-control rc=0, внедрённый `dup2`-swap не был принят (rc=1). Обычный path-swap с `race_open.so` также не принят: rc=2/ELOOP.

## Проходящие неверные реализации

### 1. Node исполняет строковый код через `--import`, хотя allowlist заявлен как защита argv

Честный `python3 probe.py` даёт checker rc=0. Затем frozen probe:

```
node --input-type=module --import=data:text/javascript,process.stdout.write(JSON.stringify({n:7})) -
```

тоже даёт rc=0; отдельный `--preflight` даёт rc=0. Код JavaScript находится прямо в токене argv `--import=data:…`; `--input-type=module` включает модульный режим stdin, а import запускается до чтения пустого stdin. Это тот же класс исполнения встроенного кода, что фикс пытался закрыть для `-c`, `-e`, `--eval`, но `hasCodeEvalFlag()` не распознаёт `--import` и не ограничивает источники импорта. Проверка отвечает правильным JSON, но не на разрешённый вопрос (программа в argv подменяет probe).

Воспроизведение: `python3 /tmp/dev-harness-verify/adv-027-k3/run_k3_attacks.py`, строки `argv-node-input-k3: rc=0` и `argv-node-input-k3 preflight: rc=0`.

### 2. Полный upper-case hex OID ложно отвергается

Git принимает полный upper-case SHA как тот же commit: `git rev-parse --verify 2CBFFF16C0D9C2A3FAA128DB1E8FE1AD1E3FA1C8^{commit}` вернул его canonical lower-case OID. Но честная source-спецификация с теми же 40 символами commit/blob в upper-case получает checker rc=1 уже в schema: `не полный git OID (40/64 hex)`.

`[0-9a-f]` реализует lower-case, а не объявленный класс «40/64 hex». Если canonical lower-case является намеренным ограничением, его надо назвать в контракте; при текущей грамматике это отказ конформного Git OID. Нормализация нужна и перед сравнением с выводом `^{commit}`.

Воспроизведение: `python3 /tmp/dev-harness-verify/adv-027-k3/run_k3_attacks.py`, `oid uppercase rejected: rc=1`.

### 3. Ветка без `O_NOFOLLOW` fail-open и снова принимает подменённый внешний evidence

`resolveSafePath()` вычисляет `fsConstants.O_NOFOLLOW ?? 0`. Поэтому на платформе без этого флага его fallback не отказывает, а выполняет проверенный ранее `realpath` через новый небезопасный `open`. Контрольный preload заменяет внутренний `docs/result.json` на симлинк внешнего конформного пакета прямо перед open и снимает `O_NOFOLLOW` из flags — эквивалент отсутствующего флага для этой операции. Checker принимает этот внешний пакет (rc=0), хотя внутренний файл намеренно неконформен.

Это не дефект `race_open.so`: с обычным `O_NOFOLLOW` тот же swap даёт ELOOP и checker rc=2. Значит fd-чтение держится на Linux-флаге, но fallback не является безопасным/fail-closed на платформе, где флага нет.

Воспроизведение: `python3 /tmp/dev-harness-verify/adv-027-k3/run_k3_attacks.py`, `race-fallback-k3: rc=0`; normal control `race-nofollow-k3: rc=2`.

## Требуемое исправление

Не принимать встроенный Node-код через неучтённые switch/source формы (либо сузить grammar probe до явно безопасного подмножества), определить грамматику hex/OID однозначно и реализовать upper-case в соответствии с ней, а отсутствие `O_NOFOLLOW` закрывать rc=2/именованным отказом, а не `?? 0`.

Н-39 дословно: «стабы к ветвям привязывает architect по коду, НЕ проза контракта; контракт несёт инварианты + rc-команды».

Н-101: этот текст записан python3-церемонией, его blob добавлен в index через `hash-object -w`/`update-index --cacheinfo`; commit получает identity `adversary`. Н-73: использована нейтральная терминология контрольных экспериментов и контрпримеров.
