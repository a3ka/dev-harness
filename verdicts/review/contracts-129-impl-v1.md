FAIL
OBJECT=f977f6ee000d6228b38f94f3721349bb0052a9f3
Резюме: батарея зелёная, обхода стенда нет, зона чиста, но возвращаемый хуком список нарушает
замороженный инвариант 2 (примарий выброшен), а коммит утверждает обратное (R129-1); плюс
ACCIDENTAL-ветвь без потребителя (R129-2). Находки — /tmp/dev-harness-verify/Rev129/review.md
(reslop, status: ready).

Судья: reviewer Rev129, круг 1 из 3 (scoped). Контракт: frozen/contracts/129/1. Реализация:
wip/129/implementer @ f977f6ee0. Клоны: /tmp/dev-harness-verify/Rev129/h (main f232007bd +
наложенный файл реализации), /tmp/dev-harness-verify/Rev129/h0 (main без файла; потом
checkout frozen/contracts/129/1). PYTHONDONTWRITEBYTECODE=1.

## Находки (класс у каждой)

- R129-1 — БЛОКИРУЕТ. Семантика, инвариант 2 + п.7 «заявленное = сделанное». Строки 111,121:
  `model: [target, ...tail.filter(...)]` отбрасывает `patterns[0]`; контракт требует
  `[<запасная>, ...patterns]`. Лог omp в стенде: реализация `"requested":["stub-zai/glm"]`,
  честная модель `"requested":["stub-zai/glm","stub-anthropic/opus"]`. Коммит пишет «[селектор
  fallback тира, ...patterns]». Различие ИСХОДА в стенде не построено (мир x-stale: оба
  варианта failed — P в cooldown omp); различие интерфейса хука наблюдаемо.
- R129-2 — БЛОКИРУЕТ (норма 050, ACCIDENTAL, все три части названы). Строки 94-95,
  `snapshot ?? event`: свойство не требуется контрактом/клетками/приёмкой; простая форма
  `event.message` (честная модель) — `--model` rc 0 «cells=6 red=0».
- R129-3 — совет: строка 117 `target === primary` покрыта строкой 119.
- R129-4 — не implementer, оркестратору: `pre_critic.sh` на main rc 1 (гейт предпосылок 122,
  залендён после заморозки); на дереве frozen/contracts/129/1 rc 0.

## Проверки ревьюера по одной

1. Область правки — ЧИСТО. `git log 4ebea3468..f977f6ee0` — 1 коммит, автор implementer;
   `git diff --name-only main...f977f6ee0` → только `.omp/extensions/fallback-route.ts`
   (зона frozen). Батарея и контракт с заморозки не менялись:
   `git diff --stat frozen/contracts/129/1^{commit} HEAD -- contracts/129-… fixtures/…/fallback_subagent_129/`
   → 0 строк.
2. Сырой вывод — мои прогоны (ниже) совпали с отчётом исполнителя по каждому rc и числу.
3. Проверка не подогнана: implementer файлы батареи/фикстур не трогал (п.1).
4. Красное предъявлено: тот же main без файла → rc 1 «cells=6 red=2» (c2, c6).
5. Атомарность: один коммит со ссылкой на 129.
6. Норма не тронута: нормативных документов в диффе нет.
7. Свои меры: `jq` по source.json → `[11,13]` (стабов 11, пар 13) — совпадает с выводом
   `--stabs`; 13 строк `caught` пересчитаны поштучно.

## Прогоны (rc и числа, мои)

- `battery.py` (дерево main + файл реализации) → rc 0, «cells=6 red=0» (16 с).
- `battery.py --subject ../h0` (то же дерево без файла) → rc 1, «cells=6 red=2»:
  `FAIL c2-sosed-cooldown: ребёнок failed (exit 1), ожидался completed`,
  `FAIL c6-zapasnaja-validacija: ребёнок failed (exit 1), ожидался completed`.
- `battery.py --model` → rc 0, «cells=6 red=0».
- `battery.py --stabs` → rc 0, «stubs=11 pairs=13 uncaught=0».
- `battery.py --subject /nonexistent` → rc 2, «NOT_IMPLEMENTED: у субъекта /nonexistent нет
  config/agent_models.json».
- `env PATH=/usr/bin:/bin python3 battery.py` → rc 2, «NOT_IMPLEMENTED: нет omp в PATH …».
- `check_threat_model.sh . contracts/129-…` → rc 0 (ЗАЩИЩАЕТ 8, НЕ ЗАЩИЩАЕТ 6).
- `pre_critic.sh contracts/129-…` → main rc 1 (R129-4); дерево frozen rc 0.
- Одноразовый эксперимент `/tmp/dev-harness-verify/Rev129/exp.py` (мир x-stale): реализация →
  failed, честная модель → failed, без расширения → completed на P; лог «requested» — R129-1.

## Обход (ОБХОД стенда) — НЕ НАЙДЕН

grep по файлу на `stub|M129|SIB129|127.0|localhost|zai|anthropic|opus|glm|slow` — только
комментарий строки 74 (`@slow` как пример). Зашитого перечня провайдеров/тиров нет: тир — из
`modelRole`, цель — `tiers[..].fallback` → `models` одного config/agent_models.json по
расположению файла. Сигнал — 429 + `retry-after-ms` > 300000 (inv 1, 4); подмена условна
только записью исчерпания провайдера `patterns[0]` с неистёкшим сроком (inv 2: состояние F
не проверяется ни в одну сторону); провайдер цели ≠ исчерпанному (inv 3); реестр на
globalThis(Symbol.for) со сроком `now+N`, рост — по числу провайдеров; таймеров, повторов,
спавнов нет (grep `setTimeout|setInterval|spawn(|exec(` — пусто) (inv 5). R-1/R-2 не
переоткрываю.

## Реальная загрузка и побочные эффекты

- `omp --mode rpc --no-ui --no-session --no-extensions --extension <файл> --no-skills
  --no-rules --no-tools --no-lsp` (cwd `/tmp/dev-harness-verify/Rev129/load/cwd`, свой
  `PI_CODING_AGENT_DIR`, stdin EOF) → rc 0, строк «Failed to load extension» — нет.
  Негативный контроль (битый .ts) → «Failed to load extension … 2 errors building».
- Вместе со spawn-guard.ts и path-guard.ts → «failed to load» 0 строк, rc 0.
- Побочки: grep `writeFile|appendFile|fetch|process.env|child_process` — пусто; единственное
  чтение — config/agent_models.json; секретов/сети нет. В живой `.omp/extensions` не ставил.

## Паразитная сложность (050) — артефакт `.omp/extensions/fallback-route.ts`

(1) свойство: Frontier (2), инварианты 1–5 — ESSENTIAL как модуль; (2) состояние — карта
исчерпаний на globalThis, явно названа (Symbol.for) и видна в `note` возврата хука; (3) при
правке того же свойства меняется 1 файл (+ порог вместе с .omp/config.yml — оговорено
контрактом), дифф число не увеличил; (4) интерфейс — два хука и один читаемый файл, без env и
флагов, работа за ним — разбор хода, реестр, разрешение тира: модуль глубокий; (5) потребитель
— строка приёмки 4; грамматика config/agent_models.json не дублирует чужую логику, кроме
снятия `@` (как у spawn-guard/честной модели). ACCIDENTAL внутри модуля — R129-2, R129-3.

ПРОВОДКА: guard=battery.py — существует, судит именно этот предмет; проводка в CI — за
оркестратором (R-2, ПРОВОДКА-ЭНФОРСМЕНТ), не блокер.
