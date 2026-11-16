accept
OBJECT=4448dd1554530c3bc6099e61535be3bc102b9798
КЛАСС=рисковый
СУД: repo=dev-harness; предмет=186; фаза=реализация v2 (РИСКОВЫЙ; один полный вызов, AGENTS.md шаг 7); роль=reviewer; вызов=1/1; модель-план=по config/agent_models.json (reviewer → audit → @opus → anthropic/claude-opus-5-5); сессия=Rev186Impl; модель-факт=anthropic/claude-opus-5-5; SHA=4448dd1554530c3bc6099e61535be3bc102b9798; контракт=frozen/contracts/186/2 (commit 1b515ada88cdc7330b5be4c2b6fdf49829e90156); предыдущий=verdicts/adversary/contracts-186-impl-v2-vyzov2.md (Adv186Narrow accept scoped, OBJECT 4448dd1554; ветка origin/wip/186/adversary-impl2 b246080c); исключение=нет

# Вердикт reviewer — 186 «хранитель архитектуры», реализация v2 (дверь L1 v+1), вызов 1/1

Находки и советы — `.review/2026-11-16-99.md` (status: ready). Блокирующих находок нет. Два совета (С-1 — architect, вне объекта; С-2 — косметика implementer) и три наблюдения не блокируют.

Репро — одноразовый SSH-клон `ssh://git@github.com/a3ka/dev-harness.git` в `/tmp/dev-harness-verify/Rev186Impl` со своим `.git`. HEAD detached на OBJECT, `git status --porcelain | wc -l` → `0`. Worktree не создавался, push не делался, основной `.git` не использовался.

## 1. Область правки — соответствует

```
$ git rev-parse origin/wip/186/implementer
4448dd1554530c3bc6099e61535be3bc102b9798
$ git log --format='%H %an <%ae> %s' 85afea305d..origin/wip/186/implementer
4448dd1554530c3bc6099e61535be3bc102b9798 implementer <implementer@dev-harness.local> 186 v+1: дверь L1 — поле модель-факт с левой границей, реестр от реального файла скрипта, алиас-цикл отказом
a163e3d9d65ed5c448fde1b077d1d4cc1f8d6aa2 architect <architect@dev-harness.local> 186 v+1: красные клетки вердикта Adv186Impl Н-1/Н-2/Н-3 и стабы wrong_field/symlink_cwd_registry/alias_terminal
8b86533fda0d7d4864fe2521584153da2e993aba implementer <implementer@dev-harness.local> 186 v+1: ролевые нормы называют назначение роли critic реестром
39b98241fc1d5528bec4bd7c01937a6f39292e7e implementer <implementer@dev-harness.local> 186 v+1: дверь L1 ждёт модель по назначению роли critic в реестре
$ git diff --stat 85afea305d..4448dd1554
 .omp/agents/architecture-steward.md                |   4 +-
 .omp/agents/orchestrator.md                        |   6 +-
 .../architecture_steward_186/door_control.py       |  25 ++++-
 .../architecture_steward_186/door_probe.py         | 123 ++++++++++++++++++++-
 roles/architecture-steward.md                      |   4 +-
 roles/orchestrator.md                              |   6 +-
 scripts/merge_architecture_pr.sh                   |  94 ++++++++++++++--
 7 files changed, 239 insertions(+), 23 deletions(-)
== 39b98241fc  parent=85afea305d author=implementer:  scripts/merge_architecture_pr.sh | 65 (+57 −8)
== 8b86533fda  parent=39b98241fc author=implementer:  .omp/agents/architecture-steward.md, .omp/agents/orchestrator.md, roles/architecture-steward.md, roles/orchestrator.md (+10 −10)
== a163e3d9d6  parent=8b86533fda author=architect committer=implementer:  door_control.py, door_probe.py (+143 −5)
== 4448dd1554  parent=a163e3d9d6 author=implementer:  scripts/merge_architecture_pr.sh | 39 (+34 −5)
```

- Все 7 файлов лежат в ЗОНА implementer (`scripts/merge_architecture_pr.sh`, `roles/architecture-steward.md`, `roles/orchestrator.md`, `.omp/agents/architecture-steward.md`, `.omp/agents/orchestrator.md`) или в ЗОНА architect (`fixtures/workshop_project/architecture_steward_186/`, коммит автора architect). Контракт, `registry/`, `.omp/config.yml`, `config/agent_models.json`, CI не тронуты. Контракт на OBJECT равен тегу: `git diff --quiet 'frozen/contracts/186/2^{commit}' 4448dd1554 -- contracts/186-hranitel-arhitektury.md` → `CONTRACT_SAME_AT_OBJECT`.
- Коммитов четыре, а не три, как записано в задании (см. `.review` Н-1): дверь и роли разнесены по 39b98241fc и 8b86533fda. Оба коммита implementer, оба ссылаются на 186. Атомарность соблюдена.
- Cherry-pick батареи совпадает с исходником architect байт в байт. Исходник `cfa32b681e` лежит в локальной `refs/heads/wip/186/architect` основного репозитория; проверено только чтением.

