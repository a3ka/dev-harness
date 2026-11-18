# СДАЧА 187 — лист v3 для узкого critic-вызова по шву 170 (форма контракта 193)

Лист судит форму и согласованность: двери и команды ниже прогнаны этой
пачкой на одноразовом клоне кандидата (ssh-origin, база tip 7d428820c2,
дерево клона равно дереву tip — Замер 8); смысл судит критик. Происхождение
пачки — слово владельца 2026-11-18 12:16 UTC, пункт №13 OWNER-BATCH-1118.
Смысл обязательств контракта и батареи этой пачкой НЕ меняется: правка —
машинное поле СДАЧА контракта и этот лист; все замеры ниже — свежие прогоны
на актуальном кандидате.

Последний материализованный вердикт критика по 187 —
verdicts/critic/contracts-187-v2.md (accept, OBJECT 09e5c11543,
frozen/contracts/187/2); раздела «## Карта классов» он не несёт (замер grep
этой пачки: 0 вхождений), блоков у accept-вердикта нет. Машинной строки
«ПРЕДЫДУЩИЙ ВЕРДИКТ:» лист не несёт: дверь отказывает ссылку на вердикт без
карты (Замер 6), а дорисовка карты в чужой вердикт запрещена. FAIL-вердикт
contracts-187-v2-r1.md карту несёт, но перекрыт accept v2 и предыдущим не
является; красное-до v3 несёт Замер 3.

## Двери

- pre_critic · bash scripts/pre_critic.sh contracts/187-arhitektura-v-processe.md · 0 · 0
- battery-model · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model · 0 · 0
- battery-stabs · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --stabs · 0 · 0

## Карта классов

- К-01 · чисто · bash scripts/pre_critic.sh contracts/187-arhitektura-v-processe.md · 0 · 0
- К-02 · чисто · вход: слово владельца пункт 13 OWNER-BATCH-1118 (12:16 UTC, дословно в задании пачки): дельта пачки не шире слова — машинное поле СДАЧА и этот лист; смысл контракта и батарея не менялись · - · -
- К-03 · чисто · bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model · 0 · 0
- К-04 · чисто · вход: оба файла пачки лежат в ЗОНА architect contracts/187-arhitektura-v-processe.md и fixtures/workshop_project/architecture_process_187/; зоны судит precision-gate внутри pre_critic · - · -
- К-05 · чисто · вход: приёмочные пункты v3 — команды с кодом возврата (голый прогон красен ровно на пяти именованных клетках, Замер 4); двери этого листа · - · -
- К-06 · чисто · вход: канон rc 2 в шапках дверей — check_sdacha без git/timeout/awk/sed и pre_critic без git/bash дают NOT_IMPLEMENTED rc 2, не красную клетку; батарея требует python3 и git станции · - · -
- К-07 · чисто · вход: двери и батарея этого листа прогнаны в одноразовом клоне кандидата той же командой (Замер 8); батарея судит настоящие публичные двери make_task, freeze_contract.sh, pre_critic.sh, done_contract.sh, не двойника · - · -
- К-08 · чисто · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --stabs · 0 · 0
- К-09 · чисто · вход: демаркация v3 — конформный pin это полный 40-hex SHA строчными (канон git); ветви HEAD, имя ветки, 12-hex префикс, неразрешимый полный SHA, вызов без флага, lock без каталога и каталог без lock — своя клетка каждая (pin-symbolic-head, pin-symbolic-branch, pin-short-sha, pin-unresolvable-sha, pin-head-noflag, applicability-lock-no-dir, applicability-dir-no-lock) · - · -
- К-10 · чисто · вход: клетки судят rc и именованную причину полного вывода двери (ARCH_PIN, ARCH_COMPONENT_NET, PINNED_BRIEF_187), не строку-маркер · - · -
- К-11 · чисто · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model · 0 · 0
- К-12 · чисто · вход: грамматика pin — каноническая форма SHA git из единого источника lock .commit; самописного парсера формата нет · - · -
- К-13 · н/п · секреты не предмет: батарея без секретов, нога предпосылок pre_critic сообщает secrets=0 variables=0 environments=0 settings=2 · - · -
- К-14 · чисто · вход: честные эквивалентные записи зелёны — pin-unresolvable-sha и applicability-dir-no-lock зелёны на текущей двери (Замер 1), все 54 прежние клетки зелёны; красны ровно пять клеток-дефектов (Замер 4) · - · -
- К-15 · чисто · вход: числа листа из вывода команд Замеров 1-8; счётные числа контракта совпадают с выводом батареи (61 клетка, 63 стаба) · - · -
- К-16 · чисто · bash scripts/check_threat_model.sh . contracts/187-arhitektura-v-processe.md · 0 · 0
- К-17 · н/п · tooling/checks/cli.js и бриф архитектуры в дереве харнесса отсутствуют (замер ls этой пачки): предмет сам заводит архитектурную дверь продукта, шестой вопрос 188 на этом дереве не предъявим · - · -

