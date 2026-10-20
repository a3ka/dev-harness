FAIL
OBJECT=18ac45501030810f46239bfbf9ab7438730ee9da

# Critic111 — один круг до заморозки

Предмет суда: **закоммиченный контракт и его исполняемый критерий**, не будущая реализация. HEAD изолированного H — указанный OBJECT, автор `architect`. Продукт R скопирован из Architect111/R; HEAD R — B `76ac10fac668a1036371c4b392061ce9b3277ebc`. Контракт и батарея материализованы из OBJECT. Основной checkout и чужие worktree не изменялись; коммитов/push не делал, согласно заданию непиннованной сессии.

**Основание FAIL: пять воспроизведённых обходов предметных rc-команд.** На каждом из пяти состояний дерева обычные пробы, БЕЗ `--model`, дают behavior rc0 (4/4), static rc0 (13/13). Два затронутых frozen-entry сценария 995 (`DIRECT_unknown`, `DEFAULT_OFFLINE`) также rc0 на каждом. Это не утверждение о зелёном полном CI: APK, Maestro и project-wide проверки не запускались. Проверяется достаточность предъявленного до реализации критерия, а не готовность C.

## Проверка задания и пяти вопросов роли

| Пункт | Замер / суждение | Результат |
|---|---|---|
| Полнота набора, предмет, Один результат, команды, исполнители | Предмет и результат: contracts/111-cmp-mob-first-run.md:74–110; приёмка: 149–171; ЗОНА: 183–190; ПРОВОДКА: 241–250. Предмет закоммичен. Набор достаточен для содержательного суда. | Комплект полный. |
| Критерий слабее предмета / «то ли сделано» | Обе авторские модели rc0; обе матрицы rc0, 7 и 8 мутантов. Дополнительные пять состояний ниже проходят все 17 клеток, но нарушают объявленные инварианты. | БЛОКИРУЕТ B1–B5. |
| Доказуемость названными командами | `check_precision_gate.sh H contracts/111-cmp-mob-first-run.md` → rc0, `OK`. `pre_critic.sh --repo H contracts/111-cmp-mob-first-run.md` → rc0. Дословная команда без аргумента из строки 171 → rc1, usage. | Исправить команду — СОВЕТ S1; самостоятельного обхода здесь нет. |
| Н-351 / канон | Прочитаны issue #109 (тело и comments), First-Run.html/png, каталог, токены, STRUCTURE.md. SHA256 трёх источников совпали с source.json. Тексты promise/CTA, review_status и четыре значения ground/ink соответствуют канону. Поведенческие ожидания — независимые литералы; сравнение header с ранее наблюдённым label дополнительно закреплено литералом, поэтому не тавтология. | Обхода через зависимый оракул не найдено. |
| Границы / 108 | Исполнитель implementer и шесть путей названы. Проверены frozen-образец 108 и живой precision-гейт. Пробы и модель исполнились на B без Start/AgentPresence из 108. Зависимости от PR#112 для заявленного среза не обнаружено. | Границы названы; машинный смысл строки ПЕРЕСЕЧЕНИЕ — СОВЕТ S2. |
| NOT_RUN и вопросы владельцу | Maestro/снимок C явно NOT_RUN (254–257); реальные IdP, copy signoff и device evidence не выдаются за локальный Jest. Issue перечисляет wordmark/promise/CTA, splash, Demo, safe-area, но не требует AgentPresence или замены splash-art. | Вопросы 261–264 не блокируют: текущая граница явно выбрана, решения не оставлены молча исполнителю. Не расширять срез до 108 без решения владельца. |
| Норма AGENTS / Н-39 | Проза модели угроз и фактического замера снова связывает именованные стабы с клетками, хотя pre_critic rc0. По заданной границе суда это замечание к сопроводительной прозе, а не дополнительный обход приёмки. | СОВЕТ S3; не использован для расширения основания FAIL. |

## Блокирующие находки

Все пути доказательств ниже отсчитываются от `/tmp/dev-harness-verify/Critic111/`. Патчи состояний дерева сохранены в `evidence/*-mutations.json`. Они применялись только к disposable R через восстановление исходных байтов; тест H не подменялся. Отдельные witness-прогоны добавляли временное наблюдение **после** обычных предметных прогонов и не служили их оракулом.

