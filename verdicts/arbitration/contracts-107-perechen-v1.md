РЕШЕНИЕ
OBJECT=a4520d9b626457259673bbbe7679051331384596

# Арбитраж 107 — критерий обязан замыкать ЗАКРЫТОЕ произведение осей, записанных в самом контракте (поля доказательства × admission; действие × вектор эффектов × состояние; исход ack × время × порядок; сценарий mock → экран), а не ряд одиночных обходов

МОДЕЛЬ: `anthropic/claude-fable-5-1`, арбитр (Arbiter107), 2026-10-19. Асимметрия семейства записана в `roles/arbiter.md`: делю семейство с автором конструкции (architect). Все четыре спорных пункта решены замером (З-0…З-4); не сводятся к замеру два места и помечены: включение исхода `reject` в перечень К7 (Решение 2, довод — текст контракта :96) и граница К9 «mock → экран, не app-маршрут» (Решение 2).

## Итог

- **По существу четырёх находок Бб1–Бб4 — критик прав:** каждая из них ловит утверждение контракта, доказанное слабее, чем написано (инварианты 3, 5, 6 — :41/:43/:44; К9 :63), а не новое требование. Все пять мутантов круга 2 воспроизведены на МОЁМ клоне и МОЁМ R: обычные пробы OBJECT и обе матрицы rc0 на каждом, свидетели критика красны на именованных клетках (З-1). Honest-модель автора выполняет замкнутый перечень ниже на 225 клетках из 229; четыре красные — исход `reject` (З-3), и это дефект эталона под собственным пунктом контракта :96 («явный именованный отказ» http-runtime), закрывается одной строкой (`.catch`, З-4: 229/229).
- **По методу — автор прав:** критерий не может расти «ещё одним мутантом» каждый круг. Класс закрывается КОНЕЧНЫМ произведением осей, уже объявленных в контракте (Решение 2: К5′–К9′, 229 клеток, 7 с Jest), после чего обход ВНЕ перечня — совет и круг не роняет. Двойной ack, реальный HTTP, app-композиция (route-файлы, http-runtime) — ВНЕ перечня: критик сам ими не блокировал, и я их не вношу.
- **Нарезки нет; круг 3 — в пределах капа 3** (tri-slota §3). Предмет круга 3 закрыт перечнем К5′–К9′ и правками П1–П6; FAIL круга 3 по пункту перечня = кап достигнут → К ВЛАДЕЛЬЦУ. Все правки — ЗОНА architect (контракт + `fixtures/workshop_project/erstinfo_107/`); зона implementer и B не трогаются.

## Созыв и первоисточники

Созван строкой `АРБИТР:` вердикта круга 2 (правило 15 AGENTS.md; повтор причины по тем же осям Б1–Б4). Прочитаны полностью: `roles/arbiter.md`; `docs/owner/2026-10-18-tri-slota.md` §3; `verdicts/critic/contracts-107-krug1-fail.md` (origin/main bd8be6eb); вердикт круга 2 — на origin/main ОТСУТСТВУЕТ, прочитан из `/tmp/dev-harness-verify/Critic107r2/verdict.md` (первоисточник критика, read-only; расхождение с брифом «на main» записано, на суждение не влияет); контракт `contracts/107-cmp-mob-003-erstinformation.md`, `fixtures/workshop_project/erstinfo_107/{erstinfo.test.tsx,erstinfo_probe.py,erstinfo_static_probe.py,probe_lib.py,source.json,model/*}` на OBJECT (мой клон `/tmp/dev-harness-verify/Arbiter107/dh`, `git rev-parse HEAD` = OBJECT, porcelain 0 после всех прогонов); репро критика `/tmp/dev-harness-verify/Critic107r2/{measure.py,controls.py,witness.test.tsx,runtime-witness.test.tsx}` — только чтение, MUTANTS перенесены байт-в-байт (diff строк 39–47 пуст); прецеденты `verdicts/arbitration/contracts-999-perechen-v1.md`, `contracts-998-perechen-vetvej-v1.md`; issue a3ka/Complior-mob#7 — из `Critic107r2/primary-issue.log` (живой `gh issue view` критика): работа 5 «повторно читать evidence без автоматического продолжения бизнес-процесса», критерий «после ack перечитать текущее evidence».

Письменного несогласия architect'а в первоисточниках нет; позиция автора взята из брифа оркестратора и сообщения коммита OBJECT («закрытие осей Б1–Б4 … произведение состояний × версий × admission»).

