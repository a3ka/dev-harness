accept

# Суд закрытия R016-2, контракт 016 — круг 3

Проверен только заявленный узкий предмет: независимость proof-слоя R016-2 и
живость уже принятых в кругах 1–2 барьеров. Все прогоны, которые создают
репозитории, ветки или worktree, выполнены **только** в одноразовом клоне
`/tmp/review-r016r3.e1MESj` (`git clone /home/aka/Documents/dev-harness
/tmp/review-r016r3.e1MESj`). Живое дерево использовалось только для чтения и
для записи этого вердикта.

**Итог:**

- **R016-2 — закрыто.** После `frozen/contracts/016/4` единственный автор
  изменений трёх fixture-каталогов — `architect` в `4aa5631`; механизм с моего
  предыдущего вердикта `7e5ed45` не менялся. Новый
  `land_agent/case_chuzoj_worktree.sh` не является проверкой, созданной
  implementer-автором механизма. Его самостоятельный зелёный и красный входы
  подтверждены ниже, включая отдельные сохранности.
- **Раскрытая продуктовая находка `spawn_agent.sh` — не блокирует закрытие
  016.** Я воспроизвёл оба дефекта: документированные `--root` и `--nnn`
  парсер отвергает, а автоматический выбор после живой `wip/005/existing`
  выдаёт `wip/001/reviewer`, потому что `g` объявлена после первого вызова.
  Это дефект реализации и документации, но не нарушение узкого принятого
  контракта: в §«Незаполненные требования» 016 прямо оставляет имена
  аргументов/флагов деталью реализации, а контрактные свойства здесь — форма
  `wip/<NNN>/<автор>` и именованный отказ при живом **том же** имени —
  сохранены. `wip/001/reviewer` свободна и имеет требуемую форму; повтор её
  был бы отвергнут. Исправление должно идти отдельным defect-fix после done,
  без расширения 016; превращать его в блокер означало бы молча расширить
  предмет вопреки границе владельца B.

## Авторство, границы, атомарность, норма

Заморозка v4 разрешает architect все три fixture-каталога (включая
`fixtures/spawn_agent/`, `fixtures/land_agent/`,
`fixtures/gc_agent_branches/`) и отдельно сохраняет легитимные v1–v3
implementer-коммиты. `4aa5631` атомарно меняет только два proof-файла:
переписанный R016-2 case и ложный комментарий каркаса GC. Нормативных файлов
и `scripts/` этот коммит не меняет. Тем самым область не превышена и норма не
ослаблена.

Сырой history и diff из клона:

```text
$ git log --format='%an %h' frozen/contracts/016/4..HEAD -- fixtures/spawn_agent fixtures/land_agent fixtures/gc_agent_branches
architect 4aa5631
rc=0

$ git log --oneline 7e5ed45..HEAD -- scripts/
rc=0

$ git diff --name-status 4aa5631^..4aa5631
M       fixtures/gc_agent_branches/_repo.sh
M       fixtures/land_agent/case_chuzoj_worktree.sh
rc=0
```

Это устраняет именно прежний класс R016-2: permanent fixture теперь
переавторствована architect независимо от implementer-механизма. Красное
предъявлено не пересказом: проверяющий вновь запустил сохранённый красный
вызов в изолированном клоне.

## Самостоятельное предъявление R016-2 в клоне

`review_chuzoj_worktree.sh` построил свою зелёную пару
`wip/010/implementer` + `wt-010`, затем две разные ветки с разными коммитами
и вызвал `--branch wip/030/implementer --worktree wt-020`. Помимо кода и
причины отказа скрипт отдельными assertions проверял main, обе refs и оба
worktree:

```text
$ bash ./review_chuzoj_worktree.sh; rc=$?; printf 'rc=%s\n' "$rc"; exit "$rc"
green rc=0
Deleted branch wip/010/implementer (was 9db5bd9).
LANDED main=7ee5eb9c2240a331f010c6d757be63d14e335e4c branch=wip/010/implementer
green landing and immediate cleanup: ok
red rc=1
ОТКАЗ: HEAD worktree 789a39a9 не совпадает с tip ветки 482f007c — предмет не в worktree (И-8)
preservation main: ok
preservation branches wip/020,wip/030: ok
preservation worktrees wt-020,wt-030: ok
rc=0
```

