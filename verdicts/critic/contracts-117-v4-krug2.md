FAIL
OBJECT=087e4ee00a705c9b6727a784613229d88444f650
СУД: repo=dev-harness; предмет=117 (v4); фаза=контракт; роль=critic-sol; вызов=2/2; модель-план=openai-codex/gpt-6-sol; сессия=Critic117h; модель-факт=openai-codex/gpt-6-sol; SHA=087e4ee00a705c9b6727a784613229d88444f650; предыдущий=verdicts/critic/contracts-117-v4-krug1.md; исключение=нет

## БЛОКИРУЕТ

БЛОКИРУЕТ contracts/117-cmp-mob-vkhod-splash.md:627 — новая проверка порядка ложно краснит допустимую цепочку при дополнительном ожидании до `stopApp`. Класс причины — предикат `_maestro_hold_cold_start_verdict` выбирает **первое** `extendedWaitUntil visible splash-overlay` во всём YAML, а не требуемое ожидание ПОСЛЕ hold-`openLink`. Инвариант 10 определяет холодный старт состоянием запускающих/останавливающих команд и не запрещает дополнительные не запускающие шаги до `stopApp`; снимок по-прежнему следует за ожиданием после ссылки.
ОБЯЗАТЕЛЬСТВО: contracts/117-cmp-mob-vkhod-splash.md:627–640 — после `launchApp{clearState}` и `stopApp` без нового запуска литерал `openLink` должен быть холодным стартом; после него ожидается видимость splash-overlay, затем снимается кадр.
СОСТОЯНИЕ: в модельном YAML `launchApp{clearState} → extendedWaitUntil(visible splash-overlay) → stopApp → openLink(literal) → extendedWaitUntil(visible splash-overlay) → takeScreenshot(vkhod-117-splash)`. Перед literal-`openLink` приложение остановлено; между `stopApp` и ссылкой нет запуска; непосредственно перед снимком присутствует обязательное ожидание после ссылки. Контроль с `takeScreenshot: pre-stop` вместо добавочного ожидания зелёный.
НАБЛЮДЕНИЕ: статическая проба на полной эталонной модели с добавочным ожиданием rc1, `RED MAESTRO_HOLD_COLD_START: … ожидание visible splash-overlay не после openLink (openLink#3, ожидание#1)` и зависимый `RED REPLAY_SPLASH_WHILE_OVERLAY: hold 1200 … холодный старт: False`; та же модель с добавочным снимком до `stopApp` rc0 `static 64/64`. Причина — поиск первого wait с индексом 1, хотя требуемый wait есть после `openLink` (индекс 4).
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: связывать с hold-`openLink` ожидание, находящееся после него; не запускающие шаги до `stopApp` не должны менять решение о холодном старте.

Сырая атака на полном субъекте (`python3 false_red.py`, временный скрипт, одноразовый C124clean + installed(model_bytes), скрипт не входит в предмет):
```text
$ /usr/bin/python3 /tmp/dev-harness-verify/Critic117h/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117h/C124clean # additional-visible-before-stop
rc=1
RED MAESTRO_HOLD_COLD_START: сценарий не запускает холодный старт каналом (Г′) по СОСТОЯНИЮ команд — ожидание visible splash-overlay не после openLink (openLink#3, ожидание#1)
RED REPLAY_SPLASH_WHILE_OVERLAY: hold 1200 исходы ['CLASS_B', 'SPLASH']  (канал (Г): True холодный старт: False )
$ /usr/bin/python3 /tmp/dev-harness-verify/Critic117h/repo/fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117h/C124clean # additional-screenshot-before-stop
rc=0
static 64/64
```

АРБИТР: arbiter.
ПРЕДМЕТ СПОРА: допустимы ли дополнительные не запускающие команды до `stopApp` при сохранённой обязательной цепочке; как выбрать релевантное ожидание после deep-link. Исчерпан разрешённый бюджет 2/2; этот FAIL не даёт третьего вызова или accept без маршрута §Быстрый-процесс.

## Проверки дельты и атаки

`git cat-file -t 087e4ee00a705c9b6727a784613229d88444f650` → `commit` rc0; родитель `039db92b41f627a2892285f3deed7c7d5c4d0026`. `git diff --numstat 38f435abaf1e4fac388f213562a9f3c20307f569 087e4ee00a705c9b6727a784613229d88444f650 -- contracts/117-cmp-mob-vkhod-splash.md fixtures/workshop_project/vkhod_117/vkhod_static_probe.py` → `135 21` и `195 36`, rc0. Другие файлы в сравнении деревьев относятся к новому main; `git diff --exit-code … -- fixtures/workshop_project/vkhod_117/model fixtures/workshop_project/vkhod_117/live fixtures/workshop_project/vkhod_117/vkhod_probe.py fixtures/workshop_project/vkhod_117/source.json` → пустой stdout, rc0. `git diff --numstat frozen/contracts/117/3 OBJECT -- contracts/117-cmp-mob-vkhod-splash.md` → `622 0`, rc0.

