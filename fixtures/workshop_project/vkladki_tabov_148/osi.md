# Оси батареи 148 (vkladki-tabov) — 67 клеток, 37 стабов, 56 привязки
# (`--model` rc 0 67/67; `--stabs` rc 0, контроль 67/67,
# «SVJAZI 56», живых 0; без флага — rc 1: продукта в дереве харнесса
# нет — живые красноты поимённо).
# v6-перевод (2026-11-22, слово владельца ~10:53): токенный гейт судит
# ЗНАЧЕНИЯ проекции mobile/src/theme/nav-tokens.ts (модуль
# kompakt-tokens.ts снят); записи 393 — ПРОИЗВОДНЫЕ эталоны safe-area
# (etalony_safe_area/postroit.py + manifest.json, семья
# mobile/etalony-vkladki-393/), гейты ETALON_393_NE_PROIZVODNYJ и
# POROG_NE_0_600 у обоих судей; клетки porog-oslablen /
# etalon-393-nizhe-poroga / pr-etalon-393-chuzhoj-bajt /
# pr-porog-oslablen, стабы s99/s100/s101; порог 0.600 и прежние
# клетки не ослаблены (снимок kejsy переснят, честные базы rc 0).
# v5-перенацел (2026-11-15): статические якоря продукт-судьи сняты с
# формы PR #147 (замещена v5): MITTE-маркеры судят КЛЮЧИ каталога 1.1
# (не имена внутренних полей), KOPII — только ключи каталога + ЗАПРЕТ
# финала-2 и fixture.*/runtime.value.* в ui-copy, PROKHOD — только цели
# лейсте (канон 999 + gespraech-mitte); референсная раскладка приведена
# к v5-форме копии (fixture.schutz.02 — данные schutz-dannye.ts).

Субъекты (Н-39: стабы привязаны к ветвям ОБОИХ субъектов по stab_vhod
source.json — привязка кодом, не прозой):

- **A (форма)** — судья формы `model/sud_formy_148.py` (правки
  Crit148v2 блок 3 + v+1): гейт ТОЧНОГО значения маски профиля
  (mera.chrome_verh_pt == 48) и гейт ПАКЕТА (каждый кадр обоих
  манифестов — docs/ux/05_Kompakt_D24/frames/ + sha == записи
  nositeli/paket/SHA256SUMS пакета D24-Kompakt-1.1; возврат пина
  D 2.4 Final 2 — PAKET_1_1_NE_PRIPINEN; v3a Crit148k2a Б1: гейт ИМЁН
  KADR_PODMENEN — пин каждой записи ↔ её идентификатор по оракулу
  kadry_manifest/profil_kadry; v6: гейт ПОРОГА — porog каждой записи
  обоих манифестов == 0.600 — POROG_NE_0_600 «без ослабления порога»)
  ПОСЛЕ визуального суда
  делегата `--sud` (живой `scripts/ekran_shablon.py` или эталон) на
  модельной пачке «vkladki» (shablon 3; носители — 16 кадров
  GA-02/03/04/09 пакета D24-Kompakt-1.1 по ИМЕНАМ пакета, байты
  пиннены sha256 в source.json:.piny.nositeli == frames/SHA256SUMS,
  и подмножества источников D 2.4 тем же построением, что батарея
  146; старые кадры Final 2 — nositeli/maket-final2/, вход клеток
  paket-final2/pr-paket-final2). Эталон — `model/ekran_shablon.py`:
  байт-копия модели 146 (v3 = frozen 132/2 + ветка dvizhenie) из
  harness main 81326fc1a после Fix146e (шапка «НЕ БАРЬЕР», 2133
  строки; поведенчески идентична замороженной ab26d789 — правка
  только шапка-комментарий, вердикт критика 146 c26889843; tag
  frozen/contracts/146/1 исторически держит ab26d789), пин
  5fd1415e…db453b проверяется load_source ДО клеток; новая версия
  146 потребует перепина этой пачкой — пин и ожидания kejsy
  переснимаются прогоном `--snapshot` ДО freeze 148.
