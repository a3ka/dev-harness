# Контракт 048 — doc-приёмка спеки Odelix v0.2.0 и корпуса конспектов (Фаза A: A1+A2)

Черновик. НЕКОДОВЫЙ doc-контракт: первое боевое применение механизма 027
(`scripts/doc_contract.ts`, `scripts/check_document.ts`, `scripts/render_document.ts`,
doc-preflight в `check_contract_ready.sh`/`freeze_contract.sh`). Номер выдан механизмом:
тег `id/CONTRACT/048` → `347783bf477e8fedc0fc999f509872a00929bf16`. Предмет — дословно
HANDOFF.md «ПРЕДМЕТ А1»/«ПРЕДМЕТ А2» (коммит `f78187b22bf4af01f38de952a575a3d95bcc69e5`,
строки 2468–2649); слово владельца 2026-09-26: исполнять A1+A2 дословно, A3 не начинать.

## Предмет

**А1.** Авторская спека владельца «Универсальный dev-harness поверх OMP» v0.2.0 переезжает
из эфемерного `tmp/` чужого репозитория в `docs/` этого дерева побайтово и принимается как
документ профиля `architecture`. Вход: `/home/aka/Documents/odelixhq/tmp/Odelix-Development-Harness-on-OMP-v0.2.0.md`,
974 строки, sha256 `29b98cd4931e489efabc234ea1c5a13c42e3170c7424e753b421af83f91caa2d`,
git blob `08f375c1e06e9b13705ef34bcc8d8d5415bcfe0d` (снято `wc -l`, `sha256sum`,
`git hash-object` 2026-09-26). Содержание не редактируется: принятие = перенос +
формализация. Все 20 нумерованных разделов спеки — утверждения `to-be` (спека, строка 19:
«Наличие требования в этом документе не означает наличие реализации»).

**А2.** Payload Приложения (HANDOFF.md@`f78187b`, строки 2556–2649, 91 непустая строка;
`cmp` с заданием 048 строки 108–201 — совпадение) переносится в тот же принятый документ
ДОСЛОВНО: 8 конспектов гистов tshemsedinov, конспект доков владельца, конспект reslop,
карта утилизации. Истина после приземления — файл дерева, не гист и не внешний док.

**Named-факт пина (дерево — истина).** Спека пинует основу `fd6c7bc1465ce32895dc61849993fb58f5dbe6fa`
(предок текущего HEAD, `git merge-base --is-ancestor` rc=0). Расхождение двумя мерами:
`git rev-list --count fd6c7bc…..e64803986cb861bbd4b2e9777db1a48032821308` = **1397**,
`..f78187b22bf4af01f38de952a575a3d95bcc69e5` = **1398**; `git log --oneline … | wc -l`
даёт те же 1397/1398. Число 1397 из задания относится к родителю минт-коммита `e648039`,
не к `f78187b` (расхождение на единицу — минт-коммит 048). Документ несёт оба числа с
концами диапазона; «текущий HEAD» без OID не пиннуется — число растёт с историей.

## Решения конструкции

1. **Один контракт, профиль `architecture`** (право выбора дано заданием). А2 — это карта
   «источник → артефакт → фаза» над корпусом, т.е. компоненты и связи; product-сценарий
   с actor/outcomes здесь выдуман бы. Две пары outputs на один перенос — вторая дверь
   без второго предмета.
2. **Три файла результата.** Побайтовая копия спеки отдельно от принимающего документа:
   section-маркеры и formal-фрагмент 027 внутри авторского текста были бы его правкой.
   Копия судится sha256 (Д5), не механизмом 027: её commit-OID до заморозки не существует,
   а git-source 027 требует commit+blob.
3. **As-is — только то, что разрешимо механически сейчас:** пин спеки разрешается в этом
   дереве (commit:path→blob, historical) и Приложение закреплено в git (HANDOFF@`f78187b`).
   Счёт расхождения — не as-is 027 (нет JSON/строки-источника с этим числом, probe лишён
   `.git`), а исполняемые строки Д9/Д10 с фиксированными концами.
4. **Внешние источники** (гисты, доки владельца вне git, публичные репо, исходная спека) —
   `external`, `historical`, `cognitive-only`: checker их не скачивает (027).

## Док-приёмка

