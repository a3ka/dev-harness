FAIL
OBJECT=c138290f05f75689526725d2951cb3cfdb855508
СУД: repo=dev-harness; предмет=140; фаза=реализация (v2); роль=reviewer; вызов=1/2 (полный); модель-план=anthropic/claude-opus-5-5; сессия=Rev140v2; модель-факт=anthropic/claude-opus-5-5; SHA=c138290f05f75689526725d2951cb3cfdb855508; предыдущий=adversary 140 impl v2 scoped 3 accept (Adv140v2c); исключение=нет; независимость: автор implementer (MiniMax), батарея architect (GLM), судья — Anthropic

Находки: `.review/2026-10-28-03.md` (status: ready) — R140v2-B1 (БЛОК), R140v2-S1…S4 (СОВЕТ).

Вердикт привязан к блобам:
- дверь `scripts/zamok_predmeta.sh` 799ee67a (== cff06dff);
- дерево `fixtures/workshop_project/odin_agent_140/` 598ff0ea (== c138290f);
- `registry/ci-steps.tsv` 840fc6d2;
- поезд `owner/train-140int2` 76d5a6ec поверх main 8b25a61c (5653f6d5 — его предок).

## БЛОКИРУЕТ

**R140v2-B1 — отказ `ZANYATO_RESHENIEM` снимает ЧУЖОЙ живой мьютекс; итог — два рабочих на одном предмете.**
- Обязательство: инв. 3 «решение пакета — под мьютексами ВСЕХ его предметов… гонка двух процессов — ровно один пропуск»; §ЗАЩИЩАЕТ «от гонки»; слово владельца 2026-10-28 «2 архитекторов на одну задачу нельзя».
- Класс причины: `scripts/zamok_predmeta.sh:426-427` (`mutexi_snyat_vse` — :286) — в `--sudit` ветка `if ! mutex_zajavit "$ms"; then mutexi_snyat_vse; otp ZANYATO_RESHENIEM …` снимает весь `$SUBJS`, включая мьютекс, который держит конкурент. Модель та же: дверь == модель.
- Достижимое состояние: два процесса судят один предмет, решение первого длится дольше окна повтора 2 с — случай, который предусмотрен самим отказом `ZANYATO_RESHENIEM`. Затем повтор второго или третий процесс. Длительность решения на станции не замерена [INFERENCE: тёплый `find` по 17 686 журналам — 0,065 с; медленное решение — нагрузка или холодный кеш].
- Наблюдение (mktemp-мир, `probe_mutex.sh`, медленный `find` у A имитирует медленный ввод-вывод): `A: PUSCHEM A153`, `B1: ОТКАЗ: ZANYATO_RESHENIEM`, `B2: PUSCHEM B153`, START по 153 = 2, повторено 3/3. Отдельно (б): после отказа B «мьютекс A СНЯТ». Контроль (г) последовательно: B → `RABOCHIJ_ZHIV`.
- Закрывающее свойство: отказанный процесс снимает только свои мьютексы; при любом раскладе времени — не больше одного START на (repoId, subjectId); клетка батареи + мутант «снять весь SUBJS». Одноразовая правка (`door-fix.sh`, не поставка) даёт «мьютекс A ЦЕЛ» и START 1; безфлаговый `W` на ней тоже rc 0 `KLETKI 70 KRASNYH 0`. Батарея не различает дефектную и исправленную дверь: клетки под это свойство нет. Инв. 4 при этом сохранить — см. S1.
- Арбитраж Arb140i («Счёт сторон»): унаследованный дефект — не граница v2, обязательства инв. 3/7 те же. Закрывается без v+1: architect (модель, клетка, стаб) → implementer (байт-копия тела) → scoped.

## СОВЕТ (подробности — `.review/2026-10-28-03.md`)

- S1 — инв. 4: упавший мьютекс без `zanyat` `--osvobodit` не подбирает (`NET_ZAMKA`). Сейчас это маскируется дефектом B1; закрывать вместе с ним.
- S2 — дыра батареи по Q3 1.1: мутант «`iskl` до проверки repoId» проходит 70/70, потому что w26 не пересекает номера своих и чужих записей. Поставленная дверь верна.
- S3 — гонка лимита группы между РАЗНЫМИ предметами: 2 из 3 занято, два параллельных процесса → `GRP harness 4 3`, 5/5. Инв. 3 этого не обещает; назвать остаток или ввести мьютекс группы — решение владельца.
- S4 — комментарий в `ci-steps.tsv:276` «63 входа / 60 связей» устарел (факт 70/67). Фраза коммита 76d5a6ec «ci.yml перегенерирован» — без диффа `ci.yml`.

