# Оси батареи 149 (gespraech-tekst-chat) — имена причин по осям

Формат клетки: `CASE <ось>-<вход> ok|KRASNO (<причина>)`. Ожидание каждой
красной клетки — РОВНО одно имя причины × все адреса своей оси; сверяется
с фактом ЭТАЛОНА (model/ekran_shablon.py, пин source.json) на том же
входе ДО субъекта (правило 8). Рассинхрон — ORACLE_TAMPERED rc 2.

## Ось a — форма пачки (судья: валидатор 132 v3)

Субъект: `scripts/ekran_shablon.py` живого дерева (v3 в main — равен
эталону) против эталона v3 (пин). Вход — мир (мини-продукт с
пачкой-эталоном + мини-харнесс) с ОДНОЙ мутацией пачки;
`kontrol-forma` — честный мир (rc 0, SHABLON OK).

| вход | причина |
|---|---|
| kontrol-forma | (зелёный контроль: rc 0) |
| shablon2-s-ga | DVIZHENIE_OTSVTSTVUET |
| ekrany-ne-polny-ga-11/-ga-12/-ga-13/-ga-17/-ga-18/-ga-19 | EKRANY_NE_POLNY |
| ekran-vne-manifesta (GA-99) | EKRAN_VNE_MANIFESTA |
| ekran-bez-kadrov (GA-09) | EKRAN_BEZ_KADROV |
| perehody-ne-polny-t30/-t32/-t34/-t08/-t37/-t17/-t18/-t19/-r2/-r2-393 | PEREHODY_NE_POLNY |
| perehod-lishnij (GA-T28) | PEREHOD_LISHNIJ |
| perehod-vne-manifesta (GA-T36) | PEREHOD_VNE_MANIFESTA |
| scena-vne-orakula (GA-T30 — морф-трек) | SCENA_VNE_ORAKULA |
| scena-vne-perehoda (GA-T20 — позы чужого) | SCENA_VNE_PEREHODA |
| sceny-znaka-ne-polny (снят GA-T32) | SCENY_ZNAKA_NE_POLNY |
| etalon-bez-pinov (GA-T30) | ETALON_BEZ_PINOV |
| etalon-ne-hex | ETALON_NE_HEX |
| etalon-ne-polon | ETALON_NE_POLON |
| etalon-tema-otsvtstvuet | ETALON_TEMA_OTSVTSTVUET |
| video-etalon-ne-polon | VIDEO_ETALON_NE_POLON |
| etalon-lishnij (GA-T16) | ETALON_LISHNIJ |
| istochnik-ne-sovpadaet (пин спеки) | ISTOCHNIK_NE_SOVPADAET |
| istochnik-otsvtstvuet (поз-оракул удалён) | ISTOCHNIK_OTSVTSTVUET (rc 2) |
| kljuch-bez-kataloga | KLJUCH_BEZ_KATALOGA |
| scenarij-bez-snimka | SCENARIJ_BEZ_SNIMKA |
| zony-rashodjatsja | ZONY_RASHODJATSJA |
| ne-trogaet-ne-polon | NE_TROGAET_NE_POLON |
| pressable-bez-izmenenija | PRESSABLE_BEZ_IZMENENIJA |
| kasanie-menshe-normy | KASANIE_MENSHE_NORMY |
| kasanie-v-safe-zone | KASANIE_V_SAFE_ZONE |
| kadr-neodnoznachen | KADR_NEODNOZNACHEN |
| profil-nizhe-minimuma | PROFIL_NIZHE_MINIMUMA |
| profil-bez-insetov (vyrez 24) | PROFIL_BEZ_INSETOV |
| golyl-komponent | GOLYJ_KOMPONENT |
| marshrut-bez-obolochki | MARSHRUT_BEZ_OBOLOCHKI |
| marshrut-bez-snimka | MARSHRUT_BEZ_SNIMKA |
| odna-tema | ODNA_TEMA |
| nalozhenie-sloev | NALOZHENIE_SLOEV |
| zalezaet-pod-inset | ZALEZAET_POD_INSET |
| pustaja-ikonka | PUSTAJA_IKONKA |
| kontrakt-dlinnyj | NE_ODNA_STRANICA |
| literal-cveta | LITERAL_VNE_AUDITA |
| prokhod-ne-maestro | PROKHOD_NE_MAESTRO |
| prokhod-bez-pressable | PROKHOD_BEZ_PRESSABLE |
| dvizhenie-bez-otcheta | DVIZHENIE_BEZ_OTCHETA |
| dvizhenie-ne-proshla | DVIZHENIE_NE_PROSHLA |
| otchet-ustarevshij | OTCHET_USTAREVSHIJ |
| otchet-pustoj | OTCHET_PUSTOJ |
| otchet-s-provalami | OTCHET_S_PROVALAMI |
| e2e-ne-proshla | E2E_NE_PROSHLA |
| kadr-ustarevshij | KADR_USTAREVSHIJ |
| samodelnaya-sverka | SAMODELNAYA_SVERKA |
| staroj-pin-d24 (оба kadry-манифеста пачки → макеты D 2.4 Final 2) | KADR_NIZHE_POROGA |
| razdel-otsvtstvuet | RAZDEL_OTSVTSTVUET |

