РЕШЕНИЕ
OBJECT=7482b8d8bcfa2d70d34d456c5dde18a9c47a1dbb

# Арбитраж 999 — критерий обязан различать ЗАКРЫТУЮ грамматику портов шва (состояние × действие × режим; примитив × вариант × состояние × тема), а не перечень предъявленных обманок

МОДЕЛЬ: `anthropic/claude-fable-5-1`, арбитр (Arbiter999), 2026-10-18. Асимметрия семейства записана в `roles/arbiter.md`: делю семейство с автором конструкции (architect). Все спорные факты решены замером (З-0…З-4). Не сводятся к замеру три места: включение `colorScheme` в режимы навигации (Решение 2, К1, помечено), граница accent-гейта shell в dark (К4, помечено), «нарезка нет» (Решение 3, помечено).

## Итог

- **Предмет спора — критик прав по существу всех четырёх классов.** Перечни OBJECT («ЗАКРЫТЫЕ ПЕРЕЧНИ» контракта :51–57) замкнуты по ОДНОЙ оси каждый (вкладка; примитив×тема; наличие компонента; состояние в dark), тогда как сам контракт объявляет больше осей: порты шва `initialSection/returnSection/reducedMotion/colorScheme/onCommand` (:47), свойства примитивов `primary/secondary, disabled`, `secureTextEntry` (:42), «ближайший композит над хостом» (:55), «dark/light» (:34). Семь обходов критика (З-2) и пять моих, НЕ названных критиком (З-3), проходят все четыре пробы OBJECT, а честная модель автора выполняет всё — значит пробел только в пробе, класс один: «перечень порождён выборкой обходов, не грамматикой портов».
- **Автору — в частностях:** модель architect честна и полна (З-0: 62/62 клеток закрытого перечня зелёные без единой правки модели); 11 обходов круга 1 и матрица copy/static закрыты (не оспорено, не пересматриваю); реализацию и зону implementer править не нужно; все правки — ЗОНА architect.
- **Нарезка не нужна** (Решение 3); новые номера запрещены брифом, и они не нужны: закрытие — одна таблица состояний с общим «обходом поверхности» + одно декартово произведение примитивов, ~62 клетки, ~5 с Jest.
- **Круг 3 критика допускается** в пределах капа 3 (tri-slota §3) с ЗАКРЫТЫМ предметом К1–К4 / П1–П7. FAIL круга 3 по пункту перечня = кап достигнут → К ВЛАДЕЛЬЦУ. Находка вне перечня — совет, круг не роняет.

## Созыв и первоисточники

Созван строкой `АРБИТР:` вердикта круга 2 (повтор причины). Прочитаны полностью: `roles/arbiter.md`; `docs/owner/2026-10-18-tri-slota.md` §3; `verdicts/critic/contracts-999-krug1-fail.md`, `contracts-999-krug2-fail.md` (origin/main 977454a6); контракт `contracts/999-cmp-mob-002-navigatsiya.md`, `fixtures/workshop_project/nav_999/{nav.test.tsx,ui.test.tsx,copy_surface.test.tsx,source.json,probe_lib.py,nav_probe.py,ui_probe.py,copy_probe.py}` и `model/*` на OBJECT (мой клон `/tmp/dev-harness-verify/arb999/clone`, `git rev-parse HEAD` = OBJECT, `status --porcelain` → 0 строк после всех прогонов); репро критика `/tmp/dev-harness-verify/critic999r2/{audit.py,observe.test.tsx,run.py,*.log}` — только чтение, мутации перенесены байт-в-байт; прецеденты `verdicts/arbitration/contracts-998-perechen-vetvej-v1.md`, `contracts-996-closed-preserved-v1.md`.

## Замеры

