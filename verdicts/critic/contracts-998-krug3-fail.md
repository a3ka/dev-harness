FAIL
OBJECT=905be408a03bd898e508a375d86b8b7158d40db1

# Критик 998, круг 3 — закрытый перечень после арбитража

К ВЛАДЕЛЬЦУ: кап трёх кругов достигнут. Два воспроизведённых обхода относятся исключительно к К1.24 и К1.23 принятого перечня. Нового блокирующего требования вне К1–К3 не ввожу. К2 и К3 усилены правильно; семь вариантов П7 теперь красны. Это не отменяет двух оставшихся дыр К1: весь объявленный критерий проходит на каждом из двух кандидатов ниже.

Арбитраж уже состоялся: `verdicts/arbitration/contracts-998-perechen-vetvej-v1.md`, Решение 2 и §Круг 3. Нужен не четвёртый обычный круг и не повторный инженерный арбитраж, а предусмотренный этим решением выход к владельцу.

## Предмет, происхождение и входной гейт

Рабочая область: `/tmp/dev-harness-verify/critic998r3/`. Основной чекаут не использован ни как источник кандидата, ни для записи. Клон получен командой:

```sh
git clone ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/critic998r3/clone
git fetch origin wip/998/architect
git checkout --detach 905be408a03bd898e508a375d86b8b7158d40db1
git rev-parse HEAD
```

Последний сырой вывод, rc=0:

```text
905be408a03bd898e508a375d86b8b7158d40db1
```

`roles/critic.md`, оба предыдущих вердикта и арбитраж прочитаны из `origin/main` через `git show origin/main:<путь>`. Контракт и проба судятся с указанного OBJECT, не с main и не по сообщению автора. Прочитан `AGENTS.md` предмета. Предмет, критерий с командами, исполнители, ЗОНА-строки, модель угроз и красная проба присутствуют; отказа по неполному набору нет.

Первая исполненная проверка контракта:

```sh
env TMPDIR=/tmp/dev-harness-verify/critic998r3 bash scripts/pre_critic.sh contracts/998-pravila-modelei.md
```

rc=0, сырой вывод:

```text
КРИТИК: дверь зелёная
```

Затем отдельно, не параллельно другому precision/pre_critic:

```sh
env TMPDIR=/tmp/dev-harness-verify/critic998r3 bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/critic998r3/clone contracts/998-pravila-modelei.md
```

rc=0, сырой вывод:

```text
OK
```

## Блокирующие находки — только закрытый К1

### К1.24: клетка отсутствующего файла одновременно удаляет запись таблицы и не различает потерю файловой проверки

БЛОКИРУЕТ contracts/998-pravila-modelei.md:80 — требование «роль есть в таблице И имеет файл» и обещание покрытия каждой ветви на :186–192 не доказаны для К1.24. `fixtures/pravila_modelei_998/probe.py:521–530` удаляет не только файл роли и производный агент, но и `roles["implementer-glm"]` из конфигурации. Поэтому `gen_reject_missing_role` (:681–695) зеленеет за счёт уже проверяемой К1.22 — отсутствующей записи роли в таблице. В матрице повторена та же совместная поломка (:1007–1011). Это не независимый вход «роль в таблице осталась, файла нет» из строки К1.24 арбитража.
ОБХОД: у зелёного кандидата удалить из `loadRoles` оба цикла проверки наличия файлов — общий table→file и routing→file; остальную грамматику, рендер и пять фаз производных оставить неизменными. Кандидат `missing_role_file_gap/` проходит `--cases` 44/0, lane с матрицей 54/0, check:gen, gen_ci_steps --check, check_provodka и scoped check_provodka. Затем в его копии удалить `roles/implementer-glm.md` и соответствующую производную, ОСТАВИВ таблицу ролей и обе ссылки routing неизменными. Генератор принимает этот вход кодом 0 в ОБЕИХ точках входа. Файла роли нет, но контрактные команды до входа-свидетеля не обнаружили отсутствие обязательной проверки.

Это именно пункт К1.24, помеченный арбитражем «есть», а не новый вид входа: §Круг 3 арбитража требует, чтобы пункты «есть» по-прежнему различались. Удаление общей проверки потребовалось, чтобы она не маскировала потерю routing→file; никаких исключений по тестовому токену или имени входа в генератор не добавлено.

Команда опыта (все копии внутри разрешённой области):

```sh
python3 /tmp/dev-harness-verify/critic998r3/k1_bypasses.py
```

Сырые строки вывода:

