ФОРК: n13x-plan-id
ВОПРОС: `freeze_contract.sh contracts/131-poezd-bez-dogonyalok.md` отказывает: «контракт вне плана: 131 — не в текущей/следующей паре registry/plan.tsv (P0 3, P1 4)» (freeze_contract.sh:248). Причина: строки плана 130/131 заведены по СЛАГАМ (`registry/plan.tsv:55-56`: `teg-posle-teksta	4	до V-2	-	…publikaciya-main.md#Порядок	autonomy` и `poezd-bez-dogonyalok	4	…`), а все остальные строки пары 4 — по НОМЕРУ (`127`, `120`, `122`, `128`, `129`, `123`, `124`). Заморозка ищет контракт по номеру NNN (130, 131). Нужен owner-коммит консультанта (строки plan.tsv — мандат консультанта): заменить id `teg-posle-teksta` → `130`, `poezd-bez-dogonyalok` → `131` (остальные поля без изменений), push через поезд/учётный. Готовый вид строк: `130	4	до V-2	-	docs/owner/2026-10-21-publikaciya-main.md#Порядок	autonomy` и `131	4	до V-2	-	docs/owner/2026-10-21-publikaciya-main.md#Порядок	autonomy`. До этого freeze 131 стоит (Architect131d сдал `eea9b08cf`, 24 клетки/22 стаба, арбитр закрыт; нового круга критика нет — freeze по вердикту арбитра); 130 — после Architect130d тот же отказ. Критическая цепочка владельца «130+131 done к утру» ждёт этой строки.
КЛАСС: инженерный
ПРИЗНАК: приоритет
МАРШРУТ: консультант
ЗАВЕДЁН: 2026-10-21T22:45:00Z
БЛОКИРУЕТ: да
ОТВЕЧЕНО: да
ЗАКРЫТИЕ: owner-коммит ab51f9965 (cherry-pick 65d8c00ca, main): строки плана teg-posle-teksta → 130, poezd-bez-dogonyalok → 131; check_plan rc 0; консультант 23:16 UTC 2026-10-21
