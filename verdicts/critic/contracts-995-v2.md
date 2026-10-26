accept
OBJECT=242d18a95582087e8f2a67758508e209ccd69b45
СУД: repo=dev-harness; предмет=995 (v+1); фаза=контракт; роль=critic-sol; вызов=3 (по решению арбитра, сверх 2/2); модель-план=openai-codex/gpt-6-sol; сессия=Critic995c; модель-факт=openai-codex/gpt-6-sol (workstation); SHA=242d18a95582087e8f2a67758508e209ccd69b45; предыдущий=verdicts/critic/contracts-995-v2-krug1-fail.md, verdicts/critic/contracts-995-v2-krug2-fail.md, verdicts/arbitration/contracts-995-v2-arbitraz.md; исключение=вызов сверх лимита 2 по решению арбитра (разрешён заранее, только перечень G). Автор Architect995v2c — zai/glm-5.3; семейства различны.

Граница суда: только G(i)–(iv) арбитража; открытых блокирующих находок нет. `git clone ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/Critic995c/repo`; `git fetch origin wip/995/architect-v2e`; `git checkout -q 242d18a95582087e8f2a67758508e209ccd69b45` → HEAD `242d18a95582087e8f2a67758508e209ccd69b45`. Рабочая копия для испытаний — отдельный local clone `/tmp/dev-harness-verify/Critic995c/scratch`; мутации только в иных одноразовых копиях. Вердикт не коммичу и не отправляю (условие задания).

## G(i): команды и наблюдённые выходы

`W = env -i PATH=/home/harness/.local/bin:/usr/bin:/bin bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh`, cwd=`/tmp/dev-harness-verify/Critic995c/scratch`. Без флага: rc=1; первая строка stderr `SUBJECT_ABSENT: нет --repo/MOB_REPO; зелень без субъекта невозможна`; stdout `CASE pervaja-zelena KRASNO (SUBJECT_ABSENT)` … `CASE inkarnacija-smert-svip KRASNO (SUBJECT_ABSENT)` … `CASE p-timeout KRASNO (SUBJECT_ABSENT)`; посчитаны 30 красных.

`W --model` три **последовательных** запуска: rc=0, rc=0, rc=0, 30 строк `CASE … ok` каждый, в каждом дословно:
```
SVIP k= 1 adb -s emulator-5560 wait-for-device                       ok
SVIP k= 2 adb -s emulator-5560 shell getprop sys.boot_completed      ok
SVIP k= 3 sleep 3                                                    ok
SVIP k= 4 adb -s emulator-5560 shell getprop sys.boot_completed      ok
SVIP k= 5 adb -s emulator-5560 shell settings put global window_anim ok
SVIP k= 6 adb -s emulator-5560 shell settings put global transition_ ok
SVIP k= 7 adb -s emulator-5560 shell settings put global animator_du ok
SVIP k= 8 adb -s emulator-5560 install -r /tmp/baterija995r-…        ok
SVIP k= 9 adb -s emulator-5560 get-state                             ok
SVIP k=10 adb -s emulator-5560 shell pm path com.complior.mobile     ok
SVIP k=11 sleep 2                                                    ok
SVIP k=12 adb -s emulator-5560 get-state                             ok
SVIP k=13 adb -s emulator-5560 shell pm path com.complior.mobile     ok
SVIP k=14 sleep 2                                                    ok
SVIP k=15 adb -s emulator-5560 get-state                             ok
SVIP k=16 adb -s emulator-5560 shell pm path com.complior.mobile     ok
SVIP k=17 adb -s emulator-5560 shell cat /proc/sys/kernel/random/boo ok
SVIP k=18 adb -s emulator-5560 shell pidof adbd                      ok
SVIP k=19 adb devices -l                                             ok
SVIP k=20 adb -s emulator-5560 shell logcat -d -t 200                ok
SVIP itog: N=20, krasnykh 0
CASE inkarnacija-smert-svip ok
```
Строка k=8 содержит разный случайный временный путь в каждом запуске (фактические суффиксы `j6rxiii0`, `pfdjdv_d`, `5wricpp9`), здесь заменён только суффикс для чтения; остальные строки — сырые. `W --stabs`: rc=0, контроль 30/30, вся матрица `SVJAZI 44`, `zhivykh 0`; сырые новые свидетели:
```
SVIP k= 1 adb -s emulator-5560 wait-for-device                       KRASNO
SVIP itog: N=20, krasnykh 1 (k=1)
STAB s-bez-zhizni inkarnacija-smert-svip KRASEN
SVIP k= 1 adb -s emulator-5560 wait-for-device                       KRASNO
SVIP itog: N=20, krasnykh 1 (k=1)
STAB s-zhizn-ne-pered-nastrojkami inkarnacija-smert-svip KRASEN
SVIP k= 7 adb -s emulator-5560 shell settings put global animator_du KRASNO
SVIP itog: N=20, krasnykh 1 (k=7)
STAB s-zhizn-perenesena inkarnacija-smert-svip KRASEN
SVJAZI 44
zhivykh 0
```
Прежние STAB-строки тоже все `KRASEN`, ни одной `ZHIV`.

