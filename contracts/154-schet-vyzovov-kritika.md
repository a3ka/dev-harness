# Контракт 154 — механический счёт critic START до спавна и при freeze

КЛАСС ЗАДАЧИ: КОДОВЫЙ — красная батарея и энфорсмент действующего бюджета.
КЛАСС РИСКА: рисковый — деньги: платная critic-сессия, ошибочно разрешённая сверх бюджета.
КОНТЕКСТ: `roles/critic.md` §Быстрый-процесс/§Остановка/§Счёт — фазы и исключения; `AGENTS.md` §Арбитр — конечная граница; ADR `docs/owner/adr/2026-11-17-uzkij-kritik-konsultant-sessii.md` — полномочие консультанта; OWNER-BATCH-1118 №18 от 2026-11-18 12:16 UTC, строка 105 — одна переработка 154, не разрешение шестого вызова.

## Существующее

- `scripts/zamok_predmeta.sh` / `.omp/extensions/spawn-guard.ts`: станционная дверь до `task`; START под предметным мьютексом в `<state>/uchet.jsonl`. `repoId` — basename origin без `.git`, при отсутствии origin — basename репозитория. Точный ключ `(repoId,subjectId)` уже существует; роли `critic` и `critic-sol` — один расход. D10/D11/D21 и счёт START не заменяются.
- `zamok_predmeta.sh` D16: существующий тип `SLOVO` без различения назначения открывает GROUP-лимит. Поэтому записи бюджета имеют новый тип `SANKTSIYA` В ТОМ ЖЕ append-only журнале: нельзя случайно снять GROUP-барьер словом о critic. Отдельного реестра исключений нет. D28 пропускает arbiter без START — факт арбитража записывается отдельным событием этого же журнала.
- `scripts/freeze_contract.sh` §6в / контракт 013: прежняя единица — смена первой строки verdict через git log, с клапаном арбитража/владельца. Этот код сохраняется дословно для старых предметов. Новая ветвь повторно считает START до тега И реестра, не выводит количество вызовов из имён verdict.
- `roles/critic.md` §Быстрый-процесс: один полный + не более одного исправительного; третий — только по санкции при предписанной дельте; после третьего FAIL — один арбитраж о конечной границе, затем один узкий вызов на исполнение. Accept, новая платная сессия после обрыва, версия и переименование счёт не сбрасывают. Коммит границы новых предметов — `5ca237e4e6bc980c460ede8ee6d85af8a33d0601` (2026-10-24).
- ADR 2026-11-17: консультант сессии может санкционировать не более двух узких вызовов на предмет, на названные блоки и дельту конкретного OBJECT; сверх этого, для полного прохода и для перевода старого предмета нужен владелец. ADR 2026-11-18 о сверке/очередности нового бюджета не создаёт. Контракт 192 меняет нормы ролей, но не поглощает механический остаток 154.
- Предыдущие `verdicts/critic/contracts-154-v1{,b,c,d,e}-fail.md` — вход, не новые разрешения. Батарея сохраняет совместимость, предмет/станцию/роль, до-журнальную историю, обрыв с повторным OBJECT и независимость порога от номера. Б8/Б9 предъявляются полным доменом и снимками обоих результатов freeze, а не перечнем актуальных тегов.
- Исполняемый канон: `fixtures/workshop_project/schet_vyzovov_154/model/budget.py`; реальные скрипты для модельной вставки закреплены на main `e97e740ff87a2dccdfa950d4e0e1b157f0962a68`. Два git-объекта границы в `granica154.pack/.idx` нужны живой классификации, а не её двойнику. Реализация повторно использует существующий замок; модель не становится второй runtime-базой данных.

Обещание: механически не открывать непокрытую платную позицию и независимо не замораживать такой предмет. Наблюдение: rc, добавленная START либо отсутствие изменений журнала; при freeze — снимки тега и реестра. Frozen-обязательства 013, 027, 038, 060, 084, 140, 167, 192 и 996 сохраняются; миграция их затронутых toy-потребителей объявлена ниже, без отключения соседних гейтов. Источник поддерживаемого входа — реальный spawn-guard с трёхзначным SUBJECT и станционным state, затем существующий freeze.

## Frontier

