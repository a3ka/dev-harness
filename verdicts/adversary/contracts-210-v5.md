FAIL
OBJECT=1f69756856705143b4cb0941b6db9884edc706d9
СУД: репо=dev-harness; предмет=210; роль=adversary; вызов=5 (узкий, по SANKCIJA консультанта на этот OBJECT); фаза=реализация; модель-план=anthropic/claude-sonnet-5-5; модель-факт=anthropic/claude-sonnet-5-5; предыдущий=archive/210/adversary-v4-fail-b9ed2ad903 (FAIL Adv210d); класс риска=рисковый

Область: дельта после вызова 4 (Impl210e `e8191b62a`/`0c771816b`, Arch210g `1f6975685`/`861f559fc`), полнота по классу «имена путей», двусторонность. Зоны авторов сверены (`git log --format='%an' origin/main..OBJECT` + `diff-tree` по коммитам): architect — `fixtures/workshop_project/charter_tekst_do_tega_210/`; implementer — пять файлов зоны; orchestrator — `registry/ci-*.tsv`, `.github/workflows/ci.yml`; в OBJECT присутствует `verdicts/review/contracts-210-impl-v2.md` (коммит `ca3cd0227`, автор reviewer; в задании сказано «вердиктов Rev210 в OBJECT нет» — расхождение описи, не дефект кода). grandfather-список, грамматика `razreshil`, owner-канал, правила 167 в дельте `check_charter.sh` не менялись (строки сообщений только переотступлены).

## Блоки

Все три блока — класс К-08 (мутация production не краснится `W --repo`). Production в каждом случае ВЕРЕН: возврат на достижимом состоянии воспроизведён только на мутанте; блок — в том, что батарея не удерживает инвариант на этом месте. Правка — только в зоне architect (клетки `probe.py`/`transport.py`/`stabs.tsv`), production не трогать.

**БЛОКИРУЕТ Б-1 (К-08): ветка `--cc` в `owner_docs_paths` не удержана батареей** — `.githooks/pre-push:374` (`git diff-tree -z --cc --no-commit-id --name-only -r "$c" -- docs/owner/`).
- ОБЯЗАТЕЛЬСТВО: арбитраж 210 «сквозной NUL-транспорт», место миграции `owner_docs_paths` (две ветки: merge `--cc`, не-merge `--root`); задание п.4: возврат строкового чтения в `owner_docs_paths` обязан краситься `W --repo`.
- СОСТОЯНИЕ: слияние (2 родителя, автор ≠ owner), меняющее `docs/owner/x.md` относительно обоих родителей.
- НАБЛЮДЕНИЕ: мутант «`diff-tree --cc` без `-z`» (одна правка, `.githooks/pre-push:374`): `W --repo` rc 0, `KLETKI=325 ZELENYE=325 KRASNYE=0` — мутант жив. Мутант той же функции в ветке `--root` (`:376`) красится: rc 1, `KRASNYE=10` (`wire-owner-ascii/quote/slash/tab/lf`, `wire-ownerread-*`). Достижимое следствие мутанта (`owner_demo.py`, настоящий evil merge, функция извлечена из хука): production `records=1` (`docs/owner/x.md`), мутант `records=0` — читатель `read -d ''` не получает ни одной записи, проверка канала владельца для любого merge молча пустеет (и для ASCII-имени). Клетки `wire-owner-*`/`wire-ownerread-*` строят владельческий merge без собственной дельты (блоб равен правому родителю, `payload=b''`, `transport.py:177-188`): ветка `--cc` исполняется, но вывод пуст у обеих форм.
- Закрытие: клетка с merge, чей результат отличается от обоих родителей по `docs/owner/<имя>.md` (ASCII и `a"quote`), ожидание — одна NUL-запись и отказ `ОТКАЗ: pre-push: docs/owner/ пишет только owner …`; стаб «`--cc` без `-z`» в `stabs.tsv` (сейчас `NUL-OWNER` держит только ветку `--root`).

