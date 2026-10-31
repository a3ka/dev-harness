FAIL

СУД: repo=dev-harness; предмет=150; фаза=контракт; роль=critic; вызов=2/2; модель-план=openai-codex/gpt-6-sol; модель-факт=openai-codex/gpt-6-sol; сессия=ожидается; SHA=732aa24df467f391f7c976676ebcaca6b6fbbf8a; предыдущий=verdicts/critic/contracts-150-v1-krug1-fail.md; исключение=нет. Автор architect (GLM), судья Sol, независимость по доступным сведениям соблюдена; фактический номер сессии оркестратор не предъявил.

БЛОКИРУЕТ contracts/150-prichinnyy-zamer-obryva.md:69 — повтор класса причины блока 6 круга 1: критерий `W --repo R` объявляет СОГЛАСОВАННЫЙ путь сбора/upload ПО КАЖДОМУ работнику доказанным клеткой z05, но z05 ищет подстроку `mobile/zamer-out-$ZAMER_EKRAN` во всём `run` и исполняет replay ТОЛЬКО первого работника. Во втором работнике реальный `--out mobile/zamer-out-NEVER`, `with.path: mobile/zamer-out-proba-drugoj`; сохранённая в комментарии строка `# historical --out mobile/zamer-out-$ZAMER_EKRAN` даёт ложную зелень 17/17. Это допустимая добавленная запись карты и второй экранный job с собственным выходом селектора; скрипт модели не изменён. В красном job второго работника upload-artifact с `if-no-files-found: ignore` загружает пустоту. Дополнительно, «живые приёмки» на contracts/150-prichinnyy-zamer-obryva.md:75,80-83 утверждают `failure`/`success`/`0`, но перечисленные команды `gh --jq` возвращают rc 0 при ИНОМ значении, а `:83` оставляет сравнение времени «на глаз»: механического доказательства этих частей нет. Исправить проверку исполняемого пути сбора каждого работника (не лексическое совпадение в комментарии), а приёмочные команды сделать возвращающими ненулевой rc при неверном status/count/заявленном инварианте времени; отдельная красная клетка против второго работника с расходящимися путями обязательна до freeze.
ОБХОД: `python3 /tmp/dev-harness-verify/Crit150b/attack_upload_second_worker.py` (копия модели с двумя работниками, второй собирает в `NEVER`, upload ожидает `proba-drugoj`) → `ATTACK_RC 0`, `ZELENO: клеток 17, зелёных 17`, хотя файл второго работника в upload-каталоге не создаётся. При этом `jq` по отсутствующему job печатает ничего и rc 0, а jq-подсчёт одного опубликованного `zamer-…` печатает `1` и rc 0; критерий требует только rc 0.
ОБЯЗАТЕЛЬСТВО: И-6 `:52`, приёмка `:69-70` и предмет `:41` требуют соответствие фактически исполняемого пути сбора и пути upload для КАЖДОГО экранного работника; приёмки `:74-83` должны доказывать заявленный итог командами с кодом возврата.
СОСТОЯНИЕ: новый второй работник карты с корректной DAG-зависимостью и тремя шагами, но неверным `--out` только во втором сборе; живой зелёный job, публикующий диагностический артефакт, или отсутствующий целевой job при живых пунктах 7/8.
НАБЛЮДЕНИЕ: в репро z01–z05 и все b01–b12 зелёные, поскольку b* проигрывают первого работника, а z05 удовлетворяется комментарием. `jq` возвращает 0 независимо от сравнения значения с `failure`/`success`/`0`.

АРБИТР: arbiter — второй FAIL по той же причине «публикация по каждому работнику не доказана приёмкой» (блок 6 круга 1). Предмет инженерного спора: может ли z05 с лексическим поиском `--out` в `run` и replay только первого работника служить достаточным доказательством согласования фактически исполняемого пути для всей карты, и как дать rc-команды для живых пунктов 7/8. Бюджет 2/2 исчерпан; арбитраж не является третьим critic-вызовом или accept.

