accept
OBJECT=5bf840b09e92480eab5cd0184afeaff42c4d97bd
СУД: repo=dev-harness; предмет=122; фаза=контракт v5, узкий повтор; роль=critic; вызов=2/3; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit122V5b; модель-факт=openai-codex/gpt-6.1-terra (allowed, models_actual --bind); SHA=5bf840b09e92480eab5cd0184afeaff42c4d97bd; предыдущий=FAIL Crit122V5, f4d581bdd1; исключение=слово владельца на v+1 и узкий вызов.

Область повтора — три блока Crit122V5 и зависимый регресс ремонта; неизменённые поверхности не исследовались заново. К-09: исходный вход воспроизводится клеткой p10-format-skobka-v-stroke, соседний вход с удвоенной одинарной кавычкой и `}}` в аргументе функции тоже отвергнут; конформные формы проходят p6/p9. К-10: p9 проверяет диагностику побега с уровня шага, defaults workflow и defaults джобы. К-01: новые пары стаб→ветвь удалены из прозы контракта, имена и rc-команды сохранены, связь остаётся в коде стабов. Разрешение владельца в коммите называет путь первым токеном и ограничено словом №2; зоны дельты не изменены.

## Карта классов

К-01: чисто — вход: contracts/122-ci-proekta.md:53,62,106–108 и шапки stabs; дельта Н-39.
К-02: н/п — без изменений с вызова Crit122V5: источники и область задания.
К-03: н/п — без изменений с вызова Crit122V5: чужие обязательства.
К-04: чисто — вход: contracts/122-ci-proekta.md:70–76, git diff f4d581bdd1..OBJECT; дельта в зоне architect.
К-05: чисто — вход: contracts/122-ci-proekta.md:56–65, rc-команды сохранены.
К-06: н/п — без изменений с вызова Crit122V5: средовая ветвь.
К-07: чисто — bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model, rc 0, 65/65/0.
К-08: чисто — вход: четыре мутанта через CI_PROEKTA_122_PREFLIGHT, rc 1; собственная замена d0 на d краснит четыре p9.
К-09: чисто — вход: p10-format-skobka-v-stroke и format('a''}}b', github.sha), rc 1 с vyrazhenie-ne-podderzhano.
К-10: чисто — вход: p9 шаг/defaults workflow/defaults джобы и замена d0 на d, четыре различающие красные клетки.
К-11: н/п — без изменений с вызова Crit122V5: свидетель.
К-12: н/п — без изменений с вызова Crit122V5: форматный оракул.
К-13: н/п — без изменений с вызова Crit122V5: секреты.
К-14: чисто — вход: p6 и p9 батареи --model, поддерживаемые формы зелёны; соседний формат с кавычками не расширяет алфавит.
К-15: чисто — вход: --model 65/65/0; мутанты 54/11, 61/4, 60/5 и 64/1.
К-16: чисто — вход: contracts/122-ci-proekta.md:103–115, граница алфавита и остаток прежние.
К-17: н/п — без изменений с вызова Crit122V5: архитектурный бриф 188 отсутствует.

## Соседняя проба и мутация

