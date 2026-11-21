accept
OBJECT=2253d941d0c9d15055eecde5c4e0598115e28595
СУД: один scoped reviewer по Ф1 (слово владельца 21.11 13:56; консультант 19:09); роль=reviewer; сессия=Rev141F1; repo=dev-harness; предмет=141; объект=Ф1 — станционный ремонт батареи fixtures/workshop_project/obryv_adb_diagnostika_141/ (коммит 2253d941d0, автор architect); контракт=frozen/contracts/141/3 (blob 300c3e8e2ad62342d1956f2d35865d14de2031e2); вызов=1/1; класс задачи=кодовый; класс риска=обычный (не повышаю: правка только батареи харнесса, без прав, денег, ПД и согласий); модель-факт=anthropic/claude-opus-5-5 (по workstation-контексту сессии);

ИТОГ: блоков нет. Ф1 закрывает дефект, который назвал прежний reviewer: «батарея не видит CRLF» (`verdicts/review/contracts-141-impl-v3.md` на `wip/141/reviewer-v3` @ 9ba965215f). Своей мерой на CRLF-мире: прежний probe.py даёт `--repo` rc 0 (46 ok), объект даёт rc 1 (25 KRASNO, из них 3 `SKRIPT_PIN_RASHOZHDENIE`). Честный LF-мир зелёный: rc 0, 46 ok. Из 7 моих мутантов батареи 6 краснят именованную клетку контроля. Выжил M2b (сравнение `.strip()` со `.strip()` модели). Это прежний пробел покрытия, Ф1 его не расширила → совет С-1. Советы — в `.review/2026-11-21-127.md` (С-1…С-3).

ИДЕНТИФИКАЦИЯ. pwd=/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tf7c7ecd41/m.
- `git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/141/architect` → rc 0.
- `git switch --detach 2253d941d0…` → `git rev-parse HEAD` = 2253d941d0c9d15055eecde5c4e0598115e28595.
- `git fetch --tags …` → rc 0. Отклонены 3 чужих тега (id/PLAN/008, id/VERDICT/001, ustav/1 — «would clobber existing tag»); к предмету они не относятся.
- Scratch: TMPDIR=$PWD/.scratch-rev141f1. Там лежат прогоны `honest/`, мутанты `mut/<имя>/` (копии каталога фикстуры), миры `worlds/{LF,CRLF,NONL}`. В коммит scratch не входит.

══ (1) ОБЛАСТЬ ПРАВКИ ══
Родитель коммита: `git log -1 --format=%P 2253d941d0` = c31903d0d7. Это коммит тега frozen/contracts/141/3 (вердикт critic), а не fa8393d8fc, как сказано в задании.
- `git diff --name-status fa8393d8fc 2253d941d0` даёт 3 пути: probe.py, repo_control.py и `A verdicts/critic/contracts-141-v3.md`. Третий путь — коммит critic c31903d0d7 (ЗОНА critic), не Ф1.
- Своей мерой `git diff --name-status 2253d941d0^ 2253d941d0` и `git diff --name-status frozen/contracts/141/3 HEAD -- fixtures/…141/ contracts/141-…md` — ровно 2 файла:
  - M fixtures/workshop_project/obryv_adb_diagnostika_141/probe.py (23: +12/−11);
  - M fixtures/workshop_project/obryv_adb_diagnostika_141/repo_control.py (53: +48/−5).
  - Итого +60/−16, совпадает с заданием.
Зона: обе правки лежат в `ЗОНА architect: … fixtures/workshop_project/obryv_adb_diagnostika_141/` (контракт :49). author = committer = architect <architect@dev-harness.local>.
Атомарность: один коммит, один предмет, сообщение «fix(141): preserve raw script bytes in pins and replay».
Не тронуты:
- контракт: blob HEAD = blob frozen/contracts/141/3 = 300c3e8e2a;
- source.json, модельные носители и nositeli;
- registry/, продукт.
Подгонки под имена клеток нет: source.json не менялся, `kejsy`/`stab_vhod` прежние. repo_control.py ждёт существующие клетки `CASE struktura-shag<N> ok` и `… KRASNO (SKRIPT_PIN_RASHOZHDENIE: <N>)`.

