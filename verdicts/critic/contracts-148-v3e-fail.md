FAIL
OBJECT=2d2c47893791a5544b0d67e32cd38f5841b96c83
СУД: repo=dev-harness; предмет=148; фаза=контракт v+1 (+красная батарея); роль=critic; цикл 2, вызов=5/5; модель-план=openai-codex/gpt-6-sol; сессия=Crit148k2e (UUID трейса судье не открыт); модель-факт=openai-codex/gpt-6-sol (workstation); SHA=2d2c47893791a5544b0d67e32cd38f5841b96c83; предыдущий=verdicts/critic/contracts-148-v3d-fail.md; исключение=нет.

`git cat-file -t OBJECT` → `commit`. Сообщение кандидата содержит дословную отдельную строку `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/148-vkladki-tabov.md — v+1 под компактную шкалу по пакету D24-Kompakt-1.1: заменяются версия пакета, токены и эталонные кадры; поведение, обязательства и доступность не ослабляются; цели касания судятся по зоне hw/hh, видимый размер < 44 при зоне ≥ 44 находкой не является (слово владельца 2026-11-02)`. Автор последнего упрочнения Arch148z — GLM zai/glm-5.3, судья — Sol, семейства независимы. Кандидат извлечён `git archive OBJECT | tar -x` в `/tmp/dev-harness-verify/Crit148k2e/repo`; для исторических гейтов только этому архиву добавлена собственная `.git` с тегами и HEAD=OBJECT. Основной репозиторий и авторский объект не изменены; `git worktree` в основном не создавался, push не было.

## Блокирующие классы

БЛОКИРУЕТ contracts/148-vkladki-tabov.md:57,71,85,90 — **видимая надпись подменяется видимым Text-предком с невидимыми буквами**. ОБЯЗАТЕЛЬСТВО: И-14, предмет и приёмка 8 требуют видимых подписей всех слотов; Text с `color:'transparent'` не считается видимой подписью. Класс причины: единый `nadpisUzla` (`fixtures/workshop_project/vkladki_tabov_148/produkt/vkladki-zond-148.test.tsx:331-340`) вызывает рекурсивный `tekstUzla(parent)` (`:250-265`), после чего проверяет видимость только `parent`, а не тех вложенных Text, которые содержат буквы; `proveritVidimostTseli` также принимает текст из такого предка. СОСТОЯНИЕ: полный честный R, только `{uiCopyDe[TAB_LABEL_KEYS[id]].text}` внутри внешнего Text каждого `shell-tab-*` заменён на `<Text style={{ color: 'transparent' }}>{uiCopyDe[TAB_LABEL_KEYS[id]].text}</Text>`; видимые внешние Text сохраняют честный fontSize/lineHeight, но текстовые листья прозрачны. НАБЛЮДЕНИЕ: продукт-судья на R-mutant → rc 0, KADR×8 1.000, Jest 15/15, все 22 мутанта убиты; ни `NADPIS_NEVIDIMA`, ни отказ типографики. ОБХОД: подписей четырёх вкладок не видно, а критерий готовности зелён. ЗАКРЫВАЮЩЕЕ СВОЙСТВО: для каждого ожидаемого текста проверяется видимость именно буквенных Text-листьев со всеми их родителями и правильная типографика того же видимого текста; честные видимые вложенные Text зелёные. Это заявленный домен И-14 (`transparent`), НЕ исключённый layout/клип.

БЛОКИРУЕТ contracts/148-vkladki-tabov.md:59,62,69,85,90 — **действие цели проверено только на первом профиле**. ОБЯЗАТЕЛЬСТВО: И-4/И-13 требуют собственного действующего нажатия каждой обязательной цели, И-9 задаёт также профиль 393×852; приёмка 8 обещает суд реальных целей обоих профилей. Класс причины: тесты `Б2-действие` (`produkt/vkladki-zond-148.test.tsx:727-824`) вызывают `fireEvent.press` до установки второго профиля; тесты `Б2 (профиль, раздел)` (`:854-910`) на 390 и 393 проверяют лишь существование, видимость и стиль/зону, но не действие. СОСТОЯНИЕ: в полной копии R входной проп `onBereich` в `SchutzUebersicht` назван `originalBereich`, локальный `const onBereich = Dimensions.get('window').width === 393 ? undefined : originalBereich;`; исходные Pressable/onPress/testID, все стилевые и матричные якоря сохранены. НАБЛЮДЕНИЕ: продукт-судья → rc 0, KADR×8 1.000, Jest 15/15, все 22 мутанта убиты; при достижимом 393 `onBereich` отсутствует и нажатие `schutz-optionen`/остальных целей Schutz не доставляет колбэк. ОБХОД: зелёный критерий с мёртвыми обязательными целями второго профиля. ЗАКРЫВАЮЩЕЕ СВОЙСТВО: для каждого обязательного target×profile исполнить собственное нажатие с новым правильным результатом колбэка; проверить только размеры на 393 недостаточно.

