FAIL

Объект: 9ff0cf74db64139641a363293f54451a9b66dc7d.

Найден конформный вход, на котором в цель публикуется тег frozen/contracts/130/1 с текстом, отличающимся от текста в main цели.

Состояние входа:
- bare-цель содержит main с `contracts/130-t.md` = `good text` и `verdicts/critic/contracts-130-v1.md` с первой строкой `accept`;
- репозиторий A является текущим каталогом и имеет локальный тег `frozen/contracts/130/1` на коммите с `good text`;
- репозиторий B имеет тот же remote, но одноимённый локальный тег на коммите с `bad text`;
- запуск из A: `GIT_EXCHANGE_GUARD_CANONICAL=<bare> bash <candidate>/scripts/gitw -C <B> push origin refs/tags/frozen/contracts/130/1`.

Наблюдение независимого сценария: rc=0, `remote_tag=yes`, `blob_equal_main=no`. Цель получила тег B, хотя его blob `contracts/130-t.md` не равен blob main цели. Нейтрализация различает именно этот разрыв: тот же запуск из B дал rc=1, именованный отказ «текст не в main цели» и `remote_tag=no`.

Причина: `sostav()` выполняет пробный push с `PRE`, поэтому состав читается из B. После этого `judge_tag()` вызывает обычный `git rev-parse`, `git ls-tree` и `git cat-file` без глобального контекста `-C <B>`; эти команды читают A. Суд сопоставляет одноимённую годную локальную ссылку A вместо отправляемой ссылки B. Это противоречит И-2 (состав того же обмена) и И-4 (суд коммита источника).

Приёмочная команда при этом зелёная на кандидате:
- `--candidate /tmp/dev-harness-verify/adv130 --seed 1` — rc 0, 48/48;
- `--candidate /tmp/dev-harness-verify/adv130 --seed 7` — rc 0, 48/48;
- `--candidate /tmp/dev-harness-verify/adv130 --seed 42` — rc 0, 48/48;
- `--candidate /tmp/dev-harness-verify/adv130 --seed 99999` — rc 0, 48/48.

Позитивный контроль на базовом снимке 371e0e388007ef2b136bfde82efda4fbf37855cc: `--model --seed 7`, `--model --seed 99999`, `--stabs --seed 7` и `--stabs --seed 42` дали rc 0 (48/48 и 29/29). На дереве самого кандидата режимы `--model` и `--stabs` дают rc 2: якорь раннего exec уже заменён добавленным крюком, поэтому модель поверх этого дерева не накладывается.

Дополнительно: неизвестная клетка дала rc 2; frozen-пути `contracts/130-*.md`, `fixtures/workshop_project/teg_posle_teksta_130/**`, `scripts/gitw_preflight_071.sh` не отличаются между `frozen/contracts/130/1^{commit}` и HEAD; соседняя батарея 045 дала rc 0. `pre_critic` и `check_threat_model` дали rc 0. Запуск `fixtures/gitw_predpolet/red_predpolet_071.sh` не завершился за 300 с (частичный вывод дошёл до s19), поэтому зелёный итог для него не заявляется.
