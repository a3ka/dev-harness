FAIL
OBJECT=d441e285fe57c06e750ebc6f9c62c3e7350e1ae1
СУД: repo=dev-harness; предмет=109 (v4); фаза=контракт; роль=critic-sol; вызов=1/2; модель-план=openai-codex/gpt-6-sol; сессия=01a177ee-2a48-75af-86f8-4e9d5af0e8c0; модель-факт=openai-codex/gpt-6-sol; SHA=d441e285fe57c06e750ebc6f9c62c3e7350e1ae1; предыдущий=critic 109 v1–v3; исключение=нет

## Блокирующие находки

БЛОКИРУЕТ contracts/109-cmp-bck-004-stend-evidence.md:3 — занижен класс риска КОДОВОГО контракта. Класс причины: противоречие действующей норме `roles/critic.md §Класс риска`. Эта строка называет предмет «обычным», потому что «продукт не трогается», но сам предмет требует создание продуктового `compose.dev.yml`, изменение продуктовых `server/`, `app/config/`, `tests/integration/` (ЗОНА implementer, строка 74), отделение миграционных/DDL-учёток от API (инвариант 2, строка 43) и тест SQL role/context isolation, отсутствия DDL-учёток у API (приёмка 5, строка 61). Права/роли БД — буквально одно из перечисленных нормой оснований рискованного класса; отсутствие правок продукта в *архитекторском diff v4* не равно отсутствию их в раздаваемом контракте.
ОБЯЗАТЕЛЬСТВО: кодовый контракт обязан назвать класс риска и действительное основание, совпадающее с предметом.
СОСТОЯНИЕ: implementer исполняет ЗОНА product checkout и поставляет разделение DB-идентичностей/API.
НАБЛЮДЕНИЕ: классификация «обычный; права/роли БД не задеты; продукт не трогается» противоречит предмету, поэтому риск-рейтинг и следующий маршрут adversary могут быть неверно выбраны ещё до реализации.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: классификация учитывает продуктовые DB-права/роли и реально раздаваемые изменения; фактическую потребность в adversary определяют по такому классу, а не по составу коммита архитектора.

БЛОКИРУЕТ contracts/109-cmp-bck-004-stend-evidence.md:118 — в `НЕ ЗАЩИЩАЕТ` не объявлена существенная граница нового манифестного оракула. Класс причины: неназванный остаточный риск в обязательной модели угроз (не требование получить независимое число помимо манифеста). В списке есть подложный docker и внешняя среда, но не согласованно неверные манифест+файлы и не изменение расположения манифеста в будущем checkout продукта; §Инварианты 8, строка 49, обещает судить продукт *под проверкой* и считать его манифест источником N, а код закрепляет ровно два исторических пути в `PATHS`. Даже идеально зелёный W не отличит согласованно неверный список от истинного, а переехавший путь даст MANIFEST_MISSING вместо адаптации к новому run.js. Задание суда требует честно назвать остаток; не выдаю эти случаи за обнаруженный обход красных клеток.
ОБЯЗАТЕЛЬСТВО: `§НЕ ЗАЩИЩАЕТ` перечисляет фактические границы заявленной новой защиты, а не оставляет существенные остатки неявными (`roles/critic.md §Норма модели угроз`; задание §Что проверить, п.6).
СОСТОЯНИЕ: а) продукт несёт согласованно неверные 15 записей и 15 SQL вместо нужных 16; б) следующий продуктовый checkout перемещает манифест и меняет loadPlan, не имея прежнего файла.
НАБЛЮДЕНИЕ: а) N=15, ledger=15 зелены по определению этого оракула, независимого канона в W нет; б) `PATHS['manifest']` старой структуры не видит новый файл, отказ MANIFEST_MISSING; оба ограничения не названы в пяти пунктах `НЕ ЗАЩИЩАЕТ`.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: явно обозначенная граница, что манифест+файлы совместно считаются доверенным источником, их согласованная ошибка не ловится, а будущий перенос пути без обновления PATHS не поддерживается; docker-слой уже назван честно.

