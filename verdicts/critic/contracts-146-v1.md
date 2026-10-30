accept
OBJECT=5d1f60620bc4ef60ebaf6ba845e2a0f9690f3890
СУД: repo=dev-harness; предмет=146; фаза=последний scoped-критик после FAIL Crit146c по слову владельца 30.10 «А»; роль=critic-sol; вызов=адресное исключение, один вызов; сессия=Crit146d; модель-факт=openai-codex/gpt-6-sol; автор=Fix146d, модель-факт=zai/glm-5.3; независимость=фактические строки обеих ролей в `scripts/models_actual.sh --tsv --bind` различаются; SHA=5d1f60620bc4ef60ebaf6ba845e2a0f9690f3890; предыдущий=/tmp/dev-harness-verify/Crit146c/verdicts/critic/contracts-146-v1c.md (FAIL); исключение=прямое слово владельца «А».

ПРЕДМЕТ И ПОРОГ. Судил закоммиченный HEAD, не проект реализации: предмет и И-3/И-5/И-6/И-6а `contracts/146-shablon-dvizhenie.md:40-48`, исполнимый критерий `:51-79`, названные `ЗОНА architect/implementer/orchestrator` и границы `:80-89`, модель угроз `:174-190`, класс риска «обычный». Из `git diff 5d1f6062^ 5d1f6062` — 60 файлов, все только `contracts/146-*` и `fixtures/workshop_project/shablon_dvizhenie_146/`, вне зоны architect 0; фактический родитель 3044a51edaac30ecb72f986a478f5c620f690147. Единственная реализационная сдача implementer — дословно портировать весь model-файл в `scripts/ekran_shablon.py`; byte-pin и красный W до порта не позволяют принять одну заглушку. Источники тройного пина, реальные адреса, обе стороны полноты и отказы по именам определены; решения о связях stab→вход остаются в коде architect (Н-39), а не в прозе контракта. `КЛАСС РИСКА: обычный` соответствует валидатору локальных файлов, не полномочиям, деньгам, ПД или юридическим операциям. Названного блокирующего обхода критерия в допустимом входе после дельты не получил.

ЗАКРЫТИЕ Crit146c `contracts/146-shablon-dvizhenie.md:45-48,66-68`: три прежних ложно-зелёных усечения атаковал на НЕИЗМЕНЁННЫХ эталоне и ожиданиях, переписан только исполняемый субъект в одноразовой копии `/tmp/dev-harness-verify/Crit146d-attack`. Сырые итоговые строки каждой команды (каждый запуск прогонял все 289 клеток):
```text
$ python3 /tmp/dev-harness-verify/Crit146d-attack.py pin_ends_only 146
BEHAVIOR cells=289 green=286 red=3 seed=146 mode=pin_ends_only
RC=1
$ python3 /tmp/dev-harness-verify/Crit146d-attack.py pin_ends_only 7
BEHAVIOR cells=289 green=286 red=3 seed=7 mode=pin_ends_only
RC=1
$ python3 /tmp/dev-harness-verify/Crit146d-attack.py pin_ends_only 999
BEHAVIOR cells=289 green=286 red=3 seed=999 mode=pin_ends_only
RC=1
RED_CASES: etalon-pin-1-ne-hex, etalon-pin-2-ne-hex, etalon-pin-3-ne-hex
$ python3 /tmp/dev-harness-verify/Crit146d-attack.py missing_scene_fallback 146
BEHAVIOR cells=289 green=283 red=6 seed=146 mode=missing_scene_fallback
RC=1
$ python3 /tmp/dev-harness-verify/Crit146d-attack.py missing_scene_fallback 7
BEHAVIOR cells=289 green=283 red=6 seed=7 mode=missing_scene_fallback
RC=1
$ python3 /tmp/dev-harness-verify/Crit146d-attack.py missing_scene_fallback 999
BEHAVIOR cells=289 green=283 red=6 seed=999 mode=missing_scene_fallback
RC=1
RED_CASES: perehod-bez-specy-ga-t28, perehod-bez-specy-ga-t31, perehod-bez-specy-ga-t29, perehod-bez-specy-ga-t35, perehod-bez-specy-ga-t36, perehody-bez-specy-vse
$ python3 /tmp/dev-harness-verify/Crit146d-attack.py omitted_reduced_duration_default 146
BEHAVIOR cells=289 green=288 red=1 seed=146 mode=omitted_reduced_duration_default
RC=1
$ python3 /tmp/dev-harness-verify/Crit146d-attack.py omitted_reduced_duration_default 7
BEHAVIOR cells=289 green=288 red=1 seed=7 mode=omitted_reduced_duration_default
RC=1
$ python3 /tmp/dev-harness-verify/Crit146d-attack.py omitted_reduced_duration_default 999
BEHAVIOR cells=289 green=288 red=1 seed=999 mode=omitted_reduced_duration_default
RC=1
RED_CASES: pole-treka-udaleno-reduced_duration_ms
```
Промежуточные индексы 1/2/3 из всех пяти, все пять обязательных pid и физическое отсутствие поля с именем теперь отличаются поведением; прежние 125/125 зелёных мутантов больше не проходят. Сравнивались причины и адреса, не только rc либо SHA файла.

