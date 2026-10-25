FAIL
OBJECT=708e1773c1a5769e722cfb64ebc97ff33f58d0c3

# Контракт 116 v3d — единственный scoped-круг после арбитража

Предмет: коммит OBJECT на `wip/116/architect-v3` (закоммичен); сверялся на отдельной копии `/tmp/dev-harness-verify/Critic116sol4/repo`. Граница: только закрытый список G1/F1/F3 `verdicts/arbitration/contracts-116-v3-arbitraz.md` §2, сохранение области и совместимость формы реального продуктового флоу. Итог: **2 блокирующие находки**, один корень — комментарий, допустимый G1, ошибочно читается как исполняемая команда F1/F3. Десять новых отрицательных мутантов внутри класса красны, но дополнительный одиннадцатый (плюс варианты) показал зелёный обход. Это не требование нового класса Maestro: строка остаётся в заявленном белом списке G1.

БЛОКИРУЕТ contracts/116-cmp-mob-005-mission.md:25 — G1 разрешает `[ # …]`, но F1 принимает `assertVisible` ИЗ комментария обычной команды как собственное исполненное подтверждение кадра. Источник дефекта `fixtures/workshop_project/mission_116/teksty/proverka_text.py:289-318`: `if 'assertVisible' in s` + `id_iz(s)` по полной строке, не по исполняемому аргументу. Параметры судьи и имя кадра остаются честными; дефект находится внутри закрытой грамматики и квантора «каждое вхождение».
ОБХОД: в честном `mobile/.maestro/mission.yaml` заменить `- assertVisible: {id: mission_frame_f05_05}` непосредственно перед `- takeScreenshot: mission-f05-05` на `- hideKeyboard # assertVisible: {id: mission_frame_f05_05}`. Белый список принимает строку; замороженная `proverka_proiskhozdenija.py --pack … --repo …` возвращает **rc 0, причин нет**, хотя PyYAML распознаёт **0 исполняемых assertVisible** собственного селектора F05.05. Тем самым критерий «КАЖДОЕ вхождение после своего assertVisible» выполнен кодом возврата, а предмет не выполнен. Вариант `- inputText: 'x' # assertVisible: {id: mission_frame_f05_05}` также rc 0. Сырой замер: `comment_assert_on_hidekeyboard rc= 0 reasons= []`; `comment_assert_on_input rc= 0 reasons= []`; `f1 YAML executable assertVisible mission_frame_f05_05 = 0`. Воспроизводитель: `/tmp/dev-harness-verify/Critic116sol4/comment_spoof.py`; независимая YAML-семантика: `yaml_semantics.py`.

БЛОКИРУЕТ contracts/116-cmp-mob-005-mission.md:25 — F3 принимает негатив V02 и положительное наблюдение V01 из комментария к допустимой команде. Источник `fixtures/workshop_project/mission_116/teksty/proverka_text.py:530-583`: условие `'assertNotVisible' in s` / `'assertVisible' in s` вместе с `id_iz(s)` не отделяет комментарий от действия. Отрицательная ось V02 объявлена в критерии контракта: contracts/116-cmp-mob-005-mission.md:38.
ОБХОД: в честном `mission-state-v02.yaml` заменить `- assertNotVisible: {id: mission_response_completed}` на `- hideKeyboard # assertNotVisible: {id: mission_response_completed}` после положительного наблюдения. Получается **rc 0, причин нет**, но YAML содержит **0 исполняемых assertNotVisible** нужного ID: критерий V02 зелёный без требуемого негатива. Отдельная форма того же корня: в `mission-state-v01.yaml` заменить положительный `assertVisible mission_queued_offline` на `- hideKeyboard # assertVisible: {id: mission_queued_offline}` — rc 0, состояние не наблюдается. Сырой замер: `v02_negative_in_comment rc= 0 reasons= []`; `v01_positive_in_comment rc= 0 reasons= []`; `f3 YAML executable assertNotVisible mission_response_completed = 0`. Воспроизводитель `/tmp/dev-harness-verify/Critic116sol4/child_spoof.py`.

СОВЕТ contracts/116-cmp-mob-005-mission.md:25 — честная разрешённая грамматикой строка `- takeScreenshot: mission-f05-05 # verified` ложно красна (`FLOW_SNIMOK_VNE_MANIFESTA:mission-f05-05 # verified; SELEKTOR_NE_KADRA:mission-f05-05`). Это не обход зелёного критерия; в прочитанном реальном продуктовом `mission.yaml` нет такого inline-комментария на снимке. Можно учесть при ремонте того же разделения комментариев. СОВЕТ contracts/116-cmp-mob-005-mission.md:33 — `--stabs` заявлено «80/80 ok», но фактически выдаёт 97 строк `CASE … ok`, а эта же строка критерия говорит «97 входов»; исправить счётное описание.

## Scope (1)–(4)

