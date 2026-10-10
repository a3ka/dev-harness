BLOCKS

# Вердикт adversary — контракт 094, круг 5

**Судимый субъект:** `origin/wip/094/implementer` @ `e6009c5d36eea1a0ee039dcd64bd89c752787fe6`.

**Судимая батарея:** `origin/wip/094/architect` @ `9140ea202cde280a438a825c2f85b5023b2725ac`.

`architect` является предком субъекта; сборка в одноразовом SSH-клоне поэтому имеет `HEAD=e6009c5d…` без дополнительной дельты.

## Блокер Б5-R5 — переход toy → production меняет carrier политики без санкции

Фикс Б4-R4 верно выбирает candidate-версию **того же** carrier, но выбор самого carrier делается только по `BASE`:

```bash
if registry_bytes="$(git -C "$REPO" show "$BASE:registry/ci-steps.tsv" ...)"; then
  POLICY_SOURCE="registry/ci-steps.tsv"
else
  POLICY_SOURCE="harness/policy"
fi
...
cand_pol="$(git -C "$REPO" show "$CAND:$POLICY_SOURCE" ... )"
```

Из toy-base (только `harness/policy`, mandatory `ci-a,ci-b`) построен кандидат, который сохраняет этот toy-carrier без изменений, но добавляет production-carrier `registry/ci-steps.tsv` с единственным слабым шагом `weak`. Журнал содержит обычный accept и честные зелёные check-строки старой toy-политики, **без** строки `policy`. `publish` выбирает `harness/policy` по base, видит те же байты у кандидата, не требует санкции и публикует merge. После публикации следующий вызов уже выберет существующий registry-carrier, то есть доверенная политика молча стала `weak`.

Живая проба:

```text
bash /tmp/dev-harness-verify/probe-r5-toy-production-boundary.sh .
toy_to_production_policy_bypass=published
```

Это не спор о byte-for-byte сравнении: в production→production ветви изменение `registry/ci-steps.tsv` сравнивается по sha256 байтов и требует санкцию. Дыра — смена **самого носителя** между base и candidate. Батарея остаётся зелёной, потому что её toy-мир не вводит production-carrier в candidate и модель не имеет production-развилки; следовательно, она не различает эту ошибочную реализацию.

Нужно явно определить и проверить переход carrier'ов: candidate, добавляющий `registry/ci-steps.tsv` к toy-base (или удаляющий его при production-base), обязан быть отдельным санкционируемым policy-transition, а policy-version должна отражать выбранный/типизированный carrier. Нужны соответствующие positive и decoy клетки со стабом.

## Б4-R4 перепроверен: закрыт в production→production

Обе прошлые пробы выполнены на новом субъекте живьём.

```text
bash /tmp/dev-harness-verify/probe-r5-real-publish.sh .
real_publish=passed

bash /tmp/dev-harness-verify/probe-r5-production-policy-bypass.sh .
decoy_policy_bypass=refused
```

Первая строит честный production-кандидат без `harness/policy`, с замкнутыми inherited `.review` findings, полным набором check-строк по base registry и `--candidate-ref`: publish проходит. Вторая обнуляет candidate `registry/ci-steps.tsv`, кладёт в `harness/policy` точные байты base registry и не даёт policy-санкцию: дверь отказывает именованно «неавторизованный переход политики» и не двигает `main`.

## Контроли и прежние границы

```text
bash fixtures/_krasnye_094.sh
ИТОГ 094: rc=0                 (17 клеток, 18/18 стабов)

bash fixtures/_krasnye_094.sh --model
ИТОГ 094: rc=0                 (17 клеток, 18/18 стабов)

bash /tmp/dev-harness-verify/probe-r5-land-wrapper.sh .
land_wrapper_unproven_candidate=refused

bash /tmp/dev-harness-verify/probe-r5-outsider-identity.sh .
outsider_identity=refused
```

- **Б-1:** `land_agent.sh` дошёл до двери и не смог сфабриковать verdict/check-журнал; непроверенный кандидат отказан, `main` не сдвинут.
- **Б-2:** range с author/committer `round5-outsider` отказан на `prepare` до merge: committer не в реестре зон.
- **Б-3:** полная батарея, включая `red_proverka_ne_togo_dereva.sh` и стаб `s15`, зелена на субъекте и модели; снятие tree-сверки ловится.
- **Б-6 / policy carrier на обычной production-границе:** прежний decoy обнуления registry с toy-decoy отказан (см. Б4-R4 выше); новый блокер — отдельная неиспытанная граница toy→production.

## Приговор

**BLOCKS.** Исправление `cand_pol` закрыло Б4-R4 для выбранного base-carrier, но `BASE`-only выбор позволяет сменить policy carrier и ослабить production policy без требуемой `policy`-санкции.
