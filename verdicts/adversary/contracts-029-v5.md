accept

# Контракт 029 — адверсарий, круг 5

Судится только применение трёх фиксов круга 4 из
`verdicts/adversary/contracts-029-v4.md`; caller-PATH/TCB-класс, замороженный
арбитражем `verdicts/arbitration/tcb-granica-put-029.md` §4, не переоткрывался.
Замеры сделаны в одноразовом клоне `/tmp/dev-harness-verify/adv5-20260919-029/repo`
на `ecdf6af`; игрушечные репозитории, внешние файлы, симлинки и обёртки жили
только в его `/tmp`-скретчах.

## Три фикса

* Внешний файл: честная тройка `КОМАНДА: cat ../outside.txt` получила `rc=1` и
  именованный отказ `вне белого списка: файловый операнд … за пределы --root`.
  Тот же итог (`rc=1`, та же причина) дали `cat evidence-link`, где
  `evidence-link -> ../outside.txt`; цепочка `evidence-link-2 -> evidence-link`,
  абсолютный путь, и `nested/../../outside.txt`. Канонизация `realpath -m`
  закрывает и `..`, и резолв симлинков.
* Форма с разделителем аргументов также не обходит границу:
  `cat -- ../outside.txt` завершился `rc=1` с именованным отказом о файловом
  операнде. Варианты `cat -- -/../../outside.txt` и
  `ls -- -/../../outside.txt` отвергнуты раньше, `rc=1`, как неразрешённая
  опция; это fail-closed, а не доступ к внешнему файлу.
* Обёртка `git`, видимая `command -v` и завершающая каждый вызов с `rc=1`, дала
  `check_fork_route.sh rc=2`, текст `нет инструмента git (неработоспособен)`.
  Тот же контроль с `rc=127` также дал `rc=2`.
* Обёртка `cat`, печатающая файл ответа без изменений, затем завершающаяся с
  `rc=1`, дала `verify_consultant.sh rc=2`, текст `cat непригоден — нечем
  проверить (rc=1)`. При `rc=127` получен тот же код `2` и именованный текст.

Положительные контроли: честный `cat README.md`, `cat` с пустым stdin и `ls` без
операндов (с оракулом в том же `env -i PATH=/usr/bin:/bin LC_ALL=C.UTF-8`, что
у барьера) дали `verify_consultant.sh rc=0`. Следовательно, отказы выше не
являются заглушкой «всегда красный».

Поломка `git` в caller-PATH против `verify_consultant.sh` дала `rc=0`: это не
дефект данного круга. Барьер исполняет git-переисполнение в своём
`env -i PATH="$TRUSTED_PATH"`; caller-обёртка там не вызывается, а в
предварительной проверке она лишь разрешается через `command -v`. Это именно
исключённый PATH/TCB-класс, а не неработоспособность инструмента, которым
барьер фактически проверяет ответ. Аналогично `cat` не является инструментом
`check_fork_route.sh`; обёртка cat оставляет его конформный вход зелёным
(`rc=0`).

Гитлинк не переоткрывался: существующая живая красная фикстура
`fixtures/verify_consultant/red_lozhnyj_rc.sh` включает Г4 и прошла (`rc=0`).

## Живость прежних предъявлений и scoped-регресс

Все девять прежних красных предъявлений завершились `rc=0`:

```text
bash fixtures/check_fork_route/red_degradacija_taimer.sh
bash fixtures/check_fork_route/red_flush_batcha.sh
bash fixtures/check_fork_route/red_marshrut_a_inzhenernyj.sh
bash fixtures/check_fork_route/red_marshrut_b_volja_batch.sh
bash fixtures/check_fork_route/red_marshrut_v_soreview.sh
bash fixtures/check_fork_route/red_schet_peredatochnyh.sh
bash fixtures/check_fork_route/red_zapret_dvojnoj_roli.sh
bash fixtures/verify_consultant/red_deko_bez_rc.sh
bash fixtures/verify_consultant/red_lozhnyj_rc.sh
```

`npm run check:antiplacebo -- --scope check_fork_route verify_consultant` →
`rc=0` (2 барьера, 3 постоянные фикстуры); полный прогон не запускался.

`git diff --exit-code frozen/contracts/029/1 HEAD --
contracts/029-auto-konsultant-forkov.md` → `rc=0`.