## Доказательства и числа на OBJECT

Работал только в `/tmp/dev-harness-verify/Critic109d/`; ни commit, ни push, ни docker-compose подъёма не было. `git log --oneline -3`: `d441e285 109 v4`, `05ab558e handoff`, `b1e93770 handoff`; `git diff --stat origin/main..HEAD`: шесть файлов, контракт `51` строк diff, `model/manifest.json` `89`, `probe.py` `249`, `red_migracii_109.sh` `15`, `source.json` `27`, `srez_migracii_109.py` `592`; `git diff --name-only` — только `contracts/109-cmp-bck-004-stend-evidence.md` и пять файлов `fixtures/workshop_project/stend_109/`; соседние барьеры/батареи не изменены. Сверка `frozen/contracts/109/3..HEAD` по контракту: 44 добавленных / 7 удалённых строк; заменены версия, обозначения, приёмки 2–4 и 8, ПРОВОДКА-ЭНФОРСМЕНТ, все замены тематически перечислены в §Замены v4. Старые инварианты 1–7, старые клетки и неизменные строки приёмки не ослаблены. ЗОНА architect только контракт и `stend_109/`; остальные зоны и `ПЕРЕСЕЧЕНИЕ` объявлены. Precision и проводка ниже — зелёные.

Живой Complior-back clone: main `8cb7ac2` — `manifest.json` `source=migrations/`, 14 `migrations` и 14 `*.sql`, последний `014_api_reads_migration_ledger.sql`; PR #239 `wip/007/implementer`, `c381c3d` — 15/15, последний `015_auth_entry_invitation.sql`. `run.js:42,155–181,221–223,240–242` действительно default-читает этот файл, сверяет состав/SHA до DB connect, `plan.length` определяет target и добавляет ledger rows для ещё не применённых миграций; живой SQL ledger после migrator здесь НЕ измерялся (без docker), это вывод по коду, не имитация опыта. `sha256sum` двух манифестов model/main → одинаковый `f125f672972418494c8a28234c82c8b5bc3968b0c925828506e72d3799ee6c38`; `cmp -s` rc 0. Единственные `14` в судящем коде среза — классы порождаемых миров/стаб с намеренной константой и исторический pin; `probe.py` использует `len(manifest_entries(tree))` в stend/delivery, две прочие цифры 14 — текст комментария и JS-проверка часа (`zh > 14`). Число каждого мира снимается из его `manifest.json` ДО вызова stend-факта; файл/фикстура/контракт не подменяют оракул.

Команды ниже выполнялись последовательно; строки вывода приведены дословно, многократные строки `mir-… ok` опущены только в сводках W (полный прогон был). `W=bash fixtures/workshop_project/stend_109/red_migracii_109.sh` из клона OBJECT:

```
W
109 SEZ: SUBJECT_ABSENT: нет --repo/--base/STEND109_BASE — зелень без субъекта невозможна
клетки среза: mir-N:zeleno (N из манифеста мира), ... stab s-pustoj-prinjat
RC=1
W --model --base /tmp/dev-harness-verify/Critic109d/back   # три отдельных запуска
клеток 31, красных 0
RC=0
клеток 31, красных 0
RC=0
клеток 31, красных 0
RC=0
W --model --base /tmp/dev-harness-verify/Critic109d/back007
mir-16:zeleno                               ok
mir-16:nedokat                              ok
mir-16:perekat                              ok
клеток 38, красных 0
RC=0
W --stabs --base /tmp/dev-harness-verify/Critic109d/back
stab s-konstanta-14 @ mir-15:zeleno          ok
stab s-konstanta-14 @ mir-1:zeleno           ok
stab s-ozhidanie-iz-fajlov @ mir-lishnij-fajl:zeleno-po-fajlam ok
stab s-manifest-iz-fikstury @ mir-15:zeleno  ok
stab s-pustoj-prinjat @ mir-pustoj-manifest:ledger-0 ok
стабов 4, привязок 5, непойманных 0
клеток 36, красных 0
RC=0
W --repo /tmp/dev-harness-verify/Critic109d/back
живой манифест /tmp/dev-harness-verify/Critic109d/back: N=14
полный CLI-прогон (PATH без docker): rc=1, отчёт=читается, красных фактов 0, красный контроль пуст
клеток 31, красных 0
RC=0
W --repo /tmp/dev-harness-verify/Critic109d/back007
живой манифест /tmp/dev-harness-verify/Critic109d/back007: N=15
полный CLI-прогон (PATH без docker): rc=1, отчёт=читается, красных фактов 0, красный контроль пуст
клеток 38, красных 0
RC=0
```

