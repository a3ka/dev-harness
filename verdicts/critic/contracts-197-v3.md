accept

OBJECT=088cc14abf1a3d9b9af033742a921dfcb307ca3a
СУД: repo=dev-harness; предмет=197; фаза=контракт v4-кандидат до заморозки, узкий исправительный вызов; роль=critic; вызов=1/2 по счёту консультативных санкций ADR 2026-11-17, уточнённому ADR 2026-11-18/#1100 (до вызова использовано 0, после использования останется 1; второй вызов после accept Crit197V9; общий исторический счёт не сбрасывается); модель-план=openai-codex/gpt-6.1-terra (config/agent_models.json: critic → apex-sol → @gpt-terra, объявленный autoFallback @glm); сессия=Crit197V11; модель-факт=openai-codex/gpt-6.1-terra (models_actual --bind: allowed); OBJECT=088cc14abf1a3d9b9af033742a921dfcb307ca3a; SHA=088cc14abf1a3d9b9af033742a921dfcb307ca3a; предыдущий=verdicts/critic/contracts-197-v3.md, FAIL Crit197V10 в 64c00666bc5f87b818fbac7a26dd5bd771122799, OBJECT 95235b366a5d5d62807be58a37709d1bc7a0bc3d; исключение=отдельная одноразовая санкция консультанта сессии Cons197Sign, openai-codex/gpt-6.1-sol, /tmp/dev-harness-verify/Cons197Sign/otvet.md, по docs/owner/adr/2026-11-17-uzkij-kritik-konsultant-sessii.md п.1 и docs/owner/adr/2026-11-18-schet-uzkih-vyzovov.md пп.1–5; основание=предмет нового порядка (id/CONTRACT/197, 2026-11-16), конкретный FAIL К-06 и зависимый К-09, позиция architect и закрытие канон/инструмент в fixtures/workshop_project/mob_ci_artifacts_local_197/sdacha_197.md; объём=только закрытие приоритета проверки снимка/пина до SKRIPT_NET/SUBJECT_ABSENT во всех автономных режимах и дочерних запусках, шесть адресных сочетаний, соседняя мутация и зависимый регресс узкой дельты 64c00666bc..088cc14abf; запреты=новый полный поиск, пересуд неизменённых поверхностей без связи с дельтой/новым свидетельством риска, смена риска, ослабление обязательств, перенос на другой OBJECT и автоматический следующий вызов; независимость=санкционировал консультант Cons197Sign (модель сессии openai-codex/gpt-6.1-sol, не автор предметного ремонта и не его арбитр), арбитражи 197 подписаны openai-codex/gpt-6-astra, критик назначается штатной моделью и не судит собственную работу; перед запуском сверить фактических авторов, модели и известные fallback, после старта дописать сессия=<фактический id> и модель-факт=<полный provider/model> по трассе, повторить сверку после fallback; без установленной независимости и модельной привязки вердикт не материализовать. Санкция не заменяет accept, штатные предсудебные двери, машинный кап и основания freeze.

## Область и результат

Проверена только названная дельта К-06 и связанная К-09, не весь контракт заново. К-06 закрыт шире примера: `probe.py:50-62,917-930,1091-1107` загружает и проверяет снимок до разбора режима и субъекта; `:741-750,940-941` переносит проверенные байты в песочницу s01, не перечитывая снимок и без fallback. Все дочерние процессы запускают собственную раннюю проверку. Шесть адресных сочетаний привязаны кодом к областям и причинам в `source.json:185-226`, не прозой. Суд собственной работы исключён: автор OBJECT architect, фактическая модель по `bash scripts/models_actual.sh --tsv --bind --session Crit197V11 | cut -f1-3` — дважды `critic openai-codex/gpt-6.1-terra allowed` (rc 0).

## Проверки

