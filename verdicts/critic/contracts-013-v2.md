FAIL

БЛОКИРУЕТ contracts/013-processnye-artefakty-i-schet-krugov.md:111 — строка `СПАСЕНО` грамматически законна и действительно выводит `bc12da47` из суда, но не делает обязательный пробный прогон зелёным: коммит самой правки v2 `22acea9f` имеет автора `orchestrator` и меняет контракт, тогда как `ЗОНА orchestrator` на строке 109 разрешает только `NABLIUDENIA.md HANDOFF.md`. В клоне с пробным тегом `frozen/contracts/013/2` на `22acea9fb91c2f7bf7b0d5888bb3947fc4fa7e3d` команда `bash scripts/check_zones.sh .` завершилась с rc=1 и точным отказом `FAIL коммит вне зоны: orchestrator 22acea9f contracts/013-processnye-artefakty-i-schet-krugov.md — зона контракта 013: HANDOFF.md NABLIUDENIA.md`. Это противоречит норме сборки `AGENTS.md:151-153`: до вызова судьи пачка обязана быть зелёной всеми своими командами приёмки. Для прямого противоречия `AGENTS.md` ОБХОД не требуется.

## Узкая сверка v2

- Предмет закоммичен: HEAD перед судом — `22acea9fb91c2f7bf7b0d5888bb3947fc4fa7e3d`; максимальная существующая заморозка 013 — `frozen/contracts/013/1`, поэтому имя этого вердикта — `contracts-013-v2.md`.
- Побайтовый `git diff frozen/contracts/013/1 -- contracts/013-processnye-artefakty-i-schet-krugov.md` дал: `1 file changed, 4 insertions(+), 0 deletions(-)`. Все четыре добавленные diff-строки находятся после `ЗОНА implementer`: одна строка `СПАСЕНО`, одна пустая строка-разделитель и две строки примечания v2. Других расхождений нет; предмет, критерий готовности и прежние `ЗОНА`-строки побайтово совпадают с frozen-блобом v1.
- Законность изменения: коммит `22acea9f` содержит `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/013-processnye-artefakty-i-schet-krugov.md ...`; `bash scripts/check_charter.sh` → rc=0 и печатает для этого пути `изменений без разрешения нет`.

## Грамматика СПАСЕНО и хеш

Парсер `scripts/check_zones.sh:190-240` требует объявленного ЗОНА-автора, непустую причину, полный 40-символьный lowercase hex, существующий commit и принадлежность диапазону.

- `architect` объявлен строкой `ЗОНА architect` в этом контракте на строке 105.
- `git rev-parse bc12da4` → `bc12da471b5180bc2d8de299720ef38b2fa305fb`; это ровно один полный 40-символьный хеш в строке 111.
- Причина непуста и называет суть исключения: разовый carve-out за вклинивание пачки 014 в открытый диапазон 013 ради разблокировки CI, Н-63-1 и решение владельца/слово на v+1.
- Парсер подтвердил действие строкой: `ok   контракт 013: коммит bc12da47 (architect) — СПАСЕНО, из суда зон выведен`.

## Пробная заморозка

В чистом локальном клоне исходного HEAD выполнено:

```text
$ git rev-parse HEAD
22acea9fb91c2f7bf7b0d5888bb3947fc4fa7e3d
$ git tag frozen/contracts/013/2 22acea9fb91c2f7bf7b0d5888bb3947fc4fa7e3d
$ bash scripts/check_zones.sh .
  ok   контракт 013: коммит bc12da47 (architect) — СПАСЕНО, из суда зон выведен
  FAIL коммит вне зоны: orchestrator 22acea9f contracts/013-processnye-artefakty-i-schet-krugov.md — зона контракта 013: HANDOFF.md NABLIUDENIA.md
rc=1
```

Требуемое доказательство `rc=0` не получено; заморозка v2 по этому тексту запрещена.
