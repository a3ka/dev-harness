FAIL

# Рере-ревью закрытия R016-1/R016-2 контракта 016

Проверен узкий fix `cf2d3eb` поверх предыдущего вердикта `39c0012`, на
`bdbd295`. Предыдущий FAIL этим файлом заменён. Все прогоны с мутациями
выполнены **исключительно в одноразовом клоне**
`/tmp/rev016.bjfiBR` (`git clone /home/aka/Documents/dev-harness
/tmp/rev016.bjfiBR`); живое дерево не было worktree ни одного прогона.

**Итог:**

- **R016-1 — закрыто.** `land_agent.sh` получает `tip_sha` до проверки
  диапазона и до единственного `git merge`; при `WT_HEAD != tip_sha` он
  выходит с rc 1 и точной именованной причиной И-8. Мой независимый toy-вход
  подтвердил, что это происходит до mutation `main`, с сохранением обеих
  веток и обоих worktree.
- **R016-2 — не закрыто, класс: проверка подогнана автором реализации.**
  Поведенческий кейс действительно даёт зелёный контроль и красный повтор на
  чужом worktree (это подтверждено ниже), но `cf2d3eb` с author
  `implementer <implementer@dev-harness.local>` одним коммитом изменяет
  **и** `scripts/land_agent.sh`, **и** новый
  `fixtures/land_agent/case_chuzoj_worktree.sh`. Следовательно, новая
  постоянная проверка создана тем же автором, чью реализацию она принимает.
  Это ровно незакрытая часть R016-2 из `39c0012`; зелёно-красный результат
  сам по себе не делает self-test независимым. Нужен отдельный коммит автора
  проверки, меняющий fixture независимо от implementer-кода. До этого общий
  вердикт остаётся **FAIL**.

## Границы, атомарность и норма

Сырой факт fix-коммита в клоне:

```text
$ git show --no-ext-diff --format=fuller --stat cf2d3eb
commit cf2d3ebabb7b981f9d54f58622d1d6b143cbda1f
Author:     implementer <implementer@dev-harness.local>
AuthorDate: Sun Aug 30 21:32:18 2026 +0200
Commit:     orchestrator <orchestrator@dev-harness.local>
CommitDate: Sun Aug 30 22:17:36 2026 +0200

    016 fix-delta: land_agent И-8 — отказ ДО merge на WT_HEAD != tip_sha (R016-1); кейс чужого worktree (R016-2)

 fixtures/land_agent/case_chuzoj_worktree.sh | 78 +++++++++++++++++++++++++++++
 scripts/land_agent.sh                       | 17 +++++--
 2 files changed, 91 insertions(+), 4 deletions(-)
rc=0

$ git diff --no-ext-diff --name-status cf2d3eb^..cf2d3eb
A	fixtures/land_agent/case_chuzoj_worktree.sh
M	scripts/land_agent.sh
rc=0
```

Это одна атомарная задача и ровно две относящиеся к ней реализации/fixture;
нормативные файлы fix-коммит не меняет. Это не устраняет процессную находку
R016-2: приведённый выше raw history одновременно доказывает, что fixture и
механизм созданы одним author.

Источник порядка проверен чтением `scripts/land_agent.sh`: вычисление
`wt_head`, `main_head`, `tip_sha` и отказ `WT_HEAD != tip_sha` находятся до
проверок И-9 и до единственного вызова `git ... merge --no-ff`.

## Прогоны в `/tmp/rev016.bjfiBR`

### Собственное воспроизведение R016-1

Мой toy создаёт целевую `wip/010/implementer` и отдельную чужую
`wip/011/implementer`, каждая — со своим worktree и commit. Он вызывает
`--branch wip/010/implementer` с worktree второй ветки, затем самостоятельно
сверяет rc, именованный И-8 отказ, неизменность `main`, наличие обеих refs и
обоих worktree.

```text
$ bash ./review_r016_1.sh; rc=$?; printf 'rc=%s\n' "$rc"; exit "$rc"
rc=1
ОТКАЗ: HEAD worktree b4eaca43 не совпадает с tip ветки 1745de4a — предмет не в worktree (И-8)
ОТКАЗ: HEAD worktree b4eaca43 не совпадает с tip ветки 1745de4a — предмет не в worktree (И-8)
ok: R016-1 own repro: refusal precedes merge; main, branches, worktrees preserved
rc=0
```