Недостижимые в v3 имена (не клетки): VTOROJ_PROFIL_OTSVTSTVUET и
PROKHODIMOST_OTSVTSTVUET — удаление ОБЯЗАТЕЛЬНОГО поля ловит закрытый
состав формы SHABLON_NEVEREN ещё в check_alfavit (замер 147); KADR_NIZHE
_POROGA на паре тёмный/светлый макет — линейные рисунки D 2.4 сверкой
не разводятся (замер 147), ловец — живая сверка продуктового CI против
настоящих скриншотов; кадры GA-13/GA-17 несут маску зоны системной
клавиатуры (платформа, правило 6 MOTION) — сверка судит приложение,
клавиатура — по видео (vision).

## v2 (слово владельца 2026-11-02, пакет D24-Kompakt-1.1)

Эталонные кадры/токены/зоны касания — пакет `docs/ux/05_Kompakt_D24`
(D24-Kompakt-1.1, ЗАМЕНЯЕТ 1.0; носители зоны `nositeli/kompakt11/`):
kadry-манифесты пачки пинуют ИМЕНА кадров пакета (`frames/frames.json`)
с sha из `frames/SHA256SUMS` (якорь целостности; d-paket-kompakt судит
и носители — байты пакета). Стенд-ин e2e подаёт ПЕРЕКОДИРОВАННЫЕ кадры
1.1 (пиксели равны, байты отличны; реализация рендерит компактную
шкалу) — записи берёт из kadry-манифестов пачки, не списком. Старый пин
D 2.4 Final 2 грамматикой ПРИНИМАЕТСЯ (мутация ставит честные пути/ша
против старых макетов мира) — красна ЖИВАЯ мера 123: кадры-носители 1.1
против макета финала-2 (замер этой пачки: 390-набор 10/12 кадров
0.315–0.597 < 0.600; неотличимы GA-13 dark 0.895/0.901, GA-17 dark
0.700/0.702, GA-17 light-393 0.656 — ловится полный набор валидатора,
одиночная подмена этих кадров — живой CI/vision). Движение пакет 1.1
не меняет: источники dvizhenie пачки — финал 2 (манифест экранов/
переходов под грамматику v3 — manifest 1.1 screens-словарь без motion
её не проходит; спека/позы — числа неизменны), d-paket-dvizhenie судит
это по motion-delta (13 изменённых — только размеры, в т.ч. T30/T34/
T08/T37/T17; T32/T18/T19 — «Сохранено») и токенам (motion без final2).
Касание — по ЗОНЕ hw/hh манифеста 1.1 (d-paket-zony: аудит under_44=0,
pressables пачки == зонам по карте целей; видимая рамка меньше зоны
находкой не является — слово владельца). Снятые носители: 24
перекодированных кадра финала-2 (`nositeli/d24/kadry/`) — мёртвый вес
после перехода стенд-ина на кадры 1.1 (макеты финала-2 ОСТАЮТСЯ —
мир мутации staroj-pin-d24 подаёт их по 04-путям).

## Ось d — правила данных (пиннованные источники, судит оракул)

