РЕШЕНИЕ
OBJECT=0f04486dc8978f30bdaab102e42b8071836b7c0c
СУД: repo=dev-harness; предмет=144; фаза=контракт (арбитраж по исчерпанию critic 2/2, повтор причины №2); роль=arbiter; вызов=1; модель-план=anthropic/claude-fable-5-1; сессия=Arb144 (id 01a1841a-f9ed-7512-a61e-a8ce14d065f4); модель-факт=anthropic/claude-fable-5-1 (model_change журнала Arb144.jsonl, fallback=false); стороны по факту: architect (Fix144a) = zai/glm-5.3, critic (Crit144b) = openai-codex/gpt-6-sol — три разных семейства, семейного совпадения арбитра ни с одной стороной нет; SHA=0f04486dc8978f30bdaab102e42b8071836b7c0c (`git cat-file -t` → commit; один коммит architect поверх main 5653f6d5); предыдущий=`/tmp/dev-harness-verify/Crit144/verdicts/critic/contracts-144-v1.md` (1/2 FAIL), `/tmp/dev-harness-verify/Crit144b/verdicts/critic/contracts-144-v1b.md` (2/2 FAIL); исключение=нет. Коммит/push не делались (запрет задания); файл — в `/tmp/dev-harness-verify/Arb144/verdicts/arbitration/`, в репозиторий его вносит оркестратор.

## Итог по сторонам

**Критик прав по существу и по факту; спор решается в его пользу по пункту «ложная достаточность п.9».** Архитектор прав в том, что вариант (А), предел блоков, `--candidate`, `--station --stabs` и честность §Существующее закрыты и не оспариваются — они не меняются. Арбитраж нашёл **более сильный контрпример, чем оба критика: реальный журнал самого автора (`Fix144a.jsonl`, страж на станции не развёрнут, ни одного блока не было) проходит `--journal` с rc 0** — маркер отказа лежит в выводе `bash` (драйвер батареи напечатал reason), а строка `"toolName": "yield"` есть в любом реальном журнале (toolResult каждого yield). Это не «подделка ребёнком», это штатный журнал — приёмка п.9 в нынешнем виде зеленеет на станции без механизма.

Замеры (cwd `/tmp/dev-harness-verify/Arb144/repo`, `W` = `bash fixtures/workshop_project/agent_zhdet_144/red_agent_zhdet_144.sh`, журналы скопированы read-only из каталога сессий платформы):
- `W --journal /tmp/dev-harness-verify/Arb144/fix144a.jsonl` (реальный, 800 записей, стража нет) → **rc 0** `ИТОГ 144 (живая проба, журнал): отказ дошёл до сессии; свежий yield после отказа записан`.
- `W --journal …/z1.jsonl` (реальная проба без стража) → rc 1 `нет строки «ОТКАЗ park-guard…»`; `…/z2.jsonl` → rc 1 то же.
- `W --journal fixtures/…/zhurnal_obrazec.jsonl` → rc 0 — при этом образец структурно НЕ журнал omp (блоки `tool_call`/`toolName` вместо `toolCall`/`name`; роль `tool` вместо `toolResult`; нет `toolCallId`, `isError`, `details.async`, `[async-result]`).
- Контрпримеры критика: `fake-live.jsonl`, `fake-session.jsonl`, `assistant-echo.jsonl` → rc 0 каждый; `prompt-no-guard.jsonl` → rc 1. Факты вердикта 2/2 подтверждены полностью (`park_guard_144.py:563–574`: `text.find(OTKAZ_MARKER)` по всему файлу, затем подстрока `"toolName":"yield"` в хвосте; `--station` → `run_cell` с синтетическим ctx в двух cwd, `:473–488`).

## Q1. Структура журнала — замер по реальным файлам

