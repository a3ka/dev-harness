FAIL
OBJECT=df5fdfc3d93afe340233aa8e309c18a32cb13057
СУД: repo=dev-harness; предмет=148; фаза=контракт v2 (дельта замороженного 148/1); роль=critic; вызов=1 по v2; модель-план=openai-codex/gpt-6-sol; сессия=Crit148v2; модель-факт=openai-codex/gpt-6-sol; SHA=df5fdfc3d93afe340233aa8e309c18a32cb13057; предыдущий=verdicts/critic/contracts-148-v1.md (accept по прежней области); исключение=нет.

Область: только v2 (маска 393, последовательность двух AVD, ПЕРЕСЕЧЕНИЕ cmp-mob-002-tabs.yaml) и зависимый регресс. `git cat-file -t df5fdfc3d93afe340233aa8e309c18a32cb13057` → rc 0, `commit`; собственный клон HEAD = OBJECT; девять путей коммита, все в зоне architect. Живых эмуляторов и нативных сборок не запускал. Предыдущие причины v1 заново не судил.

## БЛОКИРУЕТ: содержательные причины

БЛОКИРУЕТ contracts/148-vkladki-tabov.md:62,87 — И-11/приёмка 12 допускают одновременный запуск после неисполненной остановки первого AVD. Класс: ложная достаточность статической грамматики жизненного цикла.
ОБХОД: в эталонном `mobile/e2e-vkladki/e2e.sh` заменить единственную остановку `adb -s "$SERIAL_390" emu kill` на `true || adb -s "$SERIAL_390" emu kill` (или `echo 'adb -s "$SERIAL_390" emu kill'`). При входном живом 5570 команда kill не исполняется, после неё стартует 393, но `produkt_sud.py --repo <референс>` возвращает rc 0, без причин отказа. Закрывающее свойство: ни один допустимый исполняемый путь не запускает второй AVD, пока первый не завершён; неисполняемый текст остановкой не считается, контроль порядка выполняется командой с rc и красной клеткой.

БЛОКИРУЕТ contracts/148-vkladki-tabov.md:62,87 — порт второго AVD из И-11 не проверяется. Класс: непокрытый параметр того же жизненного цикла.
ОБХОД: в эталонном `e2e.sh` заменить `PORT_393=5576` на `PORT_393=5571` (5571 — adb-пара 5570, прямо запрещённая И-11); `produkt_sud.py --repo <референс>` возвращает rc 0. Закрывающее свойство: выбранные порты пары проверены как 5570/5576, соседний adb-порт отвергается исполняемой клеткой.

БЛОКИРУЕТ contracts/148-vkladki-tabov.md:60,86 — точное `mera.chrome_verh_pt = 48` не обеспечено приёмкой. Класс: красная клетка только для 36 вместо инварианта значения.
ОБХОД: в `kadry_profil.json` референсного R установить 47 (или 49, 60) вместо 48, оставив порог кадров 0.600. Модель формы с заново построенными кадрами для 47/49/60 даёт rc 0; `produkt_sud.py --repo R` на 47 даёт rc 0, восемь KADR 1.000 и SHABLON OK; **названная** `W --repo R` на том же R даёт rc 0, `клеток 34, зелёных 34, красных 0`, тогда как профиль больше не имеет маски 48 pt. Закрывающее свойство: отличное от 48 значение манифеста профиля получает именованный rc 1 независимо от визуального score, без ослабления порога 0.600.

## Сырые атаки и проверки

