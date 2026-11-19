# СДАЧА 140 v5 — владелец frozen, К-02 / К-16

БАЗА: f7bbd1fca64a21b575f30365821e7446320784ab.
OBJECT предыдущего суда: 5e256355bf4e68d4b17cbed49e0e37b5912c8a39 (не меняется).
ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-140-v5.md

## Предмет и существующее

Исправляются только исполняемая модель, продуктовые миры, адресные стабы,
их материализация и этот лист в architect-зоне. Frozen-текст контракта и
production не изменяются. Прежние клетки/инварианты остаются обязательными.
В принятой базе уже есть resolver OBJECT, проверяемая передача через
опубликованный receipt, JSON Schema, first-parent непустота результата,
прозрачный verdict/.review хвост и detached runtime-checkout.

К-02/К-16: frozen принадлежит владельцу предмета. Для станции HEAD pin,
annotated tag-object, commit и риск читаются в станции; для прямого
продуктового START — в продукте. При передаче опубликованный станционный
receipt по-прежнему удостоверяет точный pin своим registry/contracts.tsv;
наличие тега, тип объекта, его commit и Git blobs риска проверяются в продукте.
Ни latest, ни main-контракт станции/продукта, ни OBJECT не заменяют frozen.

Продуктовые миры теперь создают собственные frozen и реестр, не импортируя
объекты в станцию. p34/p35 имеют противоположные классы и одноимённые разные
станционные frozen; обе полярности reviewer различают владельца. p36 проверяет
подмену frozenCommit, p37 — отсутствие продуктового HEAD pin. Прежние p09/p10,
p26/p27 сохраняют отказы по ref, registry и batch-атомарности. p03/p33 проверяют
настоящую передачу, исходный START, автора, отсутствие фиктивного START и
неизменность веток/учёта; q29/q30 остаются отдельным станционным контролем.
Исполняемые связи s77/s78 заданы produkt_140.py и материализованы в source.json.

Закрытие — канон/инструмент: существующий Git plumbing с правильным корнем.
Снятия обещания и сужения границы нет; новый парсер не вводится. Клетки нужны
как воспроизводимое наблюдение корня: одной статикой нельзя доказать эффект
на двух различных репозиториях. Новых предметных обязательств вне блока нет.

## Среда и результаты

Рабочая копия:
/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t9ef984a08/m
Ветка wip/140/architect-v5 выбрана от точной БАЗЫ; git-dir — своя .git.
Origin: ssh://git@github.com/a3ka/dev-harness.git; push не выполняется.
TMPDIR — .scratch-140-owner внутри этой копии (абсолютный путь при запуске),
PYTHONDONTWRITEBYTECODE=1, PATH=/usr/bin:/bin. Все Git-миры имеют свою .git.
Delivery WORKTREE не используется как cwd/git-dir/scratch.

Собственный red-до: W --owner-before извлекает модель точной БАЗЫ через
Git и предъявляет ей те же конформные миры: rc 1, OWNER140_FAILURES 5;
наблюдаемый KLASS_RISKA_NET вместо разрешённой передачи/суда либо ожидаемого
ADVERSARIJ_DO_REVJUERA. Это реальный прогон, а не прежнее INFERENCE критика.
Green-после: W --owner-check rc 0, OWNER140_FAILURES 0; отдельные станционные
контроли зелёные, s77/s78 красны каждым своим входом (включая обе полярности).
Итого source.json по jq: cases=162, mutants=79, bindings=143, carriers=84.

Rc дверей ниже — требования к фактическому прогону check_sdacha, не замена
самого прогона. W/W --stabs до реализации должны дать rc 1 предметной
краснотой production, а не rc 2 NOT_IMPLEMENTED/ORACLE_TAMPERED.
Оставшиеся красные production — не дефект автора модели и не готовность
реализации; после реализации обе команды обязаны дать rc 0.

## Двери

