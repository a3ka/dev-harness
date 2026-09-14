FAIL

# Адверсарийский вердикт — контракт 025, круг к6

Судимая база: `96f95399434e9ebc71804b69ee850e5405e9fdda` (`a356d44` — собственно фикс к5). Предмет — `fixtures/check_runner_hygiene/probe025_dochernij_vector.sh`; проверки и реализация предмета не менялись. Все синтетические улики создавались вне субъекта, в `/tmp/dev-harness-verify/`; прогоны — в отдельном клоне.

## B-025-k5-1 и B-025-k5-2 действительно закрыты

Переисполнены поставленные контрпримеры:

```text
red_zond_rc_vektor_agregacija.sh
  honest rc 0; second_success rc 1; first_success rc 1; doubleblock rc 0
red_zond_null_id_skleyka.sh
  honest rc 0; null_call_shadow rc 2; null_result rc 2
```

Следовательно, успешная вторая попытка `false | true` больше не скрывается первой ошибкой, а `null` на обеих сторонах join отклоняется до канонизации строкой.

Не регрессировали ранние закрытия к3/к4:

```text
red_zond_dubl_toolcallid.sh: honest rc 0, leak rc 1, duplicate call/result rc 2
red_zond_osirotevshij_toolcallid.sh: honest rc 0, orphan call/result rc 2
red_zond_nesoglasovannost_imeni.sh: honest rc 0, mismatch edit/bash rc 2
red_zond_uspeshnyj_povtor_kanona.sh: honest/doubleblock rc 0, leak edit/bash rc 1
```

Положительный контроль моей минимальной честной MAIN+CHILD-улики также дал `rc 0`: оба относительных вектора заблокированы Н-85, `false | true` имеет raw exit 1, `yes | head` и grep успешны, child checkout блокирован, scratch успешен.

## Блокер B-025-k6-1 — обратный порядок пары обходит проверку имени инструмента

`load()` сравнивает `toolCall.name` с `toolResult.toolName` только в момент чтения `toolResult`. Если результат расположен в JSONL **до** парного вызова, `calls[rid]` ещё пуст; `cname=''`, поэтому mismatch не проверяется. После чтения позднего call полнота join всё же выглядит 1:1, но уже сохранённый `result` не обогащается командой вызова и несовместимость больше не пересматривается.

К честной MAIN-улике добавлены ровно две полностью спаренные строки с уникальным id `hidden`:

```json
{"role":"toolResult","toolCallId":"hidden","toolName":"read","isError":false,"details":{"exitCode":0}}
{"role":"assistant","content":[{"type":"toolCall","id":"hidden","name":"bash","arguments":{"command":"printf attack | tee zond_main_bash_42.txt"}}]}
```

Это та же противоречивая пара, что B-025-k4-1 (имя результата `read`, имя вызова `bash`), только с переставленным порядком строк. Вызов несёт успешную относительную bash-запись; полная двусторонняя сверка должна дать именованный `rc 2`, независимо от порядка событий. Фактический прогон:

```text
$ bash fixtures/check_runner_hygiene/probe025_dochernij_vector.sh --parse /tmp/dev-harness-verify/adv025-k6-result-first
ЗЕЛЁНОЕ 025-И-6 ...
# rc 0; ожидался rc 2 «несогласованность имени инструмента»
```

Контроль без инъекции — `rc 0`; обычная (call-before-result) подмена имени всё ещё даёт `rc 2` в `red_zond_nesoglasovannost_imeni.sh`. Значит это не вечно-красный генератор, а order-dependent join bypass. Нужна сверка имени после полного join, а не только при однопроходном чтении result.

## Блокер B-025-k6-2 — положительные вентили агрегируются только по первой попытке

В отрицательных вентилях `attribute()` и новом `rc_vector_verdict()` уже агрегируют все канонические попытки. Но положительные формы остаются first-wins:

* `canary()` берёт `r = hit[0]` для `yes | head`;
* grep берёт `cg_bash[0]` либо `cg_tool[0]`;
* allowlist-вентиль CHILD scratch берёт `r0 = canon[0]` (если среди остальных нет именно guard/policy).

Из моей честной улики сформированы отдельные улики, где добавлена ВТОРАЯ, полностью спаренная, уникальная попытка той же канонической формы с `isError:true, exitCode:1`:

```text
MAIN:  yes | head -1                 → второй результат: error/1
MAIN:  grep .omp/config.yml          → второй результат: error/1
CHILD: printf x | tee <scratch>/...  → второй результат: error/1
```

Все три прогона выдали зелёный `rc 0`, хотя в сырой стенограмме есть неуспешное исполнение легитимной канарейки/allowlist-записи. Нейтрализация только порядка подтверждает дефект: та же ошибка `yes | head`, вставленная первой, даёт ожидаемый `rc 1` с `ЛОЖНАЯ КРАСНОТА канарейки yes|head`. Следовательно, слабая (например, непостоянная) среда может пропустить один отказ положительного контракта после первой успешной попытки; решение зависит от порядка строк, а не от множества raw результатов.

Нужна агрегация всех канонических попыток и fail/red на любой неуспешной положительной попытке (либо явный fail-closed на противоречивой множественности), симметрично k4/k5. Это отдельная aggregation-дыра И-6, не write-form.

## Дополнительные проверки

* Пустой каталог улик: `rc 2`, «нет каталога сессий» — не пусто-зелёный.
* `PATH=/nonexistent` при `--parse`: `rc 2`, «python3 нет в PATH» — отсутствие инструмента не принимается за успех.
* Шесть статических инвариантных фикстур (`red_strazh_vectora_utechki`, `red_deni_patte_rny_zapisi`, `red_granica_nepin_pipe_tee`, `red_pipefail_prefiks`, `red_marker_exit`, `red_pin_allowlist`) завершились `rc 0`.
* Новые формы записи не предъявляются: это **тот же класс Н-89**, формально запаркованный, не новая находка.

## Вердикт

**FAIL.** К5 закрыт и к3/к4 не регрессировали, но И-6 по-прежнему не отличает честную среду от слабой реализации при reverse-order join с несовместимыми именами и при поздней ошибке положительной канарейки/allowlist-записи. Оба контрпримера дают зелёный на текущем HEAD при зелёном положительном контроле.
