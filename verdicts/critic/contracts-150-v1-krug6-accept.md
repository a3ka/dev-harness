accept
OBJECT=1cd86253d6e1ccf5e7fd1a12c14cc45389acb404
СУД: repo=dev-harness; предмет=150; фаза=контракт (до заморозки); роль=critic; вызов=6 (ОДИН scoped-вызов по слову владельца 2026-11-12: «регресс krug3–5 + живые приёмки 7/8»; при FAIL седьмого нет — вопрос консультанту); модель-план=тир apex-sol (openai-codex/gpt-6.1-sol — по config/agent_models.json); сессия=Crit150V6; модель-факт=zai/glm-5.3 (расхождение с назначением apex-sol названо; совпадение семейства с автором отказа не даёт, контракт 166; решение о материализации — за оркестратором по §Независимость, автофолбек не скрывается); SHA=1cd86253d6; предыдущий=verdicts/critic/contracts-150-v1-krug1…krug5-fail.md + verdicts/arbitration/contracts-150-arbitraz.md + verdicts/consultant/n-150-z05-vyzov5-fail-reshenie-klass-v1.md; исключение=слово владельца 2026-11-12.

# Критик — контракт 150, вызов 6 (scoped: замена симуляции Actions закрытым каноном; регресс krug1–5 + живые приёмки 7/8)

Предмет: коммит 1cd86253d6 (architect, 33 файла +1791/−525: contracts/150-prichinnyy-zamer-obryva.md + fixtures/workshop_project/obryv_zamer_150/). Судился в одноразовом SSH-клоне `/tmp/dev-harness-verify/Crit150V6/repo` (checkout OBJECT, `git cat-file -t` → commit), правок репо автора, GIT_DIR/GIT_WORK_TREE и push нет; identity owner не создавалась. Полный набор артефактов есть: предмет, критерий готовности rc-командами, исполнители, ЗОНА-строки; КЛАСС РИСКА: рисковый — безопасность (:3, с основанием frozen 995/5); ПРОВОДКА-ЭНФОРСМЕНТ (:182) — чистый энфорсмент guard-каналом; модель угроз валидна (check_threat_model rc 0, ЗАЩИЩАЕТ 8 / НЕ ЗАЩИЩАЕТ 9).

## 1. Регресс krug1–5 — каждый блок закрыт, мера ДРУГАЯ (правило 4)

Старый распознаватель shell-ветвлений удалён из probe.py целиком (grep `_shell_komandy|SBOR_NE_BEZUSLOVEN|NABLJUDENIE_PUSTO|SBOR_RUN_NE_RASPOZNAN` — 0 вхождений): симуляция семантики Actions заменена байтовым каноном z05 (`KANON_150_*`, первое отличие с адресом строки) и исполнительными оракулами результата z06/z07 (`SBOR_150_RESULT_NET`/`HUK_*` по реальным файлам). Живые прогоны:

- `W --stabs` → rc 0, **SVJAZI 37, все 37 KRASEN, STAB_ZHIV 0**, контроль модели молчаливо зелёный (wall 190.7 s). Круг 3 П1 (`true ||` — uslovnyj_sbor), круг 4 (`true ||`+перенос — operator_novaja_stroka), круг 5 Б1а/б/в/г (`false | true ||` — konvejer_false_true; `shell: true {0}` — shell_true → `KANON_150_SHELL`; `if: ${{ always() && false }}` — if_vsegda_i_lozh → `KANON_150_IF`; шаг без cwd при root defaults mobile — bez_wd → `KANON_150_CWD`) и Б2 (`sbor_bez_rezultata` → z06 `SBOR_150_RC=2`; `hook_bez_sbora` → z07 `SBOR_150_RESULT_NET`) — все красны НОВОЙ мерой у второй единицы/в матрице, не повтором прежней команды.
- Круг 3 П2 (ZP): живые режимы через ВНЕШНИЙ gh-двойник в PATH при `Z150_MOK=/nonexistent`: `zelenyj` → rc 0 `ZP_ZELENYJ_OK`, `krasnyj` → rc 0 `ZP_KRASNYJ_OK` (+обязательная строка отчёту ревью) — mock-переменная не влияет (блок 2 закрыт); ответ artifacts API 0 байт rc 0 → `PUSTOJ_OTVET_API` rc 1 (блок 3); `dlitelnosti` 4 аргумента → rc 0, ОБА run с числовой длительностью (420s/420s), 3 аргумента → rc 1 `ARGUMENTY` (блок 4/П2-5); дублированный job → `JOB_DUBLIR` rc 1; зелёный run без артефактов по валидному пустому массиву → rc 0. `--samoproverka` → rc 0 `sluchaev 11, sovpalo 11` (включая PUSTOJ_OTVET_API-случай).
- Круг 1 (8 блоков, закрыты с круга 2): класс риска (:3) ✓; форма модели угроз ✓; exit/logcat до остановки — b04/b06 (стабы bez_exit/bez_kolca KRASEN) ✓; RECOVERED 995 — b11 + arhiv_soblaznjaet ✓; PEM-тело — b07 + pem_tolko_begin (`SEKRET_UTEK: PEM`) ✓; путь upload по каждому работнику — теперь байтовый канон z05 над КАЖДОЙ единицей (`for e in edinicy`, probe.py:412+) + стабы put_zagruzki/kommentarij_sbor ✓; потолок b08 + bez_predela ✓; гигиена b12 + techet_procesom (`PODDELKI_ZHIVY`) ✓. Круг 2 (второй работник, комментарий-приманка) — z05 судит все единицы, kommentarij_sbor → `KANON_150_RUN` ✓. Арбитражные П1/П2 закрыты названным, П3-граница exit дословно в «РЕШЕНО ВЛАДЕЛЬЦЕМ 2026-10-31» и НЕ ЗАЩИЩАЕТ (слово владельца 31.10 приложено).

## 2. Охват S2 §1.3 — по всем пяти точкам

start (канон-шаги F1/F2 «запуск сэмплера» судимы байтами), управляющее окружение (явные shell/working-directory/закрытое env, `KANON_150_SHELL/IF/CWD/ENV/KEYS`, z03: continue-on-error шаг/_job_, if:always, порядок «старт<экран<сбор»), все работники (един coverage = записи карты+integracija, матричные записи НЕ схлопываются — проверено мутантом ниже), матричный child (M-шаблон артефакт-шага + ТРИ канон-строки хука в раннере по child-hook-vyzovy.txt + z07 исполняет хук КАЖДОГО child, включая второго: matrica_bez_porta_vtorogo красна у `proba-matrica-dva`), совместимость 163 (F2 `npm run ci:zamer`, package.json-пин, закрытый словарь lanes без eval — kanon/lane-zamer.txt; lane_neprivjazan и мой eval-мутант → `KANON_150_LANE`). Мутант job-defaults честно ЗЕЛЁН — проверен мною лично, соответствует объявленной границе («нормальный продукт — не злонамеренная мутация»).

## 3. Собственные мутации (одноразовые копии model/, суд `W --repo`, 9 атак + 2 честных контроля)

```
m_probel_v_rune        rc 1 z05 KANON_150_RUN (хвостовой пробел в run сбора 2-го работника)
m_shell_javyj_shablon  rc 1 z05 KANON_150_SHELL: stroka 2: 'shell: bash' != 'shell: bash --noprofile --norc -eo pipefail {0}'
m_start_posle_sbora    rc 1 z03: start позже sbor; между startom i sborom net ekrannogo shaga
m_tretij_child         rc 0 — ЧЕСТНЫЙ контроль: третий канонический child судится отдельно, ложной красноты нет
m_huk_dubl             rc 1 z05 KANON_150_MATRICA: vyzov huka sbor vstrechen 2 raz (kanon: 1) — у ОБОИХ child
m_pryamoj_maestro      rc 1 z05 KANON_150_MATRICA: huka maestro 0 raz + prjamoj vyzov maestro mimo huka
m_job_defaults_shell   rc 0 — ЧЕСТНЫЙ контроль: job-level defaults не меняют семантику шагов замера
m_yaml_alias           rc 1 z05 KANON_150_YAML: alias *zamer_env_drugoj — vne kanona
m_serial_ne_po_portu   rc 1 z02: ZAMER_SERIAL 'emulator-9999' != emulator-PORT(5571)
m_sbor_bez_env         rc 1 z02: ZAMER_EKRAN/NS/SERIAL None != karte
m_lane_eval            rc 1 z05 KANON_150_LANE: kanonicheskaja stroka slovarja lanes vstrechena 0 raz
```
Нарушений нет: каждая атака красна именованной причиной у своей единицы, честные формы зелёны.

