accept (С11 закрыт: на устройстве заголовок F03.01 y=222, кадры 995 попиксельно равны базе до 111; First-Run full-bleed и бейдж под инсетом сохранены; регресс зелёный; область — 1 файл, коммит атомарен)
OBJECT=91da6487b8351a6d8b9a5bb956f7364ea8fdacec

# Суд реализации контракта 111 (mob First-Run), reviewer Rev111r5, микро-круг r5 (scoped ТОЛЬКО С11)

Контракт: `frozen/contracts/111/1`, `contracts/111-cmp-mob-first-run.md`, стр. 41–42 и 80–83 («остальные кадры
… поверхность 995, не рестайлятся»). Батарея H: `52a534e51a1c99b40c190f24c625036ce4a78999`, получена через
`git archive` в `Rev111r5/H`. Объект: `first-run-111/impl` @ 91da6487. Все прогоны шли на одноразовых
`cp -a`-копиях `Impl111/mob` в `/tmp/dev-harness-verify/Rev111r5/{C,M1,M2,R995,MX,APK,BASE}`, у каждой свой
.git. Расширение охвата RESTYLE_GUARD_995 принято как остаточный риск и предметом круга не было. Находки в
формате reslop: `/tmp/dev-harness-verify/Rev111r5/review.md`. Блокирующих находок нет.

## Таблица

| # | Предмет | Замер своей мерой | Итог |
|---|---------|-------------------|------|
| **С11** | y заголовка F03.01 = 222 | **Устройство**: release-APK OBJECT (sha `016c94d5…de76`, собран из 91da6487 командами android-e2e mobile.yml), эмулятор complior_api36 `-read-only`, statusBars `[0,0][1080,136]`. F03.01: заголовок `[42,222][1038,300]`, `demo-indicator` `[42,126][179,190]`, `auth-email` `[42,331]`, `auth-demo-entry` `[42,478]`. Круг 4 (ae0ec97d) давал `[42,358]`, `[42,262]`, `[42,467]`, `[42,614]`, то есть сдвиг +136 снят | **ЗАКРЫТО** |
| С11 / база | «как до 111» | **Своя база**: release-APK 16eb708a, родителя первого коммита 111 cec116cd (sha `3bc74187…6890`), то же устройство. F03.01, code и recovery дают те же bounds и те же цветовые счёты (62296/10473 у заголовка). `pixdiff.py`: ниже статус-бара **0** отличающихся пикселей на F03.01, code и recovery | ЗАКРЫТО |
| С11 / F03.02 | code | Устройство: `Kontakt bestätigen` `[42,222][1038,300]`, `auth-code` `[42,331]`, фон `#FFFFFF` по 6 пикселям | ЗАКРЫТО |
| С11 / F03.04 | recovery | Устройство: `Zugang wiederherstellen` `[42,222][1038,300]`, `auth-recover` `[42,426]`, `#FFFFFF` | ЗАКРЫТО |
| С11 / welcome | Jest (явно: не устройство) | На устройстве не достигнут: number-pad `auth-code` отвергает демо-код, см. И2. Своя мера `c11_r5.test.tsx`, 2 схемы × инсеты 47/59: на welcome нет `demo-indicator`, в дереве нет отступа, равного инсету. На OBJECT 4 passed, rc0. **Красное**: форма до r5 даёт 4 failed, rc1 (F03.01, code и recovery несут инсет 47/59) | ЗАКРЫТО (Jest) |
| A2/К6 | First-Run full-bleed `#0A0A0A` | Устройство: `action_bar_root` `#0A0A0A`, 6 пикселей по краям `#0A0A0A`, ниже статус-бара `#0A0A0A` 94.37 %. `first-run-safe-area` `[0,232][1080,2400]`. К6 ×2 зелёные | OK |
| R1/К7 | бейдж ниже статус-бара на First-Run | Устройство: `demo-indicator` `[0,136][137,200]` при statusBars `[0,0][1080,136]`. Jest, своя мера: обёртка на first-run несёт ровно 47 или 59. К7 ×2 зелёные, мутанты `badge-*` в матрице красят ровно `DEMO_BADGE_INSET_{DARK,LIGHT}` | OK |
| Батарея | static / behavioral | `static 16/16` STATIC_RC=0, `honest 19/19` PROBE_RC=0, 35 строк `case` | OK |
| Матрицы | M2 / M1 | M2: 15 строк `mutant`, SMATRIX_RC=0. M1: 24 строки `mutant`, MATRIX_RC=0. Красные множества те же, что в круге 4. Своя мера ast: ключей `MUTANTS` 24 и 15; `it(` ×10, из них 9 двухсхемных, итого 19 клеток | OK |
| Регресс 995/999/108 | команды mobile.yml, `.harness` = H | CMP_995_OK; `--check-frozen` runs=1 mismatches=0; 11 проб 995 rc0; 4 пробы 999 rc0; 108 `static 22/22` и `honest 336/336`, rc0 | OK |
| npm | test / lint / typecheck | `Tests: 14 passed` RC_test=0, RC_lint=0, RC_typecheck=0 | OK |
| Область | pilot-app.tsx + mobile.yml | `git diff --stat 2eee68dd 91da6487`: ровно 2 файла. В mobile.yml вне комментариев изменены только 2 строки `ref:` (52a534e51). Дельта r5 к принятому в круге 4: `git diff ae0ec97d 7ee77076` пуст, `7ee77076..91da6487` затрагивает только pilot-app.tsx, +7 −1. Вне комментариев изменена одна строка: условие `frame === 'first-run'` | OK |
| Атомарность | — | 91da6487 = один предмет (С11), ссылка «111 r5 (С11)». 7ee77076 = числа и пин: связка круга 4 схлопнута, С13 закрыт. Автор у всех трёх `implementer` | OK |
| Проверки не переписаны | — | В дифе 2eee68dd..91da6487 нет файлов батареи и тестов. `pilot.test.tsx` и `source.json` совпадают с H по `cmp` | OK |
| Норма | — | Нормативных документов в дифе нет | OK |
| Числа в mobile.yml | своя мера | Комментарии «16/16 + 19/19, матрица 15+24» и пин 52a534e51 совпадают с замером | OK |

