# SPEC — экран 147 gespraech-vhod-menu (лёгкий трек; что экран добавляет)

Спецификация для implementer. Контракт: `contracts/147-gespraech-vhod-menu.md` (ТРЕК: ЛЁГКИЙ).
Общие свойства экранов (видимость/надпись/зона/действие/достижимость/токен-связь/AVD-канон/маска 48)
судит ОДИН раз набор `fixtures/workshop_project/ekrannyj_nabor_158/` (контракт 158, И-2/И-4);
этот файл несёт ТОЛЬКО экран-уникальное: карта целей, пины, кадры, форма пачки, CI-запись.

Пачка экрана (эта): `karta.json` (карта целей), `piny.json` (пины: пакет/кадры/токены/маски/AVD/ключи копии), `SPEC.md` (этот файл).
Прежняя полная батарея цикла 2 (probe.py, source.json, osi.md, model/, stubs/, nositeli/, teksty/, produkt/, pachka/, red_gespraech_vhod_147.sh)
остаётся замороженным артефактом закрытого цикла: не воспроизводится, не пересуживается, приёмкой 147 больше не вызывается;
прогоняется набором 158 как регрессия соседа (семья G SPEC 158). НОВЫЕ файлы пачки — karta.json/piny.json/SPEC.md.

## 1. Карта целей (karta.json)

Формат — SPEC набора 158 §4 (ekran/istochnik/profili/sostojanja/tceli). 13 обязательных целей × 4 состояния × 2 профиля (390×844, 393×852):

- `start` (GA-01, меню закрыто, вход — начальный): вкладки `shell-tab-{start,vorgaenge,schutz,post}`, `gespraech-mitte`, `shell-profile-entry`, `gespraech-vorgaenge-ansehen`;
- `profil` (вход `shell-profile-entry` → profile-surface; целей 147 в нём нет — цели start в нём отсутствуют);
- `menu` (GA-15, вход `gespraech-mitte`): пилюли `gespraech-menu-{sprechen,schreiben,foto,dokument}`, `gespraech-menu-close`; «Ansehen» в нём НЕ рендерится;
- `menu_vorgang` (GA-16, вход `gespraech-vorgaenge-ansehen`): те же пилюли и «×» + `gespraech-menu-ansehen` (карта ждущего Vorgang сверху); «Ansehen» действует переходом в section-vorgaenge и закрывает меню.

Постусловия — в карте (perehod/vyzov с дословным значением). Меню перекрывает оболочку целиком: цели start в menu/menu_vorgang недоступны — вход в меню только из покоя. Удержание Mitte (press-long 500 мс) → голос-мок (GA-34, будущий 150); отпуск раньше порога → меню. ТестID существующих элементов слайса-1 переиспользуются (`shell-tab-*`, `shell-profile-entry`), новых — `gespraech-*`; демо-переключателей нет.

## 2. Пины (piny.json; ЕДИНЫЙ источник значений)

Пакет D24-Kompakt-1.1 (Complior-mob `docs/ux/05_Kompakt_D24`, коммит 9610dc4): sha256 четырёх файлов-источников и 12 кадров — в piny.json.
Токены (значения оттуда, продукт читает через `mobile/src/theme/` — владелец файла 148; литерал числа вместо чтения токена — нарушение, связь а не совпадение):
nav.height 49px; nav.item.min-height 48px; nav.label.font-size 10px; nav.label.line-height 12px; nav.icon 20px; touch-target.min 44px;
typography.body 15/21; motion-fast 150ms; motion-base 250ms; motion-stagger-tight 30ms; motion-morph 450ms; ease-morph cubic-bezier(0.32,0.72,0,1); press-long 500ms.
Движение: план строится ТОЛЬКО из токенов; меню читается к 300 мс (5×30+150), «Sprechen» — пилюля 1; press-long — scale 1→1.06 линейно за токен;
T31 закрытие — пилюли гаснут разом за motion-fast, морф назад motion-base; УД: перемещение/морф 0, видимое ≤ motion-fast.
Зоны hw/hh — manifest.json пакета (сводка в piny.json.zony_dizajna_hw_hh): все ≥ touch-target.min; видимый размер < 44 при зоне ≥ 44 — не находка.
Надписи — ключи copy-de.json (piny.json.kopija_kljuchi); a11y-имена: Mitte «Gespräch» (+status), профиль «Profil und Einstellungen», «×» — «Schließen».

