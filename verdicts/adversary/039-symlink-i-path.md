FAIL

Судимый HEAD: `4de2123` (реализация переноса `222a82a`). Предмет и его проверки не изменялись. Одноразовый клон и воспроизводящие программы: `/tmp/dev-harness-verify/039-rename-adversary/`.

## Найдено: 2 обхода приёмки

### 1. Blob-инвариант принимает непригодный носитель `120000`

В чистом toy-репозитории защищённый регулярный `plans/001-p.md` содержит ровно байты `unrecoverable-artifact`. Удаляющий коммит удаляет этот путь и добавляет `notes/001-p.md` mode `120000` — dangling symlink с той же строкой как целью. Git хранит цель symlink в blob, поэтому её OID равен OID прежнего регулярного файла; сам symlink не резолвится и пригодного файла на HEAD нет.

Тем не менее:

```text
bash scripts/check_protected.sh cases/dangling-symlink-in-delete
→ rc=0
  ok   перенесён, контент жив на HEAD: plans/001-p.md
```

Это проходит обе текущие проверки `moved_for`: в удаляющем коммите есть `A notes/001-p.md` с blob B и B есть в `git ls-tree -r HEAD`. Ни mode, ни способность прочесть путь как обычный файл не проверяются. Та же ошибка воспроизведена вторым состоянием: честный regular rename в c, затем следующий коммит меняет только mode `notes/001-p.md` на тот же dangling symlink. `check_protected.sh` снова возвращает rc=0 с той же ok-строкой. Следовательно, носитель можно перенести, а затем испортить/удалить без `ALLOW`, сохранив лишь blob symlink-цели.

Нужное направление исправления: для q в c и для живого носителя B на HEAD требовать пригодный обычный file-entry (`100644`/`100755` по принятой грамматике) либо явно закрепить иной режим как пригодный. Проверка только OID не отличает regular file от symlink.

### 2. Подмена `comm` через PATH превращает реальное удаление в пустое `missing`

На том же toy-дереве обычное удаление без ALLOW даёт ожидаемый rc=1 и named FAIL. Затем перед барьером поставлен только `fakebin/comm`:

```bash
#!/usr/bin/env bash
exit 0
```

Вызов:

```text
env PATH=/tmp/dev-harness-verify/039-rename-adversary/fakebin:$PATH \
  bash scripts/check_protected.sh cases/control-delete
→ rc=0
область: … · существовало: 2 · на HEAD: 1 · исчезло: 0 · перенесено: 0
```

`comm -23 "$TMP/existed" "$TMP/head" > "$TMP/missing"` получает успешную пустую подстановку; цикл не видит удалённый артефакт. Скрипт санитизирует Git-переменные, но не задаёт доверенный PATH и не пинит утилиты. Это состояние среды даёт зелёный ответ при фактическом безвозвратном удалении.

Нужное направление исправления: до первой внешней команды задать минимальный доверенный PATH из системных каталогов или разрешённые абсолютные пути к применяемым утилитам; отсутствие требуемой утилиты обязано быть named rc=2, а не пустым успешным набором. Контроль отсутствующего git уже fail-closed: `env PATH=/nonexistent /usr/bin/bash …` дал rc=2.

## Контроли и другие пробы

* `cases/control-delete`: обычное удаление — rc=1 с `защищённый артефакт существовал и на HEAD его нет: plans/001-p.md`.
* `cases/control-rename`: byte-identical regular rename — rc=0 и обязательная ok-строка.
* `python3 run_chain.py`: цепочка `plans → verdicts → notes` с промежуточным изменением другого защищённого пути — rc=0, обе строки переноса есть; обхода нет.
* `bash scripts/drill_protected_rename.sh` — rc=0, оба честных переноса названы. `bash scripts/verify_antiplacebo.sh --scope drill_protected_rename` — rc=0, стаб `case_perenos_ne_priznan.sh` предъявлен красным. Дрилл корректно дискриминирует именно отсутствие распознавания regular rename, но не моделирует mode-change после него.
* `bash scripts/verify_antiplacebo.sh --scope check_protected` — rc=0, 20/20 красных предъявлены.
* `bash scripts/check_protected.sh` на судимом HEAD — rc=0, две существующие строки переноса.
* Октопус из трёх родителей с `plans/001-p.md` одним и тем же blob не образовал ложной зелени: rc=1. Причина отдельная: `git log -1 --format=%P` отдаёт родителей одной строкой, а `while read` в `moved_for` принимает её как один несуществующий object name. Это false-red для разрешённого одинакового-blob merge, не обход и в счёт не входит.

Н-111: текст подготовлен вне основного дерева; его blob записан `git hash-object -w`, внесён ровно этим путём через `git update-index --cacheinfo`, commit создан с `user.name=adversary`, `user.email=adversary@dev-harness.local`; затем путь materialized только `checkout HEAD --`. Н-73: выводы сформулированы как контрольные состояния и наблюдаемое поведение.
