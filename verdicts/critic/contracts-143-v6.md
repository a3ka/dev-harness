accept
OBJECT=aa72e2d762b138aeeb1f77626af6022d123c1805
СУД: repo=dev-harness; предмет=143; роль=critic; вызов=один адресный по v6 (слово владельца 24.11); фаза=v6; модель-план=openai-codex/gpt-6.1-terra (штатный тир apex-sol); сессия=Crit143V6; модель-факт=openai-codex/gpt-6.1-terra; независимость: автор Architect143b — другая модель/сессия; предыдущий=verdicts/critic/contracts-143-v7.md (accept на v5, OBJECT 180352174bc136f35e3f57bc780e1d4eaa610d84); класс риска=рисковый, health/required CI.

## Решение

Адресно рассмотрена дельта `git diff 5e5a274c35750f8f29319f39bae43780af1446db aa72e2d762b138aeeb1f77626af6022d123c1805`: признание только доказанных lane-тел, сохранение inline и исходных проверок, точный внешний остаток. Повторного полного суда v5 нет. `models_actual.sh --tsv --bind --session Crit143V6`: rc 0, `critic openai-codex/gpt-6.1-terra allowed Crit143V6 aa72e2d762b138aeeb1f77626af6022d123c1805` (две одинаковые строки).

Снимок `nositeli/lanes-216.json` и baseline настоящего 216 на `fa6678d2163b5c96e5a8a5f71a194c8a7c4e4e79` имеют SHA256 `e502c44d93bd93e090ba4e2be80462bfc753a961af10dd0efc310f37b8831511`. Проекция сверяет маршрут, lifecycle, dispatcher, тело, env, cwd, name/id до подстановки; селектор отдельно исполняется в песочнице. Старые клетки не удалены; `probe.py` и `matrix_v3.py` проверены построчным diff.

## Измерения

`TMPDIR=/tmp/dev-harness-verify/scratch-crit143v6`; мобильный git — одноразовый клон с отдельным `.git`. Все rc ниже наблюдались.

- `bash scripts/check_sdacha.sh "$PWD" contracts/143-mob-ci-razdelenie.md --run`: rc 0, `СДАЧА: лист зелёный (двери=5 карта=17/17 дельта=2)`; пять дверей включают model/stabs/syntax/provodka/pre-critic, в листе заявлен rc 0.
- `bash scripts/pre_critic.sh contracts/143-mob-ci-razdelenie.md`: rc 0, `КРИТИК: дверь зелёная`.
- `python3 -B fixtures/workshop_project/mob_ci_143/lane_v6_acceptance.py --prepare <mobile> <R>`: rc 0, настоящий `run.sh --repo R --base 55d9be4484bf058d655a2eef6b558ab21d9393d9`, все 23 `CASE ... OK`, `RC 0`.
- `bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo <R>`: rc 1, `клеток 405, зелёных 402, красных 3`; `клеток 79, зелёных 75, красных 4`. Красные ровно `legacy: LEGACY_JOB_CHANGED`, `workflow-quality-run-step-3`, `workflow-quality-run-step-6`, `y12-avd-namespace`, `y13-odin-uroven-vosstanovlenija`, `y23-ispolnenie-povtora`, `p01-P-nabor`.
- `python3 -B fixtures/workshop_project/mob_ci_143/lane_v6_acceptance.py --repo <R>`: rc 0; внутренний `RC 1`; `RESIDUAL_EXACT legacy,p01-P-nabor,workflow-quality-run-step-3,workflow-quality-run-step-6,y12-avd-namespace,y13-odin-uroven-vosstanovlenija,y23-ispolnenie-povtora`; `LANE_DELTA_GREEN 11`; `LANE_CONTROLS 11 NEGATIVE_BINDINGS 88`. Пары включают честный эквивалент preamble каждой lane.
- `bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo <inline-fda1fc8>`: rc 0, `клеток 396, зелёных 396, красных 0`; `клеток 79, зелёных 79, красных 0`.
- `git diff --quiet` соответствующих файлов относительно frozen 141/3, 995/5, 135/1, 118/3 и 197/3: каждый rc 0. Проектный 216 судится по отдельному мобильному git; его baseline побайтово совпадает со снимком. Frozen 143/4 даёт architect пути `contracts/143-mob-ci-razdelenie.md fixtures/workshop_project/mob_ci_143/`; все восемь путей diff внутри них. Строка разрешения владельца имеется в теле `aa72e2d...`.
- `bash scripts/check_zones.sh "$PWD"`: общий прогон не завершился за 300 секунд, rc не получен; в частичном выводе `ok ... contracts/143-mob-ci-razdelenie.md`. Глобальный PASS зон не утверждается; адресная сверка восьми путей выполнена по frozen-блобу выше.

## Мутации критика

Каждая команда копировала R во временный каталог, меняла указанное тело и вызывала полную батарею. Ни одна замена не является стабом `lane_v6_acceptance.py`; ниже собственная добавленная красная клетка и итог помимо семи внешних красных. Вызовы исполнялись с `TMPDIR=/tmp/dev-harness-verify/scratch-crit143v6`.

