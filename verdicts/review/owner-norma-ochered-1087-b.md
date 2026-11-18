accept
OBJECT=b77f6ee8faed4c768223e96a9ba3187a37458e1a
ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/review/owner-norma-ochered-1087.md

# Ревьюер, повтор по скоупу (вызов 2): owner-PR a3ka/dev-harness#1087 (`owner/norma-ochered`), норма-строка п.4 «очерёдность»

- Предмет: оговорка `cognitive-only` к норме п.4 в `roles/orchestrator.md` §«Начатое — до конца; лимит параллельности» и производная `.omp/agents/orchestrator.md`.
- Скоуп повтора: блок Б1 прошлого вердикта (FAIL на OBJECT `3ff12828655d6dac89ec0bf02a22ca2e4b35f216`, в main `913378f581`) и регресс дельты `3ff12828..b77f6ee8`. Остальная часть прошлого вердикта (сверка содержания, ОСТАТОК, СВЕРКА-СТАНДАРТОВ/АРХИТЕКТУРЫ, сложность) не пересматривалась: дельта её не затрагивает (ниже показано, что дельта — одна строка).
- Класс задачи: некодовый (норма роли и производная). Класс риска: обычный.
- Манифест двери: SUBJECT=192 (роль reviewer).
- Сессия: `Rev1087b` (субагент; `PI_SESSION_ID=01a1ee72-08b2-76ed-9e1d-36ac98da67da`).
- Модель-факт (`bash scripts/models_actual.sh --tsv --bind --session Rev1087b | cut -f1-3`, основной чекаут `/home/harness/dev-harness`, только чтение; rc 0):
  ```
  reviewer	anthropic/claude-opus-5-5	allowed
  reviewer	anthropic/claude-opus-5-5	allowed
  ```
- Клон: `/tmp/dev-harness-verify/Rev1087b/repo` (свежий `git clone ssh://git@github.com/a3ka/dev-harness.git`), `git checkout --detach b77f6ee8faed4c768223e96a9ba3187a37458e1a`.

## Итог

accept. Б1 закрыт по свойству. Строка п.4 теперь прямо помечена `cognitive-only`, в ней записаны отсутствие механизма с условием его появления, остаточный риск и два ловца: роль плюс то, по чему она ловит. Это форма, которую требует AGENTS.md правило 1, и она строже соседней нормы роли (:48). Дельта — ровно эта дописка, в двух файлах побайтово одинаковая. Производная равна генерации, потолок соблюдён. Блоков нет. Советы С1–С3 прошлого вердикта не закрыты; они и не блокировали. Добавлен совет С4.

## Б1 — закрыт

- Было (`roles/orchestrator.md:410` на `3ff12828`): «… новое вне очереди — только когда очередь исчерпана или словом владельца (ADR docs/owner/adr/2026-11-18-sverka-i-ocherednost.md).»
- Стало (`roles/orchestrator.md:410` на `b77f6ee8`; та же строка — `.omp/agents/orchestrator.md:413`): «… новое вне очереди — только когда очередь исчерпана или словом владельца; cognitive-only: механизма нет (замок очереди в zamok/pre-spawn отложен ADR до повтора перескоков), остаточный риск — перескок/простой машиной не ловится; ловцы — консультант по блоку «ОЧЕРЕДЬ» HANDOFF и ревьюер по трейсу (ADR docs/owner/adr/2026-11-18-sverka-i-ocherednost.md).»
- Обязательство: `AGENTS.md:218-219`: «**Правило без механизма не существует.** Либо проверка, либо явная пометка `cognitive-only` с записанным остаточным риском.»
  - пометка `cognitive-only` стоит буквально — есть;
  - остаточный риск записан: «перескок/простой машиной не ловится» — есть;
  - сказано, почему механизма нет и когда он появится: «замок очереди в zamok/pre-spawn отложен ADR до повтора перескоков». Это сверено с ADR: `docs/owner/adr/2026-11-18-sverka-i-ocherednost.md:14` — «механический замок очереди в zamok_predmeta — отложено: сначала норма и наблюдение; механизм — предметом, если перескоки продолжатся», `:16` — «условие пересмотра: перескоки или простой на форках повторяются — механизм в zamok/pre-spawn». Расхождения с ADR нет. Скрипт `scripts/zamok_predmeta.sh` в дереве существует, так что названный будущий носитель механизма реален.
