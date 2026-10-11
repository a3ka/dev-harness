ACCEPT — 092 круг 2: оба обхода круга 1 закрыты в реализации и батарее; живая проверка соседних входов не нашла новых.

# Вердикт adversary — контракт 092, круг 2

**Судимый субъект:** `wip/092/implementer`, `4ac664bb757c41f9a97b99a6fc5d30fd26d4912b`.

**Судимая батарея:** `wip/092/architect`, `606eb710fd7838c519b3b6b81ce51523bf84443b` (17 красных + 4 зелёных case + 18 стабов, добавлены клетки 16 и 17 по вердикту круга 1).

## Приговор

**ACCEPT.** Оба обхода, найденные в круге 1 (И-4: пустой `ORCH_STATE_DIR` маскировался успешной семиполевой сводкой rc 0; И-8: `pub-done` чужой задачи/кандидата безусловно повышал `pub_state` ТЕКУЩЕЙ), закрыты и в реализации, и в батарее. Полный прогон `bash fixtures/_krasnye_092.sh` зелёный, диффпроба 21/21, стаб-пак 18/18. Живые соседние входы (несуществующий шов, `pub-done` с совпадающим task но чужим candidate и наоборот, отказ при пустом шве без фабрикации файлов, отказ при шве с `candidate=-`, отказ при `ref` с дополнительными `@`) подтверждают, что новых обходов в этих двух инвариантах не появилось.

## Стенограмма

В одноразовом клоне `/tmp/dev-harness-verify/092-k2-1791585800` (SSH-clone от `wip/092/implementer`@`4ac664bb`) проверено:

1. В рабочее дерево клона наложена батарея из `wip/092/architect`@`606eb710`:
   - `fixtures/orch_state/` (все 19 файлов семьи: `_toy.sh`, `battery_stubs.sh`, 15 прежних красных, клетка 16 `red_status_no_state_refusal.sh`, клетка 17 `red_pub_done_mismatch_refusal.sh`, `green/`);
   - `fixtures/_krasnye_092.sh`;
   - `scripts/orch_checkpoint.sh` и `scripts/orch_status.sh` ОСТАВЛЕНЫ судимого субъекта (фикс И-4/И-8, `4ac664bb`), а не версии архитектора (`33caf2ef`, без починки).
2. `bash fixtures/_krasnye_092.sh` → `rc=0`, stderr пуст, вывод:

   ```text
   диффпроба: честный мини-субъект зелён на всех 21 клетках семьи (rc=0)
   S1 → red_net_off_local_survives.sh: поймано
   S2 → red_net_off_local_survives.sh: поймано
   S3 → red_pub_vs_close.sh: поймано
   S4 → red_status_derives_not_echo.sh: поймано
   S5 → red_ciwait_no_repoll.sh: поймано
   S6 → red_restart_no_dup_task.sh: поймано
   S7 → red_restart_no_dup_round.sh: поймано
   S8 → red_restart_no_dup_publish.sh: поймано
   S9 → red_three_fails_three_rounds.sh,red_rounds_count_events_not_files.sh: поймано
   S10 → red_three_fails_three_rounds.sh: поймано
   S11 → red_three_fails_three_rounds.sh: поймано
   S12 → red_checkpoint_atomic_fail.sh: поймано
   S13 → red_checkpoint_grammar.sh: поймано
   S14 → red_state_outside_tree.sh: поймано
   S15 → red_ciwait_net_vs_timeout.sh: поймано
   S16 → red_checkpoint_atomic_fail.sh: поймано
   S17 → red_pub_state_needs_proof.sh: поймано
   S18 → red_pub_done_mismatch_refusal.sh: поймано
   стаб-пак 092: 18/18 поймано, диффпроба 21/21
   ок red_net_off_local_survives
   ок red_restart_continues_subject
   ок red_ciwait_no_repoll
   ок red_restart_no_dup_task
   ок red_restart_no_dup_round
   ок red_restart_no_dup_publish
   ок red_three_fails_three_rounds
   ок red_pub_vs_close
   ок red_status_derives_not_echo
   ок red_checkpoint_atomic_fail
   ок red_checkpoint_grammar
   ок red_state_outside_tree
   ок red_rounds_count_events_not_files
   ок red_ciwait_net_vs_timeout
   ок red_pub_state_needs_proof
   ок red_status_no_state_refusal
   ок red_pub_done_mismatch_refusal
   ок case_checkpoint_roundtrip
   ок case_status_green
   ок case_ciwait_green
   ок case_events_idempotent_green
   ```

   Сумма: 17 красных клеток `ок …` + 4 зелёных case + 18/18 стабов поймано + 21/21 диффпроба. `grep -c КРАСНО` по полному выводу = 0.

   Стаб S18 (привязка к клетке 17) встроен в `battery_stubs.sh`: тело `33caf2ef` (без починки) портится заменой гварда `subject != m['task'] or ref.split('@', 1)[0] != m['candidate']` на «if False: pass»; на честном теле `4ac664bb` стаб ловится ячейкой 17 (`S18 → red_pub_done_mismatch_refusal.sh: поймано`), что подтверждает, что новая клетка действительно различает обход.

