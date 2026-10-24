FAIL
OBJECT=1be3128f737969f91aaff09d4e148cd7a12899e6

# Критик 136 v2 — один scoped-круг до заморозки

**Блокеров: 3 группы; собственных мутантов: 12, из них 5 прошли 136 зелёными.** Судится конструкция и достаточность красных тестов v2, не реализация 3cee078b. Повторного суда решений 136/1 и арбитража 5c4e3b8d нет. Текущий кандидат замораживать нельзя: перечисленные ниже обходы должны получить красные тесты. Это финальный назначенный scoped-круг; нового круга/арбитра я не запускаю, дальнейший маршрут определяет владелец по данному заданию.

Судья: Critic136v2, openai-codex/gpt-6-astra. Своя копия с отдельным `.git`: `/tmp/dev-harness-verify/Critic136v2/repo`, получена `cp -r` из предъявленного клона, без remote на чужой локальный путь. Вердикт сохранён по специально заданному пути, **не закоммичен и не запушен по прямому ограничению задания**. Основной чекаут и чужие клоны не изменялись. Реализацию/контракт/фикстуры кандидата не исправлял.

## Допуск и граница суда

Набор полный: контракт на HEAD, предмет И-1…И-8, критерий с командами/rc, именованные исполнители и ЗОНА-строки, риск и модель угроз присутствуют. Сверка `git diff --exit-code HEAD -- contracts/136-dovodka-sessij-proektov.md fixtures/workshop_project/sessii_136 fixtures/workshop_project/sessii_125` дала пустой вывод, rc 0: прочитанные предметные исходники соответствуют HEAD.

- HEAD — ровно OBJECT; единственный родитель `da8f1c2ffd446078b6676be0c2eacce533c90977`. Строка `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` сравнена целой строкой с заданием: `OWNER_LINE_EXACT=True`; она начинается в первой колонке текста коммита. Полный текст ниже в сыром `object`.
- 13 изменённых файлов — только контракт 136, модель/батарея/source/stabs 136 и `_gruppa_c.sh` 125. `contracts/125-*`, производственные `scripts/`, страж, config, registry и профиль не изменены. ЗОНА implementer осталась ровно `scripts/connect_project.sh scripts/make_task.sh scripts/verify_ci_parity.sh`.
- Пересечение architect с 125 объявлено по грамматике, ограничено c01 и установочным миром. ПРОВОДКА имеет role и guard, область роли и чистого энфорсмента названа. Precision и pre_critic исполнены, оба rc 0. Класс риска «рисковый — безопасность/авторизация записи» соответствует предмету. Понижения риска/ратификации старого FAIL нет.
- По immutable source.json: **34 старые клетки сохранены по именам и содержимому**, 18 старых стабов сохранены побайтно, все старые привязки сохранены. Новое: 41 клетка, 25 каталогов стабов, 41 привязка; независимая jq-мера `[41,41,25]`. `sessii_125/source.json` побайтно прежний; группа C содержит те же 22 клетки, вся батарея — 70.
- c01 действительно стала сильнее по проверяемому свойству отдельного корня: четыре требуемых ложных argv, а также дубль корня, теперь красны на c01. Разрешение корректного хвоста 136 — намеренное развитие формы, не снятие контроля корня. Добавка корня в MSG при сохранённом правильном корне закономерно не отвергается c01 как неправильный argv; её ловят a25/a26, что отдельно показано m12.

### Изоляция исполнения — существенная оговорка

Предъявленные раннеры жёстко пишут в общие `/tmp/dev-harness-verify/sessii-136-*`, `/tmp/dev-harness-fakehome-136/*` и `/tmp/dev-harness-verify/s125`. Чтобы выполнить ограничение «единственная запись — Critic136v2», прогоны выполнены их копиями `critic_run_red_sessii_*.sh` **с заменой только констант корней миров** на собственный scratch; TMPDIR также собственный. Оригинальные раннеры на HEAD не редактировались. Настоящий path-guard.ts и его allowlist не менялись; fakehome расположен вне `${TMPDIR}/dev-harness-verify`, контроль a7 остаётся реально красным для непиннованной записи. Попытка user-namespace isolation была недоступна (`unshare: ... Operation not permitted`), поэтому выбрана явная релокация, а не запись в чужие миры.

Подстановка собственного мутанта — только переменная DOOR/PAR в копии раннера; все клетки и оракулы сохранены. Для проверки всей 125 с честной v2-дверью и зелёными мутантами временно подставлялся субъект `scripts/connect_project.sh` **только своей копии**, затем восстанавливался. Для дискриминации 3cee078b в свою копию временно извлечены три скрипта этого коммита, затем восстановлены. Это экспериментальные деревья, не правка предъявленного объекта.

## Блокирующие находки

### B1 — NUL-оракул argv не охватывает другой штатный источник задания

БЛОКИРУЕТ contracts/136-dovodka-sessij-proektov.md:48 — форма И-4 обязательна и при `--task-file`, но критерий на строках 57/59/62 пропускает потерю корня именно на этом пути входа. Новые a25/a26 проверяют NEXT_TASK, а a22 с task-file продолжает проверять построчно извлечённый MSG и пин, не полный argv. Наличие NUL-наблюдателя само по себе не делает все входы наблюдаемыми.
ОБХОД: собственный `m06-taskfile-noroot` оставляет всю честную модель, но перед штатным exec добавляет `if [ -n "$TASKFILE_ARG" ]; then exec "$WORKSHOP_BIN" --yolo -- "$MSG"; fi`. Он проходит 136 **41/41 rc 0**, 125/C **22/22** и всю 125 **70/70 rc 0**, но независимый запуск `--task-file` даёт `RC=7 ARGC=3`, argv `[--yolo, --, MSG]`, тогда как честная модель даёт `RC=7 ARGC=4`, argv `[--yolo, KOREN, --, MSG]`. Корень не передан до разделителя, PROJECT лаунчера не выбран. В MSG пробы есть собственные строки `--` и `ARGC=4`; они не становятся отдельными argv и не исправляют потерю корня.

Закрытие критерия: красный тест на границы argv через `--task-file` и проверка, что обманная реализация m06 краснеет; источник задания не должен менять форму запуска. Обход не зависит от конкретных имён проекта, путей, текста или тестовых slug.

### B2 — наличие файла стража проверено, обязательность настоящего финального суда и отсутствие node — нет

БЛОКИРУЕТ contracts/136-dovodka-sessij-proektov.md:50 — И-6 запрещает собственный финальный оракул и требует `strazh-net` без node до exec, но новая a27 предъявляет только отсутствие файла. Критерий строк 57/59 не отличает настоящий финальный extract-pin от собственного сканера при существующем файле и не предъявляет отсутствие интерпретатора.
ОБХОД: `m07-no-final-oracle` сохраняет `command -v node`, проверку `-f guard` и локальный сканер, но удаляет вызов `node ... --extract-pin "$MSG"` и сравнение результата. Получено 136 **41/41 rc 0**, вся 125 **70/70 rc 0**. На отдельном тексте `note\rWORKTREE=/fake/wip-777-other\rBRANCH=wip/777/other\n` честная модель даёт `PIN_CHUZHOJ`, rc 1, `EXEC=no`; мутант даёт rc 7, `EXEC=yes`, а настоящий guard на полном переданном MSG — `{"worktree":null}`. Второй независимый вариант той же непроверенной границы, `m08-node-fallback`, заменяет отказ отсутствующего node на exec с корректными argv: он также даёт 136 **41/41** и 125 **70/70**, а в настоящем PATH без node запускает двойник (rc 7), тогда как модель отказывает `strazh-net`, rc 1, до exec.

Закрытие критерия: отдельные красные входы на недоступный node и на необходимость именно финального настоящего оракула, а не только существования его файла. Это проверка нового fail-closed обещания v2, не пересмотр приоритета/кратности PIN_CHUZHOJ/PIN_DUBL из арбитража.

### B3 — режим паритета доказан для единственного буквального имени слоя, а не объявленного свойства

БЛОКИРУЕТ contracts/136-dovodka-sessij-proektov.md:52 — предикат И-8 задан по свойству «profilePath под .harness/», однако d1/d3/d5 используют единственное имя `.harness/project-layer.json`, а d4 проверяет лишь `registry/...`. Критерий строки 57 допускает хардкод имени вместо свойства и не испытывает объявленный отказ без jq.
ОБХОД: `m09-exact-layer-only` заменяет `.harness/*)` в выборе режима на `.harness/project-layer.json)`. Все **41/41** клетки зелёные, rc 0. В независимом мире объявлен и существует `.harness/alternate.json`, профильные исключения пусты, а корневые достаточны: честная модель даёт rc 1, `объявленных исключений: 0`, `расхождений: 2`; мутант даёт rc 0, `объявленных исключений: 2`, `расхождений: 0`. Проектный профиль получает режим 020 и корневые исключения вопреки И-8. Дополнительно `m10-parity-jq-fallback` возвращает 0 при отсутствии jq и проходит те же **41/41**; в отдельном PATH без jq честная модель возвращает 2 с именованной причиной, мутант — 0.

Закрытие критерия: красный тест с другим корректным объявленным путём **под** `.harness/` (и его потерей, не потерей зашитого имени), плюс отсутствие jq при существующем профиле. Это не новая грамматика пути и не расширение implementer-зоны.

## Советы и пределы атак

