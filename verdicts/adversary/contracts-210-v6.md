FAIL
OBJECT=377f89643a54e24104e784470ee28b8a4b73c6c2
СУД: репо=dev-harness; предмет=210; роль=adversary; вызов=6 (узкий, по слову владельца/SANKCIJA на этот OBJECT); фаза=реализация; модель-план=anthropic/claude-sonnet-5-5; модель-факт=anthropic/claude-sonnet-5-5 (метаданные среды выполнения судьи); предыдущий=archive/210/adversary-v5-fail-05c75ff09f (FAIL Adv210e); класс риска=рисковый

Область: дельта Architect210h (`e2a5002f1`, ТОЛЬКО `fixtures/workshop_project/charter_tekst_do_tega_210/{transport.py,probe.py,stabs.tsv,SDACHA.md}`) и полнота по классу «читатели путей Git в пяти файлах зоны». Носитель: `git log --format='%h %an %s' cb136eb51..HEAD` — 17 коммитов; дельта `e2a5002f1` (автор `architect`): `git diff-tree --no-commit-id --name-only -r e2a5002f1` — ровно четыре файла выше. Зоны прежних 16 коммитов повторно не сверял (сверено v5; production-дельта побайтово равна — см. md5 ниже). В OBJECT присутствует `verdicts/review/contracts-210-impl-v2.md` (коммит `fec551081`, автор reviewer) — как отмечено в v5, расхождение описи задания, не дельта вызова 6.

Проверено, что production и контракт НЕ менялись после вызова 5: `git diff 1f69756856705143b4cb0941b6db9884edc706d9 377f89643a54e24104e784470ee28b8a4b73c6c2 -- scripts .githooks contracts` = только 8 строк grandfather в `scripts/check_charter.sh` (217/143) — это дрейф main (`git diff 8b52fade7 cb136eb51 --stat` = те же 8 вставок); мультимножество `+/-` строк `git diff 8b52fade7 1f697… -- scripts .githooks` и `git diff cb136eb51 377f896… -- scripts .githooks` совпадает (`md5sum` обоих `b7cda8ed5e33ccd07c32f6b38a554ff8`). Необъявленной семантики в дельте носителя нет (К-01 не блок).

Закрытие вызова-5: все три блока Adv210e (Б-1 `--cc`, Б-2 `cm`/`cm2`, Б-3 зонд `git log -1`) закрыты — мутанты красятся `W --repo .` (см. Мутации). Блок ниже — НОВЫЙ, найден при обязательной полноте п.2 по оси rc производителя путей (та же ось, что Б-3 вызова 5, но другие читатели).

## Блоки

**БЛОКИРУЕТ Б-1 (К-08): отказ при ошибке производителя путей в pre-push и в оракуле не удержан батареей** — production ВЕРЕН (на ошибке git отказ); дыра в батарее: мутант «снять проверку rc / подавить rc» не красит `W --repo .` (rc 0, `KLETKI=342 ZELENYE=342 KRASNYE=0`) в шести местах. Правка — только в зоне architect (клетки/стабы), production не трогать.

