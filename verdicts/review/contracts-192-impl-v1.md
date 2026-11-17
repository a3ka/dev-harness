accept
OBJECT=b57628e8968bb7057ee412b31d199c6f00d0e43c
КЛАСС=doc/role; КЛАСС РИСКА=обычный — подтверждён (инструкции процесса; права/роли БД, авторизация, деньги, ПД, юридически значимые действия не затронуты; адверсарий не требуется)
СУД: repo=a3ka/dev-harness; предмет=192; фаза=реализация; роль=reviewer; вызов=1/1; модель-план=config/agent_models.json reviewer → тир audit; сессия=Rev192Impl; модель-факт=anthropic/claude-opus-5-5; SHA=b57628e8968bb7057ee412b31d199c6f00d0e43c; предыдущий=нет; исключение=нет

# Вердикт reviewer — 192 «нормы ролей связки architect↔критик» (Л3), реализация, вызов 1/1

**accept.** Блоков нет. Советы и наблюдения записаны в `.review/2026-11-17-92.md` (`status: ready`):

| Находка | Класс | Адресат | Суть |
|---|---|---|---|
| С-1 | совет | owner / следующий предмет норм | `roles/arbiter.md:22`: остаток старого порядка «не открывает третий вызов … явное решение владельца о дополнительном вызове» противоречит новой норме арбитра «исполнение проверит один узкий вызов критика» и `critic.md` §Остановка. Строка вне четырёх якорей И3. |
| С-2 | совет | owner / следующий предмет норм | `roles/critic-sol.md:137-138` и замороженная голова «Второй FAIL» в `roles/critic.md:169` пишут «исчерпание с FAIL → арбитраж» и пропускают третий вызов по санкции. §Остановка и `critic.md:172` его называют. |
| С-3 | совет, К ВЛАДЕЛЬЦУ | owner | Два числа потолка. В И5 записано 73728, живой `check_ceilings.sh` держит 81920 (owner 35f64276). `orchestrator.md` = 76510 > 73728, причём в базе до 192 было уже 75507; дельта 192 = +1003. Батарея судит 73728 только на модели, живое дерево судит только скрипт. |
| Н-1 | наблюдение | orchestrator | `check_provodka` 192 даёт rc 1 «guard не подключён». Ожидаемо, это CI-строка оркестратора. При подключённом guard во временной копии — rc 0. |
| Н-2 | наблюдение | — | «Три вызова + один узкий после арбитража» означает до четырёх вызовов critic. Формула совпадает с AGENTS.md:103 (слово владельца). |
| Н-3 | наблюдение | — | Режим «PATH без node» не воспроизведён: node лежит в `/usr/bin` рядом с python3. В повестку этот режим не входил. |

**Клон.** `ssh://git@github.com/a3ka/dev-harness.git` → `/tmp/dev-harness-verify/Rev192Impl`, свой `.git`, worktree не создавался.
```
$ git rev-parse origin/main origin/wip/192/implementer 'frozen/contracts/192/1^{commit}'
87e2521a76257c4e874e3a19b1efaec423ae41b4
b57628e8968bb7057ee412b31d199c6f00d0e43c
2209698f861714e562afcbd793d2688de51d1861
$ git log --oneline -3 origin/wip/192/implementer
b57628e8 роли: нормы связки architect↔критик (контракт 192)
87e2521a land: wip/int-1882/implementer
ea5aa4b7 orchestrator: интеграция wip/int-1881/implementer (…предмет 188…)
$ git merge-base --is-ancestor 'frozen/contracts/192/1^{commit}' 87e2521a76; echo anc=$?
anc=0
```

## 1. Область правки

