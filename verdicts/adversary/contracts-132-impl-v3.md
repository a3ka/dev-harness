FAIL
OBJECT=5f547cedc0d898951892ac96a86fdfddfc7e81af

# Суд реализации 132 ekran-shablon — круг 3

## Блокер 1 — настоящий раннер 123 принимает другой манифест вместо манифеста пачки

На отдельном свежем входе, построенном именно `probe.build_pack` и
`probe.build_repo`, в `repo/podmena/kadry.json` записана копия
`pack/kadry.json` с заменённым только `_comment` на
`podmena: not the pack manifest`. В `pack/ekran.json` единственная правка:

```json
"sverka": "python3 .harness123/scripts/sverka_maketa.py --manifest podmena/kadry.json --kadry mobile/maestro-out-demo --repo ."
```

Это байт-идентичный раннер 123, обычный e2e перед ним исполняется и создаёт
свежие кадры. Однако `--manifest` указывает не на манифест кадров судимой
пачки (`pack/kadry.json`), а на посторонний файл продукта. Прямой CLI живого
субъекта дал:

```text
rc=0
KADR	Splash dark	0.783	0.600	tagline	OK
KADR	Splash light	0.782	0.600	tagline	OK
SHABLON	demo-vkhod	OK
```

Значит, зелёный результат получен при ответе раннера на другой вопрос. Это
нарушает контракт 132, инвариант 4 и §З: сверка должна быть вызвана раннером
123 **по манифесту кадров пачки**. Копия здесь намеренно сохранила рабочую
семантику, чтобы изолировать дефект связи argv: путь отличен от манифеста
пачки, но stdout не даёт валидатору заметить подмену. Та же дыра позволяет
подставить иной допустимый манифест с совпадающим выводом.

Причина: `_argv_rannera123` проверяет только наличие трёх флагов и непустые
значения, а `run_priemka_sverka` проверяет sha файла раннера, но не связывает
`--manifest`, `--kadry` и `--repo` с `pack/f['kadry']`,
`repo/f['kadry_dir']` и переданным `repo`. В результате подмена не является
`SAMODELNAYA_SVERKA`.

## Закрытие блокера круга 2 и прямые контроли

Все перечисленные ниже состояния также строились на новых
`build_pack`/`build_repo` и запускались прямым CLI. Реализация и эталон
`model/ekran_shablon.py` дали одинаковые `(rc, stdout, stderr)` на каждом из
них.

| Состояние | Наблюдение |
|---|---|
| Самодельный `podmena/scripts/sverka_maketa.py` с константными строками честного вывода | `rc=1`, `SAMODELNAYA_SVERKA файл не раннер 123` |
| Честный относительный вызов | `rc=0`, `SHABLON demo-vkhod OK` |
| Честный абсолютный путь к `.harness123/scripts/sverka_maketa.py` | `rc=0`, `SHABLON demo-vkhod OK` |
| Байт-в-байт копия раннера | `rc=0`, `SHABLON demo-vkhod OK` |
| Симлинк на раннер | `rc=0`, `SHABLON demo-vkhod OK` |
| Не существующий файл сверки | `rc=1`, `SAMODELNAYA_SVERKA вывод не воспроизводит механизм 123` |
| e2e-инструмент вне PATH (`not-on-path`) | `rc=1`, `E2E_NE_PROSHLA FileNotFoundError(2, ...)` |
| Пустой `kadry` | `rc=2`, `SHABLON_NEVEREN kadry: не список кадров` |

Положительный контроль — честный свежий вход — зелёный. Его реальный
sha256-пин манифеста (`4a17e3a4c3888343490f73c037688a7d6522e5fac1919126265c7414f26c976c`)
длиннее 16 и содержит буквы; он не был принят за размерный литерал.

## Батарея, модель и зона

Исполнены меры оркестратора на объекте:

| Команда | Результат |
|---|---|
| `bash fixtures/workshop_project/ekran_shablon_132/red_ekran_shablon_132.sh` | `rc=0`, 38 `CASE … ok` |
| `…red_ekran_shablon_132.sh --model` | `rc=0`, 38 `CASE … ok` |
| `…red_ekran_shablon_132.sh --stabs` | `rc=0`, 38 `CASE … ok`, 35 `STAB … KRASEN`, `SVJAZI 35` |
| `python3 fixtures/workshop_project/ekran_shablon_132/probe.py` | `rc=0`, 38 `CASE … ok` |

Внебатарейный прямой набор выше (путь раннера: относительный, абсолютный,
копия, симлинк; подмена по имени; отсутствующий инструмент; пустой манифест;
чужой манифест) не показал расхождения `scripts/ekran_shablon.py` с эталоном:
все результаты совпали. Следовательно, блокер — общий дефект модели и
реализации, а не различие их поведения.

Проверка зоны: `git diff --name-only 514bc758a HEAD` вывела ровно
`scripts/ekran_shablon.py`.
