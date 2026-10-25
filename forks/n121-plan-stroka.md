ФОРК: n121-plan-stroka
ВОПРОС: 121 (CMP-BCK-003) заморозка невозможна: на origin/main (fetch 05:30 UTC, `git show origin/main:registry/plan.tsv | awk -F'\t' '$1=="121"'` — пусто) НЕТ строки 121 в registry/plan.tsv; `freeze_contract.sh` отказывает «контракт вне плана: 121 — нет строки в registry/plan.tsv» (воспроизведено на wip/121/architect c1dbafa0b, accept критика есть). Порядок «land → freeze» из слова консультанта 05:10/05:25 механизм не допускает: заморозка идёт на ветке до ленда (REPLACE реестра — после ленда). plan.tsv — путь owner-коммитов (последние: `6cce2eb63` owner plan 119/120, `8e0b1226d` 117/118), агент его не правит. Нужен owner-коммит строки 121 (формат как у 119: `121<TAB>4<TAB>до V-2<TAB>106<TAB>docs/owner/…#Порядок<TAB>complior`; зависимость/источник — по воле владельца) в origin/main. После её появления: gitw fetch → пересборка ветки на main → freeze 121 → PR → ленд → REPLACE → Impl121 (клон Complior-back, ветка cmp-bck-003/yadro).
ПРИЗНАК: норма
МАРШРУТ: консультант
ЗАВЕДЁН: 2026-10-21T05:30:00Z
БЛОКИРУЕТ: нет
ОТВЕЧЕНО: да