Содержание Ф1 (probe.py на OBJECT). Скрипты хранятся байтами от загрузки до replay:
- :1406 `scripts[n] = b` (модель, после пина);
- :1485 `(Path(repo) / path).read_bytes()` (субъект `--repo`; до Ф1 — `read_text`, универсальные переводы строк);
- :667 `sha256_bytes(script)` по сырым байтам;
- :585/:589 replay проверяет `b'${{'` и пишет `write_bytes(script_bytes)`;
- :681-688 и :696 сигнатура и выражения сверяются по байтам; выражения — через `decode(errors='surrogateescape')`;
- :1320 стабы декодируют и кодируют модель (LF, UTF-8 — без потерь: модельные скрипты CR=0, последний байт `\n`).
Workflow `mobile.yml` по-прежнему читается текстом (:1483). Это вне Ф1: контракт пинит скрипты, а не workflow (инв. 5).
repo_control.py:45-83 — новый цикл по 135/118/995:
- LF-скрипт зелёный;
- CRLF-вариант даёт ровно `CASE struktura-shag<N> KRASNO (SKRIPT_PIN_RASHOZHDENIE: <N>)`, rc 1;
- `probe.ispolnit_replay` с телом `cmp -- <path> <(printf '%s' <байты из памяти>)` в CHISTYJ и ACTIONS, для LF и CRLF, — независимый оракул байтов replay.

══ (2) СЫРОЙ ВЫВОД (дерево OBJECT, TMPDIR внутри копии) ══
  bash …/red_obryv_adb_diagnostika_141.sh                → rc 1; 46 строк `KRASNO (SUBJECT_ABSENT)`, ok 0; stderr «SUBJECT_ABSENT: нет субъекта .github/workflows/mobile.yml…»
  … --model                                              → rc 0; 46 `CASE … ok`, KRASNO 0
  … --stabs                                              → rc 0; 46 ok; 71 `STAB … KRASEN`; уникальных стабов 56; ZHIV 0; `SVJAZI 71`; `zhivykh 0`
  … --matrix                                             → rc 0; вывод побайтово равен --stabs (cmp rc 0)
  python3 …/repo_control.py                              → rc 0:
    CONTROL_REPO_GREEN rc=0 cases=46
    CONTROL_LF_GREEN {135,118,995} rc=0
    CONTROL_CRLF_RED 135 rc=1 SKRIPT_PIN_RASHOZHDENIE: 135   (так же 118, 995)
    CONTROL_REPLAY_BYTES_GREEN {135,118,995} {LF,CRLF} {CHISTYJ,ACTIONS} rc=0   (12 строк)
    CONTROL_DIAG118_REPLAY_RED CHISTYJ / ACTIONS: нет маркера вывода: "maestro.android.DeviceServerDiedException: …"
    CONTROL_PIN_RED rc=1 SKRIPT_PIN_RASHOZHDENIE
    CONTROL_CALL_RED rc=1 VYZOV_SKRIPTA
  --repo worlds/LF   (model/mobile.yml + 3 модельных скрипта)   → rc 0, 46 ok
  --repo worlds/CRLF (три скрипта `\n`→`\r\n`)                   → rc 1, ok 21, KRASNO 25 = 22 replay (`CHISTYJ: rc=2 (ожидался …)`) + struktura-shag{135,118,995} `SKRIPT_PIN_RASHOZHDENIE`
  --repo worlds/NONL (у трёх скриптов снят хвостовой `\n`)       → rc 1, ok 43, KRASNO 3 = struktura-shag{135,118,995} `SKRIPT_PIN_RASHOZHDENIE`
  CRLF или снятый хвостовой `\n` в каждом модельном скрипте при неизменном source.json → `--model` rc 2 `ORACLE_TAMPERED: пин model/mobile/scripts/<f> не сходится` (6/6)
  bash scripts/check_provodka.sh . contracts/141-obryv-adb-diagnostika.md → rc 0
  bash scripts/check_project_sources.sh --repo . --contract contracts/141-obryv-adb-diagnostika.md --stage done → rc 0
Своя мера счёта (`.scratch-rev141f1/count.py` — разбор source.json, а не вывод батареи):
- stabs 56, svjazi 71, kejsy 46 (replay 22, struktura 15, derevo 9);
- sha256 модельных скриптов = nositeli ×3; CR=0, последний байт `\n` ×3.
Совпадает с контрактом :29-30 («56 стабов / 71», «SVJAZI 71», 22/15/9). «69» в тексте задания контракту не соответствует: контракт и замер дают 71.

