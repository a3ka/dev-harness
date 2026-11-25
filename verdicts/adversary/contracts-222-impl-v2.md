FAIL
OBJECT=26571a3960da5614903d2acc07425f63eb1ba98c
СУД: репо=dev-harness; предмет=222; фаза=реализация; роль=adversary; вызов=2 (узкий; SANKCIJA консультанта); сессия=c907157c/Adv222b; модель-факт=openai-codex/gpt-6.1-terra; автор Impl222b — implementer (MiniMax), Architect222b; предыдущий=archive/222/adversary-v1-fail-64e736b4dc; класс=рисковый

## Блоки

### БЛОКИРУЕТ К-08 — батарея принимает префиксную сверку denied вместо равенства fallback

ПРОИСХОЖДЕНИЕ: узкое-закрытие; КЛАСС: К-08. ОБЯЗАТЕЛЬСТВО: `contracts/222-sudja-ljubaja-model.md`, «Предмет» и И2: denied сверяется именно с объявленным fallback; selector с effort является самостоятельным полным значением, сравнение буквальное с принятой bare/full эквивалентностью. `scripts/check_sud_model.sh:429` содержит сравнение с `$fbexpected`. Источник входа — прямо заявленные в контракте выбор selector с effort из реестра, per-call назначение и трасса автофолбэка; вход ниже использует пять конформных полей и модель, отдельно вписанную в models. Источник ошибочного механизма — замена уже имеющегося сравнения fallback с фактом, не изменение оракула.

ОБХОД: в одноразовом клоне OBJECT изменить единственное выражение в условии denied:

```bash
# до
! sud_same_model "$m" "$fbexpected"
# после: точное совпадение ИЛИ префикс теперь считается совпадением
! sud_same_model "$m" "$fbexpected" && [[ "$m" != "$fbexpected"* ]]
```

СОСТОЯНИЕ: отдельный мир `probe.install(repo, world, False)`: primary `primary-vendor/base-1`, fallback `reserve-vendor/reserve-2`, явно объявленная per-call `other-vendor/other-family-9`; дополнительно в `models` внесена модель `reserve-vendor/reserve-2:xhigh`. Трасса: `critic TAB reserve-vendor/reserve-2:xhigh TAB denied TAB Judge222_A TAB aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa`; `--assigned-model other-vendor/other-family-9`. `probe.observe` вызывает настоящую скопированную bash-дверь с этим конфигом и трассой.

НАБЛЮДЕНИЕ (честная и мутированная двери, один и тот же вход):
```text
honest model reserve-vendor/reserve-2:xhigh assigned other-vendor/other-family-9 status denied rc 1 stdout  stderr ОТКАЗ: фолбэк вне списка тира: critic на reserve-vendor/reserve-2:xhigh, тир apex-sol (Н-270)
mutant model reserve-vendor/reserve-2:xhigh assigned other-vendor/other-family-9 status denied rc 0 stdout СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт critic материализуется stderr
```
На этом мутанте `bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh --repo .` rc 0, `SUBJEKT 222: KLETKI 83 KRASNYH 0`. Соседние проверки также зелёны: 198 `--repo .` rc 0 `REPO_CELLS=12 FAILURES=0`, 173 `--repo` rc 0 (19 ZELENO), все шесть `fixtures/zashchita_main_104/red_*.sh` rc 0. Позитивный контроль честной production и модели зелён (ниже). Это дефект различения батареи, не утверждение о неисправности честной production. Закрывающее свойство — различать denied-факт, являющийся собственной объявленной моделью, от fallback, когда их имена различаются только продолжением selector, включая effort, в том числе при per-call назначении.

Правило остановки владельца: FAIL только по К-08 при честной production → сразу reviewer; не открывать новый цикл ремонта до этого решения.

## Остатки

В контракте нет строк `НЕ ЗАЩИЩАЕТ` с одновременно указанными идентификатором К-NN и ловцом adversary; граница конечной батареи с ловцом critic/adversary проверена атакой К-08 выше. Компрометация доверенного запроса/трассы, внешний платный runtime и идентификация актора не объявлены защищёнными. Префиксная мутация по существующему компаратору подтверждена при отдельно объявленном selector, не выдаётся за атаку через изменение проверки.

## Регресс

В отдельном чистом клоне origin, переключённом на OBJECT, с отдельными тестовыми мирами и фиктивными конфигом и трассами:
```text
222 --repo .      rc=0  SUBJEKT 222: KLETKI 83 KRASNYH 0
222 --model       rc=0  MODEL 222: KLETKI 83 KRASNYH 0
222 --stabs       rc=0  STABY 222: STABS 35 ZHIVYH 0
222 --sintaksis   rc=0
222 --catalog     rc=0  KLETKI=83 STABS=35 SVJAZI=64
check_adv222.py   rc=0
```
Обе адресные мутации st34/st35 пойманы; независимое `continue` в denied красит `verdict-denied-per-call-wrong-fallback`, независимое условие `-n "$assigned"` красит обе клетки пустого назначения. По `git diff 465b42261 HEAD` и `git log`: implementer изменил только `scripts/check_sud_model.sh`, architect — только `fixtures/workshop_project/lyubaja_model_222/`. Дифф `probe.py` сохраняет клетки 1–76 и добавляет 77–83.

Дифференциал базовой `465b42261` и OBJECT на изолированном мире: отсутствующий флаг, корректный, другой объявленный, необъявленный, effort, подстрока, регистр, пробел/TAB/LF, `--assigned-model=…`, `-x`, `--x`, пустое→значение дали побайтно одинаковые stdout/stderr и rc. Явное пустое и значение→пустое: база rc 0, OBJECT rc 2 с именованным отказом. Последний флаг: база timeout, OBJECT rc 2. При пустом значении в spawn/frontmatter OBJECT rc 2; при неверной роли rc 2 с именем роли. В окружении задавалась `assigned=other-vendor/other-family-9`, она не поменяла результаты. NUL в argv POSIX не представим; отдельный runtime-тест такого argv не выполнялся.

## Мутации

| Независимая замена production | Наблюдение |
|---|---|
| denied сравнивает факт с `expected_model` вместо fallback | 2/2 адресных клетки красные |
| denied продолжает цикл при наличии назначения (`check_adv222.py`) | 1/1 адресная клетка красная |
| пустое значение подменяется `${2:-$expected}` | 2/2 красные, set -u даёт rc 1 вместо ожидаемого rc 2 |
| `assigned_given=${2:+1}` | 2/2 красные: пустое приводит к ложному успеху |
| отказ резолвера вместо вывода | положительная `spawn-critic-other-family` красная: rc 2 вместо 0 |
| denied допускает совпадение по префиксу в дополнение к `sud_same_model` | ЖИВ: полная 222 83/0, соседи 198/173/104 зелёные; контрпример и точная замена выше |

## НЕ ЗАЩИЩАЕТ

Суд ограничен дельтой К-08/К-09 и выполненными выше командами; не доказывает все селекторы, подлинность доверенной трассы, идентичность акторов или внешний runtime. Батареи 198 `--model`/`--stabs`, 104 `battery_stubs.sh` и 173 `--model`/`--stabs` на этом вызове отдельно не запускались; их результаты прошлого вызова не выдаются за результаты текущего.

## Советы

Нет дополнительных советов. Сырые итоги существенных прогонов приведены выше; перечисленные результаты адресных мутаций получены через `probe.battery` в отдельных временных мирах.
