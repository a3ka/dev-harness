FAIL
OBJECT=91090bb8fea6f60e9f2c4a991b7c5e24eaf80c6a
СУД: repo=dev-harness; предмет=143; фаза=scoped-критик Fix143d после Rev143 Б-1; роль=critic; вызов=дополнительный по слову владельца 2026-10-29; сессия=Crit143z; модель-факт=openai-codex/gpt-6-sol; предыдущий=/tmp/dev-harness-verify/Rev143/verdicts/review/contracts-143-impl-v1.md; класс находок=содержательный.
К ВЛАДЕЛЬЦУ: следующий FAIL после прежних кругов/арбитража. Ни автоматического следующего круга правки, ни разрешения cutover этот вердикт не даёт.

БЛОКИРУЕТ fixtures/workshop_project/mob_ci_143/probe.py:1386-1400 — y23 выбирает ПЕРВЫЙ шаг с литералом «ПОВТОР: » и выполняет шаг с выбранным именем, а не реально исполняемый на PR `108 start`. `replej_rabotnika` в том же файле, строки 622-625, игнорирует ложное `if` до запуска шага. Условно пропущенный честный дубликат скрывает мёртвую ветку действительного шага: W принимает 71/71 rc 0, но отдельно выполненный действительный `108 start` даёт rc 1 и один вызов Maestro. ОБЯЗАТЕЛЬСТВО: frozen `contracts/143-mob-ci-razdelenie.md:50`, И-6, `e2e-start` делает один внутренний повтор при сигнатуре транспортного обрыва, не повторяет продуктовый отказ; Fix143d обещал обнаруживать Б-1 исполнением, не совпадением букв. СОСТОЯНИЕ: достижимая модель workflow с честным `108 start контрольный (пропущен в PR)` с `if: ${{ false }}` ПЕРЕД действительным `108 start`; у действительного `zapusk108` снова `set -e` перед `return "$rc"`, а его единственный текст «ПОВТОР: » заменён на «ДРУГОЙ_МАРКЕР: ». НАБЛЮДЕНИЕ: y13 считает ровно один литерал (в пропущенном шаге), y23 выбирает его и исполняет только его имя, все клетки зелёные; отдельный replay действительного шага показывает мёртвый повтор. Закрывающее свойство — проверять rc, число Maestro-вызовов и диагностический маркер на исполняемом в PR шаге, не на первом совпадении строки; пропущенный дубль не доказывает работу действительного шага.
ОБХОД: вставить указанный честный шаг с другим именем и ложным `if`, вернуть `set -e` в действительный и переименовать в нём только маркер. Поскольку шаг с `if: ${{ false }}` не запускается согласно GitHub Actions `jobs.<job_id>.steps[*].if` и правилу falsy для `false`, на PR остаётся только мёртвый рабочий шаг. Документация: https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#jobsjob_idstepsif и https://docs.github.com/en/actions/reference/workflows-and-actions/expressions#literals. Живой GitHub Actions здесь НЕ прогонялся: его правило сопоставлено с байтами YAML и отдельно исполняемым телом шага.
```
$ python3 /tmp/dev-harness-verify/Crit143z-retry-decoy.py
BROKEN SOLO REPLAY: MODE --as-is rc=1
stderr: <пусто>
maestro-вызовов: 1 USTANOVLEN: 1 ПОВТОР в stderr: False driver_rc= 0
MUTANT e2e-start skipped decoy if=${{ false }}, actual zapusk108 set -e before return; ПОВТОР literal only in decoy
клеток 71, зелёных 71, красных 0
rc= 0
```
Одноразовый скрипт создаёт отдельно `solo-broken.yml` для репро действительного шага, затем модель для W; среди четырёх файлов-субъектов W в копии изменён только `mobile.yml`. Первая попытка атаки по ошибке оставила «НЕ-ПОВТОР: » (всё ещё содержит «ПОВТОР: ») и была красной y13; приведённый финальный «ДРУГОЙ_МАРКЕР: » даёт действительный ложнозелёный контрпример.

