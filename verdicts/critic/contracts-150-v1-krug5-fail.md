FAIL
OBJECT=1d0d05f3594416adcc5cd5119abadc41ecd9f399
СУД: repo=dev-harness; предмет=150; фаза=контракт (scoped после дельты Arch150e, пере-скоуп z05); роль=critic; вызов=5 (сверх капа по слову владельца 2026-11-01 ~12:10; предыдущий — verdicts/critic/contracts-150-v1-krug4-fail.md FAIL, OBJECT 1d5d3463); модель-план=anthropic/claude-opus-5-5; сессия=Crit150e (id агента в ростере харнесса; id трейса судье не виден); модель-факт=anthropic/claude-opus-5-5; SHA=1d0d05f3594416adcc5cd5119abadc41ecd9f399; арбитраж=verdicts/arbitration/contracts-150-arbitraz.md; исключение=да (РАЗРЕШИЛ-ВЛАДЕЛЕЦ 2026-11-01)
Независимость: автор OBJECT — architect (`%an`=architect), модель-факт автора по отчёту Arch150e — openai-codex/gpt-6-sol; судья — anthropic/claude-opus-5-5: семейства разные, судья не автор.

# Критик — контракт 150, вызов 5 (scoped: изменённый критерий z05 + зависимый регресс)

Предмет суда: `git diff e8f1e9112 1d0d05f35` (10 файлов: контракт :53,:67-68,:70,:176,:184-186,:199,:202-203; osi.md; probe.py z05; source.json +1 привязка; 6 стабов z05). Клон `/tmp/dev-harness-verify/Crit150e/repo`, `git cat-file -t 1d0d05f3594416adcc5cd5119abadc41ecd9f399` → `commit`; checkout OBJECT; родитель e8f1e9112. В репо автора правок нет, push нет, эмуляторы/нативные сборки не запускались.

Итог: блок вызова 4 (`true ||`+перевод строки) ЗАКРЫТ — воспроизведено. Но новый исполнительный оракул z05 исполняет `run` не в той семантике, в какой его исполнит GitHub Actions, и это дало **регресс относительно дерева до дельты**: форма `false | true || bash … sbor` у второго работника на e8f1e9112 была красной (`SBOR_NE_BEZUSLOVEN`), на OBJECT — 17/17 зелёная, при том что в CI сбор не выполняется. Содержательных блоков — 2 класса. САМООПИСАНИЕ контракта — расхождений 0.

## БЛОКИРУЕТ

### Б1. Оракул z05 исполняет шаг сбора не так, как его исполнит CI (интерпретатор/опции, ключи шага) — ложный зелёный при пропущенном сборе

БЛОКИРУЕТ contracts/150-prichinnyy-zamer-obryva.md:70 (и :53, :176; osi.md:26; probe.py:850-852 `_ispolni_sbor`) — z05 исполняет `run` командой `/bin/bash --noprofile --norc -e -o pipefail -c <run>` в пустом cwd, игнорируя, как CI на самом деле исполняет этот шаг.

ОБЯЗАТЕЛЬСТВО: :70 — «z05 исполняет `run` шага сбора КАЖДОГО работника … `true ||` (включая перенос после `||`), `false &&`, … и любой пустой журнал → rc 1 `SBOR_NE_VYZVAN`/`NABLJUDENIE_PUSTO`»; :176 ЗАЩИЩАЕТ «по каждому работнику вызов сбора и фактический `--out` доказаны исполнительным журналом»; закрывающее свойство арбитража 148/150 (задание вызова 5): сбор ФАКТИЧЕСКИ выполнен на каждом работнике, пропуск сбора любой формой краснеет.

КЛАСС ПРИЧИНЫ: исполнительная модель оракула ≠ исполнительной модели шага в GitHub Actions. По docs.github.com (workflow-syntax, таблица `shell`): шаг БЕЗ ключа `shell` на Linux исполняется `bash -e {0}` — БЕЗ `pipefail`; `shell: bash` — `bash --noprofile --norc -eo pipefail {0}`; `shell: <шаблон> {0}` — произвольная команда; `if:` шага вычисляется раннером; `working-directory` (шаг / `jobs.<id>.defaults.run` / `defaults.run` workflow) задаёт cwd. Оракул всегда берёт вариант `shell: bash`, не читает `shell`/`defaults`/`if`/`working-directory`. Модель 150 (`model/.github/workflows/mobile.yml`, шаг «Замер обрыва: сбор») ключа `shell` не несёт → в CI это `bash -e {0}`.