БЛОКИРУЕТ contracts/148-vkladki-tabov.md:62,69,85,90 — **узкая настоящая ширина Pressable не измеряется при flexBasis**. ОБЯЗАТЕЛЬСТВО: И-7 требует effective hit-area ≥44×44 у всех вкладок, не только достаточной высоты. Класс причины: `zonaCelej` (`produkt/vkladki-zond-148.test.tsx:388-412`) устанавливает `shirina=null` без `width/minWidth/maxWidth/hitSlop.left/right` и вообще пропускает горизонтальную проверку; Yoga flex-row между тем поддерживает `flexBasis` ширины ребёнка. СОСТОЯНИЕ: в полной копии R у `styles.tab` `flexBasis:20`, `paddingHorizontal:0`, прочие размеры высоты/токены/действия/надписи без изменений; TabBar — flexDirection row, расширения hitSlop по горизонтали нет, клип не добавлялся. НАБЛЮДЕНИЕ: продукт-судья → rc 0, KADR×8 1.000, Jest 15/15, все 22 мутанта убиты; измеритель принимает `shirina=null` при заданной flex-basis 20. ОБХОД: Pressable с базисом ширины 20 без расширения удовлетворяет приёмке зоны 44. ЗАКРЫВАЮЩЕЕ СВОЙСТВО: эффективная горизонтальная зона хозяина учитывает flex-layout, а отсутствие трёх перечисленных style-свойств не считается доказательством ширины ≥44. [INFERENCE] Численное значение ширины на устройстве вытекает из семантики RN/Yoga flexBasis; нативный эмулятор запрещён, пиксельное измерение этого входа не выдаю за проведённое.

## Атаки: команды, rc и сырой вывод

Каждый вход — отдельная полная копия `/tmp/dev-harness-verify/Arch148t/mob-ref`; копия удалялась СРАЗУ после прогона (не более одной одновременно). Скрипты-мутаторы лежали только в `/tmp/dev-harness-verify/Crit148k2e/` и после замеров удалены. Честный контроль `bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh --repo /tmp/dev-harness-verify/Arch148t/mob-ref` → rc 0, финал `CASE pr-chestnaja ok` / `клеток 37, зелёных 37, красных 0`.

A. `python3 /tmp/dev-harness-verify/Crit148k2e/mutate_hidden_child.py` → rc 0, сырой stdout: `MUTATED all four tab labels: visible outer Text retains nav typography, only text-bearing inner Text color=transparent; no replacement label`. `python3 fixtures/workshop_project/vkladki_tabov_148/produkt_sud.py --repo /tmp/dev-harness-verify/Crit148k2e/mob-hidden-child` → rc 0.

B. `python3 /tmp/dev-harness-verify/Crit148k2e/mutate_profile.py` (вторая, якорь-сохраняющая версия) → rc 0, сырой stdout: `MUTATED Schutz callback disabled on 393 only, original Pressable JSX anchors unchanged; layout/labels/zones unchanged`. `python3 fixtures/workshop_project/vkladki_tabov_148/produkt_sud.py --repo /tmp/dev-harness-verify/Crit148k2e/mob-profile-dead` → rc 0.

C. `python3 /tmp/dev-harness-verify/Crit148k2e/mutate_flex_width.py` → rc 0, сырой stdout: `MUTATED four Pressables: flexBasis=20, horizontal padding=0; height and label tokens/visibility/actions preserved, no ancestor clipping`. `python3 fixtures/workshop_project/vkladki_tabov_148/produkt_sud.py --repo /tmp/dev-harness-verify/Crit148k2e/mob-flex-width` → rc 0.

D. Вне объявленной границы угроз: `python3 /tmp/dev-harness-verify/Crit148k2e/mutate_narrow.py` → rc 0, сырой stdout: `MUTATED tabbar: width=20 overflow=hidden, height/nav tokens/Pressables/testIDs/actions unchanged`. `python3 fixtures/workshop_project/vkladki_tabov_148/produkt_sud.py --repo /tmp/dev-harness-verify/Crit148k2e/mob-narrow` → rc 0.

