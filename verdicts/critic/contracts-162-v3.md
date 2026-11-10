accept
OBJECT=33593bc38ddbc1cf389d53f18e7825bca3e2288b
СУД: repo=dev-harness; предмет=162; фаза=контракт (v3, v+1 замороженного 162/2: пин STRUCTURE.md и буква критерия 3); роль=critic; вызов=1/2; модель-план=zai/glm-5.3; сессия=Crit162v3; модель-факт=zai/glm-5.3; SHA=33593bc38ddbc1cf389d53f18e7825bca3e2288b; предыдущий=verdicts/review/contracts-162-impl-v2.md; исключение=нет

# Вердикт критика — контракт 162 v3 «Стандарт кода мобильного приложения»

## Кандидат, учёт и независимость

В одноразовом SSH-клоне выполнены `git fetch origin wip/162/architect`, затем `git switch --detach 33593bc38ddbc1cf389d53f18e7825bca3e2288b`. `FETCH_HEAD`, запрошенный OBJECT и `HEAD` совпали с `33593bc38ddbc1cf389d53f18e7825bca3e2288b`.

После `git fetch origin main` строка до вызова найдена в `origin/main:HANDOFF.md:8`:

```text
СУД: repo=dev-harness; предмет=162; фаза=контракт (v3, v+1 замороженного 162/2: пин STRUCTURE.md и буква критерия 3; строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ «б да» ~20:44 в изменяющем коммите); роль=critic; вызов=1/2; модель-план=zai/glm-5.3; сессия=ожидается; SHA=33593bc38ddbc1cf389d53f18e7825bca3e2288b; предыдущий=verdicts/review/contracts-162-impl-v2.md; исключение=нет
```

Объектный коммит принадлежит `architect <architect@dev-harness.local>`, судья — отдельная сессия `Crit162v3`. Выданный mandatory trace содержит `critic\tzai/glm-5.3\tallowed`; назначение `roles.critic → apex-sol → @glm` подтверждено живой проверкой:

```text
$ bash scripts/check_sud_model.sh --spawn critic zai/glm-5.3 --root .
СУДЬЯ СВОЕЙ МОДЕЛИ: critic тир apex-sol модель zai/glm-5.3
[rc=0]
```

`git log -1 --format=%B` предъявил требуемую авторизацию:

```text
РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/162-standart-koda-mob.md — v3: пин STRUCTURE.md обновлён на актуальный хэш после 143 (механическая правка, семантика не ослабляется); слово владельца 2026-11-10 ~20:44 UTC «б да» через консультанта
```

`bash scripts/check_charter.sh .` завершился rc 0; релевантная сырая строка: `ok   уставной документ изменён с разрешения владельца: contracts/162-standart-koda-mob.md в 33593bc3`.

## Полнота, границы и класс риска

Неполного набора нет: закоммиченный предмет расположен в `contracts/162-standart-koda-mob.md:29-31`, проверяемые rc-критерии — в `:62-87`, а раздача — в `:102-106`. Дельта кандидата содержит только этот контракт и два новых проверочных файла; все три пути лежат в `ЗОНА architect` на `:102`. Полный `check_zones.sh` по прямому ограничению задания не запускался.

`КЛАСС РИСКА: обычный` на `:3` адекватен предмету: он фиксирует документ и трассировку существующих правил, без изменения прав/ролей БД, авторизации, безопасности, денег, ПД/health, согласий или юридически значимых операций. Оснований для adversary нет. Модель угроз на `:89-96` имеет обе границы и не выдаёт проверку пинов за доказательство семантики произвольных правил.

## Ф-1 и пины источников

Пин `STRUCTURE.md` на `contracts/162-standart-koda-mob.md:9` соответствует именно слитому кандидату PR #158. В read-only product clone `HEAD=a1b3d41a8d6fa6f79779eef6732c191d874529ba` выполнено:

```text
$ sha256sum docs/CODING-STANDARDS.md STRUCTURE.md AGENTS.md docs/context/CONTEXT-POLICY.md
b32fb106a50d7803521a9e8811d17a3f6034ed31ede09622c5f1976e5464a436  docs/CODING-STANDARDS.md
b91af22dfd3ebbd231c962028cc26bc0c2a39a6dd10f9fcbfec153e7c1b71e11  STRUCTURE.md
e76d217b361b0f3e1c50a56c8699f34d242a9abcd7673871a0fdd1c3bda99f9a  AGENTS.md
ac1e9dbe13f904384825e77754b3e397704c5145c200874fe91485251b433e4c  docs/context/CONTEXT-POLICY.md
[rc=0]
```

