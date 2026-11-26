# СДАЧА 226 — профильная дверь архитектуры

Обещание: hooks.archBrief вместо селектора имени и адреса продукта; неизвестность профиля не выключает страж. Наблюдение: настоящий CLI на Git/Node/профильных мирах, раздельные stdout/stderr, HEAD/refs/файлы и argv gh. Ожидания литеральны и в памяти до субъекта. Production, реестры, CI и чужие фикстуры не меняются; overlay существует только в model/. База генерации 5b8ae0cdca9429d9d651c19d2775016e57ce271f, база исправления cbce7ecc43a2749164e972dc2ef911cc02ca3176.

Frontier сохранён: отсутствие ЛИСТА в корректном repo-профиле, даже при lock, и false — выключение; owner/repo при lock — включение. Это сохраняет отсутствие автовключения по lock и переключатель 187/203. Нет ФАЙЛА при lock — ARCH_PROFILE_MISSING; повреждение/недоступность профиля или объявленного слоя — ARCH_PROFILE; известный лист в defaults (включая false или конфликт с repo) — ARCH_PROFILE_LAYER. Неизвестные имена остаются предупреждениями М-0. Backend-ключ доставляет orchestrator отдельным PR проекта до установки 226.

КЛЕТКИ: 56 (было 45). МУТАЦИИ: 18 (было 15). СВЯЗИ: 25 (было 18). Носители: 26 (8 честных, 18 изменённых); shell с обёрткой: 25. Меры: CASES/probe.py, MUTATIONS/build.py, source.json с sha256 и исполняемый catalog. Старые клетки и связи сохранены; layer-cannot-enable усилена с разрешения пака до именованного отказа, остальные ожидания не меняются. Область implementer не расширена; context.py сверяет высшие frozen-блобы.

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-226-v1.md

Историческое Red-до: до production-реализации W --repo . давала rc 1, KLETKI 56 KRASNYH 45 на OBJECT=1ab6f19bda3ac01d15f0e9adce9f24e542400da2; свидетельство — verdicts/critic/contracts-226-v1.md §«Доказательства». Ниже проверяется состояние после реализации на базе 6d758b918382096e75ee96ff9dd20ad87841b09e: та же команда обязана дать rc 0, KLETKI 56 KRASNYH 0.

## Двери

- Repo-posle · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --repo . · 0 · 0
- Model · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --model · 0 · 0
- Stabs · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --stabs · 0 · 0
- Sintaksis · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --sintaksis · 0 · 0
- Catalog · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --catalog · 0 · 0
- Regression · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --regression · 0 · 0
- Context · fixtures/workshop_project/arch_door_profile_key_226/context.py · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/226-arch-door-profile-key.md · 0 · 0
- Spec-ready · bash scripts/check_spec_ready.sh . contracts/226-arch-door-profile-key.md · 0 · 0
- Threat-model · bash scripts/check_threat_model.sh . contracts/226-arch-door-profile-key.md · 0 · 0
- Predposylki · bash scripts/check_predposylki.sh . contracts/226-arch-door-profile-key.md · 0 · 0
- Ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- Ids · bash scripts/check_ids.sh . · 0 · 0
- Provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/226-arch-door-profile-key.md · 0 · 0
- CI-canon · bash scripts/gen_ci_steps.sh --check · 0 · 0

## Карта классов

- К-01 · чисто · вход: двери листа, кодовый предмет, рисковый процессный страж; production после freeze · - · -
- К-02 · чисто · вход: R-0103/R-0102, Л10; Б-1 закрыт различением файла и листа, таблица состояний контракта · - · -
- К-03 · чисто · вход: 203/1 187/3 170/1 188/2 186/2 193/3 184/1 996/2; прежние ожидания 203/pin186 не меняются · - · -
- К-04 · чисто · вход: context.py по высшим frozen, точные зоны без расширения implementer, отдельный backend PR · - · -
- К-05 · чисто · вход: W --model; JSON судит существующий resolver, metadata HTTP отдельно от argv · - · -
- К-06 · чисто · вход: ошибки среды/носителя rc 2; INVALID_MUTANT не засчитывает infra-отказ · - · -
- К-07 · чисто · вход: настоящий make_task и pin CLI, реальные pin/HEAD/merge; честный контроль 56/0 · - · -
- К-08 · чисто · вход: W --stabs, 18 мутантов и 25 отдельных связей; все прежние связи и новые адресные Б-1 · - · -
- К-09 · чисто · вход: missing-profile-door/no-lock, layer-cannot-enable/conflict/false, malformed-profile/layer-door, missing-layer-door; прежние типы/значения сохранены · - · -
- К-10 · чисто · вход: rc/именованная причина в stderr, пустой stdout отказа, HEAD/refs; layer-freeze/done и layer-door · - · -
- К-11 · чисто · вход: CASES и ожидаемые значения в памяти до субъекта; gh-calls только наблюдение, хеши носителей до запуска · - · -
- К-12 · чисто · вход: настоящий jq/resolver, git, node, bash -n и пин shellcheck, без двойника валидатора · - · -
- К-13 · н/п · новых секретов/сетевых разрешений нет, батарея offline · - · -
- К-14 · чисто · вход: other-absent/backend-absent при lock, explicit-false/backend-false, enabled/no-pin, minimal/mixed/long, unknown-sibling и unknown-layer-sibling · - · -
- К-15 · чисто · вход: catalog 56/18/25, carriers 26; отдельные model/stabs и regression 203/pin186 · - · -
- К-16 · чисто · вход: неизвестность профиля и ошибочный слой отказывают до пака/тегов; честное отсутствие листа не стало автовключением; key-toggle и argv сохранились · - · -
- К-17 · н/п · станционный конфигурационный предмет не меняет продуктовую модель/writers/isolationKeys · - · -

