# Контракт 053 — побайтовые снимки стандартов владельца, полные тексты 8 гистов и пины репозиториев (Б6(2)/(4)/(5))

Черновик. НЕКОДОВЫЙ doc-контракт по профилю 027 (прецеденты 048 и 052). Минт: тег
`id/CONTRACT/053` (tag-object `e9e5beca517f10387ad41285baf10af6d6831860`, `git rev-parse`
живьём) + строка `053 → e9e5bec…` в `registry/contracts.tsv` (origin/main `200df65`;
резерв 023 исполнен до пачки). Заморозка — после круга критика (оркестратор). Работа
ведётся в worktree `/tmp/dev-harness-worktrees/775e24e1/wip-053-architect`, ветка
`wip/053/architect`. Doc-артефакты пишет doc-исполнитель (implementer) отдельной фазой
после freeze — НЕ архитектор этой пачки.

## Предмет

Слово владельца 2026-09-27, блок Б6 — дословно:

> «(4) да — побайтовый снимок моих ARCHITECTURE.md и CODING-STANDARDS.md с sha256 в дерево:
> это вход паков фазы C; (5) да — снять полные тексты 8 гистов (цель A2 — защита от
> исчезновения). (4)+(5) — одним малым doc-контрактом после done 052, не раньше.»

Плюс Б6(2) — дословно: «metaskills/pocock/reslop — пиновать по commit sha (дёшево, против
дрейфа)» — записывается нормой-фактом в принимающий документ, новым механизмом не становится.
Условие «не раньше done 052» исполнено: done/contracts/052/1 → `d76e680`.

Контракт закрывает три вопроса 048 ответами владельца: `Вопрос-снимок-доков-владельца`
(ответ «да»), `Вопрос-снимок-гистов` (ответ «да»), `Вопрос-пин-репозиториев` (ответ
«пиновать по commit sha»). Открытых вопросов не остаётся.

## Снятые источники — живьём этой пачкой (Н-71: замер, не память)

Съём 2026-09-28 из основного окружения мастерской. Оракул побайтовости — ЭТА таблица
(правило 8: источник изменяем и вне git, диск источника истиной не перечитывается).

### Стандарты владельца (2)

| Источник (живой путь) | Снимок в дереве | строк | байт | sha256 |
| /home/aka/Documents/ARCHITECTURE.md | docs/owner/ARCHITECTURE.md | 1134 | 73603 | c77616e10b33c1b9a6cfd57522705cd834c1de884ea437c1ab23e8e95ab488f3 |
| /home/aka/Documents/CODING-STANDARDS.md | docs/owner/CODING-STANDARDS.md | 1418 | 54011 | 36e3244fdafb907459fdd6a1c19b3d53aa08badd176441b494b77014f0a32bec |

Двойная мера: копии `/home/aka/Documents/temp/ARCHITECTURE.md` и
`/home/aka/Documents/temp/CODING-STANDARDS.md` побайтово идентичны (та же пара sha256,
`sha256sum` обеих пар путей живьём) — источник стабилен в двух независимых копиях.

### Гисты tshemsedinov (8, все секретные)

API `api.github.com/gists/<id>` живьём: каждый гист `public=false`, ровно один файл
(`files=1`), размер API совпадает с размером снятых байтов у всех восьми. Съём — по
НЕИЗМЕНЯЕМОЙ редакции гиста (`/raw/<revision>/<имя-файла>`), не по плавающему `/raw`:
редакция гиста — тот же анти-дрейфовый пин, что commit sha для репозиториев (Б6(2)).

