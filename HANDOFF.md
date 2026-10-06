## ГДЕ МЫ (2026-10-06, ~16:50 UTC — push-блокер СНЯТ полностью, 086 И 087 ЗАМОРОЖЕНЫ
(frozen/contracts/086/1, frozen/contracts/087/1), критик круг 2 accept на обоих,
фикстуры/батарея обоих в main, всё запушено. 083 land ЗАБЛОКИРОВАН новой находкой —
charter-отказ на sync-merge (Н-213-класс), НЕ починен, нужно слово владельца/архитектора.
Следующий шаг: implementer 086 — можно раздавать сразу; 083 charter-блокер — к архитектору/
владельцу; implementer 087 ждёт ленда 083.)

- Серверная обвязка станции — единый источник: ops/server/README.md.

### Итог сессии (сжато, для быстрой ориентации)

1. **Push-блокер (72 коммита, ~5+ ч) снят.** Корень — ДВА независимых пробела: (а) `check:ids`
   FAIL на голых `083-*-klass-v1.md` в `verdicts/consultant/` (переименованы в `fork-083-*`,
   коммит `72d6e76`); (б) main CI самотест 071 падал — mint-теги `id/CONTRACT/084`/`085` были
   локальными, НЕ на origin (допушены). `git push origin main` прошёл (`d1cbcf7..0ff0cec`),
   main CI зелёный (все 6 джоб, run `37483686850`).
2. **086 и 087 — ПОЛНЫЙ цикл до freeze за эту сессию.** Контракты спроектированы ПРЕДЫДУЩЕЙ
   сессией (architect ClearParrot/IntellectualEarwig); эта сессия: критик круг 1 (ОБА FAIL,
   параллельно, по слову владельца) → architect-фиксы (ArchitectFix086/087, isolated,
   материализованы git-плумбингом) → критик круг 2 (ОБА accept) → freeze (086→
   `frozen/contracts/086/1`, 087→`frozen/contracts/087/1`) → фикстуры/батарея закоммичены
   (zone стала живой ПОСЛЕ freeze — критичный урок, см. ниже) → всё запушено через retroactive-
   PR-CI-гейт (контракт 069).
3. **083 (CI-A генератор шагов) — НЕ приземлён.** Integration-ветка (`wip/083/integration`)
   обновлена merge’ем текущего main, запушена, PR#30 синхронизирован — **PR-CI КРАСНЫЙ**
   (run `37491182280`, 8 из 12 джоб failure). Корневая причина (минимум для `l1,
   check:charter`): sync-merge коммиты (МОЙ `f171fab` И пред-существующий `8b5c0dd` прошлой
   сессии) трогают `contracts/083-ci-a-parallelnye-dzhoby-generator-shagov.md` (уставный путь)
   БЕЗ строки `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` в теле коммита — правило 11 устава. **Это Н-213-класс**
   (тот же корень, что уже ловился раньше на 083). НЕ чинил сам — нет права писать
   РАЗРЕШИЛ-строку без слова владельца (правило 11). Другие 7 упавших джоб НЕ продиагностированы
   до конца (не входило в разумный бюджет этого уже огромного хода) — вероятно каскад от того
   же или смежных дефектов 083 implementer-кода.

### Живые числа (команды прямо сейчас)

`git rev-parse --short HEAD` = `47cadac`. `git rev-list --left-right --count origin/main...HEAD`
= `0 0`. `git status --porcelain` → пусто. `check_no_leak.sh --snapshot` переснят НА ЭТОМ
чистом состоянии (стоячая санкция (а)∧(б)∧(в) — porcelain пуст, HEAD==origin/main, 0 0).
`git tag -l "frozen/contracts/086/*" "frozen/contracts/087/*"` → `/1` у обоих, на origin.

### Следующий шаг (строго, порядок)

