# SPEC — экран 147 gespraech-vhod-menu (лёгкий трек; что экран добавляет)

Спецификация для implementer. Контракт: `contracts/147-gespraech-vhod-menu.md` (ТРЕК: ЛЁГКИЙ).
Общие свойства экранов (видимость/надпись/зона/действие/достижимость/токен-связь/AVD-канон/маска 48)
судит ОДИН раз набор `fixtures/workshop_project/ekrannyj_nabor_158/` (контракт 158, И-2/И-4);
этот файл несёт ТОЛЬКО экран-уникальное: карта целей, пины, кадры, форма пачки, CI-запись.

Пачка экрана: `karta.json`, `piny.json`, `SPEC.md`, `red_maket_147.py` (узкая визуальная красная проба Б-4), `red_ci_147.py` (клетки регистрации CI — вариант А, слово владельца 2026-11-12). Прежняя полная батарея цикла 2 (`probe.py`, `source.json`, `osi.md`, `model/`, `stubs/`, `nositeli/`, `teksty/`, `produkt/`, `pachka/`, `red_gespraech_vhod_147.sh`) сохраняется как frozen-предшественник: общие классы судит набор 158, новая визуальная находка Б-4 по слову владельца 2026-11-11 — §7, регистрация в CI — §5.

## 1. Карта целей (karta.json)

Формат — SPEC набора 158 §4 (ekran/istochnik/profili/sostojanja/tceli). 13 обязательных целей × 4 состояния × 2 профиля (390×844, 393×852):

- `start` (GA-01, меню закрыто, вход — начальный): вкладки `shell-tab-{start,vorgaenge,schutz,post}`, `gespraech-mitte`, `shell-profile-entry`, `gespraech-vorgaenge-ansehen`;
- `profil` (вход `shell-profile-entry` → profile-surface; целей 147 в нём нет — цели start в нём отсутствуют);
- `menu` (GA-15, вход `gespraech-mitte`): пилюли `gespraech-menu-{sprechen,schreiben,foto,dokument}`, `gespraech-menu-close`; «Ansehen» в нём НЕ рендерится;
- `menu_vorgang` (GA-16, вход `gespraech-vorgaenge-ansehen`): те же пилюли и «×» + `gespraech-menu-ansehen` (карта ждущего Vorgang сверху); «Ansehen» действует переходом в section-vorgaenge и закрывает меню.

Постусловия — в карте. Меню перекрывает оболочку: интерактивные цели start в menu/menu_vorgang недоступны, но ИХ ВИЗУАЛЬНАЯ подложка остаётся смонтированной (Start под GA-15, Vorgänge под GA-16) и реально размывается под scrim (механизм — выбор исполнителя: нативный blur/фильтр, лишь бы фактически размывал живое содержимое на Android-кадрах; плоский фон и статический PNG — нарушение). Удержание Mitte (press-long 500 мс) → голос-мок; короткое касание → меню. Старые testID сохраняются, демо-переключателей нет.

## 2. Пины (piny.json; ЕДИНЫЙ источник значений)

