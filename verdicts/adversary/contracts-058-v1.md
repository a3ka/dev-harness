FAIL

# Адверсарный круг контракта 058

Судился `HEAD=816ec5d41d2f2ddc16aa659fa990529dbb283470`; контракт и список
барьеров прочитаны из `frozen/contracts/058/1`
(`b78bffc68db15dfde0d5a09be3878b0846c84b9e`). Испытания выполнялись только в
одноразовом клоне.

## Стенограмма перед спавном

Детектор перед спавном: bash scripts/check_no_leak.sh --check /home/aka/Documents/dev-harness → rc 0, «основной чекаут чист» (2026-09-29, после пуша 816ec5d).

Это дословная стенограмма, переданная судье в назначении; основной чекаут не
открывался и не изменялся.

## Положительный контроль

На честном `workshop` выполнен ровно CI-шаг:

```text
$ bash fixtures/_krasnye_058.sh
стаб-пак: 9/9 поймано, диффпроба 9/9 — различимость жива (Н-39)
честная часть: 13/13 зелёная; предъявлений: стабы 9/9 + дифф 9/9 + честные 13/13
итог 058: rc=0
```

`package.json` связывает `check:sharing-family-selftest` с тем же значением
`bash fixtures/_krasnye_058.sh`, а CI вызывает этот shell-скрипт напрямую.
Следовательно, ниже приведены именно обходы scoped-батареи и CI-шага, а не
вечно-красная проверка.

## Найденные обходы

### F1 — зашитый `projectId=p1` проходит батарею и CI

**Нарушение.** И-1 применим к любому `projectId` допустимой грамматики. Мутант
выполняет настоящую реализацию только для `p1`, а для любого другого валидного
идентификатора завершает `rc=0` с правдоподобным A2, хотя живой DEVDB уже есть:

```bash
case "$(cat "$HARNESS_PROJECT_LAYER_ROOT/registry/harness-project.json")" in
  *'"projectId":"p1"'*) exec "$REAL_WORKSHOP" "$@" ;;
  *) printf 'AGENTDB: изолирована\n'; exit 0 ;;
esac
```

**Путь воспроизведения.** Корень с этим мутантом как `workshop`, а остальными
файлами из клона, дал зелёный точный CI-вызов:

```text
$ REPO_ROOT=.adversary058-mutants/p1-root bash fixtures/_krasnye_058.sh
стаб-пак: 9/9 поймано, диффпроба 9/9 — различимость жива (Н-39)
честная часть: 13/13 зелёная; предъявлений: стабы 9/9 + дифф 9/9 + честные 13/13
итог 058: rc=0
```

Отдельный конформный toy-вход с полным профилем, `projectId=p2`, существующим
`$DEVDB` и тем же мутантом завершился `rc=0` и напечатал:

```text
hard-code breach: p2 DEVDB exists but PROJDB is not a symlink
```

То есть батарея никогда не запускает честную часть 058 для второго допустимого
значения. У неё есть `p2` в соседней семье 055, но вложенный к11 не делает это
наблюдением шага 058: данный мутант всё равно зелёный во всей scoped-батарее.

**Требуемое лечение автором.** Добавить честную клетку 058 с отличным от `p1`
валидным `projectId` и живым DEVDB, проверяющую C1, путь PSTATE и A1. Нельзя
лечить исключением для `p1` или статической проверкой исходника.

### F2 — dev-ветка может печатать `AGENTDB:` и остаётся зелёной

**Нарушение.** И-6 требует, чтобы dev-ветка не содержала ни `AGENTDB`, ни W8,
ни шага. Батарея объявляет к12 cognitive-only и вообще не исполняет вход без
проекта. Мутант меняет только dev-вход:

```bash
if [ "$#" -eq 0 ]; then
  printf 'AGENTDB: dev branch must remain untouched\n'
fi
exec "$REAL_WORKSHOP" "$@"
```

**Путь воспроизведения.** Этот мутант прошёл точный CI-вызов с теми же
`9/9 + 9/9 + 13/13` и `rc=0`:

```text
$ REPO_ROOT=.adversary058-mutants/dev-root bash fixtures/_krasnye_058.sh
…
итог 058: rc=0
```

Но реальный dev-запуск с безопасным `omp`-shim завершился `rc=0` и первым
вывел запрещённую строку:

```text
$ PATH=.adversary058-mutants:$PATH XDG_STATE_HOME=$(mktemp -d) \
    bash .adversary058-mutants/dev-root/workshop
AGENTDB: dev branch must remain untouched
```

**Требуемое лечение автором.** Сделать к12 исполняемой: запустить dev-вход с
`omp`-shim, проверить `rc=0` и отсутствие `AGENTDB:`/W8, а также отсутствие
создания/изменения agent.db. Одна только проверка проектной ветви это свойство
не доказывает.

### F3 — frozen-барьер из списка контракта изменён при landing

Из frozen-блоба взят список «РАБОТА НЕ РАЗДАЁТСЯ», включающий
`NABLIUDENIA.md`. Проверка дельты landing относительно первого родителя
показывает изменение этого запрещённого пути:

```text
$ git diff --name-only 816ec5d^1 816ec5d -- \
  scripts/verify_antiplacebo.sh registry/contracts.tsv .omp \
  scripts/profile_resolver.sh fixtures/_krasnye_054.sh \
  fixtures/_krasnye_055.sh fixtures/workshop_project/red_izoljacija_projectid.sh \
  fixtures/workshop_project/_verify_055_r3.sh \
  fixtures/workshop_project/red_profil_dva_sloja.sh NABLIUDENIA.md \
  NABLIUDENIA_ARCHITECT.md HANDOFF.md AGENTS.md
NABLIUDENIA.md
```

Эквивалентный `git diff --exit-code 816ec5d^1 816ec5d -- <тот же список>`
вернул `rc=1`. Три названных implementer-коммита сами меняют только
`workshop` и `fixtures/workshop_project/red_sharing_agentdb.sh`, но итоговый
landing всё равно не удовлетворяет требуемой неизменности frozen-барьера.

## Отвергнутые обманы (батарея их поймала)

| Класс | Проба | Наблюдение |
|---|---|---|
| пустой субъект | `WORKSHOP=/dev/null bash fixtures/workshop_project/red_sharing_agentdb.sh .` | `rc=1`, г0 «предмет отсутствует» |
| нейтрализация шага с фальшивым `AGENTDB:` | мутант печатает A2 и `exit 0` | `rc=1`; честные к1, к3–к11, к13 красные (2/13) |
| инструмент вне PATH / отказ вместо содержательного вывода | `env PATH=/nonexistent /usr/bin/bash fixtures/workshop_project/red_sharing_agentdb.sh .` | `rc=1`; отсутствующие `dirname`, `mktemp`, затем «058-батарея ОТКАЗ: нет git» |
| девять штатных контрмоделей | положительный контроль выше | все 9/9 адресно пойманы, диффпроба 9/9 зелёная |

Отдельная попытка перенаправить вывод базового прогона в `/tmp` была остановлена
стражем; обходных форм записи не применялось. Дословный отказ:

```text
запись в чекаут из непиннованной сессии запрещена — Н-85/А-122: путь /tmp/adversary058-baseline.out не в null-allowlist (/tmp/dev-harness-verify/**, artifact://)
```

## Вердикт

**FAIL.** F1 даёт ложнозелёную реализацию с зашитой константой вместо общего
вычисления, F2 оставляет И-6 непроверенным исполнимо, а F3 нарушает требуемую
неизменность frozen-барьера. Предмет и батарею не правил.
