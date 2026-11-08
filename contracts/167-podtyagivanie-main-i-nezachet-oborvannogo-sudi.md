# Контракт 167 — безопасное подтягивание main и незачёт оборванного судьи

КОНТЕКСТ: решение владельца 2026-11-07 ~12:05 UTC «по беку согласен. сейчас а, и реализовать б, чтобы мы могли вливать в таких случаях обрыва сессий готовую работу». Пункт (а), разовое подтягивание PR #628/#632, уже исполнен консультантом от имени владельца. Здесь — штатный путь для следующего такого случая. КЛАСС ЗАДАЧИ: смешанный (норма + механизм). КЛАСС РИСКА: обычный — не меняются доступ, авторизация, деньги, ПД/health или юридически значимое действие; судейский учёт и PR-история защищены самостоятельными отрицательными клетками.

## Существующее

- Арбитраж `verdicts/arbitration/merge-wip-protiv-main-konflikt-norm.md` отверг неограниченный merge main→wip: первым родителем идёт wip; выборочное разрешение «только конфликтующие файлы» откатывает чужую main-дельту. Разрешённая здесь форма — ПОЛНОЕ слияние, не выборочный cherry-pick дерева. Н-191/Н-281/Н-286 — действительный источник запрета; ярлык «Н-213» в Н-294 неточен: собственная Н-213 в `NABLIUDENIA.md` описывает сломанный инкрементальный кеш CI. Н-294 — измеренный повтор merge, Н-62 — запись урока без механизма. Владелец изменил норму только для узкого случая 167.
- `.githooks/pre-push:188–239,323–337` запрещает main вторым родителем обычной PR-ветки; `scripts/check_charter.sh:46–51` судит merge по первому родителю; `scripts/land_agent.sh` защищает авторство И-9, frozen ancestry И-3 и честный ленд, но не готовит конфликтную PR-ветку и не доказывает отсутствие пересечения её дельты с main. `roles/orchestrator.md` ведёт git-обмен через `scripts/gitw`, а не raw push. Новая проверка допуска строится в существующем pre-push, не во второй двери обхода.
- `scripts/zamok_predmeta.sh:219–240,437–468,557–596` уже хранит START/RELEASE, проверяет журнал yield и привязывает D11 к роли и OBJECT. Сейчас D11 считает любой START, в том числе оборванный без вердикта, и смотрит в журнал, а не в commit вердикта; после явного RELEASE D11 вовсе не исполняется (стоит внутри проверки существующего `zanyat`). `fixtures/workshop_project/odin_agent_140/` даёт стабильную модель 140 и тот же публичный CLI `--sudit`/`--osvobodit`; исправление уточняет её D11 без переписывания соседних клеток 140. Н-315 предостерегает от подмены модели/роли после отказа вместо диагностики, а не является основанием расширить этот контракт.
- `registry/contracts.tsv` уже раздаёт 167; `registry/plan.tsv` несёт 140 и старые зависимости; в дереве нет другого предмета для восстановления оборванного судьи 167. Незавершённые wip/PR 161/143/158/165/166 не служат эталоном исхода суда: существование сессии или текста scratch не равно коммиту вердикта. Норма 165 материализует только завершённый суд — здесь же речь об отсутствии завершённого суда, поэтому 165 не заменяет D11. PR #628/#632 — фактический повод, а не тестовые фикстуры.

## Предмет и граница

