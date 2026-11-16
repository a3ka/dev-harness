accept
OBJECT=20f19ec3e9b6dfffb040267b6fc1917b66a3f2d2
КЛАСС=кодовый; КЛАСС РИСКА=обычный
СУД: repo=dev-harness; предмет=147; фаза=контракт v5; роль=critic; вызов=3/3; модель-план=zai/glm-5.3; сессия=Crit147v5c; модель-факт=zai/glm-5.3 (trace: role=critic model=zai/glm-5.3 fallback=allowed); SHA=20f19ec3e9b6dfffb040267b6fc1917b66a3f2d2; предыдущий=verdicts/critic/contracts-147-v5-vyzov2-fail.md; исключение=нет

## Решение

Б-1 вызова 2 закрыт по свойству. Контракт `contracts/147-gespraech-vhod-menu.md:72,83` требует единственную замкнутую YAML-модель работника, поимённые агрегаты и сравнение shell-обёртки разобранными словами; `:105` фиксирует именно этот класс закрытия. На независимой честной сборке из mob main `0814d2f5a8980e6e8331f06b8e22911e5f57eade`, живого работника 149 и десятифайловой пачки команда `python3 fixtures/workshop_project/gespraech_vhod_147/red_ci_147.py --repo /tmp/dev-harness-verify/Crit147v5c/honest` дала `REGISTRACIJA_OK` (rc 0). На живом mob main она дала rc 1: `PRICHINA PACHKA_NEPOLNAJA: нет каталога mobile/e2e-gespraech-vhod`.

`--model` дал `MODEL_OK` (rc 0), `--stabs` дал rc 0: `MODEL_OK`, затем 38/38 красных стабов с их ветвями. Первые 13 стабов предыдущего вызова совпадают по AST побайтно (`STABY_AST_1_13_IDENTICAL=True`; old=13, new=38). В частности, прежние MA-1b/MA-2/MA-2b сохранили соответственно `RABOTNIK_BEZ_VYBORA`, `RABOTNIK_BEZ_VALIDATORA`, `RABOTNIK_BEZ_KADROV`; m6/m6b/m7/m6c, m8/m9/m10, дубли ключа/job, YAML-алиас, timeout, strategy и перестановка шага красны. PyYAML — несомая предпосылка раннера: `registry/ci-steps.tsv:138-139` объявляет 143-family с `python3-pyyaml`.

Дельта `3ab61f29f1af40c87e870f855af16742e7a6d513..OBJECT` содержит только контракт, SPEC и `red_ci_147.py` (+450/−99); `karta.json` не затронут. Модель 999 сохраняет `shell-profile-entry` только в start, что согласуется с 999 v+1 в HANDOFF и контрактом 147. Снятия норм ограничены вариантом А владельца; И-1..И-10, набор 158, Б-4-пины и unit-приёмка не сняты.

В опубликованном origin доступны frozen-теги 147/1–147/3; `/4` и объект `d3bc6094` отсутствуют, поэтому заданный diff от `/4` не исполним в обязательном чистом клоне. Это не является ложным зелёным критерия 4: текущая дельта от предыдущего OBJECT полностью предъявлена выше, а контракт удалил неподтверждаемое утверждение о публикации `/4` и не опирается на него как на доказательство закрытия Б-1.

## Сырые мутации критика

Команда каждой строки: `python3 fixtures/workshop_project/gespraech_vhod_147/red_ci_147.py --repo <одноразовая копия честной сборки>`. Якорь у каждого изменения был ограничен job `e2e-gespraech-vhod`; после изменения PyYAML разобрал именно названный job/шаг (снимок `PYYAML=` для каждого случая сохранён в запуске).