Живой продукт: `git -c credential.helper='!gh auth git-credential' clone https://github.com/a3ka/Complior-mob.git /tmp/dev-harness-verify/Critic995c/product`; `git checkout -q 52a5cf5468408c54fda96825cd93ad6ecdaa7c90`; `W --repo /tmp/dev-harness-verify/Critic995c/product` → rc=1, 22 `KRASNO`/8 `ok`; сырой новый отказ:
```
SVIP N=0: нет второй инкарнации (якорь NACHALO2 не встречен)
CASE inkarnacija-smert-svip KRASNO (SVIP: нет второй инкарнации (N=0; якорь NACHALO2 не встречен в трассе))
CASE kanon-bajt KRASNO (SKRIPT_RASHOZHDENIE: байты субъекта ≠ модели (копия байт-в-байт))
```

Команда `python3 /tmp/dev-harness-verify/Critic995c/verify_attacks.py` (четыре отдельные local-копии, реальная порча S/P/носителя/таблицы, вызов `W --model` в каждой, затем 5×2 параллельных `W --model`) → итог rc=0; сырой вывод атак:
```
TAMPER S rc=2
ORACLE_TAMPERED: пин model/ci-e2e.sh не сходится
TAMPER P rc=2
ORACLE_TAMPERED: пин model/maestro_probe.py не сходится
TAMPER nositel rc=2
ORACLE_TAMPERED: пин nositeli/ci-e2e-staryj.sh не сходится
TAMPER stab_vhod rc=2
ORACLE_TAMPERED: stab_vhod != STAB_MUTACII
PARALLEL 1-A rc=0; ['SVIP itog: N=20, krasnykh 0']; red=[]; stderr=''
PARALLEL 1-B rc=0; ['SVIP itog: N=20, krasnykh 0']; red=[]; stderr=''
PARALLEL 2-A rc=0; ['SVIP itog: N=20, krasnykh 0']; red=[]; stderr=''
PARALLEL 2-B rc=0; ['SVIP itog: N=20, krasnykh 0']; red=[]; stderr=''
PARALLEL 3-A rc=0; ['SVIP itog: N=20, krasnykh 0']; red=[]; stderr=''
PARALLEL 3-B rc=0; ['SVIP itog: N=20, krasnykh 0']; red=[]; stderr=''
PARALLEL 4-A rc=0; ['SVIP itog: N=20, krasnykh 0']; red=[]; stderr=''
PARALLEL 4-B rc=0; ['SVIP itog: N=20, krasnykh 0']; red=[]; stderr=''
PARALLEL 5-A rc=0; ['SVIP itog: N=20, krasnykh 0']; red=[]; stderr=''
PARALLEL 5-B rc=0; ['SVIP itog: N=20, krasnykh 0']; red=[]; stderr=''
```

Гейты, cwd scratch: `bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Critic995c/scratch contracts/995-cmp-mob-001-android-pilot.md` rc=0, `КРИТИК: дверь зелёная`; `bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Critic995c/scratch contracts/995-cmp-mob-001-android-pilot.md` rc=0, `модель угроз: секция валидна (ЗАЩИЩАЕТ 4 буллет(ов), НЕ ЗАЩИЩАЕТ 4 буллет(ов))`; `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic995c/scratch contracts/995-cmp-mob-001-android-pilot.md` rc=0 `OK`; `bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Critic995c/scratch contracts/995-cmp-mob-001-android-pilot.md` rc=0 `OK`; `bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Critic995c/scratch contracts/995-cmp-mob-001-android-pilot.md` rc=0 `потолки в порядке`. `git clone --local scratch provodka` + `python3 /tmp/dev-harness-verify/Critic995c/add_provodka.py` (одна строка `step\tcheck:ci-e2e-restart-995-family-selftest\t90\tbash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --stabs`); `bash scripts/check_provodka.sh /tmp/dev-harness-verify/Critic995c/provodka contracts/995-cmp-mob-001-android-pilot.md` → rc=0, пустой stdout.