Измеренная боль: живой журнал станции `/home/harness/.local/state/dev-harness-sessions/c907157c/zamok/uchet.jsonl` на 2026-11-18 содержит START `critic|critic-sol` для dev-harness: 143 — 7, 149 — 9, 154 — 5, 193 — 6. Это журнал текущей станции, не вся история: для 143 HANDOFF/сверка ConsCrit143 фиксируют ≥21 исторического вызова. Действующий предел не останавливается дверью, а прежняя идея общего капа пять не представляет новый порядок и адресные решения.

Мера текущей выборки: `jq -s '[.[] | select(.t=="START" and .repoId=="dev-harness" and (.rol=="critic" or .rol=="critic-sol"))] | group_by(.subjectId) | map(select(.[0].subjectId=="143" or .[0].subjectId=="149" or .[0].subjectId=="154" or .[0].subjectId=="193") | {predmet:.[0].subjectId,start:length})' <state>/uchet.jsonl`. Граница выборки — полный прочитанный файл этой станции; чужие станции не суммируются молча.

| Вариант | Что закрывает / почему не выбран |
|---|---|
| **START + адресные события того же журнала + committed receipt — выбран** | Одна позиционная последовательность, один источник количества, проверяемое основание исключения, пересчёт freeze. Ожидание над каждым вызовом, не над количеством файлов. |
| Прежний git log/verdict | Не видит платный обрыв без verdict и сжимает одинаковые решения. Остаётся только прежней ветвью старых предметов. |
| Общий числовой кап | Не различает санкционируемый третий, арбитражный четвёртый и адресные полномочия; отклонён, не является fallback. |
| Отдельный файл-реестр исключений | Два расходящихся источника budget-state; существующий журнал уже умеет события. Отклонён. |
| Только HANDOFF и ручной счёт | Не останавливает платный spawn; именно измеренный cognitive-only остаток. Отклонён как механизм. |

Вариант с провалом-ловцом: законный адресный вызов после обычного маршрута обязан оставаться зелёным, но перенос того же разрешения на другой OBJECT — именованный отказ; повторный арбитраж не покупает следующую позицию. Команды: `W --model` и `W --stabs`, ожидается rc 0. Конкретная привязка мутации к наблюдаемому различию находится ТОЛЬКО в исполняемом коде батареи.

## Инварианты

