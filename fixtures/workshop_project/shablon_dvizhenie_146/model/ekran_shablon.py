#!/usr/bin/env python3
# ЭТАЛОН 146 (v3 шаблона 132): эталон поведения батареи
# fixtures/workshop_project/shablon_dvizhenie_146/probe.py; та же
# грамматика вывода, что у субъекта scripts/ekran_shablon.py. v3 =
# frozen 132/2 (байт-в-байт поведением v1/v2) + блок dvizhenie:
# шапка-докстринг, константы KLJUCHI_DVIZHENIE/алфавиты, ветка
# check_dvizhenie + исполнение priemka_dvizhenija (слово владельца
# 2026-10-28 mob-dvizhenie §Решение п.4; слово владельца 2026-10-28
# d24-gespraech-final2 — «со всей динамикой и движениями»).
"""Шаблон контракта экрана mob (132): машиночитаемая форма ekran.json + проверки.

Форма (замкнутый состав): v1 — 17 полей ниже (СТАРЫЙ экран); v2 — те же
  17 + shablon + prokhodimost + vtoroj_profil (НОВЫЙ экран; слово
  владельца 2026-10-27 ~22:45 UTC — «правило проходимости» и ~23:45 UTC —
  сверка на ВТОРОМ профиле экрана с safe-area; уже замороженные экранные
  контракты блоков не несут и не переоткрываются); v3 — v2 + dvizhenie
  (shablon: 3 — экран с движением; слово владельца 2026-10-28
  mob-dvizhenie §Решение п.4, пилот 145 — численная приёмка против
  pose()/path() и спеки движения):
  ekran          id экрана, [a-z0-9][a-z0-9-]{0,63} — ОДИН экран на контракт
  kadry          путь в пачке: манифест кадров грамматики 123 (kadry_117.json)
  sostojanija    непустой список [a-z0-9-]+, без повторов
  kljuchi_kopii  непустой список [A-Za-z0-9_.-]+; каждый есть в каталоге копии
  operacii_api   список [A-Za-z0-9_.-]+ (может быть пуст); каждый operationId
                 есть в API-спецификации
  katalog_kopii  путь в репо продукта: каталог копии (JSON)
  spec_api       путь в репо продукта: API-спецификация (JSON, operationId)
  audit_tokenov  путь в репо продукта: общий аудит токенов D2.2.5.1 —
                 ЕДИНСТВЕННОЕ место, где допустимы литералы цветов/размеров
  e2e_scenarij   путь в репо продукта: сценарий android-e2e; содержит каждый
                 snimok манифеста кадров
  kadry_dir      путь в репо продукта: каталог кадров Maestro-раскладки
  kontrakt       путь в пачке: контракт экрана «на одну страницу» (воля
                 владельца) — ТРИ меры объёма: ≤ 60 строк, ≤ 120 символов
                 в строке, ≤ 4000 байт файла (NE_ODNA_STRANICA); несёт
                 обязательные разделы
                 (Воля владельца, Существующее, Инварианты, Приёмочный
                 критерий, Зоны и исполнители, ПРОВОДКА, Модель угроз) и
                 ЗОНА-строки, равные zony формы
  batareja       непустой список путей в пачке: файлы батареи экрана
  priemka        {"e2e": командная строка android-e2e, "sverka": командная
                 строка сверки}. v2 (shablon 2) несёт ТРЕТЬЮ команду
                 "prokhod" — проход Maestro по видимым pressable (каждое
                 нажатие даёт наблюдаемое изменение либо кнопка помечена
                 неактивной; слово владельца 2026-10-27). Команда прохода
                 несёт ЦЕЛЬ-ФЛОЮ Maestro: непустой argv с существующим
                 .yaml в репо, флоу ссылается на КАЖДЫЙ pressable обоих
                 списков манифеста обособленным токеном В ИСПОЛНЯЕМОМ
                 ТЕКСТЕ флоу — после первого «---», без комментариев YAML
                 (шапка name:/комментарий ссылкой не являются; С-2
                 арбитража 132 v2). argv БЕЗ цели-флою (true/echo ok/
                 sh -c exit 0) — PROKHOD_NE_MAESTRO rc 1; флоу без
                 pressable — PROKHOD_BEZ_PRESSABLE rc 1 (блокер 2 вердикта
                 критика 1/2); С-3: механизм различает именно ОТСУТСТВИЕ
                 цели-флою — команда с .yaml в argv без Maestro (echo/cat/
                 обёртка-заглушка) rc 0 без нажатий, честный остаток, ловец
                 — продуктовый CI и ревью). ОБЕ/ТРИ
                 ИСПОЛНЯЮТСЯ фактическим argv (cwd = репо
                 пробел единственный разделитель, прецедент Г3-002):
                 e2e — rc 0, и кадры СВЕЖИ: каждый файл под kadry_dir
                 создан ЭТИМ запуском (mtime не старше старта команды И
                 байты отличаются от дозапускового состояния) — иначе
                 KADR_USTAREVSHIJ; команда без кадров даёт
                 KADR_OTSUTSTVUET, не зелень;
                 sverka — rc 0 И stdout дословно равен выводу раннера 123 по
                 манифесту пачки (сверка-образец); строка обязана нести
                 --manifest И быть ТОЧНЫМ вызовом раннера 123: python3
                 <путь файла> --manifest M --kadry DIR --repo R (полный
                 argv CLI 123), где файл по <путь файла> идентичен
                 эталонному раннеру БАЙТАМИ — sha256 равен
                 --harness/scripts/sverka_maketa.py (разрешённый путь
                 раннера: пин .harness123 репо / scripts/ харнесса;
                 честные относительный и абсолютный вызовы, симлинк,
                 байт-в-байт копия — зелёные; имя/суффикс пути — НЕ
                 дискриминатор: …sverka_maketa.py.fake и
                 podmena/scripts/sverka_maketa.py с константной репликой
                 stdout — SAMODELNAYA_SVERKA; блокеры 2/1 вердикта
                 adv-132)
                 Три значения argv связаны с пачкой: --manifest —
                 sha256 файла == sha256 pack/kadry (байт-копия допустима);
                 --kadry — realpath == repo/kadry_dir, --repo — realpath
                 == repo; чужой или отсутствующий путь —
                 SAMODELNAYA_SVERKA с именем флага (арбитраж
                 verdicts/arbitration/contracts-132-impl-kap.md П-1).
  zony           {"architect": [...], "implementer": [...]} — грамматика
                 check_zones: относительные пути без *?[ , без .., без
                 ведущего /; каталог с завершающей /
  zamenjaet      null | путь в харнессе ИЛИ репо продукта: манифест кадров
                 ЗАМЕНЯЕМОГО контракта того же экрана; кадры нового —
                 надмножество КАЖДОГО найденного манифеста этого пути
                 (суд в каждом корне, где файл есть; замена целиком)
  ne_trogaet     список путей в харнессе ИЛИ репо продукта: живые манифесты
                 ЧУЖИХ экранов; пересечение id кадров пусто с КАЖДЫМ
                 найденным манифестом каждого пути (чужих пикселей
                 не морозит)
  fiktura        bool; СУДИМАЯ пачка обязана быть false (фикция не судится);
                 false у живой пачки делает её видимой обнаружению (ниже)
  shablon        целое 2 — объявление пачки НОВЫМ экраном под шаблон v2;
                 другие значения/типы — SHABLON_NEVEREN; пачка без поля
                 судится по v1 ТОЛЬКО при подлинной идентичности
                 замороженного экрана: ekran из закрытого отображения
                 ZAMOROZHENNYE_STARYE_EKRANY (id + пины макетов
                 замороженного манифеста: 135/138/116/118, источник нормы
                 единожды, пополнение — только v+1 шаблона) И непустые
                 пины maket_sha256 манифеста пачки ⊆ пинам этого id; иначе
                 — SHABLON_OTSVTSTVUET rc 1 (подробность называет id и
                 чужие пины): «старый» — факт идентичности по пинам
                 замороженного манифеста, не самодекларация id (блокер 1
                 вердикта критика 1/2 — свежий экран, опустивший shablon,
                 не выдаёт себя за старый; С-1 арбитража 132 v2 — и новый
                 экран ПОД историческим id с чужими макетами тоже)
  prokhodimost  блок проходимости НОВОГО экрана (при shablon 2 ОБЯЗАТЕЛЕН;
                 отсутствие — PROKHODIMOST_OTSVTSTVUET rc 1 с именем поля —
                 правило 7 AGENTS: неразобранное объявление отказывает с
                 названным местом и выходом): {"pressable": […], "demo":
                 […], "safe": {"verh": N, "niz": N, "vysota": N}}; числа
                 геометрии — ЦЕЛЫЕ pt из манифеста экрана (литералы
                 размеров в пачке по-прежнему запрещены — инвариант 3):
                 pressable — непустой перечень ВИДИМЫХ продуктовых целей
                 {id (testID, [a-z0-9][a-z0-9-]{0,63}), sostojanie
                 deistvie|neaktivna, shirina, vysota, x, y ≥ 0, demo:
                 false}: deistvie — izmenenie (наблюдаемое изменение либо
                 маршрут) ОБЯЗАТЕЛЬНО (иначе PRESSABLE_BEZ_IZMENENIJA);
                 neaktivna — kadry (непустой список id кадров манифеста
                 пачки — disabled-вид) ОБЯЗАТЕЛЕН (иначе NEAKTIVNA_BEZ_KADRA);
                 demo — демо-переключатели (может быть пуст): та же запись
                 + demo: true + otdelenie (заявление визуального отделения
                 — отдельный контейнер/подпись); размеры касания ≥ 44pt
                 (норма правила проходимости, закреплена единожды —
                 MIN_KASANIE_PT), иначе KASANIE_MENSHE_NORMY; цель ВНЕ
                 safe-area: y ≥ safe.verh И y+vysota ≤ safe.vysota−safe.niz,
                 иначе KASANIE_V_SAFE_ZONE; метки согласованы со списками:
                 запись списка demo обязана нести demo: true (иначе
                 DEMO_NE_OTMECHEN), запись списка pressable — demo: false
                 (иначе DEMO_V_SOSTAVE), демо без otdelenie —
                 DEMO_BEZ_OTDELENIJA; id уникальны в обоих списках
  vtoroj_profil блок второго профиля НОВОГО экрана (при shablon 2
                 ОБЯЗАТЕЛЕН вместе с prokhodimost; отсутствие —
                 VTOROJ_PROFIL_OTSVTSTVUET rc 1 с именем поля, правило 7
                 AGENTS; слово владельца 2026-10-27 ~23:45 UTC): профиль
                 iphone-safe-area — сверка ЦЕЛОГО экрана в СОБРАННОМ пути
                 (оболочка + путь входа, как видит пользователь) в ОБЕ
                 темы вторым набором кадров: {"profil": "iphone-safe-area"
                 (замкнутый перечень из одного), "shirina", "vysota",
                 "vyrez", "home" — ЦЕЛЫЕ pt ЗНАЧЕНИЯ ПАЧКИ, судятся против
                 НОРМЫ КЛАССА PROFIL_IPHONE (единый источник нормы:
                 ≥ 393×852, вырез 47–59, home-indicator 34; ниже класса —
                 PROFIL_NIZHE_MINIMUMA, инсеты вне нормы —
                 PROFIL_BEZ_INSETOV), "obolochka" — заявленная оболочка
                 собранного пути ([a-z0-9-]+; ПУСТАЯ — GOLYJ_KOMPONENT:
                 голый компонент/маршрут без оболочки сверкой не
                 принимается), "marshrut" — путь в репо продукта: флоу
                 СОБРАННОГО пути входа: содержит obolochka обособленным
                 токеном И каждый snimok манифеста профиля ТЕМ ЖЕ
                 обособленным токеном — В ИСПОЛНЯЕМОМ ТЕКСТЕ флоу
                 (ispolnimye_stroki_flo: после первого «---», без
                 комментариев YAML — шапка name: и «# tabshell»/
                 «# - takeScreenshot: …» ссылкой не являются; С-2
                 арбитража 132 v2; вход в оболочку наблюдаем, не
                 декларация; связь исполненного пути с каждым кадром;
                 иначе MARSHRUT_BEZ_OBOLOCHKI / MARSHRUT_BEZ_SNIMKA rc 1 —
                 блокер 3 вердикта критика 1/2: поддельная оболочка/
                 голый маршрут не принимаются),
                 "kadry" — путь в пачке: ВТОРОЙ манифест
                 кадров той же грамматики 123 (кадры ОБЕИХ тем:
                 dark И light — иначе ODNA_TEMA), "elementy" —
                 непустой перечень элементов собранного экрана из
                 UI-дерева: {id, tip shapka|zagolovok|ikonka|kontrol|
                 prochee, x, y, shirina, vysota ≥ 0, у ikonka — glif
                 ИЛИ dostupnoe_imja (нет ни того, ни другого —
                 PUSTAJA_IKONKA)}; наложение слоёв — два элемента с
                 пересечением bbox положительной площади (NALOZHENIE_SLOEV),
                 залезание под вырез/статус-бар (y < vyrez) либо
                 home-indicator (y+vysota > vysota−home) — ZALEZAET_POD_INSET;
                 кадры профиля кладёт ТА ЖЕ priemka.e2e (второй AVD с
                 вырезом/инсетами внутри продуктового e2e), судит их
                 ВАЛИДАТОР прямым вызовом раннера 123 по манифесту профиля
                 (ниже порога — KADR_NIZHE_POROGA с именем кадра профиля;
                 четвёртой команды приёмки нет); макет — тот же PNG
                 docs/ux на экран/тему.

Живые пачки (грамматика ОБНАРУЖЕНИЯ, отдельно от полной формы): файл
ekran.json под fixtures/workshop_project/** В ОБОИХ корнях — харнесса И
переданного репо продукта (--repo; обход круга 2: живая пачка в продукте
невидима харнесс-скану) — с полями ekran ([a-z0-9][a-z0-9-]{0,63}), kadry
(относительный путь) и fiktura != true. Судимая пачка исключает из
обнаружения себя (сравнение путей в каждом корне). Полнота объявлений
против обнаруженных живых пачек: живая пачка ТОГО ЖЕ ekran — её манифест
обязан быть назван в zamenjaet (ZAMENJAET_NE_POLON); живая пачка ЧУЖОГО
ekran — её манифест обязан стоять в ne_trogaet (NE_TROGAET_NE_POLON).
Один и тот же путь в двух корнях — ОДНА запись обнаружения, но суд
манифеста — по КАЖДОМУ файлу в каждом корне, где он есть (коллизия
корней, арбитраж 132 Б: читаются все корни, не первый найденный).
Замена целиком: заменяющий контракт экрана удаляет пачку предшественника
своей зоной — живость определяется наличием ekran.json.
  dvizhenie     блок движения НОВОГО экрана (shablon 3; замкнутый состав
                 ключей — KLJUCHI_DVIZHENIE; отсутствие блока при
                 shablon: 3 — DVIZHENIE_OTSVTSTVUET rc 1; блок при
                 shablon: 2 — SHABLON_NEVEREN; слово владельца
                 2026-10-28 mob-dvizhenie §Решение п.4 «после пилота»):
                 "manifest"/"spec"/"pozvonok" — пути в репо продукта:
                 манифест пакета дизайнера (screens/motion списки),
                 спецификация движения (tokens/scenes), оракул поз знака
                 (scenes; пилот 145); каждому — "_sha256" пин байтов
                 файла в репо (ISTOCHNIK_NE_SOVPADAET rc 1; нет файла —
                 ISTOCHNIK_OTSVTSTVUET rc 2, fail-closed); "ekrany" —
                 список GA-идов экранов ЭТОЙ пачки (^GA-[0-9]{2}$,
                 каждый — экран манифеста; каждый кадр манифеста пачки с
                 GA-якорем (^GA-[0-9]{2}($| )) обязан быть объявлен —
                 EKRANY_NE_POLNY; объявленный без кадров — EKRAN_BEZ_KADROV;
                 посторонний — EKRAN_VNE_MANIFESTA; кадры с GA-якорем у
                 пачки БЕЗ shablon: 3 — DVIZHENIE_OTSVTSTVUET с именами
                 кадров: экран D 2.4 не прячет движение за v2);
                 "perehody" — переходы пачки: ПОЛНОТА против манифеста —
                 всякий id движения манифеста, чьи frames ∩ ekrany ≠ ∅,
                 обязан быть объявлен (PEREHODY_NE_POLNY), посторонний
                 (frames ∩ ekrany = ∅) — PEREHOD_LISHNIJ, вне манифеста —
                 PEREHOD_VNE_MANIFESTA; у объявленного перехода обязана
                 быть сцена спеки (PEREHOD_BEZ_SPECY);
                 "sceny_znaka" — РОВНО perehody ∩ сцены оракула поз
                 (пропуск — SCENY_ZNAKA_NE_POLNY, лишняя —
                 SCENA_VNE_ORAKULA; переход без поз-оракула — морф-треки,
                 сценой знака НЕ объявляется);
                 "etalony" — на КАЖДЫЙ perehod: keyframes — по темам
                 dark/dark_reduced/light/light_reduced РОВНО столько
                 sha256-пинов, сколько файлов ключевых кадров в files
                 сцены спеки (ETALON_TEMA_OTSVTSTVUET/ETALON_NE_POLON;
                 не-hex — ETALON_NE_HEX), video — sha256 на каждую тему
                 из files сцены (VIDEO_ETALON_NE_POLON); посторонний
                 ключ — ETALON_LISHNIJ; байты эталонов живут во вложении
                 Release пакета дизайнера (вне репо) — валидатор судит
                 наличие/форму/число, байты — vision-судьи по SHA256SUMS;
                 "priemka_dvizhenija" — командная строка ЧИСЛЕННОЙ
                 приёмки движения (jest-реплей против оракулов; алфавит
                 RE_PRIEMKA): argv несёт "--json" и "--outputFile" с
                 путём отчёта в репо (DVIZHENIE_BEZ_OTCHETA) —
                 ИСПОЛНЯЕТСЯ фактическим argv (cwd = репо): rc ≠ 0 —
                 DVIZHENIE_NE_PROSHLA; отчёт свеж (mtime не старше старта
                 И байты отличны от дозапусковой ревизии — OTCHET_USTAREVSHIJ),
                 читается как JSON (OTCHET_NE_CHITAETSJA),
                 numTotalTests > 0 (OTCHET_PUSTOJ) и numPassedTests ==
                 numTotalTests (OTCHET_S_PROVALAMI).
  Грамматика СПЕКИ движения (судится ПО ОБЪЯВЛЕННЫМ переходам пачки —
  чужие сцены вне суда; токены — единый источник spec.tokens; числа
  производны, обязаны совпадать): длительность — имя токена (сырое число —
  DLITELNOST_BEZ_TOKENA) И ms == значению токена (ZNACHENIE_NE_TOKENA);
  задержка — число | имя токена | арифметика n*token / a + b - c над
  ними, значение обязано совпадать (ZADERZHKA_NE_PO_GRAMMATIKE /
  ZADERZHKA_NE_SOGLASNA); кривая — ease-standard | ease-morph | linear
  (KRIVAYA_VNE_KANONA; значение кривой == значению токена), пружина
  запрещена (spring != null — PRUZHINA_ZAPRESHCHENA); УД —
  reduced_duration_ms обязателен (UD_BEZ_STOLBCA): перемещение/размер
  (свойство вне {opacity, bg}) — 0, видимое (opacity/bg) — не дольше
  токена motion-fast (UD_NARUSHEN; правило MOTION reduced_motion);
  end_ms == delay + duration (END_MS_NE_RAVEN); порядок — order 1..n
  без повторов (PORYADOK_NARUSHEN); keyframes_ms — ровно 0/25/50/75/100 %
  и значения == window_ms[1]×k/100 (KLJUCHEVYE_KADRY_NE_RAVNY), окно
  от нуля (OKNO_NE_OT_NULJA); files сцены — 4 темы видео + 4 темы
  ключевых кадров, списки непусты (FAJLY_ETALONOV_NE_POLNY).

Проверки (порядок «дешёвые раньше дорогих»: при любом отказе формы/полей
дешёвых проверок дорогое не зовётся):
  алфавит/грамматика формы и путей, существование файлов, разделы и ОБЪЁМ
  (≤ 60 строк) контракта, равенство ЗОНА-строк контракта форме, запрет
  литералов, ключи копии, операции API, покрытие сценария, токены команды
  сверки, замена целиком, чужие кадры, полнота объявлений,
  ПРОХОДИМОСТЬ (блок prokhodimost НОВОГО экрана: статическая ветвь (г)
  — манифест → вердикт rc: полнота состояний, размеры ≥ 44pt,
  safe-area, метки/отделение демо), ВТОРОЙ ПРОФИЛЬ (блок vtoroj_profil:
  норма класса PROFIL_IPHONE, оболочка собранного пути, обе темы,
  наложения слоёв/залезания под инсеты/пустые иконки геометрией bbox из
  UI-дерева — статическая ветвь), МАРШРУТ собранного пути (marshrut:
  obolochka токеном + каждый snimok профиля ТЕМ ЖЕ токеном — в
  ИСПОЛНЯЕМОМ тексте флоу, блокер 3 вердикта критика 1/2 + С-2
  арбитража 132 v2), КОМАНДА прохода (цель-флоу .yaml, ссылающийся на
  каждый pressable в исполняемом тексте — блокер 2 вердикта критика
  1/2 + С-2/С-3 арбитража 132 v2), СТАРОСТЬ ЭКРАНА — последняя
  дешёвая, НА ПУТИ К ЗЕЛЕНИ: пачка без shablon судится по v1 только
  при подлинной идентичности замороженного экрана (id ∈ отображению
  ZAMOROZHENNYE_STARYE_EKRANY И пины её манифеста ⊆ пинам id);
  иначе — SHABLON_OTSVTSTVUET rc 1 ровно там, где пачка иначе прошла
  бы (блокер 1 вердикта критика 1/2 + С-1 арбитража 132 v2: зелени
  без маркера и без подлинной идентичности не существует)
  — затем ИСПОЛНЕНИЕ priemka.e2e (argv, rc 0; кладёт кадры ОБОИХ
  профилей), СВЕЖЕСТЬ оставшихся кадров (ревизия kadry_dir до команды:
  пути+sha256; после — mtime моложе старта и байты иные — оставшиеся кадры
  прежнего прогона не засчитываются, KADR_USTAREVSHIJ), сверка-образец
  раннером 123 по манифесту пачки (каждый кадр не ниже порога), затем
  ИСПОЛНЕНИЕ priemka.sverka (argv, rc 0 + дословное совпадение вывода со
  сверкой-образцом), затем сверка ВТОРОГО ПРОФИЛЯ — прямой вызов раннера
  123 по манифесту профиля (успех молча: вывод первого набора остаётся
  дословным; ниже порога/нет кадра — именованный отказ с кадром профиля),
  последней — ИСПОЛНЕНИЕ priemka.prokhod (argv, rc 0 — проход Maestro
  жмёт кнопки ПОСЛЕ сверки кадров; нажатие без наблюдаемого изменения —
  PROKHOD_NE_PROSHLA).

Литералы (ЗАПРЕЩЕНЫ во всех текстовых файлах пачки; судятся КЛАССОМ, не
перечнем образцов — обход круга 2: hwb()/проценты/ch; арбитраж круга 3:
суд по ВСЕМУ ТЕКСТУ файла — перенос строки внутри функции литерал не
прячет): цвета — hex #[0-9a-fA-F]{3,8} И ЛЮБАЯ функциональная запись
«идентификатор(…число…)» (все CSS-функции цвета и функциональные нотации
размеров: rgb/hsl/hwb/lab/oklch/color/calc/min/…, аргументы — числа,
в т.ч. с ведущими нулями); размеры — число с % ИЛИ любой буквенной
единицей 1–4 букв (px/rem/ch/vmin/…, ведущие нули — по-прежнему число).
Маска дайджеста — ОБСОБЛЕННОЕ hex-слово 16+ с хотя бы одной буквой a–f
(sha-пин манифеста — не литерал); число из цифр и аргумент функции маска
НЕ стирает; словоформа «цифры + буквенная единица 1–4 букв» маской НЕ
стирается и тогда, когда буквы единицы лежат в a–f (блокер 1 вердикта
adv-132: 0000000000000001fa — размерный литерал, не дайджест: класс
«число + единица» приоритетнее маски). файл:строка — строка НАЧАЛА
совпадения.

CLI: ekran_shablon.py --pack DIR --repo DIR --harness DIR
Вывод: stdout — строки раннера 123 (KADR...) дословно, затем при успехе
  SHABLON<TAB><ekran><TAB>OK
stderr — строка на отказ PRICHINA<TAB>имя<TAB>подробности.
rc: 0 — форма верна, приёмка исполнена, все кадры не ниже порога;
1 — LITERAL_VNE_AUDITA / KLJUCH_BEZ_KATALOGA / OPERACIJA_BEZ_SPEKA /
SCENARIJ_BEZ_SNIMKA / SAMODELNAYA_SVERKA / E2E_NE_PROSHLA / NE_TSELIKOM /
CHUZHIE_KADRY / ZAMENJAET_NE_POLON / NE_TROGAET_NE_POLON / ZONY_RASHODJATSJA /
RAZDEL_OTSVTSTVUET / NE_ODNA_STRANICA / KADR_NIZHE_POROGA /
KADR_OTSUTSTVUET / KADR_USTAREVSHIJ / KADR_NEODNOZNACHEN / KADR_NECHITAEM /
MAKET_PODMENEN / PROKHODIMOST_OTSVTSTVUET / SHABLON_OTSVTSTVUET /
PRESSABLE_BEZ_IZMENENIJA / NEAKTIVNA_BEZ_KADRA / KASANIE_MENSHE_NORMY /
KASANIE_V_SAFE_ZONE / DEMO_NE_OTMECHEN / DEMO_V_SOSTAVE / DEMO_BEZ_OTDELENIJA /
PROKHOD_NE_PROSHLA / PROKHOD_NE_MAESTRO / PROKHOD_BEZ_PRESSABLE /
VTOROJ_PROFIL_OTSVTSTVUET / PROFIL_NIZHE_MINIMUMA / PROFIL_BEZ_INSETOV /
GOLYJ_KOMPONENT / NALOZHENIE_SLOEV / ZALEZAET_POD_INSET / PUSTAJA_IKONKA /
ODNA_TEMA / MARSHRUT_BEZ_OBOLOCHKI / MARSHRUT_BEZ_SNIMKA / v3-движение:
DVIZHENIE_OTSVTSTVUET / EKRANY_NE_POLNY / EKRAN_BEZ_KADROV /
EKRAN_VNE_MANIFESTA / PEREHODY_NE_POLNY / PEREHOD_LISHNIJ /
PEREHOD_VNE_MANIFESTA / PEREHOD_BEZ_SPECY / SCENY_ZNAKA_NE_POLNY /
SCENA_VNE_ORAKULA / ETALON_BEZ_PINOV / ETALON_LISHNIJ /
ETALON_TEMA_OTSVTSTVUET / ETALON_NE_POLON / ETALON_NE_HEX /
VIDEO_ETALON_NE_POLON / ISTOCHNIK_NE_SOVPADAET / DVIZHENIE_BEZ_OTCHETA /
DVIZHENIE_NE_PROSHLA / OTCHET_OTSVTSTVUET / OTCHET_USTAREVSHIJ /
OTCHET_NE_CHITAETSJA / OTCHET_PUSTOJ / OTCHET_S_PROVALAMI /
DLITELNOST_BEZ_TOKENA / ZNACHENIE_NE_TOKENA / ZADERZHKA_NE_PO_GRAMMATIKE /
ZADERZHKA_NE_SOGLASNA / KRIVAYA_VNE_KANONA / KRIVAYA_NE_SOGLASNA /
PRUZHINA_ZAPRESHCHENA / UD_BEZ_STOLBCA / UD_NARUSHEN / END_MS_NE_RAVEN /
PORYADOK_NARUSHEN / KLJUCHEVYE_KADRY_NE_RAVNY / OKNO_NE_OT_NULJA /
FAJLY_ETALONOV_NE_POLNY / TREK_BEZ_POLJA;
Несвязанный --manifest/--kadry/--repo — SAMODELNAYA_SVERKA rc 1
с именем флага в подробности.
2 — SHABLON_NEVEREN (грамматика формы, нет файла, манифест кадров вне
грамматики 123, fiktura у судимой) / SVERKA_123_ABSENT (нет раннера 123 —
инфраструктура) / ISTOCHNIK_OTSVTSTVUET (нет источника движения в репо —
инфраструктура, fail-closed).
"""
import hashlib
import os
import json
import re
import subprocess
import sys
import time
from pathlib import Path

