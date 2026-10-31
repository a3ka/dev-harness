FAIL
OBJECT=0445f80689e40fff8b6ba738cff0f70df9fe43ec
СУД: repo=dev-harness; предмет=150; фаза=контракт; роль=critic; вызов=3/2 (дополнительный scoped-вызов разрешён владельцем 2026-10-31 ~11:55 UTC); сессия=Crit150c; модель-факт=openai-codex/gpt-6-sol; SHA=0445f80689e40fff8b6ba738cff0f70df9fe43ec; предыдущий=verdicts/arbitration/contracts-150-arbitraz.md; исключение=да. Автор конструкции architect/GLM по предъявленным сведениям, критик Sol; независимость соблюдена. Закоммиченный OBJECT судился в изолированном клоне. Арбитраж уже состоялся; дальнейший бюджет после FAIL решает владелец.

БЛОКИРУЕТ contracts/150-prichinnyy-zamer-obryva.md:70 — П1: z05 считает фактически исполняемым `sbor` в правом операнде `||`, даже когда левый `true` и сбор НЕ вызывается. У второго работника карты `true || bash mobile/scripts/zamer_obryva.sh sbor ... --out mobile/zamer-out-$ZAMER_EKRAN` оставляет правильный `with.path`, но красный job второго не создаёт файл для upload с `if-no-files-found: ignore`. Все 17 клеток зелёные: b* проигрывают только первого штатного работника. Форма должна либо доказывать исполнение, либо краснеть именованно.
ОБХОД: `python3 /tmp/dev-harness-verify/Crit150c/attack_unreachable_second.py` — одноразовая копия model с двумя работниками карты, у второго ТОЛЬКО `true || ` перед штатной командой сбора. Сырой вывод:
```
SECOND_WORKER_COLLECTION: 'set -u\ntrue || bash mobile/scripts/zamer_obryva.sh sbor \\\n  --ekran "$ZAMER_EKRAN" --ns "$ZAMER_NS" --serial "$ZAMER_SERIAL" \\\n  --spool .zamer-$ZAMER_EKRAN --out mobile/zamer-out-$ZAMER_EKRAN\n'
ATTACK_RC 0
ATTACK_STDOUT
ZELENO: клеток 17, зелёных 17

ATTACK_STDERR

```
ОБЯЗАТЕЛЬСТВО: арбитраж П1, И-6 и критерий 5 требуют согласовать upload с `--out` реально исполняемой команды ПО КАЖДОМУ работнику, нераспознанную форму отвергать.
СОСТОЯНИЕ: два законных работника с полной обёрткой, сбор второго пропускается, шаг заканчивается rc 0.
НАБЛЮДЕНИЕ: `_shell_komandy` разбивает `||` на границу команд, z05 учитывает неисполняемый правый операнд; `bash -c 'true || { printf SHOULD_NOT_RUN; exit 4; }; printf COLLECTION_SKIPPED'` → `COLLECTION_SKIPPED`, rc 0. Контроль той же карты без мутации: `python3 /tmp/dev-harness-verify/Crit150c/control_two_workers.py` → `TWO_WORKERS_UNMUTATED_RC 0`, `ZELENO: клеток 17, зелёных 17`. Контроль исполняемого неверного `--out` второго, скрытого комментарием: `python3 /tmp/dev-harness-verify/Crit150c/control_wrong_out_second.py` → `SECOND_WORKER_WRONG_OUT_RC 1`, `KRASNO: клеток 17, красных 1`, `z05-put-zagruzki: e2e-proba-drugoj: PUT_ZAGRUZKI_RASHODITSJA: ispolnjaemyj --out 'mobile/zamer-out-NEVER' != with.path 'mobile/zamer-out-proba-drugoj' (upload gruzit pustotu)`.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: второй штатный работник проходит, второй с пропущенным сбором краснеет, даже при правильном текстовом `--out`.

БЛОКИРУЕТ contracts/150-prichinnyy-zamer-obryva.md:75 — П2: обязательные живые приёмки 7/8 невыполнимы. `zhivaja_priemka_150.sh:150-151` БЕЗУСЛОВНО определяет `gh()` поверх доступного `/usr/bin/gh` и читает `$Z150_MOK` под `set -u`; эта переменная задаётся лишь в `--samoproverka`. Любой живой red/green run даёт rc 1 ДО обращения к настоящему gh API, несмотря на 10/10 зелёных mock-проверок.
ОБЯЗАТЕЛЬСТВО: П2 и критерии 7/8 требуют живые команды, возвращающие 0 на положительных run и ненулевой rc по причине на отрицательных.
СОСТОЯНИЕ: штатный `ZP krasnyj <repo> <S> <R> <A> <C>` либо `ZP zelenyj <repo> <S> <R> <A>` без mock-переменной.
НАБЛЮДЕНИЕ: оба запуска ниже → `Z150_MOK: unbound variable`, `ZP_OTKAZ: GH_OTKAZ`, rc 1; настоящего вызова gh нет.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: живые режимы используют внешний gh, mock ограничен `--samoproverka`, положительные gh-ответы дают rc 0.

