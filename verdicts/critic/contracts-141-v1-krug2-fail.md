FAIL
OBJECT=c1eaffc138dd424056d3cbdc6cc432130e0c470e
СУД: repo=dev-harness; предмет=141; фаза=контракт; роль=critic-sol; вызов=2/2; модель-план=openai-codex/gpt-6-sol; сессия=Critic141b; модель-факт=openai-codex/gpt-6-sol; SHA=c1eaffc138dd424056d3cbdc6cc432130e0c470e; предыдущий=/tmp/dev-harness-verify/Critic141/verdicts/critic/contracts-141-v1.md; исключение=нет
Независимость: автор Architect141/141b — zai/glm-5.3 (данные задания); судья Critic141b — openai-codex/gpt-6-sol (факт окружения). Предмет — коммит OBJECT в отдельном SSH-клоне; контракт не редактировался. Второй FAIL исчерпывает лимит 2/2: после подтверждённого блокера остальные запланированные измерения не проводились.

## Блокирует

БЛОКИРУЕТ contracts/141-obryv-adb-diagnostika.md:47 — повтор причины вызова 1: канон `run:` и replay не судят эффект *управляющей оболочки job*; новый whitelisted-различитель `continue-on-error` принимает семантическое true только как YAML bool / строку `true`, но пропускает разрешённое GitHub Actions выражение `${{ true }}`. Обязательство — сохранение красного итога при сбое целевых шагов 135/118/995, явно названное инвариантом 11 и защитой в :172. Класс причины — семантически одинаковое значение управляющего ключа в другом синтаксисе; состояние допустимо (YAML job android-e2e с модельными телами всех трёх шагов, разрешённым GitHub expression в `continue-on-error`); наблюдение — батарея возвращает rc 0, все 39 CASE ok, включая struktura-upravlenie-job, тогда как GH Actions считает такой job tolerable и workflow run успешным при его отказе. Официальный синтаксис: https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#jobsjob_idcontinue-on-error — «Prevents a workflow run from failing when a job fails» и пример `continue-on-error: ${{ matrix.experimental }}`; константа `${{ true }}` возвращает булево true.
ОБХОД: из точной модели `.github/workflows/mobile.yml` оставить `run:` всех трёх целевых шагов неизменными, добавить `jobs.android-e2e.continue-on-error: ${{ true }}`. Свидетель `/tmp/dev-harness-verify/Critic141b/attack-job-continue-expression/.github/workflows/mobile.yml`; `W --repo` rc 0, 39/39. В настоящем CI обрыв/провал валидатора не даёт красный workflow, а 139 не запускает единственный workflow rerun: предмет «красный итог и один повтор» не выполнен при зелёном критерии. Это не объявленный остаток :182 (`if` вне статически ложного семейства, существующий `needs` и значения *прочих* ключей job): `continue-on-error` прямо назван охраняемым различителем, константа true статически разрешима.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: красный тест для expression-формы, которая статически даёт true у job `continue-on-error`, и явная проверяемая граница для динамических форм этого же ключа, не изменяя допуск иных ключей job. Решение о конкретном анализаторе/политике принадлежит автору.
АРБИТР: созвать по предмету 141 после второго critic-FAIL. Спор — является ли job-level expression `${{ true }}` обязательным членом класса «управляющие свойства / сохранение красного итога» либо допустимым остатком за границей контракта; инженерный обход и rc 0 зафиксированы. Решение арбитра не подменяет третью подпись критика; дальнейший вызов — только по слову владельца (§Быстрый-процесс).

## Измерения

Подготовка: `git clone ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/Critic141b/repo && git -C /tmp/dev-harness-verify/Critic141b/repo checkout -q c1eaffc138dd424056d3cbdc6cc432130e0c470e` → rc 0, `Cloning into '/tmp/dev-harness-verify/Critic141b/repo'...`. Все дальнейшие `W` — `bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh`, cwd `/tmp/dev-harness-verify/Critic141b/repo`, через `env -i PATH=/usr/bin:/bin`, без omp/сети.