- `m6_if_false_validator`: rc=1; `PRICHINA UPRAVLYAYUSHCHIJ_KLYUCH: валидатор [5]: ключи/значения вне честной модели`.
- `m6b_if_false_artifact`: rc=1; `PRICHINA UPRAVLYAYUSHCHIJ_KLYUCH: артефакт кадров [6]: ключи/значения вне честной модели`.
- `m7_if_false_job`: rc=1; `PRICHINA UPRAVLYAYUSHCHIJ_KLYUCH: job e2e-gespraech-vhod: ключи/значения вне честной модели`.
- `m6c_continue_on_error_job`: rc=1; `PRICHINA UPRAVLYAYUSHCHIJ_KLYUCH: job e2e-gespraech-vhod: ключи/значения вне честной модели`.
- `run_if_false_then`: rc=1; `PRICHINA UPRAVLYAYUSHCHIJ_KLYUCH: валидатор [5]: shell-обёртка вне честной модели`.
- `run_or_true`: rc=1; `PRICHINA RABOTNIK_BEZ_VALIDATORA: команды-вызова ekran_shablon.py --pack 'mobile/e2e-gespraech-vhod/' своими shell-словами нет`.
- `run_semicolon_true`: rc=1; `PRICHINA RABOTNIK_BEZ_VALIDATORA: команды-вызова ekran_shablon.py --pack 'mobile/e2e-gespraech-vhod/' своими shell-словами нет`.
- `run_set_plus_e`: rc=1; `PRICHINA UPRAVLYAYUSHCHIJ_KLYUCH: валидатор [5]: shell-обёртка вне честной модели`.
- `working_directory_other`: rc=1; `PRICHINA UPRAVLYAYUSHCHIJ_KLYUCH: валидатор [5]: ключи/значения вне честной модели`.
- `shell_other_interpreter`: rc=1; `PRICHINA UPRAVLYAYUSHCHIJ_KLYUCH: валидатор [5]: ключи/значения вне честной модели`.
- `env_validator_other`: rc=1; `PRICHINA UPRAVLYAYUSHCHIJ_KLYUCH: валидатор [5]: ключи/значения вне честной модели`.
- `uses_instead_of_run`: rc=1; `PRICHINA RABOTNIK_BEZ_VALIDATORA: команды-вызова ekran_shablon.py --pack 'mobile/e2e-gespraech-vhod/' своими shell-словами нет`.

Дополнительно матрица `--stabs` дала: m7 `${{ false }}`, `'false'`, `always() && false` и YAML-якорь; m6 на валидаторе и H-checkout; m6b на артефакте; m6c; `timeout-minutes: 0`; `strategy.fail-fast`; echo/heredoc/no-op-heredoc; m10 с двумя неагрегатами; перестановку; другой `needs`; дубль `if`; алиас `if`; дубль job; `continue-on-error` выражением на артефакте. Все 38 дали rc 1 с собственной первой наблюдаемой ветвью, а сама матрица — rc 0.

## Гейты

- `bash scripts/pre_critic.sh contracts/147-gespraech-vhod-menu.md` — rc 0 (`PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=5`; `ТРЕК ЛЁГКИЙ`; `КРИТИК: дверь зелёная`).
- `bash scripts/check_precision_gate.sh . contracts/147-gespraech-vhod-menu.md` — rc 0 (`OK`).
- `bash scripts/check_threat_model.sh . contracts/147-gespraech-vhod-menu.md` — rc 0 (`ЗАЩИЩАЕТ 10`, `НЕ ЗАЩИЩАЕТ 8`).
- `bash scripts/check_ceilings.sh .` — rc 0 (`потолки в порядке`).
- `bash scripts/check_spec_ready.sh . contracts/147-gespraech-vhod-menu.md` — rc 0 (`OK`).
- `bash scripts/check_provodka.sh . contracts/147-gespraech-vhod-menu.md` — rc 1: `guard не подключён: fixtures/workshop_project/gespraech_vhod_147/red_ci_147.py не вызывается в .githooks/ или .github/workflows/`; допустимое до done красное по норме 038 и явному окну проводки orchestrator.

## Карта классов

- К-01: чисто — шесть гейтов выше; проводка rc 1 допустима нормой 038.
- К-02: чисто — вариант А владельца и И-11 отражены в контракте/критерии/модели угроз.
- К-03: чисто — дельта ограничена тремя ожидаемыми файлами; сопряжение 999 сохранено.
- К-04: чисто — три изменённых файла в зоне architect; производных в дельте нет.
- К-05: чисто — критерий 4 имеет rc-команду и честный rc 0.
- К-06: чисто — живой mob без входа дал предметный rc 1, отсутствующий repo даёт rc 2 по батарее.
- К-07: чисто — независимая честная сборка зелена той же `--repo` командой.
- К-08: чисто — 38/38 стабов и 12 собственных мутаций закрывают удаление/отключение/замену операций.
- К-09: чисто — разобраны ветви YAML (дубли, алиасы, условие, keys/values) и shell-представления.
- К-10: чисто — echo, heredoc, uses, условное тело и подавление статуса не удовлетворяют клетку.
- К-11: чисто — `MODEL_YML` снимался до чтения субъекта; честная сборка независима от модели батареи.
- К-12: чисто — YAML судит стандартный PyYAML; формат пачки остаётся за валидатором 132 v3.
- К-13: н/п — секретных входов нет (`pre_critic`: secrets=0, variables=0, environments=0).
- К-14: чисто — честная форма зелена, а различающиеся формы красны; эквивалентные YAML значения сравниваются после разбора.
- К-15: чисто — 10 файлов, 38 стабов, 13 сохранённых и +450/−99 сверены.
- К-16: чисто — ровно одна строка класса риска проходит regex; обычный класс соответствует UI-моку.
- К-17: н/п — экранный контракт не вводит DRAFT-операции, модульную схему или writers/consumes; A1–A15 к нему не применяются.
