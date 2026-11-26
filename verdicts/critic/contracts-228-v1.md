FAIL
OBJECT=4516787ba0973da23e46cea93b227e9b28465289
СУД: репо=dev-harness; предмет=228; фаза=контракт; роль=critic; вызов=1 (полный; новый предмет); сессия=c907157c; модель-факт=openai-codex/gpt-6.1-terra (apex-sol, назначение config/agent_models.json); автор Architect228/b/c — openai-codex/gpt-6.1-sol (тир slow по реестру roles.architect, слово владельца 2026-11-23; фактические модели трассы внутри сессий недоступны суду — сверено по назначению, независимость моделей соблюдена: семейства/назначения не совпадают с судьёй)

# Вердикт критика 228 — Ш-3 owner-overrides, вызов 1 (полный)

Кандидат: contracts/228-sh3-owner-overrides.md + батарея fixtures/workshop_project/owner_overrides_228/ на OBJECT 4516787ba0973da23e46cea93b227e9b28465289 (закоммичен, HEAD ветки wip/228/orchestrator-c3; авторство architect@dev-harness.local). Набор артефактов полон: предмет, критерий готовности (rc-команды), КЛАСС РИСКА «рисковый — авторизация/безопасность» (совпадает: уставные двери), модель угроз (норма 041: ЗАЩИЩАЕТ 3 буллета / НЕ ЗАЩИЩАЕТ 4, по свойству), ЗОНЫ и 97 ПЕРЕСЕЧЕНИЙ, РАБОТА РАЗДАЁТСЯ: implementer. Нормы форм соблюдены.

## Прогон обязательных дверей (сырой вывод — ниже, раздел «Сырой вывод»)

- SDACHA_TIMEOUT_SEK=1200 SDACHA_BUDZHET_SEK=2400 bash scripts/check_sdacha.sh "$PWD" contracts/228-sh3-owner-overrides.md --run → rc 0, «СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=0)», 191.08 с.
- bash scripts/pre_critic.sh contracts/228-sh3-owner-overrides.md → rc 0, «КРИТИК: дверь зелёная», 206.18 с.
- bash scripts/check_precision_gate.sh "$PWD" contracts/228-sh3-owner-overrides.md → rc 0, «OK», 26.98 с (все 97 объявленных пересечений подтверждены живым zones_load/git show frozen; вывод context.py — 688 строк, полный в scratch-журнале прогона).
- python3 fixtures/workshop_project/owner_overrides_228/context.py → rc 0: SHA40 166/53/18/0 (итог 237), noncomment 90/36/10/0 — числа контракта «Существующее» совпадают с живым деревом; check_no_leak/check_staged без SHA40 — подтверждено.
- W --repo . (до реализации) → rc 1, KLETKI=52 ZELENYE=6 KRASNYE=46, 3.71 с — «красное ДО» по умыслу (OWNER_INTERFACE_ABSENT / отсутствие carrier-проверки), совпадает со сдаточным листом 228c. Как реализация позеленит: implementer в ЗОНЕ пишет scripts/lib_owner.sh + registry/owner-overrides.tsv и подключает читатель в четыре двери ровно так, как построен reference build.py (валидация источника до применения, carrier-проверка И5, перенос предикатов) — те же 52 клетки обязаны позеленеть на неизменённых мирах.
- Счётные сверки (К-15): census source.json {клетки 52, мутации 35, связи 43, строки 148, матрица 586, unique_sha 133, исторические решения 532} = W --catalog; снимок 78/4/312, complete=false, equality-log 78 строк == reproducible_shas (jq-сверка); records 312: baseline==historical.json и reference==baseline для каждой записи (0 расхождений); unreproducible 4×check_zones BASELINE_SIGPIPE; failure BASELINE_TIMEOUT 60 с, elapsed 6421.7. Файлы «РАЗРЕШИЛ-ВЛАДЕЛЕЦ» в scripts+.githooks = 12 (grep по живому дереву) — как в контракте.

## Граница исторического доказательства (главный вопрос задания) — честная и достаточная

Реконструированный снимок допустим как закоммиченное свидетельство: provenance.kind=reconstructed-from-equality-log назван в схеме (констант-схема), producer 247e39679b…, хеш исходного equality-log 3e25f1dd… в snapshot-lock.json, complete=false закреплён схемой (min/max exact), рост/усечение/подмена исключений и записей дают rc 2 (клетки historical_snapshot_checks: mismatch/truncated/growth/completeness/tampered/baseline-identity; стабы 6/6 ZHIVYH=0 — проверено прогонами --model в этом суде). Снимок не выдаёт зелёный за несуществующее доказательство: «Живого пересъёма 133 SHA в --model нет» (И6), критерий печатает complete=false REPRODUCIBLE_SHAS=78, а живой replay вынесен отдельной ручной командой --historical (rc 0/1/2 определены, полный/неполный исход не маскируется). Ловцы и остаточный риск записаны в «НЕ ЗАЩИЩАЕТ» (reviewer — полный diff, литеральная матрица 148/586, живые API/CLI миры, ручной --historical перед ленд-ревью; решение о границе — оркестратор). Подмена reference ловится живыми мирами --model (integration/frozen клетки исполняют двери, а не снимок) и стабами снимка. Это закрытие по правилу «граница»: обязательство не сужено — паритет 78×4 остаётся свидетельством, а 55 невоспроизведённых SHA честно названы недоказанными. Дополнительных блоков граница не даёт.

