FAIL
OBJECT=b330af2c5b36f00c5f3061116787330082e77209

# Критик — контракт 999, круг 1

Предмет: `contracts/999-cmp-mob-002-navigatsiya.md` и красные пробы `fixtures/workshop_project/nav_999/` на указанном HEAD. Судится критерий ДО реализации, не реализация Complior-mob.

Набор артефактов полный: предмет, команды готовности, названные исполнители и ЗОНА-строки есть. Отсутствие строки 999 в `registry/plan.tsv` не блокирует этот суд — согласно поручению. Контракт и пробы не исправлялись. Коммитов, push, изменений основного checkout не делал.

Результат: приёмочные команды пропускают воспроизведённые дефекты навигации, примитивов, контейнеров и использования copy. Отдельно матрица copy заявляет независимость, которой не измеряет. Это не пожелания расширить предмет: обходы нарушают уже объявленные инварианты.

## Блокирующие находки

### 1. Перечислены вкладки, но не проверены состояния и переходы всех вкладок

БЛОКИРУЕТ contracts/999-cmp-mob-002-navigatsiya.md:56 — набор nav-case не доказывает навигационный предмет строк 34, 40 и 44. `nav.test.tsx:44` проверяет selected при переключении только для Vorgänge/Schutz; `:65` проверяет единственную пару initial=Schutz, return=Post. Профиль открывается/закрывается с проверкой числа вкладок, но без проверки сохранения исходного раздела.
ОБХОД: в эталонном дереве заменить `selected: section === id` на `selected: id !== 'start' && section === id`; инициализацию section — на `initialSection === 'post' ? 'start' : initialSection`; `leaveProfile` — на `() => { setSection('start'); setRoute('tabs'); }`. Start больше никогда не объявляется выбранным, вход в Post открывает Start, возврат из профиля теряет Post. Все четыре обычные пробы и все четыре `--matrix` возвращают 0 на таком дереве в составе combined-репро. Независимое наблюдение действительно получает три отказа на этих свойствах при зелёном эталоне.

Отдельная независимая мутация `useState<ShellSection | null>(initialSection === 'schutz' ? returnSection : null)` тоже проходит все четыре обычные пробы: возврат может работать только для одной стартовой вкладки. Список четырёх вкладок в source.json не делает таблицу переходов исчерпывающей. Нужна конечная таблица выбранного раздела, входа и возврата для всех объявленных вкладок, а не дополнительные названия case без наблюдения состояния.

### 2. Dark/light примитивов — не декартово покрытие; accent проверяется не на примитивах

БЛОКИРУЕТ contracts/999-cmp-mob-002-navigatsiya.md:42 — инварианты примитивов и accent (также строка 41) сильнее UI-критерия строки 56. `ui.test.tsx:28,38` испытывает только dark-primary и light-secondary; Notice и TextField испытываются только в light. `ACCENT_NOT_TEXT_ON_LIGHT` смотрит заголовок Start, вкладки и вход в профиль, но не Button/Notice/TextField и не содержимое остальных разделов.
ОБХОД: в Button заменить `const labelColor = variant === 'primary' ? tokens['on-primary'] : tokens.ink;` на `const labelColor = tokens.accent;`. Light-secondary получает лаймовую подпись на светлой panel, а dark-primary — лаймовую подпись на лаймовой заливке. Все четыре обычные пробы и четыре `--matrix` проходят в combined-репро; независимый рендер light-secondary подтверждает запрещённый цвет и падает, тогда как эталон проходит.

Независимо испытаны ещё три обхода, каждый проходит все четыре обычные пробы:

- Button: `onPress={((tokens.primary === tokens.accent) === (variant === 'primary')) ? onPress : undefined}` — не работают dark-secondary и light-primary.
- Notice: `accessibilityRole={tokens.primary === tokens.accent ? undefined : 'alert'}` — alert отсутствует в dark.
- TextField: `secureTextEntry={tokens.primary === tokens.accent ? false : secureTextEntry}` — secure-ввод в dark не скрыт.

