FAIL
OBJECT=bfd42927b4e55824d32cd6e635fb2b4544d4a818
СУД: repo=dev-harness; предмет=148; фаза=контракт v+1 (+красная батарея); роль=critic; цикл 2, вызов=3/5; модель-план=openai-codex/gpt-6-sol; сессия=Crit148k2c (UUID трейса судье недоступен); модель-факт=openai-codex/gpt-6-sol (workstation); SHA=bfd42927b4e55824d32cd6e635fb2b4544d4a818; предыдущий=verdicts/critic/contracts-148-v3b-fail.md; исключение=нет.

`git cat-file -t OBJECT` → `commit`; checkout OBJECT в изолированном `/tmp/dev-harness-verify/Crit148k2c/repo`. `git diff 275a6dfce bfd42927b -- contracts fixtures/workshop_project/vkladki_tabov_148/`: 10 файлов (+719/−131), дельта ОТ РОДИТЕЛЯ. `git show -s --format=%B bfd42927b` → второй абзац дословно `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/148-vkladki-tabov.md — v+1 под компактную шкалу по пакету D24-Kompakt-1.1: заменяются версия пакета, токены и эталонные кадры; поведение, обязательства и доступность не ослабляются; цели касания судятся по зоне hw/hh, видимый размер < 44 при зоне ≥ 44 находкой не является (слово владельца 2026-11-02)`. Автор GLM zai/glm-5.3 по заданию/HANDOFF, судья Sol; авторского дерева не правил. Предмет/rc-критерии/исполнители с ЗОНА/класс риска/модель угроз имеются. Сопоставление к frozen/contracts/148/1: И-1…И-10 сохранены и расширены И-11/И-12, приёмки 1…10 → 1…16; маски Notice GA-03 сняты после каталогизации 1.1, маска системной шапки 393=48 и последовательный AVD 5570→5576 оставлены. Исключение фоновой остановки из прежнего вердикта объявлено в НЕ ЗАЩИЩАЕТ, не засчитывается закрытием.

## Блокирующие классы

БЛОКИРУЕТ contracts/148-vkladki-tabov.md:59,62,81,85,228-230 — И-4 требует, чтобы **каждая** обязательная цель Post нажималась и доходила до колбэка, а И-7/приёмка 8 заявляют исполняемый суд целей. Класс причины: `produkt/vkladki-zond-148.test.tsx:376-408,452-471` ищет хотя бы один *предыдущий* вызов общего mock `onFiltr` с аргументом `all`; `post-filtr-alle` нажимается раньше `post-filtr-nastrojki`, оба имеют аргумент `all`. Последняя цель проходит без собственного события. ОБЯЗАТЕЛЬСТВО: рабочее действие Filter/настройки фильтра при наличии и корректной зоне цели. СОСТОЯНИЕ: в полной копии зелёного R оставить `post-filtr-alle` неизменным, заменить единственную строку `onPress={() => onFiltr?.(filtr)}` у `Pressable testID="post-filtr-nastrojki"` на `onPress={() => {}}`; прочие компоненты, кадры, размеры, среда и пины прежние. НАБЛЮДЕНИЕ: `produkt_sud.py --repo R_mut` rc 0, контроль suites=1 tests=15, восемь мутантов убиты; нажатие Filter ничего не вызывает. ОБХОД: отключённое действие Filter при зелёной приёмке действующей цели. ЗАКРЫВАЮЩЕЕ СВОЙСТВО: каждое обязательное нажатие доказывает СОБСТВЕННЫЙ ожидаемый вызов/переход независимо от предыдущих нажатий иных целей с тем же аргументом; честный R зелёный, одиночный no-op Filter красный. Нужен красный тест этого класса ДО заморозки.

БЛОКИРУЕТ contracts/148-vkladki-tabov.md:40,62,85,228,251 — И-7 и слово владельца требуют судить **эффективную** зону касания, не конкретное написание стиля; приёмка 8/контроль zona заявляют отсутствие ложного отказа для реальной зоны ≥44. Класс причины: `produkt/vkladki-zond-148.test.tsx:136-165` считает `paddingTop`/`paddingBottom`/`paddingVertical`, но пропускает стандартное RN-свойство `padding`. ОБЯЗАТЕЛЬСТВО: зелёный исход для конформной фактической зоны ≥44, в том числе образованной padding. СОСТОЯНИЕ: в полной копии честного R заменить только стиль `filtrKnopka: { alignItems: 'flex-start', justifyContent: 'center', minHeight: 44 }` на тот же стиль с `padding: 22` вместо minHeight (или `padding: 16`: текст `Filter` имеет fontSize 14, суммарная вертикальная зона больше 44), Filter остаётся Pressable с прежним колбэком, два вертикальных padding по 22 уже дают 44 pt до текста. НАБЛЮДЕНИЕ: `produkt_sud.py --repo R_padding` и `--repo R_padding16` оба rc 1 `ISPOLNIMYJ_KONTROL_KRASEN … (упавших ассертов 2)`, тогда как тот же R без замены rc 0. ЗАКРЫВАЮЩЕЕ СВОЙСТВО: эффективный бокс учитывает валидные способы RN задания padding; реальная зона ≥44 остаётся зелёной, зона 36 и отключённая цель красны. Не предписывается единственный способ расчёта. Физическая зона по RN-семантике padding — вывод по допустимому стилю, не притворяется замером эмулятором.

