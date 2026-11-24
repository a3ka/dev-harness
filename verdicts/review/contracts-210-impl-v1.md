FAIL
OBJECT=a8123cf02f398fbc4f5e0eb247c2c8b15d6dc1a5
СУД: репо=dev-harness; предмет=210; роль=reviewer; вызов=1 (полный); фаза=реализация; модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5 (метаданные среды выполнения судьи: Model anthropic/claude-opus-5-5; `bash scripts/models_actual.sh --tsv --bind --session Rev210 | cut -f1-3` → `reviewer	anthropic/claude-opus-5-5	allowed`, rc 0); предыдущий=нет; класс риска=рисковый
КЛАСС=КОДОВЫЙ. Блок 1 (Б-1, orchestrator: OBJECT снимает с CI чужой self-test 205). Советов 2 (С-1, С-2, implementer). Находки — в `.review/2026-11-24-157.md`.

# Вердикт reviewer — 210, реализация, вызов 1 (полный)

**Итог.** FAIL — только по Б-1.

Транспорт имён и предикат публикации в пяти production-файлах судимой реализации я принимаю:
- `--repo` 314/314/0, `--model` 314/314/0, `--stabs` 39/46/46/0;
- новые клетки Arch210e и Arch210f краснели на production до Impl210c и Impl210d (мой замер: 258/171/87 и 314/274/40);
- три собственные мутации production краснят `--repo` с rc 1;
- регресс зелёный.

Блок — в CI-части orchestrator. Коммит `ec22a6b05` при переносе на базу `14bc5c140` ЗАМЕНИЛ строку self-test 205 строкой 210 вместо того, чтобы добавить её. На OBJECT `check_provodka` для 205 даёт rc 1 «guard не подключён», на базе — rc 0. Это нарушает ПЕРЕСЕЧЕНИЕ orchestrator контракта 210 («чужие строки сохраняются») и Приёмку п.7.

## Область

```
pwd → /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tdd4660c25/m
git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/210/orchestrator-r11 refs/heads/archive/210/adversary-v{1..4}-fail-… refs/heads/wip/210/arbiter-v1 → rc 0
git switch --detach a8123cf02f398fbc4f5e0eb247c2c8b15d6dc1a5; git rev-parse HEAD → a8123cf02f398fbc4f5e0eb247c2c8b15d6dc1a5 (= origin/wip/210/orchestrator-r11)
git merge-base --is-ancestor 14bc5c140 HEAD → rc 0
git diff --stat 14bc5c140 a8123cf02 → 15 files, +1282 −251:
  .githooks/pre-push 74 · .github/workflows/ci.yml 12 · registry/ci-steps.tsv 2 · registry/ci-zamery.tsv 2
  scripts/check_charter.sh 256 · scripts/check_contract_frozen.sh 22 · scripts/check_zones.sh 25 · scripts/next_id.sh 46
  fixtures/workshop_project/charter_tekst_do_tega_210/{SDACHA.md,model/check_charter.sh,model/path_readers.sh,model/pre-push,probe.py,stabs.tsv,transport.py}
git diff --exit-code 'frozen/contracts/210/1^{commit}' a8123cf02 -- contracts/210-charter-tekst-do-tega.md → rc 0
```

Коммиты (`git log --format='%h %an|%cn'`, файлы — `git diff-tree --name-only`, по одному):

| коммит | автор | файлы | зона |
|---|---|---|---|
| 0bab4d98f | implementer | pre-push, check_charter.sh | да |
| ec22a6b05 | orchestrator | ci.yml, ci-steps.tsv, ci-zamery.tsv | зона да, содержание — **Б-1** |
| 6288542d5 | architect | fixtures/…210/ (SDACHA, model/check_charter.sh, probe.py, stabs.tsv) | да |
| 1cf83ae2a | implementer | check_charter.sh | да |
| be26e8a0e | architect | fixtures/…210/ (+ model/path_readers.sh, model/pre-push, transport.py) | да |
| cc196c86d | implementer | pre-push, check_charter.sh, check_contract_frozen.sh, check_zones.sh, next_id.sh | да, с расширением 23.11 |
| 568e8e532 | orchestrator | ci.yml, ci-steps.tsv, ci-zamery.tsv | да |
| 457e69a04 | architect | fixtures/…210/ | да |
| 06db45b95 | implementer | check_contract_frozen.sh, check_zones.sh | да, с расширением 23.11 |
| 531f73711 | orchestrator | ci.yml, ci-steps.tsv, ci-zamery.tsv | да |
| a8123cf02 | orchestrator | ci.yml | да |

