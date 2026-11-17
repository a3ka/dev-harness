# СДАЧА 182 v2 — круг правки по FAIL Crit182V2 (пять блоков)

ОБЪЕКТ: contracts/182-plan-posle-perezapuska.md + fixtures/workshop_project/plan_restart_182/** на этом коммите (поверх beedddb0349ed523bb4747b66db95bf5e93d5c45).

## Двери формы (живые прогоны, cwd = worktree, без ambient GIT_AUTHOR_*/GIT_COMMITTER_*)

- `bash scripts/pre_critic.sh contracts/182-plan-posle-perezapuska.md` → rc 0 («дверь зелёная»)
- `bash scripts/check_spec_ready.sh . contracts/182-plan-posle-perezapuska.md` → rc 0 (`OK`)
- `bash scripts/check_precision_gate.sh . contracts/182-plan-posle-perezapuska.md` → rc 0 (`OK`)
- `bash scripts/check_threat_model.sh . contracts/182-plan-posle-perezapuska.md` → rc 0 (2+2 буллета)
- `bash scripts/check_ceilings.sh . contracts/182-plan-posle-perezapuska.md` → rc 0
- `bash scripts/check_charter.sh . contracts/182-plan-posle-perezapuska.md` → rc 0
- `bash scripts/check_sdacha.sh . contracts/182-plan-posle-perezapuska.md --run` → rc 127: скрипта нет в дереве (на OBJECT его не было — тот же rc 127 зафиксирован вердиктом Crit182V2); лист ведётся вручную, восстановление механизма — вне зоны architect 182.

## Батарея (живые прогоны)

- `W --model` → rc 0, `CELLS=35 GREEN=35`
- `W --stabs` → rc 0, `STABS=17 CAUGHT=17`, ZHIV нет
- `W` (голый) → rc 1, `CELLS=35 GREEN=15`, именованные строки RED напечатаны (ранее — молчаливый rc 1)
- `W --repo .` → rc 1, `CELLS=35 GREEN=15`

## Дельта-лист по пяти блокам (способ → доказательство)

1. К-08 (потеря registry резолвера) — способ `клетка`: новый мир `proj-alt-registry` (эффективный реестр `.harness/ledger` из профиля, опубликованная согласованная приманка в стандартном `.harness/registry`, расходящаяся паузой), 8 клеток `proj-alt-*` (probe.py `project_world(registry=..., standard_decoy=True)`, вызов в main). Мутация критика `registry-hardcode` стала адресным стабом (model/plan_slice.py:157-160) → `STAB registry-hardcode caught: proj-alt-structural`. Соседняя: станционный читатель (v1 CLI в `--repo .`) на том же мире красит proj-alt-done/frozen/pause/draft/no-decoy/structural (живой вывод голого прогона). Честная запись зелёная: `--model` → все proj-alt-* GREEN.
2. К-10 (обязательный названный выход) — способ `клетка`: клетка `proj-no-plan-exit` (точный rc 1, пустой stdout, полный префикс с SHA, дословный выход И-7); `assess_refusal` усилен до `startswith(prefix)` + фрагменты; выходы требуются у каждого вида отказа (no-plan/broken-profile/sync-marker). Мутация критика `no-exit` → `STAB no-exit caught: proj-no-plan-exit`; соседняя моя `vague-refusal` (полный префикс заменён расплывчатым) → `STAB vague-refusal caught: proj-no-plan-named`. Честная эквивалентная запись зелёная: предикат пинует только префикс и выход дословно, середина свободна — `--model` GREEN proj-no-plan-named/proj-no-plan-exit.
3. К-07 (безаргументный прогон) — способ `механизм` (обёртка в зоне architect): red_plan_restart_182.sh переписан без безусловного `shift`; голый вход исполняет те же клетки, печатает именованные RED и итог. Живой вывод: `CELLS=35 GREEN=15`, rc 1; контракт :37 описывает этот итог.
4. К-15 (несовместимые числа) — способ `снятие` устаревших как действующих: `STABS=4`→17 (:39), `STABS=14`→17 (:80), CELLS=26→35 (:73), строка :56 переписана (прошлые счёты — история, не приёмка); строка :73 уточнена списком зелёных/красных по живому прогону. Сверка командой: grep по контракту не находит 4/4, 14/14, 26; все числа — из прогонов этого листа.
5. К-01 (запрещённая проза Н-39) — способ `снятие`: секция «Мутационные доказательства v2 (Н-39)» удалена целиком; привязки стаб↔ветвь↔вход живут только в коде (probe.py `proj_stabs`, model/plan_slice.py). Сверка: grep "→.*proj-" по контракту — вхождений привязок нет.