| правило | что доказывает |
|---|---|
| d-pole-rastjot | манифест: поле GA-13 выше поля GA-11 (растёт с текстом); «Nachricht senden» есть только в GA-13 (появляется с текстом); микрофон в поле GA-13 — 44×44 (CHANGELOG: поле + голос в поле) |
| d-t30-fon-zakryvaet | спека T30: конец #gnd ≤ задержки КАЖДОГО .L-chat2 трека (без двойного изображения — выводимо из пиннованной спеки) |
| d-t30-morph-450 | морф #morph x/y/w/h: токен motion-morph (450), ease-morph, УД 0; resolved from/to равны по темам |
| d-t32-porjadok-sobytij | события T32: отметка → вопрос → чипы строго возрастают; чипы и «Lieber erzählen?» — ОДНО событие #b-qr |
| d-t37-b-end-na-morfe | событие «Weiter im Anliegen» на motion-morph; морф Leiste→поле 4 трека ease-morph УД 0 |
| d-ud-trex-scen | во всех трёх сценах: видимое (opacity/bg) ≤ motion-fast, остальное 0 |
| d-paket-kompakt | кадры пачки — имена/ша кадров пакета 1.1 (frames.json + SHA256SUMS, носители = байты пакета); покрытие 46/46 full — ожидание кадров GA-09/14/18/19 СНЯТО |
| d-paket-zony | зоны hw/hh ≥ touch-target.min (токен) по всем целям экранов пачки обоих профилей; аудит under_44=0; pressables пачки == зонам манифеста (карта целей) |
| d-paket-dvizhenie | движение не изменилось: motion-delta 1.1 (T30/T34/T08/T37/T17 — изменённые-13, только размеры; T32/T18/T19 — «Сохранено») + токены motion без final2 → спека пачки остаётся финалом 2 |
| d-paket-maska | v+1 цикл 2 (слово владельца 31.10): самоприменение — манифест кадров профиля 393 пачки несёт маску шапки 48 pt (mera.chrome_verh_pt и верх «ekran»-элемента всех 12 записей); repin зоны на 36 красит правило; в R то же значение судит s-profil-maska-393 |

## Ось m — машина текст-чата (раннер model/dvizhenie-runner.mjs, node)

Субъект: `mobile/src/features/conversation/chat-machine.ts` продукта
(в --model/--stabs — модель model/chat-machine.ts). Правила раннера
идентичны канону teksty/gespraech-tekst.test.ts (jest продукта):
plan-t30, t30-fon-do-chata, t30-morf-pilulja-pole, t30-temy-posle-polja,
plan-t32, t32-vopros-ranshe-chipov, plan-t37, t37-leista-v-pole,
ud-bez-poljota, pole-shest-strok. План машины обязан ПОЛНОСТЬЮ
покрывать треки сцен (неполнота — красная); таймлайн T32 машина
получает параметром из событий спеки — сама задержки не изобретает.

## Ось s — субъект в продукте

s-pachka-v-produkte, s-mashina-v-produkte, s-kanon-bajty (байты
канон-файлов против source.json piny.kanon). В --model/--stabs —
статически-зелёные контроли (доказано осями a/m и vedro; прецедент
132/146/147); безфлагово — SUBJECT_ABSENT до реализации.