**БЛОКИРУЕТ Б-2 (К-08): читатели `cm`/`cm2` исключения 167 не удержаны батареей** — `.githooks/pre-push:282`, `:284` (`mapfile -d '' -t cm < "$paths_167"`, `mapfile -d '' -t cm2 < …`).
- ОБЯЗАТЕЛЬСТВО: те же — место миграции «исключение 167» (четыре диффа `d1/d2/cm/cm2`, каждый с читателем NUL).
- НАБЛЮДЕНИЕ: мутанты «читатель без `-d ''`» по одной строке: `:282` и `:284` — `W --repo` rc 0, `KLETKI=325 ZELENYE=325 KRASNYE=0` (живые); `:222` — rc 1 `KRASNYE=2`, `:224` — rc 1 `KRASNYE=1` (красятся). Причина: клетки 167 несут ровно один интересный путь, и он в сортировке стоит ПЕРВЫМ (`notes/a"quote.md` < `registry/contracts.tsv`); bash `mapfile -t` по NUL-потоку берёт только первую запись (замер `printf 'p1\0p2\0' | …`: строковый читатель `n=1 first=p1`, NUL-читатель `n=2`). Достижимое следствие мутанта (`cm_demo.py`, настоящие Git-миры, функции извлечены из хука): evil merge, откатывающий правку левого родителя по пути `zzz/evil.md` (после `registry/contracts.tsv` в сортировке): production `merge_167_razreshen` rc=1 (запрещено), мутант `:282` rc=0 (РАЗРЕШЕНО); тот же сценарий с путём `aaa/evil.md` — оба rc=1.
- Закрытие: клетки 167 `cm`/`cm2` с дельтой из ≥2 путей, где нарушающий путь сортируется после `registry/contracts.tsv`; стабы «читатель `cm`/`cm2` без `-d ''`».

**БЛОКИРУЕТ Б-3 (К-08 / ПЕРЕСЕЧЕНИЕ 992): независимый зонд законной пустоты не удержан батареей** — `scripts/check_charter.sh:1147-1149` (`__ch_pmatch="$(g log -1 --format=%H … HEAD 2>/dev/null)" || __ch_pr=$?` и `if [ "$__ch_pr" -ne 0 ] || [ -n "$__ch_pmatch" ]`).
- ОБЯЗАТЕЛЬСТВО: задание п.2 и ПЕРЕСЕЧЕНИЕ 992: «пустота только при rc 0 и пустом выводе; ошибки не превращать в ноль»; каждый мутант подавления rc обязан краситься.
- НАБЛЮДЕНИЕ (мутанты `W --repo`): `|| __ch_lr=$?`→`|| true` на основном `git log` — rc 1, `KRASNYE=1` (`wire-errors-log`) красится; «пустота при rc≠0 законна» (`__ch_lr` игнорируется при пустом файле) — rc 1, `KRASNYE=1` (`wire-errors-log`) красится; удалён `-n "$__ch_pmatch"` — красится (`wire-errors-empty`); «всегда законно» — красится (`wire-errors-empty`); «нет проверки хвоста `__ch_line`» — красится (`wire-errors-truncated`). ЖИВЫ два: (а) подавление rc зонда `|| __ch_pr=$?`→`|| true` (rc 0, `KRASNYE=0`), (б) удаление `[ "$__ch_pr" -ne 0 ] ||` (rc 0, `KRASNYE=0`). Достижимое следствие в модели отказа, которую сама батарея считает допустимой (`transport.py` `wire-errors-*`: подмена `git` функцией): основной `git log -z … --name-only` пуст при rc 0 (законная пустота), `git log -1 …` возвращает 128 — production `rc=1 FAIL пустой или оборванный протокол git log` (верно); мутант (а) `rc=0` (зелёный) (`probe_pr.py`, мир «только добавления»). На настоящем git без подмены состояние недостижимо (зонд читает подмножество того, что читает основной проход), поэтому это защитная ветка, но именно её удержания требует п.2.
- Закрытие: клетка `wire-errors-probe`: подмена `git`, возвращающая rc 128 только на `log -1` без `--name-only` при законно пустом основном потоке; ожидание — `FAIL пустой или оборванный протокол git log`, rc 1; стаб на оба мутанта.