БЛОКИРУЕТ contracts/150-prichinnyy-zamer-obryva.md:76 — П2: пустая успешная выдача API артефактов засчитывается доказательством НУЛЯ запрещённых артефактов. `jq -es` принимает пустой поток как `[]`, а `length == 0` возвращает true; это нарушает явное `:73` «пустое успешное значение недопустимо» и остаётся дефектом после исправления функции `gh()`.
ОБХОД: в `/tmp/dev-harness-verify/Crit150c/empty-api/` mock-ответ jobs.json = completed/success job S, log.txt = `ne publikuetsja`, `artifacts.json` — 0 байт, выдаётся `cat` с rc 0. `env Z150_MOK=/tmp/dev-harness-verify/Crit150c/empty-api bash fixtures/workshop_project/obryv_zamer_150/zhivaja_priemka_150.sh zelenyj owner/repo S 123 1` → сырой stdout `ZP_ZELENYJ_OK: run=123 job=S jobid=111 artefaktov_zamer=0 marker=est`, rc 0; ни одной страницы списка API не было.
ОБЯЗАТЕЛЬСТВО: П2-4, критерии 7/8: отсутствие артефакта доказывается полным разобранным списком, пустой/неразобранный ответ не равен отсутствию.
СОСТОЯНИЕ: `gh api --paginate` rc 0 с 0 байт ответа; job и лог позитивны.
НАБЛЮДЕНИЕ: `jq -es '[.[].artifacts[]? | select((.name | type == "string") and (.name | startswith("zamer-S-")))] | length == 0' /tmp/dev-harness-verify/Crit150c/empty-api/artifacts.json` печатает `true`, rc 0, как и полная приёмка.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: принимать отсутствие артефакта лишь после хотя бы одной валидной полной JSON-страницы/ответа; 0 байт дают именованный отказ; настоящий пустой массив артефактов — успех.

БЛОКИРУЕТ contracts/150-prichinnyy-zamer-obryva.md:77 — П2-5: `ZP dlitelnosti <repo> <S> <R1> <R2>` всегда отказывает на правильных четырёх аргументах: после `shift` код требует `[ $# -eq 3 ]`, ниже обращается к `$4`. Две длительности не измеряются.
ОБЯЗАТЕЛЬСТВО: П2-5 и критерий 9 требуют исполняемый пункт наблюдения обеих длительностей, НЕ машинного доказательства их равенства.
СОСТОЯНИЕ: штатный вызов с двумя run id.
НАБЛЮДЕНИЕ: `bash fixtures/workshop_project/obryv_zamer_150/zhivaja_priemka_150.sh dlitelnosti owner/repo S 123 124` → rc 1, сырой вывод `ZP_OTKAZ: ARGUMENTY: dlitelnosti <repo> <S> <R1> <R2 — vsego 4>` до обращения к gh.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: четыре аргумента проходят диспетчер, пункт печатает данные ОБОИХ run; неверная арность краснеет.

П3: владелец принял суррогат смерти PID/дельты oom/журнала/NE_DOSTUPEN для 150; контракт признаёт zombie-окно `/proc/PID/stat` и числовой exit отдельным предметом. Это НЕ блокер. СОВЕТ contracts/150-prichinnyy-zamer-obryva.md:44 — комментарий пиннованного канона `model/mobile/scripts/zamer_obryva.sh:201-204` всё ещё говорит «физически недоступен вне родительской оболочки»: при будущей правке канона согласовать с уточнённой границей П3. Блоков класса «САМООПИСАНИЕ» нет: все четыре блока содержательные, стоячее разрешение владельца 31.10 ~18:10 о чистом самоописании к ним неприменимо.