Каталог `/tmp/dev-harness-verify/arb999/`. `R` — копия disposable-клона критика (`cp -a critic999r2/R`), `git rev-parse HEAD` = B `f0d8e54e181853473e23c7df3dc623bbb7faecdf`, `status --short --untracked-files=all` → 0 строк до и после каждого режима. Измеритель `measure.py` (sha256 `eded445e4782c110…`), свидетель закрытого перечня `witness.test.tsx` (sha256 `584019ec3e7ced95…`, 62 клетки: К1 48 = 4 вкладки × {tab→*, profile, deeplink→*} × 4 режима; К2 14 = Button 2×2×2 + Notice 2 + TextField 2×2; в каждой клетке К1 — обход поверхности: каталог, accent-гейт по ВСЕМ host-Text/TextInput, контейнеры). Полный вывод — `logs/{baseline,critic,combined,arb}.log`. `TMPDIR=/tmp/dev-harness-verify/arb999`, `PYTHONDONTWRITEBYTECODE=1`.

**З-0. Baseline и честная модель** (`python3 measure.py baseline`):
```
$ nav_probe.py --repo R            → 999 NAV_SHELL_ABSENT        EXIT=1
$ ui_probe.py --repo R             → 999 UI_PRIMITIVES_ABSENT    EXIT=1
$ shell_static_probe.py --repo R   → 999 STATIC_THEME_ABSENT     EXIT=1
$ copy_probe.py --repo R           → 999 COPY_MODULE_ABSENT      EXIT=1
[модель + шрифты установлены в R через probe_lib.installed]
$ nav_probe.py --repo R            → EXIT=0 (32 строки 999 nav/*: rc=0)
$ ui_probe.py --repo R             → EXIT=0 (11)
$ shell_static_probe.py --repo R   → EXIT=0 (6, FONTS_* sha256 совпал)
$ copy_probe.py --repo R           → EXIT=0 (4, COPY_SURFACE_CATALOG rc=0)
WITNESS honest-model JEST_EXIT=0 cells=62 failed=0
STATUS_AFTER: (clean)
```
Вывод: модель автора выполняет весь закрытый перечень К1–К4 ниже; правки модели/implementer не требуются.

**З-1. Семь мутаций критика круга 2, каждая отдельно, против четырёх проб OBJECT и свидетеля** (`python3 measure.py critic`):
```
OBJECT_PROBES transition-post-vorgaenge      nav/ui/static/copy = [0, 0, 0, 0]
WITNESS transition-post-vorgaenge  cells=62 failed=8   RED: K1 tab post→* ×4 режима; K1 tab vorgaenge→* ×4
OBJECT_PROBES reduced-motion-emits-command   nav/ui/static/copy = [0, 0, 0, 0]
WITNESS reduced-motion-emits-command failed=8          RED: K1 tab {start,vorgaenge,schutz,post}→* rm=true ×2 cs
OBJECT_PROBES secondary-disabled-ignored     nav/ui/static/copy = [0, 0, 0, 0]
WITNESS secondary-disabled-ignored failed=2            RED: K2 Button secondary disabled=true dark; …light
OBJECT_PROBES input-accent-text              nav/ui/static/copy = [0, 0, 0, 0]
WITNESS input-accent-text failed=4                     RED: K2 TextField secure={true,false} × {dark,light}
OBJECT_PROBES containers-detached            nav/ui/static/copy = [0, 0, 0, 0]
WITNESS containers-detached failed=48                  RED: все 48 клеток К1 (контейнерная часть обхода поверхности)
OBJECT_PROBES light-copy-invented            nav/ui/static/copy = [0, 0, 0, 0]
WITNESS light-copy-invented failed=24                  RED: все 24 клетки К1 cs=light
OBJECT_PROBES nonstart-accent-title          nav/ui/static/copy = [0, 0, 0, 0]
WITNESS nonstart-accent-title failed=44                RED: все клетки К1, где виден раздел ≠ start (обе темы, см. К4)
STATUS_AFTER: (clean)
```
Факты критика подтверждены в обе стороны: пробы OBJECT слепы к каждому обходу по отдельности; закрытый перечень различает каждый.

