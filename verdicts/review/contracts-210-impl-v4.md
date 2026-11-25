accept
OBJECT=377f89643a54e24104e784470ee28b8a4b73c6c2
СУД: репо=dev-harness; предмет=210; фаза=реализация; роль=reviewer; вызов=4 (узкий аттестат-перенос на r16; по SANKCIJA и R-0068); сессия=Rev210d (станция c907157c); модель-факт=anthropic/claude-opus-5-5 (метаданные среды судьи: Model anthropic/claude-opus-5-5; `bash scripts/models_actual.sh --tsv --bind --session Rev210d | cut -f1-3` → `reviewer	anthropic/claude-opus-5-5	allowed`, rc 0); автор Impl210* — MiniMax; предыдущий=verdicts/review/contracts-210-impl-v3.md (accept Rev210c на 499824d89) и archive/210/adversary-v6-fail-20dbcc1dc7 (FAIL только К-08); класс риска=рисковый
КЛАСС=КОДОВЫЙ. Блоков 0. Советов 2 (С-1, С-2) и наблюдение Н-1 — `.review/2026-11-25-2104.md`.

# Вердикт reviewer — 210, реализация, вызов 4 (узкий аттестат-перенос на r16)

**БЛОКИРУЕТ: нет.**

**СОВЕТ: 2** (С-1 — ось rc в батарее 210, architect; С-2 — потеря rc у внешних потребителей `charter_diff_paths`, отдельный предмет). Плюс наблюдение Н-1 (замер CI). Подробности в `.review/2026-11-25-2104.md`.

Перепроверил ВСЁ: область правки, сырой вывод, не переписаны ли проверки под код.

**Итог: accept.**
- Production r16 совпадает с судимым Rev210c на `499824d89`. Единственная разница — дрейф main, owner-коммит `62a012d73`, у него совпадает patch-id.
- Дельта Arch210h ограничена четырьмя файлами семьи 210 в зоне architect.
- Три новых стаба красны и на моих собственных мутантах production, сделанных другим текстом, чем якоря `MUTATIONS`.
- Прежние ожидания батареи не переписаны.
- Ось rc производителя (Б-1 Adv210f) — дыра батареи, а не production. На всех семи местах production отказывает при ошибке Git. По R-0068 она уходит в остаток С-1.

## Порядок судей

Класс риска — рисковый (контракт, строка 4). Порядок такой: adversary → reviewer.
- Adv210 v1–v4 и Adv210e v5 дали FAIL.
- Adv210f v6 (`20dbcc1dc7`) дал FAIL только по К-08, блок Б-1, и сам допускает перенос оси в Остатки (его §Блоки, «Оговорка по границе блока»).
- Правило остановки владельца R-0068 (постановка задания Rev210d): «FAIL только по К-08 → седьмого адверсария нет, находки в НЕ ЗАЩИЩАЕТ/остаток, дальше Rev210».

Этот вызов идёт после адверсария, не параллельно ему. SANKCIJA — «reviewer · 210 · 377f89643a54e24104e784470ee28b8a4b73c6c2», слово консультанта из постановки. Принятый остаток К-09 `scripts/lib_zones.sh:311` — слово консультанта m2283 (постановка).

## 1. Область правки

```
pwd → /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/te2997d090/m
git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/210/orchestrator-r16 refs/heads/main refs/heads/archive/210/adversary-v5-fail-05c75ff09f refs/heads/archive/210/adversary-v6-fail-20dbcc1dc7 → rc 0
git switch --detach 377f89643a54e24104e784470ee28b8a4b73c6c2; git rev-parse HEAD → 377f89643a54e24104e784470ee28b8a4b73c6c2
git remote add origin …; git fetch origin '+refs/tags/*:refs/tags/*' … → rc 0; origin/main = e767f5132c2c
git merge-base origin/main HEAD → cb136eb51e596c4397c4c04d71502b8fcfd2cc37
git diff --name-status cb136eb51 HEAD →
  M .githooks/pre-push                         (implementer)
  M .github/workflows/ci.yml                   (orchestrator)
  M fixtures/…/charter_tekst_do_tega_210/{SDACHA.md, model/check_charter.sh, model/pre-push, probe.py, stabs.tsv}; A model/path_readers.sh, transport.py   (architect)
  M registry/ci-steps.tsv, registry/ci-zamery.tsv   (orchestrator)
  M scripts/check_charter.sh                   (implementer)
  M scripts/check_contract_frozen.sh, scripts/check_zones.sh, scripts/next_id.sh   (implementer, расширение зоны — см. ниже)
  A verdicts/review/contracts-210-impl-v2.md   (reviewer)
```