## Блокирующие находки

Обе — ложная достаточность критерия «W --model rc 0» для инвариантов И1/И3: Batterie не различает честную передачу контекста и её молчаливую замену. Мутации выполнены живьём в одноразовом клоне tmp/clone-crit228 (код-якоря, Н-39), сырой вывод ниже.

БЛОКИРУЕТ contracts/228-sh3-owner-overrides.md:42 (И3) + :75 (ЗАЩИЩАЕТ «чужой … автор») — критерий не проверяет передачу автора дверью.
ОБЯЗАТЕЛЬСТВО: И3 — «потребитель решения ОБЯЗАН передавать scope-контекст пути и требуемого автора»; модель угроз обещает защиту от расширения индульгенции на чужого автора.
СОСТОЯНИЕ: reference честной модели передаёт автора коммита (fixtures/workshop_project/owner_overrides_228/build.py:106 и :111 — `owner_override_has check_zones/process|mint "$c" "$f" "$an"`). Замена обеих передач `$an` литералом `orchestrator` (python-replace по единственному якорю каждой строки).
НАБЛЮДЕНИЕ: W --model с мутантом полностью зелёный — rc 0, KLETKI=52 ZELENYE=52 KRASNYE=0, HISTORICAL_SNAPSHOT 78/4/312 MISMATCHES=0, SNAPSHOT/POLICY стабы ZHIVYH=0 (сырой вывод — раздел «Сырый вывод», прогон 2). Причина: все CLI-клетки строят строки реестра с actor '*' (fixtures/workshop_project/owner_overrides_228/probe.py:312 — `row = [key, …, '*', 'R-0114', 'never']`; frozen-клетка аналогично), пара actor/чужой существует только на API-уровне (клетка wrong-author), где аргумент автора задаёт сама батарея, а не дверь. Источник входа: перенесённые mint-строки батареи несут actor 'orchestrator' (не '*') — измеренные данные, не гипотеза; дверь, не передающая автора, применяет их к коммитам любого автора. Источник ошибочного механизма: замена существующей операции честной модели (передача `$an`) — воспроизведена живьём.
ОБХОД: живой мутант — тот же --model зелёный при заменённой передаче автора. Закрывающее свойство (не единственная реализация): парная клетка уровня CLI — строка реестра с actor ≠ автору коммита → дверь отказывает; actor == автору → допускает (для любой из четырёх дверей, достаточно одной); мутация передачи автора обязана красить эту клетку.