`probe.yml`: `env.VALUE: "${{ format('a''}}b', github.sha) }}"`, local job с `run: 'true'`.
```
$ bash fixtures/workshop_project/ci_proekta_122/model/ci_preflight.sh --repo /tmp/dev-harness-verify/Crit122V5b --workflow probe.yml
preflight ОТКАЗ: vyrazhenie-ne-podderzhano: ${{ format('a''}}b', github.sha) }}
rc=1
```
Мутация существующей операции диагностики: в одноразовой копии модели `d0` заменено на подставленное `d`; команда `CI_PROEKTA_122_PREFLIGHT=/tmp/dev-harness-verify/Crit122V5b/wd-mutant.sh bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p9` вернула rc 1. Сырой вывод:
```
CASE p9-wd-workspace: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-ws-v-run: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-ws-v-env: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-wd-defaults-workflow: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-wd-defaults-pereopredelenie: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-wd-dotdot-vne-kopii: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. КРАСНАЯ (нет причины)
    | preflight ОТКАЗ: working-directory-vne-kopii: /tmp/dev-harness-verify/ci122-pre-l7zgkssz/repo/..
CASE p9-wd-simlink-pobeg: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/vne-kopii-link КРАСНАЯ (нет причины)
    | preflight ОТКАЗ: working-directory-vne-kopii: /tmp/dev-harness-verify/ci122-pre-0lzpiuaf/repo/vne-kopii-link
CASE p9-wd-dotdot-vne-kopii-defaults-workflow: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. КРАСНАЯ (нет причины)
    | preflight ОТКАЗ: working-directory-vne-kopii: /tmp/dev-harness-verify/ci122-pre-e786m6dg/repo/..
CASE p9-wd-dotdot-vne-kopii-defaults-dzhoby: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. КРАСНАЯ (нет причины)
    | preflight ОТКАЗ: working-directory-vne-kopii: /tmp/dev-harness-verify/ci122-pre-x5w4rk9u/repo/..
CASE p9-forma-mobile: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
ИТОГ 122 (--cell p9): зелёных 6, красных 4
```

Развилка: зелёный per-job предполёт baseline mobile.yml на станции недостижим из-за среды раннера; по представленному слову владельца временное исключение относится только к станционным джобам PR экранов 149/147/148 до продуктовой разметки и не расширяет алфавит.

## Сырые результаты батареи

```
$ bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model
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
CASE p8-wd-absolyutnyj-r-bez-mutacii: rc=1 want=1 причина=working-directory-otsutstvuet: /tmp/dev-harness-verify/ci122/run-cryh/world-a221 ЗЕЛЁНАЯ
CASE p9-wd-workspace: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-ws-v-run: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-ws-v-env: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-wd-defaults-workflow: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-wd-defaults-pereopredelenie: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-wd-dotdot-vne-kopii: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. ЗЕЛЁНАЯ
CASE p9-wd-simlink-pobeg: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/vne-kopii-link ЗЕЛЁНАЯ
CASE p9-wd-dotdot-vne-kopii-defaults-workflow: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. ЗЕЛЁНАЯ
CASE p9-wd-dotdot-vne-kopii-defaults-dzhoby: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. ЗЕЛЁНАЯ
CASE p9-forma-mobile: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p10-vyrazhenie-v-run: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ github.run_id }} ЗЕЛЁНАЯ
CASE p10-vyrazhenie-v-env: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ github.sha }} ЗЕЛЁНАЯ
CASE p10-funkcija-tojson: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ toJSON(needs) }} ЗЕЛЁНАЯ
CASE p10-format-skobka-v-stroke: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ format('}', github.sha) }} ЗЕЛЁНАЯ
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
ИТОГ 122 (model): клеток 65, зелёных 65, красных 0
rc=0
```

