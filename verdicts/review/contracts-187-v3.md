accept
OBJECT=ac91200c8cbb46dcd4a5c5737a39857940bb348b
СУД: repo=dev-harness; предмет=187; фаза=реализация v3 (implementer 187а, Impl187V3 787fc63b83 → cherry-pick -x ac91200c8c); роль=reviewer; вызов=1/1, полный (класс риска обычный, контракт 187:4: adversary не вызывается, reviewer единственный судья); сессия=Rev187V3; модель-план=config/agent_models.json (reviewer → audit); модель-факт=anthropic/claude-opus-5-5 allowed (`bash scripts/models_actual.sh --tsv --bind --session Rev187V3 | cut -f1-3` из /home/harness/dev-harness → две строки `reviewer	anthropic/claude-opus-5-5	allowed`); SHA=ac91200c8cbb46dcd4a5c5737a39857940bb348b (ветка wip/int-2050/architect).

ИТОГ: реализация выполняет три обязанности v3 (грамматика pin, порядок шва, применимость) на различающих входах, а не только на зелёной батарее. Дифф лежит только в зоне implementer. Батарея, контракт и реестр не тронуты. Специальных веток под имена фикстур нет. Четыре развилки автора допустимы, скрытого ослабления нет. Блоков нет.

ИДЕНТИФИКАЦИЯ ДЕРЕВА (клон /tmp/dev-harness-verify/Rev187V3/repo; прогоны — в одноразовых копиях run1 = OBJECT и pre = OBJECT~1 = 96fca733f2, `git clone` клона, внутри /tmp/dev-harness-verify/Rev187V3/):
  git rev-parse HEAD → ac91200c8cbb46dcd4a5c5737a39857940bb348b; `git merge-base --is-ancestor origin/main HEAD` → rc 0 (origin/main b428ff6d).
  b428ff6d..HEAD — четыре коммита, у каждого author=committer=роль:
    fec2b009 architect: contracts/187-arhitektura-v-processe.md, fixtures/…/architecture_process_187/{sdacha_187.md,workflow_probe.py}
    34641668 critic: verdicts/critic/contracts-187-v3.md
    96fca733 arbiter: verdicts/arbitration/187-pin-diagnostika.md
    ac91200c implementer: scripts/check_architecture_contract.sh, scripts/make_task.sh (93+/11−)
  `git show 787fc63b83 | git patch-id` = `git show HEAD | git patch-id` = f71c43d7d4: cherry-pick байт-в-байт равен коммиту автора.

══ (1) ОБЛАСТЬ ПРАВКИ ══
  `git diff --name-only HEAD~1 HEAD` → scripts/check_architecture_contract.sh, scripts/make_task.sh. Оба файла входят в ЗОНУ implementer (контракт 187:84: make_task, freeze_contract, pre_critic, done_contract, check_architecture_contract).
  `git diff --quiet HEAD~1 HEAD -- contracts fixtures registry verdicts .github` → rc 0: батарея, контракт, реестр и CI в коммите реализации не менялись. Проверка автором реализации не переписана.
  Подгонки под фикстуры нет. Я прочитал дифф целиком: новые ветви зависят только от длины и алфавита значения `.commit`, от каталога `architecture/` и от arch187_scope. Литералов мира (777, api.identity, PINNED_/WRONG_HEAD_, toy, Fixture) в диффе нет.

