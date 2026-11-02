FAIL
OBJECT=26c89441a1a2cd6552cd46177d3e5b993521d130
СУД: repo=dev-harness; предмет=148; фаза=контракт v+1 (+красная батарея); роль=critic; цикл 2, вызов 2/5; модель-план=openai-codex/gpt-6-sol; сессия=Crit148k2b (UUID трейса недоступен судье); модель-факт=openai-codex/gpt-6-sol (workstation); SHA=26c89441a1a2cd6552cd46177d3e5b993521d130; предыдущий=verdicts/critic/contracts-148-v3a-fail.md (цикл 2, 1/5); исключение=санкция вызова 2/5 в HANDOFF.md:1.

`git cat-file -t OBJECT` → commit; checkout OBJECT в отдельном клоне `/tmp/dev-harness-verify/Crit148k2b/repo`. Автор Arch148r/s — GLM zai/glm-5.3 по отчётам, судья — Sol; независимость соблюдена. `git show -s --format=%B` коммитов 5e3a706c2 и OBJECT показывает по одной строке РАЗРЕШИЛ с буквальным `contracts/148-vkladki-tabov.md` первым. Дельта исправления `git diff 5e3a706c2 26c89441a -- contracts/148-vkladki-tabov.md fixtures/workshop_project/vkladki_tabov_148/` — 14 файлов. Frozen 148/1: И-1…И-10/приёмки 1…10 сопоставлены с И-1…И-12/приёмками 1…16; порядок AVD 5570→5576 и маска 48 из решения 31.10 сохранены, маска Notice GA-03 снята по каталогу 1.1. Имя кадра конкретного GA/темы/профиля (предыдущий Б1) теперь проверяют оба судьи; Final2-пин краснеет гейтом. Предыдущие Б2/Б3 закрыты лишь для пяти перечисленных тестовых мутаций, но не для допустимых состояний ниже.

## Содержательные классы

БЛОКИРУЕТ contracts/148-vkladki-tabov.md:19,38,65,79,83,227 — И-12 требует **потребления именованных токенов 1.1 реальным экраном**, а не правильного соседнего JSON при совпадении нескольких чисел. Класс причины: зонд сравнивает подписи и minHeight с тремя значениями, но не доказывает связь компонента с источником и не проверяет `nav.height`; стенд-ин кадры не получены рендером компонента. ОБЯЗАТЕЛЬСТВО: заданные пакетом токены навигации, включая `nav.height` `$value=49px` (Final2=71px), определяют рабочую геометрию. СОСТОЯНИЕ: честная модель уже содержит литералы `tabLabel: { fontSize: 10, lineHeight: 12 }`, `minHeight: 48` без чтения токенов (`model/produktnaja-raskladka/mobile/src/bootstrap/tab-shell.tsx:385-402`); в её полной одноразовой продуктовой копии рабочему `tabbarBg` добавлено `height:71`, старое значение nav.height; файлы пакета/пины не менялись. НАБЛЮДЕНИЕ: `produkt_sud --repo R` rc0, KADR×8 1.000, Jest 11/11 и пять убитых мутантов; `W --repo R` 37/37 rc0 (вывод ниже). ОБХОД: старую высоту лейсте принимают как Kompakt, сравнив только текст/высоту цели. ЗАКРЫВАЮЩЕЕ СВОЙСТВО: реальные значения навигации привязаны к именованным токенам 1.1 и подмена любого обязательного значения на Final2 (в частности 49→71) краснит приёмку, честный экран зелёный; совпавший литерал без связи с токеном не доказывает потребление.

БЛОКИРУЕТ contracts/148-vkladki-tabov.md:57,60,79,83,222 — И-4/И-7 требуют действующие цели вкладок, не только testID и достаточную высоту. Класс причины: зонд `getByTestId` читает стиль/hitSlop, но не проверяет доступность Pressable для нажатия (`disabled`) и не нажимает обязательные цели контента. СОСТОЯНИЕ: в полном R добавлена единственная строка `disabled` у `Pressable testID="schutz-optionen"` («Optionen ansehen», GA-03); размеры/кадры/пины прежние. НАБЛЮДЕНИЕ: `produkt_sud --repo R` rc0, 11/11 и пять мутантов убиты, `W --repo R` 37/37 rc0. ОБХОД: цель видна и имеет декларацию зоны ≥44, но нажать её нельзя. ЗАКРЫВАЮЩЕЕ СВОЙСТВО: каждая из заявленных 24 целей на обоих профилях остаётся действующим интерактивным элементом с реальной зоной; отключение любой без изменения testID/стиля краснит приёмку.

