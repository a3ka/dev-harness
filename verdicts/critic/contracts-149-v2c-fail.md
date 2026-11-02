FAIL
OBJECT=acbb343222c6486bbc090bf36e5eafb549e18f77
СУД: repo=dev-harness; предмет=149; фаза=контракт v+1 (+красная батарея); цикл 2, вызов 3/5; роль=critic; модель-план=openai-codex/gpt-6-sol; сессия=Crit149k2c; модель-факт=openai-codex/gpt-6-sol; SHA=acbb343222c6486bbc090bf36e5eafb549e18f77; предыдущий=contracts-149-v2b-fail.md; исключение=нет. `git cat-file -t OBJECT` → commit; HEAD изолированного клона = OBJECT. Конструкцию писал GLM zai/glm-5.3; судья Sol, независимость соблюдена. Во всех трёх коммитах a5c68cac6, 264e46873, acbb34322 — одна и та же точная строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ с буквальным путём контракта первым (`git log -3`). Судился контракт, не implementer.

## БЛОКИРУЕТ

БЛОКИРУЕТ contracts/149-gespraech-tekst-chat.md:59,72,76,199 — класс ЛОЖНЫЙ_ОТКАЗ_ЗОНЫ: допустимая зона касания 44×44 объявлена красной из-за меньшего `minWidth/minHeight`, хотя заданы `width/height` по 44.
ОБЯЗАТЕЛЬСТВО: И-5 и слово владельца 02.11 предписывают судить эффективную настоящую hit-area по hw/hh против `touch-target.min`, а не способ объявления минимальных полов или видимую рамку. При зоне ≥44 допустимый компонент зелён на обоих профилях.
СОСТОЯНИЕ: зелёное дерево R `/tmp/dev-harness-verify/Arch149s/a-derevo4`, копия `/tmp/dev-harness-verify/Crit149k2c/mut-valid-effective-zone`; в `ChatComposer.styles.knopka` только `minHeight/minWidth: 44 → 36`, одновременно `height:44,width:44`. Эффективный размер RN Pressable ≥44×44, список целей, нажатия, токены, оба профиля и пакет не меняются.
НАБЛЮДЕНИЕ: `python3 /tmp/dev-harness-verify/Crit149k2c/mutate_zone.py` rc 0; `W --repo /tmp/dev-harness-verify/Crit149k2c/mut-valid-effective-zone` rc **1**, сырой stdout/stderr (решающие строки; все прочие CASE `ok`):
```
Effective 44x44 through explicit height/width, lower min floors 36x36
ISPOLNIMYJ kontrol KRASEN — suites=1 tests=15
CASE s-ekran-ispolnim KRASNO ISPOLNIMYJ_KONTROL_KRASEN: зонд красен на исходных компонентах R (упавших ассертов 2)
клеток 96, зелёных 95, красных 1; режим repo seed 149
rc=1
```
Причина `produkt/gespraech-zond-149.test.tsx:114-116`: `sloi.minWidth ?? sloi.width` и `sloi.minHeight ?? sloi.height` предпочитают 36 фактическим width/height 44. Симметричный допустимый случай `height:36,minHeight:44` обнаружен у соседа 148, но здесь также доказана собственная мутация.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: все допустимые способы задания эффективной зоны ≥ токена (включая одновременно width/height и minWidth/minHeight) зелены, а реально уменьшенная зона красна; видимый размер — отдельное свойство.

