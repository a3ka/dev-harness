# 998 — правила моделей: routing — единственное место, роль implementer-glm

## Предмет

Н-315: пять отказов спавна `task` и обход сменой роли отправили диагностику e2e на
MiniMax вместо architect (~1 мин на отказы + диагностика не на той модели; ловца нет).
Корень шире одного инцидента: правила «какая модель при каком случае» разошлись по ~10
местам (AGENTS.md, decisions/001–005, ROADMAP, переходный регламент 13.10, план станции,
аварийные оверлеи) и противоречат друг другу; правило 13.10 в механике не реализовано — у
роли implementer одна модель. Результат 998 по решению владельца 2026-10-18: единственное
место правил — секция `routing` в `config/agent_models.json`; правило 13.10 реализуется
второй ролью `implementer-glm` (тот же текст роли, тир на `@glm`); генератор сверяет
routing с ролями и тирами и рендерит его в промпт оркестратора; дубликаты правил в
AGENTS.md и decisions/002/005 заменяются ссылкой. Отдельная боль того же решения —
roles/consultant.md:270 запрещает фолбек `@fable`, тогда как раскладка 2026-10-18 прямо
требует «замена Astra — только Fable»; норма приводится к решению.

КОНТЕКСТ: `docs/owner/2026-10-18-pravila-modelei.md` — решение владельца: routing —
единственное место правил, при расхождении действует файл; implementer-glm как вторая
роль; дословная строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ для коммита, правящего AGENTS.md.
КОНТЕКСТ: `docs/owner/2026-10-18-raskladka-modelei.md` — раскладка: implementer-glm —
GLM-5.3, фолбек Sonnet 5-5; «заменой Astra может быть только Fable, и наоборот».
КОНТЕКСТ: `NABLIUDENIA.md` Н-315 — измеренный обход правил роли; правила выбора модели
без единого места и без ловца.
КОНТЕКСТ: `contracts/997-orch-loop-metka-perezapuska.md`, `contracts/994-provodka-vneshnij-ci-guard.md` — формат слота и probe-only каталога 034.

## Существующее

- `scripts/roles.ts` — ЕДИНСТВЕННЫЙ разбор `config/agent_models.json` (`agentModels()`:
  roles→tiers→models, `RoleParseError`; `loadRoles`: двухсторонняя сверка таблицы ролей и
  файлов `roles/*.md`). Секция `routing` сегодня не разбирается вовсе; ошибки — исключением,
  вердикт rc выносит импортёр.
- `scripts/gen-harness.ts` — производные `.omp/agents/*.md`, `modelRoles`,
  `retry.fallbackChains`; `--check` в CI (`npm run check:gen`); `--prompt <роль>` печатает
  тело роли — лаунчер `workshop` (строки 586/846) кормит этим системный промпт сессии через
  `--append-system-prompt`; вырожденные поддеревья (нет конфига/`.omp`) судят только
  agents↔roles с именованной пометкой пропуска.
- `config/agent_models.json` — секции models/tiers/roles и `routing.rules` (12 правил;
  два правила о implementer-glm несут until-оговорку «роли нет до контракта
  pravila-modelei»). `roles/` — 9 ролей.
- Дубликаты правил: `AGENTS.md` абзацы «**Какую модель ведёт сессия.**» (нарратив
  MiniMax→GLM) и «Модели ролей — единый источник…»; `decisions/002` строка «`implementer`
  на MiniMax»; `decisions/005` строка «своя роль модели `apex`». `roles/consultant.md` §Модель
  (строка 270): «фолбек тира; НЕ `@fable`».
- `registry/ci-steps.tsv` + `scripts/gen_ci_steps.sh` + `scripts/run_ci_lane.sh` — реестр
  шагов, генерация workflow, lane-runner; `scripts/check_provodka.sh` судит поле ПРОВОДКА.
- `fixtures/pravila_modelei_998/` — эта проба: легальный probe-only каталог 034
  (`.probe-only` + `red_routing_sverka_998.sh`, без `case_*`).

## Frontier и выбор

- Правила в одном файле против правки ~10 документов — выбран файл (слово владельца):
  остальные документы ссылаются, при расхождении действует файл.
- Вторая роль `implementer-glm` против параметра модели у одной роли — выбрана роль:
  omp назначает модель по роли (`modelRole`), «чистый код — MiniMax, прочее — GLM»
  иначе в механике невыразимо; тот же текст роли, тир `task-glm`.
