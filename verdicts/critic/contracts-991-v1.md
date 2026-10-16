FAIL
ПРЕДМЕТ: contracts/991-complior-repeticiya-p107-p111.md + fixtures/workshop_project/rehearsal_991/{.probe-only,model.tsx,probe.py,rehearsal.test.tsx,rehearsal.yaml}
OBJECT=b7c9f900838193c3e3022f37ecfef29610010dab
ВЕТКА: wip/991/architect (merge-base с main 8f3a89e4f; main при суде 8a30e7bf2)
КРУГ: 1
МОДЕЛЬ: anthropic/claude-opus-5-5 (роль apex → @opus; architect на @gpt-astra — чужое семейство соблюдено)

## Живые замеры этого круга (третье независимое подтверждение чисел автора)

Complior-mob: `gh repo clone a3ka/Complior-mob` в /tmp/dev-harness-verify/critic991c1/complior-mob,
HEAD = origin/main = `8a699d175114f82395e019964ee1fec02a6bb200` (совпадает с пином :13/:66);
`npm ci --no-audit --no-fund` в mobile/ → rc 0. Фикстуры взяты `git archive wip/991/architect`
(blob probe.py `3a190bf6d`, sha256 `6e97a6f8…f9068e`).

|команда|rc|вывод|
|---|---|---|
|`python3 probe.py --repo complior-mob`|1|`actual/R1 rc=1 failed`, `actual/R2 rc=1 failed`, `executed=2`; обе ошибки `Unable to find an element with role: button, name: Prüfung starten`|
|`python3 probe.py --repo complior-mob --matrix`|0|honest/R1 0, honest/R2 0, noop/R1 1, premature/R1 1, sticky/R2 1, sticky/R1 0; `executed=6`|
|`probe.py --repo <несуществующий под allowlist>`|2|`991 INFRASTRUCTURE: [Errno 2] …start-screen.tsx`|
|`probe.py --repo /tmp`|2|`disposable clone must be under /tmp/dev-harness-verify`|
|`bash scripts/check_precision_gate.sh <wt> contracts/991-…md`|0|`OK`|
|`bash scripts/check_spec_ready.sh <wt> contracts/991-…md`|0|`OK`|
|`bash scripts/pre_critic.sh --repo <wt> contracts/991-…md`|0|`КРИТИК: дверь зелёная`|
|`bash scripts/check_threat_model.sh <wt> contracts/991-…md`|0|ЗАЩИЩАЕТ 3, НЕ ЗАЩИЩАЕТ 3|
|`bash scripts/check_ceilings.sh <wt>`|**1**|`FAIL … 991-…md (31001 байт): тело раздела «Незаполненные требования:» вне грамматики` (на main тот же скрипт rc 0) — см. СОВЕТ 1|

`<wt>` = /tmp/dev-harness-worktrees/c907157c/wip-991-architect, HEAD b7c9f9008, грязь только `?? .omp/context/`.
После обоих прогонов клон Complior чист (`git status --porcelain` пуст) — finally восстановил StartScreen.

Н-39 соблюдён: привязки контрмоделей к входам — в коде (`probe.py:20-22` MATRIX, режим через
`REHEARSAL_991_MODEL` в `model.tsx:5,10,13`), не в прозе. Каждая контрмодель падает на СВОЁМ
assertion (stderr матрицы): noop — `rehearsal.test.tsx:15` getByText «abgeschlossen»; premature —
`:9` queryByText toBeNull; sticky/R2 — `:9` после remount. Вход базы: реальный
`mobile/src/features/start/start-screen.tsx:8` несёт `testID="start-screen"`, поэтому отрицательный
native-прогон `rehearsal.yaml:6-9` споткнётся именно на `id: rehearsal-start`, а не раньше
[INFERENCE: чтение кода; native NOT_RUN — станции у критика нет].

Граница «991 сейчас ничего в Complior-mob не раздаёт» в тексте соблюдена: `:4` (не разрешение
push/freeze/раздачи), `:40` (без допуска публикация не начинается), `:83` (зона implementer —
ПОСЛЕ отдельного допуска и freeze-PR), `:110` (Б1 разрешил подготовку). ПЕРЕСЕЧЕНИЕ `:81` —
легитимный маршрут А-114/А-116/А-155, не обход. Модель угроз (норма 041) и precision-гейт
(норма 043) — rc 0, см. таблицу.

