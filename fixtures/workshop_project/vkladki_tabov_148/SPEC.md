# SPEC — экран 148 vkladki-tabov (таб-бар D 2.4 Kompakt), лёгкий трек: карта целей + пины

Единый источник карты экрана для набора 158 (`--ekran 148`), jest-сьютов и реализации.
Числа сняты скриптом прямо из пакета D24-Kompakt-1.1 (замер 2026-11-04, команды §6);
пакет — истина: расхождение этого SPEC с пакетом — дефект SPEC (v+1 контракта), не пакета.
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

## 3. Эталонные кадры (390 — 8 кадров пакета, имена из frames/frames.json, байты — frames/SHA256SUMS; 393 — ПРОИЗВОДНЫЕ safe-area, v6)

### 3а. Профиль 390 (kadry.json): кадры пакета

| кадр | sha256 |
|---|---|
| `GA-02_normal_dark_390x844.png` | `f9e8648c8dedb8446c0eee32b2a5105e6a6155c8f870a8c3102f206eb3ed2782` |
| `GA-02_normal_light_390x844.png` | `2d508bb14ec703530bb215c24a5b203e9ee60c3bbceb1854b4f0b0e0090559a5` |
| `GA-03_normal_dark_390x844.png` | `66b4c02273dcf04d359fd0a7feefe3362182ba68ac732858039b11d377597556` |
| `GA-03_normal_light_390x844.png` | `4d0a4c0d981e9936920955a4beb2da8be52e414c4026519a86c706946947aa17` |
| `GA-04_normal_dark_390x844.png` | `087a17167b58fce478d384e2c62fc36cda92f61edf93a476dff3298298f8de0b` |
| `GA-04_normal_light_390x844.png` | `ac9dd85c4326b912979c02baabdae09de63dd62ed6efd1dc5bfabd0b56736bcb` |
| `GA-09_normal_dark_390x844.png` | `86f884df687fa4d6fdc88f815e6101ad2c7aa69af2e2a95801de9dcef79f0f4c` |
| `GA-09_normal_light_390x844.png` | `d29692de3533bfba75fe5a9d8e0a78017b343c0a8d2ea83c9f861074acc8e47e` |

### 3б. Профиль 393 (kadry_profil.json): ПРОИЗВОДНЫЕ эталоны safe-area (v6 — слово владельца 2026-11-22 ~10:53; v6c ВАРИАНТ Б — слово владельца 22.11 ~14:35)

Эталон 393 = D24-390 + системные полосы 393 с ПОЭКРАННЫМ удалением ровно
85 измеренных пустых строк полотна основы (НЕпустой контент 1:1, в том же
порядке, без ресэмплинга). Арифметика: полотно 844−49=795 строк, зона
полотна кадра 852−59−34−49=710, 844+59+34=937>852 — дефицит 85 закрыт
пустыми строками (СЛОВО ВЛАДЕЛЬЦА 22.11 ~14:35: «148 v6: допускаю
поэкранное удаление 85 измеренных пустых строк в производных эталонах 393
(контент 390 сохраняется 1:1 по непустым строкам); порог 0.600 и маска 48
без изменений»). Построение ДЕТЕРМИНИРОВАННО: построитель
`fixtures/workshop_project/vkladki_tabov_148/etalony_safe_area/postroit.py`
(константы — только из оракула source.json: vyrez 59 / домашняя полоса 34 /
nav.height 49 / полоса 390 36 / рамка 393×852), манифест
`etalony_safe_area/manifest.json` (provenance: источники-основы + sha,
ПРАВИЛО и удалённые диапазоны на каждый кадр, операции, версии
инструментов, mera 48/20, porog 0.6); перестройка `--proverit` — rc 0,
байты совпадают.

Правило выбора 85 строк (вычислимо ТОЛЬКО из основы и констант, без
подгонки под выход; оно же — `manifest.json.pravilo_udalenija`):

1. строка полотна основы (0..794) пустая ⟺ все её пиксели равны фоновому
   пикселю (0,0) ОСНОВЫ (поэкранная мера; замер: GA-02/09 — по 238 пустых
   и 557 непустых, GA-03 — 302/493, GA-04 — 218/577; вторая мера —
   яркость: дисперсия выбранных строк 0.0);
2. пустые прогоны упорядочиваются по убыванию длины (равенство —
   меньший y), из прогона строки берутся СВЕРХУ ВНИЗ, бюджет 85 на кадр;
3. внутренний прогон (обе соседние строки непустые) оставляет ≥ 1 строку —
   соседние содержательные блоки не сливаются; краевые прогоны (y=0 / низ
   полотна) ограничения не несут. Пример (GA-02 light): удалены прогоны
   y 40..68, 114..142, 354..380 (29+29+27 = 85).