```
(основной репо, только чтение) git show cfa32b681e | git patch-id --stable
7f55bf38290131fd2da12054e42d71a7de42d64b cfa32b681ebb9d7d532ce0ba4f9bbdf2a29286a9
(клон)                          git show a163e3d9d6 | git patch-id --stable
7f55bf38290131fd2da12054e42d71a7de42d64b a163e3d9d65ed5c448fde1b077d1d4cc1f8d6aa2
sha256 door_probe.py   cfa32b681e / a163e3d9d6 / 4448dd1554: 4776f1cd86d6135d55f67b178f38334c71b92062b81e6275e51a115b98d5aa4e (все три)
sha256 door_control.py cfa32b681e / a163e3d9d6:              ee94e0e65b2e5e515365f59989709cf8fc1fa2fc3e52c02f675576a3d26b0ff5
$ git diff a163e3d9d6 4448dd1554 --stat
 scripts/merge_architecture_pr.sh | 39 ++++++++++++++++++++++++++++++++++-----
```

Время коммитов: architect `cfa32b681e` — 22:23:46, правка двери 4448dd1554 — 22:29:01. После клеток implementer батарею не трогал.

## 2. Сырой вывод приёмки (клон, HEAD=4448dd1554)

### `bash fixtures/workshop_project/architecture_steward_186/red_architecture_186.sh --repo .` → RC_REPO=0

