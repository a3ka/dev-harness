FAIL
Усиление круга 2 закрывает три обхода Adv120, но добавляет два ложных красных: оба расширяют замороженный контракт, поэтому батарея непригодна как оракул принятия в текущем виде.
OBJECT=0d4647307f3a5a34ce493ba0019f6be6e95db147

## Блокеры: ложные красные относительно frozen/contracts/120/1

### Б-1 — «типизированная» не означает «обязательно новая» в И-5

Замороженная И-5 задаёт единственное отношение допустимости идентификаторов lifecycle: `operations ⊆ pin ∪ new_operations процесса KENNZEICHEN_WUNSCH`, плюс запрет deprecated. Она требует пять видов, но не утверждает, что идентификатор каждого из этих видов должен принадлежать `new_operations`. Следовательно, пять существующих, непомеченных deprecated идентификаторов из пина — конформный вариант.

Построен из OBJECT отдельный клон `frozen-conformant-existing-ops`: у KENNZEICHEN_WUNSCH `new_operations=[]`; пять lifecycle-идентификаторов заменены на существующие в пине `listMobilityServices`, `createMobilityServiceCase`, `getMobilityServiceRequirements`, `answerMobilityServiceRequirements`, `linkMobilityServiceDependency`. Их виды CHECK/RESERVE/READ/EXPIRE/CANCEL и все переходы сохранены; остальные инварианты не менялись, два новых insurance-идентификатора остались. Это непосредственно реализует разрешённую И-5 альтернативу, а не содержательный обход.

- Замороженный оракул из `/tmp/dev-harness-verify/Adv120/h` принял этот клон: rc=0, `MOBILITY120_OK processes=5 new_operations=2 errors=15 nodes=20 pin=real`.
- Усиленный оракул @a294171 принял тот же клон за красный: rc=1, `ОТКАЗ: mobility120: wunsch-lifecycle-nepolny (CHECK: listMobilityServices не новая типизированная операция)`.

Причина — новая `wunsch_tipizirovany`: она требует `id ∈ new_operations` для каждого обязательного вида. Это строго сильнее замороженной формулы `pin ∪ new` и потому решение architect («каждая ... обязательно НОВАЯ») расширяет, а не реализует frozen-контракт.

### Б-2 — требование всех внешних зависимостей сильнее И-7

Замороженная И-7 требует только `EXTERNAL ⊆ pin`, не равенство. В ней отдельно нужны пять PROCESS-узлов, их каналы в замыкании `CONSUMER_MOBILITY_REAL`, шесть PM_* и broker; `communications_admission` не является каналом процесса. Клон `omit-external` удаляет только EXTERNAL-узел `communications_admission` и ссылку на него из `PM_ENGAGEMENT`; все перечисленные требования сохраняются.

- Замороженный оракул принял этот вариант: rc=0, `MOBILITY120_OK processes=5 new_operations=7 errors=15 nodes=19 pin=real`.
- Усиленный оракул отверг его: rc=1, `ОТКАЗ: mobility120: graf-nepolny (внешние плана 119 без узла: communications_admission)`.

Новая `graf_vneshnie` заменяет допустимое подмножество равенством `set(pin_ext) <= ext_nodes`. Это второе наблюдаемое расширение frozen-контракта и отдельный ложный красный.

## Обходы круга 1 и позитивный контроль

Все прогоны ниже выполнены из собственного клона батареи @a294171fb71123a2f7fd9a35d83c2bb5a2bce194 с `PYTHONDONTWRITEBYTECODE=1`.

| Проба | Факт | rc |
|---|---|---:|
| OBJECT, живой усиленный guard | `MOBILITY120_OK processes=5 new_operations=7 errors=15 nodes=20 pin=real` | 0 |
| полный `--model` | 51 клетка, зелёных 51, красных 0 | 0 |
| `--stabs` | `строк 13, расхождений 0` | 0 |
| Adv120 `assume-unchanged` с изменённым `server/src/logger.js` | `vne-zony (server/src/logger.js)` | 1 |
| самостоятельный `skip-worktree` того же запрещённого файла | `vne-zony (server/src/logger.js)` | 1 |
| Adv120 `no-new-operations` (стёрты семь новых операций, lifecycle переназначен на общие) | `wunsch-lifecycle-nepolny (CHECK: listMobilityServices не новая типизированная операция)` | 1 |
| Adv120 `omit-external` (удален `communications_admission`) | `graf-nepolny (внешние плана 119 без узла: communications_admission)` | 1 |

Таким образом, усиление действительно ловит три прежних неконформных пробы и имеет живой позитивный контроль; дефект — не плацебо, а сверхконтрактное условие.

## Закрытие Б-1 review и граница delivery

`git diff --name-status b408b427..OBJECT` показал ровно один путь: `M docs/spec/mobility-consumer-v1/bundle-errors-315.json`. В нём ровно 15 замен поля `fix`; независимая проверка JSON дала `entries=15 all_model_fix=True`, то есть каждое поле ровно `по §5.2 «Как исправить»`. Воспроизводимость реального пина: `gen_pin_120.py back 0b0c413... | cmp - pin_120.json` — rc=0. Замороженный контракт и `pin_120.json` в ветке architect побайтно не менялись относительно `frozen/contracts/120/1` (rc=0).

Требуемая правка — за architect: удалить либо формально заморозить обе новые сильные предпосылки в контракте до включения их в оракул. Без этого принимать только из-за зелёного OBJECT нельзя: батарея отвергает два конформных мира.
