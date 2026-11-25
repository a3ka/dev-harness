accept
OBJECT=7cd4dbbe51bc6ba0df021d3104134160a926dfc3
СУД: репо=dev-harness; предмет=221; фаза=реализация; роль=reviewer; вызов=1 (полный); сессия=c907157c/Rev221; модель-факт=anthropic/claude-opus-5-5 (метаданные системного промпта сессии); автор Impl221 — implementer (MiniMax); предыдущий=archive/221/adversary-v1-fail-b93acf7b01 (FAIL только К-08; правило остановки R-0068/R-0074)

# Суд реализации 221 — `scripts/mint_line.sh` (project-маршрут двери минта 031), reviewer вызов 1

**БЛОКИРУЕТ: нет.**

**СОВЕТ: 9** — файл находок `.review/2026-11-25-2211.md` (`status: ready`):
- Б-1…Б-6 — ремонт батареи по шести дырам К-08 Adv221 (Architect);
- С-1…С-3 — паразитная сложность production по норме 050 (implementer, при следующей правке; не блок).

Я перепроверил ВСЁ: область правки, сырой вывод, не переписаны ли проверки под код. Свойства контракта проверены своими мирами (`own.py`, `extra.py`), а не клетками батареи. Красность батареи на production доказана пятью своими мутантами. Мутационный поиск адверсария не повторялся.

## 1. Область правки

`git diff --name-status 880ff787e HEAD` (merge-base с origin/main = `880ff787ed8d221e13863afac60208a99843814b`):
```
M	.github/workflows/ci.yml
M	registry/ci-steps.tsv
M	registry/ci-zamery.tsv
M	scripts/mint_line.sh
```
`git log --format='%h %an <%ae> | %cn %s' 880ff787e..HEAD`:
```
7cd4dbbe5 orchestrator <orchestrator@dev-harness.local> | orchestrator orchestrator: 221 CI-шаг check:mint-line-proekt-221-family-selftest (вес 60, замер 50 с: …), пересчёт JOBS ci.yml; gen_ci_steps --check rc 0
b18e1b4d5 implementer <implementer@dev-harness.local> | implementer implementer(221): scripts/mint_line.sh — project-маршрут минта сквозь живую дверь 031
```
- **Implementer `b18e1b4d5`:** ровно `scripts/mint_line.sh` (+81/−1). Это ЗОНА implementer и ПЕРЕСЕЧЕНИЕ с 068.
- **Orchestrator `7cd4dbbe5`:** ровно `ci.yml` (12 строк, только сгенерированный блок JOBS 083), `ci-steps.tsv` (+1), `ci-zamery.tsv` (+1). Всё в ЗОНЕ orchestrator.
- Вне зон ничего нет. Атомарность: два коммита, у каждого своя роль и ссылка на предмет.
- **Батарея не подогнана.** `git diff frozen/contracts/221/1 HEAD -- fixtures/workshop_project/mint_line_proekt_221 contracts/221-mint-line-proekt.md` пуст. Тег `frozen/contracts/221/1` (`67288e882`) — предок HEAD. История семьи — только architect: `4d4da0211`, `3470aa421`, `cf6a8f665`, все до заморозки.
- **Нормативы не тронуты.** Контракт, roles и норм-документы в диффе отсутствуют.

**Дельта production против И1–И6.** Необъявленной семантики нет. Вся дельта — один блок `if [ -f "$ROOT/harness.project.json" ]` (`mint_line.sh:150-201`) и функция `_mint_hook_cleanup` (`:143-149`, в станции только определяется).
- И1 — признак и префлайт `project_paths_resolve` (`:150`, `:154`).
- И3 — `--unset-all` user.name/email (`:160-169`).
- И2 — одноразовый хук в `mktemp -d` и `trap EXIT` (`:177-189`); process-local `core.hooksPath` через `GIT_CONFIG_*` (`:193-200`).
- Строки 0–5 (068) не изменены.
- Дополнительные rc 2 `NOT_IMPLEMENTED` (нет `check_staged.sh` рядом, сбой mktemp/printf/chmod) — это прежняя грамматика скрипта «rc 2 — нечем проверить». Операционные сбои названы, как требует «Модель угроз». Шапка `:52` их не перечисляет — совет С-3.

