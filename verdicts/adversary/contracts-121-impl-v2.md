FAIL

OBJECT=501e369e827bd5e37000eb3fbff21f9eb80946ea; adversary, round 2. Позитивный контроль усиленной батареи не проходит на самом OBJECT, поэтому предмет не принят: исполнимое доказательство R3 не даёт зелёный путь.

Блокирующий репро (из изолированного клона `/tmp/dev-harness-verify/Adv121r2`, зависимости — симлинк на выданный clone):

```sh
PYTHONDONTWRITEBYTECODE=1 bash /tmp/dev-harness-worktrees/c907157c/wip-121-architect/fixtures/workshop_project/yadro_121/yadro_oracle.sh --repo /tmp/dev-harness-verify/Adv121r2
```

Результат: rc 1 за 60.08 s:

```
ОТКАЗ: yadro121: evidence-deklaraciya: derevo запись 20261021T074756Z.native — sql/errors не исполнялись в прогоне test:core
```

Это именно положительный контроль, не подмена предмета: `--repo` указывает на checkout OBJECT. Оракул уже прогнал `test:core` на свежем PG18 перед сравнением и отверг закоммиченную RUNTIME-запись как декларацию, не воспроизводимую журналом. Следовательно, R3 («evidence — запись прогона») и обязательный зелёный путь оракула не закрыты.

Отдельные выполненные контроли:

- `bash .../yadro_oracle.sh --model` → rc 0 за 19.24 s; честный мини-мир прошёл, 24/24 декоя отклонены своими причинами. Значит, батарея не является безусловно красной.
- Пустой ввод: `bash .../yadro_oracle.sh --repo ""` → rc 2, `использование: ...`; пустой путь не объявлен успехом.
- Нейтрализация `app.guard_immutable()` в отдельном одноразовом клоне: до штатного `run_core.js` скрипт выполнил `CREATE OR REPLACE FUNCTION app.guard_immutable()` с `RETURN NEW` для UPDATE и `RETURN OLD` для DELETE. Усиленный оракул вернул rc 1, `testy-ne-zelenye` за 19.48 s: текущие поведенческие immutable-тесты не дали подмене выглядеть зелёной. Это ожидаемая краснота, не находка против батареи.
- `npm run -s lint && npm run test:standards-lint` на OBJECT → rc 0 за 4.24 s.
- `git diff --quiet c525fd8d43ce3f243f8d92be72e1eedfe5375f22..501e369e827bd5e37000eb3fbff21f9eb80946ea -- migrations/001_core.sql migrations/002_rls.sql migrations/003_finance.sql migrations/004_runtime_role_fixes.sql` → rc 0; изменённые пути лежат в заявленной зоне implementer.

Нужно исправить продуктовую RUNTIME-evidence так, чтобы каждый закоммиченный `docs/evidence/core/*.native/run.json` воспроизводился целыми SQL и ошибками журналом нового `test:core` на PG18, затем повторить указанный положительный контроль. Не правились ни предмет, ни батарея; подмена guard была только в одноразовом атакующем клоне.
