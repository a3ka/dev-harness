accept
OBJECT=8eb8d4babeb0ee8147656c6f80c6ee280c99bfe9

# Ревью реализации 135 first-run-ekran — PR a3ka/Complior-mob#121 (круг 2)

Судья: reviewer (Rev135b), другая сессия, чем Rev135 круга 1. Вердикт круга 1:
`orch/keep135/contracts-135-impl.md` (FAIL, один блокер R135-B1), находки — `orch/keep135/2026-10-24-01.md`.
Предмет круга 2 — коммит `8eb8d4ba` «каретка поля не остаётся в кадре (R135-B1)» и регрессии
от него. Заново я судил только это. Остальное по кругу 1 не пересуживал.

**Блокеров: 0.** Ниже доказано пикселями, тестом и прогонами, что R135-B1 закрыт. Регрессий в
зоне круга нет. Коллизии K1–K3 по решению оркестратора идут как вопросы владельцу. Новое
наблюдение K4 — тоже вопрос владельцу, не блокер. Файл `.review/` не заводился, потому что
блокеров нет.

Рабочая копия: `/tmp/dev-harness-verify/Rev135b/mob` (это `cp -a` клона Impl135, HEAD == OBJECT).
Рядом лежат производные копии `mob-lint` (без `.harness` и `mobile/e2e-first-run`, как в шаге CI
«Вынести H…»), `mob-red` (для красного прогона и мутантов) и `mob-st` (для пробы stale_table).
H-пины я распаковал через `git archive` из основного репозитория харнесса: `Hc663`
(c663dd0f, пин `.harness`), `H135` (ca277b3a, пин `.harness135`), `H117` (8d3f48b8).

## 1. R135-B1 закрыт: каретки нет ни в одном из 8 кадров

### 1.1 Происхождение кадров

Кадры `orch/art12` по байтам совпадают с артефактом attempt 3 рана 40099110838 на OBJECT. Я
скачал его сам в `Rev135b/ci/a3`:
```
$ gh api repos/a3ka/Complior-mob/actions/runs/40099110838 --jq '{run_attempt,head_sha,conclusion}'
{"conclusion":"success","head_sha":"8eb8d4babeb0ee8147656c6f80c6ee280c99bfe9","run_attempt":3}
$ gh run download 40099110838 -n maestro-first-run-…-40099110838-3 -D Rev135b/ci/a3
$ cmp ci/a3/<тема>/…/first-run-ekran-<k>.png orch/art12/first-run/<тема>/…/first-run-ekran-<k>.png
CMP_OK dark/2026-10-24_141039 first-run | f03-01 | f03-02 | f03-02-v01
CMP_OK light/2026-10-24_141118 first-run | f03-01 | f03-02 | f03-02-v01      (8/8)
```

### 1.2 Пиксельный замер (`Rev135b/caret_measure.py`)

Меры:
- **A** — метод круга 1: бирюзовые пиксели G>100, B>90, R<80. Окно поля кода 60..1040 × 1040..1200,
  окно поля e-mail F03.01 сдвинуто на поле: 60..1040 × 1132..1290.
- **B** — своя мера, не зависит от цвета каретки. Тёмную каретку мера A могла бы не поймать,
  поэтому B смотрит на форму. Внутри поля берётся каждый пиксель, отличный от заливки больше
  чем на 60 по любому каналу. По каждому столбцу считается самая длинная вертикальная серия
  таких пикселей. Каретка даёт серию ≥ 70 px, точка маски — около 17 px, буквы плейсхолдера —
  не больше 36 px.
- **C** — цветные пиксели (max−min канала > 40) внутри поля.

