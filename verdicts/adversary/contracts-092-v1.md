# Вердикт adversary — контракт 092, круг 1

**Судимый субъект:** `wip/092/implementer`, `33caf2ef276ba88ff826866077a3dffb4d1109f0`.

## Приговор

**BLOCKS implementation.** В реализации есть два конформных обхода инвариантов, которые обязательная красная батарея 092 не ловит. Первый превращает отсутствие состояния в успешную выдуманную сводку; второй позволяет событию публикации чужой задачи и чужого кандидата пометить опубликованной текущую задачу. Это дефекты проверки и реализации: на обоих входах субъект ведёт себя неверно, однако `fixtures/_krasnye_092.sh` остаётся зелёной.

## Живые положительные контроли

В одноразовом клоне судимого sha батарея была извлечена из `35c53bb63a876b222770223476e811d6e05bee05` и запущена против неизменённого субъекта:

```text
bash fixtures/_krasnye_092.sh
rc=0
диффпроба: честный мини-субъект зелён на всех 19 клетках семьи (rc=0)
стаб-пак 092: 17/17 поймано, диффпроба 19/19
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
ок red_checkpoint_grammar
ок red_state_outside_tree
ок red_rounds_count_events_not_files
ок red_ciwait_net_vs_timeout
ок red_pub_state_needs_proof
ок case_checkpoint_roundtrip
ок case_status_green
ок case_ciwait_green
ок case_events_idempotent_green
```

Следовательно, батарея не является вечно-красной: честный мини-субъект и все штатные клетки судимого субъекта зелёны, а её собственные 17 обманных стабов различимы.

## Пройденные обходы — дефекты батареи 092

1. **И-4: пустой `ORCH_STATE_DIR` маскируется как успешное состояние.** В новом пустом каталоге состояния был выполнен:

   ```text
   ORCH_STATE_DIR=<пустой-каталог> bash scripts/orch_status.sh
   rc=0
   stderr: состояние отсутствует                    # семь раз
   stdout:
   task: -
   stage: -
   candidate: -
   last_proven: -
   waiting: -
   next_step: -
   pub_state: unknown
   кругов: 0
   опубликовано: нет
   закрытие: не завершено
   удалённое состояние: неизвестно
   ```

   И-4 допускает `rc=1` для отсутствия состояния только с именованной причиной; он не допускает успешную семиполевую сводку несуществующего состояния. Причина в `orch_status.sh`: `get_state` вызывает checkpoint, но безусловно возвращает `0`; семь его ошибок уходят в stderr, после чего пустые значения заменяются на `-`/`unknown`. Ни одна клетка батареи не предъявляет пустой каталог состояния статусу. Поэтому полный прогон выше остаётся `rc=0` на уже неконформном субъекте.

2. **И-8: `pub-done` чужой задачи/кандидата повышает pub_state текущей.** Было создано состояние текущей задачи `092` с кандидатом `aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa` и `pub_state=pushed`. Затем выполнено конформное по грамматике, но чужое событие:

   ```text
   ORCH_STATE_DIR=<каталог> bash scripts/orch_checkpoint.sh event pub-done 999 bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb@refs/heads/main
   rc=0
   ORCH_STATE_DIR=<каталог> bash scripts/orch_checkpoint.sh get pub_state
   stdout: published
   events.tsv:
   2026-10-09T19:59:05Z	pub-done	999	bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb@refs/heads/main
   state.tsv:
   task	092
   candidate	aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
   pub_state	published
   ```

   И-8 разрешает доказательство журналом только для `pub-done <текущий task> <текущий candidate>@<target>`. Здесь не совпадают и subject, и candidate, однако ветка `ARG_KIND == "pub-done"` безусловно присваивает `m["pub_state"] = "published"`. Клетка `red_pub_state_needs_proof.sh` предъявляет лишь разрешённый журнал `pub-done` с тем же task и candidate; отрицательных соседних task/candidate она не предъявляет. Поэтому батарея снова остаётся зелёной на этом обходе.

Архитектору следует добавить самостоятельные красные входы: пустой `ORCH_STATE_DIR` для `orch_status` с обязательным `rc=1` и именованной причиной, а также `pub-done` с несовпадающими subject и candidate с обязательными отказом/неизменностью обоих файлов. Автору следует исправить субъект, не ослабляя эти инварианты.
