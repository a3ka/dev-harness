accept
OBJECT=6d50ad48b17b08b4aa5c57d52c6f951ae59a54d8
СУД: repo=dev-harness; предмет=201; фаза=scoped-суд строк `registry/mesto-legacy.tsv` (разовый вызов implementer по слову владельца 2026-11-20 21:48 UTC п.16); роль=reviewer; вызов=scoped (только 4 новые строки реестра); класс риска 201=рисковый (адверсарий по 201 учтён ранее, в этот вызов не входит); модель-план=config/agent_models.json reviewer → anthropic/claude-opus-5-5; сессия=Rev201Mesto; модель-факт: `bash scripts/models_actual.sh --tsv --bind --session Rev201Mesto | cut -f1-3` → `reviewer	anthropic/claude-opus-5-5	allowed` ×2, rc 0.
СВЕРКА-АРХИТЕКТУРЫ: размещение — данные лежат в существующем реестре `registry/mesto-legacy.tsv` (зона implementer frozen/contracts/201/1 :146–147), новых файлов нет; зависимостей не добавлено; писатель реестра прежний (implementer по зоне 201), дверь `scripts/done_contract.sh:550-571` реестр только читает через `git show HEAD:`; новых операций нет; `bindings.json`/`architecture.lock.json` не тронуты; долг не расширен; diff модели отсутствует (L-уровня нет).
СВЕРКА-СТАНДАРТОВ: AGENTS.md станции не объявляет документ архитектуры и стандарт кода (`grep -c 'ARCHITECTURE\|CODING' AGENTS.md` → 0); неприменимо.
sourceCanon: `jq .sourceCanon harness.project.json` → null; gate сверки источников не объявлен.

Копия судьи: `/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t6b6facb03/m` (detached на OBJECT, `git rev-parse HEAD` → 6d50ad48b17b08b4aa5c57d52c6f951ae59a54d8).
Scratch: `/tmp/dev-harness-verify/rev201m-2786069/`. Одноразовый клон `probe-obj/` (свой `.git`, `git clone --no-hardlinks`) и скрипт негативов `neg.sh`.
Находки (только советы): `.review/2026-11-20-123.md`.

## Блоки

Нет.

## 1. Дельта коммита

- `git log -1 --format='%H %P / A=%an <%ae> / C=%cn <%ce>' 6d50ad48b1` → родитель `82c76c7e575baaaad5f720efb0b4c7534efd580b`; `A=implementer <implementer@dev-harness.local>`, `C=implementer <implementer@dev-harness.local>`.
- `git show --stat --format= 6d50ad48b1` → `registry/mesto-legacy.tsv | 4 ++++`, `1 file changed, 4 insertions(+)`, rc 0.
- `git diff --numstat 82c76c7e57 6d50ad48b1` → `4	0	registry/mesto-legacy.tsv`. По `git diff … | cat -A` hunk `@@ -13,3 +13,7 @@`: контекст (991, 999, 201) не изменён, добавлены только четыре `+`-строки.
- `git diff --name-status 82c76c7e57 6d50ad48b1` → `M	registry/mesto-legacy.tsv`. `git diff --quiet 82c76c7e57 6d50ad48b1 -- scripts/done_contract.sh registry/pauzy.tsv` → rc 0, файлы не тронуты.
- `git merge-base --is-ancestor 82c76c7e57 6d50ad48b1` → rc 0.
- PR #1168: `gh pr view 1168 --json …` → head `6d50ad48b17b08b4aa5c57d52c6f951ae59a54d8`, base `main`, `+4/−0`, files `["registry/mesto-legacy.tsv"]`, state OPEN. `gh pr checks 1168` → `16 pass`, `1 skipping` (`vorota`).

## 2. Каждая строка: формат, blob vmax, основание, место

Формат. `awk -F'\t' '{print NR": NF="NF}'` даёт NF=5 у всех 19 строк файла. `awk -F'\t' 'NF!=5'` пусто. `grep -nP '\r|[ \t]$| \t|\t '` → rc 1: нет CR, хвостовых пробелов и пробела рядом с TAB. Последний байт файла `\n`.

Blob vmax. Сверено живой командой `git rev-parse "frozen/contracts/<N>/<vmax>^{commit}:<файл>"`. vmax — максимум по `git tag -l 'frozen/contracts/<N>/*' | sed 's#.*/##' | sort -n | tail -1`.

