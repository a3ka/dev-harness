FAIL
OBJECT=264e468730030e053f230029299f56c4641c7912
СУД: repo=dev-harness; предмет=149; фаза=контракт v+1 (+красная батарея); цикл 2, вызов 2/5; модель-план=openai-codex/gpt-6-sol; сессия=Crit149k2b; модель-факт=openai-codex/gpt-6-sol; SHA=264e468730030e053f230029299f56c4641c7912; предыдущий=contracts-149-v2a-fail.md; исключение=нет. Судья Sol, автор конструкции GLM; независимость сохранена. Судился коммит, не рабочий черновик: `git cat-file -t OBJECT` → `commit` rc 0; оба коммита имеют по одной точной строке РАЗРЕШИЛ-ВЛАДЕЛЕЦ с буквальным путём 149.

## БЛОКИРУЕТ

БЛОКИРУЕТ contracts/149-gespraech-tekst-chat.md:58,72,77,200 — класс РЕАЛЬНЫЙ_ТОКЕН_ПОЛЯ: проверка равенства зафиксированному значению не доказывает потребления токена компонентом.
ОБЯЗАТЕЛЬСТВО: И-4 требует, чтобы реальный композер читал `typography.body.$value.lineHeight` из tokens.json пакета 1.1, **не литералом**, и чтобы критерий различал потребление токена от старого числового потолка. Пакет при этом пинуется; подменять пакет для сдачи нельзя.
СОСТОЯНИЕ: конформное R — зелёная референс-раскладка автора `/tmp/dev-harness-verify/Arch149r/a-derevo3` с единственной предметной правкой композера: выражение `const VYSOTA_STROKI = Number(String(kompakt.typography.body.$value.lineHeight).replace('px', ''));` заменено на `const VYSOTA_STROKI = 21;`. Пакет, пины, исходная высота на экране и 15 тестов не изменены; импорт пакета остаётся неиспользуемым.
НАБЛЮДЕНИЕ: `python3 /tmp/dev-harness-verify/Crit149k2b/mutate_token_literal.py` → `literal token replaces consumed token; package import remains unused`, rc 0. `W --repo /tmp/dev-harness-verify/Crit149k2b/mut-token-literal` → rc **0**, `CASE s-ekran-ispolnim ok`, `клеток 96, зелёных 96, красных 0; режим repo seed 149`, suites=1 tests=15, все шесть штатных мутантов по-прежнему UBIT (10/15/4/4/1/1). Тест `produkt/gespraech-zond-149.test.tsx:273-289` сопоставляет `maxHeight` с числом `6*21` из неизменяемого пина, а не проверяет связь источника и компонента.
ОБХОД: сдать визуально идентичный экран и всю зелёную батарею с зашитым в компонент числом 21 вместо потребления токена; обещанная единая шкала перестаёт быть источником компонента.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: приёмка различает связь компонента с токеном и совпадение текущего числа; отсутствие потребления при корректном зафиксированном пакете красно, а реальные 24/20 остаются красными. Единственный способ проверки не предписывается.

БЛОКИРУЕТ contracts/149-gespraech-tekst-chat.md:49,59,72,77,192 — класс ПОЛНОТА_ЖИВЫХ_ЦЕЛЕЙ: зелёный суд принимает экран без обязательных pressable из объявленного домена.
ОБЯЗАТЕЛЬСТВО: предмет включает GA-19 и чипы ответов, И-5 объявляет 26 целей в `prokhodimost.pressable`, а сценарий 5 утверждает исполнимый экран на настоящих компонентах R, не только JSON-карту. У GA-19 в пиннованном 1.1-манифесте цели `Ja, vergleichen` и `Erst mal nicht`.
СОСТОЯНИЕ: конформная зелёная референс-раскладка `/tmp/dev-harness-verify/Arch149r/a-derevo3`, чьи `chat-host.tsx`/`conversation-composer.tsx` вообще не содержат `gespraech-chip-vergleichen`, `gespraech-chip-nicht`, `gespraech-mikrofon-v-pole`, тогда как все три id перечислены среди 26 целей `pachka/forma-ekrana.json`. GA-19 в хосте представлен документом без обоих чипов. Дерево имеет установленную jest-среду и полную пачку, поэтому не относится к исключению для синтетических входов.
НАБЛЮДЕНИЕ: на этом дереве `W --repo /tmp/dev-harness-verify/Arch149r/a-derevo3` → rc **0**, 96/96, `ISPOLNIMYJ kontrol ZELEN — suites=1 tests=15`. `jq -r '.prokhodimost.pressable[].id' .../pachka/forma-ekrana.json` выводит три перечисленных id; поиск по обоим реальным компонентам не находит ни одного. В `produkt/gespraech-zond-149.test.tsx:219-240` проверка `queryByTestId` делает `continue` при отсутствии цели, а GA-19 вообще не достигается зондом. Пакетная карта и стенд-ины e2e остаются зелёными при отсутствующих живых целях.
ОБХОД: сохранить в JSON все 26 записей и макеты пакета, не реализовав чипы GA-19/кнопку голоса в поле; `--repo` сообщает полную зелень без заявленного экрана.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: суд живой реализации достигает каждого заявленного состояния и требует наличие/действие каждого обязательного pressable на соответствующем экране; отсутствие любого обязательного target не может считаться вне домена через `continue`. Зона ≥44 и видимая рамка остаются разными свойствами.