БЛОКИРУЕТ contracts/148-vkladki-tabov.md:40,60,83,222 — И-7 и слово владельца 02.11 разрешают любую **реальную** зону ≥44, не только приоритет определённого поля StyleSheet. Класс причины: `zonaCelej` выбирает `height` вместо `minHeight`, если оба существуют, и ошибочно принимает видимую высоту за hit-area; ограничение минимальной высоты не учитывается. ОБЯЗАТЕЛЬСТВО: фактическая зона ≥44 остаётся зелёной, фактическая зона 36 краснеет. СОСТОЯНИЕ: у `post-filtr-nastrojki` полное R вместо `minHeight:44` содержит `height:36, minHeight:44`: RN минимальная высота сохраняет фактическую зону не менее 44. НАБЛЮДЕНИЕ: `produkt_sud --repo R` rc1 `ISPOLNIMYJ_KONTROL_KRASEN` с двумя упавшими ассертами, базовый R rc0. ЗАКРЫВАЮЩЕЕ СВОЙСТВО: мерить эффективную hit-area с учётом minHeight/height/hitSlop: действительно 36 красно, при двух полях и эффективной зоне ≥44 зелено.

## Атаки: команда и сырой вывод

Режимы одноразового `/tmp/dev-harness-verify/Crit148k2b/attack.py`: замена ровно одной строки полной побайтовой копии `/tmp/dev-harness-verify/Arch148r/mob-ref` (node_modules установлен); все изменённые копии и скрипт удалены после замеров. В командах ниже `R` — абсолютный путь `/tmp/dev-harness-verify/Crit148k2b/mob-mut-nav`, `/tmp/dev-harness-verify/Crit148k2b/mob-mut` либо `/tmp/dev-harness-verify/Crit148k2b/mob-mut-valid` соответственно; команды исполнены из клона кандидата.