```
186 role ok: роль зарегистрирована
186 intake ok: Находки
186 status ok: Статусы
186 l1 ok: L1
186 l2 ok: L2
186 l3 ok: L3
186 register ok: Реестр
186 register_ci ok: CI реестра
186 code_debt ok: Граница полномочий
186 review ok: Обзор
186 review_check ok: Контроль обзора
186 status_cli ok: старый/свежий/разобранный/неконформный статус
186 review_file ok: пропущенный/незакоммиченный/неполный/полный обзор
186 routing ok: routing
186 tier ok: tier
186 fallback ok: fallback
186 critic_assigned ok: critic_assigned
186 generated ok: генерация
186 done ok: сигнал architecture-done
186 blocker ok: сигнал architecture-blocker
186 schedule ok: сигнал architecture
186 door l1_merge ok: rc=0 output=СЛИТО: a3ka/CompliorOS-architecture PR 42 head d76141e5d2fa7b32d354ccbb2f37c69f25e9730e 
186 door no_accept ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door accept_other_head ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door accept_author ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door accept_fact_foreign ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door ci_red ok: rc=1 output=CI_NOT_GREEN_ON_HEAD 
186 door ci_architecture_missing ok: rc=1 output=CI_NOT_GREEN_ON_HEAD 
186 door l2_without_owner ok: rc=1 output=L2_OWNER_APPROVAL_REQUIRED 
186 door l3_without_owner ok: rc=1 output=L3_OWNER_APPROVAL_REQUIRED 
186 door no_complior ok: rc=1 output=NO_COMPLIOR_ID 
186 door author_merger ok: rc=1 output=AUTHOR_IS_MERGER 
186 door title_two_ids ok: rc=1 output=NO_COMPLIOR_ID 
186 door author_casefold ok: rc=1 output=AUTHOR_IS_MERGER 
186 door model_second_field ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door accept_not_first ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door foreign_architecture_app ok: rc=1 output=CI_NOT_GREEN_ON_HEAD 
186 door paginated_red_run ok: rc=1 output=CI_NOT_GREEN_ON_HEAD 
186 door title_lowercase_id ok: rc=1 output=NO_COMPLIOR_ID 
186 door title_suffixed_id ok: rc=1 output=NO_COMPLIOR_ID 
186 door author_unicode_lookalike ok: rc=0 output=СЛИТО: a3ka/CompliorOS-architecture PR 42 head e6bc1b156d1308a435566b52111ed3e8cacb70e4 
186 door author_space_login ok: rc=0 output=СЛИТО: a3ka/CompliorOS-architecture PR 42 head 8d84624cdce4590f73da523f6411e01b698ac9fd 
186 door author_empty ok: rc=2 output= DOOR_INFRA_ERROR: в PR нет автора — слияние невозможно судить
186 door author_bot_suffix ok: rc=0 output=СЛИТО: a3ka/CompliorOS-architecture PR 42 head 8d84624cdce4590f73da523f6411e01b698ac9fd 
186 door accept_case ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door accept_trailing_space ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door sud_no_sha ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door sud_foreign_sha ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door review_not_approved ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door model_empty_value ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door model_case_distorted ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door ci_skipped ok: rc=1 output=CI_NOT_GREEN_ON_HEAD 
186 door ci_neutral ok: rc=1 output=CI_NOT_GREEN_ON_HEAD 
186 door ci_cancelled ok: rc=1 output=CI_NOT_GREEN_ON_HEAD 
186 door ci_in_progress ok: rc=1 output=CI_NOT_GREEN_ON_HEAD 
186 door ci_two_architecture ok: rc=1 output=CI_NOT_GREEN_ON_HEAD 
186 door registry_terra ok: rc=0 output=СЛИТО: a3ka/CompliorOS-architecture PR 42 head 9ca36ff440a1081b9284fcd94e08a0750715c21b 
186 door registry_sol ok: rc=0 output=СЛИТО: a3ka/CompliorOS-architecture PR 42 head 2d878b12804d18991d27888bcb585f49c0bf4867 
186 door registry_fallback_change ok: rc=0 output=СЛИТО: a3ka/CompliorOS-architecture PR 42 head 2d878b12804d18991d27888bcb585f49c0bf4867 
186 door accept_fact_glm ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door accept_fact_fallback ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door accept_fact_same_family ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door accept_fact_superstring ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door accept_fact_padded ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door accept_fact_padded_lead_space ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door accept_fact_padded_lead_tab ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door accept_fact_padded_tail_space ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door accept_fact_padded_tail_tab ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door accept_fact_fullwidth ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door accept_fact_bare ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door accept_fact_suffixed ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door registry_missing ok: rc=1 output=CRITIC_MODEL_UNRESOLVED 
186 door registry_invalid_json ok: rc=1 output=CRITIC_MODEL_UNRESOLVED 
186 door registry_no_critic_role ok: rc=1 output=CRITIC_MODEL_UNRESOLVED 
186 door registry_no_tier ok: rc=1 output=CRITIC_MODEL_UNRESOLVED 
186 door registry_alias_unresolvable ok: rc=1 output=CRITIC_MODEL_UNRESOLVED 
186 door registry_model_empty ok: rc=1 output=CRITIC_MODEL_UNRESOLVED 
186 door field_renamed_foreign ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door field_inside_other_name ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door field_after_separator_spaces ok: rc=0 output=СЛИТО: a3ka/CompliorOS-architecture PR 42 head f4125bd144d8a1556ddb19811f937be73b0d6a52 
186 door symlink_foreign_registry ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door own_tree_foreign_neighbor ok: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door alias_cycle_honest_fact ok: rc=1 output=CRITIC_MODEL_UNRESOLVED 
186 door alias_cycle_fact_alias ok: rc=1 output=CRITIC_MODEL_UNRESOLVED 
186 door alias_other_family_control ok: rc=0 output=СЛИТО: a3ka/CompliorOS-architecture PR 42 head f4125bd144d8a1556ddb19811f937be73b0d6a52 
186 door checkout_main_l1 ok: rc=1 output=CHECKOUT_NOT_AT_PR_HEAD 
186 door checkout_main_l2 ok: rc=1 output=CHECKOUT_NOT_AT_PR_HEAD 
186 door checkout_main_l3 ok: rc=1 output=CHECKOUT_NOT_AT_PR_HEAD 
186 door dirty_untracked_l1 ok: rc=1 output=CHECKOUT_DIRTY 
186 door dirty_modified_l1 ok: rc=1 output=CHECKOUT_DIRTY 
186 door dirty_baseline_swap_l3 ok: rc=1 output=CHECKOUT_DIRTY 
186 door dirty_reverted_l1 ok: rc=0 output=СЛИТО: a3ka/CompliorOS-architecture PR 42 head 742444805d739b349a2856263466f5b1bd8381b1 
186 door detached_head_l1 ok: rc=0 output=СЛИТО: a3ka/CompliorOS-architecture PR 42 head 742444805d739b349a2856263466f5b1bd8381b1 
186 door other_branch_at_head ok: rc=0 output=СЛИТО: a3ka/CompliorOS-architecture PR 42 head 178d8078550fb2e72a879ac07e452862a9d3783b 
186 door no_git ok: rc=2 output= DOOR_INFRA_ERROR: git rev-parse HEAD: fatal: not a git repository (or any of the parent directories): .git
186 door shallow_clone ok: rc=2 output= DOOR_INFRA_ERROR: gh pr merge 42 -R a3ka/CompliorOS-architecture --merge --match-head-commit 178d8078550fb2e72a879ac07e452862a9d3783b: fatal: invalid reference: main
Traceback (most recent call last):
  File "/tmp/arch-door-186-ekihs66_/bin/gh", line 25, in <module>
    subprocess.run(['git', 'switch', '-q', 'main'], check=True)
  File "/usr/lib/python3.12/subprocess.py", line 571, in run
    raise CalledProcessError(retcode, process.args,
subprocess.CalledProcessError: Command '['git', 'switch', '-q', 'main']' returned non-zero exit status 128.
186 pin pin_merged ok: rc=0 output=ПИН ВЕРЕН: a3ka/CompliorOS-architecture merge f2a29c2ffd45a132c27db8dc7e73ab683f6d9ad9 ← COMPLIOR-186 
186 pin lock_missing ok: rc=1 output=ARCHITECTURE_LOCK_MISSING 
186 pin pin_missing ok: rc=1 output=ARCHITECTURE_PIN_MISSING 
186 pin pin_wrong ok: rc=1 output=ARCHITECTURE_PIN_MISMATCH 
186 pin pin_arch_head ok: rc=1 output=ARCHITECTURE_PIN_MISMATCH 
RC_REPO=0
```

