# СДАЧА 207 — батарея по FAIL ревьюера, блок Б-1

Коррекция на базе b73141d01a681243f649e1958ea8b383894580c4 (OBJECT ветки
wip/207/orchestrator = main 0eb88386a + реализация implementer + CI-коммит
orchestrator). Контракт заморожен (frozen/contracts/207/1) и не меняется.
Зона этой пачки — только fixtures/workshop_project/check_zones_incr_207/;
scripts/check_zones.sh не трогалась: правка Б-1 (own_nnn) — зона implementer.
Вердикт ревьюера в дереве OBJECT не закоммичен, строка «ПРЕДЫДУЩИЙ ВЕРДИКТ:»
не заявляется.

Блок Б-1 (reviewer, вызов 1, .review/2026-11-23-151.md): пер-контрактный
replay стартует с переменной nnn, уже переприсвоенной ADD-формой минта в
цикле сбора (scripts/check_zones.sh:1789 ← :1441). На мире «СПАСЕНО у
контракта X на коммите раньше ADD-минта другого номера в том же окне» дверь
расходится с базой: wA — ложно-зелёный rc 0 вместо 1 (нарушитель выпал из
суда), wB — ложный FAIL в incr при зелёном полном прогоне, кеш не записан.
Закрытие — способом «клетка»: два новых мира wA/wB (контракты на номерах
033/041 и 052/061/077 — не 101/102, урок 208), клетки e16/e17 с каноном из
ЗАФИКСИРОВАННОЙ базы base/check_zones.sh (побайтово равна
0eb88386a:scripts/check_zones.sh, снята git cat-file), и адресная мутация
производства PATERN:PROIZV-CLOB-SKIP — возврат дефекта заменой
zones_replay "$own_nnn" на zones_replay "$nnn" (Н-39: привязка по коду
субъекта, якорь кратности 1). Прежние 48 клеток и их ожидания не менялись.

## Двери

- модель-окна-один-раз · bash fixtures/workshop_project/check_zones_incr_207/red_check_zones_incr_207.sh --model · 0 · 0
- адресные-мутации-модели · bash fixtures/workshop_project/check_zones_incr_207/red_check_zones_incr_207.sh --stabs --delta model · 0 · 0
- красное-до-на-зафиксированной-базе · bash fixtures/workshop_project/check_zones_incr_207/red_check_zones_incr_207.sh --base · 0 · 0
- реестры-и-якоря · bash fixtures/workshop_project/check_zones_incr_207/red_check_zones_incr_207.sh --catalog · 0 · 0
- готовность-спеки · bash scripts/check_spec_ready.sh . contracts/207-check-zones-incr-odin-sud-okna.md · 0 · 0
- идентификаторы · bash scripts/check_ids.sh . · 0 · 0
- грамматика-проводки · bash scripts/check_provodka.sh --grammar . contracts/207-check-zones-incr-odin-sud-okna.md · 0 · 0

Ряд «красное-до-на-зафиксированной-базе» исполнен против зафиксированной
базы, а не против субъекта HEAD (урок 208 Б-2): команда зелёна и на OBJECT,
где дефект жив, и после правки implementer — переписывать ряд по факту
правки не нужно. Фактическое красное субъекта на OBJECT (rc 1, полные
стабы rc 2) записано сырыми rc в «## Измерения» и «## Дельта».

## Карта классов