| Гист (id, конспект 048) | Редакция (пин) | Файл гиста | байт | sha256 | Снимок в дереве |
| 13d53d3a…d35 «Большие задачи» | fad71b19a7669b739842b9b6af6b346572d3b19e | Big-tasks.md | 2887 | cba2ce510768cb78b157663e7252f04884835e1d1a76529bb16a5f505b38bbf7 | docs/owner/gists/13d53d3a62a9f1803f650bbe555c9d35-Big-tasks.md |
| a7c5f677…2ef «Вертикаль/горизонталь» | 850cb070600cd28f055f8726d2c4432964520e34 | Vertical-Horizontal.md | 4096 | af03ff176ba021bd03fe5493869dd9a4bcee2210eb01d4a830e67d59929d4b9a | docs/owner/gists/a7c5f6770b0269c34106fb86ad7402ef-Vertical-Horizontal.md |
| 6ce301f5…014 «AC как контракт» | e2b2b3e527b05981b646c53f7bc6fc4b7f12d299 | Acceptance-criteria.md | 4840 | b9580f40aea4b0d110e3004ef614bc9a1ad6144a2259c41294c3df1e20fbefed | docs/owner/gists/6ce301f58c3a661fc4e304a4c1400014-Acceptance-criteria.md |
| 956420ff…bd6 «ADR» | 53f6e3db33752f410096a995705489976939d074 | 01-ADR.md | 5044 | 1a52e31362a38920f8be5044976fdead7b76c2f58bbd0f5b53fcab78cccb6a86 | docs/owner/gists/956420ff93f738356c66a896df5e1bd6-01-ADR.md |
| b23c72df…304 «Архдокументы» | 5ce6383dbca41f139921c354f91a99b943b73058 | 01-Records.md | 5404 | 5532e09635228a8b1794bf238331ea710575909783caf905e12d9f58edf1eaa0 | docs/owner/gists/b23c72df843a94b896c106b7b4d30304-01-Records.md |
| 7d520fef…63f «NFR» | 196f832ae23c38ecff2fdbc621590c3c73ed5813 | NFR.md | 12603 | 61f67480a585fe202d53970a4433b0db80608a5dda498f61a1ddd547613a182d | docs/owner/gists/7d520fefcd1313847536368ee763263f-NFR.md |
| e741b323…fa6 «Лингвистика» | 506ab5b87fec956306ad4e26f74df0301c7b88fa | Terminology.md | 6119 | 63495382460eb04f5cdb0598f1168d5769c242b649cecf425295f2aadfaae3b7 | docs/owner/gists/e741b3235f1be44221b145e143d4bfa6-Terminology.md |
| 566ff0f0…ab1 «AI и сложность» | 5fcbee9922a8044e20b885bd476bb8648c604db2 | AI-Architecture-Complexity.md | 7791 | 219a7f5005b9fcd369f88e2bea1dd81a50de009a156cb62554480d7913df225f | docs/owner/gists/566ff0f053aeb7713e45022638a65ab1-AI-Architecture-Complexity.md |

Побайтовость съёма проверена самой пачкой: fetch по `<id>/raw` и fetch по
`<id>/raw/<revision>/<файл>` дали один sha256 (замер на гисте 13d53d3a…d35).

### Пины репозиториев (3, значения — при реализации)

Названы владельцем (Б6(2)); значение снимает doc-исполнитель при реализации живьём
командой `git ls-remote <url> HEAD` и записывает канон-строкой (достижимость всех трёх
проверена этой пачкой живьём, значения НЕ пинуются досрочно — двойной истины нет):

- metaskills — https://github.com/metarhia/metaskills
- pocock-skills — https://github.com/mattpocock/skills
- reslop — https://github.com/tshemsedinov/reslop

Канон-строка пина в принимающем документе (ровно три — по одной на каждое из репо
выше; дубль одного репо вместо другого и пропуск репо караются Д7):

    Пин: metarhia/metaskills → <40-hex> (снято ГГГГ-ММ-ДД)
    Пин: mattpocock/skills → <40-hex> (снято ГГГГ-ММ-ДД)
    Пин: tshemsedinov/reslop → <40-hex> (снято ГГГГ-ММ-ДД)

## Норма побайтовости и дрейфа

1. Побайтовость = снимок есть копия источника без правок: единственный судья — sha256
   против таблиц этой пачки (Д4/Д5). Правка снимка = красное Д4/Д5, «улучшение»
   форматирования источника не существует как операция.
2. Дрейф источника ПОСЛЕ съёма не меняет пин: гист пинуется редакцией, репозиторий —
   commit sha, файлы владельца — sha256 этой таблицы. Изменившийся источник — доклад
   оркестратору и новый снимок новым контрактом, не тихая переписка пина.
3. Полнота 8/8: снимаются все восемь гистов из конспектов 048 (идентификаторы совпадают
   с зарегистрированными источниками 048 дословно); девятый гист предметом не является.

## Док-приёмка

