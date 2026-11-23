# Контракт 211 — D52-bootstrap на reviewer/adversary: класс риска из дерева OBJECT при локальном frozen-теге с тем же tag-object (D64)

КЛАСС РИСКА: рисковый — дверь замка предмета решает, каким судьям реализации (reviewer/adversary) известен класс риска предмета; ошибка занижает рисковый предмет до обычного (ревьюер без адверсария) либо навсегда держит предмет в «неизвестном риске» (порядок судей и записи учёта искажены); основание закрытого перечня: «безопасность/авторизация» (периметр допуска судей и порядок adversary → reviewer).

ПРОДУКТ: станция

КОНТЕКСТ: номер 211 выдан `next_id` (тег `id/CONTRACT/211` = `db1359620ca3e85042fc7d8935152429381f048a`, строка реестра `ba33f7b9b8`); затравка консультанта/станции в клоне пары (также `/tmp/dev-harness-verify/consultant/draft-211-d52-bootstrap-sudej.md`) — черновик-bootstrap, заменена этим контрактом целиком; слово владельца 22.11 (через консультанта 00:26 UTC, дословно): «Двери судей агента — ВАРИАНТ А: продолжение D52-bootstrap на reviewer/adversary (класс риска из дерева OBJECT при локальном frozen-теге с тем же tag-object)»; задание станции `/tmp/dev-harness-verify/task-arch211.md`; исправительный круг по вердикту критика вызов 1 (три блока: корень чтения legacy-реестра и профиля, устаревшая база модели, числа и указатели базы) — `/tmp/dev-harness-verify/task-arch211b.md`. Н-39 дословно: стабы к ветвям привязывает architect по коду, НЕ проза контракта; контракт несёт инварианты + rc-команды.

## Существующее

Дерево — истина; база ветки — родитель OBJECT `10ff5df41` (ветка `wip/208/orchestrator` — ПОЛНЫЙ носитель реализации 208 с принятым исправлением Б-1 `verdikt_put`); дверь базы `scripts/zamok_predmeta.sh` — sha256 `47de5c0244b548d275b268a0530f634e90a09e7224b8542bb2cbe1601826bdfe`, одна и та же в `10ff5df41` и в OBJECT (коммит архитектуры меняет только зону 211).

