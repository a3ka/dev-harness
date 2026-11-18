FAIL
OBJECT=ebf7ac6b62692c51753c6ad8e2767e2130af19fc
СУД: repo=dev-harness; предмет=122; фаза=контракт v5, узкий суд дельты; роль=critic; вызов=один по слову владельца 2026-11-18 ~18:10 UTC; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit122V5; модель-факт=openai-codex/gpt-6.1-terra (allowed, models_actual --bind); SHA=ebf7ac6b62692c51753c6ad8e2767e2130af19fc; предыдущий=accept v4; исключение=слово владельца, батч №3 №3.

БЛОКИРУЕТ contracts/122-ci-proekta.md:41 — обязательная модель допускает неподдерживаемое выражение с `}` в строковом аргументе функции.
ОБЯЗАТЕЛЬСТВО: всякое выражение вне трёх разрешённых форм на run/env/working-directory получает `vyrazhenie-ne-podderzhano` до исполнения; обязательная честная модель должна ему соответствовать.
СОСТОЯНИЕ: явно заявленная область включает функции `format` и значения env (`contracts/122-ci-proekta.md:112`); ручной workflow с `env: {VALUE: "${{ format('}', github.sha) }}"}` и `run: 'true'`. Модель `fixtures/workshop_project/ci_proekta_122/model/ci_preflight.sh:74` ищет выражение регулярным выражением `\$\{\{[^}]*\}\}`, которое не проходит через `}` внутри строкового аргумента.
НАБЛЮДЕНИЕ: обязательная модель возвращает rc 0 `CIPREFLIGHT_OK jobs=1 station=0` вместо именованного отказа; её существующая операция обнаружения выражения пропускает достижимый через поддерживаемый рукописный workflow вход. Это не специально добавленный фильтр и не гипотетическая мутация.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: модель и приёмка различают выражения вне замкнутого алфавита, включая строковые аргументы с `}`, и отказывают до исполнения; разрешённые формы остаются зелёными.
ПРОИСХОЖДЕНИЕ: дельта
КЛАСС: К-09

БЛОКИРУЕТ contracts/122-ci-proekta.md:41 — модель теряет исходное значение унаследованного working-directory при отказе о побеге.
ОБЯЗАТЕЛЬСТВО: `working-directory-vne-kopii: <исходное значение поля до подстановки>`; defaults workflow и джобы входят в v+1.
СОСТОЯНИЕ: `defaults.run.working-directory: ${{ github.workspace }}/..`, шаг без собственного working-directory. В `fixtures/workshop_project/ci_proekta_122/model/ci_preflight.sh:210-221` модель берёт fallback после подстановки, а не исходный наследуемый путь.
НАБЛЮДЕНИЕ: rc 1, но причина содержит `/tmp/dev-harness-verify/ci122-pre-gmlp3nga/repo/..` вместо `${{ github.workspace }}/..`. Батарея при этом зелена: обе клетки побега проверяют только поле шага.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: исходное значение в диагностике сохраняется при наследовании с любого предусмотренного уровня и проверяется различающим входом; требование не диктует устройство реализации.
ПРОИСХОЖДЕНИЕ: дельта
КЛАСС: К-10

БЛОКИРУЕТ contracts/122-ci-proekta.md:53,62,108 — новые пары «стаб → ветвь/клетка» записаны в прозе контракта, хотя Н-39 поручает привязку architect по коду, а контракту — инварианты и rc-команды.
ОБЯЗАТЕЛЬСТВО: Н-39 дословно задан в поручении: привязки стаба к ветвям несёт код, не проза контракта.
СОСТОЯНИЕ: строка 53 перечисляет три новых имени и соответствующие удалённые операции, строка 62 указывает именованные красные клетки каждого нового стаба, строка 108 — конкретный стаб и его ветвь.
НАБЛЮДЕНИЕ: те же привязки уже находятся в шапках стаба и в коде модели; декларация строки 53 об отсутствии пар не устраняет их наличие в самом тексте.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: убрать новые прозаические привязки из контракта, сохранив инварианты и rc-команды; привязки должны остаться проверяемыми по коду architect.
ПРОИСХОЖДЕНИЕ: дельта
КЛАСС: К-01

