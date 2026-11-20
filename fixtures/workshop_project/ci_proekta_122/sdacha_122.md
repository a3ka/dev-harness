# СДАЧА 122 v6 — повреждённый маркер не равен отсутствию

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-122-v6.md

Предыдущий FAIL: Crit122V6c, OBJECT 2de882ec83367a742b4d0769dc0aef10a7a5a754; материализован на 13610cb0a4, родитель 2de882ec83. Исправительный вход: `/tmp/dev-harness-verify/task-122-architect-v6fix3.md`. Арбитраж `verdicts/arbitration/122-granica-svyazi-predmeta-s-proektom.md` прочитан целиком и не пересматривается. Один класс: распознавание только корректного разделителя превращало повреждённое объявление в отсутствие. Production-скрипты, схема identity, Г1–Г3/v5/205 и остаточная граница не меняются.

После реализации `f284fc8f07ad4e2e0c39a3a58edfe3d654bb78ad` машинные строки дверей описывают реализованное дерево: `--repo .` дал rc 0, 74/74/0 и ROOTS122 TOTAL=43 GREEN=43 RED=0. Поэтому обе repo-двери переведены из honest-red в production с ожидаемым rc 0. Прежние замеры 37/22, ограничения среды и статус реализации в разделах ниже — история предыдущей сдачи, не результаты этого кандидата; контракт и его критерии не меняются.

## Двери

- pre_critic · bash scripts/pre_critic.sh --repo . contracts/122-ci-proekta.md · 0 · 0
- spec_ready · bash scripts/check_spec_ready.sh . contracts/122-ci-proekta.md · 0 · 0
- precision-gate · bash scripts/check_precision_gate.sh . contracts/122-ci-proekta.md · 0 · 0
- provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/122-ci-proekta.md · 0 · 0
- threat-model · bash scripts/check_threat_model.sh . contracts/122-ci-proekta.md · 0 · 0
- батарея model · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model · 0 · 0
- батарея stabs v6 · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --stabs · 0 · 0
- батарея repo production · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --repo . · 0 · 0
- корни model · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r12 · 0 · 0
- корни repo production · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --repo . --cell r12 · 0 · 0
- маркеры model · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r13 · 0 · 0

## Карта классов

- К-01 · чисто · вход: STABS в roots_probe.py исполняет привязки по коду; ожидаемые rc дверей выше подлежат полному прогону оркестратором по ограничению путей ниже · - · -
- К-02 · чисто · вход: Crit122V6c; кандидат маркера определяется до разбора корректного разделителя; r13 воспроизводит обе атаки через настоящий HEAD и обновлённый subject.blob · - · -
- К-03 · чисто · вход: без изменений с Crit122V6c; общий JSON-канон, identity по 054, frozen-обязательства и остаток арбитража сохранены · - · -
- К-04 · чисто · вход: только contracts/122-ci-proekta.md и fixtures/workshop_project/ci_proekta_122/; source.json/osi.md в этой семье отсутствуют, новый параллельный источник чисел не вводится · - · -
- К-05 · чисто · вход: приёмка v6 несёт rc-команды, r12 включает все корневые миры, r13 выбирает только повреждения маркера · - · -
- К-06 · чисто · вход: без изменений с Crit122V6c; gh-error и station-unresolved сохраняют собственные причины, невалидный честный контроль стаба даёт rc 2 · - · -
- К-07 · чисто · вход: прямой roots_probe.py --model дал rc 0, ROOTS122 37/37/0; прежняя полная когорта 74 здесь NOT_RUN, не выдана за новый результат · - · -
- К-08 · чисто · вход: прямой roots_probe.py --stabs дал rc 0, STABS=22 CAUGHT=22; мутанты повреждённого маркера адресованы наблюдаемым входам в коде · - · -
- К-09 · чисто · вход: r13 — отсутствие пробела, лишний пробел/табуляция, регистр, корректная плюс повреждённая декларация; ROOT и внешний корень · - · -
- К-10 · чисто · вход: обе атаки ДО дали субъект rc 0, gh станции, тег и изменённые snapshots; ПОСЛЕ субъект rc 1 project-workflow-rashozhdenie, gh=[], tag_rc=128, unchanged=True · - · -
- К-11 · чисто · вход: HEAD читается настоящим git; снимки обоих деревьев и ожидаемые rc/причины остаются в памяти до вызова субъекта · - · -
- К-12 · чисто · вход: стандартный jsonschema судит объект identity; распознавание литерального маркера не заменяет JSON-валидатор, второй формат/резолвер не вводится · - · -
- К-13 · чисто · вход: без изменений с Crit122V6c; fixture-gh выводит имена/аргументы, не значения секретов; PILOT_DEMO_CODE не копируется · - · -
- К-14 · чисто · вход: mono/mono-explicit без объявления, mono-declared/mono-declared-explicit с корректным объявлением и project-secret остались зелёными в прямом модельном прогоне · - · -
- К-15 · чисто · вход: AST независимо от раннера дал CASES=27 R13=10 TOTAL=37 STABS=22; итоги раннера TOTAL=37 и STABS=22; исторические числа помечены ниже · - · -
- К-16 · чисто · вход: класс риска, поставщик/гонка и остаточная граница не изменены; check_threat_model rc 0, 11/8 буллетов · - · -
- К-17 · н/п · механизм харнесса, продуктовый бриф архитектуры 188 не заявлен · - · -

## Дельта

