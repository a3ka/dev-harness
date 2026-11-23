# СДАЧА 208 — замок предмета: вывод субъекта байтами обеих труб (К-10, круг c); адрес предмета параметризован — константа 208 различима (круг d, Adv208); белый список D9b — ОДИН предикат с резолвером (круг h, Б-1 Rev208)

БАЗА круга c: сдача круга b `36fea14f3dd156848273ac89ce42763864762be2` (OBJECT FAIL
Crit208V2; на origin `wip/208/architect`), рабочая ветка wip/208/architect-c. Вердикт
Crit208V2 (`c8aef370e312c6d6e4692c99c4e28325efb7f53c`, archive/208 станции, ветка
archive/208/critic-v2-fail-c8aef370e3; в дереве этой ветки не закоммичен — строка вида
«ПРЕДЫДУЩИЙ ВЕРДИКТ:» не заявлена). Блок один — К-10: проверка вывода нормализует
CRLF до LF. Решение арбитра по К-10 исполнено: наблюдение — (rc, stdout bytes, stderr
bytes) с точным равенством в каждом режиме и клетке; CRLF, одиночный CR, пробел в конце
строки, двойной LF, BOM, NUL, не-UTF8, лишний вывод и перенос между трубами — не остаток;
временной общий порядок строк между трубами двумя PIPE не наблюдаем, merged stream не
вводится; text-режим допустим только служебному git/bash -n — в пробе его нет вовсе.
Правка круга: probe208.py, source.json, stabs/st20…st39 (новые), контракт (контекст,
приёмка, модель угроз), этот лист. Производство `scripts/zamok_predmeta.sh` не тронуто.
Scratch прогонов — в копии работы (`.scratch-arch208c/`: запись вне пина запрещена
стражем), удалён до коммита.

