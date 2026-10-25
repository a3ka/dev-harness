FAIL
OBJECT=53724ea70cfb87d2d9e15e1f15b4018cc486c379

# Критик 116 v3 — один круг перед заморозкой

Основание: закоммиченный предмет `contracts/116-cmp-mob-005-mission.md` на OBJECT; `frozen/contracts/116/2` = `ccf05c7cee9f3f57781b114094e9c5ded07bbb8d`; консультация `/tmp/dev-harness-verify/astra-workflow/REPORT-116.md` §3 шаг 1 пп. 1–6, §4; reviewer `/tmp/dev-harness-verify/orch/keep116r/contracts-116-impl-v1.md` B1–B4/Z6–Z9. Прочитаны оригинальные носители, не только слова architect. Отказ касается **только контракта/критерия до заморозки**, а не суда текущего продукта. Блокеров: **4**. Отдельный арбитр по умолчанию не требуется; это первый круг v3 по новому основанию.

## Находки: обходы проверены собственными мутациями

БЛОКИРУЕТ contracts/116-cmp-mob-005-mission.md:10,25,37 — требование увидеть исчезновение pending-подписи **после** upload не удержано критерием: удаление единственного `assertNotVisible: {id: mission_chip_wird_gelesen}` из корня даёт `proverka` rc 0. `teksty/proverka_text.py:183-188` проверяет только порядок **если** отрицательная проверка существует; исполняемая клетка K7 требует `attachment-state=uploaded`, но не отсутствие подписи после upload; K18 требует подпись только до upload. PNG F05.V03 снимается **до** upload. У всей существующей батареи 63 входа остаются прежние входы, продуктовая статическая проба тоже rc 0 на мутанте.
ОБХОД: продукт сохраняет `mission_chip_wird_gelesen` и после успешного upload (при `attachment-state=uploaded`), удаляет отрицательный assert из `mobile/.maestro/mission.yaml`, оставляет переход `tapOn attachment-complete-UPL-1`, pending-assert и кадр до upload. Настоящий Maestro не ждёт исчезновения подписи, Jest K7/K18 и пиксельный кадр до upload не проверяют этот переход; все названные rc могут быть зелёными при невыполненной фазе V03. Замер: `negative_assert_removed rc=0 (none)`; e2e stand-in rc 0, proverka rc 0, statika rc 0. Эмулятор на этом мутанте не запускался: конкретное состояние продукта — логический контрпример к составу проверяемых предикатов, а не заявка о выполненном product-CI.

БЛОКИРУЕТ contracts/116-cmp-mob-005-mission.md:10,13,25,37 — независимый сценарий V01 не обязан **совершить отправку/получить offline-исход**, достаточно стартовых маркеров и видимого testID. Мутация удаляет `tapOn mission_send` из `mission-state-v01.yaml`: `proverka rc=0`, `statika rc=0`; существующие кейсы `--model/--stabs` не включают это дерево. `teksty/proverka_text.py:264-273` проверяет наличие launchApp/Start, а `:253-255` ищет testID в объединении детей, не действие и причинный исход в конкретном ребёнке. Поле `scenarij` проверяется только как существующий путь.
ОБХОД: в продукте V01 показывает `mission_queued_offline` из предварительно загруженного offline-состояния при входе (или всегда), в сценарии нет отправки/перехода в очередь, затем один `assertVisible` проходит; остальные сценарии и фиксированный Jest с замоканным `queued_offline` оставлены. Корневая e2e и статические проверки зелёные, а независимое достижение V01 **действием отправки** не предъявлено. Собственный `child_no_action rc=0`; sibling `orphan_v01_relocated_assert rc=0` удаляет runFlow ребёнка V01 и переносит его assert в ребёнка F05.07, при этом checker принимает «состояния в своих дочерних сценариях». Живое достижение этого подменного runtime не заявлено проверенным.

