# Контракт 175 — табло станции без демонстрационных PR

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — меняется только отображение открытых PR; доступы, деньги, данные людей и политика слияния не меняются.
КОНТЕКСТ: слово владельца 09.11.2026 ~01:50, фаза 1.4: убрать DEMO и «НЕ МЕРЖИТЬ» с табло станции. Шов — запуск `python3 ops/server/user/orch-tablo [минут-окна]`, без новых параметров и записи в реестр.

## Существующее

- `ops/server/user/orch-tablo` (строки 93–114 и 143–150) получает открытые PR `a3ka/dev-harness` и `a3ka/Complior-mob` из `gh pr list --json number,headRefName,statusCheckRollup,updatedAt` и выводит PR с завершённым CI, не различая рабочие и демонстрационные ветки. `ops/server/README.md` (раздел «Табло потоков») документирует команду; `roles/orchestrator.md` запускает табло при пробуждении, `contracts/128-wait-guard.md` судит его формат строк СТОИТ. Не менять формат и потребителя wait-guard.
- Живой запуск `python3 ops/server/user/orch-tablo 20` на исходной голове `24cc7ea9c` дал rc 0, строки `СТОИТ ... PR Complior-mob#150 (demo/kompakt-d24)` и `#149 (demo/investor-d24)`, а также настоящие `#163`, `#162`, `#158`, итог 13. `gh pr view 149/150 -R a3ka/Complior-mob --json title,headRefName,body`: #149 — `DEMO для инвестора ... НЕ МЕРЖИТЬ`; #150 — `DEMO-ONLY ... (НЕ МЕРЖИТЬ)`; обе ветки `demo/*`. Маркер хранится в заголовке PR, сам заголовок прежняя форма строки табло не печатает. Нельзя объявлять удаление литерала в printf решением: надо исключить сами демонстрационные строки.
- Сверены `contracts/`, `registry/plan.tsv`, `scripts/`, `fixtures/`, `ops/server/`, локальные/remote wip refs и открытые PR dev-harness: реализации фильтра демонстрационных PR в дереве/открытом PR не найдено; ближайшие прецеденты — замороженные 074 (путь ops), 128 (форма вывода), 140 (журнал yield), 997 (README), семья `fixtures/workshop_project/model_trace_169/` (red/model/stabs). Строки 175 в `registry/plan.tsv` в исходной голове нет; номер уже выдан `registry/contracts.tsv` — внесение в план вне ЗОНЫ architect, не маскировать зелёной приёмкой.

## Frontier и решение

1. **Фильтр до добавления PR в `prs` — выбран.** Живые #149/#150 попадают в перечень ещё до формирования строк СТОИТ; отсечь их на входе одинаково для двух репозиториев означает, что они не добавят строки, счётчик и занятость потока. Читаются branch и title из одного ответа gh; указатели `demo/`, самостоятельное слово DEMO в title (без захвата DEMOGRAPHIC) и литерал «НЕ МЕРЖИТЬ» — независимые поводы отсечения.
2. Чистить уже собранные строки stdout — отвергнуто: на входе 149/150 строка не содержит заголовка, а `stoit` уже увеличен; вывод и итог расходятся. Это тот же измеренный дефект, не новый функциональный запрос.
3. Закрыть PR #149/#150 или переназвать их — отвергнуто: чужой продуктовый PR и его история вне зоны станции, а следующее демо вернёт дефект.

Единственный результат: демонстрационные PR не считаются рабочими делами станции и не появляются в табло; обычные красные/зелёные PR остаются. Решение ограничено формой списка PR; статусы CI, активность агента, main/теги, потоки, паузы, окно и итоговая грамматика не меняются.

## Инварианты и валидные входы

1. PR-строка, чья ветка начинается `demo/` без учёта регистра, либо чей заголовок содержит отдельное слово `DEMO` без учёта регистра, либо литерал «НЕ МЕРЖИТЬ», не отображается и не прибавляет `стоит без хода`. Все три условия действуют независимо на обоих репозиториях, включая PR с несколькими признаками одновременно; query gh запрашивает `title` рядом с существующими полями. Слова вроде `DEMOGRAPHIC` не являются словом DEMO.
2. Для рабочего PR с завершённым зелёным/красным CI сохраняются существующие точные строки `СТОИТ … PR …: CI зелёный|красный, по нему никто не работает` и счёт, в том числе если в том же списке раньше него идёт demo PR; вывод не печатает `НЕ МЕРЖИТЬ` ни отдельной инструкцией, ни демонстрационной строкой. Незавершённый CI и работающий агент сохраняют прежнюю семантику; эта пачка не переопределяет её.
3. Конформный вход батареи — JSON списка `gh pr list` с `number`, `headRefName`, `title`, `updatedAt`, `statusCheckRollup` и живой CLI программы табло; `git`/журнал предоставлены как неизменённые ответы существующих зависимостей. Оракул (строки случая, независимое ожидаемое наличие PR) живёт в памяти checker до exec субъекта, не выводится из диска кандидата. Валидный контрпример инвариантен к значениям номеров/названий/времени и расходится на конформном gh-ответе; сломанный gh, повреждённый JSON или иной контракт CLI — не контрпример 175. В fixture каждое предъявление сравнивает самостоятельную PR-строку с номером case; просто отсутствие подстроки в другом месте недостаточно.