СОВЕТ contracts/150-prichinnyy-zamer-obryva.md:43 — вопрос числового exit владельцу явно открыт, `НЕ ЗАЩИЩАЕТ` (`:180`) честно называет остаток: решение о достаточности суррогата за владельцем, НЕ самостоятельный блок суда. Однако абсолютное «физически недостижим вне родительской оболочки» стоит сузить до «надёжно недоступен этому непривилегированному наблюдателю ПОСЛЕ reap»: эксперимент показал, что независимый наблюдатель может прочитать числовой wait-status из поля 52 `/proc/PID/stat` ПОКА процесс zombie (42 → 10752), после reap путь пропадает. `pidfd_open` + `waitid(P_PIDFD)` внешнего наблюдателя даёт ECHILD (errno 10); `strace -p` при ptrace_scope=1 и текущих непривилегированных capabilities даёт EPERM; `dmesg` EPERM, `journalctl -k` «No entries». Привилегированная трассировка существует, но не гарантируется runner и не является лёгкой заменой без смены границ. Суррогат death/PID/oom/log-marker и предостановочный ring действительно внесены.
СОВЕТ contracts/150-prichinnyy-zamer-obryva.md:208 — `check_provodka` сейчас rc 1 «guard не подключён» соответствует объявленному порядку freeze..done; оркестратор обязан предъявить rc 0 до done после CI-проводки. Порядок после PR 147/148/149 и красный `--repo` для экрана без обёртки явно описаны (`:212-217`), нового обхода на этом пути не найдено.

Закрытие восьми пунктов предыдущего круга: класс риска теперь «рисковый — безопасность», adversary назначен до reviewer; `check_threat_model` rc 0; `emulator-exit.txt`/предостановочный `logcat -d -t 50` и открытый вопрос числового кода; реальный RECOVERED 995 с сохранённым diagnostics/attempt-1 проверяется b11; PEM тело и END в b07; z05/живые приёмки формально добавлены, но сохраняют описанный ОБХОД; b08 точный потолок с маркером; все mock PID регистрируются/дожидаются, b12 сканирует нонсы и ловит отсоединённый процесс. Лёгкость ≤1 Гц, запрет continue-on-error и неприкосновенность чужих тел остались в критерии. `check_precision_gate` rc 0 `OK`; `check_threat_model` rc 0 `модель угроз: секция валидна (ЗАЩИЩАЕТ 6 буллет(ов), НЕ ЗАЩИЩАЕТ 6 буллет(ов))`.

