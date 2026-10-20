FAIL
OBJECT=dce75f00a513678acd4ad7bed43e662aba6947fb

# Adv110r3: атака на реализацию 110 (scripts/done_wave.sh), круг 3

Судья: adversary (Adv110r3). Предмет: `wip/110/implementer@dce75f00a`. Батарея: `wip/110/architect@d41494b06`
(84 клетки, 62 мутанта). Дерево W собрано по заданию: archive 9bb5beb30, поверх d41494b06 (батарея и контракт),
поверх 4 файла OBJECT, затем `git init`. OBJ — чистый `git archive dce75f00a`. Все миры одноразовые, лежат в
`/tmp/dev-harness-verify/Adv110r3/worlds`. Скрипты в той же папке: `attack.sh`, `attack4.sh`, `attack6.sh`
(круги 1–2, перенесены, путь двери передаётся аргументом), `attack7.sh` (новые поверхности), `attack8.sh`
(миры заглушек Z), `decoys3.py` (мутанты новой двери), `fixctl3.py` (позитивный контроль правки → дерево FIX),
`frozen_check.py`.

## 0. Приёмка судьи

```
W$ bash fixtures/workshop_project/done_volny_110/probe.sh                        → rc 0  «случаев 84, зелёных честных 17/17, отказных с именованной причиной 67/67» (6.6 с)
W$ bash scripts/verify_antiplacebo.sh --scope verify_ci_parity check_provodka    → rc 0  «барьеров: 2 · фикстур: 54 · предъявлено красным повторным прогоном: 54»
W$ bash scripts/gen_ci_steps.sh --check                                          → rc 1  «дрейф блока JOBS — побайтовое расхождение с генерацией из реестра»   ← Б0
W$ bash scripts/verify_ci_parity.sh                                              → rc 0  «расхождений: 0»
W$ bash fixtures/workshop_project/done_volny_110/provodka.sh                     → rc 0
W$ bash scripts/check_provodka.sh . contracts/110-done-volny.md                  → rc 0
git diff --exit-code frozen/contracts/110/1 d41494b06 -- contracts/110-done-volny.md → rc 0
git diff --exit-code frozen/contracts/110/1 dce75f00a -- contracts/110-done-volny.md → rc 0
python3 frozen_check.py → «замороженных клеток 52 | клеток круга 3 84 | изменены/пропали замороженные: [] |
                           не подстрока нового probe.py: [] | добавлено: 32 | W probe.py == d41494b06: True»
```
`--matrix` я не запускал: его прогнал оркестратор, и бюджет я потратил на атаки.

### Б0. БЛОКИРУЕТ (приёмка): `gen_ci_steps.sh --check` красный на самом OBJECT
Это не артефакт сборки W. На чистом `git archive dce75f00a` (OBJ) тот же отказ, rc 1. На 953be6f26 и
530e8a4a6 rc 0. Причина — коммит dce75f00a: он поднял вес `check:done-volny-110-family-selftest` в
`registry/ci-steps.tsv` с 6 до 8, а `.github/workflows/ci.yml` не перегенерировал (LPT-раскладка lane
изменилась). Шапка двери (:21) по-прежнему говорит «вес в ci-steps.tsv — 6». Живой CI на ключе
`check:gen-ci-steps-coherence` будет красным.
Позитивный контроль: `OBJ$ bash scripts/gen_ci_steps.sh --write` меняет 12 строк ci.yml, после этого `--check` → rc 0.

## 1. Закрыто на деле: replay кругов 1–2 на новой двери

| # | Мир | Круг 2 (530e8a4a6) | Круг 3 (dce75f00a) |
|---|---|---|---|
| N2 | испорченный `.git/index`, HEAD:e2e.sh exit 1, в дереве exit 0 | rc 0 v1 | **rc 1** «не удалось определить состояние рабочего дерева: fatal: .git/index: index file smaller than expected», refs без изменений |
| N11b | слой `layer/p.json` не на HEAD, в дереве неотслеживаемый, указывает на деко | rc 0 v1 | **rc 1** «профиль проекта расходится с HEAD: layer/p.json» |
| N11a/N11c | контроли | rc 1 / rc 1 | rc 1 «112 (нет done-тега)» / rc 1 «… project-layer.json» |
| N1 | `bash e2e.sh`, e2e.sh не на HEAD | rc 0 v1 | **rc 1** «команда не на HEAD: e2e.sh» |
| N1c | `bash nfr.sh`, nfr.sh в .gitignore | rc 0 v1 | **rc 1** «команда не на HEAD: nfr.sh» |
| N1b | `git rm --cached e2e.sh` | rc 1 | rc 1 «рабочее дерево расходится с HEAD: e2e.sh» |
| N3b/N3c | правка HEAD-источника с кириллицей/пробелом в имени | ложный rc 1 | **rc 0 v1** |
| N3d | грязный `docs/otkat.md x/e2e.sh` | rc 1 искажённый путь | rc 1, путь целиком |
| A1/A1b/A2/A3/A4/A5 | миры круга 1 | закрыты | закрыты: A1 rc 1, A1b rc 1, A2 rc 1, A3 rc 1, A4 v2 со строкой владельца, peeled = HEAD до вызова |
| control, N6/N7/N8 | честный мир; detached HEAD; корень через симлинк; linked worktree | rc 0 | rc 0 v1 |

