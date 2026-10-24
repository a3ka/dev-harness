FAIL
OBJECT=e7807024c3211875a5686fc0595011e0b2076305

# Ревью 116 (CMP-MOB-005, Mission) — реализация, круг 1 (reviewer, Rev116c)

Предмет: PR a3ka/Complior-mob#122, ветка `cmp-mob-116/mission` @ e7807024 (свежий SSH-клон
`/tmp/dev-harness-verify/Rev116c/mob`). Контракт: `frozen/contracts/116/2` → ccf05c7c
(`contracts/116-cmp-mob-005-mission.md`). H-пин пачки `.harness116` = ccf05c7c
(клон `/tmp/dev-harness-verify/Rev116c/H`), совпадает с коммитом тега.
`accept`/`FAIL` здесь — суд реализации, НЕ разрешение на merge.

## Основание FAIL (коротко)

1. **B1 — блокер (обход статической строки).** `mobile/.maestro/mission.yaml` не может пройти
   на этом экране. Проверка происхождения (`FLOW_*`, Инв. 4 «кадры без PNG — своими testID в
   потоке») зелёная по всему, кроме селектора 118. При этом шаг `assertNotVisible
   mission_chip_wird_gelesen` (yaml:35) ложен в любой конфигурации портов. Хвост yaml:43–47
   требует состояний `sendState`, которые в одном прогоне взаимно исключают друг друга.
   Замер: replay шагов флоу на продукте — 12/12 конфигураций красные. Шаг mission-ekran
   останется красным и после 118, по причине, не зависящей от 118.
2. **B2 — блокер (норма 050, ACCIDENTAL).** Порты A01/A02/A03 добавлены в общий композер 108,
   но у них нет потребителя. Более простая форма (композер как на main) проходит те же строки
   приёмки — замерено.
3. **B3 — дефект, предсказанный красный (не обход).** На OBJECT устарели пины 3 из 7 макетов
   в `kadry.json`: после слияния main (дизайн-пакет 3) сверка 123 даёт `MAKET_PODMENEN` для
   F05.02, F05.03 и F05.V03 — независимо от эмулятора.
4. **B4 — сверка с макетом.** Кадров mission с эмулятора нет. По норме владельца
   2026-10-20 вердикт по мобильному экрану — FAIL «нечем сверить». Сверка по доступному
   (прозаичный рендер против PNG) показывает расхождения состава: см. раздел ниже.

Судимая часть, которая ЧИСТА (замерено своей мерой): зона правки, байт-пины семьи и носителей,
поведение 19 клеток и их краснота на мутантах продукта, CI-шаг семьи и runtime-строка :38,
дословность шагов 995/108/111/117/135 (с оговоркой S5), копия F05 побайтово по каталогу.

## Замеры (команда → сырой вывод)

### Z1. Область правки
```
$ git -C mob log --oneline origin/main..HEAD
e780702 116: починить разбор mission.yaml и вынести его из общего прогона каталога
04b0ece Merge remote-tracking branch 'origin/main' into cmp-mob-116/mission
640b9f4 116 v2 (n116-tsc-batareja): миграция принятого оракула в продукт
ec6210e 116 (CMP-MOB-005): экран беседы Mission — поведение issue #9, состояния без PNG, пачка e2e-mission и CI-шаг
$ git -C mob merge-base origin/main HEAD ; git -C mob rev-parse origin/main
1e9bcc59a2d0df2fbf16aa97a5108f1f74e801cf
1e9bcc59a2d0df2fbf16aa97a5108f1f74e801cf
$ git -C mob diff --stat origin/main...HEAD
.github/workflows/mobile.yml                        |  35 ++
mobile/.maestro/config.yaml                         |  15 +
mobile/.maestro/mission.yaml                        |  47 ++
mobile/e2e-mission/batareja/proverka_proiskhozdenija.py | 195 +++
mobile/e2e-mission/batareja/red_ekrana.sh           |   3 +
mobile/e2e-mission/e2e.sh                           |  27 ++
mobile/e2e-mission/ekran.json                       |  73 ++
mobile/e2e-mission/kadry.json                       | 478 ++++
mobile/e2e-mission/katalog_kopii.json               |  98 ++
mobile/e2e-mission/kontrakt.md                      |  30 ++
mobile/e2e-mission/sostojanija_bez_png.json         |  58 ++
mobile/e2e-mission/spec_api.json                    |  32 ++
.../conversation/__tests__/mission-116.test.tsx     | 444 ++++
.../features/conversation/conversation-screen.tsx   | 429 ++++
mobile/src/features/conversation/ds-class-name.ts   |  12 +
mobile/src/features/conversation/mission-copy.ts    | 113 +++
.../conversation-composer.tsx                       |  40 +-
17 files +2128 -1
```
Все 17 файлов лежат в ЗОНЕ implementer. Docs/ux пришли слиянием main (04b0ece), это не правка
предмета. Нормативные документы не тронуты. Коммиты атомарны по предмету: ec6210e — сам
предмет, 640b9f4 — миграция v2, e780702 — фикс разбора, плюс merge.