Положительный контроль — кадр круга 1 с дефектом.
```
$ python3 caret_measure.py
kadr                     A_teal  teal_bbox            B_maxrun  B_col  C_color  fill
First-Run dark           0       -                    58        x672   0        (10,10,10)     ← поля нет, серия 58 — штрих заголовка
First-Run light          0       -                    57        x672   0        (243,242,238)  ← то же
F03.01 dark              0       -                    36        x276   0        (30,30,29)
F03.01 light             0       -                    36        x276   0        (230,229,223)
F03.02 dark              0       -                    17        x126   0        (30,30,29)
F03.02 light             0       -                    17        x126   0        (230,229,223)
F03.02-V01 dark          0       -                    17        x128   0        (30,30,29)
F03.02-V01 light         0       -                    17        x128   0        (230,229,223)
a1 F03.01 dark           0       -                    36        x276   0        (доп. выборка: attempt 1, dark)
a1 F03.02 dark           0       -                    17        x126   0
a1 F03.02-V01 dark       0       -                    17        x128   0
KONTROL art11 V01 light  450     x352-356,y1074-1163  90        x352   450      ← R135-B1 на eea0db8c
RC=0
```
Итог: во всех 8 кадрах OBJECT каретки нет — 0 пикселей по A, 0 по C, а самая длинная серия по B
не больше 36 px при пороге 70. Дополнительно проверены 3 кадра поля из attempt 1 (dark): там
тоже 0. На контрольном кадре круга 1 мера ловит дефект: A — 450 пикселей, B — серия 90 px. Это
те же числа, что дал круг 1.

### 1.3 Тест `auth-focus.test.tsx`: красный на eea0db8c и мутанты

Красный: в `mob-red` взял `auth-screen.tsx` из eea0db8c, файл теста оставил из HEAD.
```
$ git -C mob-red checkout eea0db8c -- mobile/src/features/auth/auth-screen.tsx
$ npx jest --ci --runInBand src/features/auth
FAIL src/features/auth/__tests__/auth-focus.test.tsx
  ● … F03.02: скрытая клавиатура снимает фокус с поля кода …   Expected: true  Received: false  (:107)
  ● … F03.02: кадр ошибки снимает фокус с поля кода …         Expected: true  Received: false  (:122)
  ● … F03.01: скрытая клавиатура снимает фокус с поля e-mail … Expected: true  Received: false  (:135)
Tests: 3 failed, 5 passed, 8 total       JEST_RED_RC=1
```
На eea0db8c все три теста краснеют уже на первом утверждении: prop `caretHidden` там просто
нет. Такой красный сам по себе доказывает только проводку. Поэтому я проверил переходы
состояния мутантами `auth-screen.tsx` HEAD (скрипт `Rev135b/mutants.sh`):
```
BASELINE HEAD                         ✓✓✓  Tests: 3 passed
M1 нет blur по invalid                ✓✕✓  Tests: 1 failed, 2 passed   (краснеет «кадр ошибки»)
M2 нет blur по keyboardDidHide        ✕✓✕  Tests: 2 failed, 1 passed   (краснеют оба «скрытая клавиатура»)
M3 blur без сброса состояния focused  ✕✕✕  Tests: 3 failed
M4 caretHidden={false}                ✕✕✕  Tests: 3 failed
```
Каждое из трёх свойств шва — снятие фокуса по скрытию клавиатуры, снятие по кадру ошибки и
«каретка только в фокусе» — краснеет своим мутантом. Тест проверяет свойство, а не тавтологию.
Пиксельное свойство «нет каретки в кадре» доказывает только устройство, см. п. 1.2 и совет
R135b-S1.

## 2. Регрессии круга

### 2.1 Зона, атомарность, автор
```
$ git diff --name-only eea0db8c..8eb8d4ba
mobile/src/features/auth/__tests__/auth-focus.test.tsx
mobile/src/features/auth/auth-screen.tsx                    ⊆ mobile/src/features/auth/  ✓
$ gh pr diff 121 -R a3ka/Complior-mob --name-only           → 18 файлов (17 круга 1 + auth-focus.test.tsx), все в ЗОНЕ
$ git log --format='%h %an <%ae> %s' origin/main..HEAD      → 8 коммитов, все implementer <implementer@dev-harness.local>, префикс «135:»
8eb8d4b implementer … 135: каретка поля не остаётся в кадре (R135-B1) — …    (один коммит на находку)
$ git diff --stat eea0db8c..8eb8d4ba -- mobile/e2e-first-run mobile/.maestro .github mobile/src/bootstrap  → пусто
```
Проверки и фикстуры автор в этом круге не трогал: изменены только продуктовый
`auth-screen.tsx` и новый тест. Норм и frozen-файлов в диффе нет.