## Советы (не блокируют) — подробно в review.md

- **С15** (architect): ни одна клетка батареи не держит С11. Форма до r5 проходит 16/16 + 19/19. Это класс
  «охват RESTYLE_GUARD_995», принятый остаточный риск.
- **И1** (владелец, вне 111): на кадрах 995 бейдж заходит под статус-бар на 10 px, так же было на базе 16eb708a.
- **И2**: welcome на устройстве недостижим, судится Jest.

## Контракт 050: паразитная сложность (артефакты дифа r5)

| Артефакт | (1) свойство | (2) состояние | (3) сопряжённые правки | (4) глубина | (5) потребитель | Класс |
|---|---|---|---|---|---|---|
| условие `frame === 'first-run' ? insets.top : 0` у обёртки бейджа | стр. 41–42/80–83 (995 не рестайлятся) + R1 (бейдж под инсетом на First-Run) | нет, чистая функция `frame` и `insets` | 1 файл, число не выросло | одно выражение | К7 ×2, устройство (С11) | ESSENTIAL |
| комментарий r5 в pilot-app.tsx | — | нет | 1 | — | нет | нейтрально |

Новых скриптов, функций, флагов, env-переменных и файлов состояния в продукте нет.

---

## Сырой вывод (отдельно от диагноза)

