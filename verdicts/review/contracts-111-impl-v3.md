FAIL (Р2: регресс кадров 995, нарушено замороженное «Вне предмета»; A1r2 и R1 закрыты)
OBJECT=5ab34ce0644ff849bcb189f285b84325dcc8e543

# Суд реализации контракта 111 (mob First-Run D2.2.5.1), reviewer Rev111r3, круг 3 (scoped A1r2, R1 + регресс)

Контракт: `frozen/contracts/111/1` (тег → 2f6ebcf59). Батарея H = `be6b3d6573d6815bb39cb63cbcce61a63d12d459`
(`git archive be6b3d657 fixtures/workshop_project` → `/tmp/dev-harness-verify/Rev111r3/H`).
Объект: родитель e26ba282 (предмет круга 2), автор `implementer`, один коммит со ссылкой «111 r3 (R1)».
Все прогоны шли на `cp -a`-копиях клона `Impl111/mob` в `/tmp/dev-harness-verify/Rev111r3/{C,M1,M2,MX,R995,APK}`.
Находки в формате reslop: `review.md` (та же папка). Кап круга исчерпан (третий): FAIL ⇒ арбитр.

Итог: A1r2 закрыт, R1 закрыт, оба измерены своей мерой, R1 ещё и на устройстве. Батарея, 995/999/108 и npm
зелёные. **Блокирует новая находка Р2**: правка круга 3 перекрасила и лишила отступов кадры 995. Замороженный
контракт прямо запрещает их рестайлить. На устройстве F03.01 (цель CTA First-Run) показывает тёмный текст на
тёмном фоне. Батарея этого не видит.

## Таблица

| # | Предмет | Замер своей мерой | Итог |
|---|---------|-------------------|------|
| A1r2 | бренд-идентичность растра wordmark | Клетка `WORDMARK_ASSET_IDENTITY` на C зелёная (static 16/16 rc0). Стаб матрицы `wordmark-opaque-one-transparent` (sha `a9f143a1…dcba`) красен ровно `[WORDMARK_ASSET_IDENTITY]`. **Свой мутант** (Pillow, непрозрачный чёрный 429×156 с одним прозрачным пикселем, sha `733e81f7…fc82`, кодировщик не тот, что у стаба) красен ровно `WORDMARK_ASSET_IDENTITY`, `DECODES` зелёная, rc1. Второй свой мутант: ink растра перекрашен в `#FFFFFF`, глифы сохранены (sha `8727ecaf…11cd`), красен ровно IDENTITY | **ЗАКРЫТО** |
| R1 | Demo-бейдж внутри safe-area | К7 `DEMO_BADGE_INSET_{DARK,LIGHT}` на C зелёные. Стабы матрицы badge-outside-safearea, badge-inset-top-zero и badge-hardcoded-inset красны ровно парой К7. **Свои мутанты:** хардкод `59` красен парой К7, `paddingBottom: insets.top` красен парой К7, честный вариант `marginTop: insets.top` зелёный (15/15). **Устройство** (release-APK OBJECT `b5eb07b9…79db`): `demo-indicator` `[0,136][137,200]`, statusBars `frame=[0,0][1080,136]`, то есть бейдж начинается ровно под инсетом. В круге 2 было `[0,0][137,64]` | **ЗАКРЫТО** |
| R1/995 | fallback `{top:0}` вне SafeAreaProvider | Свой мутант: `useSafeAreaInsets()` вместо `useContext(...) ?? {top:0…}`. 995 `pilot.test.tsx` падает: «No safe area value available…», RC_pilot=1. На OBJECT `Tests: 14 passed` rc0. Fallback несущий, не мёртвый | OK |
| A2-регресс | full-bleed `#0A0A0A` на First-Run | К6 ×2 зелёные. На устройстве пиксели (1075,140), (5,1200), (1075,1200), (5,2395), (540,2395), (1075,2395) равны `#0A0A0A`. Ниже статус-бара `#0A0A0A` 94.4 %, белых пикселей 0 | OK |
| **Р2** | регресс кадров 995 (F03.01+, welcome) | Устройство, First-Run → тап CTA → F03.01. Фон `#0A0A0A`, заголовок `#111111` (не читается), `auth-demo-entry` `#111111` на `#0A0A0A`, узлы с x=0. База круга 2 по тому же пути: фон `#FFFFFF`, узлы с x=42 | **FAIL (блок)** |
| Батарея | static / behavioral | `static 16/16` STATIC_RC=0 (16 строк `case`); `honest 15/15` PROBE_RC=0 (15 строк `case`); `git status` 0 строк | OK |
| Матрицы | M1 / M2 | M1 `--matrix`: 20 строк `mutant`, MATRIX_RC=0. M2 `--matrix`: 15 строк `mutant`, SMATRIX_RC=0. Своя мера: `ast` по словарю `MUTANTS` даёт 20 и 15 ключей; `it(` ×8 = 7 двухсхемных + 1 = 15 клеток | OK |
| Регресс 995/999/108 | команды mobile.yml, `.harness` = H | CMP_995_OK; probe.py --check-frozen rc0 (runs=1 mismatches=0); 11 проб 995 rc0; 4 пробы 999 rc0; 108 `static 22/22` + `honest 336/336` rc0 | OK |
| npm | test/lint/typecheck | `Tests: 14 passed` RC_test=0, RC_lint=0, RC_typecheck=0; `git status` 0 строк | OK |
| Release-сборка | путь android-e2e | `gradlew --offline assembleRelease -PreactNativeArchitectures=x86_64` GRADLE_RC=0, APK ставится и стартует | OK (CI не наблюдаем: объект не запушен) |
| Неизменность frozen-батареи | first_run_111 frozen 111/1 → be6b3d657 | Круг 3 (18763ef30..be6b3d657): удалённые строки — только расширение red-множеств мутантов новыми клетками (`+IDENTITY`, `+DEMO_BADGE_INSET` в `demo-badge-scope`), оборачивание `renderFirstRun` в `SafeAreaInsetsContext.Provider` без host-узлов и комментарии. Проверки прежних клеток не изменены. Фикстуры 995/999/108 между 18763ef30 и be6b3d657: `git diff --stat` пуст | OK |
| Числа С7 | комментарии mobile.yml | «16/16 + 15/15, матрица 15+20» в трёх местах совпадает с замером выше. Пин `be6b3d657` стоит в обоих `ref:` (quality, android-e2e). `diff -I '^\s*#'`: вне комментариев изменены только 2 строки `ref:` | OK |
| Область | ЗОНА implementer | Диф круга 3 — ровно `pilot-app.tsx` + `mobile.yml`, оба файла в ЗОНЕ. **По содержанию** правка вышла за R1: рестайл кадров 995 → Р2 | см. Р2 |
| Атомарность | — | 1 коммит, автор `implementer`, ссылка «111 r3 (R1)». Перепин H — обязательное следствие новой батареи | OK |
| Норма | — | нормативных документов в дифе нет | OK |