## Находки

БЛОКИРУЕТ contracts/991-complior-repeticiya-p107-p111.md:15,57-62,92 — контракт вводит в оба
Complior-workflow НОВУЮ проверку (APK/JUnit/каждый PNG отдельно, «JUnit без
failures/errors/skipped» `:61`, Maestro 2.11.0 «несовпадение — отказ» `:30,:57`), но ни один пункт
приёмки `:66-73` не предъявляет её КРАСНОЙ. Это противоречие норме AGENTS.md, правило 3 («проверка
не готова, пока не предъявлена КРАСНОЙ против обманной заглушки»). Отрицательный PR идёт ПЕРВЫМ
(`:41`) — на старом workflow, новую проверку он не исполняет; к тому же она стоит только в
«успешном нативном шаге» (`:60`). «Парный негатив» `:70` — ручная сверка reviewer'ом АРТЕФАКТОВ
одного прогона, не способности проверки упасть.
ОБХОД: положительный PR C пишет шаг проверки как `run: test -d maestro-out` и cloud-установку как
`… && maestro --version || true`. Честный flow сам производит оба PNG и JUnit, поэтому reviewer по
`:70` находит полный комплект, `gh pr checks` (`:69`) и post-merge (`:73`) зелёны — все пункты
`:66-73` выполнены, а заявленная дельта «проверка каждого обязательного evidence-файла» (`:15`) и
ЗАЩИЩАЕТ `:92` — плацебо, которое следующей поставке пропустит отсутствующий `rehearsal-after.png`.
Отягчает (вопрос 3): если проверку внести во freeze-PR, она обязана там быть зелёной (`:43`), хотя
rehearsal-flow там НЕ активирован — значит исполнитель сам придумает условие «проверять PNG, если…»,
и условие такого вида плацебо по построению.
ВЫХОД (совет формы, не требование): вынести проверку в `mobile/scripts/<имя>` (зона `:83` уже это
допускает) и добавить пункт приёмки с командой, исполнимой без эмулятора: каталог без
`rehearsal-after.png` → rc≠0 с именем файла; два файла одного имени → rc≠0; JUnit с
failure/skipped → rc≠0; версия Maestro ≠ 2.11.0 → rc≠0; полный комплект → rc 0. И назвать, при каком
объекте (freeze-PR / положительный / post-merge) проверка обязательна.

БЛОКИРУЕТ contracts/991-complior-repeticiya-p107-p111.md:44,51,83 — дифф положительного PR в
Complior механически не ограничен. (а) Байтовое тождество требуется только для flow (`:44`
«одинаковый SHA-256 flow»), для Jest-теста — нет (`:51` лишь называет место). (б) Зона implementer
в Complior объявлена прозой (`:83`); ЗОНА-строки для него нет, а `scripts/check_zones.sh:34`
по построению: «НЕОБЪЯВЛЕННЫЕ АВТОРЫ НЕ ПРОВЕРЯЮТСЯ». (в) Ни один пункт `:66-73` не сверяет дифф
B..C с перечнем `:83` и неизменность существующих проверок («проверки не ослабляются» `:44` —
пожелание без команды, вопрос 2).
ОБХОД: C кладёт в `mobile/src/features/start/__tests__/rehearsal.test.tsx` пустой
`it('R1 starts incomplete and completes only after a press', () => {})` и убирает
`expect(screen.getByRole('header'))` из соседнего `start-screen.test.tsx`; StartScreen при этом
честный. `probe.py --repo R` берёт байты теста из фикстуры dev-harness, а НЕ из PR → rc 0
executed=2 (`:66`); Maestro (`:68`), `gh pr checks` (`:69`), push-run (`:73`) — зелёны. Все пункты
выполнены, а «включает Jest … обычный npm test в quality его выполняет» (`:44,:51`) и ЗАЩИЩАЕТ `:90`
(«настоящий Jest … судят действие, результат и reset») не сделаны: quality на main поведение не судит.
ВЫХОД (совет формы): пункт приёмки с командой — `git -C R show C:mobile/src/features/start/__tests__/rehearsal.test.tsx | sha256sum`
равен `sha256sum fixtures/workshop_project/rehearsal_991/rehearsal.test.tsx` (байты переносимы как
есть: импорт `../start-screen` тот же), `git -C R diff --name-only B C` ⊆ перечню `:83` с rc, и
`git -C R diff --exit-code B C -- mobile/src/features/start/__tests__/start-screen.test.tsx mobile/.maestro/start.yaml`.
Либо ЗОНА-строка implementer, либо названный механизм, держащий его границу в Complior.