Traceback в `shallow_clone` — stderr fake-`gh` toy-мира. Клетка ждёт rc 2 («нечем судить»), и получен rc 2.

### `… --model` → RC_MODEL=0

Набор строк тот же, что в `--repo`, все `ok`. Отличия только в output: у позитивных клеток пустой output (`186 door l1_merge ok: rc=0 output= `), у `foreign_architecture_app` — `output=CI_FOREIGN_ARCHITECTURE_APP`, у `no_git` — `output= DOOR_INFRA_ERROR: fatal: not a git repository …`, у `shallow_clone` — `output= DOOR_INFRA_ERROR: fatal: invalid reference: main` плюс тот же traceback fake-`gh`. Последняя строка — `RC_MODEL=0`. Число строк `ok` — 101, совпадает с `--repo`.

### `… --stabs` → RC_STABS=0

```
186 STAB no_frontmatter caught @ role: нет frontmatter
186 STAB humans_only caught @ intake: нет обязанности Находки
186 STAB silent_overdue caught @ status_cli: просрочка без именованной строки и rc 1
186 STAB invalid_status caught @ status_cli: неконформный статус скрывает просрочку
186 STAB review_without_file caught @ review: нет обязанности Обзор
186 STAB silent_missing_review caught @ review_file: нет отчёта оркестратору при пропуске done
186 STAB uncommitted_review caught @ review_file: непереданный в PR файл выдаётся за коммит обзора
186 STAB incomplete_review caught @ review_file: пустое содержание выдаётся за обзор
186 STAB no_register_ci_task caught @ register_ci: нет обязанности CI реестра
186 STAB l1_not_pr caught @ l1: нет обязанности L1
186 STAB l1_self_merge caught @ l1: нет обязанности L1
186 STAB l1_same_commit caught @ l1: нет обязанности L1
186 STAB l2_self_merge caught @ l2: нет обязанности L2
186 STAB l3_self_merge caught @ l3: нет обязанности L3
186 STAB l3_no_recommendation caught @ l3: нет обязанности L3
186 STAB writes_code_or_judges caught @ code_debt: нет обязанности Граница полномочий
186 STAB no_roadmap_priority caught @ register: нет обязанности Реестр
186 STAB plan_astra caught @ tier: неверный tier
186 STAB tier_astra caught @ tier: неверный tier
186 STAB wrong_fallback caught @ fallback: неверный fallback
186 STAB no_role_map caught @ routing: неверный routing
186 STAB critic_role_deleted caught @ critic_assigned: неверный critic_assigned
186 STAB critic_tier_missing caught @ critic_assigned: неверный critic_assigned
186 STAB critic_alias_broken caught @ critic_assigned: неверный critic_assigned
186 STAB critic_model_empty caught @ critic_assigned: неверный critic_assigned
186 STAB route_statistics caught @ routing: неверный routing
186 STAB route_rule_deleted caught @ routing: неверный routing
186 STAB blocker_missing caught @ blocker: action architecture-blocker rc=2
186 STAB blocker_arm_deleted caught @ blocker: action architecture-blocker rc=2
186 STAB calendar_only caught @ done: action architecture-done rc=2
186 STAB timer_start caught @ schedule: timer не диспатчит architecture
186 STAB stale_generated caught @ generated: генерация расходится rc=1
186 STAB no_timer caught @ schedule: нет страховочного timer
186 door skip_accept caught: rc=0 output= 
186 door skip_head caught: rc=0 output= 
186 door skip_author caught: rc=0 output= 
186 door skip_family caught: rc=0 output= 
186 door stub_hardcode_glm caught: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door stub_hardcode_gpt caught: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door stub_first_tier caught: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door stub_silent_glm_fallback caught: rc=1 output= File "/tmp/arch-door-186-4gvwsxsc/control.py", line 100
    critic_model = 'zai/glm-5.3'
    ^
IndentationError: expected an indented block after 'if' statement on line 99
186 door stub_fallback_tolerated caught: rc=0 output= 
186 door stub_family_prefix caught: rc=0 output= 
186 door stub_substring caught: rc=0 output= 
186 door stub_strip_fact caught: rc=0 output= 
186 door stub_lstrip_fact caught: rc=0 output= 
186 door stub_rstrip_fact caught: rc=0 output= 
186 door stub_nfkc caught: rc=0 output= 
186 door stub_bare_equiv caught: rc=0 output= 
186 door stub_endswith caught: rc=0 output= 
186 door skip_ci caught: rc=0 output= 
186 door skip_architecture_ci caught: rc=0 output= 
186 door skip_baseline caught: rc=0 output= 
186 door skip_l3 caught: rc=1 output=L2_OWNER_APPROVAL_REQUIRED 
186 door skip_id caught: rc=0 output= 
186 door skip_merger caught: rc=0 output= 
186 door skip_head_pin caught: rc=0 output= 
186 door skip_unique_id caught: rc=0 output= 
186 door skip_id_case caught: rc=0 output= 
186 door skip_id_edge caught: rc=0 output= 
186 door skip_login_casefold caught: rc=0 output= 
186 door skip_login_unicode caught: rc=1 output=AUTHOR_IS_MERGER 
186 door skip_login_space caught: rc=1 output=AUTHOR_IS_MERGER 
186 door skip_login_empty caught: rc=0 output= 
186 door skip_login_bot caught: rc=1 output=AUTHOR_IS_MERGER 
186 door skip_sud_fields caught: rc=0 output= 
186 door skip_model_empty caught: rc=0 output= 
186 door skip_model_case caught: rc=0 output= 
186 door skip_sud_sha caught: rc=0 output= 
186 door skip_sud_sha_value caught: rc=0 output= 
186 door skip_review_state caught: rc=0 output= 
186 door skip_accept_first caught: rc=0 output= 
186 door skip_accept_case caught: rc=0 output= 
186 door skip_accept_space caught: rc=0 output= 
186 door skip_ci_app caught: rc=0 output= 
186 door skip_ci_pages caught: rc=0 output= 
186 door skip_ci_skipped caught: rc=0 output= 
186 door skip_ci_neutral caught: rc=0 output= 
186 door skip_ci_cancelled caught: rc=0 output= 
186 door skip_ci_status caught: rc=0 output= 
186 door skip_ci_siblings caught: rc=0 output= 
186 door skip_head_checkout caught: rc=0 output= 
186 door skip_dirty caught: rc=0 output= 
186 door wrong_field caught: rc=0 output= 
186 door wrong_field_foreign_name caught: rc=0 output= 
186 door stub_separator_tight caught: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door symlink_cwd_registry caught: rc=0 output= 
186 door cwd_registry caught: rc=1 output=CRITIC_MODEL_UNRESOLVED 
186 door alias_terminal caught: rc=0 output= 
186 door alias_terminal_honest_fact caught: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door stub_alias_any_family caught: rc=1 output=CRITIC_MODEL_UNRESOLVED 
186 pin skip_pin_check caught: rc=0 output= 
186 pin skip_pin_field caught: rc=0 output= 
186 pin compare_arch_head caught: rc=0 output= 
186 pin accept_any_sha caught: rc=0 output= 
RC_STABS=0
```

