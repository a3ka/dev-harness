FAIL

СУД: контракт 143 v2, scoped-вызов 2/2 по §2.1 предыдущего `verdicts/critic/contracts-143-v2-krug1-fail.md`; OBJECT `022de5d461e435d63ec18e8d994c412163077b9d`, родитель `61f01bd914b1b7bfa42e98be92e8ee4dba8b5997`, модель-факт `openai-codex/gpt-6-sol`, автор OBJECT `architect`. Изолированный SSH-клон `/tmp/dev-harness-verify/Crit143v2s`, ветка `wip/143/critic-v2s`. Две находки относятся только к новой семантике child-flows и её приёмке; §2.2–§4 и продукт не пересуждались.

БЛОКИРУЕТ contracts/143-mob-ci-razdelenie.md:139 — новый критерий i08 требует `AFFECTED` для PR по child-flow независимо от разрешённого статуса экрана. При законном `in-development` (именно статус ещё не принятого экрана 148) прежний И-2 сначала выбирает работника по статусу с причиной `DEVELOPMENT`, а потом не переписывает причину на `AFFECTED`. Конформная шестая запись с `child_flows=[mobile/.maestro/vkladki-tabshell-393.yaml]` и честный селектор дают 78/79: единственная красная i08 при правильно выбранном работнике. `approved` той же записи даёт 79/79. Это противоречит заявленному расширению на экраны в разработке, а не нарушение селектора.
ОБЯЗАТЕЛЬСТВО: критерий допускает оба статуса И-1 и судит, выбран ли владелец child-flow, не отклоняя честное включение экрана в разработке по уже действующему приоритету DEVELOPMENT.
СОСТОЯНИЕ: модель + `e2e-vkladki` из лекала, статус `in-development`, отдельная запись child-flow, настоящий git-diff меняет только этот flow.
НАБЛЮДЕНИЕ: `W --repo <A2-in-development>` rc 1, `КЛЕТКА i08-vybor-child-flows: ... причина DEVELOPMENT ≠ AFFECTED КРАСНА`; та же карта со статусом `approved` — rc 0. Закрывающее свойство: оба разрешённых статуса проходят, а мутант, не владеющий child-flow, красен на ОБОИХ.

БЛОКИРУЕТ contracts/143-mob-ci-razdelenie.md:70 — `child_flows` объявлен частью подписи `POLICY_CHANGE`, но ни одна красная клетка не проверяет смену ТОЛЬКО этой записи между base/head. Удаление `z.child_flows` из `kartaPodpis` оставляет `W --repo` зелёным 79/79 и все 61 стаб пойманы (`--stabs` запускает стаб против модели, не против поданного `--repo`). На реальном git-diff, меняющем только карту добавлением child-flow, честный селектор выдаёт `policy_change=true`, `prichiny=[POLICY_CHANGE,COMMON_CHANGE]`; мутант выдаёт `policy_change=false`, `prichiny=[COMMON_CHANGE]` (полный набор остаётся лишь по общему пути карты). Названное свойство события POLICY_CHANGE не доказано критерием.
ОБХОД: портировать мутант селектора, удалив `z.child_flows` только из `kartaPodpis`, сохранив union и `vladelec`: приёмка `W --repo <продукт>` → rc 0 `79/79`, хотя PR, меняющий регистрацию child-flow, не классифицирован POLICY_CHANGE. Закрывающее свойство: отдельный git-diff смены child_flows base/head проверяет policy_change и причину и краснеет на таком мутанте; не требуется менять сам способ подписи.

АРБИТР: arbiter; после второго critic-FAIL исчерпан адресный бюджет 1 полный + ≤1 scoped. Предмет спора: допустимая причина выбора in-development при child-only PR и полнота красного доказательства POLICY_CHANGE для смены child_flows. Этот FAIL не даёт нового вызова и не заменяет решение владельца о бюджете согласно §Быстрый-процесс.

### Живые команды и сырой вывод атак

