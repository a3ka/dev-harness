accept (Р2 закрыт, на устройстве и клетками; RESTYLE_GUARD_995 зелёные на продукте и красные на мутантах; R1/A1r2 и регресс зелёные; советы С11–С14 не блокируют)
OBJECT=ae0ec97d88188c6749f460e3ab433f2616f957d8

# Суд реализации контракта 111 (mob First-Run D2.2.5.1), reviewer Rev111r4, круг 4 (scoped: Р2 + RESTYLE_GUARD_995 + регресс)

Контракт: `frozen/contracts/111/1`. Батарея H = `52a534e51a1c99b40c190f24c625036ce4a78999`
(`git archive 52a534e51 fixtures/workshop_project` → `/tmp/dev-harness-verify/Rev111r4/H`).
Объект: `first-run-111/impl` @ ae0ec97d, три коммита поверх 5ab34ce0, автор у всех `implementer`.
Все прогоны шли на одноразовых `cp -a`-копиях `Impl111/mob` в `/tmp/dev-harness-verify/Rev111r4/{C,M1,M2,MX,R995,APK}`.
У каждой копии свой .git; `git status` после каждого прогона 0 строк.
Находки в формате reslop лежат в `/tmp/dev-harness-verify/Rev111r4/review.md`. Блокирующих находок нет.

## Таблица

| # | Предмет | Замер своей мерой | Итог |
|---|---------|-------------------|------|
| **Р2** | кадры 995 не рестайлены | **Устройство**: release-APK OBJECT (sha `312f965c…5688`, собран из ae0ec97d), эмулятор complior_api36 `-read-only`. Путь First-Run → тап CTA → F03.01 → demo-entry → F03.02 (code) → «Zugang wiederherstellen» → F03.04 (recovery). На всех трёх кадрах 995 фон `#FFFFFF` (6 пикселей по краям и `action_bar_root` 94 % `#FFFFFF`). Узлы стоят с x=42 и до x=1038, то есть 16 dp × 2.625 с каждой стороны. F03.01: заголовок `[42,358][1038,436]` `#FFFFFF`/`#111111`, `auth-demo-entry` `#111111`/`#FFFFFF`. Цветовой счёт заголовка 62299/10224 против 62296/10473 у базы круга 2. Регресс круга 3 (`#0A0A0A`, x=0) ушёл. Код: root по кадру, `styles.root` = 48/16/16 + `#FFFFFF` (literal), `rootFirstRun` = `{flex:1}` + ground | **ЗАКРЫТО** |
| A2/К6 | first-run full-bleed `#0A0A0A` | Устройство: First-Run ниже статус-бара `#0A0A0A` 94.37 %, пиксели (5,300), (1075,300), (5,1200), (1075,1200), (540,2395), (1075,2395) все `#0A0A0A`. `first-run-safe-area` `[0,232][1080,2400]`. К6 ×2 зелёные | OK |
| К8/К8′ на продукте | RESTYLE_GUARD_995 ×4 | `honest 19/19` PROBE_RC=0, 4 строки `case RESTYLE_GUARD_995_*` | OK |
| К8/К8′ красные | мутанты батареи + свои | Матрица H: `restyle-995-ground` красит К8 ×2 (+ объявленные К8′ и К6), `restyle-welcome-ground` только К8′ ×2, `restyle-995-no-padding` и `restyle-995-padding-shifted` все 4. MATRIX_RC=0. **Свои**: `dark-only-ground` красит ровно `F03_01_DARK` и `WELCOME_DARK`, rc1; `padding-horizontal-20` красит все 4, rc1 | OK |
| Обходы К8 | атака клеток | Свои мутанты зелёные при рестайле кадра 995 (honest 19/19 rc0): `inner-ground-wrapper`, `code-recovery-ground`, `platform-android-ground`. Продукт этими обходами не пользуется: render прочитан, кадры F03.01, F03.02 и F03.04 измерены на Android. Это слабость батареи, а не продукта, см. С12. Регистр hex: `'#ffffff'` красит все 4 клетки, ложная краснота, см. С14 | совет |
| R1/К7 | бейдж под инсетом | К7 ×2 зелёные. Свой мутант `badge-no-wrapper` красит ровно `DEMO_BADGE_INSET_{DARK,LIGHT}`, rc1. Устройство: `demo-indicator` `[0,136][137,200]` на First-Run, statusBars `[0,0][1080,136]` | OK |
| R1/995 | fallback `{top:0}` | Свой мутант `useSafeAreaInsets()` вместо `useContext ?? {top:0…}`: 995 pilot.test падает на «No safe area value available…», RC_pilot=1. На OBJECT `Tests: 14 passed` rc0 | OK |
| A1r2 | WORDMARK_ASSET_IDENTITY | static 16/16 rc0. Матрица: `wordmark-opaque-one-transparent`, `-recolored-ink`, `-recompressed` красят ровно `[WORDMARK_ASSET_IDENTITY]` | OK |
| Батарея | static / behavioral | `static 16/16` STATIC_RC=0, `honest 19/19` PROBE_RC=0 | OK |
| Матрицы | M2 / M1 | M2 `--matrix`: 15 строк `mutant`, SMATRIX_RC=0. M1 `--matrix`: 24 строки `mutant`, MATRIX_RC=0. Своя мера `ast` по `MUTANTS`: 24 и 15 ключей. `it(` ×10, из них 9 двухсхемных: 9×2+1 = 19 клеток | OK |
| Регресс 995/999/108 | команды mobile.yml, `.harness` = H | CMP_995_OK; `--check-frozen` runs=1 mismatches=0 rc0; 11 проб 995 rc0; 4 пробы 999 rc0; 108 `static 22/22` + `honest 336/336` rc0 | OK |
| npm | test/lint/typecheck | `Tests: 14 passed` RC_test=0, RC_lint=0, RC_typecheck=0 | OK |
| Неизменность прежних клеток | be6b3d657 → 52a534e51 | Изменён только `first_run_111` (автор `architect`, 40fe950cb); у 995/999/108 diff пуст. В `first_run.test.tsx` удалены лишь сигнатуры `ports()` и `renderFirstRun(...)` (новый параметр с дефолтом `'invalid'`, поведение прежних клеток то же) и строка import (+`waitFor`). Тела прежних `it` не тронуты. В `first_run_probe.py` red/depends-множества прежних мутантов только расширены новыми клетками. Якорь `wrapper-root-padding` перенесён на `rootFirstRun`, red-множество прежнее (К6 ×2, замерено). Реализация батарею не правила | OK |
| Область | pilot-app.tsx + mobile.yml | `git diff --stat 5ab34ce06 HEAD`: ровно эти 2 файла. В mobile.yml вне комментариев изменены только 2 строки `ref:` | OK |
| Числа в mobile.yml | своя мера | «16/16 + 19/19, матрица 15+24» и пин 52a534e51 в обоих `ref:` совпадают с замером | OK |
| Атомарность | — | 2eee68dd (Р2) — отдельный коммит. e00f6e62 (числа) и ae0ec97d (перепин) лучше схлопнуть: e00f6e62 несёт числа нового пина при старом `ref:`, см. С13 | совет |
| Норма | — | нормативных документов в дифе нет | OK |