```json
{
  "type": "documentation",
  "version": 1,
  "profile": "architecture",
  "outputs": {
    "markdown": "docs/048-priemka-spec-odelix-i-konspektov.md",
    "evidence": "docs/048-priemka-spec-odelix-i-konspektov.evidence.json"
  },
  "required": {
    "sections": [
      "Обзор", "Спека-Odelix-v020",
      "Конспект-большие-задачи", "Конспект-вертикаль-горизонталь", "Конспект-AC-контракт",
      "Конспект-ADR", "Конспект-архдокументы", "Конспект-NFR", "Конспект-лингвистика",
      "Конспект-AI-сложность", "Конспект-доков-владельца", "Конспект-reslop",
      "Карта-утилизации", "Вопросы-владельцу"
    ],
    "scenarios": [],
    "components": ["Спека-Odelix", "Корпус-конспектов", "Карта-утилизации", "Дерево-dev-harness"],
    "links": ["Спека-на-пине", "Карта-из-конспектов", "Карта-из-спеки"],
    "decisions": ["Решение-спека-to-be", "Решение-примат-приложения", "Решение-один-контракт"],
    "failures": ["Отказ-дрейф-пина", "Отказ-исчезновение-источника", "Отказ-искажение-переноса"]
  },
  "assertions": [
    {"id": "Пин-разрешим", "status": "as-is", "kind": "observation", "evidence": "Св-пин-разрешим",
     "check": {"type": "exact-line", "source": "Пин-дерева-fd6c7bc",
               "expected": "# dev-harness — система, которая строит другие системы"}},
    {"id": "Приложение-закреплено", "status": "as-is", "kind": "observation", "evidence": "Св-приложение-закреплено",
     "check": {"type": "exact-line", "source": "HANDOFF-f78187b",
               "expected": "ПРИЛОЖЕНИЕ — ПЕРЕНОСИТСЯ ДОСЛОВНО (payload А2)"}},
    {"id": "Спека-р01", "status": "to-be", "kind": "proposal", "decision": "Решение-спека-to-be", "check": {"type": "decision"}},
    {"id": "Спека-р02", "status": "to-be", "kind": "proposal", "decision": "Решение-спека-to-be", "check": {"type": "decision"}},
    {"id": "Спека-р03", "status": "to-be", "kind": "proposal", "decision": "Решение-спека-to-be", "check": {"type": "decision"}},
    {"id": "Спека-р04", "status": "to-be", "kind": "proposal", "decision": "Решение-спека-to-be", "check": {"type": "decision"}},
    {"id": "Спека-р05", "status": "to-be", "kind": "proposal", "decision": "Решение-спека-to-be", "check": {"type": "decision"}},
    {"id": "Спека-р06", "status": "to-be", "kind": "proposal", "decision": "Решение-спека-to-be", "check": {"type": "decision"}},
    {"id": "Спека-р07", "status": "to-be", "kind": "proposal", "decision": "Решение-спека-to-be", "check": {"type": "decision"}},
    {"id": "Спека-р08", "status": "to-be", "kind": "proposal", "decision": "Решение-спека-to-be", "check": {"type": "decision"}},
    {"id": "Спека-р09", "status": "to-be", "kind": "proposal", "decision": "Решение-спека-to-be", "check": {"type": "decision"}},
    {"id": "Спека-р10", "status": "to-be", "kind": "proposal", "decision": "Решение-спека-to-be", "check": {"type": "decision"}},
    {"id": "Спека-р11", "status": "to-be", "kind": "proposal", "decision": "Решение-спека-to-be", "check": {"type": "decision"}},
    {"id": "Спека-р12", "status": "to-be", "kind": "proposal", "decision": "Решение-спека-to-be", "check": {"type": "decision"}},
    {"id": "Спека-р13", "status": "to-be", "kind": "proposal", "decision": "Решение-спека-to-be", "check": {"type": "decision"}},
    {"id": "Спека-р14", "status": "to-be", "kind": "proposal", "decision": "Решение-спека-to-be", "check": {"type": "decision"}},
    {"id": "Спека-р15", "status": "to-be", "kind": "proposal", "decision": "Решение-спека-to-be", "check": {"type": "decision"}},
    {"id": "Спека-р16", "status": "to-be", "kind": "proposal", "decision": "Решение-спека-to-be", "check": {"type": "decision"}},
    {"id": "Спека-р17", "status": "to-be", "kind": "proposal", "decision": "Решение-спека-to-be", "check": {"type": "decision"}},
    {"id": "Спека-р18", "status": "to-be", "kind": "proposal", "decision": "Решение-спека-to-be", "check": {"type": "decision"}},
    {"id": "Спека-р19", "status": "to-be", "kind": "proposal", "decision": "Решение-спека-to-be", "check": {"type": "decision"}},
    {"id": "Спека-р20", "status": "to-be", "kind": "proposal", "decision": "Решение-спека-to-be", "check": {"type": "decision"}}
  ],
  "sources": [
    {"id": "Пин-дерева-fd6c7bc", "kind": "git", "path": "AGENTS.md",
     "commit": "fd6c7bc1465ce32895dc61849993fb58f5dbe6fa", "blob": "a851b4230a6f5fe71a62e7795afd2b11c875869a",
     "freshness": "historical"},
    {"id": "HANDOFF-f78187b", "kind": "git", "path": "HANDOFF.md",
     "commit": "f78187b22bf4af01f38de952a575a3d95bcc69e5", "blob": "24f8c476e9e09afd7a9a8f0f6c8cc9036b48735b",
     "freshness": "historical"},
    {"id": "Odelix-спека-v020", "kind": "external",
     "address": "file:///home/aka/Documents/odelixhq/tmp/Odelix-Development-Harness-on-OMP-v0.2.0.md",
     "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Слово-владельца-A1A2", "kind": "external",
     "address": "urn:dev-harness:owner-word:2026-09-26:phase-A-A1A2-verbatim",
     "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Гист-большие-задачи", "kind": "external", "address": "https://gist.github.com/tshemsedinov/13d53d3a62a9f1803f650bbe555c9d35", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Гист-вертикаль-горизонталь", "kind": "external", "address": "https://gist.github.com/tshemsedinov/a7c5f6770b0269c34106fb86ad7402ef", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Гист-AC-контракт", "kind": "external", "address": "https://gist.github.com/tshemsedinov/6ce301f58c3a661fc4e304a4c1400014", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Гист-ADR", "kind": "external", "address": "https://gist.github.com/tshemsedinov/956420ff93f738356c66a896df5e1bd6", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Гист-архдокументы", "kind": "external", "address": "https://gist.github.com/tshemsedinov/b23c72df843a94b896c106b7b4d30304", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Гист-NFR", "kind": "external", "address": "https://gist.github.com/tshemsedinov/7d520fefcd1313847536368ee763263f", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Гист-лингвистика", "kind": "external", "address": "https://gist.github.com/tshemsedinov/e741b3235f1be44221b145e143d4bfa6", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Гист-AI-сложность", "kind": "external", "address": "https://gist.github.com/tshemsedinov/566ff0f053aeb7713e45022638a65ab1", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Доки-ARCHITECTURE", "kind": "external", "address": "file:///home/aka/Documents/ARCHITECTURE.md", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Доки-CODING-STANDARDS", "kind": "external", "address": "file:///home/aka/Documents/CODING-STANDARDS.md", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Репо-metaskills", "kind": "external", "address": "https://github.com/metarhia/metaskills", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Репо-pocock-skills", "kind": "external", "address": "https://github.com/mattpocock/skills", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Репо-reslop", "kind": "external", "address": "https://github.com/tshemsedinov/reslop", "freshness": "historical", "verification": "cognitive-only"}
  ],
  "questions": [
    {"id": "Вопрос-пин-спеки", "blocking": false, "allow_open": true},
    {"id": "Вопрос-пин-репозиториев", "blocking": false, "allow_open": true},
    {"id": "Вопрос-профиль-Odelix", "blocking": false, "allow_open": true},
    {"id": "Вопрос-снимок-доков-владельца", "blocking": false, "allow_open": true},
    {"id": "Вопрос-снимок-гистов", "blocking": false, "allow_open": true}
  ],
  "calibration": {
    "positive": "fixtures/check_check_contract_ready/doc_048/kalibrovka-pozitiv.json",
    "negative": [
      {"evidence": "fixtures/check_check_contract_ready/doc_048/kalibrovka-negativ-poterjan-konspekt.json", "violation": "coverage"},
      {"evidence": "fixtures/check_check_contract_ready/doc_048/kalibrovka-negativ-nerazreshimaja-svjaz.json", "violation": "link-resolution"},
      {"evidence": "fixtures/check_check_contract_ready/doc_048/kalibrovka-negativ-as-is-bez-svidetelstva.json", "violation": "evidence-ownership"}
    ]
  }
}
```