- **Расхождение с frozen-зоной.** `ЗОНА implementer` контракта называет только `scripts/check_charter.sh .githooks/pre-push`. Три других файла (`next_id.sh`, `check_contract_frozen.sh`, `check_zones.sh`) входят в зону по расширению словом владельца 23.11 (основание — постановка), и миграцию этих мест требует перечень арбитража. Записи этого слова в дереве OBJECT я не нашёл (grep HANDOFF/contracts). Сверку с источником слова оставляю оркестратору; блоком не считаю.
- **Implementer фикстур не трогал.** Architect не трогал production.
- **Неподгонка.** Порядок коммитов: Arch210d `be26e8a0e` → Impl210c `cc196c86d`; Arch210f `457e69a04` → Impl210d `06db45b95`. Клетки предшествуют реализации; свой красный-до замер ниже, в §Проверки.
- **Транспорт без смены решений.** Diff пяти файлов прочитан построчно (`git diff 14bc5c140 a8123cf02 -- <5 файлов>`). Каждая правка вне нового предиката `charter_frozen_publication` и двух его мест вызова — одно из трёх:
  - (а) `-z`/`read -d ''`/`mapfile -d ''`/`sort -z`;
  - (б) отбор по ЗАПИСИ вместо `awk` по строке;
  - (в) fail-closed на rc производителя.

  Пункт (в): `pre-push:221–224,281–284` — `return 1`, т.е. merge 167 не разрешён; `pre-push:426–430,463–466` — именованный ОТКАЗ при нечитаемой дельте; `check_charter.sh` fast — именованный FAIL «пустой или оборванный протокол». Этого требует арбитраж («без потери rc производителя», «ошибка Git … не превращается в чистую область»).

  Не менялись: грамматика `razreshil`, `grandfather_pair`, owner-политика `docs/owner/` и её сообщение, условия 167 (`reg_167_stroka`, L/R/M), v+1-предикаты в `check_contract_frozen.sh`/`check_zones.sh`. Новый предикат публикации вызывается только в oracle, fast и кольце pre-push. В v+1-окнах его нет: И9 выполнен, НЕ ЗАЩИЩАЕТ п.3 не тронут.

## Сверка с предметом

**Чтения путей Git в пяти файлах.** `git grep -n -E 'ls-tree|name-only|diff-tree|log .*--name|name-status|ls-files|--raw|--stat|--numstat|find ' -- <5 файлов>` → rc 0. Каждое чтение имени — `-z`/NUL:
- `check_charter.sh:421,423` (`charter_diff_paths`), `:863` (ls-tree области → `sort -z` → `read -d ''`, отбор `*.md` по записи), `:1041` (`log -z --format=%x00%H`, автомат header/first/paths, снятие ровно одного служебного LF, проверка sha 40/64 hex);
- `pre-push:221,223,281,283` (167, во временный файл с проверкой rc), `:374,376` (owner_docs);
- `next_id.sh:286` (HEAD), `:310` (история, фильтр локаций по записи), `:646` (`find -print0`);
- `check_contract_frozen.sh:95`;
- `check_zones.sh:502,566` (селекторы HEAD и frozen-тега), `:1064` (уже был `-z`).

Не имя пути: `check_charter.sh:753` (`--format=%(objectname)`). Оба внешних потребителя `charter_diff_paths` (`check_contract_frozen.sh:241–248`, `check_zones.sh:486–493`) читают `read -r -d ''`. Других потребителей в `scripts/`, `.githooks/` нет (grep `charter_diff_paths|charter_frozen_publication`). Строкового адаптера не осталось.

**Предикат (И1–И7).** `charter_frozen_publication` (`check_charter.sh:681–765`), сверено по коду:
- И1: только `contracts/NNN-*` без вложенности, ref строго `frozen/contracts/NNN/1`. Plans/AGENTS/ROADMAP → rc 1.
- И2: `cb = tb` по именам блобов.
- И3: `c^2` несёт `tb` и сравним с T в обе стороны. Первичность: `T` не предок `c^1`, и в first-parent-линии `c^1 ^T` блоб `tb` ранее не встречался.
- И5: тип `tag`; объект ref буквально равен `ls-remote --refs --tags origin` (`<oid>\t<ref>`).
- И6: неизвестность → rc 2, и обе ветви и hook выводят именованную причину «не могу проверить публикацию заморозки».
- И7: суд по паре (C,P).