`python3 /tmp/dev-harness-verify/Crit143v2s-child-direct.py` → rc 0; настоящий репозиторий, diff:
```
GIT_DIFF M	mobile/.maestro/vkladki-tabshell-393.yaml
SELECTOR honest command= node mobile/scripts/select-ci-screens.cjs --mode pull_request --repo /tmp/critic143-v2s-child-direct-h96sfxbv --base-sha 80802af0b289b9b8d8370f8092bd14100b14ea5c --head-sha 7fd28a45d6ac9ae3a9250dd8d154180b95df57d3 --out /tmp/critic143-v2s-child-direct-h96sfxbv/selection.json rc= 0 stdout= VYHOD e2e-splash=false
VYHOD e2e-first-run=false
VYHOD e2e-erstinformation=false
VYHOD e2e-start=false
VYHOD e2e-vkladki=true
VYHOD e2e-pilot=false
VYBOROK 1 iz 6 stderr=
SELECTION {"selected": [{"id": "vkladki", "job": "e2e-vkladki", "reason": "AFFECTED"}], "full_set": false, "policy_change": false, "diff_istochnik": "git"}
SELECTOR mutant command= node mobile/scripts/select-ci-screens.cjs --mode pull_request --repo /tmp/critic143-v2s-child-direct-h96sfxbv --base-sha 80802af0b289b9b8d8370f8092bd14100b14ea5c --head-sha 7fd28a45d6ac9ae3a9250dd8d154180b95df57d3 --out /tmp/critic143-v2s-child-direct-h96sfxbv/selection.json rc= 1 stdout=  stderr= VYBOR_OTKAZ: INVENTAR_KARTY: mobile/.maestro/vkladki-tabshell-393.yaml
```

`python3 /tmp/dev-harness-verify/Crit143v2s-status.py` → rc 0 (скрипт проверяет ожидаемое расхождение, все деревья временные); сырой вывод батареи и целевого мутанта:
```
COMMAND bash /tmp/dev-harness-verify/Crit143v2s/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/critic143-v2s-status-yzrnnk2i/in-development RC 1 STDOUT клеток 79, зелёных 78, красных 1
КЛЕТКА i08-vybor-child-flows: PR только mobile/.maestro/vkladki-tabshell-393.yaml: причина DEVELOPMENT ≠ AFFECTED КРАСНА STDERR
I08 in-development False PR только mobile/.maestro/vkladki-tabshell-393.yaml: причина DEVELOPMENT ≠ AFFECTED
COMMAND bash /tmp/dev-harness-verify/Crit143v2s/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/critic143-v2s-status-yzrnnk2i/approved RC 0 STDOUT клеток 79, зелёных 79, красных 0 STDERR
I08 approved True
COMMAND bash /tmp/dev-harness-verify/Crit143v2s/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/critic143-v2s-status-yzrnnk2i/approved RC 1 STDOUT клеток 79, зелёных 78, красных 1
КЛЕТКА i08-vybor-child-flows: PR только mobile/.maestro/vkladki-tabshell-393.yaml: rc=1 VYBOR_OTKAZ: INVENTAR_KARTY: mobile/.maestro/vkladki-tabshell-393.yaml КРАСНА STDERR
```

`python3 /tmp/dev-harness-verify/Crit143v2s-policy.py` → rc 0 (скрипт ожидает ложный зелёный); сырой вывод:
```
POLICY_SIGNATURE_MUTANT command=bash /tmp/dev-harness-verify/Crit143v2s/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/critic143-v2s-policy-o5_aawh7 rc= 0 stdout= клеток 79, зелёных 79, красных 0 stderr=
```
`python3 /tmp/dev-harness-verify/Crit143v2s-policy-git.py` → rc 0, реальный git-diff и два селектора на одних коммитах; сырой вывод:
```
DIFF M	mobile/ci-screens.json
VARIANT honest COMMAND node mobile/scripts/select-ci-screens.cjs --mode pull_request --repo /tmp/critic143-v2s-policy-git-c0i9y8nt --base-sha c91c55d31502d34cb8a0b3d585abeaf82fba1408 --head-sha b368550a741b4d86d6f63b8fbe8ad00868b61ca3 --out /tmp/critic143-v2s-policy-git-c0i9y8nt/selection.json RC 0 STDOUT VYHOD e2e-splash=true
VYHOD e2e-first-run=true
VYHOD e2e-erstinformation=true
VYHOD e2e-start=true
VYHOD e2e-pilot=true
VYBOROK 5 iz 5 STDERR  SELECTION {"policy_change": true, "full_set": true, "prichiny": ["POLICY_CHANGE", "COMMON_CHANGE"]}
VARIANT signature-stripped COMMAND node mobile/scripts/select-ci-screens.cjs --mode pull_request --repo /tmp/critic143-v2s-policy-git-c0i9y8nt --base-sha c91c55d31502d34cb8a0b3d585abeaf82fba1408 --head-sha b368550a741b4d86d6f63b8fbe8ad00868b61ca3 --out /tmp/critic143-v2s-policy-git-c0i9y8nt/selection.json RC 0 STDOUT VYHOD e2e-splash=true
VYHOD e2e-first-run=true
VYHOD e2e-erstinformation=true
VYHOD e2e-start=true
VYHOD e2e-pilot=true
VYBOROK 5 iz 5 STDERR  SELECTION {"policy_change": false, "full_set": true, "prichiny": ["COMMON_CHANGE"]}
```

