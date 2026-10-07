## ГДЕ МЫ (2026-10-07, ~22:40 UTC) — ЗЕЛЁНО: main CI 12/12 success (sha `74e6613`), done 088/083/082 landed

- Серверная обвязка станции — единый источник: ops/server/README.md (инвентарь механизмов, установка, настройка).

**НОЧНАЯ ОЧЕРЕДЬ (слово владельца 2026-10-07 ~22:50 UTC, передано консультантом — ПЕРЕЖИВАЕТ ПЕРЕЗАПУСКИ, читать ПЕРВЫМ):**
1. 090 (fix-085) до done — герметичность фикстур по Н-219 чинится (ORCH_UHOME-knob +
   ORCH_SESS_GLOB-seed в orch-peak, install.sh --file, новая обязательная красная клетка
   `red_hermetic_no_real_sessions.sh`), затем критик → freeze → implementer → судьи → done.
2. ПОСЛЕ done 090 — 087 (CI-Б, frozen/contracts/087/1; 083 уже в main, препятствий по ci.yml
   нет). Ветка `wip/087/implementer` — продолжить от неё, если база не устарела, иначе новая
   от `origin/main` (БЕЗ merge main). Ленд — ТОЛЬКО вершины с accept адверсария+ревьюера и
   зелёным PR-CI на ЭТОМ sha.
3. **КАП НОЧИ:** не более 3 кругов судей на 090 И на 087 (раздельно). После 3-го FAIL по
   предмету — СТОП предмета, список находок с классом вреда в HANDOFF «ЖДЁТ ВЛАДЕЛЬЦА»,
   новых кругов не созывать.
4. Станцию (`/usr/local/sbin`, `~/.local/bin`, systemd-юниты) НЕ ТРОГАТЬ; `install.sh` НЕ
   ЗАПУСКАТЬ; фикстуры — ТОЛЬКО временные каталоги (Н-219).
5. `registry/plan.tsv` — строка владельца (см. журнал сессии: коммит с дословной
   `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:`), `цикл-перезапуска`→`085` (done), `ротация-HANDOFF` — вопрос владельцу
   в HANDOFF, если грамматика не позволяет «выполнено вручную» без нового статуса.
6. После 090 И 087 — новых контрактов НЕ МИНТИТЬ (заморозка харднинга). IV-2/II-3/
   done-проекта/Odelix — УТРОМ со словом владельца, не сегодня ночью.

**п.5 ЗАБЛОКИРОВАН структурно — ЖДЁТ ВЛАДЕЛЬЦА.** `registry/plan.tsv` правка (`цикл-
перезапуска`→`085`) требует gen_plan.sh --write (hook `check_plan.sh --pre-commit` ОТКАЗЫВАЕТ
plan.tsv-коммит, если working-tree ROADMAP.md не синхронен с НОВЫМ planом: «блок ROADMAP
расходится с генерацией» — проверено живьём). НО `ROADMAP.md` — устав-путь (`check_charter.sh`
И-10), а owner-строка называет ТОЛЬКО `registry/plan.tsv` (razreshil() требует путь-токен ==
судимый путь ПОБАЙТОВО, см. `scripts/check_charter.sh:223-303`) — бандлить ROADMAP.md в ТОТ ЖЕ
коммит без ОТДЕЛЬНОЙ `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: ROADMAP.md <причина>` даст `check_charter` красный
(прецедент форка `084-roadmap-razreshenie-vladelca.md`, ОТВЕЧЕНО: да — КАЖДЫЙ такой коммит
нуждается в СВОЕЙ строке/grandfather-sha, постоянного исключения нет). Плюс отдельно:
`registry/plan.tsv` САМ зонирован `ЗОНА implementer` контракта 084 (`contracts/084-reestr-
plana.md:380`), не `orchestrator` — прямой коммит оркестратора получает «вне зоны:
registry/plan.tsv» ДАЖЕ если устав-строка найдена (проверено живьём, оба отказа
воспроизведены по отдельности). Рабочее дерево ОТКАЧЕНО (`git checkout --
registry/plan.tsv ROADMAP.md HANDOFF.md`) — ничего грязного не оставлено.