1. Роль `roles/orchestrator.md` устанавливает правило: ведущая сессия проекта сама делает **полный** `merge --no-ff` актуального origin/main в ветку PR (wip — первый родитель, main — второй) своей identity без force, только если изменения main с момента merge-base НЕ пересекаются по путям с изменениями ветки либо единственное пересечение/конфликт — `registry/contracts.tsv` и итог содержит объединение строк обеих сторон с однозначными ключами и без потери/перезаписи строки. Любые остальные пересечения, неполный merge, иная ветка или неопределённость — отказ; другие merge main→wip остаются запрещены. После нового head необходимы CI именно для этого head и заново судьи по новому OBJECT; старый accept не переносится. Механическая часть — исключение `.githooks/pre-push` с пересчётом merge-base, путей обеих дельт, дерева результата и буквального объединения строк; только для именованной wip PR-ветки и только при второй родительской вершине живого origin/main (прошлый локальный main не авторитетен). `scripts/check_charter` сохраняет независимый суд уставных путей: 167 не даёт права повторно вписывать owner-санкции. Семантика «CI зелёный именно на новом head и суд нового OBJECT» — cognitive-only до существующих CI/судейских дверей; остаточный риск ручного пропуска порядка ловит reviewer сверкой SHA PR/CI/вердикта.
Грамматика строки объединяемого `registry/contracts.tsv` из живого реестра: `^[0-9]{3} → [0-9a-f]{40}$`; ключ — первые три цифры, совпавшие ключи с разными значениями отказывают, строки в результате сохраняются побайтово.
2. Судья START без **закоммиченного** вердикта данной роли/сессии/OBJECT по завершении сессии не тратит круг D11. При явном `--osvobodit` после завершения либо брошенного holder учёт пишет RELEASE с причиной `obryv_bez_verdikta`, если доказано отсутствие коммита вердикта; при доказанном коммите `accept` или `FAIL` — `verdikt_zakommiten`. D11 судит и после освобождения замка; учитывает START той же роли и OBJECT как состоявшийся круг, пока не найден его собственный RELEASE `obryv_bez_verdikta`. Один такой release даёт ровно один повтор; новый START повторного судьи снова учитывается, и второй повтор без его собственного нового release запрещён. Судья, только вызвавший yield, но не закоммиченный, остаётся оборванным. Нельзя выводить отсутствие коммита из отсутствия файла в одном worktree: локальные и опубликованные судейские refs должны быть синхронизированы до классификации; недоступность ref/проверки вердикта = отказ `NOT_IMPLEMENTED`, а не разрешение. Истинность verdict доказывается Git-коммитом в refs судейской ветки и blob: первая строка `accept`/`FAIL`, точная самостоятельная строка `OBJECT=<sha>`, литеральные поля `роль=<роль>;` и `сессия=<holder>;` в строке `СУД:` (как в существующем `verdicts/critic/contracts-161-v3.md:1–3`), author коммита совпадает с ролью; одной подложной строки в ledger/журнале/рабочем файле недостаточно. Исходный замок и блок живого судьи (`SUDJA_ZHIV`) сохраняются; `--osvobodit` живого по-прежнему отказывает. Для уже завершённого judge с commit, даже когда замок снят, повтор отказывает `OBJECT_UZHE_SUZHEN`.

## Приёмочный критерий

