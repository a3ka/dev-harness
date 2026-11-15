# Контракт 188 — 187б: роли по архитектуре

КЛАСС ЗАДАЧИ: doc/role — нормы ролей и структурная проверка их наличия.
КЛАСС РИСКА: обычный — инструкции процесса, без изменения прав/ролей БД, авторизации, денег, ПД/health-данных и согласий или юридически значимых действий.
КОНТЕКСТ: Н-442 (архитектура не дошла до ролей процесса), слово владельца 2026-11-10 ~20:40 (разрез 187а/188), `/home/harness/consultant/plan-doc.md` §Восстановлено пп. 1, 6–8, 13–15 и Fable-11 §1 (только чтение).
ВЕРСИЯ: v2 — адресный v+1 frozen/contracts/188/1 (слово владельца 2026-11-11 ~12:20 UTC через консультанта: «188 v+1 ДА: в ЗОНУ добавить `roles/implementer-glm.md` (парный файл implementer — та же вставка норм 188)»); дельта v+1 — раздел «Адресный v+1» ниже, суд критика по дельте.

## Существующее

- `roles/architect.md`, `roles/critic.md`, `roles/implementer.md`, `roles/adversary.md`, `roles/reviewer.md`, `roles/arbiter.md`, `roles/orchestrator.md` несут действующие шаги авторов и судей; в них пока нет выделенного обязательного блока норм 188 (реализация PR #771 `wip/188/orchestrator` вставляет, не влита). `scripts/roles.ts` и `scripts/gen-harness.ts` порождают соответствующие `.omp/agents/*.md`; после правки ролей implementer перегенерирует ровно их. Вывод батареи `--repo .` до работы implementer (main): rc 1, `CELLS=22 GREEN=1` — 21 литеральная клетка красна, клетка пары зелена (тела равны, пока норм нет нигде).
- `roles/implementer-glm.md` — парная роль implementer (998, регистр routing: тот же исполнитель на другой модели `task-glm`); её тело обязано быть байт-в-байт с телом `roles/implementer.md` (кейс `role_pair_glm` пробы `fixtures/pravila_modelei_998/probe.py`: `composition_violations` → «тело roles/implementer-glm.md не байт-в-байт с roles/implementer.md»), frontmatter расходится только полем `role:`. Пара поддерживается парными вставками (прецедент 996: коммит 53b9cbc5d внёс ту же секцию в пару с маркером базового файла). Реализация 188 (PR #771) вставила нормы в `roles/implementer.md`, но не в пару — CI `check:pravila-modelei-998` красный по `role_pair_glm` (воспроизведено локально на `wip/188/orchestrator`; на main расхождений 0). Прежние владельцы glm-файлов по замороженным зонам — только 998 (скан всех 311 тегов `frozen/contracts/*`, vmax каждого из 169 контрактов: явные упоминания `roles/implementer-glm.md` и `.omp/agents/implementer-glm.md` — `frozen/contracts/998/1` ЗОНА implementer, для агента также ПЕРЕСЕЧЕНИЯ 002/003/005/010/011 как производная генератора).
- 170 уже подаёт compact brief; 095 доставляет контекст. 187а — механические ворота `make_task`/`pre_critic`/`freeze_contract`/`done_contract`/`check_architecture_contract`, не этот предмет. 186 — отдельная роль `architecture-steward`, таймер и дверь L1-слияния; его потребитель планового сигнала в `roles/orchestrator.md` должен сохраниться. `registry/plan.tsv` и owner-план называют этапы, но не заменяют бриф/модель.
- `scripts/check_provodka.sh` сверяет литеральные строки каналов `role=` с файлом роли; `scripts/check_ceilings.sh` ограничивает байты персоны (в текущем дереве 61440, owner-решение ~20:44 повышает до 73728 отдельным PR #743). Текущие размеры ролей в байтах (`wc -c`, порядок в ЗОНА ниже): architect 47196, critic 41231, implementer 10451, adversary 7921, reviewer 15643, arbiter 9016, orchestrator 61353. До публикации #743 для orchestrator остаётся лишь 87 байт — реализация 188 после #743, не сокращением чужих норм. Оценочный бюджет добавления: по одной короткой секции на роль; итоговый прирост измеряется по `wc -c` перед сдачей implementer.
- Семьи `fixtures/workshop_project/arch_component_170/` и `architecture_process_187/` уже проверяют бриф/ворота; новый bash entrypoint проверяет только наличие отдельной нормы в своей роли. `fixtures/workshop_project/plan_restart_182/red_plan_restart_182.sh` — действующий шаблон CLI `--model/--stabs/--repo`. Frozen-зоны ниже прочитаны из `frozen/contracts/<NNN>/<vmax>^{commit}` (не из памяти/живого черновика).

## Адресный v+1 — пара implementer-glm (998)

Дельта v2 ровно одна: ЗОНА implementer пополняется парой `roles/implementer-glm.md` и производным `.omp/agents/implementer-glm.md` (генерат `npm run gen:harness`; в ЗОНЕ v1 оба отсутствовали — `.omp/agents/*` перечислены поимённо, glm-агента среди них нет). Вставка в пару — та же секция `## Архитектура 188` байт-в-байт с секцией `roles/implementer.md`, включая маркер `Норма-строка (ПРОВОДКА roles/implementer.md, заморожена 188/1):` базового файла (прецедент парного переноса 996, коммит 53b9cbc5d) — иначе тело пары разойдётся с пином `role_pair_glm` 998; frontmatter пары не меняется (поле `role: implementer-glm`). Чужие нормы 998 в паре неизменны.

Инварианты батареи (единый источник литералов не дублируется: координаты пары выводятся из строк implementer расширением получателя в коде пробы):
- литералы 188 в glm-файле идентичны литералам implementer: 4 литеральные координаты `implementer-glm/finding|placement|engine|bindings` тем же механизмом раздела и маркера;
- клетка `implementer-glm/pair`: тело glm-файла байт-в-байт равно телу implementer.md (семантика `split_role_file` пробы 998) — ловит расхождение любым байтом, вне литералов включительно; на main зелена (тела равны в отсутствии норм), на реализации PR #771 без вставки в пару — красна.
- Обманные glm-тела и их различающие входы: норма только в implementer.md (glm-файл без секции) — различима литеральной координатой пары и клеткой пары; лишний байт в теле пары вне литералов — различима ТОЛЬКО клеткой пары (литеральные координаты пары зелёны); литерал пары в комментарии/fence/необязательном разделе glm-файла — различима своей литеральной координатой пары. Прежние 17 координат и 8 предъявлений неизменны.

rc-команды дельты (`W=bash fixtures/workshop_project/roles_architecture_188/red_roles_architecture_188.sh`):
- `W --model` → rc 0, `CELLS=22 HONEST=22 RED_NEGATIVES=22 HTML_NEGATIVES=22 FENCE_NEGATIVES=22`;
- `W --stabs` → rc 0, `STABS=13 CAUGHT=13` (8 прежних + 5 пары), каждая мутация пары — на своём входе выше, `ZHIV` нет; встроенный `--repo` на честной модели с одной скрытой нормой — rc 1, `CELLS=22 GREEN=21`, единственная RED — `architect/cells`;
- `W --repo .` на main → rc 1, `CELLS=22 GREEN=1` (зелена только клетка пары); на реализации 188 без вставки в glm-файл (PR #771) → rc 1, `CELLS=22 GREEN=17`, красны 4 литеральные glm-координаты и клетка пары; после вставки в пару → rc 0, `CELLS=22 GREEN=22`.
- `bash scripts/check_provodka.sh . contracts/188-roli-po-arhitekture.md`: четыре новых role-канала `roles/implementer-glm.md` красны до вставки в пару (норма-строка не найдена в role-файле) — ожидаемое красное до implementer, как и 17 каналов v1 до их вставки; после вставки rc 0 по всем 21 role-каналу и guard-каналу.

## Предмет и frontier

Один результат: каждая из семи ролей получает свою строку архитектурной обязанности в выделенном `## Архитектура 188` с самостоятельной `Норма-строка (ПРОВОДКА roles/<роль>.md, заморожена 188/1):`; пять ролей получают также общую строку «находку командой, не руками»; каждый литерал задан единожды в `fixtures/workshop_project/roles_architecture_188/norms.tsv` и цитируется далее в ПРОВОДКЕ. Пара `roles/implementer-glm.md` получает ту же вставку байт-в-байт (раздел «Адресный v+1»). В комплекте 22 координаты (5 командных + architect 1 + critic 1 + implementer 3 + adversary 1 + reviewer 1 + arbiter 1 + orchestrator 4 + пара implementer-glm 4 + клетка равенства тел пары 1); каждый из 22 отдельных пропусков красен своей клеткой.

Frontier: (а) отдельные короткие ролевые инструкции с исполненным role-каналом и CI-батареей; (б) один общий абзац в роли оркестратора со ссылкой «судьи помнят правила». Выбрано (а): Н-442 показала, что роли кодового контракта достигли судей без архитектурного контроля; ссылка в чужой роли не даёт agent-у этой роли операционного шага. Цена — семь role-дельт и производные `.omp/agents`, без новых ворот 187 или хранения модели 186. 188 не утверждает, что текст роли или совпадение строки доказывают содержание конкретной операции либо слияние PR.

Кодовый backend-архитектурный предмет получает brief из закреплённой версии по 170/187: с правилами architect/critic/arbiter, без правил implementer/adversary/reviewer. Литерал `АРХИТЕКТУРА:` оркестратора обозначает формат ЗАДАНИЯ; контрактную грамматику и отказы исполняет 187а. Находка создаётся командой `node tooling/checks/cli.js finding new <slug> --input <six-field.json>` (шесть полей и L1/L2/L3; номер выдаёт механизм), не ручным файлом/номером; невозможность вызвать CLI — стоп и доклад, не ручная заглушка. Модель меняют отдельным обоснованным коммитом с diff, никогда задним числом под код; новая находка не добавляется в долг. Связанные PR — процессная норма; механическая дверь пары PR/сверки ссылок из пп.13–15 не строится в 188 (cognitive-only, ловец reviewer/owner в реальных PR).

## Позиция автора после вызова 1/2

СОГЛАСЕН: HTML-комментарий из вердикта критика оставляет роль без самостоятельной нормы, а прежняя батарея давала rc 0. Исправление исключает скрытые строки из проверки и предъявляет многострочный комментарий через вход `--repo` на копии честных ролей.

## Позиция автора после вызова 2/2

СОГЛАСЕН: вложенные «…» в двух role-цитатах не проходят грамматику `check_provodka.sh`, поэтому честные роли не могли выполнить критерий rc 0. Заменены только внутренние кавычки в обоих литералах единого `norms.tsv` и соответствующих строках ПРОВОДКИ; смысл обязанностей сохранён. Честный контроль проверяется на отдельной копии дерева с семью ролями и подключённым guard.

## Модель угроз

ЗАЩИЩАЕТ:
- От отсутствия обязательной нормы роли или переноса её в чужую роль, HTML-комментарий (одно- и многострочный), fenced code, прозу, необязательную секцию: структурная проверка 22 независимых координат читает конкретный файл и один обязательный раздел. Строка внутри обратных кавычек, `[//]: #` или цитаты `> ` не равна точному литералу и также отсутствует; видимая самостоятельная строка вне комментария и code fence допустима.
- От потери общего командного маршрута находок у одного из пяти участников и от потери по отдельности обязанностей исполнителя, арбитра и оркестратора при изменении файла роли.
- От вставки норм 188 только в `roles/implementer.md` при расходящейся паре `roles/implementer-glm.md` (v+1): четыре литеральные координаты пары требуют те же литералы в обязательном разделе glm-файла, клетка `implementer-glm/pair` — байт-в-байт равенство тел пары (пин 998), включая произвольное расхождение вне литералов.
НЕ ЗАЩИЩАЕТ:
- От исполнения норм агентом, правдивости архитектуры/брифа/отчёта движка, факта вызова CLI или реального слияния пары PR: проверка статична, поведение судится существующими воротами 186/187 и живым reviewer; остаточный риск двух связанных PR — cognitive-only до отдельного предмета.
- От подмены самого `norms.tsv` вместе с ролью злонамеренным автором; protected зона, critic и reviewer обязаны сверять смысл изменений, норм-строки role-канала побайтово проверяет `check_provodka.sh`.
- От синхронной вставки в роли, не входящие в 998-пару (например `roles/implementer-vision.md`, пином не охвачена и в v2 не трогается): клетка пары судит ровно два файла implementer/implementer-glm.

## Приёмочный критерий

- Дано: `norms.tsv` как оракул в памяти и честные тексты семи ролей с маркером и литералами в обязательном разделе, пара glm с тем же телом байт-в-байт; когда `bash fixtures/workshop_project/roles_architecture_188/red_roles_architecture_188.sh --model`; тогда rc 0, `CELLS=22 HONEST=22 RED_NEGATIVES=22 HTML_NEGATIVES=22 FENCE_NEGATIVES=22`: честный контроль и независимое удаление/скрытие в комментарии/скрытие в fenced code каждой координаты, включая координаты пары; самостоятельная строка после закрытого code fence остаётся допустимой.
- Дано: отдельная обманная роль с нормой не в своей роли/HTML-комментарием (одно- и многострочным)/fenced code/опечаткой/необязательной секцией/прозой и обманные glm-тела (норма только в implementer.md; лишний байт вне литералов; литерал в комментарии/fence/необязательном разделе glm-файла); когда та же команда `--stabs`; тогда rc 0, `STABS=13 CAUGHT=13`: реальный `--repo` на копии честных ролей с единственным литералом только внутри многострочного HTML-комментария возвращает rc 1, `CELLS=22 GREEN=21`, единственная RED-координата — `architect/cells`; у каждого предъявления свой различающий вход в коде и ни одного `ZHIV`.
- Дано: существующие `roles/*.md` до implementer (main); когда та же команда `--repo .` (также CI-вход без аргумента); тогда rc 1, `CELLS=22 GREEN=1` — имена всех отсутствующих координат, зелена только клетка пары (тела равны в отсутствии норм). Дано: реализация 188 без вставки в glm-файл (состояние PR #771); тогда rc 1, `CELLS=22 GREEN=17`, красны 4 литеральные glm-координаты и клетка пары. Дано: после implementer в каждой роли и в паре самостоятельная строка внутри её обязательного раздела с точным маркером и процитированным литералом; та же команда → rc 0, `CELLS=22 GREEN=22`; удаление любого одного литерала в копии роли → rc 1 по её координате, без зелёного по первым соседям.
- Правило: `npm run gen:harness` перегенерирует `.omp/agents/*.md` (включая `.omp/agents/implementer-glm.md`) по обновлённым ролям, затем `npm run check:gen` → rc 0; `bash scripts/check_provodka.sh . contracts/188-roli-po-arhitekture.md` и `bash scripts/check_ceilings.sh` → rc 0 после публикации #743 (role-каналы glm красны до вставки пары — намеренное красное, как 17 каналов v1). До критика: `bash scripts/pre_critic.sh contracts/188-roli-po-arhitekture.md` и `bash scripts/check_precision_gate.sh . contracts/188-roli-po-arhitekture.md` → rc 0; отсутствие новых норм до implementer — намеренный rc 1 `--repo`, не ложный зелёный.

ПРЕДПОСЫЛКИ:
- setting CI харнесса предоставляет bash и Python 3; новый шаг не требует secrets/variables/environments, а обновление потолка персон #743 публикуется до реализации 188.

## Незаполненные требования:
нет

## Зоны и проводка

ЗОНА architect: contracts/188-roli-po-arhitekture.md fixtures/workshop_project/roles_architecture_188/
ЗОНА implementer: roles/architect.md roles/critic.md roles/implementer.md roles/implementer-glm.md roles/adversary.md roles/reviewer.md roles/arbiter.md roles/orchestrator.md .omp/agents/architect.md .omp/agents/critic.md .omp/agents/implementer.md .omp/agents/implementer-glm.md .omp/agents/adversary.md .omp/agents/reviewer.md .omp/agents/arbiter.md .omp/agents/orchestrator.md
ПЕРЕСЕЧЕНИЕ implementer: roles/implementer-glm.md — 998 пин role_pair_glm: тело байт-в-байт с roles/implementer.md; только вставка норм 188 той же секцией с маркером базового файла (прецедент 53b9cbc5d), чужие нормы 998 неизменны.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/implementer-glm.md — 998 производная роли из roles/, перегенерируется генератором; только пересборка роли 188.
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 186 только вызов по done/блокирующей находке, сигнал планового таймера 186 не меняется; роль 188 вливать после 186.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 186 только пересборка от новой роли 188 после 186, плановый сигнал сохраняется.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 187 только нормы 188, двери 187а не меняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 187 только нормы 188, двери 187а не меняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/adversary.md — 187 только нормы 188, двери 187а не меняются.
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 187 только нормы 188, двери 187а не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только новый шаг `roles_architecture_188`; чужие строки сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 188, чужие строки сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только сгенерированный шаг 188; чужие шаги сохраняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только сгенерированный шаг 188.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/architect.md — 016 только пересборка роли 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/architect.md — 050 только пересборка роли 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 050 только пересборка роли 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 061 только пересборка роли 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 068 только пересборка роли 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/orchestrator.md — 069 только пересборка роли 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: .omp/agents/reviewer.md — 050 только пересборка роли 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только новая строка шага 188.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только новая строка шага 188.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только новая строка шага 188.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только новая строка шага 188.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только новая строка шага 188.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только новая строка шага 188.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только новая строка шага 188.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только новая строка шага 188.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только новая строка шага 188.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только новая строка шага 188.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только новая строка шага 188.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только новая строка шага 188.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только новая строка шага 188.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только новая строка шага 188.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только новая строка шага 188.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только новая строка шага 188.
ПЕРЕСЕЧЕНИЕ implementer: roles/arbiter.md — 002 только норма архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 002 только норма архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 003 только норма архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 010 только норма архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 016 только норма архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 037 только норма архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 038 только норма архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 041 только норма архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 050 только норма архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/architect.md — 066 только норма архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 036 только шестой архитектурный вопрос, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 041 только шестой архитектурный вопрос, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/critic.md — 043 только шестой архитектурный вопрос, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/implementer.md — 002 только нормы архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/implementer.md — 003 только нормы архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/implementer.md — 027 только нормы архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 010 только нормы архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 026 только нормы архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 027 только нормы архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 028 только нормы архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 029 только нормы архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 031 только нормы архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 037 только нормы архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 038 только нормы архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 050 только нормы архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 061 только нормы архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 068 только нормы архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 069 только нормы архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/orchestrator.md — 100 только нормы архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 027 только сверка архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 038 только сверка архитектуры 188, прежние нормы сохранены.
ПЕРЕСЕЧЕНИЕ implementer: roles/reviewer.md — 050 только сверка архитектуры 188, прежние нормы сохранены.
CI-проводку собственного шага и его замер orchestrator коммитит после freeze: `gen_ci_steps.sh --write`, `--check` rc 0; `step` вызывает `bash fixtures/workshop_project/roles_architecture_188/red_roles_architecture_188.sh --repo .`, а не внутренний `probe.py`.

ПРОВОДКА:
- guard=fixtures/workshop_project/roles_architecture_188/red_roles_architecture_188.sh
- role=roles/architect.md «Обнаружив расхождение модели и работы, создай находку командой `node tooling/checks/cli.js finding new <slug> --input <six-field.json>` (шесть полей, уровень L1/L2/L3, номер выдаётся под lock); не нумеруй вручную, не заглушай находку и не узаконивай код подгонкой модели.»
- role=roles/critic.md «Обнаружив расхождение модели и работы, создай находку командой `node tooling/checks/cli.js finding new <slug> --input <six-field.json>` (шесть полей, уровень L1/L2/L3, номер выдаётся под lock); не нумеруй вручную, не заглушай находку и не узаконивай код подгонкой модели.»
- role=roles/implementer.md «Обнаружив расхождение модели и работы, создай находку командой `node tooling/checks/cli.js finding new <slug> --input <six-field.json>` (шесть полей, уровень L1/L2/L3, номер выдаётся под lock); не нумеруй вручную, не заглушай находку и не узаконивай код подгонкой модели.»
- role=roles/adversary.md «Обнаружив расхождение модели и работы, создай находку командой `node tooling/checks/cli.js finding new <slug> --input <six-field.json>` (шесть полей, уровень L1/L2/L3, номер выдаётся под lock); не нумеруй вручную, не заглушай находку и не узаконивай код подгонкой модели.»
- role=roles/reviewer.md «Обнаружив расхождение модели и работы, создай находку командой `node tooling/checks/cli.js finding new <slug> --input <six-field.json>` (шесть полей, уровень L1/L2/L3, номер выдаётся под lock); не нумеруй вручную, не заглушай находку и не узаконивай код подгонкой модели.»
- role=roles/architect.md «Для кодового предмета выводи красные клетки из схем операций, `semanticInvariant`, `writers` и `isolationKeys` брифа с правилами; мутации "второй писатель" и "чужой scope_id" проверяй раздельно, DRAFT без схемы до заморозки не допускай.»
- role=roles/critic.md «Шестой вопрос кодового предмета: сверь контракт с брифом с правилами — операции и схемы не DRAFT, каждой схеме и инварианту есть клетка, новые `consumes` и `writers` объявлены, уровень правки модели подтверждён `check --base`; противоречие блокирует accept.»
- role=roles/implementer.md «Код размещай только в `implementationPathHint` своего компонента; чужие зависимости — только через объявленные `consumes`, таблицы пишет только назначенный `writers` своего ресурса; при расхождении остановись и передай находку, не меняй модель в кодовом PR.»
- role=roles/implementer.md «Перед push локально запусти `ARCHITECTURE_ROOT=<клон архитектуры> node tests/tools/run-arch.js`; красное исправь в коде либо остановись и доложи оркестратору, не пополняя долг новой находкой.»
- role=roles/implementer.md «Новые привязки функции к операции заноси в `bindings.json` в том же PR, в котором меняется код; имя операции и схема берутся из закреплённого брифа.»
- role=roles/implementer-glm.md «Обнаружив расхождение модели и работы, создай находку командой `node tooling/checks/cli.js finding new <slug> --input <six-field.json>` (шесть полей, уровень L1/L2/L3, номер выдаётся под lock); не нумеруй вручную, не заглушай находку и не узаконивай код подгонкой модели.»
- role=roles/implementer-glm.md «Код размещай только в `implementationPathHint` своего компонента; чужие зависимости — только через объявленные `consumes`, таблицы пишет только назначенный `writers` своего ресурса; при расхождении остановись и передай находку, не меняй модель в кодовом PR.»
- role=roles/implementer-glm.md «Перед push локально запусти `ARCHITECTURE_ROOT=<клон архитектуры> node tests/tools/run-arch.js`; красное исправь в коде либо остановись и доложи оркестратору, не пополняя долг новой находкой.»
- role=roles/implementer-glm.md «Новые привязки функции к операции заноси в `bindings.json` в том же PR, в котором меняется код; имя операции и схема берутся из закреплённого брифа.»
- role=roles/adversary.md «Испытай архитектурные заглушки по отдельности: второй писатель ресурса, прямой SQL из `app/api`, обход `consumes`, чтение без `scope_id` и новую форму обхода движка; зелёный обход — находка хранителю, а не расширение долга.»
- role=roles/reviewer.md «В вердикте напиши самостоятельную строку `СВЕРКА-АРХИТЕКТУРЫ:` с выводом по размещению, зависимостям, писателям, операциям, `bindings.json`, нерасширению долга и уровню diff модели; L2/L3 без решения владельца не принимай.»
- role=roles/arbiter.md «Получив бриф с правилами и обе позиции, разрешай спор "код или модель" на уровне L1/L2 с проверкой `check --base`; L3 (данные, полномочия, ресурсы) возвращай владельцу одним вопросом и рекомендованным ответом.»
- role=roles/orchestrator.md «В кодовом задании называй компоненты и уровень строкой `АРХИТЕКТУРА: L1|L2|L3 <id,…>` по закреплённому брифу; L3 сначала передай владельцу, не открывая предмет без его ответа.»
- role=roles/orchestrator.md «Для архитектурной дельты веди два связанных PR с одним `COMPLIOR-<NNN>` в заголовках, взаимными ссылками и тем же `workItem` в `architecture.lock.json`: модель сливается первой, продукт закрепляет точный commit слияния; при смене checker/профилей/привязок пересобери базу долга в том же PR только сужаясь.»
- role=roles/orchestrator.md «L1 PR архитектуры сливает назначенный мейнтейнер — оркестратор станции — через дверь 186, автор сам свой PR не сливает; L2/L3 без записи владельца не сливать; откат пина делай только через reviewed forward revert.»
- role=roles/orchestrator.md «После done каждого Э-этапа и немедленно при блокирующей архитектурной находке вызывай `architecture-steward` для обзора среза/разбора находки; плановый сигнал хранителя по 186 остаётся отдельным триггером.»
ПРОВОДКА-ЭНФОРСМЕНТ: bash-барьер доказывает только точное наличие каждой цитаты в конкретной роли и обязательном разделе; самостоятельные действия/выводы ролей cognitive-only, их ловят реальные судьи и owner.