```
$ git diff --stat 87e2521a76..b57628e896
 .omp/agents/adversary.md    |  6 ++++++
 .omp/agents/arbiter.md      |  6 ++++++
 .omp/agents/architect.md    | 48 ++++++++++++++++++++++++++++++++++++-------
 .omp/agents/critic-sol.md   |  2 ++
 .omp/agents/critic.md       | 50 ++++++++++++++++++++++++++++++++++++++-------
 .omp/agents/orchestrator.md |  6 ++++++
 .omp/agents/reviewer.md     |  6 ++++++
 roles/adversary.md          |  6 ++++++
 roles/arbiter.md            |  6 ++++++
 roles/architect.md          | 48 ++++++++++++++++++++++++++++++++++++-------
 roles/critic-sol.md         |  2 ++
 roles/critic.md             | 50 ++++++++++++++++++++++++++++++++++++++-------
 roles/orchestrator.md       |  6 ++++++
 roles/reviewer.md           |  6 ++++++
 14 files changed, 220 insertions(+), 28 deletions(-)
$ git log -1 --format='%an <%ae>' b57628e896
implementer <implementer@dev-harness.local>
# множество путей диффа против строки «ЗОНА implementer:» замороженного контракта (comm -3):
$ … | comm -3 - <(git diff --name-only 87e2521a76..b57628e896 | sort); echo comm-diff-done
comm-diff-done            # пусто: ровно 14 файлов зоны, ни больше ни меньше
$ git diff --name-only 87e2521a76..b57628e896 -- fixtures contracts registry .github scripts AGENTS.md verdicts | wc -l
0
$ git diff --stat 'frozen/contracts/192/1^{commit}' b57628e896 -- contracts/192-normy-roley-svyazki.md fixtures/workshop_project/normy_roley_svyazki_192; echo diffrc=$?
diffrc=0                  # пусто: контракт и батарея на OBJECT равны тегу
```
Атомарность соблюдена: в объекте один коммит, в сообщении указан предмет («(контракт 192)»). Нормативных документов вне зоны дифф не трогает: AGENTS.md побайтово равен базе (см. §4, И7).

## 2. Сырой вывод (клон, detached на OBJECT)

```
== HEAD b57628e8968bb7057ee412b31d199c6f00d0e43c
== bare
GREEN adversary/starshij-poryadok
GREEN reviewer/starshij-poryadok
GREEN critic-sol/starshij-poryadok
GREEN repo/agents-parity
CELLS=46 GREEN=46
rc=0
== --repo .
CELLS=46 GREEN=46
rc=0
== --model
AGENTS_PARITY=ok
CEILINGS=7 MAX=68755 LIMIT=73728
CELLS=53 GREEN=53 RED_NEGATIVES=67/67
rc=0
== --stabs
STAB ceiling-exceeded caught
STAB agents-drift caught
STAB barer-stub caught
STABS=18 CAUGHT=18
rc=0
== --repo /nonexistent-root-192
CELLS=46 GREEN=12
rc=1
== bash scripts/check_ceilings.sh .
  ok   персоны: 13 файл(ов), потолок 81920 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 177 черновик(ов) судится, замороженные — по тегам
потолки в порядке
rc=0
== npm run -s check:gen
харнес соответствует roles/ (13 ролей)
rc=0
== red_roles_architecture_188.sh --repo .
GREEN implementer-glm/pair
CELLS=22 GREEN=22
rc=0
== red_architecture_186.sh --repo .
186 pin pin_missing ok: rc=1 output=ARCHITECTURE_PIN_MISSING
186 pin pin_wrong ok: rc=1 output=ARCHITECTURE_PIN_MISMATCH
186 pin pin_arch_head ok: rc=1 output=ARCHITECTURE_PIN_MISMATCH
rc=0
== bash scripts/check_provodka.sh . contracts/192-normy-roley-svyazki.md
проводка: guard не подключён: fixtures/workshop_project/normy_roley_svyazki_192/red_normy_roley_svyazki_192.sh не вызывается в .githooks/ или .github/workflows/
rc=1      # ожидаемо до CI-строки оркестратора; см. Н-1
== то же во временной копии git archive OBJECT + одна строка ci.yml «run: bash …/red_normy_roley_svyazki_192.sh --repo .»
rc=0
```

