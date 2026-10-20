FAIL
Ревьюер Rev112r3, контракт 112 (frozen/contracts/112/2), круг 3, OBJECT=e564ed034ebfa15dc49e7a9e34e4a631bdb01b68 (union: 61260217c + f27db3964 + 9f549bec5 + c040b73dc + e564ed034). Что в порядке: зоны чисты, контракт не тронут, модель только ужесточена, прежние клетки не удалены. Все входы кругов 1–2 закрыты в РЕАЛИЗАЦИИ: 75 входов, расхождений «модель 1 / продукт 0» — 0. B4 закрыт: мутант ветви node красит D34/D35/D37, мутант npm raw-склейки красит D43/D44/D46/D47. Но найден НОВЫЙ класс обхода, на котором продукт и модель обе дают rc 0, а батарея 52/52 зелёная: раскрытия оболочки, которых нет в списке op_obolochki (кавычки, `\`, `{…,}`, `~`). Подтверждено исполнением: шаг CI реально запускает файл ВНЕ дерева (B1).

---
status: ready
object: e564ed034ebfa15dc49e7a9e34e4a631bdb01b68
contract: frozen/contracts/112/2
reviewer: Rev112r3 (anthropic/claude-opus-5-5)
date: 2026-10-20
round: 3
---

## Блокирующие находки

- [ ] **B1 [ОБХОД, (г)/(2): продукт rc 0 на дефектном профиле, батарея 52/52 зелёная; зоны implementer + architect] раскрытия оболочки вне списка `op_obolochki` ведут исполнение за пределы дерева.**
  Фрагмент продукта: `scripts/check_project_connection.sh:153-158`. `op_obolochki` запрещает только `| & ; ( ) < > \` $`. Затем `:170` (`toks=($v)`) судит токены как ЛИТЕРАЛЬНЫЕ пути. Но `gen_ci_workflow.sh:108-116` кладёт команду профиля в `run: |` как есть, и shell перед исполнением делает удаление кавычек (`'` `"`), удаление `\`, раскрытие `{a,}` и `~`. В итоге проверяется один путь, а исполняется другой.
  Фрагмент модели: `fixtures/workshop_project/podklyuchenie_112/model_check_connection.sh:83-88`, тот же список. Модель разделяет дефект, поэтому дифференциальный прогон implementer («модель 1 / продукт 0» = 0 на 239 вариантах) этот класс увидеть не может: он ловит только расхождения, а здесь обе стороны ошибаются одинаково.
  Входы (мир mob, одна мутация; литеральные имена в дереве — тот же приём, что в принятых клетках D39 `$evil.js` и D40 `evil;false`). Свидетель — `/tmp/dev-harness-verify/Rev112r3/probe_exec.sh`: `cd <мир> && bash -e -c "<команда>"`, cwd = корень клона, как в шаге CI:
  ```
  squote-escape  commands.lint="node '../outside/evil.js'"   (в дереве: каталог `'..`/outside/, файл `evil.js'`)
                 impl rc=0 model rc=0 | CI-исполнение: EXECUTED-OUTSIDE-TREE <S>/outside/evil.js (rc=0)
  dquote-escape  commands.lint='node "../outside/evil.js"'   (в дереве: `"..`/outside/`evil.js"`)
                 impl rc=0 model rc=0 | CI-исполнение: EXECUTED-OUTSIDE-TREE <S>/outside/evil.js (rc=0)
  backslash-esc  commands.lint='node \../outside/evil.js'    (в дереве: `\..`/outside/evil.js)
                 impl rc=0 model rc=0 | CI-исполнение: EXECUTED-OUTSIDE-TREE <S>/outside/evil.js (rc=0)
  brace-escape   commands.lint='node {../outside/evil.js,}'  (в дереве: `{..`/outside/`evil.js,}`)
                 impl rc=0 model rc=0 | CI-исполнение: EXECUTED-OUTSIDE-TREE <S>/outside/evil.js (rc=0)
  tilde-prefix   commands.test='npm --prefix ~ test'         (в дереве: каталог `~` с package.json)
                 impl rc=0 model rc=0 | CI-исполнение: > test > echo fake-home  fake-home (rc=0) — исполнен $HOME/package.json
  ```
  Это ровно то свойство, которое закрывали F1/F2 и D39–D41: «файл есть в дереве» и «реальная команда». Проверка признаёт файл, а исполняется `../outside/evil.js` вне клона. Комментарий-обещание `:43-45` («глобальная проверка операторов/подстановок оболочки В КАЖДОМ токене… метасимвол в имени файла/--prefix/script») этим не выполнен.
  Простейшая форма, проходящая те же строки приёмки: в продукте и модели заменить чёрный список на БЕЛЫЙ набор символов токена (например, `[A-Za-z0-9._/@:=+-]`). Честные литералы CI (`node backend/scripts/gen-contracts.js --check`, `npm --prefix backend run lint`, табы) в этот набор укладываются. Architect: клетка на каждое семейство раскрытий (кавычка / `\` / `{,}` / `~`), каждая красная на текущем e564ed034.

## Советы (не блокируют)

- [ ] A1 `verify_antiplacebo.sh . --scope check_project_connection` → rc 1 — принятый cognitive-only остаток (задание).
- [ ] A2 (kanon-remote, «БУКВАЛЬНО» стр. 84 блоба) Хвостовые байты в `git.canonicalRemote` принимают и impl, и model (rc 0/0). Резолвер переносит их в эффективное значение без изменений (`probe_remote.sh`): `…mob.git\0` и `…mob.git\n\n` против origin `…mob.git` → impl rc 0. Причина — `$(jq -r …)` срезает хвостовые `\n` и выбрасывает NUL. Обхода с наблюдаемым последствием не предъявлено: потребители на bash срезают так же [INFERENCE]. Поэтому это совет. Тот же механизм принимает `workflowPaths.contracts=".harness/contracts\n"`, `state+="\n"` и `sources[].path="docs/A.md\n"` (все rc 0/0).
- [ ] A3 Листовой symlink ФАЙЛА наружу по-прежнему принимают обе стороны (rc 0/0): `node mobile/scripts/lnk.js`, `sourceCanon.sources[].path="docs/leaf.md"`, `mobile/package.json -> <вне>/package.json`. `canon_R` для kind=file канонизирует только родителя (`:121-128`). Шапка `:46-48` («…листовой-symlink-наружу = отказ») верна только для каталогов. Нужно поправить комментарий или канонизировать лист через `readlink -f`/`realpath`.
- [ ] A4 Перевод строки в node (`node f.js\nexit 0`) — обе стороны rc 0, принято заданием.
- [ ] A5 Регресс диагностики в 9f549bec5: `:63` `printf '…неизвестный аргумент: %s\n' >&2` потерял `"$1"`. Вывод: `check_project_connection: неизвестный аргумент: ` (пусто), rc 2 сохранён. В 61260217c аргумент был.
- [ ] A6 (architect) `red_podkljuchenie_112.sh` всё ещё вызывает несуществующую `usage` (`line 620: usage: command not found`). rc 2 получается только через `exit "$rc"`.
- [ ] A7 (050, architect) Список komandy-клеток D34–D48 записан дважды: в главном цикле и в цикле анти-плацебо (4). При новой клетке оба места нужно менять вместе. Проще выводить второй список из первого (фильтр `D3[4-9]|D4*`).
- [ ] A8 source-canon: модель слабее продукта на симлинк-ЗВЕНЕ (`lnkdir/canon.md`: impl rc 1, model rc 0). Продукт строже, обхода нет, но эталон этой ветви неполон.

## (1) Входы кругов 1–2 против union (продукт и модель на одном входе)

Свидетели: `/tmp/dev-harness-verify/Rev112r3/probe.sh` (22 входа, до места сбоя разбора имени в моём скрипте) и `probe_b.sh` (53 входа). Счёт своей мерой: `grep -c '^probe '`. Итого 75 входов, **0 строк «модель 1 / продукт 0»**.
```
honest / node-honest-arg / tabs-sep / state-dotdot-into / src-honest      impl 0 model 0
r1-node-abs-etc, r1-node-abs-outside, r1-npm-prefix-abs                    impl 1 model 1  (F1)
r1-node-dotdot, r1-npm-prefix-dotdot                                       impl 1 model 1  (F2)
r1-npm-or-true, r1-npm-semicolon-exit0, r1-npm-bare-script                 impl 1 model 1  (F3)
r1-npm-run-missing-name, r1-true-spaces, r1-colon-noop                     impl 1 model 1
r2-node-or-true, r2-node-pipe, r2-node-or-exit0, r2-node-amp, r2-node-semicolon  impl 1 model 1  (B3)
r2-npm-prefix-dotdot-bare, r2-npm-prefix-sub-dotdot2, r2-dotdot-without-outer, r2-dotdot-run-lint-noout  impl 1 model 1  (B1 r2)
r2-npm-prefix-symlink-out                                                  impl 1 model 1  (B2 r2)
r2-npm-prefix-dollar, -twice, -eq, r2-npm-newline-tail, r2-npm-glob, r2-unicode-long, r2-src-dotdot  impl 1 model 1
r2-node-newline-exit0-A4, r2-node-dquote, r2-node-symlink-leaf-A3          impl 0 model 0  (советы)
a2-1 node-abs-inside, a2-2 npm-prefix-abs-in, a2-3 node-dollar, a2-4 node-semicolon,
a2-5 npm-script-dollar, a2-6 npm-prefix-semicolon, a2-7 npm-repeated-prefix, a2-leaf-npm-prefix  impl 1 model 1  (обходы 1–7 + лист)
a2-leaf-node, a2-leaf-source-canon                                         impl 0 model 0  (A3)
```
Честные back/mob ложных отказов не дали: M1/M2 зелёные в батарее, честные литералы в probe приняты.

## (2) Новый класс — перебор других ветвей

- komandy: раскрытия оболочки вне списка — **B1** (5 входов, исполнение вне дерева подтверждено).
- kanon-remote: хвостовые `\n`/`\n\n`/NUL — 0/0 (A2). `url.<канон>.insteadOf` при origin `https://evil.example/x.git` — 0/0: get-url возвращает переписанный URL, а это и есть буквальная мера контракта (стр. 84). `pushurl` evil и второй url origin — 0/0: контракт меряет только `get-url origin`.
- workflowPaths/state: симлинк-каталог наружу 1/1. `lnkdir/../.harness` 1/1. `.git` как state 0/0 (внутри клона, правилом контракта не запрещено). Хвостовой `\n` 0/0 (A2).
- source-canon: `..`, `docs/../../…`, абсолютный путь, пустой массив дают rc 1 через резолвер (`SOURCE_CANON_INVALID`). Каталог вместо файла 1/1. Звено-симлинк impl 1 / model 0 (A8). Лист-симлинк 0/0 (A3).
- profil: `\u0000`/CR/ведущие пробелы в командах — CR 1/1, остальное 0/0 и безвредно (NUL отбрасывается, `bash: ignored null byte`).

## (3) B4 — мутанты (свидетель `/tmp/dev-harness-verify/Rev112r3/mutant.sh`, клоны mut_node/mut_npm, батарея union)

```
mut_node: `if canon_R "$file" …` → `case "$file" in /*) REAL="$file";; *) REAL="$R/$file";; esac; if true`
  --cell D34=1 D35=1 D37=1 (красны); D43/D44/D46/D47=0; M1=0 M2=0
  полный: ИТОГ 112: клеток 52, зелёных 49, красных 3, rc=1
mut_npm: `if ! canon_R "$dnext" …` → `case "$dnext" in /*) REAL="$dnext";; *) REAL="$R/$dnext";; esac`
  --cell D43=1 D44=1 D46=1 D47=1 (красны); D34/D35/D37=0; M1=0 M2=0
  полный: ИТОГ 112: клеток 52, зелёных 47, красных 5, rc=1
```
Каждый мутант одной ветви красит собственные клетки, честные M1/M2 остаются зелёными. B4 круга 2 закрыт.

## (4) Модель не ослаблена

`git diff 61260217c HEAD -- model_check_connection.sh` (53+/12-) прочитан целиком. node: к прежнему `[ -f "$R/${toks[1]}" ]` добавлены непустой файл, запрет абсолютного пути, `cd && pwd -P` и префикс-проверка. npm: цикл по `--prefix` заменён ровно одним `--prefix` с полной канонизацией; голое имя (`*) script="$cur"`) заменено отказом; добавлены запрет хвоста и `op_obolochki` на каждом токене. `c040b73dc..e564ed034` меняет в модели 1 строку комментария (D34–D48). Ни одно прежнее условие не снято. Батарея: удалены только строки счёта (`37` → `vsego`) и строка цикла, в которую дописаны D34–D48. Ни одна прежняя клетка не удалена и не изменена.

## (а) Зоны и frozen

```
61260217c implementer: .github/workflows/ci.yml package.json registry/ci-steps.tsv scripts/check_project_connection.sh scripts/profile_resolver.sh
f27db3964 implementer: scripts/check_project_connection.sh
9f549bec5 implementer: scripts/check_project_connection.sh
c040b73dc architect:   fixtures/workshop_project/podklyuchenie_112/{model_check_connection.sh,red_podkljuchenie_112.sh}
e564ed034 architect:   fixtures/workshop_project/podklyuchenie_112/{model_check_connection.sh,red_podkljuchenie_112.sh}
git diff frozen/contracts/112/2^{commit}..HEAD -- contracts/112-podklyuchenie-proekta.md → 0 строк
```

## (в) Прогоны (клон `/tmp/dev-harness-verify/Rev112r3/m` @ e564ed034)

| команда | rc | вывод |
|---|---|---|
| `red_podkljuchenie_112.sh` | 0 | `ИТОГ 112: клеток 52, зелёных 52, красных 0, rc=0` |
| `--model` | 0 | `ИТОГ 112: клеток 52, зелёных 52, красных 0, rc=0` |
| `--cell net-takoj-kletki` | 2 | `line 620: usage: command not found` (A6) |
| state-слепая контрмодель (sed STATE-112) `--cell D14` / `D16` | 1 / 1 | расхождение поймано |
| komandy-слепая контрмодель (sed KOMANDY-112) `--cell D34…D48` | 1 ×15 | все 15 клеток красны против стаба |
| impl union `--cell D34…D48` | 0 ×15 | |
| impl 61260217c `--cell D34…D48` | 1 ×15 | полный: `клеток 52, зелёных 37, красных 15, rc=1` |
| impl f27db3964 `--cell` | D34/D35/D36/D46/D47/D48 = 0; D37–D45 = 1 | полный: `клеток 52, зелёных 43, красных 9, rc=1`. Новые клетки круга 3 красны ровно на обходах круга 2: подгонки нет |
| п.6 jq package.json / awk ci-steps.tsv | 0 / 0 | |
| `gen_ci_steps.sh --write && --check` | 0 | `git status --porcelain` → 0 строк |
| `verify_ci_parity.sh` | 0 | `… расхождений: 0` |
| `run_battery.sh profile_resolver` | 0 | `итог 4/4 классов закрыто` |
| `_krasnye_054.sh` | 0 | `итог 054: rc=0` |
| `check_provodka.sh . contracts/112-…md` | 0 | |
| `check_threat_model.sh . contracts/112-…md` | 0 | `ЗАЩИЩАЕТ 6, НЕ ЗАЩИЩАЕТ 4` |
| `verify_antiplacebo.sh . --scope check_project_connection` | 1 | `расхождений: 1` (A1, принято) |
| мутант node / мутант npm (полный) | 1 / 1 | `зелёных 49, красных 3` / `зелёных 47, красных 5` |
| probe_exec (B1, 5 входов) | impl 0 ×5 | исполнение вне дерева ×5 |

Свидетели прогонов: `runs.sh`, `mutant.sh`, `probe.sh`, `probe_b.sh`, `probe_exec.sh`, `probe_remote.sh` в `/tmp/dev-harness-verify/Rev112r3/`.

Счёт 52 своей мерой: токены `(M|K|D)NN-` в главном цикле = 52; метки `case` клеток = 52 (две разные команды). Число «239 вариантов» implementer не перепроверено: лог `diff_run5.log` несёт только итоговую строку. Мой независимый замер — 75 входов, 0 расхождений. Метод «модель 1 / продукт 0» по построению слеп к общим дефектам (B1).

## Паразитная сложность (050) — артефакты круга 3

- `canon_R` (impl, 9f549bec5). (1) Свойство «в дереве» для workflowPaths/state/komandy/source-canon (§Конструкция). (2) Состояние неявно передаётся через глобальную `REAL`, как раньше. (3) Три копии круга 2 (`check_inside_dir`, `canon_inside_R`, инлайн source-canon) сведены в одну, число файлов на правку сократилось. (4) Интерфейс — 4 аргумента, работа полная для каталогов; для файлов лист не разрешается (A3). (5) Потребители — D5/D6/D10/D13/D14/D16/D17/D34–D47. ESSENTIAL.
- `op_obolochki` (impl) + `op_obolochki` (model). (1) Закрытая форма komandy (стр. 85). (2) Состояния нет. (3) Грамматика живёт в 2 файлах (продукт и эталон). Это неизбежно для пары модель/продукт, но обе копии разделяют неполноту (B1). (4) Глубокий модуль: один `case`. (5) D36/D39–D41/D45. ESSENTIAL; дефект — чёрный список вместо белого (B1).
- Клетки D37–D48 (семья). (1) Свойства F1/F2/F3 и обходы круга 2. (2) Миры в `$SCRATCH`, внешние цели явные. (3) Батарея + модель, плюс второй список в анти-плацебо (A7). (4) По одной мутации на клетку. (5) Полный прогон и CI-шаг. ESSENTIAL.
- Ветвь `true\ *` (impl `:165`). Свойство «не `true`» (стр. 85); после глобальной проверки она частично дублирует отказ «вне семейств» (`true` — не npm/node/python3). Это совет, не блок: свойство то же, вред — лишняя ветвь.

## Починка (норма 050)

- implementer, `scripts/check_project_connection.sh`: B1 — белый набор символов для каждого токена (или явный запрет `' " \ { } ~ * ? [ ] #` и пробельных управляющих), до семейство-специфичной логики; A5 — вернуть `"$1"` в `:63`.
- architect, `fixtures/workshop_project/podklyuchenie_112/`: B1 — та же правка `op_obolochki` модели и клетки на каждое семейство раскрытий (кавычка / `\` / `{,}` / `~`), каждая красная на e564ed034 (сейчас impl и model дают rc 0); A6/A7 по желанию.