## Сырые атаки в одноразовых копиях (кандидат/авторский R не изменены)

Команда `cp -a /tmp/dev-harness-verify/Arch148t/mob-ref /tmp/dev-harness-verify/Crit148k2c/mob-filter; python3 /tmp/dev-harness-verify/Crit148k2c/filter_attack.py && python3 fixtures/workshop_project/vkladki_tabov_148/produkt_sud.py --repo /tmp/dev-harness-verify/Crit148k2c/mob-filter` → **rc 0**:
```text
MUTATED /tmp/dev-harness-verify/Crit148k2c/mob-filter/mobile/src/features/post/components/PostEingang.tsx: Filter action removed, all other actions unchanged
KADR	GA-02 dark	1.000	0.600	G	OK
KADR	GA-02 light	1.000	0.600	G	OK
KADR	GA-03 dark	1.000	0.600	G	OK
KADR	GA-03 light	1.000	0.600	G	OK
KADR	GA-04 dark	1.000	0.600	G	OK
KADR	GA-04 light	1.000	0.600	G	OK
KADR	GA-09 dark	1.000	0.600	G	OK
KADR	GA-09 light	1.000	0.600	G	OK
SHABLON	vkladki	OK
ISPOLNIMYJ kontrol ZELEN — suites=1 tests=15
ISPOLNIMYJ kontrol svjaz ZELEN — nav.height 49px→51px, nav.item.min-height 48px→50px, nav.label.font-size 10px→12px, nav.label.line-height 12px→14px (высота лейсте и minHeight вкладок следуют за источником)
ISPOLNIMYJ kontrol zona ZELEN — height:36+minHeight:44 принята (эффективная зона 44 по правилам RN: minHeight — пол)
ISPOLNIMYJ mutant tabs UBIT — упавших ассертов 11
ISPOLNIMYJ mutant badge UBIT — упавших ассертов 1
ISPOLNIMYJ mutant skroll UBIT — упавших ассертов 1
ISPOLNIMYJ mutant kasanie UBIT — упавших ассертов 2
ISPOLNIMYJ mutant tokeny UBIT — упавших ассертов 1
ISPOLNIMYJ mutant nav-final2 UBIT — упавших ассертов 1
ISPOLNIMYJ mutant nav-literal UBIT — упавших ассертов 1
ISPOLNIMYJ mutant disabled UBIT — упавших ассертов 1
```
Команда `cp -a /tmp/dev-harness-verify/Arch148t/mob-ref /tmp/dev-harness-verify/Crit148k2c/mob-padding; python3 /tmp/dev-harness-verify/Crit148k2c/padding_attack.py && python3 fixtures/workshop_project/vkladki_tabov_148/produkt_sud.py --repo /tmp/dev-harness-verify/Crit148k2c/mob-padding` → **rc 1**:
```text
MUTATED /tmp/dev-harness-verify/Crit148k2c/mob-padding/mobile/src/features/post/components/PostEingang.tsx: equivalent >=44 touch height by padding 22+22, filter action intact
KADR	GA-02 dark	1.000	0.600	G	OK
KADR	GA-02 light	1.000	0.600	G	OK
KADR	GA-03 dark	1.000	0.600	G	OK
KADR	GA-03 light	1.000	0.600	G	OK
KADR	GA-04 dark	1.000	0.600	G	OK
KADR	GA-04 light	1.000	0.600	G	OK
KADR	GA-09 dark	1.000	0.600	G	OK
KADR	GA-09 light	1.000	0.600	G	OK
SHABLON	vkladki	OK
ISPOLNIMYJ kontrol KRASEN — suites=1 tests=15
PRICHINA	ISPOLNIMYJ_KONTROL_KRASEN: зонд красен на исходных компонентах R (упавших ассертов 2)
```
Команда `cp -a /tmp/dev-harness-verify/Arch148t/mob-ref /tmp/dev-harness-verify/Crit148k2c/mob-padding16; python3 /tmp/dev-harness-verify/Crit148k2c/padding16_attack.py && python3 fixtures/workshop_project/vkladki_tabov_148/produkt_sud.py --repo /tmp/dev-harness-verify/Crit148k2c/mob-padding16` → **rc 1**:
```text
MUTATED /tmp/dev-harness-verify/Crit148k2c/mob-padding16/mobile/src/features/post/components/PostEingang.tsx: content fontSize 14 plus 16+16 vertical padding >=46, action intact
KADR	GA-02 dark	1.000	0.600	G	OK
KADR	GA-02 light	1.000	0.600	G	OK
KADR	GA-03 dark	1.000	0.600	G	OK
KADR	GA-03 light	1.000	0.600	G	OK
KADR	GA-04 dark	1.000	0.600	G	OK
KADR	GA-04 light	1.000	0.600	G	OK
KADR	GA-09 dark	1.000	0.600	G	OK
KADR	GA-09 light	1.000	0.600	G	OK
SHABLON	vkladki	OK
ISPOLNIMYJ kontrol KRASEN — suites=1 tests=15
PRICHINA	ISPOLNIMYJ_KONTROL_KRASEN: зонд красен на исходных компонентах R (упавших ассертов 2)
```