Четыре независимых мутанта *кода пробы* и две порчи пинов выполнены в отдельной disposable-копии через `python3 /tmp/dev-harness-verify/Critic109d/attack.py`, никогда не в OBJECT. Вывод команды (каждая строка `KRASNO` — собственный вход/наблюдение клетки; pid-проекты в note случайны, привязка к причине стабильна):

```
M1-constant-count rc= 1
mir-1:zeleno                                 KRASNO v=False note=живой стенд (проект stend109up81c7610e): up -d --wait: rc=0  | ledger='1' rc=0 | роль hc_synthetic_only: rolsu
mir-15:zeleno                                KRASNO v=False note=живой стенд (проект stend109up4bbd7944): up -d --wait: rc=0  | ledger='15' rc=0 | роль hc_synthetic_only: rols
mir-15:nedokat                               KRASNO v=True note=живой стенд (проект stend109up920cf490): up -d --wait: rc=0  | ledger='14' rc=0 | роль hc_synthetic_only: rols
mir-17:zeleno                                KRASNO v=False note=живой стенд (проект stend109up8251f54a): up -d --wait: rc=0  | ledger='17' rc=0 | роль hc_synthetic_only: rols
клеток 31, красных 4
M2-ignore-ledger-count-both-ups rc= 1
mir-1:nedokat                                KRASNO v=True note=живой стенд (проект stend109upa2a1bb83): up -d --wait: rc=0  | ledger='0' rc=0 | роль hc_synthetic_only: rolsu
mir-1:perekat                                KRASNO v=True note=живой стенд (проект stend109up80089c7a): up -d --wait: rc=0  | ledger='2' rc=0 | роль hc_synthetic_only: rolsu
mir-14:nedokat                               KRASNO v=True note=живой стенд (проект stend109up2d5bb79b): up -d --wait: rc=0  | ledger='13' rc=0 | роль hc_synthetic_only: rols
mir-14:perekat                               KRASNO v=True note=живой стенд (проект stend109upab82baa3): up -d --wait: rc=0  | ledger='15' rc=0 | роль hc_synthetic_only: rols
mir-15:nedokat                               KRASNO v=True note=живой стенд (проект stend109upb61768ee): up -d --wait: rc=0  | ledger='14' rc=0 | роль hc_synthetic_only: rols
mir-15:perekat                               KRASNO v=True note=живой стенд (проект stend109upc146b157): up -d --wait: rc=0  | ledger='16' rc=0 | роль hc_synthetic_only: rols
mir-17:nedokat                               KRASNO v=True note=живой стенд (проект stend109up72a04b40): up -d --wait: rc=0  | ledger='16' rc=0 | роль hc_synthetic_only: rols
mir-17:perekat                               KRASNO v=True note=живой стенд (проект stend109upd6c66b9f): up -d --wait: rc=0  | ledger='18' rc=0 | роль hc_synthetic_only: rols
клеток 31, красных 8
M3-ignore-file-manifest-diff rc= 1
mir-lishnij-fajl                             KRASNO cli rc=1 raise=None
клеток 31, красных 1
M4-hardcode-delivery-count rc= 1
mir-1:delivery-tokem                         KRASNO v=False note=тело теста «живое наблюдение: server+PG18…» выхолощено (I-10): отсутствуют токены 14, assert-проверок 9 < 5 —
mir-15:delivery-tokem                        KRASNO v=False note=тело теста «живое наблюдение: server+PG18…» выхолощено (I-10): отсутствуют токены 14, assert-проверок 9 < 5 —
mir-15:delivery-otstal                       KRASNO v=None note=NEEDS_ENV: docker недоступен — delivery-тест на PG18 НЕ исполнен
mir-17:delivery-tokem                        KRASNO v=False note=тело теста «живое наблюдение: server+PG18…» выхолощено (I-10): отсутствуют токены 14, assert-проверок 9 < 5 —
клеток 31, красных 4
M5-pin-corruption rc= 2
109 SEZ: ORACLE_TAMPERED: пин model/manifest.json f125f6729724 != байтам 61aca2bbbfd1
M6-stab-route-desync rc= 2
109 SEZ: ORACLE_TAMPERED: рассинхрон привязок s-konstanta-14: код ['mir-15:zeleno', 'mir-1:zeleno'] != source.json ['mir-15:zeleno', 'mir-17:zeleno']
RC=0
```

