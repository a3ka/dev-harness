accept
111 v3: в предъявленной дельте ослабления защиты от тихого дефолт-синего и платформенного переопределения splash не обнаружено. Миграция двух клеток принимается; новые числа подтверждены. Это не повторная приёмка всего контракта 111 и не визуальная приёмка продукта.

## Предмет и изоляция

- OBJECT: `d4a85c538efe5a631af750f7520c71ef95d4466c`, закоммиченный `contracts/111-cmp-mob-first-run.md`.
- Разобрана именно дельта `git diff frozen/contracts/111/2 d4a85c538efe5a631af750f7520c71ef95d4466c -- contracts/111-cmp-mob-first-run.md`, а не авторский черновик. Строка `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` присутствует в теле изменяющего коммита.
- Клон харнесса: `/tmp/dev-harness-verify/Critic111v3/repo` (собственный `.git`). Копия продукта: `/tmp/dev-harness-verify/Critic111v3/product117` @ `0d1a09b08b5294e0578f9887541662b5f4bbbd08`. Копия базы: `/tmp/dev-harness-verify/Critic111v3/baseB` @ `8748a7a3352c14a6caa5a75b71f869e5d3b8152c`.
- Исходный worktree и продукт Impl117 не изменялись. Runtime-зависимости скопированы в собственный каталог; база использовала ссылку на эту собственную копию. Все мутации выполнялись только в копиях.
- Набор артефактов полон: предмет, команды готовности, исполнители и зоны присутствуют. Новых зон или семей case-файлов дельта не вводит; precision-гейт дополнительно исполнен, rc 0.

## Живые прогоны

Обозначения для команд ниже:

```sh
H=/tmp/dev-harness-verify/Critic111v3/repo
R=/tmp/dev-harness-verify/Critic111v3/product117
B=/tmp/dev-harness-verify/Critic111v3/baseB
```

Команды с относительными путями исполнены из `$H`.

| Команда | rc | Наблюдение |
|---|---:|---|
| `python3 fixtures/workshop_project/first_run_111/first_run_static_probe.py --repo "$R"` | 0 | `static 16/16` |
| `python3 fixtures/workshop_project/first_run_111/first_run_probe.py --repo "$R"` | 0 | `honest 23/23` |
| `python3 fixtures/workshop_project/first_run_111/first_run_static_probe.py --repo "$R" --matrix` | 0 | Все 16 мутантов отвергнуты; нет `MUTANT_GREEN`, `MUTANT_NAMED_MISS`, `MUTANT_UNEXPECTED_RED` |
| `python3 fixtures/workshop_project/first_run_111/first_run_probe.py --repo "$B" --matrix` | 0 | Все 26 мутантов отвергнуты; нет указанных дефектов матрицы |
| `python3 fixtures/workshop_project/first_run_111/first_run_static_probe.py --repo "$B"` | 1 | Ровно `SPLASH_GROUND_SCHEME` и `SPLASH_EFFECTIVE_GROUND_BOTH` красны; остальные 14 зелены |
| `python3 fixtures/workshop_project/first_run_111/first_run_probe.py --repo "$B"` | 0 | `honest 23/23` |
| `python3 fixtures/workshop_project/vkhod_117/vkhod_static_probe.py --repo "$R"` | 0 | `static 35/35`, включая реальные generated drawable и iOS storyboard |
| `bash scripts/check_precision_gate.sh "$H" contracts/111-cmp-mob-first-run.md` | 0 | Гейт выполнен |
| `cmp fixtures/workshop_project/first_run_111/model/app.json "$R/mobile/app.json"` | 0 | Модель app.json байт-равна продукту 117 |

Поведенческая матрица использует собственную эталонную модель; выбор базы для этого прогона не выдаётся за проверку поведения немодифицированного 117. Последнее отдельно проверено строкой `--repo "$R"` без `--model`.

Независимая сверка чисел, не повтор счётчика пробы:

- AST двух Python-файлов: словари `MUTANTS` содержат соответственно **26** и **16** уникальных ключей. Исполнено `python3 /tmp/dev-harness-verify/Critic111v3/exercise_delta.py`, rc 0.
- Поведенческие клетки: 11 циклов по буквальному `['dark', 'light']`, каждый объявляет один `it`, плюс один отдельный `CTA_TEXT_EQUALS_FRAME_TITLE`: **11×2+1 = 23**.
- Статические клетки по различным идентификаторам в `run_checks`: splash 3 + copy 2 + screen 5 + Pilot 2 + wordmark 3 + oracle 1 = **16**; альтернативные ветви ошибок не считаются повторно.
- Поэтому изменённые утверждения `16 клеток`, `26+16 стабов`, `23/23, 16/16` достоверны. Добавленные в перечень wordmark-клетки уже существовали в коде v2; это синхронизация описания, не новая работа.

## Независимые попытки обхода

