FAIL
OBJECT=488a97f36d5d627af2b8d611feec9f75e8a1d45d
КЛАСС=кодовый; риск=обычный (подтверждён: оболочка навигации и мок-контент вкладок; прав, ролей, авторизации, сети, денег, ПД нет — оснований повышать нет)
СУД: repo=Complior-mob (PR a3ka/Complior-mob#168, ветка wip/148/implementer-rebuild); предмет=148 (vkladki-tabov); фаза=реализация; роль=reviewer; вызов=1/1 (полный, по новому OBJECT); модель-план=anthropic/claude-opus-5-5; session-id=Rev148v2 (сессия c907157c); модель-факт=anthropic/claude-opus-5-5; предыдущий=нет

# Вердикт reviewer — 148 vkladki-tabov, реализация (пересборка, PR #168)

Контракт: `frozen/contracts/148/4` → `2adad8b61927450644329f282892db70f3fd88ef`.
- В origin харнесса тега нет. Тег взят из основного чекаута только чтением: `git fetch /home/harness/dev-harness refs/tags/frozen/contracts/148/4`.
- Дерево тега — одноразовый worktree `/tmp/dev-harness-verify/Rev148v2/c4`.
- Блоб контракта по сути (§Предмет и инварианты, §Приёмочный критерий) совпадает с `origin/wip/148/architect`.

Находки reslop: `.review/2026-11-12-02.md`, `status: ready`. Лежит в клоне `/tmp/dev-harness-verify/Rev148v2/repo` и в коммит не входит — так требует задание.

Клоны:
- продукт `/tmp/dev-harness-verify/Rev148v2/mob`: `git rev-parse HEAD` = `488a97f36d5d627af2b8d611feec9f75e8a1d45d` = OBJECT, `git status` чист;
- харнесс `/tmp/dev-harness-verify/Rev148v2/repo`;
- чистый main продукта — `/tmp/dev-harness-verify/Rev148v2/mainmob`.

Зонд, мутанты и throwaway-тесты гонялись только в одноразовой копии `/tmp/dev-harness-verify/Rev148v2/zt/mobile` (node_modules — симлинк). После прогонов `diff -rq zt/mobile/src mob/mobile/src` показывает только два положенных файла зонда.

**Итог.** По коду всё, что исполнимо без эмулятора, зелёное:
- зона чистая, overlay побайтово равен `ff0850e6b`;
- jest 243/243, typecheck, полный tsc и eslint дают rc 0;
- 995 и все четыре 999-пробы дают rc 0, как на чистом main;
- safe-area Б-3: гейты, зонд и мутанты в норме;
- все 14 моих негативов п. 2 краснеют.

Принять нельзя по трём причинам:
1. Кадров эмулятора нет, сверять с макетом нечем.
2. Манифест кадров 390 отошёл от замороженного SPEC §3.
3. Легаси-флоу 999 не проходит — это противоречие внутри контракта.

## БЛОКИРУЕТ

| ID | Обязательство | Наблюдение (своя мера) | Класс | Кто закрывает |
|---|---|---|---|---|
| Р148-Б1 «нечем сверить» | roles/reviewer.md §«Мобильный экран — сверка с макетом» (слово владельца 2026-10-20); приёмка п. 4; живая часть Б-3 («НЕ ЗАЩИЩАЕТ: … живые кадры — ревьюер») | Единственный run по OBJECT — 43170563774 `completed/failure`. `build-apk` и все `e2e-*` skipped, артефактов 0 (у предыдущего 43161917403 тоже 0). Ждать нечего: run завершён, а не в очереди. Кадров эмулятора и junit трёх флоу п. 4 на OBJECT не существует | нечем сверить (не проверено) | оркестратор: CI после И-10 либо станционный прогон `e2e.sh` на APK из OBJECT → scoped-суд сверки |
| Р148-Б2 карта кадров 390 | И-9 («эталон — 16 кадров SPEC §3 … байты == frames/SHA256SUMS»; «маски: шапка chrome_verh_pt 36 у 390»); п. 4 («маски и пины по SPEC §3»); п. 5 задания «карта kadry.json не ослаблена» | `mobile/e2e-vkladki/kadry.json`: 8/8 записей 390 ссылаются на `fixtures/workshop_project/vkladki_tabov_148/etalony-safe-area-390/*.png`. sha совпадает с SHA256SUMS у 0/8 (GA-02 dark: `516e41ed…` против SPEC §3 `f9e8648c…`). Файлов нет ни в origin/main, ни в `wip/148/architect`, ни во frozen 148/4, ни в `/home/harness/dev-harness`. `mera.chrome_verh_pt`=48 против 36 по SPEC. `_comment` «SHA — из SPEC §3» ложен. `kadry_profil.json` (393) в норме: 8/8 sha == SUMS, маска 48 | отклонение от замороженного инварианта на достижимом состоянии (манифест OBJECT) | implementer (вернуть 390 на кадры пакета, маска 36) ЛИБО оркестратор/architect (заморозить v+1 с производными эталонами — вариант А-964 — и положить эталоны в харнесс) |
| Р148-Б3 легаси-e2e 999 | строка ПЕРЕСЕЧЕНИЕ 999 (`cmp-mob-002-tabs.yaml`: «ассерт Schutz "Ihre Absicherung im Überblick" … не меняются») против И-1/И-4 (контент секции ЗАМЕНЯЕТ заголовок) | Throwaway jest на живом маршруте `(tabs)/[section]` (390, W1A): `REZ {"Vorgänge(exact)":true,"Ihre Absicherung im Überblick(text)":false,"Ihre Absicherung im Überblick(a11y)":false,"Schutz(exact)":true,"Post(exact)":true}`, rc 1. Флоу — `fiksirovannyj_nabor` job `e2e-pilot` (`mobile/ci-screens.json:95-99`) | противоречие контракта, вскрытое исполнением (реализация следует И-4 и макету GA-03) | владелец: ассерт → «Schutz» (как «Vorgänge»/«Post» 31.10) ЛИБО заголовок F19.01 в контенте Schutz |

Других блоков нет.

## Прежние находки (impl-v1 на d5929d6 — Б-1…Б-10; Rev148v1 на a4d82bf — не материализован, Б-1…Б-3) — все перепроверены исполнением

| ID | Было | Сейчас (своя мера) | Статус |
|---|---|---|---|
| impl-v1 Б-1 | `prokhod-vkladki` не исполнялся | `e2e.sh` принимает имя флоу аргументом (`f="mobile/.maestro/$flow.yaml"`), значит `prokhod-vkladki` запускаем. Прогона на OBJECT нет | открыт → Р148-Б1 |
| impl-v1 Б-2a…f | шесть негативов п. 2 зелёные | все 14 моих мутантов RED (§2) | закрыт |
| impl-v1 Б-3 | лейсте в жестовой полосе 390 | `_layout.tsx:14` SafeAreaProvider; `tab-shell.tsx:200` `useContext(SafeAreaInsetsContext)`; `:511` `Math.max(allowance, insets.bottom)`. Зонд 3/3, оба мутанта RED. На живых кадрах не видел | по коду закрыт; живая часть → Р148-Б1 |
| impl-v1 Б-4…Б-8 | расхождения с макетом GA-02/03/04/09 | Код изменён: `.p-seg` (`PostEingang.tsx:127-156`), данные писем (`post-dannye.ts:43-48`), точка статуса (`:320`), `vorgangLink` underline (`:395`), скелет `maxWidth 70%` (`:280`), cardBorder (7 мест), глифы `car`/`users` (`schutz-dannye.ts:41,84`), профиль `HEADER.profile.icon` 24 (`tab-shell.tsx:337`), срок `fristSrok` weight 500 (`VorgaengeListe.tsx:465`). Визуально не проверено | открыт до кадров → Р148-Б1 |
| impl-v1 Б-9 | `vorgaenge.group.*` литералами | `VorgaengeListe.tsx:188-191,204,222` читают `VORGAENGE_GROUP.*` из `theme/nav-tokens.ts:154`. Гейт `proverka_tokenov` → OK | закрыт |
| impl-v1 Б-10 | `?mitte=needs` глушит отклик | тест «нажатие Mitte меняет видимое состояние и на входе ?mitte=needs» зелёный в `vkladki-tab-shell.test.tsx` | закрыт |
| Rev148v1 Б-1 | `vkladki-kompoziciya.test.tsx` вне зоны | файла в diff нет. 3 теста перенесены дословно в `vkladki-tab-shell.test.tsx:404-439` (diff ff0850e6b..HEAD: +60/−1, только этот файл) | закрыт |
| Rev148v1 Б-2 | `cmp-mob-002` «Ihre Absicherung…» | перепроверено своим jest — красный | открыт → Р148-Б3 |
| Rev148v1 Б-3 | кадры не сняты | CI на OBJECT кадров не дал | открыт → Р148-Б1 |

## 1. Область правки (свои команды)

```
$ git -C mob merge-base origin/main HEAD
cbb254fe8786805aecb9190a53ebe21acbc06952
$ git -C mob diff --name-status origin/main...HEAD        # 24 files +4601 -72
M mobile/.maestro/cmp-mob-002-tabs.yaml        A mobile/.maestro/prokhod-vkladki.yaml
A mobile/.maestro/vkladki-tabshell-393.yaml   A mobile/.maestro/vkladki.yaml
A mobile/e2e-vkladki/{e2e.sh,kadry.json,kadry_profil.json}
M mobile/src/app/(tabs)/[section].tsx          M mobile/src/app/_layout.tsx
A mobile/src/bootstrap/__tests__/{gespraech-mitte,vkladki-tab-shell}.test.tsx
A mobile/src/bootstrap/gespraech-mitte.tsx     M mobile/src/bootstrap/tab-shell.tsx
A mobile/src/features/missions/{__tests__/vkladki.test.tsx,components/VorgaengeListe.tsx,model/vkladki-dannye.ts}
A mobile/src/features/post/{__tests__/post-eingang.test.tsx,components/PostEingang.tsx,model/post-dannye.ts}
A mobile/src/features/protection/{__tests__/schutz-uebersicht.test.tsx,components/SchutzUebersicht.tsx,model/schutz-dannye.ts}
M mobile/src/i18n/ui-copy.ts                   A mobile/src/theme/nav-tokens.ts
$ git -C mob log --format='%H %an %s' origin/main..HEAD
488a97f36d5d… implementer 148 vkladki-tabov: сьют композиции маршрута — внутрь зонного vkladki-tab-shell.test.tsx (Б-1)
a4d82bfa76fb… implementer 148 vkladki-tabov: пересборка реализации экрана на актуальном main продукта
```

- Все 24 пути ⊆ строкам `ЗОНА implementer:` блоба 148/4. `.maestro/{vkladki,vkladki-tabshell-393,prokhod-vkladki,cmp-mob-002-tabs}.yaml`, `e2e-vkladki/`, `src/app/` и `features/{missions,protection,post}/` — каталоги или пути зоны; два сьюта `bootstrap/__tests__`, `tab-shell.tsx`, `gespraech-mitte.tsx`, `ui-copy.ts`, `nav-tokens.ts` — пути зоны.
- `cmp-mob-002-tabs.yaml` изменён только в трёх ассертах заголовков («Ihre Vorgänge» → «Vorgänge», «Ihre Dokumente» → «Post» ×2) — в рамках строки ПЕРЕСЕЧЕНИЕ.
- Выхода за зону нет.

Overlay. `ff0850e6bcd714cb653818ac84a5280214af2f76` нет в origin продукта, а клона Impl148v4 нет на диске. Объект я взял из `/tmp/dev-harness-verify/Rev148v1/mob` (`git fetch` по sha):
```
$ git diff --stat ff0850e6b a4d82bf -- <24 пути>     → (пусто)
$ git diff --stat ff0850e6b HEAD   -- <24 пути>
 .../bootstrap/__tests__/vkladki-tab-shell.test.tsx | 61 ++++++++++++++++++++-
```
Из 26 путей F против его базы два в OBJECT не перенесены:
- `vkladki-kompoziciya.test.tsx` — перенесён внутрь зонного сьюта;
- `.github/workflows/mobile.yml` — шум 151.

На OBJECT `grep -c vkladki` по `.github/workflows/mobile.yml` и по `mobile/ci-screens.json` даёт 0 и 0. Проводки нет, И-10 соблюдён.

Атомарность: оба коммита — автор `implementer`, оба ссылаются на 148, чужих предметов нет.

## 2. Реализация по сути (И-1…И-10, п. 1–2а)

Safe-area Б-3 (И-3, п. 2а). Зонд — `produkt/vkladki-zond-148.test.tsx` и носитель `nositeli/tokeny-1-1.json` из frozen-дерева; sha256 обоих совпадает с пинами `source.json`: `d6fb96c0…`, `6d2d7196…`.
```
$ jest --ci --runInBand vkladki-zond-148 -t 'Б-3'
  ✓ Б-3 (390x844, инсет 24): резерв лейсте == нижнему инсету
  ✓ Б-3 (390x844, инсет 48): резерв следует за инсетом, не константа
  ✓ Б-3 (393x852, инсет 34): резерв лейсте ≥ нижнему инсету
Tests: 15 skipped, 3 passed, 18 total        rc=0
$ python3 sud_safe.py mob   (гейты produkt_sud frozen 148/4)
GATE proverka_tokenov -> OK
GATE proverka_provaidera -> OK
GATE proverka_insetov -> OK
GATE proverka_modulja_tokenov -> TOKENY_MODUL_NE_IZ_ISTOCHNIKA: нет mobile/src/bootstrap/kompakt-tokens.ts   (гейт полного трека; лёгкий И-8 — theme/nav-tokens.ts; Н-4)
$ python3 mutanty.py   (якорь 'Math.max(allowance, insets.bottom)', единственный)
== mutant safe-rezerv-nul → allowance:          zond 3 failed rc=1; vkladki-tab-shell 3 failed/24 rc=1
== mutant safe-konstanta  → Math.max(allowance, 24): zond 2 failed rc=1; vkladki-tab-shell 3 failed/24 rc=1
restored True
```
- Инсет читается из контекста, а не задан плоской константой.
- `profileFor` (`tab-shell.tsx:162`) выбирает только артборд и allowance. Резерв `rezervNiz` (`:511`) следует за `insets.bottom` — это форма `66ca8e3d5`, которую судит v+1.

Остальные инварианты:
- И-1: `vkladki-tab-shell.test.tsx` содержит «без слотов остаётся замороженная поверхность: заголовок секции» и «слот контента ЗАМЕНЯЕТ заголовок секции».
- И-2: `gespraech-mitte.tsx` — Pressable, `accessibilityRole="button"`, testID `gespraech-mitte`, `FadenSign size="tab"`, имя по шаблону `proposed.gespraech.tab.a11y.status`. Бейдж — точка `NAV.badge`, рендерится ровно при `needs_user`. Ключей `ui.vorgaenge.group.*` нет.
- Видимого текста статуса у Mitte нет. Макет GA-02/GA-03 390 light я открыл сам: в лейсте только камешек со знаком, точка-бейдж в GA-03 и подпись «Gespräch» — реализация с ним совпадает. Поэтому снятые с головы PR #147 тесты «показывает статус In Arbeit» — правка под макет, а не подгонка.
- 5 слотов: `shell-tab-start`, `shell-tab-vorgaenge`, `gespraech-mitte`, `shell-tab-schutz`, `shell-tab-post`. Mitte стоит перед `schutz` (`tab-shell.tsx:374`), `accessibilityRole="tablist"` стоит на ряду.
- И-8: `proverka_tokenov` (значения проекции против `docs/ux/05_Kompakt_D24/source/tokens.json`) → OK.

Негативы п. 2 — свои мутанты (`mutanty_p2.py`): одна замена с проверкой единственности якоря, прогон пяти сьютов экрана, восстановление.
```
KONTROL rc=0 ['Tests: 83 passed, 83 total']
== M-slot: композиция без слота vorgaenge: RED rc=1 [1 failed]
== M-disabled: Verträge disabled: RED rc=1 [4 failed]
== M-pointerEvents: Dokumente pointerEvents none: RED rc=1 [2 failed]
== M-shared: Beitrag -> onVertraege (общий обработчик): RED rc=1 [4 failed]
== M-swap: Verträge<->Beitrag обменялись: RED rc=1 [4 failed]
== M-zona: Dokumente высота 36 < 44: RED rc=1 [2 failed]
== M-flexBasis: вкладка flexBasis 20, flexGrow 0: RED rc=1 [3 failed]
== M-chip: чип -> чужой пост-эффект (всегда sent): RED rc=1 [2 failed]
== M-literal: ab.y(48) вместо NAV.item.minHeight (вкладка): RED rc=1 [1 failed]
== M-opacity-nadpis: подпись вкладки opacity 0: RED rc=1 [1 failed]
== M-opacity-cel: Mitte opacity 0: RED rc=1 [4 failed]
== M-odin-profil: Mitte onPress только на 390: RED rc=1 [1 failed]
== M-odin-profil-schutz: Lücke только на 390: RED rc=1 [2 failed]
== M-bereiche: полоса областей ~ниже 44 (paddingVertical 1): RED rc=1 [2 failed]
```
14/14 RED. Шесть негативов, которые были зелёными в impl-v1 (M7–M12), теперь краснеют.

## 3. Сырой вывод (перегнал сам)

| команда | rc | вывод |
|---|---|---|
| `cd mobile && npm ci --no-audit --no-fund` | 0 | `added 1114 packages in 6s` |
| `npm test` | 0 | `Test Suites: 21 passed, 21 total` / `Tests: 243 passed, 243 total` |
| `npm run typecheck` (`tsc --noEmit -p src/lib/faden/tsconfig.json`) | 0 | пусто |
| `npx tsc --noEmit -p tsconfig.json` (полный) | 0 | пусто |
| `npx eslint --max-warnings=0 src` | 0 | пусто |
| `npx eslint . --max-warnings=0` | 0 | пусто |
| `npm run lint` | 1 | 20 × «file outside allowed location/type». На чистом main `node scripts/check-structure.cjs` даёт 17 (rc 1). Разница — `e2e-vkladki/{e2e.sh,kadry.json,kadry_profil.json}`, ожидаемо до И-10 |
| `python3 <H>/fixtures/workshop_project/pilot_995/bundle_probe.py --repo mob` | 0 | 3 строки, ненулевых rc 0; `995 bundle elapsed=20.9s` |
| `… nav_999/shell_static_probe.py` | 0 | 6 клеток, все rc=0 |
| `… nav_999/nav_probe.py` | 0 | 238 клеток, все rc=0 |
| `… nav_999/ui_probe.py` | 0 | 18 клеток, все rc=0 |
| `… nav_999/copy_probe.py` | 0 | 51 клетка, все rc=0 |
| те же пять на чистом main (`mainmob`) | 0 | 3/6/238/18/51, все rc=0 — ухудшений нет |
| `bash c4/fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh --repo mob` | 1 | `клеток 37, зелёных 36, красных 1`; красная `pr-chestnaja`: `PRICHINA PACHKA_ABSENT: нет mobile/e2e-vkladki/ekran.json` (Н-3) |
| полный зонд `jest vkladki-zond-148` | 1 | `Tests: 12 failed, 6 passed, 18 total`. Все 12 вне Б-3: testID контента полного трека, высота лейсте 77.4 с резервом против 49, текст бейджа. Совпадает с «НЕ ЗАЩИЩАЕТ» (12 на aa0127838) — Н-4 |

## 4. Сверка с макетом

Норма 2026-10-20 требует кадр эмулятора рядом с PNG-макетом. Кадров нет: см. §6 и Р148-Б1.

| кадр | макет (пакет, sha по SPEC §3) | кадр эмулятора | расхождения | класс |
|---|---|---|---|---|
| GA-02/03/04/09 × dark/light × 390 (8) | `docs/ux/05_Kompakt_D24/frames/GA-0{2,3,4,9}_normal_{dark,light}_390x844.png` | нет (run 43170563774: build-apk skipped, артефактов 0) | нечем сверить | блок Р148-Б1 |
| GA-02/03/04/09 × dark/light × 393 (8) | `docs/ux/05_Kompakt_D24/frames/GA-0{2,3,4,9}_normal_{dark,light}_393x852.png` | нет | нечем сверить | блок Р148-Б1 |

Что установлено без кадров:
- Макеты GA-03 light 390 и GA-02 light 390 я открыл сам. Лейсте: Start | Vorgänge | камешек «C» с подписью Gespräch | Schutz | Post. В GA-03 тёплая точка-бейдж над камешком. Над лейсте статус-бара нет.
- Реализация Mitte по коду совпадает с этим составом.
- Для кадров 390 манифест пачки ссылается не на эти PNG (Р148-Б2).

Чего нет: самих кадров эмулятора. Поэтому положение лейсте над жестовой полосой на AVD, шрифты, отступы и цвет не проверены.

## 5. Неподгонка проверок под код

- `git diff origin/main...HEAD -- 'mobile/src/**/__tests__/*' | grep` по `.skip/.only/.todo/xit/xdescribe/fit/fdescribe` → пусто, rc 1.
- Число `it(`: gespraech-mitte 9, vkladki-tab-shell 24, missions 8, schutz 8, post 9.
- Все сьюты написаны implementer — так велит зона контракта для лёгкого трека.
- Снятые относительно головы PR #147 (`9955af5e`) ассерты видимого статуса Mitte заменены ассертами a11y-имени и бейджа. Это соответствует макету (§2). Пороги зон не снижены: 14 мутантов краснеют.
- Карта `kadry.json` ослаблена: маска 390 36 → 48, эталоны 390 подменены производными без пина в SPEC (Р148-Б2). `kadry_profil.json` не ослаблена.

## 6. CI PR

```
$ gh pr checks 168 --repo a3ka/Complior-mob        (rc=1)
android-e2e  fail  9s      quality  fail  7m53s     select-screens  fail  8s
build-apk / e2e-erstinformation / e2e-first-run / e2e-pilot / e2e-screen / e2e-splash / e2e-start / mobile-regression-signal  skipping
$ gh run list --repo a3ka/Complior-mob --commit 488a97f36d5d…  → 43170563774 completed failure (единственный)
select-screens: VYBOR_OTKAZ: INVENTAR_KARTY: mobile/.maestro/prokhod-vkladki.yaml
quality:        VYBOR_OTKAZ: PACHKA_BEZ_REGISTRACII: mobile/e2e-vkladki/ — пачка на дереве без записи карты
android-e2e:    AGREGAT_OTKAZ: SLUZHEBNAYA_NE_ZELENA — select-screens=failure
artifacts(43170563774) = 0; artifacts(43161917403, a4d82bf, cancelled) = 0
```
Все три красных job — от известной предпосылки И-10 («лёгкий режим валидатора»: `INVENTAR_KARTY`/`PACHKA_BEZ_REGISTRACII`). Дефектом реализации они не являются. Но из-за них не собран APK и не сняты кадры — отсюда Р148-Б1.

## ПРОВОДКА (038)

- guard=`fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh` существует во frozen-дереве и исполним — §3.
- В CI харнесса не подключён: это решение оркестратора в окне freeze..done.
- ПРОВОДКА-ЭНФОРСМЕНТ честный: батарея полного трека не является приёмкой, кроме safe-area клеток.
- Оговорка: на лёгкой реализации эти клетки за `PACHKA_ABSENT` не исполняются (Н-3). Их свойства я исполнил отдельно — гейты, зонд, мутанты, §2.
- sourceCanon проекта не объявлен, поэтому сверка 996 не применяется.

## Паразитная сложность (050)

Ответы по пяти вопросам: свойство | состояние | файлы, меняющиеся вместе | глубина | потребитель.

- `bootstrap/tab-shell.tsx` (+377/−69):
  - свойство — И-1 слоты, И-3 инсеты, И-8 токены;
  - состояние — инсет явный (контекст). Артборд выбирается по размеру окна (`profileFor`) и влияет только на allowance;
  - вместе меняются nav-tokens и gespraech-mitte;
  - добавлены 2 пропа и `useArtboard`, модуль глубокий;
  - потребители — `[section].tsx`, сьюты, пробы 999.
  → ESSENTIAL.
- `bootstrap/gespraech-mitte.tsx` (149): И-2 | статус — явный проп | 1 | 4 пропа | композиция, сьюты → ESSENTIAL.
- `theme/nav-tokens.ts` (203): И-8 | нет | 1 | константы | все экраны 148 → ESSENTIAL.
- `features/{missions,protection,post}` (3 компонента + 3 model, одно семейство): И-4/И-7 | `aktivId`/`filtr` — явные пропы | — | 5–7 колбэков, этого требует И-7 | композиция, сьюты → ESSENTIAL.
- `app/(tabs)/[section].tsx` (+77) и `_layout.tsx` (+13): композиция, И-2 мок-отклик, И-3 провайдер | состояния `mittePerekljuchen`/`postFiltr`/`aktiv` явные | 1 | — | `?mitte=needs` теперь имеет потребителя: frozen-зонд GA-03 и сьют композиции → ESSENTIAL (impl-v1 считал его ACCIDENTAL — снято).
- `e2e-vkladki/e2e.sh` (153):
  - свойство — И-9, канон пары AVD;
  - состояние — 8 env: `VKLADKI_*`, `PORT_393`, `MAESTRO_*`, `E2E_DIAG_LOG`, `E2E_TRACE`;
  - потребитель — станция/работник после И-10.
  → ESSENTIAL. Ветка `systemd-run` — совет impl-v1 С-4 без изменений; потребителя в строке приёмки у неё нет, но и блокирующей тройки нет.
- `kadry.json`/`kadry_profil.json`: И-9 | нет | 2 | — | сверка 123 → ESSENTIAL. Содержание 390 — Р148-Б2.
- Сьюты экрана ×5 (одно семейство): п. 2 | нет | — | — | `npm test` → ESSENTIAL.
- `i18n/ui-copy.ts` (+58): И-5 | нет | 1 | — | экраны → ESSENTIAL.

Блокирующих ACCIDENTAL нет.

## СВЕРКА-СТАНДАРТОВ

`AGENTS.md` продукта объявляет `STRUCTURE.md`; в дереве действует `docs/CODING-STANDARDS.md` (2026-11-04). `docs/ARCHITECTURE.md` у моба нет.
- STRUCTURE.md §1/§2 (место кода): соответствует. Домены `features/{missions,protection,post}/{components,model,__tests__}`, `theme/nav-tokens.ts` в слое theme, композиция в `app/(tabs)`.
- CODING-STANDARDS §2 (направления импортов): соответствует. Фичи не импортируют bootstrap/app и друг друга, `eslint .` rc 0.
- CODING-STANDARDS §3 (default только у маршрутов): соответствует. `export default` есть только в `app/(tabs)/[section].tsx:73` и `app/_layout.tsx:12`.
- CODING-STANDARDS §5 (импорты `@/…` через слои): расхождение.
  - `features/missions/components/VorgaengeListe.tsx:19-30`, `features/post/components/PostEingang.tsx:19-29`, `features/protection/components/SchutzUebersicht.tsx:19-29` — `../../../theme/*`, `../../../i18n/ui-copy` в новых файлах;
  - `any`/`console.*` нет.
  → совет С-1.
- CODING-STANDARDS §10/§15 (литеральный размер в компоненте): расхождение. `SchutzUebersicht.tsx:168` `ab.w(10)`, `:349` `ab.w(7)` → совет С-2. Hex вне token-модулей в новых файлах нет.
- CODING-STANDARDS §11 (доступность: зона на хозяине, одна функция — одна цель, видимая надпись): соответствует — 14 мутантов §2 RED.
- CODING-STANDARDS §12 (копия из каталога): соответствует. Ключи `uiCopyDe`, `copy_probe` 51/51.
- CODING-STANDARDS §13 (тесты colocated, Maestro + скриншоты): colocated соответствует. Maestro-сценарии есть, но скриншотов прогона нет → Р148-Б1. Имена `vkladki*.yaml` заданы замороженным контрактом, а контракт старше стандарта по §1.
- STRUCTURE §7.1 (пачки): расхождение ожидаемо по И-10 — 3 отказа инвентаризации `e2e-vkladki/*`.

## Заявленное против сделанного (своя мера)

- «22 suites / 243 tests»: моя мера — 21 suites / 243 tests. Тесты сошлись, сьюты — нет (Н-1).
- «25 путей зоны implementer» (overlay): в diff OBJECT — 24 пути. 25-й снят в 488a97f и перенесён внутрь зонного сьюта (Н-2).
- «тесты перенесены, 21→24»: 24 `it(` в `vkladki-tab-shell.test.tsx` — сходится.
- «батарея 37/36/1 pr-chestnaja»: сходится. Но «клетки safe-area зелёные» этим прогоном не доказаны: pr-safe-* в нём не исполняются. Доказаны отдельно моими командами (§2).
- «зонд 3 passed», «мутанты краснят»: сходится.
- «eslint src rc 0», «lint 20 = 17 + 3»: сходится, 17 замерены на чистом main.

## Советы и наблюдения

С-1…С-3 и Н-1…Н-5 — в `.review/2026-11-12-02.md`.

Повторный суд после закрытия Р148-Б1…Б3 — scoped на новом SHA:
- кадры 16/16 рядом с макетами;
- `kadry.json` 390;
- решение по `cmp-mob-002`.

Accept этого вызова к изменённому кандидату не применяется.