## Проверено (сырые команды, rc, вывод) — клон `/tmp/dev-harness-verify/Rev140v2/repo`, checkout `origin/owner/train-140int2`

1. Объект и область.
   - `git cat-file -t c138290f` → `commit` (в worktree architect; в клон объект подтянут из worktree — на origin его нет, в поезде он cherry-pick d7fa151e).
   - `git rev-parse HEAD` → `76d5a6ec…`.
   - `git log origin/main..HEAD`: d7fa151e architect / 1acec15f implementer / 76d5a6ec orchestrator.
   - Файлы коммитов:
     - architect: 38 файлов, вне `fixtures/workshop_project/odin_agent_140/` — 0;
     - implementer: ровно `scripts/zamok_predmeta.sh`;
     - orchestrator: ровно `registry/ci-steps.tsv` (`ci.yml` без диффа: ключ шага прежний).
   - `git diff --stat origin/main HEAD -- contracts/ .omp/ .github/` → пусто.
   - Блобы: `HEAD:fixtures/…/odin_agent_140` = `c138290f:…` = 598ff0ea; `HEAD:scripts/zamok_predmeta.sh` = `cff06dff:…` = 799ee67a.
   - sha256 текста контракта HEAD = frozen/contracts/140/2 = `54e86cfd…a25747`.
2. Дверь == модель.
   - `diff <(sed -n '65,$p' scripts/zamok_predmeta.sh) <(sed -n '53,$p' …/model/zamok_predmeta.sh)` → rc 0, пусто; строка 65/53 — `set -uo pipefail`.
   - sha256 обоих тел — `efe02fa6718176556cbadf12dd05212d617b58d731b6ff13201cc0a0ca47bf8b` (моя мера совпала с докладом).
   - Дельта к main (`git diff origin/main HEAD -- scripts/zamok_predmeta.sh`): `CAP_HARNESS 1→3`, `CAP_BACK 2→3`; шапка «70 клеток», «frozen/contracts/140/2»; комментарий D25; `[D30 chuzhoj-reestr]` в `zhivykh_v_gruppe` (чужой repoId — `cnt+1; continue` до iskl/done/пауз) и в `--uchet` (done/pauza только при `$r = $REPO_ID`). Прочего нет.
   - «afbf0288» из сообщения implementer — коммит architect до `--amend`; его блоб модели равен блобу c138290f (6367f7ca).
3. Батарея (`TMPDIR` — мой каталог).
   - `W` → rc 0, `KLETKI 70 KRASNYH 0`; моя мера: 70 строк `CASE … ok`, 70 уникальных; множество имён == ключам `source.json:.kejsy` (70).
   - `W --model` ×3 → rc 0, 70/70 каждый.
   - `W --stabs` → rc 0, `SVJAZI 67`, `SUBJEKT_SVJAZI 67`, `STAB_ZHIV` нет. Моя мера: стабов в выводе 34 (уникальных), каталогов `stabs/` 34 = ключей `stab_vhod` 34, сумма привязок `stab_vhod` 67, строк `KRASEN` 134 = 67 × 2 слоя.
   - `env -i PATH=/usr/bin:/bin HOME=$T TMPDIR=$T`: `W` rc 0 70/0; `--model` rc 0; `--stabs` rc 0 67/67.
4. Красное предъявлено (подстановка в `scripts/` копии `mut/`, безфлаговый `W`).
   - Дверь `16b243bb` → rc 1, `KLETKI 70 KRASNYH 1` — ровно `w26`: 4-й START, ложные done чужих, `GRP back ('1','3')`, F153 жив.
   - Стабы в позиции двери:
     - `s31` → rc 1, ровно `w23`;
     - `s32` → rc 1, ровно `w24`;
     - `s33` → rc 1, ровно `w26`;
     - `s10` → `bash -n` rc 0, rc 1, ровно `s05` («причины SUDJA_ZHIV нет… RABOCHIJ_ZHIV»).
   - `diff` model↔стаб: s31 — +5 строк (судья под лимитом), s32 — SLOVO без `subjectId`, s33 — минус строка D30 цикла, s10 — ветка D21 заменена на `:`.
   - Мои мутанты:
     - `--uchet` без D30 → ровно `w26` («учёт: чужие записи с done»);
     - `CAP_BACK=2` → `u01`, `w21`, `w26`;
     - `CAP_HARNESS=4` → `u01`, `w13`, `w24`, `w26`;
     - `CAP_MOB=4` → `u01`, `w15`;
     - «iskl до D30» → 0 красных (S2).
   - Порча:
     - `echo '# tamper' >> model/…` → `--model` rc 2 `ORACLE_TAMPERED: sha256 носителя model/zamok_predmeta.sh`;
     - то же в стаб s33 → `--stabs` rc 2 `ORACLE_TAMPERED: sha256 носителя s33-done-chuzhogo-reestra`.
