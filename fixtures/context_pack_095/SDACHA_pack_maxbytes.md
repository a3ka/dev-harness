# Сдача Б-4 — профильный предел пака

База: `c9401ac33027b8ea2be824eeffb99212bee2adad` (origin/main задания).
Основание: `docs/owner/adr/2026-11-21-plan-fable.md`, решение 2/Б-4 и решение 3.
Это лист батареи, не новая версия frozen-контракта. Дверь и резолвер не менялись.

## Существующее и граница доказательства

- `_toy.sh`: настоящие два слоя профиля и публичный CLI; `red_bjudzhet_vklejki.sh`: действующий контроль умолчания 40000; `red_orch_brief_bounded_work.sh`: целые строки WORK и явный хвост.
- `model/dover.sh`: модель прямого чтения двух слоёв (как прежде); продукт обязан пользоваться единственным `profile_resolver.sh`. Здесь модель отражает только добавленный repo-ключ и его эффект. Однократное получение эффективного капа через существующий резолвер — сверка reviewer по реализации, не обещание этой поведенческой батареи.
- `battery_stubs.sh`: существующие порчи и новые независимые Б-4 порчи; привязки реализованы кодом. Для новых порч дополнительно проверяются `bash -n` и адресная причина красноты.
- Оракулы входов/байтов/WORK снимаются в память до вызова; stdout/stderr раздельны; отказ требует rc 1, пустой stdout и отсутствующий файл манифеста. BUDGET проверяется в своей секции целиком по фактическому байтовому префиксу до MANIFEST, не по числу из самого BUDGET. Границы калибруются размером малого пака, затем независимо пересчитываются байты результата и сверяются с буквальными MAX/MAX+1.
- Конформные положительные входы: repo `pack.maxBytes` — десятичный JSON integer в [40000,1000000], отсутствие ключа — 40000; содержимое контекста и WORK соответствует прежней грамматике 095. Отрицательные лексемы передаются без нормализации JSON. Контрпример валиден при расхождении на соответствующем конформном положительном либо явно предписанном отрицательном входе, а не при аварии мутанта.

## Команды и результаты

Все команды запускались в авторской изолированной копии. Scratch:
`export TMPDIR="$PWD/.scratch-b4a"` (каталог создан до прогонов).
Существующие `_toy.sh` и стаб-пак получили только TMPDIR-маршрут перед базовым замером: старый жёсткий /tmp-путь нарушил бы изоляцию задания. Старые red-клетки не менялись.

| Команда | До Б-4 (19 клеток) | После батареи (23 клетки, дверь базы) | После реализации: ожидается |
|---|---:|---:|---:|
| `bash fixtures/_krasnye_095.sh` | 0 | 1, только четыре новых красных | 0 |
| `bash fixtures/_krasnye_095.sh --model` | 0 | 0 | 0 |
| `bash fixtures/_krasnye_095.sh --stabs` | режима не было | 0, CAUGHT=38 LIVE=0 | 0 |

| Клетка | rc двери базы | rc модели | rc после реализации |
|---|---:|---:|---:|
| `red_pack_maxbytes.sh` | 1 | 0 | 0 |
| `red_pack_maxbytes_boundary.sh` | 1 | 0 | 0 |
| `red_pack_maxbytes_values.sh` | 1 | 0 | 0 |
| `red_pack_maxbytes_brief.sh` | 1 | 0 | 0 |
| Прежние `red_*.sh` (без этих четырёх) | все 0 | все 0 | все 0 |

Новые различающие входы: большой пак с 91445-байтовым контекстом; отсутствие ключа и явный 40000 в том же мире; дополнительный 145000; точные 40000/40001 и 130000/130001; десять недопустимых лексем с зелёным повтором после каждой; неизвестный pack.foo; верхняя включённая граница 1000000; отсутствие maxBytes; полный WORK больше 39800 и меньше 129800, явное усечение при 40000 и 60000, проверка порога MAX−200.

