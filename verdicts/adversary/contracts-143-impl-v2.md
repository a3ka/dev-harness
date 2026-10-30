accept
OBJECT=2279c4a8c8078d12910a5d2bf2ac6ee2dc2e8114
СУД: repo=Complior-mob+dev-harness; предмет=143; фаза=реализация (cutover), scoped-повтор после Adv143; роль=adversary; вызов=2/2; сессия=Adv143b; модель-факт=openai-codex/gpt-5.6-terra; автор=implementer (MiniMax); контракт/батарея=architect (GLM); независимость=другое семейство.

БЛОКЕРЫ: нет.

## Предмет и parity

`git -C /tmp/dev-harness-verify/Adv143b/mob cat-file -t 2279c4a8c8078d12910a5d2bf2ac6ee2dc2e8114` → `commit`, rc=0; checkout этого OBJECT выполнен.

Сверка четырёх судимых файлов с моделью Fix143c:

```text
$ sha256sum <product/{mobile.yml,ci-screens.json,select-ci-screens.cjs,ci-aggregate.cjs}> <model/{mobile.yml,ci-screens.json,select-ci-screens.cjs,ci-aggregate.cjs}>
868b30e1a1accbacddea9a9ade6e97b7bafd58e83cb8160bba610ebd4ecf8c41  product/.github/workflows/mobile.yml
… e11d15196440489589a7ff837d1d50b9adce7f7cadc884238b558cc6f4f768b0  product/mobile/ci-screens.json
… 4bf826ac8eb397f1c7b2699f7b7d161f0e92074127b25c05f20991bb9f5d391a  product/mobile/scripts/select-ci-screens.cjs
… 83118c9297a9b2678e28b73fb4e8ffd772f39bf6f41426c2d07fe9d8199fede1  product/mobile/scripts/ci-aggregate.cjs
# четыре соответствующие model-файла дали те же четыре sha256 в том же порядке
rc=0
```

## Обязательный визуальный суд provenance в РЕАЛЬНОМ `build-apk`

`mobile.yml:396–413` содержит именно: шаг 0 `actions/checkout@v7` c единственными `with: {persist-credentials: false, clean: true}`, затем шаг 1 `test "$(git rev-parse HEAD)" = "$GITHUB_SHA"`. До него нет source-consuming шага. После него до конца `build-apk` нет второго checkout, `continue-on-error`, маскирующего `if:false`, `|| true`, самосравнения, `git fetch/checkout/reset/switch`, загрузки APK или `cp`/`curl`/`wget`/`gh run download`, которые подменяли бы исходники либо артефакт до сборки. Единственный `if: always()` — публикация уже построенного APK; он не маскирует source assert.

Машинная повторная проверка этого прочтения по YAML (не по комментариям):

```text
$ python3 /tmp/dev-harness-verify/Adv143b/audit_build.py mob/.github/workflows/mobile.yml
BUILD_AUDIT_OK: checkout[0], HEAD==GITHUB_SHA[1], no masking/second checkout/git/source-artifact substitution
rc=0

$ python3 …/audit_build.py mut-source-copy/.github/workflows/mobile.yml
BUILD_AUDIT_FAIL: source/artifact substitution 'cp ' at 2
rc=1

$ python3 …/audit_build.py mut-no-checkout/.github/workflows/mobile.yml
BUILD_AUDIT_FAIL: step0 is not checkout@v7; step0 options=None; source-check run='test ! -e /home/harness/.ssh && test ! -e /home/harness/dev-harness'; source-check is self-comparison
rc=1
```

Последние две строки — положительный контроль самого аудита; рабочее дерево OBJECT не менялось. Мутант `cp /tmp/foreign-ci-screens.json mobile/ci-screens.json` после assert даёт 69/69 у батареи: это известный остаток статической батареи, прямо оставленный Arb143r п.5. По правилу владельца он не блокирует: в реальном `build-apk` такого достижимого шага нет (проверено выше).

## Один APK, permissions и fail-closed

У пяти screen jobs `needs: [select-screens, build-apk]`, job-level `permissions: {contents: read, actions: read}`; workflow-default — минимальный `{contents: read}`. `android-e2e` имеет все восемь нужных predecessor jobs, `if: always()` на PR/push/merge_group и запускает `ci-aggregate.cjs` на `toJSON(needs)` после checkout. Реальный ruleset `25121366`, enforcement=active, требует контексты `quality` и `android-e2e`, strict=true, bypass_actors=[]; branch-protection endpoint дал 404 именно потому, что защита задана ruleset-ом, не старым branch-protection API.

Независимые атаки на одноразовых клонах продукта (`W --repo`):

