accept
OBJECT=1c2844536407bc7da0411296a8dbe6932aa62312
СУД: репо=dev-harness; предмет=212; фаза=реализация; роль=reviewer; вызов=1 (полный); сессия=Rev212; модель-факт=anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --session Rev212 | cut -f1-3` → `reviewer	anthropic/claude-opus-5-5	allowed`, rc 0); автор Impl212 — MiniMax; предыдущий=verdicts/adversary/contracts-212-impl-v4.md (accept); класс риска=рисковый
КЛАСС=КОДОВЫЙ. Блоков 0. Советов 4 (С-1…С-4), все в `.review/2026-11-24-158.md`.

# Вердикт reviewer — 212, реализация, вызов 1 (полный)

**БЛОКИРУЕТ: нет.**

**СОВЕТ: 4** — С-1 (architect): связи `--stabs` st49/st50 → r28 — плацебо. С-2 (orchestrator, отдельный предмет вместе с 068): пустое или отсутствующее значение `--nnn`/`--root`. С-3 (architect): ОСТАТОК-1 закрыть в батарее. С-4 (implementer, косметика): перевод строки в причине «не main» на unborn HEAD. Подробности — `.review/2026-11-24-158.md`.

Перепроверил ВСЁ: область правки, сырой вывод, не переписаны ли проверки под код. Счётные заявления проверены своей мерой, а не повтором чужой команды. Красное предъявлено своими мутантами в одноразовом клоне.

## 1. Объект и область правки (К-области)

```
pwd → /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/taef5ff966/m
git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/212/orchestrator-r8 refs/heads/wip/212/adversary-v4 refs/heads/main → rc 0
git switch --detach 1c2844536407bc7da0411296a8dbe6932aa62312; git rev-parse HEAD → 1c2844536407bc7da0411296a8dbe6932aa62312 (= wip/212/orchestrator-r8)
git merge-base origin/main HEAD → cb136eb51e596c4397c4c04d71502b8fcfd2cc37  (origin/main = e767f5132, +1 registry-коммит 068 сверху; дельта 212 от него не зависит)
git log --format='%h %an | %cn | %s' cb136eb51..HEAD →
  1c2844536 architect | orchestrator | 212: distinguish TMPDIR and cwd cross-filesystem cutover
  4b4bec69b architect | orchestrator | 212: различать remint vmax=2 и межфайловый mv в батарее
  01291b107 orchestrator | orchestrator | orchestrator: 212 CI-шаг — пинованный shellcheck 0.11.0 …
  8132a7b33 architect | orchestrator | 212: различить peeled, отказ commit и неатомарную запись в батарее
  69cf963ef orchestrator | orchestrator | orchestrator: 212 CI-шаг check:replace-posle-lenda-212-family-selftest …
  b575fd6e9 architect | orchestrator | fix(212): resolve subject before running argv fixtures
  7953de24f implementer | orchestrator | implementer(212): scripts/replace_line.sh — REPLACE строки реестра после ленда носителя
git diff --name-status cb136eb51 HEAD →
  M .github/workflows/ci.yml                       (orchestrator 69cf963ef)
  M registry/ci-steps.tsv, M registry/ci-zamery.tsv (orchestrator 69cf963ef, 01291b107)
  A scripts/replace_line.sh                        (implementer 7953de24f — единственный коммит)
  M|A fixtures/workshop_project/replace_posle_lenda_212/{SDACHA.md,mutants212.py,probe212.py,source.json,stabs/st44…st50/replace_line.sh}  (architect: b575fd6e9, 8132a7b33, 4b4bec69b, 1c2844536)
