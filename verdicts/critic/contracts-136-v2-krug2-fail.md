FAIL
OBJECT=59ba025a9f7c5533aaed535d2daf032659234292

# Критик 136 v2 — круг 2, финальный scoped-круг

**Блокеров: 3 группы (B1–B3), 6 исполненных зелёных обходов.** Все двенадцать старых мутантов m01–m12 теперь красные. Конкретные старые примеры закрыты, но новые независимые мутации по тем же трём осям проходят 48/48. Заморозка не разрешена.

**СТОП: нового круга критика или выдачи реализации по этому кандидату нет.**
АРБИТР: независимый `arbiter` по предмету 136, созыв через Main; предмет арбитража — повторный FAIL B1–B3 после закрытия конкретных m06–m10, достаточность новых красных входов для обязательных свойств И-4/И-6/И-8. Автор конструкции — сторона, не судья. Это направление на арбитраж, не уже состоявшийся арбитраж и не решение владельца о принятии риска.

Попытка передать Main уведомление о блокерах и созыве арбитра через `write agent://Main` отказала: `внутренний URI непиннованной сессии запрещён — Н-85`. Поэтому направление зафиксировано здесь и передаётся итогом задания; не утверждаю, что новый арбитр уже запущен.

Судья: Critic136v2b, openai-codex/gpt-6-astra. Своя копия с собственным `.git`: `/tmp/dev-harness-verify/Critic136v2b/repo`, получена `cp -r /tmp/dev-harness-verify/Architect136v2/repo .../Critic136v2b/repo`. HEAD равен OBJECT. Предмет — закоммиченный контракт и дельта `da8f1c2f..59ba025a`, преимущественно `1be3128f..59ba025a`; реализация 3cee078b не судится повторно. Вердикт **не коммичен и не пушен по прямому ограничению задания**. Чужие клоны и основной чекаут не менялись.

## Допуск, регресс и способ исполнения

Набор артефактов полный: предмет И-1…И-8, критерий с командами/rc, исполнители и зоны, риск и модель угроз присутствуют. Класс «рисковый — безопасность/авторизация записи» соответствует выдаче пинов worktree/agent://. Читаемые контракт и исходники батарей совпали с HEAD: `git diff HEAD -- contracts/136-dovodka-sessij-proektov.md fixtures/workshop_project/sessii_136 fixtures/workshop_project/sessii_125` пуст.

- Оба изменяющих контракт коммита, 1be3128f и 59ba025a, авторства `architect <architect@dev-harness.local>`. Требуемая строка `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` в обоих телах сравнена целиком: `OWNER_LINE_EXACT ... True`, без нормализации или сравнения только префикса.
- 18 изменённых файлов: только контракт 136, семейство 136 и `_gruppa_c.sh` 125. Diff текста `contracts/125-*`, стража `.omp/extensions/path-guard.ts`, производственных `scripts/` и чужих фикстур пуст. Зона implementer не расширена: ровно `scripts/connect_project.sh scripts/make_task.sh scripts/verify_ci_parity.sh`.
- Все прежние 34 клетки/18 стабов v1 и 7 клеток/7 стабов первого кандидата v2 сохранены по именам; старые описания клеток равны, привязки равны, файлы старых стабов побайтно равны. Изменений старых описаний: `V1_METADATA_CHANGED []`, `V2_R1_METADATA_CHANGED []`.
- Независимые меры: jq **48/46/30**; каталоги стабов **30**; Python по JSON **48/46/30**; ORDER — **48 уникальных имён**, равен множеству kletki; синтаксическая AST-проверка подграмматики диспетчера `run_cell` — **48 case-ветвей/48 имён**, все равны kletki. Полный shell-синтаксис отдельно принят `bash -n`. Это не выдаётся за универсальный AST-парсер всего bash.
- 125 plain и `--model` — **70/70**. Вся 125 с честной дверью v2 — **70/70**. c01 больше не путает строку MSG с отдельным argv. c12 сохранила прежние проверки и добавила зонды: m01 красен на c01/c12, m06 — на c12. Допуск корректного хвоста 136 вместо старой формы без хвоста — разрешённое развитие 125-б, не буквальное включение всех старых допустимых байтов argv.
- `pre_critic`, `check_precision_gate` и scoped `verify_antiplacebo --scope verify_ci_parity` дали rc 0; последний предъявил красными 26/26 фикстур одного барьера.

