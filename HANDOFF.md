## ГДЕ МЫ (2026-10-06, ~14:00 UTC — автоперезапуск по контексту >600K. 083 v3 ЗАМОРОЖЕН
(frozen/contracts/083/3). Push-процедура ИДЁТ по словам владельца ниже, застряла на
check:ids FAIL — именная коллизия в verdicts/consultant/, НЕ воля владельца, чинить
сразу. НЕ push'ить, пока все перечисленные проверки не зелёные.)

- Серверная обвязка станции — единый источник: ops/server/README.md (инвентарь механизмов, установка, настройка).

### Слово владельца 2026-10-06 ~13:45 UTC (передано консультантом) — ДОСЛОВНО, порядок в силе

ФАКТ (сверено консультантом): закрытие PR#30/#31 НЕ снимет отказ — gitw_preflight_071.sh:350-373
для каждого `land:`-коммита в диапазоне ищет успешный pull_request-прогон по head_sha
второго родителя ленда. Ленды 9bfbfd6 (p=ffc67552, run 37361468235 failure) и b984399
(p=d69a3bc2, run 37367941521 failure) красные НАВСЕГДА по истории. PR НЕ закрывать.

**СТРОКА 1** (уже ИСПОЛЬЗОВАНА — freeze 083/3 сделан этой строкой, см. ниже):

    РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/083-ci-a-parallelnye-dzhoby-generator-shagov.md — заморозка
    v3 поверх 6 кругов критика (v1/v2/v3 исторические; v4/v5/v6 — три узких круга
    2026-10-06 по санкционированной zone-expansion-дельте, конвергенция разных находок,
    не спор; critic accept в v6, verdicts/critic/contracts-083-v6.md); арбитр не нужен;
    слово владельца 2026-10-06.

**СТРОКА 2** (ЕЩЁ НЕ использована — дословно первой колонкой тела ОРКЕСТРАТОРСКОГО
коммита НЕПОСРЕДСТВЕННО ПЕРЕД push, транскрипт проверок — в тело того же коммита):

    РАЗРЕШИЛ-ВЛАДЕЛЕЦ: разовый push origin main мимо проверки «land без зелёного PR-CI»
    предполёта gitw (071) для ленд-коммитов wip/083/architect 9bfbfd6 и b984399 (PR-CI их
    вершин ffc6755/d69a3bc красный: самотест 071 и «Зоны исполнителей»; причина зон
    устранена 083 v3 и grandfather 2c01b1e); до push зелёные: четыре npm-проверки
    предполёта, check_zones, check_charter; детектор до и после; main CI после push
    сверяется по --json по каждому job; слово владельца 2026-10-06.

**ПОРЯДОК (строго):**
1. freeze 083/3 (строка 1) → в ОДНОРАЗОВОМ КЛОНЕ локального main: `npm run check:nabludenia
   && npm run check:ci-parity && npm run check:ceilings && npm run check:ids` (четыре
   ключа предполёта), `bash scripts/check_zones.sh`, `bash scripts/check_charter.sh .` —
   ВСЕ rc 0. Любой rc≠0 → СТОП, push НЕ делать, доклад.
2. Коммит со строкой 2 и транскриптом → `bash scripts/check_no_leak.sh --check <корень>`
   → разовый `git push origin main` (ТОЛЬКО main, ТОЛЬКО этот раз; теги
   frozen/084,frozen/085,frozen/083/3 — тем же разом или следом через gitw) → детектор
   после → `gh run view <id> --json jobs` по каждому job main.
3. Если main CI красный на самотесте 071 — первая починка, раньше всего. Иначе — коммит
   086/087 (dual-control пройдёт) → критик → freeze → implementer; параллельно 083 к
   ленду (впредь ленд ТОЛЬКО после зелёного PR-CI вершины ветки — ночной раздел роли).
4. Н-запись: ленды 9bfbfd6/b984399 без зелёного PR-CI (рецидив Н-185) → 66 коммитов не
   пушились ~5 ч.
Все остальные push — только через gitw, как прежде.

### ТОЧНОЕ состояние шага 1 (живыми командами)

`frozen/contracts/083/3` ПОСТАВЛЕН (строкой 1, см. выше) — `git tag -l
"frozen/contracts/083/*"` → `/1 /2 /3`. В одноразовом клоне `/tmp/dev-harness-verify/
preflight-083-clone` (создан `git clone` ЛОКАЛЬНОГО /home/harness/dev-harness, HEAD
`2129aca`):
- `npm run check:nabludenia` → rc 0.
- `npm run check:ci-parity` → rc 0.
- `npm run check:ceilings` → rc 0.
- `npm run check:ids` → **rc 1, FAIL**. Причина: 4 файла в `verdicts/consultant/`
  начинаются с ГОЛОГО `083-` (три цифры + дефис), барьер трактует это как
  mint-номерованный VERDICT-артефакт класса VERDICT (grammar `scripts/check_ids.sh:34-62`)
  и требует тег `id/VERDICT/083`, которого нет — «номер 83 назначен рукой, а не
  механизмом» ×4 + «одинаковый номер 83 в классе VERDICT» ×3 (попарно). Файлы:
  `083-kap-krugov-freeze-6-verdiktov-klass-v1.md`,
  `083-spaseno-gate036-nikogda-ne-zonnyj-put-v1.md`,
  `083-charter-merge-false-positive-v1.md`,
  `083-check-zones-fail-dokfail-owner-i-055-grammar-klass-v1.md` (ПОСЛЕДНИЙ — НЕ мой,
  пред-существующий с прошлой сессии 2026-10-05; остальные три — мои, этой сессии).
  Ещё НЕ прогнаны (после фикса имён): check_zones.sh, check_charter.sh.