**З-2. Совмещённое дерево критика (шесть мутаций)** (`python3 measure.py combined`):
```
OBJECT_PROBES combined nav/ui/static/copy = [0, 0, 0, 0]
WITNESS combined JEST_EXIT=1 cells=62 failed=54
```

**З-3. Пять моих представителей тех же классов, критиком НЕ названных** (`python3 measure.py arb`; патчи — `measure.py`, список `ARB`):
```
X1 nav-gated-by-colorScheme        onPress: if (!(colorScheme==='light' && id==='post')) setSection(id)
   OBJECT_PROBES = [0, 0, 0, 0]    WITNESS failed=8   RED: K1 tab *→* cs=light ×2 rm
X2 copy-invented-under-reducedMotion   header: {reducedMotion ? <Text>Bewegung aus</Text> : null}
   OBJECT_PROBES = [0, 0, 0, 0]    WITNESS failed=24  RED: все клетки К1 rm=true
X3 textfield-always-secure         secureTextEntry={true}
   OBJECT_PROBES = [0, 0, 0, 0]    WITNESS failed=2   RED: K2 TextField secure=false dark/light
X4 tabbar-outside-safe-area        tablist вынесен за </SafeAreaView> (testID, роли, порядок сохранены)
   OBJECT_PROBES = [0, 0, 0, 0]    WITNESS failed=48  RED: все клетки К1 (shell-tab-* не потомки host shell-safe-area)
X5 profile-not-in-keyboard-container   profile-surface вынесен за </KeyboardAvoidingView>
   OBJECT_PROBES = [0, 0, 0, 0]    WITNESS failed=16  RED: K1 profile {4 вкладки} × 4 режима
STATUS_AFTER: (clean)
```
Вывод: обобщение автора на OBJECT (перечень вкладок; примитив×тема; «компонент присутствует»; состояния в dark) не замыкает класс — пять новых обходов вне списка критика проходят всё. Замкнутость даёт только перебор по объявленным осям, и честная модель его выполняет (З-0).

**З-4. Факты по коду OBJECT (чтение, подтверждают доводы критика):** `nav.test.tsx:49–61` — одна последовательность Start→Vorgänge→Schutz→Post, пары «из X в Y» не перебираются; `:64–74` и `:125–139` — `onCommand` не наблюдается при `reducedMotion`; `ui.test.tsx:92–104` — disabled только default primary; `:124–140` — цвет TextInput не наблюдается, `secureTextEntry` только `true`; `:40–49,144–152` — `compositeCount(root, C) > 0`, связь с хостом и содержимым не проверяется; `:155–175` — ручной список узлов (title start, вкладки, профиль); `copy_surface.test.tsx:47,55,65` — три render без `colorScheme`/`reducedMotion`. Модель `model/bootstrap.tab-shell.tsx:92–118`: `onPress={() => setSection(id)}` без ветвлений по режиму; `:76–89` — контент внутри `KeyboardAvoidingView` внутри `SafeAreaView`; tablist внутри `SafeAreaView`.

## Решение 1 — кто прав по каждому спорному пункту

Правило владельца (tri-slota §3): повтор класса чинится обобщённо; на поздних кругах блокирует доказанное нарушение принятого требования или недостоверное доказательство, новое требование — совет.

