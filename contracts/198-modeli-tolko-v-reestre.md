# Контракт 198 — модели только в реестре

КЛАСС ЗАДАЧИ: кодовый — один резолвер назначений моделей (единственная точка
разбора цепочки roles→tiers→models в `scripts/roles.ts`) + одна
батарея-матрица «роль × тир × запасная × проект» с обманными стабами; замена
жёстких привязок потребителей резолвом через реестр. Реализация — implementer
после freeze; до freeze реализации нет.

КЛАСС РИСКА: рисковый — основание: подмена ожидаемой модели судьи/роли ломает
независимость суда и учёт (дверь `check_sud_model.sh` — ядро ролевой проводки,
104/173), а молчаливый дефолт модели маскирует потерю назначения; кроме того,
предмет меняет исполняемый шов станционного лаунчера (`workshop`).

КОНТЕКСТ: слово владельца 2026-11-16 ~16:30 UTC через консультанта «модели
через реестр — старт»; номер выдан `next_id.sh` (тег id/CONTRACT/198, строка
реестра 198 уже заминчена, `registry/contracts.tsv`). Принцип владельца:
«чтобы ничего жёсткого не было вписано в харнессе: завтра поменяем модель —
всё переключится само; омп поменял названия — завтра опять может поменять».
Критерий готовности: смена реестра (в духе открытого owner-PR #1000
`owner/critic-terra-1116`) переключает всех потребителей без правки кода —
это доказывается перестановками матрицы. Правило 17 AGENTS.md (ничего жёсткого
про формат/имена внешнего omp) действует на всё написанное здесь: код батареи
не несёт литералов внешних моделей (значения миров выводятся из реестра в
рантайме; литерал есть только внутри обманных стабов — предмет их обмана).

## Предмет

ЕДИНСТВЕННЫЙ источник «какая модель у роли/тира» — `config/agent_models.json`
(models → tiers → roles). Предмет закрывает четыре инварианта:

- **Р1 Резолвер.** `scripts/roles.ts` — единственная точка резолва НАЗНАЧЕНИЯ
  РОЛИ: функция `resolveRoleModel(am, role)` (роль → тир → модель/фолбек/
  autoFallback, именованные отказы) и CLI `--resolve-model <роль> [--root <кат>]`.
  Семантический уровень семейств (`@fam` → id) остаётся в существующем
  `resolveModelRef` — второй разбор не заводится, роль-уровень встраивается в
  тот же модуль тем же разбором.
- **Р2 Дверь.** `scripts/check_sud_model.sh` берёт ожидание (tier, expected,
  fbexpected) у резолвера Р1; собственный jq-разбор цепочки
  (`.roles[`/`.tiers[`/`.models[`) из двери удаляется. Обязательства 104/173
  (коды rc, литеральные сравнения, алфавиты, фолбек только из объявленного
  списка тира, нормализация имён 173) неизменны.
- **Р3 Шов --fable.** `workshop` берёт модель режима `--fable` резолвом роли
  `consultant` через Р1; grep литерального семейства и упоминание семейства
  как источника модели удаляются. Имя флага `--fable`, read-only семантика
  режима и текст промпта режима неизменны — меняется только источник модели.
- **Р4 Опечатка (малая правка).** `scripts/check_project_session.sh`,
  константа `ZAGOLOVOK_PRAVIL` = «## Правила, каждое из которых уже стоило
  время**ни**» — канон `AGENTS.md:216` (един с `scripts/gen-harness.ts:187`
  `AGENTS_RULES_HEADER`). Сегодня литерал расходится с каноном, секция правил
  никогда не находится, множество правил пусто — недоставка правил проектной
  сессией НЕ обнаруживается (ложное молчание поля pravila). Правка — литерал
  к канону; перечень полей, порядок печати и rc неизменны.

