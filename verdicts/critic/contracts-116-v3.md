accept
OBJECT=3d899398e73a028e6a29be77a3c9843a3ef761df

# Критик 116 v3e — последний scoped-круг до заморозки

Основание: закоммиченный кандидат `contracts/116-cmp-mob-005-mission.md` на OBJECT, консультация Astra `REPORT-116.md` §3 шаг 1, решение арбитра `verdicts/arbitration/contracts-116-v3-arbitraz.md` §2–3 и предыдущий `critic-r4-FAIL.md`. Судился контракт/его исполняемый критерий, не готовность будущего продуктового экрана. Все замеры — на отдельной копии кандидата `/tmp/dev-harness-verify/Critic116sol5/repo` с собственной `.git` и независимых сборках pack/repo внутри `/tmp/dev-harness-verify/Critic116sol5/`; исходный клон архитектора, основной checkout и продуктовый клон не менялись. **Блокеров: 0. Обходов с зелёным критерием внутри закрытого класса не найдено.** Эмулятор и живой product-CI не запускались; stand-in e2e и настоящий раннер 123 на replay-кадрах — не выдаются за живые кадры продукта.

## Scope (1)–(4)

| Область | Результат / свидетельство |
|---|---|
| (1) закрытый список G1/F1/F3 и класс комментарий/литерал | Четыре обхода прошлого круга (`hideKeyboard # assertVisible`, `inputText: 'x' # assertVisible`, V02 `hideKeyboard # assertNotVisible`, V01 `hideKeyboard # assertVisible`) теперь rc1 **своими** `FLOW_BEZ_DOSTIZHENIJA`, `SCENARIJ_BEZ_NEGATIVA`, `SCENARIJ_BEZ_SVOEJ_TESTID`/`BEZPNG_BEZ_TESTID_V_POTOKE`; PyYAML на отдельном quoted-литерале подтверждает 0 исполняемых assert F05.05. Все 18 применимых отрицательных мутаций критика r3 и 7 вариантов арбитра rc1 по соответствующим осям (отдельно честный rc0); девятнадцатый `pending_before_attach` rc0 **по прямому исключению арбитра §2**: добавочный assert судит живой Maestro, не статическая батарея. 9 новых отрицательных комбинаций внутри класса красны, 3 зелёных контроля (комментарий между assert и снимком, inline `# verified` у снимка, quoted `#` в name) проходят. Грамматика всех пяти честных файлов без отказов. Подробности ниже. |
| (2) ничего сверх Astra/арбитра | `git diff --name-only 8ffa2c066..OBJECT`: 62 пути, все — один контракт либо `fixtures/workshop_project/mission_116/`; нет изменений 132, 123, `frozen/contracts/116/2`, продуктового Jest. Пять коммитов, действительно меняющих контракт (53724ea7, e812c418, a30d7092, 708e1773, 3d899398), содержат дословную строку `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/116-cmp-mob-005-mission.md — выпустить v3 по консультации Astra (REPORT-116, вердикт (в), слово владельца 2026-10-24 23:30): связный основной путь и независимые сценарии состояний, исправленные носители flow, согласованные пины B02/B02t/B09; без ослабления Инв. 4 и без нового предмета.`; bcaab6da/2a1090b2 контракта не меняют. По независимому JSON/AST: прежних удалённых клеток/стабов нет; `RENDER_V03_CHIP_LESET` остаётся, Jest-пин `dab2efebea58f15c92a76989436d4a23d97fc72d9238f9c7efa816606438dac9`; пины B02/B02t/B09 в фикстуре `eb4c4cf8…81db` / `727ee59e…063c9a` / `ed7627cc…8294`. Никакого ослабления Инв. 4 текстом не установлено. |
| (3) собственные замеры | `--model` rc0: 103 CASE ok и 7×KADR `1.000 ≥ 0.600`; `--stabs` rc0: 103 CASE ok, все 97×STAB KRASEN, `SVJAZI 97`, непойманных 0; `--tablica` rc0: 20 строк, 63 клетки = 63 клетки потока. Дерево *без* `scripts/ekran_shablon.py`: plain rc1 `SHABLON_ABSENT`, 103×`CASE … KRASNO`, ok=0. `pre_critic` rc0 PREDPOSYLKI_OK; `check_precision_gate.sh` rc0 OK. Отдельный stand-in e2e rc0 и вызов настоящего `.harness123/scripts/sverka_maketa.py` rc0: 7×KADR 1.000, `MAKET_PODMENEN` нет. Независимо подсчитано: 103 = 13 forma + 63 proverka + 27 statika, исходы 11 зелёных/92 красных, 67 стабов/97 связей, 20 строк/63 уникальные клетки, множества `missing=[]`, `extra=[]`, removed cases/stubs `[]`/`[]`. |
| (4) реальный продуктовый flow | Read-only `/tmp/dev-harness-verify/Impl116/mob/mobile/.maestro/mission.yaml`: `shagi_flow` на данном файле → **29 шагов, `errors=[]`**, sha256 `17d6fd784d4ff1341cfc7faba47cf11fab2e1eff6ebcf7b306c97fd8a488b3e8`; G1 не отвергает честную продуктовую форму. Это совместимость синтаксиса, не заявление о прохождении нового продуктового семантического критерия до миграции. |

