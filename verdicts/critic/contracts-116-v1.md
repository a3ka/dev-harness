accept

# 116 — финальный scoped-круг r9 по РЕШЕНИЮ 675465e2

OBJECT: `fa75c42b2721c897f57245ba92134f7d58c2a122`, ветка `wip/116/architect-r9`.
База дельты: `2dc29509b1fac3cd29528f1fb60e706ed8543810` (r8).
Предмет: `contracts/116-cmp-mob-005-mission.md`, прежде всего :31–38, :41–48, :57, :68/:75/:79.
Судья: critic / Critic116r6b. Прочитано решение `675465e2` из клона Arbiter116c.
Клон и ВСЕ собственные записи: `/tmp/dev-harness-verify/Critic116r6b/`.
Вердикт разрешает заморозку текста в согласованной границе, НЕ аттестует готовый мобильный продукт.
Push не выполнялся. Предмет и оракул не изменялись; мутации — отдельные временные субъекты.

## Решение и полнота набора

Закоммиченный предмет предъявлен на точном HEAD. Предмет, rc-критерии, исполнители и ЗОНА-строки есть.
Суд ограничен выбранной арбитром границей: статик = единственный нормализованный текстовый пин блока; required-membership и исполнение = runtime одного принимаемого C.
Правило Н-39 сохранено: реальные привязки стабов судились по `source.json`/коду и исполнению, не конструировались из прозы контракта.
Действительных блокирующих находок в этой границе нет. Контрпримеров `P ∧ static_rc≠0` или `¬P ∧ static_rc=0` на предъявленных входах — 0.

Пять обязательных вопросов:
1. **Критерий против предмета:** :37–38 отделяют лексическую форму от исполнения. Пинованный текст в чужом job статически зелён, но не удовлетворяет всей runtime-конъюнкции. Выдать статический rc 0 за доказательство required-job контракт не разрешает.
2. **Доказуемость командами:** :31–33 исполняются W; :38 задаёт Jest rc и живой `gh pr checks <PR> --repo a3ka/Complior-mob --required`, дополненный доказанной связью идентификаторов/URL, run/job, шага/лога и C. Локальный Jest-стенд доказывает только исполняемую часть, а не GitHub-membership. Именно такое разделение предписано §4–5 решения.
3. **Молчаливые решения:** критерий явно определяет начало/конец блока, нормализацию, кратность, отрицание лишних ключей; required-job и shell-семантика статике не поручены. При ленде судья обязан установить четыре факта одного C/run, не три несвязанных успеха.
4. **Границы:** все 14 изменённых файлов r8→r9 находятся в объявленной зоне architect (:41); роли суда и продукта названы (:42–48). Удаление s48–s51 и обновление субъектов находятся внутри той же зоны. Продуктовый workflow не менялся. Механизм исполнения зон — `check_zones.sh`; здесь выполнена scoped-сверка дельты с объявлением, а не полный исторический прогон заморозок.
5. **Норма:** новых противоречий AGENTS.md в судимой дельте не найдено; модель угроз согласована с разделением статик/runtime. Precision и pre_critic выполнены живыми командами. K1–K19, дизайн и PNG повторно по существу не пересуживались.

## Собственные команды и результаты

CWD команд батареи/гейтов: `/tmp/dev-harness-verify/Critic116r6b/repo`.
Для временных файлов задан `TMPDIR=/tmp/dev-harness-verify/Critic116r6b/tmp`, Python без pycache; npm/Jest cache — в собственной зоне.

```bash
python3 -B /tmp/dev-harness-verify/Critic116r6b/measure.py battery
```

Драйвер запускает дословно:
- `bash fixtures/workshop_project/mission_116/red_mission_116.sh --model`: **rc 0, CASE 51/51 ok, KADR 7**.
- `bash fixtures/workshop_project/mission_116/red_mission_116.sh --stabs`: **rc 0, CASE 51/51 ok, STAB KRASEN 38/38, SVJAZI 38, непойманных 0**.
- временно убирает только в собственном клоне `scripts/ekran_shablon.py`, запускает W без флага и восстанавливает файл: **rc 1, SHABLON_ABSENT, CASE KRASNO 51/51**.

