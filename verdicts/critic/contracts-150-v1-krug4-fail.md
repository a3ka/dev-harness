FAIL
OBJECT=1d5d3463f9ebc81378cd3ceea774d2330a74a4ae
СУД: repo=dev-harness; предмет=150; фаза=контракт (scoped после дельты); роль=critic; вызов=4 (сверх капа по слову владельца 2026-10-31 ~21:40 UTC); сессия=Crit150d; модель-факт=openai-codex/gpt-6-sol; SHA=1d5d3463f9ebc81378cd3ceea774d2330a74a4ae; предыдущий=verdicts/critic/contracts-150-v1-krug3-fail.md; арбитраж=verdicts/arbitration/contracts-150-arbitraz.md; исключение=да. Автор конструкции architect/GLM по предъявленным сведениям, критик Sol; независимость соблюдена. Закоммиченный OBJECT судился в изолированном клоне `/tmp/dev-harness-verify/Crit150d/repo`; правок репо автора, GIT_DIR/GIT_WORK_TREE основного checkout и push в origin не было.
РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/150-prichinnyy-zamer-obryva.md — один дополнительный scoped-вызов критика (вызов 4) только по четырём блокам Crit150c (z05 «||», Z150_MOK, пустой ответ API, арность dlitelnosti) и зависимому регрессу после одной дельты architect; при FAIL — стоп и пере-скоуп (слово владельца 2026-10-31)

БЛОКИРУЕТ contracts/150-prichinnyy-zamer-obryva.md:70 — П1 z05 принимает гарантированно пропущенный сбор ВТОРОГО работника: перевод строки после `||` восстанавливает в `_shell_komandy` признак «безусловно». Это тот же класс причины, что в вызове 3, и прямо нарушает названное закрывающее свойство вызова 4.
ОБЯЗАТЕЛЬСТВО: путь upload равен `--out` фактически БЕЗУСЛОВНО ИСПОЛНЯЕМОЙ команды `bash mobile/scripts/zamer_obryva.sh sbor` шага сбора ПО КАЖДОМУ работнику карты; правый операнд `&&`/`||` с возможностью пропуска краснеет именованно.
КЛАСС ПРИЧИНЫ: недо-приближение структуры shell. `probe.py:894-897` при `\n` присваивает `bezuslovno = baza[-1]` (True), хотя ранее правый операнд `||` помечен условным; для bash перевод строки ПОСЛЕ незавершённого оператора не снимает условность.
СОСТОЯНИЕ: мир с двумя законными работниками; первый штатный, у второго перед канонической командой сбора стоит `true ||` + перевод строки; `--out` канонический и `with.path` правильный, но сбор не запускается и upload с `if-no-files-found: ignore` получает пустоту.
НАБЛЮДЕНИЕ: `bash -c $'true ||\nprintf SHOULD_NOT_RUN\nprintf SKIPPED'` → `SKIPPED`, rc 0 (правая команда пропущена). Мутация ниже дала rc 0/17 зелёных; контроль двух штатных работников rc 0/17 зелёных, контроль неверного исполняемого `--out` второго rc 1/z05 `PUT_ZAGRUZKI_RASHODITSJA`.
ОБХОД: `python3 /tmp/dev-harness-verify/Crit150d/attack_operator_newline.py` (одноразовый мир, shell-валидный второй работник с правильным текстовым `--out`); сырой вывод команды, rc инструмента 0:
```
SECOND_WORKER_COLLECTION: 'set -u\ntrue ||\nbash mobile/scripts/zamer_obryva.sh sbor \\\n  --ekran "$ZAMER_EKRAN" --ns "$ZAMER_NS" --serial "$ZAMER_SERIAL" \\\n  --spool .zamer-$ZAMER_EKRAN --out mobile/zamer-out-$ZAMER_EKRAN\n'
ATTACK_RC 0
ATTACK_STDOUT
ZELENO: клеток 17, зелёных 17

ATTACK_STDERR
```
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: при втором работнике пропущенный сбор краснеет содержательной причиной z05 даже с переводом строки ПОСЛЕ `||`/`&&`; тот же мир с исправленным вторым работником остаётся зелёным.