## Результат, который пишет implementer (doc-профиль, после freeze)

Файлы: `docs/spec/Odelix-Development-Harness-on-OMP-v0.2.0.md` (побайтовая копия входа А1),
`docs/048-priemka-spec-odelix-i-konspektov.md`, `docs/048-priemka-spec-odelix-i-konspektov.evidence.json`.
Принимающий документ несёт ровно 14 section-маркеров `required.sections`; в `Конспект-*` и
`Карта-утилизации` — строки payload Приложения дословно, включая оба заголовка `## …`
payload; в `Обзор` — самостоятельной строкой named-факт пина:

    Расхождение пина: git rev-list --count fd6c7bc1465ce32895dc61849993fb58f5dbe6fa..e64803986cb861bbd4b2e9777db1a48032821308 = 1397; ..f78187b22bf4af01f38de952a575a3d95bcc69e5 = 1398.

Formal-фрагмент — только генерат `render_document.ts`. Evidence повторяет форму позитива
калибровки; `observation-time` — фактическое время наблюдения implementer'а.

## Вопросы владельцу (не блокируют заморозку; в JSON — `blocking: false`)

1. `Вопрос-пин-спеки`: спека §2 пинует основу на `fd6c7bc` (1397/1398 коммитов назад). Перепин
   — правка авторского текста, это ваш канал; пока as-is о текущем дереве из спеки не выводится.