Живое подтверждение на настоящей истории станции: полный `check_charter` на OBJECT вывел `внесён публикацией заморозки` для 204–212 (`c25196f6`, `78579513`, `71384784`, `a1654418`, …) при живом origin; итог `191 · 591 · 591`, rc 0.

**Параметры батареи.**
- `--repo .` подставляет в миры байты production этого дерева (`transport.observe`: `sources` → `root/<имя>`; `probe.py` для полных CLI).
- `--model` подставляет модели `model/*`, `--stabs` — адресные мутации модели, по `stabs.tsv`.
- Оракул не самоопределяется из текста production. Ожидания — литералы и производные входных байтов, снимаются до запуска субъекта: `world.path`, `hash-object --stdin` по входным байтам, литеральные фразы FAIL/ok (`transport.py:261–279`, `:200–245`).
- Текст production используется только как вырезаемый шов (`between(...)`, `function(...)`). Неприменимый якорь → `Prerequisite` (rc 2), не зелёное.

**Модель/эталон.** Модель — предъявленный кандидат, не страж. Привязки мутаций — только `stabs.tsv`/`probe.py` (Н-39).

**sourceCanon (996).** Станция sourceCanon не объявляет — неприменимо.

**ПРОВОДКА (038).** Канал один: guard `fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh`. Он существует, это барьер именно 210, подключён строкой `registry/ci-steps.tsv` (`check:charter-tekst-do-tega-210-family-selftest`, вес 200). `bash scripts/check_provodka.sh . contracts/210-charter-tekst-do-tega.md` → rc 0. ПРОВОДКА-ЭНФОРСМЕНТ обоснована честно: ремонт энфорсмента 130/019/022, поведенческой нормы роли нет.

СВЕРКА-СТАНДАРТОВ: `AGENTS.md` станции документов архитектуры и стандарта кода не объявляет (grep `ARCHITECTURE|CODING-STANDARDS|стандарт кода` → нет совпадений; `docs/ARCHITECTURE.md`, `docs/CODING-STANDARDS.md` отсутствуют) — разделов для сверки нет. По форме модуля: новый предикат — одна библиотечная функция рядом с `razreshil` за существующим `CHARTER_LIB`-экспортом (приём 022). Отказы — именованные (приём 992). Расхождение формы — только С-2 (`next_id.sh:301`, неlocal `keep`), совет.
СВЕРКА-АРХИТЕКТУРЫ:
- Размещение — в существующих файлах зон; новых production-файлов нет.
- Зависимости — только git plumbing и уже импортируемые `next_id`/`check_charter`.
- Писатели — только временные файлы под `TMPDIR`/`$ROOT/tmp`; HEAD, индекс и мир не меняются (И10; батарея проверяет `snapshot` до/после).
- Операции — чтение.
- `bindings.json` и `tooling/checks/cli.js` в дереве нет → diff модели L0; долг не расширен; находку 188 не заводил.

Паразитная сложность (050):
- **`charter_frozen_publication`** (`check_charter.sh:681–765`).
  - (1) И2–И7.
  - (2) Состояние — только локальные и rc 0/1/2, видимые в выводе.
  - (3) Правка свойства: функция + модель + probe — столько же, сколько у прежних барьеров.
  - (4) Интерфейс — 3 позиционных аргумента и 3 rc, без env и флагов.
  - (5) Потребитель — приёмка п.1–3 и CI.
  - ESSENTIAL: Frontier 1/2 отвергнуты клетками g4/g5/g19–g23.
- **Автомат разбора fast** (`__ch_state`, `check_charter.sh:1062–1132`).
  - (1) Требование арбитража: «протокол записей, служебный LF».
  - (2) Состояние явное, именованные отказы.
  - (4) Интерфейс не вырос.
  - (5) Потребитель — клетки nul-*-fast/incr, wire-errors-*.
  - ESSENTIAL. Простая форма (`read -d` без состояния) отвергнута арбитражем.
- **Временные файлы pre-push** (`paths_167`, `delta_file`, `owner_file`).
  - (1) rc производителя.
  - (2) Видны в отказе.
  - (5) Потребители — wire-167-*, nul-*-push, wire-owner*.
  - ESSENTIAL.