## Закрытые обходы круга 1 — проверка живыми пробами

### И-4: пустой шов давал выдуманную rc=0 сводку

Реализация в `4ac664bb`: убран безусловный `return 0` в `get_state()` (был в `scripts/orch_status.sh`); первый вызов `W_TASK=$(get_state task) || exit 1`. Соседние входы, не предъявленные клеткой 16, проверены отдельно:

| вход | команда | наблюдение |
|---|---|---|
| шов НЕ существует (`ORCH_STATE_DIR=/tmp/dev-harness-verify/test-nodir-k2-nonexistent`) | `bash scripts/orch_status.sh` | stderr: `состояние отсутствует`, stdout ПУСТ, `rc=1` |
| шов пуст (каталог есть, `state.tsv`/`events.tsv` нет) | `bash scripts/orch_status.sh` | stderr: `состояние отсутствует`, stdout ПУСТ, `rc=1` (клетка 16) |
| шов содержит только `events.tsv`, без `state.tsv` | `bash scripts/orch_status.sh` | stderr: `состояние отсутствует`, stdout ПУСТ, `rc=1` |
| шов содержит только `state.tsv` (без `events.tsv`) | `bash scripts/orch_status.sh` | rc=0, корректная полусводка с «кругов: 0», «опубликовано: нет», «закрытие: не завершено», «удалённое состояние: неизвестно» (т.е. не отсутствие) |
| шов содержит пустой `state.tsv` (0 байт) | `bash scripts/orch_status.sh` | stderr: `состояние вне грамматики: task`, `rc=1` (И-2, не И-4) |
| шов содержит `state.tsv` с `candidate=-` | `bash scripts/orch_status.sh` | rc=0, корректная полусводка с `candidate: -`, `pub_state: unknown` |

Никакой случай из шести не возвращает выдуманную семиполевую сводку с rc=0 при отсутствии состояния. Соседний кейс «только events.tsv» подтверждает, что гвард `get_state task || exit 1` срабатывает на отсутствии `state.tsv`, а не только на пустом каталоге.

### И-8: `pub-done` чужой задачи/кандидата повышал pub_state

Реализация в `4ac664bb`: новая константа `P92L_CHUZH_PUBDONE="pub-done чужой задачи или кандидата"`, проброс в Python heredoc, в ветке `event pub-done`:

```python
cur_task = "-" if m is None else m.get("task", "-")
cur_cand = "-" if m is None else m.get("candidate", "-")
arg_cand = ARG_REF.split("@", 1)[0]
if m is None or ARG_SUBJECT != cur_task or arg_cand != cur_cand:
    refuse(L_CHUZH_PUBDONE)
```

