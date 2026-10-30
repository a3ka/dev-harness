FAIL

ОБЪЕКТ: `77cd91ddcf333c139a7f5bb48a800b234b5e131a` (`architect`), родитель `03088a85a69063eab53b2a9b1c71d985f8d22d78`. Дополнительный строго scoped-суд Fix147e по решению консультанта 30.10; роль critic, сессия Crit147c, фактическая модель `openai-codex/gpt-6-sol`. Предыдущий вердикт: `verdicts/critic/contracts-147-v2.md` (FAIL).

БЛОКИРУЕТ contracts/147-gespraech-vhod-menu.md:63 — критерий сценария 7 не доказывает обязательный **запуск** второго AVD профиля 393 до приёмки. Класс причины: ложная достаточность `W --repo` для И-8. `_sudi_vtoroj_profil` требует буквальные `PORT393=5573`, `SERIAL="$SERIAL393"` и ранний `export GESPRAECH_SERIAL_393`, но не требует вызова `boot` после переключения на профиль 393. Достижимое состояние: настоящий продукт 6240f630 + канон 11/машина/пачка/полная карта и job по рецепту `--a-derevo`, из экранного шага которого удалена **только** строка `if ! boot; then diag; exit 1; fi` непосредственно после `AVD="$AVD393"; PORT="$PORT393"; SERIAL="$SERIAL393"`. Первый `boot` и резервный `boot` сохранены, однако оба выполняются с исходным профилем 390/портом 5572: до первого `boot` ещё не переключено, до резервного уже восстановлены `AVD_GL/PORT_GL/SERIAL_GL`. Экспорт второго serial есть, реального второго эмулятора нет. Мутация синтаксически правильна (`bash -n` rc 0), остальные обязанности сохранены.
ОБХОД: `python3 /tmp/dev-harness-verify/Crit147c-boot-attack.py` → `W --repo /tmp/dev-harness-verify/Crit147c-mut-no-second-boot` **rc 0**, `CASE s-lekalo-instanciirovano ok`, **71/71**; второй эмулятор ни разу не запускается, приёмка профиля 393 не может выполниться. Закрывающее свойство: этот же однострочный мутант красен поимённо `LEKALO_BEZ_VTOROGO_PROFILJA`, а честное A-дерево сохраняет 71/71; новый красный тест до заморозки (не только проверка наличия строки экспорта).

АРБИТР: `gpt-5.6-terra` через консультанта (решение о маршруте 30.10). Спор: достаточность статической проверки настоящего второго AVD И-8 после повторного FAIL того же класса; предыдущие два обхода теперь пойманы, но однострочное удаление фактического запуска снова принимается зелёным. Суд не предлагает править контракт/реализацию сам и не выдаёт accept.

### Сырой вывод scoped-атак

`W` = `bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh`; команда `python3 /tmp/dev-harness-verify/Crit147c-attack.py` запускает `W --repo` для каждого независимого мутанта из A-дерева, на батарее старого клона HEAD `03088a85` и нового клона HEAD `77cd91dd`; вывод ниже — непосредственный stdout команды (из 71 CASE показана изменяемая клетка и итог; неизменные CASE сохранены в `/tmp/dev-harness-verify/Crit147c-*.log`):
```
bez-vtorogo-avd-before rc=0 battery=Crit147c-before target=/tmp/dev-harness-verify/Crit147c-mut-bez-vtorogo-avd
CASE s-lekalo-instanciirovano ok
клеток 71, зелёных 71, красных 0; режим repo seed 147
bez-vtorogo-avd-after rc=1 battery=Crit147c target=/tmp/dev-harness-verify/Crit147c-mut-bez-vtorogo-avd
CASE s-lekalo-instanciirovano KRASNO LEKALO_BEZ_VTOROGO_PROFILJA: экранный шаг без boot второго AVD 393 (SERIAL="$SERIAL393"); GESPRAECH_SERIAL_393 не экспортирована экраным шагом (канон e2e.sh ждёт её)
клеток 71, зелёных 70, красных 1; режим repo seed 147
puti-pusto-before rc=0 battery=Crit147c-before target=/tmp/dev-harness-verify/Crit147c-mut-puti-pusto
CASE s-lekalo-instanciirovano ok
клеток 71, зелёных 71, красных 0; режим repo seed 147
puti-pusto-after rc=1 battery=Crit147c target=/tmp/dev-harness-verify/Crit147c-mut-puti-pusto
CASE s-lekalo-instanciirovano KRASNO LEKALO_BEZ_PUTEJ_KARTY: puti записи пусты (выбор экранной задачи не обеспечен)
клеток 71, зелёных 70, красных 1; режим repo seed 147
serial-bez-potreblenija-after rc=1 battery=Crit147c target=/tmp/dev-harness-verify/Crit147c-mut-serial-bez-potreblenija
CASE s-lekalo-instanciirovano KRASNO LEKALO_BEZ_VTOROGO_PROFILJA: GESPRAECH_SERIAL_393 не потребляется экраным шагом (export после вызова приёмки run_priemka)
клеток 71, зелёных 70, красных 1; режим repo seed 147
SCOPED_ATTACKS_PASS 2-before 3-after
```

