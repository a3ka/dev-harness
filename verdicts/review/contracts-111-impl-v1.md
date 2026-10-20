FAIL
OBJECT=cec116cd42f4f927ace694180134ef16a51e67a7

# Суд реализации контракта 111 (mob First-Run D2.2.5.1) — reviewer Rev111, круг 1

Контракт: `frozen/contracts/111/1^{commit}` = `2f6ebcf592a937a367d8e80449c077c5b268a494`.
Батарея H = `0a991ebcdca9faf452f8906b6302971c268dedad` (fixtures first_run_111/pilot_995/nav_999/start_108
побайтово равны тегу 2f6ebcf и, для 995/999/108, прежнему пину 98d837eb9 — `git diff --stat` пуст).
База B = `16eb708a27f7127920803dac537be7eddac5ae54`. Находки reslop-формата: `review.md` (та же папка).
Все прогоны — на `cp -a`-копиях `/tmp/dev-harness-verify/Rev111/R1..R4` клона Impl111/mob (HEAD=cec116cd, clean).

## Таблица по инвариантам (замер своей мерой)

| # | Инвариант | Замер | Итог |
|---|-----------|-------|------|
| 1 | first-run-screen.tsx: props-only `onEnter`(+testID), палитра через useTheme, без hex, SafeAreaView без edges (4 края) | чтение файла C: `useTheme()`, `tokens.ground/ink`, hex-литералов нет, `<SafeAreaView>` из `react-native-safe-area-context` без `edges`; клетки SCREEN_NO_HEX_LITERALS, SCREEN_SAFEAREA_COMPONENT, SAFEAREA_EDGES_ACTIVE_{DARK,LIGHT} зелёные | OK |
| 2 | testID `first-run-continue` на CTA; нажатие → F03.01 в обеих схемах | CTA_OPENS_F03_01_{DARK,LIGHT}, CTA_TESTID_BOUND зелёные; 995 pilot.test.tsx 14/14 в `npm test`; `cmp` с H — OK | OK |
| 3 | CTA/promise байт-в-байт, видимый текст ⊆ {Demo, promise, CTA} | FIRST_RUN_COPY_CLOSED_{DARK,LIGHT}, CTA_TEXT_EQUALS_FRAME_TITLE зелёные; в экране нет саблайнов | OK |
| 4 | ui-copy.ts +2 ключа verbatim | диф: ровно 2 строки ключей `ui.first_run.promise`/`enter_f03` с review_status `UX_EDITORIAL_REVIEWED; NATIVE_RELEASE_SIGNOFF_REQUIRED`; COPY_KEY_* зелёные; 999 copy_probe rc0 | OK |
| 5 | splash `#0A0A0A`, эффективно android+ios, image/imageWidth неизменны, `#208AEF` удалён | диф app.json: одна строка `#208AEF`→`#0A0A0A`; SPLASH_* ×3 зелёные (резолверы expo-splash-screen) | OK |
| 6 | Wordmark — растр `wordmark-dark.png`, **растеризованный из logo/ wordmark-dark.svg**, label «complior», role image, высота 22, source экрана на ассет | label/role/height/source — OK (К4 ×2). **Сам ассет — не растр бренда и не декодируется**: sha256 `7f4f1010…9248` = модель батареи `model/wordmark-dark.png`; IHDR 8×44 grayscale при IDAT 1100 байт RGB-данных (44 строки × 8 пикселей `#f2f1ec`) — сплошной прямоугольник, к тому же битый; Pillow: `OSError unrecognized data stream`; pngjs: `Unrecognised filter type - 236`; aapt2 compile (crunch) rc=139; `gradlew :app:mergeReleaseResources` rc=1 | **FAIL — Б1** |
| 7 | Demo-бейдж `demo-indicator` на First-Run, одна метка | pilot-app: бейдж рендерится при `frame !== 'welcome'`, FirstRunScreen второй метки не несёт; FIRST_RUN_STRUCTURE_{DARK,LIGHT} зелёные | OK |
| 8 | dark/light: контейнер на tokens.ground, promise на tokens.ink | FIRST_RUN_STRUCTURE_{DARK,LIGHT} зелёные (контейнер SafeAreaView) | OK (см. совет С2 про белую рамку root) |
| Приёмка | B без реализации → rc1 FIRST_RUN_SEAM_ABSENT ×2 | R2 на 16eb708: обе пробы rc1 `FIRST_RUN_SEAM_ABSENT` | OK (красное предъявлено) |
| Приёмка | C: 11/11 + 14/14 | R1: `honest 11/11` rc0 (11 строк `case`), `static 14/14` rc0 (14 строк `case`) | OK |
| Приёмка | `--matrix` rc0, 14+9 стабов, побочная краснота только в depends | R3: 14 строк `mutant`, MATRIX_RC=0; R4: 9 строк `mutant`, SMATRIX_RC=0 | OK |
| Приёмка | `git status` после проб = 0 строк | R1, R3, R4: пусто между командой и маркером `STATUS_LINES_END` | OK |
| Приёмка | lint/typecheck/test; 995/999 без правок проб | R1/mobile: RC_test=0 (14 passed), RC_lint=0, RC_typecheck=0; R2 c `.harness`=H: все 11 проб 995 rc0, 4 пробы 999 rc0, 108 `static 22/22` + `honest 336/336` rc0 | OK |
| Приёмка | `gh pr checks --required` rc0 **включая android-e2e** (assembleRelease) | C не запушен — CI не наблюдаем. Локально тот же путь сборки: `expo prebuild` + `gradlew :app:mergeReleaseResources` → **rc1** `AAPT2 … Unexpected error during compile '…/drawable-mdpi/assets_images_wordmarkdark.png'`; контроль с честным растром → rc0 | **FAIL — Б1** (android-e2e не может быть зелёным на C) |

