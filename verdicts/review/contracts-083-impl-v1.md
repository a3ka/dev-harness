accept
OBJECT=4026cdc0edd851009465687ee103d9ad50864698
СУД: репо=dev-harness; предмет=083; фаза=реализация; роль=reviewer; вызов=1; сессия=Rev083env; модель-факт=anthropic/claude-opus-5-5 (метаданные станции, поле Model); автор Impl083env — implementer-glm, Architect083b; предыдущий=нет; адверсарий=accept 2de969a5b

# Reviewer 083 — ремонт lane-раннера (снятие GITHUB_EVENT_NAME у self-test'ов) + Г11, PR #1451

**БЛОКИРУЕТ: нет.**

**СОВЕТ: 2** — файл `.review/2026-11-27-0831.md` (`status: ready`):

- С-1: architect — два синтетических остатка адверсария (`check:doc*`, литерал `probe-family-selftest`), К-08; принимаю советом.
- С-2: orchestrator → implementer при ленде 218 — номера строк в комментарии раннера указывают на ещё не влитую реализацию 218.

Порядок суда: implementer `f07328d9e` → adversary FAIL `fc946057d` (К-08/К-10) → Architect083b `4026cdc0e` → adversary accept `2de969a5b` → этот вызов. Оба вердикта адверсария прочитаны. Полный повтор работы адверсария не делал; проверил область, неподгонку, сырой вывод, достаточность советов, плюс свои мутанты и интеграционный ДО/ПОСЛЕ.

## Область правки

`git diff --numstat origin/main HEAD` (merge-base = origin/main `ea20d3326edb7299724ab16f5d978fc18f63a379`):

```
67	2	fixtures/_krasnye_083.sh
82	0	fixtures/ci_gen_083/red_ci_a_083.sh
29	1	scripts/run_ci_lane.sh
```

Коммиты (`git log --format='%h %an <%ae> %s' origin/main..HEAD`):

```
4026cdc0e architect-b <architect-b@dev-harness.local> 083: cover lane PR-event classes with addressed mutations
   → fixtures/_krasnye_083.sh, fixtures/ci_gen_083/red_ci_a_083.sh
f07328d9e implementer <implementer@dev-harness.local> implementer: 083-поправка — self-test шаги lane CI исполняются без GITHUB_EVENT_NAME (решение консультанта m2541 п.3, вариант (б))
   → scripts/run_ci_lane.sh
```

Зоны frozen 083/3 (`git show 'frozen/contracts/083/3^{commit}:contracts/083-ci-a-parallelnye-dzhoby-generator-shagov.md' | grep ЗОНА`):
- `ЗОНА architect: … fixtures/_krasnye_083.sh fixtures/ci_gen_083/red_ci_a_083.sh …` (строка 401);
- `ЗОНА implementer: scripts/gen_ci_steps.sh scripts/run_ci_lane.sh …` (строка 402).

Каждый автор в своей зоне. Атомарность: две задачи — два коммита, в обоих ссылка на 083. Генерируемые `ci.yml`/`registry/ci-steps.tsv` не тронуты: `bash scripts/gen_ci_steps.sh --check` rc 0; `bash scripts/verify_ci_parity.sh` rc 0, `расхождений: 0`. Норма не тронута: `git diff --name-only origin/main HEAD -- roles AGENTS.md verdicts contracts docs | wc -l` = 0; `git diff --stat frozen/contracts/083/3^{commit} HEAD -- contracts/083-…md` пуст. `check:zones` (legkij) на OBJECT в CI — pass, т.е. identity `architect-b` зона-гейтом принята.

## Проверки не переписаны под код

- Implementer батарею не трогал (`f07328d9e` → только `scripts/run_ci_lane.sh`). Architect083b production не трогал (`4026cdc0e` → только две фикстуры зоны architect).
- Дельта батареи аддитивна: `red_ci_a_083.sh` +82/−0; в `_krasnye_083.sh` удалены ровно `bash "$BATTERY" "$@"` и `exit $?` — заменены вызовом батареи с явным ROOT, сохранением `battery_rc` и стаб-паком; итог `[ "$battery_rc" -eq 0 ] && [ "$missed" -eq 0 ]` строже прежнего. Ни одна прежняя клетка не ослаблена. Внешних вызывающих с аргументами нет (`ci.yml:217`, `package.json:82` — без аргументов).
- Г11 различает раннеры по НАБЛЮДАЕМОМУ эффекту, не по тексту: реальный раннер субъекта копируется в toy-мир и исполняется; команды toy-ключей (`bash scripts/event_probe.sh <i>`) печатают `${GITHUB_EVENT_NAME-unset}` изнутри дочернего процесса; ожидания — литералы массива `pr=(…)` в памяти батареи до вызова. Доказательство «не текст» — мои эквивалентные мутанты ниже остаются зелёными, а неэквивалентные краснеют.
- Стаб-пак строит мутантов текстовой заменой (Н-39: привязка кодом), но зачёт — rc 1 и ТОЧНЫЙ профиль FAIL-подклеток; неединственный фрагмент — громкий FAIL, не тихий зачёт.