## Выполненные пробы

Вход первой пробы (`/tmp/dev-harness-verify/Crit122V5/world/workflow.yml`):
```yaml
name: example
jobs:
  build:
    runs-on: ubuntu-latest
    env:
      VALUE: "${{ format('}', github.sha) }}"
    steps:
      - run: 'true'
```
```
$ bash fixtures/workshop_project/ci_proekta_122/model/ci_preflight.sh --repo /tmp/dev-harness-verify/Crit122V5/world --workflow workflow.yml
CIPREFLIGHT_OK jobs=1 station=0
rc=0
```
Вход второй пробы (`inherited.yml` в том же мире):
```yaml
name: example
defaults:
  run:
    working-directory: ${{ github.workspace }}/..
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: 'true'
```
```
$ bash fixtures/workshop_project/ci_proekta_122/model/ci_preflight.sh --repo /tmp/dev-harness-verify/Crit122V5/world --workflow inherited.yml
preflight ОТКАЗ: working-directory-vne-kopii: /tmp/dev-harness-verify/ci122-pre-gmlp3nga/repo/..
rc=1
```

`bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --stabs`:
```
ci122 ОТКАЗ: неизвестный ключ: --stabs
```
rc 2: у этой батареи нет такого режима; по её фактическому интерфейсу три новых стаба подключены через `CI_PROEKTA_122_PREFLIGHT`, каждый на `--model`. Они меняют существующие операции модели через единственные маркеры, а не добавляют запрет. Результаты: без workspace — rc 1, 53/9; без границы — rc 1, 60/2; без отказа выражений — rc 1, 58/4. Их дефекты пойманы, но это не устраняет два самостоятельных нарушения честной модели выше.

`bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model`, rc 0, сырой вывод:
```
CASE k-gen-check: rc=0 want=0 причина=gen OK: check ЗЕЛЁНАЯ
CASE k-preflight: rc=0 want=0 причина=CIPREFLIGHT_OK ЗЕЛЁНАЯ
CASE k-preflight-contract: rc=0 want=0 причина=CIPREFLIGHT_OK ЗЕЛЁНАЯ
CASE k-gates: rc=0 want=0 причина=PREDPOSYLKI_OK ЗЕЛЁНАЯ
CASE k-freeze: rc=0 want=0 причина=PREDPOSYLKI_OK ЗЕЛЁНАЯ
CASE z5-bez-ci-ne-trebuet: rc=0 want=0 причина=PREDPOSYLKI_OK ЗЕЛЁНАЯ
CASE g1-manifest-otsutstvuet: rc=1 want=1 причина=manifest-otsutstvuet ЗЕЛЁНАЯ
CASE g2-manifest-nevaliden: rc=1 want=1 причина=manifest-nevaliden ЗЕЛЁНАЯ
CASE g3-workflow-ruchnoj: rc=1 want=1 причина=workflow-ruchnoj ЗЕЛЁНАЯ
CASE g3-write-vosstanavlivaet: rc=0 want=0 причина=bajty vozvrashcheny ЗЕЛЁНАЯ
CASE g4-gen-nedeterminirovan: rc=0 want=0 причина=gen-nedeterminirovan: net ЗЕЛЁНАЯ
CASE g5-profil-rashozhdenie: rc=1 want=1 причина=profil-rashozhdenie ЗЕЛЁНАЯ
CASE g6-profil-otsutstvuet: rc=1 want=1 причина=profil-otsutstvuet ЗЕЛЁНАЯ
CASE g7-workflow-otsutstvuet: rc=1 want=1 причина=workflow-otsutstvuet ЗЕЛЁНАЯ
CASE g8-crlf-ruchnoj: rc=1 want=1 причина=workflow-ruchnoj ЗЕЛЁНАЯ
CASE g8-cr-ruchnoj: rc=1 want=1 причина=workflow-ruchnoj ЗЕЛЁНАЯ
CASE p1-yaml-nevaliden: rc=1 want=1 причина=yaml-nevaliden ЗЕЛЁНАЯ
CASE p2-working-directory-otsutstvuet: rc=1 want=1 причина=working-directory-otsutstvuet ЗЕЛЁНАЯ
CASE p3-shag-upal: rc=1 want=1 причина=shag-upal: ci/lomaetsa ЗЕЛЁНАЯ
CASE p4-station-skip: rc=0 want=0 причина=STATION-JOB: e2e ЗЕЛЁНАЯ
CASE p5-sekrety-ne-perechisleny: rc=1 want=1 причина=sekrety-ne-perechisleny: PILOT_DEMO_CODE ЗЕЛЁНАЯ
CASE p5-env-sekret-ne-perechislen: rc=1 want=1 причина=sekrety-ne-perechisleny: PILOT_DEMO_CODE ЗЕЛЁНАЯ
CASE p5-station-sekret-ne-perechislen: rc=1 want=1 причина=sekrety-ne-perechisleny: PILOT_DEMO_CODE ЗЕЛЁНАЯ
CASE p5-if-shag-sekret-ne-perechislen: rc=1 want=1 причина=sekrety-ne-perechisleny: CI122_IF_SHAG ЗЕЛЁНАЯ
CASE p5-if-dzhoba-var-ne-perechislena: rc=1 want=1 причина=sekrety-ne-perechisleny: CI122_IF_DZHOBA ЗЕЛЁНАЯ
CASE p5-with-sekret-ne-perechislen: rc=1 want=1 причина=sekrety-ne-perechisleny: CI122_WITH ЗЕЛЁНАЯ
CASE p6-sekret-podstavlyaetsya: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=1 ЗЕЛЁНАЯ
CASE p6-sekret-shag-ispolnyaetsya: rc=1 want=1 причина=shag-upal: ci/sekret ЗЕЛЁНАЯ
CASE p6-env-nositel-boli: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p6-env-cepochka: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p6-env-shag-ispolnyaetsya: rc=1 want=1 причина=shag-upal: verify/sekret-v-env ЗЕЛЁНАЯ
CASE p6z-env-ne-literal: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p6z-env-ravno-run: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p6z-env-literal-otkaz: rc=1 want=1 причина=shag-upal: verify/env-raven-literalu ЗЕЛЁНАЯ
CASE p7-wd-workflow-otsutstvuet: rc=1 want=1 причина=working-directory-otsutstvuet: missing-directory ЗЕЛЁНАЯ
CASE p7-wd-workflow-est: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p7-wd-pereopredelen-dzhoboj: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p7-wd-pereopredelen-shagom: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p8-wd-dvoetochie-vne-repo: rc=1 want=1 причина=working-directory-otsutstvuet: .. ЗЕЛЁНАЯ
CASE p8-wd-absolyutnyj-vne-repo: rc=1 want=1 причина=working-directory-otsutstvuet: /tmp ЗЕЛЁНАЯ
CASE p8-wd-absolyutnyj-r-bez-mutacii: rc=1 want=1 причина=working-directory-otsutstvuet: /tmp/dev-harness-verify/ci122/run-NIDE/world-nngX ЗЕЛЁНАЯ
CASE p9-wd-workspace: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-ws-v-run: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-ws-v-env: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-wd-defaults-workflow: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-wd-defaults-pereopredelenie: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-wd-dotdot-vne-kopii: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. ЗЕЛЁНАЯ
CASE p9-wd-simlink-pobeg: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/vne-kopii-link ЗЕЛЁНАЯ
CASE p9-forma-mobile: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p10-vyrazhenie-v-run: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ github.run_id }} ЗЕЛЁНАЯ
CASE p10-vyrazhenie-v-env: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ github.sha }} ЗЕЛЁНАЯ
CASE p10-funkcija-tojson: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ toJSON(needs) }} ЗЕЛЁНАЯ
CASE p10-otkaz-do-ispolnenija: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ matrix.x }} ЗЕЛЁНАЯ
CASE p10-uses-ne-suditsa: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE z1-predposylki-otsutstvuyut: rc=1 want=1 причина=predposylki-otsutstvuyut ЗЕЛЁНАЯ
CASE z2-sekrety-ne-zavedeny: rc=1 want=1 причина=sekrety-ne-zavedeny: PILOT_DEMO_CODE ЗЕЛЁНАЯ
CASE z3-gh-nedostupen: rc=1 want=1 причина=gh-nedostupen ЗЕЛЁНАЯ
CASE z4-predposylki-nevaliden: rc=1 want=1 причина=predposylki-nevaliden: - password Sekret ЗЕЛЁНАЯ
CASE z6-variable-ne-zavedena: rc=1 want=1 причина=sekrety-ne-zavedeny: ONLY_VARIABLE ЗЕЛЁНАЯ
CASE z7-secret-ne-zaveden: rc=1 want=1 причина=sekrety-ne-zavedeny: ONLY_SECRET ЗЕЛЁНАЯ
CASE z8-secret-gh-oshibka: rc=1 want=1 причина=gh-nedostupen ЗЕЛЁНАЯ
CASE z9-variable-gh-oshibka: rc=1 want=1 причина=gh-nedostupen ЗЕЛЁНАЯ
ИТОГ 122 (model): клеток 62, зелёных 62, красных 0
```