FORMA_KEYS = {'ekran', 'kadry', 'sostojanija', 'kljuchi_kopii', 'operacii_api',
              'katalog_kopii', 'spec_api', 'audit_tokenov', 'e2e_scenarij',
              'kadry_dir', 'kontrakt', 'batareja', 'priemka', 'zony',
              'zamenjaet', 'ne_trogaet', 'fiktura'}
FORMA_KEYS_V2 = FORMA_KEYS | {'shablon', 'prokhodimost', 'vtoroj_profil'}
# v3 (146): форма экрана с движением — v2 + dvizhenie (слово владельца
# 2026-10-28 mob-dvizhenie §Решение п.4 «после пилота»: раздел «движение»
# в шаблоне экранного контракта; пилот 145 — численная приёмка знака).
FORMA_KEYS_V3 = FORMA_KEYS_V2 | {'dvizhenie'}
# Грамматика блока dvizhenie — замкнутый состав (041); источник нормы
# ЕДИНожды — здесь и в докстринге выше, пополнение — только v+1 шаблона.
KLJUCHI_DVIZHENIE = {'manifest', 'manifest_sha256', 'spec', 'spec_sha256',
                     'pozvonok', 'pozvonok_sha256', 'ekrany', 'perehody',
                     'sceny_znaka', 'etalony', 'priemka_dvizhenija'}
RE_GA_EKRAN = re.compile(r'\AGA-[0-9]{2}\Z')
RE_GA_JAKOR = re.compile(r'\AGA-[0-9]{2}(?:[ ].*)?\Z')
RE_SHA256 = re.compile(r'\A[0-9a-f]{64}\Z')
# Темы эталонов дизайнера (Release-вложение пакета: 4 видео + 4×5
# ключевых кадров на переход; байты судят vision-судьи, валидатор —
# наличие/форму/число).
TEMY_ETF = ('dark', 'dark_reduced', 'light', 'light_reduced')
# Кривые движения: две UI-кривые дизайн-системы + linear для живого
# прогресса press-long (значение null); пружины запрещены (MOTION rules).
KRIVYE_KANON = ('ease-standard', 'ease-morph', 'linear')
# Свойства, которым при «Уменьшить движение» разрешена задержка до
# motion-fast; всё остальное (перемещение/размер/поворот/морф) — 0.
SVOJSTVA_VIZUALNYE = {'opacity', 'bg'}
# Обязательные поля трека спеки движения (значения судятся ниже).
POLJA_TREKA = {'order', 'element', 'property', 'delay', 'duration',
               'end_ms', 'curve', 'spring', 'reduced_duration_ms'}