## 2. Сырой вывод — регресс (rc и числа)

Окружение: `TMPDIR=/tmp/dev-harness-verify/scratch-rev221`, `VALIDATE_STD_SHELLCHECK=…/shellcheck/0.11.0/shellcheck`, `git rev-parse HEAD` = `7cd4dbbe51bc6ba0df021d3104134160a926dfc3`. База для сравнения — клон на `880ff787e`.

| команда | rc | числа |
|---|---|---|
| `W --repo .` | 0 | `KLETKI 17 KRASNYH 0` (p01–p12, s01–s05 GREEN), 27 с |
| `W --model` | 0 | `KLETKI 17 KRASNYH 0` |
| `W --stabs` | 0 | CONTROL 17 GREEN; `STABY 14 SVJAZI 18 ZHIVYH 0`; каждая из 18 связей RED отдельно |
| `W --sintaksis` | 0 | `SINTAKSIS 17 SHELLCHECK 2` |
| `bash -n scripts/mint_line.sh` | 0 | — |
| shellcheck 0.11.0 `-S warning scripts/mint_line.sh` | 1 | одна SC2034 `NEXT_ID_LIB` (`:76`); на базе та же одна (rc 1) |
| `bash fixtures/mint_line/red_mint_line_068.sh` | 0 | `ветвей 8, стабов 4, красных 0, зелёных 11, не прогнано 1`; база — те же числа и rc 0 (стМ1/стМ2 «мёртв … next_id.sh: No such file» есть и на базе: строка 64 против 78, сдвиг из-за комментария) |
| `red_charter_tekst_do_tega_210.sh --repo .` | 0 | `KLETKI=342 ZELENYE=342 KRASNYE=0` |
| `fixtures/limit_aktivnyh/red_limit_aktivnyh_078.sh` | 1 | `красных 1, зелёных 22, не исполнено 31` (л0 «предмет отсутствует»); база — то же, rc 1 |
| `bash scripts/gen_ci_steps.sh --check` | 0 | — |
| `bash scripts/check_provodka.sh . contracts/221-mint-line-proekt.md` | 0 | — |
| `pre_critic` / `check_sdacha --run` | см. §2а | — |

### 2а. pre_critic / check_sdacha

Изолированный прогон (load 35 → 16, ничего моего параллельно):
```
bash scripts/pre_critic.sh contracts/221-mint-line-proekt.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
  ok   модель угроз красна
  ok   потолки красны
  ok   проводка красна
ОТКАЗ: сдаточный лист красен (rc=1): ОТКАЗ: строка 15: фактический rc=0 ≠ заявленного 1: bash fixtures/workshop_project/mint_line_proekt_221/red_mint_line_proekt_221.sh --repo .
pre_critic rc=1
SDACHA_TIMEOUT_SEK=600 SDACHA_BUDZHET_SEK=2400 bash scripts/check_sdacha.sh . contracts/221-mint-line-proekt.md --run
ОТКАЗ: строка 15: фактический rc=0 ≠ заявленного 1: bash fixtures/workshop_project/mint_line_proekt_221/red_mint_line_proekt_221.sh --repo .
sdacha rc=1
```
Красна только строка 15. Это известный ряд «Red-do» `1 · 1`, который Architect правит после ленда; не блок.

`check_sdacha` останавливается на первом расхождении. Поэтому остальные ряды листа я прогнал по одному тем же способом (`SDACHA_OKRUG=1 timeout -k 10 600 <команда>`):
- строки 16–26 — все rc 0: `--model`, `--sintaksis`, `check_precision_gate`, `check_spec_ready`, `check_threat_model` («ЗАЩИЩАЕТ 2, НЕ ЗАЩИЩАЕТ 4»), `check_predposylki`, `check_ceilings`, `check_ids`, `check_provodka --grammar`, `gen_ci_steps --check`;
- `--stabs` (строка 17 и оба ряда «Дельта») — rc 0 (§2);
- ряды «Карта» несут `- · -`, команд в них нет.