«Ровно 85 и все пустые» наблюдаемо как: зона полотна ровно 710 строк +
все непустые строки основы в ней — судит НЕЗАВИСИМЫЙ оракул
`etalony_safe_area/orakul_soderzhanija.py` (другой код, не построитель:
кодек движка probe.py — у построителя produkt_sud.py, своя мера пустоты и
геометрия, построитель не импортируется; клетки батареи etalon-393-*,
стабы s102–s106): (i) непустая последовательность основы == эталона,
строка за строкой, порядок сохранён (утеря/чужая/дубликат/сдвиг порядка —
именованные детали ETALON_393_SODERZHANIE_UTRACHENO); (ii) ровно 85
удалённых, все пустые (следствие геометрии); (iii) якоря GA-03 light/dark:
строки 19–35 (логотип/профиль) и 759–771 («Dokumente») присутствуют
(ETALON_393_JAKOR_UTRACHEN; якорь обязан быть непустым в самой основе);
(iv) между соседними блоками с пустым промежутком остаётся ≥ 1 пустая
строка (ETALON_393_BLOKI_SLITY); (v) лейсте 795..843 → 769..817 байт-в-байт
(ETALON_393_LEISTE); (vi) вырез/домашняя полоса/столбцы 390..392 — фон;
(vii) часовой значений: mera.chrome_verh_pt == 48, chrome_niz_pt == 20,
porog == 0.600, konstanty == source.json (ETALON_393_MASKA_NE_48 /
_NIZ_NE_20 / _POROG_NE_0_600 / _MANIFEST_KONSTANTY).

implementer кладёт файлы в `mobile/etalony-vkladki-393/`, байты == выводу
построителя, sha256 — из манифеста:

| кадр | sha256 |
|---|---|
| `GA-02_normal_dark_393x852.png` | `8c6678d9a227259bfcb490a4ebbf592ccea24689322f980711d1bbf132bebd1f` |
| `GA-02_normal_light_393x852.png` | `178dad600ff67062b964edaf0fd5d4acbe687a53d9f5b3fbff01a18b33b6e1f9` |
| `GA-03_normal_dark_393x852.png` | `e393571077385cfdce3f1b1a852caf1ad2a37a35388a12218e5b94f9109abac2` |
| `GA-03_normal_light_393x852.png` | `0a7eb55a5fa6743da25f177d6dd78deb31904325c18c312687e35c07f82781cb` |
| `GA-04_normal_dark_393x852.png` | `c92247a2e11d3ba43a72ac38598432620e469a4824d0ee21b1fb3d2eead98ab4` |
| `GA-04_normal_light_393x852.png` | `1a22679eeb7723d5a87ac41f7e70ee1945825a49d7b2fbf0fb81fe213bf33bac` |
| `GA-09_normal_dark_393x852.png` | `98682aaad849067bef0982aaa1532e919f1cdf6ad54009659a352c1b093603a3` |
| `GA-09_normal_light_393x852.png` | `6a7638d25b3b0adbe56c05b28d4a46d9c015344038b623aafcd3e0dad40554ec` |

Кадры пакета 393 (`*_393x852.png` в frames/, нарисованы дизайнером без
системных полос) эталоном для kadry_profil.json НЕ являются (v6; до v6
таблица пинила их — снимок таблицы v5 в истории контракта).

Геометрия лейсте по манифесту (все четыре экрана состояния): 390×844 — y 795, h 49;
393×852 — y 769, h 49 (`nav.height`; вырез 59 / домашняя полоса 34 — карта
vtoroj_profil: шапка y59, лейсте y769); полотно основы — в строки
59..768 после удаления 85 пустых; слоты вкладок 78×48 (390) / 79×48 (393)
(`nav.item.min-height` 48).

Сверка — раннер 123, порог 0.600 У КАЖДОЙ записи (без ослабления — v6;
v6c: маска 48 и порог не меняются — слово владельца 22.11 ~14:35).
Маски системного хрома в манифестах пачки (kadry.json — 390,
kadry_profil.json — 393): шапка chrome_verh_pt 36 (390, пилюли нет) /
48 (393 — пилюля Dynamic Island x133–258, y11–47, слово владельца 31.10;
производный эталон полос не несёт — строка статуса эмулятора и пилюля
закрываются маской 48, при 36 сверка красна — v6c-снимок: семь записей,
GA-09 dark при новых эталонах проходит порог); низ chrome_niz_pt 20
(пилюля home-индикатора y839–843). Имя записи кадра в kadry*.json обязано
соответствовать её идентификатору (GA-02 dark → кадр GA-02; класс 5
перечня: подмена соседним кадром — отказ; байт производного эталона не из
манифеста — ETALON_393_NE_PROIZVODNYJ, porog ≠ 0.600 — POROG_NE_0_600).

Граница пиксельной наблюдаемости (v6c): удаление пустой строки СВЕРХ 85
внутри многорядного разделителя неотличимо от честного выбора 85 (зона
710 + сохранение всех непустых форсируют ровно 85 отсутствующих пустых);
ловцы — manifest.json.udalennye_diapazony (сумма 85, строки пусты в
основе — сверяет ревьюер) и код построителя (детерминизм --proverit).

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
# кадры экрана 390: имена из frames.json (8), sha256 == записи SHA256SUMS (8/8, assert);
# производные 393 (v6): sha256 каждого == etalony_safe_area/manifest.json (8/8, assert),
# перестройка postroit.py --proverit — rc 0 (детерминизм, assert батареей --model)
# карта целей: len(touch_targets[профиль]) по GA-02/03/04/09 → §4; nav y/h → §3 (assert)
# ключи копии: union(copy_keys четырёх экранов) → 65 уникальных, все в entries (264, assert)
```

Генератор этого файла: /tmp/dev-harness-verify/Arch148f/gen_spec.py (рабочая зона
оркестратора; в дереве харнесса не живёт).
