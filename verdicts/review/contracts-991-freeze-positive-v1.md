FAIL

# Ревью 991 — Freeze-PR a3ka/Complior-mob#106 и положительный PR #107, v1

OBJECT=33947b8f9701ac98a918a4667a051ff39f9f426e
FREEZE_OBJECT=3b440a577da618321db7d38662803707b8ef42eb
Роль: reviewer (Reviewer991FreezePositive). Проверял сам, с Adversary991FreezePositive не
согласовывал. Клон, хеши и прогоны — свои, `/tmp/dev-harness-verify/rev991fp/`.
Контракт: contracts/991-complior-repeticiya-p107-p111.md (текст равен
`frozen/contracts/991/1` и main), §Последовательность п.4–7, §Приёмочный критерий,
§Зоны (Д1–Д4, фазы freeze/positive).
Находки (reslop): `.review/2026-10-17-01.md`.

| PR | Исход | Блокеры |
|---|---|---|
| #106 freeze | FAIL | Рв991-FP-1 |
| #107 positive | FAIL | Рв991-FP-1 (наследуется), Рв991-FP-2 |

Всё остальное, что проверено ниже, зелёное, включая пины, сравнитель, probe, artifacts, Jest в
логе, нативный reset и replay evidence-шага.

## Пины, объект, провенанс

- H = `wip/991/architect` = fc8a8898791fd99e742c77da752e9d8cd282fac8 (объект accept критика,
  038bb2fff). Байты сняты ПЕРВЫМ действием через `git archive` в
  `/tmp/dev-harness-verify/rev991fp/h/`, до любого чтения PR:
  ```
  eb540c9677cf8ab9c1d01472b7aa621fb9c9a4b62b5eea680e2c0e5491c54879  rehearsal.test.tsx
  eef6d0b7df2cb84832f76886632e364f97c1349b065de54267151b6456c78d50  rehearsal.yaml
  1287387d0e2ec29c0d0801ca4ae438e8bee11f12b89fe4ae5523b04c43934598  compare_carriers.py
  48202f0e328f21a0b68db18ac9a3865c6d8ec066eb0626938de5023c7eda68b5  matrix_carriers.py
  6e97a6f85f64dd57facd6f7cf33d41f57ab114be108796a8afccb349bbf9068e  probe.py
  dd3e6429c0467d0356662489795543c2274d6cc002eec46d61ec1d6eb8020edf  model.tsx
  ```
  Первые два совпадают с хешами задания. В main и в теге `frozen/contracts/991/1`
  (28e3a711e) каталога фикстур нет (Рв991-FP-5).
