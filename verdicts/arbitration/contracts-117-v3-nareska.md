РЕШЕНИЕ
OBJECT=6b6e55c1cabaa7f28b5d89903fa8652ae8d65b34

# Арбитраж 117 v3 / нарезка 117↔118 — после третьего FAIL критика

Повод: три FAIL критика по одной причине (полнота критерия допуска/Г0 против зелёных контрпримеров): `orch/keep117v3/contracts-117-v3.md`, `-r2.md`, `-r3.md`. Стороны: автор конструкции 117 v3 (architect, GLM) и критик (openai-codex). Модель арбитра: anthropic/claude-fable-5-1 — не семейство автора (GLM), не семейство критика и не модель консультанта (openai-codex/gpt-6-astra); асимметрия роли «арбитр одного семейства с автором» в этом арбитраже не действует. Записка консультанта `orch/consult117slice.md` прочтена целиком как материал; её [INFERENCE] перепроверены по деревьям ниже.

Арбитр решает только «как правильно». Кап кругов, цена дальнейших судей, объём и изменение frozen-текста 118 — владельцу (раздел «К владельцу остаётся»). Прошлые круги не пересуживаются: их находки — факты. Новых кругов этот вердикт не назначает и не разрешает.

## Замеры (только чтение; клоны read-only)

Все команды исполнены из `/home/harness/dev-harness`, `/tmp/dev-harness-verify/Architect117v3/repo`, `/tmp/dev-harness-verify/Impl118e/mob`; ни один файл в этих деревьях не изменён.

| № | Что | Результат |
|---|---|---|
| 1 | `git rev-parse HEAD` в Architect117v3/repo; `git status --short \| wc -l` | `6b6e55c1…` = OBJECT; 0 — рабочей дельты нет |
| 2 | `git rev-parse HEAD` в Impl118e/mob | `fba61efafefc61b69dfc42afa0fec7ec61ce649c` |
| 3 | `mobile/src/app/index.tsx` (Impl118e) | `export { PilotApp as default } from '../bootstrap/pilot-app'` — production `/` = bootstrap |
| 4 | grep `Erstinformation\|onboarding\|admission` в `mobile/src/bootstrap/pilot-app.tsx` (Impl118e) | импорта Erstinformation нет; `onboarding` только как `entry.onboarding?: 'unknown'\|'incomplete'\|string` (:57) и комментарий (:121); порта admission/gate нет; `auth.begin` вызывается ТОЛЬКО в handleDemoEntry (:204) — F03.02 (code) достижим только через demo |
| 5 | `mobile/src/bootstrap/__tests__/kompozicija.probe.test.tsx` (Impl118e) | :21 `import { PilotApp } from '../../app/pilot-app.model'` — НЕ production; шесть неизменных клеток W0/W1A × null/stale/current (:86–93); `erstinfo_continue_start` нажимается ТОЛЬКО при `gate === 'current'` (:109–112); темы, `entry`, смены порта, remount нет |
| 6 | `mobile/src/app/pilot-app.model.tsx` (Impl118e) :37–57 | stage first-run → demo → Erstinformation БЕЗУСЛОВНО; gate/admission решают только внутри `ErstinformationDemoPath` (допуск Start) |
| 7 | `sha256sum mobile/src/bootstrap/__tests__/kompozicija.stand-in.sh` (Impl118e) vs `KOMPOZICIJA_FORMA_SHA256` в `fixtures/workshop_project/erstinformation_118/teksty/proverka_text.py:153–154` | `49fb3e58…` ≠ пин `5ec501b4…` → `sud_kompoziciju` даёт `KOMPOZICIJA_FORMA` (подтверждён замер консультанта §6) |
| 8 | `mobile/.maestro/erstinformation.yaml` (Impl118e) | `grep -c first-run-continue` = 0; поток `launchApp → first_run_demo_entry → assertVisible erstinfo_gate_null → … → erstinfo_gate_stale → … → erstinfo_retry_current → erstinfo_continue_start → start_tabs`; `first_run_demo_entry` живёт в `features/onboarding/first-run-demo-entry.tsx:36` (компонент 118), production demo-кнопка — `auth-demo-entry` на F03.01 (`features/auth/auth-screen.tsx:119`) |
| 9 | 117 v3: `fixtures/workshop_project/vkhod_117/model/bootstrap.pilot-app.tsx` :186–187, :215–218 | `onboardingAdmission = onboarding?.admission ?? 'W0'`, `onboardingGate = onboarding?.gate ?? 'null'`; в handleDemoEntry `if (W1A && current) setFrame('erstinformation')`, иначе `auth.begin → 'code'` — gate судится В МОМЕНТ demo |
| 10 | `contracts/117-cmp-mob-vkhod-splash.md` (OBJECT) :147–156, :162–166, :170–174 | «Без admission ИЛИ без current — прежний путь B: демо-вход ведёт в кадр code»; «Erstinformation — ТОЛЬКО демо-входом при допуске» |
| 11 | `contracts/118-erstinformation.md` (основной H): `git tag -l 'frozen/contracts/11[78]/*'`; `git diff --quiet frozen/contracts/118/1 HEAD -- contracts/118-erstinformation.md` | теги `117/1`, `117/2`, `118/1` (`54cdfae6…`); `117/3` НЕТ; текст 118 побайтово равен frozen/118/1 |
| 12 | 118 :15–16 («Зависимость замороженного корня»): 117 v+1 «объявляет узкую смену pilot-app.tsx для demo → Erstinformation и допуска current → Start»; :22 инв. 4: «на null и stale видит маркер gate и assertNotVisible Start до current; при null/stale нажатие continue НЕ даёт перехода»; :23 инв. 5: «инъецирует gate=null и stale и отвергает переход к Start ПОСЛЕ ДЕЙСТВИЯ continue»; :32 команда bootstrap-пробы | Erstinformation (с маркером gate и действием continue) показан при null/stale; gate закрывает только Start |
| 13 | `grep -n 'КЛАСС РИСКА'` в 117/118; `grep 117\|118 registry/risk-legacy.tsv` | поля нет, записей нет → рисковый класс по `roles/orchestrator.md:494–499` |
| 14 | `AGENTS.md:100–110` (арбитр), `:139–147` (добавление красных тестов после freeze по вердикту адверсария/арбитра законно — усиливает гейт) | норма действует |
| 15 | `git show 9793d1dde:forks/n118-migraciya-117.md` | слово владельца «а» = завести предмет «миграция 117 v+1» (текст 117 допускает правку pilot-app под 118/135 с сохранением Г0); момент проверки gate (на входе / перед continue) владельцем НЕ зафиксирован — это инженерный вопрос |
| 16 | `/tmp/dev-harness-verify/Rev118c/h/verdicts/review/contracts-118-v1.md` | каталог `Rev118c` отсутствует (`ls` rc 2) — первичный Rev118c не прочтён; его вторичные пересказы в решении не используются как факты |

