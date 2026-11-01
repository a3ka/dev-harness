accept
OBJECT=d15d162d09ac921f4439054c4b24fbcb208cb833
СУД: repo=dev-harness; предмет=153; фаза=реализация (перед слиянием); роль=reviewer; вызов=1/1; сессия=Rev153; модель-план=audit → @opus (config/agent_models.json roles.reviewer="audit"; fallback @gpt-sol); модель-факт=anthropic/claude-opus-5-5; SHA=d15d162d09ac921f4439054c4b24fbcb208cb833; база=6da673dcd; контракт=frozen/contracts/153/1 (тег 51416d3a → bda15e0ee); исключение=нет.
Семейство: Anthropic Opus. Это вне семейства автора реализации (MiniMax) и автора контракта (Sol/OpenAI). Адверсарий работал на openai-codex/gpt-5.6-terra, так что судьи реализации стоят на двух вендорах.

# Вердикт reviewer — реализация контракта 153 «ложный отказ NUL в пути источника sourceCanon»

Итог: **accept**. Блокирующих находок нет, поэтому файла `.review/` нет. До `done` есть одно условие для оркестратора, оно описано в §5.

Клон: `/tmp/dev-harness-verify/Rev153/repo`, чекаут OBJECT. База лежит в worktree клона: `/tmp/dev-harness-verify/Rev153/base` @ 6da673dcd. С основным `.git` через GIT_DIR/GIT_WORK_TREE не работал.

## 1. Область правки — соответствует

```
$ git cat-file -t d15d162d09ac921f4439054c4b24fbcb208cb833        → commit
$ git rev-parse wip/153/implementer (основной репо)                 → d15d162d09ac921f4439054c4b24fbcb208cb833
$ git log --format='%H %an <%ae> %P' -1 OBJECT
d15d162d09ac921f4439054c4b24fbcb208cb833 implementer <implementer@dev-harness.local> 6da673dcd326091896e4077db69f55e35470080c
$ git show --numstat --format= OBJECT
0	1	scripts/check_project_sources.sh
$ git diff --name-only 6da673dcd..OBJECT
scripts/check_project_sources.sh
$ git diff 6da673dcd..OBJECT
@@ -108,7 +108,6 @@ for p in "${SOURCE_PATHS[@]}"; do
   case "$p" in
     /*) die "SOURCE_CANON_INVALID: абсолютный путь источника: $p" ;;
     *..*) die "SOURCE_CANON_INVALID: .. в пути: $p" ;;
-    *\0*) die "SOURCE_CANON_INVALID: NUL в пути: $p" ;;
   esac
```
- Удалена ровно одна строка. Других изменений нет.
- Файл точно совпадает с `ЗОНА implementer: scripts/check_project_sources.sh`.
- Автор коммита — `implementer`, коммит один, база 6da673dcd является его предком.
- ПЕРЕСЕЧЕНИЕ «996 удалить лишь ложный NUL-case» соблюдено: `-e/-f`, `readlink`, CLI и gate не тронуты.
- `profile_resolver.sh` не менялся, текст 996 не менялся. Других путей в diff нет.
- Атомарность: один коммит со ссылкой на предмет («153: … реализация по frozen/contracts/153/1»).
- Полный `scripts/check_zones.sh` (около 380 с) не гонял: ПРИЁМКА-СУДЬИ v2 разрешает scoped-проверку. Своей мерой проверил автора и путь по ЗОНА-строке замороженного контракта (выше).
- Main с базы продвинулся только вердиктом адверсария: `git diff --quiet 6da673dcd ae40d30bb -- scripts/ contracts/153-… fixtures/…/nul_istochnika_153` → rc 0.

## 2. Сырой вывод (мои прогоны на OBJECT, rc в конце)