## 4. САМООПИСАНИЕ (все счётные утверждения перемерены живыми источниками)

Расхождений нет: клеток 19 (`grep -cE '^\| (z0[0-9]|b[01][0-9])-' osi.md` = 19; `KLETKI` = 19); `--model` → rc 0 `ZELENO: клеток 19, зелёных 19` (также `--seed 7`); безфлаговый → rc 1 `KRASNO: клеток 19, красных 19` + `SUBJECT_ABSENT` поимённо (z04 — ZAMER_SKRIPT_NET); `--oracle-tamper` → rc 0 `nositelej=9` (`jq '.piny|length'` = 9); стабов 37 = census = `.stab_vhod` 37 (дрейфа нет — zhestkij_kanon сверяет список с диском); `--repo mob_ci_143/model` → rc 1 `KRASNO: клеток 19, красных 15` поимённо ровно как в Сдаче (z01 «bez shaga» по каждому×3, z04, z05 KANON_150_KEYS, z06 SBOR_SHAG_NET/PORT_RABOTNIKA_NET, b01–b11 ZAMER_NET_OBERTKI: e2e-splash; z02/z03 зелены пустым входом, z07 «детей нет», b12 зелена); samoproverka 11/11; гигиена после всех прогонов `ps -eo cmd | grep -c '[z]150mir'` → 0.

Гейты (клон OBJECT): `pre_critic.sh --repo <клон> contracts/150-…` → rc 0 «КРИТИК: дверь зелёная» (PREDPOSYLKI_OK settings=3, precision 043 rc 0, threat-model 041 rc 0, Н-39 проза-привязок нет — привязки только `source.json:.stab_vhod`, контракт пар «стаб↔ветвь» не несёт: инварианты И-1…И-7 + rc-команды, перечень вход/причина отнесён к osi.md батареи); `check_provodka.sh` → rc 1 «guard не подключён» — заявлено ожидаемым до проводки оркестратора в окне freeze..done (ЗОНА orchestrator, норма 038, прецедент 143).

## СОВЕТ

- СОВЕТ probe.py:515 — первое отличие для шага F2-формы считается сперва против F1-шаблона (`_pervoe_rashozhdenie(r1, fakt) or …(r2, fakt)`): мутант с хвостовым пробелом в npm-run сборе получил диагноз `kanon 'bash mobile/scripts/zamer_obryva.sh sbor \' != fakt 'npm run ci:zamer -- sbor \\'` — отказ истинный и адресный (шаг/строка верны), но «канон» цитируется чужой формы; выбирающий базу по точному совпадению больших кусков (или сверяющий F2-шаг сперва с F2) уберёт ложный указатель направления правки.
- СОВЕТ osi.md (границы честности) — там, где перечислены inter-contract входы 143/163, стоит одной строкой назвать и «работник workflow вне карты» (экран, влитый без записи карты, батареей 150 не судится — держит 143); сейчас это выводимо только из Демаркации.

## Что НЕ проверено

Живой GitHub Actions и продукт Complior-mob не запускались: реализация (`zamer_obryva.sh`, `zamer_child_hook.sh`, обёртка в mobile.yml) — зона implementer ПОСЛЕ freeze; живые приёмки 7/8 настоящим gh — обязательство до done (процедура проверена внешним двойником gh в PATH). Полное поведение пиннованного скрипта судится его b-клетками на модели (исполнение реализацией байт-в-байт обеспечит z04). `check_zones.sh` полный (~7 мин) не гонялся: зоны этой дельты не менялись против проверенных кругов 4–5, новые ЗОНА/ПЕРЕСЕЧЕНИЕ-строки прошли precision-гейт rc 0; полный прогон — обязанность CI/оркестратора до freeze.

## Маршрут

Блокирующих находок нет: каждый закрытый класс krug1–5 закрыт клеткой с другой мерой и живым прогоном, охват S2 §1.3 полный, приёмки 7/8 исполняемы и неимитируемы, самоописание совпадает. По классу риска «рисковый — безопасность» далее независимый adversary ДО ревьюера, затем freeze 150/1; живые приёмки 7/8 и проводка CI — обязательства до done. Приемочная база для последующих судов: `--stabs` до ленда, безфлаговый `--repo` после.