`python3 /tmp/dev-harness-verify/Crit148k2b/attack.py nav-final2 /tmp/dev-harness-verify/Crit148k2b/mob-mut-nav && python3 fixtures/workshop_project/vkladki_tabov_148/produkt_sud.py --repo /tmp/dev-harness-verify/Crit148k2b/mob-mut-nav; echo rc=$?`:
```text
nav-final2 /tmp/dev-harness-verify/Crit148k2b/mob-mut-nav/mobile/src/bootstrap/tab-shell.tsx mutated
KADR	GA-02 dark	1.000	0.600	G	OK
KADR	GA-02 light	1.000	0.600	G	OK
KADR	GA-03 dark	1.000	0.600	G	OK
KADR	GA-03 light	1.000	0.600	G	OK
KADR	GA-04 dark	1.000	0.600	G	OK
KADR	GA-04 light	1.000	0.600	G	OK
KADR	GA-09 dark	1.000	0.600	G	OK
KADR	GA-09 light	1.000	0.600	G	OK
SHABLON	vkladki	OK
ISPOLNIMYJ kontrol ZELEN — suites=1 tests=11
ISPOLNIMYJ mutant tabs UBIT — упавших ассертов 8
ISPOLNIMYJ mutant badge UBIT — упавших ассертов 1
ISPOLNIMYJ mutant skroll UBIT — упавших ассертов 1
ISPOLNIMYJ mutant kasanie UBIT — упавших ассертов 2
ISPOLNIMYJ mutant tokeny UBIT — упавших ассертов 1
rc=0
```
`python3 /tmp/dev-harness-verify/Crit148k2b/attack.py disabled /tmp/dev-harness-verify/Crit148k2b/mob-mut && python3 fixtures/workshop_project/vkladki_tabov_148/produkt_sud.py --repo /tmp/dev-harness-verify/Crit148k2b/mob-mut; echo rc=$?`:
```text
disabled /tmp/dev-harness-verify/Crit148k2b/mob-mut/mobile/src/features/protection/components/SchutzUebersicht.tsx mutated
KADR	GA-02 dark	1.000	0.600	G	OK
KADR	GA-02 light	1.000	0.600	G	OK
KADR	GA-03 dark	1.000	0.600	G	OK
KADR	GA-03 light	1.000	0.600	G	OK
KADR	GA-04 dark	1.000	0.600	G	OK
KADR	GA-04 light	1.000	0.600	G	OK
KADR	GA-09 dark	1.000	0.600	G	OK
KADR	GA-09 light	1.000	0.600	G	OK
SHABLON	vkladki	OK
ISPOLNIMYJ kontrol ZELEN — suites=1 tests=11
ISPOLNIMYJ mutant tabs UBIT — упавших ассертов 8
ISPOLNIMYJ mutant badge UBIT — упавших ассертов 1
ISPOLNIMYJ mutant skroll UBIT — упавших ассертов 1
ISPOLNIMYJ mutant kasanie UBIT — упавших ассертов 2
ISPOLNIMYJ mutant tokeny UBIT — упавших ассертов 1
rc=0
```
`python3 /tmp/dev-harness-verify/Crit148k2b/attack.py valid-zone /tmp/dev-harness-verify/Crit148k2b/mob-mut-valid && python3 fixtures/workshop_project/vkladki_tabov_148/produkt_sud.py --repo /tmp/dev-harness-verify/Crit148k2b/mob-mut-valid; echo rc=$?`:
```text
valid-zone /tmp/dev-harness-verify/Crit148k2b/mob-mut-valid/mobile/src/features/post/components/PostEingang.tsx mutated
KADR	GA-02 dark	1.000	0.600	G	OK
KADR	GA-02 light	1.000	0.600	G	OK
KADR	GA-03 dark	1.000	0.600	G	OK
KADR	GA-03 light	1.000	0.600	G	OK
KADR	GA-04 dark	1.000	0.600	G	OK
KADR	GA-04 light	1.000	0.600	G	OK
KADR	GA-09 dark	1.000	0.600	G	OK
KADR	GA-09 light	1.000	0.600	G	OK
SHABLON	vkladki	OK
ISPOLNIMYJ kontrol KRASEN — suites=1 tests=11
PRICHINA	ISPOLNIMYJ_KONTROL_KRASEN: зонд красен на исходных компонентах R (упавших ассертов 2)
rc=1
```
Обе дополнительные команды `bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh --repo /tmp/dev-harness-verify/Crit148k2b/mob-mut; echo rc=$?` и `bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh --repo /tmp/dev-harness-verify/Crit148k2b/mob-mut-nav; echo rc=$?` независимо выдали один и тот же сырой stdout:
```text
CASE chestnyj-vkladki ok
CASE shablon-otsvtstvuet ok
CASE shablon-2-s-ga-kadrami ok
CASE priemka-bez-prokhoda ok
CASE prokhodimost-otsvtstvuet ok
CASE vtoroj-profil-otsvtstvuet ok
CASE maket-podmenen ok
CASE kadr-nizhe-poroga ok
CASE kadr-ustarevshij ok
CASE e2e-ne-proshla ok
CASE chuzhoj-kadr ok
CASE stroka-bez-izmenenija ok
CASE kasanie-menshe-normy ok
CASE kasanie-v-safe-zone ok
CASE demo-v-sostave ok
CASE demo-bez-otdelenija ok
CASE povtor-id ok
CASE profil-nizhe-minimuma ok
CASE profil-bez-insetov ok
CASE odna-tema ok
CASE profil-maska-36 ok
CASE profil-maska-ne-48 ok
CASE paket-final2 ok
CASE kadry-podmenen ok
CASE marshrut-bez-obolochki ok
CASE marshrut-bez-snimka ok
CASE prokhod-ne-maestro ok
CASE prokhod-bez-pressable ok
CASE prokhod-ne-proshla ok
CASE literal-cveta ok
CASE kljuch-bez-kataloga ok
CASE scenarij-bez-snimka ok
CASE zony-rashodjatsja ok
CASE perehod-lishnij ok
CASE istochnik-ne-sovpadaet ok
CASE istochnik-otsutstvuet ok
CASE pr-chestnaja ok
клеток 37, зелёных 37, красных 0
rc=0
```

## САМООПИСАНИЕ — полный список обнаруженных механических расхождений