## Гейт-проверки ревьюера

1. **Область правки** — дифф B..C: ровно 6 файлов, все из ЗОНЫ implementer frozen-блоба
   (`.github/workflows/mobile.yml`, `mobile/app.json`, `mobile/assets/images/wordmark-dark.png`,
   `mobile/src/bootstrap/pilot-app.tsx`, `mobile/src/features/auth/first-run-screen.tsx`,
   `mobile/src/i18n/ui-copy.ts`). `git diff --quiet B C -- mobile/src/bootstrap/__tests__ mobile/.maestro
   mobile/src/theme mobile/src/ui docs` → rc0. OK.
2. **Сырой вывод** — собственный (ниже). Отчёт implementer не использован как доказательство.
3. **Проверки не переписаны** — пробы берутся из H (не из дерева продукта); 995 pilot.test.tsx/source.json
   `cmp` с H — равны; дифф C не трогает `__tests__`. OK. Обратное направление — реализация списана с
   модели батареи (см. С1).
4. **Красное предъявлено** — на B обе пробы rc1 `FIRST_RUN_SEAM_ABSENT`; матрицы красят каждый стаб. OK.
5. **Атомарность** — один коммит `cec116cd`, автор `implementer`, ссылка «111 (CMP-MOB-005)». OK.
6. **Норма не тронута** — нормативных документов в диффе нет. OK.
7. **Заявленное = сделанное** — 11/11, 14/14, 14+9, 14 passed, 6 файлов — подтверждено своей мерой.
   **Не подтверждено**: тело коммита «wordmark-dark.png (ассет, растеризован из logo/)» — ассет байт-равен
   модели батареи (sha256 совпал) и растром SVG не является (Б1).
8. **mobile.yml** — перепин `ref:` 98d837eb9→0a991ebcd в обоих checkout (quality, android-e2e), как в
   прецеденте b669cef; новый шаг 111 вставлен после шага 108 и до `npm test/lint/typecheck/doctor`, на
   disposable R, обе пробы. Шаги 995/999/108 (name/run) в диффе не встречаются — дословно сохранены;
   меняются только общий комментарий перед checkout и комментарий android-e2e. OK.

