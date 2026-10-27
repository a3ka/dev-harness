FAIL
OBJECT=38f435abaf1e4fac388f213562a9f3c20307f569
СУД: repo=dev-harness; предмет=117 (v4); фаза=контракт; роль=critic-sol; вызов=1/2; модель-план=openai-codex/gpt-6-sol; сессия=Critic117g; модель-факт=openai-codex/gpt-6-sol; SHA=38f435abaf1e4fac388f213562a9f3c20307f569; предыдущий=critic 117 v1–v3; исключение=нет

## БЛОКИРУЕТ

БЛОКИРУЕТ contracts/117-cmp-mob-vkhod-splash.md:607 — инвариант 10 требует ХОЛОДНЫЙ старт `launchApp{clearState} → stopApp → openLink`. Класс причины — ложная достаточность красной клетки `MAESTRO_HOLD_COLD_START` и зависящего от неё реплея. Закрывающее свойство: после очистки должен следовать `stopApp`, а между ПОСЛЕДНИМ `stopApp` и `openLink` приложение не должно запускаться снова; реплей не должен приписывать холодный старт простой сумме команд. При открытии ссылки в контрпримере приложение уже работает, а `pilot-app.tsx:257–269` читает `Linking.getInitialURL()` при монтировании и не слушает последующие deep links. Живой CI/123 может отклонить получившийся кадр, но он не заменяет обязательную красную проверку холодного канала до раздачи реализации.
ОБХОД: в честной цепочке оставить `launchApp: {clearState: true} → stopApp`, добавить ВТОРОЙ `launchApp: {clearState: true}` между `stopApp` и прежним `openLink: complior:///?e2e=splash-hold`, затем честные ожидание/снимок. Обе объявленные статические клетки `MAESTRO_HOLD_COLD_START` и `REPLAY_SPLASH_WHILE_OVERLAY` остаются зелёными, полная статика rc0 `55/55`. Независимый вариант той же причины — переставить первые команды: `stopApp → launchApp{clearState} → openLink`; полная статика rc0 `55/55` И поведение rc0 `191/191`. Предикат `fixtures/workshop_project/vkhod_117/vkhod_static_probe.py:1274–1288` проверяет `any(clearState до ссылки) ∧ any(stopApp до ссылки)` и запрещает launch лишь ПОСЛЕ ссылки, не наблюдая состояние в момент `openLink`.

## Атака до кода: команды, rc, сырой вывод

Среда `env -i PATH=/home/harness/.local/bin:/usr/bin:/bin TMPDIR=/tmp/dev-harness-verify/Critic117g`; одноразовый продукт `/tmp/dev-harness-verify/Critic117g/RBmut`; временная установка модели из закоммиченного OBJECT восстанавливает файлы после каждой атаки (`git status --porcelain --untracked-files=no` пуст). `attack117.py <имя>` вызывает `vkhod_static_probe.py --repo RBmut`, `attack117_behavior.py` — `vkhod_probe.py --repo RBmut`; указан rc дочерней пробы ДО восстановления. Полный stdout в `history://Critic117g`. Первые три наблюдения — ОДИН класс причины.