```
$ CI_PROEKTA_122_PREFLIGHT=fixtures/workshop_project/ci_proekta_122/stabs/stab_preflight_bez_workspace.sh bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model
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
CASE p8-wd-absolyutnyj-r-bez-mutacii: rc=1 want=1 причина=working-directory-otsutstvuet: /tmp/dev-harness-verify/ci122/run-MvRJ/world-HaSX ЗЕЛЁНАЯ
CASE p9-wd-workspace: rc=1 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 КРАСНАЯ (rc 1 вместо 0; нет причины)
    | preflight ОТКАЗ: vyrazhenie-ne-podderzhano: ${{ github.workspace }}
CASE p9-ws-v-run: rc=1 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 КРАСНАЯ (rc 1 вместо 0; нет причины)
    | preflight ОТКАЗ: vyrazhenie-ne-podderzhano: ${{ github.workspace }}
CASE p9-ws-v-env: rc=1 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 КРАСНАЯ (rc 1 вместо 0; нет причины)
    | preflight ОТКАЗ: vyrazhenie-ne-podderzhano: ${{ github.workspace }}
CASE p9-wd-defaults-workflow: rc=1 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 КРАСНАЯ (rc 1 вместо 0; нет причины)
    | preflight ОТКАЗ: vyrazhenie-ne-podderzhano: ${{ github.workspace }}
CASE p9-wd-defaults-pereopredelenie: rc=1 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 КРАСНАЯ (rc 1 вместо 0; нет причины)
    | preflight ОТКАЗ: vyrazhenie-ne-podderzhano: ${{ github.workspace }}
CASE p9-wd-dotdot-vne-kopii: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. КРАСНАЯ (нет причины)
    | preflight ОТКАЗ: vyrazhenie-ne-podderzhano: ${{ github.workspace }}
CASE p9-wd-simlink-pobeg: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/vne-kopii-link КРАСНАЯ (нет причины)
    | preflight ОТКАЗ: vyrazhenie-ne-podderzhano: ${{ github.workspace }}
CASE p9-wd-dotdot-vne-kopii-defaults-workflow: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. КРАСНАЯ (нет причины)
    | preflight ОТКАЗ: vyrazhenie-ne-podderzhano: ${{ github.workspace }}
CASE p9-wd-dotdot-vne-kopii-defaults-dzhoby: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. КРАСНАЯ (нет причины)
    | preflight ОТКАЗ: vyrazhenie-ne-podderzhano: ${{ github.workspace }}
CASE p9-forma-mobile: rc=1 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 КРАСНАЯ (rc 1 вместо 0; нет причины)
    | preflight ОТКАЗ: vyrazhenie-ne-podderzhano: ${{ github.workspace }}
CASE p10-vyrazhenie-v-run: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ github.run_id }} ЗЕЛЁНАЯ
CASE p10-vyrazhenie-v-env: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ github.sha }} ЗЕЛЁНАЯ
CASE p10-funkcija-tojson: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ toJSON(needs) }} ЗЕЛЁНАЯ
CASE p10-format-skobka-v-stroke: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ format('}', github.sha) }} ЗЕЛЁНАЯ
CASE p10-otkaz-do-ispolnenija: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ matrix.x }} ЗЕЛЁНАЯ
CASE p10-uses-ne-suditsa: rc=1 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 КРАСНАЯ (rc 1 вместо 0; нет причины)
    | preflight ОТКАЗ: vyrazhenie-ne-podderzhano: ${{ github.workspace }}
CASE z1-predposylki-otsutstvuyut: rc=1 want=1 причина=predposylki-otsutstvuyut ЗЕЛЁНАЯ
CASE z2-sekrety-ne-zavedeny: rc=1 want=1 причина=sekrety-ne-zavedeny: PILOT_DEMO_CODE ЗЕЛЁНАЯ
CASE z3-gh-nedostupen: rc=1 want=1 причина=gh-nedostupen ЗЕЛЁНАЯ
CASE z4-predposylki-nevaliden: rc=1 want=1 причина=predposylki-nevaliden: - password Sekret ЗЕЛЁНАЯ
CASE z6-variable-ne-zavedena: rc=1 want=1 причина=sekrety-ne-zavedeny: ONLY_VARIABLE ЗЕЛЁНАЯ
CASE z7-secret-ne-zaveden: rc=1 want=1 причина=sekrety-ne-zavedeny: ONLY_SECRET ЗЕЛЁНАЯ
CASE z8-secret-gh-oshibka: rc=1 want=1 причина=gh-nedostupen ЗЕЛЁНАЯ
CASE z9-variable-gh-oshibka: rc=1 want=1 причина=gh-nedostupen ЗЕЛЁНАЯ
ИТОГ 122 (model): клеток 65, зелёных 54, красных 11
rc=1
```