`python3 /tmp/dev-harness-verify/Crit148v2/attack_lifecycle.py` → rc 0, полный stdout:
```text
baseline-sequential: []
simultaneous-true-or-kill: []
simultaneous-echo-kill: []
honest-two-spaces-kill: ['EMULJATORY_ODNOVREMENNO: строка 38 запускает эмулятор при живом первом — одновременно (И-11: второй после остановки первого, не более двух на станции)']
wrong-adb-pair-port-5571: []
```
`python3 /tmp/dev-harness-verify/Crit148v2/attack_product.py` → rc 0 (каждая строка — отдельное исполнение `produkt_sud.py --repo` на изолированном референсе), полный stdout:
```text
baseline: rc=0; causes=[]
simultaneous-true-or-kill: rc=0; causes=[]
simultaneous-echo-kill: rc=0; causes=[]
wrong-adb-pair-port-5571: rc=0; causes=[]
honest-two-spaces-kill: rc=1; causes=[]
```
`python3 /tmp/dev-harness-verify/Crit148v2/attack_mask.py` → rc 0 (новая пачка и снимки для каждого входа), полный stdout:
```text
mask=36: rc=1; causes=['PRICHINA\tKADR_NIZHE_POROGA\tGA-02 light 393\tscore=0.513 porog=0.600 hudshij=shapka', 'PRICHINA\tKADR_NIZHE_POROGA\tGA-03 light 393\tscore=0.498 porog=0.600 hudshij=shapka', 'PRICHINA\tKADR_NIZHE_POROGA\tGA-04 light 393\tscore=0.475 porog=0.600 hudshij=shapka']
mask=47: rc=0; causes=[]
mask=48: rc=0; causes=[]
mask=49: rc=0; causes=[]
mask=60: rc=0; causes=[]
```
Первый черновой запуск той же команды до исправления установки стенда был невалиден (после маски 36 переиспользовал старые PNG, давал `KADR_USTAREVSHIJ` при масках 47/48/49/60). Сырой stdout первого запуска:
```text
mask=36: rc=1; causes=['PRICHINA\tKADR_NIZHE_POROGA\tGA-02 light 393\tscore=0.513 porog=0.600 hudshij=shapka', 'PRICHINA\tKADR_NIZHE_POROGA\tGA-03 light 393\tscore=0.498 porog=0.600 hudshij=shapka', 'PRICHINA\tKADR_NIZHE_POROGA\tGA-04 light 393\tscore=0.475 porog=0.600 hudshij=shapka']
mask=47: rc=1; causes=['PRICHINA\tKADR_USTAREVSHIJ\tdark/aa/bb/takeScreenshot/vkladki-post-393.png', 'PRICHINA\tKADR_USTAREVSHIJ\tdark/aa/bb/takeScreenshot/vkladki-post.png', 'PRICHINA\tKADR_USTAREVSHIJ\tdark/aa/bb/takeScreenshot/vkladki-schutz-393.png', 'PRICHINA\tKADR_USTAREVSHIJ\tdark/aa/bb/takeScreenshot/vkladki-schutz.png', 'PRICHINA\tKADR_USTAREVSHIJ\tdark/aa/bb/takeScreenshot/vkladki-vorgaenge-393.png']
mask=48: rc=1; causes=['PRICHINA\tKADR_USTAREVSHIJ\tdark/aa/bb/takeScreenshot/vkladki-post-393.png', 'PRICHINA\tKADR_USTAREVSHIJ\tdark/aa/bb/takeScreenshot/vkladki-post.png', 'PRICHINA\tKADR_USTAREVSHIJ\tdark/aa/bb/takeScreenshot/vkladki-schutz-393.png', 'PRICHINA\tKADR_USTAREVSHIJ\tdark/aa/bb/takeScreenshot/vkladki-schutz.png', 'PRICHINA\tKADR_USTAREVSHIJ\tdark/aa/bb/takeScreenshot/vkladki-vorgaenge-393.png']
mask=49: rc=1; causes=['PRICHINA\tKADR_USTAREVSHIJ\tdark/aa/bb/takeScreenshot/vkladki-post-393.png', 'PRICHINA\tKADR_USTAREVSHIJ\tdark/aa/bb/takeScreenshot/vkladki-post.png', 'PRICHINA\tKADR_USTAREVSHIJ\tdark/aa/bb/takeScreenshot/vkladki-schutz-393.png', 'PRICHINA\tKADR_USTAREVSHIJ\tdark/aa/bb/takeScreenshot/vkladki-schutz.png', 'PRICHINA\tKADR_USTAREVSHIJ\tdark/aa/bb/takeScreenshot/vkladki-vorgaenge-393.png']
mask=60: rc=1; causes=['PRICHINA\tKADR_USTAREVSHIJ\tdark/aa/bb/takeScreenshot/vkladki-post-393.png', 'PRICHINA\tKADR_USTAREVSHIJ\tdark/aa/bb/takeScreenshot/vkladki-post.png', 'PRICHINA\tKADR_USTAREVSHIJ\tdark/aa/bb/takeScreenshot/vkladki-schutz-393.png', 'PRICHINA\tKADR_USTAREVSHIJ\tdark/aa/bb/takeScreenshot/vkladki-schutz.png', 'PRICHINA\tKADR_USTAREVSHIJ\tdark/aa/bb/takeScreenshot/vkladki-vorgaenge-393.png']
```
`python3 fixtures/workshop_project/vkladki_tabov_148/produkt_sud.py --repo /tmp/dev-harness-verify/Crit148v2/referens` при маске 47 → rc 0, конец сырого stdout/stderr:
```text
KADR	GA-02 dark	1.000	0.600	G	OK
KADR	GA-02 light	1.000	0.600	G	OK
KADR	GA-03 dark	1.000	0.600	G	OK
KADR	GA-03 light	1.000	0.600	G	OK
KADR	GA-04 dark	1.000	0.600	G	OK
KADR	GA-04 light	1.000	0.600	G	OK
KADR	GA-09 dark	1.000	0.600	G	OK
KADR	GA-09 light	1.000	0.600	G	OK
SHABLON	vkladki	OK
ISPOLNIMYJ_SKIP: нет mobile/package.json — не jest-среда
```
`bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh --repo /tmp/dev-harness-verify/Crit148v2/referens` на той же маске 47 → rc 0, сырой финал `CASE pr-chestnaja ok` / `клеток 34, зелёных 34, красных 0`; синтетическая копия намеренно без jest, поэтому настоящая Android/Jest-стадия этим не заявлена проверенной. Раздел продуктового суда проверяет маску до Jest; маска не входит в матрицу Jest-компонентов.

`bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh --model` → rc 0, сырой финал `CASE profil-maska-36 ok` / `CASE pr-emuljatory-odnovremenno ok` / `клеток 46, зелёных 46, красных 0`.
Та же команда без флага → rc 1, `клеток 46, зелёных 34, красных 12` (12 продуктовых входов PACHKA_ABSENT); `--model --repo /tmp/dev-harness-verify/Crit148v2/referens` до мутации маски → rc 0, `клеток 34, зелёных 34, красных 0`.
`bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh --stabs` → rc 0, сырой вывод контрольной и новой части:
```text
CASE chestnyj-vkladki ok
CASE profil-maska-36 ok
CASE pr-chestnaja ok
CASE pr-emuljatory-odnovremenno ok
клеток 46, зелёных 46, красных 0
STAB s84_maska_propuskaet.py profil-maska-36 KRASEN
STAB s85_emuljatory_propuskaet.py pr-emuljatory-odnovremenno KRASEN
SVJAZI 35
```
21 стаб s65–s85, все 35 привязок красны, живых 0; приведены предметные строки выхода, остальные строки состояли из `CASE … ok` и `STAB … KRASEN` (полный вывод прогона получен судьёй).
`bash scripts/pre_critic.sh contracts/148-vkladki-tabov.md` → rc 0, `КРИТИК: дверь зелёная`; `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Crit148v2/repo contracts/148-vkladki-tabov.md` → rc 0, `OK` (новая ЗОНА :104, ПЕРЕСЕЧЕНИЕ :124); `bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Crit148v2/repo` → rc 0, `потолки в порядке`; `bash scripts/check_charter.sh /tmp/dev-harness-verify/Crit148v2/repo` → rc 0, уставных документов 146 / изменений 375 / с разрешения 375; `bash scripts/check_zones.sh /tmp/dev-harness-verify/Crit148v2/repo` → rc 0, замороженных 146 / коммитов в диапазонах 39973 / по зонам 9349.