1. **Дверь уже решает смежную часть для critic** — `scripts/zamok_predmeta.sh`, режим `--sudit`, блоки `[D42 frozen-risk]`/`[D52 bootstrap-kritika]` (сразу после `[D9 object-sovpadaet]`): первый critic НОВОГО предмета (ноль `refs/tags/frozen/contracts/<NNN>/*` у владельца) читает класс из ДЕРЕВА OBJECT; для reviewer/adversary ветки нет — «как прежде». Класс читает `klass_riska <NNN> <worktree> <OBJECT>` по ВСЕМ файлам `<каталог>/<NNN>-*.md` (одинаковое значение у всех, замкнутый алфавит обычный|рисковый; D29/D31), причём `git -C <worktree>` читает дерево, а из рабочего каталога `<worktree>` берутся профиль каталога контрактов (`kontrakt_kat`) и legacy-реестр D30 (`registry/risk-legacy.tsv` по blob). Репозиторий владельца `risk_repo` — правило базы: репозиторий реестра (`--repo`), если origin носителя автора совпадает с origin репозитория реестра, иначе сам носитель; путь реестра/каталога контрактов — профиль владельца (`reestr_put`/`kontrakt_kat`, [registry-profile]).
2. **Закреплённый frozen** — `frozen_predmeta`: строка `<NNN> → <40hex>` реестра профиля на HEAD репозитория владельца (`risk_repo`: станция для станционных предметов, носитель продукта для продуктовых), объект — annotated тег под `refs/tags/frozen/contracts/<NNN>/`; промах (строки нет / указывает на id-тег минта) → «закреплённый frozen недоступен» → предупреждение `KLASS_RISKA_NET`, предмет считается рисковым (rc 0, START пишется), для ревьюера — плюс `ADVERSARIJ_DO_REVJUERA` (rc 1) без завершённого адверсария (D14/D59).
3. **Измеренная боль (окно REPLACE)**: строка REPLACE (`<NNN> → tag-object frozen/contracts/<NNN>/<v>`) попадает на main только ПОСЛЕ ленда носителя заморозки и publish тега, а ленд реализующего шага требует accept судьи реализации — судья реализации не получает класс, пока строки нет на main, а строки нет, пока реализация не принята. Замеры: станция — спавн reviewer 204 отказан `KLASS_RISKA_NET: закреплённый frozen недоступен` при живом теге `frozen/contracts/204/1` на origin и строке-минте (`id/CONTRACT/204`) в реестре (`/tmp/dev-harness-verify/consultant/inbox-STANCIJA-REPLACE-204-2240.txt`); проекты — Complior-back 177 и 185 тот же отказ (`inbox-back-0125-177-spawn-klass-riska-net.txt`, `inbox-back-0215-185-critic-klass-riska-net.txt`, `inbox-back-STANCIJA-1206-klass-riska-net-project-registry.txt`; часть тех болей — путь `.harness/registry/` — уже закрыта [registry-profile], остаётся окно REPLACE).
4. **База двери** — редакция A2 контракта 140 (v8…v13) + блоки D9/D11 контракта 208 с принятым исправлением Б-1 (`verdikt_put` — один предикат вердиктных путей для резолвера и `kodovaja_granica`): допуск судьи по предковости/публикации (`obj_opublikovan`, `kodovaja_granica`), санкция повтора SANKCIJA полного адреса; семья зелена на базе: 140 `--model` 244/0, obryv_167 `--repo` rc 0, zamok_object_predok_208 `--repo` 35/0, профиль гигиены `zamok_predmeta` 4/4 (замер этой пачки на базе ветки — родителе OBJECT).
5. **Батареи-соседи** (не дублируются): `fixtures/workshop_project/odin_agent_140/` (дверь целиком, A2), `fixtures/workshop_project/zamok_object_predok_208/` (D9/D11), `fixtures/workshop_project/obryv_167/` (круги/обрыв), `fixtures/parsing_hygiene_battery/profiles/zamok_predmeta.sh` (гигиена парсинга двери); новая пачка `fixtures/workshop_project/d52_bootstrap_sudej_211/` судит ТОЛЬКО поведение класса риска судей реализации и не трогает соседей.
6. **Вне предмета**: живость origin-view носителя (208), выбор вердикта адверсария по имени в `scripts/done_contract.sh` (208 §Существующее п.6), порядок судей при отсутствии автора (D59 A2), учёт P_FROZEN проверки передачи (D39) — не меняются; границы — «НЕ ЗАЩИЩАЕТ».
7. **Проектный реестр** `.harness/registry/` блок D64 не читает: путь реестра — `reestr_put` профиля ВЛАДЕЛЬЦА (тот же, что у `frozen_predmeta`), каталог контрактов — `kontrakt_kat` владельца ([registry-profile]); часть болей 177/185 закрыта им, остаётся окно REPLACE.

## Предмет и последовательность

Один наблюдаемый результат: судья РЕАЛИЗАЦИИ (reviewer/adversary) предмета, у которого закреплённый frozen недоступен (строки REPLACE на HEAD владельца нет либо она указывает на id-тег), получает класс риска из ДЕРЕВА OBJECT — но только по УДОСТОВЕРЕННОМУ локальному frozen-тегу НОВОЙ версии предмета (коммит заморозки — предок OBJECT; блобы контракта побайтно равны); дерево OBJECT читается в носителе автора, профиль каталога контрактов и legacy-реестр — только у владельца; иначе — прежнее поведение байтами. Класс: правка существующей двери.

Последовательность (порядок — зависимость):
1. Implementer: `scripts/zamok_predmeta.sh` — блок `[D64 bootstrap-sudej]` (helpers `poslednj_frozen_teg`/`frozen_udostoveren_objectu` + ветвь разрешения kr для reviewer/adversary) и необязательный четвёртый аргумент `klass_riska` (репозиторий владельца профиля и legacy-реестра; вызовы D42/D52 его не передают — владелец остаётся тем же `<worktree>`) по инвариантам ниже; эталон семантики — `fixtures/workshop_project/d52_bootstrap_sudej_211/model/zamok_predmeta.sh` = дверь базы (sha256 `47de5c02…`, §Существующее) + только дельта D64: заголовок v14, эти helpers, ветвь и четвёртый аргумент (поведение судится батареей, не побайтовым сравнением текста; семья 208 зелена против модели как субъекта — `--sosed-208`). Та же дверь — один пишущий в момент: реализация 211 идёт ПОСЛЕ ленда 208 (реализация 208 уже в базе ветки работы; конфликт зон не возникает).
2. Оркестратор: `gen_ci_steps.sh --write` (шаг батареи 211; до ленда реализации шаг несёт `--stabs`, после — безфлаговый), `--check` rc 0.
3. Судьи по регламенту (класс «рисковый»: адверсарий до ревьюера); имя вердикта критика — `verdicts/critic/contracts-211-v1.md` (v1 — новый предмет).

