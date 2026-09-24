# 045 v1 — первый adversary-круг реализации

**Вердикт: FAIL.** Реализация `scripts/gitw` из `9c372335b2755540b15e569f47120472646a8335` пропускает фактический `push`, `fetch` и `pull` в неканоническую цель, когда цель — имя remote, и пропускает SCP-форму прямой цели. Это живой обход И-4/И-5 и модели угроз «в ЛЮБОЙ форме вызова». Фикстура г0–г12 зелёная, но этих форм не содержит.

## Блокер: именованный не-`origin` remote

После `push`/`fetch`/`pull` парсер считает целью лишь строку с `://` либо начинающуюся с `/`, `./`, `../`. Имя remote `evil` не подходит, поэтому гард читает и проверяет канонический `remote.origin.*`, успешно делает `ls-remote` канона, затем `exec` передаёт настоящему git исходный argv. Настоящий git трактует `evil` как remote и идёт в его URL.

В одноразовом toy (базы через `mktemp -d /tmp/gitw045-…`, то есть вне `/tmp/dev-harness-verify`) настроены каноническая bare `C` как `origin` и неканоническая bare `E` как дополнительный `evil`. При `GIT_EXCHANGE_GUARD_CANONICAL=C` команда `bash /tmp/dev-harness-verify/adversary-045-bypass.sh` вернула rc 0:

```text
BYPASS named-remote push rc=0 actual=/tmp/gitw045-bypass.1mUMOc/noncanonical.git
BYPASS named-remote fetch rc=0 actual=/tmp/gitw045-bypass.1mUMOc/noncanonical.git
BYPASS named-remote pull rc=0 actual=/tmp/gitw045-bypass.1mUMOc/noncanonical.git
```

Сценарий проверяет SHA фактической стороны: `push evil HEAD:refs/heads/named-push` создал ref в `E`; `fetch evil main` записал SHA `E/main` в `FETCH_HEAD`; `pull evil main` fast-forward-нул HEAD до SHA из `E`. Значит это не ложный rc: реальный обмен с неканонической целью произошёл.

Нужна красная клетка для всех трёх обменов при каноническом origin и `evil=<чужая bare>` (F1 и отсутствие изменения `E`/FETCH_HEAD/HEAD), а реализация должна разрешать фактический positional repository argument по git-семантике, включая remote name, а не подставлять `origin` для любого не-URL аргумента.

## Тот же дефект: SCP

`git@example.test:any/path` не имеет `://` и не начинается с пути, поэтому проходит ту же неверную ветвь. Локальный `GIT_SSH_COMMAND` в toy обслуживал настоящий `git-receive-pack` неканонической `E`; сеть не требовалась:

```text
To example.test:any/path
 * [new branch]      HEAD -> scp-push
BYPASS scp-target push rc=0 actual=/tmp/gitw045-bypass.1mUMOc/noncanonical.git
```

SHA `E/refs/heads/scp-push` совпал с HEAD отправителя. Нужна SCP-клетка и общий разбор repository argument; текущая г5 покрывает только абсолютный путь.

## Контроли и обязательные пробы

Позитивный контроль в отдельном toy прошёл реальный канонический push/fetch/pull с проверкой SHA:

```text
PASS positive canonical push/fetch/pull
```

Немодифицированная батарея также полностью зелёная:

```text
$ bash fixtures/gitw/red_gitw_obmen.sh /home/aka/Documents/dev-harness
ok: стаб-pushonly … ok: стаб-pushurlskip
ok: г0 … ok: г12
gitw: батарея зелёная (клетки г0-г12 + 11 стабов на своих клетках)
[rc=0]
```

`bash /tmp/dev-harness-verify/adversary-045-negatives.sh` отверг F1 ровно `--git-dir=<x>`, относительный `-C`, `GIT_DIR`/`GIT_WORK_TREE`, повторные `-c`, шаблонный `insteadOf` и multiple pushurl; пустой PATH дал rc2 NOT_IMPLEMENTED, не успех.

Проверены также mandated fake-PATH/127 сценарии. Fake `git` до системного в PATH может выдать канонические ответы либо rc127 на все четыре config/get-url query, а затем выполнить raw git; оба дали rc0 и обмен с `E`:

```text
BYPASS fake-PATH git rc=0 actual=/tmp/gitw045-pathfake.YrUVk8/noncanonical.git
BYPASS query-127 fake-PATH git rc=0 actual=/tmp/gitw045-query127.A42mjg/noncanonical.git
```

Это не дополнительный блокер: §Модель угроз прямо исключает подмену PATH до обёртки как злонамеренный TCB. Но проба подтверждает, что `|| true` преобразует отказ query в пустой origin. Главный обход не зависит от PATH, 127, пустого входа, константы или окружения: это настоящий `/usr/bin/git`, два обычных remote, непустые refs и SHA-проверки.