Других красных нет.

**Наблюдение о первом, неизолированном прогоне.** Это было async-задание: без `TMPDIR` и `VALIDATE_STD_SHELLCHECK`, параллельно с моими `own.py`/`mut.py`, при load 35.
- `pre_critic` и `check_sdacha --run` дали rc 1 «строка 18: фактический rc=2 ≠ заявленного 0: … --sintaksis».
- Причина rc 2 воспроизведена: без пина `--sintaksis` пишет `COMMAND rc=2: [… validate_std.sh bash …/model/mint_line.sh]: b'VALIDATOR_MISSING: shellcheck\n'`. Это объявленное поведение листа («нет валидатора — rc 2»), не дефект.
- Строка 15 в том прогоне совпала с `1`. Значит, `--repo .` тогда дал rc 1. Повторить это не удалось:
  - изолированно — rc 0;
  - без `TMPDIR`/пина — `KLETKI 17 KRASNYH 0` rc 0;
  - под нагрузкой с параллельными `own.py`/`mut.py` — rc 0;
  - четыре параллельных `--repo .` без env при load 26 — четыре раза `KLETKI 17 KRASNYH 0` rc 0.
- Вывод того прогона был подавлен самим `check_sdacha` (`>/dev/null`), красную клетку назвать нечем. [INFERENCE] разовая красная клетка от нагрузки или пересечения с моими параллельными прогонами. На вердикт не влияет. Если повторится в CI, нужен вывод `--repo` с именем клетки.

## 3. Соответствие контракту — свои миры (не клетки батареи)