`git log --format='%h %an | %cn | %s' cb136eb51..HEAD` даёт 16 коммитов. Сверено по `git log --name-only`: каждый коммит трогает только файлы своей роли.

| роль | коммиты | файлы |
|---|---|---|
| implementer | 97510e9b2, 3b6615fc7, 43c4324f7, 918c121cc, 2bcf03c97 | `scripts/check_charter.sh`, `.githooks/pre-push`, `next_id.sh`, `check_contract_frozen.sh`, `check_zones.sh` |
| architect | 18d371c5f, a8b460850, 4140b9122, 30193eace, 377f89643 | только `fixtures/workshop_project/charter_tekst_do_tega_210/` |
| orchestrator | ec4a77628, 0c1380237, fd69c3235, d883e0522, 5964087db | только `registry/ci-steps.tsv`, `registry/ci-zamery.tsv`, `.github/workflows/ci.yml` |
| reviewer | fec551081 | `verdicts/review/contracts-210-impl-v2.md` |

`ЗОНА implementer` frozen-контракта называет `scripts/check_charter.sh .githooks/pre-push`. Три остальных файла (`next_id.sh`, `check_contract_frozen.sh`, `check_zones.sh`) требует таблица миграции арбитража 210 (`origin/wip/210/arbiter-v1:verdicts/arbitration/predmet-210-granica-imen-putej.md`, §2): «Последние два файла нельзя пропустить». Расширение по слову владельца 23.11 принято Rev210 v1 (`43eff87fb4`, строка 48) и Rev210b. Этим вызовом не перепроверялось. Новых путей вне этих зон дифф не несёт. Вне зоны ничего нет.

**Production не менялась с Rev210c, если не считать дрейфа main.** Своя мера, тремя независимыми способами:

```
git diff --stat 499824d89 1f69756856705143b4cb0941b6db9884edc706d9 -- scripts/ .githooks/   → пусто (rc 0)
git diff --stat 1f69756856705143b4cb0941b6db9884edc706d9 377f89643 →
  fixtures/…/charter_tekst_do_tega_210/{SDACHA.md 99, probe.py 18, stabs.tsv 10, transport.py 71}
  scripts/check_charter.sh | 8 ++
сравнение блобов 16 файлов 210: HEAD:<f> против 499824d89:<f> → SAME у 11, DIFF у SDACHA.md, probe.py, stabs.tsv, transport.py (Arch210h) и scripts/check_charter.sh
git diff 1f697568 HEAD -- scripts/check_charter.sh | git patch-id → fa453359224e…
git show 62a012d73 -- scripts/check_charter.sh | git patch-id     → fa453359224e…  (owner: grandfather 1fb51dc3 (217) и 8f2dc6c2 (143))
```

Дельта `check_charter.sh` — это ровно owner-коммит main `62a012d73`: 8 строк grandfather 217/143, на main с `cb136eb51`. Это не правка 210. Нормативные документы (`roles/`, `AGENTS.md`, контракт) дифф 210 не трогает. Блоб контракта равен `frozen/contracts/210/1` (`9c46a64a…` = `9c46a64a…`).

## 2. Сырой вывод

Окружение: `TMPDIR=/tmp/dev-harness-verify/scratch-rev210d`, `VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck`. Все прогоны шли в одноразовом клоне `…/scratch-rev210d/clone` (`git clone --no-hardlinks` копии, origin = GitHub, аннотированные теги GitHub, detached на OBJECT). После всех прогонов `git status --short` клона пуст, HEAD = OBJECT. Станция под нагрузкой (load ≈ 15 на 16 ядрах).

