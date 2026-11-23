# СДАЧА 208 — замок предмета: вывод субъекта байтами обеих труб (К-10, круг c); адрес предмета параметризован — константа 208 различима (круг d, Adv208)

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
«stabs/* = 39» правкой батареи не трогается, проверено прогоном
check_spec_ready — 40-й каталог в stabs/ красит гейт «заявлено 39, команда
даёт 40»), source.json, этот лист. Производство scripts/zamok_predmeta.sh не
тронуто: sha256 прежний d79af60e82c7c698c35015f6289cf8cb3feb57e4b80a833e96930057aa588734,
все прежние клетки и стабы неизменны.

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
· Круг d (текущее состояние, прогон этого круга): `--model` → `MODEL 208: KLETKI 30
  KRASNYH 0`, rc 0 (23 прежние + r24–r30 на предметах 209/003); `--repo .` →
  `SUBJEKT 208: KLETKI 30 KRASNYH 0`, rc 0; `--stabs` → `STABY 208: SVJAZI 71
  ZHIVYH 0`, rc 0 — стабов 43 (st01–st39 прежние в stabs/, st40–st43 константы
  предмета в stabs-konstanty-208d/), связей 71 (7 новых: 2+2+2+1).
· `--sintaksis` → `SINTAKSIS OK`, rc 0.
· Регресс на двери A2: 140 `--model` → `MODEL_KLETKI 244 KRASNYH 0`, rc 0; obryv_167
  `--repo .` → rc 0; гигиена zamok_predmeta → `итог 4/4 классов закрыто`, rc 0.
· census: model/ = 1 файл, stabs/ = 39 каталогов (замеры контракта — не изменились),
  stabs-konstanty-208d/ = 4 каталога (вне замеров контракта; 40-й каталог в stabs/
  красит spec-гейт: «заявлено 39, команда даёт 40» — проверено прогоном).

## Двери

- Red-posle — живая дверь A2 после реализации 208 · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo . · 0 · 0
- Model — эталон (A2 + блоки 208), все клетки, обе трубы байтами · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --model · 0 · 0
- Stabs — матрица обманных дверей, SVJAZI 71 ZHIVYH 0 (st01-st39 в stabs/, st40-st43 в stabs-konstanty-208d/) · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --stabs · 0 · 0
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

- К-01 · чисто · вход: двери листа прогоном (rc в рядах выше); рекурсия pre_critic разорвана штатным SDACHA_OKRUG=1; форма контракта — потолки, незаполненные требования, СДАЧА/ПРОВОДКА-строки · - · -
- К-02 · чисто · вход: слово владельца затравки PR #1232 (РАЗРЕШИЛ-ВЛАДЕЛЕЦ, дословно в КОНТЕКСТ), задание станции (task-arch208.md, дельты task-arch208b.md и task-arch208c.md — блок К-10 и решение арбитра 208), боль консультанта дословно в §Существующее/§Предмет; sourceCanon отсутствует — режим проекта не объявлен · - · -
- К-03 · чисто · вход: A2 `378e45782e` влита merge'ом (потомок — rc 0), ПЕРЕСЕЧЕНИЕ 140/154/167/199 по scripts/zamok_predmeta.sh и 140 по профилю гигиены объявлены в контракте с базой A2; равенство (r01), предупреждения v8 вне предмета (r09/r17/r18) и оборванный круг (167, reg-167) не ослаблены; дверь дерева этим кругом не тронута · - · -
- К-04 · чисто · вход: файлы пачки только в architect-зоне (fixtures/workshop_project/zamok_object_predok_208/ этого круга: probe208.py, source.json, stabs-konstanty-208d/, лист), census-замеры контракта сверяют состав и НЕ изменились (model 1 / stabs 39: новые стабы круга d — в отдельном каталоге stabs-konstanty-208d/, 4 каталога, вне census-глоба заморозки); производных файлов вне зоны нет; scratch прогонов удалён до коммита · - · -
- К-05 · чисто · вход: каждая строка приёмки контракта — правило, сценарий дано→когда→тогда либо команда с rc (пробы Red-do/Model/Stabs/bash -n/регрессии; после реализации — fenced-блок гейтов ленда для оркестратора) · - · -
- К-06 · чисто · вход: rc 2 (нет git/jq/python3, ORACLE_TAMPERED, дрейф носителей, сломанный синтаксис мутации) не считается успехом; SUBJECT_ABSENT — rc 1 с перечнем входов · - · -
- К-07 · чисто · вход: Red-do судит поставленную дверь дерева (`scripts/zamok_predmeta.sh` по --repo; дерево == A2), не двойника; после реализации та же команда даёт rc 0 (безфлаговый и --repo равны) · - · -
- К-08 · чисто · вход: матрица обманных дверей над текстом модели — SVJAZI 71 ZHIVYH 0; каждая замена/удаление операции допуска (предковость, первый родитель, публикация, граница, merge-fallback, ПОЛНЫЙ адрес санкции, граница кругов, строка как ложная санкция, форма и тексты отказов, КОНСТАНТА ПРЕДМЕТА 208 вместо параметра адреса — публикация/граница/санкция/кандидат D9, Adv208) и каждая граница наблюдения (восемь границ байтов на каждой трубе, перенос между трубами, лишняя строка в тихой трубе) имеет краснеющую клетку из source.json:.stab_vhod; каждый стаб отличается от модели ровно одной строкой (якорь кратности 1) · - · -
- К-09 · чисто · вход: виды конформных входов покрыты по клеткам — равенство r01, предок r02/r03/r04, предок через второго родителя r22, потомок r05/r06/r07, merge-пустой r08, merge с обратным порядком r23, пустой не-merge r09, расхождение r10, повтор r11-r15/r19-r21, необязательные поля (санкция с чужим адресом, круги 1/2), КОНФОРМНЫЕ входы предметов ≠ 208 (грамматика [0-9]{3}: публикация ветки своего предмета r24/r25, вердиктный хвост своего предмета r26/r27, санкция полного адреса r28, чужой предмет r29, резолв кандидата через свой хвост r30) — каждая клетка своим предъявлением; границы вывода — каждая своим стабом на обеих трубах (st20-st39) · - · -
- К-10 · чисто · вход: наблюдение — (rc, stdout bytes, stderr bytes) с точным равенством во ВСЕХ режимах одним путём запуска (sudit → захват байтами, text-режима в пробе нет) и одним предикатом k_vyvod; ожидания в памяти до вызова; мутация критика (CRLF в otp) — стаб st20, соседи st21-st39: 40 связей красны, честная модель 23/0; слой субъекта: --repo <корень> с CRLF-мутантом — rc 1, 23/12 (r04, r06, r07 красны), с честной моделью — rc 0, 23/0 · - · -
- К-11 · чисто · вход: оракул (source.json + ожидания в памяти) до вызова субъекта; носители — sha256 (дрейф = ORACLE_TAMPERED rc 2); миры в mktemp вне дерева субъекта · - · -
- К-12 · чисто · вход: факты git — plumbing (merge-base --is-ancestor, rev-list --first-parent только в стабе-мутанте, for-each-ref, rev-parse, show) самого git; событие — jq; самописного разбора истории/JSON нет · - · -
- К-13 · н/п · секретов во входах/выходах предмета нет (локальные миры, реестры станции, git-объекты) — белый список наружных строк не строится · - · -
- К-14 · чисто · вход: честные эквивалентные записи зелёны на модели (30/30: равенство при живом предковости-допуске r01, повтор по санкции r11, предок через второго родителя r22, merge с обратным порядком родителей r23, допуск предмета 209/003 r24/r25/r28/r30) и маршрутом субъекта (дверь дерева, --repo . — 30/0); каждая запрещающая мутация матрицы красит связанную клетку, свободных проходов нет (ZHIVYH 0) · - · -
- К-15 · чисто · вход: числа листа и контракта — из вывода движка (KLETKI/KRASNYH/SVJAZI/ZHIVYH: 30/0, 71/0; census контракта 1 и 39 — без изменений, второй каталог 4 — из ls | wc -l); таблица стабов листа напечатана из source.json:.stab_vhod и diff стаб↔модель, сверена с данными командой побайтово (43 строки, 71 связь); столбцы «стаб» и «клетки» повторяются jq по source.json · - · -
- К-16 · чисто · вход: КЛАСС РИСКА: рисковый с основанием закрытого перечня (допуск судей); модель угроз по свойствам ЗАЩИЩАЕТ/НЕ ЗАЩИЩАЕТ, границы с ловцами (смена риска против слова 12:06 — решено словом владельца 22.11, преддверие 172, отдельный предмет done_contract.sh, судьи на живом дереве, порядок строк между трубами — решение арбитра, побайтовая форма учёта) · - · -
- К-17 · чисто · вход: правка существующей двери поверх принятой A2 без новых модулей; один наблюдаемый результат (допуск судьи), третий класс боли вынесен за границу предмета с обоснованием (§Существующее п.6); глубина — вопрос 4 паразитной сложности на суде ревьюера · - · -

## Дельта

- К-08 · клетка · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --stabs · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --stabs · 0 · 0
- К-14 · клетка · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --model · 0 · 0
- К-15 · канон/инструмент · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --stabs · 0 · 0

Дельта по блоку (вердикт Adv208 — один блок «ложная достаточность проверки
универсальной публикации в ветке предмета»: замена `"refs/remotes/origin/wip/$n/"`
на константу `"refs/remotes/origin/wip/208/"` (одна, якорь кратности 1) проходила
батарею 23/0 и профиль гигиены 4/4; закрывающее свойство вердикта — различать
параметризованную публикацию и фиксированный чужой номер минимум на двух
предметах, сохраняя позитивный контроль). Круг c (К-10 Crit208V2, байты труб)
закрыт прежним кругом — его доказательства (разделы ниже) не менялись.
К-08, К-09 (способ клетка). Места входа номера предмета в проверки D9/D11,
найденные по коду (Н-39): obj_opublikovan:401 (ref-путь `wip/$n/`),
kodovaja_granica:410 (белый список `contracts-$n`), sankcija_ucheta:978
(`.subjectId == $n`), вызов кандидата D9 `object_kandidata "$r_wt" "$sv" "$r_br"`
(строка блока D9); merge-порядок D9c номера предмета не несёт — клетка/стаб не
требуются (записано причиной). Внутренности object_kandidata (340/372) — резолвер
A2, инвариант 1 контракта держит его неизменным; его вход в D9 закрыт стабом
вызова (st43). Клетки r24–r30 — миры предметов 209 и 003 (формат NNN, та же
грамматика события и миров): r24 (предок 209 опубликован в wip/209/*), r25
(кодовая граница 003 опубликована в wip/003/*), r26/r27 (вердиктный хвост
своего предмета впереди — отказ), r28 (санкция полного адреса 209 — допуск),
r29 (санкция subjectId 208 при суде 003 — отказ), r30 (кандидат 209,
резолвленный через хвост 209, — равенство, допуск без публикации). Стабы
st40–st43 — по одному на место, якорь кратности 1 (grep -c модели = 1),
каталог stabs-konstanty-208d/ (census заморозки «stabs/* = 39» не тронут);
каждый красит связанные клетки: SVJAZI 71 ZHIVYH 0. Мутация Adv208 вручную на
копии двери — rc 1, KLETKI 30 KRASNYH 2, красны ровно r24/r25 (вывод ниже);
опасное направление доказано: st41 допускает вердиктный хвост 209/003 (r26/r27
rc 0 вместо 1, учёт переписан), st42 допускает чужую санкцию 208 при суде 003
(r29 rc 0 вместо 1) и ломает свою санкцию 209 (r28 rc 1 вместо 0), st43
отказывает в равенстве 209 (r30 rc 1 вместо 0). Позитивный контроль: дверь не
менялась (sha256 d79af60e…), прежние 23 клетки зелены, --repo . 30/0.
Эквивалентность вызовов: подмена параметра константой на ВЫЗОВЕ помощника
(`obj_opublikovan "$r_wt" "208" …`, `sankcija_ucheta "208" …`) наблюдаемо
идентична стабам помощников на тех же клетках r24–r29 — дублирующие стабы не
чеканены.
К-14 (способ клетка): честная модель 30/0 на --model; конформные входы 209/003
зелены маршрутом субъекта (--repo . 30/0).
К-15 (способ канон/инструмент): числа — из вывода движка (KLETKI 30, SVJAZI 71,
ZHIVYH 0) и `ls -d … | wc -l` (stabs/ 39 — без изменений, stabs-konstanty-208d/
4); census заморозки НЕ менялся — 40-й каталог в stabs/ красит spec-гейт
(«заявлено 39, команда даёт 40»), поэтому новые стабы лежат во втором каталоге,
общем source.json.

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
Честная дверь на тех же мирах зелёная: `--repo .` → rc 0, `SUBJEKT 208: KLETKI 30 KRASNYH 0`.

| мутация | итог прогона | красные клетки |
|---|---|---|
| Adv208: `"refs/remotes/origin/wip/$n/"` → `"refs/remotes/origin/wip/208/"` (obj_opublikovan:401) | rc 1, `SUBJEKT 208: KLETKI 30 KRASNYH 2` | r24-predok-209-opublikovan-v-vetke (209: отказ «не опубликован» вместо допуска, stdout/stderr/учёт), r25-vperjod-003-opublikovan-v-vetke (003: то же) |
| st41: `contracts-$n` → `contracts-208` в белом списке kodovaja_granica:410 | rc 1, `KLETKI 30 KRASNYH 2` | r26/r27: rc 0 вместо 1 — вердиктный хвост 209/003 ДОПУЩЕН объектом суда, учёт переписан |
| st42: `.subjectId == $n` → `.subjectId == "208"` в sankcija_ucheta:978 | rc 1, `KLETKI 30 KRASNYH 2` | r28: rc 1 вместо 0 — своя санкция 209 отвергнута; r29: rc 0 вместо 1 — чужая санкция 208 при суде 003 принята |
| st43: `object_kandidata "$r_wt" "$sv" "$r_br"` → `"208"` (вызов D9:1339) | rc 1, `KLETKI 30 KRASNYH 1` | r30: rc 1 вместо 0 — равенство 209 через свой хвост отвергнуто «не опубликован» |

Контроль позитивный: без мутаций та же команда на двери дерева — rc 0 (30/0);
прежние клетки r01–r23 на каждом мутанте зелёны (константа 208 == параметр на
предмете 208) — расхождение только на предметах ≠ 208.

## Самопроверка барьера (мутации проверяющего кода, scratch-копия пробы)

Каждая мутация — одна строка k_vyvod либо его обёртки; команда та же:
`bash <копия батареи>/red_zamok_object_predok_208.sh --stabs`. Без мутации — SVJAZI 64
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
(.stab_vhod), мутация — diff файла стаба против модели (ровно одна строка; общие префикс
и суффикс строки сняты, изменённая часть — в ⟦⟧, длинная сокращена до 46 символов с «…»,
окно — 14 символов до и 16 после; `\|` — литеральная вертикальная черта). Столбцы «стаб»
и «клетки» повторяются командой jq по source.json (43 строки, 71 связь;
st01–st39 лежат в stabs/, st40–st43 — в stabs-konstanty-208d/):
`jq -r '.stab_vhod | to_entries[] | "\(.key) | \(.value | join(", "))"' fixtures/workshop_project/zamok_object_predok_208/source.json`

| стаб | одна изменённая строка модели: было → стало | клетки |
|---|---|---|
| st01-ravenstvo-tolko | 1359:         if ⟦[ "$obj_fakt" = "$obj" ] && [ "$tip" != "$obj…⟧; then →         if ⟦false⟧; then | r04-predok-ne-opublikovan, r06-vperjod-verdikt-hvost, r07-vperjod-ne-opublikovan, r10-mimo-novoj-raboty |
| st02-predok-bez-publikacii | 1364:             ⟦obj_opublikovan "$r_wt" "$sv" "$obj"⟧ \|\| { →             ⟦true⟧ \|\| { | r04-predok-ne-opublikovan |
| st03-vperjod-bez-granicy | 1372:             ⟦kodovaja_granica "$r_wt" "$sv" "$obj"⟧ \|\| { →             ⟦true⟧ \|\| { | r06-vperjod-verdikt-hvost |
| st04-vperjod-bez-publikacii | 1376:             ⟦obj_opublikovan "$r_wt" "$sv" "$obj"⟧ \|\| { →             ⟦true⟧ \|\| { | r07-vperjod-ne-opublikovan |
| st05-merge-bez-pustoty | 1351: удалено              ⟦&& [ -z "$(puti_kommita "$r_wt" "$mtip")" ]⟧; then | r18-merge-verdikt-neodnoznachnyj |
| st06-merge-ljuboj-tip | 1350: … \| grep -Eq '^⟦[0-9a-f]{40}( [0-9a-f]{40})+⟧$' \ → … \| grep -Eq '^⟦.*⟧$' \ | r09-pustoj-ne-merge-tip |
| st07-sankcija-bez-object | 979: … == $roli and ⟦.object == $o⟧)' \ → … == $roli and ⟦true⟧)' \ | r12-sankcija-chuzhoj-object |
| st08-sankcija-bez-krugov | 1263:       if ⟦[ "$(krugov_suda "$sv" "$rol" "$obj")" = '1' ]⟧ \ →       if ⟦true⟧ \ | r13-sankcija-iscerpana |
| st09-stroka-kak-sankcija | 1264:          && ⟦sankcija_ucheta "$sv" "$rol" "$obj"⟧; then →          && ⟦{ sankcija_ucheta "$sv" "$rol" "$obj" \|\| grep…⟧; then | r14-povtor-stroka-ne-dejstvuet |
| st10-otkaz-bez-vyhoda | 1384: удалено …и $r_br ($tip)⟦ и не связан предковостью с работой последнег…⟧" | r10-mimo-novoj-raboty |
| st11-predki-pereputany | 1363: …is-ancestor "$⟦obj" "$tip⟧" 2>/dev/null; t… → …is-ancestor "$⟦tip" "$obj⟧" 2>/dev/null; t… | r02-predok-opublikovan-v-main, r03-predok-opublikovan-v-vetke, r23-porjadok-roditelej-merge |
| st12-publikacija-tolko-main | 401: вставка …/origin/wip/$n⟦-net⟧/") | r03-predok-opublikovan-v-vetke |
| st13-sankcija-bez-subjectid | 978: …oId == $r and ⟦.subjectId == $n⟧ → …oId == $r and ⟦true⟧ | r19-sankcija-chuzhoj-predmet |
| st14-sankcija-bez-roli | 979: …          and ⟦.rol == $roli⟧ and .object == … → …          and ⟦true⟧ and .object == … | r20-sankcija-chuzhaja-rol |
| st15-sankcija-bez-repo | 978: …SANKCIJA" and ⟦.repoId == $r⟧ and .subjectId … → …SANKCIJA" and ⟦true⟧ and .subjectId … | r21-sankcija-chuzhoj-repo |
| st16-predok-tolko-pervyj-roditel | 1363: …it -C "$r_wt" ⟦merge-base --is-ancestor "$obj" "$tip" 2>/dev…⟧; then → …it -C "$r_wt" ⟦rev-list --first-parent "$tip" 2>/dev/null \| …⟧; then | r22-predok-cherez-vtorogo-roditelja |
| st17-diagnostika-r04 | 1366: удалено …ржат); выход: ⟦fetch origin в носителе либо ⟧опубликовать раб… | r04-predok-ne-opublikovan |
| st18-diagnostika-r06 | 1374: …ом суда; выход⟦: OBJECT работы, не verdikt-комми⟧т" → …ом суда; выход⟦ отсутствуе⟧т" | r06-vperjod-verdikt-hvost |
| st19-diagnostika-r07 | 1378: …вать работу в ⟦main либо ветке wip/$sv/*⟧ на origin" → …вать работу в ⟦ветке wip/$sv/* либо в main⟧ на origin" | r07-vperjod-ne-opublikovan |
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
| st30-puschem-crlf | 1499: вставка …%s/%s (%s/%s)\⟦r\⟧n' "$name" "$REP… | r01-ravenstvo-dopusk |
| st31-puschem-odinochnyj-cr | 1499: …%s/%s (%s/%s)\⟦n⟧' "$name" "$REPO… → …%s/%s (%s/%s)\⟦r⟧' "$name" "$REPO… | r01-ravenstvo-dopusk |
| st32-puschem-probel-v-konce | 1499: вставка … %s/%s (%s/%s)⟦ ⟧\n' "$name" "$RE… | r01-ravenstvo-dopusk |
| st33-puschem-dvojnoj-lf | 1499: вставка …s/%s (%s/%s)\n⟦\n⟧' "$name" "$REPO… | r01-ravenstvo-dopusk |
| st34-puschem-bom | 1499: вставка     printf '⟦\xEF\xBB\xBF⟧PUSCHEM %s %s/%s… | r01-ravenstvo-dopusk |
| st35-puschem-nul | 1499: вставка …%s/%s (%s/%s)\⟦x00\⟧n' "$name" "$REP… | r01-ravenstvo-dopusk |
| st36-puschem-ne-utf8 | 1499: вставка     printf '⟦\xFF⟧PUSCHEM %s %s/%s… | r01-ravenstvo-dopusk |
| st37-puschem-lishnij-vyvod | 1499: вставка …s/%s (%s/%s)\n⟦LISHNJAJA stroka\n⟧' "$name" "$REPO… | r01-ravenstvo-dopusk |
| st38-puschem-perenos | 1499: вставка …$klass" "$rol"⟦ >&2⟧ | r01-ravenstvo-dopusk |
| st39-puschem-lishnij-v-stderr | 1499: вставка …$klass" "$rol"⟦; printf 'LISHNJAJA stroka\n' >&2⟧ | r01-ravenstvo-dopusk |
| st40-konstanta-publikacii-208 | 401: …origin/wip/⟦$n⟧/") → …origin/wip/⟦208⟧/") | r24-predok-209-opublikovan-v-vetke, r25-vperjod-003-opublikovan-v-vetke |
| st41-konstanta-granicy-208 | 410: …review)/⟦contracts-$n⟧(-[A-Za-z0-9._-]+)?\.md$ \ → …review)/⟦contracts-208⟧(-[A-Za-z0-9._-]+)?\.md$ \ | r26-vperjod-209-verdikt-hvost, r27-vperjod-003-verdikt-hvost |
| st42-konstanta-sankcii-208 | 978: …oId == $r and ⟦.subjectId == $n⟧ → …oId == $r and ⟦.subjectId == "208"⟧ | r28-sankcija-209-adresna, r29-sankcija-003-chuzhoj-predmet |
| st43-konstanta-kandidata-208 | 1339: tip="$(⟦object_kandidata "$r_wt" "$sv" "$r_br"⟧)" \|\| tip='' → tip="$(⟦object_kandidata "$r_wt" "208" "$r_br"⟧)" \|\| tip='' | r30-ravenstvo-209-cherez-verdikt-hvost |