Имена различающих входов новых стабов (исполняемая привязка и ожидаемый диагноз — только в `battery_stubs.sh`, блок `Б-4`):

| Стаб | Вход |
|---|---|
| B4-S1 | большой пак, затем тот же мир без ключа |
| B4-S2 | большой пак при 130000 |
| B4-S3 | полный WORK при 130000 |
| B4-S4 | JSON maxBytes=30000 |
| B4-S5 | JSON maxBytes="130000" |
| B4-S6 | BUDGET большого пака при 130000 |
| B4-S7 | VK=40000 при MAX=40000 |

### Сырой вывод: базовый census и результаты

Полные stdout/stderr и rc команд — в трассе вызовов автора; ниже буквальные результирующие строки (без повторяющихся строк старых порч).

```text
— red_bjudzhet_vklejki.sh: rc=0
— red_dver_spawn_manifest.sh: rc=0
— red_kontekst_doslovno.sh: rc=0
— red_manifest_razreshaetsja.sh: rc=0
— red_naznachennaja_specializacija.sh: rc=0
— red_orch_brief_bounded_work.sh: rc=0
— red_orch_brief_karta_legacy.sh: rc=0
— red_orch_brief_rabota_bez_plana.sh: rc=0
— red_orch_brief_starter.sh: rc=0
— red_poteryannaja_ssylka_tochna.sh: rc=0
— red_pravila_proekta_ne_harsa.sh: rc=0
— red_profil_dva_sloja.sh: rc=0
— red_proishozhdenie_fragmentov.sh: rc=0
— red_revjer_poluchaet_vydannoe.sh: rc=0
— red_rezhim_do_zamorozki.sh: rc=0
— red_roli_menjajut_vydachu.sh: rc=0
— red_svidetelstvo_modeli.sh: rc=0
— red_uroki_po_oblasti.sh: rc=0
— red_zony_iz_frozen_blobs.sh: rc=0
ИТОГ 095: rc=0
```

Этот набор и итог наблюдались и для real, и для `--model` до добавления Б-4.
После добавления, на неизменённой двери базы:

```text
КРАСНО: pack-maxbytes/raised: успех rc=1: ОТКАЗ: неизвестный ключ репо-слой: pack
— red_pack_maxbytes.sh: rc=1
КРАСНО: pack-maxbytes/boundary: успех rc=1: ОТКАЗ: неизвестный ключ репо-слой: pack
— red_pack_maxbytes_boundary.sh: rc=1
КРАСНО: pack-maxbytes/brief: успех rc=1: ОТКАЗ: неизвестный ключ репо-слой: pack
— red_pack_maxbytes_brief.sh: rc=1
КРАСНО: pack-maxbytes/values: нет причины 'pack.maxBytes': ['ОТКАЗ: неизвестный ключ репо-слой: pack']
— red_pack_maxbytes_values.sh: rc=1
ИТОГ 095: rc=1
```

Модель после добавления:

```text
B4 raised VK=102355 MAX=130000; default/explicit40000 refused
— red_pack_maxbytes.sh: rc=0
B4 boundary VK=40000 accepted; VK=40001 refused
B4 boundary VK=130000 accepted; VK=130001 refused
— red_pack_maxbytes_boundary.sh: rc=0
B4 brief VK=72568 full WORK; MAX=40000/60000 truncation at MAX-200
— red_pack_maxbytes_brief.sh: rc=0
B4 value "130000" refused; valid repeat accepted
B4 value 130000.5 refused; valid repeat accepted
B4 value 1e5 refused; valid repeat accepted
B4 value 0 refused; valid repeat accepted
B4 value -1 refused; valid repeat accepted
B4 value 30000 refused; valid repeat accepted
B4 value 39999 refused; valid repeat accepted
B4 value 1000001 refused; valid repeat accepted
B4 value "" refused; valid repeat accepted
B4 value null refused; valid repeat accepted
B4 values unknown refused; absent/empty-pack default; upper bound accepted
— red_pack_maxbytes_values.sh: rc=0
ИТОГ 095: rc=0
```

