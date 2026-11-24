accept
OBJECT=569206545b5679cec61e7d86625e3bf1921aa83f
СУД: репо=dev-harness; предмет=210; роль=reviewer; вызов=2 (scoped-исправительный, ≤1 по бюджету); фаза=реализация; модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5 (метаданные среды выполнения судьи: Model anthropic/claude-opus-5-5; `bash scripts/models_actual.sh --tsv --bind --session Rev210b | cut -f1-3` → `reviewer	anthropic/claude-opus-5-5	allowed`, rc 0); предыдущий=archive/210/reviewer-v1-fail-43eff87fb4 (FAIL Б-1); класс риска=рисковый
КЛАСС=КОДОВЫЙ. Блоков 0. Б-1 вызова 1 закрыт. Новых советов нет; С-1 и С-2 вызова 1 (`.review/2026-11-24-157.md` на `archive/210/reviewer-v1-fail-43eff87fb4`) остаются в силе.

# Вердикт reviewer — 210, реализация, вызов 2 (scoped: только Б-1, CI-реестры)

**Итог.** accept.

Исправление `569206545` (orchestrator|orchestrator) возвращает строки self-test 205 в CI-реестры побайтово. К реестрам относительно базы `14bc5c140` и текущего main `ce5a4129e` добавлено ровно по одной строке 210. Порядок `keys:` в `ci.yml` пересобран генератором, а множество ключей отличается от базы ровно ключом 210. `check_provodka` для 205 и 210 даёт rc 0, `gen_ci_steps --check` — rc 0. Регресс быстрого прогона на OBJECT зелёный.

Остальное — production 210, батарея, контракт, остаточный риск — принято вызовом 1 и в этом вызове не перепроверялось. Код, батарея и контракт между `a8123cf02` и OBJECT не менялись: список изменённых файлов ниже.

## Область

```
pwd → /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t594fb1618/m
git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/210/orchestrator-r11 refs/heads/archive/210/reviewer-v1-fail-43eff87fb4 refs/heads/main → rc 0
git switch --detach 569206545b5679cec61e7d86625e3bf1921aa83f; git rev-parse HEAD → 569206545b5679cec61e7d86625e3bf1921aa83f
git merge-base --is-ancestor a8123cf02 569206545 → rc 0
git log --format='%h %an|%cn' a8123cf02..569206545 → 569206545 orchestrator|orchestrator (один коммит)
git diff --name-only a8123cf02f398fbc4f5e0eb247c2c8b15d6dc1a5 569206545b5679cec61e7d86625e3bf1921aa83f → rc 0:
  .github/workflows/ci.yml
  registry/ci-steps.tsv
  registry/ci-zamery.tsv
git diff --stat a8123cf02 569206545 → ci.yml 12 (+6 −6), ci-steps.tsv +1, ci-zamery.tsv +1
git rev-parse origin/main → ce5a4129ed3c3d1c3ce86685f2215a7282d90464 (= ce5a4129e; main вперёд не ушёл)
```

Три файла — это зона orchestrator. Production (`check_charter.sh`, `pre-push`, `next_id.sh`, `check_contract_frozen.sh`, `check_zones.sh`), батарея `fixtures/workshop_project/charter_tekst_do_tega_210/` и контракт `contracts/210-charter-tekst-do-tega.md` в diff отсутствуют.

**Реестры против базы и main** (`git show <rev>:<файл> | diff - <файл>`, своя мера):

| файл | против `14bc5c140` | против `ce5a4129e` = `origin/main` |
|---|---|---|
| `registry/ci-steps.tsv` | rc 1; единственный hunk `324a325`: `> step	check:charter-tekst-do-tega-210-family-selftest	200	bash …red_charter_tekst_do_tega_210.sh --repo . && … --model && … --stabs` | тот же единственный hunk `324a325` |
| `registry/ci-zamery.tsv` | rc 1; единственный hunk `125a126`: `> check:charter-tekst-do-tega-210-family-selftest	200	180	0` | тот же единственный hunk `125a126` |