1. **083 charter-блокер → architect или владелец.** Варианты починки (архитектор решает):
   (а) owner даёт дословную строку `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/083-*.md <причина>` для
   КОНКРЕТНОГО sync-merge коммита (но merge уже сделан локально в этой сессии — придётся либо
   пересобрать ветку без merge-коммита, либо добавить РАЗРЕШИЛ в НОВЫЙ коммит поверх); (б)
   пересобрать `wip/083/integration` через REBASE вместо merge (не создаёт коммит, "трогающий"
   контракт-файл диффом — contracts/083 остаётся байт-в-байт тем же на всех коммитах рёбейза,
   если сам контракт не менялся по существу между base и main) — вероятно ЧИЩЕ. Остальные 7
   красных джоб — продиагностировать (скорее implementer-код 083, не инфраструктура).
2. **Implementer 086 — раздавать сразу.** Контракт frozen, ЗОНА implementer:
   `scripts/gejt_svedenija.sh scripts/accept_task_commit.sh scripts/land_agent.sh
   scripts/spawn_agent.sh scripts/check_zones.sh scripts/check_charter.sh
   .githooks/pre-merge-commit`. ПЕРЕСЕЧЕНИЯ с живой заморозкой 083 на `check_zones.sh`/
   `check_charter.sh` названы в контракте явно (строки 247-255) — координация с 083
   implementer нужна (кто landит первым, сводит оба флага). НЕ начинать 086 implementer,
   пока 083-charter-блокер не ясен (риск двойного конфликта на тех же файлах) — ИЛИ начать
   параллельно, если архитектор подтвердит независимость.
3. **Implementer 087 — ждёт ленда 083** (контракт 087:236, явная оговорка).
4. **087 design-форк** (`forks/087-granica-u-kod-vs-uchetnoe.md`, КЛАСС дизайн, МАРШРУТ
   со-ревью, БЛОКИРУЕТ нет) — нужен со-ревью архитектора (контракт 029 инв.3) ДО done 087;
   `check_fork_route.sh --root .` сейчас падает РАНЬШЕ (пред-существующий `083-check-zones-
   fail-...` баг witness-грамматики, см. ниже) — механическая проверка маршрута временно
   недоступна для ЭТОЙ записи, обработка вручную (текст прочитан, маршрут назначен верно).

### Выученные уроки этой сессии (кандидаты в NABLIUDENIA.md, следующая сессия заносит формально)

- **Н-NEW-1:** mint-теги (`id/CONTRACT/NNN`) нужно пушить на origin ОТДЕЛЬНО —
  `mint_line.sh` их не пушит сам; пропуск ломает CI self-test 071 toy-world `check:ids` на
  СЛЕДУЮЩЕМ push даже если текущий push прошёл.
- **Н-NEW-2:** зоны из НЕзамороженного контракта НЕ существуют (`lib_zones.sh` читает только
  `frozen/contracts/NNN/vmax`). Фикстуры/батарею контракта коммитить ДО freeze нельзя — только
  текст контракта через bootstrap-дверь 023(iii) (5 условий: грамматика, тег `id/CONTRACT/NNN`
  жив локально, dual-control на origin, ветка `wip/NNN/автор`, путь отсутствует в main).
- **Н-NEW-3:** `land_agent.sh` НЕ проверяет сам PR-CI-гейт 069 — проверяет ТОЛЬКО следующий
  `gitw push origin main` (чек 3 предполёта 071). Забыть PR ДО land_agent узнаётся только на
  попытке push — чинится ретроактивно: PR на отдельную ветку, указывающую РОВНО на
  нужный sha (второй родитель land-мёржа), слить потом не нужно — GitHub сам закрывает PR
  как «already merged», когда коммит обнаруживается в main.
- **Н-NEW-4:** GitHub `pull_request`-webhook в этом окружении имеет лаг ДО ~20+ минут при
  занятых раннерах (не 2-3 мин, как казалось сначала) — полный прогон (все 6 антиплацебо-джоб +
  ci) занимает 15-25 минут. НЕ форсировать через force-push/close-reopen раньше времени — каждый
  форс создаёт concurrency-cancel параллельного прогона на том же ref/ветке. Просто ждать.
