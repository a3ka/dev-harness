FAIL
OBJECT=f977f6ee000d6228b38f94f3721349bb0052a9f3

Реализация нарушает инвариант 2 замороженного контракта: при подмене возвращаемый список обязан быть `[<fallback>, ...patterns]`. Реальный `route()` отбрасывает исходный primary: `const [primary, ...tail] = patterns` и возвращает `[target, ...tail.filter((p) => p !== target)]`.

Наблюдаемый контрпример на самом расширении (rc 0): после сообщения assistant/error/429/retry-after-ms=300001/provider=anthropic вызов `before_subagent_spawn` с `{modelRole:"slow", patterns:["anthropic/primary","openai/other"]}` вернул `{"model":["zai/glm-5.3","openai/other"],...}`. Обязательный результат по инварианту — `{"model":["zai/glm-5.3","anthropic/primary","openai/other"],...}`. Значит предмет не сохраняет штатную цепочку попыток ребёнка.

Батарея этот дефект не ловит: `python3 fixtures/workshop_project/fallback_subagent_129/battery.py` на OBJECT дала rc 0, `cells=6 red=0`; все её сценарии не различают потерю primary из `patterns`.

Пробитие проверки подтверждено исполнимыми заглушками.
- `attack-hardcoded.ts` распознаёт единственный стендовый tier `slow` и жёстко возвращает стендовый селектор `stub-zai/glm`, игнорируя конфигурацию и все остальные autoFallback-тиры. Батарея: rc 0, `cells=6 red=0`. Это нарушает единый источник `config/agent_models.json`, запрет второго списка и требование ко всем тирам.
- `attack-fixed-window.ts` вместо срока из полученного `retry-after-ms` всегда записывает константу `31_561_000`. Батарея: rc 0, `cells=6 red=0`. Это нарушает инвариант 1 «до момента сейчас + N»; проверка использует только одно N и не проверяет истечение/вариацию срока.

Позитивные и негативные контроли:
- честная модель `battery.py --model`: rc 0, `cells=6 red=0`;
- закрытые 11 заглушек `battery.py --stabs`: rc 0, `stubs=11 pairs=13 uncaught=0`;
- без расширения `battery.py --ext ''`: rc 1, `cells=6 red=2` (c2, c6);
- нейтрализация s3 только на c4: rc 1, `cells=1 red=1`;
- отсутствующий субъект: rc 2 `NOT_IMPLEMENTED`;
- PATH без omp: rc 2 `NOT_IMPLEMENTED`;
- пустой выбор клеток `--cells ''`: rc 1 (KeyError), не ложный успех;
- `scripts/pre_critic.sh` и `scripts/check_threat_model.sh`: оба rc 0.

Исправление за автором: в `route()` вернуть буквально `[target, ...patterns]` (без удаления primary/target) и расширить батарею вариативными конфигурациями тира/провайдера и разными retry-after-ms с проверкой срока.