`env -i PATH=/usr/bin:/bin W` → rc 1; сырой вывод:
```text
SUBJECT_ABSENT: нет субъекта .github/workflows/mobile.yml; зелень без субъекта невозможна
CASE 135-oflin-povtor-spas KRASNO (SUBJECT_ABSENT)
CASE 135-adb-notfound KRASNO (SUBJECT_ABSENT)
CASE 135-serial-notfound KRASNO (SUBJECT_ABSENT)
CASE 135-devserverdied-povtor-krasen KRASNO (SUBJECT_ABSENT)
CASE 135-chistyj-proval KRASNO (SUBJECT_ABSENT)
CASE 135-zelenyj KRASNO (SUBJECT_ABSENT)
CASE 135-boot-ne-zagruzilsja KRASNO (SUBJECT_ABSENT)
CASE 135-stabil-nedostizhima KRASNO (SUBJECT_ABSENT)
CASE 135-emulator-log-hvost KRASNO (SUBJECT_ABSENT)
CASE 135-install-failed-bez-povtora KRASNO (SUBJECT_ABSENT)
CASE 135-pustoj-maestro-out KRASNO (SUBJECT_ABSENT)
CASE 118-oflin-povtor-spas KRASNO (SUBJECT_ABSENT)
CASE 118-devserverdied-povtor-spas KRASNO (SUBJECT_ABSENT)
CASE 118-povtor-tozhe-krasen KRASNO (SUBJECT_ABSENT)
CASE 118-chistyj-proval KRASNO (SUBJECT_ABSENT)
CASE 118-zelenyj KRASNO (SUBJECT_ABSENT)
CASE 118-boot-ne-zagruzilsja KRASNO (SUBJECT_ABSENT)
CASE 118-stabil-nedostizhima KRASNO (SUBJECT_ABSENT)
CASE 118-emulator-log-hvost KRASNO (SUBJECT_ABSENT)
CASE 995-diag-signatura KRASNO (SUBJECT_ABSENT)
CASE 995-chistyj-proval KRASNO (SUBJECT_ABSENT)
CASE 995-zelenyj KRASNO (SUBJECT_ABSENT)
CASE struktura-shag135 KRASNO (SUBJECT_ABSENT)
CASE struktura-shag118 KRASNO (SUBJECT_ABSENT)
CASE struktura-shag995 KRASNO (SUBJECT_ABSENT)
CASE struktura-pereformat135 KRASNO (SUBJECT_ABSENT)
CASE struktura-pereformat118 KRASNO (SUBJECT_ABSENT)
CASE struktura-pereformat995 KRASNO (SUBJECT_ABSENT)
CASE struktura-signatura135 KRASNO (SUBJECT_ABSENT)
CASE struktura-signatura118 KRASNO (SUBJECT_ABSENT)
CASE struktura-signatura995 KRASNO (SUBJECT_ABSENT)
CASE struktura-vyrazhenija KRASNO (SUBJECT_ABSENT)
CASE struktura-upravlenie-shag135 KRASNO (SUBJECT_ABSENT)
CASE struktura-upravlenie-shag118 KRASNO (SUBJECT_ABSENT)
CASE struktura-upravlenie-shag995 KRASNO (SUBJECT_ABSENT)
CASE struktura-upravlenie-job KRASNO (SUBJECT_ABSENT)
CASE derevo-bez-141 KRASNO (SUBJECT_ABSENT)
CASE derevo-chuzhoj-shag KRASNO (SUBJECT_ABSENT)
CASE derevo-shag-net KRASNO (SUBJECT_ABSENT)
```