Утверждения критика r3 (семь зелёных мутантов при 96/96 + 43/43) и автора (26×2=52, стабы 53/38 красны) приняты как факты прошлых кругов, оба независимо получены там исполнением; мною не перепроверялись и не оспариваются.

## Основание

### Ф1. Четыре из семи «временных» обходов r3 — НЕ временные
Классификация по собственным описаниям мутантов (r3 :16–22):
- `r3-extra-authenticated` — неизменный вход `{admission:'W0',gate:'stale',authenticated:true}`;
- `r3-gate-from-entry` — неизменный вход `entry.gate='current'` + `{W1A,stale}`;
- `r3-admission-literal-completed` — неизменный вход `entry.onboarding='complete'` + `{W0,current}`;
- `r3-restart-completed-start` — начальный frame при неизменном входе `entry.onboarding='complete'` (критик оформил как remount, но дефект наблюдаем ПЕРВЫМ рендером: нарушено «стартовое значение frame — 'first-run'», 117 :165–166).

Это клетки той же формы, что таблица автора (фиксированный вход → наблюдение), только с полем `entry` и соседним полем порта. `entry.onboarding: string` — СУЩЕСТВУЮЩЕЕ поле production-порта (замер 4, :57), не придуманный алфавит. Довод автора «источник/переходы — 118» к этим четырём не применим: они о том, из КАКИХ ПОЛЕЙ модели читается допуск и каков начальный кадр, а это ровно то, что 117 v3 :147–151 обещает («ТОЛЬКО W1A из сессии ∧ current; литерал запрещён»). Критик прав: критерий слабее написанного предмета.

### Ф2. Три действительно временных — делятся
- `r3-g0-theme-change` и `r3-order-theme-autostart` — смена темы ОС в живом экземпляре. Тема/StatusBar/Г0 — предмет 117 (клетки `PROD_ENTRY_OS_THEME_*`, `RESTYLE_GUARD_995_F03_*`); 117 :155–160 обещает Г0 «при ЛЮБОМ недопуске, обе темы». Смена схемы ОС при открытом приложении — штатное событие production (useColorScheme), не экзотика. Эти два — 117, а не 118: 118 не судит Г0 корня F03 и не владеет темой.
- `r3-cached-admission` — повторная подача порта с изменённым admission в живом экземпляре. Свойство модели «порт читается в момент demo, не кэшируется» — дешёвая RNTL-клетка (rerender), пинится в 117; а связь «сессия → порт» и её обновление на production-корне — 118 (инв. 5).