Все варианты используют имеющиеся токены, поэтому hex-scan не является ловцом. Требуется наблюдать заявленные свойства каждого примитива в обеих темах и оба варианта Button; проверка наличия словаря токенов этого не заменяет.

### 3. Контейнеры можно заменить обычным View, сохранив testID

БЛОКИРУЕТ contracts/999-cmp-mob-002-navigatsiya.md:42 — `SAFE_KEYBOARD_CONTAINER` из критерия строки 56 проверяет только два testID (`ui.test.tsx:82–85`), не safe-area/keyboard поведение или даже наличие соответствующего контейнера.
ОБХОД: заменить импорт `SafeAreaView` из `react-native-safe-area-context` на `const SafeAreaView = View;`, оставив JSX и testID. Все четыре обычные пробы и четыре `--matrix` проходят в combined-репро, хотя safe-area механизма уже нет. Независимая замена KeyboardAvoidingView обычным View с сохранением testID также проходит все четыре обычные пробы. Это ровно имитация объявленного контейнера automation-меткой.

Отложенная проверка физического рендера на устройстве не является доказательством уже заявленного RNTL-покрытия композиции (строка 105). Нужна красная проба против контейнера-пустышки, а не против удаления его testID.

### 4. Полнота словаря copy не доказывает использование его ключей

БЛОКИРУЕТ contracts/999-cmp-mob-002-navigatsiya.md:43 — критерий проверяет 10 записей `ui-copy.ts`, но не все соответствующие видимые тексты. `global.back` присутствует в перечне, однако отображение Back не сверяется с каталогом.
ОБХОД: оставить весь `ui-copy.ts` без изменений, а в TabShell заменить видимый текст Back `{uiCopyDe['global.back'].text}` на `{'Falscher Rückweg'}` (accessibilityLabel оставить исходным). Новая немецкая формулировка попадает на поверхность, несмотря на запрет инварианта. Все четыре обычные пробы и все четыре `--matrix` проходят в combined-репро. Независимое наблюдение `within(shell-back).getByText('Zurück')` проходит на эталоне и падает на обходе.

Именно перечень потребителей ключей неполон; значения всех 10 записей самого словаря проверяются — отдельная проверка ниже это подтверждает. Исправление — наблюдение использования ключей, а не добавление одиннадцатого статического ключа.

### 5. Матрица copy/static не проверяет посторонние ячейки

БЛОКИРУЕТ contracts/999-cmp-mob-002-navigatsiya.md:57 — обещание «посторонние зелёны» недоказуемо реализацией матрицы: `copy_probe.py:123` и `shell_static_probe.py:175` запускают `run_cases(repo, [case])`, после чего множество `others` всегда пусто. Для copy дефект не гипотетический.
ОБХОД: оставить предъявленную матрицу и её мутант `status-lost` неизменными. Команда `copy_probe.py --repo R --matrix` возвращает 0 и печатает `MUTANT status-lost: named=REVIEW_STATUS RED -> OK`, хотя прогон ВСЕХ трёх case на том же мутанте даёт одновременно COPY_TEXT=1 и REVIEW_STATUS=1 при DEPRECATED_KEY=0. Незаявленная зависимость пропущена, критерий независимости объявлен выполненным. Состояние обхода уже находится на OBJECT; дополнительная мутация проверяющего не нужна.

Нужно исполнять все колонки матрицы и сравнивать результат с явно объявленными зависимостями. Побочная краснота сама по себе допустима, если объявлена; отсутствие её измерения — нет. Аналогичный цикл static имеет ту же пустую проверку `others`, но фактический контрпример предъявлен для copy, не приписывается static без измерения.

## Проверки пяти вопросов роли

