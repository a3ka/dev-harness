# Контракт 141 v3 — диагностика обрыва adb в скриптах работников 135/118/995

КЛАСС ЗАДАЧИ: КОДОВЫЙ (CI-инфраструктура продукта и красная батарея харнесса).
КЛАСС РИСКА: обычный — только диагностика/повтор CI, без прав, денег, ПД и согласий.
РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/141-obryv-adb-diagnostika.md — v+1 (141 v3): шаги 135/118/995 судятся в скриптах (sha256-пин + повторный прогон из скриптов) вместо построчных тел в mobile.yml; слово владельца 2026-11-05 ~13:55 UTC «если ты все перепроверил и здесь надо "да", то ок»

## Предмет

КОНТЕКСТ: Н-407: 42 из 58 красных android-e2e за сутки — обрыв adb: 135 ×17, 995 ×17, 118 ×8. Диагностика до 141 скрывалась в артефакте Maestro или невыгружаемом emulator-логе; признак 139 вне эха не видел её. Не предмет: splash/пустые кадры/gradle-lock, расширение сигнатур 139, правка `ci-e2e.sh` или `maestro_probe.py`.

## Существующее

Frozen 141/2 и `fixtures/workshop_project/obryv_adb_diagnostika_141/` уже несут 46 сценариев, 66 связей с обманными стабами, проверку управляющих свойств шага/job/workflow и needs-ребра 143, плюс замкнутый replay в CHISTYJ и ACTIONS. Арбитраж `verdicts/arbitration/contracts-141-arbitraz.md` закрыл обходы управляющих свойств; `verdicts/critic/contracts-141-v2.md` принял защиту needs-ребра. Frozen 135/118/995 описывают своих работников, 995 уже повторяет внутри `mobile/scripts/ci-e2e.sh`; 139 судит повтор всего workflow, не дополнительный повтор 995. Контракт 143 распределяет 135 → `e2e-first-run`, 118 → `e2e-erstinformation`, 995 → `e2e-pilot` и required-агрегат. v2 пинил построчно три длинных `run:`; дальнейший 143 cutover требует судить вынесенные скрипты, не копии их тел в `mobile.yml`.

## Решение и инварианты

Единственное изменение v3: три длинных тела v2 переходят в файлы продукта `mobile/scripts/ci-first-run-135.sh`, `mobile/scripts/ci-erstinformation-118.sh`, `mobile/scripts/ci-pilot-995.sh`. Каждый из трёх прежних шагов в своей работе `mobile.yml` вызывает СВОЙ файл из checkout R: соответственно `bash mobile/scripts/ci-first-run-135.sh`, `bash mobile/scripts/ci-erstinformation-118.sh`, `bash mobile/scripts/ci-pilot-995.sh`. Ни один скрипт не берётся из `.harness*` или модельного дерева во время суда субъекта. Модельные файлы под `fixtures/workshop_project/obryv_adb_diagnostika_141/model/mobile/scripts/` — извлечённые из модели v2 тела с заменой только GitHub Actions `${{ github.workspace }}`/`${{ github.run_id }}`/`${{ github.run_attempt }}` на shell-переменные `$GITHUB_WORKSPACE`/`${GITHUB_RUN_ID}`/`${GITHUB_RUN_ATTEMPT}`; секреты и алгоритмы не меняются. `model/mobile.yml` оставляет прочие работы/шаги нетронутыми и содержит только вызовы вместо трёх длинных тел.

