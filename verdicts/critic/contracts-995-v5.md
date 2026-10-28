accept
OBJECT=13b4a84ef6bc2d6ba423b22e5919a258494ede6e
СУД: repo=dev-harness; предмет=995; фаза=контракт v5 (адресная по 143, правка по арбитражу); роль=critic; вызов=scoped по перечню арбитра (после 2/2 FAIL); модель-план=роль critic; сессия=Crit995c; модель-факт=openai-codex/gpt-6-sol; SHA=13b4a84ef6bc2d6ba423b22e5919a258494ede6e; предыдущий=critic 995 v5 1/2 FAIL, 2/2 FAIL, арбитраж БЛОКЕР; исключение=нет

Суд только по перечню арбитра `verdicts/arbitration/contracts-995-v5-arbitraz.md`: закрывающее свойство исполнено; новых осей не открывалось. Read-only клон `/tmp/dev-harness-verify/Crit995c/repo`; коммит/push не делались. `git cat-file -t 13b4a84ef6bc2d6ba423b22e5919a258494ede6e` → `commit`, rc 0; HEAD клона = OBJECT. Теги `frozen/contracts/995/1`–`/4` получены из отдельного клона origin.

1. **Адресность — выполнено.** `git diff --name-only 47aa733d..aeac8b1b`, `aeac8b1b..210c64bf`, `210c64bf..13b4a84e`: первые два дают ровно `contracts/995-cmp-mob-001-android-pilot.md`, `fixtures/workshop_project/pilot_995/maestro_probe.py`, `restart/model/maestro_probe.py`, `restart/probe.py`, `restart/source.json` (все внутри `pilot_995`); последний — только контракт. `sha256sum` живого/модельного P → дважды `6639ce8c0fd6db095a2d7ff84897d5bdcb01ed59369a8b377b06c7087dbfd353`; S-модель → `0fa425b5db4752633c7ea453065503bfa8ecefa67e1bef8a7e66102426897f30` (та же сумма у `git show aeac8b1b:…/model/ci-e2e.sh`); NABOR_P, KONFIG_KATALOGA и кадры адресным diff не менялись. `python3 /tmp/dev-harness-verify/Crit995c/compare_source.py`, rc 0, сырой вывод:
   ```
   kejsy: before=61 after=63 previous_changed=[] added=['nabor-kollizija-name-ispolnen', 'nabor-kollizija-name-propusk']
   stab_vhod: before=41 after=42 previous_changed=[] added=['p-mnozhestvo-vmesto-multimnozhestva']
   pin changes: ['model/maestro_probe.py']
   SVJAZI: 68 -> 69
   case_count: 63
   ```