`env -i PATH=/usr/bin:/bin W --model` → rc 0; сырой вывод:
```text
CASE 135-oflin-povtor-spas ok
CASE 135-adb-notfound ok
CASE 135-serial-notfound ok
CASE 135-devserverdied-povtor-krasen ok
CASE 135-chistyj-proval ok
CASE 135-zelenyj ok
CASE 135-boot-ne-zagruzilsja ok
CASE 135-stabil-nedostizhima ok
CASE 135-emulator-log-hvost ok
CASE 135-install-failed-bez-povtora ok
CASE 135-pustoj-maestro-out ok
CASE 118-oflin-povtor-spas ok
CASE 118-devserverdied-povtor-spas ok
CASE 118-povtor-tozhe-krasen ok
CASE 118-chistyj-proval ok
CASE 118-zelenyj ok
CASE 118-boot-ne-zagruzilsja ok
CASE 118-stabil-nedostizhima ok
CASE 118-emulator-log-hvost ok
CASE 995-diag-signatura ok
CASE 995-chistyj-proval ok
CASE 995-zelenyj ok
CASE struktura-shag135 ok
CASE struktura-shag118 ok
CASE struktura-shag995 ok
CASE struktura-pereformat135 ok
CASE struktura-pereformat118 ok
CASE struktura-pereformat995 ok
CASE struktura-signatura135 ok
CASE struktura-signatura118 ok
CASE struktura-signatura995 ok
CASE struktura-vyrazhenija ok
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-shag-net ok
```

`env -i PATH=/usr/bin:/bin W --stabs` → rc 0; сырой вывод:
```text
CASE 135-oflin-povtor-spas ok
CASE 135-adb-notfound ok
CASE 135-serial-notfound ok
CASE 135-devserverdied-povtor-krasen ok
CASE 135-chistyj-proval ok
CASE 135-zelenyj ok
CASE 135-boot-ne-zagruzilsja ok
CASE 135-stabil-nedostizhima ok
CASE 135-emulator-log-hvost ok
CASE 135-install-failed-bez-povtora ok
CASE 135-pustoj-maestro-out ok
CASE 118-oflin-povtor-spas ok
CASE 118-devserverdied-povtor-spas ok
CASE 118-povtor-tozhe-krasen ok
CASE 118-chistyj-proval ok
CASE 118-zelenyj ok
CASE 118-boot-ne-zagruzilsja ok
CASE 118-stabil-nedostizhima ok
CASE 118-emulator-log-hvost ok
CASE 995-diag-signatura ok
CASE 995-chistyj-proval ok
CASE 995-zelenyj ok
CASE struktura-shag135 ok
CASE struktura-shag118 ok
CASE struktura-shag995 ok
CASE struktura-pereformat135 ok
CASE struktura-pereformat118 ok
CASE struktura-pereformat995 ok
CASE struktura-signatura135 ok
CASE struktura-signatura118 ok
CASE struktura-signatura995 ok
CASE struktura-vyrazhenija ok
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-shag-net ok
STAB s-995-adb-glotnuto 995-diag-signatura KRASEN
STAB s-995-adb-glotnuto 995-chistyj-proval KRASEN
STAB s-995-bez-diag 995-diag-signatura KRASEN
STAB s-995-bez-diag 995-chistyj-proval KRASEN
STAB s-995-shagovoj-povtor 995-diag-signatura KRASEN
STAB s-adb-glotnuto-135 135-oflin-povtor-spas KRASEN
STAB s-adb-glotnuto-135 135-emulator-log-hvost KRASEN
STAB s-adb-glotnuto-135 135-devserverdied-povtor-krasen KRASEN
STAB s-bez-diag-118 118-chistyj-proval KRASEN
STAB s-bez-diag-118 118-oflin-povtor-spas KRASEN
STAB s-bez-diag-118 118-devserverdied-povtor-spas KRASEN
STAB s-bez-diag-135 135-chistyj-proval KRASEN
STAB s-bez-diag-135 135-oflin-povtor-spas KRASEN
STAB s-bez-diag-135 135-adb-notfound KRASEN
STAB s-bez-diag-135 135-serial-notfound KRASEN
STAB s-bez-diag-135 135-devserverdied-povtor-krasen KRASEN
STAB s-bez-itoga-stabil-118 118-stabil-nedostizhima KRASEN
STAB s-bez-itoga-stabil-135 135-stabil-nedostizhima KRASEN
STAB s-bez-povtora-118 118-oflin-povtor-spas KRASEN
STAB s-bez-povtora-118 118-devserverdied-povtor-spas KRASEN
STAB s-bez-signaturnogo-filtra-135 135-install-failed-bez-povtora KRASEN
STAB s-boot-bez-diag-135 135-boot-ne-zagruzilsja KRASEN
STAB s-diag-zaglushen-135 135-oflin-povtor-spas KRASEN
STAB s-diag-zaglushen-135 135-devserverdied-povtor-krasen KRASEN
STAB s-dva-povtora-118 118-povtor-tozhe-krasen KRASEN
STAB s-dva-povtora-135 135-devserverdied-povtor-krasen KRASEN
STAB s-emulator-log-uterjan-135 135-emulator-log-hvost KRASEN
STAB s-kanon-stroka-118 struktura-shag118 KRASEN
STAB s-kanon-stroka-135 struktura-shag135 KRASEN
STAB s-kanon-stroka-995 struktura-shag995 KRASEN
STAB s-podmena-signatury-diag-118 struktura-signatura118 KRASEN
STAB s-podmena-signatury-diag-135 struktura-signatura135 KRASEN
STAB s-podmena-signatury-diag-135 135-adb-notfound KRASEN
STAB s-podmena-signatury-diag-995 struktura-signatura995 KRASEN
STAB s-povtor-bez-perezapuska-135 135-oflin-povtor-spas KRASEN
STAB s-shag-pereimenovan-135 struktura-shag135 KRASEN
STAB s-signatura-rasshirena-135 135-install-failed-bez-povtora KRASEN
STAB s-signatura-suzhena-135 135-devserverdied-povtor-krasen KRASEN
STAB s-signatura-suzhena-135 struktura-signatura135 KRASEN
STAB s-tail-korotkij-135 135-emulator-log-hvost KRASEN
STAB s-upr-continue-995 struktura-upravlenie-shag995 KRASEN
STAB s-upr-env-path-135 struktura-upravlenie-shag135 KRASEN
STAB s-upr-if-always-995 struktura-upravlenie-shag995 KRASEN
STAB s-upr-if-false-135 struktura-upravlenie-shag135 KRASEN
STAB s-upr-if-literal-118 struktura-upravlenie-shag118 KRASEN
STAB s-upr-job-continue struktura-upravlenie-job KRASEN
STAB s-upr-job-env-path struktura-upravlenie-job KRASEN
STAB s-upr-job-if-false struktura-upravlenie-job KRASEN
STAB s-upr-shell-118 struktura-upravlenie-shag118 KRASEN
STAB s-upr-timeout-0-135 struktura-upravlenie-shag135 KRASEN
STAB s-upr-uses-135 struktura-upravlenie-shag135 KRASEN
STAB s-vyrazhenie-vne-alfavita struktura-vyrazhenija KRASEN
SVJAZI 52
zhivykh 0
```

