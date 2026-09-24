1 дефект — FAIL: референсный набор 043 не замечает отключение задачи (в), поэтому не доказывает, что precision-гейт блокирует красный CI-паритет.

Н-39 ДОСЛОВНО: стабы к ветвям привязывает adversary по коду, не проза контракта.

Проверен свежий SSH-клон `origin` на live HEAD. Предметные файлы
`contracts/043-precizionnyj-prefriz-gejt.md`, `scripts/check_precision_gate.sh`,
`scripts/freeze_contract.sh` и `roles/critic.md` в нём не менялись. Все мутации
ниже делались только в одноразовых копиях этого клона и затем удалялись.

## Дефект: задача (в) не имеет дискриминирующей красной пробы

В одноразовой копии заменена ровно проверка rc дочернего паритет-барьера:

```sh
sed -i 's/\[ "$ci_rc" -eq 0 \] || die/true || die/' scripts/check_precision_gate.sh
```

То есть (а) и (б) остаются прежними, `verify_ci_parity.sh` всё ещё вызывается,
но его красный rc игнорируется. Затем в `package.json` добавлен один непокрытый
CI npm-скрипт:

```json
"adversary:rogue":"true"
```

Это действительное расхождение: CI его не запускает, а приёмка им богаче. На
неверной реализации все три референса гейта остались зелёными:

```text
$ bash fixtures/_krasnye_043.sh
итог: 17 файлов, провалов 0
[rc=0]

$ npm run check:precision-battery
БАТАРЕЯ check_precision_gate: итог 4/4 классов закрыто
[rc=0]

$ bash scripts/check_precision_gate.sh . contracts/043-precizionnyj-prefriz-gejt.md
OK
[rc=0]
```

Последняя команда **ожидалась rc=1**: дерево намеренно непаритетно, и изменённая
ветка обязана это остановить. Независимый оракул доказал, что вход действительно
красный:

```text
$ bash scripts/verify_ci_parity.sh .
workflow-команд: 45 · скриптов в приёмке: 58 · … · расхождений: 1
[rc=1]
```

Немодифицированный `check_precision_gate.sh` исходного клона на том же
подставном корне вернул rc=1 с `паритет CI красен (verify_ci_parity.sh rc 1)`.
Это не ложная краснота и не дефект текущей реализации, а дыра в её проверке:
`fixtures/_krasnye_043.sh` и parsing-батарея не создают красный CI-паритет,
а green self-application запускается лишь на здоровом дереве. Нужна красная
фикстура задачи (в): создать конкретное двустороннее расхождение, потребовать
именованный rc=1 от precision-гейта и проверить её зелёность честной реализацией.

## Остальные обманные заглушки

Каждый сценарий ниже выполнен против неизменённой реализации либо, где указано,
против её одноразовой неверной копии. Они не являются дополнительными дефектами.

| Класс adversary | Заглушка и команда | Наблюдение |
|---|---|---|
| отказ, выглядящий успехом | В отдельном наборе `verify_ci_parity.sh` заменён на `exit 127`; gate запущен как `env PATH=/definitely-missing /usr/bin/bash <copy>/check_precision_gate.sh <toy> contracts/043-toy-draft.md` | `паритет CI красен (verify_ci_parity.sh rc 127): simulated verifier missing`, rc=1. |
| инструмент мимо PATH | Та же проба с родительским `PATH=/definitely-missing` | rc=1 по содержательному rc=127: gate восстанавливает базовый PATH и не считает отсутствие инструмента успехом. |
| зашитая константа / пустой union | В копии после `zones_load` очищен `zones_scoped`; `bash fixtures/check_precision_gate/red_02_zona_collision_undeclared.sh` | сама фикстура стала красной: `case_02 … rc 0 (ожидался 1)`. Она держит молчаливый пропуск новой коллизии. |
| правильный ответ не на тот вопрос | В копии выключена только проверка `$live`; `bash fixtures/check_precision_gate/red_07_case_no_live_call.sh` | фикстура красная: `case_07 … rc 0 (ожидался 1)`. Отдельно честный gate отверг подделку `BASH_XTRACEFD` (`red_15…`, rc=0 у самопроверяющей фикстуры) и xtrace-only ветку (`red_16…`, rc=0 у фикстуры). |
| пустое/незаявленное имя полярности | `bash fixtures/check_precision_gate/red_06_case_polarity_undeclared.sh` | честный gate дал именованный rc=1; фикстура rc=0. |
| нейтрализация freeze-проводки | В копии заменено `if [ "$pg_rc" -ne 0 ]` на `if false`; `bash fixtures/check_precision_gate/red_14_freeze_refuses_red_precision.sh` | фикстура красная: freeze записал `frozen/contracts/044/1`, хотя precision-гейт был красен. Интеграция это ловит. |

## Литеральное untrusted-untrusted сравнение

Отдельный toy был построен штатными `mk_toy_repo`/`mk_foreign_frozen` из
`fixtures/check_precision_gate/_toy.sh`: frozen зона автора `alice.*` и пути
`shared/a[bc].txt`; черновик объявлял настоящую зону `shared/a[bc].txt`, но
ложное разрешение `ПЕРЕСЕЧЕНИЕ architect: shared/a*.txt — 999 …`. Честный
`bash scripts/check_precision_gate.sh <toy> contracts/043-toy-draft.md` вернул
rc=1 с точной причиной `ПЕРЕСЕЧЕНИЕ не привязан: путь shared/a*.txt не заявлен
автором architect в ЗОНА этого черновика`. Метасимволы не расширили привязку;
эта атака не прошла.

## Позитивные контроли честной реализации

Последовательно, без параллельного доступа к одному `lib_zones` scratch, были
зелёными:

```text
bash fixtures/_krasnye_043.sh                         # 17 файлов, 0 провалов
npm run check:precision-battery                        # 4/4 класса
bash scripts/verify_ci_parity.sh .                     # 0 расхождений
bash scripts/check_precision_gate.sh . contracts/043-precizionnyj-prefriz-gejt.md
                                                        # OK, rc=0
```

Текущая реализация корректно отклоняет проверенный красный CI-паритет; `FAIL`
относится к недостающей красной пробе, через которую эта ветка может
регрессировать незамеченной.
