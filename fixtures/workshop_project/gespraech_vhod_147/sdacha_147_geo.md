# СДАЧА 147 — v+6, геометрия пяти переходов Kompakt-1.1

Дельта И-12: численное основание T28/29/30/31/33, пины, геометрический канон и его потребление прежними g01/g02 набора 158; адресная ЗОНА implementer на единственный производный motion-spec-gespraech-kompakt-147.json в Complior-mob объявлена до freeze. Доставка и пин в mobile/e2e-gespraech-vhod/ekran.json — implementer после freeze в том же продуктовом PR; оригиналы пакета и производный -149.json неизменны. Реализация mob#169, scripts/, батарея, токены, кадры, позы, CI-регистрация и прежние сроки/кривые/УД не меняются. Команды листа и двери pre_critic/check_sdacha исполняются в своей изолированной копии; лист не объявляет RN-реализацию принятой.

## Двери

- geometry-model · fixtures/workshop_project/gespraech_vhod_147/red_geo_147.py --model · 0 · 0
- geometry-stabs · fixtures/workshop_project/gespraech_vhod_147/red_geo_147.py --stabs · 0 · 0
- legacy-model · bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --model · 0 · 0
- legacy-stabs · bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --stabs · 0 · 0
- threat-form · bash scripts/check_threat_model.sh . contracts/147-gespraech-vhod-menu.md · 0 · 0
- provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/147-gespraech-vhod-menu.md · 0 · 0
- product-spec-zone · bash scripts/check_precision_gate.sh . contracts/147-gespraech-vhod-menu.md · 0 · 0

## Карта классов

- К-01 · чисто · bash scripts/check_provodka.sh --grammar . contracts/147-gespraech-vhod-menu.md · 0 · 0
- К-02 · чисто · вход: слово владельца 13:52/~14:05 UTC 18.11 и Cons147Motion; источник motion-delta.md sha4b16215f8e плюс измеренные конечные прямоугольники 05, не имя пакета на старых числах · - · -
- К-03 · чисто · вход: прежняя scenes/tokens-форма и 132 v3/146 не меняются; manifest/poses/etalony остаются побайтно; контроль inherited-obligations сравнивает неизменные поля со frozen/147/4 · - · -
- К-04 · чисто · bash scripts/check_precision_gate.sh . contracts/147-gespraech-vhod-menu.md · 0 · 0
- К-05 · чисто · вход: критерий 6 и SPEC8 содержат CLI с rc0/1/2, отсутствующий источник не выдаётся за зелень · - · -
- К-06 · чисто · вход: red_geo_147.py возвращает rc2 при отсутствии git/node/frozen-tag/источника либо повреждении оракула; ошибки загрузки не засчитываются убитым стабом · - · -
- К-07 · чисто · вход: самостоятельный --repo читает только заявленный производный spec и byte-пины геометрии/дельты; среды RN/эмулятора не требует, прежний продуктовый jest и кадры остаются обязательны · - · -
- К-08 · чисто · fixtures/workshop_project/gespraech_vhod_147/red_geo_147.py --stabs · 0 · 0
- К-09 · чисто · вход: пять собственных ветвей, обе темы resolved, symbolic from/to с k, adaptive top/cap/min/start/end; контраст заменяет ровно одну сцену на исходную Final2, остальные геометрические ветви и все timing-rules зелены · - · -
- К-10 · чисто · вход: проверяются разобранные численные поля и полный структурный runner-report; один маркер не достаточен, геометрические результаты обязаны покрывать все пять ID, timing-набор непуст · - · -
- К-11 · чисто · вход: oracle() загружает pinned geometry/delta и frozen-spec до spec-субъекта; --repo не черпает ожидания из продукта, исходная Final2-геометрия служит только контрастом · - · -
- К-12 · чисто · вход: JSON разбирается стандартным json/JSON.parse и сравнивается структурно; самописной грамматики JSON/Markdown нет; применённый spec не подменён compact-manifest · - · -
- К-13 · н/п · секреты/учётные данные и внешняя сеть не предмет геометрической проверки · - · -
- К-14 · чисто · вход: equivalent-json переставляет ключи и меняет пробелы без изменения результата на честном и явно предъявленном субъекте; числовое равенство не зависит от текстовой записи 32/32.0 · - · -
- К-15 · чисто · вход: IDS и STABS в red_geo_147.py задают множество пяти переходов; счёт клеток и пойманных стабов печатает сам прогон, прежний цикл2 имеет собственную отдельную сводку · - · -
- К-16 · чисто · bash scripts/check_threat_model.sh . contracts/147-gespraech-vhod-menu.md · 0 · 0
- К-17 · н/п · модель модулей/writers/consumes и новые продуктовые операции в геометрической дельте не вводятся · - · -

## Дельта

- К-02 · канон/инструмент · fixtures/workshop_project/gespraech_vhod_147/red_geo_147.py --model · 0 · 0
- К-03 · канон/инструмент · fixtures/workshop_project/gespraech_vhod_147/red_geo_147.py --model · 0 · 0
- К-04 · канон/инструмент · bash scripts/check_precision_gate.sh . contracts/147-gespraech-vhod-menu.md · 0 · 0
- К-08 · клетка · fixtures/workshop_project/gespraech_vhod_147/red_geo_147.py --stabs · 0 · 0
- К-11 · канон/инструмент · fixtures/workshop_project/gespraech_vhod_147/red_geo_147.py --model · 0 · 0
- К-14 · канон/инструмент · fixtures/workshop_project/gespraech_vhod_147/red_geo_147.py --model · 0 · 0

## Развилки

Форма без строки «ПРЕДЫДУЩИЙ ВЕРДИКТ» предусмотрена `scripts/check_sdacha.sh`: покрытие прошлых блоков проверяется только при непустом пути. Вердикт v5 accept содержит строки `- К-NN:`, а оба v5 FAIL — также неканонический заголовок карты; `scripts/lib_karta_sdachi.sh` не читает из них карту. Судейские артефакты не переписываются; полная карта К-01…К-17 и команды этой дельты остаются в листе.

Раздача производного motion-spec-gespraech-kompakt-147.json завершена точной ЗОНА implementer в контракте; её согласованность с union живых зон проверяет product-spec-zone. Доставка и пин в mobile/e2e-gespraech-vhod/ekran.json остаются работой implementer после freeze в том же продуктовом PR, не имитацией прошедшей --repo-приёмки реального mob; mob#169 не тронут. У 149 отдельный носитель -149 и другая граница перепина архива; общий переход T30 согласован численно (390:35/575/320/52 → 68/452/250/48). Строку санкции владельца добавляет orchestrator, не architect.

ОТКРЫТЫЙ ВОПРОС ДИЗАЙНЕРУ (не блок, не скрывается; слово консультанта 15:40 UTC, диагностика моба `motion-kompakt-1118-scout.md` §6): внутри пакета Kompakt размер знака противоречив — motion-delta.md:22 даёт 28→20 (и 40→32), manifest.json:106 — 28→24, tokens.json presence-mini — 28 без изменения. По слову владельца (батч №2 §8) приоритет у motion-delta.md, поэтому батарея и замеры держат 20 (T28/T31: 20↔32); вопрос размера знака (20/24/28) и единой машинной motion-spec Kompakt решает владелец (батч №3). Движок 145 (mobile/src/lib/faden/faden-motion.ts) держит размеры Final2 (TIERS 288/232/160/96, adaptiveMin 96, cap 288) и этой пачкой не затрагивается.

