FAIL
OBJECT=aeac8b1b6613b79ccf867f8432e876ed6ccfaf5b
СУД: repo=dev-harness; предмет=995; фаза=контракт v5 (адресная по 143, правка по вердикту); роль=critic; вызов=2/2 (scoped: только блокер flows-фильтра); модель-план=роль critic; сессия=Crit995b; модель-факт=openai-codex/gpt-6-sol; SHA=aeac8b1b6613b79ccf867f8432e876ed6ccfaf5b; предыдущий=contracts-995-v5-krug1-fail FAIL; исключение=нет

БЛОКИРУЕТ contracts/995-cmp-mob-001-android-pilot.md:54,260 — новая проверка полноты JUnit не доказывает исполнение четырёх скопированных флоу: P преобразует четыре ожидаемых имени testcase в `set` и сравнивает с `set` имён отчёта; два разных флоу с одинаковым допустимым `name:` заголовка становятся неразличимы. Это та же причина предыдущего FAIL — СКОПИРОВАННОЕ ≠ ИСПОЛНЕННОЕ, теперь через коллизию именованного свидетельства, которую новая ветвь полноты не закрывает. Класс причины: ложная достаточность критерия исполнения фиксированного набора на достижимом состоянии продукта.
ОБХОД: изменить в разрешённой implementer-зоне `mobile/.maestro/start.yaml` только поле `name:` на уже существующее `name: 995 synthetic DIRECT entry and restart` у приватного pilot.yaml, сохранить четыре файла набора и штатный `flows: ["*", "!erstinformation.yaml"]`; Maestro пропускает start.yaml без отказа (отдельная ветвь сценария `SCENARIJ_MAESTRO_KATALOG_PROPUSK`, которую контракт:260 прямо требует краснить). Три исполненных testcase с именами pilot/rehearsal/tabs дают `P rc=0`, три testcase в опубликованном report.xml и `MAESTRO_POTOKI cmp-mob-002-tabs.yaml pilot.yaml rehearsal.yaml` без start.yaml, несмотря на требование И-8 и «ровно четыре именованных testcase»; модель и 61/61 красная батарея остаются зелёными. ЗАКРЫВАЮЩЕЕ СВОЙСТВО: при четырёх скопированных флоу отсутствие исполнения любого одного даёт красную публикацию независимо от коллизий `name:`; контрпример с совпадающим заголовком одного пропущенного и одного исполненного флоу должен стать отдельной красной клеткой, а ложный зелёный — красным стабом. Это свойство, не предписание конкретного способа учёта флоу.

АРБИТР: роль arbiter, независимая от architect; предмет спора — допустима ли зелёная публикация трёх testcase при четырёх копиях, когда два имени `name:` совпали, несмотря на требование исполнения РОВНО набора. Это второй FAIL по той же причине, бюджет critic 2/2 исчерпан; арбитраж не является третьим critic-вызовом и сам не даёт accept.

Сырой scoped-прогон собственной атаки (`python3 /tmp/dev-harness-verify/Crit995b/attack_duplicate.py`, rc 0; disposable sandbox P + подложный Maestro берёт имя testcase из заголовка, ничего не меняет в дереве предмета):
```
P rc=0
report=<?xml version="1.0"?>
<testsuites>
<testsuite name="Test Suite" device="ci-775418046-1" attempt="1" rc="0" tests="3" failures="0" time="0.69" timestamp="00:03:05.000">
<testcase id="cmp-mob-002-tabs.yaml" name="cmp-mob-002-tabs.yaml" classname="cmp-mob-002-tabs.yaml" file=".maestro/potok-1.yaml" time="1.1" timestamp="00:03:05.000" status="SUCCESS"/>
<testcase id="995 synthetic DIRECT entry and restart" name="995 synthetic DIRECT entry and restart" classname="995 synthetic DIRECT entry and restart" file=".maestro/potok-2.yaml" time="1.1" timestamp="00:03:05.000" status="SUCCESS"/>
<testcase id="rehearsal.yaml" name="rehearsal.yaml" classname="rehearsal.yaml" file=".maestro/potok-3.yaml" time="1.1" timestamp="00:03:05.000" status="SUCCESS"/>
</testsuite>
</testsuites>
maestro=['MAESTRO_POTOKI cmp-mob-002-tabs.yaml pilot.yaml rehearsal.yaml']
output=995 native rc=0 testcases=3 failed=0
```
Правка `name:` воспроизведена в sandbox путём подмены записи `mobile/.maestro/start.yaml`, а `maestro_katalog_propusk=['start.yaml']` — штатный вход подложного Maestro; это НЕ реальный запуск Android. Семейная клетка `nabor-junit-nepolnyj` на исходных уникальных именах по-прежнему `('ok', None)`, что показывает пробел алфавита, не обход самой этой клетки.

