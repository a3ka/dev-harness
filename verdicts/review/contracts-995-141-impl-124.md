accept
OBJECT=67f7343950ece44e2fd53d22c11bb35cf403e07f

СУД: repo=Complior-mob (+dev-harness); предмет=995 и 141 (реализация в PR a3ka/Complior-mob#124); фаза=реализация; роль=reviewer; вызов=1/2 (полный); модель-план=anthropic/claude-opus-5-5 (`config/agent_models.json`: reviewer→audit→@opus); сессия=01a17f37-6784-702e-8cb1-0708fa3a2ac5 (агент Rev124a); модель-факт=anthropic/claude-opus-5-5; SHA=67f7343950ece44e2fd53d22c11bb35cf403e07f; предыдущий=141: `verdicts/review/contracts-141-impl-v1.md` accept на `33beed4ca`; 995: нет; исключение=нет
Независимость: все 23 коммита ветки — `user.name=implementer` (MiniMax по заданию: Impl995 v2/v3/v4, Impl141); судья — Anthropic Opus, другое семейство.

## Кандидат и пины (сырые команды)

- `gh pr view 124 -R a3ka/Complior-mob --json headRefOid` → `"headRefOid":"67f7343950ece44e2fd53d22c11bb35cf403e07f"`, state OPEN, base main. Совпадает с OBJECT.
- `git cat-file -t 67f7343950ece44e2fd53d22c11bb35cf403e07f` → `commit`; `git checkout -q` → HEAD = OBJECT.
- Харнесс: `frozen/contracts/995/4^{commit}`=`5cc325a9dc4da004b952a24bcaae8f578d591667`, `141/1`=`df66a1fd647a0366ba293fe79f5f91aaabffe58d`, `139/2`=`8ce080c67a777965bb36476bb22a6fb826b84d12`. Для каждой метки свой worktree.
- `sha256sum mob/mobile/scripts/ci-e2e.sh` → `0fa425b5db4752633c7ea453065503bfa8ecefa67e1bef8a7e66102426897f30`; `git show 'frozen/contracts/995/4^{commit}:…/restart/model/ci-e2e.sh' | sha256sum` → `0fa425b5…7f30`. **Байт-в-байт, совпадает.**
- `sha256sum mob/.github/workflows/mobile.yml` → `f45c68230eb83b12c8aa81173da4b9d46608b966acfef7da7ba6178d21087421` = пин 139/2 (`e2e_avtoperezapusk_139/source.json` nositeli `mobile.yml`); `git show 799bbc8:.github/workflows/mobile.yml | sha256sum` → тот же хеш (после 995 v2 файл не менялся).
- P: `git show 66052cdf…:fixtures/workshop_project/pilot_995/maestro_probe.py | sha256sum` = `git show 995/4:…/maestro_probe.py | sha256sum` → `9a556b48cf4f84a988ba520e6e9ec7389004f461173a8202c6dfb34528803749` (не менялся). `git merge-base --is-ancestor 66052cdf 995/4` → 0.
- Пины H в mobile.yml@OBJECT: native-шаг 995 (стр. 283) `66052cdfd134ab0958421a961caef219694a54df`; quality (стр. 87) `b9b4c66f…`. Проверил: `git diff --name-only b9b4c66f..995/4 -- fixtures/workshop_project/pilot_995/` вне `restart/` даёт только `maestro_probe.py`, а quality его не вызывает. Расклад пинов согласован.
- `gh pr checks 124` → `android-e2e pass` (job 122465527248), `quality pass`; `mergeStateStatus CLEAN`.

## 995 v4 — реализация (`mobile/scripts/ci-e2e.sh`)

1. **История правок S в ветке** (`git log c3235fb..HEAD -- mobile/scripts/ci-e2e.sh`): `799bbc8` v2 (d8841d6b…, + пин H в mobile.yml), `ba5ebbc` v3 (99759129…), `c617f6f` v4 (0fa425b5…). В каждом коммите по одной задаче со ссылкой на предмет: `git show --stat` — v3 и v4 трогают только ci-e2e.sh, v2 — ci-e2e.sh и одну строку пина. Итоговый файл равен модели v4.
2. **Приёмка батареи 995/4** (worktree 995/4, `reslop t -- bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh …`; клетки считал своей мерой — `grep -c '^CASE .* ok$'` по сырому логу):
   - `--repo …/Rev124a/mob`, прогон 1 → **rc 1**, 50/51 ok. Красная одна: `CASE inkarnacija-mertva-pered-vtorym KRASNO (ACTIONS: rc=0 (ожидался 1))`. В тот момент: `uptime` load 4.39, параллельно шли jest Rev124b и CI-задачи станции. Разбор в СОВЕТ-1.
   - `--repo …/Rev124a/mob`, прогон 2 → **rc 0, 51/51** (`grep -c '^CASE '`=51, ok=51), `SVIP itog: N=20, krasnykh 0`.
   - `--model` (контроль, один раз) → **rc 0, 51/51**, SVIP N=20, krasnykh 0.
   - `--stabs` (контроль, один раз) → **rc 0**: контроль 51/51 ok, `SVJAZI 60`, `zhivykh 0`. Стаб `s-zhizn-tolko-na-gotovnosti` красен ровно на `inkarnacija-mertva-pered-vtorym`.
   - S побайтно равен модели, поэтому `--repo` и `--model` исполняют одни и те же байты. Расхождение исходов между прогонами 1 и 2 — недетерминизм подложной среды, а не свойство S.
3. **Живая серия A** (run 40570602069, head_sha = OBJECT во всех 5 попытках; `gh api …/attempts/<a>/jobs`). android-e2e: 122425010734 / 122437140172 / 122446303161 / 122455967964 / 122465527248 — все `success` на `station-complior`. Копии логов в orch совпадают с живыми: `gh api …/jobs/<id>/logs | sha256sum` = `sha256sum < seria124-job-<id>.log` для всех 5 (900c00c9…, d0556df3…, 248d68ec…, c91daff0…, 9970d55d…).
   - Строка `995 native rc=0 testcases=7 failed=0` есть во всех 5. `995 sobytie: RECOVERED` есть **в попытках 1, 2, 4** (jobs …010734, …140172, …967964), в 3 и 5 нет — там попытка 1 набора зелёная. **Поправка к заданию:** «RECOVERED в 1, 3, 5» неверно. 1, 3, 5 — это попытки, где был шаговый ПОВТОР 141 (135/118), см. ниже.
   - `NATIVE_EVIDENCE_INCOMPLETE` во всех 5 логах: 0 вхождений (`grep` rc 1). `##[error]`: 0.
   - Артефакты. `gh api …/runs/40570602069/artifacts` отдаёт только попытку 5. Мой `gh run download -n maestro-5f19336…-40570602069-5` дал `diff -r` с копией orch `seria-art/5/…` → IDENTICAL. Для попыток 1–4 использованы копии orch (своей загрузки нет: артефактов этих попыток в API уже нет).
     - Структура по всем 5 попыткам: ровно один каталог `<ts>/`, 7 флоу, **24 вложенных** `<ts>/<флоу>/takeScreenshot/*.png`, PNG верхнего уровня 0, report.xml `tests="7" failures="0"`, `rehearsal-evidence/` присутствует, в логе `rehearsal evidence OK`. Публикуется финальная попытка живым деревом, без деревьев нефинальных попыток (один ts-каталог при RECOVERED).
     - RECOVERED-попытки (1, 2, 4): `diagnostics/attempt-1` (diag: adb-devices, emulator.log, logcat-do, logcat-posle, manifest; maestro.log, report.xml `failures="6"`; `flows/` упавших) и `diagnostics/attempt-2` (boot-снимок, maestro.log 7/7 Passed). Каноническая сигнатура найдена в артефактах попытки 1 (`maestro.log`, `flows/*/maestro.log|commands.json`).
     - Manifest попытки 1 run-1: `boot`/`otkaz` pokolenie=1 `emulator_pid=295014` `guest_boot_id=eb79d791…`; attempt-2 pokolenie=2 `emulator_pid=309768` `guest_boot_id=e16cfa31…`, тот же `avd=ci-40570602069-1 port=5560`. Значит, новая инкарнация на тот же AVD/порт, сервер adb не перезапускался (PID в поле не изменился; оговорку о достоверности поля см. в СОВЕТ-2). Поля utc/monotonic/run/github_attempt/local_attempt/netns/mem/cgroup/PSI/boot_id/adbd присутствуют, недоступные помечены `<недоступно>`.
     - Опубликованный `maestro.log`: `ПОВТОР: обрыв adb-транспорта попытки 1 по канонической сигнатуре …` → `RECOVERED: …`. Повтор ровно один.
   - Секрет. В шаге `PILOT_DEMO_CODE` встречается только в теле скрипта (`[ -z "$PILOT_DEMO_CODE" ]`, `printf '%s' "$PILOT_DEMO_CODE" > …/code`) и в `env:` как `PILOT_DEMO_CODE: ***` (замаскирован). Echo значения нет. В артефактах 86 файлов с `[REDACTED]`, включая `"PILOT_DEMO_CODE" : "[REDACTED]"` и `"text" : "[REDACTED]"`. Литерал mock-кода продукта `synthetic-verification-value` (`mobile/src/mocks/demo-code.ts`) в 6 логах и во всех артефактах серий A/B найден 0 раз. Совпадает ли секрет CI с этим литералом, не известно; поэтому это проверка кандидата, а не значения секрета.
   - Свип смерти owned PID вживую не наблюдаем (событий смерти в серии нет). Его держит батарея: `inkarnacija-smert-svip` N=20, krasnykh 0; стабы `s-zhizn-*` красны на своих клетках. Остановка именно старого PID вживую видна только косвенно: новый PID стартовал на тот же порт 5560 [INFERENCE: старый процесс освободил порт].
4. **Красная серия Б** (run 40570609019, head_sha = OBJECT, ветка `cmp-mob-118/seria-b`; попытка 1, job 122425232044, `station-complior-2`; копия лога = живой, sha256 b1886bd3…):
   - Лог: `995 sobytie: EXHAUSTED: попытка 2 красная (rc=1) — итог красный, третьей попытки нет`, `995 native rc=1 testcases=7 failed=7`, job `failure`. Итог красный, а не зелёный.
   - Опубликованный `maestro.log`: ровно один `ПОВТОР` и затем `EXHAUSTED`. Сохранены `diagnostics/attempt-1` и `attempt-2` (diag + maestro.log + report.xml, у обоих `failures="7"`, `DeviceServerDiedException … 'deviceInfo' … 166–245 ms`). Новая инкарнация: pid 306626 → 317979, boot_id e3e9e9d2… → 801e9d62….
   - Отказ продукта до флоу (Maestro не дошёл ни до одного шага), повтор израсходован по канонической сигнатуре — оба поведения соответствуют инв. 7/8. **Дефекта реакции кода не вижу.**
   - Шаг 141 для 995 вывел `ДИАГНОСТИКА 995: adb devices` и `ДИАГНОСТИКА 995: сигнатуры Maestro в mobile/maestro-out` после endgroup, вне эха; шагового повтора нет (инв. 2/7 контракта 141).
   - Факт для разбора причины (не для суда): попытка 1 Б (`report.xml` timestamp 19:45:50 и 19:46:41) целиком легла в окно набора попытки 2 серии A (19:45:50–19:47:53, зелёный). Попытка 2 Б (job 122429098319, 19:47–20:05) — **success** на runner-2 (`995 native rc=0 testcases=7 failed=0` в 19:54:53), её 995-шаг шёл одновременно с шагами 117/135/118 серии A, но не с 995-набором A. Оба раннера используют `PORT=5560`/`emulator-5560` (жёстко в S, разные netns) и общий `-Duser.home=/var/lib/ci-runner/home`. [INFERENCE: гипотеза — коллизия двух одновременных 995-наборов на общем ресурсе вне netns; не установлено.]

## 141 — дельта с принятого `33beed4ca`

- `git diff 33beed4ca3ac5bc77cef628ce874b2f1f5c1d277..67f7343950ece44e2fd53d22c11bb35cf403e07f -- .github/workflows/mobile.yml` → `1 file changed, 1 insertion(+), 1 deletion(-)`, это ровно `ref: b9b4c66f… → 66052cdfd134ab0958421a961caef219694a54df` у `Checkout frozen probe harness H` native-job. Пара коммитов откат `c87531f` / возврат `daa95a8` нетто-нулевая. Тела шагов 135/118/995 (и 117) с accept не менялись.
- Батарея 141 (worktree 141/1): `bash …/red_obryv_adb_diagnostika_141.sh --repo …/mob` → **rc 0, 41/41** (41 строка, все `ok`).
- Живые события (счёт строк вне эха `^<ts>Z <маркер>` по 5 логам серии A): `ПОВТОР … 135` = 1/0/1/0/1, `ПОВТОР … 118` = 1/0/1/0/1, `ДИАГНОСТИКА 135` = 3/0/3/0/3, `ДИАГНОСТИКА 118` = 3/0/3/0/3. Все 5 job зелёные. Каждый шаг повторялся не больше одного раза, после повтора — зелёный. Отдельно ПОВТОР темы 117 = 1 во всех 5 (шаг 117, не 141).

## Совместимость с заморозками

- W139 (worktree 139/2): `bash …/red_e2e_avtoperezapusk_139.sh --repo …/mob` → **rc 0, 42/42** (`awk` по сырому логу: 42 `CASE ok`). Пин mobile.yml `f45c6823…` верен (см. выше).
- ЗОНЫ. `git diff --name-only origin/main...HEAD` → 38 файлов. Классифицировал по ЗОНА implementer из блобов 995/4, 141/1, 117/4, 118/2: 1 `.github/workflows/mobile.yml` (995/141/117/118); 4 `mobile/.maestro/*` (995/117/118); 1 `mobile/scripts/ci-e2e.sh` (995); 12 `mobile/src/app/*`, `src/bootstrap/__tests__/*`, `src/bootstrap/pilot-app.tsx`, `src/mocks/pilot-responses.json` (995/118); 8 `mobile/e2e-erstinformation/*` (118); 12 `mobile/src/features/onboarding/*` (118). **Вне зон: 0 файлов.** `check_zones.sh` харнесса судит историю dev-harness (`frozen/contracts/<NNN>/1..HEAD`), к коммитам продукта он неприменим. Сделана ручная сверка той же грамматикой зон.
- Merge-gate `.review/`. В Complior-mob каталога `.review/` нет, т.е. для mob-PR гейт неприменим. В основном чекауте харнесса 138 файлов `ready|partial`; про 995 только `2026-10-18-01..03` (PR #108, OBJECT e883d533/807e390f/e44dfd09 — прежняя реализация, не этот кандидат). Про #124/ci-e2e v4/141 ни одного.

## СВЕРКА-СТАНДАРТОВ

`AGENTS.md` продукта объявляет только `STRUCTURE.md`; `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` нет.
- STRUCTURE.md §дерево (стр. 44–45 `mobile/scripts/` «CI, … не runtime», `ci-e2e.sh`) — соответствует.
- STRUCTURE.md стр. 26 `.github/workflows/ mobile.yml: quality и android-e2e` — соответствует.
Других разделов дифф 995/141 не затрагивает.

## ПРОВОДКА (038)

- 995: guard `fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh` существует и бьёт именно этот предмет: исполняет настоящий S и красен на 60 привязках стабов. Строка ПРОВОДКА-ЭНФОРСМЕНТ обоснована: норма механическая (owned PID, один повтор, канон сигнатуры). Role-канал — orchestrator done_contract.
- 141: guard `obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh` существует, судит тела трёх шагов.
- Подключение к CI харнесса: в `registry/ci-steps.tsv@85737c9` строк батарей 995 и 141 нет (есть только 139 `--stabs`). Это окно freeze..done оркестратора, см. СОВЕТ-4.

## Паразитная сложность (050)

- `mobile/scripts/ci-e2e.sh` v4. (1) Свойство: инв. 9 v4 — публикация финальной попытки живым деревом. (2) Новое состояние — только выбор дерева финальной попытки при `opublikovat`, видно в выводе (RECOVERED/EXHAUSTED) и в структуре публикации. (3) При следующей правке меняются вместе модель + копия S, т.е. 2 файла, как и до диффа. (4) Интерфейс не вырос: аргументы, env и коды возврата те же, что у v3. (5) Потребитель — `W --repo` и шаг native mobile.yml. Логику P/rehearsal-гейта он не повторяет, а кормит их. **ESSENTIAL.**
- Строка пина H в mobile.yml. (1) Свойство: 995 §Пины, H native-шага = заморозка с P. (2)–(4) Нового состояния нет, одна строка. (5) Потребитель — native-шаг. **ESSENTIAL.**

## БЛОКИРУЕТ

Нет.

## СОВЕТ

- **СОВЕТ-1** (architect, батарея 995/4). Клетка `inkarnacija-mertva-pered-vtorym` недетерминирована под нагрузкой станции. Приёмка `W --repo` на побайтно модельном S один раз дала rc 1 (50/51, `ACTIONS: rc=0 (ожидался 1)`), повтор — rc 0 51/51. Механика (`restart/probe.py` ADB_SH/EMULATOR_SH): смерть подложного эмулятора `posle-logcat` — поллинг `grep -c` раз в 0.05 с, у подложного `adb logcat` фиксированное окно `read -t 0.8`. Расчёт на то, что за 0.8 с эмулятор выйдет и bash S успеет его пожать до `kill -0`. При перегрузке окно не успевает. До сбора зомби `kill -0` тоже возвращает успех [INFERENCE]. Контракт заявляет «три прогона подряд rc 0». Закрывающее свойство: смерть в этой клетке синхронна событию журнала — стаб не выходит, пока PID эмулятора жив/не собран (ждёт `EMULATOR_STOP` + `! kill -0`), а не по таймеру. Реализацию не блокирует: S = модель.
- **СОВЕТ-2** (architect, модель S, инв. 9 «adb-сервер»). Поле `adb_server=$(ps -eo pid,etimes,args | grep -m1 '[a]db.*fork-server')` берёт первый fork-server во всём PID-пространстве. На станции два сервера adb в разных netns: read-only замер `readlink /proc/<pid>/ns/net` → `1219497 net:[4026533563]` (runner-2) и `1904176 net:[4026531840]` (runner-1). Серия A (netns 4026531840) записала `adb_server=1219497`, т.е. **чужой** сервер, а свой (1904176) не записан. Для разбора красной серии Б это поле нельзя читать как «общий adb-сервер». Закрывающее свойство: поле выбирает сервер с `/proc/<pid>/ns/net` = netns снимка (либо перечисляет все с netns). Реализацию не блокирует: S = модель, поле присутствует.
- **СОВЕТ-3** (оркестратор, точность задания). (а) RECOVERED 995 — в попытках 1, 2, 4, а не «1, 3, 5»; 1, 3, 5 — шаговый ПОВТОР 141 (135/118). (б) В задании sha256 P записан как `…004f4611738a8202…` (65 символов); фактически `9a556b48cf4f84a988ba520e6e9ec7389004f461173a8202c6dfb34528803749`, совпадает с `9a556b48…` контракта. (в) «Одна красная попытка Б»: у run 40570609019 попытка 2 зелёная на runner-2.
- **СОВЕТ-4** (оркестратор, ПРОВОДКА до done). Строк self-test батарей 995 (`red_ci_e2e_restart_995.sh --stabs`) и 141 в `registry/ci-steps.tsv` на main харнесса нет. ПЕРЕСЕЧЕНИЕ orchestrator контракта 995 предусматривает их в окне freeze..done. Тегов `done/995*`, `done/141*` нет.
- **СОВЕТ-5** (владельцу/оркестратору). `AGENTS.md` продукта @OBJECT: «**Merge нажимает владелец.** Агенты не мержат PR». В задании merge #124 — за оркестратором (`--match-head-commit`). Нужна сверка с действующим словом владельца (в HANDOFF упомянут незапушенный `AGENTS.md mob e0da55163`).

## НЕ ПРОВЕРЕНО

- Живой DAG/required-checks на настройках ветки GitHub: не смотрел, прочёл только `gh pr checks` (pass/pass).
- Runner-2 одиночный (без параллельной серии A) на этой голове: отдельной серии нет. Есть только зелёная попытка 2 Б, частично совпавшая по времени с A.
- Причина EXHAUSTED в Б не установлена (см. факты и [INFERENCE] выше).
- Артефакты попыток 1–4 серии A — только копии orch (в API их уже нет); моя загрузка и сверка — только для попытки 5.
- Совпадение секрета CI `PILOT_DEMO_CODE` с mock-литералом не известно. Grep по значению секрета невозможен — проверены отсутствие echo, маскирование `***` и `[REDACTED]` в артефактах.
- Визуальная сверка PNG и cognitive-only пункты 995 (ApiClient/AuthProvider, слои F03/F02) — вне этого вызова (дельта ci-e2e v4 + 141). Мобильный экран/кадры — у Rev124b (117/118).
- Свип смерти owned PID вживую: событий смерти в серии нет, держит только батарея.
