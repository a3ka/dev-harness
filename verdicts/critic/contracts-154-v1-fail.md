FAIL
OBJECT=a8b3e6eea8f1c497d8c38bfb9781b090de7d693b
СУД: repo=dev-harness; предмет=154; фаза=контракт (+красная батарея); роль=critic; вызов=1/2 (полный; Быстрый-процесс; предел 5 на предмет); КЛАСС РИСКА=рисковый (деньги); модель-план=anthropic/claude-opus-5-5; сессия=Crit154; модель-факт=anthropic/claude-opus-5-5; SHA=a8b3e6eea8f1c497d8c38bfb9781b090de7d693b; предыдущий=нет; исключение=нет.
Сверка счёта: живой учёт станции (`/home/harness/.local/state/dev-harness-sessions/c907157c/zamok/uchet.jsonl`, прочитан только для чтения) несёт по dev-harness/154 ровно один critic START — `Crit154`, object=a8b3e6ee…, 2026-11-02T01:21:58Z. Это вызов 1.
Независимость: автор OBJECT — Arch154 (openai-codex/gpt-6-sol, отчёт `/tmp/dev-harness-verify/Arch154/report.md`; коммиты под identity architect); судья — anthropic/claude-opus-5-5. Семейства разные.

Предмет — закоммиченный `a8b3e6eea` (`git cat-file -t` → `commit`). Дерево судьи: одноразовый клон `/tmp/dev-harness-verify/Crit154/repo`, ветка автора получена fetch. Мутации — только во втором одноразовом клоне `/tmp/dev-harness-verify/Crit154/mut`. В основной чекаут ничего не писалось, push не было.

Итог: 5 блокирующих классов (Б1–Б5), 4 расхождения самоописания (С1–С4), 5 советов (Н1–Н5). Набор артефактов полон: предмет, критерий, исполнители, ЗОНА-строки, КЛАСС РИСКА, ПРОВОДКА, ПРЕДПОСЫЛКИ и модель угроз на месте.

## Замеры: сырые команды и rc (последовательно, корень клона = OBJECT)

```
$ bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh                   → rc=1  CELLS=35 GREEN=6   (RED 29: five-identical … critic-sol-only; GREEN boundary-spawn-0..4, boundary-freeze-1)
$ bash …/red_schet_vyzovov_154.sh --model                                                     → rc=0  CELLS=35 GREEN=35
$ bash …/red_schet_vyzovov_154.sh --domain                                                    → rc=1  CELLS=136 GREEN=76  (RED 60)
$ bash …/red_schet_vyzovov_154.sh --domain-model                                              → rc=0  CELLS=136 GREEN=136
$ bash …/red_schet_vyzovov_154.sh --stabs                                                     → rc=0  SVJAZI=8 CAUGHT=8 LIVE=0 (каждый STAB_CAUGHT своей одноимённой клеткой)
$ bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh                         → rc=1  KLETKI 66 KRASNYH 3 (u01-uchet-svod, w20-limit-harness-tri-ok, w21-limit-back-tri-ok)
$ bash scripts/pre_critic.sh contracts/154-schet-vyzovov-kritika.md                           → rc=0  «КРИТИК: дверь зелёная»
$ bash scripts/check_ceilings.sh                                                              → rc=0  «потолки в порядке»
$ bash scripts/check_precision_gate.sh . contracts/154-schet-vyzovov-kritika.md               → rc=0  «OK»
$ bash scripts/check_threat_model.sh . contracts/154-schet-vyzovov-kritika.md                 → rc=0  «секция валидна (ЗАЩИЩАЕТ 3, НЕ ЗАЩИЩАЕТ 4)»
$ bash scripts/check_provodka.sh . contracts/154-schet-vyzovov-kritika.md                     → rc=1  «guard не подключён: …red_schet_vyzovov_154.sh не вызывается в .githooks/ или .github/workflows/» (ожидаемо до CI-строки)
$ bash scripts/check_zones.sh --incr /tmp/dev-harness-verify/Crit154/zcache/cache .           → rc=0  (полный обход 427 с; хвост: «ok contracts/105-… — работа не раздаётся …»)
```

Честная реализация, на которой проверялись Б1, Б2 и регресс 140: throwaway `/tmp/dev-harness-verify/Crit154/mk_impl.py` вызывает собственный `probe.prepare_scripts(…, 'model')` батареи и кладёт полученные модельные `zamok_predmeta.sh` и `freeze_contract.sh` в `scripts/` клона `mut`. Это та вставка, которую контракт называет эталоном.

