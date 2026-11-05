# SPEC — экран 148 vkladki-tabov (таб-бар D 2.4 Kompakt), лёгкий трек: карта целей + пины

Единый источник карты экрана для набора 158 (`--ekran 148`), jest-сьютов и реализации.
Пакет D24-Kompakt-1.1 — исходный канон состава, текста и токенов; исходные PNG
побайтово сохраняются. Для 390 его исходная геометрия БЕЗ системного хрома
несовместима с выбранной владельцем композицией С системным хромом; §3
различает исходники и производные профильные эталоны, не подменяя канон.
Контракт-носитель: contracts/148-vkladki-tabov.md (ТРЕК: ЛЁГКИЙ, членство — маркер
ekrannyj_nabor_158 в разделе приёмки контракта, грамматика 158-И-6/И-7).

## 1. Пины пакета (sha256; пакет в product main, УТВЕРЖДЁН, заменяет 1.0 и финал-2)

| файл | sha256 |
|---|---|
| `docs/ux/05_Kompakt_D24/source/tokens.json` | `cb39fb94cb0d775c6c739561315eebe87c207c3244f0dab2c4a42660acd06cb2` |
| `docs/ux/05_Kompakt_D24/source/manifest.json` | `3fc386adb04fcbffe60bad979b2b0d53085c013bdbc63a6a905af3e6a568a633` |
| `docs/ux/05_Kompakt_D24/source/copy-de.json` | `c277661822e2d40670c0821ebd012c6823fd411de7dd4d3c50ed3045e024701e` |
| `docs/ux/05_Kompakt_D24/frames/frames.json` | `84e4b5fc52d4dd7e00f91c4c7b9fb56f7ccc5a119b0f4cd351a8199efab72a8b` |
| `docs/ux/05_Kompakt_D24/frames/SHA256SUMS` | `d8fe43b5f4b3850210afc8299a3fd0ab120b15eefd519f1a883d0f69687f9746` |

`frames/` — 188 PNG, свод `190` записей; кадры экрана 148 — 16, каждый
сверен с записью `frames/SHA256SUMS` (замер: 16/16).

## 2. Пины токенов (source/tokens.json 1.1, ветка `$value`; проекция — mobile/src/theme/nav-tokens.ts)

| токен | значение |
|---|---|
| `nav.height` | 49px |
| `nav.item.min-height` | 48px |
| `nav.item.padding` | 5px 0 6px |
| `nav.label.font-size` | 10px |
| `nav.label.line-height` | 12px |
| `nav.icon` | 20px |
| `nav.pebble.width` | 40px |
| `nav.pebble.height` | 24px |
| `nav.badge` | 8px |
| `nav.hide-offset` | 49px |
| `touch-target.min` | 44px |
| `touch-target.extend.button-sm` | 4px |
| `size.row` | 44px |
| `vorgaenge.group.dot` | 8px |
| `typography.body` | fontFamily `{font.sans}`, 15px / 21px, weight 400, spacing 0 |
| `vorgaenge.group.label` | fontFamily `{font.sans}`, 12px / 16px, weight 500, spacing 0.06em, uppercase, color `{color.*.ink-muted}` |

Значения финала-2 (nav.height 71, nav.icon 24, nav.label.font-size 11, pebble 48×32,
hide-offset 84, header.height 60) — НЕ пинятся; литерал равного числа в месте, где
грамматика экрана требует чтения токена, запрещён (И-8 контракта, класс 2 перечня).

## 3. Эталонные кадры (16 состояний/тем/профилей)

SHA ниже относятся к исходным PNG D24-Kompakt-1.1 (`frames/frames.json`,
`frames/SHA256SUMS`); 393 PNG остаются действующими референсами 123.
Для 390 действуют восемь отдельных source-only PNG в
`fixtures/workshop_project/vkladki_tabov_148/etalony-safe-area-390/`
(корень `--repo` раннера 123 = корень харнесса, НЕ продукта).
Генератор `generate_safe_area_390.py` читает ТОЛЬКО неизменные PNG
390/393 пакета и проверяет их SHA из таблицы оригиналов §3 ДО преобразования.
Из каждого оригинального 393 кадра считываются системные полосы 48 px
сверху (остров до строки 48) и 20 px снизу (полоса домашнего жеста);
их первые 390 столбцов переносятся побайтово без масштабирования.
Из оригинала 390 сохраняются пиксели прямоугольников
`[0,390)×[0,727)` (контент/шапка → y=48…774) и
`[0,390)×[795,844)` (лейсте → y=775…823), порог разницы НОЛЬ.
Утрата видимой высоты 68 px = 48+20 системного хрома: исключён
ТОЛЬКО прокручиваемый участок исходного viewport y=727…794;
эквивалентность ВСЕГО кадра не заявлена. Исходный дизайн D24 390
не перепроектирован и не изменён: добавлены только системные полосы,
сохранённая часть переставлена пиксель-в-пиксель. Это НЕ кадры продукта.