## Остатки

Принятое решение консультанта/арбитража: строковое чтение вне пяти файлов зоны — остаток класса К-09, не блок.
- `scripts/lib_zones.sh:311` (zones_load: `ls-tree -r --name-only` + префикс; C-цитирование теряет зоны для `a"quote`/`a\slash`/кириллицы/NFC/NFD; `check_staged` «не судится») — принятый К-09 (вызов 4).
- Прочие строковые чтения имён (все НЕ в пяти файлах; класс «C-цитата теряет/подменяет запись» = К-09, если не оговорено иначе), по убыванию значимости: `scripts/check_staged.sh:676` (`ls-tree -r --name-only refs/heads/main | grep -qE "^contracts/NNN-"` — цитата начинается с `"`, проверка «контракт уже приземлён в main» пропускает контракт с кириллицей/кавычкой в имени, fail-open); `scripts/land_agent.sh:268-270` (`ls-tree -r --name-only` + `awk match(/contracts\/[0-9]+-[a-z0-9-]+\.md$/)` — проверка «замороженные контракты не изменились при приземлении» видит только ASCII-slug); `scripts/check_sdacha.sh:105-106`; `scripts/check_ids.sh:286-287` (`log --name-status` + `awk NF==2`); `scripts/check_protected.sh:282-284` (`--raw`+`awk $6`), `:353-357` (`name-only` без `-z`, обе стороны `comm` в цитированном виде), `:495`, `:618`, `:642-644`; `scripts/accept_publish.sh:200` (`ls-tree … .review | grep '\.md$'`); `scripts/done_contract.sh:212`, `:731` (имена вердиктов, `grep -E`), `:776-778` (`diff-tree --raw` без `-z`, `awk -F'\t' $2`; цитированное имя в любом случае не совпадёт с белым списком — fail-closed); `scripts/dovodka_ui.sh:144`, `:350`; `scripts/freeze_contract.sh:507`, `:557`; `scripts/gitw_teg_130.sh:78`, `:83`; `scripts/lib_karta_sdachi.sh:205`; `scripts/lib_plan.sh:401-402`; `scripts/make_task.sh:815`; `scripts/zamok_predmeta.sh:325`, `:327`, `:376`, `:387`, `:660`, `:779`, `:1538`; `scripts/check_scoped_run.sh:86` (`name-status` + `IFS=$'\t' read`); `scripts/findings_status.py:74`; `scripts/verify_consultant.sh:273/285` (`ls-files -s` + `awk $NF`); `scripts/scope_select.sh:206` (`diff --name-status -z | tr '\0' '\n'` — `-z` есть, но NUL тут же превращён в LF: имя с LF рвётся).
- [INFERENCE] Классы и последствия остатков выше установлены чтением кода и известным поведением git (`ls-tree/diff/log --name-only` без `-z` цитирует имя C-кавычками); сами скрипты вне зоны на цитируемых именах я не прогонял, кроме `check_contract_frozen.sh:95` (воспроизведено).
- Только непустота/rc (имена не читаются, вреда нет): `scripts/check_consumers.sh:325`, `:398`; `scripts/check_plan.sh:166`; `scripts/check_project_standard.sh:110`; `scripts/check_skills.sh:292`; `scripts/check_runner_hygiene.sh:728` (фиксированные ASCII-имена); `scripts/gitw_preflight_071.sh:470` (`package.json`); `scripts/gc_agent_branches.sh:697,765`; `scripts/connect_project.sh:176`.
- NUL (`-z`/`-print0`, не остаток): `scripts/check_staged.sh:348`, `scripts/ci_klass.sh:139,267`, `scripts/check_no_leak.sh` (ноги ls-files `-z`), `scripts/gc_agent_branches.sh:508`, `scripts/connect_project.sh:354`, `scripts/done_contract.sh:371`.
- Маскирование rc в файле зоны, не относящееся к именам и существовавшее на базе: `scripts/check_contract_frozen.sh:95` (`ls-tree … > ls-raw || true`). Воспроизведено на OBJECT: HEAD с отсутствующим деревом `contracts/` (`rm` loose-объекта) — `check_contract_frozen.sh` rc 0, «планов и контрактов на HEAD: 0 · черновиков: 0 · заморожено: 0»; `check_charter.sh` в том же мире — rc 1 `FAIL область устава … не читается (ls-tree rc=1)`. На базе (`origin/main:scripts/check_contract_frozen.sh:86`) то же `|| true` и `pipefail` — дельта 210 его не создаёт; сам OBJECT не меняет это место (ПЕРЕСЕЧЕНИЕ 992 в контракте названо только для `check_charter.sh`).
- Pathspec без `:(literal)`: `scripts/check_contract_frozen.sh:190`, `:202` (`-- "$f"`) — имя с `*`/`[`/`?` матчит и посторонние пути (избыточные коммиты окна (б) → ложный красный, ложного зелёного нет; на базе то же).
- Эквивалентные/внеобластные живые мутанты: `check_charter.sh:423` (ветка корневого коммита `diff-tree … "$c"` без `--root`: вывод всегда пуст при `--diff-filter=MD` — замер `diff-tree -r -z … <root>` = 0 байт; мутация `-z` там неотличима); `check_zones.sh:1064` (`diff-tree --raw --always -z --stdin`: `-z` стоял на базе до 210 — `origin/main:scripts/check_zones.sh:1049`, не место миграции 210).