Scoped-батарея на OBJECT (cwd `/tmp/dev-harness-verify/Crit150b/repo`):
```
bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh --model
ZELENO: клеток 17, зелёных 17
rc=0
bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh --model --seed 7
ZELENO: клеток 17, зелёных 17
rc=0
bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh --oracle-tamper
ORACLE_TAMPER_PROVERENO nositelej=3
rc=0
bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh
KRASNO: клеток 17, красных 17
  z01-obertka-polnota: SUBJECT_ABSENT: KARTA_NET: /tmp/dev-harness-verify/Crit150b/repo/mobile/ci-screens.json
  z02-obertka-parametry: SUBJECT_ABSENT: net workflow
  z03-obertka-porjadok-maskirovka: SUBJECT_ABSENT: net workflow
  z04-kanon-skripta: ZAMER_SKRIPT_NET: mobile/scripts/zamer_obryva.sh
  z05-put-zagruzki: SUBJECT_ABSENT: net workflow
  b01-krasnyj-s-signaturoj: SUBJECT_ABSENT: нет субъекта для replay
  b02-zelenyj-tishina: SUBJECT_ABSENT: нет субъекта для replay
  b03-produktovyj-krasnyj: SUBJECT_ABSENT: нет субъекта для replay
  b04-dannye-do-ostanovki: SUBJECT_ABSENT: нет субъекта для replay
  b05-cgroup-poly: SUBJECT_ABSENT: нет субъекта для replay
  b06-adb-server-i-device: SUBJECT_ABSENT: нет субъекта для replay
  b07-sekrety-redakcija: SUBJECT_ABSENT: нет субъекта для replay
  b08-obem-ogranichen: SUBJECT_ABSENT: нет субъекта для replay
  b09-sampler-legkij: SUBJECT_ABSENT: нет субъекта для replay
  b10-sampler-ostanovlen: SUBJECT_ABSENT: нет субъекта для replay
  b11-vosstanovlennyj-zelenyj: SUBJECT_ABSENT: нет субъекта для replay
  b12-mir-poddelki-umerly: SUBJECT_ABSENT: нет субъекта для replay
SUBJECT_ABSENT: субъект не реализован (продукт без обёртки 150)
rc=1
bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh --stabs
STAB stab_zamer_arhiv_soblaznjaet.py → b11-vosstanovlennyj-zelenyj KRASEN (VOSST_PUBLIKUET: зелёный итог после восстановления публикует)
STAB stab_zamer_bez_cgroup.py → b05-cgroup-poly KRASEN (CGROUP_POTERJAN: cgroup-значение '-' (фикстура даёт данные))
STAB stab_zamer_bez_exit.py → b04-dannye-do-ostanovki KRASEN (EXIT_BEZ_PIDA: фиксация смерти не называет упавший PID)
STAB stab_zamer_bez_kolca.py → b06-adb-server-i-device KRASEN (KOLCO_NET: предостановочного logcat-кольца нет (или без -t))
STAB stab_zamer_bez_predela.py → b08-obem-ogranichen KRASEN (FAIL_BEZ_PREDLA: emulator-log-hvost.txt 2446442 байт (потоло)
STAB stab_zamer_bez_redakcii.py → b07-sekrety-redakcija KRASEN (SEKRET_UTEK: ['emulator-log-hvost.txt:ghp_AAAABBBBCC', 'emul)
STAB stab_zamer_maskiruet.py → z03-obertka-porjadok-maskirovka KRASEN (e2e-proba-obryv: shag 'Экранная пачка (представитель экранно)
STAB stab_zamer_noop.py → b01-krasnyj-s-signaturoj KRASEN (ARTEFAKT_NET: sbor rc 0, но itog/артефакта нет)
STAB stab_zamer_pem_tolko_begin.py → b07-sekrety-redakcija KRASEN (SEKRET_UTEK: ['emulator-log-hvost.txt:PEM:PRIVATE KEY-----',)
STAB stab_zamer_pidfile_zhiv.py → b10-sampler-ostanovlen KRASEN (SEMPLER_ZHIV: процесс 2377078 пережил сбор)
STAB stab_zamer_posle_ostanovki.py → b04-dannye-do-ostanovki KRASEN (TAJMLAJN_NET: sampler.tsv без строк (замер после остановки?))
STAB stab_zamer_put_zagruzki.py → z05-put-zagruzki KRASEN (e2e-proba-obryv: PUT_ZAGRUZKI_RASHODITSJA: with.path 'mobile)
STAB stab_zamer_shirokij_grep.py → b03-produktovyj-krasnyj KRASEN (LOZHNAYA_PUBLIKAJIJA: артефакт без обрыва в ns (grep шире ns)
STAB stab_zamer_techet_procesom.py → b12-mir-poddelki-umerly KRASEN (PODDELKI_ZHIVY: pids [2602610, 2624098] пережили мир)
STAB stab_zamer_tjaghelo.py → b09-sampler-legkij KRASEN (SAMPLER_TJAZELOVAT: 288 опросов devices за 63 с)
STAB stab_zamer_vsegda.py → b02-zelenyj-tishina KRASEN (ZELENYJ_PUBLIKUET: артефакт на зелёном)
STAB stab_zamer_zelenyj_krasnyj.py → b02-zelenyj-tishina KRASEN (ZELENYJ_KRASN: sbor rc=1)
SVJAZI 17
rc=0
```

