accept

# Ревьюер — контракт 012, третий полный финальный гейт, HEAD `eb520eb2a5e8f08c132dd84dd7c9ea20c324f413`

## Вердикт

**accept.** Новых блокирующих находок нет. Оба прежних FAIL прочитаны целиком:
`7fc8d1d:verdicts/review/contracts-012.md` (внезонные дозаморозочные записи
architect) и `3a613ec:verdicts/review/contracts-012.md` (не реализован предмет
А+Б и три внезонных orchestrator-коммита). Первый класс закрыт объявлением
`NABLIUDENIA_ARCHITECT.md` в ЗОНЕ architect; второй — предметным коммитом
implementer `f71b2e8` и v+2 контракта `a1d5976`, добавившей конечное
`СПАСЕНО e62bc2f` и ЗОНУ orchestrator. Текущий frozen `012/3` побайтово
совпадает с контрактом v3.

## Полная история диапазона и область правки

Проверен полный `git log --format='%H\t%an\t%ae\t%s' --name-status
frozen/contracts/012/1..HEAD`, а не только `check_zones.sh`. Результат: все
14 коммитов в диапазоне укладываются в объявленные ЗОНЫ либо в поимённое
СПАСЕНО:

- `10cc9b0`, `e9ed95b`, `8cdeaf9` — orchestrator / `NABLIUDENIA.md`, ЗОНА
  orchestrator;
- `e62bc2f` — orchestrator / `.omp/agents/architect.md`, `NABLIUDENIA.md`,
  `roles/architect.md`, единственное конечное **СПАСЕНО** контракта 012;
- `7fc8d1d`, `3a613ec` — reviewer / `verdicts/review/`, ЗОНА reviewer;
- `913b6b4`, `a1d5976` — architect / контракт, ЗОНА architect;
- `87ca3ed`, `422ad8c` — architect / `NABLIUDENIA_ARCHITECT.md`, ЗОНА architect;
- `f71b2e8` — implementer / `.omp/config.yml`, `roles/architect.md`,
  `roles/orchestrator.md`, `scripts/verify_antiplacebo.sh`, ЗОНА implementer;
- `f3c933f`, `a588a8e`, `eb520eb` — critic / `verdicts/critic/`, ЗОНА critic.

`f71b2e8` — один предметный коммит: он реализует ровно А+Б контракта,
затрагивает только четыре пути implementer и не меняет барьер либо фикстуры.
Следовательно, проверка не подогнана исполнителем: 40 красных предъявлений
остаются architect-артефактами. Нормативный контракт менялся только
архитектором в двух явно разрешённых v+1/v+2 поправках по предыдущим FAIL;
`npm run check:charter` подтвердил разрешённость обеих правок. Никаких
посторонних либо неатомарных новых предметных коммитов в диапазоне нет.

Сырой вывод истории:

```text
$ git log --format='%H\t%an\t%ae\t%s' --name-status frozen/contracts/012/1..HEAD
... 14 перечисленных выше коммитов, каждый с одним из указанных путей
COMMAND_EXIT_RC=0
```

## Живая приёмка предмета

Это не подмена `verify_antiplacebo` эталоном: все шесть предметных ветвей
запущены непосредственно на живом `scripts/verify_antiplacebo.sh` текущего
дерева. Сырой вывод:

```text
$ bash scripts/check_runner_hygiene.sh . lockdef
  ok   (lockdef) пустая переменная → общий default-скратч: второй прогон живого владельца отказал rc=3 «занят»
check_runner_hygiene: ветви «lockdef» зелены
COMMAND_EXIT_RC=0

$ bash scripts/check_runner_hygiene.sh . techka
  ok   (techka) завершившийся прогон не оставил под $TMPDIR новых путей; существовавший default-скратч и чужие пути неприкосновенны
check_runner_hygiene: ветви «techka» зелены
COMMAND_EXIT_RC=0

$ bash scripts/check_runner_hygiene.sh . pidrec
  ok   (pidrec) живой pid с чужим pgid опознан мёртвым владельцем: lock убран, прогон прошёл rc=0, decoy цел
check_runner_hygiene: ветви «pidrec» зелены
COMMAND_EXIT_RC=0

$ bash scripts/check_runner_hygiene.sh . izolcfg
  ok   (izolcfg) .omp/config.yml несёт task.isolation.mode: btrfs
check_runner_hygiene: ветви «izolcfg» зелены
COMMAND_EXIT_RC=0

$ bash scripts/check_runner_hygiene.sh . klon
  ok   (klon) roles/architect.md: клон роли по ${TMPDIR}/dev-harness-<роль>/repo, норма названа
check_runner_hygiene: ветви «klon» зелены
COMMAND_EXIT_RC=0

$ bash scripts/check_runner_hygiene.sh . izolnorm
  ok   (izolnorm) orchestrator: isolated: true на параллельные пачки; длинные прогоны — в disposable-клоне
check_runner_hygiene: ветви «izolnorm» зелены
COMMAND_EXIT_RC=0
```