s-lekalo-instanciirovano (И-8; блок Crit149 круг 1 — ekran.json={} без
проводки проходил 82/82): судит в --repo ТРИ парные правки лекала 143/2
(экран-работник добавляется СВОИМ PR инстанциацией ЛЕКАЛА
nositeli/screen-job.template.yml — копия frozen 143/2, sha256-пин; ключи
инстанциации — source.json.lekalo, единый источник, зеркало рецепта
pachka/ci-recept-d149.md): (1) запись карты mobile/ci-screens.json с job
e2e-gespraech-tekst (id/kontrakty/status/pack/flows оба корневых/
child_flows/h_checkout .harness149/output_namespace/puti НЕПУСТЫ —
блок Crit147b: puti=[] не выбирал экран); (2) job в
.github/workflows/mobile.yml ИЗ ЛЕКАЛА — needs/if/outputs/runs-on/
timeout/permissions равны скелету инстанциации, шаги лекала по порядку
полными именами (грамматика одна — пиннованный шаблон, второго перечня
в батарее нет), v+1 цикл 2 (Crit149k2a ПОРЯДОК_AVD_393): работник
поднимает ОДИН эмулятор лекала — экранный шаг СТРОГО равен скелету
(добавочное поведение — параллельный второй boot, инертные строки —
красно; пару профилей ПОСЛЕДОВАТЕЛЬНО ведёт e2e.sh пачки: остановка
первого, затем запуск 393, слово владельца 31.10); e2e.sh пачки несёт
ПОРТАМ лекала привязку (5580/5582); валидатор 132 v3 из .harness149,
PORT=5580 и оба корневых
флоу в FLOWS_PACHKI; H-checkout — принятым 40-hex пином (не плавающей
ссылкой); запреты continue-on-error/strategy/matrix и ровно один
«ПОВТОР: »; (3) output выбора в select-screens (из шага vybor) + имя
работника в needs ОБОИХ агрегатов (android-e2e required +
mobile-regression-signal ночной); вынос пачки — общий шаг
инвентаризации quality (--mode inventar; персональный mv и wildcard
запрещены); пачка НЕ ПУСТА (ekran.json — форма v3: shablon 3, ekran
gespraech-tekst, ekrany GA-11/12/13/17/18/19 — обход Crit149 {}
красен). Отсутствие ЛЮБОГО аспекта — именованный отказ
LEKALO_NE_INSTANCIIROVANO со списком недостающего. Зелёный контроль:
A-дерево рецепта (--a-derevo; v2: живой клон продукта с пакетом 1.1
в docs/ux/05_Kompakt_D24 + три парные правки; v+1 цикл 2: один эмулятор
работника, пара профилей — последовательный e2e.sh) — клетка зелена,
полная батарея rc 0 96/96 (замер v+1 цикла 2 на a-derevo3; v2 — 93/93
на a-derevo2; v1 — 85/85 на 6240f630 до перепина пакета).

s-emuljatory-posledovatelno (v+1 цикл 2, Crit149k2a класс
ПОРЯДОК_AVD_393; слово владельца 2026-10-31 — второй эмулятор профиля
393 запускается ПОСЛЕ остановки первого, не одновременно): судит в
--repo ИСПОЛНЕНИЕМ e2e.sh пачки R в песочнице с двойниками SDK
(прецедент 148 v2 по арбитражу): на входе жив эмулятор работника
(5580), двойники adb/emulator пишут журнал KILL/START; каждый START
обязан идти портом 5582 и ТОЛЬКО при пустом множестве живых — параллельный
старт (до остановки первого) красен AVD393_ZAPUSCHEN_DO_OSTANOVKI;
запуск мимо PATH/ANDROID_HOME и отсутствие старта — AVD393_NET_ZAPUSKA;
чужой порт — AVD393_PORT_NE_5582; ненулевой rc скрипта — AVD393_E2E_RC;
именованный отказ клетки: EMULJATORY_NE_POSLEDOVATELNO со списком
аспектов. Журнал — наблюдение, НЕ оракул: порты и начальное состояние —
в памяти судьи (правило 8). Зелёный контроль: A-дерево (e2e.sh зоны);
стаб emuljatory-odnovremenno — KRASEN.

s-profil-maska-393 (v+1 цикл 2, Crit149k2a класс МАСКА_ПРОФИЛЯ_393;
слово владельца 2026-10-31 — маска системной шапки профиля 393 = 48 pt,
вырез камеры): судит в --repo ТОЧНОЕ ЗНАЧЕНИЕ манифеста кадров профиля
R (файл — по записи vtoroj_profil.kadry формы): mera.chrome_verh_pt и
верх «ekran»-элемента КАЖДОЙ записи == 48; 36/47/49 проходят визуальную
меру — значение красит именованно PROFIL_MASKA_NE_48 (прецедент
proverka_maski_profilja 148). Нечитаемые пачка/манифест здесь не
судятся (их раньше красит s-pachka-validirovana). Самоприменение зоны —
d-paket-maska; стаб maska-36 — KRASEN.