Отклонение от брифа: `git clone ssh://git@github.com/a3ka/Complior-mob.git` дважды вернул `ERROR: Repository not found` (rc=128; `ssh -T git@github.com` аутентифицирует как a3ka; тот же отказ даёт `git ls-remote` из клона критика). Мой `mob` клонирован из `/tmp/dev-harness-verify/Critic107r2/mob` (клон критика с origin GitHub) и выставлен на B `76ac10fac668a1036371c4b392061ce9b3277ebc` — содержимое проверяется SHA; основной чекаут не открывался.

## Замеры

Каталог `/tmp/dev-harness-verify/Arbiter107/`: `dh/` (OBJECT), `mob/` (B, `npm ci` rc0, `status --short --untracked-files=all` → 0 строк до и после каждого режима), `measure.py` (копия критика с заменой ROOT/H/имени теста; sha256 `2202f415fed48e49…`), `witness.test.tsx` (байт-в-байт критика, `0b05d583352e9708…`), `closure.test.tsx` (мой свидетель закрытого перечня, `68e903ce007c41dd…`), `closure.py`/`closure2.py`. Логи: `logs-{baseline,mutations,controls,closure,closure2}.txt` и `<label>.log` с полной командой, cwd и `rc=`. `TMPDIR` внутри каталога, `PYTHONDONTWRITEBYTECODE=1`.

**З-0. Baseline OBJECT** (`python3 measure.py baseline`):
```
B-erstinfo_static_probe rc=1   ERSTINFO_MODULE_ABSENT
B-erstinfo_probe        rc=1   ERSTINFO_COMPONENT_ABSENT
model-erstinfo_static_probe rc=0   static 22/22
model-erstinfo_probe        rc=0   honest 95/95
matrix-erstinfo_static_probe rc=0  mutants 4, defects 0
matrix-erstinfo_probe        rc=0  mutants 18, defects 0
```

**З-1. Пять мутантов критика круга 2, каждый отдельно** (`python3 measure.py mutations`; обычные пробы OBJECT на мутированном R → свидетель критика):
```
control-witness (модель без правок)      rc=1  17 клеток, красны 3: rejected-ack W0/W1A (unhandled rejection эталона), runtime-composed (ошибка matcher'а критика, им же отозвана)
evidence-coabsent-fallback  static rc=0 probe rc=0  witness rc=1  8/4 RED: evidence-combination {W0,W1A} × ref={null,''} required=4
retry-business-transition   static rc=0 probe rc=0  witness rc=1  2/2 RED: retry-is-read-only W0, W1A
recheck-before-settlement   static rc=0 probe rc=0  witness rc=1  2/2 RED: ack-settlement-order W0, W1A
recheck-success-only        static rc=0 probe rc=0  witness rc=1  2/2 RED: rejected-ack W0, W1A
runtime-incomplete-gate     static rc=0 probe rc=0  witness rc=1  1/1 RED: runtime-composed-current-evidence
```
Положительные контроли (`controls.py`, `controls2.py` — строки критика): `control-valid-paths` rc=0 14/14 на чистой модели; `control-rejection-handled` rc=0 2/2 (модель + терминальный `.catch`); `control-runtime` rc=0 1/1 (`runtime-witness.test.tsx` на модели); `incomplete-runtime-corrected` rc=1 (`Unable to find an element with testID: erstinfo-evidence-checked-at`). Факты критика подтверждены в обе стороны.