══ (3) НЕПОДГОНКА И КРАСНОЕ: МУТАНТЫ БАТАРЕИ ══
Как сделано: каждый мутант — одна замена с assert count==1 в отдельной копии каталога фикстуры (`.scratch-rev141f1/mutants.py`). Каждый прогнан через `--model`, `--repo` на мирах LF/CRLF/NONL и `repo_control.py`. Контроль (HONEST, копия без замены) совпал с прогоном дерева.
  PRE-F1 (probe.py родителя c31903d0d7):
    --repo CRLF → rc 0, 46 ok: дефект воспроизведён, батарея CRLF не видит. --repo NONL → rc 1 (3 pin): хвостовой `\n` был виден и до Ф1.
    repo_control.py объекта на прежнем probe.py → rc 1 (Traceback).
  M1 пин по CRLF→LF (`probe.py:667` `sha256_bytes(script.replace(b'\r\n', b'\n'))`) → КРАСНЫЙ.
    repo_control rc 1 `CONTROL_CRLF_NOT_RED 135: rc=1`: клетка struktura-shag135 зелёная, дверь красна только 22 replay-клетками.
    --model rc 0.
  M2a пин по `.strip()` против сырого пина → КРАСНЫЙ: --model rc 1, KRASNO 4 (3 pin + derevo-job-zakonnaja-pravka); repo_control rc 1 `CONTROL_REPO_RED`.
  M2b пин `.strip()` против `.strip()` модели в памяти → ВЫЖИЛ.
    --model rc 0, --repo LF rc 0, --repo NONL rc 0 (46 ok), --stabs rc 0 (SVJAZI 71, zhivykh 0), repo_control rc 0.
    CRLF ловит и он: rc 1, внутренние `\r\n` не снимаются strip.
    → С-1: мира «без хвостового `\n`» в контроле нет; до Ф1 то же.
  M3 replay пишет CRLF→LF (`probe.py:589`) → КРАСНЫЙ.
    repo_control rc 1 `CONTROL_REPLAY_BYTES_RED 135 CRLF CHISTYJ: rc=1 (ожидался 0)`.
    --repo CRLF rc 1 только тремя pin-клетками: replay нормализованного скрипта зелёный, без cmp-контроля дефект был бы виден лишь пину.
  M4 replay теряет хвостовой перевод строки (`write_bytes(script_bytes.rstrip(b'\r\n'))`) → КРАСНЫЙ.
    repo_control rc 1 `CONTROL_REPLAY_BYTES_RED 135 LF CHISTYJ: rc=1 (ожидался 0)`.
    Клетки батареи к нему слепы (--model rc 0, LF rc 0): поведение то же.
  M5 чтение `--repo` текстом (`probe.py:1485` `read_text(encoding='utf-8').encode('utf-8')`, путь до Ф1) → КРАСНЫЙ только контролем.
    --repo CRLF rc 0, 46 ok (дверь открыта).
    repo_control rc 1 `CONTROL_CRLF_NOT_RED 135: rc=0`.
  M6 чтение `--repo` теряет хвостовой `\n` (`read_bytes().rstrip(b'\n')`) → КРАСНЫЙ: --repo LF rc 1 (3 pin); repo_control rc 1 `CONTROL_REPO_RED`.
  Итог: 6/7 красны, выжил M2b.
  Режим CI `--stabs` на M1, M2b, M3, M5 → rc 0, SVJAZI 71, zhivykh 0 ×4: к Ф1 он слеп (С-2).
  Проверка ПРОВЕРЬ задания («Ф1 закрывает “батарея не видит CRLF”»): на CRLF-мире клетка struktura-shag<N> красная у честной двери и зелёная у прежнего probe.py и у M5. Честный LF-мир зелёный. Подтверждено.
Оракул контроля независим. Ожидаемые байты в cmp-контроле взяты из `model_scripts` в памяти: они сверены с пином source.json до прогона (`zagruzit_model`), а не прочитаны из песочницы или файла продукта. Красное у cmp-контроля предъявлено мутантами M3 и M4.

══ ПАРАЗИТНАЯ СЛОЖНОСТЬ (050), ответы (1)–(5) ══
  • Перевод probe.py со str на bytes (7 ханков: :585, :589, :667, :681-688, :696, :1320, :1406, :1485):
      (1) инв. 1 «SHA256 ко ВСЕМ байтам», инв. 3 «replay исполняет из файла»;
      (2) нового состояния нет, тип явный;
      (3) 1 файл, число не выросло;
      (4) флаги, коды возврата и env прежние;
      (5) строка приёмки `--repo` (:32), repo_control.
      ESSENTIAL.
  • Цикл LF/CRLF/cmp в repo_control.py:45-83:
      (1) красное предъявление инв. 1/3 на CRLF;
      (2) временное дерево, исход явен строками CONTROL_LF_GREEN / CONTROL_CRLF_RED / CONTROL_REPLAY_BYTES_GREEN и rc;
      (3) при смене формы причины меняются probe.py и строка ожидания: 2 файла, как у прежнего CONTROL_PIN_RED;
      (4) аргументов, флагов и env нет, +3 вида строк вывода;
      (5) строка приёмки :31 (repo_control rc 0); в CI не проведён (С-2). M1, M3, M4, M5 красны только им.
      ESSENTIAL.
  • Загрузка src/модели перенесена выше в repo_control.py:28-29: нужна циклу. ESSENTIAL.
  • `dir=HERE` в repo_control.py:30 — ACCIDENTAL.
      Свойства контракта под ним нет. Он вводит неотслеживаемый каталог `control141-*` в фикстуре: git check-ignore rc 1, остаётся при SIGKILL.
      Простая форма (без `dir=`) прогнана: rc 0, те же строки.
      Не блок: обязательство контракта не нарушено, порог задания для FAIL — нарушение обязательства на достижимом состоянии. → С-3.

