FAIL
OBJECT=7482b8d8bcfa2d70d34d456c5dde18a9c47a1dbb

# Критик — контракт 999, круг 2

Предмет: `contracts/999-cmp-mob-002-navigatsiya.md` и предъявленные им красные критерии на указанном закоммиченном HEAD. Сужу до заморозки, не реализацию Complior-mob. Набор артефактов полный: предмет, команды готовности, исполнители и ЗОНА-строки присутствуют. `pre_critic.sh` исполнен первым барьером после закрепления объекта, rc=0. Полное тело Complior-mob#6, `roles/critic.md`, `AGENTS.md`, вердикт первого круга из origin/main и репро первого круга прочитаны.

**Итог:** все 11 конкретных обходов первого круга теперь красные; прежний combined тоже красный. Блокер 5 первого круга — неисполнение всех колонок copy/static — закрыт. Но обобщённого закрытия остальных четырёх классов нет: семь новых независимых мутаций проходят все четыре обычные пробы. Их совмещённое дерево проходит также все четыре `--matrix`, хотя независимый RNTL-рендер обнаруживает восемь нарушений предмета. Это не требование новой функциональности: нарушены свойства строк 40–44 и объявленные перечни строк 53–56.

## Закрытие пяти блокеров первого круга

| Класс | Что действительно закрыто | Остаток |
|---|---|---|
| 1. Навигационные состояния | initialSection всех четырёх вкладок; selected для Start; возврат из профиля каждой вкладки; 16 пар deep-link initial×return | Переключение вкладок проверяется одной последовательностью, не таблицей исходная×целевая. Запрет команды не наблюдается при reducedMotion. Находка 1 ниже. |
| 2. Примитивы / accent | Button variant×theme, dark Notice role, dark TextField secure, подписи Button | disabled secondary отсутствует среди проверяемых состояний; текст самого TextInput и заголовки остальных разделов не входят в accent-наблюдение. Находка 2. |
| 3. Контейнеры | Прямые подмены SafeAreaView/KeyboardAvoidingView обычным View отвергаются | Наличие компонента где-либо в дереве не доказывает его участие в контейнеризации содержимого. Находка 3. |
| 4. Copy поверхности | Изобретённый Back на прежних входах отвергается; обход строковых листьев действительно есть | Перечень состояний не включает light-поверхность. Находка 4. |
| 5. Матрицы copy/static | Обе матрицы исполняют все колонки, проверяют unexpected_red и depends_missed; status-lost объявляет COPY_TEXT зависимостью | Закрыт. Возвращать этот прежний блокер оснований нет. |

## Блокирующие находки

### 1. Перечень вкладок не замыкает переходы и режим reduced motion

БЛОКИРУЕТ contracts/999-cmp-mob-002-navigatsiya.md:53 — selected при переключении «всех четырёх» не доказывает переходы между этими вкладками; критерий :64–65 слабее навигационного предмета :34 и инварианта :44. `fixtures/workshop_project/nav_999/nav.test.tsx:49–61` проходит только последовательность Start→Start→Vorgänge→Schutz→Post. Декартово произведение :88–102 относится к Back/deep link, а не к нажатию tab. `TAB_SWITCH_NO_COMMAND` (:64–74) исполняется без reducedMotion; `REDUCED_MOTION_ACTIONS` (:125–139) не передаёт наблюдатель onCommand.
ОБХОД: в `mobile/src/bootstrap/tab-shell.tsx` заменить `onPress={() => setSection(id)}` на `onPress={() => { if (!(section === 'post' && id === 'vorgaenge')) setSection(id); }}`. Из Post нельзя открыть Vorgänge нажатием вкладки, но nav/ui/static/copy возвращают 0. Независимый вход `initialSection="post"`, затем нажатие Vorgänge, не получает выбранную Vorgänge. Это мутация `transition-post-vorgaenge` в `audit.py`.

Второй, независимый представитель пропущенной оси: тот же handler заменить на `onPress={() => { setSection(id); if (reducedMotion) onCommand?.({ kind: 'mission.create' }); }}`. Переключение с reducedMotion отправляет команду создания Mission, но все четыре пробы возвращают 0 (`reduced-motion-emits-command`). В combined присутствуют оба дефекта; все четыре `--matrix` тоже возвращают 0. Независимый наблюдатель onCommand при reducedMotion красен.

Обобщённая граница исправления — перечислить исходное состояние и целевое действие, а также режим, в котором действует запрет побочного эффекта. Добавить лишь особый тест Post→Vorgänge недостаточно для объявленной исчерпывающей таблицы.