```text
$ python3 /tmp/dev-harness-verify/Critic117g/attack117.py relaunch-after-stop-before-link
rc=0 [дочерняя статическая проба]
case MAESTRO_HOLD_COLD_START
case REPLAY_SPLASH_WHILE_OVERLAY
static 55/55
$ python3 /tmp/dev-harness-verify/Critic117g/attack117.py order-stop-before-launch
rc=0 [дочерняя статическая проба]
case MAESTRO_HOLD_COLD_START
case REPLAY_SPLASH_WHILE_OVERLAY
static 55/55
$ python3 /tmp/dev-harness-verify/Critic117g/attack117_behavior.py
rc=0 [дочерняя поведенческая проба на перестановке stopApp/launchApp]
case SPLASH_OVERLAY_HOLD_LINK_DARK
case SPLASH_OVERLAY_HOLD_LINK_LIGHT
behavioral 191/191
$ python3 /tmp/dev-harness-verify/Critic117g/attack117.py nonexisting-route
rc=1 [дочерняя статическая проба]
RED SPLASH_HOLD_LINK_ROUTE_MOUNT: ссылка канала сценария ['complior://e2e-splash-hold'] не ведёт на корень «/» литералом complior:///?e2e=splash-hold (expo-путь: e2e-splash-hold — host-форма = несуществующий маршрут, PilotApp не монтируется, hideAsync не вызван)
RED REPLAY_SPLASH_WHILE_OVERLAY: hold 1200 исходы ['NO_PILOT'] стартовая ссылка канала ведёт на несуществующий маршрут: PilotApp не монтируется, оверлей splash-overlay не появляется — ожидание visible краснеет таймаутом (канал (Г): False холодный старт: False )
$ python3 /tmp/dev-harness-verify/Critic117g/attack117.py shot-before-visibility
rc=1 [дочерняя статическая проба]
RED MAESTRO_SPLASH_FRAME_WAIT: шаг перед vkhod-117-splash — не extendedWaitUntil visible splash-overlay
RED REPLAY_SPLASH_WHILE_OVERLAY: hold 8000 исходы ['UNBOUND'] перед снимком vkhod-117-splash нет extendedWaitUntil visible/notVisible по splash-overlay — кадр не привязан к оверлею (канал (Г): True холодный старт: True )
$ python3 /tmp/dev-harness-verify/Critic117g/attack117.py removed-clear-timeout
rc=0 [дочерняя ТОЛЬКО статическая проба]
static 55/55
$ python3 fixtures/workshop_project/vkhod_117/vkhod_probe.py --matrix --repo /tmp/dev-harness-verify/Critic117g/RB
mutant splash-hold-taymer-bez-clear red= ['SPLASH_OVERLAY_HOLD_LINK_DARK', 'SPLASH_OVERLAY_HOLD_LINK_LIGHT']
```

Последние две строки НЕ образуют второго обхода: отсутствие очистки таймера уже краснит объявленный поведенческий стаб. Другие собственные мутации — несуществующий маршрут и ранний кадр — честно красные.

## Дельта и живые носители

