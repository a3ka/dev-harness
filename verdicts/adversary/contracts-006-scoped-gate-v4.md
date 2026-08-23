accept

# Контракт 006: подтверждающий adversary-круг v4 — инвариант N

Проверен реализованный `scripts/scope_select.sh` только в предписанной арбитром области: N1/N2 и ветви `у–щ` `scripts/check_scope_select.sh`. Предмет, барьер и замороженный контракт не менялись.

## Итог атаки

Ложного сужения в модели угроз арбитра не найдено. Для изменения барьера `b` N1 возвращает `MODE: full`, когда другой барьер `a` содержит в исполняемой не-комментарной строке байты `b.sh` либо симлинк-алиас `link.sh`; N2 возвращает `MODE: full` для видимого source с нелитеральным basename. Полнострочный комментарий остаётся единственным намеренно исключённым случаем и даёт проверенный позитивный `MODE: scoped`.

Исполняемая матрица находится только в `tmp/adversary-006v4/` и запускается из корня:

```bash
bash tmp/adversary-006v4/repro_name_guard.sh
```

Фактический результат:

```text
ok midline → full
ok literal → full
ok dynamic_alias → full
ok n2 → full
ok comment-positive → scoped
N1/N2 adversarial matrix: green
```

Матрица строит отдельный git-репозиторий на случай, коммитит базу и правку тела `b`, затем вызывает реальный `scope_select.sh`. `midline` проверяет `:; . "$(dirname "$0")/b.sh"`; `dynamic_alias` — `link.sh -> b.sh` и source через alias; `literal` подтверждает fail-closed по самому имени в строке; `n2` — `[ -f "$cfg" ] && . "$cfg"`. Тем самым проверены классы mid-line, байт-имени, симлинк-алиаса, видимой нелитеральной source-инструкции и позитивный контроль вычета комментариев.

Отдельно рассмотрен потенциальный обход `command . "$1"`, передающий `b.sh` только в рантайме. Его стенд:

```bash
bash tmp/adversary-006v4/repro_boundary_only.sh
```

фактически исполняет `a` с `b` и получает `MODE: scoped`, `KEY: b`; однако в `a` нет байтов `b.sh`. Это полностью-переменный путь без плейнтекст-имени цели — явно исключённая арбитром граница §3, поэтому не является дефектом 006 и не предъявляется как finding.

## Предписанная приёмка

```bash
pkill -9 -f 'verify_antiplacebo|check_scop' || true
bash scripts/verify_antiplacebo.sh "$PWD" --scope check_scope_select
```

Вернула `0`: все 24 фикстуры, включая семь новых `case_vetv_{u,f,h,c,ch,sh,shch}*.sh`, напечатали «зелёный контроль есть, повторный прогон красный», итог — `предъявлено красным повторным прогоном: 24`.

Также выполнено точечно:

```bash
bash scripts/check_scope_select.sh "$PWD" у
bash scripts/check_scope_select.sh "$PWD" ф
bash scripts/check_scope_select.sh "$PWD" х
bash scripts/check_scope_select.sh "$PWD" ц
bash scripts/check_scope_select.sh "$PWD" ч
bash scripts/check_scope_select.sh "$PWD" ш
bash scripts/check_scope_select.sh "$PWD" щ
```

Все семь завершились `0`: `у/ф/х/ц/ч` требуют `full`, `ш` сохраняет scoped при имени только в полном комментарии, `щ` подтверждает scoped ровно независимого изменённого ключа.