## Дельта

Изменения v3 относительно frozen/contracts/187/2 (арбитраж 1 по 170, выход
А): позиция автора v3; грамматика pin — полный 40-hex SHA и порядок шва
(pin судится до флага); применимость требования компонента при lock без
локального каталога; четыре приёмочных пункта v3; строки ЗАЩИЩАЕТ и НЕ
ЗАЩИЩАЕТ модели угроз. Батарея: 54→61 клетка и 56→63 стаба (семь новых
клеток pin-* и applicability-*, Замеры 1-2); текст приёмки v2 нёс числа
30/27 и приведён к фактическим 61/63. Смысл обязательств v2 сохранён.
Закрытие по классам:

- К-08 · клетка · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --stabs · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model · 0 · 0
- К-11 · канон/инструмент · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model · 0 · 0
- К-14 · клетка · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model · 0 · 0

Способы: К-08 — привязка каждого из 63 стабов кодом батареи (строка «STAB
<имя> caught @ <клетка>» в выводе; проза контракта привязок не несёт,
Н-39); К-09 — семь новых клеток покрывают каждую ветвь pin-грамматики и
применимости своим входом; К-11 — грамматика pin заимствует каноническую
форму SHA git, источник един — lock .commit; К-14 — все 54 прежние клетки
и их стабы зелены и не ослаблены (голый прогон красен ровно на пяти
клетках-дефектах, Замер 4), честные записи новых предикатов зелены до и
после ремонта.

## Замеры пачки (числа из вывода команд; тайминги ориентирочные)

1. `--model` → rc 0: «CELLS=61 STABS=0 FAILURES=0» (~6 c); семь новых
   клеток v3 зелены в модельном прогоне, в том числе pin-unresolvable-sha
   и applicability-dir-no-lock.
2. `--stabs` → rc 0: «CELLS=61 STABS=63 FAILURES=0» (~7 c); каждый стаб
   пойман своей клеткой («STAB … caught @ …»), непойманных нет.
3. Красное-до (кандидат без поля СДАЧА, тот же tip): pre_critic → rc 1
   «ОТКАЗ: сдаточный лист красен (rc=1): ОТКАЗ: строка СДАЧА: обязательна
   (текст отличается от frozen/contracts/187/2 — v+1 после внедрения
   193)»; check_sdacha --run → rc 1 тем же текстом.
4. Голый прогон до ремонта implementer 187а: `--repo .` → rc 1, красных
   ровно 5: pin-symbolic-head, pin-symbolic-branch, pin-short-sha,
   pin-head-noflag, applicability-lock-no-dir; прочие 56 зелёны (~64 c).
5. Сосед 170 (этой пачкой не менялся): red_arch_component_170.sh --model
   → rc 0 (~29 c) — замороженная батарея соседа переживает v3.
6. Отказ машинной ссылки: копия листа со строкой «ПРЕДЫДУЩИЙ ВЕРДИКТ:
   verdicts/critic/contracts-187-v2.md» → check_sdacha rc 1 «ОТКАЗ:
   предыдущий вердикт: карта 0 строк…» — строка из листа убрана,
   происхождение несёт эта проза.
7. Форма модели угроз: check_threat_model → rc 0 «модель угроз: секция
   валидна (ЗАЩИЩАЕТ 4 буллет(ов), НЕ ЗАЩИЩАЕТ 3 буллет(ов))».
8. Двери на одноразовом клоне кандидата (ssh-origin, теги доставлены):
   pre_critic и check_sdacha --run → rc 0 каждая; дерево клона равно
   дереву tip (сверка tree-hash в докладе пачки); сырой вывод и rc — в
   докладе пачки.