`stub_silent_glm_fallback` «пойман» через `IndentationError` — это плацебо-стаб во frozen-батарее (6c293583, architect), вне объекта суда. Свойство прикрыто живыми клетками `registry_*` на реальной двери. См. `.review` С-1.

### Генерация, usage, ПРОВОДКА

```
$ node --version
v26.5.1
$ npm run gen:harness -- --check
> dev-harness@0.0.0 gen:harness
> node scripts/gen-harness.ts --check
харнес соответствует roles/ (13 ролей)
RC_GEN=0
$ { bash scripts/merge_architecture_pr.sh; rc=$?; echo "door_noargs_rc=$rc"; [ $rc -eq 2 ]; }; echo "RC_NOARGS_CHECK=$?"
использование: merge_architecture_pr.sh <корень-CompliorOS-architecture> <номер-PR>
door_noargs_rc=2
RC_NOARGS_CHECK=0
$ bash scripts/check_provodka.sh . contracts/186-hranitel-arhitektury.md; echo "RC_PROVODKA=$?"
RC_PROVODKA=0
```

### Счёт своей мерой (B2d)

Заявлено 101 клетка `--repo` и 95 пойманных стабов при 0 живых. Проверено двумя независимыми способами.
- Ручной поимённый подсчёт строк вывода выше. `--repo`: probe 21 + door 75 + pin 5 = **101**, KRASNO нет. `--stabs`: STAB 33 + door 58 + pin 4 = **95**, ZHIV нет.
- Статический подсчёт словарей батареи через `ast` (`/tmp/dev-harness-verify/Rev186Impl-work/count_cells.py`, вне репо): `CASES 75`, `MUTATIONS 58`, `TOY_MODELS 7`. Сходится с door 75 и door-стабами 58.

