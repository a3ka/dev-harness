FAIL
OBJECT=814a71169388b3970dae0c0f0caf3694abb4c9f9
СУД: repo=dev-harness; предмет=995 (v+1); фаза=контракт; роль=critic-sol; вызов=2/2; модель-план=openai-codex/gpt-6-sol; сессия=Critic995b (trace 01a177ee-2a48-75af-86f8-4e9d5af0e8c0); модель-факт=openai-codex/gpt-6-sol; SHA=814a71169388b3970dae0c0f0caf3694abb4c9f9; предыдущий=verdicts/critic/contracts-995-v2-krug1-fail.md (FAIL 1/2, 8ae962ff6); исключение=нет. Автор Architect995v2b — zai/glm-5.3, независимость соблюдена.

## БЛОКИРУЕТ

БЛОКИРУЕТ contracts/995-cmp-mob-001-android-pilot.md:47 — батарея обещает проверять живой owned PID **непосредственно перед установкой APK**, но принимает модель, переносящую эту проверку к `adb wait-for-device`, до трёх настроек анимации. Класс причины тот же, что в круге 1: универсальное обязательство о владении новой инкарнацией доказывается лишь двумя частными моментами её смерти — сразу после EMULATOR_START и перед вторым набором; смерти между готовностью и установкой клетки нет. Смена момента проверки НЕ запрещена байтовым пином: в одноразовой копии модели пин законно пересчитывается вместе с моделью, 29/29 зелёные. На достижимом состоянии, когда собственный новый PID умирает на третьем `adb shell settings put global` после перенесённой проверки, но serial по-прежнему отвечает, модель корректно отказывает без установки, а зелёная контрмодель выполняет `ADB_INSTALL rc=0` **после** `EMULATOR_STOP <новый PID>` (фактический replay ниже). До второго Maestro контрмодель всё же отказывает: находка — ложная установка на чужой/старой инкарнации, НЕ ложное RECOVERED.
ОБЯЗАТЕЛЬСТВО: живой owned PID проверяется перед APK install; при мёртвом owned PID готовность/установка/набор на чужом serial не выполняются (инварианты 8, 10, также `ЗАЩИЩАЕТ` v+1).
СОСТОЯНИЕ: после успешного `wait-for-device` нового PID и до APK install emulator выходит во время настройки анимации, stale/foreign serial продолжает отвечать.
НАБЛЮДЕНИЕ: удаление проверки прямо перед APK install с переносом её сразу за `wait-for-device` даёт `--model` 29/29 rc0 при новом пине; специально назначенная смерть приводит к последовательности `EMULATOR_STOP 2415517 | ADB_INSTALL rc=0`, тогда как неизменённая модель заканчивает без второго `ADB_INSTALL`.
ОБХОД: поставляемые байты модели S заменить на перенесённую проверку, согласованно обновить sha256 в source.json и контракте; именованные красные клетки и структурный пин остаются зелёными, но установка происходит после смерти нового PID. Стаб `s-bez-zhizni` удаляет ВСЕ проверки и потому эту контрмодель не различает.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: поведенческий красный тест назначает смерть нового owned PID после прохождения ранней проверки/готовности, но **до** APK install при отвечающем serial; ожидает именованный отказ и отсутствие `ADB_INSTALL`/Maestro/RECOVERED. Тест не должен принимать перенос kill -0 в любую более раннюю точку как эквивалент проверки непосредственно перед install.

АРБИТР: независимый arbiter; предмет спора второго FAIL 995 v+1 — достаточно ли двух частных сценариев смерти для обещанного контроля живого owned PID перед установкой на всём классе достижимых состояний. Третий critic-вызов автоматически не назначать; freeze без accept не делать.

## СЫРЫЕ КОМАНДЫ И ВЫВОДЫ АТАК