Остатки, которые уже приняты или не изменились: N1d (`. ./helper.sh` неотслеживаемый) → rc 0 v1 (принят);
N12 → rc 0 v1 (принят); N10 → rc 0 v1 (принят); N2b skip-worktree → rc 0 v1; N4 → rc 0 v1; A6/A7/A8/A12 → rc 0;
A9 `done/waves/3/08` → bash `:326: 08: value too great for base`, `v: unbound variable`, rc 1.

## 2. Мутанты новой двери против пробы 84 (`python3 decoys3.py`)

Каждый мутант — dce75f00a, установленный в копию W как scripts/done_wave.sh.

| Мутант | probe | пойман клеткой |
|---|---|---|
| E1 грязь = `git diff -z --name-only` (только worktree против index) | rc 1 | e1_staged_edit |
| E3 охрана слоя профиля вырезана | rc 1 | e3_layer_untracked_deco, n11b_layer_profile_path |
| E5 топлевел сравнивается с `pwd -L` | rc 1 | e5_root_symlink_ok |
| E6 корень = есть каталог `.git` | rc 1 | e6_linked_worktree_ok |
| E10 исключение грязи по префиксу `$REG_REL/` | rc 1 | e10_registry_prefix_dirty |
| E11 проверка грязи после NFR/e2e | rc 1 | e11_dirty_before_commands |
| Z1 `wave110_cmd_on_head` ничего не делает | rc 1 | n1_e2e_untracked_script, n1b_nfr_untracked_script |
| Z2 / Z3 проверка команд только NFR / только e2e | rc 1 / rc 1 | n1_… / n1b_… |
| Z5 rc `git status` игнорируется (N2) | rc 1 | n2_status_unreadable |
| Z6 у слоя проверяется только diff, без «есть на HEAD» | rc 1 | e3_…, n11b_… |
| Z7 имя слоя зашито `project-layer.json` | rc 1 | n11b_layer_profile_path |
| Z8 без `-z` (разбор porcelain построчно) | rc 1 | n3a_dirty_cyrillic_path, n3b_dirty_space_path |
| **Z4 интерпретаторы сужены до `bash`** | **rc 0, 84/84** | — |
| **Z10 проверка команды e2e после её запуска** | **rc 0, 84/84** | — |
| Z9 diff-проверка harness.project.json вырезана | rc 0 | эквивалентный мутант: правку ловит общая проверка грязи (`attack8.sh`: rc 1 «рабочее дерево расходится с HEAD: harness.project.json») |

Все E-заглушки круга 2 (E1, E3, E5, E6, E10, E11) и новые Z1–Z3, Z5–Z8 проба ловит. Дыры батареи
(адресат architect, наблюдаемо по `attack8.sh`):
- Z4. Мир: `nfr sh nfr.sh` и `e2e python3 e2e.py`, оба файла неотслеживаемые. Честная дверь → rc 1
  «команда не на HEAD: nfr.sh», заглушка → **rc 0 v1**. Клетки на `sh`/`python3` нет.
- Z10. Мир: неотслеживаемый e2e.sh делает `rm -f e2e.sh; exit 0`. Честная дверь → rc 1, заглушка →
  **rc 0 v1**. Клетки «проверка до запуска» нет. Шапка двери это обещает, но фактический порядок
  нарушает (см. Б2).

## 3. БЛОКИРУЕТ: новые наблюдаемые обходы на изменённых поверхностях

Все миры — `bash attack7.sh <door>`. Контроль «экспорт HEAD» — это `git archive HEAD`, затем та же команда.

### Б1. Закрытие N1 узкое: оно держится только на шаблоне «интерпретатор⎵файл-от-корня»
Требование то же, что у клетки n1_e2e_untracked_script: дверь отказывает «команда не на HEAD», если
исполняемого кода волны нет на HEAD. Предикат `wave110_cmd_on_head` (:251-269) проверяет только слово,
стоящее сразу после `bash|sh|…|source`, и только как буквальный путь от корня. Честные формы той же команды
проходят мимо. Во всех мирах ниже e2e.sh не на HEAD, `status -uno` пуст, дверь → **rc 0 v1, тег поставлен**:

| мир | команда e2e | экспорт HEAD |
|---|---|---|
| P1 | `./e2e.sh` (прямой запуск, самая частая форма) | rc 127 «No such file» |
| P2 | `bash -e e2e.sh` | rc ≠ 0 «No such file» |
| P4 | `bash e2e.sh;` | rc 127 |
| P5 | `bash "e2e.sh"` | rc 127 |
| P6 | `sh -c ./e2e.sh` | rc 127 |
| P3 | `cd tests && bash e2e.sh` (tests/e2e.sh) | rc 127 |