## Блокирующие находки

### Б1 — wordmark-ассет: заглушка батареи вместо растра бренда; битый PNG ломает release-сборку (инв. 6; приёмка android-e2e; заявленное ≠ сделанное)

- Фрагмент: `mobile/assets/images/wordmark-dark.png` (82 байта, sha256 `7f4f1010e77a8fb1acefd79a0b85d0bc12d71c4599a716244a3efb461b069248`
  = `fixtures/workshop_project/first_run_111/model/wordmark-dark.png` H). Обязательство инв. 6: «растеризованный
  из семьи logo/ D2.2.5.1 (wordmark-dark.svg)». Наблюдение: IHDR `8×44, depth 8, colortype 0` при
  декомпрессированных данных 1100 байт = 44 × (1 + 8×3) — RGB-сплошняк `#f2f1ec`; глифов «complior» нет,
  файл не декодируется ни одним декодером.
- **ОБХОД**: клетка `WORDMARK_ASSET` проверяет только `blob.startswith(b'\x89PNG…')` (static_probe.py:152),
  а в Jest ассет замокан — поэтому копия заглушки модели даёт 14/14 + 11/11, а предмет «wordmark по D2.2.5.1»
  не сделан. Батарея прямо называет пиксели wordmark зоной reviewer («НЕ ЗАЩИЩАЕТ: визуальная точность
  wordmark … ловец reviewer на C»).
- **Воспроизведение** (R3 = cp -a C):
  `npx expo prebuild --platform android --no-install` → rc0;
  `env ANDROID_HOME=/opt/android-sdk ./gradlew --no-daemon --offline :app:mergeReleaseResources -PreactNativeArchitectures=x86_64`
  → `RC=1`, `AAPT2 aapt2-8.12.0-13700139-linux Daemon #0: Unexpected error during compile
  '…/build/generated/res/react/release/drawable-mdpi/assets_images_wordmarkdark.png'`.
  CI android-e2e исполняет `./gradlew assembleRelease` (mobile.yml:191), в шаблоне prebuild `crunchPngs`
  = true для release (`android.enablePngCrunchInReleaseBuilds=true`) → требуемая строка приёмки
  «gh pr checks --required rc0, включая android-e2e» на C недостижима [INFERENCE: CI-раннер исполняет тот
  же AGP/aapt2; локально измерено на buildTools 36.0.0, aapt2 35.0.0 тоже rc=139].
- **Контроль (более простая форма, проходящая те же строки)**: растр того же SVG через установленный
  `/usr/bin/google-chrome --headless=new --default-background-color=00000000 --force-device-scale-factor=3
  --window-size=143,53 --screenshot=… file://…/logo/assets/complior-wordmark-dark.svg` → RGBA 429×159,
  Pillow декодирует, aapt2 compile rc0; подложен в R4 → `static 14/14` rc0, `honest 11/11` rc0;
  подложен в R3 → `mergeReleaseResources --rerun-tasks` rc0.
- Допустимо считать предметом (предложение к починке): PNG RGBA с прозрачным фоном, растеризованный из
  `logo/assets/complior-wordmark-dark.svg` (sha256 `e0f2ef4f…e4bf`, байт-равен `screens/html/ds/wordmark-dark.svg`),
  декодируемый стандартным декодером (Pillow/pngjs/aapt2), высота глифов при отображении 22 pt; желательно
  @2x/@3x. «Растеризатора на станции нет» — неверно: Chrome headless есть и измерен. Команда растеризации
  — в тело коммита (воспроизводимость).

## Советы (не блокируют)

- **С1 (процесс)**: `first-run-screen.tsx` побайтово равен `model/features.auth.first-run-screen.tsx`, `app.json` —
  `model/app.json`, `pilot-app.tsx` отличается от модели одним комментарием. Реализация списана с эталонной
  модели батареи; так и унаследована заглушка-ассет. Не запрещено контрактом, но тогда батарея проверяет сама
  себя — судьям сверять предмет с эталоном D2.2.5.1, не с моделью.
