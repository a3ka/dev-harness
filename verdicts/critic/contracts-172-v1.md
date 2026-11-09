accept

# Вердикт критика — контракт 172 «преддверие судейской проводки», вызов 2 (закрытие класса FAIL v1)

## Учёт вызова

СУД: repo=dev-harness; предмет=172; фаза=контракт; роль=critic; вызов=2/2; модель-план=apex-sol (config/agent_models.json: critic→apex-sol); сессия=Critic172RoundTwoLanded; модель-факт=zai/glm-5.3; SHA=2834aa8c45d124b3df2f23aaa191160a428af190; предыдущий=FAIL (verdicts/critic/contracts-172-v1.md, коммит 4e023159c607673ad2e0067798f1be8f7312d6ae); исключение=нет.

Независимость: автор — Architect172GateContract (architect), судья — Critic172RoundTwoLanded, судья не судит собственную работу; фактическая модель судьи отличается от плана apex-sol (назначение оркестратора), по контракту 166 семейный запрет снят, совпадение семейства с автором отказа не даёт.

Предмет закоммичен и совпадает с заданным объектом: `git -C <worktree> rev-parse wip/172/architect` = `2834aa8c45d124b3df2f23aaa191160a428af190` = OBJECT. Дельта от судимого в v1 (`dd14dbf2`) — один коммит `2834aa8c4 172: cover judge branch, missing inputs, and checkout ff mutations`, ровно три файла: контракт (список клеток + три строки приёмки), батарея, контрольная модель. Область вызова 2 по §Контракт: закрытие классов v1 и последствия дельты; новые поверхности не открыты.

## Класс FAIL v1 и его закрытие

Единый класс v1: критерий готовности слабее предмета — удаление/подмена названной операции обязательной модели оставляло батарею зелёной. Закрывающее свойство v1 требовало по одной клетке на операцию; все три клетки в кандидате есть, каждая именована и в приёмке, и в коде батареи:

1. `nonjudge_verdict` — staged вердикт на `wip/172/implementer` → rc 1 `NE_SUDJSKAJA_VETKA` (red_predverie_172.py:110, CASES:139; приёмка: «Дано: staged verdict на `wip/172/implementer`; … → rc 1 `NE_SUDJSKAJA_VETKA`»). Закрывает блокер v1 про не-судейский ref.
2. `prepare_no_state` / `verdict_no_file` — prepare без `--sostojanie` и verdict без `--file` → rc 1 `NE_POLNYJ_VHOD` (evaluate:56-57, :59-60; CASES:129, :138; приёмка: две отдельные строки «опущен только `--sostojanie`» и «с опущенным `--file`»). Закрывают блокер v1 про неполный вход и угадывание пути.
3. `ff_sync` наблюдает рабочее дерево: сверка не только `main`==`origin/main`, но и файл, принесённый опубликованным потомком, присутствует в чекауте (red_predverie_172.py:167-168, :180-183; приёмка: «рабочий checkout содержит файл из опубликованного потомка и main tip равен origin/main»). Закрывает блокер v1 про sync-main без обновления checkout.

## Обязательные прогоны (одноразовый клон OBJECT внутри worktree tmp, удалён после; дерево клона после каждой мутации восстановлено — `git status --porcelain` пуст)

1. `bash scripts/pre_critic.sh --repo <клон> contracts/172-predverie-sudejskoj-provodki.md` → **rc 0**: `ok гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1` / `КРИТИК: дверь зелёная`.
2. `python3 fixtures/dver_pered_kritikom/predverie_172/red_predverie_172.py --repo` → **rc 1**, все 16 клеток именованно `KRASNO (rc=2)` (двери ещё нет — зона implementer, `scripts/pre_judge.sh` отсутствует): published, prepare_no_state, missing_origin, stale_origin, state_inside, manifest_wait, leak_reject, ff_sync, nonff_sync, judge_verdict, verdict_no_file, nonjudge_verdict, staged_main_verdict, committed_main_verdict, archive_free, archive_attached.
3. `... --model` → **rc 0**, 16/16 `ok`; контрольный повтор после всех мутаций и восстановлений — снова **rc 0**, 16/16.
4. `... --stabs` → **rc 0**, 12/12 `STAB ... caught`, ни одного `ZHIV`: stale_origin, allow_incomplete_prepare, state_inside, ignore_manifest, ignore_leak, allow_nonff, ref_only_ff, allow_main_verdict (×2), allow_incomplete_verdict, allow_nonjudge_verdict, allow_archive_worktree.