Целевые команды и исходы (cwd `/tmp/dev-harness-verify/Crit150c/repo`):
```
bash fixtures/workshop_project/obryv_zamer_150/zhivaja_priemka_150.sh krasnyj owner/repo S 123 1 abc
fixtures/workshop_project/obryv_zamer_150/zhivaja_priemka_150.sh: line 151: Z150_MOK: unbound variable
ZP_OTKAZ: GH_OTKAZ: gh run view 123 (sm. stderr vishe)
rc=1
bash fixtures/workshop_project/obryv_zamer_150/zhivaja_priemka_150.sh zelenyj owner/repo S 123 1
fixtures/workshop_project/obryv_zamer_150/zhivaja_priemka_150.sh: line 151: Z150_MOK: unbound variable
ZP_OTKAZ: GH_OTKAZ: gh run view 123 (sm. stderr vishe)
rc=1
bash fixtures/workshop_project/obryv_zamer_150/zhivaja_priemka_150.sh --samoproverka
SLUCHAJ krasnyj-polozhitelnyj rc=0 OK (ZP_KRASNYJ_OK)
SLUCHAJ krasnyj-job-net rc=1 OK (JOB_NET)
SLUCHAJ krasnyj-conclusion-inaja rc=1 OK (KONKLUZIJA)
SLUCHAJ krasnyj-job-ne-zavershen rc=1 OK (KONKLUZIJA)
SLUCHAJ krasnyj-artefakt-net rc=1 OK (ARTEFAKT_NET)
SLUCHAJ krasnyj-fajl-objazatelnyj-net rc=1 OK (FAJL_NET)
SLUCHAJ zelenyj-polozhitelnyj rc=0 OK (ZP_ZELENYJ_OK)
SLUCHAJ zelenyj-artefakt-zapreschen rc=1 OK (ARTEFAKT_ZAPRESCHEN)
SLUCHAJ zelenyj-marker-net rc=1 OK (MARKER_NE_PUBLIKUETSA)
SLUCHAJ oshibka-gh rc=1 OK (GH_OTKAZ)
SAMOPROVERKA: sluchaev 10, sovpalo 10
rc=0
bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh --model --seed 1
ZELENO: клеток 17, зелёных 17
rc=0
bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh --model --seed 7
ZELENO: клеток 17, зелёных 17
rc=0
bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh --model --seed 123
ZELENO: клеток 17, зелёных 17
rc=0
bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh --oracle-tamper
ORACLE_TAMPER_PROVERENO nositelej=3
rc=0
bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh
KRASNO: клеток 17, красных 17; z01–z03,z05,b01–b12: SUBJECT_ABSENT, z04: ZAMER_SKRIPT_NET
rc=1
bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Crit150c/repo contracts/150-prichinnyy-zamer-obryva.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
КРИТИК: дверь зелёная
rc=0
bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Crit150c/repo contracts/150-prichinnyy-zamer-obryva.md
OK
rc=0
bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Crit150c/repo contracts/150-prichinnyy-zamer-obryva.md
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 144 черновик(ов) судится, замороженные — по тегам
потолки в порядке
rc=0
bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Crit150c/repo contracts/150-prichinnyy-zamer-obryva.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 6 буллет(ов), НЕ ЗАЩИЩАЕТ 6 буллет(ов))
rc=0
bash scripts/check_provodka.sh /tmp/dev-harness-verify/Crit150c/repo contracts/150-prichinnyy-zamer-obryva.md
проводка: guard не подключён: fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh не вызывается в .githooks/ или .github/workflows/
rc=1 (ожидаемо до проводки оркестратора)
```