`W` на OBJECT (39.5 с):
```
DOMAIN strok=37448 putej=26502 otkaz-grammatika=6530 ne-regular=4416
GREEN backend: rc=0 stderr='' gate=True
GREEN ten: rc=0 stderr='' gate=True
GREEN nested: rc=0 stderr='' gate=True
GREEN zero-first: rc=0 stderr='' gate=True
GREEN zero-last: rc=0 stderr='' gate=True
GREEN zero-whole: rc=0 stderr='' gate=True
GREEN zero-head: rc=0 stderr='' gate=True
GREEN zero-tail: rc=0 stderr='' gate=True
GREEN nul: rc=1 stderr='ОТКАЗ: профиль: SOURCE_CANON_INVALID: репо-слой.sourceCanon.sources[0]: path NUL' gate=False
GREEN absolute: rc=1 stderr='ОТКАЗ: профиль: SOURCE_CANON_INVALID: репо-слой.sourceCanon.sources[0]: path абсолютный' gate=False
GREEN dotdot: rc=1 stderr='ОТКАЗ: профиль: SOURCE_CANON_INVALID: репо-слой.sourceCanon.sources[0]: path ..' gate=False
GREEN outside: rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: источник вне репозитория: link.md' gate=False
GREEN directory: rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: источник не regular file: folder' gate=False
GREEN fifo: rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: источник не regular file: pipe' gate=False
GREEN sweep: GREEN paths=26502 batches=9
CELLS=15 GREEN=15
RC=0
```
`W` на базе 6da673dcd (красное до правки, 3.1 с): rc 1, `CELLS=15 GREEN=6`.
- Каждая из восьми клеток backend, ten, nested, zero-first, zero-last, zero-whole, zero-head и zero-tail красная по своей причине: `SOURCE_CANON_INVALID: NUL в пути: <свой путь>`.
- `RED sweep: RED length=1 batch=0 rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: 0'`.
- Итог: `CELLS=15 GREEN=6`, `RC=1`. Красных клеток девять, это совпадает с приёмкой п.1 и п.2.

`W --stabs` на OBJECT (54.3 с):
```
DOMAIN strok=37448 putej=26502 otkaz-grammatika=6530 ne-regular=4416
CAUGHT false-zero backend
CAUGHT reject-edge-zero sweep
CAUGHT reject-whole-zero sweep
CAUGHT reject-middle-zero sweep
CAUGHT reject-double-edge-zero sweep
CAUGHT reject-triple-zero sweep
CAUGHT reject-quoted-backslash-zero sweep
CAUGHT accept-all nul
CAUGHT skip-nul-json nul
CAUGHT skip-absolute absolute
CAUGHT skip-dotdot dotdot
CAUGHT skip-canonical outside
CAUGHT accept-directory directory
CAUGHT accept-fifo fifo
SVJAZI=14 CAUGHT=14 LIVE=0
RC=0
```
`bash fixtures/workshop_project/rezhim_996/probe.sh` на OBJECT (33.3 с, хвост):
```
freeze-committed-preserved: rc=0
done-committed-preserved: rc=0
freeze-closures-preserved: rc=0
freeze-head-plan-preserved: rc=0
996: examined=111 mutants=0 mismatches=0
RC=0
```
Ворота на OBJECT:
```
$ bash scripts/pre_critic.sh contracts/153-nul-v-puti-istochnika.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1
КРИТИК: дверь зелёная
RC_pre_critic=0
$ bash scripts/check_ceilings.sh
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 146 черновик(ов) судится, замороженные — по тегам
потолки в порядке
RC_ceilings=0
$ bash scripts/check_provodka.sh . contracts/153-nul-v-puti-istochnika.md
RC_provodka=0
```
Живая проверка боли. Скрипт `scratch/live.sh` пишет свой код мира и не использует probe.py. Он создаёт временный git-репозиторий: `harness.project.json` с sourceCanon `migrations/001_core.sql` и gate `sh -c 'printf ok > gate-ran'`, затем вызывает реальный CLI `--stage pre_critic`.
```
OBJECT : rc=0 out='' gate-ran=yes
BASE   : rc=1 out='ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: migrations/001_core.sql' gate-ran=no
```

## 3. Неподгонка проверок — подтверждена

- Своей мерой проверил, что батарея не менялась. `git diff --stat frozen/contracts/153/1..OBJECT -- contracts fixtures` дал пустой вывод, rc 0. Единственный коммит после заморозки — коммит implementer; файлов контракта и батареи он не касается.
- Реализация не подстроена под клетки. Удалена неисполнимая ветвь, новой ветви под sweep нет. Пути `/*` и `*..*` и ФС-проверки остались прежними.
- Второй грамматики NUL нет. В `check_project_sources.sh` NUL упоминается только в комментариях (стр. 15–16, 91, 172), исполняемого предиката нет. Единственный источник — resolver `scan_canon`: `contains("\u0000")` для path (стр. 443) и для gate argv (стр. 501).
- Настоящий NUL отвергается ДО gate. Мои 9 входов с JSON `\u0000`: `\u0000`, `a\u0000`, `\u0000a`, `migrations/001\u0000core.sql`, `x/\u0000/y`, `0\u0000`, `\u00000`, `a\u0000\u0000b`, `src/\u0000.md`. Итог 9/9: rc 1, `SOURCE_CANON_INVALID: репо-слой.sourceCanon.sources[0]: path NUL`, `gate-ran=no`.
- Стабы красны по содержательной причине своей клетки. probe.py печатает только CAUGHT, поэтому детали я вывел своим скриптом `scratch/stab_details.py`: он импортирует `exercise`/`exercise_sweep` и печатает detail.
  - false-zero → backend: `NUL в пути: migrations/001_core.sql`.
  - reject-edge-zero → sweep: `NUL в пути: 0`.
  - reject-whole-zero → sweep: `NUL в пути: 0`.
  - reject-middle-zero → sweep, length 5: `0/0/0`.
  - reject-double-edge-zero → sweep: `00`.
  - reject-triple-zero → sweep: `000`.
  - reject-quoted-backslash-zero → sweep: `\0`.
  - accept-all → nul: rc 0.
  - skip-nul-json → nul: `SOURCE_CANON_MISSING: source`.
  - skip-absolute → absolute: `SOURCE_CANON_MISSING: /tmp/…/inside.md`.
  - skip-dotdot → dotdot: `SOURCE_CANON_MISSING: sub/../inside.md`.
  - skip-canonical → outside: rc 0, gate=True.
  - accept-directory → directory: rc 0, gate=True.
  - accept-fifo → fifo: rc 0, gate=True.
  Все 14 расходятся с честным результатом на своём конформном входе.
