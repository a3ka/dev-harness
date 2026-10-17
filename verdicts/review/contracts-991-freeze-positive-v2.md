FAIL

# Ревью 991 — Freeze-PR a3ka/Complior-mob#106 и положительный PR #107, v2 (круг 2)

OBJECT=7e74d2da70866a914bc1794f6110a822fd444bd8
FREEZE_OBJECT=8235118f6d2ea062351a44df5c16ba895c3b5c6d
Роль: reviewer (LinguisticPrimate). Проверял сам, с adversary не согласовывал. Клон, хеши,
прогоны и скачивания — свои, `/tmp/dev-harness-verify/rev991fp2/`.
Контракт: `frozen/contracts/991/2` (commit 2831d37a4), §Последовательность п.4–7,
§Приёмочный критерий, §Зоны (Д1–Д4, Дс5, фазы freeze/positive), §«Пины, карточка и доверие».
Находки (reslop): `.review/2026-10-17-02.md`. Круг 1: `verdicts/review/contracts-991-freeze-positive-v1.md`.

| PR | Исход | Блокеры |
|---|---|---|
| #106 freeze (8235118f) | FAIL | Рв991-FP-9 (журнал карточки) |
| #107 positive (7e74d2da) | FAIL | Рв991-FP-9 (журнал карточки) |

Код, workflows, сравнитель, version/evidence replay, station- и cloud-evidence на C приняты.
Круг 1 закрыт по существу: Рв991-FP-1 и Рв991-FP-2 закрыты, это видно в исполнении, а не только
в словах. Единственный блокер — журнал карточки #103 не ведётся с 15:07Z. Его фикс — дописать
комментарии; C он не меняет. Повторно сверить нужно будет только сами комментарии.

## Пины, объект, провенанс

- H = `frozen/contracts/991/2` (2831d37a4). Байты сняты первым действием через `git archive`
  в `…/h/`:
  ```
  eb540c9677cf8ab9c1d01472b7aa621fb9c9a4b62b5eea680e2c0e5491c54879  rehearsal.test.tsx
  eef6d0b7df2cb84832f76886632e364f97c1349b065de54267151b6456c78d50  rehearsal.yaml
  da3e286e4a343daac40e3b8e23737171dfb8c01d620f933d23a7de2e3f803946  compare_carriers.py (v2)
  613dba7c81eed1a8e64558cb7673f41aa3ead1426ffbe4e71efeb0073fbd3336  matrix_carriers.py (v2)
  ```
  Пины Jest и flow те же, что в круге 1. В C байты совпадают:
  `git show 7e74d2da:mobile/src/features/start/__tests__/rehearsal.test.tsx | sha256sum` → eb540c96…54879,
  `…:mobile/.maestro/rehearsal.yaml` → eef6d0b7…78d50.
- Свежий клон Complior-mob, refs `pull/10{6,7}/{head,merge}`:
  ```
  origin/main = B = dc396b6134b1ab1670cf35551c0d4e48a845d073
  pr106 = 8235118f6d2ea062351a44df5c16ba895c3b5c6d   pr107 = 7e74d2da70866a914bc1794f6110a822fd444bd8
  ls-remote: fix/991-freeze-maestro-uploads=8235118f…, fix/991-positive-rehearsal=7e74d2da… (ветки стоят)
  ```
  Цепочка (все `implementer <implementer@dev-harness.local>`):
  ```
  3b440a57 ← dc396b6  991 freeze: Д1 + Д2 + Д3                                   14:47:05Z
  8235118f ← 3b440a57 991 freeze: Д3 rehearsal_version named reason (Рв991-FP-1)  16:08:55Z
  7967f759 ← 8235118f 991 positive rehearsal: StartScreen Б1 + пины + Д4            16:10:09Z
  7e74d2da ← 7967f759 Дс5: освобождение диска перед cloud-эмулятором (991)         18:49:31Z
  ```
  Атомарность соблюдена: FP-1, positive и Дс5 идут отдельными коммитами со ссылкой на предмет.
  `git diff --stat 7967f759 7e74d2da` → только `.github/workflows/mobile-cloud-e2e.yml | 8 +`.
  `git diff --stat 33947b8f 7e74d2da` (объект круга 1 → текущий) → только два workflow
  (+20/−2), то есть `rehearsal-evidence.sh`, StartScreen, Jest и flow побайтно те же, что в
  круге 1. Фикстуры и контракт 991 implementer'ом не тронуты: `git log --all --author=implementer --
  fixtures/workshop_project/rehearsal_991 contracts/991-…` пусто.
- `gh pr view`: #106 и #107 OPEN, `mergedAt` null, baseRefName `main` (Рв991-FP-6).
- Блобы workflows, old/new (блоб | sha256 | число вхождений `2.11.0`):
  ```
  B         mobile.yml a965eecb6198 c3ca0e055558746a 0 | cloud 5a5ee7ff7b08 61cb65d93c574373 0
  3b440a57  mobile.yml b92e1b6cf167 965c6ed28a33a1dc 1 | cloud 6001f7ddddfd d3d11d68837f1689 2   (круг 1)
  8235118f  mobile.yml 870c030d01af 8867fe8150d5ec87 2 | cloud 7e5b74042953 4cc336c9bd3cf3eb 3
  7e74d2da  mobile.yml e7a4c54f9d46 4c6a9b2aecce4573 2 | cloud 7ec44c2b75f0 8ad28a7b25e2d52e 3
  ```
  В mobile.yml `2.11.0` встречается в теле version-шага дважды: сравнение и текст причины.
  В cloud к ним добавляется `MAESTRO_VERSION=2.11.0` установщика. Тело install-шага Д3 на C:
  `curl -fsSL https://get.maestro.mobile.dev | MAESTRO_VERSION=2.11.0 bash` и
  `echo "$HOME/.maestro/bin" >> "$GITHUB_PATH"`. Оно не изменилось с круга 1 и новых побочных
  действий не добавляет (cognitive-only, класс 4).

