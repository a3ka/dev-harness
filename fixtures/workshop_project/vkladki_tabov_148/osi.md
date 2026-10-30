# Оси батареи 148 (vkladki-tabov) — 40 клеток, 17 стабов, 29 привязок
# (числа — из вывода прогонов этой пачки: `--model` rc 0 40/40;
# `--stabs` rc 0, контроль 40/40, «SVJAZI 29», живых 0; без флага —
# rc 1, зелёных 2 / красных 38 — живой валидатор остаётся v2 и продукт
# в дереве харнесса отсутствует: честная краснота ДО реализации)

Субъекты (Н-39: стабы привязаны к ветвям ОБОИХ субъектов по stab_vhod
source.json — привязка кодом, не прозой):

- **A (форма)** — живой `scripts/ekran_shablon.py` на модельной пачке
  «vkladki» (shablon 3; носители — 16 РЕАЛЬНЫХ макетов GA-02/03/04/09 из
  product main, байты пиннены sha256 в source.json:.piny.nositeli, и
  подмножества источников D 2.4 тем же построением, что батарея 146).
  Эталон — `model/ekran_shablon.py`: байт-копия ЗАМОРОЖЕННОЙ модели 146
  (v3 = frozen 132/2 + ветка dvizhenie; frozen/contracts/146/1,
  harness main 9df5a4b5b), пин ab26d789…39b679e проверяется
  load_source ДО клеток; дрейф модели после заморозки 146 невозможен
  без новой версии 146 — тогда пин и ожидания kejsy переснимаются
  прогоном `--snapshot` ДО freeze 148.
- **B (продукт)** — `produkt_sud.py --repo R`: статические маркеры шва
  TabShell (слоты mitte/sectionScreens), Mitte (FadenSign size="tab",
  ключи статусов, testID, роль НЕ tab), контент-файлы трёх доменов,
  ключи ui-copy, пины макетов (8+8 кадров), покрытие флоу снимками обоих
  профилей и pressable; затем ДОРОГОЙ полный суд пачки эталоном v3 в
  синтетическом репо, собранном из файлов R и носителей. Эталон —
  собранная референсная раскладка `model/produktnaja-raskladka` (код
  референса 148 + флоу; пачка пишется из source.json:.ekran_forma_prod).

Оракул — source.json (kejsy: rc/prichiny/stdout с допуском 0.01 на
KADR-числа; stubs ↔ stab_vhod — рассинхрон rc 2 ORACLE_TAMPERED ДО
клеток; пины носителей и эталонной раскладки сверяются ДО клеток —
правило 8). Честные кадры stand-in — перегонка макетов (декодер ct 2/6,
энкодер RGBA: пиксели те же, байты иные — приём 118/132; KADR 1.000 во
всех восьми строках обеих баз). Временные репо/пачки — mktemp, без
сети/omp/эмулятора.

## Базы (две, обе честные, rc 0)

- `chestnyj-vkladki` — модельная пачка: stdout KADR×8 (1.000) +
  SHABLON vkladki OK; приёмки исполнены стенд-инами (e2e кладёт кадры
  обоих профилей в Maestro-раскладку, сверка-образец == вывод раннера
  123, проход rc 0, отчёт движения свеж: timestamp меняет байты).
- `pr-chestnaja` — продукт-судья на референсной раскладке: тот же
  stdout (KADR×8 + SHABLON OK) — пачка референса проходит эталон целиком
  (живой прогон канона на реальном продукте — produkt_sud --repo
  <копия продукта>: rc 0, SHABLON vkladki OK, замер пачки).

## Оси клеток (каждая красная — ровно одна именованная причина; каскады
срезаны порядком суда «дешёвое раньше дорогого»; двойные одноимённые
отказы — по кадру на тему, законны и оговорены)

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
- **Второй профиль** (5): 320×640 — PROFIL_NIZHE_MINIMUMA (+ZALEZAET_POD_INSET
  законен: элементы не влезают в класс ниже нормы — двойной отказ
  оговорён); vyrez 0 — PROFIL_BEZ_INSETOV; одна тема — ODNA_TEMA; флоу
  без токена tabshell — MARSHRUT_BEZ_OBOLOCHKI; флоу без снимка
  профиля — MARSHRUT_BEZ_SNIMKA.
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
- **Продукт** (8): шов без слотов — SHOV_NET; Mitte с tab-ролью —
  MITTE_V_TAB; пачка удалена — PACHKA_ABSENT; пин макета неверен —
  MAKET_PIN_NEVEREN; ключи копии удалены — KOPII_NET; флоу без снимка —
  SCENARIJ_BEZ_SNIMKA; контент-файл удалён — KONTENT_NET; честная база —
  rc 0 (канон).

## Стабы (s65–s81: 10 ветвей эталона A + 7 ветвей продукт-судьи B)

Каждый стаб подменяет РОВНО свою ветвь (файл stubs/, загрузчики
_model.py/_produkt.py) и обязан быть пойман на КАЖДОМ входе своей записи
stab_vhod; «стаб жив» — rc 1 STAB_ZHIV. s72 глотает отказы раннера 123
(stdout честный, rc принудительно 0) и свежесть кадров; s77 считает
отсутствие пачки зелёным; s76 пропускает tab-роль Mitte (грамматика 999
не защищена) — ловцы привязаны к пр-* входам.
