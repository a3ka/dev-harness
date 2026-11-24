FAIL
OBJECT=3ca9ae82d6449f193e6048bd21aa276b5c687019
СУД: repo=dev-harness; предмет=217; фаза=v1; роль=critic; вызов=1/2 (полный); модель-план=openai-codex/gpt-6.1-terra (штатный тир apex-sol); сессия=Crit217; модель-факт=openai-codex/gpt-6.1-terra (метаданные запуска); SHA=3ca9ae82d6449f193e6048bd21aa276b5c687019; предыдущий=нет; исключение=нет; класс риска=рисковый; независимость: автор Architect217 — другая модель/сессия.

## Карта классов
К-01: чисто — check_sdacha --run rc 0 и pre_critic rc 0
К-02: чисто — вход owner-затравка 217 в 4487181453d713b975740c71b7b7504eca6b616d и ROADMAP.md:533
К-03: чисто — вход 083 113 200 207 210 и 992 в контракте и --context rc 0
К-04: чисто — вход --context rc 0 и зоны contracts/217-incr-pustoe-okno.md:76-165
К-05: чисто — вход приёмка contracts/217-incr-pustoe-okno.md:51-55
К-06: чисто — вход probe.py:375-438 и раздел угроз контракта
К-07: чисто — W --model rc 0 и W --repo . rc 1 до реализации
К-08: блок — пустой путь не проверяет вызов атомарного писателя
К-09: блок — пустой путь не проверяет вызов атомарного писателя
К-10: блок — пустой путь не проверяет вызов атомарного писателя
К-11: чисто — вход probe.py:239-273 и зафиксированный базовый объект
К-12: чисто — вход probe.py:226-235 и JSON Trace2 Git
К-13: н/п — секреты отсутствуют в синтетических мирах
К-14: чисто — вход противопоставленные клетки cells в probe.py:95-120
К-15: чисто — W --model rc 0 и W --stabs rc 0
К-16: чисто — вход contracts/217-incr-pustoe-okno.md:4 и 60-74
К-17: н/п — станционный guard без проектной архитектурной модели 188

## Блоки

БЛОКИРУЕТ contracts/217-incr-pustoe-okno.md:39,51 — пустой путь не проверяет вызов атомарного писателя (К-08/К-09/К-10).
ОБЯЗАТЕЛЬСТВО: И1 требует после пустого окна кеш полный HEAD + LF именно через существующий `incr_finish`; это не просто требование равенства уже записанного значения. Конформный вход — поддерживаемый lib_incr кеш-предок (строка 74).
СОСТОЯНИЕ: исходная операция `incr_finish 0` в обязательной модели `fixtures/workshop_project/incr_pustoe_okno_217/model/empty_window.sh:4` удалена в одноразовом клоне. На поддерживаемом вызове cache содержит текущий SHA без завершающего LF: `scripts/lib_incr.sh:143-144` читает первую строку и принимает SHA, то есть база успешно проверена и равна HEAD. Такой файл создаётся обычной записью `printf %s "$sha"` и не является отсутствующим или повреждённым по действующему парсеру.
НАБЛЮДЕНИЕ: вся батарея `W --model` на мутанте возвращает rc 0 и 25/25 зелёных, поскольку все её пустые миры заранее содержат `(HEAD + LF)` (`probe.py:170`), и удаление записи незаметно. Отдельный Git-мир с тем же мутантом дал `subject_rc= 0 cache_has_lf= False cache_bytes= b'86df19b2a52dddc1eabc6d83b7871ec2360b09ca'`: требуемого HEAD + LF и вызова писателя нет. Даже при полностью каноническом исходном кеше отсутствие предписанного вызова не различается приёмкой.
ОБХОД: реализация без `incr_finish 0` в пустой ветви проходит `W --repo` на тех же мирах, хотя не исполняет И1. Закрывающее свойство: различающая проверка действия штатного атомарного писателя на пустом окне, включая вход, принимаемый действующим парсером и требующий нормализации, не подменяя её только сравнением заранее идентичных байтов. Стаб должен адресно удалять именно вызов пустой ветви, а не общий писатель для непустого окна.

## Проверки и атаки

Первым запущен `bash scripts/check_sdacha.sh "$PWD" contracts/217-incr-pustoe-okno.md --run`: rc 0, сырой итог `СДАЧА: лист зелёный (двери=15 карта=17/17 дельта=0)`. `bash scripts/pre_critic.sh contracts/217-incr-pustoe-okno.md`: rc 0, `КРИТИК: дверь зелёная`. `bash scripts/check_precision_gate.sh "$PWD" contracts/217-incr-pustoe-okno.md`: rc 0, итог `OK`, но параллельный запуск с общим TMPDIR дал сообщения исчезнувших временных файлов lib_zones; без вывода о чистоте внутренней части этого прогона. Отдельно --context rc 0 напечатал union и frozen-источники. Метаданные кандидата: один коммит architect поверх 4576309b, шесть файлов.