## БЛОКИРУЕТ

**Б1. БЛОКИРУЕТ fixtures/workshop_project/schet_vyzovov_154/probe.py:318 (обязательство contracts/154-schet-vyzovov-kritika.md:37 п.4 и ПЕРЕСЕЧЕНИЕ CI :49).** Ворота недостижимы по построению.
ОБЯЗАТЕЛЬСТВО: :37 — «Дана реализация: когда `W`, `W --domain` и `W --stabs`; тогда все rc 0». ПЕРЕСЕЧЕНИЕ CI :49 гоняет `W` и `W --domain` после реализации.
СОСТОЯНИЕ: честная реализация, то есть эталонная вставка батареи в настоящих `scripts/` клона `mut`.
НАБЛЮДЕНИЕ:
```
$ python3 /tmp/dev-harness-verify/Crit154/mk_impl.py /tmp/dev-harness-verify/Crit154/mut
$ bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh            → CELLS=35 GREEN=35  rc=1
$ bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --domain   → CELLS=136 GREEN=136 rc=1
```
Причина в `return 0 if mode == 'stabs' and not failed or mode in ('model', 'domain-model') and not failed else 1`: режимы `repo` и `domain` возвращают 1 всегда. Батарея лежит в ЗОНА architect (:43), поэтому implementer её не исправит, а CI-строка 154 станет вечно красной.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: rc режимов `W` и `W --domain` равен 0 тогда и только тогда, когда все клетки зелёные, и ≠0 при любой красной. Это предъявлено прогоном на эталонной вставке, установленной в `scripts/`: rc 0. На текущем дереве по-прежнему rc 1.

**Б2. БЛОКИРУЕТ contracts/154-schet-vyzovov-kritika.md:44 (ЗОНА implementer), :45, :50, :54, :59 (ПЕРЕСЕЧЕНИЕ 013/027/060/996 «менять только §6в … сохраняется»), :9 (перечень закрепивших прежнюю семантику).** Зона исполнения неполна: потребители `freeze_contract.sh` лежат вне зоны.
ОБЯЗАТЕЛЬСТВО: :19 требует, чтобы freeze без пути к состоянию отказывал `SCHET_NEIZVESTEN`. :38 п.5 требует, чтобы прежние freeze-ворота остались зелёными «не вырезая чужую фикстуру». ПЕРЕСЕЧЕНИЕ обещают 027/060/996, что их механика «сохраняется».
СОСТОЯНИЕ: та же честная реализация. Все прочие вызывающие замораживают с 1–3 аргументами и ждут rc 0, а часть из них закрепляет старый §6в.
НАБЛЮДЕНИЕ (база OBJECT → честная реализация):
```
$ bash scripts/drill_contract_change.sh                                     rc 0 → rc 1 «ОТКАЗ: SCHET_NEIZVESTEN: корень состояния не передан» (шаг «заморозка v1»)
$ bash fixtures/workshop_project/red_samodostatochnost_repo_060.sh           rc 0 (17/17) → rc 1 (14/17: к3-е-реестр-в-toy, к6б-…-freeze, к6е-…)
$ python3 fixtures/check_check_contract_ready/_doc027.py lifecycle           rc 0 → rc 1 «DOC-lifecycle/freeze-doc-control: поведение rc=1, требуется 0»
$ bash fixtures/workshop_project/rezhim_996/probe.sh --case freeze-cap                  rc 0 → rc 1 PROJECT_CAP_BYPASSED (клетка требует «кап кругов» старого §6в)
$ bash fixtures/workshop_project/rezhim_996/probe.sh --case freeze-project-arbitration  rc 0 → rc 1 PROJECT_ARBITRATION_NOT_READ (клетка требует, чтобы арбитраж СНИМАЛ кап)
$ bash fixtures/workshop_project/rezhim_996/probe.sh --case freeze-root-arbitration     rc 0 → rc 1
$ bash fixtures/workshop_project/rezhim_996/probe.sh --case freeze-gate-preserved       rc 0 → rc 1 PROJECT_GATE_REPAIR_REFUSED:spec
```
Все четыре семьи идут в CI: ci-steps.tsv:245, шарды ap2 и ap5 в ci-steps.tsv:274 и :277. Две из них — зарегистрированные потребители писателя (`scripts/consumers.d/freeze_contract.sh__check_check_contract_ready.tsv`, `…__drill_contract_change.tsv`) и потому подпадают под consumers-gate 038. Ни один из этих путей не входит в ЗОНА implementer (только `fixtures/freeze_contract/`). Implementer либо остановится, либо молча расширит зону.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: годится любой из двух путей.
- Каждый файл, чьи ожидания меняет новая сигнатура или семантика freeze (как минимум `scripts/drill_contract_change.sh`, `fixtures/check_check_contract_ready/_doc027.py`, `fixtures/workshop_project/red_samodostatochnost_repo_060.sh`, `fixtures/workshop_project/rezhim_996/{probe.py,model.py}`), получает ЗОНА/ПЕРЕСЕЧЕНИЕ с названной миграцией, а приёмка требует их команды с rc 0 после реализации.
- Либо контракт называет такой вход состояния для freeze, при котором эти команды остаются rc 0 без правки и без ослабления «нет состояния → отказ» на живой станции.

