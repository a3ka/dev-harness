# СДАЧА 140 v+1 — модель, красное production и двери формы

БАЗА: 2bda5651096e666f8665f0cc9b860c72bd917651.
Объект этой пачки — только этот лист; контракт, scripts/ и батарея неизменны.
Рабочая копия: /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t99b06189d/m
Ветка: wip/140/architect-v5; git-dir — собственный .git внутри рабочей копии.
Origin: ssh://git@github.com/a3ka/dev-harness.git. Push не выполняется.

## Предмет и существующее

Контракт 140, разделы «Инварианты» и «Приёмочный критерий», остаётся источником
обязательств. В принятой базе уже есть общий resolver OBJECT, D49/D50/D51,
передача с опубликованным receipt и JSON Schema, detached runtime-checkout,
source/runpy-пробы, first-parent проверка непустоты commit/merge, pinned frozen
обоих владельцев предмета и прозрачные проверенные verdicts/ и .review/.
Прежние замок, сдача, isolated каждого item, batch-атомарность, исторические
START/author/count, ограничения повторного суда и лимиты 3/3/3 не исключены.

Слово владельца и адресные уточнения перечислены в контракте, включая 19.11
16:23. Замок судит продуктовый результат, а не очередной записанный verdict;
риск берётся из pinned frozen соответствующего владельца, не из OBJECT.
Исполняемые привязки мутаций — object_140.py/produkt_140.py и source.json;
этот лист не задаёт их заново. Предыдущий принятый суд —
verdicts/critic/contracts-140-v4.md (accept); эта пачка чинит форму листа,
не меняет обещания и не является исправительным кругом нового verdict.

## Среда и чтение результатов

Для прогона листа и pre_critic вызывающая оболочка задаёт
`TMPDIR=/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t99b06189d/m/.scratch-140-sheet-Arch140SheetFix`,
`PYTHONDONTWRITEBYTECODE=1`, `PATH=/usr/bin:/bin`.
Scratch создан внутри собственной копии; Git-миры батареи создаются под TMPDIR
и имеют собственные .git. Гейты формы используют также tmp/ этой же копии.
Доставка /tmp/dev-harness-verify/dev-harness-worktrees/c907157c/wip-140-architect-v5
не используется как cwd, git-dir или scratch.

В машинных строках ниже два rc — ожидаемый и предъявляемый проверке; они не
заменяют итог фактического запуска check_sdacha. Команды запускаются прямо,
без shell-хвостов, подавления отказов или подмены поставленной двери моделью.
До реализации W и W --stabs обязаны быть красными по контракту §Приёмка п.3:
rc 1 — наблюдаемый недостаток production, НЕ готовность реализации и НЕ
ошибка среды. После реализации обе строки требуют rc 0 и нового измерения.
NOT_IMPLEMENTED/ORACLE_TAMPERED rc 2 не засчитываются вместо предметного rc 1.

Из входной пользовательской приёмки точной БАЗЫ, а не нового собственного
прогона: W --model rc 0, 158/158; W --stabs rc 1, MODEL_ZHIVYH 0,
SVJAZI 136, только SUBJEKT_KRASNO 59. Старое утверждение об отсутствии
jsonschema снято: владелец установил engine; чистая среда проверяется отдельно.
Независимый подсчёт текущего source.json командой
`jq '{cases:(.kejsy|length), mutants:(.stab_vhod|length), bindings:([.stab_vhod[]|length]|add), carriers:(.nositeli|length)}' fixtures/workshop_project/odin_agent_140/source.json`
дал rc 0: cases=158, mutants=77, bindings=136, carriers=82.

## Двери

