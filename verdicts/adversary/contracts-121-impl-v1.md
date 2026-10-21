FAIL

Обход: `test:core` можно сделать зелёным при нарушенной immutable-семантике `app.document_version`, сохранив все маркеры, каталог триггера и реакцию на четыре штатные DAMAGE-мутации. Следовательно, оракул и набор тестов принимают ответ на другой вопрос (наличие/включённость триггера), а не требуемый отказ UPDATE/DELETE существующей версии.

Репро выполнено только в `/tmp/dev-harness-verify/Adv121` на native PostgreSQL 18.6 из пина.

1. Честные контроли:
   - `bash /home/harness/dev-harness/fixtures/workshop_project/yadro_121/yadro_oracle.sh --model` -> rc 0.
   - `bash /home/harness/dev-harness/fixtures/workshop_project/yadro_121/yadro_oracle.sh --repo /tmp/dev-harness-verify/Adv121` -> rc 0 (Docker/PG18 доступны; оракул выполнил контрольные повторы и все четыре DAMAGE-пробы).
   - `sha256sum` на `migrations/001_core.sql`, `002_rls.sql`, `003_finance.sql`, `004_runtime_role_fixes.sql` дал четыре digest из `pin_yadro121.json`; `git diff --exit-code c525fd8 -- migrations/001_core.sql migrations/002_rls.sql migrations/003_finance.sql migrations/004_runtime_role_fixes.sql` -> rc 0.
   - `npm run -s lint && npm run test:standards-lint` -> rc 0.

2. Заглушка (только в одноразовом клоне): добавлен `tests/integration/core/evil_immutable_setup.js`, который до запуска существующего `run_core.js` от admin URL выполняет
   `CREATE OR REPLACE FUNCTION app.guard_immutable() RETURNS trigger LANGUAGE plpgsql AS $f$ BEGIN IF TG_OP = 'DELETE' THEN RETURN OLD; END IF; RETURN NEW; END $f$`.
   Скрипт `test:core` временно заменён на
   `node tests/integration/core/evil_immutable_setup.js && node tests/integration/core/run_core.js`.
   Это оставляет `guard_document_version` включённым (`tgenabled='O'`), сохраняет `plpgsql` и поэтому не ослепляет DAMAGE: отключение `guard_document_version` всё ещё роняет существующую проверку.

3. Эта заведомо негодная реализация прошла полный продуктовый оракул:
   `bash /home/harness/dev-harness/fixtures/workshop_project/yadro_121/yadro_oracle.sh --repo /tmp/dev-harness-verify/Adv121` -> rc 0.
   Тем самым пройдены и штатный честный контроль, и контрольные повторы, и все 4 DAMAGE-пробы, хотя immutable-функция стала пропускающей UPDATE/DELETE.

4. Наблюдаемый контрпример на отдельной PG18: после применения 001–004 (`node server/infrastructure/migrations/run.js --through 004` -> rc 0) заглушка дала `npm run -s test:core` -> rc 0, 20/20. Затем на существующей строке `app.document_version` команда
   `UPDATE app.document_version SET object_key='tampered' WHERE id='00000000-0000-0000-0000-000000000005'`
   дала `UPDATE 1`; последующий `SELECT object_key ...` вывел `tampered`. Требуемый запрет UPDATE не выполняется.

Нужна правка автора: реальные положительный INSERT и отрицательные UPDATE/DELETE существующих `document_version` и `approval` (а не только pg_catalog/tgenabled) должны быть обязательными для `test:core`; аналогично проверки критериев 4г не должны ограничиваться структурой, если ими заявляется поведение.

Попытки прочих классов:
- пустой/несуществующий `--repo` не принят (rc 2), а отсутствие зависимостей не объявляется успехом;
- относительный `--repo .` ошибочно даёт rc 1 `ranner-ne-otkazyvaet`: оракул делает относительный symlink `./node_modules` внутри временной копии, поэтому `pg` не находится. Это не основание данного FAIL, так как объявленный абсолютный checkout проходит;
- обычная нейтрализация каждого из force/bypassrls/immutable/journal ловится штатным оракулом; найденный обход сохраняет именно эту чувствительность и меняет непроверяемую семантику функции.