## 3. Проверка не подогнана под код — красное предъявлено

Клетки Н-1/Н-2/Н-3 и стабы написаны architect (`cfa32b681e`, 22:23:46) до правки двери (4448dd1554, 22:29:01). Из удалённых строк батареи только перезаякорение существующего стаба `skip_sud_fields` на новую форму контрольной модели и замена контрольных строк `door_control.py`. Ни одна клетка CASES не удалена и не ослаблена:

```
$ git show a163e3d9d6 --format= -U0 | grep -E '^[-+]' | grep -vE '^\+\+\+|^---' | grep '^-'
-    return model if isinstance(model, str) and model.strip() else None
-        fields = sud[0].split('модель-факт=') if len(sud) == 1 else []
-батареей не читается, перестановки реестра правки кода не требуют."""
-    'skip_sud_fields': ("fields = sud[0].split('модель-факт=') if len(sud) == 1 else []",
-                        "fields = sud[0].split('модель-факт=')[1:] if sud else []",
```

Ниже прогон `--repo` на a163e3d9d6, то есть на двери 8b86533fda с клетками architect. Ровно пять KRASNO, rc 1:

```
$ git checkout -q --detach a163e3d9d6 && git rev-parse HEAD
a163e3d9d65ed5c448fde1b077d1d4cc1f8d6aa2
$ bash …/red_architecture_186.sh --repo . 2>&1 | grep -v ' ok:'; echo "RC_REPO_A163=${PIPESTATUS[0]}"
186 door field_renamed_foreign KRASNO: rc=0 output=СЛИТО: a3ka/CompliorOS-architecture PR 42 head fe4190e3d37fbbd6c06d9f5ed334ac6b5ea22e7f 
186 door field_inside_other_name KRASNO: rc=0 output=СЛИТО: a3ka/CompliorOS-architecture PR 42 head fe4190e3d37fbbd6c06d9f5ed334ac6b5ea22e7f 
186 door symlink_foreign_registry KRASNO: rc=0 output=СЛИТО: a3ka/CompliorOS-architecture PR 42 head 07603687a5215507e9c83ac0909a97ea7e56513d 
186 door alias_cycle_honest_fact KRASNO: rc=1 output=NO_CRITIC_ACCEPT_ON_HEAD 
186 door alias_cycle_fact_alias KRASNO: rc=0 output=СЛИТО: a3ka/CompliorOS-architecture PR 42 head 07603687a5215507e9c83ac0909a97ea7e56513d 
Traceback (most recent call last):            # stderr fake-gh клетки shallow_clone, клетка ok
  …
RC_REPO_A163=1
$ git checkout -q --detach 4448dd1554 && git rev-parse HEAD
4448dd1554530c3bc6099e61535be3bc102b9798
```

На OBJECT те же пять клеток `ok` (раздел 2). Контроли `field_after_separator_spaces`, `own_tree_foreign_neighbor` и `alias_other_family_control` зелёны и до, и после правки. Значит, правка не пере-жата: законный `; модель-факт=` с пробелами, своё дерево без симлинка и алиасность чужой семьи слиянию не мешают. Правка закрывает ровно эти пять клеток — честное закрытие, а не подгонка.

## 4. Инварианты v+1 и сохранённые обязательства — по коду двери на OBJECT

