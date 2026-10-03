## ГДЕ МЫ (2026-10-03, ~20:15 — КОНТЕКСТ-РЕСТАРТ (сторож: 528K≥500K, владелец спит, слово «на ближайшей чистой точке — дверью»); 080 grandfather-fix ИСПОЛНЕН (check_charter.sh 3 пары 73070ff, вариант решения форка пересмотрен с (3) на (2) — freeze v2 структурно не чинит ancestry, якорь check_charter ВСЕГДА /1, см. Н-192 поправка), PR#14 CI rerun IN_PROGRESS; 078 hang-фикс запушен (4dc7c6f), ap2-шард теперь ЗЕЛЁНЫЙ, отдельный ci-job упал на известном check_ids missing-remote флейке — retrigger отправлен, IN_PROGRESS; НОВЫЙ контракт 081 «общий git-конфиг неприкосновенен» (сверх лимита, слово владельца) — architect СДАЛ контракт+красную фикстуру (efe7d75, push), 108 ячеек/42 красных/59 зелёных/7 missing rc1, ДВА мелких дефекта фикстуры найдены (кириллица/латиница в 4 ячейках, шероховатости sed в стабах) — следующий шаг pre_critic→critic; дерево чисто, все wip-ветки на origin)

- Серверная обвязка станции — единый источник: ops/server/README.md (инвентарь механизмов, установка, настройка).

### Состояние на момент рестарта (сырое, живыми командами)

- origin/main = `306d524`; local main == origin (`0 0`), `git status --porcelain` пусто,
  `check_no_leak --check` → «основной чекаут чист».
- `wip/080/architect` = `27b1f05` (НЕ трогать — grandfather-пары в check_charter.sh
  пришиты к ЭТИМ ТРЁМ SHA, ребейз/амend сломает якорь). PR#14 CI rerun `37144012441`
  (started ~19:50) — IN_PROGRESS на момент рестарта.
- `wip/078/implementer` = `4dc7c6f` (bounded-timeout фикс hang). CI retrigger
  `37148205226` (started ~19:51, после retrigger на check_ids-флейке) — IN_PROGRESS.
- `wip/081/architect` = `efe7d75` — `contracts/081-obshchij-git-konfig-strazh.md` +
  `fixtures/path_guard/red_git_config_immut_081.sh` (108 ячеек, rc 1 ожидаемо).
  **ИЗВЕСТНЫЕ ДЕФЕКТЫ ФИКСТУРЫ** (сообщены architect, НЕ для implementer — фикс-круг
  архитектора ДО критика): (а) 4 ячейки р19–р22 (блок-вт) используют кириллическую «т»
  в `expect_block` при латинском «wt» в ORDER — считаются missing, не red; (б) ст-1..ст-6
  (mutant-стабы) имеют шероховатости sed-экранирования. Оба — тривиальный фикс той же
  зоной (fixtures/path_guard/), НЕ блокируют pre_critic по существу предмета, но МОГУТ
  дать неверный счёт ячеек — проверить `bash fixtures/path_guard/red_git_config_immut_081.sh`
  живьём перед критиком.
- Проверено: НИ ОДИН субагент не жив (`read proc://` пусто), все три wip-ветки
  (080/078/081) синхронизированы local==origin.

### Следующая сессия — порядок действий

