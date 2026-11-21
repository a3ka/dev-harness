accept
OBJECT=fc5081751721f9c93baaeb5e9ca0653094e8db40
СУД: один reviewer по Б-3 (слово владельца 21.11 16:19; консультант 17:44); роль=reviewer; сессия=Rev187B3; repo=dev-harness; предмет=187; PR=a3ka/dev-harness#1184 (wip/187/architect-b3); база=01df50efe7; основание=docs/owner/adr/2026-11-21-plan-fable.md (решения 2–3); класс задачи=кодовый (дверь + батарея); класс риска=обычный (не повышаю: ослаблена одна ветка по ADR владельца, ARCH_CI держит отказ, мутант M3 красный); модель-факт=anthropic/claude-opus-5-5 (по workstation-контексту сессии);

ИТОГ: блоков нет. Дверь изменена ровно в объявленной части: при отсутствии самостоятельной непустой строки `СВЕРКА-АРХИТЕКТУРЫ:` ветка ARCH_REVIEW теперь печатает предупреждение в stderr, а не отказывает. ARCH_CI, все прочие отказы done и порядок шагов не тронуты. Клетку «отказ» заменили клетки «предупреждение»: её не удалили без замены. Из 9 моих мутантов двери 8 дают красный цвет. Выжил M5c: это прежний пробел покрытия (совет С-1). Советы С-1…С-3 — в `.review/2026-11-21-125.md`.

ИДЕНТИФИКАЦИЯ. pwd=/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tc90f4ea4a/m. Получение: git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/187/architect-b3 (rc 0) → git switch --detach OBJECT → git rev-parse HEAD = fc5081751721f9c93baaeb5e9ca0653094e8db40. Прогоны и мутанты — в одноразовых клонах внутри копии: TMPDIR=$PWD/.scratch-rev187b3 (run = клон на OBJECT, base = клон на 01df50efe7, mut-* = копии run). В коммит scratch не входит.

══ (1) ОБЛАСТЬ ПРАВКИ ══
git diff --name-status 01df50efe7 fc50817517 → ровно 3 файла:
  M fixtures/workshop_project/architecture_process_187/sdacha_187.md
  M fixtures/workshop_project/architecture_process_187/workflow_probe.py
  M scripts/done_contract.sh
Итого 196+/116−. Frozen-тексты contracts/ не тронуты.

История линейна: 87197bd3e9←01df50efe7, f708b72398←87197bd3e9, fc50817517←f708b72398. Merge нет.
По коммитам (author = committer у каждого):
  87197bd3e9 architect — 2 файла фикстуры;
  f708b72398 implementer — только scripts/done_contract.sh, 7+/2−;
  fc50817517 architect — только sdacha_187.md, 14+/14−.
ЗОНЫ frozen 187: architect (:83) — fixtures/workshop_project/architecture_process_187/; implementer (:84) — scripts/done_contract.sh. Все пути лежат в своих зонах.
Атомарность: три коммита, у каждого один предмет и ссылка на 187 Б-3.

Все изменённые строки scripts/done_contract.sh (git diff 01df50efe7 fc50817517 -- scripts/done_contract.sh):
  hunk @@ -268 +268 — только комментарий шапки 187а:
    :271 «;» → «.»
    +:272-273 «План Fable Б-3 (ADR …): ARCH_REVIEW — ПРЕДУПРЕЖДЕНИЕ в stderr, не отказ; отказом остаётся ARCH_CI (2).»
  hunk @@ -303 +305 — единственная исполняемая правка:
    −`die "ARCH_REVIEW: в вердикте ревьюера $freshest нет самостоятельной строки «СВЕРКА-АРХИТЕКТУРЫ:»"`
    +:308-310 комментарий
    +:311 `printf 'ПРЕДУПРЕЖДЕНИЕ: ARCH_REVIEW: в вердикте ревьюера %s нет самостоятельной строки «СВЕРКА-АРХИТЕКТУРЫ:»; напиши самостоятельную строку «СВЕРКА-АРХИТЕКТУРЫ: <вывод>»\n' "$freshest" >&2`
Условие ветки (:307 `if [ "$_a187_rev_ok" != "1" ]`) и предикат (:294 `'СВЕРКА-АРХИТЕКТУРЫ:'*)`, :296 непустой хвост) не менялись.
Блок ARCH_CI (:313-370, все его `die "ARCH_CI…"`) идёт после ветки ARCH_REVIEW, как прежде, и не менялся.
Других хунков нет. Не тронуты: шаг 5 (вердикт), source-gate 996, ПРОВОДКА (6), ПОТРЕБИТЕЛИ (6а), 6б/201, клапан v>1, 992, env-гигиена, NNN-грамматика, закоммиченность. Порядок шагов тот же.

