accept
СУД: repo=dev-harness; предмет=166; фаза=реализация; роль=reviewer; вызов=1 (полный); OBJECT=f58ef9462ed1d99b9c8bcbb64c9a83d58edc8b61
Контракт: frozen/contracts/166/1 (тег 3c580d8a → коммит d2b69165, предок origin/main 65fa3044). Кандидат: wip/166/implementer, PR #596, headRefOid = OBJECT. Модель судьи: anthropic/claude-opus-5-5 (сессия Reviewer166Opus).
Пин сессии: `pwd` → /tmp/dev-harness-worktrees/c907157c/wip-166-reviewer; `git rev-parse --show-toplevel` → /tmp/dev-harness-worktrees/c907157c/wip-166-reviewer; HEAD 65fa3044, ветка wip/166/reviewer.

# Вердикт reviewer — 166, реализация, вызов 1 (полный)

## Итог

Блоков по реализации нет. Отказ по совпадению семейства снят ровно в `make_task.sh` и в
трёх копиях 136. Обязательный след автора остался: без строки автора в трассе rc 1
«свидетельство не той роли: <автор>». Назначения моделей не тронуты. Дверь 104 цела. Красное
предъявлено против базы и не подогнано: `probe.py` автор реализации не трогал.

Два пункта не закрыты, и оба вне зоны implementer:
- **БЛОК-DONE-1** — CI-шаг 166 и поле ПРОВОДКА. Зона orchestrator и контракт v+1.
- **В-1** — вопрос владельцу об остаточных запретах совпадения моделей вне объёма замороженного
  контракта.

Accept относится к блобам OBJECT f58ef946. Новая редакция кандидата этот accept не наследует.

Все прогоны ниже выполнены в одноразовом клоне
`/tmp/dev-harness-verify/Reviewer166Opus/clone` (ssh-клон, ветка wip/166/implementer, HEAD = OBJECT).
База для красного — worktree этого клона на origin/main 65fa3044:
`/tmp/dev-harness-verify/Reviewer166Opus/base`.

## 1. Область правки

`git log --format='%h %an' --name-only origin/main..HEAD` — 8 коммитов, все от `implementer <implementer@dev-harness.local>`:
```
f58ef946 AGENTS.md
cf025b07 .omp/agents/critic-sol.md .omp/agents/critic.md roles/critic-sol.md roles/critic.md
bb5bfe10 .omp/agents/{adversary,arbiter,consultant,critic-sol,critic,orchestrator,reviewer}.md
9b5f2dbf config/agent_models.json decisions/005-kritik-na-top-chuzogo-semeistva.md roles/{adversary,arbiter,consultant,critic-sol,critic,orchestrator,reviewer}.md
3f54cf54 AGENTS.md
8c11d701 fixtures/workshop_project/sessii_136/{model,stabs/s6-zadacha-filtr-vezde,stabs/s7-zadacha-trassa-net}/make_task.sh
f7637e90 fixtures/context_pack_095/{battery_stubs.sh,model/dover.sh,red_revjer_poluchaet_vydannoe.sh}
85c13798 scripts/make_task.sh
```
Своя мера: `git diff --name-only origin/main..HEAD` → 24 пути. Их прогнал через regex-фильтр ЗОНЫ
implementer, путей вне зоны — 0 (grep -v rc 1). Пути
`fixtures/workshop_project/model_choice_166 contracts registry scripts/check_sud_model.sh .github`
не тронуты: `git diff --quiet` rc 0.

Атомарность: восемь коммитов, у каждого префикс `166:`, один срез на коммит (механизм; 095; 136;
устав; роли и реестр; генерация; уточнение critic; потолок устава). Это соответствует
вертикальному срезу «Порядок» контракта.

## 2. Устав: строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ

`grep -c -x -F "<строка>"` — первая колонка, вся строка, байт в байт:
- в замороженном тексте контракта (d2b69165): 1;
- в теле 3f54cf54: 1;
- в теле f58ef946: 1.

`bash scripts/check_charter.sh` → rc 0. Две строки отчёта:
`ok уставной документ изменён с разрешения владельца: AGENTS.md в f58ef946` и `… в 3f54cf54`,
итог `AGENTS.md — уставной с ustav/1 … изменений без разрешения нет`.