СВЕРКА-СТАНДАРТОВ: AGENTS.md dev-harness не объявляет docs/ARCHITECTURE.md и docs/CODING-STANDARDS.md (grep — 0 совпадений, файлов в дереве нет); сверять дифф с документом стандарта не с чем. По виду дифф соответствует соседнему коду фикстуры: транслит-имена probe.py, отказ именованной строкой в stderr и rc 1 в repo_control, как у прежних CONTROL_*_NOT_RED.
СВЕРКА-АРХИТЕКТУРЫ: размещение — 2 файла в fixtures/workshop_project/obryv_adb_diagnostika_141/ (ЗОНА architect); других путей нет. Зависимости: stdlib `shlex` и coreutils `cmp`/bash process substitution внутри песочницы replay (доступность доказана зелёными CONTROL_REPLAY_BYTES_GREEN, различимость — красными M3/M4); новых пакетов нет. Писатели: новых писателей отслеживаемых файлов нет; временный каталог контроля теперь внутри фикстуры (С-3). Операции и интерфейс батареи (флаги --model/--stabs/--matrix/--repo, MOB_REPO, коды 0/1/2) не изменены. bindings.json в дереве нет (glob — 0). Долг не расширен: прежний пробел «хвостовой `\n`» тот же (С-1). Diff модели нет: source.json и model/ не тронуты, L-уровень не применим. tooling/checks/cli.js в дереве нет, завести находку архитектуры им нечем и не по чему.
ПРОВОДКА (038): guard=fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh существует. Это барьер именно предмета 141, подключён registry/ci-steps.tsv:147 (`--stabs`). check_provodka rc 0. Проводку Ф1 не меняла. Красное Ф1 живёт в repo_control.py, а он в CI не проведён (С-2, строка оркестратора по ПРОВОДКА-ЭНФОРСМЕНТ).
ОСТАТОК (контракт 192): у frozen 141 НЕ ЗАЩИЩАЕТ (:42-45) нет нумерации К-NN. Ловец «ревью diff» назван у строки «код шагов ДО целевых и достижимость workflow по событиям on:/статусам предшествующих job». ОСТАТОК: «код шагов до целевых / достижимость workflow» — не укусил: дифф Ф1 не касается workflow и шагов продукта (только 2 файла фикстуры харнесса).
РЕЖИМ ПРОЕКТА (996): harness.project.json не объявляет sourceCanon, gate сверки не применим. Вердикт лежит под workflowPaths.verdicts = verdicts.

══ БЛОКИ ══
нет.

══ РАЗВИЛКИ ══
  - Ф1 НЕ покрывает продуктовые CI-скрипты Complior-mob#222 (`eb2cb6146f`). Это отдельный объект и отдельный суд; `--repo /home/harness/projects/Complior-mob` не запускал (строка приёмки :32 — суд продукта).
  - `.review/` по 141 на OBJECT: `ls .review | grep 141` → пусто. Файлов ready/partial по 141 нет. Свой совет — `.review/2026-11-21-127.md` (status: ready).
  - Задание называет родителя fa8393d8fc; фактический родитель — c31903d0d7 (= frozen/contracts/141/3, коммит critic). Разница в 3-м пути diff — вердикт critic, не Ф1.
  - Задание ссылается на «69» SVJAZI; контракт :30 и замер дают 71.
  - Прежний вердикт reviewer v3 (`contracts-141-impl-v3.md`) лежит на ветке wip/141/reviewer-v3, а не в дереве OBJECT. В дереве OBJECT из contracts-141-impl-* есть только v1; v4 свободен во всех ссылках (git log --all пусто).
  - `bash scripts/pre_critic.sh …` (строка приёмки :33, стадия контракта) не запускал: контракт Ф1 не меняла (blob равен frozen).
  - `repo_control.py` при импорте probe пишет `__pycache__/` в каталог фикстуры (нет PYTHONDONTWRITEBYTECODE). Так было и до Ф1; каталог покрыт .gitignore. Свой `__pycache__` после прогонов удалил.

МАТЕРИАЛЫ: $PWD/.scratch-rev141f1/{run_modes.sh, mutants.py, stabs_on_mutants.py, oracle_crlf.py, control_tmpdir.py, count.py, honest/, mut/, worlds/}. Push не делал, тег done не ставил, в docs/owner/ и вне копии не писал.
