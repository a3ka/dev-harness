accept
OBJECT=4ab3e741d99827e9ae8b40749e47fec69c756e3a
СУД: repo=dev-harness; предмет=217; фаза=контракт v1; роль=critic; вызов=2/2 (повторный по дельта-листу); модель-план=openai-codex/gpt-6.1-terra (штатный тир apex-sol); сессия=Crit217b; модель-факт=openai-codex/gpt-6.1-terra (метаданные запуска); SHA=4ab3e741d99827e9ae8b40749e47fec69c756e3a; предыдущий=verdicts/critic/contracts-217-v1.md (FAIL); исключение=нет; класс риска=рисковый; независимость: автор Architect217b — другая сессия.

## Карта классов
К-01: чисто — check_sdacha --run rc 0 и pre_critic rc 0 и diff 3ca9ae82..6d2e6bd2 соответствует дельта-листу
К-02: чисто — без изменений с вызова 1: owner-затравка 217 и ROADMAP.md:533
К-03: чисто — без изменений с вызова 1: контракты 083 113 200 207 210 и 992
К-04: чисто — без изменений с вызова 1: зоны contracts/217-incr-pustoe-okno.md
К-05: чисто — без изменений с вызова 1: команды приёмки contracts/217-incr-pustoe-okno.md
К-06: чисто — без изменений с вызова 1: probe.py и раздел угроз
К-07: чисто — эквивалентная честная ветвь W --model rc 0 и 28 зелёных клеток
К-08: чисто — W --stabs rc 0 и удаление пустого писателя W --model rc 1
К-09: чисто — e6 e7 красные при удалении писателя и w9 зелёная
К-10: чисто — соседние мутации кеша W --model rc 1 по CACHE
К-11: чисто — без изменений с вызова 1: побайтовый оракул probe.py
К-12: чисто — без изменений с вызова 1: Git Trace2 JSON и стандартный парсер
К-13: н/п — синтетические миры не содержат секретов
К-14: чисто — эквивалентная честная ветвь W --model rc 0 включая HEAD с LF и без LF
К-15: чисто — W --stabs rc 0 MUTACII=15 SVJAZI=19 POIMANY=19 ZHIVYH=0
К-16: чисто — contracts/217-incr-pustoe-okno.md:69 сохраняет O(1) и именует предел Trace2 с ловцами
К-17: н/п — проектной архитектурной модели 188 у станционного guard нет

## Блоки

Нет. Блок вызова 1 закрыт различающими входами HEAD без LF, включая oracle на 5000 коммитов, и адресным стабом удаления именно пустого писателя. Это не доказательство наблюдаемости любого возможного вызова писателя на уже канонических байтах: приёмка проверяет именно cache_bytes, как установлено контрактом.

## Проверки дельты

Первым запущен `bash scripts/check_sdacha.sh "$PWD" contracts/217-incr-pustoe-okno.md --run`, rc 0: `СДАЧА: лист зелёный (двери=15 карта=17/17 дельта=3)`. `bash scripts/pre_critic.sh contracts/217-incr-pustoe-okno.md`, rc 0: `КРИТИК: дверь зелёная`. Авторский `W --stabs` rc 0, включая `NO_FINISH_EMPTY -> e6-empty-no-lf: POIMAN`, `NO_FINISH_EMPTY -> e7-empty-oracle-no-lf: POIMAN`, итог `MUTACII=15 SVJAZI=19 POIMANY=19 ZHIVYH=0`. W = `bash fixtures/workshop_project/incr_pustoe_okno_217/red_incr_pustoe_okno_217.sh`. `git diff 3ca9ae82d6449f193e6048bd21aa276b5c687019 6d2e6bd27db811cb859a0b1271dcc9d692c384c7` изучен против раздела «Дельта»: необъявленного семантического изменения не установлено. Риск rev-list ранее был советом, теперь назван в НЕ ЗАЩИЩАЕТ без отмены обязательства O(1).

Ниже мутации по одной в одноразовом клоне со своей .git; приведены фактические строки вывода. После каждой перезаписывался только model/empty_window.sh. Имена контрольных значений соответствуют настоящим Git-мирам батареи.