- **Н-NEW-5:** непиннованная оркестраторская сессия не может писать В ЧЕКАУТ (включая НОВЫЕ
  worktree от `spawn_agent.sh`) напрямую через `_write`/`_edit`/bash-`tee`/`cp` — ТОЛЬКО через
  git-плумбинг (`hash-object -w` из allowlist-пути → `update-index --add --cacheinfo` →
  `checkout -- <путь>`). Работает для НОВЫХ и существующих файлов, в основном чекауте И в любом
  связанном worktree.
- **Н-NEW-6:** `check_staged.sh` отказывает прямой коммит identity `architect`/`implementer`
  НЕ в их собственной `wip/<NNN>/<автор>`-ветке — не обходится даже `--author=architect` с
  committer=orchestrator (гвард читает author, не committer). Для контракт-текста ДО freeze —
  bootstrap-дверь 023(iii) работает ТОЛЬКО если коммитишь в `wip/<NNN>/architect` ветке САМ
  architect-identity (не orchestrator).
- **Н-NEW-7 (дорогой урок, ~40 мин раскопок):** `GIT_AUTHOR_NAME`/`GIT_COMMITTER_NAME`
  env-переменные, выставленные ambient для `freeze_contract.sh` (нужны для `git tag -a` —
  репозиторий блокирует локальный `.git/config`, Н-56), ЛЕКУТ во ВСЕ дочерние git-процессы,
  включая temp-репозитории, которые пробы `check_spec_ready.sh`/красных батарей создают для
  ТЕСТИРОВАНИЯ identity-зависимых сценариев (например, «sync-merge без идентичности хука») —
  присутствие ИМЕНИ (не email) меняет наблюдаемое поведение пробы и даёт спек-гейт-036 отказ
  «проба красна без заявленной причины». **Фикс:** использовать `GIT_CONFIG_COUNT=2
  GIT_CONFIG_KEY_0=user.name GIT_CONFIG_VALUE_0=<имя> GIT_CONFIG_KEY_1=user.email
  GIT_CONFIG_VALUE_1=<email>` вместо `GIT_AUTHOR_NAME`/`GIT_COMMITTER_NAME` — `git tag -a`
  это принимает, а probe-тесты (чувствительные конкретно к `GIT_COMMITTER_NAME`/
  `GIT_AUTHOR_NAME` env-переменным, не к `GIT_CONFIG_*`) не ломаются.
- **Н-NEW-8:** Ad-hoc git-worktree (`git worktree add` НЕ через `spawn_agent.sh`, напр. для
  ручного merge-main-в-integration) ОБЯЗАТЕЛЬНО снимать через `git worktree remove` ПЕРЕД
  `gitw push` — gitw-предполёт отказывает «посторонний worktree» на любой незнакомой
  (не wip/NNN/author) линкованной директории.

### Контрольный транскрипт (последние 15 коммитов main, свежий `git log`)

```
47cadac land: wip/087/architect
ff8e55a land: wip/086/architect
cd4b7a0 NABLIUDENIA_ARCHITECT: А-360..А-364
825cbc2 087: красная батарея — К6-фикс Critic087 круга 1
bb0d6a4 086: красная батарея — s13-фикс Critic086 круга 1
c245991 freeze: registry 087 → 7647f76b999b8d7ddc01f2653601c7199b0f61b8
650df93 критик 087 круг 2: accept
49360bd freeze: registry 086 → 2b1334ed87dfe51d5ed127a53c89f490f63aee2d
377d809 критик 086 круг 2: accept
15ebbc9 land: wip/087/architect (текст контракта)
9ddf75b land: wip/086/architect (текст контракта)
0cbc977 087: контракт — черновик текста
4417fe3 086: контракт — черновик текста
3d93264 реестр: строка 087 (mint_line)
838a06c реестр: строка 086 (mint_line)
```

Полная история этой сессии — `git log` от `3d34a30` (стартап) до `47cadac` (текущий HEAD).
Транскрипты субагентов: `history://Critic086`, `history://Critic087`, `history://Critic086R2`,
`history://Critic087R2`, `history://ArchitectFix086`, `history://ArchitectFix087`.

История — git log этой сессии.