# Норма правила проходимости (слово владельца 2026-10-27 ~22:45 UTC):
# цели касания ≥ 44pt. Закреплена в источнике нормы ЕДИНожды — здесь;
# в батарее и пачках числа геометрии приходят из манифеста экрана.
MIN_KASANIE_PT = 44
SOSTOJANIJA_PRESS = ('deistvie', 'neaktivna')
KLJUCHI_PRESS = {'id', 'sostojanie', 'izmenenie', 'kadry', 'shirina', 'vysota',
                 'x', 'y', 'demo', 'otdelenie'}
KLJUCHI_PRESS_OBJAZ = {'id', 'sostojanie', 'shirina', 'vysota', 'x', 'y', 'demo'}
# Норма класса второго профиля (слово владельца 2026-10-27 ~23:45 UTC):
# профиль iphone-safe-area — размер класса iPhone 15/16 (≥ 393×852),
# вырез/статус-бар сверху 47–59pt, home-indicator снизу 34pt. Закреплена
# в источнике нормы ЕДИНожды — здесь; значения пачки — данные манифеста,
# судятся против нормы (клетки 390×844 / vyrez 24 / home 0 доказывают
# суд, а не эхо).
PROFIL_IPHONE = {'imja': 'iphone-safe-area', 'shirina_min': 393,
                 'vysota_min': 852, 'vyrez_min': 47, 'vyrez_max': 59,
                 'home': 34}
TEMY = ('dark', 'light')
TIPY_ELEMENTOV = {'shapka', 'zagolovok', 'ikonka', 'kontrol', 'prochee'}
KLJUCHI_PROFIL = {'profil', 'shirina', 'vysota', 'vyrez', 'home',
                  'obolochka', 'marshrut', 'kadry', 'elementy'}
# Закрытый перечень ЗАМОРОЖЕННЫХ старых экранов — С-1 РЕШЕНИЯ АРБИТРА
# (verdicts/arbitration/contracts-132-v2-arbitraz.md, обход (а)): старость
# экрана — НЕ самодекларация id, у замороженного экрана есть независимая
# идентичность — пины maket_sha256 его замороженного манифеста. Отображение
# ekran → frozenset(maket_sha256) из замороженных манифестов батарей
# 135/138/116/118 (значения замерены по source.json сестёр: 7/8/7/14 пинов,
# пересечений между экранами 0; источник нормы ЕДИНожды — здесь, пополнение
# — только v+1 шаблона). Id контрактов 111/117 (first-run, vkhod-splash)
# замороженной пачки НЕ имеют — пинам взяться неоткуда, из перечня УБРАНЫ
# (два свободных псевдонима). Пачка без shablon судится по v1 только при
# подлинной идентичности: id ∈ отображению И непустые пины её манифеста ⊆
# пинам этого id (check_starost).
ZAMOROZHENNYE_STARYE_EKRANY = {
    'first-run-ekran': frozenset({
        '0411d0a370c2427de5abcb8caa43f2eb00b4eee0657d77c8f08dbbf52df66a94',
        '0c8ec9fb674ed89e285d576766991c384b6ed06ddc0008bffb0d307cab21c078',
        '306096157873ff877f7cddd437c7e1ea59df0b18ea2c1ec64bf7364668a225b6',
        '5777b005307913d41659daad7731158593a90e3d3c079905bde3267060a19298',
        '82cb91ef277ba2ee24907a0a440ae48005bbc7ccd2ea35058e33af15ec9564cc',
        'bb2c1929e2737a6ae072a325a122b23aebac89792e646dea73d7bb6cc21c4ca2',
        'd1a2e383082bbf834352ba183d983b18147a727939f82e156016ac4440d8d2de',
    }),
    'start-ekran': frozenset({
        '2b1e862267c8bc78c9f0923ba650293386a16eae0df2e397660462970013f564',
        '3cf68331fa11e242c5ecce4a55d291051f5582d0cfa20e5b569f68bec2734125',
        '43db524e38d3c5d306f1a74a4a0ab8d7754f80b60f1eacb5d0830ff2e2a77cab',
        '706d93cd6bbddec0955b3369353e25e832c5758a1fc040937b8a77a6889634bc',
        '8662dd00d31e22251a6fa67f7737db2dfca403023bbd12a206d2d741debd224f',
        '9242a4162aecfc1f22921c2d1d4a1582eb7345dcf47b1b2d6501f567471abad1',
        '98bdb89ff63446d12b26b09b420a83d95542be1ddcaaad0b5c9a695ba1eda22c',
        'c7f4ff1e3c07b1b7853a5e9b1cf149b9d8748883fe83db809f1494073bda1953',
    }),
    'mission': frozenset({
        '20f6ba52be8eb3a4745e6685e33ea5f6b1305bc1b8e7d976a384acee0ce432e0',
        '487acc835d8c7349c6813c89df134c2e2dd81f4860be7948b6ae2a7c34adaa42',
        '727ee59e681559440afc96cffacb266a27a89b945070145a965625b9a4063c9a',
        'b5a287e0370956fa5cbebf0f4f7025cb3bb9f0a97fba8f21a4cf155379021525',
        'eb4c4cf893b16347a9978c309c46e9b6025004147a8a98a99c2db185fa3d81db',
        'ed7627cc96590f33d40e48028bbfbc1b72aef26340a91bbe0451fc542cae8294',
        'fcf4d0aa0f160ba7ec5894c4c8fafb3104a9ba5e59b0d4d4e914a1e1889dd4b9',
    }),
    'erstinformation': frozenset({
        '1b5bb443347e8574c40e7b97823bdcd24ccc865f752cf7554809b3edc4bc639a',
        '2ea021a7da12d160f366c1537f269a91a4e6d040c7c02071b76fa4f42a2bc508',
        '2fc8eb9f50c32f92b87b87bf67c40ce3da8b3a3a547f84dbde0f3221d5e17c3a',
        '3388da91086fb6ee2aecac8882b3047507dc14ebdd2a62b7ecc2fd8818777674',
        '3828fa1263fee9e4c61197e4df6c194784de776da98a640fc11b15f749d32137',
        '6df227bba9a4eeb9f368dde8dcd51f635ecfe53c78c820e3fddbf3a2fb301215',
        '817b0fec50c1206dab384c1bc4de69397d47e3252ca742882916b0c5e9989c8b',
        '8b134427063f691968199652ea940d769dd65fe9fbb1a12d6829d92548e42baa',
        '9cb114c40f801929393a18164adf840cbbc39bc7334d60416ad3fd1a5065871d',
        'b3ed01e7786fce1978b3d2af60c6673106ced716c4307d5bb1f5186b2c4d3af1',
        'b99fe0aeec71ac1b60cc8ace502cc3594990ef13db529305624b5926b4c7a7eb',
        'e25286728be632f8ee2b0bb47d45872c2fc65646bc7193bf14c0e85712961977',
        'f52033ab4ea47cc73551f7c15b7d49ee28c5d8e523a1e1955e7d011fbd9a7e0b',
        'f5660a15e54371359a7ad8d426cee6fa91ac0d9f8b15df9ec828a243f86c45e8',
    }),
}
KLJUCHI_ELEM = {'id', 'tip', 'x', 'y', 'shirina', 'vysota', 'glif',
                'dostupnoe_imja'}
KLJUCHI_ELEM_OBJAZ = {'id', 'tip', 'x', 'y', 'shirina', 'vysota'}
RAZDELY = ['Воля владельца', 'Существующее', 'Инварианты',
           'Приёмочный критерий', 'Зоны и исполнители', 'ПРОВОДКА',
           'Модель угроз']
RE_EKRAN = re.compile(r'\A[a-z0-9][a-z0-9-]{0,63}\Z')
RE_SLOVO = re.compile(r'\A[a-z0-9-]+\Z')
RE_KLJUCH = re.compile(r'\A[A-Za-z0-9_.-]+\Z')
RE_PUT = re.compile(r'\A[A-Za-z0-9_./-]+\Z')
RE_PRIEMKA = re.compile(r'\A[A-Za-z0-9 ./_-]+\Z')
RE_ZONA_STROKA = re.compile(r'^ЗОНА (architect|implementer): (.+)$')
RE_CVET = re.compile(r'#[0-9a-fA-F]{3,8}\b'
                     r'|\b[a-zA-Z][a-zA-Z0-9-]*\([^()]*[0-9][^()]*\)')
RE_RAZMER = re.compile(r'\b[0-9]+(?:\.[0-9]+)?(?:%|[a-zA-Z]{1,4}\b)')
# Блокер 1 (adv-132): словоформа «цифры + буквенная единица 1–4 букв» —
# размерный литерал, НЕ дайджест, даже когда буквы единицы лежат в a–f
# (0000000000000001fa): негативный lookahead уводит маску с таких позиций.
RE_HEX_ZHIST = re.compile(
    r'(?<![0-9a-zA-Z])(?![0-9]+[a-fA-F]{1,4}(?![0-9a-zA-Z]))'
    r'(?=[0-9a-fA-F]{16,}(?![0-9a-zA-Z]))'
    r'(?=[0-9]*[a-fA-F])[0-9a-fA-F]{16,}')
MAX_STRANICA = 60
MAX_SHIRINA = 120
MAX_BAJT = 4000
RC2 = {'SHABLON_NEVEREN', 'SVERKA_123_ABSENT', 'ISTOCHNIK_OTSVTSTVUET'}
# отказ раннера 123 -> имя отказа шаблона (по грамматике вывода 123)
RUNNER_MAP = {'NIZHE_POROGA': 'KADR_NIZHE_POROGA',
              'KADR_OTSUTSTVUET': 'KADR_OTSUTSTVUET',
              'KADR_NEODNOZNACHEN': 'KADR_NEODNOZNACHEN',
              'KADR_NECHITAEM': 'KADR_NECHITAEM',
              'MAKET_PODMENEN': 'MAKET_PODMENEN',
              'MANIFEST_NEVEREN': 'SHABLON_NEVEREN',
              'PUSTAYA_SVERKA': 'SHABLON_NEVEREN'}


def path_ok(p):
    return (isinstance(p, str) and bool(p) and bool(RE_PUT.match(p))
            and not p.startswith('/') and '..' not in p.split('/'))


def otkaz(name, detail):
    return 'PRICHINA\t%s\t%s' % (name, detail)


def _spisok(f, pole, re_, pustoj=False):
    """Списковое поле: список, алфавит, без повторов."""
    v = f.get(pole)
    if not isinstance(v, list):
        return [otkaz('SHABLON_NEVEREN', pole)]
    if not v and not pustoj:
        return [otkaz('SHABLON_NEVEREN', pole)]
    if len(set(v)) != len(v):
        return [otkaz('SHABLON_NEVEREN', pole + ': повторы')]
    for x in v:
        if not isinstance(x, str) or not re_.match(x):
            return [otkaz('SHABLON_NEVEREN', '%s: %r' % (pole, x))]
    return []


def check_alfavit(f):
    """Грамматика формы: состав ключей, алфавиты, замкнутость (041).
    v1 — 17 полей (старый экран); v2 — 20 (shablon 2 + prokhodimost +
    vtoroj_profil); v3 — 21 (shablon 3 = v2 + dvizhenie, слово владельца
    2026-10-28 mob-dvizhenie §Решение п.4). Промежуточные составы
    v1+{shablon:2} и v1+{shablon:2, prokhodimost} принимаются грамматикой,
    чтобы отсутствие блока у НОВОГО экрана отказало ИМЕННОЙ причиной
    PROKHODIMOST_OTSVTSTVUET / VTOROJ_PROFIL_OTSVTSTVUET (правило 7
    AGENTS), а не глухим SHABLON_NEVEREN; состав shablon:3 БЕЗ dvizhenie
    принимается грамматикой по тем же спискам — отсутствие отказывает
    именованной причиной DVIZHENIE_OTSVTSTVUET (правило 7), а блок
    dvizhenie при shablon:2 — SHABLON_NEVEREN (замкнутость составов)."""
    if not isinstance(f, dict):
        return [otkaz('SHABLON_NEVEREN', 'forma не объект')]
    novyj = 'shablon' in f
    if novyj:
        if type(f['shablon']) is not int or f['shablon'] not in (2, 3):
            return [otkaz('SHABLON_NEVEREN', 'shablon')]
        if 'dvizhenie' in f:
            if f['shablon'] != 3 or set(f) != FORMA_KEYS_V3:
                return [otkaz('SHABLON_NEVEREN',
                              'состав ключей != шаблон: %s'
                              % sorted(set(f) ^ FORMA_KEYS_V3))]
        elif set(f) not in (FORMA_KEYS_V2,
                            FORMA_KEYS | {'shablon'},
                            FORMA_KEYS | {'shablon', 'prokhodimost'}):
            return [otkaz('SHABLON_NEVEREN',
                          'состав ключей != шаблон: %s'
                          % sorted(set(f) ^ FORMA_KEYS_V2))]
    elif set(f) != FORMA_KEYS:
        return [otkaz('SHABLON_NEVEREN',
                      'состав ключей != шаблон: %s' % sorted(set(f) ^ FORMA_KEYS))]
    bad = []
    if not isinstance(f['ekran'], str) or not RE_EKRAN.match(f['ekran']):
        bad.append(otkaz('SHABLON_NEVEREN', 'ekran'))
    fk = f['fiktura']
    if not isinstance(fk, bool):
        bad.append(otkaz('SHABLON_NEVEREN', 'fiktura'))
    elif fk:
        bad.append(otkaz('SHABLON_NEVEREN', 'fiktura: судимая пачка — не фикция'))
    bad += _spisok(f, 'sostojanija', RE_SLOVO)
    bad += _spisok(f, 'kljuchi_kopii', RE_KLJUCH)
    bad += _spisok(f, 'operacii_api', RE_KLJUCH, pustoj=True)
    for pole in ('kadry', 'katalog_kopii', 'spec_api', 'audit_tokenov',
                 'e2e_scenarij', 'kadry_dir', 'kontrakt'):
        if not path_ok(f[pole]):
            bad.append(otkaz('SHABLON_NEVEREN', pole))
    bat = f['batareja']
    if not isinstance(bat, list) or not bat:
        bad.append(otkaz('SHABLON_NEVEREN', 'batareja'))
    else:
        for x in bat:
            if not path_ok(x):
                bad.append(otkaz('SHABLON_NEVEREN', 'batareja: %r' % x))
                break
    pr = f['priemka']
    kljuchi_priemki = ({'e2e', 'sverka', 'prokhod'} if novyj
                       else {'e2e', 'sverka'})
    if (not isinstance(pr, dict) or set(pr) != kljuchi_priemki
            or not isinstance(pr.get('e2e'), str)
            or not RE_PRIEMKA.match(pr['e2e'])
            or not isinstance(pr.get('sverka'), str)
            or not RE_PRIEMKA.match(pr['sverka'])
            or (novyj and (not isinstance(pr.get('prokhod'), str)
                           or not RE_PRIEMKA.match(pr['prokhod'])))):
        bad.append(otkaz('SHABLON_NEVEREN', 'priemka'))
    z = f['zony']
    if not isinstance(z, dict) or set(z) != {'architect', 'implementer'}:
        bad.append(otkaz('SHABLON_NEVEREN', 'zony'))
    else:
        for imja in ('architect', 'implementer'):
            sp = z[imja]
            if not isinstance(sp, list) or not sp:
                bad.append(otkaz('SHABLON_NEVEREN', 'zony.' + imja))
                continue
            for x in sp:
                if not path_ok(x):
                    bad.append(otkaz('SHABLON_NEVEREN', 'zony.%s: %r' % (imja, x)))
                    break
    if not (f['zamenjaet'] is None or path_ok(f['zamenjaet'])):
        bad.append(otkaz('SHABLON_NEVEREN', 'zamenjaet'))
    nt = f['ne_trogaet']
    if not isinstance(nt, list):
        bad.append(otkaz('SHABLON_NEVEREN', 'ne_trogaet'))
    else:
        for x in nt:
            if not path_ok(x):
                bad.append(otkaz('SHABLON_NEVEREN', 'ne_trogaet: %r' % x))
                break
    return bad