- Ловцы, их форма и достаточность:
  - Как устав называет ловцов. `AGENTS.md:105` перечисляет их ролями («остаточным риском с ловцом (адверсарий, ревьюер, CI)»). Соседняя норма роли `roles/orchestrator.md:48` пишет так: «Напоминание cognitive-only, ловцы — консультант/ревьюер.» Новая строка называет две конкретные роли и у каждой — объект ловли («по блоку «ОЧЕРЕДЬ» HANDOFF», «по трейсу»). Ловцов не «все»: названы две роли, у каждой свой объект. Форма допустимая и строже прецедента :48.
  - Консультант. У этого ловца есть канал: ADR п.3 (`:8`) — «Сторож загрузки консультанта толкает к «следующему по ОЧЕРЕДИ HANDOFF»». Блок «ОЧЕРЕДЬ» лежит в HANDOFF, его видно в артефакте.
  - Ревьюер «по трейсу». Ловец назван, но в `roles/reviewer.md` нет ни слова «трейс», ни «ОЧЕРЕДЬ» (обе проверки grep дали 0). Момент, когда ревьюер видит трейс оркестратора, нигде не назван. Правило 1 ловца не требует, ему достаточно записанного остаточного риска, а прецедент :48 устроен так же. Поэтому это совет С4, а не блок.

## Регресс дельты — нет

- `git diff --stat 3ff12828..b77f6ee8`: 2 файла, по +1/−1. Это `roles/orchestrator.md:410` и `.omp/agents/orchestrator.md:413`, в обоих одна и та же правка.
- `git diff -U0`: изменилась только хвостовая часть п.4. Вместо « (ADR …).» стоит «; cognitive-only: … ловцы — … (ADR …).» Прежний текст нормы до «словом владельца» не тронут. Ссылка на ADR осталась, теперь она в конце строки.
- `diff <(sed -n 410p roles/orchestrator.md) <(sed -n 413p .omp/agents/orchestrator.md)`: rc 0 (строки побайтово одинаковые).
- Уставные пути не тронуты: `git diff --name-only 3ff12828..HEAD | grep -E '^(AGENTS\.md|ROADMAP\.md|plans/|contracts/)'` дал rc 1 (совпадений нет).
- Коммит дельты один: `b77f6ee8 owner <owner@dev-harness.local> | owner | owner: норма очерёдности — пометка cognitive-only, остаточный риск и ловцы (Б1 Rev1087)`. Предмет ссылки (Б1 Rev1087) в нём назван. `3ff12828` — предок `b77f6ee8` (`merge-base --is-ancestor` rc 0).
- Против main: `origin/main` = `913378f5`, merge-base = `a430e5c0`. Ветка отстаёт на 2 коммита (`4160d716` — вердикт Rev1087, `913378f5` — его land), и оба трогают только `verdicts/review/owner-norma-ochered-1087.md`. Пересечения с диффом PR нет. `git diff --stat origin/main...HEAD`: 2 файла, +2.
- Норма-строка 192/1 на месте (`grep -c 'заморожена 192/1' roles/orchestrator.md` = 1). `bash scripts/check_provodka.sh . contracts/192-normy-roley-svyazki.md` дал rc 0.

## ОСТАТОК (контракт 192)
- ОСТАТОК: «подмена самой семьи (`norms.tsv`, `drafts/`, база модели) вместе с ролями; смысл изменений судят critic и reviewer» (contracts/192-normy-roley-svyazki.md:43) — не укусил: дельта меняет одну строку п.4 в роли и в производной, а `norms.tsv`, `drafts/` и норм-строки 192/1 не трогает.
- ОСТАТОК: «исполнение норм агентами … новые строки норм — cognitive-only» (:41) — не укусил. Новая строка сама помечена `cognitive-only`, и этим снят Б1.

## СВЕРКА-СТАНДАРТОВ
СВЕРКА-СТАНДАРТОВ: не применимо. `AGENTS.md` харнесса не объявляет `docs/ARCHITECTURE.md`/`docs/CODING-STANDARDS.md`, дельта некодовая (как и в прошлом вердикте; дельта этого не меняет).

## СВЕРКА-АРХИТЕКТУРЫ
СВЕРКА-АРХИТЕКТУРЫ: размещение — норма в `roles/` (источник) и производная в `.omp/agents/` из `gen-harness`, соответствует. Зависимостей, писателей и операций не добавлено, `bindings.json` не тронут. Долг не расширен: норма без механизма теперь записана как `cognitive-only` с остаточным риском. Diff модели нет, находку `finding new` не заводил.

