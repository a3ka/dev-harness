ФОРК: 094-plan-tsv-zamena-simvol-na-nomer
ВОПРОС: `registry/plan.tsv` несёт символьную строку `принятие-публикации` (пара 3,
этап «до V-2», зависит=091, источник `docs/owner/2026-10-08-roadmap-dovedenie.md#Контракт 3`,
трек odelix) — это ПЛЕЙСХОЛДЕР для контракта 094 (`contracts/094-prinyatie-i-
publikatsiya-kandidata.md`, критик круг 3 accept, `verdicts/critic/contracts-094-v1.md`
на main). `freeze_contract.sh contracts/094-...md "<причина>"` отказывает «контракт
вне плана: 094 — не в текущей/следующей паре registry/plan.tsv (P0 3, P1 4)».

Это ТОТ ЖЕ КЛАСС, что `forks/090-registry-plan-tsv-roadmap-razreshenie.md` (090,
ОТВЕЧЕНО) и `forks/rotaciya-handoff-091-plan-id-korrekcija.md` (091, ОТВЕЧЕНО):
для 090/091 существовали символьные плейсхолдеры, требовавшие ЗАМЕНЫ id
символ→номер — ТОТ ЖЕ случай здесь (не НОВАЯ строка, как у 092/093 в
`forks/put-g-092-093-plan-tsv-registracija.md`).

Предлагаемая замена (на выбор владельца, зеркально 090/091):
```
094	3	до V-2	091	docs/owner/2026-10-08-roadmap-dovedenie.md#Контракт 3	odelix
```
(вместо строки `принятие-публикации	3	до V-2	091	...`; пара/зависимость/трек
сохранены дословно, меняется только id).

КЛАСС: воля-владельца
ПРИЗНАК: норма
МАРШРУТ: батч
ЗАВЕДЁН: 2026-10-09T06:40:00Z
АВТОР: orchestrator
БЛОКИРУЕТ: да — freeze 094 отказывает СЕЙЧАС (живой прогон выше); до ответа
контракт остаётся на wip-ветке (wip/094/architect, HEAD fddf1f0, не landed)
ОТВЕЧЕНО: нет
