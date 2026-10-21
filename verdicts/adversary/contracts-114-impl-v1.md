FAIL

Объект: fd218d414ad46d7cc54147a7718acf954511b3bb.

Найдено два воспроизведённых нарушения замороженного контракта 114.

1. Пропущено каноническое требование к числу наблюдений в TSV.

Канон `frozen/contracts/114/1` прямо определяет `n` как число наблюдений ключа (строки 48–52) и в живой приёмке требует: `n≥8` у step и `n≥20` у legkij (строки 347–348). В HEAD все 65 строк `registry/ci-zamery.tsv` содержат ровно `n=5`:

```
python3 -c "from collections import Counter; r=[x.split('\\t') for x in open('registry/ci-zamery.tsv') if x and not x.startswith('#')]; c=Counter(int(x[2]) for x in r); print('rows=%d n_values=%s step_n_min=%d legkij_n_min=%d' % (len(r),dict(sorted(c.items())),min(int(x[2]) for x in r if x[0].startswith('check:') or x[0].startswith('drill:')),min(int(x[2]) for x in r)))"
# rows=65 n_values={5: 65} step_n_min=5 legkij_n_min=5
```

Это не только старый TSV: живой сетевой запуск реального `scripts/measure_ci_weights.sh` записал `/tmp/dev-harness-verify/Adv114/live.tsv` с `65` ключами, окном `39519086646`; `diff -u registry/ci-zamery.tsv /tmp/dev-harness-verify/Adv114/live.tsv` дал rc 0. Причина в реализации наблюдаема в `measure_ci_weights.sh`: третье поле строится как `len(last)`, где `last = o[-min_obs:]`; при умолчании это всегда 5 и стирает число доступных наблюдений.

При этом именно состояние с нарушенным `n` зелёное у всех относящихся барьеров:

```
bash fixtures/_krasnye_114.sh
# rc 0; батарея 114: клеток 35, зелёных 35, красных 0
bash scripts/check_ci_weights.sh
# rc 0; ok: веса по замеру: 65 ключей
bash scripts/check_ci_weights.sh --migrate --base /tmp/dev-harness-verify/Adv114/base114.tsv
# rc 0; ok: веса по замеру (миграция): 65 ключей
```

Гвард проверяет третье поле лишь как `isdigit()`, а батарея проверяет только размер использованного медианного окна. Поэтому она не предъявляет красным требование sourceCanon о числе наблюдений, и зелёный результат не доказывает объявленную достаточность выборки.

2. Отсутствующий `gh` не получает обязательного именованного rc 2.

Контракт требует при отказе транспорта `rc 2` с `gh api отказ (…)`. На живом скрипте я оставил в PATH только `bash` и `python3`, без `gh`, и вызвал сетевую ветвь:

```
PATH=/tmp/dev-harness-verify/Adv114/nogh bash scripts/measure_ci_weights.sh --repo toy/ci --out /tmp/dev-harness-verify/Adv114/nogh.tsv
# rc 1
# Traceback ... FileNotFoundError: [Errno 2] No such file or directory: 'gh'
```

`subprocess.run(['gh', ...])` не перехватывает `FileNotFoundError`, так что контрактный rc/диагноз не соблюдён; т17 проверяет только работоспособный gh-двойник и этот путь не наблюдает.

Прочие атакованные классы не дали обхода: отказ-127 меры был пойман батареей (rc 1, 10 красных), s5/s6 пойманы на max/floor, s9 на TSV без источника, t16 на изменении lanes, а s11 (побочная запись только вне корпус/default) дал rc 1 и ровно т19/т20/т21 красные. Живой замер совпал с закоммиченным TSV побайтно; сверены числа отчёта: 65 ключей, 38 изменённых весов, sum(весов)=sum(TSV)=2128. `gen_ci_steps --check`, `verify_ci_parity`, обе батареи 083/087 и неизменность `gen_ci_steps.sh`/`ci_vesa.sh`/`run_ci_lane.sh` относительно базы прошли.

Исправление за implementer/architect: сохранять в `<n>` фактическое число доступных наблюдений и добавить красную клетку с минимумами 8/20; перехватывать отсутствие `gh` и возвращать именованный rc 2, с красной клеткой PATH без gh.
