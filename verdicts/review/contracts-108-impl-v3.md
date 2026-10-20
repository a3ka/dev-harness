accept
OBJECT=5bbdf6e4715d3507a84add4ec50b31f736300554

# Суд реализации контракта 108 (CMP-MOB-004 Start), круг 3, SCOPED — reviewer Rev108r3

Находки (reslop): `review.md` рядом (status: ready). Блокеров нет; советы R3-1, R108-3, R3-2, R3-3.

Сборка (одноразово, /tmp/dev-harness-verify/Rev108r3/): `mob` и `w` — две копии
/tmp/dev-harness-verify/Impl108/mob на 5bbdf6e (status пуст). `mob` — под 108-пробы,
`w` — под свидетеля, 995/999 и npm, чтобы мутации проб и jest не делили дерево.
H = archive 9bb5beb30 поверх archive 57c6798b3 fixtures/workshop_project/start_108.

## 1. Область правки — в зоне

Мера своя: `zone.py` берёт строку «ЗОНА implementer:» из frozen-блоба
`frozen/contracts/108/1^{commit}:contracts/108-cmp-mob-004-start.md` и сверяет с `git diff --name-status`.

```
307b396..5bbdf6e  paths 4  out 1 [['D', 'mobile/src/bootstrap/use-system-reduce-motion.ts']]
76ac10f..5bbdf6e  paths 16 out 1 [['M', 'mobile/src/bootstrap/__tests__/pilot.test.tsx']]
```
- Дифф круга: `.github/workflows/mobile.yml`, `mobile/src/app/(tabs)/[section].tsx` и
  `mobile/src/bootstrap/tab-shell.tsx` лежат в зоне.
- Четвёртый путь — УДАЛЕНИЕ файла, который круг 2 внёс вне зоны (R2-1). В B 76ac10f этого
  файла нет (`git cat-file -e` → rc128). В накопленном диффе к B его тоже нет. **R2-1 закрыт.**
- Хук `useSystemReduceMotion` снова живёт в `tab-shell.tsx`. Против B тело то же, добавлен
  только `export`; имя внутренней функции совпадает с B (`readSystemReduceMotionInitial`).
  Перестановка блока `useSystemColorScheme` — шум (совет R3-3).
- Единственный путь вне зоны в накопленном диффе — `pilot.test.tsx`. Его санкционировал
  консультант (А2), он побайтно равен H: `cmp … pilot_995/pilot.test.tsx` → rc0,
  `cmp … source.json` → rc0.
- Коммит один (5bbdf6e), автор `implementer`, тема называет 108. Правка одной задачи,
  атомарность соблюдена.

## 2. B-1 закрыт — свидетель адверсария, мой прогон

Взял `/tmp/dev-harness-verify/Adv108r2/evidence/adv108r2.throwaway.test.tsx` и положил его в
`w/mobile/src/features/start/__tests__/`. Запуск: `npx jest <файл>`.
```
5bbdf6e: ✓ deep-link entry vorgaenge/schutz/post ×3, ✓ vorgaenge?returnTo=start, ✓ live reduce motion, ✓ draft before resolve
         Tests: 6 passed, 6 total   rc=0
307b396: ✕ deep-link entry vorgaenge/schutz/post ×3, ✕ returnTo=start; ✓ 2
         Tests: 4 failed, 2 passed, 6 total   rc=1
```
Новые клетки H (`start-route.test.tsx` @57c6798b3) прогнал своей мерой на НАСТОЯЩЕМ продукте,
а не на модели:
```
5bbdf6e: Tests: 12 passed, 12 total  rc=0
307b396: ✕ ROUTE_ENTRY_TAB_vorgaenge/schutz/post, ✕ ROUTE_ENTRY_DEEPLINK_RETURN; ✓ DIRECT_ROUNDTRIP (объявленный позитивный контроль)
         Tests: 4 failed, 8 passed, 12 total  rc=1
```
Красное предъявлено: до правки 4 красных, после 0. Свидетель и клетки удалены после прогона;
`git -C w status` пуст.

## 3. Проверки не переписаны под код

```
git diff --stat frozen/contracts/108/1^{commit} 57c6798b3 -- contracts/108-cmp-mob-004-start.md fixtures/workshop_project/start_108/
  → model/app.tabs.section.tsx, model/features.start.draft-context.ts, model/ui.conversation-composer.tsx,
    probe_lib.py, start-route.test.tsx, start_probe.py
  (контракт, start.test.tsx, source.json и start_static_probe.py в списке отсутствуют, то есть = frozen/108/1)
git diff --stat frozen/contracts/999/1^{commit} 9bb5beb30 -- fixtures/workshop_project/nav_999/   → пусто
git diff --stat frozen/contracts/999/1^{commit} 57c6798b3 -- fixtures/workshop_project/nav_999/   → пусто
git diff 8b113da05 57c6798b3 -- start_108/: start-route.test.tsx @@ -153,3 +153,75 (+72/−0, только аппенд);
  start_probe.py +40/−4 (все 4 «−» — списки depends, к которым добавлены ENTRY_CELLS; named ни одного мутанта не ослаблен)
git log frozen/108/1..57c6798b3 -- start_108/  → 8b113da05, 57c6798b3; автор обоих — architect
```
Implementer харнесс не трогал. В диффе круга продуктовые тесты не менялись.

