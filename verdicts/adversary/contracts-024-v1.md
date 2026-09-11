FAIL

# Адверсарий: контракт 024, круг 2

Судимая база: `main` `01ed097b8155b604ccbe838d0d4b0807667c71c1`,
`frozen/contracts/024/2 = HEAD`. Все мутации и репро ниже сделаны только в
одноразовых клонах под `/tmp`; основной checkout менялся только этим вердиктом.
Н-39 дословно: «стабы к ветвям привязывает architect по коду, НЕ проза контракта; контракт несёт инварианты + rc-команды».

## Блокер 1 — подмена доступной `sha256sum` на PATH делает живую утечку «чистой»

**Контрпример `S-path-forged-sha256`.** Это конформный живой git-checkout с уже
существующим untracked-файлом `S-path-forged-sha`: он пуст перед снимком и после
снимка становится однобайтным. В `PATH` перед `/usr/bin` поставлена исполнимая
`sha256sum`, возвращающая грамматически корректный постоянный 64-hex отпечаток
для stdin и любого аргумента. Остальные восемь требуемых программ настоящие.

```text
PATH=/tmp/dev-harness-adv2/fake-bin:/usr/bin:/bin \
TMPDIR=/tmp/adv024-path-forged \
  bash scripts/check_no_leak.sh --snapshot /tmp/dev-harness-adv2/repo  # rc=0
truncate -s 1 S-path-forged-sha
PATH=/tmp/dev-harness-adv2/fake-bin:/usr/bin:/bin \
TMPDIR=/tmp/adv024-path-forged \
  bash scripts/check_no_leak.sh --check /tmp/dev-harness-adv2/repo     # rc=0
# stdout: основной чекаут чист
```

Детектор проверяет лишь `command -v sha256sum`: доступная подмена проходит
предпроверку. Оба манифеста содержат одинаковый постоянный fingerprint при том,
что байты tracked входа изменились после снимка; утечка не названа. Это именно
класс «инструмент мимо PATH», не прежний закрытый класс отсутствующей утилиты
(rc 127). Оракул из 18 ворот зелёный в штатном PATH, но не испытывает эту
реальную форму среды; следовательно, его зелёность не защищает И-5 в обещанном
`PATH`-уважающем CLI.

**Положительный контроль.** Та же последовательность с настоящим PATH на
`S-positive-control` дала `rc=1` и `ОТКАЗ: основной чекаут загрязнён:
S-positive-control`; следовательно, контрпример не является вечно-красным либо
перепутанным вопросом.

## Блокер 2 — symlink-подмена внешнего манифеста позволяет выдать новую запись за базу

**Контрпример `S-external-snapshot-symlink`.** В отдельном репозитории с одним
закоммиченным `seed` снимок A сделан при размере `seed=1`. После `truncate -s 2
seed` снимок B сделан в другом `TMPDIR`. Затем, только вне стерегомого дерева,
`porcelain` снимка A заменён ссылкой на `porcelain` снимка B. В обоих файлах
первая строка корректна и одинаково содержит `root /tmp/adv024-symlink-tree`.

```text
TMPDIR=/tmp/adv024-symlink-a \
  bash scripts/check_no_leak.sh --snapshot /tmp/adv024-symlink-tree  # rc=0
truncate -s 2 /tmp/adv024-symlink-tree/seed
TMPDIR=/tmp/adv024-symlink-b \
  bash scripts/check_no_leak.sh --snapshot /tmp/adv024-symlink-tree  # rc=0
mv /tmp/adv024-symlink-a/dev-harness-leak/26476c9b/porcelain \
   /tmp/adv024-symlink-a/dev-harness-leak/26476c9b/porcelain-base
ln -s /tmp/adv024-symlink-b/dev-harness-leak/26476c9b/porcelain \
   /tmp/adv024-symlink-a/dev-harness-leak/26476c9b/porcelain
TMPDIR=/tmp/adv024-symlink-a \
  bash scripts/check_no_leak.sh --check /tmp/adv024-symlink-tree     # rc=0
# stdout: основной чекаут чист
```

