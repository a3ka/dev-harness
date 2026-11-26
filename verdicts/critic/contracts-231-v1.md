accept
OBJECT=9fefb172db9dc41650ab2ec3238f89c02e788f30
СУД: репо=dev-harness; предмет=231; фаза=контракт; роль=critic; вызов=2 (узкий, по дельте Architect231c); сессия=Crit231b; модель-факт=openai-codex/gpt-6.1-terra; автор Architect231c — модель по доступным метаданным не установлена; предыдущий=FAIL 4ad679feda7bd00e8884ee77a6d74a62d6db4285; исключение=нет.

## Закрытие прежнего блока

К-04/К-07 закрыт: contracts/231-sovmestimost-doski-224.md:16,39,67,104–105,187 и contracts/224-svezhest-verdikta-done.md:56 согласуют общий самостоятельный установщик, его область и проверку в двух режимах. Сопоставление 4ad679fed и OBJECT: probe.py 224 только добавляет установку Git, конфиг, схему и пины; предыдущие CASES и ожидания не изменены. Сохранены оба отдельных отказа DUPLICATE. В 224 изменено описание установщика батареи, не ослабление двери. Отдельные коммиты правки frozen-путей содержат адресные строки РАЗРЕШИЛ-ВЛАДЕЛЕЦ: R-0162 (224: 46e2be35 и b8e1d419; 201: c87f672f).

Собственное воспроизведение в одноразовом клоне: `python3 -B tmp/critic231_attacks.py` (rc 0). Старый и новый install извлечены соответственно из `git show 4ad679fed:.../probe.py` и OBJECT, оба вызывают действительный suite 224 на reference 231. Независимый TMPDIR — пустой вложенный Git без HEAD; checkout TMPDIR — внутри клона. Сырой вывод:

```
before-checkout historic186 RAW 0 b'' b''
before-checkout historic186 GREEN
before-checkout historic129 RAW 0 b'' b''
before-checkout historic129 GREEN
RESULT before checkout RED 0
before-independent historic186 RAW 1 b'' b'done: DONE_FORMS_CONFIG\n'
before-independent historic186 RED RC,TAG_TARGET,STDERR rc=1 stderr=b'done: DONE_FORMS_CONFIG\n'
before-independent historic129 RAW 1 b'' b'done: DONE_FORMS_CONFIG\n'
before-independent historic129 RED RC,TAG_TARGET,STDERR rc=1 stderr=b'done: DONE_FORMS_CONFIG\n'
RESULT before independent RED 2
after-checkout historic186 RAW 0 b'' b''
after-checkout historic186 GREEN
after-checkout historic129 RAW 0 b'' b''
after-checkout historic129 GREEN
RESULT after checkout RED 0
after-independent historic186 RAW 0 b'' b''
after-independent historic186 GREEN
after-independent historic129 RAW 0 b'' b''
after-independent historic129 GREEN
RESULT after independent RED 0
```

Три дополнительные независимые мутации той же операции install; команда та же, каждую функцию install подменяли отдельно, входы historic186/historic129 реальные клетки. Сырой вывод:

```
no-head-independent historic186 RAW 1 b'' b'done: DONE_FORMS_CONFIG\n'
no-head-independent historic186 RED RC,TAG_TARGET,STDERR rc=1 stderr=b'done: DONE_FORMS_CONFIG\n'
no-head-independent historic129 RAW 1 b'' b'done: DONE_FORMS_CONFIG\n'
no-head-independent historic129 RED RC,TAG_TARGET,STDERR rc=1 stderr=b'done: DONE_FORMS_CONFIG\n'
RESULT no-head independent RED 2
no-schema-independent historic186 RAW 1 b'' b'done: DONE_FORMS_CONFIG\n'
no-schema-independent historic186 RED RC,TAG_TARGET,STDERR rc=1 stderr=b'done: DONE_FORMS_CONFIG\n'
no-schema-independent historic129 RAW 1 b'' b'done: DONE_FORMS_CONFIG\n'
no-schema-independent historic129 RED RC,TAG_TARGET,STDERR rc=1 stderr=b'done: DONE_FORMS_CONFIG\n'
RESULT no-schema independent RED 2
modified-policy-independent historic186 RAW 0 b'' b''
modified-policy-independent historic186 GREEN
modified-policy-independent historic129 RAW 0 b'' b''
modified-policy-independent historic129 GREEN
RESULT modified-policy independent RED 0
```

СОВЕТ contracts/231-sovmestimost-doski-224.md:67 — две положительные исторические клетки не различили добавление особого нового station_lines литерала в скопированный установщиком конфиг; он не является наблюдавшимся ранее дефектом и конкретный дополнительный литерал не показан достижимым входом, поэтому по порогу не блок. Различие данных установки можно дополнительно проверять при желании.