`own.py` строит свои Git-миры с local bare-origin, annotated id-тегом, профилем 996 и копией установки инструментов из OBJECT. TMPDIR и HOME у каждого мира свои.
- **Регистратор хука.** В установке `check_staged.sh` подменён обёрткой. Она пишет фактический `core.hooksPath`, свои аргументы и `$0`, затем `exec` настоящей двери.
- Вывод (`own.py … all`, rc 0):
```
PASS A.rc0+stdout :: rc=0 out='MINTED nnn=917 sha=946afb06… commit=1a83c5a7…\n' err='judged: .harness/registry/contracts.tsv (дверь минта 031: +1 строк ↔ живые dual-control теги)\nok: staged в зоне автора orchestrator (1 путь/путей)\n'
PASS A.door-live-stderr
PASS A.hook-exec-sibling-check_staged-on-R :: HOOKDIR=…/w/A/scratch/tmp.NphXCQPPhz | ARGS=…/w/A/product | SELF=…/tools-rec/scripts/check_staged.sh
PASS A.hook-dir-removed :: hookdir=['…/w/A/scratch/tmp.NphXCQPPhz'] exists=[False]
PASS A.existing-hook-untouched-not-run :: existing.log=False gitdir-diff=None
PASS A.one-commit-only-registry
PASS A.identity :: orchestrator|orchestrator@dev-harness.local|orchestrator|orchestrator@dev-harness.local   (при чужих GIT_AUTHOR_*/GIT_COMMITTER_* вызывающего)
PASS A.config-only-user.name/email-removed :: ['-\tname =', '-\tname = second', '-\temail = e@x']   ([alias] name/email, [user "work"] name/email, [sendemail], user.signingkey сохранены)
PASS A.refs-tags-branches-same
PASS A.no-residue-scratch-home
PASS A.registry-exact
PASS A.hooksPath-not-persisted
PASS B.rc1+reason :: rc=1 err='ОТКАЗ: дверь минта 031: номер 917 уже в манифесте — повторный минт\nОТКАЗ: commit строки реестра отказал (дверь минта 031) — дерево возвращено к HEAD\n'
PASS B.atomic-HEAD/status/registry :: ['cfg']
PASS B.ignored-survive
PASS B.hook-dir-removed-on-refusal :: ['…/w/B/scratch/tmp.O7yHBHh1xy']
PASS B.tags-same
PASS B.name-normalized :: ['-[user]', '-\tname = x']
PASS C1.foreign-cwd-project-route :: rc=0 out='MINTED …'
PASS D1.broken-profile.rc1+config-untouched :: rc=1 err='файл не JSON: …/harness.project.json\n'
PASS D2.not-main.rc1+config-untouched :: rc=1 err='ОТКАЗ: HEAD не main (текущая ветка: side) …'
PASS D3.dirty.rc1+config-untouched :: rc=1 err='ОТКАЗ: грязное дерево …'
PASS E.unset-fails-named-rc1 :: rc=1 err='error: could not lock config file .git/config: File exists\nОТКАЗ: не удалось удалить запрещённый ключ user.name из общего file-config (rc=255) — минт без нормированной identity невозможен\n'
PASS F.devnull+caller-pair-door-runs :: rc=0 out='MINTED …'   (core.hooksPath=/dev/null в клоне и пара GIT_CONFIG_KEY_0=core.hooksPath=/dev/null у вызывающего)
PASS G.door-rc-propagates :: rc=1 err='REV221-DOOR-REFUSED\nОТКАЗ: commit строки реестра отказал …'
PASS H1.repeat :: rc=1 err='ОТКАЗ: номер 917 уже в манифесте — повторный минт\n'
PASS H2.no-verify-unknown :: rc=1 err='mint_line: неизвестный аргумент: --no-verify\nиспользование: …'
PASS H3.not-repo-rc2 :: rc=2 err='NOT_IMPLEMENTED: --root не репозиторий git: …'
PROJECT FAILS 0
SAME s-live-hook base_rc=0 obj_rc=0
SAME s-no-hook base_rc=1 obj_rc=1
SAME s-foreign-config-hook base_rc=1 obj_rc=1
SAME s-foreign-config-nohook base_rc=1 obj_rc=1
SAME s-repeat base_rc=1 obj_rc=1
SAME s-door-refusal base_rc=1 obj_rc=1
SAME s-not-main base_rc=1 obj_rc=1
SAME s-dirty base_rc=1 obj_rc=1
SAME s-no-tag base_rc=1 obj_rc=1
SAME s-devnull base_rc=1 obj_rc=1
SAME s-layer-only-no-profile base_rc=1 obj_rc=1
SAME s-profile-in-parent base_rc=1 obj_rc=1
STATION WORLDS 12 DIFF 0
```
`extra.py` (rc 0):
```
X1.no-TMPDIR rc=0 hookdir=['/tmp/tmp.bs08u9gYon'] exists=[False] home=[]
X2.caller-GIT_CONFIG_PARAMETERS-devnull rc=1 err='ОТКАЗ: дверь 031 отключена конфигом (эффективный hooks-каталог /dev/null без исполняемого pre-commit) …' head_same=True
X3.profile-untracked-ignored-in-R rc=0 out='MINTED nnn=917 sha=946afb06… '
```
Две поправки к моей первой редакции `own.py` — не дефекты production:
- `FETCH_HEAD` появляется от fetch самой двери 031. Он есть и в станционных мирах базы.
- Снятие пустого заголовка `[user]` — штатное поведение git 2.43. Голый `git config --unset-all user.name` вне mint_line даёт тот же конфиг без `[user]`.

**Вывод по инвариантам:**
- **И1 — соответствует.** Признак — `-f $ROOT/harness.project.json`, тот же, что у резолвера `next_id.sh:359`. Он не зависит от cwd (C1). Слой без профиля и профиль в родителе остаются станцией, побайтно как на базе. Своего резолвера и новых флагов нет. Строка реестра точная (A.registry-exact).
- **И2 — соответствует.**
  - Хук исполняет живой `check_staged.sh` установки с аргументом R (регистратор).
  - Отказ двери доходит до rc 1 (G, B). Хук не пустой, `--no-verify` нет.
  - Хук работает при `/dev/null` в клоне и при паре вызывающего (F).
  - Имеющийся `.git/hooks/pre-commit` не изменён и не исполнялся (A). Постоянный `core.hooksPath` не записан.
  - Каталог хука удалён и при успехе (A, X1 — /tmp), и при отказе (B). В HOME и `.git` остатка нет.