Резолвер НЕ подставляет ожидаемое значение проверке по её имени/режиму: нет
веток, особых флагов или env-признаков «вызван проверкой» (правило 3 нормы;
ловится парой клеток, в т.ч. `resolver_plain_call_parity`; двойник-«сниффер»
назначен этой клетке кодом `STAB_BIND` в `probe.py`, не прозой).
Отсутствие роли/тира/алиаса/пустая строка модели — именованный отказ
(ROLE_UNKNOWN / TIER_MISSING / ALIAS_UNRESOLVED / MODEL_EMPTY, rc 1),
отсутствие/неразбор реестра — REGISTRY_MISSING / REGISTRY_INVALID, rc 2;
молчаливый дефолт GLM или любой другой модели запрещён.

Грамматика CLI Р1 (одна строка stdout при rc 0):
`<тир>\t<модель>\t<фолбек|->\t<autoFallback true|false>`; фолбек `-` при
null/отсутствии; autoFallback `false` при отсутствии флага (канон `_comment`
реестра: «без флага подмена ручная», Н-50); литеральный id тира (без `@`)
проходит как есть. `--root` задаёт корень реестра (по умолчанию — относительно
самого скрипта, как `agentModels()`).

## Существующее

Сверено живьём по дереву wip/198/architect (база 1cf5fdd1cd) и origin/main
967d36c028 (теги fetched); расхождения дерева и доков — дереву.

1. **186 v2 ЗАМОРОЖЕН** (тег `frozen/contracts/186/2` = 66d8ea3166, в main
   85afea305d; реализация в полёте — агент Impl186). v+1 уже забрал у 198
   критика-факт двери L1 и ролевые нормы: A1 `scripts/merge_architecture_pr.sh`
   (env-дефолт `zai/glm-5.3` удаляется, цепочка `roles["critic"] → tiers →
   models` с отказом `CRITIC_MODEL_UNRESOLVED`), B1–B3 (батарея 186,
   перестановки @glm/@gpt-terra/@gpt-sol), C10–C13 (`roles/orchestrator.md:438,446`,
   `roles/architecture-steward.md`), D1–D3. **198 не трогает** ни дверь L1, ни
   батарею 186, ни эти нормы: 186 читает реестр сам по СВОЕМУ замороженному
   интерфейсу (ПУТЬ/ЦЕПОЧКА/СРАВНЕНИЕ/ОТКАЗ — дословные обязательства v+1);
   резолвер 198 — точка для остальных потребителей. Дрейф цепочек исключён
   парами батарей: дверь L1 пинится батареей 186 на перестановках, резолвер и
   дверь судей — батареей 198; обе батареи пинят одну и ту же документированную
   цепочку, расхождение любой стороны красит свою батарею.
