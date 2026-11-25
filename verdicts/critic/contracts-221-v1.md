FAIL
OBJECT=bdb527504b6a4f509a2bf8ba902ef3e18dc238e5
СУД: repo=dev-harness; предмет=221; фаза=v1; роль=critic; вызов=1 (полный); модель-план=zai/glm-5.3 (критики на GLM, слово владельца); модель-факт=zai/glm-5.3 (сессия Crit221, трасса настоящего вызова); предыдущий=нет; класс риска=рисковый (заявлено architect: права/безопасность — подтверждаю: запись в dual-control зону реестра проекта, исполнение commit-стража, identity); SHA=bdb527504b6a4f509a2bf8ba902ef3e18dc238e5; исключение=нет

# Суд контракта 221 до заморозки — вызов 1 (полный)

Судится `contracts/221-mint-line-proekt.md` на OBJECT `bdb527504b6a4f509a2bf8ba902ef3e18dc238e5` (= main `8b52fade7` + 3 architect-коммита, только контракт и семья `fixtures/workshop_project/mint_line_proekt_221/`; `git diff 8b52fade7 HEAD -- scripts/mint_line.sh` пуст). Вердикта в дереве OBJECT не было. Запись «СУД (ДО ВЫЗОВА)» по 221 в HANDOFF дерева OBJECT не наблюдается — запись ведёт оркестратор в своём WORKTREE, по заданию не повод для стопа.

## Перепроверка заявлений автора (все rc сырые, моими прогонами)

- `bash scripts/check_sdacha.sh "$PWD" contracts/221-mint-line-proekt.md --run` → rc 0, «лист зелёный (двери=12 карта=17/17 дельта=0)» — совпало.
- `bash scripts/pre_critic.sh contracts/221-mint-line-proekt.md` → rc 0 — совпало.
- `bash fixtures/workshop_project/mint_line_proekt_221/red_mint_line_proekt_221.sh --repo .` → rc 1, `KLETKI 16 KRASNYH 9` (красные p01–p08, p11; p09/p10/s01–s05 зелёные) — совпало.
- `… --model` → rc 0, `KLETKI 16 KRASNYH 0` — совпало.
- `… --stabs` → rc 0, контроль 16/16 зелёный, `STABY 12 SVJAZI 15 ZHIVYH 0` — совпало.
- `… --sintaksis` → rc 0, `SINTAKSIS 15 SHELLCHECK 2` (с пином VALIDATE_STD_SHELLCHECK) — совпало; без пина мной наблюдён rc 2 `VALIDATOR_MISSING: shellcheck` — fail-closed работает (К-06).
- `bash scripts/check_precision_gate.sh . contracts/221-mint-line-proekt.md` → rc 0 (норма 043 исполнена живой командой).
- `bash scripts/gen_ci_steps.sh --check` → rc 0. `bash scripts/check_provodka.sh . contracts/221-mint-line-proekt.md` → rc 1 «guard не подключён» — честно объявлено автором и контрактом как done-условие ПОСЛЕ подключения ЗОНА orchestrator, не блок.
- План: строки 221 в `registry/plan.tsv` нет (`grep -n … registry/plan.tsv` → rc 1, пусто). Дословно: отказ только по отсутствию строки плана 221 не блок — внешний owner-PR #1350 в очереди, plan.tsv не зона architect.