## Стабы (Н-39: привязка к правилу, где дефект наблюдаем)

| стаб | правило |
|---|---|
| t30-fon-posle | t30-fon-do-chata |
| t30-morph-linejnyj | t30-morf-pilulja-pole |
| t30-temy-rano | t30-temy-posle-polja |
| t32-chipy-ranshe | t32-vopros-ranshe-chipov |
| t32-bez-plashek | plan-t32 |
| t37-morph-linejnyj | t37-leista-v-pole |
| ud-ignor | ud-bez-poljota |
| pole-bez-potolka | pole-shest-strok |
| pole-bez-skrolla | pole-shest-strok |
| lekalo-obhod-kritika | s-lekalo-instanciirovano |

Честность раннера доказывается самими стабами: раннер, всегда пишущий
«зелено», оставил бы стабы живыми (rc 1 STAB_ZHIV). Стаб лекала —
мутатор ДЕРЕВА (не машины): снимает все три парные правки и опустошает
ekran.json (дословный обход Crit149); клетка обязана краснеть —
мутант-«пропускник» ловится парой входов одной клетки (зелёное A-дерево
рецепта зелено, стаб-обход красен).

## Ось s (блок 1 Crit149b) — полный суд пачки и исполняемый зонд

s-pachka-validirovana (блок 1 Crit149b — «W --repo принимал продукт без
корректной v3-пачки», обход {shablon,ekran,dvizhenie.ekrany} проходил
rc 0 83/83): пачка ЭТОГО экрана в R судится ЗАМОРОЖЕННЫМ валидатором
v3 (эталон model/ekran_shablon.py, пин 5fd1415e, вызов по канону
132/146: --pack/--repo/--harness) в синтетическом репо из файлов R —
пачка целиком; источники dvizhenie/аудит токенов/макеты по манифестам
кадров/флоу команд приёмки (включая цель-флою прохода из argv
priemka.prokhod) — из R по объявленным путям; ne_trogaet — найденное в
R + фикстуры 132 мини-харнесса; раннер 123 — живой из харнесса в
.harness149; стенд-ины e2e/prokhod/npm — батареи (napishi_standiny,
байты те же, что мирам оси A); машина отчёта приёмки — машина R.
Собственных литеральных проверок полей НЕТ — единый источник формы
валидатор. Красная: PACHKA_NE_PROSHLA_VALIDATOR с PRICHINA-строками
валидатора (или «состав ключей != v3» при отказе до именованных
причин). Зелёный контроль: A-дерево с полной пачкой; стаб
ekran-minimalnyj (дословная атака) — KRASEN.

