FAIL
OBJECT=3572945eff21be13da950aedc3c1631a7d0b9470
КЛАСС=рисковый
СУД: repo=dev-harness; предмет=140; фаза=реализация; роль=adversary; вызов=1/2; модель-план=openai-codex/gpt-5.6-terra; сессия=Adv140v1; модель-факт=openai-codex/gpt-5.6-terra; SHA=3572945eff21be13da950aedc3c1631a7d0b9470; предыдущий=verdicts/critic/contracts-140-v3.md; исключение=нет

Независимость: судимый OBJECT — коммит implementer `dbdf6afe7`, перенесённый в дерево architect `3572945e`; судья не автор этой реализации. Фактическая модель взята из `/tmp/dev-harness-verify/orch/trace-adv143.tsv`.

## БЛОКИРУЕТ

БЛОКИРУЕТ `contracts/140-odin-agent-na-predmet.md:142` (инвариант 7: лимиты групп harness/mob/back 3/3/3) — лимит группы не атомарен между разными предметами.

КЛАСС ПРИЧИНЫ: мьютексы берутся только по `(repoId, subjectId)`; два независимых запроса на разные SUBJECT читают одинаковое значение заполненности группы до записи своих START и оба проходят.

ОБЯЗАТЕЛЬСТВО: «сверх лимита — только строка SLOVO» и «лимиты harness 3 / mob 3 / back 3 — верхняя граница».

СОСТОЯНИЕ: в учёте два живых harness-предмета 101 и 102; одновременно запущены два публичных `--sudit` для независимых рабочих 140 и 141, оба с корректными worktree/branch.

НАБЛЮДЕНИЕ: `timeout 300 python3 tmp_adv140_group_race.py` напечатал:
```
RACE ESCAPED attempt=1; rc140=0 rc141=0; starts=4; out140=PUSCHEM A140 dev-harness/140 (rabochij/architect); out141=PUSCHEM A141 dev-harness/141 (rabochij/architect)
```
Ожидание: один запрос разрешён, второй `LIMIT_GRUPPY`; факт: четыре START при капе 3. Вход — два обычных поддерживаемых одновременных task-спавна разных предметов, не запись атакующего в состояние.

## Пройденные атаки и позитивные контроли

- Приёмочная батарея на OBJECT: `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh`, `--model` и `--stabs` — rc 0, `KLETKI 76 KRASNYH 0`, `SVJAZI 71`, `SUBJEKT_SVJAZI 71`; станционная команда — rc 0 `PROB VSEGO 15 KRASNYH 0`.
- Контроль 167: `python3 fixtures/workshop_project/obryv_167/probe.py --repo`, `--model`, `--stabs` — rc 0, каждый `CHECKED 9 CASES; FAILURES 0`.
- Структурная сдача: честный последний `session_exit kind=normal`, CRLF, пробелы и строка 1 MiB разрешают; normal не последней строкой, пустая последняя строка, последний signal, `Normal`, `normal ` и битый JSON блокируют `RABOCHIJ_ZHIV`.
- Файловые границы: журнал-директория и симлинк блокируют `ZAMOK_BROSHEN`; `--osvobodit` с чужим holder блокирует `DERZHATEL_RASHODITSJA`.
- Класс риска, дерево OBJECT, legacy, не-blobs, конфликты деклараций, несоответствие tip и batch-откат проверены 76 клетками и 71 кодовой мутацией батареи; для отказа класса одного элемента пакет не оставляет START/замка.

## СОВЕТ

СОВЕТ `scripts/zamok_predmeta.sh:157` — выбор `find ... | sed -n '1p'` небезопасен при двух `<holder>.jsonl`: в стенде «active-first-normal-second» вернул rc 0, хотя один журнал того же holder остаётся без сдачи. Это согласуется с советом критика. Достижимость дубликата именованного журнала не доказана поддерживаемой операцией; поэтому не блокирует по §Быстрый-процесс.

Попытка скопировать журналы станции для дополнительной пробы была остановлена механизмом Н-85 до чтения/записи двери; живая дверь с реальным учётом станции не запускалась.
