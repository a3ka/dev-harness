accept
OBJECT=0070c38ac300ff7fdc2c8ca48d5abfa001426582

# Вердикт reviewer (Rev107r3): реализация C контракта 107 (CMP-MOB-003), круг 3 (последний по капу)

Предмет: Complior-mob, ветка `cmp-mob-003/erstinformatsiya`.
- C = 0070c38 (21 коммит implementer поверх B = 76ac10f, все с префиксом 107 (CMP-MOB-003)).
- H контракта = cd15c807 (`frozen/contracts/107/1^{commit}`).
- H в CI = 58bcdb6a9 (origin/main).

Находки записаны в `review.md` того же каталога (reslop, `status: ready`). Логи прогонов лежат там же:
`static.log`, `behav.log`, `ci107_*.log`, `p995_*.log`, `p999_*.log`, `matrix_b.log`, `matrix_s.log`.

**Основание accept.** Ни одна находка не называет ОБХОД, то есть состояние, где критерий выполнен, а предмет не сделан.
- Блокеры круга 2 закрыты своей мерой:
  - R107-10 закрыт, мутант красный;
  - R107-4 — честный NOT_RUN без шага-заглушки;
  - R107-1 снят решением Б.
- Остальное — советы, перечислены ниже.

**Оговорка по зоне.** Три пути лежат вне frozen-ЗОНЫ (п. З). Это открытый вопрос консультанту, мой вердикт его исход не решает.
- `pilot.test.tsx` покрыт словом владельца А2.
- `runtime-contract.d.ts` и `tests/acceptance/erstinformation-route.test.tsx` словом владельца не покрыты.
- Если консультант откажет в расширении зоны: `d.ts` откатывается к B без потерь (измерено). `route.test` — единственный барьер W0-guard, его вынос или перенос решает консультант.

## Сырые прогоны своей мерой

R — одноразовая копия C с `npm ci`. CI — копия R с `.harness`, это клон H, поставленный на 58bcdb6a9, ровно как `actions/checkout path: .harness`.

```
# R (/tmp/dev-harness-verify/Rev107r3/R), пробы из H-клона (erstinfo_107 на 58bcdb6a9 == frozen 107: git diff --stat cd15c807 58bcdb6a9 -- erstinfo_107 contract → пусто)
python3 dh/…/erstinfo_static_probe.py --repo .   → static 22/22        rc=0
python3 dh/…/erstinfo_probe.py --repo .          → honest 265/265      rc=0
пересчёт: grep -c '^case ' → 22 / 265; уникальных 265; ACTION_VECTOR 100 + EVIDENCE_PROD 96 + MOCK_SCREEN 20 + ACK_OUTCOME 12 + RUNTIME_GATE 1 = 229 (ядро = контракт)
mut: erstinfo_probe.py --matrix   → mutants 24, defects 0  rc=0
mut: erstinfo_static_probe.py --matrix → mutants 4, defects 0  rc=0
mobile/: npm run lint → structure: OK, eslint 0          lint_rc=0
mobile/: npm run typecheck (tsc --noEmit)               tc_rc=0
mobile/: npm test → Test Suites: 4 passed; Tests: 18 passed, 18 total   test_rc=0

# CI-копия (/tmp/dev-harness-verify/Rev107r3/CI, .harness @ 58bcdb6a97e987c8daf60e42a299fd4c162a5652)
cmp mobile/src/bootstrap/__tests__/pilot.test.tsx .harness/…/pilot_995/pilot.test.tsx   cmp1=0
cmp mobile/src/bootstrap/__tests__/source.json   .harness/…/pilot_995/source.json       cmp2=0
pilot_995/probe.py --repo . --check-frozen → 14 сценариев assertion=passed, runs=1 mismatches=0   frozen_rc=0
runtime_probe rc=0 · bundle_probe rc=0 · schema_probe rc=0 (checked=2 runtime=matched) · frozen_matrix rc=0 (checked=3)
transport_probe rc=0 · admission_probe rc=0 · stale_probe rc=0 · types_probe rc=0 · pins_probe rc=0
admission_family_probe rc=0 (family_size=860) · stale_table_probe rc=0
nav_999: nav_probe rc=0 (238/238 строк rc=0) · ui_probe rc=0 (18/18) · shell_static_probe rc=0 (6/6) · copy_probe rc=0 (51/51)
erstinfo_107 из .harness: s107=0 (static 22/22) · b107=0 (honest 265/265)
git status --short --untracked-files=all: mob 0 · R 0 · dh 0 · CI/.harness 0
```