## Блокирующая находка

### Р2: правка круга 3 рестайлит кадры 995 (F03.01+, welcome), а F03.01 на устройстве не читается

- **Обязательство** (`contracts/111-cmp-mob-first-run.md` @ frozen/contracts/111/1):
  - стр. 41–42: «Предмет заменяет first-run-кадр; остальные кадры (email/code/unavailable/recovery/welcome) — поверхность 995, не рестайлятся»;
  - стр. 80–83, «Вне предмета»: «кадры F03.01+ и welcome (поверхность 995, не рестайлятся) … userInterfaceStyle/тёмная тема остальных кадров»;
  - стр. 77–78: нажатие CTA «открывает F03.01 (email-кадр 995) с прежней семантикой».
- **Фрагмент**: `mobile/src/bootstrap/pilot-app.tsx`. Было `frame === 'first-run' ? [styles.rootFirstRun, {ground}] : styles.root`
  (root = `paddingTop 48 / paddingHorizontal 16 / paddingBottom 16 / #FFFFFF`). Стало
  `<View style={[styles.root, { backgroundColor: tokens.ground }]}>` для всех кадров при `styles.root = { flex: 1 }`.
  Экраны 995 по-прежнему красят себя литералами под белый фон: `auth-screen.tsx` title/input `#111111`,
  buttonText bg `#111111`, body `#333333`; `welcome-screen.tsx` body/demo `#111111`. Теперь они лежат на `#0A0A0A`.