Исторический S получен `git show 8ae962ff6:fixtures/workshop_project/pilot_995/restart/model/ci-e2e.sh`, новый S — байты HEAD; `/tmp/dev-harness-verify/Critic995b/replay995.py` использует неизменённые функции `probe.py` (сценарии и oracles source.json новой батареи) и печатает фактические события. Команда:

```
$ env -i PATH=/home/harness/.local/bin:/usr/bin:/bin python3 /tmp/dev-harness-verify/Critic995b/replay995.py
DELTA kejsy added ['inkarnacija-mertva-na-starte', 'inkarnacija-mertva-pered-vtorym', 'inkarnacija-mertva-vo-vtorom'] deleted [] changed []
DELTA stab_vhod added ['s-bez-zhizni', 's-zhizn-tolko-na-gotovnosti'] deleted [] changed []
DELTA other ['nositeli']
OLD inkarnacija-mertva-na-starte rc 0 reason None
EVENTS EMULATOR_START ci-567890123-1 2327269 | ADB_INSTALL rc=0 | MAESTRO 1 rc=1 | EMULATOR_STOP 2327269 | EMULATOR_START ci-567890123-1 2327852 | EMULATOR_STOP 2327852 | ADB_INSTALL rc=0 | MAESTRO 2 rc=0
OUTPUT RECOVERED: обрыв adb-транспорта попытки 1 пережит перезапуском собственного эмулятора; попытка 2 зелёная
JUDGMENT CHISTYJ: rc=0 (ожидался 1)
NEW inkarnacija-mertva-na-starte rc 1 reason None
EVENTS EMULATOR_START ci-567890123-1 2331426 | ADB_INSTALL rc=0 | MAESTRO 1 rc=1 | EMULATOR_STOP 2331426 | EMULATOR_START ci-567890123-1 2332112 | EMULATOR_STOP 2332112
OUTPUT ОТКАЗ: owned PID эмулятора мёртв (поколение 2, pid 2332112) — новая инкарнация не подтверждена, чужой/старый процесс на порту emulator-5560 не принимается | ОТКАЗ: перезапуск эмулятора не дал готовности (поколение 2)
JUDGMENT None
OLD inkarnacija-mertva-pered-vtorym rc 0 reason None
EVENTS EMULATOR_START ci-567890123-1 2335710 | ADB_INSTALL rc=0 | MAESTRO 1 rc=1 | EMULATOR_STOP 2335710 | EMULATOR_START ci-567890123-1 2336116 | ADB_INSTALL rc=0 | EMULATOR_STOP 2336116 | MAESTRO 2 rc=0
OUTPUT RECOVERED: обрыв adb-транспорта попытки 1 пережит перезапуском собственного эмулятора; попытка 2 зелёная
JUDGMENT CHISTYJ: rc=0 (ожидался 1)
NEW inkarnacija-mertva-pered-vtorym rc 1 reason None
EVENTS EMULATOR_START ci-567890123-1 2339927 | ADB_INSTALL rc=0 | MAESTRO 1 rc=1 | EMULATOR_STOP 2339927 | EMULATOR_START ci-567890123-1 2340385 | ADB_INSTALL rc=0 | EMULATOR_STOP 2340385
OUTPUT ОТКАЗ: owned PID эмулятора мёртв (поколение 2, pid 2340385) — новая инкарнация не подтверждена, чужой/старый процесс на порту emulator-5560 не принимается | ОТКАЗ: owned PID новой инкарнации мёртв непосредственно перед набором 2 — Maestro не запускается, повтор не расходуется, итог попытки 1 сохранён
JUDGMENT None
NEW inkarnacija-mertva-vo-vtorom rc 0 reason None
EVENTS EMULATOR_START ci-567890123-1 2347675 | ADB_INSTALL rc=0 | MAESTRO 1 rc=1 | EMULATOR_STOP 2347675 | EMULATOR_START ci-567890123-1 2348060 | ADB_INSTALL rc=0 | MAESTRO 2 rc=0 | EMULATOR_STOP 2348060
OUTPUT RECOVERED: обрыв adb-транспорта попытки 1 пережит перезапуском собственного эмулятора; попытка 2 зелёная
JUDGMENT None
NEW obryv-device-offline rc 0 reason None
EVENTS EMULATOR_START ci-567890123-1 2353908 | ADB_INSTALL rc=0 | MAESTRO 1 rc=1 | EMULATOR_STOP 2353908 | EMULATOR_START ci-567890123-1 2354126 | ADB_INSTALL rc=0 | MAESTRO 2 rc=0 | EMULATOR_STOP 2354126
OUTPUT RECOVERED: обрыв adb-транспорта попытки 1 пережит перезапуском собственного эмулятора; попытка 2 зелёная
JUDGMENT None
[exit=0]
```