## Инварианты

1. **Bootstrap судей реализации (D64)**: при пустом `P_FROZEN` (передача не удостоверила frozen) и отказе `frozen_predmeta` роли reviewer/adversary получают класс как `klass_riska <NNN> <r_wt> <obj_fakt> <risk_repo>` — из ДЕРЕВА OBJECT (фактический OBJECT, как у D52) — при условии, что локальный frozen-тег удостоверен для дерева OBJECT. Корни чтения разделены: ДЕРЕВО OBJECT читается в носителе `r_wt` (там D9 сверил его с веткой), профиль каталога контрактов (`kontrakt_kat`) и legacy-реестр D30 (`registry/risk-legacy.tsv`) — только в репозитории ВЛАДЕЛЬЦА `risk_repo` (тот же корень, что у `frozen_predmeta`, D42 и D30 — правило базы, п.1 §Существующее); рабочий каталог носителя автора класс не задает.
   - (б1) это annotated тег (объект-тег, не коммит/другой тип) под `refs/tags/frozen/contracts/<NNN>/<v>` В РЕПОЗИТОРИИ ВЛАДЕЛЬЦА, версия `v` — числовая `[1-9][0-9]*`; выбор ТОЛЬКО новой версии — ЧИСЛОВОЙ максимум сравнением digit-строк штатной сортировкой (длина, затем порядок знаков в C; арифметики shell нет — версия любой длины сравнима); лексический порядок ref'ов не числовой: `…/10` < `…/2`; нечисловой суффикс — пропуск (fail-closed);
   - (б2) коммит заморозки `tag^{commit}` — ПРЕДОК `obj_fakt` (`merge-base --is-ancestor` в носителе `r_wt`): заморозка входит в историю судимой работы; тег боковой линии/чужой заморозки не удостоверяет;
   - (б3) перечень и блобы `<каталог>/<NNN>-*.md` в OBJECT и в коммите заморозки равны ПОБАЙТОВО (тот же перечень имён, что у `klass_riska`, каталог — тот же профиль ВЛАДЕЛЬЦА; blob-ша в git — байты): подмена текста или `КЛАСС РИСКА` в OBJECT после заморозки различима; пустой перечень (нет файлов предмета) текста не удостоверяет.