Сырой scoped-прогон прочих синтаксисов (`python3 /tmp/dev-harness-verify/Crit995b/attack_flows.py`, rc 0; `maestro_calls` — записи журнала):
```
previous-start rc=2 maestro_calls=0 flows=[] marker=['995 FIKSIROVANNYJ_NABOR_ISKLJUCHEN: mobile/.maestro/config.yaml flows исключает start.yaml из фиксированного набора']
pilot rc=2 maestro_calls=0 flows=[] marker=['995 FIKSIROVANNYJ_NABOR_ISKLJUCHEN: mobile/.maestro/config.yaml flows исключает pilot.yaml из фиксированного набора']
rehearsal rc=2 maestro_calls=0 flows=[] marker=['995 FIKSIROVANNYJ_NABOR_ISKLJUCHEN: mobile/.maestro/config.yaml flows исключает rehearsal.yaml из фиксированного набора']
tabs rc=2 maestro_calls=0 flows=[] marker=['995 FIKSIROVANNYJ_NABOR_ISKLJUCHEN: mobile/.maestro/config.yaml flows исключает cmp-mob-002-tabs.yaml из фиксированного набора']
foreign-only rc=0 maestro_calls=1 flows=['MAESTRO_POTOKI cmp-mob-002-tabs.yaml pilot.yaml rehearsal.yaml start.yaml'] marker=['995 native rc=0 testcases=4 failed=0']
glob-literal rc=0 maestro_calls=1 flows=['MAESTRO_POTOKI cmp-mob-002-tabs.yaml pilot.yaml rehearsal.yaml start.yaml'] marker=['995 native rc=0 testcases=4 failed=0']
short-glob-literal rc=0 maestro_calls=1 flows=['MAESTRO_POTOKI cmp-mob-002-tabs.yaml pilot.yaml rehearsal.yaml start.yaml'] marker=['995 native rc=0 testcases=4 failed=0']
without-star rc=0 maestro_calls=1 flows=['MAESTRO_POTOKI cmp-mob-002-tabs.yaml pilot.yaml rehearsal.yaml start.yaml'] marker=['995 native rc=0 testcases=4 failed=0']
empty-list rc=0 maestro_calls=1 flows=['MAESTRO_POTOKI cmp-mob-002-tabs.yaml pilot.yaml rehearsal.yaml start.yaml'] marker=['995 native rc=0 testcases=4 failed=0']
duplicate-exclusion rc=2 maestro_calls=0 flows=[] marker=['995 FIKSIROVANNYJ_NABOR_ISKLJUCHEN: mobile/.maestro/config.yaml flows исключает start.yaml из фиксированного набора']
comment-only rc=0 maestro_calls=1 flows=['MAESTRO_POTOKI cmp-mob-002-tabs.yaml pilot.yaml rehearsal.yaml start.yaml'] marker=['995 native rc=0 testcases=4 failed=0']
in-list-comment-before-exclusion rc=0 maestro_calls=1 flows=['MAESTRO_POTOKI cmp-mob-002-tabs.yaml pilot.yaml rehearsal.yaml start.yaml'] marker=['995 native rc=0 testcases=4 failed=0']
missing-testcase-case=('ok', None)
```
Границы: `!*.yaml` и `!st*.yaml` здесь литералы, не глобы; позитивные шаблоны и до-каталожный JUnit явно вынесены в НЕ ЗАЩИЩАЕТ (контракт:266-267). `in-list-comment-before-exclusion` в подложном Maestro следует узкой грамматике парсера 118 и не доказывает поведение настоящего Maestro на валидном YAML с промежуточным комментарием — НЕ используется как блокер. Продукт d0140101c: `mobile/scripts/ci-e2e.sh:168-169` вызывает `maestro test ... .maestro` с JUnit; `restart/zhivoj/report.xml` живой серии содержит testcase `name:` из заголовков флоу; `mobile/e2e-erstinformation/e2e.sh:26-29` и `mobile/e2e-first-run/e2e.sh:23-26` запускают прямые флоу отдельно. До-каталожная форма отчёта этим путём не обоснована как достижимый зелёный продуктовый JUnit после cutover, не самостоятельная находка этого круга.