Контроли той же карты, `python3 /tmp/dev-harness-verify/Crit150d/control_second_worker.py` (сырой вывод):
```
CONTROL canonical RC 0
ZELENO: клеток 17, зелёных 17
STDERR:
CONTROL wrong-out RC 1
STDERR: KRASNO: клеток 17, красных 1
  z05-put-zagruzki: e2e-proba-drugoj: PUT_ZAGRUZKI_RASHODITSJA: ispolnjaemyj --out 'mobile/zamer-out-NEVER' != with.path 'mobile/zamer-out-proba-drugoj' (upload gruzit pustotu)
```

П2 Z150_MOK: положительные живые `zelenyj` и `krasnyj` через ВНЕШНИЙ gh-двойник в PATH оба rc 0, `Z150_MOK=/nonexistent` не влияет на зелёный режим; mock объявлен внутри `samoproverka`.
П2 пустой API: ответ gh 0 байт даёт именованный `PUSTOJ_OTVET_API`, rc 1; валидный ответ с `artifacts:[]` даёт зелёный rc 0.
П2-5: `dlitelnosti` с четырьмя аргументами rc 0, печатает ОБА run (420s и 400s); с тремя аргументами rc 1 ARGUMENTY.

САМООПИСАНИЕ — полный список расхождений: **нет**. Перемерены отдельным классом следующие адреса и числа:
- contracts/150-prichinnyy-zamer-obryva.md:62, :66, :67, :195, :198, :200 — 17 клеток, 17/17 зелёных на модели default и seeds 1/7/123, 17/17 красных без субъекта; `len(probe.KLETKI)=17`.
- contracts/150-prichinnyy-zamer-obryva.md:67, :68, :196 — 23 привязки `.stab_vhod`, 23 файла `stab_*.py`, `--stabs` завершился `SVJAZI 23`, все 23 стаба красные, живых нет; новые пять красны содержательной причиной СВОЕЙ клетки z05 по коду `source.json`.
- fixtures/workshop_project/obryv_zamer_150/osi.md:50-72 — 23 `| stab_zamer…`-строки, включая новые пять :67-71; osi.md:79 — `SVJAZI 23`.
- contracts/150-prichinnyy-zamer-obryva.md:69, :197 — 3 пина `.piny`; `--oracle-tamper` вывел `ORACLE_TAMPER_PROVERENO nositelej=3`.
- contracts/150-prichinnyy-zamer-obryva.md:199 — мир 143 без обёртки, rc 1 `KRASNO: клеток 17, красных 14`.
- contracts/150-prichinnyy-zamer-obryva.md:200 — одна красная клетка z05 для negative wrong-out, подтверждено контролем; обход newline даёт ноль красных, это содержательная ложная достаточность, а НЕ счётная опечатка.
- contracts/150-prichinnyy-zamer-obryva.md:201 — `--samoproverka`: 11 случаев, 11 совпадений, rc 0.

