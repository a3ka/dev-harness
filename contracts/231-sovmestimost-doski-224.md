# Контракт 231 — совместимость входов двери done: старые имена, точка ПРОДУКТ и вызов без vyzov

СТАТУС: ЧЕРНОВИК — конфликт frozen 224 раскрыт ниже; без решения владельца не замораживать и не реализовывать production.
КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: рисковый — авторизация приёмки: неверный выбор свежего суда даёт ложный done.
ПРОДУКТ: станция
АРХИТЕКТУРА: н/п — ремонт станционного писателя без продуктовой модели 188.
КОНТЕКСТ: затравка owner contracts/231-sovmestimost-doski-224.md на базе 568f0ea63271e3461b574105cba8faec7563a8fd; задание task-architect231.md с обоими дополнениями, консультант m2534/m2538/m2541. SourceCanon не объявлен.
СДАЧА: fixtures/workshop_project/done_round_compat_231/SDACHA.md

## Существующее

База 568f0ea63271e3461b574105cba8faec7563a8fd; затравка/slug сохранены. Сверены 224 и frozen/224/1 (69b88241882320d67c007830dfdc343cf5739d14), scripts/done_contract.sh, семья svezhest_verdikta_done_224, 201, contracts/213-posledniy-fail-fazy.md и scripts/lib_karta_sdachi.sh. 213 пока затравка, не выполненный ремонт: её предмет — последний FAIL фазы листа, не done. Реестр registry/plan.tsv на базе НЕ несёт 231; номер уже выдан (registry/contracts.tsv, id/CONTRACT/231). Строку плана добавляет владелец.

- Общий _select_round_verdict читает HEAD для review/adversary, возвращает файл/CID/первую строку. Дорабатывается он; второго селектора нет. F/CID/OBJECT, same-OBJECT, workflowPaths, ARCH_CI сохраняются.
- Миры 201 и install 224 переиспользуются read-only, ожидания 231 — собственные литералы. Reference копирует дверь названной базы с точечной дельтой, не разрешает откатить последующую production.
- frozen/215/1:contracts/215-otkaz-po-soderzhaniyu-zapasnaya.md:5 несёт «ПРОДУКТ: станция.». Клетка переносит ВЕСЬ текст без изменений, настоящую guard/role-проводку и заканчивает annotated done.
- verdicts/review/contracts-227-impl-v1.md:1–3 на базе несёт accept, OBJECT, вызов=2 без поколения фазы. Клетка переносит полный blob, меняя только OBJECT на реальный; парный adversary меняет также поле роли.
- context.py этой семьи читает высшие frozen-блобы, печатает commit и реальные зоны. Сверены 038/2,094/2,168/1,184/1,187/3,201/1,223/1,224/1,226/1,992/2,996/2. Читатель scripts/check_spec_ready.sh вызывается ниже.
- Поиск wip: ветки 224 и собственная 231. Открытые PR по gh pr list --repo a3ka/dev-harness относятся к 223/218/226/044; готового ремонта 231 нет.

## Боль

Замер консультанта m2534: /8 отказывает VERDICT_ROUND_MISSING на backend impl-1/2/5, где /7 проходил. Замеры m2538/m2541: frozen 215 не проходит ПРОДУКТ с точкой; review 227 вызов=2 в impl-v1 получает VERDICT_ROUND_CONFLICT. Пользовательские отказы приняты как факт и не перепроверяются на живых продуктах. Красные клетки воспроизводят класс в автономных Git-мирах, не изменяя судебных артефактов проектов задним числом.

## Предмет

Один наблюдаемый результат: тот же публичный CLI `bash scripts/done_contract.sh <контракт> <причина> [корень]` принимает три исторических представления без переименований и без ослабления позднего FAIL/дублей/F/OBJECT. Наблюдение: rc, раздельные трубы, annotated done-тег на исходном HEAD; при отказе тега нет и HEAD неизменен. Тип доказательства — поведенческий; context доказывает только происхождение зон.

Порядок: решение конфликта frozen → critic → freeze → implementer только scripts/done_contract.sh → orchestrator свой CI-шаг/замер → рисковый суд реализации и reviewer → land → done. Предписанный путь А (один PR, без v+1 224/215) не выдаётся за уже разрешённое изменение frozen. Production и судебные файлы этой architect-пачкой не меняются.

