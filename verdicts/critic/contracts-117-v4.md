accept
OBJECT=b164fdc1b640073f21e56d5daaf47ab5db3c4f2d
СУД: repo=dev-harness; предмет=117 (v4); фаза=контракт; роль=critic-sol; вызов=scoped-повтор №2 после verdicts/critic/contracts-117-v4-krug3.md и verdicts/arbitration/contracts-117-v4-arbitraz.md; модель-план=openai-codex/gpt-6-sol; сессия=Critic117k; модель-факт=openai-codex/gpt-6-sol; SHA=b164fdc1b640073f21e56d5daaf47ab5db3c4f2d; исключение=нет; независимость: автор zai/glm-5.3, судья openai-codex/gpt-6-sol

## БЛОКИРУЕТ

Нет. Входы предыдущего FAIL — запускающие шаги после hold-ссылки — теперь красные; честная цепочка и разрешённые арбитром незапускающие шаги зелёные. Ошибочный SHA в задании прерванного Critic117j исправлен до суда; тот запуск не судил предмет.

## СОВЕТ

СОВЕТ contracts/117-cmp-mob-vkhod-splash.md:657–670 — целые YAML-вставки `repeat` и `retry` с вложенным `launchApp` между ссылкой и ожиданием оставляют `static 70/70` (rc0): `_is_launching` классифицирует перечисленные верхнеуровневые шаги, а не раскрывает управляющие обёртки. Арбитр явно ограничил этот scoped-вызов запускающими формами `launchApp`/`runFlow`/`openLink`; `repeat`/`retry` за его пределами, потому это совет, не препятствие заморозке.

## Предмет и согласованность

`git cat-file -t b164fdc1b640073f21e56d5daaf47ab5db3c4f2d` → `commit` (rc0); судился именно этот HEAD. `git diff --stat 0c9e8d95c913b46b16a979803f103e0d51da7a1f b164fdc1b640073f21e56d5daaf47ab5db3c4f2d -- contracts/117-cmp-mob-vkhod-splash.md fixtures/workshop_project/vkhod_117/vkhod_static_probe.py` → два файла, `244 insertions(+), 62 deletions(-)` (rc0). Неотфильтрованный diff пересекает независимые изменения main; к дельте 117 отнесены пути предмета. `git diff --name-only 0c9e8d95c913b46b16a979803f103e0d51da7a1f HEAD -- fixtures/workshop_project/vkhod_117/model fixtures/workshop_project/vkhod_117/live fixtures/workshop_project/vkhod_117/source.json fixtures/workshop_project/vkhod_117/vkhod_probe.py` → пусто (rc0). `git diff --numstat frozen/contracts/117/3 HEAD -- contracts/117-cmp-mob-vkhod-splash.md` → `736 0` (rc0; удалённых frozen-строк нет). Старые `×10`/`65/65` в тексте помечены историческим «было → стало»; актуальны семья ×15, статика 70/70, поведенческая 191/191. В исходнике ровно одно определение `_is_launching`, обе проверки — до ссылки и от ссылки до ожидания — его вызывают. Обязательство и исполняемая команда указаны в contracts/117-cmp-mob-vkhod-splash.md:653–675,943–962,1405–1431; риск и зоны объявлены.

Внешний пакет автора `/tmp/dev-harness-verify/Architect117v4/produktnye-izmenenija3/` (НЕ часть коммита кандидата) прочитан только на сверку SHA-256: `0001-pilot-app-derzhanie-po-kornevomu-linku.patch` = `31c70f6724965e741863615e7b24fe01b2433b9f8e27aa63b209f279a206e99d`; `0002-maestro-117-holodnyj-start-po-kornevomu-linku.patch` = `c4b6ddb2621f465564196f6a522f97bf3b0abc266356c35ffce9cc4feab50581`; `pilot-app.new.tsx` = `df4f738f00af71d24a9abb3e63e39c803ee5d6b6e03074d7f2305465fc03f7c6`; `vkhod.new.yaml` = `23201d57ae0fbcaa50e961e1eccce017e21811504dd613a685c972fedc9c474b`. Живую CI-пробу не повторял: продуктовые байты контрактной правкой не менялись, применима установленная арбитром граница.

## Сырые прогоны на одном изолированном дереве продукта

Клон неподменённого продукта `/tmp/dev-harness-verify/Critic117k/mob`, HEAD `c617f6fb236d11574df75fb09ae41870bf8c29d6`. Батареи выполнялись ПОСЛЕДОВАТЕЛЬНО. Модельные подстановки и повреждения пинов восстанавливаются контекстом `installed`; по завершении `git status --short --untracked-files=no` в продукте пуст (rc0).

`python3 attack117k.py` (рабочий каталог `/tmp/dev-harness-verify/Critic117k`) → rc0, `ATTACK_EXPECTATIONS_FAILED=False`. Свод вывода по целым YAML-моделям (фактический rc, точные имена красных клеток; ноль = `static 70/70`):

