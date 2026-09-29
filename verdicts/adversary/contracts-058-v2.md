FAIL

# Адверсарий к2 — контракт 058 (шаринг `agent.db`)

Судился `HEAD=af5543cbf3b98b048ef15def66fda8d54913d4d2` в одноразовом
SSH-клоне. Предмет и батарея не изменялись; обманные субъекты и одноразовые
toy-входы жили в неотслеживаемом `.adversary058-mutants/` и не входят в
коммит.

## Стенограмма перед спавном

Детектор перед спавном: bash scripts/check_no_leak.sh --check /home/aka/Documents/dev-harness → rc 0, «основной чекаут чист» (2026-09-29, CI зелёный 6/6 по af5543c).

## Положительный контроль и frozen-границы

Честный точный CI-guard был исполнен:

```text
$ bash fixtures/_krasnye_058.sh
стаб-пак: 9/9 поймано, диффпроба 9/9 — различимость жива (Н-39)
честная часть: 15/15 зелёная; предъявлений: стабы 9/9 + дифф 9/9 + честные 15/15
итог 058: rc=0
```

`package.json` и прямой шаг CI вызывают этот же guard. Следовательно, ниже
приведённые ложнозелёные субъекты — дефекты scoped-батареи, а не постоянно
красная проверка.

Frozen-барьеры из `frozen/contracts/058/1` проверены для фикс-пачки:

```text
$ git diff --exit-code 302d8be 6527420 -- \
  scripts/verify_antiplacebo.sh registry/contracts.tsv .omp \
  scripts/profile_resolver.sh fixtures/_krasnye_054.sh fixtures/_krasnye_055.sh \
  fixtures/workshop_project/red_izoljacija_projectid.sh \
  fixtures/workshop_project/_verify_055_r3.sh \
  fixtures/workshop_project/red_profil_dva_sloja.sh \
  NABLIUDENIA_ARCHITECT.md HANDOFF.md AGENTS.md
rc=0
```

`NABLIUDENIA.md` намеренно исключён: это санкционированная владельцем
вне-предметная учётная дельта `816ec5d`, указанная в задании. F3 прошлого
круга не повторяется как finding.

## F1/F2 прошлого круга закрыты исполнимо

### F1 — константа только для `p1` поймана к15

Мутант делегирует честную реализацию только для `projectId=p1`; для любого
другого projectId возвращает правдоподобные `AGENTDB: изолирована` и `rc=0`.
Dev-вход делегируется честно, поэтому нейтрализована ровно проверяемая ветка.

```text
$ WORKSHOP=$PWD/.adversary058-mutants/f1-workshop \
    bash fixtures/workshop_project/red_sharing_agentdb.sh
стаб-пак: 9/9 поймано, диффпроба 9/9 — различимость жива (Н-39)
058-батарея: честная клетка к15 красная
честная часть: 14 из 15
rc=1
```

К15 ловит ровно F1: p2 с живым DEVDB не материализует C1/PSTATE/A1.

### F2 — запрещённый вывод dev-ветки пойман к12

Мутант делегирует все проектные запуски, но перед честным dev-запуском печатает
`AGENTDB: forbidden dev-branch sharing` и завершает честный запуск. Он
проверяет, что к12 действительно исполняет вход с omp-shim, а не читает
исходник.

```text
$ WORKSHOP=$PWD/.adversary058-mutants/f2-workshop \
    bash fixtures/workshop_project/red_sharing_agentdb.sh
стаб-пак: 9/9 поймано, диффпроба 9/9 — различимость жива (Н-39)
058-батарея: честная клетка к12 красная
честная часть: 14 из 15
rc=1
```

## Новые находки

### N1 — два известных `projectId` можно зашить, и батарея остаётся зелёной

Контракт требует одно и то же для **любого** projectId своей грамматики, но
честная часть вызывает только `p1` и `p2`. Мутант делегирует `p1|p2`, в том
числе dev-вход, а любой иной валидный идентификатор подменяет A2/`rc=0`:

