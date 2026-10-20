FAIL
OBJECT=9508a903f28976d5e51fca08451b587d779507e6

# Суд реализации 110 (done волны), круг 1 — Rev110

Находки (reslop, status: ready): `/tmp/dev-harness-verify/Rev110/review.md`. Блокеров два: Б1
(у него назван обход) и Б2 (красный регресс из ПРИЁМКИ-СУДЬИ). Советов шесть, С1–С6.

## Блокеры

- **Б1 — обход И-8:** тег ставится на HEAD в момент `git tag`, а не на HEAD, снятый до
  вызова. Если HEAD сдвинулся во время NFR/e2e, дверь даёт rc 0 и `done/waves/3/1` встаёт на
  коммит, где в волне 3 есть нетерминальная 083. Сама дверь на этом коммите отказывает (rc 1).
  Простая форма: закрепить `HEAD_SHA` и ставить тег от него, probe 52/52 rc 0.
- **Б2 — регресс CI:** `scripts/done_wave.sh` не классифицирован для verify_antiplacebo, поэтому
  после слияния красны все шарды antiplacebo. Простая форма: одна строка шапки
  `НЕ БАРЬЕР:` по прецеденту make_task.sh, scoped rc 0, probe rc 0.

## Сырые команды и rc

Клоны: `impl` = OBJECT; `run` = OBJECT плюс `git archive frozen/contracts/110/1
fixtures/workshop_project/done_volny_110 contracts/110-done-volny.md`; `merged` = main@8316a2e47
плюс merge OBJECT (без конфликтов, main после базы 7ff625939 эти 4 файла не трогал); `gp` = клон
merged; `mainc` = main@ec1f4072f без OBJECT.

```
# run
bash fixtures/workshop_project/done_volny_110/probe.sh            → rc=0 «ИТОГ: случаев 52, зелёных честных 11/11, отказных с именованной причиной 41/41» (real 4.314s)
… probe.sh | grep -cE '^СЛУЧАЙ .* ok ?$'                           → 52
… probe.sh --case __no_such_case__                                  → dispatch_rc=2
… provodka.sh                                                       → rc=0
… probe.sh --matrix                                                 → matrix_rc=0, mismatches=0, 31 строка «МУТАНТ»
python3 (import probe.py): cases 52 distinct 52 ok 11 refuse 41; mutants 31 distinct 31
# свои мутанты РЕАЛИЗАЦИИ (mutrun.sh, обычный probe.sh)
pin                → rc=0 52/52           (форма для Б1)
review_worktree    → rc=1 красная: review_dirty
v_always_1         → rc=1 красные: tag_v2_valve tag_v2_allowed tag_gap_max_plus_one
second_nfr_skipped → rc=1 красные: nfr_second_over nfr_second_cmd_fail nfr_second_no_metric
lightweight_tag    → rc=1 красные: все 11 ok-клеток
# Б1
bash race.sh (impl)       → rc=0 out=v1; H0=b7b6a308…; peeled=94fa2286…; план на коммите тега: 082,083; дверь там → rc=1 «083 (нет done-тега)»
DOOR=v_pin/… bash race.sh → rc=0 out=v1; H0=b6bc175f… == peeled=b6bc175f…
own.sh мир B (e2e коммитит) → rc=0 v1, peeled=642b0dcc… ≠ H0=e0052b8c…
# Б2
mainc:  verify_antiplacebo.sh --scope verify_ci_parity → ap_main_rc=0 (26/26)
gp:     verify_antiplacebo.sh --scope verify_ci_parity → ap_impl_rc=1 «FAIL done_wave.sh: не классифицирован…», «расхождений: 1»
gp:     verify_antiplacebo.sh --scope ci_gen_083       → rc=1 (тот же FAIL)
gp + строка «НЕ БАРЬЕР:» → --scope verify_ci_parity rc=0; probe.sh rc=0 52/52
gp + строка «Коды возврата:» → --scope verify_ci_parity rc=0
# merged: регрессы и проводка
bash scripts/gen_ci_steps.sh --check                                → rc=0
bash scripts/verify_ci_parity.sh                                    → rc=0 «расхождений: 0»
bash fixtures/workshop_project/done_volny_110/provodka.sh           → rc=0
bash scripts/check_provodka.sh . contracts/110-done-volny.md        → rc=0
bash scripts/check_zones.sh                                         → rc=0 (111 контрактов, 3489 коммитов по зонам)
bash fixtures/_krasnye_084.sh                                       → rc=0 «клеток 59, красных 0»
bash fixtures/_krasnye_083.sh                                       → rc=0 «ok=120 FAIL=0»
bash fixtures/workshop_project/rezhim_996/probe.sh                  → rc=0 «mismatches=0»
git diff --quiet frozen/contracts/110/1 HEAD -- contracts/110-done-volny.md fixtures/workshop_project/done_volny_110/ → rc=0
# gp: регресс gen_plan (команда 4)
(теги: done+frozen contracts = 287)
gen_plan.sh --write без registry/waves → rc=0; HANDOFF sha256 b0b84a9d…, ROADMAP a56975d7…
gen_plan.sh --write с registry/waves/{1,4}.tsv (коммит) → rc=0; sha256 те же
git diff --exit-code -- ROADMAP.md HANDOFF.md → rc=1 в ОБОИХ случаях: дрейф main (+«110 · пара 4 · заморожен»), не от реализации (С6)
# ci.yml и реестр
diff мультимножеств keys: ci.yml HEAD~1 vs HEAD → только «> check:done-volny-110-family-selftest»
строки diff ci.yml вне «keys:» → нет (grep rc=1)
git diff HEAD~1 HEAD -- registry/ci-steps.tsv → 7 добавленных строк, 0 удалённых; package.json → запятая и один новый ключ
# свой оракул (own.sh)
A честная: rc=0 v1; type=tag; peeled == H0; причина в аннотации; tagger=Fixture <fixture@local> (С1)
C подкаталог-корень: rc=0 v1 по корневому деко (С4)
D метрика «.» при le 10: rc=0 v1 (С3)
E e2e видит GIT_CONFIG_GLOBAL: rc=1 «сквозной запуск волны красный» (С2)
G worktree-корень (.git — файл): rc=0 v2 при РАЗРЕШИЛ-ВЛАДЕЛЕЦ:
H v2 без строки владельца: rc=1, refs неизменны
I review-перечень пуст: rc=0 v1
J числовая в closed-without-done без done-тега: rc=1 «082 (нет done-тега)»
```