| # | команда | rc | вывод |
|---|---|---|---|
| 1 | `W --repo .` | 0 | `ИТОГ 210: KLETKI=342 ZELENYE=342 KRASNYE=0`, 104 с |
| 2 | `W --model` | 0 | `ИТОГ 210: KLETKI=342 ZELENYE=342 KRASNYE=0`, 102 с |
| 3 | `W --stabs` | 0 | `ИТОГ 210: MUTACII=46 SVJAZI=60 POIMANY=60 ZHIVYH=0`, 52 с; все 60 строк `POIMAN`, включая 10 новых (NUL-OWNER-CC ×4, NUL-167-CM-READ ×2, NUL-167-CM2-READ ×2, EMPTY-PROBE-RC-IGNORED, EMPTY-PROBE-RC-UNCHECKED) |
| 4 | `W --syntax` | 0 | `210 SYNTAX: bash=4 python=2` |
| 5 | `bash scripts/check_sdacha.sh "$PWD" contracts/210-charter-tekst-do-tega.md --run` | 0 | `СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=6)`, 427 с |
| 6 | `bash scripts/pre_critic.sh contracts/210-charter-tekst-do-tega.md` | 0 | `КРИТИК: дверь зелёная`, 369 с (строки «модель угроз красна», «потолки красны», «проводка красна», «сдаточный лист красен» — самопроверки гейтов, см. SDACHA) |
| 7 | `bash scripts/check_charter.sh` (полный) | 0 | `уставных документов: 192 · изменений в них: 597 · с разрешения: 597`, 35 с; среди ok 11 пар «внесён публикацией заморозки» по 7 контрактам (205, 206, 207, 209, 210, 211, 212) |
| 8 | `bash scripts/check_charter.sh --incr <кеш=HEAD>` | 0 | `incr: check_charter судит 377f8964..377f8964 (0 коммитов)`; `192 · 12 · 12`, 15 с; кеш после прогона = `377f89643a54…` |
| 9 | `bash scripts/check_contract_frozen.sh` | 0 | `планов и контрактов на HEAD: 199 · черновиков: 9 · заморожено: 190 · реестр: full`, 9 с |
| 10 | `bash fixtures/charter_fast_113/red_113.sh` | 0 | `клеток: 28 · красных: 0`, 41 с (холодный клон 11 с) |
| 11 | `bash …/check_zones_incr_207/red_check_zones_incr_207.sh --repo .` | 0 | `KLETKI=50 ZELENYE=50 KRASNYE=0`, 106 с |
| 12 | `bash …/okno_zamorozki_200/red_okno_zamorozki_200.sh` | 0 | `ИТОГ 200 (субъекты дерева): клеток 11, красных 0, зелёных 11` |
| 13 | `bash scripts/verify_antiplacebo.sh . --scope check_charter` | 0 | `барьеров: 1 · фикстур: 13 · предъявлено красным повторным прогоном: 13` |
| 14 | shellcheck 0.11.0 `-S warning -f gcc`, OBJECT против `git archive cb136eb51` | — | число находок OBJECT/база: `check_charter.sh 6/6`, `pre-push 2/2`, `next_id.sh 2/3`, `check_contract_frozen.sh 2/2`, `check_zones.sh 9/9`; новых текстов (`comm -23`) 0 у каждого — не хуже базы |
| 15 | `bash -n` на `check_charter.sh`, `pre-push`, `next_id.sh`, `check_contract_frozen.sh`, `check_zones.sh`, `model/{check_charter.sh,pre-push,path_readers.sh}`, обёртке | 0×9 | — |
| 16 | `bash scripts/gen_ci_steps.sh --check` | 0 | — |
| 17 | двери формы п.4: `check_spec_ready`, `check_ids`, `check_ceilings`, `check_precision_gate`, `check_threat_model`, `check_predposylki`, `check_provodka --grammar` | 0×7 | `OK`; `номера уникальны…`; `потолки в порядке`; `OK`; `ЗАЩИЩАЕТ 3 … НЕ ЗАЩИЩАЕТ 4`; `PREDPOSYLKI_OK … settings=1`; — |
| 18 | `bash scripts/check_provodka.sh . contracts/210-charter-tekst-do-tega.md` (полный, п.7) | 0 | — |