| строка файла | N | файл (`ls contracts/<N>-*`) | теги | vmax | live blob | в реестре | младшие версии (blob ≠) |
|---|---|---|---|---|---|---|---|
| `registry/mesto-legacy.tsv:16` | 193 | contracts/193-svyazka-sdatochnyj-list.md | /1 /2 /3 | 3 | 7761b9cd9f03ec68d9571794fdf29aec247b17a3 | = MATCH | v1 17696b27…, v2 254a2b60… |
| `registry/mesto-legacy.tsv:17` | 187 | contracts/187-arhitektura-v-processe.md | /1 /2 /3 | 3 | 7835226181aa2badcf4776e64972588a4ef3a8a5 | = MATCH | v1 54c975d9…, v2 e8cd212f… |
| `registry/mesto-legacy.tsv:18` | 122 | contracts/122-ci-proekta.md | /1…/6 | 6 | f44496bfed2c98e5fb3bfd5e315253825b158479 | = MATCH | v1 56160bb6…, v2=v3 77305975…, v4 9164d630…, v5 b1743760… |
| `registry/mesto-legacy.tsv:19` | 140 | contracts/140-odin-agent-na-predmet.md | /1…/5 | 5 | 8e7d5364df748499635f99188b183f15e3ddfc10 | = MATCH | v1 bdb99a18…, v2 fd03ddba…, v3 de23ed6a…, v4 e76dd59c… |

У каждого предмета blob реестра совпадает с blob vmax и не совпадает ни с одной младшей версией. Blob HEAD-файла совпадает с vmax у всех четырёх.

Основание. Для каждого N сделано так: из `git show frozen/contracts/<N>/<vmax>^{commit}:<файл> | grep '^ЗОНА implementer'` снят префикс, из колонки 4 сняты `ЗОНА implementer: ` и ` станции`, строки сравнены байтово. Результат по всем четырём — `основание==frozen ЗОНА: EQUAL`. У каждого замороженного текста ровно одна строка `ЗОНА implementer` (193:367, 187:84, 122:82, 140:94). Все пути зон существуют в дереве станции на OBJECT (`git cat-file -e 6d50ad48b1:<путь>` → exists ×19).

Место «станция». `grep -c '^ПРОДУКТ:'` по vmax-текстам → 0 у всех четырёх, поэтому место определяется только записью реестра. ЗОНА implementer и ПЕРЕСЕЧЕНИЕ implementer каждого текста указывают только на `scripts/`, `.omp/extensions/` и `fixtures/` станции. Продуктовых путей в зонах нет:
- 193 — скрипты сдачи (`check_sdacha.sh`, `lib_karta_sdachi.sh` и др.);
- 187 — `make_task.sh`/`done_contract.sh`/`check_architecture_contract.sh`. Строка `:26` про `repoId=Complior-back` описывает применимость требований 187а, а не место кода;
- 122 — генератор `gen_project_workflow.sh`. Строка `:135` прямо выносит «живой перевод Complior-back/Complior-mob … не здесь»;
- 140 — `zamok_predmeta.sh`/`pre_judge.sh`/`spawn-guard.ts`. Тот же `spawn-guard.ts` записан станцией у 157 в §Миграции.

Смешанной зоны, как у 123, ни у одного предмета нет. Классификация «станция» верна.

Колонка `записал`=`implementer` правдива: author/committer коммита — implementer. Норма `contracts/201-done-dver-soderzhatelnaja-sverka.md:141` («последующие строки реестра … с основанием и автором в записи») это допускает. Указание `:123` («`записал` всех строк — architect (арбитраж 1)») относится к таблице §Миграции, этих строк в ней нет.

## 3. Дубли и неоднозначность

- `awk -F'\t' '{print $1,$2}' registry/mesto-legacy.tsv | sort | uniq -d` → пусто.
- `awk -F'\t' 'NR>1{print $1}' … | sort | uniq -d` → пусто: каждый номер предмета встречается в файле один раз, на N не больше одной записи.
- Строк 157 и 199 в дельте нет: `git diff … | grep -E '^\+(157|199)\b'` → rc 1.

## 4. Эффект (живая дверь, одноразовый клон со своим `.git`)

Прогон: `env -u GIT_AUTHOR_NAME -u GIT_AUTHOR_EMAIL -u GIT_COMMITTER_NAME -u GIT_COMMITTER_EMAIL bash scripts/done_contract.sh <файл> "проба"` в `probe-obj/`. До прогонов в клоне уже стояли теги `done/contracts/{122,140,187,193}/1`.

На OBJECT 6d50ad48b1 место пройдено, отказ наступает позже, на клапане v>1:
```
== 193 rc=1 done-tags before=1 after=1   done: v>1 требует строку РАЗРЕШИЛ-ВЛАДЕЛЕЦ: в причине
== 187 rc=1 done-tags before=1 after=1   done: v>1 требует строку РАЗРЕШИЛ-ВЛАДЕЛЕЦ: в причине
== 122 rc=1 done-tags before=1 after=1   done: v>1 требует строку РАЗРЕШИЛ-ВЛАДЕЛЕЦ: в причине
== 140 rc=1 done-tags before=1 after=1   done: v>1 требует строку РАЗРЕШИЛ-ВЛАДЕЛЕЦ: в причине
```
Новых тегов не поставлено.