### Z2. Байт-пины (семья, носители) — своя мера sha256
```
$ sha256sum (mob/mobile ↔ H/fixtures/workshop_project/mission_116/teksty)
dab2efebea58f15c92a76989436d4a23d97fc72d9238f9c7efa816606438dac9  src/features/conversation/__tests__/mission-116.test.tsx
dab2efebea58f15c92a76989436d4a23d97fc72d9238f9c7efa816606438dac9  povedenie.test.stand-in.tsx
9348a377…6a65  e2e-mission/batareja/proverka_proiskhozdenija.py  = 9348a377…6a65 proverka_text.py
ebad3183…8b25  e2e-mission/batareja/red_ekrana.sh               = ebad3183…8b25 batareja_text.sh
f98ce2dc…a89a73 e2e-mission/kontrakt.md                          = f98ce2dc…a89a73 kontrakt.md
72006d35…7115  e2e-mission/sostojanija_bez_png.json             = 72006d35…7115 sostojanija_bez_png.json
```
Пин из критерия (dab2efeb…dac9) совпадает. Тесты и фикстуры автором под код не переписаны
(п. 3 роли).

### Z3. Семья Jest 19/19 поимённо + своя мера количества
```
$ cd mobile && npx jest src/features/conversation/__tests__/mission-116.test.tsx --ci --verbose
  ✓ CONVERSATION_STRUCTURE_DARK ✓ CONVERSATION_STRUCTURE_LIGHT ✓ SEND_SAME_MISSION_AND_DRAFT_CLEARED
  ✓ ALREADY_ACCEPTED_NO_DUPE ✓ DRAFT_KEPT_ON_ATTACH ✓ CONTROLLED_DRAFT_PORT ✓ ATTACH_PENDING_NOT_READ
  ✓ UPLOAD_GATE_AND_RETRY_NO_DUPE ✓ QUEUED_OFFLINE_DRAFT_KEPT ✓ INTERRUPTED_NOT_COMPLETED
  ✓ NEW_TOPIC_SEPARATE_INTENT ✓ NEW_TOPIC_DRAFT_KEPT ✓ REVOKED_SOURCE_CLOSED ✓ DRAFT_SURVIVES_REMOUNT
  ✓ RENDER_F05_07_DRAFT_FRAME ✓ RENDER_V01_QUEUED_OFFLINE ✓ RENDER_V02_INTERRUPTED
  ✓ RENDER_V04_ALREADY_ACCEPTED ✓ RENDER_V03_CHIP_LESET
Tests:       19 passed, 19 total            (exit 0)
$ grep '^\s*(it|test)\(' mission-116.test.tsx   → 19 строк (150,167,178,202,217,229,244,256,273,288,296,316,330,363,377,388,404,418,436)
$ npx jest --ci                             → Test Suites: 5 passed; Tests: 41 passed, 41 total (exit 0)
$ npm run typecheck                         → typecheck rc=0
```

### Z4. Красное предъявлено на ПРОДУКТЕ (мутанты conversation-screen.tsx, scratch/mutants.py)
```
MUTANT already_accepted_keeps_draft  rc=1 Tests: 1 failed, 18 passed, 19 total FAILED=ALREADY_ACCEPTED_NO_DUPE
MUTANT already_accepted_appends_dupe rc=1 Tests: 2 failed, 17 passed, 19 total FAILED=ALREADY_ACCEPTED_NO_DUPE,RENDER_V04_ALREADY_ACCEPTED
MUTANT new_topic_keeps_draft         rc=1 Tests: 1 failed, 18 passed, 19 total FAILED=NEW_TOPIC_DRAFT_KEPT
MUTANT attach_clears_draft           rc=1 Tests: 2 failed, 17 passed, 19 total FAILED=CONTROLLED_DRAFT_PORT,DRAFT_KEPT_ON_ATTACH
MUTANT revoked_shown                 rc=1 Tests: 1 failed, 18 passed, 19 total FAILED=REVOKED_SOURCE_CLOSED
MUTANT chip_suffix_dropped           rc=1 Tests: 5 failed, 14 passed, 19 total FAILED=ATTACH_PENDING_NOT_READ,…,RENDER_V03_CHIP_LESET,…
(файл восстановлен: sha256 a76826df…a670 = HEAD)
```