### 2.2 Frozen-файлы против пинов H (`cmp`)
```
cmp mobile/src/bootstrap/__tests__/pilot.test.tsx ../Hc663/fixtures/workshop_project/pilot_995/pilot.test.tsx   PILOT_CMP=0
cmp mobile/src/bootstrap/__tests__/source.json    ../Hc663/fixtures/workshop_project/pilot_995/source.json      SOURCE_CMP=0
cmp mobile/e2e-first-run/batareja/proverka_proiskhozdenija.py ../H135/…/first_run_ekran_135/teksty/proverka_text.py  PROVERKA_CMP=0
cmp <(git show 5d98a1cd:scripts/sverka_maketa.py) H135/scripts/sverka_maketa.py   SVERKA_RUNNER_CMP_H123_H135=0
$ python3 ../Hc663/fixtures/workshop_project/pilot_995/stale_table_probe.py --repo …/Rev135b/mob-st
995 stale-table/995 table BEGIN_REBEGIN: rc=0 … LIVE_VERIFY_WELCOME: rc=0     (37 строк, все rc=0)
STALE_RC=0
```
По своей мере у пробы stale_table на пине c663dd0f **37** строк, все с rc=0. Круг 1 записал
«12/12». Мой счёт другой, но вывод тот же: регрессии нет.

### 2.3 tsc / jest / lint — сырой вывод
```
$ npx tsc --noEmit                                           (mob/mobile)        TSC_RC=0
$ npx jest --ci --runInBand                                  (mob/mobile)
PASS src/bootstrap/__tests__/pilot.test.tsx
PASS src/features/auth/__tests__/auth-code-input.test.tsx
PASS src/features/auth/__tests__/auth-focus.test.tsx
PASS src/features/auth/__tests__/auth-keyboard.test.tsx
Test Suites: 4 passed, 4 total   Tests: 22 passed, 22 total    JEST_RC=0
$ reslop t -- npx jest --ci --runInBand                      → тот же итог, exit: 0
$ npm run lint      (mob-lint/mobile: без .harness и mobile/e2e-first-run, как шаг CI)
structure: OK (repository inventory; external trees excluded)                     LINT_RC=0
```
Управляемая `selection` в конец значения (`auth-code-input`, 3 теста) и сдвиг корня под
клавиатурой (`auth-keyboard`, 2 теста) остались зелёными. Сценарий в п. 3 дополнительно
показывает, что `selection` = {len, len} на каждом шаге.

### 2.4 Сверка 123 и проверка происхождения — своя мера на кадрах attempt 3
```
$ python3 ../H135/scripts/sverka_maketa.py --manifest mobile/e2e-first-run/kadry.json --kadry mobile/maestro-out-first-run --repo .
KADR	First-Run dark	0.787	0.600	zagolovok	OK
KADR	First-Run light	0.784	0.600	zagolovok	OK
KADR	F03.01 dark	0.802	0.600	cta	OK
KADR	F03.01 light	0.910	0.600	G	OK
KADR	F03.02 dark	0.660	0.600	dopolnitelno	OK
KADR	F03.02 light	0.908	0.600	G	OK
KADR	F03.02-V01 dark	0.805	0.600	osibka	OK
KADR	F03.02-V01 light	0.894	0.600	G	OK
SVERKA_RC=0
$ python3 mobile/e2e-first-run/batareja/proverka_proiskhozdenija.py --pack mobile/e2e-first-run --repo . --harness ../H135
PROVERKA_RC=0
```
Мои 8 чисел совпадают с заявленными в логе CI attempt 3 (ниже).