Предел устройства: кадр welcome на эмуляторе не достигнут. `auth-code` имеет `keyboardType="number-pad"` и отвергает
синтетический код `synthetic-verification-value` из `adb input text`, ответ «Ungültiger Code». Welcome судят
К8′ ×2 (Jest), а по коду welcome рендерит `styles.root` без обёртки бейджа.

## Советы (не блокируют) — подробно в review.md

- **С11** (владелец/architect): обёртка бейджа круга 3 сдвигает кадры 995 на statusBars-инсет (136 px: заголовок
  F03.01 y 222 → 358). Фон и поля сохранены. Простая форма `frame === 'first-run' ? insets.top : 0` проходит
  16/16 + 19/19 + 14 passed. Вопрос, рестайл ли это, оставлен владельцу. Обёртку дельта круга пометила «нетронута».
- **С12** (architect): три обхода К8 зелёные: внутренняя обёртка, кадры code/recovery, `Platform.OS`.
- **С13** (implementer): промежуточный e00f6e62 расходится с собственным пином.
- **С14** (architect): К8 строга к регистру hex.

## Контракт 050: паразитная сложность (артефакты дифа круга 4)

| Артефакт | (1) свойство | (2) состояние | (3) сопряжённые правки | (4) глубина | (5) потребитель | Класс |
|---|---|---|---|---|---|---|
| условный root `frame === 'first-run' ? [rootFirstRun, ground] : root` | стр. 41–42/80–83 (995 не рестайлятся) + инв. full-bleed First-Run (К6) | нет, чистая функция `frame` | 1 файл | одно выражение | К6 ×2, К8 ×2, К8′ ×2, устройство | ESSENTIAL |
| `styles.rootFirstRun = {flex:1}` + возврат `styles.root` 48/16/16 `#FFFFFF` | те же | нет | 1 | — | те же | ESSENTIAL |
| комментарии в pilot-app.tsx (2 блока) | — | нет | 1 | — | нет | нейтрально |
| перепин `ref:` ×2 на 52a534e51 + числа в комментариях mobile.yml | «Пины и порядок поставки» | пин явно в mobile.yml | 2 `ref:` + 3 комментария (как в круге 3, число не выросло) | — | шаг quality 111, android-e2e | ESSENTIAL |

