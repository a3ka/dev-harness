FAIL
OBJECT=c5ceb268c1d99622edc7e494d7a280e2e9974704

# Ревьюер, круг 4 — реализация 110 по закрытому перечню Arb110 §4. Итог: К ВЛАДЕЛЬЦУ

Объекты: реализация `wip/110/implementer@c5ceb268c`, батарея `wip/110/architect@5cef0d00f`,
контракт `frozen/contracts/110/1` (коммит 201805d77). Перечень взят из
`main:verdicts/arbitration/contracts-110-impl-ostatok-n1.md`, документ прочитан целиком. Находки в
формате reslop лежат в `review.md` рядом.

FAIL по пункту §4 «Rev С10' / reslop #1–#4». Implementer переписал комментарий к шагу 110 в
`registry/ci-steps.tsv` в этом круге (c5ceb268c) и сослался в нём на `probe.sh --matrix`. Но
описан состав батареи прошлого круга: «84 клетки … n1/n1b …; 5 mn* (mn11b/mn2/mn3/mn1/mn1b)».
Моя мера по батарее 5cef0d00f: 86 клеток, n1/n1b удалены, mn* три (mn11b, mn2, mn3), добавлены
mh1 и mc11. Пункт перечня требует «счёт клеток/мутантов = фактический; разбивку … берёт из вывода
`--matrix`», и это требование не выполнено. Из того же пункта не выполнена часть «комментарий про
`if !`» (reslop #4): он остался в `done_wave.sh:214-219`. Круг открыт, пункт перечня FAIL, поэтому
по условию задания кап, К ВЛАДЕЛЬЦУ. Правка текстовая и в зоне impl, поведение двери она не меняет.

## Сборка (только `/tmp/dev-harness-verify/Rev110r4/`)

```
git -C /home/harness/dev-harness archive 9bb5beb30 | tar -x -C …/W
git -C … archive 5cef0d00f fixtures/workshop_project/done_volny_110 contracts/110-done-volny.md | tar -x -C …/W
git -C … archive c5ceb268c scripts/done_wave.sh package.json registry/ci-steps.tsv .github/workflows/ci.yml | tar -x -C …/W
git -C …/W init && add -A && commit                                    → OK
```

## Сырые прогоны (W)

| Команда | rc | Вывод |
|---|---|---|
| `bash fixtures/workshop_project/done_volny_110/probe.sh` (дверь) | 0 | «ИТОГ: случаев 86, зелёных честных 19/19, отказных с именованной причиной 67/67», real 6.9 s |
| `probe.sh --model` | 0 | «ИТОГ: случаев 86, … 19/19, … 67/67» |
| `probe.sh --matrix` | 0 | 86 случаев зелёные на модели; 62 строки «МУТАНТ … различающих случаев: ≥1» (mh1 → h1, mc11 → c11, ma2 → a2+h1); « mismatches=0»; wall 447 s |
| `bash scripts/gen_ci_steps.sh --check` | 0 | (пусто) |
| `bash scripts/verify_ci_parity.sh` | 0 | «… matrix-ключей: 47 · анти-плацебо-запусков: 2 · расхождений: 0» |
| `bash fixtures/workshop_project/done_volny_110/provodka.sh` | 0 | «проводка 110: ключ check:done-volny-110-family-selftest ведёт в батарею 110 (package.json + ci-steps + ci.yml)» |
| `bash scripts/check_provodka.sh . contracts/110-done-volny.md` | 0 | (пусто) |
| `reslop t -- bash scripts/verify_antiplacebo.sh --scope verify_ci_parity check_provodka` | 0 | «барьеров: 2 · фикстур: 54 · предъявлено красным повторным прогоном: 54», passed 54 failed 0 |

## Красное предъявлено (моими мутантами двери, не мутантами модели architect)

| Мир | rc | Расхождение |
|---|---|---|
| W_h1: в двери ветвь «на HEAD нет, в дереве есть» заменена на `:` | 1 | `h1_profile_untracked_head_legacy РАЗНОГЛАСИЕ rc=0 … new_tags=['done/waves/3/1']`, 66/67 |
| W_c11: проверка причины перенесена после A3 | 1 | `c11_reason_priority_before_a3 РАЗНОГЛАСИЕ rc=1 err='done_wave: корень не корень репозитория: …/sub'`, 66/67 |
| W_old: дверь прошлого круга dce75f00a (с эвристикой) | 1 | красные n1_ostatok (rc=1), f2 (rc=1), h1 (rc=0, тег), c11; «17/19, 65/67» |

## Неизменность замороженного (своя мера, `frozen_check.py`)

- Блоб контракта в W: `git hash-object` = 4dc5a957efef…; у frozen/contracts/110/1 тот же 4dc5a957efef…
- Блок `CASES = [ …` замороженного probe.py (201805d77, 17192 байта) — байтовая подстрока нового
  probe.py: True. Первые 52 элемента `CASES` нового модуля равны 52 замороженным: True.
- `cmp` provodka.sh frozen ↔ W: rc 0.
- Модель удалила `wave110_cmd_on_head` и клетки/мутанты n1/n1b по решению арбитра §4 («arch»).
  Это не подгонка: в замороженном блоке этих клеток нет.

## Область правки (дословно по §Зоны frozen-блоба :306-307)

- `git diff --stat 9bb5beb30 c5ceb268c` затрагивает ровно `scripts/done_wave.sh package.json
  registry/ci-steps.tsv .github/workflows/ci.yml`, что совпадает с ЗОНА implementer. Все коммиты
  диапазона автора `implementer`.
- `git diff --stat 9bb5beb30 5cef0d00f` затрагивает только `fixtures/workshop_project/done_volny_110/`
  (model, probe.py, probe.sh), то есть подмножество ЗОНА architect. Контракт не менялся.
- ПЕРЕСЕЧЕНИЯ :309-320 (`ci_keys.py`, база 9bb5beb30 против c5ceb268c): из package.json ничего не
  удалено и не изменено, добавлен один ключ `check:done-volny-110-family-selftest` → `bash
  fixtures/workshop_project/done_volny_110/probe.sh`. В ci-steps удалённых строк 0, добавлена одна
  `step check:done-volny-110-family-selftest 8 npm run …`. В ci.yml удалённых ключей 0, добавлен один
  ключ, и вне строк `keys:` diff пуст: это производная регенерация.

## Таблица «пункт §4 ↔ проверка ↔ результат»

| Пункт §4 | Проверка | Результат |
|---|---|---|
| Б0/Б4 ci.yml перегенерирован | `gen_ci_steps --check` rc 0; `verify_ci_parity` rc 0; `provodka.sh` rc 0; `ci_keys.py` | PASS |
| Б1+С13+P1–P6…: эвристика удалена из двери и модели | grep `wave110_cmd_on_head` по двери: 0 вхождений; в модели только комментарии; клеток n1/n1b и мутантов MUT-N1/N1b нет (импорт probe.py) | PASS |
| Клетка-свидетель N1 | `n1_ostatok_untracked_e2e_ok` (`bash e2e.sh`, e2e.sh только в дереве), ожидание ('ok', 1), комментарий дословно; на двери ok; на W_old красная | PASS |
| Строка ОСТАТОК в шапке двери и модели | дверь :28-31, модель :33: текст совпадает, эвристика из шапки снята | PASS (совет: в двери `"` вместо `“`) |
| Б2/F2 | `f2_build_out_e2e_ok` → ('ok', 1), на двери ok, на W_old красная | PASS |
| Б4/F1 | закрыто F2 по §4 | PASS |
| Б3/H1 | ветвь стоит до `project_paths_resolve` (:86-89 → die …harness.project.json); клетка h1 ok; красное W_h1; мутант `mh1_profile_branch_cut` в MUTANTS | PASS |
| С11 (И-8) | `[ -n "${REASON//[[:space:]]/}" ] \|\| die "причина пуста"` стоит сразу после проверки «git-репозиторий», до A3/HEAD/профиля; клетка c11 ok; красное W_c11; мутант `mc11_reason_after_a3` | PASS |
| С12 + reslop #5 | grep `символическ` и `!= "null"` по двери: 0 | PASS |
| С10' / reslop #1–#4 | шапка двери без веса, хроники и счётчиков: выполнено. **ci-steps: «84 клетки … n1/n1b … 5 mn* (…mn1/mn1b)» против факта 86 / mn*=3 / mh1, mc11** — неверно. Комментарий про `if !` (:218) и хроника «rev110 С8», «adv110 N11b» остались | **FAIL** (Б1-r4 в review.md) |
| Прогон батареи: probe/model/matrix/CI-паритет/antiplacebo | см. «Сырые прогоны» | PASS |

## Регресс кругов 1–3

На двери c5ceb268c все клетки регресса зелёные: A1–A4, Б1 (b1_head_pinned_tag), Б3
(b3_reason_hash_only), N2, N3 (n3a/n3b), N11b, E1/E3/E5/E6/E10/E11, а также 13 D* и 52
замороженных. Источник — прогон `probe.sh`, 86/86 rc 0. Проверка грязного отслеживаемого дерева
(`status --porcelain=v1 -z --no-renames --untracked-files=no`) сохранена до NFR/e2e, как требует
арбитраж п. 1.

## Паразитная сложность (050), по артефактам диффа круга

- Ветвь H1 в двери (`else die …harness.project.json`). (1) Свойство: И-1 / модель угроз «профильный
  реестр», граница п. 2 арбитража. (2) Нового состояния не вводит. (3) Дверь, модель и клетка h1 —
  число файлов не выросло. (4) Одна ветвь, интерфейс не менялся. (5) Потребитель — клетка h1.
  ESSENTIAL.
- Перенос проверки причины. (1) И-8. (2) Состояния нет. (3) Не выросло. (4) Строк стало меньше.
  (5) Потребитель — клетка c11. ESSENTIAL.
- Удаление `wave110_cmd_on_head` и двух symlink-ветвей: дифф чистый, −78 строк. Новых артефактов
  нет.
- Комментарий ci-steps: свойства не несёт, а его счёт неверен. Это блокер по пункту перечня, а не
  по 050.

## Советы (не блокеры)

- Строка ОСТАТОК: в двери ASCII-кавычка `"`, в модели и арбитраже `“`.
- Ветвь `profilePath вне корня` (из круга 3) не имеет клетки и мутанта. Вне перечня.
- c5ceb268c объединяет четыре пункта §4 в одном коммите. Так было во всех кругах 110.
- Вне перечня (не переоткрываю): N1 во всех написаниях, N12, N2b/N4/N10, С1–С3, A6–A12, Z4/Z10.