## 3. Эталонные кадры и пачка в продукте

`mobile/e2e-gespraech-vhod/` — ТОЛЬКО три файла: `e2e.sh`, `kadry.json` (профиль 390), `kadry_profil.json` (профиль 393).
Прежние ekran.json/spec_api.json/batareja/dvizhenie.mjs/prokhod.sh/katalog_kopii.json/kontrakt.md полной батареи НЕ воспроизводятся (слово владельца 2026-11-03); следствие для CI-проводки — §5.

- Пиксельная сверка — 8 записей: GA-15_menu_* и GA-16_menu_* × {light,dark} × {390×844,393×852}; имена кадров == записи frames/frames.json пакета;
  пины sha256 == frames/SHA256SUMS (piny.json.kadry.sha256); подмена кадра ДРУГИМ кадром того же пакета ловится именем записи (класс 5 перечня).
- GA-01_normal_* — 4 снимка во флоу (свежесть судится), в пиксельной сверке ИХ НЕТ (слово владельца 2026-10-31: новый Start D 2.4 — отдельный предмет).
- Маски сравнения: профиль 390 → chrome_verh_pt 36; профиль 393 → 48 (пилюля пакета y11–47: 36 оставляла 12 pt чужого хрома).
- `e2e.sh` — AVD-канон набора 158 (И-4): последовательный жизненный цикл, остановка 390 с ПОДТВЕРЖДЕНИЕМ ухода (adb devices) до запуска 393
  (порт 5574, вне adb-пары 5572/5573), не более двух живых AVD; запуск 393 при живом 390 запрещён (piny.json.avd).
- Живая сверка против настоящих скриншотов — продуктовый CI (работник по лекалу 143/2 + раннер 123), не станция — после ленда лёгкого режима валидатора (§5): до того непокрытие именовано, станцией не подменяется.

## 4. Юнит-тесты экрана (jest; продукт)

Сьют в `mobile/src/features/conversation/__tests__/` (gespraech-vhod*.test.tsx, gespraech-dvizhenie*.test.ts — заголовки без `ident(цифра)`, урок 145 v4).
Команда приёмки: `cd mobile && npx jest src/features/conversation` → rc 0. Сьют судит по карте (обе ширины 390/393):

- полнота: все 13 целей карты в своих состояниях; отсутствующая/выключенная цель — падение;
- видимость: хозяин нажатия и его надпись видимы (opacity 0 узла/предка, прозрачный фон+надпись, нулевой бокс, display:none — падение);
- зона: эффективная зона ИНТЕРКТИВНОГО хозяина ≥ 44 (width/height, min*, hitSlop, padding, flexBasis — все допустимые способы зелены);
- действие: изолированный колбэк/свежий счётчик на КАЖДУЮ цель, постусловие специфично (sprechen ≠ schreiben; «×» закрывает; «Ansehen» → section-vorgaenge);
- различимость: GA-15 не выдаёт «Ansehen»; GA-16 достижим своей целью-входом; цели start в меню отсутствуют;
- токен-связь: подмена значения токена в одноразовой копии меняет поведение компонента (порог press-long, зона, высота навигации);
- движение: план из токенов, 300 мс, «Sprechen» первый, press-long на фейк-часах (допуск такта 1 мс), УД-правила.

Матрица мутантов и обманные заглушки экрана НЕ заводятся (норма лёгкого трека): красное предъявление экрана — набор 158 (негативные образцы на живом референсе), не экранная батарея.

## 5. CI-проводка (условна по механизму; общие файлы append-only)