```
$ CI_PROEKTA_122_PREFLIGHT=fixtures/workshop_project/ci_proekta_122/stabs/stab_preflight_ws_bez_granicy.sh bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model
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
CASE p8-wd-absolyutnyj-r-bez-mutacii: rc=1 want=1 причина=working-directory-otsutstvuet: /tmp/dev-harness-verify/ci122/run-Am9J/world-EZuy ЗЕЛЁНАЯ
CASE p9-wd-workspace: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-ws-v-run: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-ws-v-env: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-wd-defaults-workflow: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-wd-defaults-pereopredelenie: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-wd-dotdot-vne-kopii: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. КРАСНАЯ (нет причины)
    | preflight ОТКАЗ: working-directory-otsutstvuet: /tmp/dev-harness-verify/ci122-pre-60ib_2mc/repo/..
CASE p9-wd-simlink-pobeg: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/vne-kopii-link КРАСНАЯ (нет причины)
    | preflight ОТКАЗ: working-directory-otsutstvuet: /tmp/dev-harness-verify/ci122-pre-6ukrwxqa/repo/vne-kopii-link
CASE p9-wd-dotdot-vne-kopii-defaults-workflow: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. КРАСНАЯ (нет причины)
    | preflight ОТКАЗ: working-directory-otsutstvuet: /tmp/dev-harness-verify/ci122-pre-wq98r27o/repo/..
CASE p9-wd-dotdot-vne-kopii-defaults-dzhoby: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. КРАСНАЯ (нет причины)
    | preflight ОТКАЗ: working-directory-otsutstvuet: /tmp/dev-harness-verify/ci122-pre-cyswtj6v/repo/..
CASE p9-forma-mobile: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p10-vyrazhenie-v-run: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ github.run_id }} ЗЕЛЁНАЯ
CASE p10-vyrazhenie-v-env: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ github.sha }} ЗЕЛЁНАЯ
CASE p10-funkcija-tojson: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ toJSON(needs) }} ЗЕЛЁНАЯ
CASE p10-format-skobka-v-stroke: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ format('}', github.sha) }} ЗЕЛЁНАЯ
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
ИТОГ 122 (model): клеток 65, зелёных 61, красных 4
rc=1
```