**Изоляция.** Оригинальные раннеры содержат общие абсолютные `/tmp/dev-harness-verify/sessii-136-*`, `/tmp/dev-harness-fakehome-136/` и `/tmp/dev-harness-verify/s125`. Чтобы не писать в чужие миры, исполнялись копии `critic_*.sh` рядом с раннерами в своём клоне: заменены только корни миров. Для каждого полного прогона и мутанта — отдельный каталог `Critic136v2b/runs/<имя>/`; TMPDIR также свой. Fakehome находится вне `${TMPDIR}/dev-harness-verify`, поэтому a7 не зеленеет за счёт scratch-allowlist. Поведенческие прогоны шли последовательно. Страж/его allowlist не менялись.

Для мутантов менялся только выбор субъекта DOOR/PAR в копии раннера; код клеток и оракулы сохранялись. Для 125 с v2/n01/n02 подменялся только S_C в копии раннера, а не продуктовый файл. Одноразовые timing-пробы и повреждения установки ниже явно отделены от штатных прогонов. Все генераторы, мутанты, миры и полные stdout/stderr/rc сохранены в своей области: `audit.py`, `new_mutants.py`, `source_mutant.py`, `probes.py`, `flake.py`, `inheritance.py`, `meta.py`, `counts_ast.py`, `mutants/`, `logs/`.

## Блокирующие находки

### B1 — все формы argv проверены, но не весь выбор/состав MSG

БЛОКИРУЕТ contracts/136-dovodka-sessij-proektov.md:48 — запрет дописывать корень в MSG и выбор служебного брифа при пустом NEXT_TASK не удержаны критерием строк 57/59. a29 проверяет четыре argv, HANDOFF и извлекаемый пин, но не запрещённую добавку к MSG; пустой существующий NEXT_TASK не предъявлен.
ОБХОД: `n01-brief-extra-root` сохраняет правильный `exec --yolo "$KOREN" -- "$MSG"`, но только при отсутствии task-file и непустого NEXT_TASK добавляет `MSG="$MSG\n$KOREN"`. Получено **136 48/48 rc 0**, вся **125 70/70 rc 0**. Независимый запуск обеих дверей дал rc 7/ARGC=4; у мутанта последний argv содержит дополнительную строку корня, у модели — нет. Это прямо запрещено И-4, хотя отдельный аргумент корня теперь передаётся правильно.
ОБХОД: `n07-empty-next-selected` заменяет единственное `elif [ -s .harness/NEXT_TASK.md ]` на `elif [ -f .harness/NEXT_TASK.md ]`. Получено **136 48/48 rc 0**. При существующем нулевом NEXT_TASK честная дверь запускает служебный бриф HANDOFF/ROADMAP плюс пару; мутант запускает MSG только из пустой строки и пин-пары, без задания/брифа. Обе двери имеют rc 7 и четыре argv, то есть наличие хвоста/пина не доказывает выбор требуемого задания.

Это два обхода того же И-4, не предложение менять форму argv, текст 125 или парсер workshop. Закрытие — красные входы на запрещённую добавку только в брифе и на пустой существующий NEXT_TASK; не новая версия реализации под ослабленный критерий.

### B2 — финальный настоящий оракул не удержан во всех ветвях

