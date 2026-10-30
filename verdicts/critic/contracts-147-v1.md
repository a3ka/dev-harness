accept

ОБЪЕКТ: `3a10c03699d2f6f53c5c09796328b18971424cdb` (`architect`; parent `77cd91ddcf333c139a7f5bb48a800b234b5e131a`). Судья: critic Crit147d, модель-факт `openai-codex/gpt-6-sol`, независима от автора. По решению консультанта 30.10 ~19:35 — **один scoped-суд только клетки запуска AVD-393 и зависимого регресса** (m399). Предыдущий scoped-вердикт: `verdicts/critic/contracts-147-v3-scoped-fail.md`. Это accept кандидату, **не подтверждение уже выполненного диагностического PR и не разрешение обойти блок заморозки**.

СОВЕТ contracts/147-gespraech-vhod-menu.md:63 — остаток того же класса «статическая форма ≠ исполнение»: после переключения на 393 вставка `boot() { :; }` непосредственно перед существующим `if ! boot; then diag; exit 1; fi` оставляет `W --repo` зелёным (71/71), но делает второй вызов boot пустым. Отдельного FAIL/нового круга по этой оси нет: маршрут Arb143r п.5, текст контракта `:147`, `:177` уже ограничивает клетку статикой и требует живые кадры 393 обеих тем с **run id + путём артефакта** диаг-PR до freeze; ревьюер должен отказать при отсутствии кадров. Снимок станции — только доказательство живого устройства, **не** успешного CI продуктового job. Подмена тела `boot` попадает в названный остаток; иного нового обхода в пределах scoped-атаки не предъявлено.

### Сырой вывод атак (выполнено мной)

Команда: `python3 /tmp/dev-harness-verify/Crit147d-attack.py`. Она копирует A-дерево в изолированное дерево, для каждого случая восстанавливает YAML и карту из зелёного контроля, делает ровно указанную мутацию и выполняет `bash -n` экранного шага, затем `bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --repo /tmp/dev-harness-verify/Crit147d-mutant` на указанном клоне. Строки CASE/итога ниже — дословный stdout батареи; полный вывод каждого вызова сохранён вне клона в `/tmp/dev-harness-verify/Crit147d-*.log`.

```
before-no-boot: rc=0 candidate=Crit147d-before bash-n=0
CASE s-lekalo-instanciirovano ok
клеток 71, зелёных 71, красных 0; режим repo seed 147
after-no-boot: rc=1 candidate=Crit147d bash-n=0
CASE s-lekalo-instanciirovano KRASNO LEKALO_BEZ_ZAPUSKA_393: запуск AVD 393 отсутствует: между переключением SERIAL="$SERIAL393" и возвратом serial-390/run_priemka нет вызова boot
клеток 71, зелёных 70, красных 1; режим repo seed 147
after-step-if: rc=1 candidate=Crit147d bash-n=0
CASE s-lekalo-instanciirovano KRASNO LEKALO_BEZ_ZAPUSKA_393: экранный шаг под условием if: '${{ false }}' — запуск 393 может быть пропущен целиком
клеток 71, зелёных 70, красных 1; режим repo seed 147
after-or-true: rc=1 candidate=Crit147d bash-n=0
CASE s-lekalo-instanciirovano KRASNO LEKALO_BEZ_ZAPUSKA_393: запуск AVD 393 размаскирован: отказ проглочен (|| true): 'boot || true'
клеток 71, зелёных 70, красных 1; режим repo seed 147
after-no-create: rc=1 candidate=Crit147d bash-n=0
CASE s-lekalo-instanciirovano KRASNO LEKALO_BEZ_ZAPUSKA_393: AVD 393 не создаётся (нет create avd -n "$AVD393") — запуск мёрт: emulator -avd "$AVD393" без AVD
клеток 71, зелёных 70, красных 1; режим repo seed 147
after-guard: rc=1 candidate=Crit147d bash-n=0
CASE s-lekalo-instanciirovano KRASNO LEKALO_BEZ_ZAPUSKA_393: запуск AVD 393 размаскирован: запуск под условной guard ('if false; then' перед ним): 'if ! boot; then diag; exit 1; fi'
клеток 71, зелёных 70, красных 1; режим repo seed 147
after-no-paths: rc=1 candidate=Crit147d bash-n=0
CASE s-lekalo-instanciirovano KRASNO LEKALO_BEZ_PUTEJ_KARTY: puti записи пусты (выбор экранной задачи не обеспечен)
клеток 71, зелёных 70, красных 1; режим repo seed 147
after-no-second-profile: rc=1 candidate=Crit147d bash-n=0
CASE s-lekalo-instanciirovano KRASNO LEKALO_BEZ_VTOROGO_PROFILJA: экранный шаг без PORT393=5573 (порт второго AVD 393)
клеток 71, зелёных 70, красных 1; режим repo seed 147
SCOPED_MATRIX 7/7 plus before red proof
```

