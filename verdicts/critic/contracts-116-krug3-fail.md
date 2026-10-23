FAIL

Предмет: закоммиченный `d809a4d362cc317fa513d7011af5a6270b961c25` (116 r5), контракт `contracts/116-cmp-mob-005-mission.md`. Круг 3 — scoped-микро-круг по РЕШЕНИЮ арбитра `0259fb0088d92c9a34f6427c0ceb428078dfe98e`, §4. КЛАСС: КОДОВЫЙ. Набор полон: предмет, rc-критерий, исполнители, ЗОНА-строки присутствуют на OBJECT.

Круги 1–2 закрыты рамкой арбитра: принятые 24 исходных входа, пины семи PNG, слово владельца «б», зоны и pre_critic не переоткрывались. Здесь проверены только новая исполняемая семья, её пин/проводка, изменённый текст и батарея 116. Старый спор о статическом суде семантики не возобновляется. Два блокера ниже — измеренные обходы механизма (а)–(г), а не требование нового предмета. По §4 решения арбитра новый арбитраж не требуется; исправление возвращается автору.

## Блокирующие находки

БЛОКИРУЕТ contracts/116-cmp-mob-005-mission.md:39 — пинованная исполняемая семья не доказывает снятие НЕОТПРАВЛЕННОГО черновика при новой теме, которое входит в предмет `:10`. Клетка `NEW_TOPIC_SEPARATE_INTENT` сначала отправляет текст с результатом accepted, то есть обнуляет черновик ДО смены темы; её проверка пустого поля после новой темы нечувствительна к отсутствию очистки в этом переходе. Семантическую ось нельзя считать покрытой только наличием имени клетки.
ОБХОД: в `model/conversation-screen.tsx` удалить только `handleDraft('');` из `handleNewTopic` (между `setAttachments([]);` и `setDraftUndelivered(false);`). Пин пробы не изменён. Полная пинованная семья проходит rc 0, **18/18**. На том же экране жест «ввести `Privater alter Entwurf.` → composer-new-topic», без предварительной отправки, меняет mission на `MIS-NEW-42`, но оставляет приватный черновик прежней темы. Независимая временная клетка `CRITIC_NEW_TOPIC_UNSENT_DRAFT` с ожиданием пустого поля красна: rc 1, **18/19**; на исходной честной модели этот же расширенный прогон зелён: rc 0, **19/19**. Это конформная мутация, достижимая существующими портами семьи, с нарушением явно названного инварианта; не запрос дополнительного runtime/нового API.

БЛОКИРУЕТ contracts/116-cmp-mob-005-mission.md:39 — обещанный гейт product-CI (`:26`, `:38`, `:68`) не держится пробой проводки. `sud_ci_shag` в `teksty/statika_text.py:257–274` берёт текст шага только ДО строки с `mission-116.test.tsx` включительно и считает любое вхождение имени файла запуском. Легальная перестановка YAML-полей меняет вердикт без изменения семантики шага.
ОБХОД: на честном входе статической пробы оставить исходный `run: npx jest src/features/conversation/__tests__/mission-116.test.tsx`, а СЛЕДУЮЩЕЙ строкой того же шага поставить `continue-on-error: true`. Полная `statika_text.py --pack <teksty> --repo <ci-subject>` даёт rc 0, без PRICHINA; шаг больше не гейтит. Отдельно измерены два других конформных варианта с тем же rc 0: `if: false` после `run` (проба не исполняется) и `run: echo skipped # npx jest src/features/conversation/__tests__/mission-116.test.tsx` (имя осталось в shell-комментарии, Jest не запускается). Честный контроль также rc 0. Пинованный Jest-файл во всех четырёх входах байт-идентичен; штатные стабы зелёной батареи не различают эти обходы. Это проверка обязательной проводки (в), не переоткрытие допустимых ограничений статического стража JSX-формы (е).

## Собственные исполняемые замеры

Все записи — `/tmp/dev-harness-verify/Critic116r3b/`. Клон `repo` создан из `/tmp/dev-harness-verify/Architect116r5/repo`, checkout OBJECT. Собственное одноразовое `R` — копия продуктового R автора (его база заявлена 74c5993; не выдаю её происхождение за собственный git-замер), поверх заново установлены **закоммиченные** `model/conversation-screen.tsx`, `model/ui-copy.ts` и текст пробы из батареи OBJECT. Сохранён продуктовый composer с портами; `node_modules` — read-only по использованию симлинк на `/tmp/dev-harness-verify/Critic111r1/R/mobile/node_modules`; cache/TMPDIR внутри своей зоны. Чужие деревья не правились.