2. **Атака формы на всех четырёх позициях — выполнено.** `python3 /tmp/dev-harness-verify/Crit995c/attack_four.py`, rc 0; disposable replay над P OBJECT, коллизия `name:` + `maestro_katalog_propusk`. Сырой вывод (публикация `report.xml` фактически прочитана в каждом сценарии):
   ```
   A1 omitted=start.yaml P rc=1 report.xml tests="3" marker=True result=OK
     995 FIKSIROVANNYJ_NABOR_NE_ISPOLNEN: исполнены ['995 synthetic DIRECT entry and restart', 'cmp-mob-002-tabs.yaml', 'rehearsal.yaml'] ≠ фиксированного набора ['995 synthetic DIRECT entry and restart', '995 synthetic DIRECT entry and restart', 'cmp-mob-002-tabs.yaml', 'rehearsal.yaml']
   A2 omitted=pilot.yaml P rc=1 report.xml tests="3" marker=True result=OK
     995 FIKSIROVANNYJ_NABOR_NE_ISPOLNEN: исполнены ['995 synthetic DIRECT entry and restart', 'cmp-mob-002-tabs.yaml', 'rehearsal.yaml'] ≠ фиксированного набора ['995 synthetic DIRECT entry and restart', '995 synthetic DIRECT entry and restart', 'cmp-mob-002-tabs.yaml', 'rehearsal.yaml']
   A3 omitted=rehearsal.yaml P rc=1 report.xml tests="3" marker=True result=OK
     995 FIKSIROVANNYJ_NABOR_NE_ISPOLNEN: исполнены ['995 synthetic DIRECT entry and restart', 'cmp-mob-002-tabs.yaml', 'start.yaml'] ≠ фиксированного набора ['995 synthetic DIRECT entry and restart', 'cmp-mob-002-tabs.yaml', 'cmp-mob-002-tabs.yaml', 'start.yaml']
   A4 omitted=cmp-mob-002-tabs.yaml P rc=1 report.xml tests="3" marker=True result=OK
     995 FIKSIROVANNYJ_NABOR_NE_ISPOLNEN: исполнены ['995 synthetic DIRECT entry and restart', 'rehearsal.yaml', 'start.yaml'] ≠ фиксированного набора ['995 synthetic DIRECT entry and restart', 'rehearsal.yaml', 'start.yaml', 'start.yaml']
   C omitted=None P rc=0 report.xml tests="4" marker=False result=OK
     995 native rc=0 testcases=4 failed=0
   D omitted=None P rc=0 report.xml tests="4" marker=False result=OK
     995 native rc=0 testcases=4 failed=0
   failures=0
   ```
3. **Контроли — выполнено.** C и D выше не ложнокрасные; `nabor-junit-nepolnyj` → `CASE nabor-junit-nepolnyj ok` в полном `--model` и `--stabs`.
4. **Батареи — выполнено с отмеченным наблюдением старого свипа.** Новые `nabor-kollizija-name-propusk` (rc 1/маркер/tests="3") и `nabor-kollizija-name-ispolnen` (rc 0/tests="4") → `CASE … ok` в `--model`, `--stabs` и `--repo`; поставленная мутация сравнений по `set` привязана кодом ветви: `STAB p-mnozhestvo-vmesto-multimnozhestva nabor-kollizija-name-propusk KRASEN`; прежняя: `STAB p-bez-polnoty-junit nabor-junit-nepolnyj KRASEN`. Команды/rc/сырой контрольный вывод:
   ```
   bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh                    # rc 1
   SUBJECT_ABSENT: нет --repo/MOB_REPO; зелень без субъекта невозможна
   CASE nabor-kollizija-name-propusk KRASNO (SUBJECT_ABSENT)
   CASE nabor-kollizija-name-ispolnen KRASNO (SUBJECT_ABSENT)
   bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --model            # первый rc 1: старый свип k=16
   SVIP itog: N=20, krasnykh 1 (k=16)
   CASE inkarnacija-smert-svip KRASNO (k=16 (adb -s emulator-5560 shell pm path com.complior.mobile): нет маркера вывода: 'ОТКАЗ: owned PID')
   CASE nabor-junit-nepolnyj ok
   CASE nabor-kollizija-name-propusk ok
   CASE nabor-kollizija-name-ispolnen ok
   bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --model            # повтор rc 0
   SVIP itog: N=20, krasnykh 0
   CASE inkarnacija-smert-svip ok
   CASE nabor-junit-nepolnyj ok
   CASE nabor-kollizija-name-propusk ok
   CASE nabor-kollizija-name-ispolnen ok
   bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --stabs            # rc 0
   CASE nabor-kollizija-name-propusk ok
   CASE nabor-kollizija-name-ispolnen ok
   STAB p-bez-polnoty-junit nabor-junit-nepolnyj KRASEN
   STAB p-mnozhestvo-vmesto-multimnozhestva nabor-kollizija-name-propusk KRASEN
   SVJAZI 69
   zhivykh 0
   bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --repo /tmp/dev-harness-verify/Crit995c/target-tree # rc 0
   SVIP itog: N=20, krasnykh 0
   CASE nabor-junit-nepolnyj ok
   CASE nabor-kollizija-name-propusk ok
   CASE nabor-kollizija-name-ispolnen ok
   bash /tmp/dev-harness-verify/Crit995c/restart-tamper/red_ci_e2e_restart_995.sh --model        # rc 2
   ORACLE_TAMPERED: пин model/maestro_probe.py не сходится
   python3 fixtures/workshop_project/pilot_995/native_matrix.py --scratch /tmp/dev-harness-verify/Crit995c # rc 0
   995 native-runner checked=16 Android=NOT_RUN
   ```
   Продукт `target-tree` скопирован `cp -a` из `/tmp/dev-harness-verify/Addr141/target-tree` только в свой каталог. Первый `--model` дал красный **неизменённой** клетки `inkarnacija-smert-svip` (k=16; указан сырой вывод); второй, без параллельной батареи, N=20/0, 63/63. Контракт ранее документирует флейк свипа; этот наблюдённый сбой не связан с дельтой свойства мультимножества и не скрывается.