- **Фильтр локаций в `next_id.sh`** (`joined_locs`, `keep`). ESSENTIAL: заменил `awk` по строке. Утечка `keep` — С-2.
- **Селекторы `check_zones.sh:502–506,566–569`, область `check_contract_frozen.sh:95–99`.** ESSENTIAL. Построчная запись `$TMP/files` — С-1.
- **Батарея** (`transport.py`, `model/path_readers.sh`, +клетки/строки `stabs.tsv`).
  - (1) Требование арбитража «Что обязана различать батарея».
  - (5) Потребитель — CI-шаг 210.
  - ESSENTIAL.
- **CI-строка 210 и её замер.** ESSENTIAL. Замена ею строки 205 — ACCIDENTAL-разрушение, Б-1.

## Проверки

Окружение: cwd = копия, `TMPDIR=/tmp/dev-harness-verify/scratch-rev210`, `VALIDATE_STD_SHELLCHECK=…/validators/shellcheck/0.11.0/shellcheck`. Для полного `check_charter`: `git remote add origin ssh://git@github.com/a3ka/dev-harness.git` и `git fetch … '+refs/tags/*:refs/tags/*'` → rc 0; `git cat-file -t frozen/contracts/210/1` → `tag`.

| Команда | rc | Вывод |
|---|---|---|
| `bash $W --repo .` | 0 | `ИТОГ 210: KLETKI=314 ZELENYE=314 KRASNYE=0`, 47 с |
| `bash $W --model` | 0 | `KLETKI=314 ZELENYE=314 KRASNYE=0`. Своя мера: python по выводу — 314 строк клеток, 314 уникальных имён, 0 KRASNO |
| `bash $W --stabs` | 0 | `MUTACII=39 SVJAZI=46 POIMANY=46 ZHIVYH=0`. Своя мера: `stabs.tsv` 47 строк − 1 комментарий = 46 связей; `cut -f1 \| sort -u` → 40 − комментарий = 39 мутаций; 46 строк `POIMAN` в выводе |
| `bash $W --syntax` | 0 | `210 SYNTAX: bash=4 python=2` |
| красное-до Impl210c (своё): одноразовый клон, `switch --detach be26e8a0e`, `$W --repo .` | 1 | `KLETKI=258 ZELENYE=171 KRASNYE=87` |
| красное-до Impl210d (своё): клон, `switch --detach 457e69a04`, `$W --repo .` | 1 | `KLETKI=314 ZELENYE=274 KRASNYE=40`: ровно 5 форм (quote, slash, cyrillic, nfc, nfd) × 8 клеток frozenscope/zoneshead/zonestag; space-формы зелёные как контроль |
| M1 (своя), клон @OBJECT: `charter_diff_paths` без `-z` (обе ветви, `check_charter.sh:421,423`) | 1 | `KRASNYE=58`: oracle/push-клетки всех форм, `wire-diff-*`; `wire-frozen-*` (actual `1\0\0` — fail-open v+1) и `wire-zones-*` (`1`). Откат, `status` пуст |
| M2 (своя): `check_contract_frozen.sh:95–99` → прежний `ls-tree --name-only \| awk '/\.md$/'` | 1 | `KRASNYE=20`. Откат, `status` пуст |
| M3 (своя): HEAD-селектор `check_zones.sh:502–506` → прежний `ls-tree --name-only \| awk index(...)` | 1 | `KRASNYE=10`. Откат, `status` пуст |
| `bash -n` пяти файлов | 0 ×5 | — |
| shellcheck 0.11.0 `-S warning`, OBJECT против `git show 4261dc18c:<файл>` | — | check_charter 6/6, pre-push 2/2, next_id 2/3 (ушёл SC2140), check_contract_frozen 2/2, check_zones 9/9. Коды совпадают (SC2034/SC1090/SC2046), новых нет |
| `bash fixtures/charter_fast_113/red_113.sh` | 0 | `клеток: 28 · красных: 0` |
| `bash fixtures/workshop_project/check_zones_incr_207/red_check_zones_incr_207.sh --repo .` | 0 | `KLETKI=50 ZELENYE=50 KRASNYE=0`, 75.6 с |
| `bash fixtures/workshop_project/okno_zamorozki_200/red_okno_zamorozki_200.sh` | 0 | `клеток 11, красных 0, зелёных 11` |
| `bash scripts/check_charter.sh` (полный) | 0 | `уставных документов: 191 · изменений в них: 591 · с разрешения: 591`, real 27.9 с |
| `bash scripts/check_charter.sh --incr $TMPDIR/charter.cache` (сеяние) | 0 | 191/591/591, 29.5 с; кеш = `a8123cf02f39…` = HEAD |
| то же, повтор, пустое окно | 0 | `incr: check_charter судит a8123cf0..a8123cf0 (0 коммитов)`, `191 · 12 · 12`, real 11.0 с; кеш = HEAD. 12 изменений — per-document окна 083 у документов с /1 вне предков кеша (080, 082, 097, 098, 129), все с разрешения |
| `bash scripts/check_contract_frozen.sh` | 0 | `планов и контрактов на HEAD: 198 · черновиков: 9 · заморожено: 189 · реестр: full` |
| `bash scripts/pre_critic.sh contracts/210-charter-tekst-do-tega.md` | 0 | «КРИТИК: дверь зелёная» |
| `bash scripts/check_sdacha.sh "$PWD" contracts/210-charter-tekst-do-tega.md --run` | 0 | «СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=6)», real 5m14s (≤900 с) |
| `bash scripts/gen_ci_steps.sh --check` | 0 | — |
| `bash fixtures/mint_line/red_mint_line_068.sh` | 0 | `ветвей 8, стабов 4, красных 0, зелёных 11, не прогнано 1`. Стабы стМ1/стМ2/стМ4 «мёртв», стМ3 «не построен» — ровно так же на базе `14bc5c140` (клон, rc 0): прежнее, не 210 |
| `bash scripts/check_provodka.sh . contracts/210-charter-tekst-do-tega.md` | 0 | пусто |
| `bash scripts/check_provodka.sh . contracts/205-provodka-gate-profilja.md` | **1** | «проводка: guard не подключён: fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh не вызывается в .githooks/ или .github/workflows/» |
| то же на базе `14bc5c140` (клон) | 0 | пусто |
| `git grep -n provodka-gate-205 <rev> -- registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml` | 14bc5c140: 0; ce5a4129e: 0; **a8123cf02: 1** | на базе и main — `ci-steps.tsv:324`, `ci-zamery.tsv:125`, `ci.yml:284` |