Пакет D24-Kompakt-1.1 (Complior-mob `docs/ux/05_Kompakt_D24`, коммит 9610dc4): sha256 четырёх файлов-источников и 12 кадров — в piny.json.
Токены (значения оттуда, продукт читает через `mobile/src/theme/` — владелец файла 148; литерал числа вместо чтения токена — нарушение, связь а не совпадение):
nav.height 49px; nav.item.min-height 48px; nav.label.font-size 10px; nav.label.line-height 12px; nav.icon 20px; touch-target.min 44px;
typography.body 15/21; motion-fast 150ms; motion-base 250ms; motion-stagger-tight 30ms; motion-morph 450ms; ease-morph cubic-bezier(0.32,0.72,0,1); press-long 500ms.
Цвет «Sprechen» из ЕДИНОГО источника piny.json.tokeny.znachenija: `color.light.accent`/`color.dark.accent` = `#d6f75a`, `color.light.on-accent` = `#121211`; в продукте использовать существующий `tokens.accent`, для тёмного круга/текста `tokens['on-card']`, НЕ чёрный light `tokens.primary`. Гарнитура `font.sans` = `DM Sans`; ресурс `mobile/assets/fonts/DMSans-Variable.ttf` уже есть (зона 999/1), но его надо загрузить в root _layout через expo-font/useFonts до показа UI и применить к видимым Text меню/TabShell (`expo-font` уже в package.json). Новые зависимости экран НЕ ставит: `mobile/package.json`/`package-lock.json` — вне зоны 147 (живые владельцы 145/v4, 151/v1, 995/v5); если для честного размытия нужна зависимость — СТОП и слово через оркестратора, не молчаливая установка. Файлы theme/tokens.ts и theme/nav-tokens.ts принадлежат экрану 148, 147 их читает ПОСЛЕ landing 148, не правит.
Движение: план строится ТОЛЬКО из токенов; меню читается к 300 мс (5×30+150), «Sprechen» — пилюля 1; press-long — scale 1→1.06 линейно за токен;
T31 закрытие — пилюли гаснут разом за motion-fast, морф назад motion-base; УД: перемещение/морф 0, видимое ≤ motion-fast.
Зоны hw/hh — manifest.json пакета (сводка в piny.json.zony_dizajna_hw_hh): все ≥ touch-target.min; видимый размер < 44 при зоне ≥ 44 — не находка.
Надписи — ключи copy-de.json (piny.json.kopija_kljuchi); a11y-имена: Mitte «Gespräch» (+status), профиль «Profil und Einstellungen», «×» — «Schließen».

## 3. Эталонные кадры и пачка ПОЛНОГО состава в продукте (слово владельца 2026-11-12, вариант А)

`mobile/e2e-gespraech-vhod/` — РОВНО 10 файлов (И-11 контракта v5; образец — пачка 149 `mobile/e2e-gespraech-tekst/`): `e2e.sh`, `kadry.json` (профиль 390), `kadry_profil.json` (профиль 393), `ekran.json` (грамматика 132 v3: shablon:3, prokhodimost на 13 целей карты, vtoroj_profil 393/852/48/34 с obolochka tab-shell и marshrut gespraech-vhod-393.yaml, dvizhenie — манифест/спека/позы 04_Gespraech_D24 с живыми sha256 из репо, perehody по ∩-правилу [GA-T28,GA-T29,GA-T30,GA-T31,GA-T33], sceny_znaka [GA-T29,GA-T33], priemka, zony, ne_trogaet), `kontrakt.md`, `katalog_kopii.json`, `spec_api.json`, `dvizhenie.mjs`, `prokhod.sh`, `batareja/red_ekrana.sh`. Требуемые валидатором пути в репо (katalog_kopii/spec_api/audit_tokenov/e2e_scenarij/kadry_dir + marshrut-флою 393) — по образцу 149; черновик-материал — `pack147A` замера Arch147An (пины etalony в нём формальны, геометрия pressable/elementy — прикидка: честные значения из manifest hw/hh пакета; пишет implementer). Ограничение v4 «ТОЛЬКО три файла» СНЯТО словом владельца 2026-11-12 (контракт v5, раздел «Снятие замороженных норм»); состав «ровно 10» судит клетка PACHKA_NEPOLNAJA/PACHKA_LISHNEE (§5).

- Пиксельная сверка — 8 записей: GA-15_menu_* и GA-16_menu_* × {light,dark} × {390×844,393×852}; имена кадров == записи frames/frames.json пакета;
  пины sha256 == frames/SHA256SUMS (piny.json.kadry.sha256); подмена кадра ДРУГИМ кадром того же пакета ловится именем записи (класс 5 перечня).
