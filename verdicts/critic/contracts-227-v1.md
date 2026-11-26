FAIL
OBJECT=b2244d635f912b4c2997cbca387156db3fcff4cb

СУД: repo=dev-harness; предмет=227; фаза=контракт; роль=critic; вызов=1/2 (полный; новый предмет); модель-план=openai-codex/gpt-6.1-terra; сессия=Crit227; модель-факт=openai-codex/gpt-6.1-terra (метаданные запуска); SHA=b2244d635f912b4c2997cbca387156db3fcff4cb; предыдущий=нет; исключение=нет; автор=Architect227, отдельная сессия, фактическая модель автора по доступной истории не установлена. Доступный model-trace.tsv содержит разрешённые роли, а не привязку фактической модели к сессии; оркестратору необходимо сверить авторскую трассу до материализации.

## Карта классов

К-01: чисто — check_sdacha --run rc 0 и pre_critic rc 0 и precision-gate rc 0
К-02: чисто — вход R-0114/R-0102 и Fable §Ш-5ф и task-architect227
К-03: чисто — context.py rc 0 читает высшие frozen-блобы зон и их пересечения
К-04: чисто — вход зоны контракта строки 90–92 и context.py rc 0
К-05: блок — отсутствие проверяемого доказательства ошибки измерения
К-06: чисто — вход probe.py:29–38 и совет о классификации rc 2 субъекта
К-07: чисто — --model 26/0 и настоящий gen_ci_steps --write/--check
К-08: блок — отсутствие проверяемого доказательства ошибки измерения
К-09: чисто — вход конформные Git-миры probe.py:54–92
К-10: чисто — вход probe.py:125–155 проверяет JSON и обе трубы и снимки
К-11: чисто — вход ожидаемые records probe.py:52–92 и снимки перед запуском
К-12: чисто — вход настоящий Git и стандартный JSON и gen_ci_steps
К-13: н/п — секреты и их вывод не предмет отчёта
К-14: чисто — --stabs rc 0 два эквивалента зелёные
К-15: чисто — исходный git grep дал 89 строк и 20 файлов и catalog в листе 26/25/2/28
К-16: чисто — вход контракт строки 4 и 76–86 обычный read-only отчёт
К-17: н/п — станционный отчёт не меняет продуктовую модель 188

## Блоки

БЛОКИРУЕТ contracts/227-sh5f-zashivki-otchet.md:45,61 — отсутствие проверяемого доказательства ошибки измерения.
ПРОИСХОЖДЕНИЕ: пропущен-ранее
КЛАСС: К-08
ОБЯЗАТЕЛЬСТВО: при недоступности Git или невозможности закончить измерение публичный отчёт обязан вернуть rc 2 с NOT_IMPLEMENTED, а не печатать ложный ноль. Это явное обязательство строки 45; исключение ошибок инструмента из определения конформного входа строки 57 не отменяет его.
СОСТОЯНИЕ: исходная операция модели `model/scripts/report_zashivki.sh:19–21` проверяет rc настоящего `git grep` и превращает rc кроме 0/1 в исключение. В одноразовом клоне удалены только эти три строки проверки; прочий алгоритм и вывод не изменены, manifest/stabs перестроены штатным build.py. Сценарий отказа Git прямо заявлен строкой 45: команда git при вызове сообщает ошибку и возвращает 128, как при операционном сбое. Исполняемый отказавший git в PATH воспроизводит этот сценарий, не добавляя запрета входного значения.
НАБЛЮДЕНИЕ: батарея --model после удаления проверки зелёная 26/0; при отказе git тот же мутант возвращает rc 0 и JSON с lines=0, files=0, matches=[], stderr пуст. Это ложное измерение, не rc 2. Оракул проб не предъявляет сценариев операционной ошибки: probe.py:54–92 содержит только успешные миры, а probe.py:140–141 объявляет любой rc 2 субъекта недоступностью стенда. Критерий на строках 61–67 не отличает такую реализацию от правильной.
ОБХОД: убрать проверку rc grep из модели/реализации; все существующие честные и адресные клетки проходят, а при реальном отказе измерения CI получает ложный нулевой отчёт.
Закрывающее свойство: отдельное проверяемое наблюдение отличает ошибку именно процесса измерения/чтения конфига от пустого остатка и требует rc 2 с NOT_IMPLEMENTED без ложного JSON, сохраняя зелёную пустую корректную выборку. Как строить контролируемый отказ и какие стабы связать с клетками решает architect по коду (Н-39); отказ самого проверяющего и отказ субъекта не смешивать.

## Советы

СОВЕТ contracts/227-sh5f-zashivki-otchet.md:53 — при удалении `-I` из настоящей операции Git бинарный конформный файл приводит к rc 2 теста `SUBJECT_UNAVAILABLE`, хотя причина — результат субъекта на корректном входе. Приёмка не зелёная, поэтому это не обход. Для диагностики полезно отделить ошибку проверяемой программы от отсутствия инструментов проверяющего.

## НЕ ЗАЩИЩАЕТ

Семантические зашивки вне ERE и сознательную подмену конфига не выявляет; ловец — reviewer полного diff/config (контракт:83–85). Отказ инструмента не является измеренным нулём и остаётся заявленным обязательством, а не исключением из него.

## Доказательства и атаки

