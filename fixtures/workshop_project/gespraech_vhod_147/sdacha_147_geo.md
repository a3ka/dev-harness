# СДАЧА 147 — v+6, геометрия пяти переходов Kompakt-1.1

Дельта К-04/К-07 Crit147G1: две точные ЗОНА implementer на motion-spec-gespraech-kompakt-147.json и geometrija-147.json в Complior-mob объявлены до freeze. Geometry — побайтовая копия закреплённого fixture-носителя nositeli/kompakt11/geometrija-147.json с sha256 = piny.json.dvizhenie.sha256. Доставка обоих файлов и dvizhenie.spec/spec_sha256 в mobile/e2e-gespraech-vhod/ekran.json — implementer 147 после freeze в том же продуктовом PR, без повторной раздачи; оригиналы пакета и производный -149.json неизменны. Оракул харнесса загружает закреплённый fixture-носитель до продуктового spec, не вычисляет ожидания из продукта. Пачка mobile/e2e-gespraech-vhod/ остаётся ровно из 10 файлов, оба носителя вне неё. Реализация mob#169, scripts/, батарея, пины, токены, кадры, позы, CI-регистрация и прежние сроки/кривые/УД не меняются. Команды листа и двери pre_critic/check_sdacha исполняются в своей изолированной копии; лист не объявляет RN-реализацию принятой.

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-147-v5-geometrija-fail.md

## Двери

- geometry-model · fixtures/workshop_project/gespraech_vhod_147/red_geo_147.py --model · 0 · 0
- geometry-stabs · fixtures/workshop_project/gespraech_vhod_147/red_geo_147.py --stabs · 0 · 0
- legacy-model · bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --model · 0 · 0
- legacy-stabs · bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --stabs · 0 · 0
- threat-form · bash scripts/check_threat_model.sh . contracts/147-gespraech-vhod-menu.md · 0 · 0
- provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/147-gespraech-vhod-menu.md · 0 · 0
- product-spec-zone · bash scripts/check_precision_gate.sh . contracts/147-gespraech-vhod-menu.md · 0 · 0
- product-carrier-zones · bash fixtures/workshop_project/gespraech_vhod_147/check_zone_147.sh · 0 · 0

## Карта классов

- К-01 · чисто · bash scripts/check_provodka.sh --grammar . contracts/147-gespraech-vhod-menu.md · 0 · 0
- К-02 · чисто · вход: слово владельца 13:52/~14:05 UTC 18.11 и Cons147Motion; источник motion-delta.md sha4b16215f8e плюс измеренные конечные прямоугольники 05, не имя пакета на старых числах · - · -
- К-03 · чисто · вход: прежняя scenes/tokens-форма и 132 v3/146 не меняются; manifest/poses/etalony остаются побайтно; контроль inherited-obligations сравнивает неизменные поля со frozen/147/4 · - · -
- К-04 · чисто · bash fixtures/workshop_project/gespraech_vhod_147/check_zone_147.sh · 0 · 0
- К-05 · чисто · вход: критерий 6 и SPEC8 содержат CLI с rc0/1/2, отсутствующий источник не выдаётся за зелень · - · -
- К-06 · чисто · вход: red_geo_147.py возвращает rc2 при отсутствии git/node/frozen-tag/источника либо повреждении оракула; ошибки загрузки не засчитываются убитым стабом · - · -
- К-07 · чисто · bash fixtures/workshop_project/gespraech_vhod_147/check_zone_147.sh · 0 · 0
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

- К-04 · канон/инструмент · bash fixtures/workshop_project/gespraech_vhod_147/check_zone_147.sh · 0 · 0
- К-07 · канон/инструмент · bash fixtures/workshop_project/gespraech_vhod_147/check_zone_147.sh · 0 · 0

Свидетель следует check_zone_149.sh (83069b598b9d9217a9653d766a1fc7a0029ba6fa): стандартный grep -Fxq сверяет самостоятельные строки обеих зон, полную границу из варианта А Cons147Carrier и строку доставки двух файлов после freeze. Это каноническая текстовая сверка раздачи, не новый механизм приёмки геометрии и не самописный разбор Markdown. Контракт до правки: та же команда дала сырой rc 1 (stdout пуст); геометрический оракул, критерий 6 и его rc0/1/2 неизменны.

## Развилки

