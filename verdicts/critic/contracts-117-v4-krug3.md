FAIL
OBJECT=0c9e8d95c913b46b16a979803f103e0d51da7a1f
СУД: repo=dev-harness; предмет=117 (v4); фаза=контракт; роль=critic-sol; вызов=scoped-повтор после арбитража (дополнительный вызов по стоячему слову владельца 25.10); модель-план=openai-codex/gpt-6-sol; сессия=Critic117i; модель-факт=openai-codex/gpt-6-sol; SHA=0c9e8d95c913b46b16a979803f103e0d51da7a1f; предыдущий=verdicts/critic/contracts-117-v4-krug2.md (FAIL 2/2), verdicts/arbitration/contracts-117-v4-arbitraz.md; исключение=нет

## БЛОКИРУЕТ

БЛОКИРУЕТ contracts/117-cmp-mob-vkhod-splash.md:1338–1344 — **новая ложная зелёная на классе порядка**, в пределах конечной границы арбитра (`verdicts/arbitration/contracts-117-v4-arbitraz.md:213–218`). После hold-`openLink` и до обязательного ожидания запускающий шаг `runFlow: start.yaml` либо живой скалярный Maestro-шаг `- launchApp` оставляет полную статическую батарею зелёной `static 65/65` (rc0). Допустимые не запускающие вставки до `stopApp` зелёные, оба старых обхода до ссылки красные; дефект именно в суффиксе после ссылки.
ОБЯЗАТЕЛЬСТВО: contracts/117-cmp-mob-vkhod-splash.md:627–646,1338–1344 — кадр Splash снимается при взведённом *холодным стартом по литералу* удержании; запускающий шаг между hold-ссылкой и ожиданием должен краснеть. Арбитр явно называет `launchApp/runFlow/иной openLink` запускающими и запрещает их между ссылкой и ожиданием (`verdicts/arbitration/contracts-117-v4-arbitraz.md:213–218`).
КЛАСС ПРИЧИНЫ: `fixtures/workshop_project/vkhod_117/vkhod_static_probe.py:1494–1499` после выбора первого ожидания ПОСЛЕ `openLink` проверяет на интервале только `isinstance(st, dict) and 'launchApp' in st`. Запуск через `runFlow` и скалярный `launchApp` не замечаются; реплей взводит окно по ошибочно истинному `cold_start_ok`, не проигрывая промежуточную смену процесса. Запускающий `runFlow` ДО ссылки `_cold_start_state` уже признаёт запуском (:1452), после ссылки — нет.
СОСТОЯНИЕ: одноразовая модельная копия продукта @ `c617f6fb236d11574df75fb09ae41870bf8c29d6`: `launchApp{clearState} → stopApp → openLink(complior:///?e2e=splash-hold) → runFlow: start.yaml → extendedWaitUntil visible splash-overlay → takeScreenshot(vkhod-117-splash)`; второй вход меняет `runFlow` на `- launchApp`. `mobile/.maestro/start.yaml:4–7` реально запускает приложение с `clearState: true`; скалярный `- launchApp` реально употреблён в `mobile/.maestro/erstinformation.yaml:4`. Синтаксис достигаем в Maestro и не меняет ни модельный TSX, ни остальные проверки.
НАБЛЮДЕНИЕ: `python3 attack117i.py` на OBJECT (скрипт `/tmp/dev-harness-verify/Critic117i/attack117i.py` устанавливает `model_bytes` контекстом `installed`, после каждого прогона восстанавливает байты) даёт для `run-flow-between-hold-and-wait` `rc=0 static 65/65` и `launch-between-hold-and-wait` `rc=0 static 65/65` вместо красного; `MAESTRO_HOLD_COLD_START`, `REPLAY_SPLASH_WHILE_OVERLAY` и прочие 65 клеток не краснеют. Честный контроль и ранее ложнокрасный `visible` до `stopApp` тоже `rc0 static 65/65`; оба старых обхода красны `rc1` ожидаемыми двумя клетками. Этот сбой остаётся даже после требуемой правки «первое ожидание после ссылки».
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: для *всех живых форм запуска* (`runFlow`, `launchApp` как строка/словарь, другая ссылка), появившихся между hold-ссылкой и выбранным ожиданием, холодный старт/реплей красные; дополнительные НЕ запускающие шаги в том же интервале и до `stopApp` не краснеют. Проверять на целой модели, а не только на синтетическом предикате.