- **ПУТЬ РЕЕСТРА** — соответствует. `scripts/merge_architecture_pr.sh:79-84`: `SCRIPT_PATH="$(readlink -f -- "${BASH_SOURCE[0]}")"`; `SCRIPT_ROOT=dirname(SCRIPT_PATH)`; `REGISTRY="$SCRIPT_ROOT/../config/agent_models.json"`. Путь вычисляется от реального файла скрипта, а не от cwd, каталога ссылки или корня проекта. Если readlink не сработал — rc 2 (`DOOR_INFRA_ERROR`). Реестр передаётся в Python явным argv. Клетки: `symlink_foreign_registry`, `own_tree_foreign_neighbor`; стабы: `symlink_cwd_registry`, `cwd_registry`.
- **ЦЕПОЧКА** — соответствует. `assigned_critic_model()` (`:95-129`) идёт по цепочке `roles.get('critic')` → `tiers[name]` → `.model` (обязан начинаться с `@`) → `models[alias[1:]]`. Конец цепочки — только непустая строка, не начинающаяся с `@` (Н-3). На реестре OBJECT получается `critic → apex-sol → @glm → zai/glm-5.3`; проверено собственным разбором `config/agent_models.json`.
- **СРАВНЕНИЕ литеральное по полной строке** — соответствует. `:260-266`: имя поля привязано к левой границе (`re.findall(r'(?:\A|;[ \t]*)модель-факт=', sud[0][5:])` ровно 1, Н-1), `split('модель-факт=')` даёт ровно 2 части, и `fields[1].split(';', 1)[0] != critic_model` сравнивается без strip/casefold/NFKC, без bare-формы, семейства и fallback. Назначенная строка остаётся байт в байт: `model.strip()` только проверяет пустоту и значение не меняет. Клетки: 13 `accept_fact_*` и `model_case_distorted`, `field_*`.
- **ОТКАЗ `CRITIC_MODEL_UNRESOLVED` до сетевых вызовов** — соответствует. `:200-202` вызывает `assigned_critic_model()` и `refuse('CRITIC_MODEL_UNRESOLVED')` (rc 1) раньше первого `gh_json` (`:204`). Отказывают отсутствующий файл (OSError), невалидный JSON (ValueError), корень не объект, нет `roles.critic`, нет тира, алиас не разрешается, пустая или пробельная модель, алиас-цикл или алиас-в-алиас. Молчаливого fallback на GLM нет. Клетки: 6 `registry_*` и 2 `alias_cycle_*`.
- **env `ARCH_CRITIC_MODEL` удалён** — соответствует. Поиск `ARCH_CRITIC_MODEL` по дереву OBJECT находит его только в contracts/186 (текст нормы) и в старых вердиктах. В `scripts/`, `ops/`, `roles/` и батарее его нет. `ARCH_CRITIC_LOGINS` сохранён (`:73`).
- **Сохранённые обязательства не ослаблены.** Дифф `85afea305d..4448dd1554` по двери касается только заголовочного комментария п. 3, блока env/реестра, функции `assigned_critic_model`, вызова отказа и разбора поля. Пин head/SHA (`commit_id != sha`, `endswith('; SHA=' + sha)`, `CHECKOUT_NOT_AT_PR_HEAD`/`CHECKOUT_DIRTY`), независимый автор (`AUTHOR_IS_MERGER`, `login == author → continue`), зелёный architecture CI с `app.slug=github-actions` и `--paginate`, классификация baseline (L2/L3 отказы до `BASELINE_NOT_PASS`) и единственный `gh pr merge … --merge --match-head-commit sha` в конце не изменены. Их клетки зелёны (раздел 2).

## 5. ПРОВОДКА-строки ролей совпадают с оракулами `role=` frozen 186/2 побайтово

Своя мера — скрипт `/tmp/dev-harness-verify/Rev186Impl-work/oracle_cmp.py` вне репо. Он берёт текст между «» из `- role=` контракта по тегу и ищет точное совпадение со строкой файла:

```
roles/architecture-steward.md exact_line_hits= [124] oracle_bytes= 1123
.omp/agents/architecture-steward.md exact_line_hits= [127] oracle_bytes= 1123
roles/orchestrator.md exact_line_hits= [446] oracle_bytes= 1234
.omp/agents/orchestrator.md exact_line_hits= [449] oracle_bytes= 1234
```

