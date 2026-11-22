# СДАЧА 208 — замок предмета: допуск судьи по предковости (D9) и санкция повтора

БАЗА: b8ecb80533413dd3d4bddf85ea01a6ab852f2399 (origin/main; ветка wip/208/architect-a).
Первый круг нового предмета: предыдущего вердикта нет, «## Дельта» пуст.
Рабочая копия: /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tc4936175c/m
Внешний scratch: .scratch-208 (TMPDIR, абсолютный путь), удаляется после прогонов.

Предмет и существующее (кратко; полный текст — contracts/208-zamok-object-predok.md).
Обещание: судья допускается на OBJECT, связанный предковостью с кандидатом
последнего рабочего START и опубликованный (main либо ветка предмета на
origin, в носителе); порядок родителей merge не меняет допуск; повтор роли
на том же OBJECT — строка задания 21.11 00:55 ИЛИ записанная в учёте санкция
SANKCIJA при неисчерпанном круге. Наблюдение — rc двери и полный stderr
(производственный слой: rc + имя отказа; модель: rc + текст байт-в-байт),
START учёта при допуске, неизменность учёта при отказе.
Существующее: дверь 140 (frozen 5) с равенством D9 и повтором D11 стоит в
scripts/zamok_predmeta.sh; резолвер общий с pre_judge/peredat и не меняется;
равенство, D50, ПАУЗА, VETKA_NEDOSTUPNA и грамматика OBJECT сохранены
(клетки r01/r09/r16-r18 зелены на производстве и на модели). Пересечение с
140 A2 (PR #1238) объявлено в контракте; реализация 208 — после ленда A2.

· `--repo .` → `SUBJEKT 208: KLETKI 18 KRASNYH 5`, rc 1; красные клетки:
  r02-predok-opublikovan-v-main, r03-predok-opublikovan-v-vetke,
  r05-vperjod-opublikovan, r08-merge-pustaja-delta, r11-sankcija-v-uchete.
· `--model` → `MODEL 208: KLETKI 18 KRASNYH 0`, rc 0.
· `--stabs` → `MODEL 208: KLETKI 18 KRASNYH 0`, `STABY 208: SVJAZI 16 ZHIVYH 0`, rc 0.
· Регресс: 140 `--model` → `MODEL_KLETKI 172 KRASNYH 0`, rc 0;
  obryv_167 `--repo .` → rc 0; гигиена zamok_predmeta → `итог 4/4 классов закрыто`, rc 0.
· census: model/ = 1 файл, stabs/ = 12 каталогов (замеры контракта).

## Двери

- Red-do — живая дверь до реализации · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo . · 1 · 1
- Model — эталон, все клетки · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --model · 0 · 0
- Stabs — матрица обманных дверей · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --stabs · 0 · 0
- Sintaksis — модель и субъект-носители · bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --sintaksis · 0 · 0
- Reg-140-model — семья замка целиком · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model · 0 · 0
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
- К-02 · чисто · вход: слово владельца затравки PR #1232 (РАЗРЕШИЛ-ВЛАДЕЛЕЦ, дословно в КОНТЕКСТ), задание станции, боль консультанта дословно в §Существующее/§Предмет; sourceCanon отсутствует — режим проекта не объявлен · - · -
- К-03 · чисто · вход: ПЕРЕСЕЧЕНИЕ 140/154/167/199 по scripts/zamok_predmeta.sh и 140 по профилю гигиены объявлены в контракте; замороженные равенство (r01), D50 одиночного коммита (r09), повтор по строке 00:55 (r14) и оборванный круг (167, reg-167) не ослаблены · - · -
- К-04 · чисто · вход: файлы пачки только в architect-зоне (контракт + fixtures/workshop_project/zamok_object_predok_208/), census-замеры контракта сверяют состав; производных файлов вне зоны нет · - · -
- К-05 · чисто · вход: каждая строка приёмки контракта — команда с rc (пробы Red-do/Model/Stabs/bash -n/регрессии; после реализации — fenced-блок гейтов ленда для оркестратора) · - · -
- К-06 · чисто · вход: rc 2 (нет git/jq/python3, ORACLE_TAMPERED, дрейф носителей, сломанный синтаксис мутации) не считается успехом; SUBJECT_ABSENT — rc 1 с перечнем входов · - · -
- К-07 · чисто · вход: Red-do судит поставленную дверь дерева (`scripts/zamok_predmeta.sh` по --repo), не двойника; после реализации та же команда даёт rc 0 (безфлаговый и --repo равны) · - · -
- К-08 · чисто · вход: матрица обманных дверей над текстом модели — SVJAZI 16 ZHIVYH 0; каждая замена/удаление операции допуска (предковость, публикация, граница, merge-fallback, сверка санкции, граница кругов, строка 00:55, форма отказа) имеет краснеющую клетку из source.json:.stab_vhod · - · -
- К-09 · чисто · вход: виды конформных входов покрыты по клеткам — равенство r01, предок r02/r03/r04, потомок r05/r06/r07, merge-пустой r08, пустой не-merge r09, расхождение r10, повтор r11-r15, необязательные поля (строка задания, санкция, круги 1/2) — каждая клетка своим предъявлением · - · -
- К-10 · чисто · вход: проверяется rc + полный вывод (модель — stderr байт-в-байт с ожиданием, k_text) + факт START/неизменность учёта; подстрока-где-угодно не используется · - · -
- К-11 · чисто · вход: оракул (source.json + ожидания в памяти) до вызова субъекта; носители — sha256 (дрейф = ORACLE_TAMPERED rc 2); миры в mktemp вне дерева субъекта · - · -
- К-12 · чисто · вход: факты git — plumbing (merge-base --is-ancestor, for-each-ref, rev-parse, show) самого git; событие — jq; самописного разбора истории/JSON нет; буквы отказа сравниваются по префиксу первой строки · - · -
- К-13 · н/п · секретов во входах/выходах предмета нет (локальные миры, реестры станции, git-объекты) — белый список наружных строк не строится · - · -
- К-14 · чисто · вход: честные эквивалентные записи зелены на модели (18/18: равенство при живом предковости-допуске r01, повтор по строке при живой санкции r14); каждая запрещающая мутация матрицы красит связанную клетку, свободных проходов нет (ZHIVYH 0) · - · -
- К-15 · чисто · вход: числа листа — из вывода движка (KLETKI/KRASNYH/SVJAZI/ZHIVYH/census); перечень клеток/связей — source.json, сверяется прогоном при каждом режиме (рассинхрон — rc 2) · - · -
- К-16 · чисто · вход: КЛАСС РИСКА: рисковый с основанием закрытого перечня (допуск судей); модель угроз по свойствам ЗАЩИЩАЕТ/НЕ ЗАЩИЩАЕТ, границы с ловцами (преддверие 172, отдельный предмет done_contract.sh, судьи на живом дереве) · - · -
- К-17 · чисто · вход: правка существующей двери без новых модулей; один наблюдаемый результат (допуск судьи), третий класс боли вынесен за границу предмета с обоснованием (§Существующее п.6); глубина — вопрос 4 паразитной сложности на суде ревьюера · - · -
