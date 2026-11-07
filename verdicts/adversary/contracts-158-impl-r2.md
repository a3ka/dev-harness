accept

OBJECT=a77f3d11c10fe1f521635714225fd6a2eee6decf
КЛАСС=КОДОВЫЙ
СУД: repo=dev-harness; предмет=158; фаза=реализация; роль=adversary; сессия=Adv158Terra2; модель-план=openai-codex/gpt-5.6-terra; модель-факт=openai-codex/gpt-5.6-terra; вызов=2/2

## Дельта и область scoped-повтора

Сужение задано Б-1 прошлого круга: `a77f3d11c` меняет только распознавание
`КЛАСС РИСКА:` в компактной шапке, его эталон, клетки батареи, пин и носитель
грамматики. Проверены именно обходы подмены класса риска/ложной зелени и
зависимая дверь `pre_critic`; неизменённые поверхности не переоткрывались.

БЛОКИРУЮЩИХ находок нет. Компактная рисковая шапка проходит через
`model/check_trek_ekrana_158.py:98-123` и обе доставки субъекта: прямой гейт
`script/check_trek_ekrana.sh:49-57` и ногу двери `scripts/pre_critic.sh:260-272`.

## Сырые прогоны

Позитивный контроль честной минимальной реализации:

```text
$ bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh --model
CASE a01-trek-po-umolchaniju ok
CASE a02-risk-bez-stroki ok
CASE a03-risk-legkij ok
CASE a04-risk-legkij-so-slovom ok
CASE a05-polnyj-vsegda ok
…
CASE g01-147-model ok
CASE g02-147-stabs ok
CASE g03-148-model ok
CASE g04-148-stabs ok
CASE g05-149-model ok
CASE g06-149-stabs ok
CASE g07-143-stabs ok
клеток 36, зелёных 36, красных 0
rc=0
```

```text
$ bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh --stabs
клеток 36, зелёных 36, красных 0
STAB st01-trek-bez-riska.py a02-risk-bez-stroki KRASEN
STAB st01-trek-bez-riska.py a03-risk-legkij KRASEN
STAB st02-trek-udaljaet-sloj.py a06-pereklyuchenie KRASEN
STAB st03-avd-393-bez-podtverzhdenija.py b02-zalipshij-390 KRASEN
STAB st04-lint-po-chislu.py c01-literal-nav-height KRASEN
STAB st05-zond-bez-predkov.py f15-tsel-opacity0 KRASEN
STAB st06-oracle-s-diska.py d02-oracle-tamper KRASEN
STAB st07-polnyj-bez-ispolnenija.py a10-sloj-ispolnen-v-polnom KRASEN
STAB st08-marker-gde-ugodno.py a12-marker-vne-priemki KRASEN
STAB st09-sovmestnyj-v-toy.py f03-sovmestnyj-chestnyj KRASEN
STAB st10-sovmestnyj-otvergaet.py f03-sovmestnyj-chestnyj KRASEN
STAB st11-sovmestnyj-karta-ref-clean.py f06-sovmestnyj-karta-iz-fajla KRASEN
STAB st12-sovmestnyj-tablica-nomerov.py f06-sovmestnyj-karta-iz-fajla KRASEN
STAB st13-sovmestnyj-karta-po-nomeru.py f06-sovmestnyj-karta-iz-fajla KRASEN
SVJAZI 26
rc=0
```

Зависимый antiplacebo-регресс (сам `check_trek_ekrana.sh` объявлен
`НЕ БАРЬЕР`, поэтому его имя не является допустимым scope-ключом; затронутая
дверь — `pre_critic`):

```text
$ bash scripts/verify_antiplacebo.sh --scope pre_critic
SCOPED: барьеров 1 из выборки — не для приёмки
  ok   pre_critic/case_01_honest_green.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «Н-39: привязка стаба в прозе»
  ok   pre_critic/case_02_n39_s2_binding.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «Н-39: привязка стаба в прозе»

барьеров: 1 · фикстур: 2 · предъявлено красным повторным прогоном: 2
rc=0

$ git diff --exit-code a77f3d11c^ a77f3d11c -- frozen
rc=0
```

## Атаки на проверку

Одноразовые артефакты были удалены до вердикта.

1. **Нейтрализация / зашитая константа / ложный успех.** В `PATH` был поставлен
   одноразовый `python3`: он делегировал честному `/usr/bin/python3` все входы,
   кроме компактного рискового контракта, для которого возвращал константу
   `0`. Обычная ветвь поэтому оставалась рабочей. Сырой вывод субъекта батареи:

```text
CASE a01-trek-po-umolchaniju ok
CASE a02-risk-bez-stroki ok
CASE a03-risk-legkij ok
CASE a04-risk-legkij-so-slovom ok
CASE a05-polnyj-vsegda ok
CASE z01-gate-v-dereve KRASNO: ожидался rc=0, факт rc=1 (причины факта: NE_SOVPAL_S_SUBJEKTOM)
CASE z02-noga-pre-critic KRASNO: ожидался rc=0, факт rc=1 (причины факта: ЖИВАЯ ДВЕРЬ НА РИСК-ЭКРАНЕ: rc=0 (ожидался 1))
```

   Значит клетка `z01` ловит расхождение эталон/живая обёртка, а `z02` ловит
   ровно нейтрализованную ветвь в настоящей двери. Обманная реализация не
   прошла. Отдельный стаб «всегда rc=0» дал те же две предметные красные клетки.

2. **Инструмент мимо PATH / отказ вместо содержательного результата.** При
   `PATH=/nonexistent` (с сохранённым разрешением корня оболочки) реальный гейт
   напечатал и вернул:

```text
NOT_IMPLEMENTED: нет python3
rc=2
```

   Отсутствующий исполнитель не превращается в зелень.

3. **Пустой вход.** На пустом каталоге `contracts/` прямой гейт вернул
   `rc=0` без строк. Это не обход обязательства: в таком входе нет контракта с
   маркером набора и, следовательно, нет экранного предмета, который гейт
   обязан судить. Для конкретного предъявленного контракта честный контроль
   был зелёным:

```text
$ bash scripts/check_trek_ekrana.sh "$PWD" contracts/158-ekrannyj-nabor.md
ТРЕК ЛЁГКИЙ (по умолчанию)
rc=0
```

4. **Ответ не на тот вопрос.** В селективном стабе условие было привязано к
   содержимому компактной шапки, а не к имени/номеру файла; `z01` сравнил rc и
   причину с независимо исполненным эталоном, а `z02` исполнил `pre_critic` на
   отдельном toy-контракте. Подмена ответа не прошла обе независимые доставки.

Механических расхождений в области Б-1 не найдено: объект действительно
`a77f3d11c10fe1f521635714225fd6a2eee6decf`, frozen-барьеры не менялись, пин
эталона равен `6e3b63584cc76dbaa7ca2d855826333845f5a4f5b78c1776834721a6b1204642`.
