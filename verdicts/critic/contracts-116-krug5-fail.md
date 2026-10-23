FAIL

# 116/1 — scoped-повтор r8: только required-job

OBJECT: `2dc29509b1fac3cd29528f1fb60e706ed8543810` (`wip/116/architect-r8`); база r7 `2a9c39337f365b2ca0e7ba97c58f0a527f88ab8f`.
Предмет: закоммиченный `contracts/116-cmp-mob-005-mission.md`, не рабочий черновик.
Судья: critic. Клон, драйверы и сырьё: `/tmp/dev-harness-verify/Critic116r5/`.
Рамка: задание `orch/task-critic116r5.md`, только ложный required-job и перечисленный scoped-регресс. Код продукта, Jest-матрица K1–K19 и runtime-строка заново не судились.
Набор полон: предмет :9–10, rc-критерий :29–38, исполнители/ЗОНА :40–48, модель угроз :59–76. Арбитраж `4cadfc54:verdicts/arbitration/contracts-116-eho-podmena.md` прочитан из закоммиченного блоба репозитория Arbiter116b; действует его §2.

## Единственная блокирующая причина

БЛОКИРУЕТ contracts/116-cmp-mob-005-mission.md:38 — required-job всё ещё ложно отвергает неизменный пин в `android-e2e`: допустимый YAML indentless sequence не распознаётся как список шагов своего job. Это ровно ветка допустимого контрпримера из :79 и §2 арбитра, не требование расширить множество run и не спор о факте запуска.
ОБХОД: в честном `teksty/mobile-ci.stand-in.yml` оставить `    steps:` на месте, а все строки его списка сдвинуть на два пробела влево. `- name: 116 mission behaviour render` окажется на одном уровне с `steps:`, его `run:` — глубже. Независимый `yaml.safe_load` даёт документ, ПОЛНОСТЬЮ РАВНЫЙ честному, единственный шаг по-прежнему в `jobs.android-e2e.steps`; блок по объявленному `.strip()` равен пину. Полная CLI-проба возвращает rc 1, `PRICHINA\tCI_SHAG_POVEDENIJA_VNE_REQUIRED_JOB\tjobs`, хотя объявленный предикат требует rc 0. При этом W --model и W --stabs зелёные: существующие входы не обнаруживают неполноту membership.

Минимальная существенная форма (остальные честные поля и шаги в сохранённом witness не удалены):

```yaml
jobs:
  android-e2e:
    steps:
    - name: 116 mission behaviour render
      run: npx jest src/features/conversation/__tests__/mission-116.test.tsx
```

Место механизма: `fixtures/workshop_project/mission_116/teksty/statika_text.py:318–336`. Обратный поиск пропускает `steps:` с отступом, РАВНЫМ отступу `-` (`ind >= porog`); принимает строку `android-e2e:` за родителя списка и затем `jobs:` — за job. Это не эффект shell/defaults/PATH/jest.config и не исключённый арбитром остаток: фактический YAML job доказан независимо, блок равен пину, отказ именно VNE_REQUIRED_JOB.

Команда: `python3 /tmp/dev-harness-verify/Critic116r5/membership_inputs.py` → rc 0 (драйвер измерения; rc субъекта ниже). Для каждого входа вызывается:

```bash
python3 /tmp/dev-harness-verify/Critic116r5/repo/fixtures/workshop_project/mission_116/teksty/statika_text.py \
  --pack /tmp/dev-harness-verify/Critic116r5/repo/fixtures/workshop_project/mission_116/teksty \
  --repo /tmp/dev-harness-verify/Critic116r5/ci-subject
```

Сырой вывод:

```text
indentless_steps: yaml_equals_honest=True block_eq_pin=True job=android-e2e static_rc=1 counterexample=True
PRICHINA	CI_SHAG_POVEDENIJA_VNE_REQUIRED_JOB	jobs
indentless_single_quote_comment: yaml_equals_honest=True block_eq_pin=True job=android-e2e static_rc=1 counterexample=True
PRICHINA	CI_SHAG_POVEDENIJA_VNE_REQUIRED_JOB	jobs
indentless_four_space_job: yaml_equals_honest=True block_eq_pin=True job=android-e2e static_rc=1 counterexample=True
PRICHINA	CI_SHAG_POVEDENIJA_VNE_REQUIRED_JOB	jobs
single_quote_comment_control: yaml_equals_honest=True block_eq_pin=True job=android-e2e static_rc=0 counterexample=False
COUNTEREXAMPLES 3
```

Одна причина, три варианта свидетельства; четвёртый вход — положительный контроль. YAML, JSON и сырой лог сохранены в `evidence/indentless*.yml`, `evidence/membership_inputs.{json,log}`. Для закрытия требуется положительный вход с indentless steps, красный на нынешнем статике, и исправление membership; пин run расширять не требуется.

