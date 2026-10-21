FAIL

Покадровая приёмка по правилу (В) не пройдена. OBJECT `74c4c58612388df11eed492863341bbfee87c6b1` имеет реальный зелёный путь батарей при видимом несоответствии экранов макету. Я видел `sheet2.png` (8 кадров OBJECT) и `mock.png` (First-Run, Splash-Hell, Splash). Координаты ниже — 390×844, ручная погрешность ±5 px.

## Покадровая сверка

| Кадр | Фактически видно | Макет/токен и расхождение | Итог |
|---|---|---|---|
| dark / splash | Тёмный ground; светлый знак с лаймовой точкой примерно x109–289, y271–443; wordmark x157–232, y514–533; tagline x57–332, y569–595. | Совпадает с `Splash.png` (system bars не часть артборда). | pass |
| dark / First-Run | Малый wordmark приклеен к x0–65, y≈155; promise около y≈240; CTA малая x0–≈260, y≈290. Нет крупного C, сублайна и footer. | `First-Run.png`: крупный C в центре; block size-lg CTA у низа — примерно x23–367, y≈690–742. Нет «Ein Brief, ein Schaden, ein neues Auto …» и «Versicherung. Erledigt.». | **FAIL** |
| dark / F03.01 | Title/body/label и panel находятся ниже status bar, gutters ≈16 dp. CTA — малая content-width pill, не block/size-lg. Поле пустое, но body-text виден над ним как `TextField` label. | PNG нет; Button README требует primary `size-lg` 56 px на всю ширину. Frozen 117/1 требует label, но не placeholder. | **FAIL**: CTA; отсутствие placeholder не доказанный дефект |
| dark / F03.02 | Safe-area/gutters есть, body-label есть, primary CTA малая; три лаймовые ссылки на чёрном читаемы. | Button README: 56 px block. | **FAIL**: CTA |
| light / splash | Светлый ground, чёрный знак с лаймовой точкой, wordmark/tagline на тех же местах. | Совпадает с `Splash-Hell.png`. | pass |
| light / First-Run | Wordmark отсутствует; promise и малая CTA высоко в колонке; нет C, сублайна, footer. | Не соответствует `First-Run.png` по составу, центровке, низовой block CTA. | **FAIL** |
| light / F03.01 | Light scheme/safe-area/panel присутствуют; CTA чёрная, но малая, не block. Status-bar glyphs светлые на светлом ground. | Нарушены Button geometry и dark-content status bar для light scheme. | **FAIL** |
| light / F03.02 | Light scheme/panel есть; CTA малая. `Code erneut senden`, `E-Mail ändern`, `Zugang wiederherstellen` — `#d6f75a` на `#f3f2ee`; status-bar glyphs светлые. | Лайм на light ground практически не читается. Literal frozen 117/1 одновременно требует этот accent в light. | **FAIL** |

## Исполненный обманный зелёный путь

В одноразовом клоне OBJECT запущена батарея Architect117r6 из `fc96e6dab`:

```text
vkhod_probe.py --repo .                   rc=0, behavioral 28/28
vkhod_static_probe.py --repo .            rc=0, static 37/37
vkhod_probe.py --repo . --matrix          rc=0, honest 28; 25/25 declared mutants red
first_run_111/first_run_probe.py --repo . rc=0, honest 23/23
```

Статическая matrix Architect117r6 также завершила все 25 заявленных мутаций без `MUTANT_GREEN`: в том числе неправильные splash assets, размер, платформенные override и пять нарушений порядка Maestro покраснели именованными клетками. Это сильный positive control для существующих static/semantic целей, но не для visual First-Run/F03.

Следовательно сам OBJECT — искомая обманная реализация: кадры выше реально существуют в предоставленном Maestro sheet, а все названные battery paths зелёные. Проверка отвечает на другой вопрос:

* `MAESTRO_FIRST_RUN_ORDER` разбирает YAML и требует лишь исчезновения overlay и двух строк (promise/CTA), не сравнение screenshot с `First-Run.png`;
* `AUTH_*` судят дерево, tokens и дешёвые anti-offscreen styles; они не вычисляют layout и не измеряют bbox/высоту/ширину CTA;
* `first_run_111` 23/23 судит accessibility/source/copy/safe-area/transition, но не C, вертикальную композицию или bottom block CTA;
* static `MAESTRO_*` — YAML parser, не Android pixel comparison.

Таким образом положительный контроль присутствует: честный OBJECT зелёный, матрицы ловят свои semantic/static mutants. Пропущен именно класс: сохранены ID, строки, переходы и токены, но output screen не соответствует эталону.

`maestro --version; adb devices` в этом изолированном окружении дали rc=127 (`command not found` для обоих). Это не выдано за успешный e2e. Supplied `sheet2.png` — доступный artefact Maestro OBJECT; его восемь кадров служат наблюдаемым контрпримером к отсутствующему screenshot↔mock gate.

## Обходы, блокеры и владелец

1. **Нейтрализация pixel barrier / правильный ответ не на тот вопрос — блокер architect.** Добавить клетку First-Run visual-reference: сравнение release screenshot с `First-Run.png` либо независимые bbox assertions C, wordmark, promise, CTA block/56/bottom и footer. Она обязана красить ровно First-Run-visual mutant с сохранёнными ID, copy и переходом. Аналогично F03 надо проверять geometry Button/TextField по D2.2.5.1, а не только их дерево.
2. **First-Run и block CTA — блокер продукта, но не зона implementer 117.** `first-run-screen.tsx` и `src/ui/button.tsx` read-only для 117. Первый рендерит только wordmark/promise/Button; второй имеет `alignSelf: 'flex-start'` и padding вместо size-lg/block. Owner CMP-MOB-111/UI должен исправить composition и API. Сублайн/footer требуют решения владельца copy: frozen 111/1 запрещает новый видимый текст, хотя source canon `First-Run.html`/PNG его показывает. Implementer 117 не должен изобретать либо молча добавлять copy.
3. **Light links — дефект контракта/DS и блокер фактического экрана.** Реализация точно следует frozen `accent #d6f75a` в обеих темах; потому `AUTH_F03_02_STRUCTURE_LIGHT` зелёная. Architect/DS owner должен ввести читаемый light-link token и обновить oracle/клетки; implementer не должен тайно нарушать frozen literal.
4. **Light status bar — блокер implementer.** В `pilot-app.tsx`/`app.json` нет scheme-aware `StatusBar`; кадры показывают light glyphs на `#f3f2ee`. Нужен dark-content для light scheme плюс Android visual evidence; architect добавляет отдельную наблюдающую клетку.
5. **Поле — не подтверждённый блокер.** Body text на sheet расположен над panel, как требует `TextField.label`; frozen 117/1 и TextField README placeholder не требуют. Пустой value выглядит пустой полосой, но не является основанием добавлять placeholder без новой воли владельца.

Splash проверен хорошо: оба варианта соответствуют макетам, а static matrix ловит свои asset/generator stubs. Однако rule (В) требует покадровой сверки всех экранов, которой для First-Run/F03 нет. Поэтому `accept` невозможен.