СОСТОЯНИЕ (достижимое, допустимый вход `W --repo R`): карта+workflow с двумя работниками (схема Crit150d), первый — штатный; у второго в шаге сбора при каноническом `--out`/upload:
- (а) РЕГРЕСС ДЕЛЬТЫ: `false | true || bash mobile/scripts/zamer_obryva.sh sbor …` (и с переводом строки после `||`). В CI (`bash -e`, без pipefail) `false | true` = 0 → сбор пропущен; в оракуле (pipefail) = 1 → сбор «вызван».
- (б) `shell: true {0}` на шаге сбора (или `jobs.<id>.defaults.run.shell: true {0}`): CI запускает `true <script>` — сбор не исполняется никогда.
- (в) `if: ${{ always() && false }}` на шаге сбора: z03 проверяет лишь подстроку `always()` (probe.py:789-790), шаг в CI пропущен всегда.
- (г) мир как продукт 143 (`defaults.run.working-directory: mobile`, fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml:28-30): шаг сбора второго работника без переопределения каталога, `… --out mobile/zamer-out-$ZAMER_EKRAN || true`. В CI из `mobile/` путь `mobile/scripts/zamer_obryva.sh` не существует, `|| true` глушит — шаг зелёный, сбора нет.

НАБЛЮДЕНИЕ (сырой вывод, OBJECT):
```
$ python3 /tmp/dev-harness-verify/Crit150e/attack.py m_pipefail_or m_pipefail_or_newline
=== MUTANT m_pipefail_or ATTACK_RC 0
   ZELENO: клеток 17, зелёных 17
=== MUTANT m_pipefail_or_newline ATTACK_RC 0
   ZELENO: клеток 17, зелёных 17
$ python3 /tmp/dev-harness-verify/Crit150e/attack.py m_control m_if_always_and_false m_shell_true
=== MUTANT m_control ATTACK_RC 0
   ZELENO: клеток 17, зелёных 17
=== MUTANT m_if_always_and_false ATTACK_RC 0
   ZELENO: клеток 17, зелёных 17
=== MUTANT m_shell_true ATTACK_RC 0
   ZELENO: клеток 17, зелёных 17
$ python3 /tmp/dev-harness-verify/Crit150e/attack.py m_job_defaults_shell_true … m_if_always_and_false@1 m_shell_true@1
=== MUTANT m_job_defaults_shell_true ATTACK_RC 0
   ZELENO: клеток 17, зелёных 17
=== MUTANT m_if_always_and_false@1 ATTACK_RC 0      (мутант на ПЕРВОМ работнике — b*-replay тоже не ловит)
   ZELENO: клеток 17, зелёных 17
=== MUTANT m_shell_true@1 ATTACK_RC 0
   ZELENO: клеток 17, зелёных 17
$ python3 /tmp/dev-harness-verify/Crit150e/attack.py m_wd_defaults_or_true
=== MUTANT m_wd_defaults_or_true ATTACK_RC 0
   ZELENO: клеток 17, зелёных 17
```
Та же строка `run` — оракулом и так, как исполнит CI (тот же двойник SHIM_BASH_SBOR, тот же журнал):
```
$ python3 /tmp/dev-harness-verify/Crit150e/ci_vs_oracle.py
kanon                  ORACLE_z05 sobytij=1 osh='' | CI(unspecified: bash -e {0}) rc=0 sobytij=1 | CI(shell: bash) rc=0 sobytij=1
pipefail_or            ORACLE_z05 sobytij=1 osh='' | CI(unspecified: bash -e {0}) rc=0 sobytij=0 | CI(shell: bash) rc=0 sobytij=1
pipefail_or_newline    ORACLE_z05 sobytij=1 osh='' | CI(unspecified: bash -e {0}) rc=0 sobytij=0 | CI(shell: bash) rc=0 sobytij=1
$ bash /tmp/dev-harness-verify/Crit150e/wd_demo.sh        # (г): реальный bash -e, cwd=$WS/mobile, настоящий файл скрипта-заглушки
bash: mobile/scripts/zamer_obryva.sh: No such file or directory
CI_STEP_RC=0
MARKER: NET (sbor ne ispolnen)
```
Регресс подтверждён на дереве ДО дельты (e8f1e9112, отдельный checkout `/tmp/dev-harness-verify/Crit150e/old`, тот же скрипт атаки):
```
$ env CRIT_REPO=…/Crit150e/old CRIT_WORLDS=…/worlds_old python3 attack.py m_control m_pipefail_or m_shell_true m_if_always_and_false
=== MUTANT m_control ATTACK_RC 0            ZELENO: клеток 17, зелёных 17
=== MUTANT m_pipefail_or ATTACK_RC 1        KRASNO: клеток 17, красных 1
  z05-put-zagruzki: e2e-proba-drugoj: SBOR_NE_BEZUSLOVEN: vyzov sbor v uslovnoj pozicii (pravyj operand &&/|| libo uslovnaja gruppa) …
=== MUTANT m_shell_true ATTACK_RC 0         ZELENO: клеток 17, зелёных 17
=== MUTANT m_if_always_and_false ATTACK_RC 0  ZELENO: клеток 17, зелёных 17
$ env CRIT_REPO=…/Crit150e/old … attack.py m_wd_defaults_or_true m_job_defaults_shell_true
=== MUTANT m_wd_defaults_or_true ATTACK_RC 0   ZELENO: клеток 17, зелёных 17
=== MUTANT m_job_defaults_shell_true ATTACK_RC 0  ZELENO: клеток 17, зелёных 17
```
То есть (а) — регресс, внесённый дельтой (статика краснила правый операнд `||`, исполнение в чужой семантике — нет); (б)–(г) существовали и до дельты, но это та же причина: исполнительный оракул заявлен как «фактически выполнен», а исполняет не то, что исполнит CI. Один класс, четыре примера.