s-ekran-ispolnim (блок 1 Crit149b — «реальный UI доказуем заявленной
командой, не выводится из наличия машины и канона»; прецедент
ispolnimyj_sud 148): живой jest-зонд produkt/gespraech-zond-149.test.tsx
на РЕАЛЬНЫХ компонентах R — чат-хост mobile/src/features/conversation/
chat-host.tsx (экспорт GespraechTekstChat) и композер
mobile/src/ui/conversation-composer/conversation-composer.tsx (экспорт
ChatComposer поверх поверхности 108) — в изолированной копии mobile
(node_modules — симлинк установки R). Матрица мутантов: «пустой хост»
(stabs/stab_host_pustoj.tsx), «композер не изменён» (байты product
main, nositeli/produkt/composer-108.tsx), v+1 цикла 2 (Crit149k2a):
«zona-12-host»/«zona-12-kompozer» (полы зон 44→12 — класс
РЕАЛЬНАЯ_ЗОНА_КАСАНИЯ) и «token-24»/«token-20» (высота строки поля
литералом вместо токена — класс РЕАЛЬНЫЙ_ТОКЕН_ПОЛЯ), v+1 цикла 2
вызов 2 (Crit149k2b): «token-literal-21» (литерал 21 при сохранённом
импорте пакета — дословная атака критика), «bez-chipov-ga19» (GA-19
без обязательных чипов сравнения) и «bez-golosa-v-polje» (голос В
ПОЛЕ снят) — класс ПОЛНОТА_ЖИВЫХ_ЦЕЛЕЙ. Зонд судит НА РЕАЛЬНОМ
компоненте: (а) эффективную hit-area каждой обязательной цели на обоих
профилях — max(width,minWidth) × max(height,minHeight) с hitSlop против
touch-target.min пакета: width/height 44 при полах 36 и обратное сочетание
валидны; уменьшенная эффективная зона красна; видимая рамка отдельно; (б) связь
компонента с ТОКЕНОМ, не совпадение текущего числа (Crit149k2b,
РЕАЛЬНЫЙ_ТОКЕН_ПОЛЯ): контроль зелён ДВАЖДЫ — на пиннованном пакете и
на ПОДМЕНЁННОМ другом допустимом значении (lineHeight Npx→N+2px,
потолок calc(6 * (N+2)px) — грамматика та же; подмена ТОЛЬКО в
изолированной копии суда, предложение вердикта); высота поля обязана
СЛЕДОВАТЬ за токеном — иначе ISPOLNIMYJ_TOKEN_NE_POTREBLJON; мутанты
исполняются ПОД подменой (литерал 21 наблюдаем именно там); (в)
полноту и действие целей (Crit149k2b/k2c): суд достигает шести состояний
пачки; каждая обязательная цель присутствует, не выключена disabled или
accessibilityState.disabled, не блокирована pointerEvents и имеет onPress;
поле принимает ввод. Все 40 пар «состояние × цель» (14 начальных,
остальные 26) суд нажимает на обоих профилях по отдельности — 80
живых action-тестов; disabled Heirat красна. Отсутствие цели —
CEL_OTSTUTSVUET, disabled — CEL_VYKLUCHENA, блокирование —
CEL_OBEZDVIZHENA, нет обработчика — CEL_BEZ_DEJSTVIJA. Карта
«состояние → цели» сверяется с пачкой ТОЧНО (таб-бар — зона 148).
Оба числа зонд читает из
docs/ux/05_Kompakt_D24/source/tokens.json дерева (LIVE_PREDPOSYLKA
при отсутствии пакета/пачки). Среда 145/RNTL: ОДИН render на тест
(render/unmount в одном тесте дают overlapping act() и пустое дерево
— замер этой пачки). Именованные причины:
ISPOLNIMYJ_KONTROL_KRASEN / ISPOLNIMYJ_TOKEN_NE_POTREBLJON /
ISPOLNIMYJ_MUTANT_ZHIV /
ISPOLNIMYJ_MUTANT_NE_UBIT (падение загрузки сьюта ≠ убитый мутант) /
ISPOLNIMYJ_INFRA / LIVE_PREDPOSYLKA (заявленная среда без установки —
никогда skip→pass) / ORACLE_TAMPERED (пин зонда); без
mobile/package.json — именованный пропуск ISPOLNIMYJ_SKIP в stderr,
НЕ зелень продукта. Среда 145/RNTL v14: каждое событие зонда ЖДЁТСЯ
(прецедент pilot.test click). Референс-раскладка батареи —
model/produktnaja-raskladka/ (чат-хост + chat-kopija.ts + композер:
полы зон обеих осей, высота строки — ИЗ ТОКЕНА пакета, не литерал;
меню вложений и чипы GA-19 — по флоу и pressable-карте пачки).

## Стабы (Н-39: привязка к правилу/клетке, где дефект наблюдаем) — дополнение блока 1

| стаб | клетка |
|---|---|
| ekran-minimalnyj | s-pachka-validirovana |
| jest-krasnyj | s-ekran-ispolnim (контроль красен) |
| jest-zelenyj | s-ekran-ispolnim (мутант жив) |
| emuljatory-odnovremenno | s-emuljatory-posledovatelno |
| maska-36 | s-profil-maska-393 |

Мутанты матрицы ispolnimyj_sud («пустой хост», stab_host_pustoj.tsx;
zona-12-*, token-24/token-20, token-literal-21, bez-chipov-ga19,
bez-golosa-v-polje) — файлы-носители (пин sha256), зонд обязан
краснеть на каждом УПАВШИМ АССЕРТОМ (token-literal-21 — на подмене
значения токена, остальные — и на пине); стабы emuljatory/maska —
мутаторы КОПИИ A-дерева рецепта (e2e.sh стартует 393 до остановки
первого; kadry-393 = 36 pt) — клетка обязана краснеть СВОЕЙ причиной
(AVD393_ZAPUSCHEN_DO_OSTANOVKI / PROFIL_MASKA_NE_48), иначе ORACLE rc 2.