Круг d (Adv208, FAIL, один блок — «ложная достаточность проверки универсальной
публикации в ветке предмета»: мутация-константа 208 вместо параметра $n в
obj_opublikovan проходила батарею и профиль гигиены; вердикт —
archive/208/adversary-v1-fail-cf589c2153 станции, в дереве ветки не закоммичен
— строка «ПРЕДЫДУЩИЙ ВЕРДИКТ:» не заявлена). БАЗА круга d: d0b9565856ae3a67445d79f67441119b9f160c72
(main 6d311c00e + реализация + лист круга c; батарея зелёная 23/0, 64/0).
Правка круга d: probe208.py (клетки r24–r30 на предметах 209/003, стабы
st40–st43 константы предмета — каталог stabs-konstanty-208d/: census заморозки
«stabs/* = 39» правкой батареи не трогается), source.json, этот лист.

Круг h (Rev208, FAIL, один блок Б-1 — «белый список D9b ≠ белый список резолвера»,
инвариант 3: kodovaja_granica судила кодовую границу по glob `"$p" == .review/*`
(любой не-`.md` файл и вложенный каталог — «вердиктный путь»), а резолвер
object_kandidata — только `^\.review/[A-Za-z0-9._-]+\.md$`; на мире «вперёд»,
опубликованном в origin/main и добавляющем только `.review/zametki.txt`, дверь
отказывала «не кодовая граница» rc 1, хотя резолвер тот же коммит считал кодом;
вердикт — archive/208/reviewer-v1-fail-4e63894b06 станции, в дереве ветки НЕ
закоммичен — строка «ПРЕДЫДУЩИЙ ВЕРДИКТ:» не заявлена, блок описан командами rc
в «## Дельта»). БАЗА круга h: OBJECT `94251e24cf96b2b8bf292fbbb9c70d171c8dd69b`
(ветка wip/208/orch-lin2). Правка круга h: model/zamok_predmeta.sh (грамматика
вердиктного пути — ОДИН предикат verdikt_put, его зовут оба обхода резолвера и
kodovaja_granica; вторая альтернатива D9b — `^\.review/[A-Za-z0-9._-]+\.md$`, как у
резолвера), probe208.py (клетки r31/r32 — допуски не-`.md` и вложенного пути;
r33–r35 — контроли вердиктного `.review/zametki.md` на предметах 208/209/003),
stabs-konstanty-208d/st41 (якорь перевешан на verdikt_put) и st44 (возврат glob —
новый адресный стаб Б-1), source.json, этот лист. Производство
scripts/zamok_predmeta.sh НЕ тронуто: sha256 прежний
`d79af60e82c7c698c35015f6289cf8cb3feb57e4b80a833e96930057aa588734`; дверь подгонит
implementer побайтно к НОВОМУ sha256 модели
`47de5c0244b548d275b268a0530f634e90a09e7224b8542bb2cbe1601826bdfe`.
Строки модели для побайтного повтора implementer-ом — fenced-блок в «## Дельта».
Scratch прогонов — `.scratch-208h/` в копии работы, удалён до коммита.

Предмет и существующее (кратко; полный текст — contracts/208-zamok-object-predok.md).
Обещание: судья допускается на OBJECT, связанный предковостью с кандидатом последнего
рабочего START и опубликованный (main либо ветка предмета на origin, в носителе), START
несёт запрошенный OBJECT; порядок родителей merge не меняет допуск; повтор роли на том
же OBJECT — только по записанной в учёте санкции SANKCIJA полного адреса при
неисчерпанном круге. Наблюдение — rc, ПОЛНЫЙ stdout и ПОЛНЫЙ stderr БАЙТАМИ в КАЖДОМ
режиме (модель, стабы, субъект): один путь запуска (sudit → захват обеих труб без
text-режима) и один предикат вывода k_vyvod, между захватом и сравнением нет
декодирования, перевода строк и strip; ожидания в памяти до вызова; START учёта при
допуске, неизменность учёта при отказе.
Существующее: дверь 140 в редакции A2 (v8…v13) — база; резолвер общий с pre_judge/peredat
и не меняется; равенство, отказы реального вреда и предупреждения v8 вне предмета
сохранены (клетки r01/r09/r16-r18 зелены на производстве и на модели). Пересечение
140↔208 (отказы 208 для судейских D9/D11 поверх предупреждений v8) названо в контракте
отдельным разделом — решено словом владельца 22.11 (вариант А).

· До реализации (A2): `--repo .` → `SUBJEKT 208: KLETKI 23 KRASNYH 18`, rc 1; красные клетки производства
  (замер на двери A2): r02, r03, r04, r05, r06, r07, r08, r10, r11, r12, r13, r14, r15,
  r19, r20, r21, r22, r23; регрессионные r01/r09/r16/r17/r18 зелены.
· Круг h (прогон на двери ДО правки implementer; на OBJECT после подгонки та же команда даёт rc 0 — ряд «## Двери»): `--model` → `MODEL 208: KLETKI 35
  KRASNYH 0`, rc 0 (30 прежних + r31–r35); `--repo .` → `SUBJEKT 208: KLETKI 35
  KRASNYH 2`, rc 1 — красны РОВНО r31-review-txt-vperjod и r32-review-vlozhenyj-vperjod
  (Б-1: дверь дерева ещё несёт glob `.review/*`; обе клетки зелёны на исправленной
  модели — правка двери за implementer-ом, побайтно к sha256 модели этого круга);
  `--stabs` → `MODEL 208: KLETKI 35 KRASNYH 0` и `STABY 208: SVJAZI 73 ZHIVYH 0`,
  rc 0 — стабов 44 (st01–st39 прежние в stabs/, st40–st44 в stabs-konstanty-208d/),
  связей 73 (2 новых у st44: r31, r32).
· `--sintaksis` → `SINTAKSIS OK`, rc 0.
· Регресс на двери A2: 140 `--model` → `MODEL_KLETKI 244 KRASNYH 0`, rc 0; obryv_167
  `--repo .` → rc 0; гигиена zamok_predmeta → `итог 4/4 классов закрыто`, rc 0.
· census: model/ = 1 файл, stabs/ = 39 каталогов (замеры контракта — не изменились),
  stabs-konstanty-208d/ = 5 каталогов (вне замеров контракта; 40-й каталог в stabs/
  красит spec-гейт: «заявлено 39, команда даёт 40» — проверено прогоном круга d).

## Двери

- Red-do (историческое имя ряда круга h) — субъект дерева ПОСЛЕ побайтной подгонки двери implementer: красных 0; до подгонки двери красны были ровно r31/r32 (Б-1) — зафиксировано в «## Дельта» п.1 и «Ручная проба круга h» · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo . · 0 · 0
- Model — эталон (A2 + блоки 208 + один предикат verdikt_put), все клетки, обе трубы байтами · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --model · 0 · 0
- Stabs — матрица обманных дверей, SVJAZI 73 ZHIVYH 0 (st01-st39 в stabs/, st40-st44 в stabs-konstanty-208d/) · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --stabs · 0 · 0
- Sintaksis — модель и субъект-носители · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --sintaksis · 0 · 0
- Reg-140-model — семья замка целиком (редакция A2) · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model · 0 · 0
- Reg-167 — оборванный судья и круги · bash fixtures/workshop_project/obryv_167/red_obryv_167.sh --repo . · 0 · 0
- Reg-higiena — профиль двери · bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/208-zamok-object-predok.md · 0 · 0
- Spec-ready · bash scripts/check_spec_ready.sh . contracts/208-zamok-object-predok.md · 0 · 0
- Predposylki · bash scripts/check_predposylki.sh . contracts/208-zamok-object-predok.md · 0 · 0
- Threat-model · bash scripts/check_threat_model.sh . contracts/208-zamok-object-predok.md · 0 · 0
- Ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- Provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/208-zamok-object-predok.md · 0 · 0
- Pre-critic · bash scripts/pre_critic.sh --repo . contracts/208-zamok-object-predok.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: двери листа прогоном (rc в рядах выше), форма контракта — потолки, незаполненные требования, СДАЧА/ПРОВОДКА-строки, рекурсия pre_critic разорвана штатным маркером SDACHA_OKRUG=1 · - · -
- К-02 · чисто · вход: слово владельца затравки PR #1232 (РАЗРЕШИЛ-ВЛАДЕЛЕЦ дословно в КОНТЕКСТ), задания станции task-arch208/b/c/h, боль консультанта дословно в §Существующее/§Предмет, sourceCanon не объявлен — режим проекта не включён · - · -
- К-03 · чисто · вход: A2 378e45782e влита merge'ом (потомок — rc 0), ПЕРЕСЕЧЕНИЕ 140/154/167/199 по scripts/zamok_predmeta.sh и 140 по профилю гигиены объявлены с базой A2, равенство (r01), предупреждения v8 вне предмета (r09/r17/r18) и оборванный круг (167) не ослаблены, дверь дерева этим кругом не тронута (sha256 d79af60e…) · - · -
- К-04 · чисто · вход: файлы пачки только в architect-зоне fixtures/workshop_project/zamok_object_predok_208/ этого круга (model, probe208.py, source.json, stabs-konstanty-208d/, лист), census-замеры контракта сверяют состав и НЕ изменились (model 1 / stabs 39), производных файлов вне зоны нет, scratch прогонов удалён до коммита · - · -
- К-05 · чисто · вход: каждая строка приёмки контракта — правило, сценарий дано→когда→тогда либо команда с rc (пробы Red-do/Model/Stabs/Sintaksis/регрессии в рядах дверей) · - · -
- К-06 · чисто · вход: rc 2 (нет git/jq/python3, ORACLE_TAMPERED, дрейф носителей, сломанный синтаксис мутации) успехом не считается, SUBJECT_ABSENT — rc 1 с перечнем входов · - · -
- К-07 · чисто · вход: Red-do судит поставленную дверь дерева (scripts/zamok_predmeta.sh по --repo .), не двойника — до правки двери implementer красны ровно r31/r32 (Б-1), после побайтной подгонки двери к sha256 модели 47de5c02… та же команда даёт rc 0 · - · -
- К-08 · чисто · вход: матрица обманных дверей над текстом модели — SVJAZI 73 ZHIVYH 0, каждая замена/удаление операции допуска и каждая граница наблюдения имеет краснеющую клетку из source.json:.stab_vhod, включая st44 (возврат glob .review/* в D9b — красит r31/r32), каждый стаб отличается от модели ровно одной якорной заменой кратности 1 · - · -
- К-09 · чисто · вход: конформные входы покрыты по клеткам — равенство r01, предок r02/r03/r04/r22, потомок r05/r06/r07, merge-пустой r08, merge с обратным порядком r23, пустой не-merge r09, расхождение r10, повтор r11-r15/r19-r21, предметы ≠ 208 r24-r30, грамматика белого списка .review: не-`.md` файл r31, вложенный путь r32, контроль вердиктного `.md` r33/r34/r35, границы вывода — каждая своим стабом на обеих трубах (st20-st39) · - · -
- К-10 · чисто · вход: наблюдение — (rc, stdout bytes, stderr bytes) с точным равенством во ВСЕХ режимах одним путём запуска (sudit → захват байтами, text-режима в пробе нет) и одним предикатом k_vyvod, ожидания в памяти до вызова, слой субъекта — ручная проба CRLF круга c (раздел ниже) · - · -
- К-11 · чисто · вход: оракул source.json и ожидания в памяти до вызова субъекта, носители — sha256 (дрейф = ORACLE_TAMPERED rc 2), миры в mktemp вне дерева субъекта · - · -
- К-12 · чисто · вход: факты git — plumbing (merge-base --is-ancestor, for-each-ref, rev-parse, show, diff-tree), событие — jq, самописного разбора истории/JSON нет · - · -
- К-13 · н/п · секретов во входах/выходах предмета нет (локальные миры, реестры станции, git-объекты) — белый список наружных строк не строится · - · -
- К-14 · чисто · вход: честные эквивалентные записи зелёны на модели (35/0: равенство r01, повтор по санкции r11, предок через второго родителя r22, merge с обратным порядком r23, допуски предметов 209/003 r24/r25/r28/r30, контроль вердиктного .review/zametki.md r33/r34/r35), каждая запрещающая мутация матрицы красит связанную клетку — свободных проходов нет (ZHIVYH 0) · - · -
- К-15 · чисто · вход: числа листа — из вывода движка (KLETKI 35, SVJAZI 73, ZHIVYH 0) и ls -d … | wc -l (stabs/ 39 — без изменений, stabs-konstanty-208d/ 5), таблица стабов листа напечатана из source.json:.stab_vhod и diff стаб↔модель, сверена jq-командой побайтово (44 строки, 73 связи) · - · -
- К-16 · чисто · вход: КЛАСС РИСКА: рисковый с основанием закрытого перечня (допуск судей), модель угроз по свойствам ЗАЩИЩАЕТ/НЕ ЗАЩИЩАЕТ, границы с ловцами · - · -
- К-17 · чисто · вход: правка существующей двери поверх принятой A2 без новых модулей, один наблюдаемый результат (допуск судьи), глубина — вопрос 4 паразитной сложности на суде ревьюера · - · -

## Дельта

- К-08 · клетка · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --stabs · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --model · 0 · 0
- К-14 · клетка · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --model · 0 · 0
- К-15 · канон/инструмент · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --stabs · 0 · 0

Дельта по блоку Б-1 вердикта Rev208 (единственный блок: белый список D9b расходился
со списком резолвера — kodovaja_granica матчила glob `"$p" == .review/*`, резолвер
`^\.review/[A-Za-z0-9._-]+\.md$`; мир «вперёд» с публикацией, добавляющий только
`.review/zametki.txt`, получал отказ «не кодовая граница» rc 1 вместо допуска).
Строка о закрытии: БЛОК Б-1 ЗАКРЫТ одним предикатом verdikt_put для резолвера и D9b
плюс клетками r31/r32 и адресным стабом st44 — воспроизведение и закрытие командами rc
(вердикт ревьюера в дереве этой ветки не закоммичен, строка «ПРЕДЫДУЩИЙ ВЕРДИКТ:»
не заявлена — как в прецеденте круга c):

1. Воспроизведение отказа на двери дерева ДО правки (sha256 двери
   d79af60e82c7c698c35015f6289cf8cb3feb57e4b80a833e96930057aa588734):
   `bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo .`
   → rc 1, `SUBJEKT 208: KLETKI 35 KRASNYH 2`, красны РОВНО
   r31-review-txt-vperjod (rc 1 ≠ 0, stderr `ОТКАЗ: OBJECT_RASHODITSJA … но не
   кодовая граница — вердиктный хвост не становит…`) и r32-review-vlozhenyj-vperjod
   (то же на вложенном пути) — отказ шире решения, как в вердикте.
2. Закрытие на исправленной модели (та же команда с --model):
   `bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --model`
   → rc 0, `MODEL 208: KLETKI 35 KRASNYH 0` — r31/r32 допускают (rc 0, PUSCHEM,
   START с запрошенным OBJECT), контроли r33/r34/r35 держат прежний отказ
   («не кодовая граница» rc 1, учёт не изменён) — список не расширен и не сужен.
3. Адресный стаб (Н-39, привязка по коду): `--stabs` → rc 0, `STABY 208: SVJAZI 73
   ZHIVYH 0`; st44-glob-review-granicy заменяет в kodovaja_granica вызов
   verdikt_put на прежний glob (якорь кратности 1) и красит ровно связанные
   r31/r32 — возврат Б-1 различим.
4. Дверь правит implementer ПОСЛЕ этого круга побайтно к sha256 модели
   47de5c0244b548d275b268a0530f634e90a09e7224b8542bb2cbe1601826bdfe; строки модели
   для повтора (дифф против круга g — четыре замены, номера строк новой модели):

```
331:# [D45 verdict-path] Белый список вердиктных путей предмета — ОДИН предикат
332:# для резолвера и kodovaja_granica (инвариант 3: список D9b тот же, что у
333:# резолвера; третья копия грамматики разошлась — Б-1 Rev208).
334:verdikt_put() {  # <NNN> <path> → 0 вердиктный путь | 1 нет
335:  local n="$1" p="$2"
336:  [[ "$p" =~ ^verdicts/(critic|adversary|review)/contracts-$n(-[A-Za-z0-9._-]+)?\.md$ \
337:    || "$p" =~ ^\.review/[A-Za-z0-9._-]+\.md$ ]]
338:}
```

```
348:    verdikt_put "$n" "$p" \
349:      || { printf '%s\n' "$tip"; return 0; }
380:      verdikt_put "$n" "$p" || return 1
417:    verdikt_put "$n" "$p" || return 0
```

Способы: К-08 (клетка — st44 в матрице, ZHIVYH 0), К-09 (клетка — миры r31–r35:
r31 мир r05 с `.review/zametki.txt` — допуск rc 0 КАК у резолвера, r32 вложенный
`.review/sub/a.md` — допуск, контроли r33/r34/r35 — вердиктный `.review/zametki.md`
на предметах 208/209/003 даёт прежний отказ, миры 209/003 — урок Adv208 «не только
208»), К-14 (клетка — честные эквивалентные записи r33/r34/r35 зелены на модели и
маршрутом субъекта, прежние 30 клеток не изменились), К-15 (канон/инструмент — числа
из вывода движка и jq по source.json: 44 стаба, 73 связи, 35 клеток; census заморозки
НЕ менялся — stabs/ 39, второй каталог 5). Мутации ревьюера стали адресными стабами:
мир r31 ревьюера = клетка r31-review-txt-vperjod, контроль r32 ревьюера (равенство с
tip) покрыт инвариантом 1 резолвера (клетка r30 — резолв кандидата через хвост) и
допуском r31/r32, стаб возврата glob = st44.

## Ручная проба CRLF-мутанта (слой субъекта)

Дано: текст стаба st20 (модель, в `otp` формат `\r\n`; diff с моделью — одна строка 233)
размещён как `<корень>/scripts/zamok_predmeta.sh`, корень — scratch копии. Когда:
`bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo <корень>`.
Тогда: rc 1; stdout прогона (строки обрезаны после скобки длин: sha миров меняются от
прогона к прогону, смещения байтов — нет):
```
SUBJEKT 208: KLETKI 23 KRASNYH 12
KRASNAJA-KLETKA r04-predok-ne-opublikovan: r04: stderr байт-в-байт ≠ ожиданию: первое расхождение на байте 392 (факт 0x0d, ожидание 0x0a; длины 394/393);
KRASNAJA-KLETKA r06-vperjod-verdikt-hvost: r06: stderr байт-в-байт ≠ ожиданию: первое расхождение на байте 363 (факт 0x0d, ожидание 0x0a; длины 365/364);
KRASNAJA-KLETKA r07-vperjod-ne-opublikovan: r07: stderr байт-в-байт ≠ ожиданию: первое расхождение на байте 430 (факт 0x0d, ожидание 0x0a; длины 432/431);
KRASNAJA-KLETKA r10-mimo-novoj-raboty: r10: stderr байт-в-байт ≠ ожиданию: первое расхождение на байте 424 (факт 0x0d, ожидание 0x0a; длины 426/425);
KRASNAJA-KLETKA r12-sankcija-chuzhoj-object: r12: stderr байт-в-байт ≠ ожиданию: первое расхождение на байте 326 (факт 0x0d, ожидание 0x0a; длины 328/327);
KRASNAJA-KLETKA r13-sankcija-iscerpana: r13: stderr байт-в-байт ≠ ожиданию: первое расхождение на байте 326 (факт 0x0d, ожидание 0x0a; длины 328/327);
KRASNAJA-KLETKA r14-povtor-stroka-ne-dejstvuet: r14: stderr байт-в-байт ≠ ожиданию: первое расхождение на байте 326 (факт 0x0d, ожидание 0x0a; длины 328/327);
KRASNAJA-KLETKA r15-povtor-bez-razreshenija: r15: stderr байт-в-байт ≠ ожиданию: первое расхождение на байте 326 (факт 0x0d, ожидание 0x0a; длины 328/327);
KRASNAJA-KLETKA r16-pauza-vladelca: r16: stderr байт-в-байт ≠ ожиданию: первое расхождение на байте 123 (факт 0x0d, ожидание 0x0a; длины 125/124);
KRASNAJA-KLETKA r19-sankcija-chuzhoj-predmet: r19: stderr байт-в-байт ≠ ожиданию: первое расхождение на байте 326 (факт 0x0d, ожидание 0x0a; длины 328/327);
KRASNAJA-KLETKA r20-sankcija-chuzhaja-rol: r20: stderr байт-в-байт ≠ ожиданию: первое расхождение на байте 326 (факт 0x0d, ожидание 0x0a; длины 328/327);
KRASNAJA-KLETKA r21-sankcija-chuzhoj-repo: r21: stderr байт-в-байт ≠ ожиданию: первое расхождение на байте 326 (факт 0x0d, ожидание 0x0a; длины 328/327);
```
Контроль: та же команда с честной моделью в `<корень>` (diff с моделью пуст) → rc 0,
`SUBJEKT 208: KLETKI 23 KRASNYH 0`. До исправления: батарея OBJECT `36fea14f3d` на том же
мутанте → rc 0, `SUBJEKT 208: KLETKI 23 KRASNYH 0`, на честной модели → rc 0, 23/0 —
мутант неотличим; атака subject.py вердикта воспроизведена.

## Ручные пробы круга d (мутации константы предмета, слой субъекта)

Каждая мутация — ОДНА замена якоря кратности 1 в копии двери
`scripts/zamok_predmeta.sh` (grep -c якоря в модели = 1), корень — scratch;
команда `bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo <корень>`.
Честная дверь на тех же мирах зелёная (круг d): `--repo .` → rc 0.

| мутация | итог прогона | красные клетки |
|---|---|---|
| Adv208: `"refs/remotes/origin/wip/$n/"` → `"refs/remotes/origin/wip/208/"` (obj_opublikovan, круг d — строка 401 тогда) | rc 1, `SUBJEKT 208: KLETKI 30 KRASNYH 2` | r24-predok-209-opublikovan-v-vetke (209: отказ «не опубликован» вместо допуска, stdout/stderr/учёт), r25-vperjod-003-opublikovan-v-vetke (003: то же) |
| st41: `contracts-$n` → `contracts-208` в белом списке границы (круг d — строка 410 тогда) | rc 1, `KLETKI 30 KRASNYH 2` | r26/r27: rc 0 вместо 1 — вердиктный хвост 209/003 ДОПУЩЕН объектом суда, учёт переписан |
| st42: `.subjectId == $n` → `.subjectId == "208"` в sankcija_ucheta (круг d — строка 978 тогда) | rc 1, `KLETKI 30 KRASNYH 2` | r28: rc 1 вместо 0 — своя санкция 209 отвергнута; r29: rc 0 вместо 1 — чужая санкция 208 при суде 003 принята |
| st43: `object_kandidata "$r_wt" "$sv" "$r_br"` → `"208"` (вызов D9, круг d — строка 1339 тогда) | rc 1, `KLETKI 30 KRASNYH 1` | r30: rc 1 вместо 0 — равенство 209 через свой хвост отвергнуто «не опубликован» |

Контроль позитивный: без мутаций та же команда на двери дерева — rc 0 (30/0 в круге d);
прежние клетки r01–r23 на каждом мутанте зелёны (константа 208 == параметр на
предмете 208) — расхождение только на предметах ≠ 208.

## Ручная проба круга h (возврат glob, слой субъекта)

Мутация st44 — замена строки 417 модели `    verdikt_put "$n" "$p" || return 0` на
прежние две строки glob (якорь кратности 1, diff ровно одна замена). Корень — scratch
копии; команда `bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo <корень>`:
rc 1, `SUBJEKT 208: KLETKI 35 KRASNYH 2`, красны РОВНО r31-review-txt-vperjod и
r32-review-vlozhenyj-vperjod (отказ «не кодовая граница» rc 1 вместо допуска) —
та же картина, что на неизменённой двери дерева до правки (пункт 1 «## Дельта»), контроли
r33/r34/r35 и прочие 30 клеток зелены. Исполнение той же мутации матрицей —
`--stabs` (связи r31/r32, ZHIVYH 0).

## Самопроверка барьера (мутации проверяющего кода, scratch-копия пробы)

Каждая мутация — одна строка k_vyvod либо его обёртки; команда та же:
`bash <копия батареи>/red_zamok_object_predok_208.sh --stabs`. Без мутации — SVJAZI 73
ZHIVYH 0, rc 0.

| мутация | живые стабы (STAB_ZHIV) | число | rc |
|---|---|---|---|
| M1 нормализация CRLF и CR → LF до сравнения | st20, st21, st30, st31 | 4 | 1 |
| M2 сравнение по префиксу вместо полного равенства | st23, st27, st29, st33, st37, st39 | 6 | 1 |
| M3 труба с пустым ожиданием не судится | st29, st39 | 2 | 1 |
| M4 stdout не судится (k_stdout → None) | st29, st30, st31, st32, st33, st34, st35, st36, st37 | 9 | 1 |
| M5 stderr не судится (k_text → None) | st03, st05, st06, st10, st17, st18, st19, st20, st21, st22, st23, st24, st25, st26, st27, st39 | 16 | 1 |

## Таблица стабов

Источник: привязки — `fixtures/workshop_project/zamok_object_predok_208/source.json`
(.stab_vhod), мутация — diff файла стаба против модели (ровно одна якорная замена; общие префикс
и суффикс строки сняты, изменённая часть — в ⟦⟧, длинная сокращена до 46 символов с «…»,
окно — 14 символов до и 16 после; `\|` — литеральная вертикальная черта). Столбцы «стаб»
и «клетки» повторяются командой jq по source.json (44 строки, 73 связи;
st01–st39 лежат в stabs/, st40–st44 — в stabs-konstanty-208d/):
`jq -r '.stab_vhod | to_entries[] | "\(.key) | \(.value | join(", "))"' fixtures/workshop_project/zamok_object_predok_208/source.json`

| стаб | одна изменённая строка модели: было → стало | клетки |
|---|---|---|
| st01-ravenstvo-tolko | 1365:         if ⟦[ "$obj_fakt" = "$obj" ] && [ "$tip" != "$obj…⟧; then →         if ⟦false⟧; then | r04-predok-ne-opublikovan, r06-vperjod-verdikt-hvost, r07-vperjod-ne-opublikovan, r10-mimo-novoj-raboty |
| st02-predok-bez-publikacii | 1370:             ⟦obj_opublikovan "$r_wt" "$sv" "$obj"⟧ \|\| { →             ⟦true⟧ \|\| { | r04-predok-ne-opublikovan |
| st03-vperjod-bez-granicy | 1378:             ⟦kodovaja_granica "$r_wt" "$sv" "$obj"⟧ \|\| { →             ⟦true⟧ \|\| { | r06-vperjod-verdikt-hvost |
| st04-vperjod-bez-publikacii | 1382:             ⟦obj_opublikovan "$r_wt" "$sv" "$obj"⟧ \|\| { →             ⟦true⟧ \|\| { | r07-vperjod-ne-opublikovan |
| st05-merge-bez-pustoty | 1357: удалено              ⟦&& [ -z "$(puti_kommita "$r_wt" "$mtip")" ]⟧; then | r18-merge-verdikt-neodnoznachnyj |
| st06-merge-ljuboj-tip | 1356: … \| grep -Eq '^⟦[0-9a-f]{40}( [0-9a-f]{40})+⟧$' \ → … \| grep -Eq '^⟦.*⟧$' \ | r09-pustoj-ne-merge-tip |
| st07-sankcija-bez-object | 985: … == $roli and ⟦.object == $o⟧)' \ → … == $roli and ⟦true⟧)' \ | r12-sankcija-chuzhoj-object |
| st08-sankcija-bez-krugov | 1269:       if ⟦[ "$(krugov_suda "$sv" "$rol" "$obj")" = '1' ]⟧ \ →       if ⟦true⟧ \ | r13-sankcija-iscerpana |
| st09-stroka-kak-sankcija | 1270:          && ⟦sankcija_ucheta "$sv" "$rol" "$obj"⟧; then →          && ⟦{ sankcija_ucheta "$sv" "$rol" "$obj" \|\| grep…⟧; then | r14-povtor-stroka-ne-dejstvuet |
| st10-otkaz-bez-vyhoda | 1390: удалено …и $r_br ($tip)⟦ и не связан предковостью с работой последнег…⟧" | r10-mimo-novoj-raboty |
| st11-predki-pereputany | 1369: …is-ancestor "$⟦obj" "$tip⟧" 2>/dev/null; t… → …is-ancestor "$⟦tip" "$obj⟧" 2>/dev/null; t… | r02-predok-opublikovan-v-main, r03-predok-opublikovan-v-vetke, r23-porjadok-roditelej-merge |
| st12-publikacija-tolko-main | 408: вставка …/origin/wip/$n⟦-net⟧/") | r03-predok-opublikovan-v-vetke |
| st13-sankcija-bez-subjectid | 984: …oId == $r and ⟦.subjectId == $n⟧ → …oId == $r and ⟦true⟧ | r19-sankcija-chuzhoj-predmet |
| st14-sankcija-bez-roli | 985: …          and ⟦.rol == $roli⟧ and .object == … → …          and ⟦true⟧ and .object == … | r20-sankcija-chuzhaja-rol |
| st15-sankcija-bez-repo | 984: …SANKCIJA" and ⟦.repoId == $r⟧ and .subjectId … → …SANKCIJA" and ⟦true⟧ and .subjectId … | r21-sankcija-chuzhoj-repo |
| st16-predok-tolko-pervyj-roditel | 1369: …it -C "$r_wt" ⟦merge-base --is-ancestor "$obj" "$tip" 2>/dev…⟧; then → …it -C "$r_wt" ⟦rev-list --first-parent "$tip" 2>/dev/null \| …⟧; then | r22-predok-cherez-vtorogo-roditelja |
| st17-diagnostika-r04 | 1372: удалено …ржат); выход: ⟦fetch origin в носителе либо ⟧опубликовать раб… | r04-predok-ne-opublikovan |
| st18-diagnostika-r06 | 1380: …ом суда; выход⟦: OBJECT работы, не verdikt-комми⟧т" → …ом суда; выход⟦ отсутствуе⟧т" | r06-vperjod-verdikt-hvost |
| st19-diagnostika-r07 | 1384: …вать работу в ⟦main либо ветке wip/$sv/*⟧ на origin" → …вать работу в ⟦ветке wip/$sv/* либо в main⟧ на origin" | r07-vperjod-ne-opublikovan |
| st20-otkaz-crlf | 233: вставка …ОТКАЗ: %s: %s\⟦r\⟧n' "$1" "$2" >&2… | r04-predok-ne-opublikovan, r06-vperjod-verdikt-hvost, r07-vperjod-ne-opublikovan |
| st21-otkaz-odinochnyj-cr | 233: …ОТКАЗ: %s: %s\⟦n⟧' "$1" "$2" >&2;… → …ОТКАЗ: %s: %s\⟦r⟧' "$1" "$2" >&2;… | r04-predok-ne-opublikovan, r06-vperjod-verdikt-hvost, r07-vperjod-ne-opublikovan |
| st22-otkaz-probel-v-konce | 233: вставка …'ОТКАЗ: %s: %s⟦ ⟧\n' "$1" "$2" >&… | r04-predok-ne-opublikovan, r06-vperjod-verdikt-hvost, r07-vperjod-ne-opublikovan |
| st23-otkaz-dvojnoj-lf | 233: вставка …ТКАЗ: %s: %s\n⟦\n⟧' "$1" "$2" >&2;… | r04-predok-ne-opublikovan, r06-vperjod-verdikt-hvost, r07-vperjod-ne-opublikovan |
| st24-otkaz-bom | 233: вставка …()  { printf '⟦\xEF\xBB\xBF⟧ОТКАЗ: %s: %s\n'… | r04-predok-ne-opublikovan, r06-vperjod-verdikt-hvost, r07-vperjod-ne-opublikovan |
| st25-otkaz-nul | 233: вставка …ОТКАЗ: %s: %s\⟦x00\⟧n' "$1" "$2" >&2… | r04-predok-ne-opublikovan, r06-vperjod-verdikt-hvost, r07-vperjod-ne-opublikovan |
| st26-otkaz-ne-utf8 | 233: вставка …()  { printf '⟦\xFF⟧ОТКАЗ: %s: %s\n'… | r04-predok-ne-opublikovan, r06-vperjod-verdikt-hvost, r07-vperjod-ne-opublikovan |
| st27-otkaz-lishnij-vyvod | 233: вставка …ТКАЗ: %s: %s\n⟦LISHNJAJA stroka\n⟧' "$1" "$2" >&2;… | r04-predok-ne-opublikovan, r06-vperjod-verdikt-hvost, r07-vperjod-ne-opublikovan |
| st28-otkaz-perenos | 233: удалено …s\n' "$1" "$2"⟦ >&2⟧; exit 1; } | r04-predok-ne-opublikovan, r06-vperjod-verdikt-hvost, r07-vperjod-ne-opublikovan |
| st29-otkaz-lishnij-v-stdout | 233: вставка …$1" "$2" >&2; ⟦printf 'LISHNJAJA stroka\n'; ⟧exit 1; } | r04-predok-ne-opublikovan, r06-vperjod-verdikt-hvost, r07-vperjod-ne-opublikovan |
| st30-puschem-crlf | 1505: вставка …%s/%s (%s/%s)\⟦r\⟧n' "$name" "$REP… | r01-ravenstvo-dopusk |
| st31-puschem-odinochnyj-cr | 1505: …%s/%s (%s/%s)\⟦n⟧' "$name" "$RE… → …%s/%s (%s/%s)\⟦r⟧' "$name" "$RE… | r01-ravenstvo-dopusk |
| st32-puschem-probel-v-konce | 1505: вставка … %s/%s (%s/%s)⟦ ⟧\n' "$name" "$RE… | r01-ravenstvo-dopusk |
| st33-puschem-dvojnoj-lf | 1505: вставка …s/%s (%s/%s)\n⟦\n⟧' "$name" "$RE… | r01-ravenstvo-dopusk |
| st34-puschem-bom | 1505: вставка     printf '⟦\xEF\xBB\xBF⟧PUSCHEM %s %s/%s… | r01-ravenstvo-dopusk |
| st35-puschem-nul | 1505: вставка …%s/%s (%s/%s)\⟦x00\⟧n' "$name" "$REP… | r01-ravenstvo-dopusk |
| st36-puschem-ne-utf8 | 1505: вставка     printf '⟦\xFF⟧PUSCHEM %s %s/%s… | r01-ravenstvo-dopusk |
| st37-puschem-lishnij-vyvod | 1505: вставка …s/%s (%s/%s)\n⟦LISHNJAJA stroka\n⟧' "$name" "$RE… | r01-ravenstvo-dopusk |
| st38-puschem-perenos | 1505: вставка …$klass" "$rol"⟦ >&2⟧ | r01-ravenstvo-dopusk |
| st39-puschem-lishnij-v-stderr | 1505: вставка …$klass" "$rol"⟦; printf 'LISHNJAJA stroka\n' >&2⟧ | r01-ravenstvo-dopusk |
| st40-konstanta-publikacii-208 | 408: …origin/wip/⟦$n⟧/") → …origin/wip/⟦208⟧/") | r24-predok-209-opublikovan-v-vetke, r25-vperjod-003-opublikovan-v-vetke |
| st41-konstanta-granicy-208 | 336: …review)/⟦contracts-$n⟧(-[A-Za-z0-9._-]+)?\.md$ \ → …review)/⟦contracts-208⟧(-[A-Za-z0-9._-]+)?\.md$ \ (якорь — тело verdikt_put, грамматика теперь одна) | r26-vperjod-209-verdikt-hvost, r27-vperjod-003-verdikt-hvost |
| st42-konstanta-sankcii-208 | 984: …oId == $r and ⟦.subjectId == $n⟧ → …oId == $r and ⟦.subjectId == "208"⟧ | r28-sankcija-209-adresna, r29-sankcija-003-chuzhoj-predmet |
| st43-konstanta-kandidata-208 | 1345: tip="$(⟦object_kandidata "$r_wt" "$sv" "$r_br"⟧)" \|\| tip='' → tip="$(⟦object_kandidata "$r_wt" "208" "$r_br"⟧)" \|\| tip='' | r30-ravenstvo-209-cherez-verdikt-hvost |
| st44-glob-review-granicy | 417:     ⟦verdikt_put "$n" "$p" \|\| return 0⟧ →     ⟦[[ "$p" =~ ^verdicts/(critic\|adversary\|review)/contracts-$n(-[A-Za-z0-9._-]+)?\.md$ \⟧ + 418: ⟦      \|\| "$p" == .review/* ]] \|\| return 0⟧ (возврат glob Б-1 в kodovaja_granica) | r31-review-txt-vperjod, r32-review-vlozhenyj-vperjod |