### 2. У клеток UI отсутствуют заявленные свойства и наблюдаемые текстовые поверхности

БЛОКИРУЕТ contracts/999-cmp-mob-002-navigatsiya.md:54 — «в каждой клетке все заявленные свойства» не обеспечено критерием :64: `BUTTON_DISABLED_STATE` (`ui.test.tsx:92–104`) перебирает темы, но использует только default primary. TextField (:124–140) проверяет цвет label, не цвет введённого текста/его поверхности. `ACCENT_NOT_TEXT_ON_LIGHT` (:155–175) смотрит только заголовок Start, tab labels и profile entry, не остальные заголовки. Это противоречит уже заявленным disabled (:42) и accent-инварианту (:41), а не добавляет новые требования.
ОБХОД: в `mobile/src/ui/button.tsx` заменить `accessibilityState={{ disabled }}` на `accessibilityState={{ disabled: disabled && variant === 'primary' }}` и `disabled={disabled}` на `disabled={disabled && variant === 'primary'}`. Disabled secondary остаётся активной и вызывает callback; все четыре обычные пробы зелёные (`secondary-disabled-ignored`), все матрицы зелёные в combined. Независимое нажатие disabled secondary в light вызывает onPress и краснит проверку.

Два дополнительных независимо исполненных представителя того же незамкнутого списка свойств/поверхностей:

- `input-accent-text`: в `mobile/src/ui/text-field.tsx` заменить `backgroundColor: tokens.panel, color: tokens.ink` на `backgroundColor: tokens.panel, color: tokens.accent`. Label остаётся корректным, но введённый текст становится лаймовым на светлой panel. Все четыре пробы rc=0.
- `nonstart-accent-title`: у `section-title-${section}` заменить `color: tokens.ink` на `color: section === 'start' ? tokens.ink : tokens.accent`. Start остаётся правильным, заголовки Vorgänge/Schutz/Post — лаймовые в light. Все четыре пробы rc=0.

Оба также включены в combined. Независимый рендер наблюдает запрещённый цвет у TextInput и заголовка Schutz; соответствующие assertions красные, на эталоне зелёные. Словарь токенов и hex-scan здесь ничего не ловят: используются существующие токены.

### 3. Заявлено тождество контейнера над содержимым, проверено существование где-либо

БЛОКИРУЕТ contracts/999-cmp-mob-002-navigatsiya.md:55 — обещание «ближайший композит над хостом shell-safe-area / shell-keyboard-container» не измеряется. `ui.test.tsx:40–49,144–152` считает любой узел, у которого соответствующий компонент встречается в цепочке предков; затем отдельно проверяет testID. Связь с названным хостом и содержимым не проверяется.
ОБХОД: заменить реальные обёртки shell-safe-area и shell-keyboard-container обычными View, сохранив testID, стили и всё содержимое. Под общим корневым View добавить соседние ветви `<SafeAreaView><View /></SafeAreaView>` и `<KeyboardAvoidingView><View /></KeyboardAvoidingView>`. Настоящие компоненты существуют, но раздел/профиль не находятся внутри них. Все четыре обычные пробы возвращают 0 (`containers-detached`); в combined также все четыре матрицы rc=0. Независимая проверка предков `section-start` не находит ни SafeAreaView, ни KeyboardAvoidingView; обе проверки на эталоне проходят, на обходе падают.

Это всё ещё контейнер-пустышка, а не запрос физической Android-проверки: неверность композиции наблюдаема тем же RNTL/fiber-швом. Строка :55 уже требует более сильную связь, чем `compositeCount(root, component)>0`.

### 4. Copy-каталог сверяется только для одной темы поверхности

БЛОКИРУЕТ contracts/999-cmp-mob-002-navigatsiya.md:56 — объявленный закрытый перечень состояний слабее dark/light-предмета :34 и запрета новых формулировок :43. Все три render в `copy_surface.test.tsx:47,55,65` используют default dark. Перебор вкладок не превращает это в проверку всей объявленной поверхности.
ОБХОД: сразу внутри `<View style={styles.header}>` в TabShell добавить `{colorScheme === 'light' ? <Text>Falscher Rückweg</Text> : null}`. Словарь и правильные тексты не менять. На light появляется новая немецкая формулировка вне каталога, но все четыре обычные пробы возвращают 0 (`light-copy-invented`); в combined также все матрицы rc=0. Независимый сбор строковых листьев light-рендера получает строку вне исходных десяти, а на эталоне не получает.