Не запускал полный интеграционный `check_zones.sh`: по постановке это не в скоупе, его восполняет main.

Счётные утверждения я проверял своей мерой, другой командой: импортировал `probe.py` (`sys.dont_write_bytecode`) и посчитал `awk` по `stabs.tsv`.
- `len(cells())=342`, уникальных имён 342.
- `len(MUTATIONS)=46`.
- Привязок 60 при 46 различных именах.
- На r15c (`1f697568:stabs.tsv`) привязок было 50.
- Новых клеток Arch210h 17: `wire-ownermerge*` 8, `wire-167-cm{,2}read-*` 8, `wire-errors-probe` 1.

Итого 325+17=342, 41+5=46, 50+10=60. Это сходится с SDACHA и с Adv210f.

## 3. Подгонка под код

**Клетки наблюдают поведение мира, а не текст скрипта.**
- Каждая клетка Arch210h строит настоящий git-мир через commit-tree: owner-merge с путём, отличным от обоих родителей, или merge с объединением реестра и нарушающим путём `zzz/…` после `registry/contracts.tsv`.
- Клетка запускает извлечённую из production функцию (`owner_docs_paths`, тело цикла owner, `merge_167_razreshen`) либо весь `check_charter.sh` с обёрткой `git`, которая роняет только `log -1`.
- Сверяются полные rc, stdout и stderr.
- Ожидания строятся до запуска субъекта, из формы мира.

**Красность на стабе — моими мутантами production, а не через `MUTATIONS`.** Сборщик `mkmut.py` копирует 11 исходников `sources()` из клона и делает одну замену. Якорь проверяется на однократность. Текст замены выбран отличным от якорей стабов. Запуск: `python3 probe.py --repo <мутант> --cell <glob>`.

| мутант (своя замена) | `--cell` | rc | красные | честные соседи |
|---|---|---|---|---|
| mutA: `pre-push:374` `diff-tree -z --cc` → `diff-tree --cc` | `wire-ownermerge*` | 1 | 4/8: `wire-ownermerge{,read}-{ascii,quote}-edit` | 4 `*-history` ok |
| mutB: `pre-push:282` `mapfile -d '' -t cm <` → `mapfile -t cm <` | `wire-167-cm*` | 1 | 2/12: `wire-167-cmread-deny-{ascii,quote}` | cm2read, allow, прежние cm/cm2/d* — ok |
| mutC: `check_charter.sh:1155` `[ "$__ch_pr" -ne 0 ]` → `[ "$__ch_pr" -lt 0 ]` (rc пробы игнорируется) | `wire-errors-*` | 1 | 1/5: `wire-errors-probe` | scope/log/empty/truncated ok |

Наблюдаемое различие каждой клетки (expected → actual мутанта):
- `wire-ownermergeread-quote-edit`: `(1, b'', b'ОТКАЗ: pre-push: docs/owner/ пишет только owner … путь=docs/owner/a"quote.md\n')` → `(0, b'', b'')`. Отказ owner-канала пропал молча.
- `wire-167-cmread-deny-quote`: `(0, b'1\n', b'')` (запрет) → `(0, b'0\n', b'')` (разрешено).
- `wire-errors-probe`: `(1, b'', b'  FAIL пустой или оборванный протокол git log: проверить невозможно\n  ok   AGENTS.md …')` → `(0, b'', b'  ok   AGENTS.md …')`. Ошибка Git превратилась в чистый результат.

**Прежние ожидания не переписаны.** `git diff 1f697568 HEAD -- probe.py transport.py` прочитан построчно. Все правки затрагивают только новые ветви: `seam in ('ownermerge','ownermergeread')`, `reader_only`, `variant == 'probe'`, новые override-виды `wire-probe-ignored`, `wire-owner-merge-lost`.
- Для прежних клеток `left/right` при `reader_only=False` дают прежнее `'cm2'/'cm'`.
- Карта `effect` для `empty`/`truncated` и `selector` `*" --name-only "*` у прежних вариантов те же.
- Ветка `owner`/`ownerread` без изменений.
- В `stabs.tsv` 50 прежних строк не тронуты, только +10.

