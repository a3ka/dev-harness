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

s-lekalo-instanciirovano (И-8; блок Crit147 круг 1 — ekran.json={} без
проводки проходил 70/70; блок Crit147b круг 2 — job без второго AVD 393
и запись карты с puti=[] проходили 71/71; блок Crit147c scoped — удаление
ТОЛЬКО запуска второго эмулятора после переключения 393 проходило 71/71):
судит в --repo ТРИ парные правки лекала 143/2 (экран-работник добавляется
СВОИМ PR инстанциацией ЛЕКАЛА nositeli/screen-job.template.yml — копия
frozen 143/2, sha256-пин; ключи инстанциации — source.json.lekalo,
единый источник): (1) запись карты mobile/ci-screens.json с job
e2e-gespraech-vhod (id/kontrakty/status/pack/flows оба корневых/
child_flows/h_checkout .harness147/output_namespace + НЕПУСТЫЕ puti —
все три пути И-8: features/conversation, tab-shell.tsx, mocks —
пусто/неполная тройка красна LEKALO_BEZ_PUTEJ_KARTY: выбор экранной
задачи по её путям не обеспечен); (2) job в
.github/workflows/mobile.yml ИЗ ЛЕКАЛА — needs/if/outputs/runs-on/
timeout/permissions равны скелету инстанциации, шаги лекала по порядку
полными именами (грамматика одна — пиннованный шаблон, второго перечня
в батарее нет), экранный шаг расширяем (норма 132 v2 — второй AVD 393 в
том же работнике), но несёт валидатор 132 v3 из .harness147, PORT=5572 и
оба корневых флоу в FLOWS_PACHKI; H-checkout — принятым 40-hex пином (не
плавающей ссылкой); запреты continue-on-error/strategy/matrix и ровно
один «ПОВТОР: »; (3) output выбора в select-screens (из шага vybor) + имя
работника в needs ОБОИХ агрегатов (android-e2e required +
mobile-regression-signal ночной); вынос пачки — общий шаг инвентаризации
quality (--mode inventar; персональный mv и wildcard запрещены); пачка
НЕ ПУСТА (ekran.json — форма v3: shablon 3, ekran gespraech-vhod, ekrany
GA-01/GA-15/GA-16 — обход Crit147 {} красен); ВТОРОЙ AVD профиля 393 в
экранном шаге (блок Crit147b: PORT393=5573, boot-переключ
SERIAL="$SERIAL393", export GESPRAECH_SERIAL_393= ДО вызова приёмки
run_priemka — канон e2e.sh ждёт её; отсутствие/непотребление —
LEKALO_BEZ_VTOROGO_PROFILJA); ЗАПУСК AVD-393 по коду job (блок Crit147c:
create avd -n "$AVD393" — без него emulator -avd "$AVD393" мёрт; вызов
boot МЕЖДУ переключением SERIAL="$SERIAL393" и возвратом serial-390
(AVD="$AVD_GL")/первым run_priemka — порядок «переключение serial →
запуск AVD-393 → run_priemka»; каноническая форма — грамматика лекала
«if ! boot; then … exit …; fi» либо голый boot под set -e; маскировки:
if: на экранном шаге, || true/|| : у вызова, условная guard (открытое
then/else/do перед вызовом), форма без exit — LEKALO_BEZ_ZAPUSKA_393).
Имя причины — РОВНО одно на вход, по старшинству:
LEKALO_NE_INSTANCIIROVANO (парные правки/вынос/форма/запреты) →
LEKALO_BEZ_VTOROGO_PROFILJA (второй AVD 393) → LEKALO_BEZ_ZAPUSKA_393
(запуск 393) → LEKALO_BEZ_PUTEJ_KARTY (puti записи). Зелёный контроль:
A-дерево рецепта (--a-derevo: живые байты продукта 6240f630 + три парные
правки + создание/запуск второго AVD) — клетка зелена, полная батарея
rc 0 71/71.

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
| lekalo-obhod-kritika | s-lekalo-instanciirovano |
| lekalo-bez-zapuska-393 | s-lekalo-instanciirovano |

Честность раннера доказывается самими стабами: раннер, всегда пишущий
«зелено», оставил бы стабы живыми (rc 1 STAB_ZHIV). Стабы лекала —
мутаторы ДЕРЕВА (не машины): lekalo-obhod-kritika снимает все три парные
правки и опустошает ekran.json (дословный обход Crit147 атака 3);
lekalo-bez-zapuska-393 удаляет ТОЛЬКО строку запуска второго эмулятора
после переключения 393 (вызовов boot 3→2, bash -n rc 0 — дословный
scoped-обход Crit147c); клетка обязана краснеть своим именем —
мутанты-«пропускники» (клетка зелена без проверок) ловятся той же парой
входов: A-дерево рецепта зелено, каждый стаб-обход красен (контроль в
каждом --stabs прогоне; замеры частичных мутантов и маскировок —
контракт §Живые измерения).
