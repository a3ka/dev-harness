FAIL
OBJECT=e26ba282f829364cd5af6f37e65012da86be912c

# Суд реализации контракта 111 (mob First-Run D2.2.5.1) — reviewer Rev111r2, круг 2 (scoped)

Контракт: `frozen/contracts/111/1`. Батарея H = `18763ef30cf7e8c4dc36a5c09291906d54913534`
(`git archive … fixtures/workshop_project` → `/tmp/dev-harness-verify/Rev111r2/H`). База B = `16eb708a`.
Цепочка объекта: cec116cd → cd4f52e4 → e26ba282 (автор `implementer`, клон не запушен).
Все прогоны — на `cp -a`-копиях клона в `/tmp/dev-harness-verify/Rev111r2/{C,M1,M2,R995,APK}`.
Находки reslop: `review.md` (та же папка).

Итог: A1/Б1 и A2 закрыты, это измерено, в том числе на устройстве. Регресса по батарее, 995/999/108,
lint/typecheck/test нет. **Блокирует одна новая находка Р1**: правка A2 переместила Demo-бейдж
в область статус-бара. Её внёс диф круга 2, на устройстве это измерено, батарея её не видит.

## Таблица

| # | Предмет | Замер своей мерой | Итог |
|---|---------|-------------------|------|
| A1/Б1 | wordmark — растр `logo/assets/complior-wordmark-dark.svg`, декодируемый | Свой прогон команды растеризации из тела cd4f52e4 (Chrome headless, `--force-device-scale-factor=3 --window-size=143,52`) на `C/docs/…/complior-wordmark-dark.svg` (sha256 `e0f2ef4f…e4bf`) дал файл sha256 `fcb1a2f8…589e`, **байт-в-байт равный** `mobile/assets/images/wordmark-dark.png`. Pillow: RGBA 429×156, ratio 2.7500; alpha≠0 у 14090 из 66924 px; цвета: прозрачный (52834) и `#f2f1ec` (11620) — ink канона; глифы «complior» видны глазом. `assembleRelease` (aapt2 crunch) rc0, на эмуляторе wordmark отрисован (ImageView 159×58 px = 60.6×22.1 dp). Клетки WORDMARK_ASSET и WORDMARK_ASSET_DECODES зелёные | **ЗАКРЫТО** |
| A2 | First-Run без рамки, вся поверхность на ground | pilot-app: на кадре first-run root = `[rootFirstRun, {backgroundColor: tokens.ground}]` без отступов, остальные кадры 995 на прежнем `styles.root`. FIRST_RUN_GROUND_FULL_SURFACE_{DARK,LIGHT} зелёные; стабы wrapper-root-{white,magenta,padding} красят ровно эту пару. Устройство (release-APK, эмулятор API 36, 1080×2400): `#0A0A0A` во весь экран, белой рамки нет (`first-run-device.png`) | **ЗАКРЫТО** |
| Р1 | регресс от A2: Demo-бейдж ушёл в область статус-бара | uiautomator: `demo-indicator` bounds `[0,0][137,64]`, а инсет statusBars `frame=[0,0][1080,136]`: бейдж целиком внутри инсета и перекрывает системные часы (см. скриншот). `first-run-safe-area` начинается с `[0,96]`. Батарея 13/13 + 15/15 зелёная | **FAIL (блок, см. ниже)** |
| Регресс | пробы 111 честные | `honest 13/13` rc0 (13 строк `case`), `static 15/15` rc0 (15 строк `case`); `git status` 0 строк | OK |
| Регресс | матрицы | M1 `--matrix`: 17 строк `mutant`, MATRIX_RC=0; M2 `--matrix`: 12 строк `mutant`, SMATRIX_RC=0; `git status` 0 строк в обеих | OK |
| Регресс | 995/999/108 (команды mobile.yml, `.harness` = H) | `cmp` pilot.test.tsx/source.json → CMP_995_OK; probe.py --check-frozen 14 кейсов rc0; 11 проб 995 rc0; 4 пробы 999 rc0; 108 `static 22/22` + `honest 336/336` rc0. Фикстуры 995/999/108 в H 18763ef30 и 98d837eb9 равны (`git diff --stat` пуст) | OK |
| Регресс | lint/typecheck/test | R995/mobile: `Tests: 14 passed` RC_test=0, RC_lint=0, RC_typecheck=0; после всех прогонов `git status` 0 строк | OK |
| Регресс | release-сборка (путь android-e2e) | `expo prebuild` + `gradlew assembleRelease -PreactNativeArchitectures=x86_64` (JDK 17): BUILD SUCCESSFUL, GRADLE_RC=0; APK ставится и стартует | OK (CI `gh pr checks` не наблюдаем: объект не запушен) |
| Область | ЗОНА implementer | `git diff --stat 16eb708a e26ba282`: ровно 6 файлов, все в ЗОНЕ; диф круга 2 (cec116cd..e26ba282) — 4 файла из ЗОНЫ. `git diff -I '^\s*#'` mobile.yml B..HEAD: только два `ref:` и новый шаг 111; name/run шагов 995/999/108 дословно | OK |
| Сырой вывод | — | ниже, отдельным блоком; отчёт автора доказательством не служил | OK |
| Атомарность | — | 3 коммита, у каждого автор `implementer` и ссылка «111»: исходный, починка круга 1, перепин H | OK |
| Норма | — | нормативных документов в дифе нет | OK |