**ДИАГНОЗ (инженерный, не воля владельца):** форк-записи для консультанта по конвенции
роли называются `verdicts/consultant/<fork-id>-v<N>.md`, где `<fork-id>` часто ссылается
на номер контракта — но установленный ЖИВОЙ ПРЕЦЕДЕНТ (`verdicts/consultant/
fork-082-provodka-sanktsija-nedostatochna-v1.md`, уже в дереве) префиксует такие имена
словом `fork-`, ИМЕННО чтобы не попадать под голую `NNN-`-грамматику check_ids. Я (эта
сессия) создал 3 новых файла БЕЗ этого префикса — моя ошибка; 4-й файл (055-grammar)
пред-существующий, та же ошибка прошлой сессии, не пойманная раньше (возможно, check:ids
не гонялся в одноразовом клоне до этой попытки push).

### Следующий шаг (строго, для следующей сессии — НЕ ждать владельца, это инженерный фикс)

1. `git mv` все 4 файла в `verdicts/consultant/`, добавив префикс `fork-` (матчит
   прецедент `fork-082-provodka-sanktsija-nedostatochna-v1.md`):
   `fork-083-kap-krugov-freeze-6-verdiktov-klass-v1.md`,
   `fork-083-spaseno-gate036-nikogda-ne-zonnyj-put-v1.md`,
   `fork-083-charter-merge-false-positive-v1.md`,
   `fork-083-check-zones-fail-dokfail-owner-i-055-grammar-klass-v1.md`. Коммит под
   identity `consultant` (зона verdicts/consultant/), с строкой
   `ALLOW-ARTIFACT-DELETE: <старый путь> <причина — переименование под грамматику
   check_ids, прецедент fork-082>` для КАЖДОГО старого пути первой колонкой тела
   (Н-69-класс, см. Гигиена задания п.5 в этом же файле роли оркестратора).
2. Живым прогоном (тот же одноразовый клон либо свежий) перепроверить
   `npm run check:ids` → ожидается rc 0.
3. Если rc 0 — продолжить ПОРЯДОК (см. выше) с шага 1: `bash scripts/check_zones.sh` и
   `bash scripts/check_charter.sh .` в клоне (оба ожидаются rc 0, но ОБЯЗАТЕЛЬНО
   перепроверить живьём — не предполагать). Если rc 0 у всех шести — переходить к шагу 2
   порядка (коммит со СТРОКОЙ 2 + push).
4. Push origin main — ТОЛЬКО main, ровно один раз, строго по шагу 2 порядка выше
   (check_no_leak до и после, gh run view по каждому job).

### Контракты 086/087 — готовы, содержимое НЕ потеряно

Оба спроектированы architect (ClearParrot — 086 «гейты сведения»; IntellectualEarwig —
087 «CI-Б классификатор»), красные батареи + честные симуляции реализации пройдены. НЕ
закоммичены штатно (dual-control на registry-строке требовал push main). Содержимое лежит
НЕЗАКОММИЧЕННЫМ в рабочем дереве `/home/harness/dev-harness` (untracked):
`contracts/086-gejty-svedenija-integracii.md`, `contracts/087-ci-b-klassy-izmenenij-hesh-koda.md`,
`fixtures/_krasnye_086.sh`, `fixtures/_krasnye_087.sh`, `fixtures/gejty_svedenija_086/`,
`fixtures/ci_b_087/`, `fixtures/parsing_hygiene_battery/profiles/{gejt_svedenija,ci_klass}.sh`;
модифицирован `NABLIUDENIA_ARCHITECT.md` (А-360..А-362). После push main (шаг 2 порядка)
dual-control пройдёт — коммитить под identity architect, затем критик → freeze →
implementer (087 implementer — ТОЛЬКО после ленда 083, см. контракт).

087 несёт design-вопрос К ВЛАДЕЛЬЦУ (не блокирует freeze): граница «код vs учётное» для
contracts/plans/AGENTS.md/forks/.review/ROADMAP.md шире первоначального предложения —
детали в `agent://IntellectualEarwig` транскрипте (поле `design_choices_needing_attention`).

### Точное состояние (живыми командами на момент записи)

`git rev-parse --short HEAD` = `2129aca`. `git status --porcelain` → 9 путей (086/087
содержимое, untracked/modified, см. выше). Живых субагентов нет. `frozen/contracts/083/3`
стоит. check:ids красный (см. выше) — push НЕ делался, НЕ будет делаться до зелёного.

История — git log этой сессии.
