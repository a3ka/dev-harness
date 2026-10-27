accept
OBJECT=eda5fdbad64cef8d8fee58b98633183e2d257903
СУД: repo=dev-harness; предмет=109 (v4); фаза=контракт; роль=critic-sol; вызов=2/2; модель-план=openai-codex/gpt-6-sol; сессия=Critic109e (доступный идентификатор трейса agent history; UUID сессии не предоставлен); модель-факт=openai-codex/gpt-6-sol (workstation); SHA=eda5fdbad64cef8d8fee58b98633183e2d257903; предыдущий=verdicts/critic/contracts-109-v4-krug1.md (OBJECT=d441e285fe57c06e750ebc6f9c62c3e7350e1ae1, FAIL); исключение=нет

## Решение по исправительному вызову

Оба класса причины первого FAIL закрыты. `contracts/109-cmp-bck-004-stend-evidence.md:3` классифицирует *раздаваемый контракт целиком* как рисковый по основанию из закрытого списка «права/роли БД», ссылается на ЗОНА implementer, инвариант 2 и приёмку 5; оговорка о том, что сама текстовая/стендовая правка v4 не меняет продукт, не занижает класс. В документе больше нет прежнего утверждения «обычный; продукт не трогается». По существу и форме соответствует `roles/critic.md §Класс риска` и образцам 136/142; риск-маршрут adversary/reviewer остается предусмотрен приёмкой 6.

`contracts/109-cmp-bck-004-stend-evidence.md:126-127` явно ограничивает манифестный оракул: согласованная ошибка `manifest.json` + `*.sql` дерева продукта совместно принимается за источник N (независимого канона у W нет); перенос манифеста или изменение `loadPlan` вне двух исторических `PATHS['manifest']` требуют v+1/правки PATHS, прежнего пути нет — `MANIFEST_MISSING`, rc 2, fail-closed, а не ложное зелёное. `:49` оговаривает ровно те же два остатка. Предыдущие пять пунктов НЕ ЗАЩИЩАЕТ не изменены: всего 9 пунктов ЗАЩИЩАЕТ и 7 пунктов НЕ ЗАЩИЩАЕТ (формальный гейт ниже).

Регресс дельты: `git rev-list --count origin/main..HEAD` → `1`; `git diff d441e285fe57c06e750ebc6f9c62c3e7350e1ae1..HEAD --numstat` → `6  3  contracts/109-cmp-bck-004-stend-evidence.md`; `--name-only` → только этот контракт. `git diff d441e285f..HEAD -- fixtures/workshop_project/stend_109/` → пусто, батарея побайтно прежняя. Сравнение с `frozen/contracts/109/3` показывает только v4-замены/добавления, перечисленные в `§Замены v4` (пункты 1–5); пункт 6 теперь явно объявляет исправление по суду 1/2, включая приёмку 12 (уточнение о rc внутреннего CLI). Инварианты 1–7 и неизменные приёмки не ослаблены. ЗОНА architect/critic/adversary/reviewer и внешняя ЗОНА implementer (`:68-75`) с ПЕРЕСЕЧЕНИЕ остаются на месте; новая классификация риска не меняет их. Никаких новых блокирующих дефектов изменения не обнаружено. Docker-стенд не поднимал: живой Docker/PG18 и зелёная приёмка полного C — ответственность станции реализации, а не доказанный здесь факт.

## Сырые команды и вывод

Запускал из `/tmp/dev-harness-verify/Critic109e/repo` на HEAD `eda5fdbad64cef8d8fee58b98633183e2d257903`; самостоятельный checkout продукта `/tmp/dev-harness-verify/Critic109e/back` — `8cb7ac27dae1d509b1d1ae879cafabb726de8a08`. В него установлен `npm ci --ignore-scripts --no-audit --no-fund` (rc 0: `added 163 packages in 743ms`; npm предупредил EBADENGINE: продукту нужен Node 24.22.0, станция Node 26.5.1). Первая попытка W --model до установки зависимостей дала `клеток 31, красных 4`, rc 1, во всех четырёх случаях `NEEDS_ENV: node_modules/pg отсутствует — delivery-тест НЕ исполнен`; после установки повторил, результат ниже. Дерево объекта чистое (`git status --short` пусто). Запусков project-wide build/линтера/antiplacebo и docker не было.

