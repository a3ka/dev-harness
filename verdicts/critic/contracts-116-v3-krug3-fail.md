FAIL
OBJECT=a30d709209f86f1a42bd2f780e6825858dad7d25

# Критик 116 v3 — круг 3/3, ДО заморозки

Предмет: закоммиченный `contracts/116-cmp-mob-005-mission.md` на OBJECT, скопированный из `/tmp/dev-harness-verify/Architect116v3/repo` в `/tmp/dev-harness-verify/Critic116sol3/repo` со своей `.git`; не ревью реализации. Основание: слово владельца 2026-10-24 23:30, Astra `/tmp/dev-harness-verify/astra-workflow/REPORT-116.md` §3 шаг 1, FAIL кругов 1–2. **Блокеров: 4.** Проверялись только предмет, критерий и границы исполнения. Замеры — на собственной копии, последовательно, без эмулятора; полный сырой stdout/stderr каждой команды и rc сохранён в `/tmp/dev-harness-verify/Critic116sol3/logs/{model,stabs,tablica,plain,pre_critic,precision,runner123,counts,mutants,proof,yaml,scope}.log`. Сокращения в таблицах ниже НЕ означают выдуманного прогона.

## Находки и точные обходы

БЛОКИРУЕТ contracts/116-cmp-mob-005-mission.md:25,37 — проверка каждого `takeScreenshot` ограничена семью именами `kadry.json`: `sud_potok` перечисляет ВСЕ имена для дублей, но требует собственный предшествующий assert ТОЛЬКО при переборе `snimki` манифеста. Дополнительное одиночное имя без своего селектора зелено. В собственной мутации `unlisted_screenshot_no_assert` proverka/statika/stand-in e2e/123 rc=0/0/0/0, 7×KADR 1.000; PyYAML подтверждает отдельный исполняемый шаг `takeScreenshot: mission-surprise` до `assertVisible mission_frame_f05_05`. Это противоречит «перед КАЖДЫМ», хотя семь обязательных имён сохранены.
ОБХОД: в реальном `mobile/.maestro/mission.yaml` перед честной парой F05.05 поставить `- takeScreenshot: mission-surprise` без какого-либо `assertVisible` своего селектора; сохранить остальные семь кадров, четыре запускаемых ребёнка и продукт, исполняющий штатный сценарий. Maestro создаёт дополнительный кадр без подтверждения, proverka/statika/Jest/сверка семи имён его не судят; зелёная названная приёмка не доказывает заявленный квантор. Реальное исполнение Maestro здесь не выдаётся за проведённый опыт: установлен структурный зелёный контрпример к предикату критерия.

БЛОКИРУЕТ contracts/116-cmp-mob-005-mission.md:25,37 — `shagi_flow` удаляет отступы строк YAML и ошибочно принимает строку внутри скалярного литерала `inputText: |` за реальный `assertVisible`. Мутация `assert_only_literal` удаляет настоящий assert F05.05 и помещает строку `    - assertVisible: {id: mission_frame_f05_05}` ВНУТРИ литерала; PyYAML распознаёт `inputText` со значением `'- assertVisible: {id: mission_frame_f05_05}\n'`, реальных assert F05.05 в корне **ноль**, `takeScreenshot: mission-f05-05` по-прежнему отдельная команда. proverka/statika/stand-in e2e/123 rc=0/0/0/0 и 7×KADR 1.000, хотя собственный assert перед кадром НЕ выполняется.
ОБХОД: в продуктовом `mission.yaml` заменить только пару `- assertVisible: {id: mission_frame_f05_05}` / `- takeScreenshot: mission-f05-05` на `- inputText: |` + отступлённый текст `    - assertVisible: {id: mission_frame_f05_05}` + прежний действительный `- takeScreenshot: mission-f05-05`. На экране с доступным полем Maestro вводит текст (не исполняет assert), затем снимает кадр без проверки селектора; продукт может уже иметь правильные пиксели до готовности testID. Пинованные Jest и 123 не проверяют эту временную причинность. Комментарий-обманка отдельно красная (`FLOW_BEZ_DOSTIZHENIJA`), но YAML-литерал — не комментарий.