- И-1 — единица и область. Под тем же мьютексом, ДО START, считать ВСЕ START ролей `critic|critic-sol` точного `(repoId,subjectId)`, включая accept, aborted, освобождённые и повторный OBJECT. Порядок строк журнала задаёт позиции; новая попытка имеет `p=count+1`. Другие роли/предметы/репозитории бюджет не расходуют и исключения не дают. START добавляется ровно одна при разрешении, ни одной при отказе.
- И-2 — фазы. Позиции 1 и 2 — полный и максимум один исправительный. Позиция 3 требует адресную `SANKTSIYA` источника `orchestrator` с committed основанием выполнения условий §Остановка либо полномочного owner/consultant. Условия достаточности дельты проверяются людьми по действующей роли, не модельным поиском слов. Никакого безусловно бесплатного третьего нет.
- И-3 — граница. Событие `ARBITRAZH` с committed решением о конечной границе покрывает ТОЛЬКО позицию 4 (один узкий вызов после исполнения). Повторная запись/повторный арбитраж не покрывает позицию 5 и не сбрасывает счёт. Семантическое исполнение решения и обязательный accept не заменяются счётом.
- И-4 — явное адресное исключение. `SANKTSIYA` содержит `repoId,subjectId,object,nomer,istochnik,at,basisCommit,basisPath`; `nomer` — целое ≥3, `object` — ровно OBJECT оплачиваемого START, `istochnik` ∈ `vladelec|konsultant|orchestrator`. Orchestrator может покрыть только 3. Владелец — только явно названную позицию и OBJECT, без выдуманного общего числового потолка. Consultant — максимум ДВА фактически использованных узких вызова на предмет по ADR; неиспользованные и дублирующие записи сами вызовами не являются. Позиции уже покрытые обычным маршрутом/владельцем не расходуют consultant-бюджет. Ни факт verdict, ни имя файла, ни версия не являются санкцией.
- И-5 — основание. `ARBITRAZH` содержит `repoId,subjectId,at,basisCommit,basisPath`. Для обоих типов `basisCommit` — существующий 40-hex git commit; `basisPath` — точный repo-relative `HANDOFF.md` либо `verdicts/arbitration/*.md`, без пустых/`.`/`..` сегментов. Из ИМЕННО ЭТОГО commit:path читается отдельная строка `БЮДЖЕТ-154: ` + канонический JSON. Единственный сериализатор — `model/budget.py:receipt_line`: UTF-8, sorted keys, separators `,`/`:`, поля `t,repoId,subjectId`, у SANKTSIYA также `object,nomer,istochnik`. Значение журнала сравнивается с committed строкой буквально, не regex/подстрокой. Журнал выбирает факт, существующий документ доказывает его происхождение; нового реестра нет. Грамматика генерируется одним примитивом. Неподтверждённые основания → rc 1 `SANKTSIYA_NE_PODTVERZHDENA` / `ARBITRAZH_NE_PODTVERZHDEN`.
- И-6 — независимый freeze. `freeze_contract.sh <контракт> <причина> <repo> <state>` передаёт ТОТ ЖЕ state read-only режиму существующего замка `--schet-kritika`. Он заново покрывает каждую историческую позицию начиная с 3 по её OBJECT и текущую предлагаемую при spawn; будущая адресная санкция не легализует непокрытый прошлый вызов. Непокрытая позиция → rc 1 `KAP_VYZOVOV_KRITIKA`. Отказ до изменения frozen-тега И строки registry; никакой временный tag не остаётся.
- И-7 — история и совместимость. Если предмет уже был в реестре/заморожен к commit границы, прежний §6в действует дословно; адресный перевод старого предмета требует отдельного решения владельца. Поздний тег не делает предмет старым; отсутствие доступного снимка границы трактуется строго как новый. Ни версия, renaming, accept, арбитраж, ни исправление батареи не обнуляют START. Журнал не переписывается.
- И-8 — неизвестность не разрешение. Нет state/ledger, нечитабельный/битый JSONL/необъектная строка, malformed relevant event → rc 1 `SCHET_NEIZVESTEN`; verdict без START → `SCHET_RASHOZHDENIE`. История verdict с author-date `%at` до первого START требует явного additive засева `<state>/zasev_kritika.jsonl` (`repoId,subjectId,doZhurnala`, целое ≥1), иначе `SCHET_NEIZVESTEN`. Засев не стирает START и не предоставляет отсутствующие OBJECT/разрешения для исключительных позиций: неизвестная позиция ≥3 остаётся закрытой. Чужая станция/неполный перенос с наблюдаемой историей даёт отказ, не ноль.
- И-9 — полный дозволенный SUBJECT. Порог не зависит от номера/наличия тега, имени файла verdict, repoId и исхода FAIL/accept. Домен SUBJECT — все строки `[0-9]{3}` (000…999), а не текущие зарегистрированные номера. `--grammar` предъявляет на КАЖДОМ номере реальную установленную дверь и freeze с непокрытой позицией; оба эффекта freeze снимаются до вызова и сверяются после отказа. Конформный контрпример — достижимый этим API вход, инвариантный к переименованию значений, на котором предмет расходится с покрытием позиций; самоповреждение toy-механики им не является.

## Приёмочный критерий

`W` = `bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh` из корня кандидата. Для каждого режима rc 0 означает, что ВСЕ предъявления совпали с заранее снятым ожидаемым результатом; пустая выборка/неизвестный режим → ненулевой rc. Оракул — чистая функция параметров в памяти ДО субъекта; диск после субъекта не источник ожиданий. Модель вставляет счётчик в реальные копии закреплённых scripts, прочие проверки не заменяет двойниками.

