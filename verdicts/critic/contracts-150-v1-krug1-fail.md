FAIL

СУД: repo=dev-harness; предмет=150; фаза=контракт; роль=critic; вызов=1/2; модель-план=openai-codex/gpt-6-sol; модель-факт=openai-codex/gpt-6-sol; сессия=ожидается; SHA=1dbaf6415db12e66f2ccd7aeaa7aa1dc2ce24d23; предыдущий=нет; исключение=нет. Автор коммита: architect; модель автора по предъявленному заданию: GLM. Судился только закоммиченный OBJECT в одноразовом клоне; модель критика — Sol. Номер сессии в предъявленном СУД ещё не дополнен оркестратором, выдумывать его нельзя.

БЛОКИРУЕТ contracts/150-prichinnyy-zamer-obryva.md:3 — «КЛАСС РИСКА: обычный … сетевой безопасности нет» игнорирует именно защищаемую границу: тексты диагностических журналов попадают в публикуемый GitHub-артефакт, И-5 требует не раскрывать секреты. Frozen 995/5 классифицирует такую публикацию диагностического секрета как «рисковый — безопасность» (contracts/995-cmp-mob-001-android-pilot.md:4). Исправить класс и основание, назначить требуемого независимого adversary; redaction не является основанием *снять* риск.
ОБЯЗАТЕЛЬСТВО: roles/critic.md §Класс риска запрещает занижение кодового контракта; И-5 запрещает секреты в артефакте.
СОСТОЯНИЕ: журнал эмулятора содержит PRIVATE KEY, новая обвязка публикует его хвост.
НАБЛЮДЕНИЕ: модельный скрипт и батарея сейчас пропускают тело ключа (самостоятельная атака ниже).

БЛОКИРУЕТ contracts/150-prichinnyy-zamer-obryva.md:161 — «ЗАЩИЩАЕТ (по свойству):» и contracts/150-prichinnyy-zamer-obryva.md:169 «НЕ ЗАЩИЩАЕТ (остаточные риски, имя ловца или владельца решения):» не являются распознаваемыми метками `ЗАЩИЩАЕТ:`/`НЕ ЗАЩИЩАЕТ:`; между каждой меткой и первым буллетом также оставлена пустая строка. Форма введённой модели угроз не проходит норму 041 для гарда чужого ввода. Исправить литеральные метки **и** примыкание буллетов; один только переименованный заголовок всё ещё rc 1.
ОБЯЗАТЕЛЬСТВО: roles/critic.md §Норма модели угроз и scripts/check_threat_model.sh требуют оба списка с ≥1 непосредственно следующим буллетом.
СОСТОЯНИЕ: проверка HEAD 1dbaf6415 на чистом checkout.
НАБЛЮДЕНИЕ: `bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Crit150/repo contracts/150-prichinnyy-zamer-obryva.md` → rc 1, сырой вывод `модель угроз: список ЗАЩИЩАЕТ: отсутствует`. Проба изолированной копии с одними переименованными метками → rc 1 `модель угроз: список ЗАЩИЩАЕТ: пуст (нет буллета)`; с удалёнными двумя пустыми строками → rc 0 `модель угроз: секция валидна (ЗАЩИЩАЕТ 5 буллет(ов), НЕ ЗАЩИЩАЕТ 6 буллет(ов))`.