## Ось круга 2: проверка своей мерой

**R107-10 закрыт.**
- В `api-client.ts` единый `ApiClient` с 4 операциями. `grep FullApiClient|DisclosureOps|as ApiClient` по `mobile/src` и `mobile/tests` даёт только комментарий `Pick<…>`.
- Route: `const api: ApiClient = shippedRuntime.api;`, каста нет.
- Красный предъявлен. Мутант `http-drop` на одноразовой копии `mut` удаляет обе операции 107 из `httpApiClient`. Результат: `tsc --noEmit` → `http-runtime.ts(79,7): error TS2739 … missing … acknowledgeDisclosure, getDisclosureGate`, **tc_rc=2**. В круге 2 тот же мутант давал rc0.
- Дифф `pilot.test.tsx` против B: `^-` 0 строк, `^+` 15 строк, это ровно две заглушки `acknowledgeDisclosure`/`getDisclosureGate`.
- sha256 файла на C и эталона `pilot_995/pilot.test.tsx` на 58bcdb6a9 совпадают: `b06b6f9d…e915b`. sha256 `source.json` — `527da5c1…1c0da`, равны.
- Перепин связный:
  - `git diff --stat c9f680b4d 58bcdb6a9 -- pilot_995 nav_999` → только `pilot.test.tsx +15`, то есть frozen-пробы 995/999 не переписаны;
  - коммит харнесса 3dad6ff6 принадлежит architect, 1 файл +15/−0;
  - обратный контроль: если вернуть в `mut` `pilot.test.tsx` из B, `cmp` с новым эталоном даёт rc1 (`differ: line 24`), а tsc — 2 ошибки TS.

**R107-4 — честный NOT_RUN.**
- В yaml нет ни одной исполняемой строки с `evalScript`, `runFlow` или `setSystemFontScale`: grep находит их только в комментариях `:20-33`.
- Шаг-заглушка (условный no-op из 469c8f5) удалён в 04a769a.
- EOF yaml исправлен (`\n`).
- Совет: имя flow (`:2`) по-прежнему обещает «увеличить текст», см. R3-6.

**R107-7, решение В.**
- `initialAdmission = 'W0'`. `useEffect` выходит рано при `admission !== 'W1A'`. `recheck` защищён тем же условием.
- Красный предъявлен. Мутант «снять guard эффекта»: `route.test` даёт `Expected number of calls: 0 / Received: 1`, **jest_rc=1**. Пробы 107 на том же мутанте зелёные: static rc0 22/22, behav rc0 265/265. Значит, барьер W0-route держит только этот тест вне зоны.
- Факт для владельца:
  - `handleContinue → W1A` недостижим, потому что continue рисуется только при W1A (инв. 6);
  - поэтому в собранном приложении `getDisclosureGate` не вызывается никогда, gate всегда `null`, экран остаётся в fallback;
  - это прямое следствие решения В плюс инв. 6, а не обход;
  - источник W1A-admission в коде отсутствует.

**R107-1 снят решением Б.** Приёмка идёт по поведению, это не дефект.

**R107-9 — регресс, совет.** В коммите 633d8fe 4 файла потеряли перевод строки в конце файла: `api-client.ts`, `http-runtime.ts`, `mocks/runtime.ts`, `runtime-contract.d.ts`. Проверено `tail -c1 | od -c` → `}`/`;`. В диффе от B 5 строк `\ No newline`; пятая — `ui-copy.ts` на стороне B, на C она исправлена.

**R107-6, без изменений (совет).** `responsible_entity`/`source_ref` — литералы route. `?? DOCUMENT_REF`/`?? DISCLOSURE_VERSION` — мёртвые fallback. При отказе `getDisclosure` показывается литеральный плейсхолдер. HTTP-доставка вне предмета (§Вне предмета), инварианта, которого это касается, нет.

**R107-11, без изменений (совет).** Устаревшие комментарии на месте:
- disclosure-mock `:6-8`: SYNTHETIC;
- disclosure-mock `:10-14`: «runtime does NOT call gateFor», хотя `gateMock()` возвращает `gateFor(...)`;
- route `:210`: `ABSENT_GATE`;
- route `:16`: «Set-state-in-effect нет».