Первая собственная мутация только УДАЛЯЛА предустановочную проверку: НЕ зелёная, клетка `inkarnacija-mertva-na-starte` её ловит. Это не основание FAIL; сырой вывод атаки:

```
$ env -i PATH=/home/harness/.local/bin:/usr/bin:/bin python3 /tmp/dev-harness-verify/Critic995b/attack-install995.py
MUTATION: omit ONLY pre-install zhiv_svoyo
CASE pervaja-zelena ok
CASE obryv-device-offline ok
CASE obryv-adb-notfound ok
CASE obryv-serial-notfound ok
CASE obryv-devserverdied ok
CASE produkt-assert ok
CASE produkt-install-tekst ok
CASE smeshannyj ok
CASE vtoroj-krasnyj-produkt ok
CASE vtoroj-transportnyj ok
CASE staryj-artefakt ok
CASE pustoj-vyvod ok
CASE ustanovka-otkaz ok
CASE boot-ne-gotov ok
CASE stabil-nedostizhima ok
CASE malo-pamyati ok
CASE inkarnacija-mertva-na-starte KRASNO CHISTYJ: записи: [AVDMANAGER_CREATE ci-633993812-1 | ADB_STARTSERVER | EMULATOR_START ci-633993812-1 2386053 | ADB_INSTALL rc=0 …] ≠ [AVDMANAGER_CREATE ci-633993812-1 | ADB_STARTSERVER | EMULATOR_START ci-633993812-1 2386053 | ADB_INSTALL rc=0 …]
CASE inkarnacija-mertva-pered-vtorym ok
CASE inkarnacija-mertva-vo-vtorom ok
REPLAY_MISMATCHES ['inkarnacija-mertva-na-starte']
MODEL RC 1 REASON None
MODEL EVENTS EMULATOR_START ci-567890123-1 2389523 | ADB_INSTALL rc=0 | MAESTRO 1 rc=1 | EMULATOR_STOP 2389523 | EMULATOR_START ci-567890123-1 2389928 | EMULATOR_STOP 2389928
MUTANT RC 1 REASON None
MUTANT EVENTS EMULATOR_START ci-567890123-1 2390346 | ADB_INSTALL rc=0 | MAESTRO 1 rc=1 | EMULATOR_STOP 2390346 | EMULATOR_START ci-567890123-1 2390723 | EMULATOR_STOP 2390723 | ADB_INSTALL rc=0
[exit=0]
```

После этого тот же скрипт переписан на строго одну естественную контрмодель: **перенос** проверки перед установкой сразу после `wait-for-device`, не удаление. Сырой вывод:

