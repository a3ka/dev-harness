accept

# Review 994, круг 2 (reviewer)

- Предмет: `contracts/994-provodka-vneshnij-ci-guard.md`, `frozen/contracts/994/1`, frozen v1.
- OBJECT: `11fa8517a5ece23c9654bec39ed858e3dca07c66`. Это land-merge orchestrator, родители
  `a92e44c5` и `cf4f4b3d`.
- Фикс: implementer `cf4f4b3d` (+1/−8, `scripts/check_provodka.sh`). Блоб `263fda75` стал
  `50b95176`.
- Круг 1: `verdicts/review/contracts-994-v1.md` (FAIL, Б-1) и `.review/2026-10-18-04.md`.
- Клон: `/tmp/dev-harness-verify/rev994r2/clone` на OBJECT. Рядом worktree `old` (`e68cd7e3`, блоб
  263fda75) и `mut` (OBJECT, для мутаций). Прогоны шли строго последовательно.
- Одноразовые пробы лежат в `/tmp/dev-harness-verify/rev994r2/`: `allcontracts.py`, `mutate.sh`,
  `contbound_old.sh`, `loopform.py`, `loopcheck.sh`.

## Находки

**Блокеров нет.** Б-1 закрыт в объёме, который был доказан в круге 1. Советы С-1…С-4 круга 1
остаются советами, их статус не изменился. Новый совет — С-5, ниже. Он не блокирует.

## 1. Б-1 закрыт, поведение не изменилось

- **Б-1a.** `channel_src_indices` удалён целиком: объявление, комментарий и `+=` в цикле
  классификации. Привязка теперь `guard_idx="${channel_indices[$i]}"` (`:590`). `grep
  channel_src_indices` по блобу 50b95176 ничего не находит.
