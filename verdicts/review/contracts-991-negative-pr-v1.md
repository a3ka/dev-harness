FAIL

# Ревью 991 — отрицательный PR a3ka/Complior-mob#105, v1

OBJECT=cd217484689a1ec36e9c530b5fe8fb0fe46811ea
Роль: reviewer (Reviewer991Neg); проверял сам, с Adversary991Neg не согласовывал.
Контракт: contracts/991-complior-repeticiya-p107-p111.md, §Приёмочный критерий п.1, п.3; §Зоны (закрытый список дельт КАРКАСА, Д1, фаза negative).
H (байты эталона и сравнителя) = wip/991/architect = fc8a8898791fd99e742c77da752e9d8cd282fac8

`FAIL` здесь означает подтверждённый ожидаемый исход: объект падает на отсутствии кнопки `rehearsal-start`, а не на инфраструктуре. Блокирующих находок нет.

## Объект
- B (фактическая база) = dc396b6134b1ab1670cf35551c0d4e48a845d073 (= origin/main, merge-base с C)
- C (head PR) = cd217484689a1ec36e9c530b5fe8fb0fe46811ea; один коммит, автор `implementer <implementer@dev-harness.local>`, родитель dc396b6
- T (checkout в CI) = f340761e72cf4858a7be418b1dc8f9f3f065eab1 (refs/pull/105/merge, родители dc396b6 и cd21748). Дерево T = дерево C = c81cb4890d593523d5799c39400fea42606e682b; `git diff --name-only C T` → 0 путей
- Run 39031080102, attempt 1, event pull_request, workflow `.github/workflows/mobile.yml` (blob 58ae87b88cf3556b8e65006380b5cd73f8cbe42a, sha256 8e9b1997a04eda3d1aefb2baf63277234e1d2789b9c91ba3d7d8e5277964109f). Для этого head SHA run только один.

## 1. Живой статус проверок
`gh pr checks 105 --repo a3ka/Complior-mob` → rc=1:
```
android-e2e	fail	4m18s	…/runs/39031080102/job/117391627572
quality	pass	45s	…/runs/39031080102/job/117391483482
```
API jobs: 117391483482 quality success; 117391627572 android-e2e failure, runner station-complior, head_sha = C.

## 2. Assertion в логе job (нашёл сам)
`gh api /repos/a3ka/Complior-mob/actions/jobs/117391627572/logs`, 1141 строка:
```
2026-10-17T12:07:52.1266843Z BUILD SUCCESSFUL in 2m 37s
2026-10-17T12:09:02.9418540Z [Failed] 991 start action and new-launch reset (20s) (Assertion is false: id: rehearsal-start is visible)
2026-10-17T12:09:05.5256783Z [Passed] Стартовый экран открывается (3s)
2026-10-17T12:09:05.5291314Z 1/2 Flow Failed
2026-10-17T12:09:09.7633970Z ##[error]Process completed with exit code 1.
```
Инфраструктура исключена тремя независимыми мерами:
- grep полного лога по `kvm|parse|error|fail|emulator|adb`: из инфраструктуры ничего, только Gradle-задачи `*ConfigurationErrors SKIPPED`/`parse*Resources` и предупреждения deprecated. Сборка прошла успешно, эмулятор поднялся, соседний flow start.yaml прошёл (PASSED) на том же APK и устройстве.
- JUnit `report.xml` из artifact maestro (12100750910, zip sha256 390bff801d7abcdc59782dc4a7ef14927766733791d5765924d1a84b15e136f4): `tests=2 failures=1`; testcase `.maestro/rehearsal.yaml` → status ERROR, `<failure>Assertion is false: id: rehearsal-start is visible</failure>`; `.maestro/start.yaml` → SUCCESS.
- `commands.json` упавшего flow: defineVariables, applyConfiguration (appId com.complior.mobile), launchApp clearState, assertVisible `start-screen` завершены (COMPLETED); падает assertVisible `rehearsal-start` (FAILED, 15689 мс). В screen-hierarchy шага 005 есть `resource-id: start-screen` и тексты «Complior», «Mobile — Grundgerüst»; совпадений `rehearsal|Prüfung` — 0. maestro.log по `kvm|device offline|unauthorized|parse|exception` — 0 совпадений.

Причина падения — именно отсутствие кнопки rehearsal-start на неизменённом StartScreen.

## 3. APK-artifact, пересчёт SHA-256
Artifact 12100870380 `apk-f340761e72cf4858a7be418b1dc8f9f3f065eab1-39031080102-1`, не истёк, workflow_run.head_sha = C. Скачал по ID через REST `/actions/artifacts/12100870380/zip`:
- zip: sha256 **5b155ebec83e817ef57ef413abad935362c7eec35f5029f8f0504062581f971f**, 26078013 байт. Совпадает с digest из API и со строкой лога `SHA256 digest of uploaded artifact`.
- внутри: `app-release.apk`, 43909392 байт, sha256 **b3db410793a92ee18a77d21ff706ee0aefae92764953c04f8dbbca2b569353a1**.
- Имя artifact соответствует `apk-<checkoutSHA>-<run_id>-<run_attempt>`: checkoutSHA = T.