## Советы круга 1 (С1–С6), состояние

| Совет | Состояние |
|---|---|
| С1 (реализация списана с модели) | **закрыт**. Pilot-app круга 2 отличается от модели H: реализация красит ground только на кадре first-run, модель красит все кадры. Ассет сделан автором (cd4f52e4, 12:31), модель H взяла его позже (adaebe4d6, 13:00; sha256 модели = `fcb1a2f8…`) |
| С2 (белая рамка) | **закрыт** → A2 |
| С3 (wordmark-dark в light: ink `#f2f1ec` на `#f3f2ee`) | **открыт**, это вопрос редакции контракта (инв. 6/К4 требуют dark-ассет в обеих схемах). В продукте ThemeContext по умолчанию dark, провайдера над PilotApp нет. Не блокирует |
| С4 (батарея проверяла только магию) | **закрыт** architect: WORDMARK_ASSET_DECODES и 3 стаба (1x1, broken-stub-82, solid-rectangle) |
| С5 (aspectRatio wordmark) | **закрыт**: `aspectRatio: 143 / 52.08`; на устройстве 159×58 px |
| С6 (надгробный комментарий; пин в комментарии шага 108) | **закрыт**: надгробие убрано, пин в комментарии обновлён. Новое устаревание вынесено в С7 |

## Блокирующая находка

### Р1 — Demo-бейдж на First-Run целиком в инсете статус-бара (регресс от правки A2; инв. 7, предмет «safe-area настоящим компонентом», визуальная сверка с First-Run.png за reviewer)

- Фрагмент: `mobile/src/bootstrap/pilot-app.tsx`, на кадре first-run root = `styles.rootFirstRun` (`paddingTop: 0`,
  `paddingHorizontal: 0`). Бейдж `demo-indicator` — первый ребёнок root, и он ВНЕ `SafeAreaView` экрана.
  В cec116cd его сверху сдвигал `paddingTop: 48`. Круг 2 убрал отступ и не поставил вместо него safe-area-отступ,
  поэтому бейдж ушёл в (0,0).
- Наблюдение (release-APK объекта, эмулятор `complior_api36`, 1080×2400, 420 dpi): `demo-indicator` `[0,0][137,64]`,
  текст «Demo» `[26,10][110,53]`, statusBars `frame=[0,0][1080,136]`. Бейдж лежит в системной зоне целиком
  и закрывает часы статус-бара (`first-run-device.png`). Обязательство инв. 7 — «Demo-бейдж виден на First-Run»,
  метка mock composition. Предмет называет safe-area частью First-Run. Эталон First-Run.png — контент под
  статус-баром. [INFERENCE] На iOS с вырезом левый верхний угол (0,0) — зона часов и скругления, перекрытие то же.