`$W` = `fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh`.

Мутанты — по одному, в одноразовом клоне `/tmp/dev-harness-verify/scratch-rev210/cl` со своим `.git`. После каждого — `git checkout -- <файл>`, `git status --porcelain | wc -l` → 0.

Полный интеграционный `check_zones.sh` в копии не запускал: под нагрузкой копии он не завершается (постановка). Это не блок, восполняют CI и main. Live-приёмка вне скоупа.

## Блоки

**Б-1 (orchestrator). OBJECT удаляет self-test 205 из CI.** Подробно — `.review/2026-11-24-157.md`.
- **Фрагмент.** `git diff 14bc5c140 a8123cf02 -- registry/ci-steps.tsv registry/ci-zamery.tsv`:
  - `-step	check:provodka-gate-205-family-selftest	18	bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --repo . && … --model && … --stabs` (база `:324`);
  - `-check:provodka-gate-205-family-selftest	18	16	0` (база `:125`);
  - на их местах — строки 210.

  Производный `ci.yml` (`gen_ci_steps --check` rc 0) ключа 205 больше не несёт. Внёс `ec22a6b05` (orchestrator|orchestrator). Его diff на OBJECT — замена строки, не добавление. Строка 205 пришла в main позже (`be10fee30`, 22:18) исходной записи 210 (20:39) и была перетёрта при переносе на `14bc5c140`.
- **Мера.** `check_provodka . contracts/205-…`: OBJECT rc 1 «guard не подключён», база rc 0. `git grep` ключа 205: OBJECT rc 1, база и текущий main `ce5a4129e` rc 0.
- **Обязательство.** frozen/contracts/210/1:
  - ПЕРЕСЕЧЕНИЕ orchestrator `registry/ci-steps.tsv` — «только новая строка self-test 210; чужие строки сохраняются»;
  - `registry/ci-zamery.tsv` — «чужие замеры сохраняются»;
  - `.github/workflows/ci.yml` — «чужая проводка сохраняется»;
  - Приёмка п.7 — «Orchestrator добавляет только self-test 210».
- **Достижимость.** Это сам OBJECT, предъявленный к слиянию: трёхсторонний merge в main снимет 205 с CI. Это не «конфликт CI-реестров с новым main»: удаление сделано против собственной базы OBJECT, где строка уже была.
- **Простая форма.**
  1. Вернуть обе строки 205 из `14bc5c140` побайтово и оставить строку 210 следующей.
  2. Выполнить `gen_ci_steps.sh --write`.
  3. Подтвердить: `gen_ci_steps --check` → rc 0, `check_provodka` для 205 и 210 → rc 0.
  4. Повторный суд — scoped, только CI-реестры и проводка. Production и батарея 210 этим не затрагиваются.