Соседние входы (за пределами клетки 17) проверены отдельно на собственноручно собранных состояниях:

| вход | команда | наблюдение |
|---|---|---|
| `state.tsv` НЕ существует, `pub-done 092 aaaa…@refs/heads/main` | `bash scripts/orch_checkpoint.sh event pub-done 092 aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa@refs/heads/main` | stderr: `pub-done чужой задачи или кандидата`, `rc=1`, файлы НЕ созданы (`ls state/` пуст) |
| `state.tsv` существует с `candidate=-` (черновик), `pub-done 092 aaaa…@refs/heads/main` | то же | `rc=1`, `state.tsv` и `events.tsv` байт-в-байт идентичны ДО (sha256 проверены после) |
| `state.tsv` существует с `candidate=bbb…`, `pub-done 092 aaaa…@refs/heads/main` (matching task, foreign cand) | `bash scripts/orch_checkpoint.sh event pub-done 092 aaa…@refs/heads/main` | `rc=1`, файлы байт-в-байт (клетка 17 вход-б) |
| `state.tsv` существует с `candidate=bbb…`, `pub-done 999 bbb…@refs/heads/main` (foreign task, matching cand) | `bash scripts/orch_checkpoint.sh event pub-done 999 bbb…@refs/heads/main` | `rc=1`, файлы байт-в-байт (клетка 17 вход-в) |
| `state.tsv` существует с `candidate=bbb…`, `pub-done "  092 " bbb…@refs/heads/main` (whitespace в subject) | то же с пробелами | `rc=1`, файлы байт-в-байт |
| `state.tsv` существует с `candidate=bbb…`, `pub-done 092 bbb…@refs/heads/main@extra` (лишний `@`) | то же | `rc=1`, файлы байт-в-байт |
| `state.tsv` существует с `candidate=bbb…`, `pub-done 092 bbb…@refs/heads/main` (matching) | то же | `rc=0`, `state.tsv.pub_state=published`, `events.tsv` создан с правильной строкой (клетка 17 вход-г) |
| `state.tsv` существует с `candidate=bbb…`, нет `events.tsv`, matching `pub-done` | то же | `rc=0`, `state.tsv.pub_state=published`, `events.tsv` создан |

Соседние проверки входов 5–7 не были предъявлены клеткой 17 (whitespace в subject, лишний `@` в ref, `events.tsv` отсутствует при наличии matching state) — все они дают rc=1 с тем же именованным отказом и не трогают `state.tsv`/`events.tsv`. Гвард `ARG_REF.split("@", 1)[0]` берёт только первую `@`-часть, поэтому дополнительные `@` в ref-суффиксе не открывают обход.

## Что осталось вне периметра

Задача о проверке соседних входов для двух инвариантов выполнена; обходы не найдены. Прочие инварианты контракта 092 (И-1, И-2, И-3, И-5, И-6, И-7, И-9) и инварианты, не затронутые кругом 1, я не проверял — это не круг задания («не расширяй предмет»). Батарея остаётся в текущем составе: 17 красных + 4 зелёных case + 18 стабов; добавление новых клеток — на усмотрение архитектора и более поздних кругов, если потребуется.

## Вердикт

**ACCEPT.** Починки архитектора (клетки 16 и 17, стаб S18, `O92L_NETSOST` и `O92L_CHUZH_PUBDONE` в `_toy.sh`, обновление `_krasnye_092.sh` до 17/4/18) и починки автора (`|| exit 1` на первом `get_state`, `refuse(L_CHUZH_PUBDONE)` в ветке `pub-done`) совместно закрывают оба обхода круга 1. Живые соседние входы (несуществующий шов, шов с одним файлом, шов с `candidate=-`, `pub-done` с whitespace / лишним `@` / без `events.tsv`) не открывают новых обходов в этих двух инвариантах. Полный прогон зелёный, стаб-пак 18/18, диффпроба 21/21.