2. **129** (PR #1008 OPEN, `wip/int-1297/architect`): `read_task_results()` —
   единственный адаптер формата omp, маркер M129. 198 не пересекается: про
   формат внешнего omp здесь не пишется ничего жёсткого (правило 17).
3. **998** (frozen 998/1): гарантирует routing-грамматику, композицую
   роль→тир→модель на живом реестре, паритет тел implementer/implementer-glm,
   фазы дрейфа генератора (`fixtures/pravila_modelei_998/`, decoy_all_roles.ts
   и др.). Закрепления конкретных моделей в его батарее — B4/B5 — предмет
   **998 v+1 по слову владельца**, не 198: батарея 198 НЕ судит паритет тел и
   routing (инварианты 998), она судит согласованность резолва с генерацией
   на перестановках (значения modelRoles/frontmatter == выходу резолвера).
4. **owner-PR #1000** (`owner/critic-terra-1116`, OPEN): смена
   `tiers[roles.critic].model` на `@gpt-terra` — живой сценарий «смена
   реестра переключает всё сама»; toy-реплика в батарее — клетки
   `door_swap_green`/`door_stale_primary` и резолверные перестановки. Владелец
   реестра — owner-PR по нормам 998; 198 значений реестра не меняет.
5. **roles.ts и потребители сегодня**: `resolveModelRef` — единственный разбор
   `@семейство` (генератор и `--resolve-overlay` зовут его); роль-уровня НЕТ —
   поэтому дверь судей дублирует цепочку в jq (`check_sud_model.sh:189–228`),
   а `workshop --fable` (636–647) grep-ит литеральное семейство `fable` —
   обе привязки заменяются вызовом Р1. `models_actual.sh` (TSV — экстрактор
   факта; human — читает СГЕНЕРИРОВАННУЮ декларацию) и
   `.omp/extensions/fallback-route.ts` (читает сгенерированный конфиг) —
   реестровые производные, не меняются. `check_sud_model.sh` УЖЕ без
   vendor-whitelist — замена jq-цепочки на Р1 сохраняет поведение (клетки
   двери зелёны ДО и ПОСЛЕ — регрессионная защита ПЕРЕСЕЧЕНИЯ).
6. **Провайдерная интеграция и эксплуатация** (инвентарь A3/A4/A6/A7):
   workshop-ключи zai/minimax (`:268–275`), OAuth-исключения
   `overlay.sh:167–176`, тариф `config/metering.json` (A6), таймеры
   `ops/server/root/systemd/orch-peak-*` (A7) — НЕ выбор модели: провайдерная
   auth/тарифная/эксплуатационная политика, отдельные предметы и развилки
   (ниже), 198 их не трогает.
7. **Маршрутизация всех 31 группы инвентаря** (консультантский инвентарь
   `/home/harness/consultant/hardcoded-models.md`, A=7/B=5/C=13/D=6; сверено с
   деревом). Владелец определён по живым заморозкам; «198» = зона implementer
   этого контракта:
   - A1, B1–B3, C10–C13, D1–D3 → **186 v2 (уже заморожен, реализация в полёте)**.
   - A2 (workshop --fable) → **198 (Р3)**.
   - Дубль-резолв двери (F-класс `check_sud_model.sh:189–228`) → **198 (Р2)**.
   - Р4 (опечатка заголовка) → **198 (малая правка)** — подтверждена живьём:
     `check_project_session.sh:75` «…стоило время» против канона AGENTS.md:216
     «…стоило времени».
   - B4, B5, C7, D4 → **998 v+1** (слово владельца, отдельный предмет).
   - C1, C2 (arbiter:53,63) и C3, C4 (critic/critic-sol «Sol») → v+1
     владельца норм 166/188/192 — прозa ролей не в зоне 198 (расширение зоны
     чужого предмета запрещено, 061); записи ниже в РАЗВИЛКАХ.
   - C5, C6 (consultant @fable-проза) → v+1 владельца 029.
   - C8 (orchestrator:190, политика остановки slow/task-glm) → v+1 владельца
     оркестраторских норм (живая политика остановки, слово 2026-10-25/26).
   - C9 (слот MiniMax) → РАЗВИЛКА (slot-policy владельца).
   - D5 (145/4), D6 (147/3, 149/2, 163/1) → проектные предметы (Complior-mob,
     Gespräch, CI-моб), не станция.
   - A3, A4, A5 (ключи/OAuth/оверлеи models-*.yml) → отдельный предмет
     провайдерно-лаунчерной политики (вторая очередь инвентаря §7).
   - A6 (тариф метеринга) → РАЗВИЛКА (деньги).
   - A7 (orch-peak) → РАЗВИЛКА (эксплуатационная политика z.ai).
8. **Уже начатое**: живых веток/PR по резолверу ролей нет (ls-remote
   origin/main, PR #1000/#1006–#1009 — предметы 129/186/997/999, не 198);
   заглушки контракта в дереве нет — этот файл и есть контракт (строка реестра
   заминчена 1cf5fdd1cd).

## Зоны и проводка

ЗОНА architect: contracts/198-modeli-tolko-v-reestre.md fixtures/workshop_project/modeli_tolko_v_reestre_198/
ЗОНА implementer: scripts/roles.ts scripts/check_sud_model.sh workshop scripts/check_project_session.sh
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml

ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/modeli_tolko_v_reestre_198/ — 054 новая семья каталога; файлы 054 не меняются.
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/modeli_tolko_v_reestre_198/ — 055 новая семья каталога; файлы 055 не меняются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/roles.ts — 002 только добавление роль-уровня резолва (resolveRoleModel + CLI --resolve-model); прежний разбор/инварианты не меняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/roles.ts — 010 только добавление роль-уровня резолва (resolveRoleModel + CLI --resolve-model); прежний разбор/инварианты не меняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/roles.ts — 998 только добавление роль-уровня резолва (resolveRoleModel + CLI --resolve-model); routing-грамматика, паритет тел и фазы генератора 998 не меняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_sud_model.sh — 099 только источник ожидаемой модели (вызов roles.ts --resolve-model); обязательства двери неизменны
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_sud_model.sh — 104 источник ожидаемой модели (замена jq-цепочки :189–228 вызовом roles.ts --resolve-model); обязательства двери (rc 0/1/2, алфавиты, литеральные сравнения, привязка вердикта) неизменны
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_sud_model.sh — 173 то же; нормализация имён sud_same_model не тронута
ПЕРЕСЕЧЕНИЕ implementer: workshop — 002 только блок --fable (источник LIVE_MODEL); прочие блоки не меняются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 005 только блок --fable (источник LIVE_MODEL); прочие блоки не меняются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 010 только блок --fable (источник LIVE_MODEL); топология ролей не меняется
ПЕРЕСЕЧЕНИЕ implementer: workshop — 028 только блок --fable (источник LIVE_MODEL); прочие блоки не меняются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 030 только блок --fable (источник LIVE_MODEL); инвентарь/гонки спавна не меняются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 054 только блок --fable (источник LIVE_MODEL); профили/слои проекта не меняются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 055 только блок --fable (источник LIVE_MODEL); прочие блоки не меняются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 058 только блок --fable (источник LIVE_MODEL); прочие блоки не меняются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 060 только блок --fable (источник LIVE_MODEL); самодостаточность/экспорты 060 не меняются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 070 только блок --fable (источник LIVE_MODEL); прочие блоки не меняются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 105 только блок --fable (источник LIVE_MODEL); прочие блоки не меняются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 125 только блок --fable (источник LIVE_MODEL); прочие блоки не меняются
ПЕРЕСЕЧЕНИЕ implementer: workshop — 996 только блок --fable (источник LIVE_MODEL); проектный контекст/топология не меняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_project_session.sh — 125 только литерал заголовка правил к канону AGENTS.md; перечень полей, порядок печати, rc неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 140 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 141 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 142 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 143 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 145 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 146 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 147 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 148 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 149 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 153 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 157 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 158 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 159 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 163 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 166 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 167 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 168 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 169 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 170 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 172 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 173 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 174 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 175 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 182 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 184 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 185 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 186 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 187 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 188 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 189 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 190 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 195 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 197 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 995 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только новая строка 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 140 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 141 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 142 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 143 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 145 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 146 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 147 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 148 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 149 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 153 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 157 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 158 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 159 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 163 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 166 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 167 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 168 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 169 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 170 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 172 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 173 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 174 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 175 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 182 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 184 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 185 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 186 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 187 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 188 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 189 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 190 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 195 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 197 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 995 только замер 198; чужие строки неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 140 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 141 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 142 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 145 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 146 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 147 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 148 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 149 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 153 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 157 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 158 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 159 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 163 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 166 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 167 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 168 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 169 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 170 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 172 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 173 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 174 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 175 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 182 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 184 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 185 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 186 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 187 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 188 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 189 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 190 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 195 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 197 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 994 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 995 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 997 только шаг 198; чужие шаги неизменны
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 998 только шаг 198; чужие шаги неизменны

ПРОВОДКА:
- guard=scripts/roles.ts (единственная точка резолва назначений: роль→тир→семейство→id; потребитель с собственным разбором цепочки — дефект, ловят repo-клетки швов батареи 198 в CI)
- guard=scripts/check_sud_model.sh (ожидание судейской модели — только у резолвера)
ПРОВОДКА-ЭНФОРСМЕНТ: батарея подключается в CI bash-раннером `bash fixtures/workshop_project/modeli_tolko_v_reestre_198/red_modeli_reestra_198.sh` (--model зелёный прогон), не как python-проба; repo-клетки R4–R7 ловят возврат собственного разбора/литерала в швах.

## Приёмочный критерий

Форма — сценарии (дано/когда/тогда) и правила; каждой зелёной клетке
сопоставлена негативная на том же мире (полный перечень клеток и привязка
стабов — КОД батареи `probe.py` (словари CELLS и STAB_BIND), не проза — Н-39).
Все ожидания вычисляются оракулом в памяти батареи (собственный разбор мира на
python) ДО вызова субъекта; значения миров — toy-иды, выводимые из реестра
рантаймом (инвариантность к значениям). Замеры и пробы перемерены по живому
дереву (выводы команд ниже).

- Дано: мир с реестром живой-формы (13 ролей, toy-иды); когда
  `node <мир>/scripts/roles.ts --resolve-model <роль> --root <мир>`; тогда
  rc 0 и строка `тир\tмодель\tфолбек\tautoFallback` == оракулу для КАЖДОЙ роли
  (клетка resolver_matrix_base; сегодня красна — CLI нет, rc 0 с пустым
  выводом). Негативная: роль вне roles → rc 1 ROLE_UNKNOWN, не строка с
  моделью (resolver_role_unknown).
- Правило; перестановка основной модели роли / версии семейства / фолбека /
  autoFallback — правкой ТОЛЬКО мира; резолвер следует без правки кода
  (resolver_primary_swap, resolver_family_version_swap,
  resolver_fallback_swap, resolver_autofallback_toggle). Негативная на той же
  перестановке: прямая заглушка «всегда модель X» обязана краснеть минимум
  одной клеткой матрицы (словарь двойников — `stabs/`, назначение каждого —
  код `STAB_BIND` в `probe.py`).
- Правило; битые входы — именованные отказы, не дефолт: тира нет → rc 1
  TIER_MISSING; алиас не разрешается → rc 1 ALIAS_UNRESOLVED; пустая строка
  модели → rc 1 MODEL_EMPTY; файла реестра нет → rc 2 REGISTRY_MISSING; тело
  не JSON → rc 2 REGISTRY_INVALID (resolver_tier_missing …
  resolver_registry_invalid).
- Правило; резолвер не различает «вызов проверки»: два вызова без маркеров
  (разный cwd, зачищенный env) байт-равны и равны оракулу
  (resolver_plain_call_parity; двойники, распознающие маркеры проверки,
  назначены этой клетке кодом `STAB_BIND`).
- Дано: мир двери с 4 судейскими ролями; когда
  `bash <мир>/scripts/check_sud_model.sh --spawn critic <назначенная> --root
  <мир>`; тогда rc 0; запасная на спавне → rc 1 «модель не тира роли»; чужая
  → rc 1 (door_spawn_primary/…fallback_refused/…foreign_refused — зелёны уже
  сегодня, регрессионная защита ПЕРЕСЕЧЕНИЯ 104/173). Трасса вердикта:
  allowed на primary → rc 0, denied на ОБЪЯВЛЕННОЙ запасной → rc 0, denied на
  чужой → rc 1 «фолбэк вне списка тира» (door_verdict_fallback_flow,
  door_verdict_foreign_fallback).
- Правило; перестановка реестра критика (toy-реплика owner-PR #1000) без
  правки кода: НОВАЯ модель проходит дверь rc 0 (door_swap_green), СТАРАЯ
  отказывает rc 1 (door_stale_primary — краснота двусторонняя, не «любая
  не-GLM»); словарь двойников двери — `stabs/`, назначение каждого — код
  `STAB_BIND` в `probe.py`.
- Правило; битый реестр в двери — fail-closed rc 2, не 0/1
  (door_broken_registry, door_no_role).
- Дано: мир с roles/ и генератором; перестановка версии семейства; когда
  `node scripts/gen-harness.ts` в мире; тогда `.omp/agents/<роль>.md`
  `model: ["@<тир>"]` и `.omp/config.yml` `  <тир>: "<id>"` следуют реестру,
  `--check` rc 0 (gen_follows_registry); живая цепочка подмены строится только
  для fallback+autoFallback:true и снимается при false (gen_fallback_chain).
  Зона 198 — согласованность значений с резолвером; паритет тел/роутинг — 998.
- Правило; проектный оверлей разворачивается реестром мира: смена версии
  семейства меняет развёрнутый id, ссылка `@семейство` в вывод не протекает
  (overlay_registry_swap); неизвестное семейство → rc 1 «неизвестное
  семейство» (overlay_unknown_family; двойник-неразворачиватель назначен
  кодом `STAB_BIND`).
- Дано: пара фактов сессий, проектная потеряла правило основной; когда
  `bash <мир>/scripts/check_project_session.sh --main-argv … --project-argv …`;
  тогда stdout содержит «РАСХОЖДЕНИЕ pravila», rc 1
  (pravila_missing_detected — сегодня КРАСНА: опечатанный литерал оставляет
  поле глухим); доставленная норма не флагается pravila
  (pravila_delivered_ok; двойники сверщика — в `stabs/`, назначение кодом
  `STAB_BIND`).
- Дано: живое дерево `--repo .`; когда раннер батареи; тогда: repo-клетки
  резолвера (repo_resolver_cli, repo_resolver_matrix — все роли живого
  реестра), двери (repo_door_judges), швов (repo_seam_fable_no_literal,
  repo_seam_fable_resolver, repo_seam_door_resolver,
  repo_seam_door_no_private) и опечатки (repo_pravila_live) зелёны ПОСЛЕ
  замены; ДО замены честно красны seams/резолвер/опечатка (замер ниже).

Команды приёмки (rc, перемерены на живом дереве 2026-11-16):
- `bash fixtures/workshop_project/modeli_tolko_v_reestre_198/red_modeli_reestra_198.sh --repo .` → красная: резолвер CLI отсутствует на живом дереве
- `bash fixtures/workshop_project/modeli_tolko_v_reestre_198/red_modeli_reestra_198.sh --model` → красная: резолвер CLI отсутствует либо молчит
- `bash fixtures/workshop_project/modeli_tolko_v_reestre_198/red_modeli_reestra_198.sh --stabs` (rc 0 уже сегодня и после реализации)
- после реализации: та же `--model` → `CELLS=27 FAILURES=0` rc 0; `--stabs` → `STABS=13 CAUGHT=13` rc 0; `--repo .` → `REPO_CELLS=8 FAILURES=0` rc 0.

замер: `ls -d fixtures/workshop_project/modeli_tolko_v_reestre_198/* | wc -l` = 3 census fixtures/workshop_project/modeli_tolko_v_reestre_198/*
замер: `ls fixtures/workshop_project/modeli_tolko_v_reestre_198/stabs/decoy_* | wc -l` = 13 census fixtures/workshop_project/modeli_tolko_v_reestre_198/stabs/decoy_*

Счёты по выводу команд (2026-11-16, живое дерево): `--model` → `CELLS=27
FAILURES=26` (красны все резолверные клетки и pravila_missing_detected;
door/gen/overlay клетки зелёны — регрессионная защита); `--stabs` →
`STABS=13 CAUGHT=13` rc 0; `--repo .` → `REPO_CELLS=8 FAILURES=19` rc 1;
клеток-функций в probe.py `grep -c '^@cell('` = 27; время полного прогона
трёх режимов ~7 с.

Демаркация конформности (019): конформный вход — реестр живой грамматики
(семейство → непустой «провайдер/id»; тир: model «@семейство»|литерал,
fallback «@семейство»|null|отсутствует, autoFallback bool|отсутствует; роли →
существующие тиры) и аргументы в алфавитах двери (104). Валидный контрпример
= инвариантность к значениям (toy-иды/перестановки) ∧ расхождение на
конформном входе (другая назначенная модель). Неконформные входы (битый JSON,
пустая модель, отсутствие роли) — клетки именованных отказов, не контрпримеры
инвариантности.

## Модель угроз

ЗАЩИЩАЕТ:
- от второго разбора цепочки roles→tiers→models у потребителей: единственная
  точка roles.ts, repo-клетки швов ловят возврат jq-цепочки/литерального
  grep'а в двери и лаунчере;
- от молчаливого дефолта модели при отсутствии роли/тира/алиаса/реестра:
  именованные отказы rc 1/2 с точным именем в выводе;
- от «надстройки, подменяющей ответы проверкам»: оракул в памяти батареи,
  зачищенный env, нейтральный cwd, двойной вызов без маркеров
  (resolver_plain_call_parity);
- от застревания системы на старой модели при смене реестра: перестановки
  primary/версии/фолбека/autoFallback переключают резолвер, генератор, дверь
  и проектный оверлей без правки кода (включая toy-реплику owner-PR #1000);
- от маскировки недоставки правил опечатанным заголовком: клетка
  pravila_missing_detected на живом сверщике.

НЕ ЗАЩИЩАЕТ:
- от неверного НАЗНАЧЕНИЯ владельцем — реестр есть истина входа, семантика
  выбора моделей за владельцем (998/owner-PR);
- от дрейфа цепочки двери L1 архитектуры — её пинирует собственная батарея
  186 v2 (см. Существующее 1), не 198;
- от провайдерной auth/ключевой политики (A3/A4), тарифов метеринга (A6),
  эксплуатационных таймеров z.ai (A7) — вне предмета (РАЗВИЛКИ);
- от устаревшей прозы ролей C1–C9 — v+1 владельца соответствующих норм
  (166/188/192/029/оркестраторские), не молчаливая правка 198;
- (cognitive-only остаток) конечный набор перестановок не доказывает
  универсальность резолва на всём пространстве JSON-значений; демаркация
  выше ограничивает претензию конформными входами; ловец — критик/адверсарий
  на дополнительных контрпримерах в границах демаркации.

## РАЗВИЛКИ ДЛЯ ВЛАДЕЛЬЦА (воля/риск/деньги — не решаются 198)

1. A6 метеринг: тариф в `config/metering.json` привязан к конкретному MiniMax
   id; при смене модели тариф не переезжает (proxy не находит цену). Тариф —
   факт, не alias; вынос тарифного справочника в реестр с fail-closed —
   отдельный предмет по слову владельца.
2. A7 orch-peak: таймеры паузы z.ai — станционная эксплуатация; при полном
   отказе GLM пауза теряет смысл. Изменение — ops-предмет по слову владельца.
3. C9 слот «ВСЕГДА под MiniMax»: привязка льготного слота к ролям против
   модели — slot-policy владельца, 198 не расширяет allowance.
4. 998 v+1 (B4/B5/C7/D4) и чистка прозы C1–C6/C8: нужны v+1 соответствующих
   владельцев норм (166/029/998/оркестраторские) — запрос отдельными
   предметами.
5. Полный отказ от GLM (миграция tiers.default.fallback/task-glm/slow и
   удаление models.glm) — вторая очередь инвентаря, только по слову владельца.

ПРЕДПОСЫЛКИ:
- setting bash, python3, git, node (type-stripping, как у gen-harness), jq (дверь) — всё уже в CI харнесса; новых CI secrets/variables/environments и настроек репозитория НЕ требуется

## Незаполненные требования:
нет