- **Б-1b.** Ветви `"#"*) break` и ```` ``` ````-ветвь из внутреннего цикла `first_enf_body_after`
  удалены. Недостижимость я проверил по коду. Цикл поля (`:230-247`) кончается одним из трёх
  способов:
  - `#`/```` ``` ```` — с `field_end_idx=$i; break`;
  - `die`;
  - концом файла.

  Значит, в `(header_idx, field_end_idx)` нет строки на `#`/```` ``` ````. Оба цикла функции
  (`:501`, `:513`) идут строго `< field_end_idx`.
- **Дифференциал, своя мера** (`allcontracts.py`). Старый (263fda75) и новый (50b95176)
  `check_provodka.sh` прогнаны на ВСЕХ 100 `contracts/*.md` дерева OBJECT. Результат: `contracts
  100 new rc histogram {1: 45, 0: 55}`, `differing 0`. rc, stdout и stderr совпадают побайтово.
- **Дифференциал на моих клетках** (`rev994/gapcells.py`, 8 клеток). Выводы old и new совпадают,
  отличается только путь скрипта в warning NUL-клетки.
- **Мутационный сдвиг (наблюдение, не дефект).** Мутант `no_cont_bound` снимает границу
  `field_end_idx` у цикла продолжений.
  - На коде круга 1 он выживал (`contbound_old.sh`: `probe rc=0 unmatched=0`): его маскировали
    удалённые дубли.
  - На OBJECT его убивают клетки `AFTER_HASH_NO_SPACE_CONTINUATION` и
    `AFTER_FENCE_LANGUAGE_CONTINUATION` (2 клетки).
  - Вывод: дубли были не просто мёртвыми, они ослабляли батарею. После удаления границу держит
    одна строка, и батарея её измеряет.

## 2. Область правки ⊆ ЗОНА

- В `a92e44c5..11fa8517` один коммит не-orchestrator: `cf4f4b3d`, автор `implementer`. Он меняет
  один файл, `scripts/check_provodka.sh`, а это ЗОНА implementer (`:64`).
- `git diff a92e44c5 11fa8517 --stat` по первому родителю land-merge даёт только
  `scripts/check_provodka.sh | 9 +--------`.
- `registry/ci-steps.tsv` фикс не трогал.
- Фикстуры, контракт и роли не тронуты. `git diff frozen/contracts/994/1 HEAD --
  contracts/994-… fixtures/check_provodka/` пуст.
- `check_zones.sh` на OBJECT даёт rc 0. Единственная FAIL-строка относится к
  `contracts/055` (грамматика ЗОНА architect). Она существовала до предмета и с 994 не связана.

## 3. Пробы и барьеры (OBJECT, последовательно)

| команда | rc | наблюдение |
|---|---|---|
| `probe.sh --cases` | 0 | `CASES executed=76 mismatches=0`; matched true 76 / false 0 |
| `probe.sh --legacy` | 0 | `LEGACY executed=18 mismatches=0` |
| `probe.sh --matrix` | 0 | 12 MODEL-строк, у каждой `valid=1`; honest `observed=0`, у обманных `observed≥1` |
| `probe.sh --self-wiring` | 0 | `REGISTRY_ONLY` 0/0, `WITHOUT_OWN_STEP` 1/1 |
| `check_provodka.sh "$PWD" contracts/991-…` | 0 | — |
| `check_provodka.sh "$PWD" contracts/993-…` | 0 | — |
| `check_provodka.sh "$PWD" contracts/994-…` | 0 | — |
| `gen_ci_steps.sh --check` | 0 | — |
| `run_ci_lane.sh check:provodka-external-994` | 0 | все режимы пробы; `git status` после прогона чист |
| `verify_antiplacebo.sh --scope check_provodka` | 0 | `барьеров: 1 · фикстур: 28 · предъявлено красным повторным прогоном: 28` |
| `check_contract_frozen.sh` | 0 | `994 — заморожен v1, блоб совпадает побайтово`; заморожено 101, реестр full |

CI проверил через `gh run list`:
- `cf4f4b3d7` `wip/994/implementer` pull_request — success;
- `f0c13535b` main push — success;
- `11fa8517a` main push — cancelled, его вытеснил следующий push.

`f0c13535b` — потомок OBJECT. Блоб `check_provodka.sh` в нём тот же, 50b95176. Diff фикстур 994,
реестра и контракта до него пуст. Поэтому зелёный main CI покрывает предмет.

## 4. Мутации реализации (своя батарея, 22 мутанта, `mutate.sh`)

Мутанты те же sed-выражения, что в круге 1. Изменилось одно: `from_start` теперь целится в
`channel_indices`, потому что `channel_src_indices` удалён.

- **Убиты: 14.**
  - `split_comma` 4, `split_colon` 5, `split_bang` 4, `split_q` 4, `split_emdash` 4;
  - `substring` 31, `no_trim_frag` 3, `unicode_ws` 5;
  - `no_cont_bound` 2 — новый, см. п.1;
  - `from_start` 4, `exc_before_exist` 1, `exc_any_body` 55, `exc_skips_rest` 3, `case_insens` 2.
- **Не применимы: 2.** `no_hash_term` и `no_fence_term` — их код удалён по Б-1b.
- **Выжили: 6.**
  - `split_endash` — принятый остаточный риск арбитража (m_dash, П3).
  - `no_blank_term` и `marker_anywhere` — эквивалентны по построению, как в круге 1.
  - `no_field_bound`, `no_dash_term`, `no_enf_term` — пробел батареи С-1, совет architect.
    Реализация на них ведёт себя верно: на OBJECT мои клетки дают rc 1
    (`GUARD_ONLY_PHRASE_AFTER_HEADING`, `CHANNEL_LINE_CARRIES_PHRASE`,
    `ADJACENT_SECOND_MARKER_DOT`), позитивный контроль — rc 0.
- **Сверка с кругом 1 своей мерой.** Круг 1 дал 13 из 22. В формулировке задания «как в круге 1
  (13/22)» счёт верен. Но в тексте моего вердикта круга 1 `no_cont_bound` пропущен в обоих
  списках, хотя он был среди 9 выживших; это подтверждает `contbound_old.sh`. Круг 2 даёт 14 из
  20 применимых. Каждый мутант, убитый в круге 1, убит и сейчас. Регресса нет.

## 5. Атомарность

`cf4f4b3d` — одна задача: в сообщении стоит «994:» и ссылка на Б-1a и Б-1b. Других задач в
коммите нет. Land-merge — отдельный коммит orchestrator.

## 6. Норма не тронута

`roles/`, `AGENTS.md`, `docs/` и контракты в diff фикса не входят.

## 7. Заявленное = сделанное (своей мерой)

- «+1/−8, один файл»: `git show --stat` даёт `1 insertion(+), 8 deletions(-)`, файл один.
- «Удалены ровно channel_src_indices и мёртвые ветви»: diff фикса — ровно 4 hunk'а. Это
  объявление с комментарием (4 строки), `+=` (1), две ветви (2) и замена индекса (1↔1). Каждый
  hunk совпадает с одной из первых пяти замен моего `rev994/simplify.py`, то есть с доказанной
  частью Б-1.
- «Поведение не изменилось»: 100/100 контрактов совпадают побайтово (п.1), 76/0 и 18/0 (п.3).
- Наблюдение по процессу. `.review/2026-10-18-04.md` по-прежнему `status: ready`, чекбоксы
  `[ ]`. Каталог `.review/` не входит в ЗОНА implementer, поэтому отметки о закрытии ставит
  оркестратор. Это не дефект предмета.

## 050: строка пяти вопросов по артефактам фикса

Фикс новых артефактов не вводит, только удаляет.
- **`channel_indices` как единственный источник индекса guard.**
  - (1) Свойство — §Инв.1, привязка к первому последующему абзацу.
  - (2) Состояние явное: массив параллелен `channel_lines` и заполняется в той же case-ветке.
  - (3) Число файлов, которые правятся вместе, уменьшилось: два параллельных массива стали одним.
  - (4) Интерфейс не изменился.
  - (5) Потребитель — клетки `SECOND_GUARD_*`/`ENF_BEFORE_CHANNEL`. `from_start` их убивает.
  - Вывод: ESSENTIAL.
- **`first_enf_body_after`.**
  - (1) Свойство — §Инв.2.
  - (2) Состояние — только `field_end_idx`, общая граница с циклом поля.
  - (3) Граница теперь живёт в одном месте. Раньше их было два.
  - (4) Интерфейс: аргумент индекса и rc 0/1. Ветвей стало меньше.
  - (5) Потребители — клетки `AFTER_*`/`WRAPPED_*`. `no_cont_bound` теперь убит.
  - Вывод: ESSENTIAL.

## Советы (не блокируют)

- **С-5 (implementer, 050, совет).** Остаток Б-1a — индексный цикл классификации `:261-262`:

  ```
  for ((j=0; j<${#channel_lines[@]}; j++)); do
    ln="${channel_lines[$j]}"
  ```

  `j` больше нигде не читается, а цикл переписывали в индексный только ради
  `channel_src_indices`. Текст Б-1a круга 1 называл этот фрагмент (`:265-266`, «прежний цикл
  `for ln in` без правки»). Но прогнанная простая форма круга 1 (`simplify.py`) цикл НЕ
  восстанавливала, то есть третья часть 050 для него тогда предъявлена не была. Поднимать его
  в блокер во втором круге значит выдвигать новый блокер, а не закрывать старый. Поэтому это
  совет.

  Простую форму я прогнал сейчас (`loopform.py` + `loopcheck.sh`): `for ln in
  "${channel_lines[@]}"; do`, +1/−2. Результат: `--cases` 76/0 rc 0, `--legacy` 18/0 rc 0,
  `--matrix` rc 0, `--self-wiring` rc 0. На 100 контрактах против OBJECT `differing=0`.
- **С-1…С-4 круга 1** остаются в силе без изменений, адресаты те же:
  - С-1 — пробел батареи по трём мутантам, architect;
  - С-2 — awk MATCH/NOMATCH и `2>/dev/null || true`, implementer, не применено;
  - С-3 — NUL;
  - С-4 — guard за корнем.