## Карта классов К-01…К-17

- К-01: чисто — удалённая секция; grep без привязок (см. дельта-лист п.5).
- К-02: без изменений с вызова 3 — дельта только по пяти блокам; `git diff --stat beedddb034` ограничен зоной.
- К-03: чисто — `bash fixtures/context_pack_095/red_orch_brief_karta_legacy.sh` rc 0; frozen 095 не тронут.
- К-04: чисто — изменены только contracts/182-*.md и fixtures/workshop_project/plan_restart_182/** (зона architect).
- К-05: чисто — каждая строка приёмки несёт команду и rc (строки 37-40, 73-81 контракта).
- К-06: н/п — новых зависимостей среды нет; инфра-отказ мира даёт NOT_IMPLEMENTED rc 2, не красную клетку.
- К-07: чисто — голый `W`: rc 1, `CELLS=35 GREEN=15`, именованные RED напечатаны; достижимость зелёного после реализации — те же клетки, что `--repo .`.
- К-08: чисто — `STAB registry-hardcode caught: proj-alt-structural` (сырой вывод в `--stabs`).
- К-09: чисто — нестандартный эффективный реестр `.harness/ledger` — конформный вход 996, честная модель даёт proj-alt-* GREEN.
- К-10: чисто — `STAB no-exit caught: proj-no-plan-exit`, `STAB vague-refusal caught: proj-no-plan-named`.
- К-11: чисто — оракул в памяти: `project_expected`/`origin_sha`/`refusal_no_plan` снимаются до вызова субъекта.
- К-12: чисто — сверка побайтовая (`==` на всей выдаче), разбор generated-блока единственный `parse_rows`.
- К-13: н/п — дельта секретов не выводит.
- К-14: чисто — каждый новый предикат двусторонен: мутация красит (registry-hardcode/no-exit/vague-refusal), честная запись зелёна (`--model` 35 GREEN); префикс-предикат пинует только дословный префикс И-7 и выход, свободная середина не отвергается.
- К-15: чисто — все числа из живых прогонов; grep устаревших счётов пуст.
- К-16: чисто — КЛАСС РИСКА обычный (:4, :7); модель угроз v2 сохранена, check_threat_model rc 0.
- К-17: н/п — модель/операции 188 дельтой не меняются.

## Соседи (без регресса)

- 996 `bash fixtures/workshop_project/rezhim_996/probe.sh` rc 0, examined=111 mutants=0 mismatches=0
- 996 `--matrix` rc 1, examined=111 mutants=76 mismatches=1 (живой broken-profile-fallback) — прежний базлайн, дельтой 182 не менялся
- 125 rc 0 (зелёных 70, красных 0); 095 rc 0; 187 `--model` rc 0 (CELLS=54 STABS=0 FAILURES=0)
- `bash scripts/check_plan.sh` rc 1 «done-пункт стоит следующим: 187» — прежнее поведение станции

## Остатки

- `scripts/check_sdacha.sh` отсутствует в дереве (rc 127 у критика и у меня) — механизм вне зоны architect 182.
- Следующий вызов критика — только по слову владельца.