## 4. Flow байт-в-байт с эталоном H
Эталон снят ПЕРВЫМ действием, до любого чтения PR: `git -C /home/harness/dev-harness show wip/991/architect:fixtures/workshop_project/rehearsal_991/rehearsal.yaml | sha256sum` → eef6d0b7df2cb84832f76886632e364f97c1349b065de54267151b6456c78d50.
PR: `git show C:mobile/.maestro/rehearsal.yaml | sha256sum` → eef6d0b7df2cb84832f76886632e364f97c1349b065de54267151b6456c78d50. `cmp` с эталоном → BYTE_EQUAL. В B файла нет: в `ls-tree dc396b6 mobile/.maestro/` только start.yaml, то есть файл новый.

## 5. Живой diff и Д1
Свежий клон `https://github.com/a3ka/Complior-mob.git`, `git diff --name-only dc396b6 C`:
```
.github/workflows/mobile.yml
mobile/.maestro/rehearsal.yaml
```
`wc -l` = 2. Оба пути входят в ЗОНУ implementer.
Дифф mobile.yml — ровно один новый шаг в конце job android-e2e, после `Эмулятор API 36 + сценарии Maestro` и после существующего `Артефакты`:
```
+      - name: Release APK
+        if: always()
+        uses: actions/upload-artifact@v7
+        with:
+          name: apk-${{ github.sha }}-${{ github.run_id }}-${{ github.run_attempt }}
+          path: mobile/android/app/build/outputs/apk/release/app-release.apk
+          if-no-files-found: error
+          retention-days: 14
```
`continue-on-error` нет. Существующий шаг `Артефакты` не изменён: `if-no-files-found: warn` и имя `maestro-${{ github.sha }}`, то есть Д2 в negative не протащена. quality, mobile-cloud-e2e.yml, ключи верхнего уровня не тронуты.
Механическая мера — сравнитель из H, материализован из wip/991/architect:
- `compare_carriers.py --repo R --base dc396b6… --head cd21748… --phase negative` → `rc=0 ACCEPTED`
- красная сторона на той же базе: `--matrix` → executed=30, mismatches=0. Честные negative/freeze/positive дают rc 0, обманы — rc 1 с именованным отказом (в том числе `negative-cloud-change`, `apk-soft-failure`, `pin-FLOW_BYTES_MISMATCH`), неисполнимые — rc 2.

## 6. PR не смержён
`gh pr view 105 --json …` → `state: OPEN`, `mergedAt: null`, `closed: false`, headRefOid = C, changedFiles 2, isCrossRepository false.

## Находки
1. [НАБЛЮДЕНИЕ, не блокирует] Дрейф B. Контракт (п.1 критерия, строка 160) называет базу 8a699d175114f82395e019964ee1fec02a6bb200, PR построен на dc396b6 (текущий main, 6 коммитов вперёд). `git diff 8a699d1 dc396b6 -- .github mobile/src mobile/.maestro` пуст; меняются только mobile/eslint.config.js, mobile/package.json (`lint` += `node scripts/check-structure.cjs`; `test` остаётся `jest --ci --runInBand`), новый mobile/scripts/check-structure.cjs и mobile/structure-policy.json. StartScreen и workflows не изменены. По §строке 31 («изменение B требует новых свидетельств») новое свидетельство для B=dc396b6 сделано выше: matrix 30/0 и negative ACCEPTED. Карточке нужно явно записать B=dc396b6.
2. [НАБЛЮДЕНИЕ, не блокирует] В Д1 есть ключ `retention-days: 14`, которого нет в тексте Д1. Сравнитель H его принимает, на исход не влияет. Если ключ нежелателен, это вопрос к грамматике сравнителя, а не к PR.
3. [ВНЕ ОБЛАСТИ] п.3 критерия требует два независимых FAIL через 104 и сохранённый HTTP-отказ merge-API владельцу. Это не предмет данного ревью; данный вердикт — одно из свидетельств.

## Сверка с Adversary991Neg
Вывод Adversary991Neg на момент ревью недоступен (`agent://Adversary991Neg` → Not found), сравнение не выполнено. Расхождения проверяет оркестратор.

## Итог
FAIL подтверждён: quality success, android-e2e failure; первичная причина — `Assertion is false: id: rehearsal-start is visible` в логе, JUnit и commands.json; flow побайтно равен H; дифф — 2 файла, Д1 в чистом виде; APK sha256 пересчитан; PR OPEN, не смержён.