**Красное до реализации (база 87e2521a76):**
```
== HEAD 87e2521a76257c4e874e3a19b1efaec423ae41b4
38                                   # строк RED
GREEN istochnik/edinstvennyj
GREEN architect/starshij-poryadok
GREEN orchestrator/starshij-poryadok
GREEN arbiter/starshij-poryadok
GREEN adversary/starshij-poryadok
GREEN reviewer/starshij-poryadok
GREEN critic-sol/starshij-poryadok
GREEN repo/agents-parity
CELLS=46 GREEN=8
rc=1
потолки в порядке
ceil rc=0
```
Совпадает с приёмкой: восемь зелёных — ровно восемь честно-зелёных клеток (источник единственен, старого порядка в шести ролях нет, агенты сходятся с генерацией). Красны 38 = 12 норм + 17 строк классов + строка critic-sol + 8 клеток капа.

## 3. Не подогнано

- Батарею писал architect до реализации: `29f9d4fc architect 2026-11-12 00:39 … 192 Л3` и `4018ff0a architect … 192 fix1`. Обе правки входят в тег `frozen/contracts/192/1`, а тег — предок базы. Implementer семью не трогал: `git diff` между тегом и OBJECT по контракту и семье пуст (§1).
- **Своя мера**, независимая от `probe.py` и `build_model.py`: одноразовый скрипт вне клона `/tmp/dev-harness-verify/Rev192Impl-own-measure.py`, читает `git show` базы и OBJECT. Итог: `RESULT OK`, rc 0, 153 строки OK. Что именно он проверял:
  - **Происхождение литералов.** 12 литералов `norms.tsv` побайтово равны 12 строкам `- role=… «…»` ПРОВОДКА замороженного контракта, порядок тоже совпадает.
  - **Каждая норма в своей роли.** Литерал стоит самостоятельной строкой ровно 1 раз; как подстрока во всём файле тоже встречается ровно 1 раз; в базе его не было. Ближайшая непустая строка над литералом — маркер `Норма-строка (ПРОВОДКА roles/<роль>.md, заморожена 192/1):`. Ни в одной другой из 13 ролей литерала нет. Число маркеров 192/1 на роль равно числу её норм: critic 3, architect 5, orchestrator/arbiter/adversary/reviewer по 1, critic-sol 0.
  - **Разделы норм:** critic — `## Связка с автором (контракт 192)`; architect — `## Связка с критиком (контракт 192)`; orchestrator — `## Связка critic ↔ architect (контракт 192)`; arbiter — `## Конечная граница (контракт 192)`; adversary и reviewer — `## Остаток контракта (контракт 192)`; строка critic-sol — `## Быстрый-процесс`.
  - **Реконструкция.** Взята база `roles/<роль>.md`, к ней применены 7 правок `drafts/edits/*.old → *.new` (семантика `replace_once`: `.new` без хвостового перевода строки). Остаток диффа против OBJECT по всем семи ролям — **только вставки**, ни одной замены или удаления. Каждая вставка — фрагмент черновика: `critic_section.md` целиком (3599 байт), `architect_section.md` целиком (2951 байт) перед `## Правила исполнения плана`, тела из `others_sections.md` для orchestrator/arbiter/adversary/reviewer (628/512/261/274 байт), строка critic-sol (97 байт). Это доказывает, что в ролях нет ни байта сверх черновиков и правок.
  - **Каждая правка по отдельности.** `.old` встречается в базе ровно 1 раз, в OBJECT его нет, `.new` встречается в OBJECT ровно 1 раз.
  - **Агенты.** `node scripts/gen-harness.ts --into /tmp/dev-harness-verify/Rev192Impl-gen` → «сгенерировано: 13 ролей», rc 0; `cmp` с `.omp/agents/{critic,architect,orchestrator,arbiter,adversary,reviewer,critic-sol,implementer}.md` → same ×8.