1. Проверяющий до чтения субъекта загружает в память `source.json` и все четыре модельных носителя, сверяет их байтовые SHA256 из `source.json`; рассинхрон → rc 2 `ORACLE_TAMPERED`. При `--repo R` читает `R/.github/workflows/mobile.yml` и именно три файла `R/mobile/scripts/ci-*.sh` в память. Отсутствующий скрипт — именованный красный `SKRIPT_<N>_NET`, не fallback на модель; у изменённого скрипта красный `SKRIPT_PIN_RASHOZHDENIE`. SHA256 применяется ко ВСЕМ байтам скрипта (включая комментарии), а не к телам `mobile.yml` или всему workflow.
2. `run` трёх именованных шагов проверяется как единственная нормализованная команда вызова соответствующего скрипта; пустые строки/комментарии `mobile.yml` свободны, иной вызов → `VYZOV_SKRIPTA`. Шаг отсутствует → `SHAG_<N>_NET`. Управляющие ключи этих шагов и трех job, workflow defaults/env, канонические job-if и буквальное needs-ребро `select-screens` сохраняют барьер v2 (включая `REBRO_NEEDS`): скрипт без достижимого вызова не проходит проверку.
3. Replay **исполняет из файла** скрипт субъекта под подложными adb/emulator/avdmanager/python3 в замкнутом PATH, отдельно в CHISTYJ и ACTIONS. Не исполнять модель при проверке `--repo`; не перечитывать ожидания с диска проверяемого. Изменённый алгоритм обязан проявиться как красный собственным входом, даже если SHA256-пин уже красен другим входом. Вся привязка стабов к входам задана кодом `probe.py` и `source.json`, а не таблицей прозы.
4. Поведение v2 сохраняется: при красном результате 135/118 диагностика `adb devices`, сигнатуры Maestro и хвост 40 строк `emulator-$AVD.log` выходят в stderr вне эха; при загрузке/стабильности — именованный отказ и диагностика. Только четыре альтернативы строки канона `source.json` (`device offline|adb: device not found|device [^ ]* not found|DeviceServerDiedException`) разрешают один перезапуск **эмулятора и валидатора**; повторный красный остаётся красным, третьего запуска нет; `INSTALL_FAILED`/пустой лог/ошибка происхождения не повторяются. 995 выдаёт adb и сигнатуры Maestro при отказе, один вызов `maestro_probe.py`, шагового повтора нет (собственный повтор 995 остаётся в `ci-e2e.sh`). У скриптов число вхождений канона: 135 — 2, 118 — 2, 995 — 1.
5. Чужой шаг `mobile.yml`/прочие job свободны; законные перемены `runs-on`, timeout ≥1 и зелёные job-ключи сохраняются. Никакого пина байтов всего `mobile.yml`. Передающие workflow-шаги не расширяют ключевой алфавит замороженной модели. Контрпример конформен, если это YAML c тремя именованными шагами в указанном DAG либо модификация одного из трёх скриптов; валидное опровержение = расходящийся результат на таком входе при неизменных независимых ожиданиях.

## Приёмка (команды исполняются из корня харнесса)


- Дано: продукта нет; когда: `bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh`; тогда: rc 1 `SUBJECT_ABSENT`, каждый из 46 входов `KRASNO`.
- Дано: модельные файлы с пинами; когда: `bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --model`; тогда: rc 0, 46 `CASE … ok` (22 replay, 15 struktura, 9 derevo). Изменённый байт каждого модельного скрипта или модельного workflow при неизменном `source.json` → rc 2 `ORACLE_TAMPERED`.
- Дано: модель + обманные стабы; когда: `bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --stabs`; тогда: rc 0, 46 `CASE … ok`, 54 стаба / 69 `STAB … KRASEN`, `SVJAZI 69`, `zhivykh 0`. Среди них отдельный обход вызова 135, отсутствие скрипта 995 и изменения байтов всех трёх скриптов; поведенческие стабы ловятся **replay изменённого скрипта**, не только пином.
- Дано: disposable product-tree с тремя скриптами; когда: `python3 fixtures/workshop_project/obryv_adb_diagnostika_141/repo_control.py`; тогда: rc 0, `CONTROL_REPO_GREEN rc=0 cases=46`, `CONTROL_PIN_RED rc=1 SKRIPT_PIN_RASHOZHDENIE` и `CONTROL_CALL_RED rc=1 VYZOV_SKRIPTA` (скрипт субъекта подменён при прежнем workflow, затем вызов подменён при прежних скриптах).
- Дано: живой продукт без выноса скриптов, `R=/home/harness/projects/Complior-mob`; когда: `bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /home/harness/projects/Complior-mob`; тогда: rc 1, `VYZOV_SKRIPTA` и `SKRIPT_<N>_NET` (либо `SHAG_<N>_NET`, если отсутствует задача после cutover 143). После переноса на дерево продукта с тремя скриптами из модели и тремя вызовами → rc 0 46/46. Подмена тела скрипта при прежнем workflow → rc 1 `SKRIPT_PIN_RASHOZHDENIE`; подмена вызова при прежних скриптах → rc 1 `VYZOV_SKRIPTA`.
- Дано: этот v3 кандидат; когда: `bash scripts/pre_critic.sh --repo . contracts/141-obryv-adb-diagnostika.md`; тогда: rc 0 «КРИТИК: дверь зелёная». Перед freeze/done: `bash scripts/check_provodka.sh . contracts/141-obryv-adb-diagnostika.md` → rc 0; при `harness.project.json` также `bash scripts/check_project_sources.sh --repo . --contract contracts/141-obryv-adb-diagnostika.md --stage done` → rc 0. Следующие суды и freeze — оркестратор.