Адресность (команды / сырой вывод):
```
git cat-file -t aeac8b1b6613b79ccf867f8432e876ed6ccfaf5b             # rc 0: commit
git rev-parse HEAD                                                      # rc 0: aeac8b1b6613b79ccf867f8432e876ed6ccfaf5b
git diff --name-only HEAD~1..HEAD                                       # rc 0:
contracts/995-cmp-mob-001-android-pilot.md
fixtures/workshop_project/pilot_995/maestro_probe.py
fixtures/workshop_project/pilot_995/restart/model/maestro_probe.py
fixtures/workshop_project/pilot_995/restart/probe.py
fixtures/workshop_project/pilot_995/restart/source.json
sha256sum fixtures/workshop_project/pilot_995/restart/model/ci-e2e.sh fixtures/workshop_project/pilot_995/maestro_probe.py fixtures/workshop_project/pilot_995/restart/model/maestro_probe.py # rc 0:
0fa425b5db4752633c7ea453065503bfa8ecefa67e1bef8a7e66102426897f30  fixtures/workshop_project/pilot_995/restart/model/ci-e2e.sh
2e897a0bf8db9163a3781b7a7ba7d952bf09619561d3b54aece95f2b0f6950f4  fixtures/workshop_project/pilot_995/maestro_probe.py
2e897a0bf8db9163a3781b7a7ba7d952bf09619561d3b54aece95f2b0f6950f4  fixtures/workshop_project/pilot_995/restart/model/maestro_probe.py
```
Сравнение `git show 47aa733d:.../source.json` с HEAD разобранным JSON (python3 -c, rc 0): `old/new cases 55 61`; `changed old cases []`; новые — `nabor-junit-nepolnyj`, `nabor-konfig-iskljuchaet-{chuzhoj,pilot,rehearsal,start,tabs}`; `changed old stub mappings []`; новые стабы `p-bez-polnoty-junit`, `p-ignoriruet-konfig`; `changed pinned artifacts ['model/maestro_probe.py']`; `old/new links 63 68`. Все пять изменённых файлов принадлежат `ЗОНА architect` (контракт:119), S-байты `0fa425b5…` не менялись. Новые четыре связки `p-ignoriruet-konfig` и одна `p-bez-polnoty-junit` соответствуют изменяемым ветвям в `restart/probe.py:1838-1867`, а не прозе договора (Н-39).

Предметные команды / фактический исход (последовательно, НЕ параллельные батареи):
```
bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh
# rc 1: SUBJECT_ABSENT: нет --repo/MOB_REPO; зелень без субъекта невозможна; 61 строка CASE ... KRASNO (SUBJECT_ABSENT).
bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --model
# rc 0: CASE nabor-konfig-iskljuchaet-pilot ok; CASE nabor-konfig-iskljuchaet-start ok; CASE nabor-konfig-iskljuchaet-rehearsal ok; CASE nabor-konfig-iskljuchaet-tabs ok; CASE nabor-konfig-iskljuchaet-chuzhoj ok; CASE nabor-junit-nepolnyj ok; всего 61 CASE ok; SVIP itog: N=20, krasnykh 0.
bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --stabs
# rc 0: контроль 61 CASE ok; STAB p-ignoriruet-konfig nabor-konfig-iskljuchaet-{pilot,start,rehearsal,tabs} KRASEN; STAB p-bez-polnoty-junit nabor-junit-nepolnyj KRASEN; SVJAZI 68; zhivykh 0.
bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --repo /tmp/dev-harness-verify/Crit995b/target-tree
# rc 0: 61 CASE ok; SVIP itog: N=20, krasnykh 0. target-tree — cp -a read-only /tmp/dev-harness-verify/Addr141/target-tree, HEAD d0140101c6c4fca94687cf88c418344cd9601d59.
python3 fixtures/workshop_project/pilot_995/native_matrix.py --scratch /tmp/dev-harness-verify/Crit995b
# rc 0: 995 native-runner checked=16 Android=NOT_RUN.
python3 /tmp/dev-harness-verify/Crit995b/tamper995/probe.py --model
# rc 2: ORACLE_TAMPERED: пин model/maestro_probe.py не сходится (только disposable копия).
bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --stabs
# rc 0: SVJAZI 60.
bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --stabs
# rc 0: SVJAZI 61; zhivykh 0.
bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs
# rc 2: клеток 69, зелёных 68, красных 0; p01 NEEDS_PRECEDENT 995 v5 (ожидаемое окно до freeze/перепина); стабов 33, привязок 49, непойманных 0.
```
Гейты, живые команды на HEAD фиксированного клона:
```
bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Crit995b/repo contracts/995-cmp-mob-001-android-pilot.md # rc 0: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3; КРИТИК: дверь зелёная
bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Crit995b/repo contracts/995-cmp-mob-001-android-pilot.md # rc 0: OK
bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Crit995b/repo contracts/995-cmp-mob-001-android-pilot.md # rc 0: OK
bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Crit995b/repo # rc 0: потолки в порядке
bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Crit995b/repo contracts/995-cmp-mob-001-android-pilot.md # rc 0: ЗАЩИЩАЕТ 4, НЕ ЗАЩИЩАЕТ 4
bash scripts/check_provodka.sh /tmp/dev-harness-verify/Crit995b/repo contracts/995-cmp-mob-001-android-pilot.md # rc 1: проводка: guard не подключён (окно orchestrator freeze..done)
bash scripts/check_provodka.sh /tmp/dev-harness-verify/Crit995b/provodka-copy contracts/995-cmp-mob-001-android-pilot.md # rc 0 на disposable копии с одним workflow-шагом, который вызывает guard --stabs.
```
НЕ ПРОВЕРЕНО: настоящий Maestro/Android, CI с устройством и реальный перепин H после freeze. Авторство коммита `architect <architect@dev-harness.local>` подтверждено `git show`; фактическая модель архитектора из независимого metadata-трейса не подтверждена, но исход FAIL не зависит от accept/сверки независимости. Фактическая модель этого судьи — runtime metadata `openai-codex/gpt-6-sol`, идентификатор сессии `Crit995b`.
