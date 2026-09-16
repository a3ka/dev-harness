# Контракт 027 — механизм doc-приёмки некодовых документов

Черновик по ROADMAP §8. Основание: решения владельца 2026-09-16 по Q1–Q7,
D10–D18; дословный ответ «я согласен с архитектором». Источники конструкции:
ArchSection8Frontier §1 (механизм), ArchSection8Consult (границы суда),
ArchSection8Docs (разделение реестра), ArchSection8Odelix §3 (типизация оснований).
Это КОДОВЫЙ контракт механизма, не принимаемый им продуктовый документ.

## Предмет

Реализовать `scripts/doc_contract.ts` (единственный разбор грамматики и профилей),
`scripts/check_document.ts` (приёмка пакета), `scripts/render_document.ts`
(производные формальные фрагменты), doc-preflight существующих
`check_contract_ready.sh`, его мета-барьера `check_check_contract_ready.sh` и
`freeze_contract.sh`; провести команды через package.json и CI.

Ровно два профиля: `product` и `architecture`. `as-is`/`to-be` — статусы
утверждений; ADR — форма результата; MCP — класс интерфейсных обязательств
architecture, не третий профиль. Автор результата — implementer с doc-профилем,
новая роль docwriter и модельные назначения не вводятся.

Гарантия Q7 снимочная: принято относительно проверенных источников, без обещания
сопровождения. Несовпадение объявленных current-зависимостей вычисляется при
проверке; историческое принятие не отменяется, обычная кодовая поставка от дрейфа
автоматически не блокируется. Обязательство current выбирает потребляющий контракт.
Реестр и автоматическое отображение дрейфа корпуса — следующий предмет.

## Грамматика doc-контракта

У будущего doc-контракта ровно один раздел `## Док-приёмка` и ровно один fenced
`json`-блок внутри него. Вне этого раздела JSON и упоминания ID не нормативны.
Ниже НОРМАТИВНЫЙ пример формы (не активная doc-спецификация самого 027): конкретные
OID источников выбираются doc-контрактом из Git, здесь пример использует внешний
источник, не вымышленные OID.

```json
{
  "type": "documentation",
  "version": 1,
  "profile": "product",
  "outputs": {"markdown": "docs/ёж.md", "evidence": "docs/ёж.evidence.json"},
  "required": {
    "sections": ["Обзор-Ёж"], "scenarios": ["Сценарий-ёж"],
    "components": [], "links": [], "decisions": ["Решение-Ёж"],
    "failures": ["Отказ-ёж"]
  },
  "assertions": [{
    "id": "Цель-Ёж", "status": "to-be", "kind": "proposal",
    "decision": "Решение-Ёж", "check": {"type": "decision"}
  }],
  "sources": [{
    "id": "Решение-владельца", "kind": "external",
    "address": "urn:example:decision:yozh", "freshness": "historical",
    "verification": "cognitive-only"
  }],
  "questions": [{"id": "Вопрос-Ёж", "blocking": true, "allow_open": false}],
  "calibration": {
    "positive": "fixtures/positive.json",
    "negative": [{"evidence": "fixtures/negative.json", "violation": "coverage"}]
  }
}
```

Грамматика ID — целиком `[A-Za-zА-Яа-яЁё0-9][A-Za-zА-Яа-яЁё0-9_-]*`.
UTF-8 без транслитерации; свободная проза не ограничивается грамматикой ID.
Локальные пути относительны корню, без пустого компонента, `.`/`..`, NUL и
выхода через симлинк; абсолютный адрес не превращается в локальный путь.
Дубли ID в одном типизированном множестве, неизвестный профиль/статус/тип проверки,
неверные типы полей и неоднозначный блок — именованный отказ rc=1. Поля расширения
не интерпретируются как полномочия или исполняемые команды.

`required` содержит непустые sections; product — непустые scenarios; architecture —
непустые components, links, decisions, failures. Остальные объявленные множества
могут быть пустыми. Каждое множество в результате равно своему объявленному
набору ID; дубли запрещены. Assertions и questions покрываются точно так же.
Для product сценарий содержит непустые actor/input и outcomes (ID, kind
success|failure, непустой result); оба вида исхода обязательны, объявленные
failures связаны с отказными outcomes. Architecture: boundary компонента,
from/to/contract связи, result отказа; концы связи обязаны разрешаться.
Decisions: id, state accepted|open, source; accepted ссылается на разрешимый
локальный файл либо ID объявленного внешнего источника. Questions: id,
state resolved|open, decision; resolved требует accepted-решения, open допустим
только при allow_open=true и blocking=false. Назвать вопрос решённым без основания
нельзя; достоверность решения — ограниченный содержательный суд.

