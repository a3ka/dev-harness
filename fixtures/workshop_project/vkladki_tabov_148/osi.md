# Оси батареи 148 (vkladki-tabov) — 57 клеток, 30 стабов, 47 привязок
# (`--model` rc 0 57/57; `--stabs` rc 0, контроль 57/57,
# «SVJAZI 47», живых 0; без флага — rc 1, зелёных 37 /
# красных 20: продукта в дереве харнесса нет).

Субъекты (Н-39: стабы привязаны к ветвям ОБОИХ субъектов по stab_vhod
source.json — привязка кодом, не прозой):

- **A (форма)** — судья формы `model/sud_formy_148.py` (правки
  Crit148v2 блок 3 + v+1): гейт ТОЧНОГО значения маски профиля
  (mera.chrome_verh_pt == 48) и гейт ПАКЕТА (каждый кадр обоих
  манифестов — docs/ux/05_Kompakt_D24/frames/ + sha == записи
  nositeli/paket/SHA256SUMS пакета D24-Kompakt-1.1; возврат пина
  D 2.4 Final 2 — PAKET_1_1_NE_PRIPINEN; v3a Crit148k2a Б1: гейт ИМЁН
  KADR_PODMENEN — пин каждой записи ↔ её идентификатор по оракулу
  kadry_manifest/profil_kadry) ПОСЛЕ визуального суда
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
  Без package.json — именованный пропуск; заявленная среда без
  установки — rc 2 LIVE_PREDPOSYLKA. Эталон — референсная раскладка
  `model/produktnaja-raskladka` (пачка — source.json:.ekran_forma_prod).

Оракул — source.json (kejsy: rc/prichiny/stdout с допуском 0.01 на
KADR-числа; stubs ↔ stab_vhod — рассинхрон rc 2 ORACLE_TAMPERED ДО
клеток; пины носителей и эталонной раскладки сверяются ДО клеток —
правило 8). Честные кадры stand-in — перегонка макетов (декодер ct 2/6,
энкодер RGBA: пиксели те же, байты иные — приём 118/132; KADR 1.000 во
всех восьми строках обеих баз). Временные репо/пачки — mktemp, без
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
- **Кадры/макеты** (5): байты макета GA-03 изменены при том же пине —
  MAKET_PODMENEN; кадр GA-03 dark с залитой полосой Mitte —
  KADR_NIZHE_POROGA; кадры положены ДО команды и команда молчит —
  KADR_USTAREVSHIJ (оба манифеста — два одноимённых отказа); e2e rc 1 —
  E2E_NE_PROSHLA; id кадра == id живой пачки 132 — CHUZHIE_KADRY.
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
  владельца 31.10: пилюля Dynamic Island стёрта из стенд-ин снимков —
  эмулятор вырез не рисует; в кадрах 1.1 пилюля x133–258, y11–47) —
  KADR_NIZHE_POROGA на светлых GA-03/GA-04 393 (0.595/0.565 < 0.600,
  кадры 1.1; GA-02 light 393, тёмные и GA-09 при 36 зелёны — кадры
  1.1 в зоне пилюли мягче финала-2, порог и механизм не меняются;
  живой прообраз Q1б краснел тройкой 0.425/0.414/0.392); значение
  маски 47 при визуально зелёных кадрах (правка Crit148v2, блок 3) —
  PROFIL_MASKA_NE_48: инвариант ТОЧНОГО значения 48 судит судья
  формы ПОСЛЕ визуального суда.
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
- **Продукт** (20): шов без слотов — SHOV_NET; подмена имени кадра
  в пачке R при честных файле и sha — KADR_PODMENEN (v3a, вход
  pr-kadry-podmenen); дрейф байтов источника токенов —
  TOKENY_ISTOCHNIK_NEVEREN (И-12; живые обходы Б2/Б3 роняют контроль
  зонда — ISPOLNIMYJ_KONTROL_KRASEN, приёмка 16); Mitte с tab-ролью —
  MITTE_V_TAB; пачка удалена — PACHKA_ABSENT; пин макета неверен либо
  PNG удалён по каноническому пути — MAKET_PIN_NEVEREN; пин пачки R
  на Final 2 при честных файлах — PAKET_1_1_NE_PRIPINEN (v+1, вход
  pr-paket-final2, клетка 14; stdout честен — KADR×8 + SHABLON OK,
  красит гейт пакета продукт-судьи); ключи копии удалены — KOPII_NET;
  флоу без снимка — SCENARIJ_BEZ_SNIMKA; контент удалён — KONTENT_NET;
  package.json без jest-установки — rc 2 LIVE_PREDPOSYLKA; зонд красен
  на исходном коде — ISPOLNIMYJ_KONTROL_KRASEN; мутант переживает зонд
  — ISPOLNIMYJ_MUTANT_ZHIV; второй AVD до остановки первого, а также
  `true || kill`, `echo emu kill` и `if false; then kill; fi` вместо
  реального `adb … emu kill` — EMULJATORY_ODNOVREMENNO по журналу
  (четыре независимых входа); PORT_393=5571 — PORT_393_NE_5576;
  маска профиля R 47 при визуально зелёных кадрах —
  PROFIL_MASKA_NE_48; честная база — rc 0.

## Стабы (s65–s93: 14 ветвей эталона A/судьи формы + 15 ветвей продукт-судьи B)

Каждый стаб подменяет РОВНО свою ветвь (файл stubs/, загрузчики
_model.py/_produkt.py) и обязан быть пойман на КАЖДОМ входе своей записи
stab_vhod; «стаб жив» — rc 1 STAB_ZHIV. s72 глотает отказы раннера 123
(stdout честный, rc принудительно 0) и свежесть кадров; s77 считает
отсутствие пачки зелёным; s76 пропускает tab-роль Mitte (грамматика 999
не защищена); s82 гасит исполняемый суд (класс «литерал на месте,
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