Команда исполнения семьи в R/mobile: `node node_modules/jest/bin/jest.js --ci --runInBand --cacheDirectory /tmp/dev-harness-verify/Critic116r3b/jest-cache --runTestsByPath src/features/conversation/__tests__/mission-116.test.tsx --json --outputFile <свой отчёт>`. Это тот же Jest и путь семьи, что у rc-команды контракта; добавлены только параметры отчёта/изоляции. Честная модель: **rc 0, 18/18**.

Три класса обходов круга 2 перенесены на исполняемую модель; каждый имеет именованный красный результат:

| Мутация | rc | Красная клетка |
|---|---:|---|
| `r2_offline_setDraft`: очистка handleDraft('') после queued_offline | 1 | QUEUED_OFFLINE_DRAFT_KEPT |
| `r2_completeMission_outside_JSX`: перед return, по responseState=interrupted вызвать completeMission, переводящий состояние в completed | 1 | INTERRUPTED_NOT_COMPLETED; RENDER_V02_INTERRUPTED |
| `r2_required_text_JSX_comment`: обязательное тело F05.07 перенесено в JSX-комментарий | 1 | RENDER_F05_07_DRAFT_FRAME |

Вторая строка — перенос наблюдаемого завершения на presentation-модель r5: локальный completeMission меняет responseState до JSX. Это не замер реального транспорта/API completeMission, которого в портах семьи r5 нет.

Дополнительно **6 классов** замера 2 арбитра (требовалось ≥3), каждый rc 1:

| Мутация | Красная клетка |
|---|---|
| `arb_double_quotes`: handleDraft("") при вложении | DRAFT_KEPT_ON_ATTACH; CONTROLLED_DRAFT_PORT |
| `arb_direct_draftStore`: прямой сброс draftStore и setInternalDraft в офлайне | QUEUED_OFFLINE_DRAFT_KEPT |
| `arb_helper`: очистка при вложении через clearDraft() | DRAFT_KEPT_ON_ATTACH; CONTROLLED_DRAFT_PORT |
| `arb_false_and`: обязательное тело F05.07 под false && | RENDER_F05_07_DRAFT_FRAME |
| `arb_display_none`: обязательный заголовок offline под display:none | RENDER_V01_QUEUED_OFFLINE |
| `arb_variable_text`: чужая строка через переменную hint внутри F05.07 | RENDER_F05_07_DRAFT_FRAME |

Итого основной независимый мутационный прогон: **9/9 красны поимённо**, не ошибки загрузки/компиляции. Это мой минимальный scoped-замер, не присвоение заявленных автором 19/19 или покрытия всех 18 клеток. Дополнительная конформная мутация новой темы проходит 18/18 — первый блокер.

Скрипты воспроизведения: `python3 /tmp/dev-harness-verify/Critic116r3b/measure.py` и `python3 /tmp/dev-harness-verify/Critic116r3b/bypasses.py`. Сырые Jest JSON/log и сводки — `evidence/`. Временная witness-клетка после прогона удалена, модель восстановлена из честного текста; пинованный файл не менялся.

## Батарея, пин, CI и область