As-is assertion содержит id, status, kind, evidence и check; результат повторяет
id/status/kind, содержит value и evidence. Типы kind: observation, calculation,
experiment-plan, experiment-result, event; proposal допустим только для to-be.
Evidence несёт собственный id, assertion, kind, source и dependencies. Ссылки
двусторонни, тип evidence совпадает с утверждением: план не результат, событие не
расчёт. To-be содержит decision и check.type=decision, не выдаёт evidence
наблюдения за доказательство осуществлённости; допустимое open-решение явно
принимается замороженными questions. Проверка права доступа не заменяется меткой.

Sources: git — id, kind, path, commit (полный OID), blob (полный OID), freshness
current|historical. Commit:path обязан разрешиться именно в blob; current сверяет
байты текущего файла с этим blob, НЕ равенство всего HEAD. Historical использует
объявленный blob, рендерит исторический статус. External — id, kind, address,
freshness=historical, verification=cognitive-only; без разрешённого локального
свидетельства не удовлетворяет механическому as-is. Checker не скачивает адреса,
не сканирует домашний каталог, не исполняет команды из evidence.

Dependencies типизированы: observation-time (RFC3339 дата наблюдения), data-time
(RFC3339 время данных), calculation-version (непустая версия расчёта), source
(ID объявленного источника). document_date (YYYY-MM-DD) — дата документа, не
замена этим зависимостям. Порог возраста и доменные ограничения — только явно
объявленная проверка контракта; универсального TTL нет. Для calculation требуются
source, data-time и calculation-version; observation требует observation-time.
Иные виды основания несут свои явно объявленные зависимости; совпадение хеша
не доказывает временную пригодность. Учёт состава корпуса/датасета — не этот контракт.

Check.type: json-pointer (source, pointer RFC6901, expected JSON-значение),
exact-line (source, expected строка: самостоятельная строка), probe (argv —
непустой массив строк, pointer, expected), decision (для to-be). Простые меры
читают разрешённый source; probe запускается без shell, cwd изолированного
проектного чекаута, без подразумеваемой сети. Результат probe — JSON stdout,
rc=0; выбранное значение сравнивается структурно и с expected, и с value.
Rc=1 — нарушение; rc=2/невозможность запуска — проверка не состоялась, итог 2,
никогда не зелёное/не содержательное красное. Sidecar не определяет expected/argv.

## Док-пакет и публичные команды

Markdown — свободное объяснение с самостоятельными строками
`<!-- doc:section ID -->`; маркер существует ровно в собственной секции,
упоминание в произвольном комментарии или более длинном ID не считается.
JSON-свидетельства содержат version/profile/document_date и типизированные массивы
sections/scenarios/components/links/decisions/failures/questions/assertions/evidence
описанной выше формы. Синтетические исполняемые примеры: `_doc027.py:toy`.

Формальные факты и их статусы/источники генерируются из JSON в единственную пару
самостоятельных строк `<!-- doc:formal:start -->` / `<!-- doc:formal:end -->`.
Автор не набирает факты вторым исходником. Renderer изменяет только этот фрагмент;
свободная проза и section-маркеры сохраняются. Отсутствующие/дублированные границы
дают отказ без частичной записи. --check сравнивает детерминированный результат,
ничего не исправляет. Формат строк внутри фрагмента — деталь реализации, не второй
парсер в пробах; сравнение выполняется через публичный --check.

```sh
node "$HARNESS/scripts/check_document.ts" --root "$PROJECT" --contract "$CONTRACT" --preflight
node "$HARNESS/scripts/check_document.ts" --root "$PROJECT" --contract "$CONTRACT" --check
node "$HARNESS/scripts/render_document.ts" --root "$PROJECT" --contract "$CONTRACT"
node "$HARNESS/scripts/render_document.ts" --root "$PROJECT" --contract "$CONTRACT" --check
```