def read_json(p: Path):
    return json.loads(p.read_text(encoding='utf-8'))


def load_kadry(path: Path):
    """Манифест кадров: структура грамматики 123 (значения судит раннер 123)."""
    try:
        m = read_json(path)
    except (OSError, ValueError):
        return None, [otkaz('SHABLON_NEVEREN', 'kadry не читается')]
    if not isinstance(m, dict) or not isinstance(m.get('kadry'), list) or not m['kadry']:
        return None, [otkaz('SHABLON_NEVEREN', 'kadry: не список кадров')]
    ids, snimki, piny = [], [], set()
    for e in m['kadry']:
        if not isinstance(e, dict) or not isinstance(e.get('id'), str):
            return None, [otkaz('SHABLON_NEVEREN', 'kadry: запись без id')]
        ids.append(e['id'])
        snimki.append(e.get('snimok'))
        # пины maket_sha256 — независимая идентичность замороженного
        # экрана (С-1 арбитража 132 v2: судятся check_starost)
        if isinstance(e.get('maket_sha256'), str):
            piny.add(e['maket_sha256'])
    if len(set(ids)) != len(ids):
        return None, [otkaz('SHABLON_NEVEREN', 'kadry: повторы id')]
    return {'ids': ids, 'snimki': snimki, 'piny': piny}, []


def check_fajly(f, pack: Path, repo: Path, harness: Path):
    bad = []
    if not (pack / f['kadry']).is_file():
        bad.append(otkaz('SHABLON_NEVEREN', 'нет файла: ' + f['kadry']))
    vp = f.get('vtoroj_profil')
    if isinstance(vp, dict) and isinstance(vp.get('kadry'), str) \
            and not (pack / vp['kadry']).is_file():
        bad.append(otkaz('SHABLON_NEVEREN', 'нет файла: ' + vp['kadry']))
    if isinstance(vp, dict) and isinstance(vp.get('marshrut'), str) \
            and not (repo / vp['marshrut']).is_file():
        bad.append(otkaz('SHABLON_NEVEREN', 'нет файла: ' + vp['marshrut']))
    if not (pack / f['kontrakt']).is_file():
        bad.append(otkaz('SHABLON_NEVEREN', 'нет файла: ' + f['kontrakt']))
    for x in f['batareja']:
        if not (pack / x).is_file():
            bad.append(otkaz('SHABLON_NEVEREN', 'нет файла: ' + x))
            break
    for pole in ('katalog_kopii', 'spec_api', 'audit_tokenov', 'e2e_scenarij'):
        if not (repo / f[pole]).is_file():
            bad.append(otkaz('SHABLON_NEVEREN', 'нет файла: ' + f[pole]))
    if not (repo / f['kadry_dir']).is_dir():
        bad.append(otkaz('SHABLON_NEVEREN', 'нет каталога: ' + f['kadry_dir']))
    if f['zamenjaet'] is not None and not any(
            (r / f['zamenjaet']).is_file() for r in (harness, repo)):
        bad.append(otkaz('SHABLON_NEVEREN', 'нет файла: ' + f['zamenjaet']))
    for x in f['ne_trogaet']:
        if not any((r / x).is_file() for r in (harness, repo)):
            bad.append(otkaz('SHABLON_NEVEREN', 'нет файла: ' + x))
            break
    return bad


def check_razdely(tekst: str):
    bad = []
    for r in RAZDELY:
        s = '## ' + r
        if not any(line.rstrip('\r') == s for line in tekst.splitlines()):
            bad.append(otkaz('RAZDEL_OTSVTSTVUET', r))
    return bad


def check_objem(tekst: str):
    """Воля владельца «контракт экрана на одну страницу» — ТРИ меры:
    строки (переводы), ширина (сворачивание строк), байты (объём текста);
    обход круга 2: 47 строк / 261138 байт одной строкой."""
    stroki = tekst.splitlines()
    bad = []
    if len(stroki) > MAX_STRANICA:
        bad.append(otkaz('NE_ODNA_STRANICA',
                         'строк: %d (норма ≤ %d)' % (len(stroki), MAX_STRANICA)))
    shirina = max((len(s) for s in stroki), default=0)
    if shirina > MAX_SHIRINA:
        bad.append(otkaz('NE_ODNA_STRANICA',
                         'ширина: %d (норма ≤ %d)' % (shirina, MAX_SHIRINA)))
    bajt = len(tekst.encode('utf-8'))
    if bajt > MAX_BAJT:
        bad.append(otkaz('NE_ODNA_STRANICA',
                         'байт: %d (норма ≤ %d)' % (bajt, MAX_BAJT)))
    return bad


def check_zony_stroki(tekst: str, f):
    """ЗОНА-строки контракта = zony формы (множества, грамматика check_zones)."""
    bad, najdeno = [], {'architect': set(), 'implementer': set()}
    for line in tekst.splitlines():
        m = RE_ZONA_STROKA.match(line.rstrip('\r'))
        if m:
            for p in m.group(2).split():
                najdeno[m.group(1)].add(p)
    for imja in ('architect', 'implementer'):
        if najdeno[imja] != set(f['zony'][imja]):
            bad.append(otkaz('ZONY_RASHODJATSJA', imja))
    return bad


def check_literal(pack: Path):
    """Литералы цветов/размеров запрещены во всей пачке (аудит — в репо):
    судятся КЛАССОМ по ВСЕМУ ТЕКСТУ файла — перенос строки внутри функции
    литерал не прячет (арбитраж 132 А1); маска дайджеста — обособленное
    hex-слово 16+ с хотя бы одной буквой a-f, НЕ стирает ни число с
    единицей/% (А2), ни аргумент-число из цифр (А3) — в том числе единицу
    из букв a-f (блокер 1 adv-132: маска не встаёт на словоформу «цифры +
    единица 1–4 букв»); файл:строка — строка НАЧАЛА совпадения."""
    bad = []
    for p in sorted(pack.rglob('*')):
        if not p.is_file():
            continue
        try:
            tekst = p.read_text(encoding='utf-8')
        except (OSError, UnicodeDecodeError):
            continue  # бинарный носитель
        zaslon = RE_HEX_ZHIST.sub(lambda mm: ' ' * len(mm.group(0)), tekst)
        m = RE_CVET.search(zaslon) or RE_RAZMER.search(zaslon)
        if m:
            i = zaslon.count('\n', 0, m.start()) + 1
            bad.append(otkaz('LITERAL_VNE_AUDITA',
                             '%s:%d' % (p.relative_to(pack), i)))
    return bad


def _operacii_json(obj, akk):
    """operationId собираются рекурсивно по всей спецификации."""
    if isinstance(obj, dict):
        for k, v in obj.items():
            if k == 'operationId' and isinstance(v, str):
                akk.add(v)
            _operacii_json(v, akk)
    elif isinstance(obj, list):
        for v in obj:
            _operacii_json(v, akk)


def check_kljuchi(f, repo: Path):
    try:
        kat = read_json(repo / f['katalog_kopii'])
    except (OSError, ValueError):
        return [otkaz('SHABLON_NEVEREN', 'katalog_kopii не читается')]
    if not isinstance(kat, dict):
        return [otkaz('SHABLON_NEVEREN', 'katalog_kopii не объект')]
    akk = set(kat)  # ключи каталога копии — верхний уровень (как D2.2.5.1)
    return [otkaz('KLJUCH_BEZ_KATALOGA', k) for k in f['kljuchi_kopii']
            if k not in akk]


def check_operacii(f, repo: Path):
    try:
        sp = read_json(repo / f['spec_api'])
    except (OSError, ValueError):
        return [otkaz('SHABLON_NEVEREN', 'spec_api не читается')]
    akk = set()
    _operacii_json(sp, akk)
    return [otkaz('OPERACIJA_BEZ_SPEKA', o) for o in f['operacii_api']
            if o not in akk]


def check_scenarij(f, repo: Path, kadry):
    try:
        stroki = (repo / f['e2e_scenarij']).read_text(
            encoding='utf-8').splitlines()
    except OSError:
        return [otkaz('SHABLON_NEVEREN', 'e2e_scenarij не читается')]
    bad = []
    for s in kadry['snimki']:
        if not isinstance(s, str) or not any(s in line for line in stroki):
            bad.append(otkaz('SCENARIJ_BEZ_SNIMKA', str(s)))
    return bad


def razbit_argv(cmd):
    """Алфавит priemka без кавычек/;|&$() — пробел единственный разделитель;
    исполнение — фактический argv без shell (прецедент Г3-002)."""
    return cmd.split(' ')


def check_priemka(f):
    sv = razbit_argv(f['priemka']['sverka'])
    if '--manifest' not in sv:
        return [otkaz('SAMODELNAYA_SVERKA',
                      'команда сверки не запускает механизм 123')]
    return []


def _nahodi_manifest(harness: Path, repo: Path, rel):
    """Манифест по объявленному пути судится в КАЖДОМ корне, где файл по
    этому пути существует (арбитраж 132 Б: один и тот же путь в двух
    корнях — одна запись обнаружения, но суд — по каждому файлу);
    нет нигде/не-манифест в любом корне — None."""
    najdennye = []
    for root in (harness, repo):
        p = root / rel
        if not p.is_file():
            continue
        try:
            m = read_json(p)
        except (OSError, ValueError):
            return None
        if not isinstance(m, dict) or not isinstance(m.get('kadry'), list):
            return None
        najdennye.append([e.get('id') for e in m['kadry'] if isinstance(e, dict)])
    return najdennye or None


def check_tselikom(f, harness: Path, repo: Path, kadry):
    if f['zamenjaet'] is None:
        return []
    najdennye = _nahodi_manifest(harness, repo, f['zamenjaet'])
    if najdennye is None:
        return [otkaz('SHABLON_NEVEREN', 'zamenjaet: не манифест кадров')]
    return [otkaz('NE_TSELIKOM', i)
            for starye in najdennye for i in starye if i not in kadry['ids']]


def check_chuzhie(f, harness: Path, repo: Path, kadry):
    bad = []
    for rel in f['ne_trogaet']:
        najdennye = _nahodi_manifest(harness, repo, rel)
        if najdennye is None:
            bad.append(otkaz('SHABLON_NEVEREN', 'ne_trogaet: не манифест'))
            continue
        for chuzhie in najdennye:
            for i in chuzhie:
                if i in kadry['ids']:
                    bad.append(otkaz('CHUZHIE_KADRY', i))
    return bad


def _zhivye_v_korne(root: Path, pack: Path):
    """Живые пачки одного корня: ekran.json под fixtures/workshop_project/**
    с ekran/kadry и fiktura != true; судимая исключает себя (resolved)."""
    vne = []
    base = root / 'fixtures' / 'workshop_project'
    if not base.is_dir():
        return vne
    sobstvennyj = (pack / 'ekran.json').resolve()
    for p in sorted(base.rglob('ekran.json')):
        try:
            q = read_json(p)
        except (OSError, ValueError):
            continue
        if not isinstance(q, dict) or q.get('fiktura') is True:
            continue
        e, k = q.get('ekran'), q.get('kadry')
        if (not isinstance(e, str) or not RE_EKRAN.match(e)
                or not path_ok(k)):
            continue
        if p.resolve() == sobstvennyj:
            continue
        vne.append((e, p.parent.relative_to(root).joinpath(k).as_posix()))
    return vne


def zhivye_pachty(harness: Path, repo: Path, pack: Path):
    """Живые пачки В ОБОИХ корнях — харнессе И переданном репо продукта
    (обход круга 2: пачка в --repo невидима харнесс-скану); один и тот же
    относительный путь в двух корнях — одна запись обнаружения, но суд
    манифеста — по каждому файлу в каждом корне, где он есть (_nahodi_manifest,
    арбитраж 132 Б)."""
    vidno = {}
    for root in (harness, repo):
        for para in _zhivye_v_korne(root, pack):
            vidno[para] = None
    return sorted(vidno)


def check_polnota(f, harness: Path, repo: Path, pack: Path):
    """Полнота объявлений против ОБНАРУЖЕННЫХ живых пачек ОБЕИХ корней
    (мера против пустых zamenjaet/ne_trogaet): перечисление экранов —
    не самодекларация."""
    bad = []
    for ekran_q, kadry_q in zhivye_pachty(harness, repo, pack):
        if ekran_q == f['ekran']:
            if f['zamenjaet'] != kadry_q:
                bad.append(otkaz('ZAMENJAET_NE_POLON', kadry_q))
        elif kadry_q not in f['ne_trogaet']:
            bad.append(otkaz('NE_TROGAET_NE_POLON', kadry_q))
    return bad


def check_starost(f, piny):
    """СТАРОСТЬ экрана — подлинная идентичность замороженного экрана,
    не самодекларация id (блокер 1 вердикта критика 1/2; С-1 РЕШЕНИЯ
    АРБИТРА verdicts/arbitration/contracts-132-v2-arbitraz.md, обход (а)):
    право не нести блоки v2 есть ТОЛЬКО у экранов, замороженных ДО правила,
    ИДЕНТИЧНОСТЬ которых доказуема независимо — пины maket_sha256
    замороженного манифеста (ZAMOROZHENNYE_STARYE_EKRANY — отображение
    ekran → frozenset пинов, источник нормы единожды). Пачка без shablon
    судится по v1 только если ekran ∈ отображению И непустое множество
    пинов ЕЁ манифеста ⊆ пинам этого id; иначе SHABLON_OTSVTSTVUET
    (подробность называет id и чужие пины). Судится НА ПУТИ К ЗЕЛЕНИ
    (последняя дешёвая, перед исполнением приёмки): пачка с иным отказом
    уже красна — ЗЕЛЕНИ без маркера и без подлинной идентичности не
    существует; отказ появляется ровно там, где пачка иначе прошла бы
    (правило 7 AGENTS: место и выход названы)."""
    if 'shablon' in f:
        return []
    zamorozhennye = ZAMOROZHENNYE_STARYE_EKRANY.get(f['ekran'])
    if zamorozhennye is not None and piny and piny <= zamorozhennye:
        return []
    if zamorozhennye is None:
        return [otkaz(
            'SHABLON_OTSVTSTVUET',
            'ekran %s вне перечня замороженных старых экранов (%s): новый '
            'экран обязан нести shablon: 2 с блоками prokhodimost и '
            'vtoroj_profil (слово владельца 2026-10-27)'
            % (f['ekran'], ', '.join(sorted(ZAMOROZHENNYE_STARYE_EKRANY))))]
    chuzhie = sorted(piny - zamorozhennye)
    if chuzhie:
        return [otkaz(
            'SHABLON_OTSVTSTVUET',
            'ekran %s: пины макетов %s не из замороженного манифеста этого '
            'экрана — исторический id с чужими макетами: идентичность '
            'замороженного экрана не доказана, новый экран обязан нести '
            'shablon: 2 с блоками prokhodimost и vtoroj_profil (слово '
            'владельца 2026-10-27)' % (f['ekran'], ', '.join(chuzhie)))]
    return [otkaz(
        'SHABLON_OTSVTSTVUET',
        'ekran %s: манифест пачки без пинов maket_sha256 — идентичность '
        'замороженного экрана (id + пины макетов замороженного манифеста) '
        'не доказана (слово владельца 2026-10-27)' % f['ekran'])]