- **И3 — соответствует.**
  - Удалены все user.name/email, включая пустые и многозначные. Прочие ключи, в том числе одноимённые в других секциях, сохранены (A).
  - Identity orchestrator держится при чужих GIT_* (A).
  - Префлайт идёт до нормализации: битый профиль, не-main и грязное дерево оставляют `.git/config` байт-в-байт (D1–D3).
  - Неудавшееся удаление даёт именованный rc 1 без коммита (E).
- **И4 — соответствует.** rc 0, один коммит, только реестр, stdout точный, stderr — настоящая дверь. Теги, ветки и origin не изменены (A).
- **И5 — соответствует.**
  - Отказ двери: rc 1 с причиной, HEAD, индекс и реестр прежние, игнорируемые файлы целы (B).
  - Повтор — ранний rc 1 (H1). `--no-verify` — rc 1 и usage (H2). Не-репозиторий — rc 2 (H3).
- **И6 — соответствует.** Двенадцать станционных миров (база против OBJECT): rc, stdout, stderr, HEAD, status, реестр, config, refs, рекурсивный `.git` и origin побайтно равны (DIFF 0).

**Приёмка:**
- Строки `--repo`/`--model`/`--stabs`/`--sintaksis` зелёные с числами выше. Границы ≥ 16 клеток / ≥ 11 копий / ≥ 14 предъявлений выполнены: 17 / 14 / 18.
- Проводка: `check_provodka` rc 0, `gen_ci_steps --check` rc 0.
- CI-шаг вызывает guard `red_mint_line_proekt_221.sh` в режимах `--repo .`, `--stabs`, `--sintaksis` — строка `registry/ci-steps.tsv` и ключ `check:mint-line-proekt-221-family-selftest` в lane l5 `ci.yml`.
- Правило допуска — см. §2а.

ОСТАТОК (контракт 192; строки НЕ ЗАЩИЩАЕТ):
- **НЗ-1 «компрометация установки/PATH/git, single-uid» (ловцы: изоляция станции, CI, reviewer) — не укусил.**
  - Дифф не меняет поиск `git`/`bash` через PATH и не читает новых env, кроме `GIT_CONFIG_COUNT`.
  - Хук зовёт абсолютный `$SELF_DIR/check_staged.sh` установки, не `$ROOT/scripts` (регистратор: `SELF=…/tools-rec/scripts/check_staged.sh`).
  - Канал `git -c` вызывающего (`GIT_CONFIG_PARAMETERS` core.hooksPath=/dev/null) побеждает пару mint_line. Но это fail-closed rc 1 «дверь 031 отключена», не обход (X2). Подмена хука через тот же канал у вызывающего — прежний остаток 068 «hooksPath-инъекция -c», в станционной ветви он тот же.
- **НЗ-2 «профильный путь внутри 031 (`check_staged.sh:780/793`)» — не укусил предмет.** Дифф `check_staged.sh` не трогает. Отказная клетка и мой мир B идут на корневом реестре, как объявлено.
- **НЗ-3 «конкурентная запись config / сбой FS» — не укусил.** Сбой удаления (lock) даёт именованный rc 1 (E). Новых замков нет.
- **НЗ-4 «скратч lib_zones двери» — укусил, как объявлено.** В TMPDIR мира A после успешного минта остались `lib_zones.9fc56b88.7uniCa` и `lib_zones.9fc56b88.active`. Это дверь, не хук 221.

СВЕРКА-СТАНДАРТОВ: н/п — `AGENTS.md` этого репозитория не объявляет документов архитектуры или стандарта кода (поиск `ARCHITECTURE.md|CODING-STANDARDS` пуст). Shell-форма проверена пиновым shellcheck: дельта новых предупреждений не дала.

