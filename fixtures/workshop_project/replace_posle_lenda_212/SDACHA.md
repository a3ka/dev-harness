# СДАЧА 212 — исправление батареи по Adv212b Б-1/Б-2

Основание: `d3e7adfd1d1aaae45db1e60866ee1227860e7657:verdicts/adversary/contracts-212-impl-v2.md`, OBJECT/база `2574fec93993292f0eab13cfc4f534dad39f1f0f`, задание task-architect212d.md. Оба блока — К-08. Б-3 вердикта (независимый дрейф main) не входит в исправление. Замороженный контракт, production, модель, CI и прочие зоны не меняются. Прежние клетки и привязки сохранены.

## Существующее и доказательство

`probe212.py` уже строит настоящие toy/bare-origin миры, запускает живую дверь 031 и сверяет полные bytes stdout/stderr, HEAD, реестр, identity, status. `source.json` генерируется из `STAB_MUTACII`/`STAB_VHOD`; второго реестра привязок нет. Носители модели/стабов сверяются sha256 до вызова. Отказные пост-проверки сверяют HEAD, исходные байты worktree и status; r23 сохраняет предъявление remint /1, r24 — отказ commit/откат, r25 — удерживаемый исходный inode.

Обещание прежнее: прямой registry-only коммит main после ленда/публикации либо именованный отказ без изменения состояния. Frozen-обязательства: `contracts/212-replace-posle-lenda.md:33` — tag-object выбранного vmax, не только /1; `:36` — временный файл и mv. r26 использует опубликованную /2 и remint на тот же commit, фиксирует разные tag-object и равные peeled commits до субъекта. r27 наблюдает st_dev источника непосредственно перед настоящим mv и st_dev каталога реестра: через EXDEV mv копирует/удаляет, а не выполняет атомарный rename. Оракул ожиданий и пред-снимок остаются в памяти.

Шим r27 только пишет JSON-наблюдение stat и exec настоящего mv, найденного ДО субъекта: argv, stdout/stderr и rc не заменяются. Это не двойник git/mv и не анализ исходника. Наблюдаемая форма — штатная `mv [флаги] src dst`, включая честные -f/-T/--. Точный каталог TMP не предписан frozen-контрактом: допускается любая та же ФС. Поэтому неизменённая модель с TMP в корне toy, production с TMP в registry и /tmp на той же ФС остаются зелёными. Обязанность атомарного cutover — из :36, нового требования «только registry» нет. Пустое наблюдение — красное, не пусто-зелёное.

До исправления (сырые результаты вердикта, не повторялись): repo/model rc 0, 31/0; stabs rc 0, 79/0; синтаксис rc 0, 48/3; оба новых production-мутанта давали --repo rc 0. После: repo/model rc 0, 33/0; stabs rc 0, 81/0; синтаксис rc 0, 50/3. Независимый `jq '{worlds:(.kejsy|length),stabs:(.stab_vhod|length),bindings:([.stab_vhod[]|length]|add)}' fixtures/workshop_project/replace_posle_lenda_212/source.json` дал 27 миров, 48 стабов, 81 связь; неизменные argv-клетки дополняют миры до 33.

Среда: TMPDIR=/tmp/dev-harness-verify/scratch-arch212d (создать до прогона, удалить после); VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck. Нет валидатора — rc 2, не пропуск. Синтаксис намеренных мутантов — bash -n; пинованный shellcheck — честные носители.

## Двери

