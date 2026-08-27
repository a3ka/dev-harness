accept

РЕШЕНИЕ арбитража `verdicts/arbitration/kontrakt-013-razryv-vzaimnyh-okon.md` исполнено на закоммиченном `HEAD = cf0039695582833a86018b33a411e4435bec4421`: H1 = `a5d39f65c860784dfd1bc3c593702ec1bd78e069`, Y1 = `f88fb5f4b3b06b088a2e86eaf31afcffe36bc0ac`. Блокирующих находок нет.

## Единственность изменения против блоба v2

Команда

```text
git diff --no-ext-diff --unified=5 frozen/contracts/013/2 HEAD -- contracts/013-processnye-artefakty-i-schet-krugov.md
```

завершилась с **rc=0** и дала ровно `1 file changed, 3 insertions(+), 4 deletions(-)`. В единственном hunk прежняя одна строка `СПАСЕНО architect` заменена двумя строками `СПАСЕНО` по авторам, а двухстрочное примечание v2 заменено однострочным примечанием v3. Иных изменений предмета, критерия или зон нет.

## Грамматика двух строк

В `contracts/013-processnye-artefakty-i-schet-krugov.md:104-112` авторы `architect` и `implementer` объявлены собственными `ЗОНА`-строками. Строка `СПАСЕНО architect` содержит 6 полных lowercase 40-символьных хешей, строка `СПАСЕНО implementer` — 1; после `—` у обеих непустая причина. Команда

```text
git rev-parse bc12da4 0f19263 c081809 376025f 743d35b f88fb5f c91a6c8
```

завершилась с **rc=0** и вернула, в том же порядке:

```text
bc12da471b5180bc2d8de299720ef38b2fa305fb
0f192635126c9054ba1cdafc79c4dd296f5f7923
c0818095ef62b582bd8301b5c1b12fbfca3260ed
376025fcbd5ced9b697d57a7ee4a6d94c6431e12
743d35b24762939530979188415e3af15e9c0e28
f88fb5f4b3b06b088a2e86eaf31afcffe36bc0ac
c91a6c843b959aef70c6c82363a7de098c7a365c
```

`git show -s --format='%H %an'` завершилась с **rc=0**: первые 6 коммитов принадлежат `architect`, последний — `implementer`. Это соответствует грамматике парсера `scripts/check_zones.sh:190-250` и объявленным авторам контракта 013.

## Парная проба заморозок

В собственном чистом клоне `/tmp/critic013v3fix-cf00396-20260827` выполнено:

```text
git tag -f frozen/contracts/013/3 a5d39f6
git tag -f frozen/contracts/014/2 f88fb5f
bash scripts/check_zones.sh .
```

Итог парного прогона — **rc=0**. Все семь исключений контракта 013 прочитаны и применены:

```text
ok   контракт 013: коммит bc12da47 (architect) — СПАСЕНО, из суда зон выведен
ok   контракт 013: коммит 0f192635 (architect) — СПАСЕНО, из суда зон выведен
ok   контракт 013: коммит c0818095 (architect) — СПАСЕНО, из суда зон выведен
ok   контракт 013: коммит 376025fc (architect) — СПАСЕНО, из суда зон выведен
ok   контракт 013: коммит 743d35b2 (architect) — СПАСЕНО, из суда зон выведен
ok   контракт 013: коммит c91a6c84 (implementer) — СПАСЕНО, из суда зон выведен
ok   контракт 013: коммит f88fb5f4 (architect) — СПАСЕНО, из суда зон выведен
```

Обратное покрытие двух правок 013 принято именно точным именем зоны 014-v2. Прогон напечатал:

```text
ok   contracts/014-default-skratch-vne-dereva-pri-tmpdir.md — зона: architect → contracts/013-processnye-artefakty-i-schet-krugov.md  014
```

Проверка изменённых путей дала:

```text
a84a93c7cdb873ea08dc6e33923c2ddaaf88c1c5 architect
contracts/013-processnye-artefakty-i-schet-krugov.md
a5d39f65c860784dfd1bc3c593702ec1bd78e069 architect
contracts/013-processnye-artefakty-i-schet-krugov.md
```

Следовательно, оба коммита `a84a93c7` и `a5d39f65` покрыты точным путём зоны `architect` замороженного 014-v2; диагностик `FAIL` нет. Сводка парного прогона:

```text
замороженных контрактов: 13 · объявленных авторов: 6 · коммитов в диапазонах: 292 · проверено по зонам: 203
```

После пробы собственный клон удалён.

## Charter

В том же чистом клоне команда

```text
bash scripts/check_charter.sh .
```

завершилась с **rc=0**. Для H1 и Y1 напечатано:

```text
ok   уставной документ изменён с разрешения владельца: contracts/013-processnye-artefakty-i-schet-krugov.md в a5d39f65
ok   уставной документ изменён с разрешения владельца: contracts/014-default-skratch-vne-dereva-pri-tmpdir.md в f88fb5f4
```

Сводка: `уставных документов: 16 · изменений в них: 43 · с разрешения: 43`.