5. **Текст — выполнено.** `contracts/995-cmp-mob-001-android-pilot.md:54,260`: равенство отсортированных списков с кратностью, число testcase равно числу копий, коллизия `name:` пропуск не маскирует; `:263-268`: буквальные `!имя` — только ранняя проверка, glob/теги/будущие механизмы — после исполнения мультимножеством, до-каталожная ветвь отдельно признана. `:61-62,127,341` указывают 63/63, 69 и новый sha P; сверено с собственными выводами.
6. **Гейты/соседи/границы — выполнено.** `bash scripts/pre_critic.sh --repo . contracts/995-cmp-mob-001-android-pilot.md` rc 0: `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3`, `КРИТИК: дверь зелёная`; `bash scripts/check_precision_gate.sh . contracts/995-cmp-mob-001-android-pilot.md` rc 0: `OK`; `bash scripts/check_spec_ready.sh . contracts/995-cmp-mob-001-android-pilot.md` rc 0: `OK`; `bash scripts/check_ceilings.sh .` rc 0: `потолки в порядке`; `bash scripts/check_threat_model.sh . contracts/995-cmp-mob-001-android-pilot.md` rc 0: `модель угроз: секция валидна (ЗАЩИЩАЕТ 4 буллет(ов), НЕ ЗАЩИЩАЕТ 4 буллет(ов))`. `bash scripts/check_provodka.sh . contracts/995-cmp-mob-001-android-pilot.md` rc 1: `проводка: guard не подключён: fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh не вызывается в .githooks/ или .github/workflows/`; на одноразовой копии с workflow-строкой `- run: bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --stabs` та же команда с аргументом `/tmp/dev-harness-verify/Crit995c/provodka-copy` → rc 0, вывода нет. Проводка — окно интеграции оркестратора. `bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --stabs` rc 0, `SVJAZI 60`; `bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --stabs` rc 0, `SVJAZI 61`, `zhivykh 0`; `bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs` rc 2, `КЛЕТКА p01-P-nabor: NEEDS_PRECEDENT: 995 v5 — исполняемый набор P ещё rglob (frozen 995/4)`, `стабов 33, привязок 49, непойманных 0` — существующий барьер до freeze 995/5. `ЗОНА architect` охватывает контракт и pilot_995; другие пути в diff не затронуты.
7. **Новые оси — не открывались.** Гигиена имён, грамматика glob до запуска, `file`-атрибут JUnit, до-каталожная ветвь и живой Maestro/Android не предъявлялись как блокеры. Живой Android не запускался в этом scoped-суде.

СОВЕТ contracts/995-cmp-mob-001-android-pilot.md:61 — старый свип смерти может иногда выдавать ложную красноту (в этом вызове первый `--model` rc 1 при k=16, отдельный повтор rc 0 N=20/0); вне адреса арбитража, поэтому заморозку не блокирует.