Вывод из таблицы:
- удалённых и изменённых строк нет;
- строки 205 (`ci-steps.tsv:324`: `step	check:provodka-gate-205-family-selftest	18	bash fixtures/workshop_project/provodka_gate_205/red_provodka_gate_205.sh --repo . && … --model && … --stabs`; `ci-zamery.tsv:125`: `check:provodka-gate-205-family-selftest	18	16	0`) побайтово равны базе и main;
- чужие строки и замеры не тронуты;
- строка 210 добавлена ровно одна, вес 200, замер 180.

**`ci.yml`** — производный файл `gen_ci_steps`:
- строки без `keys:`: `diff <(git grep -h -v 'keys:' 14bc5c140 -- .github/workflows/ci.yml) <(git grep -h -v 'keys:' HEAD -- …)` → rc 0, то есть идентичны базе;
- множество ключей JOBS (`git grep -h 'keys:' <rev> -- ci.yml | tr ' ' '\n' | sort`), база `14bc5c140` против OBJECT → единственная разница `> check:charter-tekst-do-tega-210-family-selftest`;
- то же, `a8123cf02` против OBJECT → единственная разница `> check:provodka-gate-205-family-selftest` (это и есть возврат Б-1);
- дублей ключей шагов нет: `uniq -dc` показывает только служебные токены `keys:`, `restore-keys:`, `|` и пустые, как на базе.

Перестановка ключей между джобами — штатная пересборка бинпакинга по весам. Её согласованность с реестром подтверждает `gen_ci_steps --check` rc 0.

## Проверки

Окружение: cwd = копия, `TMPDIR=/tmp/dev-harness-verify/scratch-rev210b`. Все команды — на OBJECT.

| # | Команда | rc | Вывод |
|---|---|---|---|
| 1 | `git diff --name-only a8123cf02… 569206545…` | 0 | 3 пути, все в зоне orchestrator |
| 1 | `git show 14bc5c140:registry/ci-steps.tsv \| diff - registry/ci-steps.tsv` | 1 | только `324a325` (+строка 210) |
| 1 | то же против `ce5a4129e` и `origin/main` | 1 / 1 | только `324a325` |
| 1 | `git show 14bc5c140:registry/ci-zamery.tsv \| diff - registry/ci-zamery.tsv` | 1 | только `125a126` (+строка 210) |
| 1 | то же против `ce5a4129e` и `origin/main` | 1 / 1 | только `125a126` |
| 2 | `bash scripts/gen_ci_steps.sh --check` | 0 | — |
| 2 | `bash scripts/check_provodka.sh . contracts/205-provodka-gate-profilja.md` | **0** | пусто (на `a8123cf02` в вызове 1 было rc 1 «guard не подключён») |
| 2 | `bash scripts/check_provodka.sh . contracts/210-charter-tekst-do-tega.md` | 0 | пусто |
| 2 | `git grep -c 'provodka-gate-205' -- registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml` | 0 | `ci.yml:1`, `ci-steps.tsv:1`, `ci-zamery.tsv:1`. В `ci.yml:284` ключ стоит в `keys:` JOBS. Для контраста: на `a8123cf02` тот же grep не находит ничего, на `14bc5c140` — по 1 в каждом из трёх |
| 3 | `bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --repo .` | 0 | `ИТОГ 210: KLETKI=314 ZELENYE=314 KRASNYE=0` |
| 3 | то же `--model` | 0 | `ИТОГ 210: KLETKI=314 ZELENYE=314 KRASNYE=0` |
| 3 | `bash scripts/pre_critic.sh contracts/210-charter-tekst-do-tega.md` | 0 | «гейт предпосылок … ok; модель угроз красна; потолки красны; проводка красна; сдаточный лист красен; КРИТИК: дверь зелёная». Общее время шага 3 — 667 с |