БЛОКИРУЕТ contracts/116-cmp-mob-005-mission.md:25,37 — `assertVisible` селектора кадра допустим **после** `takeScreenshot`; требование «перед каждым» не доказано названной командой. `teksty/proverka_text.py:119-126` ищет assert где-нибудь в раскрытом потоке, индекс screenshot используется лишь для наличия любого предшествующего перехода. Замер `screenshot_after_assert` (имя теста историческое, фактически `takeScreenshot` переставлен ПЕРЕД assert кадра F05.05) → `proverka rc=0`.
ОБХОД: продукт снимает F05.05 до подтверждения `mission_frame_f05_05`, а затем делает assert; экран к моменту снимка уже выглядит как PNG с оценкой ≥0.600, но testID кадра ещё не появился (например, запаздывает его объявление), после снимка появляется и Maestro проходит. Продуктовый rc и численный 123 зелёные; свой assert **перед** кадром отсутствует, хотя контракт его требует. Для штатного снимка runner 123 наблюдал 7×1.000, не измерял это изменённое время runtime.

БЛОКИРУЕТ contracts/116-cmp-mob-005-mission.md:13,25,37 — новое поле `scenarij` заявляет привязку конкретного состояния к **своему** ребёнку, но checker не сверяет поле с раскрытыми `runFlow`/testID по конкретному ребёнку: `teksty/proverka_text.py:253-271` ищет testID в агрегате, а для файла из манифеста — лишь запуск/Start. Замер `manifest_swapped_children`: у F05.V01 `scenarij` указывает `mission-state-f05-07.yaml`, собственный V01-файл остался в корне; proverka rc 0, statika rc 0, stand-in e2e rc 0.
ОБХОД: все четыре настоящие Maestro-сценария исполняются и продуктовые Jest/скриншоты зелёные, но `sostojanija_bez_png.json` для V01 указывает сценарий F05.07 (без offline-исхода). Декларированная связь «кадр → свой ребёнок» ложна при всех названных rc, потому что валидатор принимает существование чужого дочернего файла вместо его отношения к данному состоянию.

СОВЕТ contracts/116-cmp-mob-005-mission.md:18,24 — у нового B02t `elementy.composer` указан `[0,560,390,700]`, а реально яркий CTA находится в x330–373, y709–752; `navigacija [0,700,390,824]` захватывает этот CTA. Это не сдвиг на единицы pt. Однако замер удаления именно CTA даёт `KADR F05.03 dark 0.000 0.600 composer NIZHE_POROGA` (margin сетки 123 всё-таки ловит отсутствие), поэтому **обход не установлен** и совет не блокирует. Маска `[0,540,390,824]` снята, худшая область и порог сохранены.

## Сверка с поручением Astra и границами