Неизменный валидатор лекала (ekran_shablon.py, пин `5fd1415e…`) на трёхфайловой пачке даёт rc 2 `SHABLON_NEVEREN ekran.json` (живой замер 2026-11-04, пачка собрана по §3): обязательный вызов `run_priemka` работника первым делом безусловно читает `pack/ekran.json`; «минимального честного ekran.json» не существует — грамматика замкнута, полный состав (kontrakt/batareja в пачке; katalog_kopii/spec_api/audit_tokenov/e2e_scenarij/kadry_dir + marshrut-флою 393 в репо; dvizhenie с живым отчётом) исключён словом владельца 2026-11-03. Поэтому запись карты и работник добавляются ТОЛЬКО после ленда лёгкого режима валидатора (предпосылка контракта §ПРЕДПОСЫЛКИ; отдельный предмет харнесса — зона владельцев: линия 132/146 — валидатор, 143 — лекало); до того НЕ добавляются: честная реализация не создаёт вечно-красный job (Crit147L). Условие ленда: решающая команда валидатора из тела работника на честной пачке — rc 0, на подмене кадра другим кадром пакета или имени кадра вне frames.json — именованный ненулевой rc.

- `mobile/ci-screens.json` — ТОЛЬКО своя запись, не раньше ленда лёгкого режима валидатора: id `gespraech-vhod`, kontrakty `[147]`, job `e2e-gespraech-vhod`, pack `mobile/e2e-gespraech-vhod/`,
  flows `gespraech-vhod.yaml`+`gespraech-vhod-393.yaml`, child_flows `gespraech-prokhod.yaml`, h_checkout `.harness147`,
  output_namespace `mobile/maestro-out-gespraech`; чужие записи не трогаются.
- `.github/workflows/mobile.yml` — ТОЛЬКО свой работник `e2e-gespraech-vhod` инстанциацией ЛЕКАЛА `fixtures/workshop_project/mob_ci_143/model/screen-job.template.yml`
  (frozen 143/2, sha256 3675182e218c467f694dc69d4ee3457900849e6717b7a80d12e8bafc80aa14dd): output выбора, имя в needs обоих агрегатов; тем же условием (не раньше ленда режима); чужие тела не меняются.
- `mobile/.maestro/` — свои `gespraech-{vhod,vhod-393,prokhod}.yaml` + строки исключения config.yaml (прецедент 138); чужие флоу не трогаются.
- `mobile/src/bootstrap/tab-shell.tsx` — ТОЛЬКО строки слота startScreen/меню (владелец файла в лёгком цикле — экран 148 по решению оркестратора 2026-11-04);
  landing 147 ПОСЛЕ 148 (rebase на 148), конфликт — исполнителя.
- `mobile/src/mocks/` — новые файлы дописываются, чужие не трогаются (пилот-хост живёт рядом с портом в src/features/conversation/adapters/
  из-за eslint-границы моков — прецедент PR #146).
- `mobile/src/theme/tokens.ts`, `nav-tokens.ts`, `mobile/src/i18n/ui-copy.ts` — владелец 148; экран 147 их ЧИТАЕТ, не правит.

Материал: прежняя реализация PR #146 (ветка wip/147/implementer, 33 файла, красный CI) — разрешено брать код; известные дефекты против этой карты:
меню в PR не различает GA-15/GA-16 (карта ждущего Vorgang показывается всегда), press-long-подача и слот-интеграция — сверить с картой и пинами.

## 6. Критерии готовности (сводка; полные rc-команды — контракт §Приёмочный критерий)

1. `bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh --repo <R> --ekran 147` → rc 0 (по готовности 158; до того — именованный rc 2, не зелень);
2. `cd mobile && npx jest src/features/conversation` → rc 0;
3. пачка mobile/e2e-gespraech-vhod/ = e2e.sh + kadry.json + kadry_profil.json; имена/пины/маски == piny.json;
4. CI: своя запись карты + свой работник по лекалу 143/2 (append-only) — ТОЛЬКО после ленда лёгкого режима валидатора (§5; неизменный валидатор красит трёхфайловую пачку rc 2 — живой замер 2026-11-04), до того НЕ добавляются; landing после 148;
5. суд: ОДИН круг критика (быстрый процесс) + ревьюер.