Новых скриптов, функций, флагов, env-переменных и файлов состояния нет.

---

## Сырой вывод (отдельно от диагноза)

```
$ git -C …/Impl111/mob log --oneline -4
ae0ec97d 111 r4: H-перепин на 52a534e5 (ленд wip/111/architect) + числа батареи
e00f6e62 111 r4 (числа, без репина): 19/19 + матрица 24 (be6b3d657 -> [ждать ленда])
2eee68dd 111 r4 (P2, контрольная форма ревьюера): root условный по кадру
5ab34ce0 111 r3 (R1): …
$ git diff --stat 5ab34ce0 HEAD
 .github/workflows/mobile.yml       | 41 +++++++++++++++++++++++---------------
 mobile/src/bootstrap/pilot-app.tsx | 33 ++++++++++++++++++++++++++----
$ git diff -U0 5ab34ce06 HEAD -- .github/workflows/mobile.yml | non-comment
-          ref: be6b3d6573d6815bb39cb63cbcce61a63d12d459   (×2)
+          ref: 52a534e51a1c99b40c190f24c625036ce4a78999   (×2)

# батарея: git log be6b3d657..52a534e51 -- fixtures/workshop_project
40fe950cb architect <architect@dev-harness.local> 111 круг 4 (С10/Р2): клетка RESTYLE_GUARD_995 x2 пары …
$ git diff --stat be6b3d657 52a534e51 -- …/pilot_995 …/nav_999 …/start_108   → (пусто)

# C: bash probes.sh C honest
ae0ec97d88188c6749f460e3ab433f2616f957d8
case SPLASH_GROUND_DARK … case STATIC_ORACLE_LITERALS                 (16 строк case)
static 16/16
STATIC_RC=0
case CTA_OPENS_F03_01_DARK / _LIGHT / CTA_TEXT_EQUALS_FRAME_TITLE / DEMO_BADGE_INSET_DARK / _LIGHT /
case FIRST_RUN_COPY_CLOSED_DARK / _LIGHT / FIRST_RUN_GROUND_FULL_SURFACE_DARK / _LIGHT /
case FIRST_RUN_STRUCTURE_DARK / _LIGHT / RESTYLE_GUARD_995_F03_01_DARK / RESTYLE_GUARD_995_F03_01_LIGHT /
case RESTYLE_GUARD_995_WELCOME_DARK / RESTYLE_GUARD_995_WELCOME_LIGHT / SAFEAREA_EDGES_ACTIVE_DARK / _LIGHT /
case WORDMARK_SOURCE_BOUND_DARK / _LIGHT                               (19 строк case)
honest 19/19
PROBE_RC=0
STATUS_END

# M1: bash probes.sh M1 matrix-beh   (24 строки mutant)
mutant cta-label-weiter red= ['CTA_TEXT_EQUALS_FRAME_TITLE', 'FIRST_RUN_COPY_CLOSED_DARK', 'FIRST_RUN_COPY_CLOSED_LIGHT', 'FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT']
mutant promise-invented red= ['FIRST_RUN_COPY_CLOSED_DARK', 'FIRST_RUN_COPY_CLOSED_LIGHT', 'FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT']
mutant onenter-not-wired red= ['CTA_OPENS_F03_01_DARK', 'CTA_OPENS_F03_01_LIGHT', 'CTA_TEXT_EQUALS_FRAME_TITLE', 'RESTYLE_GUARD_995_F03_01_DARK', 'RESTYLE_GUARD_995_F03_01_LIGHT', 'RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT']
mutant ground-default-blue red= ['FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT']
mutant demo-badge-scope red= ['DEMO_BADGE_INSET_DARK', 'DEMO_BADGE_INSET_LIGHT', 'FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT']
mutant wordmark-absent red= ['FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT', 'WORDMARK_SOURCE_BOUND_DARK', 'WORDMARK_SOURCE_BOUND_LIGHT']
mutant cta-testid-renamed red= ['CTA_OPENS_F03_01_DARK', 'CTA_OPENS_F03_01_LIGHT', 'CTA_TEXT_EQUALS_FRAME_TITLE', 'FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT', 'RESTYLE_GUARD_995_F03_01_DARK', 'RESTYLE_GUARD_995_F03_01_LIGHT', 'RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT']
mutant light-cta-noop red= ['CTA_OPENS_F03_01_LIGHT', 'RESTYLE_GUARD_995_F03_01_LIGHT', 'RESTYLE_GUARD_995_WELCOME_LIGHT']
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
mutant restyle-995-ground red= ['FIRST_RUN_GROUND_FULL_SURFACE_DARK', 'FIRST_RUN_GROUND_FULL_SURFACE_LIGHT', 'RESTYLE_GUARD_995_F03_01_DARK', 'RESTYLE_GUARD_995_F03_01_LIGHT', 'RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT']
mutant restyle-welcome-ground red= ['RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT']
mutant restyle-995-no-padding red= ['RESTYLE_GUARD_995_F03_01_DARK', 'RESTYLE_GUARD_995_F03_01_LIGHT', 'RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT']
mutant restyle-995-padding-shifted red= ['RESTYLE_GUARD_995_F03_01_DARK', 'RESTYLE_GUARD_995_F03_01_LIGHT', 'RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT']
MATRIX_RC=0
STATUS_END

# M2: bash probes.sh M2 matrix-static   (15 строк mutant)
mutant splash-stays-default-blue red= ['SPLASH_DEFAULT_BLUE_GONE', 'SPLASH_EFFECTIVE_GROUND_BOTH', 'SPLASH_GROUND_DARK']
mutant android-splash-blue … copy-promise-invented … copy-enter-missing … screen-hex-literal … pilot-unwired …
mutant wordmark-missing red= ['WORDMARK_ASSET', 'WORDMARK_ASSET_DECODES', 'WORDMARK_ASSET_IDENTITY']
mutant wordmark-1x1-png / wordmark-broken-stub-82 / wordmark-solid-rectangle red= ['WORDMARK_ASSET_DECODES', 'WORDMARK_ASSET_IDENTITY']
mutant wordmark-opaque-one-transparent red= ['WORDMARK_ASSET_IDENTITY']
mutant wordmark-recolored-ink red= ['WORDMARK_ASSET_IDENTITY']
mutant wordmark-recompressed red= ['WORDMARK_ASSET_IDENTITY']
mutant cta-testid-unbound red= ['CTA_TESTID_BOUND']
mutant screen-plain-view red= ['SCREEN_SAFEAREA_COMPONENT']
SMATRIX_RC=0
STATUS_END

# своя мера чисел (ast, H/fixtures/workshop_project/first_run_111)
first_run_probe.py MUTANTS keys 24
first_run_static_probe.py MUTANTS keys 15
it( lines 10 ; it with ${S} 9      → 9×2 + 1 = 19

# MX: python3 own_mutants.py (поведенческая проба H на патче pilot-app.tsx)
HEAD ae0ec97d88188c6749f460e3ab433f2616f957d8
=== hex-lowercase: rc=1 red=['RESTYLE_GUARD_995_F03_01_DARK', 'RESTYLE_GUARD_995_F03_01_LIGHT', 'RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT']
=== inner-ground-wrapper: rc=0 red=[] ['honest 19/19']
=== code-recovery-ground: rc=0 red=[] ['honest 19/19']
=== platform-android-ground: rc=0 red=[] ['honest 19/19']
=== dark-only-ground: rc=1 red=['RESTYLE_GUARD_995_F03_01_DARK', 'RESTYLE_GUARD_995_WELCOME_DARK']
=== padding-horizontal-20: rc=1 red=['RESTYLE_GUARD_995_F03_01_DARK', 'RESTYLE_GUARD_995_F03_01_LIGHT', 'RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT']
=== badge-no-wrapper: rc=1 red=['DEMO_BADGE_INSET_DARK', 'DEMO_BADGE_INSET_LIGHT']
STATUS clean
# MX: fallback-мутант (useSafeAreaInsets())
  ● 995 pilot › DIRECT_unknown
    No safe area value available. Make sure you are rendering `<SafeAreaProvider>` at the top of your app.
RC_pilot=1
Tests:       14 passed, 14 total        RC_pilot_obj=0 (OBJECT)
# MX: простая форма С11 (paddingTop: frame === 'first-run' ? insets.top : 0)
honest 19/19  PROBE_RC=0 ; static 16/16  STATIC_RC=0 ; Tests: 14 passed  RC_pilot=0 ; git status 0 строк

# R995: bash regress.sh (команды mobile.yml, .harness = H 52a534e51)
ae0ec97d88188c6749f460e3ab433f2616f957d8
CMP_995_OK
995 actual/REPLAY: rc=0 assertion=passed
995 actual/DEFAULT_OFFLINE: rc=0 assertion=passed
995 runs=1 mismatches=0
RC_probe=0 RC_runtime_probe=0 RC_bundle_probe=0 RC_schema_probe=0 RC_frozen_matrix=0 RC_transport_probe=0
RC_admission_probe=0 RC_stale_probe=0 RC_types_probe=0 RC_pins_probe=0 RC_admission_family_probe=0 RC_stale_table_probe=0
RC_nav_probe=0 RC_ui_probe=0 RC_shell_static_probe=0 RC_copy_probe=0
static 22/22   RC_start_static=0
honest 336/336 RC_start=0
Tests:       14 passed, 14 total   RC_test=0
structure: OK (repository inventory; external trees excluded)   RC_lint=0
RC_typecheck=0
STATUS_END   (0 строк)

# APK: JAVA_HOME=jdk17 ANDROID_HOME=/opt/android-sdk ./gradlew --offline assembleRelease -PreactNativeArchitectures=x86_64 (checkout ae0ec97d)
Android Bundled 7072ms node_modules/expo-router/entry.js (1259 modules)
BUILD SUCCESSFUL in 1m 39s
GRADLE_RC=0
312f965cd0fe058c6d8ac783cd3fbbf1b4acacc8edbd08e0c47bb2e134925688  app/build/outputs/apk/release/app-release.apk

# устройство: python3 device.py <APK> obj   (emulator-5632, complior_api36 -read-only)
RC_install 0 ; RC_launch 0
InsetsSource … type=statusBars frame=[0,0][1080,136] visible=true
== first-run
'demo-indicator' [0,136][137,200] ; 'first-run-safe-area' [0,232][1080,2400] [('#0A0A0A', 2212468), ('#D6F75A', 70754)]
'first-run-continue' android.widget.Button [0,814][687,934]
px (5,300) (1075,300) (5,1200) (1075,1200) (540,2395) (1075,2395) = #0A0A0A
below-statusbar top colors [('#0A0A0A', 0.9437), ('#D6F75A', 0.0289), ('#F2F1EC', 0.0143)]
tap first-run-continue RC_tap=0
== f0301
'com.complior.mobile:id/action_bar_root' [0,0][1080,2400] [('#FFFFFF', 2444605), ('#111111', 119604)]
'demo-indicator' [42,262][179,326] [('#F2F2F2', 7602), ('#444444', 494)]
'Anmelden oder Konto erstellen' android.view.View [42,358][1038,436] [('#FFFFFF', 62299), ('#111111', 10224)]
'auth-email' android.widget.EditText [42,467][1038,582] [('#FFFFFF', 107950), ('#999999', 4207)]
'auth-demo-entry' android.widget.Button [42,614][1038,755] [('#111111', 109380), ('#FFFFFF', 26713)]
px (5,300) (1075,300) (5,1200) (1075,1200) (540,2395) (1075,2395) = #FFFFFF
below-statusbar top colors [('#FFFFFF', 0.9397), ('#111111', 0.0489), ('#F2F2F2', 0.0031)]
tap auth-demo-entry RC_tap=0
== after-demo (F03.02 code)
'Kontakt bestätigen' [42,358][1038,436] [('#FFFFFF', 67406), ('#111111', 6697)] ; 'auth-code' [42,467][1038,582] ; px … = #FFFFFF
# device_recovery.py: tap auth-no-access RC_tap=0
== recovery (F03.04)
'F03.04' [42,358][1038,785] [('#FFFFFF', 284478), ('#111111', 121106)] ; 'auth-recover' [42,562][1038,703] ; px … = #FFFFFF
below-statusbar top colors [('#FFFFFF', 0.9377), ('#111111', 0.0495), ('#F2F2F2', 0.0032)]
# device_welcome.py objw synthetic-verification-value: after-verify → 'Ungültiger Code' (number-pad отверг буквы) — welcome не достигнут

# база круга 2 (Rev111r3/auth-ui-r2.xml, APK e26ba282) для С11
auth-ui-r2.xml demo-indicator [42,126][179,190]
auth-ui-r2.xml Anmelden oder Konto erstellen [42,222][1038,300]
auth-ui-r2.xml auth-email [42,331][1038,446]
```

Воспроизведение: `bash Rev111r4/probes.sh {C honest|M1 matrix-beh|M2 matrix-static}`, `bash Rev111r4/regress.sh`,
`python3 Rev111r4/own_mutants.py`, `python3 Rev111r4/device.py <APK> obj`, `python3 Rev111r4/device_recovery.py`
(эмулятор: `sg kvm -c "emulator -avd complior_api36 -read-only -port 5632 -no-window"`). Снимки:
`Rev111r4/obj-{first-run,f0301,after-demo}.{png,xml}`, `objr-recovery.{png,xml}`.