- **С2 (визуал, вопрос владельцу/architect)**: `PilotApp` root (`paddingTop: 48`, `paddingHorizontal: 16`,
  `paddingBottom: 16`, `backgroundColor: '#FFFFFF'`) оборачивает FirstRunScreen; Demo-бейдж на сером
  `#F2F2F2` в белой полосе над тёмным экраном. Эталон First-Run.png — тёмный full-bleed. Инв. 8 буквально
  выполнен (контейнер экрана на ground), модель батареи такая же — замороженное обязательство не нарушено;
  ожидаемая визуальная рамка [INFERENCE по стилям, рендера на устройстве нет]. Кандидат на правку root для
  кадра first-run или на уточнение контракта.
- **С3 (контракт, architect)**: инв. 6/К4 требуют `wordmark-dark.png` в ОБЕИХ схемах; в light ink
  `#f2f1ec` на ground `#f3f2ee` — wordmark невидим. Семья logo/ несёт `wordmark-light.svg`. Вопрос на
  следующую редакцию контракта.
- **С4 (батарея, architect)**: `WORDMARK_ASSET` проверяет лишь магию; заглушка модели битая. Для следующей
  редакции — декодирование (IHDR/IDAT согласованы, размер > порога) или сравнение с растром SVG.
- **С5**: стиль `wordmark` задаёт только `height: 22` без `width`/`aspectRatio` — при честном растре ширина
  возьмётся из intrinsic-размера ассета [INFERENCE]; задать aspectRatio 143/52.08 (или width).
- **С6**: комментарий в pilot-app.tsx «legacy «Weiter»-константа и стили убраны…» — надгробие удалённого кода,
  убрать. Комментарий шага 108 в mobile.yml по-прежнему называет пин 98d837eb9 (шаг сохранён дословно по
  норме — устаревший комментарий наследуется; не трогать без решения оркестратора).

## Контракт 050 — паразитная сложность (по артефактам диффа)

| Артефакт | (1) свойство | (2) состояние | (3) сопряжённые правки | (4) глубина | (5) потребитель | Класс |
|---|---|---|---|---|---|---|
| `features/auth/first-run-screen.tsx` | инв. 1–3, 6–8, шов | нет (props `onEnter`, `testID?`) | 1 (экран) + pilot-app вызов — не выросло | интерфейс 2 props, работа — весь кадр | обе пробы 111 | ESSENTIAL |
| `assets/images/wordmark-dark.png` | инв. 6 | файл | 1 | — | WORDMARK_ASSET, К4 | ESSENTIAL (содержимое — Б1) |
| 2 ключа `ui-copy.ts` | инв. 4 | нет | 1 | — | COPY_KEY_*, 999 copy_probe | ESSENTIAL |
| `app.json` backgroundColor | инв. 5 | нет | 1 | — | SPLASH_* | ESSENTIAL |
| шаг quality 111 в mobile.yml | «Пины и порядок поставки» | `/tmp/dev-harness-verify/impl111-r-<run>` явно в run | 1 (шаг) + ref-пин — как у 108 | 2 команды | строка приёмки CI | ESSENTIAL |

Новых флагов/env/функций сверх названного нет.

---

## Сырой вывод (отдельно от диагноза)