## Ось s (перепин 31.10) — форма и состояния флоу: Maestro 2.11.0 + макет D 2.4

Субъект — флоу пачки зоны (байты запинены vedro: piny.sha pachka/*.yaml);
в --repo той же мерой канон-копии mobile/.maestro. Шаги — документы YAML
после первого «---» (структурный аналог ispolnimye_stroki_flo эталона);
замер — факт живого стенда Impl149b §1/§4 (31.10) + сверка кадров с
манифестом D 2.4. Флоу прохода снимков не несёт — клетка формы снимка
его не судит; клетки входа судят все три флоу.

s-snimok-strokoj — SNIMOK_KARTOJ: каждый снимок СТРОКОВОЙ формой
«takeScreenshot: имя» (карта {name: …} в Maestro 2.11.0 даёт «Config
Field Required: path» — оба экранных флоу прежней пачки не исполнялись;
замер Impl149b: строковая форма 4/4 прогона). Преемник клетки 147.

s-vkhod-v-ekran — VHOD_BEZ_VKHODA: после launchApp — assertVisible
first-run-continue + openLink complior://start ДО первого нажатия
(launchApp открывает корень First-Run: без входа цель экрана
недостижима; замер Impl149b §1 + урок 147 f1dc0305).

s-ga12-s-voprosom — GA12_BEZ_VOPROSA: снимок GA-12 обязан идти ПОСЛЕ
наблюдения вопроса агента (gespraech-vopros-agenta) и чипа
(gespraech-chip-gekauft) с момента выбора темы (tapOn gespraech-topic-*
или gespraech-tema-*). Основание: манифест D 2.4, заголовок GA-12 —
«Plakette «Neues Auto» → Thema im Verlauf, Complior fragt zuerst ·
Antwort-Chips und «Lieber erzählen?» kommen zusammen»; замороженный
текст — «темой в Verlauf с вопросом агента и чипами (GA-12)»; прежний
флоу снимал тему-строку БЕЗ вопроса и чипов (Impl149b §4 п.2).

s-ga13-posle-otpravki — GA13_DO_OTPRAVKI: снимок GA-13 обязан идти
ПОСЛЕ отправки (tapOn gespraech-otpravit + assertVisible
gespraech-soobschenie-polzovatel) и НОВОГО ввода (inputText в поле +
assertVisible gespraech-otpravit — «Nachricht senden» появляется с
текстом, d-pole-rastjot). Основание: манифест D 2.4 — GA-13 «Schreiben ·
iOS-Tastatur offen», лента несёт карточку фактов «Aus unserem Gespräch»
и следующий вопрос — следствие отправленного сообщения (кадр ПОСЛЕ
отправки; поле с новым текстом, замер Impl149b §4 п.2); прежний флоу
снимал GA-13 до отправки.

Живое исполнение флоу (эмулятор/Maestro) — продуктовый CI экрана
(остаток 132, как у 147): клетки судят форму и порядок состояний по
запиненным байтам.

## Стабы (Н-39) — дополнение перепина 31.10 (обманный ПЕРЕПИН: флоу + пины вместе)

| стаб | клетка |
|---|---|
| flo-staraq-forma | s-snimok-strokoj |
| flo-bez-vkhoda | s-vkhod-v-ekran |
| ga12-bez-voprosa | s-ga12-s-voprosom |
| ga13-do-otpravki | s-ga13-posle-otpravki |

Мутаторы зеркала зоны: флоу И пины source.json меняются ВМЕСТЕ (порчу
носителя ловит vedro ДО клеток — перепин ловит только клетка). Каждый
обязан краснеть СВОИМ именем причины (иначе ORACLE rc 2);
мутант-«пропускник» ловится STAB_ZHIV rc 1; vedro сверяет привязки с
KLETKI_FLO_STABOV (единый источник) и полноту стабов по клеткам флоу.