БЛОКИРУЕТ contracts/149-gespraech-tekst-chat.md:59,72,76,201 — класс НЕДЕЙСТВУЮЩАЯ_ОБЯЗАТЕЛЬНАЯ_ЦЕЛЬ: суд проверяет наличие и размер, но не действие *каждой* объявленной цели.
ОБЯЗАТЕЛЬСТВО: И-5 — проходимость 26 целей; сценарии 5 и 8(б) требуют НАЛИЧИЕ/ДЕЙСТВИЕ каждого обязательного pressable в объявленном состоянии. `gespraech-topic-heirat-erzaehlen` входит в `pachka/forma-ekrana.json:prokhodimost.pressable` и в карту `SOSTOJANIJA_I_TSELI.plaschki`, должен вести к письму.
СОСТОЯНИЕ: копия зелёного R `/tmp/dev-harness-verify/Crit149k2c/mut-disabled-target`, единственная предметная правка к Pressable темы «Heirat»: `disabled={t.id === 'heirat'}`. Кнопка видна, testID и зона ≥44 остаются, `onPress` прежний, но нажать её пользователь не может; остальные цели/экраны/пакет без изменений.
НАБЛЮДЕНИЕ: `python3 /tmp/dev-harness-verify/Crit149k2c/mutate_disabled.py` rc 0; `W --repo /tmp/dev-harness-verify/Crit149k2c/mut-disabled-target` rc **0**. Сырой решающий вывод (остальные CASE также `ok`):
```
Heirat erzaehlen remains visible and 44x44 but disabled, all other pressables unchanged
ISPOLNIMYJ kontrol ZELEN — suites=1 tests=15
ISPOLNIMYJ token-podmena ZELEN — lineHeight 21px→23px
ISPOLNIMYJ mutant host-pustoj UBIT — упавших ассертов 9
ISPOLNIMYJ mutant kompozer-ne-izmenen UBIT — упавших ассертов 14
ISPOLNIMYJ mutant zona-12-host UBIT — упавших ассертов 4
ISPOLNIMYJ mutant zona-12-kompozer UBIT — упавших ассертов 3
ISPOLNIMYJ mutant token-24 UBIT — упавших ассертов 4
ISPOLNIMYJ mutant token-20 UBIT — упавших ассертов 4
ISPOLNIMYJ mutant token-literal-21 UBIT — упавших ассертов 1
ISPOLNIMYJ mutant bez-chipov-ga19 UBIT — упавших ассертов 3
ISPOLNIMYJ mutant bez-golosa-v-polje UBIT — упавших ассертов 3
CASE s-ekran-ispolnim ok 
клеток 96, зелёных 96, красных 0; режим repo seed 149
rc=0
```
Зонд `sudSostojanija` в `produkt/gespraech-zond-149.test.tsx:215-239` проверяет только существование и стили зоны; переходы тестируются для `auto`, но не для `heirat` (или каждой иной объявленной темы).
ОБХОД: оставить объявленный 44×44 pressable в дереве и пачке, отключить его: зеленая сдача при непроходимом объявленном пути.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: действие каждой обязательной цели в каждом предусмотренном состоянии проверяемо; выключение/обездвиживание любой такой цели красно, отсутствие цели красно, валидная геометрия не отвергается.

## Предыдущие блоки, пробы, rc

Свойства Crit149k2b «литерал 21 не потребляет токен» и «отсутствуют обязательные чипы GA-19/голос в поле» закрыты: два прохода зонда (21→23) зелены, литерал и отсутствие краснеют. Новый блок про действие существующей, но выключенной цели — иной достижимый случай. Свойства Crit149k2a для уменьшенной реальной зоны, неверного значения токена (20/24), последовательной пары AVD и маски всех 12 кадров 393=48 соблюдены. Собственное исполнение канонического e2e.sh с застрявшим 5580 в песочнице двойников: `python3 /tmp/dev-harness-verify/Crit149k2c/stuck_avd.py; echo rc=$?` печатает дословно `e2e_rc= 1`, `stderr= ОТКАЗ: эмулятор emulator-5580 не остановился`, `events= KILL emulator-5580`, `avd393_started= False`, `rc=0`.