- Своей мерой пересчитал счётные утверждения. `scratch/count.py` перечисляет домен через base-8, а классы определяет regex-ами, без itertools probe.py. Результат: `{'strok': 37448, 'gram': 6530, 'nonreg': 4416, 'pos': 26502}`. Это совпадает с константами контракта 37448 = 26502 + 6530 + 4416. Число 15 клеток, 14 связей и 9 красных до правки сверил по сырому выводу выше.

## 4. Выборочная перепроверка выводов адверсария

- NUL-граница: 9/9 отвергнуты до gate (§3), подтверждаю.
- Границы путей: 15/15 зелёных на OBJECT (§2), подтверждаю. Дополнительно своей мерой:
  - симлинк внутри R (`l0.md → d/0.md`) → rc 0, gate запущен;
  - отсутствующий `absent0.md` → rc 1 `SOURCE_CANON_MISSING: absent0.md`, то есть цифра 0 не подменяет класс отказа;
  - литеральное имя `a\0b` (обратная косая и цифра 0) → rc 0, gate запущен.
- Prefix-коллизия `"$REPO"/*`: R=`<W>/r`, симлинк `l.md → <W>/r2/x.md`. Результат rc 1 `SOURCE_CANON_INVALID: источник вне репозитория: l.md`, gate не запущен. Коллизии нет, подтверждаю.
- Совет адверсария про NUL в корневом JSON-ключе. Воспроизвёл на OBJECT и на базе, результаты побайтно одинаковые:
  - ключ `sourceCanon\u0000x` → rc 1 со строкой bash `line 296: warning: command substitution: ignored null byte in input` и `неизвестный ключ репо-слой: sourceCanonx`;
  - ключ `zz\u0000` → rc 1 с тем же warning и `… zz`.
  Оценка: не блок 153. Отказ происходит до gate, поведение предшествует правке (resolver вне diff), предмет 153 судит NUL в path/argv, а не в ключах.
  **Поправка к выводу адверсария «обхода нет»** — см. ВНЕ ПРЕДМЕТА В-1.

## 5. ПРОВОДКА / CI

- `guard=fixtures/workshop_project/nul_istochnika_153/probe.sh` — барьер именно этого предмета. Он исполняет `scripts/check_project_sources.sh` и `profile_resolver.sh` из дерева. На базе guard красный, на OBJECT зелёный (§2).
- ПРОВОДКА-ЭНФОРСМЕНТ обоснована честно. Новой поведенческой нормы роли нет, предмет — исправление механизма существующей нормы 996. role-канал не требуется. `check_provodka.sh` → rc 0.
- CI-строка self-test 153 ещё не подключена: в `registry/` и `.github/` нет `nul_istochnika_153`. Сейчас это не блок.
- **УСЛОВИЕ для done (обязательство оркестратора по ПЕРЕСЕЧЕНИЮ контракта):**
  - добавить в `registry/ci-steps.tsv`, `registry/ci-zamery.tsv` и `.github/workflows/ci.yml` строку с `W` и `W --stabs`;
  - `gen_ci_steps.sh --write`, затем `--check` → rc 0;
  - чужие шаги не менять.
  Без этого батарея 153 не исполняется в CI, и регресс ложного NUL-отказа ничем не ловится.

## 6. `.review/`

Файлов `status: ready|partial`, относящихся к предмету 153, нет. Искал `153|check_project_sources|nul_istochnika` по `.review/`. Найденные совпадения относятся к другим предметам:
- PR#153 Complior-back по 121;
- START-счётчик в 140;
- старые С3-2/Р2-3 996 про `check_project_sources.sh:109-113`.
Старый совет С3-2 (`.review/2026-10-19-16.md`: «case `/*`, `*..*`, `*\0*` после resolver недостижимы») этой правкой закрыт частично: `*\0*` удалена. Оставшиеся `/*` и `*..*` — 996, вне 153. Готовых или частичных файлов по 153 нет, так что merge gate IV-1б не держит.

