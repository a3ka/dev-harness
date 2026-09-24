fail

# Контракт 037 M1+M2 — повторный адверсарный круг после фикса

Проверен `origin/main` на `7e01ed220991b23af4fffe89d029693f84b4e5cb` (на момент клонирования совпадал с HEAD). Найден один блокирующий дефект M1. Предыдущие блокеры M1 и M2 закрыты живыми пробами; регрессии зелёные.

## Блокер M1: условие HOME из п.4 фактически не применяется

`isSelfContainedCwdEligible()` вычисляет `realHome`, но после этого **не вызывает** обязательное п.4 `isWithin(realHome, canonicalActual)`. Анцесторный цикл предполагает это условие в комментарии, однако при `canonicalActual` вне HOME он идёт к `/` и завершается защитным `parent === cur`; при отсутствии `.git` у предков он не отказывает. Значит самодостаточный репозиторий вне `$HOME` с подходящим owner-артефактом получает разрешение на запись.

Живой зонд против настоящего `.omp/extensions/path-guard.ts` на текущем коде создал два обычных репозитория с ровно одной строкой `git worktree list`, не в `${TMPDIR}/dev-harness-verify`:

```
outside_home_bypass=pass
home_itself_bypass=pass
```

Первый случай: `actual=$BASE/outside`, тогда как `HOME=$BASE/home`; в `$BASE/.omp-isolation-owner.json` записан совпадающий `id`. Второй: `actual === HOME`, сам HOME является обычным репозиторием, а owner-артефакт лежит в его родителе. Оба должны быть `block`: первый прямо нарушает М1 п.4, второй также опровергает текст п.6, утверждающий, что кандидат `canonicalActual === HOME` «никогда не допускается по п.5».

Это не отрицательный контроль без owner-корреляции: в каждом случае `sessionName` литерально совпадает с `owner.json.id`, поэтому разрешение прошло через именно новую self-contained ветвь, а не через scratch allowlist. Это обход требований М1 к решению судьи; зелёная п4 существующей фикстуры не различает его, поскольку подаёт `sessionName`/owner.json так, что п.5 сама отказывает раньше п.4.

Нужен явный fail-closed отказ сразу после получения `realHome`, если `!isWithin(realHome, canonicalActual)`, и отдельные различающие проверки: вне-HOME с валидными п.2, п.3 и п.5; `canonicalActual === HOME` с теми же прочими валидными условиями.

## Закрытые направления M1

Точно повторён первый Outer/Inner-зонд настоящим CLI `node .omp/extensions/path-guard.ts --judge`:

```
Outer {"decision":"pass"}
Inner {"decision":"block","reason":"... Н-85/А-122 ..."}
```

Следовательно, легитимный Outer не регрессировал, а поддельный owner-артефакт для Inner больше не открывает запись.

Дополнительный зонд против настоящего модуля дал ожидаемый `block` для:

```
nested_outer_inner=block
nested_outer_mid_inner=block
linked_gitfile_ancestor=block
dead_gitdir_ancestor=block
```

`linked_gitfile_ancestor` использует реальный linked worktree, то есть `.git` у предка — gitfile; `dead_gitdir_ancestor` содержит `gitdir: /definitely/missing/gitdir`. Оба подтверждают fail-closed по наличию `.git`, без проверки живости gitdir.

Кэш-связанный вектор также не прошёл. В одном процессе модуля первый вызов для законного `cache-outer` дал `pass`, затем после создания `cache-outer/inner` как git-репозитория и подделки его owner-артефакта второй вызов дал:

```
cache_before_mutation=pass
cache_after_mutation=block
```

Следовательно, решение eligibility между вызовами не кэшируется; изменившийся `.git` предка пересчитывается.

## Закрытые направления M2

Настоящий `scripts/accept_task_commit.sh` прошёл позитивные контроли:

```
linear_two rc=0 files=a.txt,b.txt
linear_three rc=0 files=a.txt,c.txt
```

Ветка `wip/201/implementer` в обоих случаях содержит все указанные файлы, то есть каждый SHA передан `cherry-pick` отдельным argv, а не как embedded-newline строка.

Честные merge-диапазоны дали именованный отказ до создания временного worktree, sha мержа и неизменную ветку:

```
merge_last   rc=1 branch=unchanged sha=bf834ec9a422735132353f6977b4a3080ecee38c
merge_middle rc=1 branch=unchanged sha=a9a8b446f11bbdaeed7b50e0dc3bb77f18ab1ef5
octopus      rc=1 branch=unchanged sha=3fa80a40181c6631e467c4838b84521ecfd0816b
```

Каждый вывод содержит `ОТКАЗ: мерж-коммит в диапазоне — не поддерживается sha=<тот же sha>`. Дополнительно `-m 1` не интерпретируется как mainline-политика, а отвергается грамматикой CLI: `rc=1`, `неизвестный аргумент: -m`.

## Регрессии и обязательные проверки

Все команды запущены в проверочном SSH-клоне против текущего предмета:

- `bash fixtures/self_contained_cwd/red_self_contained_cwd.sh .` → `ветвей 8, красных 0, зелёных 8`.
- `bash fixtures/accept_task_commit/red_accept_task_commit.sh .` → `ветвей объявлено 7, прогнано 7, красных 0, зелёных 7`.
- `bash fixtures/check_runner_hygiene/red_pin_spawn_zadanie.sh .` → `ветвей 31, красных 0, зелёных 31`.
- `bash fixtures/check_runner_hygiene/red_pin_allowlist.sh .` → rc 0.
- `bash fixtures/check_runner_hygiene/red_granica_nepin_pipe_tee.sh .` → rc 0.
- `bash fixtures/check_runner_hygiene/red_strazh_vectora_utechki.sh .` → rc 0.
- `bash fixtures/parsing_hygiene_battery/run_battery.sh accept_task_commit` → `итог 4/4 классов закрыто`.

`frozen/contracts/037/1` в проверенном коммите отсутствует: `git ls-tree -r --name-only HEAD -- frozen/contracts/037/1 contracts/037-samodostatochnyj-cwd-i-priemnik-task.md` вернул только контракт. Поэтому требуемый diff с ним не исполнялся и не классифицируется как находка этого круга.

Вердикт не закрывает гейт нормы.