| кадр | sha256 |
|---|---|
| `GA-02_normal_dark_390x844.png` | `f9e8648c8dedb8446c0eee32b2a5105e6a6155c8f870a8c3102f206eb3ed2782` |
| `GA-02_normal_dark_393x852.png` | `3943a93fc91b3e0adf6382ae6655cd525cc067369b698f24e51fb7bb161a53b8` |
| `GA-02_normal_light_390x844.png` | `2d508bb14ec703530bb215c24a5b203e9ee60c3bbceb1854b4f0b0e0090559a5` |
| `GA-02_normal_light_393x852.png` | `0f8699969953a2bec50644c1e8dc1d20273d85eff2a62a70caed57693d2b650c` |
| `GA-03_normal_dark_390x844.png` | `66b4c02273dcf04d359fd0a7feefe3362182ba68ac732858039b11d377597556` |
| `GA-03_normal_dark_393x852.png` | `34ced494cf3bd16969e16619d49e00053d480c3227c800d2f84453aac909510e` |
| `GA-03_normal_light_390x844.png` | `4d0a4c0d981e9936920955a4beb2da8be52e414c4026519a86c706946947aa17` |
| `GA-03_normal_light_393x852.png` | `d60bf486da8dca2cee092f9e5c4a2e8cfdbf9579e66584151eba49c7d2753736` |
| `GA-04_normal_dark_390x844.png` | `087a17167b58fce478d384e2c62fc36cda92f61edf93a476dff3298298f8de0b` |
| `GA-04_normal_dark_393x852.png` | `4b54ce6f0eba87f9e663399f37894b8c63a2f02f326c77ca7b9d747d5c31d57e` |
| `GA-04_normal_light_390x844.png` | `ac9dd85c4326b912979c02baabdae09de63dd62ed6efd1dc5bfabd0b56736bcb` |
| `GA-04_normal_light_393x852.png` | `91373fc599d77898a14df0d93235b75e2ac22f9444514a70d491052633dce580` |
| `GA-09_normal_dark_390x844.png` | `86f884df687fa4d6fdc88f815e6101ad2c7aa69af2e2a95801de9dcef79f0f4c` |
| `GA-09_normal_dark_393x852.png` | `039509874abfde53b71962036e807f43295cbae6883cdc199535a05071d3fc8e` |
| `GA-09_normal_light_390x844.png` | `d29692de3533bfba75fe5a9d8e0a78017b343c0a8d2ea83c9f861074acc8e47e` |
| `GA-09_normal_light_393x852.png` | `cd7902e20b2d5a269b5e7a81df5489e6cf2c1c47d50612b905e40f34c8379144` |
Производные 390 референсы: точный `maket` записи `kadry.json` —
`fixtures/workshop_project/vkladki_tabov_148/etalony-safe-area-390/<имя из первого столбца>`.

| имя 390 референса | sha256, вычислен из D24 исходников |
|---|---|
| `GA-02_normal_dark_390x844.png` | `516e41ed70eb05a52dcd27261f10a286f8b7a310b800dc821678ab3c95bb7cca` |
| `GA-02_normal_light_390x844.png` | `813538933352fcdc5da56d9f1df6d5fab277e4c4115d4ccf45a447c0bba12cae` |
| `GA-03_normal_dark_390x844.png` | `c28344eb7e08cc5726bedcf21b02f147d8e6c8a44b80c2e66f306ad218ae8436` |
| `GA-03_normal_light_390x844.png` | `4ca6e4372510ba4dd4cfbf9254165231924427b16aef58ce5b5f4cc38cb06591` |
| `GA-04_normal_dark_390x844.png` | `72d1af71346541d0aefdf11ff0bd1a0fc148e5ad112c37e72fc777991f382884` |
| `GA-04_normal_light_390x844.png` | `b1fac3a3299ea01065e490b1c206f31e60640d4d2504253d716391d1139fb283` |
| `GA-09_normal_dark_390x844.png` | `10caadf62971d46d3685bb1d80cf6d1dd59a3594afd013c21738ba01983ad87b` |
| `GA-09_normal_light_390x844.png` | `564d3d22f06103d7c344c2fdee1330d46d4276d313d68097c6013dbcbae5acb8` |