ДРУГИЕ ОБМАННЫЕ СУБЪЕКТЫ. Команды на том же независимом исполняемом субъекте и сырые итоги:
```text
$ python3 /tmp/dev-harness-verify/Crit146d-attack.py skip_spec_byte_pin 146
BEHAVIOR cells=289 green=288 red=1 seed=146 mode=skip_spec_byte_pin
RC=1
RED_CASES: istochnik-piny-spec
$ python3 /tmp/dev-harness-verify/Crit146d-attack.py skip_anchor_screen_completeness 146
BEHAVIOR cells=289 green=284 red=5 seed=146 mode=skip_anchor_screen_completeness
RC=1
RED_CASES: ekrany-vne-manifesta, ekran-bez-kadrov, ekrany-ne-polny-ga-01, ekrany-ne-polny-ga-15, ekrany-ne-polny-ga-16
$ python3 /tmp/dev-harness-verify/Crit146d-attack.py skip_report_digest_freshness 146
BEHAVIOR cells=289 green=288 red=1 seed=146 mode=skip_report_digest_freshness
RC=1
RED_CASES: otchet-te-zhe-bajty
$ python3 -c 'from pathlib import Path;exec(compile(Path("/tmp/dev-harness-verify/Crit146c-attack-run.py").read_text().replace("Crit146c-attack","Crit146d-attack"),"prior-attack-run.py","exec"))' old 146
BEHAVIOR cells=289 green=192 red=97 seed=146 mode=old
RC=1
$ python3 -c 'from pathlib import Path;exec(compile(Path("/tmp/dev-harness-verify/Crit146c-attack-run.py").read_text().replace("Crit146c-attack","Crit146d-attack"),"prior-attack-run.py","exec"))' first_track 146
BEHAVIOR cells=289 green=281 red=8 seed=146 mode=first_track
RC=1
RED_CASES: pruzhina-v-spetse, krivaya-vne-kanona, krivaya-imja-vne-kanona-vse-treki, krivaya-znachenie-vne-tokena-vse-treki, pruzhina-na-kazhdom-treke, pole-treka-pustoe-curve, pole-treka-chuzhoj-curve, pole-treka-chuzhoj-spring
```
Для двух последних команд скрипт prior-attack-run.py перенаправлен в одноразовую копию субъекта, печатал индивидуальные CASE; приведены его буквальные итоговые строки (а не заявление об отсутствии иных строк). Сырой контроль матрицы зелёного свидетеля `/tmp/dev-harness-verify/Crit146d-green-witness.py`: `chestnyj-d24-ekran expected_rc0 actual_rc0 problems[]`; на законной перестановке `dv.ekrany` — `matrica-dv-ekrany-perestanovka expected_rc0 actual_rc1 problems ['rc=1, ожидался 0', …]`; статическое зелёное ожидание замечает ложный отказ. Проба исключений `/tmp/dev-harness-verify/Crit146d-exclusions.py`: `batareja-empty rc=2 PRICHINA SHABLON_NEVEREN batareja` (красная клетка есть); `operacii-api-empty rc=0 SHABLON OK`, `fiktura-false rc=0`, `zamenjaet-none rc=0`, `etalony-reordered rc=0` — конформные значения/перестановка; `prokhodimost-empty rc=1 traceback=True no PRICHINA` — существующий дефект v2-поля вне нового раздела 146, учётный маршрут 061 назван в `osi.md:91-93`, не ложная зелёная приёмка v3.

БАТАРЕИ, все из клона кандидата, по одной: `bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh --model` и варианты `--model --seed 7`, `--model --seed 999` — каждый rc 0, `клеток 289, зелёных 289, красных 0`; `--stabs` — rc 0, 289/289, `SVJAZI 124`, все 124 `STAB ... KRASEN`; `--stabs --seed 7` — повторно явно rc 0, 289/289 и 124 привязки. Из `source.json`/импорта `probe.py` независимо пересчитано 289 клеток (17 статических положительных, 272 красных, 248 вычислимых), 36 стабов, 124 связи; `KATALOG perehodov=5 trekov=67 vidimyh=36 peremeshchenija=31 semey=114`; `MATRICA polej=31 kletok=93 zelenyh-svidetelej=8 izjatij=50 pokryto=4 pinnyh-indeksov=5`. У каждого из 31 поля есть красная комбинация, классы исключений и зелёных значений объявлены. На исходном v2 `W` rc 1, `клеток 289, зелёных 4, красных 285`, `PORT_NE_DOOSLOVEN: scripts/... sha0285... != model/... shaab26...`; на собственной одноразовой копии с буквальным портом только `scripts/ekran_shablon.py` — rc 0, 289/289, `PORT_DOSLOVEN sha256=ab26d789e7813d403adb160b06131f460ca8082d7d2cc3485673abcaf39b679e`. `W --oracle-tamper` — rc 0, `ORACLE_TAMPER_PROVERENO nositelej=17`. Батарея зависимого 132 `bash fixtures/workshop_project/ekran_shablon_132/red_ekran_shablon_132.sh` — rc 0, 70/70 CASE ok.

