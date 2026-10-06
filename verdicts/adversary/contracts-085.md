accept

# 085 — adversary verdict

Предмет: `contracts/085-cikl-perezapuska-repo.md` на HEAD `c68c45ebb208e6ebcd5f2e35966c2ee9e9cfa50b`,
реализация `ops/server/user/orch-loop` + `ops/server/root/orch-peak` + `ops/server/README.md`
в коммите `20ce9a38f9b5620a457a36fc96dc6da03e0351ad` (implementer). Сверка в одноразовом
клоне `/tmp/dev-harness-verify/Judges085-isolated/repo` через
`git clone /home/harness/dev-harness /tmp/dev-harness-verify/Judges085-isolated/repo`;
основной чекаут не изменён.

## FIXSIM-батарея

```text
$ cd /tmp/dev-harness-verify/Judges085-isolated/repo && FIXSIM=1 bash fixtures/ops_server/red_cikl_perezapuska_085.sh
…
стаб s31 пойман (вход м6): проба вместо факта исполнения: отказ запуска после успешной пробы …
стаб s36 пойман (вход л9): счёт станции: счётчик вида копится через событие другого вида …
…
стаб-пак: 39/39 поймано, диффпроба: 31/31
итог 085: красных=0, стабы=39/39, диффпроба=31/31
rc=0
```

FIXSIM=1 зелёная на полном наборе (33 клетки + 39 стабов), включая живую м5 на станции,
различение первой/второй пробы systemd-run (м6) и общий счёт подряд (л9/л10). Стаб-пак
39/39 пойман; диффпроба 31/31. Контракт-правки И-5а/И-3 закрыты исполнением (см. s31, s36).

## 074 pin (ожидаемая красная k5b)

```text
$ cd /tmp/dev-harness-verify/Judges085-isolated/repo && bash fixtures/_krasnye_074.sh
…
честная часть (субъект …/ops/server/install.sh):
k5b: станция /home/harness/.local/bin/orch-loop разошлась с пином
  КРАСНО: cell_k5b
…
итог 074: красных клеток=1 стабы=7/7
rc=1
```

Ровно одна красная клетка — k5b (пины `PIN['user/orch-loop']` и `PIN['root/orch-peak']`
ещё не пересняты на новые sha256 — это работа architect по лендинге 085, см. И-7
контракта). Честная часть 7/7 зелёная, стаб-пак 7/7, диффпроба 7/7, к1b-каналы
6/6+6/6 — всё в норме. Ожидаемое состояние до architect-пересъёмки пинов.

## scoped check_zones

```text
$ bash scripts/verify_antiplacebo.sh --scope check_zones
…
барьеров: 1 · фикстур: 38 · предъявлено красным повторным прогоном: 38
rc=0
```

Все 38 case-фикстур `fixtures/check_zones/` зелёные: каждая имеет положительный
контроль, повторный прогон красный кодом 1 с именованной причиной. Реализация
085 не затрагивает ни один из 38 проверенных инвариантов грамматики зон.

## Контрпримеры (Н-39, оба пойманы)

- **(м6) «проба вместо факта исполнения».** Реализация могла бы проверять
  доступность scope отдельным `systemd-run ... -- true`, а отказ последующего
  запуска workshop ошибочно считать падением. Вход: «падение, выход» с
  `EARLY_MAX=2`, шим отказывает rc 1 без исполнения ровно первому запуску сессии.
  Стаб s31 поймал: наблюдено «сессий 1, rc 1» (ожидалось «сессий 2, rc 0»).
  Реализация запускает сессию через `$MARK.scoped` — свидетельство exec-исполнения
  приходит к workshop, отказ scope ловится по отсутствию свидетельства, не по rc.

- **(л9/л10) «счётчик вида копится через событие другого вида».** Реализация
  могла бы копить раздельные счётчики для ранних маркеров и падений, взаимно
  не сбрасывая. Вход: «ранний, ранний, падение, ранний, выход» → ожидалось 3
  сессии и rc≠0. Стаб s36 поймал: реализация-станции копит «4 сессии, rc 3»
  (на четвёртой ветке), стаб через `== 4` отвергнут. В реализации репо счёт
  общий: смена вида события его не сбрасывает и не разводит по видам, обычный
  перезапуск по маркеру обнуляет.

## Area-of-change

```text
$ git show --stat 20ce9a3 | tail -3
 ops/server/README.md      | 167 ++++++++++++++++++++++++++----
 ops/server/root/orch-peak | 143 ++++++++++++++++-------
 ops/server/user/orch-loop |  60 ++++++++--
 3 files changed, 289 insertions(+), 81 deletions(-)
```

Все три файла — ровно ЗОНА implementer 085
(`ops/server/user/orch-loop ops/server/root/orch-peak ops/server/README.md`).
Architect-зона (`fixtures/ops_server/red_*.sh`, `fixtures/ops_server/cikl_085/`,
`fixtures/ops_server/red_server_obvjazka_074.sh`, `contracts/085-*.md`,
`NABLIUDENIA_ARCHITECT.md`) не тронута. ЗОНА implementer не выходит за границы.

## Frozen

```text
$ git diff --exit-code frozen/contracts/085/1..HEAD -- contracts/085-cikl-perezapuska-repo.md; echo rc=$?
rc=0

$ git diff --exit-code frozen/contracts/085/1..HEAD -- fixtures/ops_server/ fixtures/ops_server/red_cikl_perezapuska_085.sh fixtures/ops_server/cikl_085/; echo rc=$?
rc=0
```

Текст контракта и снимки `cikl_085/` не правлены с момента тега
`frozen/contracts/085/1`. Содержание и контрпримеры привязаны к закоммиченному
входу, не к черновику.

## Проводка и неизменность

- `bash scripts/verify_antiplacebo.sh --scope check_zones` → rc=0 (38/38 — выше).
  Барьер `gitw_preflight_071.sh` для 085 не требуется — нет правок
  `ci-steps.tsv`/`.github/workflows/ci.yml`/`registry/` (085 в зоне implementer
  живой заморозки 083, проводка отложена).
- И-6 (батарея 080 на слитом дереве) реализацией 085 не нарушается: ни один
  из швов `ORCH_PEAK_TEST`, опроса живых субагентов, отчёта, `PHRASE_OK`,
  транзакции маркера не тронут в `ops/server/root/orch-peak`. Слияние
  станция+080 вносит ровно те три объединения, что названы контрактом.

## Вердикт

`accept`: FIXSIM battery rc=0 39/39, 074 pin rc=1 ровно k5b ожидаемо (pre-pin),
scoped check_zones rc=0 38/38, оба контрпримера (м6 и л9/л10) пойманы,
area-of-change чист (3 файла = ЗОНА implementer), frozen rc=0. Установка на
станцию, снятие orch-memcap (И-8) и прогоны `stancija`/`check_zouts` — отдельная
работа консультанта/architect по лендинге, не предмет приёмки адверсария.