accept
OBJECT=c5ceb268c1d99622edc7e494d7a280e2e9974704

# Adversary 110, круг 4: проверка по закрытому перечню Arb110 §4 и регресс

Судья: Adv110r4 (adversary). Предмет: дверь `wip/110/implementer@c5ceb268c`, батарея
`wip/110/architect@5cef0d00f` (86 клеток, 62 мутанта). Первоисточник перечня:
`main:verdicts/arbitration/contracts-110-impl-ostatok-n1.md`, прочитан целиком.
Всё делалось под `/tmp/dev-harness-verify/Adv110r4/`. Основной чекаут не изменялся, push не выполнялся.

## Сборка W
`git archive 9bb5beb30` + `archive 5cef0d00f fixtures/workshop_project/done_volny_110 contracts/110-done-volny.md`
+ `archive c5ceb268c scripts/done_wave.sh package.json registry/ci-steps.tsv .github/workflows/ci.yml`, затем `git init` и commit.

## Сырые прогоны (rc)
| Команда (cwd W) | rc | Вывод |
|---|---|---|
| `bash fixtures/workshop_project/done_volny_110/probe.sh` | 0 | «случаев 86, зелёных честных 19/19, отказных с именованной причиной 67/67» (7.1 с) |
| `probe.sh --model` | 0 | то же 86/86 |
| `probe.sh --matrix` | — | ` mismatches=0`; mh1_profile_branch_cut → h1_profile_untracked_head_legacy; mc11_reason_after_a3 → c11_reason_priority_before_a3; ma2 → a2, h1 (447 с). rc не снят: вывод шёл через `tail` |
| `bash scripts/gen_ci_steps.sh --check` | 0 | — |
| `bash scripts/verify_ci_parity.sh` | 0 | «расхождений: 0» |
| `bash fixtures/workshop_project/done_volny_110/provodka.sh` | 0 | ключ ведёт в батарею 110 |
| `bash scripts/check_provodka.sh . contracts/110-done-volny.md` | 0 | — |
| `bash scripts/verify_antiplacebo.sh --scope verify_ci_parity check_provodka` | 0 | «фикстур: 54 · предъявлено красным: 54» |
| `cmp <(git show frozen/contracts/110/1^{commit}:contracts/110-done-volny.md) W/contracts/110-done-volny.md` | 0 | контракт = frozen |
| Блок `CASES = [` … последняя клетка (52 клетки, 17192 байт) замороженного probe.py как подстрока нового probe.py | True | смещение 12948 (без закрывающей `]`, после неё идут клетки кругов 2–4) |
| `grep wave110_cmd_on_head` в двери / модели / probe.py | 0 / 2 / 1 | в модели и probe.py остались только упоминания в комментариях («удалена»/«снята»); функции и вызовов нет |
| `grep 'символическ\|!= "null"' scripts/done_wave.sh` | 1 | мёртвые ветви С12 / reslop #5 удалены |

## Миры: Adv110r3 и арбитра, дверь передаётся аргументом
Скрипты Adv110r3 скопированы в `r3/`, BASE перенаправлен в мои `worlds/`.
Команда: `bash r3/attack7.sh W/scripts/done_wave.sh …`; мои миры: `bash attack_r4.sh <дверь>`.

| Мир | Ожидание по перечню | Дверь c5ceb268c |
|---|---|---|
| F1: прошлый билд в `out/` (.gitignore), свежий клон и после `bash build.sh` | ok (ложного отказа нет) | rc 0 v1 / rc 0 v1, тег на HEAD |
| F2: NFR `bash build.sh` → `out/run.sh`, e2e `sh out/run.sh` | ok | rc 0 v1; экспорт HEAD тоже rc 0 |
| H1: LEGACY HEAD (112 не done) + неотслеживаемые harness.project.json и layer.json → зелёный деко | refuse «профиль проекта расходится с HEAD: harness.project.json» | rc 1, ровно эта причина, refs не изменены; контроль без профиля: rc 1 «112 (нет done-тега)» |
| C1: `bash -c 'exit 0'` / `python3 -c` | ok | rc 0 v1 |
| C2: `bash ./e2e.sh` на HEAD | ok | rc 0 v1 |
| P1 `./e2e.sh` и P3 `cd tests && bash e2e.sh`, файл не на HEAD | ПРИНЯТЫЙ ОСТАТОК N1 (ok) | rc 0 v1. Соответствует п. 1, не блокер |
| З8/W6: harness.project.json на HEAD — файл, в дереве — symlink на тот же контент | refuse профиль | rc 1 «…: harness.project.json» |
| W7: то же для layer.json | refuse | rc 1 «…: layer.json» |
| W3: отслеживаемый harness.project.json изменён (profilePath → неотслеживаемый layer2.json → деко) | refuse профиль | rc 1 «…: harness.project.json» |
| W4a / W4b: отслеживаемый layer.json изменён / удалён | refuse | rc 1 «…: layer.json» / rc 1 «…: layer.json» |
| W2: H1-мир + причина «  » | «причина пуста» ДО профиля (И-8) | rc 1 «причина пуста» |
| W2b: изменённый профиль + «  » | «причина пуста» | rc 1 «причина пуста» |
| W2c: нерождённый HEAD + «  » | «причина пуста» ДО HEAD | rc 1 «причина пуста» |