- Сверка routing в генераторе против отдельного guard-скрипта — генератор: разбор уже
  один в `scripts/roles.ts`, второй разбор разошёлся бы молча; отказ виден в `--check`
  (CI) и в `--prompt` (fail-closed на каждой сессии).
- Рендер routing в `--prompt orchestrator` против ручной правки `roles/orchestrator.md`
  текстом правил — генерация из конфига: ручная копия разошлась бы при первой же правке
  конфига (класс Н-51); роль получает одну норма-строку-указатель, не копию правил.

## Инварианты

1. Грамматика routing — закрытая, единственный разбор в `scripts/roles.ts`;
   весь класс нарушений ниже отвергается в ОБЕИХ точках входа генератора
   (`--check` и `--prompt <роль>`) отказом rc 1, именующим routing, индекс
   правила `routing.rules[N]` и самого нарушителя (буквальное значение/ключ/
   поле): отсутствие секции routing; routing не объект; `rules` не непустой
   массив; неизвестный ключ объекта routing (допустимы `rules`,
   `conditional`, `emergency`, `_`-префикс); правило не объект; неизвестный
   ключ правила (допустимы `class`, `role`, `tier`, `constraint`, `until`,
   `_`-префикс — `_`-поля-комментарии разрешены и у объекта, и внутри
   правила, один язык); `class`/цель не непустая строка; нестроковые
   `constraint`/`until`; НЕ ровно один из `role`|`tier`; `conditional`/
   `emergency` не строки. Конфиг существует ⇒ routing существует. Вырожденный
   режим (нет `config/agent_models.json`) routing не судит — прежняя
   толерантность сохраняется.
2. Сверка ссылок: `role` обязан быть ключом `roles`-таблицы конфига И иметь
   файл `roles/<role>.md` (проверка файла — в полном режиме, рядом с
   двухсторонней сверкой `loadRoles`); `tier` — ключом `tiers`. Существующие
   фазы генератора и их диагностика неизменны; потеря накопления
   расхождения (drift) или приём сломанной производной как «зелень»
   `--check` — отказ предмета, ловится пробой: каждая из пяти фаз — своей
   клеткой с поломкой ровно одной производной — агент расходится содержимым
   (`gen_check_drift_agent_content`), агент отсутствует
   (`gen_check_drift_agent_missing`), посторонний элемент каталога
   (`gen_check_drift_agent_stray`), modelRoles (`gen_check_drift_model_roles`,
   поломана только строка `task-glm:`), fallbackChains
   (`gen_check_drift_fallback_chains`, поломана только строка `task-glm:`).
   Режимы `--into`, `--resolve-overlay`, `--agents-rules` 998 не правит
   (ПЕРЕСЕЧЕНИЕ 054); проба 998 их не судит; ловец остатка — reviewer по
   diff `scripts/gen-harness.ts` и действующая семья `fixtures/gen-harness/`
   (полным прогоном CI).
3. Рендер: `--prompt orchestrator` добавляет секцию с литеральным заголовком
   `## Правила выбора роли (routing — config/agent_models.json)`; каждое
   правило — РОВНО одной строкой, несущей литеральные `class` и цель, а при
   наличии — `constraint` и `until` на той же строке; `conditional` и
   `emergency` — своими строками; посторонних строк в секции нет. Рендер
   производен от конфига: правка значений/полей любого правила доходит до
   промпта — включая замену ЦЕЛИ (`role`/`tier`) на другую существующую,
   смену формы цели role↔tier, добавление/удаление правила и удаление
   необязательных полей (constraint/until/conditional/emergency) без
   остатка устаревшего текста в секции. Промпты всех прочих ролей
   байт-в-байт равны телам их `roles/<роль>.md` — рендер чужих ролей
   не затрагивает.
4. Роль `implementer-glm`: файл `roles/implementer-glm.md` байт-в-байт с
   `roles/implementer.md`, включая ВЕСЬ frontmatter (в том числе `tools`),
   отличается только значением `role:`; в конфиге
   `tiers["task-glm"] = {model: "@glm", fallback: "@sonnet", autoFallback:
   true, why: …}` (why ссылается на оба решения 2026-10-18; autoFallback —
   живая цепочка подмены, как у `task`) и
   `roles["implementer-glm"] = "task-glm"`; производные
   (`.omp/agents/implementer-glm.md`, `.omp/agents/consultant.md`,
   `.omp/agents/orchestrator.md`, `.omp/config.yml` — modelRoles и
   fallbackChains) перегенерируются генератором. until-оговорки двух правил
   снимаются — роль появилась, оговорка стала ложью. routing._comment и
   остальные 10 правил не меняются.