2. **Промах любого условия (б1–б3), отсутствие тега или чужой tag-object — прежнее поведение байтами**: `kr='net_stroki'`, предупреждение `KLASS_RISKA_NET` («закреплённый frozen недоступен — класс не определён, предмет считается рисковым») с записью в учёт, rc 0, START пишется; ревьюер без завершённого адверсария — `ADVERSARIJ_DO_REVJUERA` rc 1 (как в базе).
3. **Класс не занижается и не выдумывается**: побайтовое равенство (б3) закрывает правку класса в OBJECT после заморозки (b05); на пути bootstrap класс задают только декларация в удостоверенном тексте и legacy-строка D30 реестра ВЛАДЕЛЬЦА (b24, b26 — тот же источник, что у D42/D30), а незакоммиченные legacy-реестр (b21) и профиль (b22, b23) носителя автора класс не задают; при удостоверенном тексте БЕЗ строки класса и без legacy-строки владельца bootstrap не выдумывает класс — `klass_riska` даёт `neodnoznachno`, диагностика предупреждения честна (предустановленный «закреплённый frozen недоступен» сбрасывается — сообщение называет реальную причину), предмет рисковый (b14); путь D64 не меняет путь D42 — тот же `klass_riska` без четвёртого аргумента читает legacy-строку владельца как в базе (b27).
4. **critic/critic-sol не меняются**: D52 (bootstrap только при нуле frozen-тегов) и обязательность pinned frozen при живом теге — как в базе; блок D64 на critic не действует: при живом теге без строки на main критик получает прежнее предупреждение (b09).
5. **Порядок судей рискового сохраняется** (D14/D59): класс «рисковый» из OBJECT — ревьюер без завершённого адверсария отказан `ADVERSARIJ_DO_REVJUERA` (b03), после завершённого круга адверсария допущен (b04); закреплённый frozen с «рисковый» — тот же отказ (b13).
6. **Закреплённый frozen приоритетен**: успех `frozen_predmeta` (REPLACE на main указывает на frozen-тег) даёт класс из ДЕРЕВА ЗАМОРОЗКИ как прежде (D42) — bootstrap не участвует и не нужен, расходящийся текст OBJECT на это не влияет (b12); строка-минт с id-тегом отказывает в `frozen_predmeta` — и тогда bootstrap применяется (b08 — измеренный случай 204).
7. **Версии — детерминированный выбор**: только числовой максимум (б1): `/1` при живой `/2` суд не удостоверяет (b11); «последний ref» лексически не равен максимуму (b20, `/2`+`/10`); нечисловая версия пропускается (b18); версия вне int64 сравнима наравне — `/999999999999999999999999999999` остаётся новой версией, `/1` её не подменяет (b25); несколько тегов одной максимальной версии не бывает (уникальный refname), тег каждой меньшей версии игнорируется.
8. **Регресс двери A2/208**: входы вне дельты D64 — без изменений: резолвер `--object/--snapshot/--peredat`, D9 (предковость/публикация/merge-порядок), D11 (SANKCIJA полного адреса), грамматики события/пина, отказы реального вреда, предупреждения v8, учёт START/RELEASE, профиль/пауза (v9–v13); семьи 140 (244/0), 167, 208 (35/0) и профиль гигиены (4/4) зелены до и после реализации (механический якорь регресса). Эталон — дверь базы плюс только дельта D64: семья 208 зелена против МОДЕЛИ как субъекта (`--sosed-208`, `SUBJEKT 208: KLETKI 35 KRASNYH 0`); откат исправления 208 Б-1 (`verdikt_put`) режим различает (`--negativ-208`: rc 0, `NEGATIV 208: KLETKI 35 KRASNYH 2` — ровно r31/r32).

## Приёмка

### Красное сейчас (до реализации)

Замер прогона на базе ветки: `bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --repo .` → `SUBJEKT 211: KLETKI 27 KRASNYH 13`, rc 1 — красные клетки производства: b01-bootstrap-adversary, b02-bootstrap-reviewer-obychnyj, b03-bootstrap-risikovyj-porjadok, b04-bootstrap-posle-adversarija, b08-id-teg-v-stroke-na-main, b10-versija-vtoraja, b14-net-stroki-klassa, b16-chuzoj-predmet-bootstrap (боли 204/177/185 — окно REPLACE) и b21-legacy-avtora-ne-istochnik, b22-profil-avtora-ne-istochnik, b23-spisok-po-profilju-vladelca, b24-legacy-vladelca-rabotaet, b26-profil-vladelca-rabotaet (корень чтения — владелец); регрессионные b05–b07, b09, b11–b13, b15, b17–b20, b25, b27 зелены (прошлое поведение байтами).

### Сценарии (дано → когда → тогда)