| ID | Место контракта | Измерение | Нарушенный результат |
|---|---|---|---|
| B1 | contracts/111-cmp-mob-first-run.md:128–132, :109 | `light-cta-noop`: 4/4 + 13/13; witness после нажатия в light: `auth-email absent; First-Run remains`. | CTA не открывает F03.01 в одной из двух заявленных схем. |
| B2 | contracts/111-cmp-mob-first-run.md:89–90, :127, :136 | `safearea-disabled`: 4/4 + 13/13; настоящий компонент передал native edges `{top:off,right:off,bottom:off,left:off}`. | Наличие импорта и цвета не доказывает действующую safe-area. |
| B3 | contracts/111-cmp-mob-first-run.md:104–106, :125–126, :138 | `wordmark-wrong-source`: 4/4 + 13/13 после замены Image.source на существующий splash-icon.png. | Требуемый wordmark-ассет лежит рядом, но экран его не использует. |
| B4 | contracts/111-cmp-mob-first-run.md:74–75, :101–103, :134–135 | `android-splash-blue`: 4/4 + 13/13; настоящий resolver expo-splash-screen вернул effective Android backgroundColor `#208aef`. | Нативный splash остался синим при зелёном SPLASH_GROUND_DARK. |
| B5 | contracts/111-cmp-mob-first-run.md:97–100, :135 | `extra-unreviewed-copy`: 4/4 + 13/13 с дополнительным видимым `<Text>Versicherung. Erledigt.</Text>`. | Проходит новая немецкая строка без каталога/review_status, прямо исключённая из этого среза. |

### B1

БЛОКИРУЕТ contracts/111-cmp-mob-first-run.md:128 — действие CTA проверяется только в dark, хотя работа экрана заявлена в dark/light (:109) и переход не имеет исключения для light (:77–78).
ОБХОД: модель с `const { tokens, scheme } = useTheme()` и `onPress={scheme === 'dark' ? onEnter : () => {}}`. В light все элементы/цвета правильны, но нажатие ничего не делает. Обычные обе пробы зелёные; live witness нажал CTA и наблюдал оставшийся First-Run без auth-email.

Доказательства: `evidence/light-cta-noop-probe.txt`, `light-cta-noop-static_probe.txt`, `light-cta-noop-witness.txt`, `light-cta-noop-995-entry.txt`. Закрывать критерий следует наблюдением объявленного перехода в обеих схемах, не особым условием против этого написания мутанта.

### B2

БЛОКИРУЕТ contracts/111-cmp-mob-first-run.md:127 — клетка называет safe-area, но наблюдает только backgroundColor; статическая клетка требует импорт, не действующую защиту краёв.
ОБХОД: добавить `edges={[]}` настоящему `<SafeAreaView>`. Импорт настоящий, дерево и цвета сохранены, все 17 клеток зелёные. Реальный react-native-safe-area-context преобразовал это в четыре native-края `off`; защищённой области больше нет.

Доказательства: `evidence/safearea-disabled-probe.txt`, `safearea-disabled-static_probe.txt`, `safearea-disabled-witness.txt`, `safearea-disabled-995-entry.txt`. Это не требование пиксельной сверки эмулятора: дефект наблюдён на фактическом native-prop шве библиотеки.

### B3

БЛОКИРУЕТ contracts/111-cmp-mob-first-run.md:125 — label/role/testID у Image и отдельный файл на диске засчитываются как wordmark без связи между ними.
ОБХОД: оставить `wordmark-dark.png` на требуемом пути, accessibilityLabel/role/testID оставить дословно, но Image.source направить на `../../../assets/images/splash-icon.png`. Обе пробы дают rc0, хотя экран больше не использует требуемый wordmark-ассет.

Доказательства: `evidence/wordmark-wrong-source-mutations.json`, `wordmark-wrong-source-probe.txt`, `wordmark-wrong-source-static_probe.txt`, `wordmark-wrong-source-995-entry.txt`. Это нарушение проводки требуемого ассета, не спор о шрифте, пропорциях или точности растеризации, оставленных reviewer.

### B4

БЛОКИРУЕТ contracts/111-cmp-mob-first-run.md:134 — проверяется корневое свойство plugin options, не конфигурация, реально выбранная нативной платформой.
ОБХОД: оставить top-level `backgroundColor: "#0A0A0A"`, image и imageWidth неизменными и добавить `android: { backgroundColor: "#208aef" }`. Строчная проверка старого синего тоже зелёная из-за регистра. Обе пробы rc0, но реальный `getAndroidSplashConfig` из установленного expo-splash-screen возвращает синий фон `#208aef`.

Доказательства: `evidence/android-splash-blue-mutations.json`, `android-splash-blue-probe.txt`, `android-splash-blue-static_probe.txt`, `native-observers.txt`, `android-splash-blue-995-entry.txt`. Вызов нативного config-resolver наблюдал эффект, APK/экран устройства не запускался. Оговорка о pixel evidence не делает неправильную effective-конфигурацию допустимой.

### B5

БЛОКИРУЕТ contracts/111-cmp-mob-first-run.md:135 — проверка существования двух правильных записей не запрещает некаталожную копию на поверхности, вопреки инварианту :97 и границе :81.
ОБХОД: перед Button добавить `<Text>Versicherung. Erledigt.</Text>`, не меняя ui-copy.ts, promise или CTA. Все 17 клеток зелёные; новый саблайн отображается без ключа и review_status. Сам контракт на :52–53 специально говорит, что этот саблайн в продукт не вводится.