ЗАКРЫВАЮЩЕЕ СВОЙСТВО: z05 судит сбор каждого работника в той семантике исполнения шага, какую применит GitHub Actions, либо даёт именованный отказ там, где эту семантику не моделирует: (1) эффективный shell шага разрешается как в Actions (шаг `shell` → `jobs.<id>.defaults.run.shell` → `defaults.run.shell` → не указан = `bash -e {0}` без pipefail; `bash` = `--noprofile --norc -eo pipefail`), `run` исполняется этим вызовом; иной/шаблонный shell — отказ, не зелень; (2) `if:` шага сбора, отличный от принятой канонической формы (`always()`), — отказ (либо его вычисление); (3) эффективный `working-directory` (шаг/job/workflow defaults) учитывается при сопоставлении фактического cwd/`--out` с `with.path` (upload относителен workspace) либо неканонический каталог — отказ. Красное доказательство до заморозки: второй работник с `false | true || bash … sbor` (одна строка и перенос) → rc 1 z05 адресно; `shell: true {0}` → rc 1; `if: ${{ always() && false }}` → rc 1; мир с `defaults.run.working-directory: mobile` без переопределения у второго → rc 1; честные формы (два штатных работника; `false || сбор`; сбор с `&`+`wait`; вызов функции) остаются rc 0. Конкретный механизм выбирает автор.

### Б2. Событие двойника ≠ выполненный сбор: argv, на котором пиннованный скрипт молча выходит без сбора, зелёный

БЛОКИРУЕТ contracts/150-prichinnyy-zamer-obryva.md:70 (osi.md:26; probe.py:817-823 двойник, :917-932 суд) — оракул проверяет в argv только единственность и значение `--out`; остальные аргументы не судятся.

ОБЯЗАТЕЛЬСТВО: то же закрывающее свойство — «сбор ФАКТИЧЕСКИ выполнен на каждом работнике и с правильным `--out`»; :176 «вызов сбора … доказан исполнительным журналом».

КЛАСС ПРИЧИНЫ: двойник журналирует вызов, не исполнение. Пиннованный канон (`model/mobile/scripts/zamer_obryva.sh:66`): `*) ubyto "ZAMER_ARG_NEIZVESTEN: $1"; [ "$KMD" = sbor ] && exit 0; exit 0 ;;` — любой неизвестный аргумент → выход 0 ДО сбора. z04 пиннует скрипт, но не argv его вызова.

