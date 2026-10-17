FAIL

# Контракт 991, шаг 2 — отрицательный PR #105

`OBJECT=cd217484689a1ec36e9c530b5fe8fb0fe46811ea`

Проверено живьём 2026-10-17. `gh pr view 105 --repo a3ka/Complior-mob --json headRefOid` вернул ровно `cd217484689a1ec36e9c530b5fe8fb0fe46811ea`.

1. `gh pr checks 105 --repo a3ka/Complior-mob`: `quality` — `pass` (45s); `android-e2e` — `fail` (4m18s), run `39031080102`, job `117391627572`.
2. `gh run view 39031080102 --repo a3ka/Complior-mob --job 117391627572` показывает успешные сборку release APK и artifact uploads, но отказ шага `Эмулятор API 36 + сценарии Maestro`. Лог, скачанный через `gh api /repos/a3ka/Complior-mob/actions/jobs/117391627572/logs`, содержит: `[Failed] 991 start action and new-launch reset (20s) (Assertion is false: id: rehearsal-start is visible)`, затем `1/2 Flow Failed` и exit 1. До этого `BUILD SUCCESSFUL`; это не offline, `DeviceServerDiedException` или KVM-ошибка.
3. Артефакты скачаны API-эндпоинтами `/actions/artifacts/12100870380/zip` и `/actions/artifacts/12100750910/zip`. SHA-256 контейнера APK равен `5b155ebec83e817ef57ef413abad935362c7eec35f5029f8f0504062581f971f`, что совпадает с API digest. Однако SHA-256 единственного payload `app-release.apk` внутри APK ZIP равен `eef6d0b7df2cb84832f76886632e364f97c1349b065de54267151b6456c78d50`, а не заявленному `b3db410793a92ee18a77d21ff706ee0aefae92764953c04f8dbbca2b569353a1`: **APK_PAYLOAD_SHA_MISMATCH**. Maestro ZIP пересчитан как `390bff801d7abcdc59782dc4a7ef14927766733791d5765924d1a84b15e136f4`, совпадающий с его API digest.
4. Ответ `contents/mobile/.maestro/rehearsal.yaml?ref=cd217484689a1ec36e9c530b5fe8fb0fe46811ea` декодирован из base64 и побайтно (`cmp`) совпал с `git -C /home/harness/dev-harness show wip/991/architect:fixtures/workshop_project/rehearsal_991/rehearsal.yaml`; у обоих SHA-256 `b3db410793a92ee18a77d21ff706ee0aefae92764953c04f8dbbca2b569353a1`.
5. В свежем клоне `git diff --name-only dc396b6 cd217484` вывел ровно `.github/workflows/mobile.yml` и `mobile/.maestro/rehearsal.yaml`. Diff workflow — только восемь добавленных строк одного шага `Release APK` после Maestro: `if: always()`, `actions/upload-artifact@v7`, правильный release path и `if-no-files-found: error`; `continue-on-error`, изменения `quality` и иные шаги отсутствуют.

Итог: требуемый отрицательный Android-отказ именно на отсутствии `rehearsal-start` подтверждён, но пункт 3 не проходит: заявленный SHA-256 внутреннего APK не соответствует скачанному payload. Поэтому это независимый `FAIL`, а не достаточное evidence для закрытия шага.
