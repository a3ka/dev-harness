FAIL
OBJECT=47aa733d6cbd5a8dc232952eca14a3cd413daa4e
СУД: repo=dev-harness; предмет=995; фаза=контракт v5 (адресная по 143); роль=critic; вызов=1/2; модель-план=openai-codex/gpt-6-sol; сессия=Crit995a; модель-факт=openai-codex/gpt-6-sol; SHA=47aa733d6cbd5a8dc232952eca14a3cd413daa4e; предыдущий=нет; исключение=нет

БЛОКИРУЕТ contracts/995-cmp-mob-001-android-pilot.md:53,255,329 — критерий исполнительной клетки фиксированного набора путает четыре СКОПИРОВАННЫХ файла с четырьмя ИСПОЛНЕННЫМИ флоу: Maestro учитывает `flows` в скопированном `config.yaml`, а подложный maestro каталог-режима безусловно обходит `*.yaml` и игнорирует этот фильтр (`fixtures/workshop_project/pilot_995/restart/probe.py:384-418`).
ОБХОД: достижимая правка `mobile/.maestro/config.yaml`: сохранить штатные `flows: ["*", "!erstinformation.yaml"]`, добавить `"!start.yaml"`, не менять карту четырёх флоу. Проверка 118 требует наличие только `!erstinformation.yaml` и явно НЕ запрещает исключения чужих флоу (`fixtures/workshop_project/erstinformation_118/stubs/s-bez-kanonizacii-puti.py:118-138`). P копирует `config.yaml` и четыре файла, Maestro исключает start.yaml из исполнения; публикация pilot/rehearsal/вкладок может сохранить rc0, отчёт, три pilot-PNG и rehearsal evidence, required-агрегат получает зелёный e2e-pilot, хотя И-8 контракта 143 требует исполнения РОВНО четырёх флоу. Замкнутая red-клетка остаётся зелёной: подложный maestro не читает `config.yaml`. Проверяемое закрытие: зелёный исход обусловлен ФАКТИЧЕСКИМ исполнением всех четырёх перечисленных потоков с учётом фильтра Maestro; отрицательный контроль с config.yaml, исключающим один требуемый флоу при неизменной карте, краснеет. Не требуется менять S и прочие оси.

Сырой scoped-прогон атаки (одноразовый скрипт только в каталоге судьи, `python3 /tmp/dev-harness-verify/Crit995a/config_filter_attack.py`, rc 0):
```
Current fake: P rc=0; MAESTRO_POTOKI cmp-mob-002-tabs.yaml pilot.yaml rehearsal.yaml start.yaml
Faithful config filter: P rc=0; MAESTRO_POTOKI cmp-mob-002-tabs.yaml pilot.yaml rehearsal.yaml
```
Тот же вход `config.yaml` с исключением `start.yaml` и исходный fake, scoped вызов `sud_kejs('nabor-zaprosen-rovno', ...)`, rc 0:
```
CELL nabor-zaprosen-rovno: ('ok', None)
```
`Faithful config filter` — подложный фильтр Maestro по документированной в продукте 118 семантике `flows`; настоящий Maestro/эмулятор здесь не запускался. `maestro_probe.py:117-119,223-240` копирует config и проверяет непустой JUnit плюс три pilot-PNG, но не полноту именованных testcase. Это один класс причины — обход через конфигурацию исполнения после копирования, не новая область продукта.

Остальной суд адресности:
- `git cat-file -t 47aa733d6cbd5a8dc232952eca14a3cd413daa4e` → `commit`; HEAD собственного read-only клона тот же SHA. `git diff --name-only HEAD~1 HEAD` → ровно 6 путей: контракт, `maestro_probe.py`, `native_matrix.py`, `restart/model/maestro_probe.py`, `restart/probe.py`, `restart/source.json` (все в ЗОНА architect). Текстовый diff относительно `frozen/contracts/995/4` соответствует §«Замены v5» и двум ханкам draft 143; новый предмет P/один APK/e2e-pilot/агрегат, неизменные 96/252/284 frozen — имя required `android-e2e` остаётся агрегатом, модель 143 `e2e-pilot.timeout-minutes: 40`.
- `sha256sum restart/model/ci-e2e.sh maestro_probe.py restart/model/maestro_probe.py` (из `fixtures/workshop_project/pilot_995/`) → `0fa425b5db4752633c7ea453065503bfa8ecefa67e1bef8a7e66102426897f30`, `f50ecf6dacac9133d975d912de28bee7c8252a5dbe321bf1f740986b1bdfbd54`, `f50ecf6dacac9133d975d912de28bee7c8252a5dbe321bf1f740986b1bdfbd54`. Программная сверка `source.json` frozen/4 vs HEAD: прежние 51 клетки и 36 привязок стабов не изменены; единственный старый изменённый пин — `model/maestro_probe.py`; модель S и прочие носители не изменены.

