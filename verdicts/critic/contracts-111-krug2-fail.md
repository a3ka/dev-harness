FAIL
OBJECT=4d7e74edf46408f074e43cab98072d0807e184a6

# Critic111r2 — дельта B1–B5 до заморозки

**Все пять точных обходов круга 1 теперь красные. Однако классы B2, B3 и B5 не закрыты:** те же дефекты, ограниченные светлой схемой, проходят обе предметные пробы (rc0, 8/8 + 14/14). Независимые live-witness прогоны наблюдали выключенные боковые края, чужой Image.source и видимый некаталожный саблайн. Основание FAIL — только эти три воспроизведённых обхода прежних классов, не новые требования.

АРБИТР: arbiter — повторный FAIL по классам B2/B3/B5. Предмет: достаточно ли dark-only клеток К3/К4/К5 для объявленных без исключения инвариантов safe-area, связи wordmark с ассетом и закрытого состава копии экрана, работающего в dark/light; где заканчивается закрытие класса обхода и начинается новый предмет. Требуется маршрутизация арбитру, не третий круг критика. Автор конструкции — сторона, не судья. Доступного инструмента запуска арбитра в этой сессии нет; попытка адресовать Main через agent:// отклонена гардом непиннованной сессии Н-85. Передача этого вердикта ведущей роли — через итог задания.

## Предмет, происхождение и граница

- Судился закоммиченный OBJECT, не текст переписки. `git cat-file -t` → `commit`; контракт и семейство 111 извлечены `git archive OBJECT`. Побайтовое соответствие материала блобам OBJECT подтверждено в `evidence/integrity.json`.
- Предмет/инварианты: `contracts/111-cmp-mob-first-run.md:74–121`; rc-приёмка: :176–199; исполнители и зоны: :207–229. Комплект полный. Дельта не меняет implementer-зону; мутации ниже затрагивают только объявленные продуктовые пути.
- R — собственная `cp -a`-копия `/tmp/dev-harness-verify/Architect111/R`, база B=76ac10fa с node_modules. H — собственная копия прежнего изолированного H с наложенным архивом OBJECT; precision/precritic проверяли материализованный контракт. Это не новый коммит H: его git HEAD унаследован от копии.
- Чужие checkout/worktree не изменялись. Коммитов/push нет по явному ограничению задания. Все записи — внутри `/tmp/dev-harness-verify/Critic111r2/`.
- Н-351: добавленные ожидания — литералы, не значения, вычисленные продуктом. Три канонических SHA256 source.json совпали с R. Полный пересуд исходного канона и новые классы не проводились.

## Таблица B1–B5 и регресс

Здесь **P/S** — rc обычных `first_run_probe.py` / `first_run_static_probe.py --repo R`, без `--model` на установленном мутанте. Старые мутации загружены непосредственно из пяти `Critic111/evidence/*-mutations.json`, не заменены похожими авторскими стабами.