### Z5. Статическая проба, носители, проверка происхождения, валидатор 132
```
$ python3 H/…/mission_116/teksty/statika_text.py --pack mobile/e2e-mission --repo .   → rc=0
$ cmp mobile/e2e-mission/batareja/proverka_proiskhozdenija.py H/…/teksty/proverka_text.py → rc=0
$ cmp mobile/e2e-mission/batareja/red_ekrana.sh H/…/teksty/batareja_text.sh            → rc=0
$ python3 mobile/e2e-mission/batareja/proverka_proiskhozdenija.py --pack mobile/e2e-mission --repo . --harness H
PRICHINA	SELEKTOR_BEZ_EKRANA	start_tab_start
PRICHINA	SELEKTOR_BEZ_EKRANA	start_tab_start
rc=1        (зависимость: вход Start — предмет 118; в продукте вкладка shell-tab-start)
$ python3 H/scripts/ekran_shablon.py --pack mobile/e2e-mission --repo . --harness H
PRICHINA	SHABLON_NEVEREN	нет каталога: mobile/maestro-out-mission
rc=2        (e2e.sh без MISSION_SERIAL/эмулятора; NOT_RUN)
```

### Z6. Сверка 123 на OBJECT без эмулятора — пины макетов (B3)
```
$ python3 H/scripts/sverka_maketa.py --manifest mobile/e2e-mission/kadry.json --kadry scratch/kadry-empty --repo .
KADR_OTSUTSTVUET	F05.01 dark
MAKET_PODMENEN	F05.02 dark	sha256
MAKET_PODMENEN	F05.03 dark	sha256
KADR_OTSUTSTVUET	F05.04 dark
KADR_OTSUTSTVUET	F05.05 dark
KADR_OTSUTSTVUET	F05.06 dark
MAKET_PODMENEN	F05.V03 dark	sha256
rc=1
$ sha256sum docs/ux/03_Mobility_Slice1/screens/{B02,B02t,B09}.png
eb4c4cf8…81db B02.png   (kadry.json и H source.json: e0ea9bce…4d91)
727ee59e…9c9a B02t.png  (kadry.json и H source.json: 2446b2ba…77b2)
ed7627cc…94e9 B09.png   (kadry.json и H source.json: 99beda42…f367)
$ scratch/dims.py: размеры не изменились (B02/B02t 390x844, B09 390x991); до слияния 04b0ece^1 sha совпадали с пинами.
```

### Z7. Replay флоу mission.yaml на продукте (B1, scratch-тест удалён после замера)
Шаги mission.yaml повторены через RNTL с теми же testID: changeText композера → press
mission_attach → press mission_attachment_foto → проверка chip → press mission_send → хвост.
Перебор: SendStatus × responseState × turns (с ответом агента и Quelle и без).
```
REPLAY accepted/idle/baseline        ALL_FLOW_ASSERTIONS=false :: assertNotVisible(chip_wird_gelesen)=false f05_06=false f05_07=false queued_offline=false interrupted=false already_accepted=false
REPLAY accepted/idle/answered        ALL_FLOW_ASSERTIONS=false :: assertNotVisible(chip_wird_gelesen)=false f05_05=false f05_07=false queued_offline=false interrupted=false assertNotVisible(completed)=false already_accepted=false
REPLAY accepted/interrupted/baseline ALL_FLOW_ASSERTIONS=false :: assertNotVisible(chip_wird_gelesen)=false f05_05=false f05_06=false f05_07=false queued_offline=false already_accepted=false
REPLAY accepted/interrupted/answered ALL_FLOW_ASSERTIONS=false :: assertNotVisible(chip_wird_gelesen)=false f05_05=false f05_07=false queued_offline=false already_accepted=false
REPLAY already_accepted/idle/baseline        … assertNotVisible(chip_wird_gelesen)=false f05_05=false f05_06=false f05_07=false queued_offline=false interrupted=false
REPLAY already_accepted/idle/answered        … assertNotVisible(chip_wird_gelesen)=false f05_05=false f05_07=false queued_offline=false interrupted=false assertNotVisible(completed)=false
REPLAY already_accepted/interrupted/baseline … assertNotVisible(chip_wird_gelesen)=false f05_05=false f05_06=false f05_07=false queued_offline=false
REPLAY already_accepted/interrupted/answered … assertNotVisible(chip_wird_gelesen)=false f05_05=false f05_07=false queued_offline=false
REPLAY queued_offline/idle/baseline          … assertNotVisible(chip_wird_gelesen)=false f05_05=false f05_06=false f05_07=false interrupted=false already_accepted=false
REPLAY queued_offline/idle/answered          … assertNotVisible(chip_wird_gelesen)=false f05_05=false f05_07=false interrupted=false assertNotVisible(completed)=false already_accepted=false
REPLAY queued_offline/interrupted/baseline   … assertNotVisible(chip_wird_gelesen)=false f05_05=false f05_06=false f05_07=false already_accepted=false
REPLAY queued_offline/interrupted/answered   … assertNotVisible(chip_wird_gelesen)=false f05_05=false f05_07=false already_accepted=false
Tests: 12 passed (замер-лог), 0/12 конфигураций проходят флоу
```
Код (conversation-screen.tsx):
- :354–358 — чип «wird gelesen» рендерится при любом `attachment_pending`. Снять его может
  только нажатие `attachment-complete-*`, а такого шага во флоу нет.
