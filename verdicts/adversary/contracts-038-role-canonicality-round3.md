# Adversary 038 — role canonicality bypasses survive round-3 traversal repair

**Verdict: FAIL.** Судимый HEAD: `583fe381505a8000976a20e340deec683eac133c` (`583fe38`). Предмет: `contracts/038-provodka-done-gejt.md`; судимая реализация: `scripts/check_provodka.sh` (и настоящий писатель `scripts/done_contract.sh`). Предмет и проверки не правились.

Полное воспроизведение — только в `/tmp/dev-harness-verify/adversary038k3_repro.sh`; одноразовый клон предметного HEAD — `/tmp/dev-harness-verify/adversary038k3-clone`. Команда:

```bash
bash /tmp/dev-harness-verify/adversary038k3_repro.sh
```

завершилась `rc=0` с `ALL ROUND-3 ADVERSARY REPRODUCTIONS PASSED`.

## Найдено: 2 обхода `role=roles/<роль>.md`

### Б1 — симлинк из `roles/` резолвится в не-role норму

Toy содержит Git-trackable симлинк:

```text
roles/actor.md -> ../policies/r.md
```

и единственную проводку:

```text
ПРОВОДКА:
- role=roles/actor.md «Policy norm.»
```

Строка лексически проходит обе стадии текущей проверки: `roles/*.md`, затем в остатке `actor.md` нет `/`. Но `[ -f "$ROOT/$path" ]` и `grep -Fxq -- "$norm" "$ROOT/$path"` разыменовывают симлинк и засчитывают `policies/r.md`, то есть не-role файл.

Живой запуск настоящего reader и writer:

```text
symlink-reader-bypass: rc=0
symlink-done-bypass: rc=0
symlink-done-tag: present
```

Писатель поставил `done/contracts/038/1` для канала, который не ведёт к role-файлу. Проверке необходима проверка канонической цели без разыменования (`roles/*.md` должен быть обычным файлом роли, не симлинком наружу), до поиска нормы.

### Б2 — пустое имя роли `roles/.md` принимается и приводит к done-тегу

Грамматика контракта требует `roles/<роль>.md`; в toy есть файл `roles/.md` и поле:

```text
ПРОВОДКА:
- role=roles/.md «Empty role norm.»
```

После заменившей старый `[^/]*.md` первой стадии текущий `case` использует `roles/*.md`. В shell-glob `*` допускает пустую строку, а остаток `.md` не содержит `/`; таким образом отсутствующий `<роль>` проходит обе стадии.

```text
empty-role-reader-bypass: rc=0
empty-role-done-bypass: rc=0
empty-role-done-tag: present
```

Это не `roles/<роль>.md`: компонент роли пуст. Проверка обязана требовать непустой остаток до суффикса `.md`, не только отсутствие `/`.

## Контроли и закрытые ветви

Позитивный контроль честной минимальной role-проводки обязателен и зелёный, включая настоящий writer и тег:

```text
positive-reader: rc=0
positive-done: rc=0
positive-done-tag: present
```

Собственный обход круга 2 закрыт именно по имени, и writer его не обходит:

```text
traversal-reader: rc=1 named
traversal-done: rc=1 named
```

БЙ1 остаётся закрыт: `role=policies/r.md` даёт именованный `rc=1` с `role-канал обязан ссылаться строго на roles/<роль>.md`.

Проверенные границы ASCII `/` также именованно красны:

```text
slash-before-suffix-reader: rc=1 named    # roles/foo/.md
empty-segment-reader: rc=1 named          # roles//foo.md
inner-empty-segment-reader: rc=1 named    # roles/foo//bar.md
```

Нетипичные байты не дали обхода другой директории: полный Unicode-slash остаётся одним именем файла (зелёный контроль), а LF в `role=` разрывает строку поля и именованно отвергается. `grep -Fxq` сохраняет побайтовую семантику нормы: `Role  norm.` и `Role<NBSP>norm.` не совпадают с `Role norm.`, а один и тот же NBSP-байт в поле и файле зелёный.

БЙ2 остаётся закрыт: в toy с живым `frozen/contracts/001/1`, изменённым зарегистрированным writer и отсутствующей `ПОТРЕБИТЕЛЬ`-пробой обычный запуск и запуск с `fakebin/tail` (`exit 127`) перед `/usr/bin:/bin` оба дают один предметный именованный отказ:

```text
b2-normal-missing-probe: rc=1 named
b2-fake-tail-ignored: rc=1 named
```

`check_consumers.sh` фиксирует доверенный PATH до вызова `tail`; отсутствие внешней утилиты не маскируется зелёной пустотой.

**Счёт найденных обходов: 2.**
