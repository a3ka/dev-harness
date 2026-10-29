FAIL
OBJECT=15e298206088015c7d039dc38b7754c35465f241
СУД: repo=Complior-mob+dev-harness; предмет=143; фаза=реализация (cutover); роль=adversary; вызов=1/2; сессия=Adv143; модель-факт=openai-codex/gpt-5.6-terra; автор=implementer (MiniMax); контракт/батарея=architect (GLM); независимость=другое семейство.

БЛОКИРУЕТ — build-apk может собрать и проверить не OBJECT

Обязательство 143: единая задача `build-apk` должна собрать release APK проверяемого PR, а выбранные экранные jobs должны проверить именно этот APK; required `android-e2e` не может стать зелёным для непроверенного изменения экрана. Это следует из И-4 («одна сборка на прогон», `github.sha` в identity), И-5 и из source-canon прежнего `android-e2e`, где checkout продукта предшествовал build-step.

Класс причины: правильный ответ не на тот вопрос / нейтрализация source provenance. Digest, artifact name, run_id и все последующие E2E честно согласованы, но они удостоверяют APK из остаточного workspace, не APK `${{ github.sha }}`.

Достижимое состояние: `build-apk` назначается на self-hosted runner, чей workspace содержит checkout более старой ревизии. Jobs Actions независимы; `needs: quality` задаёт порядок, но не переносит его checkout и не закрепляет build за тем же runner. У `build-apk` нет `actions/checkout` вообще: после `needs: quality` он начинает с isolation/version/node/npm/prebuild. Поэтому он способен собрать старое дерево, затем все workers скачивают тот же старый APK по корректному digest, запускают тесты старого APK и публикуют совпадающие outputs. `android-e2e` получает все `needs.result=success` и возвращает `AGREGAT_OK`.

Воспроизведение на копии/наблюдение:

```text
$ git clone -q --no-checkout mob stub-build-without-checkout && git -C stub-build-without-checkout checkout -q 15e298206088015c7d039dc38b7754c35465f241 && TMPDIR=/tmp/dev-harness-verify/Adv143/tmp bash h/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Adv143/stub-build-without-checkout
клеток 69, зелёных 69, красных 0
rc=0
```

Это именно обманная заглушка «build без checkout», уже присутствующая в OBJECT, а не гипотетическая правка. Статический срез OBJECT подтверждает отсутствие checkout между `build-apk:` (строка 386) и первым `npm ci` (строка 406); все остальные jobs и оба aggregating jobs checkout имеют. В `probe.py` `sud_apk` проверяет outputs/identity и worker digest, а `y19` требует checkout только у `android-e2e` и `mobile-regression-signal`; обязательства checkout продукта перед build нет. Поэтому батарея объявляет такой субъект зелёным.

Закрывающее свойство: первым шагом `build-apk` обязателен `actions/checkout@v7` проверяемого workflow ref с `persist-credentials: false` и `clean: true`, до любого source-consuming шага (`test "$(git rev-parse HEAD)" = "$GITHUB_SHA"` — допустимая runtime-проверка). Красная батарея должна иметь отдельную нейтрализацию: удаление либо перенос этого checkout после `npm ci`/prebuild красит именованно; честный workflow с checkout на OBJECT зелёный. Проверка должна судить source provenance build, не только digest provenance уже построенного artifact.

СОВЕТ

`select-ci-screens` локально воспроизвёл PR #136 через git diff (`base=ed852eec076491341d5e041be8585291281eea3a`, `head=OBJECT`): `VYBOROK 5 iz 5`; все пять jobs selected с `COMMON_CHANGE`. Это соответствует ожидаемой консервативной выборке для изменения workflow/map/selector/aggregate.

Токен fallback селектора не подтверждался живым runner-исполнением. Локальный путь git был доступен; при недоступной базе fallback обязан fail-closed с `NET_BAZY`, а не давать success с пустой выборкой. Это не блокирующая находка по OBJECT.

Позитивный контроль и прогоны проверки

```text
$ mkdir -p /tmp/dev-harness-verify/Adv143/tmp && TMPDIR=/tmp/dev-harness-verify/Adv143/tmp bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Adv143/mob
клеток 69, зелёных 69, красных 0
rc=0

$ mkdir -p /tmp/dev-harness-verify/Adv143/tmp && TMPDIR=/tmp/dev-harness-verify/Adv143/tmp bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs
клеток 69, зелёных 69, красных 0
стабов 33, привязок 49, непойманных 0
rc=0
```

Матрица стаба проверила 33 мутации/49 связей: отказ как успех, пустой вход, зашитая константа/белый список, инструмент в замкнутом PATH и неверный источник digest/needs, а также нейтрализации aggregator/worker/cron/cancel/digest/needs. Новая атака выше находится вне этой карты: provenance исходников `build-apk` не проверяется.

Parity и scope

```text
$ git -C mob cat-file -t 15e298206088015c7d039dc38b7754c35465f241
commit
rc=0

$ [cross-repository hash-object OBJECT vs f7e95185:fixtures/workshop_project/mob_ci_143/model/<path>]
.github/workflows/mobile.yml  9ee1f83a2ccc7618767307b4c3998c7dcc7ce4e3 = 9ee1f83a2ccc7618767307b4c3998c7dcc7ce4e3
mobile/ci-screens.json        2addeb7fcaa14490046c208b14ada3c491bae456 = 2addeb7fcaa14490046c208b14ada3c491bae456
mobile/scripts/select-ci-screens.cjs b0f7a4d39cf9a3170f561406f1b96a9da53de659 = b0f7a4d39cf9a3170f561406f1b96a9da53de659
mobile/scripts/ci-aggregate.cjs c7b5f6900060970098ec1e54ab76252ae99830dd = c7b5f6900060970098ec1e54ab76252ae99830dd
rc=0

$ git diff --name-only ed852eec076491341d5e041be8585291281eea3a 15e298206088015c7d039dc38b7754c35465f241
.github/workflows/mobile-e2e-retry.yml
.github/workflows/mobile.yml
mobile/ci-screens.json
mobile/scripts/ci-aggregate.cjs
mobile/scripts/select-ci-screens.cjs
mobile/structure-policy.json
rc=0

$ git cat-file -e OBJECT:.github/workflows/mobile-e2e-retry.yml
fatal: path '.github/workflows/mobile-e2e-retry.yml' does not exist in OBJECT
rc=128
```

`mobile/structure-policy.json` changes only by adding `ci-screens.json` to `mobileFiles`.

ЗАПРОС ЖИВОЙ ПРОБЫ

Оркестратору: на disposable PR-ветке от OBJECT добавьте в `build-apk.steps` ПЕРЕД `Изоляция раннера` только:

```yaml
      - name: Assert build source is workflow SHA
        working-directory: ${{ github.workspace }}
        run: test "$(git rev-parse HEAD)" = "${{ github.sha }}"
```

Запустите один PR-run на каждом из двух self-hosted slots, без иных изменений. Ожидание для OBJECT: job обязан быть красным либо доказать случайный остаточный HEAD; сам diff намеренно не чинит отсутствие checkout. Для закрывающей версии повторите на двух slots после добавления checkout и этой проверки: оба должны быть зелёными.

НЕ ПРОВЕРЕНО

Не запрашивались/не запускались `gh run`, GitHub API/logs, push, commit либо эмуляторы: это запрещено назначением; живое выполнение screen jobs и branch-protection остаются за оркестратором. Живой факт задания о run 40676683209 не доказывает provenance рабочего дерева `build-apk`.