### 2.5 CI на OBJECT
```
$ gh pr checks 121 -R a3ka/Complior-mob
android-e2e	pass	9m15s	…/runs/40099110838/job/120892259634
quality	pass	3m38s	…/runs/40099110838/job/120892260649
лог android-e2e (job 120892259634): 995 native rc=0 testcases=7 failed=0
  KADR Splash dark 0.783 / light 0.782 OK; 8 строк KADR 135 как в п. 2.4; SHABLON first-run-ekran OK
лог quality (job 120887415490, head_sha 8eb8d4ba): static 22/22, honest 336/336, static 16/16, honest 23/23,
  static 40/40, case RESTYLE_GUARD_995_F03_DARK/_LIGHT, behavioral 26/26, Tests: 22 passed, 22 total, structure: OK
```

### 2.6 Попытки 1–2 (`E2E_NE_PROSHLA`) — инфраструктура, а не код
```
attempt 1: android-e2e failure, шаг «135 first-run-ekran…»: PRICHINA	E2E_NE_PROSHLA	rc=1
  ci/a1/report-light.xml: time="1.008" status="ERROR" <failure>Unknown error</failure>
  ci/a1/light/…/maestro.log:9  [ERROR] … CommandFailed: Command failed (host:transport:emulator-5564): device offline
  ci/a1/light/…/maestro.log:54 Launch app "com.complior.mobile" with clear state FAILED
  (тёмная тема того же attempt 1 прошла: 4 кадра, каретки 0 — п. 1.2, строки a1)
attempt 2: android-e2e failure, тот же шаг
  ci/a2/report-dark.xml: time="1.31" status="ERROR" <failure>Unknown error</failure>
  ci/a2/dark/…/maestro.log:9  … emulator-5564): device offline;  :54 Launch app … FAILED
```
В обоих отказах adb теряет эмулятор (`device offline`) на третьем шаге, `launchApp`, через ~1 с
после старта — ещё до кода приложения. Тот же APK того же SHA проходит тёмную тему в attempt 1
и обе темы в attempt 3. Детерминированного дефекта кода нет. Нестабильность самого шага —
совет R135b-S3.

## 3. Побочные эффекты `caretHidden` и фокуса

Сценарий пользователя я прогнал одноразовым RNTL-сценарием на HEAD в `mob-red`. В дерево
продукта он не попадает. Шаги: монтирование, тап, набор, вставка, стирание, скрытие
клавиатуры, повторный тап, ввод, отправка → V01, тап в V01, исправление, blur от платформы.
```
0 mount                   value=""        caretHidden=true   selection={0,0}  a11y=Kontakt bestätigen  secure=true
1 tap/focus               value=""        caretHidden=false  selection={0,0}
2 type 48                 value="48"      caretHidden=false  selection={2,2}
3 paste 482190            value="482190"  caretHidden=false  selection={6,6}
4 erase all               value=""        caretHidden=false  selection={0,0}
5 keyboardDidHide         value=""        caretHidden=true
6 tap again               value=""        caretHidden=false
7 type                    value="482190"  caretHidden=false  selection={6,6}
8 submit -> V01           value="482190"  caretHidden=true
9 tap in V01              value="482190"  caretHidden=false
10 correct (invalid stays) value="48219"  caretHidden=false  selection={5,5}
11 platform blur          value="48219"   caretHidden=true
Tests: 1 passed, 1 total   SCEN_RC=0
```
Что видно по прогону:
- В фокусе каретка возвращается.
- При исправлении в V01 эффект `invalid` повторно не срабатывает: зависимость не меняется, и
  каретка не гаснет под пальцем.
- `accessibilityLabel`, `secureTextEntry`, `testID` и `onChangeText` не тронуты.
- frozen 995 на устройстве зелёный (`995 native rc=0 testcases=7 failed=0`), значит Maestro
  `tapOn`/`inputText`/`eraseText`/`hideKeyboard` с новым швом работают.

Слушатели `keyboardDidHide` (в шве фокуса и в `Surface`) независимы, `auth-keyboard` зелёный.
Оговорка: «`caretHidden` гасит уже нарисованную полосу на Android» — это [INFERENCE] из кода
RN (`setCursorVisible`). Подтверждено оно только кадрами устройства в п. 1.2: 9 кадров поля без
каретки. До правки было 1 из 4.

