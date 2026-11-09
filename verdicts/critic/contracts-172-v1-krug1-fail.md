FAIL

# Вердикт критика — контракт 172 «преддверие судейской проводки», вызов 1

## Учёт вызова

СУД: repo=dev-harness; предмет=172; фаза=контракт; роль=critic; вызов=1/2; модель-план=apex-sol (config/agent_models.json: critic→apex-sol); сессия=Critic172Predverie; модель-факт=zai/glm-5.3; SHA=dd14dbf23345d2df1487bbf8ab9c6da1bf3836ca; предыдущий=нет; исключение=нет.

Независимость: автор — Architect172GateContract (architect), судья не судит собственную работу; фактическая модель судьи отличается от плана apex-sol (назначение оркестратора); по контракту 166 семейный запрет снят, совпадение/несовпадение семейства с автором отказа не даёт. Предмет закоммичен: `git -C /tmp/dev-harness-worktrees/c907157c/wip-172-architect rev-parse HEAD` = `dd14dbf23345d2df1487bbf8ab9c6da1bf3836ca` — совпадает с OBJECT задания.

Набор артефактов полон: предмет, критерий готовности с командами и кодами возврата, исполнители пофайлово названы, ЗОНА-строки есть (контракт раздаёт работу), КЛАСС РИСКА указан и соответствует предмету («обычный» — прав/ролей/денег/ПД нет, адверсарий по норме не требуется).

## Обязательные прогоны (одноразовый клон OBJECT, дерево после прогонов чистое)

1. `bash scripts/pre_critic.sh --repo <клон> contracts/172-predverie-sudejskoj-provodki.md` → **rc 0**; вывод: `ok гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1` / `КРИТИК: дверь зелёная`.
2. `python3 fixtures/dver_pered_kritikom/predverie_172/red_predverie_172.py --repo` → **rc 1**; все 13 клеток именованно `KRASNO (rc=2)` — «самостоятельные красные имена каждой клетки» подтверждены (published, missing_origin, stale_origin, state_inside, manifest_wait, leak_reject, ff_sync, nonff_sync, judge_verdict, staged_main_verdict, committed_main_verdict, archive_free, archive_attached).
3. `... --model` → **rc 0**, 13/13 `ok`.
4. `... --stabs` → **rc 0**, 8/8: `STAB stale_origin|state_inside|ignore_manifest|ignore_leak|allow_nonff|allow_main_verdict (×2)|allow_archive_worktree caught`, ни одного `ZHIV`.
5. `bash scripts/check_threat_model.sh <клон> <контракт>` → **rc 0** «модель угроз: секция отсутствует (вне применимости барьера)» — гард для чужого ввода контракт не вводит (входы — от ролей станции), норма 041 не срабатывает.
6. `bash scripts/check_precision_gate.sh <клон> <контракт>` → **rc 0**, `OK` (норма 043: новые ЗОНА-строки и новая семья case-файлов — прогон обязателен, выполнен).
7. Механика: `registry/plan.tsv:100` = 172 ✓; `zamok_predmeta.sh`, `check_no_leak.sh` (`--check` отказывает fail-closed без снимка — соответствует «уже является детектором»), `gitw`, `gc_agent_branches.sh`, `check_provodka.sh`, `check_project_sources.sh` существуют ✓. Счётные утверждения приёмки (13 клеток, 8 стабов) сходятся с кодом батареи ✓.

## Мутационная атака критика (одноразовый клон; reference.py восстановлен после каждой мутации, сверено)

Каждая мутация — удаление/подмена названной предметной операции обязательной модели; прогон той же командой батареи.