```
$ git diff --stat 16eb708a27 cec116cd42
 .github/workflows/mobile.yml                  |  51 +++++++++++++++-------
 mobile/app.json                               |   2 +-
 mobile/assets/images/wordmark-dark.png        | Bin 0 -> 82 bytes
 mobile/src/bootstrap/pilot-app.tsx            |  30 +++----------
 mobile/src/features/auth/first-run-screen.tsx |  59 ++++++++++++++++++++++++++
 mobile/src/i18n/ui-copy.ts                    |   3 ++
 6 files changed, 104 insertions(+), 41 deletions(-)
cec116cd42f4f927ace694180134ef16a51e67a7 implementer implementer@dev-harness.local 111 (CMP-MOB-005): …

$ git -C /home/harness/dev-harness diff --stat 2f6ebcf592 0a991ebcd -- fixtures/…first_run_111 pilot_995 nav_999 start_108 contracts/111-…   (пусто)
$ git -C /home/harness/dev-harness diff --stat 98d837eb9 0a991ebcd -- fixtures/…pilot_995 nav_999 start_108                             (пусто)

# R2 @ B=16eb708 (красное)
FIRST_RUN_SEAM_ABSENT
PROBE_RC_on_B=1
FIRST_RUN_SEAM_ABSENT
STATIC_RC_on_B=1

# R1 @ C — честный прогон
case CTA_OPENS_F03_01_DARK / CTA_OPENS_F03_01_LIGHT / CTA_TEXT_EQUALS_FRAME_TITLE / FIRST_RUN_COPY_CLOSED_DARK /
case FIRST_RUN_COPY_CLOSED_LIGHT / FIRST_RUN_STRUCTURE_DARK / FIRST_RUN_STRUCTURE_LIGHT / SAFEAREA_EDGES_ACTIVE_DARK /
case SAFEAREA_EDGES_ACTIVE_LIGHT / WORDMARK_SOURCE_BOUND_DARK / WORDMARK_SOURCE_BOUND_LIGHT     (11 строк case)
honest 11/11
PROBE_RC=0
case SPLASH_GROUND_DARK … STATIC_ORACLE_LITERALS                                                   (14 строк case)
static 14/14
STATIC_RC=0
STATUS_LINES_END        (git status --short --untracked-files=all: 0 строк)

# R3 @ C — first_run_probe.py --matrix
mutant cta-label-weiter red= ['CTA_TEXT_EQUALS_FRAME_TITLE', 'FIRST_RUN_COPY_CLOSED_DARK', 'FIRST_RUN_COPY_CLOSED_LIGHT', 'FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT']
mutant promise-invented red= ['FIRST_RUN_COPY_CLOSED_DARK', 'FIRST_RUN_COPY_CLOSED_LIGHT', 'FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT']
mutant onenter-not-wired red= ['CTA_OPENS_F03_01_DARK', 'CTA_OPENS_F03_01_LIGHT', 'CTA_TEXT_EQUALS_FRAME_TITLE']
mutant ground-default-blue red= ['FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT']
mutant demo-badge-scope red= ['FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT']
mutant wordmark-absent red= ['FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT', 'WORDMARK_SOURCE_BOUND_DARK', 'WORDMARK_SOURCE_BOUND_LIGHT']
mutant cta-testid-renamed red= ['CTA_OPENS_F03_01_DARK', 'CTA_OPENS_F03_01_LIGHT', 'CTA_TEXT_EQUALS_FRAME_TITLE', 'FIRST_RUN_STRUCTURE_DARK', 'FIRST_RUN_STRUCTURE_LIGHT']
mutant light-cta-noop red= ['CTA_OPENS_F03_01_LIGHT']
mutant safearea-edges-empty red= ['SAFEAREA_EDGES_ACTIVE_DARK', 'SAFEAREA_EDGES_ACTIVE_LIGHT']
mutant wordmark-wrong-source red= ['WORDMARK_SOURCE_BOUND_DARK', 'WORDMARK_SOURCE_BOUND_LIGHT']
mutant extra-unreviewed-copy red= ['FIRST_RUN_COPY_CLOSED_DARK', 'FIRST_RUN_COPY_CLOSED_LIGHT']
mutant light-edges-top-bottom red= ['SAFEAREA_EDGES_ACTIVE_LIGHT']
mutant light-wrong-source red= ['WORDMARK_SOURCE_BOUND_LIGHT']
mutant light-extra-copy red= ['FIRST_RUN_COPY_CLOSED_LIGHT']
MATRIX_RC=0
STATUS_LINES_END

# R4 @ C — first_run_static_probe.py --matrix
mutant splash-stays-default-blue red= ['SPLASH_DEFAULT_BLUE_GONE', 'SPLASH_EFFECTIVE_GROUND_BOTH', 'SPLASH_GROUND_DARK']
mutant android-splash-blue red= ['SPLASH_EFFECTIVE_GROUND_BOTH']
mutant copy-promise-invented red= ['COPY_KEY_ui_first_run_promise']
mutant copy-enter-missing red= ['COPY_KEY_ui_first_run_enter_f03']
mutant screen-hex-literal red= ['SCREEN_NO_HEX_LITERALS']
mutant pilot-unwired red= ['PILOT_WIRED_FIRST_RUN']
mutant wordmark-missing red= ['WORDMARK_ASSET']
mutant cta-testid-unbound red= ['CTA_TESTID_BOUND']
mutant screen-plain-view red= ['SCREEN_SAFEAREA_COMPONENT']
SMATRIX_RC=0
STATUS_LINES_END

# R1/mobile
Tests:       14 passed, 14 total
RC_test=0
structure: OK (repository inventory; external trees excluded)
RC_lint=0
RC_typecheck=0

# R2 (C, .harness=H) — frozen 995/999/108 по командам mobile.yml
RC_probe=0 RC_runtime_probe=0 RC_bundle_probe=0 RC_schema_probe=0 RC_frozen_matrix=0 RC_transport_probe=0
RC_admission_probe=0 RC_stale_probe=0 RC_types_probe=0 RC_pins_probe=0 RC_admission_family_probe=0 RC_stale_table_probe=0
RC_nav_probe=0 RC_ui_probe=0 RC_shell_static_probe=0 RC_copy_probe=0
static 22/22  RC_start_static_probe=0
honest 336/336  RC_start_probe=0
cmp pilot.test.tsx/source.json с H → CMP_995_OK

# wordmark-ассет
sha256 7f4f1010e77a8fb1acefd79a0b85d0bc12d71c4599a716244a3efb461b069248  mobile/assets/images/wordmark-dark.png
sha256 7f4f1010e77a8fb1acefd79a0b85d0bc12d71c4599a716244a3efb461b069248  H/…/first_run_111/model/wordmark-dark.png
od: 89504e47… IHDR 00000008 0000002c 08 00 …  IDAT 25 байт → zlib 1100 байт, значения {0, 236, 241, 242}
Pillow 10.2.0: header PNG L (8, 44); DECODE_ERROR OSError unrecognized data stream contents when reading image file
pngjs: DECODE_ERROR Unrecognised filter type - 236
(контроль splash-icon.png: Pillow RGBA 228×213, pngjs 228×213 — декодируются)
aapt2 35.0.0 compile: RC=139; aapt2 36.0.0 compile: RC=139; aapt2 36.0.0 --no-crunch: RC=0
npx expo export:embed --platform android --dev false … → RC_embed=0; 82 …/res/drawable-mdpi/assets_images_wordmarkdark.png

# R3: release-ресурсы
npx expo prebuild --platform android --no-install → RC_prebuild=0
gradlew :app:mergeReleaseResources (C):
  > Task :app:mergeReleaseResources FAILED — AAPT2 aapt2-8.12.0-13700139-linux Daemon #0: Unexpected error during compile
    '/tmp/dev-harness-verify/Rev111/R3/mobile/android/app/build/generated/res/react/release/drawable-mdpi/assets_images_wordmarkdark.png'
  RC_gradle_mergeReleaseResources=1
gradlew :app:mergeReleaseResources (C + chrome-растр, БЕЗ --rerun-tasks): RC=1 — в generated/res остался прежний файл 82 байта (bundle-задача up-to-date; ls подтвердил 82 байта) — прогон не засчитан
gradlew :app:mergeReleaseResources --rerun-tasks (C + wordmark = chrome-растр SVG, 10502 байт):
  RC_gradle_mergeReleaseResources_realraster=0

# R4: батарея с честным растром
static 14/14  STATIC_RC_realraster=0
honest 11/11  PROBE_RC_realraster=0
```