## НЕ ЗАЩИЩАЕТ

**Строки остатка контракта (§Модель угроз).** Номеров К-NN у них нет, нумерую НЗ-1..4 по порядку.
- ОСТАТОК: НЗ-1 (воля человека, администрирование и подмена origin; ловцы adversary/reviewer) — не укусил. Дифф не ослабляет сверку: И5 сравнивает объект ref с `ls-remote origin` буквально (`check_charter.sh:759–763`). Подпись тегов не вводится — заявленная граница.
- ОСТАТОК: НЗ-2 (plans/ROADMAP/AGENTS, /2+, draft-блобы вне истории /1, octopus через третий родитель; ловец reviewer) — не укусил.
  - `case "$p" in contracts/*)` и `*/*` → rc 1 (`:687–690`);
  - ref строго `/$nnn/1` (`:702`);
  - родитель только `c^2` (`:715`);
  - nul-plan-* (8 клеток) и g15 зелёные.
- ОСТАТОК: НЗ-3 (будущие v+1-окна `check_contract_frozen`/`check_zones`; ловцы гарды и reviewer) — не укусил. В обоих файлах изменилось только чтение NUL (`check_contract_frozen.sh:95–99,241`, `check_zones.sh:486,502–506,566–569`). Предикат и сообщения прежние, освобождение публикации в v+1 не вызывается.
- НЗ-4 (сговор автора батареи; ловец adversary) — не мой ловец. Оракул от текста production не самоопределяется (см. §Сверка).

**Остаточный риск по решению (Adv210d, вызов 4).** Загрузчик зон `scripts/lib_zones.sh:311–314` читает имя frozen-контракта строковым `git ls-tree --name-only` и сравнивает префикс через `awk index(...)`. C-цитированное имя (`"`, `\`, не-ASCII при `core.quotePath` по умолчанию) не начинается с `contracts/NNN-`. Поэтому `file` пуст и срабатывает `continue` до записи зоны и окна (прочитано: `lib_zones.sh:311–314`).
- Вне зоны 210 и вне обязательств контракта: `git diff --name-only 14bc5c140 a8123cf02` содержит 15 путей, `lib_zones.sh` среди них нет. В перечень мест миграции арбитража `lib_zones.sh` не входит. Обязательство 210 — освобождение публикации и транспорт его читателей, а не загрузчик зон.
- Достижимость: только штатное имя frozen-контракта с `"`/`\`/не-ASCII (next_id → mint → draft). Своя мера на OBJECT: `git ls-tree -r -z --name-only HEAD -- contracts/ plans/` → 198 имён, из них с байтами вне `\x21–\x7e`, кавычкой или обратной косой — 0. На текущем состоянии не укусил.
- Ловец (назван постановкой): до отдельной задачи имя frozen-контракта — только ASCII без кавычки и обратной косой (next_id → mint), иначе стоп. Задачу «NUL-чтение имён в lib_zones.sh и остатках» не создаю — она у владельца.
- Остатки вне зоны (список Adv210d §Остатки, не проверялись этим судом): `scripts/check_ids.sh:286`, `scripts/check_sdacha.sh:105`, `scripts/check_staged.sh:676`, `scripts/land_agent.sh:268`, `scripts/lib_plan.sh:401`, `scripts/gitw_teg_130.sh:78,83`, `scripts/lib_karta_sdachi.sh:205`, `scripts/check_protected.sh:353,357,618,642,644`, `scripts/lib_zones.sh:311–314`.

## Советы

- С-1 (implementer) — `.review/2026-11-24-157.md`. `check_contract_frozen.sh:95–99`: после NUL-чтения область снова пишется строками (`:98`), цикл читает `read -r`. Имя с LF (только plumbing; штатный commit его отвергает) разорвётся. [INFERENCE] Не измерено: в батарее нет frozenscope-lf.
- С-2 (implementer) — там же. `next_id.sh:301`: `keep` не `local` в библиотечной функции.

**Наблюдение (вне 210, не находка).** `red_mint_line_068.sh` даёт rc 0 при «не прогнано 1» и трёх мёртвых стабах. На базе `14bc5c140` — побайтово тот же итог.
