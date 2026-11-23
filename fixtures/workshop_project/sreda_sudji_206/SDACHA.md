# СДАЧА 206 — среда изолированного судьи

Исправительный круг по Adv206V1, OBJECT FAIL
4c22cced68809594b260a531cc9c31f8d1a8df28. Вердикт прочитан целиком из
archive/206/adversary-v1-fail-afab2af670:verdicts/adversary/contracts-206-v1.md;
в HEAD этой базы он не закоммичен, чужая зона verdicts автором не материализуется,
строку предыдущего вердикта лист не заявляет (прецедент 208/210). Production все
предъявленные входы судит правильно, FAIL — за два живых мутанта на батарее:
правка — только различающие клетки и адресные стабы. Production, контракт, роли
и CI не меняются. Эталон production остаётся дельтой над immutable BASE
db56f44d1012854b6098a7076fccdae0855badeb, live.py — проверяемый наблюдатель
этой пачки, копируемый в модель для адресных мутаций.

## Двери

- repo · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --repo . · 0 · 0
- модель · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --model · 0 · 0
- адресные-мутации · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --stabs · 0 · 0
- каталог-канон · fixtures/workshop_project/sreda_sudji_206/catalog.py --check · 0 · 0
- наблюдатель-контроли · fixtures/workshop_project/sreda_sudji_206/live_control.py · 0 · 0
- precision · bash scripts/check_precision_gate.sh . contracts/206-sreda-sudji.md · 0 · 0
- spec-ready · bash scripts/check_spec_ready.sh . contracts/206-sreda-sudji.md · 0 · 0
- ids · bash scripts/check_ids.sh . · 0 · 0
- потолки · bash scripts/check_ceilings.sh . · 0 · 0
- проводка-грамматика · bash scripts/check_provodka.sh --grammar . contracts/206-sreda-sudji.md · 0 · 0
- модель-угроз · bash scripts/check_threat_model.sh . contracts/206-sreda-sudji.md · 0 · 0
- предпосылки · bash scripts/check_predposylki.sh . contracts/206-sreda-sudji.md · 0 · 0
- pre-critic · bash scripts/pre_critic.sh contracts/206-sreda-sudji.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: машинные двери листа и раздел Дельта, pre_critic обязателен до сдачи · - · -
- К-02 · чисто · вход: task-arch206 и task-arch206b, оба блока Adv206V1 закрываются только клетками и стабами без изменения предмета · - · -
- К-03 · чисто · вход: права М1 037 и назначенный пин 032/066 сохранены, режимы 172 и детектор 185 не тронуты · - · -
- К-04 · чисто · вход: меняется только семья fixtures/workshop_project/sreda_sudji_206, production остаётся implementer, CI orchestrator · - · -
- К-05 · чисто · вход: приёмка — rc-команды, live принимает назначенный --object · - · -
- К-06 · чисто · вход: observer-null/number/string/array/broken-json/bom ожидают полный rc2/stderr, empty/count-1/count-2 ожидают предметный rc1/stdout · - · -
- К-07 · чисто · вход: эталон вызывает реальные Node/git/pre_judge, разделение опций/операндов и realpath исправлены в обязательной модели · - · -
- К-08 · чисто · вход: verdict-relative-outside/parent-outside/symlink-outside/file-symlink-outside и verdict-absolute-file-symlink-outside противопоставлены честным внутри-repo входам обеих форм · - · -
- К-09 · чисто · вход: cp/mkdir и /bin-формы после --, dash-операнды внутри/снаружи, флаги до --, несколько операндов и цель cp с хвостовым слэшем в живой state · - · -
- К-10 · чисто · вход: observer-honest/different-objects/unassigned-object/missing-object, мутации сравниваются по полному rc/stdout/stderr, не подстроке · - · -
- К-11 · чисто · вход: ожидания в памяти до запуска субъекта, live читает один снимок журнала, не получает ожидания от проекта · - · -
- К-12 · чисто · вход: GNU realpath для нормализации, штатная токенизация guard, json.loads для JSON, единый controls для observer-клеток и catalog.py для stabs.tsv · - · -
- К-13 · н/п · секреты в предмет не входят · - · -
- К-14 · чисто · вход: честные абсолютные пути внутри repo и цель cp с хвостовым слэшем в собственный scratch остаются зелёными, empty отличён от невалидного JSON · - · -
- К-15 · чисто · вход: счётчики раннеров, побайтовая сверка stabs.tsv с MUTATIONS из 36 записей · - · -
- К-16 · чисто · вход: риск безопасности путей, сохранённая граница shell и обязательная живая тройка после рестарта · - · -
- К-17 · н/п · harness не имеет pinned проектного архитектурного брифа 187а/188 для этого предмета · - · -

## Дельта

- К-08 · клетка · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --stabs · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --stabs · 0 · 0
- К-14 · клетка · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --repo . · 0 · 0

## Закрытие двух блоков Adv206V1 и предикаты

