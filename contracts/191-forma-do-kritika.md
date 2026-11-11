# Контракт 191 — Л1: форма до критика (три ноги формы в двери перед платным судом)

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: обычный — инструмент проверки формы контракта до платного вызова критика; права/роли, авторизация, безопасность, деньги, ПД и юридически значимые действия не меняются.
КОНТЕКСТ: слово владельца 2026-11-11 (перестановка ~20:10): 191 — следующий в полосе А2/А1, ни от чего не зависит; новых предметов не заводить (слово ~19:50). Источник требований — ADOPTION §2 «Л1» (/home/harness/consultant/fable16/out16/ADOPTION.md) и Д§3.1 того же прохода; строка плана registry/plan.tsv:191 (пара 3, архитектура), решение владельца docs/owner/2026-11-11-svyazka-architect-kritik.md. Боль (Факт Д§3.1): дверь «зелёная» совместима с формально красным контрактом — 7 блоков формы и 2 узких платных вызова на потолок ушли платному критику.

## Существующее (сверено живьём 2026-11-11; дерево — истина)

- Дверь scripts/pre_critic.sh несёт ноги (а) precision-gate, (б) spec-ready, (в) Н-39, (д) source-gate 996, (г) форму КОНТЕКСТ:/§Существующее 095, (д2) предпосылки 122, (д3) трек экрана 158, (е) архитектуру 187а — и НЕ зовёт check_threat_model.sh, check_ceilings.sh, check_provodka.sh (замер живого файла: поиск имён трёх гейтов — совпадений нет; Факт Д§3.1). Прецеденты платных находок формы: 185 круг 1 (модель угроз), 176 БК1 (модель угроз), 186 круг 1 (потолки).
- Гейты формы существуют и работают каждый сам по себе: check_threat_model.sh (041) судит форму секции «## Модель угроз» — метки ЗАЩИЩАЕТ:/НЕ ЗАЩИЩАЕТ: своими строками, в каждом списке не меньше одного буллета; check_ceilings.sh (004) судит персоны roles/ не выше 73728 байт и требует у каждого незамороженного черновика contracts/NNN-*.md раздел «Незаполненные требования:» с телом «нет» либо строки, начинающиеся с «- »; check_provodka.sh (038) судит г0 → г0-доп → г1..г6 (существование, грамматика, подключение каналов поля ПРОВОДКА) и режима «только грамматика» не имеет — первый аргумент для него корень (Факт Д§3.1: грамматику каналов до суда проверить нечем, её ловили критики 186 в3 и 188 в2 на копии с заглушками).
- Дверь в приёмках зовут контракты 154, 163, 165, 166, 167, 168, 169, 170, 172, 173, 175, 182, 184, 187, 188 (grep contracts/ живого дерева); сам файл двери как зону несут живые заморозки 072, 094, 095, 103, 122, 158, 184, 187, 996 — пересчёт командой по живым frozen-тегам приведён ниже в ПЕРЕСЕЧЕНИЕ.
- Семантика пропуска — канон ноги (д2) двери: гейт, отсутствующий в корне, пропускается, а не даёт отказ; замер 122 показал, что fail-closed здесь ломает замороженную батарею 072 (её toy-мир копирует подмножество гейтов). Новые ноги наследуют пропуск.
- CLI-шаблон режимов --model/--stabs/--repo батарей — 174/175/182 (заморожены); минимальный перечень обманных реализаций только против новых ветвей — 158 (заморожен); toy-мир канона 072 (подмножество гейтов + package.json + ci.yml) — прецедент fixtures/pre_critic/_toy.sh, копируемый живой батареей 191 в каждый мир.

## Предмет и инварианты

Три ноги формы в существующей двери и грамматический режим существующего гейта проводки (обе зоны implementer). Инварианты:

