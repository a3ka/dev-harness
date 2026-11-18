accept

OBJECT=35bb27a4369c2a1845af70e34f6056f02b4f852d
СУД: repo=dev-harness; предмет=197; фаза=контракт v3 до заморозки; роль=critic; вызов=один дополнительный узкий по слову владельца 2026-11-18 ~21:09 UTC, прежний счёт сохраняется; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit197V9; модель-факт=openai-codex/gpt-6.1-terra (models_actual --bind: allowed); SHA=35bb27a4369c2a1845af70e34f6056f02b4f852d; предыдущий=Crit197V8 FAIL, OBJECT 0abf3c086791e97fcfa72af3ac97257c04434edc; исключение=слово владельца 21:09, один узкий вызов К-02 и зависимый регресс.

## Решение

К-02 Crit197V8 закрыт. Слово владельца в state-HANDOFF :12 разрешает commit `9d3ad2bea4f1f15be15a9d975966bb20451a9a54` и tree `89ccddf8281b15842eda6aa1a316bdde579845ee` вместо frozen/143/4, без ослабления шести красных. `contracts/197-mob-ci-artefakty-lokalno.md:26,79`, `fixtures/workshop_project/mob_ci_artifacts_local_197/sdacha_197.md:68-70` и `source.json` называют те же пины и шесть поимённых красных; `git rev-parse '9d3ad2bea4f1f15be15a9d975966bb20451a9a54:fixtures/workshop_project/mob_ci_143'` rc 0: `89ccddf8281b15842eda6aa1a316bdde579845ee`. В сдаточном листе сохранено историческое основание fix-v6b, новое слово зафиксировано в самом контракте. Дельта от f25c238613 — одна строка контракта; пины и лист не менялись.

СУД ограничен К-02 и зависимым регрессом. По поправке задания рассмотрен потомок, а не SHA 0abf3c0867, указанный в слове: предвызовная запись state-HANDOFF :7 фиксирует отказ двери `OBJECT_UZHE_SUZHEN`, новый SHA и передачу расхождения консультанту. Новый полный суд не проводился, новый автоматический вызов этим вердиктом не разрешается.

СОВЕТ contracts/197-mob-ci-artefakty-lokalno.md:82 — `check_provodka` в предъявленном дереве уже возвращает rc 0, а не названный до freeze rc 1; строка батареи присутствует в `registry/ci-steps.tsv:315`. Это прежнее состояние вне дельты К-02; отдельно согласовать формулировку с фактической проводкой.

## Проверки

Клон `/tmp/dev-harness-verify/Crit197V9/repo`, OBJECT как выше; проверка — отдельный `git clone --no-hardlinks` и `checkout --detach` этого OBJECT в `/tmp/dev-harness-verify/Crit197V9/measurement`, обе команды rc 0, `git fetch --tags origin` в исходном клоне rc 0. Все следующие команды исполнены из measurement:

- `bash scripts/pre_critic.sh --repo . contracts/197-mob-ci-artefakty-lokalno.md` rc 0: `КРИТИК: дверь зелёная`.
- `bash scripts/check_sdacha.sh . contracts/197-mob-ci-artefakty-lokalno.md --run` rc 0: `СДАЧА: лист зелёный (двери=4 карта=17/17 дельта=2)`.
- `bash fixtures/workshop_project/mob_ci_artifacts_local_197/red_mob_ci_artifacts_local_197.sh --repo .` rc 1: `SUBJECT_ABSENT`, 29 клеток, 0 зелёных, 29 красных — ожидаемая проверка харнесса без продукта.
- Та же батарея `--model` rc 0: 29 клеток, 29 зелёных, 0 красных; `--stabs` rc 0: 29/29, стабов 30, непойманных 0.
- `bash scripts/check_provodka.sh . contracts/197-mob-ci-artefakty-lokalno.md` rc 0, вывода нет; расхождение с прежней формулировкой названо советом.

`bash fixtures/workshop_project/mob_ci_artifacts_local_197/proverka_sverki_143.sh --ref 0d391630a037d3c3e71d0795866dddba55f1fc57` rc 0, сырой вывод обоих режимов и отрицательных контролей:

```text
КЛЕТКА_СВЕРКИ do-bez-sosednej-batarei ЗЕЛЕНА: rc=0; ИНВЕНТАРЬ_143_СОВПАЛ: красных 6 из 6
БАТАРЕЯ_143: режим до; commit 9d3ad2bea4f1f15be15a9d975966bb20451a9a54; tree 89ccddf8281b15842eda6aa1a316bdde579845ee
ПСЕВДО-ПРОДУКТ: fda1fc871960b8061d8e6f6d12f2cc38f5834cee + модель 197 → /tmp/sverka143-197-94j0m6vi/produkt
БАТАРЕЯ_197_ЗЕЛЕНА: клеток 29, зелёных 29, красных 0
КРАСНАЯ_143: a17-digest-do-ustanovki: e2e-splash: РЕНДЕР_ВНЕ_АЛФАВИТА: needs.build-apk.outputs.run_attempt
КРАСНАЯ_143: evidence: CHILD_DOWNLOAD_ABSENT_android-e2e
КРАСНАЯ_143: legacy: LEGACY_JOB_CHANGED
КРАСНАЯ_143: workflow-build-apk-outputs: WORKFLOW_CONTROL_workflow-build-apk-outputs
КРАСНАЯ_143: workflow-build-apk-run-step-7: WORKFLOW_CONTROL_workflow-build-apk-run-step-7
КРАСНАЯ_143: y19-outputs-provodka: outputs build-apk: ['apk_sha256', 'artifact_name', 'run_attempt', 'run_id']
ИНВЕНТАРЬ_143_СОВПАЛ: красных 6 из 6 пина, поимённо
КЛЕТКА_СВЕРКИ posle-ref ЗЕЛЕНА: rc=0; ИНВЕНТАРЬ_143_НОЛЬ_КРАСНЫХ: ноль красных
КЛЕТКА_СВЕРКИ posle-katalog-ekvivalent ЗЕЛЕНА: rc=0; ИНВЕНТАРЬ_143_НОЛЬ_КРАСНЫХ: ноль красных
КЛЕТКА_СВЕРКИ posle-staraja-versija ЗЕЛЕНА: rc=1; БАТАРЕЯ_143_ОТКАЗ: rc=1, ожидался 0
КЛЕТКА_СВЕРКИ posle-bez-istochnika ЗЕЛЕНА: rc=2; REZHIM_143
КЛЕТКА_СВЕРКИ posle-net-ref ЗЕЛЕНА: rc=2; BATAREJA_143_COMMIT_NET
КЛЕТКА_СВЕРКИ do-net-commita ЗЕЛЕНА: rc=2; BATAREJA_143_COMMIT_NET
КЛЕТКА_СВЕРКИ do-tree-rashozhdenie ЗЕЛЕНА: rc=2; BATAREJA_143_TREE_RASHOZHDENIE
КЛЕТКА_СВЕРКИ do-drugaja-versija ЗЕЛЕНА: rc=2; BATAREJA_143_TREE_RASHOZHDENIE
КЛЕТКА_СВЕРКИ posle-pustoj-vyvod ЗЕЛЕНА: rc=1; БАТАРЕЯ_143_ОТКАЗ
КЛЕТКА_СВЕРКИ posle-oshibka-sredy ЗЕЛЕНА: rc=1; БАТАРЕЯ_143_ОТКАЗ
КЛЕТКА_СВЕРКИ posle-lishnjaja-krasnaja ЗЕЛЕНА: rc=1; ИНВЕНТАРЬ_143_РАСХОДИТСЯ
клеток сверки 12, зелёных 12, красных 0
```

## Карта классов

К-01: чисто — вход: Crit197V8 К-01; `check_sdacha --run` rc 0.
К-02: чисто — вход: слово владельца state-HANDOFF :12, контракт :26, пины source.json, `proverka_sverki_143.sh` rc 0 и git tree выше.
К-03: чисто — вход: Crit197V8 К-03; приёмка 143 v+1 и шестиклеточное обязательство сохранены.
К-04: чисто — вход: Crit197V8 К-04, изменение контракта в зоне architect.
К-05: чисто — вход: Crit197V8 К-05, п.8 контракта не менялся.
К-06: чисто — вход: Crit197V8 К-06; проверка шва rc 0, отрицательные клетки rc 2 выше.
К-07: чисто — вход: Crit197V8 К-07; обе честные формы после и до прошли проверку шва.
К-08: чисто — вход: Crit197V8 К-08; `--stabs` rc 0, 30 поймано.
К-09: чисто — вход: Crit197V8 К-09; оба источника после прошли проверку шва.
К-10: чисто — вход: Crit197V8 К-10; шесть имён выше совпали с оракулом source.json.
К-11: чисто — вход: Crit197V8 К-11; независимое извлечение по git commit/tree в проверке шва.
К-12: чисто — вход: Crit197V8 К-12; проверка шва использует runner 143 из git archive.
К-13: н/п — вход: Crit197V8 К-13, секреты вне адресной дельты.
К-14: чисто — вход: Crit197V8 К-14; ref и эквивалентный каталог после зелёны.
К-15: чисто — вход: Crit197V8 К-15; `--model` 29/29, `--stabs` 30/30, проверка шва 12/12.
К-16: чисто — вход: Crit197V8 К-16, риск и модель угроз не менялись.
К-17: н/п — вход: Crit197V8 К-17, архитектурная модель 188 не менялась.

## Развилки

Расхождение указанного в слове владельца OBJECT и потомка, предъявленного из-за отказа двери, уже передано консультанту согласно state-HANDOFF :7; этот вердикт не подменяет решение о маршруте. После freeze 143 требуется повторить режим после на фактическом новом frozen с записью ref/commit/tree и rc в карточке ленда, как требует контракт.