Контроль без ложных отказов: C1 (`bash -c 'exit 0'`, `python3 -c …`) → rc 0 v1; C2 (`bash ./e2e.sh`,
файл на HEAD) → rc 0 v1.

### Б2. Честная волна «собрать, затем запустить собранное» отклоняется всегда
Шапка двери (:28-29) обещает отказ «команда не на HEAD» **ДО запуска команд**. Код же проверяет e2e
(:293) уже после того, как исполнены все NFR (:272-290). Мир F2: `nfr bash build.sh` (меряет сборку,
печатает `zamer 3 s`; build.sh на HEAD) и `e2e sh out/run.sh`, `out/` в .gitignore, свежий клон, `out/`
до вызова отсутствует. Дверь → **rc 1 «команда не на HEAD: out/run.sh»**, хотя экспорт HEAD (NFR, затем
e2e) → rc 0. И-5 требует «сквозной запуск собранной системы», то есть тег не ставится на честном мире.

### Б3. Профиль из рабочего дерева при отсутствии harness.project.json на HEAD (класс A2/N11b)
Охрана профиля (:69-104) включается только при `cat-file -e HEAD:harness.project.json`. При этом
`project_paths_resolve` (scripts/next_id.sh:353) читает harness.project.json **рабочего дерева**. Мир H1:
на HEAD профиля нет (LEGACY, `registry/`: волна 3 = 111 + 112, у 112 нет done), на HEAD закоммичен
`.harness/ledger` (только 111). Контроль: дверь → rc 1 «112 (нет done-тега)». Затем в дерево кладутся
неотслеживаемые harness.project.json (`profilePath: layer.json`) и layer.json (`registry: .harness/ledger`),
`status -uno` пуст. Дверь → **rc 0 v1**, тег `done/waves/3/1` → HEAD a7c3fa70…: волна с нетерминальной
112 принята. Правило И-1 («реестр — профильный … корневой registry/ — не запасной источник») при этом
применено к профилю, которого на HEAD нет.

### Б4 (адресат architect, цена решения (a)). Результат зависит от остатков прошлой сборки
Мир F1: `e2e bash build.sh && sh out/run.sh`, `out/` в .gitignore. На свежем клоне → rc 0 v1. На том же
HEAD (дерево b4cd5fab… совпадает), где разработчик один раз запустил build.sh → **rc 1 «команда не на HEAD:
out/run.sh»**. Честный мир получает отказ из-за игнорируемого артефакта. Исключить игнорируемые пути
(`git check-ignore`) — значит заново открыть N1c. Выбор за architect. Правка ниже F1 не закрывает.

### Позитивный контроль правки (`python3 fixctl3.py` → дерево FIX, только зона implementer)
Три правки:
(1) если harness.project.json нет на HEAD, но он есть в дереве → «профиль проекта расходится с HEAD:
harness.project.json»;
(2) предикат проверяет КАЖДОЕ слово команды (без кавычек, без `./`, без хвоста `;&|)`, флаги и абсолютные
пути пропускаются), включая первое слово;
(3) все команды NFR и e2e проверяются до запуска первой.

Результаты на FIX:
- `FIX$ probe.sh` → **rc 0, 84/84** (17/17, 67/67);
- P1, P2, P4, P5, P6 → rc 1 «команда не на HEAD: e2e.sh»;
- F2 → rc 0 v1;
- H1 → rc 1 «профиль проекта расходится с HEAD: harness.project.json»;
- C1, C2 и control → rc 0 v1; A1, A2, N1, N1c, N2 → rc 1.
- Остаются P3 (`cd tests && …`) и F1: это класс N1d (транзитивный путь), их решает architect.

При этом проба одинаково зелёная и на OBJECT, и на FIX: клеток на P1/P2, F2 и H1 в ней нет.

## Итог

FAIL. N2, N11b и N1 (в форме `bash e2e.sh`/`bash nfr.sh`) на деле закрыты. Все E-заглушки круга 2 проба
ловит. Блокеры:
- **Б0** — `gen_ci_steps --check` rc 1 на OBJECT (вес 6→8 без `--write`);
- **Б1** — N1 обходится честными формами `./e2e.sh`, `bash -e e2e.sh`, `bash "e2e.sh"`, `bash e2e.sh;`,
  `sh -c ./e2e.sh` → rc 0 v1;
- **Б2** — сборочная волна NFR→e2e ложно отклоняется: проверка стоит после NFR, вопреки шапке;
- **Б3** — неотслеживаемый harness.project.json при LEGACY-HEAD подменяет реестр → rc 0 v1 на волне с
  нетерминальной 112.

Б0–Б3 исправляются в зоне implementer, проба при этом остаётся 84/84. Адресат architect: Б4 и P3 (решение
по классу «транзитивный/собранный код»), дыры батареи Z4 и Z10, а также отсутствие клеток P1/P2/F2/H1.
