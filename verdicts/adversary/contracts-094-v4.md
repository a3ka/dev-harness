BLOCKS

# Вердикт adversary — контракт 094, круг 4

**Судимый субъект:** `origin/wip/094/implementer` @ `59184a7feea143d08fa43bfe07b95a9e101a4f20`.

**Судимая батарея:** `origin/wip/094/architect` @ `9140ea202cde280a438a825c2f85b5023b2725ac`.

## Блокер Б4-R4 — production-carrier сверяется с несвязанным toy-файлом

В production-ветви `scripts/accept_publish.sh` выбирает доверенную политику из
`BASE:registry/ci-steps.tsv`, но проверка перехода всегда читает
`CAND:harness/policy`:

```bash
cand_pol="$(git -C "$REPO" show "$CAND:$POLICY_PATH" 2>/dev/null)"
```

`POLICY_PATH=harness/policy` — toy-носитель, отсутствующий в реальном
production base. Это живо даёт и ложный отказ честному кандидату, и обход И-6б.

### Честный production-кандидат ложно красен

В одноразовом SSH-клоне построен реальный harness-кандидат от `59184a7…`:
коммиттер `implementer`, `prepare`, объект, применимый `verdict`, зелёная
`check`-строка для каждого base `step` (wfsha доверенного реестра и буквально
`MERGE^{tree}`), `--candidate-ref`; готовые `.review`-находки закрыты, чтобы
они не маскировали пробу.

```text
bash /tmp/dev-harness-verify/probe-r4-real-publish.sh
publish_rc=1
ОТКАЗ: политика кандидата удалена
main_unchanged=yes
```

Кандидат не менял `registry/ci-steps.tsv`; он закономерно не имеет
`harness/policy`, поэтому дверь отказывает вместо publish.

### Ослабление production-политики публикуется без санкции

В том же реальном harness-мире с локальной `main=59184a7…` кандидат удаляет
все `step` из своего `registry/ci-steps.tsv` (остаётся `lanes\t7`) и кладёт в
новый, неиспользуемый production-файл `harness/policy` точные байты доверенного
base реестра. Журнал несёт все доказательства по base-политике, но не несёт ни
одной `policy`-строки. И-6б требует named refusal, однако дверь публикует:

```text
bash /tmp/dev-harness-verify/probe-r4-production-policy-bypass.sh
publish=PUBLISHED target=main merge=5def72631f0b719ddcb8b0352c81783d5c2e9131
main_is_merge=yes
candidate_steps=0
policy_sanctions=0
```

Следовательно, изменение действительного production carrier не сравнивается и
не требует отдельной санкции; candidate-controlled decoy отвечает на другой
вопрос. Это обход двери, не спор о силе CI: check-строки в пробе привязаны к
base wfsha и tree подготовленного merge.

Батарея не ловит обход: все 17 клеток используют toy `harness/policy`; `s13`
снимает требование санкции лишь в toy-ветви. Нет full-publish production
positive control, стаба изменения `registry/ci-steps.tsv` с decoy
`harness/policy`, либо честного production-кандидата без toy-файла. Поэтому
18/18 стабов зелены при этом обходе.

## Контроли

Сборка была сделана только в одноразовом SSH-клоне. `architect` уже предок
судимого SHA, поэтому `git merge --no-ff origin/wip/094/architect` оставил
`HEAD=59184a7…`.

```text
bash fixtures/_krasnye_094.sh
rc=0; ИТОГ 094: rc=0; 17 клеток, 18/18 стабов

bash fixtures/_krasnye_094.sh --model
rc=0; ИТОГ 094: rc=0; 17 клеток, 18/18 стабов
```

Б-1/Б-3 закрыты в живой toy-пробе настоящей обёртки:

```text
bash /tmp/dev-harness-verify/probe-r4-land-wrapper.sh
land_agent_rc=1
ОТКАЗ: нет применимого accept для задачи: cand
main_unchanged=yes
```

`land_agent.sh` дошёл до двери, не сфабриковал journal и не двинул `main`;
оба wrapper-файла существуют как допустимая тонкая альтернатива.

Б-2: одиночный коммит с committer `round4-outsider` на реальном
harness-дереве отвергнут до `prepare`:

```text
ОТКАЗ: identity: committer не в реестре зон: round4-outsider (<sha>)
```

И-5/tree не ослаблен: батарея поймала `s15` клеткой
`red_proverka_ne_togo_dereva.sh`, а субъект её прошёл.

## Приговор

**BLOCKS.** Б4-R4 одновременно публикует ослабленный
`registry/ci-steps.tsv` без `policy`-санкции и делает обычный production
publish ложнокрасным. Нужна проверка candidate-версии того же carrier, который
выбран для base (`registry/ci-steps.tsv` для harness, `harness/policy` только
dля toy), плюс production-path клетка и стаб.