Сжатие устава, `git diff cf025b07 f58ef946 -- AGENTS.md`. Удалены:
- (а) ссылка «(решение владельца 2026-10-18, docs/owner/…)» и «ровно один источник истины» — второе повторяет «**Единый источник —**» того же абзаца;
- (б) свидетельство «инцидент MiniMax без vision»;
- (в) замеры «внешний проект, три из четырёх кругов» и «каталог стилей собрали три исполнителя»;
- (г) перефраз добавленного абзаца 166.

Нормы не потеряны: удалено только историческое или повторное. Норма-строка канала charter цела
полной строкой: `AGENTS.md:59: Судьи допускаются на назначенных моделях независимо от семейства и
модели автора`, под заголовком `## Модели ролей` (AGENTS.md:43).

Размеры своей мерой:
- `wc -c` HEAD = 30653, origin/main = 30693;
- cf025b07 = 31252 (python, len bytes).

`npm run check:ceilings` → rc 0, `ok правила: 1 файл(ов), потолок 30720 байт`. Заявленное автором
«31252 → 30653» совпадает. О выходе сжатия за ПЕРЕСЕЧЕНИЕ — находка С-1.

## 3. Сырой вывод прогонов (своя мера)

`python3 fixtures/workshop_project/model_choice_166/probe.py --repo .` (реализация):
```
166 critic_sol_sol: OK rc=0 stderr=''
166 reviewer_glm_glm: OK rc=0 stderr=''
166 reviewer_cross: OK rc=0 stderr=''
166 critic_no_author: OK rc=1 stderr='ОТКАЗ: свидетельство не той роли: architect'
166 reviewer_no_author: OK rc=1 stderr='ОТКАЗ: свидетельство не той роли: implementer'
166 critic_no_judge: OK rc=1 stderr='ОТКАЗ: свидетельство не той роли: critic'
166 reviewer_no_task: OK rc=1 stderr='ОТКАЗ: нет выданного задания: 777'
rc=0
```
`python3 …/probe.py --repo ../base` (база origin/main 65fa3044, КРАСНОЕ ДО):
```
166 critic_sol_sol: RED rc=1 stderr='ОТКАЗ: судья на модели автора: gpt'
166 reviewer_glm_glm: RED rc=1 stderr='ОТКАЗ: судья на модели автора: glm'
166 reviewer_cross: OK rc=0 stderr=''
166 critic_no_author: OK rc=1 …architect
166 reviewer_no_author: OK rc=1 …implementer
166 critic_no_judge: OK rc=1 …critic
166 reviewer_no_task: OK rc=1 'ОТКАЗ: нет выданного задания: 777'
rc=1
```
`--model`: те же 7 строк OK, rc=0.

`--stabs`: те же 7 строк OK, затем:
```
166 stub missing_author: CAUGHT
166 reviewer_glm_glm: RED rc=0 stderr=''
166 stub forged_trace: CAUGHT
166 reviewer_glm_glm: RED rc=1 stderr='ОТКАЗ: судья на модели автора: glm'
166 stub reviewer_blocked: CAUGHT
rc=0
```

Батареи 095 и 136:
- `bash fixtures/context_pack_095/red_revjer_poluchaet_vydannoe.sh` → rc=0.
- `bash fixtures/context_pack_095/battery_stubs.sh`: `… стаб s17 ПОЙМАН клеткой red_revjer_poluchaet_vydannoe.sh … ИТОГ стаб-пак 095: rc=0`, rc=0.
  Своя мера: `grep -c '^zapest s[0-9]'` = 19 объявленных, `grep -c ПОЙМАН` = 19. Это сходится с заявлением автора «19/19».
