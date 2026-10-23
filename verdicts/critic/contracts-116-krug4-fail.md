FAIL

# 116/1 — scoped-круг r7 по РЕШЕНИЮ 4cadfc54 §4

OBJECT: `2a9c39337f365b2ca0e7ba97c58f0a527f88ab8f`, ветка `wip/116/architect-r7`, база r6 `ba07bdf3`.
Предмет: `contracts/116-cmp-mob-005-mission.md` на HEAD OBJECT, не черновик.
Судья: critic. Клон и все записи: `/tmp/dev-harness-verify/Critic116r4/`.
Рамка: CI-страж, runtime-строка, 17 форм, батарея и не-регресс. Полный повтор мутационной матрицы Jest K1–K19 НЕ проводился.

Набор полон: предмет :9–10, критерий с rc-командами :29–38, исполнители/ЗОНА :40–48, модель угроз :59–76. Решение арбитра `4cadfc54` прочитано из его закоммиченного блоба.

## Единственная блокирующая причина — ложный отказ membership

БЛОКИРУЕТ contracts/116-cmp-mob-005-mission.md:38 — заявленный предикат «блок == пин ∧ job == android-e2e» не соблюдается на законном написании ключа job. Контракт :79 прямо принимает такой ложный отказ как допустимый контрпример. Это новая причина, не повтор негейтящего shell и не требование расширить множество разрешённых run.
ОБХОД: взять честный `teksty/mobile-ci.stand-in.yml` и изменить ТОЛЬКО `  android-e2e:` на `  android-e2e: # required Android job`. Две строки шага, включая исходные байты и отступы, НЕ изменены; единственный шаг лежит в YAML `jobs.android-e2e.steps` (проверено независимым `yaml.safe_load`). Полная CLI-проба возвращает rc 1, `PRICHINA\tCI_SHAG_POVEDENIJA_VNE_REQUIRED_JOB\tNone`. Следовательно, выполняется ровно первая ветка критерия арбитра §2: **блок == пин ∧ job == android-e2e ∧ красно**. Та же причина воспроизведена с ключом `"android-e2e":` и с отступом job 4 пробела (в последнем случае строки блока равны пину по объявленному `.strip()`).

Место механизма: `fixtures/workshop_project/mission_116/teksty/statika_text.py:315–324`; поиск job допускает только `^  ([\w-]+):\s*$`. Объявленная граница пинует БЛОК ШАГА, а не написание ключа job. Поэтому исключение «всё вне блока» :75 не оправдывает этот результат: оно исключает доказательство запуска/гейта, но не разрешает отвергать неизменный пин в нужном job; это различие прямо задано §2 арбитра.

Команда воспроизведения трёх вариантов и контролей:

```bash
python3 /tmp/dev-harness-verify/Critic116r4/own_inputs.py
```

Внутри каждого входа исполняется один и тот же полный CLI:

```bash
python3 /tmp/dev-harness-verify/Critic116r4/repo/fixtures/workshop_project/mission_116/teksty/statika_text.py \
  --pack /tmp/dev-harness-verify/Critic116r4/repo/fixtures/workshop_project/mission_116/teksty \
  --repo /tmp/dev-harness-verify/Critic116r4/ci-subject
```

Входы сохранены поимённо в `evidence/<имя>.yml`; драйвер восстанавливает честный workflow после прогона. Сырой вывод:

```text
job_inline_comment: block_eq_pin=True raw_step_bytes_unchanged=True yaml_job=android-e2e yaml_matching_steps=1 static_rc=1 legal_counterexample=True
PRICHINA	CI_SHAG_POVEDENIJA_VNE_REQUIRED_JOB	None
job_quoted_key: block_eq_pin=True raw_step_bytes_unchanged=True yaml_job=android-e2e yaml_matching_steps=1 static_rc=1 legal_counterexample=True
PRICHINA	CI_SHAG_POVEDENIJA_VNE_REQUIRED_JOB	None
job_indent_four: block_eq_pin=True raw_step_bytes_unchanged=False yaml_job=android-e2e yaml_matching_steps=1 static_rc=1 legal_counterexample=True
PRICHINA	CI_SHAG_POVEDENIJA_VNE_REQUIRED_JOB	None
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
LEGAL_COUNTEREXAMPLES 3
```