Геометрия исходного пакета: 390×844 — лейсте y=795…843 (49 px),
системных полос нет; 393×852 — верхняя островная полоса 48 px и
нижняя жестовая полоса 20 px. Сверка каждого из восьми оригиналов 393
определяет границы по пикселям острова и домашнего индикатора и
подтверждает 48/20 перед переносом. На живых AVD измеряется фактический
inset, не подставляется профильный литерал. Сравнение 123: порог 0.600
для каждого из 16 кадров; `chrome_verh_pt=48`, `chrome_niz_pt=20` для
обоих профилей: маскируется только системный хром, а логотип и лейсте
остаются внутри видимой области. Дополнительная `maski_pt` на
шапку/таб-бар не допускается. Проверка `check_safe_area_148.py` сверяет
каждый перенесённый пиксель с оригиналом независимо от исходного PNG
продукта; восемь сравнений возвращают max_difference=0.

Исходные 390 PNG — свидетельство конфликта, не активный референс
после перехода safe-area. На настоящих кадрах Impl148j с указанными
масками и исходными 390 PNG мера 123 дала пять красных из восьми:
GA-03 dark/light 0.484/0.477, GA-04 dark 0.546, GA-09 dark/light
0.566/0.565; худший элемент — tab-leiste. Производные PNG требуют
зелёной пробы на НОВЫХ кадрах уже после чтения верхнего inset;
порог и маска шапки ради такого результата не ослабляются.

Состояния экрана: GA-02/GA-04 — Mitte «In Arbeit» (working); GA-03 — бейдж Mitte
«Ihre Rückmeldung nötig» (needs_user); GA-09 — скролл: контент идёт ПОД лейсте,
лейсте остаётся (оверлей нижнего края).

## 4. Карта целей (source/manifest.json, touch_targets; цель × профиль)

Обязательные цели экрана (замер): GA-02 — 9@390 / 8@393; GA-03 — 16@15; GA-04 — 14@14; GA-09 — 9@9 (всего 48@390, 46@393). Судится зона hw/hh (hit-area): видимая рамка w/h < 44 при hw/hh ≥ 44 — НЕ нарушение (слово владельца 2026-11-02; примеры: «Optionen ansehen» 146×36 при hh 44, чипы 93/94×38 при hh 44, «Filter» 64×36 при hh 44). Цели лейсте несут testID канона 999 (shell-tab-start/vorgaenge/schutz/post, shell-tabbar) + gespraech-mitte; профиль — канон 999; строки Vorgänge — зона касания 60.

### GA-02 @ 390x844 (9 целей)

| надпись (манифест) | w×h видимая | hw×hh зона |
|---|---|---|
| Profil und Einstellungen | 44×44 | 44×44 |
| Rechtsschutz-Beratung Beratungsdokumentation gesendet · 02.10. | 358×60 | 358×60 |
| Hausrat-Vertrag Vertragsunterlagen eingegangen · 02.09. | 358×60 | 358×60 |
| Alle erledigten Vorgänge | 358×44 | 358×44 |
| Start | 78×48 | 78×48 |
| Vorgänge | 78×48 | 78×48 |
| Gespräch mit Complior – In Arbeit | 78×48 | 78×48 |
| Schutz | 78×48 | 78×48 |
| Post | 78×48 | 78×48 |

### GA-02 @ 393x852 (8 целей)

| надпись (манифест) | w×h видимая | hw×hh зона |
|---|---|---|
| Profil und Einstellungen | 44×44 | 44×44 |
| Rechtsschutz-Beratung Beratungsdokumentation gesendet · 02.10. | 361×60 | 361×60 |
| Hausrat-Vertrag Vertragsunterlagen eingegangen · 02.09. | 361×60 | 361×60 |
| Start | 79×48 | 79×48 |
| Vorgänge | 79×48 | 79×48 |
| Gespräch mit Complior – In Arbeit | 79×48 | 79×48 |
| Schutz | 79×48 | 79×48 |
| Post | 79×48 | 79×48 |