## САМООПИСАНИЕ — полный список расхождений текущего текста

САМООПИСАНИЕ contracts/149-gespraech-tekst-chat.md:187 — защита от подмены источников обещает «порча любого из **84** носителей зоны», тогда как текущие `source.json:piny.nositeli` и выполненное `W --oracle-tamper` дают **132** носителя. Исторический счёт 84 не помечен как исторический, в отличие от специально размеченных измерений v1/v2; исправить описание области или число.

Иных расхождений актуального самоописания при проверке не найдено: без флага 96/78/18; model seed 149/7 96/96; stabs seed 149/7 19 KRASEN, SVJAZI 19; oracle 132; repo 96/96 и 15 тестов, шесть мутантов убиты 10/15/4/4/1/1; оси 64+10+10+12=96, 26 pressable, 11 канон-пинов. Пакет продукта d4aa406: байты `tokens.json`, `frames.json`, `SHA256SUMS`, `manifest.json`, `motion-delta.md` равны носителям; 188 кадров/46 full, 190 строк SHA256SUMS, targets=699/under_44=0, tokens 872 скаляра, 265 `$value`/264 `$type`/84 `final2`, lineHeight=21px, max-height=`calc(6 * 21px)`, touch-target.min=44px. Все 12 верхних масок 393 равны 48. `check_zones` на ЭТОМ клоне 42547 коммитов/10108 проверено (цифры 42433/10068 есть в старом отчёте автора, но уже НЕ закреплены в тексте контракта; не считаются новой находкой).

## Исполненные команды и дословные решающие строки stdout/stderr

`W=bash fixtures/workshop_project/gespraech_tekst_149/red_gespraech_tekst_149.sh` из изолированного клона OBJECT; команды запускались последовательно, все rc измерены `echo rc=$?`.

```
W                                      rc=1  клеток 96, зелёных 78, красных 18; режим koren seed 149
W --model                              rc=0  клеток 96, зелёных 96, красных 0; режим model seed 149
W --model --seed 7                     rc=0  клеток 96, зелёных 96, красных 0; режим model seed 7
W --stabs                              rc=0  STAB emuljatory-odnovremenno KRASEN AVD393_ZAPUSCHEN_DO_OSTANOVKI
                                             STAB maska-36 KRASEN PROFIL_MASKA_NE_48
                                             SVJAZI 19
                                             клеток 96, зелёных 96, красных 0; режим stabs seed 149
W --stabs --seed 7                     rc=0  SVJAZI 19; клеток 96, зелёных 96, красных 0; режим stabs seed 7
W --oracle-tamper                      rc=0  ORACLE_TAMPER_PROVERENO nositelej=132
W --repo /tmp/dev-harness-verify/Arch149r/a-derevo3
                                       rc=0  ISPOLNIMYJ kontrol ZELEN — suites=1 tests=15
                                             ISPOLNIMYJ mutant host-pustoj UBIT — упавших ассертов 10
                                             ISPOLNIMYJ mutant kompozer-ne-izmenen UBIT — упавших ассертов 15
                                             ISPOLNIMYJ mutant zona-12-host UBIT — упавших ассертов 4
                                             ISPOLNIMYJ mutant zona-12-kompozer UBIT — упавших ассертов 4
                                             ISPOLNIMYJ mutant token-24 UBIT — упавших ассертов 1
                                             ISPOLNIMYJ mutant token-20 UBIT — упавших ассертов 1
                                             CASE s-ekran-ispolnim ok
                                             CASE s-emuljatory-posledovatelno ok
                                             CASE s-profil-maska-393 ok
                                             клеток 96, зелёных 96, красных 0; режим repo seed 149
bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model
                                       rc=0  CASE w22-limit-back-chetyre ok
bash scripts/pre_critic.sh contracts/149-gespraech-tekst-chat.md
                                       rc=0  КРИТИК: дверь зелёная
bash scripts/check_ceilings.sh <клон> rc=0  потолки в порядке
bash scripts/check_precision_gate.sh <клон> contracts/149-gespraech-tekst-chat.md
                                       rc=0  OK
bash scripts/check_threat_model.sh <клон> contracts/149-gespraech-tekst-chat.md
                                       rc=0  модель угроз: секция валидна (ЗАЩИЩАЕТ 18 буллет(ов), НЕ ЗАЩИЩАЕТ 10 буллет(ов))
bash scripts/check_spec_ready.sh <клон> contracts/149-gespraech-tekst-chat.md
                                       rc=0  OK
bash scripts/check_provodka.sh <клон> contracts/149-gespraech-tekst-chat.md
                                       rc=1  проводка: guard не подключён: fixtures/workshop_project/gespraech_tekst_149/red_gespraech_tekst_149.sh не вызывается в .githooks/ или .github/workflows/
bash scripts/check_zones.sh <клон> contracts/149-gespraech-tekst-chat.md
                                       rc=0  замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 42547 · проверено по зонам: 10108
```