Команда: `python3 /tmp/dev-harness-verify/Critic111v3/exercise_delta.py` → **rc 0**. Она поочерёдно меняет настоящий `mobile/app.json` копии продукта, вызывает CLI статической пробы без `--model`, сверяет точный набор отказов и восстанавливает исходные байты через `finally`.

Сокращения только для таблицы доказательств: G = `SPLASH_GROUND_SCHEME`; E = `SPLASH_EFFECTIVE_GROUND_BOTH`; D = `SPLASH_DEFAULT_BLUE_GONE`.

| Мутация настоящего продукта 117 | rc пробы | Красные клетки |
|---|---:|---|
| Корень `backgroundColor = #208AEF` | 1 | G, E, D |
| `android.backgroundColor = #208aef`, корень/dark верны | 1 | E |
| `ios.backgroundColor = #208aef`, корень/dark верны | 1 | E |
| `dark.backgroundColor = #208AEF`, корень верен | 1 | G, E, D |
| `android.dark.backgroundColor = #208aef` | 1 | E |
| `ios.dark.backgroundColor = #208aef` | 1 | E |
| Светлый знак подменён тёмным | 1 | G |
| Тёмный знак подменён светлым | 1 | G |
| `imageWidth = 76` вместо 181 | 1 | G |
| Блок `dark` удалён | 1 | G, E |
| `android.backgroundColor = null` | 1 | E |
| `ios.backgroundColor = null` | 1 | E |
| `android.dark.backgroundColor = null` | 1 | E |
| `ios.dark.backgroundColor = null` | 1 | E |

Дополнительная попытка ослабления — спрятать дефолт через нижний регистр платформенного цвета, чтобы строковый страж D не помог, и через `null`, включающий fallback резолвера. Во всех восьми платформенных вариантах отказ даёт именно E. Следовательно наблюдаемый отказ не является побочной краснотой строкового поиска синего. Успешного обхода в заданной области не найдено.

Подмена знаков/ширины обязана красить G, а не E: E судит эффективные фоны. Это разделение сохранено, а не выдано за проверку изображения клеткой фона.

Сырые stdout/stderr, rc и точные мутации: `/tmp/dev-harness-verify/Critic111v3/delta-evidence.json`. Явно сохранённые rc поведенческой матрицы и батареи 117: `/tmp/dev-harness-verify/Critic111v3/captured-results.json`; воспроизведение — `capture_results.py` в том же каталоге.

## Граница изменений и пять вопросов критика

1. Предмет миграции не подменён существованием фикстуры: честный 117 зелён, изменённые состояния реально отвергаются. Старый B красен ровно на согласованных двух клетках.
2. Изменённые критерии имеют живые команды с rc, результаты приведены выше. Новые числовые утверждения совпадают и с прогонами, и с независимым счётом.
3. Выбор цветов, знаков, ширины и resizeMode не оставлен исполнителю: указан единый источник `vkhod_117/source.json → appjson_literals`.
4. Зоны не расширялись. В рассматриваемых путях относительно v2 изменены ровно контракт и три файла семьи 111: `source.json`, `first_run_static_probe.py`, `model/app.json`. Модель целиком синхронизирована с 117; проверки остальных клеток не изменены.
5. В изменённых предмете/критерии/границах блокирующего противоречия норме не найдено. Прочие разделы уже замороженного 111 заново не судились.

Побайтовая неизменность проверена командами (обе rc 0, diff пуст):

```sh
git diff --exit-code frozen/contracts/111/2 d4a85c538 -- fixtures/workshop_project/vkhod_117 fixtures/workshop_project/first_run_111/first_run_probe.py fixtures/workshop_project/first_run_111/first_run.test.tsx fixtures/workshop_project/first_run_111/probe_lib.py
git diff --exit-code frozen/contracts/117/1 d4a85c538 -- fixtures/workshop_project/vkhod_117
```

То есть батарея 117, включая единый источник литералов, не переписана ради зелени; поведенческая батарея 111 также неизменна. pre_critic повторно не запускался: его rc 0 передан в задании. Полные lint/build/test проекта и визуальная сверка телефона не выполнялись и данным accept не утверждаются.

## Неблокирующие замечания по дельте

СОВЕТ contracts/111-cmp-mob-first-run.md:422 — новый измерительный раздел снова переносит пары «стаб ↔ клетки» из кода в прозу. Для Н-39 лучше оставить здесь команду и ссылку на сырой результат, не второй поддерживаемый перечень. Это замечание к описанию замера, не новый критерий готовности и не блокер данной миграции.

СОВЕТ contracts/111-cmp-mob-first-run.md:4 — шапка говорит «форк … ОТВЕЧЕНО», но в снимке OBJECT сам `forks/n111-v3-splash-static.md` ещё содержит `ОТВЕЧЕНО: нет`. Слово владельца явно передано в задании, а разрешающая строка присутствует в коммите; это рассинхронизация записи решения, не доказанный обход приёмки. Синхронизировать state форка при приземлении, без нового круга критика.

Блокирующих находок: 0. Вердикт предназначен для коммита оркестратором; critic не коммитил в read-only worktree и не делал push.