1. `python3 -B -c 'import tempfile,shutil,pathlib,subprocess; t=tempfile.TemporaryDirectory(); r=pathlib.Path(t.name)/"R"; shutil.copytree("/tmp/dev-harness-verify/scratch-crit143v6/R",r); p=r/"mobile/scripts/ci-build-identity.sh"; s=p.read_text(); p.write_text(s.replace("echo \"run_attempt=${GITHUB_RUN_ATTEMPT}\"", "echo \"run_attempt=1\"")); z=subprocess.run(["bash","fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh","--repo",str(r)]); print("MUTANT_IDENTITY_RC",z.returncode,flush=True); t.cleanup()'`.
   Вывод: `КЛЕТКА workflow-build-apk-run-step-7 КРАСНА: WORKFLOW_CONTROL_workflow-build-apk-run-step-7`; `клеток 405, зелёных 401, красных 4`; `клеток 79, зелёных 75, красных 4`; `MUTANT_IDENTITY_RC 1`.
2. `python3 -B -c 'import tempfile,shutil,pathlib,subprocess; t=tempfile.TemporaryDirectory(); r=pathlib.Path(t.name)/"R"; shutil.copytree("/tmp/dev-harness-verify/scratch-crit143v6/R",r); p=r/"mobile/scripts/ci-selection-outputs.sh"; s=p.read_text(); p.write_text(s.replace("sel.selected", "sel.excluded")); z=subprocess.run(["bash","fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh","--repo",str(r)]); print("MUTANT_SELECTION_RC",z.returncode,flush=True); t.cleanup()'`.
   Вывод: `КЛЕТКА workflow-select-screens-run-step-3 КРАСНА: WORKFLOW_CONTROL_workflow-select-screens-run-step-3`; `клеток 405, зелёных 401, красных 4`; `клеток 79, зелёных 75, красных 4`; `MUTANT_SELECTION_RC 1`.
3. `python3 -B -c 'import tempfile,shutil,pathlib,subprocess; t=tempfile.TemporaryDirectory(); r=pathlib.Path(t.name)/"R"; shutil.copytree("/tmp/dev-harness-verify/scratch-crit143v6/R",r); p=r/"mobile/scripts/ci-inventar.sh"; s=p.read_text(); p.write_text(s.replace("node mobile/scripts/select-ci-screens.cjs --mode inventar", "true mobile/scripts/select-ci-screens.cjs --mode inventar")); z=subprocess.run(["bash","fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh","--repo",str(r)]); print("MUTANT_INVENTAR_RC",z.returncode,flush=True); t.cleanup()'`.
   Вывод: `КЛЕТКА i05-vynos-iz-inventarja: НЕТ_ИНВЕНТАРИЗАЦИИ: в quality нет шага с вызовом селектора --mode inventar КРАСНА`; `клеток 405, зелёных 402, красных 3`; `клеток 79, зелёных 74, красных 5`; `MUTANT_INVENTAR_RC 1`.

## Карта классов

К-01: чисто — check_sdacha --run rc 0, pre_critic rc 0.
К-02: чисто — вход: OBJECT и письмо задания 216, baseline 216 совпадает по SHA256.
К-03: чисто — diff файлов frozen 141/3, 995/5, 135/1, 118/3, 197/3 rc 0; продуктовый 216 не меняется.
К-04: чисто — вход: восемь путей diff и зоны frozen 143/4; общий check_zones не завершён, см. измерения.
К-05: чисто — вход: contracts/143-mob-ci-razdelenie.md:471-497, команды с кодами; запущены сдаточный лист, R и inline.
К-06: чисто — вход: lanes_216.py oracle проверяет SHA до чтения субъекта; ошибка обрабатывается как ORACLE_TAMPERED rc 2.
К-07: чисто — --prepare rc 0, настоящая 216 23 CASE OK; inline rc 0.
К-08: чисто — L --repo R rc 0, 88 негативных привязок; три собственные мутации красны адресно.
К-09: чисто — вход: И-20 и lanes_216.py ограничивают модель пятью именованными lane и inline; 11 ветвей зелёны на R.
К-10: чисто — вход: matrix_v3.py selector_output_case исполняет шаг и сверяет единственный вывод, selection.json и независимое ожидание.
К-11: чисто — вход: baseline 216 сопоставлен с независимым SHA256 до проекции, источник снаружи R.
К-12: чисто — вход: lanes_216.py сопоставляет байты фиксированного канона; YAML safe_load, реальный npm/bash для селектора.
К-13: н/п — новые секретные входы дельтой не вводятся; git diff файлов проверок.
К-14: чисто — L --repo R rc 0, честные эквивалентные preamble проверены перед 88 отрицательными парами.
К-15: чисто — V --repo R rc 1, 405/402/3 и 79/75/4; L --repo rc 0, 11 и 88.
К-16: чисто — вход: contracts/143-mob-ci-razdelenie.md:406-407,500-514; риск health и остаток R названы.
К-17: н/п — вход: git diff: модель операций/схем 188 и продуктовые API дельтой не меняются.

## Блоки

Нет доказанных блокирующих нарушений в области адресного вызова.

## НЕ ЗАЩИЩАЕТ

Общий rc 0 R216 не достигнут: семь именованных исходных красных не отменены и требуют отдельного согласования канонов 141/995; ловец — Critic/Reviewer 216. Живое исполнение GitHub/self-hosted и произвольный переписанный shell/JS вне ограниченного канона — независимый review и живой CI 216.

## Советы

СОВЕТ contracts/143-mob-ci-razdelenie.md:497 — общий `check_zones.sh` в этой копии не успел завершиться за 300 секунд. Перед лендингом получить его полный итог; адресная сверка frozen-зоны сделана отдельно и не выдаётся за общий PASS.