Команды и сырой значимый вывод (cwd=/tmp/dev-harness-verify/Crit150d/repo):
```
git cat-file -t 1d5d3463f9ebc81378cd3ceea774d2330a74a4ae
commit
rc=0

git diff --name-only 0445f8068..1d5d3463f9ebc81378cd3ceea774d2330a74a4ae | wc -l
10
rc=0

bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh --model
ZELENO: клеток 17, зелёных 17
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

bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh
KRASNO: клеток 17, красных 17
SUBJECT_ABSENT: субъект не реализован (продукт без обёртки 150)
rc=1
bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh --repo fixtures/workshop_project/mob_ci_143/model
KRASNO: клеток 17, красных 14
rc=1
bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh --oracle-tamper
ORACLE_TAMPER_PROVERENO nositelej=3
rc=0

bash fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh --stabs
STAB stab_zamer_arhiv_soblaznjaet.py → b11-vosstanovlennyj-zelenyj KRASEN (VOSST_PUBLIKUET: зелёный итог после восстановления публикует)
STAB stab_zamer_bez_cgroup.py → b05-cgroup-poly KRASEN (CGROUP_POTERJAN: cgroup-значение '-' (фикстура даёт данные))
STAB stab_zamer_bez_exit.py → b04-dannye-do-ostanovki KRASEN (EXIT_BEZ_PIDA: фиксация смерти не называет упавший PID)
STAB stab_zamer_bez_kolca.py → b06-adb-server-i-device KRASEN (KOLCO_NET: предостановочного logcat-кольца нет (или без -t))
STAB stab_zamer_bez_predela.py → b08-obem-ogranichen KRASEN (FAIL_BEZ_PREDLA: emulator-log-hvost.txt 2446442 байт (потоло)
STAB stab_zamer_bez_redakcii.py → b07-sekrety-redakcija KRASEN (SEKRET_UTEK: ['emulator-log-hvost.txt:ghp_AAAABBBBCC', 'emul)
STAB stab_zamer_exit_do_sbora.py → z05-put-zagruzki KRASEN (e2e-proba-obryv: SBOR_NEDOSTIZHIM: bezuslovnyj exit vyshe vy)
STAB stab_zamer_funkcija_sbor.py → z05-put-zagruzki KRASEN (e2e-proba-obryv: SBOR_RUN_NE_RASPOZNAN: neraspozannaja forma)
STAB stab_zamer_heredoc_sbor.py → z05-put-zagruzki KRASEN (e2e-proba-obryv: SBOR_RUN_NE_RASPOZNAN: neraspozannaja forma)
STAB stab_zamer_kommentarij_sbor.py → z05-put-zagruzki KRASEN (e2e-proba-obryv: PUT_ZAGRUZKI_RASHODITSJA: ispolnjaemyj --ou)
STAB stab_zamer_maskiruet.py → z03-obertka-porjadok-maskirovka KRASEN (e2e-proba-obryv: shag 'Экранная пачка (представитель экранно)
STAB stab_zamer_noop.py → b01-krasnyj-s-signaturoj KRASEN (ARTEFAKT_NET: sbor rc 0, но itog/артефакта нет)
STAB stab_zamer_pem_tolko_begin.py → b07-sekrety-redakcija KRASEN (SEKRET_UTEK: ['emulator-log-hvost.txt:PEM:PRIVATE KEY-----',)
STAB stab_zamer_pidfile_zhiv.py → b10-sampler-ostanovlen KRASEN (SEMPLER_ZHIV: процесс 2503545 пережил сбор)
STAB stab_zamer_posle_ostanovki.py → b04-dannye-do-ostanovki KRASEN (TAJMLAJN_NET: sampler.tsv без строк (замер после остановки?))
STAB stab_zamer_put_zagruzki.py → z05-put-zagruzki KRASEN (e2e-proba-obryv: PUT_ZAGRUZKI_RASHODITSJA: with.path 'mobile)
STAB stab_zamer_shirokij_grep.py → b03-produktovyj-krasnyj KRASEN (LOZHNAYA_PUBLIKAJIJA: артефакт без обрыва в ns (grep шире ns)
STAB stab_zamer_techet_procesom.py → b12-mir-poddelki-umerly KRASEN (PODDELKI_ZHIVY: pids [2749770, 2771549] пережили мир)
STAB stab_zamer_tjaghelo.py → b09-sampler-legkij KRASEN (SAMPLER_TJAZELOVAT: 293 опросов devices за 63 с)
STAB stab_zamer_uslovnyj_sbor.py → z05-put-zagruzki KRASEN (e2e-proba-obryv: SBOR_NE_BEZUSLOVEN: vyzov sbor v uslovnoj p)
STAB stab_zamer_uslovnyj_sbor_and.py → z05-put-zagruzki KRASEN (e2e-proba-obryv: SBOR_NE_BEZUSLOVEN: vyzov sbor v uslovnoj p)
STAB stab_zamer_vsegda.py → b02-zelenyj-tishina KRASEN (ZELENYJ_PUBLIKUET: артефакт на зелёном)
STAB stab_zamer_zelenyj_krasnyj.py → b02-zelenyj-tishina KRASEN (ZELENYJ_KRASN: sbor rc=1)
SVJAZI 23
```
`--stabs` вывод завершён, отдельного числового exit из фонового инструмента не получено; [INFERENCE] rc=0 из итогового `SVJAZI 23` и отсутствия `STAB_ZHIV` (само число и пять содержательных красных строк непосредственно наблюдались).