Своя мера для счётных утверждений постановки:
- «+1 строка 210» — по `diff` против трёх ревизий, а не по сообщению коммита;
- «JOBS пересчитан» — по разности множеств ключей, а не по `--check`;
- «строки 205 побайтово» — по отсутствию в `diff` удалённых и изменённых строк.

Цифры 314/314/0 сняты из вывода самой батареи. Собственный пересчёт клеток сделан вызовом 1 на неизменённой батарее.

## Блоки

Нет.

Б-1 вызова 1 (OBJECT `a8123cf02` снимал self-test 205 с CI) закрыт. Обязательства frozen/contracts/210/1 выполнены, что подтверждают меры §Область и §Проверки п.2:
- ПЕРЕСЕЧЕНИЕ orchestrator — «только новая строка self-test 210; чужие строки сохраняются», «чужие замеры сохраняются», «чужая проводка сохраняется»;
- Приёмка п.7.

## НЕ ЗАЩИЩАЕТ

Без изменений против вызова 1: `archive/210/reviewer-v1-fail-43eff87fb4:verdicts/review/contracts-210-impl-v1.md` §НЕ ЗАЩИЩАЕТ. Diff этого вызова затрагивает только CI-реестры, поэтому ни одна строка остатка не задета:
- ОСТАТОК: НЗ-1 (воля человека, origin) — не укусил; в диффе нет мест.
- ОСТАТОК: НЗ-2 (plans/ROADMAP/AGENTS, /2+, octopus) — не укусил; в диффе нет мест.
- ОСТАТОК: НЗ-3 (будущие v+1-окна) — не укусил; в диффе нет мест.
- НЗ-4 (сговор автора батареи) — не мой ловец; батарея не менялась.

**Остаточный риск по решению (Adv210d, вызов 4).** `scripts/lib_zones.sh:311–314` — строковое чтение имени frozen-контракта. Риск вне зоны 210 и вне обязательств контракта; `lib_zones.sh` в diff нет ни в этом вызове, ни в вызове 1. Ловец: до отдельной задачи имя frozen-контракта — только ASCII без кавычки и обратной косой (next_id → mint), иначе стоп.

Остатки вне зоны — по списку вызова 1, этим судом не проверялись: `scripts/check_ids.sh:286`, `scripts/check_sdacha.sh:105`, `scripts/check_staged.sh:676`, `scripts/land_agent.sh:268`, `scripts/lib_plan.sh:401`, `scripts/gitw_teg_130.sh:78,83`, `scripts/lib_karta_sdachi.sh:205`, `scripts/check_protected.sh:353,357,618,642,644`, `scripts/lib_zones.sh:311–314`.

Паразитная сложность (050): новых артефактов нет. Строка `check:charter-tekst-do-tega-210-family-selftest` в двух реестрах и ключ JOBS:
1. ПРОВОДКА 210 и Приёмка п.7.
2. Состояние явное: вес и замер в реестре.
3. Число совместно меняемых файлов — 3, как у любой CI-строки.
4. Интерфейс не вырос.
5. Потребитель — шаг CI.

Итог — ESSENTIAL. Вернувшаяся строка 205 — чужая и прежняя.

СВЕРКА-СТАНДАРТОВ: `AGENTS.md` станции документов архитектуры и стандарта кода не объявляет (вызов 1). Дифф — только данные CI-реестров и производный `ci.yml`.

СВЕРКА-АРХИТЕКТУРЫ:
- размещение — в существующих реестрах зоны orchestrator;
- зависимости и операции не меняются;
- писатель `ci.yml` — `gen_ci_steps --write` (`--check` rc 0);
- `bindings.json` и `tooling/checks/cli.js` в дереве нет, diff модели L0;
- долг не расширен.

## Советы

Новых нет. С-1 (`check_contract_frozen.sh:95–99`, построчная запись области после NUL-чтения) и С-2 (`next_id.sh:301`, не-local `keep`) вызова 1 — прежние, implementer, `.review/2026-11-24-157.md` на `archive/210/reviewer-v1-fail-43eff87fb4`. Они не блоки.