СОВЕТ contracts/136-dovodka-sessij-proektov.md:50 — явно назвать доверие к установке/node: пустой и синтаксически битый guard на честной модели реально отказали до exec (rc 1, диагноз `PIN_CHUZHOJ`, а не `strazh-net`); корректный guard без x-бита продолжает работать через node (rc 7 — это не «нечем исполнить»). Подложный guard либо подложный node, печатающий правильный JSON worktree, допускают запуск rc 7. Это подмена доверенной установки/PATH, а не доказанный обход чужим текстом задания; не требую вне согласованного объёма новый криптографический механизм аутентичности. B2 основан не на такой подмене, а на пропущенном настоящем оракуле/отсутствующем node.

СОВЕТ contracts/136-dovodka-sessij-proektov.md:48 — для «БАЙТ В БАЙТ» стоит определить NUL-алфавит входного файла. Собственная проба с NUL в task-file: rc 7, ровно четыре argv, корень корректен; NUL удалён bash command substitution с предупреждением. Поэтому NUL не позволил обмануть границы argv, но байт файла не доставлен. Не навязываю способ поддержки невозможного NUL внутри execve argv; это отдельное явное решение «отказ либо допустимый текстовый алфавит», а не оправдание B1.

СОВЕТ contracts/136-dovodka-sessij-proektov.md:52 — при последующих атаках не путать слои паритета и sourceCanon. Исполненный настоящий `profile_resolver.sh` отверг NUL/`..`/абсолютный sourceCanon.sources[].path в репо-слое **и** в затенённом `defaults.sourceCanon` слоя проекта при валидном верхнем sourceCanon: каждый раз rc 1 `SOURCE_CANON_INVALID` с именем слоя. Поэтому ветви после успешного резолвера на этих значениях недостижимы через его публичный вход. Это не доказательство недостижимости для прямого `verify_ci_parity.sh`: он читает профиль сам и не вызывает scan_canon; прямой smoke шёл до суда CI (rc 1 о непокрытых командах, не SOURCE_CANON_INVALID). Шов для мутаций здесь — штатный DOOR/PAR выбор субъекта в одноразовом раннере; резолвер и его защиту не ослаблял, не подменял. sourceCanon в самом контракте 136 не объявлен; новых обязательств карты источников ему не приписываю.

## Пять обязательных вопросов

1. **Критерий слабее предмета?** Да: B1/B2/B3 — конкретные зелёные обманные реализации, каждый обход исполнен на отдельном штатном входе.
2. **Команды доказывают заявленное?** Команды/rc названы и базовые числа воспроизведены, но область их отрицательных входов неполна — именно найденные обходы, не пожелание «больше тестов». Ручная граница «diff = модели» не заменяет поведенческий красный тест, требуемый шагом 1 AGENTS.md.
3. **Молчаливые решения исполнителю?** Форма argv, fail-closed и предикат режима теперь заданы явно. Основные проблемы — отсутствие их различения тестами, а не отсутствие текста. NUL/доверие установке оставлены советами выше.
4. **Границы исполнения?** Зоны и пересечения названы, новая дельта в них; implementer-зона не расширена. Конкретного выхода за зоны для реализации v2 не найдено.
5. **Противоречие AGENTS.md?** Недостаточность красных тестов подтверждена B1–B3; неполного набора, снижения класса риска, отсутствия модели угроз, незаконной frozen-правки или обхода precision-гейта не найдено. Прочая проза вне трёх контрактных вопросов не использована как самостоятельный блокер.

## Таблица собственных мутантов

Цвет означает **цвет приёмки мутанта**, не цвет smoke: зелёный мутант — пропущенный обман. rc 2 в подстановочном `--model` означает «модель не зелёная» после перечисления красных клеток; это положительное доказательство поимки, а не сломанный мир.

| Мутант | Дельта | 136 | 125 | Итог |
|---|---|---|---|---|
| m01-noroot | корень убран для всех запусков | красный: a25,a26; 39/2 | C: 21/1, c01 | пойман |
| m02-root-in-msg | корень только последней строкой MSG | красный: a25,a26; 39/2 | C: 21/1, c01 | пойман |
| m03-root-after-separator | корень отдельным argv после `--` | красный: a25,a26; 39/2 | C: 21/1, c01 | пойман |
| m04-foreign-root | вместо KOREN передан HOME | красный: a25,a26; 39/2 | C: 21/1, c01 | пойман |
| m05-duplicate-root | KOREN передан дважды до `--` | красный: a25,a26; 39/2 | C: 21/1, c01 | пойман |
| m06-taskfile-noroot | корень убран только при task-file | **зелёный 41/41** | C 22/22; вся 70/70 | B1 |
| m07-no-final-oracle | только локальный сканер, нет финального extract-pin | **зелёный 41/41** | вся 70/70 | B2 |
| m08-node-fallback | отсутствующий node ведёт к exec | **зелёный 41/41** | вся 70/70 | B2 |
| m09-exact-layer-only | проектный режим только для одного имени слоя | **зелёный 41/41** | не запускалась: субъект паритета | B3 |
| m10-parity-jq-fallback | нет jq → rc 0 | **зелёный 41/41** | не запускалась: субъект паритета | B3 |
| m11-allow-duplicate | снят отдельный отказ PIN_DUBL | красный: a10,a19,a21; 38/3 | не запускалась | поимка приоритета пина сохранена |
| m12-append-root-to-msg | правильный корень в argv + дописанный в MSG | красный: a25,a26; 39/2 | C 22/22 | пойман совокупной приёмкой |

## Сводка собственных замеров

| Команда/сценарий (релокация миров раскрыта выше) | Результат |
|---|---|
| 136 plain, без реализации | 41 клетка, 5 зелёных / 36 красных, rc 1 |
| 136 --model | 41/41, rc 0 |
| 136 --stabs | 25 стабов / 41 привязка / 0 непойманных, rc 0 |
| 125 plain | 70/70, rc 0 |
| 125 --model | 70/70, rc 0 |
| вся 125 с честной v2-дверью | 70/70, rc 0 |
| 136 с тремя скриптами 3cee078b | 36 зелёных / 5 красных, rc 1; ровно a25 a26 a27 b3 d5 |
| pre_critic 136 | rc 0, дверь зелёная |
| check_precision_gate на своём клоне и контракте | rc 0, OK |
| verify_antiplacebo --scope verify_ci_parity | 1 барьер / 26 фикстур / 26 предъявлено красным, rc 0 |
| guard --extract-pin «текст без пары» | `{"worktree":null}`, rc 0 |
| независимые счётчики | 41 клетки / 41 привязка / 25 ключей = 25 каталогов; старые 34/18 сохранены |

11 отдельных батарей лаунчера, полный project-wide CI и живую omp-сессию не запускал; их файлы/субъекты не входят в дельту кандидата. Отсутствие правок не выдаётся за исполненный прогон. Наследуемая 125, напротив, исполнена полностью на обоих её режимах и на настоящей v2-модели двери. Ни одного нового permanent-теста/правки предмета этот суд не содержит.

## Сырые команды и вывод (собственные прогоны)

Команды генераторов: `python3 /tmp/dev-harness-verify/Critic136v2/audit.py baseline`; `python3 /tmp/dev-harness-verify/Critic136v2/audit.py mutants`; `python3 /tmp/dev-harness-verify/Critic136v2/probes.py`; `python3 /tmp/dev-harness-verify/Critic136v2/extra.py`. Ниже не пересказ — сохранённый объединённый stdout/stderr каждого запуска и его rc. В строках `SUBJECT_RC` / `RESOLVER_RC` указан код исследуемого субъекта; rc самого smoke-скрипта — не его вердикт. Группа C печатает красные клетки при rc=0, поэтому её цвет определяется строками `КРАСНО`, а не кодом группы.

### object

```text
$ git show -s --format=%H%n%P%n%B HEAD
1be3128f737969f91aaff09d4e148cd7a12899e6
da8f1c2ffd446078b6676be0c2eacce533c90977
РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/136-dovodka-sessij-proektov.md — в рамках предмета 136 выпустить v2: сохранить корень отдельным аргументом до -- и MSG после --, уточнить правило 7 и пересечение architect с батареей 125 для усиления c01 и согласования установочного мира с настоящими guard/config, сохранить fail-closed выдачи пина и трассы, уточнить различение проектного режима и режима харнесса; без принятия текущего FAIL и без нового предмета.

architect 136 v2 (B1/B2 Rev136, consult136 §3.1): контракт v2 (КЛАСС РИСКА: рисковый;
границы argv И-4, strazh-net/trassa-net-konfiga fail-closed, предикат проектного
режима паритета по объявленному слою профиля); батарея 41 клетка / 25 стабов /
41 привязка (новые a25 a26 a27 b3 b4 d4 d5, стабы s19–s25); пересечение с 125:
c01 — NUL-оракул границ argv, мир группы C несёт настоящие path-guard.ts и
config/agent_models.json. Замеры: plain 41/5/36 (новые красны a25 a26 a27 b3
b4 d5), --model 41/41 rc 0, --stabs 25/41/0 rc 0; 125 на main-двери 70/70 и
--model 70/70; v2-модель в группе C 22/22; мутанты noroot/koren-v-msg/
koren-posle/chuzoj-koren красны ровно на c01 (21/1 каждый); pre_critic rc 0.


RC=0
```

### scope

