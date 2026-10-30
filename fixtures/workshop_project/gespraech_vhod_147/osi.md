# Оси батареи 147 (gespraech-vhod-menu) — имена причин по осям

Формат клетки: `CASE <ось>-<вход> ok|KRASNO (<причина>)`. Ожидание каждой
красной клетки — РОВНО одно имя причины × все адреса своей оси; сверяется
с фактом ЭТАЛОНА (model/ekran_shablon.py, пин source.json) на том же
входе ДО субъекта (правило 8). Рассинхрон — ORACLE_TAMPERED rc 2.

## Ось a — форма пачки (судья: валидатор 132 v3)

Субъект: `scripts/ekran_shablon.py` живого дерева против эталона v3
(пин). Вход — мир (мини-продукт с пачкой-эталоном + мини-харнесс) с
ОДНОЙ мутацией пачки; `kontrol-forma` — честный мир (rc 0, SHABLON OK).

| вход | причина |
|---|---|
| kontrol-forma | (зелёный контроль: rc 0) |
| shablon2-s-ga | DVIZHENIE_OTSVTSTVUET |
| ekrany-ne-polny-ga-01/-ga-15/-ga-16 | EKRANY_NE_POLNY |
| ekran-vne-manifesta (GA-99) | EKRAN_VNE_MANIFESTA |
| ekran-bez-kadrov (GA-09) | EKRAN_BEZ_KADROV |
| perehody-ne-polny-t28/-t29/-t30/-t31/-t33/-t35 | PEREHODY_NE_POLNY |
| perehod-lishnij (GA-T16) | PEREHOD_LISHNIJ |
| perehod-vne-manifesta (GA-T36) | PEREHOD_VNE_MANIFESTA |
| scena-vne-orakula (GA-T28 — морф-трек) | SCENA_VNE_ORAKULA |
| scena-vne-perehoda (GA-T20 — позы чужого) | SCENA_VNE_PEREHODA |
| sceny-znaka-ne-polny (снят GA-T29) | SCENY_ZNAKA_NE_POLNY |
| etalon-bez-pinov (GA-T31) | ETALON_BEZ_PINOV |
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
| kadr-neodnoznachen | KADR_NEODNOZNACHEN |
| samodelnaya-sverka | SAMODELNAYA_SVERKA |
| razdel-otsvtstvuet | RAZDEL_OTSVTSTVUET |

Недостижимые в v3 имена (не клетки): VTOROJ_PROFIL_OTSVTSTVUET и
PROKHODIMOST_OTSVTSTVUET — удаление ОБЯЗАТЕЛЬНОГО поля ловит закрытый
состав формы SHABLON_NEVEREN ещё в check_alfavit (замер этой пачки);
PEREHOD_BEZ_SPECY — у всех переходов реального манифеста есть сцены
спеки; KADR_NIZHE_POROGA на паре тёмный/светлый макет — линейные
рисунки D 2.4 сверкой не разводятся (замер: эталон зелён), ловец —
живая сверка продуктового CI против настоящих скриншотов.

## Ось d — правила данных (пиннованные источники, судит оракул)

| правило | что доказывает |
|---|---|
| d-menja-300 | концы opacity пилюль T28 возрастают и ≤ 300 мс (обещание нарезки выводимо из пиннованной спеки, не из прозы) |
| d-sprechen-pervym | задержки пилюль возрастают по порядку; первая — «Sprechen» (элементы манифеста GA-15) |
| d-press-long-500 | трек удержания: токен press-long, linear, 1 → 1.06; событие 500 мс → состояние listening |
| d-ud-dvizhenija | во всех шести сценах: видимое (opacity/bg) ≤ motion-fast, остальное 0 |

## Ось m — машина вход-меню (раннер model/dvizhenie-runner.mjs, node)

Субъект: `mobile/src/features/conversation/menu-machine.ts` продукта
(в --model/--stabs — модель model/menu-machine.ts). Правила раннера
идентичны канону teksty/gespraech-dvizhenie.test.ts (jest продукта):
plan-open-t28, sprechen-pervym, menja-k-300, znak-morf-250,
press-long-500, plan-close-t31, ud-bez-poljota. План машины обязан
ПОЛНОСТЬЮ покрывать треки сцен (неполнота — красная).

## Ось s — субъект в продукте

s-pachka-v-produkte, s-mashina-v-produkte, s-kanon-bajty (байты
канон-файлов против source.json piny.kanon). В --model/--stabs —
статически-зелёные контроли (доказано осями a/m и vedro; прецедент
132/146); безфлагово — SUBJECT_ABSENT до реализации.

## Стабы (Н-39: привязка к правилу, где дефект наблюдаем)

| стаб | правило |
|---|---|
| porjadok-obratnyj | sprechen-pervym |
| shag-ne-tot | plan-open-t28 |
| poslednjaja-310 | menja-k-300 |
| presslong-ranjshe | press-long-500 |
| ud-ignor | ud-bez-poljota |
| morph-linejnyj | znak-morf-250 |
| zakrytie-bez-morfa | plan-close-t31 |

Честность раннера доказывается самими стабами: раннер, всегда пишущий
«зелено», оставил бы стабы живыми (rc 1 STAB_ZHIV).
