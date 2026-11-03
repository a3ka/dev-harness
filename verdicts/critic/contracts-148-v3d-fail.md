FAIL
OBJECT=fae36499bbfce7b6e06a3635dbceaeb765019fb3
СУД: repo=dev-harness; предмет=148; фаза=контракт v+1 (+красная батарея); роль=critic; цикл 2, вызов=4/5; модель-план=openai-codex/gpt-6-sol; сессия=Crit148k2d (UUID трейса судье не открыт); модель-факт=openai-codex/gpt-6-sol (workstation); SHA=fae36499bbfce7b6e06a3635dbceaeb765019fb3; предыдущий=verdicts/critic/contracts-148-v3c-fail.md; исключение=нет.

Кандидат — коммит (`git cat-file -t OBJECT` → `commit`), последняя дельта от f55e7a79f — пять путей контракта/батареи. `git show -s --format=%B OBJECT`: второй абзац дословно `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/148-vkladki-tabov.md — v+1 под компактную шкалу по пакету D24-Kompakt-1.1: заменяются версия пакета, токены и эталонные кадры; поведение, обязательства и доступность не ослабляются; цели касания судятся по зоне hw/hh, видимый размер < 44 при зоне ≥ 44 находкой не является (слово владельца 2026-11-02)`; дерево OBJECT совпадает с деревом 537436976 до reword. Архив OBJECT извлечён в изолированный `/tmp/dev-harness-verify/Crit148k2d/repo`, история и теги добавлены в ЕГО собственный `.git`, основной репозиторий не менялся. Автор последнего упрочнения Arch148w — zai/glm-5.3 по заданию/отчёту; судья — openai-codex/gpt-6-sol, семьи разные. Отсутствующих предмета, rc-критерия, исполнителей/ЗОНА, класса риска или модели угроз не найдено. Frozen 148/1 сопоставлен с v+1: шов, содержание вкладок, бейдж, темы/профили, порядок AVD, порог изображения, зона касания и CI-обязательства сохранены; снятые специальные ожидания GA-09/14/18/19 и каталогизированная вместо маски Notice-зона названы; системная маска 393 остаётся ровно 48.

## Блокирующие классы

БЛОКИРУЕТ contracts/148-vkladki-tabov.md:52,57,83,87 — ВИДИМАЯ НАДПИСЬ подменена текстовым потомком. Класс причины: `produkt/vkladki-zond-148.test.tsx:282-285` проверяет нахождение узла `gespraech-mitte-badge` в дереве и `props.children`, а `:582-594` находит текст подписи вкладки и сверяет только fontSize/lineHeight. Ни одна из проверок не доказывает, что буквы отрисованы видимо; KADR×8 продукт-судьи здесь стенд-ины, генерируемые из пиннованных PNG, а не изображения изменённого компонента. ОБЯЗАТЕЛЬСТВО: предмет и И-2 требуют видимый бейдж «Ihre Rückmeldung nötig» GA-03 и видимые подписи пяти слотов; приёмка 4/8 заявляет суд реальных компонентов. СОСТОЯНИЕ: полная копия зелёного продукта R; только `mobile/src/bootstrap/gespraech-mitte.tsx`: `badgeText: { fontSize: 10 }` → `{ fontSize: 10, opacity: 0 }` (GA-03), либо отдельно `mobile/src/bootstrap/tab-shell.tsx`: в стиле `tabLabel` добавить `opacity: 0`, сохранив `navTokens.labelFontSize/labelLineHeight`, тексты, действия и пины. НАБЛЮДЕНИЕ: на первом входе `produkt_sud.py --repo R_mut` rc 0, KADR×8 1.000, Jest suites=1 tests=15 и все 11 внутренних мутантов убиты; на втором `W --repo R_mut` rc 0, 37/37. По семантике RN `opacity: 0` прячет видимые буквы, хотя они остаются потомком с прежним текстом и токенами. ОБХОД: надписи GA-03/табов на телефоне невидимы при зелёной названной приёмке. ЗАКРЫВАЮЩЕЕ СВОЙСТВО: суд различает реально видимую подпись каждого обязательного состояния GA/профиля от текстового узла, визуально скрытого стилем (в том числе прозрачностью); честный продукт зелён, прозрачная подпись красна. Способ достижения не предписывается; одной `getByText`/`toBeOnTheScreen` без видимости недостаточно.