- К-01 · чисто · вход: семь дверей листа и две адресные дельты прогнаны на конечном коде, заявленный rc каждой равен фактическому, полный check_provodka до CI-строки остаётся заявленно красным · - · -
- К-02 · чисто · вход: слово владельца 22.11 о суде окна один раз и неизменном timeout 300 не пересматривается, арбитраж f803aa2056423f83495331bb36174fe3da878bcc принят дословно · - · -
- К-03 · чисто · вход: lib_incr 083 и полный режим двери не менялись, 48 прежних клеток зелёны на OBJECT с прежними ожиданиями, K=0 и кеш не тронуты · - · -
- К-04 · чисто · вход: git diff --stat b73141d01a…HEAD называет только каталог fixtures/workshop_project/check_zones_incr_207/, контракт и scripts/check_zones.sh не менялись · - · -
- К-05 · чисто · вход: привязки предъявлений живут только в stabs.tsv и probe.py, мутация производства привязана к якорю кратности 1 в коде субъекта (Н-39) · - · -
- К-06 · чисто · вход: n1–n4 требуют rc 2 непригодного измерителя, до правки Б-1 полные стабы дают именованный отказ NE_PRIMENIM rc 2, это красное-до, не поимка · - · -
- К-07 · чисто · вход: миры строятся живым git станции, канон base/check_zones.sh побайтово равен 0eb88386a:scripts/check_zones.sh и снят git cat-file, а не перепечатан · - · -
- К-08 · чисто · вход: 32 адресные мутации модели пойманы после зелёного честного контроля дверью --stabs --delta model · - · -
- К-09 · чисто · вход: класс миров «СПАСЕНО у контракта X на коммите раньше ADD-минта другого номера в том же окне» покрыт клетками e16 и e17 на номерах 033/041 и 052/061/077, не 101/102 · - · -
- К-10 · чисто · вход: каждая клетка сравнивает rc и отдельно полные stdout и stderr incr с оракулом и каноном базы, сводка и кеш сверяются, порядок ok и FAIL-строк сравнивается байтами · - · -
- К-11 · чисто · вход: оракул снят в память до вызова субъекта, канон — зафиксированная база, субъект пишет только в одноразовые git-миры и свой скратч · - · -
- К-12 · чисто · вход: счётчик судов окна — внешний strace с предсубъектным инвентарём Git по inode и SHA256, самописного самоотчёта нет · - · -
- К-13 · н/п · секреты не предмет · - · -
- К-14 · чисто · вход: честные записи зелёны — модель и починенный скратч-субъект дают 50 из 50 клеток, зафиксированная база 18 из 18 клеток эквивалентности, дефект красит ровно e16 и e17 · - · -
- К-15 · чисто · вход: числа листа взяты из фактических прогонов, каталог независимо пересчитывает реестры EQ=18 C=6 H=21 N=4 K0=1 KLETKI=50 STABS=33 PATERNS=30 PROIZV=1 · - · -
- К-16 · чисто · вход: класс риска обычный, границы модели угроз контракта не меняются, timeout 300 не поднимается · - · -
- К-17 · н/п · архитектурная модель 188 не меняется · - · -

## Дельта

- К-08 · канон/инструмент · bash fixtures/workshop_project/check_zones_incr_207/red_check_zones_incr_207.sh --stabs --delta git · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/check_zones_incr_207/red_check_zones_incr_207.sh --base · 0 · 0

Закрытие Б-1, команды с rc. Факт OBJECT b73141d01a (дефект жив):
`bash fixtures/workshop_project/check_zones_incr_207/red_check_zones_incr_207.sh --repo .`
→ rc 1, KLETKI=50 ZELENYE=48 KRASNYE=2, красны ровно e16-spaseno-do-add-minta
и e17-lozhnyj-fail-incr — красное-до для implementer.
`bash fixtures/workshop_project/check_zones_incr_207/red_check_zones_incr_207.sh --stabs`
→ rc 2, именованный отказ «NE_PRIMENIM: якорь zones_replay "$own_nnn"
встречается в production 0 раз — правка implementer не применена» —
красное-до стаба производства (той же командой с `--delta proizv`, rc 2).
Починенное ПОСЛЕ доказано в одноразовой скратч-копии дерева с двустрочной
правкой ревьюера (own_nnn="$nnn" после eff_nnn, zones_replay "$own_nnn"):
`--repo <скратч>` → rc 0, KLETKI=50 ZELENYE=50 KRASNYE=0;
`--stabs --repo <скратч>` → rc 0, MUTACII=33 SVJAZI=33 POIMANY=33 ZHIVYH=0;
`--stabs --repo <скратч> --delta proizv` → pojman PATERN:PROIZV-CLOB-SKIP на
клетке e16 (rc=0 ≠ 1, СПАСЕНО-строка задвоена), мутант проверен вручную и на
e17 (rc=1 ≠ 0). Поведение стаба производства: ДО правки якоря правки нет —
именованное NE_PRIMENIM rc 2 без исполнения мутации, ПОСЛЕ правки якорь
встречается ровно один раз, честный контроль зелёен и мутация поймана.