## Мутационная атака (физические правки reference.py в одноразовом клоне; каждая восстановлена, после каждой — сверка чистоты)

**M1 — удаление отказа не-судейской ветки** (вырезаны reference.py:78-79 — условие `mutant not in ('allow_main_verdict', 'allow_nonjudge_verdict') and not (branch.startswith('wip/') and … in ('critic','adversary','reviewer','arbiter'))` и `return refuse('NE_SUDJSKAJA_VETKA')`, diff: 2 deletions). `--model` → **rc 1**, ровно одна клетка красная: `nonjudge_verdict KRASNO (rc=0)` — модель без проверки молча принимает verdict на `wip/172/implementer`, клетка требует именованный отказ. Остальные 15 ok.

**M2a — удаление prepare-отказа `NE_POLNYJ_VHOD`** (вырезаны reference.py:36-37; diff: 2 deletions). `--model` → **rc 1**, ровно `prepare_no_state KRASNO (rc=0)`: модель без отказа угадывает путь (`args.sostojanie or root.parent/'state'` — ровно внешний state фикстуры), уходит в rc 0 с OBJECT=/SOSTOJANIE=, клетка всё равно требует rc 1 `ОТКАЗ: NE_POLNYJ_VHOD`. Угадывание пути наблюдаемо и поймано. Остальные 15 ok.

**M2b — удаление verdict-отказа `NE_POLNYJ_VHOD`** (вырезаны reference.py:72-73; diff: 2 deletions). `--model` → **rc 1**, ровно `verdict_no_file KRASNO (rc=0)`: модель молча подставляет путь по умолчанию `verdicts/critic/contracts-172-v1.md`, клетка требует именованный отказ. Остальные 15 ok.

**M3 — ff без обновления checkout** (reference.py:68: `git(root, 'merge', '--ff-only', 'origin/main')` → `git(root, 'update-ref', 'refs/heads/main', remote)`). `--model` → **rc 1**, ровно `ff_sync KRASNO (rc=0)`. Прямое наблюдение checkout-файла (одноразовый сценарий на тех же setup/case_input, скрипт и клон впоследствии удалены):
- мутант: `rc=0 stdout='MAIN=c249df00…'`, `main==origin/main: True`, **checkout-файл remote: ОТСУТСТВУЕТ (дерево не обновлено)**;
- честная модель: тот же rc 0 и refs, **checkout-файл remote: ПРИСУТСТВУЕТ, содержимое='remote\n'**.
Наблюдаемое изменение checkout-файла — единственная разница двух прогонов, и именно её клетка и проверяет.

Все три мутации v1 (M1–M3) теперь краснят батарею каждая своей клеткой; зелёная батарея отличает дверь с операцией от двери без неё. Класс FAIL v1 закрыт.

## Счётные и механические утверждения дельты (полным списком, норма 2026-10-31)

- Клеток в приёмке 16, в CASES 16, множества имён совпадают (сверено программно: расхождение НЕТ).
- Стабов в MUTATIONS 12, все 12 caught, ZHIV нет; контракт числа не называет, противоречия нет.
- Свидетель nonff: контракт `branch wip/<N>/<author|judge>-main-saved` ↔ батарея `'branch wip/172/architect-main-saved'` ↔ вывод модели — совпадает.
- `scripts/check_provodka.sh`, `scripts/check_project_sources.sh` существуют; `scripts/pre_judge.sh` на OBJECT отсутствует (ожидаемо: зона implementer, клетка published красная именно поэтому).
- Расхождений не найдено.

## Остаток

Два совета v1 (ветка rc 2 `NOT_IMPLEMENTED` доказуема только чтением модели; значение `--timeout` по умолчанию не названо) не входят в класс FAIL, остаются советами и с accept закрываются по усмотрению автора. N-39 соблюдён: привязка стабов к ветвям — в коде батареи, контракт несёт инварианты и rc-команды.

Вердикт: **accept** — класс FAIL v1 (покрытие батареи слабее предмета) закрыт тремя именованными клетками, каждая доказана физической мутацией; честная модель зелёная до и после; дельта механически сходится.