БЛОКИРУЕТ contracts/150-prichinnyy-zamer-obryva.md:171 — «код возврата qemu … не код; … не этот предмет» односторонне исключает **exit** эмулятора, прямо требуемый принятым решением владельца `docs/owner/2026-10-26-obryv-emulyatora-v2.md:21-22` («PID/exit … ограниченный logcat — до остановки») и Astra §10:173–175. Вдобавок `:34,40,45` обещают logcat или маркер, но модельный sampler не пишет logcat, а `adb logcat -d -t 200` вызывается только в отдельном шаге сбора *после* `trap cleanup EXIT` экрана; даже при доступном до обрыва госте остаётся лишь маркер. Astra явно требует короткий bounded ring/stream до Maestro, а не попытку чтения после исчезновения serial. Сэмплер до экранного шага решает часть PID/boot_id/pressure, не эти два обязательных различителя. Восстановить и доказать предостановочные exit/status и ограниченный guest logcat либо получить явное изменение решения владельца; не объявлять честную метку недоступности эквивалентом замера.
ОБЯЗАТЕЛЬСТВО: принятое решение владельца §Решение п.2 и причинный замер **до** stop; не сокращать предмет без разрешения.
СОСТОЯНИЕ: экранный `run:` заканчивается и его EXIT-trap останавливает qemu до следующего отдельного `if: always()` шага; модельный sampler работает в этот интервал, но измеряет только PID/guest boot_id/adbd/cgroup.
НАБЛЮДЕНИЕ: `model/mobile/scripts/zamer_obryva.sh:145-201,224-259` не получает exit status и никогда не читает logcat в sampler; читает logcat только после остановки, затем пишет «logcat-kolco nizhe», которого нет. Клетки b04/b06 проверяют PID/boot_id, не exit/status и не предостановочное содержимое logcat.

БЛОКИРУЕТ contracts/150-prichinnyy-zamer-obryva.md:46 — «восстановленный-зелёный … не публикуют» обманут *действующим frozen 995/5*: его S при RECOVERED публикует diagnostics/attempt-1 с первоначальными `device offline`/DeviceServerDiedException даже после успешной второй попытки (model/ci-e2e.sh:251-284,339-355); P копирует этот каталог в `mobile/maestro-out` (model/maestro_probe.py:217-248), а карта 143 указывает `integracija.output_namespace=mobile/maestro-out`. Батарея b11 вместо этого *целиком* вытирает ns, поэтому принимаемый критерий принимает саму модель на нереалистичном recovered-состоянии; простой grep любой сигнатуры в ns публикует замер в зелёном job. Красная клетка должна моделировать сохранённую диагностику предыдущей попытки frozen 995, не стирать её. Гейт обязан различать текущий итог и исторические признаки без изменения чужого S/P.
ОБХОД: green `report.xml` текущей попытки и `diagnostics/attempt-1/maestro.log` с `device offline` одновременно допустимы для RECOVERED 995; модельный `sbor` rc 0 создаёт `itog.txt` с `reshenie=publikuem`, а существующий `W --model` rc 0 15/15 из-за полного wipe в собственной фикстуре.

БЛОКИРУЕТ contracts/150-prichinnyy-zamer-obryva.md:48 — обещано удалить `PRIVATE KEY` из ВСЕХ текстов артефакта, но модельный `redakt_fajl` заменяет только строку `BEGIN ... PRIVATE KEY`, оставляет body и `END ... PRIVATE KEY`; клетка b07 сеет/ищет только ghp_/AKIA/Bearer. Исправить redaction многострочного ключа и красный тест с его секретным body во всём опубликованном дереве.
ОБХОД: допустимый красный журнал с `-----BEGIN RSA PRIVATE KEY-----\nSUPERSECRET_PRIVATE_KEY_BODY_150\n-----END RSA PRIVATE KEY-----` даёт `W --model` rc 0 `ZELENO: клеток 15, зелёных 15`, при этом `emulator-log-hvost.txt` содержит `SUPERSECRET_PRIVATE_KEY_BODY_150` и строку END.

