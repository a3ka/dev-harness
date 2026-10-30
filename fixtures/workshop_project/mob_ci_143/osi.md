# Оси батареи 143 (mob-ci-razdelenie) — 78 клеток (v2: 71 клетка дерева
# после Fix143e + 7 клеток I-оси расширения по вердикту Astra
# mob-ekrannye-job-astra-v1.md §2 и слову владельца 2026-10-30 ~11:40 UTC;
# история: v3 арбитража Б1–Б4 — 69 клеток, y23/y24 Rev143 — 71)

Субъекты: `.github/workflows/mobile.yml` (DAG), `mobile/ci-screens.json` (карта),
`mobile/scripts/select-ci-screens.cjs` (селектор, v2: + режим `--mode
inventar` без diff/выбора), `mobile/scripts/ci-aggregate.cjs`
(агрегат), отсутствие `.github/workflows/mobile-e2e-retry.yml`. Режимы раннера
`red_mob_ci_143.sh`: без флага → SUBJECT_ABSENT; `--repo R` → живой продукт;
`--model` → эталоны; `--stabs` → + матрица обманных стабов (60). Оракул
`source.json` в памяти ДО вызова субъекта; ожидания S-оси строит независимый
python-канон `probe.py:kanon_vybor` (субъект-.cjs не исполняется для
ожиданий); v2: перечень работников общих обязательств — ИЗ КАРТЫ СУБЪЕКТА
(`rabotniki_subiekta`), не python-константа; неизменная legacy-опора
(пять работников frozen 143/1) судится i07 отдельно. Пины sha256 22
(13: 5 файлов model/ — mobile.yml, ci-screens.json, select-ci-screens.cjs,
ci-aggregate.cjs, screen-job.template.yml (лекало, v2) + 5 живых носителей
API/workflow + 3 носителя P/S — байты P v5 (nositeli/p-4ac99af9.py),
pilot.yaml, ci-e2e.sh; + 9 черновиков drafts/*.md — перепись zhestkij_kanon
ДО клеток, арбитраж Б4) — `ORACLE_TAMPERED` rc 2. Retired байты 66052cdf
(frozen 995/4, rglob) — НЕ пин: встроенная полезная нагрузка красной ветви
p01/стаба (stabs/p-66052cdf.py, вне glob stab_*.py — census stabs не
трогает), целостность кодовой константой probe.py (RETIRED_SHA256) —
порча/удаление = rc 2 `ORACLE_TAMPERED` ДО клеток.


## S — селектор (поведение, replay подложными git/gh; 25 клеток)

s01 общий код → полный набор · s02 локальный файл → один экран (негативная
пара) · s03 новый pack → INVENTAR · s04 новый флоу → INVENTAR · s05 флоу двух
владельцев → INVENTAR · s06 сужение glob в PR → POLICY_CHANGE полный · s07
снятие статуса → POLICY_CHANGE · s08 удаление записи → POLICY_CHANGE · s09
rename внутри · s10 rename вне карты → UNKNOWN_PATH полный · s11 delete ·
s12 пробел в имени · s13 Unicode · s14 перевод строки · s15 type-change ·
s16 нет базы → NET_BAZY · s17 усечение страницы API → USECHENIE_API (живая
неполная страница PR #124) · s18 ошибка diff → OSIBKA_DIFFA · s19 схема карты
→ SKHEMA_KARTY · s20 пустой реестр → PUSTOJ_REESTR · s21 docs-only →
EMPTY_SELECTION_FALLBACK полный · s22 schedule → FULL_SET_REZHIM · s23 push
before→after · s24 gh-api fallback на живом files-ответе PR #124 → COMMON ·
s25 merge_group.

## A — агрегат (поведение; 17 клеток)

a01 пустой selected → PUSTOJ_NABOR · a02 выбранный вне реестра → VNE_REESTRA ·
a03 skip выбранного · a04 cancelled · a05 timeout · a06 failure · a07 селектор
упал · a08 сборка упала · a09 quality упала · a10 чужой digest →
APK_DIGEST_RASKHOZHDENIE · a11 старый артефакт → STARYJ_ARTEFAKT · a12 лишний
зелёный работник → LISHNIJ_RABOTNIK · a13 skip без причины → SKIP_BEZ_PRICHINY ·
a14 исключённый объяснён (зелёная пара) · a15 отмена одного из двух · a16
пустой needs → PUSTOJ_NEEDS · a17 digest ДО установки — ИСПОЛНИТЕЛЬНЫЙ
replay шагов работника с подложным APK иного digest в замкнутом PATH
(подложные gh run download/adb/emulator/avdmanager/maestro): у каждого из
пяти работников шаг digest обязан упасть rc≠0 с именем
APK_DIGEST_RASKHOZHDENIE, полная цепочка e2e-start обязана ОСТАНОВИТЬСЯ до
adb install (в логе подложного adb нет USTANOVLEN) — блокер 1: присутствие
маркера в YAML ничего не доказывает, мутант `if false && …` ставил подложный
APK и проходил 63/63.

## Y — DAG mobile.yml (статика; 24 клетки: 22 frozen 143/1 + y23/y24 Rev143)

y01 набор задач · y02 needs агрегата · y03 if: always() · y04 нет if:false ·
y05 нет continue-on-error · y06 нет strategy · y07 канонические условия
работников · y08 таймауты · y09 события + paths-фильтр + workflow_run +
mobile-e2e-retry.yml жив · y10 пул раннеров · y11 APK-идентичность (артефакт
по имени из outputs, digest до установки) · y12 AVD/порты namespace, запрет
широких pkill · y13 ровно один уровень восстановления на экран · y14 same-job
Jest 118 · y15 H-checkoutы (включая .harness123 у 135/118) · y16 селектор
знает schedule · y17 ночь — сигнал, не required · y18 маркер полной регрессии.
y19 провода outputs (id: ident у шага идентичности каждого работника,
job-level outputs ровно три ключа из steps.ident, checkout c
persist-credentials: false в ОБОИХ агрегирующих задачах ДО запуска
ci-aggregate.cjs — блокер 3) · y20 toJSON(needs) семантикой ГитХаба
(needs-контекст строится ПО workflow-субъекту: шаг идентичности
ИСПОЛНЯЕТСЯ, outputs без id рендерятся пустыми — и подаётся в НАСТОЯЩИЙ
агрегат: зелёный required возможен только при честной проводке — блокер 3)
y21 concurrency (PR-группа mobile-pr-N с cancel только pull_request; ночь и
диспетч — отдельные группы без отмены; закрытый алфавит выражений,
мутант cancel:false красен — блокер 4; отличие от живого #124
`mobile-<ref>`+безусловный cancel — ночь не отменяется пушами).
y22 needs работников (арбитраж Б2): needs каждого из пяти — РОВНО
[select-screens, build-apk], соседний работник в needs красен; рендер
needs.<job>.outputs.* — только для job ∈ needs задачи (семантика ГитХаба):
шаг digest/идентичности без ребра к сборке красен РЕНДЕР_ВНЕ_АЛФАВИТА,
a17/y20 ловят тот же мутант исполнением (стаб y_bez_build_apk).

## F — карта (статика; 4 клетки)

f01 фиксированный набор P (замкнутый перечень) · f02 владение потоками без
двойного владельца · f03 паки в карте · f04 статусы + in-development обязан
иметь исполняемый вход.

## I — инвентарь/расширение (v2, Astra §2; 7 клеток)

i01 inventar-dereva — ИСПОЛНИТЕЛЬНАЯ: режим `--mode inventar` селектора
субъекта на синтетических деревьях; честное дерево → rc 0 + PACHKA-строки
и inventar.json ровно по карте; пачка без записи → PACHKA_BEZ_REGISTRACII;
запись без пачки/флоу → ZAPIS_BEZ_VHODA; symlink-пачка → SYMLINK_PACHKI;
флоу без владельца (не служебный sluzhebnye_potoki) → POTOK_BEZ_REGISTRACII;
имена проб свободны от регистра субъекта (расширение может зваться vkladki) ·
i02 jobs-iz-karty — jobs(workflow) == 5 служебных ∪ работники карты
(job без карты / карта без job — именованные расхождения) ·
i03 vyhody-selektora — outputs(select-screens) == {selection} ∪ работники
карты, каждый из steps.vybor · i04 agregaty-iz-karty — needs ОБОИХ
агрегатов (required android-e2e и ночной mobile-regression-signal) ==
{select-screens, quality, build-apk} ∪ работники карты ·
i05 vynos-iz-inventarja — вынос пачек quality ОБЩИЙ: один вызов
--mode inventar до перемещения, перенос ровно PACHKA-строк; персональный
mv пачки (v1) и wildcard — именованные отказы; H-checkoutы и спец-проба
118 явные; npm test/lint/typecheck/doctor после выноса ·
i06 lekalo-rabotnika — лекало model/screen-job.template.yml (файл ПАЧКИ,
пин sha256 в source.json:.piny): параметры {{JOB_ID}}/{{SCREEN_ID}}/
{{PACK}}/{{FLOWS}}/{{H_REF}}/{{H_PATH}}/{{AVD_PORT}}/{{EVIDENCE_NS}},
запреты continue-on-error:/strategy:/matrix:, ни одного имени
legacy-экрана (второго списка экранов нет), ровно один «ПОВТОР: » в теле;
ИНСТАНЦИАЦИЯ экраном-пробой + три парные правки (карта, output, needs×2)
→ работник конформен ВСЕМ общим обязательствам (y01–y12/y19/y22/y24,
i02–i04) — порт пробы свободен от занятых субъектом; расширяемость
доказана исполнением на каждом прогоне · i07 legacy-opora — пять
работников frozen 143/1 остаются в карте И в DAG (согласованное удаление
— НЕ новый честный baseline; снятие экрана — решение владельца).

## Стабы (60, привязки 76; мутации моделей КОДОМ, Н-39)

bez_obschego (s01,s24) · belyj_spisok_imen (s12,s13) · tihoe_iskljuchenie
(s03,s04,s05) · pustoj_uspeh (s21) · oshibka_kak_pustota (s16,s18) ·
karta_base_ignoriruet (s06,s07,s08) · rezhim_polnyj_udalen (s22) ·
agregat_echo (a01,a03,a06,a07,a10,a12) · agregat_pustoj_needs_zelen (a16) ·
digest_ne_sverjaet (a10,a11) · skip_bez_prichiny_propuskaet (a13) · y_if_false
(y04,y07) · y_continue_on_error (y05) · y_bez_agregat_needs (y02) · y_bez_always
(y03) · y_strategija (y06) · y_udalen_cron (y09) · y_noch_vyborochnaja (y17) ·
y_artefakt_po_attempt (y11) · y_jest_udalen (y14) · y_bez_h123_118 (y15) ·
y_vtoroj_povtor (y13) · y_pkill_shirokij (y12) · y_marker_udalen (y18) ·
y_139_zhiv (y09) · f_P_vkljuchaet_ekran (f01,f02) · f_bez_vhoda (f04) ·
digest_mjortvaja_vetka (a17 — мутант критика `if false && …` во всех пяти
работниках: шаг digest исполняется и ПРОХОДИТ, подложный APK ставится) ·
p_rglob_kataloga (p01 — атака двойного checkout вердикта критика 1/2:
измеренный checkout 4ac99af9 сохранён, после него до запуска P вставлен
второй checkout того же path с retired пином 66052cdf; эффективный =
последний до запуска = retired, replay старых байтов запрашивает весь
каталог — клетка обязана покраснеть исполнением) ·
y_agregat_bez_checkout (y19) · y_ident_bez_id (y20) · y_cancel_vyklyuchen (y21) ·
y_bez_build_apk (y22,a17 — арбитраж Б2: все пять работников теряют ребро
build-apk; статика y22 + рендер a17 — тот же мутант красит и y20).

Стабы I-оси (v2): i_inventar_pustoj_uspeh (i01 — незарегистрированная пачка
молча входит в перечень, rc 0; класс живого отказа Complior-mob#144 «file
outside allowed location») · i_inventar_bez_dereva (i01 — записи карты
деревом не сверяются, ZAPIS_BEZ_VHODA нет) · i_vyhody_bez_rabotnika (i03 —
output работника не объявлен, экран молча не выбирается) ·
i_signal_bez_rabotnika (i04 — работник в needs PR-агрегата, но НЕ ночного
signal: два списка правятся руками и разошлись) · i_vynos_vruchnuju (i05 —
quality возвращён к v1-форме: персональные mv двух пачек без
инвентаризации) · i_udalen_ekran (i07 — СОГЛАСОВАННОЕ удаление legacy-экрана
splash из карты И DAG: все динамические проверки v2 сходятся на четырёх
работниках — ловит только legacy-опора) · i_karta_bez_joba (i02 — запись
карты без job: пачка «подключена», CI зелёный, экран не исполняется) ·
i_job_bez_karty (i02 — явный job в DAG без записи карты: вне инвентаря и
владения). Лекало стабов не требует: файл пачки под пином sha256 — мутация
байтов = rc 2 ORACLE_TAMPERED до клеток (прецедент переписи черновиков Б4).

## P — исполняемый набор P (1 клетка; АКТИВНА после перепина 995/5)

p01-P-nabor: ИСПОЛНИТЕЛЬНЫЙ replay цепочки e2e-pilot — носитель P по
ЭФФЕКТИВНОМУ пину .harness из P_IZ_PINA. П1 (арбитраж 143-repin): по ВСЕМ
задачам число шагов, чей run содержит литерал maestro_probe.py, РОВНО 1 и
он в e2e-pilot (И-8); иначе клетка красна именованной причиной со списком
job[индекс-шага] — второй запуск P (в e2e-pilot после первого или в другой
задаче) красен; ноль запусков — именованный отказ «P не исполняется этим
workflow» (fail-closed). П2: в шагах checkout ДО запуска P path
сопоставляется по posixpath.normpath == '.harness' (алиасы ./.harness и
.harness/ — тот же каталог); нелитеральный path (содержит ${{, абсолютный,
normpath начинается с '..') — красна «путь checkout неизмерим: <path>»
(fail-closed). Эффективный пин — ПОСЛЕДНИЙ checkout каталога .harness ДО
шага запуска maestro_probe.py (дубль path судится последним —
actions/checkout перезаписывает каталог, содержимое .harness при запуске P
задаёт последний checkout; checkout после запуска P не влияет; вердикт
критика 1/2 — атака двойного checkout) — 4ac99af9 → nositeli/p-4ac99af9.py
v5: набор из manifest; 66052cdf → stabs/p-66052cdf.py rglob
(retired-нагрузка, не пин) → носитель S (ci-e2e.sh 995/4, 0fa425b5) →
подложный maestro (логирует argv; каталог раскрывается в перечень флоу; в
песочнице лежит и КАРТА СУБЪЕКТА mobile/ci-screens.json — P v5 читает
набор из manifest, без карты replay ложно красен). Оракул: запрошен РОВНО
фиксированный набор P (pilot/start/rehearsal/tabs, каждый раз) при .maestro
со флоу всех экранов. Модель перепинена на 4ac99af9 (freeze 995/5, ленд
ffbbc99e7): клетка зелена на живой модели. Retired пин 66052cdf — КРАСНАЯ
ветка исполнением (replay старых байтов: Maestro запрошен весь каталог,
8 флоу); неизмеренный пин — красная именованная причина (батарея отвечает
только за пины, чьи байты пинует); стаб p_rglob_kataloga повторяет атаку
критика (двойной checkout «хороший, затем плохой» → эффективно retired →
красно исполнением); «плохой, затем хороший» оставляет эффективным
хороший — клетка зелена: измерается реальность, а не первый ref.
НЕ ЗАЩИЩАЕТ (остаток арбитража 143-repin; ловцы — ревью cutover-PR со
сверкой байтов с моделью (§Порядок п.2), адверсарий, живая приёмка п.4):
запуск P без литерала maestro_probe.py в run (env-косвенность, обёртка,
composite/reusable — замер «second P via env var path» rc 0), перезапись
.harness shell-командами в run (rm/cp/git clone/curl) или действиями вне
actions/checkout, живая семантика платформы (needs/if/concurrency);
полное отсутствие литерала — уже fail-closed (замер «literal hidden» →
красна).