## Красное предъявлено и свои мутанты

Своя проба (`tmp/scratch-rev083envb/mut.sh`, удалена): раннер OBJECT с одной заменой (якорь единственный) → `env GITHUB_EVENT_NAME=pull_request bash fixtures/ci_gen_083/red_ci_a_083.sh <мир> --lane-env-only`. Ни один мутант не из стаб-пака автора.

```
honest: rc=0; 083-Г11: ok=18 FAIL=0; FAIL-подклетки:
main-pre-fix: rc=1; 083-Г11: ok=15 FAIL=3; FAIL-подклетки: Г11-PR/probe-family-selftest Г11-PR/check:document Г11-PR/drill:contract-change
empty-assign: rc=1; 083-Г11: ok=12 FAIL=6; FAIL-подклетки: Г11-PR/probe-family-selftest Г11-PR/check:document Г11-PR/drill:contract-change Г11-без-PR/probe-family-selftest Г11-без-PR/check:document Г11-без-PR/drill:contract-change
equiv-unset-inside: rc=0; 083-Г11: ok=18 FAIL=0; FAIL-подклетки:
equiv-subshell: rc=0; 083-Г11: ok=18 FAIL=0; FAIL-подклетки:
catchall-first: rc=1; 083-Г11: ok=15 FAIL=3; FAIL-подклетки: Г11-PR/probe-family-selftest Г11-PR/check:document Г11-PR/drill:contract-change
export-n-leak: rc=1; 083-Г11: ok=14 FAIL=4; FAIL-подклетки: Г11-PR/check:charter Г11-PR/check:contract-frozen Г11-PR/check:foo-selftest Г11-PR/drill:other
strip-or-true: rc=1; 083-Г11: ok=17 FAIL=1; FAIL-подклетки: Г11-fail-fast/fail-family-selftest
strip-no-exec: rc=1; 083-Г11: ok=9 FAIL=9; FAIL-подклетки: Г11-PR/rc Г11-PR/probe-family-selftest Г11-PR/check:document Г11-PR/drill:contract-change Г11-без-PR/rc Г11-без-PR/probe-family-selftest Г11-без-PR/check:document Г11-без-PR/drill:contract-change Г11-fail-fast/fail-family-selftest
keep-or-true: rc=1; 083-Г11: ok=17 FAIL=1; FAIL-подклетки: Г11-fail-fast/fail-real
```

- `main-pre-fix` — раннер `origin/main` целиком: Г11 КРАСНАЯ на исходном дефекте (красное-до барьера).
- `empty-assign` (`env GITHUB_EVENT_NAME=`) — пустое значение ≠ снятие; пойман.
- `equiv-unset-inside` (`bash -c "unset GITHUB_EVENT_NAME; $cmd"`), `equiv-subshell` (`( unset …; bash -c "$cmd" )`) — эквиваленты, зелёные: клетка не подогнана под текст `env -u`.
- `catchall-first` (`*)` перед классами), `export-n-leak` (утечка снятия в родителя), `strip-no-exec` (ветвь не исполняет команду) — пойманы.
- `strip-or-true` / `keep-or-true` (`|| true` в одной ветви) — fail-fast ловится поимённо на своём плече.

Авторский пакет на OBJECT: `TMPDIR=<копия>/tmp/scratch-rev083envb bash fixtures/_krasnye_083.sh "$PWD" --lane-env-only` → rc 0, `083-Г11: ok=18 FAIL=0`, `083-Г11-стабы: поймано=6 пропущено=0` (профили: wrong-field 3, no-family 1, all-keys 4, no-document 1, no-drill 1, broad-selftest 1 — совпадают с вызовом 2 адверсария).