══ (2) СЫРОЙ ВЫВОД (мои прогоны; команда → rc) ══
  run1 (OBJECT):
    red_architecture_process_187.sh --repo . → rc 0, `CELLS=61 STABS=0 FAILURES=0`. Своя мера: `… --repo . 2>&1 | grep -cE '^(GREEN|RED) [a-z0-9-]+: rc='` → 61 (отдельный прогон, другая команда).
    red_architecture_process_187.sh --model → rc 0, `CELLS=61 … FAILURES=0`
    red_architecture_process_187.sh --stabs → rc 0, `CELLS=61 STABS=75 FAILURES=0` (последние строки: `STAB applicability-dir-only caught @ applicability-lock-no-dir`, `STAB applicability-lock-only caught @ applicability-dir-no-lock`)
    red_architecture_process_187.sh --wiring . → rc 0
    check_architecture_contract.sh --repo . contracts/187-arhitektura-v-processe.md → rc 0 (`ARCH_187A_SKIP`, харнесс вне режима 187а)
    gen_ci_steps.sh --check → rc 0; check_provodka.sh . contracts/187-arhitektura-v-processe.md → rc 0
    arch_component_170/red_arch_component_170.sh --repo . → rc 0; --model → rc 0. Сохранность 170 v1 подтверждена. Клетки 170 матчат префикс отказа, поэтому новый текст `ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, применимая архитектура)` их не красит.
    fixtures/_krasnye_095.sh → rc 0 (`ИТОГ 095: rc=0`); fixtures/_krasnye_103.sh → rc 0 (`ИТОГ 103: rc=0`)
    dovodka_ui_133/red_dovodka_ui_133.sh → rc 0 (`клеток 34, сошлось 34, расхождений 0`)
    done_dver_soderzhatelnaja_201/red_done_dver_201.sh --stabs → rc 0 (`CELLS=62 STABS=27 FAILURES=0`); без флага → rc 0 (`CELLS=62 STABS=0 FAILURES=0`)
    izveshchenie_168/red_izveshchenie_168.sh → rc 1. Это то же, что ДО ремонта: md5 отсортированных строк RED/FAIL/rc/FAILURES = f243d16324d85e3caa94b9cb7a303401 и на run1, и на pre. Красное существовало до ремонта, ремонт его не создал.
    `git status --porcelain | wc -l` в run1 после прогонов → 0
  pre (OBJECT~1, дверь до ремонта):
    red_architecture_process_187.sh --repo . → rc 1, `CELLS=61 STABS=0 FAILURES=5`. Красны ровно pin-symbolic-head (rc 0, бриф `WRONG_HEAD_BRIEF_187`), pin-symbolic-branch (rc 0, `WRONG_HEAD_BRIEF_187`), pin-short-sha (rc 0, верный бриф `PINNED_BRIEF_187` без грамматики), pin-head-noflag (rc 1, но `ARCH_COMPONENT_NET … проект с architecture/` вместо ARCH_PIN), applicability-lock-no-dir (rc 0, пак без брифа). Остальные 56 зелёные, pin-unresolvable-sha и applicability-dir-no-lock зелены до ремонта. Красное предъявлено, и совпадает с контрактом 187:58 поимённо.