## Паразитная сложность (контракт 050)
Новых артефактов нет: дельта дописывает одну оговорку в уже существующую норма-строку. (1) Свойство — AGENTS.md правило 1 (пометка `cognitive-only` с остаточным риском). (2) Состояния не вводит. (3) Вместе меняются 2 файла (роль и производная), число не выросло. (4) Интерфейса нет. (5) Потребители — сессии-оркестраторы и судьи. Грамматику `cognitive-only, ловцы — …` дельта не изобретает, а повторяет из :48. Сложность ESSENTIAL.

## Советы (не блокируют)

- С1 (прошлый вердикт) — не закрыт: `roles/orchestrator.md:407` всё ещё ссылается на «сводная редакция §11, раздел 2» (`grep -c` = 1).
- С2 (прошлый) — не закрыт: «в том же блоке» в п.4 не дописано (`grep -c -E 'в том же блоке|в лимитах п\.1'` по строке 410 = 0).
- С3 (прошлый) — не закрыт: оговорки «(в лимитах п.1–2)» нет (то же grep = 0).
- С4 (новый). `roles/orchestrator.md:410`: ловец «ревьюер по трейсу» назван, но ни в `roles/reviewer.md`, ни в другом канале ревьюера нет обязанности смотреть трейс оркестратора на перескок или простой: `grep -c 'ОЧЕРЕД' roles/reviewer.md` = 0, `grep 'трейс' roles/reviewer.md` — пусто. По факту ловит консультант (сторож ADR п.3). Совет на будущий предмет механизма или нормы ревьюера: назвать момент, когда ревьюер видит трейс (например, вердикт по HANDOFF-ротации), либо оставить в оговорке одного консультанта. Блоком не является: правило 1 ловца не требует, прецедент :48 устроен так же.

## Сырые команды и вывод

