accept
OBJECT=e29b50efe33cb96080f7218fef92fc3d62b8ca30
СУД: репо=dev-harness; предмет=205; роль=reviewer; вызов=1 (полный); фаза=реализация; модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5 (метаданные среды выполнения судьи: Model anthropic/claude-opus-5-5; `bash scripts/models_actual.sh --tsv --bind --session Rev205 | cut -f1-3` → `reviewer	anthropic/claude-opus-5-5	allowed`, rc 0); предыдущий=нет; класс риска=обычный
КЛАСС=КОДОВЫЙ. Блоков 0. Совет 1 (С-1) — в `.review/2026-11-23-156.md`. Класс риска не повышаю: дифф касается только двери проводки, права, деньги и ПД не затронуты.

# Вердикт reviewer — 205, реализация, вызов 1 (полный)

**Итог.** accept. Четвёртая локация `guard_is_wired` (`scripts/check_provodka.sh:485-521`) выполняет И1–И7 на достижимых входах. Батарея судит production через `--repo`, ожидания — литералы probe.py: 24/24/0. До реализации тот же раннер на двери базы краснел 24/15/9 (замер свой). Три собственные мутации production красятся `--repo` с rc 1. Регресс семьи 038/994 зелёный, CI-строка подключена.

## Область

```
pwd → /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t216aacfea/m
git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/205/orchestrator-r7 → rc 0
git switch --detach e29b50efe…; git rev-parse HEAD → e29b50efe33cb96080f7218fef92fc3d62b8ca30
git diff --stat a6c4db608d731a52f63294e1fb94766b7b651e56 e29b50efe →
  .github/workflows/ci.yml                         | 12 +++----
  fixtures/workshop_project/provodka_gate_205/SDACHA.md | 5 +--
  registry/ci-steps.tsv                            |  1 +
  registry/ci-zamery.tsv                           |  1 +
  scripts/check_provodka.sh                        | 37 ++++
  5 files changed, 48 insertions(+), 8 deletions(-)
git log --format='%h %an|%cn' a6c4db608..e29b50efe →
  e29b50efe orchestrator|orchestrator   (.github/workflows/ci.yml registry/ci-steps.tsv registry/ci-zamery.tsv)
  4b4220faf architect|orchestrator      (fixtures/workshop_project/provodka_gate_205/SDACHA.md)
  07eb8098a implementer|orchestrator    (scripts/check_provodka.sh)
git diff --exit-code 'frozen/contracts/205/1^{commit}' e29b50efe -- contracts/205-provodka-gate-profilja.md → rc 0
git diff --stat 'frozen/contracts/205/1^{commit}' e29b50efe -- fixtures/workshop_project/provodka_gate_205 scripts/profile_resolver.sh
  → только SDACHA.md (3+/2-); probe.py, stabs.tsv, model/, profile_resolver.sh не тронуты
```

- **Зоны.** Каждый файл каждого коммита лежит в зоне автора этого коммита (`git diff-tree --name-only`, по коммиту): implementer → `scripts/check_provodka.sh`; architect → `fixtures/workshop_project/provodka_gate_205/`; orchestrator → `registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml`. Превышения нет.
- **Атомарность.** Три коммита, три роли, каждый ссылается на 205 и не несёт чужих задач.
- **Норма.** Контракт после freeze не менялся (rc 0). `roles/`, `AGENTS.md` и нормативные документы диффом не тронуты.
- **Проверка не подогнана под реализацию.** implementer фикстур не трогал. architect после реализации поменял в сдаточном листе одну строку двери: «красное-до … · 1 · 1» → «реальная-дверь … · 0 · 0». Исторический замер ДО (rc 1, 24/15/9) сохранён строкой рядом. Ожидания клеток и оракул не менялись.
- **ci.yml.** Изменения — производная генератора. `bash scripts/gen_ci_steps.sh --check` → rc 0. Своя мера: python по строкам `keys:` lanes. На базе 166 ключей (166 уникальных), на OBJECT 167 (167 уникальных). Добавлен `['check:provodka-gate-205-family-selftest']`, удалённых нет. Перестановка ключей по lanes — перебалансировка весов генератором, чужая проводка сохранена (ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml).
- **Реестры.** `registry/ci-steps.tsv` получил ровно одну новую строку (вес 18, команда `--repo . && --model && --stabs`). `registry/ci-zamery.tsv` получил одну строку: 18/16/0.

