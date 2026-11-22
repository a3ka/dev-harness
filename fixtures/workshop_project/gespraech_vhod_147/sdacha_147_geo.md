# СДАЧА 147 — v+7 (v6): CI-модель на транспорт 197 и паритетно допустимая lane-форма шага валидатора

Дельта слова владельца 22.11 ~10:53 UTC (п.(4)«А»), переданного заданием дословно: требования GitHub-артефактного шага в red_ci_147.py заменены lane-вызовом канона 197 — публикация кадров `npm run ci:artefakt-zapis -- --imja maestro-gespraech-vhod --chto mobile/maestro-out-gespraech` с сохранением `if: always()` (кадры при красной приёмке), источника кадров `mobile/maestro-out-gespraech` (семантика не меняется; имя каталогу `<имя>-<run_id>-<run_attempt>` строит скрипт-канон 197 — workflow имя не строит, d01) и отказа ошибочной публикации (без continue-on-error/`if: success()`/`|| true`; страж источника — fail-closed канона 197, `ISTOCHNIK_OTSTUTSTVUET`, эквивалент `if-no-files-found: error` v5). Экранная приёмка остаётся ОБЯЗАТЕЛЬНЫМ шагом работника и переведена в паритетно допустимую форму (163/1): lane `npm run ci:ekran-gespraech-vhod` (ключ в КОРНЕВОМ package.json, тело — `mobile/scripts/ci-ekran-gespraech-vhod.sh`, зона implementer); читатель APK — измеренный контекст P+L+Q канона 197 с продюсерской парой `--run-id/--run-attempt` из `needs.build-apk.outputs`. Новая ветвь LANEJA_NET судит объявление lane в корневом package.json (npm run без ключа падает в прогоне и красит паритет). Модель MODEL_YML — каркас и судимые шаги v5 (адаптация работника 149 mob@60a62ecb6, сверен с worker-147.yml автора и build_honest.py критика) с заменой ТОЛЬКО транспорта; стабы 44, каждый красен своей именованной причиной (Н-39, привязки в коде STABY). Контракт: И-11/критерий 4 переписаны, «Снятие замороженных норм» +2 строки, зоны/пересечения package.json (011/015/197) и mobile/scripts, SPEC §5/§6-4, Порядок v+7. Геометрия v+6, пачка из 10 файлов, наборная приёмка и все прочие обязательства /5 не тронуты; frozen/contracts/147/5 не перемещался.

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-147-v5.md

## Двери