```
$ env -i PATH=/home/harness/.local/bin:/usr/bin:/bin python3 /tmp/dev-harness-verify/Critic995b/attack-install995.py
MUTATION: move ONLY pre-install check to after wait-for-device
CASE pervaja-zelena ok
CASE obryv-device-offline ok
CASE obryv-adb-notfound ok
CASE obryv-serial-notfound ok
CASE obryv-devserverdied ok
CASE produkt-assert ok
CASE produkt-install-tekst ok
CASE smeshannyj ok
CASE vtoroj-krasnyj-produkt ok
CASE vtoroj-transportnyj ok
CASE staryj-artefakt ok
CASE pustoj-vyvod ok
CASE ustanovka-otkaz ok
CASE boot-ne-gotov ok
CASE stabil-nedostizhima ok
CASE malo-pamyati ok
CASE inkarnacija-mertva-na-starte ok
CASE inkarnacija-mertva-pered-vtorym ok
CASE inkarnacija-mertva-vo-vtorom ok
REPLAY_MISMATCHES []
MODEL RC 1 REASON None
MODEL EVENTS EMULATOR_START ci-567890123-1 2414999 | ADB_INSTALL rc=0 | MAESTRO 1 rc=1 | EMULATOR_STOP 2414999 | EMULATOR_START ci-567890123-1 2415197 | EMULATOR_STOP 2415197
MODEL OUTPUT ОТКАЗ: owned PID эмулятора мёртв (поколение 2, pid 2415197) — новая инкарнация не подтверждена, чужой/старый процесс на порту emulator-5560 не принимается | ОТКАЗ: перезапуск эмулятора не дал готовности (поколение 2)
MUTANT RC 1 REASON None
MUTANT EVENTS EMULATOR_START ci-567890123-1 2415252 | ADB_INSTALL rc=0 | MAESTRO 1 rc=1 | EMULATOR_STOP 2415252 | EMULATOR_START ci-567890123-1 2415517 | EMULATOR_STOP 2415517 | ADB_INSTALL rc=0
MUTANT OUTPUT ОТКАЗ: owned PID эмулятора мёртв (поколение 2, pid 2415517) — новая инкарнация не подтверждена, чужой/старый процесс на порту emulator-5560 не принимается | ОТКАЗ: owned PID новой инкарнации мёртв непосредственно перед набором 2 — Maestro не запускается, повтор не расходуется, итог попытки 1 сохранён
[exit=0]
```

Полный W на одноразовой копии `/tmp/dev-harness-verify/Critic995b/mutant` (в HEAD предмета НИ ОДНОГО изменения): `git clone /tmp/dev-harness-verify/Critic995b/repo /tmp/dev-harness-verify/Critic995b/mutant`; `python3 /tmp/dev-harness-verify/Critic995b/mutate995.py` меняет только модель S и её pin `MUTANT_MODEL_PIN 3d72a9ad273aaded4101f86bb977b12cd277783d45e2cbb66900414cd294745a`. Команда и весь вывод:

```
$ env -i PATH=/home/harness/.local/bin:/usr/bin:/bin bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --model
CASE pervaja-zelena ok
CASE obryv-device-offline ok
CASE obryv-adb-notfound ok
CASE obryv-serial-notfound ok
CASE obryv-devserverdied ok
CASE produkt-assert ok
CASE produkt-install-tekst ok
CASE smeshannyj ok
CASE vtoroj-krasnyj-produkt ok
CASE vtoroj-transportnyj ok
CASE staryj-artefakt ok
CASE pustoj-vyvod ok
CASE ustanovka-otkaz ok
CASE boot-ne-gotov ok
CASE stabil-nedostizhima ok
CASE malo-pamyati ok
CASE inkarnacija-mertva-na-starte ok
CASE inkarnacija-mertva-pered-vtorym ok
CASE inkarnacija-mertva-vo-vtorom ok
CASE kanon-bajt ok
CASE zhyvoj-p-kanon ok
CASE zapret-stroki ok
CASE kanon-signatury ok
CASE staryj-s-bez-pravki ok
CASE staryj-p-bez-pravki ok
CASE p-recovered ok
CASE p-exhausted ok
CASE p-produkt ok
CASE p-timeout ok
[exit=0]
```