def _press_zapis(x, spisok_imja):
    """Грамматика записи pressable/demo: замкнутый состав ключей, алфавиты,
    целые координаты ≥ 0 (041)."""
    if not isinstance(x, dict):
        return [otkaz('SHABLON_NEVEREN', '%s: запись не объект' % spisok_imja)]
    if not KLJUCHI_PRESS_OBJAZ <= set(x) <= KLJUCHI_PRESS:
        return [otkaz('SHABLON_NEVEREN',
                      '%s: состав ключей записи: %s'
                      % (spisok_imja, sorted(set(x) ^ KLJUCHI_PRESS)))]
    if not isinstance(x['id'], str) or not RE_EKRAN.match(x['id']):
        return [otkaz('SHABLON_NEVEREN', '%s: id %r' % (spisok_imja, x['id']))]
    if x['sostojanie'] not in SOSTOJANIJA_PRESS:
        return [otkaz('SHABLON_NEVEREN',
                      '%s: sostojanie %r' % (spisok_imja, x['sostojanie']))]
    for pole in ('shirina', 'vysota', 'x', 'y'):
        if type(x[pole]) is not int or x[pole] < 0:
            return [otkaz('SHABLON_NEVEREN',
                          '%s: %s %r' % (spisok_imja, pole, x[pole]))]
    if not isinstance(x['demo'], bool):
        return [otkaz('SHABLON_NEVEREN', '%s: demo %r' % (spisok_imja, x['demo']))]
    if 'izmenenie' in x and (not isinstance(x['izmenenie'], str)
                             or not RE_KLJUCH.match(x['izmenenie'])):
        return [otkaz('SHABLON_NEVEREN',
                      '%s: izmenenie %r' % (spisok_imja, x['izmenenie']))]
    if 'otdelenie' in x and (not isinstance(x['otdelenie'], str)
                             or not RE_KLJUCH.match(x['otdelenie'])):
        return [otkaz('SHABLON_NEVEREN',
                      '%s: otdelenie %r' % (spisok_imja, x['otdelenie']))]
    if 'kadry' in x and (not isinstance(x['kadry'], list) or not x['kadry']
                         or not all(isinstance(k, str) for k in x['kadry'])):
        return [otkaz('SHABLON_NEVEREN',
                      '%s: kadry %r' % (spisok_imja, x['kadry']))]
    return []


def check_prokhodimost(f, kadry):
    """Правило проходимости (слово владельца 2026-10-27 ~22:45 UTC, к
    правилу В для КАЖДОГО нового mob-экрана), статическая ветвь (г):
    манифест → вердикт rc. (а) каждый видимый pressable либо действует
    (izmenenie названо), либо явно неактивен (kadry-ссылка на disabled-вид);
    (б) цели ≥ MIN_KASANIE_PT и вне safe-area; (в) демо-переключатели
    помечены demo:true, заявляют otdelenie и живут ОТДЕЛЬНЫМ списком demo —
    не в составе продукта. Отказ — именованный, с местом (правило 7)."""
    if 'prokhodimost' not in f:
        return [otkaz('PROKHODIMOST_OTSVTSTVUET',
                      'поле prokhodimost: новый экран (shablon 2) обязан '
                      'нести блок проходимости (слово владельца '
                      '2026-10-27 ~22:45 UTC)')]
    p = f['prokhodimost']
    if not isinstance(p, dict) or set(p) != {'pressable', 'demo', 'safe'}:
        return [otkaz('SHABLON_NEVEREN', 'prokhodimost')]
    if not isinstance(p['pressable'], list) or not p['pressable']:
        return [otkaz('SHABLON_NEVEREN', 'prokhodimost.pressable')]
    if not isinstance(p['demo'], list):
        return [otkaz('SHABLON_NEVEREN', 'prokhodimost.demo')]
    sf = p['safe']
    if (not isinstance(sf, dict) or set(sf) != {'verh', 'niz', 'vysota'}
            or any(type(sf[k]) is not int or sf[k] < 0
                   for k in ('verh', 'niz', 'vysota'))
            or sf['vysota'] <= sf['verh'] + sf['niz']):
        return [otkaz('SHABLON_NEVEREN', 'prokhodimost.safe')]
    gram = []
    for spisok in ('pressable', 'demo'):
        for x in p[spisok]:
            gram += _press_zapis(x, 'prokhodimost.' + spisok)
    if gram:
        return gram
    ids = [x['id'] for spisok in ('pressable', 'demo') for x in p[spisok]]
    if len(set(ids)) != len(ids):
        return [otkaz('SHABLON_NEVEREN', 'prokhodimost: повторы id')]
    bad = []
    for x in p['pressable'] + p['demo']:
        if x['sostojanie'] == 'deistvie' and 'izmenenie' not in x:
            bad.append(otkaz('PRESSABLE_BEZ_IZMENENIJA', x['id']))
        if x['sostojanie'] == 'neaktivna' and (
                'kadry' not in x
                or any(k not in kadry['ids'] for k in x['kadry'])):
            bad.append(otkaz('NEAKTIVNA_BEZ_KADRA', x['id']))
    for x in p['pressable'] + p['demo']:
        for pole in ('shirina', 'vysota'):
            if x[pole] < MIN_KASANIE_PT:
                bad.append(otkaz('KASANIE_MENSHE_NORMY',
                                 '%s: %s %d < %d'
                                 % (x['id'], pole, x[pole], MIN_KASANIE_PT)))
        if x['y'] < sf['verh'] or x['y'] + x['vysota'] > sf['vysota'] - sf['niz']:
            bad.append(otkaz('KASANIE_V_SAFE_ZONE', x['id']))
    for x in p['demo']:
        if x['demo'] is not True:
            bad.append(otkaz('DEMO_NE_OTMECHEN', x['id']))
        elif 'otdelenie' not in x or not x['otdelenie']:
            bad.append(otkaz('DEMO_BEZ_OTDELENIJA', x['id']))
    for x in p['pressable']:
        if x['demo'] is not False:
            bad.append(otkaz('DEMO_V_SOSTAVE', x['id']))
    return bad

def _element_zapis(x):
    """Грамматика записи элемента собранного экрана (bbox из UI-дерева,
    041): замкнутый состав ключей, tip из замкнутого перечня, целые
    координаты ≥ 0; glif/dostupnoe_imja — [a-z0-9-]+ если есть."""
    if not isinstance(x, dict):
        return otkaz('SHABLON_NEVEREN', 'vtoroj_profil.elementy: запись не объект')
    if not KLJUCHI_ELEM_OBJAZ <= set(x) <= KLJUCHI_ELEM:
        return otkaz('SHABLON_NEVEREN',
                     'vtoroj_profil.elementy: состав ключей записи: %s'
                     % sorted(set(x) ^ KLJUCHI_ELEM))
    if not isinstance(x['id'], str) or not RE_EKRAN.match(x['id']):
        return otkaz('SHABLON_NEVEREN', 'vtoroj_profil.elementy: id %r' % x['id'])
    if x['tip'] not in TIPY_ELEMENTOV:
        return otkaz('SHABLON_NEVEREN',
                     'vtoroj_profil.elementy: tip %r' % x['tip'])
    for pole in ('x', 'y', 'shirina', 'vysota'):
        if type(x[pole]) is not int or x[pole] < 0:
            return otkaz('SHABLON_NEVEREN',
                         'vtoroj_profil.elementy: %s %r' % (pole, x[pole]))
    for pole in ('glif', 'dostupnoe_imja'):
        if pole in x and (not isinstance(x[pole], str)
                          or not RE_SLOVO.match(x[pole])):
            return otkaz('SHABLON_NEVEREN',
                         'vtoroj_profil.elementy: %s %r' % (pole, x[pole]))
    return None


def check_vtoroj_profil(f, pack: Path):
    """Второй профиль НОВОГО экрана (слово владельца 2026-10-27 ~23:45
    UTC, та же v+1): сверка ЦЕЛОГО экрана в СОБРАННОМ пути с safe-area
    как у iPhone — статическая ветвь. Норма класса — PROFIL_IPHONE
    (единый источник): ≥ 393×852, вырез 47–59pt, home-indicator 34pt;
    значения пачки — данные манифеста, судятся против нормы. Оболочка
    собранного пути заявлена (пустая — голый компонент, сверкой не
    принимается); манифест профиля покрывает ОБЕ темы; наложения слоёв,
    залезания под инсеты и пустые иконки судятся геометрией bbox из
    UI-дерева. Отказ — именованный, с местом (правило 7 AGENTS)."""
    if 'vtoroj_profil' not in f:
        return [otkaz('VTOROJ_PROFIL_OTSVTSTVUET',
                      'поле vtoroj_profil: новый экран (shablon 2) обязан '
                      'нести блок второго профиля с safe-area (слово '
                      'владельца 2026-10-27 ~23:45 UTC)')]
    vp = f['vtoroj_profil']
    if not isinstance(vp, dict) or set(vp) != KLJUCHI_PROFIL:
        return [otkaz('SHABLON_NEVEREN', 'vtoroj_profil')]
    if vp['profil'] != PROFIL_IPHONE['imja']:
        return [otkaz('SHABLON_NEVEREN', 'vtoroj_profil.profil: %r' % vp['profil'])]
    for pole in ('shirina', 'vysota', 'vyrez', 'home'):
        if type(vp[pole]) is not int or vp[pole] < 0:
            return [otkaz('SHABLON_NEVEREN',
                          'vtoroj_profil.%s: %r' % (pole, vp[pole]))]
    if not isinstance(vp['obolochka'], str) or (
            vp['obolochka'] and not RE_SLOVO.match(vp['obolochka'])):
        return [otkaz('SHABLON_NEVEREN',
                      'vtoroj_profil.obolochka: %r' % vp['obolochka'])]
    if not path_ok(vp['marshrut']):
        return [otkaz('SHABLON_NEVEREN', 'vtoroj_profil.marshrut')]
    if not path_ok(vp['kadry']):
        return [otkaz('SHABLON_NEVEREN', 'vtoroj_profil.kadry')]
    if not isinstance(vp['elementy'], list) or not vp['elementy']:
        return [otkaz('SHABLON_NEVEREN', 'vtoroj_profil.elementy')]
    gram = [_element_zapis(x) for x in vp['elementy']]
    if any(gram):
        return [g for g in gram if g]
    ids = [x['id'] for x in vp['elementy']]
    if len(set(ids)) != len(ids):
        return [otkaz('SHABLON_NEVEREN', 'vtoroj_profil.elementy: повторы id')]
    try:
        m = read_json(pack / vp['kadry'])
    except (OSError, ValueError):
        return [otkaz('SHABLON_NEVEREN', 'vtoroj_profil.kadry не читается')]
    if not isinstance(m, dict) or not isinstance(m.get('kadry'), list) \
            or not m['kadry']:
        return [otkaz('SHABLON_NEVEREN', 'vtoroj_profil.kadry: не список кадров')]
    bad = []
    temy = {e.get('tema') for e in m['kadry'] if isinstance(e, dict)}
    net_tem = [t for t in TEMY if t not in temy]
    if net_tem:
        bad.append(otkaz('ODNA_TEMA',
                         'кадры профиля без тем: %s' % ', '.join(net_tem)))
    norm = PROFIL_IPHONE
    if vp['shirina'] < norm['shirina_min'] or vp['vysota'] < norm['vysota_min']:
        bad.append(otkaz('PROFIL_NIZHE_MINIMUMA',
                         '%d×%d < %d×%d (класс iPhone 15/16)'
                         % (vp['shirina'], vp['vysota'],
                            norm['shirina_min'], norm['vysota_min'])))
    if not norm['vyrez_min'] <= vp['vyrez'] <= norm['vyrez_max']:
        bad.append(otkaz('PROFIL_BEZ_INSETOV',
                         'vyrez %d вне %d–%d'
                         % (vp['vyrez'], norm['vyrez_min'], norm['vyrez_max'])))
    if vp['home'] != norm['home']:
        bad.append(otkaz('PROFIL_BEZ_INSETOV',
                         'home %d != %d' % (vp['home'], norm['home'])))
    if not vp['obolochka']:
        bad.append(otkaz('GOLYJ_KOMPONENT',
                         'vtoroj_profil.obolochka: сверка голым компонентом '
                         'по маршруту без оболочки не принимается'))
    elem = vp['elementy']
    for i in range(len(elem)):
        for j in range(i + 1, len(elem)):
            a, b = elem[i], elem[j]
            if (a['x'] < b['x'] + b['shirina'] and b['x'] < a['x'] + a['shirina']
                    and a['y'] < b['y'] + b['vysota']
                    and b['y'] < a['y'] + a['vysota']):
                bad.append(otkaz('NALOZHENIE_SLOEV', '%s+%s' % (a['id'], b['id'])))
    for x in elem:
        if x['y'] < vp['vyrez']:
            bad.append(otkaz('ZALEZAET_POD_INSET', '%s: verh' % x['id']))
        if x['y'] + x['vysota'] > vp['vysota'] - vp['home']:
            bad.append(otkaz('ZALEZAET_POD_INSET', '%s: niz' % x['id']))
        if x['tip'] == 'ikonka' and 'glif' not in x and 'dostupnoe_imja' not in x:
            bad.append(otkaz('PUSTAJA_IKONKA',
                             '%s: нет ни глифа, ни доступного имени' % x['id']))
    return bad



def _sha256_bajtov(p: Path):
    return hashlib.sha256(p.read_bytes()).hexdigest()


RE_PEREHOD = re.compile(r'\AGA-[A-Za-z0-9]+(?:-[A-Za-z0-9]+)*\Z')


def _spisok_dv(dv, pole, re_, pustoj=False):
    """Списковое поле блока dvizhenie: список, алфавит, без повторов."""
    zn = dv.get(pole)
    if not isinstance(zn, list):
        return [otkaz('SHABLON_NEVEREN', 'dvizhenie.' + pole)], zn or []
    if not zn and not pustoj:
        return [otkaz('SHABLON_NEVEREN', 'dvizhenie.' + pole + ': пусто')], zn
    for x in zn:
        if not isinstance(x, str) or not re_.match(x):
            return ([otkaz('SHABLON_NEVEREN',
                           'dvizhenie.%s: %r' % (pole, x))], zn)
    if len(set(zn)) != len(zn):
        return [otkaz('SHABLON_NEVEREN',
                      'dvizhenie.%s: повторы' % pole)], zn
    return [], zn