Профиль `architecture` (прецедент 048, решение 1: снимки-источники — компоненты и связи,
product-сценарий с actor/outcomes здесь был бы выдуман). Лестница 052, каждая ступень
живым rc: `node scripts/doc_contract.ts --type` → rc=0 на черновике;
`bash scripts/check_document.sh --preflight` → rc=0 на черновике; `--check` → rc=0 на
HEAD ПОСЛЕ заморозки против пакета evidence (механика loadFrozenSpec, теги
`frozen/contracts/053/*`). Калибровка опущена сознательно (прецедент 052: валидатор 027
считает её необязательной, файлы калибровки вне единственного файла этой пачки — задание
оркестратора: один коммит, только контракт). Остаточный риск: префлайт не доказывает
отвержение битого пакета именно этой спекой; ловец — самотест семьи check_document в CI
(шаг Doc-приёмка) и критик следующего круга.

```json
{
  "type": "documentation",
  "version": 1,
  "profile": "architecture",
  "outputs": {
    "markdown": "docs/053-snimki-standartov-i-gistov.md",
    "evidence": "docs/053-snimki-standartov-i-gistov.evidence.json"
  },
  "required": {
    "sections": ["Обзор", "Стандарты-владельца", "Гисты-полные-тексты", "Пины-репозиториев", "Связь-с-картой-утилизации"],
    "scenarios": [],
    "components": ["Стандарты-владельца", "Гисты-полные-тексты", "Пины-репозиториев", "Дерево-dev-harness"],
    "links": ["Снимки-в-паки-фазы-C", "Гисты-из-конспектов-048", "Пины-по-слову-Б6"],
    "decisions": ["Решение-побайтовость-по-sha256", "Решение-гист-пин-редакции", "Решение-пины-при-реализации"],
    "failures": ["Отказ-дрейф-источника", "Отказ-исчезновение-гиста", "Отказ-правка-снимка"]
  },
  "assertions": [],
  "sources": [
    {"id": "Слово-владельца-Б6", "kind": "external", "address": "urn:dev-harness:owner-word:2026-09-27:block-B6-2-4-5-verbatim", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Доки-ARCHITECTURE", "kind": "external", "address": "file:///home/aka/Documents/ARCHITECTURE.md", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Доки-CODING-STANDARDS", "kind": "external", "address": "file:///home/aka/Documents/CODING-STANDARDS.md", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Гист-большие-задачи", "kind": "external", "address": "https://gist.githubusercontent.com/tshemsedinov/13d53d3a62a9f1803f650bbe555c9d35/raw/fad71b19a7669b739842b9b6af6b346572d3b19e/Big-tasks.md", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Гист-вертикаль-горизонталь", "kind": "external", "address": "https://gist.githubusercontent.com/tshemsedinov/a7c5f6770b0269c34106fb86ad7402ef/raw/850cb070600cd28f055f8726d2c4432964520e34/Vertical-Horizontal.md", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Гист-AC-контракт", "kind": "external", "address": "https://gist.githubusercontent.com/tshemsedinov/6ce301f58c3a661fc4e304a4c1400014/raw/e2b2b3e527b05981b646c53f7bc6fc4b7f12d299/Acceptance-criteria.md", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Гист-ADR", "kind": "external", "address": "https://gist.githubusercontent.com/tshemsedinov/956420ff93f738356c66a896df5e1bd6/raw/53f6e3db33752f410096a995705489976939d074/01-ADR.md", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Гист-архдокументы", "kind": "external", "address": "https://gist.githubusercontent.com/tshemsedinov/b23c72df843a94b896c106b7b4d30304/raw/5ce6383dbca41f139921c354f91a99b943b73058/01-Records.md", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Гист-NFR", "kind": "external", "address": "https://gist.githubusercontent.com/tshemsedinov/7d520fefcd1313847536368ee763263f/raw/196f832ae23c38ecff2fdbc621590c3c73ed5813/NFR.md", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Гист-лингвистика", "kind": "external", "address": "https://gist.githubusercontent.com/tshemsedinov/e741b3235f1be44221b145e143d4bfa6/raw/506ab5b87fec956306ad4e26f74df0301c7b88fa/Terminology.md", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Гист-AI-сложность", "kind": "external", "address": "https://gist.githubusercontent.com/tshemsedinov/566ff0f053aeb7713e45022638a65ab1/raw/5fcbee9922a8044e20b885bd476bb8648c604db2/AI-Architecture-Complexity.md", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Репо-metaskills", "kind": "external", "address": "https://github.com/metarhia/metaskills", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Репо-pocock-skills", "kind": "external", "address": "https://github.com/mattpocock/skills", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Репо-reslop", "kind": "external", "address": "https://github.com/tshemsedinov/reslop", "freshness": "historical", "verification": "cognitive-only"},
    {"id": "Конспекты-048", "kind": "git", "path": "docs/048-priemka-spec-odelix-i-konspektov.md", "commit": "200df6506c2ebe37bf4fbed44e5be63c3c79e326", "blob": "49758bc5ea10026eac713496c73584abd03e3a37", "freshness": "historical"}
  ],
  "questions": []
}
```