**Б3. БЛОКИРУЕТ contracts/154-schet-vyzovov-kritika.md:35 (домен `--model`/`--domain-model`) и fixtures/workshop_project/schet_vyzovov_154/probe.py:240–277 (CASES, DOMAIN).** Домен не содержит осей, которые названы обязательствами. Обманные счётчики проходят обе матрицы.
ОБЯЗАТЕЛЬСТВО:
- :19 «без пути/при недоступности журнала — `SCHET_NEIZVESTEN`, даже если вердикт accept»;
- И-2 :26 «freeze … отвергает … отсутствие полного учёта (`SCHET_NEIZVESTEN`)»;
- И-1 :25 «точным `(repoId,subjectId)` … Другие роли не расходуют именно этот бюджет»;
- :21 и И-3 :27 «verdict без START — отказ» (в том числе на двери);
- И-4 :28 «файл арбитра … не увеличивают кап» при freeze.
СОСТОЯНИЕ: эталонная модель с одной мутацией (throwaway `/tmp/dev-harness-verify/Crit154/mutate.py`, клон `mut`). Судят настоящие `zamok_predmeta.sh` и `freeze_contract.sh` эталонной вставки.
НАБЛЮДЕНИЕ: каждая команда — `python3 mutate.py . <мутант>; bash …/red_schet_vyzovov_154.sh --model; … --domain-model; git checkout -- fixtures`.
```
MUTANT freeze-failopen        (freeze: `if [ $# -ge 4 ] && [ -f "$4/uchet.jsonl" ]; then <счёт>; fi`)  --model rc=0 CELLS=35 GREEN=35   --domain-model rc=0 CELLS=136 GREEN=136
MUTANT no-repoid              (ключ без repoId)                                                       --model rc=0 CELLS=35 GREEN=35   --domain-model rc=0 CELLS=136 GREEN=136
MUTANT no-subject             (ключ без subjectId)                                                    --model rc=0 CELLS=35 GREEN=35   --domain-model rc=0 CELLS=136 GREEN=136
MUTANT all-judges             (бюджет критика расходуют adversary/reviewer)                            --model rc=0 CELLS=35 GREEN=35   --domain-model rc=0 CELLS=136 GREEN=136
MUTANT spawn-no-rashozhdenie  (verdict без START проверяется только на freeze)                         --model rc=0 CELLS=35 GREEN=35   --domain-model rc=0 CELLS=136 GREEN=136
MUTANT freeze-arb-owner       (freeze: арбитраж «К ВЛАДЕЛЬЦУ» обнуляет сверхкап до 5)                    --model rc=0 CELLS=35 GREEN=35   --domain-model rc=0 CELLS=136 GREEN=136
```
Тяжелее всех `freeze-failopen`. Все нынешние вызывающие замораживают без 4-го аргумента, так что этот мутант снимает кап при freeze целиком, а именно это закрывает пункт ЗАЩИЩАЕТ «обход спавн-барьера при прямом freeze» (:173). Причина: во всех freeze-клетках есть и 4-й аргумент, и файл ledger. Все клетки «missing/unreadable/invalid» стоят только на двери, в мире одна пара (repoId, subjectId), других ролей судей нет, verdict без START есть только на freeze, а при freeze арбитраж встречается только с первой строкой «РЕШЕНИЕ».
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: перечень мутантов этот класс не закрывает. Конечный домен обеих фаз должен включать оси:
- источник {нет аргумента состояния (freeze), ledger отсутствует, нечитаем, битый, пуст при наличии verdict};
- посторонние строки ledger {другой repoId с тем же subjectId, другой subjectId того же repo, START adversary/reviewer того же предмета};
- первая строка арбитража {РЕШЕНИЕ, К ВЛАДЕЛЬЦУ, ВЕРНУТЬ}.
Оракул — от n и источника. Шесть мутантов выше на нём краснеют, честная модель остаётся зелёной.

**Б4. БЛОКИРУЕТ contracts/154-schet-vyzovov-kritika.md:21, :25 (И-1), :27 (И-3).** Не решено, как считать вызовы критика, сделанные до начала журнала. Это живое достижимое состояние станции, и решение молча оставлено исполнителю.
ОБЯЗАТЕЛЬСТВО: слово владельца — «механизм обязан считать реальные вызовы», «неизвестный счёт — остановка, не пропуск». roles/critic.md §Счёт: «Неустановленный счёт не считается нулём». И-1 :25 требует посчитать «все предшествующие» вызовы.
СОСТОЯНИЕ: живой учёт начинается с 2026-10-31T05:38:09Z. До этой даты у предметов харнесса есть платные вызовы критика без START. Копия учёта снята только для чтения в `/tmp/dev-harness-verify/Crit154/livecopy/`, предмет — клон OBJECT.
НАБЛЮДЕНИЕ: эталон батареи `model/budget.py` на живых данных:
```
$ python3 repo/fixtures/workshop_project/schet_vyzovov_154/model/budget.py --sostojanie livecopy --repo repo --subject N --phase spawn
148 verdict-files@OBJECT=7 critic-START=4 :: rc=0          ← допуск
147 verdict-files@OBJECT=4 critic-START=0 :: ОТКАЗ: SCHET_RASHOZHDENIE … rc=1
149 verdict-files@OBJECT=3 critic-START=0 :: ОТКАЗ: SCHET_RASHOZHDENIE … rc=1
145 verdict-files@OBJECT=8 critic-START=0 :: ОТКАЗ: SCHET_RASHOZHDENIE … rc=1
```
У 148 четыре вызова критика закоммичены 2026-10-30 (`вызов 1/2 FAIL`, `круг 2/2 FAIL`, `scoped приёмка-10`, `scoped … Crit148c accept`), ещё четыре START есть в журнале после 2026-10-31. Реальный счёт не меньше 8, а механизм видит 4 и пропускает пятый, то есть фактически девятый платный вызов. Это ложный пропуск — ровно тот денежный риск, ради которого предмет заведён.

У 147 и 149 пауза снята 2026-11-02, предметы активны. Их следующий вызов критика и их freeze получают постоянный `SCHET_RASHOZHDENIE`, а контракт не называет ни выхода, ни записи-засева. :21 прямо отказывается сопоставлять историю файлов с START, поэтому неполный журнал выдаётся за полный.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: контракт называет обращение с предметом, чья история критика старше первого critic START в журнале по `(repoId, subjectId)`. Например: отказ `SCHET_NEIZVESTEN`, когда первый коммит `verdicts/critic/contracts-NNN-*` старше первого critic START, и названная запись-засев владельца или оркестратора, которую механизм читает. Нужна клетка «история старше журнала» на двери и на freeze, где сочетание 4 до-журнальных verdict + 4 START не даёт допуска.

**Б5. БЛОКИРУЕТ contracts/154-schet-vyzovov-kritika.md:25–28 (И-1…И-4 без области), :45 («013 заменить §6в»).** Противоречие действующей норме об области быстрого процесса.
ОБЯЗАТЕЛЬСТВО: roles/critic.md:20 §Область — «Этот порядок действует для новых предметов … Предметы, заведённые к этому коммиту [`5ca237e4`] … ведутся по прежнему порядку (три круга по предмету с созывом арбитра)». roles/critic.md:28 — «Предел вызовов — для новых предметов; для ранее открытых предметов действует прежний порядок до адресного решения владельца» (то же в AGENTS.md:171–173).
СОСТОЯНИЕ: на OBJECT открыты (без `done/`) предметы, номер которых выдан до `5ca237e4e`: 001, 043, 078, 084, 092, 094, 095, 097, 098, 116. Предок `id/CONTRACT/NNN` — `5ca237e4e`. Их новая версия замораживается тем же `freeze_contract.sh`.
НАБЛЮДЕНИЕ: контракт заменяет §6в для всех предметов без области. Для старых предметов исчезает действующий порядок «третий круг — арбитр или слово владельца» (старый §6в), и на них ложится кап 5. Без START в журнале они получают `SCHET_RASHOZHDENIE` (см. Б4). Адресного решения владельца о переводе ранее открытых предметов в контракте нет.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: контракт называет область: новые предметы — новый счёт, ранее открытые — прежний §6в либо названное адресное решение владельца. Клетка закрепляет, что старый предмет судится прежним порядком, а новый — новым.

## САМООПИСАНИЕ (число/адрес в тексте → живое значение)

- С1. contracts/154-schet-vyzovov-kritika.md:5 «owner/plan-154 §Остаточный риск» и :13 «owner/plan-154 §Остановка и §Счёт» → такого артефакта нет. Живые адреса: `docs/owner/2026-11-01-porog-arbitra.md` §«Остаточный риск (назван прямо)» п.2; §Остановка и §Счёт лежат в `roles/critic.md`.
- С2. contracts/154-schet-vyzovov-kritika.md:32 «Оракул результата фиксируется в памяти ДО вызова субъекта» и probe.py:219 «captured before the subject» → в коде `expected` вычисляется на probe.py:220, ПОСЛЕ `result = …` на :218. Оракул — чистая функция параметров, поэтому на исход это не влияет, но текст неверен.
- С3. contracts/154-schet-vyzovov-kritika.md:38 «frozen 140 §Приёмка п.9» → во frozen/contracts/140/2 раздел называется «## Приёмочный критерий»; п.9 = `KLETKI 66 KRASNYH 3`, содержание совпадает.
- С4. contracts/154-schet-vyzovov-kritika.md:9 «`fixtures/freeze_contract/case_kap_*` и `probe_012_dva_kruga.sh` закрепляют ПРЕЖНЮЮ семантику» (5 файлов) → живых закрепляющих больше: ещё `fixtures/workshop_project/rezhim_996/probe.py` (клетки freeze-cap, freeze-root-arbitration, freeze-project-arbitration) и `rezhim_996/model.py`. Это та же причина, что в Б2.
- Совпали с живыми: 35 (CELLS=35), «GREEN<35» (6, RED 29), 136 (CELLS=136; 72 дверь + 64 freeze), «GREEN<136» (76, RED 60), `SVJAZI=8 CAUGHT=8 LIVE=0`, восемь стабов поимённо = ключи `edits`, `KLETKI 66 KRASNYH 3` (u01/w20/w21), 0..7 (`range(8)` × 2 фазы), модель угроз 3/4, А-210/933/936/937, Н-57 (013:30), 041 §Инварианты п.1 (frozen 041/1), арбитраж 099 (verdicts/arbitration/contracts-099-spawn-trust-v1.md), D10/D11/D21 в zamok_predmeta.sh.

## СОВЕТ

- Н1. :19 «одна функция подсчёта … `--schet-kritika` … (не второй счётчик)» не доказывается ни одной командой. Эталон вызывает `budget.py` прямо из freeze. Либо клетка «freeze вызывает read-only режим замка», либо снять утверждение.
- Н2. И-4 и НЕ ЗАЩИЩАЕТ :179: после явного решения владельца о шестом вызове нет названного канала, который механизм прочтёт. Под ним остаётся только ручная правка журнала, а это класс «порча журнала». Стоит назвать канал (по образцу строки SLOVO у 140) или прямо записать, что его нет.
- Н3. Стаб `unreadable-ledger` ловится откатом инициализации замка (rc 2), а не правкой `budget.py`: строка `return 0` в мутанте не исполняется. Привязка верна, но эта часть мутанта мёртвая.
- Н4. Эталон закреплён на `BASELINE=7fd217d79`. Любая будущая правка §6в или точки вставки даст `NOT_IMPLEMENTED`, то есть громкий отказ, а не тихое расхождение. Это стоит назвать в тексте.
- Н5. Гонка двух спавнов критика одного предмета при n=4 держится существующими мьютексом и D21 (клетка 140 b04). Отдельной клетки 154 нет. Не блок.

## Регресс 140 (неухудшение)

`red_odin_agent_140.sh` на OBJECT и на честной реализации (клон `mut`) даёт одинаково rc=1 `KLETKI 66 KRASNYH 3`: те же u01, w20, w21, новых красных клеток нет.

## Что НЕ проверено

- `bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta` не прогонялся: read-only режима `--schet-kritika` в эталоне нет.
- Живые станционные пути (spawn-guard.ts → `--sudit`) не исполнялись, только игрушечные миры. Эмуляторы и нативные сборки не запускались.
- Полные батареи 027/060/996/drill после реализации прогнаны только в объёме, указанном в Б2. `fixtures/freeze_contract/` (зона implementer) не прогонялась.
- `red_limit_aktivnyh_078.sh` красен уже на базе (rc 1 на OBJECT и на честной реализации), поэтому для Б2 он не информативен.
- Отсутствие других красных в полном 996/060/027 после реализации не доказано: прогонялись только перечисленные клетки.