### GA-03 @ 390x844 (16 целей)

| надпись (манифест) | w×h видимая | hw×hh зона |
|---|---|---|
| Profil und Einstellungen | 44×44 | 44×44 |
| Schutz: Mobilität Bestätigt, Wohnen Bestätigt, Gesundheit Lücke, Recht Unklar, Familie Unk | 358×54 | 358×54 |
| Verträge 4 bestätigt | 173×112 | 173×112 |
| Beitrag / Monat 184,20 € alle Verträge | 173×112 | 173×112 |
| Optionen ansehen | 146×36 | 146×44 |
| Mobilität Kfz-Versicherung · Vollkasko Bestätigt | 358×53 | 358×53 |
| Wohnen Hausrat · Haftpflicht Bestätigt | 358×54 | 358×54 |
| Gesundheit Berufsunfähigkeit fehlt Lücke | 358×54 | 358×54 |
| Recht Kein Vertrag bekannt Unklar | 358×54 | 358×54 |
| Familie Noch nicht besprochen Unklar | 358×54 | 358×54 |
| Vertragsunterlagen → Post › | 358×44 | 358×44 |
| Start | 78×48 | 78×48 |
| Vorgänge | 78×48 | 78×48 |
| Gespräch mit Complior – Ihre Rückmeldung nötig | 78×48 | 78×48 |
| Schutz | 78×48 | 78×48 |
| Post | 78×48 | 78×48 |

### GA-03 @ 393x852 (15 целей)

| надпись (манифест) | w×h видимая | hw×hh зона |
|---|---|---|
| Profil und Einstellungen | 44×44 | 44×44 |
| Schutz: Mobilität Bestätigt, Wohnen Bestätigt, Gesundheit Lücke, Recht Unklar, Familie Unk | 361×54 | 361×54 |
| Verträge 4 bestätigt | 175×112 | 175×112 |
| Beitrag / Monat 184,20 € alle Verträge | 175×112 | 175×112 |
| Optionen ansehen | 146×36 | 146×44 |
| Mobilität Kfz-Versicherung · Vollkasko Bestätigt | 361×53 | 361×53 |
| Wohnen Hausrat · Haftpflicht Bestätigt | 361×54 | 361×54 |
| Gesundheit Berufsunfähigkeit fehlt Lücke | 361×54 | 361×54 |
| Recht Kein Vertrag bekannt Unklar | 361×54 | 361×54 |
| Familie Noch nicht besprochen Unklar | 361×54 | 361×54 |
| Start | 79×48 | 79×48 |
| Vorgänge | 79×48 | 79×48 |
| Gespräch mit Complior – Ihre Rückmeldung nötig | 79×48 | 79×48 |
| Schutz | 79×48 | 79×48 |
| Post | 79×48 | 79×48 |

### GA-04 @ 390x844 (14 целей)

| надпись (манифест) | w×h видимая | hw×hh зона |
|---|---|---|
| Profil und Einstellungen | 44×44 | 44×44 |
| Alle | 93×38 | 93×44 |
| Eingegangen | 93×38 | 93×44 |
| Gesendet | 93×38 | 93×44 |
| Filter | 64×36 | 64×44 |
| An Complior schicken | 325×44 | 325×44 |
| Rechtsschutz · gesendet von Complior Antwort ausstehend | 358×152 | 358×152 |
| Deckungsanfrage | 101×44 | 101×44 |
| Kfz-Versicherung · KV-2048-7731 Eingegangen | 358×152 | 358×152 |
| Start | 78×48 | 78×48 |
| Vorgänge | 78×48 | 78×48 |
| Gespräch mit Complior – In Arbeit | 78×48 | 78×48 |
| Schutz | 78×48 | 78×48 |
| Post | 78×48 | 78×48 |

### GA-04 @ 393x852 (14 целей)