## Регресс (rc/числа; на OBJECT `1f69756856705143b4cb0941b6db9884edc706d9`, TMPDIR=`/tmp/dev-harness-verify/scratch-adv210e`)

| команда | rc | число |
|---|---|---|
| `W --repo .` | 0 | `KLETKI=325 ZELENYE=325 KRASNYE=0` (97 с) |
| `W --model` | 0 | `KLETKI=325 ZELENYE=325 KRASNYE=0` |
| `W --stabs` | 0 | `MUTACII=41 SVJAZI=50 POIMANY=50 ZHIVYH=0` |
| `W --syntax` | 0 | `SYNTAX: bash=4 python=2` |
| `bash scripts/pre_critic.sh contracts/210-charter-tekst-do-tega.md` | 0 | `КРИТИК: дверь зелёная` |
| `bash scripts/check_sdacha.sh "$PWD" contracts/210-charter-tekst-do-tega.md --run` | 0 | `СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=6)`, 400 с (≤900) |
| `bash scripts/check_charter.sh` (полный; origin/теги восстановлены) | 0 | `уставных документов: 192 · изменений в них: 597 · с разрешения: 597`, 35,7 с; база `8b52fade7`: rc 1, `597 / 585` (12 публикаций 204/205 не освобождены), 15,0 с |
| `bash scripts/check_charter.sh --incr <кеш=HEAD>` (пустое окно) | 0 | `коммитов в диапазоне 0`, `192 · 12 · 12`, 15,3 с; база rc 0, `192 · 12 · 12`, 16,8 с; кеш после прогона равен HEAD |
| `bash scripts/check_contract_frozen.sh` | 0 | `планов и контрактов на HEAD: 199 · черновиков: 9 · заморожено: 190` |
| `bash fixtures/charter_fast_113/red_113.sh` | 0 | `клеток: 28 · красных: 0` |
| `check_zones_incr_207 --repo .` | 0 | `KLETKI=50 ZELENYE=50 KRASNYE=0` |
| `okno_zamorozki_200` | 0 | `ИТОГ 200: клеток 11, красных 0, зелёных 11` |
| shellcheck 0.11.0 `-S warning` (OBJECT / база `origin/main`) | — | `check_charter.sh 6/6`, `pre-push 2/2`, `next_id.sh 2/3`, `check_contract_frozen.sh 2/2`, `check_zones.sh 9/9` — не хуже базы |
| `bash -n` пяти файлов зоны | 0×5 | — |
| `bash scripts/gen_ci_steps.sh --check` | 0 | — |