2. `Вопрос-пин-репозиториев`: metaskills/pocock/reslop приняты ссылкой без commit — пиновать?
3. `Вопрос-профиль-Odelix`: §19 (профиль Odelix) остаётся в документации универсального харнесса
   или уезжает в репозиторий Odelix?
4. `Вопрос-снимок-доков-владельца`: ARCHITECTURE.md/CODING-STANDARDS.md вне git и изменяемы —
   в дереве только конспект; нужен ли побайтовый снимок?
5. `Вопрос-снимок-гистов`: цель А2 — защита от исчезновения секретных гистов, но в дерево ложатся
   конспекты, не полные тексты; снимать ли полные тексты?

Открытый пункт канала владельца (не вопрос и не работа этого контракта): строка-указатель
ROADMAP §8 на принятый документ — оркестратору по слову владельца.

## Зоны

ЗОНА architect: contracts/048-priemka-spec-odelix-i-konspektov.md fixtures/check_check_contract_ready/doc_048/ NABLIUDENIA_ARCHITECT.md
ЗОНА implementer: docs/048-priemka-spec-odelix-i-konspektov.md docs/048-priemka-spec-odelix-i-konspektov.evidence.json docs/spec/Odelix-Development-Harness-on-OMP-v0.2.0.md
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: HANDOFF.md NABLIUDENIA.md

ПЕРЕСЕЧЕНИЕ orchestrator: HANDOFF.md — 002 002 отдал HANDOFF.md architect'у административным каналом (устав/roles/.omp); 048 использует HANDOFF.md обычным оркестраторским каналом чекпойнта «ГДЕ МЫ», не работой 002

ПЕРЕСЕЧЕНИЕ orchestrator: HANDOFF.md — 003 003 отдал HANDOFF.md architect'у административным каналом (устав/roles/.omp); 048 использует HANDOFF.md обычным оркестраторским каналом чекпойнта «ГДЕ МЫ», не работой 003

ПЕРЕСЕЧЕНИЕ orchestrator: HANDOFF.md — 004 004 отдал HANDOFF.md architect'у административным каналом (устав/roles/.omp); 048 использует HANDOFF.md обычным оркестраторским каналом чекпойнта «ГДЕ МЫ», не работой 004

ПЕРЕСЕЧЕНИЕ orchestrator: HANDOFF.md — 005 005 отдал HANDOFF.md architect'у административным каналом (устав/roles/.omp); 048 использует HANDOFF.md обычным оркестраторским каналом чекпойнта «ГДЕ МЫ», не работой 005

ПЕРЕСЕЧЕНИЕ orchestrator: HANDOFF.md — 006 006 отдал HANDOFF.md architect'у административным каналом (устав/roles/.omp); 048 использует HANDOFF.md обычным оркестраторским каналом чекпойнта «ГДЕ МЫ», не работой 006