SDACHA прямо называет единственную поправку в ходе работы: первое `--stabs` дало 58/60, и было исправлено контрфактическое ожидание мутанта-производителя. Ожидание честной клетки при этом не менялось. Мои мутанты от этого ожидания не зависят: mutA краснит клетку честной production независимо от `MUTATIONS`. Производство и батарею писали разные роли в разных коммитах. Production после Arch210h не менялась, так что клетки предъявлены к уже реализованному коду и красны только на мутантах.

## 4. Ось rc (остаток Б-1 Adv210f)

Для каждого места: что делает production при ошибке Git; превратила бы потеря rc эту ошибку в чистый результат; достижимо ли это в штатной работе.

| место | production (по коду OBJECT) | мутант «rc потерян» | достижимость |
|---|---|---|---|
| R1 `.githooks/pre-push:221` `d1` | `… > "$paths_167" \|\| { rm -f …; return 1; }` → исключение 167 не дано → `merge_main_verdict` (`:333`) идёт в общий запрет merge main→wip → `ОТКАЗ`. Fail-closed | пустой `d1` → `peresech=0`; дальше `merge-tree` и `[ "$auto1" = "$tree" ]` (`:239–240`). Отличие только при «`d1∩d2` непусто с одинаковым содержимым» (Adv210f, [INFERENCE]) | ошибка `git diff` на локальных объектах пушимого merge недостижима штатно [INFERENCE]; плюс соседняя проверка merge-tree |
| R2 `:223` `d2` | то же | то же | то же |
| R3 `:281` `cm` | то же → `return 1` | пустой `cm` → поштучная сверка с `auto1` пропущена → `0` (разрешено) | ошибка Git на `p1`/`c` (локальные) недостижима штатно [INFERENCE] |
| R4 `:283` `cm2` | то же | то же | то же |
| R5 `:427` кольцо | `if ! charter_diff_paths … > "$delta_file"` → `ОТКАЗ: pre-push: дельта коммита не читается`, `rc=1` | пустая дельта → устав-правка проходит молча | то же [INFERENCE] |
| R6 `:461` owner | `if ! owner_docs_paths … > "$owner_file"` → `ОТКАЗ: pre-push: owner-дельта не читается`. Внутри `np=$(rev-list … \| awk …) \|\| return 1` при `set -uo pipefail` (`:69`) | пустой поток → не-owner правка `docs/owner/` проходит | то же [INFERENCE] |
| R8 `scripts/check_charter.sh:940` оракул | `\|\| dt_rc=$?` → `bad "… не читается (diff-tree rc=…)"` | `изменений без разрешения нет` на нечитаемой дельте | то же; быстрый режим имеет свои клетки `wire-errors-{scope,log,empty,truncated,probe}` |

`charter_diff_paths` (`scripts/check_charter.sh:422–429`) возвращает rc своего `diff-tree`. Если `c^1` не разрешается, работает ветвь без родителя, которой для не-корневого коммита тоже нужны объекты родителя. Её rc тоже не теряется [INFERENCE].

**Вывод.** На всех семи местах production сохраняет rc и отказывает с именованной причиной. Мутанты, которые потеряли бы rc, — дыра батареи (К-08). Это не дефект production. Ошибка Git на объектах коммита, только что выданного `rev-list`, в штатной работе недостижима: нужны порча объектной базы, отказ ввода-вывода или сигнал [INFERENCE]. Значит, это совет и остаток с ловцом: С-1, architect, при следующей правке батареи 210; ловец — reviewer. Блока нет.

Попутно (С-2, вне 210): у внешних потребителей `scripts/check_contract_frozen.sh:248` и `scripts/check_zones.sh:493` rc производителя теряется на подстановке процесса `done < <(charter_diff_paths …)`. Соседи — `check_contract_frozen.sh:95`, `:190`, `check_zones.sh:476` с `|| true`. На базе `cb136eb51` форма та же (`:232`, `:489`). Арбитраж требует от этих мест только смены wire-format, контракт относит v+1-окна к НЗ-3.