БЛОКИРУЕТ contracts/150-prichinnyy-zamer-obryva.md:66 — `W --repo R` якобы доказывает публикацию, но z03 проверяет лишь `uses: actions/upload-artifact` и `if-no-files-found: ignore`, не `with.path`; b01 проверяет локальный itog, не соответствие пути загрузки. Подмена только `with.path` на отсутствующий каталог сохраняет 15/15 зелёными, реального артефакта в красном CI нет. Живые пункты `:71-72` написаны без команды с кодом возврата («ревьюер видит глазами») и не заменяют недостающего доказательства публикации. Добавить красную клетку для согласования пути upload с выходом сбора **по каждому работнику**, а живую приёмку сформулировать командой с rc, проверяющей статус red/green run и скачанный/отсутствующий артефакт по run id.
ОБХОД: на одноразовой копии модели только `path: mobile/zamer-out-proba-obryv` → `path: mobile/zamer-out-NEVER`; `W --repo <копия>` → rc 0 `ZELENO: клеток 15, зелёных 15` при `if-no-files-found: ignore` и отсутствии опубликованного снимка.

БЛОКИРУЕТ contracts/150-prichinnyy-zamer-obryva.md:47 — строгий предел «каждый файл ≤512 KiB» нарушает *само* каноническое зелёное исполнение: модель режет файл до 524288 байт, а затем приписывает маркер обрезки; b08 разрешает +128 байт и объявляет (True, ''). Исправить реальную границу с учётом маркера и точное сравнение в клетке.
ОБХОД: штатный b08-вход (300 emulator-log строк по 12 KiB) → `emulator-log-hvost.txt` 524321 байт при лимите 524288, `sud_b08(result) == (True, '')`, `W --model` rc 0 15/15.

БЛОКИРУЕТ contracts/150-prichinnyy-zamer-obryva.md:187 — предпосылка «процессы-подделки … умирают с песочницей» ложна для recovered-ветви. В `probe.py:556-562` `wipe_ns_zelenym` запускает НАСТОЯЩИЙ qemu-mock через `_poddelnyj_proces(...)` и выбрасывает его Popen; в `finally` `:600-616` убивается только первоначальный qemu и список `novye`, куда добавляется **лишь** adb-server. При последнем `ubit_qemu` сценария снова убивается старый qemu. Новый `sleep 600` переживает выход replay и удаление каталога; отдельная сессия не даёт групповому cleanup его достать. Точное закрытие — сохранить/останавливать/дождаться каждый порождённый PID, включая recovered и исключительные выходы, и доказать после батареи отсутствие новых живых подделок своего мира. Своих найденных потомков этого клона критик прибрал; сообщённых пользователем старых станционных процессов не трогал.
ОБЯЗАТЕЛЬСТВО: контрактная предпосылка :187 и безопасность/изоляция самоисполняемой красной батареи.
СОСТОЯНИЕ: `SCENARII['vosstanovlennyj']`: обрыв → `perezapust_qemu` → `wipe_ns_zelenym` → повторный `ubit_qemu`, затем finally; `_poddelnyj_proces` создаёт процесс `sleep 600` с argv0 `qemu-system-x86_64 z150mir-… -port 5571`.
НАБЛЮДЕНИЕ: никакой записи нового Popen в `novye` нет; cleanup после завершения теста нашёл и послал SIGKILL только десяти запущенным после создания этого клона mock-qemu PID `[4121, 55118, 90512, 115026, 146334, 305924, 329314, 4077096, 4143427, 4143428]` (сырое `CLEANUP owned leaked mock-qemu pids [...]`). Старые процессы, о которых сообщил пользователь до запуска клона, не использовались как доказательство нового прогона.

СОВЕТ contracts/150-prichinnyy-zamer-obryva.md:198 — заявленный `check_provodka` rc 1 до работы orchestrator допускается объявленным порядком freeze..done, но зелёную проводку до done всё равно обязательно предъявить; это не девятый блокер сейчас.
СОВЕТ contracts/150-prichinnyy-zamer-obryva.md:31 — отдельный GHA run-шаг действительно идёт после `trap cleanup EXIT` предыдущего шага; предостановочный таймлайн сэмплера помогает PID/boot_id/pressure. Не смешивать это корректное частичное доказательство с недостающими exit/logcat (блокер выше).
СОВЕТ contracts/150-prichinnyy-zamer-obryva.md:203 — заявленный порядок после merge #146/#147 и красная проверка экрана, влитого позднее без обёртки, явно назван; нового обхода этой гонки не доказано.