БЛОКИРУЕТ contracts/116-cmp-mob-005-mission.md:25,37 — заявленная уникальность имён В РАСКРЫТОМ ИСПОЛНЯЕМОМ потоке не удержана, когда Maestro-`repeat` повторяет команду. `repeat_root_screenshot`: честная пара F05.05 заменена документированной Maestro-формой `- repeat: {times: 2, commands: [assertVisible F05.05, takeScreenshot mission-f05-05]}` в многострочном YAML. PyYAML видит `times: 2`, две реальные команды в теле; `shagi_flow` ложно видит одну текстовую команду `takeScreenshot`, потому что не раскрывает `repeat`, а Maestro исполнит два одноимённых снимка. proverka/statika/stand-in e2e/123 rc=0/0/0/0, семь 1.000; однострочные `runFlow` с `when` в двух испытанных формах, напротив, красны `RUNFLOW_BEZ_FAJLA, BEZPNG_BEZ_TESTID_V_POTOKE, BEZPNG_SCENARIJ_NE_ZAPUSCHEN`. Документация синтаксиса: https://docs.maestro.dev/reference/commands-available/repeat .
ОБХОД: поместить `assertVisible mission_frame_f05_05` + `takeScreenshot mission-f05-05` в `repeat: {times: 2, commands: ...}` вместо прежней пары в продукте; каждый проход создаёт снимок того же имени, конечный PNG семи заявленных кадров может совпасть с макетом, но «имена takeScreenshot уникальны» в исполняемом потоке ложно. Суд манифеста и таблица `--tablica` видят текстовую клетку, не multiplicity runtime. Это не заявление об испытанном живом эмуляторе.

БЛОКИРУЕТ contracts/116-cmp-mob-005-mission.md:10,25,37 — для V01 порядок предусловие→действие из собственной строки осей не обеспечен: `sud_bezpng` требует жест `tapOn composer`→`inputText` ГДЕ УГОДНО в ребёнке и `mission_send` только до итогового assert. `v01_send_before_input` (`tapOn mission_send` до `inputText`, свой assert offline остаётся после ввода) даёт proverka rc=0, хотя отправленное не обязано быть введённым в ЭТОМ сценарии черновиком. K8 `QUEUED_OFFLINE_DRAFT_KEPT` действительно вводит текст ПЕРЕД send, не измеряет порядок живого дочернего Maestro. Это новый конкретный обход из четырёх ранее зелёных наблюдений, не голословное расширение предмета.
ОБХОД: оставить в V01 дочернем flow `tapOn mission_composer_input` → `tapOn mission_send` → `inputText: 'Ich habe ein Auto gekauft.'` → `assertVisible mission_queued_offline`. При сохранённом с прошлого независимого сценария F05.07 черновике (его сохранение при недоставке — требование :10) действие очереди отправляет ПРЕЖНИЙ черновик, потом вводится НОВЫЙ; offline testID виден и живой Maestro может пройти, Jest K8 на изолированном свежем вводе зелён, но собственный ввод V01 НЕ был предпосылкой своей отправки. Батарея 80/80 на неизменном source.json не включает этот продуктовый вариант; адресная proverka ошибочно зелена.

АРБИТР: роль `arbiter` (`roles/arbiter.md`); обязательный после третьего круга по одному предмету и капа. Инженерный спор critic ↔ architect — должен ли Инв. 4 отвергать одиночный неманифестный снимок, текстовый псевдо-assert в YAML-литерале и динамический повтор имени, когда `--model/--stabs` и контроль продукта по семи PNG зелены; также должен ли предусловный ввод V01 стоять до действия. До решения арбитра — STOP; НЕ четвёртый круг критика и НЕ молчаливая заморозка. Это не `ESCALATE`: вопрос корректности предиката, а не выбора цены/риска владельцем.

СОВЕТ contracts/116-cmp-mob-005-mission.md:18,24 — bbox composer F05.03 по прежнему замеру не охватывает яркий CTA (x330–373, y709–752); удаление CTA в круге 1 краснило 123, поэтому обхода не предъявлено и вердикт этот совет не определяет. `maski_pt=[]`, порог 0.600 подтверждены собственным JSON-замером.

## Scope (1)–(4)