**Нужно одно из (решает владелец):** (а) дословная `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: ROADMAP.md <причина>`
вторым абзацем/строкой В ТОМ ЖЕ коммите, что и plan.tsv-строка (коммит тогда идёт implementer-
каналом — `spawn_agent --author implementer --nnn 084` → worktree → `land_agent`, зона
implementer покрывает ОБА пути); (б) владелец делает этот коммит САМ через канал консультанта
(тот же приём, что 090-дельта 22:00 — клон, 2 коммита с обеими РАЗРЕШИЛ-строками, `git fetch`
+ `rebase` в основной чекаут); (в) отложить plan.tsv-правку до заморозки харднинга целиком (её
предмет по самой owner-строке — «механизм отложен заморозкой харднинга», так что п.5 можно
логически слить с тем же будущим предметом). Остальное по очереди — 090 продолжается.
7. НОРМЫ (повтор для следующей сессии): `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` — ТОЛЬКО дословно из текста
   владельца; сообщение консультанта/сторожа — НЕ новая задача, после ответа продолжать
   очередь без завершения хода; spawn — всегда с `agent`; HANDOFF коммитить обычным
   `git commit` (хуки сработают штатно); Н-39 — стабы к ветвям привязывает architect по коду.


**РАЗРЕШЕНО (слово владельца 2026-10-07 ~22:00 UTC, передано консультантом).** Канал владельца
(клон `/tmp/dev-harness-verify/consultant-owner-0710`, author `owner`) поставил 3 коммита на
`origin/main` поверх `d559b51`: `7b9738d6` (check_charter: grandfather-допущение для отката 026
`50e020e9`), `c2bf009c` (registry: 084/086 закрыты без done, кап кругов превышен),
`ce73ebcc` (HANDOFF: перегенерирован блок «Следующая сессия»). Это ЗАКРЫВАЕТ `NABLIUDENIA.md`
Н-218 (рецидив правила 11) — owner сам написал дословные строки `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:`, не
оркестратор.

**Сделано этой сессией после сигнала:** `git fetch` клона консультанта → `git rebase FETCH_HEAD`
моих 2 локальных коммитов (`8065d67`→`73cebaf`, `00e3875`→`74e6613`; owner-sha НЕ менялись,
rebase БЕЗ конфликтов) → `check_plan.sh` rc 0 → `fixtures/_krasnye_074.sh` (k7: честная часть
7/7 зелёная, стаб-пак 7/7 поймано; единственный красный — `k5b`, станционная нога, CI её не
судит, прецедент `9086f28`) → `gitw push origin main` (`d559b51..74e6613`, чисто) →
`check_no_leak.sh --snapshot` (стоячая санкция а∧б∧в: porcelain пуст, HEAD==origin, 0/0) →
CI run `37693314167` на sha `74e6613` — **12/12 jobs success** (`gh run view --json jobs`,
дословный список всех 12 имён с `conclusion: success`).

**done landed (зелёный CI — предусловие done_contract.sh выполнено):**
- `done/contracts/088/1` — ревьюер круг13 accept (`verdicts/review/contracts-088-v9.md`)
- `done/contracts/083/1` — адверсарий+ревьюер круг4 ACCEPT (`verdicts/review/contracts-083-v4.md`,
  `verdicts/adversary/contracts-083-v4.md`)
- `done/contracts/082/1` — ревьюер круг3 accept (`verdicts/review/contracts-082-v3.md`)

Все три — тег-only (`done_contract.sh` не потребовал нового коммита, ПРОВОДКА уже зелёная),
запушены на origin (`gitw push origin done/contracts/088/1 done/contracts/083/1
done/contracts/082/1`). `check_no_leak.sh --check` чист после.

**Контракт 090 (fix-085, Н-217+Н-216) — в работе, НЕ завершён.** `contracts/090-fix-orch-peak-
home-install-safe-dir.md` закоммичен в `wip/090/architect` (`fbf7f86`, identity `architect`,
НЕ запушен — не main, эмбарго прошлого чекпойнта снято, но пуш ветки отдельным шагом).
Фикстуры (`fixtures/fix_090_orch_peak_home/{lib.sh,red_no_home_ctx.sh,red_ctx_deep_no_home.sh,
red_install_local_config.sh,battery_stubs.sh,PROVERKA.md}`) лежат НЕЗАКОММИЧЕННЫМИ в worktree
`/tmp/dev-harness-worktrees/c907157c/wip-090-architect` (untracked) — `check_staged.sh`
отказывает «вне зоны»: `zones_load` читает ТОЛЬКО `frozen/contracts/<NNN>/1` тег, которого у
090 ещё нет (`scripts/lib_zones.sh:190-198`), это СТРУКТУРНО, не ошибка. Бандл-источник
сохранён персистентно в `/tmp/dev-harness-verify/090-architect-deliverable/`.