1. Ноги (ж)/(з)/(и). После существующих ног дверь зовёт в порядке ж → з → и: (ж) bash scripts/check_threat_model.sh BASE CONTRACT; (з) bash scripts/check_ceilings.sh BASE; (и) bash scripts/check_provodka.sh --grammar BASE CONTRACT. BASE — корень двери (ROOT без --repo, R с --repo, резолв 103), CONTRACT — тот же относительный путь контракта.
2. Именованный отказ. Ненулевой rc гейта ноги → rc 1 двери, первая строка stderr «ОТКАЗ: модель угроз красна (rc=N): …» / «ОТКАЗ: потолки красны (rc=N): …» / «ОТКАЗ: проводка красна (rc=N): …», где N — фактический rc гейта, после двоеточия — первая строка его вывода. Критик не зовётся.
3. Fail-closed. Зелёного результата у ненулевого rc гейта не бывает: rc 1 и rc 2 — оба отказ; «нечем проверить» не значит «проверено».
4. Семантика пропуска. Гейт ноги отсутствует в корне (нет исполняемого файла) → нога пропускается молча, не отказ — канон (д2)/(д3); игрушечные миры 072 без гейтов формы ведут себя как раньше.
5. Неизменность существующего: ноги (а)–(е), CLI --repo, rc-семантика и строка «КРИТИК: дверь зелёная» двери 072; обычный режим check_provodka.sh — г0–г6, фразы причин и порядок диагностики дословно.
6. Режим --grammar гейта проводки судит ТОЛЬКО форму поля ПРОВОДКА: наличие поля; канальные строки «- guard=…» / «- role=…» / «- charter=…»; guard-цель — один токен без пробельных символов и кавычек-лапок; role-цель — ровно roles/<роль>.md с норма-строкой «…» без вложенных пар; charter-цель — ровно AGENTS.md §<полный заголовок секции> «…»; поле из одних guard-каналов без строки ПРОВОДКА-ЭНФОРСМЕНТ — отказ. Существование файлов, подключение и наличие норма-строк в ролях НЕ судятся — это обычный режим 038 на done; обычный режим на том же входе красен по-прежнему.
7. Честный черновик с конформной формой проходит дверь rc 0.
8. Привязки обманных реализаций к различающим входам — данными батареи (stabs.tsv), не прозой этого контракта (Н-39): контракт несёт инварианты и rc-команды.

## Приёмка

Батарея семьи fixtures/workshop_project/forma_do_kritika_191/ (13 клеток по прогону, 12 обманных реализаций; mir 8, stabs 12, model 2 — census-строки ниже; замеры прогонов этой пачки на дереве без реализации). Судится реальный субъект: toy-мир каждого случая несёт копии настоящих гейтов формы из дерева и копию субъекта; ожидания сняты в память до вызова.