- Свежий клон `https://github.com/a3ka/Complior-mob.git`, refs `pull/106/head`,
  `pull/107/head`, `pull/10{6,7}/merge`:
  - B = dc396b6134b1ab1670cf35551c0d4e48a845d073 (= origin/main = merge-base #106).
  - #106: C₁ = 3b440a577da618321db7d38662803707b8ef42eb. Один коммит, автор
    `implementer <implementer@dev-harness.local>`, «991 freeze: Д1 … Д2 … Д3», родитель B.
  - #107: C = 33947b8f9701ac98a918a4667a051ff39f9f426e. Один коммит, implementer,
    «991 positive rehearsal …», родитель C₁.
  - T₁ = 9e26c8a80073ba6320889c7bf67fb940d3011844, T = a9f71e4c04c0040e5692e5ac3fad55e95129cf6f
    (merge-ref, родители B и C₁/C; строки логов `HEAD is now at 9e26c8a…` / `a9f71e4…`).
    Дерево T₁ = дерево C₁ = a747e805…; дерево T = дерево C = 694dcfb3…
  - `gh pr view`: оба OPEN, `mergedAt` null, baseRefName `main`. #106 changedFiles=2,
    #107 changedFiles=6 (Рв991-FP-6).
- Блобы workflows:
  ```
  B   mobile.yml a965eecb… sha256 c3ca0e05…;  cloud 5a5ee7ff… sha256 61cb65d9…
  C₁  mobile.yml b92e1b6c… sha256 965c6ed2…;          cloud 6001f7dd… sha256 d3d11d68…
  C   mobile.yml 48a7e687… sha256 dc4116f1…;          cloud 4eeb3712… sha256 4d8a6ed4…
  ```
- Атомарность: одна задача — один коммит со ссылкой «991 freeze» / «991 positive». Норма и
  фикстуры H implementer'ом не тронуты: `git log --all --author=implementer -- fixtures/…/rehearsal_991 contracts/991-…` пуст.
  Все три коммита фикстур — architect.
- Порядок п.4→п.5: run #106 закончен 14:52:31Z, коммит C — 14:57:10Z, то есть после зелени
  freeze.

## П1. Пины Jest/flow (байтовая сверка, `pipefail`)

```
jest exp=eb540c96…54879 act=eb540c96…54879  → test "$actual" = "$expected" rc=0
flow exp=eef6d0b7…78d50 act=eef6d0b7…78d50  → rc=0
flow #105 (cd21748) = eef6d0b7…78d50        → равен положительному, rc=0
```
Парный негатив: SHA пустого `it('R1 starts incomplete and completes only after a press', () => {})`
против эталона → `rc=1 JEST_BYTES_MISMATCH`.

## П2. compare_carriers.py из H

```
--base B  --head C₁ --phase freeze    → rc=0 ACCEPTED
--base C₁ --head C  --phase positive  → rc=0 ACCEPTED
--base C₁ --head C  --phase freeze    → rc=1 CARRIER_CHANGED: .github/workflows/mobile.yml:android-e2e:steps[6]
--base B  --head C  --phase positive  → rc=1 CARRIER_CHANGED: .github/workflows/mobile.yml:android-e2e:steps[7]
--base B  --head C₁ --phase negative  → rc=1 CARRIER_CHANGED: .github/workflows/mobile.yml:android-e2e:steps[6]
--base B --matrix                     → rc=0 executed=30 mismatches=0
```
Матрицу пересчитал своим парсером по строкам `991 carriers/<case>: rc=… expected=…`: 30 строк,
ожидаемые {0:3, 1:24, 2:3}, расхождений 0. Покрыты все классы обязательного перечня:
run-ignore-pattern, existing-step/job `continue-on-error` и `if`, pre-native-step,
new-quality-forged-log, station/cloud-flow-directory, trigger-filter,
evidence-continue-on-error.
Существующие проверки (`start-screen.test.tsx`, `start.yaml`, `ci-e2e.sh`, `package.json`):
`git diff --quiet B C -- …` → без различий.

## П3. probe.py из H (свой клон C + `npm ci` rc=0, 1100 пакетов)

```
C:  991 actual/R1: rc=0 assertion=passed | actual/R2: rc=0 passed | executed=2 → rc=0
C₁ (экран не менялся): actual/R1 rc=1 failed | actual/R2 rc=1 failed | executed=2 → rc=1
    причина ×2: Unable to find an element with role: button, name: Prüfung starten
C --matrix: honest/R1 0, honest/R2 0, noop/R1 1, premature/R1 1, sticky/R2 1, sticky/R1 0
    → executed=6 rc=0
```
Построчно сверил с `MATRIX` в probe.py: все 6 исходов равны ожидаемым. После прогона
`git status` клона чист (кроме node_modules).

## П4. CI: jobs, провенанс, Jest в логе quality

`gh pr checks 106 --required` → rc=0; `gh pr checks 107 --required` → rc=0. API jobs:
```
run 39042249676 att 1 pull_request head_sha=C₁ success
  117423923873 quality      success  GitHub Actions
  117424094012 android-e2e  success  station-complior
run 39043085409 att 1 pull_request head_sha=C success
  117426344232 quality      success  GitHub Actions
  117426504720 android-e2e  success  station-complior
```
Для каждого head SHA есть ровно один run. Логи jobs снял по job ID через REST
`/actions/jobs/<id>/logs`, потому что `gh run view --log` падал на чужом кэше
`/tmp/gh-cli-cache` (permission denied). Источник тот же.
- quality C: `> jest --ci --runInBand`, `PASS src/features/start/__tests__/rehearsal.test.tsx`,
  `PASS …/start-screen.test.tsx`, `Tests: 3 passed, 3 total`.
- quality C₁ (база): `Tests: 1 passed, 1 total`. 3 ≥ 1+2, значит REHEARSAL_JEST_NOT_RUN не
  срабатывает. `package.json` и job quality равны B (П2).

## П5. Station android-e2e и artifacts, скачанные по ID, хеши свои

| artifact id | имя | zip sha256 (= API digest) |
|---|---|---|
| 12104746823 | apk-9e26c8a…-39042249676-1 | f30bc395ff80dcec14d576a113cd28483f6e52f99bca295e91ddd908cd8f7968 |
| 12104806604 | maestro-9e26c8a…-39042249676-1 | 28308d1b68480938fb09f7fced3445444ab692566fa8bf574e5b0d6846488839 |
| 12104592604 | apk-a9f71e4…-39043085409-1 | 71a79bb6d26eaa5eb97d128bcc7d8f85ea57b1742337e428581101b76de059de |
| 12104517603 | maestro-a9f71e4…-39043085409-1 | 96febddaa85014e64716831fb2f1f10676617aa0ee4c903a2e2196e518e32151 |

Имена artifacts содержат checkout SHA T (`github.sha`) — так и требует грамматика Д1/Д2.
`workflow_run.head_sha` равен C₁ и C соответственно.
- #106: `app-release.apk` 43909392 Б, sha256 c5109654b3221b8906397705e7ec4b85c94d1a2c0a84381d2b6fa543d4b85922.
  JUnit `tests="1" failures="0"`, `.maestro/start.yaml` SUCCESS. Лог: `[Passed] Стартовый экран
  открывается (5s)`, `1/1 Flow Passed`. Прежний start-flow прошёл реально, rehearsal-flow в
  `.maestro` нет.
  Шаг `test "$(maestro --version)" = "2.11.0"` исполнен, job success.
- #107: `app-release.apk` 43910016 Б, sha256 **65fda6d6edf5a03c63c3e2ed55e1a87f0e2f872084127adb7ee9bd9fd29611bc**.
  JUnit sha256 7315aa54…faf6d: `tests="2" failures="0"`, `.maestro/rehearsal.yaml` SUCCESS,
  `.maestro/start.yaml` SUCCESS.
  `rehearsal-before.png` sha256 ec4823ab…db84, `rehearsal-after.png` sha256 ba4c9c44…cfb.
  Копии в `rehearsal-evidence/` побайтно равны исходным `…/takeScreenshot/*.png`.
  Значения `manifest.json` (apk/flow/junit/PNG, `maestro_version: 2.11.0`,
  `GITHUB_SHA=a9f71e4…`, run 39043085409/1) совпали с моими пересчётами.
  `commands.json` rehearsal-flow: 16/16 COMPLETED, включая `stopApp` →
  `launchApp clearState=false` → assertVisible rehearsal-start / assertNotVisible
  «Prüfung abgeschlossen». Нативный reset процесса исполнен.
  PNG открыл: before — кнопка «Prüfung starten» без completion; after — плюс «Prüfung abgeschlossen».
  Лог: `rehearsal evidence OK: …` и шаг версии исполнены. В этом run был повтор flow
  (Рв991-FP-4).

## П6. Replay эффективных evidence/version-шагов C (`replay.py`)

Шаги взяты из YAML C по `id` (`rehearsal_evidence`, `rehearsal_version`) для обоих workflows.
Запуск: `bash --noprofile --norc -eo pipefail STEP` в scratch-копии `mobile/scripts` и
`mobile/.maestro` из C, cwd = `defaults.run.working-directory` (`mobile`), env job, комплект =
скачанные APK и maestro-out (без `rehearsal-evidence`), фиктивный `maestro --version` на PATH.
Ожидания держатся в памяти до вызова.
```
evidence/honest rc=0 «rehearsal evidence OK»                       (×2 workflow)
apk-missing/empty      rc=1 EVIDENCE_MISSING|EVIDENCE_EMPTY: android/app/…/app-release.apk
junit-missing/empty    rc=1 EVIDENCE_MISSING|EVIDENCE_EMPTY: maestro-out/report.xml
junit-failure/skipped/errors-attr/no-rehearsal/garbage  rc=1 JUNIT_REHEARSAL_INVALID
before|after-missing   rc=1 EVIDENCE_MISSING: rehearsal-{before,after}.png
before|after-empty     rc=1 EVIDENCE_EMPTY: rehearsal-{before,after}.png
before|after-duplicate rc=1 DUPLICATE_EVIDENCE: rehearsal-{before,after}.png
version/version-honest  rc=0
version/version-2.10.0  rc=1 named_MAESTRO_VERSION_MISMATCH=False last=''   ← Рв991-FP-1 (×2)
placebo {run: test -d maestro-out} без after.png → step_rc=0 → EVIDENCE_CHECK_PLACEBO (ловится)
placebo {run: maestro --version || true} @2.10.0 → step_rc=0 → VERSION_CHECK_PLACEBO (ловится)
991 replay mismatches=2 (обе — version-2.10.0)
```
Evidence-шаг честен по всем названным классам. Шаг версии плацебо не является (rc=1), но
названной причины не даёт.

## П7. Д3 install, класс 4 (ручное чтение)

Тело шага `Maestro` в cloud изменилось только на `curl -fsSL https://get.maestro.mobile.dev |
MAESTRO_VERSION=2.11.0 bash`. Живой установщик (прочитан 2026-10-17): строки 91–94 —
при заданной `MAESTRO_VERSION` скачивается `releases/download/cli-$MAESTRO_VERSION/maestro.zip`.
Побочные действия установщика (дописывание PATH в `~/.bash_profile`/`.bashrc`/`.zshrc`,
`rm -rf $MAESTRO_DIR/{lib,bin}`) были и в B, дельта их не добавляет. Новых побочных действий
нет. Остаточный риск: установщик не пиннится хешем, это было и в B. В облаке Д3 не исполнялась
(Рв991-FP-2).

## П8. Область правки

`git diff --name-status B C₁`: `M .github/workflows/mobile-cloud-e2e.yml`,
`M .github/workflows/mobile.yml`.
`git diff --name-status C₁ C`: два workflows, `A mobile/.maestro/rehearsal.yaml`,
`A mobile/scripts/rehearsal-evidence.sh`,
`A mobile/src/features/start/__tests__/rehearsal.test.tsx`,
`M mobile/src/features/start/start-screen.tsx`.
Все пути в ЗОНЕ implementer. Новый скрипт вызывается шагом напрямую. StartScreen сохраняет
заголовок/подзаголовок, кнопка `accessibilityRole="button"`, `testID="rehearsal-start"`,
состояние — только `useState` (без хранилища, сети и API).

## П9. Паразитная сложность (контракт 050)

- `mobile/scripts/rehearsal-evidence.sh` (новый, 107 строк, два python-heredoc). (1) Д4 —
  индивидуальная проверка APK/JUnit/каждого PNG, канонический каталог, хеши рядом. (2) Пишет
  `maestro-out/rehearsal-evidence/{png,manifest.json}`; это видно в выводе (`OK: …`) и в
  artifact, отказ — именованной строкой. (3) Одно свойство — один файл плюс два однострочных
  шага; число файлов на свойство не выросло. (4) Интерфейс без аргументов и флагов, rc 0/1, из
  env только `GITHUB_*` в manifest; работа (разбор JUnit, поиск дублей, хеши) скрыта за ним —
  модуль глубокий. (5) Потребитель — шаги `rehearsal_evidence` обоих workflows; JUnit-логику
  нигде больше в дереве не повторяет. ESSENTIAL.
- Шаги `rehearsal_evidence` ×2. (1) Д4 «в обоих workflows». (2) Состояния нет. (3) Два файла
  меняются вместе, так велит контракт. (4) Одна строка `run`. (5) Потребители — CI и replay.
  ESSENTIAL.
- Шаги `rehearsal_version` ×2. (1) Д3 «новый шаг проверки версии». (2) Нет. (3) Два файла.
  (4) Одна строка; интерфейс без имени причины (Рв991-FP-1). (5) CI, replay. ESSENTIAL;
  дефект — в содержании, не в сложности.
- Upload `Release APK` ×2 и правка Д2 ×2. (1) Д1/Д2. (2) Artifacts с явным именем
  `<T>-<run>-<attempt>`. (3) Два файла. (4) Только `with`. (5) Ревью скачивает их по ID.
  ESSENTIAL. `retention-days` — Рв991-FP-8, совет.
- `start-screen.tsx` (+useState, Pressable, три стиля). (1) Б1. (2) Локальное состояние
  экрана, сбрасывается новым mount/процессом, это доказано probe и Maestro. (3) Один файл.
  (5) Jest/Maestro. ESSENTIAL.
ACCIDENTAL-находок нет.

## Находки (полный перечень, классы)

1. **Рв991-FP-1 — БЛОКИРУЕТ #106 и #107.** Нет названной причины `MAESTRO_VERSION_MISMATCH` в
   шаге `rehearsal_version` (оба workflows). Правка допустима только фазой freeze (П6, `.review`).
2. **Рв991-FP-2 — БЛОКИРУЕТ accept #107.** Нет нового `workflow_dispatch` mobile-cloud-e2e на
   C: у workflow ноль run, п.6 и критерий «новый cloud dispatch» не выполнены. Карточка ставит
   cloud после Merge — порядок неверный.
3. Рв991-FP-3 — СОВЕТ: в manifest нет tree и workflow blob (выводимы из GITHUB_SHA).
4. Рв991-FP-4 — НАБЛЮДЕНИЕ: в run #107 был транспортный повтор; первый заход стёрт `ci-e2e.sh`
   из B, независимо не проверяем.
5. Рв991-FP-5 — НАБЛЮДЕНИЕ (оркестратору): фикстуры H только на wip/991/architect, тег их не
   содержит.
6. Рв991-FP-6 — НАБЛЮДЕНИЕ (владельцу): #107 нацелен на main. Merge строго #106 → #107, затем
   свежая сверка #107.
7. Рв991-FP-7 — ВНЕ ОБЛАСТИ/NOT_VERIFIED: исходный task/ContextPack/сессии/104-трассы не выданы.
8. Рв991-FP-8 — СОВЕТ: `retention-days: 14` в Д1.
9. НАБЛЮДЕНИЕ: дрейф B (dc396b6 вместо 8a699d1) — как в вердикте #105; StartScreen и workflows
   между ними не менялись.

## Что нужно для повторного суда

1. Implementer правит Д3 в #106 (named reason), CI #106 снова зелёный.
2. #107 перебазируется на новую голову #106; новый C и новый station-run.
3. Оркестратор делает новый `workflow_dispatch` mobile-cloud-e2e на ветке C. Сверяются
   expo-versions и android-e2e-cloud, artifacts и checkout/tree.
4. Новый суд на новых C₁/C; этот вердикт к ним не переносится.

## Итог

FAIL. Пины, сравнитель (обе фазы и матрица 30/0), probe (2/2, 6/6), Jest в quality (3 ≥ 1+2),
station artifacts (хеши пересчитаны по ID), нативный reset и evidence-replay (16 классов × 2
workflow) — зелёные. Блокеры: шаг версии Maestro без названной причины
`MAESTRO_VERSION_MISMATCH` (живёт в #106) и отсутствующий cloud dispatch на C. Ни один PR не
смержен, merge не выполнялся.