Оба собственных обхода круга 1 воспроизведены в RBmut с целой установленной моделью (`env TMPDIR=/tmp/dev-harness-verify/Critic117h python3 attack117.py`, временный скрипт удалён). Сырой значимый вывод каждой атаки (скрипт показывает только RED и итог, rc — дочерней пробы):
```text
# honest expected_green=True
rc=0
static 64/64
# relaunch-after-stop-before-link expected_green=False
rc=1
RED MAESTRO_HOLD_COLD_START: сценарий не запускает холодный старт каналом (Г′) по СОСТОЯНИЮ команд — openLink#3: непосредственно перед ссылкой приложение ЗАПУЩЕНО (последняя запускающая/останавливающая команда — не stopApp) — старт не холодный, стартовый URL при монтировании не читается
RED REPLAY_SPLASH_WHILE_OVERLAY: hold 1200 исходы ['CLASS_B', 'SPLASH']  (канал (Г): True холодный старт: False )
# order-stop-before-launch expected_green=False
rc=1
RED MAESTRO_HOLD_COLD_START: сценарий не запускает холодный старт каналом (Г′) по СОСТОЯНИЮ команд — openLink#2: непосредственно перед ссылкой приложение ЗАПУЩЕНО (последняя запускающая/останавливающая команда — не stopApp) — старт не холодный, стартовый URL при монтировании не читается
RED REPLAY_SPLASH_WHILE_OVERLAY: hold 1200 исходы ['CLASS_B', 'SPLASH']  (канал (Г): True холодный старт: False )
# delete-stop: rc=1, RED MAESTRO_HOLD_COLD_START, RED REPLAY_SPLASH_WHILE_OVERLAY
# link-before-stop: rc=1, RED MAESTRO_HOLD_COLD_START, RED REPLAY_SPLASH_WHILE_OVERLAY
# two-links: rc=1, RED MAESTRO_HOLD_COLD_START, RED SPLASH_HOLD_LINK_ROUTE_MOUNT, RED REPLAY_SPLASH_WHILE_OVERLAY
# launch-plain: rc=1, RED MAESTRO_HOLD_COLD_START, RED REPLAY_SPLASH_WHILE_OVERLAY
```
`runFlow` после `stopApp` отдельно испытан последовательно (`python3 attack_runflow.py`, временный скрипт удалён): rc1 `RED MAESTRO_HOLD_COLD_START: … openLink#3: непосредственно перед ссылкой приложение ЗАПУЩЕНО …`, `RED REPLAY_SPLASH_WHILE_OVERLAY: hold 1200 … холодный старт: False`. Поведенческая граница Jest (191/191 на перестановке из круга 1) зафиксирована как граница, не второй блокер.

`python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --model --repo /tmp/dev-harness-verify/Critic117h/RBmut` → rc0 `static 64/64` ×3 ПОСЛЕДОВАТЕЛЬНО; `python3 fixtures/workshop_project/vkhod_117/vkhod_probe.py --model --repo /tmp/dev-harness-verify/Critic117h/RBmut` → rc0 `behavioral 191/191` ×3 ПОСЛЕДОВАТЕЛЬНО. Статическая матрица `--matrix --repo RBmut` прогнала новые именные стабы: `mutant splash-hold-relaunch-pered-link red= ['MAESTRO_HOLD_COLD_START', 'REPLAY_SPLASH_WHILE_OVERLAY']` и то же для `splash-hold-porjadok-stop-launch`; полный сырой вывод `artifact://3753` (на 51 стабе не замечено MUTANT_GREEN/NAMED_MISS/UNEXPECTED_RED).

`bash scripts/check_precision_gate.sh <клон> contracts/117-cmp-mob-vkhod-splash.md` → пустой stdout, rc0; `bash scripts/pre_critic.sh --repo <клон> contracts/117-cmp-mob-vkhod-splash.md` → `ok гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2; КРИТИК: дверь зелёная`, rc0; `bash scripts/check_spec_ready.sh <клон> contracts/117-cmp-mob-vkhod-splash.md` → `OK`, rc0 (последовательный повтор); `bash scripts/check_ceilings.sh <клон>` → `потолки в порядке`, rc0; `bash scripts/check_provodka.sh <клон> contracts/117-cmp-mob-vkhod-splash.md` → пустой stdout, rc0; `bash scripts/check_threat_model.sh <клон> contracts/117-cmp-mob-vkhod-splash.md` → `модель угроз: секция валидна (ЗАЩИЩАЕТ 1 буллет(ов), НЕ ЗАЩИЩАЕТ 1 буллет(ов))`, rc0. Продуктовые патчи из `Architect117v4/produktnye-izmenenija3/` имеют sha256 `31c70f6724965e741863615e7b24fe01b2433b9f8e27aa63b209f279a206e99d`/`c4b6ddb2621f465564196f6a522f97bf3b0abc266356c35ffce9cc4feab50581`; `git apply --check` по обоим на чистом `c617f6fb236d11574df75fb09ae41870bf8c29d6` rc0.

## СОВЕТ

Нет.
