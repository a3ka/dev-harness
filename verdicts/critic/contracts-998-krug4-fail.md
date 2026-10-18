FAIL
OBJECT=c5e14654e8f21e37ccc12c33c1aafef5d9d1baac

# Критик 998 — один разрешённый микро-круг

Итог: оба ТОЧНЫХ обхода круга 3 теперь красные; регресс К1–К3 зелёный в требуемом смысле (честный кандидат проходит, прежние обманные кандидаты отвергаются). Однако обобщённое закрытие индекса неполно: потеря `rules[N]` в отказе о файле роли при живой ссылке routing проходит ВСЕ команды приёмки. Это тот же класс К1.23 на входе К1.24, не новое требование. `named_reject` не отрезан и реально работает; дырка локальна — файловая клетка передаёт ему `idx=None`.

По мандату `forks/n998-krug3-kap.md` и заданию: **998 отложить до утра; очередной круг не открывать**. План/контракт/проба предмета не правились. Вердикт не коммитился и не пушился; файл предназначен для коммита оркестратором.

## Предмет и допуск

Клон получен с GitHub, а не из основного чекаута:

```sh
git clone ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/critic998r4/clone
git fetch origin wip/998/architect
git checkout --detach c5e14654e8f21e37ccc12c33c1aafef5d9d1baac
git rev-parse HEAD
```

Последняя команда, rc=0, сырой вывод:

```text
c5e14654e8f21e37ccc12c33c1aafef5d9d1baac
```

Первая проверка, из корня клона:

```sh
bash scripts/pre_critic.sh contracts/998-pravila-modelei.md
```

rc=0, сырой вывод:

```text
КРИТИК: дверь зелёная
```

Прочитаны `roles/critic.md`, `AGENTS.md`, контракт и изменённые клетки с OBJECT. Вердикт круга 3 отсутствует в дереве этой ветки; он, арбитраж и мандат прочитаны именно из `origin/main`:

```sh
git show origin/main:verdicts/arbitration/contracts-998-perechen-vetvej-v1.md
git show origin/main:verdicts/critic/contracts-998-krug3-fail.md
git show origin/main:forks/n998-krug3-kap.md
```

Предмет, критерий с исполняемыми командами, исполнители, зоны и модель угроз присутствуют. Суд ограничен К1.23/К1.24 и регрессом К1–К3. Новых требований к классам, форматированию, режимам генератора или реализации не добавлено.

Одиночный precision-гейт (не параллельно другому pre_critic/precision):

```sh
env TMPDIR=/tmp/dev-harness-verify/critic998r4 bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/critic998r4/clone contracts/998-pravila-modelei.md
```

rc=0, сырой вывод:

```text
OK
```

## Блокирующая находка: индекс убран из файлового отказа, весь критерий выполнен

БЛОКИРУЕТ contracts/998-pravila-modelei.md:200–204 — критерий исключил файловую клетку из требования индекса, хотя вход К1.24 имеет конкретную ссылку `routing.rules[3]`; обещание именования при удалении роли, на которую ссылается routing, сохранено на :249–251, а закрытый перечень К1 арбитража требует routing / rules[N] / нарушителя. В `fixtures/pravila_modelei_998/probe.py:741–742` файловая клетка вызывает `named_reject(..., None, require_routing=False)`. Поэтому это не обобщённое закрытие К1.23. Для того же входа честной модели матричная клетка на :1153–1155 требует `FIRST_GLM_REF`; для проверяемого генератора — нет.
ОБХОД: взять кандидат с именованной файловой проверкой `routing.rules[${i}]: роли «${role}» нет файла roles/${role}.md` перед общим table→file, затем изменить ТОЛЬКО эту диагностическую строку на `routing: роли «${role}» нет файла roles/${role}.md`. Файловый отказ сохраняется в обеих точках, все грамматические отказы и рендер неизменны, но `rules[3]` потерян. Полученный `file_index_gap/` проходит --cases 46/0, lane с матрицей 57/0, check:gen, gen_ci_steps --check, check_provodka и scoped check_provodka. На входе «удалён только roles/implementer-glm.md; таблица и ссылки живы» он возвращает rc=1 без индекса в обеих точках. Предъявленный критерий не различает это нарушение принятого К1.