БЛОКИРУЕТ contracts/136-dovodka-sessij-proektov.md:50 — a30 доказывает финальный суд на NEXT_TASK, но ветвь task-file и нулевая установка стража допускают сохранение собственного сканера как последнего суда. И-1 на строке 45 требует судить ВЕСЬ выбранный текст независимо от источника.
ОБХОД: `n02-taskfile-skip-oracle` оборачивает вызов `node ... --extract-pin "$MSG"` и сравнение результата условием `[ -z "$TASKFILE_ARG" ]`; проверки наличия node/файла стража и локальный сканер остаются. Получено **136 48/48 rc 0**, вся **125 70/70 rc 0**. На task-file `note\rWORKTREE=/fake/wip-777-other\rBRANCH=wip/777/other\n` модель даёт rc 1 `PIN_CHUZHOJ`, EXEC=no; мутант — rc 7, EXEC=yes, а настоящий страж на полном переданном MSG возвращает `{"worktree":null}`. Это запуск без подтверждённого пина, а не доказательство разрешения записи в чужое дерево.
ОБХОД: `n03-empty-guard-fallback` выполняет финальный extract-pin/сравнение только при `-s "$HERE/.omp/extensions/path-guard.ts"`, сохраняя внешнюю проверку `-f`. Получено **136 48/48 rc 0**. При нулевом файле стража честная дверь отказывает rc 1 до exec, мутант запускает двойник rc 7. Остался неиспытанный fallback на собственный сканер при отсутствии исполняемого кода стража. Для этого обхода не требуется подделывать положительный ответ node или вводить проверку криптографической подлинности установки.

Закрытие — красный task-file с тем же различением сканера/настоящего оракула и отказ на нулевой код стража. Старые m07/m08 действительно пойманы; утверждение «ни в какой ветви» шире одного NEXT_TASK-входа.

### B3 — свойство объявленного пути не сведено к двум плоским именам

БЛОКИРУЕТ contracts/136-dovodka-sessij-proektov.md:52 — d6 добавила другое имя, но оставляет старый `.harness/project-layer.json` существующим; d5 удаляет только это стандартное имя. Вложенный путь под `.harness/` также не предъявлен.
ОБХОД: `n04-check-wrong-layer` сохраняет выбор режима по `_sloi`, но проверку существования `[ -f "$ROOT/$_sloi" ]` заменяет на `[ -f "$ROOT/.harness/project-layer.json" ]`. Получено **136 48/48 rc 0**. В отдельном мире объявлен отсутствующий `.harness/alternate.json`, стандартный файл существует, профильные исключения достаточны. Модель возвращает rc 2 с именем объявленного отсутствующего слоя; мутант — rc 0, `расхождений: 0`. Потеря объявленного слоя больше не удерживается.
ОБХОД: `n05-nested-layer-harness` добавляет перед `.harness/*)` ветвь `.harness/*/*) : ;;`, то есть вложенный профильный слой считает режимом харнесса. Получено **136 48/48 rc 0**. В отдельном мире объявлен и существует `.harness/layers/custom.json`, профильные исключения пусты, корневые достаточны. Модель — rc 1, `объявленных исключений: 0`, `расхождений: 2`; мутант — rc 0, `объявленных исключений: 2`, `расхождений: 0`. Путь по-прежнему под `.harness/`; новой грамматики/валидации профиля эта находка не требует.

Закрытие — предъявить потерю именно переименованного объявленного слоя при сохранённом стандартном и корректный вложенный объявленный слой. Подмена условия свойством одного буквального файла остаётся тем же B3, а не новым предметом.

## Советы и флейк

СОВЕТ contracts/136-dovodka-sessij-proektov.md:57 — `c2-p17-rules` имеет воспроизведённый механизм ложного красного: `mkt_brief | grep -Fqx ...` под `pipefail`. В трёх изолированных полных `--model` получено 48/48 каждый раз; естественный флейк не возник. Однако добавленная ТОЛЬКО в одноразовую копию производителя пауза 50 ms после печати RULES дала `PIPESTATUS=141 0`; чтение всего stdout той же копии — rc 0, `cmp` с честным stdout — 0; grep без раннего `-q` — `PIPESTATUS=0 0`. Значит корректный производитель может получить SIGPIPE от успешного потребителя. Это дефект проверки, а не показанный дефект brief/фильтра ролей. [INFERENCE] Исторические два отказа архитектора совместимы с этим механизмом, но без его PIPESTATUS тождество причин не доказано. По порогу этого суда отдельного блокера нет: это ложное красное, не зелёный обход. Исправлять следует потребителя/сбор вывода, не маскировать ретраем. c1 использует аналогичную форму; отдельного нового предмета из этого не делаю.