## САМООПИСАНИЕ — полная сверка чисел и механических утверждений дельты

| Утверждение текста | Живое значение / команда |
|---|---|
| 46 клеток = 33 формы + 13 продукта; kejsy 46 | 46 = 33 + 13, len(source.json.kejsy)=46; `--model` 46/46, без флага 46/34/12 |
| 21 стаб s65–s85 = 11 A + 10 B | 21 файлов `stubs/s*.py`, 11 + 10 |
| SVJAZI 35; stab_vhod 21/35 | 21 ключ, sum(len(v))=35; `--stabs` rc 0 SVJAZI 35 |
| `--repo` 34 | 33 формы + pr-chestnaja = 34; два прогона 34/34 |
| 16 кадров/16 PNG, 8+8 | по 8 кадров в двух манифестах; 16 PNG-ключей `piny.nositeli` |
| 18 целей, min 44×44 | 18; минимум ширины 79, высоты 44 |
| шапка 393 48, шапка 390 36; порог 0.600 | `profil_kadry.mera.chrome_verh_pt` 48, `kadry_manifest` 36, все 16 `kadry[].porog` 0.6 |
| маска-36 scores 0.513/0.498/0.475 | отдельный живой прогон mask=36: именно эти три score и `KADR_NIZHE_POROGA` |
| одновременный старт «строка 34» | `source.json.kejsy.pr-emuljatory-odnovremenno` содержит строку 34; модельная клетка зелена |
| 12 файлов эталонной раскладки, пин e2e.sh | 12 файлов всего (11 в родителе OBJECT + 1 новый e2e.sh); sha256 e2e.sh `4f56d5f5b5a326f0b7f386ac03c4443130a6433ede80d3dcd4324fdaa405050f` |
| ось второго профиля 6; продуктовая 13 | stab_vhod s66=3, s67=2, s84=1 → 6; MUTACII_PRODUKTA=13 |
| три исходных D24-файла 1.3 МБ | 1 313 643 байта = 1.314 МБ (десятичное округление) |

**Все счётные/механические расхождения отдельного класса САМООПИСАНИЕ:**
1. САМООПИСАНИЕ contracts/148-vkladki-tabov.md:255 — «16 макетов GA … 684 КБ» против 16 PNG `piny.nositeli` суммарно **923 860 байт = 924 КБ десятичных или 902.2 КиБ**; команда: `python3 -c 'import pathlib,json; r=pathlib.Path("fixtures/workshop_project/vkladki_tabov_148"); s=json.loads((r/"source.json").read_text()); print(sum((r/x).stat().st_size for x in s["piny"]["nositeli"] if x.endswith(".png")))'` → `923860`.
2. САМООПИСАНИЕ contracts/148-vkladki-tabov.md:255 — «эталонная раскладка — 12 файлов (+ эталонный … e2e.sh)» формулирует 12 + 1, но после v2 в раскладке **12 файлов всего**, включая новый e2e.sh (до v2 11). Переписать как «12 файлов, включая e2e.sh»; это не содержательная причина отказа.
3. САМООПИСАНИЕ contracts/148-vkladki-tabov.md:256 — историческое «44/44/33» явно относится к прежней пачке и само по себе не ошибочно, но ссылка «числа строкой выше» теперь указывает на текущие **46/46/35** в :255, а не на исторический источник. Уточнить ссылку на старую версию, не менять исторические числа.

СОВЕТ contracts/148-vkladki-tabov.md:62 — честный последовательный `adb ... emu  kill` (два пробела) распознан как одновременность из-за буквально `emu kill`. За пределами объявленной закрытой грамматики; не дополнительный блок, но ложная диагностика реального bash-командного слова.

НЕ ПРОВЕРЕНО: запуск живых Android-эмуляторов/нативные сборки запрещены правилом станции; продуктовый CI/снимки на настоящем устройстве не выполнялись; синтетический --repo без установленной jest-среды не доказывает живую Jest-матрицу. Путь пересечения определён и принят precision-gate, но настоящую правку файла делает implementer по своей ЗОНА.
