# Снимки стандартов владельца, полные тексты 8 гистов и пины репозиториев (контракт 053, Б6(2)/(4)/(5))

<!-- doc:section Обзор -->
## Обзор

Документ закрывает три ответа владельца по блоку Б6 от 2026-09-27 одним doc-пакетом (контракт `contracts/053-snimki-standartov-i-gistov.md`, профиль `architecture`, заморожен `frozen/contracts/053/1`):
**Б6(4)** — побайтовые снимки двух стандартов владельца (`/home/aka/Documents/ARCHITECTURE.md` и `CODING-STANDARDS.md`) со сверенным sha256 в дерево, как вход паков фазы C;
**Б6(5)** — полные тексты 8 гистов tshemsedinov, защита от исчезновения секретных гистов;
**Б6(2)** — пины трёх репозиториев (`metarhia/metaskills`, `mattpocock/skills`, `tshemsedinov/reslop`) по commit sha, норма-факт в принимающем документе.

Съём 2026-09-28 из основного окружения мастерской, источник изменяем и вне git (правило 8 контракта), оракул побайтовости — таблицы ниже, сверка sha256 каждого снимка живой командой `sha256sum`. Все десять файлов снимков — побайтовые копии источников; дрейф источника после съёма не меняет пин (гист пинуется редакцией, репозиторий — commit sha, файлы владельца — sha256 этой таблицы), изменение источника = новый контракт, не тихая переписка. Полнота 8/8: гисты снимаются все восемь из конспектов 048, идентификаторы совпадают с зарегистрированными источниками 048 дословно, девятый гист предметом не является.

<!-- doc:section Стандарты-владельца -->
## Стандарты владельца (побайтовые снимки, sha256 — оракул)

Источник изменяем и вне git; единственный судья побайтовости — sha256 против таблицы этой пачки. Правка снимка = красное Д4/Д5. Двойная мера: копии `/home/aka/Documents/temp/ARCHITECTURE.md` и `/home/aka/Documents/temp/CODING-STANDARDS.md` побайтово идентичны источнику (та же пара sha256). Имена файлов снимков в дереве — ДОСЛОВНО по таблице, не выдумываются.

| Источник (живой путь) | Снимок в дереве | строк | байт | sha256 |
| --- | --- | --- | --- | --- |
| /home/aka/Documents/ARCHITECTURE.md | docs/owner/ARCHITECTURE.md | 1134 | 73603 | c77616e10b33c1b9a6cfd57522705cd834c1de884ea437c1ab23e8e95ab488f3 |
| /home/aka/Documents/CODING-STANDARDS.md | docs/owner/CODING-STANDARDS.md | 1418 | 54011 | 36e3244fdafb907459fdd6a1c19b3d53aa08badd176441b494b77014f0a32bec |

<!-- doc:section Гисты-полные-тексты -->
## Гисты tshemsedinov — полные тексты 8/8 (побайтовые снимки)

API `api.github.com/gists/<id>` живьём: каждый гист `public=false`, ровно один файл (`files=1`), размер API совпадает с размером снятых байтов у всех восьми. Съём по НЕИЗМЕНЯЕМОЙ редакции гиста `/raw/<revision>/<имя-файла>` (не плавающий `/raw`) — редакция = анти-дрейфовый пин по аналогии с commit sha для репозиториев (Б6(2)). Побайтовость съёма проверена самой пачкой: fetch по `<id>/raw` и fetch по `<id>/raw/<revision>/<файл>` дали один sha256 (замер на гисте 13d53d3a…d35). Полнота 8/8: имена файлов снимков — ДОСЛОВНО по таблице, не выдумываются.