## Результат, который пишет doc-исполнитель (после freeze)

Файлы: `docs/053-snimki-standartov-i-gistov.md`,
`docs/053-snimki-standartov-i-gistov.evidence.json`, десять снимков из таблиц выше
(два стандарта + восемь гистов; имена файлов снимков — из таблиц, не выдумываются).
Принимающий документ несёт ровно 5 section-маркеров `required.sections`; в
`Стандарты-владельца` и `Гисты-полные-тексты` — обе таблицы этой пачки (источник →
редакция/путь → байты → sha256 → снимок), все десять sha256 — самостоятельными
токенами, каждый — в одной строке таблицы с путём своего снимка (Д8 сверяет пары
sha256↔снимок против таблиц этой пачки, а не только счёт); в `Пины-репозиториев` —
ровно три канон-строки пина, по одной на каждое репо (Д7), со значениями,
снятыми `git ls-remote <url> HEAD`, и датой съёма; в `Связь-с-картой-утилизации` —
указатели на строки 048 (ARCHITECTURE.md → architecture pack C/D, CODING-STANDARDS.md →
language-typescript pack C, гисты → B/C, metaskills/pocock → C): снимки — вход паков
фазы C. Formal-фрагмент — только генерат `render_document.ts`; evidence повторяет форму
027; `observation-time` — фактическое время наблюдения doc-исполнителя.

## Зоны

ЗОНА architect: contracts/053-snimki-standartov-i-gistov.md

ЗОНА implementer: docs/053-snimki-standartov-i-gistov.md docs/053-snimki-standartov-i-gistov.evidence.json docs/owner/ARCHITECTURE.md docs/owner/CODING-STANDARDS.md docs/owner/gists/13d53d3a62a9f1803f650bbe555c9d35-Big-tasks.md docs/owner/gists/a7c5f6770b0269c34106fb86ad7402ef-Vertical-Horizontal.md docs/owner/gists/6ce301f58c3a661fc4e304a4c1400014-Acceptance-criteria.md docs/owner/gists/956420ff93f738356c66a896df5e1bd6-01-ADR.md docs/owner/gists/b23c72df843a94b896c106b7b4d30304-01-Records.md docs/owner/gists/7d520fefcd1313847536368ee763263f-NFR.md docs/owner/gists/e741b3235f1be44221b145e143d4bfa6-Terminology.md docs/owner/gists/566ff0f053aeb7713e45022638a65ab1-AI-Architecture-Complexity.md

ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: HANDOFF.md NABLIUDENIA.md

Пересечения перечислены ВСЕ живым перечислителем этой пачки (union заморозок
zones_load + перебор каждой чужой записи на путях этой пачки; мера ниже — 17 строк
на 17 чужих записей: HANDOFF.md — architect 002–008/010, NABLIUDENIA.md — architect
002–008/010 и implementer 015; после правки задача (а) гейта 043 зелёная):