## Конфликт с 224

ДА. frozen/contracts/224/1^{commit}:contracts/224-svezhest-verdikta-done.md:45 (И1) требует MISSING среди нескольких безномерных носителей. Явных legacy impl-N/impl-krugN там нет, отдельной клетки на них нет. review-missing/adversary-missing используют impl-final (probe.py:281–285,318–325) и остаются отказными; расширение известных форм меняет замкнутую грамматику И1.

Прямой конфликт третьего дополнения: frozen 224:46 (И2) требует «Без поколения фазы объявленный вызов общей формы совпадает с N»; :48 (И4) требует CONFLICT при несовпадении. Семья 224 probe.py:285 задаёт impl-v4 с вызов=3; :318–325 требует CONFLICT в review-conflict/adversary-conflict. По 231 одиночный такой носитель допустим, а в старом двухносительном мире оба объявляют вызов=3 → DUPLICATE, НЕ CONFLICT. --regression224 исполняет старую батарею без правок и возвращает сырой rc: её краснота НЕ зелёный регресс.

Ещё прямой конфликт: frozen/contracts/201/1^{commit}:contracts/201-done-dver-soderzhatelnaja-sverka.md:54 требует станционный литерал БЕЗ хвоста; точка из 215 расширяет эту грамматику. 215 собственного отказа на точку не требует.

Путь А требует слова владельца (адресное разрешение конфликтов либо v+1 соответствующих обязательств). Architect его не пишет. Совокупная приёмка «224 неизменно зелёный» до решения недостижима; диагноз нельзя подменить ради зелени. Frozen и прежние клетки не редактируются.

## Инварианты