- **Наблюдение**: release-APK OBJECT, First-Run → тап CTA:
  `'Anmelden oder Konto erstellen' [0,232][1080,310]` с цветами `#0A0A0A`/`#111111`, `'auth-demo-entry' [0,488][1080,629]`
  `#111111`/`#0A0A0A`, фон кадра `#0A0A0A`. Глазом заголовок не виден, кнопка без контура (`auth-device.png`).
  База круга 2 (APK `f562fc66…`, e26ba282, тот же путь): заголовок `[42,222][1038,300]` на `#FFFFFF`, поля 42 px
  (`auth-device-r2.png`). Регресс внёс именно диф круга 3. В круге 2 условный root держал кадры 995 нетронутыми.
- **ОБХОД**: К2 `CTA_OPENS_F03_01_*` ищет заголовок по роли и `auth-email`, на цвет и отступы не смотрит.
  995 pilot.test — Jest без вёрстки. Поэтому продукт с нечитаемым F03.01 даёт 16/16 + 15/15 + 14 passed.
  Модель H (`model/bootstrap.pilot-app.tsx` стр. 199, 249–251) делает ровно то же. Продукт снова повторяет модель
  дословно (С1 круга 1), а модель здесь расходится с контрактом (совет С10 для architect).
- **Более простая форма, проходящая те же строки (проверено)**: `fix_probe.sh` на MX. Root по кадру:
  first-run → `[styles.rootFirstRun /* { flex: 1 } */, { backgroundColor: tokens.ground }]`, остальные → прежний
  `styles.root` (48/16/16 + `#FFFFFF`), обёртка бейджа с `insets.top` без изменений. Итог: `static 16/16` rc0,
  `honest 15/15` rc0, `Tests: 14 passed` rc0. В продукт не вносилось.
- **Воспроизведение**: `bash /tmp/dev-harness-verify/Rev111r3/shot.sh && bash /tmp/dev-harness-verify/Rev111r3/shot_auth.sh`
  (эмулятор `complior_api36 -read-only`, порт 5632; APK собран в `Rev111r3/APK`). База:
  `bash /tmp/dev-harness-verify/Rev111r3/shot_auth_r2.sh`.

## Советы (не блокируют)

- **С8** (из круга 2): на First-Run wordmark `[0,421][159,479]` и CTA `[0,814][687,934]` прижаты к x=0.
- **С10** (architect): модель H расходится со стр. 41–42/80–83 контракта, то есть рестайлит кадры 995.
  Клетки, которая увидела бы рестайл кадров 995 (фон или отступ root вне first-run), в батарее нет.

## Контракт 050: паразитная сложность (артефакты дифа круга 3)

| Артефакт | (1) свойство | (2) состояние | (3) сопряжённые правки | (4) глубина | (5) потребитель | Класс |
|---|---|---|---|---|---|---|
| `useContext(SafeAreaInsetsContext) ?? {0,0,0,0}` | инв. 7 / К7 (бейдж под инсетом) + совместимость с 995 (pilot.test без провайдера) | читает существующий контекст библиотеки, fallback явный в коде | 1 | одно выражение | К7 ×2; 995 pilot.test (без fallback красен, замерено) | ESSENTIAL |
| обёртка `<View style={{ paddingTop: insets.top }}>` | инв. 7 / К7 | нет | 1 | — | К7 ×2, устройство | ESSENTIAL |
| слияние root (`styles.root = {flex:1}` + ground на всех кадрах) | ни одного: R1 его не требует, контракт его запрещает (Р2) | нет | 1 | — | нет (К6 проходит и с условным root, замерено) | ACCIDENTAL, блок через Р2 |
| перепин `ref:` ×2 на be6b3d657 + числа в комментариях | «Пины и порядок поставки» | пин явно в mobile.yml | 2 `ref:` + 3 комментария | — | шаг quality 111, android-e2e | ESSENTIAL |

Новых функций, флагов и env-переменных нет.

---

## Сырой вывод (отдельно от диагноза)