- **B (продукт)** — `produkt_sud.py --repo R`: маркеры шва/контента,
  пины кадров по каноническим путям R (docs/ux/05_Kompakt_D24/frames/,
  гейт пакета PAKET_1_1_NE_PRIPINEN — те же sha, что у судьи формы),
  v6: токенный гейт судит ЗНАЧЕНИЯ проекции mobile/src/theme/nav-tokens.ts
  (пять листьев NAV.height/NAV.item.minHeight/NAV.label.fontSize/
  NAV.label.lineHeight/TOUCH_TARGET.min против извлечения из
  source/tokens.json — TOKENY_MODUL_NE_IZ_ISTOCHNIKA на дрейф; модуль
  kompakt-tokens.ts снят), гейт ПРОИЗВОДНОСТИ 393 (sha каждой записи
  kadry_profil.json == manifest.json построителя — ETALON_393_NE_PROIZVODNYJ)
  и гейт ПОРОГА (porog == 0.600 — POROG_NE_0_600); записи 393 судит
  paket-гейт только префиксом пути (mobile/etalony-vkladki-393/ —
  атрибуция причин производности отдельно от пакета);
  снимки обоих профилей и pressable (зона hw/hh); v3a Crit148k2a: гейты KADR_PODMENEN (имя записи ↔ идентификатор) и TOKENY_ISTOCHNIK_NEVEREN (байты ds/tokens.css == пину frames.json пакета); И-11 — исполняемый
  e2e.sh в одноразовом cwd с двойниками adb/emulator/maestro/sleep в
  PATH+ANDROID_HOME, состояние живых серийников и журнал KILL/START;
  затем полный суд пачки эталоном v3; последним — ИСПОЛНЯЕМЫЙ суд
  реальных компонентов R живым jest-зондом
  `produkt/vkladki-zond-148.test.tsx` (пин sha256 в piny.produkt)
  в изолированной копии mobile. Зелёные контроли по отдельности:
  подмена nav-токенов N+2, конформная height36+minHeight44,
  padding22, padding16+однострочный Filter14 и paddingVertical22.
  Красные действующие мутации исполняются по одному на живом R:
  tabs/badge/skroll/kasanie/tokeny/nav-final2/nav-literal/disabled/
  filter-bez-dejstvija/padding-tolko-gorizontal; причина Filter
  принадлежит именно событию Filter, а не старому вызову Alle.
  Суд зоны учитывает RN height/min/max, padding по осям, контент
  однострочной кнопки и hitSlop на обоих профилях; исходы
  подтверждаются `produkt_sud.py --repo R` в среде продукта.
  v+1 (слово владельца 2026-11-11, Б-3): статические гейты корня
  (<SafeAreaProvider в app/_layout.tsx) и чтения инсета лейсте
  (useContext(SafeAreaInsetsContext)/useSafeAreaInsets) + зондовый
  ассерт Б-3 — рендер TabShell в SafeAreaProvider (нижний инсет 24 и
  48 на 390, 34 на 393): резерв оверлея == инсету на 390 (двумя
  значениями — плоская константа красна), ≥ на 393, bottom 0;
  эталонная раскладка несёт честную форму: провайдер в корне, резерв
  оверлея = nav.height + max(0, insets.bottom), мутанты
  safe-rezerv-nul/safe-konstanta убиваются ассертом (якоря — обе
  формы: живой продукт и раскладка).
  Без package.json — именованный пропуск; заявленная среда без
  установки — rc 2 LIVE_PREDPOSYLKA. Эталон — референсная раскладка
  `model/produktnaja-raskladka` (пачка — source.json:.ekran_forma_prod).