**M1 — удаление отказа не-судейской ветки** (вырезаны reference.py:75-76):
```diff
-            if mutant != 'allow_main_verdict' and not (branch.startswith('wip/') and branch.split('/')[-1] in ('critic', 'adversary', 'reviewer', 'arbiter')):
-                return refuse('NE_SUDJSKAJA_VETKA')
```
`python3 fixtures/dver_pered_kritikom/predverie_172/red_predverie_172.py --model` → **rc 0**, сырой вывод:
```
published ok (rc=0)
missing_origin ok (rc=1)
stale_origin ok (rc=1)
state_inside ok (rc=1)
manifest_wait ok (rc=1)
leak_reject ok (rc=1)
ff_sync ok (rc=0)
nonff_sync ok (rc=1)
judge_verdict ok (rc=0)
staged_main_verdict ok (rc=1)
committed_main_verdict ok (rc=1)
archive_free ok (rc=0)
archive_attached ok (rc=1)
```

**M2 — удаление отказа при незаданных --branch/--sostojanie/--file** (вырезаны reference.py:36-37 и :69-70):
```diff
-            if not args.branch or not args.sostojanie:
-                return refuse('NE_POLNYJ_VHOD')
...
-            if not args.file:
-                return refuse('NE_POLNYJ_VHOD')
```
`... --model` → **rc 0**, 13/13 `ok` (вывод буквальный тот же, что у M1).

**M3 — ff без обновления checkout** (reference.py:65: merge заменён движением ref):
```diff
-                git(root, 'merge', '--ff-only', 'origin/main')
+                git(root, 'update-ref', 'refs/heads/main', remote)
```
`... --model` → **rc 0**, 13/13 `ok` (вывод буквальный тот же, что у M1): ref main равен origin/main, рабочее дерево остаётся старым — клетка ff_sync этого не видит.

**M4 (контрольная) — nonff-отказ без команды сохранения** (в STDERR-инструкции MAIN_NE_FAST_FORWARD оставлен только `reset --hard origin/main`, без `branch wip/172/architect-main-saved`): `... --model` → **rc 1**, `M4_nonff_bez_sohranenija: rc=1 ok_cells=12/13` — батарея поймала (клетка nonff_sync требует оба свидетеля). Контроль подтверждает: батарея краснеет там, где клетка есть; слепота M1–M3 — дефект покрытия, не общая зелёность.

## Находки

Единый класс всех трёх блокеров: **критерий готовности слабее предмета** — удаление/подмена названной в предмете операции обязательной модели оставляет батарею зелёной; зелёная батарея не отличает дверь с операцией от двери без неё. Перечислено полным списком по норме 2026-10-31.

БЛОКИРУЕТ contracts/172-predverie-sudejskoj-provodki.md:17 — предмет требует «любой иной не-судейский ref — rc 1 `NE_SUDJSKAJA_VETKA`», но у батареи нет клетки не-судейской ветки: case_input (fixtures/dver_pered_kritikom/predverie_172/red_predverie_172.py:60-83) переводит репозиторий только на `wip/172/critic` (judge_verdict) и `main` (staged/committed), CASES (:124-138) не содержит ожидания `NE_SUDJSKAJA_VETKA`.
ОБХОД: M1 выше — удаление белого списка судейских веток из reference.py проходит `--model` зелёной (rc 0, 13/13 ok): реализация без этой проверки будет принята как готовая.
ВХОД: поддерживаемая операция — шаг ПРОВОДКА «перед материализацией вердикта: `pre_judge.sh verdict --repo <root> --file <вердикт>`» на общем чекауте станции, который в фазах реализации/ленда стоит на не-судейских ветках (`wip/<N>/implementer`, main); предмет сам утверждает сценарий («любой иной не-судейский ref»).
МЕХАНИЗМ: удаление уже имеющейся предметной операции обязательной модели (reference.py:75-76).

