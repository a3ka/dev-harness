accept
OBJECT=250f46dc61166df88c1611a2398c37e57192319b
КЛАСС=кодовый; риск=обычный — подтверждён: предмет меняет двери процесса (make_task/freeze_contract/pre_critic/done_contract/check_architecture_contract), права/роли БД, авторизация, деньги, ПД/health и юридически значимые действия не затрагиваются (контракт:4 «КЛАСС РИСКА: обычный»); оснований для повышения нет.
СУД: repo=dev-harness; предмет=187; фаза=контракт v2 (УЗКИЙ вызов критика ПОСЛЕ АРБИТРАЖА о границе — слово владельца 2026-11-11 ~18:20 UTC, AGENTS.md §Арбитр); роль=critic; вызов=узкий 2/2 фазы v2, 5-й по предмету (кап 5 исчерпан этим вызовом); модель-план=zai/glm-5.3 (тир apex-sol); сессия=Crit187n; модель-факт=zai/glm-5.3; SHA=250f46dc61166df88c1611a2398c37e57192319b; предыдущий=verdicts/critic/contracts-187-v2-r1.md (FAIL, OBJECT 03a69e82e), затем арбитраж verdicts/arbitration/contracts-187-v2-granica.md (титул «(контракт 187)», модель-факт openai-codex/gpt-6-astra); исключение=узкий вызов после арбитража (только пп. 1–3 решения арбитра).

# Вердикт критика — контракт 187 v2: узкий вызов после арбитража

Кандидат: tip `wip/187/architect` `250f46dc6` (в моём клоне `/tmp/dev-harness-verify/Crit187n/repo`, сверен `git rev-parse`), два коммита `Arch187Fix2` поверх `8f2de864d`: `ec0acbb82` (контракт, 15 строк) и `250f46dc6` (workflow_probe.py, +47/−6). Дельта касается только `contracts/187-arhitektura-v-processe.md` и семьи `fixtures/workshop_project/architecture_process_187/` (`git diff --stat`, 2 файла). Запись оркестратора — origin/main HANDOFF строка 2 (сессия=ожидается → дополнена фактом `сессия=Crit187n; модель-факт=zai/glm-5.3` в заголовке этого вердикта). `verdicts/critic/contracts-187-v2.md` в origin/main отсутствует (`git ls-tree`: только `contracts-187-v1*.md`, `contracts-187-v2-r1.md`); vmax `frozen/contracts/187/*` = 1 → имя заморозки по канону.

Область — ТОЛЬКО исполнение пп. 1–3 арбитража (замер M4–M6 дословно по командам арбитра, на OBJECT). Полные `--model`/`--stabs` — проверка сохранения батареи; `--repo .` — заявленная краснота до реализации. Новых классов не открываю: находок вне пунктов арбитра нет, кроме совета ниже. Совпадение модели критика с моделью автора отказа не даёт (контракт 166, §Независимость: выбор по назначению роли в config/agent_models.json); судится текст автора, не мой прежний вердикт — спор сторон решён арбитром другой модели.

## Пункт 1(a) — union-отказ семантический: ЗАКРЫТ

Наблюдатель `locate-union-foreign` (`workflow_probe.py:241-251` `refusal_ok`) требует сам код `ARCH_ZONE` (граница слова) и ЛЮБОЙ компонент объединения в позиции атрибуции; проверка rc 1 и отсутствие frozen-тега сохранены (`workflow_probe.py:875, 884-886`). Честный контроль называет не-первый компонент `union[-1]` (`workflow_probe.py:645-647`). Замеры (команды арбитра дословно, cwd=репо на OBJECT):