Совпадают и строки ролей, и сгенерированные агенты. Это согласуется с `check_provodka` rc 0 и `gen:harness --check` rc 0. Прозаическая строка `roles/orchestrator.md:438` («accept критика на том же head с моделью-фактом, равной назначенной модели роли critic из `config/agent_models.json`») согласована с нормой. Упоминаний «critic GLM» в `roles/` и в двери не осталось. Копии со старой формулировкой есть только в фикстурах чужого предмета `fixtures/workshop_project/normy_roley_svyazki_192/{base,model}`: это снимок-основа 192, вне 186.

## 6. Два совета адверсария — вне предмета, не блокируют

Отдельный предмет не нужен ни по одному (обоснование — `.review` Н-2).
- Пустой `ARCH_CRITIC_LOGINS` не расширяет допуск: остаётся штатный `critic` плюс все прочие условия. Семантику «пусто = выключить дверь» контракт не задаёт, это новый замысел.
- Дубли ключей JSON: и `json.load` двери, и `JSON.parse` генератора (`scripts/roles.ts:253`) берут последнее вхождение. Действующее назначение у двери и у производных `.omp` одно.

## Паразитная сложность (контракт 050)

- **`assigned_critic_model()` + отказ `CRITIC_MODEL_UNRESOLVED`.** (1) Требуют ЦЕПОЧКА и ОТКАЗ v+1. (2) Состояние явное: путь реестра приходит argv, результат — строка или None, отказ печатается именем. (3) При следующей правке того же свойства меняются 1 файл двери и батарея — столько же, сколько было с env+дефолтом. (4) Интерфейс сузился: env `ARCH_CRITIC_MODEL` ушёл, добавлен один код отказа rc 1; модуль глубокий. (5) Потребители — клетки `registry_*`, `alias_*`, `critic_assigned`. Цепочка повторяет `resolveModelRef` из `scripts/roles.ts`, но дверь — Python в bash-heredoc без node, и терминальная проверка строже. **ESSENTIAL**.
- **`SCRIPT_PATH`/`SCRIPT_ROOT`/`REGISTRY` с `readlink -f`.** (1) Требует ПУТЬ РЕЕСТРА. (2) Путь явный, передаётся argv. (3) 1 файл. (4) Добавлен путь rc 2 `DOOR_INFRA_ERROR` на сбой readlink. (5) Клетки `symlink_foreign_registry`, `own_tree_foreign_neighbor`. `pwd -P` после `readlink -f` избыточен, но безвреден (С-2). **ESSENTIAL**.
- **Граница поля `bounded`.** (1) СРАВНЕНИЕ: поле `модель-факт=` строки СУД. (2) Нет состояния. (3) 1 файл. (4) Интерфейс не меняется. (5) Клетки `field_*`. **ESSENTIAL**.
- **Терминальная проверка алиаса.** (1) ОТКАЗ «неразрешимый алиас». (2–4) Нового состояния и интерфейса нет. (5) Клетки `alias_cycle_*` и контроль `alias_other_family_control`. Первое условие в дизъюнкции избыточно (С-2). **ESSENTIAL**.

ACCIDENTAL-находок с блокирующей силой нет.

СВЕРКА-СТАНДАРТОВ: `AGENTS.md` dev-harness не объявляет ни документа архитектуры, ни стандарта кода (поиск `ARCHITECTURE.md|CODING-STANDARDS|стандарт кода` по `AGENTS.md` ничего не нашёл), сверять не с чем — неприменимо.

## Атомарность и норма

Каждый коммит — один предмет с отсылкой «186 v+1», авторы различимы по `user.name` (implementer / architect). Нормативные документы (контракт, AGENTS.md, нормы чужих ролей) не тронуты. Изменены только ПРОВОДКА-строки 186 в `roles/architecture-steward.md` и `roles/orchestrator.md` — парно с оракулами frozen 186/2, как требует §«Затронутые места».

## Итог

**accept.** Реализация 186 v2 на OBJECT 4448dd1554 выполняет все обязательства §Дельта v+1: ПУТЬ РЕЕСТРА, ЦЕПОЧКА, литеральное СРАВНЕНИЕ, ОТКАЗ до сети, удаление env. Сохранённые обязательства §4 не ослаблены. Область правки чиста. Красное предъявлено: 5 KRASNO на двери до правки, 0 после; клетки — architect, раньше правки. Счёт 101/95 подтверждён своей мерой. ПРОВОДКА-строки побайтно равны оракулам. Советы С-1 (плацебо-стаб `stub_silent_glm_fallback`, architect, вне объекта) и С-2 (косметика) не блокируют.

Оркестратору перед слиянием: на носителе-PR (с CI-коммитом a031af5981) проверить, что CI на итоговом SHA зелёный. Этот accept относится к OBJECT 4448dd1554 и не переносится на изменённого кандидата.