СОВЕТ contracts/136-dovodka-sessij-proektov.md:50 — границу доверия к установке стоит называть явно. На честной модели пустой, JSON-null и синтаксически битый страж дали rc 1 без exec. Отсутствие x-бита у читаемого файла не мешает node: rc 7 корректен. Подложный guard или node, печатающий ожидаемый положительный JSON, дали rc 7. Последнее — подмена доверенной установки/PATH, не доказанный обход через текст задания; не требую нового механизма аутентификации кода стража. B2 выше не опирается на необходимость такой аутентификации.

СОВЕТ contracts/136-dovodka-sessij-proektov.md:62 — фраза «m08 красен на c12» не соответствует собственному прогону: группа C на m08 дала 22 зелёных, включая c12; отсутствие node она не предъявляет. На 136 m08 честно пойман a31. После усиления c12 m01 красен уже на c01 И c12, а не «ровно c01». Это неточные пояснения замеров; отдельного нового обхода сверх B1–B3 здесь не заявляю.

СОВЕТ contracts/136-dovodka-sessij-proektov.md:68 — пересечение всё ещё говорит «остальные клетки ... НЕ меняются», хотя согласованная правка усилила c12 и правило 7 это описывает. Механическая зона architect включает семейство 125, implementer-зона не расширена; привести пояснение границы в соответствие с уже разрешённым усилением.

## Пять вопросов гейта

1. Критерий слабее предмета? **Да, B1–B3:** шесть конкретных зелёных реализаций при нарушении явно названного результата.
2. Названные команды доказывают готовность? Команды/rc есть и штатные числа воспроизведены, но они не различают перечисленные обходы. Проза «diff = модели» не заменяет требуемые до заморозки красные поведенческие входы.
3. Есть молчаливое решение исполнителю? Форма argv, источники MSG, fail-closed и предикат режима заданы явно; главная проблема не недоопределённая архитектура, а отсутствие различающих входов. Доверие к установке отмечено советом.
4. Границы исполнения названы? Да, механические зоны и исполнители есть; требуемые продуктовые изменения укладываются в прежние три файла implementer. Нет основания расширять его зону на страж или фикстуры.
5. Противоречие норме AGENTS.md? Обязательная атака до кода исполнена; риск, модель угроз и precision представлены. Зелёные обманки B1–B3 не удовлетворяют норме красных тестов до реализации. Отдельных новых блокеров по остальной прозе документа не выдвигаю.

## Таблица мутантов

Цвет — цвет приёмки мутанта. `rc 2` в подстановочном `--model` сопровождается перечислением красных клеток и означает поимку, не поломку мира. Старые m01–m12 взяты из файлов первого критика без изменения. Здесь написаны семь дополнительных вариантов: n01–n05 и n07 — **шесть независимых новых относительно перечисленных o1–o11 автора**; n06 повторяет класс авторского o10 и учитывается только как дополнительный отрицательный контроль d8, не в квоте шести новых.