**Сырой протокол атаки:**
```text
$ cd /tmp/dev-harness-verify/Critic117i && python3 attack117i.py
## honest: rc=0 expected=0
static 65/65
## prior-false-red-visible-before-stop: rc=0 expected=0
static 65/65
## first-bypass-relaunch: rc=1 expected=1
RED MAESTRO_HOLD_COLD_START: сценарий не запускает холодный старт каналом (Г′) по СОСТОЯНИЮ команд — openLink#3: непосредственно перед ссылкой приложение ЗАПУЩЕНО (последняя запускающая/останавливающая команда — не stopApp) — старт не холодный, стартовый URL при монтировании не читается
RED REPLAY_SPLASH_WHILE_OVERLAY: hold 1200 исходы ['CLASS_B', 'SPLASH']  (канал (Г): True холодный старт: False )
## second-bypass-stop-then-launch: rc=1 expected=1
RED MAESTRO_HOLD_COLD_START: сценарий не запускает холодный старт каналом (Г′) по СОСТОЯНИЮ команд — openLink#2: непосредственно перед ссылкой приложение ЗАПУЩЕНО (последняя запускающая/останавливающая команда — не stopApp) — старт не холодный, стартовый URL при монтировании не читается
RED REPLAY_SPLASH_WHILE_OVERLAY: hold 1200 исходы ['CLASS_B', 'SPLASH']  (канал (Г): True холодный старт: False )
## assert-visible-before-stop: rc=0 expected=0
static 65/65
## not-visible-before-stop: rc=0 expected=0
static 65/65
## screenshot-before-stop: rc=0 expected=0
static 65/65
## wait-only-before-link: rc=1 expected=1
RED MAESTRO_SPLASH_FRAME_WAIT: шаг перед vkhod-117-splash — не extendedWaitUntil visible splash-overlay
RED MAESTRO_HOLD_COLD_START: сценарий не запускает холодный старт каналом (Г′) по СОСТОЯНИЮ команд — ожидание visible splash-overlay не после openLink (openLink#3, ожидание#-1)
RED REPLAY_SPLASH_WHILE_OVERLAY: hold 1200 исходы ['UNBOUND'] перед снимком vkhod-117-splash нет extendedWaitUntil visible/notVisible по splash-overlay — кадр не привязан к оверлею (канал (Г): True холодный старт: False )
## other-link-before-hold-link: rc=1 expected=1
RED MAESTRO_HOLD_COLD_START: сценарий не запускает холодный старт каналом (Г′) по СОСТОЯНИЮ команд — openLink#3: непосредственно перед ссылкой приложение ЗАПУЩЕНО (последняя запускающая/останавливающая команда — не stopApp) — старт не холодный, стартовый URL при монтировании не читается
RED SPLASH_HOLD_LINK_ROUTE_MOUNT: ссылка канала сценария ['complior://start', 'complior:///?e2e=splash-hold'] не ведёт на корень «/» литералом complior:///?e2e=splash-hold (expo-путь: start — host-форма = несуществующий маршрут, PilotApp не монтируется, hideAsync не вызван)
RED REPLAY_SPLASH_WHILE_OVERLAY: hold 1200 исходы ['CLASS_B', 'SPLASH']  (канал (Г): True холодный старт: False )
## other-link-between-hold-and-wait: rc=1 expected=1
RED SPLASH_HOLD_LINK_ROUTE_MOUNT: ссылка канала сценария ['complior:///?e2e=splash-hold', 'complior://start'] не ведёт на корень «/» литералом complior:///?e2e=splash-hold (expo-путь:  — host-форма = несуществующий маршрут, PilotApp не монтируется, hideAsync не вызван)
RED REPLAY_SPLASH_WHILE_OVERLAY: hold 8000 исходы ['NO_PILOT'] стартовая ссылка канала ведёт на несуществующий маршрут: PilotApp не монтируется, оверлей splash-overlay не появляется — ожидание visible краснеет таймаутом (канал (Г): True холодный старт: True )
## run-flow-between-hold-and-wait: rc=0 expected=1
static 65/65
## launch-between-hold-and-wait: rc=0 expected=1
static 65/65
## two-hold-links: rc=1 expected=1
RED SPLASH_HOLD_LINK_ROUTE_MOUNT: ссылка канала сценария ['complior:///?e2e=splash-hold', 'complior:///?e2e=splash-hold'] не ведёт на корень «/» литералом complior:///?e2e=splash-hold (expo-путь:  — host-форма = несуществующий маршрут, PilotApp не монтируется, hideAsync не вызван)
ATTACK_EXPECTATIONS_FAILED=True
[exit=1]
```

