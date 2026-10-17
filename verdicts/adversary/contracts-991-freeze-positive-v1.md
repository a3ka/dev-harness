FAIL

OBJECT=33947b8f9701ac98a918a4667a051ff39f9f426e

Свежий клон: `/tmp/dev-harness-verify/Adversary991FreezePositive/Complior-mob`.

## Блокер — нет cloud evidence положительного C

§Последовательность п.6 и §Приёмочный критерий п.92 требуют после station-run новый `workflow_dispatch` существующего `mobile-cloud-e2e` на неподвижном C, с реальным зелёным `expo-versions` и `android-e2e-cloud` и cloud APK/JUnit/PNG evidence-комплектом.

Проверка GitHub API именно по C:

```text
$ gh api --method GET repos/a3ka/Complior-mob/actions/runs \
  -f head_sha=33947b8f9701ac98a918a4667a051ff39f9f426e -f per_page=100
39043085409  mobile  pull_request  success
```

Это единственный run данного head: station workflow `mobile`, event `pull_request`. `gh run list --repo a3ka/Complior-mob --workflow mobile-cloud-e2e.yml --limit 30 …` дал ноль строк. `gh pr view 106/107 --json comments` не дал альтернативного run/artifact evidence. Поэтому cloud run ID, cloud APK/JUnit/PNG, cloud checkout/tree и cloud Maestro/flow сверить невозможно. Зелёный station-run не заменяет независимую cloud-сверку. Это достаточный FAIL.

## Подтверждённые части (не отменяют блокер)

### Objects, CI, carrier integrity

- #106: B=`dc396b6134b1ab1670cf35551c0d4e48a845d073`, C=`3b440a577da618321db7d38662803707b8ef42eb`, station run `39042249676`: quality `117423923873` success, android-e2e `117424094012` success.
- #107: B=`3b440a577da618321db7d38662803707b8ef42eb`, C=`33947b8f9701ac98a918a4667a051ff39f9f426e`, station run `39043085409`: quality `117426344232` success, android-e2e `117426504720` success. Quality log: `PASS src/features/start/__tests__/rehearsal.test.tsx`; `Tests: 3 passed, 3 total`.
- CI checkouts: freeze T=`9e26c8a80073ba6320889c7bf67fb940d3011844`, positive T=`a9f71e4c04c0040e5692e5ac3fad55e95129cf6f`. Их trees равны corresponding C (`a747e805…`, `694dcfb3…`); `git diff --name-only C T` пуст в обоих случаях.
- До запуска PR взят H=`wip/991/architect`=`fc8a8898791fd99e742c77da752e9d8cd282fac8`: Jest `eb540c9677cf8ab9c1d01472b7aa621fb9c9a4b62b5eea680e2c0e5491c54879`, flow `eef6d0b7df2cb84832f76886632e364f97c1349b065de54267151b6456c78d50`, comparator `1287387d0e2ec29c0d0801ca4ae438e8bee11f12b89fe4ae5523b04c43934598`.
- Positive C Jest и rehearsal flow побайтно равны H; от freeze к positive не менялись `start-screen.test.tsx`, `start.yaml`, `mobile/scripts/ci-e2e.sh`.
- Comparator из H: #106 `--phase freeze` → `rc=0 ACCEPTED`; #107 `--phase positive` → `rc=0 ACCEPTED`; `--matrix` на B #106 → `executed=30, mismatches=0`. Матрица действительно отклонила ослабления quality/job/evidence, изменённые flow directories, вне-зону, pins и unreadable YAML.

### Скачанные station artifacts и SHA-256

Артефакты скачаны `gh run download` по ID и payload пересчитан.

| Object | IDs | Recomputed payload |
|---|---:|---|
| #106 / T `9e26c8a…` | maestro `12104806604`, APK `12104746823` | APK `c5109654b3221b8906397705e7ec4b85c94d1a2c0a84381d2b6fa543d4b85922`; JUnit `2e7dc5017a6e4dc0a6e48118a55b8c7437be0ae2d66a38cc8580c4e1572e93eb`, один `start.yaml` SUCCESS. |
| #107 / T `a9f71e4…` | maestro `12104517603`, APK `12104592604` | APK `65fda6d6edf5a03c63c3e2ed55e1a87f0e2f872084127adb7ee9bd9fd29611bc`; JUnit `7315aa54e02fcf78facead3ff7950735608ba22995a2c880b3e7da1eb15faf6d`; before PNG `ec4823ab5ede7ce4a3f40b4df461b6757bf123f3c255f2be643ab8c6fd20db84`; after PNG `ba4c9c44786481f66f79e87317c5d8a132505b57d6edd9ae39055c8183da5cfb`. |

Positive JUnit содержит `rehearsal.yaml` SUCCESS; PNG ровно по одному и равны каноническим копиям. Скачанный manifest содержит те же пять hashes, T, `run/attempt=39043085409/1`, Maestro `2.11.0`. API ZIP digests: maestro `96febddaa85014e64716831fb2f1f10676617aa0ee4c903a2e2196e518e32151`; APK `71a79bb6d26eaa5eb97d128bcc7d8f85ea57b1742337e428581101b76de059de`.

### Replay и adversarial controls

В scratch с реальными C files и скачанными #107 APK/JUnit/PNG `bash --noprofile --norc -eo pipefail scripts/rehearsal-evidence.sh` прошёл. Version step прошёл с `maestro --version=2.11.0`; `2.10.0` и отсутствующий PATH-tool дали rc=1.

Ровно соответствующие негативные копии дали:

```text
нет APK                         -> EVIDENCE_MISSING: android/app/build/outputs/apk/release/app-release.apk, rc=1
пустой rehearsal-before.png     -> EVIDENCE_EMPTY: rehearsal-before.png, rc=1
нет rehearsal-after.png         -> EVIDENCE_MISSING: rehearsal-after.png, rc=1
duplicate rehearsal-after.png   -> DUPLICATE_EVIDENCE: rehearsal-after.png, rc=1
JUnit failure/status FAILURE    -> JUNIT_REHEARSAL_INVALID, rc=1
```

На копии без after-PNG плацебо `test -d maestro-out` вернул rc=0, в отличие от реального D4 rc=1.

Trusted H probe на C: actual `executed=2` pass; matrix `executed=6` pass — honest R1/R2 зелёны, `noop/R1`, `premature/R1`, `sticky/R2` красны, `sticky/R1` (контроль правильного ответа на другой вопрос) зелёный. Subject/test восстановлены (`git diff --exit-code` пуст).

## Неблокирующее наблюдение

Station log #107 содержит первичное `[Failed] 991 start action and new-launch reset (1s)`, затем retry с сообщением об adb transport и успешную вторую попытку. `ci-e2e.sh` принимает retry по `grep -rqE 'device offline|DeviceServerDiedException' maestro-out`, затем удаляет `maestro-out`; итоговый artifact сохраняет только вторую попытку. Точную причину первого failure по сохранённому evidence перепроверить нельзя. Основной FAIL выше не зависит от этого наблюдения.
