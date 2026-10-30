accept
# Вердикт reviewer — 146 shablon-dvizhenie, реализация (SUBJECT=146, OBJECT=1837ce6cdd1bcdd07eec66bddd21b2fc7d4b5a84)

OBJECT=1837ce6cdd1bcdd07eec66bddd21b2fc7d4b5a84
СУД: repo=dev-harness (PR #455, ветка owner/train-int146b, `git rev-parse FETCH_HEAD` = OBJECT); предмет=146; фаза=реализация (контракт frozen/contracts/146/1 = fbc23ab7e8aed5021c0ff2d633f5b2222dc4c17a); роль=reviewer; вызов=1 (класс «обычный», один полный вызов); сессия=Rev146; модель-факт=anthropic/claude-opus-5-5; родитель поезда = origin/main 18d8e7449711a864bb033147c46791475356033c.
Независимость: модель architect — автор батареи/эталона, implementer — автор порта; судья — семейство Anthropic. Accept привязан к OBJECT и не наследуется другой редакцией ветки.

Находки: `.review/2026-10-30-01.md` (`status: ready`). Блокеров нет, два совета: С-1 — внести вердикт Crit146e (orchestrator); С-2 — устаревший sha эталона в тексте frozen 146/1 (architect, v+1).

Клон суда — `/tmp/dev-harness-verify/Rev146`: собственный `.git` (клон с `--reference`, затем `git repack -a -d` и удалён `objects/info/alternates`), origin `ssh://git@github.com/a3ka/dev-harness.git`, checkout OBJECT. Мутации вносились только в одноразовых клонах `Rev146-mutA` и `Rev146-mutB`; базовый контроль — в `Rev146-base`.

## БЛОКИРУЕТ

Нет.

## 1. Область правки

`git log --format='%h %an | %s' origin/main..OBJECT` — три коммита, у каждого один автор, одна задача и ссылка на 146:

| Коммит | Автор | Файлы (`git show --name-status`) | ЗОНА контракта |
|---|---|---|---|
| 2d307443 | architect | M `fixtures/workshop_project/shablon_dvizhenie_146/model/ekran_shablon.py`, M `…/osi.md` | `ЗОНА architect: fixtures/workshop_project/shablon_dvizhenie_146/` (стр. 85) |
| 92bbf07b | implementer | M `scripts/ekran_shablon.py` | `ЗОНА implementer: scripts/ekran_shablon.py` (стр. 86) |
| 1837ce6c | orchestrator | M `.github/workflows/ci.yml`, M `registry/ci-steps.tsv`, M `registry/ci-zamery.tsv` | `ЗОНА orchestrator: …` (стр. 87) |

`git diff --stat origin/main OBJECT`: 6 файлов, все в объявленных зонах, лишних нет. Атомарность соблюдена.

`ci.yml` проверял своей мерой (`keys.py`: разбор диффа по строкам `keys:`). Строк, кроме `keys:`, изменено 0; ключей было 83, стало 84, дублей 0. Добавлен ровно `check:shablon-dvizhenie-146-family-selftest`, ни один ключ не удалён. Остальное — перебалансировка lanes генератором; форма чужих шагов не менялась.

## 2. Замороженный текст

- `git diff frozen/contracts/146/1^{commit} OBJECT -- contracts/146-shablon-dvizhenie.md | wc -c` → **0**.
- `git cat-file -e frozen/contracts/146/1^{commit}:contracts/146-shablon-dvizhenie.md` → путь есть, то есть пустой дифф не означает отсутствие файла.
- `git merge-base --is-ancestor frozen/contracts/146/1^{commit} OBJECT` → rc 0.

## 3. Порт

- `sha256sum scripts/ekran_shablon.py model/ekran_shablon.py`: оба `5fd1415e40b257e5e7b97c7bf9bc8fe31e94dcea9e05c4c3ac44d68802db453b`. `cmp` → rc 0, IDENT. `wc -l` → 2133.
- Эталон против родителя (`git diff origin/main OBJECT -- …/model/ekran_shablon.py`): одна добавленная строка 2, комментарий `# НЕ БАРЬЕР: субъект (SUBJECT) батареи …`. Исполняемый код не менялся, значит поведение идентично.
- Живой v2 родителя `git show origin/main:scripts/ekran_shablon.py`: sha256 `0285a02c…`, 1439 строк. Совпадает с v2-базой контракта («Существующее»).

## 4. Неподгонка и красное

- Шаг CI через реальный раннер: `bash scripts/run_ci_lane.sh check:shablon-dvizhenie-146-family-selftest` → `+ bash fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh` (без флага), `клеток 289, зелёных 289, красных 0`, `PORT_DOSLOVEN sha256=5fd1415e…`, `замер: … 47`, real 0m46.349s, **LANE_RC=0**.
- Своя мера, другой командой: `red_shablon_dvizhenie_146.sh | grep -cE '^CASE .* ok$'` → **289**, RC146=0.
- **Мутант A** (`Rev146-mutA`, ровно 1 байт). `cmp -l` → `105409 60 71`: `or nt == 0:` → `or nt == 9:` (OTCHET_PUSTOJ). Безфлаговая батарея → **MUTA_RC=1**: `клеток 289, зелёных 288, красных 1` (`CASE otchet-pustoj KRASNO: rc=0, ожидался 1; … OTCHET_PUSTOJ`) и `PORT_NE_DOOSLOVEN: scripts/ekran_shablon.py (sha256=2c3f0b76…, 2133 строк) != model/ekran_shablon.py (sha256=5fd1415e…)`. Красные обе стороны — клетка и побайтовый порт.
- **Мутант B** (`Rev146-mutB`): из `scripts/ekran_shablon.py` удалена строка 2 `# НЕ БАРЬЕР:` (`git diff --numstat` → `0 1`). `verify_antiplacebo.sh --scope next_id` → `FAIL ekran_shablon.py: не классифицирован — объявите в шапке 'Коды возврата:' либо 'НЕ БАРЬЕР: <почему>'`, **AP_MUTB_RC=1**. Контроль на чистом OBJECT (`Rev146-base`), та же команда → **AP_BASE_RC=0**, строки FAIL нет.
- Проверки не подогнаны под код. Implementer менял только `scripts/ekran_shablon.py`: probe.py, source.json, стабы и обёртку не трогал. Эталон после заморозки правил architect, своей зоной. Правка — строка-комментарий классификации, нужная анти-плацебо-скану `scripts/` (мутант B показывает, что без неё порт красный). Ожиданий клеток она не меняет. Судейский след этой правки — Crit146e, файл которого в дереве OBJECT отсутствует (С-1).

## 5. Регресс соседей (scoped, клон OBJECT)

- 132, live без флага: `red_ekran_shablon_132.sh` → R132_RC=0, все строки `CASE … ok`. Своя мера: `grep -cE '^CASE .* ok$'` → **70**, RC132=0.
- 118 `--stabs`: `red_erstinformation_118.sh --stabs` → **RC=0** (`SVJAZI 73`).
- 135 `--stabs`: `red_first_run_ekran_135.sh --stabs` → **RC=0** (`SVJAZI 13`).
- 138 `--stabs`: `red_start_ekran_138.sh --stabs` → **RC=0** (`SVJAZI 53`).
- Шаг CI 146 исполняет безфлаговую команду. Это видно по `registry/ci-steps.tsv:141` (`step	check:shablon-dvizhenie-146-family-selftest	50	bash …/red_shablon_dvizhenie_146.sh`) и по трассе `run_ci_lane.sh` выше. В `ci.yml:274` ключ стоит в lane l2, а шаг lane — `bash scripts/run_ci_lane.sh ${{ matrix.keys }}`.

## 6. Проводка

- `bash scripts/gen_ci_steps.sh --check` → **rc 0**.
- `bash scripts/check_provodka.sh . contracts/146-shablon-dvizhenie.md` → **PROV_RC=0**. До заморозки был ожидаемый rc 1 «guard не подключён» — по «Сдаче» контракта.
- Вес 50 (`ci-steps.tsv:141`, `ci-zamery.tsv:87` → `50 1 0`) против замера: 47 с по раннеру и 46.3 с по `time`. Сходится, с запасом около 6 %.
- Каналы ПРОВОДКИ: `guard=fixtures/workshop_project/shablon_dvizhenie_146/red_shablon_dvizhenie_146.sh` существует, подключён шагом CI и является барьером этого предмета: судит субъект `scripts/ekran_shablon.py` клетками и побайтовым портом. ПРОВОДКА-ЭНФОРСМЕНТ обоснована честно: валидатор формы, поведенческой нормы нет, role-канал не требуется.

## Паразитная сложность (050) — по дельте

| Артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / повтор | Класс |
|---|---|---|---|---|---|---|
| строка `# НЕ БАРЬЕР:` шапки эталона/порта | И-8 (порт == эталон) при скане `scripts/` анти-плацебо (без неё — «не классифицирован», мутант B) | нет | 2 (модель + порт, одно байт-равенство) + `osi.md` (прозаический пин) | интерфейс не менялся | ap1–ap5, безфлаговая батарея; грамматику шапки не повторяет, а использует | ESSENTIAL |
| `scripts/ekran_shablon.py` v3 | И-8 (дословный порт) | нет новых флагов/env/файлов состояния | 1 (копия) | CLI тот же, работа выросла веткой dvizhenie | шаг CI 146, батарея 132 (70/70) | ESSENTIAL |
| строки `ci-steps.tsv` / `ci-zamery.tsv` / ключ `ci.yml` | ПРОВОДКА (шаг selftest без флага) | явно в реестре | 3, генератор держит согласованность (`--check` rc 0) | — | lane l2 | ESSENTIAL |

Перепин sha в `osi.md:15` — вторая запись того же факта, что и байты эталона. Это совет (С-2 о синхронности), не блок: более простой формы, проходящей строки приёмки, дифф не опровергает.

## СВЕРКА-СТАНДАРТОВ

Неприменимо: `AGENTS.md` харнесса не объявляет `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` (`grep -nE 'ARCHITECTURE|CODING-STANDARDS' AGENTS.md` → пусто). Дифф — байт-копия эталона и реестровые строки.

## Мобильный экран

Не применимо: предмет — валидатор формы ekran.json, экранов и кадров в дельте нет. Кадры и движение экранов D 2.4 — контракты 147+.

## НЕ проверено

- `--model`, `--stabs`, `--d24-real`, `--differencial`, `--oracle-tamper` не повторялись. По ПРИЁМКЕ-СУДЬИ требуются только scoped-регресс и дифф frozen. Эталон менялся только комментарием, и это покрывает scoped-критик Crit146e.
- Живой CI PR #455 (16 pass) — со слов задания. `gh` своей мерой не запрашивал.
- Полный `verify_antiplacebo` и `check_zones` не прогонялись. Для анти-плацебо прогнан scoped-ключ `next_id`: скан классификации `scripts/` в нём безусловный. Зоны сверены вручную со строками ЗОНА (п. 1).