══ (3) СООТВЕТСТВИЕ ПРЕДМЕТУ — СВОИ РАЗЛИЧАЮЩИЕ ВХОДЫ ══
  Скрипт /tmp/dev-harness-verify/Rev187V3/myprobe.py. Из батареи взят только построитель миров (world/architecture: модель с A=pin и отличным HEAD B). Ожидания и вызовы публичных дверей — мои. Прогон: `python3 myprobe.py <дерево>`. На run1 → rc 0, `BAD=0` из 31 входа; на pre → rc 1, `BAD=15`.
  Для каждого входа: rc, байты stdout, первая строка stderr на run1, затем pre.
    флаг, pin=HEAD → rc 1, stdout 0, `ОТКАЗ: ARCH_PIN: закреплённый pin не полный 40-hex SHA: HEAD` | pre: rc 0, пак 1392 байт
    флаг, pin=main (ветка) → rc 1, 0, `… не полный 40-hex SHA: main` | pre: rc 0
    флаг, pin=12 hex от A → rc 1, 0, `… не полный 40-hex SHA: f9d7f43dac0d` | pre: rc 0
    флаг, pin=39 hex от A → rc 1, 0, `… не полный 40-hex SHA: <39hex>` | pre: rc 0
    флаг, pin=A В ВЕРХНЕМ РЕГИСТРЕ (40 символов) → rc 1, 0, `… не полный 40-hex SHA: 117E5AD4…` | pre: rc 0. Каноническая строчная форма соблюдена.
    флаг, pin=A с хвостовым пробелом → rc 1, 0, неконформный | pre: rc 1 (неразрешимый)
    флаг, pin=`A^{commit}` → rc 1, 0, неконформный | pre: rc 0
    флаг, pin=`HEAD~1` (разрешается ровно в A) → rc 1, 0, `… не полный 40-hex SHA: HEAD~1` | pre: rc 0. Разрешимость в правильный коммит грамматику не заменяет.
    флаг, pin=40×d (неразрешимый) → rc 1, 0, `ОТКАЗ: ARCH_PIN: коммит dddd…dddd не разрешается в клоне модели: <клон>` | pre: тот же
    флаг, pin=40×e, а в клоне модели есть ВЕТКА с таким 40-hex именем на B → rc 1, 0, `коммит eeee… не разрешается в клоне модели`. Имя-ссылка не подменяет объект, бриф B не выдан.
    флаг, `.commit`="" и `.commit`=null → rc 1, 0, `ОТКАЗ: ARCH_PIN: в architecture.lock.json нет закреплённого коммита` (прежний отказ, развилка 4)
    флаг, полный A, с каталогом и без каталога → rc 0, пак содержит `PINNED_BRIEF_187` и не содержит `WRONG_HEAD_BRIEF_187` (парный корректный вход)
    без флага, pin=HEAD, с каталогом и без каталога → rc 1, 0, `ARCH_PIN … HEAD`, `ARCH_COMPONENT_NET` нет | pre: с каталогом ARCH_COMPONENT_NET, без каталога rc 0 пак
    без флага, pin=12 hex, без каталога → rc 1, ARCH_PIN | pre: rc 0
    без флага, неразрешимый pin, без каталога → rc 1, ARCH_PIN «не разрешается»
    без флага, lock с полным A, без каталога → rc 1, 0, `ОТКАЗ: ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, применимая архитектура)` | pre: rc 0, пак без брифа
    без флага, lock с полным A и каталог → rc 1, ARCH_COMPONENT_NET
    без флага, каталог без lock → rc 1, ARCH_COMPONENT_NET (требование 170/1 не сужено)
    без флага, нет ни каталога, ни lock (backend) → rc 0, пак (вне применимости)
    без флага, нет строки «АРХИТЕКТУРА:» и pin=HEAD → rc 1, `ARCH_LINE_MISSING`, ARCH_PIN не выводится. Порядок строка → pin соблюдён.
    документальный предмет без флага, lock без каталога; то же с pin=HEAD → rc 0, пак (гейта нет, контракт 187:35)
    документальный предмет с флагом, pin=HEAD → rc 1, ARCH_PIN (источник брифа закреплён и для документа) | pre: rc 0
    mob и harness без флага, lock есть, каталога нет → rc 0 (новых отказов нет, контракт 187:26)
    freeze_contract.sh, pin=HEAD → rc 1, `ARCH_PIN … HEAD`, frozen-тега нет | pre: rc 0, тег frozen/contracts/777/1 создан
    freeze_contract.sh, полный A → rc 0, тег есть
    pre_critic.sh --repo, pin=12 hex → rc 1, ARCH_PIN неконформный | pre: rc 0
  Вывод: «разрешить HEAD/ветку/префикс в SHA и принять» не выполняется ни на одном пути (флаговом, безфлаговом, документальном с флагом, freeze, pre_critic). Pin судится до флага. Применимость = каталог ИЛИ backend-lock, и каждая ветвь различается своим входом.

══ (4) РАЗВИЛКИ АВТОРА — ОЦЕНКА ══
  (1) Текст ARCH_COMPONENT_NET «(кодовый предмет, применимая архитектура)». Допустимо. Контракт 187:35 задаёт имя, rc, пустой stdout и отсутствие пака, точный хвост текста не задаёт. Frozen 170/1 требует префикс `ARCH_COMPONENT_NET:` и подсказку `--arch-component`, обе части в тексте есть. 170 --repo и --model rc 0. Прежний хвост «проект с architecture/» стал бы ложным на ветви lock без каталога. В scripts/ и fixtures/ старый хвост больше не встречается, он остался только в архивных вердиктах critic v1.
  (2) Грамматика в общем шве. Отказ ARCH_PIN на неконформном pin получают также freeze и pre_critic; done не затронут, потому что done_contract.sh:277–370 не зовёт arch187_model_prepare. Это не ослабление, а исполнение одного правила одной реализацией (шапка check_architecture_contract.sh «одна реализация правил»). Раньше freeze и pre_critic по символьному pin судили модель из головы клона, вопреки замороженным 187:10 и 187:30 («не из HEAD», «из точного SHA»). Именно это показывает мой вход freeze pin=HEAD: на pre rc 0 и тег создан. Потребители 095, 103, 133, 201 и 170 v1 зелёные, 168 без изменений.
  (3) Для документального предмета отказ не расширен. Допустимо: в контракте 187:35 стоит «документальный предмет гейта не получает». При флаге документ всё равно получает ARCH_PIN на неконформном pin, так что источник брифа не ослаблен.
  (4) Пустой или null `.commit` сохранил прежний отказ `ARCH_PIN: в architecture.lock.json нет закреплённого коммита`. Допустимо. В домен входов v3 (187:55–58) входят HEAD, ветка, 12 hex и неразрешимый полный sha; пустое значение — вход 170 v2 (`empty_lock*`, 187:21 и «НЕ ЗАЩИЩАЕТ» 187:73). Охраняемые свойства (имя ARCH_PIN, rc 1, пустой stdout, бриф не зовётся) держатся, что проверено входами "" и null.