| Мутант | Дельта | 136 | Дополнительная проверка |
|---|---|---|---|
| m01-noroot | нет корня | красный 44/4: a25,a26,a28,a29 | 125/C: c01,c12 красны |
| m02-root-in-msg | корень только в MSG | красный 44/4: a25,a26,a28,a29 | — |
| m03-root-after-separator | корень после -- | красный 44/4: a25,a26,a28,a29 | — |
| m04-foreign-root | чужой корень | красный 44/4: a25,a26,a28,a29 | — |
| m05-duplicate-root | дубль корня | красный 44/4: a25,a26,a28,a29 | — |
| m06-taskfile-noroot | нет корня только task-file | красный 47/1: a28 | 125/C: c12 красна |
| m07-no-final-oracle | удалён финальный extract-pin | красный 47/1: a30 | — |
| m08-node-fallback | нет node → exec | красный 47/1: a31 | 125/C: 22/22 |
| m09-exact-layer-only | режим только по одному имени | красный 47/1: d6 | — |
| m10-parity-jq-fallback | нет jq → успех | красный 47/1: d7 | — |
| m11-allow-duplicate | нет PIN_DUBL | красный 45/3: a10,a19,a21 | — |
| m12-append-root-to-msg | корень дописан всем MSG | красный 45/3: a25,a26,a28 | — |
| n01-brief-extra-root | корень дописан только брифу, argv правильный | **зелёный 48/48** | вся 125 70/70; B1 |
| n02-taskfile-skip-oracle | task-file без финального стража | **зелёный 48/48** | вся 125 70/70; B2 |
| n03-empty-guard-fallback | нулевой файл → локальный сканер | **зелёный 48/48** | empty guard: exec вместо отказа; B2 |
| n04-check-wrong-layer | проверяется не объявленный файл | **зелёный 48/48** | потеря alternate: rc 0 вместо 2; B3 |
| n05-nested-layer-harness | вложенный слой → режим харнесса | **зелёный 48/48** | корневые исключения: rc 0 вместо 1; B3 |
| n06-broken-profile-accepted | неразбираемый профиль → успех | красный 47/1: d8 | контроль уже закрытого входа |
| n07-empty-next-selected | пустой NEXT_TASK выбран вместо брифа | **зелёный 48/48** | MSG только с парой; B1 |

## Замеры

| Команда/сценарий | Собственный результат |
|---|---|
| 136 plain ×3, отдельные миры | каждый раз 48 клеток / 5 зелёных / 43 красных, rc 1 |
| 136 --model ×3, отдельные миры | каждый раз 48/48, rc 0 |
| 136 --stabs | 30 стабов / 46 привязок / 0 непойманных, rc 0 |
| 125 plain / --model | 70/70 / 70/70, rc 0 / 0 |
| вся 125 с честной v2-дверью | 70/70, rc 0 |
| вся 125 с n01 / n02 | 70/70 / 70/70, rc 0 / 0 |
| pre_critic 136 | rc 0 |
| check_precision_gate на своём клоне | rc 0, OK |
| verify_antiplacebo --scope verify_ci_parity | 1 барьер / 26 фикстур / 26 красных предъявлений, rc 0 |
| отвергнутые три субъекта 3cee078b на 136 | 39/9, rc 1: a25,a26,a27,a28,a31,b3,d5,d7,d8 |
| guard --extract-pin 'текст без пары' | {"worktree":null}, rc 0 |
| frozen/чужие поверхности | diff пуст |

11 отдельных батарей лаунчера, project-wide CI и живую omp-сессию не запускал: они вне назначенного scoped-регресса этого круга. Неизменность их файлов не выдаётся за исполнение.

## Команды и сырой вывод мутаций

CWD всех команд — свой `repo`. Полные объединённые stdout/stderr и rc также лежат в `Critic136v2b/logs/<имя>.txt`. Ниже вывод каждой мутации без сокращения; команды запускают сохранённые копии раннера с раскрытой выше релокацией и подстановкой субъекта.