Сырой вывод KADR:
```text
KADR	F05.01 dark	1.000	0.600	G	OK
KADR	F05.02 dark	1.000	0.600	G	OK
KADR	F05.03 dark	1.000	0.600	G	OK
KADR	F05.04 dark	1.000	0.600	G	OK
KADR	F05.05 dark	1.000	0.600	G	OK
KADR	F05.06 dark	1.000	0.600	G	OK
KADR	F05.V03 dark	1.000	0.600	G	OK
```

Независимый счёт содержимого `source.json`: **51 вход = 41 красный + 10 зелёных; 35 стабов, 38 связей**. Это не повтор счётчика W. Полные логи собственных запусков сохранены в `../evidence/model.log`, `stabs.log`, `shablon_absent.log`.

```bash
env TMPDIR=/tmp/dev-harness-verify/Critic116r6b/tmp PYTHONDONTWRITEBYTECODE=1 bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic116r6b/repo contracts/116-cmp-mob-005-mission.md
python3 -B /tmp/dev-harness-verify/Critic116r6b/measure.py gates
```

Precision: rc 0, `OK`. Драйвер gates сохраняет вывод обоих механизмов; pre_critic — rc 0:
```text
КРИТИК: дверь зелёная
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
```

## Replay 17 форм и положительные свидетели

```bash
python3 -B /tmp/dev-harness-verify/Critic116r6b/measure.py replay
python3 -B /tmp/dev-harness-verify/Critic116r6b/membership_inputs.py
python3 -B /tmp/dev-harness-verify/Critic116r6b/own_inputs.py
python3 -B /tmp/dev-harness-verify/Critic116r6b/pin_inputs.py
```

Все четыре команды rc 0. Полная CLI-проба `teksty/statika_text.py --pack <собственный pack> --repo <собственный ci-subject>`, не вызов только функции. Replay заимствует список V, но старую метку обхода чужого job заменяет новым ожиданием арбитража.

| Форма replay | static rc | отказ |
|---|---:|---|
| honest | 0 | — |
| r3_echo_comment | 1 | CI_SHAG_POVEDENIJA_NE_PO_PINU |
| critic_quoted_echo | 1 | CI_SHAG_POVEDENIJA_NE_PO_PINU |
| critic_xargs_echo | 1 | CI_SHAG_POVEDENIJA_NE_PO_PINU |
| critic_echo_subst | 1 | CI_SHAG_POVEDENIJA_NE_PO_PINU |
| arb_or_true | 1 | CI_SHAG_POVEDENIJA_NE_PO_PINU |
| arb_semicolon_true | 1 | CI_SHAG_POVEDENIJA_NE_PO_PINU |
| arb_and_or_echo | 1 | CI_SHAG_POVEDENIJA_NE_PO_PINU |
| arb_exit0_before | 1 | CI_SHAG_POVEDENIJA_NE_PO_PINU |
| arb_func_shadow | 1 | CI_SHAG_POVEDENIJA_NE_PO_PINU |
| arb_set_plus_e | 1 | CI_SHAG_POVEDENIJA_NE_PO_PINU |
| arb_background | 1 | CI_SHAG_POVEDENIJA_NE_PO_PINU |
| arb_heredoc | 1 | CI_SHAG_POVEDENIJA_NE_PO_PINU |
| arb_folded_block | 1 | CI_SHAG_POVEDENIJA_NE_PO_PINU |
| arb_shell_key | 1 | CI_SHAG_POVEDENIJA_NE_PO_PINU |
| arb_testname_filter | 1 | CI_SHAG_POVEDENIJA_NE_PO_PINU |
| arb_step_in_other_job | 0 | —, membership теперь runtime |

Итого **2 зелёных / 15 красных**, не старое ожидание 1/16. Shell-часть этого replay использует подставной npx с rc 1 и не является доказательством настоящего Jest.

`membership_inputs.py` Critic116r5 перенесён в свою зону: `indentless_steps`, `indentless_single_quote_comment`, `indentless_four_space_job`, `single_quote_comment_control` — **4/4 rc 0**, YAML равен честному, пин равен, COUNTEREXAMPLES 0.

