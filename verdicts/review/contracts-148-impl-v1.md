FAIL
OBJECT=d5929d6839944b364723b21343a9d7a70133e974
СУД: сессия=Rev148; модель-план=Opus (vision обязателен); модель-факт=anthropic/claude-opus-5-5; вызов=1
SUBJECT=148 (лёгкий трек, класс риска обычный). Контракт `frozen/contracts/148/2` → `afc9598b6b34a201b1d8f2d3974fcc5777d8dfde`; текст сохранён в `/tmp/dev-harness-verify/Rev148/contract-148-2.md` (sha256 `15e3e8db…69986`).
Находки (reslop): `.review/2026-11-04-02.md`, копия в `/tmp/dev-harness-verify/Rev148/review-files/.review/2026-11-04-02.md`.
Кандидат: продуктовый клон `/tmp/dev-harness-verify/Impl148i/mob`, ветка `wip/148/implementer`; клон я не менял (HEAD d5929d6, `git status` чист). Мои прогоны шли в `git clone --shared` с hardlink-копией node_modules в `/tmp/dev-harness-verify/Rev148/mob`; копия удалена после прогона. Харнесс на HEAD `5b0ba4b13eb6…`, node v26.5.1, jest 29.7.0.

## Итог

10 блокеров:
- Б-1. Приёмка п. 4 не исполнена: `prokhod-vkladki.yaml` не запускался ни разу.
- Б-2. Приёмка п. 2: шесть названных негативов не краснеют (мои мутанты).
- Б-3. Предмет «над домашней полосой»: на профиле 390 подписи лейсте закрыты системной жестовой полосой.
- Б-4…Б-8. Расхождения живых кадров с макетом, которые владелец не оговорил (норма 2026-10-20).
- Б-9. И-8: `vorgaenge.group.margin` и `vorgaenge.group.count` не спроецированы.
- Б-10. И-2/И-7: если открыть экран ссылкой с `?mitte=needs`, нажатие Mitte ничего не меняет.

Что выполнено:
- Сьюты, полный jest, typecheck, eslint и пробы 999 зелёные.
- Сверка 123: 16/16 ≥ 0.600, минимум 0.722.
- Манифесты кадров совпадают с SPEC §3.
- Копия verbatim.
- CI-проводка не добавлена, push не было.

## 1. Область правки

Своя команда: `git diff --stat <merge-base> d5929d6`, где merge-base с origin/main = `6240f6306c55`.
Изменено 24 пути, +3974/−69. Все пути ⊆ «ЗОНА implementer»:
- `bootstrap/{tab-shell,gespraech-mitte}.tsx` + 2 сьюта;
- `features/{missions,protection,post}/**` (каталоги в зоне целиком);
- `theme/nav-tokens.ts`, `i18n/ui-copy.ts`, `app/(tabs)/[section].tsx`;
- 4 флоу `.maestro/*`;
- `e2e-vkladki/{e2e.sh,kadry.json,kadry_profil.json}`;
- `.github/workflows/mobile.yml`.

`theme/tokens.ts` не тронут. Чужих общих файлов в diff нет.

- `mobile/ci-screens.json` — diff пуст и против merge-base, и против origin/main `575f16a1acca`.
- `.github/workflows/mobile.yml` — против origin/main diff пуст. Против merge-base +33 строки: это проводка 151 (коммиты main 8f341d6/75aeaf0), перенесённая в ветку. Записи `vkladki` и работника `e2e-vkladki` нет. И-10 соблюдён; шум в diff PR — совет С-1.
- `cmp-mob-002-tabs.yaml`: изменены только 3 ассерта заголовков («Ihre Vorgänge» → «Vorgänge», «Ihre Dokumente» → «Post» ×2). Это в рамках строки ПЕРЕСЕЧЕНИЕ.
- Состав пачки — ровно `e2e.sh` + `kadry.json` + `kadry_profil.json`. Машина полного трека удалена.
- Атомарность: 13 коммитов `9955af5..d5929d6`, у всех автор `implementer`, у всех ссылка на 148. Связки нескольких предметов нет.

## 2. Сырые замеры (своя копия, `cd mobile`)