## Промер и механическая сверка

- `bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh` → rc 1, `клеток 57, зелёных 37, красных 20` (`PACHKA_ABSENT` в дереве харнесса); `… --model` → rc 0, `57/57/0`; `… --model --seed 7` → rc 2, `error: unrecognized arguments: --seed 7`; `… --oracle-tamper` → rc 2, `error: unrecognized arguments: --oracle-tamper` (оба режима не объявлены CLI probe.py).
- `… --stabs` → rc 0, контроль 57/57, все s65–s94 KRASEN, `SVJAZI 47`, живых 0; `… --repo /tmp/dev-harness-verify/Arch148t/mob-ref` → rc 0, `37/37/0`; `python3 …/produkt_sud.py --repo /tmp/dev-harness-verify/Arch148t/mob-ref` как контроль предыдущих атак → rc 0, KADR×8 1.000, Jest suites=1 tests=15 с двумя зелёными контролями и восемью убитыми мутантами (прямой контрольный запуск из изолированного клона вернул rc 0: KADR×8 1.000, SHABLON OK, suites=1 tests=15, svjaz/zona ZELEN и восемь мутантов UBIT).
- `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model` → rc 0, все напечатанные CASE ok.
- `bash scripts/pre_critic.sh contracts/148-vkladki-tabov.md` → rc 0 `КРИТИК: дверь зелёная`; `bash scripts/check_ceilings.sh` → rc 0 `потолки в порядке`; `bash scripts/check_precision_gate.sh . contracts/148-vkladki-tabov.md` → rc 0 `OK`; `bash scripts/check_threat_model.sh . contracts/148-vkladki-tabov.md` → rc 0 `ЗАЩИЩАЕТ 14 … НЕ ЗАЩИЩАЕТ 12`; `bash scripts/check_spec_ready.sh . contracts/148-vkladki-tabov.md` → rc 0 `OK`; `bash scripts/check_provodka.sh . contracts/148-vkladki-tabov.md` → rc 1 `guard не подключён` (зона orchestrator после freeze). `bash scripts/check_zones.sh .` первый раз timeout 180 s, повтор завершён за 413.56 s: `замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 42908 · проверено по зонам: 10241`, `ОТКАЗ`/«коммит вне зоны» отсутствуют, код возврата фонового задания proc://bg_54 инструмент явно не показывает (rc 0 выводится из условного завершения скрипта при отсутствии отказов).
- `git -C /tmp/dev-harness-verify/Impl151/mob merge-base --is-ancestor d4aa406 origin/main` → rc 0; пакет origin/main и d4aa406 имеют один tree `dbdf5c418e02f830c58267c54aeaaeca31681d0e`; SHA256 трёх носителей `frames.json`, `SHA256SUMS`, `manifest.json` совпали с `git show origin/main:docs/ux/05_Kompakt_D24/...`; `sha256sum --quiet -c SHA256SUMS` в продуктовом референсе → rc 0, 190 строк; `frames.json._meta.summary` → screens/full/partial/frames = 46/46/0/188; продуктовый `source/tokens.json` → 265 `$value`, 264 `$type`, 84 `final2`; `_meta.audit.targets=699, under_44=0, screens=46`. Носители 1.1/Final2 = 1 261 038/923 860 Б, файлы свода 18 360/66 996/217 883 Б; пин модели 146 и jest-зонда совпал с `source.json`.
- `jq '[ (.kejsy|length), (.stab_vhod|length), ([.kejsy[].rc] | group_by(.) | map({rc:.[0], n:length})) ]' fixtures/workshop_project/vkladki_tabov_148/source.json` → 57,30, rc0=2/rc1=48/rc2=7. Проверено 19 контентных целей действия/зоны + пять слотов лейсте = 24; пин Final2 и подмена GA-02→GA-04 красны в клетках `paket-final2`/`kadry-podmenen` при `W --model`. Новая сводка со свежей зоной выше не равна историческим 40397/9567 из задания, но контракт их НЕ утверждает. Счётных расхождений САМООПИСАНИЕ в тексте кандидата не выявлено.

НЕ проверено: настоящий Android AVD/Maestro, native build, PR/dispatch CI по тому же SHA, пиксельный рендер изменённых экранов на телефоне; они остаются условиями реализации/заморозки, не выдаются за зелёные. Физический размер padding-вариантов основан на RN-семантике свойства, а не эмуляторном измерении. Порчу оракула физической правкой пинов не запускал: режим `--oracle-tamper` отсутствует. Авторский отчёт `/tmp/dev-harness-verify/Arch148u/report.md` отсутствовал — авторским числам не доверял, перемерил самостоятельно. Ни основной репозиторий, ни авторский OBJECT не менялись; вердикт оставлен оркестратору для внесения в main.