| Scope | статус | привязка / доказательство |
|---|---|---|
| (1) §3 шаг 1 пп. 1–6, ничего сверх | Частично: предмет/носители/разрешение предъявлены; смысл сценариев не доказан | `contracts/116-cmp-mob-005-mission.md:2,10,13,16,18,25,40-53`; `fixtures/workshop_project/mission_116/teksty/{flow.yaml,mission-state-f05-07.yaml,mission-state-v01.yaml,mission-state-v02.yaml,mission-state-v04.yaml,proverka_text.py}`; `git diff --name-only 8ffa2c066..53724ea70`: только контракт + каталог mission_116 (41 путь), никаких правок продукта/132/123/117/118/B2/S2–S4. Коммит 53724ea70 имеет требуемую дословную строку `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` в теле; bcaab6d меняет только fixture. |
| (2) нет ослабления v2/тафтологии | **Нет, критерий слабее заявленного v3**, четыре обхода выше | Инв.4 v2 `frozen/contracts/116/2:25` не удалена, уточнена в v3 `:25`; исполняемая K18 `teksty/povedenie.test.stand-in.tsx:436-444` sha256 `dab2efebea58f15c92a76989436d4a23d97fc72d9238f9c7efa816606438dac9`, старая s29–s47 не изменена; s19–s28 регенерированы, s52–s62 новые. Положительный честный пример `flow.yaml` существует и проходит, но недосужены причинные переходы и порядок. |
| (3) ≥8 новых мутаций и S1 | **Выполнено, выявлены зелёные обходы** | 18 независимых вариантов + 3 проверки порядка на своих сборках в `scratch/`; таблица ниже; S1 `comment_instead_tap` красен. |
| (4) свои scoped замеры | **Выполнено с указанным пределом** | `--model rc0 63/63 + 7 KADR`; `--stabs rc0 63/63, 50 KRASEN/50, SVJAZI 50`; W без 132 `rc1 SHABLON_ABSENT, KRASNO 63`; `pre_critic rc0`; `check_precision_gate rc0 OK`; `verify_antiplacebo --scope check_zones rc0, 42/42`; 123 rc0, 7×1.000, нет MAKET_PODMENEN; jq независимо 63=13+23+27, 10 green/53 red, 46 stubs/50 связей. Предварительно ошибочный selector `--scope ekran_shablon` → rc1: это субъект/НЕ БАРЬЕР, не scope-key; затем применён действительный `check_zones`. |
| (5) макетные пины/геометрия | Пины и порог подтверждены, bbox неточен (совет) | `source.json` 3 sha равны собственным файлам и бинарникам `origin/main @1e9bcc59` ранее клонированного `Rev116c/mob`; `B02=eb4c4cf8…81db`, `B02t=727ee59e…063c9a`, `B09=ed7627cc…8294`; изображениями осмотрены 3 PNG; PIL полоса B02t y560–690 почти пустая (nonblack 0.005), CTA y709–752; 123 на снимке с вырезанным CTA красен 0.000. **Собственный SSH-клон `git clone ssh://git@github.com/a3ka/Complior-mob.git .../product` отвергнут `Repository not found` rc128**, поэтому независимый сетевой main не подтверждён, использован уже существующий read-only `origin/main` другого клона; это предел, не выдуманное подтверждение. |

## Независимые мутанты против продуктовой proverka (rc0 — ЗЕЛЁНЫЙ)

| мутация | результат |
|---|---|
| honest | ЗЕЛЁНЫЙ rc0 |
| orphan_v01_relocated_assert | **ЗЕЛЁНЫЙ rc0** |
| manifest_swapped_children | **ЗЕЛЁНЫЙ rc0** |
| extra_child_not_run (лишний файл, не из четырёх заявленных) | ЗЕЛЁНЫЙ rc0, не самостоятельный блокер |
| child_no_start | красный rc1 RUNFLOW_SCENARIJ_BEZ_START_VHODA |
| missing_runflow | красный rc1 RUNFLOW_BEZ_FAJLA, BEZPNG_BEZ_TESTID_V_POTOKE |
| cyclic_runflow | красный rc1 RUNFLOW_CIKL |
| negative_before_upload | красный rc1 FLOW_CHIP_NEG_DO_UPLOADA |
| no_upload | красный rc1 FLOW_BEZ_UPLOAD_PEREHODA |
| comment_instead_tap (S1 предыдущего круга) | красный rc1 FLOW_BEZ_CHERNOVIKA, FLOW_CHERNOVIK_POSLE_VLOZHENIJA |
| no_child_v01_jest_only | красный rc1 BEZPNG_BEZ_TESTID_V_POTOKE |
| deep_link_instead_start | красный rc1 FLOW_BEZ_START_VHODA |
| tail_without_actions | красный rc1 BEZPNG_V_KORNE ×2 |
| upload_wrong_identifier | ЗЕЛЁНЫЙ rc0 (не блокирует отдельно: тест K7 всё равно требует UPL-1) |
| no_positive_after_upload | красный rc1 FLOW_BEZ_V03_POSLE_UPLOADA |
| negative_assert_removed | **ЗЕЛЁНЫЙ rc0** |
| pending_assert_wrong_order | красный rc1 FLOW_CHIP_POSLE_UPLOADA |
| child_no_action | **ЗЕЛЁНЫЙ rc0** |
| takeScreenshot до собственного assert | **ЗЕЛЁНЫЙ rc0** |
| upload до attach | красный rc1 FLOW_CHIP_POSLE_UPLOADA |
| pending-assert до attach | ЗЕЛЁНЫЙ rc0 (не отдельный блокер) |