«Существующее» сверено живьём: `scripts/mint_line.sh:123–141` (проверка исполняемого effective pre-commit, содержимое не судится), `:190–201` (project_paths_resolve, профильный реестр), `:224` (четыре GIT_AUTHOR/GIT_COMMITTER orchestrator явно); `scripts/check_staged.sh:203–267` (нога (д') 080/инв.18: присутствие user.name/user.email в общем config → rc 1), `:780/:793` — литеральное чтение `HEAD:registry/contracts.tsv` и `${origin_main_sha}:registry/contracts.tsv` — заявленный дефект подтверждён, в «НЕ ЗАЩИЩАЕТ» не скрыт; `reserve_project_contract.sh:54+` (профиль-валидация, теги, строку не минтит, хуков не ставит), `connect_project.sh:203–244` (0 упоминаний hooksPath/user.* — установщика нет), `accept_task_commit.sh:218–225` (-c identity при cherry-pick), `push_product.sh:91–96` (профиль обязателен, mint-коммита нет), `next_id.sh:333–450` (единый project_paths_resolve). Frozen-зоны сверены `git show frozen/contracts/{068/1 cc4904ccf, 031/4 dc550fda, 080/4, 996/2, 125/1, 140/5, 016/4, 992/2}`: mint_line.sh — ЗОНА architect 068/1 (ПЕРЕСЕЧЕНИЕ implementer объявлено, строки 65–71) и ЗОНА implementer 996/2 (та же роль — union, пересечения не требует); 031/4 mint_line не владеет; check_staged 221 не раздаёт. Боль Н-456 подтверждается обоими письмами бэкенда (1200: «дверь 031 отключена конфигом» без хука; 1210: ручной внешний hooksPath + «user.name/email в .git/config клона дают отказ 016»); записи Н-456 в NABLIUDENIA.md базы нет — контрактом названо честно, не выдуманная запись.

Двусторонность на РЕАЛЬНЫХ git-мирах (не мок-эхо): станционный байт-паритет s01–s05 — полный кортеж (rc, stdout, stderr, HEAD, status, реестр, HEAD:реестр, identity, config, .git/hooks, origin-refs) против базового канона base `8b52fade7`; проектные миры — p01 (нет хука, rc 0, MINTED, страж отработал), p02/p03/p04/p11 (чужие/пустые/email-only/многозначные ключи → нормализация → orchestrator), p05 (чужая env-identity не даёт чужого лица), p06 (локальный core.hooksPath=/dev/null перекрыт process-local назначением), p07 (живой отказ двери → rc 1, реестр не изменён), p08 (повтор), p09 (--no-verify → rc 1 «неизвестный аргумент»), p10 (не-репозиторий → rc 2). Как реализация обязана позеленеть `--repo` без ослабления стража и без постоянной правки hooksPath — по тексту контракта (строки 20, 33–34): project-ветвь по признаку harness.project.json сама назначает одноразовый pre-commit → sibling check_staged с явным корнем, process-local git-конфигом (env GIT_CONFIG_COUNT — старше local в precedence, потому p06 зелёный, а постоянный core.hooksPath не трогается), нормализация запрещённых ключей штатным `git config --local --unset-all` (rc 5 = отсутствие — допустимо), commit с уже имеющейся явной env-identity; станционная ветвь не меняется. Живая дверь остаётся судьёй: ожидаемый stderr — точный вывод check_staged (judged/ok-строки), p07 требует настоящего отказа.

## Блоки

БЛОК-1 БЛОКИРУЕТ contracts/221-mint-line-proekt.md:33 (также :20 «удаляет временный каталог на выходе») — инвариант 2 «одноразовый хук удаляется на выходе» заявлен, но не имеет различающей клетки.
ОБЯЗАТЕЛЬСТВО: инвариант 2 (строка 33): «Постоянные core.hooksPath и файлы имеющихся хуков не меняются; одноразовый хук удаляется на выходе»; Frontier (строка 20): «удаляет временный каталог на выходе».
СОСТОЯНИЕ: модель/реализация mint_line, в которой очистка удалена (в модели — строка `trap 'rm -rf -- "$HOOK_WORK"' EXIT`, модель `fixtures/workshop_project/mint_line_proekt_221/model/mint_line.sh:136`), после вызова остаётся каталог с исполняемым pre-commit.
НАБЛЮДЕНИЕ: одноразовый клон OBJECT, в build.py единственная мутация `m2-no-cleanup` (строка trap заменена на `: # trap removed…`), `python3 build.py`, затем `bash fixtures/workshop_project/mint_line_proekt_221/red_mint_line_proekt_221.sh --stabs` → `stabs/m2-no-cleanup/mint_line.sh p01-no-hook GREEN` … `STABY 1 SVJAZI 1 ZHIVYH 1`, rc батареи 1 — мутант жив. Ни одна клетка не inspect содержимое TMPDIR-мира после вызова (probe221.py observe() читает rc/обе трубы/HEAD/status/реестр/identity/config/.git/hooks/origin — не scratch; TMPDIR проба локализует в `<мир>/scratch`, который никто не проверяет).
ОБХОД: реализация без очистки удовлетворяет всем командам приёмки (--repo после реализации rc 0, --model rc 0, --stabs rc 0, --sintaksis rc 0, pre_critic rc 0, check_sdacha --run rc 0) — критерий green, обещанная работа не сделана: источник входа — любой проектный вызов mint_line (поддерживаемая операция предмета), источник ошибочного механизма — удаление имеющейся операции очистки в модели.
ПРОИСХОЖДЕНИЕ: полный вызов 1 (новая находка полного прохода).
КЛАСС: К-08.
Закрывающее свойство (единственную реализацию не предписывает): различающая клетка остатка одноразового хука — наблюдение scratch/TMPDIR-мира после успешного и отказного вызова (пусто → зелёная, остался pre-commit → красная); честная модель зелёная (trap удаляет), мутант красный. Альтернатива — снять обещание из инварианта 2 и Frontier, но это сужение обязательства предмета, а не закрытие.

БЛОК-2 БЛОКИРУЕТ contracts/221-mint-line-proekt.md:34 — инвариант 3 «Остальная конфигурация сохраняет ключи/значения» не покрыт по семейству ключей [user] помимо запрещённых.
ОБЯЗАТЕЛЬСТВО: инвариант 3 (строка 34): «После project-префлайта удаляются ВСЕ локальные user.name/email… Остальная конфигурация сохраняет ключи/значения».
СОСТОЯНИЕ: модель/реализация, где нормализация сносит всю секцию [user] (замена `git config --local --unset-all "$key"` модели `model/mint_line.sh:129` на `git config --local --remove-section user`), в конформном проектном клоне, где помимо запрещённых ключей стоит любой иной ключ [user] (например user.signingkey).
НАБЛЮДЕНИЕ: одноразовый клон OBJECT, единственная мутация `m3-user-section`, `--stabs` → `stabs/m3-user-section/mint_line.sh p02-foreign-config GREEN` … `ZHIVYH 1`, rc 1 — мутант жив: в мире p02 после обеих форм нормализации парсированные строки конфига идентичны (world.other_config не содержит ни одного ключа [user] сверх name/email). Контроль полноты: мутация `m4-wipe-config` (`: > .git/config`) красится (p02 RED UNRELATED_CONFIG_CHANGED — core/remote/branch-ключи различаются), т.е. различающая способность есть только вне секции [user].
ОБХОД: конформный клон с user.signingkey + реализация с remove-section → ключ молча удалён, все двери зелёные. Источник входа достижим на объявленном шве: определение конформных миров (строка 50) не исключает иных локальных ключей [user], а болевой клон Н-456 уже несёт [user]-секцию (письмо 1210: «в клоне остались user.name/email от прошлых коммитов — снял git config --local --unset»); источник ошибочного механизма — замена точечного unset-all двух ключей на удаление секции в модели.
ПРОИСХОЖДЕНИЕ: полный вызов 1 (новая находка полного прохода).
КЛАСС: К-09.
Закрывающее свойство: клетка с иным ключом [user] (например user.signingkey в p02 или отдельная клетка), обязанным сохраниться, — существующий предикат UNRELATED_CONFIG_CHANGED уже сравнивает все прочие строки локального конфига; честная модель зелёная (unset-all не трогает прочие ключи), мутант красный.

Оба блока — один класс причин по существу (обязательство контракта без различающей клетки), но два разных обязательства (очистка / сохранение конфига) с разными закрывающими свойствами. Остальные атаки батареи выдержала (живых мутантов кроме названных нет): `m1` пустой хук (`exit 0`, дверь не вызывается) → p01 RED LIVE_DOOR_OUTPUT; `m4` очистка всего `.git/config` → p02 RED; `m5` постоянная запись `core.hooksPath` в local config → p01 RED HOOK_CONFIG_CHANGED/UNRELATED_CONFIG_CHANGED; `m6` подавление rc судьи внутри хука (`bash check_staged … || exit 0`) → p07 RED REFUSAL_REASON/REFUSAL_NOT_ATOMIC.

## НЕ ЗАЩИЩАЕТ (остатки — приняты, ловцы названы)

- Компрометация установки инструментов, PATH/git, single-uid identity-forgery, авторитет — прежние границы 016/023/031; ловцы — изоляция станции, CI, reviewer. Ручной `git commit --no-verify` вне mint_line — прежний остаток 068, ловец CI check:zones.
- Независимый дефект профильного пути 031: check_staged.sh:780/793 читает HEAD/origin `registry/contracts.tsv` литерально при ином workflowPaths.registry — подтверждено мной по коду; клетка отказа p07 использует конформный проект с корневым реестром, где судья реально красен; исправление — отдельный предмет оркестратору; ловец — адресная remote-only project-проба следующего предмета.
- Конкурентная запись в общий git-config при нормализации, недоступность FS/сети — новых транзакций/замков 221 не вводит; ловец — живой запрет 080 до коммита и именованный отказ с повтором после устранения причины.

## Советы

- СОВЕТ build.py (модель): `export NEXT_ID_LIB=1` инертен — check_staged.sh:102 и check_charter.sh:336 сами ставят NEXT_ID_LIB=1 до source next_id.sh, и никто в цепочке хука не читает его из env иначе; пояснить назначение или убрать, чтобы implementer не копировал мёртвую строку как обязательную.
- СОВЕТ contracts/221-mint-line-proekt.md:50: положительный минт на корневой раскладке проекта не покрыт ни одной клеткой успеха (корневая раскладка встречается только в отказной p07); добавить зелёную клетку успеха на корневой раскладке либо сузить формулировку «раскладки корневая, .harness и .workflow/book остаются зелёными» до фактического покрытия.

## Карта классов

К-01: чисто — bash scripts/check_sdacha.sh "$PWD" contracts/221-mint-line-proekt.md --run → rc 0 (двери=12 карта=17/17 дельта=0), pre_critic rc 0, precision-gate rc 0, строки плана 221 в registry/plan.tsv нет (grep rc 1) — внешний owner-PR #1350, отказ только по этому не блок
К-02: чисто — вход: task-architect221, затравка и оба письма бэкенда прочитаны, боль Н-456 подтверждена, отсутствие записи Н-456 в NABLIUDENIA.md базы названо честно (grep rc 1), sourceCanon не объявлен
К-03: чисто — вход: git show frozen 068/1 cc4904ccf (mint_line.sh в ЗОНА architect — ПЕРЕСЕЧЕНИЕ объявлено), 031/4 dc550fda (не владеет), 080/4 (check_staged не раздаётся), 996/2 (mint_line.sh в ЗОНА implementer — та же роль), 125/140/016/992 сверкнуты
К-04: чисто — вход: все файлы семьи в ЗОНА architect (строка 65), implementer — только scripts/mint_line.sh (66), orchestrator — ci-steps/ci-zamery/ci.yml, check_precision_gate rc 0
К-05: чисто — вход: каждый пункт приёмки несёт команду с rc (red_*.sh --repo/--model/--stabs/--sintaksis, pre_critic, check_sdacha, check_provodka done-условие, gen_ci_steps)
К-06: чисто — вход: без пина shellcheck --sintaksis дал rc 2 VALIDATOR_MISSING (наблюдено критиком), нет python3 в обёртке — rc 2
К-07: чисто — вход: --model rc 0 16/0 на настоящем git и настоящем check_staged из дерева (install копирует scripts/ целиком), не двойник судьи
К-08: блок — БЛОК-1 «одноразовый хук удаляется на выходе» без различающей клетки (мутант m2 жив, ZHIVYH 1)
К-09: блок — БЛОК-2 «Остальная конфигурация сохраняет ключи/значения» без клетки по иным ключам [user] (мутант m3 жив, ZHIVYH 1)
К-10: чисто — вход: observe() захватывает rc, обе трубы bytes, HEAD, status, реестр и HEAD:реестр, identity, конфиг, .git/hooks, origin-refs — полный выход, не маркеры
К-11: чисто — вход: ожидания и канон станции читаются в память до субъекта (observe(baseline) до candidate), sha256 носителей до запуска (check_carriers)
К-12: чисто — вход: git plumbing для refs/HEAD/commit, единый project_paths_resolve, validate_std bash для shell-формы, source.json генерируется из одного build.py
К-13: н/п — секретных входов нет: локальный bare-origin, синтетические identity и хеши, новых credentials/CI secrets предмет не вводит
К-14: чисто — вход: честная эквивалентная модель зелёная 16/0 в трёх раскладках, мутации критика m1/m4/m5/m6 красятся, живые m2/m3 отнесены к К-08/К-09
К-15: чисто — вход: 16 клеток и 9 красных из вывода --repo (rc 1), 16/0 из --model (rc 0), STABY 12 SVJAZI 15 ZHIVYH 0 из --stabs (rc 0), NOSITELI 14, двери=12 — числа из вывода
К-16: чисто — вход: рисковый права/безопасность подтверждён (dual-control реестр, commit-страж, identity), модель угроз форма и граница по смыслу, дефект 031-пути явно в НЕ ЗАЩИЩАЕТ с ловцом
К-17: н/п — новых операций/схем модели 188 нет: правка клиента существующей двери без второго резолвера/реестра/identity-политики

## Сырые выводы ключевых прогонов

- check_sdacha --run: «СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=0)» rc=0; pre_critic: «КРИТИК: дверь зелёная» rc=0.
- --repo .: «KLETKI 16 KRASNYH 9» rc=1 (REPO p01…p08, p11 RED — у p01–p06, p11 REFUSAL-независимые MINT_RC/LIVE_DOOR_OUTPUT/REGISTRY_DELTA/FILE_IDENTITY_LEFT, у p07/p08 REFUSAL_REASON; p09, p10, s01–s05 GREEN).
- --model: «KLETKI 16 KRASNYH 0» rc=0.
- --stabs: контроль CONTROL 16×GREEN; st01–st12 по своим связям RED; «STABY 12 SVJAZI 15 ZHIVYH 0» rc=0.
- --sintaksis: «SINTAKSIS 15 SHELLCHECK 2» rc=0; без VALIDATE_STD_SHELLCHECK — «VALIDATOR_MISSING: shellcheck» rc=2.
- check_precision_gate: «OK» rc=0. gen_ci_steps --check rc=0. check_provodka: «проводка: guard не подключён: fixtures/workshop_project/mint_line_proekt_221/red_mint_line_proekt_221.sh не вызывается в .githooks/ или .github/workflows/» rc=1 (объявлено как done-условие orchestrator).
- Мутации критика (одноразовые клоны, каждый удалён после прогона): m1-empty-hook → p01 RED LIVE_DOOR_OUTPUT (пойман); m2-no-cleanup → p01 GREEN, «STABY 1 SVJAZI 1 ZHIVYH 1» rc=1 (ЖИВОЙ — БЛОК-1); m3-user-section → p02 GREEN, ZHIVYH 1 rc=1 (ЖИВОЙ — БЛОК-2); m4-wipe-config → p02 RED MINT_RC,…,UNRELATED_CONFIG_CHANGED (пойман); m5-persistent-hookspath → p01 RED UNRELATED_CONFIG_CHANGED,HOOK_CONFIG_CHANGED (пойман); m6-rc-suppress → p07 RED REFUSAL_REASON,REFUSAL_NOT_ATOMIC (пойман).