```
$ git -C Impl111/mob log --oneline -3 ; git status --short | wc -l
91da6487 111 r5 (С11): инсет Demo-бейджа только на кадре first-run — кадры 995 не сдвигаются на top-инсет
7ee77076 111 r4: числа батареи (19/19, матрица 24) + H-перепин на 52a534e5 в mobile.yml
2eee68dd 111 r4 (P2, контрольная форма ревьюера): root условный по кадру
0
$ git diff --stat 2eee68dd 91da6487
 .github/workflows/mobile.yml       | 41 +++++++++++++++++++++++---------------
 mobile/src/bootstrap/pilot-app.tsx |  8 +++++++-
$ git diff -U0 2eee68dd 91da6487 -- .github/workflows/mobile.yml | non-comment
-          ref: be6b3d6573d6815bb39cb63cbcce61a63d12d459   (×2)
+          ref: 52a534e51a1c99b40c190f24c625036ce4a78999   (×2)
$ git diff -U0 7ee77076 91da6487 | non-comment
-        <View style={{ paddingTop: insets.top }}>
+        <View style={{ paddingTop: frame === 'first-run' ? insets.top : 0 }}>
$ git diff --stat ae0ec97d 7ee77076 ; echo RC_diff=$?
RC_diff=0            (пусто)

# APK: bash build_apk.sh (prebuild + ./gradlew --offline assembleRelease -PreactNativeArchitectures=x86_64)
91da6487b8351a6d8b9a5bb956f7364ea8fdacec
PREBUILD_RC=0
Android Bundled 3236ms node_modules/expo-router/entry.js (1259 modules)
BUILD SUCCESSFUL in 1m 36s
GRADLE_RC=0
016c94d5ec03a75da8f6f7929c50adb96888a666e4d0e586386ea0989737de76  app/build/outputs/apk/release/app-release.apk
# BASE: bash build_base.sh (16eb708a)
16eb708a27f7127920803dac537be7eddac5ae54
PREBUILD_RC=0 ; BUILD SUCCESSFUL in 1m 31s ; GRADLE_RC=0
3bc741876c9c6898057c8959874d7665de894e92139b615476e4f1f1eb526890  app/build/outputs/apk/release/app-release.apk

# устройство: python3 device.py <APK OBJECT> obj   (emulator-5632, complior_api36 -read-only)
RC_install 0 ; RC_launch 0
InsetsSource id=d3ba0000 type=statusBars frame=[0,0][1080,136] visible=true
== first-run
'com.complior.mobile:id/action_bar_root' [0,0][1080,2400] [('#0A0A0A', 2449814), ('#D6F75A', 70754)]
'demo-indicator' android.view.ViewGroup [0,136][137,200] [('#F2F2F2', 7638), ('#444444', 571)]
'first-run-safe-area' android.view.ViewGroup [0,232][1080,2400] [('#0A0A0A', 2212468), ('#D6F75A', 70754)]
'first-run-continue' android.widget.Button [0,814][687,934]
px (5,300) (1075,300) (5,1200) (1075,1200) (540,2395) (1075,2395) = #0A0A0A
below-statusbar top colors [('#0A0A0A', 0.9437), ('#D6F75A', 0.0289), ('#F2F1EC', 0.0143)]
tap first-run-continue RC_tap=0
== f0301
'com.complior.mobile:id/action_bar_root' [0,0][1080,2400] [('#FFFFFF', 2444381), ('#111111', 119728)]
'demo-indicator' android.view.ViewGroup [42,126][179,190] [('#F2F2F2', 7613), ('#444444', 500)]
'Anmelden oder Konto erstellen' android.view.View [42,222][1038,300] [('#FFFFFF', 62296), ('#111111', 10473)]
'auth-email' android.widget.EditText [42,331][1038,446]
'auth-demo-entry' android.widget.Button [42,478][1038,619] [('#111111', 109255), ('#FFFFFF', 26496)]
px … = #FFFFFF ; below-statusbar top colors [('#FFFFFF', 0.9402), ('#111111', 0.049), ('#F2F2F2', 0.0026)]
tap auth-demo-entry RC_tap=0
== code (F03.02)
'Kontakt bestätigen' android.view.View [42,222][1038,300] [('#FFFFFF', 67411), ('#111111', 6888)]
'auth-code' android.widget.EditText [42,331][1038,446] ; 'auth-verify' [42,478][1038,619] ; px … = #FFFFFF
tap auth-no-access RC_tap=0
== recovery (F03.04)
'F03.04' android.view.ViewGroup [42,222][1038,649] [('#FFFFFF', 284478), ('#111111', 121106)]
'Zugang wiederherstellen' android.view.View [42,222][1038,300] ; 'auth-recover' [42,426][1038,567] ; px … = #FFFFFF

# устройство: python3 device.py <APK BASE 16eb708a> base
== first-run (база: кадра нет, стартовый экран 995 с 'Weiter')
'demo-indicator' [42,126][179,190] ; 'first-run-continue' 'Weiter' [416,1225][664,1355]
== f0301
'demo-indicator' android.view.ViewGroup [42,126][179,190] [('#F2F2F2', 7613), ('#444444', 500)]
'Anmelden oder Konto erstellen' android.view.View [42,222][1038,300] [('#FFFFFF', 62296), ('#111111', 10473)]
'auth-email' [42,331][1038,446] ; 'auth-demo-entry' [42,478][1038,619]
== code: 'Kontakt bestätigen' [42,222][1038,300] ; == recovery: 'F03.04' [42,222][1038,649]

$ python3 pixdiff.py      (база 16eb708a против OBJECT, y ≥ 136)
f0301 size (1080, 2400) (1080, 2400) diff-pixels-below-statusbar 0 bbox None
code size (1080, 2400) (1080, 2400) diff-pixels-below-statusbar 0 bbox None
recovery size (1080, 2400) (1080, 2400) diff-pixels-below-statusbar 0 bbox None

# MX: npx jest src/bootstrap/__tests__/c11_r5.test.tsx  (своя мера, одноразово в копии MX)
C11 dark top=47 {"first-run.wrapper":47,"F03.01.wrapper":0,"F03.01.insetInTree":false,"code.wrapper":0,"code.insetInTree":false,"recovery.wrapper":0,"recovery.insetInTree":false,"welcome.badge":false,"welcome.insetInTree":false}
C11 dark top=59 {"first-run.wrapper":59,"F03.01.wrapper":0,…,"welcome.insetInTree":false}
C11 light top=47 {"first-run.wrapper":47,"F03.01.wrapper":0,…}   C11 light top=59 {"first-run.wrapper":59,"F03.01.wrapper":0,…}
Tests:       4 passed, 4 total
RC_c11_obj=0
# MX: git checkout 7ee77076 -- mobile/src/bootstrap/pilot-app.tsx (форма до r5)
C11 dark top=47 {"first-run.wrapper":47,"F03.01.wrapper":47,"F03.01.insetInTree":true,"code.wrapper":47,"code.insetInTree":true,"recovery.wrapper":47,"recovery.insetInTree":true,"welcome.badge":false,"welcome.insetInTree":false}
(…dark 59 / light 47 / light 59 — то же с 59/47/59)
Tests:       4 failed, 4 total
RC_c11_pre_r5=1
# MX: bash probes.sh MX honest (форма до r5) — батарея С11 не держит (С15)
static 16/16  STATIC_RC=0 ; honest 19/19  PROBE_RC=0

# C: bash probes.sh C honest  (OBJECT)
91da6487b8351a6d8b9a5bb956f7364ea8fdacec
case SPLASH_GROUND_DARK … case STATIC_ORACLE_LITERALS          (16 строк case)
static 16/16
STATIC_RC=0
case CTA_OPENS_F03_01_DARK … case WORDMARK_SOURCE_BOUND_LIGHT  (19 строк case, в т. ч. DEMO_BADGE_INSET_{DARK,LIGHT},
     FIRST_RUN_GROUND_FULL_SURFACE_{DARK,LIGHT}, RESTYLE_GUARD_995_{F03_01,WELCOME}_{DARK,LIGHT})
honest 19/19
PROBE_RC=0
STATUS_END      (0 строк)

# M1: bash probes.sh M1 matrix-beh   — 24 строки mutant, red-множества = круг 4
mutant badge-outside-safearea red= ['DEMO_BADGE_INSET_DARK', 'DEMO_BADGE_INSET_LIGHT']
mutant badge-inset-top-zero red= ['DEMO_BADGE_INSET_DARK', 'DEMO_BADGE_INSET_LIGHT']
mutant badge-hardcoded-inset red= ['DEMO_BADGE_INSET_DARK', 'DEMO_BADGE_INSET_LIGHT']
mutant restyle-995-ground red= ['FIRST_RUN_GROUND_FULL_SURFACE_DARK', 'FIRST_RUN_GROUND_FULL_SURFACE_LIGHT', 'RESTYLE_GUARD_995_F03_01_DARK', 'RESTYLE_GUARD_995_F03_01_LIGHT', 'RESTYLE_GUARD_995_WELCOME_DARK', 'RESTYLE_GUARD_995_WELCOME_LIGHT']
… (остальные 20 строк дословно как в круге 4)
MATRIX_RC=0
STATUS_END      (0 строк)
# M2: bash probes.sh M2 matrix-static — 15 строк mutant
mutant wordmark-opaque-one-transparent red= ['WORDMARK_ASSET_IDENTITY'] ; wordmark-recolored-ink / wordmark-recompressed red= ['WORDMARK_ASSET_IDENTITY'] …
SMATRIX_RC=0
STATUS_END      (0 строк)
# своя мера чисел: python3 count_cells.py
first_run_probe.py MUTANTS keys 24
first_run_static_probe.py MUTANTS keys 15
it( 10 two-scheme 9 cells 19

# R995: bash regress.sh (команды mobile.yml, .harness = H 52a534e51)
91da6487b8351a6d8b9a5bb956f7364ea8fdacec
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
STATUS_END      (0 строк)
```

Воспроизведение: `bash Rev111r5/build_apk.sh`, `bash Rev111r5/build_base.sh`,
`python3 Rev111r5/device.py <APK> {obj|base}`, `python3 Rev111r5/pixdiff.py`,
`bash Rev111r5/probes.sh {C honest|M1 matrix-beh|M2 matrix-static|MX honest}`, `bash Rev111r5/regress.sh`,
`python3 Rev111r5/count_cells.py`, `Rev111r5/c11_r5.test.tsx` (класть в копию `mobile/src/bootstrap/__tests__/`).
Эмулятор: `ANDROID_AVD_HOME=/home/harness/.android/avd sg kvm -c "emulator -avd complior_api36 -read-only -port 5632 -no-window -no-audio"`.
Снимки: `Rev111r5/{obj,base}-{first-run,f0301,code,recovery}.{png,xml}`.