Обход не меняет ожидания проб, отчёты или окружение. Это состояние обычного продуктового дерева внутри implementer-зоны, а не атака общего uid. Исправлять надо замкнутость перечня состояний видимой поверхности, не добавлять исключение для конкретной строки.

## Пять вопросов роли

1. **Критерий слабее предмета:** да — четыре находки выше, семь независимых мутаций, единое дерево с восемью наблюдаемыми нарушениями и зелёными восемью командами приёмки (:64–65).
2. **Доказуемость командами:** команды названы; прежний ложный вывод о независимости copy/static исправлен. Новые расхождения — именно недостающие наблюдения исполняемых критериев. Отложенный Android не выдаётся за выполненный.
3. **Решение, оставленное исполнителю:** закрытые перечни не определяют/не проверяют необходимые оси и композиционные связи, перечисленные в находках. Это не вкусовая претензия: каждый пробел сопровождается исполняемым обходом.
4. **Границы исполнения:** исполнители и ЗОНА-строки названы; все предъявленные мутации внутри implementer-зоны :84. Precision-гейт rc=0. Доказанного дополнительного обхода зон нет.
5. **AGENTS.md:** применена норма красных критериев кодового контракта; блокеры предъявлены исполнением, не чтением остальной прозы. Отдельного блокера без обхода по нормам не выставляю.

АРБИТР: arbiter (`roles/arbiter.md`). Созываю по повторной причине «неполный закрытый перечень позволяет выполнить критерий без выполнения объявленного предмета»; предмет арбитража — достаточность обобщённого закрытия классов 1–4 и граница следующих исправлений, не реализация и не воля владельца. Это второй FAIL по тем же классам; третий обычный круг критика не предлагаю. Доставить отдельное сообщение Main через `agent://Main` не удалось: инструмент отказал по Н-85 (`внутренний URI непиннованной сессии запрещён`). Требование созыва передаётся этим вердиктом и итогом задания; не утверждаю, что процесс арбитра уже запущен.

## Команды и сырой вывод

Все собственные записи и disposable-репро — в `/tmp/dev-harness-verify/critic999r2/`. Основной checkout не открывался, контракт/пробы не правились, commit/push не выполнялись. Complior-mob получен HTTPS и закреплён на B=`f0d8e54e181853473e23c7df3dc623bbb7faecdf`; `R` — отдельный disposable-клон B.

### Закрепление объекта и входные барьеры

```text
$ git clone ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/critic999r2/clone
$ git fetch origin wip/999/architect
$ git checkout --detach 7482b8d8bcfa2d70d34d456c5dde18a9c47a1dbb
$ git fetch origin --tags
$ git rev-parse HEAD
7482b8d8bcfa2d70d34d456c5dde18a9c47a1dbb
[exit=0]

$ bash scripts/pre_critic.sh --repo . contracts/999-cmp-mob-002-navigatsiya.md
КРИТИК: дверь зелёная
[exit=0]

$ bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/critic999r2/clone contracts/999-cmp-mob-002-navigatsiya.md
OK
[exit=0]

$ bash scripts/check_threat_model.sh . contracts/999-cmp-mob-002-navigatsiya.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 8 буллет(ов), НЕ ЗАЩИЩАЕТ 4 буллет(ов))
[exit=0]
```

Прочитаны:

```bash
git show origin/main:verdicts/critic/contracts-999-krug1-fail.md
gh repo clone https://github.com/a3ka/Complior-mob.git /tmp/dev-harness-verify/critic999r2/Complior-mob
git -C /tmp/dev-harness-verify/critic999r2/Complior-mob checkout --detach f0d8e54e181853473e23c7df3dc623bbb7faecdf
gh issue view 6 --repo a3ka/Complior-mob --json body --jq .body
```

Каждая команда rc=0. Установка `npm ci --prefix /tmp/dev-harness-verify/critic999r2/R/mobile --cache /tmp/dev-harness-verify/critic999r2/npm-cache` — rc=0. Это подготовка, не project-wide validation.

`sha256sum` исходных tokens/copy/font/OFL в read-only снимке дал ровно хеши source.json:

```text
70e9e31167c46258697cbe7eaa2f5f096d49f167783e76ce74d08644982a5364  docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/design-system/project/tokens.json
8d9c9ac780e367160ceae1577b9e4bf0a7c1b8db05df9158dc72f3c8506c36f9  docs/ux/01_UX_Source_of_Truth/BrokerOS_UI_Copy_DE.json
a023f465d2f26d8f56c6e3cac6aece08b7a66eb75b4d75eeef9df838c53c81f6  docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/design-system/project/fonts/DMSans-Variable.ttf
9af36190332437f5ecd09974de43c1f7c77a310a996cdd8ceb25628b458840e1  docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/design-system/project/fonts/OFL-DMSans.txt
```