- дано: честная модель (дверь базы + дельта D64); когда: `bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --model`; тогда: rc 0, `MODEL 211: KLETKI 27 KRASNYH 0` — вывод обеих труб зелёный во всех двадцати семи входах.
- дано: матрица обманных дверей над текстом модели (якорь каждой замены — кратность 1; привязки — ТОЛЬКО `source.json:.stab_vhod`); когда: `bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --stabs`; тогда: rc 0, `MODEL 211: KLETKI 27 KRASNYH 0`, `STABY 211: SVJAZI 51 ZHIVYH 0`; в пару негатив: обманка, не различимая честной моделью ни на одной связанной клетке — rc 1 `STAB_ZHIV`; потерянный якорь либо сломанный синтаксис мутации — rc 2 `ORACLE_TAMPERED`.
- дано: субъект дерева (база; после реализации — та же команда тем же путём); когда: `bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --repo .`; тогда: до реализации rc 1 (`KLETKI 27 KRASNYH 13`), после — rc 0 (`KLETKI 27 KRASNYH 0`); нет субъекта — rc 1 `SUBJECT_ABSENT` с перечнем входов.
- дано: модель как субъект семьи 208 (в отдельном корне под `$TMPDIR` единственный файл `scripts/zamok_predmeta.sh` — модель побайтно); когда: `bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --sosed-208`; тогда: rc 0, `SUBJEKT 208: KLETKI 35 KRASNYH 0` — эталон не откатывает принятых исправлений 208; в пару негатив (Б-2): когда `bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --negativ-208` — мутация модели «третья копия белого списка путей вердиктов — форма базы ДО unification `verdikt_put`» (якорь кратности 1); тогда: rc 0, `NEGATIV 208: KLETKI 35 KRASNYH 2` — ровно r31-review-txt-vperjod и r32-review-vlozhenyj-vperjod; иное множество красных либо зелень — rc 1 (режим не различает), потерянный якорь либо сломанный синтаксис — rc 2 `ORACLE_TAMPERED`.
- Вывод субъекта — БАЙТЫ (арбитраж 208): каждая клетка сравнивает rc, stdout И stderr ПОЛНОСТЬЮ байт-в-байт в каждом режиме (модель, обманные копии, субъект — один путь запуска; обе трубы захватываются байтами, без text-режима, без декодирования/strip до сравнения; ожидания в памяти до вызова). Границы наблюдения — по одной мутации печати на каждую трубу (`ПРЕДУПРЕЖДЕНИЕ` predupr, `ОТКАЗ` otp, `PUSCHEM` stdout): восемь границ байтов (CRLF, одиночный CR, пробел в конце, двойной LF, BOM, NUL, не-UTF8, лишний вывод), перенос печати в другую трубу и лишняя строка в тихой трубе — привязки в `source.json:.stab_vhod` (st13–st42).

### Зелёные контроли (rc 0, замер этой пачки на базе)

- `bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --model`
- `bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --stabs`
- `bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --negativ-208`
- `bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --sintaksis`

