accept
OBJECT=5bbdf6e4715d3507a84add4ec50b31f736300554

# Adversary, круг 3 (scoped) — реализация контракта 108 (CMP-MOB-004 Start)

Копии: продукт `/tmp/dev-harness-verify/Adv108r3/mob` (cmp-mob-004/r3 @ 5bbdf6e, дерево чистое после каждого прогона:
`git status --short | wc -l` = 0), H `/tmp/dev-harness-verify/Adv108r3/h` (`git archive 9bb5beb30` + поверх
`git archive 57c6798b3 fixtures/workshop_project/start_108`). Мутанты: `mutants.py` (порт круга 2 на якоря 5bbdf6e + R*/T*);
выходы `out/<мутант>.{beh,static}`; свидетели `evidence/adv108r2.throwaway.test.tsx` (круг 2, без изменений),
`evidence/adv108r3.throwaway.test.tsx` (новый); запуск `witness.sh <label> [мутант]` (кладёт свидетели в
`mobile/src/features/start/__tests__/`, гоняет `npx jest`, удаляет); регресс `regress.sh`, `out/reg.*`.

## 1. B-1 закрыт исполнением

- Свидетель круга 2 на настоящем `TabRoute` 5bbdf6e: `npx jest src/features/start/__tests__/adv108r2.throwaway.test.tsx`
  rc=0, **6/6 ✓** (вход vorgaenge|schutz|post → tab start показывает `start-screen`; `vorgaenge?returnTo=start` →
  shell-back показывает `start-screen`; живое переключение reduce motion; черновик, набранный до разрешения missions).
- Код: `[section].tsx` подаёт `startScreen={<StartSectionHost …/>}` без условия; рендер ограничен самим TabShell
  (`tab-shell.tsx:288` `section === 'start' && startScreen ? startScreen : null`).

## 2. Тернарник-мутант на НАСТОЯЩЕМ коде — усиленная проба H краснеет

| Мутант 5bbdf6e | static | behavioral | красное |
|---|---|---|---|
| R1 `[section].tsx`: восстановлен `start === 'start' ? (<StartSectionHost…/>) : undefined` | 0 | **1** | ROUTE_ENTRY_TAB_{vorgaenge,schutz,post}, ROUTE_ENTRY_DEEPLINK_RETURN |
| R2 частичный гейт `start === 'start' \|\| ret === 'start' ? (` | 0 | **1** | ROUTE_ENTRY_TAB_{vorgaenge,schutz,post} |
| R5 `missions={start === 'start' ? missions : null}` | 0 | **1** | ROUTE_ENTRY_TAB_×3, ROUTE_ENTRY_DEEPLINK_RETURN |

ROUTE_ENTRY_DIRECT_ROUNDTRIP на R1 зелёная — так и задумано (положительный контроль входа через start). Свидетель на R1:
10 ✕ / 2 ✓ (`witness.sh R1`).

## 3. Перенос хука в tab-shell.tsx — регрессии нет

- Тело `useSystemReduceMotion` + функции начального значения в `tab-shell.tsx@5bbdf6e` и в удалённом
  `use-system-reduce-motion.ts@307b396` сравнены `diff`: отличается только имя `readInitial` → `readSystemReduceMotionInitial`
  (2 строки). Других импортёров удалённого файла нет (grep `use-system-reduce-motion` по всей копии продукта — 0 совпадений).
- Мутанты круга 2 повторены на 5bbdf6e (`python3 mutants.py`) — **результаты совпадают с кругом 2 один в один**:

| Мутант | static | beh | красное (как в круге 2) |
|---|---|---|---|
| A1 route→host `reducedMotion={false}` | 0 | 1 | ROUTE_MOTION_SYSTEM_reduced |
| A2 route→host `reducedMotion={true}` | 0 | 1 | ROUTE_MOTION_SYSTEM_full |
| A3 host→screen `reducedMotion={false}` | 0 | 1 | ROUTE_MOTION_SYSTEM_reduced |
| A4 route: свой `useState(false)` | 0 | 1 | ROUTE_MOTION_SYSTEM_reduced |
| A5 хук (теперь в tab-shell): Promise не применяется | 0 | 1 | ROUTE_MOTION_SYSTEM_full |
| A6 хук: нет подписки `reduceMotionChanged` | 0 | 0 | — 336/336 (как в круге 2: 331/331) |
| B1 черновик не поднят | 0 | 1 | ROUTE_DRAFT_RETURN_{vorgaenge,schutz,post,PROFILE} |
| B2 черновик в StartSectionHost | 0 | 1 | те же 4 |
| B3 сброс черновика на missions | 0 | 0 | — |
| B4 сброс черновика на reducedMotion | 0 | 0 | — |
| C1 resume/brief скрыт для COMPLETED/CANCELLED | 0 | 1 | BRIEF_STATE_*, RESUME_EFFECT_*, RUNTIME_SCENARIO_*, SNAPSHOT_REFRESH_* |
| C2 resume no-op для COMPLETED/CANCELLED/PARTIAL | 0 | 1 | RESUME_EFFECT_{3}_{full,reduced} |
| D1 route зовёт `getAdmission` | 0 | 1 | ROUTE_MOUNT_MISSIONS_FROM_RUNTIME, ROUTE_MOTION_SYSTEM_*, теперь ещё ROUTE_ENTRY_* ×5 |
| D2 порт `missions`→`admission` | 0 | 1 | ACTION_FROM_*_PRESENT, ACTION_RESUME_* … |