5. Дубликаты → ссылка, замена СТРУКТУРНАЯ: `AGENTS.md` — абзац «**Какую
   модель ведёт сессия.**» удалён ЦЕЛИКОМ (строки старого нарратива —
   «перевёрнуто…», «на MiniMax» — в файле отсутствуют); если заголовок абзаца
   сохранён, абзац несёт ссылку `config/agent_models.json`+`routing` — замена
   стоит ВМЕСТО старого абзаца, не рядом и не в конце файла; абзац «Модели
   ролей — единый источник…» дополняется `routing` в перечне секций.
   `decisions/002` — строка «`implementer` на MiniMax» и `decisions/005` —
   строка «своя роль модели `apex`» удалены; в каждом из трёх файлов есть
   строка-ссылка, несущая `config/agent_models.json` и `routing`.
   Соответствие смысла ссылки заменённому тексту сверх этой структуры —
   cognitive-only, ловец — reviewer контракта 998. Коммит, правящий
   AGENTS.md, несёт в теле первой строкой дословную строку владельца (агент
   копирует из решения, не сочиняет):

```text
РАЗРЕШИЛ-ВЛАДЕЛЕЦ: AGENTS.md — правила моделей заменены ссылкой на config/agent_models.json §routing (слово владельца 2026-10-18, docs/owner/2026-10-18-pravila-modelei.md)
```

   decisions/001 и 003 не правятся. ROADMAP :441 не входит в этот предмет
   (уставные пути сверх названных — отдельным словом владельца).
6. `roles/consultant.md` §Модель: фрагмент «фолбек тира; НЕ `@fable`
   (арбитр-конфликт на failover)» удалён; в §Модель есть строка нормы
   «замена Astra — только Fable» со ссылкой на
   `docs/owner/2026-10-18-raskladka-modelei.md`; строка нормы не несёт
   противоположной полярности («НЕ действует», «вместо Astra», «разрешён
   Sonnet», «запрещает»); пересечение с арбитром — только на отказе Astra;
   ручная процедура Н-50 сохраняется. Смысловой остаток сверх структуры —
   cognitive-only, ловец — reviewer контракта 998.
7. `roles/orchestrator.md` — норма-строка role-каналом (см. ПРОВОДКА),
   дословно: «Выбор роли субагента — по routing `config/agent_models.json`
   (правила рендерятся генератором в промпт оркестратора); правило ниже
   памяти сессии не создаётся и не обходится; при отказе спавна — доклад
   причины консультанту, не смена роли (Н-315).»

## Приёмочный критерий

Команды из корня принятого дерева. Проба: rc 0 — ожидания совпали, 1 —
расхождение (каждая клетка печатает имя, реальный исход, ожидание и именованную
причину), 2 — нет входа. Ожидания и инварианты неизменности исходного
`config/agent_models.json` снимаются в память ДО вызова субъекта (константы и
предзагрузка `probe.py`, правило 8 AGENTS.md): после запуска субъекта его диск
как оракул не перечитывается, а сверяется с предзагрузкой; субъект, сузивший
routing на диске во время прогона, красен именованной причиной.