```bash
case "$(jq -r .projectId "$HARNESS_PROJECT_LAYER_ROOT/registry/harness-project.json")" in
  p1|p2) exec "$REAL_WORKSHOP" "$@" ;;
  *) printf 'AGENTDB: изолирована\n'; exit 0 ;;
esac
```

Он проходит полный scoped-guard и, следовательно, CI:

```text
$ WORKSHOP=$PWD/.adversary058-mutants/dual-id-workshop \
    bash fixtures/workshop_project/red_sharing_agentdb.sh
стаб-пак: 9/9 поймано, диффпроба 9/9 — различимость жива (Н-39)
честная часть: 15/15 зелёная; предъявлений: стабы 9/9 + дифф 9/9 + честные 15/15
rc=0
```

Но на конформном `projectId=p3`, с живым DEVDB и тем же полным toy-профилем,
субъект подтвердил обход:

```text
$ SUBJECT=$PWD/.adversary058-mutants/dual-id-workshop \
    bash .adversary058-mutants/probe-third-id.sh
third-id breach: p3 has a live DEVDB, but the dual-id mutant returns A2 and creates no PROJDB
rc=0
```

**Требуемое лечение:** строить как минимум одну честную C1-клетку с новым
валидным projectId, не фиксированным `p1`/`p2` (лучше генерируемым значением),
и проверять PSTATE, A1 и readlink так же, как к15. Статический запрет
констант не является лечением.

### N2 — симлинк родителя `PSTATE/home` обходит «только agent.db»

И-2 требует, чтобы в `$PSTATE/home` была не более одна ссылка и именно
PROJDB; Граница-2 запрещает разделять состояние кроме `agent.db`. Однако
реализация не проверяет компоненты PSTATE. Если до probe владелец оставил
`$PSTATE/home` симлинком на внешний каталог, `mkdir -p` и `ln -s` идут через
него: появляются и внешний HOME (prompt/agents/state), и дочерний PROJDB.

Реализация на живом `workshop` воспроизводит это на конформном C1-входе с
валидным `projectId=p3`, живым DEVDB и единственной подменой — симлинком
родителя:

```text
$ bash .adversary058-mutants/probe-parent-symlink.sh
parent-symlink breach: HOME is a symlink outside PSTATE, while agent.db is materialized through it
rc=0
```

Батарея не строит такую форму и потому положительный контроль выше остаётся
зелёным. Это не L3a (он допускает ранее работающий **PROJDB**); здесь
подменён предок, и разделяется больше, чем файл `agent.db`.

**Требуемое лечение:** до первого `mkdir`/`ln` fail-closed проверять, что
существующие компоненты `$PSTATE/home/.omp/profiles/$PROFILE/agent` не
являются симлинками (либо явно нормировать иной разрешённый контрактный
исход); добавить клетку с симлинком `PSTATE/home` на внешний каталог, которая
требует отказ до материализации любого дочернего состояния.

## Прочие обязательные контроли

- Пустой субъект: `WORKSHOP=/dev/null bash fixtures/workshop_project/red_sharing_agentdb.sh`
  вернул `rc=1` с `ОТКАЗ: предмет отсутствует`; пустота не объявлена успехом.
- Инструмент вне PATH: `env PATH=/nonexistent /usr/bin/bash
  fixtures/workshop_project/red_sharing_agentdb.sh` вернул `rc=1` и
  `058-батарея ОТКАЗ: нет git`; отсутствие исполняемых утилит fail-closed.
- Неверный ответ на другой путь проявился N2: обычная проверка только
  дочернего PROJDB не отвечает на вопрос о симлинке-предке HOME.

## Вердикт

**FAIL.** F1 и F2 к1 закрыты их живыми мутантами, frozen-барьеры фикс-пачки
не затронуты, но N1 даёт ложнозелёную реализацию с константами `p1|p2`, а N2
оставляет незащищённой симлинк-подмену родительского HOME. Предмет и батарея
не менялись.