- **Невидимые символы** (остаток контракта, ловец — дельта-разбор ревьюера). В добавленных строках диффа нет символов категорий Cf/Mn/Me/Co/Cs/Cc и нестандартных пробелов. Во всех семи ролях целиком Cf/Mn/Me = 0.

## 4. Инварианты И1–И7

- **И1 — да.** 12/12 по своей мере (§3): одна строка, без « », единственная пара маркер→литерал, единственное вхождение, свой раздел.
- **И2 — да.** В `roles/critic.md` ровно 17 строк `- К-01 … - К-17`, порядок 01..17, побайтово равны строкам `drafts/critic_section.md`. Полной строки класса (ни с префиксом `- `, ни без него) нет ни в одном из 12 других `roles/*.md` и ни в одном из 12 `.omp/agents/*.md`, кроме critic.
- **И3 — да.** Четыре якоря нового порядка присутствуют в `roles/critic.md` (нормализация пробелов): «Общий предел — три critic-вызова», «После третьего вызова без accept — один арбитраж о конечной границе», «один узкий вызов критика только на исполнение решения арбитра», «согласен автор или спорит». Четыре старых якоря отсутствуют во всех 13 `roles/*.md` и в `AGENTS.md`. §Остановка (`roles/critic.md:32`) побайтово равна `drafts/edits/critic-ostanovka.new`, голова и хвост §«Второй FAIL» — `critic-vtorojfail-{golova,tail}.new` (реконструкция §3). Дословность ответа на вопрос суда (б): кап переписан ровно текстом замороженного черновика, без добавлений.
- **И4 — да.** Все четыре правки architect (`startup`, `otvet`, `byudzhet`, `barer`) применены дословно; после них остаток диффа — только вставка раздела.
- **И5 — команда зелёная, число И5 на живом дереве не выполнено по причине вне 192.** Подробно в С-3.
  ```
  $ wc -c roles/{critic,architect,orchestrator,arbiter,adversary,reviewer,critic-sol}.md   (OBJECT)
   48103 roles/critic.md
   54432 roles/architect.md
   76510 roles/orchestrator.md
   10385 roles/arbiter.md
    9281 roles/adversary.md
   17033 roles/reviewer.md
   20848 roles/critic-sol.md
  $ git show 87e2521a76:roles/orchestrator.md | wc -c
  75507
  $ grep -n 'PERSONA_LIMIT=' scripts/check_ceilings.sh
  30:PERSONA_LIMIT=81920
  $ git log -1 --format='%h %an %s' -S'PERSONA_LIMIT=81920' -- scripts/check_ceilings.sh
  35f64276 owner owner: потолок персоны 73728 → 81920 байт (80 КиБ)
  ```
  Ответ на вопрос суда (а). Батарея судит 73728 **только на модели**: `probe.py:395-401`, `ceiling_failures(model_dir / 'roles', …)`, модель из пиннованного `base/roles`, MAX=68755. В `--repo` (46 клеток) клеток потолка нет. Живое дерево судит только `check_ceilings.sh` по 81920, rc 0. Шесть ролей ≤ 73728; `orchestrator.md` 76510 — выше 73728, ниже 81920. Порог 73728 был превышен уже в базе (75507) до первой правки 192, так что в зоне implementer достижимого исправления нет. Решение «какой потолок» — за владельцем (С-3), блоком реализации это не является.
- **И6 — да.** `npm run -s check:gen` rc 0, своя генерация `--into` + `cmp` same ×8, `repo/agents-parity` GREEN.
- **И7 — да.** Реализация идёт после 188: база 87e2521a76 = `land: wip/int-1882` (188 влит). `.omp/agents/implementer.md`, `roles/implementer.md`, `AGENTS.md` побайтово равны базе. Раздел `## Архитектура 188` побайтово равен базе в critic, architect, orchestrator, arbiter, adversary, reviewer, implementer, implementer-glm; единственная разница — разделительная пустая строка перед новым разделом 192, вне тела раздела. Число вхождений каждого литерала `roles_architecture_188/norms.tsv` в каждой из 13 ролей в базе и OBJECT одинаково. Регрессия 188 — 22/22, rc 0.