## Двери

Последовательный запуск `python3 -B fixtures/workshop_project/done_round_compat_231/acceptance.py` на одноразовом клоне OBJECT, rc 0. Ниже дословные итоговые строки исполненного runner; отдельные выходы команд runner записал в tmp/acceptance231 одноразового клона.

```
model RAW_RC 0 EXPECTED 0
KLETKI 99 KRASNYH 0
stabs RAW_RC 0 EXPECTED 0
STABY 25 SVJAZI 69 ZHIVYH 0
sintaksis RAW_RC 0 EXPECTED 0
catalog RAW_RC 0 EXPECTED 0
KLETKI 99 STABY 25 SVJAZI 69
repo RAW_RC 1 EXPECTED 1
KLETKI 99 KRASNYH 56
install-checkout RAW_RC 0 EXPECTED 0
install224-checkout RED 0
install-independent RAW_RC 0 EXPECTED 0
install224-independent RED 0
scripts-only RAW_RC 1 EXPECTED 1
install224-independent historic186 RED RC,TAG_TARGET,STDERR rc=1 stderr=b'done: DONE_FORMS_CONFIG\n'
install224-independent historic129 RED RC,TAG_TARGET,STDERR rc=1 stderr=b'done: DONE_FORMS_CONFIG\n'
install224-independent RED 2
regression224-checkout RAW_RC 0 EXPECTED 0
KLETKI 100 KRASNYH 0
REGRESSION224_RAW_RC 0
regression224-independent RAW_RC 0 EXPECTED 0
KLETKI 100 KRASNYH 0
REGRESSION224_RAW_RC 0
context RAW_RC 0 EXPECTED 0
ДЕКЛАРАЦИИ 84
schema RAW_RC 0 EXPECTED 0
precritic RAW_RC 0 EXPECTED 0
sdacha RAW_RC 0 EXPECTED 0
precision RAW_RC 0 EXPECTED 0
spec RAW_RC 0 EXPECTED 0
production224-checkout RAW_RC 1 EXPECTED 1
REPO review-conflict RED DIAGNOSIS rc=1 stderr=b'done: VERDICT_ROUND_CONFLICT: review: verdicts/review/contracts-777-impl-v4.md\n'
REPO adversary-conflict RED DIAGNOSIS rc=1 stderr=b'done: VERDICT_ROUND_CONFLICT: adversary: verdicts/adversary/contracts-777-impl-v4.md\n'
KLETKI 100 KRASNYH 2
production224-independent RAW_RC 1 EXPECTED 1
REPO review-conflict RED DIAGNOSIS rc=1 stderr=b'done: VERDICT_ROUND_CONFLICT: review: verdicts/review/contracts-777-impl-v4.md\n'
REPO adversary-conflict RED DIAGNOSIS rc=1 stderr=b'done: VERDICT_ROUND_CONFLICT: adversary: verdicts/adversary/contracts-777-impl-v4.md\n'
KLETKI 100 KRASNYH 2
production201 RAW_RC 0 EXPECTED 0
CELLS=62 STABS=0 FAILURES=0
production187 RAW_RC 0 EXPECTED 0
CELLS=111 STABS=0 FAILURES=0
production193 RAW_RC 0 EXPECTED 0
ИТОГ 193: rc=0 KLETKI=152 ZELENYE=152 KRASNYE=0
```

## Карта классов
К-01: без изменений с вызова 1.
К-02: без изменений с вызова 1.
К-03: чисто — вход: адресные слова R-0162 в коммитах 201/224, изменение установщика 224 не меняет дверь.
К-04: чисто — вход: contracts/231-sovmestimost-doski-224.md:39,104–105; общий install в зоне architect.
К-05: чисто — вход: contracts/231-sovmestimost-doski-224.md:67, команды двух TMPDIR и старой мутации.
К-06: без изменений с вызова 1.
К-07: чисто — вход: собственные before/after historic186 и historic129 выше, независимый и checkout TMPDIR.
К-08: чисто — вход: удаление commit и схемы из install окрашивает обе исторические клетки; прежний scripts-only стаб.
К-09: без изменений с вызова 1.
К-10: чисто — вход: suite 224 проверяет rc, stdout, stderr, цель тега и HEAD при новом install.
К-11: без изменений с вызова 1.
К-12: без изменений с вызова 1.
К-13: без изменений с вызова 1.
К-14: чисто — вход: честные checkout и независимый TMPDIR оба зелёные.
К-15: без изменений с вызова 1.
К-16: без изменений с вызова 1.
К-17: без изменений с вызова 1.