Не запускал: полный интеграционный `check_zones.sh` (в копии не завершается под нагрузкой; восполняет main). Замер времени полного `check_charter.sh` снят при параллельных мутационных прогонах (≈2,4× к базе 15,0 с; ниже порога 60 с) — совет, не блок.

## Законная пустота и ошибки git (задание п.2; настоящие git-миры, production из OBJECT)

Миры: «только добавления после ustav/1» (законно пустой поток) и «правка AGENTS.md без разрешения»; режимы default/oracle/incr; повреждение — удаление loose-объектов. Результат: без повреждения add → rc 0, md → rc 1; `tree-mid` (дерево среднего коммита) → rc 1 (`история не читается (git log rc=128)` / oracle `diff-tree rc=128`) в обоих мирах и режимах; `commit-mid` → rc 1 (`git log rc=128`, `rev-list rc=128`); `tree-head` и висящий HEAD → rc 1 (`ls-tree rc=128`); ветка удалена → default/oracle rc 2, incr rc 1; shallow (`.git/shallow` и `git clone --depth 1`) → rc 1 `реестр устава … недоступен: shallow` (отказ до чтения истории). Зелёным ошибка git не становится нигде, кроме `refs/replace` (подмена коммита пустым деревом → rc 0 и для мира с правкой устава: `md replace-empty rc=0`) — вне предмета, см. НЕ ЗАЩИЩАЕТ. Оставшаяся дыра — Б-3 (зонд `log -1` не удержан).

## Мутации (production, одноразовый клон, откат после каждой; `W --repo`)

Группа А (законная пустота): `E-LR-TRUE` красен (1: `wire-errors-log`); `E-LR-EMPTYOK` красен (1: `wire-errors-log`); `E-NOPMATCH` красен (1: `wire-errors-empty`); `E-ALWAYS-LEGIT` красен (1: `wire-errors-empty`); `E-NOLINE` красен (1: `wire-errors-truncated`); `E-PR-TRUE` ЖИВ (0); `E-PR-NORC` ЖИВ (0).

Группа Б (возврат строкового чтения, места миграции): `check_charter.sh` ls-tree области (`:863`) — 154 красных; fast log (`:1041`) — 135; diff-tree ветка `${c}^1` (`:421`) — 58; `check_contract_frozen.sh:95` — 28; `check_zones.sh:502` — 14, `:566` — 14; `next_id.sh:286` — 5, `:310` — 5; `pre-push` `d1`/`d2`/`cm`/`cm2`-производители (`:221/223/281/283`) — 4/4/2/2 (по одному ряду на мутацию); owner `--root` (`:376`) — 10; owner `--cc` (`:374`) — ЖИВ.

Группа В (читатель NUL → строка, по одному месту): красны все, кроме двух: `pre-push:431` (22), `:465` (5), `:222` (2), `:224` (1); `check_charter.sh:870` (154), `:896` (24), `:942` (21), `:992` (143), `:1060` (135), `:1063` (135), `:1072` (105), `:1158` (143); `check_contract_frozen.sh:96` (28), `:241` (5); `check_zones.sh:486` (5), `:503` (14), `:567` (14); `next_id.sh:278` (5), `:297` (5), `:633` (5). ЖИВЫ: `pre-push:282`, `pre-push:284`.

Эквивалентные/внеобластные (не считаются блоком): `check_charter.sh:423`, `check_zones.sh:1064` — см. Остатки.

## НЕ ЗАЩИЩАЕТ

- Подмена объектной базы через `refs/replace/*` (локальная запись refs): history читается как подменённая; проверено `md replace-empty` — rc 0 для правки устава. Вне предмета 210; ловец reviewer.
- Усечение потока `git log -z` ровно на границе записи при rc 0 (после полной записи пути/после sha): протокол без терминатора не отличает его от полного — только подмена `git`.
- Мутации — классы по одному месту; конечный список. Три блока выше — места, где мутация дошла до production без красного.
- Строковые чтения вне пяти файлов зоны — Остатки (К-09, принятое решение).