```text
CHANGED_FILES=13
SCOPE_OUTSIDE_ALLOWED=[]
contracts/136-dovodka-sessij-proektov.md
fixtures/workshop_project/sessii_125/_gruppa_c.sh
fixtures/workshop_project/sessii_136/model/connect_project.sh
fixtures/workshop_project/sessii_136/model/verify_ci_parity.sh
fixtures/workshop_project/sessii_136/red_sessii_136.sh
fixtures/workshop_project/sessii_136/source.json
fixtures/workshop_project/sessii_136/stabs/s19-dver-strazh-svoj-orakul/connect_project.sh
fixtures/workshop_project/sessii_136/stabs/s20-dver-trassa-molcha/connect_project.sh
fixtures/workshop_project/sessii_136/stabs/s21-dver-trassa-bit-molcha/connect_project.sh
fixtures/workshop_project/sessii_136/stabs/s22-dver-koren-v-hvoste/connect_project.sh
fixtures/workshop_project/sessii_136/stabs/s23-parity-sloi-molcha/verify_ci_parity.sh
fixtures/workshop_project/sessii_136/stabs/s24-parity-proekt-po-faktu/verify_ci_parity.sh
fixtures/workshop_project/sessii_136/stabs/s25-dver-put-v-zadachenii/connect_project.sh
```

### counts

```text
{
  "old_cells": 34,
  "new_cells": 41,
  "lost_cells": [],
  "old_stabs": 18,
  "new_stabs": 25,
  "changed_old_bindings": {},
  "stab_directories": 25
}
```

### jq-counts

```text
$ jq '[ (.kletki|length), ([.stab_vhod[]|length]|add), (.stab_vhod|keys|length)]' /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/source.json
[
  41,
  41,
  25
]

RC=0
```

### 136-plain

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_run_red_sessii_136.sh
sessii_136: клеток 41, зелёных 5, красных 36
красные: a1-p6-hvost a2-p6-brief-defolt a3-p3-pin-v-soobshchenii a4-p3-zapis a5-p12-agent a6-p11-subagent-pin a8-pin-block a9-pin-inline a10-pin-duplicate a11-pin-mixed a12-pin-reverse a13-pin-foreign-wt a14-pin-foreign-br a15-pin-extra-wt a16-pin-extra-br a17-pin-half-wt a18-pin-empty-br a19-pin-inline-mixed a20-pin-delimiters a21-pin-taskfile-duplicate a22-pin-taskfile-inline a23-pin-live-foreign a24-pin-inline-foreign a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem a27-strazh-net b1-povtor b2-p10-raskladka b3-trassa-net-konfiga b4-trassa-konfig-bit c1-p17-map c2-p17-rules c3-p5-trassa-defolt d1-p10-isklyuchenie d3-kontrol-koren d5-sloi-poterjan

RC=1
```

### 136-model

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_run_red_sessii_136.sh --model
sessii_136: клеток 41, зелёных 41, красных 0

RC=0
```

### 136-stabs

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_run_red_sessii_136.sh --stabs
sessii_136 --stabs: стабов 25, привязок 41, непойманных 0

RC=0
```

### 125-plain

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_125/critic_run_red_sessii_125.sh
ЗЕЛЕНО a01-chestnaya
ЗЕЛЕНО a02-dom-obshij
ЗЕЛЕНО a03-drejf-config-yml
ЗЕЛЕНО a03-drejf-models-db
ЗЕЛЕНО a03-drejf-skill-descriptions-db
ЗЕЛЕНО a04-ssylka-config-yml
ЗЕЛЕНО a04-ssylka-models-db
ЗЕЛЕНО a04-zhestkaya-config-yml
ЗЕЛЕНО a05-net-config-yml
ЗЕЛЕНО a06-agentdb-kopiya
ЗЕЛЕНО a07-sessii-kopiya
ЗЕЛЕНО a07-history-ssylka
ЗЕЛЕНО a07-blobs-kopiya
ЗЕЛЕНО a07-history-pereimenovana
ЗЕЛЕНО a07-sessiya-pereimenovana
ЗЕЛЕНО a07-vne-profilya
ЗЕЛЕНО a07-ssylka-pereimenovana
ЗЕЛЕНО a19-dost-fajl-dev
ЗЕЛЕНО a20-dost-podkatalog
ЗЕЛЕНО a21-dost-katalog-agenta
ЗЕЛЕНО a21-dost-roditel
ЗЕЛЕНО a22-dost-cepochka
ЗЕЛЕНО a23-dost-otnositelnaya
ЗЕЛЕНО a26-dost-cherez-katalog
ЗЕЛЕНО a24-dost-hardlink
ЗЕЛЕНО a25-dost-hardlink-pustoj
ЗЕЛЕНО a08-profil
ЗЕЛЕНО a09-podtverzhdeniya
ЗЕЛЕНО a10-model
ЗЕЛЕНО a11-instrumenty
ЗЕЛЕНО a12-politika
ЗЕЛЕНО a13-rasshireniya
ЗЕЛЕНО a14-pravila
ЗЕЛЕНО a15-agenty
ЗЕЛЕНО a16-tri-prichiny
ЗЕЛЕНО a17-nechem-pustye-fakty
ЗЕЛЕНО a18-nechem-osnovnaya-bez-config
ЗЕЛЕНО b01-dom-otdelnyj
ЗЕЛЕНО b02-sev-pobajtno
ЗЕЛЕНО b05-ne-sessii
ЗЕЛЕНО b06-ne-sekrety
ЗЕЛЕНО b07-agentdb-w8
ЗЕЛЕНО b08-sverka-chestnaya
ЗЕЛЕНО b09-podtv-bez-yolo
ЗЕЛЕНО b03-drejf
ЗЕЛЕНО b04-zapis-ne-v-dev
ЗЕЛЕНО b10-podtv-yolo
ЗЕЛЕНО b11-harness-raskladka
ЗЕЛЕНО c01-zapusk-odin
ЗЕЛЕНО c02-yolo
ЗЕЛЕНО c03-projectid
ЗЕЛЕНО c04-klon-https-gh
ЗЕЛЕНО c05-pin
ЗЕЛЕНО c06-deny
ЗЕЛЕНО c07-karkas
ЗЕЛЕНО c08-tolko-harness
ЗЕЛЕНО c09-env-klyuchi
ЗЕЛЕНО c10-sekrety-vyvod
ЗЕЛЕНО c11-sekrety-repo
ЗЕЛЕНО c12-povtor
ЗЕЛЕНО c13-sverhu
ЗЕЛЕНО c14-imya-vne-klassa
ЗЕЛЕНО c15-mob-bez-pravok
ЗЕЛЕНО c16-mob-ci
ЗЕЛЕНО c17-env-v-indekse
ЗЕЛЕНО c18-zhizn-povtor
ЗЕЛЕНО c19-zhizn-add-f
ЗЕЛЕНО c20-zhizn-add-a
ЗЕЛЕНО c21-zhizn-vetka
ЗЕЛЕНО c22-zhizn-imya
s125 red: зелёных 70, красных 0

RC=0
```

### 125-model

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_125/critic_run_red_sessii_125.sh --model
ЗЕЛЕНО a01-chestnaya
ЗЕЛЕНО a02-dom-obshij
ЗЕЛЕНО a03-drejf-config-yml
ЗЕЛЕНО a03-drejf-models-db
ЗЕЛЕНО a03-drejf-skill-descriptions-db
ЗЕЛЕНО a04-ssylka-config-yml
ЗЕЛЕНО a04-ssylka-models-db
ЗЕЛЕНО a04-zhestkaya-config-yml
ЗЕЛЕНО a05-net-config-yml
ЗЕЛЕНО a06-agentdb-kopiya
ЗЕЛЕНО a07-sessii-kopiya
ЗЕЛЕНО a07-history-ssylka
ЗЕЛЕНО a07-blobs-kopiya
ЗЕЛЕНО a07-history-pereimenovana
ЗЕЛЕНО a07-sessiya-pereimenovana
ЗЕЛЕНО a07-vne-profilya
ЗЕЛЕНО a07-ssylka-pereimenovana
ЗЕЛЕНО a19-dost-fajl-dev
ЗЕЛЕНО a20-dost-podkatalog
ЗЕЛЕНО a21-dost-katalog-agenta
ЗЕЛЕНО a21-dost-roditel
ЗЕЛЕНО a22-dost-cepochka
ЗЕЛЕНО a23-dost-otnositelnaya
ЗЕЛЕНО a26-dost-cherez-katalog
ЗЕЛЕНО a24-dost-hardlink
ЗЕЛЕНО a25-dost-hardlink-pustoj
ЗЕЛЕНО a08-profil
ЗЕЛЕНО a09-podtverzhdeniya
ЗЕЛЕНО a10-model
ЗЕЛЕНО a11-instrumenty
ЗЕЛЕНО a12-politika
ЗЕЛЕНО a13-rasshireniya
ЗЕЛЕНО a14-pravila
ЗЕЛЕНО a15-agenty
ЗЕЛЕНО a16-tri-prichiny
ЗЕЛЕНО a17-nechem-pustye-fakty
ЗЕЛЕНО a18-nechem-osnovnaya-bez-config
ЗЕЛЕНО b01-dom-otdelnyj
ЗЕЛЕНО b02-sev-pobajtno
ЗЕЛЕНО b05-ne-sessii
ЗЕЛЕНО b06-ne-sekrety
ЗЕЛЕНО b07-agentdb-w8
ЗЕЛЕНО b08-sverka-chestnaya
ЗЕЛЕНО b09-podtv-bez-yolo
ЗЕЛЕНО b03-drejf
ЗЕЛЕНО b04-zapis-ne-v-dev
ЗЕЛЕНО b10-podtv-yolo
ЗЕЛЕНО b11-harness-raskladka
ЗЕЛЕНО c01-zapusk-odin
ЗЕЛЕНО c02-yolo
ЗЕЛЕНО c03-projectid
ЗЕЛЕНО c04-klon-https-gh
ЗЕЛЕНО c05-pin
ЗЕЛЕНО c06-deny
ЗЕЛЕНО c07-karkas
ЗЕЛЕНО c08-tolko-harness
ЗЕЛЕНО c09-env-klyuchi
ЗЕЛЕНО c10-sekrety-vyvod
ЗЕЛЕНО c11-sekrety-repo
ЗЕЛЕНО c12-povtor
ЗЕЛЕНО c13-sverhu
ЗЕЛЕНО c14-imya-vne-klassa
ЗЕЛЕНО c15-mob-bez-pravok
ЗЕЛЕНО c16-mob-ci
ЗЕЛЕНО c17-env-v-indekse
ЗЕЛЕНО c18-zhizn-povtor
ЗЕЛЕНО c19-zhizn-add-f
ЗЕЛЕНО c20-zhizn-add-a
ЗЕЛЕНО c21-zhizn-vetka
ЗЕЛЕНО c22-zhizn-imya
s125 model: зелёных 70, красных 0