## 5. Соответствие контракту

| обязательство | команда на OBJECT | rc / результат |
|---|---|---|
| Приёмка 1 | `W --repo .` | 0, 342/342/0 |
| Приёмка 2 | `W --model` | 0, 342/342/0 (frozen 36 — числа пачки, текущее 342 ⊇) |
| Приёмка 3 | `W --stabs` | 0, 46/60/60/0 (frozen 18/20 исторические) |
| Приёмка 4 | семь дверей формы | 0×7 |
| Приёмка 5 | `check_sdacha --run`; `pre_critic` | 0 (427 с ≤ 900); 0 «КРИТИК: дверь зелёная» |
| Приёмка 6 | `W --syntax`; shellcheck пин | 0; не хуже базы |
| Приёмка 7 | `gen_ci_steps --check`; полный `check_provodka` | 0; 0 |
| И1–И10 | клетки 342 (`a*`, `b*`, `g1–g25`, `v1–v8`, `nul-*`, `wire-*`, `empty-*`) и полный `check_charter` на дереве: 11 пар «внесён публикацией заморозки», 597/597 | зелёно; И8 — `grandfather_pair` 70/71, 72–74 и новые 217/143 owner-канала, `a2`/`a3` зелёные |

## Остатки

Строки НЕ ЗАЩИЩАЕТ контракта с ловцом reviewer (контракт 192):
- ОСТАТОК: НЗ-1 (воля человека, администрирование origin) — не укусил. Предикат публикации и owner-канал с Rev210c не менялись, дельта r16 — только фикстуры.
- ОСТАТОК: НЗ-2 (plans/ROADMAP/AGENTS, /2+, draft вне /1, octopus) — не укусил. Production дельтой не тронута.
- ОСТАТОК: НЗ-3 (будущие v+1-окна `check_contract_frozen`/`check_zones`) — не укусил дифф 210. Потеря rc на `check_contract_frozen.sh:248`, `check_zones.sh:493` существовала на базе в той же форме (С-2, отдельный предмет).
- НЗ-4 (сговор автора батареи) — ловец adversary, отработан шестью вызовами.

Остатки вердиктов адверсариев, file:line:
- К-09 принят словом консультанта m2283: `scripts/lib_zones.sh:311` (`ls-tree -r --name-only`, строковое имя frozen-контракта).
- Б-1 Adv210f, ось rc → С-1: `.githooks/pre-push:221`, `:223`, `:281`, `:283`, `:427`, `:461`; `scripts/check_charter.sh:940`.
- Эквивалентные и вне области (Adv210f): `scripts/check_charter.sh:423` (корень без `--root` при MD пуст), `scripts/check_zones.sh:1064`.
- NUL-разбор батч-потока `check_zones.sh` (не в таблице арбитража, ловцы — батареи 040/207): `:952`, `:1139`, `:1146`, `:1227`, `:1791`. Моя батарея 207 зелёная: 50/50.
- `scripts/next_id.sh:300`: стрип служебного LF, эквивалент на git 2.43.0.
- `scripts/next_id.sh:234`, `:600`: ролевые локации, не имена Git.
- Pathspec без `:(literal)`: `scripts/check_charter.sh:761`; `scripts/check_contract_frozen.sh:190`, `:202` (v5).
- `scripts/check_contract_frozen.sh:95`: `ls-tree … || true`, на базе то же (v5).
- Подстановка процесса: `scripts/check_contract_frozen.sh:248`, `scripts/check_zones.sh:493` → С-2.
- Вне пяти файлов (v5 и Rev210 v1): `scripts/check_staged.sh:676`, `scripts/land_agent.sh:268-270`, `scripts/check_sdacha.sh:105`, `scripts/check_ids.sh:286`, `scripts/lib_plan.sh:401`, `scripts/gitw_teg_130.sh:78,83`, `scripts/lib_karta_sdachi.sh:205`, `scripts/check_protected.sh:353,357,618,642,644`.