СОСТОЯНИЕ: второй работник, шаг сбора `bash mobile/scripts/zamer_obryva.sh sbor --help --ekran … --out mobile/zamer-out-$ZAMER_EKRAN` (любой неизвестный флаг, в т.ч. опечатка `--outt`, рядом с правильным `--out`). В CI скрипт выходит 0 на разборе аргументов, артефакта нет, upload грузит пустоту молча (`if-no-files-found: ignore`).

НАБЛЮДЕНИЕ:
```
$ python3 /tmp/dev-harness-verify/Crit150e/attack.py m_help_arg            # OBJECT
=== MUTANT m_help_arg ATTACK_RC 0
   ZELENO: клеток 17, зелёных 17
$ env CRIT_REPO=…/Crit150e/old … attack.py m_help_arg                      # e8f1e9112 — тоже зелёный (существовал до дельты)
=== MUTANT m_help_arg ATTACK_RC 0
   ZELENO: клеток 17, зелёных 17
```
Дефект существовал до дельты; предъявлен, потому что заявленное дельтой свойство («фактически выполнен», а не «текстуально вызван») им нарушается на допустимом входе (§Контракт: «обнаруженное реальное нарушение не скрывается ради scope»). Владелец вправе взвесить его отдельно от Б1.

ЗАКРЫВАЮЩЕЕ СВОЙСТВО: z05 краснеет именованно, если argv события не принимается разбором пиннованного скрипта как полноценный `sbor` (неизвестный/лишний аргумент; при желании — значения `--ekran/--ns/--serial/--spool` против env/карты работника), — например, двойник прогоняет argv через разбор аргументов канона либо сверяет с закрытым набором флагов канона. Красное доказательство: второй работник с `sbor --help … --out <верный>` → rc 1 z05; штатный → rc 0.

## САМООПИСАНИЕ (все счётные/адресные утверждения текста контракта и osi.md, перемерены живыми источниками)

Расхождений в контракте/osi.md/source.json — **0**. Полный список сверенного:

| утверждение (адрес) | живая мера | итог |
|---|---|---|
| 17 клеток — контракт :62,:66,:67,:198,:201,:202,:203; osi.md:78 | `len(probe.KLETKI)`=17; строк `^| [zb]NN-` в osi.md = 17; `--model` (default, seed 1/7/123) = 17/17; без флага 17/17 красных | совпадает |
| `SVJAZI 24`, живых 0, контроль 17/17 — контракт :67,:199; osi.md:80 | `--stabs` rc 0: `SVJAZI 24`, 24 KRASEN, STAB_ZHIV 0; контроль молчаливый (rc 0 ⇒ 17/17) | совпадает |
| census `stabs/stab_*.py` = 24 — контракт :68 | `ls stabs/stab_*.py | wc -l` = 24; `jq '.stab_vhod|length'` = 24; множества файлов и ключей `stab_vhod` равны (diff пуст) | совпадает |
| 24 stab-строки osi.md (:50–:73) | `grep -c '^| stab_zamer_' osi.md` = 24, строки 50..73; пары файл→клетка osi.md == source.json (diff пуст) | совпадает |
| 8 z05-стабов; перечень красных случаев z05 — контракт :67 | `stab_vhod` → z05-put-zagruzki = 8 (uslovnyj `true||`, operator_novaja_stroka, uslovnyj_and `false&&`, exit_do_sbora, heredoc, funkcija, kommentarij = неверный `--out`, put_zagruzki = неверный upload) | совпадает (8 = 8 перечисленных) |
| `nositelej=3` — контракт :69,:200; osi.md:81 | `jq '.piny|length'` = 3; `--oracle-tamper` → `ORACLE_TAMPER_PROVERENO nositelej=3` rc 0 | совпадает |
| 14 красных из 17 на модели 143 — контракт :202 | `W --repo fixtures/workshop_project/mob_ci_143/model` → rc 1 `KRASNO: клеток 17, красных 14`, z05 `NABLJUDENIE_PUSTO` + `net shagov sbor/artefakt` по каждому | совпадает |
| «четыре экранных работника + интеграция e2e-pilot» — контракт :202 | `mob_ci_143/model/mobile/ci-screens.json`: ekrany[].job = 4 (splash, first-run, erstinformation, start), integracija.job = e2e-pilot | совпадает |
| 2 работника, 1 красная клетка на атаки/неверный `--out` — контракт :203 | репро Crit150c/Crit150d: `KRASNO: клеток 17, красных 1` z05 адресно `e2e-proba-drugoj`; контроль два штатных rc 0 17/17 | совпадает |
| `sluchaev 11, sovpalo 11` — контракт :204 | `--samoproverka` rc 0 `SAMOPROVERKA: sluchaev 11, sovpalo 11` | совпадает |
| «три именованных шага» — контракт :53 | модель: start/sbor/artifact = 3 | совпадает |