Предыдущий FAIL Crit147G1 материализован в базе e200b972a9; его секция «## Карта классов» соответствует scripts/lib_karta_sdachi.sh и содержит блоки К-04 и К-07. Обе строки закрываются командами дельты выше; прежняя зелень check_precision_gate сама по себе не доказывает раздачу недостающего носителя.

Раздача motion-spec-gespraech-kompakt-147.json и geometrija-147.json завершена двумя точными ЗОНА implementer в контракте; product-spec-zone проверяет union живых зон, product-carrier-zones — наличие обеих зон, неизменность оригиналов и доставку обоих файлов одним implementer 147 после freeze, без будущей раздачи. Доставка и пин в mobile/e2e-gespraech-vhod/ekran.json остаются работой implementer в том же продуктовом PR, не имитацией прошедшей --repo-приёмки реального mob; mob#169 не тронут. У 149 отдельный носитель -149 и другая граница перепина архива; общий переход T30 согласован численно (390:35/575/320/52 → 68/452/250/48). Строку санкции владельца добавляет orchestrator, не architect.

ОТКРЫТЫЙ ВОПРОС ДИЗАЙНЕРУ (не блок, не скрывается; слово консультанта 15:40 UTC, диагностика моба `motion-kompakt-1118-scout.md` §6): внутри пакета Kompakt размер знака противоречив — motion-delta.md:22 даёт 28→20 (и 40→32), manifest.json:106 — 28→24, tokens.json presence-mini — 28 без изменения. По слову владельца (батч №2 §8) приоритет у motion-delta.md, поэтому батарея и замеры держат 20 (T28/T31: 20↔32); вопрос размера знака (20/24/28) и единой машинной motion-spec Kompakt решает владелец (батч №3). Движок 145 (mobile/src/lib/faden/faden-motion.ts) держит размеры Final2 (TIERS 288/232/160/96, adaptiveMin 96, cap 288) и этой пачкой не затрагивается.


## Фактические двери исправления К-04/К-07

Копия: `/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/ta50d0e4ea/m`;
ветка `wip/147/architect`, база `e200b972a9`.
`TMPDIR` равен корню этой копии; продуктовые файлы не создавались.

| Команда (из корня копии) | Сырой rc | Вывод |
|---|---:|---|
| bash fixtures/workshop_project/gespraech_vhod_147/check_zone_147.sh — исходный контракт | 1 | stdout пуст |
| bash fixtures/workshop_project/gespraech_vhod_147/check_zone_147.sh — исправленный контракт | 0 | ZONA_147_VYDANA |
| bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --model | 0 | геометрия 8/8; прежняя регрессия 76/76 |
| bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --stabs | 0 | геометрия 8/8, поймано 5/5; прежняя регрессия 76/76, SVJAZI 18 |
| bash /home/harness/dev-harness/scripts/check_sdacha.sh &lt;копия&gt; contracts/147-gespraech-vhod-menu.md --run | 0 | СДАЧА: лист зелёный (двери=8 карта=17/17 дельта=2) |
| bash /home/harness/dev-harness/scripts/pre_critic.sh --repo &lt;копия&gt; contracts/147-gespraech-vhod-menu.md | 0 | КРИТИК: дверь зелёная |

Последние пять команд выполнены последовательной цепочкой `&&`, итоговый сырой rc 0: каждая достигнута. Машинные двери листа также исполнили geometry-model/geometry-stabs, threat-form, provodka-grammar и product-spec-zone с rc 0. Счёт дверей и полнота карты взяты из вывода check_sdacha, не из прежней зелени precision-gate. До будущей продуктовой доставки `--repo` остаётся обязательной приёмкой с честным отказом rc 2 при отсутствии источника; продукт, RN/Jest, эмулятор и mob#169 здесь не запускались.

Формат нового shell-свидетеля: `bash -n fixtures/workshop_project/gespraech_vhod_147/check_zone_147.sh` — rc 0; следующий `shellcheck fixtures/workshop_project/gespraech_vhod_147/check_zone_147.sh` — rc 127 (`shellcheck: command not found`), lint не подтверждён. Журнал NABLIUDENIA_ARCHITECT.md в wip-ветке и вне зоны не менялся; отсутствие shellcheck передаётся оркестратору как ограничение среды, не как зелёная проверка.