- GA-01_normal_* — 4 снимка во флоу (свежесть судится), в пиксельной сверке ИХ НЕТ (слово владельца 2026-10-31: новый Start D 2.4 — отдельный предмет).
- Маски сравнения: профиль 390 → chrome_verh_pt 36; профиль 393 → 48 (пилюля пакета y11–47: 36 оставляла 12 pt чужого хрома).
- `e2e.sh` — AVD-канон набора 158 (И-4): последовательный жизненный цикл, остановка 390 с ПОДТВЕРЖДЕНИЕМ ухода (adb devices) до запуска 393
  (порт 5574, вне adb-пары 5572/5573), не более двух живых AVD; запуск 393 при живом 390 запрещён (piny.json.avd).
- Канон §7 прогнан станцией до заморозки живьём: `--model` rc 0, `--stubs` rc 0, `--check font` на текущем tip ветки rc 1 (красное на реализации без Б-4); станция профилей AVD 390/393 не имеет (все AVD 1080×2400@420, замер 2026-11-11) — полный кадельный прогон `--screens` исполняется в среде продукта: работник CI `e2e-gespraech-vhod` снимает 8 кадров в артефакт maestro-gespraech-vhod-* (лекало 143/2, раннер 123), локальная проба §7 не отменяется.

## 4. Юнит-тесты экрана (jest; продукт)

Сьют слайса `mobile/src/features/conversation/__tests__/` и проба полной композиции `mobile/src/bootstrap/__tests__/gespraech-ekran.test.tsx` (слайсу запрещён импорт bootstrap по eslint). Команда из mobile: `npx jest src/features/conversation src/bootstrap/__tests__/gespraech-ekran.test.tsx` → rc 0. Только вместе они судят 13 целей × 4 состояния × обе ширины (Б-5).

- полнота: все 13 целей карты в своих состояниях; отсутствующая/выключенная цель — падение;
- видимость: хозяин нажатия и его надпись видимы (opacity 0 узла/предка, прозрачный фон+надпись, нулевой бокс, display:none — падение);
- зона: эффективная зона ИНТЕРКТИВНОГО хозяина ≥ 44 (width/height, min*, hitSlop, padding, flexBasis — все допустимые способы зелены);
- действие: изолированный колбэк/свежий счётчик на КАЖДУЮ цель, постусловие специфично (sprechen ≠ schreiben; «×» закрывает; «Ansehen» → section-vorgaenge);
- различимость: GA-15 не выдаёт «Ansehen»; GA-16 достижим своей целью-входом; цели start в меню не принимают жесты, их видимое содержимое остаётся под размытой подложкой;
- токен-связь: подмена значения токена в одноразовой копии меняет поведение компонента (порог press-long, зона, высота навигации);
- движение: план из токенов, 300 мс, «Sprechen» первый, press-long на фейк-часах (допуск такта 1 мс), УД-правила.

Матрица классов 1–13 остаётся в наборе 158; §7 — ТОЛЬКО адресные красные пины нового визуального расхождения Б-4 с обманами кодом, не второй общий набор.

## 5. CI-проводка (БЕЗУСЛОВНАЯ с v5 — слово владельца 2026-11-12, вариант А; общие файлы append-only)

Предпосылка v4 «лёгкий режим валидатора» СНЯТА (контракт v5, раздел «Снятие замороженных норм»): пачка ПОЛНОГО состава §3 проходит НЕИЗМЕННЫЙ валидатор пина `5fd1415e…` (замер Arch147An 2026-11-12: вся статика зелёная — rc 1 E2E_NE_PROSHLA только из-за отсутствия эмулятора, как у эталона 149; живое исполнение e2e/сверка/профиль/проход/движение — работник с эмуляторами). Запись карты и работник добавляются в PR экрана, не условно; условие ленда прежнее: решающая команда валидатора из тела работника на честной пачке — rc 0, на подмене кадра другим кадром пакета или имени кадра вне frames.json — именованный ненулевой rc.