Сырые команды / исходы (последовательно, без параллельных батарей):
```
bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh
rc=1 SUBJECT_ABSENT; CASE nabor-zaprosen-rovno KRASNO (SUBJECT_ABSENT); CASE nabor-net-karty KRASNO (SUBJECT_ABSENT); CASE nabor-bez-klyucha KRASNO (SUBJECT_ABSENT); CASE nabor-net-floy KRASNO (SUBJECT_ABSENT); всего 55 KRASNO
bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --model
rc=0; CASE nabor-zaprosen-rovno ok; CASE nabor-net-karty ok; CASE nabor-bez-klyucha ok; CASE nabor-net-floy ok; SVIP itog: N=20, krasnykh 0
bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --stabs
rc=0; STAB p-pustoj-nabor nabor-bez-klyucha KRASEN; STAB p-rglob-kataloga nabor-zaprosen-rovno KRASEN; STAB p-tihoe-suzhenie nabor-net-floy KRASEN; SVJAZI 63; zhivykh 0
bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --repo /tmp/dev-harness-verify/Crit995a/target-tree
rc=0; CASE nabor-zaprosen-rovno ok; CASE nabor-net-karty ok; CASE nabor-bez-klyucha ok; CASE nabor-net-floy ok; SVIP itog: N=20, krasnykh 0
python3 fixtures/workshop_project/pilot_995/native_matrix.py --scratch /tmp/dev-harness-verify/Crit995a
rc=0; 995 native-runner checked=16 Android=NOT_RUN
python3 /tmp/dev-harness-verify/Crit995a/tamper995/restart/probe.py --model
rc=2; ORACLE_TAMPERED: пин model/maestro_probe.py не сходится
```
`target-tree` — локальная копия read-only `/tmp/dev-harness-verify/Addr141/target-tree`, продукт HEAD `d0140101c6c4fca94687cf88c418344cd9601d59`; чужое дерево не менялось.

Сырые собственные мутации, `python3 /tmp/dev-harness-verify/Crit995a/mutate995.py`, rc=0:
```
rglob-vmesto-karty: CASE nabor-zaprosen-rovno KRASNO (запрошен набор ['cmp-mob-002-tabs.yaml', 'cmp-mob-004-start.yaml', 'erstinformation.yaml', 'first-run-ekran.yaml', 'pilot.yaml', 'rehearsal.yaml', 'start.yaml', 'vkhod-117-splash-vhod.yaml'] ≠ фиксированного ['cmp-mob-002-tabs.yaml', 'pilot.yaml', 'rehearsal.yaml', 'start.yaml'])
pustoj-nabor: CASE nabor-zaprosen-rovno KRASNO (запрошен набор ['pilot.yaml'] ≠ фиксированного ['cmp-mob-002-tabs.yaml', 'pilot.yaml', 'rehearsal.yaml', 'start.yaml'])
bez-odnogo: CASE nabor-zaprosen-rovno KRASNO (запрошен набор ['cmp-mob-002-tabs.yaml', 'pilot.yaml', 'start.yaml'] ≠ фиксированного ['cmp-mob-002-tabs.yaml', 'pilot.yaml', 'rehearsal.yaml', 'start.yaml'])
lishnij-floy: CASE nabor-zaprosen-rovno KRASNO (запрошен набор ['cmp-mob-002-tabs.yaml', 'erstinformation.yaml', 'pilot.yaml', 'rehearsal.yaml', 'start.yaml'] ≠ фиксированного ['cmp-mob-002-tabs.yaml', 'pilot.yaml', 'rehearsal.yaml', 'start.yaml'])
bez-klyucha-tihiy-uspekh: CASE nabor-bez-klyucha KRASNO (rc=0 (ожидался 2))
tihoye-suzhenie: CASE nabor-net-floy KRASNO (rc=0 (ожидался 2))
s-bajt: CASE kanon-bajt KRASNO (SKRIPT_RASHOZHDENIE: байты субъекта ≠ модели (копия байт-в-байт))
```
Отсутствие отдельного стаба на nabor-net-karty не обнаружило второго обхода: снятие одного из двух стражей всё ещё ведёт к SKHEMA_KARTY, а вход missing-key + самостоятельная мутация проверяют отказ; критерий не требует один стаб на каждый вход.

Гейты / соседи:
```
bash scripts/pre_critic.sh --repo . contracts/995-cmp-mob-001-android-pilot.md  # rc 0: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3; КРИТИК: дверь зелёная
bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Crit995a/repo contracts/995-cmp-mob-001-android-pilot.md  # rc 0: OK
bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Crit995a/repo contracts/995-cmp-mob-001-android-pilot.md  # rc 0: OK
bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Crit995a/repo  # rc 0: потолки в порядке
bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Crit995a/repo contracts/995-cmp-mob-001-android-pilot.md  # rc 0: ЗАЩИЩАЕТ 4, НЕ ЗАЩИЩАЕТ 4
bash scripts/check_provodka.sh /tmp/dev-harness-verify/Crit995a/repo contracts/995-cmp-mob-001-android-pilot.md  # rc 1: проводка: guard не подключён (ожидаемое окно до интеграционного коммита orchestrator)
bash /tmp/dev-harness-verify/Crit995a/provodka-copy/scripts/check_provodka.sh /tmp/dev-harness-verify/Crit995a/provodka-copy contracts/995-cmp-mob-001-android-pilot.md  # rc 0 на disposable копии с одной step-строкой
bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs  # rc 2: NEEDS_PRECEDENT p01; клеток 69, зелёных 68, красных 0; стабов 33, привязок 49, непойманных 0
bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --stabs  # rc 0: SVJAZI 60
bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --stabs  # rc 0: SVJAZI 61; zhivykh 0
```
`bash scripts/check_zones.sh /tmp/dev-harness-verify/Crit995a/repo` запущен отдельно; при записи этого файла ещё не закончен. Ограниченная статическая сверка шести файлов `git diff --name-only HEAD~1 HEAD` с `ЗОНА architect` положительна.

НЕ ПРОВЕРЕНО: настоящий Android/устройство/живой Maestro с config-фильтром, CI run, фактический перепин H после freeze и активация p01 батареи 143. Трейс не выдаёт непрозрачный runtime session ID: в строке СУД указан доступный идентификатор агента `Crit995a` (`history://Crit995a`), модель-факт — runtime metadata `openai-codex/gpt-6-sol`; фактическая модель архитектора из независимого трейса не предъявлена, но FAIL не зависит от этой сверки. Ни push, ни commit судья не делал по заданию.