## Сырой вывод и счёт своей мерой

- 18 новых подклеток — по коду `lane_env11`: 7 ключей × 2 режима + 2 rc + 2 fail-fast = 18; прогоном `--lane-env-only` — `ok=18`.
- Другой мерой — лог CI, а не локальный прогон (`gh api repos/a3ka/dev-harness/actions/jobs/140267755834/logs`, run 45922365231, event `pull_request`, headSha = OBJECT, джоба `obshchij`): `083-батарея: ok=138 FAIL=0` и `083-Г11-стабы: поймано=6 пропущено=0`. 138 = 120 (база `f07328d9e`, вызов 1 адверсария без PR-события) + 18. Локальные 137/1 у адверсария — гостевая И0б/check_charter клона, на CI её нет.
- `gh pr checks 1451`: все джобы pass (ci l1–l7, antiplacebo ap1–ap5, legkij, obshchij, klass, tyazhelyj-itog), `vorota` skipping.
- `bash -n` трёх файлов rc 0. `shellcheck -S warning` (пин 0.11.0): `fixtures/_krasnye_083.sh` rc 0; `scripts/run_ci_lane.sh` rc 1 только SC2034 `LANE_WEIGHT` строка 49 — вне хунка (`@@ -62`), унаследовано.

## Интеграционный ДО/ПОСЛЕ (мой, с реализацией 218)

На OBJECT/main ни один скрипт событие не читает: `git grep -n GITHUB_EVENT_NAME -- fixtures/_krasnye_058.sh 'fixtures/*058*' scripts/` → только `scripts/run_ci_lane.sh:65,66,88`, rc 0. Поэтому ДО/ПОСЛЕ на голом main различия не даёт (это же в вызове 1 адверсария). Одноразовый worktree OBJECT внутри копии + три файла 218 из `wip/218/implementer-c 504050805e07ee06b4dbcef1d9c5983ac3c53ea7` (`check_charter.sh`, `check_contract_frozen.sh`, `lib_incr.sh`); эксперимент интеграции, не утверждение, что 218 на OBJECT.

```
ДО   (раннер origin/main) GITHUB_EVENT_NAME=pull_request run_ci_lane check:document:
      4   CONTROL: PR_WINDOW_BASE_MISSING
      4   PR_WINDOW_BASE_MISSING
      1 lane: отказ ключа check:document (rc=1)
      rc=1
ПОСЛЕ (раннер OBJECT) то же: замер: check:document 35; rc=0
ПОСЛЕ (раннер OBJECT) check:contract-frozen (legkij, реальная защита):
  pr: check_contract_frozen main=ea20d3326edb… base=ea20d3326edb… head=4026cdc0edd8…; rc=0   — окно PR включено, событие СОХРАНЕНО
```

`check:incr-pustoe-okno-217-family-selftest` сам не повторял (≈70 с; у адверсария вызов 1: ДО 41/41 красных `PR_WINDOW_BASE_MISSING`, ПОСЛЕ 41/41 зелёных) — НЕ ПРОВЕРЕНО мной.

## Корректность предиката и охват класса

- `case "$k"` по ключу; `printf '+ %s'`, `t0`, `rc=$?` сразу после `esac`, `замер:`, fail-fast `exit "$rc"` сохранены (прочитан весь цикл `scripts/run_ci_lane.sh:55-101`).
- Под класс попадают 104 шага: `awk` по `registry/ci-steps.tsv` → 102 `step *-family-selftest` + `check:document` + `drill:contract-change`; legkij-ключи (`check:charter check:zones check:ids check:protected check:nabludenia check:contract-frozen`) под класс не попадают.
- Ни один из 102 не обязан видеть событие PR: `git grep -E 'GITHUB_EVENT_NAME|github\.event_name'` вне раннера и 083 находит только yml-носители/модели и пробы, САМИ задающие переменную ребёнку (`e2e_avtoperezapusk_139/probe.py:124` workflow_run, `obryv_adb_diagnostika_141/probe.py:195` push, `pilot_995/restart/probe.py:621` push, `okno_frozen_v_pr_218/probe.py:385/389`, `owner_overrides_228/probe.py:27` чистит) — снятие у родителя их не меняет.
- `check:charter-tekst-do-tega-210-family-selftest` на ветви 218 краснеет по иной причине (`--model`: `transport.py:322` ищет `\ng ls-tree`, отступ в `check_contract_frozen.sh` ветви 218) — вне объёма, НЕ блок; мной не запускался.