БЛОКИРУЕТ contracts/148-vkladki-tabov.md:57,62,83,87 — ЗОНА ДОЧЕРНЕГО УЗЛА принята за зону нажимаемого Pressable. Класс причины: `produkt/vkladki-zond-148.test.tsx:201-249` меряет `screen.getByTestId(id)` без установления, что этот узел является интерактивным хозяином; `fireEvent.press` по ребёнку проходит к обработчику родителя. ОБЯЗАТЕЛЬСТВО: И-7 и слово владельца 02.11 требуют реальную эффективную hit-area каждой обязательной цели ≥44×44, а не размер дочернего текста; И-4/И-13 — действие нажатия этой цели. СОСТОЯНИЕ: на полной копии R у Schutz `schutz-optionen` переместить `testID` на дочерний Text с `minHeight:44,minWidth:44`; оставшийся родительский Pressable с прежним `onPress` сделать `width:20,height:20,minHeight:0,overflow:'hidden'`, без hitSlop, все остальные файлы неизменны. НАБЛЮДЕНИЕ: продукт-судья rc 0, KADR×8 1.000, 15 тестов и 11 мутантов; полная `W --repo` rc 0, 37/37, хотя реально принимающая нажатие область родительского Pressable 20×20. ОБХОД: действующая на программном `fireEvent.press` карточка «Optionen ansehen» недоступна касанием в требуемой зоне при зелёной приёмке. ЗАКРЫВАЮЩЕЕ СВОЙСТВО: измерять эффективную hit-area ИНТЕРАКТИВНОГО узла, реально принимающего нажатие, на каждом обязательном ID и обоих профилях; 20×20 Pressable с ребёнком 44×44 красен, валидные padding/minHeight/hitSlop формы остаются зелёными. Это отдельный класс от скрытого текста.

## Сырые атакующие прогоны (только одноразовые полные копии R)