5. Гигиена, станция, гейты.
   - `run_battery.sh zamok_predmeta` → rc 0, «итог 4/4 классов закрыто».
   - `stancija_odin_agent_140.sh` → rc 0, `PROB VSEGO 15 KRASNYH 0` (15 строк `PROBA … OK`).
   - `check_provodka.sh <корень> contracts/140-odin-agent-na-predmet.md` → rc 0.
   - `check_charter.sh` → rc 0 («уставных документов: 141 · изменений в них: 360 · с разрешения: 360»).
   - `bash -n` двери, модели, `red_*`, `stancija_*` и 34 стабов → все rc 0.
   - `check_zones.sh` (последним) → rc 0, 320,9 с: «замороженных контрактов: 141 · объявленных авторов: 5 · коммитов в диапазонах: 36525 · проверено по зонам: 8139».
6. CI: `gh pr view 432` → head 76d5a6ec, OPEN, `SUCCESS 16, SKIPPED 1`; в шарде l3 есть `check:odin-agent-140-family-selftest` — SUCCESS. Строка шага — безфлаговая, вес 55 (`registry/ci-steps.tsv:277`).
7. Живые миры (mktemp, не учёт станции): сценарии `probe_world.sh` / `probe_mutex.sh` — P1 (S3), P2/P3 (S1), (а)–(г) (B1).

СВЕРКА-СТАНДАРТОВ: не применимо — `AGENTS.md` dev-harness не объявляет документ архитектуры и стандарт кода (grep `ARCHITECTURE|CODING-STANDARDS|стандарт кода` → 0).

ПРОВОДКА (038): канал `guard=fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh` существует и подключён. Шаг CI `check:odin-agent-140-family-selftest` идёт безфлаговым, зелёный в #432; `check_provodka` rc 0. Guard — барьер именно этого предмета: судит поставленную дверь. ПРОВОДКА-ЭНФОРСМЕНТ принят на freeze; новых поведенческих норм дифф не вводит.

Паразитная сложность (050), по артефактам диффа:
- `[D30]`, две ветви в двери/модели: (1) инв. 7 + Q3 1.1 арбитража (done/ПАУЗА своего реестра); (2) состояние не вводит, читает `REPO_ID`; (3) модель + дверь, как и прежде (число не выросло); (4) интерфейс двери не изменился; (5) потребитель — w26. ESSENTIAL.
- Клетки w23–w26 (`probe.py`): (1) инв. 5/7, Q3 1.2; (2) mktemp-миры, видимые в выводе CASE; (3) `probe.py` + `source.json` + `osi.md` — прежняя связка; (4) –; (5) шаг CI 140. ESSENTIAL.
- Семья стабов s31–s33: (1) инв. 8 (стаб ↔ вход); (2) нет; (3) стаб + пин `nositeli` + `stab_vhod` — прежняя связка; (4) –; (5) `--stabs`. ESSENTIAL.
- Изменение капов: (1) слово владельца 2026-10-28; простая форма. ESSENTIAL.
- ACCIDENTAL не найдено.

Остатки п.4 задания — названы честно, НЕ блок.
- (а) Сессия без `/zones/` получает блок: это исполнение инв. 1 («нет ctx/файла сессии вне грамматики → блок „страж сломан“»), а не нарушение. Сам не перемерял — опираюсь на замер Fix140v.
- (б) Sentinel-мутанты и литерал `cap=3` — вне периметра. Защита «дверь == модель» мной сверена. Чужая запись держит слот до RELEASE — fail-safe.
- (в), (г) — кандидаты v3.
- Найденное сверх них: B1 (гонки, блок), S1 (`--osvobodit`), S3 (гонка лимита).
- Откат пакета (b03) и `--uchet` (D30) моими мутантами покрыты, нового дефекта там не найдено.

НЕ ПРОВЕРЕНО:
- живой спавн omp и реальный учёт станции — не трогал;
- длительность решения двери на станции под нагрузкой: от неё зависит частота B1 [INFERENCE];
- воспроизведение пробы (а) Fix140v;
- блобы ленд-пачки вердиктов адверсария/арбитра — читал как файлы.