```
$ git clone -q ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/Rev1087b/repo ; echo rc=$?
rc=0
$ git fetch -q origin owner/norma-ochered ; git checkout -q --detach b77f6ee8faed4c768223e96a9ba3187a37458e1a ; git rev-parse HEAD
b77f6ee8faed4c768223e96a9ba3187a37458e1a
$ git diff --stat 3ff12828655d6dac89ec0bf02a22ca2e4b35f216..b77f6ee8faed4c768223e96a9ba3187a37458e1a
 .omp/agents/orchestrator.md | 2 +-
 roles/orchestrator.md       | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)
$ git log --format='%H %an <%ae> | %cn | %s' 3ff12828..b77f6ee8
b77f6ee8faed4c768223e96a9ba3187a37458e1a owner <owner@dev-harness.local> | owner | owner: норма очерёдности — пометка cognitive-only, остаточный риск и ловцы (Б1 Rev1087)
$ git merge-base --is-ancestor 3ff12828 b77f6ee8 ; echo anc=$?
anc=0
$ git diff -U0 3ff12828..b77f6ee8     (обе ханки: @@ -413 +413 @@ и @@ -410 +410 @@; одна и та же строка)
-… новое вне очереди — только когда очередь исчерпана или словом владельца (ADR docs/owner/adr/2026-11-18-sverka-i-ocherednost.md).
+… новое вне очереди — только когда очередь исчерпана или словом владельца; cognitive-only: механизма нет (замок очереди в zamok/pre-spawn отложен ADR до повтора перескоков), остаточный риск — перескок/простой машиной не ловится; ловцы — консультант по блоку «ОЧЕРЕДЬ» HANDOFF и ревьюер по трейсу (ADR docs/owner/adr/2026-11-18-sverka-i-ocherednost.md).
$ diff <(sed -n '410p' roles/orchestrator.md) <(sed -n '413p' .omp/agents/orchestrator.md) ; echo rc_same=$?
rc_same=0
$ git diff --name-only 3ff12828..HEAD | grep -E '^(AGENTS\.md|ROADMAP\.md|plans/|contracts/)' ; echo rc_ustav_grep=$?
rc_ustav_grep=1

$ sed -n '218,219p' AGENTS.md
1. **Правило без механизма не существует.** Либо проверка, либо явная пометка
   `cognitive-only` с записанным остаточным риском.
$ grep -n -o 'cognitive-only.\{0,160\}' roles/orchestrator.md   (фрагмент)
48:cognitive-only, ловцы — консультант/ревьюер.
55:cognitive-only контроль делегирования — ревьюер по диффу (011).
410:cognitive-only: механизма нет (замок очереди в zamok/pre-spawn отложен ADR до повтора перескоков), остаточный риск — перескок/простой машиной не ловится; ло…
$ grep -n -o '.\{0,100\}ловц.\{0,100\}' AGENTS.md
105:исправить, что записать остаточным риском с ловцом (адверсарий, ревьюер, CI). Затем один узкий вызов
249:    `cognitive-only` в шапке `check_charter.sh`, ловцы названы там же.
$ grep -n -i -E 'замок|отлож|pre-spawn|сторож' docs/owner/adr/2026-11-18-sverka-i-ocherednost.md
8:  3. Сторож загрузки консультанта толкает к «следующему по ОЧЕРЕДИ HANDOFF», а не к «любому незаблокированному предмету».
14:  - механический замок очереди в zamok_predmeta — отложено: сначала норма и наблюдение; механизм — предметом, если перескоки продолжатся;
16:условие пересмотра: перескоки или простой на форках повторяются — механизм в zamok/pre-spawn.
$ ls scripts | grep -i -E 'zamok|pre.?spawn'
zamok_predmeta.sh
$ grep -c 'ОЧЕРЕД' roles/consultant.md roles/reviewer.md
roles/consultant.md:0
roles/reviewer.md:0
$ grep -n 'трейс' roles/reviewer.md roles/consultant.md
(пусто)

$ npm run gen:harness ; echo rc_gen=$?
> node scripts/gen-harness.ts
сгенерировано: 13 ролей, обновлено файлов: 0
rc_gen=0
$ git status --porcelain
(пусто)
$ npm run gen:harness -- --check ; echo rc_gencheck=$?
> node scripts/gen-harness.ts --check
харнес соответствует roles/ (13 ролей)
rc_gencheck=0
$ npm run check:gen ; echo rc_checkgen=$?
> node scripts/gen-harness.ts --check
харнес соответствует roles/ (13 ролей)
rc_checkgen=0
$ bash scripts/check_ceilings.sh ; echo rc_ceil=$?
  ok   персоны: 13 файл(ов), потолок 81920 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 182 черновик(ов) судится, замороженные — по тегам
потолки в порядке
rc_ceil=0
$ wc -c roles/orchestrator.md .omp/agents/orchestrator.md
 77690 roles/orchestrator.md          (заявлено автором 77690 — совпало; запас 4230 до PERSONA_LIMIT=81920, scripts/check_ceilings.sh:30)
 78033 .omp/agents/orchestrator.md

$ git fetch -q origin main ; git rev-parse origin/main ; git merge-base origin/main HEAD ; git rev-list --count HEAD..origin/main
913378f5816adcbf42826e904493cc8ebb3a8f53
a430e5c0eb593481606f4db9034c6d860da54ee1
2
$ git log --format='%h %an | %s' a430e5c0..origin/main ; git diff --name-only a430e5c0 origin/main
913378f5 orchestrator | land: wip/int-2017/reviewer
4160d716 reviewer | reviewer: вердикт FAIL owner-PR #1087 (норма очерёдности п.4; OBJECT=3ff12828655d6dac89ec0bf02a22ca2e4b35f216)
verdicts/review/owner-norma-ochered-1087.md
$ git diff --stat origin/main...HEAD
 .omp/agents/orchestrator.md | 1 +
 roles/orchestrator.md       | 1 +
 2 files changed, 2 insertions(+)
$ bash scripts/check_provodka.sh . contracts/192-normy-roley-svyazki.md ; echo rc_prov=$?
rc_prov=0
$ grep -c 'заморожена 192/1' roles/orchestrator.md
1
$ bash scripts/check_charter.sh ; echo rc_charter=$?
уставных документов: 181 · изменений в них: 525 · с разрешения: 525
rc_charter=0
```

## Развилки
- Ловец «ревьюер по трейсу» без канала в `roles/reviewer.md` записан советом С4, а не блоком. Основания: правило 1 требует только `cognitive-only` и остаточного риска, у соседней нормы :48 та же форма, а эту формулировку предложил сам прошлый вердикт (Б1, «более простая форма»). Блокировать собственную предложенную форму было бы сменой критерия между кругами.
- Вердикт закоммичен на ветке `rev1087b/verdict` от `origin/main` (`913378f5`), а не на `owner/norma-ochered`. Так же был сделан прошлый вердикт: `4160d716` стоит на `a430e5c0` = main. Владельческую ветку судья не трогает.