```
$ bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Critic109e/repo contracts/109-cmp-bck-004-stend-evidence.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
КРИТИК: дверь зелёная
RC=0
$ bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic109e/repo contracts/109-cmp-bck-004-stend-evidence.md
OK
RC=0
$ bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Critic109e/repo contracts/109-cmp-bck-004-stend-evidence.md
спек-гейт 036: перенос зоны: backend/compose.dev.yml (implementer): исключение ZONE_MOVE_EXEMPT (контракт 109, продуктовый репо)
спек-гейт 036: перенос зоны: backend/server/ (implementer): исключение ZONE_MOVE_EXEMPT (контракт 109, продуктовый репо)
спек-гейт 036: перенос зоны: backend/tests/integration/ (implementer): исключение ZONE_MOVE_EXEMPT (контракт 109, продуктовый репо)
спек-гейт 036: перенос зоны: infra/ (implementer): исключение ZONE_MOVE_EXEMPT (контракт 109, продуктовый репо)
спек-гейт 036: перенос зоны: backend/app/config/ (implementer): исключение ZONE_MOVE_EXEMPT (контракт 109, продуктовый репо)
спек-гейт 036: перенос зоны: VERSION_MANIFEST.json (implementer): исключение ZONE_MOVE_EXEMPT (контракт 109, продуктовый репо)
спек-гейт 036: перенос зоны: backend/package.json (implementer): исключение ZONE_MOVE_EXEMPT (контракт 109, продуктовый репо)
спек-гейт 036: перенос зоны: tests/run_sql_3_9_native.py (implementer): исключение ZONE_MOVE_EXEMPT (контракт 109, продуктовый репо)
спек-гейт 036: перенос зоны: backend/tests/helpers/harness.js (implementer): исключение ZONE_MOVE_EXEMPT (контракт 109, продуктовый репо)
спек-гейт 036: перенос зоны: backend/package-lock.json (implementer): исключение ZONE_MOVE_EXEMPT (контракт 109, продуктовый репо)
спек-гейт 036: перенос зоны: VALIDATION.json (implementer): исключение ZONE_MOVE_EXEMPT (контракт 109, продуктовый репо)
спек-гейт 036: перенос зоны: backend/scripts/ (implementer): исключение ZONE_MOVE_EXEMPT (контракт 109, продуктовый репо)
спек-гейт 036: перенос зоны: tools/run_backend_ci.py (implementer): исключение ZONE_MOVE_EXEMPT (контракт 109, продуктовый репо)
спек-гейт 036: перенос зоны: README_RU.md (implementer): исключение ZONE_MOVE_EXEMPT (контракт 109, продуктовый репо)
спек-гейт 036: перенос зоны: evidence/runs/ (implementer): исключение ZONE_MOVE_EXEMPT (контракт 109, продуктовый репо)
OK
RC=0
$ bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Critic109e/repo
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 137 черновик(ов) судится, замороженные — по тегам
потолки в порядке
RC=0
$ bash scripts/check_provodka.sh /tmp/dev-harness-verify/Critic109e/repo contracts/109-cmp-bck-004-stend-evidence.md
RC=0
$ bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Critic109e/repo contracts/109-cmp-bck-004-stend-evidence.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 9 буллет(ов), НЕ ЗАЩИЩАЕТ 7 буллет(ов))
RC=0
```

Контроль честных миров (один прогон после установки pg; строки дословные):