- Owner-before — реальный принятый дефект · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --owner-before · 1 · 1
- Owner-check — владелец, станции, передача и адресные мутации · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --owner-check · 0 · 0
- W-model — все прежние и новые клетки · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model · 0 · 0
- W-stabs — адресная матрица и production до реализации · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --stabs · 1 · 1
- W-production — настоящая дверь до реализации · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh · 1 · 1
- W-sintaksis — все носители · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --sintaksis · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Spec-ready · bash scripts/check_spec_ready.sh . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Predposylki · bash scripts/check_predposylki.sh . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Threat-model · bash scripts/check_threat_model.sh . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- Provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Provodka · bash scripts/check_provodka.sh . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Pre-critic · bash scripts/pre_critic.sh --repo . contracts/140-odin-agent-na-predmet.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: машинные двери; внешний check_sdacha проверяет весь лист, внутренний pre_critic использует штатный SDACHA_OKRUG=1 против рекурсии · - · -
- К-02 · чисто · вход: предыдущий FAIL; одинаковые конформные продуктовые миры красны на БАЗЕ и зелены после исправления корня frozen · - · -
- К-03 · чисто · вход: frozen-текст и production неизменны; 104/167/197/199 и прежние обязательства 140 не ослаблены · - · -
- К-04 · чисто · вход: все изменения только fixtures/workshop_project/odin_agent_140/ в architect-зоне · - · -
- К-05 · чисто · вход: двери соответствуют rc-командам контракта; обе полярности продукта и отдельная станция предъявляются Owner-check · - · -
- К-06 · чисто · вход: ожидаемый предметный rc 1 W не заменяется NOT_IMPLEMENTED/ORACLE_TAMPERED rc 2 · - · -
- К-07 · чисто · вход: W-model и полная адресная матрица обязательны; scoped зелень не заменяет production/runtime/станцию · - · -
- К-08 · чисто · вход: s77/s78 адресно возвращают неправильный корень; W-stabs по-прежнему включает поставленную дверь · - · -
- К-09 · чисто · вход: p34/p35 — обе полярности класса, p36/p37 — отказы, p03/p33 — передача, q29/q30 — станция · - · -
- К-10 · чисто · вход: реальные раздельные .git, отсутствие продуктовых объектов в станции, противоположные станционные frozen; START/автор/ветки/счёт проверяются прежними клетками · - · -
- К-11 · чисто · вход: source.json и пины снимаются до субъекта; материализация выполняется до приёмки; ожидания не берутся из диска субъекта · - · -
- К-12 · чисто · вход: стандартные Git show/cat-file/rev-parse/for-each-ref и JSON Schema; формат не разбирается новым самописным валидатором · - · -
- К-13 · н/п · секреты и новые внешние строки с секретами не вводятся · - · -
- К-14 · чисто · вход: обычный продукт допускает reviewer вопреки рисковой станции, рисковый продукт отказывает вопреки обычной; соответствующие честные эквиваленты остаются зелёными · - · -
- К-15 · чисто · вход: jq source.json дал 162 клетки, 79 мутантов, 143 связи, 84 носителя; red-до и green-после — собственные результаты · - · -
- К-16 · чисто · вход: pin/tag-object/commit/blob берутся у владельца, опубликованный receipt сохраняет связь передачи; классы станции не подменяют продукт · - · -
- К-17 · н/п · схема операций/writers/isolationKeys модели 188 не меняется; исправляется исполняемая модель батареи 140 · - · -

## Дельта

- К-02 · канон/инструмент · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --owner-check · 0 · 0
- К-16 · канон/инструмент · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --owner-check · 0 · 0

## Границы и процессная рефлексия

Чистая среда из приёмки п.8 проверяется отдельно командой env -i с системным
PATH и HOME/TMPDIR внутри копии; env первым словом не входит в грамматику листа.
S/normalizacija здесь NOT_RUN: внешний /zones/ может вывести станционные
корни вне копии. После реализации оркестратор/adversary выполняют настоящую
станцию, pre_judge --prepare и живой omp, не подменяя их моделью.
Нового вызова critic это исправление не санкционирует.

Наблюдение процесса: прежний продуктовый контроль создавал frozen в станции,
поэтому не различал владельца. Закрытие — отдельные Git-миры и обе полярности
конфликта. Общий NABLIUDENIA_ARCHITECT не изменяется: вне разрешённой зоны и
запись А-NNN допустима только в main.

Фактическая финальная матрица W --stabs: rc 1, MODEL_KLETKI 162 KRASNYH 0,
SVJAZI 143, MODEL_ZHIVYH 0; только слой поставленной двери — SUBJEKT_KRASNO 62.
Чистая среда W --model: rc 0, 162/162. W --sintaksis: rc 0, 80 файлов;
check_provodka: rc 0.

Первый полный check_sdacha --run: rc 1, «предыдущий вердикт: карта 0 строк»:
принятый v5 FAIL не содержит секции «Карта классов». Полный pre_critic: rc 1
только на той же ноге листа; предыдущие ноги прошли. Чужая critic-зона не
исправляется автором модели; требуется штатное дополнение карты критиком,
без изменения FAIL/OBJECT и без нового суда. До такого дополнения зелёный
лист/полный pre_critic не заявляются; требования rc 0 выше не ослабляются.
