accept

# Ревьюер — контракт 008, круг 2 перед `done`

Проверен чистый клон на HEAD `ecffb10`. Находка круга 1 из `9ee2972` закрыта: предмет больше не принимает строку `ЗОН` как раздачу, а мета-барьер предъявляет именно этот старый дефект красным.

## Область, авторство и атомарность

Сырой вывод независимого просмотра области после предыдущего вердикта:

```text
$ git diff --name-only 9ee2972..HEAD
fixtures/check_check_contract_ready/case_zone_malformed.sh
scripts/check_check_contract_ready.sh
scripts/check_contract_ready.sh
RC=0
```

Это ровно предметная правка (`scripts/check_contract_ready.sh`) и её architect-барьер/фикстура; нормативные `contracts/` и frozen-документы не менялись. История содержит два атомарных, предметных коммита:

```text
f006b26 implementer <implementer@dev-harness.local> check_contract_ready: зон-детект по грамматике ЗОНА <роль>: <путь> вместо ^ЗОН (ревьюер 008)
ecffb10 architect <architect@dev-harness.local> 008 ревьюер FAIL (9ee2972) закрыт (architect): мета-барьер +ветвь зонаформ ...
```

`f006b26` изменяет только предмет; `ecffb10` изменяет только мета-барьер и фикстуру. Поэтому новая проверка не была написана автором исправления. `bash scripts/check_zones.sh` завершился `RC=0`; в том числе контракт 008 объявляет `scripts/check_contract_ready.sh` зоной implementer, а `scripts/check_check_contract_ready.sh` и `fixtures/check_check_contract_ready/` — зоной architect.

## Закрытие FAIL круга 1: грамматика зоны

Вручную построен корень с настоящей исполняемой красной пробой `scripts/red.sh` (RC=1) и единственной строкой `ЗОН`. Сырой вывод предмета:

```text
$ bash scripts/check_contract_ready.sh /tmp/contract-zone-malformed.M8p2iB
ОТКАЗ зон: нет валидной СТРОКИ «ЗОНА <роль>: <путь>» ни «РАБОТА НЕ РАЗДАЁТСЯ:» в /tmp/contract-zone-malformed.M8p2iB/contract.md
RC=1
```

Положительный и граничный контроли на том же корне:

```text
# contract.md: ЗОНА architect: scripts/
$ bash scripts/check_contract_ready.sh /tmp/contract-zone-malformed.M8p2iB
OK
RC=0

# contract.md: ЗОНА architect:
$ bash scripts/check_contract_ready.sh /tmp/contract-zone-malformed.M8p2iB
ОТКАЗ зон: нет валидной СТРОКИ «ЗОНА <роль>: <путь>» ни «РАБОТА НЕ РАЗДАЁТСЯ:» в /tmp/contract-zone-malformed.M8p2iB/contract.md
RC=1
```

Следовательно, исправленный regex требует роль, двоеточие и непустой путь; прежний молчаливый зелёный для `ЗОН` не воспроизводится. Мета-ветвь `зонаформ` также зелёная в полном прогоне ниже и имеет отдельную фикстуру `case_zone_malformed.sh` с `# ПРИЧИНА: не требует грамматику`.

## Красные атаки адверсария круга 1

Старый диспетчер, узнающий только постоянные заголовки toy-контрактов и печатающий `OK` для новых generic `$TOK`, подан как подставной предмет. Он красный:

```text
$ bash scripts/check_check_contract_ready.sh /tmp/contract-dispatcher.LqPLll
ОТКАЗ ветвь (зоны): контракт без зон принят RC=0 — предмет не ловит отсутствие раздачи (Н-38). Вывод: OK
RC=1
```

Подставной `judge_gate`, который зовёт fake ради маркера, но зелёный хардкодит только для старого `PASS_THIS_SHA_GREEN`, также красный против случайного SHA:

```text
$ bash scripts/check_judge_gate.sh /tmp/judge-hardcode.uhpvOD
  ok   (красный) не-зелёный CI → judge_gate RC≠0, звал check_ci_gate
ОТКАЗ ветвь (зелёный): CI зелёный (sha=GOOD-SHA-222441-220872994917362), а judge_gate дал RC=1. Вывод: FAKE-check_ci_gate sha=GOOD-SHA-222441-220872994917362 rc=0
RC=1
```

## Антиплацебо и зелёные контроли

```text
$ bash scripts/verify_antiplacebo.sh --scope check_check_contract_ready check_judge_gate
SCOPED: барьеров 2 из выборки — не для приёмки
  ok   check_check_contract_ready/case_dispatcher.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «не проверил существование»
  ok   check_check_contract_ready/case_gotov_strict.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «готовый контракт не RC=0»
  ok   check_check_contract_ready/case_zone_malformed.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «не требует грамматику»
  ok   check_check_contract_ready/case_zony_lax.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «не ловит отсутствие раздачи»
  ok   check_judge_gate/case_dispatcher_sha.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «а judge_gate дал RC»
  ok   check_judge_gate/case_krasnyj_lax.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «судья пропустил»
  ok   check_judge_gate/case_zelenyj_bypass_sha.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «НЕ передал свой»

барьеров: 2 · фикстур: 7 · предъявлено красным повторным прогоном: 7
RC=0

$ find fixtures/check_check_contract_ready fixtures/check_judge_gate -maxdepth 1 -type f -name 'case_*.sh' | wc -l
7
RC=0
```

Это не тавтология: `verify_antiplacebo` запускает каждую фикстуру, требует зелёный контроль на реальном предмете, затем сам повторяет сохранённый красный вызов. Его правило отдельно отвергает фикстуру, если подстрока `# ПРИЧИНА` видна на зелёном прогоне. Число семи подтверждено второй, иной мерой (`find | wc -l`).

## Полные предметные и раскладочные прогоны

```text
$ npm run check:contract-ready
  ok   (зоны) без зон → RC≠0, названо «зон»
  ok   (зонаформ) малформед «ЗОН» → RC≠0, названо «зон»
  ok   (проба) зелёная проба → RC≠0, названо «проб»
  ok   (пробаф) проба на несуществующий файл → RC≠0, названо «проб»
  ok   (счёт) рассогласованный счёт → RC≠0, названо «счёт»
  ok   (арбитраж) несуществующий арбитражный пункт → RC≠0, названо «арбитраж»
  ok   (готов) готовый контракт → RC=0 + «OK» в выводе
check_check_contract_ready: ветви «all» зелены
RC=0

$ npm run check:judge-gate
  ok   (красный) не-зелёный CI → judge_gate RC≠0, звал check_ci_gate
  ok   (зелёный) зелёный CI → judge_gate RC=0 + «OK» + передал sha=GOOD-SHA-225240-111882123350
check_judge_gate: ветви «all» зелены
RC=0

$ npm run check:ci-parity
workflow-команд: 21 · скриптов в приёмке: 33 · объявленных исключений: 12 · расхождений: 0
RC=0

$ bash scripts/check_contract_frozen.sh
  ok   contracts/006-scoped-izolirovannyj-gejt.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают
  ok   contracts/007-scoped-ci-i-deflake-metering.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают
  ok   contracts/008-deshevye-sudejskie-krugi.md — заморожен v2, блоб совпадает побайтово, вердикты v1..v2 разрешают
планов и контрактов на HEAD: 12 · черновиков: 3 · заморожено: 9 · реестр: full
RC=0

$ bash scripts/check_zones.sh
замороженных контрактов: 8 · объявленных авторов: 2 · коммитов в диапазонах: 191 · проверено по зонам: 126
RC=0
```

## Вердикт

**accept.** Находка круга 1 закрыта проверкой на малформедный `ЗОН`, валидный `ЗОНА architect: scripts/` остаётся зелёным, а отсутствие пути отклоняется. Старые атаки диспетчером и SHA-хардкодом предъявлены красными. Новая независимая fixture имеет реальный зелёный контроль и воспроизводимый именованный красный прогон; проверка раскладки, CI-проводки и frozen-контрактов (включая 006/007) зелёная.