Доказательства: `evidence/extra-unreviewed-copy-mutations.json`, `extra-unreviewed-copy-probe.txt`, `extra-unreviewed-copy-static_probe.txt`, `extra-unreviewed-copy-995-entry.txt`. Нужен наблюдаемый закрытый состав копии First-Run, а не только наличие двух разрешённых строк.

## Советы — не дополнительные основания FAIL

- СОВЕТ contracts/111-cmp-mob-first-run.md:171 — заменить пример команды на реально исполнимый `bash scripts/pre_critic.sh --repo <H> contracts/111-cmp-mob-first-run.md`. Дословный вызов из контракта rc1, исправленный rc0. Логи: `evidence/precritic-exact.txt`, `precritic-corrected.txt`.
- СОВЕТ contracts/111-cmp-mob-first-run.md:192 — `ПЕРЕСЕЧЕНИЕ:` без автора не является машинной строкой `ПЕРЕСЕЧЕНИЕ <автор>: <путь> — <NNN> <причина>` из precision-гейта. На данном OBJECT гейт rc0, блокирующей коллизии не доказано. Не считать эту пояснительную строку машинным разрешением будущого чужого пересечения.
- СОВЕТ contracts/111-cmp-mob-first-run.md:213 — убрать из сопровождающей прозы пары `onenter-not-wired → обе CTA-клетки`, аналогичные :210, :219–222, :277–279. Это запрещённые Н-39 привязки, хотя эвристика двери пропускает слово «красен». Привязки оставить коду батареи; предмет, инварианты и rc-команды от этого не меняются.
- СОВЕТ contracts/111-cmp-mob-first-run.md:138 — модельный wordmark не декодируется настоящим `pngjs`: `Unrecognised filter type - 236`; `file` видит только заголовок 8×44. Честная модель для бренд-предмета не должна подтверждаться только PNG-магией. Это дополнительное свидетельство слабого ассет-критерия B3, не требование автоматической pixel-perfect сверки. Лог: `evidence/native-observers.txt`.
- СОВЕТ contracts/111-cmp-mob-first-run.md:75 — live render модели сохраняет root PilotApp `backgroundColor:'#FFFFFF', paddingTop:48, paddingHorizontal:16, paddingBottom:16`. К1 проверяет лишь вложенный safe-area. [INFERENCE] На устройстве ожидается белое обрамление, а не полный ground-экран эталона. Физический кадр не снят; не выдаю это за измеренную визуальную регрессию. Проверить композицию всего First-Run, не только дочернего контейнера. Лог: `evidence/model-root-witness.txt`.
- СОВЕТ contracts/111-cmp-mob-first-run.md:159 — обе `--matrix` всегда устанавливают свою модель, а не мутируют переданное C. Это действительно самопроверка батареи (:146), а не независимое доказательство корректности C; сохранить это различие в отчётах.

## Сырые данные и предел доказательства

Сырой stdout/stderr, команды и rc вынесены **отдельно от диагноза** в `evidence/*.txt`. Основные файлы: `precision.txt`, `precritic-{exact,corrected}.txt`, `model-{probe,static_probe}.txt`, `matrix-{probe,static_probe}.txt`, пять групп мутантов из таблицы, `*-witness.txt`, `*-995-entry.txt`, `native-observers.txt`, `issue109.txt`. Скрипты воспроизведения находятся рядом с verdict: `probe_review.py`, `witness_review.py`, `preservation_review.py`, `observe.js`, `final_evidence.py`.

Первый исследовательский runner остановился на **моём** неверном якоре `"imageWidth": 76,` (в модели нет запятой). Этот неисполненный вариант не засчитан: отдельный `witness_review.py` применил уникальный существующий якорь и исполнил `android-splash-blue` с обоими rc0. Успешные предыдущие прогоны сохранены каждый своим логом.

Авторскую базовую красноту rc1 FIRST_RUN_SEAM_ABSENT не выдаю за собственный повторный замер; перепроверены модель, обе матрицы и дополнительные состояния. Запускался только scoped-регресс: батарея 111 и два entry-теста 995. Полные npm test/lint/typecheck, сборка APK, Maestro, GH PR checks, device evidence и фактический screenshot-review C — **NOT_RUN**. Отсутствие реализации C этим вердиктом не маскируется.

После исследовательских установок и witness-тестов статус disposable R был пустым (rc0), product-файлы восстановлены. Замороженные пробы не редактировались. Вердикт оставлен только в разрешённой папке сессии; для механизма freeze его должен перенести и закоммитить уполномоченный процесс, не эта непиннованная сессия.
