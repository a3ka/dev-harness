# Сдаточный лист 154 — одна инженерная переработка

Лист добавлен из-за живого требования двери 193: незамороженный черновик тоже обязан иметь СДАЧА. Это не новый critic-вызов и не разрешение его бюджета. Исторические FAIL v1…v1e прочитаны; они предшествуют карте классов 192/193 и не подменяются новым вердиктом автора.

## Двери

- pre_critic без рекурсивной ноги листа · bash scripts/pre_critic.sh contracts/154-schet-vyzovov-kritika.md · 0 · 0
- precision · bash scripts/check_precision_gate.sh . contracts/154-schet-vyzovov-kritika.md · 0 · 0
- spec · bash scripts/check_spec_ready.sh . contracts/154-schet-vyzovov-kritika.md · 0 · 0
- threat · bash scripts/check_threat_model.sh . contracts/154-schet-vyzovov-kritika.md · 0 · 0
- ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- provodka grammar · bash scripts/check_provodka.sh --grammar . contracts/154-schet-vyzovov-kritika.md · 0 · 0
- honest model · bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --model · 0 · 0
- domain model · bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --domain-model · 0 · 0
- deceptive changes · bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --stabs · 0 · 0

## Карта классов

- К-01 · чисто · вход: команды секции Двери, включая pre_critic под SDACHA_OKRUG=1; внешний pre_critic выполняет саму дверь листа · - · -
- К-02 · чисто · вход: OWNER-BATCH-1118 №18, roles/critic.md §Быстрый-процесс и ADR 2026-11-17 сопоставлены с И-1…И-9; шестой вызов не разрешён · - · -
- К-03 · чисто · вход: старый §6в сохранён дословно; installed-model-live CELLS=9 GREEN=9; затронутые потребители и frozen-пересечения названы в контракте · - · -
- К-04 · чисто · вход: изменяются только contracts/154-schet-vyzovov-kritika.md и fixtures/workshop_project/schet_vyzovov_154/; реализация и CI остаются своим исполнителям · - · -
- К-05 · чисто · вход: таблица приёмки задаёт команды и rc до/после реализации; предписанные consumer-команды не объявлены уже прогнанными · - · -
- К-06 · чисто · вход: probe.py инфраструктурные RuntimeError/OSError/ValueError завершает NOT_IMPLEMENTED rc 2; отсутствующий предметный state является проверяемым отказом rc 1 · - · -
- К-07 · чисто · вход: python3 fixtures/workshop_project/schet_vyzovov_154/installed_control.py — rc 0; честная вставка в настоящие копии CLI: repo 87/87, domain 213/213, live 9/9, grammar 2000/2000, каждый rc 0; production не менялся · - · -
- К-08 · чисто · вход: STAB_CASES привязывает мутации к различающим предъявлениям по коду; каждый модельный контроль зелёный, SVJAZI=46 CAUGHT=46 LIVE=0 · - · -
- К-09 · чисто · вход: две фазы, история, источник, адресный OBJECT/nomer/роль/ключ, третий и consultant-бюджет; весь SUBJECT 000…999, GRAMMAR=1000 CELLS=2000 · - · -
- К-10 · чисто · вход: успешный spawn добавляет ровно START, отказ сохраняет ledger; freeze сравнивает tag И registry; freeze-side-effect выявлен именно изменением снимка, не аварией · - · -
- К-11 · чисто · вход: oracle — чистая функция параметров до субъекта; снимки результатов до вызова в памяти; после субъекта ожидания не перечитываются · - · -
- К-12 · чисто · вход: JSON читает стандартный json; committed receipt сравнивается с каноном receipt_line буквально отдельной строкой из git show commit:path, не самодельным поиском формата · - · -
- К-13 · н/п · предмет не вводит обработку или вывод секретных значений; это не проверка редактирования секретов · - · -
- К-14 · чисто · вход: модель 90/90; две фактически consultant-позиции с арбитражем допустимы, третья отказана в обеих фазах; прямой owner не расходует два, альтернативная owner-строка не меняет реально выбранный consultant-источник · - · -
- К-15 · чисто · вход: счётчики взяты из сырых результатов; полный домен построен range(1000), не списком текущих тегов; текущая станция и исторические ≥21 вызов 143 разделены · - · -
- К-16 · чисто · вход: КЛАСС РИСКА деньги; модель угроз явно оставляет semantic-полномочия, подмену целого журнала, old-subject cutover и бюджет следующего вызова полномочной роли · - · -
- К-17 · н/п · харнесс не проект 187а с закреплённой моделью; архитектура механизма — одна функция бюджета существующей двери и её read-only повтор при freeze · - · -

## Дельта А154-1

| Блок | Способ | Команда | Сырой rc / наблюдение |
|---|---|---|---|
| А154-1: источник расхода | канон/инструмент — ADR 18.11; committed ISPOLZOVANO в том же append-only учёте связывает источник с позицией и OBJECT | W --model | 0; CELLS=90 GREEN=90 |
| А154-1: независимый пересчёт | клетка — одинаковые использованные источники в обеих фазах, дополнительные ARBITRAZH и неиспользованные разрешения | W --domain-model | 0; CELLS=217 GREEN=217 |
| А154-1: различимость и соседние регрессы | клетка — адресные мутации операций и честные парные контроли, привязки в STAB_CASES | W --stabs | 0; SVJAZI=46 CAUGHT=46 LIVE=0 |
| Б1–Б9 сохранены | канон/инструмент — честная вставка в копии настоящих CLI, затем только установленные режимы | python3 fixtures/workshop_project/schet_vyzovov_154/installed_control.py | 0; repo/domain/live/grammar каждый rc 0 |

`W` — команда из приёмки контракта. Модель и оракул получают источник независимо от наличных альтернатив; ожидание остаётся чистой функцией параметров до субъекта. Отсутствие/конфликт источника даёт SCHET_NEIZVESTEN. Выбранный consultant на позиции 4 не становится базовым от ARBITRAZH; новый owner-grant не уменьшает прежний расход. Снимки ledger/tag/registry и положительные freeze-контроли сохранены.

Голые установленные режимы ДО production-реализации: `W --repo` → rc 1, CELLS=87 GREEN=18; `W --domain` → rc 1, CELLS=213 GREEN=19; `W --live` → rc 1, CELLS=9 GREEN=5; `W --grammar` → rc 1, GRAMMAR=1000 CELLS=2000 GREEN=0. Это именованные RED, не безусловные заглушки и не зелёная поставка.

Независимая мера структуры: импорт probe дал CASES=87, OLD=3, DOMAIN=213, OLD_DOMAIN=4, ATTRIBUTION=18, STABS=46, LIVE=9; grammar=1000, границы 000/999. Числа согласованы с сырыми итогами прогонов. Содержательная дельта контракта не даёт автоматического переноса санкции по ADR переиздания и не разрешает новый critic-вызов. Точный итоговый OBJECT — SHA коммита с этим листом в инженерном докладе, не SHA арбитража.
