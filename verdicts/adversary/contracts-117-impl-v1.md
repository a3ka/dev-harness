FAIL

OBJECT `814e95ed19b3b7bf8912d79c588e295e2a2bf121`, CMP-MOB-006. Визуально проверены `/home/harness/consultant/e2e117/sheet.png` (8 кадров, 1264×1366), `/home/harness/consultant/e2e117/mock.png` и эталоны `docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/screens/{Splash,Splash-Hell,First-Run}.png` (390×844).

## Блокер A-117-1 — зелёный путь Maestro снимает не First-Run

`mobile/.maestro/vkhod-117-splash-vhod.yaml:31-34` делает splash screenshot, затем лишь `assertVisible id: first-run-continue`, затем `takeScreenshot: vkhod-117-first-run`. Нет ожидания 1200 ms, `assertNotVisible splash-overlay` и проверки видимых wordmark/promise/CTA First-Run.

Это исполнимая обманная ветка: `PilotApp` уже имеет `frame === 'first-run'`, но `splash-overlay` — последний sibling поверх дерева с `pointerEvents="none"`, живущий 1200 ms (`pilot-app.tsx:130-139,294-315`). Поэтому ID CTA находится и нажимается под непрозрачным Splash-растром. В sheet оба `vkhod-117-first-run` действительно показывают Splash, не First-Run. `assertVisible` отвечает на другой вопрос — наличие элемента в дереве, а не видимость снимаемого кадра.

**Чинит architect:** после splash-клетки требовать исчезновение `splash-overlay`, затем видимый состав First-Run и только потом делать `vkhod-117-first-run`. Негативный стаб «overlay удержан» обязан красить ровно First-Run-клетку.

## Покадровая сверка

Координаты — кадр 390×844, визуальная погрешность около 5 px.

| Тема/кадр sheet | Эталон | Наблюдение и расхождение |
|---|---|---|
| dark / `vkhod-117-splash` | `Splash.png` | Рабочий стол Android; приложения нет. Полностью отсутствуют ground `#0A0A0A`, знак x109–289 y271–443, wordmark x157–232 y514–533, tagline x57–332 y569–595. |
| dark / `vkhod-117-first-run` | `First-Run.png` | Тёмный Splash с его знаком/wordmark/tagline. Нет First-Run верхнего wordmark, promise «Sie sagen, was passiert ist…» (около y337–454) и CTA x16–374 y739–793. |
| dark / `vkhod-117-f03-01` | D2.2.5.1 tokens + Button/TextField + F03 table | `Demo` x0 y0 накладывается на status bar; heading/body/field x0, поле до краёв. Нет safe-area и 16 px gutters. **Чинит implementer** (`pilot-app.tsx`, `auth-screen.tsx`). |
| dark / `vkhod-117-f03-02` | то же | `Demo` x0 y0 под часами, heading/links x0; нет safe-area/16 px сетки. **Чинит implementer.** |
| light / `vkhod-117-splash` | `Splash-Hell.png` | Только нативный light-знак; нет требуемых wordmark x157–232 y514–533 и tagline x57–332 y569–595 полного Splash-Hell. |
| light / `vkhod-117-first-run` | `First-Run.png` | Снова чёрный Splash с белыми знаком/wordmark/tagline, не First-Run. |
| light / `vkhod-117-f03-01` | light D2.2.5.1 | Чёрный ground, белые ink/body, тёмная panel и lime CTA — dark-палитра; также x0 и нет safe-area/gutters. Ожидались `#f3f2ee`, `#121211`, `#e6e5df`, primary `#121211`. **Чинит implementer.** |
| light / `vkhod-117-f03-02` | light D2.2.5.1 | Повтор dark-палитры и layout x0 вместо light tokens/safe-area/16 px grid. **Чинит implementer.** |

«По токенам» F03 означает effective `ground/ink/panel/primary/on-primary/accent` нужной темы, `.title` 28/32/500, TextField с body-label, 56 px primary pill, safe-area и 16 px сетку, не только testID.

## Блокер A-117-2 — тест подменяет тему устройства

`src/theme/context.ts:13-16` имеет default `scheme: 'dark'`. Cold-start `/` только реэкспортирует `PilotApp` (`src/app/index.tsx`), `src/app/_layout.tsx` рендерит Stack, а `PilotApp` не ставит provider. Единственный production `<ThemeContext.Provider>` находится внутри `TabShell` (`tab-shell.tsx:305-313`), который для First-Run/F03 cold-start не используется.

Зато `vkhod.test.tsx:144-148,562-566` вручную оборачивает PilotApp в provider с `themeTokens[scheme]`. Поэтому LIGHT-RNTL клетки зелёные на искусственно переданной теме, но отвечают не на вопрос о theme propagation с устройства. Лист e2e показывает фактический результат — оба нижних F03 dark.

**Чинит implementer:** провести Appearance/theme provider до cold-start PilotApp. **Чинит architect:** добавить e2e/integration-стаб без injected ThemeContext: OS light обязан дать light tokens на F03.01/F03.02.

## Блокер A-117-3 — матрица проверок пропускает две обязательные пустышки

Позитивные контроли прошли:

```text
vkhod_probe.py --model        rc=0, behavioral 22/22
vkhod_static_probe.py --model rc=0, static 35/35
vkhod_probe.py --matrix       rc=0; honest 22, все 20 behavioral mutants red
```

Полная статическая матрица завершилась `rc=2` за 286.51 s и напечатала:

```text
MUTANT_GREEN icon-template-bytes
MUTANT_GREEN adaptive-favicon-template
```

Это дефект батареи, не продукта. У `icon-template-bytes` причина прямая: `vkhod_static_probe.py:1084-1105` читает `template_icon` из уже реализованного subject (`repo / I`), затем подставляет те же байты вместо `ICON_MODEL`; на честном C мутация no-op. `adaptive-favicon-template` построен тем же паттерном (`template_fg/bg/mo/favicon` читаются из subject), поэтому также не предъявляет template-подстановку. Остальные статические мутации, включая wrong splash asset, shifted/half-res/no-words composite, image width, user style, IOS legacy и wrong source, покраснели на именованных клетках.

**Чинит architect:** брать все template bytes из независимого frozen base/oracle, а не из C; матрица обязана быть rc=0 только когда нет `MUTANT_GREEN`.

## Область и среда

`git diff --name-only B..OBJECT` содержит только заявленную implementer-зону: workflow, scenario, app.json, перечисленные icon/splash assets, `pilot-app.tsx`, `auth-screen.tsx`. Это не смягчает FAIL: правило (В) требует фактической покадровой сверки, а все 8 наблюдаемых кадров ей противоречат.

Локально `maestro --version` и `adb devices` дали rc=127 `command not found`; это не выдано за зелёный e2e. Визуальный контрпример взят из доступного raw artefact sheet. Общие lint/typecheck/npm test не запускались: проектная проверка назначена Main и они не являются доказательством пиксельного кадра. Продукт и батарея не менялись; эксперименты только в `/tmp/dev-harness-verify/Adv117/mob`.