Паразитная сложность (050). Новые артефакты дельты Arch210h, одной семьёй фикстур:
- **A1. 17 клеток и ветви `observe`** (`transport.py`, +~70 строк).
  1. Свойство — К-08/К-09 и требование арбитража «каждого независимого места чтения с наблюдаемым отличием».
  2. Состояние — TemporaryDirectory мира, явное.
  3. Совместно меняются `transport.py`, `probe.py`, `stabs.tsv`; число файлов не выросло.
  4. Интерфейс CLI не изменился (`--cell`, режимы прежние).
  5. Потребитель — CI-строка self-test 210 и `check_sdacha`.

  Более простая форма — без этих клеток. Она оставляет живыми мои mutA/mutB/mutC, то есть строки приёмки К-08 не проходит. **ESSENTIAL.**
- **A2. Пять мутаций и десять привязок** — адресация по коду (Н-39). **ESSENTIAL.**

СВЕРКА-СТАНДАРТОВ: `AGENTS.md` станции не объявляет документ архитектуры и стандарт кода (`grep -c 'ARCHITECTURE.md\|CODING-STANDARDS' AGENTS.md` → 0; `docs/ARCHITECTURE.md`, `docs/CODING-STANDARDS.md` отсутствуют). Разделов для сверки нет. Дельта r16 — только Python и TSV фикстур, стиль соседнего кода семьи соблюдён.

СВЕРКА-АРХИТЕКТУРЫ:
- размещение — в существующей семье `fixtures/workshop_project/charter_tekst_do_tega_210/`;
- зависимости — прежние (`probe.World`/`EmptyWorld`, настоящий git);
- писатели — миры под TMPDIR, удаляются сразу;
- операции production не менялись;
- `bindings.json` предмета и `tooling/checks/cli.js` в дереве нет, дифф модели L0;
- долг не расширен.

## Сырой вывод ключевых прогонов

```
W --repo .        : ИТОГ 210: KLETKI=342 ZELENYE=342 KRASNYE=0                     rc=0 sec=104
W --model         : ИТОГ 210: KLETKI=342 ZELENYE=342 KRASNYE=0                     rc=0 sec=102
W --stabs         : ИТОГ 210: MUTACII=46 SVJAZI=60 POIMANY=60 ZHIVYH=0             rc=0 sec=52
W --syntax        : 210 SYNTAX: bash=4 python=2                                    rc=0
check_sdacha --run: СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=6)             rc=0 sec=427
check_charter     : уставных документов: 192 · изменений в них: 597 · с разрешения: 597   rc=0 sec=35
check_charter --incr (кеш=HEAD): incr: check_charter судит 377f8964..377f8964 (0 коммитов); 192 · 12 · 12   rc=0 sec=15; кеш=377f89643a54…
check_contract_frozen: планов и контрактов на HEAD: 199 · черновиков: 9 · заморожено: 190 · реестр: full   rc=0
red_113           : клеток: 28 · красных: 0                                        rc=0
red_207 --repo .  : KLETKI=50 ZELENYE=50 KRASNYE=0                                 rc=0
red_200           : ИТОГ 200 (субъекты дерева): клеток 11, красных 0, зелёных 11   rc=0
verify_antiplacebo --scope check_charter: барьеров: 1 · фикстур: 13 · предъявлено красным повторным прогоном: 13   rc=0
mutA --cell 'wire-ownermerge*'   : KLETKI=8 ZELENYE=4 KRASNYE=4   rc=1
mutB --cell 'wire-167-cm*'       : KLETKI=12 ZELENYE=10 KRASNYE=2 rc=1
mutC --cell 'wire-errors-*'      : KLETKI=5 ZELENYE=4 KRASNYE=1   rc=1
pre_critic        : КРИТИК: дверь зелёная                                         rc=0 sec=369
```

Среда: scratch `/tmp/dev-harness-verify/scratch-rev210d` вне копии (запись туда разрешена), одноразовый клон со своим `.git`. Основной чекаут станции не затрагивался. Мутанты собраны отдельными деревьями из 11 файлов в scratch, клон не мутировался. Перед докладом scratch удалён.