def zagnost_dvizhenija(f):
    """Форма блока dvizhenie: замкнутый состав ключей, алфавиты путей/пинов
    (041). Возвращает (otkazy, dv)."""
    dv = f.get('dvizhenie')
    if not isinstance(dv, dict) or set(dv) != KLJUCHI_DVIZHENIE:
        return ([otkaz('SHABLON_NEVEREN',
                       'состав ключей != dvizhenie: %s'
                       % sorted(set(dv if isinstance(dv, dict) else {})
                                ^ KLJUCHI_DVIZHENIE))], None)
    bad = []
    for pole in ('manifest', 'spec', 'pozvonok'):
        if not path_ok(dv[pole]):
            bad.append(otkaz('SHABLON_NEVEREN', 'dvizhenie.' + pole))
    for pole in ('manifest_sha256', 'spec_sha256', 'pozvonok_sha256'):
        if not isinstance(dv[pole], str) or not RE_SHA256.match(dv[pole]):
            bad.append(otkaz('SHABLON_NEVEREN', 'dvizhenie.' + pole))
    if not isinstance(dv['priemka_dvizhenija'], str) \
            or not RE_PRIEMKA.match(dv['priemka_dvizhenija']):
        bad.append(otkaz('SHABLON_NEVEREN', 'dvizhenie.priemka_dvizhenija'))
    if not isinstance(dv['etalony'], dict):
        bad.append(otkaz('SHABLON_NEVEREN', 'dvizhenie.etalony'))
    return bad, dv


def zagnost_istochniki(dv, repo: Path):
    """Источники движения: файл в репо, пин sha256 байтов, разбор JSON,
    грамматика списков. Возвращает (otkazy, {'manifest'|'spec'|'pozvonok'}).
    Нет файла — ISTOCHNIK_OTSVTSTVUET rc 2 (инфраструктура, fail-closed);
    пин не совпал — ISTOCHNIK_NE_SOVPADAET rc 1 (пачка лжёт об источнике)."""
    isto, bad = {}, []
    for imja in ('manifest', 'spec', 'pozvonok'):
        p = repo / dv[imja]
        if not p.is_file():
            return [otkaz('ISTOCHNIK_OTSVTSTVUET', dv[imja])], None
        if _sha256_bajtov(p) != dv[imja + '_sha256']:
            bad.append(otkaz('ISTOCHNIK_NE_SOVPADAET', imja))
            continue
        try:
            isto[imja] = json.loads(p.read_text(encoding='utf-8'))
        except ValueError:
            bad.append(otkaz('ISTOCHNIK_OTSVTSTVUET', imja + ' не JSON'))
    if bad or len(isto) != 3:
        return bad, None
    man, spc, poz = isto['manifest'], isto['spec'], isto['pozvonok']
    if (not isinstance(man, dict)
            or not isinstance(man.get('screens'), list)
            or not all(isinstance(x, str) for x in man['screens'])
            or not isinstance(man.get('motion'), list)
            or not all(isinstance(x, dict)
                       and isinstance(x.get('id'), str)
                       and isinstance(x.get('frames'), list)
                       and all(isinstance(y, str) for y in x['frames'])
                       for x in man['motion'])):
        return ([otkaz('ISTOCHNIK_OTSVTSTVUET', 'manifest не по грамматике')],
                None)
    if (not isinstance(spc, dict)
            or not isinstance(spc.get('tokens'), list)
            or not all(isinstance(t, dict)
                       and isinstance(t.get('name'), str)
                       and isinstance(t.get('value'), str)
                       for t in spc['tokens'])
            or not isinstance(spc.get('scenes'), list)
            or not all(isinstance(s, dict) and isinstance(s.get('id'), str)
                       for s in spc['scenes'])):
        return ([otkaz('ISTOCHNIK_OTSVTSTVUET', 'spec не по грамматике')],
                None)
    if not isinstance(poz, dict) or not isinstance(poz.get('scenes'), dict):
        return ([otkaz('ISTOCHNIK_OTSVTSTVUET', 'pozvonok не по грамматике')],
                None)
    return [], isto


def _tokeny(spc):
    """Токены спеки: имя -> (значение-строка, мс или None)."""
    tk = {}
    for t in spc['tokens']:
        ms = None
        m = re.match(r'\A([0-9]+(?:\.[0-9]+)?)ms\Z', t['value'])
        if m:
            ms = float(m.group(1))
        tk[t['name']] = (t['value'], ms)
    return tk


def _znach_vyrazhenija(tekst, tk):
    """Значение закрытой грамматики задержки: число | имя токена |
    n*token | a + b - c над числами и токенами (мс). None — вне
    грамматики либо токен без мс-значения (кривая как задержка — отказ)."""
    if not isinstance(tekst, str) or not tekst:
        return None
    znach, znak, ozhidaem_term = 0.0, 1.0, True
    for ch in tekst.split(' '):
        if ch in ('+', '-'):
            if ozhidaem_term:
                return None
            znak = 1.0 if ch == '+' else -1.0
            ozhidaem_term = True
            continue
        if not ozhidaem_term:
            return None
        v = None
        m = re.match(r'\A([0-9]+(?:\.[0-9]+)?)(?:\*([a-z][a-z0-9-]*))?\Z',
                     ch)
        if m:
            v = float(m.group(1))
            if m.group(2):
                if m.group(2) not in tk or tk[m.group(2)][1] is None:
                    return None
                v = v * tk[m.group(2)][1]
        elif ch in tk:
            if tk[ch][1] is None:
                return None
            v = tk[ch][1]
        if v is None:
            return None
        znach += znak * v
        ozhidaem_term = False
    return None if ozhidaem_term else znach


def _proverka_dlitel(dur, tk, gde, bad):
    """Длительность трека: имя токена (или «0») И ms == значению токена;
    сырое число — DLITELNOST_BEZ_TOKENA (токены — единый источник)."""
    if not (isinstance(dur, dict) and isinstance(dur.get('token'), str)
            and isinstance(dur.get('ms'), (int, float))
            and not isinstance(dur.get('ms'), bool)):
        bad.append(otkaz('TREK_BEZ_POLJA', gde + ': duration'))
        return False
    if dur['token'] == '0':
        if float(dur['ms']) == 0.0:
            return True
        bad.append(otkaz('ZNACHENIE_NE_TOKENA', gde + ': 0'))
        return False
    if dur['token'] not in tk or tk[dur['token']][1] is None:
        bad.append(otkaz('DLITELNOST_BEZ_TOKENA',
                         '%s: %s' % (gde, dur['token'])))
    elif abs(tk[dur['token']][1] - float(dur['ms'])) > 1e-9:
        bad.append(otkaz('ZNACHENIE_NE_TOKENA',
                         '%s: %s' % (gde, dur['token'])))
    else:
        return True
    return False


def _proverka_zaderzh(z, tk, gde, bad):
    """Задержка: закрытая грамматика (число | токен | n*token | a+b-c) И
    согласованность значения (ZADERZHKA_NE_SOGLASNA)."""
    if not (isinstance(z, dict) and isinstance(z.get('token'), str)
            and isinstance(z.get('ms'), (int, float))
            and not isinstance(z.get('ms'), bool)):
        bad.append(otkaz('TREK_BEZ_POLJA', gde + ': delay'))
        return False
    v = _znach_vyrazhenija(z['token'], tk)
    if v is None:
        bad.append(otkaz('ZADERZHKA_NE_PO_GRAMMATIKE',
                         '%s: %s' % (gde, z['token'])))
    elif abs(v - float(z['ms'])) > 1e-9:
        bad.append(otkaz('ZADERZHKA_NE_SOGLASNA',
                         '%s: %s' % (gde, z['token'])))
    else:
        return True
    return False




def _proverka_ud(t, ud_limit, gde, bad):
    """«Уменьшить движение» (правило MOTION reduced_motion): столбец
    обязателен; перемещение/размер — 0; видимое (opacity/bg) — не дольше
    токена motion-fast."""
    r = t.get('reduced_duration_ms')
    if not isinstance(r, (int, float)) or isinstance(r, bool):
        bad.append(otkaz('UD_BEZ_STOLBCA', gde))
    elif ((t['property'] in SVOJSTVA_VIZUALNYE
           and float(r) > ud_limit + 1e-9)
          or (t['property'] not in SVOJSTVA_VIZUALNYE
              and abs(float(r)) > 1e-9)):
        bad.append(otkaz('UD_NARUSHEN', gde + ': ' + t['property']))


def _proverka_end(t, z, dur, gde, bad):
    """end_ms == delay + duration (производное число, не самовольное)."""
    if not isinstance(t.get('end_ms'), (int, float)) \
            or isinstance(t.get('end_ms'), bool) \
            or abs(float(t['end_ms'])
                   - (float(z['ms']) + float(dur['ms']))) > 1e-9:
        bad.append(otkaz('END_MS_NE_RAVEN', gde))


def _proverka_sceny_kadry(sc, pid, bad):
    """Ключевые кадры сцены: окно от нуля; ровно 0/25/50/75/100 % и
    значения == доля окна (механизм 0/25/50/75/100 приёмки движения)."""
    w = sc.get('window_ms')
    kf = sc.get('keyframes_ms')
    if not (isinstance(w, list) and len(w) == 2
            and all(isinstance(x, (int, float)) for x in w)):
        bad.append(otkaz('TREK_BEZ_POLJA', pid + ': window_ms'))
        return
    if float(w[0]) != 0.0:
        bad.append(otkaz('OKNO_NE_OT_NULJA', pid))
    if not (isinstance(kf, dict)
            and set(kf) == {'0', '25', '50', '75', '100'}
            and all(isinstance(kf[k], (int, float)) for k in kf)):
        bad.append(otkaz('KLJUCHEVYE_KADRY_NE_RAVNY', pid))
        return
    for k in ('0', '25', '50', '75', '100'):
        if abs(float(kf[k]) - float(w[1]) * int(k) / 100.0) > 1e-9:
            bad.append(otkaz('KLJUCHEVYE_KADRY_NE_RAVNY',
                             '%s: %s%%' % (pid, k)))


def _proverka_sceny_fajly(sc, pid, bad):
    """Файлы эталонов сцены: 4 темы видео + 4 темы ключевых кадров,
    списки непусты (сами байты — в Release, судят vision-судьи)."""
    fajly = sc.get('files')
    if (not isinstance(fajly, dict)
            or not isinstance(fajly.get('video'), dict)
            or set(fajly['video']) != set(TEMY_ETF)
            or not all(isinstance(v, str) and v
                       for v in fajly['video'].values())
            or not isinstance(fajly.get('keyframes'), dict)
            or set(fajly['keyframes']) != set(TEMY_ETF)
            or not all(isinstance(v, list) and v
                       and all(isinstance(x, str) and x for x in v)
                       for v in fajly['keyframes'].values())):
        bad.append(otkaz('FAJLY_ETALONOV_NE_POLNY', pid))


def _grammatika_sceny(sc, tk, pid):
    """Грамматика сцены спеки движения по ОБЪЯВЛЕННОМУ переходу (чужие
    сцены вне суда): состав треков, токены длительности/задержки, канон
    кривых, запрет пружин, УД, end_ms, порядок 1..n, ключевые кадры,
    файлы эталонов. Токены — единый источник (spec.tokens); числа
    производны и обязаны совпадать. Составляющие — отдельные функции
    (стабы батареи подменяют ровно свою ветвь, Н-39)."""
    bad = []
    treki = sc.get('tracks')
    if not isinstance(treki, list) or not treki:
        return [otkaz('TREK_BEZ_POLJA', pid + ': нет треков')]
    if 'motion-fast' not in tk or tk['motion-fast'][1] is None:
        return [otkaz('UD_NARUSHEN', pid + ': spec без токена motion-fast')]
    ud_limit = tk['motion-fast'][1]
    porjadki = []
    for i, t in enumerate(treki):
        gde = '%s:%d' % (pid, i + 1)
        if not isinstance(t, dict) or not POLJA_TREKA <= set(t) \
                or not isinstance(t.get('property'), str):
            bad.append(otkaz('TREK_BEZ_POLJA', gde))
            continue
        dur_ok = _proverka_dlitel(t.get('duration'), tk, gde, bad)
        zader_ok = _proverka_zaderzh(t.get('delay'), tk, gde, bad)
        _proverka_mekhaniki(t, tk, gde, bad)
        _proverka_ud(t, ud_limit, gde, bad)
        if dur_ok and zader_ok:
            _proverka_end(t, t['delay'], t['duration'], gde, bad)
        if isinstance(t.get('order'), int) and not isinstance(t.get('order'), bool):
            porjadki.append(t['order'])
    _proverka_sceny_poryadok(porjadki, len(treki), pid, bad)
    _proverka_sceny_kadry(sc, pid, bad)
    _proverka_sceny_fajly(sc, pid, bad)
    return bad


def _proverka_mekhaniki(t, tk, gde, bad):
    """Механика анимации трека: канон кривых (ease-standard/ease-morph/
    linear; значение == токену) И запрет пружин (MOTION rules: no
    springs) — одна ветвь, кривая и пружина неразделимы."""
    kr = t.get('curve')
    if not (isinstance(kr, dict) and isinstance(kr.get('token'), str)):
        bad.append(otkaz('TREK_BEZ_POLJA', gde + ': curve'))
    elif kr['token'] not in KRIVYE_KANON:
        bad.append(otkaz('KRIVAYA_VNE_KANONA',
                         '%s: %s' % (gde, kr['token'])))
    elif kr['token'] == 'linear':
        if kr.get('value') is not None:
            bad.append(otkaz('KRIVAYA_NE_SOGLASNA', gde + ': linear'))
    elif kr['token'] not in tk or tk[kr['token']][0] is None:
        bad.append(otkaz('KRIVAYA_NE_SOGLASNA',
                         '%s: %s' % (gde, kr['token'])))
    elif kr.get('value') != tk[kr['token']][0]:
        bad.append(otkaz('KRIVAYA_NE_SOGLASNA',
                         '%s: %s' % (gde, kr['token'])))
    if t.get('spring') is not None:
        bad.append(otkaz('PRUZHINA_ZAPRESHCHENA', gde))


def _proverka_sceny_poryadok(porjadki, n, pid, bad):
    """Порядок стартов треков: order ровно 1..n (хореография сцены —
    данные спеки, валидатор судит производное)."""
    if porjadki != list(range(1, n + 1)):
        bad.append(otkaz('PORYADOK_NARUSHEN', pid))


def check_dvizhenie(f, repo: Path, kadry):
    """Блок dvizhenie (v3, слово владельца 2026-10-28 mob-dvizhenie
    §Решение п.4): форма, источники с пинами, экраны пачки против
    манифеста и якорей кадров, ПОЛНОТА переходов (∩-правило), сцены
    знака, эталоны Release, грамматика спеки по объявленным переходам.
    Ветвь инертна для пачек v1/v2 без GA-кадров (обратная совместимость
    замороженных экранов слайса-1 — пачки 117/135/118 не переоткрываются)."""
    bad, dv = zagnost_dvizhenija(f)
    if bad:
        return bad
    sbad, isto = zagnost_istochniki(dv, repo)
    if sbad:
        return sbad
    man, spc, poz = isto['manifest'], isto['spec'], isto['pozvonok']
    tk = _tokeny(spc)
    obad, ekrany = _spisok_dv(dv, 'ekrany', RE_GA_EKRAN)
    if obad:
        return obad
    bad += _ekrany_sud(set(man['screens']), ekrany, kadry['ids'])
    if bad:
        return bad
    pbad, perehody = _spisok_dv(dv, 'perehody', RE_PEREHOD, pustoj=True)
    if pbad:
        return pbad
    dvizh_man = {}
    for m in man['motion']:
        dvizh_man[m['id']] = set(m['frames'])
    bad += _perehody_polnota(dvizh_man, set(ekrany), perehody)
    if bad:
        return bad
    sceny = {}
    for s in spc['scenes']:
        sceny[s['id']] = s
    for pid in perehody:
        if pid not in sceny:
            bad.append(otkaz('PEREHOD_BEZ_SPECY', pid))
    if bad:
        return bad
    zbad, sceny_znaka = _spisok_dv(dv, 'sceny_znaka', RE_PEREHOD, pustoj=True)
    if zbad:
        return zbad
    bad += _sceny_znaka_sud(set(poz['scenes']), set(perehody), sceny_znaka)
    if bad:
        return bad
    bad += _etalony_sud(sceny, dv['etalony'], perehody)
    if bad:
        return bad
    for pid in sorted(perehody):
        bad += _grammatika_sceny(sceny[pid], tk, pid)
    return bad


