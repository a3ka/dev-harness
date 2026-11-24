# СДАЧА 221 — project-минт

Обещание: штатный project-минт без ручного hooksPath. Наблюдение: реальный Git commit, профильный реестр, identity и rc живого check_staged, станционная побайтовая диффпроба. Frozen 068/031/080 учтены в Существующем контракта. Политика 080 не выключается: project-нормализация удаляет запрещённые локальные ключи, даже пустые/многозначные; другие ключи сохраняются. Производство этой пачкой не правится.

Среда: TMPDIR=/tmp/dev-harness-verify/scratch-arch221 существует; VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck. Нет валидатора — rc 2, не зелёный пропуск. Bash-синтаксис мутантов судится перед запуском, shellcheck — стандартным пинованным инструментом на честной модели/обёртке. Числа модели/связей определяет вывод, нижние границы контракта — 16 клеток, 11 стабов, 14 связей.

Наблюдённые rc: --repo 1 (KLETKI 16 KRASNYH 9: p01–p08 и p11); --model 0 (KLETKI 16 KRASNYH 0); последняя check_sdacha --run 0 (двери=12 карта=17/17 дельта=0). Генератор финальной семьи напечатал NOSITELI 14 STABY 12 SVJAZI 15; Stabs и Sintaksis финальной семьи прошли дверями листа с rc 0. Pre_critic rc 0 получен с тем же контрактом; после него правка только диагностики unrelated-config и добавление её адресной мутации, повторная полная дверь листа — rc 0.

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
- К-07 · чисто · вход: --model исполняет настоящий check_staged и git, не двойники; отказ двери — project с корневым registry, дефект прочих remote-путей 031 явно вынесен из предмета · - · -
- К-08 · чисто · вход: build.py — единственный реестр адресных мутаций, source.json — сгенерированные носители/связи; --stabs требует отдельную красноту каждой связи и честный контроль · - · -
- К-09 · чисто · вход: отсутствие, чужие, пустые, email-only, многозначные ключи, чужая env-identity, hooksPath=/dev/null, профильные раскладки и station-противоположности · - · -
- К-10 · чисто · вход: захват обеих труб bytes, полное сравнение успеха и station-паритет, фактические реестр/index/HEAD/config/hooks/origin; отказы project судятся по rc и именованной причине с пустым stdout и неизменностью реестра · - · -
- К-11 · чисто · вход: ожидания и исходный реестр в памяти до субъекта, sha256 носителей до запуска, станционный результат снят в память до вызова кандидата · - · -
- К-12 · чисто · вход: Git plumbing для refs/HEAD/commit, существующий project_paths_resolve для профиля, validate_std bash для shell-формы, генерация source.json из одного build.py · - · -
- К-13 · н/п · секретных входов нет: локальный bare-origin, synthetic identity и hashes, новых credentials/CI secrets предмет не вводит · - · -
- К-14 · чисто · вход: честный контроль зелён без локальных ключей и с чужими/пустыми/повторёнными ключами после нормализации, три конформные раскладки; station-конфиг по-прежнему отвергается как базой · - · -
- К-15 · чисто · вход: количество CASES и MUTATIONS — из --model/--stabs, контракт несёт нижние границы, сгенерированные связи не копируются парами в прозу · - · -
- К-16 · чисто · вход: рисковый — права/безопасность; single-uid/доверенный PATH/конкурентный config и независимый remote-registry дефект 031 названы в НЕ ЗАЩИЩАЕТ · - · -
- К-17 · н/п · новых сервисов/операций модели 188 нет; доработка одного клиента двери без второго резолвера/реестра/identity-политики, новые замки не вводятся · - · -

## Дельта

Первое предъявление; предыдущего закоммиченного вердикта этого предмета нет.