ПЕРЕСЕЧЕНИЕ orchestrator: HANDOFF.md — 002 зона эпохи до переворота 010: architect тогда был ведущей сессией и нёс журнал HANDOFF.md своей зоной; с 011 путь — штатная орг-зона orchestrator; 053 пишет только чекпойнт цикла 053, содержимое эпохи 002 не трогает
ПЕРЕСЕЧЕНИЕ orchestrator: HANDOFF.md — 003 та же архитекторская зона до переворота 010 (журнал HANDOFF.md у ведущей сессии); та же причина, что для 002
ПЕРЕСЕЧЕНИЕ orchestrator: HANDOFF.md — 004 та же архитекторская зона до переворота 010 (журнал HANDOFF.md у ведущей сессии); та же причина, что для 002
ПЕРЕСЕЧЕНИЕ orchestrator: HANDOFF.md — 005 та же архитекторская зона до переворота 010 (журнал HANDOFF.md у ведущей сессии); та же причина, что для 002
ПЕРЕСЕЧЕНИЕ orchestrator: HANDOFF.md — 006 та же архитекторская зона до переворота 010 (журнал HANDOFF.md у ведущей сессии); та же причина, что для 002
ПЕРЕСЕЧЕНИЕ orchestrator: HANDOFF.md — 007 та же архитекторская зона до переворота 010 (журнал HANDOFF.md у ведущей сессии); та же причина, что для 002
ПЕРЕСЕЧЕНИЕ orchestrator: HANDOFF.md — 008 та же архитекторская зона до переворота 010 (журнал HANDOFF.md у ведущей сессии); та же причина, что для 002
ПЕРЕСЕЧЕНИЕ orchestrator: HANDOFF.md — 010 архитекторская зона самого переворота 010 (последняя архитекторская заявка журнала); с 011 путь — штатная орг-зона orchestrator; 053 пишет только чекпойнт цикла 053
ПЕРЕСЕЧЕНИЕ orchestrator: NABLIUDENIA.md — 002 зона эпохи до переворота 010: architect тогда был ведущей сессией и нёс журнал наблюдений NABLIUDENIA.md своей зоной; с 011 путь — штатная орг-зона orchestrator; 053 пишет только наблюдения цикла 053, содержимое эпохи 002 не трогает
ПЕРЕСЕЧЕНИЕ orchestrator: NABLIUDENIA.md — 003 та же архитекторская зона до переворота 010 (журнал наблюдений у ведущей сессии); та же причина, что для 002
ПЕРЕСЕЧЕНИЕ orchestrator: NABLIUDENIA.md — 004 та же архитекторская зона до переворота 010 (журнал наблюдений у ведущей сессии); та же причина, что для 002
ПЕРЕСЕЧЕНИЕ orchestrator: NABLIUDENIA.md — 005 та же архитекторская зона до переворота 010 (журнал наблюдений у ведущей сессии); та же причина, что для 002
ПЕРЕСЕЧЕНИЕ orchestrator: NABLIUDENIA.md — 006 та же архитекторская зона до переворота 010 (журнал наблюдений у ведущей сессии); та же причина, что для 002
ПЕРЕСЕЧЕНИЕ orchestrator: NABLIUDENIA.md — 007 та же архитекторская зона до переворота 010 (журнал наблюдений у ведущей сессии); та же причина, что для 002
ПЕРЕСЕЧЕНИЕ orchestrator: NABLIUDENIA.md — 008 та же архитекторская зона до переворота 010 (журнал наблюдений у ведущей сессии); та же причина, что для 002
ПЕРЕСЕЧЕНИЕ orchestrator: NABLIUDENIA.md — 010 архитекторская зона самого переворота 010 (последняя архитекторская заявка журнала наблюдений); с 011 путь — штатная орг-зона orchestrator; 053 пишет только наблюдения цикла 053
ПЕРЕСЕЧЕНИЕ orchestrator: NABLIUDENIA.md — 015 implementer-зона 015 — механизмы ядра наблюдений (scripts/check_nabludenia.sh и семья, Н-записи) с этим путём; 053 механизмы 015 не трогает, запись наблюдений цикла 053 делает orchestrator

РАБОТА НЕ РАЗДАЁТСЯ: scripts/ fixtures/ (механизм 027 не меняется) ROADMAP.md AGENTS.md
roles/ registry/ package.json .github/workflows/ci.yml; паки фазы C (потребители снимков —
будущие контракты фазы C, читают снимки как вход); правка содержания снимков (побайтовость
— суть предмета); перепин спеки docs/spec/ (Б6(1) — не перепиновывается).

## Приёмочный критерий

Н-39 дословно: «стабы к ветвям привязывает architect по коду, НЕ проза контракта; контракт
несёт инварианты + rc-команды». `C=contracts/053-snimki-standartov-i-gistov.md`,
`MD=docs/053-snimki-standartov-i-gistov.md`. ДО — на черновике этой ветки (только контракт,
`docs/owner/` и `MD` отсутствуют); ПОСЛЕ — после doc-исполнителя.

Пробы (живой прогон гейтом 036):