git log --format='%h %an %s' -- scripts/replace_line.sh → 7953de24f implementer … (единственный; после Adv212b production не правилась)
git diff --stat cb136eb51 HEAD -- roles AGENTS.md contracts scripts/check_staged.sh scripts/mint_line.sh scripts/check_zones.sh scripts/gitw scripts/freeze_contract.sh → пусто
git diff --stat frozen/contracts/212/1 HEAD -- contracts/212-replace-posle-lenda.md → пусто
```
Каждый путь лежит в зоне своего автора по `ЗОНА`/`ПЕРЕСЕЧЕНИЕ` (`contracts/212-replace-posle-lenda.md:82-…`). Implementer коснулся только `scripts/replace_line.sh`, а фикстуры правил только architect. Норма, роли, двери 031/049, mint_line, gitw и freeze не тронуты. Контракт совпадает с frozen-блобом. Каждый коммит относится к одному предмету и ссылается на 212.

Блок JOBS `.github/workflows/ci.yml` перепакован целиком: ключи переехали между полосами l2…l7. Это штатный вывод `gen_ci_steps.sh --write`, его требует `:26` контракта. `--check` rc 0 (§2), значит блок совпадает с генерацией из реестра. Чужих строк реестров дифф не меняет: в `ci-steps.tsv` и `ci-zamery.tsv` добавлено по одной строке.

## 2. Сырой вывод (мой прогон, по одной, на OBJECT)

Среда: `TMPDIR=/tmp/dev-harness-verify/scratch-rev212`, `VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck`, `W=fixtures/workshop_project/replace_posle_lenda_212/red_replace_posle_lenda_212.sh`.
```
bash $W --repo .      → SUBJEKT 212: KLETKI 34 KRASNYH 0                     RC_REPO=0   real 0m15.7s
bash $W --model       → MODEL 212: KLETKI 34 KRASNYH 0                       RC_MODEL=0  real 0m18.3s
bash $W --stabs       → MODEL 212: KLETKI 34 KRASNYH 0
                        STABY 212: SVJAZI 83 ZHIVYH 0                        RC_STABS=0  real 1m13.2s
bash $W --sintaksis   → SINTAKSIS OK (bash -n: 52; пинованный shellcheck честных носителей: 3)   RC_SINT=0
bash scripts/gen_ci_steps.sh --check                                         RC_GEN=0
bash scripts/pre_critic.sh contracts/212-replace-posle-lenda.md → ok гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1 / ok гейт трека / ok модель угроз красна / ok потолки красны / ok проводка красна / ok сдаточный лист красен / КРИТИК: дверь зелёная   RC_PRECRITIC=0   (13m20s)
bash scripts/gen_ci_steps.sh --check (повтор той же сессией)          RC_GEN=0
bash scripts/check_sdacha.sh "$PWD" contracts/212-replace-posle-lenda.md --run → СДАЧА: лист зелёный (двери=14 карта=17/17 дельта=1)   RC_SDACHA=0   real 11m11s (с первого раза; параллельно шёл pre_critic)
bash fixtures/mint_line/red_mint_line_068.sh → ИТОГ 068b (mint_line): ветвей 8, стабов 4, красных 0, зелёных 11, не прогнано 1   RC_068=0
  (стМ1/стМ2 «мёртв … next_id.sh: No such file», стМ3 «не построен», стМ4 «мёртв» — как в вызовах Adv212…Adv212d; не предмет 212, тот же класс, что С-1)