РЕАЛЬНЫЕ ИСТОЧНИКИ. На настоящей копии `/tmp/dev-harness-verify/Impl145/mob` команда `W --d24-real /tmp/dev-harness-verify/Impl145/mob` — rc 0, `D24_REAL_PINY realnyj-manifest=OK realnaja-speka=OK realnyj-pozvonok=OK product=e94ec4c07f7c434e471a5a27941f256b1a0d502f model_sha256=ab26d789e7813d403adb160b06131f460ca8082d7d2cc3485673abcaf39b679e`, `D24_REAL ekranov=46 dvizhenija=24 scen_znaka=21 scen_speki=24 trekov=488 tokenov=31`, `D24_REAL_POKRYTIE semey=93 soglasnyh=93 adresnyh-polnoty=OK`, `D24_REAL_ATAKA scen=24 atak=24 otkazov=24 seed=146 pravil=9`, `D24_REAL: ZELEN`. `W --differencial` с тем же путём — rc 0, три версии v1/v2/v3 × обе реальные v1-пачки дали ровно шесть `STATIC_BOUNDARY_REACHED; E2E_NOT_RUN`; `DIFF_V2_FORMA soglasno: rc=0, stdout=3 строк, причин=0`, `DIFF: ZELEN`. Это НЕ живой e2e и не принятие продуктовой v3-пачки 147+.

ДОПУСК И МЕХАНИЗМЫ. `bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Crit146d contracts/146-shablon-dvizhenie.md` — rc 0, `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3`, `КРИТИК: дверь зелёная`; `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Crit146d contracts/146-shablon-dvizhenie.md` — rc 0, `OK`; `bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Crit146d contracts/146-shablon-dvizhenie.md` — rc 0, `OK`; `check_ceilings.sh` — rc 0, `потолки в порядке`; `check_threat_model.sh` — rc 0, `ЗАЩИЩАЕТ 9`, `НЕ ЗАЩИЩАЕТ 7`; `check_predposylki.sh` — rc 0, settings=3; `check_contract_frozen.sh` — rc 0, `планов и контрактов на HEAD: 144 · черновиков: 4 · заморожено: 140 · реестр: full`. Последней проверкой `bash scripts/check_zones.sh /tmp/dev-harness-verify/Crit146d` (через subprocess с явным timeout 1200, дождался фонового `[async-result]`) — rc 0, сырой конец: `замороженных контрактов: 142 · объявленных авторов: 5 · коммитов в диапазонах: 37762 · проверено по зонам: 8470`; напечатано `RC 0`.

Независимость по доступному трейсу: `bash scripts/models_actual.sh --tsv --bind` вывел `critic-sol openai-codex/gpt-6-sol allowed Crit146d 5d1f60620bc4ef60ebaf6ba845e2a0f9690f3890` и `architect zai/glm-5.3 allowed Fix146d -` (обе строки по два раза); глобальный скан старых сессий завершился rc 2 `NOT_IMPLEMENTED: session-id вне алфавита [A-Za-z0-9._-]: Arbiter079Б1` — это историческая иная сессия, не ошибка строк Fix146d/Crit146d. Авторство будущего коммита вердикта — critic.

СОВЕТ contracts/146-shablon-dvizhenie.md:206 — в описательной сдаче назван родитель `073e29290`, хотя фактический родитель OBJECT — `3044a51ed`; при следующем обновлении исторической записи указывать действительный SHA. Это не приёмочный критерий и не меняет вывод батарей.

C.12: текст `contracts/146-shablon-dvizhenie.md:204-205` честно говорит, что диагностический CI для нового SHA не выполнялся; его зелень НЕ приписываю нынешнему OBJECT. Живой CI диагностического PR #143, run 40972809292 выполнялся на предыдущем кандидате f819bea3, рецепт признан консультантом; слово владельца в задании на этот один scoped-критик прямо освобождает от повторного живого CI после изменения модельного SHA на ab26d789. Сверка реальных данных на 488 треках, статической границы обеих реальных v1-пачек на трёх версиях, v2-формы и регресс 132 подтверждают затронутый участок в пределах этого исключения. Приписывать новому SHA результат старого CI запрещено; выполнение будущего CI/проводки остаётся оркестратору по владельческому маршруту.

НЕ ПРОВЕРЕНО лично: полный живой quality/android-e2e/Jest/Maestro на кандидате 5d1f6062 и экран в эмуляторе, байты внешних Release PNG/MP4, продуктовые пачки 147+, все дальнейшие реализации implementer/orchestrator; не утверждаю полное динамическое тождество v2/v3 за статической границей. Origin не коммитился и не пушился; мутации и буквальный порт оставлены в одноразовых копиях вне дерева кандидата.