```text
honest: 0 static 70/70
prior-false-red-visible-before-stop: 0 static 70/70
first-bypass-relaunch: 1 MAESTRO_HOLD_COLD_START REPLAY_SPLASH_WHILE_OVERLAY
second-bypass-stop-then-launch: 1 MAESTRO_HOLD_COLD_START REPLAY_SPLASH_WHILE_OVERLAY
assert-visible-before-stop: 0 static 70/70
not-visible-before-stop: 0 static 70/70
screenshot-before-stop: 0 static 70/70
wait-only-before-link: 1 MAESTRO_SPLASH_FRAME_WAIT MAESTRO_HOLD_COLD_START REPLAY_SPLASH_WHILE_OVERLAY
other-link-before-hold-link: 1 MAESTRO_HOLD_COLD_START SPLASH_HOLD_LINK_ROUTE_MOUNT REPLAY_SPLASH_WHILE_OVERLAY
other-link-between-hold-and-wait: 1 MAESTRO_HOLD_COLD_START SPLASH_HOLD_LINK_ROUTE_MOUNT REPLAY_SPLASH_WHILE_OVERLAY
run-flow-between-hold-and-wait: 1 MAESTRO_HOLD_COLD_START REPLAY_SPLASH_WHILE_OVERLAY
launch-between-hold-and-wait: 1 MAESTRO_HOLD_COLD_START REPLAY_SPLASH_WHILE_OVERLAY
two-hold-links: 1 SPLASH_HOLD_LINK_ROUTE_MOUNT
runflow-nested-commands: 1 MAESTRO_HOLD_COLD_START REPLAY_SPLASH_WHILE_OVERLAY
runflow-path: 1 MAESTRO_HOLD_COLD_START REPLAY_SPLASH_WHILE_OVERLAY
launch-empty-map: 1 MAESTRO_HOLD_COLD_START REPLAY_SPLASH_WHILE_OVERLAY
launch-with-app-id: 1 MAESTRO_HOLD_COLD_START REPLAY_SPLASH_WHILE_OVERLAY
assert-visible-between: 0 static 70/70
not-visible-between: 0 static 70/70
screenshot-between: 0 static 70/70
visible-between: 0 static 70/70
other-link-after-wait: 1 MAESTRO_SPLASH_FRAME_WAIT SPLASH_HOLD_LINK_ROUTE_MOUNT REPLAY_SPLASH_WHILE_OVERLAY
repeat-nested-launch-between: 0 static 70/70
retry-nested-launch-between: 0 static 70/70
ATTACK_EXPECTATIONS_FAILED=False
```

Последние два исхода — совет выше. Ссылка ПОСЛЕ ожидания красна: нарушена непосредственная последовательность «ожидание → кадр» и требование единственной ссылки канала, а не разрешённые незапускающие действия. Дополнительный запуск `python3 appid117k.py` → rc0 скрипта; внутри probe `launch-with-real-app-id: rc=1` (`com.complior.mobile`), сырой вывод:

```text
RED MAESTRO_HOLD_COLD_START: сценарий не запускает холодный старт каналом (Г′) по СОСТОЯНИЮ команд — запускающий шаг между openLink#2 и ожиданием#4 — запуск/повторный запуск приложения (launchApp любой формы, runFlow, иная ссылка; единый классификатор _is_launching, круг 3): стартовый URL при монтировании не читается
RED REPLAY_SPLASH_WHILE_OVERLAY: hold 1200 исходы ['CLASS_B', 'SPLASH']  (канал (Г): True холодный старт: False )
```

`python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --model --repo /tmp/dev-harness-verify/Critic117k/mob` → rc0 `static 70/70`, включая 15 клеток `MAESTRO_HOLD_PORJADOK_*`; `python3 fixtures/workshop_project/vkhod_117/vkhod_probe.py --model --repo /tmp/dev-harness-verify/Critic117k/mob` → rc0 `behavioral 191/191`.

`python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --matrix --repo /tmp/dev-harness-verify/Critic117k/mob` → 52 строки `mutant … red= […]`, включая сырое `mutant splash-hold-runflow-posle-link red= ['MAESTRO_HOLD_COLD_START', 'REPLAY_SPLASH_WHILE_OVERLAY']`; нет `MUTANT_GREEN`, `MUTANT_NAMED_MISS`, `MUTANT_UNEXPECTED_RED`, `MUTANT_INFRASTRUCTURE`, `MUTANT_ANCHOR_BROKEN` либо `MUTATION_MATRIX_HONEST_NOT_GREEN`. Оболочка фонового инструмента не показала код завершения: **[INFERENCE] rc0**, потому что исполняемая `matrix()` возвращает `0 if ok else 2`, а ошибочных маркеров нет; код не объявляю непосредственно наблюдавшимся.