shellcheck 0.11.0 -S warning scripts/replace_line.sh → 0 находок   RC_SC=0
bash -n scripts/replace_line.sh                                     RC_BASHN=0
sha256 пина: /home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck = 4da528ddb3a4d1b7b24a59d4e16eb2f5fd960f4bd9a3708a15baddbdf1d5a55b = ops/server/validators.tsv:7
```
Заявленное Adv212d (`--repo` 34/0, `--model` 34/0, `--stabs` 83/0, `--sintaksis` rc 0) совпало.

Первый `--sintaksis` я запустил фоном без переменных среды (async-шелл их не наследует). Он дал rc 2 `VALIDATOR_MISSING: shellcheck`, то есть дверь без валидатора отказывает именованным rc 2 и в зелёный пропуск не превращается. С переменными в той же строке — rc 0, как выше.

Своя мера счётных заявлений, другой командой. `jq '{worlds:(.kejsy|length),stabs:(.stab_vhod|length),bindings:([.stab_vhod[]|length]|add),carriers:(.nositeli|length)}' source.json` → `28/50/83/51`. `ls -d stabs/*/ | wc -l` → 50. `grep -c "^    reg('r" probe212.py` → 28 миров, ещё 6 argv-клеток `ARGV_KEJSY` дают 34. Совпадающих sha256 среди 50 стабов, модели и production нет (`sha256sum … | sort | uniq -d | wc -l` → 0). Прошу учесть: из 83 связей 2 — плацебо (§3, С-1).

Красное до реализации (`:44-46`). В одноразовом клоне, у которого свой `.git`, `scripts/replace_line.sh` временно убран, затем `bash $W --repo .` → `SUBJEKT 212: SUBJECT_ABSENT .` + перечень `VHOD: …`, rc 1. После этого файл возвращён, `git status` чист.

## 3. Не подогнаны ли проверки под код. Красное своей мерой

**Хронология.** Модель и красная батарея — `bdcb7718c`/`b64369929` architect, 2026-11-23 02:15–03:11. Реализация — `7953de24f`, 2026-11-24 14:20. После реализации architect только добавлял клетки r23–r28 и стабы st44–st50 по блокам адверсария. `git diff b64369929 HEAD -- …/probe212.py | grep -E '^[-+].*(ozh_otkaz|ОТКАЗ|DVOR|USAGE|NOT_IMPLEMENTED)'` показывает только две добавленные строки ожиданий новых клеток r26/r24: ни одно прежнее ожидание не переписано. `git diff --stat b64369929 HEAD -- …/model` пуст, модель после реализации не менялась. Implementer фикстуры не трогал.

**Клетки судят поведение мира, а не текст скрипта.** `probe212.py:sravnit`/`post_problemy` сравнивают rc и полные байты stdout/stderr, без декодирования. Дальше сверяется HEAD с одним новым коммитом (`rev-list --count`), побайтовый манифест HEAD против пред-снимка в памяти, identity `%an|%ae|%cn|%ce`, `status --porcelain`, inode/fstat (r25) и st_dev источника настоящего `mv` (r27/r28). Пробы по исходнику субъекта нет. Ожидаемый stdout успеха собирается из мира через `rev-parse HEAD`. Связи стабов — `STAB_VHOD` в коде пробы, а `source.json` сверяется с ним на равенство, то есть привязки идут по коду (Н-39), а не по прозе контракта.

**Модель против production.** Модель production не копирует: она старше. Обратное верно: если отбросить комментарии, production — почти дословная модель (`git diff --no-index -w model/replace_line.sh scripts/replace_line.sh`). Код расходится только в трёх местах: поиск `next_id.sh` строго рядом с собой (`SELF_DIR`), порядок вычисления `vmax_prev` и каталог `mktemp` (registry вместо корня). Контракт `:25` такое разрешает («не требование копировать её текст»). Отмечу последствие: дефект, общий для модели и production, батарея, откалиброванная по модели, не увидит. Компенсация — четыре круга мутационного поиска адверсария на production. Находкой это не считаю.

**Зелёных пустышек нет, кроме двух связей.** Проба `rev_red.py` (scratch, удалена). `probe212.prognot_kletku` запускался в одноразовом клоне, cwd = клон:
```
stab st04-predok-ne-proverjaetsja   r03  RED  rc 0 ≠ 1; stdout 'REPLACED nnn=994 …'              (причина по существу)
stab st45-otkat-udalen              r24  RED  пост: манифест worktree мутирован; 'M  registry/contracts.tsv'
stab st43-nul-udalen                r19  RED  stderr 'grep: (standard input): binary file matches …'
stab st49-mktemp-tmpdir             r28  RED  rc 2; stderr 'NOT_IMPLEMENTED: next_id.sh не найден: …/stabs/st49-mktemp-tmpdir/…'; пост: mv реестра не наблюдался
stab st50-mktemp-cwd-rel            r28  RED  то же: NOT_IMPLEMENTED next_id.sh
stab st49-mktemp-tmpdir             r01  RED  то же (честная клетка!) → стаб мёртв на любом входе = плацебо-связь (С-1)
stab st48-mktemp-drugaja-fs         r27  RED  пост: mv между файловыми системами                 (по существу)
PROD-MUT st49 (в scripts/ клона)    r28  RED  пост: mv между файловыми системами;   r01 GREEN
PROD-MUT st50 (в scripts/ клона)    r28  RED  пост: mv между файловыми системами;   r01 GREEN
мои мутанты production (вне STAB_MUTACII):
P1 merge-base --is-ancestor → cat-file -e FREEZE_COMMIT   r03  RED  rc 0 ≠ 1, коммит до ленда
P2 откат: show HEAD:реестр > реестр (без индекса)          r24  RED  пост: 'MM registry/contracts.tsv'
P3 nul_cnt=0                                               r19  RED  stderr 'grep: … binary file matches'
P4 sort -n → sort (лексикографический vmax)                r15  GREEN  (на версиях 1/2 неотличим; = названный остаток «vmax≤2», production безусловна)
честная production: r03/r24/r19/r15                        GREEN
```
Клетки r03, r19, r24 и r28 краснеют против сломанной реализации по своей причине. Связи st49 → r28 и st50 → r28 в матрице `--stabs` ловят отказ носителя (у стаба-копии production нет соседа `next_id.sh`), а не межфайловый `mv`. По `:59` контракта ошибка носителя должна давать rc 2 и в зачёт не идти. Различительную силу r28 на production это не отменяет (строки PROD-MUT), а пороги `:59` (≥43 стабов, ≥76 связей) выполнены и без двух плацебо: 48/81. Поэтому это совет С-1, а не блок.

## 4. Соответствие контракту: команда и rc по каждому инварианту и пункту приёмки

| Обязательство | Где в production | Мера на OBJECT | rc/итог |
|---|---|---|---|
| И-1 CLI: N 1–3 цифры → NNN; usage rc 1; вне грамматики rc 2 | `:144-171` | argv n01–n06 в `--repo` (34/0); своя проба: без аргументов → rc 1 + usage; `--zzz` → rc 1 + usage; `--nnn 1234` → rc 2 NOT_IMPLEMENTED; `--root /nonexist` → rc 2; `--root /` → rc 2 «не репозиторий» | соответствует; `--nnn ''`/`--nnn` без значения → rc 1 с shell-диагностикой → С-2 |
| И-1 строка реестра, annotated, литеральные сравнения | `:226-229`, `:252`, `:310-332` (`[ = ]`) | r11 (лёгкий тег), r23/r26 (tag-object ≠ при равных peeled) | 34/0 |
| И-2 main, чистота, local main = живой origin main | `:174-183`, `:257-269` (`ls-remote`, не tracking-ref) | r06, r07, r08 | 34/0 |
| И-3 vmax той же мерой; авторитет недоступен / не выдан / переминт | `:216-254` | r02, r13, r14, r15, r23, r26 | 34/0 |
| И-4 коммит заморозки — предок живой origin main | `:272-279` | r03; мой P1 → r03 RED | 34/0 |
| И-5 ровно одна строка; NUL/CRLF/поля/пустая по трубе до `$()`; старая сторона id или vmax−1; повтор | `:285-332` | r04, r05, r10, r12, r16, r19–r22; мой P3 → r19 RED | 34/0 |
| И-6 временный файл + mv в той же ФС; побайтово с краем файла; identity env | `:342-359` | r17, r18, r25, r27, r28; PROD-MUT st49/st50 → r28 RED | 34/0 |
| И-7 живой pre-commit до записи; без `-c`/`--no-verify`; откат точечный | `:188-200`, `:359-363` | r09, r24; стабы st15/st16 (канарейка `DVOR`); мой P2 → r24 RED | 34/0, 83/0 |
| И-8 stdout ровно `REPLACED …`; stderr хука; не пушит, не двигает теги | `:365-367`; grep `push|tag |fetch|update-ref|reset|--no-verify` по коду — только чтение refs и `commit` | r01, стабы st30–st39 | 34/0, 83/0 |
| Приёмка «гейты ленда» (4 команды) | — | `--repo .` 0, `--stabs` 0, `--sintaksis` 0, `gen_ci_steps --check` 0 | все rc 0 |

**Production реально заменяет ручную процедуру** `/tmp/dev-harness-verify/replace-main-v.sh`. Проба `rev_manual.py` (scratch, удалена) построила два мира-близнеца `probe212.Mir`: toy, bare-origin и живая дверь 031, NNN=989, сначала минт, потом freeze с лендом и publish. Ручной скрипт запускался копией в scratch, у которой `R` перенаправлен на toy. Настоящий origin и основной чекаут не задействованы.
```
PROD   rc=0 stdout='REPLACED nnn=989 old=f39bfb6a… new=118c4e9d… commit=012d27ee…\n'
       stderr='judged: registry/contracts.tsv (дверь минта 031: +1 строк ↔ живые dual-control теги)\nok: staged в зоне автора orchestrator (1 путь/путей)\n'
       commits=1 first_parent=pre parents=1 files=registry/contracts.tsv numstat=1/1 status='' line==tag-object frozen/989/1: True
       ident=orchestrator|orchestrator@dev-harness.local|orchestrator|orchestrator@dev-harness.local
MANUAL rc=0  (те же stderr двери) commits=1 parents=1 files=registry/contracts.tsv numstat=1/1 status='' line==tag-object: True, ident тот же
SAME-SHAPE {commits, first_parent_is_pre, parents, files, status, numstat: True}
PROD повтор без push → rc 1 'ОТКАЗ: main разошёлся с origin/main (…)', HEAD не сдвинулся
```
Production строже ручного маршрута. Она сверяет старую сторону с id/vmax−1 (у ручного этого нет), пишет атомарным `mv` в той же ФС (ручной делает `cp` поверх), выбирает vmax сама, а не берёт `$3`, и не делает `fetch`/`merge --ff-only`. Последнее — ровно И-2: живой origin сверяется, но main не двигается.

## 5. CI-проводка

`registry/ci-steps.tsv:325` содержит `check:replace-posle-lenda-212-family-selftest`, вес 110: `--repo .` && `--stabs` && скачивание shellcheck v0.11.0 && `VALIDATE_STD_SHELLCHECK=… --sintaksis`. `registry/ci-zamery.tsv:126` — `110 95 0`. Скачанный архив проверен: `curl -fsSL https://github.com/koalaman/shellcheck/releases/download/v0.11.0/shellcheck-v0.11.0.linux.x86_64.tar.gz | tar -xz` → `sha256(shellcheck-v0.11.0/shellcheck)=4da528dd…a55b`, что равно пину `ops/server/validators.tsv:7`. `validate_std.sh:72-76` сверяет sha с пином на любой ветви резолва. Мой замер (≈15.7 + 73 + 1 с + скачивание) согласуется с замером 95 при весе 110. У каждой команды `run:` есть пункт приёмки: `--repo .`, `--stabs`, `--sintaksis` — «гейты ленда» `:69-78` и шаг `:26`; curl и tar — подготовка валидатора, требуемая ПРЕДПОСЫЛКАМИ `:176`. `gen_ci_steps --check` rc 0. ПРОВОДКА: guard `red_replace_posle_lenda_212.sh` — барьер именно этого предмета, канал подключён этим шагом. ПРОВОДКА-ЭНФОРСМЕНТ обоснован честно: это инструмент записи штатной двери, новой поведенческой нормы нет.

## 6. Остатки Adv212d — триаж

- **ОСТАТОК-1 (HOME/TMP/TEMP).** Для production недостижим. В `scripts/replace_line.sh` этих переменных не читают (grep `\$\{?(HOME|TMP|TEMP|TMPDIR|PWD|XDG_…)\b` находит только локальную `$TMP` от `mktemp`). Единственный `mktemp` (`:342`) берёт шаблон `$ROOT/$_REGISTRY_PATH/.replace-line-…`, и при шаблоне с `/` GNU mktemp `TMPDIR` не читает. Это совет С-3 (дыра входа батареи), не блок.
- **ОСТАТОК-2** (константа `/tmp`, `/var/tmp`). Production так не делает. Лист называет это честным эквивалентом той же ФС. Без действий.
- **ОСТАТОК-3** (vmax≤2, префикс sha[0:8]). Production сравнивает tag-object полностью и литерально (`:252`, `[ "$NEW_SHA" != "$sha_origin" ]`) для любого vmax. Мой P4 подтверждает, что батарея на версиях 1/2 мутант не различает. Остаток назван, ловец — reviewer: не укусил.
- **ОСТАТОК-4** (`/bin/mv` ложно-красный, `rm -f` перед `mv` живой). Production вызывает `mv` через PATH (`:353`), `rm` перед ним нет. Не укусил.
- **ОСТАТОК-5** (чувствительность `check_sdacha --run` к нагрузке). Мой прогон — §2. Процессное, без действий в 212.

## 7. Остатки контракта (НЕ ЗАЩИЩАЕТ, `:168-173`) с ловцом reviewer

- ОСТАТОК: К-03 (`:170`, подлинность тела pre-commit и git в PATH) — не укусил. Production проверяет `-x` эффективного `pre-commit` до записи (`:188-200`), коммит `:359` без `-c` и `--no-verify`, identity идёт явным env. Подмену git в PATH production не создаёт.
- ОСТАТОК: К-06 (`:173`, конечная батарея ≠ эквивалентность программы) — по production не укусил: мои четыре мутанта P1–P4 и сверка с ручным маршрутом новых дефектов не дали. По самой батарее укусил частично: две плацебо-связи `--stabs` (С-1, `probe212.py:rezhim_stabs`, `stabs/st49…`, `stabs/st50…`).
- `:168` (историческая пара 208), `:169` (гонка после снимка), `:171` (форма вывода check_staged), `:172` (профили 996) — ловцы не reviewer. Дифф их не затрагивает.

## 8. Паразитная сложность (050)

- `scripts/replace_line.sh`. (1) Свойство: предмет контракта `:22`, И-1…И-8. (2) Состояние: реестр, один коммит и временный файл `registry/.replace-line-NNN.*`. Всё явное: stdout `REPLACED`, stderr `ОТКАЗ`, файл убирает `trap`. (3) Меняются вместе 1 файл production и модель с клетками в зоне architect; дифф это число не увеличил. (4) Интерфейс: 2 флага, rc 0/1/2, env субъект не читает (только выставляет `GIT_CONFIG_*`); работа за ним — 8 инвариантов, модуль глубокий. (5) Потребитель — гейты ленда и шаг CI. `decimal_sub1` — третья копия (`check_staged.sh:119`, `check_zones.sh:347`), так принято в дереве. Комментарий «второй реализации нет» (`:120-122`) неточен, но общий lib потребовал бы правки двери вне зоны. ESSENTIAL.
- Семья батареи (`probe212.py`, `mutants212.py`, `source.json`, `stabs/`, `model/`). (1) Приёмка `:40-78`. (2) Миры в `TMPDIR`, удаляются в `finally`. (3) Стабы генерируются из пробы, `source.json` сверяется на равенство: правка в одном месте. (4) Режимы `--repo/--model/--stabs/--sintaksis/--sgeneriruj-staby`, каждый с приёмочным потребителем. (5) `mutants212.py` — дверь листа (`SDACHA.md`) без потребителя в CI. Стабы st49/st50, копии production, придётся перегенерировать при правке production. Это совет Adv212d, его подхватывает С-1. ESSENTIAL.
- Шаг CI и две строки реестров: (1) `:26`; (2)–(4) по одной строке; (5) потребитель — CI. ESSENTIAL.

## 9. Сверки

СВЕРКА-СТАНДАРТОВ: н/п — `AGENTS.md` станции не объявляет `docs/ARCHITECTURE.md`/`docs/CODING-STANDARDS.md` (`grep -c -E 'ARCHITECTURE|CODING-STANDARDS' AGENTS.md` → 0); дифф — bash-инструмент станции, стандарт бэкенда к нему не применим.
СВЕРКА-АРХИТЕКТУРЫ: размещение — `scripts/` станции, зона implementer; зависимости — `next_id.sh` (резолвер 996, единственный), git, jq, awk; писатели реестра — дверь 031 остаётся единственным судьёй, новый писатель — только штатный commit orchestrator; операции — модели операций 188 в станции нет, контракт не несёт строки `АРХИТЕКТУРА:` (`grep -c` → 0); `bindings.json` — дифф не трогает; долг не расширен; уровень diff модели — нет diff модели (L0).

## 10. Регресс

`--repo .` 34/0, `--model` 34/0, `--stabs` 83/0 (из них 81 содержательная), `--sintaksis` 52/3, `gen_ci_steps --check` 0, pre_critic и check_sdacha — §2, 068 — rc 0 (прежнее «не прогнано 1»), shellcheck 0, `bash -n` 0. Против Adv212d регресса нет.

## 11. Среда и следы

Все запуски субъекта, стабов и мутантов шли в мирах `TMPDIR=/tmp/dev-harness-verify/scratch-rev212` и одноразовом клоне `scratch-rev212/clone` (`git clone --no-hardlinks`, собственный `.git`, `checkout --detach` OBJECT). Против настоящего origin и основного чекаута ничего не запускалось. Scratch удалён перед докладом.