Реальный формат (`…/sessions/--home-harness-dev-harness--/<ведущая>/Arch144/Arch144.Probe144z1.jsonl`, 26 записей; `Arch144.jsonl`; `Fix144a.jsonl`): JSONL, одна запись = объект `{type, id, parentId, timestamp, …}`. Типы: `title`, `session` (`version:3`, `cwd`, **`parentSession` — абсолютный путь журнала родителя**), `model_change`, `thinking_level_change`, `session_init`, `credential_pin`, `message`, `custom` (`customType: tool_execution_start | session_exit`), `custom_message` (`customType: async-result | custom-message`). Роли `message.role`: `user`, `assistant`, `toolResult`, `developer`. Порядок записей в файле = порядок событий (append-only).

Поля, однозначно идентифицирующие (а)–(д):

| Шаг | Запись | Поля (замер) | Кто пишет |
| --- | --- | --- | --- |
| (а) авто-фоновое задание ребёнка | `message.role=toolResult`, `toolName=bash`, `toolCallId=<id вызова>` | `details.async = {state:"running", jobId:"bg_1276", type:"bash"}`; текст `Backgrounded as job bg_1276…` (z1 #10) | платформа (`details` — не текст команды) |
| (б) заблокированный терминальный yield | assistant-блок `{type:"toolCall", id:"toolu_…", name:"yield", arguments:{data…}}` (z1 #11) + `message.role=toolResult`, `toolCallId == id блока`, `toolName=yield`, **`isError:true`**, `details:{}`, `content[0].text == reason` побайтово | форма блока `{block:true, reason}` измерена на path-guard: `Arch144.jsonl` #93/#96 — `isError:true, details:{}, text='запись относительным путём без cwd запрещена — Н-85…'` = `reason` из `path-guard.ts:1052` | платформа + обработчик tool_call; текст toolResult **yield** модель не контролирует никогда (обзор 304 yield-результатов: `Result submitted.`, ошибки схемы платформы, `Task aborted…`) |
| терминальность | `arguments.type` НЕ непустой массив строк (инвариант 2; поле в журнале — `arguments`, не `input`) | z1 #11: `arguments:{data:{…}}` | модель (это вход, не свидетельство) |
| (в) результат того же задания | `type=custom_message`, `customType="async-result"`, `details.jobs[*].jobId == jobId из (а)` (`type:"bash"`, `label`, `durationMs`), `content` начинается `<system-notice>\nBackground job bg_1276 has completed` (z1 #17) | платформа |
| (г) свежая сдача | assistant `toolCall name=yield` (терминальный) ПОЗЖЕ (в) + `toolResult toolCallId==id, toolName=yield, isError:false, details.status=="success"`, текст `Result submitted.` (z1 #13; Fix144a #796/#798) | платформа |
| (д) доставка родителю | в журнале **родителя** (`session.parentSession` ребёнка — путь существует, замер) `custom_message async-result`, `details.jobs[*] = {jobId:"<id ребёнка>", type:"task"}`, `content` содержит `<task-result id="<id ребёнка>" agent="…" status="completed">`; у z1 — `status="failed (exit 1)"` + `<error>Background job results arrived after the subagent's last yield…</error>` (Arch144 #155). id ребёнка = basename его журнала без `.jsonl` (`Arch144.Probe144z1`) | платформа родительской сессии |

Подделываемо ребёнком (в штатной работе): текст assistant, аргументы toolCall, **вывод bash в toolResult bash** (именно так зеленеет Fix144a), содержимое файлов, data yield. Не подделываемо штатно: `role=toolResult` для `yield` (текст — платформы/обработчика), `isError`, `toolCallId`-связка, `details.async`, записи `custom_message async-result` и `developer`, журнал родителя.

**Структурный разбор обязателен, подстроки — нет.** Решение: `--journal` разбирает JSONL по записям и проверяет цепочку (а)→(б)→(в)→(г)→(д) с тождеством `jobId` и `toolCallId` и порядком по файлу. Достаточность: rc 0 структурной проверки над файлом, который оркестратор берёт из каталога сессий платформы по id пробы (путь выводит **оркестратор**, не ребёнок; ребёнку путь не сообщается), доказывает измерения 1–3 и доставку. Остаток подделки: намеренная запись ребёнком в append-only журнал платформы вне allowlist path-guard (edit/write и лексические формы bash блокируются Н-85 — замер: даже `/dev/null` отказан; нелексическая запись через интерпретатор — не исключена [INFERENCE по коду path-guard: судится текст команды]). Это осознанный саботаж пробы собственным субагентом с согласованными `toolCallId`/`jobId`; закрыть без подписи журналов платформой (Frontier Д) нельзя — **принимается как остаток** и пишется в §НЕ ЗАЩИЩАЕТ. Исполнитель приёмки п.9 — оркестратор; источник файла — каталог сессий платформы (`<журнал родителя без .jsonl>/<id пробы>.jsonl`), доверенный в этой модели угроз.

Где структурная проверка бессильна (честно): форму `additionalContext` (WARN «снимок недоступен»/«предел блоков») в журнале я не измерил — ни одной записи с таким текстом в выборке нет; по `omp://extensions.md:447–449` оно доставляется «после результатов с developer/system-приоритетом» [INFERENCE: запись `role=developer`]. Парсер п.9 на WARN не опирается: ложность измерения 2 (снимок субагента `null`/без его задания) проявляется как класс «терминальный yield при живом задании прошёл без отказа» — тот же, что у z1.

## Q2. Замкнутый перечень клеток `--journal` (ожидание = rc + именованная причина; числа печатает команда)

Позитивные (rc 0, строка `ИТОГ 144 (живая проба, журнал): задание <J>; отказ yield <id>; [async-result] <J>; свежий yield <id2> успешен; родитель: completed`):
1. **j01-chestnyj** — цепочка (а)…(д) в реальной структуре (перегенерированный `zhurnal_obrazec.jsonl` + `zhurnal_obrazec_roditel.jsonl`). Это и есть п.(7) задания: образец пересобрать по полям таблицы Q1 (блоки `toolCall/name/id/arguments`, `toolResult/toolCallId/toolName/isError/details`, `details.async.jobId`, `custom_message async-result details.jobs`, запись `session` с `parentSession`/id; текст reason — побайтово `header(k)` + `  <jobId> (running)` из модели).
2. **j02-dva-otkaza** — два подряд отказа (модель повторила терминальный yield один раз) → rc 0: цепочка не требует ровно одного отказа, требует отсутствия ПРОШЕДШЕГО терминального yield до (в).

Негативные (rc 1, причина именованная, класс в скобках):
3. **j03-citata-user** (`fake-session.jsonl`) и 4. **j04-citata-assistant** (`assistant-echo.jsonl`) → `отказа park-guard в toolResult вызова yield нет (маркер только в тексте user/assistant)`.
5. **j05-marker-v-bash** — маркер в toolResult `bash` (форма Fix144a: драйвер напечатал reason), yield прошёл → тот же класс «отказа в toolResult yield нет». Ловит подстроку-в-любом-месте и игнор роли/`toolName`.
6. **j06-otkaz-bez-vyzova** — toolResult yield с маркером и `isError:true`, чей `toolCallId` не соответствует ни одному assistant-`toolCall name=yield` → `отказ не привязан к вызову yield (toolCallId)`. Ловит игнор toolCallId.
7. **j07-marker-isError-false** — toolResult yield с маркером, но `isError:false`, `details.status:"success"` → `маркер в успешном результате yield — это не блок`. Ловит игнор `isError`.
8. **j08-net-async-result** — (а),(б),(г) есть, записи `async-result` с `jobId==J` нет → `нет [async-result] задания <J> после отказа (измерение 3 не доказано)`.
9. **j09-chuzhoj-async-result** — `async-result` есть, но `details.jobs[].jobId != J` → тот же класс с именем чужого задания. Ловит игнор тождества jobId.
10. **j10-otkaz-ne-o-zadanii** — перечень reason (строки 2..k+1) не содержит `J` из `details.async` → `отказ не о задании пробы <J>`. Связывает (б) с (а).
11. **j11-yield-proshyol-do-otkaza** — после (а) и до (в) есть терминальный yield с `isError:false` → `терминальный yield <id> при живом задании <J> прошёл без отказа — блок не дошёл до сессии (измерения 1–2 не состоялись)`. Ловит игнор порядка.
12. **j12-z1-bez-strazha** — РЕАЛЬНЫЙ журнал z1, редуцированный по типам записей (оставить `session`, `message`, `custom`, `custom_message/async-result`; убрать `session_init`, `credential_pin`, `model_change`, `thinking_level_change`, `title`, `custom-message`; блоки `thinking` вырезать; поля оставшихся записей не менять; правило редукции записать в osi.md) + родительская запись #155 как `zhurnal_z1_roditel.jsonl` → rc 1 ИМЕННО классом j11 (`yield toolu_017Cv… при живом bg_1276 прошёл без отказа`), не классом «нет строки». Это п.(8) задания.
13. **j13-otkaz-na-sekciyu** — отказ (isError + маркер) на yield с `arguments.type` непустым массивом строк → `отказ на инкрементальную секцию — ложный блок (инвариант 2)`. Ловит игнор терминальности; п.(6) задания.
14. **j14-net-svezhego-yield** — (а),(б),(в) есть, после (в) нет терминального yield с `isError:false` (или он снова заблокирован) → `после [async-result] свежего успешного yield нет (измерение 3: модель не сдала)`.
15. **j15-net-avtofona** — нет toolResult bash с `details.async` → `авто-фонового задания в журнале нет — проба не состоялась`.
16. **j16-roditel-failed** — ребёнок честен, в родительском журнале `<task-result … status="failed (exit 1)">` → `родитель получил failed — результат потерян`; 17. **j17-roditel-bez-zapisi** — записи `async-result` с `jobId==<id ребёнка>` у родителя нет → `доставки родителю нет`.
18. **j18-ne-zhurnal** (`fake-live.jsonl`) — нет записи `type=session` / строки не формата записей → rc 1 `не журнал сессии omp`. (rc 2 остаётся только за «нет пути / нет файла» — иначе rc 2 читается как «повторить».)

Мутанты `--journal` → клетка: подстрока-в-любом-месте → j03/j04/j05; игнор роли/toolName → j05; игнор toolCallId → j06; игнор isError → j07; игнор тождества jobId → j09/j10; игнор порядка → j11 (и j14 для «после (в)»); игнор терминальности → j13; игнор родителя → j16/j17. Физические генераторы мутантов парсера НЕ требуются (парсер — оракул, а не субъект; Н-39 про стабы субъекта): самодоказательство — режим `--journal --cells` (имя на усмотрение architect), прогоняющий все клетки j01–j18 из `source.json` (новый раздел `journal`: `id`, `file`, `roditel`, `rc`, `prichina`) и печатающий `ИТОГ 144 (журнал, клетки): клеток N, сошлось N, расхождений 0`; расхождение = rc или класс причины не тот. Родительский журнал в клетках задаётся явно (`--roditel <jsonl>`), на станции — по умолчанию из `session.parentSession` ребёнка; второй аргумент не обязателен.

## Q3. Остаток и достаточность для freeze

Что НЕ закрывается без деплоя: `--station` доказывает только, что развёрнутый файл грузится фабрикой omp и решает одинаково в реальном cwd (синтетический ctx/snapshot) — оно **не доказывает** ни что hook платформы срабатывает на yield субагента (1), ни что `getAsyncJobSnapshot()` дочерней сессии несёт её задание (2), ни что модель действует по отказу (3), ни доставку родителю (д). Всё это доказывает только п.9 на станции после деплоя и перезапуска. Так и писать.

Достаточно ли для freeze: **да**, при условии структурного п.9 по Q1/Q2 и честных строк ниже. Freeze замораживает спецификацию и её исполняемую приёмку; п.9 — исполняемая, структурно красно-способная команда оркестратора, обязательная **до done**, не до freeze (прецедент 128: `--live` на станции после ленда). Предмет не закрывается (`done`) без п.9 rc 0 над журналом из каталога сессий платформы.

Строка §НЕ ЗАЩИЩАЕТ (заменить последний буллет): «факты платформы до деплоя: `--station` судит синтетический ctx в реальном cwd и НЕ доказывает, что hook видит yield субагента, что снимок несёт его задание и что родитель получает результат — это доказывает только живая проба п.9 (структурный `--journal` по журналу из каталога сессий платформы) после деплоя; до её rc 0 предмет не done; журнал, намеренно дописанный самим субагентом-пробой вне allowlist (согласованные toolCallId/jobId), от проверки не отличим — подпись журналов платформой вне дерева (Frontier Д)».

Критерий неисполнимости: п.7 (оркестратор, станция) rc 0 ∧ `--load` станционного дерева rc 0 ∧ сессии перезапущены, а п.9 даёт rc 1 класса j11 («терминальный yield при живом задании прошёл без отказа») ⇒ измерение 1 или 2 ложно ⇒ вариант (А) неисполним на платформе ⇒ **К ВЛАДЕЛЬЦУ** с Frontier (Б)/(Г) (выбор замены — воля, не инженерия; architect сам Frontier не переключает). Один повтор пробы допускается только для исключения неперезапущенной сессии (операционная ошибка), не для «дожима до зелёного». rc 1 классов j14/j16 (блок был, модель не сдала / родитель failed) — ложно измерение 3: это дефект нормы/модели, не платформы — доклад владельцу без возврата к Frontier, предмет не done.

## Q4. Замкнутый перечень правок architect (amend того же коммита, ветка `wip/144/architect`)

Контракт `contracts/144-agent-zhdet-vechno.md`:
1. п.9 §Приёмочный критерий: заменить описание `--journal` на структурную цепочку (а)–(д) с полями из таблицы Q1; строка успеха; негативные пары — ссылка на клетки j03–j18 с классами причин; z1 → rc 1 именно классом j11; образец → rc 0; источник журнала — `<журнал родителя без .jsonl>/<id пробы>.jsonl` из каталога сессий платформы, путь выводит оркестратор; критерий неисполнимости из Q3 дословно; «до rc 0 п.9 предмет не done».
2. §Конструкция батареи, абзац `--journal`: структурный разбор + режим самопроверки клеток (`--journal --cells` или иное имя) + `--roditel`.
3. §Живые измерения: добавить (д) доставку и явную фразу, чего `--station` не доказывает.
4. §Модель угроз НЕ ЗАЩИЩАЕТ: заменить последний буллет строкой из Q3 (`check_threat_model.sh` обязан остаться rc 0).
5. §Сдача: «done только после п.9 rc 0 на станции (оркестратор)».
Батарея `fixtures/workshop_project/agent_zhdet_144/`:
6. `park_guard_144.py` `run_journal`: структурный парсер по Q1 (записи → индексы по `toolCallId`; (а) по `details.async.jobId`; (б) `toolResult yield isError:true` + текст начинается `OTKAZ_MARKER`, перечень содержит J, вызов терминален; (в) `async-result` с `jobs[].jobId==J` после (б); до (в) ни одного `toolResult yield isError:false`; (г) после (в) `toolResult yield isError:false, details.status=="success"`; (д) родитель — `--roditel` либо `session.parentSession` — `<task-result id="<basename>" … status="completed">`); именованные причины по классам j03–j18; докстринг режимов; rc 1 для «не журнал», rc 2 только нет пути/файла/родителя-по-умолчанию недоступен.
7. `source.json`: раздел `journal` с клетками j01–j18 (файл, родитель, rc, класс причины); режим `--journal --cells`.
8. Файлы клеток (каталог `zhurnal/`): `zhurnal_obrazec.jsonl` перегенерировать по реальной структуре (+ родительский файл); j12 — редуцированный реальный z1 + его родительская запись (правило редукции — в osi.md); остальные — синтетика в реальной структуре.
9. `osi.md`: таблица клеток журнала и карта «мутант → клетка»; `red_agent_zhdet_144.sh` шапка: строка `--journal`.
10. `zadanie_zhivoj_proby.md`: добавить, что журнал пробы — файл платформы по id пробы (путь берёт оркестратор), приёмка включает доставку родителю; текст задачи субагенту не менять по существу.

НЕ меняется: вариант (А) и Frontier; инварианты 1–10; §Грамматика; предел блоков и c19; клетки c01–c19, 20 стабов, `--model/--stabs/--candidate/--load/--station/--station --stabs`, драйвер; `model/park-guard.ts`; раздел «Незаполненные требования: нет»; зоны; норма-строки ролей (на журнал не ссылаются); §Существующее п.1–10.

Периметр ОДНОГО scoped-критика после правки: только пункты 1–10 выше. Команды: `W --journal` на каждой клетке j01–j18 (rc и класс причины), `W --journal --cells` → rc 0, `W --journal /tmp/dev-harness-verify/Arb144/fix144a.jsonl` → rc 1 (класс j05) и `…/z1.jsonl` → rc 1 (класс j11) — оба файла лежат в скратче арбитража; новые журналы критика допустимы только в осях Q2; регрессия `W --model --seed 42`, `W --stabs --seed 42`, `W --station --stabs`, гейты `pre_critic`, `check_threat_model`, `check_ceilings` — rc 0. Находки вне периметра — СОВЕТ владельцу, не блокер. Следующий FAIL — к владельцу; арбитраж accept не даёт и третьего вызова не открывает.

## Принятые остатки
- Намеренная запись субагентом-пробой в журнал платформы вне allowlist — не отличима; принят, в §НЕ ЗАЩИЩАЕТ.
- Форма `additionalContext` в журнале не измерена; парсер на ней не строится.
- Форма блока на `yield` измерена на блоке path-guard для `bash` (тот же механизм tool_call → `isError:true`, текст = reason) — для yield проверится первой живой пробой; расхождение формы = rc 1 с именованной причиной, а не тихий зелёный.

## НЕ ПРОВЕРЕНО
Реализация стража и живая проба на станции (не существуют на этом HEAD); `--model/--stabs/--station` регрессия (не предмет спора; замеры критика 2/2 не оспаривались сторонами); форма записи `additionalContext`; нелексический обход path-guard для записи в каталог сессий (только вывод по коду).

## Сырые команды
- `git -C /tmp/dev-harness-verify/Arch144/repo cat-file -t 0f04486d…` → `commit`; `git clone` → `/tmp/dev-harness-verify/Arb144/repo`, `checkout 0f04486d…`; `git show --stat HEAD` → 30 файлов, 1599 вставок, автор architect.
- `cp <sessions>/Arch144/Arch144.Probe144z1.jsonl /tmp/dev-harness-verify/Arb144/z1.jsonl` (26 записей), `…z2.jsonl` (15), `…/Fix144a.jsonl` → `fix144a.jsonl` (800); разбор `dump.py` — типы/роли/поля, цитированные в Q1.
- `W --journal z1.jsonl` → rc 1; `z2.jsonl` → rc 1; `fix144a.jsonl` → **rc 0**; `zhurnal_obrazec.jsonl` → rc 0; `fake-live` → rc 0; `fake-session` → rc 0; `assistant-echo` → rc 0; `prompt-no-guard` → rc 1 (вывод — в разделе «Итог по сторонам»).
- Обзор форм toolResult yield по всем журналам ведущей сессии: 304× `isError:false, status:success, "Result submitted."`; `isError:true` — только тексты платформы (ошибки схемы, «cannot contain both data and error»); `status:aborted` — 1.
- `<task-result … status="…">` в Arch144.jsonl: `completed` ×4, `failed (exit 1)` ×1 (Probe144z1), все — `custom_message async-result`, `details.jobs[].type:"task"`.
- `grep` `path-guard.ts`: `{ block: true, reason: result.reason }` (:1324), причина Н-85 (:1052) = текст toolResult #93 Arch144.jsonl побайтово.
- `model_change` журналов: Arb144 anthropic/claude-fable-5-1; Fix144a zai/glm-5.3; Crit144b openai-codex/gpt-6-sol (fallback=false у всех).
