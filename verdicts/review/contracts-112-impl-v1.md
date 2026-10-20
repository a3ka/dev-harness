FAIL
Ревьюер Rev112, контракт 112 (frozen/contracts/112/2), OBJECT=61260217cf1531ac4231bda337c1a30047da98a9 (ветка wip/112/implementer, база main 0868cc67f). Зона и CI-проводка чисты, батарея 37/37 зелёная, но `scripts/check_project_connection.sh` выдаёт rc 0 на дефектных профилях в ветви `komandy`: три обхода названы ниже (F1 — ослабление относительно модели-эталона, F2/F3 — нарушение контракта, общее с моделью). Батарея 37/37 на этих входах остаётся зелёной — это и есть ответ на (д).

---
status: ready
object: 61260217cf1531ac4231bda337c1a30047da98a9
contract: frozen/contracts/112/2
reviewer: Rev112 (anthropic/claude-opus-5-5)
date: 2026-10-20
---

## Блокирующие находки (ОБХОД: rc 0 при дефектном профиле)

- [ ] **F1 [ОБХОД, расхождение с моделью и контрактом] абсолютные пути в `komandy` принимаются.**
  Фрагмент: `scripts/check_project_connection.sh:162-165` (`/*) target="$file" ;;  # абсолютный — принимаем`) и `:183-185` (`--prefix` `/*) dir="$dnext"`).
  Контракт §Конструкция, `komandy`: «семейство `node|python3 <файл>` → файл есть в дереве»; `npm [--prefix D] run <s>|test` → скрипт в `D/package.json` в дереве. Модель-эталон (`model_check_connection.sh:80,89`) всегда склеивает `$R/…` и отказывает.
  Вход (мир mob из батареи, одна мутация):
  `commands.lint="node /etc/hostname"` → impl rc=0, model rc=1;
  `commands.lint="node <вне репо>/evil.js"` → impl rc=0, model rc=1;
  `commands.test="npm --prefix <вне репо>/pkg test"` (чужой package.json со `"test":"echo fake"`) → impl rc=0, model rc=1.
  Реализация намеренно слабее эталона: профиль внешнего репо (недоверенный ввод) объявляет команду над файлом вне дерева, а проверка подключения отвечает «структурно цело».

- [ ] **F2 [ОБХОД, нарушение контракта; модель разделяет дефект] `..`-побег в `komandy` не канонизируется.**
  Фрагмент: `:164` `target="$R/$file"` и `:185` `dir="$R/$dnext"`: путь не проходит `cd && pwd -P` + проверку префикса, хотя для workflowPaths та же форма реализована (`check_inside_dir`).
  Вход: `commands.lint="node ../outside/evil.js"` → impl rc=0 (model rc=0); `commands.test="npm --prefix ../outside/pkg test"` → impl rc=0 (model rc=0). Контракт: «файл есть в дереве», модель угроз: «от … нереальных команд (скрипта нет в package.json, файла нет в дереве)». Модель тоже даёт rc 0, поэтому замороженная батарея этого не ловит. Реализация судится по контракту, а не по копии модели (задание, п. в).

- [ ] **F3 [ОБХОД, нарушение контракта; модель разделяет дефект] закрытая форма семейства npm не проверяется: хвост и голое имя проходят.**
  Фрагмент: `:192-199`: после извлечения имени скрипта остальные токены игнорируются; `*) script="$cur"` принимает `npm <имя>` без `run`.
  Контракт: «семейство `npm [--prefix D] run <s>|test` … прочие формы — отказ (закрытый набор семейств)»; модель угроз: «от пустых/маскированных (`true`) … команд».
  Вход: `commands.test="npm --prefix mobile test || true"` → impl rc=0 (model rc=0): команда замаскирована и всегда завершается успехом, а проверка подключения зелёная. `commands.lint="npm --prefix mobile lint"` → impl rc=0 (model rc=0): у npm нет такой команды, эта форма вне контракта.
  (Для сравнения: `"npm --prefix mobile test; exit 0"` отказывает только потому, что `test;` склеился в один токен. Это случайность разбиения, правило тут ни при чём.)

Все три — ветвь `komandy`, в одном файле зоны implementer. Ни один обход не требует правки батареи, чтобы его предъявить. Чтобы закрыть обходы в CI, нужна клетка батареи, а это зона architect. Оркестратору: решить, идёт ли докрутка контракта/батареи (F2/F3 воспроизводятся на модели).