### Ф3. Производственная проба 118 сегодня НЕ ловит ни одного из r3 — подтверждено
Замеры 3–6: production `/` экспортирует `bootstrap/pilot-app`, в котором нет ни Erstinformation, ни порта admission/gate; проба 118 импортирует модель `app/pilot-app.model`, не production; шесть клеток неизменных входов, continue не нажимается при null/stale (требование инв. 5 «после действия continue» не исполнено даже на модели), тем/entry/remount нет. Утверждение консультанта §2 («ни один из семи r3 не имеет ловца на production118») — верно по коду. Форма stand-in расходится с пином H (замер 7) — продуктовая `sud_kompoziciju` сейчас красна по `KOMPOZICIJA_FORMA`, а не зелена; зелёный консультанта/критика по `kompozicija_forma W1A current` — исполнение shell-формы, не композиции.

### Ф4. Решающее: две модели реализуют РАЗНЫЕ автоматы допуска, и это несовместимо с frozen 118/1
117 v3 (замеры 9–10): gate судится в момент demo; W1A×null и W1A×stale → кадр code (F03.02), Erstinformation не показан.
Frozen 118/1 (замер 12): после demo пользователь ВИДИТ Erstinformation с маркером gate при null/stale, Start закрыт, нажатие continue не переводит; Maestro от production `/` снимает F02.03 V01/V02 (MISSING/OUTDATED) именно на этом пути (замер 8: `assertVisible erstinfo_gate_null` сразу после demo). Под автоматом 117 v3 кадры F02.03 V01/V02 с production `/` недостижимы вовсе: при null/stale приложение ушло в F03.02. 118 :15–16 прямо описывает ожидаемую миграцию как «demo → Erstinformation» и «допуск current → Start» — два разных перехода, gate на втором.

Следовательно спор о «полноте таблицы» вторичен: таблица 117 v3 пинит на W1A×stale поведение (code-кадр), которое frozen 118 запрещает на production. Усиление батареи 117 в нынешней семантике закрепило бы несовместимость. Консультант отметил это как [INFERENCE] (§2 «Важная граница применимости»); здесь это установлено по тексту frozen 118 и yaml, не по модели 118.

Кто уступает: frozen-текст 118/1 уже санкционирован владельцем (тег, РАЗРЕШИЛ); 117 v3 — незамороженный кандидат, заведённый КАК предпосылка 118 (замер 15). Слово владельца «а» момент проверки gate не фиксировало. Инженерно: кандидат подстраивается под замороженный текст, который он обслуживает; обратное (118 v2 ради удержания gate-на-входе) — изменение воли, а не инженерии.

### Ф5. Что остаётся верным у автора
- Модельная батарея НЕ МОЖЕТ доказать production-источник сессии, подключение `/` и поведение настоящего корня — это инвариант 5 и команда bootstrap-пробы frozen 118 (:23, :32); зона `mobile/src/bootstrap/__tests__/` у implementer 118 (118 :39–49).
- 117 v3 — санкция узкой правки + охрана Г0 + таблица порта; состав экранов Erstinformation/Start — 118. Критик это и не оспаривал (r3 вопрос 3–4).
- `r3-g0-erstinformation` критик сам не считает блокером — верно: поверхность F02 судится кадрами 118.

## Решение

### Пункт 1 — граница ответственности
Правы обе стороны по разным половинам; формула автора «переходы и источники — 118» принимается ТОЛЬКО для production-источника и production-корня, но НЕ для свойств самой модели.