## Модель угроз

ЗАЩИЩАЕТ:
- от пустого субъекта, отсутствия или изменения любого из трёх скриптов, обхода вызова, обрыва диагностики и повтора вне четырёхальтернативного канона: пины, структурный вызов и фактический replay скриптов;
- от ложной зелени при недостижимых шагах/job и подавленном красном результате: v2 алфавит управляющих ключей и needs-ребро сохраняются;
- от хрупкости соседей: скриптовые пины не привязывают весь `mobile.yml`; контроль законных изменений чужого шага.

НЕ ЗАЩИЩАЕТ:
- исполнение живого Android/эмулятора вместо шимов, размещение stderr GH Actions относительно `##[endgroup]` и судьбу qemu после настоящего обрыва: ловец — первое живое падение в CI;
- код шагов ДО целевых и достижимость workflow целиком по событиям `on:`/статусам предшествующих job: ловец — ревью diff и обязательная проверка PR;
- расширение сигнатур/повтора 139, классы splash/пустых кадров и gradle-lock: отдельные предметы.

## Зоны, зависимости и проводка

ЗОНА architect: contracts/141-obryv-adb-diagnostika.md fixtures/workshop_project/obryv_adb_diagnostika_141/
ЗОНА implementer: .github/workflows/mobile.yml mobile/scripts/ci-first-run-135.sh mobile/scripts/ci-erstinformation-118.sh mobile/scripts/ci-pilot-995.sh
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
Репозиторий implementer — продукт; только три вызова и три новых скрипта, остальные части workflow неизменны. Замороженные 135/118/995 и 143 пересекаются по смыслу, но вынос тела в собственный скрипт не меняет поведения и границы job. Проводка в CI харнесса — только интеграционный коммит оркестратора после freeze. Живые продуктовые правки — после окна 139 и cutover 143; push от architect запрещён.

ПРЕДПОСЫЛКИ:
- setting python3 и PyYAML для батареи харнесса; без секретов и сети.
- setting продуктовый CI запускает bash из рабочего каталога checkout R с доступными GITHUB_WORKSPACE, GITHUB_RUN_ID и GITHUB_RUN_ATTEMPT; снимок модели основан на DAG 143.
- setting PR продукта меняет именно три шага и три новых файла, без правки `ci-e2e.sh`/прочих обязанностей 135/118/995/139.

ПРОВОДКА:
- guard=fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh

ПРОВОДКА-ЭНФОРСМЕНТ: доказательство поведения 135/118/995 — исполняемый replay файлов субъекта + байтовые пины, не длинные тела workflow; `--stabs` в CI харнесса до внедрения и `--repo` после внедрения; строку CI проводит оркестратор.

## Незаполненные требования:
нет