1. Дано: дерево без реализации предмета (живое дерево до implementer). Когда голый прогон батареи. Тогда rc 1: предметные клетки красны, честные контроли зелёны (замер пачки: KLETKI=13 ZELENYE=3 KRASNYE=10); после реализации та же команда даёт rc 0 (KLETKI=13 ZELENYE=13 KRASNYE=0).
- `bash fixtures/workshop_project/forma_do_kritika_191/red_forma_do_kritika_191.sh` → красная: ИТОГ 191: rc=1 KLETKI=13 ZELENYE=3 KRASNYE=10
2. Дано: честная модель ног (fixtures/workshop_project/forma_do_kritika_191/model/). Когда режим --model. Тогда rc 0, все 13 клеток зелёные.
- `bash fixtures/workshop_project/forma_do_kritika_191/red_forma_do_kritika_191.sh --model`
3. Дано: обманные реализации (stabs/, привязки stabs.tsv). Когда режим --stabs. Тогда rc 0: каждая поймана на своём различающем входе, живых нет (замер пачки: OBMANOK=12 POIMANY=12 ZHIVYH=0).
- `bash fixtures/workshop_project/forma_do_kritika_191/red_forma_do_kritika_191.sh --stabs`
4. Дано: среда без git (PATH только с bash, python3, dirname). Когда та же обёртка. Тогда rc 2 и stderr LIVE_PREDPOSYLKA — именованный отказ зависимости, не тихий пропуск.
5. Правило (именованные отказы двери, после реализации): кандидат с метками модели угроз внутри буллетов → rc 1, маркер «ОТКАЗ: модель угроз красна»; кандидат без раздела «Незаполненные требования:» или с персоной сверх 73728 байт → rc 1, маркер «ОТКАЗ: потолки красны»; кандидат со строкой канала вне грамматики (guard-цель с пояснением в кавычках, вложенные кавычки в норма-строке, charter-цель вне AGENTS.md, строка канала без префикса канала, поле из одних guard-каналов без обоснования) → rc 1, маркер «ОТКАЗ: проводка красна»; rc 2 гейта ноги → rc 1 отказа, никогда rc 0.
6. Правило (грамматический режим, после реализации): bash scripts/check_provodka.sh --grammar <корень> <контракт с несуществующими целями каналов> → rc 0; bash scripts/check_provodka.sh <корень> <тот же контракт> → rc 1 с фразой о несуществующем файле — существование судит обычный режим.
7. Правило (гейты этой пачки на этом контракте): bash scripts/pre_critic.sh contracts/191-forma-do-kritika.md → rc 0; bash scripts/check_threat_model.sh . contracts/191-forma-do-kritika.md → rc 0; bash scripts/check_ceilings.sh . → rc 0; bash scripts/check_precision_gate.sh . contracts/191-forma-do-kritika.md → rc 0. bash scripts/check_provodka.sh . contracts/191-forma-do-kritika.md до подключения CI-строки → rc 1 «guard не подключён»; после строки и замера оркестратора → rc 0.
8. Дано: копия дерева, из которой удалён guard-файл батареи. Когда bash scripts/check_provodka.sh <копия> contracts/191-forma-do-kritika.md. Тогда rc 1 с фразой «проводка: guard-файл не существует» — негативный контроль: отсутствие канала не зелёное.