- :267/:273/:281 — F05.07, queued_offline и already_accepted завязаны на одно значение
  `sendState`. После последнего действия пользователя (tapOn mission_send) оно не меняется:
  таймеров нет, эффектов нет.

Предел: RNTL, а не эмулятор. Асинхронная смена `turns`/`responseState` из runtime может
изменить только f05_05/f05_06/interrupted/completed. На chip и на тройку `sendState` она не
влияет.

Происхождение дефекта: хвост и `assertNotVisible` дословно повторяют замороженную модель
`H/…/teksty/flow.yaml`. Модельный экран `H/…/model/conversation-screen.tsx:193–280` содержит
те же исключающие условия и тот же чип. Дефект общий для контракта и реализации, см. B1.

### Z8. Опора проверки черновика на YAML-комментарий (S1, scratch/comment_probe.py)
```
VARIANT A_comment_removed rc=1
PRICHINA	FLOW_BEZ_CHERNOVIKA	mission_composer_input
PRICHINA	FLOW_CHERNOVIK_POSLE_VLOZHENIJA	mission_composer_input
PRICHINA	SELEKTOR_BEZ_EKRANA	start_tab_start   (×2)
VARIANT B_tap_removed_comment_kept rc=1
PRICHINA	SELEKTOR_BEZ_EKRANA	start_tab_start   (×2)
```
Вывод: FLOW_BEZ_CHERNOVIKA удовлетворяет комментарий `# mission_composer_input`, а не жест.
Вариант B (tapOn убран, комментарий оставлен) статически так же зелёный. На OBJECT жест есть:
yaml:20 tapOn на mission_composer_input, затем inputText. Свойство выполнено. Слабость —
в грамматике замороженной проверки: `inputText` в Maestro не принимает id.

### Z9. Простая форма композера (B2): композер = origin/main
```
$ git checkout origin/main -- mobile/src/ui/conversation-composer/conversation-composer.tsx
$ npx jest …mission-116.test.tsx --ci → Tests: 19 passed, 19 total; jest rc=0
$ npm run typecheck                   → typecheck rc=0
$ statika_text.py …                   → statika rc=0
$ proverka_proiskhozdenija.py …       → те же 2× SELEKTOR_BEZ_EKRANA start_tab_start, rc=1 (как на OBJECT)
$ git checkout HEAD -- …              (восстановлено, status чистый)
$ grep '<ConversationComposer' mobile/src → conversation-screen.tsx:392 (только onChangeText/value), start-screen.tsx:110 — порты onSend/onAttach/onNewTopic/…Label не передаёт никто
```

### Z10. Батарея контракта W (H @ ccf05c7c)
```
$ bash fixtures/workshop_project/mission_116/red_mission_116.sh --model
CASE … ok ×51 (chestnyj-ekran … ci-steps-indentless-otstup-chetyre)
KADR	F05.01 dark	1.000	0.600	G	OK   … KADR	F05.V03 dark	1.000	0.600	G	OK   (7 строк)
rc=0
$ bash fixtures/workshop_project/mission_116/red_mission_116.sh --stabs
CASE … ok ×51 ; STAB … KRASEN ×38 (s01 … s47) ; SVJAZI 38
exit 0
```
Свой подсчёт по выводу: 51 CASE (13 форма + 8 proiskhozdenie + 3 bezpng + 8 povedenie +
4 bezpng-render + 2 proba + 13 ci), 38 STAB.

