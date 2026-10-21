accept
OBJECT=ce23253e790f30e970f3e2da83daf9e049e7f102

Контракт 120, круг 2, только дельта к 58438133724e5d074f79d8210a8335a0f79722e2. Блокирующих находок нет. Обход первого круга закрыт по существу: классификация известных id берётся из пина, а транзитивное замыкание V1 ограничено id ядра и пяти процессов независимо от заявленного kind. На реальном продукте честная спецификация проходит. Предположение о возможном отсутствии 0b0c413 после squash не применимо к фактическому main: это merge-коммит, предок присутствует, деревья совпадают.

## Предмет и полнота

Судился закоммиченный HEAD ce23253e790f30e970f3e2da83daf9e049e7f102 ветки wip/120/architect в собственном клоне /tmp/dev-harness-verify/Critic120b/repo. Предмет, критерий с командами и кодами возврата, исполнители architect/implementer, ЗОНА-строки и граница продуктового дерева присутствуют. Вердикт первого круга прочитан. Контракт, оракул и реализация продукта не правились.

Все исполнения — из одноразовых клонов под /tmp/dev-harness-verify/Critic120b/, со своими .git и PYTHONDONTWRITEBYTECODE=1; временные миры батареи также под этим каталогом. Основной чекаут не использовался для записей или запуска Python. Push не выполнялся.

## Независимые пробы дельты

Пробы выполнены через живой раннер на собственном клоне Complior-back @45b946d06a5c2c6d5e0fa3b0fba66d07764acb63 с реальным пином харнесса. Между пробами возвращался честный граф.

| Состояние проверяемого дерева | Наблюдаемый результат |
|---|---|
| Честная спецификация honest_spec | rc 0, MOBILITY120_OK processes=5 new_operations=7 errors=15 nodes=20 pin=real |
| insurer_sandbox с kind SHARED | rc 1, graf-kind-protiv-pina |
| PM_FOUNDATION с kind SHARED | rc 1, graf-kind-protiv-pina |
| KUENDIGUNG с kind SHARED | rc 1, graf-kind-protiv-pina |
| Новый id insurer_contract, kind SHARED, непосредственно в зависимостях V1 | rc 1, graf-ne-consumer-first |
| V1 → процесс → SHARED_MOBILITY_CORE → insurer_contract → insurer_sandbox; непосредственного ребра V1 к каналу нет | rc 1, graf-ne-consumer-first (insurer_contract,insurer_sandbox) |
| Только KUENDIGUNG зависит от insurer_sandbox | rc 1, graf-ne-consumer-first |
| Самоссылка SHARED_MOBILITY_CORE | rc 1, graf-ciklichen |
| Дополнительный SHARED-узел вне замыкания V1, зависящий от insurer_sandbox | rc 0, nodes=21 pin=real: разрешённая открытость вне V1 сохранена |
| Обход первого круга плюс поддельный pin_120.json внутри spec_dir и поля pin/external_dependencies в release-graph.json | rc 1, graf-kind-protiv-pina: проверяемая спека не подменяет выбранный раннером пин |
| Честная спека плюс неотслеживаемый файл tests/critic120b-probe.txt | rc 1, vne-zony |

Фабрика батареи отдельно воспроизвела дословный обход первого круга d41 с обоими рёбрами V1/KUENDIGUNG → insurer_sandbox: rc 1, graf-kind-protiv-pina. d44 воспроизвела отсутствие базы пина: rc 2 с именованным диагнозом, клетка сошлась.

## Исполненная приёмка