| Дано / когда | Тогда |
|---|---|
| Честная модель; `W --model` | rc 0, все положительные и отказные сценарии совпали. Законный spawn добавил одну START; законный freeze создал tag и запись registry. |
| Позиционная модель на домене комбинаций; `W --domain-model` | rc 0; обе фазы, источник состояния/санкций, идентичность, до-журнальная история и прежний порядок совпали. |
| Обманные реализации; `W --stabs` | rc 0, все мутации различимы от модели своим исполняемым предъявлением. Привязки живут в коде, не в контракте. |
| Установленная реализация кандидата; `W --repo` и `W --domain` | каждый rc 0 ПОСЛЕ реализации; ДО неё именованное расхождение и rc 1, не безусловно красная заглушка. |
| Установленные scripts и настоящие git-объекты границы; `W --live` | rc 0 после реализации, старые предметы сохраняют прежний порядок, новые с тегом/без тега — новый. |
| Все 000…999; `W --grammar` | rc 0 после реализации, ненулевая полная выборка; отказ обоих API на каждом номере, registry и tags неизменны. |
| Форма кандидата в одноразовом ssh-клоне; `bash /home/harness/dev-harness/scripts/pre_critic.sh --repo <клон> contracts/154-schet-vyzovov-kritika.md` | rc 0, сырой вывод в инженерном докладе. |

Потребительская приёмка ПОСЛЕ реализации: `bash scripts/drill_contract_change.sh`, `bash scripts/verify_antiplacebo.sh --scope drill_contract_change`, `python3 fixtures/check_check_contract_ready/_doc027.py lifecycle`, `bash fixtures/workshop_project/red_samodostatochnost_repo_060.sh`, четыре `freeze-*` случая `fixtures/workshop_project/rezhim_996/probe.sh` (cap/project-arbitration/root-arbitration/gate-preserved), `bash fixtures/check_check_contract_ready/doc_048/probe_zhivoy_vyzov_048.sh`, `bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta` → rc 0. Семья 140 `red_odin_agent_140.sh` сохраняет frozen-результат п.9 (rc 1, ровно u01/w20/w21), не превращается в замаскированный зелёный прогон.

Живой контроль семейного барьера 027/048 (грамматика формы 036):
- `bash fixtures/check_check_contract_ready/doc_048/probe_zhivoy_vyzov_048.sh`

## Зоны и порядок

ЗОНА architect: contracts/154-schet-vyzovov-kritika.md fixtures/workshop_project/schet_vyzovov_154/
ЗОНА implementer: scripts/freeze_contract.sh scripts/zamok_predmeta.sh fixtures/freeze_contract/ scripts/drill_contract_change.sh fixtures/plan_084/ fixtures/check_check_contract_ready/_doc027.py fixtures/workshop_project/red_samodostatochnost_repo_060.sh fixtures/workshop_project/rezhim_996/probe.py fixtures/workshop_project/rezhim_996/model.py
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 013 заменить §6в для новых предметов, сохранив его дословно для старых, без изменения проверок исхода verdict, версий и атомарности заморозки.
ПЕРЕСЕЧЕНИЕ implementer: scripts/zamok_predmeta.sh — 140 вставить позиционную проверку под предметным мьютексом до START и read-only режим `--schet-kritika`; D10/D11/D21 сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/freeze_contract/ — 013 мигрировать только старые ожидания капа на новую единицу, не отключая совместимость.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/freeze_contract/ — 027 мигрировать только старые кап-сценарии без отключения doc-клеток.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/freeze_contract/ — 992 мигрировать только старые кап-сценарии без отключения fail-closed клеток.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 027 менять только §6в; doc-preflight сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 036 менять только §6в; spec-preflight сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 038 менять только §6в; consumers-gate сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 043 менять только §6в; precision-gate сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 060 менять только §6в; workflow-root сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 078 менять только §6в; origin-гейт сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 084 менять только §6в; plan-гейт сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 122 менять только §6в; предпосылки сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 992 менять только §6в; fail-closed других гейтов сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/freeze_contract.sh — 996 менять только §6в; workflowPaths сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/check_check_contract_ready/_doc027.py — 027 (зона architect заморожена): клетка freeze-doc-control мигрирует на вход состояния; ожидание меняется только §6в; клетки freeze-preflight/freeze-calibration не трогаются (умирают до §6в).
ПЕРЕСЕЧЕНИЕ implementer: fixtures/workshop_project/red_samodostatochnost_repo_060.sh — 060 (зона architect заморожена): клетки к3-е/к6б/к6е передают toy-корень состояния; ожидание меняется только §6в; клетки workflow-root (к5б) не трогаются.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/workshop_project/rezhim_996/probe.py — 996 (зона architect заморожена): семья freeze-* мигрирует на новую единицу — позиции START, арбитраж позицию 4 и только, санкции по nomer+OBJECT; зелёные ноги ремонта получают вход состояния; workflowPaths-поведение сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/workshop_project/rezhim_996/model.py — 996 (зона architect заморожена): оракул freeze переносит кап на единицу START с той же областью новых предметов; остальная модель не меняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/drill_contract_change.sh — 038 шаги «заморозка v1/v2» передают toy-корень состояния; остальной дрилл не меняется.
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 140 добавить только строку self-test `check:schet-vyzovov-154-family-selftest`, с `W`, `W --domain`, `W --stabs`, `W --live`, `W --grammar` после реализации.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 140 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 141 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 142 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 145 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 146 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 147 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 148 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 149 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 153 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 994 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 995 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 997 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 998 только производная строка CI 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 141 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 142 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 143 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 145 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 146 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 147 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 148 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 149 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 153 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 995 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только новая строка self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 140 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 141 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 142 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 143 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 145 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 146 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 147 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 148 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 149 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 153 только замер строки self-test 154.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 995 только замер строки self-test 154.