## Проверки предмета до стопа

```text
$ git cat-file -t 0c9e8d95c913b46b16a979803f103e0d51da7a1f
commit
[exit=0]
$ git rev-parse HEAD
0c9e8d95c913b46b16a979803f103e0d51da7a1f
[exit=0]
$ git diff --numstat 087e4ee00a705c9b6727a784613229d88444f650 0c9e8d95c913b46b16a979803f103e0d51da7a1f -- contracts/117-cmp-mob-vkhod-splash.md fixtures/workshop_project/vkhod_117/vkhod_static_probe.py
40 15 contracts/117-cmp-mob-vkhod-splash.md
14 4 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py
[exit=0]
$ git diff --exit-code 087e4ee00a705c9b6727a784613229d88444f650 0c9e8d95c913b46b16a979803f103e0d51da7a1f -- fixtures/workshop_project/vkhod_117/model fixtures/workshop_project/vkhod_117/live fixtures/workshop_project/vkhod_117/source.json fixtures/workshop_project/vkhod_117/vkhod_probe.py fixtures/workshop_project/vkhod_117/produktnye-izmenenija3
[exit=0]
$ git diff --numstat frozen/contracts/117/3 0c9e8d95c913b46b16a979803f103e0d51da7a1f -- contracts/117-cmp-mob-vkhod-splash.md
647 0 contracts/117-cmp-mob-vkhod-splash.md
[exit=0]
$ bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Critic117i/repo contracts/117-cmp-mob-vkhod-splash.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
КРИТИК: дверь зелёная
[exit=0]
$ bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic117i/repo contracts/117-cmp-mob-vkhod-splash.md
OK
[exit=0]
$ bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Critic117i/repo contracts/117-cmp-mob-vkhod-splash.md
OK
[exit=0]
$ bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Critic117i/repo
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 137 черновик(ов) судится, замороженные — по тегам
потолки в порядке
[exit=0]
$ bash scripts/check_provodka.sh /tmp/dev-harness-verify/Critic117i/repo contracts/117-cmp-mob-vkhod-splash.md
[exit=0]
$ bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Critic117i/repo contracts/117-cmp-mob-vkhod-splash.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 1 буллет(ов), НЕ ЗАЩИЩАЕТ 1 буллет(ов))
[exit=0]
```

Новая клетка `MAESTRO_HOLD_PORJADOK_VSTAVKA_WAIT_DO_STOPA` порождается `porjadok_cells` с литералом `True` перед вызовом проверяемого предиката (`vkhod_static_probe.py:1546–1551`); в контракте перечислена (:910–914), ×10 и static 65/65 соответствуют наблюдению; единственное `×9` в :971 — объявленная история `×9 → ×10`. Предыдущие порождаемые клетки и стабы остались в исходном файле; полные `--model` / `--stabs` после найденной ложной зелёной НЕ запускались: предписанный стоп при FAIL, не заявляю непроведённую проверку.

К КОНСУЛЬТАНТУ: арбитраж уже состоялся; новая ложная зелёная внутри его конечной границы — требуется маршрут консультанта/владельца, не молчаливая новая итерация критика. Push/commit не делал.

## СОВЕТ

Нет.