СВЕРКА-АРХИТЕКТУРЫ: н/п. Модели 188 (`bindings.json`) в дереве нет. Дифф не вводит сервисов, операций, писателей реестра или зависимостей: клиент существующей двери 031 и существующий `project_paths_resolve`. Долг не расширен, diff модели — нет (К-17 листа «н/п» подтверждаю).

## 4. Подгонка под код и норма 050

**Клетки не подогнаны.**
- Ожидания `probe221.py` выводятся из снимка мира до вызова, из честной модели (`model/mint_line.sh`, переменные `HOOK_WORK`/`key`/`cfg_rc` — независимая от production реализация) и из живой двери. Текст production не используется.
- Носители заморожены sha256 (`source.json`) и не менялись после `frozen/contracts/221/1`. Implementer и orchestrator в семью не писали.

**Красность на своих мутантах production** (замены не совпадают с якорями стабов: стабы мутируют модель, а не production, и другими заменами). `mut.py`, `W --repo <мутант>`:
```
R1-unset-nonempty-only  (--unset-all "$_mint_key" '.+')            rc=1 KLETKI 17 KRASNYH 1  p03-empty-config:…FILE_IDENTITY_LEFT
R2-rollback-index-only  (checkout HEAD -- → restore --staged --)    rc=1 KLETKI 17 KRASNYH 3  p07:REFUSAL_NOT_ATOMIC, s03/s05:STATION_BYTE_PARITY
R3-hookpath-only-if-unset (GIT_CONFIG_* только если hooksPath пуст) rc=1 KLETKI 17 KRASNYH 1  p06-disabled-config-hook:MINT_RC,…
R4-committer-from-caller (GIT_COMMITTER_NAME="${GIT_COMMITTER_NAME:-orchestrator}") rc=1 KLETKI 17 KRASNYH 1  p05-foreign-env:IDENTITY
R5-trap-signals-only    (trap … EXIT → trap … INT TERM)              rc=1 KLETKI 17 KRASNYH 10 p01–p08,p11,p12:ONCE_HOOK_LEFT(tmp.*/pre-commit)
```
Мои мутанты на свойствах И1–И6 живыми не остались. Живые мутанты Adv221 — шесть дыр К-08, разобраны в §5.

**Паразитная сложность (норма 050)** — ответы на пять вопросов по каждому артефакту дельты:
- **Project-ветвь `:150-201`.** (1) И1–И3. (2) Состояние — временный каталог хука и env `GIT_CONFIG_*` процесса. Оно явное: путь виден в выводе двери через hooksPath, временное и убирается ловушкой. (3) При правке свойства меняется 1 файл, число не выросло. (4) Интерфейс не вырос: флагов и env не добавлено, кроме чтения `GIT_CONFIG_COUNT`. (5) Потребитель — клетки p01–p12, CI-шаг. Грамматика не дублируется: `project_paths_resolve` и `check_staged` переиспользованы. → **ESSENTIAL.**
- **`_mint_hook_cleanup` `:143-149`.** (1) И2, удаление на выходе. (2)–(3) Нет. (4) 7 строк вместо одной. Сохранение `$?` в EXIT-ловушке не влияет на код выхода — эквивалент C04 Adv221. (5) Потребитель — st13/p01/p07. → **ACCIDENTAL.**
  - Фрагмент `:144`, `:148`.
  - Отсутствующее свойство — «исходный код выхода сохраняется»: его даёт сам bash.
  - Простая форма — однострочный `trap 'rm -rf -- "$_mint_hook_work"' EXIT` модели, проходит те же строки.
  - Совет С-1 (не блок: обязательство не нарушено).