**З-2. Факты по коду OBJECT (чтение):**
- `erstinfo.test.tsx:232–248` — `EVIDENCE_INVALID` шесть ОДИНОЧНЫХ patch'ей поверх валидного gate; ни одна клетка не подаёт два негодных поля сразу. Инвариант 3 (:41): «пригодное evidence (delivery_evidence_ref — непустая строка, checked_at непуст) … Любое нарушение → disclosure.updated».
- `erstinfo.test.tsx:181–186` `FAILED_RETRY_ACTION` — проверяет `recheck=1`, `ack=[]`; `cont` и `open` не наблюдаются. Модель `:226` `onPress={() => onRecheck?.()}`. Инвариант 6 (:44): continue «только при admission=W1A ∧ полном доказательстве», «побочные эффекты действий разделены»; issue #7 работа 5.
- `erstinfo.test.tsx:303–323` `ACK_VERSION_CHANGES` — итоговое `recheck=1` ПОСЛЕ resolve; между press и resolve счётчик не читается; исход — только `resolve({accepted:false})`. Инвариант 5 (:43): «наблюдает ЗАВЕРШЕНИЕ Promise … и ПОСЛЕ него перечитывает gate». Модель `:128–133`: `Promise.resolve(onAcknowledge?.(…)).finally(() => onRecheck?.())` — recheck после settlement есть, но rejected Promise не обработан. Контракт :96: http-runtime «расширяет объект ApiClient операциями acknowledgeDisclosure/getDisclosureGate (до CMP-BCK-008/024 — с явным именованным отказом, не тихим заглушка-нуль)» — т.е. на C экран ПО КОНТРАКТУ получит rejected Promise.
- `erstinfo.test.tsx:417–425` `RUNTIME_GATE_SNAPSHOT` — `toMatchObject` по 5 полям из 7 типа `DisclosureGateSnapshot`; `checked_at`, `responsible_entity_id` не сверяются; снимок runtime в экран не подаётся. `model/mocks.runtime.ts:69` `getDisclosureGate = async () => gateMock()`.
- `source.json` `source_sha256.ui_copy_b` — 63 символа (`…fbfe55a7646a1`), фактический sha256 на B `…fbfe955a7646a1` (пропущена цифра) — подтверждаю совет критика; на поведение не влияет.

**З-3. Мой свидетель закрытого перечня (Решение 2) на honest-модели и на пяти мутантах** (`python3 closure.py`; 229 клеток: К5′ 96, К6′ 100, К7′ 12, К8′ как на OBJECT, К9′ 21):
```
closure-model                      rc=1  229, failed 4: B3 {W0,W1A} × moved={false,true} × reject   (ACK_NAMED_FAILURE — unhandled rejection эталона; recheck при этом ВЫЗВАН)
closure-evidence-coabsent-fallback rc=1  failed 8  = 4 модели + B1 {W0,W1A} × ref∈{null,''} × checked='' (остальные поля валидны)
closure-retry-business-transition  rc=1  failed 8  = 4 модели + B2 {W0,W1A} × FAILED × {EQ,STALE} × erstinfo-retry
closure-recheck-before-settlement  rc=1  failed 12 = B3 все 12 клеток (recheck до settled)
closure-recheck-success-only       rc=1  failed 4  = B3 reject ×4 (совпадает с моделью — см. З-4)
closure-runtime-incomplete-gate    rc=1  failed 5  = 4 модели + B4 runtime gate equals full declared snapshot and drives CURRENT_CONFIRMED on screen
closure-status                     rc=0  (git status пуст)
```

**З-4. Эталон с терминальным `.catch`** (`python3 closure2.py`; одна замена в модели `.finally(...)` → `.finally(...).catch(() => undefined)`):
```
closure-model-catch   rc=0  229 клеток, failed 0
closure-success-only  rc=1  failed 4: B3 reject ×4   (мутант критика различим только когда эталон обрабатывает reject)
```
Вывод: перечень К5′–К9′ конечен, honest-модель выполняет его целиком после одной строки; каждый из пяти обходов круга 2 красен на своей клетке перечня; обход вне перечня перечню не нужен.

## Решение 1 — кто прав по каждому пункту

Правило владельца (tri-slota §3): повтор класса чинится обобщённо; на поздних кругах блокирует доказанное нарушение принятого требования или недостоверное доказательство, новое требование — совет.

