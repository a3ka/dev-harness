# СДАЧА 221 — project-минт

Обещание: штатный project-минт без ручного hooksPath. Наблюдение: реальный Git commit, профильный реестр, identity и rc живого check_staged, станционная побайтовая диффпроба. Frozen 068/031/080 учтены в Существующем контракта. Политика 080 не выключается: project-нормализация удаляет запрещённые локальные ключи, даже пустые/многозначные; другие ключи сохраняются. Производство этой пачкой не правится.

Среда: TMPDIR=/tmp/dev-harness-verify/scratch-arch221b существует; VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck. Нет валидатора — rc 2, не зелёный пропуск. Bash-синтаксис мутантов судится перед запуском, shellcheck — стандартным пинованным инструментом на честной модели/обёртке. Числа модели/связей определяет вывод, нижние границы контракта — 16 клеток, 11 стабов, 14 связей.

Наблюдённые rc: --repo 1 (KLETKI 17 KRASNYH 10: p01–p08, p11, p12 — клетки реализации; p09, p10, s01–s05 зелёные); --model 0 (KLETKI 17 KRASNYH 0); --stabs 0 (честные 17 зелёных, STABY 14 SVJAZI 18 ZHIVYH 0); --sintaksis 0 (SINTAKSIS 17 SHELLCHECK 2); pre_critic 0 («КРИТИК: дверь зелёная»); check_sdacha --run 0 (двери=12 карта=17/17 дельта=2). Генератор напечатал NOSITELI 16 STABY 14 SVJAZI 18; model/ байт-в-байт прежняя, добавлены два носителя st13/st14.

План не менялся: запрошенный gen_plan --check вернул rc 1 «gen_plan: флаг вне грамматики: --check» (у инструмента только --write); штатный немутирующий эквивалент check_plan --root вернул rc 1 «done-пункт стоит следующим: 157». Это существующая очередь, не отсутствие строки 221 и не предмет architect. Никакого обхода этой проверки либо зелёного заявления о плане нет.

Полный check_provodka (не --grammar) до подключения orchestrator вернул rc 1: «проводка: guard не подключён: fixtures/workshop_project/mint_line_proekt_221/red_mint_line_proekt_221.sh не вызывается в .githooks/ или .github/workflows/». Подключение своего CI-шага — зона orchestrator контракта, до вызова критика/ворот done; architect не объявляет полную проводку зелёной.

## Двери

- Red-do · bash fixtures/workshop_project/mint_line_proekt_221/red_mint_line_proekt_221.sh --repo . · 1 · 1
- Model · bash fixtures/workshop_project/mint_line_proekt_221/red_mint_line_proekt_221.sh --model · 0 · 0
- Stabs · bash fixtures/workshop_project/mint_line_proekt_221/red_mint_line_proekt_221.sh --stabs · 0 · 0
- Sintaksis · bash fixtures/workshop_project/mint_line_proekt_221/red_mint_line_proekt_221.sh --sintaksis · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/221-mint-line-proekt.md · 0 · 0
- Spec-ready · bash scripts/check_spec_ready.sh . contracts/221-mint-line-proekt.md · 0 · 0
- Threat-model · bash scripts/check_threat_model.sh . contracts/221-mint-line-proekt.md · 0 · 0
- Predposylki · bash scripts/check_predposylki.sh . contracts/221-mint-line-proekt.md · 0 · 0
- Ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- Ids · bash scripts/check_ids.sh . · 0 · 0
- Provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/221-mint-line-proekt.md · 0 · 0
- CI-canon · bash scripts/gen_ci_steps.sh --check · 0 · 0

## Карта классов

