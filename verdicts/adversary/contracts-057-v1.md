accept

# Адверсарий 057 — круг 1: батарея 054, Б3 и проводка M4

Судился одноразовый SSH-клон HEAD `bebea3c569daeaf00808b5a82ca6ec088118a85f`
в `/tmp/dev-harness-verify/adv057-bebea3c`. Предмет и проверки в клоне не
редактировались. Все подмены были отдельными временными копиями вне дерева
предмета; в коммит входит только этот вердикт.

## Красный вход: `.git/config`

SHA-256 `.git/config` клона до атак и после них одинаков:

```text
26b2d85179c3c4d6a84e3b3cd5f4fea6b15455727ce8fe92cebc7151353c1331
```

SHA-256 `.git/config` основного checkout до записи вердикта:

```text
ee1444766dcd4467db3622d64fb78505aacf55ea130e7fa18cacf1e3b6ce0f09
```

## M1 — слияние листьев `barriers`

Независимый toy-probe реального `scripts/profile_resolver.sh` прошёл пять
границ: частичный repo-объект P (`mandatory` из repo, `optional` из defaults),
`defaults.barriers.optional: null`, пустой `optional: []`, отсутствующий
`optional` и отсутствующий `defaults`. Во всех пяти случаях rc=0 и JSON имел
ожидаемые значения/происхождение либо отсутствие листа:

```text
M1 partial: PASS
M1 null_default: PASS
M1 empty_default: PASS
M1 absent_optional: PASS
M1 absent_defaults: PASS
```

Отдельный негатив `defaults.barriers.optional: "BAD KEY!"` дал rc=1 и точную
причину `значение вне алфавита: defaults.barriers.optional: <string>`.

## M2 — fd-first гонка, мутант и счётчик

Позитивный прогон реальной батареи завершился rc=0: стаб-пак поймал 20/20
обманных реализаций, честная часть предъявила 30 клеток. Реальная fd-first
гонка b11h дала `leak=0`; заякоренная дифф-подмена порядка check-then-open
дала утечки и потому была различена:

```text
b11h: ok=59 refused=69 leak=0 (RACE_N=128)
b11m: ok=49 refused=68 leak=11 (RACE_N=128, мутант check-then-open)
честная часть: проверено предъявлений 30
054-батарея зелёная
итог 054: rc=0
```

Внешний счётчик на новом прогоне подтвердил `N=30` против 30 строк `СВЕРКА:`.
В копии батареи заякоренная замена только итогового счётчика на литерал `1`
была обнаружена независимым счётом, а не самой печатью батареи:

```text
EXTERNAL_COUNT n=30 events=30
LITERAL_COUNT_MUTANT_DETECTED n=1 events=30
```

Нейтрализация fail-closed диспетчера отдельной копией добавила ровно
`unknown_cell` в `HONEST_CELLS`. Батарея дошла до этой клетки и вернула rc=1 с
именованной причиной, не прошла молча:

```text
СВЕРКА: unknown_cell
054-батарея ОТКАЗ: ЧЕСТНАЯ ЧАСТЬ: клетка unknown_cell красная
UNKNOWN_DISPATCHER_MUTANT_DETECTED rc=1
```

## M3 — код возврата раннера

Красный субъект `profile_resolver.sh` с единственным `exit 1` был подан
раннеру через отдельный внешний `REPO_ROOT`. Стаб-пак остался различимым,
честная часть упала на k1, а раннер напечатал `итог 054: rc=1` и сам завершился
`RUNNER_RC=1`. Следовательно, `echo` больше не маскирует код батареи.

Инструмент вне PATH тоже не дал ложного успеха:

```text
fixtures/_krasnye_054.sh: line 15: dirname: command not found
ОТКАЗ: нет резолвера: //scripts/profile_resolver.sh
MISSING_PATH_RC=1
```

## M4 — case-канал и CI-ключ

`npm run check:antiplacebo -- --scope profile_resolver` завершился rc=0:
9/9 case-файлов предъявили зелёный вызов и красный повторный вызов,
`предъявлено красным повторным прогоном: 9`. Отдельный scoped запуск
`profile_resolver/case_defaults_vne_alfavita` также предъявил один зелёный и
один повторный красный сценарий. В матрице CI ключ `profile_resolver` находится
в `ap3`, который запускает тот же `npm run check:antiplacebo -- --scope`.

## Дополнительные проверки

- `bash fixtures/parsing_hygiene_battery/run_battery.sh profile_resolver`:
  4/4 класса закрыты.
- `bash scripts/check_contract_frozen.sh .`: контракт 057 заморожен v1,
  HEAD-блоб совпадает побайтово, вердикт v1 разрешает.
- `bash scripts/check_zones.sh .` вернул rc=1 ещё до этого вердикта: единственная
  причина — уже существующая строка вне грамматики в
  `contracts/055-izoljacija-sostojanija-po-projectid.md` (`ЗОНА architect
  (до-заморозочная батарея по ДЕЙСТВУЮЩЕЙ заморозке каталога):`). Это не путь
  предмета 057 и не исправлялось; поэтому зонный gate нельзя заявлять зелёным.

## Итог

Проверка поймала каждую построенную обманную реализацию: неправильный порядок
fd-open, литеральный счётчик, неизвестную клетку, красный субъект раннера,
невалидный defaults-лист и отсутствие PATH-инструмента. Позитивные контроли
реального резолвера, батареи и всех девяти case-клеток зелёные. Нового обхода
в обязательных векторах M1–M4 не найдено; принимаю реализацию 057.