| # | место | мутант (одна правка) | `W --repo .` | эффект при инъекции rc 128 (production → мутант) |
|---|---|---|---|---|
| R3 | `.githooks/pre-push:281` (`diff -z … "$p1" "$c"` → `cm`) | `\|\| { rm -f …; return 1; }` → `\|\| true` | rc 0, ЖИВ | `merge_167_razreshen` печатает `1` (запрет) → `0` (разрешено) |
| R4 | `.githooks/pre-push:283` (`… "$p2" "$c"` → `cm2`) | то же | rc 0, ЖИВ | `1` → `0` |
| R5 | `.githooks/pre-push:427` (`charter_diff_paths` в кольце) | `if ! charter_diff_paths … then` → `… \|\| true; if false; then` | rc 0, ЖИВ | клетка `nul-quote-edit-push` (правка устава после /1): production rc 1 `ОТКАЗ: pre-push: дельта коммита не читается: e95dcba8…` → мутант rc 0, stderr пуст — нарушение проходит молча |
| R6 | `.githooks/pre-push:461` (`owner_docs_paths`) | `if ! owner_docs_paths … then` → `… \|\| true; if false; then` | rc 0, ЖИВ | клетка `wire-ownermergeread-quote-edit` (не-owner правит docs/owner/): production rc 1 → мутант rc 0 |
| R8 | `scripts/check_charter.sh:940` (оракул, `charter_diff_paths … \|\| dt_rc=$?`) | `\|\| dt_rc=$?` → `\|\| true` | rc 0, ЖИВ | клетка `nul-quote-edit-oracle`: production rc 1 `… (diff-tree rc=128)`/`FAIL`; мутант rc 0, `изменений без разрешения нет` на нечитаемой дельте |
| R1 | `.githooks/pre-push:221` (`d1`) | то же, что R3 | rc 0, ЖИВ | на клетке `wire-167-cm-allow` результат `1` и у production, и у мутанта (дальше срабатывает `merge-tree`/`$auto1 = $tree`); различие — только на состоянии «`d1` нечитаем И пересечение `d1∩d2` непусто с одинаковым содержимым» [INFERENCE: не воспроизводил; сумма достижимого эффекта мала] |
| R2 | `.githooks/pre-push:223` (`d2`) | то же | rc 0, ЖИВ | то же, [INFERENCE] |

- ОБЯЗАТЕЛЬСТВО: арбитраж 210 (`origin/wip/210/arbiter-v1:verdicts/arbitration/predmet-210-granica-imen-putej.md`): таблица миграции, место `.githooks/pre-push:215–216,271–272` — «все четыре diff --name-only в исключении 167: NUL-массивы, **без потери rc производителя**»; «Что обязана различать батарея»: «Ошибка Git, пустой/оборванный протокол и поломанный инструмент не превращаются в чистую область … требую каждой оси и каждого независимого места чтения с наблюдаемым отличием»; контракт 210 `ПЕРЕСЕЧЕНИЕ implementer … 992 … отказы чтения области/истории/дельты сохраняются` (R8). Задание п.2 вызова 6: «ПОЛНОТА … читатели путей покрыты красными клетками»; «живой мутант = блок К-08».
- СОСТОЯНИЕ: ошибка `git diff`/`git diff-tree` (повреждённая/недостающая объектная база, обрыв инструмента) на пушимом коммите/merge. Метод инъекции — тот же, что у автора закрывающей клетки Б-3 (`wire-errors-probe`: подмена `git`, rc 128 на одном вызове); драйвер `rdemo.py` на мирах батареи (`probe.observe`, PATH-прокладка `git`), производственный pre-push/`check_charter.sh` — без правок.
- НАБЛЮДЕНИЕ (на OBJECT, `W --repo .`): `ИТОГ 210: KLETKI=342 ZELENYE=342 KRASNYE=0`, rc 0 — для каждого из R1–R6, R8 по отдельности. Контроль без инъекции: `wire-167-cm-allow` rc 0 и `nul-quote-edit-push` rc 1 совпали с ожиданием.
- Закрытие: клетки с инъекцией rc 128 на каждый независимый производитель (четыре `diff -z` в 167 — по номеру вызова; `diff-tree` кольца pre-push; `diff-tree … docs/owner/`; оракул `diff-tree`) на мире с нарушением (чтобы «чисто» и «ошибка» различались), ожидание — запрет/rc 1 с именованным отказом; стабы «`|| true`» на каждое из мест (в `stabs.tsv`).
- Оговорка по границе блока: если консультант/арбитраж относит ось rc производителя вне класса «возврат строкового чтения/снятие -z/-d ''» вызова 6, то Б-1 снижается до `## Остатки` и вердикт становится accept; все три прямо назначенных блока вызова 5 закрыты. Я не снижаю класс сам: арбитраж 210 называет «без потери rc производителя» явным требованием к тем же местам, а Б-3 вызова 5 был блоком той же оси.

## Остатки