## П2. compare_carriers.py H-v2 (своя мера)

```
--base B        --head 8235118f --phase freeze    → rc=0 ACCEPTED
--base 8235118f --head 7e74d2da --phase positive  → rc=0 ACCEPTED
--base 8235118f --head 7967f759 --phase positive  → rc=1 CARRIER_CHANGED: …mobile-cloud-e2e.yml:android-e2e-cloud:missing-Ds5   (реальный C без Дс5 — красный)
--base B        --head 7e74d2da --phase positive  → rc=1 CARRIER_CHANGED: …mobile.yml:android-e2e:steps[7]   (Рв991-FP-6)
--base 8235118f --head 7e74d2da --phase freeze    → rc=1 CARRIER_CHANGED: …mobile.yml:android-e2e:steps[6]
--base B        --head 8235118f --phase positive  → rc=1 CARRIER_CHANGED: …mobile.yml:android-e2e:steps[6]
--base B        --head 8235118f --phase negative  → rc=1 CARRIER_CHANGED: …mobile.yml:android-e2e:steps[6]
--base B --matrix                                 → rc=0 executed=63 mismatches=0
```
Строк `Ds5-*` в выводе матрицы 33, все `rc=1 expected=1`. Среди них missing, duplicate,
changed/missing для каждого из пяти ключей, extra-if/continue-on-error/env/uses, позиции
0–7 и 9–13, wrong-workflow, wrong-job, wrong-phase-negative/freeze.

Дс5 своей мерой (`replay.py`, YAML-объект извлечён из текста контракта v2 и сравнён со
step-dict C): `Ds5 idx=[8] exact_equal=True prev='KVM' next='Эмулятор API 36 + сценарии Maestro'`.
В `mobile.yml` Дс5 нет.

## Рв991-FP-1 — version replay (своя мера, `replay.py`)

`bash --noprofile --norc -eo pipefail STEP`, где STEP — реальное `run`-тело шага
`id: rehearsal_version`, извлечённое из YAML; `maestro` — заглушка в PATH.
```
8235118f mobile.yml        2.11.0 rc=0 | 2.10.0 rc=1 "MAESTRO_VERSION_MISMATCH: expected=2.11.0 actual='2.10.0'" | absent rc=1 "…actual=''"
8235118f mobile-cloud-e2e  2.11.0 rc=0 | 2.10.0 rc=1 "MAESTRO_VERSION_MISMATCH: …actual='2.10.0'"                 | absent rc=1 "…actual=''"
7e74d2da mobile.yml        2.11.0 rc=0 | 2.10.0 rc=1 "MAESTRO_VERSION_MISMATCH: …actual='2.10.0'"                 | absent rc=1 "…actual=''"
7e74d2da mobile-cloud-e2e  2.11.0 rc=0 | 2.10.0 rc=1 "MAESTRO_VERSION_MISMATCH: …actual='2.10.0'"                 | absent rc=1 "…actual=''"
3b440a57 (круг 1, красное) 2.10.0 rc=1 named=False out=''   (оба workflow)
плацебо H `maestro --version || true` @2.10.0 → step_rc=0 → `test "$step_rc" -ne 0` rc=1 → VERSION_CHECK_PLACEBO ловится
```
Живые прогоны: station 39059857986 и cloud 39061274882 — шаг `Check Maestro version` success.
В обоих манифестах `maestro_version: "2.11.0"`.