1. Кандидаты — прежние HEAD-пути workflowPaths.verdicts/{review,adversary}/contracts-NNN-*.md. Канонический N/V/K/M — ASCII [1-9][0-9]{0,8}, без нуля/ведущих нулей. Новые формы (точный конец .md): impl-N и impl-krugN дают круг N, impl.md даёт 1, в том числе среди нескольких; без поля вызов имя достаточно. У этих legacy-форм объявленный вызов обязан буквально совпасть с N/1; оба порядка несовпадения — rc 1 VERDICT_ROUND_CONFLICT с ролью и полным путём. Неканонические impl-0/impl-01/impl-/impl-krug0/impl-v0 и число длиннее девяти цифр — VERDICT_ROUND_INVALID. Неизвестный безномерный суффикс среди нескольких — VERDICT_ROUND_MISSING; прежний singleton без номера остаётся тривиально свежим.
2. Обычная форма -vN[-S].md (включая impl-vN), S=[A-Za-z0-9._-]+: имя НЕ объявляет вызов. Единственный канонический вызов=K в СУД при отсутствии поколения фазы даёт ключ (K,0); без вызова — (N,0). Поэтому impl-v1 с вызов=2 и impl-v5 с вызов=1 допустимы. Имена legacy из И1 по-прежнему сверяются и не получают обхода через это правило. Номера берутся не из произвольной прозы/дат/OBJECT.
3. Сохраняются прежние формы impl-aN и явная impl-vV-vyzovK: последняя разбирается первой и даёт (V,K), её объявленный вызов обязан совпасть с K. Поддерживаемое поколение СУД («фаза=реализация vV» либо прежнее «реализация…круг V») вместе с вызов=K даёт (V,K), как frozen 224; конфликт явного V/K, поколение без вызова — CONFLICT. У legacy-имени проверка его собственного N происходит ДО применения поколения фазы. Обычный v-носитель с поколением фазы не сверяет K с номером имени.
4. Все объявления поддерживаемых полей СУД проверяются по прежней грамматике 224: самостоятельная строка СУД:, границы полей начало/пробел/;, вызов=N либо N/M, стандартная Gregorian дата. Повтор даже равного вызова/поколения/даты, неконформное число или дата и противоречие явному vyzov — CONFLICT. Пояснения после пробела, неизвестные поля и фаза без поколения остаются свободными. Нет СУД/вызова — допустим filename-only.
5. Единственный максимальный ЧИСЛОВОЙ ключ выбирает свежего отдельно для review/adversary независимо от ancestry носителей/лексики/даты коммита/mtime/полярности. Два одинаковых ключа — VERDICT_ROUND_DUPLICATE, также два accept и разные формы имён одного вызова. Проверки date-order и первой строки trim+fold accept сохраняются; свежий FAIL/ESCALATE не заменяется старым accept. Нечитаемый blob/история не становится пропуском; остальные отказы и связи frozen→CID/OBJECT/same-OBJECT остаются прежними.
6. В frozen ПРОДУКТ дополнительно допустима ровно самостоятельная строка `ПРОДУКТ: станция.`; это ровно значение станция. `ПРОДУКТ: станция` остаётся допустимым. Двойная точка, станция.x, хвост, лишние пробелы, иной регистр — прежний отказ «done: строка ПРОДУКТ: вне грамматики: <полная строка>». ПРОДУКТ owner/repo. НЕ нормализуется: прежняя грамматика [A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+ уже допускает это как буквальное имя репозитория с точкой. Удаление байта изменило бы адрес внешнего продукта; без такого поручения сохраняются прежние байты/внешняя проверка. Это не станционная реализация, для локального OBJECT сохраняется отказ «OBJECT разрешается в репо станции, а контракт объявил продукт …». Идентификаторы проектов/номеров 181/179/218/215/227 в production не зашиваются.

## Приёмочный критерий

B = `bash fixtures/workshop_project/done_round_compat_231/red_done_round_compat_231.sh`. Шов подтверждён заданием: полный настоящий CLI. Git-миры имеют настоящий F/OBJECT, независимые носители с merge-base в обе стороны до субъекта, профильные и станционные пути. Ожидания/HEAD/хеши carrier сняты в память ДО запуска. Диагноз проверяется целой строкой со структурой роли/пути, не произвольной подстрокой. Ожидания не перечитываются с диска субъекта.

Н-39 дословно: стабы к ветвям привязывает architect по коду, НЕ проза контракта; контракт несёт инварианты + rc-команды. Единый реестр связей — MUTATIONS/build.py → source.json/stabs.tsv; каждая связь исполняется самостоятельно. Syntax/среда/непостроенный мир — rc 2 NOT_IMPLEMENTED, не поимка дефекта.

- Дано неизменённая дверь на базе; когда B --repo .; тогда rc 1, собственные именованные красные совместимости. После реализации та же команда — rc 0, KRASNYH 0, положительные формы ставят annotated done, отрицательные не ставят тег.
- Правило честного контроля и различимости: B --model и B --stabs — каждый rc 0, непустой каталог, ZHIVYH 0. Честные legacy с совпадающим вызовом/без него и v-формы с независимым вызовом проходят; конфликтные/нечисловые/дубли/свежий FAIL отказывают своими причинами. Census — B --catalog, не ручной словарь в контракте.
- Правило формы: B --sintaksis и B --catalog — каждый rc 0; bash -n, пинованный shellcheck через validate_std, compile Python без pycache. Унаследованные SC2034/SC2295/SC1010 reference явно помечены, production не правится ради них.
- Правило frozen: B --regression224 запускает старые клетки без изменений. Цель после РЕШЕНИЯ конфликта — rc 0; сейчас ожидаемый сырой rc 1 с раскрытыми конфликтами, это блок заморозки, не исключение из регресса. `bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --repo .` на неизменённом production — rc 0.
- Правило допуска: `python3 -B fixtures/workshop_project/done_round_compat_231/context.py`, `bash scripts/pre_critic.sh contracts/231-sovmestimost-doski-224.md`, `SDACHA_TIMEOUT_SEK=1200 SDACHA_BUDZHET_SEK=2400 bash scripts/check_sdacha.sh . contracts/231-sovmestimost-doski-224.md --run`, `bash scripts/check_precision_gate.sh . contracts/231-sovmestimost-doski-224.md` — каждый rc 0 формы; никакой из них не является словом владельца о frozen.
- Правило потребителя: `bash scripts/check_spec_ready.sh . contracts/231-sovmestimost-doski-224.md` — rc 0. До done orchestrator подключает B --repo . / --model / --stabs / --sintaksis своим шагом и замером; `bash scripts/check_provodka.sh . contracts/231-sovmestimost-doski-224.md` и `bash scripts/gen_ci_steps.sh --check` — rc 0 после проводки, не объявляются зелёными до неё.

Конформный вход — настоящий доступный Git с F/OBJECT/HEAD-блобами и прежним профилем 996, плюс описанные положительные/явно отказные грамматики. Валидный контрпример инвариантен к конкретному номеру предмета, SHA и пути корня, расходится на конформном входе. Отсутствие инструмента/объекта или timeout не подменяет предметный отказ. Живые blob 215/227 пинованы базой/тегом, не синтетическими перепечатками. Продуктовые формы 181/179/218 — перенос топологии и имён из измерения, не утверждение прогона настоящего backend/mobile.

ПОТРЕБИТЕЛЬ scripts/check_spec_ready.sh: bash scripts/check_spec_ready.sh . contracts/231-sovmestimost-doski-224.md
замер: `cat scripts/consumers.d/*.tsv | wc -l` = 6 census scripts/consumers.d/*.tsv

## Модель угроз

ЗАЩИЩАЕТ:
- От отказа на документированных исторических представлениях одной двери: новые имена и точка проходят без миграции судебных артефактов, целые живые blob используются в контроле.
- От ложного done на позднем FAIL или конфликтующем явном вызове: числовой выбор, уникальность ключа, канонические поля и прежние F/CID/OBJECT не снимаются.
- От проектных зашивок при ремонте совместимости: грамматика общая для обеих ролей и workflowPaths, значения проектов остаются данными фикстуры.

НЕ ЗАЩИЩАЕТ:
- От согласованной лжи суда или удаления позднего вердикта из истории; ловцы — существующие pre_judge/замок предмета, origin и независимый reviewer.
- От компрометации Git/PATH/установки или субъекта, распознающего стенд; ловцы — изоляция, CI и независимый adversary/reviewer, конечная батарея не доказывает любые программы.
- От противоречия frozen-обязательств: ловец — раскрытый конфликт и решение владельца ДО заморозки; reference не уполномочивает менять риск или ослаблять 224.
- От независимых дефектов архитектурного API/профиля/sourceCanon/карты листа; ловцы — прежние семьи 187/201/213/992/996 и полный production-diff reviewer.

## Зоны и проводка

ЗОНА architect: contracts/231-sovmestimost-doski-224.md fixtures/workshop_project/done_round_compat_231/
ЗОНА implementer: scripts/done_contract.sh
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml

ПЕРЕСЕЧЕНИЕ architect: contracts/231-sovmestimost-doski-224.md — 993 только 231; прежние семьи сохраняются
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/done_round_compat_231/ — 054 только 231; прежние семьи сохраняются
ПЕРЕСЕЧЕНИЕ architect: fixtures/workshop_project/done_round_compat_231/ — 055 только 231; прежние семьи сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 038 только совместимость 231; прочие двери сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 094 только совместимость 231; прочие двери сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 168 только совместимость 231; прочие двери сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 184 только совместимость 231; прочие двери сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 187 только совместимость 231; прочие двери сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 201 только совместимость 231; прочие двери сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 223 только совместимость 231; прочие двери сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 224 конфликт раскрыт выше; требуется решение владельца
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 226 только совместимость 231; прочие двери сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 992 только совместимость 231; прочие двери сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 996 только совместимость 231; прочие двери сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только свой шаг 231
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только свой шаг 231

ПРЕДПОСЫЛКИ:
- setting Git/bash/python3/jq/date/stat и pinned shellcheck 0.11.0; новых secrets/variables/environments/settings не требуется.
- setting Свою CI-проводку подключает orchestrator после решения конфликта; чужие шаги не меняются.

ПРОВОДКА:
- guard=fixtures/workshop_project/done_round_compat_231/red_done_round_compat_231.sh

ПРОВОДКА-ЭНФОРСМЕНТ: чистая механика существующего писателя done; новых поведенческих норм роли нет. Потребители батареи — исполнимый сдаточный лист и собственный CI-шаг orchestrator после реализации. Отсутствие подключения до этого не объявляется зелёным done.

## Незаполненные требования:
нет