Коды: 0 — машинная мера выполнена, 1 — именованное нарушение, 2 — нечем проверить.
--preflight читает draft-критерий, проверяет схему и калибровку: positive принят,
каждый negative конформен и отвергнут своим violation (не синтаксическим отказом).
Калибровка проверяет JSON без требования ещё не написанного Markdown; не требует
готового документа. --check и renderer используют критерий из наибольшей frozen
версии данного номера, не из изменяемого sidecar/рабочей копии. До вызова probe
снимают обязательства, ожидаемые значения, входной пакет и исходные блобы в память.
Check read-only; probe запускается в изоляции, изменение им входов не меняет оракул
и не легализует результат. Сохранность исходного проекта проверяется отдельно.

Устойчивое основание принятия для следующего реестра: frozen-тег и OID блоба
контракта + профиль + пути/OID Markdown и evidence + пути/OID проверенных
источников + reviewer-вердикт с этими идентификаторами. Свободное accepted:true
не заменяет эту связь. Машинный rc=0 ещё не означает содержательное принятие.

## Классы меры и предел честности

1. **Продукт:** точное покрытие ID, структурные исходы и ссылки. Не доказывает
   полезность/реалистичность сценария: cognitive-only, reviewer по обязательству.
2. **Архитектура:** разрешимые концы связей, обязательные решения и отказы.
   Связность не доказывает качество архитектуры: cognitive-only, reviewer.
3. **Происхождение as-is:** разрешимый commit:path/blob, свои evidence и current
   зависимости. Хеш не доказывает логическое следование из исходника: cognitive-only.
4. **Формальные as-is:** зарегистрированные операции/probe, структурное сравнение.
   Не обещает понимания произвольного кода или независимости контрольной модели.
5. **To-be:** отдельный статус и допустимое решение, без выдачи за измерение.
   Желательность/осуществимость — cognitive-only, не новый автоматический балл.
6. **Неопределённости:** все вопросы имеют состояние, блокирующие open не проходят.
   Подлинность воли владельца остаётся существующим когнитивным риском.
7. **Читаемый результат:** генерация, --check, ссылки, целостность пакета.
   Ясность причин/полнота свободного объяснения — cognitive-only, адресный суд.

## Freeze, charter, zones и проводка

Doc-ветвь ready распознаёт тип через общий модуль и требует --preflight вместо
кодовой эвристики «тест отсутствующего документа красен». Freeze повторяет тот же
preflight ДО записи тега, даже при accept критика. Отказ не меняет refs. Старые
кодовые контракты продолжают прежний путь. check_contract_frozen не расширяется
на docs; check_charter защищает критерий как прежде; docs не становятся уставом.

Package-команда `check:document` запускает все прямые red_doc_*; CI запускает её,
мета-ready и scoped antiplacebo новых/изменённых барьеров. Нынешняя
`check:contract-ready` остаётся мета-барьером, не переименовывается в preflight.
После freeze implementer вводит fixtures/check_document/case_*.sh и
fixtures/render_document/case_*.sh с грамматикой раннера: # ПРИЧИНА, $BARRIER,
положительный контроль и повторяемое отрицательное состояние. Общий модуль
doc_contract.ts объявлен НЕ БАРЬЕР (библиотека); CLI с --check несёт коды возврата.
Прямые red_* не выдаются за автоматически подобранные case_*.
Паритет CI проверяется существующим verify_ci_parity: новая check:document
присутствует и в package.json, и в CI, нового исключения не требуется.
Доставка внешнего project-workflow этим контрактом не заявляется: механизм
принимается локальным CLI в dev-harness, внедрение в проект — отдельная работа.

## Мандат семантического суда

Основание изменения судейской роли: слово владельца 2026-09-16
«я согласен с архитектором» по Q1: док-пакет + ОГРАНИЧЕННЫЙ содержательный суд,
носитель — существующий reviewer с расширенным мандатом. Раздел роли
roles/reviewer.md меняется orchestrator ДО открытия её круга по этому предмету,
по правилу 14. Сам architect роль в этой пачке не правит.

Reviewer сверяет product/architecture-результат с конкретными замороженными
обязательствами. Каждый семантический FAIL обязан назвать ID обязательства,
точный фрагмент результата, источник и наблюдаемое противоречие/пропуск.
Стиль, новый сценарий, новый замысел, новая мера после freeze не являются FAIL:
это предложение/вопрос владельцу. Предел кругов и арбитраж остаются существующими.
Вердикт связывается с точными блобами пакета; новая редакция не наследует принятие
старого блоба. Суд не получает права отменять машинный отказ или менять критерий.

## Зоны