- `bash fixtures/workshop_project/mission_116/red_mission_116.sh --model`: **rc 0, 40/40 CASE ok**, **7 KADR**, каждый 1.000 при пороге 0.600 (F05.01–F05.06, F05.V03). Это replay-модель батареи, не скриншоты живого телефона.
- Та же команда `--stabs`: **rc 0, 40/40**, **34 STAB … KRASEN**, `SVJAZI 34`, **31 стаб**, непойманных **0**. В том числе `s40_proba_otsutstvuet_propuskaet.py` / povedenie-proba-otsutstvuet, `s41_proba_podmenena_propuskaet.py` / povedenie-proba-podmenena, `s42_ci_bez_shaga_propuskaet.py` / ci-shag-otsutstvuet, `s43_ci_shag_ne_gejtit_propuskaet.py` / ci-shag-ne-gejtit — все KRASEN на объявленных входах.
- Собственная копия без `scripts/ekran_shablon.py`: безфлаговая W → **rc 1, SHABLON_ABSENT, 40 CASE KRASNO**. Не спутано с запуском на живом валидаторе.
- Независимый подсчёт структуры source.json: **40 входов = 37 красных + 3 зелёных**, **31** ключ stab_vhod / **34** связи / **7** PNG. Н-39: стабы к ветвям привязывает architect по коду, НЕ проза контракта; контракт несёт инварианты + rc-команды. Новых требований к текстовой привязке не предъявляю.
- SHA256 пинованного текста пробы, `source.json.povedenie_proba_sha256`, bytes `source.json.povedenie_proba`, `teksty/povedenie.test.stand-in.tsx` и файл в собственном R совпадают: **`2a1ec048e72e1943f5e928d33756a22f5f1a71a032ced26b29951d98ea1dfef0`**.
- Исходный шаг carrier `mobile-ci.stand-in.yml` / установленный в R `.github/workflows/mobile.yml`: `android-e2e`, `working-directory: mobile`, `run: npx jest src/features/conversation/__tests__/mission-116.test.tsx`, без continue-on-error и без if; команда совпадает с `cd mobile && npx jest …` в критерии. Это carrier будущей проводки, не уже приземлённый продуктовый шаг.
- Required-контур сверён живым `gh api repos/a3ka/Complior-mob/rules/branches/main`: required_status_checks содержит **quality** и **android-e2e**, strict=true. Поэтому выбранный job входит в required-контур. Старый endpoint `/branches/main/protection/required_status_checks` ответил 404 Branch not protected; это НЕ принято за отсутствие защиты — проверен актуальный ruleset API. Удалённый прогон новой семьи/`gh pr checks --required` не заявляю: PR новой реализации не предъявлен. Наличие required job не спасает continue-on-error/пропуск самого шага — второй блокер.
- `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic116r3b/repo contracts/116-cmp-mob-005-mission.md`: **rc 0, OK**, собственный живой bash-прогон.
- `git diff --name-only 6c20af87..d809a4d3`: **12 файлов**, все в `contracts/116-cmp-mob-005-mission.md` либо `fixtures/workshop_project/mission_116/`. Иных изменений нет.
- Blob-сверка r4→r5 контрактов и семей **111/117/118/132/133/135**: соответственно **11/26/63/40/7/37** записей `git ls-tree -r` совпадают. Тексты всех шести контрактов также совпадают с последними соответствующими frozen-тегами **111/3, 117/2, 118/1, 132/1, 133/1, 135/1**. Блобы `scripts/ekran_shablon.py` и `scripts/sverka_maketa.py` неизменны. Тег **frozen/contracts/116/** отсутствует. Воспроизведение: `python3 /tmp/dev-harness-verify/Critic116r3b/scope.py`.

## Текст и пять вопросов гейта

1. Критерий слабее предмета в точно измеренном переходе новой темы; обход приведён выше, не требование тестировать всё.
2. Команды с rc названы; их фактическая недостаточность в двух местах доказана собственными прогонами, а не чтением/вкусом.
3. K4-расхождение разрешено явно (`:10`, `:26`, `:39`): already_accepted означает уже доставленное сообщение, черновик снимается. Клетка `ALREADY_ACCEPTED_NO_DUPE` действительно проверяет пустой input и отсутствие дубля. Прежнее требование сохранять его здесь не переоткрывается.
4. Исполнители/зоны есть, r5 остаётся в зоне architect; implementer назван для экрана, composer, пачки, Maestro и mobile.yml. Границы не расширяются этим вердиктом.
5. Противоречия AGENTS.md как самостоятельного нового блокера не заявляю. Модель угроз содержит явный список НЕ ЗАЩИЩАЕТ; `:13`, `:26`, `:56`, `:65–68` больше не приписывают статической пробе суд поведения/фактического рендера. Слово владельца «б» не ослаблено: семь кадров по PNG и приёмка совпадения скриншота с макетом сохранены; четыре кадра без PNG до пакета дизайнера остаются явно принятым исключением.

Вердикт не меняет контракт/батарею/реализацию; push не выполнялся. Блокирует только два названных обхода; численные зелёные замеры выше их не отменяют.
