# СДАЧА 208 — замок предмета: вывод субъекта — байты обеих труб (К-10, круг c)

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

· `--repo .` → `SUBJEKT 208: KLETKI 23 KRASNYH 18`, rc 1; красные клетки производства
  (замер на двери A2): r02, r03, r04, r05, r06, r07, r08, r10, r11, r12, r13, r14, r15,
  r19, r20, r21, r22, r23; регрессионные r01/r09/r16/r17/r18 зелены.
· `--model` → `MODEL 208: KLETKI 23 KRASNYH 0`, rc 0.
· `--stabs` → `MODEL 208: KLETKI 23 KRASNYH 0`, `STABY 208: SVJAZI 64 ZHIVYH 0`, rc 0;
  стабов 39 (st01-st19 прежние, st20-st39 — границы наблюдения), связей 64 (40 новых).
· `--sintaksis` → `SINTAKSIS OK`, rc 0.
· Регресс на двери A2: 140 `--model` → `MODEL_KLETKI 244 KRASNYH 0`, rc 0; obryv_167
  `--repo .` → rc 0; гигиена zamok_predmeta → `итог 4/4 классов закрыто`, rc 0.
· census: model/ = 1 файл, stabs/ = 39 каталогов (замеры контракта).

## Двери

- Red-do — живая дверь A2 до реализации · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo . · 1 · 1
- Model — эталон (A2 + блоки 208), все клетки, обе трубы байтами · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --model · 0 · 0
- Stabs — матрица обманных дверей, SVJAZI 64 ZHIVYH 0 · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --stabs · 0 · 0
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
- К-04 · чисто · вход: файлы пачки только в architect-зоне (контракт + fixtures/workshop_project/zamok_object_predok_208/), census-замеры контракта сверяют состав (model 1 / stabs 39); производных файлов вне зоны нет; scratch прогонов удалён до коммита · - · -
- К-05 · чисто · вход: каждая строка приёмки контракта — правило, сценарий дано→когда→тогда либо команда с rc (пробы Red-do/Model/Stabs/bash -n/регрессии; после реализации — fenced-блок гейтов ленда для оркестратора) · - · -
- К-06 · чисто · вход: rc 2 (нет git/jq/python3, ORACLE_TAMPERED, дрейф носителей, сломанный синтаксис мутации) не считается успехом; SUBJECT_ABSENT — rc 1 с перечнем входов · - · -
- К-07 · чисто · вход: Red-do судит поставленную дверь дерева (`scripts/zamok_predmeta.sh` по --repo; дерево == A2), не двойника; после реализации та же команда даёт rc 0 (безфлаговый и --repo равны) · - · -
- К-08 · чисто · вход: матрица обманных дверей над текстом модели — SVJAZI 64 ZHIVYH 0; каждая замена/удаление операции допуска (предковость, первый родитель, публикация, граница, merge-fallback, ПОЛНЫЙ адрес санкции, граница кругов, строка как ложная санкция, форма и тексты отказов) и каждая граница наблюдения (восемь границ байтов на каждой трубе, перенос между трубами, лишняя строка в тихой трубе) имеет краснеющую клетку из source.json:.stab_vhod; каждый стаб отличается от модели ровно одной строкой · - · -
- К-09 · чисто · вход: виды конформных входов покрыты по клеткам — равенство r01, предок r02/r03/r04, предок через второго родителя r22, потомок r05/r06/r07, merge-пустой r08, merge с обратным порядком r23, пустой не-merge r09, расхождение r10, повтор r11-r15/r19-r21, необязательные поля (санкция с чужим адресом, круги 1/2) — каждая клетка своим предъявлением; границы вывода — каждая своим стабом на обеих трубах (st20-st39) · - · -
- К-10 · чисто · вход: наблюдение — (rc, stdout bytes, stderr bytes) с точным равенством во ВСЕХ режимах одним путём запуска (sudit → захват байтами, text-режима в пробе нет) и одним предикатом k_vyvod; ожидания в памяти до вызова; мутация критика (CRLF в otp) — стаб st20, соседи st21-st39: 40 связей красны, честная модель 23/0; слой субъекта: --repo <корень> с CRLF-мутантом — rc 1, 23/12 (r04, r06, r07 красны), с честной моделью — rc 0, 23/0 · - · -
- К-11 · чисто · вход: оракул (source.json + ожидания в памяти) до вызова субъекта; носители — sha256 (дрейф = ORACLE_TAMPERED rc 2); миры в mktemp вне дерева субъекта · - · -
- К-12 · чисто · вход: факты git — plumbing (merge-base --is-ancestor, rev-list --first-parent только в стабе-мутанте, for-each-ref, rev-parse, show) самого git; событие — jq; самописного разбора истории/JSON нет · - · -
- К-13 · н/п · секретов во входах/выходах предмета нет (локальные миры, реестры станции, git-объекты) — белый список наружных строк не строится · - · -
- К-14 · чисто · вход: честные эквивалентные записи зелёны на модели (23/23: равенство при живом предковости-допуске r01, повтор по санкции r11, предок через второго родителя r22, merge с обратным порядком родителей r23) и маршрутом субъекта (честная модель как scripts/zamok_predmeta.sh, --repo <корень> — 23/0); каждая запрещающая мутация матрицы красит связанную клетку, свободных проходов нет (ZHIVYH 0) · - · -
- К-15 · чисто · вход: числа листа и контракта — из вывода движка (KLETKI/KRASNYH/SVJAZI/ZHIVYH/census 1 и 39/244/4-4); таблица стабов листа напечатана из source.json:.stab_vhod и diff стаб↔модель, сверена с данными командой побайтово (39 строк, 64 связи); столбцы «стаб» и «клетки» повторяются jq по source.json · - · -
- К-16 · чисто · вход: КЛАСС РИСКА: рисковый с основанием закрытого перечня (допуск судей); модель угроз по свойствам ЗАЩИЩАЕТ/НЕ ЗАЩИЩАЕТ, границы с ловцами (смена риска против слова 12:06 — решено словом владельца 22.11, преддверие 172, отдельный предмет done_contract.sh, судьи на живом дереве, порядок строк между трубами — решение арбитра, побайтовая форма учёта) · - · -
- К-17 · чисто · вход: правка существующей двери поверх принятой A2 без новых модулей; один наблюдаемый результат (допуск судьи), третий класс боли вынесен за границу предмета с обоснованием (§Существующее п.6); глубина — вопрос 4 паразитной сложности на суде ревьюера · - · -