## Мутанты НАСТОЯЩЕЙ двери против 86 клеток
Драйвер `mut.py`: для каждого мутанта копия W, правка `scripts/done_wave.sh`, прогон `probe.sh`.
Если клетка разошлась с ожиданием, мутант пойман. Позитивный контроль: немутированная дверь 86/86, rc 0.

| Мутант | Итог | Различающие клетки |
|---|---|---|
| D_H1_branch_cut (ветвь «в дереве есть, на HEAD нет» → `:`) | ПОЙМАН | h1_profile_untracked_head_legacy |
| D_H1_gate_head_only (охрана только при HEAD-профиле) | ПОЙМАН | h1 |
| D_PROFILE_all_off (весь блок профиля выключен) | ПОЙМАН | a2, e3, n11b, h1 |
| D_LAYER_untracked_ok | ПОЙМАН | e3, n11b |
| D_LAYER_const_path (зашитый profilePath) | ПОЙМАН | e3, n11b |
| D_HPJ_rm_ok | выжил, эквивалентен | удаление ловит следующий `git diff --quiet` (W3/W6 → та же причина) |
| D_HPJ_diff_off / D_LAYER_diff_off / D_LAYER_rm_ok | выжили (совет С-1) | на W3/W4/W6/W7 rc 1, refs не изменены: отказ даёт A1 или резолвер, другое имя причины. Приёма нет |
| D_REASON_after_A3 | ПОЙМАН | c11 |
| D_REASON_after_profile (A3 на месте) | ПОЙМАН | c11 |
| D_REASON_no_trim / D_REASON_off | ПОЙМАН | c11 / reason_empty, c11 |
| D_REASON_after_profile_A3_moved / D_REASON_after_HEAD_A3_moved | выжили (совет С-2) | см. ниже |
| D_UNTRACKED_judged (`--untracked-files=normal`) / D_UNTRACKED_all (`all --ignored`), то есть возврат к суду неотслеживаемых | ПОЙМАН | n1_ostatok_untracked_e2e_ok |
| R_A1_dirty_off | ПОЙМАН | a1, a1b, e1, e10, e11, n3a, n3b |
| R_N2_rc_off | ПОЙМАН | n2_status_unreadable |
| R_N3_lastword | ПОЙМАН | n3b |
| R_E1_unstaged_only | ПОЙМАН | e1 |
| R_E10_reg_prefix | ПОЙМАН | e10 |
| R_E11_dirty_after_e2e | ПОЙМАН | e11 |
| R_A3_off / R_E5_pwdL / R_E6_dotgit_dir | ПОЙМАНЫ | a3 / e5 / e6 |
| R_B1_tag_live_head | ПОЙМАН | b1 |
| R_A4_cleanup_default | ПОЙМАН | a4, b3 |