Это не требование индекса у общего table→file без ссылок: для `gen_reject_unreferenced_role_file` индекс действительно неприменим. Нарушение относится только к роли, на которую ССЫЛАЕТСЯ routing. Не требую конкретной архитектуры двух циклов: полная именованная проверка допустима и одним проходом.

### Воспроизводимость и положительный контроль

```sh
python3 /tmp/dev-harness-verify/critic998r4/prepare.py
python3 /tmp/dev-harness-verify/critic998r4/file_index_controls.py
```

`prepare.py` перенёс прочитанный построитель круга 3, заменив единственный корень на МОЙ SSH-клон OBJECT; построитель создал disposable `candidate/` и живым генератором создал производные. Он не изменяет клон предмета. Сырой вывод построения, rc=0:

```text
PATCHED
modelRoles/fallbackChains: .omp/config.yml перегенерирован из config/agent_models.json
сгенерировано: 10 ролей, обновлено файлов: 3
DERIVATIVES OK
BUILD_RC=0
```

`file_index_controls.py` сначала создаёт `file_index_honest/`: файловая проверка routing именует индекс и предшествует общей table→file (иначе более ранний общий отказ маскирует её). Затем `file_index_gap/` отличается от этого контроля ОДНОЙ строкой диагностики. Проба и `named_reject` в обоих деревьях остаются байтами OBJECT; они не исправляются и не отключаются. В отдельной копии каждого дерева удаляется только исходный файл роли — таблица, обе ссылки и производный агент сохранены.

Сырые строки вывода сценария, его rc=0:

```text
file_index_honest_cases rc=0
census cases: исполнено 46, расхождений 0
file_index_gap_cases rc=0
census cases: исполнено 46, расхождений 0
file_index_gap_lane rc=0
census cases: исполнено 46, расхождений 0
census matrix: исполнено 57, расхождений 0
file_index_gap_gen rc=0
харнес соответствует roles/ (10 ролей)
file_index_gap_ci rc=0

file_index_gap_provodka rc=0

file_index_gap_scoped rc=0
SCOPED: барьеров 1 из выборки — не для приёмки
```

Итог scoped-прогона (между строками выше и ниже в полном логе — вывод 28 фикстур):

```text
барьеров: 1 · фикстур: 28 · предъявлено красным повторным прогоном: 28
good table=task-glm refs=[3, 4]
good_file_witness_check rc=1
FAIL routing.rules[3]: роли «implementer-glm» нет файла roles/implementer-glm.md
good_file_witness_prompt rc=1
FAIL routing.rules[3]: роли «implementer-glm» нет файла roles/implementer-glm.md
bad table=task-glm refs=[3, 4]
bad_file_witness_check rc=1
FAIL routing: роли «implementer-glm» нет файла roles/implementer-glm.md
bad_file_witness_prompt rc=1
FAIL routing: роли «implementer-glm» нет файла roles/implementer-glm.md
```

Сама клетка на обманном кандидате печатает:

```text
CASE cases gen_reject_missing_role_file: ok — роль в таблице без файла roles/implementer-glm.md отвергнута в обеих точках (роль и файл названы; таблица и ссылки routing живы)
```

Реально исполненные команды внутри `file_index_gap/`:

```sh
bash fixtures/pravila_modelei_998/probe.sh --cases
bash scripts/run_ci_lane.sh check:pravila-modelei-998
npm run --silent check:gen
bash scripts/gen_ci_steps.sh --check
bash scripts/check_provodka.sh /tmp/dev-harness-verify/critic998r4/file_index_gap contracts/998-pravila-modelei.md
npm run --silent check:antiplacebo -- --scope check_provodka
```

На отдельных свидетелях `file_index_witness_good/` и `file_index_witness_bad/`:

```sh
node scripts/gen-harness.ts --check
node scripts/gen-harness.ts --prompt orchestrator
```

