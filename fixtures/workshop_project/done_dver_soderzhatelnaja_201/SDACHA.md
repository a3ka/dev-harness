# Сдаточный лист 201 — действующая машинная форма (m2725)

SOURCE: `9d37c35a714a52deeba7fd91753dceea1a5c8c38` (parent
`47f61ba470d094a96af7045be468d35b789a03bc`). C =
`contracts/201-done-dver-soderzhatelnaja-sverka.md` этого SOURCE; A2 =
`verdicts/arbitration/201-granica-done-dveri-2.md` того же SOURCE.
Полный предшествующий разбор:
`/tmp/dev-harness-verify/consultant/201-form-reconcile-original-report.txt`
(Architect201FormReconcile/artifact16476); разрешение только узкого адаптера —
`/tmp/dev-harness-verify/task-architect201-matrix-adapter.md`, m2725.

## Существующее и граница проводки

`dver_probe.py:116–119` уже использует прямой subprocess argv и снимает rc/вывод
до сверки; этот приём переиспользован. Его `run` объединяет stderr со stdout,
поэтому для matrix он непригоден: диагностический поток должен оставаться
отличимым от протокола. `rezhim_996/probe.py:1567–1590` — единственный источник
порядка CASES/MUTANTS и суммы несовпадений. Определения снимаются в память
до child; ни probe, ни parser, ни контракт не меняются. Существующий
`rezhim_996/probe.sh` добавляет npm-dispatch и не тождествен исходной команде.

Единственная adapter-строка ниже означает ДОСЛОВНО исходную команду C:118:
`PYTHONDONTWRITEBYTECODE=1 python3 fixtures/workshop_project/rezhim_996/probe.py --matrix`.
Исходный предикат: `examined=111`, `mismatches≤1`; допускаются raw child rc=0
при нуле и rc=1 при одном несовпадении. Adapter возвращает rc0 для обоих.
Проверяются все строки исходного протокола и согласованность суммы/итога/rc;
rc2/PROBE_ERROR, stderr, сигнал, неполный/неразобранный/противоречивый вывод
не являются нормативным одним mismatch. stdout/stderr сохраняются байтами,
raw child exitstatus печатается отдельно. Наследуется остальное окружение;
меняются только заданный ENV и TMPDIR в собственном `<repo>/tmp`.
Это локальный предикат одного пункта, не executor/DSL или новый критерий.

Публичные швы адресного доказательства: предикат над завершённым результатом
probe и вызов subprocess с буквальным argv/ENV. Полные синтетические записи
подчиняются протоколу probe, ожидания 0/1 заданы независимо; реального child,
Git/session/state/journal/event-писателей proof не вызывает. Подмена лишь
транспорта в памяти НЕ объявляется actual matrix. Кодовые стабы always-green,
reject-one, lost-matrix и lost-ENV привязаны в `matrix_996_201_proof.py`.
Честные эквивалентные записи: mismatch в базовой клетке либо в mutation,
различный текст assertion; обе границы 0 и 1 принимаются.

## Условия стадий и свидетельства

Ряды «Двери» — действующие обязательства после сборки реализации (C:117,
A2:94), а не повтор дореализационного красного опыта C:116. Оба rc-поля —
предписанный результат при исполнении `check_sdacha --run`, НЕ утверждение
о новом фактическом прогоне. Полный набор сейчас NOT_RUN: его исполняет main
после 037 на цельном кандидате без ambient GIT_AUTHOR_*/GIT_COMMITTER_*.
`SDACHA_OKRUG=1` штатно разрывает рекурсию pre_critic, новый обход не вводится.
187 сохраняет CELLS=54; актуальные числа 201 берутся из живого вывода,
старые 45/15/30 остаются историей согласно A2:92.
ACTUAL_MATRIX=NOT_RUN: здесь native-клон под `/zones/`, unsafe matrix не запускался.
Адресное доказательство запускается отдельно единожды после цельной правки:
`fixtures/workshop_project/done_dver_soderzhatelnaja_201/matrix_996_201_proof.py`.

Условные обязанности C:119 — ДО freeze ПОСЛЕ подключения CI, исполнитель
orchestrator; не безусловные команды architect и не исключённые обязательства:

| Условная команда (дословно) | Предписанный rc | Источник |
|---|---:|---|
| `bash scripts/gen_ci_steps.sh --write` | 0 | C:119, orchestrator |
| `bash scripts/gen_ci_steps.sh --check` | 0 | C:119, затем после --write |
| `bash scripts/check_provodka.sh . contracts/201-done-dver-soderzhatelnaja-sverka.md` | 0 | C:119, та же стадия |

C:120 (ПОТРЕБИТЕЛЬ) и C:121 (census) не превращены в новые rc-двери.
Исторические `check_charter`/`bash -n` также не добавлены к приёмке C:114–119.
Предыдущая карта critic-v2 судила только C:54/R-0162, не весь 201:
не объявляется новым prior-verdict этой сдачи.

## Двери

- 201 голый после реализации [C:116; A2:92,94] · bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh · 0 · 0
- 201 repo [C:117; A2:94] · bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh --repo . · 0 · 0
- 201 model [C:116; A2:92,94] · bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh --model · 0 · 0
- 201 stabs [C:116; A2:80,92,94] · bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh --stabs · 0 · 0
- 187 repo CELLS54 [C:118] · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo . · 0 · 0
- 187 model CELLS54 [C:118] · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model · 0 · 0
- 187 stabs CELLS54 [C:118] · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --stabs · 0 · 0
- 996 examined111 mismatches≤1 [C:118; m2725 adapter] · fixtures/workshop_project/done_dver_soderzhatelnaja_201/matrix_996_201.py · 0 · 0
- pre_critic исправленный черновик без ambient git identity [C:119] · bash scripts/pre_critic.sh --repo . contracts/201-done-dver-soderzhatelnaja-sverka.md · 0 · 0
- spec [C:119] · bash scripts/check_spec_ready.sh . contracts/201-done-dver-soderzhatelnaja-sverka.md · 0 · 0
- precision [C:119] · bash scripts/check_precision_gate.sh . contracts/201-done-dver-soderzhatelnaja-sverka.md · 0 · 0
- threat [C:119] · bash scripts/check_threat_model.sh . contracts/201-done-dver-soderzhatelnaja-sverka.md · 0 · 0
- ceilings [C:119] · bash scripts/check_ceilings.sh . · 0 · 0

## Карта классов

- К-01 · чисто · вход: C:114–119 и A2:92,94; полный набор и стадия выше; фактический fullgate NOT_RUN · - · -
- К-02 · чисто · вход: C:9,30–65 и прежняя карта К-02 (история ниже); m2725 не меняет предмет · - · -
- К-03 · чисто · вход: C:151 и A2:94; 187 все режимы и исходный 996 сохранены в дверях · - · -
- К-04 · чисто · вход: C:151; дельта только fixture-семьи201, contract/parser/996/187 read-only · - · -
- К-05 · чисто · вход: C:116–119; команды и rc стадий перенесены без ослабления, stdout-порог через один adapter · - · -
- К-06 · н/п · вход: прежняя карта К-06; новых требований rc2 к done-двери нет, runtimefail adapter отвергает · - · -
- К-07 · чисто · fixtures/workshop_project/done_dver_soderzhatelnaja_201/matrix_996_201_proof.py · 0 · 0
- К-08 · чисто · вход: кодовые STABS dver_probe.py и стабы matrix_996_201_proof.py; различающие результаты proof в докладе · - · -
- К-09 · чисто · вход: CASES dver_probe.py и протокол probe.py:1567–1590; границы 0/1/>1 и ошибки различимы · - · -
- К-10 · чисто · вход: A2:94 и dver_probe.py:983–1018; rc+тег сохранены; adapter наблюдает raw child rc и полные потоки · - · -
- К-11 · чисто · вход: прежняя карта К-11 и dver_probe.py:975–983; adapter снимает CASES/MUTANTS до child · - · -
- К-12 · чисто · вход: A2:44–49; jq/git-каноны неизменны, adapter разбирает только собственный протокол996 · - · -
- К-13 · чисто · вход: прежняя карта К-13; секретов дельта не вводит, исходные child-потоки не маскируются · - · -
- К-14 · чисто · вход: matrix_996_201_proof.py; ноль/один mismatch, базовая/mutation клетка и другой текст assertion · - · -
- К-15 · чисто · вход: A2:92; история чисел сохранена, текущие числа только из фактических выводов main, matrix examined111 неизменен · - · -
- К-16 · чисто · вход: C:1,80–102 и A2:98–104; риск и остаточная граница не меняются · - · -
- К-17 · чисто · вход: прежняя карта К-17; механизм харнесса, модель архитектуры дельтой не меняется · - · -