R108-3 (совет, не блок). Модель `model/app.tabs.section.tsx` не повторяет продукт байтово:
у неё StartDraftContext, инлайн-хост и хук внутри route; у продукта — props композера,
`features/start/start-section-host.tsx` и хук из tab-shell (`diff` → rc1, расхождение по всей
структуре). Мутант `route-entry-slot-ternary` якорён на байтах МОДЕЛИ, поэтому матрица
доказывает чувствительность клеток только на эталоне. Чувствительность на продукте дал мой
прогон на 307b396 (выше: 4 красных). Подгонки нет: продукт с моделью не совпадает, а клетки
независимо ловят настоящий обход.

## 4. Scoped-регресс (мои прогоны)

```
python3 h/…/start_108/start_static_probe.py --repo mob            → static 22/22            rc=0
python3 h/…/start_108/start_probe.py --repo mob                   → honest 336/336           rc=0
python3 h/…/start_108/start_static_probe.py --repo mob --matrix   → mutants 5, defects 0     rc=0
python3 h/…/start_108/start_probe.py --repo mob --matrix          → mutants 42, defects 0    rc=0
   (route-entry-slot-ternary: named RED ok, depends_red=[DEEPLINK_RETURN, TAB_post, TAB_schutz])
git -C mob status --short --untracked-files=all | wc -l           → 0
своя мера (иной командой): start_probe.py | grep -c ^case → 336; --matrix | grep -cE "^mutant .*named RED ok" → 42; status → 0
cmp pilot.test.tsx / source.json с H                              → rc=0 / rc=0
python3 h/…/pilot_995/probe.py --repo w --check-frozen            → "995 runs=1 mismatches=0"  rc=0
python3 h/…/pilot_995/frozen_matrix.py --repo w                   → "995 frozen checked=3" (дрейф-мутант FROZEN_BYTES_MISMATCH пойман)  rc=0
python3 h/…/nav_999/nav_probe.py --repo w                         → rc=0
python3 h/…/nav_999/ui_probe.py --repo w                          → rc=0
python3 h/…/nav_999/shell_static_probe.py --repo w                → rc=0
python3 h/…/nav_999/copy_probe.py --repo w                        → rc=0
(w/mobile) npm run lint       → structure: OK; eslint --max-warnings=0   rc=0
(w/mobile) npm run typecheck  → tsc --noEmit                              rc=0
(w/mobile) npm test -- --silent → Test Suites 1 passed; Tests 14 passed   rc=0
git -C w status --short --untracked-files=all | wc -l             → 0
```
Maestro/android-e2e — NOT_RUN: эмулятора нет. Предметом суда это не является.

## 5. Норма не тронута

Контракт, source.json, start.test.tsx и start_static_probe.py совпадают с frozen/108/1;
nav_999 совпадает с frozen/999/1. Нормативных документов в диффе нет. Комментарий mobile.yml
теперь правдив: шаг 108 читает тот же H 9bb5beb30 (ref на строках 39 и 147), на нём
331 клетка (324 + 7 route; 8b113da05 — предок H, rc0).

## 6. Паразитная сложность (050) — новые и раздутые артефакты

- Продукт, круг 3: новых артефактов нет. Файл `use-system-reduce-motion.ts` удалён,
  хук снова внутри tab-shell и получил `export`. Каждый ответ на пять вопросов сводит
  сложность к нулю или к минусу: (1) инвариант 7/F04.V04 — один источник reduceMotion;
  (2) новое состояние не вводится; (3) правок, которые обязаны идти вместе, стало меньше на
  1 файл; (4) интерфейс модуля вырос на один экспорт, работа та же; (5) потребители —
  [section].tsx и TabShell, дубля грамматики нет. Вывод: ESSENTIAL.
- Семья ROUTE_ENTRY ×5 (H, architect): (1) инвариант 3 (присутствие и композер при входе в
  start любым путём 999), барьер B-1; (2) явное состояние `mockEnv.params` клетки;
  (3) 1 файл теста + список ENTRY_CELLS в start_probe.py — 2 места, против 8b113da05 их
  было 2 (ROUTE_ALL); (4) интерфейс пробы не вырос — ни флагов, ни env; (5) потребитель —
  строка приёмки «поведенческая N/N» и шаг CI (после перепина). Вывод: ESSENTIAL.
  Повтор ожиданий в 4 клетках вместо вызова `expectStartSurfaces()` — ACCIDENTAL, совет
  R3-2. Фрагмент, свойство и более простая форма названы, но строку приёмки повтор не
  ломает, поэтому это не блок.
- Мутант route-entry-slot-ternary: (1) самопроверка матрицы для клеток ENTRY (приёмочная
  строка --matrix); (2) состояния нет; (3) якорь — байты модели, при правке модели меняются
  2 места; (4)/(5) потребитель — `--matrix`. Вывод: ESSENTIAL (оговорка — R108-3).

## 7. Советы (не блок)

- **R3-1.** CI исполняет H 9bb5beb30, а ROUTE_ENTRY-клеток в нём нет: 57c6798b3 не предок H
  (`merge-base --is-ancestor` → rc1) и живёт только в `wip/108/architect`. Значит, барьер B-1
  в CI Complior-mob не работает, пока оркестратор не продвинет 57c6798b3 и implementer не
  перепинит обе ref в mobile.yml (после этого комментарий станет «336/336»). Обход не
  назван: продукт на 5bbdf6e клетки проходит. Это пред-merge задача оркестратора.
- **R108-3.** Матрица self-check якорена на модели. Нужен хотя бы один мутант по байтам
  продукта либо явная пометка, что матрица проверяет модель.
- **R3-2.** `expectStartSurfaces()` вызывать во всех ENTRY-клетках.
- **R3-3.** Перестановка блока `useSystemColorScheme` в tab-shell.tsx — шум диффа.