`--stabs` запускался дважды: первый при одновременном `check_zones` оборван лимитом 360 с после десяти красных стабов, не считается завершённым; повтор БЕЗ `check_zones` достиг `SVJAZI 18`, все 18 красные, ни одного `STAB_ZHIV`. Асинхронный инструмент не отдал отдельного числового поля exit, [INFERENCE] rc 0 из конечного `SVJAZI` и `probe.py` (ветка без живых стабов возвращает 0). Сырой вывод обеих попыток:
```
bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh --stabs
[Command timed out after 360 seconds]
STAB stab_zamer_arhiv_soblaznjaet.py → b11-vosstanovlennyj-zelenyj KRASEN (VOSST_PUBLIKUET: зелёный итог после восстановления публикует)
STAB stab_zamer_bez_cgroup.py → b05-cgroup-poly KRASEN (CGROUP_POTERJAN: cgroup-значение '-' (фикстура даёт данные))
STAB stab_zamer_bez_exit.py → b04-dannye-do-ostanovki KRASEN (EXIT_BEZ_PIDA: фиксация смерти не называет упавший PID)
STAB stab_zamer_bez_kolca.py → b06-adb-server-i-device KRASEN (KOLCO_NET: предостановочного logcat-кольца нет (или без -t))
STAB stab_zamer_bez_predela.py → b08-obem-ogranichen KRASEN (FAIL_BEZ_PREDLA: emulator-log-hvost.txt 2446442 байт (потоло)
STAB stab_zamer_bez_redakcii.py → b07-sekrety-redakcija KRASEN (SEKRET_UTEK: ['emulator-log-hvost.txt:ghp_AAAABBBBCC', 'emul)
STAB stab_zamer_kommentarij_sbor.py → z05-put-zagruzki KRASEN (e2e-proba-obryv: PUT_ZAGRUZKI_RASHODITSJA: ispolnjaemyj --ou)
STAB stab_zamer_maskiruet.py → z03-obertka-porjadok-maskirovka KRASEN (e2e-proba-obryv: shag 'Экранная пачка (представитель экранно)
STAB stab_zamer_noop.py → b01-krasnyj-s-signaturoj KRASEN (ARTEFAKT_NET: sbor rc 0, но itog/артефакта нет)
STAB stab_zamer_pem_tolko_begin.py → b07-sekrety-redakcija KRASEN (SEKRET_UTEK: ['emulator-log-hvost.txt:PEM:PRIVATE KEY-----',)

bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh --stabs
STAB stab_zamer_arhiv_soblaznjaet.py → b11-vosstanovlennyj-zelenyj KRASEN (VOSST_PUBLIKUET: зелёный итог после восстановления публикует)
STAB stab_zamer_bez_cgroup.py → b05-cgroup-poly KRASEN (CGROUP_POTERJAN: cgroup-значение '-' (фикстура даёт данные))
STAB stab_zamer_bez_exit.py → b04-dannye-do-ostanovki KRASEN (EXIT_BEZ_PIDA: фиксация смерти не называет упавший PID)
STAB stab_zamer_bez_kolca.py → b06-adb-server-i-device KRASEN (KOLCO_NET: предостановочного logcat-кольца нет (или без -t))
STAB stab_zamer_bez_predela.py → b08-obem-ogranichen KRASEN (FAIL_BEZ_PREDLA: emulator-log-hvost.txt 2446442 байт (потоло)
STAB stab_zamer_bez_redakcii.py → b07-sekrety-redakcija KRASEN (SEKRET_UTEK: ['emulator-log-hvost.txt:ghp_AAAABBBBCC', 'emul)
STAB stab_zamer_kommentarij_sbor.py → z05-put-zagruzki KRASEN (e2e-proba-obryv: PUT_ZAGRUZKI_RASHODITSJA: ispolnjaemyj --ou)
STAB stab_zamer_maskiruet.py → z03-obertka-porjadok-maskirovka KRASEN (e2e-proba-obryv: shag 'Экранная пачка (представитель экранно)
STAB stab_zamer_noop.py → b01-krasnyj-s-signaturoj KRASEN (ARTEFAKT_NET: sbor rc 0, но itog/артефакта нет)
STAB stab_zamer_pem_tolko_begin.py → b07-sekrety-redakcija KRASEN (SEKRET_UTEK: ['emulator-log-hvost.txt:PEM:PRIVATE KEY-----',)
STAB stab_zamer_pidfile_zhiv.py → b10-sampler-ostanovlen KRASEN (SEMPLER_ZHIV: процесс 1153909 пережил сбор)
STAB stab_zamer_posle_ostanovki.py → b04-dannye-do-ostanovki KRASEN (TAJMLAJN_NET: sampler.tsv без строк (замер после остановки?))
STAB stab_zamer_put_zagruzki.py → z05-put-zagruzki KRASEN (e2e-proba-obryv: PUT_ZAGRUZKI_RASHODITSJA: with.path 'mobile)
STAB stab_zamer_shirokij_grep.py → b03-produktovyj-krasnyj KRASEN (LOZHNAYA_PUBLIKAJIJA: артефакт без обрыва в ns (grep шире ns)
STAB stab_zamer_techet_procesom.py → b12-mir-poddelki-umerly KRASEN (PODDELKI_ZHIVY: pids [1253697, 1276223] пережили мир)
STAB stab_zamer_tjaghelo.py → b09-sampler-legkij KRASEN (SAMPLER_TJAZELOVAT: 291 опросов devices за 63 с)
STAB stab_zamer_vsegda.py → b02-zelenyj-tishina KRASEN (ZELENYJ_PUBLIKUET: артефакт на зелёном)
STAB stab_zamer_zelenyj_krasnyj.py → b02-zelenyj-tishina KRASEN (ZELENYJ_KRASN: sbor rc=1)
SVJAZI 18
```

`check_charter.sh <repo> <контракт>` → rc 0, «уставных документов: 146 · изменений в них: 373 · с разрешения: 373». `check_zones.sh <repo>` → терминальный отчёт «замороженных контрактов: 146 · объявленных авторов: 5 · коммитов в диапазонах: 39479 · проверено по зонам: 9241»; инструмент не отдал отдельного числового rc, [INFERENCE] успешное завершение из отчёта. Первый вызов check_zones с лишним вторым аргументом прерван лимитом 120 с, зелёным не назван. `verify_antiplacebo.sh --scope obryv_zamer_150` → rc 1 «scope_select отказал (код 1)» (ключ до CI-проводки не зарегистрирован, проверка ничего не доказала). `ps -eo cmd` с фильтром нонса z150mir ПОСЛЕ полного прогона → `z150mir: EMPTY`, rc 0. Настоящий GitHub CI продукта, реальный эмулятор и native-сборки не запускались; это будущая реализация/приёмка.