`W --repo .`: rc 1, `KLETKI=25 ZELENYE=20 KRASNYE=5`, красны e1–e5 по BYTES и EMPTY_DISCOVERY. `W --model`: rc 0, `KLETKI=25 ZELENYE=25 KRASNYE=0`. `W --stabs`: rc 0, `MUTACII=14 SVJAZI=17 POIMANY=17 ZHIVYH=0`. Для позеленения production после 210 необходим выход после успешного incr_parse при INCR_MODE=incr и INCR_BASE=INCR_HEAD через incr_finish, до разведки; timeout 60 не меняется. Остальные ветви и батареи 210/113/083 сохраняются.

Независимые мутации выполнялись по одной в собственном .git одноразового клона. Ниже W относится к копии клона, TMPDIR=/tmp/dev-harness-verify/scratch-crit217. Выводы приведены как наблюдавшиеся строки, не как утверждение полного универсального покрытия.

1. Замена сравнения base=head в модели на непустой HEAD, `W --model --cell w1-denied`, rc 1:
```
HISTORY commits=1 documents=3
HISTORY commits=5000 documents=26
w1-denied: rc=0 seconds=0.044 git=3 discovery=0 RED
  CACHE expected=b'86df19b2a52dddc1eabc6d83b7871ec2360b09ca\n' actual=b'09d60501113e9947bf65883fe052a3860271e456\n'
KLETKI=1 ZELENYE=0 KRASNYE=1
```
Также напечатан BYTES с ожидаемым rc 1 и фактическим rc 0. Аналогичный класс присутствует в ALL_WINDOWS архитектора.

2. Удаление `incr_finish 0` только из пустой ветви, `W --model`, rc 0:
```
HISTORY commits=1 documents=3
HISTORY commits=5000 documents=26
e1-empty-small: rc=0 seconds=0.031 git=3 discovery=0 GREEN
e2-empty-5000: rc=0 seconds=0.031 git=3 discovery=0 GREEN
e3-empty-equals: rc=0 seconds=0.034 git=3 discovery=0 GREEN
e4-empty-oracle: rc=0 seconds=0.048 git=3 discovery=0 GREEN
e5-empty-old-violation: rc=0 seconds=0.036 git=3 discovery=0 GREEN
KLETKI=25 ZELENYE=25 KRASNYE=0
```
Дополнительный вызов того же мутанта в отдельном Git-мире с cache без LF: rc 0, сырой вывод `HISTORY commits=1 documents=3` и `subject_rc= 0 cache_has_lf= False cache_bytes= b'86df19b2a52dddc1eabc6d83b7871ec2360b09ca'`.

3. Перед `incr_finish` добавлен `git -C "$ROOT" rev-list --count "$INCR_HEAD" >/dev/null`, `W --model`, rc 0:
```
HISTORY commits=1 documents=3
HISTORY commits=5000 documents=26
e1-empty-small: rc=0 seconds=0.028 git=4 discovery=0 GREEN
e2-empty-5000: rc=0 seconds=0.042 git=4 discovery=0 GREEN
e3-empty-equals: rc=0 seconds=0.050 git=4 discovery=0 GREEN
e4-empty-oracle: rc=0 seconds=0.027 git=4 discovery=0 GREEN
e5-empty-old-violation: rc=0 seconds=0.027 git=4 discovery=0 GREEN
KLETKI=25 ZELENYE=25 KRASNYE=0
```
Это добавленная новая операция, а не замена существующего предметного механизма: по §Порог совет, не самостоятельный блок.

4. Добавлено условие `"${INCR_REST[0]}" != "--oracle"` к предикату, `W --model --cell e4-empty-oracle`, rc 0:
```
HISTORY commits=1 documents=3
HISTORY commits=5000 documents=26
e4-empty-oracle: rc=0 seconds=0.023 git=3 discovery=0 GREEN
KLETKI=1 ZELENYE=1 KRASNYE=0
```
В этом расположении условие не нарушило наблюдаемого исхода, поэтому это не свидетельство обхода.

## НЕ ЗАЩИЩАЕТ

Остатки названы в contracts/217-incr-pustoe-okno.md:67-72: подделка достижимого кеша ловится действующими писателями CI и reviewer/adversary; произвольное сокрытие обхода и воздействие на Trace2 — независимым adversary и reviewer; нестабильность среды — CI и reviewer; публикация/merge — батареей 210 и reviewer. Блок выше не объявляется остаточным риском.

## Советы

СОВЕТ contracts/217-incr-pustoe-okno.md:40 — Trace2 сейчас запрещает ls-tree/log/for-each-ref, но не полный `rev-list HEAD`: третья мутация показывает зелёную батарею при проходе истории. Основание этой конкретной мутации — добавление операции, не источник ранее существующего ошибочного механизма, поэтому по действующему порогу это совет.