### Z11. Runtime-строка :38 (живой gh, связь одного C)
```
$ gh pr view 122 --json headRefOid,mergeStateStatus,state
{"headRefName":"cmp-mob-116/mission","headRefOid":"e7807024c3211875a5686fc0595011e0b2076305","mergeStateStatus":"CLEAN","state":"OPEN"}
$ gh pr checks 122 --repo a3ka/Complior-mob --required      (exit 0)
android-e2e	pass	11m18s	…/actions/runs/40110642935/job/120941529641
quality	pass	4m53s	…/actions/runs/40110642935/job/120941558780
$ gh api …/actions/jobs/120941529641 → head_sha e7807024…, run_attempt 11, conclusion success,
  step "116 mission behaviour render" conclusion success
$ gh api …/actions/jobs/120941529641/logs
17:43:59.5050813Z ##[group]Run npx jest src/features/conversation/__tests__/mission-116.test.tsx
17:44:00.5566685Z Test Suites: 1 passed, 1 total
17:44:00.5566950Z Tests:       19 passed, 19 total
… шаг «116 mission pack checks»: statika + 2× cmp на .harness116 @ ccf05c7c — success
$ gh api …/actions/jobs/120941558780 → head_sha e7807024; success: 108 start_static_probe.py / start_probe.py,
  111 …, 117 …, «Вынести H, батарею 117 и пачку 135…», npm test, npm run lint, npm run typecheck, npm run doctor
```
Все четыре факта строки :38 относятся к одному C = e7807024: (1) rc 0; (2) android-e2e в
required, run 40110642935/job 120941529641; (3) шаг success и `Tests: 19 passed, 19 total`;
(4) head_sha = OBJECT.

### Z12. mobile.yml: шаги 995/108/111/117/135 против main
`git diff origin/main...HEAD -- .github/workflows/mobile.yml` содержит 4 ханка, все добавления.
В существующий блок попадает ровно один из них: общий шаг
«Вынести H, батарею 117 и пачку 135 из дерева до lint», +1 строка
`mv mobile/e2e-mission …`. Прецедент: `git log -L` показывает, что 117 (abb1e3c) и
135 (74c5993) так же дописывали строку `mv` в этот шаг. Блок шага семьи
(`- name: 116 mission behaviour render` / `run: npx jest src/features/conversation/__tests__/mission-116.test.tsx`)
байт-равен пину: statika rc 0. Шаг стоит в required job android-e2e (mobile.yml:283).

### Z13. Копия F05 против каталога (scratch/copy_check.py)
```
OK action.F05.A01 … OK global.retry
ENTRIES 19 BAD 0     (text + review_status + copy_version побайтово против docs/ux/01_UX_Source_of_Truth/BrokerOS_UI_Copy_DE.json)
```

### Z14. Тег зависимости
```
$ git tag -l 'frozen/contracts/117/*' 'frozen/contracts/118/*'
frozen/contracts/117/1  frozen/contracts/117/2  frozen/contracts/117/3  frozen/contracts/118/1
```
Тег 117/3 существует. Команду проверки тега из раздела 118 «Зависимость замороженного корня»
в этом круге не гонял: NOT_RUN.

## Протокол критерия: пункт → статус → от чего зависит