```text
# прежний блок Adv143: удалён только первый checkout build-apk
$ W --repo mut-no-checkout
клеток 69, зелёных 68, красных 1
КЛЕТКА y19-outputs-provodka: build-apk: сборка без checkout продукта первым шагом … КРАСНА
rc=1

# имя artifact подменено вычислением из run_attempt вместо output build-apk
$ W --repo mut-artifact-attempt
клеток 69, зелёных 68, красных 1
КЛЕТКА y11-apk-identichnost: e2e-splash не берёт артефакт по имени из outputs сборки КРАСНА
rc=1

# ci-screens.json заменён пустой картой
$ W --repo mut-map-empty
клеток 69, зелёных 67, красных 2
КЛЕТКА f01-fiksirovannyj-nabor-P: P-набор [] КРАСНА
КЛЕТКА p01-P-nabor: Maestro не вызван ни разу … КРАСНА
rc=1

# select-ci-screens: тихий пустой success вместо EMPTY_SELECTION_FALLBACK
$ W --repo mut-selector-empty
клеток 69, зелёных 68, красных 1
КЛЕТКА s21-doksi-fallback: full_set=False, канон True КРАСНА
rc=1

# ci-aggregate: немедленный AGREGAT_OK/exit 0
$ W --repo mut-aggregate-echo
клеток 69, зелёных 54, красных 15
КЛЕТКИ a01,a02,a03,a04,a05,a06,a07,a08,a09,a10,a11,a12,a13,a15,a16: rc=0, канон rc=1 … КРАСНА
rc=1
```

Нейтрализация ловится адресно: отсутствующий checkout красит y19, чужой artifact-name — y11, тихий selector — s21, а выключенный агрегатор — ровно его 15 A-сценариев. Это также покрывает отказ как успех, пустой вход/пустую карту, правильный ответ не на тот input и константный успех.

Отдельная живая проба fail-closed селектора:

```text
$ node mobile/scripts/select-ci-screens.cjs --mode push --base-sha 0000000000000000000000000000000000000000 --head-sha OBJECT --repo . --out /tmp/dev-harness-verify/Adv143b/no-base-selection.json
VYBOR_OTKAZ: NET_BAZY: git
rc=1
```

## Позитивные контроли и полная матрица

```text
$ TMPDIR=/tmp/dev-harness-verify/Adv143b/tmp W --repo /tmp/dev-harness-verify/Adv143b/mob
клеток 69, зелёных 69, красных 0
rc=0

$ TMPDIR=/tmp/dev-harness-verify/Adv143b/tmp W --model
клеток 69, зелёных 69, красных 0
rc=0

$ TMPDIR=/tmp/dev-harness-verify/Adv143b/tmp W --stabs
клеток 69, зелёных 69, красных 0
стабов 43, привязок 59, непойманных 0
rc=0
```

Матрица прошла в том числе нейтрализации source provenance: `|| true`, удалённая/поздняя сверка, неверный `$GITHUB_REF`, `if:false`, `continue-on-error`, чужой ref/path, второй checkout и `git fetch && git checkout`; а также отсутствие/глубина checkout, artifact `run_attempt`, пустой needs, missing PATH-инструмент и fail-closed aggregate.

## Живой CI

`gh api repos/a3ka/Complior-mob/actions/runs/40961808157` → `head_branch=cmp-mob-143/cutover`, `head_sha=OBJECT`, `event=pull_request`, `conclusion=success`, rc=0. Jobs API для attempt 2 показал success у `select-screens`, `quality`, `build-apk`, пяти `e2e-*` и `android-e2e`; `mobile-regression-signal` skipped по своему schedule/dispatch condition.

Лог build job `123762833836`, полученный требуемым endpoint `gh api repos/a3ka/Complior-mob/actions/jobs/123762833836/logs`, даёт:

```text
Run actions/checkout@v7
  persist-credentials: false
  clean: true
HEAD is now at 8595adb… Merge 2279c4a8c8078d12910a5d2bf2ac6ee2dc2e8114 into 1a99902a…
Run test "$(git rev-parse HEAD)" = "$GITHUB_SHA"
# step «Сборка из проверяемой ревизии (HEAD == GITHUB_SHA)»: conclusion=success
```

Следовательно `test` реально исполнился и был зелёным на merge SHA PR, который лог прямо связывает с OBJECT; это не просто наличие строки в YAML.

## СОВЕТ

Нет.

## НЕ ПРОВЕРЕНО

Не запускались новый Android build/эмуляторы и не создавался PR с намеренным `cp`-мутантом: это не нужно для scoped-повтора, а живой run уже предъявлен. Лог assert не печатает оба операнда, поэтому равенство подтверждено успешным rc шага и checkout-log, а не отдельным echo SHA. Проверялась заданная ветка OBJECT и run attempt 2; первый флаковый запуск эмулятора не воспроизводился.