## Сверка с предметом

Код — `scripts/check_provodka.sh:485-521` на OBJECT.

- **И1 — токен gate, литерально.**
  - Источник — эффективный профиль резолвера (`:500`, `HARNESS_PROJECT_LAYER_ROOT="$root" bash "$SELF_DIR/profile_resolver.sh" --repo "$root"`). Слоёв дверь сама не парсит. jq по выходу резолвера только извлекает `.sourceCanon.value.gate[]` (`:520`), грамматики не дублирует.
  - Сравнение: целый токен `= "$guard"` (`:516`) либо суффикс `"/$guard"` через подстроку `${tok:…}` (`:506,517`). Это bash-строковое `=` внутри `[ ]`, без `[[ ]]`, regex и glob, чувствительное к регистру.
  - Разделитель — NUL: `jq -j … + "\u0000"` и `read -r -d ''` (`:514,520`). LF внутри элемента сохраняется — подтверждено клетками a6/a6c и моей мутацией M3.
- **И2 — порядок локаций.** Четвёртая локация опрашивается под `[ "$found" -eq 0 ] && [ -f "$root/harness.project.json" ]` (`:498`), после трёх прежних. Прежние локации диффом не тронуты: diff +37/-0, всё внутри одного hunk. Без `harness.project.json` блок не входит — байт-в-байт прежнее поведение (b3, f1–f3).
- **И3 — нераспознанный профиль.** rc резолвера ≠ 0 → `die "проводка: профиль проекта не распознан: $prof_reason"` (`:501-504`, `die` = stderr + exit 1, `:156`). Причина — первая строка вывода без префикса `profile ОТКАЗ: `. Клетки e1/e2/e3 дают полную строку: «файл не JSON: …», «нет файла слоя проекта: …», «SOURCE_CANON_INVALID: …». Канона нет (`has("sourceCanon")` false) → jq пуст, локация молчит. Новых rc 2 нет. Свой контроль: ключ вне алфавита (`zzUnknownKey`) при валидном gate → дверь rc 0. Предупреждение резолвера в слитый канал `2>&1` не попадает (`channels_merged`, `profile_resolver.sh:267,302`), JSON не ломается.
- **И4 — двойники.** `xred_…` (c1), `…-old` (c2), `.bak` (a7), регистр (a8), имя в `sources[].path` (c3), LF-двойники (a6, a6c) — rc 1 со старой фразой. Сравнение идёт только с элементами `gate`.
- **И5 — существование прежде подключения.** Блок внутри `guard_is_wired`, порядок г-кругов не тронут. d1 → «guard-файл не существует».
- **И6 — фразы и режимы.** `:669` «проводка: guard не подключён: $guard не вызывается в .githooks/ или .github/workflows/» не в диффе, байт-в-байт прежняя. Новая фраза одна (`:504`). `--grammar` не тронут, дифф вне его ветви.
- **И7 — оговорка 994.** Вызов `guard_is_wired` по-прежнему под `matches_external_exception` (`:667-669`, не в диффе). Батарея 994 EXTERNAL_991/993 → rc 0.
- **Модельный паритет.** `diff -u scripts/check_provodka.sh fixtures/workshop_project/provodka_gate_205/model/check_provodka_model.sh` → пусто, rc 0: дверь байт-в-байт равна модели, включая шапку-комментарий блока. Контракт п.8 допускает разницу «только шапка», ноль — подмножество. Подгонки под модель нет:
  - модель не менялась с freeze;
  - `--repo` судит `root/scripts/check_provodka.sh` (`probe.py:452`), а не модель;
  - ожидания — литералы `old_refusal`/`new_refusal`/`exp_ok` (`probe.py:41-46,103-109`), до вызова субъекта; текст двери оракул не читает;
  - модель читается только в `--model/--stabs/--attack` (`probe.py:375,361`).
- **sourceCanon (996).** Станция `sourceCanon` не объявляет (`HARNESS_PROJECT_LAYER_ROOT="$PWD" bash scripts/profile_resolver.sh --repo "$PWD"` → rc 0, `has("sourceCanon")` = false). Сверка карты источников и gate к этому дереву неприменимы.
- **ПРОВОДКА (038).** Единственный канал — guard `fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh`. Он существует и подключён строкой `registry/ci-steps.tsv` (третья локация). Это барьер именно этого предмета: батарея 205, а не произвольный скрипт дерева. Полный `check_provodka` → rc 0. Строка ПРОВОДКА-ЭНФОРСМЕНТ обоснована честно: 205 чинит энфорсмент двери 038 и поведенческой нормы ролей не вводит, role-канал не требуется.