- contracts/148-vkladki-tabov.md:13: заявлена «дословная строка [глоб `contracts/147-*.md contracts/148-*.md contracts/149-*.md`] во втором -m коммита этой правки» → фактический второй абзац OBJECT и 5e3a706c2 начинается **литералом** `contracts/148-vkladki-tabov.md`; разрешение по механике корректно, неверна только ссылка на побайтовую цитату.
- contracts/148-vkladki-tabov.md:27: «зонд 4 теста, три мутанта» → текущий `produkt_sud` suites=1 **tests=11**, **пять** мутантов tabs/badge/skroll/kasanie/tokeny; упавшие ассерты 8/1/1/2/1.
- contracts/148-vkladki-tabov.md:75: «27 обманных стабов» → `source.json.stab_vhod` **29** (s65–s93); конец той же строки (29, SVJAZI 46) корректен.
- contracts/148-vkladki-tabov.md:233: «зонд измеряет ТРИ исполняемых измерения» → теперь добавлены зоны и токены, **пять** именованных осей, 11 тестов.
- ВНЕ контракта: база задания «40397 коммитов/9567 зон» и отчёта Arch148s «42585/10146» → в этом OBJECT-клоне **42604/10165**, замороженных контрактов **148** (моменты истории различны; не блок договора). Цифра `0.441` из задания для несоответствующего старого кадра не повторена прямым `sverka_maketa.score_frame` на 16 соответствующих парах с текущими манифестами: измерен диапазон **0.123…0.432**, GA-02 dark 390 = 0.401, самосравнение 1.000, порог 0.600. Контракт не фиксирует 0.441; старые кадры всё равно красные.

Остальная счётная/механическая сверка: source.json 56 клеток (2 rc0/47 rc1/7 rc2), W --model 56/56, --stabs 29/46/0 живых, --repo 37/37; пакет 46/46 full, 188 PNG и 190 строк SHA256SUMS (`sha256sum --quiet -c` rc0), 699 целей/0 ниже 44, tokens.json 265 `$value`/264 `$type`/84 final2/872 скаляра, copy-de.json 264, 16 кадров Kompakt/16 Final2 размером 1261038/923860 Б, SHA256SUMS/frames.json/manifest.json/tokens.css 18360/66996/217883/6274 Б, носитель семи token fields совпал с продуктом 7/7, 8+8 пинов GA/темы/профиля. Иных обнаруженных расхождений текста нет. Правило владельца «FAIL только по самоописанию» неприменимо: выше три содержательных блока.

## Последовательные команды и границы

| Команда в клоне OBJECT | Наблюдение |
|---|---|
| `bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh` | rc1, 56/37/19, без продукта PACHKA_ABSENT |
| та же `--model` | rc0, 56/56 |
| та же `--model --seed 7` | rc2, `error: unrecognized arguments: --seed 7` (не контрактный режим) |
| та же `--stabs` | rc0, 56/56, все s65–s93 KRASEN, SVJAZI 46; первая попытка timeout=180 прервана после s86, повтор с timeout=900 завершён |
| та же `--oracle-tamper` | rc2, `error: unrecognized arguments: --oracle-tamper` (не контрактный режим) |
| та же `--repo /tmp/dev-harness-verify/Arch148r/mob-ref` и `--model --repo …` | обе rc0, 37/37 |
| `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model` | rc0, все CASE ok |
| `bash scripts/pre_critic.sh contracts/148-vkladki-tabov.md` | rc0, `КРИТИК: дверь зелёная` |
| `bash scripts/check_ceilings.sh` | rc0, `потолки в порядке` |
| `bash scripts/check_precision_gate.sh . contracts/148-vkladki-tabov.md` | rc0, `OK` |
| `bash scripts/check_threat_model.sh . contracts/148-vkladki-tabov.md` | rc0, ЗАЩИЩАЕТ 14, НЕ ЗАЩИЩАЕТ 12 |
| `bash scripts/check_spec_ready.sh . contracts/148-vkladki-tabov.md` | rc0, `OK` |
| `bash scripts/check_provodka.sh . contracts/148-vkladki-tabov.md` | rc1, `guard не подключён` (назначен orchestrator после freeze) |
| `bash scripts/check_zones.sh .` без --incr | rc0, 148 замороженных/5 авторов/42604 коммита/10165 проверенных зон |

НЕ проверено: Android/AVD/Maestro, нативная сборка, диагностический PR продукта и workflow_dispatch `mobile-regression-signal` по тому же SHA (приёмка 10 — условие будущей freeze, оркестратор отвечает); живые hit-test координаты вне Jest-дерева. Фоновая остановка AVD — честно в НЕ ЗАЩИЩАЕТ, изменение этой границы требует слова владельца. Ни кандидат, ни основной репозиторий этим судом не изменены; вердикт в main вносит оркестратор.