## Приёмка

- Дано: исходная голова `24cc7ea9c`, PR demo/ и реальные PR станции; когда `python3 ops/server/user/orch-tablo 20`; тогда rc 0, в выводе были `Complior-mob#149` и `#150` — измеренное ДО. Дано: реализация и те же PR остаются открыты; когда `python3 ops/server/user/orch-tablo 20`; тогда rc 0, `#149/#150` не появляются, реальные PR и итоговая строка остаются; при закрытии исходных PR эта живая часть проверяется конформным fixture-входом ниже.
- Дано: код до изменения; когда `bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --repo .`; тогда rc 1, demo-клетки красны собственным предъявлением, рабочие зелёны. Дано: изменённый код; та же команда → rc 0, все клетки `ok`, каждая строка имеет собственное имя; в обоих репозиториях различаются регистр ветки и слова DEMO, независимые маркеры, их сочетание, красный рабочий PR и порядок demo→рабочий в списке PR со сверкой счёта.
- Дано: независимый честный контроль исходного board + выбранный фильтр; когда `bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --model`; тогда rc 0, все клетки `ok`. Дано: обманные кодовые варианты; когда `bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --stabs`; тогда rc 0, каждый `STAB … caught`, ни одного `ZHIV`; ветвь каждого стаба объявлена в коде fixture, а не в контрактной прозе.
- Дано: готовая авторская пачка; когда `bash scripts/check_ceilings.sh`, затем `bash scripts/check_precision_gate.sh . contracts/175-tablo-bez-demo.md`, затем `bash scripts/pre_critic.sh --repo . contracts/175-tablo-bez-demo.md`; тогда каждое rc 0. Перед done `bash scripts/check_provodka.sh . contracts/175-tablo-bez-demo.md` → rc 0; CI-шаг исполнителя ведёт orchestrator.

## Модель угроз

ЗАЩИЩАЕТ:
- От попадания демонстрационного PR на табло через ветку, заголовок или маркер и от потери рабочих PR либо искажения счёта защищает сверка отдельных строк и итога для обоих репозиториев.
НЕ ЗАЩИЩАЕТ:
- От намеренного демо без трёх признаков: владелец размечает демонстрационные PR, ловец — живой просмотр открытых PR; достоверность GitHub API при отказе сети остаётся отдельным предметом.

## Незаполненные требования:
нет

## Зоны и проводка

ЗОНА architect: contracts/175-tablo-bez-demo.md fixtures/workshop_project/tablo_demo_175/
ЗОНА implementer: ops/server/user/orch-tablo ops/server/README.md
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: ops/server/README.md — 074 только предложение о демонстрационных PR; инвентарь и установка 074 не меняются.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/README.md — 081 только предложение о демонстрационных PR; .git/config-операции 081 не меняются.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/README.md — 085 только предложение о демонстрационных PR; семантика цикла 085 не меняется.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/README.md — 093 только предложение о демонстрационных PR; граница исполнения 093 не меняется.
ПЕРЕСЕЧЕНИЕ implementer: ops/server/README.md — 997 только предложение о демонстрационных PR; scope/receipt 997 не меняется.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только шаг 175; чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только строка 175; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только строка 175; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только строка 175; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только строка 175; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только строка 175; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только строка 175; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только строка 175; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только строка 175; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только строка 175; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только строка 175; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только строка 175; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только строка 175; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только строка 175; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только строка 175; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только строка 175; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только строка 175; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только строка 175; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 083 только замер 175; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 175; чужие строки не меняются.
ПРОВОДКА:
- role=roles/orchestrator.md «При каждом пробуждении — после wait, события или сообщения — первым делом запусти `python3 ops/server/user/orch-tablo` (описание — ops/server/README.md) и закрой каждую строку СТОИТ следующим шагом её потока до нового wait; wait — только когда строк СТОИТ нет.»

## Предпосылки

ПРЕДПОСЫЛКИ:
- setting Существующий CI харнесса предоставляет Python 3, bash и git для красной семьи 175; новые secrets, variables и environments не требуются.
- setting Станционный запуск читает открытые PR через gh в существующих репозиториях; доступ gh до и после 175 один и тот же.
