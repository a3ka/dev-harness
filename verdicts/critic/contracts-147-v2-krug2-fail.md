FAIL

ОБЪЕКТ: `03088a85a69063eab53b2a9b1c71d985f8d22d78` (`architect`; судим файл на этом коммите, не черновик). Суд 2/2, critic-sol, фактическая модель `openai-codex/gpt-6-sol`. СУД: repo=dev-harness; предмет=147; фаза=контракт; роль=critic-sol; вызов=2/2; модель-план=openai-codex/gpt-6-sol; сессия=Crit147b; модель-факт=openai-codex/gpt-6-sol; SHA=03088a85a69063eab53b2a9b1c71d985f8d22d78; предыдущий=verdicts/critic/contracts-147-v1-krug1-fail.md; исключение=нет.

БЛОКИРУЕТ contracts/147-gespraech-vhod-menu.md:53 — критерий `W --repo R` (строки 61, 63) принимает экранный job без обязательного второго AVD профиля 393 на порту 5573. Причина: новая клетка `s-lekalo-instanciirovano` сверяет `FLOWS_PACHKI` с двумя путями, `PORT=5572` и подстроку валидатора, но не требует второго запуска AVD и экспорта `GESPRAECH_SERIAL_393`. Это допустимое дерево с настоящей картой, полным job, всеми канон-файлами и непустой пачкой; статика 143 не становится действительной приёмкой профиля 393 от одного перечисления флоу. Исполняемый `mobile/e2e-gespraech-vhod/e2e.sh` проверяет `${GESPRAECH_SERIAL_393:?}` до прогона, без экспорта шаг не способен завершить И-7/И-8.
ОБХОД: от зелёного A-дерева удалить ТОЛЬКО участок экранного шага между `# второй AVD профиля 393` и восстановлением `AVD="$AVD_GL"; PORT="$PORT_GL"; SERIAL="$SERIAL_GL"` включительно. Первый AVD, валидатор, два пути FLOWS, пиннованные шаги, карта, output, оба needs остаются. Клетка `ok`, вся батарея **rc 0 71/71**, хотя второго boot/export нет и e2e 393 откажет до Maestro. Закрывающее свойство: та же допустимая мутация даёт поимённый красный `W --repo`, честное A-дерево остаётся 71/71; новый красный тест до заморозки.

БЛОКИРУЕТ contracts/147-gespraech-vhod-menu.md:78 — новая клетка не требует `puti` своей записи карты, хотя здесь прямо названы три пути и строка 63 требует запись карты как ПАРНУЮ правку job. Причина: `sud_lekalo` проверяет job/id/flows/child_flows/h_checkout/output_namespace, но пропускает `puti` целиком. В 143/2 `select-screens` выбирает экран по путям записи; такая карта может не запустить экранный job при изменении любого файла экрана.
ОБХОД: в зелёном A-дереве заменить только `puti` записи `e2e-gespraech-vhod` на `[]`, сохранить job/flows/needs/output/пачку. `W --repo` возвращает **rc 0 71/71**, `s-lekalo-instanciirovano ok`; изменение самого продукта не приводит к выбору экрана по его путям. Закрывающее свойство: красная клетка на пустой/неполной тройке путей карты, при зелёной исходной записи.

АРБИТР: terra, через консультанта. Предмет инженерного спора — достаточность критерия И-8 после повторного FAIL по классу ложной достаточности `W --repo`: отсутствие проводки исправлено, но неработающая/невыбираемая проводка принимается зелёной. Бюджет 2/2 исчерпан; арбитр не даёт третьего вызова или accept, вопрос дополнительного вызова — владельцу.

### Воспроизведение (изолированные клоны, сырой вывод команд)

`W` = `bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh` в `/tmp/dev-harness-verify/Crit147b`. `W --a-derevo /tmp/dev-harness-verify/Crit147b-product /tmp/dev-harness-verify/Crit147b-green` → `A-DEREVO /tmp/dev-harness-verify/Crit147b-green job=e2e-gespraech-vhod kanon=11 mashina=1 ekran.json=forma`, rc 0. Атакующие скрипты работают с отдельными копиями этого A-дерева и печатают сырой stdout собственного запуска (строку изменившейся клетки и итог; 70 неизменённых CASE не дублируются).