| Гист (id, конспект 048) | Редакция (пин) | Файл гиста | байт | sha256 | Снимок в дереве |
| --- | --- | --- | --- | --- | --- |
| 13d53d3a…d35 «Большие задачи» | fad71b19a7669b739842b9b6af6b346572d3b19e | Big-tasks.md | 2887 | cba2ce510768cb78b157663e7252f04884835e1d1a76529bb16a5f505b38bbf7 | docs/owner/gists/13d53d3a62a9f1803f650bbe555c9d35-Big-tasks.md |
| a7c5f677…2ef «Вертикаль/горизонталь» | 850cb070600cd28f055f8726d2c4432964520e34 | Vertical-Horizontal.md | 4096 | af03ff176ba021bd03fe5493869dd9a4bcee2210eb01d4a830e67d59929d4b9a | docs/owner/gists/a7c5f6770b0269c34106fb86ad7402ef-Vertical-Horizontal.md |
| 6ce301f5…014 «AC как контракт» | e2b2b3e527b05981b646c53f7bc6fc4b7f12d299 | Acceptance-criteria.md | 4840 | b9580f40aea4b0d110e3004ef614bc9a1ad6144a2259c41294c3df1e20fbefed | docs/owner/gists/6ce301f58c3a661fc4e304a4c1400014-Acceptance-criteria.md |
| 956420ff…bd6 «ADR» | 53f6e3db33752f410096a995705489976939d074 | 01-ADR.md | 5044 | 1a52e31362a38920f8be5044976fdead7b76c2f58bbd0f5b53fcab78cccb6a86 | docs/owner/gists/956420ff93f738356c66a896df5e1bd6-01-ADR.md |
| b23c72df…304 «Архдокументы» | 5ce6383dbca41f139921c354f91a99b943b73058 | 01-Records.md | 5404 | 5532e09635228a8b1794bf238331ea710575909783caf905e12d9f58edf1eaa0 | docs/owner/gists/b23c72df843a94b896c106b7b4d30304-01-Records.md |
| 7d520fef…63f «NFR» | 196f832ae23c38ecff2fdbc621590c3c73ed5813 | NFR.md | 12603 | 61f67480a585fe202d53970a4433b0db80608a5dda498f61a1ddd547613a182d | docs/owner/gists/7d520fefcd1313847536368ee763263f-NFR.md |
| e741b323…fa6 «Лингвистика» | 506ab5b87fec956306ad4e26f74df0301c7b88fa | Terminology.md | 6119 | 63495382460eb04f5cdb0598f1168d5769c242b649cecf425295f2aadfaae3b7 | docs/owner/gists/e741b3235f1be44221b145e143d4bfa6-Terminology.md |
| 566ff0f0…ab1 «AI и сложность» | 5fcbee9922a8044e20b885bd476bb8648c604db2 | AI-Architecture-Complexity.md | 7791 | 219a7f5005b9fcd369f88e2bea1dd81a50de009a156cb62554480d7913df225f | docs/owner/gists/566ff0f053aeb7713e45022638a65ab1-AI-Architecture-Complexity.md |

<!-- doc:section Пины-репозиториев -->
## Пины репозиториев (по commit sha, норма-факт Б6(2))

Снято живьём командой `git ls-remote <url> HEAD` в день съёма пачки (2026-09-28); достижимость всех трёх репозиториев проверена этой пачкой живьём. Значения ниже НЕ пинуются досрочно — двойной истины нет. Канон-строка пина — ровно три, по одной на каждое из репо ниже; дубль одного репо вместо другого и пропуск репо караются Д7.

```
Пин: metarhia/metaskills → fe4c4230ea054e4b354d9e81400e26299f1be6d7 (снято 2026-09-28)
Пин: mattpocock/skills → c55ee46073ed923f86ce59a5eb3b6d895095d1b7 (снято 2026-09-28)
Пин: tshemsedinov/reslop → 6fc5debee5cf2b3d2a1be35653a4e3002430ff97 (снято 2026-09-28)
```

<!-- doc:section Связь-с-картой-утилизации -->
## Связь с картой утилизации (вход паков фазы C)

Снимки, лежащие в этом дереве — вход паков фазы C; карта утилизации 048 задаёт соответствие источник → артефакт → фаза, и снимки 053 служат материалом, который эти паки потребляют.

- `docs/owner/ARCHITECTURE.md` → architecture pack (C/D): реализует дерево модулей, Bounded Contexts, Implementation Status Matrix (генератор матрицы вместо рукописи); вход `docs/048-priemka-spec-odelix-i-konspektov.md` §«Карта-утилизации» (`ARCHITECTURE.md → architecture pack + генератор Status Matrix → C/D`).
- `docs/owner/CODING-STANDARDS.md` → language-typescript pack (C): FP-first, strict TS, V8-правила, чеклисты по ролям, таблица запрещённых практик; вход `docs/048-priemka-spec-odelix-i-konspektov.md` §«Карта-утилизации» (`CODING-STANDARDS.md → language-typescript pack → C`).
- `docs/owner/gists/<8 файлов>` → паки B/C: гисты «Большие задачи»/«Вертикаль-горизонталь»/«AC»/«AI и сложность» → скиллы и правила architect (B); гисты «ADR»/«Таксономия»/«NFR»/«Лингвистика» → реестр doc-профилей, NFR-раунд frontier, GLOSSARY-шаблон (C); вход `docs/048-priemka-spec-odelix-i-konspektov.md` §«Карта-утилизации» (строки 8 гистов).
- Пины `metarhia/metaskills`, `mattpocock/skills`, `tshemsedinov/reslop` → паки C по слову владельца Б6(2) (metaskills js-conventions/error-handling/npm-publish/data-structures, pocock codebase-design/domain-modeling/tdd/AGENT-BRIEF/OUT-OF-SCOPE, reslop сразу в пилоте A3 и адаптер `.review→TaskPacket` фазы D); вход `docs/048-priemka-spec-odelix-i-konspektov.md` §«Карта-утилизации» (строки metaskills/pocock/reslop).

Все 17 пересечений с чужими зонами (HANDOFF.md, NABLIUDENIA.md, scripts/, fixtures/, пакеты фазы C, ROADMAP.md, AGENTS.md, roles/, registry/, package.json, .github/workflows/ci.yml, docs/spec/) — ответственность соответствующих зон этой пачкой не трогается, записаны в контракте для полноты картины.

<!-- doc:formal:start -->
<!-- doc:formal:end -->
