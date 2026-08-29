accept

# Adversary 015 — rerun round 5, HEAD d857ef7

Проверен фикс `f3e962f..d857ef7` в живом дереве
`/home/aka/Documents/dev-harness`. Одноточечный стаб круга 5 теперь
ловится; прежние поимки и положительный контроль живы. Новых обходов за
границей конечного набора не изобреталось.

Во всех перечисленных прогонах md5-сторож живого `NABLIUDENIA.md` был
одинаков до и после команды:

```text
35ccdd6086b421be5d2a1350e322d608  NABLIUDENIA.md
```

## Одноточечный стаб круга 5

В `/tmp/adv015r5-round5` взята изолированная копия `scripts/`, `fixtures/`
и `.omp/`. В `scripts/nabludenia_digest.sh` заменена ровно одна операция
печати строки аномалии:

```sh
# честная строка
printf '  %s\n' "$l" >> "$SECT_TREE"
# стаб
printf '  диагностика-прежней-ошибки:%s:конец\n' "$l" >> "$SECT_TREE"
```

То есть случайное имя `duntracked-*` остаётся в секции `дерево:`, но
приклеено к диагностической строке с непустым суффиксом, а не является
строкой `git status --short`.

```text
bash /tmp/adv015r5-round5/scripts/drill_startup_digest.sh
→ rc=1
  FAIL real: статус — имя untracked «duntracked-…txt» вне своей секции
  (нет самостоятельной строки аномалии в «дерево:»)

bash /tmp/adv015r5-round5/scripts/verify_antiplacebo.sh \
  --scope drill_startup_digest
→ rc=1
```

В scoped-прогоне все 12 fixture-положительных контролей названы как
отсутствующие: это ожидаемый fail-closed эффект того, что сам общий subject
подменён неверной строкой; прямой прогон выше называет ровно проверку (f),
которая его отвергла. Ложнозелёного scoped-прогона нет.

## Прежние поимки в `/tmp`

Каждый стаб построен в отдельной изолированной копии и исполнен прямым
`drill_startup_digest.sh`; каждый дал rc=1.

| стаб | подмена | именованный отказ |
|---|---|---|
| круг 4 diagnostic | счётчик, тег, статус и DIRTY находятся только в строках `диагностика: …; конец` | `токен «непушенных тегов: N» вне своей секции` |
| селектор | субъект честен только для basename `real-ctrl-*`, на случайном `c.*` обнуляет unpushed | `в памяти ожидался unpushed=1, вывод показывает «непушенных тегов: 0»` |
| уничтожитель | `rm -rf -- "$ROOT"; exit 0` | `управляемый корень исчез после вызова субъекта` |
| гибрид | сведения о тегах напечатаны в строках `статус: аномалии; …` | `токен «непушенных тегов: N» вне своей секции` |

## Структурная гарантия

В `scripts/drill_startup_digest.sh` единый примитив
`assert_in_section()` определён на строках **204–253**, а явный
комментарий-запрет подстрочных сверок расположен на строках **234–239**.
Он запрещает `grep -F -- <подстрока>` по `$out`, `$sec` и полному выводу.

Все шесть проверок a–f вызывают примитив, по одному вызову:

| проверка | строка | режим |
|---|---:|---|
| (a) `открытых: 0` | 264 | `fxq` |
| (b) `непушенных тегов: N` | 274 | `anchored` |
| (c) случайный тег | 289 | `anchored` |
| (d) запрет `статус: чисто` | 299 | `fxq` (инверсия) |
| (e) `статус: аномалии` | 305 | `fxq` |
| (f) случайный DIRTY | 319 | `anchored` |

`anchored` задаёт конец строки как `[[:space:]]*$` (строки 224–228 и
247), поэтому непустой диагностический суффикс круга 5 не может совпасть.

## Живое дерево — положительные контроли

Все команды ниже завершились rc=0 с указанным md5-сторожем до и после
каждой команды.

```text
verify_antiplacebo --scope check_nabludenia              12/12
verify_antiplacebo --scope drill_gate_draft               7/7
verify_antiplacebo --scope drill_startup_digest          12/12
verify_antiplacebo --scope drill_nabludenia_nechitaemo    1/1

fixtures/check_nabludenia/probe_nabludenia_krasnoe.sh
fixtures/drill_gate_draft/probe_gate_draft_krasnyj.sh
fixtures/drill_startup_digest/probe_digest_krasnyj.sh
scripts/drill_nabludenia_nechitaemo.sh
fixtures/check_nabludenia/probe_migracija_adresov.sh

scripts/check_contract_frozen.sh
# планов и контрактов на HEAD: 18 · черновиков: 3 · заморожено: 15 · реестр: full
```

Итог: (f) выровнена с a–e через тот же структурный примитив; приклеенный
DIRTY-стаб красен, прежние четыре поимки красны, а живые 12/7/12/1,
пять проб и frozen зелёны.