Команда `python3 /tmp/dev-harness-verify/Crit147d-propusknik.py` (копия workshop_project + scripts; подмена `sud_lekalo` на `return True, ''`, затем `W --stabs`) дала:
```
PROPOSKNIK rc=1
STAB morph-linejnyj KRASEN znak-morf-250
STAB porjadok-obratnyj KRASEN sprechen-pervym
STAB poslednjaja-310 KRASEN menja-k-300
STAB presslong-ranjshe KRASEN press-long-500
STAB shag-ne-tot KRASEN plan-open-t28
STAB ud-ignor KRASEN ud-bez-poljota
STAB zakrytie-bez-morfa KRASEN plan-close-t31
STAB lekalo-bez-zapuska-393 ZHIV (клетка s-lekalo-instanciirovano зелена на стабе)
```
Первая попытка этого пропускника была неполной копией: остановилась ДО батареи с `FileNotFoundError: .../fixtures/workshop_project/ekran_shablon_132/model/fiktura/pachta_chuzhogo/ekran.json` (rc 1); исправлена копией всей `fixtures/workshop_project/`, успешное доказательство выше.

Команда `python3 /tmp/dev-harness-verify/Crit147d-residual.py` (новый same-class обход в собственной копии A-дерева):
```
INERT_BOOT rc=0 bash-n=0
CASE s-lekalo-instanciirovano ok
клеток 71, зелёных 71, красных 0; режим repo seed 147
```

### Зелёное и регресс

`W --a-derevo /tmp/dev-harness-verify/Crit147c-product /tmp/dev-harness-verify/Crit147d-green` rc 0: `A-DEREVO /tmp/dev-harness-verify/Crit147d-green job=e2e-gespraech-vhod kanon=11 mashina=1 ekran.json=forma`; продукт-основа на `6240f6306c55213fdcb4c508b480eefbb75d2c62`. `W --repo /tmp/dev-harness-verify/Crit147d-green` rc 0, `CASE s-lekalo-instanciirovano ok`, `клеток 71, зелёных 71, красных 0; режим repo seed 147`. `W --model` seeds 147/7/999: каждый rc 0, 71/71. `W --stabs`: rc 0, `STAB lekalo-bez-zapuska-393 KRASEN LEKALO_BEZ_ZAPUSKA_393`, `STAB lekalo-obhod-kritika KRASEN LEKALO_NE_INSTANCIIROVANO`, `SVJAZI 9`, 71/71; живых стабов 0. `npm test -- gespraech` в существующем продуктовом дереве `/tmp/dev-harness-verify/Crit147c-green/mobile` rc 0: `Test Suites: 1 passed, 1 total`, `Tests: 7 passed, 7 total`. Соседи `W --stabs`: 132 rc 0 SVJAZI 65; 118 rc 0 SVJAZI 73; 135 rc 0 SVJAZI 13; 138 rc 0 SVJAZI 53.

Живой кадр станции существует: `/tmp/dev-harness-verify/Arch147f-work/zhivoj-393/kadry/zhivoj-393.png`, `file` → PNG RGBA **1180 × 2556**, `sha256sum` → `f733dc1fe9a666fe865cd8c0670deb5380269947362e5eb4f48dafffed71ef59`. Диаг-PR обеих тем с run id и артефактом обязателен до freeze по строке `contracts/147-gespraech-vhod-menu.md:147`; пока нет доказательства выполнения, заморозка остаётся заблокирована независимо от этого accept. Дельта OBJECT — ровно пять путей под ЗОНА architect (`contracts/147-gespraech-vhod-menu.md`, `fixtures/workshop_project/gespraech_vhod_147/{probe.py,osi.md,source.json,stabs/stab_lekalo_bez_zapuska_393.py}`); `bash scripts/check_zones.sh /tmp/dev-harness-verify/Crit147d` rc 0 (FAIL 0).