ЗОНА architect: contracts/027-doc-priemka.md fixtures/check_check_contract_ready/ fixtures/freeze_contract/ fixtures/check_document/ NABLIUDENIA_ARCHITECT.md
ЗОНА implementer: scripts/doc_contract.ts scripts/check_document.ts scripts/render_document.ts scripts/check_contract_ready.sh scripts/check_check_contract_ready.sh scripts/freeze_contract.sh package.json .github/workflows/ci.yml
ЗОНА orchestrator: AGENTS.md roles/orchestrator.md HANDOFF.md NABLIUDENIA.md
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/

Это ЗОН-макет Frontier с выданным номером/путём. Дополнительная адресная зона
для принятого мандата и doc-профиля (не новые роли/модели):
ЗОНА orchestrator: roles/reviewer.md roles/implementer.md
ЗОНА implementer: fixtures/check_document/ fixtures/render_document/

До freeze architect пишет только в уже разрешённые семьи, не fixtures/check_document/.
После freeze implementer добавляет постоянные case туда как часть реализации.
Правка AGENTS.md не разрешается одним наличием зоны: отдельная строка владельца
при необходимости. Черновик эту строку за владельца не пишет. Автор документа
получает docs-результаты, не критерий/барьер; проверка зон идёт с живой identity.

## Приёмочный критерий

Н-39 дословно: «стабы к ветвям привязывает architect по коду, НЕ проза контракта;
контракт несёт инварианты + rc-команды».

| Инвариант | Прямое предъявление; до реализации rc=1, после rc=0 |
|---|---|
| Непустые обязательства, точное покрытие, структурные ID без дублей | `bash fixtures/check_check_contract_ready/red_doc_obligations.sh` |
| Product: собственные исходы сценария и допустимые открытые вопросы | `bash fixtures/check_check_contract_ready/red_doc_product.sh` |
| Architecture: собственные связи, решения и обязательные отказы | `bash fixtures/check_check_contract_ready/red_doc_architecture.sh` |
| Источники разрешимы, current согласован, evidence принадлежит утверждению | `bash fixtures/check_check_contract_ready/red_doc_evidence.sh` |
| Формальный факт равен мере, rc=2 не выдаётся за успех | `bash fixtures/check_check_contract_ready/red_doc_assertions.sh` |
| As-is/to-be различны, генерируемый Markdown совпадает с фактами | `bash fixtures/check_check_contract_ready/red_doc_status_render.sh` |
| Изменение входов в процессе не меняет оракул, check read-only | `bash fixtures/check_check_contract_ready/red_doc_oracle.sh` |
| Ready/freeze требуют doc-preflight; frozen/charter/zones сохраняются | `bash fixtures/freeze_contract/red_doc_lifecycle.sh` |

Каркас `_doc027.py` создаёт игрушки под literal /tmp, ловит точные rc и сохраняет
ожидания до вызова. Пока CLI отсутствует, субъект — реальный прежний ready:
положительный контроль проходит, отрицательный конформный doc-вход незаконно
принимается. Это измерение отсутствующей проверки поведения, не rc=127.
После появления CLI все пакетные ветви вызывают его. Ни одна последующая ветвь
не засчитывается по первому красному: полная реализация обязана пройти весь файл.
Зелёность последующих ассертов до реализации не заявляется.

После реализации обязательны перечисленные прямые команды rc=0 и:

    npm run check:document                         # rc=0
    npm run check:contract-ready                   # rc=0
    bash scripts/verify_antiplacebo.sh --scope check_document render_document freeze_contract check_check_contract_ready  # rc=0
    npm run check:ci-parity                        # rc=0

## Демаркация и не-цели

Конформный вход соответствует описанной UTF-8/JSON/ID/путевой грамматике и типам
полей. Конформный отрицательный вход нарушает один семантический инвариант,
а не ломает JSON. Валидный контрпример: инвариантность к конкретным значениям/ID
и расхождение на конформном входе при проходящем честном контроле. Битый JSON
судит отдельную ветвь парсера, не считается доказательством против плацебо.

Реализацию предмета выполняет implementer после freeze, не architect этой
черновой пачки. Реестр документов — следующий контракт; project-агенты — отдельный;
Odelix-внедрение и его закрытые материалы вне предмета (только синтетические
Ё/ё-входы). Не входят §10, Н-89, config/agent_models.json, новый docwriter,
универсальный LLM-score, постоянное сопровождение/TTL и автоматическая блокировка
кодовых поставок из-за старого документа.

## Незаполненные требования:

нет