### Baseline и закрытие прежних конкретных обходов

Исполнены `audit.py baseline` и `audit.py old` с `PYTHONDONTWRITEBYTECODE=1`, `TMPDIR=/tmp/dev-harness-verify/critic999r2`. Команды каждой дочерней пробы и полный сырой вывод сохранены в `baseline.log` и `old.log`.

На B:

```text
999 NAV_SHELL_ABSENT
EXIT=1
999 UI_PRIMITIVES_ABSENT
EXIT=1
999 STATIC_THEME_ABSENT
EXIT=1
999 COPY_MODULE_ABSENT
EXIT=1
```

На B с `--model` каждая проба rc=0: nav 32, ui 11, static 6, copy 4 case. На установленном эталоне все четыре `--matrix` rc=0; исполнены 12 nav, 11 ui, 7 static, 4 copy мутанта. Для прежнего блокера независимости существенен сырой вывод:

```text
999 copy/COPY_TEXT: rc=1 COPY_KEY_ABSENT: ia115.nav.START
999 copy/REVIEW_STATUS: rc=1 COPY_KEY_ABSENT: ia115.nav.START
999 copy/DEPRECATED_KEY: rc=0 deprecated-алиасы не используются
999 copy/COPY_SURFACE_CATALOG: rc=0 поверхность (вкладки/профиль/deep link) показывает только тексты каталога
MUTANT status-lost: named=REVIEW_STATUS RED depends_red=['COPY_TEXT'] unexpected_red=none -> OK
```

Все 11 старых мутаций дали rc=1 своей семье. Старый combined: nav=1, ui=1, static=0, copy=1. Static не обязан краснеть на дереве без статической мутации.

Техническая оговорка о судейском раннере: первоначальный Tee после завершения этих дочерних команд пытался flush уже закрытого log, из-за чего внешний процесс завершился rc=120. Это не отказ/успех предметных проб; их реальные rc напечатаны до завершения. Раннер исправлен (`run.py`, восстановление stdout до закрытия файла). При разработке нового контейнерного репро обнаружены неуникальный якорь и вариант с Fragment, не проходивший UI-пробу; они не объявляются обходами. Окончательный вариант имеет общий корневой View и предъявлен последующим успешным прогоном ниже.

### Семь новых независимых обходов и совмещённое дерево

Окончательные исполненные команды:

```bash
env PYTHONDONTWRITEBYTECODE=1 TMPDIR=/tmp/dev-harness-verify/critic999r2 \
  python3 /tmp/dev-harness-verify/critic999r2/run.py new
env PYTHONDONTWRITEBYTECODE=1 TMPDIR=/tmp/dev-harness-verify/critic999r2 \
  python3 /tmp/dev-harness-verify/critic999r2/run.py combined
```

Обе завершились rc=0; совместная bash-команда rc=0. В режиме `new` rc=0 раннера означает: все четыре приёмочные пробы на каждом из семи дефектных деревьев вернули 0. В `combined`: все четыре обычные пробы и все четыре `--matrix` вернули 0, независимые наблюдения зелёные на эталоне и красные на обходе. Полные сырые логи: `new.log`, `combined.log`. Определения мутаций и установка/восстановление — `audit.py`; независимое наблюдение — `observe.test.tsx`.

Сводка результатов независимых прогонов (колонки nav/ui/static/copy):

```text
transition-post-vorgaenge       0 0 0 0
reduced-motion-emits-command    0 0 0 0
secondary-disabled-ignored     0 0 0 0
input-accent-text              0 0 0 0
containers-detached           0 0 0 0
light-copy-invented            0 0 0 0
nonstart-accent-title          0 0 0 0
```

Это сводка по логам, не выдаётся за сырой stdout команды. Ниже — дословный сырой вывод обычных UI/static/copy-проб на **совмещённом дефектном дереве**:

```text
999 ui/ACCENT_NOT_TEXT_ON_LIGHT: rc=0
999 ui/BUTTON_DARK_PRIMARY: rc=0
999 ui/BUTTON_DARK_SECONDARY: rc=0
999 ui/BUTTON_DISABLED_STATE: rc=0
999 ui/BUTTON_LIGHT_PRIMARY: rc=0
999 ui/BUTTON_LIGHT_SECONDARY: rc=0
999 ui/NOTICE_DARK: rc=0
999 ui/NOTICE_LIGHT: rc=0
999 ui/SAFE_KEYBOARD_CONTAINER: rc=0
999 ui/TEXTFIELD_DARK: rc=0
999 ui/TEXTFIELD_LIGHT: rc=0
EXIT=0
999 static/TOKENS_MATCH: rc=0 names=8 dark/light совпали побайтово
999 static/LITERAL_PALETTE: rc=0 зоны 002 (app/ui/navigation/tab-shell/start-screen) без hex-литералов
999 static/FONTS_PRESENT: rc=0 mobile/assets/fonts/DMSans-Variable.ttf sha256 совпал
999 static/FONTS_OFL: rc=0 mobile/assets/fonts/OFL-DMSans.txt sha256 совпал
999 static/NO_WEB_BUNDLE: rc=0 импортов design-snapshot bundle/docs в mobile/src нет
999 static/DEEP_LINK_SCHEME: rc=0 scheme=complior
EXIT=0
999 copy/COPY_TEXT: rc=0 keys=10 тексты совпали побайтово
999 copy/REVIEW_STATUS: rc=0 review_status сохранён у каждого ключа
999 copy/DEPRECATED_KEY: rc=0 deprecated-алиасы не используются
999 copy/COPY_SURFACE_CATALOG: rc=0 поверхность (вкладки/профиль/deep link) показывает только тексты каталога
EXIT=0
```

Дословный конец nav-прогона на том же дереве (полные 32 строки — в `combined.log`):

```text
999 nav/PROFILE_RETURN_POST: rc=0
999 nav/PROFILE_RETURN_SCHUTZ: rc=0
999 nav/PROFILE_RETURN_START: rc=0
999 nav/PROFILE_RETURN_VORGAENGE: rc=0
999 nav/PROFILE_SECONDARY_NOT_TAB: rc=0
999 nav/REDUCED_MOTION_ACTIONS: rc=0
999 nav/SECTION_CONTENT_COPY: rc=0
999 nav/TABS_ORDER: rc=0
999 nav/TAB_LABELS_IA: rc=0
999 nav/TAB_SWITCH_NO_COMMAND: rc=0
999 nav/TAB_SWITCH_SELECTS_SECTION: rc=0
EXIT=0
```

Матрицы исполнены настоящими CLI-командами `python3 <FAMILY> --repo /tmp/dev-harness-verify/critic999r2/R --matrix`, не вызовом одного удобного case. Все четыре `EXIT=0` записаны в `combined.log`. В nav/ui матричные мутанты устанавливают модель, honest-часть исполняет текущее дерево; ни одной матрице этот combined не мешает стать зелёной.

### Независимое наблюдение невыполненного предмета

Дословный вывод из `combined.log`:

```text
OBSERVE honest JEST_EXIT=0
{"all light section titles avoid accent text": "passed", "disabled secondary cannot activate": "passed", "keyboard avoidance actually encloses section": "passed", "light input text is not accent": "passed", "light shell only displays catalogue strings": "passed", "post can switch to vorgaenge": "passed", "reduced motion switches do not emit commands": "passed", "safe area actually encloses section": "passed"}
OBSERVE combined-bypass JEST_EXIT=1
{"all light section titles avoid accent text": "failed", "disabled secondary cannot activate": "failed", "keyboard avoidance actually encloses section": "failed", "light input text is not accent": "failed", "light shell only displays catalogue strings": "failed", "post can switch to vorgaenge": "failed", "reduced motion switches do not emit commands": "failed", "safe area actually encloses section": "failed"}
```

Это живые Jest/RNTL render/press и наблюдение дерева компонентов, не regex вместо выполнения поведения. Проверка контейнеров — принадлежность содержимого настоящему компоненту-предку, не наличие произвольной automation-метки.

После завершения:

```text
$ git status --short --untracked-files=all
(no output)
[exit=0]
```

Команда исполнена в disposable R: workspace и все мутации восстановлены.

## Граница результата

Не заявляю Android/Maestro, визуальный device-render, CI Complior-mob, frozen-995 на C или готовность Expo Router entry: C ещё нет, это отложенная приёмка. FAIL касается уже предъявленного исполняемого критерия :64–65 и его заявленного покрытия, не выдуманного результата будущего PR. Гейт не требует бесконечного числа тестов: предъявлены конкретные состояния дерева, удовлетворяющие этим командам при невыполненных уже названных свойствах. Заморозка данной редакции не разрешается.