| команда | rc | вывод |
|---|---|---|
| `npx jest src/bootstrap/__tests__/gespraech-mitte.test.tsx src/bootstrap/__tests__/vkladki-tab-shell.test.tsx src/features/missions/__tests__/vkladki.test.tsx src/features/protection/__tests__/schutz-uebersicht.test.tsx src/features/post/__tests__/post-eingang.test.tsx` | 0 | `Test Suites: 5 passed, 5 total` / `Tests: 55 passed, 55 total` |
| `npm run test` (полный, `jest --ci --runInBand`) | 0 | `Test Suites: 20 passed, 20 total` / `Tests: 204 passed, 204 total` |
| `npm run typecheck` | 0 | без ошибок |
| `npx tsc --noEmit -p tsconfig.json` (гейт 995) | 0 | без ошибок |
| `npx eslint . --max-warnings=0` | 0 | пусто |
| `node scripts/check-structure.cjs` | 1 | 25 отказов (разбор ниже) |
| `npm run lint` | 1 | структура 1 → eslint не дошёл (прогон отдельно, выше: rc 0) |
| `python3 fixtures/workshop_project/nav_999/nav_probe.py --repo .` | 0 | 238 клеток, все `rc=0` (подсчёт по выводу) |
| `… ui_probe.py --repo .` | 0 | 18/18 |
| `… shell_static_probe.py --repo .` | 0 | 6/6 |
| `… copy_probe.py --repo .` | 0 | 51/51 |
| `scripts/sverka_maketa.py --manifest e2e-vkladki/kadry.json --kadry /tmp/dev-harness-verify/Impl148i/frames/maestro-out-vkladki --repo /tmp/dev-harness-verify/ctxroot-mob` | 0 | GA-02 d/l 0.833/0.833; GA-03 0.864/0.811; GA-04 0.722/0.748; GA-09 0.764/0.822 |
| то же, `kadry_profil.json` | 0 | GA-02 393 0.886/0.873; GA-03 0.850/0.838; GA-04 0.817/0.820; GA-09 0.879/0.853 |
| `kadry_check.py` (свой: имя записи ↔ id ↔ файл ↔ SHA256SUMS ↔ SPEC §3) | 0 | 16/16 записей OK, множество == SPEC §3; маски 36/20 (390) и 48/20 (393); порог 0.6 |
| `copy_check.py` (свой: новые ключи ui-copy против copy-de.json 1.1) | 0 | база 24 ключа → 70; новых 46, изменённых 0, удалённых 0. 45 ключей verbatim (text+status). `extension.MX01.title` — alt_key записи `frame.F40.01.title` (тоже verbatim) |
| пины SPEC §1 (`sha256sum` пяти файлов пакета в ctxroot-mob) | 0 | все 5 совпали |
| junit Maestro (артефакты Impl148i) | — | 4 отчёта, все `status="SUCCESS"`: `vkladki` @5570 dark/light, `vkladki-tabshell-393` @5576 dark/light. Отчёта `prokhod-vkladki` нет (Б-1) |

Разбор lint (п. 3), своя мера. `check-structure.cjs` на чистом worktree origin/main `575f16a` даёт rc 1 и **17** отказов: `e2e-erstinformation/*` (8), `e2e-first-run/*` (8), `kompozicija.stand-in.sh` (1). На OBJECT отказов 25: эти 17, плюс 5 `.harness/*`, плюс 3 `e2e-vkladki/*`.
- `.harness/*`: в ветке старая `structure-policy.json`. В main добавлен `.harness` в `externalTrees` и `package.json` в `repositoryFiles`. Ожидаемо, снимается rebase.
- `e2e-vkladki/*`: ожидаемо по контракту (И-10, «незарегистрированная пачка честно отказывает инвентаризацией»).
- 17 отказов есть и в main. CI main выносит пачки по карте и `kompozicija.stand-in.sh` до lint (`mobile.yml:411-432`).

Итого lint rc 1 ожидаем до И-10 и не блокирует. Число «16 предсуществующих» из задания — это 16 отказов e2e-пачек; 17-й (`kompozicija.stand-in.sh`) тоже лежит в main.

Заявленное против сделанного (своя мера):
- Совпадают: 5/55 и 20/204 jest; пробы 238/18/6/51; сверка 16/16, минимум 0.722; 25 отказов структуры.
- Не совпадает: отчёт Impl148i §6 «геометрии уровня компонентов в tokens.json 1.1 нет» — ложь (С-2).
- Не совпадает: отчёт §4 «Maestro … Passed» относится только к двум флоу из трёх, названных в п. 4 (Б-1).