| Класс | Точный обход круга 1 на новом OBJECT | Дополнительная проверка того же класса | Итог |
|---|---|---|---|
| B1 — CTA | `old-light-cta-noop`: **1/0**, RED `CTA_OPENS_F03_01_LIGHT` | `new-light-wrong-frame`: CTA действительно переводит в recovery вместо email только в light; **1/0**, та же именованная краснота | Закрыт на проверенных вариантах; нового обхода не найдено |
| B2 — safe-area | `old-safearea-disabled`: **1/0**, RED `SAFEAREA_EDGES_ACTIVE` | Постоянные edges top/bottom: **1/0**. Те же усечённые edges только в light: **0/0**, witness `{top:additive,right:off,bottom:additive,left:off}` | **БЛОКИРУЕТ B2r2** |
| B3 — wordmark source | `old-wordmark-wrong-source`: **1/0**, RED `WORDMARK_SOURCE_BOUND` | splash-icon.png только в light: **0/0**, witness source=`../../../assets/images/splash-icon.png` | **БЛОКИРУЕТ B3r2** |
| B4 — effective splash | `old-android-splash-blue`: **0/1**, RED `SPLASH_EFFECTIVE_GROUND_BOTH` | ios.backgroundColor blue: **0/1**. Отсутствующий Android-resolver: **rc2 INFRASTRUCTURE**; реально бросающий исключение resolver: **rc2 INFRASTRUCTURE** | Старый обход закрыт; отказ/пропуск resolver не даёт зелень. Дополнительное dark-наблюдение — совет S1 ниже |
| B5 — замкнутая копия | `old-extra-unreviewed-copy`: **1/0**, RED `FIRST_RUN_COPY_CLOSED` | Тот же саблайн только в light: **0/0**, witness видит `Versicherung. Erledigt.` | **БЛОКИРУЕТ B5r2** |
| Регресс модели | `--model`: P **rc0 honest 8/8**, S **rc0 static 14/14** | Все прежние положительные клетки сохранены | Зелёный |
| Регресс матриц | P `--matrix` **rc0**, 11 стабов; S `--matrix` **rc0**, 9 стабов | Старые 7+8 стабов остаются красными; нет MUTANT_GREEN / NAMED_MISS / UNEXPECTED_RED | Зелёный |
| Scoped 995 | DIRECT_unknown + DEFAULT_OFFLINE: **rc0, оба passed** на каждом из трёх новых обходов B2/B3/B5 | Также rc0 на wrong-frame и dark-splash вариантах | Обходы не отсекаются этими entry-клетками |
| Двери | `bash scripts/check_precision_gate.sh H contracts/111-cmp-mob-first-run.md` **rc0 OK**; `pre_critic.sh --repo H ...` **rc0** | Исправленный контрактный вызов precritic исполним | Зелёный; не отменяет предметных обходов |
| Неизменность | `git diff` между OBJECT круга 1 и OBJECT круга 2 по pilot_995/nav_999: **rc0, пустой вывод** | R pilot.test.tsx/source.json совпадают с фактическим CI-пином B `c9f680b4…`; временные продуктовые изменения восстановлены | Регресс дельты не найден |

## Блокирующие находки

### B2r2 — защита краёв снова проверяется не на всём объявленном экране

БЛОКИРУЕТ contracts/111-cmp-mob-first-run.md:145 — К3 требует действующих четырёх краёв (:90–93), но её исполняемая проверка рендерит только dark (`first_run.test.tsx:160–163`); структурная light-клетка наблюдает только цвет. Инвариант :120 не исключает safe-area из светлой схемы.
ОБХОД: в модели получить `scheme` через существующий useTheme и добавить настоящему SafeAreaView `edges={scheme === 'light' ? ['top', 'bottom'] : undefined}`. Все 22 клетки двух предметных проб зелёные, scoped entry-995 зелёный, но в светлой теме библиотека передаёт native left/right=`off`: требуемой защиты всех четырёх краёв нет.

Замер: `evidence/new-light-edges-top-bottom-{probe,static_probe,995-entry,witness}.txt`; точная мутация — одноимённый `-mutations.json`. Witness независимо проверил литеральную native-карту с выключенными боковыми краями, rc0. Это тот же класс B2, а не новый пиксельный критерий.

### B3r2 — обязательный ассет используется только в dark

БЛОКИРУЕТ contracts/111-cmp-mob-first-run.md:148 — К4 утверждает связь Image.source экрана с wordmark-dark.png (:114–117), но проверяет её только после `renderFirstRun('dark')` (`first_run.test.tsx:170–175`). В light label/role/testID засчитываются без проверки source.
ОБХОД: оставить требуемый файл и все accessibility-атрибуты, а source задать `scheme === 'light' ? require('../../../assets/images/splash-icon.png') : require('../../../assets/images/wordmark-dark.png')`. Обе предметные пробы rc0, scoped entry-995 rc0; на живом light-рендере source у wordmark указывает на splash-icon.png, не на обязательный wordmark.

Замер: `evidence/new-light-wrong-source-{probe,static_probe,995-entry,witness}.txt`, мутация в `-mutations.json`. Witness проверил source на splash-icon.png и отсутствие wordmark-dark.png. Это нарушение проводки ассета B3, не спор о растеризации/пикселях.

### B5r2 — некаталожный саблайн проходит в light

