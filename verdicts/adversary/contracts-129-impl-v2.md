accept
OBJECT=2974de91b878e36eca00ccbff9b55f6d5b5ceadc

Круг 2, scoped-дельта: R129-1 закрыта по существу. На реальном стенде omp в c2 лог ребёнка содержит `requested=["stub-zai/glm","stub-anthropic/opus"]`: запасная первая, а исходный primary сохранён. R129-2 закрыта: обработчик `message_end` принимает только `event.message`; ветвь `snapshot ?? event` удалена. Зона дельты — только `.omp/extensions/fallback-route.ts`.

Прогоны из одноразового клона `/tmp/dev-harness-verify/Adv129b/h` с `PYTHONDONTWRITEBYTECODE=1`:
- `battery.py` — rc 0, `cells=6 red=0`.
- `battery.py --model` (позитивный контроль) — rc 0, `cells=6 red=0`.
- `battery.py --stabs` — rc 0, `stubs=11 pairs=13 uncaught=0`.
- без расширения (`--ext ''`) — rc 1, `cells=6 red=2`; красны ровно c2 и c6.
- нейтрализация распознавания исчерпания стабом s3 только на c4 — rc 1, `cells=1 red=1`.
- отсутствующий субъект — rc 2; PATH без omp — rc 2; пустой выбор клеток — rc 1 (KeyError), не ложный зелёный результат.

Свои обходы реального кода через зарегистрированные обработчики (rc 0, `probe=ok cases=5`): после истинного 429 `retry-after-ms=300001` подмена формирует `[fallback, ...patterns]`; дубли исходных селекторов сохраняются; пустой `patterns` не подменяется; исчерпание не первого селектора не подменяет; при искусственно таком же провайдере fallback подмена не происходит. Нового дефекта в дельте не найдено.