**Обход круга 1:** `python3 /tmp/dev-harness-verify/Crit147b-attacks.py obhod` запускает `W --repo` на одном продукте с `ekran.json={}` и без карты/job/output/needs, сначала с батареей HEAD `df570cac` другого клона, затем с батареей OBJECT:
```
ATTACK obhod before rc=0 command=bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --repo /tmp/dev-harness-verify/Crit147b-mut-obhod
клеток 70, зелёных 70, красных 0; режим repo seed 147
ATTACK obhod after rc=1 command=bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --repo /tmp/dev-harness-verify/Crit147b-mut-obhod
CASE s-lekalo-instanciirovano KRASNO LEKALO_NE_INSTANCIIROVANO: нет записи карты с job e2e-gespraech-vhod; ekran.json пачки пуст (обход Crit147: {}); нет job e2e-gespraech-vhod в mobile.yml; output выбора e2e-gespraech-vhod отсутствует/не из шага vybor; needs агрегата android-e2e без e2e-gespraech-vhod; needs агрегата mobile-regression-signal без e2e-gespraech-vhod
клеток 71, зелёных 70, красных 1; режим repo seed 147
```

**Четыре частичных мутанта:** команда для каждого — `python3 /tmp/dev-harness-verify/Crit147b-attacks.py <имя>`; raw stdout (rc проверки — внутри строки):
```
ATTACK karta-bez-joba after rc=1 command=bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --repo /tmp/dev-harness-verify/Crit147b-mut-karta-bez-joba
CASE s-lekalo-instanciirovano KRASNO LEKALO_NE_INSTANCIIROVANO: нет записи карты с job e2e-gespraech-vhod
клеток 71, зелёных 70, красных 1; режим repo seed 147
ATTACK bez-vyhoda after rc=1 command=bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --repo /tmp/dev-harness-verify/Crit147b-mut-bez-vyhoda
CASE s-lekalo-instanciirovano KRASNO LEKALO_NE_INSTANCIIROVANO: output выбора e2e-gespraech-vhod отсутствует/не из шага vybor
клеток 71, зелёных 70, красных 1; режим repo seed 147
ATTACK bez-needs-android-e2e after rc=1 command=bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --repo /tmp/dev-harness-verify/Crit147b-mut-bez-needs-android-e2e
CASE s-lekalo-instanciirovano KRASNO LEKALO_NE_INSTANCIIROVANO: needs агрегата android-e2e без e2e-gespraech-vhod
клеток 71, зелёных 70, красных 1; режим repo seed 147
ATTACK lichnyj-mv2 after rc=1 command=bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --repo /tmp/dev-harness-verify/Crit147b-mut-lichnyj-mv2
CASE s-lekalo-instanciirovano KRASNO LEKALO_NE_INSTANCIIROVANO: персональный mv пачки (вынос — общий шаг)
клеток 71, зелёных 70, красных 1; режим repo seed 147
```

**Пропускник:** `python3 /tmp/dev-harness-verify/Crit147b-propusknik.py` в отдельном клоне меняет только итог `sud_lekalo` на `return True, ''`, затем запускает `W --stabs`; raw stdout:
```
ATTACK propusknik rc=1 command=bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --stabs
STAB morph-linejnyj KRASEN znak-morf-250
STAB porjadok-obratnyj KRASEN sprechen-pervym
STAB poslednjaja-310 KRASEN menja-k-300
STAB presslong-ranjshe KRASEN press-long-500
STAB shag-ne-tot KRASEN plan-open-t28
STAB ud-ignor KRASEN ud-bez-poljota
STAB zakrytie-bez-morfa KRASEN plan-close-t31
STAB lekalo-obhod-kritika ZHIV (клетка зелена на обходе критика: ekran.json={} без проводки)
```