```
$ CI_PROEKTA_122_PREFLIGHT=fixtures/workshop_project/ci_proekta_122/stabs/stab_preflight_bez_otkaza_vyrazhenij.sh bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model
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
CASE p8-wd-absolyutnyj-r-bez-mutacii: rc=1 want=1 причина=working-directory-otsutstvuet: /tmp/dev-harness-verify/ci122/run-rdkN/world-mVUN ЗЕЛЁНАЯ
CASE p9-wd-workspace: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-ws-v-run: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-ws-v-env: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-wd-defaults-workflow: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-wd-defaults-pereopredelenie: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-wd-dotdot-vne-kopii: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. ЗЕЛЁНАЯ
CASE p9-wd-simlink-pobeg: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/vne-kopii-link ЗЕЛЁНАЯ
CASE p9-wd-dotdot-vne-kopii-defaults-workflow: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. ЗЕЛЁНАЯ
CASE p9-wd-dotdot-vne-kopii-defaults-dzhoby: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. ЗЕЛЁНАЯ
CASE p9-forma-mobile: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p10-vyrazhenie-v-run: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ github.run_id }} КРАСНАЯ (нет причины)
    | preflight ОТКАЗ: shag-upal: verify/kontekst-v-run
CASE p10-vyrazhenie-v-env: rc=0 want=1 причина=vyrazhenie-ne-podderzhano: ${{ github.sha }} КРАСНАЯ (rc 0 вместо 1; нет причины)
    | CIPREFLIGHT_OK jobs=1 station=0
CASE p10-funkcija-tojson: rc=0 want=1 причина=vyrazhenie-ne-podderzhano: ${{ toJSON(needs) }} КРАСНАЯ (rc 0 вместо 1; нет причины)
    | CIPREFLIGHT_OK jobs=1 station=0
CASE p10-format-skobka-v-stroke: rc=0 want=1 причина=vyrazhenie-ne-podderzhano: ${{ format('}', github.sha) }} КРАСНАЯ (rc 0 вместо 1; нет причины)
    | CIPREFLIGHT_OK jobs=1 station=0
CASE p10-otkaz-do-ispolnenija: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ matrix.x }} КРАСНАЯ (нет причины)
    | preflight ОТКАЗ: shag-upal: verify/pervyj-padaet
CASE p10-uses-ne-suditsa: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE z1-predposylki-otsutstvuyut: rc=1 want=1 причина=predposylki-otsutstvuyut ЗЕЛЁНАЯ
CASE z2-sekrety-ne-zavedeny: rc=1 want=1 причина=sekrety-ne-zavedeny: PILOT_DEMO_CODE ЗЕЛЁНАЯ
CASE z3-gh-nedostupen: rc=1 want=1 причина=gh-nedostupen ЗЕЛЁНАЯ
CASE z4-predposylki-nevaliden: rc=1 want=1 причина=predposylki-nevaliden: - password Sekret ЗЕЛЁНАЯ
CASE z6-variable-ne-zavedena: rc=1 want=1 причина=sekrety-ne-zavedeny: ONLY_VARIABLE ЗЕЛЁНАЯ
CASE z7-secret-ne-zaveden: rc=1 want=1 причина=sekrety-ne-zavedeny: ONLY_SECRET ЗЕЛЁНАЯ
CASE z8-secret-gh-oshibka: rc=1 want=1 причина=gh-nedostupen ЗЕЛЁНАЯ
CASE z9-variable-gh-oshibka: rc=1 want=1 причина=gh-nedostupen ЗЕЛЁНАЯ
ИТОГ 122 (model): клеток 65, зелёных 60, красных 5
rc=1
```

```
$ CI_PROEKTA_122_PREFLIGHT=fixtures/workshop_project/ci_proekta_122/stabs/stab_preflight_kavychki_vyrazhenij.sh bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model
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
CASE p8-wd-absolyutnyj-r-bez-mutacii: rc=1 want=1 причина=working-directory-otsutstvuet: /tmp/dev-harness-verify/ci122/run-xwET/world-EhCR ЗЕЛЁНАЯ
CASE p9-wd-workspace: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-ws-v-run: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-ws-v-env: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-wd-defaults-workflow: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-wd-defaults-pereopredelenie: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p9-wd-dotdot-vne-kopii: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. ЗЕЛЁНАЯ
CASE p9-wd-simlink-pobeg: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/vne-kopii-link ЗЕЛЁНАЯ
CASE p9-wd-dotdot-vne-kopii-defaults-workflow: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. ЗЕЛЁНАЯ
CASE p9-wd-dotdot-vne-kopii-defaults-dzhoby: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. ЗЕЛЁНАЯ
CASE p9-forma-mobile: rc=0 want=0 причина=CIPREFLIGHT_OK jobs=1 station=0 ЗЕЛЁНАЯ
CASE p10-vyrazhenie-v-run: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ github.run_id }} ЗЕЛЁНАЯ
CASE p10-vyrazhenie-v-env: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ github.sha }} ЗЕЛЁНАЯ
CASE p10-funkcija-tojson: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ toJSON(needs) }} ЗЕЛЁНАЯ
CASE p10-format-skobka-v-stroke: rc=0 want=1 причина=vyrazhenie-ne-podderzhano: ${{ format('}', github.sha) }} КРАСНАЯ (rc 0 вместо 1; нет причины)
    | CIPREFLIGHT_OK jobs=1 station=0
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
ИТОГ 122 (model): клеток 65, зелёных 64, красных 1
rc=1
```