Замеры (пересчитываются гейтом; числа — нижняя граница, не потолок усиления батареи: связей не менее 51, живых 0, клеток не менее 27, обманных копий не менее 50 — по выводу движка, не константой текста):
замер: `ls fixtures/workshop_project/d52_bootstrap_sudej_211/model/* | wc -l` = 1 census fixtures/workshop_project/d52_bootstrap_sudej_211/model/*

### После реализации (гейты ленда, выполняет оркестратор/судьи)

```
bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --sosed-208                                           # rc 0 (SUBJEKT 208: KLETKI 35 KRASNYH 0)
bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --negativ-208                                         # rc 0 (NEGATIV 208: KLETKI 35 KRASNYH 2 — r31/r32)
bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --repo .   # rc 0 (KLETKI 27 KRASNYH 0)
bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --stabs   # rc 0 (SVJAZI 51, ZHIVYH 0)
bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo .  # rc 0 (35/0)
bash fixtures/workshop_project/obryv_167/red_obryv_167.sh --repo .                              # rc 0
bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model                     # rc 0 (244/0)
bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta                             # rc 0 (4/4)
bash scripts/gen_ci_steps.sh --check                                                            # rc 0 (шаг 211 подключён оркестратором)
```

## Зоны и проводка

ЗОНА architect: contracts/211-d52-bootstrap-sudej.md fixtures/workshop_project/d52_bootstrap_sudej_211/
ЗОНА implementer: scripts/zamok_predmeta.sh
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: scripts/zamok_predmeta.sh — 140 только блок [D64 bootstrap-sudej] режима --sudit (класс риска reviewer/adversary из дерева OBJECT), его helpers и необязательный 4-й аргумент klass_riska (репозиторий владельца профиля и legacy-реестра, умолчание — прежний <worktree>) поверх редакции A2/базы 208; D52/D42/D14/D59, грамматики, лимиты, учёт, резолвер и профиль/пауза неизменны.
ПЕРЕСЕЧЕНИЕ implementer: scripts/zamok_predmeta.sh — 154 только блок D64, его helpers и необязательный 4-й аргумент klass_riska; счёт вызовов критика и карта листа не затрагиваются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/zamok_predmeta.sh — 167 только блок D64, его helpers и необязательный 4-й аргумент klass_riska; семантика оборванного судьи (krugov_suda, obryv_bez_verdikta) и RELEASE не меняются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/zamok_predmeta.sh — 199 только блок D64, его helpers и необязательный 4-й аргумент klass_riska; isolated рабочего, привязка сдачи и факт isolated в START не затрагиваются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/zamok_predmeta.sh — 208 только блок D64, его helpers и необязательный 4-й аргумент klass_riska ПОВЕРХ сданной реализации 208 (та же дверь — один пишущий в момент; реализация 211 — после ленда 208, база ветки работы уже несёт реализацию 208); блоки D9/D11 (включая verdikt_put) не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 140 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 141 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 142 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 143 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 145 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 146 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 147 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 148 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 149 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 153 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 154 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 157 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 158 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 159 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 163 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 166 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 167 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 168 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 169 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 170 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 172 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 173 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 174 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 175 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 182 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 184 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 185 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 186 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 187 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 188 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 189 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 190 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 191 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 192 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 193 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 195 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 196 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 197 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 198 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 199 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 200 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 201 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 204 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 208 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 995 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только сгенерированный шаг 211; чужие строки неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 140 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 141 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 142 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 143 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 145 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 146 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 147 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 148 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 149 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 153 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 154 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 157 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 158 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 159 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 163 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 166 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 167 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 168 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 169 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 170 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 172 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 173 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 174 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 175 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 182 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 184 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 185 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 186 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 187 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 188 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 189 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 190 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 191 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 192 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 193 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 195 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 196 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 197 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 198 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 199 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 200 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 201 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 204 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 208 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 995 только замер шага 211; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 140 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 141 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 142 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 145 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 146 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 147 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 148 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 149 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 153 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 154 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 157 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 158 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 159 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 163 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 166 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 167 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 168 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 169 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 170 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 172 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 173 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 174 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 175 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 182 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 184 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 185 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 186 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 187 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 188 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 189 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 190 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 191 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 192 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 193 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 195 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 196 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 197 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 198 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 199 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 200 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 201 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 204 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 208 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 994 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 995 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 997 только сгенерированный шаг 211; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 998 только сгенерированный шаг 211; чужие шаги неизменны.


СДАЧА: fixtures/workshop_project/d52_bootstrap_sudej_211/SDACHA.md

ПРОВОДКА:
- guard=fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh
ПРОВОДКА-ЭНФОРСМЕНТ: класс риска судей реализации — чистый энфорсмент двери (guard-канал): батарея судит поставленную дверь `scripts/zamok_predmeta.sh` по `--repo`, до ленда реализации CI несёт `--stabs` + ногу `bash -n scripts/zamok_predmeta.sh`, после ленда оркестратор переключает шаг на безфлаговый режим (`gen_ci_steps.sh --write`, `--check` rc 0); строку своей батареи подключает оркестратор — имя guard появляется в ci-steps для guard_is_wired done-гейта (прецедент 190/199/208), чужие строки не меняются.

## Модель угроз

ЗАЩИЩАЕТ:
- От вечного «неизвестного риска» в окне REPLACE: судья реализации получает класс из дерева OBJECT по удостоверенному локальному frozen-тегу — инвариант 1, клетки b01/b02/b08/b10/b16 (боли 204/177/185).
- От занижения класса автором НОСИТЕЛЯ: побайтовое равенство блобов контракта (подмена `КЛАСС РИСКА` в OBJECT после заморозки различима), предковость заморозки (чужой tag-object/боковая линия не удостоверяют) и корень чтения — репозиторий ВЛАДЕЛЬЦА: незакоммиченные legacy-реестр и профиль в рабочем каталоге носителя автора класс не задают — инварианты 1б2/1б3/3, клетки b05/b06/b17 и b21/b22/b23; лёгкий (не annotated) тег и пустой перечень файлов — не заморозка — b15/b19.
- От выдумывания класса: bootstrap не обходят `klass_riska` — класс дают только декларация в удостоверенном тексте и legacy-строка D30 реестра владельца, отсутствующая или неоднозначная декларация даёт прежний fail-closed «предмет рисковый» с честной диагностикой — инвариант 3, клетки b14/b24/b26.
- От выбора старой версии: числовой максимум версий сравнением digit-строк, нечисловые суффиксы и лексический порядок ref'ов не пропускают устаревшую/мусорную заморозку, версия вне int64 не теряется — инварианты 1б1/7, клетки b10/b11/b18/b20/b25.
- От ослабления порядка судей, critic-пути и пути D42: рисковый из OBJECT держит adversary → reviewer (b03/b04), critic — как в D52 (b09), закреплённый frozen приоритетен (b12/b13), путь D42 читает legacy-строку владельца как в базе (b27) — инварианты 4–6.
- От регресса замка: входы вне дельты D64 и семьи соседей (140 244/0, 167, 208 35/0, гигиена 4/4), эталон — дверь базы плюс только дельта D64 (семья 208 зелена против модели как субъекта; откат `verdikt_put` различим — `--negativ-208`, ровно r31/r32) — инвариант 8, зелёные контроли приёмки.
- От пропуска побайтового дефекта вывода: наблюдение — (rc, stdout bytes, stderr bytes) с точным равенством в каждом режиме одним путём запуска и одним предикатом; CRLF, одиночный CR, пробел в конце, двойной LF, BOM, NUL, не-UTF8, лишний вывод и перенос между трубами — каждая граница своей обманной копией с якорем кратности 1 (st13–st42, `--stabs` rc 0, живых 0).

НЕ ЗАЩИЩАЕТ:
- Происхождение тега, профиля и legacy-реестра, когда владелец по правилу базы — сам носитель автора: `risk_repo` — носитель, если его origin не совпадает с origin репозитория реестра (продуктовый носитель, носитель без origin либо с иным origin — в том числе изолированный клон станционного предмета): работник, контролирующий свой клон, может изготовить и тег, и строку, и профиль; это СУЩЕСТВУЮЩАЯ граница доверия двери (D31/D42/D52 базы читают тот же `risk_repo`), предметом не вводится заново; ловец — ревьюер/адверсарий реализации 211 и отдельный предмет по слову владельца (вывод владельца для носителя без origin).
- Незакоммиченная правка `registry/risk-legacy.tsv` или `harness.project.json` в рабочем дереве репозитория ВЛАДЕЛЬЦА читается на пути bootstrap так же, как на путях D42/D30/D52 базы (D30 читает рабочий каталог владельца, а не `HEAD:`): второй источник только для D64 не заводится — он расходился бы с D42; станция автору недоступна; ловец — отдельный предмет по слову владельца (чтение `HEAD:` на всех путях сразу).
- Путь D52 (critic) по-прежнему читает профиль и legacy-реестр носителя автора, как в базе (инвариант 4; совет С-3 вердикта критика вызов 1) — вне предмета; ловец — отдельный предмет по решению оркестратора либо слову владельца.
- Живость тега на origin не проверяется (сеть в двери нет): локальный тег, исчезнувший с origin, продолжает удостоверять до исчезновения локально; замена доверия «origin-тег» — отдельный предмет; ловец — оркестратор на живом прогоне.
- Свежесть origin-view носителя (208) и преддверие 172 (равенство tip) — вне предмета, не меняются.
- Побайтовая форма строк учёта `uchet.jsonl` не судится (START — по полям JSON, отказ — по неизменности файла); ловец — отдельный предмет по слову владельца (граница 208 сохранена).
- Проектный реестр `.harness/registry/`: блок D64 берёт путь реестра и каталог контрактов только из профиля ВЛАДЕЛЬЦА штатным резолвером ([registry-profile]), своих ключей профиля не вводит; ловец — батареи [registry-profile].
- Батарея — конечный закрытый набор на объявленные механизмы (клеток не менее 27, обманных копий не менее 50, связей не менее 51 — по выводу движка), не доказательство эквивалентности произвольной программы; остаток — судьи (adversary → reviewer) на живом дереве.

ПРЕДПОСЫЛКИ:
- setting нужны bash, git, jq, python3 (rc 2 при отсутствии); новых CI secrets/variables/environments и настроек репозитория не требуется.

## Незаполненные требования:
нет