- ci-model · fixtures/workshop_project/gespraech_vhod_147/red_ci_147.py --model · 0 · 0
- ci-stabs · fixtures/workshop_project/gespraech_vhod_147/red_ci_147.py --stabs · 0 · 0
- legacy-model · bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --model · 0 · 0
- legacy-stabs · bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --stabs · 0 · 0
- threat-form · bash scripts/check_threat_model.sh . contracts/147-gespraech-vhod-menu.md · 0 · 0
- provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/147-gespraech-vhod-menu.md · 0 · 0
- product-spec-zone · bash scripts/check_precision_gate.sh . contracts/147-gespraech-vhod-menu.md · 0 · 0
- product-carrier-zones · bash fixtures/workshop_project/gespraech_vhod_147/check_zone_147.sh · 0 · 0
- spec-ready · bash scripts/check_spec_ready.sh . contracts/147-gespraech-vhod-menu.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: провода guard= строки и грамматика — provodka-grammar rc 0; CI-подключение шага red_ci_147.py — orchestrator в окне freeze..done (Незаполненные требования) · - · -
- К-02 · чисто · вход: слово владельца 22.11 ~10:53 UTC п.(4)«А» скопировано в §Воля владельца дословно; источник — задание v6; санкцию к заморозке добавляет orchestrator · - · -
- К-03 · чисто · вход: frozen/contracts/147/5 не перемещался (тег на месте); геометрия И-12, пачка 10 файлов, критерии 1–3/5–6 и SPEC §7–§8 не правлены этой пачкой · - · -
- К-04 · чисто · bash fixtures/workshop_project/gespraech_vhod_147/check_zone_147.sh · 0 · 0
- К-05 · чисто · вход: критерий 4 несёт rc 0 REGISTRACIJA_OK и именованные rc 1 (PACHKA_*/ZAPIS_*/LANEJA_NET/RABOTNIK_*/UPRAVLYAYUSHCHIJ_KLYUCH); rc 2 NOT_IMPLEMENTED без режима/PyYAML · - · -
- К-06 · чисто · вход: отсутствие PyYAML/режима/каталога — rc 2 NOT_IMPLEMENTED с именованной причиной, не пустая зелень; битый YAML — RABOTNIKA_NET · - · -
- К-07 · чисто · bash fixtures/workshop_project/gespraech_vhod_147/check_zone_147.sh · 0 · 0
- К-08 · чисто · fixtures/workshop_project/gespraech_vhod_147/red_ci_147.py --stabs · 0 · 0
- К-09 · чисто · вход: каждая мутация новых требований красна своей именованной причиной — lane-ключи (LANEJA_NET), lane-слова в echo/heredoc/no-op/`|| true` (RABOTNIK_BEZ_VALIDATORA), `--imja`/`--chto`/`|| true` писателя (RABOTNIK_BEZ_KADROV), `if: false`/`if: success()` на публикации (UPRAVLYAYUSHCHIJ_KLYUCH); привязки — код STABY, не контракт (Н-39) · - · -
- К-10 · чисто · вход: судятся разобранные shell-слова (lane/--imja/--chto — самостоятельные слова), полные поля шагов и позиции против MODEL_YML; комментарий/echo/heredoc-данные вызовом не являются · - · -
- К-11 · чисто · вход: MODEL_YML/MODEL_PKG разбираются в память ДО субъекта; --repo не читает ожидания из продукта; прецедент 141 v3 upravlenie_job · - · -
- К-12 · чисто · вход: YAML — python3-pyyaml (та же предпосылка семей 143/149), JSON — stdlib json; самописного разбора формата нет · - · -
- К-13 · н/п · секреты/учётные данные и внешняя сеть не предмет формы CI-регистрации; новых секретов/variables/environments нет · - · -
- К-14 · чисто · вход: структурное равенство ravno_modeli не зависит от порядка ключей и текстовой записи; YAML-алиасы/дубли ключей судятся фактическим последним значением · - · -
- К-15 · чисто · вход: счёт клеток и стабов печатает сам прогон (44/44, каждая PRICHINA поимённо); цифры листа взяты из вывода, не из головы · - · -
- К-16 · чисто · bash scripts/check_threat_model.sh . contracts/147-gespraech-vhod-menu.md · 0 · 0
- К-17 · чисто · вход: новых продуктовых операций не вводится — lane-вызовы потребляют канон 197 (ci-artefakty.cjs не копируется, пины 197 не трогаются); модель потребления — И-11 v+7 контракта · - · -

## Дельта

- К-09 · клетка · fixtures/workshop_project/gespraech_vhod_147/red_ci_147.py --stabs · 0 · 0

Карта предыдущего вердикта (contracts-147-v5.md, accept) блоков не несёт; последний FAIL темы (contracts-147-v5-geometrija-fail.md) закрыт в v+6 строками К-04/К-07 прежнего листа, его классы не входили в дельту этого круга; настоящий круг меняет И-11/критерий 4, и его единственная новая клетка — К-09 (стаб-матрица lane-транспорта), закрывается прогоном ci-stabs.

## Развилки

Развилок воли владельца не осталось: слово 22.11 предписывает форму (канон 197, ничего нового), сохранение четырёх свойств и неперемещение /5 — всё исполнено. Имя lane приёмки `ci:ekran-gespraech-vhod` и скрипт `mobile/scripts/ci-ekran-gespraech-vhod.sh` — не новый транспорт, а паритетно допустимая обёртка для прежнего тела шага (163/1: `run:` — `npm run <NAME>`); значение lane — зона implementer, батареёй судится только наличие непустого ключа. Красное-до (живой замер 2026-11-22, базовая батарея /5 ДО правки): `red_ci_147.py --repo <дерево PR #248 @ d3a17dd2>` → rc 1 `PRICHINA RABOTNIK_BEZ_KADROV: шага upload-artifact (mobile/maestro-out-gespraech + if-no-files-found: error) нет` — требования GitHub-артефактного шага краснили lane-реализацию; после v+7 то же дерево красно rc 1 `LANEJA_NET: lane ci:ekran-gespraech-vhod не объявлена в корневом package.json` — честный вход implementer (PR уже несёт lane-писателя кадров и lane-читателя APK). Продуктовая батарея приёма 209 пинует байты red_ci_147.py — перепин после freeze v6 на стороне продукта (orchestrator/консультант), не этой пачкой.