Порядок: architect красное, модель и закрывающее свойство grammar → critic → freeze с состоянием станции → implementer одна функция в существующем замке + её вызов из freeze с веткой прежнего §6в + миграция всех потребителей по ПЕРЕСЕЧЕНИЯМ → orchestrator CI (`gen_ci_steps.sh --write`, `--check` rc 0) и живой засев до-журнальных предметов (И-8) → adversary (деньги) → reviewer → done. Ответственный за станционный путь, данные учёта и строки ARBITRAZH/SANKTSIYA при freeze — orchestrator, не CI. Ни роли судьи, ни AGENTS.md этот контракт не редактирует.

ПРЕДПОСЫЛКИ:
- setting читаемый полный ledger станции в том же корне, который использует spawn-guard; при переносе станции переносится полный журнал либо заморозка останавливается. CI-запуск без живого ledger использует только независимые игрушечные state.
- setting bash, git, jq, python3 в PATH CI и станции; дополнительных secrets/variables/environments не нужно.

СДАЧА: fixtures/workshop_project/schet_vyzovov_154/sdacha.md

ПРОВОДКА:
- guard=fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh
ПРОВОДКА-ЭНФОРСМЕНТ: действующее ограничение денег на платные сессии судьи получает количественный guard на уже существующем spawn-хуке и freeze; новой поведенческой нормы роли нет.

## Модель угроз

ЗАЩИЩАЕТ:
- пропуск непокрытой платной позиции из-за одинаковых verdict, renaming, версии, смены OBJECT или обрыва;
- перенос разрешения на другой OBJECT/номер, повторное использование арбитража и третий фактически потраченный consultant-вызов без owner-основания;
- голую строку исключения без отдельной канонической строки в названном git commit:path, подстрочное совпадение и незакоммиченный файл вместо основания;
- нулевой счёт при отсутствующем/битом state, наблюдаемом расхождении с verdict и до-журнальной истории без usable засева;
- обход spawn-барьера прямым freeze, а также tag/registry side effect при его отказе;
- зависимость порога от собственного подмножества трёхзначных SUBJECT на обеих установленных точках.

НЕ ЗАЩИЩАЕТ:
- semantic-полномочие автора committed санкции и достаточность дельта-листа третьего, узость consultant-вызова, исполнение арбитража и очередность «после третьего FAIL» — cognitive-only; ловцы: оркестратор и reviewer по действующим ролям/ADR. Механика требует основание, но не выдаёт его сама.
- злонамеренную замену целого согласованного журнала/его подписи, неверный additive засев и поддельное самообъявление istochnik в committed документе — существующий журнал не криптографический; ловец: станционный аудит, журнал платформы и сверка полномочной роли.
- обход task-хука другой установкой omp/сырым вызовом модели и внешнюю несогласованную перезапись state без предметного mutex — ловцы: независимый журнал модели и аудит станции.
- автоматический перевод старого предмета на новый порядок и проектные переопределения workflowPaths для дополнительных мест receipt: нужен отдельный адресный cutover, старый маршрут не меняется молча; ловец: оркестратор по §Область и 996.
- выдачу нового бюджета для самого 154: эта инженерная переработка не разрешает шестой critic-вызов; его основание после сдачи решает полномочная роль отдельно.

## Незаполненные требования:
нет