БЛОКИРУЕТ contracts/111-cmp-mob-first-run.md:151 — К5 объявляет закрытый состав всего видимого текста (:101–104), но собирает host-дерево только dark (`first_run.test.tsx:183–190`). Клетка структуры light не исключает добавочный текст.
ОБХОД: перед Button вставить `{scheme === 'light' ? <Text>Versicherung. Erledigt.</Text> : null}`. Обе предметные пробы rc0, scoped entry-995 rc0, каталог и два обязательных текста сохранены; live light-рендер отображает явно запрещённый некаталожный саблайн.

Замер: `evidence/new-light-extra-copy-{probe,static_probe,995-entry,witness}.txt`, мутация в `-mutations.json`. Witness нашёл точный текст на поверхности через RNTL `toBeOnTheScreen`, rc0. Это буквально класс и строка B5, только в другой уже объявленной теме.

Закрывать эти находки следует наблюдением инвариантов в обеих заявленных схемах, а не распознаванием конкретного написания трёх мутаций. Контракт и пробы здесь не исправлялись.

## Советы — не основания FAIL

СОВЕТ contracts/111-cmp-mob-first-run.md:156 — дополнительный вариант `android: { dark: { backgroundColor: '#208aef' } }` проходит P/S rc0, 8/8 + 14/14 (`evidence/new-android-dark-blue-*.txt`). Проба извлекает только `.backgroundColor`, не `.dark.backgroundColor`. В R `userInterfaceStyle: light`; устройство и реально выбранный night-resource не наблюдались. Поэтому применимость к объявленному холодному старту **не доказана**, в блокер это не превращаю. [INFERENCE] Нативный night-вариант заслуживает отдельного уточнения, если его включают в границу effective-конфигурации.

СОВЕТ contracts/111-cmp-mob-first-run.md:190 — учитывать разницу между frozen-фикстурой фактического H-пина B и одноимённым файлом на текущем OBJECT харнесса. Начальное сравнение с материализованным H дало `pilot.test.tsx=false`: там уже добавлены API-порты 107/108, отсутствующие в B. Проверка против **фактического CI-пина** c9f680b4… дала true для обоих файлов. Дельта круга 2 этих файлов не меняет; это не регресс и не блокер данного круга. Не выдавать сравнение с произвольным HEAD харнесса за сравнение с frozen-пином поставки.

## Сырые данные, команды и предел доказательства

Сырые stdout/stderr и rc отделены от диагноза: `evidence/*.txt`, свод `evidence/results.json`. Все прогоны обычных проб записывают точный argv и cwd. Основные группы:

- `model-{probe,static_probe}.txt`, `matrix-{probe,static_probe}.txt`;
- пять `old-*-{probe,static_probe}.txt` и точные `old-*-mutations.json`;
- `new-*-{probe,static_probe}.txt`, `resolver-{absent,throws}.txt`;
- три `new-light-*-witness.txt` и `new-light-*-995-entry.txt`;
- `precision.txt`, `precritic.txt`, `frozen-diff.txt`, `integrity.json`, `frozen-pin-provenance.json`, `subject-versus-B-pilot-diff.txt`.

Воспроизведение: `python3 review.py` — модель, обе матрицы, старые/новые мутации, resolver failures и scoped 995; `python3 witness.py` — независимое наблюдение трёх светлых обходов. Runner устанавливает изменения только временно в собственной R и восстанавливает байты. Witness-тест хранится как evidence, не добавлен в продукт/контракт; его skipped-клетки не выданы за предметный прогон — обычные пробы выполнялись отдельно.

Базовую красноту B rc1 FIRST_RUN_SEAM_ABSENT, уже предъявленную автором, повторно не подтверждал. Полные lint/typecheck/npm test, CI, APK, Maestro и физический экран — **NOT_RUN**, согласно scoped-границе. Результат касается достаточности предъявленного кодового критерия до реализации, не утверждает зелёный полный CI или готовность C. Все три блокера имеют выполненные предметные rc-команды и отдельное наблюдение нарушенного инварианта.

После прогонов восстановлены все пять путей модели и Android-resolver; временные installed-тест и splash-script отсутствуют (`integrity.json`). Материализованный контракт и пробы остались байт-в-байт из OBJECT. Вердикт оставлен по требуемому пути; перенос и коммит под именем critic — обязанность уполномоченного процесса, не этой непиннованной сессии.