Оракул — source.json (kejsy: rc/prichiny/stdout с допуском 0.01 на
KADR-числа; stubs ↔ stab_vhod — рассинхрон rc 2 ORACLE_TAMPERED ДО
клеток; пины носителей и эталонной раскладки сверяются ДО клеток —
правило 8; v6: пины производной семьи etalony_safe_area — то же
правило ДО клеток, плюс проверка детерминизма построения — importlib
запускает etalony_safe_area/postroit.py:proverit(), перестройка в
mktemp обязана совпасть байтами). Честные кадры stand-in — перегонка
макетов (декодер ct 2/6, энкодер RGBA: пиксели те же, байты иные —
приём 118/132; KADR 1.000 во всех восьми строках обеих баз; v6:
снимки 393 дополнительно несут строку статуса эмулятора y 12..47 —
живой скриншот несёт её; производные эталоны полос не несут, маска
48 закрывает строку). Временные репо/пачки — mktemp, без
сети/omp/живого эмулятора.

## Базы (две, обе честные, rc 0)

- `chestnyj-vkladki` — модельная пачка: stdout KADR×8 (1.000) +
  SHABLON vkladki OK; приёмки исполнены стенд-инами (e2e кладёт кадры
  обоих профилей в Maestro-раскладку, сверка-образец == вывод раннера
  123, проход rc 0, отчёт движения свеж: timestamp меняет байты).
- `pr-chestnaja` — продукт-судья на референсной раскладке: тот же
  stdout (KADR×8 + SHABLON OK) — пачка референса проходит эталон целиком
  (живой прогон канона на реальном продукте — produkt_sud --repo
  <копия продукта>: rc 0, SHABLON vkladki OK, замер пачки).

## Оси клеток (каждая красная имеет свою именованную причину; судья
называет первое нарушение; журнал может содержать два нарушения
порядка на двух START одного входа)

- **Форма v3** (5): без shablon — SHABLON_OTSVTSTVUET; GA-кадры на
  shablon 2 — DVIZHENIE_OTSVTSTVUET «GA-02, GA-03, GA-04, GA-09» (экран
  D 2.4 не прячет принадлежность за версией формы); priemka без prokhod
  — SHABLON_NEVEREN «priemka» (замкнутый состав трёх команд); без
  prokhodimost — PROKHODIMOST_OTSVTSTVUET; без vtoroj_profil —
  VTOROJ_PROFIL_OTSVTSTVUET.
- **Кадры/макеты** (6): байты макета GA-03 изменены при том же пине —
  MAKET_PODMENEN; кадр GA-03 dark с залитой полосой Mitte —
  KADR_NIZHE_POROGA; кадры положены ДО команды и команда молчит —
  KADR_USTAREVSHIJ (оба манифеста — два одноимённых отказа); e2e rc 1 —
  E2E_NE_PROSHLA; id кадра == id живой пачки 132 — CHUZHIE_KADRY;
  v6: полоса деградации Mitte y 772..818 в живом снимке GA-03 dark 393
  (мода цвета фона) при честных пинах — KADR_NIZHE_POROGA на 393-записи
  (вход etalon-393-nizhe-poroga; порог 0.600 ловит и геометрический
  дрейф против производного эталона, не только подмену файла).
- **Проходимость** (6): pressable без izmenenie — PRESSABLE_BEZ_IZMENENIJA;
  Mitte vysota 36 — KASANIE_MENSHE_NORMY; цель в вырезе (y 40) —
  KASANIE_V_SAFE_ZONE; demo-метка в составе — DEMO_V_SOSTAVE; демо-цель
  без otdelenie (токен во флоу добавлен — одна причина) —
  DEMO_BEZ_OTDELENIJA; повтор id — SHABLON_NEVEREN «повторы id».