══ (2) СЫРОЙ ВЫВОД (клон run на OBJECT) ══
  bash …/red_architecture_process_187.sh --repo . → rc 0, `CELLS=67 STABS=0 FAILURES=0` (145 s; среди GREEN: done-valid rc=0, done-review-missing-warns rc=0, done-review-heading-warns rc=0, done-ci-* и done-ci-*-warns rc=1 reason=ARCH_CI, pin-selfcheck 9/9)
  … --model → rc 0, `CELLS=67 STABS=0 FAILURES=0`
  … --stabs → rc 0, `CELLS=67 STABS=93 FAILURES=0`
  … --wiring . → rc 0, вывод пуст
  bash scripts/check_sdacha.sh "$PWD" contracts/187-arhitektura-v-processe.md --run → rc 0, `СДАЧА: лист зелёный (двери=4 карта=17/17 дельта=0)`
  bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh --repo . → rc 0, `CELLS=62 STABS=0 FAILURES=0`, в т.ч. «karta-jq-vyzovov … × 5» (201/1 «НЕ СЛАБИТЬ» для прочих отказов держится)
  fixtures/done_contract/{red_D1,D2,D3,D4,D5,D7,D8,D9, green_D6,D10,G}.sh → каждая rc 0 (11/11, причины «названа дословно», «тег поставлен…»)
  bash fixtures/workshop_project/potrebiteli_116_195/red_potrebiteli_116_195.sh → rc 0, «195: честных клеток 14, зелёных 14, красных: нет»
  bash fixtures/workshop_project/izveshchenie_168/red_izveshchenie_168.sh → rc 1 на OBJECT и тот же rc 1 с теми же строками на базе 01df50efe7 (клон base): BRIEF_NOTICES_MISSING … DONE_WRITER_NOT_GATED «без строки OBJECT=…», STATION_DONE_WRITER_NOT_GATED. Это батарея нереализованного 168 (201:22 «в дереве ЕЩЁ НЕ реализован»), PR её не меняет.
  CI head (gh api …/commits/fc50817517…/check-runs) → success 16, skipped 1 (vorota). Совпадает с заданием.

Своя мера счёта:
  импорт workflow_probe.py → CASES=67 (уникальных 67), STABS=93, висячих привязок STABS→CASES 0.
  Дельта STABS: снят 1 (`reviewer-line-ignored`), добавлено 12 (review-{missing,heading} × 6 дефектов) + 1 (`reviewer-valid-warned`) + 5 (`ci-*-warning-omitted`) + 1 (`ci-warning-after-refusal`) = 19. Итог 75−1+19=93, совпадает с листом.
  Дельта CASES: −1 (`done-review-missing`), +2 review-warns, +5 ci-warns: 61−1+7=67.

══ (3) НЕПОДГОНКА И КРАСНОЕ ══
Клетки и стабы architect заложил в 87197bd3e9 до реализации (f708b72398). Implementer фикстур не трогал. Ожидания — кортежи CASES. done_observed (workflow_probe.py:1456) снимает HEAD и признак warns до вызова, после вызова читает настоящий тег `refs/tags/done/contracts/777/1^{commit}` и отдельно stderr.

Мутанты двери. Каждый — одна замена в scripts/done_contract.sh с assert count==1, в отдельной копии клона run. Прогон — только done-клетки (13) через публичную дверь (`$TMPDIR/done_only.py`, фильтр CASES по action=done, `--repo <мутант>`). Контроль без мутации: `CELLS=13 FAILURES=0`, rc 0.
  M1 ARCH_REVIEW снова `die` (прежняя фраза), замена :311 → КРАСНЫЙ, rc 1, FAILURES=7: done-review-missing-warns, done-review-heading-warns (rc=1 вместо 0); done-ci-{missing,other-sha,red,skipped,head-ahead}-warns (вывод «ARCH_REVIEW: …» без ARCH_CI). Это тот же набор 7, что лист заявляет красным на старой двери.
  M2 предупреждение не печатается (`:` вместо :311) → КРАСНЫЙ, FAILURES=7: те же 7 клеток (rc верный, предупреждения нет).
  M3 ARCH_CI тоже предупреждение (:370 `|| die "ARCH_CI…"` → `|| printf 'ПРЕДУПРЕЖДЕНИЕ: ARCH_CI…' >&2`) → КРАСНЫЙ, FAILURES=10: done-ci-{missing,other-sha,red,skipped,head-ahead} и все 5 done-ci-*-warns (rc=0 вместо 1, тег встал бы).
  M4 предупреждение всегда (:307 → `if true`) → КРАСНЫЙ, FAILURES=6: done-valid (rc 0, но лишний ПРЕДУПРЕЖДЕНИЕ) и 5 исходных done-ci-* (предупреждение при самостоятельной строке).
  M5a проверка свидетельства пропущена целиком (:307 → `if false`) → КРАСНЫЙ, FAILURES=7: обе review-warns и 5 ci-warns.
  M5b чужая строка или цитата засчитывается (:294 `'СВЕРКА-АРХИТЕКТУРЫ:'*)` → `*'СВЕРКА-АРХИТЕКТУРЫ'*)`) → КРАСНЫЙ, FAILURES=7: done-review-missing-warns (inline-цитата), done-review-heading-warns (заголовок `## СВЕРКА-АРХИТЕКТУРЫ`) и 5 ci-warns.
  M5c пустой хвост засчитывается (:296 → `if true`) → ЗЕЛЁНЫЙ, FAILURES=0. Мутант выжил. Пробел был и на базе: единственная прежняя клетка `done-review-missing` несла только inline-упоминание. → совет С-1.
  M6 предупреждение, затем `exit 1` (после :311) → КРАСНЫЙ, FAILURES=7: review-warns rc=1 вместо 0; ci-warns без ARCH_CI.
  M7 (свой) предупреждение в stdout вместо stderr (снят `>&2` с :311) → КРАСНЫЙ, FAILURES=7: обе review-warns и 5 ci-warns (done_observed читает stderr отдельно).