Область исполнения: `contracts/116-cmp-mob-005-mission.md:40-53` называет architect/critic/adversary/reviewer/implementer; все изменённые файлы в зоне architect, производные дети продукта — в `mobile/.maestro/`, носители — в `mobile/e2e-mission/`, шаг — в `.github/workflows/mobile.yml`. Проход `pre_critic` и `check_precision_gate` подтверждён прямыми командами; противоречий `AGENTS.md` вне перечисленных обходов не установлено. Модель угроз имеет `ЗАЩИЩАЕТ` и `НЕ ЗАЩИЩАЕТ`, но обещанная защита от мёртвых переходов не доказана своим критерием (блокеры выше).

### Сырые короткие замеры вне батареи

```text
$ bash scripts/pre_critic.sh contracts/116-cmp-mob-005-mission.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
КРИТИК: дверь зелёная
rc=0
$ bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic116sol/repo contracts/116-cmp-mob-005-mission.md
OK
rc=0
$ python3 scripts/sverka_maketa.py --manifest scratch/honest/pack/kadry.json --kadry scratch/honest/repo/mobile/maestro-out-mission --repo scratch/honest/repo
KADR	F05.01 dark	1.000	0.600	G	OK
KADR	F05.02 dark	1.000	0.600	G	OK
KADR	F05.03 dark	1.000	0.600	G	OK
KADR	F05.04 dark	1.000	0.600	G	OK
KADR	F05.05 dark	1.000	0.600	G	OK
KADR	F05.06 dark	1.000	0.600	G	OK
KADR	F05.V03 dark	1.000	0.600	G	OK
rc=0
$ bash scripts/verify_antiplacebo.sh --scope check_zones
SCOPED: барьеров 1 из выборки — не для приёмки
барьеров: 1 · фикстур: 42 · предъявлено красным повторным прогоном: 42
rc=0
```

Следующие три блока — **дословные stdout/stderr и rc** независимого последовательного прогона W на моей копии; без эмулятора и без product-CI. У `scripts/ekran_shablon.py` в replay-stand-in после второго e2e даже честный вход отдаёт `KADR_USTAREVSHIJ ×7` (фиксированный timestamp); это ограничение replay, не доказательство, что моя мутация прошла продуктовую 132. Приведённые зелёные мутанты измерены прямым продуктовым checker + statika + stand-in e2e и логически конкретным недостающим runtime-предикатом, а не выданы за зелёный запуск эмулятора.

#### W model: полный сырой вывод

```text
$ bash fixtures/workshop_project/mission_116/red_mission_116.sh --model
rc=0
stdout:
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
KADR	F05.01 dark	1.000	0.600	G	OK
KADR	F05.02 dark	1.000	0.600	G	OK
KADR	F05.03 dark	1.000	0.600	G	OK
KADR	F05.04 dark	1.000	0.600	G	OK
KADR	F05.05 dark	1.000	0.600	G	OK
KADR	F05.06 dark	1.000	0.600	G	OK
KADR	F05.V03 dark	1.000	0.600	G	OK
stderr:
```

#### W stabs: полный сырой вывод

```text
$ bash fixtures/workshop_project/mission_116/red_mission_116.sh --stabs
rc=0
stdout:
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
SVJAZI 50
stderr:
```

#### W plain: полный сырой вывод

```text
$ bash fixtures/workshop_project/mission_116/red_mission_116.sh
rc=1
stdout:
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
stderr:
```