БЛОКИРУЕТ fixtures/workshop_project/mob_ci_143/probe.py:1426-1455 — y24 судит текст и позицию шага «Изоляция раннера», но не его исполнение на PR; y04 (`probe.py:1885-1888`) ловит буквальное `if: false`, не выражение, ложное для PR. ОБЯЗАТЕЛЬСТВО: frozen `contracts/143-mob-ci-razdelenie.md:51`, И-7, и адресное С-3 Rev143: в каждой job, выполняющей код PR, изоляция раннера исполняется ДО такого кода. СОСТОЯНИЕ: в `e2e-erstinformation` честному шагу изоляции добавлено `if: ${{ github.event_name == 'schedule' }}`, после него без изменения выполняются `npm ci` и Jest; workflow содержит события и `pull_request`, и `schedule` (`model/.github/workflows/mobile.yml:13-18`). НАБЛЮДЕНИЕ: на PR условие шага ложно согласно документированной GitHub семантике `steps[*].if` и `github.event_name`, но y24 считает этот шаг действующей изоляцией, W возвращает 71/71 rc 0. Закрывающее свойство — обязательное выполнение обеих проверок изоляции до первого PR-code шага для PR, а не только наличие текста и более раннего индекса. Это YAML-видимый обход адресного нового y24, не заявление о выполненном живом Actions прогоне; исключённая контрактом живая платформа остаётся НЕ ПРОВЕРЕНО.
ОБХОД: добавить к существующему шагу изоляции `e2e-erstinformation` единственный `if: ${{ github.event_name == 'schedule' }}`; на PR он пропускается, `npm ci`/Jest не пропускаются, все 71 клетки зелёные.
```
$ python3 /tmp/dev-harness-verify/Crit143z-condition.py
MUTATION job=e2e-erstinformation isolation.if= ${{ github.event_name == 'schedule' }}
клеток 71, зелёных 71, красных 0
rc= 0
```

ОБЛАСТЬ. Судился зафиксированный коммит (первым действием `git cat-file -t 91090bb8fea6f60e9f2c4a991b7c5e24eaf80c6a` → `commit`, rc 0) и ДЕЛЬТА ОТ ЕГО РОДИТЕЛЯ, не `main..HEAD` посторонней ветки. `git diff --name-status 91090bb8^ 91090bb8` → M `fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml`, `probe.py`, `source.json`; A девять `fixtures/workshop_project/mob_ci_143/stabs/stab_y_*`: izoljacija_posle_npm118, izoljacija_udalena118, povtor_mertvaja_vetka108, povtor_rc_nol108, povtor_vne_konteksta117, povtor_vtoroj_true108, povtor_vtoroj_true118, povtor_vtoroj_true135, run_bool (все `.py`); всего 12 файлов и нуль за пределами фикстуры. `git diff --exit-code 91090bb8^ 91090bb8 -- contracts/143-mob-ci-razdelenie.md` → пусто, rc 0. SHA256 изменённой модели `mobile.yml`: `401071f04359000258dc3f4c34f0c27374f41762473f233e7646370105f5f896`. Frozen-блоб 143/1 не изменён.

КОНТРОЛЬ РАБОЧЕЙ МОДЕЛИ И СТАРОГО ПРОДУКТА (буквальный вывод проверенных путей):
```
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --model
клеток 71, зелёных 71, красных 0
rc=0
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs
клеток 71, зелёных 71, красных 0
стабов 52, привязок 68, непойманных 0
rc=0
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Impl143e/mob
клеток 71, зелёных 69, красных 2
КЛЕТКА y24-izoljacija-ranera: select-screens: нет шага «Изоляция раннера» ...; quality: нет шага ...; e2e-erstinformation: нет шага ... КРАСНА
КЛЕТКА y23-ispolnenie-povtora: e2e-start/обрыв: rc=1 (канон 0) — шаг упал до/в повторе; e2e-start/обрыв: маркер ПОВТОР не в stderr — мёртвая ветка повтора; e2e-start/обрыв: диагностика Н-407 не в stderr; e2e-start/obryv: maestro-вызовов 1, канон 2 — ветка повтора не исполнена КРАСНА
rc=1
```
В последнем блоке длинная строка красных клеток показана с `...` там, где перечислялись одинаковые причины других job; ПОЛНЫЙ вывод есть в выполненной сессии, здесь это обозначено как выдержка, не как полный raw-log. Честный `108 start` проверен ещё отдельным репро:
```
$ python3 /tmp/dev-harness-verify/Rev143/mut/replay_start_retry.py fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml
MODE --as-is rc=0
stderr: ДИАГНОСТИКА 108: сигнатуры Maestro в maestro-out-start | maestro-out-start/maestro.log:1:CommandFailed: Command failed (host:transport:emulator-5568): device offline | ПОВТОР: обрыв adb-транспорта эмулятора 108 — перезапуск и повтор набора
maestro-вызовов: 2 USTANOVLEN: 2 ПОВТОР в stderr: True
rc драйвера=0
$ python3 /tmp/dev-harness-verify/Rev143/mut/replay_start_retry.py fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml --product-fail
MODE --product-fail rc=1
stderr: ДИАГНОСТИКА 108: сигнатуры Maestro в maestro-out-start
maestro-вызовов: 1 USTANOVLEN: 1 ПОВТОР в stderr: False
rc драйвера=0
```