## Измерения

W = `bash fixtures/workshop_project/check_zones_incr_207/red_check_zones_incr_207.sh`.
Тяжёлые команды выполняются по одной, TMPDIR внутри своей копии, scratch
удаляется до коммита.

На OBJECT b73141d01a681243f649e1958ea8b383894580c4 (дефект Б-1 жив):
W --repo . → rc 1, KLETKI=50 ZELENYE=48 KRASNYE=2, KRASNYE-KLETKI:
e16-spaseno-do-add-minta, e17-lozhnyj-fail-incr, 77.5 с.
W --model → rc 0, KLETKI=50 ZELENYE=50 KRASNYE=0.
W --stabs --delta model → rc 0, MUTACII=32 SVJAZI=32 POIMANY=32 ZHIVYH=0.
W --base → rc 0, KLETKI=18 ZELENYE=18 KRASNYE=0, 13.1 с.
W --stabs (полный) → rc 2, именованный отказ NE_PRIMENIM (якорь правки
Б-1 в production встречается 0 раз), отказ на первой строке stabs.tsv.
W --catalog → rc 0: EQ=18 C=6 H=21 N=4 K0=1 KLETKI=50 STABS=33 PATERNS=30
PROIZV=1 ANCHORS=1.
Скратч-ПОСЛЕ (двустрочная правка ревьюера во временной копии, рабочее
дерево не менялось и возвращено в исходное состояние):
W --repo <скратч> → rc 0, KLETKI=50 ZELENYE=50 KRASNYE=0.
W --stabs --repo <скратч> → rc 0, MUTACII=33 SVJAZI=33 POIMANY=33 ZHIVYH=0.
W --stabs --repo <скратч> --delta proizv → rc 0, pojman на e16, мутант
красен и на e17 (ручная проверка).

`bash scripts/check_sdacha.sh "$PWD" contracts/207-check-zones-incr-odin-sud-okna.md --run`
→ rc 0, двери=7 карта=17/17 дельта=2. Затем
`bash scripts/pre_critic.sh contracts/207-check-zones-incr-odin-sud-okna.md`
→ rc 0, «КРИТИК: дверь зелёная».
`npm run check:antiplacebo -- --scope check_zones` → rc 0, без конкурентных
записей. Каждая цифра этого листа — из вывода перечисленных команд.

Канон зафиксированной базы: 146805 байт, sha256
e0852c2b6624f0199104d8069429b6e83b161b47641824152a4d05468f4aa0ba, совпадение
с 0eb88386a:scripts/check_zones.sh проверено cmp при съёме. Модель батареи на
мирах wA/wB совпадает с базой побайтово (клетки e16/e17 зелёны в --model),
дефектна только производственная дверь.

## Организация приёмки

Миры wA/wB одноразовые, строятся в TMPDIR батареи и удаляются с её скратчем.
antiplacebo выполняется один раз, отдельно, без конкурентных записей дерева.
Неизменённая после правки implementer production обязана пройти W --repo .
с 50/50/0 и полные стабы 33/33 — это послеремонтная приёмка оркестратора,
канон модели её не заменяет. Семья 040/083 и timeout 300 не переписываются.