## История — сохранённые свидетельства прежних кругов

Следующий текст — прежний лист SOURCE, не новые прогоны/вердикты.
У шести исторических списков только маркер `-` заменён на `*`, чтобы
старые command/rc не стали машинными рядами вне секции; значения сохранены.

# Исторический сдаточный лист 201 — Круг: красные клетки Adv201c (Arch201Cells)

Текущий круг — один коммит поверх `154c73bbd8`, только `dver_probe.py` и
этот лист; новых файлов нет (привязки стабов — в словаре STABS). Замороженный
текст 201, дверь и реестр места не менялись; судимый кандидат —
`b4d46ec66bb7ed7df58d28489cac922f8d66137f` (единый: реализация `1f0f8bee9d`
+ батарея `154c73bbd8` + строка реестра). Sha единственного коммита круга —
в докладе оркестратору (коммит не может содержать собственный sha). Разделы
ниже — ИСТОРИЯ (57/24, 49/19, 45/15); фактические числа этого круга —
62 клетки / 27 стабов из выводов ниже.

## Круг Adv201c — NUL-байты ответа до jq (оба маршрута) и числовой status

Основание: вердикт третьего adversary — коммит `dcb26084b4`, ref
`archive/201/adv201c-verdict-dcb26084b4`, блоки 1–2; инженерное решение
консультанта `Cons201c` §2. Ответы сервера задаются исходными БАЙТАМИ вне
toy-мира (`write_bytes`), curl rc 0; канонический jq батареи не менялся;
ожидания — в памяти раннера (rc + подстрока причины + отсутствие тега).

### Новые клетки