**Новые обходы** (каждый мутирует только один носитель; `diff -qr` сравнил зелёное и первый мутант — отличается лишь `.github/workflows/mobile.yml`):
```
$ python3 /tmp/dev-harness-verify/Crit147b-screen-bypass.py
ATTACK bez-vtorogo-avd rc=0 command=bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --repo /tmp/dev-harness-verify/Crit147b-mut-single-avd2
CASE s-lekalo-instanciirovano ok 
клеток 71, зелёных 71, красных 0; режим repo seed 147
$ env -u GESPRAECH_SERIAL_393 GESPRAECH_SERIAL=emulator-5572 bash mobile/e2e-gespraech-vhod/e2e.sh gespraech-vhod
mobile/e2e-gespraech-vhod/e2e.sh: line 17: GESPRAECH_SERIAL_393: GESPRAECH_SERIAL_393: эмулятор 393 с вырезом
[rc=1]
$ python3 /tmp/dev-harness-verify/Crit147b-missing-paths.py
ATTACK bez-putej rc=0 command=bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --repo /tmp/dev-harness-verify/Crit147b-mut-no-paths
CASE s-lekalo-instanciirovano ok 
клеток 71, зелёных 71, красных 0; режим repo seed 147
```

**Контроль авторских стабов:** `python3 /tmp/dev-harness-verify/Crit147b-stabs-summary.py` вызывает неизменённый `W --stabs`, печатает сырой отфильтрованный stdout без 71 неизменённой CASE-строки:
```
STABS rc=0 command=bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --stabs
STAB morph-linejnyj KRASEN znak-morf-250
STAB porjadok-obratnyj KRASEN sprechen-pervym
STAB poslednjaja-310 KRASEN menja-k-300
STAB presslong-ranjshe KRASEN press-long-500
STAB shag-ne-tot KRASEN plan-open-t28
STAB ud-ignor KRASEN ud-bez-poljota
STAB zakrytie-bez-morfa KRASEN plan-close-t31
STAB lekalo-obhod-kritika KRASEN s-lekalo-instanciirovano
SVJAZI 8
клеток 71, зелёных 71, красных 0; режим stabs seed 147
```

Остальной зелёный контроль: `W --repo /tmp/dev-harness-verify/Crit147b-green` rc 0 71/71; `W --model` и `--seed 7`/`999` по rc 0 71/71; `W --stabs --seed 7` rc 0 `SVJAZI 8`; `W --oracle-tamper` rc 0 `ORACLE_TAMPER_PROVERENO nositelej=58`. `npm test -- gespraech` в продукте с каноном rc 0: `Test Suites: 1 passed, 1 total`, `Tests: 7 passed, 7 total`. Безфлаговый `W` rc 1: `клеток 71, зелёных 4, красных 67; режим koren seed 147`. Регресс соседей `--stabs`: 132-live rc 0 `SVJAZI 65`, 118 rc 0 `SVJAZI 73`, 135 rc 0 `SVJAZI 13`, 138 rc 0 `SVJAZI 53`.

Провенанс: дельта `03088a85^..03088a85` — ровно девять файлов: контракт и восемь путей `fixtures/workshop_project/gespraech_vhod_147/`, зона architect (:69–70). SHA256 лекала `3675182e218c467f694dc69d4ee3457900849e6717b7a80d12e8bafc80aa14dd` совпал с frozen 143/2; модель `5fd1415e40b257e5e7b97c7bf9bc8fe31e94dcea9e05c4c3ac44d68802db453b` — с origin/main; носители mobile.yml/ci-screens.json совпали с HEAD продукта `6240f6306c55213fdcb4c508b480eefbb75d2c62` (`6137aa57…`, `85c23e1c…`). `check_precision_gate.sh`, `check_spec_ready.sh`, `check_ceilings.sh`, `check_threat_model.sh`, `check_predposylki.sh`, `pre_critic.sh`: каждый rc 0. `check_zones.sh`: после первого таймаута среды 120 с повтор `python3 /tmp/dev-harness-verify/Crit147b-zone.py` с 600-секундным пределом **rc 0**, последний сырой вывод: `замороженных контрактов: 143 · объявленных авторов: 5 · коммитов в диапазонах: 38098 · проверено по зонам: 8668`.