Первый `rc=1` — код самого `land_agent.sh`, напечатанный toy до захвата;
последний `rc=0` — код независимой проверки всех четырёх сохранностей.

### Явный новый вход R016-2

Отдельный toy повторяет форму нового case без доверия к его exit: зелёный
`wip/021` приземляется со своим `wt-021`; затем `--branch wip/023` получает
чужой `wt-022`. Toy сам сверяет rc 1, текст И-8, `main_before == main_after`,
две refs и два worktree.

```text
$ bash ./review_r016_2.sh; rc=$?; printf 'rc=%s\n' "$rc"; exit "$rc"
green rc=0
Deleted branch wip/021/implementer (was f552382).
LANDED main=61acdd8d8dbb4826df5e6c6b0900bbd5292e96a7 branch=wip/021/implementer
red rc=1
ОТКАЗ: HEAD worktree 044a82f2 не совпадает с tip ветки 6465beee — предмет не в worktree (И-8)
ОТКАЗ: HEAD worktree 044a82f2 не совпадает с tip ветки 6465beee — предмет не в worktree (И-8)
ok: R016-2 green landed; red foreign-worktree refusal preserved main, branches, worktrees
rc=0
```

Поведение R016-2 предъявлено, но постоянный case остаётся self-authored, как
зафиксировано в разделе выше.

### Обязательные контрольные прогоны

```text
$ bash scripts/verify_antiplacebo.sh . --scope land_agent; rc=$?; printf 'rc=%s\n' "$rc"; exit "$rc"
SCOPED: барьеров 1 из выборки — не для приёмки
  ok   land_agent/case_chuzoj_worktree.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «предмет не в worktree»
  ok   land_agent/case_gryaznyj_main.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «главное дерево загрязнено мимо worktree»
  ok   land_agent/case_identity_rasscheplena.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «identity расщеплена»
  ok   land_agent/case_imja_podstroka_reestra.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «имя вне реестра ролей»
  ok   land_agent/case_imja_vne_reestra.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «имя вне реестра ролей»
  ok   land_agent/case_kommit_mimo_merge.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «не несёт коммитов относительно main»
  ok   land_agent/case_merzh_ne_orkestrator.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «не несёт коммитов относительно main»
  ok   land_agent/case_priyomka_bez_vetki.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «HEAD worktree не отличается от main»
  ok   land_agent/case_vetka_perezhila.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «главное дерево загрязнено мимо worktree»

барьеров: 1 · фикстур: 9 · предъявлено красным повторным прогоном: 9
rc=0

$ bash fixtures/check_staged/probe_check_staged_krasnyj.sh; rc=$?; printf 'rc=%s\n' "$rc"; exit "$rc"
ok: стаб честной формы — все пять case: зелёный контроль + красное повтором
ok: стаб зоны-слеп пойман на входе case_vne_zon
ok: стаб грамматика-слеп пойман на входе case_imja_control_simvol
ok: стаб всё-красно пойман на зелёном контроле
ok: стаб канарейка-слеп пойман на входе case_imja_fake_python3_exit_1
ok: судья зелёный на живом дереве (staged пуст, всё в зоне либо автор не объявлен)
rc=0

$ ! grep -rnE '\bgit\b[^|<>]*[[:space:]](commit|merge)[[:space:]]' scripts/ | grep -vE ':[0-9]+:[[:space:]]*#' | grep -v merge-base | grep -vE 'user\.(name|email)=|GIT_(AUTHOR|COMMITTER)_(NAME|EMAIL)' | grep .; rc=$?; printf 'rc=%s\n' "$rc"; exit "$rc"
rc=0

$ git ls-files 'fixtures/check_staged/case_*.sh' 'fixtures/check_hooks/case_*.sh' 'fixtures/spawn_agent/case_*.sh' 'fixtures/land_agent/case_*.sh' 'fixtures/gc_agent_branches/case_*.sh' | wc -l; rc=$?; printf 'rc=%s\n' "$rc"; exit "$rc"
24
rc=0
```

Счёт сделан независимой от прежнего `find`-измерения командой и совпадает с
заявленным 24. Никакие старые пункты круга 1 не пересуждались.