- **ОБХОД**: FIRST_RUN_STRUCTURE_{DARK,LIGHT} проверяют только наличие бейджа (testID и текст), но не его место.
  FIRST_RUN_GROUND_FULL_SURFACE_* требует root без отступов. В Jest вёрстки нет, поэтому продукт с бейджем под
  системными часами даёт 13/13 + 15/15.
- **Воспроизведение**: `bash /tmp/dev-harness-verify/Rev111r2/shot.sh` (после `expo prebuild` и
  `gradlew assembleRelease -PreactNativeArchitectures=x86_64` на копии APK). Дамп `first-run-ui.xml` и
  `python3 ui_bounds.py` печатают bounds выше, `dumpsys window` — инсет statusBars 136 px.
- Более простая форма, проходящая те же строки [INFERENCE, контрольный прогон не делался]: root не трогать
  (К6 остаётся зелёной), а бейджу на кадре first-run дать отступ safe-area. Например, `useSafeAreaInsets().top`
  в marginTop, либо обёртка `SafeAreaView edges={['top','left','right']}` вокруг бейджа. Шов экрана и
  структура 995 при этом не меняются.

## Советы (не блокируют)

- **С7**: в комментариях mobile.yml у шага 111 (строки 122–127) и у android-e2e (строка 169) числа батареи
  прежние: «14/14», «11/11», «матрица 9+14». На пине 18763ef30 фактически 15/15, 13/13, 12+17 (замер выше).
  Заголовок коммита e26ba282 называет верные числа, комментарий в файле — нет.
- **С8 (визуал, владельцу/architect)**: без root-отступа wordmark `[0,285][159,343]` и CTA `[0,678][687,798]`
  прижаты к левому краю экрана (x=0). В First-Run.png wordmark по центру сверху, а CTA — блок на всю ширину
  с полями 16 и внизу. Замороженного обязательства на раскладку нет, поэтому не FAIL. При починке Р1 стоит
  заодно вернуть экрану горизонтальные поля внутри `first-run-screen.tsx`.
- **С9 (050, ACCIDENTAL-совет)**: в `styles.rootFirstRun` записаны `backgroundColor: '#FFFFFF'` и три нулевых
  отступа. Цвет всегда перекрывается `{ backgroundColor: tokens.ground }` и мёртв. Нули повторяют поведение
  по умолчанию. Форма `{ flex: 1 }` проходит К6 (отступы `undefined` допустимы).

## Контракт 050 — паразитная сложность (артефакты дифа круга 2)

| Артефакт | (1) свойство | (2) состояние | (3) сопряжённые правки | (4) глубина | (5) потребитель | Класс |
|---|---|---|---|---|---|---|
| `wordmark-dark.png` (растр 429×156) | инв. 6 | файл; команда растеризации в теле коммита | 1 | — | WORDMARK_ASSET(_DECODES), К4, release-сборка | ESSENTIAL |
| `styles.rootFirstRun` + ветка `frame === 'first-run'` в root | инв. 8 / К6 | нет (стиль от `frame`) | 1 | ветка из 2 исходов | К6 ×2 | ESSENTIAL по ветке; лишние литералы — С9 |
| `useTheme()` в PilotApp | инв. 8 (ground схемы на root) | читает существующий ThemeContext | 1 | — | К6 ×2 | ESSENTIAL |
| `aspectRatio: 143 / 52.08` | совет С5 / инв. 6 «высота по эталону» | нет | 1 | — | визуал | ESSENTIAL |
| перепин `ref:` ×2 на 18763ef30 | «Пины и порядок поставки» | пин явно в mobile.yml | 2 строки, как в прецеденте | — | шаг quality 111, android-e2e | ESSENTIAL |

Новых функций, флагов и env-переменных нет.

---

## Сырой вывод (отдельно от диагноза)

