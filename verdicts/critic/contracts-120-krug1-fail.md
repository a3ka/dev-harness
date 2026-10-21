FAIL
Резюме: контракт 120 (спецификация mobility consumer v1, СМЕШАННЫЙ) собран полно — предмет, закрытый перечень артефактов, И-1…И-8, приёмка командами с rc, ЗОНА architect/implementer + ПЕРЕСЕЧЕНИЕ, ПРОВОДКА guard=, модель угроз (check_threat_model rc 0), precision-гейт rc 0, демаркация и остаточные риски названы. Батарея воспроизведена в одноразовом клоне: живой продукт @0b0c413 rc 1 «spec-otsutstvuet (README_RU.md)»; `--model` rc 0 «клеток 42, зелёных 42, красных 0»; стабы rc 1 (1/41 и 2/40); `--cell net-takoj` rc 2; пин воспроизводим (`gen_pin_120.py … 0b0c413 | cmp` — байт-в-байт). Одна блокирующая находка с подтверждённым обходом: инвариант И-7 «замыкание CONSUMER_MOBILITY_V1 без EXTERNAL» держится на поле `kind`, которое пишет сам проверяемый; канал из пина, переименованный в SHARED, делает V1 зависимым от договора с каналом при зелёном оракуле — ровно то «consumer-first под видом partner/channel-first», от чего модель угроз обещает защищать.
OBJECT=58438133724e5d074f79d8210a8335a0f79722e2

Предмет: ветка wip/120/architect @ 584381337, клон /tmp/dev-harness-verify/Critic120/repo (свой .git); продукт — клон /tmp/dev-harness-verify/Critic120/back с /tmp/dev-harness-verify/Impl119/back (HEAD 0b0c413).

## Набор артефактов — полон
Предмет, критерий готовности с командами и rc, исполнители (architect/implementer), ЗОНА-строки обоих, ПРОВОДКА, модель угроз — на HEAD. Разбор по существу правомерен.

## Воспроизведение (одноразовый клон, PYTHONDONTWRITEBYTECODE=1, TMPDIR под Critic120)
- `red_mobility_spec_120.sh /tmp/dev-harness-verify/Critic120/back` → rc 1 «ОТКАЗ: mobility120: spec-otsutstvuet (README_RU.md)».
- `--model` → rc 0 «ИТОГ 120: клеток 42, зелёных 42, красных 0», 7.9 с; каждая d-клетка красная своей причиной (25 причин в REASONS замкнуты).
- `MOBILITY120_ORACLE=stab_vsegda_zelenyj.sh … --model` → rc 1 «зелёных 1, красных 41»; `stab_vsegda_krasnyj.sh` → rc 1 «зелёных 2, красных 40».
- `--cell net-takoj` → rc 2 «нет такой клетки».
- `python3 gen_pin_120.py <клон> 0b0c413 | cmp - pin_120.json` → совпадает.
- `check_threat_model.sh . contracts/120-…md` → rc 0 (6/5 буллетов); `check_precision_gate.sh <клон> contracts/120-…md` → rc 0 «OK».
- main продукта 45b946d06a в доступных клонах отсутствует (`cat-file -t` → not a valid object); сверка замороженных файлов main против 0b0c413 НЕ выполнена — R-1 контракта это называет; направление ложно-красное, не обход.

## Находки

БЛОКИРУЕТ contracts/120-mobility-consumer-spec.md:48 (И-7: «замыкание CONSUMER_MOBILITY_V1 без PARTNER/BROKER_APP/EXTERNAL») и :118 (модель угроз: «от partner-first под видом consumer-first: транзитивное замыкание V1 без PARTNER/BROKER_APP/EXTERNAL») — оракул (mobility_spec_oracle.py, блок release-graph: `bad = [i for i in cv1 if kind[i] in ("PARTNER","BROKER_APP","EXTERNAL")]`) отличает канал от общего ядра ТОЛЬКО по полю `kind`, которое пишет проверяемый; привязки «id из pin.external_dependencies ⇒ kind EXTERNAL» нет (в отличие от PM_* — те обязаны быть PARTNER, и BROKER_APP_ENDPOINTS — BROKER_APP). Клетка d34-graf-v1-zhdet-kanal ловит только честную маркировку.
ОБХОД: честная спека модели, в release-graph.json узел `{"id":"insurer_sandbox","kind":"SHARED","depends_on":[]}` (вместо EXTERNAL), `CONSUMER_MOBILITY_V1.depends_on` += `insurer_sandbox`, `KUENDIGUNG.depends_on` += `insurer_sandbox`. Прогон оракула на этом мире (build --spec + правка, одноразовый скрипт): `MOBILITY120_OK processes=5 new_operations=7 errors=15 nodes=20 pin=model`, rc 0. Строка 1 приёмки зелёная, граф выпуска V1 заблокирован договором со страховщиком — consumer-first не сделан. Закрытие: в оракуле требовать для каждого id ∈ pin["external_dependencies"], присутствующего в nodes, kind == EXTERNAL (причина graf-nevaliden), и/или проверять `cv1 ∩ set(pin["external_dependencies"]) == ∅` по id (graf-ne-consumer-first); добавить клетку с этой мутацией (её ожидаемая причина — литерал таблицы CELLS, Н-39).