Сырые решающие строки каждой собственной атаки (прочие `CASE a-*`, `d-*`, `m-*`, `s-*` в полном выводе каждой атаки имели `ok`; указаны именно неизменённые строки stdout/stderr, без перефразирования):

```
python3 /tmp/dev-harness-verify/Crit149k2b/mutate_token_literal.py
literal token replaces consumed token; package import remains unused
rc=0
W --repo /tmp/dev-harness-verify/Crit149k2b/mut-token-literal
ISPOLNIMYJ kontrol ZELEN — suites=1 tests=15
ISPOLNIMYJ mutant host-pustoj UBIT — упавших ассертов 10
ISPOLNIMYJ mutant kompozer-ne-izmenen UBIT — упавших ассертов 15
ISPOLNIMYJ mutant zona-12-host UBIT — упавших ассертов 4
ISPOLNIMYJ mutant zona-12-kompozer UBIT — упавших ассертов 4
ISPOLNIMYJ mutant token-24 UBIT — упавших ассертов 1
ISPOLNIMYJ mutant token-20 UBIT — упавших ассертов 1
CASE s-ekran-ispolnim ok 
CASE s-emuljatory-posledovatelno ok 
CASE s-profil-maska-393 ok 
клеток 96, зелёных 96, красных 0; режим repo seed 149
rc=0

python3 /tmp/dev-harness-verify/Crit149k2b/mutate_target.py
removed required Heirat topic from GA-13/17 theme strip; other targets untouched
rc=0
W --repo /tmp/dev-harness-verify/Crit149k2b/mut-missing-target
ISPOLNIMYJ kontrol ZELEN — suites=1 tests=15
CASE s-ekran-ispolnim ok 
клеток 96, зелёных 96, красных 0; режим repo seed 149
rc=0

python3 /tmp/dev-harness-verify/Crit149k2b/mutate_pointer.py
mutated pressables: 8
rc=0
W --repo /tmp/dev-harness-verify/Crit149k2b/mut-pointer
ISPOLNIMYJ kontrol KRASEN — suites=1 tests=15
CASE s-ekran-ispolnim KRASNO ISPOLNIMYJ_KONTROL_KRASEN: зонд красен на исходных компонентах R (упавших ассертов 3)
клеток 96, зелёных 95, красных 1; режим repo seed 149
rc=1

python3 /tmp/dev-harness-verify/Crit149k2b/stuck_avd.py
е2е_rc= 1
stderr= ОТКАЗ: эмулятор emulator-5580 не остановился
events= KILL emulator-5580
avd393_started= False
rc=0
```

Мутация отсутствия Heirat в строке тем самостоятельной находкой не считается: `gespraech-tema-heirat` не числится среди 26 id в текущей `forma-ekrana.json`; доступность/полнота именно этой темы в GA-13/17 уточняется владельцем экранного манифеста, а не догадкой критика. Гарантии по классу Crit149k2a РЕАЛЬНАЯ_ЗОНА_КАСАНИЯ (для *существующих* целей), ПОРЯДОК_AVD_393 и МАСКА_ПРОФИЛЯ_393 укреплены; зависший 390 в самостоятельном исполнении e2e.sh даёт rc 1 и 393 не запускает. Гарантия потребления токена остаётся незакрытой, несмотря на зелень мутантов 24/20. Сверка frozen 149/1 → v3: прежние И-1..И-8, динамика T30/T32/T37, пачка, угрозы, зоны и класс риска сохранены, разрешённо заменены только пакет/кадры/токены/геометрия по зоне. Не проверено: нативная сборка, живые эмуляторы, продуктовый CI и Release-эталоны (ограничения задания/до freeze 147+148).