АРБИТР: роль arbiter — созываю по второму FAIL одной причины (ложный VNE_REQUIRED_JOB на пинованном блоке в android-e2e; предыдущий d564854b). Предмет узкий: применимость уже принятого §2 к валидному indentless списку и достаточность регрессии membership, не shell/runtime. Вызов передаётся ведущему вместе с этим вердиктом; попытка сообщения `agent://Main` заблокирована средой Н-85, о состоявшемся запуске арбитра не утверждаю. Несогласие архитектора на момент вердикта не заявлено.

## Три прежних свидетеля — исправлены

Команда: `env TMPDIR=/tmp/dev-harness-verify/Critic116r5/tmp PYTHONDONTWRITEBYTECODE=1 python3 /tmp/dev-harness-verify/Critic116r5/own_inputs.py` → rc 0. Это прежний `own_inputs.py` с заменой только корня Critic116r4 → Critic116r5.

```text
job_inline_comment: block_eq_pin=True raw_step_bytes_unchanged=True yaml_job=android-e2e yaml_matching_steps=1 static_rc=0 legal_counterexample=False
job_quoted_key: block_eq_pin=True raw_step_bytes_unchanged=True yaml_job=android-e2e yaml_matching_steps=1 static_rc=0 legal_counterexample=False
job_indent_four: block_eq_pin=True raw_step_bytes_unchanged=False yaml_job=android-e2e yaml_matching_steps=1 static_rc=0 legal_counterexample=False
changed_run_suffix: block_eq_pin=False raw_step_bytes_unchanged=False yaml_job=android-e2e yaml_matching_steps=1 static_rc=1 legal_counterexample=False
PRICHINA	CI_SHAG_POVEDENIJA_NE_PO_PINU	blok shaga
extra_step_key: block_eq_pin=False raw_step_bytes_unchanged=True yaml_job=android-e2e yaml_matching_steps=1 static_rc=1 legal_counterexample=False
PRICHINA	CI_SHAG_POVEDENIJA_NE_PO_PINU	blok shaga
duplicate_step: block_eq_pin=False raw_step_bytes_unchanged=True yaml_job=android-e2e yaml_matching_steps=2 static_rc=1 legal_counterexample=False
PRICHINA	CI_SHAG_POVEDENIJA_NE_PO_PINU	blokov shaga 2
allowed_comments: block_eq_pin=True raw_step_bytes_unchanged=False yaml_job=android-e2e yaml_matching_steps=1 static_rc=0 legal_counterexample=False
honest_cd: block_eq_pin=False raw_step_bytes_unchanged=False yaml_job=android-e2e yaml_matching_steps=1 static_rc=1 legal_counterexample=False
PRICHINA	CI_SHAG_POVEDENIJA_NE_PO_PINU	blok shaga
honest_multiline: block_eq_pin=False raw_step_bytes_unchanged=False yaml_job=android-e2e yaml_matching_steps=1 static_rc=1 legal_counterexample=False
PRICHINA	CI_SHAG_POVEDENIJA_NE_PO_PINU	blok shaga
LEGAL_COUNTEREXAMPLES 0
```

## 17 форм арбитра — не регрессировали

Команда: `python3 /tmp/dev-harness-verify/Critic116r5/measure.py replay` → rc 0. Собственный ci-subject, полная CLI-проба; shell-контроль использует прежний подставной npx с rc 1, не настоящий Jest. Сырой вывод:

```text
honest                   static=0                                              shell=1    jest_invoked=True
r3_echo_comment          static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=0    jest_invoked=False
critic_quoted_echo       static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=0    jest_invoked=False
critic_xargs_echo        static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=0    jest_invoked=False
critic_echo_subst        static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=0    jest_invoked=True
arb_or_true              static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=0    jest_invoked=True
arb_semicolon_true       static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=1    jest_invoked=True
arb_and_or_echo          static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=0    jest_invoked=True
arb_exit0_before         static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=0    jest_invoked=False
arb_func_shadow          static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=0    jest_invoked=True
arb_set_plus_e           static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=0    jest_invoked=True
arb_background          static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=0    jest_invoked=True
arb_heredoc              static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=0    jest_invoked=False
arb_folded_block         static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=0    jest_invoked=False
arb_shell_key            static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=None jest_invoked=None
arb_testname_filter      static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=1    jest_invoked=True
arb_step_in_other_job    static=1 PRICHINA CI_SHAG_POVEDENIJA_VNE_REQUIRED_JOB not-required shell=None jest_invoked=None
bypasses: 0 / 17
```

Честный rc 0, остальные 16 rc 1; истинно чужой job остался красным VNE_REQUIRED_JOB. Полный вывод — `evidence/replay.log`, JSON — `ci_replay.json`.

## Батарея и три собственных мутанта

Команда: `python3 /tmp/dev-harness-verify/Critic116r5/measure.py battery` → rc 0; W = `bash fixtures/workshop_project/mission_116/red_mission_116.sh`.

