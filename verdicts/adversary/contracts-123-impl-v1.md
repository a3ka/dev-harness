FAIL

Обход проводки: батарея проверяет только отдельный `scripts/sverka_maketa.py` на синтетических входах; она не проверяет, что android-e2e вообще создаёт кадры по раскладке, которую затем читает шаг 123. Поэтому все 29 случаев и матрица могут быть зелёными, хотя предмет — реальная сверка кадров с макетом в CI — не исполняется на снимках 117.

Наблюдаемый контрпример (без GitHub): в продуктовой ветке единственный вызов `maestro_probe.py` публикует `--out ${{ github.workspace }}/mobile/maestro-out`; его исходник и `mobile/scripts/ci-e2e.sh` используют соответственно `maestro-out` и `--test-output-dir maestro-out`. Шаг 123 вместо этого читает `mobile/maestro-out-117`. Такого каталога в продукте нет. В `mobile/.maestro/` также нет `vkhod-117-splash-vhod.yaml` (есть только cmp-mob-002-tabs.yaml, cmp-mob-004-start.yaml, rehearsal.yaml, start.yaml), поэтому текущий прогон не создаёт четыре объявленных снимка 117.

Исполнен точный pipeline шага 123 в локальном клоне продукта (без сети):
`set -o pipefail; python3 ../scripts/sverka_maketa.py --manifest ../fixtures/workshop_project/mob_sverka_123/kadry_117.json --kadry mobile/maestro-out-117 --repo . | tee mobile/maestro-out-117/sverka-123.tsv`
rc=1; stderr: `tee: mobile/maestro-out-117/sverka-123.tsv: No such file or directory`, затем четыре отказа `KADR_OTSUTSTVUET` для Splash dark, Splash light, First-Run dark и First-Run light. Следовательно CI не получает ни кадры 117, ни требуемый TSV с четырьмя строками KADR; проверка падает до содержательной сверки.

Положительный контроль и батарея на дереве реализации:
- `python3 fixtures/workshop_project/mob_sverka_123/probe.py` — rc=0, 29/29 CASE ok.
- `python3 fixtures/workshop_project/mob_sverka_123/probe.py --model` — rc=0, 29/29 CASE ok.
- `python3 fixtures/workshop_project/mob_sverka_123/probe.py --matrix` — rc=0: 29 CONTROL ok; все 32 связи 19 стабов KRASEN.
- Независимый отказ-как-успех: временный субъект `sys.exit(127)` под `probe.py --subject` — rc=1; все 29 CASE красные с фактическим rc=127. Стаб удалён после прогона.

Проверены обязательные классы стабов в matrix: константы/всегда-зелёный (s01/s04), пустой вход (s06/s08/s09), неверный вопрос/только G (s11/s14/s18), нейтрализация масок/допуска/пина/покрытия (s05/s07/s12/s13/s19), грамматика и glob (s16/s17). Все были отвергнуты. Внешний инструмент/PATH не является зависимостью предмета: субъект и probe запускают Python stdlib напрямую (`sys.executable`), внешних утилит для меры нет.

Требуемая правка за implementer: восстановить/добавить запуск flow 117 и согласовать единственный фактический каталог его скриншотов с `--kadry` и местом TSV; затем доказать положительную и отрицательную CI-пары из критерия 5.