## Карта классов

К-01: блок — Н-39: новые пары стаба с ветвью в тексте.
К-02: чисто — вход: OWNER-BATCH-1118 №2 и батч №3 №3, OBJECT задан для узкого суда.
К-03: чисто — вход: дельта не меняет 149/198/199, объявление PILOT_DEMO_CODE отдельно; исключение владельца для станционных джоб не расширяет алфавит.
К-04: чисто — вход: contracts/122-ci-proekta.md:70–76, зоны architect и implementer, v+1 ограничен ci_preflight.
К-05: чисто — вход: приёмка contracts/122-ci-proekta.md:56–65, rc-команды.
К-06: н/п — средовая ветвь v1 не изменена дельтой, явный rc 2 в contracts/122-ci-proekta.md:43.
К-07: блок — честная обязательная модель не исполняет два инварианта Г2 при зелёном --model.
К-08: чисто — вход: три новых стаба изменяют существующие операции модели; прогоны 53/9, 60/2, 58/4.
К-09: блок — неподдержанное выражение с `}` внутри аргумента функции принято моделью.
К-10: блок — унаследованный путь побега в диагностике не равен исходному значению.
К-11: н/п — независимость свидетеля v1 без изменений с accept v4.
К-12: н/п — форматный оракул v1 без изменений с accept v4.
К-13: н/п — секреты v1 без изменения; отдельная правка 149 вне этого предмета.
К-14: чисто — вход: p9 --model зелёны 8 конформных/проверочных клеток, полный --model rc 0.
К-15: чисто — вход: --model 62/62/0; новые мутанты 53/9, 60/2, 58/4; --stabs отсутствует, rc 2.
К-16: чисто — вход: contracts/122-ci-proekta.md, модель угроз и НЕ ЗАЩИЩАЕТ; изоляция и контексты явно названы.
К-17: н/п — архитектурный бриф 188 и tooling/checks/cli.js в данном предмете отсутствуют.

Развилки: для baseline mobile.yml зелёный per-job предполёт на станции недостижим из-за шага изоляции раннера; по переданному слову владельца временное исключение относится только к станционным джобам PR экранов 149/147/148 до продуктовой разметки. Это не разрешает расширение алфавита заглушками.