Базовые команды на зафиксированном OBJECT (cwd `/tmp/dev-harness-verify/Crit150/repo`):
```
bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh --model
ZELENO: клеток 15, зелёных 15
rc=0
bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh --model --seed 7
ZELENO: клеток 15, зелёных 15
rc=0
bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh --oracle-tamper
ORACLE_TAMPER_PROVERENO nositelej=3
rc=0
bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh
KRASNO: клеток 15, красных 15
  z01-obertka-polnota: SUBJECT_ABSENT: KARTA_NET: /tmp/dev-harness-verify/Crit150/repo/mobile/ci-screens.json
  z02-obertka-parametry: SUBJECT_ABSENT: net workflow
  z03-obertka-porjadok-maskirovka: SUBJECT_ABSENT: net workflow
  z04-kanon-skripta: ZAMER_SKRIPT_NET: mobile/scripts/zamer_obryva.sh
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
SUBJECT_ABSENT: субъект не реализован (продукт без обёртки 150)
rc=1
```

Стабы автора. Первый вызов `bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh --stabs` прерван лимитом инструмента 300 с после первых пяти строк (не подменяется успешным); сырой вывод:
```
[Command timed out after 300 seconds]
STAB stab_zamer_bez_cgroup.py → b05-cgroup-poly KRASEN (CGROUP_POTERJAN: cgroup-значение '-' (фикстура даёт данные))
STAB stab_zamer_bez_predela.py → b08-obem-ogranichen KRASEN (FAIL_BEZ_PREDLA: emulator-log-hvost.txt 2458655 байт)
STAB stab_zamer_bez_redakcii.py → b07-sekrety-redakcija KRASEN (SEKRET_UTEK: ['emulator-log-hvost.txt:ghp_AAAABBBBCC'])
STAB stab_zamer_maskiruet.py → z03-obertka-porjadok-maskirovka KRASEN (e2e-proba-obryv: shag 'Экранная пачка (представитель экранно)
STAB stab_zamer_noop.py → b01-krasnyj-s-signaturoj KRASEN (ARTEFAKT_NET: sbor rc 0, но itog/артефакта нет)
```
Полный повтор той же команды с timeout 1200 с → rc 0, сырой вывод:
```
STAB stab_zamer_bez_cgroup.py → b05-cgroup-poly KRASEN (CGROUP_POTERJAN: cgroup-значение '-' (фикстура даёт данные))
STAB stab_zamer_bez_predela.py → b08-obem-ogranichen KRASEN (FAIL_BEZ_PREDLA: emulator-log-hvost.txt 2458655 байт)
STAB stab_zamer_bez_redakcii.py → b07-sekrety-redakcija KRASEN (SEKRET_UTEK: ['emulator-log-hvost.txt:ghp_AAAABBBBCC'])
STAB stab_zamer_maskiruet.py → z03-obertka-porjadok-maskirovka KRASEN (e2e-proba-obryv: shag 'Экранная пачка (представитель экранно)
STAB stab_zamer_noop.py → b01-krasnyj-s-signaturoj KRASEN (ARTEFAKT_NET: sbor rc 0, но itog/артефакта нет)
STAB stab_zamer_pidfile_zhiv.py → b10-sampler-ostanovlen KRASEN (SEMPLER_ZHIV: процесс 95081 пережил сбор)
STAB stab_zamer_posle_ostanovki.py → b04-dannye-do-ostanovki KRASEN (TAJMLAJN_NET: sampler.tsv без строк (замер после остановки?))
STAB stab_zamer_shirokij_grep.py → b03-produktovyj-krasnyj KRASEN (LOZHNAYA_PUBLIKAJIJA: артефакт без обрыва в ns (grep шире ns)
STAB stab_zamer_tjaghelo.py → b09-sampler-legkij KRASEN (SAMPLER_TJAZELOVAT: 249 опросов devices за 63 с)
STAB stab_zamer_vsegda.py → b02-zelenyj-tishina KRASEN (ZELENYJ_PUBLIKUET: артефакт на зелёном)
STAB stab_zamer_zelenyj_krasnyj.py → b02-zelenyj-tishina KRASEN (ZELENYJ_KRASN: sbor rc=1)
SVJAZI 11
```