## 5. Смысл норм (противоречия с другими нормами)

Тексты Fable внесены побайтово, и оценка смысла этого не отменяет. Найденные противоречия с соседними нормами — в советы, не в блоки. Обязательство 192 (И3) называет четыре якоря старого порядка, и все четыре сняты. Остальные остатки — вне замороженных обязательств, и их правка сверх черновиков была бы выходом за предписанный текст:
```
$ git grep -n -E 'пять (critic-)?вызов|5 вызов|…|третий вызов|исправительн|по согласию|СОГЛАСИ|названном спор' b57628e896 -- roles/ AGENTS.md
roles/arbiter.md:22:  Твой вердикт не даёт accept и не открывает третий вызов: если для freeze нужна новая подпись   → С-1
roles/architect.md:115,158,159: «пять вызовов» — измерение 174/176 в прозе черновика, не кап
roles/architect.md:215-216: «Выход при исчерпании — `roles/critic.md §Остановка`: третий вызов по санкции, затем один арбитраж…» — согласовано
roles/critic-sol.md:137-138: «его исчерпание с FAIL — арбитраж, один на предмет»   → С-2
roles/critic.md:169: «его исчерпание с FAIL решает арбитраж о конечной границе» (замороженный golova.new)   → С-2
roles/critic.md:172: «§Остановка (третий вызов по санкции, после него арбитраж … и один узкий вызов)» — согласовано
roles/critic-sol.md:49-50, roles/critic.md:63-64: «С СОГЛАСИЕМ СУДЬИ» — другой механизм (правка роли), не кап
AGENTS.md:172: ревьюер — scoped-исправительный, не кап критика
```
«Пять» как действующий кап не встречается нигде: ни в `roles/`, ни в `AGENTS.md`.

## ОСТАТОК (строки `НЕ ЗАЩИЩАЕТ` с ловцом reviewer)

Контракт 192 К-NN этим строкам не присваивает.
- ОСТАТОК: невидимые символы внутри якорей старого порядка — **не укусил**. В добавленных строках диффа (`roles/*`, `.omp/agents/*`) категорий Cf/Mn/Me/Co/Cs/Cc нет. Каналы ролей побайтово равны `drafts/edits/*.new`; `.old` в OBJECT отсутствует (§3).
- ОСТАТОК: подмена самой семьи вместе с ролями — **не укусил**. `git diff 'frozen/contracts/192/1^{commit}' b57628e896 -- contracts/192-… fixtures/…/normy_roley_svyazki_192` пуст.

## Паразитная сложность (050)

Неприменимо: в диффе нет скриптов, функций, флагов, env или файлов состояния. Изменены только тексты ролей и их генерируемые производные; новых артефактов нет.

СВЕРКА-СТАНДАРТОВ: н/п — `AGENTS.md` dev-harness не объявляет документа архитектуры и стандарта кода (`docs/ARCHITECTURE.md`, `docs/CODING-STANDARDS.md` в дереве нет). Дифф — тексты ролей и генерируемые `.omp/agents`; их соответствие закреплено `check:gen` rc 0.

СВЕРКА-АРХИТЕКТУРЫ: размещение — только `roles/*` и производные `.omp/agents/*` в зоне контракта; зависимостей, писателей, операций и `bindings.json` дифф не вводит (в харнессе `bindings.json` нет); долг не расширен — раздел «Архитектура 188» и его нормы побайтово сохранены (И7); diff модели — L0 (модель не затронута). Находок `finding new` нет.

**Порядок.** Адверсарий по классу «обычный» не требуется. Вердикт относится к OBJECT b57628e896. Новая редакция ролей этот accept не наследует.
