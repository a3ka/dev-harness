FAIL

## Блокирующее нарушение очередности

Контракт 087, §«Зоны», дословно требует: «**РАБОТА НЕ РАЗДАЁТСЯ: ЗОНА implementer 087 — до лендинга 083 в main (база пачки — main с уже слитым 083 …); до того implementer этого контракта не стартует**».

Репро в одноразовом SSH-клоне на `486ef12bf00183ff73480fa321da0c40a13b8e4a`:

```text
git merge-base --is-ancestor origin/wip/083/integration-2 main; rc=1
git merge-base --is-ancestor origin/wip/083/integration-2 HEAD; rc=1
```

`origin/wip/083/integration-2` указывает на `6aa38a58`; следовательно, 083 не является предком ни `main` (`a688c495`), ни PR#39 (`486ef12`). История PR от merge-base `5bfc85c4` содержит только `1f321809`, `85fb6ba0`, `b512ee39`, `486ef12`; коммитов 083 в ней нет. Это самостоятельный блокирующий FAIL независимо от статуса CI.

## Предмет на PR отсутствует

Area-of-change против `origin/main...486ef12` по всем путям ЗОНЫ implementer пуст: неизменны `scripts/ci_klass.sh`, `scripts/ci_vesa.sh`, `scripts/check_ci_gate.sh`, `scripts/gitw_preflight_071.sh`, `scripts/run_ci_lane.sh`, `scripts/gen_ci_steps.sh`, `scripts/verify_ci_parity.sh`, `registry/ci-steps.tsv`, `.github/workflows/ci.yml`, `package.json`, `config/ci_parity_exceptions.txt`.

То есть CI-wiring действительно не трогался, но не реализована и допустимая самостоятельная часть: в дереве нет `scripts/ci_klass.sh`, `scripts/ci_vesa.sh`, `scripts/run_ci_lane.sh` и `registry/ci-steps.tsv`.

Фактический приёмочный прогон:

```text
$ bash fixtures/_krasnye_087.sh
красная: предмет отсутствует
КРАСНОЕ 087: нет scripts/ci_klass.sh scripts/ci_vesa.sh scripts/run_ci_lane.sh registry/ci-steps.tsv
rc=1
```

Ожидаемый контрактом rc=0 и `ok=98 … 26/26` не достигнут. Гигиеническая батарея также красная: `bash fixtures/parsing_hygiene_battery/run_battery.sh ci_klass` → rc=1, `итог 0/4 классов закрыто` (вызовы классификатора возвращают 127, потому что файл отсутствует).

## Контрпробы и положительный контроль

Положительный контроль батареи исполним: `bash fixtures/ci_b_087/red_ci_b_087.sh --model` → rc=0, `ИТОГ 087: клеток ok=98 КРАСНО=0; стаб-пак: поймано 26/26 (model)`.

В нём независимо построены и пойманы, в частности, следующие обманные реализации с зелёной диффпробой:

* `tree-hash`: хеширует всё дерево и тем выдаёт учётный `HANDOFF.md` за код — пойман на `А1 U_handoff`; кодовая диффпроба `А1 K_content` зелёная.
* `legkij-glotaet`: лёгкий lane гасит отказ последнего `check:contract-frozen` — пойман исполнением на `К-исп legkij`; диффпроба измерения `В1` зелёная.
* `bez-zamera`: lane не печатает обязательную строку `замер: <ключ> <секунды>` — пойман на `В1`; диффпроба веса `В2` зелёная.

Тем самым честная модель и классификация лёгкого/тяжёлого с измерениями проверка различает; применить это к предмету невозможно, пока субъект отсутствует.

## Проводка судьи и неизменность

`bash scripts/verify_antiplacebo.sh --scope check_ci_gate gitw_preflight_071` → rc=1: восемь красных проб `check_ci_gate` предъявлены, но для барьера `gitw_preflight_071.sh` отсутствует обязательная семья `fixtures/gitw_preflight_071/case_*.sh`.

Неизменность замороженного текста и барьеров самого PR подтверждена:

```text
git diff --exit-code frozen/contracts/087/1..HEAD -- contracts/087-ci-b-klassy-izmenenij-hesh-koda.md  # rc=0
git diff --exit-code origin/main...HEAD -- contracts/087-ci-b-klassy-izmenenij-hesh-koda.md fixtures/_krasnye_087.sh fixtures/ci_b_087/ fixtures/parsing_hygiene_battery/profiles/ci_klass.sh  # rc=0
```

Это не отменяет FAIL: frozen-контракт и его проверка не были ослаблены, но реализация 087 на нелегитимной базе не начата и приёмка предмета красная.
