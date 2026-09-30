FAIL

# Adversary 064 — круг 1: раскрытие `${HOME}` рантаймом proxy учёта

## Стенограммы шапки

- Детектор перед кругом: rc 0; основной checkout чист, `HEAD 53e2a0b = origin`, snapshot rc 0.
- CI-гейт перед кругом: последний завершённый `799f697`, 6/6 success; прогон для `53e2a0b` был начат, ожидания не было.
- Предмет: `frozen/contracts/064/1` (`frozen/064/1`); исходник — `scripts/proxy/metering_proxy.ts`, семейный барьер — `scripts/check_metering.sh`, красная фикстура — `fixtures/check_metering/red_home_raskrytie_064.sh`.

## Положительный контроль

На честной реализации:

| Команда | rc | Наблюдение |
|---|---:|---|
| `bash fixtures/check_metering/red_home_raskrytie_064.sh` | 0 | ЗК зелёный; С1--С4 пойманы; обе клетки боли зелёные. |
| `npm run metering:selftest` | 0 | `selftest OK`. |
| `bash scripts/check_metering.sh` | 0 | Все 16 ветвей, включая (н), зелёные. |
| `npm run check:gen` | 0 | `харнес соответствует roles/ (9 ролей)`. |
| `git diff --exit-code frozen/contracts/064/1 -- contracts/064-raskrytie-home-rantajmom-proksi-ucheta.md` | 0 | stdout пуст: frozen-diff 064 пуст. |

Проверка PATH отдельно не выдала ложный зелёный: при `env -i PATH=/nonexistent /bin/bash fixtures/check_metering/red_home_raskrytie_064.sh` фикстура остановилась с `NOT_IMPLEMENTED: нет node` и rc 2. Пустой `data_dir` на живом proxy также отказан: `node scripts/proxy/metering_proxy.ts --config tmp/adversary-empty-path.json` → rc 1, `config: data_dir должен быть непустой строкой`.

## Исполненные мутанты

Каждый кодовый мутант жил в отдельной копии дерева; предмет и проверка в назначенном checkout не менялись.

| Мутант | Результат | Ловец |
|---|---|---|
| Раскрытие только в начале строки (`replace(/^\$\{HOME\}/, home)`) | пойман: fixture rc 0, но selftest rc 1 | selftest проверяет `${HOME}` в середине строки. Это нужная независимая пара: семейная фикстура использует только префикс. |
| Раскрытие до проверки с `HOME ?? ''`; пустой результат получает общий отказ | пойман: fixture rc 1 и selftest rc 1 | (б2) требует именованный HOME-отказ; selftest отдельно требует отказ при отсутствующем и пустом HOME. |
| Абсолютный путь без плейсхолдера запрещён | пойман: fixture rc 1 и selftest rc 1 | ЗК на абсолютных путях и selftest (`expandHomePath` без плейсхолдера) требуют прежнее дословное поведение. |
| Фолбэк `HOME → cwd` | пойман | С4 штатной красной фикстуры предъявляет именно этот стаб на `env -u HOME`; нормальный прогон напечатал `ok С4`. |
| Запись `write-before-home-refusal` до именованного отказа | пойман: fixture rc 1; selftest rc 0 | (б2) увидел путь под cwd до отказа. Это показывает, что внешняя клетка нужна: один selftest эту запись не наблюдает. |
| Отказ подменён успешным `process.exit(0)` | пойман: fixture rc 1 | (б2) диагностировал `выход кодом 0 без HOME`. |
| Нейтрализация части поведения: порт раскрыт, секреты/журнал оставлены литеральными | пойман | С3 нормального прогона пойман по POST/журналу, а не по одному порту. |
| Ответ на другой вопрос: data_dir заменён хардкодом дома | пойман | С2 нормального прогона пойман по `.actual_port` вне сгенерированного data_dir. |

## Ускользнувший мутант: раскрывается только первое вхождение

Мутант заменяет ровно одну строку:

```ts
return value.split('${HOME}').join(home)
```

на:

```ts
return value.replace('${HOME}', home)
```

Он нарушает инвариант 1: литеральный `${HOME}` остаётся в строковом поле пути и доходит до `fs.mkdirSync`/`fs.writeFileSync`. Это не гипотеза о статическом тексте: мутант был запущен с `data_dir = "${HOME}/metering/${HOME}"`. Процесс напечатал:

```text
metering_proxy listening on 36139, data_dir=/tmp/dev-harness-verify/adv064c/tmp/adversary-first-home/metering/${HOME}
```

и наблюдаемый файл-порт возник в каталоге с буквальным именем `${HOME}`:

```text
/tmp/dev-harness-verify/adv064c/tmp/adversary-first-home/metering/${HOME}/.actual_port
```

При этом весь предъявленный набор для реализации остался зелёным на этом неверном коде:

| Команда в копии с мутантом | rc |
|---|---:|
| `bash fixtures/check_metering/red_home_raskrytie_064.sh` | 0 |
| `npm run metering:selftest` | 0 |
| `bash scripts/check_metering.sh` | 0 |

Следовательно, проверка не различает корректную реализацию от реализации, которая раскрывает лишь первое из нескольких литеральных вхождений `${HOME}`. С1--С4, ЗК и ветвь (н) предъявляют только один плейсхолдер на поле; selftest предъявляет начало и середину, но тоже только по одному вхождению. Это дефект проверки, а не мутанта.

## Вердикт

`FAIL`: добавить различающий прогон с минимум двумя `${HOME}` в одном из `data_dir`, `secrets_env` или ненулевом `now_file`; он должен требовать отсутствие литеральных байтов `${HOME}` в каждом пути, дошедшем до fs. После исправления проверки требуется повторить этот круг; этот вердикт не закрывает норму.