СОВЕТ contracts/120-mobility-consumer-spec.md:46 (И-5) — операции lifecycle Wunschkennzeichen допускаются из `пин ∪ new_operations`; состояние «пять видов разнесены по существующим generic-операциям case (listMobilityServices=CHECK, createMobilityServiceCase=RESERVE, getMobilityOperation=READ, getMobilityServiceOutcome=EXPIRE, cancelMobilityServiceCase=CANCEL), new_operations пусты» проходит оракул, хотя §2.1 отчёта называет именно отсутствие типизированных reserve/expire/cancel дефектом. Контракт объявляет это cognitive-only (R-2, строка 8 приёмки) — потому совет: требовать RESERVE/EXPIRE/CANCEL ∈ new_operations процесса KENNZEICHEN_WUNSCH либо явно записать допустимость переиспользования в демаркации.

СОВЕТ contracts/120-mobility-consumer-spec.md:43 (И-2) — `untouched_prefixes` = только `app/`, `server/`; правки в `tests/`, `docs/contracts/*` (кроме published), `docs/data/` в продукте оракул не видит, а `check_zones.sh` харнесса коммиты Complior-back не читает [INFERENCE]. Это не обход (предмет при этом сделан), но граница «вне зоны — И-2» держится только дисциплиной; дешевле: `git diff --name-only base_commit` + untracked, допускать ТОЛЬКО `spec_dir`.

СОВЕТ contracts/120-mobility-consumer-spec.md:96–97 — «клон, содержащий коммит 0b0c413» и «ветка implementer — от main (содержит #156)» совместимы только если main содержит 0b0c413 в истории; при squash-merge #156 свежий клон main его не содержит → `git diff` rc≠0 → оракул `SystemExit(2)` «нечем судить» вместо ясного сообщения. R-1 лечит перегенерацией пина; стоит записать это явной предпосылкой и дать оракулу осмысленный rc 2-текст («base_commit пина отсутствует в клоне»).

СОВЕТ contracts/120-mobility-consumer-spec.md:49 (И-6) — `severity` из алфавита, но соответствие строке отчёта не сверяется; `fix` — любая непустая строка (модель пишет «по §5.2 «Как исправить»» для всех 15). Объявлено cognitive-only (строка 8) — оставить, но пин несёт колонку серьёзности дословно (gen_pin уже разбирает таблицу) и сверка стоила бы одну строку.

СОВЕТ — сверка «main 45b946d06a ≠ 0b0c413 по замороженным файлам» критику недоступна (коммита нет на станции); до старта implementer выполнить R-1 и зафиксировать в HANDOFF, на каком коммите снят рабочий пин.

## По пяти вопросам
1. Критерий слабее предмета — да, в одном месте (И-7, обход выше). Прочие инварианты привязаны к пину по id (коды, операции, 18 строк, 13 id, PM_*), не к полям проверяемого.
2. Недоказуемого «готово» нет: 7 пунктов приёмки с командами и rc; пункт 8 честно cognitive-only с названным ловцом.
3. Молчаливые решения: имена новых операций (regex), состояния сверх минимума, тексты fix — объявлены открытыми (демаркация). Не молчание.
4. Границы: ЗОНА обоих названы, ПЕРЕСЕЧЕНИЕ с 119 объяснено; механизм удержания границы в продукте — только И-2 (совет выше).
5. Противоречий норме AGENTS.md не найдено: PASS не печатается, rc 2 на «нечем судить», стабы двунаправленные, пара «стаб ↔ ветвь» контрактом не утверждается (Н-39: литералы CELLS), ПРОВОДКА по грамматике 038 с обоснованием ПРОВОДКА-ЭНФОРСМЕНТ.

Арбитр: круг 1, не созывается.