`W=bash fixtures/workshop_project/obryv_167/red_obryv_167.sh`; входы — локальный toy Git с изолированным `file://` origin и отдельные корни state/журналов. Конформны START по грамматике 140, release по CLI, законченная судейская сессия, доступный Git-commit кандидата на вердикт (в том числе с отклонением ровно в одном гейте аутентичности) и двухродительский merge с актуальным origin/main на разрешённом или ином refs/heads/*. Контрпример валиден при инвариантности к именам сессии и значениям OBJECT/ключей реестра и расхождении на таком конформном входе; не любой JSON с `VERDICT`, не частичный merge и не устаревшая локальная main.

- Дано: текущие двери без 167. Когда `W --repo`; тогда rc 1: `CASE interrupted KRASNO` (RELEASE `yield` вместо `obryv_bez_verdikta`) и `MERGE separate KRASNO`/`MERGE registry KRASNO` с причиной «merge main в ветку запрещён». Дано: честная контрольная модель на независимом эталоне 140 и настоящем pre-push с узким разрешением; когда `W --model`; тогда rc 0, исходы `CASE interrupted/verdict/verdict_no_receipt/reviewer_verdict/remote_unavailable/verdict_wrong_author/verdict_wrong_path/verdict_wrong_object/verdict_wrong_session ok`, `MERGE separate/registry/overlap/registry_drop/partial/other_ref ok`.
- Дано: сессия yield без commit и вызван явный release; когда `W --repo` после реализации; тогда rc 0, `RELEASE.prichina=obryv_bez_verdikta`, один новый START на том же OBJECT проходит, следующий без нового собственного release получает rc 1 `OBJECT_UZHE_SUZHEN`. Дано: закоммиченный FAIL с совпадающими ролью, сессией и OBJECT; когда тот же CLI и явный release; тогда `RELEASE.prichina=verdikt_zakommiten`, повтор rc 1 `OBJECT_UZHE_SUZHEN`. Дано: commit есть, release ещё не сделан; когда повтор; тогда rc 1 `OBJECT_UZHE_SUZHEN`. Дано: сессия ещё жива; когда release; тогда rc 1 `ZAMOK_ZHIV` (старый инвариант 140).
- Дано: законченная сессия и commit с вердиктом `FAIL`, точным полем роли и остальными совпадающими гейтами, но отклонением ровно в одном: `%an` коммита — не роль, путь вне `verdicts/<роль>/contracts-<N>-v*`, строка `OBJECT=` содержит другой sha, либо поле `сессия=` содержит другого holder. Когда `W --repo` после реализации; тогда для каждой самостоятельной клетки `CASE verdict_wrong_author/path/object/session ok`, RELEASE имеет `prichina=obryv_bez_verdikta` и повтор того же OBJECT проходит rc 0. Удаление соответствующего гейта на каждой из этих клеток даёт `STAB ... caught` при `W --stabs`, а не ложное сжигание круга.
- Дано: remote судейских refs недоступен при явном освобождении судьи; когда `W --repo` после реализации; тогда rc 2 `NOT_IMPLEMENTED: judge refs недоступны`, RELEASE не записан, замок не снят. Дано: refs доступны; когда тот же вход с завершённым судьёй без вердикта; тогда rc 0 и сохранена предыдущая пара.
- Дано: раздельные path-дельты PR/main и полный merge; когда `W --repo` после реализации; тогда `MERGE separate ok`, rc 0. Дано: конфликт только в registry и объединены все строки; когда тот же вход; тогда `MERGE registry ok`, rc 0. Дано: общий путь вне реестра; когда `MERGE overlap`; тогда rc 1 «merge main в ветку запрещён». При реестровом merge с потерянной строкой и при выборочном присоединении main без её файлов — тот же отказ. Дано: такой же полный конформный merge с раздельными дельтами, но пуш в `refs/heads/feature/other-branch`; когда `W --repo` после реализации; тогда `MERGE other_ref ok` (отказ pre-push rc 1 «merge main в ветку запрещён»), а `W --stabs` ловит подмену без ref-условия. CI на новом head и суд новом OBJECT проверяются существующими gitw/CI и замком: до done предъявляется живой PR с соответствующими SHA; их отсутствие блокирует done, fixture не выдаёт ложную зелень происхождения CI.
- Дано: контроль и обманные реализации. Когда `W --stabs`; тогда rc 0 и независимые диагностические строки `STAB ... caught` на каждом различающем входе, без `STAB_ZHIV`. Когда `bash scripts/pre_critic.sh --repo . contracts/167-podtyagivanie-main-i-nezachet-oborvannogo-sudi.md`; тогда rc 0 до суда. До done `bash scripts/check_provodka.sh . contracts/167-podtyagivanie-main-i-nezachet-oborvannogo-sudi.md` и (при наличии project-source) `check_project_sources.sh --stage done` обязаны вернуть rc 0.

## Зоны и проводка

ЗОНА architect: contracts/167-podtyagivanie-main-i-nezachet-oborvannogo-sudi.md fixtures/workshop_project/obryv_167/
ЗОНА implementer: scripts/zamok_predmeta.sh .githooks/pre-push roles/orchestrator.md .omp/agents/orchestrator.md fixtures/workshop_project/odin_agent_140/probe.py
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: scripts/zamok_predmeta.sh — 140 только D11 и причина судейского RELEASE; остальные клетки без изменений.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/workshop_project/odin_agent_140/probe.py — 140 только s06: создать настоящий закоммиченный verdict для прежнего отрицательного инварианта D11; b05: release судьи с причиной obryv_bez_verdikta вместо унаследованной yield; остальные клетки и источник модели сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: .githooks/pre-push — 022 только узкое исключение verdict merge main в PR; общее кольцо charter и не-PR refs без изменений.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 002 только вывод изменённого текста roles/orchestrator.md генератором `npm run gen:harness`; прочее без изменений.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 003 только вывод изменённого текста roles/orchestrator.md генератором `npm run gen:harness`; прочее без изменений.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 005 только вывод изменённого текста roles/orchestrator.md генератором `npm run gen:harness`; прочее без изменений.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 010 только вывод изменённого текста roles/orchestrator.md генератором `npm run gen:harness`; прочее без изменений.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 050 только вывод изменённого текста roles/orchestrator.md генератором `npm run gen:harness`; прочее без изменений.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 061 только вывод изменённого текста roles/orchestrator.md генератором `npm run gen:harness`; прочее без изменений.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 068 только вывод изменённого текста roles/orchestrator.md генератором `npm run gen:harness`; прочее без изменений.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 069 только вывод изменённого текста roles/orchestrator.md генератором `npm run gen:harness`; прочее без изменений.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 140 только норма судьи и PR-синхронизации; чужие нормы неизменны.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 010 добавляется только норма 167; топология ролей сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 012 добавляется только норма 167; прежние нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 026 добавляется только норма 167; прежние нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 027 добавляется только норма 167; прежние нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 028 добавляется только норма 167; прежние нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 029 добавляется только норма 167; прежние нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 031 добавляется только норма 167; прежние нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 037 добавляется только норма 167; прежние нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 038 добавляется только норма 167; прежние нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 050 добавляется только норма 167; прежние нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 061 добавляется только норма 167; прежние нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 068 добавляется только норма 167; прежние нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 069 добавляется только норма 167; прежние нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 072 добавляется только норма 167; прежние нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 074 добавляется только норма 167; прежние нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 094 добавляется только норма 167; прежние нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 095 добавляется только норма 167; прежние нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 099 добавляется только норма 167; прежние нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 100 добавляется только норма 167; прежние нормы сохраняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 104 добавляется только норма 167; прежние нормы сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только шаг 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только шаг батареи 167; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только строка 167; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только строка 167; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только строка 167; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только строка 167; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только строка 167; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только строка 167; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только строка 167; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только строка 167; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только строка 167; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только строка 167; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только строка 167; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только строка 167; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только строка 167; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только строка 167; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только строка 167; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только строка 167; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только строка 167; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 167; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 083 только строка 167; чужие строки не меняются.
ПРЕДПОСЫЛКИ:
- setting Нынешняя `.github/workflows/ci.yml` имеет Python 3, git, jq, bash и возможность одного scoped шага 167; новых secrets/variables/environments нет.
- setting Судейские refs доступны в локальной Git-базе до классификации verdict или дверь именованно отказывает, без догадки об их отсутствии по одному worktree.

ПРОВОДКА:
- role=roles/orchestrator.md «Merge main в ветку PR: ведущая сессия проекта сама делает полный `merge --no-ff` актуального origin/main в ветку PR (wip — первый родитель, main — второй) своей identity, без force, только если изменения main с момента merge-base НЕ пересекаются по путям с изменениями ветки либо единственное пересечение/конфликт — `registry/contracts.tsv` и итог содержит объединение строк обеих сторон с однозначными ключами и без потери/перезаписи строки; любые другие пересечения, неполный merge, иная ветка или неопределённость — отказ, остальные merge main→wip запрещены; после нового head обязательны CI именно для этого head и заново судьи по новому OBJECT — старый accept не переносится; механическая часть — узкое исключение в `.githooks/pre-push` по живым refs origin, уставные пути судит независимое кольцо `scripts/check_charter.sh`.»
- role=roles/orchestrator.md «Судья без закоммиченного вердикта: завершивший сессию без коммита вердикта (роль/сессия/OBJECT) освобождается явным `--osvobodit`, дверь пишет причину `obryv_bez_verdikta` — круг D11 не тратится и повторный круг судьи на том же OBJECT допустим ровно один раз; при доказанном коммите вердикта (`accept`/`FAIL`) причина `verdikt_zakommiten` — круг тратится, повтор отказ; недоступность судейских refs — отказ `NOT_IMPLEMENTED`, а не разрешение повтора.»
- guard=.githooks/pre-push
- guard=scripts/zamok_predmeta.sh

## Модель угроз

ЗАЩИЩАЕТ:
- Дубликат оплаченного суда по той же роли/OBJECT и исключение только подтверждённо оборванной попытки; произвольный START без release не создаёт бесплатных попыток.
- Merge, который игнорирует чужой путь main или теряет строку реестра; проверка считает полный результат, не только отсутствие текстовых conflict markers.
НЕ ЗАЩИЩАЕТ:
- Прямой обход Git pre-push `--no-verify` и неподлинность Git author при общем uid: ловцы CI и reviewer.
- Авторитетность ещё не синхронизированных удалённых judge refs: отсутствие доступа означает `NOT_IMPLEMENTED` и остановку, не разрешение повтора.

## Незаполненные требования:
нет