Полные команды, cwd, rc и сырой stdout/stderr — `file_index_logs/*.log`. Зелёную полную приёмку на дереве ПОСЛЕ удаления роли не заявляю: это отрицательный вход-свидетель, обе точки на нём должны отказывать именованно.

## Точные обходы круга 3 закрыты; индексный оракул не вакуумный

```sh
python3 /tmp/dev-harness-verify/critic998r4/k1_controls.py
```

Сценарий проверяет кандидатов НЕ их собственной пробой, а неизменённой пробой SSH-клона:

```sh
PROBE_SUBJECT_ROOT=<кандидат> bash /tmp/dev-harness-verify/critic998r4/clone/fixtures/pravila_modelei_998/probe.sh --cases
```

Сырой вывод для прежних двух обходов:

```text
missing_role_file_gap rc=1
census cases: исполнено 46, расхождений 2
КРАСНО: gen_reject_missing_role_file, gen_reject_unreferenced_role_file
tier_index_gap rc=1
census cases: исполнено 46, расхождений 1
КРАСНО: gen_reject_bogus_tier
```

Диагностика клеток:

```text
CASE cases gen_reject_missing_role_file: РАСХОЖДЕНИЕ — --check: нарушитель «roles/implementer-glm.md» не назван; --prompt rc=0 (ожидается 1)
CASE cases gen_reject_unreferenced_role_file: РАСХОЖДЕНИЕ — --check: нарушитель «roles/implementer.md» не назван; --prompt rc=0 (ожидается 1)
CASE cases gen_reject_bogus_tier: РАСХОЖДЕНИЕ — --check: индекс rules[10] не назван; --prompt: индекс rules[10] не назван
```

Затем по одной удалены индексы из ВСЕХ девяти диагностических throw-ветвей routing построителя; это покрывает все индексируемые грамматические строки ROUTING_BRANCHES, включая ветви, использующие общий throw. Каждый вариант отвергнут:

```text
index_gap_0 rc=1
census cases: исполнено 46, расхождений 1
КРАСНО: gen_reject_rule_not_object
index_gap_1 rc=1
census cases: исполнено 46, расхождений 1
КРАСНО: gen_reject_unknown_rule_key
index_gap_2 rc=1
census cases: исполнено 46, расхождений 3
КРАСНО: gen_reject_class_number, gen_reject_class_blank, gen_reject_class_missing
index_gap_3 rc=1
census cases: исполнено 46, расхождений 2
КРАСНО: gen_reject_constraint_number, gen_reject_until_type
index_gap_4 rc=1
census cases: исполнено 46, расхождений 2
КРАСНО: gen_reject_target_conflict, gen_reject_rule_no_target
index_gap_5 rc=1
census cases: исполнено 46, расхождений 2
КРАСНО: gen_reject_target_number, gen_reject_role_blank
index_gap_6 rc=1
census cases: исполнено 46, расхождений 2
КРАСНО: gen_reject_bogus_role, gen_reject_missing_role
index_gap_7 rc=1
census cases: исполнено 46, расхождений 2
КРАСНО: gen_reject_tier_number, gen_reject_tier_blank
index_gap_8 rc=1
census cases: исполнено 46, расхождений 1
КРАСНО: gen_reject_bogus_tier
```

Дополнительно заменены только тексты шаблонных routing-исключений на `REJECT`, сохраняя rc=1. Это контроль, что зелёный кандидат не получен удалением `named_reject` или недостижимостью его вызова:

```text
unnamed_reject rc=1
census cases: исполнено 46, расхождений 19
КРАСНО: gen_reject_unknown_routing_key, gen_reject_rule_not_object, gen_reject_unknown_rule_key, gen_reject_class_number, gen_reject_class_blank, gen_reject_class_missing, gen_reject_target_number, gen_reject_role_blank, gen_reject_tier_number, gen_reject_tier_blank, gen_reject_constraint_number, gen_reject_until_type, gen_reject_target_conflict, gen_reject_rule_no_target, gen_reject_conditional_number, gen_reject_emergency_object, gen_reject_bogus_role, gen_reject_bogus_tier, gen_reject_missing_role
```

Сценарий завершился rc=0; перечисленные rc=1 относятся к исполняемым пробам. Полный сырой вывод — `k1_logs/*.log`; итоговые коды — `k1_results.json`.