Отдельный `--stabs`, новый блок и итог:

```text
— стаб B4-S1 ПОЙМАН клеткой red_pack_maxbytes.sh
— стаб B4-S2 ПОЙМАН клеткой red_pack_maxbytes.sh
— стаб B4-S3 ПОЙМАН клеткой red_pack_maxbytes_brief.sh
— стаб B4-S4 ПОЙМАН клеткой red_pack_maxbytes_values.sh
— стаб B4-S5 ПОЙМАН клеткой red_pack_maxbytes_values.sh
— стаб B4-S6 ПОЙМАН клеткой red_pack_maxbytes.sh
— стаб B4-S7 ПОЙМАН клеткой red_pack_maxbytes_boundary.sh
STABS 095: CAUGHT=38 LIVE=0
ИТОГ стаб-пак 095: rc=0
```

## ЗАМЕНЯЕМЫЕ ОБЯЗАТЕЛЬСТВА frozen-текстов

Поиск `40000|39800` в двух названных контрактах дал следующие совпадения; тексты не изменены:

- `contracts/095-profil-i-vhod-agenta-contextpack.md:82` — формат `BUDGET (vklejka=N/40000)` → эффективный MAX.
- `contracts/095-profil-i-vhod-agenta-contextpack.md:104` — безусловный отказ выше 40000 и знаменатель `/40000` → отказ выше эффективного MAX и знаменатель `/MAX`; при отсутствии ключа всё прежнее сохраняется.
- `contracts/170-arch-component-brief-vhod-zadanija.md:9` — существующий потолок 40000 → эффективный MAX.
- `contracts/170-arch-component-brief-vhod-zadanija.md:29` — отказ брифа сверх 40000 → отказ сверх эффективного MAX; бриф по-прежнему учитывается в pack_body.

Дополнительно то же обязательство с пробелом в числе: `contracts/095-profil-i-vhod-agenta-contextpack.md:72`, «потолок 40 000 байт» → профильный MAX с прежним умолчанием.
Строк с `39800` в этих двух контрактах нет; это литерал прежней реализации и модели.

## Развилки и наблюдение процесса для Main

При первоначальном распространении нового `bash -n` на ВСЕ старые стабы выяснилось: существующие s2/s4/s13 синтаксически неисправны (near `else`, near `;;`, unmatched quote); предыдущий раннер засчитывал их rc 1 как поимку. Промежуточный модельный прогон поэтому дал rc 2 при всех зелёных клетках. Это другой класс отказа, не Б-4: старые порчи не переписаны; новый синтаксический/диагностический контроль применяется только к новым семи стабам. Окончательный CAUGHT=38 — вывод прежней метрики для старых 31 плюс адресное доказательство для новых семи, НЕ доказательство семантической доброкачественности старых s2/s4/s13.

Рефлексия: расширять новый предикат на прежние стабы без отдельного предмета означает незапланированную починку батареи. Для следующей пачки Main передаёт это наблюдение в общий журнал на main (здесь общий журнал и номера А-* не изменялись по запрету задания). Ловец остатка — отдельное исправление старой фабрики стабов; Б-4 не приписывает себе его устранение.

`stancija_*`, CI, предсудебные двери frozen-контракта, тесты соседних семейств и push не запускались. После реализации Main запускает реальную семью 095 и профильную регрессию 054; старые red-клетки и frozen-тексты здесь сохранены.

## Круг Б-4b — вердикт Rev095B4 (вызов 1, `13b845d263`)

База круга: ветка wip/095/orch-b4s, OBJECT `f352937cf89936a97df081ff0dd1656ed97fe3aa`.
Правки только в `fixtures/context_pack_095/` и `fixtures/_krasnye_095.sh`; дверь
(`scripts/profile_resolver.sh`, `scripts/make_task.sh`) и контракты не тронуты.