- Живой продукт без спецификации: `bash fixtures/workshop_project/mobility_spec_120/red_mobility_spec_120.sh /tmp/dev-harness-verify/Critic120b/back` → rc 1, `spec-otsutstvuet (README_RU.md)`.
- `bash fixtures/workshop_project/mobility_spec_120/red_mobility_spec_120.sh --model` → rc 0, `ИТОГ 120: клеток 46, зелёных 46, красных 0`.
- MOBILITY120_ORACLE=stab_vsegda_zelenyj.sh, режим --model → rc 1, зелёных 1, красных 45.
- MOBILITY120_ORACLE=stab_vsegda_krasnyj.sh, режим --model → rc 1, зелёных 2, красных 44.
- `--cell net-takoj` → rc 2, `нет такой клетки: net-takoj`.
- `bash scripts/pre_critic.sh contracts/120-mobility-consumer-spec.md` → rc 0, дверь зелёная.
- `bash scripts/check_threat_model.sh . contracts/120-mobility-consumer-spec.md` → rc 0, 6/5 буллетов.
- `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic120b/repo contracts/120-mobility-consumer-spec.md` → rc 0, OK.
- `python3 fixtures/workshop_project/mobility_spec_120/gen_pin_120.py /tmp/dev-harness-verify/Critic120b/back 0b0c413 | cmp - fixtures/workshop_project/mobility_spec_120/pin_120.json` → rc 0, побайтовое совпадение. Генератор отдельно завершился rc 0.
- В собственном продуктовом клоне `git merge-base --is-ancestor 0b0c413 45b946d06a` → rc 0. `git rev-parse '0b0c413^{tree}' '45b946d06a^{tree}'` → дважды a701ae89c276eda4f424be0e7c5cdf62cbf794cf. Родители 45b946d06a: b8312f5cb7954aa94f12680a15d05688bd01eb2b и 0b0c413e209cda54f2d7c5d29667276f21661490. Пин, сгенерированный на main, отличается только base_commit.
- Старый оракул из 584381337 вместе с его собственной грамматикой прогнан против новых клеток: d41/d42/d43 — оракул rc 0, раннер rc 1; d44 — оракул rc 2 без нового диагноза, раннер rc 1. Все четыре клетки отличают прежнюю версию.

Сырые выводы дополнительных проб: /tmp/dev-harness-verify/Critic120b/logs/. Одноразовый воспроизводитель: /tmp/dev-harness-verify/Critic120b/repro.py; итог rc 0, «Дельта: все независимые пробы сошлись». Это проверочные артефакты судьи, не изменения поставляемого продукта.

## Находки

СОВЕТ contracts/120-mobility-consumer-spec.md:67 — слова «то же для d42, d43, d44» лучше уточнить для d44: общий результат раннера действительно rc 1, но прежний оракул на d44 возвращает rc 2 без нового диагноза, а не rc 0 MOBILITY120_OK. Прогон это различает, критерий не ослаблен; обхода нет, заморозку не блокирует.

## Пять вопросов — в границах дельты

1. Более слабый критерий: прежний конкретный обход устранён; новые независимые варианты с ложным kind, алиасом, транзитивной зависимостью и подменой пина не прошли. Ложного красного на честной спеке реального продукта не наблюдалось.
2. Доказуемость готовности: новые случаи И-2/И-7, отсутствие базы и совместимость с реальным продуктом исполнены командами с наблюдаемыми rc; различимость от старого оракула подтверждена.
3. Решения исполнителю: допустимое замыкание V1 и классификация известных id теперь заданы явно (contracts/120-mobility-consumer-spec.md:38); новых молчаливых развилок в дельте не найдено.
4. Границы: исполнители и зоны названы (:73–77); И-2 (:33) теперь проверяет изменения всего дерева, а не только app/server; добавление файла tests/ отвергнуто.
5. Норма AGENTS.md: новых противоречий в дельте не найдено. Модель угроз и precision-гейт зелёные. Н-39 соблюдена: контракт не утверждает пару «стаб ↔ ветвь». Cognitive-only решения lifecycle и severity/fix первого круга не переоткрывались.

Повторного FAIL нет; арбитраж не требуется. Accept относится к контракту до заморозки, не к содержательной приёмке будущей спецификации владельцем и не к готовности реализации процессов.