## 4. Сверка 8 кадров с макетами — смотрел каждое изображение сам

Кадры: `/tmp/dev-harness-verify/orch/art12/first-run/{dark/2026-10-24_141039,light/2026-10-24_141118}/first-run-ekran/takeScreenshot/first-run-ekran-<k>.png`
(байт-равны attempt 3, п. 1.1). Макеты: `…/Impl135/mob/docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/screens/First-Run.png`
и `…/Impl135/mob/docs/ux/03_Mobility_Slice1/screens/<id>[-Hell].png`.

Общее для всех кадров:
- Roboto вместо DM Sans (K1), отсюда другие переносы строк;
- системный статус-бар поверх full-bleed.

Доли по вертикали совпадают: CTA V01 dark 88,4 % против 88,5 %, CTA F03.01 light 95,3 % против
95,4 %, CTA V01 light 91,7 % против 91,8 %. Цвета ground, ink, accent, panel и danger совпадают
с токенами.

| Кадр | Макет | Вердикт | Отличия | KADR | Каретка (A/B/C) |
|---|---|---|---|---|---|
| First-Run dark `dark/…/first-run-ekran-first-run.png` | First-Run.png | совпадает, кроме шрифта | состав (wordmark, знак, заголовок, подзаголовок, CTA, футер) и цвета совпадают; переносы заголовка из-за шрифта (K1) | 0.787 | поля нет; 0/58*/0 |
| First-Run light `light/…/first-run-ekran-first-run.png` | First-Run.png (светлого макета нет) | совместим | светлые токены; шрифт (K1) | 0.784 | поля нет; 0/57*/0 |
| F03.01 dark `dark/…/first-run-ekran-f03-01.png` | F03.01.png | отличается: коллизии | + «Demo mit Beispieldaten ansehen» (K2); шрифт (K1); остальное совпадает; поле пустое, виден плейсхолдер, каретки нет | 0.802 | 0/36/0 |
| F03.01 light `light/…/first-run-ekran-f03-01.png` | F03.01-Hell.png | отличается: коллизии | + Demo-ссылка (K2); шрифт (K1); каретки нет | 0.910 | 0/36/0 |
| F03.02 dark `dark/…/first-run-ekran-f03-02.png` | F03.02.png | отличается: коллизии | маска «••••» вместо «482 1» и + «Zugang wiederherstellen» (K3); шрифт (K1); «demo@…le» — данные flow; каретки нет | 0.660 | 0/17/0 |
| F03.02 light `light/…/first-run-ekran-f03-02.png` | F03.02-Hell.png | отличается: коллизии + вопрос | как у dark (K3, K1); точка «ожидание» крупнее и темнее, чем на светлой доске (K4) | 0.908 | 0/17/0 |
| F03.02-V01 dark `dark/…/first-run-ekran-f03-02-v01.png` | F03.02-V01.png | отличается: коллизии | маска 6 точек, + «Kontaktdaten ändern» и «Zugang wiederherstellen» (K3); шрифт (K1); красный знак, «Keine Verbindung», danger-рамка, сообщение и плашка совпадают; каретки нет | 0.805 | 0/17/0 |
| F03.02-V01 light `light/…/first-run-ekran-f03-02-v01.png` | F03.02-V01-Hell.png | отличается: коллизии; **B1 закрыт** | как у dark (K3, K1); **каретки нет** (в круге 1 здесь было 450 px) | 0.894 | 0/17/0 |

\* Серия на First-Run — это штрих букв заголовка в том же окне: поля на экране нет.

Кроме K1–K4, ни один из 8 кадров не расходится с макетом.