RC=0
```

### 125-honest-v2-all

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_125/critic_run_red_sessii_125.sh
ЗЕЛЕНО a01-chestnaya
ЗЕЛЕНО a02-dom-obshij
ЗЕЛЕНО a03-drejf-config-yml
ЗЕЛЕНО a03-drejf-models-db
ЗЕЛЕНО a03-drejf-skill-descriptions-db
ЗЕЛЕНО a04-ssylka-config-yml
ЗЕЛЕНО a04-ssylka-models-db
ЗЕЛЕНО a04-zhestkaya-config-yml
ЗЕЛЕНО a05-net-config-yml
ЗЕЛЕНО a06-agentdb-kopiya
ЗЕЛЕНО a07-sessii-kopiya
ЗЕЛЕНО a07-history-ssylka
ЗЕЛЕНО a07-blobs-kopiya
ЗЕЛЕНО a07-history-pereimenovana
ЗЕЛЕНО a07-sessiya-pereimenovana
ЗЕЛЕНО a07-vne-profilya
ЗЕЛЕНО a07-ssylka-pereimenovana
ЗЕЛЕНО a19-dost-fajl-dev
ЗЕЛЕНО a20-dost-podkatalog
ЗЕЛЕНО a21-dost-katalog-agenta
ЗЕЛЕНО a21-dost-roditel
ЗЕЛЕНО a22-dost-cepochka
ЗЕЛЕНО a23-dost-otnositelnaya
ЗЕЛЕНО a26-dost-cherez-katalog
ЗЕЛЕНО a24-dost-hardlink
ЗЕЛЕНО a25-dost-hardlink-pustoj
ЗЕЛЕНО a08-profil
ЗЕЛЕНО a09-podtverzhdeniya
ЗЕЛЕНО a10-model
ЗЕЛЕНО a11-instrumenty
ЗЕЛЕНО a12-politika
ЗЕЛЕНО a13-rasshireniya
ЗЕЛЕНО a14-pravila
ЗЕЛЕНО a15-agenty
ЗЕЛЕНО a16-tri-prichiny
ЗЕЛЕНО a17-nechem-pustye-fakty
ЗЕЛЕНО a18-nechem-osnovnaya-bez-config
ЗЕЛЕНО b01-dom-otdelnyj
ЗЕЛЕНО b02-sev-pobajtno
ЗЕЛЕНО b05-ne-sessii
ЗЕЛЕНО b06-ne-sekrety
ЗЕЛЕНО b07-agentdb-w8
ЗЕЛЕНО b08-sverka-chestnaya
ЗЕЛЕНО b09-podtv-bez-yolo
ЗЕЛЕНО b03-drejf
ЗЕЛЕНО b04-zapis-ne-v-dev
ЗЕЛЕНО b10-podtv-yolo
ЗЕЛЕНО b11-harness-raskladka
ЗЕЛЕНО c01-zapusk-odin
ЗЕЛЕНО c02-yolo
ЗЕЛЕНО c03-projectid
ЗЕЛЕНО c04-klon-https-gh
ЗЕЛЕНО c05-pin
ЗЕЛЕНО c06-deny
ЗЕЛЕНО c07-karkas
ЗЕЛЕНО c08-tolko-harness
ЗЕЛЕНО c09-env-klyuchi
ЗЕЛЕНО c10-sekrety-vyvod
ЗЕЛЕНО c11-sekrety-repo
ЗЕЛЕНО c12-povtor
ЗЕЛЕНО c13-sverhu
ЗЕЛЕНО c14-imya-vne-klassa
ЗЕЛЕНО c15-mob-bez-pravok
ЗЕЛЕНО c16-mob-ci
ЗЕЛЕНО c17-env-v-indekse
ЗЕЛЕНО c18-zhizn-povtor
ЗЕЛЕНО c19-zhizn-add-f
ЗЕЛЕНО c20-zhizn-add-a
ЗЕЛЕНО c21-zhizn-vetka
ЗЕЛЕНО c22-zhizn-imya
s125 red: зелёных 70, красных 0

RC=0
```

### 136-old-impl

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_run_red_sessii_136.sh
sessii_136: клеток 41, зелёных 36, красных 5
красные: a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem a27-strazh-net b3-trassa-net-konfiga d5-sloi-poterjan

RC=1
```

### pre-critic

```text
$ bash scripts/pre_critic.sh contracts/136-dovodka-sessij-proektov.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
КРИТИК: дверь зелёная

RC=0
```

### precision

```text
$ bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic136v2/repo contracts/136-dovodka-sessij-proektov.md
OK