Самостоятельные атаки (только одноразовые копии в `/tmp/dev-harness-verify/Crit150/`, без изменений worktree автора/main), команды и сырые выводы:
```
python3 /tmp/dev-harness-verify/Crit150/attacks.py
ATTACK missing upload path: bash /tmp/dev-harness-verify/Crit150/repo/fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh --repo /tmp/dev-harness-verify/Crit150/z150-critic-7cjv2kjl/product rc=0
stdout: ZELENO: клеток 15, зелёных 15
 stderr:
ATTACK seeded private-key corpus: bash /tmp/dev-harness-verify/Crit150/z150-critic-7cjv2kjl/fixture/red_obryv_zamer_150.sh --model rc=0
stdout: ZELENO: клеток 15, зелёных 15
 stderr:
ARTIFACT contains PRIVATE KEY body: True
ARTIFACT relevant lines: ['SUPERSECRET_PRIVATE_KEY_BODY_150', '-----END RSA PRIVATE KEY-----']
python3 /tmp/dev-harness-verify/Crit150/cap_repro.py
rc_sbor 0
adb-server-i-ustrojstva.txt 158 limit 524288 exceeded False
boot_id_final.txt 118 limit 524288 exceeded False
emulator-log-hvost.txt 524321 limit 524288 exceeded True
itog.txt 215 limit 524288 exceeded False
logcat.txt 107 limit 524288 exceeded False
sampler.tsv 8313 limit 524288 exceeded False
signatury.txt 201 limit 524288 exceeded False
sistemnyj-snimok.txt 448 limit 524288 exceeded False
b08: (True, '')
python3 /tmp/dev-harness-verify/Crit150/recovered_repro.py
RECOVERED synthetic 995 namespace; sbor rc 0
stdout: ZAMER_SBOR: artefakt sobran v mobile/zamer-out-pilot
stderr: ZAMER_SEMPLER_PIDFILE_NET: start ne ispolnjalsja?
ZAMER_SBOR_OTKAZ: sampler.tsv ne skopirovan
ZAMER_SBOR_OTKAZ: sistemnyj-snimok ne skopirovan
RECOVERED publishes diagnostic artifact: True
itog: reshenie=publikuem: signatura obryva v ns rabotnika
python3 /tmp/dev-harness-verify/Crit150/threat_repro.py   # первый запуск: только заголовки; затем заголовки + смежные буллеты
labels fixed rc 1 stdout  stderr модель угроз: список ЗАЩИЩАЕТ: пуст (нет буллета)
labels and adjacency fixed rc 0 stdout  stderr модель угроз: секция валидна (ЗАЩИЩАЕТ 5 буллет(ов), НЕ ЗАЩИЩАЕТ 6 буллет(ов))
python3 /tmp/dev-harness-verify/Crit150/cleanup.py
CLEANUP owned leaked mock-qemu pids [4121, 55118, 90512, 115026, 146334, 305924, 329314, 4077096, 4143427, 4143428]
```

Прочие scoped-гейты: `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Crit150/repo contracts/150-prichinnyy-zamer-obryva.md` → rc 0, `OK` (новые зоны и пересечения); `bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Crit150/repo contracts/150-prichinnyy-zamer-obryva.md` → rc 0, `КРИТИК: дверь зелёная`; `bash scripts/check_provodka.sh /tmp/dev-harness-verify/Crit150/repo contracts/150-prichinnyy-zamer-obryva.md` → rc 1, `проводка: guard не подключён: fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh не вызывается в .githooks/ или .github/workflows/`. Живой CI Complior-mob и upload в GitHub ещё не исполнялись: до реализации продукта они не являются проверенным здесь результатом.