## Фактические двери v6

Копия: `/tmp/dev-harness-verify/dev-harness-worktrees/3afca10b/wip-147-architect`, ветка `wip/147/architect`, база `3d8fe3e4b48d934cb7a2fdd0b96b8047d27e4980` (origin/main); `TMPDIR` — scratch внутри копии, scratch удалён до доклада. Продукт — scratch-клон `https://github.com/a3ka/Complior-mob.git` (SSH-маршрут задания вернул «Repository not found»; HTTPS — тот же репозиторий, sha ветки сверен с живым клоном станции), дерево PR #248 `wip/209/implementer` @ `d3a17dd247a2c876890a823686b47304d65370ef`.

| Команда (из корня копии) | Сырой rc | Вывод |
|---|---:|---|
| red_ci_147.py --model (батарея /5, ДО правки) | 0 | MODEL_OK |
| red_ci_147.py --stabs (батарея /5, ДО правки) | 0 | 38/38, непойманных 0 |
| red_ci_147.py --repo <PR #248> (батарея /5, ДО правки — красное-до) | 1 | PRICHINA RABOTNIK_BEZ_KADROV: шага upload-artifact (… if-no-files-found: error) нет |
| red_ci_147.py --model (v+7) | 0 | MODEL_OK |
| red_ci_147.py --stabs (v+7) | 0 | 44/44, каждая PRICHINA своя, непойманных 0 |
| red_ci_147.py --repo <каталог модели> | 0 | REGISTRACIJA_OK |
| red_ci_147.py --repo <PR #248> (v+7) | 1 | PRICHINA LANEJA_NET: lane ci:ekran-gespraech-vhod не объявлена — вход implementer |
| bash scripts/verify_ci_parity.sh <PR #248> | 1 | расхождений 172 против 29 базы — рост от шагов, переставших быть непрозрачными (переписаны без $(...) без объявления команд); закрывается lane-формой судимых шагов, живой замер зафиксирован; «не хуже базы» — обязательство PR-кандидата |
| bash scripts/verify_ci_parity.sh <main 425b769> | 1 | расхождений 29 — база сравнения |
| bash scripts/check_sdacha.sh <копия> contracts/147-gespraech-vhod-menu.md --run | 1 | ОТКАЗ: последний FAIL: неоднозначный вызов 1 — известный дефект `lib_karta_sdachi.sh::karta_index` (номер вызова не уникален между фазами 147: v2a-fail 1/5, v2L-fail 1/лёгкий, v4 1/3, v5-vyzov1 1/3), зона scripts/verdicts — НЕ этой пачки; по заданию v6 докладывается, не чинится; двери листа по отдельности зелёные (таблица выше) |
| bash scripts/pre_critic.sh contracts/147-gespraech-vhod-menu.md | 1 | то же основание через внутреннюю дверь сдаточного листа (Н-39-эвристика, потолки, проводка — зелёные в её выводе); до правки формулировки И-11 давал «Н-39: привязка стаба в прозе, строка 81» — устранено перефразированием (пара s147+вход+«падает») |
| bash scripts/check_provodka.sh . contracts/147-gespraech-vhod-menu.md | 1 | именованный «guard не подключён: red_ci_147.py не вызывается в .githooks/ или .github/workflows/» — ожидаемое ДО проводки; подключение CI-шага — orchestrator в окне freeze..done |
Эмулятор, Maestro, RN/Jest и живой CI продукта не запускались: предмет круга — форма CI-модели, исполняемость пачки судит валидатор 132 v3 на работнике (критерий 3/4 прежние). `bash -n` на изменённый shell не применялся — правок .sh в этой пачке нет; shellcheck на станции отсутствует (ограничение среды, НЕ зелёная проверка). Проводка CI-шага red_ci_147.py — orchestrator в окне freeze..done; check_provodka до проводки даёт именованный rc 1 (строка батареи ещё не подключена) — не зелень и не блокер этого круга.