## Дельта

- К-02 · канон/инструмент · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --model --cell missing-profile-door · 0 · 0
- К-09 · канон/инструмент · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --model --cell layer-conflict · 0 · 0
- К-16 · канон/инструмент · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --model --cell malformed-profile-door · 0 · 0

## Закрытие Б-1 по классу

Способ — канон/инструмент: расширение существующего resolver и общего arch187_profile/scope, не второй форматный валидатор. Мутация критика «нет файла = выключено» и соседний мир «без файла и без lock» различены. Ошибочный слой проверен на owner/repo, false и двух объявлениях, через make_task/публичную дверь/freeze/done. Повреждение проверено на repo JSON, project JSON и отсутствующем объявленном слое. Новых судящих предикатов нет: judge/HEAD/TAG/M0_WARNING/INVALID_MUTANT не менялись; новые клетки используют их прежний оракул. Новых обещаний вне Б-1 нет.

Адресные стабы и связи живут только в build.py/source.json: st18 — missing-profile-door, st19 — layer-cannot-enable/conflict/false, st20 — malformed-profile-door/missing-layer-door/malformed-layer-door. Честные противоположности: missing-profile-no-lock; корректный repo без листа и false; owner/repo; неизвестный defaults.hooks.futureHook. Все проверены полным --model и до мутантов в --stabs.

## Наблюдаемые результаты исправления

W --repo . на OBJECT с расширением: rc 1, KLETKI 56 KRASNYH 45. Прежние 35 красных сохранены; добавились layer-cannot-enable и missing-profile-door, missing-layer-door, malformed-profile-door, malformed-layer-door, layer-conflict, layer-false, layer-door, layer-freeze, layer-done. missing-profile-no-lock и unknown-layer-sibling зелены.

W --model: rc 0, KLETKI 56 KRASNYH 0 (65.95 с). W --stabs: rc 0, SVJAZI 25 ZHIVYH 0 (156.05 с). W --sintaksis: rc 0, SINTAKSIS 25 SHELLCHECK_DIFFERENTIAL 6 BASELINE_DIAGNOSTICS 30. W --catalog: rc 0, KLETKI 56 STABY 18 SVJAZI 25. context.py: rc 0, FROZEN 199 BLOBS 199 OVERLAPS 123 MISSING 0. W --regression: rc 0, CELLS=21 FAILURES=0, pin186 5/5; ожидания не ослаблены (47.46 с).

## Процесс

Пишется только собственная isolated-копия; WORKTREE — адрес доставки. Общий NABLIUDENIA_ARCHITECT.md в wip не правится, номера А вручную не выдаются. Процессное наблюдение для main: заданная база cbce7ecc4 предшествует отдельному коммиту вердикта 1747cff791; gate дельты требует вердикт именно в HEAD, не только доступный git object. Проверка сдачи поэтому требует сборки кандидата с уже закоммиченным Crit226, без копирования/переавторства его файла в architect-зону. Источник: check_sdacha.sh:293. Риск — ложная краснота формы, не дефект продукта; ловец — корректный verification-base оркестратора.

## Формальные двери исправления

В сетевом клоне `tmp/clean226b` внутри своей копии HEAD=1747cff791e39043b0742ad85076bf9a4529e526 (предыдущий вердикт уже закоммичен); поверх скопированы только контракт и семья кандидата, production совпадает с OBJECT. Единственный remote — канонический origin. Прогоны последовательные, TMPDIR внутри клона, VALIDATE_STD_SHELLCHECK задан, SDACHA_TIMEOUT_SEK=600 / SDACHA_BUDZHET_SEK=2400.

`bash scripts/pre_critic.sh contracts/226-arch-door-profile-key.md` → rc 0, `КРИТИК: дверь зелёная` (314.74 с). Затем отдельный `bash scripts/check_sdacha.sh . contracts/226-arch-door-profile-key.md --run` → rc 0, `СДАЧА: лист зелёный (двери=15 карта=17/17 дельта=3)` (363.96 с). Таймаутов не было. Эти прогоны повторно исполнили полный model/stabs/регресс и три адресных дельта-команды; изменённые lists/counts сверены исполняемым catalog. Временные клон и драйвер не входят в сдачу.