## Советы (не блокируют)

- [ ] A1 `verify_antiplacebo.sh . --scope check_project_connection` → rc 1: «нет фикстур — ожидается fixtures/check_project_connection/case_*.sh». Шапка «Коды возврата:» объявляет скрипт барьером. Ключа нет в шардах ap1–ap5 (registry/ci-steps.tsv:161-165), поэтому CI это не красит. Прецедент тот же: `check_project_standard.sh` и `check_project_sources.sh` тоже без `fixtures/<key>/`. Каталог фикстур — вне зоны implementer 112.
- [ ] A2 Ложный комментарий `:104-106`, `:94` и шапка `:45-48`: там сказано «readlink -f», «pwd -P после cd разрешает ТОЛЬКО ЛИСТ». В коде используется `cd && pwd -P`, а он разрешает все звенья: D16 зелёная именно поэтому.
- [ ] A3 `toks=($v)` без `set -f`: глоб в значении команды раскрывается относительно cwd вызывающего (модель имеет тот же дефект).
- [ ] A4 Блок `:84-87` дублирует обязательные ключи, которые уже проверяет резолвер (см. 050 ниже).
- [ ] A5 (зона architect, frozen-батарея) `red_podkljuchenie_112.sh:435/446/449` вызывает несуществующую функцию `usage` («line 449: usage: command not found»). rc 2 для `--cell net-takoj-kletki` получается только через `exit "$rc"`; сообщения об использовании нет.
- [ ] A6 В `registry/ci-steps.tsv` к step-строке добавлены 3 строки `#`-комментария. Пересечение разрешает «только step-строку», но комментарии к шагам — норма файла (соседние строки 155-157) и грамматикой отбрасываются. Не выход за зону.

## (а) Область правки — чисто

`git diff --name-only base/main..HEAD` (клон, base/main=0868cc67f):
```
.github/workflows/ci.yml
package.json
registry/ci-steps.tsv
scripts/check_project_connection.sh
scripts/profile_resolver.sh
```
Совпадает с ЗОНА implementer (строка 159 frozen-блоба). Построчно:
- profile_resolver.sh: ровно `-  rust|typescript|bash) ;;` → `+  rust|typescript|bash|javascript) ;;` (строка 547), больше ничего.
- package.json: запятая у прежней последней строки и один ключ `check:podkljuchenie-112-family-selftest` = `bash fixtures/workshop_project/podklyuchenie_112/red_podkljuchenie_112.sh`.
- ci-steps.tsv: одна step-строка, вес 32, плюс 3 строки комментария (A6).
- ci.yml: 6 строк `keys:` шардов, только перераспределение. Это производная: `gen_ci_steps.sh --write` в клоне → rc 0, затем `git status --porcelain | wc -l` → 0 (байт-в-байт равна закоммиченной), `--check` → rc 0.

## (б) Неизменность frozen

`git diff --name-only base/main..HEAD -- fixtures/workshop_project/podklyuchenie_112/ contracts/ | wc -l` → 0. Коммит 61260217c — автор `implementer <implementer@dev-harness.local>`; файлы проверок и фикстур автором реализации не тронуты (п.3 роли).

## (в)/(д) Реальная проверка, а не копия

Реализация — почти дословная копия `model_check_connection.sh`: те же ветви, тот же разбор npm. Добавлено: блок `:84-87`, функция `check_inside_dir`, принятие абсолютных путей в komandy (F1 — ослабление). Литералов клеток, имён Complior, хэшей, чтения переменных батареи (`PODKLJUCHENIE_*`, `SCRATCH`) нет: grep `Complior|PODKLJUCHENIE|SCRATCH|D[0-9]+-|cell|sha|md5` → 0 совпадений. Батарея по умолчанию судит реальный путь `CHECKER="$TOOLS/scripts/check_project_connection.sh"` (батарея:59). Обходы F1–F3 при зелёной батарее 37/37 предъявлены одноразовым скриптом `/tmp/dev-harness-verify/Rev112/probe.sh` (мир mob батареи плюс одна jq-мутация, impl и model на одном входе):
```
honest                             impl rc=0 model rc=0
node-abs-outside                   impl rc=0 model rc=1
node-abs-etc                       impl rc=0 model rc=1
node-dotdot-outside                impl rc=0 model rc=0
npm-prefix-abs                     impl rc=0 model rc=1
npm-prefix-dotdot                  impl rc=0 model rc=0
npm-or-true                        impl rc=0 model rc=0
npm-semicolon-exit0                impl rc=1 model rc=1
npm-bare-script                    impl rc=0 model rc=0
npm-run-missing-name               impl rc=1 model rc=1
true-spaces                        impl rc=1 model rc=1
colon-noop                         impl rc=1 model rc=1
state-dot                          impl rc=0 model rc=0
```
Остальные ветви: profil (немедленный exit 1 по отказу резолвера), workflowPaths/state (абсолютный, `..`, симлинк-звено через `cd && pwd -P` и префикс), kanon-remote (литеральное `!=` целых строк), source-canon (абсолютный путь/отсутствие). Здесь расхождений с контрактом не найдено. source-canon `[ -f "$R/$sp" ]` без канонизации пропустит `../x`, но об этом [INFERENCE]: не проверялось, отвергает ли такой путь грамматика резолвера.

