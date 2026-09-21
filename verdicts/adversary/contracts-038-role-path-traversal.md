# Adversary 038 — role path traversal survives round-1 fix

**Verdict: FAIL.** Судимый HEAD: `e0dddc03952778f61e5a29aaadfdf9a42c38eb73`. Предмет: `contracts/038-provodka-done-gejt.md`; реализации: `scripts/check_provodka.sh`, `scripts/check_consumers.sh`, `scripts/done_contract.sh`. Найден **1 новый блокирующий обход**. Предмет и реализации не правились.

Воспроизведение только в `/tmp/dev-harness-verify/adversary038k2_repro.sh`; оно создаёт одноразовые toy-репозитории исключительно в `/tmp/dev-harness-verify/adversary038k2/` и запускает реальные скрипты с судимого HEAD. Полный запуск `bash /tmp/dev-harness-verify/adversary038k2_repro.sh` завершился rc 0.

## Б3 — `role=` всё ещё выходит из одного сегмента `roles/`

Исправление Б1 использует:

```bash
case "$path" in
  roles/[^/]*.md) ;;
  *) die ... ;;
esac
```

Но в pattern языка `case` в Bash `*` матчится и на `/`; ограничение `[^/]` действует только для его первого символа. Поэтому строка:

```text
ПРОВОДКА:
- role=roles/../policies/r.md «Policy norm.»
```

проходит этот `case`. При файловой проверке `$ROOT/$path` нормализуется в
`$ROOT/policies/r.md`: это существующий не-role файл с отдельной строкой нормы.

Живой toy содержит одновременно существующие `roles/critic.md` и
`policies/r.md`; последний несёт `Policy norm.`. Настоящий reader и настоящий
writer приняли обход и writer создал done-тег:

```text
traversal-reader-bypass: rc=0
traversal-real-done-bypass: rc=0
traversal-real-done-tag: present
```

Так `roles/../policies/r.md` нарушает обязательную грамматику
`roles/<роль>.md` и требование строгого одного сегмента, но проходит до
`done/contracts/038/1`. Это не named residual.

Соседние крайние формы проверены тем же запуском:

```text
role-empty-basename: rc=1 named       # roles/.md
role-dot-basename: rc=0               # roles/..md
role-traversal-no-md: rc=1 named      # roles/../../etc/passwd
```

`roles/..md` отвечает текущему буквальному `case` (один файловый сегмент с
суффиксом `.md`); он не добавлен отдельным блокером. Блокер — путь с внутренним
`/`, который `*` не запрещает.

## Закрытые Б1 и Б2, а также соседняя цепочка tools

Исходный Б1 закрыт: существующий не-role файл больше не принимается.

```text
B1-policies-r-md: rc=1 named
```

Причина содержит `role-канал обязан ссылаться строго на roles/<роль>.md`.

Исходный Б2 закрыт: toy имеет полный маппинг из трёх обязательных writers,
живой frozen-тег, изменённый `scripts/freeze_contract.sh` в окне и не имеет
обязательной `ПОТРЕБИТЕЛЬ fixtures/reader.sh:`-пробы. Обычный reader даёт
именованный rc 1, а подмена `tail` с rc 127 в унаследованном PATH больше не
создаёт vacuous rc 0:

```text
B2-normal-missing-probe: rc=1 named
B2-fake-tail-ignored-by-trusted-PATH: rc=1 named
```

Проверены соседние программы той же цепочки. Каждая подменена бинарником rc
127 перед `/usr/bin:/bin`; скрипт фиксирует PATH до вызовов и продолжает
выполнять настоящие `git`, `sort` и `cat`, достигая той же предметной именованной
красной ветви, а не ошибки инструмента либо зелёной пустоты:

```text
B2-fake-sort-ignored-by-trusted-PATH: rc=1 named
B2-fake-git-ignored-by-trusted-PATH: rc=1 named
B2-fake-cat-ignored-by-trusted-PATH: rc=1 named
```

Позитивный контроль честной минимальной role-проводки также зелёный и ставит
настоящий done-тег:

```text
positive-role-reader: rc=0
positive-real-done: rc=0
positive-real-done-tag: present
```

## Быстрая сверка named residual

Все три ранее названные границы механики остались такими же, не включены в
счёт блокеров:

```text
residual-consumer-stub: rc=0
residual-fenced-role: rc=0
residual-guard-echo: rc=0
```

Для guard-echo дополнительно настоящий `done_contract.sh` поставил
`done/contracts/038/1` (тег резолвится в
`431fc82469de0001cd11092c54bf96198c9a619f`), хотя `scripts/guard.sh` возвращает
99 и workflow содержит лишь `run: echo guard`; это сохранённый §Риски-2
residual, не новый блокер. Самопроверка `contracts/039-check-protected-rename.md`
на живом HEAD также остаётся зелёной: `check_provodka.sh` вернул rc 0.

**Счёт найденных обходов: 1.** Нужна правка автора: проверка должна отдельно
исключить `/` из всей части после `roles/`, а не только из её первого символа;
после этого обход обязан стать именным отказом до проверки файла.