| пункт критерия (контракт 116/2) | статус | от чего зависит / замер |
|---|---|---|
| W без `scripts/ekran_shablon.py` → rc 1, SHABLON_ABSENT ×51 | NOT_RUN | строка батареи (зона architect), принята критиком ccf05c7c; реализацию не судит |
| W --model → rc 0, 51/51, 7 KADR | OK | Z10 |
| W --stabs → rc 0, 51/51, 38 KRASEN, SVJAZI 38 | OK | Z10 (ORACLE_TAMPERED не гонял — NOT_RUN, строка батареи) |
| Продукт: проверка тега 117 v+1 (команда раздела 118) | NOT_RUN | тег 117/3 есть (Z14); саму команду не гонял |
| Продукт: W безфлаговый в продуктовом дереве | NOT_RUN | ленд продуктового субъекта + переключение оркестратором (строка :35) |
| Продукт: `bash mobile/e2e-mission/e2e.sh mission` rc 0 | NOT_RUN → предсказан FAIL | 118 (`start_tab_start`), шаг mission-ekran (нет на ветке; локально caeac54a, не запушен), эмулятор; НЕЗАВИСИМО от 118: B1 (флов не проходим, Z7) |
| Продукт: proverka пачки rc 0 | FAIL (rc 1) | только `SELEKTOR_BEZ_EKRANA start_tab_start` ×2 → 118 (Z5) |
| Продукт: статическая проба (страж формы) rc 0 | OK | Z5, CI-шаг «116 mission pack checks» success (Z11) |
| Продукт: jest-семья mission-116 19/19 rc 0, файл = пину | OK | Z2, Z3, Z4 |
| Продукт: Maestro-флоу product-CI зелён | NOT_RUN → предсказан FAIL | шаг mission-ekran отсутствует на ветке; 118; B1 |
| Продукт: сверка 123 ≥ 0.600 по 7 кадрам | NOT_RUN (оценки) / FAIL (пины) | кадров нет; `MAKET_PODMENEN` F05.02/F05.03/F05.V03 уже сейчас (Z6) → B3: перепин (локальный 4dec88e не запушен) + решение architect/владельца о пинах source.json замороженной батареи и bbox |
| Продукт: скриншоты = макет (состав/раскладка/отступы/шрифт/цвет) | FAIL «нечем сверить» | норма владельца 2026-10-20; кадров нет; см. «Сверка с макетом» |
| Runtime-строка :38 (gh required → job android-e2e → шаг → `Tests: 19 passed, 19 total`, один C) | OK | Z11 |
| Красные входы проводки (батарея) | OK | Z10 |
| Инв. 6: композер 108 сохранён, start_108 зелена без правок | OK (поведение) / B2 (сложность) | CI quality: «108 start_static_probe/start_probe» success на e7807024 (Z11); дифф аддитивен; порты мёртвые (Z9) |
| ПЕРЕСЕЧЕНИЕ .maestro: флоу 107/117 сохранены, добавлен mission | OK | ls-tree: флоу main не тронуты; config.yaml исключает mission из прогона каталога (шаг 995 success) |
| ПЕРЕСЕЧЕНИЕ mobile.yml: шаги 995/108/111/117 дословно, +116 | OK с оговоркой S5 | Z12 |
| Зона implementer | OK | Z1 |

## Сверка с макетом (правило мобильного экрана, слово владельца 2026-10-20)

**Кадров mission с эмулятора НЕТ**: шага mission-ekran на ветке нет, артефакта
`maestro-mission` нет. По норме вердикт по мобильному экрану — **FAIL «нечем сверить»**.
Ниже сверка по доступному: прозаичный рендер экрана в коде и jest против макетов, которые я
открыл как изображения.

Пути (макет ↔ кадр эмулятора):
- F05.01 `docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/screens/Auto-01-Zuhoeren.png` ↔ кадр отсутствует
- F05.02 `docs/ux/03_Mobility_Slice1/screens/B02.png` ↔ кадр отсутствует
- F05.03 `docs/ux/03_Mobility_Slice1/screens/B02t.png` ↔ кадр отсутствует
- F05.04 `docs/ux/03_Mobility_Slice1/screens/B02d.png` ↔ кадр отсутствует
- F05.05 `docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/screens/VS-04-Verstehe.png` ↔ кадр отсутствует
- F05.06 `docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/screens/Post-Agent-Antwort.png` ↔ кадр отсутствует
- F05.V03 `docs/ux/03_Mobility_Slice1/screens/B09.png` ↔ кадр отсутствует

Состав рендера `ConversationScreen` (conversation-screen.tsx:250–418), сверху вниз:
- блок F05.01: заголовок «Was ist passiert?» 16/600, тело, чип с `MIS-CAR-01`;
- условные блоки (F05.03, F05.07, V01, V04, F05.05, V02, маркер completed, F05.06, F05.04, V03);
- «Gesprächsverlauf» с репликами;
- композер 108 (подпись / поле / подсказка);
- ряд из трёх текстовых действий «Dokument hinzufügen · Neues Thema · Nachricht senden»;
- пустой Text `queued-offline-notice`.

Цвет задан только как `tokens.ink` на тексте и `tokens.ground` на фоне.

Расхождения с макетами по составу (без пиксельного суда; оценки — [INFERENCE] до кадров):
1. Ни в одном состоянии нет wordmark «complior» и кнопки профиля (полоса `wordmark`
   [0,36,390,60] в каждом кадре манифеста). Нет C-марки с лаймовой точкой и подписи состояния
   (полоса `sostojanie`). Есть во всех 7 макетах.
2. Композер: в макетах — «пилюля» с круглыми кнопками камеры, файла и отправки/микрофона
   (лайм). В продукте — карточка 108 с подписью, полем и подсказкой плюс отдельный ряд
   текстовых кнопок.
3. Навигация (полоса `navigacija`): нижней панели Start/Vorgänge/Schutz/Post на экране нет.
   Она ожидается от оболочки (118) — остаток 118.