Самостоятельные атаки; копии/мутации только под `/tmp/dev-harness-verify/Crit150b/`, ни HEAD автора, ни main не менялись:
```
python3 /tmp/dev-harness-verify/Crit150b/attack_with_path.py
WITH_PATH_ONLY rc= 1
stdout:
stderr: KRASNO: клеток 17, красных 1
  z05-put-zagruzki: e2e-proba-obryv: PUT_ZAGRUZKI_RASHODITSJA: with.path 'mobile/zamer-out-NOT-EXIST' != vyhodu sbora 'mobile/zamer-out-proba-obryv'

python3 /tmp/dev-harness-verify/Crit150b/attack_upload_second_worker.py
SECOND_WORKER_COLLECTION: --out mobile/zamer-out-NEVER
SECOND_WORKER_UPLOAD: mobile/zamer-out-proba-drugoj
ATTACK_RC 0
ATTACK_STDOUT
ZELENO: клеток 17, зелёных 17
ATTACK_STDERR

python3 /tmp/dev-harness-verify/Crit150b/attack_semantics.py
ATTACK PEM body unredacted: rc=1; expected=b07-sekrety-redakcija
STDERR: KRASNO: клеток 17, красных 1
  b07-sekrety-redakcija: SEKRET_UTEK: ['emulator-log-hvost.txt:PEM:SUPERSECRET_PRIVATE_KEY_BODY', 'emulator-log-hvost.txt:PEM:SUPERSECRET_PRIVATE_KEY_BODY', 'logcat-kolco.txt:PEM:SUPERSECRET_PRIVATE_KEY_BODY']
SUBJECT_ABSENT: субъект не реализован (продукт без обёртки 150)
ATTACK archived recovery misclassified: rc=1; expected=b11-vosstanovlennyj-zelenyj
STDERR: KRASNO: клеток 17, красных 1
  b11-vosstanovlennyj-zelenyj: VOSST_PUBLIKUET: зелёный итог после восстановления публикует
SUBJECT_ABSENT: субъект не реализован (продукт без обёртки 150)
ATTACK exact cap plus byte: rc=1; expected=b08-obem-ogranichen
STDERR: KRASNO: клеток 17, красных 1
  b08-obem-ogranichen: FAIL_BEZ_PREDLA: emulator-log-hvost.txt 524289 байт (потолок 524288)
SUBJECT_ABSENT: субъект не реализован (продукт без обёртки 150)
ATTACK detached setsid: spawned pid=2515542
ATTACK detached setsid: b12=(False, 'PODDELKI_ZHIVY: pids [2515542] пережили мир')

printf '%s\n' '{"jobs":[{"name":"other","conclusion":"success"}]}' | jq -r '.jobs[] | select(.name=="target") | .conclusion'
(no output; rc=0)
printf '%s\n' '{"artifacts":[{"name":"zamer-target-sha-run-1"}]}' | jq -r '[.artifacts[] | select(.name | startswith("zamer-target-"))] | length'
1
rc=0
```

Дополнительные измерения границы exit: `python3 /tmp/dev-harness-verify/Crit150b/probe_nonparent_wait.py` → `nonparent pidfd waitid failed ChildProcessError errno 10`; `python3 /tmp/dev-harness-verify/Crit150b/probe_zombie_stat.py` → `state= Z exit_code_wait_status= 10752 decoded= 42`, после reap `False`; `python3 /tmp/dev-harness-verify/Crit150b/probe_strace_nonparent.py` → `ptrace(PTRACE_SEIZE, …): Operation not permitted`. `ps -eo cmd | python3 -c '… фильтр z150mir …'` после батарей → `z150mir: EMPTY`, rc 0. Живой GitHub CI продукта не исполнялся: это будущая приёмка 7/8.