## Гипотеза о PR #1450 (058 к11)

`git grep -n GITHUB_EVENT_NAME -- fixtures/_krasnye_058.sh 'fixtures/*058*' scripts/` → только раннер (см. выше). В коде 058 на OBJECT событие не читается; причина красного `check:sharing-family-selftest` на PR #1450 этим деревом НЕ подтверждена — [ИНФЕРЕНЦИЯ] автора остаётся недоказанной (может проявиться лишь через вложенные 054/055 после ленда 218 — не проверено).

## Остатки

- Советы адверсария (два синтетических зелёных: `check:doc*`, литерал `probe-family-selftest`) — принимаю советом, не блоком: на текущем реестре `check:doc*` совпадает только с `check:document`, литерал не совпадает ни с одним из 102 реестровых ключей; документированного механизма ошибки нет. Простая форма закрытия — С-1.
- ОСТАТОК: НЕ-ЗАЩИЩАЕТ-1 (подмена носителя actions/cache валидным sha-предком; ловец «судейские круги на живом CI и ревьюер») — не укусил: дифф не трогает кеш-шаги `ci.yml`, `lib_incr.sh`, `*.sha`.
- ОСТАТОК: НЕ-ЗАЩИЩАЕТ-3 (выбор граничного прогона v+1; ловец «судья и ревьюер по журналу») — не укусил: дифф не трогает `timing_083.sh`/окно А3.
- Регресс 087/114: дельта `f07328d9e..4026cdc0e` — только фикстуры 083, на которые 087/114 не ссылаются (`grep -rn '_krasnye_083\|red_ci_a_083'` → только `ci.yml:217`, `package.json:82`, сама обёртка); исторические 087 110/0, 114 40/40 — вызов 1 адверсария, мной не повторены.

## Норма 050 (паразитная сложность)

- `case "$k"` в `scripts/run_ci_lane.sh:86-93`: (1) 083 И2 lane-исполнитель + frozen 218 И1 (окно PR у реальных проверок) при мирах self-test'ов без базы — решение m2541 п.3(б); (2) состояния не вводит, предикат виден в коде; (3) новый класс ключа → правка раннера + ключи `lane_env11` + фрагмент `predicate=` стаб-пака: 1 → 3 файла, рост оправдан Н-39; (4) интерфейс раннера не изменился; (5) потребитель — все lane CI. ESSENTIAL.
- `lane_env11` + флаг `--lane-env-only` (`red_ci_a_083.sh:205-273`): (1) К-08/К-10 вызова 1 адверсария — наблюдение события по классам; (2) toy-мир в `$SCRATCH/lane11`, явный; (3) локально; (4) один флаг против 18 подклеток работы; (5) потребитель — стаб-пак `_krasnye_083.sh` и CI `obshchij`; полная батарея на каждого из 6 мутантов не даёт изолированного профиля и кратно дороже. ESSENTIAL.
- Семья `lane_stub` (6 стабов, `_krasnye_083.sh`): (1) Н-39, красное-до каждого плеча; (2) scratch через `mktemp`+`trap`; (3) привязана к тексту раннера, расхождение — громкий FAIL; (4) н/п; (5) потребитель — guard CI. ESSENTIAL.

## Сверки

- СВЕРКА-АРХИТЕКТУРЫ: н/п. Контракт 083 (до 188) строки `АРХИТЕКТУРА:` не несёт; в диффе нет `bindings.json`, писателей, операций; долг не расширен; диффа модели нет. `tooling/checks/cli.js` в дереве отсутствует — находок к заведению нет.
- СВЕРКА-СТАНДАРТОВ: н/п. `AGENTS.md` не объявляет `docs/ARCHITECTURE.md`/`docs/CODING-STANDARDS.md` (grep — 0 совпадений).
- Режим проекта 996: sourceCanon не объявлен; мобильного экрана нет.
- ПРОВОДКА (038): guard `fixtures/_krasnye_083.sh` существует, подключён (`.github/workflows/ci.yml:217`, джоба `obshchij`), Г11 и стаб-пак исполнены в CI на OBJECT (лог выше) — барьер именно этого предмета.

## Не проверено

- Повторный локальный прогон полной батареи 083 и 087/114 — заменён логом CI на OBJECT и вызовами адверсария.
- 217-self-test и 210 на интеграции 218 — не запускал.