Генератор атак `python3 /tmp/dev-harness-verify/Critic141b/attack_controls.py` → rc 0, сырой вывод (пять сохранённых свидетелей; из них выполнялись только первые два):
```text
step-if-false: /tmp/dev-harness-verify/Critic141b/attack-step-if-false/.github/workflows/mobile.yml; step135-run-unchanged=True; job-continue-on-error=None; job-if=None; step135-keys=['if', 'name', 'run', 'working-directory']; step135-working-directory='${{ github.workspace }}'
job-continue-expression: /tmp/dev-harness-verify/Critic141b/attack-job-continue-expression/.github/workflows/mobile.yml; step135-run-unchanged=True; job-continue-on-error='${{ true }}'; job-if=None; step135-keys=['name', 'run', 'working-directory']; step135-working-directory='${{ github.workspace }}'
step-working-dir: /tmp/dev-harness-verify/Critic141b/attack-step-working-dir/.github/workflows/mobile.yml; step135-run-unchanged=True; job-continue-on-error=None; job-if=None; step135-keys=['name', 'run', 'working-directory']; step135-working-directory='/tmp'
job-if-false: /tmp/dev-harness-verify/Critic141b/attack-job-if-false/.github/workflows/mobile.yml; step135-run-unchanged=True; job-continue-on-error=None; job-if='${{ false }}'; step135-keys=['name', 'run', 'working-directory']; step135-working-directory='${{ github.workspace }}'
step-uses: /tmp/dev-harness-verify/Critic141b/attack-step-uses/.github/workflows/mobile.yml; step135-run-unchanged=True; job-continue-on-error=None; job-if=None; step135-keys=['name', 'run', 'uses', 'working-directory']; step135-working-directory='${{ github.workspace }}'
```