def _ekrany_sud(ekrany_man, ekrany, kadry_ids):
    """Экраны пачки: посторонний — EKRAN_VNE_MANIFESTA; кадр с GA-якорем
    без объявления — EKRANY_NE_POLNY; объявленный без кадров —
    EKRAN_BEZ_KADROV (состав пачки — не самодекларация, якорь кадра
    наблюдаем)."""
    bad = []
    for e in ekrany:
        if e not in ekrany_man:
            bad.append(otkaz('EKRAN_VNE_MANIFESTA', e))
    po_jakorju = set()
    for kid in kadry_ids:
        if RE_GA_JAKOR.match(kid):
            po_jakorju.add(kid.split(' ', 1)[0])
    for e in sorted(po_jakorju - set(ekrany)):
        bad.append(otkaz('EKRANY_NE_POLNY', e))
    for e in sorted(set(ekrany) - po_jakorju):
        bad.append(otkaz('EKRAN_BEZ_KADROV', e))
    return bad


def _perehody_polnota(dvizh_man, ekrany, perehody):
    """ПОЛНОТА переходов (∩-правило): всякий переход манифеста, чьи
    frames ∩ экраны пачки ≠ ∅, объявлен; посторонний/вне манифеста —
    отказ (незаявленное движение невидимо приёмкой — главный обход)."""
    bad = []
    for pid in perehody:
        if pid not in dvizh_man:
            bad.append(otkaz('PEREHOD_VNE_MANIFESTA', pid))
        elif not (dvizh_man[pid] & ekrany):
            bad.append(otkaz('PEREHOD_LISHNIJ', pid))
    for pid in sorted(dvizh_man):
        if dvizh_man[pid] & ekrany and pid not in perehody:
            bad.append(otkaz('PEREHODY_NE_POLNY', pid))
    return bad


def _sceny_znaka_sud(sceny_poz, perehody, zaiavl):
    """Сцены знака — РОВНО perehody ∩ сцены поз-оракула (И-3, обе
    стороны равенства; B.9 арбитража 146): пропуск лишает численной
    приёмки знака (SCENY_ZNAKA_NE_POLNY); объявленная вне пересечения —
    отказ: сцена вообще без поз-оракула (SCENA_VNE_ORAKULA; T28/T31 —
    морф-треки) И сцена, ЧУЖАЯ переходам этой пачки, хоть и с позами
    (SCENA_VNE_PEREHODA — эталоны знака не её)."""
    bad = []
    peresechenie = perehody & sceny_poz
    for s in zaiavl:
        if s not in peresechenie:
            bad.append(otkaz('SCENA_VNE_ORAKULA' if s not in sceny_poz
                             else 'SCENA_VNE_PEREHODA', s))
    for s in sorted(peresechenie):
        if s not in zaiavl:
            bad.append(otkaz('SCENY_ZNAKA_NE_POLNY', s))
    return bad


def _etalony_sud(sceny, et, perehody):
    """Эталоны Release на каждый переход: 4 темы видео + 4 темы × столько
    sha-пинов, сколько файлов ключевых кадров в спеке (байты — вне репо,
    судят vision-судьи; валидатор — наличие/форму/число/состав)."""
    bad = []
    for pid in sorted(set(et) - set(perehody)):
        bad.append(otkaz('ETALON_LISHNIJ', pid))
    for pid in sorted(set(perehody) - set(et)):
        bad.append(otkaz('ETALON_BEZ_PINOV', pid))
    for pid in sorted(perehody):
        if pid not in et:
            # уже назван ETALON_BEZ_PINOV выше; отсутствующий ключ НЕ
            # индексируем (B.9 арбитража 146: краш — не именованный отказ)
            continue
        z = et[pid]
        fajly = sceny[pid].get('files')
        if not isinstance(z, dict) or set(z) != {'keyframes', 'video'}:
            bad.append(otkaz('SHABLON_NEVEREN', 'etalony.' + pid))
            continue
        if (not isinstance(fajly, dict)
                or not isinstance(fajly.get('video'), dict)
                or not isinstance(fajly.get('keyframes'), dict)):
            bad.append(otkaz('FAJLY_ETALONOV_NE_POLNY', pid))
            continue
        vid, kfs = fajly['video'], fajly['keyframes']
        zv = z['video']
        if not isinstance(zv, dict) or set(zv) != set(vid):
            bad.append(otkaz('VIDEO_ETALON_NE_POLON', pid))
            continue
        for tema in sorted(zv):
            if not isinstance(zv[tema], str) or not RE_SHA256.match(zv[tema]):
                bad.append(otkaz('ETALON_NE_HEX',
                                 '%s video %s' % (pid, tema)))
        zk = z['keyframes']
        if not isinstance(zk, dict) or set(zk) != set(kfs):
            bad.append(otkaz('ETALON_TEMA_OTSVTSTVUET', pid))
            continue
        for tema in sorted(zk):
            puti = kfs[tema]
            piny = zk[tema]
            if not isinstance(puti, list) or not isinstance(piny, list) \
                    or len(piny) != len(puti):
                bad.append(otkaz('ETALON_NE_POLON', '%s %s' % (pid, tema)))
                continue
            for x in piny:
                if not isinstance(x, str) or not RE_SHA256.match(x):
                    bad.append(otkaz('ETALON_NE_HEX',
                                     '%s %s' % (pid, tema)))
                    break
    return bad


def d24_ekrany(kadry):
    """Экраны D 2.4 пачки по якорям кадров (GA-ид в начале id кадра):
    пачка без GA-кадров — не экранная пачка D 2.4, dvizhenie ей не нужен
    (слайс-1: 117/135/118 остаются при своей форме)."""
    ek = set()
    for kid in kadry['ids']:
        if RE_GA_JAKOR.match(kid):
            ek.add(kid.split(' ', 1)[0])
    return sorted(ek)


def check_d24_triggery(f, kadry):
    """Триггер раздела «движение» (v3): shablon 3 без блока и кадры с
    GA-якорем у пачки БЕЗ shablon 3 — DVIZHENIE_OTSVTSTVUET с именами
    (экран D 2.4 не прячет движение за версией формы)."""
    if f['shablon'] == 3 and 'dvizhenie' not in f:
        return [otkaz('DVIZHENIE_OTSVTSTVUET',
                      'shablon 3 без блока dvizhenie')]
    if f['shablon'] != 3 and d24_ekrany(kadry):
        return [otkaz('DVIZHENIE_OTSVTSTVUET',
                      'экраны D 2.4 без shablon 3: %s'
                      % ', '.join(d24_ekrany(kadry)))]
    return []

def _forma_priemki_dvizhenija(dv):
    """Форма команды приёмки движения: argv несёт --json И --outputFile
    с путём отчёта в репо (алфавит RE_PRIEMKA уже проверен формой).
    Возвращает (argv, путь | None)."""
    argv = razbit_argv(dv['priemka_dvizhenija'])
    put_otcheta = None
    if '--outputFile' in argv:
        i = argv.index('--outputFile')
        if i + 1 < len(argv) and path_ok(argv[i + 1]):
            put_otcheta = argv[i + 1]
    if '--json' not in argv:
        put_otcheta = None
    return argv, put_otcheta



def run_priemka_dvizhenie(f, repo: Path):
    """Исполнение численной приёмки движения (фактический argv, cwd=репо,
    без shell — прецедент Г3-002): rc 0; отчёт jest-формы по --outputFile
    СВЕЖ (создан этим запуском: mtime не старше старта И байты отличны от
    дозапусковой ревизии — как свежесть кадров e2e), читается, тесты
    непусты и все зелены. Команда без --json/--outputFile — отказ ещё на
    форме (DVIZHENIE_BEZ_OTCHETA): «приёмка движения исполнена» без
    отчёта не бывает."""
    argv, put_otcheta = _forma_priemki_dvizhenija(f['dvizhenie'])
    if put_otcheta is None:
        return [otkaz('DVIZHENIE_BEZ_OTCHETA',
                      f['dvizhenie']['priemka_dvizhenija'])]
    p = repo / put_otcheta
    rester = None
    if p.is_file():
        rester = _sha256_bajtov(p)
    start = time.time_ns()
    try:
        r = subprocess.run(argv, cwd=str(repo), capture_output=True,
                           text=True)
    except (OSError, ValueError):
        return [otkaz('DVIZHENIE_NE_PROSHLA', 'запуск: ' + argv[0])]
    if r.returncode != 0:
        return [otkaz('DVIZHENIE_NE_PROSHLA', 'rc=%d' % r.returncode)]
    if not p.is_file():
        return [otkaz('OTCHET_OTSVTSTVUET', put_otcheta)]
    if p.stat().st_mtime_ns < start or rester == _sha256_bajtov(p):
        return [otkaz('OTCHET_USTAREVSHIJ', put_otcheta)]
    try:
        ot = json.loads(p.read_text(encoding='utf-8'))
    except (OSError, ValueError):
        return [otkaz('OTCHET_NE_CHITAETSJA', put_otcheta)]
    nt = ot.get('numTotalTests') if isinstance(ot, dict) else None
    np_ = ot.get('numPassedTests') if isinstance(ot, dict) else None
    if not isinstance(nt, int) or isinstance(nt, bool) or nt == 0:
        return [otkaz('OTCHET_PUSTOJ', put_otcheta)]
    if not isinstance(np_, int) or isinstance(np_, bool) or np_ != nt:
        return [otkaz('OTCHET_S_PROVALAMI', put_otcheta)]
    return []

def _bez_kommentarija(line):
    """Комментарий YAML (С-2 арбитража 132 v2): «#» первым непробельным
    символом строки либо сразу после пробела, ВНЕ одинарных/двойных
    кавычек; текст строки ДО «#» остаётся (исполняется); лексическое
    правило — парсер YAML не нужен (инвариант 7: чистый stdlib)."""
    kav = None
    for i, ch in enumerate(line):
        if kav:
            if ch == kav:
                kav = None
        elif ch in ('"', "'"):
            kav = ch
        elif ch == '#' and (line[:i].strip() == '' or line[i - 1] == ' '):
            return line[:i]
    return line


def ispolnimye_stroki_flo(stroki):
    """ИСПОЛНЯЕМЫЙ текст флоу (С-2 арбитража 132 v2, обходы б-2/в):
    строки ПОСЛЕ первого разделителя документа «---» (шапка Maestro
    appId/name/tags — не шаги) с отброшенными комментариями YAML.
    Ссылка (id pressable / obolochka / snimok) засчитывается ТОЛЬКО
    здесь: комментарий и шапка — форма, не исполнение. Флоу без «---»
    исполняемого текста НЕ имеет (fail-closed: причины
    PROKHOD_BEZ_PRESSABLE / MARSHRUT_BEZ_OBOLOCHKI / MARSHRUT_BEZ_SNIMKA
    неизбежны)."""
    telo, v_telo = [], False
    for line in stroki:
        if not v_telo:
            if line.strip() == '---':
                v_telo = True
            continue
        telo.append(_bez_kommentarija(line))
    return telo

def check_marshrut(f, pack: Path, repo: Path):
    """МАРШРУТ собранного пути (блокер 3 вердикта критика 1/2; С-2
    арбитража 132 v2 — обходы в/вопрос 3): «собранный путь с оболочкой» —
    наблюдаем, не заявлен: vtoroj_profil.marshrut — существующий флоу
    репо, содержащий obolochka ОСОБЛЕННЫМ токеном В ИСПОЛНЯЕМОМ ТЕКСТЕ
    флоу (ispolnimye_stroki_flo: после первого «---», без комментариев
    YAML — шапка name: и «# tabshell» ссылкой не являются; вход в
    оболочку наблюдается в исполненном пути; поддельная оболочка/голый
    маршрут из launchApp+takeScreenshot не принимаются) И КАЖДЫЙ snimok
    манифеста профиля ТЕМ ЖЕ обособленным токеном (единообразие с id и
    оболочкой; связь исполненного пути с каждым кадром обеих тем).
    Пустая obolochka здесь не судится — её отказывает GOLYJ_KOMPONENT
    своей ветвью."""
    vp = f.get('vtoroj_profil')
    if not isinstance(vp, dict) or 'marshrut' not in vp or 'kadry' not in vp:
        return []  # грамматика блока уже отказала своей ветвью
    try:
        stroki = ispolnimye_stroki_flo(
            (repo / vp['marshrut']).read_text(encoding='utf-8').splitlines())
    except OSError:
        return [otkaz('SHABLON_NEVEREN', 'нет файла: ' + vp['marshrut'])]
    bad = []
    obl = vp.get('obolochka')
    if isinstance(obl, str) and obl:
        token = re.compile(r'(?<![a-zA-Z0-9-])%s(?![a-zA-Z0-9-])'
                           % re.escape(obl))
        if not any(token.search(line) for line in stroki):
            bad.append(otkaz('MARSHRUT_BEZ_OBOLOCHKI',
                             'маршрут %s не содержит оболочку %s: собранный '
                             'путь не наблюдается' % (vp['marshrut'], obl)))
    kadry, _ = load_kadry(pack / vp['kadry'])
    if kadry:
        vidennye = []
        for s in kadry['snimki']:
            if isinstance(s, str) and s not in vidennye:
                vidennye.append(s)
        for s in vidennye:
            token = re.compile(r'(?<![a-zA-Z0-9-])%s(?![a-zA-Z0-9-])'
                               % re.escape(s))
            if not any(token.search(line) for line in stroki):
                bad.append(otkaz('MARSHRUT_BEZ_SNIMKA', s))
    return bad


def run_sverka_profil(f, pack: Path, repo: Path, harness: Path):
    """Сверка ВТОРОГО ПРОФИЛЯ (дорогая): валидатор сам вызывает раннер 123
    по манифесту профиля (второй набор кадров/эталонов; кадры кладёт та же
    priemka.e2e). Успех — МОЛЧА: stdout первого набора остаётся дословным
    (прежние ожидания неизменны); отказ раннера отображается в именованный
    отказ шаблона с кадром профиля. Четвёртой команды приёмки нет."""
    runner = harness / 'scripts' / 'sverka_maketa.py'
    if not runner.is_file():
        return [otkaz('SVERKA_123_ABSENT', str(runner))]
    p = subprocess.run(
        [sys.executable, str(runner),
         '--manifest', str(pack / f['vtoroj_profil']['kadry']),
         '--kadry', str(repo / f['kadry_dir']), '--repo', str(repo)],
        capture_output=True, text=True)
    bad = []
    for line in p.stderr.splitlines():
        chasti = line.split('\t')
        imja = RUNNER_MAP.get(chasti[0] if chasti else '')
        if imja:
            bad.append(otkaz(imja, '\t'.join(chasti[1:])))
    if p.returncode == 2 and not bad:
        bad.append(otkaz('SHABLON_NEVEREN', 'раннер 123: манифест кадров профиля'))
    return bad