`--check` следует ссылке и доверяет подменённой базе: root-строка ловит только
чужой корень, не подмену снимка того же корня. Тем самым модификация `seed` между
исходным снимком и сверкой не наблюдается. Путь манифеста намеренно находится
вне дерева и `TMPDIR` объявлен частью API, поэтому это не ignored-путь и не
названный предел «сговор/спавн-без-вердикта»; это live bypass хранения манифеста.

## Исполненные отрицательные и положительные контроли

- `S-status-refusal`: `git status` через PATH вернул `rc=1`; `--snapshot` дал
  именованный `NOT_IMPLEMENTED: манифест не прочитан: git status rc=1 ...`,
  `rc=2`. Закрытие к1 работает.
- `S-no-sha256sum`: PATH содержал все остальные обязательные программы, но не
  `sha256sum`; `--snapshot` дал `NOT_IMPLEMENTED: утилита sha256sum отсутствует`,
  `rc=2`. Закрытие rc=127-класса работает.
- `S-empty-tree`: пустой инициализированный git-репозиторий прошёл
  `--snapshot` затем `--check` с `rc=0` и «основной чекаут чист». Пустой вход сам
  по себе не объявлен утечкой и не является находкой.
- Снимок в один момент и запись после него на настоящем PATH проверены
  `S-positive-control` выше: ровно соответствующая утечка краснеет, а не все
  сценарии.
- `bash fixtures/check_judge_gate/probe_slabyh_detektora.sh` → `rc=0`: честная
  форма прошла все 18 ворот, каждая из 17 слабых форм умерла именованно, и
  безымянный `exit 1` отвергнут. Это не покрывает два живых обхода выше.
- `bash fixtures/check_judge_gate/red_stenogrammy_sudej_024.sh` на судимой базе
  → `rc=0`, честная вакуумная зелёность: норма-строка ещё не приземлена.
  В отдельном клоне после коммита нормы `S-anchor-missing` без строки
  `check_no_leak --check ... rc` дал именованный `rc=1`; обновление файла с
  корректной стенограммой дало `rc=0`; переименование и удаление стенограммы
  (`S-anchor-renamed`) снова дали `rc=1`. Удаление и повторное внесение нормы не
  сдвинуло pickaxe-границу (осталась `90632d1...`), а norm-коммит, пришедший
  cherry-pick, дал границу `8ff106d...` и поймал `S-cherry-missing` с `rc=1`.
  A+M-множество и самая ранняя граница работают в испытанных формах.
- Ignored-путь не заявляется находкой: он прямо исключён Демаркацией 024.
  «Сговор/спавн-без-вердикта» также не объявляется новым FAIL: это прямо
  названный cognitive-only предел контракта.

## Приёмочные наблюдения

```text
bash scripts/verify_antiplacebo.sh . --scope check_judge_gate  # rc=0
 git diff --exit-code frozen/contracts/024/2..HEAD -- \
   fixtures/check_judge_gate/ scripts/check_no_leak.sh         # rc=0, пусто
```

На основном checkout исполнена заданная интерим-норма:

```text
стенограмма: check_no_leak --check → rc=0
```

## Требуемая правка

1. Сделать происхождение и исполнимость программ, формирующих адрес снимка и
   fingerprint, доверенной/неподменяемой частью детектора (одного наличия в PATH
   недостаточно), и добавить живой red-контрпример `S-path-forged-sha256`.
2. Сделать снимок защищённым от replacement/symlink-подмены между `--snapshot` и
   `--check` либо fail-closed при небезопасном типе/целостности внешнего пути; root
   одной строкой не является доказательством свежести или целостности. Добавить
   живой red-контрпример `S-external-snapshot-symlink`.
3. После правки повторить оба контрпримера, положительный контроль, probe,
   scoped `check_judge_gate` и frozen-diff. Полный прогон остаётся задачей CI
   (Н-48), не этого судьи.