| Область | Итог | Доказательство / граница |
|---|---|---|
| (1) повтор блока и ≥8 новых независимых мутаций | Старый обход **закрыт СВОЕЙ причиной**: `old_duplicate_early` rc1 `FLOW_SNIMOK_DUBL,FLOW_ASSERT_POSLE_KADRA`; ≥14 новых вариантов в таблице; ТРИ новых зелёных обхода порядка/снимка, плюс V01 предусловие | `logs/mutants.log`, `logs/proof.log`, `logs/yaml.log`. `root_assert_child_shot` честный rc0: корневой свой assert раньше дочернего снимка; `shot_only_literal` зелён структурно, но живой e2e без семи кадров не доказан — отдельным блокером НЕ объявлен. |
| (2) только Astra, сохранность | ДА по заявленной области: 52 изменённых пути = контракт + `fixtures/workshop_project/mission_116/`, outsiders=[]; коммиты 53724ea7/e812c418/a30d7092 с дословной строкой `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:`; старые кейсы/stab имена removed=[]; прежний Инв.4 и порог не ослаблены ТЕКСТОМ, но критерий не исполняет его полностью | `logs/scope.log`; 132/123/frozen/116/2/продукт не изменены. Пин `povedenie.test.stand-in.tsx` = `dab2efebea58f15c92a76989436d4a23d97fc72d9238f9c7efa816606438dac9` (sha256sum); пины B02/B02t/B09 с фактическим read-only `Impl116/mob` равны (`logs/counts.log`). Новая уникальность — уточнение уже существующего «перед каждым», не новый экран. |
| (3) все собственные scoped замеры | ВЫПОЛНЕНО: `--model` rc0 80/80+7×KADR 1.000; `--stabs` rc0 KRASEN×73, непойманных 0; `--tablica` rc0 11 строк, 40=40; plain без 132 rc1 SHABLON_ABSENT KRASNO×80; pre_critic rc0; precision rc0; честный e2e stand-in rc0 и 123 rc0 7×1.000 MAKET_PODMENEN 0; независимые AST/JSON 13+40+27=80, зелёных 11, красных 69, 57 стабов/73 связи, биекция 40=40; `grep com.complior.demo` в mission_116 пуст | Полный сырой stdout/stderr+rc каждой команды `logs/*.log`; исключение — живой Maestro/emulator и product-CI НЕ запускались, на машине `command -v maestro` rc1. Структурный контрпример не назван «пройденным живым product-CI». |
| (4) bbox F05.03 | СОВЕТ, не блокер | `jq` F05.03: `porog=0.6 maski=[] elementy=wordmark,sostojanie,zagolovok,composer-s-tekstom,composer,navigacija`; 123 семь кадров 1.000, контрпример CTA из круга 1 красный. |

### Мутанты: каждый применён отдельно с восстановлением исходных YAML

| имя | реальный вывод proverka: rc, именованная причина |
|---|---|
| old_duplicate_early (круг 2: shot → свой assert → одноимённый shot) | 1 `FLOW_SNIMOK_DUBL,FLOW_ASSERT_POSLE_KADRA` |
| child_early_root_late | 1 `FLOW_SNIMOK_DUBL,FLOW_ASSERT_POSLE_KADRA` |
| own_assert_between_two | 1 `FLOW_SNIMOK_DUBL,FLOW_ASSERT_POSLE_KADRA` |
| foreign_assert_before_own | 1 `FLOW_ASSERT_POSLE_KADRA` |
| same_name_two_children | 1 `FLOW_SNIMOK_DUBL,FLOW_SNIMOK_DUBL` |
| root_assert_child_shot (честное межфайловое раскрытие) | 0 `none` — конформен |
| child_shot_root_assert_after | 1 `FLOW_ASSERT_POSLE_KADRA` |
| unlisted_screenshot_no_assert | **0 `none`, ОБХОД 1** |
| unlisted_duplicate | 1 `FLOW_SNIMOK_DUBL` |
| assert_only_comment | 1 `FLOW_BEZ_DOSTIZHENIJA` |
| assert_only_literal | **0 `none`, ОБХОД 2** |
| shot_only_literal | 0 `none`, но отсутствие реального кадра не проходит живую приёмку |
| when_runflow_false; when_inline_runflow_false | оба 1 `RUNFLOW_BEZ_FAJLA,BEZPNG_BEZ_TESTID_V_POTOKE,BEZPNG_SCENARIJ_NE_ZAPUSCHEN`; это не обход |
| repeat_root_screenshot | **0 `none`, ОБХОД 3** |
| v01_send_before_input | **0 `none`, ОБХОД 4** |
| draft_sent_before_observe; v02_no_negative_completed; pending_before_attach | все 0 `none`; независимый полный контрпример Jest+живого runtime этим прогоном НЕ предъявлен, отдельными блокерами не объявлены |