- К-01 · чисто · вход: двери формы этого листа, ПРОВОДКА guard-каналом, модель угроз и незаполненные требования присутствуют; plan 221 ожидает внешний owner-PR #1350, не заменяется фиктивной строкой · - · -
- К-02 · чисто · вход: task-architect221, затравка и оба письма бэкенда прочитаны; Н-456 в базе отсутствует, это прямо названо; sourceCanon не объявлен · - · -
- К-03 · чисто · вход: frozen 068/1 и 031/4 прочитаны git show; обнаружен обязательный 080/4, его guard не меняется; station branch сравнивается с каноном базы · - · -
- К-04 · чисто · вход: единственные записи architect — контракт и семья fixtures; implementer получает mint_line, CI — orchestrator; нет выдачи edit-зоны реестра · - · -
- К-05 · чисто · вход: --repo / --model / --stabs / --sintaksis с rc; stdout MINTED сверяется с HEAD и отдельным фактическим commit-эффектом · - · -
- К-06 · чисто · вход: нет git/bash/jq/python3, носителя или пина — rc 2; нет project-функции до реализации — реальные красные клетки rc 1; синтаксис мутанта проверяется до запуска · - · -
- К-07 · чисто · вход: --model исполняет настоящий check_staged и git, не двойники; отказ двери — project с корневым registry, дефект прочих remote-путей 031 явно вынесен из предмета; положительный минт на корневой раскладке исполняет p12 · - · -
- К-08 · чисто · вход: build.py — единственный реестр адресных мутаций, source.json — сгенерированные носители/связи; --stabs требует отдельную красноту каждой связи и честный контроль; остаток одноразового хука после успеха и после отказа двери судится предикатом ONCE_HOOK_LEFT, стабы st13 на p01 и p07 · - · -
- К-09 · чисто · вход: отсутствие, чужие, пустые, email-only, многозначные ключи, иные [user]-ключи вне запрещённых (p12), чужая env-identity, hooksPath=/dev/null, профильные раскладки и station-противоположности; сохранность прочей конфигурации — UNRELATED_CONFIG_CHANGED во всех project-мирах и байтовый RAW_CONFIG_PARITY в p12 · - · -
- К-10 · чисто · вход: захват обеих труб bytes, полное сравнение успеха и station-паритет, фактические реестр/index/HEAD/config/hooks/origin; отказы project судятся по rc и именованной причине с пустым stdout и неизменностью реестра; TMPDIR-мир вызова наблюдается на остаток хука · - · -
- К-11 · чисто · вход: ожидания и исходный реестр в памяти до субъекта, sha256 носителей до запуска, станционный результат снят в память до вызова кандидата; ожидаемые байты конфига p12 выводятся из снимка до вызова · - · -
- К-12 · чисто · вход: Git plumbing для refs/HEAD/commit, существующий project_paths_resolve для профиля, validate_std bash для shell-формы, генерация source.json из одного build.py · - · -
- К-13 · н/п · секретных входов нет: локальный bare-origin, synthetic identity и hashes, новых credentials/CI secrets предмет не вводит · - · -
- К-14 · чисто · вход: честный контроль зелён без локальных ключей и с чужими/пустыми/повторёнными/иными [user]-ключами после нормализации, три конформные раскладки плюс положительный минт на корневой; station-конфиг по-прежнему отвергается как базой · - · -
- К-15 · чисто · вход: количество CASES и MUTATIONS — из --model/--stabs, контракт несёт нижние границы, сгенерированные связи не копируются парами в прозу; числа этого листа сняты из вывода прогонов · - · -
- К-16 · чисто · вход: рисковый — права/безопасность; single-uid/доверенный PATH/конкурентный config, независимый remote-registry дефект 031 и скратч lib_zones самой двери названы в НЕ ЗАЩИЩАЕТ · - · -
- К-17 · н/п · новых сервисов/операций модели 188 нет; доработка одного клиента двери без второго резолвера/реестра/identity-политики, новые замки не вводятся · - · -

## Дельта

Вход: вердикт Crit221 вызов 1 (FAIL), ветка archive/221/critic-v1-fail-b712c36c04; в дерево OBJECT он не входит, поэтому строки ПРЕДЫДУЩИЙ ВЕРДИКТ здесь нет, дельта заявлена по тексту блоков. Оба блока — дыры батареи, а не контракта; production не правится.

Блок К-08: инвариант 2 «одноразовый хук удаляется на выходе» не имел различающей клетки (мутант m2 без очистки жил). Способ — клетка: каждый project-вызов, успешный и отказной, оставляет TMPDIR-мир без уцелевшего pre-commit и без постороннего временного каталога (предикат ONCE_HOOK_LEFT); стаб st13-no-cleanup привязан к p01 и p07 отдельно. Честная модель оставляет в TMPDIR только lib_zones.* самой двери — это вынесено в НЕ ЗАЩИЩАЕТ контракта и белым списком префикса в once_hook_residue, ловить одноразовый хук имена lib_zones.* не мешают.

Блок К-09: инвариант 3 «остальная конфигурация сохраняет ключи/значения» не покрывал иные [user]-ключи (мутант m3 remove-section жил). Способ — клетка p12-user-family-config: user.signingkey и user.useConfigOnly рядом с запрещёнными, корневая раскладка; после минта .git/config равен исходному с удалёнными только user.name/user.email (RAW_CONFIG_PARITY, ожидание выводится из снимка до вызова) и ключи/значения не изменены (UNRELATED_CONFIG_CHANGED); стаб st14-user-section немой — rc 0 и вывод двери честные, краснеет только конфиг. Совет критика про положительный минт на корневой раскладке закрыт той же клеткой p12; совет про export NEXT_ID_LIB пояснён комментарием в build.py (нужен лишь SC2034 в shellcheck модели, для цепочки хука инертен, исполнителю не требуется).

Прежние клетки и стабы не ослаблены: p01–p11, s01–s05 и st01–st12 прежние, добавлены p12, st13, st14. Мутации критика m1, m4, m5, m6 остаются пойманными прежними связями.

- К-08 · клетка · bash fixtures/workshop_project/mint_line_proekt_221/red_mint_line_proekt_221.sh --stabs · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/mint_line_proekt_221/red_mint_line_proekt_221.sh --stabs · 0 · 0