### Матрица независимых мутаций (каждая начиналась с восстановленных честных YAML)

Имена `prior/` — определения `/tmp/dev-harness-verify/Critic116sol3/mutate.py`, `arb/` — определения `/tmp/dev-harness-verify/Arbiter116/zamer.py`, применённые заново **к собственной копии OBJECT**; `new/` — `/tmp/dev-harness-verify/Critic116sol5/mutants.py`, не клетки автора. Значения ниже — реально возвращённые причины `PRICHINA` из stderr checker, все красные имеют rc1, все зелёные rc0.

| Мутант | Результат и причина |
|---|---|
| prior/old_duplicate_early; child_early_root_late; own_assert_between_two | красный `FLOW_SNIMOK_DUBL`, `FLOW_ASSERT_POSLE_KADRA` (child ещё `FLOW_ASSERT_V_CHUZHOM_FAJLE`) |
| prior/foreign_assert_before_own | красный `FLOW_ASSERT_POSLE_KADRA` |
| prior/same_name_two_children | красный `FLOW_SNIMOK_DUBL`×2, `FLOW_ASSERT_V_CHUZHOM_FAJLE`×2 |
| prior/root_assert_child_shot; child_shot_root_assert_after | красный `FLOW_ASSERT_V_CHUZHOM_FAJLE` |
| prior/unlisted_screenshot_no_assert; unlisted_duplicate | красный `FLOW_SNIMOK_VNE_MANIFESTA` (duplicate ещё `FLOW_SNIMOK_DUBL`) |
| prior/assert_only_comment | красный `FLOW_BEZ_DOSTIZHENIJA` |
| prior/assert_only_literal; shot_only_literal | красный `FLOW_SHAG_VNE_GRAMMATIKI` (первый также `FLOW_BEZ_DOSTIZHENIJA`, второй `SELEKTOR_NE_KADRA`) |
| prior/when_runflow_false; when_inline_runflow_false; repeat_root_screenshot | красный **по G1** `FLOW_SHAG_VNE_GRAMMATIKI`, а не случайный `RUNFLOW_BEZ_FAJLA`; repeat дополнительно `SELEKTOR_NE_KADRA` |
| prior/v01_send_before_input; draft_sent_before_observe; v02_no_negative_completed | красный соответственно `SCENARIJ_VVOD_POSLE_OTPRAVKI`, `SCENARIJ_OTPRAVKA_V_CHERNOVIKE`, `SCENARIJ_BEZ_NEGATIVA` |
| prior/pending_before_attach | зелёный rc0, специально вне статической батареи по арбитражу §2 |
| arb/honest; arb/c3_pending_before_attach | зелёные rc0, честный контроль / то же исключение |
| arb/c3_unlisted_screenshot_no_assert; c3_assert_only_literal; c3_repeat_root_screenshot | красные соответственно `FLOW_SNIMOK_VNE_MANIFESTA`, `FLOW_SHAG_VNE_GRAMMATIKI`+`FLOW_BEZ_DOSTIZHENIJA`, `FLOW_SHAG_VNE_GRAMMATIKI`+`SELEKTOR_NE_KADRA` |
| arb/c3_v01_send_before_input; c3_draft_sent_before_observe; c3_v02_no_negative_completed; c3_root_assert_child_shot | красные соответственно `SCENARIJ_VVOD_POSLE_OTPRAVKI`, `SCENARIJ_OTPRAVKA_V_CHERNOVIKE`, `SCENARIJ_BEZ_NEGATIVA`, `FLOW_ASSERT_V_CHUZHOM_FAJLE` |
| arb/a_assert_tap_shot | красный `FLOW_DEJSTVIE_MEZHDU_ASSERTOM_I_SNIMKOM` |
| arb/a_repeat_shot_then_tap; a_retry_shot_only; a_assert_in_nested_runflow_inline_commands; a_shot_literal_in_root_comment_like_flow | красные `FLOW_SHAG_VNE_GRAMMATIKI` (первые также `SELEKTOR_NE_KADRA`, последние также `FLOW_BEZ_DOSTIZHENIJA`) |
| arb/a_f0507_send_after_observe; a_v01_input_only_in_root_then_send | красные `SCENARIJ_OTPRAVKA_V_CHERNOVIKE`, `SCENARIJ_VVOD_POSLE_OTPRAVKI` |
| new/old_r4_hidekeyboard; old_r4_input | **красные** `FLOW_BEZ_DOSTIZHENIJA:mission-f05-05` — оба обхода F1 r4 закрыты своим предикатом |
| new/old_r4_v02_negative; old_r4_v01_positive | **красные** `SCENARIJ_BEZ_NEGATIVA:mission_response_completed`, соответственно `BEZPNG_BEZ_TESTID_V_POTOKE`+`SCENARIJ_BEZ_SVOEJ_TESTID` — обход F3 r4 закрыт |
| new/hash_inside_quoted_input; double_hash_comment; shot_line_comment_assert; runflow_line_comment_assert; quoted_hash_and_comment; quoted_command_literal; escaped_quote_input | красные `FLOW_BEZ_DOSTIZHENIJA:mission-f05-05`: написанное в строке допустимого `inputText`/комментарии/кавычках или на строках `takeScreenshot`/`runFlow` собственным assert не становится |
| new/hash_without_space | красный `FLOW_SHAG_VNE_GRAMMATIKI:mission.yaml:33` **и** `FLOW_BEZ_DOSTIZHENIJA` |
| new/inline_map_comment_filename (`runFlow: {file: mission-state-v01.yaml # y}`) | красный `FLOW_SHAG_VNE_GRAMMATIKI:mission.yaml:40`, также `BEZPNG_SCENARIJ_NE_ZAPUSCHEN` — не ошибочный `RUNFLOW_BEZ_FAJLA` |
| new/comment_between_assert_and_shot; shot_line_verified_comment; отдельно `header_quoted_hash` | **зелёные** rc0: самостоятельный комментарий, inline-комментарий `# verified` и `#` внутри кавычек шапки не ломают честный сценарий |
| отдельно `header_unquoted_comment` | красный `FLOW_SHAG_VNE_GRAMMATIKI:mission.yaml:2` — вне закрытой G1-формы шапки |