Принятое решение консультанта/арбитража: строковое чтение вне пяти файлов зоны — К-09, не блок. Названные и прежде перечисленные (повторно подтверждены на OBJECT, строки существуют):
- `scripts/lib_zones.sh:311` (zones_load, `ls-tree -r --name-only`) — принятый К-09.
- ВНЕ пяти файлов (v5 «Остатки», без новых прогонов): `scripts/check_staged.sh:676`, `scripts/land_agent.sh:268-270`, `scripts/check_sdacha.sh:105`; прочие — как в `archive/210/adversary-v5-fail-05c75ff09f:verdicts/adversary/contracts-210-v5.md`.
- Эквивалентные/внеобластные (названы): `scripts/check_charter.sh:423` (корневой коммит; мутант `-z` на `:427` — `W --repo .` rc 0, неотличим: `diff-tree` без `--root` пуст при `--diff-filter=MD`), `scripts/check_zones.sh:1064` (`-z` на базе, rc 0 мутант).
- `scripts/check_contract_frozen.sh:95` (`… 2>/dev/null || true`, база то же) — маскирует rc ls-tree области; воспроизведено v5. Не дельта 210.

НОВОЕ в этом круге (все — не блок: чтения НЕ входят в одиннадцать мест таблицы арбитража; на базе `cb136eb51` код тот же; ловец — батареи 040/207 и reviewer; в `W --repo .` мутант жив):
- `scripts/check_zones.sh:1227` (`read -r -d '' f` → `read -r f`), `:952` (`awk -v RS='\0'` → `\n`), `:1139` (`ORS`), `:1146` (`RS = "\0"`), `:1791` (`awk -v RS='\0' -v ORS='\0'`) — NUL-разбор батч-потока `diff-tree --raw -z` (база: `git show cb136eb51:scripts/check_zones.sh` строки 1049/1131/1212/1776). Мутанты по одному: `W --repo .` rc 0, `KLETKI=342 ZELENYE=342 KRASNYE=0`. Все пять жили на базе, `git diff cb136eb51 HEAD -- scripts/check_zones.sh` их не затрагивает (три hunk'а: :482, :494, :553). [INFERENCE] ловит их набор `fixtures/check_zones/*` (не прогонял — полный `check_zones.sh` в копии не завершается под нагрузкой).
- `scripts/next_id.sh:300` (`path="${path#$'\n'}"` — снятие служебного LF) — мутант жив, но на `git 2.43.0` `git log -z --all --diff-filter=A --name-only --format=` не выдаёт LF между коммитами (od -c мира с 6 коммитами и merge: записи идут `…\0…\0` без LF; max одинаков 7=7 у production и мутанта) → эквивалентный мутант на этой версии git; [INFERENCE] на другой версии git стрип может быть значим — батарея его не держит.
- `scripts/next_id.sh:234` и `:600` (`read -r -d '' loc` по ролевым локациям `plans/`, `decisions/`, `contracts/`, `verdicts/…` — НЕ имена из Git): `:234` — мутант ломает весь `next_id` (рабочий `W --repo .` rc 2 `SUBJECT_ENVIRONMENT`, не поимка по клетке), `:600` — жив (клетка backfill задаёт `locations=(contracts/)` сама). Вне класса «имена Git».
- `scripts/check_charter.sh:761` (`ls-tree --format='%(objectname)' … -- ":(literal)$p"` → `"$p"`) — класс pathspec-литерала (не транспорт имён), жив; v5 назвал pathspec без `:(literal)` остатком (`check_contract_frozen.sh:190`, `:202`).
- Потеря rc в подстановке процесса `done < <(charter_diff_paths "$c" "$ROOT")`: `scripts/check_contract_frozen.sh:248`, `scripts/check_zones.sh:493` — форма на базе `cb136eb51` (`:232`, `:489`) та же; арбитраж требует для этих двух потребителей только смены wire-format. [INFERENCE: прогонов с инъекцией не делал.]

## Регресс (rc/числа; на OBJECT `377f89643a54e24104e784470ee28b8a4b73c6c2`, TMPDIR=`/tmp/dev-harness-verify/scratch-adv210f`)

| команда | rc | число |
|---|---|---|
| `W --repo .` | 0 | `ИТОГ 210: KLETKI=342 ZELENYE=342 KRASNYE=0` (67 с на свободной машине) |
| `W --model` | 0 | `KLETKI=342 ZELENYE=342 KRASNYE=0` |
| `W --stabs` | 0 | `ИТОГ 210: MUTACII=46 SVJAZI=60 POIMANY=60 ZHIVYH=0` |
| `W --syntax` | 0 | `210 SYNTAX: bash=4 python=2` |
| `bash scripts/pre_critic.sh contracts/210-charter-tekst-do-tega.md` | 0 | `КРИТИК: дверь зелёная` (первый прогон под параллельной мутационной нагрузкой rc 1 — `бюджет листа 900 исчерпан на команде … --model`: артефакт нагрузки; повтор на свободной машине rc 0) |
| `bash scripts/check_sdacha.sh "$PWD" contracts/210-charter-tekst-do-tega.md --run` | 0 | `СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=6)`, 472 с (≤900) |
| `bash scripts/check_charter.sh` (полный; origin и теги восстановлены) | 0 | `уставных документов: 192 · изменений в них: 597 · с разрешения: 597`, 32,6 с |
| `bash scripts/check_charter.sh --incr <кеш=HEAD>` (пустое окно) | 0 | `incr: … (0 коммитов)`, `192 · 12 · 12`, 15,6 с |
| `bash scripts/check_contract_frozen.sh` | 0 | `планов и контрактов на HEAD: 199 · черновиков: 9 · заморожено: 190` |
| `bash fixtures/charter_fast_113/red_113.sh` | 0 | `клеток: 28 · красных: 0` |
| `check_zones_incr_207 --repo .` | 0 | `KLETKI=50 ZELENYE=50 KRASNYE=0` |
| `okno_zamorozki_200` | 0 | `ИТОГ 200 … клеток 11, красных 0, зелёных 11` |
| shellcheck 0.11.0 `-S warning` (OBJECT / `origin/main`) | — | `check_charter.sh 6/6`, `pre-push 2/2`, `next_id.sh 2/3`, `check_contract_frozen.sh 2/2`, `check_zones.sh 9/9` — не хуже базы |
| `bash -n` пяти файлов зоны | 0×5 | — |
| `bash scripts/gen_ci_steps.sh --check` | 0 | — |

Не запускал: полный интеграционный `check_zones.sh` (в копии не завершается под нагрузкой; восполняет main).

## Мутации (production, одноразовый клон `…/scratch-adv210f/clone`, откат `git checkout -- <файл>` после каждой; `W --repo .`, rc и красные клетки)

Повтор вызова 5 (должны краситься) — все КРАСНЫ:
- Б-1 `pre-push:374` `diff-tree -z --cc` → `diff-tree --cc`: rc 1, `KRASNYE=4` (`wire-ownermerge-{ascii,quote}-edit`, `wire-ownermergeread-{ascii,quote}-edit`).
- Б-2 `pre-push:282` (`cm` без `-d ''`): rc 1, `KRASNYE=2` (`wire-167-cmread-deny-{ascii,quote}`); `pre-push:284` (`cm2`): rc 1, `KRASNYE=2` (`wire-167-cm2read-deny-{ascii,quote}`).
- Б-3 `check_charter.sh:1154` (`|| __ch_pr=$?` → `|| true`): rc 1, `KRASNYE=1` (`wire-errors-probe`); `:1155` (снять `[ "$__ch_pr" -ne 0 ] ||`): rc 1, `KRASNYE=1` (`wire-errors-probe`).
- Контроль живости раннера: `pre-push:376` (`--root` без `-z`): rc 1, `KRASNYE=10`; `:222` (`d1` без `-d ''`): rc 1, `KRASNYE=4`.

Полнота (новые, по одному): красны — `check_charter.sh:877` (`sort -z`→`sort`): rc 1, `KRASNYE=3` (`nul-header-edit-*`); `check_charter.sh:1049` (`--format=%x00%H`→`%H`): rc 1, `KRASNYE=135`; `check_charter.sh:871` (`|| lt_rc=$?`→`|| true`): rc 1, 1 (`wire-errors-scope`); `check_charter.sh:1051` (`|| __ch_lr=$?`→`|| true`): rc 1, 1 (`wire-errors-log`); `next_id.sh:646` (`find -print0`→`-print`): rc 1, 5 (`wire-backfill-*`); `check_zones.sh:486`: rc 1, 5 (`wire-zones-*`); `check_contract_frozen.sh:96`: rc 1, 28; `check_contract_frozen.sh:241`: rc 1, 5 (`wire-frozen-*`).
ЖИВЫ (rc 0, 342/342): R1 `pre-push:221`, R2 `:223`, R3 `:281`, R4 `:283` (`|| true`), R5 `:427`, R6 `:461`, R8 `check_charter.sh:940` — это Б-1 выше; `check_zones.sh:1227/:952/:1139/:1146/:1791`, `:1064`; `next_id.sh:300/:600`; `check_charter.sh:427/:761` — Остатки/эквиваленты выше. `next_id.sh:234` — rc 2 `SUBJECT_ENVIRONMENT` (не считается поимкой).

Достижимый эффект (драйвер `rdemo.py`, миры батареи, PATH-прокладка `git`, rc 128 на одном вызове; production в обоих прогонах из OBJECT):
```
R3 pp:281 cm  cell=wire-167-cm-allow   shim=diff#3   production stdout=1   mutant stdout=0
R4 pp:283 cm2 cell=wire-167-cm2-allow  shim=diff#4   production stdout=1   mutant stdout=0
R5 pp:427     cell=nul-quote-edit-push shim=diff-tree --diff-filter=MD   production rc=1 «ОТКАЗ: pre-push: дельта коммита не читается: e95dcba8…»   mutant rc=0 stderr пуст
R6 pp:461     cell=wire-ownermergeread-quote-edit shim=diff-tree docs/owner   production rc=1   mutant rc=0
R8 cc:940     cell=nul-quote-edit-oracle shim=diff-tree --diff-filter=MD      production rc=1   mutant rc=0 «изменений в них: 0 … изменений без разрешения нет»
R1/R2 pp:221/223 cell=wire-167-cm-allow  production stdout=1  mutant stdout=1 (не различаются на этом мире)
```

## Законная пустота и двусторонность (п.3)

Честные миры зелёные в `W --repo .` 342/342: ascii, quote, slash, кириллица, NFC/NFD, пробел, TAB, LF, CR, SOH, DEL (`nul-*-{draft,edit,history,land,sync,mixed}-*`, `wire-*`), законная публикация рядом с правкой после /1 (`nul-*-mixed`, 5 клеток), законно пустая история (`empty-*`, 11 клеток), `wire-ownermerge{,read}-{ascii,quote}-history` и `wire-167-{cmread,cm2read}-allow-{ascii,quote}` (честные пары к новым клеткам). Повреждённые миры rc 1: `wire-errors-{scope,log,empty,truncated,probe}`. Все мутанты Б-1/Б-2/Б-3 вызова 5 краснятся (см. Мутации). Новые клетки Arch210h различают производителя и читателя по отдельности (`W --stabs` 60/60 поймано, включая `NUL-OWNER-CC`, `NUL-167-CM-READ`, `NUL-167-CM2-READ`, `EMPTY-PROBE-RC-IGNORED`, `EMPTY-PROBE-RC-UNCHECKED`). Эквивалентные мутанты (названы выше) не краснятся и не считаются блоком.

## НЕ ЗАЩИЩАЕТ

- Ось rc производителя путей в `.githooks/pre-push` (R1–R6) и оракул `check_charter.sh:940` (R8) — только `wire-errors-*` для `check_charter.sh` (область, история, зонд); см. Б-1.
- NUL-разбор батч-потока `check_zones.sh` (`:952/:1139/:1146/:1227/:1791`) и `-z` на `:1064` — не в таблице миграции арбитража; ловец — батареи 040/207 и reviewer (не прогонялись здесь).
- Версия git: служебный LF в `next_id.sh:300` на `git 2.43.0` не появляется; стрип не удерживается батареей.
- Ролевые локации `next_id.sh:234/:600` (не имена из Git).
- Мутации — классы по одному месту; конечный список. Полный `check_zones.sh` и CI-реестры вне копии.

## Советы

1. Одним пакетом architect закрыть Б-1: клетки с инъекцией rc 128 (приём `wire-errors-probe`) на `pre-push:221/223/281/283` (по номеру вызова `diff -z`, мир с нарушением в НЕ первом пути), `:427`, `:461`, и на оракул `check_charter.sh:940`; стабы `|| true` на каждое место; production не менять; scoped-повтор адверсария — только эти семь мутантов + числа `W --repo/--model/--stabs`.
2. Для R1/R2 нужен мир «`d1` нечитаем, `d1∩d2` непусто с одинаковым содержимым» (иначе мутант неотличим от production — `merge-tree` ловит).
3. `check_contract_frozen.sh:95` (`|| true`) и подстановки процесса `done < <(charter_diff_paths …)` (`check_contract_frozen.sh:248`, `check_zones.sh:493`): перейти на файл с проверкой rc — отдельный предмет, не 210.
4. Если консультант принимает ось rc вне класса вызова 6, Б-1 переносится в Остатки с этим перечнем, и вердикт — accept без правок production.

## Сырой вывод ключевых прогонов

```
W --repo .   : ИТОГ 210: KLETKI=342 ZELENYE=342 KRASNYE=0                              rc=0
W --model    : ИТОГ 210: KLETKI=342 ZELENYE=342 KRASNYE=0                              rc=0
W --stabs    : ИТОГ 210: MUTACII=46 SVJAZI=60 POIMANY=60 ZHIVYH=0                      rc=0
W --syntax   : 210 SYNTAX: bash=4 python=2                                             rc=0
check_sdacha : СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=6)                      rc=0 (472 с)
pre_critic   : КРИТИК: дверь зелёная                                                    rc=0
check_charter: уставных документов: 192 · изменений в них: 597 · с разрешения: 597     rc=0 (32.6 с)
check_charter --incr (кеш=HEAD): уставных документов: 192 · изменений в них: 12 · с разрешения: 12   rc=0 (15.6 с)
B1 pp:374 --cc без -z       : rc=1 KLETKI=342 ZELENYE=338 KRASNYE=4
B2 pp:282 cm без -d ''      : rc=1 KRASNYE=2 ; pp:284 cm2: rc=1 KRASNYE=2
B3 cc:1154 || true          : rc=1 KRASNYE=1 (wire-errors-probe) ; cc:1155 без -ne 0: rc=1 KRASNYE=1
R1 pp:221 || true           : rc=0 ZELENYE=342 KRASNYE=0 (ЖИВ)
R2 pp:223 || true           : rc=0 ZELENYE=342 KRASNYE=0 (ЖИВ)
R3 pp:281 || true           : rc=0 ZELENYE=342 KRASNYE=0 (ЖИВ)
R4 pp:283 || true           : rc=0 ZELENYE=342 KRASNYE=0 (ЖИВ)
R5 pp:427 подавление rc     : rc=0 ZELENYE=342 KRASNYE=0 (ЖИВ)
R6 pp:461 подавление rc     : rc=0 ZELENYE=342 KRASNYE=0 (ЖИВ)
R8 cc:940 || dt_rc → || true: rc=0 ZELENYE=342 KRASNYE=0 (ЖИВ)
```

Среда: scratch `TMPDIR=/tmp/dev-harness-verify/scratch-adv210f` (вне копии; удалён после работы), одноразовый клон со своим `.git`; основной чекаут не мутирован (мутации — только в клоне и в памяти драйвера `rdemo.py`, выгрузка production не правилась). Добавлен `origin` (`ssh://git@github.com/a3ka/dev-harness.git`) и восстановлены теги для полного `check_charter.sh`.
