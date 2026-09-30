accept

# Reviewer 064: круг 3, Р-1′ закрыт пином

Предмет: `frozen/contracts/064/1`, `contracts/064-raskrytie-home-rantajmom-proksi-ucheta.md`. Файл совпадает
с frozen: `git diff --exit-code frozen/contracts/064/1 -- contracts/064-…md` дал пустой вывод, rc 0.
Судимый HEAD: `a8a6404` (ленд `8840f44`, implementer). Клон суда: `/tmp/dev-harness-verify/rev064k3c`.
Своя мера снята в выбрасываемом клоне `rev064k3c-m1`, куда мутант наложен `git apply` патча, и в
каталоге проб `rev064k3c-p`. Патч и конфиги написаны инструментом записи, интерпретаторы для записи не
использовались. В клоне суда правился только этот файл.

| артефакт | коммит | блоб HEAD |
|---|---|---|
| `scripts/proxy/metering_proxy.ts` | `8840f44` (implementer), ленд `a8a6404` | `078bb50` |
| `scripts/check_metering.sh` | не тронут с круга 1 | `e6e99e9` |
| `fixtures/check_metering/red_home_raskrytie_064.sh` | не тронута с круга 1 | `d711f1d` |

Вердикт связан с этими блобами. Новая редакция любого из них принятие не наследует.

## Стенограммы спавна (слово оркестратора)

- Детектор: rc 0, локально, батч-режим.
- CI-гейт: последний завершённый прогон 6/6.
- Приёмка судьи: Н-48 scoped.
- Поле 064 не менялось после `a8a6404`: HEAD клона суда и есть `a8a6404`. Между кругом 2 (`aa63f3f`) и
  `a8a6404` поле тронуто одним коммитом `8840f44` (+36 строк в `metering_proxy.ts`). Кроме него вошли
  только вердикты (`verdicts/review/contracts-064-v2.md`, `verdicts/adversary/contracts-065-v2.md`).
  `git diff --stat 50f5cbc a8a6404 -- fixtures/check_metering scripts/check_metering.sh contracts/064-…md
  config/metering.json roles .omp/agents` дал пустой вывод, rc 0.
- Коммит `8840f44` ссылается на вердикт `410f5d4`. Это коммит круга 2 до ленда: блоб
  `contracts-064-v2.md` у `410f5d4` и `195edf3` один и тот же, `a6c8b53`.

## Сырой вывод: мой прогон на `a8a6404`

```text
$ npm run -s metering:selftest
selftest OK
RC_SELFTEST=0
$ bash fixtures/check_metering/red_home_raskrytie_064.sh
  ok   С3: стаб «порт-только» пойман — секреты/журнал не раскрыты
  ok   С4: стаб «cwd-фолбэк» пойман — при env -u HOME старт не отказан
ok: 064 — ${HOME} раскрывается рантаймом, в т.ч. ДВА вхождения в одном поле; отсутствующий HOME отказает старт (ЗК зелёный, С1-С4 пойманы, все ТРИ клетки боли зелёные)
RC_RED064=0
$ bash scripts/check_metering.sh
  ok   н
барьер зелёный: 16 ветвей пройдены
RC_CHECK_METERING=0
$ npm run -s check:gen
харнес соответствует roles/ (9 ролей)
RC_GEN=0
$ bash scripts/check_zones.sh .
замороженных контрактов: 64 · объявленных авторов: 1 · коммитов в диапазонах: 3082 · проверено по зонам: 1520
RC_ZONES=0
$ git diff --exit-code frozen/contracts/064/1 -- contracts/064-raskrytie-home-rantajmom-proksi-ucheta.md
RC_FROZEN=0   (пусто)

# Живая проба ddonly: secrets_env абсолютный, ${HOME} только в data_dir
$ env -u HOME timeout 5 node …/rev064k3c/scripts/proxy/metering_proxy.ts --config ddonly.json
proxy: невалидный конфиг — config: data_dir: переменная HOME отсутствует или пуста — именованный отказ старта
RC_DDONLY=1
$ ls -A rev064k3c-p   → ddonly.json m1.patch secrets.env   (под cwd ничего не выросло)
```

Ветви барьера посчитаны своей мерой, а не по строке автора «16 ветвей». Итоговые строки веток,
`grep -E '^ *ok +[^ :]+$' | wc -l`, дали 16: а б в в2 г г2 д е ж з и к1 к2 л м н.

## Р-1′: красное предъявлено (мутант m1)

Выбрасываемый клон `rev064k3c-m1` на `a8a6404`. Мутант — откат порядка в `expandHomePath`: проверка
HOME стоит раньше проверки плейсхолдера. Это та же форма, что m1 круга 2:

```diff
 export function expandHomePath(value: string, fieldName: string): string {
-  if (!value.includes('${HOME}')) return value
   const home = process.env.HOME
   if (home === undefined || home === '') {
     throw new Error(`config: ${fieldName}: переменная HOME отсутствует или пуста — именованный отказ старта`)
   }
+  if (!value.includes('${HOME}')) return value
   return value.split('${HOME}').join(home)
 }
```

```text
$ node scripts/proxy/metering_proxy.ts --selftest          (m1)
selftest FAIL: home: dd-only — отказ должен назвать data_dir, а не secrets_env; фактически: config: secrets_env: переменная HOME отсутствует или пуста — именованный отказ старта
RC_M1_SELFTEST=1
$ env -u HOME timeout 5 node …/rev064k3c-m1/…/metering_proxy.ts --config ddonly.json
proxy: невалидный конфиг — config: secrets_env: переменная HOME отсутствует или пуста — именованный отказ старта
RC_M1_DDONLY=1
$ bash scripts/check_metering.sh                             (m1)  → RC_M1_CHECK=0
$ bash fixtures/check_metering/red_home_raskrytie_064.sh     (m1)  → RC_M1_RED064=0
```