```
$ git -C …/Impl111/mob log --oneline -2
5ab34ce0 111 r3 (R1): бейдж в safe-area (useContext fallback), H-перепин be6b3d657 + числа 16/16+15/15+15+20 в mobile.yml
e26ba282 111 r3: перепин H quality/android-e2e checkout на 18763ef30 …
$ git diff --stat e26ba282 5ab34ce0
 .github/workflows/mobile.yml       | 28 ++++++++++++------------
 mobile/src/bootstrap/pilot-app.tsx | 45 +++++++++++++++++++++-----------------
 2 files changed, 39 insertions(+), 34 deletions(-)
$ git show --format='%an <%ae>' HEAD → implementer <implementer@dev-harness.local>

# C: bash probes.sh C honest
5ab34ce0644ff849bcb189f285b84325dcc8e543
case SPLASH_GROUND_DARK / SPLASH_DEFAULT_BLUE_GONE / SPLASH_EFFECTIVE_GROUND_BOTH / COPY_KEY_ui_first_run_promise /
case COPY_KEY_ui_first_run_enter_f03 / SCREEN_SEAM_FIRST_RUN / SCREEN_NO_HEX_LITERALS / SCREEN_SAFEAREA_COMPONENT /
case SCREEN_THEME_TOKENS / CTA_TESTID_BOUND / PILOT_WIRED_FIRST_RUN / LEGACY_WEITER_GONE / WORDMARK_ASSET /
case WORDMARK_ASSET_DECODES / WORDMARK_ASSET_IDENTITY / STATIC_ORACLE_LITERALS                    (16 строк case)
static 16/16
STATIC_RC=0
case CTA_OPENS_F03_01_DARK / CTA_OPENS_F03_01_LIGHT / CTA_TEXT_EQUALS_FRAME_TITLE / DEMO_BADGE_INSET_DARK /
case DEMO_BADGE_INSET_LIGHT / FIRST_RUN_COPY_CLOSED_DARK / FIRST_RUN_COPY_CLOSED_LIGHT /
case FIRST_RUN_GROUND_FULL_SURFACE_DARK / FIRST_RUN_GROUND_FULL_SURFACE_LIGHT / FIRST_RUN_STRUCTURE_DARK /
case FIRST_RUN_STRUCTURE_LIGHT / SAFEAREA_EDGES_ACTIVE_DARK / SAFEAREA_EDGES_ACTIVE_LIGHT /
case WORDMARK_SOURCE_BOUND_DARK / WORDMARK_SOURCE_BOUND_LIGHT                                    (15 строк case)
honest 15/15
PROBE_RC=0
STATUS_END            (0 строк git status)

# M2: bash probes.sh M2 matrix-static (строки mutant)
mutant splash-stays-default-blue red= ['SPLASH_DEFAULT_BLUE_GONE', 'SPLASH_EFFECTIVE_GROUND_BOTH', 'SPLASH_GROUND_DARK']
mutant android-splash-blue red= ['SPLASH_EFFECTIVE_GROUND_BOTH']
mutant copy-promise-invented red= ['COPY_KEY_ui_first_run_promise']
mutant copy-enter-missing red= ['COPY_KEY_ui_first_run_enter_f03']
mutant screen-hex-literal red= ['SCREEN_NO_HEX_LITERALS']
mutant pilot-unwired red= ['PILOT_WIRED_FIRST_RUN']
mutant wordmark-missing red= ['WORDMARK_ASSET', 'WORDMARK_ASSET_DECODES', 'WORDMARK_ASSET_IDENTITY']
mutant wordmark-1x1-png red= ['WORDMARK_ASSET_DECODES', 'WORDMARK_ASSET_IDENTITY']
mutant wordmark-broken-stub-82 red= ['WORDMARK_ASSET_DECODES', 'WORDMARK_ASSET_IDENTITY']
mutant wordmark-solid-rectangle red= ['WORDMARK_ASSET_DECODES', 'WORDMARK_ASSET_IDENTITY']
RED WORDMARK_ASSET_IDENTITY: sha256 a9f143a1a2c4383d661b67718ec5530fb0f9111ca96e1a00064965e13062dcba
mutant wordmark-opaque-one-transparent red= ['WORDMARK_ASSET_IDENTITY']
mutant wordmark-recolored-ink red= ['WORDMARK_ASSET_IDENTITY']
mutant wordmark-recompressed red= ['WORDMARK_ASSET_IDENTITY']
mutant cta-testid-unbound red= ['CTA_TESTID_BOUND']
mutant screen-plain-view red= ['SCREEN_SAFEAREA_COMPONENT']
SMATRIX_RC=0                                                                                     (15 строк mutant)
STATUS_END

# M1: bash probes.sh M1 matrix-beh
mutant cta-label-weiter red= ['CTA_TEXT_EQUALS_FRAME_TITLE', 'FIRST_RUN_COPY_CLOSED_DARK', 'FIRST_RUN_COPY_CLOSED_LIGHT', 'FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT']
mutant promise-invented red= ['FIRST_RUN_COPY_CLOSED_DARK', 'FIRST_RUN_COPY_CLOSED_LIGHT', 'FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT']
mutant onenter-not-wired red= ['CTA_OPENS_F03_01_DARK', 'CTA_OPENS_F03_01_LIGHT', 'CTA_TEXT_EQUALS_FRAME_TITLE']
mutant ground-default-blue red= ['FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT']
mutant demo-badge-scope red= ['DEMO_BADGE_INSET_DARK', 'DEMO_BADGE_INSET_LIGHT', 'FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT']
mutant wordmark-absent red= ['FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT', 'WORDMARK_SOURCE_BOUND_DARK', 'WORDMARK_SOURCE_BOUND_LIGHT']
mutant cta-testid-renamed red= ['CTA_OPENS_F03_01_DARK', 'CTA_OPENS_F03_01_LIGHT', 'CTA_TEXT_EQUALS_FRAME_TITLE', 'FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT']
mutant light-cta-noop red= ['CTA_OPENS_F03_01_LIGHT']
mutant safearea-edges-empty red= ['SAFEAREA_EDGES_ACTIVE_DARK', 'SAFEAREA_EDGES_ACTIVE_LIGHT']
mutant wordmark-wrong-source red= ['WORDMARK_SOURCE_BOUND_DARK', 'WORDMARK_SOURCE_BOUND_LIGHT']
mutant extra-unreviewed-copy red= ['FIRST_RUN_COPY_CLOSED_DARK', 'FIRST_RUN_COPY_CLOSED_LIGHT']
mutant light-edges-top-bottom red= ['SAFEAREA_EDGES_ACTIVE_LIGHT']
mutant light-wrong-source red= ['WORDMARK_SOURCE_BOUND_LIGHT']
mutant light-extra-copy red= ['FIRST_RUN_COPY_CLOSED_LIGHT']
mutant wrapper-root-white red= ['FIRST_RUN_GROUND_FULL_SURFACE_DARK', 'FIRST_RUN_GROUND_FULL_SURFACE_LIGHT']
mutant wrapper-root-magenta red= ['FIRST_RUN_GROUND_FULL_SURFACE_DARK', 'FIRST_RUN_GROUND_FULL_SURFACE_LIGHT']
mutant wrapper-root-padding red= ['FIRST_RUN_GROUND_FULL_SURFACE_DARK', 'FIRST_RUN_GROUND_FULL_SURFACE_LIGHT']
mutant badge-outside-safearea red= ['DEMO_BADGE_INSET_DARK', 'DEMO_BADGE_INSET_LIGHT']
mutant badge-inset-top-zero red= ['DEMO_BADGE_INSET_DARK', 'DEMO_BADGE_INSET_LIGHT']
mutant badge-hardcoded-inset red= ['DEMO_BADGE_INSET_DARK', 'DEMO_BADGE_INSET_LIGHT']
MATRIX_RC=0                                                                                      (20 строк mutant)
STATUS_END

# своя мера чисел
$ python3 (ast по MUTANTS)  → first_run_probe.py MUTANTS keys 20 ; first_run_static_probe.py MUTANTS keys 15
$ grep -cE '^\s+it\(' first_run.test.tsx → 8   (7 двухсхемных × 2 + CTA_TEXT_EQUALS_FRAME_TITLE = 15)

# MX: bash own_mutants.sh (свои мутанты)
=== own-black: Pillow, непрозрачный чёрный 429x156, один прозрачный пиксель
733e81f7ff5f8ccdc1b001daae81a1feb9eeb498ba05296d5663bd905828fc82  mobile/assets/images/wordmark-dark.png
RED WORDMARK_ASSET_IDENTITY: sha256 733e81f7ff5f8ccdc1b001daae81a1feb9eeb498ba05296d5663bd905828fc82
RED WORDMARK_ASSET_IDENTITY
RC=1
=== own-ink-white: тот же растр, ink заменён на #FFFFFF (глифы сохранены)
RED WORDMARK_ASSET_IDENTITY: sha256 8727ecaf135ab7243ebc3d9843abc59f6ef533412ff4db9701ae2a67019811cd
RED WORDMARK_ASSET_IDENTITY
RC=1
=== own-badge-59: хардкод второго литерала мока
RED DEMO_BADGE_INSET_DARK
RED DEMO_BADGE_INSET_LIGHT
RC=1
=== own-badge-bottom: инсет ушёл в paddingBottom (верх не сдвинут)
RED DEMO_BADGE_INSET_DARK
RED DEMO_BADGE_INSET_LIGHT
RC=1
=== own-badge-margin: honest-вариант marginTop (ожидание зелёный)
honest 15/15
RC=0
=== own-no-fallback: useSafeAreaInsets() вместо useContext ?? {top:0} — 995 pilot.test без провайдера
  ● 995 pilot › DIRECT_unknown
    No safe area value available. Make sure you are rendering `<SafeAreaProvider>` at the top of your app.
  ● 995 pilot › DIRECT_incomplete
    No safe area value available. Make sure you are rendering `<SafeAreaProvider>` at the top of your app.
RC_pilot=1
STATUS_END

# R995: bash regress.sh (команды mobile.yml, .harness = H be6b3d657)
5ab34ce0644ff849bcb189f285b84325dcc8e543
CMP_995_OK
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

# неизменность батареи
$ git diff --stat 18763ef30 be6b3d657 -- fixtures/workshop_project
 first_run_111/first_run.test.tsx | 70 ; first_run_probe.py | 40 ; first_run_static_probe.py | 85 ; model/bootstrap.pilot-app.tsx | 12
 (pilot_995 / nav_999 / start_108 — без изменений)

# APK: gradlew --offline assembleRelease -PreactNativeArchitectures=x86_64 (APK = cp -a Rev111r2/APK, checkout 5ab34ce0)
Android Bundled 8793ms node_modules/expo-router/entry.js (1259 modules)
GRADLE_RC=0
b5eb07b9c562f693bf0bfbe1745d7776174adb557d2847d8b0ccfb0bc62779db  app/build/outputs/apk/release/app-release.apk

# устройство: bash shot.sh (First-Run, OBJECT)
RC_install=0 RC_launch=0 RC_screencap=0 RC_uidump=0
InsetsSource id=5a030000 type=statusBars frame=[0,0][1080,136] visible=true
'demo-indicator' android.view.ViewGroup [0,136][137,200]
'Demo' android.widget.TextView [26,146][110,189]
'first-run-safe-area' android.view.ViewGroup [0,232][1080,2400]
'first-run-wordmark' android.widget.ImageView [0,421][159,479]
'first-run-continue' android.widget.Button [0,814][687,934]
px (1075, 140) #0A0A0A ; px (5, 1200) #0A0A0A ; px (1075, 1200) #0A0A0A ; px (5, 2395) #0A0A0A ; px (540, 2395) #0A0A0A
below-statusbar top colors [('#0A0A0A', 0.9437), ('#D6F75A', 0.0289), ('#F2F1EC', 0.0143)]
white px below statusbar 0

# устройство: bash shot_auth.sh (тап CTA → F03.01, OBJECT)
RC_tap=0 RC_screencap=0 RC_uidump=0
'Anmelden oder Konto erstellen' android.view.View [0,232][1080,310] [('#0A0A0A', 69647), ('#111111', 11124)]
'auth-email' android.widget.EditText [0,341][1080,456] [('#0A0A0A', 117095), ('#999999', 3496)]
'auth-demo-entry' android.widget.Button [0,488][1080,629] [('#111111', 119491), ('#0A0A0A', 23008)]
px (5, 300) #0A0A0A ; px (1075, 1200) #0A0A0A ; px (540, 2395) #0A0A0A

# устройство: bash shot_auth_r2.sh (база круга 2, APK f562fc66…, тот же путь)
RC_install=0 RC_launch=0 RC_tap=0 RC_screencap=0 RC_uidump=0
'com.complior.mobile:id/action_bar_root' [0,0][1080,2400] [('#FFFFFF', 2444381), ('#111111', 119728)]
'Anmelden oder Konto erstellen' android.view.View [42,222][1038,300] [('#FFFFFF', 62296), ('#111111', 10473)]
'auth-email' android.widget.EditText [42,331][1038,446] [('#FFFFFF', 107946), ('#999999', 3253)]
'auth-demo-entry' android.widget.Button [42,478][1038,619] [('#111111', 109255), ('#FFFFFF', 26496)]

# контрольная форма Р2: bash fix_probe.sh (MX, в продукт не вносилась)
 mobile/src/bootstrap/pilot-app.tsx | 15 ++++++++++++++-
static 16/16   STATIC_RC=0
honest 15/15   PROBE_RC=0
Tests:       14 passed, 14 total   RC_test=0
STATUS_END
```