`sed -n '167,179p' STRUCTURE.md` предъявил §5 от заголовка `## 5. API, авторизация и удаление mock` до его границы; диапазон и hash совпадают с новой строкой контракта. Тем самым Ф-1 закрыт без изменения смысла цитируемого фрагмента: слияние 143 сдвинуло его на три строки.

## Ф-2: семантика критерия изолированной дельты не ослаблена

Старое буквальное условие v2 требовало `git diff --numstat 932ee4a..HEAD` равным `1<TAB>0`, хотя добавление элемента в однострочный JSON-массив физически даёт `1<TAB>1`; включение 143 в `HEAD` также делало общий диапазон не 162-дельтой. Новый критерий на `:66` не снимает исходное обязательство «ровно одно разрешение таблицы и без иных изменений», а разделяет два проверяемых отношения:

1. `932ee4a..54fd5c83` меняет только `mobile/structure-policy.json`, ровно на `1<TAB>1`;
2. `50699aeea..a1b3d41a8` сохраняет всю политику 143 и добавляет только последний элемент `scripts/coding-standards-claims.tsv` в `mobileFiles`.

Граф также не подменён: на product clone `932ee4a` является предком `54fd5c83`, а оба `54fd5c83` и `50699aeea` — предками merge `a1b3d41a8` (три `git merge-base --is-ancestor` вернули rc 0). Сырая сверка диапазонов:

```text
$ git diff --name-only 932ee4a..54fd5c83
mobile/structure-policy.json
$ git diff --numstat 932ee4a..54fd5c83 -- mobile/structure-policy.json
1	1	mobile/structure-policy.json
$ git diff --numstat 50699aeea..a1b3d41a8 -- mobile/structure-policy.json
1	1	mobile/structure-policy.json
[rc=0]
```

Основная команда нового критерия прошла на фактическом смешанном HEAD с правками 143:

```text
$ python3 fixtures/workshop_project/standart_koda_162/check_policy_delta.py --repo /tmp/dev-harness-verify/Impl162m/mob --base 932ee4a54352a8731fbb6570da30faae7406c10a --feature 54fd5c83c7b4e9e5ad5fc6dd1e162c9766bbfea4 --main 50699aeea16675980cb92175248c03ac1fbc62ab --head a1b3d41a8d6fa6f79779eef6732c191d874529ba
162: policy delta OK
[rc=0]
```

Это механическая коррекция измерителя, а не изменение разрешённого риска: он стал отличать 162-изменение от уже принятого 143 и одновременно проверяет сохранение 143-политики. Вопрос владельцу не возникает: авторизованная правка сохраняет исходный инвариант и усиливает его точной JSON-проверкой.

## Красные пары и собственные мутации

`red_policy_delta.sh` связывает три обманных JSON-входа с `check_policy_delta.py --pair` кодом, а не прозой контракта; контракт на `:66` содержит инвариант и rc-команды, но не пары «стаб ↔ ветвь». В этой малой документной проверке нет отдельного интерфейса `--stabs` и нет заявленных стабов.

Полная обёртка архитектора выполнена живьём:

```text
$ bash fixtures/workshop_project/standart_koda_162/red_policy_delta.sh
[stdout/stderr пусты; rc=0]
```

Она проверяет честную пару и три обманных входа: второй элемент политики, удаление прежнего элемента и изменение другого ключа. Мои независимые входы использовали предусмотренный `--pair` и дали следующие сырые результаты:

```text
# Пустая 162-дельта на реальных product commits до реализации
$ python3 fixtures/workshop_project/standart_koda_162/check_policy_delta.py --repo /tmp/dev-harness-verify/Impl162m/mob --base 932ee4a54352a8731fbb6570da30faae7406c10a --feature 932ee4a54352a8731fbb6570da30faae7406c10a --main 50699aeea16675980cb92175248c03ac1fbc62ab --head 50699aeea16675980cb92175248c03ac1fbc62ab
ОТКАЗ 162: diff содержит второй файл или не содержит политику
[rc=1]

# Вторая строка policy / скрытое дополнительное разрешение
$ printf '%s\n%s\n' '{"mobileFiles":["keep","second"],"externalTrees":["api"]}' '{"mobileFiles":["keep","second","scripts/coding-standards-claims.tsv","undisclosed.tsv"],"externalTrees":["api"]}' | python3 fixtures/workshop_project/standart_koda_162/check_policy_delta.py --pair
ОТКАЗ 162: policy не одна разрешающая строка
[rc=1]

# Пустая JSON-пара
$ printf '%s\n%s\n' '{"mobileFiles":["keep","second"],"externalTrees":["api"]}' '{"mobileFiles":["keep","second"],"externalTrees":["api"]}' | python3 fixtures/workshop_project/standart_koda_162/check_policy_delta.py --pair
ОТКАЗ 162: policy не одна разрешающая строка
[rc=1]

# Удалён предшественник mobileFiles
$ printf '%s\n%s\n' '{"mobileFiles":["keep","second"],"externalTrees":["api"]}' '{"mobileFiles":["keep","scripts/coding-standards-claims.tsv"],"externalTrees":["api"]}' | python3 fixtures/workshop_project/standart_koda_162/check_policy_delta.py --pair
ОТКАЗ 162: policy не одна разрешающая строка
[rc=1]

# Изменён посторонний ключ policy
$ printf '%s\n%s\n' '{"mobileFiles":["keep","second"],"externalTrees":["api"]}' '{"mobileFiles":["keep","second","scripts/coding-standards-claims.tsv"],"externalTrees":["api","extra"]}' | python3 fixtures/workshop_project/standart_koda_162/check_policy_delta.py --pair
ОТКАЗ 162: policy не одна разрешающая строка
[rc=1]
```

После этих проверок product clone остался чистым (`git status --short` и `git diff --check` дали пустой вывод, rc 0). В продукте также исполнен существующий verifier: `bash mobile/scripts/verify-coding-standards.sh` вернул rc 0 и финальный сырой итог `утверждений объявлено: 123; зелёных: 123; красных: 0` / `РЕЗУЛЬТАТ: OK (123 из 123 объявленных утверждений)`.

Прямой запуск `node mobile/scripts/check-structure.cjs` на не преобразованном read-only checkout ожидаемо вернул rc 1 на временных e2e-пачках и `kompozicija.stand-in.sh`; это не состояние критерия. Его явно заданная предпосылка на `:65` — disposable раскладка job `quality` после выноса. Наблюдаемый workflow выполняет этот вынос в `.github/workflows/mobile.yml:414-436` перед `npm run lint` (`:419` вызывает inventory, `:436` переносит stand-in). Клон не менялся для имитации CI-раскладки.

## Закрытие остальных блоков reviewer

- Ф-3 закрыт текстом `:100`: reviewer принимает CI-раскладку на уже названном merge SHA и `merge #158` разрешён только после зелёного обязательного CI. Новый критерий не заменяет CI зеленью локальной проверки.
- Ф-4 остаётся честным условием done, а не молчаливым пропуском: `:87` назначает после merge конкретную rc-команду для четырёх ролей, frozen project contract и trace, прямо называет оркестратора ответственным и помечает пункт до merge `NOT_RUN`; `:100` сохраняет этот порядок.

## Обязательные ворота

```text
$ bash scripts/pre_critic.sh --repo . contracts/162-standart-koda-mob.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=0
КРИТИК: дверь зелёная
[rc=0]

$ bash scripts/check_precision_gate.sh . contracts/162-standart-koda-mob.md
OK
[rc=0]

$ bash scripts/check_ceilings.sh .
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 169 черновик(ов) судится, замороженные — по тегам
потолки в порядке
[rc=0]

$ bash scripts/check_provodka.sh . contracts/162-standart-koda-mob.md
[stdout/stderr пусты; rc=0]

$ bash scripts/check_threat_model.sh . contracts/162-standart-koda-mob.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 2 буллет(ов), НЕ ЗАЩИЩАЕТ 2 буллет(ов))
[rc=0]

$ bash scripts/check_document.sh --root . --contract contracts/162-standart-koda-mob.md --preflight
[stdout/stderr пусты; rc=0]

$ bash scripts/check_spec_ready.sh . contracts/162-standart-koda-mob.md
OK
[rc=0]
```

Счётных или механических расхождений в проверенной v3-дельте (пин, пять source SHA, четыре commit SHA, оба numstat и JSON-свойство) не найдено. Блокирующих находок нет; `accept` относится только к OBJECT в шапке.