`W=bash fixtures/workshop_project/gespraech_tekst_149/red_gespraech_tekst_149.sh`; все команды запускались из изолированного клона, `echo rc=$?` после команды:
```
W                                     rc=1  клеток 96, зелёных 78, красных 18; режим koren seed 149
W --model                             rc=0  клеток 96, зелёных 96, красных 0; режим model seed 149
W --model --seed 7                    rc=0  клеток 96, зелёных 96, красных 0; режим model seed 7
W --stabs                             rc=0  STAB emuljatory-odnovremenno KRASEN AVD393_ZAPUSCHEN_DO_OSTANOVKI
                                               STAB maska-36 KRASEN PROFIL_MASKA_NE_48
                                               SVJAZI 19
                                               клеток 96, зелёных 96, красных 0; режим stabs seed 149
W --stabs --seed 7                    rc=0  SVJAZI 19; клеток 96, зелёных 96, красных 0; режим stabs seed 7
W --oracle-tamper                     rc=0  ORACLE_TAMPER_PROVERENO nositelej=135
W --repo /tmp/dev-harness-verify/Arch149s/a-derevo4
                                      rc=0  ISPOLNIMYJ kontrol ZELEN — suites=1 tests=15
                                               ISPOLNIMYJ token-podmena ZELEN — lineHeight 21px→23px
                                               клеток 96, зелёных 96, красных 0; режим repo seed 149
W --repo /tmp/dev-harness-verify/Arch149r/a-derevo3
                                      rc=1  CASE s-ekran-ispolnim KRASNO ISPOLNIMYJ_KONTROL_KRASEN: зонд красен на исходных компонентах R (упавших ассертов 5)
                                               клеток 96, зелёных 95, красных 1; режим repo seed 149
W --repo /tmp/dev-harness-verify/Arch149s/ataka-token-literal-21
                                      rc=1  ISPOLNIMYJ token-podmena KRASEN — lineHeight 21px→23px
                                               CASE s-ekran-ispolnim KRASNO ISPOLNIMYJ_TOKEN_NE_POTREBLJON: высота поля не следует за токеном — подмена lineHeight 21px→23px красна (упавших ассертов 1); совпадение текущего числа связью с токеном не является
                                               клеток 96, зелёных 95, красных 1; режим repo seed 149
bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model
                                      rc=0  CASE w22-limit-back-chetyre ok
bash scripts/pre_critic.sh contracts/149-gespraech-tekst-chat.md
                                      rc=0  КРИТИК: дверь зелёная
bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Crit149k2c/repo
                                      rc=0  потолки в порядке
bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Crit149k2c/repo contracts/149-gespraech-tekst-chat.md
                                      rc=0  OK
bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Crit149k2c/repo contracts/149-gespraech-tekst-chat.md
                                      rc=0  модель угроз: секция валидна (ЗАЩИЩАЕТ 19 буллет(ов), НЕ ЗАЩИЩАЕТ 10 буллет(ов))
bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Crit149k2c/repo contracts/149-gespraech-tekst-chat.md
                                      rc=0  OK
bash scripts/check_provodka.sh /tmp/dev-harness-verify/Crit149k2c/repo contracts/149-gespraech-tekst-chat.md
                                      rc=1  проводка: guard не подключён: fixtures/workshop_project/gespraech_tekst_149/red_gespraech_tekst_149.sh не вызывается в .githooks/ или .github/workflows/
bash scripts/check_zones.sh /tmp/dev-harness-verify/Crit149k2c/repo contracts/149-gespraech-tekst-chat.md
                                      rc=0  замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 42566 · проверено по зонам: 10127
```
Последний долгий вызов check_zones был автоматически перенесён средой в `bg_925`: дождался результата 417.12 с и rc 0 до вердикта. `check_provodka` rc 1 — ожидаемая зона orchestrator до CI-проводки, самостоятельным дефектом кандидата не признан.

## САМООПИСАНИЕ — полный список сверенных расхождений

Расхождений в действующем тексте **нет**. Пересчитаны: a64+d10+m10+s12=96, корень 78/18, model 96/96 с seeds 149/7, stabs 19 KRASEN и `source.json:stab_vhod`=19 с seeds 149/7, oracle=135 (`piny.nositeli`=135, `piny.sha`=135), repo 96/96, suites=1 tests=15, девять мутантов убиты (9/14/4/3/4/4/1/3/3); 26 pressable/шесть состояний, 12+12 кадров, все 12 верхних масок 393=48. Пакет 1.1: 188 кадров, 46/46 full, 190 строк SHA256SUMS, 699 целей/under_44=0 (видимых <44: 16), `$value`=265/`$type`=264/`final2`=84, 872 скалярных листа, строка 21px/потолок calc(6 * 21px). Пять мета-файлов (`manifest.json`, `tokens.json`, `frames.json`, `SHA256SUMS`, `motion-delta.md`) и `GA-11_normal_dark_390x844.png` побайтово равны `git -C /tmp/dev-harness-verify/Impl151/mob show origin/main:docs/ux/05_Kompakt_D24/...`. Актуальный текст не закрепляет плавающий счёт зон; на данном клоне он 42566/10127. Исторические значения v1/v2/v3 названы историческими, прежние 84→135 исправлены.

Сверка с `frozen/contracts/149/1`: И-1..И-8, T30/T32/T37, 26 целей, ПРОВОДКА, threat boundary, риск «обычный» и зоны сохранены; заменены только разрешённые версия пакета/имена кадров/токены/геометрия по эффективной зоне. Не проверено: реальные Android-эмуляторы, нативная сборка, продуктовый CI/Release-байты и экран на телефоне — ограничения задания/предыдущие freeze 147+148 ещё не влиты. `--model` — доказательство модели, отдельно выше предъявлен суд R.