- HEAD есть OBJECT; родитель `db45f9a0da79761ced48337f805b587eb2d5f355`; в теле коммита дословная строка `РАЗРЕШИЛ-ВЛАДЕЛЕЦ`. `git diff --numstat frozen/contracts/117/3 HEAD -- contracts/117-cmp-mob-vkhod-splash.md` → **+508/−0 строк**; 19 изменённых файлов — контракт и `fixtures/workshop_project/vkhod_117/`, frozen 117/3 не вычеркнут. Инварианты 10–12 присутствуют. Риск «обычный» обоснован UI-таймингом, не правами/ПД/деньгами. Оракул replay_117: poll max 1000 + shot max 2400 + 100 = hold_min 3500, hold 8000, сетка 4×12=48 точек.
- Провал варианта (Г) run `40497913252`: оригинальный JUnit 7 флоу, 1 ERROR ИМЕННО в 117 (`Assertion is false: id: splash-overlay is visible`), 6 SUCCESS. Оригинальный кадр — нативный знак без wordmark/tagline, hierarchy без PilotApp, logcat с `START VIEW dat=complior://e2e-splash-hold/… LAUNCH_SINGLE_TASK` и `Running "main"`. Вариант (В), run `40434807469`: оригинальные `commands.json` 118 и dark V0 побайтово совпали с `live/`-фикстурами; зазор конец launchApp → конец V0 **7450 мс**, поэтому глобальное удержание 8000 закрывало чужой кадр.
- Честная живая проба (Г′) run `40511584004`, job `122215805656`, head `79574e0d766807601c9b6e8902a9c9771c08024f`: `gh run view … --json conclusion,headSha,jobs` → success quality и android-e2e. Оригинальный job-log: `RECOVERED`; `995 native rc=0 testcases=7 failed=0`; `KADR Splash dark 0.783 0.600 … OK`, light `0.782 … OK`; `F02.03-V01-V0` dark `0.845 … OK`, light `0.783 … OK`. Оригинальный `sverka-123.tsv` содержит обе Splash-строки; оба кадра Splash и dark V0 просмотрены: полный знак/wordmark/tagline, чужой V0 не перекрыт. Оригинальный JUnit — 7 SUCCESS, включая 117. `commands.json` 117: launchApp(clearState) 835 мс → stopApp 466 → openLink корневого литерала 1084 → assert visible 1402 → screenshot 686 → wait notVisible 6783. Это доказывает ЧЕСТНЫЙ вариант, а не полноту красной батареи против мутанта.
- На собственной базе продукта `c617f6fb236d11574df75fb09ae41870bf8c29d6` применены ровно два патча `produktnye-izmenenija3`. `git diff --exit-code 79574e0d… -- <оба изменённых файла> .github/workflows/mobile.yml` rc0: живой run использовал ТОТ ЖЕ код. `git diff-tree` живого коммита: только `mobile/src/bootstrap/pilot-app.tsx` (sha256 `df4f738f00af71d24a9abb3e63e39c803ee5d6b6e03074d7f2305465fc03f7c6`) и `mobile/.maestro/vkhod-117-splash-vhod.yaml` (`23201d57ae0fbcaa50e961e1eccce017e21811504dd613a685c972fedc9c474b`); `mobile.yml` не менялся (`f45c68230eb83b12c8aa81173da4b9d46608b966acfef7da7ba6178d21087421`), lockfile также неизменён.
- **12/12** SHA256 пинов `source.json replay_117.live.svideteli` совпали с `live/**`. Провальный кадр (Г) `204db8ce…` и hierarchy `1d330d69…` сверены `cmp` с ОРИГИНАЛОМ 40497913252; logcat-пин `c4182545…` содержит указанные строки. Четыре независимые порчи logcat/screenshot/hierarchy свидетеля и пина SHA в source.json дали `ORACLE_TAMPERED`, rc2 ×4.

## Потребители, угрозы и команды

- По ЖИВОМУ `mobile.yml`: quality проверяет 117 на `.harness117`; android-e2e собирает ОДИН release APK; `maestro_probe.py → ci-e2e.sh` исполняет семь native-флоу, включая 117; отдельно Maestro 117 dark/light → безусловный 123 с `set -o pipefail`, PNG/порог 0.600 → 135/118. Флоу 108/995/991/999 в тех же семи; чужие ссылки `complior://start` в cmp-mob-002/004. 139/141 повторяют только транспортный обрыв, не визуальное падение. Реальный `/` монтирует PilotApp; только сценарий 117 содержит hold-литерал. `REPLAY_HOLD_SCENARIO_ONLY` проверяет живой V0 118 и отсутствие удержания на его старте. Future expo-router/Maestro или перенос схемы потребуют нового доказательства: предъявленные lockfile, схема и проверка Maestro=2.11.0 не менялись.
- `НЕ ЗАЩИЩАЕТ` называет ручной ввод прод-литерала (оверлей 8 с), poll/shot вне сетки (медленный эмулятор), и границы реального пиксельного кадра, ловимого 123/ревью. Нет обещания, что фиксированный оракул защищает будущую версию роутера/Maestro.
- В локальных командах применялась среда `env -i PATH=/home/harness/.local/bin:/usr/bin:/bin TMPDIR=/tmp/dev-harness-verify/Critic117g`, без `omp`/сети. `--repo` у CLI ОБЯЗАТЕЛЕН: одна ошибочная попытка голого `--model` вернула `usage: … --repo REPO`, rc2 и не учитывалась. Далее действительные команды/выводы:

```text
$ bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic117g/repo contracts/117-cmp-mob-vkhod-splash.md
OK   [rc0]
$ bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Critic117g/repo contracts/117-cmp-mob-vkhod-splash.md
ok гейт предпосылок …; КРИТИК: дверь зелёная   [rc0]
$ bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Critic117g/repo contracts/117-cmp-mob-vkhod-splash.md
OK   [rc0]
$ bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Critic117g/repo
потолки в порядке   [rc0]
$ bash scripts/check_provodka.sh /tmp/dev-harness-verify/Critic117g/repo contracts/117-cmp-mob-vkhod-splash.md
[пустой stdout, rc0]
$ bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Critic117g/repo contracts/117-cmp-mob-vkhod-splash.md
модель угроз: секция валидна …   [rc0]
$ python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --model --repo /tmp/dev-harness-verify/Critic117g/RBmut
static 55/55   [rc0 ×3]
$ python3 fixtures/workshop_project/vkhod_117/vkhod_probe.py --model --repo /tmp/dev-harness-verify/Critic117g/RBmut
behavioral 191/191   [rc0 ×3]
$ python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --matrix --repo /tmp/dev-harness-verify/Critic117g/RB
mutant splash-hold-link-na-marshrut red= ['MAESTRO_HOLD_ALONE', 'MAESTRO_HOLD_COLD_START', 'REPLAY_SPLASH_WHILE_OVERLAY', 'SPLASH_HOLD_LINK_CHANNEL', 'SPLASH_HOLD_LINK_ROUTE_MOUNT']
[49 мутантов красны, rc0; полный stdout artifact://3018]
$ python3 fixtures/workshop_project/vkhod_117/vkhod_probe.py --matrix --repo /tmp/dev-harness-verify/Critic117g/RB
honest green 191
mutant splash-hold-taymer-bez-clear red= ['SPLASH_OVERLAY_HOLD_LINK_DARK', 'SPLASH_OVERLAY_HOLD_LINK_LIGHT']
[64 мутанта красны, rc0; полный stdout artifact://3069]
```

В обеих матрицах нет `MUTANT_GREEN`, `MUTANT_NAMED_MISS`, `MUTANT_UNEXPECTED_RED`, `MUTANT_INFRASTRUCTURE`; RB/RBmut после матриц и атак имеют пустой `git status --porcelain --untracked-files=no`. До реализации B: `--repo RBmut` статическая rc1 `VKHOD_SPLASH_COMPOSITE_ABSENT`, поведенческая rc1 `VKHOD_SPLASH_OVERLAY_ABSENT; failed 62 of 191`. Продукт #124 ДО патчей: статика rc1 **ровно пять новых** `MAESTRO_HOLD_COLD_START`, `MAESTRO_HOLD_ALONE`, `SPLASH_HOLD_LINK_CHANNEL`, `SPLASH_HOLD_LINK_ROUTE_MOUNT`, `REPLAY_SPLASH_WHILE_OVERLAY`; поведение rc1 `failed 36 of 191` (две HOLD_LINK + 34 старые границы модель/production). Продукт #124 ПОСЛЕ тех же двух патчей: статика rc0 `55/55`; поведение rc1 `failed 34 of 191`, обе HOLD_LINK стали зелёными, старые 34 границы остались. Реальный CI по этой паре патчей — зелёный.

## СОВЕТ

СОВЕТ contracts/117-cmp-mob-vkhod-splash.md:33 — аннотация «инварианты 10–11» пропускает инвариант 12 (:644); сам инвариант 12 присутствует.
СОВЕТ contracts/117-cmp-mob-vkhod-splash.md:505 — строка `mobile/.maestro/vkhod-117-splash-vhod.yaml` НЕ начинается с `ЗОНА`, поэтому v4-строка :504 механически объявляет лишь pilot-app.tsx. Замороженная широкая зона :1266 всё равно покрывает `mobile/.maestro/`; ПЕРЕСЕЧЕНИЕ :1297 запрещает implementer 117 менять `mobile.yml`, и живая проба его не меняла: исполнитель не теряется. Но «v4-добавление к зоне» путает механическую и описательную границы; отдельный приёмочный `git diff --exit-code <base> <PR> -- .github/workflows/mobile.yml` сделал бы запрет проверяемым.