Батарея 117 v3 ОБЯЗАНА пинить на модели (без этого критерий слабее написанного :147–175):
- (а) чтение допуска ТОЛЬКО из `onboarding.admission`/`onboarding.gate`: при `entry.onboarding ∈ {'complete','unknown','incomplete', отсутствует}` и при постороннем truthy-поле порта (`authenticated:true`, передано через cast) ожидание клетки НЕ меняется относительно её строки таблицы; `entry.gate`/иные поля entry не влияют. Достаточно: ось `entry.onboarding` × строки таблицы с решающими парами {W0/stale, W0/current, W1A/stale, W1A/current, порт не подключён} × 2 темы + одна клетка постороннего поля на W0/stale × 2 темы;
- (б) начальный кадр 'first-run' при ЛЮБОМ `entry` (в т.ч. 'complete') и любом порте — первый рендер, без Start и без Erstinformation (закрывает `r3-restart-completed-start` как свойство входа; remount — то же наблюдение на втором монтировании, одна клетка);
- (в) Г0 F03.01/F03.02 после смены схемы в живом экземпляре, dark→light и light→dark, на недопуске (закрывает `r3-g0-theme-change`);
- (г) смена схемы на Erstinformation не даёт Start без continue (закрывает `r3-order-theme-autostart`);
- (д) порт читается в момент действия: rerender W1A→W0 до demo → недопуск (закрывает `r3-cached-admission` на модели).
Семь r3-мутантов критика становятся именованными стабами `--matrix` семьи 117, как уже сделано с мутантами кругов 1–2 (r3 :270–296, `migracija-admission-default` и др.). Это не «новая модель времени», а 5 классов клеток в существующем шве.

Батарея 117 НЕ пинит и не обязана: production-источник сессии, подключение `/`, Maestro, состав/пиксели F02/Start, настоящий gate 107.

На production-корне 118 ОБЯЗАН добавить (усиление уже обещанного инв. 4–5, :22–23, :32; frozen-текст не меняется):
1. импорт production `../pilot-app` в `kompozicija.probe.test.tsx` вместо `app/pilot-app.model` после frozen 117/3; модель как доказательство композиции удалить;
2. шесть клеток admission×gate на production-корне с ОБЯЗАТЕЛЬНЫМ нажатием continue при null/stale (инв. 5 «после действия continue») и наблюдением отсутствия Start; обе темы;
3. конфликт источников на production-шве: `entry.onboarding='complete'` + сессия W0/current → Start закрыт; сессия W0/stale + постороннее поле → закрыт; авторитетный gate stale при любом другом «current» в entry → закрыт;
4. живая смена сессии (W1A→W0) до demo/continue → закрыт; remount с сохранённым completed-entry и W0/stale → First-Run, не Start;
5. Г0 корня F03.01/F03.02 на production после смены темы (обе стороны) — так как 117 судит модель, а production-правку делает 118;
6. согласование формы stand-in с пином H (`KOMPOZICIJA_FORMA`, замер 7): либо носитель побайтово равен `teksty/kompozicija_forma`, либо пин H перепиновывается архитектором 118 законным путём; текущая пара красна и не складывается в зелёное;
7. Maestro `erstinformation.yaml`: путь от production `/` включает `first-run-continue` и production demo-кнопку (`auth-demo-entry` на F03.01, замер 8) либо точку демо-входа, которую санкционирует 117/3; экран `first_run_demo_entry` между First-Run и Erstinformation в production-корне 117 v3 не предусмотрен (117 :153 «вход F03.01 после First-Run — без изменений»).

### Пункт 2 — совместимость временных точек допуска
НЕ совместимы (Ф4). Автомат 117 v3 (gate на входе в Erstinformation) противоречит frozen 118/1 инв. 4–5, пути «demo → F02.03 → F02.08 → continue при current → Start» (:22) и :15–16. Правка текста 118 (v2) инженерно НЕ требуется: 117 v3 должен принять семантику frozen 118 —
- admission решает ПОВЕРХНОСТЬ после demo: W1A → кадр 'erstinformation' при ЛЮБОМ gate (null/stale/current/отсутствует); не-W1A (W0/отсутствует/null/неизвестное) — прежний путь B (auth.begin → code, Г0). Это сохраняет достижимость F03.02 через demo (замер 4: иной путь к code отсутствует) и клетки RESTYLE_GUARD;
- gate решает ПЕРЕХОД: continue → 'start' ТОЛЬКО при W1A ∧ current; при null/stale continue не переводит (Start отсутствует); второй gate не вводится, предикат — 107/118;
- начальный кадр 'first-run' всегда; Start ТОЛЬКО continue.
Для W0 frozen 118 поверхность после demo не фиксирует (инв. 5 говорит только о недопуске к Start); 118-реализация (замер 6) ведёт W0 в Erstinformation — это выбор реализации 118, не frozen-требование; 117 v3 вправе удержать путь B для не-W1A, и 118-проба на production обязана принять это (W0×current → Start закрыт выполняется и на пути B). Если автор 117 или владелец хотят gate-на-входе (null/stale → F03.02), это меняет frozen 118 (инв. 4, кадры F02.03 V01/V02 с production `/`) → только 118 v2 по воле владельца (вариант Б консультанта); арбитр этого не выбирает.
Таблица входов 117 (26×2) сохраняется как ОСЬ, но ожидания 20 строк с W1A×{stale,null,отсутствует,неизвестное} переписываются с «code» на «erstinformation без Start»; это не ослабление (клетки остаются красными на обходах `migracija-gate-ignor`, `-stale-kak-current`, `-null-kak-current`: там ловится Start, а не кадр), а исправление ожидания под frozen 118. Добавление красных тестов в 118 после freeze законно по AGENTS.md:139–147.