## 5. Состояние ветки (BEHIND)
```
$ gh pr view 121 -R a3ka/Complior-mob --json mergeStateStatus,mergeable,headRefOid
{"headRefOid":"8eb8d4ba…","mergeStateStatus":"BEHIND","mergeable":"MERGEABLE"}
$ gh api …/compare/8eb8d4ba…main → {"status":"diverged","ahead_by":1,"behind_by":8}, коммит 8716729c docs/ux … пакет 3 (#123)
$ git diff --name-status ff848fad 8716729c -- <7 PNG макетов 135> docs/ux/03_Mobility_Slice1/ds/tokens.css mobile .github
(пусто)
$ git diff --dirstat=files,0 ff848fad 8716729c → 752 файла, все под docs/ux/03_Mobility_Slice1/
$ git diff --name-status ff848fad 8716729c -- 'docs/ux/03_Mobility_Slice1/screens/F03*' 'screens/html/F03*' docs/ux/02_…
28 файлов, все «A»: F03.03…F03.06, F03.V02…V04 (+Hell, +html); ни одного «M»
$ git merge-tree --write-tree HEAD origin/main → 8b08126b…  MERGE_TREE_RC=0 (без конфликтов)
check-runs main 8716729c: android-e2e success, quality success
```
Пакет 3 не трогает ни 7 макетов, с которыми сверяются кадры 135 (First-Run, F03.01[-Hell],
F03.02[-Hell], F03.02-V01[-Hell]), ни `ds/tokens.css`, ни файлы PR. Слияние проходит без
конфликтов. Rebase для корректности сверки 135 не нужен. Решение о rebase — за оркестратором.
Если ветку обновят, по R135-S3 круга 1 нужен зелёный CI на новом SHA: accept привязан к
OBJECT=8eb8d4ba.

## 6. Паразитная сложность (050) — артефакты диффа круга

1. **`useFieldFocus`** в `auth-screen.tsx` заменил `useBlurOnKeyboardHide`.
   - (1) Свойство: норма владельца 2026-10-14 «не оставлять … курсор в снимке» и R135-B1.
   - (2) Новое состояние `focused` явное: оно приходит из `onFocus`/`onBlur` платформы и
     выходит наружу как prop `caretHidden`.
   - (3) При следующей правке того же свойства меняется 1 файл; было 1.
   - (4) Интерфейс вырос с 1 поля (`ref`) до 5 (`ref`, `focused`, `onFocus`, `onBlur`,
     `blur`). Функциональность выросла соразмерно: появилось состояние фокуса и
     программное снятие.
   - (5) Потребители: два поля F03 и `auth-focus.test`. Логику из дерева он не повторяет.
   - Более простая форма — только `caretHidden={!focused}` без blur — не проходит: без blur
     на V01 фокус остаётся, мутант M1 красный. Обратный вариант — blur без `caretHidden` —
     это eea0db8c, где каретка была в кадре.
   - **ESSENTIAL.**
2. **prop `invalid` у `CodeInput`.**
   - (1) Снятие фокуса на кадре ошибки V01.
   - (2) Состояние уже было у родителя, теперь оно явно передаётся в поле.
   - (3) Меняется 1 файл.
   - (5) Потребители: кадр V01 и тест 2.
   - **ESSENTIAL.**
3. **`auth-focus.test.tsx`** (3 кейса).
   - (1) Те же свойства.
   - (2) Состояния нет.
   - (5) Потребитель — jest в quality. Красный на eea0db8c и на мутантах M1–M4 есть.
   - **ESSENTIAL**, оговорка в совете R135b-S1.
4. **Комментарии-расследования.** Около 35 строк в `auth-screen.tsx:200-232` и 25 строк шапки
   теста: run ID, logcat, миллисекунды фаз мигания. Это повтор совета R135-S5 круга 1.
   **ACCIDENTAL, совет**: свойству они не нужны, их место — сообщение коммита, где этот текст
   уже есть дословно.

## Находки