- `bash scripts/check_document.sh --root . --contract contracts/053-snimki-standartov-i-gistov.md --preflight` (зелёная на черновике)
- `bash scripts/check_document.sh --root . --contract contracts/053-snimki-standartov-i-gistov.md --check` → красная: NOT_IMPLEMENTED

```
# Д1 doc-контракт распознан                         ДО rc=0  ПОСЛЕ rc=0
node scripts/doc_contract.ts --type contracts/053-snimki-standartov-i-gistov.md
# Д2 схема спеки зелёная (preflight)                ДО rc=0  ПОСЛЕ rc=0
bash scripts/check_document.sh --root . --contract "$C" --preflight
# Д3 пакет против frozen-критерия                   ДО rc=2  ПОСЛЕ rc=0
bash scripts/check_document.sh --root . --contract "$C" --check
# Д4 два стандарта побайтовы (оракул — таблица)      ДО rc=1  ПОСЛЕ rc=0
printf '%s  %s\n' c77616e10b33c1b9a6cfd57522705cd834c1de884ea437c1ab23e8e95ab488f3 docs/owner/ARCHITECTURE.md 36e3244fdafb907459fdd6a1c19b3d53aa08badd176441b494b77014f0a32bec docs/owner/CODING-STANDARDS.md | sha256sum -c --status
# Д5 восемь гистов побайтовы (оракул — таблица)     ДО rc=1  ПОСЛЕ rc=0
printf '%s  %s\n' cba2ce510768cb78b157663e7252f04884835e1d1a76529bb16a5f505b38bbf7 docs/owner/gists/13d53d3a62a9f1803f650bbe555c9d35-Big-tasks.md af03ff176ba021bd03fe5493869dd9a4bcee2210eb01d4a830e67d59929d4b9a docs/owner/gists/a7c5f6770b0269c34106fb86ad7402ef-Vertical-Horizontal.md b9580f40aea4b0d110e3004ef614bc9a1ad6144a2259c41294c3df1e20fbefed docs/owner/gists/6ce301f58c3a661fc4e304a4c1400014-Acceptance-criteria.md 1a52e31362a38920f8be5044976fdead7b76c2f58bbd0f5b53fcab78cccb6a86 docs/owner/gists/956420ff93f738356c66a896df5e1bd6-01-ADR.md 5532e09635228a8b1794bf238331ea710575909783caf905e12d9f58edf1eaa0 docs/owner/gists/b23c72df843a94b896c106b7b4d30304-01-Records.md 61f67480a585fe202d53970a4433b0db80608a5dda498f61a1ddd547613a182d docs/owner/gists/7d520fefcd1313847536368ee763263f-NFR.md 63495382460eb04f5cdb0598f1168d5769c242b649cecf425295f2aadfaae3b7 docs/owner/gists/e741b3235f1be44221b145e143d4bfa6-Terminology.md 219a7f5005b9fcd369f88e2bea1dd81a50de009a156cb62554480d7913df225f docs/owner/gists/566ff0f053aeb7713e45022638a65ab1-AI-Architecture-Complexity.md | sha256sum -c --status
# Д6 множество снимков гистов ровно 8               ДО rc=1  ПОСЛЕ rc=0
test "$(ls docs/owner/gists/*.md 2>/dev/null | wc -l)" -eq 8
# Д7 пин-состав точный: по одной канон-строке на каждое из трёх репо   ДО rc=1  ПОСЛЕ rc=0
for r in metarhia/metaskills mattpocock/skills tshemsedinov/reslop; do test "$(grep -cE "^Пин: $r → [0-9a-f]{40} \(снято [0-9]{4}-[0-9]{2}-[0-9]{2}\)$" "$MD" 2>/dev/null)" -eq 1 || exit 1; done
# Д8 оракул-таблица в $MD: 10 пар sha256↔снимок в одной строке + 10 разных   ДО rc=1  ПОСЛЕ rc=0
while read -r s p; do grep -F "$s" "$MD" 2>/dev/null | grep -Fq -- "$p" || exit 1; done <<'TBL'
c77616e10b33c1b9a6cfd57522705cd834c1de884ea437c1ab23e8e95ab488f3 docs/owner/ARCHITECTURE.md
36e3244fdafb907459fdd6a1c19b3d53aa08badd176441b494b77014f0a32bec docs/owner/CODING-STANDARDS.md
cba2ce510768cb78b157663e7252f04884835e1d1a76529bb16a5f505b38bbf7 docs/owner/gists/13d53d3a62a9f1803f650bbe555c9d35-Big-tasks.md
af03ff176ba021bd03fe5493869dd9a4bcee2210eb01d4a830e67d59929d4b9a docs/owner/gists/a7c5f6770b0269c34106fb86ad7402ef-Vertical-Horizontal.md
b9580f40aea4b0d110e3004ef614bc9a1ad6144a2259c41294c3df1e20fbefed docs/owner/gists/6ce301f58c3a661fc4e304a4c1400014-Acceptance-criteria.md
1a52e31362a38920f8be5044976fdead7b76c2f58bbd0f5b53fcab78cccb6a86 docs/owner/gists/956420ff93f738356c66a896df5e1bd6-01-ADR.md
5532e09635228a8b1794bf238331ea710575909783caf905e12d9f58edf1eaa0 docs/owner/gists/b23c72df843a94b896c106b7b4d30304-01-Records.md
61f67480a585fe202d53970a4433b0db80608a5dda498f61a1ddd547613a182d docs/owner/gists/7d520fefcd1313847536368ee763263f-NFR.md
63495382460eb04f5cdb0598f1168d5769c242b649cecf425295f2aadfaae3b7 docs/owner/gists/e741b3235f1be44221b145e143d4bfa6-Terminology.md
219a7f5005b9fcd369f88e2bea1dd81a50de009a156cb62554480d7913df225f docs/owner/gists/566ff0f053aeb7713e45022638a65ab1-AI-Architecture-Complexity.md
TBL
test "$(grep -oE '[0-9a-f]{64}' "$MD" 2>/dev/null | sort -u | wc -l)" -eq 10
# Д9 ровно 5 section-маркеров                       ДО rc=1  ПОСЛЕ rc=0
test "$(grep -Ec '^<!-- doc:section [^ ]+ -->$' "$MD" 2>/dev/null)" -eq 5
# Д10 зоны                                          ДО rc=0  ПОСЛЕ rc=0
bash scripts/check_zones.sh .
```