Клон суда `/tmp/dev-harness-verify/Crit197V11/repo`, проверки и мутации в `/tmp/dev-harness-verify/Crit197V11/check` и одноразовых каталогах внутри Crit197V11. Полный сырой журнал прогона `checks.log` — `/tmp/dev-harness-verify/Crit197V11/checks.log`; ниже приведены помеченные фрагменты без утверждения, что это полный вывод длинных прогонов. Команды выполнялись из корня проверочного клона. Результат `bash scripts/check_sdacha.sh . contracts/197-mob-ci-artefakty-lokalno.md --run`, rc 0, полный вывод:

```text
СДАЧА: лист зелёный (двери=4 карта=17/17 дельта=2)
```

`bash scripts/pre_critic.sh contracts/197-mob-ci-artefakty-lokalno.md`, rc 0, полный вывод:

```text
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
  ok   гейт трека: 
  ok   модель угроз красна
  ok   потолки красны
  ok   проводка красна
  ok   сдаточный лист красен
КРИТИК: дверь зелёная
```

`bash scripts/check_spec_ready.sh . contracts/197-mob-ci-artefakty-lokalno.md`, rc 0, полный вывод: `OK`.

`bash scripts/run_ci_lane.sh check:mob-ci-artifacts-local-197-family-selftest`, rc 0; фрагмент сырого вывода:

```text
CASE s01-styk-sbor-agregat ok
клеток 29, зелёных 29, красных 0
STAB stab_s01_bez_pary KRASEN: s01-styk-sbor-agregat: rc=1: STYK_AGREGATA_OTKAZ
STAB stab_s01_snimok_net_bez_skripta KRASEN: s01-styk-sbor-agregat: rc=2: ORACLE_TAMPERED: агрегат 143: снимок отсутствует:
STAB stab_s01_snimok_net_bez_subiekta KRASEN: s01-styk-sbor-agregat: rc=2: ORACLE_TAMPERED: агрегат 143: снимок отсутствует:
STAB stab_s01_snimok_pin_bez_skripta KRASEN: s01-styk-sbor-agregat: rc=2: ORACLE_TAMPERED: агрегат 143: sha256
STAB stab_s01_snimok_pin_bez_subiekta KRASEN: s01-styk-sbor-agregat: rc=2: ORACLE_TAMPERED: агрегат 143: sha256
STAB stab_s01_snimok_porcha_bez_skripta KRASEN: s01-styk-sbor-agregat: rc=2: ORACLE_TAMPERED: агрегат 143: sha256
STAB stab_s01_snimok_porcha_bez_subiekta KRASEN: s01-styk-sbor-agregat: rc=2: ORACLE_TAMPERED: агрегат 143: sha256
стабов 38, непойманных 0
```

Полный вывод содержит отдельные строки `REZHIM` для каждого из восьми oracle-стабов и четырёх режимов, включая дочерний `--repo`. `bash fixtures/workshop_project/mob_ci_artifacts_local_197/red_mob_ci_artifacts_local_197.sh --model`, rc 0, фрагмент: `CASE s01-styk-sbor-agregat ok` и `клеток 29, зелёных 29, красных 0`.

`bash fixtures/workshop_project/mob_ci_artifacts_local_197/sverka_inventarja_143.sh до`, rc 0, полный вывод:

```text
БАТАРЕЯ_143: режим до; commit 9d3ad2bea4f1f15be15a9d975966bb20451a9a54; tree 89ccddf8281b15842eda6aa1a316bdde579845ee
АГРЕГАТ_143_СНИМОК_СОВПАЛ: e486e353f319ed2c0a65fc1092a0f16f8c9d8314bab4aed6e1d3619630d8fec6
ПСЕВДО-ПРОДУКТ: fda1fc871960b8061d8e6f6d12f2cc38f5834cee + модель 197 → /tmp/sverka143-197-4qp17fyn/produkt
БАТАРЕЯ_197_ЗЕЛЕНА: клеток 29, зелёных 29, красных 0
КРАСНАЯ_143: a17-digest-do-ustanovki: e2e-splash: РЕНДЕР_ВНЕ_АЛФАВИТА: needs.build-apk.outputs.run_attempt
КРАСНАЯ_143: evidence: CHILD_DOWNLOAD_ABSENT_android-e2e
КРАСНАЯ_143: legacy: LEGACY_JOB_CHANGED
КРАСНАЯ_143: workflow-build-apk-outputs: WORKFLOW_CONTROL_workflow-build-apk-outputs
КРАСНАЯ_143: workflow-build-apk-run-step-7: WORKFLOW_CONTROL_workflow-build-apk-run-step-7
КРАСНАЯ_143: y19-outputs-provodka: outputs build-apk: ['apk_sha256', 'artifact_name', 'run_attempt', 'run_id']
ИНВЕНТАРЬ_143_СОВПАЛ: красных 6 из 6 пина, поимённо
```