|Scope|Результат на собственной копии|
|---|---|
|(1) G1/F1/F3|`proverka_text.py:105-173` G1, `:275-328` F1, `:510-590` F3; контракт `:25`, критерий `:38`. `--tablica` 14 строк/57 клеток-потока, независимое AST-множество 57 уникальных = 57 `subekt=proverka`. Все 18 обязательных красных критика (19-й `pending_before_attach` намеренно зелёный) + семь арбитра красны СВОЕЙ причиной; 5 честных файлов проходят. 10 дополнительных отрицательных комбинаций G/F/ребёнка красны; **новый одиннадцатый comment-spoof и варианты зелёные — 2 обхода**.|
|(2) Ничего сверх|`git diff --name-only 8ffa2c066..708e1773`: только контракт и `fixtures/workshop_project/mission_116/`, вне зоны нет имён; `scripts/sverka_maketa.py`, `scripts/ekran_shablon.py`, `frozen/116/2`, продуктовый файл Jest не изменены. 6 коммитов, каждый меняющий контракт, несёт дословно `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/116-cmp-mob-005-mission.md — выпустить v3 по консультации Astra (REPORT-116, вердикт (в), слово владельца 2026-10-24 23:30): связный основной путь и независимые сценарии состояний, исправленные носители flow, согласованные пины B02/B02t/B09; без ослабления Инв. 4 и без нового предмета.`; 5 честных файлов flow не менялись с v3c. У прежних 80 входов и 57 стабов удалений нет; единственный ожидаемый переворот `proiskhozdenie-snimok-v-rebyonke`: rc0→rc1; Jest-пин `dab2efebea58f15c92a76989436d4a23d97fc72d9238f9c7efa816606438dac9`. G1/F1/F3 уточняют заявленные оси, нового предмета сверх решения арбитра не нашёл.|
|(3) Собственные замеры|`--model` rc0 97/97, 7×KADR 1.000≥0.600; `--stabs` rc0 97 CASE ok, 92×STAB KRASEN, SVJAZI 92, непойманных 0; `--tablica` rc0 14/57/57; без субъекта rc1 SHABLON_ABSENT, 97×CASE KRASNO; `pre_critic` rc0 PREDPOSYLKI_OK; отдельный stand-in e2e rc0, живой раннер 123 на честной replay-пачке rc0 7×KADR 1.000 и ноль MAKET_PODMENEN. Независимые счёты source.json: 80→97 входов (13 форма/57 proverka/27 statika), 57→63 стаба, 73→92 связи; отсутствующие/дополнительные клетки AST = []/[], дубли = 0. `grep com.complior.demo fixtures/workshop_project/mission_116/` — пусто.|
|(4) Реальный флоу|`/tmp/dev-harness-verify/Impl116/mob/mobile/.maestro/mission.yaml` прочитан без правок; `shagi_flow` по продуктовому файлу: rc0, 29 шагов, `errors=[]`. Его одинарные кавычки в `name: '116 mission — …'`, самостоятельные `#`-комментарии и inline-комментарий на `inputText` допустимы; прежний v2-флоу не обязан проходить новые v3 семантические оси, но белый список не отказывает ему по форме.|

## Матрица мутаций на независимом repo/pack из OBJECT

Первый столбец `prior` — `/tmp/dev-harness-verify/Critic116sol3/mutate.py`, `arb` — `/tmp/dev-harness-verify/Arbiter116/zamer.py`, с изменённым только абсолютным корнем на нашу копию. Сырые причины `PRICHINA` (rc=1, если явно не сказано иное):

|источник / мутант|причина|
|---|---|
|prior old_duplicate_early; child_early_root_late; own_assert_between_two|FLOW_SNIMOK_DUBL + FLOW_ASSERT_POSLE_KADRA (child также FLOW_ASSERT_V_CHUZHOM_FAJLE)|
|prior foreign_assert_before_own|FLOW_ASSERT_POSLE_KADRA|
|prior same_name_two_children|FLOW_SNIMOK_DUBL×2 + FLOW_ASSERT_V_CHUZHOM_FAJLE×2|
|prior root_assert_child_shot; child_shot_root_assert_after|FLOW_ASSERT_V_CHUZHOM_FAJLE|
|prior unlisted_screenshot_no_assert; unlisted_duplicate|FLOW_SNIMOK_VNE_MANIFESTA (duplicate также FLOW_SNIMOK_DUBL)|
|prior assert_only_comment|FLOW_BEZ_DOSTIZHENIJA|
|prior assert_only_literal; shot_only_literal|FLOW_SHAG_VNE_GRAMMATIKI×2 + FLOW_BEZ_DOSTIZHENIJA / SELEKTOR_NE_KADRA|
|prior when_runflow_false; when_inline_runflow_false|FLOW_SHAG_VNE_GRAMMATIKI×4 / ×1; BEZPNG (не случайный RUNFLOW_BEZ_FAJLA)|
|prior repeat_root_screenshot|FLOW_SHAG_VNE_GRAMMATIKI×5 + SELEKTOR_NE_KADRA|
|prior v01_send_before_input; draft_sent_before_observe; v02_no_negative_completed|SCENARIJ_VVOD_POSLE_OTPRAVKI / SCENARIJ_OTPRAVKA_V_CHERNOVIKE / SCENARIJ_BEZ_NEGATIVA|
|prior pending_before_attach|rc=0, none — вне класса арбитража|
|arb a_assert_tap_shot|FLOW_DEJSTVIE_MEZHDU_ASSERTOM_I_SNIMKOM|
|arb a_repeat_shot_then_tap; a_retry_shot_only|FLOW_SHAG_VNE_GRAMMATIKI×5/×4 + SELEKTOR_NE_KADRA|
|arb a_assert_in_nested_runflow_inline_commands; a_shot_literal_in_root_comment_like_flow|FLOW_SHAG_VNE_GRAMMATIKI×4/×3 + FLOW_BEZ_DOSTIZHENIJA|
|arb a_f0507_send_after_observe; a_v01_input_only_in_root_then_send|SCENARIJ_OTPRAVKA_V_CHERNOVIKE / SCENARIJ_VVOD_POSLE_OTPRAVKI|
|arb honest|rc=0, none|

Новые независимые комбинации (скрипт `/tmp/dev-harness-verify/Critic116sol4/new_mutants.py`):