## Рв991-FP-2 — свежий cloud dispatch (живьём `gh run view` / `gh api`)

```
gh api …/actions/runs/39061274882 → run_attempt=1 path=.github/workflows/mobile-cloud-e2e.yml
  head_sha=head_commit=7e74d2da70866a914bc1794f6110a822fd444bd8 head_branch=fix/991-positive-rehearsal
  event=workflow_dispatch conclusion=success tree=5bcfa65b72c6611329b02815b72cb8a639a02e83 (= tree C)
android-e2e-cloud id=117479581321 success 19:10:11Z→19:27:13Z
  8 Maestro · 9 KVM · 10 Освобождение диска перед cloud-эмулятором · 11 Эмулятор API 36 + сценарии Maestro ·
  12 Check rehearsal evidence · 13 Артефакты · 14 Release APK · 15 Check Maestro version — все success
expo-versions id=117479581514 success 19:10:11Z→19:10:35Z
```
Checkout в логе job: `fetch … +7e74d2da…:refs/remotes/origin/fix/991-positive-rehearsal`,
`git log -1 --format=%H` → 7e74d2da…. Нативный шаг: `[Passed] Стартовый экран открывается (19s)`,
`[Passed] 991 start action and new-launch reset (28s)`, `2/2 Flows Passed in 47s`. Evidence-шаг
напечатал `rehearsal evidence OK: …`.

Дс5 в облаке — сохранённый вывод `df` до и после (контракт: «новый зелёный cloud-run … с
сохранённым выводом df до/после»):
```
19:22:07.3072879Z /dev/root  72G  67G  4.8G  94% /
19:22:42.4194324Z /dev/root  72G  48G   24G  67% /
```
Порядок п.6: station-run 39059857986 закончился в 18:55:28Z, засчитанный cloud-run создан в
19:10:08Z — после. Полный перечень cloud-runs workflow (`…/workflows/mobile-cloud-e2e.yml/runs`):
```
39061274882 workflow_dispatch 7e74d2da success a1 19:10:08Z
39059897917 workflow_dispatch 7e74d2da failure a1 18:50:53Z   ANR: «System UI isn't responding» (screen-hierarchy art 12111376631), logcat «ANR in com.google.android.gms.persistent»; оба flow «Assertion is false: id: start-screen is visible»
39050228377 workflow_dispatch 7967f759 failure a1 16:37:35Z   «No space left on device» (job 117447133395)
39049017837 workflow_dispatch 7967f759 failure a1 16:21:02Z   «No space left on device» (job 117443555621)
```
Сказанное в задании о трёх красных прогонах подтверждено логами. Версия задания «тот же C без
Дс5-изменений» про третий прогон неточна: 39059897917 шёл уже на 7e74d2da, то есть с Дс5, и
его `df` показывает те же 4.8G→24G. Version-drift ни в одном красном нет: шаг Maestro до
version-проверки не дошёл, а при дефиците диска падал раньше, на установке system image.

## Station (#107, `gh pr checks 107 --required` rc=0)

```
run 39059857986 pull_request head=7e74d2da a1: quality 117475399144 success, android-e2e 117475574180 success
T = 43b1c7d6e2d84361e41f350b9293ebfbd541a2a9 (merge B+C), tree 5bcfa65b… = tree C
quality log: «PASS src/features/start/__tests__/rehearsal.test.tsx», «Tests:       3 passed, 3 total» (база 1 + 2)
#106: gh pr checks 106 --required rc=0, run 39048176557 head=8235118f a1 success; tree pull/106/merge = tree 8235118f = a840e09b
```

## Evidence: artifacts по ID и replay (`evreplay.py`)