`env -i PATH=/usr/bin:/bin W --repo /tmp/dev-harness-verify/Critic141b/attack-step-if-false` → rc 1; сырой вывод:
```text
CASE 135-oflin-povtor-spas ok
CASE 135-adb-notfound ok
CASE 135-serial-notfound ok
CASE 135-devserverdied-povtor-krasen ok
CASE 135-chistyj-proval ok
CASE 135-zelenyj ok
CASE 135-boot-ne-zagruzilsja ok
CASE 135-stabil-nedostizhima ok
CASE 135-emulator-log-hvost ok
CASE 135-install-failed-bez-povtora ok
CASE 135-pustoj-maestro-out ok
CASE 118-oflin-povtor-spas ok
CASE 118-devserverdied-povtor-spas ok
CASE 118-povtor-tozhe-krasen ok
CASE 118-chistyj-proval ok
CASE 118-zelenyj ok
CASE 118-boot-ne-zagruzilsja ok
CASE 118-stabil-nedostizhima ok
CASE 118-emulator-log-hvost ok
CASE 995-diag-signatura ok
CASE 995-chistyj-proval ok
CASE 995-zelenyj ok
CASE struktura-shag135 ok
CASE struktura-shag118 ok
CASE struktura-shag995 ok
CASE struktura-pereformat135 ok
CASE struktura-pereformat118 ok
CASE struktura-pereformat995 ok
CASE struktura-signatura135 ok
CASE struktura-signatura118 ok
CASE struktura-signatura995 ok
CASE struktura-vyrazhenija ok
CASE struktura-upravlenie-shag135 KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: shag 135: лишние ключи: if)
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-shag-net ok
```

`env -i PATH=/usr/bin:/bin W --repo /tmp/dev-harness-verify/Critic141b/attack-job-continue-expression` → rc 0; сырой вывод:
```text
CASE 135-oflin-povtor-spas ok
CASE 135-adb-notfound ok
CASE 135-serial-notfound ok
CASE 135-devserverdied-povtor-krasen ok
CASE 135-chistyj-proval ok
CASE 135-zelenyj ok
CASE 135-boot-ne-zagruzilsja ok
CASE 135-stabil-nedostizhima ok
CASE 135-emulator-log-hvost ok
CASE 135-install-failed-bez-povtora ok
CASE 135-pustoj-maestro-out ok
CASE 118-oflin-povtor-spas ok
CASE 118-devserverdied-povtor-spas ok
CASE 118-povtor-tozhe-krasen ok
CASE 118-chistyj-proval ok
CASE 118-zelenyj ok
CASE 118-boot-ne-zagruzilsja ok
CASE 118-stabil-nedostizhima ok
CASE 118-emulator-log-hvost ok
CASE 995-diag-signatura ok
CASE 995-chistyj-proval ok
CASE 995-zelenyj ok
CASE struktura-shag135 ok
CASE struktura-shag118 ok
CASE struktura-shag995 ok
CASE struktura-pereformat135 ok
CASE struktura-pereformat118 ok
CASE struktura-pereformat995 ok
CASE struktura-signatura135 ok
CASE struktura-signatura118 ok
CASE struktura-signatura995 ok
CASE struktura-vyrazhenija ok
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-shag-net ok
```

СОВЕТ: нет. После установленного блокера не проводил порчу модели/носителя, `pre_critic`, precision gate, `check_ceilings`, `check_provodka`, тест соседей, а также прогон ещё трёх сохранённых мутаций; результатов им не приписываю. `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` в контракте — объявленные черновики, утверждения «слово владельца батч №4» в контракте нет (grep без совпадений по этой фразе).