- M4 (был RED): `python3 -B -c '…p.live=lambda…CompletedProcess([],1,"","ARCH_ZONE: путь app/multi/x.js отнесён моделью к компоненту api.documents, а строка называет api.identity\n")…'` → `GREEN locate-union-foreign: rc=1 expected=1 reason=ARCH_ZONE`, `CELLS=1 STABS=0 FAILURES=0`, rc 0.
- M5 (был GREEN): тот же вход с `PATH_WITHOUT_COMPONENT: … к компоненту api.hub` → `RED locate-union-foreign: rc=1 expected=1 reason=ARCH_ZONE output='PATH_WITHOUT_COMPONENT: … api.hub\n'`, `CELLS=1 … FAILURES=1`, rc 1. Клетка проверяет `ARCH_ZONE`, а не любой отказ.
- Свойство множества, не перестановка литерала (мои пробы): `api.hub` (первый) → GREEN; `api.effects` (последний, имя честного контроля) → GREEN; `ARCH_ZONE` с вне-объединённым `api.identity` → RED (rc 1). Новый случайный литерал не закреплён.
- Стабы: `union-refusal-wrong-code caught @ locate-union-foreign` (иной код отказа), `union-any-component` и `locate-first-match-component` по-прежнему caught (`--stabs`).

## Пункт 1(b) — выданный пак при ARCH_CLASS_MISSING: ЗАКРЫТ

Наблюдатель судит реальный канал выдачи — строку заголовка пака в stdout (`PACK_MARKER = '=== make_task contract='`, `workflow_probe.py:192-196`; проверка `workflow_probe.py:876-877` и в stabilization `:896-898`), а не флаг субъекта. Замеры:

- M6 (был GREEN): команда арбитра дословно (настоящая дверь `make_task` исполняется, затем rc→1 + дописан `ARCH_CLASS_MISSING`) → `RED task-class-missing: rc=1 expected=1 reason=ARCH_CLASS_MISSING output='=== make_task contract=777 role=architect kind=task ===\n…'`, `PUBLIC_DOOR_RC=0 PACK_EMITTED=True CELL_RUNNER_RC=1`, rc 1. Поздний отказ над выданным паком больше не зелёнит клетку.
- Честный ранний отказ зелёный: `--model`/`--stabs` → `GREEN task-class-missing: rc=1 expected=1 reason=ARCH_CLASS_MISSING` (без пака).
- Стабы: `task-class-skip caught @ task-class-missing`, `task-pack-then-refuse caught @ task-class-missing` (`--stabs`).
- Не ослаблено: положительная выдача пака (`task-valid` GREEN со структурным контролем `PINNED_BRIEF_187`/`WRONG_HEAD_BRIEF_187`/`STRUCTURE.md`/`RULES_FROM_PIN_187`, `workflow_probe.py:878-884`) и done-контроль отсутствия тега (`:884-886`, `done-class-missing` GREEN в `--model`) — обе проверки на месте.

## Пункт 1(c) — не ослаблен

- `--repo .`: `GREEN pin-foreign-hex: rc=1 expected=1 reason=ARCH_PIN`.
- `--stabs`: `pin-net-for-hex caught @ pin-foreign-hex`.
- Мой контроль M8 (замена только имени в результате настоящей двери `ARCH_PIN`→`ARCHITECTURE_NET`, команда арбитра дословно) → `RED pin-foreign-hex: rc=1 expected=1 reason=ARCH_PIN output='…ОТКАЗ: ARCHITECTURE_NET: коммит deadbeef…'`, rc 1.

## Остаточные риски и «НЕ ЗАЩИЩАЕТ» — ЗАКРЫТО

`contracts/187-arhitektura-v-processe.md:95-96` несут обе формулировки арбитра ДОСЛОВНО (программная сверка кавычек «НЕ ЗАЩИЩАЕТ…» из арбитражного файла со строками контракта: VERBATIM ×2, отличие только маркер булетра и точка в конце). Ловцы названы конкретно: хранитель 186 (сверка exact pin и diff модели), reviewer реализации 187 (числа 26/22 — не порог допуска; отдельно `deps-door-refusal` rc 2 ARCH_DEPS и `brief-npm-doorway` rc 0, мутации отказа npm/прямого node), CI (полная батарея `--repo .`). Справочный статус чисел 26/22 обозначен («справка, не порог допуска»).

