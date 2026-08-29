FAIL

# Ревьюер — гейт контракта 015, круг 2

Проверено в живом `/home/aka/Documents/dev-harness` на HEAD
`ca457a470c0dc6c49d8260abb6430559e64b741a`. Вердикт **FAIL** из-за одной
новой самостоятельной находки: `ca457a4` изменил текст уже замороженного
контракта 015, поэтому frozen-гейт фактически красный. R015-1, R015-2 и
R015-3 закрыты доказательствами ниже; они не отменяют R015-4.

## Находки

### R015-4 — НОРМА / заморозка: изменён frozen-текст без v+1

`ca457a4` изменяет ровно две счёт-строки в
`contracts/015-jadro-avtonomnosti-nabljudenij.md`. Это не фикстура и не
барьер; это текст frozen-спеки. Следовательно, аргумент о том, что фикстуры
не входят в freeze, к этой правке неприменим.

Сырая сверка самого изменяющего диапазона:

```text
$ git diff --unified=80 d0257eb..ca457a4 -- contracts/015-jadro-avtonomnosti-nabljudenij.md
--- a/contracts/015-jadro-avtonomnosti-nabljudenij.md
+++ b/contracts/015-jadro-avtonomnosti-nabljudenij.md
@@
-счёт: 12 фикстур в fixtures/check_nabludenia/
+счёт: 11 фикстур в fixtures/check_nabludenia/
-счёт: предъявлений 12 + 7 + 12 + 1 = 32
+счёт: предъявлений 11 + 7 + 12 + 1 = 31
```

Норма AGENTS.md, правило 3, дословно: «Заморозка морозит ТЕКСТ спеки:
`check_contract_frozen.sh` сверяет блобы `plans/`/`contracts/` с тегом —
фикстуры и барьеры приёмки в него не входят». Там же установлен единственный
путь для правки текста: «правка ТЕКСТА спеки — только v+1 с новым вердиктом
критика И строкой `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` в изменяющем коммите».

Фактический frozen-гейт (с md5-сторожем до и после) подтверждает нарушение,
а не заявленные rc=0:

```text
$ md5sum NABLIUDENIA.md
35ccdd6086b421be5d2a1350e322d608  NABLIUDENIA.md
$ bash scripts/check_contract_frozen.sh
  FAIL contracts/015-jadro-avtonomnosti-nabljudenij.md изменён без новой заморозки: на HEAD блоб 4119bcdc1fae59960b24a840ebb4287a679df00d, в заморозке v1 — ebcea273ab1dbffcfe6a18f50e4129875af732ac. Выход: новый вердикт критика v2, freeze_contract.sh и строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ: в изменяющем коммите

планов и контрактов на HEAD: 18 · черновиков: 3 · заморожено: 15 · реестр: full
rc=1
$ md5sum NABLIUDENIA.md
35ccdd6086b421be5d2a1350e322d608  NABLIUDENIA.md
```

Это отказ класса **норма / заморозка**, а не замечание о счёте: изменение
может быть содержательно верным, но frozen-норму нельзя менять молча.
Нужны предусмотренные правилом 3 v+1, новый verdict критика и
`РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` в изменяющем коммите.

## Закрытые пункты прежнего verdict

### R015-1 — закрыт: потолок дайджеста и поздние секции

Мой прежний контрпример повторён на новом HEAD в новом временном git-корне:
50 валидных открытых записей, оба файла наблюдений, один draft и HANDOFF с
`## ГДЕ МЫ`. Реальный скрипт даёт ровно 40 строк, сохраняет секции
`черновики:` и `HANDOFF:`; хвост открытых записей схлопнут внутри своей
секции.

```text
$ TMPDIR="$D" bash scripts/nabludenia_digest.sh --for-session --root "$T"
открытые с адресами:
Н-1 → контракт 015
…
Н-23 → контракт 015
…и ещё 27

дерево:
remote недоступен
непушенных тегов: 0
статус: аномалии
  ?? HANDOFF.md
  ?? NABLIUDENIA.md
  ?? NABLIUDENIA_ARCHITECT.md

черновики:
черновиков: 1
  draft.md

HANDOFF:
HANDOFF.md §ГДЕ МЫ, строка 2
rc=0 (ожидалось 0)
line_count=40 (ожидалось 40)
sections=черновики:
HANDOFF:
```

Сторож до и после прогона: `35ccdd6086b421be5d2a1350e322d608
NABLIUDENIA.md`. В `0546638` глобальный post-`head` заменён расчётом бюджета
и усечением только `SECT_OPEN`; наблюдаемый контрпример больше не нарушает
§Предмет.

### R015-2 — закрыт: барьер судит форму, не TABLE

Мой прежний контрпример — грамматически валидная запись Н-14 с чужим для её
старой таблицы назначением `контракт 015` — теперь принят реальным барьером:

```text
$ bash scripts/check_nabludenia.sh "$T"
rc=0 (ожидалось 0)
```

