FAIL
Реализация 117 (OBJECT 814e95ed19b3b7bf8912d79c588e295e2a2bf121, Complior-mob PR#114) против замороженного 117/1 по
правилу (В) не сходится с макетами на устройстве. Из 8 кадров e2e ни один не принимается без расхождения.
Р1: на устройстве JS-слой всегда dark. Р2: splash dark не снят, на кадре рабочий стол. Р3: на кадре first-run
оверлей, а не First-Run. Р4: на F03 нет safe-area и отступов. Р5: нативный знак обрезан маской Android 12+.
Р6: оверлей не вписан и смещён на 28 px. Р7: кнопка и поле не size-lg 56. Р8: static-матрица на C невыполнима (architect). Машинные проверки на C зелёные
(22/22, 35/35, behavioral-матрица, 995 14/14, lint/typecheck; static-матрица rc2 по дефекту батареи, Р8), и это показывает, что батарея и сценарий не ловят именно то,
что видно глазами. Находки и чекбоксы: `/tmp/dev-harness-verify/Rev117/review.md` (status: ready).

Модель видит изображения: sheet.png, mock.png и 8 кадров артефакта открыты напрямую.
Сырьё: артефакт `maestro-117-7cec70895e822e2f94f8175bd815f270b91d175e-39549006074-1`, скачан `gh run download`.
Run 39549006074: headSha = OBJECT, event pull_request, quality и android-e2e success; 7cec708 — merge-sha.
Стенд: pixel_7, API 36, 1080×2400, 420 dpi (1 dp = 2,625 px).

## Покадровая сверка (правило (В))

| Кадр (тема/имя) | Файл кадра (артефакт `<тема>/2026-10-21_*/117 — …/takeScreenshot/`) | Макет | Что на кадре (видел сам) | Расхождения (px кадра) | Итог |
| --- | --- | --- | --- | --- | --- |
| dark / splash | `vkhod-117-splash.png` | `screens/Splash.png` | Рабочий стол Android: обои, Gmail/Photos/YouTube, док с иконкой complior, поиск Google. Приложения нет. | Splash dark не снят, сверять нечем. Сравнивать с макетом невозможно. | **FAIL** (Р2) |
| light / splash | `vkhod-117-splash.png` | `screens/Splash-Hell.png` (знак) | Нативный splash: фон `#f3f2ee`, один тёмный знак по центру, без wordmark и tagline. | Знак `[302..769]×[972..1427]` обрезан круговой маской: дуга сплющена сверху и снизу, кончик и точка срезаны. Центр y=1200 (457 dp) против 357 dp артборда (скачок ≈100 dp, принятый И2). Кадр оверлея Splash-Hell не снят. | **FAIL** (Р5, Р2) |
| dark / first-run | `vkhod-117-first-run.png` | `screens/First-Run.png` (по имени); фактически Splash.png | JS-оверлей Splash: знак, «complior», «Versicherung. Erledigt.» на `#0a0a0a`. First-Run не виден. | Против First-Run.png нет заголовка, подзаголовка, CTA и верхнего wordmark. Против Splash.png композиция 1:1 в dp, прижата к углу: tagline 149..874 (центр 511,5 против 540, −28 px), знак `[288..761]×[711..1166]` (при contain было бы `[305..803]×[781..1258]`). | **FAIL** (Р3, Р6) |
| light / first-run | `vkhod-117-first-run.png` | First-Run.png / Splash-Hell.png | Тот же тёмный оверлей, что в dark: 0 отличающихся px ниже y=100. | Светлой схемы нет (ожидался Splash-Hell `#f3f2ee` с тёмным знаком). Расхождения те же, что в dark. | **FAIL** (Р1, Р3, Р6) |
| dark / f03-01 | `vkhod-117-f03-01.png` | Нет PNG. Токены/компоненты D2.2.5.1 + таблица состава. | Заголовок «Anmelden oder Konto erstellen», подпись-body, пустое поле-пилюля panel, лаймовая кнопка «Demo mit Beispieldaten ansehen». Сверху бейдж Demo. | Нет safe-area: заголовок y 108..164 внутри statusBars `[0..136]`, бейдж `[0..137]×[0..64]` закрывает часы `[81..150]×[51..84]`. Отступ колонки 0: всё с x=0, поле `[0..1078]` от края до края. Кнопка 45,7 dp, не на всю ширину (size-lg 56). Поле 42,3 dp. Шрифт системный (И1, не блок). Цвета dark верны: ground `#0a0a0a`, panel `#1e1e1d`, primary `#d6f75a`, ink. Состав 4/4. | **FAIL** (Р4, Р7) |
| light / f03-01 | `vkhod-117-f03-01.png` | То же, светлая схема | Попиксельно тот же тёмный кадр, что dark. | Схема light не применена: ground `#0a0a0a` вместо `#f3f2ee`, primary лайм вместо `#121211`, panel `#1e1e1d` вместо `#e6e5df`. Плюс всё из dark/f03-01. | **FAIL** (Р1, Р4, Р7) |
| dark / f03-02 | `vkhod-117-f03-02.png` | Нет PNG. Токены/компоненты + состав. | «Kontakt bestätigen», подпись-body, поле, кнопка «Anmelden», ссылки accent: «Code erneut senden», «E-Mail ändern», «Zugang wiederherstellen». | Заголовок y 108..179 внутри статус-бара, бейдж на часах. x=0 у всех элементов. Кнопка `[0..295]×[425..544]` 45,7 dp. Поле 42,3 dp от края до края. Ссылки accent `#d6f75a` верны. Состав 7/7. | **FAIL** (Р4, Р7) |
| light / f03-02 | `vkhod-117-f03-02.png` | То же, светлая | Попиксельно тот же тёмный кадр. | Схема light не применена (как на f03-01 light). Плюс всё из dark/f03-02. | **FAIL** (Р1, Р4, Р7) |

Пути макетов: `/tmp/dev-harness-verify/Impl117/mob/docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/screens/{Splash,Splash-Hell,First-Run}.png`.
Копии кадров: `/tmp/dev-harness-verify/Rev117/shots/<тема>-<кадр>.png`. Кропы рядом с макетом: `cmp-light-splash.png`, `cmp-dark-firstrun.png`, `cmp-top.png`.

## Блокирующие находки → кто чинит

- **Р1** (implementer, pilot-app.tsx): схема ОС не доходит до PilotApp на production-входе, по умолчанию стоит dark.
  Repro: throwaway-тест `@/app/index` + `Appearance.getColorScheme='light'` даёт фон оверлея `#0a0a0a` при ожидании
  `#f3f2ee` (FAIL 1/1, файл удалён).
- **Р2** (implementer: сценарий; architect: строка приёмки): кадр splash снимается без ожидания окна приложения. В dark снят
  рабочий стол. Комментарий сценария запрещает ожидание `splash-overlay`, чтобы прогон не краснел. Проверка подогнана под код.
- **Р3** (implementer: сценарий; architect: приёмка): кадр first-run снимается при живом оверлее. Нет `assertNotVisible
  splash-overlay` и нет видимого текста First-Run. `assertVisible` проходит через перекрытие.
- **Р4** (implementer, auth-screen.tsx/pilot-app.tsx): на F03.01/F03.02 нет top-инсета и горизонтальных отступов.
- **Р5** (architect, литерал imageWidth 181 в инварианте 2): нативный знак обрезан маской Android 12+.
- **Р6** (implementer, pilot-app.tsx): композит оверлея не вписан contain, смещён влево на 28 px и прижат к верху.
- **Р7** (architect/владелец): кнопка и поле не size-lg 56, кнопка не на всю ширину (README Button/TextField), а `src/ui`
  read-only для 117.
- **Р8** (architect, батарея): static `--matrix` на C даёт rc2. Шаблонные байты читаются из `--repo`, поэтому на C это канон,
  и `icon-template-bytes` и `adaptive-favicon-template` выходят MUTANT_GREEN. Строка приёмки «Дано C; --matrix → rc0»
  невыполнима. Реализации не касается.

## Обход «зелёное при не по макету» (вопрос adversary)

Своим прогоном на C вся батарея и e2e зелёные при следующих состояниях:
(а) JS всегда в dark на светлом устройстве: Jest-клетки `*_LIGHT` сами оборачивают Provider (`vkhod.test.tsx:145,563`),
сценарий цвета не судит.
(б) Скриншот splash снят до появления окна, на нём рабочий стол.
(в) Оверлей закрывает First-Run, `assertVisible` проходит по иерархии.
(г) Контент под статус-баром и с нулевыми полями. В3 судит только translate/margin ≥ окна, а `assertVisible` перекрытие
статус-баром не видит.
(д) Нативный знак обрезан маской: клетки судят drawable-файлы, а не рендер ОС.

## Семь пунктов роли

1. Область правки: PASS. 14 файлов, все в ЗОНЕ implementer. Ассетов 9, ровно перечень.
2. Сырой вывод: PASS. Все команды прогнаны самим, rc приведены ниже.
3. Проверка не переписана под реализацию: батарея H не тронута (tree 03d0b1d5 = frozen = пин CI). Сценарий
   (зона implementer) подогнан: Р2 — отказ от ожидания оверлея и ложное утверждение о тайминге в комментарии
   (коммит b5884ad).
4. Красное предъявлено: на B 8748a7a3 rc1 `VKHOD_AUTH_DS_ABSENT` и rc1 `VKHOD_SPLASH_COMPOSITE_ABSENT`.
   Behavioral `--matrix` (одиночный прогон) rc0, honest 22, 20 мутантов красны. Static `--matrix`: rc2 (лог -07, одиночный прогон, R чист после): 18 мутантов красны, `MUTANT_GREEN icon-template-bytes` и `MUTANT_GREEN adaptive-favicon-template`. Строка приёмки «Дано C; --matrix → rc0» на C невыполнима по построению батареи (Р8, architect, см. review.md). Это не дефект реализации.
5. Атомарность: 6 коммитов `8748a7a3..OBJECT`, все со ссылкой «117»: основной 6f71256, два перепина H, три фикса CI
   и сценария. PASS.
6. Норма не тронута: diff только продуктовый. PASS.
7. Счётные утверждения: 22/22, 35/35, 14/14, 20 мутантов повторены своей мерой (подсчёт строк `case`/`mutant` в
   raw-логе). Утверждение сценария «кадр внутри окна оверлея» опровергнуто кадрами.

## Прогоны (сырой вывод: `/tmp/dev-harness-verify/Rev117/.log/`)

- `vkhod_probe.py --repo C` → rc0, `behavioral 22/22` (22 строки `case`)
- `vkhod_static_probe.py --repo C` → rc0, `static 35/35` (35 строк `case`)
- `vkhod_probe.py --repo C --matrix` → rc0, `honest green 22` + 20 строк `mutant … red=[…]` (лог -06, одиночный прогон, R чист после)
- Первый прогон static `--matrix` (лог -05, rc2, 2×MUTANT_GREEN, R остался грязным) испорчен МОЕЙ параллельной гонкой behavioral+static на одном R. Он не засчитан и в находки не идёт.
- `vkhod_static_probe.py --repo C --matrix` → rc2 (лог -07, одиночный прогон, R чист после): 18 мутантов красны, `MUTANT_GREEN icon-template-bytes` и `MUTANT_GREEN adaptive-favicon-template`. Строка приёмки «Дано C; --matrix → rc0» на C невыполнима по построению батареи (Р8, architect, см. review.md). Это не дефект реализации
- `vkhod_probe.py --repo B` → rc1 `VKHOD_AUTH_DS_ABSENT`; `vkhod_static_probe.py --repo B` → rc1 `VKHOD_SPLASH_COMPOSITE_ABSENT`
- `npx jest src/bootstrap/__tests__/pilot.test.tsx` → rc0, 14/14
- `npm run typecheck` → rc0; `npm run lint` → rc0
- `first_run_probe.py` (H 8f3a37dd) → rc0, honest 23/23
- `git status --short --untracked-files=all` в R → `?? mobile/node_modules` (только симлинк)
- `gh pr checks 114 --required` → rc0 (android-e2e pass, quality pass)

## Паразитная сложность (050), по артефактам диффа

- **mobile.yml, шаг 117 (+113 строк bash: свой AVD, `wait_stable117`, `boot_emulator`, `run_theme` с повтором).**
  (1) Приёмка «android-e2e исполняет сценарий 117 × тема». (2) Состояние: AVD `ci117-*`, порт 5562, повтор по сигнатуре
  adb. Повтор виден в логе строкой «ПОВТОР». (3) При правке сценария/тем меняются 2 файла (yml + yaml), как и раньше.
  (4) Интерфейса наружу нет. Читаются только `ANDROID_HOME`/`GITHUB_RUN_*`, работа скрыта внутри. Вызов maestro
  продублирован дважды внутри `run_theme`. (5) Потребитель — required-check android-e2e. Загрузка эмулятора повторяет
  логику шага 995 (`scripts/ci-e2e.sh` H). Класс: ESSENTIAL по свойству. Дубль вызова maestro и boot-логики — совет,
  не блок: более простой формы, проходящей те же строки, не называю.
- **Оверлей в pilot-app.tsx (`splashVisible`, таймер 1200, `preventAutoHideAsync` на модуле).** (1) Инвариант 8.
  (2) Состояние явное: useState + effect cleanup. (3) Один файл. (4) Глубина нормальная. (5) Потребитель — клетки
  SPLASH_OVERLAY_*. ESSENTIAL.
- **`D22_TITLE` в auth-screen.tsx.** (1) Инвариант 6 (.title 28/32/500). (2) Состояния нет. (3) Один файл. (4) Константа.
  (5) Потребитель — AUTH_*_STRUCTURE. ESSENTIAL.
- **Сценарий `vkhod-117-splash-vhod.yaml`.** (1) Приёмка Б3 + правило (В). (2)–(4) Без состояния. (5) Потребитель — CI.
  ESSENTIAL. Дефект содержательный (Р2/Р3), а не сложность.
- **Ассеты (семья, 9 файлов).** (1) Инварианты 1–4. ESSENTIAL.

## ПРОВОДКА (038)

Канал правила (В): ПРОВОДКА-ЭНФОРСМЕНТ, cognitive-only, ловец — reviewer. Он существует и здесь сработал: все находки
Р1–Р7 найдены только глазами и своей мерой по кадрам, машинный гейт сверки отсутствует. Это ровно предсказанный
контрактом остаточный риск. Роль-строка нормы есть в `roles/reviewer.md` («Мобильный экран — сверка с макетом», слово
владельца 2026-10-20).

## Режим проекта (996)

sourceCanon для 117 не объявлен в контракте, sync-gate неприменим. Вердикт привязан к OBJECT 814e95ed. Следующая
редакция не наследует оценку.