## Пункты роли

1. Область правки: 4 файла, все в ЗОНЕ implementer. Пересечения соблюдены: в package.json и
   ci-steps только добавления, ci.yml — чистая регенерация (keys +1, gen --check rc 0). Принято.
2. Сырой вывод: отчёт автора проверен моими прогонами выше. Его цифры (52/52, 31,
   provodka/parity/zones rc 0) совпали. verify_antiplacebo в отчёте не было, и он красный (Б2).
3. Проверка не переписана: в ветке нет файлов фикстур/контракта 110, frozen diff rc 0.
4. Красное предъявлено: до-предметная красная зафиксирована в контракте, на реализации красное
   дают 4 моих мутанта.
5. Атомарность: один коммит, автор `implementer`, предмет 110.
6. Норма не тронута: roles/, AGENTS.md, contracts/ не менялись.
7. Заявленное = сделанному, своей мерой: CASES 52 (11/41), MUTANTS 31, вес 5 ≥ моего 4.31 с.
   Ключ — step, не legkij, Σ legkij = 95 не изменилась, лёгкий маршрут не задет.

Н-363: не побайтная копия модели (diff ненулевой), но логика перенесена построчно, вместе с
дефектами модели (Б1, С1, С3) — С5. Правило 2: plan_parse и project_paths_resolve
переиспользованы, нового парсера плана нет. Закрытия и done-тег продублированы awk/for-each-ref
вместо plan_status/p84_closed_reason — С5, ACCIDENTAL без блокировки. Проводка (038): guard
`fixtures/workshop_project/done_volny_110/probe.sh` подключён ключом → ci-steps → ci.yml,
provodka.sh rc 0, check_provodka rc 0. ПРОВОДКА-ЭНФОРСМЕНТ обоснован: поведенческая норма
вынесена в вопрос 3. cognitive-only живой волны честный: манифестов нет, живую волну отчёт
не заявляет. Утечку среды в живую e2e описывает С2.

## Паразитная сложность (контракт 050)

- `scripts/done_wave.sh`. (1) Требуется по «Предмет и граница», И-1…И-9. (2) Состояние — новый
  ref `done/waves/<W>/<v>`, видно в stdout `v<N>` и rc. Неявная часть: экспорт
  GIT_CONFIG_*=/dev/null в среду команд манифеста (С2). (3) При правке того же свойства вместе
  меняются дверь и проба 110, число файлов диффом не выросло. (4) Интерфейс узкий: 3
  позиционных аргумента, rc 0/1/2, env не читается (WAVE110_TOOLS модели убран). Работы за ним
  много, модуль глубокий. (5) Потребитель — probe.sh, строка 4 приёмки и CI-step. Повтор логики
  в дереве: поиск закрытий и done-тега дублирует lib_plan (С5). ESSENTIAL, кроме дубля С5
  (ACCIDENTAL, совет).
- Ключ `package.json` `check:done-volny-110-family-selftest`. (1) Требуется ПРОВОДКОЙ, строка 4.
  (2) Состояния не вводит. (3) Ключ, ci-steps и ci.yml меняются вместе, как у всех батарей, число
  не выросло. (4) Одна строка. (5) Потребители — ci-steps, provodka.sh, verify_ci_parity.
  ESSENTIAL.
- Строка `registry/ci-steps.tsv` (step, вес 5) и 6 строк комментария. (1) Требуется
  ПРОВОДКОЙ. (2) Вес явный, по замеру. (3) Как выше. (4) Одна строка грамматики. (5) Потребители
  — gen_ci_steps и ci.yml. ESSENTIAL.
- `.github/workflows/ci.yml` (регенерация). (1) Требуется ПРОВОДКОЙ. (2) Производная, не
  ручная. (3) Генератор, без ручной правки. (4) Неприменимо. (5) CI. ESSENTIAL.

Суд не меняет критерий и не отменяет машинный отказ. Чтобы закрыть круг, нужны Б1 и Б2 на
новом OBJECT и повтор probe 52/52, verify_antiplacebo --scope verify_ci_parity и race.sh на
новом SHA.