Вход 1: `cp -a /tmp/dev-harness-verify/Arch148t/mob-ref /tmp/dev-harness-verify/Crit148k2d/mob-badge-opacity; python3 mutate_opacity.py; python3 fixtures/workshop_project/vkladki_tabov_148/produkt_sud.py --repo /tmp/dev-harness-verify/Crit148k2d/mob-badge-opacity` → rc 0 (первый скрипт менял только `badgeText` как описано):
```text
MUTATED badgeText opacity:0; text, testID, accessibility, tokens untouched
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
ISPOLNIMYJ kontrol zona ZELEN — конформная зона по правилам RN
ISPOLNIMYJ kontrol padding-22 ZELEN — конформная зона по правилам RN
ISPOLNIMYJ kontrol padding-16 ZELEN — конформная зона по правилам RN
ISPOLNIMYJ kontrol padding-vertical ZELEN — конформная зона по правилам RN
ISPOLNIMYJ kontrol padding-storony ZELEN — конформная зона по правилам RN
ISPOLNIMYJ kontrol max-pol ZELEN — конформная зона по правилам RN
ISPOLNIMYJ kontrol hitSlop ZELEN — конформная зона по правилам RN
ISPOLNIMYJ kontrol padding-pri-javnom-bokse ZELEN — конформная зона по правилам RN
ISPOLNIMYJ mutant tabs UBIT — упавших ассертов 11
ISPOLNIMYJ mutant badge UBIT — упавших ассертов 1
ISPOLNIMYJ mutant skroll UBIT — упавших ассертов 1
ISPOLNIMYJ mutant kasanie UBIT — упавших ассертов 2
ISPOLNIMYJ mutant tokeny UBIT — упавших ассертов 1
ISPOLNIMYJ mutant nav-final2 UBIT — упавших ассертов 1
ISPOLNIMYJ mutant nav-literal UBIT — упавших ассертов 1
ISPOLNIMYJ mutant disabled UBIT — упавших ассертов 1
ISPOLNIMYJ mutant filter-bez-dejstvija UBIT — упавших ассертов 1
ISPOLNIMYJ mutant vorgaenge-stroki-net UBIT — упавших ассертов 3
ISPOLNIMYJ mutant padding-tolko-gorizontal UBIT — упавших ассертов 2
```
Вход 2: в новой полной копии R `mutate_tab.py` добавил `opacity:0` только к `tabLabel`; `bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh --repo /tmp/dev-harness-verify/Crit148k2d/mob-tab-opacity` → rc 0:
```text
MUTATED tabLabel opacity:0; token linkage, labels and actions unchanged
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
```
Вход 3: новая копия R, `mutate_schutz_child.py` изменил только `SchutzUebersicht.tsx` как описано; `python3 fixtures/workshop_project/vkladki_tabov_148/produkt_sud.py --repo /tmp/dev-harness-verify/Crit148k2d/mob-schutz-child` → rc 0:
```text
MUTATED Schutz Optionen parent Pressable 20x20/no hitSlop; child Text testID minHeight/minWidth44; callback unchanged
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
ISPOLNIMYJ kontrol zona ZELEN — конформная зона по правилам RN
ISPOLNIMYJ kontrol padding-22 ZELEN — конформная зона по правилам RN
ISPOLNIMYJ kontrol padding-16 ZELEN — конформная зона по правилам RN
ISPOLNIMYJ kontrol padding-vertical ZELEN — конформная зона по правилам RN
ISPOLNIMYJ kontrol padding-storony ZELEN — конформная зона по правилам RN
ISPOLNIMYJ kontrol max-pol ZELEN — конформная зона по правилам RN
ISPOLNIMYJ kontrol hitSlop ZELEN — конформная зона по правилам RN
ISPOLNIMYJ kontrol padding-pri-javnom-bokse ZELEN — конформная зона по правилам RN
ISPOLNIMYJ mutant tabs UBIT — упавших ассертов 11
ISPOLNIMYJ mutant badge UBIT — упавших ассертов 1
ISPOLNIMYJ mutant skroll UBIT — упавших ассертов 1
ISPOLNIMYJ mutant kasanie UBIT — упавших ассертов 2
ISPOLNIMYJ mutant tokeny UBIT — упавших ассертов 1
ISPOLNIMYJ mutant nav-final2 UBIT — упавших ассертов 1
ISPOLNIMYJ mutant nav-literal UBIT — упавших ассертов 1
ISPOLNIMYJ mutant disabled UBIT — упавших ассертов 1
ISPOLNIMYJ mutant filter-bez-dejstvija UBIT — упавших ассертов 1
ISPOLNIMYJ mutant vorgaenge-stroki-net UBIT — упавших ассертов 3
ISPOLNIMYJ mutant padding-tolko-gorizontal UBIT — упавших ассертов 2
```
На том же входе 3 полная `W --repo /tmp/dev-harness-verify/Crit148k2d/mob-schutz-child` → rc 0, сырые финальные строки `CASE pr-chestnaja ok` / `клеток 37, зелёных 37, красных 0` (все 36 строк формы `CASE ... ok` идентичны входу 2 выше).

Не засчитанные обходом уточняющие пробы: совместная замена badgeText+tabLabel на `display:'none'` → rc 1 `ISPOLNIMYJ_KONTROL_KRASEN … (упавших ассертов 2)`; отдельно badgeText `display:'none'` → rc 1 `… (упавших ассертов 1)` — RNTL различает display none. Первая мутация child-ID для `post-filtr-nastrojki` → rc 2 `LIVE_MUTACIJA_NEPRIMENIMA: hitSlop: нет ни одной формы входа в mobile/src/features/post/components/PostEingang.tsx` (матрица внутренних зелёных контролей требует неизменную форму Filter); поэтому доказательство класса зоны — отдельный Schutz-вход 3, у которого все контроли исполнялись. Эти неуспешные входы не объявлены зелёным доказательством. Все копии и временные скрипты удалены после исполнения.

## Промер, пины и границы