- Repo-posle-realizacii · bash fixtures/workshop_project/replace_posle_lenda_212/red_replace_posle_lenda_212.sh --repo . · 0 · 0
- Model · bash fixtures/workshop_project/replace_posle_lenda_212/red_replace_posle_lenda_212.sh --model · 0 · 0
- Stabs · bash fixtures/workshop_project/replace_posle_lenda_212/red_replace_posle_lenda_212.sh --stabs · 0 · 0
- Sintaksis · bash fixtures/workshop_project/replace_posle_lenda_212/red_replace_posle_lenda_212.sh --sintaksis · 0 · 0
- Adversary-mutants · fixtures/workshop_project/replace_posle_lenda_212/mutants212.py · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/212-replace-posle-lenda.md · 0 · 0
- Spec-ready · bash scripts/check_spec_ready.sh . contracts/212-replace-posle-lenda.md · 0 · 0
- Predposylki · bash scripts/check_predposylki.sh . contracts/212-replace-posle-lenda.md · 0 · 0
- Threat-model · bash scripts/check_threat_model.sh . contracts/212-replace-posle-lenda.md · 0 · 0
- Ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- Ids · bash scripts/check_ids.sh . · 0 · 0
- Provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/212-replace-posle-lenda.md · 0 · 0
- CI-canon · bash scripts/gen_ci_steps.sh --check · 0 · 0
- Pre-critic · bash scripts/pre_critic.sh contracts/212-replace-posle-lenda.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: check_sdacha --run исполняет двери; СДАЧА/ПРОВОДКА и frozen-контракт сохранены; сравнение области — с точной базой 2574fec93993292f0eab13cfc4f534dad39f1f0f, не с прежним main · - · -
- К-02 · чисто · вход: task-architect212d, только Б-1/Б-2 Adv212b; предмет, риск и frozen-инварианты не меняются · - · -
- К-03 · чисто · вход: production, модель, двери 031/049, маршруты 068/130/045/071, CI-реестры и контракт вне дельты · - · -
- К-04 · чисто · вход: только fixtures/workshop_project/replace_posle_lenda_212/; production-мутанты строятся в удаляемом клоне с собственным .git · - · -
- К-05 · чисто · вход: прежний CLI-договор/argv сохранены, отсутствие --nnn rc 1 с usage, негодный N rc 2 NOT_IMPLEMENTED · - · -
- К-06 · чисто · вход: потерянный носитель/якорь/синтаксис — rc 2, не зачёт мутанта; mutants212 требует успешного clone/checkout и собственного .git · - · -
- К-07 · чисто · вход: r26 — обычный freeze_v2 и remint выбранной /2 на тот же commit; r27 — успешный REPLACE с живым mv и наблюдением устройства, без sleep-гонок · - · -
- К-08 · чисто · вход: 81 связь, живых 0; st47/r26 и st48/r27 привязаны по коду; оба новых production-мутанта --repo rc 1 ровно своей новой клеткой · - · -
- К-09 · чисто · вход: прежние неконформные клетки/связи сохранены; r26/r27 используют конформные refs/CLI/реестр · - · -
- К-10 · чисто · вход: rc и полные bytes обеих труб без нормализации; r26 ожидает точный именованный отказ для /2, r27 — полный штатный успех · - · -
- К-11 · чисто · вход: пред-снимок в памяти; ожидания tag-object сняты до remint/субъекта; mv-журнал — результат наблюдения, не источник ожидаемых байтов · - · -
- К-12 · чисто · вход: DAG/refs — настоящий git; устройства — stat ОС; JSON — стандартный json; exec настоящего mv без подмены результата; source.json/стабы генерируются одним кодом · - · -
- К-13 · н/п · секретов нет, toy-origin локальны, credentials не добавлены · - · -
- К-14 · чисто · вход: честные model/repo зелены; перестановка операндов на /2, mv -f, mv -T --, TMP в корне toy и /tmp на той же ФС зелены · - · -
- К-15 · чисто · вход: repo/model 33/0, stabs 81/0, синтаксис 50/3; независимый jq source.json: 27 миров, 48 стабов, 81 связь; mutants212 требует точного множества красных клеток каждого мутанта · - · -
- К-16 · чисто · вход: прежний рисковый класс сохранён, пределы ниже с ловцами; CLI-совет не расширяет предмет · - · -
- К-17 · н/п · модель операций 188 не меняется, новых сервисов/писателей нет · - · -

## Дельта

- К-08 · клетка · fixtures/workshop_project/replace_posle_lenda_212/mutants212.py · 0 · 0

## Закрытие блоков и честные эквиваленты