СОВЕТ contracts/991-complior-repeticiya-p107-p111.md:112-114 — тело «## Незаполненные требования:»
вне грамматики `check_ceilings.sh` (пустая строка + абзац без «- »): rc 1 на ветке, rc 0 на main.
CI-лейн l7 (`.github/workflows/ci.yml:116`, ключ `check:ceilings`) покраснеет на этом дереве.
Правка: каждую позицию — отдельной строкой «- …», без пустой строки. Оркестратору — наблюдение:
`pre_critic.sh` дал «дверь зелёная» при rc 1 у гейта CI (правило 6, «гейт зеленее CI»).

СОВЕТ fixtures/workshop_project/rehearsal_991/.probe-only:2 — устаревший путь
`fixtures/rehearsal_991/probe.py`; после переноса — `fixtures/workshop_project/rehearsal_991/probe.py`.

СОВЕТ contracts/991-complior-repeticiya-p107-p111.md:41-42,62 — отрицательный PR идёт до любой
проводки, на старом workflow (`mobile.yml:64-70`: только `maestro-${{ github.sha }}`, `warn`, APK
не выгружается). Требование «Отрицательный сценарий судится по JUnit/assertion и APK» (`:62`) и
«сохранённые … APK» (`:42`) тогда не исполнимо artifact'ом; несёт ли отрицательный PR правку
workflow — решение, молча оставленное исполнителю (вопрос 3). Назвать.

СОВЕТ contracts/991-complior-repeticiya-p107-p111.md:43,57,83 — противоречие о том, кто пишет
workflow-проводку freeze-PR: `:57` — implementer, «подготовительная часть — freeze-PR»; `:43` —
freeze-PR проходит CI «ДО implementer»; `:83` — зона implementer открывается «ПОСЛЕ … freeze-PR».
Автор/публикатор отрицательного PR (`:41`, файл `mobile/.maestro/rehearsal.yaml`) не назван вовсе
(вопрос 4). Назвать исполнителя каждого из двух ранних PR.

СОВЕТ contracts/991-complior-repeticiya-p107-p111.md:85 — `РАБОТА НЕ РАЗДАЁТСЯ:` по грамматике
`check_zones.sh` объявляет весь контракт нераздаваемым, а здесь стоит рядом с ЗОНА-строками как
список исключений. Механизм принимает, но смысл двоится; перечень исключений лучше дать прозой.

СОВЕТ contracts/991-complior-repeticiya-p107-p111.md:22 — «Остальные элементы временного
StartScreen сохраняются»: подзаголовок «Mobile — Grundgerüst» (`start-screen.tsx:12`) не утверждает
ни один тест/flow (`start-screen.test.tsx` — только header и testID, `start.yaml` — только «Complior»);
ловит только владелец по PNG (`:47`). Одна строка assertion сделала бы это механическим.

СОВЕТ contracts/991-complior-repeticiya-p107-p111.md:108 — «MATRlX» набрано с латинской `l`;
поиск по имени `MATRIX` строку не найдёт.

СОВЕТ contracts/991-complior-repeticiya-p107-p111.md:66-67 — `executed=N` считает сам probe
(`len(results)`); другая мера (правило 4) — построчные `991 <mode>/<case>: rc=… assertion=…` из
Jest JSON. Достаточно, но reviewer'у стоит пересчитывать строки, а не итог.

## Итог

Две блокирующие находки — одного корня: в Complior-mob контракт поставляет две механические
гарантии (проверку evidence в workflows и Jest-регрессию в quality), а критерий проверяет только
ПОВЕДЕНИЕ приложения в этом прогоне, не сами гарантии. Обе закрываются добавлением пунктов приёмки
с командой; предмет, последовательность, Б1, пробы dev-harness и граница раздачи — в порядке.
Круг первый; арбитр не созывается.