- Дано до-предметное дерево; когда `bash fixtures/pravila_modelei_998/probe.sh
  --cases`; тогда rc 1: 46 клеток, 39 расхождений с именованными причинами —
  routing называет отсутствующую роль/файл `implementer-glm` (routing_refs);
  until-оговорка жива; рендер routing в `--prompt orchestrator` отсутствует;
  пара implementer-glm→task-glm(@glm/@sonnet/autoFallback), файл роли и
  производная modelRoles отсутствуют; дубликаты AGENTS/002/005 живы; норма
  consultant не приведена; норма-строка orchestrator отсутствует; генератор
  принимает 25 из 26 мутаций отрицательного класса rc 0 вместо 1 — 23 ветви
  грамматики инварианта 1 (закрытый перечень К1.1–К1.23 таблицы
  `ROUTING_BRANCHES` пробы: отсутствие секции; routing не объект; rules
  отсутствует/не массив/пуст; неизвестные ключи routing и правила; правило
  не объект; class число/пустой/отсутствует; role число/пустая; tier
  число/пустой; нестроковые constraint/until/conditional/emergency;
  role и tier вместе; ни role ни tier; несуществующие роль и тир) плюс
  удалённая роль (полный снос: файл, производная, запись таблицы — в --check
  И в --prompt) плюс файловая ветвь К1.24 «файл роли удалён при живой
  таблице roles и живых ссылках routing» (gen_reject_missing_role_file —
  проба таблицу не трогает); двадцать шестая мутация — роль в таблице
  без routing-ссылок без файла (gen_reject_unreferenced_role_file, общий
  table→file) — отвергается И до-предметным генератором (прежняя сверка
  002), её клетка зелёна до-предметно и краснеет только на исполнителе,
  снёсшем файловые проверки (обход круга 3 снёс обе — красны обе клетки);
  рендер не следует за
  правкой значений/полей/целей правил и набора правил (gen_render_follows_config,
  gen_render_all_fields, gen_render_rule_set, gen_render_stale_absent);
  фазы `--check` без производных 998 не применимы и красны
  (gen_check_drift_agent_missing, gen_check_drift_model_roles,
  gen_check_drift_fallback_chains). Шесть зелёных контролей:
  gen_check_harness, routing_grammar, other_roles_untouched,
  gen_check_drift_agent_content, gen_check_drift_agent_stray,
  gen_no_disk_mutation; седьмая зелёная — gen_reject_unreferenced_role_file
  (см. выше). Одна ветвь инварианта 1–2 = одна мутация;
  перечень мутаций в `NEG_MUTS` (порождается таблицей `ROUTING_BRANCHES`)
  покрывает каждую названную ветвь. Это предъявление до заморозки, не
  объявление зелёной реализации.
- Дано реализованный предмет; когда та же команда; тогда rc 0: 46 клеток из
  46 — мутационные клетки дают rc 1 в обеих точках входа с именованием
  routing, индекса `rules[N]` (для bogus_tier — индекс первого tier-правила,
  для снесённой роли — индекс первой ссылки routing) и нарушителя; файловые
  клетки К1.24 дают rc 1 в обеих точках, называя роль и её файл — проба
  таблицу roles и ссылки routing в них не трогает; динамические клетки сверяют
  построчную полноту секции (class, цель, constraint, until, conditional,
  emergency всех правил) с предзагруженным ожиданием — включая замену ЦЕЛИ
  (role/tier) на другую существующую, смену формы цели role↔tier,
  добавление/удаление правила и удаление необязательных полей без остатка
  устаревшего текста; генератор не пишет config во время прогона; потеря
  любой из пяти фаз `--check` красна своей клеткой с поломкой ровно одной
  производной (агент расходится содержимым/агент отсутствует/посторонний
  элемент каталога; modelRoles; fallbackChains).
- Правило различимости; когда `bash fixtures/pravila_modelei_998/probe.sh
  --matrix`; тогда rc 0 независимо от состояния предмета: 57 клеток; честная
  модель зелена на всех входах, включая входы честного отказа rc 1 —
  сравнивается фактический rc и именование, не слово «routing»; восемь
  обманных форм (key_only, empty_render, hardcoded, narrow_disk,
  drop_constraint, all_roles, drift_blind, role_file_blind) отвергнуты
  каждая на назначенном входе и неотличимы от честной модели на входах
  честного поведения — role_file_blind на назначенном входе «файл роли
  удалён, таблица и ссылка живы» (честная модель там даёт именованный отказ,
  клетка model_missing_role_file), роль без файла в матрице представлена
  СОБСТВЕННЫМ входом, а не сносом записи таблицы; оракул композиции
  (implementer-glm→task-glm→@glm/@sonnet/autoFallback, тождество ПОЛНЫХ
  файлов ролей) и якоря замен (включая сохранённый с твиком старый абзац и
  противоположную норму consultant) проверены в обе полярности. Перечень
  привязок — код `probe.py`, не проза.
- Дано собранное дерево; когда `bash scripts/run_ci_lane.sh
  check:pravila-modelei-998`, затем `npm run check:gen`, затем
  `bash scripts/gen_ci_steps.sh --check`, затем `bash scripts/check_provodka.sh
  "$PWD" contracts/998-pravila-modelei.md`; тогда каждая команда rc 0. Lane
  исполняет пробу целиком; отсутствие ключа — именованный отказ lane-runner,
  не декларативный green.