**Дословный полный stdout КАЖДОГО из четырёх вызовов `produkt_sud.py` A/B/C/D был одинаков** (общий блок ниже приводится без замены строк, четыре разных команды и их rc перечислены выше):
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
ISPOLNIMYJ mutant badge-opacity UBIT — упавших ассертов 1
ISPOLNIMYJ mutant vkladki-opacity UBIT — упавших ассертов 8
ISPOLNIMYJ mutant mitte-opacity-predok UBIT — упавших ассертов 9
ISPOLNIMYJ mutant nadpis-lozhnaja UBIT — упавших ассертов 1
ISPOLNIMYJ mutant schutz-rebenok UBIT — упавших ассертов 2
ISPOLNIMYJ mutant oblasti-opacity UBIT — упавших ассертов 2
ISPOLNIMYJ mutant stroki-opacity UBIT — упавших ассертов 3
ISPOLNIMYJ mutant soobschenie-display-none UBIT — упавших ассертов 3
ISPOLNIMYJ mutant nadpis-za-ekranom UBIT — упавших ассертов 1
ISPOLNIMYJ mutant badge-vsegda UBIT — упавших ассертов 1
ISPOLNIMYJ mutant pointer-events UBIT — упавших ассертов 1
```

Не засчитанная обходом первая проба профиля: `python3 /tmp/dev-harness-verify/Crit148k2e/mutate_profile.py` (первая версия, меняла JSX) → rc 0, сырой stdout `MUTATED schutz-optionen: press callback silently skips exactly profile 393, all 390 actions and both profile styles/targets preserved`; прямой `produkt_sud.py --repo /tmp/dev-harness-verify/Crit148k2e/mob-profile-dead` → rc 2. Сырой stdout: те же начальные девять строк `KADR…/SHABLON` блока выше, затем тот же набор строк `ISPOLNIMYJ kontrol ZELEN` и девяти `ISPOLNIMYJ kontrol … ZELEN`, затем `ISPOLNIMYJ mutant tabs UBIT — упавших ассертов 11`, `…badge UBIT — упавших ассертов 1`, `…skroll UBIT — упавших ассертов 1`, `…kasanie UBIT — упавших ассертов 2`, `…tokeny UBIT — упавших ассертов 1`, `…nav-final2 UBIT — упавших ассертов 1`, `…nav-literal UBIT — упавших ассертов 1`, последняя дословная строка `PRICHINA\tLIVE_MUTACIJA_NEPRIMENIMA: disabled: нет ни одной формы входа в mobile/src/features/protection/components/SchutzUebersicht.tsx`. Не используется как доказательство: матричный якорь disabled стал неприменим. Копия удалена, вход B выше исправлен и полностью прошёл.

СОВЕТ contracts/148-vkladki-tabov.md:71,242 — вход D с `width:20; overflow:'hidden'` ограничивает tabbar 20 px при зелёном судье, но **клип с ненулевым боксом исключён явно** в НЕ ЗАЩИЩАЕТ; его не смешиваю с классом C (там клипа НЕТ) и не блокирую им. Решение об изменении границы угроз принадлежит владельцу, а не критику.

## Сопоставление и выполненные проверки

Сопоставлен текст `frozen/contracts/148/1:contracts/148-vkladki-tabov.md` с OBJECT: предмет, И-1…И-10, критерии, границы ЗАЩИЩАЕТ/НЕ ЗАЩИЩАЕТ, ПРОВОДКА, класс риска и зоны исполнения сохранены кроме явно разрешённого перепина Final 2→D24-Kompakt-1.1 и снятия устаревшей маски Notice GA-03. `И-6` сверяет имя КОНКРЕТНОГО GA/профиля и старые кадры Final 2 красит именованно; `И-12` судит связь рабочего компонента с токеном, а не только скопированный tokens.css; штатные `kadry-podmenen`, `paket-final2`, `nav-final2`/`nav-literal` успешно красны. Настоящая зона — hw/hh, видимая рамка 36 при зоне 44 не признана дефектом; последовательность AVD 390→393 и точная маска 48 не сняты, `pr-ostanovka-neispolnima` и `profil-maska-ne-48` зелёны как красные клетки. Фоновая остановка из предыдущего арбитража честно объявлена НЕ ЗАЩИЩАЕТ и передана владельцу, а не заявлена доказанной. Иного ослабления явно согласованного владельцем не нашёл.

Пин пакета проверен независимо от текста: `git -C /tmp/dev-harness-verify/Impl151/mob rev-parse origin/main:docs/ux/05_Kompakt_D24` → `dbdf5c418e02f830c58267c54aeaaeca31681d0e`; SHA256 product main `frames/frames.json` == носителю `84e4b5fc52d4dd7e00f91c4c7b9fb56f7ccc5a119b0f4cd351a8199efab72a8b`, `source/manifest.json` == носителю `3fc386adb04fcbffe60bad979b2b0d53085c013bdbc63a6a905af3e6a568a633`, `frames/SHA256SUMS` == носителю `d8fe43b5f4b3850210afc8299a3fd0ab120b15eefd519f1a883d0f69687f9746`. `sha256sum --quiet -c SHA256SUMS` в product frames/ → rc 0; `frames.json._meta.summary` full 46/46. `tokens.css` в продукте и носителе → одинаковый SHA256 `49f50ad6695dbf372bdc4c06418421af69fd82bad6b22ed55742922a20cb254e`; живые `nav.height=$value49px/final2=71px`, `nav.item.min-height=48px`, `nav.label.font-size=10px/final2=11px`, `touch-target.min=44px`.

Команды в архиве кандидата (последовательно, без AVD и нативных сборок):
- `bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh` → rc 1, `клеток 57, зелёных 37, красных 20` (PACHKA_ABSENT, продукта в харнессе нет).
- То же `--model` → rc 0, `клеток 57, зелёных 57, красных 0`.
- То же `--model --seed 7` → rc 2, `probe.py: error: unrecognized arguments: --seed 7`; `--oracle-tamper` → rc 2, `probe.py: error: unrecognized arguments: --oracle-tamper` (флаги не заявлены CLI контракта).
- То же `--stabs` → rc 0, контроль 57/57, все 30 стабов s65–s94 «KRASEN», финал `SVJAZI 47`. Первая попытка отдельно прервана дедлайном 120 s после s83; полная попытка заняла 161.17 s и закончилась rc 0.
- То же `--repo /tmp/dev-harness-verify/Arch148t/mob-ref` → rc 0, `CASE pr-chestnaja ok`, `клеток 37, зелёных 37, красных 0`.
- `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model` → rc 0, все CASE ok (в архиве с подключённой git-историей).
- `bash scripts/pre_critic.sh contracts/148-vkladki-tabov.md` → rc 0, `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=6`, «КРИТИК: дверь зелёная».
- `bash scripts/check_ceilings.sh` → rc 0, «потолки в порядке».
- `bash scripts/check_precision_gate.sh . contracts/148-vkladki-tabov.md` → rc 0, `OK`.
- `bash scripts/check_threat_model.sh . contracts/148-vkladki-tabov.md` → rc 0, «ЗАЩИЩАЕТ 15 буллет(ов), НЕ ЗАЩИЩАЕТ 12 буллет(ов)».
- `bash scripts/check_spec_ready.sh . contracts/148-vkladki-tabov.md` → rc 0, `OK`.
- `bash scripts/check_provodka.sh . contracts/148-vkladki-tabov.md` → rc 1, `проводка: guard не подключён: fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh не вызывается в .githooks/ или .github/workflows/` — зона orchestrator после freeze, не выдаю это за готовую проводку.
- `bash scripts/check_zones.sh .` → rc 0, `замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 42984 · проверено по зонам: 10317` (418.91 s; последовательно с pre_critic и precision).

САМООПИСАНИЕ contracts/148-vkladki-tabov.md:75-85,267-281 — по слову владельца 2026-11-03 счёты/хэши в тексте не являются судимым блоком. Действительно перемеренные 57/37/20, 57/57, 30/SVJAZI47 приведены как сырой контекст, а не причина FAIL.

НЕ проверено: живой телефон/screenshot мутантов, реальные AVD/Maestro и нативная сборка (заданием запрещены); diagnostic PR и dispatch продуктового CI на SHA кандидата (приёмка 10 остаётся условием заморозки). Не утверждаю, что стенд-ин KADR=1.000 доказывает пиксельную точность изменённого продукта. Этот содержательный FAIL на последнем 5/5 НЕ открывает шестой вызов: далее только установленный §Остановка маршрут и явное решение владельца.