- К-02 · канон/инструмент · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r13 · 0 · 0
- К-07 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r12 · 0 · 0
- К-08 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --stabs · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r13 · 0 · 0
- К-10 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r13 · 0 · 0
- К-11 · канон/инструмент · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell r13 · 0 · 0
- К-16 · канон/инструмент · bash scripts/check_threat_model.sh . contracts/122-ci-proekta.md · 0 · 0

## Доказательства узкого ремонта

До правки модели добавленная r13-когорта из 9 миров дала сырой rc 1, TOTAL=9 GREEN=4 RED=5. Первые две клетки — точные атаки критика: фабрика mono-declared-explicit либо station-explicit; в HEAD удалён пробел после двоеточия, сделан настоящий коммит, subject.blob обновлён. Обе дали субъект rc 0, gh secret list -R origin станции, tag_rc=0, unchanged=False. Негативы не засчитываются по первой красной точке: каждая клетка отдельно судит rc, причину, журнал gh и snapshots. Внешний корень проверяется отдельно, хотя прежняя модель уже отказывала ему из-за отсутствия распознанной декларации.

Ремонт: кандидаты строки находятся по началу имени маркера без учёта регистра ДО проверки точного разделителя; единственность считается по всем кандидатам. Затем проверяется каноническое начало с одним ASCII-пробелом и JSON-объектом, объект судит прежняя схема. Ни одного кандидата — прежний путь допустимого отсутствия. Снятие обещания и граница отвергнуты, поскольку арбитраж требует отказа; JSON Schema не различает отсутствие строки и повреждённый маркер, поэтому для этого текстового предиката нужна клетка, а не новый JSON-парсер.

Мутация удаления поиска повреждений возвращает прежнее распознавание startswith корректного префикса; оба точных контрпримера становятся адресными стабами. Соседние повреждения — регистр и смешанный повтор при обоих корнях. Предикат точного разделителя различают также лишний пробел и табуляция при собственной корректной identity станции, чтобы отказ не объяснялся несовпадением внешней identity. Честные парные эквиваленты — mono-declared-explicit, mono-declared, project-secret; отсутствие объявления — mono/mono-explicit. Привязки предъявлений живут только в STABS по Н-39.

Прямой `python3 fixtures/workshop_project/ci_proekta_122/roots_probe.py --model` после ремонта → сырой rc 0, ROOTS122 TOTAL=37 GREEN=37 RED=0. `--stabs` → rc 0, STABS=22 CAUGHT=22. `--repo .` → rc 1, honest-red, TOTAL=37 GREEN=4 RED=33; правильная причина повреждённого объявления пока отсутствует в production. На обеих точных атаках исправленная модель даёт subject_rc=1, gh=[], tag_rc=128, unchanged=True. Отдельная финальная прямая r13-команда указана в докладе.

AST-подсчёт словарей, независимо от исполнения: CASES=27, MARKER_CASES=10, их union=37, STABS=22; все значения STABS входят в union. Источник чисел — код, не новый source.json/osi.md.

## Сырые двери и ограничение среды

Все исполненные команды используют TMPDIR=<pwd>/tmp и PYTHONDONTWRITEBYTECODE=1; вне изолированной копии записей не делалось. `check_threat_model` → сырой rc 0 (11/8), `check_provodka --grammar` → rc 0. `SDACHA_OKRUG=1 bash scripts/pre_critic.sh --repo . contracts/122-ci-proekta.md` → rc 0: это только scoped-проверка формы БЕЗ ноги check_sdacha, не полный pre_critic.

Полные `pre_critic`, `check_sdacha --run` и shell-батареи `red_ci_proekta_122.sh --model`, `--stabs`, `--repo .`, `--cell r12/r13` — NOT_RUN в этой копии. Причина установлена по коду: shell-батарея создаёт WORLDS=/tmp/dev-harness-verify/ci122 ДО диспетчеризации даже r12/r13/stabs; model/ci_preflight.sh также явно выбирает /tmp/dev-harness-verify. TMPDIR эти записи не перенаправляет, а задание запрещает любые записи вне pwd. Полные двери листа вызывают эти команды. Это предусмотренная заданием передача прогонов оркестратору в чистом клоне, не зелёная проверка и не основание вызвать критика. Таблицы выше несут ОЖИДАЕМЫЕ rc для этого прогона; фактические текущие результаты перечислены отдельно здесь. Production/временную инфраструктуру ради обхода ограничения не меняли.

## Исторические замеры (не нынешний прогон)

На 2de882ec83 предыдущая пачка сообщала model 74/74/0 и ROOTS122 27/27/0, stabs 18/18, repo 74/54/20 и ROOTS122 27/4/23; pre_critic и check_sdacha rc 0, двери=10 карта=17/17 дельта=5. Crit122V6c повторил check_sdacha rc 0 и нашёл нынешний дефект. На более раннем 87986725f1 были ROOTS122 19/19/0 и stabs 14/14. Эти результаты не присваиваются новому кандидату.

## Граница и развилки

Только контракт, исполняемая модель, батарея и лист; корни писателя/инвентаря, штатные резолверы, JSON Schema, прежняя когорта Г1–Г3/v5/205, риск поставщика/гонки и арбитражная таблица не меняются. Живые gh/GitHub/продукт/CI — NOT_RUN. Реализация production-ноги — implementer после штатного суда/заморозки. Новых дверей сверх блока нет: r13 — селектор уже существующей батареи. Общий журнал NABLIUDENIA_ARCHITECT вне зоны; запись в нём не делается. Наблюдение для передачи оркестратору: hardcoded scratch батареи мешает полному прогону в изолированной копии; временную инфраструктуру не расширяем этим предметом.