- `bash fixtures/_krasnye_095.sh` → `ИТОГ 095: rc=0`.
- `bash fixtures/workshop_project/sessii_136/red_sessii_136.sh --model` → `клеток 87, зелёных 87, красных 0`, rc=0.
- `… --stabs` → `стабов 45, привязок 87, непойманных 0`, rc=0. `ls stabs | wc -l` = 45.
- `… red_sessii_136.sh` без флага (реальные scripts/*) → `клеток 87, зелёных 87, красных 0`, rc=0.

Порчи s6/s7 сохранены. Своя мера: `diff model/make_task.sh stabs/<s>/make_task.sh` на базе и на
HEAD:
- s6: 39 = 39 строк, наборы `<>` идентичны;
- s7: 34 = 34, наборы идентичны.

Копия модели и стабы изменены одинаково.

Дверь 104 (не ослаблена):
- `git diff --quiet origin/main..HEAD -- scripts/check_sud_model.sh scripts/models_actual.sh scripts/overlay.sh` → без изменений.
- Тир critic = apex-sol, модель `zai/glm-5.3`. Это назначение базы, без изменений.
- `check_sud_model.sh --spawn critic zai/glm-5.3 --root .` → `СУДЬЯ СВОЕЙ МОДЕЛИ`, rc=0.
- `--spawn critic openai-codex/gpt-6-sol` → `ОТКАЗ: модель не тира роли: critic тир apex-sol спавн openai-codex/gpt-6-sol`, rc=1.
- `--spawn critic anthropic/claude-opus-5-5` → тот же ОТКАЗ, rc=1.
- `--frontmatter` critic/reviewer/adversary/arbiter → rc=0 каждый.
- Нога `--verdict` (трасса и bind) — `bash fixtures/_krasnye_104.sh`: `red_sud_model_dver_spavna rc=0`, `red_sud_model_materializatsija rc=0`, `ИТОГ 104: rc=0`.

Генератор и двери:
- `npm run gen:harness -- --check` → `харнес соответствует roles/ (12 ролей)`, rc=0.
- `bash scripts/pre_critic.sh --repo . contracts/166-…md` → `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2`, `КРИТИК: дверь зелёная`, rc=0.
- `bash scripts/check_provodka.sh . contracts/166-…md` → `проводка: строка вне грамматики: role=roles/critic.md «…»`, rc=1. Это известный дефект контракта, см. БЛОК-DONE-1.

CI PR #596 на OBJECT (`gh pr checks 596`): antiplacebo ap1–ap5, ci l1–l7, klass, legkij,
obshchij, tyazhelyj-itog — pass; vorota — skipping.

## 4. Назначения моделей не изменены

`jq -S 'walk(if type=="object" then del(.why,.constraint) else . end)'` по origin/main и HEAD
`config/agent_models.json` → diff rc 0. Модели, тиры, роли, фолбеки и autoFallback идентичны.

Сырые изменения вне `why`/`constraint` — только снятие ключа `constraint` у трёх правил routing:
- adversary «вне семейств авторов»;
- reviewer «вне семейств авторов; судьи реализации — на двух вендорах»;
- arbiter «не на модели автора конструкции».

Это routing.constraint из §Существующее контракта. `.omp/config.yml`: изменённых строк 0.

## 5. Авторский и судейский след сохранён

Код `scripts/make_task.sh:269-284`:
- строка судьи — `[ -n "$TRACE_LINE" ] || die "свидетельство не той роли: $ROLE"`;
- строка автора для critic/reviewer — `[ -n "$AUTHOR_MODEL" ] || die "свидетельство не той роли: $AUTHOR_ROLE"`.

Удалены только `_t95_family`, `fam_j/fam_a`, отказ «судья на модели автора» и переменная
`JUDGE_MODEL`. Висячих ссылок нет: `grep JUDGE_MODEL|fam_j|fam_a` по scripts, 095 и 136 — 0
совпадений.

Поведение подтверждено:
- probe: `critic_no_author`, `reviewer_no_author`, `critic_no_judge`, `reviewer_no_task` — rc 1 с прежними причинами;
- клетка 095 (в): трасса без автора → `ОТКАЗ: свидетельство не той роли: implementer`;
- стаб probe `missing_author: CAUGHT`.

Мутант s17 перепривязан по КОДУ: маркер `# t95-m17` стоит на строке проверки следа автора
(`model/dover.sh:90`), и его ловит клетка (в). Требование Н-39 выполнено.

## 6. Красное против базы, не подогнано

- `probe.py` (зона architect) не менялся автором реализации. На базе rc 1, на OBJECT rc 0 (§3).
- Перекрёст клетки И-7, которую автор правил в зоне по «сохраняется с обновлённым ожиданием»
  контракта:
  - НОВАЯ клетка против БАЗОВОГО субъекта (`CP095_SUBJECT=base/scripts/make_task.sh`) → `КРАСНО: i7: пак для судьи на модели автора не построен (rc=1, вывод: ОТКАЗ: судья на модели автора: glm)`, rc 1;
  - СТАРАЯ клетка против субъекта реализации → `КРАСНО: i7: судья на модели автора не отказан именем (rc=0 …)`, rc 1.
- Перевёрнуто ровно ожидание (б). Клетки (а), (в) и (г) — TASK sha256, байты, трипвайр файла
  задания — не тронуты.

## 7. Паразитная сложность (050)

Новых скриптов, флагов, env-переменных, файлов и каталогов состояния дифф не вводит. По каждому
изменённому артефакту — ответы на пять вопросов:

| артефакт | (1) свойство контракта | (2) состояние | (3) файлов вместе / рост | (4) глубина | (5) потребитель / повтор | класс |
|---|---|---|---|---|---|---|
| ветвь отказа `make_task.sh` (снята) | «Снять семейный запрет в make_task», Предмет | убрана переменная JUDGE_MODEL; нового нет | 4 (make_task + 3 копии 136), как было; не выросло | интерфейс прежний (аргументы и rc), работа уменьшилась | probe.py, 095 И-7, 136 c4; повтора нет | ESSENTIAL |
| копии 136 (model, s6, s7) | §Существующее: копии отказа, «не потерять другие порчи» | нет | 3, как было | без изменений | red_sessii_136 --model/--stabs; дельта порч идентична базе | ESSENTIAL |
| семья 095: dover.sh, клетка И-7 (б), стаб s17 | «Батарея … сохраняется с обновлённым ожиданием» | нет | 3, как было | без изменений | _krasnye_095 (CI `check:context-pack-095-family-selftest`) | ESSENTIAL |
| `## Модели ролей` + норма-строка AGENTS.md:59 | ПРОВОДКА charter §Модели ролей | нет | 1 | — | check_provodka (charter-канал) | ESSENTIAL |
| пояснительный абзац AGENTS.md:55-57 и orchestrator.md (две строки после норма-строки) | не требуется (перефраз норма-строки + «след обязателен») | нет | +1 место правки той же нормы | — | потребителя-барьера нет; повторяет норма-строку | ACCIDENTAL, совет (С-1) |

Блокирующих ACCIDENTAL нет. Блокирующая находка требует фрагмента, отсутствующего свойства и
более простой формы, а у дубля в AGENTS.md более простая форма потолок не проходит (С-1).

## 8. ПРОВОДКА (038)

Своя мера, `grep -c -x -F`:
- role: `roles/critic.md` — норма-строка целой строкой 1 раз (critic.md:201, §Модель; та же в critic-sol.md:163);
- role: `roles/orchestrator.md:92` — 1;
- charter: `AGENTS.md:59` под `## Модели ролей` — 1.

Каналы существуют и подключены текстом.

guard=`scripts/make_task.sh` — это сам предмет, а не барьер. Барьер предмета, `probe.py`, в
`registry/ci-steps.tsv` и `.github/workflows/ci.yml` отсутствует (`grep model_choice_166|166` по
ним — 0 совпадений). Механизм исполняется в CI косвенно, через шаги 095 и 136. Поведенческие
нормы идут role-каналами, guard-only не заявлен. Дефект формы поля — БЛОК-DONE-1.

СВЕРКА-СТАНДАРТОВ: не применимо — `AGENTS.md` dev-harness не объявляет документа архитектуры и
стандарта кода (`grep ARCHITECTURE|CODING-STANDARDS|стандарт кода AGENTS.md` — 0 совпадений).
Режим проекта 996: sourceCanon null (пак) — сверка источников не требуется.

## 9. Расхождения с замороженным текстом контракта

- ПЕРЕСЕЧЕНИЕ «AGENTS.md — 002/010/027/028 только снятие семейного отказа». Коммит f58ef946
  сжал абзацы вне снятия отказа (С-1). Вынужденно: потолок на заморозке не учтён. Норм не
  задето.
- Критерий 5 «CI шаг 166 исполняет оба режима модели … и есть в проводке» на OBJECT не выполнен.
  Это зона orchestrator (БЛОК-DONE-1).
- Других расхождений с §Предмет и граница, §Проверяемый шов, §Модель угроз не нашёл.

## Находки

status: ready

- [ ] **БЛОК-DONE-1 (контракт / orchestrator, НЕ блок реализации).** Поле ПРОВОДКА замороженного
  контракта 166 вне грамматики 038: четыре канальные строки без «- », после них абзацы.
  `bash scripts/check_provodka.sh . contracts/166-snyatie-ogranichitelya-modelej.md` → rc 1
  «строка вне грамматики: role=roles/critic.md …». Шаг CI 166 (`probe.py --model`, `--stabs`,
  `--repo .`) не зарегистрирован в `registry/ci-steps.tsv`, `registry/ci-zamery.tsv` и
  `.github/workflows/ci.yml`: 0 совпадений.
  Закрытие:
  - контракт v+1 от владельца с полем по грамматике 038 и guard-каналом на барьер предмета;
  - интеграционный коммит orchestrator со строкой шага 166 через `gen_ci_steps.sh --write`, затем `--check` rc 0.

  До закрытия done не наступает (контракт, «Порядок»: check_provodka rc 0 до done).
- [ ] **С-1 (совет; расхождение с ПЕРЕСЕЧЕНИЕ AGENTS.md).** f58ef946 удалил исторические
  фрагменты в абзацах «Какую модель ведёт сессия» и «Несоответствие модели…»
  (AGENTS.md:31-36) и «Почему implementer нужен» (AGENTS.md:67-70). При этом в разделе
  оставлен пояснительный дубль норма-строки (AGENTS.md:55-57). Замер своей мерой: вариант
  cf025b07 без дубля = 30741 байт > 30720. Значит, без правки вне снятия отказа замороженный
  объём не проходит потолок: это дефект заморозки (27 байт запаса на базе). Совет: в v+1
  контракта назвать сжатие явно, а дубль 55-57 удалить раньше, чем свидетельства в чужих
  абзацах.
- [ ] **С-2 (совет, текст).** Опечатка «другого судья» → «другого судьи» — 7 мест в источниках:
  AGENTS.md:56, roles/critic.md:36, roles/adversary.md:61, roles/reviewer.md:90,
  config/agent_models.json:57,63,133. Плюс генерируемые копии в `.omp/agents/`.
- [ ] **С-3 (совет, текст).** roles/consultant.md §Модель: переписанная автором фраза
  «(astra — модель верхнего уровня)» и соседняя «`tiers.consultant.model = @gpt-astra`,
  `fallback = @fable`» противоречат реестру. В `config/agent_models.json` консультант —
  `@fable`, фолбек `@gpt-astra` (обмен 2026-11-01). Расхождение старше 166, но фразу автор
  переписал, а неверный факт оставил.
- [ ] **С-4 (совет, структура).** Новый заголовок `## Модели ролей` (AGENTS.md:43) включил в
  раздел абзацы «Роли tester нет», «Почему implementer нужен», «Разведчиков не заводим». К
  моделям они не относятся; прежде это было продолжение «Три роли».
- [ ] **В-1 (вопрос владельцу, новый объём — не FAIL).** Слово владельца 2026-11-07 — «убрать
  ограничитель … для любого из агентов». В активных текстах остаются запреты на совпадение
  моделей, которые замороженный контракт сознательно оставил: §Существующее, check_fork_route —
  «оставить»:
  - `roles/critic.md:36` «Consultant и arbiter не совмещаются одной моделью на одном предмете»;
  - `roles/consultant.md` инв. 2 (`МОДЕЛЬ` подписи ≠ `АВТОР` записи, отказ «самоподтверждение класса»);
  - инв. 6 (МОДЕЛЬ консультанта ≠ МОДЕЛЬ арбитра на одном `<id>`).

  Реализация здесь верна замороженному тексту. Снимать ли эти запреты — решение владельца для
  v+1.