## 4. Новые обходы в изменённых поверхностях (4 пути диффа) — блокеров нет

Продукт 5bbdf6e не содержит ни одного из мутантов ниже (код прочитан; честный свидетель 12/12 ✓, `witness.sh honest` rc=0).
Это дыры ПРОВЕРКИ H → советы, не блокеры.

| Мутант | beh H | свидетель adv108r3 |
|---|---|---|
| R3 `reducedMotion={start === 'start' ? reducedMotion : false}` (motion привязан к сегменту входа) | 0, 336/336 | 3 ✕ `ADV3 entry {vorgaenge,schutz,post} + system reduce motion -> start reduced` |
| R4 `composerOnChange/Value` только при `start === 'start'` (черновик привязан к входу) | 0, 336/336 | 3 ✕ `ADV3 entry {…} -> start, type, leave, return -> draft kept` |
| T1 `readSystemReduceMotionInitial`: Promise → `false` (faden до разрешения на холодном старте) | 0, 336/336 | не покрыт (унаследовано: та же строка в 307b396/7a87004) |
| T2 TabShell игнорирует порт `reducedMotion` (`= systemReduceMotion`) | 0, 336/336 | — (в route значения совпадают; эквивалентный мутант) |
| T3 TabShell `reducedMotionPort ?? false` | 0, 336/336 | — (route всегда передаёт порт; эквивалентный по маршруту) |

mobile.yml: комментарий «331/331» верен для запинненного H 9bb5beb30 (там 5 route-клеток круга 1 → 331), комментарий не
врёт. `[section].tsx`: новый комментарий круга 3 совпадает с кодом (слот всегда; ограничение — `section === 'start'` в TabShell).

## Советы (не блокеры)

1. (H) ROUTE_ENTRY-клетки идут только при `setSystemReduceMotion(false)` и без ввода: R3/R4 (привязка motion/черновика к
   сегменту входа — тот же класс, что B-1) проходят 336/336. Закрытие — клетки ROUTE_ENTRY_* × {reduced} и
   ROUTE_ENTRY_* + ввод/уход/возврат (образец — `evidence/adv108r3.throwaway.test.tsx`, зелёный на честном 5bbdf6e).
2. (CI) `mobile.yml` в обоих checkout'ах держит H=9bb5beb30 — ROUTE_ENTRY-клетки и мутант route-entry-slot-ternary
   (57c6798b3, `wip/108/architect`) в CI не выполняются. B-1 в CI не защищён, пока architect не перепиннит H после
   приземления wip/108/architect.
3. (H) T1: холодный старт с Promise не проверяется (начальное значение до разрешения). Унаследовано.
4. (H, с круга 2, без изменений) A6, B3, B4 — 336/336.

## Scoped-регресс (`bash regress.sh`, копия 5bbdf6e, H=9bb5beb30 + start_108@57c6798b3)

```
git rev-parse HEAD                     5bbdf6e4715d3507a84add4ec50b31f736300554
cmp pilot.test.tsx H/pilot_995         rc=0
cmp source.json H/pilot_995            rc=0
start_static_probe.py --repo           rc=0  static 22/22
start_probe.py --repo                  rc=0  honest 336/336
start_probe.py --repo --matrix         rc=0  mutants 42, defects 0   (route-entry-slot-ternary: named RED ok)
start_static_probe.py --repo --matrix  rc=0  mutants 5, defects 0
pilot_995/probe.py --check-frozen      rc=0  995 runs=1 mismatches=0
pilot_995/frozen_matrix.py             rc=0  995 frozen checked=3
nav_999/nav_probe.py                   rc=0
nav_999/ui_probe.py                    rc=0
nav_999/shell_static_probe.py          rc=0  DEEP_LINK_SCHEME scheme=complior
nav_999/copy_probe.py                  rc=0
npm run lint                           rc=0  structure: OK
npm run typecheck                      rc=0
npm test                               rc=0  Tests: 14 passed, 14 total
git status --short | wc -l             0
```

Неизменность frozen (в `/home/harness/dev-harness`, только чтение):
```
git diff --quiet frozen/contracts/108/1 57c6798b3 -- contracts/108-cmp-mob-004-start.md                       rc=0
git diff --quiet frozen/contracts/108/1 57c6798b3 -- fixtures/workshop_project/start_108/start.test.tsx       rc=0
git diff --quiet frozen/contracts/108/1 57c6798b3 -- fixtures/workshop_project/start_108/source.json          rc=0
git diff --quiet frozen/contracts/108/1 57c6798b3 -- fixtures/workshop_project/start_108/start_static_probe.py rc=0
git diff --quiet frozen/contracts/999/1 9bb5beb30 -- fixtures/workshop_project/nav_999                        rc=0
git diff 8b113da05 57c6798b3 -- …/start_108/start-route.test.tsx | grep -c '^-[^-]'                           0  (только дописывание, +72)
```

NOT_RUN: Maestro / android-e2e (эмулятора нет; PR #112 android-e2e — инфраструктура раннера, не предмет суда).
Полный verify_antiplacebo не запускался (scoped по ПРИЁМКЕ-СУДЬИ v2).