| Блок | Способ и причина | Мутация и соседняя | Честная эквивалентная запись |
|---|---|---|---|
| К-08, абсолютный --file через симлинк-файл наружу | клетка: production вход уже судит верно (rc 1 VERDIKT_VNE_REPO с формой), дыра была в доказательстве — у всех symlink-клеток вход был относительным, снятие или граница ослабили бы инвариант 6 | absolute-symlink-ignored: realpath -ms только для абсолютной формы (редакция живого мутанта вердикта), соседняя relative-symlink-ignored отключает разрешение симлинков обеим формам | verdict-absolute-inside: rc 0 VERDICT_BRANCH на том же мутанте и в suite, относительные inside/normalized/symlink-внутрь остаются зелёными |
| К-09, цель cp с хвостовым слэшем | клетка: cp-в-каталог — каноническая форма грамматики предмета, production блокирует запись в live-state, клетка отсутствовала (один символ от покрытой) | cp-trailing-slash-ignored: цель с завершающим «/» покидает суд (дословная редакция мутанта вердикта), соседняя cp-no-destination теряет цель целиком | guard-cp-trailing-slash-scratch: cp в собственный scratch со слэшем — pass на production и на мутанте, cp-в-scratch без слэша зелёный |

Оба стаба несут якорь кратности 1 в реальных scripts/pre_judge.sh и
.omp/extensions/path-guard.ts и в материализованной модели (код модели
байтово совпадает с production, отличие только в комментариях), проверено
прогоном до интеграции на выделенных мирах: мутант абсолютной формы даёт
rc 0 VERDICT_BRANCH на различающем входе и rc 0 на честном внутреннем,
мутант слэша даёт pass на live-state и pass на честном scratch.

Советы .review/2026-11-23-151.md: С-1 закрыт четырьмя клетками батареи
(две различающие и две честные). С-2 (cp -t DIR src и --target-directory=)
остаётся вне грамматики флагов контракта — остаток «формы shell вне
грамматики» с ловцом adversary/reviewer, грамматика предмета не расширялась
и клетка-фиксация не заводилась: граница контракта поименована и не требует
нового предъявления. С-3 исполнен реализацией до этой пачки.

## Доказательства и границы

Машинные ряды выше задают ожидаемые rc и исполняются check_sdacha --run.
Repo — зелёная дверь: production реализован и судит все клетки батареи.
Счётчики KLETKI, OBSERVER_CONTROLS и STABS — нижняя граница покрытия,
не верх. Настоящие три суда — LIVE_JUDGES_NOT_RUN до поставки и рестарта
ТЕГ 4, живая приёмка — оркестратор. Legacy-пробы с внешним scratch
не исполняются из этой изоляции, их обязательные команды сохранены для
implementer/orchestrator.

## Фактический замер пачки

| Команда | Сырой rc | Полный итог счётчика / наблюдение |
|---|---|---|
| `red_sreda_sudji_206.sh --repo .` | 0 | KLETKI=86 ZELENYE=86 KRASNYE=0, все четыре новые клетки зелёные |
| `red_sreda_sudji_206.sh --model` | 0 | KLETKI=86 ZELENYE=86 KRASNYE=0 |
| `red_sreda_sudji_206.sh --stabs` | 0 | OBMANOK=36 POIMANY=36 ZHIVYH=0, оба новых стаба пойманы своей клеткой |
| `catalog.py --check` | 0 | STABS=36 NORM_CONSUMERS=3, независимый wc -l stabs.tsv = 37 с заголовком |
| `live_control.py` | 0 | OBSERVER_CONTROLS=21 KRASNYE=0, LIVE_JUDGES_NOT_RUN |
| `check_precision_gate.sh . contracts/206-sreda-sudji.md` | 0 | OK |
| `check_spec_ready.sh . contracts/206-sreda-sudji.md` | 0 | OK |
| `check_ids.sh .` | 0 | номера уникальны и согласованы с регистром выдачи |
| `check_ceilings.sh .` | 0 | потолки в порядке |
| `check_provodka.sh --grammar . contracts/206-sreda-sudji.md` | 0 | без вывода |
| `check_threat_model.sh . contracts/206-sreda-sudji.md` | 0 | ЗАЩИЩАЕТ 4, НЕ ЗАЩИЩАЕТ 5 |
| `check_predposylki.sh . contracts/206-sreda-sudji.md` | 0 | PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2 |
| `node scripts/gen-harness.ts --check` | 0 | харнес соответствует roles/ (13 ролей) |
| `validate_std.sh bash red_sreda_sudji_206.sh` | 0 | bash -n и shellcheck 0.11.0, sha256 сверяет штатная обёртка |
| `red_own_copy_paket_b.sh .` | 0 | ветвей 13, красных 0, зелёных 13 |
| `red_extract_pin_actual_066.sh .` | 0 | ветвей 15, красных 0, зелёных 15 |
| `red_predverie_172.py --repo` | 0 | 16 ok, prepare/sync-main/archive и коды сохранены |
| `pre_critic.sh contracts/206-sreda-sudji.md` | 0 | КРИТИК: дверь зелёная |
| `check_sdacha.sh "$PWD" contracts/206-sreda-sudji.md --run` | 0 | двери=13 карта=17/17 дельта=3 |

Валидатор исполнен полной командой `env VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck bash scripts/validate_std.sh bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh`.
Дверей, клеток и обязательств сверх двух блоков Adv206V1 не введено:
production, контракт, роли и CI не тронуты, git diff содержит только
семью fixtures/workshop_project/sreda_sudji_206.