СВЕРКА-СТАНДАРТОВ: `AGENTS.md` станции документов архитектуры и стандарта кода не объявляет (grep `ARCHITECTURE|CODING-STANDARDS` по AGENTS.md → нет совпадений). Строка неприменима к разделам. По форме модуля: блок следует приёму 083 (локация внутри `guard_is_wired`, общий флаг `found`, без новой функции и флагов CLI), `die` переиспользован — соответствует.
СВЕРКА-АРХИТЕКТУРЫ:
- Размещение — внутри существующей функции двери 038, зона implementer. Новых файлов кода нет.
- Зависимости — `scripts/profile_resolver.sh` (единый источник 996, уже зависимость пары pre_critic/done) и `jq` (предпосылка контракта).
- Писателей и операций с состоянием нет: блок только читает профиль.
- `bindings.json` и модели архитектуры 188 (`tooling/checks/cli.js`) в дереве нет → diff модели L0. Долг не расширен.
- Расхождений модели и работы не обнаружено, находку 188 не заводил.

Паразитная сложность (050), по артефакту диффа:
- **Блок четвёртой локации, `check_provodka.sh:485-521`.**
  - (1) Свойство И1/И3.
  - (2) Новое состояние — локальные `prof_out/prof_reason/tok/suf` в теле функции. Внешний эффект виден в rc и единственной фразе, env не читается: `HARNESS_PROJECT_LAYER_ROOT` дверь задаёт, а не читает.
  - (3) При правке свойства меняются дверь + модель + probe: столько же, сколько у прежних локаций (модель — копия двери, это заявленная форма батареи).
  - (4) Интерфейс не вырос: аргументов, флагов и кодов возврата не добавлено.
  - (5) Потребитель — приёмка п.1/8 и CI-шаг. Грамматику профиля не повторяет: делегирует резолверу.
  - ESSENTIAL: Frontier 1/2 (более простые формы) отвергнуты клетками c1/c2/e1–e3 и a2/e3.
- **CI-строка `check:provodka-gate-205-family-selftest` и её замер.**
  - (1) П.8 и ПРОВОДКА.
  - (2) Состояние явное: строка реестра.
  - (3) При правке меняются 2 файла (`ci-steps`/`ci-zamery`), плюс производный ci.yml.
  - (4) Интерфейс не меняется.
  - (5) Потребитель — `run_ci_lane.sh`/`gen_ci_steps.sh`.
  - ESSENTIAL.
- **Правка строки двери в SDACHA.md.**
  - (1) П.8 (состояние после реализации).
  - (2)–(4) Новых артефактов нет, правка данных.
  - (5) Потребитель — `check_sdacha --run`.
  - ESSENTIAL.

## Проверки

Каждая команда — отдельно, cwd = копия, `TMPDIR=/tmp/dev-harness-verify/scratch-rev205`, `VALIDATE_STD_SHELLCHECK=…/shellcheck/0.11.0/shellcheck`.