`bash fixtures/workshop_project/mob_ci_artifacts_local_197/sverka_inventarja_143.sh после --ref 0d391630a037d3c3e71d0795866dddba55f1fc57`, rc 0, полный вывод:

```text
БАТАРЕЯ_143: режим после; commit 0d391630a037d3c3e71d0795866dddba55f1fc57; tree a99b4b17d2e93fab6ee70a76f04fd353aee09be6
АГРЕГАТ_143_СНИМОК_СОВПАЛ: e486e353f319ed2c0a65fc1092a0f16f8c9d8314bab4aed6e1d3619630d8fec6
ПСЕВДО-ПРОДУКТ: fda1fc871960b8061d8e6f6d12f2cc38f5834cee + модель 197 → /tmp/sverka143-197-24gacfx0/produkt
БАТАРЕЯ_197_ЗЕЛЕНА: клеток 29, зелёных 29, красных 0
ИНВЕНТАРЬ_143_НОЛЬ_КРАСНЫХ: ноль красных; батарея 143 приняла lane-форму
```

`bash fixtures/workshop_project/mob_ci_artifacts_local_197/proverka_sverki_143.sh --ref 0d391630a037d3c3e71d0795866dddba55f1fc57`, rc 0; фрагмент сырого вывода:

```text
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

`git diff 64c00666bc 088cc14abf -- fixtures/workshop_project/mob_ci_artifacts_local_197/oracle143 fixtures/workshop_project/mob_ci_artifacts_local_197/sverka_inventarja_143.sh fixtures/workshop_project/mob_ci_artifacts_local_197/proverka_sverki_143.sh` rc 0, пусто. `git -C /home/harness/projects/Complior-mob show fda1fc871960b8061d8e6f6d12f2cc38f5834cee:mobile/scripts/ci-aggregate.cjs | sha256sum` и `sha256sum fixtures/workshop_project/mob_ci_artifacts_local_197/oracle143/ci-aggregate.cjs`, rc 0; обе суммы `e486e353f319ed2c0a65fc1092a0f16f8c9d8314bab4aed6e1d3619630d8fec6`. Пин источника и шесть имён также сохранены в дельте source.json.

## Соседние проверки

`python3 /tmp/dev-harness-verify/Crit197V11/neighbor.py`, rc 0: в копии семьи путь снимка заменён каталогом, у отдельного субъекта удалён workflow. Сырой вывод четырёх вызовов (фрагмент; полный — в журнале):

```text
NEIGHBOR directory snapshot / missing workflow []: rc=2; stdout=''; stderr='ORACLE_TAMPERED: агрегат 143: снимок отсутствует: /tmp/dev-harness-verify/Crit197V11/tmpu6d6gk07/family/oracle143/ci-aggregate.cjs'
NEIGHBOR directory snapshot / missing workflow ['--model']: rc=2; stdout=''; stderr='ORACLE_TAMPERED: агрегат 143: снимок отсутствует: /tmp/dev-harness-verify/Crit197V11/tmpu6d6gk07/family/oracle143/ci-aggregate.cjs'
NEIGHBOR directory snapshot / missing workflow ['--stabs']: rc=2; stdout=''; stderr='ORACLE_TAMPERED: агрегат 143: снимок отсутствует: /tmp/dev-harness-verify/Crit197V11/tmpu6d6gk07/family/oracle143/ci-aggregate.cjs'
NEIGHBOR directory snapshot / missing workflow ['--repo', '/tmp/dev-harness-verify/Crit197V11/tmpu6d6gk07/subject']: rc=2; stdout=''; stderr='ORACLE_TAMPERED: агрегат 143: снимок отсутствует: /tmp/dev-harness-verify/Crit197V11/tmpu6d6gk07/family/oracle143/ci-aggregate.cjs'
CONTROL intact snapshot / missing workflow: rc=1; first='SUBJECT_ABSENT: .github/workflows/mobile.yml не читается'
CASE s01-styk-sbor-agregat ok
клеток 29, зелёных 29, красных 0
CONTROL cached verified bytes after snapshot tampering: rc=0
```

В последнем контроле снимок испорчен после `zaghruzit_orakul()`, затем честный `sudit(MODEL, oracle)` остаётся зелёным, включая s01: использованы сохранённые проверенные байты. `python3 /tmp/dev-harness-verify/Crit197V11/attack_pin.py` удаляет существующее сравнение `if fakt != opis['sha256']` и его отказ в отдельной копии, запускает `--stabs`: оболочка проверки rc 0, атакованная батарея rc 1; фрагмент сырого вывода:

```text
CASE s01-styk-sbor-agregat ok
клеток 29, зелёных 29, красных 0
STAB stab_s01_snimok_isporchen PROPUSHCHEN: режим=[]; rc=1; искали rc=2 ORACLE_TAMPERED: агрегат 143: sha256
SUBJECT_ABSENT: предмет 197 реализуется в продукте Complior-mob
```

`python3 /tmp/dev-harness-verify/Crit197V11/control_missing_script.py` (целый оракул, у отдельной копии субъекта удалён скрипт): оболочка rc 0, предметный запуск rc 1; фрагмент сырого вывода:

```text
CASE e01-skript-pin KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE s01-styk-sbor-agregat KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
клеток 29, зелёных 16, красных 13
RC=1
```

## Карта классов

К-01: чисто — `bash scripts/check_sdacha.sh . contracts/197-mob-ci-artefakty-lokalno.md --run` rc 0; двери rc 0.
К-02: н/п — без изменений с Crit197V10; вход: задание узкого суда и дельта.
К-03: чисто — станционные до/после и 12 клеток сверки rc 0, исходный пин снимка совпал.
К-04: н/п — без изменений с Crit197V10; вход: diff 64c00666bc..088cc14abf в пределах контракта и семьи.
К-05: чисто — вход: contracts/197-mob-ci-artefakty-lokalno.md:69-79, затронутое правило содержит команду и rc.
К-06: чисто — вход: ранняя проверка probe.py:50-62,917-930 и соседний `neighbor.py` rc 0; отсутствующие субъект и скрипт с исправным оракулом остаются rc 1.
К-07: чисто — `--model` rc 0, s01 29/29; станционные проверки rc 0.
К-08: чисто — lane rc 0, 38/0; удаление сравнения пина поймано rc 1 батареи.
К-09: чисто — lane rc 0: восемь oracle-стабов по четырём режимам, включая дочерний `--repo`.
К-10: чисто — вход: код привязок source.json и фактические именованные rc в lane; s01 исполнил оригинал.
К-11: чисто — вход: независимый пин, проверенные байты в памяти; `neighbor.py` контроль после изменения снимка rc 0.
К-12: чисто — вход: `git show` оригинала и sha256 снимка совпали; s01 запускает node с этими байтами.
К-13: н/п — секреты вне дельты, без изменений с Crit197V10.
К-14: чисто — `--model` rc 0 и честный контроль кешированных байтов в `neighbor.py` rc 0.
К-15: чисто — lane 38/0, model 29/29, станция 6/6 и 12/12; пины и имена не изменены.
К-16: н/п — класс риска и граница без изменений с Crit197V10; вход: узкий diff.
К-17: н/п — архитектурная модель 188 вне дельты, без изменений с Crit197V10.

## Развилки

Принят только указанный OBJECT. После фактического freeze 143 повторить `после --ref <фактический frozen>` и записать ref/commit/tree/rc в карточке ленда; проверка выбранного кандидата это не заменяет. Санкция не назначает следующий вызов и не даёт автоматический freeze.