| находка круга 2 | основание | статус |
|---|---|---|
| Бб1 совместное отсутствие полей evidence | Инвариант 3 (:41) — конъюнкция и «любое нарушение»; К5 (:59) доказывает только одиночные нарушения (З-2). Обход проходит пробы OBJECT (З-1). Это не «2^k вкусовых комбинаций», а предикат, объявленный автором как конъюнкция k условий: доказательство, что ЛЮБОЕ нарушение даёт OUTDATED, — произведение значений полей, не k одиночек | **БЛОКЕР**, критику целиком |
| Бб2 retry → onContinue | Инвариант 6 (:44): continue только при W1A ∧ доказательство, эффекты действий разделены; issue #7 работа 5. `FAILED_RETRY_ACTION` не читает `cont`/`open` (З-2). Круг 1 Б2 был тем же классом («не все запрещённые эффекты наблюдены»), закрыт точечно для open/ack/continue, но не для retry/back — нарушение правила «повтор класса чинится обобщённо» | **БЛОКЕР**, критику целиком |
| Бб3а порядок recheck относительно settlement | Инвариант 5 (:43) буквально «ПОСЛЕ завершения Promise»; К7 читает счётчик только в конце (З-2); мутант «recheck сразу» проходит (З-1) — проверено слабее, чем написано | **БЛОКЕР**, критику целиком |
| Бб3б rejected Promise | Порт объявлен `Promise<…>`; контракт :96 САМ предписывает http-runtime отвечать именованным отказом — на C это rejected Promise, и экран обязан «наблюдать завершение» и такого исхода. Эталон оставляет rejection необработанным (З-3) — дефект эталона под собственным пунктом контракта, закрывается одной строкой (З-4) | **БЛОКЕР**, критику; уточнение: перечень исходов конечен — {accepted:true, accepted:false, reject} |
| Бб3в двойной ack / обратный порядок завершения | Критик сам не блокирует (контроль зелёный). Контракт не объявляет конкурентные ack | ВНЕ перечня — совет |
| Бб4 runtime отдаёт непригодный, но «похожий» снимок | К9 (:63) обещает «настоящий runtime исполняет getDisclosureGate» и «gateFor возвращает заявленное состояние/версию/evidence»; `toMatchObject` по 5 из 7 полей — слабее типа, объявленного инвариантом 1 (:39). Свидетель критика и мой используют ТОЛЬКО `@/mocks/runtime` + порты экрана — оба в зоне проб и уже импортированы К9; это НЕ app-композиция C (route-файлы, http-runtime), которая остаётся Maestro | **БЛОКЕР**, критику; граница: замыкается сверкой ПОЛНОГО снимка по типу и подачей снимка каждого mock-сценария в экран, не route-композицией |
| Довод автора «перечень растёт каждым мутантом» | Верен как опасение, неверен как возражение на эти четыре находки: все четыре — внутри осей, записанных в контракте. Закрытие — Решение 2; после него обход вне перечня не блокирует | частично автору — метод |
| Довод автора «реальный HTTP, композиция C — вне предмета» | Верно и не оспаривается критиком; ни одна из Бб1–Бб4 этого не требует (З-1, З-3: только mocks/runtime и порты) | автору; к спору не относится |

**Граница для круга 3** (обязательна обеим сторонам): блокирует только (i) невыполненный пункт К5′–К9′ / П1–П6; (ii) эталон, модель или клетка, сами нарушающие пункт К (недостоверность); (iii) регресс закрытого (К1–К4, К8, статическая семья, свидетели круга 1 61+2). Новый мутант вне перечня — совет.

## Решение 2 — ЗАКРЫТЫЙ перечень К5′–К9′ (порог заморозки)

Грамматика — из `source.json` (контракт :51: единственный источник), циклы, не ручной список. Единица — клетка с координатами в имени. Образец — `Arbiter107/closure.test.tsx` (замер, не оракул для копирования).

**К5′ — доказательство (инвариант 3). Произведение ЗНАЧЕНИЙ полей, не одиночные patch'и.**
`ref ∈ {valid, null, ''} × checked_at ∈ {valid, ''} × document ∈ {same, other} × applicability ∈ {REQUIRED, UNKNOWN} × version ∈ {EQ, NOT_EQUAL}` = 48 комбинаций × 2 admission = 96 клеток; ровно одна комбинация валидна (evidence-карта; continue ⇔ W1A), 47 → `disclosure.updated`, без evidence и continue. Это замыкает «любое нарушение»: мутант, различающий подмножества полей, различим. `evidence_invalid` в source.json переписать как значения полей (или оставить и породить произведение из него — форма на выбор автора, обязательна грамматика). Вне перечня: типы значений за пределами объявленных (`undefined`, не-строки) — TypeScript, совет.