ПЕРЕСЕЧЕНИЕ orchestrator: HANDOFF.md — 007 007 отдал HANDOFF.md architect'у административным каналом (устав/roles/.omp); 048 использует HANDOFF.md обычным оркестраторским каналом чекпойнта «ГДЕ МЫ», не работой 007

ПЕРЕСЕЧЕНИЕ orchestrator: HANDOFF.md — 008 008 отдал HANDOFF.md architect'у административным каналом (устав/roles/.omp); 048 использует HANDOFF.md обычным оркестраторским каналом чекпойнта «ГДЕ МЫ», не работой 008

ПЕРЕСЕЧЕНИЕ orchestrator: HANDOFF.md — 010 010 отдал HANDOFF.md architect'у административным каналом (устав/roles/.omp); 048 использует HANDOFF.md обычным оркестраторским каналом чекпойнта «ГДЕ МЫ», не работой 010

ПЕРЕСЕЧЕНИЕ orchestrator: NABLIUDENIA.md — 002 та же административная зона 002 (architect); 048 пишет NABLIUDENIA.md обычным оркестраторским наблюдением, не работой 002

ПЕРЕСЕЧЕНИЕ orchestrator: NABLIUDENIA.md — 003 та же административная зона 003 (architect); 048 пишет NABLIUDENIA.md обычным оркестраторским наблюдением, не работой 003

ПЕРЕСЕЧЕНИЕ orchestrator: NABLIUDENIA.md — 004 та же административная зона 004 (architect); 048 пишет NABLIUDENIA.md обычным оркестраторским наблюдением, не работой 004

ПЕРЕСЕЧЕНИЕ orchestrator: NABLIUDENIA.md — 005 та же административная зона 005 (architect); 048 пишет NABLIUDENIA.md обычным оркестраторским наблюдением, не работой 005

ПЕРЕСЕЧЕНИЕ orchestrator: NABLIUDENIA.md — 006 та же административная зона 006 (architect); 048 пишет NABLIUDENIA.md обычным оркестраторским наблюдением, не работой 006

ПЕРЕСЕЧЕНИЕ orchestrator: NABLIUDENIA.md — 007 та же административная зона 007 (architect); 048 пишет NABLIUDENIA.md обычным оркестраторским наблюдением, не работой 007

ПЕРЕСЕЧЕНИЕ orchestrator: NABLIUDENIA.md — 008 та же административная зона 008 (architect); 048 пишет NABLIUDENIA.md обычным оркестраторским наблюдением, не работой 008

ПЕРЕСЕЧЕНИЕ orchestrator: NABLIUDENIA.md — 010 та же административная зона 010 (architect); 048 пишет NABLIUDENIA.md обычным оркестраторским наблюдением, не работой 010

ПЕРЕСЕЧЕНИЕ orchestrator: NABLIUDENIA.md — 015 015 отдал NABLIUDENIA*.md implementer'у ТОЛЬКО миграционной пачкой заголовков (уже исполнена и закрыта); 048 пишет NABLIUDENIA.md обычным оркестраторским наблюдением, не работой 015

ПЕРЕСЕЧЕНИЕ architect: NABLIUDENIA_ARCHITECT.md — 015 015 отдал NABLIUDENIA*.md implementer'у ТОЛЬКО миграционной пачкой заголовков (уже исполнена и закрыта); 048 architect пишет NABLIUDENIA_ARCHITECT.md обычным операционным наблюдением, не работой 015


Калибровка — часть критерия: freeze повторяет preflight до тега, поэтому позитив и три
негатива пишет architect до заморозки (`fixtures/check_check_contract_ready/doc_048/` — существующая frozen-зона architect 036, не новая семья), а не
implementer после — отступление от шаблона задания, вынужденное порядком 027.

РАБОТА НЕ РАЗДАЁТСЯ: scripts/ (механизм 027 не меняется) fixtures/check_document/
fixtures/render_document/ (семьи 027) ROADMAP.md (строка §8 — канал владельца) AGENTS.md
roles/ registry/contracts.tsv package.json .github/workflows/ci.yml; фазы B–E, адаптер
reslop, A3; содержание спеки Odelix.

## Приёмочный критерий

