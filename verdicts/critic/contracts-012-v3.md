accept

Обе находки `verdicts/review/contracts-012.md` закрыты.

## Находка 1 — предмет

Коммит implementer `f71b2e89dc2516ec7bd69ab9db37c77eafdc8a33` меняет ровно
четыре файла из `ЗОНА implementer` (`contracts/012-izoljacija-progonov.md:55`):
`.omp/config.yml`, `roles/orchestrator.md`, `roles/architect.md` и
`scripts/verify_antiplacebo.sh`.

Живые приёмки предмета из `contracts/012-izoljacija-progonov.md:95-109`
исполнены по отдельности: `lockdef`, `techka`, `pidrec`, `izolcfg`, `klon` и
`izolnorm` — все шесть rc=0. Независимое чтение подтвердило:

- `.omp/config.yml:102-104` — `task.isolation.mode: btrfs`;
- `roles/orchestrator.md:62-75` — `isolated: true` для параллельных пачек и
  длинный `verify_antiplacebo` только в disposable-клоне;
- `roles/architect.md:195-204` — клон роли вне стерегомого дерева,
  `${TMPDIR}/dev-harness-architect/repo`;
- `scripts/verify_antiplacebo.sh:252-268,329-405` — общий детерминированный
  default-scratch, признак владения с самозачисткой и проверка живости владельца
  одновременно по pid и pgid.

`bash scripts/verify_antiplacebo.sh --scope check_runner_hygiene` — rc=0:
1 барьер, 40 фикстур, 40 предъявлены красным повторным прогоном.

## Находка 2 — зона

Коммит architect `a1d5976e948da794d1c0dac9b688e5af26f636f7` добавил
`ЗОНА orchestrator: NABLIUDENIA.md HANDOFF.md`
(`contracts/012-izoljacija-progonov.md:59`) и ровно одно поимённое исключение
`СПАСЕНО orchestrator` для полного хеша
`e62bc2fe4dbe0a425f4dbdfadccf44c793f259eb`
(`contracts/012-izoljacija-progonov.md:60`). Состав спасённого коммита сверён:
`%an=orchestrator`, пути `.omp/agents/architect.md`, `NABLIUDENIA.md` и
`roles/architect.md`; исключение не расширяет постоянную зону на `.omp/` или
`roles/`.

Весь `git log --no-merges --name-status frozen/contracts/012/1..HEAD` проверен
по каждому коммиту и пути. После трёх orchestrator-коммитов из исходной
находки появились только зонные изменения: implementer — четыре предметных
файла; architect — контракт и `NABLIUDENIA_ARCHITECT.md`; orchestrator
`8cdeaf94` — `NABLIUDENIA.md`; critic — этот вердикт. Новых коммитов вне зон
нет.

Теги перед выбором имени сверены: существуют только `frozen/contracts/012/1` и
`frozen/contracts/012/2`, поэтому следующий вердикт —
`verdicts/critic/contracts-012-v3.md`.

Остальные гейты на актуальном дереве:

- `bash scripts/check_zones.sh` — rc=0, 251 коммит проверен по зонам;
- `npm run check:charter` — rc=0, 39/39 изменений уставных документов имеют
  разрешение.

Новых классов не пересуждалось. Блокирующих находок и советов нет.