**К6′ — действия (инварианты 4–6, issue #7 работа 5). Каждое доступное действие × полный вектор эффектов × состояние × версия × admission.**
`A = {open, retry, confirm, continue, back}` (все `testID` действий экрана по контракту :48–50 и инварианту 3 «FAILED + retry»); `E = (open, ack, recheck, cont)` — ВСЕ четыре порта-наблюдателя в каждой клетке. Для каждой клетки `state × axis × admission` (5×2×2=20) и каждого `a ∈ A`: (а) доступность `a` ровно по правилу (retry ⇔ FAILED; confirm ⇔ CURRENT_CONFIRMED; continue ⇔ W1A ∧ CURRENT_CONFIRMED ∧ EQ; open/back всегда); (б) после нажатия вектор E равен ожидаемому: open→(1,0,0,0), retry→(0,0,1,0), confirm→(0,1,1,0) после settlement, continue→(0,0,0,1), back→(0,0,0,0). 100 клеток. `ACTION_*` и `FAILED_RETRY_ACTION` на OBJECT растворяются в них. Вне перечня: повторные нажатия одного действия, конкурентные ack (Бб3в).

**К7′ — время и исход ack (инвариант 5). Исход × версия ушла × admission, с ПОРЯДКОМ.**
`outcome ∈ {resolve accepted:true, resolve accepted:false, reject}` × `moved ∈ {нет, да: gate → STALE до settlement}` × admission = 12 клеток. В каждой: события `ack-start → settled → recheck` (до settlement recheck = 0, после = ровно 1), `cont = 0`, continue виден ⇔ W1A ∧ ¬moved ∧ исход не reject (при reject после recheck решает новый gate; до него — не показывать). Помечено как суждение: исход `reject` в перечне — довод :96 (контракт сам предписывает именованный отказ http-runtime до бэкенда). Следствие для эталона: обработать rejection (терминальный `.catch` или эквивалент — выбор автора), иначе клетка reject недостоверна (З-3/З-4). Вне перечня: политика retry/backoff, текст ошибки, telemetry.

**К8′ — серверная грамматика: как на OBJECT** (MISSING/UNKNOWN/NOT_REQUIRED × admission, snapshot absent × admission). Не оспорено, не меняется.

**К9′ — mock/runtime → экран (Б4). Сценарий × admission + полный снимок.**
(а) для каждого `MOCK_SCENARIO (state × axis)` ×  admission — gate = настоящий `gateFor(state, axis)` подаётся в экран, наблюдается заявленное состояние (notice/evidence по К1) и continue ⇔ W1A ∧ CURRENT_CONFIRMED ∧ EQ — 20 клеток; (б) `RUNTIME_GATE_SNAPSHOT`: `toEqual` ПОЛНОМУ объявленному снимку (все поля типа `DisclosureGateSnapshot` из api-client.ts) + подача этого снимка в экран → evidence-карта с `checked_at`, continue при W1A — 1 клетка; `RUNTIME_ACK_EXECUTES`, `MOCK_ACK_RECORDS` — как есть. Помечено как суждение: граница К9′ — `mocks/runtime.ts`/`mocks/disclosure-mock.ts` через порты (зона проб), НЕ `app/`-маршруты и НЕ `http-runtime.ts` (композиция C — Maestro, контракт :76/:96 — без изменений).

**Что НЕ блокирует круг 3** (переоткрывается только ссылкой на этот файл): двойной/конкурентный ack; реальная HTTP-доставка (CMP-BCK-008/024); app-маршруты и http-runtime (Maestro на C); поля `snapshot_required` сервера сверх клиентского типа (actor/subject/scope/policy — совет С3 критика, владелец композиции); resume/reconcile/replay/outage; copy signoff; состав декоев сверх П5; гранулярность `it` при сохранённой грамматике; опечатка хэша `ui_copy_b` (исправить по П6, но сама по себе не блокер).

## Решение 3 — что делает architect (один круг) и как судит критик

Все правки — ЗОНА architect. Реализация/зона implementer/B не затрагиваются (З-4: модель выполняет перечень после одной строки).

**П1 — К5′ (`erstinfo.test.tsx`, `source.json`).** Произведение значений полей (96 клеток), имена с координатами (например `EVIDENCE_REF<v>_CHK<v>_DOC<v>_APPL<v>_VER<v>_<adm>`); одна валидная клетка — положительный контроль.
**П2 — К6′.** Циклы `admission × state × axis × action` с полным вектором (open, ack, recheck, cont) и правилом доступности; `FAILED_RETRY_ACTION`/`ACTION_*` растворить или оставить как контроль.
**П3 — К7′.** 12 клеток с управляемым Promise, журналом событий и двумя точками наблюдения (до/после settlement); исход reject — обязателен. Эталон `model/features.onboarding.erstinformation.tsx:128–133`: обработать rejection (см. З-4).
**П4 — К9′.** 20 клеток `gateFor → экран` + `RUNTIME_GATE_SNAPSHOT` на `toEqual` полному снимку с подачей в экран.
**П5 — матрицы `MUTANTS`.** Добавить как декои с named-клеткой и измеренным `depends`: `evidence-coabsent-fallback`, `retry-business-transition`, `recheck-before-settlement`, `recheck-success-only`, `runtime-incomplete-gate` — патчи байт-в-байт из `Critic107r2/measure.py` (= `Arbiter107/measure.py:39–47`). `depends` допустимо порождать генератором по грамматике; побочная краснота вне named ∪ depends — дефект.
**П6 — текст контракта.** «ЗАКРЫТЫЕ ПЕРЕЧНИ» (:51) и К5–К9 (:59–63) переписать по К5′–К9′ с явным «не входит» (список выше); приёмочный критерий (:70–72): фактические числа клеток и мутантов (сейчас 95/22 и 18/4); `source.json` `ui_copy_b` — полный 64-символьный sha256; §Фактический замер — заново на новом коммите: B → rc1 именованно; `--model` → rc0 с новыми числами; `--matrix` обеих проб → rc0, unexpected_red=none; пять мутантов П5 по отдельности → rc1 на своей клетке; combined критика (`Critic107r2/combined.py`) → rc1; свидетели круга 1 (61+2) и критика круга 2 (`witness.test.tsx` 17 клеток, `runtime-witness.test.tsx`) → rc0 без красных; `git status` R пуст; `pre_critic`, `check_precision_gate`, `check_threat_model`, `check_provodka` — заявленные rc.

**Круг 3 критика.** Кругов пройдено 2, кап — 3 (tri-slota §3): круг 3 штатный, слово консультанта/владельца не требуется. Предмет круга ЗАКРЫТ: (1) сверка П1–П6; (2) К5′–К9′ — каждая клетка есть и порождена циклом по грамматике, пять мутантов П5 красны на своих клетках, эталон зелёный целиком; (3) прежние команды критерия — заявленные rc; (4) закрытое кругами 1–2 (К1–К4, К8, статика, свидетели) не регрессировало. **Критерий accept: нет обхода ВНУТРИ перечня К5′–К9′.** Обход ВНЕ перечня — совет, круг не роняет. FAIL круга 3 по пункту перечня = кап достигнут → К ВЛАДЕЛЬЦУ (микро-круг после капа — мандат консультанта tri-slota §2, не арбитра).

## Счёт по сторонам

- Критику: все четыре находки по существу (Бб1, Бб2, Бб3а/б, Бб4); метод «доказано слабее, чем написано» подтверждён замером на каждом пункте; факты круга 2 воспроизведены без расхождений.
- Автору: класс закрыт КОНЕЧНЫМ перечнем К5′–К9′ (229 клеток, ~7 с Jest), а не «любым новым обходом»; двойной ack, HTTP, app-композиция — вне перечня, как автор и утверждал; модель честна по 225/229 без правок и по 229/229 после одной строки; зона implementer не затронута; нарезка не нужна; круг 3 в пределах капа; форма генерации и гранулярность — выбор автора.
- Против критика: ничего по существу. Уточнения границ: Бб4 замыкается mock/runtime → экран, не route-композицией; Бб3 — исходы конечны (три), конкурентные ack вне перечня.

## К ВЛАДЕЛЬЦУ (не решаю)

Ничего обязательного. Для сведения: прогноз цены круга 3 — один коммит architect (один тест-файл, одна строка модели, source.json, абзац контракта, 5 декоев) + один суд критика. Репозиторий `a3ka/Complior-mob` на момент арбитража не отдаётся по SSH («Repository not found» при валидной аутентификации a3ka) — если это переименование/приватизация, implementer и CI без исправления адреса не стартуют; владение — владельца.

## Артефакты

`/tmp/dev-harness-verify/Arbiter107/`: `dh/` (OBJECT, porcelain 0); `mob/` (B, clean); `measure.py`, `controls.py`, `controls2.py`, `closure.py`, `closure2.py`, `witness.test.tsx` (критика, байт-в-байт), `runtime-witness.test.tsx` (критика), `closure.test.tsx` (мой); `logs-*.txt` и `<label>.log` с полными командами и rc; `summary-*.json`, `closure-*.json` (Jest JSON). Read-only каталоги критика/архитектора не изменены; основной чекаут не открывался; commit/push не выполнялись. Коммит под `-c user.name=arbiter -c user.email=arbiter@dev-harness.local` в `verdicts/arbitration/contracts-107-<slug>-v1.md` — оркестратору.
