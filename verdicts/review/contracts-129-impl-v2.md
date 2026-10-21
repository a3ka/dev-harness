accept
OBJECT=2974de91b878e36eca00ccbff9b55f6d5b5ceadc
Резюме: блокеры круга 1 закрыты по существу. R129-1 проверен на реальном стенде omp: в `requested`
ребёнка запасная модель стоит первой, за ней исходный список целиком. R129-2 и R129-3 удалены.
Батарея и обходы нового кода зелёные; файл круга 1 на тех же обходах красный. Нового блокирующего
дефекта нет. Советы R129b-1 и R129b-2 — в /tmp/dev-harness-verify/Rev129b/review.md (reslop,
status: ready).

Судья: reviewer Rev129b, круг 2 из 3 (scoped, только дельта f977f6ee0..2974de91b).
Контракт: frozen/contracts/129/1. Клоны: /tmp/dev-harness-verify/Rev129b/h (main a490cab94 + файл из
OBJECT, sha256 5381a3c0…aded7c), /tmp/dev-harness-verify/Rev129b/h0 (main без файла).
PYTHONDONTWRITEBYTECODE=1. В живой .omp/extensions не ставил, в основной чекаут не писал.

## Находки и их классы

- R129-1 (круг 1) — ЗАКРЫТА. Строка 122: `[target, ...list]`.
- R129-2 (круг 1) — ЗАКРЫТА. Строки 94–95: только `event.message`.
- R129-3 (круг 1) — ЗАКРЫТА. Проверка `target === primary` удалена, случай покрывает строка 120.
- R129b-1 — совет. `{message: null}` теперь даёт TypeError, в круге 1 было `turn?.role`. Такой формы
  нет ни в контракте, ни в клетках, ни в приёмке.
- R129b-2 — совет. Дубли `[F, P, F]` соответствуют букве инварианта 2. Как omp обращается с повтором
  в цепочке ребёнка, на стенде не проверено.

## Проверки ревьюера по одной

1. Область правки — чисто. `git diff --name-only main...2974de91b` → только
   `.omp/extensions/fallback-route.ts` (зона frozen). `git log main..2974de91b` → 2 коммита, оба с автором implementer.
   Дельта круга 2: 1 файл, +12/−11.
2. Сырой вывод — мои прогоны ниже, с rc.
3. Проверка не подогнана: `git diff --stat frozen/contracts/129/1^{commit} HEAD --
   contracts/129-… fixtures/…/fallback_subagent_129/` → пусто.
4. Красное предъявлено: тот же main без файла → rc 1 «cells=6 red=2». Обходы на файле круга 1
   красные (R129-1/2).
5. Атомарность: один коммит круга 2 со ссылкой на 129 и на R129-2.
6. Норма не тронута: нормативных файлов в дельте нет.
7. Своя мера: `jq` по source.json → `[11,13]`, совпадает со «stubs=11 pairs=13». Ходы ребёнка в c5
   посчитал по requests.jsonl стенда (`sib:false, turn:true`): 2 при пределе ≤ 2.
   Заявление коммита «[target,...patterns] без выбрасывания primary; snapshot ?? event убран»
   совпадает с кодом и с логом стенда.

## Прогоны (rc и числа, мои)

- `battery.py` (h, файл из OBJECT, P129_KEEP=1) → rc 0, «cells=6 red=0». Повтор → rc 0, «cells=6 red=0».
- `battery.py --subject h0` (без файла) → rc 1, «cells=6 red=2»: FAIL c2-sosed-cooldown, FAIL
  c6-zapasnaja-validacija («ребёнок failed (exit 1), ожидался completed»).
- `battery.py --model` → rc 0, «cells=6 red=0».
- `battery.py --stabs` → rc 0, «stubs=11 pairs=13 uncaught=0».
- Лог omp стенда, `Configured subagent runtime model fallback chain`:
  c2 и c6, Child129 → `"requested":["stub-zai/glm","stub-anthropic/opus"]`; Sib129 → `["stub-anthropic/opus"]`;
  c3 и c4, Child129 → `["stub-anthropic/opus"]` (подмены нет); c5, Child129 → `["stub-zai/glm","stub-anthropic/opus"]`, 2 хода.
- Обходы нового кода: `node probe.mjs` (одноразовый, /tmp/dev-harness-verify/Rev129b/u) → rc 0.
  - исчерпан P, `[P, openai]` → `[F, P, openai]`;
  - `[P]` → `[F, P]`;
  - копия модуля (вторая загрузка) видит запись;
  - запасная того же провайдера → null;
  - `F == P` → null;
  - `autoFallback: false` → null;
  - пустой patterns → null;
  - patterns без исчерпанного провайдера (`[openai, P]`, `[F]`) → null;
  - `@slow` → подмена, как у `slow`;
  - запасная исчерпана сама (тир fast) → подмена без сверки F (инвариант 2);
  - нестроковый элемент → null; patterns не массив → null;
  - срок истёк → null, у другого провайдера срок не истёк → подмена;
  - порог 300000 → null, 300001 → запись; 400 → null;
  - голый ход без `message` → записи нет;
  - `{message: null}` → TypeError (R129b-1).
  Тот же probe на f977f6ee0 → rc 0, но красный по R129-1 (07/08: P выброшен) и по R129-2 (02b: голый
  ход дал подмену).
- grep нового файла на `stub|M129|SIB129|127.0|localhost|zai|anthropic|opus|glm|setTimeout|
  setInterval|writeFile|process.env|child_process|fetch` → совпадений нет. Знания мира батареи и
  побочных эффектов в файле нет.

## Паразитная сложность (050), дельта

Артефакт — тот же `.omp/extensions/fallback-route.ts`, новых артефактов нет.
(1) Свойство — инвариант 2 `[запасная, ...patterns]`. Дельта убрала две ACCIDENTAL-ветви: `snapshot ?? event`
и `tail.filter`/`target === primary`.
(2) Состояние не изменилось: карта на globalThis.
(3) Число файлов, которые меняются вместе, — 1, не выросло.
(4) Интерфейс не изменился, работы за ним стало меньше: модуль стал глубже.
(5) Потребитель — строка приёмки 4.
Новой ACCIDENTAL сложности нет. Имя `list` — лишь переименование `patterns` после проверки типа (наблюдение, не находка).

ПРОВОДКА: guard=battery.py существует и судит именно этот предмет. Проводка в CI — за оркестратором
(R-2), не блокер. Остатки R-1 и R-2 приняты, не переоткрываю.