| Блок | Способ и отказ от первых трёх способов | Мутация + соседняя | Честный эквивалент | Наблюдение |
| --- | --- | --- | --- | --- |
| Adv212b Б-1 | клетка: снимать/сужать frozen vmax нельзя; git уже канон фактов, нужен вход за пределом /1 | st47 сравнивает только vmax=1; соседняя сравнивает только vmax>=2 и красится прежней r23 | равенство с переставленными операндами на /2 | r26: разные tag-object /2, равные commits, полный отказ rc 1 и неизменность HEAD/реестра/status |
| Adv212b Б-2 | клетка: снимать/сужать временный файл+mv нельзя; stat/настоящий mv — канон механизма, нужен адресный наблюдатель | st48 mktemp -p /dev/shm; соседняя --tmpdir=/dev/shm; удаление mv красит предикат непустого наблюдения | mv -f, mv -T --; TMP в корне toy; /tmp на той же ФС | r27: настоящий mv без подмены, source.st_dev == registry.parent.st_dev; различие устройств даёт отдельную причину |
| Adv212 v1 Б-1 (сохранён) | клетка: frozen tag-object нельзя сужать до peeled | st44 peeled; соседняя удаляет сравнение | обратные операнды равенства | r23 и дополнительно r26 красны |
| Adv212 v1 Б-2 (сохранён) | клетка: штатный отказ commit и точечный откат обязательны | st45 убирает checkout; reset только индекса/restore только worktree | restore --source=HEAD --staged --worktree | r24: полный DENIED/отказ, прежние HEAD/байты/status |
| Adv212 v1 Б-3 (сохранён) | клетка: stat/fstat наблюдают cutover, не разбирают код | st46 cat с удалением TMP; cat затем mv портит открытый старый файл | mv -f | r25: другая идентичность и неизменный открытый старый файл; st46 дополнительно красен r27 |

Команда таблицы — `python3 fixtures/workshop_project/replace_posle_lenda_212/mutants212.py`, rc 0. Скрипт исполняет `bash <W> --repo <одноразовый-клон>` для каждой мутации настоящего production: st44 rc 1 (r23/r26), st45 rc 1 (r24), st46 rc 1 (r25/r27), st47 rc 1 (r26), st48 rc 1 (r27). Начальный текст production снимается один раз; каждый мутант строится заново от него, клон и миры удаляются finally. `--stabs` отдельно проверяет две новые привязки на генерируемых копиях модели; прежние 79 связей не заменяются. Модель не требует правки: TMP в корне toy уже на той же ФС.

## НЕ ЗАЩИЩАЕТ

r23/r26 различают remint выбранных /1 и /2 при равных commits, но конечные входы не доказывают поведение для каждого будущего номера версии или префикс-коллизии tag-object. Подлинность администратора origin и гонка после снимка не удостоверяются. Ловцы — adversary/reviewer, gitw/pre-push.

r27 доказывает равенство устройств у источника наблюдаемого mv, но не эквивалентность произвольного алгоритма атомарному rename: абсолютный вызов mv вне PATH, иная форма CLI (например mv -t), прямые syscalls, злонамеренная подделка журнала или unlink перед rename не доказаны этой пробой. Ловцы — adversary/reviewer по frozen-инварианту :36. Не вводится обещание crash-durability/fsync. r25 остаётся отдельным различителем прямой записи.

r24 доказывает восстановление при штатном ненулевом завершении хука, не при SIGKILL/отказе диска или злонамеренном хуке, меняющем посторонние пути. Ловцы — adversary/reviewer; доверенность тела хука остаётся frozen-границей.

CLI-совет Adv212 об отсутствующем значении после --nnn/--root вне пачки: production выдаёт shell-диагностику вместо usage. Ловцы — orchestrator отдельным предметом и reviewer; прежняя клетка отсутствующего самого --nnn сохранена.

## Наблюдение процесса

Первый прогон обновлённого mutants212 дал rc 1: st46 теперь закономерно красится и r27, а ожидание перечисляло только r25. Исправлено точное множество ожидаемых красных клеток, продукт/предикаты не ослаблялись; полный повтор mutants212 — rc 0. Общий журнал А-NN допускает запись только в main и вне разрешённой зоны этой пачки, поэтому не менялся. Нового отдельного процессного дефекта, кроме уже установленной неполноты различителей в вердикте, не выявлено.