Д3 до freeze — rc=2 `NOT_IMPLEMENTED` (027 отдаёт «нечем проверить» отсутствующему
пакету), не 1. Машинный rc=0 — не содержательное принятие: соответствие снимков
источникам сверх sha256 (например, что секретные гисты не заменены публичными
подделками) — cognitive-only, reviewer (027 §Мандат).

Красные предъявления (подмены; каждая красит СВОЮ ветвь, прогон живьём на копии с
восстановлением): (1) один байт в `docs/owner/CODING-STANDARDS.md` → красна Д4, Д5/Д6
зелёные; (2) седьмой гист заменён байтами шестого под чужим именем → красна Д5; (3)
девятый лишний файл в `docs/owner/gists/` → красна Д6 (счёт 9) при зелёных Д4/Д5;
(4) пин «metaskills → latest» вместо 40-hex → красна Д7; (5) слитые секции принимающего
документа → красна Д9; (6) три копии канон-строки metaskills вместо пинов
pocock-skills и reslop → красна
Д7 (metaskills 3≠1, у двух требуемых репо 0), Д4–Д6/Д8/Д9 зелёные — обход критика
к1 (Б2); (7) sha256 ARCHITECTURE.md в таблице принимающего документа заменён 64
нулями, снимок не тронут → красна Д8 (пара c776…f3 ↔ docs/owner/ARCHITECTURE.md
исчезла из строки таблицы), Д4/Д5 зелёные — обход критика к1 (Б3); (8) дубль одного
sha256 вместо уникального десятого → красна Д8 (совет критика к1).

## ПРОВОДКА

ПРОВОДКА:
- guard=scripts/check_document.sh

ПРОВОДКА-ЭНФОРСМЕНТ: норма контракта — свойство АРТЕФАКТА (пакет `docs/053-*` + десять
снимков `docs/owner/` покрывает замороженный критерий), не поведение роли; исход решает
`check_document.sh --check` против наибольшей frozen-версии 053 и строки Д4–Д9. Пины
репозиториев — норма-факт Б6(2) в принимающем документе, новым механизмом и новой нормой
ролей не становится. Новых ключей CI контракт не вводит: 027 гарантия снимочная.

## Незаполненные требования:
нет