Итого: **одна причина, три свидетельства**, не три независимых блокера. Драйвер завершился rc 0 (успешно измерил); у трёх допустимых контрпримеров сам статик rc 1. Вторая ветка критерия, «блок ≠ пин ∧ зелено», на проверенных новых входах не найдена. Дополнительные честные `cd &&` и многострочный `run: |` отвергаются ожидаемо, это принятый fail-closed, не находка.

До заморозки нужны положительные регрессии законного membership, красные на текущем субъекте; критерий пина расширять или снова перечислять shell-формы не требуется. Это первый отказ по данной причине; повторного спора сторон по ней пока нет, новый арбитраж не созывался.

## 17 форм арбитра — собственный полный CLI-прогон

Команда: `python3 /tmp/dev-harness-verify/Critic116r4/measure.py replay` → rc 0.
`ci_replay.py` скопирован из стенда арбитра, изменён только корень путей; `ci-subject` — собственная копия. Для shell используется подставной npx, возвращающий 1, как в замере арбитра; это НЕ доказательство настоящего Jest, он отдельно ниже.

Сырой вывод replay:

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
arb_func_shadow          static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=0    jest_invoked=False
arb_set_plus_e           static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=0    jest_invoked=True
arb_background           static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=0    jest_invoked=True
arb_heredoc              static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=0    jest_invoked=False
arb_folded_block         static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=0    jest_invoked=False
arb_shell_key            static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=None jest_invoked=None
arb_testname_filter      static=1 PRICHINA CI_SHAG_POVEDENIJA_NE_PO_PINU blok shaga shell=1    jest_invoked=True
arb_step_in_other_job    static=1 PRICHINA CI_SHAG_POVEDENIJA_VNE_REQUIRED_JOB not-required shell=None jest_invoked=None
bypasses: 0 / 17
```

Результат: честный rc 0; **16 красных поимённо**, из них **15 NE_PO_PINU + 1 VNE_REQUIRED_JOB**, 0/17 обходов из прежнего списка. Это подтверждает исправление прежнего shell-блокера, но не опровергает новый ложный отказ выше.

## Батарея и три собственных обманных реализации

Команда: `python3 /tmp/dev-harness-verify/Critic116r4/measure.py battery` → rc 0. Она вызывает W с указанными флагами; TMPDIR находится внутри allowlist.

| режим | наблюдённый результат |
|---|---|
| W --model | rc 0, 45/45 `CASE ... ok`, 7 KADR |
| W --stabs | rc 0, 45/45 `CASE ... ok`, 39/39 `STAB ... KRASEN`, `SVJAZI 39`, непойманных 0 |
| W без `scripts/ekran_shablon.py` | rc 1, `SHABLON_ABSENT`, 45 `CASE ... KRASNO (SHABLON_ABSENT)` |

Для последней проверки субъект временно перемещён внутри собственного allowlist и восстановлен в `finally`. Это именно объявленное условие отсутствия субъекта, не безфлаговый прогон живого валидатора.

```text
KADR	F05.01 dark	1.000	0.600	G	OK
KADR	F05.02 dark	1.000	0.600	G	OK
KADR	F05.03 dark	1.000	0.600	G	OK
KADR	F05.04 dark	1.000	0.600	G	OK
KADR	F05.05 dark	1.000	0.600	G	OK
KADR	F05.06 dark	1.000	0.600	G	OK
KADR	F05.V03 dark	1.000	0.600	G	OK
```

Дополнительно написаны **три собственных мутанта субъекта**, только в одноразовом каталоге `evidence/`: (1) принимающий отсутствие шага, (2) принимающий неравный пину блок, (3) принимающий чужой job. Исполняются на существующих именованных красных входах через штатные `probe.run_subject` и `probe.judge`, не заменяя оракул. Команда: `python3 /tmp/dev-harness-verify/Critic116r4/own_stabs.py` → rc 0. Сырой вывод:

```text
missing_step_accepted: case=ci-shag-otsutstvuet subject_rc=0 oracle_rc=1 CAUGHT=True stdout='' stderr=''
unequal_block_accepted: case=ci-echo-podmena subject_rc=0 oracle_rc=1 CAUGHT=True stdout='' stderr=''
foreign_job_accepted: case=ci-shag-vne-required-job subject_rc=0 oracle_rc=1 CAUGHT=True stdout='' stderr=''
OWN_STABS 3/3 CAUGHT; uncaught=0
```

## Runtime-строка — настоящий Jest, не echo

Команда: `python3 /tmp/dev-harness-verify/Critic116r4/measure.py runtime` → rc 0.
Собственная копия R архитектора; node_modules используются только для чтения. Кэши и временные файлы — внутри Critic116r4. Адаптер npx вызывает настоящий `node node_modules/jest/bin/jest.js --ci --runInBand --cacheDirectory <свой каталог>`; тело шага запускается `bash --noprofile --norc -e -o pipefail`. Мутант K19 удаляет очистку черновика из `handleNewTopic`; модель восстанавливается после замера.

```text
honest      honest_step step_rc=0  Tests: 19 passed, 19 total          runtime-stroka: ZELENAYA
honest      echo_step   step_rc=0  Tests: (нет строки Tests:)          runtime-stroka: KRASNAYA
mutant_K19  honest_step step_rc=1  Tests: 1 failed, 18 passed, 19 total runtime-stroka: KRASNAYA
mutant_K19  echo_step   step_rc=0  Tests: (нет строки Tests:)          runtime-stroka: KRASNAYA
SOGLASIE: OK
```

4/4 ожидаемых исхода. Это требуемый smoke runtime-строки, не повтор матрицы K1–K19. Живой GitHub Actions/`gh pr checks` не запускался: этот критерий относится к ленду продуктовой реализации, а не к заморозке текста. Подменять его локальным smoke не утверждаю.

## Не-регресс, границы и пять вопросов гейта

Команда `git diff --exit-code ba07bdf3 2a9c39337f365b2ca0e7ba97c58f0a527f88ab8f -- fixtures/workshop_project/mission_116/model fixtures/workshop_project/mission_116/teksty/ekran.stand-in.tsx fixtures/workshop_project/mission_116/teksty/povedenie.test.stand-in.tsx fixtures/workshop_project/mission_116/nositeli` → rc 0, пустой diff.

Команда `python3 /tmp/dev-harness-verify/Critic116r4/nonregression.py` → rc 0: payload-поля `ekran_forma`, `kadry_manifest`, `ekran_tekst`, `povedenie_proba`, `povedenie_proba_sha256` в source.json неизменны относительно r6; 12/12 изменённых путей внутри объявленной зоны architect; все пять исполнителей названы; 7/7 PNG существуют и совпадают с sha256 манифеста; слово владельца (б) присутствует. Модель и семья на runtime-стенде байт-идентичны закоммиченным пинам; SHA256 семьи `873cf35be05a8ae8dcfff682100c992c9ee59096c0fe8a261f7eae56de871bdb`.

Живые команды на собственном клоне:

```text
bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic116r4/repo contracts/116-cmp-mob-005-mission.md
OK
EXIT 0