## (г) Прогоны (свои, в клоне /tmp/dev-harness-verify/Rev112/m @ 61260217c)

| команда | rc | вывод |
|---|---|---|
| `red_podkljuchenie_112.sh` | 0 | `ИТОГ 112: клеток 37, зелёных 37, красных 0, rc=0` |
| то же на базе (резолвер base, impl убран) | 1 | `ИТОГ 112: клеток 37, зелёных 19, красных 18, rc=1`: красное предъявлено |
| `--model` | 0 | `ИТОГ 112: клеток 37, зелёных 37, красных 0, rc=0` |
| `--cell net-takoj-kletki` | 2 | (с шумом `usage: command not found`, A5) |
| п.4 контрмодель D14 (sed по STATE-112, chmod +x) | 1 | `КЛЕТКА D14-state-vne-repo: ОЖИДАНИЕ rc=1 ФАКТ rc=0`: расхождение поймано |
| п.4 контрмодель D16 | 1 | `КЛЕТКА D16-state-symlink-zveno: ОЖИДАНИЕ rc=1 ФАКТ rc=0` |
| impl `--cell D14` / `--cell D16` | 0 / 0 | |
| п.6 jq package.json | 0 | `true` |
| п.6 awk ci-steps.tsv | 0 | вес 32 |
| `gen_ci_steps.sh --write` / `--check` | 0 / 0 | porcelain 0 |
| `verify_ci_parity.sh` | 0 | `расхождений: 0` |
| `run_battery.sh profile_resolver` | 0 | `итог 4/4 классов закрыто` |
| `_krasnye_054.sh` | 0 | `итог 054: rc=0` |
| `check_provodka.sh . contracts/112-podklyuchenie-proekta.md` | 0 | |
| `check_threat_model.sh . contracts/112-…md` | 0 | `ЗАЩИЩАЕТ 6, НЕ ЗАЩИЩАЕТ 4` |
| `verify_antiplacebo.sh . --scope check_project_connection` | 1 | `нет фикстур` (A1) |

Заявление implementer (37/37, `--model` 37/37, rc 2, javascript в алфавите, вес 32) подтверждено своей мерой. Из-за F1–F3 этого недостаточно.

## Паразитная сложность (050)

- `scripts/check_project_connection.sh` (новый, 224 строки). (1) Свойство — предмет 112 §Конструкция/CLI. (2) Состояние: только `itog` и stderr-строки причин; env `HARNESS_PROJECT_LAYER_ROOT` читается явно (контракт). (3) Свойство «алфавит/ветви» меняется вместе с моделью и батареей: 3 файла, диффом не выросло. (4) Интерфейс узкий (`--repo`, rc 0/1/2), работа скрыта — модуль глубокий. (5) Потребитель — батарея (строка приёмки п.1) и CI-шаг. ESSENTIAL. Внутри: блок `:84-87` — ACCIDENTAL, совет. Он дублирует проверки обязательных ключей резолвера, а более простая форма (удалить блок, как в модели) проходит те же строки приёмки: `--model` 37/37. Параметр `no_default` в `check_inside_dir` не меняет поведения для state (значение всегда не пусто из-за `// ".harness"`) — совет.
- `registry/ci-steps.tsv` step-строка, `package.json` ключ, `ci.yml` производная — ESSENTIAL (приёмка п.6).
- `profile_resolver.sh` arm `javascript` — ESSENTIAL (P1, клетка M1).