Соседи, cwd scratch: `python3 fixtures/workshop_project/pilot_995/native_matrix.py --scratch /tmp/dev-harness-verify/Critic995c` → rc=0, `995 native-runner checked=16 Android=NOT_RUN`; `bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --stabs` → rc=0, `SVJAZI 61`, `zhivykh 0`; `bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --stabs` → rc=0, `SVJAZI 60`.

## G(ii): контрмодели с перепином (свои копии)

Созданы `git clone --local scratch mut-critic`, `mut-arbiter`. `python3 /tmp/dev-harness-verify/Critic995c/mutate.py /tmp/dev-harness-verify/Critic995c/mut-critic critic` применяет **два дословных needle** `Critic995b/mutate995.py`: перенос `zhiv_svoyo` от `install` к `wait-for-device`; `… mut-arbiter arbiter` удаляет только проверку из цикла `settings put`; обе переустанавливают `source.json.nositeli[model/ci-e2e.sh]` из sha256 изменённых байтов. Вывод подготовки: `MUTANT_MODEL_PIN 5d11a72ea6f3798c99d8d9152a2fce4decf8bc08fb431ef7084766e4a82b6815`; `MUTANT_MODEL_PIN 89e684565ad929b5e5dbfba5334c953042166dbdca136591c1cd6fb1d74fa2b7`.

`W --model` (cwd mut-critic) → rc=1; **все прочие 29 CASE ok**, сырой вывод красного:
```
SVIP k= 1 adb -s emulator-5560 wait-for-device                       ok
SVIP k= 2 adb -s emulator-5560 shell getprop sys.boot_completed      ok
SVIP k= 3 sleep 3                                                    ok
SVIP k= 4 adb -s emulator-5560 shell getprop sys.boot_completed      ok
SVIP k= 5 adb -s emulator-5560 shell settings put global window_anim ok
SVIP k= 6 adb -s emulator-5560 shell settings put global transition_ ok
SVIP k= 7 adb -s emulator-5560 shell settings put global animator_du KRASNO
SVIP k= 8 adb -s emulator-5560 install -r /tmp/baterija995r-lzjtf6f3 ok
SVIP itog: N=20, krasnykh 1 (k=7)
CASE inkarnacija-smert-svip KRASNO (k=7 (adb -s emulator-5560 shell settings put global animator_duration_scale): состояние-меняющие вызовы ПОСЛЕ смерти: adb -s emulator-5560 install -r /tmp/baterija995r-lzjtf6f3/s)
```
`W --model` (cwd mut-arbiter) → rc=1; **все прочие 29 CASE ok**, сырой вывод:
```
SVIP k= 1 adb -s emulator-5560 wait-for-device                       KRASNO
SVIP k= 2 adb -s emulator-5560 shell getprop sys.boot_completed      KRASNO
SVIP k= 3 sleep 3                                                    KRASNO
SVIP k= 4 adb -s emulator-5560 shell getprop sys.boot_completed      KRASNO
SVIP k= 5 adb -s emulator-5560 shell settings put global window_anim KRASNO
SVIP k= 6 adb -s emulator-5560 shell settings put global transition_ KRASNO
SVIP k= 7 adb -s emulator-5560 shell settings put global animator_du ok
SVIP itog: N=20, krasnykh 6 (k=1,2,3,4,5,6)
CASE inkarnacija-smert-svip KRASNO (k=1 (adb -s emulator-5560 wait-for-device): состояние-меняющие вызовы ПОСЛЕ смерти: adb -s emulator-5560 shell settings put global window_animat | adb -s emulator-5560 shell settings put global transition_an | adb -s emulator-5560 shell settings put global animator_dura)
```
Дополнительный исходный свидетель: отдельная копия mut-historical, `python3 /tmp/dev-harness-verify/Critic995c/setup_variants.py` берёт модель `814a71169`, буквально применяет перенос `Critic995b/mutate995.py` и перепинивает; `HISTORICAL sha256 3d72a9ad273aaded4101f86bb977b12cd277783d45e2cbb66900414cd294745a` (совпадает с прежним свидетелем); `W --model` в mut-historical → rc=1, только свип красен, `SVIP itog: N=20, krasnykh 6 (k=2,3,4,5,6,7)`, `CASE inkarnacija-smert-svip KRASNO (k=2 (adb -s emulator-5560 shell getprop sys.boot_completed): состояние-меняющие вызовы ПОСЛЕ смерти: adb -s emulator-5560 shell settings put global window_animat | adb -s emulator-5560 shell settings put global transition_an | adb -s emulator-5560 shell settings put global animator_dura | adb -s emulator-5560 install -r /tmp/baterija995r-c9s2929h/s)`.