- `mobile/ci-screens.json` — ТОЛЬКО своя запись, БЕЗУСЛОВНО тем же PR что работник: id `gespraech-vhod`, kontrakty `[147]`, status `in-development` (→ `approved` по принятой поставке), job `e2e-gespraech-vhod`, pack `mobile/e2e-gespraech-vhod/`,
  flows `gespraech-vhod.yaml`+`gespraech-vhod-393.yaml`, child_flows `gespraech-prokhod.yaml`, puti {features/conversation/, tab-shell.tsx, mocks/}, h_checkout `.harness147`,
  output_namespace `mobile/maestro-out-gespraech`; чужие записи не трогаются; запись без работника — молчаливый пропуск карты (замер: DAG зелён, карта врёт) — запрещена.
- `.github/workflows/mobile.yml` — ТОЛЬКО свой работник `e2e-gespraech-vhod` инстанциацией ЛЕКАЛА `fixtures/workshop_project/mob_ci_143/model/screen-job.template.yml`
  (frozen 143/2, sha256 3675182e218c467f694dc69d4ee3457900849e6717b7a80d12e8bafc80aa14dd) по образцу 149: output выбора, имя в needs обоих агрегатов,
  H-checkout `a3ka/dev-harness` @ `d01c9414ef792ea1382750c825759ab51a418ff4`, run_priemka → `python3 .harness147/scripts/ekran_shablon.py --pack 'mobile/e2e-gespraech-vhod/' --repo . --harness '.harness147'`,
  артефакт кадров `maestro-gespraech-vhod-*` if-no-files-found: error, AVD порт 5572 (393 — 5574, piny.json.avd); чужие тела не меняются.
