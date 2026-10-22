accept

Состояние, в котором реализация 131 нарушает предмет, при зелёных приёмочных командах, не найдено.

Проверена неизменность замороженных путей:

```sh
git diff --exit-code 'frozen/contracts/131/1^{commit}' HEAD -- 'contracts/131-*.md' 'fixtures/workshop_project/poezd_131/**'
```

rc 0; вывода нет.

Исполненные прогоны на кандидате `/tmp/dev-harness-worktrees/c907157c/wip-131-implementer`:

- `bash fixtures/workshop_project/poezd_131/red_poezd_131.sh --seed 7` — rc 0, продукт: 24/24 клеток сошлись.
- `--model --seed 1`, `--model --seed 42`, `--model --seed 99999` — каждый rc 0, модель: 24/24.
- `--stabs --seed 1`, `--stabs --seed 42`, `--stabs --seed 99999` — каждый rc 0, 22/22 варианта различены.
- `--candidate /tmp/dev-harness-worktrees/c907157c/wip-131-implementer --seed 1`, затем seed 42 и 99999 — каждый rc 0, кандидат: 24/24.
- `--candidate ... --cell c10-api-net --seed 42` — rc 0, NO_JUDGE.
- `--candidate ... --cell c24-octopus-lend --seed 99999` — rc 0, PUSH.
- `--candidate ... --cell net-takoj --seed 1` — rc 2 с `НЕЧЕМ СУДИТЬ: нет такой клетки: net-takoj`, как установлено контрактом.

Наблюдаемые контроли покрыли отсутствие доказательства, служебный хвост, смешанный и подписанный код, удаление/переименование/копирование/режим/тип, недоступность API, расхождение и отсутствие fetch, отказ двери, боковых родителей, merge- и octopus-узлы, а также немонотонные даты. Реализация использует `ci_klass.sh vorota` для каждой точки first-parent и направляет публикацию через `gitw` ровно на выбранный префикс.