ПАРАЗИТНАЯ СЛОЖНОСТЬ (контракт 050):
  arch187_pin_full_sha (check_architecture_contract.sh:152–162): (1) обязательство 187:33 «полный 40-hex в строчной форме»; (2) состояния не вводит, чистый предикат по аргументу, rc 0/1; (3) правило грамматики живёт в одном месте, все двери его наследуют, число совместно меняемых файлов не выросло; (4) интерфейс — один аргумент и rc, за ним длина и алфавит; посимвольный case не зависит от локали; (5) потребитель — arch187_model_prepare:189, а через него клетки pin-* батареи; дублирования нет, это первая грамматика pin в дереве. ESSENTIAL.
  _arch_applicable (make_task.sh:1008–1011, 1093): (1) обязательство 187:35 «каталог ИЛИ применимый lock»; (2) локальная переменная, видна в одном if; (3) один файл; (4) интерфейса не добавляет; (5) потребители — клетки applicability-lock-no-dir и applicability-dir-no-lock. Сам предикат arch187_scope переиспользован, второй грамматики «режима» нет. ESSENTIAL.
  Перенос проверки пустого pin выше клона модели — перестановка без нового состояния.

СВЕРКА-СТАНДАРТОВ: не применимо. AGENTS.md клона не объявляет документ архитектуры и стандарт кода (`grep -n 'ARCHITECTURE.md\|CODING-STANDARDS' AGENTS.md` → пусто, в docs/ таких файлов нет).
СВЕРКА-АРХИТЕКТУРЫ: не применимо к дереву харнесса. Сверено: harness.project.json repoId=dev-harness, sourceCanon=null; architecture.lock.json и bindings.json в корне нет; модели архитектуры харнесса нет, поэтому размещение, зависимости, писатели, операции и bindings не сверяются, а уровень diff модели — L0, модель не тронута. Дифф меняет только дверь, которая судит чужую (backend) модель; новых зависимостей и писателей нет, долг не расширен. Находки 188 не заводились: расхождения модели и работы нет.
ОСТАТОК: строк «НЕ ЗАЩИЩАЕТ» с ловцом reviewer 187 нет. Три строки 187:73–75 называют ловцами 170 v2, движок/CI проекта и будущую поддержку sourceCanon. Остаточный риск 187:43 («ловец — critic и reviewer предмета 188») относится к 188, не к этому вызову.

СОВЕТЫ (не блокируют):
  С-1. Комментарий шапки arch187_scope (check_architecture_contract.sh:93–94: «пин не заведён») и done_contract.sh:276 («repoId И пин модели») расходятся с предикатом: применимость определяет наличие файла lock, а не значение pin. Это пред-существующая строка вне диффа, но теперь на неё опирается _arch_applicable. Достаточно правки комментария тем же исполнителем при следующем касании.

РАЗВИЛКИ ДЛЯ ОРКЕСТРАТОРА (наблюдения, не находки по реализации):
  Р-1. Контракт 187:13 ссылается на `verdicts/arbitration/170-granica-obeshchanij.md`. Файла нет ни на OBJECT, ни в любом ref клона (`git log --all -- <путь>` пуст). По HANDOFF.md:124 он лежит на `wip/170/arbiter-v1` 4366b74665, то есть должен приехать с 170.
  Р-2. Frozen 170/1:15 говорит «Без `architecture/` и без флага прежняя выдача сохраняется». 187 v3 (applicability-lock-no-dir) для backend-lock это меняет по арбитражу 170-1 (выход А). Контракт 187:9: «до v+1 170 не выдавать несовместимый cutover 187а за done». Поэтому тег done по 187 зависит от заморозки 170 v2, это не решение reviewer. Клетки 170 v2 `empty_lock`/`invalid_pin`/`model_root_unset` по verdicts/critic/contracts-170-v2.md:44 ждут иных имён отказа, чем у этой двери; это зона 170 v2 (187:73).