Чистое OBJECT: `git grep -n -I -E 'Complior-(back|mob)|a3ka/Complior|complior-(back|mob)|\.harness/' -- scripts .omp/extensions .githooks ':!scripts/proxy' | wc -l` → `89`, rc 0; та же команда с `-l` вместо `-n` → `20`, rc 0. `--repo .` → rc 1, `SUBJECT_ABSENT: scripts/report_zashivki.sh`. После реализации implementer обязан поставить script/config из зоны, orchestrator — добавить обе строки CI и сгенерировать workflow; только тогда тот же --repo проверяет живой субъект и CI, не поднимая порога остатка.

Сдаточный лист `SDACHA_TIMEOUT_SEK=1200 SDACHA_BUDZHET_SEK=2400 bash scripts/check_sdacha.sh "$PWD" contracts/227-sh5f-zashivki-otchet.md --run` rc 0: `СДАЧА: лист зелёный (двери=11 карта=17/17 дельта=0)`; `bash scripts/pre_critic.sh contracts/227-sh5f-zashivki-otchet.md` rc 0: `КРИТИК: дверь зелёная`; `bash scripts/check_precision_gate.sh "$PWD" contracts/227-sh5f-zashivki-otchet.md` rc 0: `OK`. `context.py` rc 0 `ДЕКЛАРАЦИИ 65`. Исходный `--stabs` rc 0: `STABY 25 EKVIVALENTY 2 ZHIVYH 0` (включая исходный честный `--model` 26 зелёных).

Мутации выполнялись отдельно в disposable Git-клонах OBJECT; W — команда из контракта. Для первой мутации после удаления операции проверки rc был вызван `python3 -B fixtures/workshop_project/zashivki_otchet_227/build.py`, затем `W --model`; для остальных создан настоящий production carrier и после `bash scripts/gen_ci_steps.sh --write` запущен `W --repo .`. Проверяемый отказ git воспроизведён отдельным исполняемым `git` в PATH, который пишет `git failure` в stderr и возвращает 128. Сырой вывод первой атаки:

```text
STABY 25 EKVIVALENTY 2 SVJAZI 28
ATTACK grep-error --model rc 0
nonempty GREEN
empty GREEN
excluded-only GREEN
exclude-boundary GREEN
changed-pattern GREEN
changed-include GREEN
changed-exclude GREEN
no-excludes GREEN
untracked GREEN
binary GREEN
same-content GREEN
line-numbers GREEN
comments GREEN
substring GREEN
unicode-path GREEN
literal-paths GREEN
literal-excludes GREEN
changed-baseline GREEN
dirty-worktree GREEN
above-baseline GREEN
above-file-baseline GREEN
empty-directories GREEN
default-config GREEN
ci-wiring GREEN
ci-measurement GREEN
ci-generator GREEN
KLETKI 26 KRASNYH 0
FAILING GIT rc 0 stdout '{"lines": 0, "files": 0, "matches": [], "baseline": {"lines": 89, "files": 20, "commit": "6565542c1"}}\n' stderr ''
```

Другие реально выполненные атаки, ниже — сырые отличающиеся строки и итог (прочие клетки GREEN):

```text
ATTACK binary-a generator rc 0
--repo rc 1
binary RED REPORT_CONTENT
KLETKI 26 KRASNYH 1
ATTACK no-exclusion generator rc 0
--repo rc 1
excluded-only RED REPORT_CONTENT
exclude-boundary RED REPORT_CONTENT
changed-exclude RED REPORT_CONTENT
literal-excludes RED REPORT_CONTENT
KLETKI 26 KRASNYH 4
ATTACK noisy-failure generator rc 0
--repo rc 1
nonempty RED REPORT_BLOCKS_RESIDUE rc=1
exclude-boundary RED REPORT_BLOCKS_RESIDUE rc=1
changed-pattern RED REPORT_BLOCKS_RESIDUE rc=1
changed-include RED REPORT_BLOCKS_RESIDUE rc=1
changed-exclude RED REPORT_BLOCKS_RESIDUE rc=1
no-excludes RED REPORT_BLOCKS_RESIDUE rc=1
same-content RED REPORT_BLOCKS_RESIDUE rc=1
line-numbers RED REPORT_BLOCKS_RESIDUE rc=1
comments RED REPORT_BLOCKS_RESIDUE rc=1
substring RED REPORT_BLOCKS_RESIDUE rc=1
unicode-path RED REPORT_BLOCKS_RESIDUE rc=1
literal-paths RED REPORT_BLOCKS_RESIDUE rc=1
literal-excludes RED REPORT_BLOCKS_RESIDUE rc=1
changed-baseline RED REPORT_BLOCKS_RESIDUE rc=1
dirty-worktree RED REPORT_BLOCKS_RESIDUE rc=1
above-baseline RED REPORT_BLOCKS_RESIDUE rc=1
above-file-baseline RED REPORT_BLOCKS_RESIDUE rc=1
KLETKI 26 KRASNYH 17
```

Отдельно замена `'-I', '-E'` на `'-E'`, `W --repo <одноразовый-клон>` — rc 2, сырой вывод после девяти зелёных клеток:

```text
NOT_IMPLEMENTED: SUBJECT_UNAVAILABLE: b'NOT_IMPLEMENTED: ZASHIVKI_REPORT: not enough values to unpack (expected 3, got 1)\n'
```

До запуска измерения нагрузка `uptime`: `load average: 22.27, 22.11, 20.42`. Ошибок таймаута не наблюдалось.