| ID | Класс | Адресат | Суть |
|---|---|---|---|
| R135-B1 (круг 1) | **ЗАКРЫТ** | — | каретки нет в 8/8 кадрах OBJECT (A=0, B≤36<70, C=0) и в 3 кадрах attempt 1; тест красный на eea0db8c и на мутантах M1–M4 |
| R135b-S1 | СОВЕТ | implementer / 123 | тест проверяет prop `caretHidden`, то есть состояние, а не пиксели. Само отсутствие каретки в кадре доказывает только устройство. Недорогой страж того же свойства — мера B (вертикальная серия ≥ 70 px в окне поля) в сверке кадров. Не блок: приёмка 135 такого не требует |
| R135b-S2 | СОВЕТ | implementer | комментарии-расследования снова выросли (п. 6.4, повтор R135-S5) |
| R135b-S3 | СОВЕТ | оркестратор / CI | шаг 135 красный в 2 из 3 attempt из-за `device offline` на `launchApp` (emulator-5564) — нестабильная инфраструктура, а не код (п. 2.6). Связано с R135-S4: свой второй эмулятор в шаге 135 |
| R135b-S4 | СОВЕТ | оркестратор | ветка BEHIND на #123 (пакет 3). Макеты 135, tokens и файлы PR он не трогает, merge-tree чистый. После обновления ветки нужен CI на новом SHA (R135-S3) |
| R135-K1 | вопрос владельцу | владелец (117 вопрос №2) | шрифт Roboto вместо DM Sans на всех 8 кадрах |
| R135-K2 | вопрос владельцу | владелец / architect | Demo-ссылка на F03.01 при её отсутствии на доске (её требует frozen 995 `pilot.yaml` `auth-demo-entry`) |
| R135-K3 | вопрос владельцу | владелец (frozen 995) | маска кода и лишние «Zugang wiederherstellen» / «Kontaktdaten ändern» на F03.02/V01 (их требуют frozen 995 `maestro_probe`/`pilot.test`/`stale_table`) |
| R135b-K4 | вопрос владельцу | владелец / дизайн | точка «ожидание» (state waiting) на F03.02: доски расходятся между собой — подробности ниже |

Круг 1 оставил советы R135-S1…S5, их я не пересуживал. R135-S5 повторён как R135b-S2.

Подробности K4. Светлая доска `F03.02-Hell.png` снята в фазе анимации waiting: точка цвета
ink-muted с прозрачностью 0,45, пиксель (176,175,171) = 0,45·#5f5e58 + 0,55·#f3f2ee, меньшего
размера (`faden-motion.js:76-77`: dotOpacity 0.45, dotScale 0.9). Тёмная доска `F03.02.png`
показывает полную непрозрачную точку (#a6a69f). Реализация рисует статичную полную точку в
обеих темах. Это совпадает с тёмной доской и с нормой «не оставлять бесконечную анимацию в
снимке». Кроп: `Rev135b/sign_crops.png`.

Блокеров нет, потому что ни одна находка не называет дефект, который implementer мог бы
закрыть в своей зоне без нарушения frozen 995/135 или без чужого решения.

## Вопросы владельцу

1. **K1** (117, вопрос №2). Подключать ли ассет `mobile/assets/fonts/DMSans-Variable.ttf`,
   чтобы экраны входа и First-Run совпали с досками по шрифту и переносам? Если да — каким
   контрактом: новая версия 117 или отдельный предмет?
2. **K2.** Слово 2026-10-21 (`docs/owner/2026-10-21-117-suzhenie.md:22`): «НЕТ «Demo mit
   Beispieldaten ansehen»». Frozen 995 при этом тапает `auth-demo-entry` на F03.01. Что верно:
   убрать ссылку через v+1 контракта 995 или принять расхождение с доской строкой контракта?
3. **K3.** Маска кода (`secureTextEntry` по frozen 995 `maestro_probe.py:5`) против открытого
   «482 190» на A05/A05e и лишние ссылки «Zugang wiederherstellen» / «Kontaktdaten ändern»: v+1
   контракта 995 или принятое расхождение?
4. **K4.** Какая фаза точки waiting канонична для статичного кадра F03.02: полная (как на
   тёмной доске и в реализации) или приглушённая 0,45 и меньшего размера (как на светлой)?
   Если анимация waiting нужна в продукте — это отдельная воля: норма запрещает бесконечную
   анимацию в снимке.