| Клетка | Вход (байты) | Ожидание | Ветвь двери по коду |
|---|---|---|---|
| `b-vneshnij-nul-hvost` | compare `b'{"status":"behind"}\n\x00\x00'` | rc 1, «влитость … не проверена: ответ API не разобран (синтаксическая ошибка JSON», тега нет | compare-транспорт `:539` `$(curl …)`: bash теряет NUL ДО jq → ложный done |
| `b-vneshnij-nul-v-znachenii` | compare `b'{"status": "beh\x00ind"}'` | rc 1, та же причина | тот же механизм: значение мутирует в `behind` |
| `b-vneshnij-nul-v-klyuche` | compare `b'{"sta\x00tus":"behind"}'` | rc 1, та же причина | тот же механизм: ключ мутирует в `status` |
| `b-vneshnij-status-chislo` | compare `b'{"status":5}'` — валидный ОДИН объект, поле ПРИСУТСТВУЕТ | rc 1, «…не проверена: неподдерживаемое значение status», тега нет | catch-all `:559-565`: присутствующее поле объявляется отсутствующим |
| `g-arch-nul-hvost` | check-runs: успешный `arch` (completed/success) на точном HEAD + `b'\n\x00\x00'` | rc 1, «ARCH_CI: ответ check-runs не разобран (синтаксическая ошибка JSON», тега нет | check-runs-транспорт `:295` |

Различающая пара: тот же behind без NUL-хвоста — положительный контроль
`b-vneshnij-produkt-vlit` (зелёный, не дублирован, ссылка по клетке); для
check-runs — `g-arch-tochno-imja`. Честное ОТСУТСТВИЕ поля status с числовым
входом не смешано: модель вычисляет `status_present` по ключу разобранного
объекта, прежняя ветка «нет поля»/«API недоступен» не тронута
(`b-vneshnij-api-nedostupen` зелёный без изменений).

### Модель и стабы (Н-39: привязка кодом STABS, не прозой)

Модель: после полного разбора `status_present = isinstance(cmp_obj, dict)
and 'status' in cmp_obj`; вне-словарное значение ПРИСУТСТВУЮЩЕГО поля даёт
правдивую причину «неподдерживаемое значение status» (блок 2: называет
фактическое состояние, не «без поля»). Обманные стабы — двойники ветвей
живой двери:

| Стаб | Мутант оракула | Клетка |
|---|---|---|
| `s-b-nul-transport-terjaet-bajty` | `body.replace('\x00','')` до `json_one_object` — двойник `$(curl …)` compare-маршрута (`:539`+`:51`) | `b-vneshnij-nul-hvost` |
| `s-g-nul-transport-terjaet-bajty` | то же для тела check-runs — двойник `:295` | `g-arch-nul-hvost` |
| `s-b-status-vne-slovarya-kak-otsutstvie` | присутствующее вне-словарное поле → «ответ API без поля status» (двойник `:559-565`) | `b-vneshnij-status-chislo` |

### Прогоны: сырые итоги (клон `b4d46ec66b` + батарея круга)

Судимое дерево — одноразовый SSH-клон `/tmp/dev-harness-verify/Arch201Cells/repo`
(origin `ssh://git@github.com/a3ka/dev-harness.git`, собственная `.git`),
ветка `proverka` на `b4d46ec66b`; поверх — `dver_probe.py` из WORKTREE
(`cmp` побайтово — 0; `red_done_dver_201.sh` не менялся). Ambient
`GIT_AUTHOR_*`/`GIT_COMMITTER_*` в среде прогонов отсутствуют (env-замер).

| Дверь | Команда | rc | Итог |
|---|---|---:|---|
| `b4d46ec66b` | 201 `--repo .` | 1 | `CELLS=62 STABS=0 FAILURES=5` + `GREEN karta-jq-vyzovov: механизм _json_one_object × 5` |
| `b4d46ec66b` | 201 `--model` | 0 | `CELLS=62 STABS=0 FAILURES=0` |
| `b4d46ec66b` | 201 `--stabs` | 0 | `CELLS=62 STABS=27 FAILURES=0` |

Красные строки — ровно пять новых клеток; прежние 57 зелёные:

```text
RED b-vneshnij-nul-hvost: rc=0 expected=1 … output='…done_contract.sh: line 539: warning: command substitution: ignored null byte in input\n'
RED b-vneshnij-nul-v-znachenii: rc=0 expected=1 … (та же warning line 539)
RED b-vneshnij-nul-v-klyuche: rc=0 expected=1 … (та же warning line 539)
RED b-vneshnij-status-chislo: rc=1 expected=1 … output='done: влитость в main продукта a3ka/toy-mob не проверена: ответ API без поля status\n'
RED g-arch-nul-hvost: rc=0 expected=1 … output='…done_contract.sh: line 295: warning: command substitution: ignored null byte in input\n'
GREEN karta-jq-vyzovov: механизм _json_one_object × 5, jq вне механизма не читает недоверенные байты
CELLS=62 STABS=0 FAILURES=5
```

Новые caught-строки `--stabs` (все 27 стабов caught, прежние 24 без изменений):

```text
STAB s-b-nul-transport-terjaet-bajty caught @ b-vneshnij-nul-hvost
STAB s-b-status-vne-slovarya-kak-otsutstvie caught @ b-vneshnij-status-chislo
STAB s-g-nul-transport-terjaet-bajty caught @ g-arch-nul-hvost
CELLS=62 STABS=27 FAILURES=0
```

### Развилки этого круга

* Клетки 1б/1в (NUL внутри значения/ключа) уложились в тот же механизм
  (канонический jq rc 5 на всех трёх; `$(curl)` делает их валидными) —
  добавлены; их дефектная ветвь одна с клеткой 1, стаб по ней один.
* Карта jq-вызовов на кандидате GREEN и bash-транспорт байтов НЕ судит
  (наблюдение-совет Adv201c): транспорт ловится новыми клетками, не картой.
* Фраза «неподдерживаемое значение status» — норма модели этого круга:
  ремонт двери обязан воспроизвести её подстрочно в причине отказа;
  иная правдивая формулировка потребует синхронной правки клетки и модели.


## Круг Arb201V2 — полный разбор ровно одного JSON-документа

Основание: `verdicts/arbitration/201-granica-done-dveri-2.md` (арбитраж 2,
РЕШЕНИЯ 1–3, «Что исправить → Батарея и сдача», «Остаточный риск»);
воспроизведение дефекта — Adv201b `1fe7004d63:verdicts/adversary/
contracts-201-impl-v2.md`: повреждённый хвост compare и два полных документа
давали rc 0 и ложный тег `done/contracts/777/1`. Переиспользованы CASES/STABS/
build/model/live и внешний curl-shim; второй раннер, stabs.tsv и новый
контрактный формат не вводились.

### Новые клетки (каждая — отдельный мир; не сценарий с ранним отказом)

| Клетка | Вход | Ожидание | Привязка по коду двери |
|---|---|---|---|
| `b-vneshnij-json-povrezhdjon-hvost` | compare `{"status":"behind",…}` + `\n{broken`, curl rc 0, настоящий jq | rc 1, «влитость … не проверена: ответ API не разобран (синтаксическая ошибка JSON», тега нет | compare → `_json_one_object` (доремонтный адрес 485) |
| `b-vneshnij-dva-dokumenta` | compare за положительным префиксом + `\n{}` | rc 1, «…не разобран (в ответе несколько JSON-документов», тега нет | тот же механизм; отказ именно по неединственности ответа |
| `b-vneshnij-identical` | compare `identical`, внешний whitespace/переводы строк | rc 0 + тег | парный положительный контроль (не ложный отказ) |
| `g-arch-json-povrezhdjon-hvost` | check-runs: успешный `arch` на точном HEAD (completed/success) + `\n{broken`, curl rc 0 | rc 1, «ARCH_CI: ответ check-runs не разобран (синтаксическая ошибка JSON», тега нет | check-runs → `_json_one_object` (доремонтный адрес 254); отрицательный контроль — дверь и раньше отказывала на этих байтах, но по побочной причине |
| `g-arch-dva-dokumenta` | check-runs: успешный `arch` + `\n{}` | rc 1, «…не разобран (в ответе несколько JSON-документов», тега нет | отказ по неединственности, не по побочному предикату |
| `g-profil-povrezhdyon-fajl` | harness.project.json мира + `\n{broken` | rc 1, «ОТКАЗ: профиль битый или workflowPaths вне репо», тега нет | профильный маршрут (229/389): работа не продолжается, fallback нет |
| `g-profil-dva-dokumenta` | harness.project.json мира + `\n{}` | rc 1, та же причина | многодокументный профиль не продолжает работу |
| `g-profil-bez-canonical-remote` | профиль без ключа `git` (штатное отсутствие НЕобязательного поля) | rc 0 + тег | прежний допустимый fallback canonicalRemote → GITHUB_REPOSITORY |

Положительные контроли с внешним whitespace: тела `b-vneshnij-produkt-vlit`
(behind), `b-vneshnij-identical` и трёх arch-положительных (`arch`,
`arch (…)`, `arch fitness`) несут whitespace/перевод строки вокруг
ЕДИНСТВЕННОГО документа — полный slurp их допускает. Прежние клетки
(curl rc≠0 обоих маршрутов, ahead, not-found, `arche`/`archive`/`march`/
`architecture`, frozen/HEAD-класс риска) не менялись и зелёные — регресса нет.

### Модель: факты — каноническим инструментом

Честный путь модели больше не доверяет `compare_status`: введён
`json_one_object` — тот же канонический jq -s и та же грамматика, что у
двери (`length == 1`, тип-объект ДО извлечения поля, rc ДО использования,
диагностика вторым вызовом jq); никакой особой обработки строки `{broken`.
Повреждённое тело не может остаться «успешным behind» в `--model`:
отказ «ответ API не разобран (<причина>)» выводится из самого факта
неразбора. Ожидания — по-прежнему в памяти раннера, тела ответов — вне мира.
Обманные стабы используют `json_stream` (прежняя потоковая форма jq без
slurp) — это их дефект по построению, честный путь её не касается.

### Проверяемая карта jq-вызовов (live-режимы: голый и --repo)

`jq_callsite_map` в каждом live-прогоне батареи: (1) механизм
`_json_one_object` вызван ровно 5 раз (`_pr_paths_obj`/`_a187_profile`/
`_a187_obj`/`_merged_profile_obj`/`_cmp_obj`); (2) ни один jq-вызов вне
механизма не читает недоверенные байты (комментарии не считаются).
На ремонте — `GREEN karta-jq-vyzovov`; на доремонтной `fd72a87643` — RED
ровно по адресам 51/52/53/254/389/485 + «механизм вызван 0 раз».
Входы 51–53/229/389 через файлы миров НЕтриггеримы: `project_paths_resolve`
строит свой выход printf'ом (всегда один документ), а `profile_resolver`
байт-валидирует оба слоя (`jq -e .`) и умирает на повреждённом профиле
(«файл не JSON»), многодокументный — на двухстрочном `.projectLayer.
profilePath` («нет файла слоя проекта»); замер — `/tmp/dev-harness-verify/
Arch201Fix3/scratch/probe_resolvers.py`. Поэтому применено разрешение
арбитра («общая проверка механизма плюс карта всех вызовов и положительные
профильные контроли»): механизм доказан живыми клетками двух маршрутов,
карта проверяема прогоном, профильные контроли живые (повреждённый/
многодокументный профиль → именованный отказ; отсутствие необязательного
поля → прежний fallback).

### Новые стабы (Н-39: привязка кодом STABS, не прозой контракта)

| Стаб | Мутант оракула | Клетка |
|---|---|---|
| `s-b-json-hvost-ignoriruetsja` | A: успешный префикс, rc/хвост игнорируются | `b-vneshnij-json-povrezhdjon-hvost` |
| `s-b-potok-dokumentov-dopushhen` | B: без `length == 1`/slurp — первый документ потока | `b-vneshnij-dva-dokumenta` |
| `s-g-json-hvost-ignoriruetsja` | A: счёт по успешному префиксу, rc jq игнорируется | `g-arch-json-povrezhdjon-hvost` |
| `s-g-potok-dokumentov-dopushhen` | B: счёт по КАЖДОМУ документу потока | `g-arch-dva-dokumenta` |
| `s-g-profil-potok-dopushhen` | B: многодокументный профиль читается по первому документу | `g-profil-dva-dokumenta` |

Все 24 стаба caught (`--stabs` rc 0); стабы A и B — ровне возвраты прежних
додверных ошибок из `fd72a87643`.

### Среда и источники прогонов

Каждый tool-bash — cwd WORKTREE `/tmp/dev-harness-worktrees/c907157c/
wip-201-architect`; все гейты без ambient `GIT_AUTHOR_*`/`GIT_COMMITTER_*`
(`env -u …`). Судимое дерево — одноразовый SSH-клон
`/tmp/dev-harness-verify/Arch201Fix3/repo` (origin
`ssh://git@github.com/a3ka/dev-harness.git`, `origin/main=90c4aa63c3…`),
поверх: `scripts/done_contract.sh` из `1f0f8bee9d`,
`registry/mesto-legacy.tsv` из `fd72a87643`,
`fixtures/workshop_project/rezhim_996/probe.py` из `9e0e817eae`, батарея из
WORKTREE; каждый оверлей сверен `cmp` побайтово (вывод `cmp ok` × 3).
Доремонтный прогон — копия `scripts/` с дверью `fd72a87643` (`--repo
/tmp/dev-harness-verify/Arch201Fix3/prerepo`, побайтово сверена).

### Прогоны: сырые итоги

| Дверь | Команда | rc | Итог |
|---|---|---:|---|
| `1f0f8bee9d` | 201, голый | 0 | `CELLS=57 STABS=0 FAILURES=0` + `GREEN karta-jq-vyzovov: механизм _json_one_object × 5` |
| `1f0f8bee9d` | 201 `--repo .` | 0 | `CELLS=57 STABS=0 FAILURES=0` + GREEN карта |
| `1f0f8bee9d` | 201 `--model` | 0 | `CELLS=57 STABS=0 FAILURES=0` |
| `1f0f8bee9d` | 201 `--stabs` | 0 | `CELLS=57 STABS=24 FAILURES=0` |
| `fd72a87643` (до ремонта) | 201 `--repo prerepo` | 1 | `CELLS=57 STABS=0 FAILURES=5` |
| `1f0f8bee9d` | 187 `--repo .` / `--model` | 0 | `CELLS=54 STABS=0 FAILURES=0` (оба) |
| `1f0f8bee9d` | 187 `--stabs` | 0 | `CELLS=54 STABS=56 FAILURES=0` |
| `1f0f8bee9d` | `rezhim_996/probe.sh` | 0 | `996: examined=111 mutants=0 mismatches=0` |
| `1f0f8bee9d` | `bash -n scripts/done_contract.sh` | 0 | stdout пуст |
| `1f0f8bee9d` | `bash scripts/gen_ci_steps.sh --check` | 0 | stdout пуст |
| `1f0f8bee9d` | `bash scripts/check_charter.sh .` | 0 | `уставных документов: 180 · изменений в них: 525 · с разрешения: 525` |

Красные доремонтные строки (ровно блок Adv201b; check-run — «как показал
код»: отказ был, но по побочной причине):

```text
RED b-vneshnij-json-povrezhdjon-hvost: rc=0 expected=1 … output=''
RED b-vneshnij-dva-dokumenta: rc=0 expected=1 … output=''
RED g-arch-json-povrezhdjon-hvost: rc=1 expected=1 … output='ARCH_CI: успешного check-run arch на финальном SHA … нет (curl rc=0)\n'
RED g-arch-dva-dokumenta: rc=1 expected=1 … output='ARCH_CI: успешного check-run arch на финальном SHA … нет (curl rc=0)\n'
RED karta-jq-vyzovov: строки 51, 52, 53, 254, 389, 485 + механизм вызван 0 раз
```

### Адресные мутации живой двери (одна операция; якорь ровно 1×; проверка применённости; честный контроль)

Мутант — отдельная копия `scripts/` с единственной заменой в
`done_contract.sh`; якорь каждого встречается в двери ровно один раз
(проверено счётом до замены и после). Полная батарея `--repo <мутант>`
обязана быть красной.

| Мутант | Одна операция | Адресное наблюдение honest → mutant | Полная батарея |
|---|---|---|---|
| M1 compare-prefix | блок `_cmp_obj`/`_cmp_status` заменён додверной строкой 485 (`jq -r '…status // empty…' … \|\| true`) | honest rc 1/тега нет/«не разобран (синтаксическая ошибка JSON (jq rc=5))» → mutant rc 0 + `done/contracts/777/1` на ОБОИХ клетках (хвост и два документа) | rc 1, `FAILURES=3`: обе compare-клетки + карта (строка 556 вне механизма, механизм × 4) |
| M2 potok-dokumentov | из фильтра механизма удалено `length == 1 and` (slurp сохранён) | на двух документах: compare rc 0 + тег И check-run rc 0 + тег (ложный done); на повреждённом хвосте — по-прежнему rc 1 «не разобран (синтаксическая ошибка JSON (jq rc=5))» | rc 1, `FAILURES=2`: ровно `b-vneshnij-dva-dokumenta` и `g-arch-dva-dokumenta` |
| M3 rc-otkat | удалён только `\|\| __rc=$?` (явная rc-проверка) | на хвосте и двух документах rc 1 и тега НЕТ — мутант остаётся fail-closed благодаря полному slurp (stdout при ошибке пуст), причина деградирует до «ответ API без поля status»/«нет (curl rc=0)» | rc 1, `FAILURES=4`: все четыре клетки красны ТОЛЬКО по правдивости причины (rc сходится) |
| M4 checkrun-prefix | блок `_a187_obj`/`_a187_n` заменён додверной строкой 254 (`… \|\| printf '0'`, конкат аварийного нуля) | rc 1 на обеих клетках, тега нет — прежняя форма случайно fail-closed («1\n0» нецифровое → 0 → ARCH_CI), причина побочная «нет (curl rc=0)» | rc 1, `FAILURES=3`: обе check-run клетки (по фразе) + карта (строка 308, механизм × 4) |

НАБЛЮДЕНИЯ (требование арбитража о различающем входе):

* M2 ловится входом «два документа», а НЕ тем же повреждённым хвостом: без
  `length == 1` slurp продолжает ловить синтаксические ошибки — различающий
  вход показан прогоном (`m2-compare-hvost-nabljudenie` rc 1).
* M3 — случай «откат только явной rc-проверки может оставаться безопасным
  благодаря полному slurp»: ложного done НЕТ ни на одном входе; батарея
  красит его исключительно правдивостью причины. Ложно назвать его пойманным
  по хвосту нельзя — это записано здесь как есть.
* M4: доремонтная строка check-run не давала ложного done (конкат с «0»
  ломал цифровую форму), но отказ был по побочному предикату; ремонт делает
  причину правдивой — на этом клетки и ловят возврат.

### НЕ ЗАЩИЩАЕТ (дословно из арбитража 2, «Остаточный риск»)

> успешный полный разбор одного ответа API и положительный compare/check-run
> не доказывают семантическую полноту реализации последней заморозки и
> правдивость содержательного accept; ловцы — reviewer и adversary рискового
> предмета на том же OBJECT, предметные проверки CI. Ошибка транспорта/разбора
> или неединственный JSON-ответ в этот остаток не входят и должны закрывать done.

### Развилки этого круга

* 51–53/229/389: живые клетки на каждый вызов невозможны файлами миров
  (входы контролируются резолверами origin/main, которые сами fail-closed —
  замер выше); выбрано разрешение арбитра «механизм + карта + положительные
  профильные контроли», а не выдуманный вход.
* Карта вызовов судится только в live-режимах: `--model`/`--stabs` дверь не
  вызывают, CI-шаг батареи (`--stabs`) от версии двери не зависит.
* Профильные отказные клетки зелёны и на доремонтной двери (резолвер не
  менялся ремонтом): их вклад — отсутствие fallback и положительный
  контроль необязательного поля, различение до/после — не их задача.
* Sha единственного коммита круга физически не помещается в SDACHA этого же
  коммита; кандидат зафиксирован родителем `9e0e817eae` и докладом.

### Остатки

* Живые GitHub API и настоящий тег 201 не вызывались: транспорт и ответы —
  штатный внешний шим; выпуск настоящего done-тега 201 не выполнялся.
* Числа прежних кругов (45/15, 49/19) — исторические; текущие: 57/24.
* `compare_status` в facts остаётся только для обманных стабов и книги;
  честный путь модели его не использует.

---

## История: Круг FAIL Adv201 (Arch201Fix2)

## Круг: FAIL Adv201 — предмет и существующее

Основание: `48395539cd:verdicts/adversary/contracts-201-impl-v1.md`, блоки 1–3;
актуализация задания `task-201-architect-fix2.md` о ремонте `fd72a87643`.
Переиспользованы `CASES`, `STABS`, `build`, `model`, `live` и существующий внешний
curl-shim; новая дверь, формат входа или второй раннер не вводятся. Публичный seam —
`scripts/done_contract.sh`; наблюдение каждой live-клетки — rc, именованный отказ и
наличие/отсутствие Git-тега. Модель снимает frozen-текст и ожидания до вызова двери.

* Блок 1: `b-vneshnij-curl-s-oshibkoj` отличается от честного внешнего behind-мира
  только ненулевым rc curl после валидного stdout. Отказ обязан содержать
  `влитость в main продукта a3ka/toy-mob не проверена: curl rc=1`, тега нет.
* Блок 2: `v-riskovyi-head-obychnyj` — frozen рисковый, после freeze контракт на HEAD
  закоммичен обычным, тег не двигается, адверсария нет. Ожидается отказ
  `accept адверсария не найден`. Прежний положительный контроль
  `v-obychnyj-bez-adversarii` усилен обратной записью: frozen обычный, HEAD рисковый;
  отсутствие адверсария не мешает done.
* Блок 3: `g-arche` — completed/success check-run на точном HEAD, но имя `arche`;
  ожидается ARCH_CI без тега. Контроли `arch`, `arch (…)`, `arch fitness` сохранены.
* Актуализация блока 1: отдельная `g-arch-curl-s-oshibkoj` — валидный успешный `arch`
  в stdout и rc curl 1; ожидается ARCH_CI без тега. Это самостоятельная клетка,
  не объединённый case, который засчитывается по первому отказу.

Конформность новых входов: штатные Git-коммиты после freeze без передвижения тега,
документированные поля GitHub compare/check-runs и exit-status внешнего процесса.
Шим и JSON остаются вне судимого мира; `DONE201_COMPARE_RC`/`DONE201_CHECKRUNS_RC`
передаются из памяти раннера, не читаются с диска мира. Дефект каждого стаба
наблюдаем на его кодовой привязке `STABS`; перечисления привязок в контракт не добавлены.
Итоги раннера вычисляются существующими `len(CASES)`/`len(STABS)`: 49/19,
без дублирующих чисел в shell-wrapper.

### Среда и источники прогонов

Каждый tool-bash запущен с cwd
`/tmp/dev-harness-worktrees/c907157c/wip-201-architect`.
Вложенные команды канона выполнялись в отдельном SSH-клоне
`/tmp/dev-harness-verify/Arch201Fix2/repo` со своей `.git`:
origin `ssh://git@github.com/a3ka/dev-harness.git`,
исходный `HEAD=origin/main=34566df929d888543c45b1da00f72c1ea501161b`.
Все прогоны — без ambient `GIT_AUTHOR_*`/`GIT_COMMITTER_*`
(`env -u GIT_AUTHOR_NAME -u GIT_AUTHOR_EMAIL -u GIT_AUTHOR_DATE
-u GIT_COMMITTER_NAME -u GIT_COMMITTER_EMAIL -u GIT_COMMITTER_DATE`;
одноразовый драйвер также удалял все переменные этих двух префиксов).

Скрипт двери и реестр места экспортированы `git archive | tar` из read-only
основного репозитория: сначала `3ed2c21a7a`, затем
`fd72a87643e467d1d83b17059248008bf005ca55`.
Для ОБОИХ файлов ОБОИХ кандидатов `git show <sha>:<path> | cmp - <clone/path>`
вернул 0. Батарея и прежняя правка 996 экспортированы из staged-tree
`aa733acfbb1a12773210ca6d8dec3ec963b7ca12`; `cmp` dver_probe.py с worktree — 0.
Сырой вывод подготовки:

```text
before sources and fixture cmp=0
after sources cmp=0
```

### Прогоны до и после ремонта реализации

Команды в таблице — `bash <путь>` из корня verification-клона; путь 201 —
`fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh`,
путь 187 — `fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh`.
В таблице приведены буквальные итоговые строки, не пересчитанные результаты.

| Дверь | Команда | rc | Сырой итог |
|---|---|---:|---|
| 3ed2c21a7a | 201, голый | 1 | `CELLS=49 STABS=0 FAILURES=2` |
| 3ed2c21a7a | 201 `--repo .` | 1 | `CELLS=49 STABS=0 FAILURES=2` |
| fd72a87643 | 201, голый | 0 | `CELLS=49 STABS=0 FAILURES=0` |
| fd72a87643 | 201 `--repo .` | 0 | `CELLS=49 STABS=0 FAILURES=0` |
| fd72a87643 | 201 `--model` | 0 | `CELLS=49 STABS=0 FAILURES=0` |
| fd72a87643 | 201 `--stabs` | 0 | `CELLS=49 STABS=19 FAILURES=0` |
| fd72a87643 | 187 `--repo .` | 0 | `CELLS=54 STABS=0 FAILURES=0` |
| fd72a87643 | 187 `--model` | 0 | `CELLS=54 STABS=0 FAILURES=0` |
| fd72a87643 | 187 `--stabs` | 0 | `CELLS=54 STABS=56 FAILURES=0` |
| fd72a87643 | `bash fixtures/workshop_project/rezhim_996/probe.sh` | 0 | `996: examined=111 mutants=0 mismatches=0` |
| fd72a87643 | `bash scripts/gen_ci_steps.sh --check` | 0 | stdout пуст |
| fd72a87643 | `bash scripts/check_charter.sh .` | 0 | `уставных документов: 180 · изменений в них: 521 · с разрешения: 521` |

До ремонта красны РОВНО две транспортные клетки; остальные 47 зелёные.
Сырые строки голого прогона и `--repo .` совпали:

```text
RED b-vneshnij-curl-s-oshibkoj: rc=0 expected=1 reason=влитость в main продукта a3ka/toy-mob не проверена: curl rc=1 output=''
RED g-arch-curl-s-oshibkoj: rc=0 expected=1 reason=ARCH_CI output=''
CELLS=49 STABS=0 FAILURES=2
rc=1
```

После ремонта, голый и `--repo .` (выдержка новых клеток и обратного контроля):

```text
GREEN b-vneshnij-curl-s-oshibkoj: rc=1 expected=1 reason=влитость в main продукта a3ka/toy-mob не проверена: curl rc=1
GREEN v-riskovyi-head-obychnyj: rc=1 expected=1 reason=accept адверсария не найден
GREEN v-obychnyj-bez-adversarii: rc=0 expected=0
GREEN g-arch-curl-s-oshibkoj: rc=1 expected=1 reason=ARCH_CI
GREEN g-arche: rc=1 expected=1 reason=ARCH_CI
CELLS=49 STABS=0 FAILURES=0
rc=0
```

Новые строки `--stabs` (все прежние стабы также caught):

```text
STAB s-b-curl-rc-tolko-default caught @ b-vneshnij-curl-s-oshibkoj
STAB s-v-risk-iz-head caught @ v-riskovyi-head-obychnyj
STAB s-g-curl-rc-ignoriruetsja caught @ g-arch-curl-s-oshibkoj
STAB s-g-arche-razresheno caught @ g-arche
CELLS=49 STABS=19 FAILURES=0
rc=0
```

### Мутационные доказательства на ЖИВОЙ двери

Каждый мутант — отдельная временная копия настоящего `scripts/`, а не мутант модели.
Единственная предметная замена указана ниже; на каждом запущена полная 201-батарея
`bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh --repo <копия>`.
Перед этим независимые миры предъявлены честной и мутантной двери с печатью rc/тега.

| Блок | Мутация реализации | Сырой итог полной батареи | rc |
|---|---|---|---:|
| 1 | `curl-default-only`: вернуть проверку `_cmp_crc` только в default-ветвь case, как в 3ed2c21a7a | `CELLS=49 STABS=0 FAILURES=1` | 1 |
| 2 | `risk-from-HEAD`: `git cat-file -p "$frozen_tag:$TARGET_REL"` → `git cat-file -p "HEAD:$TARGET_REL"` | `CELLS=49 STABS=0 FAILURES=2` | 1 |
| 3 | `accept-arche`: `startswith("arch ")` → `(startswith("arch ") or . == "arche")` | `CELLS=49 STABS=0 FAILURES=1` | 1 |
| 1, check-run | `checkrun-curl-ignored`: убрать `_a187_crc == 0` из условия разбора stdout | `CELLS=49 STABS=0 FAILURES=1` | 1 |

Две красные клетки мутанта риска — новый запрет и обратный положительный контроль,
а не две причины одного объединённого case. Сырой адресный вывод:

```text
curl-default-only-honest: cell=b-vneshnij-curl-s-oshibkoj rc=1 tag='' output='done: влитость в main продукта a3ka/toy-mob не проверена: curl rc=1\n'
curl-default-only-mutant: cell=b-vneshnij-curl-s-oshibkoj rc=0 tag='done/contracts/777/1' output=''
risk-from-HEAD-honest: cell=v-riskovyi-head-obychnyj rc=1 tag='' output='done: предмет рисковый, accept адверсария не найден: verdicts/adversary/contracts-777-*.md\n'
risk-from-HEAD-mutant: cell=v-riskovyi-head-obychnyj rc=0 tag='done/contracts/777/1' output=''
accept-arche-honest: cell=g-arche rc=1 tag='' output='ARCH_CI: успешного check-run arch на финальном SHA d282b1b841ea4d3915e13e4e42918482c564dc32 нет (curl rc=0)\n'
accept-arche-mutant: cell=g-arche rc=0 tag='done/contracts/777/1' output=''
checkrun-curl-ignored-honest: cell=g-arch-curl-s-oshibkoj rc=1 tag='' output='ARCH_CI: успешного check-run arch на финальном SHA 18e2629d96ec9831d17a2e031f8bb5d550ba2e3a нет (curl rc=1)\n'
checkrun-curl-ignored-mutant: cell=g-arch-curl-s-oshibkoj rc=0 tag='done/contracts/777/1' output=''
risk-reverse-positive: cell=v-obychnyj-bez-adversarii rc=0 tag='done/contracts/777/1' output=''
risk-reverse-positive: frozen=обычный HEAD=рисковый adversary=absent
compare-positive: cell=b-vneshnij-produkt-vlit rc=0 tag='done/contracts/777/1' output=''
g-arch-tochno-imja-positive: cell=g-arch-tochno-imja rc=0 tag='done/contracts/777/1' output=''
g-arch-v-skobkah-positive: cell=g-arch-v-skobkah rc=0 tag='done/contracts/777/1' output=''
g-arch-s-probelom-positive: cell=g-arch-s-probelom rc=0 tag='done/contracts/777/1' output=''
verification-phase=mutations rc=0
```

Полная мутантная батарея красила ровно названную клетку каждого запрета; для риска
также `v-obychnyj-bez-adversarii` (ложный отказ с HEAD-классом). Все прочие клетки,
включая положительные arch-контроли, оставались зелёными.

### Развилки

* Актуализация разрешает ещё одну клетку check-run/curl, но сохраняет ожидаемые
  48/18 от трёх основных находок. Она реализована отдельным миром и отдельным стабом:
  фактический census — 49/19, до ремонта FAILURES=2, не 1. Новых файлов нет.
* Замороженный текст 201 не менялся: его исторические 45 клеток / 15 стабов
  устарели, как и старый pre-implementation замер FAILURES=30. Итоги этого круга —
  таблицы выше, не молчаливая правка frozen-приёмки.
* Клон взят с живого SSH-origin (34566df9), не с локального checkout; требуемые
  blobs кандидатов перенесены разрешённым в актуализации `git archive | tar`
  и побайтово сверены `cmp`. Основной checkout и чужие verify-клоны не изменялись.
* Одноразовый драйвер после успешного 996 `rc=0` ошибочно ожидал итог без префикса
  `996:` и завершился с AssertionError. Это ошибка драйвера, не дефект батареи:
  сырой результат 111/0/0 выше. Завершённые проверки не повторялись; оставшиеся
  gen_ci_steps/check_charter выполнены отдельно (`verification-phase=remaining rc=0`).

### Остатки и рефлексия процесса

* Реальные GitHub API и удалённый CI не вызывались: транспортные отказы и ответы
  API заданы штатным внешним шимом. Локальный CI-generator проверен; выпуск
  настоящего done-тега 201 не выполнялся.
* 996 проверена только `probe.sh` с уже сданным `b135b249d4`; `--matrix` в этом
  круге не запускалась. Исторические сообщения о её mismatch ниже не являются
  результатом нынешнего круга.
* Процессная помеха: актуализация оставила фиксированные счётчики от обязательной
  тройки рядом с разрешённой дополнительной клеткой. Разрешено явным подсчётом
  раннера и разделением миров, без ослабления инвариантов.
  Общий `NABLIUDENIA_ARCHITECT.md` не изменён: он вне выданной зоны, запись в
  wip-журнал запрещена. Рефлексия передаётся оркестратору этим листом без
  самовольного общего номера.

## Круг fix3 — блок К-10 Crit201V3 (классификация места читала рабочую копию реестра)

* **Блок**: `dver_probe.py` `mesto_lookup` читала `registry/mesto-legacy.tsv` через
  `path.read_text()` (РАБОЧАЯ копия): в мире `b-legacy-chuzhoj-blob` (HEAD несёт запись
  чужого blob) незакоммиченная строка настоящего blob со значением `станция` давала модели
  `(0, '')` вместо rc 1 PH_B8 — при зелёной `--model` 41/41. Закрывающее свойство (вердикт):
  модель и адресная батарея различают HEAD и рабочие/staged изменения; отсутствие записи в
  HEAD не превращается в «станцию»; честная закоммиченная запись остаётся зелёной.
* **Закрытие** (способ: канон/инструмент — git-факты через plumbing): `mesto_lookup` читает
  реестр `git show HEAD:registry/mesto-legacy.tsv` (нет файла на HEAD — нет записи → PH_B8
  fail-closed); той же мерой исправлен lookup `risk-legacy.tsv` в `model()` — единственный
  другой чтение-рабочего-файла-как-свидетельства по аудиту задания п.1 (grep `read_text`/
  `open(`/`cat` по `dver_probe.py`: два места, оба закрыты; прочие `read_text` —
  build-сторона миров). Текст контракта :55/:61 уточнён: «источник — закоммиченный на HEAD
  файл реестра; рабочая копия и индекс — не свидетельство (п.8 AGENTS.md); нет файла на
  HEAD — нет записи»; новый пункт ЗАЩИЩАЕТ (модель угроз 9/9).
* **Клетки** (вход критика и Controls): `b-legacy-rabochaja-zapis` rc1 «место реализации
  предмета 777 не установлено» (вход критика дословно: HEAD — чужой blob, рабочий файл —
  строка настоящего blob `станция`); `b-legacy-staged-zapis` rc1 той же причиной (та же
  строка в индексе `git add`, не закоммичена); контроль `b-legacy-zakomchennaja-zapis` rc0
  (та же строка ЗАКОММИЧЕНА на HEAD — честная зелёная, живой прогон тегирует);
  `v-legacy-rabochaja-zapis` rc1 «accept адверсария не найден» (класс К-10 на реестре
  класса: незакоммиченная строка настоящего blob «обычный» не снимает адверсария).
* **Стабы** (Н-39 — привязка только кодом `STABS`): `s-b-mesto-iz-rabochego-fajla`
  @ `b-legacy-rabochaja-zapis` и `s-v-risk-iz-rabochego-fajla` @
  `v-legacy-rabochaja-zapis` — оба caught (`--stabs` rc 0, сырой вывод ниже).

## Исправление прежних заявлений круга fix1 (РЕШЕНИЕ арбитража 1 «Что исправить до freeze»)

* Прежнее заявление SDACHA fix1 «Блок 1 закрыт инвариантом OBJECT ⊆ F при F==CID» —
  НЕВЕРНО и отозвано: одного предка F достаточно́ не было (мир B→I→F с OBJECT=B проходил
  предикат, модель возвращала `(0, '')` — атака Crit201V2, §Адресные атаки). Именование
  остатка в НЕ ЗАЩИЩАЕТ («любой предок F») обязательство не исполняло. Исправлено
  РЕШЕНИЕМ 1 (ниже).
* Прежнее заявление SDACHA fix1 «Вопроса владельцу не потребовалось: обязательство не
  сужено — НЕобъявленная внешная реализация вынесена в НЕ ЗАЩИЩАЕТ» — НЕВЕРНО и
  отозвано: пропуск необъявленных внешних предметов (включая измеренный 163) был
  сужением данного владельцем обязательства «влитость проверяется»; арбитраж это
  отклонил. Исправлено РЕШЕНИЕМ 2 (ниже).
* Числа круга fix1 (32 клетки / 11 стабов / 21 красная) нормой НЕ являются; этот лист
  несёт числа ФАКТИЧЕСКИХ прогонов новой версии круга fix3: 45 / 15 / 30
  (круг fix2: 41 / 13 / 27; круг fix1: 32 / 11 / 21).

## Ответ на решения арбитража 1 (способ и доказательство)

* **РЕШЕНИЕ 1 — tree-доказательство при F==CID** (способ: канон/инструмент). §Предмет 1:
  при `F ⊊ CID` — `F ⊆ OBJECT` (сохранено); при `F == CID` — одновременно `OBJECT ⊆ F` И
  тождество Git-деревьев за вычетом ТОЛЬКО точных файлов судебных свидетельств
  (выбранный reviewer-файл; для рискового — ещё выбранный accept-файл адверсария).
  Канон — `git -c diff.renames=false diff-tree -r --raw --no-renames` (пути/моды/OID,
  удаления, gitlinks; литеральный вычет точных путей; ошибка Git ≠ доказанное равенство).
  Утверждение «любой предок F достаточен» удалено (вместе со строкой НЕ ЗАЩИЩАЕТ о нём).
  Клетки: положительная `a-ravenstvo-frozen-verdikt` rc0 (дерево F = дерево OBJECT +
  файл вердикта); отрицательные `a-drevo-object-do-realizacii` rc1 (мир B→I→F: OBJECT=B —
  родословная проходит, тождество нет) и `a-drevo-realizacija-v-f` rc1 (сам F добавляет
  реализацию сверх OBJECT). Мутационное доказательство «любой предок F»: стаб
  `s-a-tolko-rodoslovnaja` пойман на `a-drevo-object-do-realizacii` (`--stabs`);
  исходниковая мутация (выключение tree-проверки) роняет `--model` фикстурной проверкой
  на той же клетке: `сломанная фикстура: a-drevo-object-do-realizacii ожидалось 1/'не
  связан с последней заморозкой', модель дала 0/''`, rc 1.
* **РЕШЕНИЕ 2 — явное место реализации либо fail-closed** (способ: граница +
  канон/инструмент). §Предмет 2: три состояния станции — объявленная
  `ПРОДУКТ: станция` (OBJECT обязан быть локальным; внешний → новая причина «обязан быть
  SHA станции»), объявленный `ПРОДУКТ: <owner>/<repo>` (OBJECT внешний, влитость через
  compare API всегда), место НЕ установлено → rc 1 `done: место реализации предмета
  <NNN> не установлено — …` fail-closed, НЕзависимо от локальной разрешимости OBJECT.
  Для замороженных без объявления — реестр `registry/mesto-legacy.tsv` (канон
  risk-legacy: ключ NNN+blob, чтение на HEAD, конфликт/вне грамматики — отказ, другой
  blob не действует, объявление сильнее записи). Реестр и его строки — ЗОНА implementer
  (новая строка ЗОНА + §Миграция с 13 записями по данным); 123 — БЕЗ записи (смешанная
  зона станции и продукта). Клетки: `b-stancionnyj-objavlennyj` rc0 /
  `b-stancionnyj-object-vneshnij` rc1 (объявление станции), `b-vneshnij-bez-stroki` rc1 и
  `b-mesto-neizvestno` rc1 (неизвестное место — внешний и ЛОКАЛЬНЫЙ OBJECT),
  `b-legacy-stancionnyj` rc0 / `b-legacy-vneshnij-vlit` rc0 / `b-legacy-vneshnij-ne-vlit`
  rc1 «не в main продукта» (запись включает проверку продукта) / `b-legacy-chuzhoj-blob`
  rc1 (запись от другого blob не действует). Мутационное доказательство «место по
  умолчанию станция»: стаб `s-b-mesto-po-umolchaniju-stancija` пойман на
  `b-mesto-neizvestno`; исходниковая мутация (неизвестное место → станция) роняет
  `--model` на `b-vneshnij-bez-stroki`: модель дала `1/'done: OBJECT … вне репо
  станции…'` вместо `1/'…место…не установлено'` (фраза не совпала), rc 1.
* **Из НЕ ЗАЩИЩАЕТ удалены два отвергнутых оправдания**: «предреализационный OBJECT при
  F==CID — годится любой предок F» и «НЕобъявленная внешная реализация — дверь не видит,
  ловец оркестратор». Взамен — три готовые строки арбитража (тождество дерева ≠
  семантическая полнота; правдивость объявления/записи; ancestry внешнего SHA ≠
  семантическое соответствие). Вопрос 2 контракта переписан: классификация/fail-closed —
  обязательный маршрут, не добровольный ретро-ремонт; остаток — смешанные/мультипродуктовые
  предметы (123-класс).
* **Сохранено (РЕШЕНИЕ арбитража 1 п.5)**: выбор vmax оракулом из тегов мира и клетка
  `a-dve-zamorozki` (мутация max→min по-прежнему роняет батарею — стаб
  `s-a-staraja-zamorozka` caught); Н-39 — привязки стабов только кодом STABS (grep
  контракта по `s-[abvg]-|@ клетка|→ клетка` — пусто); машинный критерий тегов
  (у красной клетки тега нет, у зелёной — есть, по каждой live-клетке); гейты и клапан
  038 не тронуты; `done_contract.sh` пишет только implementer и только после законного
  freeze (freeze закрыт РЕШЕНИЕМ 3 до санкции владельца на третий вызов).

## Миграция классификации (какие предметы, какое место, источник данных)

13 записей `registry/mesto-legacy.tsv` (создаёт implementer по §Миграции контракта;
колонка `записал` = `architect (арбитраж 1)`):

* станция (5): **129** (blob 6a23c8a8…, frozen/129/2; ЗОНА implementer
  `.omp/extensions/fallback-route.ts` станции; честный контроль raw-замера), **132**
  (598bf58a…, /2; `scripts/ekran_shablon.py` станции), **157** (440310bd…, /1;
  `.omp/extensions/spawn-guard.ts` станции), **186** (42c02f92…, /2; roles/scripts/ops
  станции; честный контроль), **190** (d3a20c8f…, /1; scripts/zamer_svyazki.* станции;
  честный контроль).
* a3ka/Complior-mob (7): **111** (330250aa…, /5; карточка Complior-mob#109, ЗОНА
  mobile/…), **117** (00626ff7…, /5; ЗОНА mobile/…), **139** (d7f36092…, /3; ЗОНА
  `.github/workflows/mobile-e2e-retry.yml` репо Complior-mob), **141** (300c3e8e…, /3;
  v3 переносит тела шагов в `mobile/scripts/ci-*.sh` продукта), **163** (b651af38…, /1;
  «реализация CI — в Complior-mob» — замер арбитража 1 п.4: PRODUCT_LINES=0,
  EXPLICIT_EXTERNAL=True), **991** (5ea6f83c…, /3; «ОДИН PR в a3ka/Complior-mob», ЗОНА
  mobile/…/workflows), **999** (59f44b10…, /2; ЗОНА mobile/src/…).
* a3ka/Complior-back (1): **109** (c430e013…, /6; карточка Complior-back#5, ЗОНА
  server/, compose.dev.yml, ci.yml продукта).
* БЕЗ записи: **123** (bd5e9981…, /3) — ЗОНА implementer смешанная (`scripts/sverka_maketa.py`
  станции + `.github/workflows/mobile.yml` продукта): одиночным значением места не
  представима, произвольный выбор запрещён («нет полного доказательства — нет done»);
  остальные замороженные без объявления и записи — также отказ до классификации их
  предметами.

Источник всех blob — `git rev-parse <последний тег>:<путь контракта>` живого дерева
(2026-11-17); `ПРОДУКТ:`-строк во всех 14 замороженных текстах нет (grep `^ПРОДУКТ:` = 0);
место — по ЗОНАМ implementer и карточкам замороженных текстов. Места не выдуманы: у 123
записи нет.

## Прогоны (числа из вывода, 2026-11-17, круг fix3)

* Голый прогон против текущего дерева:
  `bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh`
  → rc 1, `CELLS=45 STABS=0 FAILURES=30`. Красные 30: (а) `a-accept-staroj-versii`,
  `a-net-zamorozki`, `a-verdikt-bez-object`, `a-object-do-zamorozki`, `a-dve-zamorozki`,
  `a-drevo-object-do-realizacii`, `a-drevo-realizacija-v-f`; (б)
  `b-produkt-object-mimo-main`, `b-produkt-object-otsutstvuet`, `b-vneshnij-ne-vlit`,
  `b-vneshnij-bez-stroki`, `b-vneshnij-stroka-krivaja`, `b-vneshnij-api-nedostupen`,
  `b-vneshnij-object-stancionnyj`, `b-vneshnij-dublikat-stroki`,
  `b-stancionnyj-object-vneshnij`, `b-mesto-neizvestno`, `b-legacy-vneshnij-ne-vlit`,
  `b-legacy-chuzhoj-blob`, `b-legacy-rabochaja-zapis`, `b-legacy-staged-zapis`; (в)
  `v-riskovyi-bez-adversarii`, `v-riskovyi-drugoj-object`,
  `v-riskovyi-svezhij-fail`, `v-adversarii-bez-object`, `v-default-riskovyi-bez-zapisi`,
  `v-legacy-rabochaja-zapis`, `v-klass-neodnoznachen`; (г) `g-arch-v-skobkah`,
  `g-arch-s-probelom`. Из 30: двадцать восемь — живой rc 0 вместо отказа (дверь ещё не
  несёт шаг 6б), две arch — живой rc 1 вместо rc 0 (предикат (г) ещё буквальный).
  Зелёные 15: `a-verdict-posle-zamorozki`, `a-ravenstvo-frozen-verdikt`, `b-produkt-vlito`,
  `b-vneshnij-produkt-vlit`, `b-stancionnyj-objavlennyj`, `b-legacy-stancionnyj`,
  `b-legacy-vneshnij-vlit`, `b-legacy-zakomchennaja-zapis` (контроль честной записи
  круга 3 — живой тег создан), `v-riskovyi-sopostavimyj-object`, `v-obychnyj-bez-adversarii`,
  `v-legacy-obychnyj`, `g-arch-tochno-imja`, `g-archive`, `g-architecture`, `g-march`
  (у зелёных live-клеток тег `done/contracts/777/1` создан, у красных — отсутствует;
  проверено раннером по каждой клетке).
* `--repo .` → rc 1, `CELLS=45 STABS=0 FAILURES=30` (те же числа, tools из cwd).
* `--model` → rc 0, `CELLS=45 STABS=0 FAILURES=0`.
* `--stabs` → rc 0, `CELLS=45 STABS=15 FAILURES=0` (все 15 стабов caught, каждый на
  своей клетке; в том числе круга 3: s-b-mesto-iz-rabochego-fajla @
  b-legacy-rabochaja-zapis, s-v-risk-iz-rabochego-fajla @ v-legacy-rabochaja-zapis —
  привязка только кодом STABS; сырые строки: `STAB s-b-mesto-iz-rabochego-fajla caught
  @ b-legacy-rabochaja-zapis`, `STAB s-v-risk-iz-rabochego-fajla caught @
  v-legacy-rabochaja-zapis`).
* Соседи (сохранность): `architecture_process_187` — `--repo .` rc 0
  (`CELLS=54 STABS=0 FAILURES=0`), `--model` rc 0 (`54/0/0`), `--stabs` rc 0
  (`CELLS=54 STABS=56 FAILURES=0`). `rezhim_996 --matrix` → rc 1, `examined=111
  mutants=76 mismatches=1` — единственный пропуск (mutant skip-committed /
  done-committed-preserved) существует ДО предмета 201 (базлайн; то же значение в
  прогонах критиков 201-v1/v1b/V3).
* Гейты (все с `env -u GIT_AUTHOR_* GIT_COMMITTER_*`): `pre_critic --repo .
  contracts/201-…md` rc 0 («КРИТИК: дверь зелёная», модель угроз красна, потолки красны,
  проводка красна); `check_spec_ready` rc 0 (OK); `check_precision_gate` rc 0 (OK);
  `check_threat_model` rc 0 (валидна: ЗАЩИЩАЕТ 9, НЕ ЗАЩИЩАЕТ 9); `check_ceilings`
  rc 0 (потолки в порядке); `check_charter` rc 0 (177 уставных, 511 изменений, все
  с разрешения).

## Мутационные доказательства (решения 1–2 и блок К-10 круга 3)

* Решение 1, стаб `s-a-tolko-rodoslovnaja` (tree-проверка выключена — мутант «любой
  предок F достаточен»): на `a-drevo-object-do-realizacii` даёт rc 0 → caught.
  Исходниковая мутация `if frozen == f['cid'] and obj_local and not skip(…)` → `if
  False:` роняет `--model` фикстурной проверкой на той же клетке (вывод выше), rc 1.
* Решение 2, стаб `s-b-mesto-po-umolchaniju-stancija` (нет объявления → «станция»,
  реестр/fail-closed пропущены): на `b-mesto-neizvestno` даёт rc 0 → caught.
  Исходниковая мутация `if declared is None and skip(…)` → `if declared is None:` роняет
  `--model` на `b-vneshnij-bez-stroki` (фраза «вне репо станции» вместо «место … не
  установлено»), rc 1.
* Блок К-10 круга 3 (место), стаб `s-b-mesto-iz-rabochego-fajla` (mesto_lookup читает
  РАБОЧУЮ копию — прежний дефектный код): на `b-legacy-rabochaja-zapis` даёт rc 0 →
  caught (сырой вывод `--stabs`: `STAB s-b-mesto-iz-rabochego-fajla caught @
  b-legacy-rabochaja-zapis`). Исходниковая мутация (возврат чтения рабочего файла в
  `mesto_lookup`) роняет `--model` фикстурной проверкой на той же клетке, сырой хвост:
  `RuntimeError: сломанная фикстура: b-legacy-rabochaja-zapis ожидалось 1/'место
  реализации предмета 777 не установлено', модель дала 0/''`, rc 1 — наблюдение критика
  воспроизведено и погашено.
* Блок К-10 круга 3 (класс риска), стаб `s-v-risk-iz-rabochego-fajla` (lookup
  risk-legacy читает РАБОЧУЮ копию): на `v-legacy-rabochaja-zapis` даёт rc 0 → caught
  (сырой вывод: `STAB s-v-risk-iz-rabochego-fajla caught @ v-legacy-rabochaja-zapis`).
  Исходниковая мутация (возврат чтения рабочего файла в lookup класса) роняет `--model`:
  `RuntimeError: сломанная фикстура: v-legacy-rabochaja-zapis ожидалось 1/'accept
  адверсария не найден', модель дала 0/''`, rc 1.
* Честные эквивалентные записи зелёны: `--model` rc 0 на всех 45 клетках без мутантов;
  каждая зелёная клетка — контрпример к ложному отказу своего пункта; контроль круга 3 —
  `b-legacy-zakomchennaja-zapis` (та же запись, но закоммиченная) rc 0.

## Карта классов К-01…К-17 (roles/critic.md §Связка с автором)

* К-01: чисто — pre_critic/precision/spec/threat/ceilings rc 0 (выводы выше); сдаточный
  лист — этот файл, строка `СДАЧА:` в контракте; `scripts/check_sdacha.sh` в дереве
  ОТСУТСТВУЕТ (норма 192 ещё не реализована механизмом) — лист исполнен вручную,
  расхождений с прогонами нет.
* К-02: чисто — слово владельца п.10 (а)–(г) покрыто пунктами один-к-одному; решения 1–2
  арбитража исполнены указанными способами (канон/инструмент + граница); данные
  raw-замера и §Миграция перенесены числами (22/5/6; 13 записей; 5 строк risk-legacy).
* К-03: чисто — 7 строк ПЕРЕСЕЧЕНИЕ implementer (038/094/168/184/187/992/996) + 2
  ПЕРЕСЕЧЕНИЕ architect (батарея 187) + новая ЗОНА implementer registry/mesto-legacy.tsv
  + 178 строк orchestrator; сохранность доказана прогонами 187 (три режима rc 0) и 996
  (mismatches=1 = базлайн).
* К-04: чисто — тронутые файлы (контракт, батарея 201) в ЗОНА architect; probe.py/
  workflow_probe.py 187 в этом круге НЕ тронуты; реестр mesto-legacy — новая ЗОНА
  implementer, файл создаёт implementer, своих строк в чужие реестры не пишу.
* К-05: чисто — каждый пункт приёмки несёт команду и rc (§Приёмка); числа приёмки
  (30/45/15) равны выводам прогонов выше.
* К-06: н/п — клеток отказа среды батарея не вводит; недоступность compare-API — честный
  rc 1 «не проверена» (клетка `b-vneshnij-api-nedostupen`), не rc 2.
* К-07: чисто — голый прогон против ЖИВОЙ двери: 30 красных клеток наблюдают реальный
  дефект, 15 зелёных проходят через настоящие check_provodka/check_consumers/187а в тех
  же мирах; двойника двери нет.
* К-08: чисто — на каждое обязательство есть различающая клетка: 15 стабов каждый пойман
  на своей клетке (`--stabs` rc 0); исходниковые мутации решений 1/2 и блока К-10 круга 3
  роняют `--model` (выводы выше).
* К-09: чисто — конформные входы по ветвям: (а) 9 (нет заморозки/нет OBJECT/старый
  accept/равенство+дерево/потомок/OBJECT до заморозки/две заморозки/B→I→F/реализация
  в F), (б) 20 (продукт: влито/мимо main/отсутствует; внешние: влито/не влито/нет
  строки/кривая строка/дубль/API 404/станционный OBJECT; станция: объявлена+локальный/
  объявлена+внешний; неизвестное место: внешний/локальный; legacy: станция/влито/не
  влито/чужой blob/рабочая копия/staged/закоммиченная запись), (в) 10, (г) 6.
* К-10: чисто — наблюдаемый эффект: rc двери + наличие/отсутствие тега
  `done/contracts/777/1` (проверяется раннером у каждой live-клетки), не строки мира.
* К-11: чисто — ожидания в памяти раннера; оракул читает git-факты мира сам (теги →
  vmax, замороженный текст, risk-legacy и mesto-legacy по (NNN, blob) — оба реестра
  только `git show HEAD:<реестр>`, круг 3); compare/check-runs JSON — вне мира, шим curl
  в отдельном bin-каталоге.
* К-12: чисто — git-факты через plumbing (`merge-base --is-ancestor`, `rev-parse`,
  `tag -l`, `show <тег>:<путь>`, `diff-tree -r --raw --no-renames` — канон тождества
  деревьев), compare/check-runs — настоящий формат API GitHub; своего парсера форматов
  батарея не пишет.
* К-13: чисто — секретов батарея не вводит; токен идёт заголовком Authorization как у
  187а, в командных строках и файлах мира отсутствует.
* К-14: чисто — честные эквивалентные записи зелёны: `a-ravenstvo-frozen-verdikt`
  (F==CID с деревом «OBJECT + вердикт»), `b-stancionnyj-objavlennyj` (объявленная
  станция), `b-legacy-stancionnyj`/`b-legacy-vneshnij-vlit` (запись реестра), прочие
  прежние зелёные клетки всех пунктов.
* К-15: чисто — числа из выводов прогонов (45/15/30; 187: 54/0/56; 996: 111/76/1;
  ЗАЩИЩАЕТ 9 / НЕ ЗАЩИЩАЕТ 9); числа контракта сверены с этими выводами.
* К-16: чисто — класс риска: рисковый (гейт приёмки done, закрытый перечень слова
  владельца 2026-10-24); модель угроз по свойствам; две отвергнутых границы НЕ ЗАЩИЩАЕТ
  удалены, fail-closed для неизвестного места — в ЗАЩИЩАЕТ.
* К-17: чисто — предмет — механизм харнесса (дверь), не продукта; расхождений с моделью
  архитектуры нет.

## Известные остатки (не блокеры)

* `check_provodka` г2 зелёнеет подключением CI-шага (зона orchestrator, до freeze).
* `scripts/check_sdacha.sh` отсутствует в дереве (норма 192 не реализована механизмом):
  лист исполнен вручную выше.
* 996-матрица: единственный mismatches=1 существует до предмета 201 (базлайн).
* Третий critic-вызов (Crit201V3, по санкции владельца №35) закрыл всё, кроме блока
  К-10 — тот закрыт этим кругом fix3; четвёртый critic-вызов — ТОЛЬКО по слову
  владельца (запрашивается оркестратором); freeze закрыт РЕШЕНИЕМ 3 арбитража 1.
* Открытые вопросы владельцу 1–3 (117/139; смешанные/мультипродуктовые предметы;
  git-fallback вне GitHub) — решений воли/риска не принималось.