```text
$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_m01-noroot-136.sh --model
sessii_136: клеток 48, зелёных 44, красных 4
красные: a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem a28-taskfile-argv a29-brief-argv
модель не зелёная
RC=2

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_m02-root-in-msg-136.sh --model
sessii_136: клеток 48, зелёных 44, красных 4
красные: a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem a28-taskfile-argv a29-brief-argv
модель не зелёная
RC=2

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_m03-root-after-separator-136.sh --model
sessii_136: клеток 48, зелёных 44, красных 4
красные: a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem a28-taskfile-argv a29-brief-argv
модель не зелёная
RC=2

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_m04-foreign-root-136.sh --model
sessii_136: клеток 48, зелёных 44, красных 4
красные: a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem a28-taskfile-argv a29-brief-argv
модель не зелёная
RC=2

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_m05-duplicate-root-136.sh --model
sessii_136: клеток 48, зелёных 44, красных 4
красные: a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem a28-taskfile-argv a29-brief-argv
модель не зелёная
RC=2

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_m06-taskfile-noroot-136.sh --model
sessii_136: клеток 48, зелёных 47, красных 1
красные: a28-taskfile-argv
модель не зелёная
RC=2

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_m07-no-final-oracle-136.sh --model
sessii_136: клеток 48, зелёных 47, красных 1
красные: a30-finalnyj-orakul
модель не зелёная
RC=2

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_m08-node-fallback-136.sh --model
sessii_136: клеток 48, зелёных 47, красных 1
красные: a31-net-node
модель не зелёная
RC=2

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_m09-exact-layer-only-136.sh --model
sessii_136: клеток 48, зелёных 47, красных 1
красные: d6-sloi-drugoe-imja
модель не зелёная
RC=2

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_m10-parity-jq-fallback-136.sh --model
sessii_136: клеток 48, зелёных 47, красных 1
красные: d7-bez-jq
модель не зелёная
RC=2

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_m11-allow-duplicate-136.sh --model
sessii_136: клеток 48, зелёных 45, красных 3
красные: a10-pin-duplicate a19-pin-inline-mixed a21-pin-taskfile-duplicate
модель не зелёная
RC=2

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_m12-append-root-to-msg-136.sh --model
sessii_136: клеток 48, зелёных 45, красных 3
красные: a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem a28-taskfile-argv
модель не зелёная
RC=2

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_n01-brief-extra-root-136.sh --model
sessii_136: клеток 48, зелёных 48, красных 0
RC=0

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_n02-taskfile-skip-oracle-136.sh --model
sessii_136: клеток 48, зелёных 48, красных 0
RC=0

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_n03-empty-guard-fallback-136.sh --model
sessii_136: клеток 48, зелёных 48, красных 0
RC=0

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_n04-check-wrong-layer-136.sh --model
sessii_136: клеток 48, зелёных 48, красных 0
RC=0

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_n05-nested-layer-harness-136.sh --model
sessii_136: клеток 48, зелёных 48, красных 0
RC=0

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_n06-broken-profile-accepted-136.sh --model
sessii_136: клеток 48, зелёных 47, красных 1
красные: d8-profil-bit
модель не зелёная
RC=2

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_n07-empty-next-selected-136.sh --model
sessii_136: клеток 48, зелёных 48, красных 0
RC=0
```

## Сырой вывод независимых smoke