- W-model — честный контроль всех обязательств · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model · 0 · 0
- W-stabs — модельная матрица и обязательное красное production до реализации · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --stabs · 1 · 1
- W-production — реальная поставленная дверь до реализации · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh · 1 · 1
- W-sintaksis — носители семейства · bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --sintaksis · 0 · 0
- Precision — зоны и паритет CI · bash scripts/check_precision_gate.sh . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Spec-ready — форма контракта · bash scripts/check_spec_ready.sh . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Predposylki — форма объявленных предпосылок · bash scripts/check_predposylki.sh . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Threat-model — форма границы угроз · bash scripts/check_threat_model.sh . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Ceilings — потолки и незаполненные требования · bash scripts/check_ceilings.sh . · 0 · 0
- Provodka-grammar — грамматика каналов · bash scripts/check_provodka.sh --grammar . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Provodka — подключение guard-канала · bash scripts/check_provodka.sh . contracts/140-odin-agent-na-predmet.md · 0 · 0
- Pre-critic — все предсудебные ноги формы · bash scripts/pre_critic.sh --repo . contracts/140-odin-agent-na-predmet.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: машинные двери выше; check_sdacha --run сверяет фактические rc, pre_critic внутри листа использует штатный SDACHA_OKRUG=1 для разрыва рекурсии; отдельный внешний pre_critic обязан проверить лист целиком · - · -
- К-02 · чисто · вход: контракт §§Воля владельца, Существующее, Инварианты и Приёмочный критерий; требования 19.11 к продуктовому OBJECT, непустому tip, frozen и runtime сохранены; после pre_critic совмещённый critic вместо со-ревью+critic · - · -
- К-03 · чисто · вход: действующие обязательства 104/167 и 140 сохранены; передача 197 и порядок интеграции 199 не заменены новыми обещаниями листа; контракт и реализация этой пачкой не меняются · - · -
- К-04 · чисто · вход: единственный изменяемый путь fixtures/workshop_project/odin_agent_140/sdacha_140_v5.md находится в architect-зоне 140; материализация пинов и стабов не выполняется · - · -
- К-05 · чисто · вход: строки дверей соответствуют командам и rc §Приёмка 1–3/9; пункты 4–6 предъявляются полной W-model, п.8 отдельной чистой средой; станционные и постреализационные пункты явно отделены ниже · - · -
- К-06 · чисто · вход: W различает NOT_IMPLEMENTED и ORACLE_TAMPERED rc 2, красную клетку/субъект rc 1 и честную модель rc 0; отсутствие engine не допускается как ожидаемая краснота production · - · -
- К-07 · чисто · вход: полный W-model rc 0 требуется в дверях, не только scoped object_140 --check; зелень модели не объявляет готовыми production, pre_judge или станционную интеграцию · - · -
- К-08 · чисто · вход: W-stabs исполняет адресную матрицу модели из кода и обязательный слой настоящего scripts/zamok_predmeta.sh; ожидаемый rc 1 только до реализации; исходная приёмка БАЗЫ дала MODEL_ZHIVYH 0 и SVJAZI 136 · - · -
- К-09 · чисто · вход: полная W-model включает обе полярности isolated и frozen, непустой merge и пустые commit/merge, verdict+.review/.review-only без companion и посторонний путь, структурную сдачу и неконформные подмены, receipt и runtime; source.json — перечень 158 входов · - · -
- К-10 · чисто · вход: клетки проверяют START каждого item, атомарность записей, автора/учёт/счёт, опубликованную передачу и реальные source/runpy эффекты detached OBJECT; один marker/ref не заменяет поведение; настоящий pre_judge после реализации остаётся отдельной приёмкой · - · -
- К-11 · чисто · вход: probe.py загружает source.json и sha256-пины до субъекта; current source.json содержит 82 носителя; неизменённые object_140.py/produkt_140.py задают исполняемые привязки, лист не перечитывает диск субъекта как оракул · - · -
- К-12 · чисто · вход: Git plumbing для ancestry/first-parent/blob/tag, стандартный JSON Schema engine для receipt, jq для JSON событий и bash -n штатного W-sintaksis; новый проверяющий код или собственный парсер формата не вводятся · - · -
- К-13 · н/п · лист не вводит обработку секретов; публичные Git metadata и пины не объявляются криптографическим удостоверением · - · -
- К-14 · чисто · вход: W-model требует зелёные честные эквиваленты запрещающих ветвей, включая непустой merge, .review-only без companion и класс frozen вопреки OBJECT; мутанты предъявляются только своим кодовым связям · - · -
- К-15 · чисто · вход: jq source.json rc 0 дал 158 клеток, 77 мутантов, 136 связей, 82 носителя; MODEL_ZHIVYH 0 и SUBJEKT_KRASNO 59 атрибутированы пользовательскому замеру БАЗЫ, не выданы за собственный новый вывод · - · -
- К-16 · чисто · вход: КЛАСС РИСКА рисковый; контракт §Модель угроз оставляет sandbox, криптографическую подлинность полномочного Git-писателя и интеграцию живого omp за пределами модельного доказательства с adversary/reviewer как ловцами · - · -
- К-17 · н/п · лист не меняет L1/L2-модель 188, схемы операций или writers/isolationKeys; предметная исполняемая модель двери уже находится в БАЗЕ · - · -

