accept

Судимый предмет: HEAD `c268fc3d6257f9654aad7bb885d36b7e3d61c611`. Подтверждающий круг ограничен пунктами 1–7 решения `verdicts/arbitration/struktura-vs-ispolnjaemaja-proba.md:88-118`; закрытый вопрос «структура vs проба» не переоткрывался, новые обходы вне чек-листа не рассматривались.

1. СДЕЛАНО — общий helper сохраняет `full_out`, требует ожидаемый диагноз в full И scoped и сверяет `scoped_rc == full_rc`: `scripts/check_scoped_run.sh:317-328`; ветви (м1)/(м2)/(м3) передают закреплённые подстроки и дополнительно требуют ожидаемый итоговый код: `scripts/check_scoped_run.sh:330-353`. Контрпример v4 с одинаковым кодом 1, но full-выводом `ПОСТОРОННИЙ ОТКАЗ` и scoped-выводом `красное не предъявлено`, теперь отвергнут кодом 1: helper назвал отсутствие `красное не предъявлено` именно в полном выводе.
2. СДЕЛАНО — (н) исполняемо строит запись в `$REPO/tmp` вне `$WORK`: `scripts/check_scoped_run.sh:229-241`; тот же helper утверждает диагноз в обоих выводах и равенство кодов, а ветвь (н) вызывает его с `дерево изменилось`: `scripts/check_scoped_run.sh:317-328`, `scripts/check_scoped_run.sh:355-361`. V2 подтвердил full/scoped код 1 и диагноз.
3. СДЕЛАНО — диспетчеры обоих барьеров перечисляют допустимые ветви и отклоняют неизвестный WANT кодом 1 с его именем: `scripts/check_scope_select.sh:79-86`, `scripts/check_scoped_run.sh:290-297`. Оба прогона V3 с `ЗЗЗ` дали код 1 и назвали `ЗЗЗ`.
4. СДЕЛАНО — референсный раннер применяет case-фильтр внутри выбранного барьера: `fixtures/check_scoped_run/_ref_va.sh:168-195`, `fixtures/check_scoped_run/_ref_va.sh:316-326`; ветвь (case) требует ровно одну фикстуру, исключает вторую и отвергает отсутствующий case: `scripts/check_scoped_run.sh:363-378`. V2 прошёл.
5. СДЕЛАНО — `SCOPED:` на needs-full утверждается отдельно в ветвях (г) и (к), причём (к) различает обе моды: `scripts/check_scope_select.sh:114-120`, `scripts/check_scope_select.sh:177-192`. V1 прошёл.
6. СДЕЛАНО — ветвь (л) строит игрушку при доступном git, затем вызывает селектор с PATH без git и требует код 2 и `SCOPED:`: `scripts/check_scope_select.sh:193-209`; claim закреплён контрактом: `contracts/006-scoped-izolirovannyj-gejt.md:74-77`. V1 прошёл.
7. СДЕЛАНО — ветвь (л) явно требует `RC == 0`, один барьер b и отсутствие a: `scripts/check_scoped_run.sh:299-313`; §Предмет объявляет гарантией исполняемую пробу, а конструкцию — дизайн-требованием: `contracts/006-scoped-izolirovannyj-gejt.md:18-25`. V2 прошёл.

Блокирующих находок по суженному чек-листу нет.

Замеры обязательного набора:
- V1 `bash scripts/check_scope_select.sh "$PWD/tmp/006-red/root"` → 0; ветви (а)–(л) зелены.
- V2 на refroot, собранном из `fixtures/check_scoped_run/_ref_va.sh`: `bash scripts/check_scoped_run.sh "$PWD/tmp/val/refroot"` → 0; ветви (л)/(м1)/(м2)/(м3)/(н)/(case) зелены.
- V3 `bash scripts/check_scope_select.sh "$PWD/tmp/006-red/root" ЗЗЗ` → 1; `bash scripts/check_scoped_run.sh "$PWD/tmp/val/refroot" ЗЗЗ` → 1; оба отказа назвали `ЗЗЗ`.
- Контрпример v4: `bash scripts/check_scoped_run.sh "$PWD/tmp/probe-m1" м1` → 1 с диагнозом `полный прогон не назвал «красное не предъявлено»` и выводом `ПОСТОРОННИЙ ОТКАЗ`.