- **Второй профиль** (7): 320×640 — PROFIL_NIZHE_MINIMUMA (+ZALEZAET_POD_INSET
  законен: элементы не влезают в класс ниже нормы — двойной отказ
  оговорён); vyrez 0 — PROFIL_BEZ_INSETOV; одна тема — ODNA_TEMA; флоу
  без токена tabshell — MARSHRUT_BEZ_OBOLOCHKI; флоу без снимка
  профиля — MARSHRUT_BEZ_SNIMKA; возврат маски шапки 36 (v2, слово
  владельца 31.10; v6-механизм: стенд-ин 393 рисует строку статуса
  эмулятора y 12..47 во всю ширину — живой скриншот несёт её; эталон
  производный полос не несит, маска 36 строку НЕ закрывает, 48 —
  закрывает) — KADR_NIZHE_POROGA на записях 393 (производные эталоны
  при маске 36 красны по всем восьми записям; пилюля выреза в кадрах
  1.1 x133–258, y11–47 остаётся закрытой маской 36 — история v2:
  живой прообраз Q1б краснел тройкой 0.425/0.414/0.392); значение
  маски 47 при визуально зелёных кадрах (правка Crit148v2, блок 3) —
  PROFIL_MASKA_NE_48: инвариант ТОЧНОГО значения 48 судит судья
  формы ПОСЛЕ визуального суда; v6: порог записи ослаблен (0.5) при
  зелёной сверке — POROG_NE_0_600 у судьи формы (вход porog-oslablen)
  и у продукт-судьи (вход pr-porog-oslablen).
- **Пакет 1.1 / имена кадров** (3; v+1 слово 2026-11-02 + v3a
  Crit148k2a Б1): пин кадров возвращён на D 2.4 Final 2 (пути
  04_Gespraech_D24/pack/screens/, файлы и sha честны, валидатор ЗЕЛЁН
  — KADR×8 + SHABLON OK) — PAKET_1_1_NE_PRIPINEN: гейт пакета судьи
  формы (вход paket-final2, клетка 13 контракта); запись «GA-02 dark»
  перепинена на СОСЕДНИЙ кадр того же пакета (GA-04, файл и sha
  честны) — KADR_PODMENEN у судьи формы (вход kadry-podmenen,
  клетка 15) и у продукт-судьи (вход pr-kadry-podmenen, клетка 16:
  stdout честен — KADR×8 + SHABLON OK, красит гейт имён).
- **Проход** (3): argv без цели-флою — PROKHOD_NE_MAESTRO; флоу без
  pressable-токена — PROKHOD_BEZ_PRESSABLE; исполнение rc 1 —
  PROKHOD_NE_PROSHLA.
- **Литералы/копия/сценарий/зоны** (4): hex в тексте пачки —
  LITERAL_VNE_AUDITA; ключ вне каталога — KLJUCH_BEZ_KATALOGA; сценарий
  без снимка (кадр обеих тем — два одноимённых) — SCENARIJ_BEZ_SNIMKA;
  ЗОНА-строки контракта ≠ zony — ZONY_RASHODJATSJA.
- **Движение-пусто** (3): perehody += GA-T28 (∩ = ∅) — PEREHOD_LISHNIJ;
  пин спеки неверен — ISTOCHNIK_NE_SOVPADAET; пути источника нет —
  ISTOCHNIK_OTSVTSTVUET (rc 2 fail-closed, инфраструктура).