1. **Критерий слабее предмета:** да, обходы 1–4 предъявлены исполнением.
2. **Доказуемость командами:** основные команды названы; ложное доказательство независимости — находка 5. Android и device-часть честно отмечены NOT_RUN до C; не выдаю их за выполненные.
3. **Решения, оставленные исполнителю:** наблюдаемые варианты/переходы перечислены недостаточно для заявленного покрытия — это отражено в обходах, а не отдельная вкусовая претензия.
4. **Границы и исполнители:** названы, precision-гейт исполнен и зелёный. Доказанного обхода зон в этом круге нет.
5. **AGENTS.md:** проверка ведётся по норме кодового контракта — красным исполнением, а не одной прозой. Отдельного блокера без обхода по нормам не выставляю.

## Команды и сырой вывод

Рабочий корень проверки: `/tmp/dev-harness-verify/critic999/`. Репро и полные логи остаются здесь, не в основном checkout. `R` — одноразовый локальный клон read-only снимка; установка зависимостей: `npm ci --prefix /tmp/dev-harness-verify/critic999/R/mobile --cache /tmp/dev-harness-verify/critic999/npm-cache`, rc=0.

### Идентичность объекта и первый гейт

```text
$ git fetch origin wip/999/architect
$ git checkout --detach b330af2c5b36f00c5f3061116787330082e77209
$ git rev-parse HEAD
b330af2c5b36f00c5f3061116787330082e77209

$ bash scripts/pre_critic.sh --repo . contracts/999-cmp-mob-002-navigatsiya.md
КРИТИК: дверь зелёная
[exit=0]

$ bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/critic999/clone contracts/999-cmp-mob-002-navigatsiya.md
OK
[exit=0]
```

`pre_critic` выполнен первым гейтом после checkout. Complior-mob получен `gh repo clone a3ka/Complior-mob ... -- --config credential.helper='!gh auth git-credential'`; origin — `https://github.com/a3ka/Complior-mob.git`, detached HEAD — `f0d8e54e181853473e23c7df3dc623bbb7faecdf`. Полное тело issue прочитано командой `gh issue view 6 --repo a3ka/Complior-mob --json body --jq .body`, rc=0.

### B, эталон, штатные мутанты

```bash
env TMPDIR=/tmp/dev-harness-verify/critic999 PYTHONDONTWRITEBYTECODE=1 \
  python3 /tmp/dev-harness-verify/critic999/probe_review.py baseline
```

`baseline.log` содержит команды и полный сырой вывод. На B:

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

На B с `--model`, затем на установленном эталоне без `--model`: каждая из четырёх проб rc=0. Исполнены 8 nav, 7 ui, 6 static, 3 copy case. Все четыре штатные матрицы rc=0; фактически перечислены 8 nav, 5 ui, 7 static, 3 copy мутанта. Это baseline работоспособности тестов, не оправдание их полноты.

### Собственные независимые мутанты и совмещённый обход

```bash
env TMPDIR=/tmp/dev-harness-verify/critic999 PYTHONDONTWRITEBYTECODE=1 \
  python3 /tmp/dev-harness-verify/critic999/probe_review.py independent
env TMPDIR=/tmp/dev-harness-verify/critic999 PYTHONDONTWRITEBYTECODE=1 \
  python3 /tmp/dev-harness-verify/critic999/probe_review.py combined
```

Первый прогон исполняет четыре обычные пробы на каждом из 11 независимых мутантов, каждый раз получает четыре rc=0. Полный вывод: `independent.log`. Второй устанавливает одновременно шесть мутаций, перечисленных в находках 1–4, и исполняет четыре обычные пробы плюс четыре `--matrix`: все восемь rc=0. Полный вывод: `combined.log`. Файлы/якоря замен и установки эталона находятся в `probe_review.py`; модель устанавливается только в disposable R и восстанавливается context manager.

Сырой вывод обычных проб на combined-дереве:

```text
999 nav/DEEPLINK_RETURN: rc=0
999 nav/PROFILE_SECONDARY_NOT_TAB: rc=0
999 nav/REDUCED_MOTION_ACTIONS: rc=0
999 nav/SECTION_CONTENT_COPY: rc=0
999 nav/TABS_ORDER: rc=0
999 nav/TAB_LABELS_IA: rc=0
999 nav/TAB_SWITCH_NO_COMMAND: rc=0
999 nav/TAB_SWITCH_SELECTS_SECTION: rc=0
EXIT=0
999 ui/ACCENT_NOT_TEXT_ON_LIGHT: rc=0
999 ui/BUTTON_DISABLED_STATE: rc=0
999 ui/BUTTON_ROLE_LIGHT_SECONDARY: rc=0
999 ui/BUTTON_ROLE_VARIANTS: rc=0
999 ui/NOTICE_ROLE: rc=0
999 ui/SAFE_KEYBOARD_CONTAINER: rc=0
999 ui/TEXTFIELD_LABEL_SECURE: rc=0
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
EXIT=0
```

### Независимое наблюдение дефектов и сверка источников

```bash
env TMPDIR=/tmp/dev-harness-verify/critic999 PYTHONDONTWRITEBYTECODE=1 \
  python3 /tmp/dev-harness-verify/critic999/observe.py
```

Сырой вывод (`observe.log`):

```text
PROVENANCE tokens sha256=70e9e31167c46258697cbe7eaa2f5f096d49f167783e76ce74d08644982a5364 MATCH
PROVENANCE copy sha256=8d9c9ac780e367160ceae1577b9e4bf0a7c1b8db05df9158dc72f3c8506c36f9 MATCH
PROVENANCE 8 token names x 2 modes; 10 copy keys x text/review_status MATCH
OBSERVE honest JEST_EXIT=0
{"Back uses catalogue text": "passed", "post initial section is honored": "passed", "profile Back preserves post": "passed", "secondary light label is not lime": "passed", "start is selected initially": "passed"}
OBSERVE bypass JEST_EXIT=1
{"Back uses catalogue text": "failed", "post initial section is honored": "failed", "profile Back preserves post": "failed", "secondary light label is not lime": "failed", "start is selected initially": "failed"}
OBSERVATION_COMPLETED
```

Это настоящий scoped Jest/RNTL-рендер тех же компонентов в R, не анализ исходника вместо исполнения. Нативный Android-рендер не запускался и не заявляется.

### Полнота значений и независимость copy

```bash
env TMPDIR=/tmp/dev-harness-verify/critic999 PYTHONDONTWRITEBYTECODE=1 \
  python3 /tmp/dev-harness-verify/critic999/probe_review.py inventory
```

Независимо изменены все 16 значений восьми токенов dark/light, а также text и review_status каждого из 10 ключей. Каждая из 36 мутаций отвергнута соответствующей проверкой с rc=1; полнота именно этих списков подтверждена. Полный сырой вывод: `inventory.log`.

Сырой вывод пробы независимости на штатном `status-lost`:

```text
INDEPENDENCE status-lost, all copy cases:
999 copy/COPY_TEXT: rc=1 COPY_KEY_ABSENT: ia115.nav.START
999 copy/REVIEW_STATUS: rc=1 COPY_KEY_ABSENT: ia115.nav.START
999 copy/DEPRECATED_KEY: rc=0 deprecated-алиасы не используются
EXIT=1 RESULTS={'COPY_TEXT': 1, 'REVIEW_STATUS': 1, 'DEPRECATED_KEY': 0}
```

Контраст — сырой вывод официального `--matrix` на этом же штатном мутанте:

```text
999 copy/REVIEW_STATUS: rc=1 COPY_KEY_ABSENT: ia115.nav.START
MUTANT status-lost: named=REVIEW_STATUS RED -> OK
```

После всех прогонов `git status --short --untracked-files=all` в R: пустой вывод, rc=0. Пробы и репро восстановили дерево.

## Граница вердикта

FAIL относится к предъявленным красным критериям до заморозки. Не утверждаю зелёные quality/android-e2e, frozen-995 на C или готовность Expo Router композиции: C ещё нет, эти проверки не исполнялись. Не требую расширения предмета на API, Mission-машину или содержимое функциональных кадров. Исправлению подлежат наблюдаемые границы уже объявленного предмета; добавление формулировки в прозу без красной пробы обходы не закрывает.