- Б-1: клетка values (`pack_maxbytes_probe.py`) и модель (`model/dover.sh`)
  переведены на семантику М-0 для `pack.<неизвестный>`: rc 0, пак с BUDGET по
  объявленному капу; модель печатает ровно одну строку «профиль
  ПРЕДУПРЕЖДЕНИЕ: неизвестный ключ репо-слой: pack.<ключ>» — дословно
  warn_unknown резолвера. Старое ожидание ОТКАЗА снято.
- Б-2 (наблюдаемое — клетка): новая `red_pack_maxbytes_merged.sh` — прямой
  вызов резолвера с раздельными потоками на профиле
  `pack={"maxBytes":130000,"rowz":1}`: rc 0, ровно одно предупреждение о
  pack.rowz, stdout merged НЕ содержит rowz, `.pack.value` — только maxBytes,
  origin repo. На базе красна (pack копируется целиком), после правки двери
  зеленеет. Режим --model судит dover.sh той же семантикой (предупреждение,
  rc 0, BUDGET/130000, ключ не влияет на выдачу).
- Б-4: новая `red_pack_maxbytes_bez_preduprezhdenija.sh` — прямой вызов
  резолвера на `pack={"maxBytes":130000}`: rc 0, 0 строк «профиль
  ПРЕДУПРЕЖДЕНИЕ», merged несёт pack.value.maxBytes=130000 origin repo; красна
  на мутанте M7 (удалён `repo:pack:maxBytes:optional`).
- Новые стабы — порчи ДВЕРИ (зона implementer; якорь по коду, Н-39):
  B4-S8 «pack копируется целиком» (якорь `\$r\.pack([^s]|$)`, sed -z; ловит
  merged-клетку) и B4-S9 = M7 (удаление строки SCHEMA_LEVELS; ловит
  bez-preduprezhdenija-клетку). S8 переписывает leaf pack merged обратно в
  whole-copy и на форме базы, и на предписанной форме с with_entries: честный
  контроль в песочнице — симуляция фикса зеленит обе клетки, S8 на фиксе
  краснит merged-клетку причиной rowz.
- Census семьи: 25 клеток; стаб-пак: CAUGHT=40 LIVE=0; раннер экспортирует
  CP095_MODE (клетки двери в --model судят модель-эталон, не реальную дверь).

### Команды и сырые rc (OBJECT f352937cf8, дверь не правлена; scratch TMPDIR внутри копии)

| Команда | rc | Наблюдение |
|---|---:|---|
| `bash fixtures/_krasnye_095.sh` до правок батареи | 1 | красна только values: «отказ rc=0» (Б-1) |
| `bash fixtures/_krasnye_095.sh` после правок батареи | 1 | красна ТОЛЬКО merged: «неизвестный ключ pack.rowz в stdout merged» (Б-2) |
| `bash fixtures/_krasnye_095.sh --model` | 0 | ИТОГ 095: rc=0, reds=0 |
| `bash fixtures/_krasnye_095.sh --stabs` | 0 | CAUGHT=40 LIVE=0, B4-S8 и B4-S9 ПОЙМАНЫ |
| `bash fixtures/context_pack_095/red_pack_maxbytes_values.sh` | 0 | Б-1 зелёна на двери базы (М-0 — уже поведение двери) |
| `bash fixtures/context_pack_095/red_pack_maxbytes_bez_preduprezhdenija.sh` | 0 | Б-4 зелёна на базе |
| `bash fixtures/_krasnye_054.sh` | 0 | «054-батарея зелёная», итог rc=0 |

После правки двери (merged.pack.value только maxBytes) ожидается rc 0 всей
батареи. Счётные строки сверены своей мерой по логам прогона: 66 строк «— » =
26 прогонов раннера + 40 ПОЙМАН стаб-пакa; красных клеток в real ровно 1
(merged), в model 0.