## 3. Проверка не переписана под реализацию

`git log` по `mobile/src/**/__tests__/*` в диапазоне `9955af5..d5929d6`: тесты менялись только в a764cd0 (перенос из PR #147) и в 6f9e982/6c7a305. Между a764cd0 и 6b5ef76 diff тестов пуст.

Единственная правка тестов в Impl148i: в `zonaVysota` трёх сьютов добавлен `hitSlop.top+bottom`. Это прямо разрешено И-6 («…hitSlop…»). Это же совпадает с SPEC §4 («Optionen ansehen» 146×36 при зоне hh 44) и с `.p-btn-sm::before { inset: -4px 0 }` макета. Пороги не снижены, цели из списков не выброшены.

Правки раскладки проверил по исходнику макета:
- три колонки уведомления — `.p-notice { grid-template-columns: 20px minmax(0,1fr) auto }` и `.p-notice .p-btn { margin: -8px -12px -8px 0 }` (bundle.css:90,99);
- поля группы — `margin: var(--space-8) 4px 10px` (GA-02.html);
- скелет-полоски 55/100/85/40 % и card-raised — bundle.css:143-144.

Правки следуют источнику, но не до конца: упущены `max-width: 70%` у `.p-doc-lines`, кромка `.p-card`, `.p-seg` (Б-4/Б-5).

Изъян самих сьютов: зона считается только по высоте, а целей лейсте на 393 и их видимости сьюты не касаются. Подробно — §4.

## 4. Красное предъявлено (свои мутанты, своя копия, `mutanty.py`, после каждого — `git checkout`; `git status mobile/src` в конце пуст)

| мутант | свойство контракта | факт | что упало |
|---|---|---|---|
| M1 `disabled` на «Optionen ansehen» | И-7 выключенная цель | **RED** rc=1 | Schutz «свой обработчик» 390+393 |
| M2 `pointerEvents="none"` на ссылке документов | И-7 | **RED** rc=1 | то же |
| M3 Beitrag → `onVertraege` | И-7 общий обработчик | **RED** rc=1 | то же |
| M4 высота ссылки документов 36 | И-6 зона < 44 на хозяине | **RED** rc=1 | «зоны целей» 390+393 |
| M5 `onLuecke` только на 390 | И-7 один профиль | **RED** rc=1 | Schutz 393 «свой обработчик» |
| M6 чип received → `onFiltr('sent')` | И-7 чужой пост-эффект | **RED** rc=1 | Post «свой обработчик» 390+393 |
| M13b TabShell не рендерит слот | п. 2 удалённый слот | **RED** rc=1 | «слот ЗАМЕНЯЕТ заголовок», «переключение вкладки» |
| M7 вкладка `flexBasis:20, flexGrow:0` | п. 2 узкая flexBasis-ширина | **GREEN** 55/55 | — (Б-2a) |
| M8 Mitte без `onPress` на 393 | п. 2 действие на одном профиле | **GREEN** 55/55 | — (Б-2b) |
| M9 подпись вкладки `opacity: 0` | п. 2 прозрачная надпись | **GREEN** 55/55 | — (Б-2c) |
| M10 `ab.y(48)` вместо `NAV.item.minHeight` | п. 2 литерал вместо токена | **GREEN** 55/55 | — (Б-2d) |
| M11 полоса Bereiche 30 pt | И-6 / SPEC §4 цель 358×54 | **GREEN** 12/12 | — (Б-2e) |
| M12 Verträge ↔ Beitrag обменялись обработчиками | И-7 «свежий счётчик после собственного нажатия» | **GREEN** 12/12 | — (Б-2f) |
| M13a композиция без слота Vorgänge | п. 2 удалённый слот (композиция) | **GREEN** 20/204 полного jest | ловит только Maestro (С-6) |

Три свойства, названные в задании (выключенная цель, общий обработчик, зона < 44 на хозяине), краснеют. Шесть других негативов из п. 2 зелёные.

Отдельный живой прогон, throwaway jest рендерит настоящий `app/(tabs)/[section].tsx`:
- `{"section":"vorgaenge"}`: «… – In Arbeit», бейдж=false → после нажатия «… – Ihre Rückmeldung nötig», бейдж=true. PASS.
- `{"section":"vorgaenge","mitte":"needs"}`: до и после нажатия «… – Ihre Rückmeldung nötig», бейдж=true. **FAIL** rc=1 (Б-10).

## 5. Сверка с макетом (изображения открыты и сравнены глазами; пары «макет | кадр» — `/tmp/dev-harness-verify/Rev148/pary/<GA>_<тема>_<профиль>.png`, увеличенные вырезки — `pary/zoom-*.png`)

Эталон: `/tmp/dev-harness-verify/ctxroot-mob/docs/ux/05_Kompakt_D24/frames/<имя>`; sha совпадает с SHA256SUMS и SPEC §3. Живой кадр: `/tmp/dev-harness-verify/Impl148i/frames/maestro-out-vkladki/<путь>`. Число — балл меры 123.

| кадр | макет | живой кадр | балл | расхождения (глазами) |
|---|---|---|---|---|
| GA-02 dark 390 | GA-02_normal_dark_390x844.png | dark/2026-11-04_220133/vkladki/takeScreenshot/vkladki-vorgaenge.png | 0.833 | часы статус-бара поверх wordmark (В); жестовая полоса поверх «Gespräch/Vorgänge» (Б-3); значок профиля 20 и прижат вправо (Б-6); «Frist bis 24.10.» без выделения (Б-8); перенос «Empfehlung» (шрифт, С-9) |
| GA-02 light 390 | GA-02_normal_light_390x844.png | light/2026-11-04_220200/vkladki/takeScreenshot/vkladki-vorgaenge.png | 0.833 | то же + нет кромки карточек (Б-5) |
| GA-02 dark 393 | GA-02_normal_dark_393x852.png | dark/2026-11-04_220251/vkladki-tabshell-393/takeScreenshot/vkladki-vorgaenge-393.png | 0.886 | Б-6, Б-8, шрифт; статус-бар платформы вместо iOS (замаскировано 48) |
| GA-02 light 393 | GA-02_normal_light_393x852.png | light/2026-11-04_220321/vkladki-tabshell-393/takeScreenshot/vkladki-vorgaenge-393.png | 0.873 | Б-5, Б-6, Б-8, шрифт |
| GA-03 dark 390 | GA-03_normal_dark_390x844.png | dark/2026-11-04_220133/vkladki/takeScreenshot/vkladki-schutz.png | 0.864 | (В), Б-3, Б-6; «Familie» без голов, «Mobilität» другой силуэт (Б-7); «Optionen ansehen» на ≈6 pt выше первой строки текста; переносы уведомления другие (шрифт); бейдж Mitte есть |
| GA-03 light 390 | GA-03_normal_light_390x844.png | light/2026-11-04_220200/vkladki/takeScreenshot/vkladki-schutz.png | 0.811 | то же + нет кромки StatCard (Б-5) |
| GA-03 dark 393 | GA-03_normal_dark_393x852.png | dark/2026-11-04_220251/vkladki-tabshell-393/takeScreenshot/vkladki-schutz-393.png | 0.850 | Б-6, Б-7, позиция «Optionen ansehen», шрифт |
| GA-03 light 393 | GA-03_normal_light_393x852.png | light/2026-11-04_220321/vkladki-tabshell-393/takeScreenshot/vkladki-schutz-393.png | 0.838 | Б-5, Б-6, Б-7, шрифт |
| GA-04 dark 390 | GA-04_normal_dark_390x844.png | dark/2026-11-04_220133/vkladki/takeScreenshot/vkladki-post.png | 0.722 | (В), Б-3, Б-6; нет дорожки сегмент-контрола (Б-4a); второе письмо «Kfz-Versicherung · KV-2048-7731 / Sep 02» вместо «Beitragsanpassung · Musterversicherung AG / Okt 13» (Б-4b); чип «Antwort ausstehend» нечитаем: светлый текст на светлом, точки нет (Б-4c); ссылка без muted и подчёркивания (Б-4d); скелет на всю ширину (Б-4e) |
| GA-04 light 390 | GA-04_normal_light_390x844.png | light/2026-11-04_220200/vkladki/takeScreenshot/vkladki-post.png | 0.748 | то же, кроме контраста чипа (точки нет); + Б-5 |
| GA-04 dark 393 | GA-04_normal_dark_393x852.png | dark/2026-11-04_220251/vkladki-tabshell-393/takeScreenshot/vkladki-post-393.png | 0.817 | Б-4a…e, Б-6; внизу «Sep» вместо «Okt» |
| GA-04 light 393 | GA-04_normal_light_393x852.png | light/2026-11-04_220321/vkladki-tabshell-393/takeScreenshot/vkladki-post-393.png | 0.820 | Б-4a/b/d/e, точки чипа нет, Б-5, Б-6 |
| GA-09 dark 390 | GA-09_normal_dark_390x844.png | dark/2026-11-04_220133/vkladki/takeScreenshot/vkladki-vorgaenge-skroll.png | 0.764 | прокрутка на ≈3 pt меньше (25–26 против 28, С-10); прокрученный wordmark и значок профиля видны под часами статус-бара (В); Б-3, Б-8; «Alle erledigten Vorgänge» уходит под лейсте, как в макете |
| GA-09 light 390 | GA-09_normal_light_390x844.png | light/2026-11-04_220200/vkladki/takeScreenshot/vkladki-vorgaenge-skroll.png | 0.822 | то же + Б-5 |
| GA-09 dark 393 | GA-09_normal_dark_393x852.png | dark/2026-11-04_220251/vkladki-tabshell-393/takeScreenshot/vkladki-vorgaenge-skroll-393.png | 0.879 | Б-6, Б-8; сдвиг близок к макету |
| GA-09 light 393 | GA-09_normal_light_393x852.png | light/2026-11-04_220321/vkladki-tabshell-393/takeScreenshot/vkladki-vorgaenge-skroll-393.png | 0.853 | Б-5, Б-6, Б-8 |

Совпадает по существу во всех 16 кадрах:
- лейсте из пяти слотов, порядок Start | Vorgänge | Gespräch | Schutz | Post, иконки UICONS, активная вкладка выделена;
- в GA-03 бейдж Mitte есть, в GA-02/04/09 его нет;
- палитра dark/light: ground, card, panel, accent-text, calm-чип «Complior»;
- группы IN ARBEIT / WARTEN AUF ANTWORT / ERLEDIGT с точками и счётчиками;
- состав Schutz: полоса областей, две StatCard, уведомление в три колонки, пять строк со статус-чипами;
- состав Post: карточка отправки, уведомление, блок даты «Okt 14».

Балл 123 (≥0.722) не ловит Б-4…Б-8: мера сравнивает чернила, а не цвет, текст и состав.

(В) — вопрос владельцу. Пакет 390×844 не содержит статус-бара: wordmark стоит на y 19–41 pt, внутри маски `chrome_verh_pt` 36. На AVD 390 шапка кладётся от y 0 (edge-to-edge), и системные часы рисуются поверх wordmark, а значок профиля стоит рядом со значками батареи. На любом реальном Android с ненулевым верхним инсетом будет так же. Чтобы читать верхний инсет, нужно решение владельца: как артборд 390 без системного хрома ложится на устройство с хромом. Нижний край (Б-3) оговорён самим Предметом («над домашней полосой»), поэтому он блокирует.

## 6. Граница ленда и предпосылки

- CI-проводка не добавлена: diff `ci-screens.json`/`mobile.yml` с origin/main пуст, записи `vkladki` и работника `e2e-vkladki` нет.
- Push не выполнялся. Своя мера: `git ls-remote ssh://git@github.com/a3ka/Complior-mob.git refs/heads/wip/148/implementer` → `9955af5e8b0a…`, это PR #147, а не 6b5ef76 или d5929d6. Ref клона `origin/wip/148/implementer`=6b5ef76 остался от клонирования из клона Impl148h и в удалённый репозиторий не попал.
- Граница п. 6 не нарушена.
- ПРОВОДКА (038): guard `fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh` есть в дереве харнесса. В `registry/ci-steps.tsv` он не подключён: это решение оркестратора в окне freeze..done. Обоснование ПРОВОДКА-ЭНФОРСМЕНТ честное: замороженная батарея полного трека не является приёмкой лёгкого трека.
- sourceCanon проекта null — сверка 996 не применяется.

## СВЕРКА-СТАНДАРТОВ

`AGENTS.md` продукта объявляет `STRUCTURE.md` стандартом размещения кода и D24-Kompakt-1.1 эталоном. ARCHITECTURE/CODING-STANDARDS у моба не объявлены.

- `STRUCTURE.md §1/§2` (место кода) — соответствует: домены `features/{missions,protection,post}` с `components/model/__tests__`; `theme/nav-tokens.ts` в слое theme; Mitte в bootstrap; композиция в `app/(tabs)`.
- `STRUCTURE.md §4` (направления импортов) — соответствует: фичи не импортируют bootstrap, артборд передаётся пропом; межфичевых импортов нет; eslint-границы rc 0. Одно но: `app/(tabs)/[section].tsx:74,95` несёт параметр маршрута без потребителя (Б-10).
- `STRUCTURE.md §6` (theme как проекция, экран не заводит свой размерный ряд) — расхождение:
  - `VorgaengeListe.tsx:63-79`: литеральные размеры при наличии токенов (С-2, Б-9);
  - `SchutzUebersicht.tsx` (ab.w(10)/ab.w(7)/ab.w(6)/ab.w(3.5)) и `PostEingang.tsx` `skelettStrok.height: 10` (С-3);
  - `tab-shell.tsx`: `ab.w(20)` значка профиля вместо `HEADER.profile.icon` (Б-6).
- `STRUCTURE.md §7` (тесты colocated, Maestro) — соответствует для colocated. Имена флоу `vkladki*.yaml` вместо `cmp-mob-NNN-*` заданы замороженным контрактом, а контракт старше по приоритету AGENTS.md.
- `STRUCTURE.md §7.1` (пачки) — расхождение ожидаемо по контракту (И-10): `mobile/e2e-vkladki/*` даёт 3 отказа инвентаризации.
- `AGENTS.md` п. 3 (D24-Kompakt-1.1: `source/tokens.json` — визуальные токены, RN реализует эталон нативно) — расхождение: Б-4…Б-8 (кадры против эталона), Б-9 (токены).
- `AGENTS.md` «Новый экран — со сценарием Maestro и скриншотом» — расхождение: сценарий прохода `prokhod-vkladki.yaml` не исполнялся (Б-1).

## Паразитная сложность (050)

Формат строки: (1) свойство контракта | (2) состояние | (3) файлы, меняющиеся вместе | (4) глубина | (5) потребитель → класс.

- `bootstrap/tab-shell.tsx` (+407/−69): (1) И-1 слоты, И-3 оверлей, И-8 nav.*, профиль 393 из И-9 | (2) section/route явные; профиль окна выбирается неявно по равенству 393×852±1 (`profileFor`) и виден только побочным эффектом раскладки | (3) геометрия nav: nav-tokens + tab-shell + gespraech-mitte, рост оправдан | (4) +2 пропа, +`useArtboard`; работы за интерфейсом много, модуль глубокий | (5) `[section].tsx`, сьюты, пробы 999 → слоты ESSENTIAL. Выбор профиля по размеру окна — корень Б-3; более простая форма (реальные инсеты) не доказана против п. 4, поэтому только совет внутри Б-3.
- `bootstrap/gespraech-mitte.tsx` (новый, 149): (1) И-2 | (2) статус — явный проп | (3) 1 | (4) 4 пропа | (5) композиция, сьют → ESSENTIAL.
- `theme/nav-tokens.ts` (новый, 191): (1) И-8 | (2) нет | (3) токен меняется в 1 файле, но литералы-обходы (Б-9, С-2) делают 2+ | (4) константы + `typo()` | (5) все экраны 148 → ESSENTIAL. `COLOR` — второй набор палитры рядом с `theme/tokens.ts` (палитра 999); это необходимо, потому что `tokens.ts` пинит проба 999.
- `features/{missions,protection,post}` — 3 компонента + 3 model (одно семейство): (1) И-4, И-7 | (2) `aktivId`/`filtr` — явные пропы | (3) — | (4) 5–7 колбэков на экран, этого требует И-7 «свой обработчик» | (5) композиция, сьюты → ESSENTIAL.
- `app/(tabs)/[section].tsx` (+77): (1) композиция, мок-отклик И-2/И-7 | (2) `mittePerekljuchen`/`postFiltr`/`aktiv` явные; **параметр `?mitte=needs` — вход без потребителя** | (3) 1 | (4) — | (5) потребителя у параметра нет ни во флоу, ни в сьюте → **ACCIDENTAL** (фрагмент `[section].tsx:74,95,99-103`; свойство отсутствует; более простая форма — удалить параметр — проходит те же строки) и дефект поведения: Б-10.
- `e2e-vkladki/e2e.sh` (153): (1) И-9 (порядок AVD, порты) | (2) env `VKLADKI_*`, `PORT_393`, `MAESTRO_*`, `E2E_DIAG_LOG`, `E2E_TRACE`; ветка `systemd-run` зависит от хоста | (3) 1 + станционная обёртка | (4) интерфейс из 8 env растёт быстрее функции: у `E2E_TRACE` потребителя не нашёл | (5) стенд станции; после И-10 — работник → ветка `systemd-run` ACCIDENTAL (С-4), остальное ESSENTIAL.
- `kadry.json`/`kadry_profil.json`: (1) И-9 два профиля | (2) нет | (3) 2 (по профилю) | (4) — | (5) сверка 123 → ESSENTIAL.
- Maestro-флоу ×3 + правка cmp-mob-002: (1) п. 4 | (5) `prokhod` не имеет исполнителя в пачке (Б-1) → ESSENTIAL, но не исполнен.
- Сьюты экрана ×5 (одно семейство): (1) п. 2 | (2) нет | (5) `npm test` → ESSENTIAL, неполные (Б-2).
- `i18n/ui-copy.ts` (+46 ключей): (1) И-5 | (5) экраны; у `extension.MX01.title` потребителя нет → совет С-5.

## Находки

Блокеры. Каждый указан в формате: обязательство / класс / достижимое состояние / наблюдение / закрывающее свойство. Подробности — в `.review/2026-11-04-02.md`.

- **Б-1** — п. 4 / не проверено / OBJECT. Отчёта `prokhod-vkladki.yaml` нет; `e2e.sh` его не вызывает. Закрывает: зелёный junit `prokhod-vkladki` на APK из кандидата.
- **Б-2a…f** — п. 2 (И-6/И-7/И-8) / барьер не краснеет / мутанты M7, M8, M9, M10, M11, M12 / все GREEN. Закрывает: каждый мутант RED своим ассертом.
- **Б-3** — Предмет «над домашней полосой», И-3 / инсеты устройства не читаются / любое окно ≠393×852±1 / в 8 кадрах 390 жестовая полоса поверх подписей. Закрывает: низ лейсте ≥ нижнего safe-area-инсета.
- **Б-4a…e** — норма владельца 2026-10-20 (сверка с макетом), И-4 / неоговорённое расхождение / GA-04 ×4. Нет `.p-seg`, данные писем перепутаны, чип нечитаем в dark и без точки, ссылка без стиля, скелет 100 %. Закрывает: состав, данные и цвета совпадают с GA-04.html и bundle.css.
- **Б-5** — та же норма / нет кромки `.p-card` в light / 8 light-кадров. Закрывает: borderWidth 1, цвет card-border в light.
- **Б-6** — та же норма, И-8 (`HEADER.profile.icon` есть в проекции) / значок 20 и прижат вправо / 16 кадров. Закрывает: 24 по центру цели 44.
- **Б-7** — та же норма / глифы «Familie» (без голов) и «Mobilität» / GA-03 ×4. Закрывает: глифы `users`/`car` макета.
- **Б-8** — та же норма / нет `<b>` в «Frist **bis 24.10.**» / GA-02/09 ×8. Закрывает: выделение срока.
- **Б-9** — И-8, класс 2 / `vorgaenge.group.margin` литералом, `.count` 13/18 вместо 12/16 / OBJECT. Закрывает: оба токена в проекции и читаются компонентом.
- **Б-10** — И-2/И-7 / вход `?mitte=needs` глушит отклик / deep link complior://vorgaenge?mitte=needs / живой jest: до == после, rc=1. Закрывает: нажатие Mitte меняет видимое состояние на любом входе (проще — удалить параметр).

Советы: С-1…С-10 (в `.review`). Это rebase ради чистого diff и lint; ложное заявление о токенах в отчёте; §6 размерный ряд; ветка `systemd-run`; неиспользуемый alias-ключ; слот в композиции ловит только Maestro; кадры сняты до коммита; приблизительное правило зоны; DM Sans против Roboto и знак Mitte 28 против камешка 24 — решения владельца; сдвиг GA-09 можно запинить в SPEC.

Вопрос владельцу (В): шапка на профиле 390 лежит под системным статус-баром. Принять edge-to-edge, раз в макете 390 нет статус-бара и маска 36 его скрывает, или требовать верхний инсет?

Повторный суд после починки — scoped по Б-1…Б-10 на новом SHA. Accept этого вызова к изменённому кандидату не применяется.