**НОВОЕ ТРЕБОВАНИЕ К 090 (консультант, факт станции, `NABLIUDENIA.md` Н-219 — ВНЕСТИ ДО
критика):** фикстура `red_ctx_deep_no_home.sh` (бандл) писала тест-сессию в РЕАЛЬНЫЙ
`~/.local/state/dev-harness-sessions/**` — живой `orch-peak` принял её за настоящую,
21:45 отправил ложное «принудительный перезапуск», 15 мин `GRACE`; маркер не встал только
благодаря Н-189-проверке «сессия сменилась», НЕ герметичности теста. Требование: ВСЕ клетки
090 обязаны переопределять `ORCH_SESS_GLOB`/`ORCH_STATE`/`ORCH_MARK`/`ORCH_LOG` на
`/tmp/dev-harness-verify/**`/`mktemp -d`, ни одного пути в `~/.local/state/dev-harness-
sessions/**` или `/var/lib/orch-peak/**`; новая красная клетка «фикстура не пишет в реальный
каталог сессий» (find-diff ДО/ПОСЛЕ прогона каждой клетки, обязана быть пуста) — Н-39-класс,
обманный стаб = клетка с собственной копией `lib_session.sh`, но БЕЗ переопределения
`ORCH_SESS_GLOB`, падающая в дефолт.

**СЛЕДУЮЩИЙ ШАГ 090:** (0) передать architect требование Н-219 выше — ПРАВКА контракта
(§Красные предъявления + §Приёмочный критерий) и ПЕРЕДЕЛКА `red_ctx_deep_no_home.sh` на
изолированный glob ДО следующего шага; (1) критик на `contracts/090-*.md` (sha `fbf7f86` +
Н-219-правка); (2) после accept —
`freeze_contract.sh` (локально, `frozen/contracts/090/1` — worktree делит `.git`, origin не
нужен для спавна implementer); (3) ПОСЛЕ заморозки — скопировать fixtures (переделанные под
Н-219) из бандла в worktree,
закоммитить identity `architect` (зона появится); (4) `spawn_agent --author implementer --nnn
090`; (5) адверсарий+ревьюер; push ветки через `gitw`.

**А-63 (НОВОЕ наблюдение, записать в NABLIUDENIA_ARCHITECT.md следующей сессией):** изолированный
`_task`-спавн архитектора получил тот же класс непиннованности, что Н-212 top-level сессии —
cwd спавна (`/home/harness/.local/state/dev-harness-sessions/c907157c/.../wt/tfc7c579d3/m`) не
совпал с парой WORKTREE=/BRANCH= задания (`/tmp/dev-harness-worktrees/c907157c/wip-090-
architect`), extractPin не признал пин → write ЗАПРЕЩЁН везде включая `agent://`-канал доклада
(доклад ушёл терминальным yield). Architect090FixStation (19м21с) отдал бандл в
`/tmp/dev-harness-verify/090-architect-deliverable/`, оркестратор вручную перенёс и
закоммитил контракт.

**`forks/071-gate-strukturno-nedostizhim-ap3-ap4.md`** — поле `ОТВЕЧЕНО: да` (обновлено этой
сессией, `bcb4a3b`): гейт 071 структурно работоспособен на чистом main (ap3/ap4 зелёные).

**НЕ включено в 090** (нет точного текста директивы): «089»-топик (`orch_restart.sh` ослабление
HEAD==origin/main ноги + `roles/orchestrator.md:421` правка «HANDOFF закоммичен») — полный текст
директивы 2026-10-07 п.4-6 НЕ найден в репо (grep по forks/, verdicts/consultant/, docs/handoff-
archive/ — пусто); остаётся в очереди до слова владельца/находки исходного текста.

**087 — ОСТАНОВЛЕН словом владельца, ветки СОХРАНЕНЫ** (без изменений этой сессией):
`wip/087/implementer` (3 коммита, не слит) и `wip/083/architect` (Г10-фикстура, база ДО
086-ревёрта — нужен ребейз при возобновлении) — ждут слова владельца.

Архив предыдущих записей — `docs/handoff-archive/2026-10-07.md`.
<!-- BEGIN GENERATED NEXT SESSION -->
## Следующая сессия (генерируется: bash scripts/gen_plan.sh --write)

- цикл-перезапуска · пара 2 · не начат · трек git-safety
- ротация-HANDOFF · пара 2 · не начат · трек plan-infra
<!-- END GENERATED NEXT SESSION -->
