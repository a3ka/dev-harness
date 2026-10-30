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

Честность раннера доказывается самими стабами: раннер, всегда пишущий
«зелено», оставил бы стабы живыми (rc 1 STAB_ZHIV).