Сторож до и после прогона: `35ccdd6086b421be5d2a1350e322d608
NABLIUDENIA.md`. Это ровно требуемая пост-миграционная граница §Предмет:
TABLE-мера остаётся у миграционной пробы, но удалена из барьера. Удаление
`case_lishnee_naznachenie.sh` проверено отдельно:

```text
$ test ! -e fixtures/check_nabludenia/case_lishnee_naznachenie.sh
case_lishnee_naznachenie_absent_rc=0
$ ls fixtures/check_nabludenia/case_*.sh | wc -l
11
$ ls fixtures/drill_gate_draft/case_*.sh | wc -l
7
$ ls fixtures/drill_startup_digest/case_*.sh | wc -l
12
$ ls fixtures/drill_nabludenia_nechitaemo/case_*.sh | wc -l
1
```

Таким образом контрактные счёт-строки на HEAD (`11 + 7 + 12 + 1 = 31`)
соответствуют независимой мере файлов. Однако сами эти строки нельзя было
менять в frozen-тексте способом `ca457a4`; это R015-4, а не повтор R015-2.

### R015-3 — закрыт: аргумент оркестратора принят

Факт `32d6b31` проверен по полному диффу двух фикстур. До него зелёный вызов
`"$BARRIER"` вычислял `WORK` из реального пути дрилла и мог переписать живой
`NABLIUDENIA.md`; после него и зелёный вызов, и красный стаб запускаются из
копии дрилла в `$WORK/green` либо `$WORK/red`, с субъектом рядом. Это
усиление изоляции и наблюдаемости красной ветви, не подгонка проверки под
реализацию и не ослабление барьера.

Норма правила 3 прямо отделяет фикстуры и барьеры приёмки от freeze и прямо
разрешает пост-freeze добавление красных тестов по verdict адверсария/арбитра
как усиление гейта. Поэтому прежняя R015-3 о самом факте правки двух
фикстур отклонена: frozen-блоб контракта на момент `32d6b31` не менялся, а
изменение фикстур было законным усилением. Последующий `ca457a4` меняет уже
не фикстуру, а frozen-контракт, что отдельно зафиксировано как R015-4.

## Приёмочные прогоны

Во всех восьми следующих прогонах md5 до **и** после был одинаковым:
`35ccdd6086b421be5d2a1350e322d608  NABLIUDENIA.md`.

```text
$ bash scripts/verify_antiplacebo.sh --scope check_nabludenia
барьеров: 1 · фикстур: 11 · предъявлено красным повторным прогоном: 11
rc=0

$ bash scripts/verify_antiplacebo.sh --scope drill_gate_draft
барьеров: 1 · фикстур: 7 · предъявлено красным повторным прогоном: 7
rc=0

$ bash scripts/verify_antiplacebo.sh --scope drill_startup_digest
барьеров: 1 · фикстур: 12 · предъявлено красным повторным прогоном: 12
rc=0

$ bash scripts/verify_antiplacebo.sh --scope drill_nabludenia_nechitaemo
барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1
rc=0

$ bash fixtures/check_nabludenia/probe_nabludenia_krasnoe.sh
ok: барьер зелёный на живом дереве — миграционная пачка в коммите введения
rc=0

$ bash fixtures/drill_gate_draft/probe_gate_draft_krasnyj.sh
ok: дрилл gate-draft зелёный на живом дереве
rc=0

$ bash fixtures/drill_startup_digest/probe_digest_krasnyj.sh
ok: дрилл startup-digest зелёный на живом дереве
rc=0

$ bash scripts/drill_nabludenia_nechitaemo.sh
  ok   зелёный контроль: барьер rc=0 на чистом дереве
  ok   нечитаемое: rc=2 + строка «нечем проверить: NABLIUDENIA.md»
  дрилл nabludenia-nechitaemo: ветвь rc=2 поймана
rc=0

$ bash fixtures/check_nabludenia/probe_migracija_adresov.sh
ok: все ОТКРЫТО-маркеры несут адрес структурной грамматикой; назначение каждой строки §Материал сохранено
rc=0
```

Пять проб и четыре scoped-прогона зелёные; frozen-прогон, также со сторожем,
красный строго по R015-4. Поэтому приёмка не может быть accept.

## Граница review-диффа

Проверенный интервал `d0257eb..ca457a4` содержит:

```text
M  contracts/015-jadro-avtonomnosti-nabljudenij.md
D  fixtures/check_nabludenia/case_lishnee_naznachenie.sh
M  scripts/check_nabludenia.sh
M  scripts/nabludenia_digest.sh
```

`0546638` — отдельный implementer-коммит только двух скриптов; `ca457a4` —
отдельный architect-коммит удаления умершей фикстуры, но одновременно и
недопустимого изменения frozen-нормы. Ни одна фикстура проверки не менялась
автором реализации `0546638`; сама проверка не была переписана под код.

## Итог

R015-1 и R015-2 воспроизведённо закрыты; R015-3 принят по норме и факту.
**FAIL** остаётся только по R015-4: frozen-текст контракта изменён без
обязательных v+1, verdict критика и `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:`; это подтверждено
`check_contract_frozen.sh` с rc=1.