```
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
SLUCHAJ zelenyj-otvet-api-pustoj rc=1 OK (PUSTOJ_OTVET_API)
SLUCHAJ oshibka-gh rc=1 OK (GH_OTKAZ)
SAMOPROVERKA: sluchaev 11, sovpalo 11
rc=0

# PATH=/tmp/dev-harness-verify/Arch150d/gh-dvojnik:$PATH; Z150_GH_MIR=<мир двойника>
# env Z150_MOK=/nonexistent, ... zelenyj owner/repo S 123 1
ZP_ZELENYJ_OK: run=123 job=S jobid=111 artefaktov_zamer=0 marker=est
rc=0
# ... krasnyj owner/repo S 123 1 C
ZP_KRASNYJ_OK: run=123 job=S jobid=111 artefakt=zamer-S-C-123-1 katalog=/tmp/zp150-9PhTtk
OBaZATELNO V OTChET REVJu: stroka sampler.tsv s PID (do obryva), blok emulator-exit.txt, marker logcat-kolco.txt
rc=0
# ... zelenyj owner/repo S 123 1; artifacts.json 0 байт
ZP_OTKAZ: PUSTOJ_OTVET_API: artifacts API run 123 — net ni odnoj validnoj JSON-stranicy (0 bajtov/musor)
rc=1
# ... dlitelnosti owner/repo S 123 124
DLITELNOST s-obertochnym-150: run=123 job=S jobid=111 status=completed conclusion=success nach=2026-10-31T10:00:00Z konets=2026-10-31T10:07:00Z dlitelnost=420s
DLITELNOST bez-obertki-150: run=124 job=S jobid=222 status=completed conclusion=success nach=2026-10-31T09:00:00Z konets=2026-10-31T09:06:40Z dlitelnost=400s
VYVOD (revjuer): sopostavimost' kartы/runnera/vetki — objazatelno v otchjot; chislovoj porog overhead — volja vladel'tsa (naznacheno ne budet)
rc=0
# bash ... zhivaja_priemka_150.sh dlitelnosti owner/repo S 123
ZP_OTKAZ: ARGUMENTY: dlitelnosti <repo> <S> <R1> <R2 — vsego 4 argumenta posle komandy
rc=1

bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Crit150d/repo contracts/150-prichinnyy-zamer-obryva.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
КРИТИК: дверь зелёная
rc=0
bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Crit150d/repo contracts/150-prichinnyy-zamer-obryva.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 6 буллет(ов), НЕ ЗАЩИЩАЕТ 6 буллет(ов))
rc=0
bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Crit150d/repo contracts/150-prichinnyy-zamer-obryva.md
OK
rc=0
bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Crit150d/repo contracts/150-prichinnyy-zamer-obryva.md
потолки в порядке
rc=0
bash scripts/check_zones.sh /tmp/dev-harness-verify/Crit150d/repo
замороженных контрактов: 146 · объявленных авторов: 5 · коммитов в диапазонах: 39498 · проверено по зонам: 9260
```
`check_zones` терминальный отчёт получен, отдельный числовой exit из фонового инструмента не получен; [INFERENCE] успешное завершение из терминального отчёта. `bash scripts/check_provodka.sh ...` → rc 1 «guard не подключён», ожидаемо до CI-проводки оркестратора.

НЕ ПРОВЕРЕНО: реальный GitHub run и продуктовый Complior-mob (будущая фаза реализации/reviewer); эмуляторы и нативные сборки не запускались по правилу станции. Зависимый регресс дельты проверен названными выше командами; неизменённые области полного документа повторно не судились.

По строке РАЗРЕШИЛ-ВЛАДЕЛЕЦ FAIL означает СТОП и пере-скоуп. Шестого круга 150 нет.
