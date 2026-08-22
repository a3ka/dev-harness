FAIL

Судимый предмет: HEAD `7a3ea8d9ecddc86c8bd423bf6c48aad9ea0bc516`. Подтверждающий круг ограничен пунктами 1–7 решения `verdicts/arbitration/struktura-vs-ispolnjaemaja-proba.md:88-118`; вопрос «структура vs проба» не переоткрывался.

1. НЕТ — `scripts/check_scoped_run.sh:317-325` сверяет `scoped_rc == full_rc`, но сохраняет и проверяет ожидаемую подстроку только в `scoped_out`; требование арбитра проверить диагноз в обоих выводах (`verdicts/arbitration/struktura-vs-ispolnjaemaja-proba.md:91-98`) не исполнено.
2. НЕТ — ветвь (н) построена исполняемо (`scripts/check_scoped_run.sh:229-241`, `scripts/check_scoped_run.sh:353-358`), но тот же общий helper `scripts/check_scoped_run.sh:317-325` не утверждает, что полный прогон отказал именно с диагнозом «дерево изменилось»; поэтому «тот же отказ, что полный» из `verdicts/arbitration/struktura-vs-ispolnjaemaja-proba.md:99-101` не доказан.
3. СДЕЛАНО — оба диспетчера перечисляют допустимые ветви и отклоняют неизвестный WANT кодом 1: `scripts/check_scope_select.sh:79-86`, `scripts/check_scoped_run.sh:290-297`; оба прогона V3 с `ЗЗЗ` дали код 1 и назвали ветвь.
4. СДЕЛАНО — `_ref_va.sh` применяет case-фильтр внутри выбранного барьера (`fixtures/check_scoped_run/_ref_va.sh:168-195`, `fixtures/check_scoped_run/_ref_va.sh:316-326`), а ветвь (case) утверждает ровно одну фикстуру и не-ноль для отсутствующего case (`scripts/check_scoped_run.sh:361-375`); V2 прошёл.
5. СДЕЛАНО — `SCOPED:` для needs-full проверяется отдельно в (г) и (к): `scripts/check_scope_select.sh:114-120`, `scripts/check_scope_select.sh:177-192`; V1 прошёл.
6. СДЕЛАНО — ветвь (л) строит игрушку до подмены PATH, затем вызывает селектор без `git` и требует код 2, не сужая claim: `scripts/check_scope_select.sh:193-209`, `contracts/006-scoped-izolirovannyj-gejt.md:74-77`; V1 прошёл.
7. СДЕЛАНО — (л) явно утверждает RC==0 (`scripts/check_scoped_run.sh:299-312`), а §Предмет объявляет гарантией исполняемую пробу (`contracts/006-scoped-izolirovannyj-gejt.md:18-25`); V2 прошёл.

БЛОКИРУЕТ contracts/006-scoped-izolirovannyj-gejt.md:91-98 — приёмка заявляет сохранение отказов (м1)/(м2)/(м3)/(н), но общий предикат `scripts/check_scoped_run.sh:317-325` после полного прогона сохраняет только `full_rc`, теряет его вывод и ищет ожидаемый диагноз лишь в scoped-выводе. Тем самым не исполнены пункты 1 и 2 чек-листа арбитра: равенство числового кода ещё не доказывает, что полный и scoped прогоны отказали по одному предмету.
ОБХОД: раннер в полном режиме печатает `ПОСТОРОННИЙ ОТКАЗ` и выходит 1, а с `--changed` печатает `красное не предъявлено` и тоже выходит 1. Точечная проба на этом раннере — `bash scripts/check_scoped_run.sh "$PWD/tmp/probe-m1" м1` — вернула 0 и напечатала `ok (м1)`, хотя ожидаемого диагноза в полном выводе не было. Тот же обход применим к (м2)/(м3)/(н): совпадает код 1, но не причина полного отказа.

Замеры обязательного набора:
- V1 `bash scripts/check_scope_select.sh "$PWD/tmp/006-red/root"` → 0, ветви (а)–(л) зелены.
- V2 на refroot из `fixtures/check_scoped_run/_ref_va.sh`: `bash scripts/check_scoped_run.sh "$PWD/tmp/val/refroot"` → 0, ветви (л)/(м1)/(м2)/(м3)/(н)/(case) зелены.
- V3: оба диспетчера с `ЗЗЗ` → 1.