### Сырые контрольные строки (вывод не нормализован)

```text
$ bash fixtures/workshop_project/mission_116/red_mission_116.sh --model
rc=0
CASE chestnyj-ekran ok
CASE proiskhozdenie-dublj-rannij ok
CASE proiskhozdenie-dublj-chestnye ok
CASE proiskhozdenie-dublj-rannie ok
CASE proiskhozdenie-kadr-chuzhoj-assert ok
CASE proiskhozdenie-snimok-v-rebyonke ok
CASE proiskhozdenie-rebyonok-ranishe-asserta ok
CASE proiskhozdenie-assert-v-rebyonke ok
KADR	F05.01 dark	1.000	0.600	G	OK
KADR	F05.02 dark	1.000	0.600	G	OK
KADR	F05.03 dark	1.000	0.600	G	OK
KADR	F05.04 dark	1.000	0.600	G	OK
KADR	F05.05 dark	1.000	0.600	G	OK
KADR	F05.06 dark	1.000	0.600	G	OK
KADR	F05.V03 dark	1.000	0.600	G	OK
$ bash fixtures/workshop_project/mission_116/red_mission_116.sh --stabs
rc=0
STAB s68_kadr_do_asserta_propuskaet.py proiskhozdenie-assert-v-rebyonke KRASEN
STAB s70_dublj_snimka_propuskaet.py proiskhozdenie-dublj-rannij KRASEN
STAB s70_dublj_snimka_propuskaet.py proiskhozdenie-dublj-chestnye KRASEN
STAB s70_dublj_snimka_propuskaet.py proiskhozdenie-dublj-rannie KRASEN
STAB s71_parnost_vhozhdenij_propuskaet.py proiskhozdenie-dublj-rannij KRASEN
STAB s72_chuzhoj_assert_propuskaet.py proiskhozdenie-kadr-chuzhoj-assert KRASEN
STAB s73_raskrytie_potoka_propuskaet.py proiskhozdenie-snimok-v-rebyonke KRASEN
STAB s73_raskrytie_potoka_propuskaet.py proiskhozdenie-rebyonok-ranishe-asserta KRASEN
STAB s73_raskrytie_potoka_propuskaet.py proiskhozdenie-assert-v-rebyonke KRASEN
SVJAZI 73
$ bash fixtures/workshop_project/mission_116/red_mission_116.sh --tablica
rc=0
OSI	итого	строк=11 клеток=40 клеток-потока=40
$ bash fixtures/workshop_project/mission_116/red_mission_116.sh # дерево without-subject, scripts/ekran_shablon.py отсутствует
rc=1
SHABLON_ABSENT
CASE chestnyj-ekran KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-assert-v-rebyonke KRASNO (SHABLON_ABSENT)
$ bash scripts/pre_critic.sh contracts/116-cmp-mob-005-mission.md
rc=0
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
КРИТИК: дверь зелёная
$ bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic116sol3/repo contracts/116-cmp-mob-005-mission.md
rc=0
OK
$ python3 /tmp/dev-harness-verify/Critic116sol3/runner123.py
rc=0
e2e rc=0 stdout='' stderr=''
runner123 rc=0 MAKET_PODMENEN=0 KADR=7
KADR	F05.01 dark	1.000	0.600	G	OK
KADR	F05.02 dark	1.000	0.600	G	OK
KADR	F05.03 dark	1.000	0.600	G	OK
KADR	F05.04 dark	1.000	0.600	G	OK
KADR	F05.05 dark	1.000	0.600	G	OK
KADR	F05.06 dark	1.000	0.600	G	OK
KADR	F05.V03 dark	1.000	0.600	G	OK
```

Граница исполнения: `contracts/116-cmp-mob-005-mission.md:40-53` перечисляет `ЗОНА architect/critic/adversary/reviewer/implementer` и перекрытия. Собственные изменения ограничены `/tmp/dev-harness-verify/Critic116sol3/`; исходный клон architect, продуктовый клон и основной репозиторий — **только чтение**. По явному условию этого поручения вердикт предоставлен здесь для переноса ведущим, не закоммичен в чужой репозиторий и не объявлен замороженным.
