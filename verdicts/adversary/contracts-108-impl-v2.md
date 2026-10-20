FAIL
OBJECT=307b3962fa3072ea55f89b5cf3f3e8d91a0471df

# Adversary, круг 2 — реализация контракта 108 (CMP-MOB-004 Start)

Копии: продукт `/tmp/dev-harness-verify/Adv108r2/mob` (detached 307b396), H `/tmp/dev-harness-verify/Adv108r2/H`
(`git archive 9bb5beb30`). Мутанты: `mutants.py` (замены в НАСТОЯЩЕМ коде 307b396 → static+behavioral пробы 108 →
`git checkout -- mobile/src`); выходы: `out/<мутант>.{beh,static}`; регресс: `regress.sh`, `out/reg.*`.

## Блокер (с названным обходом)

**B-1. Slot StartScreen привязан к сегменту входа, а не к секции start.**
`mobile/src/app/(tabs)/[section].tsx`: `startScreen={start === 'start' ? (<StartSectionHost …/>) : undefined}`, где
`start` — параметр маршрута при входе. TabShell переключает секции внутренним `setSection`, поэтому при входе по deep
link (грамматика 999: `complior://vorgaenge?returnTo=start`, инициал ≠ start) секция start показывает только заголовок —
без AgentPresence, композера, brief, resume. Нарушен пункт композиции контракта (стр. 123): «TabShell подключает
StartScreen в секцию start».

- Обход (состояние дерева, где критерий выполнен, а предмет не сделан) — само дерево 307b396: static 22/22,
  behavioral 331/331, `--matrix` 41/0; route-клетки входят ТОЛЬКО с `params={section:'start'}`.
- Свидетель (throwaway Jest/RNTL на настоящем `TabRoute`, `mobile/src/features/start/__tests__/adv108r2.throwaway.test.tsx`,
  после прогона удалён из копии; байты — `evidence/adv108r2.throwaway.test.tsx`): `npx jest …adv108r2.throwaway.test.tsx` rc=1:
  `✕ deep-link entry vorgaenge|schutz|post -> tab start shows StartScreen`, `✕ deep-link vorgaenge?returnTo=start ->
  shell-back shows StartScreen` — `Unable to find an element with testID: start-screen`; `section-start` при этом есть.
- Позитивный контроль: мутант `POS-fix-deeplink-slot` (`start === 'start' ? (` → всегда передавать слот; TabShell уже
  ограничивает рендер через `section === 'start'`) — тот же свидетель 6/6 зелёный, пробы 108 `static_rc=0 beh_rc=0
  honest 331/331`. Исправление не противоречит frozen-критериям.
- Дефект есть и в круге 1 (`7a87004`, стр. 34 тот же тернарник), судьями круга 1 не назван.

## Вопросы задания — ответы исполнением

| Мутант НАСТОЯЩЕГО кода 307b396 | static | behavioral | красное |
|---|---|---|---|
| A1 route: `<StartSectionHost reducedMotion={false}>` | 0 | 1 | ROUTE_MOTION_SYSTEM_reduced |
| A2 route: `reducedMotion={true}` | 0 | 1 | ROUTE_MOTION_SYSTEM_full |
| A3 host: `StartScreen reducedMotion={false}` (новый host в features/start) | 0 | 1 | ROUTE_MOTION_SYSTEM_reduced |
| A4 route: собственный `useState(false)` вместо общего хука | 0 | 1 | ROUTE_MOTION_SYSTEM_reduced |
| A5 общий хук: Promise не применяется (застревает на initial) | 0 | 1 | ROUTE_MOTION_SYSTEM_full |
| A6 общий хук: без подписки `reduceMotionChanged` | 0 | **0** | — (331/331) |
| B1 route: черновик не поднят (композер неуправляемый, в слоте) | 0 | 1 | ROUTE_DRAFT_RETURN_{vorgaenge,schutz,post,PROFILE} |
| B2 черновик в StartSectionHost (ниже слота) | 0 | 1 | те же 4 |
| B3 root сбрасывает черновик при смене missions | 0 | **0** | — |
| B4 root сбрасывает черновик при смене reducedMotion | 0 | **0** | — |
| C1 resume/brief скрыт для COMPLETED/CANCELLED | 0 | 1 | BRIEF_STATE_*, RESUME_EFFECT_*, RUNTIME_SCENARIO_*, SNAPSHOT_REFRESH_* |
| C2 resume no-op для COMPLETED/CANCELLED/PARTIAL | 0 | 1 | RESUME_EFFECT_{3 состояния}_{full,reduced} |
| D1 route зовёт `api.getAdmission` вместо listMissions | 0 | 1 | ROUTE_MOUNT_MISSIONS_FROM_RUNTIME, ROUTE_MOTION_SYSTEM_* |
| D2 порт StartScreen `missions` переименован в `admission` | 0 | 1 | ACTION_FROM_*_PRESENT, ACTION_RESUME_* … |
| E1 рендер кадра F04.04 (`start-frame-F04.04`) при PRESENT | 0 | **0** | — |
| E2 вторая карточка F04.05 (`start-structured-result`) | 0 | **0** | — |