`python3 /tmp/dev-harness-verify/Crit147c-propusknik.py` — изолированная копия зоны, функция `sud_lekalo` заменена на `return True, ''`, `W --stabs`:
```
PROPOSKNIK rc=1 cmd=bash /tmp/dev-harness-verify/Crit147c-propusknik/fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --stabs
STAB morph-linejnyj KRASEN znak-morf-250
STAB porjadok-obratnyj KRASEN sprechen-pervym
STAB poslednjaja-310 KRASEN menja-k-300
STAB presslong-ranjshe KRASEN press-long-500
STAB shag-ne-tot KRASEN plan-open-t28
STAB ud-ignor KRASEN ud-bez-poljota
STAB zakrytie-bez-morfa KRASEN plan-close-t31
STAB lekalo-obhod-kritika ZHIV (клетка зелена на обходе критика: ekran.json={} без проводки)
```

`python3 /tmp/dev-harness-verify/Crit147c-boot-attack.py`: семантический diff YAML — только удаление второго вызова `boot`; первый запуск и запасной запуск прежнего AVD остаются, `bash -n` rc 0. Сырой вывод атаки:
```
NO_SECOND_BOOT rc=0 cmd=bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --repo /tmp/dev-harness-verify/Crit147c-mut-no-second-boot
CASE s-lekalo-instanciirovano ok
клеток 71, зелёных 71, красных 0; режим repo seed 147
```
Первая попытка запуска этой дополнительной атаки остановилась **до батареи** на ошибочном ожидании скрипта судьи о числе оставшихся `if ! boot` (их две: первый и retry), `AssertionError` rc 1; исправлено ожидание, второй запуск выше выполнил батарею. Контракт и probe при атаке не менялись.

### Зелёный контроль, границы и регресс

`gh repo clone a3ka/Complior-mob /tmp/dev-harness-verify/Crit147c-product` → checkout продуктового `6240f6306c55213fdcb4c508b480eefbb75d2c62`; `W --a-derevo /tmp/dev-harness-verify/Crit147c-product /tmp/dev-harness-verify/Crit147c-green` напечатала `A-DEREVO ... job=e2e-gespraech-vhod kanon=11 mashina=1 ekran.json=forma`, rc 0. `W --repo /tmp/dev-harness-verify/Crit147c-green` — rc 0, `клеток 71, зелёных 71, красных 0; режим repo seed 147`. `W --model` и `W --model --seed 7/999` — каждый rc 0 71/71; `W --stabs` — rc 0 71/71, `SVJAZI 8`, все восемь `STAB ... KRASEN`; `cd /tmp/dev-harness-verify/Crit147c-green/mobile && npm test -- gespraech` — rc 0, `Test Suites: 1 passed, 1 total`, `Tests: 7 passed, 7 total` (node_modules — из существующего продуктового окружения).

Регресс на HEAD нового клона, каждую команду `bash fixtures/workshop_project/<пачка>/red_<пачка>.sh --stabs`: 132 `ekran_shablon_132` rc 0 `SVJAZI 65`; 118 `erstinformation_118` rc 0 `SVJAZI 73`; 135 `first_run_ekran_135` rc 0 `SVJAZI 13`; 138 `start_ekran_138` rc 0 `SVJAZI 53`. Коммит кандидата отличается от родителя ровно тремя путями зоны architect: `contracts/147-gespraech-vhod-menu.md`, `fixtures/workshop_project/gespraech_vhod_147/{probe.py,osi.md}`. Сценарий 7, раздел «Модель угроз» и «Живые измерения» согласованы относительно двух прежних обходов и трёх предписанных мутантов, но новый bypass делает утверждение об обязательном втором запущенном AVD недоказанным.