Прежние три свидетеля `job_inline_comment`, `job_quoted_key`, `job_indent_four` и `allowed_comments` — rc 0. `changed_run_suffix`, `extra_step_key`, `duplicate_step`, `honest_cd`, `honest_multiline` — rc 1, NE_PO_PINU. Итого **9/9 соответствуют границе**.

Дополнительные собственные входы этого круга:
```text
double_quote_comment_indentless: expected_rc=0 actual_rc=0 stdout='' stderr=''
pin_in_literal_not_job: expected_rc=0 actual_rc=0 stdout='' stderr=''
anchor_on_steps: expected_rc=0 actual_rc=0 stdout='' stderr=''
tab_trailing_whitespace: expected_rc=0 actual_rc=0 stdout='' stderr=''
comment_between_pin_lines: expected_rc=0 actual_rc=0 stdout='' stderr=''
absent_block: expected_rc=1 actual_rc=1 stdout='' stderr='PRICHINA\tCI_BEZ_SHAGA_POVEDENIJA\tshag\n'
duplicate_across_jobs: expected_rc=1 actual_rc=1 stdout='' stderr='PRICHINA\tCI_SHAG_POVEDENIJA_NE_PO_PINU\tblokov shaga 2\n'
inline_run_comment_changes_pin: expected_rc=1 actual_rc=1 stdout='' stderr='PRICHINA\tCI_SHAG_POVEDENIJA_NE_PO_PINU\tblok shaga\n'
run_equal_indent_ends_block: expected_rc=1 actual_rc=1 stdout='' stderr='PRICHINA\tCI_SHAG_POVEDENIJA_NE_PO_PINU\tblok shaga\n'
OWN_PIN_INPUTS 9/9; LEGAL_COUNTEREXAMPLES 0
```

Лексический пин внутри literal scalar зелён намеренно: не доказательство шага GitHub; :38 требует его реальное исполнение отдельно. Inline-комментарий после run не является исключаемой строкой YAML-комментария и меняет пин.

## Четыре собственные мутации субъекта против батареи

```bash
python3 -B /tmp/dev-harness-verify/Critic116r6b/own_stabs.py
```

Мутации компилируются без синтаксических ошибок и исполняются через настоящие `probe.run_subject`/`judge` на неизменённом оракуле:
1. Вместо равенства блока — поиск подстроки команды в run: пропускает echo.
2. Обрезание блока сразу после run: игнорирует последующий continue-on-error.
3. Возврат смежного механизма membership: ложный отказ для пина в чужом job.
4. Возврат запрета indentless: ложный отказ честному лексическому пину.

Сырой вывод итогового запуска (rc 0 драйвера означает, что обманы ПОЙМАНЫ):
```text
accept_run_substring: case=ci-echo-podmena subject_rc=0 oracle_rc=1 CAUGHT=True stdout='' stderr=''
truncate_block_after_run: case=ci-coe-posle-run subject_rc=0 oracle_rc=1 CAUGHT=True stdout='' stderr=''
resurrect_parent_membership: case=ci-shag-vne-required-job subject_rc=1 oracle_rc=0 CAUGHT=True stdout='' stderr='PRICHINA\tCI_SHAG_POVEDENIJA_VNE_REQUIRED_JOB\tne-required-job\n'
reject_indentless: case=ci-steps-indentless subject_rc=1 oracle_rc=0 CAUGHT=True stdout='' stderr='PRICHINA\tCI_SHAG_POVEDENIJA_NE_PO_PINU\tindentless\n'
OWN_STABS 4/4 CAUGHT; uncaught=0
```

Честность замера: первый запуск собственного драйвера остановился rc 1 на третьей мутации (`CAUGHT=False`): я назвал job `not-required`, тогда как fixture использует `ne-required-job`; ветвь мутации не активировалась. После чтения `probe.py:698–715` исправлено только имя в собственном стабе, не fixture/оракул. Это не контрпример: первоначальный субъект на данном входе не отличался поведением от честного. Сырой вывод той строки: `resurrect_parent_membership: case=ci-shag-vne-required-job subject_rc=0 oracle_rc=0 CAUGHT=False stdout='' stderr=''`.