## Паразитная сложность (050)

Дифф не вводит и не раздувает ни одного артефакта: нет нового скрипта, функции, флага, env, файла состояния или ветви барьера. Дифф только удаляет одну ветвь `case`. Строк пяти вопросов нет.
Удаление уменьшает число мест, которые надо менять вместе при правке грамматики NUL: было два (resolver и consumer), стало одно (resolver).

## СВЕРКА-СТАНДАРТОВ

`AGENTS.md` дев-харнесса не объявляет документ архитектуры и стандарт кода: в дереве нет `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` (проверено `ls`, rc 2). Сверять не с чем. Норма-источник грамматики («резолвер — единственный источник», комментарий `check_project_sources.sh:89-93`) после правки соблюдена.

## БЛОКИРУЕТ

нет.

## СОВЕТ

- С-1 (architect/батарея, frozen, не implementer). Стабы `skip-absolute` и `skip-dotdot` ловятся сменой класса отказа (`SOURCE_CANON_MISSING` вместо `абсолютн`/`..`), а не принятием пути gate-ом. Причина: в клетке dotdot нет каталога `sub`, а в клетке absolute склейка `$REPO//abs` не существует.
  Правилу валидности контракта («результат расходится с честным») это соответствует. Однако мутант, снимающий обе проверки `..`, на мире с существующим `sub/` прошёл бы до gate. Батарея ловит его только по причине отказа.
  Совет для будущего круга батареи: создать `sub/`, тогда клетка ловит и само принятие. Для принятия 153 не нужно.

## ВНЕ ПРЕДМЕТА

- В-1 (resolver 996, предшествует правке, на базе 6da673dcd побайтно то же). Если ЕДИНСТВЕННЫЙ ключ канона в `harness.project.json` записан как `"sourceCanon\u0000"`, получаем молчаливое отсутствие канона:
  1. `scan_levels` (`profile_resolver.sh:296`, `roots="$(jq -r 'keys_unsorted[]' …)"`) теряет NUL в командной подстановке и видит известный ключ `sourceCanon`;
  2. merged-профиль не несёт `.sourceCanon`;
  3. `check_project_sources.sh` → **rc 0, gate не запущен**, хотя sources указывают на `/etc/hostname`.

  Репро: `scratch/rootkey2.sh <tree>`:
  ```
  OBJECT: key=sourceCanon\u0000 rc=0 gate-ran=no out=''
  BASE  : key=sourceCanon\u0000 rc=0 gate-ran=no out=''
  ```
  Это fail-open в шлюзе «канона нет»: pre_critic и done проходят без сверки. Вывод адверсария «обхода нет» верен только для варианта с лишним ключом (`sourceCanon\u0000x`, `zz\u0000` → rc 1). Для варианта, где NUL стоит в хвосте единственного известного ключа, вывод неверен.
  Вне 153 по трём причинам: resolver вне diff, 153 судит NUL в path/argv (И-2), режим отсутствующего канона по И-4 не меняется. Передаю оркестратору как кандидата в отдельный предмет resolver: NUL/управляющие символы в ключах любого уровня → отказ, а не потеря байта.
  [INFERENCE] Чтобы записать такой ключ, нужна правка профиля проекта. Насколько это реалистично в модели угроз 996, судить не мне.
- В-2. Комментарий-заголовок `check_project_sources.sh:12-17` («2. Валидирует структуру sourceCanon … без NUL») приписывает валидацию этому скрипту. Фактически её делает resolver; правдивое уточнение есть в стр. 89-93. Неточность предшествует правке. Это остаток С3-2 по 996.

## Что НЕ проверено

- Полный `bash scripts/check_zones.sh` (около 380 с) не гонял: ПРИЁМКА-СУДЬИ v2 разрешает scoped. Зону сверил своей мерой по автору и пути (§1).
- `W --model` с `--seed 1/7/42` не перегонял. Это доказательство модели до реализации, его предъявлял architect. После ремонта `W` на реализации зелёный.
- `W --repo` (алиас) не гонял.
- Поведение на jq 1.6 (CI) не проверял: на станции jaq, и это НЕ ЗАЩИЩАЕТ контракта.
- CI-прогон не наблюдал: строка CI ещё не подключена (§5).

Временные скрипты: `/tmp/dev-harness-verify/Rev153/scratch/{live.sh,count.py,stab_details.py,rootkey.sh,rootkey2.sh}`. Они вне репозитория, в основной чекаут ничего не записано.
