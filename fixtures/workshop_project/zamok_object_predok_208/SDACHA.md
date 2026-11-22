# СДАЧА 208 — замок предмета: допуск судьи по предковости (D9) и санкция повтора

БАЗА круга b: сдача круга a `88f31852ed7293d66e9e584b15b49db0c240e1ff` (OBJECT FAIL
Crit208V1) + merge A2 контракта 140 (`378e45782e`, PR #1238, accept Rev140A2S) —
рабочая ветка wip/208/architect-b, OBJECT сдачи — потомок A2
(`git merge-base --is-ancestor 378e45782e HEAD` rc 0; дверь дерева ==
`378e45782e:scripts/zamok_predmeta.sh`, diff пуст).
Дельта круга b — по FAIL Crit208V1 (вердикт `9770601092f04d7e64f82f8d3a5bd134dea98a33`,
archive/208 станции; в дереве ветки не закоммичен — строку ПРЕДЫДУЩИЙ ВЕРДИКТ: не
заявляю, классы блоков перечислены ниже по тексту вердикта). Внешний scratch: TMPDIR,
удаляется после прогонов.

Предмет и существующее (кратко; полный текст — contracts/208-zamok-object-predok.md).
Обещание: судья допускается на OBJECT, связанный предковостью с кандидатом последнего
рабочего START и опубликованный (main либо ветка предмета на origin, в носителе), START
несёт запрошенный OBJECT; порядок родителей merge не меняет допуск; повтор роли на том
же OBJECT — только по записанной в учёте санкции SANKCIJA полного адреса при
неисчерпанном круге. Наблюдение — rc, ПОЛНЫЙ stdout и ПОЛНЫЙ stderr байт-в-байт в
КАЖДОМ режиме (модель, стабы, субъект; ожидания в памяти до вызова), START учёта при
допуске, неизменность учёта при отказе.
Существующее: дверь 140 в редакции A2 (v8…v13: предупреждения вместо отказов для
диагностических кодов, общая строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ЗАМОК, профильные пути
реестра/паузы) влита в базу merge'ом; резолвер общий с pre_judge/peredat и не меняется;
равенство, отказы реального вреда и предупреждения v8 вне предмета сохранены (клетки
r01/r09/r16-r18 зелены на производстве и на модели). Пересечение 140↔208 (отказы 208
для судейских D9/D11 поверх предупреждений v8) названо в контракте отдельным разделом и
в докладе — как вопрос оркестратору.

· `--repo .` → `SUBJEKT 208: KLETKI 23 KRASNYH 18`, rc 1; красные клетки производства
  (замер на двери A2): r02, r03, r04, r05, r06, r07, r08, r10, r11, r12, r13, r14,
  r15, r19, r20, r21, r22, r23; регрессионные r01/r09/r16/r17/r18 зелены.
· `--model` → `MODEL 208: KLETKI 23 KRASNYH 0`, rc 0.
· `--stabs` → `MODEL 208: KLETKI 23 KRASNYH 0`, `STABY 208: SVJAZI 24 ZHIVYH 0`, rc 0
  (19 стабов; мутации критика — адресные: sankcija без subjectId/rol/repoId, предок
  только по первому родителю, подмена выходов r04/r06/r07).
· Регресс на двери A2: 140 `--model` → `MODEL_KLETKI 244 KRASNYH 0`, rc 0;
  obryv_167 `--repo .` → rc 0; гигиена zamok_predmeta → `итог 4/4 классов закрыто`,
  rc 0.
· census: model/ = 1 файл, stabs/ = 19 каталогов (замеры контракта).

## Двери

- Red-do — живая дверь A2 до реализации · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo . · 1 · 1
- Model — эталон (A2 + блоки 208), все клетки · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --model · 0 · 0
- Stabs — матрица обманных дверей · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --stabs · 0 · 0
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

## Дельта

- К-03 · клетка · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo . · 1 · 1
- К-07 · клетка · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo . · 1 · 1
- К-08 · клетка · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --stabs · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --stabs · 0 · 0
- К-10 · клетка · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --stabs · 0 · 0
- К-14 · клетка · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --stabs · 0 · 0

Дельта по блокам (текст вердикта; способ — клетка):
К-03/К-07 (база A2): A2 `378e45782e` влит merge'ом, OBJECT — потомок A2; модель
перестроена с двери A2 (эталон = A2 + блоки D9/D11); регресс-клетки судят дверь A2 —
r01/r09/r16/r17/r18 зелены на `--repo .`, 18 production-клеток красны (SVJAZI 24,
ZHIVYH 0); регресс 140 — модель A2 244/0, гигиена 4/4.
К-08 (адрес санкции): клетки r19/r20/r21 (санкция с чужим subjectId=209 / rol=reviewer
/ repoId=other-repo → отказ OBJECT_UZHE_SUZHEN rc 1, полный вывод байт-в-байт) + ТРИ
адресных стаба st13/st14/st15 (по одному удалённому сравнению в sankcija_ucheta) —
пойманы `--stabs`.
К-09/К-14 (второй родитель): клетка r22 (OBJECT достижим только через второго родителя
merge — допуск, честная зелёная) + адресный стаб st16 (`rev-list --first-parent | grep
-Fxq` вместо merge-base) — пойман; в паре r23 — та же история с обратным порядком
родителей merge, решение не меняется; r23 дополнительно ловит st11.
К-10 (полный вывод субъекта): prognot_kletku судит rc + stdout + stderr байт-в-байт в
КАЖДОМ режиме (механизм strict/prefix удалён), ожидания в памяти до вызова субъекта;
адресные стабы st17/st18/st19 (подмена выхода r04, потеря выхода r06, перестановка
выхода r07) — пойманы `--stabs`.

## Карта классов

- К-01 · чисто · вход: двери листа прогоном (rc в рядах выше); рекурсия pre_critic разорвана штатным SDACHA_OKRUG=1; форма контракта — потолки, незаполненные требования, СДАЧА/ПРОВОДКА-строки · - · -
- К-02 · чисто · вход: слово владельца затравки PR #1232 (РАЗРЕШИЛ-ВЛАДЕЛЕЦ, дословно в КОНТЕКСТ), задание станции (task-arch208.md, дельта task-arch208b.md), боль консультанта дословно в §Существующее/§Предмет; sourceCanon отсутствует — режим проекта не объявлен · - · -
- К-03 · чисто · вход: A2 `378e45782e` влита merge'ом (потомок — rc 0), ПЕРЕСЕЧЕНИЕ 140/154/167/199 по scripts/zamok_predmeta.sh и 140 по профилю гигиены объявлены в контракте с базой A2; равенство (r01), предупреждения v8 вне предмета (r09/r17/r18) и оборванный круг (167, reg-167) не ослаблены · - · -
- К-04 · чисто · вход: файлы пачки только в architect-зоне (контракт + fixtures/workshop_project/zamok_object_predok_208/), census-замеры контракта сверяют состав (model 1 / stabs 19); производных файлов вне зоны нет; merge A2 вне diff круга a — файлы A2 · - · -
- К-05 · чисто · вход: каждая строка приёмки контракта — команда с rc (пробы Red-do/Model/Stabs/bash -n/регрессии; после реализации — fenced-блок гейтов ленда для оркестратора) · - · -
- К-06 · чисто · вход: rc 2 (нет git/jq/python3, ORACLE_TAMPERED, дрейф носителей, сломанный синтаксис мутации) не считается успехом; SUBJECT_ABSENT — rc 1 с перечнем входов · - · -
- К-07 · чисто · вход: Red-do судит поставленную дверь дерева (`scripts/zamok_predmeta.sh` по --repo; дерево == A2), не двойника; после реализации та же команда даёт rc 0 (безфлаговый и --repo равны) · - · -
- К-08 · чисто · вход: матрица обманных дверей над текстом модели — SVJAZI 24 ZHIVYH 0; каждая замена/удаление операции допуска (предковость, первый родитель, публикация, граница, merge-fallback, ПОЛНЫЙ адрес санкции — предмет/роль/repoId/OBJECT по отдельности, граница кругов, строка как ложная санкция, форма и тексты отказов) имеет краснеющую клетку из source.json:.stab_vhod · - · -
- К-09 · чисто · вход: виды конформных входов покрыты по клеткам — равенство r01, предок r02/r03/r04, предок через второго родителя r22, потомок r05/r06/r07, merge-пустой r08, merge с обратным порядком r23, пустой не-merge r09, расхождение r10, повтор r11-r15/r19-r21, необязательные поля (санкция с чужим адресом, круги 1/2) — каждая клетка своим предъявлением · - · -
- К-10 · чисто · вход: проверяется rc + ПОЛНЫЙ stdout и stderr байт-в-байт во ВСЕХ режимах (k_text/k_stdout без префиксного послабления субъекта), ожидания фиксируются до вызова; факт START/неизменность учёта; подстрока-где-угодно не используется · - · -
- К-11 · чисто · вход: оракул (source.json + ожидания в памяти) до вызова субъекта; носители — sha256 (дрейф = ORACLE_TAMPERED rc 2); миры в mktemp вне дерева субъекта · - · -
- К-12 · чисто · вход: факты git — plumbing (merge-base --is-ancestor, rev-list --first-parent только в стабе-мутанте, for-each-ref, rev-parse, show) самого git; событие — jq; самописного разбора истории/JSON нет · - · -
- К-13 · н/п · секретов во входах/выходах предмета нет (локальные миры, реестры станции, git-объекты) — белый список наружных строк не строится · - · -
- К-14 · чисто · вход: честные эквивалентные записи зелены на модели (23/23: равенство при живом предковости-допуске r01, повтор по санкции r11, предок через второго родителя r22, merge с обратным порядком родителей r23); каждая запрещающая мутация матрицы красит связанную клетку, свободных проходов нет (ZHIVYH 0) · - · -
- К-15 · чисто · вход: числа листа — из вывода движка (KLETKI/KRASNYH/SVJAZI/ZHIVYH/census/244/4-4); перечень клеток/связей — source.json, сверяется прогоном при каждом режиме (рассинхрон — rc 2) · - · -
- К-16 · чисто · вход: КЛАСС РИСКА: рисковый с основанием закрытого перечня (допуск судей); модель угроз по свойствам ЗАЩИЩАЕТ/НЕ ЗАЩИЩАЕТ, границы с ловцами (смена риска против слова 12:06 — вопрос оркестратору, преддверие 172, отдельный предмет done_contract.sh, судьи на живом дереве) · - · -
- К-17 · чисто · вход: правка существующей двери поверх принятой A2 без новых модулей; один наблюдаемый результат (допуск судьи), третий класс боли вынесен за границу предмета с обоснованием (§Существующее п.6); глубина — вопрос 4 паразитной сложности на суде ревьюера · - · -