Обязательства v2-r1 не ослаблены: `git diff 8f2de864d..250f46dc6 -- contracts/187-arhitektura-v-processe.md` = ровно 2 ханка — (1) перечни клеток/стабов и счёты (55→57 стабов; ожидание `компоненту api.hub` заменено семантическим «rc 1 с кодом ARCH_ZONE и именем ЛЮБОГО компонента объединения» — это и есть приказ арбитра 1(a); bullet ARCH_CLASS_MISSING усилен наблюдателем канала выдачи — приказ 1(b)), (2) «НЕ ЗАЩИЩАЕТ»: старый bullet про 26/22 заменён дословной формулировкой арбитра, добавлен второй. Список 21 красной (17+4), 58 клеток, живые клетки, ПЕРЕСЕЧЕНИЯ — без изменений. Файл семьи — только `workflow_probe.py` (+47/−6: `refusal_ok`, `PACK_MARKER`, 2 стаба, `union[-1]`), обёртка и миры не тронуты.

## Гейты и батареи (rc исполнением, cwd=OBJECT)

- `bash scripts/pre_critic.sh contracts/187-arhitektura-v-processe.md` → rc 0 («ok гейт предпосылок…», «КРИТИК: дверь зелёная»).
- `bash scripts/check_precision_gate.sh . contracts/…` → rc 0 (OK; stderr-шум lib_zones о временных файлах на результат не влияет).
- `bash scripts/check_threat_model.sh . contracts/…` → rc 0 («секция валидна (ЗАЩИЩАЕТ 5 буллет(ов), НЕ ЗАЩИЩАЕТ 5 буллет(ов))»).
- `bash scripts/check_ceilings.sh .` → rc 0; `bash scripts/check_provodka.sh . contracts/…` → rc 0.
- Батарея 187: `--model` → rc 0, `CELLS=58 STABS=0 FAILURES=0 SKIPPED=0`; `--stabs` → rc 0, `CELLS=58 STABS=57 FAILURES=0 SKIPPED=0`, 57 строк caught / 0 ZHIV; `--repo .` → rc 1, `CELLS=58 STABS=0 FAILURES=21 SKIPPED=2` — красны РОВНО заявленные 17 (`locate-json-conform`, `locate-json-foreign`, `zone-comma-list`, `path-unplaced-product`, `check-green-status-field`, `brief-npm-doorway`, `pin-symbolic`, `pin-lock-empty`, `model-root-unset`, `deps-door-refusal`, `precritic-full-zone`, `precritic-line-missing`, `precritic-draft`, `freeze-class-missing`, `precritic-class-missing`, `operation-optional`, `component-required-no-local`) + 4 из v2-r1 (`locate-union-conform`, `locate-union-foreign`, `task-class-missing`, `done-class-missing`) — список строкой в точности совпадает с контрактом:67; SKIP live-real-pin/live-real-union именованные (не зелёные).
- Батарея 170 прежняя: `--model` rc 0; `--repo .` rc 0.
- Счёты второй мерой: `python3` по модулю зонда → `CASES=58 STABS=57`, union = {api.hub, api.documents, api.effects} ↔ контракт:63 «58 клеток, 57 стабов», :65 «каждая из 58 клеток», :67 «57 обманных стабов пойманы».

## Советы (не блокируют)

- СОВЕТ (вне пунктов арбитра, без механических последствий): коммит `ec0acbb82` несёт заголовок и строку РАЗРЕШИЛ-ВЛАДЕЛЕЦ от более раннего v+1 слова владельца («дверь 187а на настоящей модели», ~13:05 UTC), тогда как его содержание — исправления блока 1 арбитража (~18:20 UTC). Provenance-строка в теле коммита ссылается не на то решение, которое фактически исполнено; заморозке не мешает (freeze читает вердикт и контракт), но в будущих правках указывать фактическое основание.

## Итог

Пп. 1–3 арбитража исполнены и доказаны живыми прогонами (M4 зелёный, M5/M6 красные, свойство множества, стабы caught, дословные «НЕ ЗАЩИЩАЕТ» с ловцами), (c) не ослаблен, обязательства v2-r1 сохранены, гейты и обе батареи в заявленных состояниях. Блокирующих находок по пунктам арбитра нет — заморозка разрешена. Бюджет предмета этим вызовом исчерпан; `--repo .` остаётся заявленно красным до реализации — переход в зелёное состояние судит ревьюер реализации с ловцами deps/brief из «НЕ ЗАЩИЩАЕТ».