- Правило соседних контрактов; когда на собранном дереве
  `npm run --silent check:antiplacebo -- --scope check_provodka`; тогда rc 0:
  каталог пробы — легальный probe-only 034 и не ломает scoped-гигиену; полные
  копии конфига и ролей в деревьях семьи `fixtures/gen-harness/` остаются
  согласованы (их положительный контроль — тот же `--check` rc 0). Чистота
  зон подтверждается одиночным (не параллельным) прогоном precision-гейта:
  шум `lib_zones` при параллельном запуске доказательством не считается.

## Модель угроз

ЗАЩИЩАЕТ:
- От расхождения правил выбора модели по документам: уставные места несут ссылку,
  содержание живёт только в `config/agent_models.json` §routing; структурные
  якоря пробы (удаление старых строк целиком, ссылка ВМЕСТО абзаца, полярность
  нормы) ловят дрейф в CI.
- От routing, называющего несуществующие роли/тиры, и от удаления роли, на
  которую routing ссылается: именованный отказ (routing, `rules[N]`, нарушитель)
  в `--check` (CI) и в `--prompt` (каждая сессия) — fail-closed обеих точек.
  Каждая файловая проверка — СВОЯ клетка с СВОИМ мутантом (К1.24, критик
  круг 3): файл роли при живой таблице и живых ссылках routing (клетки
  gen_reject_missing_role_file + model_missing_role_file, обманка
  role_file_blind) и общий table→file на роли без routing-ссылок (клетка
  gen_reject_unreferenced_role_file); снос обеих проверок или любой из них
  поодиночке красен именованной клеткой.
- От ослабления границы языка — закрытый перечень ветвей инварианта 1
  (23 ветви: отсутствие секции; routing не объект; rules отсутствует/не
  массив/пуст; неизвестные ключи routing и правила; правило не объект;
  class число/пустой/отсутствует; role число/пустая; tier число/пустой;
  нестроковые constraint/until/conditional/emergency; role+tier вместе;
  ни role ни tier; несуществующие роль и тир; удалённая роль): одна ветвь —
  один мутант — одна клетка пробы в обеих точках входа с индексом `rules[N]`
  там, где нарушение живёт в правиле (включая bogus_tier — индекс первого
  tier-правила), перечень в таблице `ROUTING_BRANCHES` кода пробы.