- **Канонизация `pwd -P` `:183-184`.** (1) Ни одно свойство её не требует: `mktemp -d` абсолютен. → **ACCIDENTAL**, совет С-2. Простая форма — удалить.
- **Дописывание к `GIT_CONFIG_COUNT` `:193-200`.** (1) Сохранение чужих process-local пар — свойство не из И1–И6. (2) Явно: читается env `GIT_CONFIG_COUNT`, интерфейс вырос на одно читаемое env. (4) Нечисловое значение молча обнуляется. → **ACCIDENTAL**, совет С-3. Простая форма модели проходит те же строки. Implementer выбирает: упростить или объявить свойство.
- **rc 2 на отсутствие `check_staged.sh` рядом `:177-180`.** Прежняя грамматика «нечем проверить». Без проверки хук упал бы, и вышел бы rc 1 (I03 Adv221). → допустимо, шапку `:52` дописать (С-3).

Ни одна находка 050 не нарушает обязательства контракта на достижимом состоянии, поэтому все — советы.

## 5. Дыры К-08 Adv221 — оценка

Каждую дыру сверил своей мерой на честной production. Во всех шести production свойство соблюдает. Значит, это остаток батареи: ремонт — Architect, ловец — reviewer при следующей правке семьи. Блока production нет.

| дыра | свойство | production | моя мера | итог |
|---|---|---|---|---|
| .1 остаток хука вне TMPDIR | И2 удаление на выходе | `mktemp -d` + `trap EXIT` (`:181`, `:185`) | A/B: HOOKDIR регистратора удалён; X1 /tmp удалён; HOME пуст; `.git` без изменений | соблюдает → Б-1 |
| .2 локальные refs/теги | И4/И5 теги не меняются | дельта не трогает refs | A/B: `for-each-ref` (кроме main) равен | соблюдает → Б-2 |
| .3 откат шире реестра | И5 только путь реестра | `checkout HEAD -- "$_REG_FILE"` (`:307`) | B: `secret.env`, `build/out.bin` целы; `status --ignored` равен | соблюдает → Б-3 |
| .4 признак project | И1 `harness.project.json` в R | `[ -f "$ROOT/harness.project.json" ]` (`:150`) | C1 чужой cwd → rc 0; слой без профиля и профиль в родителе → станция = база; X3 → project | соблюдает → Б-4 |
| .5 префлайт → нормализация | И3 «после префлайта» | `:126`/`:133`/`:154` до `:162` | D1–D3: `.git/config` байт-в-байт | соблюдает → Б-5 |
| .6 прочая конфигурация | И3 ключи/значения прочих | `git config --local --unset-all` | A: `[alias]`/`[user "work"]`/`[sendemail]`/signingkey целы, дифф только запрещённые | соблюдает → Б-6 |

## Сырой вывод ключевых прогонов

`W --repo .`:
```
REPO p01-no-hook GREEN … REPO p12-user-family-config GREEN
REPO s01-live-hook GREEN … REPO s05-live-door-refusal GREEN
KLETKI 17 KRASNYH 0
real	0m27.040s
rc=0
```
`W --stabs` (хвост):
```
stabs/st13-no-cleanup/mint_line.sh p01-no-hook RED ONCE_HOOK_LEFT(tmp.VmKkpDWhcs,tmp.VmKkpDWhcs/pre-commit) rc=0 …
stabs/st13-no-cleanup/mint_line.sh p07-live-door-refusal RED ONCE_HOOK_LEFT(tmp.u4nNyYlLb0,tmp.u4nNyYlLb0/pre-commit) rc=1 …
stabs/st14-user-section/mint_line.sh p12-user-family-config RED UNRELATED_CONFIG_CHANGED,RAW_CONFIG_PARITY rc=0 …
STABY 14 SVJAZI 18 ZHIVYH 0
rc=0
```
shellcheck:
```
In scripts/mint_line.sh line 76:
NEXT_ID_LIB=1
^---------^ SC2034 (warning): NEXT_ID_LIB appears unused. Verify use (or export if used externally).
sc rc=1
```
Рабочие скрипты прогонов — одноразовые, удалены после вердикта: `/tmp/dev-harness-verify/rev221-work/{own.py,extra.py,mut.py,dbg.py}`.