Вне текста контракта (отчёт автора `/tmp/dev-harness-verify/Arch150e/report.md`, не предмет заморозки, не блокирует): таблица отчёта адресует «17 клеток» и «3 именованных шага» также к контракт :70 — на :70 нет ни числа 17, ни «три/3» (`sed -n 70p … | grep -c 17` → 0).

## Перемер заявленной приёмки (сырые итоги, клон OBJECT)

```
W=fixtures/workshop_project/obryv_zamer_150/red_obryv_zamer_150.sh   (обёртка run_cmd.sh пишет вывод, RC, WALL)
== model.out:         ZELENO: клеток 17, зелёных 17 RC=0 WALL=28.81
== model_seed1.out:   ZELENO: клеток 17, зелёных 17 RC=0 WALL=28.8
== model_seed7.out:   ZELENO: клеток 17, зелёных 17 RC=0 WALL=31.68
== model_seed123.out: ZELENO: клеток 17, зелёных 17 RC=0 WALL=33.43
== tamper.out:        ORACLE_TAMPER_PROVERENO nositelej=3 RC=0 WALL=0.07
== noflag.out:        KRASNO: клеток 17, красных 17 RC=1 WALL=0.07   (SUBJECT_ABSENT поимённо; z04 — ZAMER_SKRIPT_NET)
== repo143.out:       KRASNO: клеток 17, красных 14 RC=1 WALL=0.42   (z05: NABLJUDENIE_PUSTO; …)
== samoproverka.out:  SAMOPROVERKA: sluchaev 11, sovpalo 11 RC=0 WALL=0.28
== stabs.out:         24 строки "STAB … KRASEN" (8 из них → z05-put-zagruzki: exit_do_sbora/funkcija/heredoc/operator_novaja_stroka/uslovnyj/uslovnyj_and → NABLJUDENIE_PUSTO+SBOR_NE_VYZVAN; kommentarij/put_zagruzki → SBOR_OUT_NE_SOVPADAET), STAB_ZHIV 0, SVJAZI 24 RC=0 WALL=907.71
                      (контроль модели в --stabs молчаливый: probe.py:1411-1416 печатает KONTROL_KRASN и rc 1 только при красном; rc 0 ⇒ контроль 17/17)
```
Гейты (клон OBJECT): `bash scripts/pre_critic.sh --repo <клон> contracts/150-prichinnyy-zamer-obryva.md` → rc 0 «КРИТИК: дверь зелёная»; `bash scripts/check_precision_gate.sh <клон> <контракт>` → rc 0 `OK`; `check_ceilings.sh` → rc 0; `check_charter.sh` → rc 0; `check_threat_model.sh` → rc 0 (ЗАЩИЩАЕТ 6, НЕ ЗАЩИЩАЕТ 9); `check_provodka.sh` → rc 1 «guard не подключён» — ожидаемо до проводки зоны orchestrator после freeze (как заявлено, :206).

Воспроизведение атак/контролей прежних кругов и смока автора (скрипты перенацелены на клон OBJECT: `/tmp/dev-harness-verify/Crit150e/repro/*`):
```
Crit150c_attack_unreachable_second.py  → ATTACK_RC 1; KRASNO 17/1; z05 e2e-proba-drugoj: SBOR_NE_VYZVAN
Crit150c_control_two_workers.py        → TWO_WORKERS_UNMUTATED_RC 0; ZELENO 17/17
Crit150c_control_wrong_out_second.py   → RC 1; KRASNO 17/1; z05 e2e-proba-drugoj: SBOR_OUT_NE_SOVPADAET: ispolnennyj --out 'mobile/zamer-out-NEVER' != with.path …
Crit150d_attack_operator_newline.py    → ATTACK_RC 1; KRASNO 17/1; z05 e2e-proba-drugoj: SBOR_NE_VYZVAN
Crit150d_control_second_worker.py      → canonical RC 0 ZELENO 17/17; wrong-out RC 1 z05 SBOR_OUT_NE_SOVPADAET
Arch150e_z05-smoke.py (sud_z05 по 8 z05-стабам) → все 8 False с причиной SBOR_*/NABLJUDENIE_PUSTO (assert прошёл)
```
Гигиена после всех прогонов: `ps -eo args | python3 -c … "z150"+"mir" …` → `LIVE 0`.