```text
$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_probe_taskfile-oracle.sh --model
SUBJECT=/tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/model/connect_project.sh RC=1
connect ОТКАЗ: PIN_CHUZHOJ: итоговый текст не извлекается в пин двери
EXEC=no
SUBJECT=/tmp/dev-harness-verify/Critic136v2b/mutants/n02-taskfile-skip-oracle/connect_project.sh RC=7
EXEC=yes
{"worktree":null}
RC=0

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_probe_empty-guard.sh --model
connect ОТКАЗ: PIN_CHUZHOJ: итоговый текст не извлекается в пин двери
SUBJECT=/tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/model/connect_project.sh RC=1
EXEC=no
SUBJECT=/tmp/dev-harness-verify/Critic136v2b/mutants/n03-empty-guard-fallback/connect_project.sh RC=7
EXEC=yes
RC=0

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_probe_layer-predicates.sh --model
KIND=missing-alternate SUBJECT=/tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/model/verify_ci_parity.sh
NOT_IMPLEMENTED: объявленный слой проекта потерян: /tmp/dev-harness-verify/Critic136v2b/runs/layer-predicates/fakehomeprobe-layer-missing-alternate/seed/toy-proj/.harness/alternate.json
SUBJECT_RC=2
KIND=missing-alternate SUBJECT=/tmp/dev-harness-verify/Critic136v2b/mutants/n04-check-wrong-layer/verify_ci_parity.sh
  ok   команда «npm run dev» (.github/workflows/ci.yml:7) приёмкой не является — объявленное исключение: команда релизного CI проекта, приёмкой пакета не является совсем
  ok   скрипт «build» не в CI — объявленное исключение: скрипт сборки тоя вне CI проекта, объявлён по причине smoke

workflow-команд: 1 · скриптов в приёмке: 1 · объявленных исключений: 2 · matrix-ключей: 0 · анти-плацебо-запусков: 0 · расхождений: 0
SUBJECT_RC=0
KIND=nested SUBJECT=/tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/model/verify_ci_parity.sh
  FAIL .github/workflows/ci.yml:7: команда «npm run dev» есть в CI, но нет пункта в приёмке и не объявлена исключением
  FAIL скрипт «build» есть в приёмке, но отсутствует в CI и не объявлен исключением

workflow-команд: 1 · скриптов в приёмке: 1 · объявленных исключений: 0 · matrix-ключей: 0 · анти-плацебо-запусков: 0 · расхождений: 2
SUBJECT_RC=1
KIND=nested SUBJECT=/tmp/dev-harness-verify/Critic136v2b/mutants/n05-nested-layer-harness/verify_ci_parity.sh
  ok   команда «npm run dev» (.github/workflows/ci.yml:7) приёмкой не является — объявленное исключение: команда релизного CI проекта, приёмкой пакета не является совсем
  ok   скрипт «build» не в CI — объявленное исключение: скрипт сборки тоя вне CI проекта, объявлён по причине smoke

workflow-команд: 1 · скриптов в приёмке: 1 · объявленных исключений: 2 · matrix-ключей: 0 · анти-плацебо-запусков: 0 · расхождений: 0
SUBJECT_RC=0
RC=0

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_probe_empty_next.sh --model
SUBJECT=/tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/model/connect_project.sh RC=7 ARGC=4
MSG=<$'Сессия проекта поднята без задания: прочитай .harness/HANDOFF.md и .harness/ROADMAP.md проекта, выбери предмет, доложи план.\nWORKTREE=/tmp/dev-harness-verify/Critic136v2b/runs/empty-next/fakehomeprobe-empty-next/dev-harness-projects/toy-proj/wt/wip-136-demo\nBRANCH=wip/136/demo'>
SUBJECT=/tmp/dev-harness-verify/Critic136v2b/mutants/n07-empty-next-selected/connect_project.sh RC=7 ARGC=4
MSG=<$'\nWORKTREE=/tmp/dev-harness-verify/Critic136v2b/runs/empty-next/fakehomeprobe-empty-next/dev-harness-projects/toy-proj/wt/wip-136-demo\nBRANCH=wip/136/demo'>
RC=0

$ bash /tmp/dev-harness-verify/Critic136v2b/repo/fixtures/workshop_project/sessii_136/critic_flake_diagnosis.sh --model
BASELINE_PIPELINE
PIPESTATUS=0 0
CAPTURE_RC=0
DELAYED_PIPELINE
PIPESTATUS=141 0
CAPTURE_RC=0
OUTPUT_BYTES_CMP_RC=0
DRAINING_MATCH
RULES: docs/CODING-STANDARDS.md
PIPESTATUS=0 0
RC=0
```

Полный NUL-argv smoke B1: `logs/probe-brief-extra-root.txt`, команда `bash repo/fixtures/workshop_project/sessii_136/critic_probe_brief-extra-root.sh --model` из Critic136v2b. В нём все четыре аргумента обеих дверей напечатаны `%q`; ниже дословный последний аргумент мутанта (не нормализован):

```text
ARG=<$'Сессия проекта поднята без задания: прочитай .harness/HANDOFF.md и .harness/ROADMAP.md проекта, выбери предмет, доложи план.\nWORKTREE=/tmp/dev-harness-verify/Critic136v2b/runs/brief-extra-root/fakehomeprobe-brief-extra-root/dev-harness-projects/toy-proj/wt/wip-136-demo\nBRANCH=wip/136/demo\n/tmp/dev-harness-verify/Critic136v2b/runs/brief-extra-root/fakehomeprobe-brief-extra-root/seed/toy-proj'>
```

## Сырые строки штатных прогонов и второй меры

