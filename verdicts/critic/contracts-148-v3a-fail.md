FAIL
OBJECT=e7553c60b18a5891416b38a3b5999567ff69aa87
СУД: repo=dev-harness; предмет=148; фаза=контракт v+1 (+красная батарея); роль=critic; цикл 2, вызов 1/5; модель-план=openai-codex/gpt-6-sol; сессия=Crit148k2a (history://Crit148k2a, UUID трейса судье не открыт); модель-факт=openai-codex/gpt-6-sol (workstation); SHA=e7553c60b18a5891416b38a3b5999567ff69aa87; предыдущий=verdicts/critic/contracts-148-v3-fail.md (прежняя шкала); исключение=нет.

## Предмет суда

`git cat-file -t e7553c60b18a5891416b38a3b5999567ff69aa87` → `commit`; изолированный клон `/tmp/dev-harness-verify/Crit148k2a/repo` fetch `wip/148/architect`, checkout указанного OBJECT. Автор Arch148q — GLM `zai/glm-5.3` по заданию/отчёту; моя модель — Sol, семейства различны. Вторая строка сообщения кандидата содержит дословную строку РАЗРЕШИЛ-ВЛАДЕЛЕЦ из задания. Контракт содержит предмет, rc-критерии и ЗОНА architect/implementer/orchestrator; модель угроз и класс риска присутствуют. Дельта против `frozen/contracts/148/1` сохраняет шов, меню, вторую тему/профиль, копию, движение и порядок эмуляторов; замена Notice-маски каталогизированной зоной 1.1 и перенос фоновой остановки в НЕ ЗАЩИЩАЕТ объявлены явно. Фоновый класс остаётся вопросом владельца, не принимается за зелёный.

## Блокирующие классы (три независимых свойства)

БЛОКИРУЕТ contracts/148-vkladki-tabov.md:59,81,90-91 — И-6 требует **имя кадра конкретного GA/темы/профиля** из пакета 1.1, а не произвольный иной кадр того же пакета. Класс причины: пин суммы проверяет членство в SHA256SUMS по basename, но не соответствие имени записи `GA-02 dark` её идентификатору; стенд-ин генерирует снимок из подставленного файла. В реальном R с установленным Jest заменены только `kadry.json: GA-02 dark` → `GA-04_normal_dark_390x844.png` и её честный SHA, другие источники неизменны: `produkt_sud --repo R` rc 0, восемь KADR=1.000 и Jest 4/4, хотя кадр GA-02 больше не запинен на GA-02. Обязательство: названные 16 эталонных кадров, не просто принадлежность пакету. Состояние: валидный кадр GA-04 и запись SHA256SUMS существуют на допустимом профиле 390. Наблюдение: сырая атака ниже. ОБХОД: зелёная приёмка с кадром чужого экрана на месте GA-02; один лишь тест Final 2 не закрывает подмену *внутри* пакета. ЗАКРЫВАЮЩЕЕ СВОЙСТВО: для каждого ожидаемого GA/темы/профиля невозможен зелёный итог после замены его пина и байтов на другой допустимый кадр пакета, при честной исходной базе зелень остаётся.

БЛОКИРУЕТ contracts/148-vkladki-tabov.md:40,60,78,82 — И-7 и слово владельца различают видимую рамку 36 и **настоящую** зону касания ≥44. Класс причины: проверяется декларированная `prokhodimost` с hw/hh, но не физический размер/расширение Pressable продукта; исполняемый Jest-зонд проверяет только слот, бейдж и абсолютный оверлей. Состояние: в живом R заменить стиль `post-filtr-nastrojki` с `minHeight: 44` на `height: 36` без hitSlop, не меняя manifest hh44. Наблюдение: `produkt_sud --repo R` rc 0, KADR×8 1.000 и Jest контроль 4/4, все три заявленных мутанта UBIT; фактическое касание Filter высотой 36. ОБХОД: контент и отчёт 24 зон удовлетворяют критерию, а невидимого расширения на экране нет. ЗАКРЫВАЮЩЕЕ СВОЙСТВО: снижение фактической hit-area хотя бы одной объявленной цели ниже 44 при неизменных hw/hh вызывает именованный красный исход в настоящей среде продукта; видимая рамка <44 при *действительно* расширенной зоне остаётся зелёной.

БЛОКИРУЕТ contracts/148-vkladki-tabov.md:13,19,38,50,78 — новый пин токенов Kompakt 1.1 требует их использования экраном, а не только правильной соседней копии `source/tokens.json`. Класс причины: модельная проверка копирует fixture `nositeli/tokens.css` в синтетический R (`produkt_sud.py:511-514`), экранный Jest не измеряет типографику/токены, а кадры-стенд-ины производятся из запиненного PNG. Состояние: на полном продуктовом референсе в разрешённом файле `mobile/src/bootstrap/tab-shell.tsx` заменить `tabLabel: { fontSize: 14 }` на `tabLabel: { fontSize: 11 }` (11 — `nav.label.font-size.final2`, 10 — `$value` 1.1); на отдельной копии подменить байты продуктового `docs/ux/05_Kompakt_D24/source/ds/tokens.css` (`--size-nav: 84px` → `71px`). Наблюдение: каждая атака отдельно возвращает rc 0 с KADR×8 1.000 и контрольным Jest 4/4, хотя на экране старый размер/продуктовые токены уже не равны канону. ОБХОД: `W --repo` принимает использование старого численного токена в рабочем компоненте, сохраняя правильные source/JSON и имена кадров. ЗАКРЫВАЮЩЕЕ СВОЙСТВО: привязка судимой реализации к именованным `$value` 1.1, так что подмена рабочего токена на соответствующий Final 2 и нарушение источника/потребления токенов не проходят rc 0 при сохранении честной базы. Простая дополнительная декларация чисел или наличие JSON без проверки потребителя недостаточны.

## Атаки — команды и сырой вывод

Все скрипты записаны только в `/tmp/dev-harness-verify/Crit148k2a/`, копируют R во временный каталог и не правят кандидата. `python3 /tmp/dev-harness-verify/Crit148k2a/live_mutations.py` (последовательно: база; чужое имя кадра; 36pt hit area; подмена продуктового CSS), **rc команды 0**:

```text
ATTACK baseline rc 0
KADR	GA-02 dark	1.000	0.600	G	OK
KADR	GA-02 light	1.000	0.600	G	OK
KADR	GA-03 dark	1.000	0.600	G	OK
KADR	GA-03 light	1.000	0.600	G	OK
KADR	GA-04 dark	1.000	0.600	G	OK
KADR	GA-04 light	1.000	0.600	G	OK
KADR	GA-09 dark	1.000	0.600	G	OK
KADR	GA-09 light	1.000	0.600	G	OK
SHABLON	vkladki	OK
ISPOLNIMYJ kontrol ZELEN — suites=1 tests=4
ISPOLNIMYJ mutant tabs UBIT — упавших ассертов 2
ISPOLNIMYJ mutant badge UBIT — упавших ассертов 1
ISPOLNIMYJ mutant skroll UBIT — упавших ассертов 1
ATTACK GA02-is-pinned-to-GA04-frame rc 0
KADR	GA-02 dark	1.000	0.600	G	OK
KADR	GA-02 light	1.000	0.600	G	OK
KADR	GA-03 dark	1.000	0.600	G	OK
KADR	GA-03 light	1.000	0.600	G	OK
KADR	GA-04 dark	1.000	0.600	G	OK
KADR	GA-04 light	1.000	0.600	G	OK
KADR	GA-09 dark	1.000	0.600	G	OK
KADR	GA-09 light	1.000	0.600	G	OK
SHABLON	vkladki	OK
ISPOLNIMYJ kontrol ZELEN — suites=1 tests=4
ISPOLNIMYJ mutant tabs UBIT — упавших ассертов 2
ISPOLNIMYJ mutant badge UBIT — упавших ассертов 1
ISPOLNIMYJ mutant skroll UBIT — упавших ассертов 1
ATTACK Filter-hit-area-36-with-declared-hh44 rc 0
KADR	GA-02 dark	1.000	0.600	G	OK
KADR	GA-02 light	1.000	0.600	G	OK
KADR	GA-03 dark	1.000	0.600	G	OK
KADR	GA-03 light	1.000	0.600	G	OK
KADR	GA-04 dark	1.000	0.600	G	OK
KADR	GA-04 light	1.000	0.600	G	OK
KADR	GA-09 dark	1.000	0.600	G	OK
KADR	GA-09 light	1.000	0.600	G	OK
SHABLON	vkladki	OK
ISPOLNIMYJ kontrol ZELEN — suites=1 tests=4
ISPOLNIMYJ mutant tabs UBIT — упавших ассертов 2
ISPOLNIMYJ mutant badge UBIT — упавших ассертов 1
ISPOLNIMYJ mutant skroll UBIT — упавших ассертов 1
ATTACK product-token-input-changed rc 0
KADR	GA-02 dark	1.000	0.600	G	OK
KADR	GA-02 light	1.000	0.600	G	OK
KADR	GA-03 dark	1.000	0.600	G	OK
KADR	GA-03 light	1.000	0.600	G	OK
KADR	GA-04 dark	1.000	0.600	G	OK
KADR	GA-04 light	1.000	0.600	G	OK
KADR	GA-09 dark	1.000	0.600	G	OK
KADR	GA-09 light	1.000	0.600	G	OK
SHABLON	vkladki	OK
ISPOLNIMYJ kontrol ZELEN — suites=1 tests=4
ISPOLNIMYJ mutant tabs UBIT — упавших ассертов 2
ISPOLNIMYJ mutant badge UBIT — упавших ассертов 1
ISPOLNIMYJ mutant skroll UBIT — упавших ассертов 1
```

`python3 /tmp/dev-harness-verify/Crit148k2a/old_token_mutation.py` (изолированный полный продукт, **rc команды 0**):

```text
ATTACK old-Final2-nav.label.font-size-11 rc 0
KADR	GA-02 dark	1.000	0.600	G	OK
KADR	GA-02 light	1.000	0.600	G	OK
KADR	GA-03 dark	1.000	0.600	G	OK
KADR	GA-03 light	1.000	0.600	G	OK
KADR	GA-04 dark	1.000	0.600	G	OK
KADR	GA-04 light	1.000	0.600	G	OK
KADR	GA-09 dark	1.000	0.600	G	OK
KADR	GA-09 light	1.000	0.600	G	OK
SHABLON	vkladki	OK
ISPOLNIMYJ kontrol ZELEN — suites=1 tests=4
ISPOLNIMYJ mutant tabs UBIT — упавших ассертов 2
ISPOLNIMYJ mutant badge UBIT — упавших ассертов 1
ISPOLNIMYJ mutant skroll UBIT — упавших ассертов 1
```

Ранние пробы на **синтетическом** R без mobile/package.json (Jest там честно сообщает SKIP, эти пробы не подменяют живое доказательство выше): `python3 /tmp/dev-harness-verify/Crit148k2a/frame_mutation.py`, `python3 /tmp/dev-harness-verify/Crit148k2a/hitarea_mutation.py`, `python3 /tmp/dev-harness-verify/Crit148k2a/token_mutation.py`, каждая команда rc 0. Их сырой вывод (последние строки stdout напечатаны самими скриптами):

```text
baseline rc 0
stdout KADR	GA-02 dark	1.000	0.600	G	OK
KADR	GA-02 light	1.000	0.600	G	OK
KADR	GA-03 dark	1.000	0.600	G	OK
KADR	GA-03 light	1.000	0.600	G	OK
KADR	GA-04 dark	1.000	0.600	G	OK
KADR	GA-04 light	1.000	0.600	G	OK
KADR	GA-09 dark	1.000	0.600	G	OK
KADR	GA-09 light	1.000	0.600	G	OK
SHABLON	vkladki	OK
stderr ISPOLNIMYJ_SKIP: нет mobile/package.json — не jest-среда
wrong-GA-02-frame-name rc 0
stdout KADR	GA-02 dark	1.000	0.600	G	OK
KADR	GA-02 light	1.000	0.600	G	OK
KADR	GA-03 dark	1.000	0.600	G	OK
KADR	GA-03 light	1.000	0.600	G	OK
KADR	GA-04 dark	1.000	0.600	G	OK
KADR	GA-04 light	1.000	0.600	G	OK
KADR	GA-09 dark	1.000	0.600	G	OK
KADR	GA-09 light	1.000	0.600	G	OK
SHABLON	vkladki	OK
stderr ISPOLNIMYJ_SKIP: нет mobile/package.json — не jest-среда
baseline rc 0 stdout R	GA-04 dark	1.000	0.600	G	OK
KADR	GA-04 light	1.000	0.600	G	OK
KADR	GA-09 dark	1.000	0.600	G	OK
KADR	GA-09 light	1.000	0.600	G	OK
SHABLON	vkladki	OK
 stderr ISPOLNIMYJ_SKIP: нет mobile/package.json — не jest-среда
filter-hit-area-36 rc 0 stdout R	GA-04 dark	1.000	0.600	G	OK
KADR	GA-04 light	1.000	0.600	G	OK
KADR	GA-09 dark	1.000	0.600	G	OK
KADR	GA-09 light	1.000	0.600	G	OK
SHABLON	vkladki	OK
 stderr ISPOLNIMYJ_SKIP: нет mobile/package.json — не jest-среда
baseline rc 0 stdout R	GA-04 dark	1.000	0.600	G	OK
KADR	GA-04 light	1.000	0.600	G	OK
KADR	GA-09 dark	1.000	0.600	G	OK
KADR	GA-09 light	1.000	0.600	G	OK
SHABLON	vkladki	OK
 stderr ISPOLNIMYJ_SKIP: нет mobile/package.json — не jest-среда
product-token-corrupted rc 0 stdout R	GA-04 dark	1.000	0.600	G	OK
KADR	GA-04 light	1.000	0.600	G	OK
KADR	GA-09 dark	1.000	0.600	G	OK
KADR	GA-09 light	1.000	0.600	G	OK
SHABLON	vkladki	OK
 stderr ISPOLNIMYJ_SKIP: нет mobile/package.json — не jest-среда
```

Промежуточная проба `python3 /tmp/dev-harness-verify/Crit148k2a/token_mutation.py` с неполной первоначальной сборкой продукта дважды вернула `rc 1` (`ISTOCHNIK_NE_SOVPADAET manifest/spec/pozvonok`); после заполнения этих источников дважды `rc 1` (`ISPOLNIMYJ_KONTROL_KRASEN: ... (упавших ассертов 2)` из-за неполной сборки). Ни один из этих результатов не засчитан обходом; окончательные зелёные замеры сделаны на авторском полном R со всеми Jest-зависимостями. Для повторения содержательных обходов достаточно двух live-скриптов выше.

## Перемер критериев и механики

| Команда в изолированном клоне OBJECT | rc | Фактический вывод |
|---|---:|---|
| `bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh` | 1 | `клеток 54, зелёных 36, красных 18` (продукта в дереве харнесса нет) |
| `… --model` | 0 | `клеток 54, зелёных 54, красных 0` |
| `… --stabs` | 0 | `клеток 54, зелёных 54, красных 0`; все `STAB … KRASEN`; `SVJAZI 44` (s65–s91 = 27) |
| `… --repo /tmp/dev-harness-verify/Arch148p/mob-ref` | 0 | `клеток 36, зелёных 36, красных 0` |
| `… --model --repo /tmp/dev-harness-verify/Arch148p/mob-ref` | 0 | `клеток 36, зелёных 36, красных 0` |
| `python3 …/produkt_sud.py --repo /tmp/dev-harness-verify/Arch148p/mob-ref` | 0 | `KADR` × 8 `1.000/0.600`, `SHABLON vkladki OK`, Jest `suites=1 tests=4`, mutants `2/1/1` убиты |
| `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model` | 0 | все перечисленные CASE ok |
| `bash scripts/pre_critic.sh contracts/148-vkladki-tabov.md` | 0 | `КРИТИК: дверь зелёная` |
| `bash scripts/check_ceilings.sh` | 0 | `потолки в порядке` |
| `bash scripts/check_precision_gate.sh . contracts/148-vkladki-tabov.md` | 0 | `OK` |
| `bash scripts/check_threat_model.sh . contracts/148-vkladki-tabov.md` | 0 | `ЗАЩИЩАЕТ 13 буллет(ов), НЕ ЗАЩИЩАЕТ 12 буллет(ов)` |
| `bash scripts/check_spec_ready.sh . contracts/148-vkladki-tabov.md` | 0 | `OK` |
| `bash scripts/check_provodka.sh . contracts/148-vkladki-tabov.md` | 1 | `guard не подключён: …red_vkladki_tabov_148.sh не вызывается в .githooks/ или .github/workflows/` — проводка назначена orchestrator после freeze, не новый класс блока |
| `bash scripts/check_zones.sh .` | 0 | `замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 42509 · проверено по зонам: 10130` |
| `bash …/red_vkladki_tabov_148.sh --model --seed 7` | 2 | `error: unrecognized arguments: --seed 7` (нет этого режима в argparse) |
| `bash …/red_vkladki_tabov_148.sh --oracle-tamper` | 2 | `error: unrecognized arguments: --oracle-tamper` (текущий CLI этих режимов не обещает) |

САМООПИСАНИЕ contracts/148-vkladki-tabov.md:72-74,78,256-266 — счётные и механические утверждения контракта сверены полным набором источников: 54=35 формы+19 продукта; 36/18 без флага; 54/54 модель и стабы, SVJAZI=44, 27 файлов s65–s91; живой R=36/36; 8 кадров по 1.000, Jest 1/4, мутанты 2/1/1; `tokens.json` 265 `$value`, 264 `$type`, 84 `final2`, 872 scalar; manifest 46 экранов, 699 целей/0 меньше 44, из них 94 для 148, 24 целей пачки; 188 PNG/190 записей SHA256SUMS (проверка `sha256sum --quiet -c SHA256SUMS` rc 0); размеры носителей 1261038/923860, SHA256SUMS 18360, frames.json 66996, manifest.json 217883, tokens.css 6274 Б; строки :59/:60/:72-74/:78/:256-266 существуют. Расхождений **в самом контракте** по этим счётам не выявлено. Вне предмета: `/tmp/dev-harness-verify/Arch148q/report.md:117` даёт прежний запуск зон 40397 коммитов/9567 зон, текущий OBJECT-клон — 42509/10130 (разные моменты/истории), а `:11` считает 53 changed files по `git show --shortstat` — действительно 53 (список `diff-tree --name-only` даёт 69 путей, потому что 16 кадров переименованы; это не 16 лишних изменённых файлов). Это полный список обнаруженных внешних счётных расхождений, они не являются самостоятельным основанием FAIL.

СОВЕТ contracts/148-vkladki-tabov.md:228-232 — объяснение фонового класса честное: однопоточный журнал не доказывает отсутствие параллельного запуска; владелец должен отдельно решить перенос/механизм, но заявленная граница этой v+1-пачки его не включает.

НЕ проверено: реальный AVD/Maestro, тяжёлые нативные сборки и CI diagnostic-PR по SHA кандидата (приёмка 10 остаётся обязательным условием до freeze); полноценный экранный рендер на телефоне вне стенд-инов. Порчу оракула реальным изменением pin-файлов не запускал: проверен только аргумент `--oracle-tamper`, которого нет. Ни контракт, ни репозиторий автора не правились.