| надпись (манифест) | w×h видимая | hw×hh зона |
|---|---|---|
| Profil und Einstellungen | 44×44 | 44×44 |
| Alle | 94×38 | 94×44 |
| Eingegangen | 94×38 | 94×44 |
| Gesendet | 94×38 | 94×44 |
| Filter | 64×36 | 64×44 |
| An Complior schicken | 328×44 | 328×44 |
| Rechtsschutz · gesendet von Complior Antwort ausstehend | 361×152 | 361×152 |
| Deckungsanfrage | 101×44 | 101×44 |
| Kfz-Versicherung · KV-2048-7731 Eingegangen | 361×152 | 361×152 |
| Start | 79×48 | 79×48 |
| Vorgänge | 79×48 | 79×48 |
| Gespräch mit Complior – In Arbeit | 79×48 | 79×48 |
| Schutz | 79×48 | 79×48 |
| Post | 79×48 | 79×48 |

### GA-09 @ 390x844 (9 целей)

| надпись (манифест) | w×h видимая | hw×hh зона |
|---|---|---|
| Profil und Einstellungen | 44×44 | 44×44 |
| Rechtsschutz-Beratung Beratungsdokumentation gesendet · 02.10. | 358×60 | 358×60 |
| Hausrat-Vertrag Vertragsunterlagen eingegangen · 02.09. | 358×60 | 358×60 |
| Alle erledigten Vorgänge | 358×44 | 358×44 |
| Start | 78×48 | 78×48 |
| Vorgänge | 78×48 | 78×48 |
| Gespräch mit Complior – In Arbeit | 78×48 | 78×48 |
| Schutz | 78×48 | 78×48 |
| Post | 78×48 | 78×48 |

### GA-09 @ 393x852 (9 целей)

| надпись (манифест) | w×h видимая | hw×hh зона |
|---|---|---|
| Profil und Einstellungen | 44×44 | 44×44 |
| Rechtsschutz-Beratung Beratungsdokumentation gesendet · 02.10. | 361×60 | 361×60 |
| Hausrat-Vertrag Vertragsunterlagen eingegangen · 02.09. | 361×60 | 361×60 |
| Alle erledigten Vorgänge | 361×44 | 361×44 |
| Start | 79×48 | 79×48 |
| Vorgänge | 79×48 | 79×48 |
| Gespräch mit Complior – In Arbeit | 79×48 | 79×48 |
| Schutz | 79×48 | 79×48 |
| Post | 79×48 | 79×48 |

Каждая строка таблиц — обязательная интерактивная цель: существует, включена (не
disabled / не pointerEvents none), видима, с видимой надписью (не прозрачный Text-
потомок), эффективная зона ≥ touch-target.min на интерактивном хозяине по правилам
RN (width/minWidth/maxWidth, height/minHeight/maxHeight, padding во всех формах,
hitSlop, flexBasis), СВОЁ действие со свежим счётчиком после собственного нажатия —
на ОБОИХ профилях и в каждом состоянии (классы 1, 3, 4, 9, 10, 12, 13 перечня).
Цели профиля 393 вне safe-зоны (safe {59, 34, 852}).

## 5. Ключи копии (source/copy-de.json 1.1 — 264 записи; экрану нужны 65, замер)

Новые ключи ui-copy.ts — только verbatim из каталога с родным review_status (И-5).
Перечень (ключ → кадры):