## Советы

1. Закрыть Б-1…Б-3 одним пакетом architect (клетки + стабы); production не менять; scoped-повтор адверсария — только на эти три места (по 2–3 мутанта каждое) и `W --repo`/`--model`/`--stabs` числа.
2. Стаб `NUL-OWNER` и `NUL-167-CM*` в `stabs.tsv` держат пару «производитель+читатель» целиком; полезно развести: отдельно производитель, отдельно читатель, отдельно ветка `--cc`/`--root` — иначе мутант на половине места остаётся зелёным.
3. Клетки с одним путём в дельте не отличают NUL-читатель от строкового (`mapfile -t` берёт первую запись). Для каждого читателя NUL-потока нужна клетка минимум с двумя записями, нарушающая — не первая в сортировке.
4. `check_contract_frozen.sh:95`: снять `|| true` и перейти на именованный отказ как в `check_charter.sh:863-867` (отдельный предмет; на базе то же).
5. Замер времени `check_charter.sh` полного режима — повторить без параллельной нагрузки: 35,7 с при мутационных прогонах против 15,0 с на базе.

## Сырой вывод ключевых прогонов

```
W --repo .      : ИТОГ 210: KLETKI=325 ZELENYE=325 KRASNYE=0                     rc=0
W --model       : ИТОГ 210: KLETKI=325 ZELENYE=325 KRASNYE=0                     rc=0
W --stabs       : ИТОГ 210: MUTACII=41 SVJAZI=50 POIMANY=50 ZHIVYH=0             rc=0
W --syntax      : 210 SYNTAX: bash=4 python=2                                    rc=0
check_sdacha    : СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=6)            rc=0 (400 с)
pre_critic      : КРИТИК: дверь зелёная                                          rc=0
S-OWNER (pre-push:374 --cc без -z)  : battery rc=0 ['ИТОГ 210: KLETKI=325 ZELENYE=325 KRASNYE=0'] krasnye_cells=0
S-OWNER2 (pre-push:376 --root без -z): battery rc=1 ['ИТОГ 210: KLETKI=325 ZELENYE=315 KRASNYE=10']
M-PP282 (pre-push:282 mapfile -t cm)  : battery rc=0 ['ИТОГ 210: KLETKI=325 ZELENYE=325 KRASNYE=0'] krasnye_cells=0
M-PP284 (pre-push:284 mapfile -t cm2) : battery rc=0 ['ИТОГ 210: KLETKI=325 ZELENYE=325 KRASNYE=0'] krasnye_cells=0
E-PR-TRUE (check_charter.sh:1148 || true)       : battery rc=0 ['ИТОГ 210: KLETKI=325 ZELENYE=325 KRASNYE=0'] krasnye_cells=0
E-PR-NORC (check_charter.sh:1149 без -ne 0)     : battery rc=0 ['ИТОГ 210: KLETKI=325 ZELENYE=325 KRASNYE=0'] krasnye_cells=0
owner_demo.py : parents: 2 | production -> record: docs/owner/x.md | records=1 | mutant(--cc string) -> records=0
cm_demo.py    : evil path aaa/evil.md production rc=1 / mutant rc=1 ; evil path zzz/evil.md production rc=1 / mutant-reader(mapfile -t cm) rc=0
probe_pr.py   : honest: rc=1 ['  FAIL пустой или оборванный протокол git log: проверить невозможно'] ; E-PR-TRUE mutant: rc=0
```

Честность среды: первая серия мини-миров и форм-проверок шла параллельно с мутационной серией и читала скрипты из рабочего клона мутаций; все они повторены на чистой выгрузке OBJECT (`git archive HEAD scripts`) с теми же результатами (75 из 78 форм-прогонов OK; три «BAD» — артефакт моего драйвера: имя пути с LF печатается вербатим в несколько строк, rc 1 верен).