Ниже дословные итоговые строки; полные логи с поимёнными строками 125/анти-плацебо и списком 43 красных — `logs/136-{plain,model}-{1,2,3}.txt`, `136-stabs.txt`, `125-{plain,model,honest-v2,n01,n02}.txt`, `antiplacebo.txt`. Прогоны не объединялись в один мир и не ретраились до зелёного.

```text
$ python3 /tmp/dev-harness-verify/Critic136v2b/audit.py baseline
136-plain-1: sessii_136: клеток 48, зелёных 5, красных 43
RC=1
136-model-1: sessii_136: клеток 48, зелёных 48, красных 0
RC=0
136-plain-2: sessii_136: клеток 48, зелёных 5, красных 43
RC=1
136-model-2: sessii_136: клеток 48, зелёных 48, красных 0
RC=0
136-plain-3: sessii_136: клеток 48, зелёных 5, красных 43
RC=1
136-model-3: sessii_136: клеток 48, зелёных 48, красных 0
RC=0
136-stabs: sessii_136 --stabs: стабов 30, привязок 46, непойманных 0
RC=0
s125 red: зелёных 70, красных 0
RC=0
s125 model: зелёных 70, красных 0
RC=0

$ bash scripts/pre_critic.sh contracts/136-dovodka-sessij-proektov.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
КРИТИК: дверь зелёная
RC=0

$ bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic136v2b/repo contracts/136-dovodka-sessij-proektov.md
OK
RC=0

$ bash scripts/verify_antiplacebo.sh --scope verify_ci_parity
SCOPED: барьеров 1 из выборки — не для приёмки
барьеров: 1 · фикстур: 26 · предъявлено красным повторным прогоном: 26
RC=0

$ jq '[(.kletki|length),([.stab_vhod[]|length]|add),(.stab_vhod|keys|length)]' fixtures/workshop_project/sessii_136/source.json
[
  48,
  46,
  30
]
RC=0

$ bash -c 'ls -1 fixtures/workshop_project/sessii_136/stabs | wc -l'
30
RC=0

$ python3 /tmp/dev-harness-verify/Critic136v2b/meta.py
HEAD 59ba025a9f7c5533aaed535d2daf032659234292
OWNER_LINE_EXACT 59ba025a9f7c5533aaed535d2daf032659234292 True
OWNER_LINE_EXACT 1be3128f737969f91aaff09d4e148cd7a12899e6 True
OUTSIDE_ALLOWED []
TRACKED_SUBJECTS_HEAD 
FROZEN_GUARD_FOREIGN_FIXTURES_DIFF 
REGRESSION da8f1c2f {"old_cells": 34, "old_stabs": 18, "lost_cells": [], "changed_bindings": {}, "changed_stab_bytes": []}
REGRESSION 1be3128f {"old_cells": 41, "old_stabs": 25, "lost_cells": [], "changed_bindings": {}, "changed_stab_bytes": []}
INDEPENDENT_ORDER_COUNT 48 UNIQUE 48 SET_EQUAL True
PYTHON_COUNTS 48 46 30
IMPLEMENTER_ZONE ЗОНА implementer: scripts/connect_project.sh scripts/make_task.sh scripts/verify_ci_parity.sh

$ python3 /tmp/dev-harness-verify/Critic136v2b/counts_ast.py
AST_SUBSET=run_cell case arms (shell syntax independently bash -n)
ARMS 48 PATTERNS 48 SOURCE_EQUAL True
FUNCTION_CALLS 32
RC=0

$ node .omp/extensions/path-guard.ts --extract-pin 'текст без пары'
{"worktree":null}
RC=0
```

Для воспроизведения всей атакующей части последовательно: `python3 audit.py old`, `python3 new_mutants.py`, `python3 probes.py`, `python3 flake.py`, `python3 inheritance.py`, `python3 source_mutant.py` из Critic136v2b. rc контейнерного Python-скрипта не подменяет rc субъекта: каждый дочерний результат записан отдельно. Группа 125/C сама возвращает 0 при напечатанных красных клетках; её цвет в таблице взят из `КРАСНО`, не из rc группы.