| ключ | кадры |
|---|---|
| `fixture.schutz.01` | GA-03 |
| `fixture.schutz.02` | GA-03 |
| `fixture.vorgaenge.01` | GA-02, GA-09 |
| `fixture.vorgaenge.02` | GA-02, GA-09 |
| `fixture.vorgaenge.03` | GA-02, GA-09 |
| `fixture.vorgaenge.04` | GA-02, GA-09 |
| `fixture.vorgaenge.05` | GA-02, GA-09 |
| `fixture.vorgaenge.06` | GA-02, GA-09 |
| `frame.F40.01.body` | GA-04 |
| `frame.F40.01.title` | GA-04 |
| `ia115.nav.POST` | GA-02, GA-03, GA-04, GA-09 |
| `ia115.nav.SCHUTZ` | GA-02, GA-03, GA-04, GA-09 |
| `ia115.nav.START` | GA-02, GA-03, GA-04, GA-09 |
| `ia117.nav.VORGAENGE` | GA-02, GA-03, GA-04, GA-09 |
| `proposed.brand.wordmark.alt` | GA-02, GA-03, GA-04, GA-09 |
| `proposed.fact.status.confirmed` | GA-03 |
| `proposed.gespraech.menu.continue.body` | GA-02, GA-03, GA-04, GA-09 |
| `proposed.gespraech.tab` | GA-02, GA-03, GA-04, GA-09 |
| `proposed.gespraech.tab.a11y.status` | GA-02, GA-03, GA-04, GA-09 |
| `proposed.kompakt.header.profile.a11y` | GA-02, GA-03, GA-04, GA-09 |
| `proposed.post.filter_sheet.title` | GA-04 |
| `proposed.post.related` | GA-04 |
| `proposed.protection.a11y` | GA-03 |
| `proposed.protection.area.family` | GA-03 |
| `proposed.protection.area.health` | GA-03 |
| `proposed.protection.area.home` | GA-03 |
| `proposed.protection.area.legal` | GA-03 |
| `proposed.protection.area.mobility` | GA-03 |
| `proposed.protection.full.a11y` | GA-03 |
| `proposed.protection.status.gap` | GA-03 |
| `proposed.protection.status.notdiscussed` | GA-03 |
| `proposed.protection.status.unknown` | GA-03 |
| `proposed.schutz.documents_in_post` | GA-03 |
| `proposed.schutz.gap.action` | GA-03 |
| `proposed.schutz.section.areas` | GA-03 |
| `proposed.schutz.section.documents` | GA-03 |
| `proposed.schutz.stat.contracts` | GA-03 |
| `proposed.schutz.stat.contracts.sub` | GA-03 |
| `proposed.schutz.stat.premium` | GA-03 |
| `proposed.schutz.stat.premium.sub` | GA-03 |
| `runtime.value.1` | GA-04 |
| `runtime.value.10` | GA-03 |
| `runtime.value.11` | GA-04 |
| `runtime.value.12` | GA-04 |
| `runtime.value.2` | GA-02, GA-09 |
| `runtime.value.3` | GA-04 |
| `runtime.value.5` | GA-04 |
| `runtime.value.8` | GA-03 |
| `runtime.value.9` | GA-02, GA-09 |
| `ui.mission.actor.complior` | GA-02, GA-09 |
| `ui.mission.actor.insurer` | GA-02, GA-09 |
| `ui.mission.all_done` | GA-02, GA-09 |
| `ui.mission.group.done` | GA-02, GA-09 |
| `ui.mission.group.unclear_exception` | GA-03 |
| `ui.mission.group.waiting` | GA-02, GA-09 |
| `ui.mission.group.working` | GA-02, GA-09 |
| `ui.post.filter.all` | GA-04 |
| `ui.post.filter.awaiting` | GA-04 |
| `ui.post.filter.delivered` | GA-04 |
| `ui.post.filter.received` | GA-04 |
| `ui.post.filter.sent` | GA-04 |
| `ui.post.send_to_complior` | GA-04 |
| `ui.vorgaenge.last_confirmed` | GA-02, GA-09 |
| `ui.vorgaenge.next_actor` | GA-02, GA-09 |
| `ui.vorgaenge.subtitle` | GA-02, GA-09 |

Статус бейджа Mitte GA-03 — `ui.mission.group.needs_user` («Ihre Rückmeldung nötig»;
в copy_keys манифеста не числится — подставляется как {status} в шаблон
`proposed.gespraech.tab.a11y.status`; в каталоге присутствует, замер). Данные
(`fixture.vorgaenge.01–06`, `runtime.value.*`) — в model-модулях экрана, НЕ в ui-copy.
Ключи финала-2 (`ui.vorgaenge.group.*`) в каталоге 1.1 отсутствуют (замер) — их
использование запрещено (дефект PR #147, не переносится).

## 6. Замеры (команды; числа выше — из этих выводов)

```
cd /home/harness/dev-harness-projects/complior-mob/wt/wip-136-demo/docs/ux/05_Kompakt_D24
sha256sum source/tokens.json source/manifest.json source/copy-de.json frames/frames.json frames/SHA256SUMS
# пины §1: 5 строк, сверены генератором с заявленными значениями (assert 5/5)
# кадры экрана: имена из frames.json (16), sha256 каждого == записи SHA256SUMS (16/16, assert)
# карта целей: len(touch_targets[профиль]) по GA-02/03/04/09 → §4; nav y/h → §3 (assert)
# ключи копии: union(copy_keys четырёх экранов) → 65 уникальных, все в entries (264, assert)
```

Генератор этого файла: /tmp/dev-harness-verify/Arch148f/gen_spec.py (рабочая зона
оркестратора; в дереве харнесса не живёт).
