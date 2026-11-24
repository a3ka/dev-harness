accept
OBJECT=180352174bc136f35e3f57bc780e1d4eaa610d84
СУД: repo=dev-harness; предмет=143; фаза=контракт v5 до заморозки; роль=critic; вызов=один узкий по слову владельца, батч 3 №2, без нового полного бюджета; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit143V5b; модель-факт=openai-codex/gpt-6.1-terra (models_actual.sh --tsv --bind --session Crit143V5b: critic, allowed); SHA=180352174bc136f35e3f57bc780e1d4eaa610d84; предыдущий=Crit143V5 FAIL, OBJECT 0d391630a037d3c3e71d0795866dddba55f1fc57; исключение=слово владельца, только К-03/К-05 и зависимый регресс.

## Решение

Класс К-03/К-05 закрыт в заданной границе. `contracts/143-mob-ci-razdelenie.md:370,387` теперь согласуют приёмку с 197/3: до используется отдельно разрешённый владельцем baseline, после — явно выбранная v5; обещание 197 и повтор после фактического freeze сохранены. `git diff HEAD^ HEAD -- fixtures/workshop_project/mob_ci_artifacts_local_197/ contracts/197-mob-ci-artefakty-lokalno.md` rc 0, пусто; дерево семьи 197 на HEAD и frozen/197/3 одинаково (`f19700f98d505e8c31e551b03306b08111b62858`). Два предметных пути 143 совпадают с `origin/wip/int-2060/architect` (git diff rc 0, пусто). Разрешение в теле коммита интеграционной ветки начинается в первой колонке с `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/143-mob-ci-razdelenie.md` и непустой причиной; соответствует `scripts/check_charter.sh:23-36` и не расширяет названное разрешение на 143 v+1. Санкция baseline дана словом владельца, зафиксированным в `contracts/197-mob-ci-artefakty-lokalno.md:26`; frozen/143/4 с четырьмя красными не выдан за базу шести.

## Измерения

Все команды из `/tmp/dev-harness-verify/Crit143V5b/repo`, продуктовый клон использован только для чтения через `git archive` и `git show` механизмом 197.

- `bash fixtures/workshop_project/mob_ci_artifacts_local_197/sverka_inventarja_143.sh до` — rc 0; commit `9d3ad2bea4f1f15be15a9d975966bb20451a9a54`, tree `89ccddf8281b15842eda6aa1a316bdde579845ee`; 197 29/29; точные красные дочерней 143:
  - `a17-digest-do-ustanovki: e2e-splash: РЕНДЕР_ВНЕ_АЛФАВИТА: needs.build-apk.outputs.run_attempt`
  - `evidence: CHILD_DOWNLOAD_ABSENT_android-e2e`
  - `legacy: LEGACY_JOB_CHANGED`
  - `workflow-build-apk-outputs: WORKFLOW_CONTROL_workflow-build-apk-outputs`
  - `workflow-build-apk-run-step-7: WORKFLOW_CONTROL_workflow-build-apk-run-step-7`
  - `y19-outputs-provodka: outputs build-apk: ['apk_sha256', 'artifact_name', 'run_attempt', 'run_id']`
- `bash fixtures/workshop_project/mob_ci_artifacts_local_197/sverka_inventarja_143.sh после --ref 180352174bc136f35e3f57bc780e1d4eaa610d84` — rc 0; tree `502e88a552fbe07f1a45be7eec4dc90d29cced58`, 197 29/29, ноль красных 143. В обоих режимах снимок агрегата совпал с оригиналом, sha256 `e486e353f319ed2c0a65fc1092a0f16f8c9d8314bab4aed6e1d3619630d8fec6`.
- `bash fixtures/workshop_project/mob_ci_artifacts_local_197/proverka_sverki_143.sh --ref 180352174bc136f35e3f57bc780e1d4eaa610d84` — rc 0, 12/12: оба честных пути `--ref` и `--dir`, старая версия с rc 1, отсутствующие источник/commit и неверный tree с rc 2, три отрицательных контроля субъекта с rc 1.
- `bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --model` — rc 0, matrix 397/397 и lane 5/5, legacy 80/80 и lane 79/79.
- `bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs` — rc 0, matrix 413 стабов/422 привязки/0 живых; legacy 66/82/0 непойманных. Привязки судятся по коду, не прозой (Н-39).
- `bash scripts/check_sdacha.sh . contracts/143-mob-ci-razdelenie.md --run` — rc 0, `СДАЧА: лист зелёный (двери=5 карта=17/17 дельта=2)`.
- `bash scripts/pre_critic.sh --repo . contracts/143-mob-ci-razdelenie.md` — rc 0, `КРИТИК: дверь зелёная`.

## Карта классов

К-01: чисто — `check_sdacha.sh . contracts/143-mob-ci-razdelenie.md --run`, `pre_critic.sh --repo . contracts/143-mob-ci-razdelenie.md`, rc 0.
К-02: н/п — новый поиск источников вне узкого слова владельца.
К-03: чисто — `sverka_inventarja_143.sh до`, `после --ref` и `proverka_sverki_143.sh --ref`, rc 0; дерево 197 равно frozen/197/3.
К-04: чисто — вход: git diff HEAD^ HEAD: чужая зона 197 не затронута.
К-05: чисто — команды пункта 1 приёмки `contracts/143-mob-ci-razdelenie.md:370`, обе формы после проверены `proverka_sverki_143.sh`, rc 0.
К-06: чисто — `proverka_sverki_143.sh --ref`, rc 0: негативные предпосылки дают rc 2.
К-07: чисто — `sverka_inventarja_143.sh до` и `после --ref`, rc 0 на архиве реального fda1fc8 плюс модель 197.
К-08: чисто — `red_mob_ci_143.sh --stabs`, rc 0; `proverka_sverki_143.sh --ref`, rc 0.
К-09: н/п — новые классы входов вне разрешённого блока.
К-10: чисто — `proverka_sverki_143.sh --ref`, rc 0: сверяется поимённый состав и наблюдаемые rc обоих состояний.
К-11: чисто — вход: `sverka_inventarja_143.sh` читает пин и сравнивает снимок агрегата с `git show` продукта до батарей.
К-12: н/п — новый суд оракулов формата вне разрешённого блока.
К-13: н/п — секреты не предмет стыка и зависимого регресса.
К-14: чисто — `proverka_sverki_143.sh --ref`, rc 0: честные `--ref` и эквивалентный `--dir` зелёны.
К-15: чисто — `red_mob_ci_143.sh --model`, `--stabs`, `proverka_sverki_143.sh --ref`, rc 0: счёт приведён выше.
К-16: н/п — новая оценка границы угроз вне узкого слова; класс риска сохранён в `contracts/143-mob-ci-razdelenie.md:350`.
К-17: н/п — модель архитектуры и продуктовый код данной markdown-правкой стыка не меняются.