1. **078/080 CI** — живым `gh run list` проверить результат retrigger/rerun ПЕРВЫМ
   делом (оба запущены ~19:50-19:51, должны завершиться задолго до рестарта следующей
   сессии). 080 при зелёном: `land_agent` (merge --no-ff) с ОБЯЗАТЕЛЬНЫМ телом
   merge-коммита дословно: «РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/080-dver-bugfiks-perezapuska.md
   — ленд ветки, замороженной вне её истории (Н-192), блоб идентичен v1; слово владельца
   2026-10-03.» (если `land_agent.sh` не умеет задать сообщение merge — сразу ПОСЛЕ
   ленда 4-я grandfather-пара на sha самого merge-коммита, тем же порядком, что
   73070ff) → PR CI → implementer 080 (зона: `scripts/orch_restart.sh`,
   `scripts/lib_session.sh`, `ops/server/root/orch-peak` — база установленной на
   станции копии `/tmp/dev-harness-verify/consultant-ops/orch-peak`, sha256 `ecd046b9…`)
   → адверсарий → ревьюер → done. 078 при зелёном: адверсарий к2 (оба мутанта
   `verdicts/adversary/contracts-078-v1.md` обязаны быть пойманы — hang больше не
   маскирует прогон) → ревьюер → done → land.
2. **081** — ПЕРВЫМ делом живьём `bash fixtures/path_guard/red_git_config_immut_081.sh`
   на `wip/081/architect` (worktree `/tmp/dev-harness-worktrees/c907157c/wip-081-architect`,
   если ещё жив — иначе `git worktree add`/clone заново от origin): подтвердить счёт
   ячеек; если архитектор не поправил два известных дефекта (кириллица/латиница в р19-22,
   sed-шероховатости ст1-6) — поправить тем же архитектором ПЕРЕД pre_critic (его зона:
   `fixtures/path_guard/red_git_config_immut_081.sh`). Затем `scripts/pre_critic.sh` →
   критик круг 1. Н-39 дословно в задание фикс-круга, если потребуется повторный спавн.
3. **Роль-текст потолок** — 52342 vs 51200 (избыток 1142 байта), решение владельца ждёт
   (поднять потолок / сократить файл / разовое разрешение); дословный абзац — в архиве
   (`docs/handoff-archive/2026-10-03.md`, ищи «Видимый todo»).
4. **local-main-backup `origin/backup/orch-main-20261003`** — владелец решил ДЕРЖАТЬ до
   done 080 (слово 2026-10-03), не удалять раньше.
5. **orch-loop вне зон 080** — ЗАКРЫТО слотом ROADMAP «цикл перезапуска = репо»
   (коммит `de12db4`); отдельный микроконтракт — первым свободным слотом после 078/080/081.

### Гигиена заданий — норма Н-193 (действует для ВСЕХ будущих заданий с git-экспериментами)

ЛЮБОЕ задание субагенту на сетевую git-диагностику (`ls-remote`/`fetch`/`clone` с подменой
`origin`) обязано нести ПЕРВОЙ строкой: «НЕ меняй `remote.origin.url`/`git remote`/git-config
НИГДЕ в выданном WORKTREE (он делит `.git` с главным чекаутом) — диагностируй в ОТДЕЛЬНОМ
toy-клоне со своим `.git` под `/tmp/dev-harness-verify/<имя>/toy`». Контракт 081 (в работе)
закрывает этот класс механически (path-guard блокирует git-config-мутации в shared-.git
целях) — до его done норма остаётся cognitive-only в каждом задании.

### Техническая находка (напоминание): `edit`/`write` заблокирован в главном чекауте для непиннованной сессии (Н-85/А-122)

Рабочий канал — ОДНОРАЗОВЫЙ SSH-клон (`git clone ssh://git@github.com/a3ka/dev-harness.git
/tmp/dev-harness-verify/<уникальное-имя>`, НЕ локальный путь — rw-ключ станции гейтится по
`pwd -P`), правка там через `edit`/`write` (работает — путь в null-allowlist), коммит
identity явным `-c`, затем `git fetch <клон-путь> main:<temp-branch>` В главном чекауте
(raw git — НЕ заблокирован), `git cherry-pick -x <sha>` на main, `git branch -D <temp-branch>`,
`rm -rf <клон>`. Push — ТОЛЬКО из главного чекаута через `bash scripts/gitw push origin main`
(прямой push из одноразового клона уходит МИМО GitHub — иной риск, Н-143).

---

История — docs/handoff-archive/2026-10-03.md
