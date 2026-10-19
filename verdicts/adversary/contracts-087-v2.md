FAIL
OBJECT=ae7f9bc7b6327c54ca36bdb908f0d48ce477ec48

Блокирующая находка: BUDGET-121 — батарея 087 не проверяет бюджет лёгкой джобы 120 секунд.

В одноразовом клоне строка реестра была единственно изменена:

```text
legkij\tcheck:runner-hygiene\t20\t…
→
legkij\tcheck:runner-hygiene\t21\t…
```

Это делает сумму весов всех строк `legkij` равной 121, то есть нарушает названный предметом предел 120 с. Сырые результаты:

```text
$ python3 -c '...sum(int(x[2]) for x in rows if ... x[0]=="legkij")...'
121

$ bash fixtures/_krasnye_087.sh
ИТОГ 087: клеток ok=103 КРАСНО=0; стаб-пак: поймано 26/26 (subject)
```

Следовательно, неконформная реализация проходит весь обязательный барьер. Это дефект батареи, а не реализации-заглушки. Нужна дифференциальная клетка: сумма весов всех `legkij` ≤ 120, с парой 120 (зелёный) / 121 (красный), и она должна читать ровно тот же реестр, который исполняет workflow.

## Положительный контроль

Честный предмет на закреплённом OBJECT до всех мутаций:

```text
$ bash fixtures/_krasnye_087.sh
ИТОГ 087: клеток ok=103 КРАСНО=0; стаб-пак: поймано 26/26 (subject)
```

Исходный реестр имеет сумму 120:

```text
$ python3 -c '...sum(int(x[2]) for x in rows if ... x[0]=="legkij")...'
120
```

## Пять обходов круга 1 — закрыты

Каждая следующая заведомо негодная мутация была внесена только в одноразовый клон и предъявлена `bash fixtures/_krasnye_087.sh`. Все дали красный именно на соответствующей клетке.

1. `ci_klass.sh`: отсутствие `curl` возвращает rc 1 вместо обязательного rc 2.

```text
КРАСНО: А9 dokaz:net-curl: dokaz без curl: rc 1 ≠ 2; out «»; ОТКАЗ: нет curl — запрос артефактов не сформировать
ИТОГ 087: клеток ok=102 КРАСНО=1; стаб-пак: поймано 26/26 (subject)
```

2. `check_ci_gate.sh`: принимается только точное имя `legkij`, не `legkij (…)`.

```text
КРАСНО: Б1 check_ci_gate:legkij-skobki: check_ci_gate (legkij-skobki): rc 1 ≠ 0; ОТКАЗ: лёгкое задание legkij по c7ecac4adc2f: нет — пропуск тяжёлых джоб без лёгкого зелёного не принимается
ИТОГ 087: клеток ok=102 КРАСНО=1; стаб-пак: поймано 26/26 (subject)
```

3. `check_ci_gate.sh`: сняты обе проверки `total_count > 0`, пустой список check-runs становится успехом.

```text
КРАСНО: Б1 check_ci_gate:pustye-checkrany: check_ci_gate (pustye-checkrany): rc 0 ≠ 1;   ok   CI зелёный: проверок 0, все success, по c7ecac4adc2f (toy/repo)
ИТОГ 087: клеток ok=102 КРАСНО=1; стаб-пак: поймано 26/26 (subject)
```

4. `check_ci_gate.sh`: вместо аргумента `$sha` в `dokaz` передаётся `HEAD` cwd.

```text
КРАСНО: Б1 check_ci_gate:chuzhoj-sha: check_ci_gate (chuzhoj-sha): rc 0 ≠ 1;   ok   CI зелёный: лёгкое по 11a37883fc37, тяжёлое — по кодовому хешу, dokaz f729e5a89541033ef03013ff5ec33a46844d57a2
ИТОГ 087: клеток ok=102 КРАСНО=1; стаб-пак: поймано 26/26 (subject)
```

5. `check_ci_gate.sh`: failure не-лёгкой джобы (`vorota`) игнорируется при skipped тяжёлых.

```text
КРАСНО: Б1 check_ci_gate:vorota-krasnaja: check_ci_gate (vorota-krasnaja): rc 0 ≠ 1;   ok   CI зелёный: лёгкое по c7ecac4adc2f, тяжёлое — по кодовому хешу, dokaz f729e5a89541033ef03013ff5ec33a46844d57a2
ИТОГ 087: клеток ok=102 КРАСНО=1; стаб-пак: поймано 26/26 (subject)
```

## Дополнительные обманные прогоны

Кодовой хеш: из `kod_hash` убран mode файла. Батарея стала красной, в частности:

```text
КРАСНО: А1 K_mode: klass c0 K_mode: rc 0, «uchet» ≠ kod;
ИТОГ 087: клеток ok=85 КРАСНО=18; стаб-пак: поймано 26/26 (subject)
```

Предполёт 071: нейтрализован отказ результата `vorota` (`if false` вместо проверки `vor_rc`). Батарея поймала обе относящиеся ветки:

```text
КРАСНО: Б2 предполёт:kod-bez-pr: предполёт (kod-bez-pr): rc 0 ≠ 1; gitw ПРЕДПОЛЁТ: код-через-PR: ОТКАЗ: код в main только через PR: …
КРАСНО: Б2 предполёт:land-ushjol: предполёт (land-ushjol): rc 0 ≠ 1; gitw ПРЕДПОЛЁТ: код-через-PR: ОТКАЗ: код в main только через PR: …
ИТОГ 087: клеток ok=101 КРАСНО=2; стаб-пак: поймано 26/26 (subject)
```

Strip тяжёлых джоб: все три первых `strip`-шага в `ci.yml` заменены на `true`:

```text
КРАСНО: К4:ci: ci: первый run-шаг 'true' ≠ bash scripts/ci_klass.sh strip ${{ needs.klass.outputs.kod }}
КРАСНО: К4:antiplacebo: antiplacebo: первый run-шаг 'true' ≠ bash scripts/ci_klass.sh strip ${{ needs.klass.outputs.kod }}
КРАСНО: К4:obshchij: obshchij: первый run-шаг 'true' ≠ bash scripts/ci_klass.sh strip ${{ needs.klass.outputs.kod }}
ИТОГ 087: клеток ok=98 КРАСНО=5; стаб-пак: поймано 26/26 (subject)
```

Зона — scoped положительный контроль:

```text
$ npm run check:antiplacebo -- --scope check_zones
SCOPED: барьеров 1 из выборки — не для приёмки
барьеров: 1 · фикстур: 38 · предъявлено красным повторным прогоном: 38
```

## Неблокирующее наблюдение по `dokaz`

Мутант, который принимает artefact без поля `expired` (замена `is not False` на `is True`), также проходит батарею:

```text
$ bash fixtures/_krasnye_087.sh
ИТОГ 087: клеток ok=103 КРАСНО=0; стаб-пак: поймано 26/26 (subject)

$ … CI_KLASS_API=https://api.github.test/repos/toy/repo bash scripts/ci_klass.sh dokaz <sha>
dokaz f729e5a89541033ef03013ff5ec33a46844d57a2
```

Не повышаю его до отдельного блокера: в демаркации контракта API-ответ назван JSON схемы GitHub, где `expired` является полем artefact. Однако буквальная проверка И-3 `expired == false` не имеет клетки на отсутствие поля; её стоит добавить при исправлении BUDGET-121.

Все мутации восстановлены; проверка сохранённых копий дала:

```text
subject-restored
classifier-restored
```