- **Продукт** (28): шов без слотов — SHOV_NET; подмена имени кадра
  в пачке R при честных файле и sha — KADR_PODMENEN (v3a, вход
  pr-kadry-podmenen); дрейф байтов источника токенов —
  TOKENY_ISTOCHNIK_NEVEREN (И-12; живые обходы Б2/Б3 роняют контроль
  зонда — ISPOLNIMYJ_KONTROL_KRASEN, приёмка 16); v6: значения
  проекции nav-tokens.ts не из источника (NAV.height 71) —
  TOKENY_MODUL_NE_IZ_ISTOCHNIKA (вход pr-tokeny-modul; байтов канона
  больше нет — судятся ЗНАЧЕНИЯ пяти листьев); Mitte с tab-ролью —
  MITTE_V_TAB; пачка удалена — PACHKA_ABSENT; пин макета неверен либо
  PNG удалён по каноническому пути — MAKET_PIN_NEVEREN; пин пачки R
  на Final 2 при честных файлах — PAKET_1_1_NE_PRIPINEN (v+1, вход
  pr-paket-final2, клетка 14; stdout честен — KADR×8 + SHABLON OK,
  красит гейт пакета продукт-судьи); ключи копии удалены — KOPII_NET;
  v5-перенацел (2026-11-15): Mitte без ключа каталога (вернулся к
  финалу-2) — MITTE_NET (вход pr-mitte-net; маркеры судят КЛЮЧИ
  ui.mission.group.*, не имена внутренних полей); ключи копии —
  только verbatim из каталога 1.1: финал-2 (ui.vorgaenge.group.*) в
  ui-copy — KOPII_FINAL2 (вход pr-kopii-final2), fixture.*/runtime.
  value.* в ui-copy — KOPII_FIXTURE_V_KOPII (вход pr-kopii-fixture;
  якорь fixture.schutz.02-в-копии формы PR #147 снят, текст Notice —
  данные model-модуля schutz-dannye.ts); флоу прохода судит ТОЛЬКО
  цели лейсте (testID канона 999 + gespraech-mitte, И-6) — флоу без
  нажатия Mitte красен PROKHOD_BEZ_PRESSABLE (вход
  pr-prokhod-bez-pressable); имена контент-целей (vorgaenge-stroka-*,
  schutz-svod — форма PR #147) не пинируются: полноту контент-целей
  судит манифест СОБСТВЕННОЙ пачки R у судьи формы (sud_pachki) и
  прогон Maestro; флоу без снимка — SCENARIJ_BEZ_SNIMKA; контент удалён — KONTENT_NET;
  package.json без jest-установки — rc 2 LIVE_PREDPOSYLKA; зонд красен
  на исходном коде — ISPOLNIMYJ_KONTROL_KRASEN; мутант переживает зонд
  — ISPOLNIMYJ_MUTANT_ZHIV; второй AVD до остановки первого, а также
  `true || kill`, `echo emu kill` и `if false; then kill; fi` вместо
  реального `adb … emu kill` — EMULJATORY_ODNOVREMENNO по журналу
  (четыре независимых входа); PORT_393=5571 — PORT_393_NE_5576;
  маска профиля R 47 при визуально зелёных кадрах —
  PROFIL_MASKA_NE_48; v6 (слово владельца 22.11): байты производного
  эталона GA-02 dark 393 подменены файлом GA-04 при перепиненом sha —
  ETALON_393_NE_PROIZVODNYJ (вход pr-etalon-393-chuzhoj-bajt; судит
  гейт производности против manifest.json, paket-гейт для 393 —
  только префикс пути: атрибуция причин); порог записи R ослаблен
  (0.5) при зелёной сверке — POROG_NE_0_600 у продукт-судьи (вход
  pr-porog-oslablen); v+1 (слово владельца 2026-11-11, Б-3): корень
  приложения без <SafeAreaProvider — SAFE_AREA_BEZ_PROVAJDERA;
  tab-shell без чтения инсета (useContext(SafeAreaInsetsContext)/
  useSafeAreaInsets) — SAFE_AREA_INSETY_NE_CHITAJUTSJA; зондовый
  ассерт Б-3 (резерв оверлея == инсету на 390 при значениях 24 и 48,
  ≥ на 393, bottom 0) убивает исполняемых мутантов
  safe-rezerv-nul/safe-konstanta; честная база — rc 0.

## Стабы (s65–s101: 15 ветвей эталона A/судьи формы + 22 ветви продукт-судьи B)

Каждый стаб подменяет РОВНО свою ветвь (файл stubs/, загрузчики
_model.py/_produkt.py) и обязан быть пойман на КАЖДОМ входе своей записи
stab_vhod; «стаб жив» — rc 1 STAB_ZHIV. s72 глотает отказы раннера 123
(stdout честный, rc принудительно 0) и свежесть кадров; s77 считает
отсутствие пачки зелёным; s76 пропускает tab-роль Mitte и маркеры
ключей каталога (грамматика 999 и И-2 не защищены; входы pr-mitte-tab,
pr-mitte-net); s97 гасит запреты копии — финал-2 и fixture.*/runtime.
value.* проходят в ui-copy (v5-перенацел 2026-11-15, входы
pr-kopii-final2/pr-kopii-fixture, ветки B KOPII_FINAL2_PREFIKS/
KOPII_DANNYE_PREFIKSY); s98 гасит канон целей лейсте — флоу без
нажатия gespraech-mitte проходит (вход pr-prokhod-bez-pressable,
ветка B PROKHOD_ID_KANON); s82 гасит исполняемый суд (класс «литерал на месте,
исполняемое иное» проходит — блок 1 Crit148, входы pr-live-*);
s83 возвращает подмену отсутствующего макета носителем батареи
(блок 2 Crit148, вход pr-maket-put-net); s84 глотает отказы сверки
профиля — маска 36 при пилюле 393 проходит (v2, слово 31.10, вход
profil-maska-36, ветка A run_sverka_profil); s85 игнорирует журнал
событий (pr-emuljatory-odnovremenno, B _sudit_zhurnal); s86 удаляет
из результатов журнала только EMULJATORY_ODNOVREMENNO (входы
pr-ostanovka-neispolnima, pr-echo-emu-kill, pr-if-false-kill и
pr-emuljatory-odnovremenno, та же ветка); s87 удаляет только
PORT_393_NE_5576 (pr-port-393-sosednij, та же ветка); s88 гасит гейт значения судьи
формы — манифест с 47 проходит визуальный суд (правка Crit148v2,
блок 3, вход profil-maska-ne-48, ветка A proverka_maski_profilja
model/sud_formy_148.py; доставляет делегата --sud сам — интерфейс
субъекта матрицы без обёртки, Н-39); s89 гасит гейт значения
продукт-судьи — манифест R с 47 проходит (правка Crit148v2, блок 3,
вход pr-maska-ne-48, ветка B proverka_maski_profilja); s90 гасит гейт
пакета судьи формы — пин Final 2 проходит визуальный суд и пин-проверку
формы (v+1, слово 2026-11-02, вход paket-final2, ветка A
proverka_paketa model/sud_formy_148.py); s91 гасит гейт пакета
продукт-судьи — пин Final 2 в пачке R проходит (v+1, вход
pr-paket-final2, ветка B proverka_paketa produkt_sud.py); s92 гасит
гейт имён судьи формы — подмена «GA-02 dark» на кадр GA-04 того же
пакета проходит визуальный суд и гейт пакета (v3a Crit148k2a Б1,
вход kadry-podmenen, ветка A proverka_imen_kadrov
model/sud_formy_148.py; делегата --sud доставляет сам, как s90);
s93 гасит гейт имён продукт-судьи — та же подмена в пачке R проходит
(v3a, вход pr-kadry-podmenen, ветка B proverka_imen_kadrov
produkt_sud.py) — ловцы привязаны к входам, где дефект наблюдаем.

s94 гасит гейт производности значений проекции — nav-tokens.ts,
переписанный руками (NAV.height 71) при честном источнике, проходит
(v3b Crit148k2b Б1 + v6-перевод значений, вход pr-tokeny-modul, ветка
B proverka_modulja_tokenov produkt_sud.py); s95 гасит гейт
провайдера — корень без <SafeAreaProvider проходит суд (v+1, слово
владельца 2026-11-11, вход pr-safe-bez-provaidera, ветка B
proverka_provaidera produkt_sud.py); s96 гасит гейт чтения инсета —
лейсте без safe-area инсета проходит (v+1, вход
pr-safe-insety-ne-chitajutsja, ветка B proverka_insetov); v6 (слово
владельца 22.11): s99 гасит гейт производности 393 — байты GA-02,
подменённые файлом GA-04 при перепиненом sha, проходят (вход
pr-etalon-393-chuzhoj-bajt, ветка B proverka_etalonov_393); s100
гасит гейт порога продукт-судьи — запись 393 с porog 0.5 проходит
(вход pr-porog-oslablen, ветка B proverka_poroga); s101 гасит гейт
порога судьи формы — манифест с porog 0.5 проходит (вход
porog-oslablen, ветка A proverka_poroga model/sud_formy_148.py;
делегата --sud доставляет сам, как s88/s90/s92); стабы s82 (гасит
исполняемый суд целиком) и s95/s96 закрывают и
зондовые ассерты Б-3: s82 гасит исполнение резерва, s95/s96 —
статические ветви; ловцы привязаны к входам, где дефект наблюдаем.