Первый независимый A2-проход `python3 /tmp/dev-harness-verify/Crit143v2s-proof.py` → rc 1 на намеренно строгом assert ожидающего зелень. Сырой вывод до assert:
```
ATTACK A1-legacy COMMAND=bash /tmp/dev-harness-verify/Crit143v2s/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/critic143-v2s-attacks-g67d8r77/A1 RC=1
STDOUT: клеток 79, зелёных 76, красных 3
КЛЕТКА i01-inventar-dereva: честное дерево: rc=1 VYBOR_OTKAZ: REZHIM: mode=inventar; пачка без регистрации: rc=1 VYBOR_OTKAZ: REZHIM: mode=inventar; запись без пачки: rc=1 VYBOR_OTKAZ: REZHIM: mode=inventar; symlink-пачка: rc=1 VYBOR_OTKAZ: REZHIM: mode=inventar; флоу без владельца: rc=1 VYBOR_OTKAZ: REZHIM: mode=inventar; флоу записи отсутствует: rc=1 VYBOR_OTKAZ: REZHIM: mode=inventar КРАСНА
КЛЕТКА i05-vynos-iz-inventarja: НЕТ_ИНВЕНТАРИЗАЦИИ: в quality нет шага с вызовом селектора --mode inventar КРАСНА
КЛЕТКА i08-vybor-child-flows: PR только mobile/.maestro/splash-child-proba.yaml: rc=1 VYBOR_OTKAZ: INVENTAR_KARTY: mobile/.maestro/splash-child-proba.yaml КРАСНА STDERR:
ATTACK A2-six-workers COMMAND=bash /tmp/dev-harness-verify/Crit143v2s/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/critic143-v2s-attacks-g67d8r77/A2 RC=1
STDOUT: клеток 79, зелёных 78, красных 1
КЛЕТКА i08-vybor-child-flows: PR только mobile/.maestro/vkladki.yaml: причина DEVELOPMENT ≠ AFFECTED КРАСНА STDERR:
Traceback (most recent call last):
  File "/tmp/dev-harness-verify/Crit143v2s-proof.py", line 103, in <module>
    assert p.returncode == 0 and 'клеток 79, зелёных 79, красных 0' in p.stdout
           ^^^^^^^^^^^^^^^^^
AssertionError
```

Прямые контрольные команды в клоне:
```
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --model   # ×3, каждый rc 0
клеток 79, зелёных 79, красных 0
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs   # rc 0
клеток 79, зелёных 79, красных 0
стабов 61, привязок 77, непойманных 0
```
Пины по `source.json`: 13 `piny` + 9 `chernoviki_piny` = 22; реально 79 `kletki`, 61 `stab_vhod`, 77 привязок, 61 файл `stab_*.py`; селектор sha256 `866e9c1a27287971017088fc9d025e459311e9a2a784041e060e2d276dccefb7` совпал с пином. **Проверка дрейфа отдельной копии** до решения не запускалась: этот результат не присваиваю себе (предыдущий вердикт содержит проверку других носителей).

Регресс (живые команды на OBJECT, каждый rc 0; дословные итоговые строки):
```
$ bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --stabs
SVIP itog: N=20, krasnykh 0
SVJAZI 69
zhivykh 0
$ bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --stabs
SVJAZI 60
$ bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --stabs
SVJAZI 66
zhivykh 0
```
`git diff 61f01bd91..022de5d46`: 6 файлов, §2.1 + новое правило 11 + счёты/проводка/демаркация и отчёт; существующие положения §2.2–§4 не удалены и не ослаблены. Frozen 143/1 не правился этой дельтой; родитель уже содержал разрешённую оркестратором строку владельца. Принимаемый в круге 1 инвентарь jobs, запрет ручного выноса, лекало, legacy-опора, разделение пина эталона и продукта, зоны/пересечения, порядок реализации остаются на месте.
