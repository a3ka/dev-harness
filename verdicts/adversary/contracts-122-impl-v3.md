FAIL
ОБХОД НАЙДЕН: батарея не исполняет отдельно ветвь `--freeze` для variable-only контракта, когда `gh variable list` сломан. z3 объявляет secret+variable, но его `gh` ломается уже на secret; z6 изолирует отсутствие variable только при успешном `gh variable list`. Поэтому обманная заглушка, которая сохраняет честную модель во всех покрытых случаях, но для variable-only контракта считает ошибку `gh variable list` успехом, проходит всю батарею.

Прогоны (одноразовый клон):
- `PYTHONDONTWRITEBYTECODE=1 bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh` — rc=0, `клеток 46, зелёных 46, красных 0`.
- `PYTHONDONTWRITEBYTECODE=1 bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model` — rc=0, `клеток 46, зелёных 46, красных 0` (позитивный контроль).
- Новый мутант `/tmp/dev-harness-verify/Adv122c-variable-gh-bypass.sh` через `CI_PROEKTA_122_GATES=… red_ci_proekta_122.sh --model` — rc=0, `46/46`; он пропускает только ошибку inventory variable-only.
- Исходный мутант `stab_predposylki_freeze_bez_variable.sh` — rc=1, `45/46`, красна ровно `z6-variable-ne-zavedena`; усиление прошлого круга работает.
- Минимальный variable-only мир с `gh` на PATH, возвращающим 127: честная модель — rc=1, `gh-nedostupen`; субъект OBJECT — rc=1, `gh-nedostupen: gh variable list rc=127`; обманная заглушка — rc=0, `PREDPOSYLKI_OK secrets=0 variables=1 environments=0 settings=0`.

Контракт требует при `--freeze` fail-closed для сломанного `gh` и отдельно обязывает каждый declared variable существовать. Требуется отдельная отрицательная клетка: variable-only `ПРЕДПОСЫЛКИ`, `gh variable list` возвращает ненулевой rc (в частности 127), ожидание rc=1 и `gh-nedostupen`. До неё ошибочная реализация проходит батарею.