замер: `ls fixtures/workshop_project/forma_do_kritika_191/model/scripts/*.sh | wc -l` = 2 census fixtures/workshop_project/forma_do_kritika_191/model/scripts/*.sh
замер: `ls fixtures/workshop_project/forma_do_kritika_191/mir/*.md | wc -l` = 8 census fixtures/workshop_project/forma_do_kritika_191/mir/*.md
замер: `ls fixtures/workshop_project/forma_do_kritika_191/stabs/*.sh | wc -l` = 12 census fixtures/workshop_project/forma_do_kritika_191/stabs/*.sh

## Модель угроз

ЗАЩИЩАЕТ:
- именованный отказ двери на неформатной модели угроз, на отсутствии раздела незаполненных требований и превышении потолка, на строке проводки вне грамматики каналов — до платного вызова критика;
- fail-closed ног: rc 2 гейта ноги не даёт зелёного результата двери, «нечем проверить» не значит «проверено»;
- семантику пропуска: отсутствие гейта ноги в чужом игрушечном мире — пропуск ноги, не отказ; мир ведёт себя как раньше;
- судимость грамматики проводки без обращений к файловой системе: черновик до реализации судим по форме, несуществующие цели каналов не красят грамматику;
- неизменность обычного режима гейта проводки и его причин на том же входе.

НЕ ЗАЩИЩАЕТ:
- смысловую полноту модели угроз и адекватность границ списков — суждение критика (граница 041, арбитраж oblast-i-porog);
- триггер «гард введён, а секции модели угроз нет» — класс К-16, суждение критика, в предмет не входит (ADOPTION §2 «Не входит»);
- существование, подключение каналов и норма-строки в ролях на этапе черновика — их судит обычный режим гейта проводки на done;
- враждебное окружение вызывающего процесса сверх закрытых гейтом проводки классов ENV-TRUST/SOURCED-EXEC;
- качество содержимого контракта сверх формы — суждение критика предмета.

## Незаполненные требования:
нет

## Зоны и проводка

ЗОНА architect: contracts/191-forma-do-kritika.md fixtures/workshop_project/forma_do_kritika_191/
ЗОНА implementer: scripts/pre_critic.sh scripts/check_provodka.sh
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_critic.sh — 072 только новые ноги (ж)/(з)/(и) после существующих; ноги (а)–(е), CLI --repo и rc-семантика 072 не меняются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_critic.sh — 094 то же: только новые ноги, семантика 094 не трогается.
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_critic.sh — 095 то же: только новые ноги, нога (г) не меняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_critic.sh — 103 то же: только новые ноги, CLI --repo и резолв корня не меняются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_critic.sh — 122 то же: новые ноги ПОСЛЕ гейта предпосылок (д2), сам гейт не меняется.
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_critic.sh — 158 то же: только новые ноги, нога (д3) и гейт трека не меняются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_critic.sh — 184 то же: только новые ноги, проектные проверки не меняются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_critic.sh — 187 то же: только новые ноги, нога (е) и дверь архитектуры не меняются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/pre_critic.sh — 996 то же: только новые ноги, проектные ноги не меняются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_provodka.sh — 038 только новый режим --grammar; обычный режим, каналы г0–г6, порядок диагностики и фразы не меняются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_provodka.sh — 994 то же: закрытое исключение per-guard wiring не трогается.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 140 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 141 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 142 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 143 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 145 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 146 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 147 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 148 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 149 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 153 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 157 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 158 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 159 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 163 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 166 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 167 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 168 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 169 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 170 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 172 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 173 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 174 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 175 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 182 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 184 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 185 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 186 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 187 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 188 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 189 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 190 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 995 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только новая строка self-test 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 140 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 141 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 142 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 143 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 145 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 146 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 147 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 148 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 149 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 153 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 157 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 158 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 159 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 163 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 166 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 167 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 168 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 169 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 170 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 172 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 173 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 174 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 175 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 182 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 184 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 185 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 186 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 187 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 188 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 189 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 190 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 995 только замер новой строки 191; чужие строки не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 140 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 141 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 142 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 145 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 146 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 147 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 148 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 149 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 153 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 157 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 158 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 159 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 163 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 166 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 167 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 168 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 169 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 170 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 172 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 173 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 174 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 175 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 182 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 184 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 185 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 186 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 187 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 188 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 189 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 190 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 994 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 995 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 997 только производная материализация генератором.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 998 только производная материализация генератором.

ПРЕДПОСЫЛКИ:
- setting CI харнесса уже предоставляет bash, Python 3 и git; toy-миры батареи создаются под TMPDIR и не ходят в сеть; новых secrets, variables, environments и настроек репозитория нет.

Порядок: контракт и красная семья (эта пачка; красное предъявление предъявлено красным до суда) → pre_critic → critic → freeze → implementer (ноги (ж)/(з)/(и) и режим --grammar одним вертикальным срезом) → orchestrator (CI-строка и замер) → reviewer → done.

ПРОВОДКА:
- guard=fixtures/workshop_project/forma_do_kritika_191/red_forma_do_kritika_191.sh

ПРОВОДКА-ЭНФОРСМЕНТ: предмет 191 — чистый энфорсмент (три ноги формы в существующей двери и грамматический режим существующего гейта проводки); поведенческих норм ролей контракт не вводит, канал один — guard: раннер семьи forma_do_kritika_191 (red_* вне case_*-глоба раннера verify_antiplacebo, прецеденты 059/083). Строку step батареи 191 в registry/ci-steps.tsv и её замер в registry/ci-zamery.tsv коммитит orchestrator в окне freeze..done (норма «Проводка CI — оркестратором», слово владельца 2026-10-25), затем bash scripts/gen_ci_steps.sh --check → rc 0; до подключения строки rc 1 «guard не подключён» — заявленное состояние черновика (прецеденты 154/158).