Вывод: reducedMotion закрыт через реальную композицию (настоящий `TabRoute` → `StartSectionHost` → `StartScreen`;
константа на route/host, обход общего хука и застревание на initial — все красные); черновик над слотом закрыт
(B1/B2 красные на всех 4 путях ухода); terminal-различение resume (контракт §Вопросы 2: resume доступен для всех 10
состояний) и имя порта ловятся. НЕ ловятся: A6, B3, B4, E1, E2 — дефекты проверки H, продукт 307b396 их не содержит
(код прочитан: подписка есть, сбросов черновика нет, одна карточка, F04.04/F04.05 не рендерятся) → советы, не блокеры.

## Советы (не блокеры)

1. (H) E1/E2: «≤1 контекстная карточка» и «F04.04/F04.05 не рендерятся» проверяются только по testID
   `start-contextual-card`/`start-frame-F04.0{1,2,3}`; вторая карточка или кадр под другим testID — 331/331.
2. (H) A6: живое переключение системного Reduce Motion не покрыто (route-клетки задают только начальный Promise).
   Продукт проходит throwaway-свидетель «live toggle» (✓).
3. (H) B3/B4: черновик в composition root, сбрасываемый эффектом на missions/reducedMotion, проходит — route-клетки
   вводят текст уже после разрешения missions и настройки.
4. (H) матричный мутант `route-draft-slot-state` привязан к `StartDraftContext` модели architect, не к ветке
   продукта (product держит черновик `useState` в `TabRoute`); байт-привязку к продукту даёт только этот вердикт (B1/B2).

## Scoped-регресс (копия 307b396, H=9bb5beb30)

```
cmp mobile/src/bootstrap/__tests__/pilot.test.tsx H/pilot_995/pilot.test.tsx   rc=0
cmp mobile/src/bootstrap/__tests__/source.json    H/pilot_995/source.json      rc=0
start_static_probe.py --repo           rc=0  static 22/22
start_probe.py --repo                  rc=0  honest 331/331
start_probe.py --repo --matrix         rc=0  mutants 41, defects 0
start_static_probe.py --repo --matrix  rc=0  mutants 5, defects 0
pilot_995/probe.py --check-frozen      rc=0  995 runs=1 mismatches=0
pilot_995/frozen_matrix.py             rc=0  995 frozen checked=3
nav_999/nav_probe.py                   rc=0
nav_999/ui_probe.py                    rc=0
nav_999/shell_static_probe.py          rc=0  DEEP_LINK_SCHEME scheme=complior
nav_999/copy_probe.py                  rc=0
npm run lint                           rc=0
npm run typecheck                      rc=0
npm test                               rc=0  Tests: 14 passed
```
Неизменность frozen (в `/home/harness/dev-harness`, только чтение):
- `git diff frozen/contracts/108/1 9bb5beb30 -- contracts/108-cmp-mob-004-start.md` — пусто;
  `start.test.tsx`, `source.json`, `start_static_probe.py` — пусто; изменения start_108 — только объявленное
  пост-заморозочное усиление (route-test, model, probe_lib, start_probe).
- `git diff frozen/contracts/999/1 9bb5beb30 -- fixtures/workshop_project/nav_999` — пусто (rc=0).
- pilot_995 vs frozen/contracts/108/1: только `pilot.test.tsx` +18 (объявленный перепин 3 заглушек 995).

NOT_RUN: Maestro / android-e2e (эмулятора на станции нет; PR #112 android-e2e — инфраструктура, не исследовалось).