На m1 краснеет ровно новая проверка, и её строка FAIL в выводе единственная. Круг 2 на том же
мутанте получил `RC_M1_SELFTEST=0`, теперь 1. `check_metering` и red-064 на m1 остаются зелёными, как
и в круге 2. Условие закрытия этого не требовало: пин стоит в selftest, а selftest — живой CI-шаг
предмета (`.github/workflows/ci.yml:426`, `npm run metering:selftest`; контракт :26-29, :139-146).
На честном HEAD та же проверка зелёная (`selftest OK`), то есть проверка честная: красная на откате,
зелёная на исправлении.

Условие Р-1′ из круга 2 сверено по пунктам с `8840f44` (`metering_proxy.ts:1280-1315`):

- `secrets_env` абсолютный (`sec`), `${HOME}` стоит только в `data_dir`. Есть.
- Сначала при заданной HOME `data_dir` раскрывается в `${fakeHome}/…`. Это положительная половина,
  без неё пин мог бы пройти на вечном отказе. Есть.
- HOME удалён, `loadConfig` обязан отказать. Проверяются и пустое сообщение, и сообщение, в котором
  есть `data_dir` и нет `secrets_env`. Есть.
- HOME восстанавливает существующий `finally` секции. Есть.
- Красный прогон на m1 предъявлен выше. Есть.

## Область, атомарность, проверка не переписана

- `8840f44` (implementer) трогает ровно `scripts/proxy/metering_proxy.ts`, это его зона. Коммит один, с
  одной задачей (Р-1′), в сообщении ссылка на вердикт. `check_zones` дал rc 0.
- Фикстуру, барьер и контракт implementer не трогал: последний коммит в `fixtures/check_metering` и
  `scripts/check_metering.sh` — `38d9b80` от architect. Норма не тронута.
- Счёт снят своей мерой (awk от `export function selftest` до закрывающей `}`). На `c7a8519` в
  `selftest()` было 359 строк, на HEAD 395 (+36, совпадает с diffstat). Маркеров `// ──` было 7, стало 8.
  Новый маркер (:1280) лежит внутри секции 064 (:1177) с отступом на уровень глубже, так что
  секций верхнего уровня по-прежнему 7. Вызовов `loadConfig(` было 10, стало 12 (+2: раскрытие и отказ).
  Приёмочная строка 2 («шесть проверок») по составу не меняется: добавлен вход в существующую
  проверку раскрытия, новой проверки нет.

## Находки

### Блокирующие

Нет.

### Закрытые

- [x] **Р-1′.** Различающий пин в selftest, красный на m1 (см. выше).
- [x] **Р-1.** Поведение (круг 2) и теперь пин.
- [x] **Р-2.** Закрыт в круге 2, блоб с тех пор изменился только вставкой Р-1′.

### Вопрос владельцу (без изменений)

- [ ] **В-1.** Полностью абсолютный конфиг без HOME стартует (доконтрактное поведение). Проверки,
  которая фиксирует этот выбор, нет. Если владелец подтвердит вариант, пин его одним входом. Это совет.

### Неблокирующие (перенесены из круга 2, в этом круге не менялись)

- [ ] **З-1.** Латентный ложный красный Б3 на `//` (`red_home_raskrytie_064.sh:122`). Зона architect.
- [ ] **З-2.** `branch_н` печатает раскрытый `${HOME}`: в этом прогоне `ok н: /tmp/dev-harness-verify/rev064k3c/tmp/metering.4q…`.
  Зона implementer.
- [ ] **З-3.** Метка Б3 зашита гипотезой «только ПЕРВОЕ вхождение». Зона architect.
- [ ] **З-4, З-5, З-6.** Тексты: контракт §Риски, ЭНФОРСМЕНТ «г4», метка норма-строки. Советы к
  следующей версии.

## Паразитная сложность (050): по артефакту диффа `8840f44`

| артефакт | (1) свойство | (2) состояние | (3) файлы вместе | (4) глубина | (5) потребитель / повтор | класс |
|---|---|---|---|---|---|---|
| вход dd-only в секции 064 selftest (+36 строк, +2 `loadConfig`) | инв. 4 «именованный отказ старта с именем поля», когда плейсхолдер стоит не в первом поле; условие закрытия Р-1′ | временный `home-dd-only.json` в `tmp` selftest; `process.env.HOME` меняется явно и восстанавливается существующим `finally`; результат виден строкой FAIL | 1 (не выросло) | интерфейс selftest прежний (флаг, rc 0/1), нового флага, env и файла состояния нет | CI-шаг `npm run metering:selftest` (ci.yml:426), приёмочная строка 2; грамматику не повторяет, зовёт тот же `loadConfig` | ESSENTIAL |

Более простой формы нет. Без входа «`${HOME}` не в первом поле» m1 проходит selftest с rc 0 (круг 2).

## Вердикт

**accept.** Р-1′ закрыт: пин различает честный код (selftest rc 0) и откат m1 (selftest rc 1 именно на
новой проверке). Живая проба ddonly называет `data_dir`. red-064 rc 0, `check_metering` 16 ветвей rc 0,
`check:gen` rc 0, `check_zones` rc 0, frozen-diff пуст. Область, зона и атомарность соблюдены, проверки
и норма не тронуты. Блокирующих находок нет. Открыты неблокирующие З-1…З-6 и вопрос В-1 владельцу.