- От рендера-снимка: построчная сверка секции (одно правило = одна строка,
  посторонних строк нет) на правках значений/полей/ЦЕЛЕЙ всех правил,
  набора правил (добавление/удаление/смена формы цели) и удалении
  необязательных полей без остатка устаревшего текста; промпты прочих
  ролей байт-в-байт равны телам их roles/*.md.
- От испорченного оракула: ожидания и инварианты неизменности снимаются в
  память до вызова субъекта; субъект, переписавший config/agent_models.json
  во время прогона (сужение routing), красен; производные .omp/agents и
  modelRoles сверяются `--check`-ом — потеря любой из пяти фаз красна своей
  клеткой (агент расходится содержимым / агент отсутствует / посторонний
  элемент каталога; modelRoles; fallbackChains) с поломкой ровно одной
  производной.
- От тихой потери правила 13.10: композиция implementer-glm→task-glm→
  @glm/@sonnet/autoFallback (живая цепочка) и тождество ПОЛНЫХ файлов ролей.

НЕ ЗАЩИЩАЕТ:
- От содержательно неверных правил в самом routing (воля владельца; правка
  конфига — cognitive-only, ловец — консультант/владелец при ревью и трасса
  фактической модели сессии).
- От отказа самой очереди спавна (Н-315, адрес «очередь автономности» —
  отдельный предмет; проба судит правила и их проводку, не спавн).
- От семантического несоответствия класса и цели: сверка судит существование
  ссылок и структуру, не смысл классов работы.
- От смыслового остатка замен сверх структурной области (соответствие СМЫСЛА
  ссылки заменённому тексту): cognitive-only, ловец — reviewer контракта 998.
- От будущих правок снимочных якорей пробы (заголовок секции, имя task-glm,
  маркеры замен): легитимная смена конфига краснит пробу до её правки —
  правится новым контрактом, не молча.

Конформный вход: деревья с `config/agent_models.json` описанной грамматики и
ролями в `roles/`; валидный контрпример — расхождение на конформном входе при
инвариантности к значениям `class`/`constraint`/`until`/`why`. Ожидания сняты
до субъекта; каталог субъекта как оракул не перечитывается; изолированные
деревья — tmp, не sandbox от чужого uid.

## Зоны и порядок

ЗОНА architect: contracts/998-pravila-modelei.md fixtures/pravila_modelei_998/
ЗОНА implementer: roles/implementer-glm.md config/agent_models.json scripts/roles.ts scripts/gen-harness.ts roles/orchestrator.md roles/consultant.md decisions/002-raskladka-modelei-dorogoe-tochechno.md decisions/005-kritik-na-top-chuzogo-semeistva.md AGENTS.md registry/ci-steps.tsv .omp/config.yml .omp/agents/implementer-glm.md .omp/agents/consultant.md .omp/agents/orchestrator.md
ЗОНА orchestrator: .github/workflows/ci.yml
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ПЕРЕСЕЧЕНИЕ implementer: scripts/roles.ts — 002 существующий разбор roles↔tiers↔models неизменен; добавляется только грамматика и сверка routing.
ПЕРЕСЕЧЕНИЕ implementer: scripts/roles.ts — 010 разбор ролей уникален, второй не заводится.
ПЕРЕСЕЧЕНИЕ implementer: scripts/gen-harness.ts — 003 производные агентов из ролей неизменны; добавляется только рендер routing в --prompt orchestrator.
ПЕРЕСЕЧЕНИЕ implementer: scripts/gen-harness.ts — 054 существующие фазы и режимы неизменны; добавляется только рендер routing в --prompt orchestrator.
ПЕРЕСЕЧЕНИЕ implementer: config/agent_models.json — 052 существующие models/tiers/roles/why неизменны и без машино-специфичных путей; новый тир task-glm, запись roles.implementer-glm, снятие двух until.
ПЕРЕСЕЧЕНИЕ implementer: .omp/config.yml — 002 только блоки modelRoles/fallbackChains; правка — перегенерацией генератора из config/agent_models.json.
ПЕРЕСЕЧЕНИЕ implementer: .omp/config.yml — 005 только блоки modelRoles/fallbackChains; правка — перегенерацией генератора из config/agent_models.json.
ПЕРЕСЕЧЕНИЕ implementer: .omp/config.yml — 010 только блоки modelRoles/fallbackChains; правка — перегенерацией генератора из config/agent_models.json.
ПЕРЕСЕЧЕНИЕ implementer: .omp/config.yml — 012 только блоки modelRoles/fallbackChains; правка — перегенерацией генератора из config/agent_models.json.
ПЕРЕСЕЧЕНИЕ implementer: .omp/config.yml — 025 только блоки modelRoles/fallbackChains; правка — перегенерацией генератора из config/agent_models.json.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/implementer-glm.md — 002 производная роли из roles/, перегенерируется генератором.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/implementer-glm.md — 003 производная роли из roles/, перегенерируется генератором.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/implementer-glm.md — 005 производная роли из roles/, перегенерируется генератором.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/implementer-glm.md — 010 производная роли из roles/, перегенерируется генератором.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/implementer-glm.md — 011 производная роли из roles/, перегенерируется генератором.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/consultant.md — 002 производная роли из roles/, перегенерируется генератором.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/consultant.md — 003 производная роли из roles/, перегенерируется генератором.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/consultant.md — 005 производная роли из roles/, перегенерируется генератором.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/consultant.md — 010 производная роли из roles/, перегенерируется генератором.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/consultant.md — 011 производная роли из roles/, перегенерируется генератором.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 002 производная роли из roles/, перегенерируется генератором.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 003 производная роли из roles/, перегенерируется генератором.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 005 производная роли из roles/, перегенерируется генератором.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 010 производная роли из roles/, перегенерируется генератором.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 011 производная роли из roles/, перегенерируется генератором.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 050 производная роли из roles/, перегенерируется генератором.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 061 производная роли из roles/, перегенерируется генератором.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 068 производная роли из roles/, перегенерируется генератором.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 069 производная роли из roles/, перегенерируется генератором.
ПЕРЕСЕЧЕНИЕ implementer: AGENTS.md — 002 уставные правила не расширяются; только замена дубликатов ссылкой.
ПЕРЕСЕЧЕНИЕ implementer: AGENTS.md — 010 топология ролей не меняется.
ПЕРЕСЕЧЕНИЕ implementer: AGENTS.md — 027 только два названных абзаца инварианта 5.
ПЕРЕСЕЧЕНИЕ implementer: AGENTS.md — 028 дом сессии не затрагивается.
ПЕРЕСЕЧЕНИЕ implementer: AGENTS.md — 074 только два названных абзаца инварианта 5; строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ в теле коммита дословно.
ПЕРЕСЕЧЕНИЕ implementer: decisions/002-raskladka-modelei-dorogoe-tochechno.md — 003 только строка решения.
ПЕРЕСЕЧЕНИЕ implementer: decisions/005-kritik-na-top-chuzogo-semeistva.md — 003 только строка решения.
ПЕРЕСЕЧЕНИЕ implementer: roles/consultant.md — 029 только §Модель.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 072 только норма-строка инварианта 7.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 010 топология ролей не меняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 012 только норма-строка инварианта 7.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 026 только норма-строка инварианта 7.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 027 только норма-строка инварианта 7.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 028 только норма-строка инварианта 7.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 029 только норма-строка инварианта 7.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 031 только норма-строка инварианта 7.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 037 только норма-строка инварианта 7.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 038 только норма-строка инварианта 7.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 050 только норма-строка инварианта 7.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 061 только норма-строка инварианта 7.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 068 только норма-строка инварианта 7.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 069 только норма-строка инварианта 7.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 074 только норма-строка инварианта 7.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 094 только норма-строка инварианта 7.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 095 только норма-строка инварианта 7.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 104 только норма-строка инварианта 7.
ПЕРЕСЕЧЕНИЕ implementer: AGENTS.md — 011 только два названных абзаца инварианта 5.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 099 только норма-строка инварианта 7.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 100 только норма-строка инварианта 7.
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 084 одна step-строка ниже, без внешних деклараций.
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 087 одна step-строка ниже, без внешних деклараций.
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 088 одна step-строка ниже, без внешних деклараций.
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 090 одна step-строка ниже, без внешних деклараций.
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 092 одна step-строка ниже, без внешних деклараций.
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 093 одна step-строка ниже, без внешних деклараций.
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 094 одна step-строка ниже, без внешних деклараций.
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 095 одна step-строка ниже, без внешних деклараций.
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 103 одна step-строка ниже, без внешних деклараций.
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 994 одна step-строка ниже, без внешних деклараций.
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 997 одна step-строка ниже, без внешних деклараций.
ПЕРЕСЕЧЕНИЕ implementer: registry/ci-steps.tsv — 083 одна step-строка ниже, без внешних деклараций.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 088 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 994 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 производная материализация CI-step 998.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 997 производная материализация CI-step 998.

Architect: контракт и красное предъявление → pre_critic rc 0 → critic → freeze →
implementer: роль, конфиг, roles.ts/gen-harness.ts, дубликаты, consultant, норма
orchestrator, перегенерация производных, step-строка реестра → orchestrator:
`bash scripts/gen_ci_steps.sh --write` в той же кандидатной ветке до PR-CI (Н-306) →
scoped/CI → adversary/reviewer → done. Коммит AGENTS.md без дословной строки владельца в
теле — обход устава, отвергается ревью. Код реализации architect в репо не вносит;
доказательство достижимости живёт в одноразовой копии вне дерева.

## ПРОВОДКА

ПРОВОДКА:
- role=roles/orchestrator.md «Выбор роли субагента — по routing `config/agent_models.json` (правила рендерятся генератором в промпт оркестратора); правило ниже памяти сессии не создаётся и не обходится; при отказе спавна — доклад причины консультанту, не смена роли (Н-315).»
- guard=fixtures/pravila_modelei_998/probe.sh

ПРОВОДКА-ЭНФОРСМЕНТ: гард несёт структурные следствия нормы: наличие норма-строки
в roles/orchestrator.md (клетка orchestrator_role_norm красна на HEAD — роль без
нормы отвергается), рендер правил в промпт оркестратора, fail-closed обеих точек
входа, сверка ссылок и производных. Поведенческое исполнение нормы («выбор по
routing; при отказе спавна — доклад, не смена роли») живёт в роли role-каналом;
отсутствие нормы до правки доказано красным прогоном. Проба включается
implementer-ом в registry/ci-steps.tsv строкей ниже; исключение «внешний CI» для
неё не заявляется.

```text
step	check:pravila-modelei-998	10	bash fixtures/pravila_modelei_998/probe.sh
```

Оркестратор материализует workflow до PR-CI; guard не считается доставленным без
исполнения lane.

## Незаполненные требования:
нет
