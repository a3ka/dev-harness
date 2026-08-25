accept

Узкая приёмка исполнения проведена на закоммиченном HEAD `bce7eff` строго в границе
`verdicts/arbitration/contract-011.md:155-162`: только три предписанные механики с красными
фикстурами и три записанных `cognitive-only` остатка. Решённые арбитром классы заново не
открывались.

Подтверждение по (а):

1. `norma`: извлечение раздела ведётся с fence-состоянием
   (`scripts/check_runner_hygiene.sh:368-384`); красная фикстура
   `fixtures/check_runner_hygiene/case_norma_fence_v_arhive.sh:1` предъявила обход
   «архивный code fence + противоположное правило в настоящем разделе» кодом 1 с причиной
   «внутри code fence».
2. `scratchdef` и `scratch`: рекурсивные слепки состава/типа/размера и байтов применяются
   на каждом тике и финально (`scripts/check_runner_hygiene.sh:124-130`,
   `scripts/check_runner_hygiene.sh:249-306`); красная фикстура
   `fixtures/check_runner_hygiene/case_scratchdef_vlozhennyj_katalog.sh:1` предъявила
   фальшивый lock под TMPDIR и работу во вложенном `scripts/run-work.*` с уборкой до выхода
   кодом 1 с причиной «вложенном подкаталоге существующего поддерева».
3. `porjadok`: состав коммита A обязан включать `contracts/010-*.md`, `AGENTS.md` и
   `scripts/verify_antiplacebo.sh`, а `A:AGENTS.md` — маркер нормы
   (`scripts/check_runner_hygiene.sh:438-455`); красная фикстура
   `fixtures/check_runner_hygiene/case_porjadok_pachka_posle_verdikta.sh:1` предъявила
   поздно доехавшие раннер и устав кодом 1 с причиной «пачка доехала после вердикта».

`bash scripts/verify_antiplacebo.sh --scope check_runner_hygiene` на отдельном чистом клоне
завершился кодом 0: 28/28 фикстур предъявлены красными повторным прогоном после зелёного
контроля. `bash scripts/verify_antiplacebo.sh --scope check_zones` завершился кодом 0:
12/12; `git diff --quiet 228ed97 HEAD -- scripts/check_zones.sh fixtures/check_zones/`
также завершился кодом 0 — ветвь и её фикстуры исполнением решения не тронуты.

Прямые повторы обходов арбитра завершились кодом 1 с предписанными именованными причинами:
`norma` — блок только внутри code fence; `scratchdef` и `scratch` — работа во вложенном
подкаталоге существующего поддерева с уборкой; `porjadok` — неполный состав коммита A,
«пачка доехала после вердикта». На текущем дереве `bash scripts/check_runner_hygiene.sh`
завершился ожидаемым кодом 1 с именованной причиной ветви `lock`. Судейский корень с
`contract.md → contracts/011-prijomka-sudi-i-gigiiena-rannera.md` прошёл
`bash scripts/check_contract_ready.sh <корень>`: `OK`, код 0.

Подтверждение по (б): все три предписанных остатка записаны в контракте:

- экзотика Markdown и ловец-судья —
  `contracts/011-prijomka-sudi-i-gigiiena-rannera.md:47-50`;
- наполненная приманка + настоящая работа в третьем месте вне TMPDIR и названные ловцы —
  `contracts/011-prijomka-sudi-i-gigiiena-rannera.md:109-117`;
- семантика содержимого пачки A и названные ловцы —
  `contracts/011-prijomka-sudi-i-gigiiena-rannera.md:85-88`.

Глубина доказательства «фактического scratch», достаточность fence-состояния против экзотики
Markdown и семантика содержимого пачки A оставлены в границе решения
`verdicts/arbitration/contract-011.md:114-153`; это не блокирующие находки. Новых классов
обходов в предписанном узком предмете не найдено. Заморозка `frozen/contracts/011/1`
разрешена.