Digest zip, посчитанный `sha256sum` по скачанному, совпадает с `digest` из API у всех пяти:
```
12112125915 maestro-7e74d2da…-39061274882-1   de3e6c26…d3c2
12111482980 apk-7e74d2da…-39061274882-1       7f2019d8…dcf14
12111475089 maestro-43b1c7d6…-39059857986-1   612b622e…db94
12110069808 apk-43b1c7d6…-39059857986-1       d1c22e8c…aa1b
12111376631 maestro-7e74d2da…-39059897917-1   215ac7d5…65c6   (красный ANR-прогон)
```
Манифест сверен с файлами: APK, JUnit и оба PNG совпадают по sha256 в обоих комплектах. Flow =
пин eef6d0b7. Каждое имя PNG встречается в выводе Maestro ровно один раз. context cloud:
`GITHUB_SHA=7e74d2da… RUN_ID=39061274882 ATTEMPT=1`; station: `GITHUB_SHA=43b1c7d6… RUN_ID=39059857986`.
JUnit обоих: tests=2 failures=0, testcase `.maestro/rehearsal.yaml` status=SUCCESS.
Replay реального `run`-тела `rehearsal_evidence` с файлами C в scratch, на копиях комплектов
(одинаково для cloud и station):
```
honest rc=0 | missing-after rc=1 EVIDENCE_MISSING: rehearsal-after.png | empty-before rc=1 EVIDENCE_EMPTY: rehearsal-before.png
dup-after rc=1 DUPLICATE_EVIDENCE: rehearsal-after.png | empty-apk rc=1 EVIDENCE_EMPTY: …/app-release.apk
no-junit rc=1 EVIDENCE_MISSING: maestro-out/report.xml | junit-error rc=1 JUNIT_REHEARSAL_INVALID
плацебо `test -d maestro-out` без after.png → step_rc=0 → EVIDENCE_CHECK_PLACEBO ловится
```
PNG cloud и station побайтно равны (Рв991-FP-11).

## Находки

Блокер:
- **Рв991-FP-9** (обязательство §«Пины, карточка и доверие»: «До действия записать… Каждое
  действие … run/attempt/PR/artifact и обнаруженный дефект»; «перезапуски учитываются» в лимите
  ≤8 вмешательств). Фрагмент: последний комментарий карточки a3ka/Complior-mob#103 датирован
  2026-10-17T15:07:13Z (run 39043085409). Источник: `gh api repos/a3ka/Complior-mob/issues/103/comments`.
  В журнале нет ни одного упоминания 39059897917, 39061274882 или ANR, нет и записей о
  8235118f, 7967f759, 7e74d2da, 39048176557, 39048562391, 39059857986, 39049017837, 39050228377.
  Комментариев в #107 тоже нет. Наблюдаемое противоречие: четыре cloud-dispatch, из них три
  красных, и перестройка C прошли без журнала, поэтому счёт вмешательств и перезапусков
  проверить нельзя.

Советы (не блокируют): Рв991-FP-3, FP-6, FP-7 из круга 1 остаются в силе. Новые — Рв991-FP-10
(первый dispatch на C раньше конца station-run; не засчитан) и FP-11 (равенство PNG). Подробности
в `.review/2026-10-17-02.md`.

## Паразитная сложность (050), артефакты, новые с круга 1

- **Тело шага `rehearsal_version` (оба workflow, блочный `run: |`).** (1) Требует его
  §Приёмочный критерий: «rc≠0 с причиной … MAESTRO_VERSION_MISMATCH». (2) Состояния не вводит,
  причина видна в stderr. (3) Меняться вместе обязаны два workflow, как и в круге 1, число не
  выросло. (4) Интерфейс — ноль аргументов и один rc, глубина нормальная. (5) Потребитель —
  replay из приёмки и живой run. Однострочник `test …` причину не печатает и строку приёмки не
  проходит. ESSENTIAL.
- **Шаг Дс5 `rehearsal_disk_space` (только cloud).** (1) Требует его Дс5 v2 дословно.
  (2) Состояние — удалённые каталоги раннера; это явно видно в `run` и выводе `df`. (3) Меняются
  вместе только cloud workflow и фиксированный объект в контракте и сравнителе, то есть
  заморожено. (4) Аргументов нет. (5) Потребители — `compare_carriers` Ds5-* и cloud-run.
  Форма задана контрактом, более простая не проходит точного равенства. ESSENTIAL.
- `rehearsal-evidence.sh` и прочее с круга 1 побайтно те же, разбор круга 1 в силе.

## ПРОВОДКА

Guard этого предмета — `compare_carriers.py` из frozen v2. Его вызывают как барьер именно
каркаса 991 по фазам, а не как произвольный скрипт дерева. Поведенческая часть (version- и
evidence-тела) судится replay'ем reviewer'а, то есть идёт role-каналом. Подмены канала нет.

## Не проверено

- п.7: исходный task/ContextPack, session-id, трассы 104 этому ревьюеру не выданы (Рв991-FP-7).
- п.8 (owner Merge, push-run M) ещё не наступил.