## Дельта

- К-08 · клетка · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --stabs · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --stabs · 0 · 0
- К-10 · клетка · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --stabs · 0 · 0
- К-14 · клетка · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --model · 0 · 0
- К-15 · канон/инструмент · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --stabs · 0 · 0

Дельта по блокам (вердикт Crit208V2 — блок К-10; соседние классы, которых коснулась
правка, объявлены рядами выше).
К-10 (способ клетка). Причина: субъект запускался в text-режиме (subprocess text=True,
universal newlines) — CRLF и CR становились LF до сравнения. Исправление в probe208.py
одним проходом: run() захватывает обе трубы байтами (text=True в коде — 0 вхождений по
grep 'text=True[,)]'; два оставшихся упоминания — комментарии); один предикат вывода
k_vyvod — полное равенство bytes на каждой трубе, без декодирования, перевода строк и
strip; декодирование errors='replace' — только текст диагностики; вывод git-plumbing — в
str через plumbing(); текст модели и стабы читаются и пишутся байтами (tekst_modeli,
write_bytes) — каждый стаб отличается от модели ровно одной строкой (проверено для всех
39); учёт читается байтами. model/ — bash, source.json — данные: text-режима нет. Мутация
критика (CRLF в otp) — адресный стаб st20, красный на r04, r06, r07; соседи по классу —
st21-st39: на каждую трубу (stderr/otp и stdout/PUSCHEM) восемь границ байтов (CRLF,
одиночный CR, пробел в конце, двойной LF, BOM, NUL, не-UTF8, лишний вывод), перенос между
трубами и лишняя строка в тихой трубе; привязки — только source.json:.stab_vhod (40 новых
связей, все красны). Слой субъекта: та же команда --repo <корень> на CRLF-мутанте — rc 1,
23/12, r04/r06/r07 красны (вывод ниже); до исправления (батарея OBJECT 36fea14f3d через
git archive в scratch) тот же мутант и честная модель давали одинаково rc 0, 23/0 — атака
воспроизведена и закрыта.
Двусторонность изменённого предиката: мутации проверяющего кода в scratch-копии каждая
красит --stabs (таблица самопроверки ниже), честная эквивалентная запись зелёная (--model
23/0; честная модель маршрутом субъекта --repo <корень> — 23/0).
К-08, К-09 (способ клетка): матрица выросла с 19 стабов и 24 связей до 39 и 64; каждая
новая граница наблюдения имеет свою краснеющую клетку; st17-st19 сохраняют силу при
байтовом сравнении (ZHIVYH 0).
К-14 (способ клетка): честная модель 23/0 на --model.
К-15 (способ канон/инструмент): числа контракта и листа — из вывода движка (SVJAZI 64,
ZHIVYH 0, census 39); таблица стабов листа — печать из source.json и diff стаб↔модель,
сверена с данными командой побайтово.
Границы (НЕ ЗАЩИЩАЕТ контракта — по решению арбитра и по соседней форме класса): временной
общий порядок строк между трубами не наблюдается (два PIPE, merged stream не вводится);
побайтовая форма строк учёта не судится (START — по полям JSON, отказ — по неизменности
файла). Блоки вердикта V1 (К-03/К-07, К-08, К-09/К-14), закрытые в круге b, в вердикте V2
— чисто; их доказательства не менялись.

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
и «клетки» повторяются командой jq по source.json (39 строк, 64 связи):
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