СВОИ ДРУГИЕ АТАКИ (каждый CASE — независимая копия модели, W --repo, rc и вывод показаны, скрипты одноразовые вне репо):
```
$ python3 /tmp/dev-harness-verify/Crit143z-mutations.py retry
CASE old-parent-model rc=1
клеток 71, зелёных 69, красных 2
КЛЕТКА y23-ispolnenie-povtora: e2e-start/обрыв: rc=1 (канон 0) — шаг упал до/в повторе; e2e-start/обрыв: маркер ПОВТОР не в stderr — мёртвая ветка повтора; e2e-start/обрыв: диагностика Н-407 не в stderr; e2e-start/obryv: maestro-вызовов 1, канон 2 — ветка повтора не исполнена КРАСНА
CASE retry-any-product-failure rc=1
клеток 71, зелёных 70, красных 1
КЛЕТКА y23-ispolnenie-povtora: e2e-start/продуктовый: маркер ПОВТОР в stderr — повтор без сигнатуры; e2e-start/produkt: maestro-вызовов 2, канон 1 — ветка повтора не исполнена КРАСНА
CASE third-maestro-call rc=1
клеток 71, зелёных 70, красных 1
КЛЕТКА y23-ispolnenie-povtora: e2e-start/obryv: maestro-вызовов 3, канон 2 — ветка повтора не исполнена КРАСНА
CASE repeat-return-code-ignored rc=1
клеток 71, зелёных 70, красных 1
КЛЕТКА y23-ispolnenie-povtora: e2e-first-run/продуктовый: rc=0 — продуктовый провал замаскирован КРАСНА
```
Исходный одноразовый скрипт после этих четырёх CASE выбросил `AssertionError` на неправильно выбранном якоре альтернативного first-run; это ошибка АТАКУЮЩЕГО скрипта, а не краснота W. Отдельно исправленная атака:
```
$ python3 /tmp/dev-harness-verify/Crit143z-regress.py
CASE dead-retry-other-screen rc 1
клеток 71, зелёных 70, красных 1
КЛЕТКА y23-ispolnenie-povtora: e2e-first-run/обрыв: rc=1 (канон 0) — шаг упал до/в повторе; e2e-first-run/обрыв: маркер ПОВТОР не в stderr — мёртвая ветка повтора; e2e-first-run/обрыв: диагностика Н-407 не в stderr; e2e-first-run/obryv: maestro-вызовов 1, канон 2 — ветка повтора не исполнена КРАСНА
$ python3 /tmp/dev-harness-verify/Crit143z-detail.py
CASE bool rc 1 stdout:
клеток 71, зелёных 69, красных 2
КЛЕТКА y24-izoljacija-ranera: e2e-erstinformation: нет шага «Изоляция раннера» (буква build-apk) до шага 5 «npm ci --no-audit --no-fund», исполняющего код PR КРАСНА
КЛЕТКА p01-P-nabor: run шага e2e-erstinformation[1] не строка (YAML-bool?): True КРАСНА
stderr: <empty>
CASE if-false rc 1 stdout:
клеток 71, зелёных 70, красных 1
КЛЕТКА y04-net-if-false: есть if:false КРАСНА
CASE continued rc 1 stdout:
клеток 71, зелёных 70, красных 1
КЛЕТКА y05-net-continue-on-error: есть continue-on-error КРАСНА
```
`python3 /tmp/dev-harness-verify/Crit143z-mutations.py isolation yaml` отдельно красил удаление изоляции, её перестановку ПОСЛЕ npm и удаление одной из двух проверок (каждый CASE rc 1, красная y24). На честной модели все десять jobs с PR-code имеют безусловный шаг изоляции раньше первого распознанного запуска: select-screens 1<2, quality 1<6, build-apk 2<3, splash 1<4, first-run 1<6, erstinformation 1<5, start 1<4, pilot 4<7, android-e2e 1<2, mobile-regression-signal 1<2. У честных шагов изоляции нет `if` и `continue-on-error`. Порча `run: true` не даёт исключения Python: приведённые y24/p01 получают красную именованную причину.