|класс / мутант|фактический вывод|
|---|---|
|G g_child_nested_retry|rc1 FLOW_SHAG_VNE_GRAMMATIKI:mission-state-v01.yaml:16, :17, :18|
|G g_root_indented_valid_step|rc1 FLOW_SHAG_VNE_GRAMMATIKI:mission.yaml:34 (+ SELEKTOR_NE_KADRA)|
|G g_child_block_string|rc1 FLOW_SHAG_VNE_GRAMMATIKI:mission-state-v02.yaml:18, :19|
|F f_unlisted_in_child_after_assert|rc1 FLOW_SNIMOK_VNE_MANIFESTA:unknown-frame|
|F f_runflow_between_assert_and_shot|rc1 FLOW_DEJSTVIE_MEZHDU_ASSERTOM_I_SNIMKOM:mission-f05-05 mission.yaml|
|F f_input_between_assert_and_shot|rc1 FLOW_DEJSTVIE_MEZHDU_ASSERTOM_I_SNIMKOM:mission-f05-05 mission.yaml|
|F3 r_v02_input_after_send|rc1 SCENARIJ_VVOD_POSLE_OTPRAVKI:F05.V02 mission-state-v02.yaml|
|F3 r_f07_send_before_draft|rc1 SCENARIJ_OTPRAVKA_V_CHERNOVIKE:F05.07 mission-state-f05-07.yaml (+ SCENARIJ_VVOD_POSLE_OTPRAVKI)|
|F3 r_v02_negative_before_positive|rc1 SCENARIJ_BEZ_NEGATIVA:mission_response_completed mission-state-v02.yaml|
|F3 r_v01_extra_input_after_first_send|rc1 SCENARIJ_VVOD_POSLE_OTPRAVKI:F05.V01 mission-state-v01.yaml|
|положительные honest; g_comment_and_quote_header|rc0 none; rc0 none|
|**F1 новый comment_assert_on_hidekeyboard; comment_assert_on_input**|**rc0 reasons=[]; rc0 reasons=[] (ОБХОД)**|
|**F3 новый v02_negative_in_comment; v01_positive_in_comment**|**rc0 reasons=[]; rc0 reasons=[] (ОБХОД)**|

## Сырой вывод ключевых проверок

```
$ bash fixtures/workshop_project/mission_116/red_mission_116.sh --tablica
OSI	grammatika	mission.yaml + mission-state-*.yaml	9
OSI	snimok	раскрытый поток: mission.yaml + дети	3
OSI	rebyonok	mission-state-*.yaml	5
OSI	итого	строк=14 клеток=57 клеток-потока=57
[exit=0]
$ bash fixtures/workshop_project/mission_116/red_mission_116.sh --model
CASE proiskhozdenie-snimok-v-rebyonke ok
CASE proiskhozdenie-grammatika-literall ok
CASE proiskhozdenie-dejstvie-mezhdu-assertom-i-snimkom ok
CASE proiskhozdenie-v02-bez-negativa ok
KADR	F05.01 dark	1.000	0.600	G	OK
KADR	F05.02 dark	1.000	0.600	G	OK
KADR	F05.03 dark	1.000	0.600	G	OK
KADR	F05.04 dark	1.000	0.600	G	OK
KADR	F05.05 dark	1.000	0.600	G	OK
KADR	F05.06 dark	1.000	0.600	G	OK
KADR	F05.V03 dark	1.000	0.600	G	OK
[exit=0; 97 CASE ok]
$ bash fixtures/workshop_project/mission_116/red_mission_116.sh --stabs
STAB s74_grammatika_propuskaet.py proiskhozdenie-grammatika-literall KRASEN
STAB s75_snimok_vne_manifesta_propuskaet.py proiskhozdenie-snimok-vne-manifesta KRASEN
STAB s76_assert_v_chuzhom_fajle_propuskaet.py proiskhozdenie-dejstvie-mezhdu-assertom-i-snimkom KRASEN
STAB s77_vvod_posle_otpravki_propuskaet.py proiskhozdenie-v01-vvod-posle-otpravki KRASEN
STAB s78_otpravka_v_chernovike_propuskaet.py proiskhozdenie-f05-07-otpravka-posle-nabljudenija KRASEN
STAB s79_bez_negativa_propuskaet.py proiskhozdenie-v02-bez-negativa KRASEN
SVJAZI 92
[exit=0; 97 CASE ok, 92 STAB KRASEN]
$ bash scripts/pre_critic.sh contracts/116-cmp-mob-005-mission.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
КРИТИК: дверь зелёная
[exit=0]
$ bash fixtures/workshop_project/mission_116/red_mission_116.sh  # отдельная копия БЕЗ scripts/ekran_shablon.py
SHABLON_ABSENT
CASE chestnyj-ekran KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-v02-bez-negativa KRASNO (SHABLON_ABSENT)
[exit=1; 97 CASE KRASNO]
$ python3 .harness123/scripts/sverka_maketa.py --manifest .harness123/kadry.json --kadry mobile/maestro-out-mission --repo .  # после stand-in e2e, rc0
KADR	F05.01 dark	1.000	0.600	G	OK
KADR	F05.02 dark	1.000	0.600	G	OK
KADR	F05.03 dark	1.000	0.600	G	OK
KADR	F05.04 dark	1.000	0.600	G	OK
KADR	F05.05 dark	1.000	0.600	G	OK
KADR	F05.06 dark	1.000	0.600	G	OK
KADR	F05.V03 dark	1.000	0.600	G	OK
[exit=0; stderr empty]
```

Отказ не о pixel runtime и не о синтаксисе произвольного YAML: два полностью допустимых G1 комментария делают собственную F1/F3 проверку ложнозелёной. После этого круга повторного судейства не проводил.