БЛОКИРУЕТ contracts/228-sh3-owner-overrides.md:38 (И1) — критерий не проверяет отказ на нечитаемом источнике.
ОБЯЗАТЕЛЬСТВО: И1 — «Пустой либо отсутствующий файл означает отсутствие исключений; прочая ошибка чтения — отказ, не пустой файл»; И3 — rc 2 «невалидный источник» с OWNER_OVERRIDES_INVALID.
СОСТОЯНИЕ: нечитаемый (chmod 000) registry/owner-overrides.tsv с легитимной строкой grandfather для дельты AGENTS.md; в model/lib_owner.sh обработчик `except OSError: fail(0, 'unreadable file')` заменён на `except OSError: sys.exit(0)` (python-replace по единственному якорю).
НАБЛЮДЕНИЕ: честная модель — check_charter rc 1 с диагностикой OWNER_OVERRIDES_INVALID (fail-closed); мутант — rc 0, допуск уставной дельты (сырой вывод «Сырой вывод», прогон 3: HONEST rc=1 invalid-diag=True / MUTANT rc=0 invalid-diag=False), полный W --model с мутантом зелёный (прогон 4). Ни одна клетка не строит ошибку чтения: RAW-набор покрывает отсутствующий/пустой/битое содержимое, malformed:* — только содержимое. Источник входа: доступное атакующему действие без привилегий — права на файл в собственном worktree перед локальным запуском двери (хук/CI-раннер читает worktree; git хранит только exec-bit, EACCES не синхронизируется и не лечится checkout'ом). Источник ошибочного механизма: замена существующей операции честной модели (обработчик ошибок чтения) — воспроизведена живьём.
ОБХОД: живой мутант — допуск вместо отказа на нечитаемом источнике, батарея молчит. Закрывающее свойство: клетка (API или CLI), подающая нечитаемый файл (например chmod 000) и требующая отказа с OWNER_OVERRIDES_INVALID до применения исключения; мутация обработчика обязана красить эту клетку.

Оба класса закрываются добавлением клеток в зону architect (fixtures/workshop_project/owner_overrides_228/) без изменения инвариантов: И1/И3 остаются как написаны.

## Советы (не блокируют)

- СОВЕТ contracts/228-sh3-owner-overrides.md:8 — КОНТЕКСТ ссылается на «FABLE-RECOMMENDATIONS-1121.md §в/Ш-3/Б-6, PLAN-V9.md §1/4» — этих файлов в дереве репозитория нет (в-repo носители: docs/owner/adr/2026-11-21-plan-fable.md, docs/owner/adr/2026-11-21-plan-v9.md; PLAN-V9 упоминается как fable-audit/out3/PLAN-V9.md — каталог вне репо). Норма (R-0114/R-0102/ADR) подтверждается in-repo источниками, название внешних файлов лучше сопровождать путём или пометкой «вне репо».
- СОВЕТ fixtures/workshop_project/owner_overrides_228/probe.py:29 — SCRATCH жёстко задан 'tmp/scratch-arch228' для любого раннера (critic/reviewer); отчёт --historical пишется в каталог с именем роли архитектора. Косметика гигиены, контракт «отчёт только в scratch» соблюдён.
- СОВЕТ — гонка перезаписи реестра между вызовами owner_override_has внутри одного запуска двери не рассматривается (дверь читает файл многократно: validate + по коммиту). Остаточный риск среды, ловец тот же (замок/CI); в «НЕ ЗАЩИЩАЕТ» можно не выносить, но стоит держать в голове при реализации.

## Карта классов

К-01: чисто — вход: сдаточный лист прогнан (rc 0, двери=12 карта=17/17), все двери формы названы командами с rc; неполноты набора нет
К-02: чисто — вход: R-0114/R-0102 процитированы дословно, ADR in-repo; фактические четыре двери установлены census 237 (сверено живой командой); R-0102 закрыт самим предметом (данные вместо литералов)
К-03: чисто — вход: context.py живьём читает высшие frozen (065/1, 083/3 и др.) и канонический zones_load; precision-gate rc 0 на 97 пересечениях; регрессы 065/083/200/207/210/217/218/992/071 назначены в приёмочном критерии командами
К-04: чисто — вход: зоны architect/implementer/orchestrator раздельны и точны (5 файлов implementer); производственные файлы в OBJECT не менялись (git diff --stat: только контракт и батарея)
К-05: чисто — вход: каждый пункт критерия имеет команду и rc; ручной --historical явно НЕ обязательная дверь с определёнными rc 0/1/2
К-06: чисто — вход: клетка historical-missing-tools запускает настоящий historical.py с PATH=/nonexistent и требует rc 2; таймаут/SIGPIPE записаны как unreproducible с причиной, complete=false не маскируется
К-07: чисто — вход: настоящие Bash API, настоящий git (init/commit-tree/update-ref/annotated tag), четыре живых CLI; baseline-identity сверяет материализованные двери с pinned git show; беглый --repo 46 красных воспроизведён этим судом (3.71 с)
К-08: блок — «критерий не различает передачу автора» (И3, build.py:106/:11, probe.py:312); «критерий не различает отказ на нечитаемом источнике» (И1, model/lib_owner.sh обработчик OSError); оба — живые мутанты, полный --model зелёный
К-09: чисто — вход: 148 строк/586 ответов матрицы, каждая пара ответов снимка (312) проверена jq-сверкой; конформный вход описан, отрицательные грамматики неконформны и отказывают
К-10: чисто — вход: snapshot сверяет rc и хеши обеих труб, покрытие и closed-перечень исключений; наблюдаемый эффект клеток — rc + обе трубы CLI
К-11: чисто — вход: oracle-байты (baseline/refs/log/lock) снимаются до субъекта и хешируются; equality-log и происхождение закоммичены; свидетельство вне проверяемого субъекта
К-12: чисто — вход: JSON Schema Draft 2020-12 через jsonschema, Bash bash -n + pinned shellcheck через validate_std, Python ast, git — plumbing; двойника git нет
К-13: н/п — секретов в предмете нет; check_predposylki: secrets=0 variables=0 environments=0
К-14: блок — тот же класс К-08: честная эквивалентная запись (замена передачи автора литералом, замена обработчика ошибок чтения) остаётся зелёной; ложная зелёность без красной клетки
К-15: чисто — вход: census 237/90/36/10/0, клетки 52+5+9, мутации 35+4+6, связи 43, снимок 78/4/312/complete=false, equality-log 78, «12 файлов РАЗРЕШИЛ» — все сверены живыми командами; расхождений нет
К-16: чисто — вход: КЛАСС РИСКА «рисковый — авторизация/безопасность» соответствует предмету (уставные двери); граница исторического доказательства оценена выше как честная (ловцы + остаточный риск + решение полномочной роли)
К-17: н/п — станционный предмет, продуктовой модели 188 нет (объявлено в контракте)

## Сырой вывод

Прогон 1 (обязательные двери):
```
СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=0)
Wall time: 191.08 seconds
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
  ok   гейт трека:
  ok   модель угроз красна
  ok   потолки красны
  ok   проводка красна
  ok   сдаточный лист красен
КРИТИК: дверь зелёная
Wall time: 206.18 seconds
OK
Wall time: 26.98 seconds
```

Прогон 2 (мутант автора, полный --model; замена build.py:106/:111 `$an` → `orchestrator`):
```
mutated: both author transmissions replaced by literal orchestrator
ZELENO migration-matrix … (52 строки ZELENO, в т.ч. wrong-author, check_zones:allow, check_zones:deny)
KLETKI=52 ZELENYE=52 KRASNYE=0
HISTORICAL_SNAPSHOT complete=false REPRODUCIBLE_SHAS=78 EXCLUDED_SHAS=4 DECISIONS=312 MISMATCHES=0
SNAPSHOT_CELLS=9 SNAPSHOT_STABS=6 ZHIVYH=0
HISTORICAL_POLICY_CELLS=5 KRASNYE=0
rc=0, Wall time: 24.80 seconds
```

Прогон 3 (мутант нечитаемости, адресный сценарий):
```
HONEST unreadable-registry check_charter rc= 1 invalid-diag= True stdout= b''
MUTANT unreadable-registry check_charter rc= 0 invalid-diag= False stdout= b''
```

Прогон 4 (мутант нечитаемости, полный --model): полный вывод ниже, раздел завершён RESTORED; model rc=0.

Прогон 5 (старый литерал поверх реестра — контрольная атака, поймана):
```
old-literal-in-door caught by no-sha-literals: True ['check_zones']
```

Прогон 6 (красное ДО):
```
KLETKI=52 ZELENYE=6 KRASNYE=46 (OWNER_INTERFACE_ABSENT, отсутствие carrier-проверки и переноса)
rc=1, Wall time: 3.71 seconds
```

## Сырой вывод (прогон 4)
mutated: OSError handler -> sys.exit(0)
ZELENO migration-matrix
ZELENO no-sha-literals
ZELENO listed
ZELENO missing
ZELENO empty
ZELENO not-listed
ZELENO prefix-query
ZELENO upper-query
ZELENO long-query
ZELENO wrong-path
ZELENO regex-path
ZELENO wrong-door
ZELENO wrong-author
ZELENO unknown-query
ZELENO expired
ZELENO future
ZELENO prefix-scope
ZELENO prefix-scope-sibling
ZELENO bad-fields
ZELENO bad-nul
ZELENO bad-crlf
ZELENO bad-space
ZELENO bad-uppercase
ZELENO bad-prefix
ZELENO bad-unknown
ZELENO bad-reason
ZELENO bad-expiry
ZELENO bad-path
ZELENO bad-path-trailing
ZELENO bad-path-prefix-empty
ZELENO bad-no-lf
ZELENO bad-duplicate
ZELENO bad-tail
ZELENO bad-blank
ZELENO authority-add
ZELENO authority-add-allowed
ZELENO authority-other-path
ZELENO authority-self
ZELENO delete-denied
ZELENO delete-allowed
ZELENO check_charter:allow
ZELENO check_charter:deny
ZELENO check_zones:allow
ZELENO check_zones:deny
ZELENO check_protected:allow
ZELENO check_protected:deny
ZELENO frozen-allow
ZELENO frozen-deny
ZELENO malformed:check_charter
ZELENO malformed:check_zones
ZELENO malformed:check_protected
ZELENO malformed:check_contract_frozen
KLETKI=52 ZELENYE=52 KRASNYE=0
HISTORICAL_SNAPSHOT complete=false REPRODUCIBLE_SHAS=78 EXCLUDED_SHAS=4 DECISIONS=312 MISMATCHES=0
SNAPSHOT_CELLS=9 SNAPSHOT_STABS=6 ZHIVYH=0
HISTORICAL_POLICY_CELLS=5 KRASNYE=0
HISTORICAL_SNAPSHOT complete=false REPRODUCIBLE_SHAS=78 EXCLUDED_SHAS=4 DECISIONS=312 MISMATCHES=0
RESTORED; model rc=0
Wall time: 34.50 seconds