RC=0
```

### antiplacebo

```text
$ bash scripts/verify_antiplacebo.sh --scope verify_ci_parity
SCOPED: барьеров 1 из выборки — не для приёмки
  ok   verify_ci_parity/case_cepochka_komand.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «команда «npm run check:sneaky» есть в CI, но нет пункта в приёмке»
  ok   verify_ci_parity/case_composite_action.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «команда «npm run check:missing» есть в CI, но нет пункта в приёмке»
  ok   verify_ci_parity/case_env_run_ne_schitaetsja.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «скрипт «check:only-env» есть в приёмке, но отсутствует в CI и не объявлен исключением»
  ok   verify_ci_parity/case_heredoc_vne_podmnozhestva.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «шаг вне разбираемого подмножества: heredoc»
  ok   verify_ci_parity/case_iskljuchenie_bez_prichiny.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «строка исключения без «=»: check:overlay»
  ok   verify_ci_parity/case_iskljuchenie_mertvoe.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «исключение «check:ghost» названо для скрипта, которого нет в приёмке — мёртвая запись»
  ok   verify_ci_parity/case_iskljuchenie_nedostizhimo.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «исключение «check:existing» недостижимо: скрипт запускается в CI — запись ничего не разрешает»
  ok   verify_ci_parity/case_komanda_ne_priemka.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «команда «set -e» есть в CI, но нет пункта в приёмке и не объявлена исключением»
  ok   verify_ci_parity/case_komanda_vne_priemki.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «команда «npm run check:foo» есть в CI, но нет пункта в приёмке»
  ok   verify_ci_parity/case_local_action_vne_github.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «команда «npm run check:missing» есть в CI, но нет пункта в приёмке»
  ok   verify_ci_parity/case_mnogostrochnyi_run.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «команда «npm run check:sneaky» есть в CI, но нет пункта в приёмке»
  ok   verify_ci_parity/case_opaque_vlozhennye_zapuski.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «шаг вне разбираемого подмножества: подстановка команды $(...)»
  ok   verify_ci_parity/case_priemka_vne_ci.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «скрипт «check:orphan» есть в приёмке, но отсутствует в CI и не объявлен исключением»
  ok   verify_ci_parity/case_psevdoprichina.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «псевдопричина у исключения «check:phantom»: «.» — причина обязана называть, что мешает исполнять пункт в CI»
  ok   verify_ci_parity/case_shard_bez_matrixy.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «шардный запуск анти-плацебо не объявлен: fixtures/check_aaa есть, а matrix-джобы в .github/** нет»
  ok   verify_ci_parity/case_shard_indirekcija_nerazreshima.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «шаг несёт нерасширенную индирекцию рядом с npm run (переменная MYSTERY_SCRIPT)»
  ok   verify_ci_parity/case_shard_komanda_vne_priemki.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «есть в CI, но нет пункта в приёмке и не объявлена исключением»
  ok   verify_ci_parity/case_shard_legacy_shag_peremennoe_imja.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «запуск анти-плацебо вне шардной matrix (не несёт --scope с ключами): npm run "$ANTI_SCRIPT" -- --changed ${{ github.event.before }}»
  ok   verify_ci_parity/case_shard_legacy_shag_peremennyj_binarnik.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «запуск анти-плацебо вне шардной matrix (не несёт --scope с ключами): "$NPM_BIN" run check:antiplacebo -- --changed ${{ github.event.before }}»
  ok   verify_ci_parity/case_shard_legacy_shag_psevdonim.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «запуск анти-плацебо вне шардной matrix (не несёт --scope с ключами): npm run-script check:antiplacebo -- --changed ${{ github.event.before }}»
  ok   verify_ci_parity/case_shard_legacy_shag.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «запуск анти-плацебо вне шардной matrix (не несёт --scope с ключами): npm run check:antiplacebo -- --changed ${{ github.event.before }}»
  ok   verify_ci_parity/case_shard_mertvyj_kljuch.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «check_zzz назван шардом ap2, но каталога fixtures/check_zzz нет — мёртвый ключ»
  ok   verify_ci_parity/case_shard_scope_sloman.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «не несёт --scope с ключами»
  ok   verify_ci_parity/case_shard_vypavshaja.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «check_ccc не покрыт шардингом — ключ не назван ни одним шардом»
  ok   verify_ci_parity/case_shard_zadublirovannaja.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «check_aaa приписан двум шардам: ap1, ap2»
  ok   verify_ci_parity/case_workflow_v_podkataloge.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «команда «npm run check:missing» есть в CI, но нет пункта в приёмке»

барьеров: 1 · фикстур: 26 · предъявлено красным повторным прогоном: 26

RC=0
```

### m01-noroot-125C

```text
$ bash fixtures/workshop_project/sessii_125/_gruppa_c.sh
КРАСНО c01-zapusk-odin:  границы argv workshop ≠ [--yolo, /tmp/dev-harness-verify/Critic136v2/tmp/red125c.buJxyr/m1/home/projects/Toy-Repo-405e] | [--yolo, /tmp/dev-harness-verify/Critic136v2/tmp/red125c.buJxyr/m1/home/projects/Toy-Repo-405e, --, непустой MSG]: --yolo|--|Сессия проекта поднята без задания: прочитай .harness/HANDOFF.md и .harness/ROADMAP.md проекта, выбери предмет, доложи план.|WORKTREE=/tmp/dev-harness-verify/Critic136v2/tmp/red125c.buJxyr/m1/home/dev-harness-projects/toy-repo-405e/wt/wip-136-demo|BRANCH=wip/136/demo|;
ЗЕЛЕНО c02-yolo
ЗЕЛЕНО c03-projectid
ЗЕЛЕНО c04-klon-https-gh
ЗЕЛЕНО c05-pin
ЗЕЛЕНО c06-deny
ЗЕЛЕНО c07-karkas
ЗЕЛЕНО c08-tolko-harness
ЗЕЛЕНО c09-env-klyuchi
ЗЕЛЕНО c10-sekrety-vyvod
ЗЕЛЕНО c11-sekrety-repo
ЗЕЛЕНО c12-povtor
ЗЕЛЕНО c13-sverhu
ЗЕЛЕНО c14-imya-vne-klassa
ЗЕЛЕНО c15-mob-bez-pravok
ЗЕЛЕНО c16-mob-ci
ЗЕЛЕНО c17-env-v-indekse
ЗЕЛЕНО c18-zhizn-povtor
ЗЕЛЕНО c19-zhizn-add-f
ЗЕЛЕНО c20-zhizn-add-a
ЗЕЛЕНО c21-zhizn-vetka
ЗЕЛЕНО c22-zhizn-imya

RC=0
```

### m01-noroot-136

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_run_red_sessii_136.sh --model
sessii_136: клеток 41, зелёных 39, красных 2
красные: a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem
модель не зелёная

RC=2
```

### m02-root-in-msg-125C

```text
$ bash fixtures/workshop_project/sessii_125/_gruppa_c.sh
КРАСНО c01-zapusk-odin:  границы argv workshop ≠ [--yolo, /tmp/dev-harness-verify/Critic136v2/tmp/red125c.R8jmzd/m1/home/projects/Toy-Repo-4f79] | [--yolo, /tmp/dev-harness-verify/Critic136v2/tmp/red125c.R8jmzd/m1/home/projects/Toy-Repo-4f79, --, непустой MSG]: --yolo|--|Сессия проекта поднята без задания: прочитай .harness/HANDOFF.md и .harness/ROADMAP.md проекта, выбери предмет, доложи план.|WORKTREE=/tmp/dev-harness-verify/Critic136v2/tmp/red125c.R8jmzd/m1/home/dev-harness-projects/toy-repo-4f79/wt/wip-136-demo|BRANCH=wip/136/demo|/tmp/dev-harness-verify/Critic136v2/tmp/red125c.R8jmzd/m1/home/projects/Toy-Repo-4f79|;
ЗЕЛЕНО c02-yolo
ЗЕЛЕНО c03-projectid
ЗЕЛЕНО c04-klon-https-gh
ЗЕЛЕНО c05-pin
ЗЕЛЕНО c06-deny
ЗЕЛЕНО c07-karkas
ЗЕЛЕНО c08-tolko-harness
ЗЕЛЕНО c09-env-klyuchi
ЗЕЛЕНО c10-sekrety-vyvod
ЗЕЛЕНО c11-sekrety-repo
ЗЕЛЕНО c12-povtor
ЗЕЛЕНО c13-sverhu
ЗЕЛЕНО c14-imya-vne-klassa
ЗЕЛЕНО c15-mob-bez-pravok
ЗЕЛЕНО c16-mob-ci
ЗЕЛЕНО c17-env-v-indekse
ЗЕЛЕНО c18-zhizn-povtor
ЗЕЛЕНО c19-zhizn-add-f
ЗЕЛЕНО c20-zhizn-add-a
ЗЕЛЕНО c21-zhizn-vetka
ЗЕЛЕНО c22-zhizn-imya

RC=0
```

### m02-root-in-msg-136

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_run_red_sessii_136.sh --model
sessii_136: клеток 41, зелёных 39, красных 2
красные: a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem
модель не зелёная

RC=2
```

### m03-root-after-separator-125C

```text
$ bash fixtures/workshop_project/sessii_125/_gruppa_c.sh
КРАСНО c01-zapusk-odin:  границы argv workshop ≠ [--yolo, /tmp/dev-harness-verify/Critic136v2/tmp/red125c.fv7xvM/m1/home/projects/Toy-Repo-29fd] | [--yolo, /tmp/dev-harness-verify/Critic136v2/tmp/red125c.fv7xvM/m1/home/projects/Toy-Repo-29fd, --, непустой MSG]: --yolo|--|Сессия проекта поднята без задания: прочитай .harness/HANDOFF.md и .harness/ROADMAP.md проекта, выбери предмет, доложи план.|WORKTREE=/tmp/dev-harness-verify/Critic136v2/tmp/red125c.fv7xvM/m1/home/dev-harness-projects/toy-repo-29fd/wt/wip-136-demo|BRANCH=wip/136/demo|/tmp/dev-harness-verify/Critic136v2/tmp/red125c.fv7xvM/m1/home/projects/Toy-Repo-29fd|;
ЗЕЛЕНО c02-yolo
ЗЕЛЕНО c03-projectid
ЗЕЛЕНО c04-klon-https-gh
ЗЕЛЕНО c05-pin
ЗЕЛЕНО c06-deny
ЗЕЛЕНО c07-karkas
ЗЕЛЕНО c08-tolko-harness
ЗЕЛЕНО c09-env-klyuchi
ЗЕЛЕНО c10-sekrety-vyvod
ЗЕЛЕНО c11-sekrety-repo
ЗЕЛЕНО c12-povtor
ЗЕЛЕНО c13-sverhu
ЗЕЛЕНО c14-imya-vne-klassa
ЗЕЛЕНО c15-mob-bez-pravok
ЗЕЛЕНО c16-mob-ci
ЗЕЛЕНО c17-env-v-indekse
ЗЕЛЕНО c18-zhizn-povtor
ЗЕЛЕНО c19-zhizn-add-f
ЗЕЛЕНО c20-zhizn-add-a
ЗЕЛЕНО c21-zhizn-vetka
ЗЕЛЕНО c22-zhizn-imya

RC=0
```

### m03-root-after-separator-136

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_run_red_sessii_136.sh --model
sessii_136: клеток 41, зелёных 39, красных 2
красные: a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem
модель не зелёная

RC=2
```

### m04-foreign-root-125C

```text
$ bash fixtures/workshop_project/sessii_125/_gruppa_c.sh
КРАСНО c01-zapusk-odin:  границы argv workshop ≠ [--yolo, /tmp/dev-harness-verify/Critic136v2/tmp/red125c.z3uVPn/m1/home/projects/Toy-Repo-2cb1] | [--yolo, /tmp/dev-harness-verify/Critic136v2/tmp/red125c.z3uVPn/m1/home/projects/Toy-Repo-2cb1, --, непустой MSG]: --yolo|/tmp/dev-harness-verify/Critic136v2/tmp/red125c.z3uVPn/m1/home|--|Сессия проекта поднята без задания: прочитай .harness/HANDOFF.md и .harness/ROADMAP.md проекта, выбери предмет, доложи план.|WORKTREE=/tmp/dev-harness-verify/Critic136v2/tmp/red125c.z3uVPn/m1/home/dev-harness-projects/toy-repo-2cb1/wt/wip-136-demo|BRANCH=wip/136/demo|;
ЗЕЛЕНО c02-yolo
ЗЕЛЕНО c03-projectid
ЗЕЛЕНО c04-klon-https-gh
ЗЕЛЕНО c05-pin
ЗЕЛЕНО c06-deny
ЗЕЛЕНО c07-karkas
ЗЕЛЕНО c08-tolko-harness
ЗЕЛЕНО c09-env-klyuchi
ЗЕЛЕНО c10-sekrety-vyvod
ЗЕЛЕНО c11-sekrety-repo
ЗЕЛЕНО c12-povtor
ЗЕЛЕНО c13-sverhu
ЗЕЛЕНО c14-imya-vne-klassa
ЗЕЛЕНО c15-mob-bez-pravok
ЗЕЛЕНО c16-mob-ci
ЗЕЛЕНО c17-env-v-indekse
ЗЕЛЕНО c18-zhizn-povtor
ЗЕЛЕНО c19-zhizn-add-f
ЗЕЛЕНО c20-zhizn-add-a
ЗЕЛЕНО c21-zhizn-vetka
ЗЕЛЕНО c22-zhizn-imya

RC=0
```

### m04-foreign-root-136

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_run_red_sessii_136.sh --model
sessii_136: клеток 41, зелёных 39, красных 2
красные: a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem
модель не зелёная

RC=2
```

### m05-duplicate-root-125C

```text
$ bash fixtures/workshop_project/sessii_125/_gruppa_c.sh
КРАСНО c01-zapusk-odin:  границы argv workshop ≠ [--yolo, /tmp/dev-harness-verify/Critic136v2/tmp/red125c.eeJLyX/m1/home/projects/Toy-Repo-696c] | [--yolo, /tmp/dev-harness-verify/Critic136v2/tmp/red125c.eeJLyX/m1/home/projects/Toy-Repo-696c, --, непустой MSG]: --yolo|/tmp/dev-harness-verify/Critic136v2/tmp/red125c.eeJLyX/m1/home/projects/Toy-Repo-696c|/tmp/dev-harness-verify/Critic136v2/tmp/red125c.eeJLyX/m1/home/projects/Toy-Repo-696c|--|Сессия проекта поднята без задания: прочитай .harness/HANDOFF.md и .harness/ROADMAP.md проекта, выбери предмет, доложи план.|WORKTREE=/tmp/dev-harness-verify/Critic136v2/tmp/red125c.eeJLyX/m1/home/dev-harness-projects/toy-repo-696c/wt/wip-136-demo|BRANCH=wip/136/demo|;
ЗЕЛЕНО c02-yolo
ЗЕЛЕНО c03-projectid
ЗЕЛЕНО c04-klon-https-gh
ЗЕЛЕНО c05-pin
ЗЕЛЕНО c06-deny
ЗЕЛЕНО c07-karkas
ЗЕЛЕНО c08-tolko-harness
ЗЕЛЕНО c09-env-klyuchi
ЗЕЛЕНО c10-sekrety-vyvod
ЗЕЛЕНО c11-sekrety-repo
ЗЕЛЕНО c12-povtor
ЗЕЛЕНО c13-sverhu
ЗЕЛЕНО c14-imya-vne-klassa
ЗЕЛЕНО c15-mob-bez-pravok
ЗЕЛЕНО c16-mob-ci
ЗЕЛЕНО c17-env-v-indekse
ЗЕЛЕНО c18-zhizn-povtor
ЗЕЛЕНО c19-zhizn-add-f
ЗЕЛЕНО c20-zhizn-add-a
ЗЕЛЕНО c21-zhizn-vetka
ЗЕЛЕНО c22-zhizn-imya

RC=0
```

### m05-duplicate-root-136

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_run_red_sessii_136.sh --model
sessii_136: клеток 41, зелёных 39, красных 2
красные: a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem
модель не зелёная

RC=2
```

### m06-taskfile-noroot-125-all

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_125/critic_run_red_sessii_125.sh
ЗЕЛЕНО a01-chestnaya
ЗЕЛЕНО a02-dom-obshij
ЗЕЛЕНО a03-drejf-config-yml
ЗЕЛЕНО a03-drejf-models-db
ЗЕЛЕНО a03-drejf-skill-descriptions-db
ЗЕЛЕНО a04-ssylka-config-yml
ЗЕЛЕНО a04-ssylka-models-db
ЗЕЛЕНО a04-zhestkaya-config-yml
ЗЕЛЕНО a05-net-config-yml
ЗЕЛЕНО a06-agentdb-kopiya
ЗЕЛЕНО a07-sessii-kopiya
ЗЕЛЕНО a07-history-ssylka
ЗЕЛЕНО a07-blobs-kopiya
ЗЕЛЕНО a07-history-pereimenovana
ЗЕЛЕНО a07-sessiya-pereimenovana
ЗЕЛЕНО a07-vne-profilya
ЗЕЛЕНО a07-ssylka-pereimenovana
ЗЕЛЕНО a19-dost-fajl-dev
ЗЕЛЕНО a20-dost-podkatalog
ЗЕЛЕНО a21-dost-katalog-agenta
ЗЕЛЕНО a21-dost-roditel
ЗЕЛЕНО a22-dost-cepochka
ЗЕЛЕНО a23-dost-otnositelnaya
ЗЕЛЕНО a26-dost-cherez-katalog
ЗЕЛЕНО a24-dost-hardlink
ЗЕЛЕНО a25-dost-hardlink-pustoj
ЗЕЛЕНО a08-profil
ЗЕЛЕНО a09-podtverzhdeniya
ЗЕЛЕНО a10-model
ЗЕЛЕНО a11-instrumenty
ЗЕЛЕНО a12-politika
ЗЕЛЕНО a13-rasshireniya
ЗЕЛЕНО a14-pravila
ЗЕЛЕНО a15-agenty
ЗЕЛЕНО a16-tri-prichiny
ЗЕЛЕНО a17-nechem-pustye-fakty
ЗЕЛЕНО a18-nechem-osnovnaya-bez-config
ЗЕЛЕНО b01-dom-otdelnyj
ЗЕЛЕНО b02-sev-pobajtno
ЗЕЛЕНО b05-ne-sessii
ЗЕЛЕНО b06-ne-sekrety
ЗЕЛЕНО b07-agentdb-w8
ЗЕЛЕНО b08-sverka-chestnaya
ЗЕЛЕНО b09-podtv-bez-yolo
ЗЕЛЕНО b03-drejf
ЗЕЛЕНО b04-zapis-ne-v-dev
ЗЕЛЕНО b10-podtv-yolo
ЗЕЛЕНО b11-harness-raskladka
ЗЕЛЕНО c01-zapusk-odin
ЗЕЛЕНО c02-yolo
ЗЕЛЕНО c03-projectid
ЗЕЛЕНО c04-klon-https-gh
ЗЕЛЕНО c05-pin
ЗЕЛЕНО c06-deny
ЗЕЛЕНО c07-karkas
ЗЕЛЕНО c08-tolko-harness
ЗЕЛЕНО c09-env-klyuchi
ЗЕЛЕНО c10-sekrety-vyvod
ЗЕЛЕНО c11-sekrety-repo
ЗЕЛЕНО c12-povtor
ЗЕЛЕНО c13-sverhu
ЗЕЛЕНО c14-imya-vne-klassa
ЗЕЛЕНО c15-mob-bez-pravok
ЗЕЛЕНО c16-mob-ci
ЗЕЛЕНО c17-env-v-indekse
ЗЕЛЕНО c18-zhizn-povtor
ЗЕЛЕНО c19-zhizn-add-f
ЗЕЛЕНО c20-zhizn-add-a
ЗЕЛЕНО c21-zhizn-vetka
ЗЕЛЕНО c22-zhizn-imya
s125 red: зелёных 70, красных 0

RC=0
```

### m06-taskfile-noroot-125C

```text
$ bash fixtures/workshop_project/sessii_125/_gruppa_c.sh
ЗЕЛЕНО c01-zapusk-odin
ЗЕЛЕНО c02-yolo
ЗЕЛЕНО c03-projectid
ЗЕЛЕНО c04-klon-https-gh
ЗЕЛЕНО c05-pin
ЗЕЛЕНО c06-deny
ЗЕЛЕНО c07-karkas
ЗЕЛЕНО c08-tolko-harness
ЗЕЛЕНО c09-env-klyuchi
ЗЕЛЕНО c10-sekrety-vyvod
ЗЕЛЕНО c11-sekrety-repo
ЗЕЛЕНО c12-povtor
ЗЕЛЕНО c13-sverhu
ЗЕЛЕНО c14-imya-vne-klassa
ЗЕЛЕНО c15-mob-bez-pravok
ЗЕЛЕНО c16-mob-ci
ЗЕЛЕНО c17-env-v-indekse
ЗЕЛЕНО c18-zhizn-povtor
ЗЕЛЕНО c19-zhizn-add-f
ЗЕЛЕНО c20-zhizn-add-a
ЗЕЛЕНО c21-zhizn-vetka
ЗЕЛЕНО c22-zhizn-imya

RC=0
```

### m06-taskfile-noroot-136

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_run_red_sessii_136.sh --model
sessii_136: клеток 41, зелёных 41, красных 0

RC=0
```

### m07-no-final-oracle-125-all

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_125/critic_run_red_sessii_125.sh
ЗЕЛЕНО a01-chestnaya
ЗЕЛЕНО a02-dom-obshij
ЗЕЛЕНО a03-drejf-config-yml
ЗЕЛЕНО a03-drejf-models-db
ЗЕЛЕНО a03-drejf-skill-descriptions-db
ЗЕЛЕНО a04-ssylka-config-yml
ЗЕЛЕНО a04-ssylka-models-db
ЗЕЛЕНО a04-zhestkaya-config-yml
ЗЕЛЕНО a05-net-config-yml
ЗЕЛЕНО a06-agentdb-kopiya
ЗЕЛЕНО a07-sessii-kopiya
ЗЕЛЕНО a07-history-ssylka
ЗЕЛЕНО a07-blobs-kopiya
ЗЕЛЕНО a07-history-pereimenovana
ЗЕЛЕНО a07-sessiya-pereimenovana
ЗЕЛЕНО a07-vne-profilya
ЗЕЛЕНО a07-ssylka-pereimenovana
ЗЕЛЕНО a19-dost-fajl-dev
ЗЕЛЕНО a20-dost-podkatalog
ЗЕЛЕНО a21-dost-katalog-agenta
ЗЕЛЕНО a21-dost-roditel
ЗЕЛЕНО a22-dost-cepochka
ЗЕЛЕНО a23-dost-otnositelnaya
ЗЕЛЕНО a26-dost-cherez-katalog
ЗЕЛЕНО a24-dost-hardlink
ЗЕЛЕНО a25-dost-hardlink-pustoj
ЗЕЛЕНО a08-profil
ЗЕЛЕНО a09-podtverzhdeniya
ЗЕЛЕНО a10-model
ЗЕЛЕНО a11-instrumenty
ЗЕЛЕНО a12-politika
ЗЕЛЕНО a13-rasshireniya
ЗЕЛЕНО a14-pravila
ЗЕЛЕНО a15-agenty
ЗЕЛЕНО a16-tri-prichiny
ЗЕЛЕНО a17-nechem-pustye-fakty
ЗЕЛЕНО a18-nechem-osnovnaya-bez-config
ЗЕЛЕНО b01-dom-otdelnyj
ЗЕЛЕНО b02-sev-pobajtno
ЗЕЛЕНО b05-ne-sessii
ЗЕЛЕНО b06-ne-sekrety
ЗЕЛЕНО b07-agentdb-w8
ЗЕЛЕНО b08-sverka-chestnaya
ЗЕЛЕНО b09-podtv-bez-yolo
ЗЕЛЕНО b03-drejf
ЗЕЛЕНО b04-zapis-ne-v-dev
ЗЕЛЕНО b10-podtv-yolo
ЗЕЛЕНО b11-harness-raskladka
ЗЕЛЕНО c01-zapusk-odin
ЗЕЛЕНО c02-yolo
ЗЕЛЕНО c03-projectid
ЗЕЛЕНО c04-klon-https-gh
ЗЕЛЕНО c05-pin
ЗЕЛЕНО c06-deny
ЗЕЛЕНО c07-karkas
ЗЕЛЕНО c08-tolko-harness
ЗЕЛЕНО c09-env-klyuchi
ЗЕЛЕНО c10-sekrety-vyvod
ЗЕЛЕНО c11-sekrety-repo
ЗЕЛЕНО c12-povtor
ЗЕЛЕНО c13-sverhu
ЗЕЛЕНО c14-imya-vne-klassa
ЗЕЛЕНО c15-mob-bez-pravok
ЗЕЛЕНО c16-mob-ci
ЗЕЛЕНО c17-env-v-indekse
ЗЕЛЕНО c18-zhizn-povtor
ЗЕЛЕНО c19-zhizn-add-f
ЗЕЛЕНО c20-zhizn-add-a
ЗЕЛЕНО c21-zhizn-vetka
ЗЕЛЕНО c22-zhizn-imya
s125 red: зелёных 70, красных 0

RC=0
```

### m07-no-final-oracle-136

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_run_red_sessii_136.sh --model
sessii_136: клеток 41, зелёных 41, красных 0

RC=0
```

### m08-node-fallback-125-all

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_125/critic_run_red_sessii_125.sh
ЗЕЛЕНО a01-chestnaya
ЗЕЛЕНО a02-dom-obshij
ЗЕЛЕНО a03-drejf-config-yml
ЗЕЛЕНО a03-drejf-models-db
ЗЕЛЕНО a03-drejf-skill-descriptions-db
ЗЕЛЕНО a04-ssylka-config-yml
ЗЕЛЕНО a04-ssylka-models-db
ЗЕЛЕНО a04-zhestkaya-config-yml
ЗЕЛЕНО a05-net-config-yml
ЗЕЛЕНО a06-agentdb-kopiya
ЗЕЛЕНО a07-sessii-kopiya
ЗЕЛЕНО a07-history-ssylka
ЗЕЛЕНО a07-blobs-kopiya
ЗЕЛЕНО a07-history-pereimenovana
ЗЕЛЕНО a07-sessiya-pereimenovana
ЗЕЛЕНО a07-vne-profilya
ЗЕЛЕНО a07-ssylka-pereimenovana
ЗЕЛЕНО a19-dost-fajl-dev
ЗЕЛЕНО a20-dost-podkatalog
ЗЕЛЕНО a21-dost-katalog-agenta
ЗЕЛЕНО a21-dost-roditel
ЗЕЛЕНО a22-dost-cepochka
ЗЕЛЕНО a23-dost-otnositelnaya
ЗЕЛЕНО a26-dost-cherez-katalog
ЗЕЛЕНО a24-dost-hardlink
ЗЕЛЕНО a25-dost-hardlink-pustoj
ЗЕЛЕНО a08-profil
ЗЕЛЕНО a09-podtverzhdeniya
ЗЕЛЕНО a10-model
ЗЕЛЕНО a11-instrumenty
ЗЕЛЕНО a12-politika
ЗЕЛЕНО a13-rasshireniya
ЗЕЛЕНО a14-pravila
ЗЕЛЕНО a15-agenty
ЗЕЛЕНО a16-tri-prichiny
ЗЕЛЕНО a17-nechem-pustye-fakty
ЗЕЛЕНО a18-nechem-osnovnaya-bez-config
ЗЕЛЕНО b01-dom-otdelnyj
ЗЕЛЕНО b02-sev-pobajtno
ЗЕЛЕНО b05-ne-sessii
ЗЕЛЕНО b06-ne-sekrety
ЗЕЛЕНО b07-agentdb-w8
ЗЕЛЕНО b08-sverka-chestnaya
ЗЕЛЕНО b09-podtv-bez-yolo
ЗЕЛЕНО b03-drejf
ЗЕЛЕНО b04-zapis-ne-v-dev
ЗЕЛЕНО b10-podtv-yolo
ЗЕЛЕНО b11-harness-raskladka
ЗЕЛЕНО c01-zapusk-odin
ЗЕЛЕНО c02-yolo
ЗЕЛЕНО c03-projectid
ЗЕЛЕНО c04-klon-https-gh
ЗЕЛЕНО c05-pin
ЗЕЛЕНО c06-deny
ЗЕЛЕНО c07-karkas
ЗЕЛЕНО c08-tolko-harness
ЗЕЛЕНО c09-env-klyuchi
ЗЕЛЕНО c10-sekrety-vyvod
ЗЕЛЕНО c11-sekrety-repo
ЗЕЛЕНО c12-povtor
ЗЕЛЕНО c13-sverhu
ЗЕЛЕНО c14-imya-vne-klassa
ЗЕЛЕНО c15-mob-bez-pravok
ЗЕЛЕНО c16-mob-ci
ЗЕЛЕНО c17-env-v-indekse
ЗЕЛЕНО c18-zhizn-povtor
ЗЕЛЕНО c19-zhizn-add-f
ЗЕЛЕНО c20-zhizn-add-a
ЗЕЛЕНО c21-zhizn-vetka
ЗЕЛЕНО c22-zhizn-imya
s125 red: зелёных 70, красных 0

RC=0
```

### m08-node-fallback-136

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_run_red_sessii_136.sh --model
sessii_136: клеток 41, зелёных 41, красных 0

RC=0
```

### m09-exact-layer-only-136

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_run_red_sessii_136.sh --model
sessii_136: клеток 41, зелёных 41, красных 0

RC=0
```

### m10-parity-jq-fallback-136

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_run_red_sessii_136.sh --model
sessii_136: клеток 41, зелёных 41, красных 0

RC=0
```

### m11-allow-duplicate-136

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_run_red_sessii_136.sh --model
sessii_136: клеток 41, зелёных 38, красных 3
красные: a10-pin-duplicate a19-pin-inline-mixed a21-pin-taskfile-duplicate
модель не зелёная

RC=2
```

### m12-append-root-to-msg-125C

```text
$ bash fixtures/workshop_project/sessii_125/_gruppa_c.sh
ЗЕЛЕНО c01-zapusk-odin
ЗЕЛЕНО c02-yolo
ЗЕЛЕНО c03-projectid
ЗЕЛЕНО c04-klon-https-gh
ЗЕЛЕНО c05-pin
ЗЕЛЕНО c06-deny
ЗЕЛЕНО c07-karkas
ЗЕЛЕНО c08-tolko-harness
ЗЕЛЕНО c09-env-klyuchi
ЗЕЛЕНО c10-sekrety-vyvod
ЗЕЛЕНО c11-sekrety-repo
ЗЕЛЕНО c12-povtor
ЗЕЛЕНО c13-sverhu
ЗЕЛЕНО c14-imya-vne-klassa
ЗЕЛЕНО c15-mob-bez-pravok
ЗЕЛЕНО c16-mob-ci
ЗЕЛЕНО c17-env-v-indekse
ЗЕЛЕНО c18-zhizn-povtor
ЗЕЛЕНО c19-zhizn-add-f
ЗЕЛЕНО c20-zhizn-add-a
ЗЕЛЕНО c21-zhizn-vetka
ЗЕЛЕНО c22-zhizn-imya

RC=0
```

### m12-append-root-to-msg-136

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_run_red_sessii_136.sh --model
sessii_136: клеток 41, зелёных 39, красных 2
красные: a25-argv-koren-do-razdelitelja a26-ctrl-msg-zakanchivaetsya-putem
модель не зелёная

RC=2
```

### probe-alternate-layer

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_probe_alternate-layer.sh --model
SUBJECT=/tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/model/verify_ci_parity.sh
  FAIL .github/workflows/ci.yml:7: команда «npm run dev» есть в CI, но нет пункта в приёмке и не объявлена исключением
  FAIL скрипт «build» есть в приёмке, но отсутствует в CI и не объявлен исключением

workflow-команд: 1 · скриптов в приёмке: 1 · объявленных исключений: 0 · matrix-ключей: 0 · анти-плацебо-запусков: 0 · расхождений: 2
SUBJECT_RC=1
SUBJECT=/tmp/dev-harness-verify/Critic136v2/mutants/m09-exact-layer-only/verify_ci_parity.sh
  ok   команда «npm run dev» (.github/workflows/ci.yml:7) приёмкой не является — объявленное исключение: команда релизного CI проекта, приёмкой пакета не является совсем
  ok   скрипт «build» не в CI — объявленное исключение: скрипт сборки тоя вне CI проекта, объявлён по причине smoke

workflow-команд: 1 · скриптов в приёмке: 1 · объявленных исключений: 2 · matrix-ключей: 0 · анти-плацебо-запусков: 0 · расхождений: 0
SUBJECT_RC=0

RC=0
```

### probe-dependencies

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_probe_dependencies.sh --model
SUBJECT=/tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/model/verify_ci_parity.sh
NOT_IMPLEMENTED: harness.project.json есть, jq нет — режим паритета не определить молча
SUBJECT_RC=2
SUBJECT=/tmp/dev-harness-verify/Critic136v2/mutants/m10-parity-jq-fallback/verify_ci_parity.sh
fallback harness mode
SUBJECT_RC=0
NONEXEC_GUARD_RC=7
FAKE_NODE_RC=7
EXEC=yes

RC=0
```

### probe-final-oracle

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_probe_final-oracle.sh --model
SUBJECT=/tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/model/connect_project.sh RC=1
connect ОТКАЗ: PIN_CHUZHOJ: итоговый текст не извлекается в пин двери
EXEC=no
SUBJECT=/tmp/dev-harness-verify/Critic136v2/mutants/m07-no-final-oracle/connect_project.sh RC=7
EXEC=yes
{"worktree":null}

RC=0
```

### probe-guard-stubs

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_probe_guard-stubs.sh --model
connect ОТКАЗ: PIN_CHUZHOJ: итоговый текст не извлекается в пин двери
KIND=empty RC=1
EXEC=no
file:///tmp/dev-harness-verify/Critic136v2/tmp/dev-harness-verify/sessii-136-probe-guard-stubs/sb/.omp/extensions/path-guard.ts:1
syntax ### broken
       ^

SyntaxError [ERR_INVALID_TYPESCRIPT_SYNTAX]: Expected ';', '}' or <eof>
    at parseTypeScript (node:internal/modules/typescript:61:36)
    at processTypeScriptCode (node:internal/modules/typescript:129:37)
    at stripTypeScriptModuleTypes (node:internal/modules/typescript:172:22)
    at Module._compile (node:internal/modules/cjs/loader:1888:15)
    at Object..js (node:internal/modules/cjs/loader:2074:10)
    at Module.load (node:internal/modules/cjs/loader:1656:32)
    at Module._load (node:internal/modules/cjs/loader:1448:12)
    at wrapModuleLoad (node:internal/modules/cjs/loader:261:19)
    at Module.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:154:5)
    at node:internal/main/run_main_module:33:47 {
  code: 'ERR_INVALID_TYPESCRIPT_SYNTAX'
}

Node.js v26.5.1
connect ОТКАЗ: PIN_CHUZHOJ: невозможно извлечь итоговый пин
KIND=broken RC=1
EXEC=no
KIND=fake RC=7
EXEC=yes

RC=0
```

### probe-missing-node

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_probe_missing-node.sh --model
connect ОТКАЗ: strazh-net: нечем исполнить страж установки (node): /tmp/dev-harness-verify/Critic136v2/tmp/dev-harness-verify/sessii-136-probe-missing-node/sb/.omp/extensions/path-guard.ts
SUBJECT=/tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/model/connect_project.sh RC=1
EXEC=no
SUBJECT=/tmp/dev-harness-verify/Critic136v2/mutants/m08-node-fallback/connect_project.sh RC=7
EXEC=yes

RC=0
```

### probe-nul

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_probe_nul.sh --model
RC=7 ARGC=4 ROOT_MATCH=0
ARG=<--yolo>
ARG=</tmp/dev-harness-verify/Critic136v2/fakehomeprobe-nul/seed/toy-proj>
ARG=<-->
ARG=<$'TaskARGC=4\n--\nWORKSHOP_ROOT=spoof\nWORKTREE=/tmp/dev-harness-verify/Critic136v2/fakehomeprobe-nul/dev-harness-projects/toy-proj/wt/wip-136-demo\nBRANCH=wip/136/demo'>
/tmp/dev-harness-verify/Critic136v2/tmp/dev-harness-verify/sessii-136-probe-nul/sb/scripts/connect_project.sh: line 133: warning: command substitution: ignored null byte in input

RC=0
```

### probe-scan-canon

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_probe_scan-canon.sh --model
KIND=nul
profile ОТКАЗ: SOURCE_CANON_INVALID: репо-слой.sourceCanon.sources[0]: path NUL
RESOLVER_RC=1
  FAIL .github/workflows/ci.yml:7: команда «npm run dev» есть в CI, но нет пункта в приёмке и не объявлена исключением
  FAIL скрипт «build» есть в приёмке, но отсутствует в CI и не объявлен исключением

workflow-команд: 1 · скриптов в приёмке: 1 · объявленных исключений: 0 · matrix-ключей: 0 · анти-плацебо-запусков: 0 · расхождений: 2
DIRECT_PARITY_RC=1
KIND=dots
profile ОТКАЗ: SOURCE_CANON_INVALID: репо-слой.sourceCanon.sources[0]: path ..
RESOLVER_RC=1
  FAIL .github/workflows/ci.yml:7: команда «npm run dev» есть в CI, но нет пункта в приёмке и не объявлена исключением
  FAIL скрипт «build» есть в приёмке, но отсутствует в CI и не объявлен исключением

workflow-команд: 1 · скриптов в приёмке: 1 · объявленных исключений: 0 · matrix-ключей: 0 · анти-плацебо-запусков: 0 · расхождений: 2
DIRECT_PARITY_RC=1
KIND=absolute
profile ОТКАЗ: SOURCE_CANON_INVALID: репо-слой.sourceCanon.sources[0]: path абсолютный
RESOLVER_RC=1
  FAIL .github/workflows/ci.yml:7: команда «npm run dev» есть в CI, но нет пункта в приёмке и не объявлена исключением
  FAIL скрипт «build» есть в приёмке, но отсутствует в CI и не объявлен исключением

workflow-команд: 1 · скриптов в приёмке: 1 · объявленных исключений: 0 · matrix-ключей: 0 · анти-плацебо-запусков: 0 · расхождений: 2
DIRECT_PARITY_RC=1

RC=0
```

### probe-shadow

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_probe_shadow.sh --model
SHADOW_KIND=nul
profile ОТКАЗ: SOURCE_CANON_INVALID: слой-проекта.defaults.sourceCanon.sources[0]: path NUL
RESOLVER_RC=1
SHADOW_KIND=dots
profile ОТКАЗ: SOURCE_CANON_INVALID: слой-проекта.defaults.sourceCanon.sources[0]: path ..
RESOLVER_RC=1
SHADOW_KIND=absolute
profile ОТКАЗ: SOURCE_CANON_INVALID: слой-проекта.defaults.sourceCanon.sources[0]: path абсолютный
RESOLVER_RC=1

RC=0
```

### probe-taskfile-argv

```text
$ bash /tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/critic_probe_taskfile-argv.sh --model
SUBJECT=/tmp/dev-harness-verify/Critic136v2/repo/fixtures/workshop_project/sessii_136/model/connect_project.sh RC=7 ARGC=4
ARG=<--yolo>
ARG=</tmp/dev-harness-verify/Critic136v2/fakehomeprobe-taskfile-argv/seed/toy-proj>
ARG=<-->
ARG=<$'TASKFILE: текст\n--\nARGC=4\nWORKTREE=/tmp/dev-harness-verify/Critic136v2/fakehomeprobe-taskfile-argv/dev-harness-projects/toy-proj/wt/wip-136-demo\nBRANCH=wip/136/demo'>
SUBJECT=/tmp/dev-harness-verify/Critic136v2/mutants/m06-taskfile-noroot/connect_project.sh RC=7 ARGC=3
ARG=<--yolo>
ARG=<-->
ARG=<$'TASKFILE: текст\n--\nARGC=4\nWORKTREE=/tmp/dev-harness-verify/Critic136v2/fakehomeprobe-taskfile-argv/dev-harness-projects/toy-proj/wt/wip-136-demo\nBRANCH=wip/136/demo'>

RC=0
```
