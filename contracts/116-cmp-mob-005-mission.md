# Контракт 116 — mob: CMP-MOB-005, текст и вложения в одной Mission без потери черновика

КЛАСС: КОДОВЫЙ. Предмет — issue `a3ka/Complior-mob#9` (CMP-MOB-005, F05 «Текст и
вложения в единой беседе», P0/W0/полоса A/mock): беседа внутри ОДНОЙ Mission —
отправка текста и вложений, состояния выбора/загрузки/ответа различимы, черновик
не теряется ни на одном пути жизненного цикла; новая тема — отдельный intent без
переноса приватного контекста; отозванный источник не открывается из старого
exchange. Реальный HTTP — вне среза (режим mock; NOT_RUN→PASS только с evidence
соответствующего SWITCH).

КОНТЕКСТ: GitHub `a3ka/Complior-mob#9` — источник работ; перед раздачей читать
полное тело (`gh api repos/a3ka/Complior-mob/issues/9 --jq .body`).
КОНТЕКСТ: `contracts/108-cmp-mob-004-start.md`, `contracts/111-cmp-mob-first-run.md`
— дисциплина H/B/C/T, disposable R, пробы с --matrix, пины H в mobile.yml.
КОНТЕКСТ: `fixtures/workshop_project/first_run_111/` — механика проб (probe_lib,
эталон-модель, обманные стабы по коду Н-39).
КОНТЕКСТ: Н-379/Н-383 (ожидания — литералы EXPECT, не вычисляются кодом/входом
субъекта), уроки 111 (свойство по ВСЕМ путям жизненного цикла, наблюдение
ПОВЕДЕНИЯ и порта отправки, а не одной точки).

## Нарезка предмета (frontier)

1. **Один контракт = весь срез F05** (беседа: composer + экран + api-шов + mock;
   один PR) — **выбран**. Боль: свойство «черновик не теряется» наблюдается одним
   жестом «написать → добавить вложение → ошибку сети → новую тему»; расщепление
   по слоям даёт слои без поведенческой обратной связи (вертикальный слайс 050);
   все пути жизненного цикла сидят на одном состоянии композера.
2. Два контракта (composer/беседа и api-шов/mock) — отвергнут: шов без поверхности
   не имеет одного измераемого результата; поверхность без шва не наблюдаема в
   порте отправки.
3. F05.06 FactCard-источники с отзывом доступа как отдельный предмет — отвергнут:
   отзыв наблюдаем из того же exchange-дерева (отозванный источник не открывается
   из старого exchange — критерий приёмки issue), отдельный контракт оставил бы
   поверхность без стража отзыва.

## Существующее

