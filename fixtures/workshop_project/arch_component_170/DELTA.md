# 170 — адресный v+1 pinned brief

## Обязательство → клетка

| Обязательство | Различающее предъявление |
|---|---|
| Полный большой бриф вместо отказа по 40000 | `brief_pinned_over_budget`, `brief_pinned_plain` |
| Компоненты не смешаны и не потеряны | `brief_pinned_multi`, `brief_aggregate_budget` |
| Малый бриф остаётся inline, включая смешанный пак | `brief_small_inline`, `brief_mixed_small_inline` |
| Путь, byte length, sha256, обязательное чтение, исполняемая проверка | `brief_pinned_over_budget`; адресные мутации метаданных в `pinned.MUTANTS` |
| Полный stdout, не срез и не нормализация переводов строк | `brief_no_slice`: UTF-8, два завершающих LF, CRLF, маркер другого компонента внутри данных; побайтовый оракул в памяти |
| Доступность и целостность до выдачи; без частичного пака | `brief_pin_missing`, `brief_pin_tampered`: второй pin в двухкомпонентном паке недоступен/изменён; stdout пуст |
| Читаемость и размещение вне checkout/.git | `brief_pin_unreadable`, `brief_pin_checkout`, `brief_pin_git` |
| Честные эквивалентные пути | `brief_pinned_spaces`, `brief_pinned_external_symlink` |
| Проверка потребителем до выдачи ему байтов | `brief_read_missing`, `brief_read_tampered`, `brief_read_same_size`, `brief_read_length_pin`, `brief_read_checkout` |
| Потолок 40000 не повышен; ссылка учитывается общим сериализатором | `brief_over_budget`, `brief_pack_cap`; мутации `cap_raised`, `brief_outside_budget` |

Привязки стабов живут только в коде: `probe.py:mutants` и `pinned.py:MUTANTS`, не в контракте.
Проверяющий исполняет команду потребителя с настоящим Python/файлами, не подменяет валидатор двойником.
Мутации удаления проверки длины и хеша различаются отдельными входами; для честного pin та же команда выдаёт полный ожидаемый stdout.

## Совместимость frozen

Адресно заменены обязательства frozen 170/1:17 и :29. Прочие исходные строки контракта сохраняются дословно; добавлены место продукта, существующий state, детали доставки и новые rc-сценарии.

Исходная `brief_over_budget` проверяла отказ на одном большом брифе. Оставлять одновременно этот отказ и новый успех pinned brief нельзя: именно это обязательство :29 разрешено изменить. Имя клетки сохранено, а её вход теперь несёт небрифовый КОНТЕКСТ за потолком и малый inline-бриф; отрицательный кап не ослаблен. Удалённая старая привязка `brief_outside_budget` заменена адресным стабом того же имени против pinned-ветви. Остальные исходные клетки и стабы сохранены. Единая новая честная модель проходит и исходные, и новые клетки.

Модель — только исполняемый канон до freeze. `pinned_model.py` не подключён в production; его потребители — модель батареи и критик. Production-реализация остаётся в зоне implementer (`scripts/make_task.sh`), после freeze; источник архитектуры 187 не меняется.

## Команды и сырой вывод

Из корня своей копии: `mkdir -p .scratch-170; export TMPDIR="$PWD/.scratch-170" PYTHONDONTWRITEBYTECODE=1`.

- `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --repo "$PWD"` — rc 1 на новых клетках; `.scratch-170/repo.log`.
- `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model` — честный контроль; `.scratch-170/model.log`.
- `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --stabs` — адресные стабы; `.scratch-170/stabs.log`.
- `python3 fixtures/workshop_project/arch_component_170/regressions.py` — утверждения `red_pravila_proekta_ne_harsa.sh` и `red_model_trace_169.sh --model`; `.scratch-170/regressions.log`.

Исторические фикстуры 095/169 жёстко пишут в `/tmp/dev-harness-verify`, игнорируя TMPDIR. `regressions.py` переносит только их scratch: неизменённый bash-тест 095 и исходный модуль 169 исполняются с локальной копией `_toy.sh`, в которой заменён корень временных файлов. Исходные production-файлы, git-pinned модель, аргументы и утверждения тестов не меняются. Прямой запуск двух исторических shell-команд не предъявляется как выполненный: он нарушил бы запрет задания писать вне изоляции.

## Доставка и граница

Коммит — только файлы этой семьи. Текст `contracts/170-arch-component-brief-vhod-zadanija.md` остаётся незакоммиченным; patch и полная копия передаются в `.scratch-170`, хеши — в докладе. Агент не пишет строку разрешения владельца и не пушит.

Суд, лист формы перед судьёй, owner-коммит текста, freeze, production-реализация, CI и shared-журнал наблюдений — не выполнялись в этой задаче. Вызов критика ведёт orchestrator после законного коммита текста. Следование живого агента обязательной инструкции остаётся cognitive-only; проверяемое свойство — валидатор не выдаёт ни байта при нарушенном pin.