## Дельта

Изменена только форма и актуальность листа: реальные машинные строки вместо
NOT_RUN для доступных команд; ожидания красного production не заменены нулями.
Нового предиката проверяющего кода, клетки или предметного обязательства нет.
Последний принятый verdict не содержит открытых блоков для этой правки листа.

## Отдельные обязательства и непройденные этапы

Чистая среда (§Приёмка п.8): команда
`env -i PATH=/usr/bin:/bin HOME=$TMPDIR TMPDIR=$TMPDIR bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model`
должна дать rc 0 с системным JSON Schema engine. Она исполняется отдельно:
грамматика машинной команды check_sdacha не допускает env первым словом.
Результат отдельного прогона и двух внешних дверей — в докладе этой пачки;
неизмеренный результат не считается зелёным.

NOT_RUN: S (`bash fixtures/workshop_project/odin_agent_140/stancija_odin_agent_140.sh`)
и normalizacija в этой копии. Внешний компонент /zones/ позволяет станционному
коду вывести корни вне своей копии; одной установки TMPDIR недостаточно.
Это предусмотренная граница §Приёмка п.7, а не отмена станционной приёмки:
оркестратор/adversary выполняют S в безопасном checkout после реализации,
ожидая rc 0 и ноль KRASNYH, плюс негативную пробу обманной интеграции rc 1.

NOT_RUN: приёмка будущего production/runtime-потребителя
`python3 fixtures/workshop_project/odin_agent_140/object_140.py --prepare`.
После реализации она должна дать rc 0 на настоящем pre_judge, сохранив отказы
leak/unpublished. Scoped PREPARE_BEFORE прежней пачки не заменяет эту проверку.
Профиль `bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta`,
живой omp-спавн и пронос isolated через интеграцию 199 остаются проверками
реализационной пачки/adversary; здесь NOT_RUN, не модельная зелень.

Порядок неизменен: внешние check_sdacha --run и полный pre_critic → совмещённый
critic → freeze → implementer → adversary → reviewer → проводка/done.
После реализации W/W --stabs/pre_judge должны стать зелёными; оркестратор
переключает CI с предварительного --model на безфлаговую реальную дверь,
материализует gen_ci_steps --write/--check и предъявляет done. До того
зелёный лист подтверждает честные rc и форму, не готовность production.

## Процессная рефлексия

Входной дефект конструкции: заголовок «Двери» без машинных строк скрывал
доступную приёмку за устаревшим средовым блокером. Закрытие — штатная грамматика
check_sdacha и полный pre_critic на точной БАЗЕ, без новых проверяющих механизмов.
Отдельная А-запись не создаётся: общий журнал вне единственного разрешённого
пути этой пачки и допускает запись только в main.