Сверено на read-only снимке Complior-mob main `16eb708a27f7127920803dac537be7eddac5ae54`
(clean clone, `git rev-parse HEAD`; включает 999/995/108 — PR#111/#112).

- `mobile/src/ui/conversation-composer/conversation-composer.tsx` (108): единый
  композер с контролируемым `value`/`onChangeText` (режим controlled при обоих,
  иначе внутренний useState), testID `start-composer`, input `start-composer-input`,
  copy F04.07. Предмет РАСШИРЯЕТ композер опциональными портами A01/A02/A03 —
  без портов поверхность 108 байт-в-байт сохранна (семья start_108 зелена без правок).
- `mobile/src/features/start/start-section-host.tsx` + `mobile/src/app/(tabs)/[section].tsx`
  (108, круг 2): черновик композера поднят ВЫШЕ слота start — composition root
  держит контролируемое значение; политика «без персиста». Предмет переиспользует
  тот же прецедент: контролируемый порт `draftValue`/`draftOnChange` экрана беседы.
- `mobile/src/api/api-client.ts` (108): шов listMissions + MissionBrief/MissionPage/
  MissionState одним местом; generated/ read-only. Предмет расширяет шов операциями
  беседы (listMessages/postMessage/createUpload/completeUpload/listDocuments/
  createIntent) — потребители не переизобретают перечней.
- `mobile/src/mocks/runtime.ts` + `start-mock.ts` (108): mock ApiClient с
  SYNTHETIC-evidence и сценарием; до CMP-BCK-009/010/011/014/015 реальных операций
  нет — mock остаётся синтетическим источником.
- Каталог `docs/ux/01_UX_Source_of_Truth/BrokerOS_UI_Copy_DE.json`: 17 ключей F05
  (3 действия + 7 кадров title/body), review_status verbatim; предмет вводит
  РОВНО потребляемые поверхностью 9 ключей (остальные — по мере появления кадров).
- `BrokerOS_Mobile_Design_Data.json#features/F05`: грамматика данных — mission_id
  `MIS-CAR-01`, send_state ∈ {draft, queued_offline, attachment_pending,
  already_accepted}, response_state ∈ {idle, interrupted}, source_refs
  `DOC-VEH-01:p1`, attachment_ids `DOC-VEH-01`; F05.02 — вторичная история.
- `mobile/src/theme/tokens.ts` + `context.ts` (999): провайдер темы; экран беседы
  палитру берёт ТОЛЬКО через useTheme.
- `mobile/src/bootstrap/__tests__/pilot.test.tsx` (995, frozen): зелёный на базе,
  не рестайлится; Jest-прецедент `await render(...)`/`await fireEvent.*` (RNTL 14.1
  async) — проба 116 следует ему.

## Предмет и граница

Один результат: пользователь пишет текст и добавляет вложение В ОДНОЙ Mission —
сообщение уходит в тот же mission_id (postMessage по client_message_id идемпотентен:
already_accepted не создаёт дубль), выбранный файл отличим от доставленного
(attachment_pending ≠ uploaded; незавершённый/отклонённый completeUpload оставляет
pending, повтор не дублирует запись и не создаёт внешний эффект), потеря сети
хранит черновик и НЕ называет его доставленным (F05.07), interrupted не показан
завершённым ответом (F05.05), новая тема (F05.A03) получает отдельный intent
(createIntent, новый mission_id) без переноса приватного контекста старой Mission,
отозванный источник не открывается из старого exchange (F05.06). Черновик не
теряется на путях: ввод вложения, ошибка/офлайн отправки, повтор already_accepted;
и снимается после принятой отправки и при новой теме (не переживает отправку).

Вне предмета: реальный HTTP/бэкенд-операции (CMP-BCK-009/010/011/014/015, SWITCH);
голосовой ввод (F05 V-каналы 108); импорт полиса и sensitive admission (F14);
персист черновика на диск (политика «без персиста» — сохранение в состоянии);
copy signoff CMP-MOB-089; device evidence CMP-MOB-090; Maestro-сценарий офлайна —
отложенная продуктовая приёмка; кадры F05.03–F05.05 как отдельные экраны (тело
кадров используется поверхностью беседы по месту); admission/quarantine вложений.

## Инварианты

1. `mobile/src/features/conversation/conversation-screen.tsx` — экран беседы:
   presentation-порт (не знает транспорта): `missionId`, `turns`, `responseState`,
   контролируемые `draftValue`/`draftOnChange`, порты `onSendMessage`/
   `onAttach`/`onCompleteUpload`/`onNewTopic`; палитра ТОЛЬКО через `useTheme`
   (hex-литералов в файле нет); canvas F05.01 + вторичная история F05.02
   (`conversation-transcript`) + mission-чип текущей Mission.
2. Отправка: порт получает `{mission_id, client_message_id, text, attachment_ids}`;
   `mission_id` = текущая Mission (не хардкод литерала на поверхность — чип рендерит
   состояние); статус `accepted` → свой ход в истории + черновик снят;
   `already_accepted` → дубль НЕ создаётся, черновик снят; `queued_offline` →
   черновик СОХРАНЁН, уведомление frame.F05.07.body, ход НЕ показан доставленным.
3. Вложение: выбор (`onAttach`) добавляет запись в состоянии `attachment_pending`;
   завершение (`onCompleteUpload`) — `uploaded` | отказ; отказ/незавершённость
   оставляет pending; повтор завершения не создаёт вторую запись (map по id);
   `attachment_pending` НЕ называется прочитанным/обработанным.
4. interrupted — UI-состояние (F05.05 body/title), не «готовый ответ»: токен
   состояния `interrupted` наблюдаем, `completed` на поверхности не появляется.
5. Новая тема: `onNewTopic` → новый mission_id в чипе, история/вложения/черновик
   старой Mission НЕ переносятся; revoked источник: контрол открытия отсутствует
   (доступный — присутствует, frame.F05.06.body).
6. `conversation-composer.tsx`: порты `onSend`/`onAttach`/`onNewTopic` ОПЦИОНАЛЬНЫ;
   без них — байт-в-байт поверхность 108 (testID `start-composer`, input
   `start-composer-input`, copy F04.07, value/onChangeText-контракт); действия
   подписаны action.F05.A01/A02/A03 verbatim.
7. `api-client.ts`: операции беседы + типы проекций (ConversationMessage/
   MessagePage/PostMessageStatus/UploadDescriptor/DocumentRef/NewIntent) объявлены
   одним местом; mock (`mocks/runtime.ts` + `mocks/conversation-mock.ts`)
   реализует их с SYNTHETIC-evidence и сценариями грамматики F05.
8. `ui-copy.ts`: ровно потребляемые 9 ключей F05 verbatim (text + review_status);
   новых немецких формулировок не вводится; множество добавлений замкнуто
   перечнем каталога F05.

## Проверяемый шов

Экран `ConversationScreen` рендерится композиционным корнем с портами; пробы
инжектируют jest-порты и наблюдают ПОВЕДЕНИЕ (поверхность + что уходит в порт).
Ожидания проб — литералы source.json в самих пробах, снятые в память ДО запуска
субъекта (правило 8, Н-351); вход (провайдер темы) — themeTokens 999.

## Закрытые перечни клеток (числа из кода проб)

Поведенческая семья (Jest/RNTL, `mission_probe.py` → `mission.test.tsx`, 12 клеток):
- К1/К2 `CONVERSATION_STRUCTURE_{DARK,LIGHT}` ×2 — произведение scheme(2): canvas
  F05.01 (title+body verbatim), история F05.02, действия A01/A02/A03 verbatim,
  mission-чип, ground/ink схемы на корне.
- К3 `SEND_SAME_MISSION_AND_DRAFT_CLEARED` — payload порта {mission_id MIS-CAR-01,
  непустой client_message_id, текст}; ход появляется; черновик снят.
- К4 `ALREADY_ACCEPTED_NO_DUPE` — повтор не приписывает дубль; черновик снят.
- К5 `DRAFT_KEPT_ON_ATTACH` — вложение добавлено, текст черновика сохранён.
- К6 `CONTROLLED_DRAFT_PORT` — внешнее значение рендерится, attach не сбрасывает.
- К7 `ATTACH_PENDING_NOT_READ` — состояние pending наблюдаемо до завершения,
  uploaded — после.
- К8 `UPLOAD_GATE_AND_RETRY_NO_DUPE` — отказ оставляет pending; повтор завершает;
  запись ровно одна.
- К9 `QUEUED_OFFLINE_DRAFT_KEPT` — F05.07.body verbatim, черновик сохранён,
  доставленным не назван.
- К10 `INTERRUPTED_NOT_COMPLETED` — токен interrupted, F05.05.title, нет completed.
- К11 `NEW_TOPIC_SEPARATE_INTENT` — новый mission_id, свой ход и базовая история
  старой Mission исчезли, черновик снят.
- К12 `REVOKED_SOURCE_CLOSED` — revoked: контрола открытия нет, ref:revoked;
  available: контрола есть, frame.F05.06.body.

Статическая семья (`mission_static_probe.py`, 8 клеток): `CONVERSATION_SEAM_PRESENT`,
`API_SEAM_CONVERSATION_OPS` (6 подписей), `MOCK_CONVERSATION_OPS` (6 реализаций +
wiring объекта mockApiClient), `COPY_F05_VERBATIM` (9 ключей побайтово; добавления
ui-copy замкнуты перечнем F05), `SCREEN_THEME_TOKENS_ONLY` (ни одного hex-литерала
в экране и композере), `COMPOSER_BACKCOMPAT_108` (порты/testID/copy 108 сохранены),
`COMPOSER_ACTIONS_WIRED` (testID действий привязаны к onPress-портам),
`STATIC_ORACLE_LITERALS` (проба несёт литералы и не читает модуль копии субъекта).

Обманные стабы (привязка к ветвям — ТОЛЬКО по коду `MUTANTS` обеих проб, Н-39;
depends измерены полным прогоном): поведенческих 14 (send-not-wired,
draft-cleared-on-attach, draft-not-cleared-after-send, already-accepted-appends-dupe,
attach-state-uploaded, interrupted-shown-completed, offline-clears-draft,
offline-no-notice, retry-upload-dupes, new-topic-same-mission,
new-topic-keeps-transcript, revoked-source-open, controlled-draft-ignored,
mission-chip-hardcoded), статических 5 (api-seam-op-missing, mock-op-missing,
copy-f05-invented, screen-hex-literal, composer-backcompat-broken); каждый красен
именованной клеткой, побочная краснота только в depends; `--matrix` — самопроверка
набора, не приёмка. Обходы адверсария из урока 111 закрыты поимённо: «хранится, но
не восстанавливается» (controlled-draft-ignored → К6), «в другое поле»
(mission-chip-hardcoded → К1/К2/К3/К11), «текст теряется при добавлении вложения»
(draft-cleared-on-attach → К5), «вложение дублируется» (retry-upload-dupes → К8),
«черновик пережил отправку» (draft-not-cleared-after-send → К3), «показан снова
доставленным» (offline-* → К9).

## Приёмочный критерий

R — disposable копия Complior-mob под /tmp/dev-harness-verify с `npm ci` в `mobile/`
(node_modules переиспользуется от npm ci-дерева 108/111); пробы — Python 3 stdlib.
Нет Jest/артефактов отчёта → rc2 INFRASTRUCTURE, не краснота предмета.

- Дано B без реализации; `python3 fixtures/workshop_project/mission_116/mission_probe.py
  --repo R` → rc1 `CONVERSATION_SEAM_ABSENT`; `mission_static_probe.py --repo R` →
  rc1 `CONVERSATION_SEAM_ABSENT` (именованный отказ на до-предметном дереве).
- Дано B с эталонной моделью (`--model`); либо честное C — обе пробы → rc0 с
  построчным перечнем: поведенческая 12/12, статическая 8/8.
- Дано C; каждая проба с `--matrix` → rc0: честный прогон зелёный, каждый стаб
  красен своей именованной ветвью, побочная краснота только в depends (14+5 стабов);
  якорь мутанта неуникален → отказ rc2.
- Дано C; `git status --short --untracked-files=all` в R после проб — 0 строк
  (пробы восстанавливают дерево).
- Дано C; `npm run lint`, `npm run typecheck`, `npm test` в R/mobile зелёные;
  frozen-прогон 995 (`src/bootstrap/__tests__/pilot.test.tsx`) и семья start_108
  проходят на новой поставке БЕЗ правок своих проб.
- Дано C в PR; `gh pr checks PR --repo a3ka/Complior-mob --required` → rc0,
  включая quality с шагами 116 из H (обе пробы на disposable R).
- Дано авторская пачка; `bash scripts/pre_critic.sh --repo <worktree-ветки>
  contracts/116-cmp-mob-005-mission.md` (worktree H-пина ветки wip/116/architect)
  → rc0.

## Пины и порядок поставки

После critic/freeze оркестратор разрешает `frozen/contracts/116/1^{commit}` в
полный SHA H и append-only записывает его с B в issue #9 ДО раздачи implementer.
mobile.yml получает шаг quality по образцу 108/111: H-checkout, обе пробы 116 на
disposable R (Python 3 stdlib) до npm test/lint/typecheck/doctor; frozen-шаги
995/999 сохраняются дословно (зона implementer, как 111).

## Зоны и исполнители

ЗОНА architect: contracts/116-cmp-mob-005-mission.md fixtures/workshop_project/mission_116/
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/

Пути implementer отсчитываются от корня Complior-mob:

ЗОНА implementer: mobile/src/features/conversation/ mobile/src/ui/conversation-composer/ mobile/src/api/api-client.ts mobile/src/mocks/runtime.ts mobile/src/mocks/conversation-mock.ts mobile/src/i18n/ui-copy.ts .github/workflows/mobile.yml

ПЕРЕСЕЧЕНИЕ: `mobile/src/ui/conversation-composer/conversation-composer.tsx`,
`mobile/src/api/api-client.ts`, `mobile/src/mocks/runtime.ts`,
`mobile/src/i18n/ui-copy.ts` — общие с замороженными семьями 995/108 (пробы этих
семей НЕ переписываются и обязаны оставаться зелёными на поставке 116;
`mobile/src/bootstrap/__tests__/` (995), `mobile/src/features/start/`,
`mobile/src/bootstrap/pilot-app.tsx`, `api/generated/`, `docs/` — read-only для 116.

fixtures/workshop_project/mission_116/ — новый подкаталог architect-зоны; коллизий
с живыми заморозками нет, чужие файлы не меняются.

РАБОТА НЕ РАЗДАЁТСЯ: реализация (implementer) не спавнится до accept критика и
freeze оркестратора; предмет этой пачки — контракт + красные пробы, предъявленные
красными на B.

## Модель угроз

ЗАЩИЩАЕТ:
- от декларативной зелени: пробы исполняют настоящий Jest/RNTL на disposable R и
  разбирают JSON-отчёт поимённо; пустой отчёт — именованный отказ/INFRASTRUCTURE;
- от потери черновика на ОСТАЛЬНЫХ путях: клетки К5/К6/К9 держат свойство по
  путям (attach, офлайн-отказ, already_accepted, контролируемый ремоунт), К3/К11 —
  снятие после принятой отправки/новой темы; «пережил отправку» красит К3;
- от молчаливой подмены состояний: pending/uploaded (К7), interrupted≠completed
  (К10), queued_offline≠доставлено (К9: уведомление F05.07 verbatim + ход
  отсутствует) — каждая пара различима своей клеткой;
- от дублей: already_accepted (К4) и повтор загрузки (К8: ровно одна запись);
- от подмены Mission: mission-чип рендерит состояние (К1/К2/К3/К11); payload
  порта снимается независимо от поверхности;
- от переноса приватного контекста: К11 — своя отправка И базовая история старой
  Mission исчезают при новом intent;
- от открытия отозванного источника: К12 — revoked без контролы, available с
  контролой (обе стороны в одной клетке);
- от inventions копии: 9 ключей F05 verbatim (text+review_status) статической
  семьёй; замкнутость добавлений ui-copy держит COPY_F05_VERBATIM;
- от второй палитры: SCREEN_THEME_TOKENS_ONLY + наблюдение ground/ink обеих схем;
- от слома поверхности 108: COMPOSER_BACKCOMPAT_108 (порты/testID/copy 108) и
  зелёные frozen-прогоны 995/108 в приёмке; порты A01/A02/A03 опциональны;
- от мёртвого шва: API_SEAM_CONVERSATION_OPS + MOCK_CONVERSATION_OPS (подписи И
  wiring объекта mockApiClient);
- от зависимого оракула (Н-351): все ожидания — литералы проб (копия source.json,
  снятого с read-only docs ДО субъекта); STATIC_ORACLE_LITERALS держит регресс
  «импорт копии субъекта»;
- от мёртвой матрицы: обе пробы исполняют все колонки на каждом стабе (14+5),
  depends измерены прогоном, unexpected_red — дефект rc2.

НЕ ЗАЩИЩАЕТ:
- от пиксельной сверки визуала беседы с эталонами D2.2.5.1 — cognitive-only,
  ловец reviewer на C по скриншотам Maestro;
- от реальной проводки createUpload/completeUpload к файловой системе/бэкенду —
  режим mock, реальный HTTP отдельным SWITCH (issue #9);
- от Maestro-сценария офлайна на устройстве — отложенная продуктовая приёмка;
- от злонамеренного кода с общим uid: независимые судьи, immutable H, CI evidence.

## ПРОВОДКА

ПРОВОДКА:
- role=roles/orchestrator.md «До done/тега прогони done_contract.sh; ручной git tag done/… — обход гейта.»

ПРОВОДКА-ЭНФОРСМЕНТ: потребляется действующая норма закрытия роли. Новая общая
норма не вводится; локальная приёмка — оркестратором/судьями и CI Complior-mob.
Пробы 116 исполняются в CI Complior-mob из H-checkout; подключение — шаг quality
в .github/workflows/mobile.yml (зона implementer) по образцу 108/111; в
registry/ci-steps.tsv харнесса НЕ регистрируется (python3 stdlib, npm-ключа нет).

## Отложенная продуктовая приёмка

- Maestro android-e2e: сценарий «ввести текст → потерять сеть → вернуться» (критерий
  приёмки issue) на C; черновик сохранён, не назван доставленным (NOT_RUN до C).
- Copy signoff CMP-MOB-089 (action.F05.*/frame.F05.*: PRODUCT_COPY_REVIEW_REQUIRED /
  EDITORIAL_DRAFT_REVIEW_REQUIRED) и device evidence CMP-MOB-090 — владелец.

## Вопросы владельцу

1. Глубина персиста черновика: политика 108 «без персиста» сохранена (черновик в
   состоянии composition root; убийство процесса его теряет). issue требует
   «потерять сеть, вернуться — черновик сохранён» — сети это покрывает. Требует ли
   владелец персиста через запуск (AsyncStorage) — отдельным предметом?
2. Кадры F05.03/F05.04/F05.05 как САМОСТОЯТЕЛЬНЫЕ экраны (меню вложения с выбором
   «файл/фото», прерывание ответа контролом) в срезе описаны телами на поверхности
   беседы; отдельные экраны — после ленда среза отдельным предметом?

## Фактический замер авторской пачки

Снимок B=`16eb708a27f7127920803dac537be7eddac5ae54` (clean gh-clone, `git rev-parse
HEAD`); disposable-дерево `/tmp/dev-harness-verify/Architect116/mob` (node_modules
cp -al от npm ci-дерева 111). Замер 2026-10-20.

- B без модели: `mission_probe.py --repo mob` → rc1 `CONVERSATION_SEAM_ABSENT`;
  `mission_static_probe.py --repo mob` → rc1 `CONVERSATION_SEAM_ABSENT`.
- B с эталонной моделью (`--model`): поведенческая rc0 honest 12/12; статическая
  rc0 8/8.
- Матрицы: `mission_probe.py --matrix` → rc0 (14 стабов, defects 0,
  unexpected_red=none); `mission_static_probe.py --matrix` → rc0 (5 стабов,
  defects 0).
- Зависимости стабов измерены полным прогоном; перечень пар — в коде `MUTANTS`
  проб (Н-39), проза пар не несёт.
- После прогонов `git status --short --untracked-files=all` в R — 0 строк (дерево
  восстановлено).
- Замер окружения: RNTL 14.1 `render`/`fireEvent` асинхронны — мир пробы следует
  прецеденту 995 (`await render`, `await fireEvent.press/changeText`); синхронный
  вызов даёт ложную красноту (экран не смонтирован к моменту запроса).