1. Удаление `incr_finish 0` из пустой ветви, `W --model`, rc 1; остальные 26 клеток GREEN, включая w9:
```
HISTORY commits=1 documents=3
HISTORY commits=5000 documents=26
e6-empty-no-lf: rc=0 seconds=0.014 git=3 discovery=0 RED
  CACHE expected=b'86df19b2a52dddc1eabc6d83b7871ec2360b09ca\n' actual=b'86df19b2a52dddc1eabc6d83b7871ec2360b09ca'
e7-empty-oracle-no-lf: rc=0 seconds=0.014 git=3 discovery=0 RED
  CACHE expected=b'6937b9236b0ea5375c557e401fdb1c1fc69486ae\n' actual=b'6937b9236b0ea5375c557e401fdb1c1fc69486ae'
KLETKI=28 ZELENYE=26 KRASNYE=2
```
2. Вызвать писателя и затем записать HEAD без LF, `W --model --cell e6-empty-no-lf`, rc 1:
```
HISTORY commits=1 documents=3
HISTORY commits=5000 documents=26
e6-empty-no-lf: rc=0 seconds=0.019 git=3 discovery=0 RED
  CACHE expected=b'86df19b2a52dddc1eabc6d83b7871ec2360b09ca\n' actual=b'86df19b2a52dddc1eabc6d83b7871ec2360b09ca'
KLETKI=1 ZELENYE=0 KRASNYE=1
```
3. Подменить `INCR_HEAD` предком перед вызовом писателя, `W --model --cell e7-empty-oracle-no-lf`, rc 1:
```
HISTORY commits=1 documents=3
HISTORY commits=5000 documents=26
e7-empty-oracle-no-lf: rc=0 seconds=0.020 git=4 discovery=0 RED
  CACHE expected=b'6937b9236b0ea5375c557e401fdb1c1fc69486ae\n' actual=b'2a0d8fbaa6395f2bf303af623b4cefafc2ad9bf9\n'
KLETKI=1 ZELENYE=0 KRASNYE=1
```
4. Вызывать писателя только при числе коммитов меньше 5000, `W --model --cell e7-empty-oracle-no-lf`, rc 1:
```
HISTORY commits=1 documents=3
HISTORY commits=5000 documents=26
e7-empty-oracle-no-lf: rc=0 seconds=0.028 git=4 discovery=0 RED
  CACHE expected=b'6937b9236b0ea5375c557e401fdb1c1fc69486ae\n' actual=b'6937b9236b0ea5375c557e401fdb1c1fc69486ae'
KLETKI=1 ZELENYE=0 KRASNYE=1
```
5. Вызвать `incr_finish 0` до суда любого incr-окна, `W --model --cell w1-denied`, rc 1:
```
HISTORY commits=1 documents=3
HISTORY commits=5000 documents=26
w1-denied: rc=1 seconds=0.062 git=21 discovery=3 RED
  CACHE expected=b'86df19b2a52dddc1eabc6d83b7871ec2360b09ca\n' actual=b'09d60501113e9947bf65883fe052a3860271e456\n'
KLETKI=1 ZELENYE=0 KRASNYE=1
```
6. Не вызывать писателя только при `ORACLE=1`, `W --model --cell e7-empty-oracle-no-lf`, rc 1:
```
HISTORY commits=1 documents=3
HISTORY commits=5000 documents=26
e7-empty-oracle-no-lf: rc=0 seconds=0.015 git=3 discovery=0 RED
  CACHE expected=b'6937b9236b0ea5375c557e401fdb1c1fc69486ae\n' actual=b'6937b9236b0ea5375c557e401fdb1c1fc69486ae'
KLETKI=1 ZELENYE=0 KRASNYE=1
```
Честная эквивалентная запись с `case` по режиму и обратным порядком операндов `test` сохранила штатный писатель: `W --model` rc 0, `KLETKI=28 ZELENYE=28 KRASNYE=0`, включая e1–e7 и w9 GREEN. Это проверка двусторонности, не утверждение о произвольной эквивалентной реализации.

## НЕ ЗАЩИЩАЕТ

Остатки contracts/217-incr-pustoe-okno.md:67–72: подделка достижимого кеша — действующие CI-писатели и reviewer/adversary; произвольный обход и полный rev-list HEAD вне секундного ограничения — reviewer алгоритма и независимый adversary; нагрузка и отказы железа — reviewer и клетка 083; регрессии публикации и merge — production-батареи 210/113/083 и reviewer. O(1) и прочие инварианты не сняты.

## Советы

Нет.
