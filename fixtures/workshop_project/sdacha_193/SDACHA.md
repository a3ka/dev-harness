# СДАЧА 193 — Л2: сдаточный лист architect и карта классов в вердикте критика

Первый образец формата, который задаёт этот предмет. Команды выбраны
rc-стабильными ДО и ПОСЛЕ реализации (красный голый прогон батареи живёт в
приёмке контракта, не в листе: до реализации он честно красен, лист судит
согласованность заявленного и фактического, а не нулевой rc).

## Двери

- pre_critic · bash scripts/pre_critic.sh contracts/193-svyazka-sdatochnyj-list.md · 0 · 0
- spec_ready · bash scripts/check_spec_ready.sh . contracts/193-svyazka-sdatochnyj-list.md · 0 · 0
- проводка-грамматика · bash scripts/check_provodka.sh --grammar . contracts/193-svyazka-sdatochnyj-list.md · 0 · 0

## Карта классов

- К-01 · чисто · bash scripts/pre_critic.sh contracts/193-svyazka-sdatochnyj-list.md · 0 · 0
- К-02 · чисто · вход: КОНТЕКСТ цитирует слово владельца 2026-11-11 и строку плана registry/plan.tsv:117 · - · -
- К-03 · чисто · вход: ПЕРЕСЕЧЕНИЕ по живым заморозкам pre_critic 10 и freeze 12 (рецепт А-962) · - · -
- К-04 · чисто · bash scripts/check_spec_ready.sh . contracts/193-svyazka-sdatochnyj-list.md · 0 · 0
- К-05 · чисто · bash fixtures/workshop_project/sdacha_193/red_sdacha_193.sh --model · 0 · 0
- К-06 · чисто · вход: клетка s13 — PATH без git даёт rc 2 NOT_IMPLEMENTED именованный · - · -
- К-07 · чисто · вход: миры батареи гоняют настоящий git и bash станции (пробы без двойников) · - · -
- К-08 · чисто · вход: привязки обманных реализаций — stabs.tsv (11 строк), поимка режимом --stabs · - · -
- К-09 · чисто · вход: клетки s01–s19, v01–v06, f01–f02, p01–p02 покрывают инварианты И1–И10 по ветви · - · -
- К-10 · чисто · вход: суд клетки сверяет rc и первую строку полного выхода субъекта · - · -
- К-11 · чисто · вход: ожидания сняты в память probe.py до вызова субъекта · - · -
- К-12 · чисто · вход: грамматика карты вердикта — единый источник lib_karta_sdachi.sh для обеих дверей · - · -
- К-13 · н/п · секреты не предмет · - · -
- К-14 · чисто · вход: честные контроли s02 s08 s10 s12 f02 p02 зелёны в --model и до и после реализации · - · -
- К-15 · чисто · bash scripts/check_spec_ready.sh . contracts/193-svyazka-sdatochnyj-list.md · 0 · 0
- К-16 · чисто · bash scripts/check_threat_model.sh . contracts/193-svyazka-sdatochnyj-list.md · 0 · 0
- К-17 · н/п · tooling/checks/cli.js и бриф архитектуры 188 в объекте отсутствуют · - · -