| Команда | rc | Вывод |
|---|---|---|
| `bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --repo .` | 0 | `KLETKI=24 ZELENYE=24 KRASNYE=0`, `REPO …/m/scripts/check_provodka.sh` |
| `… --model` | 0 | `KLETKI=24 ZELENYE=24 KRASNYE=0` |
| `… --stabs` | 0 | `HONEST_CONTROLS=27 ZELENYE=27 KRASNYE=0`, `MUTACII=21 SVJAZI=27 POIMANY=25 EKVIVALENT=2 ZHIVYH=0`; все `exact: true` |
| красное-до (своё): одноразовый клон, `git checkout a6c4db608 -- scripts/check_provodka.sh`, `… --repo <клон>` | 1 | `KLETKI=24 ZELENYE=15 KRASNYE=9`; красные a1,a2,a3,a4,a5,a6b,e1,e2,e3 — ровно список п.1; затем откат на e29b50efe, `status` чист |
| M1 (своя), клон: суффикс-ветка `:517` → `if false; then` | 1 | `KRASNYE=1`: a3-absoljutnyj-token (rc 1 ≠ 0); откат |
| M1b (своя), клон: `:506` `suf="/$guard"` → `suf="$guard"` | 1 | `KRASNYE=1`: a6-lf-vnutri-tokena (rc 0 ≠ 1) — см. С-1; откат |
| M2 (своя), клон: регистронезависимое сравнение (`${tok,,}`/`${guard,,}` в `:516`, lower-суффикс в `:517`) | 1 | `KRASNYE=1`: a8-registr (rc 0 ≠ 1); откат |
| M3 (своя), клон: граница argv потеряна (`read -r -d ''` → `read -r`, `jq -j … "\u0000"` → `jq -r … gate[]?`) | 1 | `KRASNYE=2`: a6-lf-vnutri-tokena, a6c-lf-posle-guarda (rc 0 ≠ 1); откат |
| `bash -n scripts/check_provodka.sh` | 0 | — |
| shellcheck 0.11.0 `-S warning scripts/check_provodka.sh` | 0 | 0 находок |
| shellcheck 0.11.0 `-S warning` на `git show a6c4db608:scripts/check_provodka.sh` | 1 | 1 находка (SC2034 SELF_DIR unused, `:154`); на OBJECT находок меньше: SELF_DIR теперь используется (`:500`) |
| `bash fixtures/check_provodka/external_ci_994/probe.sh` | 0 | `CASES executed=76 mismatches=0`, `LEGACY executed=18 mismatches=0`; MODEL-мутанты valid=1, SELF REGISTRY_ONLY/WITHOUT_OWN_STEP matched |
| `bash fixtures/check_provodka/red_R4_guard_osirotel.sh` | 0 | «R4: отказ rc 1, причина названа дословно» |
| `bash fixtures/check_provodka/case_27_guard_ere_metachars.sh` | 0 | «case_27: rc 0 на позитив-контролях, rc 1 на форжах» |
| `bash scripts/check_provodka.sh . contracts/205-provodka-gate-profilja.md` | 0 | пусто |
| `HARNESS_PROJECT_LAYER_ROOT="$PWD" bash scripts/profile_resolver.sh --repo "$PWD"` | 0 | keys без `sourceCanon` (`has("sourceCanon")` → false) |
| своя проба: мир с `zzUnknownKey` + валидный gate, `bash scripts/check_provodka.sh <мир> contracts/001-x.md` | 0 | пусто (резолвер отдельно: rc 0, предупреждение на stderr) |
| `bash scripts/pre_critic.sh contracts/205-provodka-gate-profilja.md` | 0 | «ok … сдаточный лист красен / КРИТИК: дверь зелёная» |
| `bash scripts/check_sdacha.sh "$PWD" contracts/205-provodka-gate-profilja.md --run` | 0 | «СДАЧА: лист зелёный (двери=14 карта=17/17 дельта=6)», real 1m24.7s (≤900 с) |
| `bash scripts/gen_ci_steps.sh --check` | 0 | — |

Каждый мутант прогонялся в одноразовом клоне `/tmp/dev-harness-verify/scratch-rev205/clone` с собственным `.git`, по одному. После каждого — `git checkout -- scripts/check_provodka.sh` и пустой `git status --short`. Клон удалён до доклада.

## Блоки

Нет. Доказанного нарушения обязательства контракта на достижимом состоянии не найдено.

## НЕ ЗАЩИЩАЕТ

Строки остатка контракта (§Модель угроз, НЕ ЗАЩИЩАЕТ). Номеров К-NN у них нет, нумерую НЗ-1..4 по порядку.
- ОСТАТОК: НЗ-2 (слой проекта вне судимого корня, ловец — ревьюер проводки проекта) — не укусил. Дверь детерминированно задаёт `HARNESS_PROJECT_LAYER_ROOT="$root"` (`scripts/check_provodka.sh:500`), живой внешний `HARNESS_PROJECT_LAYER_ROOT` резолверу не доходит. Слой вне корня не судится — заявленная граница.
- НЗ-1 (правдивость самого gate — 996), НЗ-3 (злонамеренный владелец профиля), НЗ-4 (sourced-исполнение — арбитраж 038 §3): ловец не reviewer. Дифф их не расширяет: блок только читает профиль и gate не исполняет.

## Советы

- С-1 (architect) — `.review/2026-11-23-156.md`. Граница сегмента `/` в правиле суффикса И1 держится только LF-клеткой a6, отдельной клетки двойника-префикса сегмента (`xscripts/red_gate_205.sh`) нет. Мутант M1b ловится, поэтому это не блок.