БЛОКИРУЕТ contracts/172-predverie-sudejskoj-provodki.md:15 — предмет требует «`S` обязателен… Скрипт не угадывает путь из cwd/окружения», но батарея ни разу не вызывает дверь без `--sostojanie`/`--branch`/`--file`: evaluate (red_predverie_172.py:52-56) всегда передаёт полный набор аргументов. Отказ при неполном входе (reference.py:36-37, 69-70) не наблюдаем никакой клеткой, включая вариант «угадывания» пути — вход без S просто не подаётся.
ОБХОД: M2 выше — удаление обоих отказов `NE_POLNYJ_VHOD` проходит `--model` зелёной (rc 0, 13/13 ok): дверь, молча принимающая неполный вход (или берущая путь из окружения), будет принята как готовая.
ВХОД: явно утверждённый сценарием предмета («S обязателен», «не угадывает путь из cwd/окружения») плюс публичная сигнатура самой двери `[--branch B --sostojanie S --timeout T | --file V]`, в которой фазы prepare/verdict различаются набором аргументов — незаданный аргумент достижим от поддерживаемой операции без искажения входа.
МЕХАНИЗМ: удаление уже имеющейся предметной операции обязательной модели (reference.py:36-37, 69-70).

БЛОКИРУЕТ contracts/172-predverie-sudejskoj-provodki.md:17 и :25 — предмет требует sync-main «с наблюдаемым обновлением checkout», приёмка — «rc 0, рабочий checkout и main tip равны origin/main», но клетка ff_sync проверяет только ref: red_predverie_172.py:163-164 сверяет `git rev-parse main` с `origin/main` и не смотрит рабочее дерево.
ОБХОД: M3 выше — замена `merge --ff-only` на `update-ref refs/heads/main origin/main` (ref двигается, дерево остаётся старым) проходит `--model` зелёной (rc 0, 13/13 ok).
ВХОД: поддерживаемая операция sync-main после fetch (шаг ПРОВОДКА); наблюдавшийся рабочий случай — после sync-main судья и оркестратор читают файлы рабочего чекаута, ref без дерева даёт судье старое дерево при зелёном прогоне (ровно тот класс отказа «судья получает объект до готовности проводки», которым мотивирован предмет).
МЕХАНИЗМ: подмена уже имеющейся предметной операции обязательной модели (reference.py:65).

Закрывающее свойство (одним списком; реализацию клеток выбирает автор): (1) клетка не-судейской ветки — staged вердикт на `wip/172/implementer` → rc 1 `NE_SUDJSKAJA_VETKA`; (2) клетка неполного входа — prepare без `--sostojanie` (и verdict без `--file`) → именованный rc 1, без угадывания пути; (3) ff_sync наблюдает рабочее дерево — например, файл, принесённый origin/main, присутствует в чекауте после sync. После добавления все три мутации M1–M3 обязаны краснеть.

СОВЕТ contracts/172-predverie-sudejskoj-provodki.md:19 — ветка rc 2 `NOT_IMPLEMENTED` заявлена, но конформные входы сами исключают битый Git/отсутствующий детектор, и клетки нет: путь доказуем только чтением модели. Объявленная область последовательна, закрывать по усмотрению автора.
СОВЕТ contracts/172-predverie-sudejskoj-provodki.md:15 — сигнатура делает `--timeout` опциональным, но значение по умолчанию не названо (модель: 0.1); ПРОВОДКА всегда передаёт `--timeout 30`. Мелочь, закрывать по усмотрению.

## Что проверено и здорово

- Все четыре гарантии предмета покрыты: prepare (OBJECT=origin tip, sostojanie вне checkout, ожидание уборщика с конечным таймаутом, действующий детектор), ff-only main, verdict на судейской ветке, archive без worktree — каждая с именованным кодом отказа.
- Автопуш невозможен: автопуш в prepare сделал бы клетки missing_origin/stale_origin красными (rc 0 вместо 1) — проверено логикой клеток, стабы архитектора ловятся все (8/8).
- Не плодит второй замок/второй детектор: использует zamok_predmeta-подход для S и действующий `check_no_leak.sh --check`; утечка manifest_wait/leak_reject ловится с независимым флагом.
- Остаточный риск источника S честно назван cognitive-only с ловцом (сверка стенограммы задания с живым ctx).

Вердикт: FAIL — три блокирующих находки одного класса (покрытие батареи слабее предмета), закрытие — по одной клетке на каждую названную операцию.