**Важная корректировка расследования:** одиночная мутация только первой проверки count (`led == expected`) была зелена (`31/31`) потому, что повторный up проверяет `led2 == expected` независимо (`probe.py:1571`). Она НЕ обход и не блокирующая находка. Парная мутация M2 краснеет 8 клетками. Ранее отправленное предварительное сообщение о M2 отменено после чтения второй проверки.

Формальные гейты (из клона OBJECT):

```
bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Critic109d/repo contracts/109-cmp-bck-004-stend-evidence.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
КРИТИК: дверь зелёная
RC=0
bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic109d/repo contracts/109-cmp-bck-004-stend-evidence.md
OK
RC=0
bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Critic109d/repo contracts/109-cmp-bck-004-stend-evidence.md
спек-гейт 036: перенос зоны: backend/compose.dev.yml (implementer): исключение ZONE_MOVE_EXEMPT (контракт 109, продуктовый репо)
[аналогичные 14 именованных исключений переноса зоны]
OK
RC=0
bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Critic109d/repo contracts/109-cmp-bck-004-stend-evidence.md
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 137 черновик(ов) судится, замороженные — по тегам
потолки в порядке
RC=0
bash scripts/check_provodka.sh /tmp/dev-harness-verify/Critic109d/repo contracts/109-cmp-bck-004-stend-evidence.md
RC=0
bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Critic109d/repo contracts/109-cmp-bck-004-stend-evidence.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 9 буллет(ов), НЕ ЗАЩИЩАЕТ 5 буллет(ов))
RC=0
```

`bash scripts/verify_antiplacebo.sh /tmp/dev-harness-verify/Critic109d/repo --scope 109` → `  FAIL scope_select отказал (код 1): `, rc 1; отдельно `bash scripts/scope_select.sh /tmp/dev-harness-verify/Critic109d/repo --scope 109` → `awk: fatal: cannot open file '…/scripts/109.sh'`, `неизвестный ключ 109`, rc 1. `--scope check_precision_gate` тоже rc 1 / `неизвестный ключ check_precision_gate`: эти имена не зарегистрированы как barrier-ключи `scripts/`; изменённый `fixtures/workshop_project/stend_109/` — probe-only каталог, не scripts-барьер. Это ограничение механизма scoped-выборки, не зелёный scoped-прогон. Целевые живые W и формальные гейты выше проверены; полный antiplacebo по норме ПРИЁМКА-СУДЬИ судья не гонял.

## СОВЕТ

СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:121 — явное предупреждение, что `--repo` W допускает rc 1 внутреннего полного CLI из-за docker-фактов NEEDS_ENV и сверяет отдельно чтение отчёта/нулевые красные факты, избавит от ложной трактовки «W rc0 значит probe CLI rc0». Текущее поведение измерено и честно объявлено в приёмке 12; это не обход.