ПРОШЛЫЙ ОСТАТОК y19 — ВНЕ НОВОГО БЛОКА. `python3 /tmp/dev-harness-verify/Crit143z-provenance.py` на отдельных копиях вывел:
```
CASE wrong-ref rc 1
клеток 71, зелёных 70, красных 1
КЛЕТКА y19-outputs-provodka: build-apk: checkout с ref: 'refs/heads/main' — чужая ревизия вместо проверяемой (позиция 0) КРАСНА
CASE second-checkout rc 1
клеток 71, зелёных 70, красных 1
КЛЕТКА y19-outputs-provodka: build-apk: второй checkout (позиция 2) подменяет рабочее дерево сборки КРАСНА
CASE verify-or-true rc 0
клеток 71, зелёных 71, красных 0
CASE verify-semicolon-true rc 0
клеток 71, зелёных 71, красных 0
CASE verify-or-echo rc 0
клеток 71, зелёных 71, красных 0
CASE verify-exit-zero rc 0
клеток 71, зелёных 71, красных 0
CASE verify-expression-false rc 0
клеток 71, зелёных 71, красных 0
CASE verify-self-comparison rc 0
клеток 71, зелёных 71, красных 0
CASE git-worktree-repoint rc 0
клеток 71, зелёных 71, красных 0
```
СОВЕТ fixtures/workshop_project/mob_ci_143/probe.py:1726-1733 — маскировка HEAD==GITHUB_SHA в предыдущем Fix143c остаётся известной, принятой границей `Arb143r` п.5 и словом владельца 29.10 ~22:00; honest `run` не замаскирован. Не основание текущего FAIL.

ДВЕРИ (изолированные прогоны в Crit143z; не путать их rc с ложнозелёными мутациями):
```
$ python3 -c 'import yaml; y=yaml.safe_load(open("fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml")); print("YAML_OK jobs=",len(y["jobs"]), "names=", ",".join(y["jobs"]))'
YAML_OK jobs= 10 names= select-screens,quality,build-apk,e2e-splash,e2e-first-run,e2e-erstinformation,e2e-start,e2e-pilot,android-e2e,mobile-regression-signal
rc=0
$ bash scripts/pre_critic.sh --repo . contracts/143-mob-ci-razdelenie.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=4
КРИТИК: дверь зелёная
rc=0
$ bash scripts/check_precision_gate.sh . contracts/143-mob-ci-razdelenie.md
OK
rc=0
$ bash scripts/check_spec_ready.sh . contracts/143-mob-ci-razdelenie.md
OK
rc=0
$ bash scripts/check_ceilings.sh . contracts/143-mob-ci-razdelenie.md
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 139 черновик(ов) судится, замороженные — по тегам
потолки в порядке
rc=0
$ bash scripts/check_threat_model.sh . contracts/143-mob-ci-razdelenie.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 9 буллет(ов), НЕ ЗАЩИЩАЕТ 9 буллет(ов))
rc=0
$ bash scripts/check_predposylki.sh . contracts/143-mob-ci-razdelenie.md
PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=4
rc=0
$ bash scripts/check_contract_frozen.sh .
  ok   contracts/143-mob-ci-razdelenie.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают
rc=0 [прочие контракты из вывода опущены]
$ bash scripts/check_zones.sh .; printf 'check_zones_rc=%s\n' "$?"
замороженных контрактов: 142 · объявленных авторов: 5 · коммитов в диапазонах: 37643 · проверено по зонам: 8429
check_zones_rc=0
```
Финальный `check_zones` запущен ПОСЛЕ атак, timeout 1200 секунд; дождались `[async-result]`, `artifact://14365:-8`; из вывода взят именно `check_zones_rc=0`, wall time 329.67s. Первый одновременный с `pre_critic` запуск precision-gate гонялся за общим `/tmp/lib_zones` и был ошибочным; здесь указан отдельно исполненный последовательный rc 0.

НЕ ПРОВЕРЕНО: живой GitHub Actions/Android CI на новой модели, self-hosted runners, branch protection, ночной schedule. В песочнице выполнялись тела workflow-шагов и подложки; полномасштабную платформенную семантику они не доказывают. Контракт, исходный коммит архитектора и продукт не менялись; commit/push в origin по ограничению задания не делались. Этот файл — вердикт в отдельном клоне, для последующего переноса оркестратором.