`python3 -c "import subprocess,sys;p=subprocess.run([sys.executable,'fixtures/workshop_project/vkhod_117/vkhod_probe.py','--matrix','--repo','/tmp/dev-harness-verify/Critic117k/mob']);print('BEHAVIOR_MATRIX_RC='+str(p.returncode),flush=True);sys.exit(p.returncode)"` → `honest green 191`, 64 именованных красных мутанта, в конце сырой вывод:

```text
mutant splash-hold-link-invertirovan red= ['SPLASH_OVERLAY_HOLD_LINK_DARK', 'SPLASH_OVERLAY_HOLD_LINK_LIGHT', 'SPLASH_OVERLAY_HOLD_NE_INOJ_URL_DARK', 'SPLASH_OVERLAY_HOLD_NE_INOJ_URL_LIGHT', 'SPLASH_OVERLAY_HOLD_NE_NEMARSHRUT_DARK', 'SPLASH_OVERLAY_HOLD_NE_NEMARSHRUT_LIGHT', 'SPLASH_OVERLAY_TIMER_HIDE_DARK', 'SPLASH_OVERLAY_TIMER_HIDE_LIGHT', 'STATUS_BAR_STYLE_DARK', 'STATUS_BAR_STYLE_LIGHT']
mutant splash-hold-po-umolchaniju-8000 red= ['SPLASH_OVERLAY_HOLD_NE_INOJ_URL_DARK', 'SPLASH_OVERLAY_HOLD_NE_INOJ_URL_LIGHT', 'SPLASH_OVERLAY_HOLD_NE_NEMARSHRUT_DARK', 'SPLASH_OVERLAY_HOLD_NE_NEMARSHRUT_LIGHT', 'SPLASH_OVERLAY_TIMER_HIDE_DARK', 'SPLASH_OVERLAY_TIMER_HIDE_LIGHT', 'STATUS_BAR_STYLE_DARK', 'STATUS_BAR_STYLE_LIGHT']
mutant splash-hold-vse-ssylki red= ['SPLASH_OVERLAY_HOLD_NE_INOJ_URL_DARK', 'SPLASH_OVERLAY_HOLD_NE_INOJ_URL_LIGHT', 'SPLASH_OVERLAY_HOLD_NE_NEMARSHRUT_DARK', 'SPLASH_OVERLAY_HOLD_NE_NEMARSHRUT_LIGHT']
mutant splash-hold-taymer-bez-clear red= ['SPLASH_OVERLAY_HOLD_LINK_DARK', 'SPLASH_OVERLAY_HOLD_LINK_LIGHT']
BEHAVIOR_MATRIX_RC=0
```

`python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo /tmp/dev-harness-verify/Critic117k/mob` на неподменённом продукте → rc1, ровно пять именованных RED: `MAESTRO_HOLD_COLD_START`, `MAESTRO_HOLD_ALONE`, `SPLASH_HOLD_LINK_CHANNEL`, `SPLASH_HOLD_LINK_ROUTE_MOUNT`, `REPLAY_SPLASH_WHILE_OVERLAY`. `python3 fixtures/workshop_project/vkhod_117/vkhod_probe.py --repo /tmp/dev-harness-verify/Critic117k/mob` → rc1 `failed 36 of 191`; это прежняя продуктовая граница, не модельный ложный green.

`python3 -c "import subprocess,sys;p=subprocess.run([sys.executable,'pins117k.py']);print('PIN_SCRIPT_RC='+str(p.returncode),flush=True);sys.exit(p.returncode)"` → rc0; сырые результаты четырёх независимых порч:

```text
case kadr-file: rc=2 ORACLE_TAMPERED_lines=1
ORACLE_TAMPERED live/kadr-class-b-dark.png
case kadr-pin: rc=2 ORACLE_TAMPERED_lines=1
ORACLE_TAMPERED live/kadr-class-b-dark.png
case logcat-file: rc=2 ORACLE_TAMPERED_lines=2
ORACLE_TAMPERED live/proba117g-logcat-fragment.txt
case hierarchy-file: rc=2 ORACLE_TAMPERED_lines=2
ORACLE_TAMPERED live/proba117g-hierarchy-step006.json
PIN_CORRUPTION_EXPECTATIONS_FAILED=False
PIN_SCRIPT_RC=0
```

Гейты с корректными аргументами на объекте: `bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Critic117k/repo contracts/117-cmp-mob-vkhod-splash.md` → rc0 `ok гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2`, `КРИТИК: дверь зелёная`; `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic117k/repo contracts/117-cmp-mob-vkhod-splash.md` → rc0 `OK`; `check_spec_ready.sh` → rc0 `OK`; `check_ceilings.sh` → rc0, `12 persona`, `1 rules`, `138 drafts`; `check_provodka.sh` → rc0; `check_threat_model.sh` → rc0 (по одной защищаемой и незащищаемой границе). Коммита и push вердикта нет по прямому заданию текущего вызова.