Стабы модели (--stabs, 93/93 пойманы) дополняют это теми же дефектами на модели: refuse-review, ignore-review, warning-on-stdout, warning-no-verdict, warning-no-advice, no-done-tag, warn-valid, warning-after-ci. Привязки — по коду (STABS → CASES), не прозой контракта (Н-39).

══ (4) ЧЕСТНОСТЬ ЗАМЕНЫ ОБЯЗАТЕЛЬСТВ ══
grep -n ARCH_REVIEW contracts/187-…md contracts/201-…md → 187:41, 187:52, 201:22, 201:34, 201:331.
  Тело PR называет 187:41, :52 и 201:34, :331 — совпадает с фактом.
  201:22 (инвентарь «187/2 (ARCH_REVIEW/ARCH_CI…)») в теле PR не назван. Лист sdacha_187.md:104-106 называет его историческим инвентарём, не отдельным отказом → совет С-3.
ADR §3 покрывает «187/2 (ARCH_REVIEW), 201/1 :34 и :331». Frozen-тексты не правлены (diff 3 файлов).
git grep -n ARCH_REVIEW -- . ':!verdicts' вне 187/201: ADR, docs/owner/adr/README.md:76, лист, workflow_probe.py, сама дверь. В roles/, AGENTS.md и прочих документах ARCH_REVIEW как отказ не объявлен.
Норма roles/reviewer.md §Архитектура 188 («напиши самостоятельную строку СВЕРКА-АРХИТЕКТУРЫ:») остаётся поведенческой нормой роли. С предупреждением двери она не спорит.

══ (5) КЛАСС РИСКА ══
Обычный, оставляю. Ослаблена одна ветка, на это есть ADR владельца. Удержание ARCH_CI доказано красным M3 и зелёными 201 g-* и done-ci-*.

══ ПАРАЗИТНАЯ СЛОЖНОСТЬ (050), ответы (1)–(5) ══
  • ветка-предупреждение двери (done_contract.sh:307-311):
      (1) ADR Б-3 «предупреждение с записью вместо отказа»;
      (2) состояния нет, видна в stderr;
      (3) 1 файл; число не выросло;
      (4) интерфейс прежний (коды 0/1/2, аргументы, env); +1 строка stderr;
      (5) клетки *-warns, M1/M2/M6/M7 красные.
      ESSENTIAL.
  • REVIEW_WARNING_PREFIX / REVIEW_WARNING / DONE_TAG (workflow_probe.py:121-125):
      (1) наблюдение текста предупреждения и тега;
      (2) константы, без состояния;
      (3) при смене формулировки двери меняются дверь и префикс либо подстроки done_observed: 2 файла, как у любой дословной причины;
      (4) —;
      (5) done_observed и модель.
      ESSENTIAL.
  • CI_VARIATIONS / WARN_VARIATIONS и генераторы CASES/STABS (:126-128):
      (1) порядок «предупреждение до ARCH_CI» на каждой CI-ветке;
      (2) нет;
      (3) 1;
      (4) —;
      (5) 5 ci-warns, M1/M3 красные.
      ESSENTIAL.
  • prepare: вариация review-heading (:982) и снятие суффикса -warns (:1087-1088):
      (1) «упоминание внутри чужой строки» в формах inline и заголовок;
      (2) явно во входе мира;
      (3) 1;
      (5) M5b красный.
      ESSENTIAL.
  • model_done (:1445):
      (1) модель и стабы судятся тем же оракулом каналов (stderr, тег), что и живая дверь;
      (2) создаёт настоящий тег в toy-мире модели, явно;
      (3) 1;
      (5) --model/--stabs.
      ESSENTIAL.
  • done_observed (:1456):
      (1) 187:52 «done-тег отсутствует» плюс канал stderr предупреждения;
      (2) читает тег и stderr после вызова, ожидания сняты до вызова;
      (3) 1;
      (5) все 13 done-клеток, M7 красный только им.
      ESSENTIAL.
  • 19 новых стабов — одна семья:
      (1) каждый дефект канала Б-3;
      (5) --stabs 93/93.
      ESSENTIAL.