На базе 82c76c7e57, где строк нет, дверь отказывает именно на месте:
```
== base 193 rc=1 tags=1   done: место реализации предмета 193 не установлено — нет объявления ПРОДУКТ: и нет применимой записи registry/mesto-legacy.tsv
== base 187 rc=1 tags=1   done: место реализации предмета 187 не установлено — …
== base 122 rc=1 tags=1   done: место реализации предмета 122 не установлено — …
== base 140 rc=1 tags=1   done: место реализации предмета 140 не установлено — …
```
Красное до правки предъявлено.

Негативы на строке 193. `neg.sh`: мутация строки, коммит в клоне (`probe@x`), прогон двери. Все rc=1, тег `done/contracts/193/*` в каждом случае только прежний `/1`:

| мутация | причина отказа |
|---|---|
| blob-1char (`…17a3`→`…17a4`) | «место реализации предмета 193 не установлено» |
| blob младшей версии v2 (`254a2b60…`) | «не установлено» |
| N=194 | «не установлено» |
| пробел вместо TAB между кол.1/2 | «не установлено» |
| пробел вместо TAB между кол.2/3 | «не установлено» |
| пробел вместо TAB между кол.3/4 | «неоднозначна или вне грамматики» |
| лишняя колонка перед местом | «неоднозначна или вне грамматики» |
| место `станция ` (хвостовой пробел) | «неоднозначна или вне грамматики» |
| дубль строки | «неоднозначна или вне грамматики» |
| **лишняя 6-я колонка в хвосте** | **место пройдено → клапан v>1** |

Последний негатив дверь пропускает: `scripts/done_contract.sh:556` выбирает строки по `NF>=3`. Судимые строки имеют NF=5, поэтому на этот объект суда это не влияет. Это свойство двери, а дверь в дельте не менялась. Записано советом С-1 в `.review/2026-11-20-123.md`.

## 5. Область правки

Пути дельты: {`registry/mesto-legacy.tsv`}. Они входят в ЗОНУ implementer frozen/contracts/201/1 (`:146` `scripts/done_contract.sh`, `:147` `registry/mesto-legacy.tsv`; `git tag -l 'frozen/contracts/201/*'` → только `/1`). `scripts/done_contract.sh`, `registry/pauzy.tsv` и прочие файлы не тронуты (§1). На OBJECT в `registry/pauzy.tsv` нет строки `201`: пауза снята на время вызова. Предметы 157/199 не добавлены. Один коммит, ссылка на предмет есть в заголовке (`implementer: 201 — …`). Проверки и фикстуры не менялись.

## 6. Паразитная сложность (контракт 050)

Артефакт: четыре строки данных в существующем реестре, одна семья.
(1) Свойство: `contracts/201-…:55` — место реализации явное, запись (N, blob vmax) обязательна при отсутствии `ПРОДУКТ:`; `:141` — последующие строки идут с основанием и автором.
(2) Новое состояние: четыре строки в файле на HEAD, видны в выводе `git show HEAD:registry/mesto-legacy.tsv`; побочного состояния нет.
(3) Связанные правки: при новой заморозке этих предметов blob устареет и запись перестанет действовать. Это задумано (`:123` «новая версия … запись не наследует»). Число связанных файлов не выросло: 1.
(4) Интерфейс двери не менялся: ни флагов, ни env, ни rc.
(5) Потребитель: шаг «место реализации» `scripts/done_contract.sh:547-571`. Грамматика реестра не дублируется.
ESSENTIAL.

## 7. Остаток контракта (НЕ ЗАЩИЩАЕТ, ловец reviewer)

ОСТАТОК: НЗ-1 (эра внешнего SHA) — не укусил: все четыре места станционные, внешних OBJECT в диффе нет.
ОСТАТОК: НЗ-2 (семантика вердикта; правдивость СВЕРКА-АРХИТЕКТУРЫ) — не укусил: судится только классификация места; вердикты 193/187/122/140 в этот суд не входят.
ОСТАТОК: НЗ-7 (Git-достижимость ≠ полнота) — не укусил: запись не является свидетельством полноты реализации (`:141`), полнота по предметам здесь не утверждается.
ОСТАТОК: НЗ-8 (правдивость места и legacy-записей) — не укусил: `registry/mesto-legacy.tsv:16-19` — 4 blob сверены с vmax живой командой, основания байтово совпадают с замороженными ЗОНАМИ, место «станция» подтверждено зонами и ПЕРЕСЕЧЕНИЯМИ (§2).
ОСТАТОК: НЗ-9 (семантика внешнего продуктового SHA) — не укусил: внешних мест нет.

## 8. Своя мера счётных утверждений

«+4 строки, один путь»: `--numstat` → `4 0`, `--name-status` → 1 путь. Совпадает.
«blob vmax 3/3/6/5»: `git tag -l` + `sort -n` → 3/3/6/5, blob совпадают. Совпадает.
«CI зелёный 16 pass»: `gh pr checks 1168` → 16 pass + 1 skipping. Совпадает.
