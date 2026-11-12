FAIL
OBJECT=5810f78458d9d6b80f5dcac4db85cf0af696ddef
КЛАСС=doc/role с красной батареей; риск обычный (не повышаю: правка — текст инструкций процесса, прав/данных/денег не касается)
СУД: repo=dev-harness; предмет=192; фаза=реализация; роль=reviewer; вызов=1/1; модель-план=anthropic/claude-opus-5-5; сессия=Rev192v1; модель-факт=anthropic/claude-opus-5-5; SHA=5810f78458d9d6b80f5dcac4db85cf0af696ddef; предыдущий=verdicts/critic/contracts-192-v1.md (accept, вызов 3/3, PR #913); исключение=нет

# Ревью реализации 192 «нормы ролей связки», вызов 1/1

Кандидат: `wip/192/implementer` @ `5810f784` (один коммит `implementer <implementer@dev-harness.local>`, родитель —
`origin/main` `0814d2f5`). Контракт — блоб `b1a5b57d` (`frozen/contracts/192/1^{commit}` = `0f605285`, тег локален
на станции); блоб на `origin/wip/192/architect` (`93ee9b98`) тот же `b1a5b57d`; дерево семьи
`fixtures/workshop_project/normy_roley_svyazki_192/` у тега и у ветки architect одно — `8bfa0e5f`.
Батарея и контракт наложены на дерево кандидата одноразово, без коммита (`git checkout origin/wip/192/architect -- …`).

Итог: тексты норм внесены верно и полно — побайтово по `drafts/`, ни одной потерянной чужой нормы, батарея и двери
зелёные моей мерой. Отказ — одной причиной порядка: кандидат построен на `main` БЕЗ 188 при открытом #771, вопреки
И7/ПРЕДПОСЫЛКАМ и слову владельца. Содержание 192-ханков к правке не требуется.

## Блок

**Б-1 (И7 + ПРЕДПОСЫЛКИ; класс: К-03 чужие frozen-обязательства / порядок предметов).**
- Обязательство: И7 «реализация после влития 188 (#771); нормы 188 и раздел `## Архитектура 188` не меняются»;
  ПРЕДПОСЫЛКИ «вливание 188 (PR #771) публикуется до реализации 192»; КОНТЕКСТ — слово владельца 2026-11-11 ~22:20
  «реализация и вливание — ТОЛЬКО после вливания 188 (#771)»; `docs/owner/2026-11-10-plan-i-pravila-arhitektury.md:16`
  «192 … после влития 188».
- Наблюдение: родитель кандидата `0814d2f5` = `origin/main`; `gh pr view 771` → `"state":"OPEN","mergedAt":null`;
  `grep -c 'Архитектура 188' roles/*.md` на кандидате — 0 во всех ролях, кроме `roles/critic.md:292`, где это
  ССЫЛКА строки класса `К-17 архитектура: шестой вопрос раздела ## Архитектура 188` — на дереве кандидата раздела,
  на который она указывает, нет ни в одной роли (класс К-17 карты классов критика висит в пустоту).
- Достижимое состояние: слияние этого OBJECT кладёт 192 в `main` раньше 188 — порядок, запрещённый владельцем; затем
  #771 конфликтует с ним: `git merge-tree --write-tree pr771 5810f784` → CONFLICT (content) в `roles/{adversary,arbiter,
  critic,orchestrator,reviewer}.md` и `.omp/agents/{adversary,arbiter,critic,orchestrator,reviewer}.md` (10 файлов зоны
  implementer 192; плюс `ci.yml`/`registry/ci-steps.tsv` — конфликт самого #771 с `main`, не 192).
  И5 на живом дереве («`check_ceilings.sh .` после #771+192») на этом OBJECT не наблюдаем — 188 в дереве нет.
- Закрывающее свойство: кандидат, чья история содержит влитый #771; 192-ханки равны ханкам этого OBJECT (своя мера —
  `recon.py` ниже: дельта к `main` = ровно `drafts/edits/*.old→*.new` + разделы `drafts/*`, удалённых строк вне `.old` — 0),
  разделы 192 добавлены ПОСЛЕ разделов 188 без правки `## Архитектура 188`; `.omp/agents` перегенерированы
  (`npm run check:gen` rc 0); `red_normy_roley_svyazki_192.sh` bare и `--repo .` → rc 0 `CELLS=46 GREEN=46`;
  `bash scripts/check_ceilings.sh .` rc 0 на дереве 188+192. Повтор ревьюера — scoped: разрешение конфликтов,
  потолки на живом дереве, К-17 указывает на существующий раздел; остальное этим вердиктом проверено и не
  пересуждается (§Быстрый-процесс §Реализация).
- Оценка потолка той же мерой заранее (не замена И5): размер роли на OBJECT + дельта 188 (`pr771` против
  merge-base `2c50cbee`): architect 54432, critic 48103, orchestrator 68470, arbiter 10385, adversary 9281,
  reviewer 17033, critic-sol 20847 — максимум 68470 < 73728.

## Перепроверка по заданию (сырой вывод — ниже)

1. **Область.** `git diff --stat origin/main...5810f784` — 14 путей, ровно ЗОНА implementer контракта (7 `roles/*` +
   7 `.omp/agents/*`, `implementer.md` не тронут), `218 insertions(+), 28 deletions(-)`. Уставных путей
   (AGENTS.md/ROADMAP/plans/contracts) в дельте 0; `check_charter.sh .` rc 0. Коммит один, ссылается на предмет 192.
   Удалённые строки `roles/`: 14, своей мерой (`recon.py`: применяю к `origin/main` каждую `drafts/edits/*.old→.new`,
   каждая `.old` найдена ровно 1 раз; остаток диффа — только добавления, равные `drafts/critic_section.md`,
   `architect_section.md`, `others_sections.md`) — каждая удалённая строка входит в одну из семи заявленных
   `.old`; иных удалений 0. Чужие нормы: `check_provodka.sh` по всем 42 контрактам с role-каналом в этих семи ролях —
   rc на `origin/main` и на OBJECT совпадает у всех 42 (`RC_DIFF=0`; три исходно красных — 061, 095, 188 — красны и
   до правки); удалённые формулировки старого порядка не являются литералом ни одного контракта/фикстуры дерева
   (grep по `contracts/ roles/ AGENTS.md scripts/ fixtures/ .omp/` вне семьи 192 — 0). `check_zones.sh .` — см. сырой вывод.
2. **Сырой вывод.** bare / `--repo .` rc 0 `CELLS=46 GREEN=46`; `--model` rc 0 `AGENTS_PARITY=ok`
   `CEILINGS=7 MAX=68755 LIMIT=73728` `CELLS=53 GREEN=53 RED_NEGATIVES=67/67`; `--stabs` rc 0 `STABS=18 CAUGHT=18`;
   `--repo /nonexistent-root-192` rc 1 `CELLS=46 GREEN=12`; PATH без node — все четыре входа rc 2
   `NOT_IMPLEMENTED: node недоступен`; `npm run check:gen` rc 0; `check_ceilings.sh .` rc 0; `pre_critic` rc 0;
   `check_threat_model` rc 0; `check_precision_gate` rc 0. Красное предъявлено: тот же bare на `origin/main` (с
   наложенной семьёй) — rc 1 `CELLS=46 GREEN=8` (38 красных: 12 норм, 17 классов, critic-sol, 8 клеток капа).
   `check_provodka.sh . contracts/192-…` rc 1 одной причиной «guard не подключён»: с временной (не коммиченной)
   строкой вызова guard в `ci.yml` — rc 0, то есть все 12 role-каналов г4 сходятся; подключение — зона orchestrator.
3. **Неподгонка.** Коммит implementer не трогает `fixtures/ contracts/ scripts/` (`git log origin/main..5810f784 --
   fixtures/ contracts/ scripts/` пуст); литералы клеток — `norms.tsv` architect (дерево семьи = тег); своя мера
   `count.py` (не probe.py): каждый из 12 литералов — 1 раз в своей роли, 1 раз самостоятельной строкой, 1 пара
   маркер→литерал, 0 в чужих ролях, 1 раз в своём `.omp/agents`; строк `- К-NN` в critic 17 (К-01…К-17 по порядку),
   полных строк класса в шести других ролях 0.
4. **Нормы по существу.** Кап §Остановка («три critic-вызова → один арбитраж о конечной границе → один узкий
   вызов», «согласен автор или спорит») совпадает с AGENTS.md §«Арбитр — когда и зачем» (#834); формулировок
   старого порядка (пять / ветка согласия / исправительный по согласию / только при названном споре) нет ни в
   одной из семи ролей и в AGENTS.md (grep — 0). `roles/orchestrator.md:219-220` §«Исправительный вызов по твоей
   санкции» отсылает к `critic.md §Остановка` как к единому источнику — конфликта нет. Замечания по тексту — советы ниже.
5. **Гейты** `pre_critic`/`check_threat_model`/`check_precision_gate` — rc 0 каждый.
6. **Шестой вопрос (архитектура).** Дифф — только текст ролей и их генерация; новой механики, модулей, состояния
   нет; форма повторяет живой шаблон дерева (раздел с `Норма-строка (ПРОВОДКА …):` по 038, производные через
   `gen-harness.ts`). Сам «шестой вопрос раздела `## Архитектура 188`», на который ссылается К-17, в дереве кандидата
   отсутствует — это Б-1.

СВЕРКА-СТАНДАРТОВ: н/п — `AGENTS.md` dev-harness не объявляет документ архитектуры и стандарт кода
(`grep -n 'ARCHITECTURE.md\|CODING-STANDARDS' AGENTS.md` — 0; `docs/` таких файлов не несёт).

## ОСТАТОК (НЕ ЗАЩИЩАЕТ с ловцом reviewer)

- ОСТАТОК: класс контрактом не назначен (невидимые символы в якорях старого порядка, ловец «дельта-разбор ревьюера») —
  не укусил: в добавленных строках диффа символов категорий Cf/Mn/Me/Co/Cs и не-ASCII пробелов 0 (`count.py`);
  удалённые строки побайтово равны `drafts/edits/*.old`, добавленные — `*.new`/разделам (`recon.py`).
- ОСТАТОК: класс контрактом не назначен (подмена семьи вместе с ролями, ловцы critic и reviewer) — не укусил:
  коммит implementer семью не трогает; дерево семьи у тега и у ветки architect одно (`8bfa0e5f`).

## ПРОВОДКА (038)

Каналы существуют: guard `fixtures/workshop_project/normy_roley_svyazki_192/red_normy_roley_svyazki_192.sh` — барьер
именно этого предмета (своя семья, клетки по 12 нормам/17 классам/капу); `guard=scripts/check_ceilings.sh` — rc 0;
12 role-каналов — в ролях дословно (г4 зелёный при временной проводке). Не подключён guard в CI — зона orchestrator
после суда (окно freeze..done), не находка этого кандидата. ПРОВОДКА-ЭНФОРСМЕНТ честен: поведение названо
cognitive-only, ловцы — 193 (`check_sdacha.sh`, в дереве ещё нет — названо в НЕ ЗАЩИЩАЕТ) и С16 (190).

## Паразитная сложность (050)

- 12 норм-строк в семи ролях (+ разделы-носители): (1) И1, ПРОВОДКА 192/1; (2) нового состояния нет — текст;
  (3) при правке нормы меняются роль + её `.omp/agents` (связка генерации существовала до диффа, не выросла);
  (4) интерфейса нет; (5) потребители — клетки батареи и г4 `check_provodka`. ESSENTIAL.
- Список К-01…К-17 в `roles/critic.md`: (1) И2; (2) нет; (3) один файл — единый источник, остальные ссылаются;
  (4) н/п; (5) клетки `klass-к-NN`, `istochnik`. ESSENTIAL.
- 7 правок абзацев (critic 3, architect 4): (1) И3/И4; (2) нет; (3) роль + агент; (4) н/п; (5) клетки kap-*/net-*,
  starshij-poryadok. ESSENTIAL.
- 7 перегенерированных `.omp/agents/*`: (1) И6; (2) нет; (3) генерация; (4) н/п; (5) `check:gen`, `repo/agents-parity`.
  ESSENTIAL.

## Советы (не блокируют; тексты заморожены в `drafts/` — вопрос владельцу/architect на v+1, не implementer)

- С-1. `roles/critic.md` §«Второй FAIL» (голова, `drafts/edits/critic-vtorojfail-golova.new`): «бюджет … (один полный
  вызов и не более одного исправительного); его исчерпание с FAIL решает арбитраж о конечной границе» — читается
  как арбитраж после ВТОРОГО вызова, тогда как §Остановка — третий вызов по санкции, затем арбитраж; хвост того же
  раздела отсылает к §Остановка. Плюс §Остановка не называет путь, если третий вызов НЕ санкционирован (дельта-лист
  не закрыл блоки способами снятие/граница/канон). Мера, которой не было на freeze, — не FAIL.
- С-2. `roles/critic.md` §Счёт: шаблон `вызов=N/2` при капе три — прежняя строка вне `drafts/`, не в предмете 192.
- С-3. `roles/orchestrator.md:219` заголовок «(слово владельца 2026-11-01, порог арбитра поднят)» — метка старого
  порядка; тело отсылает к единому источнику, смысл не расходится.
- С-4 (зона architect). `--repo /nonexistent-root-192` → `GREEN=12`: зелёные там только клетки отсутствия и
  `repo/agents-parity` — соответствует замороженной приёмке, но parity на несуществующем корне зелёная.

## Сырой вывод

(вставлен ниже из прогонов этого вызова; команды запускались в `/tmp/dev-harness-verify/Rev192v1/{impl,main,repo}`)

```
$ git rev-parse origin/wip/192/implementer origin/wip/192/architect origin/main
5810f78458d9d6b80f5dcac4db85cf0af696ddef
93ee9b980fb0f9039c666225232ac665473604e4
0814d2f5a8980e6e8331f06b8e22911e5f57eade
$ git merge-base origin/main origin/wip/192/implementer
0814d2f5a8980e6e8331f06b8e22911e5f57eade
$ git -C /home/harness/dev-harness rev-parse 'frozen/contracts/192/1^{commit}' 'frozen/contracts/192/1^{commit}:contracts/192-normy-roley-svyazki.md'; git rev-parse origin/wip/192/architect:contracts/192-normy-roley-svyazki.md
0f6052851131bddc4b51a128caa74af2495eb196
b1a5b57d522dc35657fd166fe8a25a8263d2910d
b1a5b57d522dc35657fd166fe8a25a8263d2910d
$ git rev-parse 'frozen/contracts/192/1^{commit}:fixtures/workshop_project/normy_roley_svyazki_192' origin/wip/192/architect:fixtures/workshop_project/normy_roley_svyazki_192
8bfa0e5f0ca72e1ede970dbb1aba9eee864e9a88
8bfa0e5f0ca72e1ede970dbb1aba9eee864e9a88
$ git diff --stat origin/main...5810f78458
 .omp/agents/adversary.md    |  6 ++++++
 .omp/agents/arbiter.md      |  6 ++++++
 .omp/agents/architect.md    | 48 ++++++++++++++++++++++++++++++++++++-------
 .omp/agents/critic-sol.md   |  1 +
 .omp/agents/critic.md       | 50 ++++++++++++++++++++++++++++++++++++++-------
 .omp/agents/orchestrator.md |  6 ++++++
 .omp/agents/reviewer.md     |  6 ++++++
 roles/adversary.md          |  6 ++++++
 roles/arbiter.md            |  6 ++++++
 roles/architect.md          | 48 ++++++++++++++++++++++++++++++++++++-------
 roles/critic-sol.md         |  1 +
 roles/critic.md             | 50 ++++++++++++++++++++++++++++++++++++++-------
 roles/orchestrator.md       |  6 ++++++
 roles/reviewer.md           |  6 ++++++
 14 files changed, 218 insertions(+), 28 deletions(-)
$ (ЗОНА implementer из блоба тега) | comm -3 (diff --name-only)   → zone=14, symmetric-diff=0
$ git log --oneline origin/main..origin/wip/192/implementer
5810f784 implementer: 192 — нормы связки architect↔критик в семи ролях
$ git log --format='%h %an' origin/main..5810f78458 -- fixtures/ contracts/ scripts/
(пусто)

$ gh pr view 771 -R a3ka/dev-harness --json state,mergedAt,title,headRefName
{"headRefName":"wip/188/orchestrator","mergedAt":null,"state":"OPEN","title":"188: нормы ролей по архитектуре (реализация) + проводка CI + регенерация .omp/agents"}
$ grep -c 'Архитектура 188' roles/*.md   (дерево кандидата)
roles/adversary.md:0 roles/arbiter.md:0 roles/architect.md:0 roles/critic-sol.md:0 roles/critic.md:1 roles/orchestrator.md:0 roles/reviewer.md:0 (прочие роли 0)
roles/critic.md:292:- К-17 архитектура: шестой вопрос раздела `## Архитектура 188`.
$ git fetch origin pull/771/head:pr771 → 0b5a387d266e30acbf448f99194df7c77e302497
$ git merge-tree --write-tree --name-only pr771 5810f78458   (rc 1)
CONFLICT (content): Merge conflict in .github/workflows/ci.yml
CONFLICT (content): Merge conflict in .omp/agents/adversary.md
CONFLICT (content): Merge conflict in .omp/agents/arbiter.md
CONFLICT (content): Merge conflict in .omp/agents/critic.md
CONFLICT (content): Merge conflict in .omp/agents/orchestrator.md
CONFLICT (content): Merge conflict in .omp/agents/reviewer.md
CONFLICT (content): Merge conflict in registry/ci-steps.tsv
(по --name-only также roles/{adversary,arbiter,critic,orchestrator,reviewer}.md, registry/ci-zamery.tsv)
$ (размер на OBJECT + дельта 188 от merge-base 2c50cbee)
architect obj=53506 d188=926 est188+192=54432 limit=73728
critic obj=47126 d188=977 est188+192=48103 limit=73728
orchestrator obj=66821 d188=1649 est188+192=68470 limit=73728
arbiter obj=9902 d188=483 est188+192=10385 limit=73728
adversary obj=8354 d188=927 est188+192=9281 limit=73728
reviewer obj=16101 d188=932 est188+192=17033 limit=73728
critic-sol obj=20847 d188=0 est188+192=20847 limit=73728

$ python3 recon.py <repo> <drafts> 5810f784   (своя мера: main + drafts → сравнение с OBJECT)
critic: edit critic-ostanovka: occurrences of .old in main = 1
critic: edit critic-vtorojfail-golova: occurrences of .old in main = 1
critic: edit critic-vtorojfail-tail: occurrences of .old in main = 1
critic: removed-after-edits=0 added-nonblank=28 draft-nonblank=28 additions==draft:True
architect: edit architect-startup: occurrences of .old in main = 1
architect: edit architect-barer: occurrences of .old in main = 1
architect: edit architect-otvet: occurrences of .old in main = 1
architect: edit architect-byudzhet: occurrences of .old in main = 1
architect: removed-after-edits=0 added-nonblank=14 draft-nonblank=14 additions==draft:True
orchestrator: removed-after-edits=0 added-nonblank=3 draft-nonblank=3 additions==draft:True
arbiter: removed-after-edits=0 added-nonblank=3 draft-nonblank=3 additions==draft:True
adversary: removed-after-edits=0 added-nonblank=3 draft-nonblank=3 additions==draft:True
reviewer: removed-after-edits=0 added-nonblank=3 draft-nonblank=3 additions==draft:True
critic-sol: removed-after-edits=0 added-nonblank=1 draft-nonblank=2 additions==draft:False
   DIFF: -## Быстрый-процесс
RECON_MISMATCH  (rc 1)
→ единственное расхождение — артефакт моего разборщика: заголовок others_sections для critic-sol — «одна строка в
  `## Быстрый-процесс`» (не новый раздел), строка вставлена в существующий раздел: roles/critic-sol.md:18 «## Быстрый-процесс»,
  :23 «Связка с автором — `roles/critic.md §Связка с автором`: карта классов, суд дельта-листа, граница.»

$ python3 count.py <repo> 5810f784 norms.tsv   (своя мера: литералы/классы/невидимые символы)
critic/karta: own=1 own-line=1 pair=1 foreign=0 agent=1 OK
critic/delta: own=1 own-line=1 pair=1 foreign=0 agent=1 OK
critic/granica: own=1 own-line=1 pair=1 foreign=0 agent=1 OK
architect/sdacha: own=1 own-line=1 pair=1 foreign=0 agent=1 OK
architect/sposoby: own=1 own-line=1 pair=1 foreign=0 agent=1 OK
architect/delta: own=1 own-line=1 pair=1 foreign=0 agent=1 OK
architect/format: own=1 own-line=1 pair=1 foreign=0 agent=1 OK
architect/rashod: own=1 own-line=1 pair=1 foreign=0 agent=1 OK
orchestrator/spawn: own=1 own-line=1 pair=1 foreign=0 agent=1 OK
arbiter/granica: own=1 own-line=1 pair=1 foreign=0 agent=1 OK
adversary/ostatok: own=1 own-line=1 pair=1 foreign=0 agent=1 OK
reviewer/ostatok: own=1 own-line=1 pair=1 foreign=0 agent=1 OK
critic class lines: 17 ids=True
architect: full class lines copied=0
orchestrator: full class lines copied=0
arbiter: full class lines copied=0
adversary: full class lines copied=0
reviewer: full class lines copied=0
critic-sol: full class lines copied=0
invisible/format/combining chars in added lines: 0 []
LITERALS=12 RESULT=OK   (rc 0)

$ grep -rln '<фраза>' contracts/ roles/ AGENTS.md scripts/ fixtures/ .omp/ | grep -v normy_roley_svyazki_192   (дерево OBJECT)
'Общий предел — пять' → 0; 'При письменном СОГЛАСИИ' → 0; 'исправительный вызов по санкции оркестратора при согласии' → 0;
'арбитр созывается только при названном споре' → 0; 'Его исчерпание с FAIL — созыв' → 0; 'Находка судьи закрывается механизмом' → 0

$ provodka_sweep.sh   (check_provodka по каждому контракту с role-каналом в семи ролях: origin/main vs OBJECT)
same … rc=0 ×39; same contracts/061-uchetnyj-marshrut.md rc=1; same contracts/095-profil-i-vhod-agenta-contextpack.md rc=1;
same contracts/188-roli-po-arhitekture.md rc=1
CONTRACTS=42 RC_DIFF=0

### дерево OBJECT + наложенная семья architect (без коммита), cwd impl
$ bash fixtures/workshop_project/normy_roley_svyazki_192/red_normy_roley_svyazki_192.sh
GREEN ×46 (critic/karta … repo/agents-parity)
CELLS=46 GREEN=46
RC=0
$ … --repo .
CELLS=46 GREEN=46
RC=0
$ … --model
AGENTS_PARITY=ok
CEILINGS=7 MAX=68755 LIMIT=73728
CELLS=53 GREEN=53 RED_NEGATIVES=67/67
RC=0
$ … --stabs
AGENTS_PARITY=ok
CEILINGS=7 MAX=68755 LIMIT=73728
STAB missing-norm caught … STAB barer-stub caught (18 строк caught)
STABS=18 CAUGHT=18
RC=0
$ … --repo /nonexistent-root-192
RED ×34 (12 норм, 17 классов, critic-sol/svyazka, kap-arbitrazh/kap-soglasen/kap-tri/kap-uzkij — «нет якоря капа в §Остановка»)
GREEN istochnik/edinstvennyj, net-* ×4, starshij-poryadok ×6, repo/agents-parity
CELLS=46 GREEN=12
RC=1
$ env PATH=<каталог: python3 bash dirname git env cat sh, без node> bash red_… {bare, --repo ., --model, --stabs}
NOT_IMPLEMENTED: node недоступен — клетку агентов нечем проверить (отказ среды, rc 2)   RC=2 ×4
$ npm run -s check:gen
харнес соответствует roles/ (13 ролей)
RC=0
$ bash scripts/check_ceilings.sh .
  ok   персоны: 13 файл(ов), потолок 73728 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 175 черновик(ов) судится, замороженные — по тегам
потолки в порядке
RC=0
$ bash scripts/check_provodka.sh . contracts/192-normy-roley-svyazki.md
проводка: guard не подключён: fixtures/workshop_project/normy_roley_svyazki_192/red_normy_roley_svyazki_192.sh не вызывается в .githooks/ или .github/workflows/
RC=1
$ (временно, без коммита, затем git checkout -- .github/workflows/ci.yml) + строка `- run: bash …red_normy_roley_svyazki_192.sh --repo .` в ci.yml
RC_provodka_with_temp_wiring=0
$ bash scripts/pre_critic.sh contracts/192-normy-roley-svyazki.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1
  ok   гейт трека:
КРИТИК: дверь зелёная
RC=0
$ bash scripts/check_threat_model.sh . contracts/192-normy-roley-svyazki.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 5 буллет(ов), НЕ ЗАЩИЩАЕТ 5 буллет(ов))
RC=0
$ bash scripts/check_precision_gate.sh . contracts/192-normy-roley-svyazki.md
OK
RC=0

### дерево origin/main + наложенная семья architect (красное до реализации), cwd main
$ bash fixtures/workshop_project/normy_roley_svyazki_192/red_normy_roley_svyazki_192.sh | grep -E '^GREEN|^CELLS'
GREEN istochnik/edinstvennyj
GREEN architect/starshij-poryadok
GREEN orchestrator/starshij-poryadok
GREEN arbiter/starshij-poryadok
GREEN adversary/starshij-poryadok
GREEN reviewer/starshij-poryadok
GREEN critic-sol/starshij-poryadok
GREEN repo/agents-parity
CELLS=46 GREEN=8
RC=1

### клон, checkout 5810f784 (чистое дерево)
$ bash scripts/check_charter.sh .
…
уставных документов: 172 · изменений в них: 453 · с разрешения: 453
RC=0
$ git diff --name-only origin/main...HEAD | grep -E '^(AGENTS\.md|ROADMAP\.md|plans/|contracts/)' | wc -l
0

### check_zones (worktree на 5810f784; тег frozen/contracts/192/1 взят из локального /home/harness/dev-harness — на origin его нет; зоны читаются из блоба тега)
$ git rev-parse origin/main | tee tmp/ci-incr/zones.sha; bash scripts/check_zones.sh --incr tmp/ci-incr/zones.sha .   (окно origin/main..OBJECT)
0814d2f5a8980e6e8331f06b8e22911e5f57eade
  ok   … (строки «работа не раздаётся» прочих контрактов; строк «вне зоны» нет)
замороженных контрактов: 173 · объявленных авторов: 5 · коммитов в диапазонах: 172 · проверено по зонам: 157
real 0m45.815s
RC=0
(полный прогон без --incr за 10 мин на станции не завершился — не засчитан; дополнительно своей мерой: ЗОНА implementer
блоба тега = 14 путей, `comm -3` с `git diff --name-only origin/main...5810f784` = 0)
```
