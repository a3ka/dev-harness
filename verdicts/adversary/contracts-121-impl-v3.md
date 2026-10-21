accept

Адверсарий Adv121r3, контракт 121, круг 3 scoped (R5/evidence-deklaraciya). OBJECT сверён: `b85230f21e30f8a82db43354849f61e028e6cfbc` в выданном checkout и в моём одноразовом local clone.

R5 закрыт по сути.

- `PYTHONDONTWRITEBYTECODE=1 bash /home/harness/dev-harness/fixtures/workshop_project/yadro_121/yadro_oracle.sh --repo /tmp/dev-harness-verify/Adv121r3` — rc 0 (67.50 s). Закоммиченная RUNTIME-запись `20261021T080632Z.native` воспроизводится журналом свежего `test:core`; отказа `evidence-deklaraciya` нет.
- Положительный контроль батареи: `... yadro_oracle.sh --model` — rc 0 (13.57 s): честный мини-мир зелёный, 24 декоя отвергнуты именно своими причинами. В частности, модельное семейство декоев покрывает константный/чужой `run_key`, неполный ledger и запись с правильной формой не из исполненного SQL.
- Два последовательных `COMPLIOR_TEST_PG_ADMIN_URL=<одноразовая PG18> npm run -s test:core` на одной подготовленной базе — оба rc 0 (21/21); выход завершился `repeat-test-core rc=0`. Постоянные ID не внесли зависимости от чистоты или порядка.

Проверка регрессий R1–R4:

- Нейтрализация `app.guard_immutable()` в отдельном clone (функция возвращает `NEW` для UPDATE и `OLD` для DELETE) — `test:core` rc 1, 5/21 красных immutable-проверок; красный прогон не создал RUNTIME-evidence.
- Нейтрализация `ALTER ROLE brokeros_api BYPASSRLS` в отдельном clone — `test:core` rc 1, 3/21 красных RLS-проверок (видимость чужого scope, отозванный context, собственно bypassrls); красный прогон не создал RUNTIME-evidence.
- `npm run -s lint` — rc 0; `npm run test:standards-lint` — rc 0.
- `COMPLIOR_TEST_PG_ADMIN_URL=<одноразовая PG18> python3 tests/tools/run_backend_ci.py --lane postgres` — rc 0: все 6 шагов PASS, включая native `test:core` и `test:integration`.

Обязательные негативные классы проверки не дали ложной зелени: пустой `--repo ''` — rc 2 с usage; при `PATH=/nonexistent` режим `--model` — rc 2 (`dirname`/`mktemp` отсутствуют, `pin-otsutstvuet`), не rc 0. Константа вместо вычисления и ответ не на тот объект отвергаются декоями `--model`; точечные нейтрализации выше упали именно в своих семействах.

После прогонов `docker ps -a --filter name=adv121r3-` и `--filter name=yadro121-` вывели пусто. Расходные клоны, скрипты и symlink `node_modules` удалены. Новых блокирующих обходов в scoped-предмете не найдено.