def run_sverka(f, pack: Path, repo: Path, harness: Path):
    """Дорогая проверка — раннер 123 по коду (мера/порог манифеста кадров).

    Возвращает (rc_раннера, stdout_раннера, [отказы шаблона]).
    """
    runner = harness / 'scripts' / 'sverka_maketa.py'
    if not runner.is_file():
        return 2, '', [otkaz('SVERKA_123_ABSENT', str(runner))]
    p = subprocess.run(
        [sys.executable, str(runner), '--manifest', str(pack / f['kadry']),
         '--kadry', str(repo / f['kadry_dir']), '--repo', str(repo)],
        capture_output=True, text=True)
    bad = []
    for line in p.stderr.splitlines():
        chasti = line.split('\t')
        imja = RUNNER_MAP.get(chasti[0] if chasti else '')
        if imja:
            bad.append(otkaz(imja, '\t'.join(chasti[1:])))
    if p.returncode == 2 and not bad:
        bad.append(otkaz('SHABLON_NEVEREN', 'раннер 123: манифест кадров'))
    return p.returncode, p.stdout, bad


def _sha256_fajla(p: Path):
    h = hashlib.sha256()
    with p.open('rb') as fh:
        for chunk in iter(lambda: fh.read(1 << 16), b''):
            h.update(chunk)
    return h.hexdigest()


def svezhost_kadrov(kd: Path, start_ns: int, rester: dict):
    """Свежесть кадров (обход круга 2: e2e один раз, потом priemka.e2e=true
    оценивает СТАРЫЕ кадры): КАЖДЫЙ файл под kadry_dir обязан быть создан
    ЭТИМ запуском — mtime моложе старта команды И байты отличны от
    дозапусковой ревизии; иначе KADR_USTAREVSHIJ (fail-closed)."""
    bad = []
    for p in sorted(kd.rglob('*')):
        if not p.is_file():
            continue
        rel = p.relative_to(kd).as_posix()
        if p.stat().st_mtime_ns < start_ns or rester.get(rel) == _sha256_fajla(p):
            bad.append(otkaz('KADR_USTAREVSHIJ', rel))
    return bad


def run_priemka_e2e(f, repo: Path):
    """Исполнение приёмки e2e: фактический argv, cwd = репо, без shell.
    До команды — ревизия kadry_dir (пути+sha256) и метка старта; после
    rc 0 — СВЕЖЕСТЬ оставшихся кадров (команда без кадров даёт
    KADR_OTSUTSTVUET на сверке, не зелень; оставшиеся — KADR_USTAREVSHIJ)."""
    kd = repo / f['kadry_dir']
    rester = {}
    if kd.is_dir():
        rester = {p.relative_to(kd).as_posix(): _sha256_fajla(p)
                  for p in sorted(kd.rglob('*')) if p.is_file()}
    start_ns = time.time_ns()
    try:
        p = subprocess.run(razbit_argv(f['priemka']['e2e']),
                           cwd=str(repo), capture_output=True, text=True,
                           timeout=600)
    except (OSError, subprocess.SubprocessError) as e:
        return [otkaz('E2E_NE_PROSHLA', repr(e)[:120])]
    if p.returncode != 0:
        return [otkaz('E2E_NE_PROSHLA', 'rc=%d' % p.returncode)]
    return svezhost_kadrov(kd, start_ns, rester)


def _argv_rannera123(sv):
    """Форма точного вызова раннера 123: python3 <путь файла> и полный argv
    CLI 123 — три обязательных флага (--manifest M --kadry DIR --repo R)
    по одному разу со значениями. ИМЯ файла — НЕ дискриминатор (блокер 1
    вердикта adv-132 круг 2: суффикс /scripts/sverka_maketa.py проходил
    подмене с константным stdout); идентичность файлу раннера судится
    отдельно по байтам (_jet_runner123); обрезанный argv — самодельная
    сверка."""
    if len(sv) != 8 or sv[0] != 'python3':
        return False
    flagi, znach = sv[2::2], sv[3::2]
    return (sorted(flagi) == ['--kadry', '--manifest', '--repo']
            and all(z and not z.startswith('--') for z in znach))


def _jet_runner123(put_fajla: Path, harness: Path):
    """Идентичность раннеру 123 ПО ФАЙЛУ, не по имени/суффиксу пути
    (блокер 1 вердикта adv-132 круг 2): путь из argv сверки (cwd = репо)
    обязан разрешаться в существующий файл с sha256 == эталону
    --harness/scripts/sverka_maketa.py — разрешённый путь раннера
    (пин .harness123 репо, scripts/ харнесса), симлинк на него и
    байт-в-байт копия зелёные; podmena/scripts/sverka_maketa.py — НЕ
    раннер: самодельная сверка."""
    etalon = harness / 'scripts' / 'sverka_maketa.py'
    try:
        return _sha256_fajla(put_fajla) == _sha256_fajla(etalon)
    except OSError:
        return False


def _svjaz_argv_pachki(sv, f, pack: Path, repo: Path):
    """Связь трёх значений argv с предъявленной пачкой (арбитраж impl П-1).
    --manifest сравнивается по байтам: честная .harness123/kadry.json —
    копия pack/kadry.json с другим realpath; пути каталогов — по realpath.
    Отсутствие файла/каталога даёт именованный отказ, а не исключение."""
    znach = dict(zip(sv[2::2], sv[3::2]))
    manifest = repo / znach['--manifest']
    try:
        if (not manifest.is_file()
                or _sha256_fajla(manifest) != _sha256_fajla(pack / f['kadry'])):
            return otkaz('SAMODELNAYA_SVERKA', '--manifest не манифест пачки')
    except OSError:
        return otkaz('SAMODELNAYA_SVERKA', '--manifest не манифест пачки')
    kadry = repo / znach['--kadry']
    if (not kadry.is_dir()
            or os.path.realpath(kadry) != os.path.realpath(repo / f['kadry_dir'])):
        return otkaz('SAMODELNAYA_SVERKA', '--kadry не каталог кадров пачки')
    put_repo = repo / znach['--repo']
    if (not put_repo.is_dir()
            or os.path.realpath(put_repo) != os.path.realpath(repo)):
        return otkaz('SAMODELNAYA_SVERKA', '--repo не репо продукта')
    return None


def run_priemka_sverka(f, pack: Path, repo: Path, harness: Path, obrazec_stdout: str):
    """Исполнение приёмки сверки: argv без shell; rc 0 И stdout дословно
    равен сверке-образцу раннера 123 (фиктивные echo/true не воспроизводят
    вывод механизма) И команда — ТОЧНЫЙ вызов раннера 123: полный argv
    CLI 123 (python3 <путь файла> --manifest M --kadry DIR --repo R)
    И файл по <путь файла> ИДЕНТИЧЕН эталонному раннеру БАЙТАМИ
    (sha256 == --harness/scripts/sverka_maketa.py): константная реплика
    stdout по имени-фрагменту (…py.fake, блокер 2 круга 1) либо по
    совпавшему суффиксу имени (podmena/scripts/sverka_maketa.py, блокер 1
    круга 2 вердикта adv-132) проходит сверку вывода, но раннером не
    является — SAMODELNAYA_SVERKA. Значения --manifest/--kadry/--repo
    связаны с пачкой: байты манифеста и realpath двух каталогов."""
    sv = razbit_argv(f['priemka']['sverka'])
    valid_argv = _argv_rannera123(sv)
    valid_runner = valid_argv and _jet_runner123(repo / sv[1], harness)
    if valid_runner:
        nesvjaz = _svjaz_argv_pachki(sv, f, pack, repo)
        if nesvjaz:
            return [nesvjaz]
    try:
        p = subprocess.run(razbit_argv(f['priemka']['sverka']),
                           cwd=str(repo), capture_output=True, text=True,
                           timeout=600)
    except (OSError, subprocess.SubprocessError) as e:
        return [otkaz('SAMODELNAYA_SVERKA', 'не исполняется: %r' % e)]
    if p.returncode != 0 or p.stdout.splitlines() != obrazec_stdout.splitlines():
        return [otkaz('SAMODELNAYA_SVERKA',
                      'вывод не воспроизводит механизм 123')]
    if not valid_argv:
        return [otkaz('SAMODELNAYA_SVERKA',
                      'argv не вызов раннера 123: %s' % f['priemka']['sverka'])]
    if not valid_runner:
        return [otkaz('SAMODELNAYA_SVERKA', 'файл не раннер 123: %s' % sv[1])]
    return []

def run_priemka_prokhod(f, repo: Path):
    """Исполнение прохода Maestro по видимым pressable (правило
    проходимости, слово владельца 2026-10-27): фактический argv, cwd =
    репо, без shell (как e2e/sverka, Г3-002); ИСПОЛНЯЕТСЯ ПОСЛЕ сверки кадров —
    кнопки жмутся после сравнения кадров с макетом. Нажатие без
    наблюдаемого изменения либо незамеченная неактивность — rc команды
    отличен от 0 (флоу продукта обязано утверждать изменение либо метку
    неактивности для каждого pressable манифеста) — PROKHOD_NE_PROSHLA."""
    try:
        p = subprocess.run(razbit_argv(f['priemka']['prokhod']),
                           cwd=str(repo), capture_output=True, text=True,
                           timeout=600)
    except (OSError, subprocess.SubprocessError) as e:
        return [otkaz('PROKHOD_NE_PROSHLA', repr(e)[:120])]
    if p.returncode != 0:
        return [otkaz('PROKHOD_NE_PROSHLA', 'rc=%d' % p.returncode)]
    return []


def check_prokhod_komanda(f, repo: Path):
    """КОМАНДА прохода (блокер 2 вердикта критика 1/2; С-2/С-3 арбитража
    132 v2): проход — не любой rc-0 скрипт: argv несёт ЦЕЛЬ-ФЛОЮ Maestro —
    существующий .yaml в репо (argv БЕЗ цели-флою — true/echo ok/
    sh -c exit 0 — PROKHOD_NE_MAESTRO; С-3: механизм различает ИМЕННО
    отсутствие цели-флою в argv — команда с .yaml в argv, не исполняющая
    Maestro (echo <flow>/cat <flow>/обёртка-заглушка), статикой от
    честной обёртки неотличима: rc 0 без нажатий, честный остаток, ловец
    — продуктовый CI и ревью). Флоу ссылается на КАЖДЫЙ pressable обоих
    списков манифеста обособленным токеном id В ИСПОЛНЯЕМОМ ТЕКСТЕ
    (ispolnimye_stroki_flo, С-2: после первого «---», без комментариев
    YAML — шапка name: и «# id» ссылкой не являются); флоу без
    pressable — PROKHOD_BEZ_PRESSABLE. Исполнение остаётся за
    run_priemka_prokhod (rc + нажатие без наблюдаемого изменения —
    PROKHOD_NE_PROSHLA)."""
    argv = razbit_argv(f['priemka']['prokhod'])
    flow = None
    for a in argv:
        if a.endswith('.yaml') and (repo / a).is_file():
            flow = repo / a
            break
    if flow is None:
        return [otkaz('PROKHOD_NE_MAESTRO',
                      'проход без цели-флоу Maestro (существующий .yaml '
                      'в репо): %s' % f['priemka']['prokhod'])]
    try:
        stroki = ispolnimye_stroki_flo(
            flow.read_text(encoding='utf-8').splitlines())
    except OSError:
        return [otkaz('PROKHOD_NE_MAESTRO', 'флоу прохода не читается')]
    p = f.get('prokhodimost')
    ids = ([x['id'] for spisok in ('pressable', 'demo') for x in p[spisok]]
           if isinstance(p, dict) else [])
    bad = []
    for pid in ids:
        token = re.compile(r'(?<![a-zA-Z0-9-])%s(?![a-zA-Z0-9-])'
                           % re.escape(pid))
        if not any(token.search(line) for line in stroki):
            bad.append(otkaz('PROKHOD_BEZ_PRESSABLE', pid))
    return bad
def main(argv=None):
    args = sys.argv[1:] if argv is None else argv
    if (len(args) != 6 or args[0] != '--pack' or args[2] != '--repo'
            or args[4] != '--harness'):
        print('CLI: ekran_shablon.py --pack DIR --repo DIR --harness DIR',
              file=sys.stderr)
        return 2
    pack = Path(args[1]).resolve()
    repo = Path(args[3]).resolve()
    harness = Path(args[5]).resolve()
    try:
        f = read_json(pack / 'ekran.json')
    except (OSError, ValueError):
        print(otkaz('SHABLON_NEVEREN', 'ekran.json'), file=sys.stderr)
        return 2
    otkazy = check_alfavit(f)
    kadry = None
    if not any(o.split('\t')[1] in RC2 for o in otkazy):
        kadry, kerr = load_kadry(pack / f['kadry'])
        otkazy += kerr
        otkazy += check_fajly(f, pack, repo, harness)
    stdout_run = ''
    if not any(o.split('\t')[1] in RC2 for o in otkazy):
        tekst = (pack / f['kontrakt']).read_text(encoding='utf-8')
        otkazy += check_razdely(tekst)
        otkazy += check_objem(tekst)
        otkazy += check_zony_stroki(tekst, f)
        otkazy += check_literal(pack)
        otkazy += check_kljuchi(f, repo)
        otkazy += check_operacii(f, repo)
        if kadry:
            otkazy += check_scenarij(f, repo, kadry)
        otkazy += check_priemka(f)
        if kadry:
            otkazy += check_tselikom(f, harness, repo, kadry)
            otkazy += check_chuzhie(f, harness, repo, kadry)
        otkazy += check_polnota(f, harness, repo, pack)
        if kadry and 'shablon' in f:
            otkazy += check_prokhodimost(f, kadry)
        if kadry and 'shablon' in f and 'prokhodimost' in f:
            otkazy += check_vtoroj_profil(f, pack)
        if kadry and 'shablon' in f and 'vtoroj_profil' in f:
            otkazy += check_marshrut(f, pack, repo)
        if kadry and 'shablon' in f:
            otkazy += check_prokhod_komanda(f, repo)
        if kadry and 'shablon' in f:
            # v3 (146): экранным пачкам D 2.4 (кадры с GA-якорем) раздел
            # «движение» ОБЯЗАТЕЛЕН (check_d24_triggery — именованный
            # отказ, правило 7; состав — не самодекларация: якорь кадра).
            otkazy += check_d24_triggery(f, kadry)
            if 'dvizhenie' in f:
                otkazy += check_dvizhenie(f, repo, kadry)
        if not otkazy:
            otkazy += check_starost(f, kadry['piny'] if kadry else set())
        if not otkazy:
            otkazy += run_priemka_e2e(f, repo)
        if not otkazy:
            _, stdout_run, bad = run_sverka(f, pack, repo, harness)
            otkazy += bad
            if stdout_run:
                sys.stdout.write(stdout_run if stdout_run.endswith('\n')
                                 else stdout_run + '\n')
        if not otkazy:
            otkazy += run_priemka_sverka(f, pack, repo, harness, stdout_run)
        if not otkazy and 'shablon' in f and 'vtoroj_profil' in f:
            otkazy += run_sverka_profil(f, pack, repo, harness)
        if not otkazy and 'shablon' in f:
            otkazy += run_priemka_prokhod(f, repo)
        if not otkazy and f.get('shablon') == 3:
            otkazy += run_priemka_dvizhenie(f, repo)
    for o in otkazy:
        print(o, file=sys.stderr)
    if otkazy:
        return 2 if any(o.split('\t')[1] in RC2 for o in otkazy) else 1
    print('SHABLON\t%s\tOK' % f['ekran'])
    return 0


if __name__ == '__main__':
    sys.exit(main())
