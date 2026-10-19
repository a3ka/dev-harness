FAIL
OBJECT=698060db450009698b3b9946552429a41f405871

# Адверсарий 996, круг 2

## Блокирующая находка 1 — каталог принимается как sourceCanon.sources[].path

**Обход.** Грамматика контракта требует, чтобы `sources` содержал существующие **файлы** внутри R. В `scripts/check_project_sources.sh` проверка существования использует `-e`, а не проверку регулярного файла; затем `readlink -f` подтверждает только нахождение цели внутри R. Поэтому каталог внутри R удовлетворяет реализации как «источник», запускает gate и открывает `pre_critic` с rc 0. Канон без файла тем самым считается сверенным, хотя требование источника не выполнено.

Состояние дерева контрпримера: в project world создан `directory-is-not-file/`; `harness.project.json` объявляет его единственным `sourceCanon.sources[0].path`, gate остаётся честным наблюдателем. Та же проба затем заменяет путь на честный `SOURCE.md` как позитивный контроль.

Сырая команда и свидетельство:
```text
$ python3 /tmp/dev-harness-verify/Adv996r2/source_directory_repro.py; printf 'RC=%s\n' $?
directory_check_project_sources_rc=0
directory_pre_critic_rc=0
file_check_project_sources_rc=0
RC=0
```

Проверка не ловит ошибку: в матрице нет клетки «каталог вместо source-файла» и мутации, заменяющей файловый предикат принятием каталога. Зелёная матрица не опровергает этот обход:
```text
$ bash fixtures/workshop_project/rezhim_996/probe.sh --matrix; printf 'RC=%s\n' $?
996: examined=88 mutants=63 mismatches=0
RC=0
```

## Блокирующая находка 2 — resolver принимает неотносительный путь и передаёт его роли

**Обход.** `sourceCanon.sources[].path = "../outside.md"` при существующем файле вне R проходит `profile_resolver.sh` с rc 0. `make_task --print-context` тоже возвращает rc 0 и передаёт именно этот неотносительный путь как effective `sourceCanon` (`context_has_nonrelative_path=True`). Только другой consumer, `check_project_sources.sh`, позднее отказывает. Это оставляет вторую грамматику в consumer и нарушает требование контракта: путь источника должен быть относительным внутри R, а замкнутая грамматика sourceCanon обязана отказываться действующим resolver до доставки контекста ролям.

Сырая команда и свидетельство:
```text
$ python3 /tmp/dev-harness-verify/Adv996r2/resolver_relative_path_repro.py; printf 'RC=%s\n' $?
resolver_rc=0
make_task_context_rc=0
check_project_sources_rc=1
context_has_nonrelative_path=True
check_project_sources_stderr=ОТКАЗ: SOURCE_CANON_INVALID: .. в пути: ../outside.md
RC=0
```

Это не отказ «для всех»: соответствующий gate-consumer действительно отказывает, но required resolver и role-context принимают неверный юнит. Проба matrix содержит только `source-traversal-escape` через consumer и поэтому остаётся зелёной.

## Закрытия круга 1 и позитивные контроли

1. Старые репро symlink и `..` источника на OBJECT теперь отказывают:
```text
$ python3 /tmp/dev-harness-verify/Adv996r2/round1_source_repros.py; printf 'RC=%s\n' $?
symlink_rc=1
symlink_stderr=ОТКАЗ: SOURCE_CANON_INVALID: источник вне репозитория: linked-source.md
traversal_rc=1
traversal_stderr=ОТКАЗ: SOURCE_CANON_INVALID: .. в пути: ../outside-source.md
RC=0
```
2. npm-ключ больше не является `true`/no-op: неизвестная клетка возвращает диспетчерский rc 2.
```text
$ npm run check:rezhim-996-family-selftest -- --case __no_such_case__; printf 'RC=%s\n' $?
> bash fixtures/workshop_project/rezhim_996/probe.sh --case __no_such_case__
probe.py: error: argument --case: invalid choice: '__no_such_case__'
RC=2
```
3. Позитивный контроль честного regular source приведён в свидетельстве находки 1 (`file_check_project_sources_rc=0`); product matrix зелёная: `examined=88`, `mutants=63`, `mismatches=0`.
4. Scoped-регресс затронутых барьеров зелёный:
```text
$ bash scripts/verify_antiplacebo.sh --scope profile_resolver pre_critic done_contract; printf 'RC=%s\n' $?
барьеров: 3 · фикстур: 13 · предъявлено красным повторным прогоном: 13
RC=0
```

## Frozen-проверка

```text
$ git diff --exit-code frozen/contracts/996/1 -- contracts/996-*.md fixtures/workshop_project/rezhim_996/; printf 'RC=%s\n' $?
RC=1
```

Diff содержит только три файла `fixtures/workshop_project/rezhim_996/` и добавляет клетки закрытий круга 1; запуск matrix выше показывает увеличение до `examined=88` и `mutants=63`. Ослабления наблюдаемых старых клеток не предъявлено, однако эти добавления не покрывают два обхода выше.

## Совет

В одном месте определить предикат source-file (регулярный файл после канонизации в R) и применять его как часть валидации sourceCanon resolver; удалить дублирующую грамматику из `check_project_sources.sh`, оставив там исполнение gate и проверку изменяемого существования. Добавить red-клетки для каталога и для относительности пути на resolver/role-context.