`W --stabs` неизменённого OBJECT: rc0, контроль 29/29; добавленные строки дословно `STAB s-bez-zhizni inkarnacija-mertva-na-starte KRASEN`, `STAB s-bez-zhizni inkarnacija-mertva-pered-vtorym KRASEN`, `STAB s-zhizn-tolko-na-gotovnosti inkarnacija-mertva-pered-vtorym KRASEN`, `SVJAZI 41`, `zhivykh 0`. Эти обманки не являются контрпримером переносу middle check; 29 клеток на оригинале зелёны три запуска подряд. Прежние 26 клеток/23 привязки байт-неизменны; старый S на новой батарее (а),(б) красный, новый зелёный. W без флагов: rc1 SUBJECT_ABSENT, 29 KRASNO. W `--repo /tmp/dev-harness-verify/Critic995b/mob` на продукте @52a5cf5468408c54fda96825cd93ad6ecdaa7c90: rc1; красные исходные S/P; цель запрета прежней реализации предъявлена.

## ПРЕДВАРИТЕЛЬНО ИСПОЛНЕННЫЕ ГЕЙТЫ

`git show -s --format='%H%n%P%n%an%n%B' HEAD`: OBJECT 814a71169388b3970dae0c0f0caf3694abb4c9f9, единственный родитель 72f7a7628645fd6a8607427f039f95596c23a87c, автор architect; дословная строка `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/995-cmp-mob-001-android-pilot.md v+1 — перезапуск собственного эмулятора и один повтор набора в mobile/scripts/ci-e2e.sh по обрыву транспорта, redacted диагностика обеих попыток, причинный замер; ЗОНА implementer дополняется mobile/scripts/ci-e2e.sh (слово владельца 2026-10-26, консультация Astra)`; diff только контракт и pilot_995/. Названы implementer/architect/orchestrator и их ЗОНА; класс рисковый, модель угроз есть. Остаток «owned PID жив, чужой порт» честно вынесен в `НЕ ЗАЩИЩАЕТ` (стр. 218), к доказанной смерти PID до установки он НЕ относится.

```
$ bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Critic995b/repo contracts/995-cmp-mob-001-android-pilot.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
КРИТИК: дверь зелёная
[exit=0]
$ bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Critic995b/repo contracts/995-cmp-mob-001-android-pilot.md
OK
[exit=0]
$ bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Critic995b/repo contracts/995-cmp-mob-001-android-pilot.md
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 136 черновик(ов) судится, замороженные — по тегам
потолки в порядке
[exit=0]
$ bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Critic995b/repo contracts/995-cmp-mob-001-android-pilot.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 4 буллет(ов), НЕ ЗАЩИЩАЕТ 4 буллет(ов))
[exit=0]
$ bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic995b/repo contracts/995-cmp-mob-001-android-pilot.md
/tmp/dev-harness-verify/Critic995b/repo/scripts/lib_zones.sh: line 328: /tmp/lib_zones.553fc2f2.xeYENl/ranges: No such file or directory
/tmp/dev-harness-verify/Critic995b/repo/scripts/lib_zones.sh: line 299: /tmp/lib_zones.553fc2f2.xeYENl/contracts_list: No such file or directory
[затем однотипные сообщения об отсутствии /tmp/lib_zones.553fc2f2.xeYENl/zones_scoped; полный сырой log artifact://969]
OK
[exit=0]
```

После доказанного блокера не запускал соседние матрицы 139/141, 5×2 параллельных прогона, порчи носителей и `check_provodka` на копии: остановка по заданию «Блокер — сразу доклад». Скрипты атак — временные, лежат только в /tmp/dev-harness-verify/Critic995b; контракт и реализация на OBJECT не изменены.

## СОВЕТ

СОВЕТ contracts/995-cmp-mob-001-android-pilot.md:54 — параллельный `check_precision_gate` с другими гейтами выдал множество ошибок чтения исчезнувшего `/tmp/lib_zones.553fc2f2.xeYENl/`, хотя закончился `OK` rc0; из-за ранней остановки не установлено, влияет ли это на точность/изоляцию precision-gate. Не основание для этого FAIL.