| находка круга 2 | основание | статус |
|---|---|---|
| 1. переходы вкладок / reducedMotion | Инвариант 5 (:44) и порт `reducedMotion` (:47) приняты автором; «selected при переключении (все четыре)» (:52) доказывает одну траекторию, не таблицу from×to, и не доказывает «не отправляет команду» в режиме reduced motion. З-1: оба обхода проходят. Проверено слабее, чем написано = недостоверное доказательство (граница 996/998) | **БЛОКЕР**, критику целиком |
| 2. disabled secondary / accent-текст TextInput / заголовки не-Start | Инвариант 3 (:42) объявляет `disabled` свойством Button, не варианта primary; инвариант 2 (:41) — гейт «на самих примитивах … и на поверхности shell»; «в каждой клетке все заявленные свойства» (:53). З-1: три обхода проходят | **БЛОКЕР**, критику целиком |
| 3. контейнеры-соседи | Контракт :55 САМ обещает «ближайший композит над хостом shell-safe-area/-keyboard-container»; проба измеряет `compositeCount > 0` где угодно. З-1 `containers-detached`, З-3 X4/X5 проходят | **БЛОКЕР**, критику целиком; уточнение: перечень «что обёрнуто» закрывается хостами шва (К3), не «всем деревом» |
| 4. copy light-поверхность | Предмет :34 «темы dark/light», инвариант 4 (:43); перечень состояний (:56) не перебирает режимы. З-1, З-3 X2 (reducedMotion — тот же пробел) | **БЛОКЕР**, критику целиком; расширение: режим = `colorScheme × reducedMotion`, не только light |
| Довод автора (сообщение коммита OBJECT: «ЗАКРЫТЫЕ перечни … перебором по перечню из source.json») | Перебор ведётся по одной оси (вкладки / примитив×тема), остальные объявленные оси (действие из состояния, режимы, состояние disabled, значение secure, вложенность) заданы константой. З-3: пять обходов вне списка критика. Довод отклонён | — |
| Возможное толкование «весь класс» как открытого множества | Отклонено: класс закрыт грамматикой портов и свойств, записанных в контракте (:42, :47, :55). Ниже — закрытый перечень; обход, не нарушающий его пункта, на круге 3 — совет | граница ниже |

**Граница для круга 3** (обязательна обеим сторонам): блокирует только (i) невыполненный пункт К1–К4 / П1–П7; (ii) эталон, модель или клетка, сами нарушающие пункт К (недостоверность); (iii) регресс закрытого (11 обходов круга 1, матрица copy/static). Новый мутант вне перечня — совет.

## Решение 2 — ЗАКРЫТЫЙ перечень К1–К4

Грамматика: `TABS = source.tabs_order` (4); `MODES = {reducedMotion: false,true} × {colorScheme: dark,light}` (4) — значения объявленных портов шва (:47); состояния S = {tabs(section), profile(origin), deeplink(initial, return)}; действия A = {tab(to) ∀ to∈TABS, profile-entry, back}. Единица — клетка, порождённая циклами по этим перечням (не ручной список); группировка нескольких координат в одну `it` допустима, если имя клетки несёт координаты (как `DEEPLINK_RETURN_<A>_TO_<B>` на OBJECT) и перечень не усечён.

**К1 — навигация (инварианты 1, 5; порты :47). Способ С.**

| К1.n | клетка | наблюдение | статус на OBJECT |
|---|---|---|---|
| 1.1 | ∀ mode, ∀ from∈TABS, ∀ to∈TABS: initialSection=from, press tab(to) — ИЗ from (после каждой пары возврат в from или новый render) | selected ровно to; `section-to` и его заголовок из каталога; Back отсутствует; `onCommand` не вызван | **правка П1** (есть только Start→V→S→P и initial×4) |
| 1.2 | ∀ mode, ∀ from: profile-entry → back | profile-surface, 0 tab, Back = `global.back`; после back — selected from, `section-from`, Back отсутствует; `onCommand` не вызван | **правка П1** (есть без режимов) |
| 1.3 | ∀ mode, ∀ (initial, return) ∈ TABS²: back | до: selected initial, Back виден; после: selected return, `section-return`, Back отсутствует; `onCommand` не вызван | **правка П1** (16 пар есть, без режимов) |
| 1.4 | ∀ mode, ∀ initial: returnSection не задан | Back отсутствует | **правка П1** (есть для post в dark) |
| 1.5 | ∀ клетка с rm=true | `shell-faden` отсутствует; каждая вкладка `disabled !== true`; все действия A доступны и дают те же состояния, что при rm=false (само по себе — следствие 1.1–1.4 под rm=true) | **правка П1** |
| 1.6 | TABS_ORDER, TAB_LABELS_IA, PROFILE_SECONDARY_NOT_TAB, TAB_SWITCH_NO_COMMAND, SECTION_CONTENT_COPY | как на OBJECT | есть |