```
$ git -C …/Impl111/mob rev-parse HEAD
e26ba282f829364cd5af6f37e65012da86be912c
$ git diff --stat cec116cd e26ba282
 .github/workflows/mobile.yml                  |  16 ++++++++--------
 mobile/assets/images/wordmark-dark.png        | Bin 82 -> 10478 bytes
 mobile/src/bootstrap/pilot-app.tsx            |  23 ++++++++++++++++++++---
 mobile/src/features/auth/first-run-screen.tsx |   7 ++++++-
 4 files changed, 34 insertions(+), 12 deletions(-)
$ git diff --stat 16eb708a e26ba282
 .github/workflows/mobile.yml | 55 ; mobile/app.json | 2 ; wordmark-dark.png | Bin 0 -> 10478 ;
 pilot-app.tsx | 45 ; first-run-screen.tsx | 64 ; ui-copy.ts | 3   — 6 files changed, 127 insertions(+), 42 deletions(-)
$ git diff -U0 -I '^\s*#' 16eb708a e26ba282 -- .github/workflows/mobile.yml
 -ref: 98d837eb9e… / +ref: 18763ef30c…  (×2: quality, android-e2e) ; +шаг «111 first_run_static_probe.py / first_run_probe.py»
$ git -C dev-harness diff --stat 98d837eb9 18763ef30 -- fixtures/…/pilot_995 nav_999 start_108
(пусто)

# C — честные пробы (H 18763ef30)
case CTA_OPENS_F03_01_DARK / CTA_OPENS_F03_01_LIGHT / CTA_TEXT_EQUALS_FRAME_TITLE / FIRST_RUN_COPY_CLOSED_DARK /
case FIRST_RUN_COPY_CLOSED_LIGHT / FIRST_RUN_GROUND_FULL_SURFACE_DARK / FIRST_RUN_GROUND_FULL_SURFACE_LIGHT /
case FIRST_RUN_STRUCTURE_DARK / FIRST_RUN_STRUCTURE_LIGHT / SAFEAREA_EDGES_ACTIVE_DARK / SAFEAREA_EDGES_ACTIVE_LIGHT /
case WORDMARK_SOURCE_BOUND_DARK / WORDMARK_SOURCE_BOUND_LIGHT                                   (13 строк case)
honest 13/13
PROBE_RC=0
case SPLASH_GROUND_DARK / SPLASH_DEFAULT_BLUE_GONE / SPLASH_EFFECTIVE_GROUND_BOTH / COPY_KEY_ui_first_run_promise /
case COPY_KEY_ui_first_run_enter_f03 / SCREEN_SEAM_FIRST_RUN / SCREEN_NO_HEX_LITERALS / SCREEN_SAFEAREA_COMPONENT /
case SCREEN_THEME_TOKENS / CTA_TESTID_BOUND / PILOT_WIRED_FIRST_RUN / LEGACY_WEITER_GONE / WORDMARK_ASSET /
case WORDMARK_ASSET_DECODES / STATIC_ORACLE_LITERALS                                            (15 строк case)
static 15/15
STATIC_RC=0
STATUS_END            (0 строк git status)

# M1 — first_run_probe.py --matrix
mutant cta-label-weiter red= [CTA_TEXT_EQUALS_FRAME_TITLE, FIRST_RUN_COPY_CLOSED_DARK, FIRST_RUN_COPY_CLOSED_LIGHT, FIRST_RUN_STRUCTURE_DARK, FIRST_RUN_STRUCTURE_LIGHT]
mutant promise-invented red= [FIRST_RUN_COPY_CLOSED_DARK, FIRST_RUN_COPY_CLOSED_LIGHT, FIRST_RUN_STRUCTURE_DARK, FIRST_RUN_STRUCTURE_LIGHT]
mutant onenter-not-wired red= [CTA_OPENS_F03_01_DARK, CTA_OPENS_F03_01_LIGHT, CTA_TEXT_EQUALS_FRAME_TITLE]
mutant ground-default-blue red= [FIRST_RUN_STRUCTURE_DARK, FIRST_RUN_STRUCTURE_LIGHT]
mutant demo-badge-scope red= [FIRST_RUN_STRUCTURE_DARK, FIRST_RUN_STRUCTURE_LIGHT]
mutant wordmark-absent red= [FIRST_RUN_STRUCTURE_DARK, FIRST_RUN_STRUCTURE_LIGHT, WORDMARK_SOURCE_BOUND_DARK, WORDMARK_SOURCE_BOUND_LIGHT]
mutant cta-testid-renamed red= [CTA_OPENS_F03_01_DARK, CTA_OPENS_F03_01_LIGHT, CTA_TEXT_EQUALS_FRAME_TITLE, FIRST_RUN_STRUCTURE_DARK, FIRST_RUN_STRUCTURE_LIGHT]
mutant light-cta-noop red= [CTA_OPENS_F03_01_LIGHT]
mutant safearea-edges-empty red= [SAFEAREA_EDGES_ACTIVE_DARK, SAFEAREA_EDGES_ACTIVE_LIGHT]
mutant wordmark-wrong-source red= [WORDMARK_SOURCE_BOUND_DARK, WORDMARK_SOURCE_BOUND_LIGHT]
mutant extra-unreviewed-copy red= [FIRST_RUN_COPY_CLOSED_DARK, FIRST_RUN_COPY_CLOSED_LIGHT]
mutant light-edges-top-bottom red= [SAFEAREA_EDGES_ACTIVE_LIGHT]
mutant light-wrong-source red= [WORDMARK_SOURCE_BOUND_LIGHT]
mutant light-extra-copy red= [FIRST_RUN_COPY_CLOSED_LIGHT]
mutant wrapper-root-white red= [FIRST_RUN_GROUND_FULL_SURFACE_DARK, FIRST_RUN_GROUND_FULL_SURFACE_LIGHT]
mutant wrapper-root-magenta red= [FIRST_RUN_GROUND_FULL_SURFACE_DARK, FIRST_RUN_GROUND_FULL_SURFACE_LIGHT]
mutant wrapper-root-padding red= [FIRST_RUN_GROUND_FULL_SURFACE_DARK, FIRST_RUN_GROUND_FULL_SURFACE_LIGHT]
MATRIX_RC=0                                                                                    (17 строк mutant)
STATUS_END

# M2 — first_run_static_probe.py --matrix
mutant splash-stays-default-blue red= [SPLASH_DEFAULT_BLUE_GONE, SPLASH_EFFECTIVE_GROUND_BOTH, SPLASH_GROUND_DARK]
mutant android-splash-blue red= [SPLASH_EFFECTIVE_GROUND_BOTH]
mutant copy-promise-invented red= [COPY_KEY_ui_first_run_promise]
mutant copy-enter-missing red= [COPY_KEY_ui_first_run_enter_f03]
mutant screen-hex-literal red= [SCREEN_NO_HEX_LITERALS]
mutant pilot-unwired red= [PILOT_WIRED_FIRST_RUN]
mutant wordmark-missing red= [WORDMARK_ASSET, WORDMARK_ASSET_DECODES]
RED WORDMARK_ASSET_DECODES: габариты 1x1 < 200x60; пропорция 1.000 вне ±10% канона 2.746; одноцветный прямоугольник: 1 разных пикселей
mutant wordmark-1x1-png red= [WORDMARK_ASSET_DECODES]
RED WORDMARK_ASSET_DECODES: IHDR_MODE w=8 h=44 depth=8 color=0
mutant wordmark-broken-stub-82 red= [WORDMARK_ASSET_DECODES]
RED WORDMARK_ASSET_DECODES: одноцветный прямоугольник: 1 разных пикселей; нет прозрачных пикселей
mutant wordmark-solid-rectangle red= [WORDMARK_ASSET_DECODES]
mutant cta-testid-unbound red= [CTA_TESTID_BOUND]
mutant screen-plain-view red= [SCREEN_SAFEAREA_COMPONENT]
SMATRIX_RC=0                                                                                   (12 строк mutant)
STATUS_END

# wordmark: честность растеризации
$ google-chrome --headless=new --disable-gpu --no-sandbox --default-background-color=00000000 --hide-scrollbars \
    --force-device-scale-factor=3 --window-size=143,52 --screenshot=…/Rev111r2/wm-repro.png file://…/C/docs/…/logo/assets/complior-wordmark-dark.svg
10478 bytes written to file /tmp/dev-harness-verify/Rev111r2/wm-repro.png
CHROME_RC=0
fcb1a2f87c2277a67c410226e26e949e403f8ec9a02bce970745969c5f02589e  …/Rev111r2/wm-repro.png
fcb1a2f87c2277a67c410226e26e949e403f8ec9a02bce970745969c5f02589e  …/C/mobile/assets/images/wordmark-dark.png
e0f2ef4f60c9eb48e12fffe97cee61b120dcfcd9cecd78b14452ed33b4d0e4bf  …/logo/assets/complior-wordmark-dark.svg
fcb1a2f87c2277a67c410226e26e949e403f8ec9a02bce970745969c5f02589e  H/…/first_run_111/model/wordmark-dark.png
$ python3 wm_stats.py …/wordmark-dark.png
mode RGBA size (429, 156) ratio 2.7500
nonzero_alpha 14090 of 66924
bbox_of_alpha (0, 33, 429, 143)
top_colors [(52834, (0, 0, 0, 0)), (11620, (242, 241, 236, 255)), (89, (242, 242, 242, 19)), (87, (242, 241, 236, 236))]

# R995 — regress.sh (команды mobile.yml, .harness = H)
CMP_995_OK
995 actual/{DIRECT_unknown,DIRECT_incomplete,INVALID_CODE,RESEND_UNCONFIRMED,RESEND_CONFIRMED,RESEND_COOLDOWN,EMAIL_STALE,
  RECOVERY_A07,AUTH_stale,AUTH_revoked,AUTH_missing_scope,SECRET,REPLAY,DEFAULT_OFFLINE}: rc=0 assertion=passed
995 runs=1 mismatches=0
RC_probe=0 RC_runtime_probe=0 RC_bundle_probe=0 RC_schema_probe=0 RC_frozen_matrix=0 RC_transport_probe=0
RC_admission_probe=0 RC_stale_probe=0 RC_types_probe=0 RC_pins_probe=0 RC_admission_family_probe=0 RC_stale_table_probe=0
RC_nav_probe=0 RC_ui_probe=0 RC_shell_static_probe=0 RC_copy_probe=0
static 22/22   RC_start_static=0
honest 336/336 RC_start=0
Tests:       14 passed, 14 total   RC_test=0
structure: OK (repository inventory; external trees excluded)   RC_lint=0
RC_typecheck=0
STATUS_END    (0 строк)

# APK — release-сборка объекта
$ npx expo prebuild --platform android --no-install          → ✔ Finished prebuild
$ env ANDROID_HOME=/opt/android-sdk JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 ./gradlew --no-daemon --offline assembleRelease -PreactNativeArchitectures=x86_64 …
> Task :app:mergeReleaseResources
BUILD SUCCESSFUL in 1m 18s
GRADLE_RC=0
(Три прежних прогона rc1 не засчитаны, они инфраструктурные: JRE 21 без javac, затем мой случайный параллельный
 gradle в том же каталоге испортил merged_res. После удаления intermediates/merged_res — прогон выше.)

# эмулятор (sg kvm; complior_api36 -read-only, порт 5632) — shot.sh
f562fc669520a8e3372f8328a07f3a6eebcd07d9fcf3233e9385c8b17b95174f  …/app-release.apk
Success  RC_install=0  RC_launch=0  RC_screencap=0  RC_uidump=0
InsetsSource id=8a030000 type=statusBars frame=[0,0][1080,136] visible=true
$ python3 ui_bounds.py
'demo-indicator' android.view.ViewGroup [0,0][137,64]
'Demo' android.widget.TextView [26,10][110,53]
'first-run-safe-area' android.view.ViewGroup [0,96][1080,2400]
'first-run-wordmark' android.widget.ImageView [0,285][159,343]
'Sie sagen, was passiert ist. Complior kümmert sich um den Rest.' android.widget.TextView [0,426][1080,678]
'first-run-continue' android.widget.Button [0,678][687,798]
'Anmelden oder Konto erstellen' android.widget.TextView [52,709][634,766]
(скриншот: /tmp/dev-harness-verify/Rev111r2/first-run-device.png — тёмный full-bleed, без белой рамки;
 «Demo» поверх часов статус-бара; wordmark «complior» и CTA прижаты к x=0)
```