Н-39 дословно: «стабы к ветвям привязывает architect по коду, НЕ проза контракта; контракт
несёт инварианты + rc-команды». `C=contracts/048-priemka-spec-odelix-i-konspektov.md`,
`MD=docs/048-priemka-spec-odelix-i-konspektov.md`. ДО — на красном коммите этой ветки (контракт
+ калибровка, `docs/` нет); ПОСЛЕ — после implementer. Негативы судятся Д1: preflight отказывает,
если хоть один негатив принят.

    # Д1 схема + калибровка (позитив принят, 3 негатива отвергнуты)   ДО rc=0  ПОСЛЕ rc=0
    bash scripts/check_document.sh --root . --contract "$C" --preflight
    # Д2 пакет против frozen-критерия; повторный прогон тот же           ДО rc=2  ПОСЛЕ rc=0
    bash scripts/check_document.sh --root . --contract "$C" --check
    # Д3 formal-фрагмент — генерат                                        ДО rc=2  ПОСЛЕ rc=0
    node scripts/render_document.ts --root . --contract "$C" --check
    # Д5 копия спеки побайтова                                            ДО rc=1  ПОСЛЕ rc=0
    printf '%s  %s\n' 29b98cd4931e489efabc234ea1c5a13c42e3170c7424e753b421af83f91caa2d docs/spec/Odelix-Development-Harness-on-OMP-v0.2.0.md | sha256sum -c --status
    # Д6 каждая из 91 непустой строки payload — самостоятельной строкой   ДО rc=1  ПОСЛЕ rc=0
    test -f "$MD" && ! { git show f78187b22bf4af01f38de952a575a3d95bcc69e5:HANDOFF.md | sed -n '2556,2649p' | grep -v '^$' | grep -Fxv -f "$MD"; }
    # Д7 ровно 14 section-маркеров                                        ДО rc=1  ПОСЛЕ rc=0
    test "$(grep -Ec '^<!-- doc:section [^ ]+ -->$' "$MD" 2>/dev/null)" = 14
    # Д8 ровно 8 конспектов гистов                                        ДО rc=1  ПОСЛЕ rc=0
    test "$(grep -c '^- «' "$MD" 2>/dev/null)" = 8
    # Д9 расхождение пина — инвариант истории                             ДО rc=0  ПОСЛЕ rc=0
    test "$(git rev-list --count fd6c7bc1465ce32895dc61849993fb58f5dbe6fa..e64803986cb861bbd4b2e9777db1a48032821308)" = 1397 && test "$(git rev-list --count fd6c7bc1465ce32895dc61849993fb58f5dbe6fa..f78187b22bf4af01f38de952a575a3d95bcc69e5)" = 1398
    # Д10 named-факт пина в документе                                     ДО rc=1  ПОСЛЕ rc=0
    test -f "$MD" && grep -Fxq 'Расхождение пина: git rev-list --count fd6c7bc1465ce32895dc61849993fb58f5dbe6fa..e64803986cb861bbd4b2e9777db1a48032821308 = 1397; ..f78187b22bf4af01f38de952a575a3d95bcc69e5 = 1398.' "$MD"
    # Д11 зоны                                                            ДО rc=0  ПОСЛЕ rc=0
    bash scripts/check_zones.sh .

Д2 между freeze и implementer — rc=2 (`NOT_IMPLEMENTED: путь не читается`), не 1: 027 отдаёт
«нечем проверить» отсутствующему evidence. Машинный rc=0 — не содержательное принятие:
соответствие конспектов источникам и полнота карты — cognitive-only, reviewer (027 §Мандат).

## ПРОВОДКА

ПРОВОДКА:
- guard=scripts/check_document.sh

ПРОВОДКА-ЭНФОРСМЕНТ: норма контракта — свойство АРТЕФАКТА (пакет `docs/048-*` покрывает
замороженный критерий), не поведение роли; исход решает `check_document.sh --check` против
наибольшей frozen-версии 048 и строки Д5–Д10. Новых ключей CI контракт не вводит: 027 гарантия
снимочная, current-обязательство выбирает потребляющий контракт (027 §Предмет, Q7).

## Риски (named residual)

1. CI не прогоняет `--check` пакета 048 — снимочная гарантия 027; дрейф `docs/048-*` после
   done ловится только повторным ручным прогоном Д2/Д5/Д6.
2. Д6 проверяет наличие каждой строки payload, не их порядок; порядок — reviewer.
3. Дословность конспектов первоисточникам не проверяется: payload авторитетен по слову владельца.

## Незаполненные требования:
нет