- `W` без флага → rc 1 `клеток 57, зелёных 37, красных 20` (отсутствующий продукт PACHKA_ABSENT); `W --model` → rc 0 `57/57/0`; `W --model --seed 7` → rc 2 дословно `probe.py: error: unrecognized arguments: --seed 7`; `W --oracle-tamper` → rc 2 `probe.py: error: unrecognized arguments: --oracle-tamper` (оба флага НЕ заявлены CLI/контрактом); `W --stabs` → rc 0 `57/57/0`, все 30 стабов s65–s94 KRASEN, `SVJAZI 47`; `W --repo /tmp/dev-harness-verify/Arch148t/mob-ref` → rc 0 `37/37/0`. `jq` по `source.json`: cases=57, stubs=30, links=47, rc0=2/rc1=48/rc2=7. Прямой `produkt_sud.py --repo` на исходном R → rc 0, восемь `KADR … 1.000/0.600 OK`, `SHABLON OK`, suites=1 tests=15, девять зелёных контролей/одиннадцать убитых мутантов, в том числе `vorgaenge-stroki-net` (3 ассерта). Прошлые классы Crit148k2c: R с Filter без обработчика → rc 1 `TSEL_NAZHATIE_NE_DEJSTVUET post-filtr-nastrojki`; R с вертикальным padding16+Text14 → rc 0 (конформная реальная зона принята).
- `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model` → rc 0, все напечатанные CASE ok. `bash scripts/pre_critic.sh contracts/148-vkladki-tabov.md` → rc 0 `КРИТИК: дверь зелёная`; `bash scripts/check_ceilings.sh` → rc 0 `потолки в порядке`; `bash scripts/check_precision_gate.sh . contracts/148-vkladki-tabov.md` → rc 0 `OK`; `bash scripts/check_threat_model.sh . contracts/148-vkladki-tabov.md` → rc 0 `ЗАЩИЩАЕТ 15 … НЕ ЗАЩИЩАЕТ 12`; `bash scripts/check_spec_ready.sh . contracts/148-vkladki-tabov.md` → rc 0 `OK`; `bash scripts/check_provodka.sh . contracts/148-vkladki-tabov.md` → rc 1 `guard не подключён` — назначенная зона orchestrator после freeze, не принимается за подключённый guard. `bash scripts/check_zones.sh .` → rc 0, `замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 42946 · проверено по зонам: 10279` (после добавления локальных mint-тегов; первый архивный прогон без mint-тегов дал ложный rc 1 для чужого 996 — артефакт неполного git-окружения копии, НЕ дефект OBJECT).
- `git -C /tmp/dev-harness-verify/Impl151/mob rev-parse origin/main:docs/ux/05_Kompakt_D24` == `d4aa406:docs/ux/05_Kompakt_D24` == `dbdf5c418e02f830c58267c54aeaaeca31681d0e`; sha256 трёх носителей батареи `frames/SHA256SUMS`, `frames/frames.json`, `source/manifest.json` совпадают с `git show origin/main:`; `sha256sum --quiet -c SHA256SUMS` в каталоге frames → rc 0 (190/190). Источник `frames.json._meta.summary`: 46/46 full, 0 partial, 188 frames; `source/manifest.json`: 46 экранов, 699 целей, 0 меньше 44, для GA-02/03/04/09 94 (48@390, 46@393); `source/tokens.json`: 265 `$value`, 264 `$type`, 84 `final2`; nav.height=$value49px/final271px, nav.item.min-height=48px, nav.label.font-size=$value10px/final211px, touch-target.min=44px; product tokens.css совпадает с носителем sha256 `49f50ad6695dbf372bdc4c06418421af69fd82bad6b22ed55742922a20cb254e`. `source.json` манифест профиля mera.chrome_verh_pt=48, обычного=36; Final2-пин и чужое GA-04 имя вместо GA-02 краснеют в `W --model` именованными гейтами (сверка стенд-ина сама при честном старом пине 1.000; число score=0.441 из задания этим прогоном НЕ измерялось и не приписывается ему). САМООПИСАНИЕ contracts/148-vkladki-tabov.md:1,52-70,78-100,107-135,260-278 — сверенные счётные/путевые утверждения кандидата расходиться с живыми источниками не обнаружены; исторические цифры зон в чужих отчётах относятся к другим tip/моментам и самим контрактом не заявлены.

НЕ проверено: реальные AVD/Maestro, native build, живой PR/dispatch CI продукта на этом SHA, скриншот изменённых компонентов с телефона (эмуляторы/нативные сборки запрещены заданием). Фактическая визуальная невидимость `opacity:0` и ограничение hit area родительским Pressable — стандартная семантика React Native, не выданы за замер пикселей на телефоне. Остаток фоновой остановки AVD честно объявлен НЕ ЗАЩИЩАЕТ и требует решения владельца, не подменён зелёным. Ни авторский OBJECT, ни основной чекаут не изменялись; verdict — оркестратору для внесения в main.