Новые:
- route `:19` «инвариант 5» и `:129` «invariant 3» указывают на admission-границу, а в контракте она в §Предмет и в инв. 6;
- route `:22` «или прямого setAdmission в тестах» — такого пути нет;
- `api-client.ts:15` «consumers narrow with Pick<…>» — потребителей нет;
- `mobile.yml:103-104` «H закреплён за frozen/contracts/107/1 (cd15c807)», а шаг исполняет пробы из checkout 58bcdb6a9. Содержимое erstinfo_107 одинаковое, неверен только текст.

**R107-12 / recheck-guard (совет).** Мутант «снять guard recheck»: route.test rc0. Eslint ловит только устаревший deps (warning → rc1). При W0 gate = null, значит confirm и retry недостижимы, и guard — оборона недостижимой ветки. Поведенческого барьера у него нет.

**050: тавтология редьюсера `:65` осталась** (совет). Обе ветки тернарника `{kind:'loading'}`.

## З. Зона (факт; исход — за консультантом)

Сверка `git diff --name-only 76ac10f HEAD` со строкой `ЗОНА implementer:` frozen-блоба cd15c807: 12 путей, из них 9 в зоне, 3 вне.

1. `mobile/src/bootstrap/__tests__/pilot.test.tsx`
   - Вне зоны, контракт относит этот путь к read-only pilot-семейству 995.
   - Покрыт словом владельца А2: «расширение ЗОНЫ implementer 107 одним тестовым путём (mock ApiClient получает два метода)», форк n107-impl-krug2.
   - Дифф ровно две заглушки, файл байт-равен эталону H.
2. `mobile/src/bootstrap/runtime-contract.d.ts`
   - Вне зоны, словом А2 не покрыт («одним тестовым путём»).
   - Дифф — только комментарий `:7-10` и снятый перевод строки в конце файла. Объявление `api: ApiClient` одинаково на B и C.
   - Утверждение «сняты суженные типы» к этому файлу не относится: сужение жило в `api-client.ts`, в зоне.
   - Своя мера: в `mut` файл возвращён к B → static rc0 22/22, behav rc0 265/265, lint rc0, tsc rc0, jest 18/18 rc0. Правка функционально пустая, 050-класс ACCIDENTAL, см. R3-2.
3. `mobile/tests/acceptance/erstinformation-route.test.tsx`
   - Вне зоны, словом не покрыт.
   - Единственный барьер W0-guard route: мутант → rc1, пробы 107 → rc0.
   - Тест не переписывает и не ослабляет frozen-барьеры. Автор — implementer, коммит 04a769a.

## Прочие пункты чек-листа

- **Пины в mobile.yml.** Дифф от B:
  - оба `ref:` (quality и android-e2e) и два комментария сменились c9f680b4d → 58bcdb6a9;
  - добавлен шаг 107 по образцу 999: `mkdir`, `cp -a` в `/tmp/dev-harness-verify/impl107-r-…`, `cd`, обе пробы без `--matrix`;
  - шаг стоит до «Вынести H» и до lint/typecheck/test;
  - тела frozen-шагов 995/999 (cmp, probe-вызовы) не тронуты, сменился только ref по А2.
- **Проверки не переписаны под реализацию.**
  - Контракт и `erstinfo_107/` на H CI равны frozen (дифф пуст, rc0).
  - Эталон `pilot_995` правил architect (3dad6ff6), не implementer.
  - Implementer добавил тест (п. З.3), существующие проверки не правил.
- **Атомарность (совет).**
  - 04a769a связывает две задачи: route recheck guard плюс новый тест (adv107r2) и Maestro font_scale (R107-4).
  - 633d8fe несёт три R-id (10/7/1), но по сути это одна правка шва.
  - Префикс `107 (CMP-MOB-003)` есть у всех коммитов.
- **Норма не тронута.** Нормативных документов в диффе нет.

## 050: строки по новым и раздутым артефактам круга 3

См. таблицу в `review.md`. ACCIDENTAL:
- `runtime-contract.d.ts` (R3-2) — фрагмент, отсутствующее свойство и более простая форма названы, форма измерена;
- recheck-guard;
- тавтология редьюсера.

Блокирующей силы ни у одного нет:
- обхода нет;
- `d.ts` — предмет открытого вопроса зоны у консультанта; исход не угадываю;
- при отказе в расширении откат обязателен и бесплатен.

## NOT_RUN

- Нативный Maestro и эмулятор — отдельная очередь.
- `gh pr checks`: PR нет, ветка не запушена.
- Мутант `recheck-noop` круга 2 повторно не гонялся.