### Пункт 3 — минимально достаточный набор в существующих номерах
Порядок (инженерный; разрешение на каждый судейский проход — владельцу):
1. **architect 117** (один консолидированный кандидат v3 на новом OBJECT): (i) семантика по пункту 2; (ii) клетки (а)–(д) пункта 1 и семь r3-стабов в `--matrix`; (iii) прежние 96 клеток и 53/38 стабов сохраняются, removed=[] (переписываются только ожидания строк W1A×не-current); (iv) описка «40 строк ×2» :538/:550 → «20 строк × 2 темы = 40»; (v) явный раздел границы доказательства: что судит модель 117, что — production 118 (ссылка на инв. 5 и команду :32), чтобы критик судил модель, а не требовал от неё production. Прежние три FAIL и r3-свидетели не стираются и не переименовываются; `/tmp/dev-harness-verify/Critic117v3c/*.tsx` переносятся в стабы как есть по смыслу.
2. **critic 117** на новом OBJECT — только если владелец разрешит проход сверх капа; при accept — freeze/publish `frozen/contracts/117/3`.
3. **architect 118**: frozen-текст НЕ правится; в `fixtures/workshop_project/erstinformation_118/` добавляются клетки/стабы пунктов 1.1–1.7 (красные на модели-как-доказательстве и на мутантах production), перепин формы stand-in ↔ H согласуется законным путём; в контракте 118 поле «КЛАСС РИСКА» отсутствует (замер 13) — класс рисковый (авторизация/допуск).
4. **implementer 118** после тега 117/3: правка production `pilot-app.tsx` в объёме 117/3 (порт onboarding из сессии; W1A → Erstinformation; continue при current → Start; Г0 неизменен), `kompozicija.probe.test.tsx` на production-импорте, Maestro от `/` через First-Run → F03.01 → demo, сборка Android обеих тем; удаляется использование `app/pilot-app.model` как приёмочного доказательства.
5. Судьи 118 на одном собранном OBJECT: adversary → reviewer последовательно (рисковый класс, `roles/orchestrator.md:494–499`); на модели/бумажном green судей не будить. Любой FAIL → СТОП.
Накопленная батарея 117: не ослаблять, не стирать FAIL; это условие уже выполняется автором (removed=[] во всех кругах) и остаётся обязательным.

## К владельцу остаётся (арбитр не решает)
1. Кап кругов 117 исчерпан (3 FAIL; слово 15:25 UTC «СТОП»): разрешить ли ОДИН дополнительный критический проход 117 на переработанном кандидате — без него freeze 117/3 и production bootstrap 118 штатно недостижимы. Проект РАЗРЕШИЛ-строки — consult117slice §4 (вариант А); арбитр его не подтверждает и не отменяет.
2. Цена судей 118 (adversary + reviewer на собранной поставке) и учёт прежних кругов 118 (первичный Rev118c недоступен, замер 16).
3. Хотите ли семантику gate-на-входе (null/stale → F03.02) вместо frozen 118 «Erstinformation с маркером gate, Start закрыт»? Инженерно не требуется; если да — только 118 v2 с критиком и РАЗРЕШИЛ-ВЛАДЕЛЕЦ, с переделкой кадров F02.03 V01/V02 как достижимых с production `/`.
4. Поверхность для W0 после demo (прежний путь B по 117 vs Erstinformation без Start как в реализации 118) — frozen 118 молчит; арбитр рекомендует путь B (сохраняет достижимость F03.02/Г0), окончательный выбор пользовательского пути — владельцу, если автор 118 возразит.

## Пределы
Код не писался, тесты не прогонялись (только чтение, sha256, grep, git read-only). Мутанты r3 не воспроизводились — приняты как факты круга 3. Rev118c первичный не прочтён (каталог отсутствует). Android/e2e/CI не касались. Это решение по инженерной сути; оно не заменяет accept критика, не даёт freeze и не разрешает круги.