## Красное предъявлено и обязательные гейты

Новые барьеры не являются зелёной самопроверкой: независимый от реализации
`_ref_runner.sh` дал зелёный контроль, а каждая из 40 именованных изменённых
фикстур была повторно красной. В том числе новые 012:
`case_lockdef_unikalnyj_mktemp.sh`, `case_techka_skretch_ostalsa.sh`,
`case_pidrec_bez_pgid_svorki.sh`, `case_izolcfg_bez_kljucha.sh`,
`case_klon_v_dereve.sh`, `case_izolnorm_bez_isolated.sh`.

Сырой вывод обязательных команд:

```text
$ bash scripts/verify_antiplacebo.sh --scope check_runner_hygiene
SCOPED: барьеров 1 из выборки — не для приёмки
... 40 строк «зелёный контроль есть, повторный прогон красный кодом 1»
барьеров: 1 · фикстур: 40 · предъявлено красным повторным прогоном: 40
VERIFY_ANTIPLACEBO_RC=0

$ bash scripts/check_zones.sh
... контракт 012: коммит e62bc2fe (orchestrator) — СПАСЕНО, из суда зон выведен
замороженных контрактов: 11 · объявленных авторов: 6 · коммитов в диапазонах: 252 · проверено по зонам: 174
CHECK_ZONES_RC=0

$ bash scripts/check_contract_frozen.sh
  ok   contracts/012-izoljacija-progonov.md — заморожен v3, блоб совпадает побайтово, вердикты v1..v3 разрешают
планов и контрактов на HEAD: 15 · черновиков: 3 · заморожено: 12 · реестр: full
CHECK_CONTRACT_FROZEN_RC=0

$ npm run check:charter
  ok   уставной документ изменён с разрешения владельца: contracts/012-izoljacija-progonov.md в a1d5976e
  ok   уставной документ изменён с разрешения владельца: contracts/012-izoljacija-progonov.md в 913b6b4f
  ok   contracts/012-izoljacija-progonov.md — уставной с frozen/contracts/012/1, коммитов в диапазоне 14, изменений без разрешения нет
уставных документов: 14 · изменений в них: 39 · с разрешения: 39
CHECK_CHARTER_RC=0

$ npm run check:ceilings
  ok   персоны: 8 файл(ов), потолок 51200 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 11 черновик(ов) судится, замороженные — по тегам
потолки в порядке
CHECK_CEILINGS_RC=0

$ npm run check:ci-parity
workflow-команд: 22 · скриптов в приёмке: 34 · объявленных исключений: 12 · расхождений: 0
CHECK_CI_PARITY_RC=0

$ bash scripts/check_scoped_run.sh
  ok   (л) фильтр: прогнан ровно выбранный b, RC=0
  ok   (м1) отказ «красное не предъявлено» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (м2) отказ «код 2 (нечем проверить)» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (м3) отказ «необъявленный код 7» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (н) отказ «дерево изменилось вне $WORK» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (case) --scope key/case прогоняет ровно 1 case, несуществующий case → fail-closed
  ok   (изол) HOME изолирован per-fixture: leak-игрушка отвергнута («красное не предъявлено»)
  ok   (ц) нерезолвимый base → полный прогон, RC=0
  ok   (ч) doc-only → RC=0, 0 барьеров
  ok   (ц2) пустой base → полный прогон, RC=0
  ok   (ц3) нерезолвимый ненулевой SHA → полный прогон, RC=0
  ok   (ч2) не-README нулевая выборка → RC=0, 0 барьеров
  ok   (ci) ci.yml: ИСПОЛНЯЕМАЯ run-строка гонит анти-плацебо scoped (--changed github.event.before)
check_scoped_run: ветви «all» зелены
CHECK_SCOPED_RUN_RC=0
```

Cognitive-only ограничения названы самим контрактом: `izolcfg`, `klon` и
`izolnorm` судят наличие, но не placement/единственность, а `techka` не судит
SIGKILL. Это не скрытая недопоставка и не новая находка.