4. F05.01: макет «Ich höre zu – erzählen Sie einfach.» с транскриптом. Продукт —
   «Was ist passiert?» / «Beschreiben Sie, wobei Sie Unterstützung benötigen.» по каталогу
   копии. Расхождение каталог↔макет принято допущением владельца о соответствии кадров,
   но по составу оно есть.
5. На кадре F05.01 при пустом черновике виден блок F05.07 «Nicht gesendeter Entwurf / Ihre
   Nachricht wurde noch nicht gesendet…» (`sendState` изначально `'draft'`, :267). В макете
   F05.01 этого блока нет. Семантически блок неверен: неотправленного ничего нет.
6. F05.04 (B02d): тексты пунктов совпадают («Foto aufnehmen», «Datei auswählen (PDF, JPG)»,
   «Aus Post übernehmen»). Но в макете это светлые скруглённые кнопки и есть инфо-плашка;
   в продукте — простой Text. Заголовок макета «Brief oder Dokument hinzufügen», в продукте
   по каталогу — «Datei hinzufügen».
7. Токены состояний без PNG (`className="warm on-warm panel"` и т. п.) на рантайме ИНЕРТНЫ.
   В React Native нет обработчика `className` (NativeWind/tailwind в mobile/package.json не
   найден), поэтому визуально плашки V01/V02/V04/F05.07 не получают ни фона, ни цвета
   токенов. Контракт это принимает (НЕ ЗАЩИЩАЕТ: семантика токена, пиксели кадров без PNG),
   поэтому это совет S2, а не FAIL.

## Находки

| # | класс | фрагмент | наблюдение | обход / состояние | что сделать (кому) |
|---|---|---|---|---|---|
| B1 | БЛОКЕР — обход статической строки (FLOW_*, Инв. 4) | `mobile/.maestro/mission.yaml:35` (`assertNotVisible mission_chip_wird_gelesen`), `:43–47`; `conversation-screen.tsx:267,273,281,355` | флоу на продукте непроходим: 0/12 конфигураций (Z7) | proverka/statika/jest/CI зелёные (кроме селектора 118), а связный путь предмета не исполним, и «кадры без PNG — своими testID в потоке» объявлены недостижимыми assertVisible; mission-ekran будет красным после 118 по этой причине | architect: замороженная модель flow.yaml/модельный экран содержат тот же дефект, нужна редакция Инв. 4 (переходы между состояниями или отдельные флоу; порядок chip/upload). implementer: флоу и экран под неё |
| B2 | БЛОКЕР — норма 050 ACCIDENTAL | `mobile/src/ui/conversation-composer/conversation-composer.tsx:26–36,44–49,74–91,98–99` | порты A01/A02/A03 и подписи без потребителя: экран рисует свой ряд с теми же testID `composer-*`; при передаче портов testID задвоятся | простая форма (композер = main) проходит те же строки: jest 19/19, tsc 0, statika 0, proverka — тот же исход (Z9) | implementer: откатить дифф композера ЛИБО передавать порты из экрана и убрать дублирующий ряд (одна форма) |
| B3 | ДЕФЕКТ — предсказанный красный (не обход) | `mobile/e2e-mission/kadry.json:85,150,408` | `MAKET_PODMENEN` F05.02/F05.03/F05.V03 на OBJECT (Z6); причина — слияние main с дизайн-пакетом 3 | — (ловит сверка 123) | implementer: запушить перепин (локальный 4dec88e) + пересверить bbox `elementy` по новым PNG; architect/владелец: пины тех же макетов в замороженном `source.json` батареи 116/2 устарели — решение о перепине (как допущение «меняется только пин манифеста») |
| B4 | FAIL по норме владельца (мобильный экран) | — | кадров mission с эмулятора нет | — | после 118 + B1 + B3: шаг mission-ekran, кадры обеих тем, ревью сверки по каждому кадру |
| S1 | совет (дефект грамматики проверки, architect) | `mission.yaml:25` `# mission_composer_input`; `proverka_proiskhozdenija.py:89–92` | FLOW_BEZ_CHERNOVIKA удовлетворяется комментарием; вариант без tapOn статически зелёный (Z8) | на OBJECT жест есть (tapOn :20) — свойство выполнено | architect: грамматика жеста = tapOn(id) → inputText, без подстроки в строке inputText |
| S2 | совет (остаток, принятый контрактом) | `ds-class-name.ts`, `className` блоков состояний | токены D2.2.5.1 на рантайме не применяются (п. 7 сверки) | принято НЕ ЗАЩИЩАЕТ | владелец/дизайн-пакет: при пиксельной сверке без-PNG кадров токены нужны в `style` |
| S3 | совет / риск сверки | `conversation-screen.tsx:267` | F05.07 виден при пустом черновике, попадает в кадр F05.01 | — | implementer: условие `draft.length > 0 && sendState === 'draft'`, если K14 допускает (K14 рендерит без ввода — проверить с architect) |
| S4 | совет | `conversation-screen.tsx:334,337,340` | подписи пунктов F05.04 — литералы вне каталога копии | — | ключи в каталог при пакете копии |
| S5 | совет | mobile.yml:228–236 | в общий шаг выноса дописана строка 116, имя шага не обновлено («…и пачку 135») | прецедент 117/135 | implementer: переименовать при следующей правке |
| S6 | ESSENTIAL (не находка) | `mission-copy.ts` | второй каталог копии в фиче: `mobile/src/i18n` вне зоны 116; тексты побайтово = каталогу (Z13) | — | — |