## Обязательные живые прогоны в том же клоне

```text
$ bash scripts/verify_antiplacebo.sh . --scope spawn_agent; rc=$?; printf 'rc=%s\n' "$rc"; exit "$rc"
SCOPED: барьеров 1 из выборки — не для приёмки
  ok   spawn_agent/case_bez_identichnosti.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «HEAD не main»

барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1
rc=0

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

$ bash scripts/verify_antiplacebo.sh . --scope gc_agent_branches; rc=$?; printf 'rc=%s\n' "$rc"; exit "$rc"
SCOPED: барьеров 1 из выборки — не для приёмки
  ok   gc_agent_branches/case_zavisshaja_peredvinuta.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «цель заявленной зависшей сменена»
  ok   gc_agent_branches/case_zavisshaja_snesena.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «заявленная зависшая ветка не наблюдается»

барьеров: 1 · фикстур: 2 · предъявлено красным повторным прогоном: 2
rc=0

$ bash fixtures/check_staged/probe_check_staged_krasnyj.sh; rc=$?; printf 'rc=%s\n' "$rc"; exit "$rc"
ok: стаб честной формы — все пять case: зелёный контроль + красное повтором
ok: стаб зоны-слеп пойман на входе case_vne_zon
ok: стаб грамматика-слеп пойман на входе case_imja_control_simvol
ok: стаб всё-красно пойман на зелёном контроле
ok: стаб канарейка-слеп пойман на входе case_imja_fake_python3_exit_1
ok: судья зелёный на живом дереве (staged пуст, всё в зоне либо автор не объявлен)
rc=0

$ bash fixtures/check_hooks/probe_check_hooks_krasnyj.sh; rc=$?; printf 'rc=%s\n' "$rc"; exit "$rc"
ok: стаб честной формы — все семь case: зелёный контроль + красное повтором
ok: стаб хук-декой пойман на входе case_huk_ne_vedet_k_sude
ok: стаб установщик-декой пойман на входе case_bez_ustanovshhika
ok: стаб проба-слеп пойман на входе case_inert_heredoc_hook
ok: стаб ф1-декой пойман на входе case_huk_sniffer_toy
ok: стаб ф2-фикс-декой пойман на входе case_huk_forged_output
ok: механизм установки хука цел на живом дереве
rc=0

$ ! grep -rnE '\bgit\b[^|<>]*[[:space:]](commit|merge)[[:space:]]' scripts/ | grep -vE ':[0-9]+:[[:space:]]*#' | grep -v merge-base | grep -vE 'user\.(name|email)=|GIT_(AUTHOR|COMMITTER)_(NAME|EMAIL)' | grep .; rc=$?; printf 'rc=%s\n' "$rc"; exit "$rc"
rc=0

$ git ls-files 'fixtures/check_staged/case_*.sh' 'fixtures/check_hooks/case_*.sh' 'fixtures/spawn_agent/case_*.sh' 'fixtures/land_agent/case_*.sh' 'fixtures/gc_agent_branches/case_*.sh' | wc -l; rc=$?; printf 'rc=%s\n' "$rc"; exit "$rc"
24
rc=0
```

Последний счёт выполнен отдельной мерой по tracked `case_*.sh`, а не повтором
заявленного автором способа.

## Раскрытая находка `spawn_agent.sh`: сырое воспроизведение

В том же одноразовом клоне я сначала создал только `wip/005/existing`, затем
запустил документированный вызов и автоматический вызов. Проба завершилась
нулём, потому что оба дефекта были именно ожидаемым наблюдаемым результатом;
она удаляет созданные ветки/worktree перед выходом.

```text
$ bash ./review_spawn_defects.sh; rc=$?; printf 'rc=%s\n' "$rc"; exit "$rc"
documented --root rc=1
spawn_agent: неизвестный аргумент: --root
использование: spawn_agent.sh --author <имя> [--nnn <номер>] [--root <каталог>]

auto-number rc=0
WORKTREE=/tmp/dev-harness-worktrees/2da36b17/wip-001-reviewer
BRANCH=wip/001/reviewer
defect reproduced: existing wip/005 did not advance automatic number
rc=0
```

Ни это воспроизведение, ни закрытый R016-2 не меняют механизм или норму.
Вердикт заменяет предыдущий `FAIL` `7e5ed45` и разрешает закрыть 016.
