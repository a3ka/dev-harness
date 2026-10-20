FAIL

Объект: `ef49cefb06a7aca27fc2270caf8b05e906693dc0`.

Найден обход батареи `fixtures/workshop_project/standarty_115/probe.py`: она принимает документ, который прямо отменяет обязательную норму §15. В одноразовом клоне изменена ровно строка `docs/CODING-STANDARDS.md`:

```diff
- `forEach` запрещён: он мутирует внешний scope и возвращает undefined;
+ `forEach` разрешён: он мутирует внешний scope и возвращает undefined;
```

Это сохраняет все требуемые батареей заголовки и токены (`forEach`, `bind`, `apply`, `complexity`, `max-depth`), но делает документный стандарт противоречащим предмету контракта: §15 обязан запрещать `forEach`. Полный прогон на таком неверном продукте дал `rc=0`: `control_green=true; facts: 4 True; клетки: 41/41 REJECTED_EXACT`.

Причина: `control_reasons()` проверяет только наличие токенов в разделе, а докстринг батареи прямо объявляет, что «Парсер ... судит грамматику маркеров» и «НЕ интерпретирует код». Норма контракта требует не только якорей, но и содержания §13–19; отрицание/разрешение запрещённой операции остаётся неотличимо от корректной нормы. Следовательно, проверка пропускает обманную реализацию «документ существует, но предписывает обратное». Это блокирующий дефект проверки, а не дефект исходной честной реализации.

Позитивный контроль: чистый одноразовый клон объекта с симлинком на предоставленные зависимости — полный `probe.py` rc=0, `control_green=true`, все 4 факта True, 41/41 `REJECTED_EXACT`.

Проверенные классы заглушек (все, кроме найденного документного обхода, отвергнуты):

- инструмент отсутствует (`ESLINT_BIN=definitely-missing-eslint`): rc=1, `LINT_FIXTURES_GUARD=False`, `wired_command_rc=1`;
- зашитое принятие (`isExactly = () => true`): rc=1, `DECOY:runner_blind`;
- пустой вход (`RULE_OF = {}`): rc=1, отсутствуют семь `ok ...`, также `DECOY:runner_blind`;
- правильный ответ не на тот вопрос (`consistent-return` ожидает `complexity`): rc=1, `wired_command_rc=1` и `wired_command_no_ok:consistent-return`;
- нейтрализация одного правила (per-file `complexity: off` для `server/src/http.js`): rc=1, `SCOPE_BEHAVIOR_SILENT:complexity` и `SCOPE_CONFIG_DRIFT:server/src/http.js:complexity`;
- пустой выбор клетки `--case nonexistent`: rc=2, `115 UNMEASURABLE: EMPTY_SELECTION`.

Дополнительные scoped-проверки исходного объекта:

- frozen-батарея и контракт относительно `frozen/contracts/115/1`: rc=0;
- область diff: только 24 разрешённых пути; `git diff --check`: rc=0;
- `npm run -s lint`: rc=0;
- `npm run -s test:standards-lint`: rc=0, семь строк `ok`;
- `npm test`: rc=0, 63 pass;
- `python3 tests/tools/run_backend_ci.py --lane checks`: rc=0.