| исполненная команда/условие | исход |
|---|---|
| W --model | rc 0, 48/48 CASE ok, 7 KADR (каждый 1.000 при пороге 0.600) |
| W --stabs | rc 0, 48/48 CASE ok, 42 строки STAB KRASEN, SVJAZI 42, непойманных 0 |
| W без scripts/ekran_shablon.py | rc 1, SHABLON_ABSENT, 48 CASE KRASNO (SHABLON_ABSENT) |

Субъект для проверки отсутствия временно перемещён внутри allowlist и восстановлен в finally. Полный сырой вывод — `evidence/model.log`, `evidence/stabs.log`, `evidence/shablon_absent.log`. Числа дополнительно посчитаны по логам отдельным драйвером nonregression.py, не повтором W.

Три собственных изменения статического субъекта, исключительно в `evidence/`: принудительное membership чужого job; ложное отвержение job с комментарием; ложное отвержение job с отступом не 2. Исполняются штатными `probe.run_subject` / `probe.judge` против неизменного oracle. Команда: `python3 /tmp/dev-harness-verify/Critic116r5/own_stabs.py` → rc 0. Сырой вывод каждой:

```text
foreign_membership_forced: case=ci-shag-vne-required-job subject_rc=0 oracle_rc=1 CAUGHT=True stdout='' stderr=''
comment_membership_rejected: case=ci-job-inline-kommentarij subject_rc=1 oracle_rc=0 CAUGHT=True stdout='' stderr='PRICHINA\tCI_SHAG_POVEDENIJA_VNE_REQUIRED_JOB\tNone\n'
deep_membership_rejected: case=ci-job-otstup-chetyre subject_rc=1 oracle_rc=0 CAUGHT=True stdout='' stderr='PRICHINA\tCI_SHAG_POVEDENIJA_VNE_REQUIRED_JOB\tNone\n'
OWN_STABS 3/3 CAUGHT; uncaught=0
```

Эти три мутанта пойманы; они не заменяют новый контрпример indentless списка, отсутствующий в батарее.

## Не-регресс, гейты и пять вопросов

`git diff --exit-code 2a9c39337f365b2ca0e7ba97c58f0a527f88ab8f 2dc29509b1fac3cd29528f1fb60e706ed8543810 -- fixtures/workshop_project/mission_116/model fixtures/workshop_project/mission_116/teksty/ekran.stand-in.tsx fixtures/workshop_project/mission_116/teksty/povedenie.test.stand-in.tsx fixtures/workshop_project/mission_116/nositeli` → rc 0, вывод пуст.

`python3 /tmp/dev-harness-verify/Critic116r5/nonregression.py` → rc 0:
- дельта 14/14 файлов — только контракт, probe.py, source.json, statika_text.py, стабы s42–s51;
- payload-поля source.json `ekran_forma`, `kadry_manifest`, `ekran_tekst`, `povedenie_proba`, `povedenie_proba_sha256`, `mobile_ci_tekst` неизменны;
- 7/7 PNG совпадают с SHA256; Jest-пин `873cf35be05a8ae8dcfff682100c992c9ee59096c0fe8a261f7eae56de871bdb` совпадает;
- 17 исходов replay и счётчики батареи дополнительно проверены assertions драйвера.

Живые команды (с `TMPDIR=/tmp/dev-harness-verify/Critic116r5/tmp`, `PYTHONDONTWRITEBYTECODE=1`):

```text
bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic116r5/repo contracts/116-cmp-mob-005-mission.md
OK
exit=0

bash scripts/pre_critic.sh contracts/116-cmp-mob-005-mission.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
КРИТИК: дверь зелёная
exit=0
```

1. Критерий слабее предмета: да, единственный названный scoped-обход выше — зелёная батарея при ложном отказе конформному membership.
2. Доказуемость командами: перечисленные scoped-команды выполнены; они не доказывают полноту YAML membership. Продуктовая runtime-строка оставлена вне этого повторного круга и не объявлена исполненной.
3. Решения исполнителю: пин и required-набор названы; неназванное ограничение относительного отступа списка выявлено исполнением, а не вкусом.
4. Границы: :41–48 называют исполнителей/зоны; все 14 путей дельты относятся к зоне architect, собственный коммит содержит только вердикт critic.
5. Норма: новых самостоятельных нарушений в scoped-дельте не установлено; Jest/PNG и принятое исключение без-PNG не менялись. False-negative membership блокируется по уже принятому §2, не по расширенной модели угроз.

Итог: три прежних свидетеля закрыты, чужой job красный, батарея/17 форм/precision/pre_critic/не-регресс зелёные. FAIL — только по оставшемуся ложному required-job для indentless steps. Контракт и код не правились, push не выполнялся. Вся запись ограничена Critic116r5; вердикт коммитится в собственном клоне под identity critic согласно заданию.