## G(iii): именно свойство свипа

`probe.py:52-110,659-770,1160-1230`, `source.json:1813-1890`, `model/ci-e2e.sh:96-125,212-267` прочитаны вместе с исполнением. `_svip_tochki` строит N из **чистого ispolnit_s**: после `NACHALO2` до `maestro` (его запуск — граница отдельной клетки (г)), исключает только не-принадлежащий второй инкарнации `sleep 1` остановки старого PID, дочерний `emulator` с fork→printf и служебные маркеры. `adb` и `sleep` пишут вызовы в отдельный `vyzovy`; `getprop` внутри `boot=pozdno` даёт 0, затем `sleep 3`, повторный `getprop` даёт 1: эти k=2,3,4 присутствуют и пройдены. В шимах trap `EXIT` исполняет эффект команды, затем `TERM` PID второго `EMULATOR_START`, ограниченно ждёт `EMULATOR_STOP`, пишет `SMERT k pid=…`; красный именно на последующем `settings put/install`, а не на отсутствующем субъекте. Ожидание `ozh` взято из `source.json` **до** replay субъекта; rc=1, `MAESTRO 2` отсутствует, `RECOVERED` отсутствует, `ОТКАЗ: owned PID`, попытка 1 (`report.xml attempt="1"`, диагностика 1 полная, у попытки 2 нет `maestro.log`), после `SMERT` нет совпадения `adb .* install -r|adb .* settings put|maestro `. Это ровно три вида `adb install`/`adb shell settings put`/`maestro` инв. 8, и неизвестная команда adb закрыта rc127. `W --repo` выше предъявил N=0 → красное. Отдельная клетка `inkarnacija-mertva-vo-vtorom` оставлена побайтно прежней, в `W --model` зелена и требует `RECOVERED`, `attempt="2"`, `rc="0"` при смерти уже после старта второго набора.

Проверка зависимости N от реально исполненной ветви: `python3 /tmp/dev-harness-verify/Critic995c/setup_variants.py` в копии boot-ok меняет только `source.json.kejsy.inkarnacija-smert-svip.scena.boot[1]` с `pozdno` на `ok`; `W --model` там rc=0 и сырое `SVIP k= 1 adb -s emulator-5560 wait-for-device                       ok`, `SVIP k= 2 adb -s emulator-5560 shell getprop sys.boot_completed      ok`, `SVIP k= 3 adb -s emulator-5560 shell settings put global window_anim ok`, `SVIP itog: N=18, krasnykh 0`, `CASE inkarnacija-smert-svip ok`. N не зашит в константу.

## G(iv): конечная граница диффа

`git diff --stat 814a71169388b3970dae0c0f0caf3694abb4c9f9..HEAD` → 4 файла: контракт (20 +/−), модель S (16 +/−, комментарии + одна выполняемая строка), `probe.py` (+207/−0) и `source.json` (+93/−1); `git diff --check` rc=0. `python3 /tmp/dev-harness-verify/Critic995c/contract_delta.py` → изменения строк 43,47,49–51,54–55,206,220–222,235,255, только E1–E6; зоны/пересечения и E7 не тронуты. `python3 /tmp/dev-harness-verify/Critic995c/check_delta.py` → `OLD CASES unchanged= 29`, `OLD STABS unchanged= 24` и у 25-го ровно третья привязка к свипу; 2 новых стаба, 1 кейс; неизменны P и два носителя; исполняемая дельта модели ровно `+    zhiv_svoyo || return 1` первой строкой тела цикла настроек. Пин фактических байтов модели S = `d8841d6b6fa4528e664668343db493401f58f9d559577444c4fe7db9bf8b3fdb`, равен `source.json` и контракту; P `9a556b48…` неизменен. Изменения `probe.py` ограничены трассой `vyzovy`, смертью k после эффекта, `boot=pozdno`, с-свип и двумя контрмоделями; сравнение всех 29 прежних JSON-клеток включает и все их `zapisi`/ожидания. Коммит `git log -1 --format=%B | python3 /tmp/dev-harness-verify/Critic995c/check_owner.py` → `OWNER EXACT COUNT 1 OWNER PREFIX COUNT 1`, дословная строка владельца из задания. `git diff --name-status` → только `contracts/995-cmp-mob-001-android-pilot.md` и три файла `fixtures/workshop_project/pilot_995/restart/`, ровно зона architect.

БЛОКИРУЕТ: нет.
СОВЕТ: нет (остатки TOCTOU / первая инкарнация / чужой порт при живом PID / подгонка / шум precision прямо выведены арбитром за пределы этого суда).