Честные формы на OBJECT (второй работник): `false || sbor` → rc 0 17/17; сбор `&` + `wait` → rc 0 17/17; вызов функции со сбором → rc 0 17/17. Сбор `&` БЕЗ `wait` → rc 1 z05 `SBOR_NE_VYZVAN` (консервативно; см. СОВЕТ).

## СОВЕТ

- СОВЕТ contracts/150-prichinnyy-zamer-obryva.md:184 (НЕ ЗАЩИЩАЕТ «ветвление … по окружению») — пустой cwd делает невидимыми для оракула файлы продукта, от которых зависит исполнение: `. mobile/scripts/zamer_okruzhenie.sh 2>/dev/null || true` с `bash(){ :; }` в этом файле, либо `env: BASH_ENV: mobile/scripts/zamer_okruzhenie.sh` на шаге — в CI тень функцией (сбора нет), в песочнице файла нет → событие → `m_source_shadow`/`m_bash_env_shadow` ATTACK_RC 0, 17/17 (`m_source_shadow` зелёный и на e8f1e9112). Тень функцией в арбитраже 148 названа красной «по построению»; здесь она уходит через отсутствие дерева продукта в песочнице. Ведётся советом, т.к. буквально подпадает под заявленное «ветвление по окружению песочницы/CI»; честнее назвать в :184 отдельно «зависимость `run`/env шага от файлов checkout (source, BASH_ENV) — песочница их не содержит» либо исполнять в одноразовой копии R (метод 148 допускает её).
- СОВЕТ probe.py:850 — при закрытии Б1 учесть обратную сторону: под pipefail честная для CI форма `false | true; bash … sbor` в оракуле краснеет (ложный красный) — та же причина; замер: `probe._ispolni_sbor("false | true\nbash mobile/scripts/zamer_obryva.sh sbor --out mobile/zamer-out-proba-drugoj\n", env)` → `([], 'SBOR_RUN_OTKAZ: rc=1')`.
- СОВЕТ — `&` без `wait` сейчас красен лишь гонкой SIGKILL группы против старта двойника (нестабильность не измерял); если это намеренный отказ, лучше дать ему детерминированную причину.
- СОВЕТ /tmp/dev-harness-verify/Arch150e/report.md — адреса :70 в таблице чисел (см. САМООПИСАНИЕ).

## Что НЕ проверено

- Утверждение отчёта «каждый стаб красен ТОЛЬКО в своей клетке»: `--stabs` проверяет лишь `kletka in kr` (probe.py:1433), исключительность не печатает и не судит; не перемерял (вне изменённого критерия).

- Живой GitHub Actions не запускался: семантика `bash -e {0}` vs `shell: bash`, кастомного `shell: <cmd> {0}`, `if:` и `working-directory` взята из docs.github.com (workflow-syntax, таблица shell, §Custom shell) и смоделирована локальным bash (`ci_vs_oracle.py`, `wd_demo.sh`); реальный прогон раннера — [INFERENCE] по документации.
- `check_zones.sh` полный (≈7 мин по отчёту) не перемерялся — вне scope z05.
- Живые режимы ZP (`zelenyj`/`krasnyj`/`dlitelnosti` через внешний gh) не перемерялись — вне изменённого критерия (П2 не трогался дельтой).
- Подделка журнала проверяемым run и вызов минуя PATH — заявлены в НЕ ЗАЩИЩАЕТ :185-186, атаками не проверялись (честность формулировки по тексту принята).

## Маршрут

Порядок по слову владельца 2026-11-01: FAIL → СТОП, шестого вызова критика нет, решение владельца. Блоки содержательные (не только самоописание) — стоячее правило 31.10 о форке консультанту при FAIL лишь по самоописанию НЕ применимо. Б1(а) — регресс самой дельты; Б1(б)–(г) и Б2 — дыры той же клетки, существовавшие до дельты.