- Красные клетки регистрации (архитектор; судят ровно эти три поверхности): `python3 <H>/fixtures/workshop_project/gespraech_vhod_147/red_ci_147.py --repo <R>` → rc 0 на честной; каждое отсутствие — именованный rc 1 (10 причин: PACHKA_NEPOLNAJA/PACHKA_LISHNEE/ZAPIS_KARTY_NET/ZAPIS_KARTY_POLJA/RABOTNIKA_NET/RABOTNIK_BEZ_VYBORA/RABOTNIK_VNE_AGGREGATOV/RABOTNIK_BEZ_VALIDATORA/RABOTNIK_BEZ_PINA/RABOTNIK_BEZ_KADROV; `--stabs` — 10 обманов, каждый красен своей причиной).
- `mobile/.maestro/` — свои `gespraech-{vhod,vhod-393,prokhod}.yaml` + строки исключения config.yaml (прецедент 138); чужие флоу не трогаются.
- `mobile/src/bootstrap/tab-shell.tsx` — строки слота и фон живой подложки меню (подложка не принимает жесты); landing 147 ПОСЛЕ владельца файла 148, чужие секции не править. Проба композиции — адресный путь `mobile/src/bootstrap/__tests__/gespraech-ekran.test.tsx`, в зоне 147.
- `mobile/src/app/_layout.tsx` — ТОЛЬКО регистрация существующего DM Sans ресурса в Expo Font и удержание показа первого кадра до готовности; каталог в зоне живых заморозок 107/v1, 108/v1, 118/v3, 148/v3, 995/v5, 999/v1 — санкция владельца на эту правку дана словом 2026-11-11 (Б-4), маршруты/Stack/чужие регистрации не меняются.
- `mobile/package.json` + `mobile/package-lock.json` — НЕ в зоне 147 (живые владельцы 145/v4, 151/v1, 995/v5): экран не добавляет зависимостей; нужная для размытия зависимость — отдельное слово владельца, не правка «заодно».
- `mobile/src/mocks/` — новые файлы дописываются, чужие не трогаются (пилот-хост живёт рядом с портом в src/features/conversation/adapters/
  из-за eslint-границы моков — прецедент PR #146).
- `mobile/src/theme/tokens.ts`, `nav-tokens.ts`, `mobile/src/i18n/ui-copy.ts` — владелец 148; экран 147 их ЧИТАЕТ, не правит.

Материал: прежняя реализация PR #146 (ветка wip/147/implementer) — разрешено брать код; известные дефекты против этой карты:
меню в PR не различает GA-15/GA-16 (карта ждущего Vorgang показывается всегда), press-long-подача и слот-интеграция — сверить с картой и пинами.
Текущая голова — mob#169 (OBJECT 08c3267c7; ревью impl-v2: код зелёный по всем исполнимым осям, ждёт кадров работника — Р147-Б1); флоу 393 несёт токен оболочки (tab-shell) — иначе MARSHRUT_BEZ_OBOLOCHKI (замер Arch147An).

## 6. Критерии готовности (сводка; полные rc-команды — контракт §Приёмочный критерий)

1. `bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh --repo <R> --ekran 147` → rc 0 (по готовности 158; до того — именованный rc 2, не зелень);
2. `cd mobile && npx jest src/features/conversation src/bootstrap/__tests__/gespraech-ekran.test.tsx` → rc 0; композиция включена явно (Б-5).
3. пачка mobile/e2e-gespraech-vhod/ = РОВНО 10 файлов (И-11 контракта v5); имена/пины/маски == piny.json;
4. CI: своя запись карты + свой работник по лекалу 143/2 — БЕЗУСЛОВНО в PR экрана (слово владельца 2026-11-12, вариант А); `python3 <H>/fixtures/workshop_project/gespraech_vhod_147/red_ci_147.py --repo <R>` → rc 0 (клетки красны на пачке неполного состава / без записи карты / без работника); landing после 148;
5. суд: ОДИН круг критика (быстрый процесс) + ревьюер.

## 7. Красные пины Б-4 (Android-кадры/шрифт; scoped, не батарея 158)

Команда из корня харнесса с подставленным корнем продукта `<R>` и каталогом кадров после живого `e2e.sh`:
`python3 fixtures/workshop_project/gespraech_vhod_147/red_maket_147.py --reference <design>/docs/ux/05_Kompakt_D24/frames --product <R> --screens <R>/mobile/maestro-out-gespraech` → rc 0 для ВСЕХ восьми GA-15/GA-16 × light/dark × 390/393. `<design>` — worktree пакета wip-136-demo либо product main (пакет влит merge #156; живой замер 2026-11-11: пины 12/12 совпадают в обоих). SHA каждого эталона заранее сравнивается с piny.json.kadry.sha256 и загружается в память ДО чтения кадров продукта. Пилюля сверяется с цветом piny.json; зона под scrim неплоская (эталон stddev 2.77–21.7, старый продукт = 0). Шрифт: asset ≥ 1 KiB и `useFonts({'DM Sans': require('…DMSans-Variable.ttf')})` в app/_layout плюс `fontFamily: 'DM Sans'` в меню; совпадение рисунка букв с PNG судит ревьюер, имя шрифта само по себе пиксели не доказывает. После пробы — обе команды раннера 123 с kadry.json/kadry_profil.json (8 оценок ≥ 0.600), затем визуальная сверка каждого кадра.

`--model --product <R> --reference <frames>` → rc 0 (восемь настоящих кадров + честный модельный путь загрузки/применения существующего asset). `--stubs --product <R> --reference <frames>` → rc 0 ТОЛЬКО если каждая подмена к своему входу в КОДЕ красна своей причиной: ровный фон GA-15 light → PODLOZHKA_NE_RAZMYTA; чёрная пилюля light с честной подложкой → SPRECHEN_NE_LAIM; замороженная подложка GA-16 light, скопированная из GA-15 при нетронутых пилюлях → PODLOZHKA_ZASTYLA; DM Sans только в комментарии без useFonts → DM_SANS_NE_ZAGRUZHEN; шрифт загружен без fontFamily → DM_SANS_NE_PRIMENEN. Попарная ROI динамика GA-15↔GA-16 в каждой теме/профиле >2 по средней яркости; каждый обман проверяется отдельно. `--check blur|color|font` делает красноту прежнего продукта наблюдаемой своей ветвью; происхождение пикселей blur подтверждает живое AVD + ревью.