```
$ bash fixtures/workshop_project/stend_109/red_migracii_109.sh --model --base /tmp/dev-harness-verify/Critic109e/back
mir-1:zeleno                                 ok 
mir-1:nedokat                                ok 
mir-1:perekat                                ok 
mir-1:podlognyj-soderzhimoe                  ok 
mir-1:pustoj-ledger                          ok 
mir-14:zeleno                                ok 
mir-14:nedokat                               ok 
mir-14:perekat                               ok 
mir-14:podlognyj-soderzhimoe                 ok 
mir-14:pustoj-ledger                         ok 
mir-15:zeleno                                ok 
mir-15:nedokat                               ok 
mir-15:perekat                               ok 
mir-15:podlognyj-soderzhimoe                 ok 
mir-15:pustoj-ledger                         ok 
mir-17:zeleno                                ok 
mir-17:nedokat                               ok 
mir-17:perekat                               ok 
mir-17:podlognyj-soderzhimoe                 ok 
mir-17:pustoj-ledger                         ok 
mir-1:delivery-tokem                         ok 
mir-14:delivery-tokem                        ok 
mir-14:delivery-otstal                       ok 
mir-15:delivery-tokem                        ok 
mir-15:delivery-otstal                       ok 
mir-17:delivery-tokem                        ok 
mir-17:delivery-otstal                       ok 
mir-manifest-otsutstvuet                     ok 
mir-pustoj-manifest                          ok 
mir-nechitaemyj-manifest                     ok 
mir-lishnij-fajl                             ok 
клеток 31, красных 0
RC=0
```

Обманные стабы архитектора (один прогон; набор батареи неизменен к 1/2, поэтому новых мутантов в исправительном вызове не создавал):

```
$ bash fixtures/workshop_project/stend_109/red_migracii_109.sh --stabs --base /tmp/dev-harness-verify/Critic109e/back
mir-1:zeleno                                 ok 
mir-1:nedokat                                ok 
mir-1:perekat                                ok 
mir-1:podlognyj-soderzhimoe                  ok 
mir-1:pustoj-ledger                          ok 
mir-14:zeleno                                ok 
mir-14:nedokat                               ok 
mir-14:perekat                               ok 
mir-14:podlognyj-soderzhimoe                 ok 
mir-14:pustoj-ledger                         ok 
mir-15:zeleno                                ok 
mir-15:nedokat                               ok 
mir-15:perekat                               ok 
mir-15:podlognyj-soderzhimoe                 ok 
mir-15:pustoj-ledger                         ok 
mir-17:zeleno                                ok 
mir-17:nedokat                               ok 
mir-17:perekat                               ok 
mir-17:podlognyj-soderzhimoe                 ok 
mir-17:pustoj-ledger                         ok 
mir-1:delivery-tokem                         ok 
mir-14:delivery-tokem                        ok 
mir-14:delivery-otstal                       ok 
mir-15:delivery-tokem                        ok 
mir-15:delivery-otstal                       ok 
mir-17:delivery-tokem                        ok 
mir-17:delivery-otstal                       ok 
mir-manifest-otsutstvuet                     ok 
mir-pustoj-manifest                          ok 
mir-nechitaemyj-manifest                     ok 
mir-lishnij-fajl                             ok 
stab s-konstanta-14 @ mir-15:zeleno          ok 
stab s-konstanta-14 @ mir-1:zeleno           ok 
stab s-ozhidanie-iz-fajlov @ mir-lishnij-fajl:zeleno-po-fajlam ok 
stab s-manifest-iz-fikstury @ mir-15:zeleno  ok 
stab s-pustoj-prinjat @ mir-pustoj-manifest:ledger-0 ok 
стабов 4, привязок 5, непойманных 0
клеток 36, красных 0
RC=0
```

## БЛОКИРУЕТ

Нет. Ранее доказанные два нарушения устранены; новое нарушение именованного обязательства в дельте не установлено.

## СОВЕТ

Нет. Совет 1/2 про внутренний rc CLI учтён предложением в приёмке 12 (`contracts/109-cmp-bck-004-stend-evidence.md:23`).