## Файловые ветви по одной — замечание, не дополнительное основание FAIL

СОВЕТ contracts/998-pravila-modelei.md:252–257 — буквальное обещание «снос любой из проверок поодиночке красен» не выполняется на положительном построителе с общим table→file перед routing→file. Изолированная потеря общего цикла красна, потеря одного routing-цикла зелена:

```text
general_file_only_gap rc=1
census cases: исполнено 46, расхождений 1
КРАСНО: gen_reject_unreferenced_role_file
routing_file_only_gap rc=0
census cases: исполнено 46, расхождений 0
```

Это тот же `k1_controls.py`. Не превращаю удаление дублирующей проверки само по себе во второй блокер: при живой проверке membership и полном общем table→file отказ на отсутствующий файл всё ещё обеспечен. Гейт должен различать потерю обещанного поведения, а не обязательность конкретного второго цикла. Реальная потеря принятого поведения — отсутствие индекса на referenced-file входе — доказана отдельным обходом выше.

## Регресс К1–К3: семь П7 и три обхода круга 2

```sh
env TMPDIR=/tmp/dev-harness-verify/critic998r4 python3 /tmp/dev-harness-verify/critic998r4/variants.py
```

Сценарий перенесён из круга 3 с заменой рабочего корня; патчи обманных вариантов прежние. Три обхода круга 2 — `grammar_gap`, `target_snapshot`, `agent_drift_gap` — являются первыми тремя из семи П7; они не подменены новыми упрощёнными вариантами.

Сырой вывод, rc сценария=0:

```text
grammar_gap: --cases rc=1 | ['census cases: исполнено 46, расхождений 5'] | ['КРАСНО: gen_reject_class_number, gen_reject_class_blank, gen_reject_class_missing, gen_reject_conditional_number, gen_reject_emergency_object']
target_snapshot: --cases rc=1 | ['census cases: исполнено 46, расхождений 2'] | ['КРАСНО: gen_render_all_fields, gen_render_rule_set']
agent_drift_gap: --cases rc=1 | ['census cases: исполнено 46, расхождений 1'] | ['КРАСНО: gen_check_drift_agent_content']
constraint_snapshot: --cases rc=1 | ['census cases: исполнено 46, расхождений 2'] | ['КРАСНО: gen_render_all_fields, gen_render_stale_absent']
modelroles_gap: --cases rc=1 | ['census cases: исполнено 46, расхождений 1'] | ['КРАСНО: gen_check_drift_model_roles']
fallback_gap: --cases rc=1 | ['census cases: исполнено 46, расхождений 1'] | ['КРАСНО: gen_check_drift_fallback_chains']
missing_file_gap: --cases rc=1 | ['census cases: исполнено 46, расхождений 1'] | ['КРАСНО: gen_check_drift_agent_missing']
ALL VARIANTS RED rc=1
```

Последняя строка — прежняя надпись сценария, не его exit status. `missing_file_gap` — отсутствие проверки ПРОИЗВОДНОГО агента (К3), не проверка исходного файла роли (К1.24).

Дополнительный регресс отдельных видов цели, набора правил и оставшейся фазы stray:

```sh
python3 /tmp/dev-harness-verify/critic998r4/regress_extra.py
```

Сценарий запускает перенесённые `individual_controls.py` и `rule_set_controls.py`; оба rc=0. Сырые результаты:

```text
stray_phase_gap rc=1 CASE gen_check_drift_agent_stray: РАСХОЖДЕНИЕ — rc=0 (ожидается 1 — фаза «посторонний элемент каталога .omp/agents/»): харнес соответствует roles/ (10 ролей)
role_target_snapshot rc=1 CASE gen_render_all_fields: РАСХОЖДЕНИЕ — правило routing.rules[0] («ведущая сессия МУТАЦИЯ-0-998» → architect) не своей строкой в секции промпта; посторонняя строка секции рендера routing: '- ведущая сессия МУТАЦИЯ-0-998 → orchestrator — модель — явн'
tier_target_snapshot rc=1 CASE gen_render_all_fields: РАСХОЖДЕНИЕ — правило routing.rules[10] («кадры и картинки МУТАЦИЯ-10-998» → advisor) не своей строкой в секции промпта; посторонняя строка секции рендера routing: '- кадры и картинки МУТАЦИЯ-10-998 → @vision — только модель '
rule_add_ignored rc=1 CASE gen_render_rule_set: РАСХОЖДЕНИЕ — правило добавлено: правило routing.rules[12] («НОВЫЙ-КЛАСС-998» → architect) не своей строкой в секции промпта
rule_delete_stale rc=1 CASE gen_render_rule_set: РАСХОЖДЕНИЕ — последнее правило удалено: посторонняя строка секции рендера routing: '- ответ прецедентом → steward'
```

## Честный кандидат, красный исходник и матрица

```sh
python3 /tmp/dev-harness-verify/critic998r4/measure.py
```

Сценарий завершился rc=0. На клоне OBJECT реально выполнены:

```sh
bash fixtures/pravila_modelei_998/probe.sh --cases
bash fixtures/pravila_modelei_998/probe.sh --matrix
```

Итоги:

```text
pre_cases rc=1
census cases: исполнено 46, расхождений 39
matrix rc=0
census matrix: исполнено 57, расхождений 0
```

На `candidate/` выполнены те же шесть команд собранной приёмки, что перечислены выше для `file_index_gap/` (путь аргумента check_provodka — candidate). Сырые итоги:

```text
honest_cases rc=0
census cases: исполнено 46, расхождений 0
honest_lane rc=0
census cases: исполнено 46, расхождений 0
census matrix: исполнено 57, расхождений 0
honest_gen rc=0
харнес соответствует roles/ (10 ролей)
honest_ci rc=0

honest_provodka rc=0

honest_scoped rc=0
барьеров: 1 · фикстур: 28 · предъявлено красным повторным прогоном: 28
```

Полные логи с командами и кодами — `logs/*.log`, коды также в `measure_results.json`. Название «честный кандидат» означает положительный контроль реализуемости предъявленных клеток, а не сертификацию всей реализации: именно для доказательства различимости дополнительно построен `file_index_honest/` с требуемым индексом, а затем однострочный мутант его диагностики.

Историческая неизменность прежних барьеров между кругом 3 и этим OBJECT:

```sh
git diff --exit-code 905be408a03bd898e508a375d86b8b7158d40db1 c5e14654e8f21e37ccc12c33c1aafef5d9d1baac -- scripts .github package.json
```

rc=0, вывод пустой. Полный CI, полный antiplacebo, линтеры, форматтеры и проектные сборки не запускались.

## Граница решения и сохранённые материалы

Один действительный блокер: потеря индекса в referenced-file отказе принимается всем критерием. Нового функционального входа не вводится: это уже назначенный К1.24 и уже принятое именование К1. Точный bogus_tier обход исправлен, все остальные проверенные индексные ветви краснят потерю индекса. Точные два обхода круга 3, семь П7, три обхода круга 2 и дополнительные раздельные К2/К3-контроли проверены живым исполнением. Невакуумность `named_reject` доказана диагностическим мутантом, а не чтением текста.

АРБИТРАЖ: предмет уже ограничен решением `verdicts/arbitration/contracts-998-perechen-vetvej-v1.md` (К1, §Круг 3); после капа действует ответ консультанта в `forks/n998-krug3-kap.md`. Нового арбитражного/четвёртого обычного круга этим вердиктом не открываю: применяется оговорённый выход «998 отложить».

Все репро и результаты сохранены в `/tmp/dev-harness-verify/critic998r4/`: `prepare.py`, `make_honest.py`, `measure.py`, `variants.py`, `k1_controls.py`, `file_index_controls.py`, `regress_extra.py`, `individual_controls.py`, `rule_set_controls.py`; каталоги логов `logs/`, `k1_logs/`, `file_index_logs/`, `variant_*.log`, дополнительные `.log`; исходный SSH-клон и отдельные кандидатные деревья. Исследовательские скрипты — свидетельства вердикта, не production-правка.