```text
missing_role_file_gap_cases rc=0
CASE cases gen_reject_missing_role: ok — удаление роли, на которую ссылается routing, отвергнуто в обеих точках
census cases: исполнено 44, расхождений 0
missing_role_file_gap_lane rc=0
census cases: исполнено 44, расхождений 0
census matrix: исполнено 54, расхождений 0
missing_role_file_gap_gen rc=0
харнес соответствует roles/ (10 ролей)
missing_role_file_gap_ci rc=0
missing_role_file_gap_provodka rc=0
missing_role_file_gap_scoped rc=0
барьеров: 1 · фикстур: 28 · предъявлено красным повторным прогоном: 28
WITNESS role table preserved: task-glm
WITNESS routing refs: [3, 4]
file_witness_check rc=0
харнес соответствует roles/ (9 ролей)
file_witness_prompt rc=0
```

Дополнительный положительный контроль именно различимости К1.24, а не правка пробы: в отдельной копии seed удалён ТОЛЬКО `roles/implementer-glm.md`; таблица сохранена. Закоммиченная честная модель корректно отказывает:

```sh
python3 /tmp/dev-harness-verify/critic998r3/file_branch_control.py
```

Сырой вывод:

```text
check rc=1   FAIL routing.rules[3]: роли «implementer-glm» нет файла roles/implementer-glm.md
routing: правила моделей расходятся с ролями/тирами config/agent_models.json

prompt rc=1   FAIL routing.rules[3]: роли «implementer-glm» нет файла roles/implementer-glm.md
routing: правила моделей расходятся с ролями/тирами config/agent_models.json
```

Модель умеет нужную ветвь; предъявленный вход пробы её независимо не испытывает.

### К1.23: отсутствие индекса неизвестного тира не различается

БЛОКИРУЕТ contracts/998-pravila-modelei.md:192 — критерий требует именования `rules[N]`, как и заголовок закрытого К1 арбитража, но у `bogus_tier` в `fixtures/pravila_modelei_998/probe.py:490–492` индекс задан `None`. Нарушение находится в конкретном правиле; `None` отключает проверку индекса в `named_reject` (:510). Для новых tier_number/tier_blank индекс уже вычисляется через `first_tier`, а для К1.23 осталась дыра.
ОБХОД: у зелёного кандидата изменить только диагностическую строку ветви отсутствующего тира: вместо `routing.rules[${i}]: тира «${tv}» нет в tiers` выдавать `routing: тира «${tv}» нет в tiers`. Кандидат `tier_index_gap/` проходит ВСЕ команды критерия, включая 44/0 и матрицу 54/0. На входе К1.23 обе точки возвращают 1, но не называют `rules[10]`. При этом клетка объявляет, что индекс назван. Это потеря прямо принятого свойства диагностики на названном входе, не пожелание к стилю сообщения.

Тот же `k1_bypasses.py`, сырые строки:

```text
tier_index_gap_cases rc=0
CASE cases gen_reject_bogus_tier: ok — нарушение отвергнуто в обеих точках входа (routing, индекс, нарушитель названы)
census cases: исполнено 44, расхождений 0
tier_index_gap_lane rc=0
census cases: исполнено 44, расхождений 0
census matrix: исполнено 54, расхождений 0
tier_index_gap_gen rc=0
харнес соответствует roles/ (10 ролей)
tier_index_gap_ci rc=0
tier_index_gap_provodka rc=0
tier_index_gap_scoped rc=0
барьеров: 1 · фикстур: 28 · предъявлено красным повторным прогоном: 28
WITNESS missing tier index: 10
tier_witness_check rc=1
FAIL routing: тира «does-not-exist-998» нет в tiers

tier_witness_prompt rc=1
FAIL routing: тира «does-not-exist-998» нет в tiers
```

Для каждого обхода отдельно реально исполнены:

```sh
bash fixtures/pravila_modelei_998/probe.sh --cases
bash scripts/run_ci_lane.sh check:pravila-modelei-998
npm run --silent check:gen
bash scripts/gen_ci_steps.sh --check
bash scripts/check_provodka.sh "$PWD" contracts/998-pravila-modelei.md
npm run --silent check:antiplacebo -- --scope check_provodka
```

Все шесть rc=0 на каждом мутанте. Затем входы-свидетели сделаны в ОТДЕЛЬНЫХ копиях. На свидетелях заявляю только исполненные `node scripts/gen-harness.ts --check` и `--prompt orchestrator`, а не зелёную полную приёмку после удаления роли/введения неизвестного тира. Полные команды, cwd, rc и stdout/stderr сохранены в `bypass_logs/*.log`.

## Сверка П1–П7 и закрытых классов