Не входит в К1 (контракт не задаёт; совет, не блокер): нажатие вкладки/профиля при заданном `returnSection` (судьба Back и returnTo); присутствие faden при rm=false; порядок клеток.

Помечено как суждение: включение `colorScheme` в режимы навигации. Довод: порт объявлен в шве (:47), «темы dark/light» — предмет (:34), X1 (З-3) — обход того же класса, цена — удвоение циклов (~1 с Jest).

**К2 — примитивы (инварианты 2, 3). Способ С. Декартово произведение, в каждой клетке все свойства.**

| К2.n | клетка | наблюдение | статус |
|---|---|---|---|
| 2.1 | Button × {primary, secondary} × {disabled=false, true} × {dark, light} = 8 | role button; `accessibilityState.disabled === disabled`; press → onPress вызван ровно 1 раз при enabled и 0 при disabled; при enabled fiber-проводка `=== onPress`; цвет подписи = on-primary/ink[scheme], заливка = primary/panel[scheme] побайтово из source.json; подпись ≠ accent[scheme] | **правка П2** (disabled только default primary) |
| 2.2 | Notice × {dark, light} = 2 | role alert; заливка card, текст on-card, ≠ accent | есть |
| 2.3 | TextField × {secure=true, false} × {dark, light} = 4 | label цвет ink, ≠ accent; `secureTextEntry === secure` (ОБА значения); `value` проброшен; цвет TextInput = ink, ≠ accent; заливка TextInput = panel; onChangeText | **правка П2** (нет secure=false, нет цвета/заливки input) |

**К3 — контейнеры (инвариант 3, :55). Способ С, наблюдается в КАЖДОМ состоянии К1 (общий обход поверхности).**