## Пункт перечня §4 ↔ проверка ↔ результат
| Пункт §4 | Проверка | Результат |
|---|---|---|
| Б0/Б4: ci.yml перегенерирован | gen_ci_steps --check, verify_ci_parity, provodka.sh, check_provodka | все rc 0: закрыт |
| Б1/С13/P*/N1c/N1d/Z4/Z10: эвристика удалена из двери и модели, клетки n1/n1b и MUT-N1/N1b удалены | grep (функции и вызовов нет); `--case n1_e2e_untracked_script` → rc 2 «неизвестный case»; в matrix нет mn1/mn1b | закрыт |
| Остаток N1: клетка-свидетель | n1_ostatok_untracked_e2e_ok ('ok',1) с комментарием Arb110 п. 1; мутанты D_UNTRACKED_* ею пойманы | закрыт |
| Остаток N1: строка шапки двери и модели | шапка двери :28-31 и модели :33: формулировка арбитра | закрыт |
| Б2/F2 | f2_build_out_e2e_ok зелёная; миры F2 и F1 → rc 0 v1 | закрыт |
| Б4/F1 | мир F1 (оба варианта) → rc 0 v1 | закрыт |
| Б3/H1: дверь = модель, ветвь до project_paths_resolve | мир H1 → нужная причина; клетка h1; модельный mh1 и дверные D_H1_* пойманы | закрыт |
| С11: причина до A3/HEAD/профиля | W2/W2b/W2c → «причина пуста»; c11 ловит «после A3» и «после профиля» | закрыт по двери; у батареи совет С-2 |
| С12 + reslop #5: мёртвые ветви symlink и `!= "null"` удалены | grep rc 1; typechange ловится (W6/W7) | закрыт |
| С10' / reslop #1–#4: шапка = факт | шапка двери без веса, хроники и разбивки. ОДНАКО `registry/ci-steps.tsv:137-146` и `done_wave.sh:216-220` не приведены к факту (см. review.md R-1, R-2) | не закрыт в части комментариев. Документный reslop, не обход: передано ревьюеру |
| Регресс прогонов | probe 86/86, --model 86/86, --matrix mismatches=0, scoped-регресс rc 0 | закрыт |
| Регресс A1–A5, Б1, N2, N3, N11b, E1/E3/E5/E6/E10/E11 | мутанты R_* и D_LAYER_* пойманы | держится |

## Советы (не блокеры)
- **С-1 (батарея, профиль).** Направление «отслеживаемый профиль или слой изменён либо удалён в
  дереве» не пришито клеткой к имени причины из §2 арбитра («профиль проекта расходится с HEAD»).
  Мутанты D_HPJ_diff_off, D_LAYER_diff_off и D_LAYER_rm_ok выживают. Гарантия при этом цела: приёма
  нет, refs не изменяются, отказ даёт A1 («рабочее дерево расходится…») или резолвер. Предложение
  architect: клетки W3/W4a с ожиданием `('refuse','профиль проекта расходится с HEAD: …')`.
- **С-2 (батарея, И-8).** c11 различает порядок причины только относительно A3. Мутант, в котором
  причина и A3 вместе переехали после HEAD или профиля, проходит 86/86. Наблюдаемый контрпример на
  мутанте: W2 (H1 + «  ») → «профиль проекта расходится…», W2c (нерождённый HEAD + «  ») →
  «HEAD недоступен», а И-8 требует «причина пуста». Настоящая дверь здесь верна (W2/W2b/W2c).
  Арбитр предписал ровно клетку c11 и мутант «после A3», оба на месте, поэтому это совет. Добавить
  клетки W2 и W2c стоит недорого.
- **С-3 (дверь ≠ модель, fail-closed).** W5: LEGACY HEAD, в дереве КАТАЛОГ `harness.project.json`.
  Дверь проверяет `-e` и отказывает «профиль расходится», модель и резолвер проверяют `-f` и
  принимают (rc 0 v1). Отказ лишний только в абсурдном мире, обхода нет.
- И-8 и проверка «корень не git» (rc 2) до причины: так же устроена модель, арбитр требует
  «до A3/HEAD/профиля». Только информация.

## Вывод
Все поведенческие обязательства перечня (H1/Б3, С11, F1/F2, снятие эвристики N1, клетка-свидетель,
ci.yml) на настоящей двери закрыты замером. Регресс кругов 1–3 держится. Все мутанты настоящей двери
внутри перечня, которые меняют исход (приём или отказ), батарея ловит. Выжившие мутанты либо
эквивалентны, либо меняют только имя отказа, либо требуют переноса A3 (С-1, С-2). Обхода с
наблюдаемым контрпримером на требовании контракта не найдено, поэтому `accept`. Отдельно:
документная часть С10' (комментарий ci-steps и комментарий `if !`) не приведена к факту. Это reslop
(review.md R-1/R-2), не обход. Закрывать ли пункт, решают ревьюер и оркестратор.

Артефакты: `mut.py`, `attack_r4.sh`, `r3/` (копии скриптов Adv110r3 с перенаправленным BASE), `W/`.