bash scripts/pre_critic.sh contracts/116-cmp-mob-005-mission.md
КРИТИК: дверь зелёная
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
EXIT 0
```

1. Соответствие критерия предмету: прежние 16 обманных CI-форм закрыты; обнаружен один новый законный контрпример полноте пина/membership, описанный выше. Успех W и pre_critic не заменяет этот суд.
2. Доказуемость: :38 содержит буквальную runtime-строку `gh pr checks --required` ∧ conclusion success ∧ `Tests: 19 passed, 19 total`; локальный живой Jest проверяет её часть rc/лог. Реальный GitHub-run остаётся обязательным при ленде, не объявлен проверенным здесь.
3. Оставленные исполнителю решения: в scoped-части пин, job, отказы и граница runtime названы. Неназванное ограничение написания job найдено замером, а не предложено как новая норма.
4. Границы: :41–48 называют зоны/пересечения; precision rc 0, r7 затрагивает только 12 путей в architect-зоне. Это scoped-проверка дельты и деклараций, не утверждение о запуске полного исторического `check_zones.sh`.
5. Норма: PNG/слово владельца сохранены; модели/кадры/семья не переписаны. В scoped-разделах :57/:68/:75/:79 форма отделена от семантики запуска; job-level/defaults/PATH/jest-config явно в НЕ ЗАЩИЩАЕТ. Дополнительного самостоятельного нарушения нормы не установлено.

Итог: **FAIL только по новой причине ложного отказа membership**, удовлетворяющей п.2 арбитра. Прежний shell-блокер закрыт, runtime-строка проведена в тексте и испытана локально. Контракт/пробы не правились; push не выполнялся. Сырьё: `/tmp/dev-harness-verify/Critic116r4/evidence/`, runtime-логи: `.../tmp/*.log`; воспроизводящие драйверы сохранены рядом с клоном.