## Runtime-строка — проверка границы доказательства

:38 ДОСЛОВНО требует «ДОКАЗАННАЯ СВЯЗЬ, не три несвязанных зелёных факта» и четыре факта ОДНОГО C/run: required rc 0; присутствие нужного check-run среди required этого PR с идентификатором/URL и связанным run/job; в этом job того же run/commit настоящий шаг conclusion success и его Tests 19/19; привязка результата к принимаемому C. Старый run или чужой лог явно исключены. В :37/:38/:68/:75 сценарий чужого job переназначен runtime.

```bash
python3 -B /tmp/dev-harness-verify/Critic116r6b/measure.py runtime
```

Собственная копия продукта-модели; node_modules используются только для чтения, npx-адаптер запускает настоящий Jest, кеш свой. Сырой вывод, rc 0 драйвера:
```text
honest      honest_step step_rc=0  Tests: 19 passed, 19 total          runtime-stroka: ZELENAYA
honest      echo_step   step_rc=0  Tests: (нет строки Tests:)          runtime-stroka: KRASNAYA
mutant_K19  honest_step step_rc=1  Tests: 1 failed, 18 passed, 19 total runtime-stroka: KRASNAYA
mutant_K19  echo_step   step_rc=0  Tests: (нет строки Tests:)          runtime-stroka: KRASNAYA
SOGLASIE: OK
```

Это локальный smoke исполненной части критерия, НЕ живой PR/branch protection/GitHub-membership. Полные Jest-логи — `../tmp/honest_honest_step.log`, `honest_echo_step.log`, `mutant_K19_honest_step.log`, `mutant_K19_echo_step.log`. Живые четыре факта при ленде остаются обязательными по решению; нового продуктового PR этот scoped-круг не требует.

## Не-регресс и остаток

```bash
python3 -B /tmp/dev-harness-verify/Critic116r6b/nonregression.py
```

rc 0, сырой вывод:
```text
SOURCE_FIELDS_UNCHANGED all except kejsy/stab_vhod/statika_tekst
ARCHITECT_ZONE 14/14
JEST_K1_K19_PNG_MODEL_PRODUCT_DIFF 0 lines
JEST_PIN 873cf35be05a8ae8dcfff682100c992c9ee59096c0fe8a261f7eae56de871bdb
PNG_PINS 7/7
MEMBERSHIP_REMOVED source+guard; s48-s51 absent
SOURCE_COUNTS CASE=51 red=41 green=10 STAB=35 SVJAZI=38
LOG_COUNTS model=51/51 KADR=7 stabs_KRASEN=38 absent_KRASNO=51
REPLAY_COUNTS 17 forms: 2 green 15 NE_PO_PINU
```

Дельта r8→r9: **14 файлов, +245/−1813**. Поля модели/кадров/Jest/CI-пина и все прочие поля source, кроме перечисленных трёх, равны базе. Jest K1–K19, PNG, модель экрана и продукт: **0 строк diff**. Проверены реальные sha256 7 PNG и Jest-пина. `CI_REQUIRED_JOBS`/`VNE_REQUIRED_JOB` отсутствуют в действующем статике; `source.statika_tekst` совпадает с файлом; s48–s51 отсутствуют и в каталоге, и в активных связях.

СОВЕТ contracts/116-cmp-mob-005-mission.md:38 — в пояснении отрицательного случая чужого job сказано «(2) ломается». Если android-e2e остаётся required, но шаг перенесён в другой job, нарушается факт (3), а не обязательно (2). Четырёхчастная конъюнкция уже отвергает этот случай, обхода нет; это уточнение нумерации, не блокер.

СОВЕТ contracts/116-cmp-mob-005-mission.md:33 — s19–s28 имеют унаследованный синтаксический дефект, прямо зафиксированный заданием как ВНЕ этого круга. Его не перепроверял для подтверждения и не исправлял. Наблюдённые 38 KRASEN — результат батареи, не утверждение о семантической пригодности этих десяти старых стабов. Данный accept не снимает этот известный остаток и не расширяет суд за границу решения 675465e2.