## Полные сырые журналы замеров (последовательный повтор на собственной копии)
### model
`cwd=/tmp/dev-harness-verify/Critic116sol4/repo`; `$ bash fixtures/workshop_project/mission_116/red_mission_116.sh --model`
```text
CASE chestnyj-ekran ok
CASE literal-cveta ok
CASE kadr-nizhe-poroga ok
CASE kadr-composer-skryt ok
CASE chuzhoj-kadr ok
CASE ne-tselikom ok
CASE zamenjaet-pustoj ok
CASE ne-trogaet-pustoj ok
CASE kontrakt-slishkom-dlinnyj ok
CASE kontrakt-shirokij ok
CASE kadry-ustarevshie ok
CASE e2e-ne-proshla ok
CASE zhivaja-pachta-v-repo ok
CASE proiskhozdenie-chistyj ok
CASE proiskhozdenie-byte-kopija ok
CASE proiskhozdenie-flow-bez-perehoda ok
CASE proiskhozdenie-selektor-bez-ekrana ok
CASE proiskhozdenie-selektor-ne-kadra ok
CASE proiskhozdenie-bez-start-vhoda ok
CASE proiskhozdenie-bez-draft-gesta ok
CASE proiskhozdenie-bez-vlozhenija ok
CASE bezpng-kopija-vne-kataloga ok
CASE bezpng-token-vne-audita ok
CASE bezpng-bez-testid-v-potoke ok
CASE povedenie-chistyj ok
CASE povedenie-draft-termjaetsja ok
CASE povedenie-draft-vechen ok
CASE povedenie-draft-bez-hranilishcha ok
CASE povedenie-intent-slitan ok
CASE povedenie-dublient ok
CASE povedenie-interrupted-zavershen ok
CASE povedenie-revoked-pokazan ok
CASE bezpng-render-pustoj ok
CASE bezpng-render-stroka ok
CASE bezpng-render-literal ok
CASE bezpng-chip-stroka ok
CASE povedenie-proba-otsutstvuet ok
CASE povedenie-proba-podmenena ok
CASE ci-shag-otsutstvuet ok
CASE ci-shag-ne-gejtit ok
CASE ci-coe-posle-run ok
CASE ci-if-false-posle-run ok
CASE ci-echo-podmena ok
CASE ci-run-kommentarij ok
CASE ci-shag-vne-required-job ok
CASE ci-job-inline-kommentarij ok
CASE ci-job-kavychki ok
CASE ci-job-otstup-chetyre ok
CASE ci-steps-indentless ok
CASE ci-steps-indentless-kavychka-kommentarij ok
CASE ci-steps-indentless-otstup-chetyre ok
CASE proiskhozdenie-gest-kommentarij ok
CASE proiskhozdenie-runflow-bez-fajla ok
CASE proiskhozdenie-runflow-cikl ok
CASE proiskhozdenie-rebyonok-bez-zapuska ok
CASE proiskhozdenie-rebyonok-bez-start-vhoda ok
CASE proiskhozdenie-khvost-v-korne ok
CASE proiskhozdenie-bez-upload-perehoda ok
CASE proiskhozdenie-chip-neg-do-uploada ok
CASE proiskhozdenie-chip-posle-uploada ok
CASE proiskhozdenie-bez-v03-posle-uploada ok
CASE proiskhozdenie-bez-chip-pending ok
CASE bezpng-bez-scenarija ok
CASE proiskhozdenie-chip-neg-udalen ok
CASE proiskhozdenie-kadr-do-asserta ok
CASE proiskhozdenie-rebyonok-bez-dejstvija ok
CASE proiskhozdenie-v04-odna-otpravka ok
CASE proiskhozdenie-v02-bez-gesta ok
CASE proiskhozdenie-f05-07-bez-gesta ok
CASE proiskhozdenie-manifest-pereputan ok
CASE proiskhozdenie-sirot-testid ok
CASE proiskhozdenie-flow-appid-chuzhoj ok
CASE proiskhozdenie-scenarij-ne-zapushhen ok
CASE proiskhozdenie-dublj-rannij ok
CASE proiskhozdenie-dublj-chestnye ok
CASE proiskhozdenie-dublj-rannie ok
CASE proiskhozdenie-kadr-chuzhoj-assert ok
CASE proiskhozdenie-snimok-v-rebyonke ok
CASE proiskhozdenie-rebyonok-ranishe-asserta ok
CASE proiskhozdenie-assert-v-rebyonke ok
CASE proiskhozdenie-grammatika-literall ok
CASE proiskhozdenie-grammatika-literall-snimok ok
CASE proiskhozdenie-grammatika-literall-kommentarij ok
CASE proiskhozdenie-grammatika-repeat ok
CASE proiskhozdenie-grammatika-repeat-tap ok
CASE proiskhozdenie-grammatika-retry ok
CASE proiskhozdenie-grammatika-when ok
CASE proiskhozdenie-grammatika-runflow-vlozhennyj ok
CASE proiskhozdenie-grammatika-neizvestnyj-argument ok
CASE proiskhozdenie-snimok-vne-manifesta ok
CASE proiskhozdenie-snimok-vne-manifesta-dubl ok
CASE proiskhozdenie-dejstvie-mezhdu-assertom-i-snimkom ok
CASE proiskhozdenie-v01-otpravka-do-vvoda ok
CASE proiskhozdenie-v01-vvod-posle-otpravki ok
CASE proiskhozdenie-f05-07-otpravka-do-nabljudenija ok
CASE proiskhozdenie-f05-07-otpravka-posle-nabljudenija ok
CASE proiskhozdenie-v02-bez-negativa ok
KADR	F05.01 dark	1.000	0.600	G	OK
KADR	F05.02 dark	1.000	0.600	G	OK
KADR	F05.03 dark	1.000	0.600	G	OK
KADR	F05.04 dark	1.000	0.600	G	OK
KADR	F05.05 dark	1.000	0.600	G	OK
KADR	F05.06 dark	1.000	0.600	G	OK
KADR	F05.V03 dark	1.000	0.600	G	OK
[exit=0]
```
### stabs
`cwd=/tmp/dev-harness-verify/Critic116sol4/repo`; `$ bash fixtures/workshop_project/mission_116/red_mission_116.sh --stabs`
```text
CASE chestnyj-ekran ok
CASE literal-cveta ok
CASE kadr-nizhe-poroga ok
CASE kadr-composer-skryt ok
CASE chuzhoj-kadr ok
CASE ne-tselikom ok
CASE zamenjaet-pustoj ok
CASE ne-trogaet-pustoj ok
CASE kontrakt-slishkom-dlinnyj ok
CASE kontrakt-shirokij ok
CASE kadry-ustarevshie ok
CASE e2e-ne-proshla ok
CASE zhivaja-pachta-v-repo ok
CASE proiskhozdenie-chistyj ok
CASE proiskhozdenie-byte-kopija ok
CASE proiskhozdenie-flow-bez-perehoda ok
CASE proiskhozdenie-selektor-bez-ekrana ok
CASE proiskhozdenie-selektor-ne-kadra ok
CASE proiskhozdenie-bez-start-vhoda ok
CASE proiskhozdenie-bez-draft-gesta ok
CASE proiskhozdenie-bez-vlozhenija ok
CASE bezpng-kopija-vne-kataloga ok
CASE bezpng-token-vne-audita ok
CASE bezpng-bez-testid-v-potoke ok
CASE povedenie-chistyj ok
CASE povedenie-draft-termjaetsja ok
CASE povedenie-draft-vechen ok
CASE povedenie-draft-bez-hranilishcha ok
CASE povedenie-intent-slitan ok
CASE povedenie-dublient ok
CASE povedenie-interrupted-zavershen ok
CASE povedenie-revoked-pokazan ok
CASE bezpng-render-pustoj ok
CASE bezpng-render-stroka ok
CASE bezpng-render-literal ok
CASE bezpng-chip-stroka ok
CASE povedenie-proba-otsutstvuet ok
CASE povedenie-proba-podmenena ok
CASE ci-shag-otsutstvuet ok
CASE ci-shag-ne-gejtit ok
CASE ci-coe-posle-run ok
CASE ci-if-false-posle-run ok
CASE ci-echo-podmena ok
CASE ci-run-kommentarij ok
CASE ci-shag-vne-required-job ok
CASE ci-job-inline-kommentarij ok
CASE ci-job-kavychki ok
CASE ci-job-otstup-chetyre ok
CASE ci-steps-indentless ok
CASE ci-steps-indentless-kavychka-kommentarij ok
CASE ci-steps-indentless-otstup-chetyre ok
CASE proiskhozdenie-gest-kommentarij ok
CASE proiskhozdenie-runflow-bez-fajla ok
CASE proiskhozdenie-runflow-cikl ok
CASE proiskhozdenie-rebyonok-bez-zapuska ok
CASE proiskhozdenie-rebyonok-bez-start-vhoda ok
CASE proiskhozdenie-khvost-v-korne ok
CASE proiskhozdenie-bez-upload-perehoda ok
CASE proiskhozdenie-chip-neg-do-uploada ok
CASE proiskhozdenie-chip-posle-uploada ok
CASE proiskhozdenie-bez-v03-posle-uploada ok
CASE proiskhozdenie-bez-chip-pending ok
CASE bezpng-bez-scenarija ok
CASE proiskhozdenie-chip-neg-udalen ok
CASE proiskhozdenie-kadr-do-asserta ok
CASE proiskhozdenie-rebyonok-bez-dejstvija ok
CASE proiskhozdenie-v04-odna-otpravka ok
CASE proiskhozdenie-v02-bez-gesta ok
CASE proiskhozdenie-f05-07-bez-gesta ok
CASE proiskhozdenie-manifest-pereputan ok
CASE proiskhozdenie-sirot-testid ok
CASE proiskhozdenie-flow-appid-chuzhoj ok
CASE proiskhozdenie-scenarij-ne-zapushhen ok
CASE proiskhozdenie-dublj-rannij ok
CASE proiskhozdenie-dublj-chestnye ok
CASE proiskhozdenie-dublj-rannie ok
CASE proiskhozdenie-kadr-chuzhoj-assert ok
CASE proiskhozdenie-snimok-v-rebyonke ok
CASE proiskhozdenie-rebyonok-ranishe-asserta ok
CASE proiskhozdenie-assert-v-rebyonke ok
CASE proiskhozdenie-grammatika-literall ok
CASE proiskhozdenie-grammatika-literall-snimok ok
CASE proiskhozdenie-grammatika-literall-kommentarij ok
CASE proiskhozdenie-grammatika-repeat ok
CASE proiskhozdenie-grammatika-repeat-tap ok
CASE proiskhozdenie-grammatika-retry ok
CASE proiskhozdenie-grammatika-when ok
CASE proiskhozdenie-grammatika-runflow-vlozhennyj ok
CASE proiskhozdenie-grammatika-neizvestnyj-argument ok
CASE proiskhozdenie-snimok-vne-manifesta ok
CASE proiskhozdenie-snimok-vne-manifesta-dubl ok
CASE proiskhozdenie-dejstvie-mezhdu-assertom-i-snimkom ok
CASE proiskhozdenie-v01-otpravka-do-vvoda ok
CASE proiskhozdenie-v01-vvod-posle-otpravki ok
CASE proiskhozdenie-f05-07-otpravka-do-nabljudenija ok
CASE proiskhozdenie-f05-07-otpravka-posle-nabljudenija ok
CASE proiskhozdenie-v02-bez-negativa ok
STAB s01_bez_literal_skana.py literal-cveta KRASEN
STAB s03_chuzhie_propuskaet.py chuzhoj-kadr KRASEN
STAB s04_tselikom_propuskaet.py ne-tselikom KRASEN
STAB s12_polnota_propuskaet.py zamenjaet-pustoj KRASEN
STAB s12_polnota_propuskaet.py zhivaja-pachta-v-repo KRASEN
STAB s12_polnota_propuskaet.py ne-trogaet-pustoj KRASEN
STAB s14_objem_propuskaet.py kontrakt-slishkom-dlinnyj KRASEN
STAB s14_objem_propuskaet.py kontrakt-shirokij KRASEN
STAB s15_svezhest_propuskaet.py kadry-ustarevshie KRASEN
STAB s19_byte_kopiju_propuskaet.py proiskhozdenie-byte-kopija KRASEN
STAB s20_perehod_propuskaet.py proiskhozdenie-flow-bez-perehoda KRASEN
STAB s21_selektor_propuskaet.py proiskhozdenie-selektor-bez-ekrana KRASEN
STAB s22_selektor_ne_kadra_propuskaet.py proiskhozdenie-selektor-ne-kadra KRASEN
STAB s23_bez_start_vhoda.py proiskhozdenie-bez-start-vhoda KRASEN
STAB s24_bez_draft_gesta.py proiskhozdenie-bez-draft-gesta KRASEN
STAB s24_bez_draft_gesta.py proiskhozdenie-gest-kommentarij KRASEN
STAB s25_bez_vlozhenija.py proiskhozdenie-bez-vlozhenija KRASEN
STAB s26_bezpng_kopiju_propuskaet.py bezpng-kopija-vne-kataloga KRASEN
STAB s27_bezpng_token_propuskaet.py bezpng-token-vne-audita KRASEN
STAB s28_bezpng_testid_propuskaet.py bezpng-bez-testid-v-potoke KRASEN
STAB s29_povedenie_draft_termjaetsja.py povedenie-draft-termjaetsja KRASEN
STAB s30_povedenie_draft_vechen.py povedenie-draft-vechen KRASEN
STAB s31_povedenie_draft_bez_hranilishcha.py povedenie-draft-bez-hranilishcha KRASEN
STAB s32_povedenie_intent_slitan.py povedenie-intent-slitan KRASEN
STAB s33_povedenie_dublient.py povedenie-dublient KRASEN
STAB s34_povedenie_interrupted_zavershen.py povedenie-interrupted-zavershen KRASEN
STAB s35_povedenie_revoked_pokazan.py povedenie-revoked-pokazan KRASEN
STAB s36_bezpng_render_pustoj.py bezpng-render-pustoj KRASEN
STAB s37_bezpng_render_stroka.py bezpng-render-stroka KRASEN
STAB s38_bezpng_render_literal.py bezpng-render-literal KRASEN
STAB s39_bezpng_chip_stroka.py bezpng-chip-stroka KRASEN
STAB s40_proba_otsutstvuet_propuskaet.py povedenie-proba-otsutstvuet KRASEN
STAB s41_proba_podmenena_propuskaet.py povedenie-proba-podmenena KRASEN
STAB s42_ci_bez_shaga_propuskaet.py ci-shag-otsutstvuet KRASEN
STAB s43_ci_shag_ne_gejtit_propuskaet.py ci-shag-ne-gejtit KRASEN
STAB s44_ci_coe_posle_run_propuskaet.py ci-coe-posle-run KRASEN
STAB s45_ci_if_false_posle_run_propuskaet.py ci-if-false-posle-run KRASEN
STAB s46_ci_echo_podmena_propuskaet.py ci-echo-podmena KRASEN
STAB s47_ci_run_kommentarij_propuskaet.py ci-run-kommentarij KRASEN
STAB s52_runflow_bez_fajla_propuskaet.py proiskhozdenie-runflow-bez-fajla KRASEN
STAB s53_runflow_cikl_propuskaet.py proiskhozdenie-runflow-cikl KRASEN
STAB s54_rebyonok_bez_zapuska_propuskaet.py proiskhozdenie-rebyonok-bez-zapuska KRASEN
STAB s55_rebyonok_bez_start_vhoda_propuskaet.py proiskhozdenie-rebyonok-bez-start-vhoda KRASEN
STAB s56_bezpng_bez_scenarija_propuskaet.py bezpng-bez-scenarija KRASEN
STAB s57_bezpng_v_korne_propuskaet.py proiskhozdenie-khvost-v-korne KRASEN
STAB s58_bez_upload_perehoda_propuskaet.py proiskhozdenie-bez-upload-perehoda KRASEN
STAB s59_chip_neg_do_uploada_propuskaet.py proiskhozdenie-chip-neg-do-uploada KRASEN
STAB s60_bez_chip_pending_propuskaet.py proiskhozdenie-bez-chip-pending KRASEN
STAB s61_bez_v03_posle_uploada_propuskaet.py proiskhozdenie-bez-v03-posle-uploada KRASEN
STAB s62_chip_posle_uploada_propuskaet.py proiskhozdenie-chip-posle-uploada KRASEN
STAB s63_appid_propuskaet.py proiskhozdenie-flow-appid-chuzhoj KRASEN
STAB s64_dejstvie_propuskaet.py proiskhozdenie-rebyonok-bez-dejstvija KRASEN
STAB s64_dejstvie_propuskaet.py proiskhozdenie-v04-odna-otpravka KRASEN
STAB s65_svoej_testid_propuskaet.py proiskhozdenie-manifest-pereputan KRASEN
STAB s65_svoej_testid_propuskaet.py proiskhozdenie-sirot-testid KRASEN
STAB s66_chernovik_v_scenarii_propuskaet.py proiskhozdenie-v02-bez-gesta KRASEN
STAB s66_chernovik_v_scenarii_propuskaet.py proiskhozdenie-f05-07-bez-gesta KRASEN
STAB s67_chip_neg_udalen_propuskaet.py proiskhozdenie-chip-neg-udalen KRASEN
STAB s68_kadr_do_asserta_propuskaet.py proiskhozdenie-kadr-do-asserta KRASEN
STAB s68_kadr_do_asserta_propuskaet.py proiskhozdenie-dublj-rannij KRASEN
STAB s68_kadr_do_asserta_propuskaet.py proiskhozdenie-dublj-rannie KRASEN
STAB s68_kadr_do_asserta_propuskaet.py proiskhozdenie-kadr-chuzhoj-assert KRASEN
STAB s68_kadr_do_asserta_propuskaet.py proiskhozdenie-rebyonok-ranishe-asserta KRASEN
STAB s68_kadr_do_asserta_propuskaet.py proiskhozdenie-assert-v-rebyonke KRASEN
STAB s69_scenarij_ne_zapushhen_propuskaet.py proiskhozdenie-scenarij-ne-zapushhen KRASEN
STAB s70_dublj_snimka_propuskaet.py proiskhozdenie-dublj-rannij KRASEN
STAB s70_dublj_snimka_propuskaet.py proiskhozdenie-dublj-chestnye KRASEN
STAB s70_dublj_snimka_propuskaet.py proiskhozdenie-dublj-rannie KRASEN
STAB s71_parnost_vhozhdenij_propuskaet.py proiskhozdenie-dublj-rannij KRASEN
STAB s72_chuzhoj_assert_propuskaet.py proiskhozdenie-kadr-chuzhoj-assert KRASEN
STAB s73_raskrytie_potoka_propuskaet.py proiskhozdenie-snimok-v-rebyonke KRASEN
STAB s73_raskrytie_potoka_propuskaet.py proiskhozdenie-rebyonok-ranishe-asserta KRASEN
STAB s73_raskrytie_potoka_propuskaet.py proiskhozdenie-assert-v-rebyonke KRASEN
STAB s74_grammatika_propuskaet.py proiskhozdenie-grammatika-literall KRASEN
STAB s74_grammatika_propuskaet.py proiskhozdenie-grammatika-literall-snimok KRASEN
STAB s74_grammatika_propuskaet.py proiskhozdenie-grammatika-literall-kommentarij KRASEN
STAB s74_grammatika_propuskaet.py proiskhozdenie-grammatika-repeat KRASEN
STAB s74_grammatika_propuskaet.py proiskhozdenie-grammatika-repeat-tap KRASEN
STAB s74_grammatika_propuskaet.py proiskhozdenie-grammatika-retry KRASEN
STAB s74_grammatika_propuskaet.py proiskhozdenie-grammatika-when KRASEN
STAB s74_grammatika_propuskaet.py proiskhozdenie-grammatika-runflow-vlozhennyj KRASEN
STAB s74_grammatika_propuskaet.py proiskhozdenie-grammatika-neizvestnyj-argument KRASEN
STAB s75_snimok_vne_manifesta_propuskaet.py proiskhozdenie-snimok-vne-manifesta KRASEN
STAB s75_snimok_vne_manifesta_propuskaet.py proiskhozdenie-snimok-vne-manifesta-dubl KRASEN
STAB s76_assert_v_chuzhom_fajle_propuskaet.py proiskhozdenie-snimok-v-rebyonke KRASEN
STAB s76_assert_v_chuzhom_fajle_propuskaet.py proiskhozdenie-dejstvie-mezhdu-assertom-i-snimkom KRASEN
STAB s76_assert_v_chuzhom_fajle_propuskaet.py proiskhozdenie-assert-v-rebyonke KRASEN
STAB s77_vvod_posle_otpravki_propuskaet.py proiskhozdenie-v01-otpravka-do-vvoda KRASEN
STAB s77_vvod_posle_otpravki_propuskaet.py proiskhozdenie-v01-vvod-posle-otpravki KRASEN
STAB s78_otpravka_v_chernovike_propuskaet.py proiskhozdenie-f05-07-otpravka-do-nabljudenija KRASEN
STAB s78_otpravka_v_chernovike_propuskaet.py proiskhozdenie-f05-07-otpravka-posle-nabljudenija KRASEN
STAB s79_bez_negativa_propuskaet.py proiskhozdenie-v02-bez-negativa KRASEN
SVJAZI 92
[exit=0]
```
### tablica
`cwd=/tmp/dev-harness-verify/Critic116sol4/repo`; `$ bash fixtures/workshop_project/mission_116/red_mission_116.sh --tablica`
```text
OSI	строка	файл	клеток
OSI	osnovnoj-put	mission.yaml	18
OSI	f05-07	mission-state-f05-07.yaml	3
OSI	v01	mission-state-v01.yaml	7
OSI	v02	mission-state-v02.yaml	3
OSI	v04	mission-state-v04.yaml	2
OSI	porjadok-dublj-rannij	mission.yaml	1
OSI	porjadok-dublj-chestnye	mission.yaml	1
OSI	porjadok-dublj-rannie	mission.yaml	1
OSI	porjadok-chuzhoj-assert	mission.yaml	1
OSI	porjadok-koren-rebyonok	mission.yaml + mission-state-v01.yaml	2
OSI	porjadok-rebyonok-ranishe	mission-state-v01.yaml	1
OSI	grammatika	mission.yaml + mission-state-*.yaml	9
OSI	snimok	раскрытый поток: mission.yaml + дети	3
OSI	rebyonok	mission-state-*.yaml	5
OSI	итого	строк=14 клеток=57 клеток-потока=57
[exit=0]
```
### without_subject
`cwd=/tmp/dev-harness-verify/Critic116sol4/without_subject`; `$ bash fixtures/workshop_project/mission_116/red_mission_116.sh`
```text
SHABLON_ABSENT
CASE chestnyj-ekran KRASNO (SHABLON_ABSENT)
CASE literal-cveta KRASNO (SHABLON_ABSENT)
CASE kadr-nizhe-poroga KRASNO (SHABLON_ABSENT)
CASE kadr-composer-skryt KRASNO (SHABLON_ABSENT)
CASE chuzhoj-kadr KRASNO (SHABLON_ABSENT)
CASE ne-tselikom KRASNO (SHABLON_ABSENT)
CASE zamenjaet-pustoj KRASNO (SHABLON_ABSENT)
CASE ne-trogaet-pustoj KRASNO (SHABLON_ABSENT)
CASE kontrakt-slishkom-dlinnyj KRASNO (SHABLON_ABSENT)
CASE kontrakt-shirokij KRASNO (SHABLON_ABSENT)
CASE kadry-ustarevshie KRASNO (SHABLON_ABSENT)
CASE e2e-ne-proshla KRASNO (SHABLON_ABSENT)
CASE zhivaja-pachta-v-repo KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-chistyj KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-byte-kopija KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-flow-bez-perehoda KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-selektor-bez-ekrana KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-selektor-ne-kadra KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-bez-start-vhoda KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-bez-draft-gesta KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-bez-vlozhenija KRASNO (SHABLON_ABSENT)
CASE bezpng-kopija-vne-kataloga KRASNO (SHABLON_ABSENT)
CASE bezpng-token-vne-audita KRASNO (SHABLON_ABSENT)
CASE bezpng-bez-testid-v-potoke KRASNO (SHABLON_ABSENT)
CASE povedenie-chistyj KRASNO (SHABLON_ABSENT)
CASE povedenie-draft-termjaetsja KRASNO (SHABLON_ABSENT)
CASE povedenie-draft-vechen KRASNO (SHABLON_ABSENT)
CASE povedenie-draft-bez-hranilishcha KRASNO (SHABLON_ABSENT)
CASE povedenie-intent-slitan KRASNO (SHABLON_ABSENT)
CASE povedenie-dublient KRASNO (SHABLON_ABSENT)
CASE povedenie-interrupted-zavershen KRASNO (SHABLON_ABSENT)
CASE povedenie-revoked-pokazan KRASNO (SHABLON_ABSENT)
CASE bezpng-render-pustoj KRASNO (SHABLON_ABSENT)
CASE bezpng-render-stroka KRASNO (SHABLON_ABSENT)
CASE bezpng-render-literal KRASNO (SHABLON_ABSENT)
CASE bezpng-chip-stroka KRASNO (SHABLON_ABSENT)
CASE povedenie-proba-otsutstvuet KRASNO (SHABLON_ABSENT)
CASE povedenie-proba-podmenena KRASNO (SHABLON_ABSENT)
CASE ci-shag-otsutstvuet KRASNO (SHABLON_ABSENT)
CASE ci-shag-ne-gejtit KRASNO (SHABLON_ABSENT)
CASE ci-coe-posle-run KRASNO (SHABLON_ABSENT)
CASE ci-if-false-posle-run KRASNO (SHABLON_ABSENT)
CASE ci-echo-podmena KRASNO (SHABLON_ABSENT)
CASE ci-run-kommentarij KRASNO (SHABLON_ABSENT)
CASE ci-shag-vne-required-job KRASNO (SHABLON_ABSENT)
CASE ci-job-inline-kommentarij KRASNO (SHABLON_ABSENT)
CASE ci-job-kavychki KRASNO (SHABLON_ABSENT)
CASE ci-job-otstup-chetyre KRASNO (SHABLON_ABSENT)
CASE ci-steps-indentless KRASNO (SHABLON_ABSENT)
CASE ci-steps-indentless-kavychka-kommentarij KRASNO (SHABLON_ABSENT)
CASE ci-steps-indentless-otstup-chetyre KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-gest-kommentarij KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-runflow-bez-fajla KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-runflow-cikl KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-rebyonok-bez-zapuska KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-rebyonok-bez-start-vhoda KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-khvost-v-korne KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-bez-upload-perehoda KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-chip-neg-do-uploada KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-chip-posle-uploada KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-bez-v03-posle-uploada KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-bez-chip-pending KRASNO (SHABLON_ABSENT)
CASE bezpng-bez-scenarija KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-chip-neg-udalen KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-kadr-do-asserta KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-rebyonok-bez-dejstvija KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-v04-odna-otpravka KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-v02-bez-gesta KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-f05-07-bez-gesta KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-manifest-pereputan KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-sirot-testid KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-flow-appid-chuzhoj KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-scenarij-ne-zapushhen KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-dublj-rannij KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-dublj-chestnye KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-dublj-rannie KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-kadr-chuzhoj-assert KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-snimok-v-rebyonke KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-rebyonok-ranishe-asserta KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-assert-v-rebyonke KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-grammatika-literall KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-grammatika-literall-snimok KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-grammatika-literall-kommentarij KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-grammatika-repeat KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-grammatika-repeat-tap KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-grammatika-retry KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-grammatika-when KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-grammatika-runflow-vlozhennyj KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-grammatika-neizvestnyj-argument KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-snimok-vne-manifesta KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-snimok-vne-manifesta-dubl KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-dejstvie-mezhdu-assertom-i-snimkom KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-v01-otpravka-do-vvoda KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-v01-vvod-posle-otpravki KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-f05-07-otpravka-do-nabljudenija KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-f05-07-otpravka-posle-nabljudenija KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-v02-bez-negativa KRASNO (SHABLON_ABSENT)
[exit=1]
```
### pre_critic
`cwd=/tmp/dev-harness-verify/Critic116sol4/repo`; `$ bash scripts/pre_critic.sh contracts/116-cmp-mob-005-mission.md`
```text
КРИТИК: дверь зелёная
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
[exit=0]
```
### runner123
`cwd=/tmp/dev-harness-verify/Critic116sol4/runner123_scratch/repo`; `$ python3 .harness123/scripts/sverka_maketa.py --manifest .harness123/kadry.json --kadry mobile/maestro-out-mission --repo .`
```text
KADR	F05.01 dark	1.000	0.600	G	OK
KADR	F05.02 dark	1.000	0.600	G	OK
KADR	F05.03 dark	1.000	0.600	G	OK
KADR	F05.04 dark	1.000	0.600	G	OK
KADR	F05.05 dark	1.000	0.600	G	OK
KADR	F05.06 dark	1.000	0.600	G	OK
KADR	F05.V03 dark	1.000	0.600	G	OK
[exit=0]
```
