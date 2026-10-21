FAIL

OBJECT: 0651df6bda472c3d2cc640eb5231b61baa329388

Блокер — поставка не проходит обязательный integration-контур контракта 109. В добавленном `tests/integration/drill-measure.test.js` константа `COLLECTOR` указывает на отсутствующий `scripts/drill-measure.js`, тогда как поставочный entrypoint и реальный файл — `tests/tools/drill-measure.js` (`package.json`: `drill:evidence = node tests/tools/drill-measure.js`). Это не тестовая абстракция: каждый вызов коллектора получает rc=1 из-за отсутствующего модуля.

Красное предъявление (на одноразовой копии @OBJECT):
- `node --test tests/integration/drill-measure.test.js` → rc=1; tests=4, pass=0, fail=4. Все четыре случая ожидают rc 0/2, но получают rc 1.
- `node scripts/drill-measure.js --out /tmp/dev-harness-verify/Adv109/drill-repro` → rc=1, `Error: Cannot find module '.../scripts/drill-measure.js'`.
- Фактический поставочный путь существует: `node -p "require('./package.json').scripts['drill:evidence']"` → `node tests/tools/drill-measure.js`; `tests/tools/drill-measure.js` существует, `scripts/drill-measure.js` отсутствует.
- Полный `COMPLIOR_TEST_PG_ADMIN_URL=... npm run -s test:integration` также был красным: сначала эти четыре drill-теста (rc=1 вместо ожидаемых 0/2), затем не относящаяся к продукту недоступность 127.0.0.1:5432 в данной docker-изоляции. Первый дефект DB-независим и воспроизводится отдельной командой выше.

Это нарушает критерий 5: `npm ci && npm run test:integration` обязан завершаться rc 0 на native PG18; drill-набор падает до обращения к БД. Правка предмета: заменить путь `scripts/drill-measure.js` в `tests/integration/drill-measure.test.js` на `tests/tools/drill-measure.js` и повторить полный integration-прогон.

Остальные измерения (не отменяют блокер):
- @OBJECT совпал с заявленным SHA; от объявленной базы `0ed762b8...` изменены 11 путей, все в зоне implementer; `git diff --check` rc=0. (В локальном одноразовом clone `origin/main` был stale из-за clone --local, поэтому базу сверял по объявленному SHA; исходный supplied checkout имеет `origin/main=0ed762b8...`.)
- Пин: `frozen/contracts/109/3` и `STEND109_PIN` оба `a22dda581a642379cc49d9f72bc87d54a8988b20`; хэш probe в pinned checkout совпал с blob HEAD.
- `python3 tests/tools/run_backend_ci.py --lane checks` → rc=0.
- `npm run -s lint` → rc=0; `npm test` → rc=0, 63/63.
- `docker compose -f compose.dev.yml up -d --wait` → rc=0; повтор → rc=0; ledger=14; `hc_synthetic_only` имеет `rolcanlogin=true, rolsuper=false`; затем `docker compose ... down -v` → rc=0.
- Полный pinned lane: `COMPLIOR_STEND109_H_CHECKOUT=/tmp/dev-harness-verify/Adv109/h python3 tests/tools/run_backend_ci.py --lane stend109` → rc=0 за 658.8 с; его батарея сообщает control + 15 facts + 53 cells `REJECTED_EXACT`.
- Позитивный контроль батареи: `--case backend_lint_unused_const` → rc=0, `REJECTED_EXACT`, только `BACKEND_LINT_GUARD`. Отдельная заглушка с ровно одним неиспользуемым `const` в `tests/helpers/harness.js` дала `npm run -s lint` rc=1 (`no-unused-vars`), то есть барьер действительно ловит эту подмену.
- Прямой полный `probe.py --out ... --matrix` был остановлен после обнаружения блокера; его контейнер/volume очищены. Ранний полный прогон с лимитом 600 с закончился timeout, но успешный stend109 lane выше является полным oracle-прогоном в pinned пути.
- Проверка отсутствующего `node` не стала зелёной, но показала неклассифицированный traceback `FileNotFoundError`/rc=1 вместо контрактного `UNMEASURABLE: NEEDS_ENV` rc=2; это совет по диагностике проверки, не основание данного FAIL.