Более простой формы, проходящей те же строки приёмки, не нашёл.

СВЕРКА-СТАНДАРТОВ: AGENTS.md dev-harness не объявляет docs/ARCHITECTURE.md и docs/CODING-STANDARDS.md (grep — 0 совпадений; файлов в дереве нет). Сверять дифф не с чем. Стиль двери соответствует соседним веткам: printf … >&2, как у прочих диагностик в stderr; `die` не переопределён.
СВЕРКА-АРХИТЕКТУРЫ: размещение — 1 строка поведения в scripts/done_contract.sh (зона implementer), клетки в семье architecture_process_187 (зона architect). Новых зависимостей нет: bash printf, python stdlib subprocess. Писатели не добавлены: done-тег по-прежнему ставит только дверь, модель тег ставит в своём toy. Операции и bindings.json не затронуты, долг не расширен. Diff модели нет, L-уровень не применим. tooling/checks/cli.js в дереве нет, находку архитектуры заводить нечем и не по чему.
ПРОВОДКА: guard предмета — red_architecture_process_187.sh. Подключение — `--wiring .` rc 0. Новые клетки исполняются им же, мутанты M1–M7 краснят его done-клетки.
ОСТАТОК (контракт 192): в «НЕ ЗАЩИЩАЕТ» frozen 187 (:72-75) строк с ловцом reviewer нет, класса К-NN для отметки нет.
РЕЖИМ ПРОЕКТА (996): sourceCanon не объявлен (лист К-17 н/п), gate сверки не применим.

══ БЛОКИ ══
нет.

══ РАЗВИЛКИ ══
  - fixtures/done_contract/case_verdikt_fail.sh — case-фикстура, ей нужны WORK/BARRIER от раннера. Голый запуск: rc 1 «WORK: unbound variable», вне предмета. Её раннер (precision/antiplacebo) в CI зелёный, сам не гонял.
  - Не запускал fixtures/_krasnye_038.sh, fixtures/check_consumers/*, fixtures/check_provodka/external_ci_994/baseline_038.sh, fixtures/freeze_contract/{fail_closed_992.py,model_992.py,red_consumers_gejt_038.sh}, fixtures/workshop_project/rezhim_996. Ни один из них не содержит `Complior-back` и `СВЕРКА-АРХИТЕКТУРЫ` (git grep rc 1), то есть изменённая ветка за arch187_scope им недостижима. Они покрыты CI head (16 success).
  - Мутанты гонялись только на 13 done-клетках, а не на всех 67: ветка достижима только из action=done.
  - «Запись» предупреждения: только stderr; условие пересмотра ADR («записи warn в учёте замка/журнале») механизма не имеет → совет С-2, вопрос владельцу.
  - Дверь в done 187 при её запуске пройдёт гейт потребителей 116: писатель scripts/done_contract.sh изменён, у него есть consumers.d/done_contract.sh__check_spec_ready_sh.tsv. Это дело done, а не этого суда [INFERENCE: check_consumers на 187 не запускал].

СОВЕТЫ: `.review/2026-11-21-125.md`:
  - С-1 — нет клетки на пустой хвост, M5c выжил;
  - С-2 — stderr вместо долговечной записи, условие пересмотра ADR не измерить;
  - С-3 — 201:22 нет в теле PR.

ИСПРАВЛЕННЫЕ ОШИБКИ СВОИХ КОМАНД:
  1) запись без cwd и запуск с /dev/null-редиректом → отказ стража Н-85. Повторил по абсолютным путям, вывод — в файлы scratch.
  2) черновой python-однострочник с лишним путём записи → отказ стража. Убрал лишнее, повторил.
МАТЕРИАЛЫ: $PWD/.scratch-rev187b3/{run,base,mut-M*,mutants.py,done_only.py}. Push не делал, в основной чекаут и чужие worktree не писал, тег done не ставил.