### Сырой вывод адресных контрольных команд

```text
$ bash fixtures/workshop_project/mission_116/red_mission_116.sh --model
CASE proiskhozdenie-kommentarij-asserta ok
CASE proiskhozdenie-literal-assert-v-kavychkah ok
CASE proiskhozdenie-negativ-v02-v-kommentarii ok
CASE proiskhozdenie-nabljudenie-v01-v-kommentarii ok
CASE proiskhozdenie-kommentarij-v-shapke ok
CASE proiskhozdenie-kommentarij-mezhdu-assertom-i-snimkom ok
KADR	F05.01 dark	1.000	0.600	G	OK
KADR	F05.02 dark	1.000	0.600	G	OK
KADR	F05.03 dark	1.000	0.600	G	OK
KADR	F05.04 dark	1.000	0.600	G	OK
KADR	F05.05 dark	1.000	0.600	G	OK
KADR	F05.06 dark	1.000	0.600	G	OK
KADR	F05.V03 dark	1.000	0.600	G	OK
[exit=0; 103 CASE ok]
$ bash fixtures/workshop_project/mission_116/red_mission_116.sh --stabs
STAB s80_kommentarij_propuskaet.py proiskhozdenie-kommentarij-asserta KRASEN
STAB s80_kommentarij_propuskaet.py proiskhozdenie-literal-assert-v-kavychkah KRASEN
STAB s81_kommentarij_negativa_propuskaet.py proiskhozdenie-negativ-v02-v-kommentarii KRASEN
STAB s82_kommentarij_nabljudenija_propuskaet.py proiskhozdenie-nabljudenie-v01-v-kommentarii KRASEN
STAB s83_kommentarij_shapki_propuskaet.py proiskhozdenie-kommentarij-v-shapke KRASEN
SVJAZI 97
[exit=0; 103 CASE ok, 97 STAB KRASEN]
$ bash fixtures/workshop_project/mission_116/red_mission_116.sh --tablica
OSI	kommentarij-shaga	mission.yaml	1
OSI	kommentarij-negativa-v02	mission-state-v02.yaml	1
OSI	kommentarij-nabljudenija-v01	mission-state-v01.yaml	1
OSI	literal-v-argumente	mission.yaml	1
OSI	kommentarij-shapki	mission.yaml	1
OSI	kommentarij-mezhdu	mission.yaml	1
OSI	итого	строк=20 клеток=63 клеток-потока=63
[exit=0]
$ bash fixtures/workshop_project/mission_116/red_mission_116.sh  # isolated without_subject
SHABLON_ABSENT
CASE chestnyj-ekran KRASNO (SHABLON_ABSENT)
CASE proiskhozdenie-kommentarij-mezhdu-assertom-i-snimkom KRASNO (SHABLON_ABSENT)
[exit=1; 103 CASE KRASNO]
$ bash scripts/pre_critic.sh contracts/116-cmp-mob-005-mission.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
КРИТИК: дверь зелёная
[exit=0]
$ bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic116sol5/repo contracts/116-cmp-mob-005-mission.md
OK
[exit=0]
$ python3 /tmp/dev-harness-verify/Critic116sol5/runner123.py
CMD bash mobile/e2e-mission/e2e.sh mission rc 0 stdout '' stderr ''
CMD python3 .harness123/scripts/sverka_maketa.py --manifest .harness123/kadry.json --kadry mobile/maestro-out-mission --repo . rc 0 stdout 'KADR\tF05.01 dark\t1.000\t0.600\tG\tOK\nKADR\tF05.02 dark\t1.000\t0.600\tG\tOK\nKADR\tF05.03 dark\t1.000\t0.600\tG\tOK\nKADR\tF05.04 dark\t1.000\t0.600\tG\tOK\nKADR\tF05.05 dark\t1.000\t0.600\tG\tOK\nKADR\tF05.06 dark\t1.000\t0.600\tG\tOK\nKADR\tF05.V03 dark\t1.000\t0.600\tG\tOK\n' stderr ''
$ python3 /tmp/dev-harness-verify/Critic116sol5/controls.py
header_quoted_hash rc 0 reasons ''
header_unquoted_comment rc 1 reasons 'PRICHINA\tFLOW_SHAG_VNE_GRAMMATIKI\tmission.yaml:2\n'
quoted_hash_literal rc 1 reasons 'PRICHINA\tFLOW_BEZ_DOSTIZHENIJA\tmission-f05-05\n'
yaml_executed_own_assert 0 literal_inputText ['x # assertVisible: {id: mission_frame_f05_05}']
```

Граница решения: текст :10/:25/:37–38 связывает основной путь, G1/F1/F3 и запускаемые дочерние сценарии с именованными rc; зоны :40–53 называют исполнителей/файлы. Исход `accept` относится **только** к этому коммиту и закрытому классу арбитража, а не к приёмке пока не мигрировавшей продуктовой реализации. Сырое полное исполнение мутаций — вывод `/tmp/dev-harness-verify/Critic116sol5/mutants.py` в текущем scoped-круге; таблица не приписывает ему живого Maestro.
