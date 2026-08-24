FAIL

# Ревьюер — контракт 008, финальный гейт

Проверка выполнена в чистом клоне `tmp/review-contract-008` на HEAD `05ae1bf`.

## Найденные проблемы

1. **FAIL — барьер среза 1 не удерживает объявленную грамматику раздачи.**
   Класс: неполная проверка контракта / зелёный при невалидной раздаче.

   API предмета и замороженный контракт требуют строку `ЗОНА <роль>: <путь>...` либо
   `РАБОТА НЕ РАЗДАЁТСЯ: <причина>`. Реализация проверяет лишь префикс `^ЗОН`:

   ```bash
   if ! grep -qE '^ЗОН' "$CONTRACT" && ! grep -qE '^РАБОТА НЕ РАЗДАЁТСЯ:' "$CONTRACT"; then
   ```

   Поэтому не являющийся объявлением контракт с единственной строкой `ЗОН` принят как готовый.
   Это не диагностируемая ошибка входа, а молчаливый зелёный (`OK`, RC=0). Прогнанный в клоне
   различающий вход и его сырой вывод:

   ```text
   $ bash scripts/check_contract_ready.sh tmp/review-malformed-zone
   OK
   malformed_zone_probe_rc=0
   ```

   Одновременно `npm run check:contract-ready` остаётся зелёным, следовательно текущий
   meta-барьер не покрывает этот дефект: его ветвь «зоны» проверяет только полное отсутствие
   строк с данным префиксом. До проверки полной заявленной грамматики (и красной фикстуры на
   такой не-`ЗОНА` префикс) судить реализации по этому барьеру нельзя.

## Область и авторство

Команда `git log --format='%h%x09%an%x09%ae%x09%s' --name-status d708a39..HEAD` была
прогнана с RC=0. Проверенные относящиеся к 008 коммиты соответствуют ролям и зонам:

```text
05ae1bf  architect   fixtures/check_check_contract_ready/case_dispatcher.sh
                       fixtures/check_judge_gate/case_dispatcher_sha.sh
                       scripts/check_check_contract_ready.sh scripts/check_judge_gate.sh
1d4ba24  adversary   verdicts/adversary/contracts-008.md
 d1dedc8 critic      verdicts/critic/contracts-008-v2.md
 f0056d1 architect   contracts/008-deshevye-sudejskie-krugi.md (санкционированная v2 правка зон)
67dd3a7  architect   fixtures/check_check_contract_ready/ fixtures/check_judge_gate/
                       scripts/check_check_contract_ready.sh scripts/check_judge_gate.sh
c1f86e6  implementer scripts/check_contract_ready.sh scripts/judge_gate.sh
                       package.json .github/workflows/ci.yml
```

`c1f86e6` действительно нёс также два architect-файла; исключение легитимно только как
точно записанное в frozen v2 спасение `c1f86e62d30b5a0d754508457957ab54fa379935`, а
мета-барьеры затем перезабраны architect в `67dd3a7`. Независимый зонный прогон завершился
RC=0; его завершающий сырой вывод:

```text
  ok   контракт 008: коммит c1f86e62 (implementer) — СПАСЕНО, из суда зон выведен

замороженных контрактов: 8 · объявленных авторов: 2 · коммитов в диапазонах: 188 · проверено по зонам: 124
check_zones_rc=0
```

## Закрытие находки адверсария

Оба вручную построенных старых обманных предмета были поданы как `<root>/scripts/` и
покраснели. Сырой вывод:

```text
$ bash scripts/check_check_contract_ready.sh tmp/review-stubs-008/dispatcher
ОТКАЗ ветвь (зоны): контракт без зон принят RC=0 — предмет не ловит отсутствие раздачи (Н-38). Вывод: OK
dispatcher_stub_rc=1

$ bash scripts/check_judge_gate.sh tmp/review-stubs-008/sha
ОТКАЗ ветвь (красный): judge_gate не позвал check_ci_gate (нет маркера FAKE-check_ci_gate) — гейт по CI-сигналу не реализован. Вывод:
sha_stub_rc=1
```

Значит две конкретные дыры из `verdicts/adversary/contracts-008.md` (диспетчер старых
заголовков и SHA `PASS_THIS_SHA_GREEN`) закрыты. Это не отменяет найденный выше дефект
грамматики зоны.

## Прогоны и коды возврата

```text
$ bash scripts/verify_antiplacebo.sh --scope check_check_contract_ready check_judge_gate
SCOPED: барьеров 2 из выборки — не для приёмки
  ok   check_check_contract_ready/case_dispatcher.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «не проверил существование»
  ok   check_check_contract_ready/case_gotov_strict.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «готовый контракт не RC=0»
  ok   check_check_contract_ready/case_zony_lax.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «не ловит отсутствие раздачи»
  ok   check_judge_gate/case_dispatcher_sha.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «а judge_gate дал RC»
  ok   check_judge_gate/case_krasnyj_lax.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «судья пропустил»
  ok   check_judge_gate/case_zelenyj_bypass_sha.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «НЕ передал свой»

барьеров: 2 · фикстур: 6 · предъявлено красным повторным прогоном: 6
verify_antiplacebo_rc=0

$ npm run check:contract-ready
check_check_contract_ready: ветви «all» зелены
check_contract_ready_rc=0

$ npm run check:judge-gate
check_judge_gate: ветви «all» зелены
check_judge_gate_rc=0

$ npm run check:ci-parity
workflow-команд: 21 · скриптов в приёмке: 33 · объявленных исключений: 12 · расхождений: 0
check_ci_parity_rc=0

$ npm run check:scope-select
check_scope_select: ветви «all» зелены
check_scope_select_rc=0

$ npm run check:scoped-run
check_scoped_run: ветви «all» зелены
check_scoped_run_rc=0

$ npm run check:metering
барьер зелёный: 15 ветвей пройдены
check_metering_rc=0

$ bash scripts/check_contract_frozen.sh
планов и контрактов на HEAD: 12 · черновиков: 3 · заморожено: 9 · реестр: full
check_contract_frozen_rc=0
```

Предметы имеют шапку `НЕ БАРЬЕР`; meta-барьеры документируют коды возврата. Однако найденный
в первой секции молчаливый зелёный нарушает требование честного вывода и делает итоговый
вердикт отказом.