| К3.n | наблюдение | статус |
|---|---|---|
| 3.1 | ближайший композит над host `shell-safe-area` (вверх до первого host-fiber) — `SafeAreaView` из react-native-safe-area-context; над host `shell-keyboard-container` — `KeyboardAvoidingView` из react-native | **правка П3** (на OBJECT — `compositeCount > 0` где угодно) |
| 3.2 | контент состояния (`section-<id>` либо `profile-surface`) — потомок ОБОИХ хостов `shell-safe-area` и `shell-keyboard-container` (по testID host-fiber'ов) | **правка П3** |
| 3.3 | каждый видимый хост шва {`shell-back`, `shell-profile-entry`, `shell-tab-*`} — потомок host `shell-safe-area` | **правка П3** (X4) |

Не входит: физический рендер safe-area/клавиатуры (NOT_RUN до C, уже честно записано :105).

**К4 — поверхность copy и accent (инварианты 2, 4). Способ С, в КАЖДОМ состоянии К1 × MODES.**

| К4.n | наблюдение | статус |
|---|---|---|
| 4.1 | все непустые строковые листья `toJSON()` ∈ множеству 10 текстов каталога source.json | **правка П4** (есть, но только dark / rm=false) |
| 4.2 | Back наблюдается поимённо (`global.back`) в состояниях profile и deeplink-до-back; отсутствует после back | есть, расширить на режимы — П4 |
| 4.3 | при cs=light: ВСЕ host-узлы `Text` и `TextInput` (обход дерева, не ручной список) имеют `color ≠ accent.light` | **правка П4** (ручной список: title start, вкладки, профиль) |

Помечено как суждение: гейт 4.3 требуется в light (буква инварианта 2 «не лаймовый текст на светлом фоне» и клетка ACCENT_NOT_TEXT_ON_LIGHT); в dark — совет (модель выполняет и его; свидетель З-1 применял оба).

**Что НЕ блокирует круг 3** (переоткрывается только ссылкой на этот файл): мутант вне К1–К4; состояния с returnSection + tab/profile; dark-гейт shell; faden при rm=false; fontFamily DM Sans в стилях (инвариант 6 требует только файлы+OFL); состав декоев матриц сверх П5; гранулярность `it` при сохранённой грамматике.

## Решение 3 — нарезка: не нужна

Суждение (асимметрия отмечена). Доводы: (1) все блокеры — три тест-файла и один абзац контракта, зона architect; реализация и зона implementer не меняются (З-0: модель 62/62); (2) класс один и сходится: круг 1 — 5 блокеров, круг 2 — 4 того же класса, оба закрываются одной грамматикой; (3) «широта» предмета мнимая по цене: закрытие — одна таблица состояний с общим обходом поверхности (К1+К3+К4) и одно декартово произведение (К2), 62 клетки, ~5 с Jest (`logs/baseline.log`); (4) новые номера запрещены и не нужны — tri-slota §3: номера счёт не обнуляют; (5) «предмет отложить» дало бы только потерю issue #6 без выигрыша в сходимости. Ужесточение внутри 999 = К1–К4.

## Пункты правки для architect (П1–П7) — все в ЗОНА architect

**П1 — К1 (`nav.test.tsx`).** Циклы `for mode of MODES` × `for from of TABS` над: (а) `for to of TABS` press tab(to) из from — 1.1; (б) profile→back — 1.2; (в) `for ret of TABS` deeplink→back — 1.3; (г) без returnSection — 1.4; под rm=true дополнительно 1.5. Имена клеток с координатами (например `TAB_<FROM>_TO_<TO>_RM<0|1>_<CS>`, `PROFILE_RETURN_<FROM>_…`, `DEEPLINK_RETURN_<A>_TO_<B>_…`). `onCommand` — наблюдатель в каждой клетке. Образец циклов и обхода поверхности — `witness.test.tsx` (замер, не копировать как оракул). Режимы — из source.json (контракт :51 называет его единственным источником грамматики: добавить `"modes": {"reducedMotion": [false, true], "colorScheme": ["dark", "light"]}`) либо из типа порта — выбор автора; обязательна грамматика, не форма.

**П2 — К2 (`ui.test.tsx`).** Button: цикл scheme × variant × disabled (8 клеток, все свойства 2.1, `BUTTON_DISABLED_STATE` растворяется в них); TextField: цикл scheme × secure (4 клетки, свойства 2.3 включая цвет/заливку TextInput и `secure=false`); Notice — как есть.

**П3 — К3.** Общая функция обхода поверхности (3.1–3.3), вызываемая в каждом состоянии К1 (из `nav.test.tsx` или общего модуля проб); `SAFE_KEYBOARD_CONTAINER` на OBJECT заменить на 3.1–3.3 либо оставить как положительный контроль.

**П4 — К4 (`copy_surface.test.tsx` и/или общий обход).** 4.1–4.3 в каждом состоянии К1 × MODES; `ACCENT_NOT_TEXT_ON_LIGHT` → обход всех host-Text/TextInput, не ручной список; каталог — из source.json.

**П5 — матрицы `MUTANTS`.** Добавить как декои с named-клеткой и измеренным `depends`: nav — `transition-post-vorgaenge`, `reduced-motion-emits-command`, X1 `nav-gated-by-colorScheme`, X2 `copy-invented-under-reducedMotion` (named в семье, где живёт обход поверхности); ui — `secondary-disabled-ignored`, `input-accent-text`, X3 `textfield-always-secure`, `containers-detached`, X4 `tabbar-outside-safe-area`, X5 `profile-not-in-keyboard-container`, `nonstart-accent-title`; copy — `light-copy-invented`. Патчи — `critic999r2/audit.py` (NEW) и `arb999/measure.py` (ARB), байт-в-байт. `depends` допустимо ПОРОЖДАТЬ генератором по грамматике (образец `_deep_cells` на OBJECT) — это не ослабление «всех колонок»; побочная краснота вне named ∪ depends по-прежнему дефект.

**П6 — текст контракта.** Блок «ЗАКРЫТЫЕ ПЕРЕЧНИ» (:51–57) переписать по К1–К4: грамматика = TABS × S × A × MODES; примитивы = вариант × состояние × тема; контейнеры = 3.1–3.3 в каждом состоянии; copy/accent = 4.1–4.3 в каждом состоянии × режиме; «не входит» — перечислить явно (см. «Что НЕ блокирует»). Приёмочный критерий (:64–65): фактические числа клеток nav/ui/copy и мутантов (сейчас 32/11/4 и 12/11/7/4). §Фактический замер — заново на новом коммите.

**П7 — предъявление на новом коммите.** Живые rc: четыре пробы на B → rc1 именованно; с `--model` и на `ref` → rc0 с новыми числами; `--matrix` всех четырёх → rc0, unexpected_red=none; 12 вариантов (7 критика + 5 моих, патчи выше) по отдельности → rc1 своей семье с именованной клеткой; combined критика → rc1 nav/ui/copy; 11 обходов круга 1 и `status-lost` — не регрессировали; `git status` R пуст; `pre_critic`, `check_precision_gate`, `check_threat_model` — заявленные rc.

## Круг 3 критика

- **Допуск.** Кругов пройдено 2, кап — 3 (tri-slota §3). Круг 3 штатный, в пределах капа; слово консультанта/владельца не требуется.
- **Предмет круга 3 закрыт:** (1) сверка П1–П7; (2) К1–К4: каждый пункт «правка» закрыт названным способом, 12 вариантов красны на своих клетках, пункты «есть» по-прежнему держат; (3) прежние команды критерия — заявленные rc; (4) закрытое кругом 2 не регрессировало.
- **FAIL круга 3** по пункту перечня = кап достигнут → К ВЛАДЕЛЬЦУ (микро-круг после капа — мандат консультанта tri-slota §2 п.2, не арбитра). Находка вне перечня — совет, круг не роняет.

## Счёт по сторонам

- Критику: все четыре класса по существу; метод «грамматика объявленных портов/свойств, не выборка обходов» — за критиком (правило владельца + граница 996/998).
- Автору: класс закрыт КОНЕЧНЫМ перечнем К1–К4, а не «любым новым обходом»; модель честна и полна (З-0), implementer-зона не затронута; нарезка не требуется; круг 3 в пределах капа; гранулярность клеток и форма генерации — выбор автора.
- Против критика: ничего по существу. Уточнения границ: К3 — замкнуто хостами шва, не «всем деревом»; К4 — режим шире, чем «light» (reducedMotion, X2).

## К ВЛАДЕЛЬЦУ (не решаю)

Ничего обязательного. Для сведения: прогноз цены круга 3 — один коммит architect (три тест-файла, абзац контракта, ~12 декоев) + один суд критика; альтернативы «отложить предмет» нет инженерных оснований (Решение 3).

## Несогласие сторон

Письменного несогласия architect'а в первоисточниках нет; позиция взята из сообщения коммита OBJECT и текста :51–57. Все факты критика воспроизведены на моём клоне и моём R (З-1, З-2); дополнительные замеры (З-0 полнота модели, З-3 пять обходов вне списка критика) — мои.

## Артефакты

`/tmp/dev-harness-verify/arb999/`: `clone/` (OBJECT, porcelain 0); `R/` (B, clean); `measure.py`, `witness.test.tsx`; `logs/{baseline,critic,combined,arb}.log` (полный сырой stdout всех команд выше, включая 32/11/6/4 строк проб на каждом прогоне). Основной чекаут не открывался; read-only каталоги критика/архитектора не изменены; commit/push не выполнялись (Н-85, бриф). Коммит под `-c user.name=arbiter -c user.email=arbiter@dev-harness.local` в `verdicts/arbitration/` — оркестратору.