| Пункт | Наблюдение круга 3 |
|---|---|
| П1 | 12 новых мутаций присутствуют в ROUTING_BRANCHES/NEG_MUTS, обе точки вызываются; model_* добавлены, key_only_class_number есть. Grammar_gap теперь даёт пять именованных красных клеток. Но весь К1 не закрыт: К1.23/К1.24 выше. |
| П2 | Цели role и tier реально меняются на другие существующие; есть три варианта gen_render_rule_set и удаление необязательных полей с проверкой старых значений. Снимки целей и constraint красны. Раздельные снимки только role и только tier также красны. |
| П3 | Вместо совместной поломки — пять отдельных клеток. Потеря каждой фазы теперь красна своей клеткой; отдельно проверена и потеря обнаружения stray-файла. |
| П4 | Инвариант :83–95, критерий :179–185/:198–201 и модель угроз перечисляют пять фаз; --into/--resolve-overlay/--agents-rules честно выведены из суда пробы с reviewer и legacy CI как ловцами. Числа 44/38, 44/0 воспроизведены. |
| П5 | Текст о «ветвь = мутация» и новый перечень внесён, но его полнота не подтверждена для двух пунктов К1 выше. |
| П6 | В инвариант :101–105 и критерий :194–197 внесены цели, смена формы, набор правил и отсутствие устаревших необязательных значений. |
| П7 | До-предметная проба 44/38, кандидат 44/0, матрица 54/0; все семь назначенных вариантов красны именованно. pre_critic/precision/threat зелёные. check_provodka на собранном кандидате зелёный; на до-предметном OBJECT красный из-за ещё не доставленной нормы роли — точный вывод ниже. Это не дополнительный блокер. |

Проверки реализуемости выполнены не на чужом готовом дереве: `prepare.py` создал `make_honest.py` из прочитанного построителя автора, заменив SRC на МОЙ SSH-клон OBJECT. Построитель применён только к disposable `candidate/`, выполнил живую генерацию производных и CI. Название «честный кандидат» здесь означает положительный контроль назначенных опытов, а не независимую сертификацию всей реализации: найденные обходы показывают, почему одной зелени недостаточно.

Команды обязательных вариантов и прежних закрывающих опытов:

```sh
python3 /tmp/dev-harness-verify/critic998r3/variants.py
python3 /tmp/dev-harness-verify/critic998r3/closures.py
```

Сырой вывод вариантов П7:

```text
grammar_gap: --cases rc=1 | ['census cases: исполнено 44, расхождений 5'] | ['КРАСНО: gen_reject_class_number, gen_reject_class_blank, gen_reject_class_missing, gen_reject_conditional_number, gen_reject_emergency_object']
target_snapshot: --cases rc=1 | ['census cases: исполнено 44, расхождений 2'] | ['КРАСНО: gen_render_all_fields, gen_render_rule_set']
agent_drift_gap: --cases rc=1 | ['census cases: исполнено 44, расхождений 1'] | ['КРАСНО: gen_check_drift_agent_content']
constraint_snapshot: --cases rc=1 | ['census cases: исполнено 44, расхождений 2'] | ['КРАСНО: gen_render_all_fields, gen_render_stale_absent']
modelroles_gap: --cases rc=1 | ['census cases: исполнено 44, расхождений 1'] | ['КРАСНО: gen_check_drift_model_roles']
fallback_gap: --cases rc=1 | ['census cases: исполнено 44, расхождений 1'] | ['КРАСНО: gen_check_drift_fallback_chains']
missing_file_gap: --cases rc=1 | ['census cases: исполнено 44, расхождений 1'] | ['КРАСНО: gen_check_drift_agent_missing']
ALL VARIANTS RED rc=1
```

Последняя строка — текст сценария, его собственный rc=0; rc=1 относятся к семи отдельным прогонам пробы. `missing_file_gap` здесь — утрата проверки ПРОИЗВОДНОГО агента К3.2, не утрата файла ИСХОДНОЙ роли К1.24. Их нельзя считать одной ветвью.

Закрытые Б3/Б4/Б5/Б8 не регрессировали на прежних сценариях; Б7 подтверждён отдельным precision-гейтом. Сырые пары имя/итог из `closures.py`:

```text
closed_no_autofallback rc=1
census cases: исполнено 44, расхождений 2
closed_different_tools rc=1
census cases: исполнено 44, расхождений 1
closed_no_orch_norm rc=1
census cases: исполнено 44, расхождений 1
closed_no_orch_norm_provodka rc=1 проводка: норма-строка не найдена в role-файле: roles/orchestrator.md
closed_false_norms rc=1
census cases: исполнено 44, расхождений 2
closed_narrow_disk rc=1
census cases: исполнено 44, расхождений 2
closed_drop_constraint rc=1
census cases: исполнено 44, расхождений 4
closed_all_roles rc=1
census cases: исполнено 44, расхождений 1
```

Дополнительные раздельные контроли внутри К2/К3:

```sh
python3 /tmp/dev-harness-verify/critic998r3/individual_controls.py
python3 /tmp/dev-harness-verify/critic998r3/rule_set_controls.py
```

Сырые строки:

```text
stray_phase_gap rc=1 CASE gen_check_drift_agent_stray: РАСХОЖДЕНИЕ — rc=0 (ожидается 1 — фаза «посторонний элемент каталога .omp/agents/»): харнес соответствует roles/ (10 ролей)
role_target_snapshot rc=1 CASE gen_render_all_fields: РАСХОЖДЕНИЕ — правило routing.rules[0] («ведущая сессия МУТАЦИЯ-0-998» → architect) не своей строкой в секции промпта; посторонняя строка секции рендера routing: '- ведущая сессия МУТАЦИЯ-0-998 → orchestrator — модель — явн'
tier_target_snapshot rc=1 CASE gen_render_all_fields: РАСХОЖДЕНИЕ — правило routing.rules[10] («кадры и картинки МУТАЦИЯ-10-998» → advisor) не своей строкой в секции промпта; посторонняя строка секции рендера routing: '- кадры и картинки МУТАЦИЯ-10-998 → @vision — только модель '
rule_add_ignored rc=1 CASE gen_render_rule_set: РАСХОЖДЕНИЕ — правило добавлено: правило routing.rules[12] («НОВЫЙ-КЛАСС-998» → architect) не своей строкой в секции промпта
rule_delete_stale rc=1 CASE gen_render_rule_set: РАСХОЖДЕНИЕ — последнее правило удалено: посторонняя строка секции рендера routing: '- ответ прецедентом → steward'
```

## Команды исходного и положительного деревьев

На OBJECT, с TMPDIR внутри разрешённой области:

| Команда | Наблюдаемый rc / сырой итог |
|---|---|
| `bash fixtures/pravila_modelei_998/probe.sh --cases` | 1; `census cases: исполнено 44, расхождений 38` |
| `bash fixtures/pravila_modelei_998/probe.sh --matrix` | 0; `census matrix: исполнено 54, расхождений 0` |
| `bash scripts/check_threat_model.sh <клон> contracts/998-pravila-modelei.md` | 0; вывод пустой |
| `bash scripts/check_provodka.sh <клон> contracts/998-pravila-modelei.md` | 1; `проводка: норма-строка не найдена в role-файле: roles/orchestrator.md` |
| `npm run --silent check:antiplacebo -- --scope check_provodka` | 0; `барьеров: 1 · фикстур: 28 · предъявлено красным повторным прогоном: 28` |

На `candidate/` реально исполнены те же шесть команд собранной приёмки, что перечислены для обходов. Сырой итог `measure.py`:

```text
honest_cases rc=0
census cases: исполнено 44, расхождений 0
honest_lane rc=0
census cases: исполнено 44, расхождений 0
census matrix: исполнено 54, расхождений 0
honest_gen rc=0
харнес соответствует roles/ (10 ролей)
honest_ci rc=0
honest_provodka rc=0
honest_scoped rc=0
SCOPED: барьеров 1 из выборки — не для приёмки
барьеров: 1 · фикстур: 28 · предъявлено красным повторным прогоном: 28
```

Измеритель сначала ошибочно ожидал rc=0 у до-предметной ПРОВОДКИ и остановился на её закономерном rc=1. Результат не скрыт и не перепроверялся для изменения диагноза: оставшиеся независимые опыты выполнены `measure_remaining.py`. Это ошибка ожидания исследовательской обвязки, не новый дефект предмета.

Историческая неизменность frozen-барьеров между кругами:

```sh
git diff --exit-code 045a91367ff82d8f3d5827e4caeeeb6ad13972b7 905be408a03bd898e508a375d86b8b7158d40db1 -- scripts .github package.json
```

rc=0, вывод пустой. Полный CI, полный antiplacebo, форматтеры и проектные сборки не запускались.

## Граница вывода и материалы

Пять вопросов роли применены к закрытому предмету: слабость критерия/недоказуемость — два точных обхода К1; новых молчаливых решений в блокеры не добавлено; исполнители и границы названы, precision зелёный; новых противоречий AGENTS.md вне перечня в отказ не внесено. К2/К3, старые закрытые блокеры и режимы вне предмета не использованы для расширения требований. Судится различимость контракта, не production-реализация.

Все исследовательские материалы под `/tmp/dev-harness-verify/critic998r3/`: `prepare.py`, `make_honest.py`, `measure.py`, `measure_remaining.py`, `variants.py`, `closures.py`, `individual_controls.py`, `rule_set_controls.py`, `file_branch_control.py`, `k1_bypasses.py`; журналы `logs/`, `bypass_logs/`, `variant_*.log`, `closed_*.log` и именованные логи дополнительных контролей. Они оставлены как воспроизводимые свидетельства, не предлагаются к переносу в production. Контракт и проба SSH-клона не правились.

Вердикт не коммитился и не пушился — по явному ограничению задания. Файл для коммита оркестратором: `/tmp/dev-harness-verify/critic998r3/verdict.md`.