Чекбоксы закрытия (implementer/architect, норма 050):
- [ ] B1 — флоу/модель флоу: проходимый путь (замер: replay или эмулятор, где каждый assert истинен)
- [ ] B2 — одна форма действий композера/экрана
- [ ] B3 — пины макетов = дереву (sverka 123 без MAKET_PODMENEN) + решение о source.json 116/2
- [ ] B4 — кадры mission × тема в артефакте android-e2e, сверка ревьюером по каждому кадру

## Паразитная сложность (контракт 050) — по артефакту диффа

| артефакт | (1) свойство контракта | (2) состояние, явность | (3) файлов на правку свойства | (4) глубина | (5) потребитель / повтор | вывод |
|---|---|---|---|---|---|---|
| conversation-screen.tsx | Предмет, Инв. 5 (оси issue #9), K14–K18 | `draftStore`, `clientMessageSeq` — состояние модуля, видно только в коде; `draftStore` требует K13 | 1 (+ флоу при смене testID) | глубокий: 11 пропсов, 6 действий, 10 состояний | jest-семья, CI | ESSENTIAL (`clientMessageSeq` глобален между экземплярами — совет) |
| mission-copy.ts | копия F05 из каталога | нет | 2 (каталог + файл) — выросло, т. к. i18n вне зоны | плоский словарь | экран | ESSENTIAL (S6) |
| ds-class-name.ts | Инв. 2/грамматика модели (`className`) | нет | 1 | augmentation типа | tsc | ESSENTIAL для tsc; эффект на рантайме нулевой (S2) |
| композер: порты A01–A03 + подписи | Инв. 6 (порты допускаются, не требуются) | нет | 2 (композер + экран) — выросло | интерфейс +6 пропсов при нуле потребителей — модуль мельче | потребителя нет; повторяет ряд действий экрана | ACCIDENTAL → B2 |
| пачка e2e-mission (ekran/kadry/katalog/sostojanija/spec_api/kontrakt/e2e.sh + 2 носителя) — одна семья | Инв. 1–4, шаблон 132, пины | `maestro-out-mission/` — каталог состояния, явный (аргумент/вывод валидатора) | kadry.json + source.json батареи при перепине (B3) | — | валидатор 132, сверка 123, CI-шаг | ESSENTIAL |
| mission.yaml | Инв. 4 | нет | флоу + экран | — | proverka, e2e.sh | ESSENTIAL; дефект B1 |
| .maestro/config.yaml | убрать mission из прогона каталога 995 (флоу требует вошедшей оболочки) | нет | 1 | 2 glob-строки | шаг 995 (success) | ESSENTIAL до 118; после 118 пересмотреть |
| mobile.yml: шаг семьи 116 | строка :38, пин блока | нет | 1 (пин) | 2 строки | runtime-строка | ESSENTIAL |
| mobile.yml: checkout .harness116 + «116 mission pack checks» | ПРОВОДКА (статика, носители) | `.harness116` — явный путь | 1 | 3 команды | CI | ESSENTIAL |
| mobile.yml: строка выноса пачки | layout-lint не видит пачку | нет | 1 | 1 строка | quality | ESSENTIAL (S5) |

## Чего вердикт НЕ утверждает
- Не утверждает пиксельный KADR ни одного кадра: кадров нет.
- Не судит локальный клон Impl116 (caeac54a, 4dec88e4). На них я только сослался как на
  существующий фикс B3 и шаг mission-ekran. Их содержимое не проверял.
- Команду проверки тега 118 и `ORACLE_TAMPERED` не гонял.
- Scratch замеров: `/tmp/dev-harness-verify/Rev116c/scratch/{mutants.py,comment_probe.py,elementy.py,dims.py,copy_check.py}`.
  Throwaway-тест replay удалён, клон чистый (`git status --short` пуст).
