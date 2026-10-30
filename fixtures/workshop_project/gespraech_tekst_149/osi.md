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
| razdel-otsvtstvuet | RAZDEL_OTSVTSTVUET |

Недостижимые в v3 имена (не клетки): VTOROJ_PROFIL_OTSVTSTVUET и
PROKHODIMOST_OTSVTSTVUET — удаление ОБЯЗАТЕЛЬНОГО поля ловит закрытый
состав формы SHABLON_NEVEREN ещё в check_alfavit (замер 147); KADR_NIZHE
_POROGA на паре тёмный/светлый макет — линейные рисунки D 2.4 сверкой
не разводятся (замер 147), ловец — живая сверка продуктового CI против
настоящих скриншотов; кадры GA-13/GA-17 несут маску зоны системной
клавиатуры (платформа, правило 6 MOTION) — сверка судит приложение,
клавиатура — по видео (vision).

## Ось d — правила данных (пиннованные источники, судит оракул)

| правило | что доказывает |
|---|---|
| d-pole-rastjot | манифест: поле GA-13 выше поля GA-11 (растёт с текстом); «Nachricht senden» есть только в GA-13 (появляется с текстом); микрофон в поле GA-13 — 44×44 (CHANGELOG: поле + голос в поле) |
| d-t30-fon-zakryvaet | спека T30: конец #gnd ≤ задержки КАЖДОГО .L-chat2 трека (без двойного изображения — выводимо из пиннованной спеки) |
| d-t30-morph-450 | морф #morph x/y/w/h: токен motion-morph (450), ease-morph, УД 0; resolved from/to равны по темам |
| d-t32-porjadok-sobytij | события T32: отметка → вопрос → чипы строго возрастают; чипы и «Lieber erzählen?» — ОДНО событие #b-qr |
| d-t37-b-end-na-morfe | событие «Weiter im Anliegen» на motion-morph; морф Leiste→поле 4 трека ease-morph УД 0 |
| d-ud-trex-scen | во всех трёх сценах: видимое (opacity/bg) ≤ motion-fast, остальное 0 |

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
в батарее нет), экранный шаг ОБЯЗАН нести расширение ВТОРЫМ AVD 393
(норма 132 v2; блок Crit147b: job без второго boot/серийника
принимался зелёным) — вторая загрузка эмулятора, PORT393=5581 и экспорт
GESPRAECH_TEKST_SERIAL/GESPRAECH_TEKST_SERIAL_393, потребляемые
e2e.sh пачки; валидатор 132 v3 из .harness149, PORT=5580 и оба корневых
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
A-дерево рецепта (--a-derevo: живые байты продукта 6240f630 + три
парные правки + второй AVD) — клетка зелена, полная батарея rc 0 85/85.

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
(stabs/stab_host_pustoj.tsx) и «композер не изменён» (байты product
main, nositeli/produkt/composer-108.tsx). Именованные причины:
ISPOLNIMYJ_KONTROL_KRASEN / ISPOLNIMYJ_MUTANT_ZHIV /
ISPOLNIMYJ_MUTANT_NE_UBIT (падение загрузки сьюта ≠ убитый мутант) /
ISPOLNIMYJ_INFRA / LIVE_PREDPOSYLKA (заявленная среда без установки —
никогда skip→pass) / ORACLE_TAMPERED (пин зонда); без
mobile/package.json — именованный пропуск ISPOLNIMYJ_SKIP в stderr,
НЕ зелень продукта. Среда 145/RNTL v14: каждое событие зонда ЖДЁТСЯ
(прецедент pilot.test click). Референс-раскладка батареи —
model/produktnaja-raskladka/ (чат-хост + chat-kopija.ts + композер).

## Стабы (Н-39: привязка к правилу/клетке, где дефект наблюдаем) — дополнение блока 1

| стаб | клетка |
|---|---|
| ekran-minimalnyj | s-pachka-validirovana |
| jest-krasnyj | s-ekran-ispolnim (контроль красен) |
| jest-zelenyj | s-ekran-ispolnim (мутант жив) |

Мутант «пустой хост» (stab_host_pustoj.tsx) — вход матрицы
ispolnimyj_sud, зонд обязан краснеть УПАВШИМ АССЕРТОМ.
