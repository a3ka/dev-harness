accept
OBJECT=5f72912383e372844de256d32b4cce2e33225c0b
СУД: repo=dev-harness; предмет=153; фаза=контракт (+красная батарея), scoped по дельте arbitraz П1–П5 + зависимый регресс; роль=critic; вызов=3 (ДОПОЛНИТЕЛЬНЫЙ, исключение=слово владельца 2026-11-01); сессия=Crit153c; модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5; SHA=5f72912383e372844de256d32b4cce2e33225c0b; предыдущие=verdicts/critic/contracts-153-v1-fail.md (FAIL, OBJECT bcacc85ca), verdicts/critic/contracts-153-v1b-fail.md (FAIL, OBJECT 67cb212d1), verdicts/arbitration/contracts-153-arbitraz.md (РЕШЕНИЕ, Arb153)
РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/153-*.md — один дополнительный scoped-вызов критика (вызов 3) только по дельте architect по РЕШЕНИЮ арбитража contracts-153-arbitraz.md и зависимому регрессу; при FAIL — стоп и решение владельца (слово владельца 2026-11-01)

Независимость: автор дельты — architect, сессия Arch153c, модель-факт openai-codex/gpt-6-sol (yield транскрипта history://Arch153c, `%an = architect` на OBJECT); критик — anthropic/claude-opus-5-5 (семейство Anthropic ≠ OpenAI). Судья не автор конструкции. Арбитр Arb153 — anthropic/claude-fable-5-1; consultant/arbiter не совмещены этой сессией.

Итог: БЛОКИРУЕТ — 0. Каждый пункт П1–П5 исполнен, закрывающее свойство блока закрыто и подтверждено исполнением (ниже — сырые прогоны). САМООПИСАНИЕ — расхождений, меняющих смысл, нет (полный список ниже). СОВЕТЫ — 3, accept не отменяют.

## Предмет и база

- `git cat-file -t 5f72912383e3…` → `commit`. Одноразовый клон `/tmp/dev-harness-verify/Crit153c/repo` (`git clone /home/harness/dev-harness`, `fetch wip/153/architect`, checkout OBJECT). Основной чекаут не тронут (`git -C /home/harness/dev-harness status --porcelain | wc -l` → 0); push нет; GIT_DIR/GIT_WORK_TREE не ставились; эмуляторы и нативные сборки не запускались. Клон после всех прогонов: `git status --porcelain` пусто.
- ЗАМЕЧАНИЕ к заданию (не к автору): `67cb212d1` НЕ предок OBJECT (`git merge-base --is-ancestor 67cb212d1 HEAD` → rc 1): автор перебазировал ветку на main 035bbd21c, родитель OBJECT — `bb2fbfc2d` (перебазированная копия 67cb212d1). Поэтому `git diff 67cb212d1 5f72912383 --stat` даёт 9 файлов (7 — изменения main). Предмет суда — коммит дельты `bb2fbfc2d..5f72912383`: ровно 2 файла (`contracts/153-nul-v-puti-istochnika.md` 13+/6−, `fixtures/workshop_project/nul_istochnika_153/probe.py`); `git diff --stat bb2fbfc2d 67cb212d1` не содержит этих двух файлов — их содержимое у 67cb212d1 и bb2fbfc2d одинаково, т.е. дельта по двум файлам та же.

## П1–П5 — выполнено/нет

**П1 (клетка sweep) — ВЫПОЛНЕНО.** `probe.py:125` ALPHABET=`01a/.-_\` (8 символов), `:130-146` генерация длин 1..5 и трёхклассовое разбиение (`/`-префикс или `..` → грамматика; хвост `/` или последний компонент `.` → не-regular; остальное — положительные), `:126-127` + `:144-146` сверка констант (расхождение → `sweep: RED DOMAIN_COUNTS …` :169), `:149-163` создание по сырой строке `os.open` + S_ISREG + realpath внутри R, `:166-211` партии по длине, конфликт файл/каталог → повторная партия (deferred), пустая партия → RED UNREPRESENTABLE :185, каждая партия — один sourceCanon через реальный `check_project_sources.sh --stage pre_critic` с проверкой rc 0, пустых stdout/stderr и `gate-observed == executed\n`; первая красная партия → RED со stderr реального CLI и остановкой; итоговая сверка `accepted == 26502` (RED LOST_PATHS :210). Клетка включена в `W`/`W --model` (:291) и `W --stabs` (:274 модельный sweep + :280 стабы).
Закрывающее свойство П1 исполнением:
- неисправленный гейт → `RED sweep: RED length=1 batch=0 rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: 0'` (W на OBJECT);
- честная модель → `GREEN sweep: GREEN paths=26502 batches=9` (×4 seeds);
- честный ремонт ФИЗИЧЕСКИ (отдельный worktree клона, удалена ТОЛЬКО строка 111 `*\0*)`, `git diff --numstat` → `0 1 scripts/check_project_sources.sh`) → `W` в режиме repo rc 0 `CELLS=15 GREEN=15`, `sweep: GREEN paths=26502 batches=9` — весь домен зелёный на реальном скрипте;
- accept-all (`exit 0` в шапке) на клетке sweep → `RED length=1 batch=0 rc=0 stderr='' stdout='' gate=False` — красна по отсутствию gate-observed, не по rc;
- оракул не читает текст гейта (sweep_domain/populate/exercise_sweep не открывают gate; tools_for читает гейт только для наложения стаба/модели); константы домена пересчитаны мной НЕЗАВИСИМЫМ классификатором (regex, не код probe.py): `strok 37448 putej 26502 grammatika 6530 ne-regular 4416 sum 37448 formula 37448` — совпадают с арбитражем и `DOMAIN_COUNTS`.

**П2 (стабы) — ВЫПОЛНЕНО.** `probe.py:84-91` четыре новых стаба (`*/0/*`, `00*|*00`, `*000*`, `*'\0'*`) тем же `die`; STAB_CASE `:106-113` (привязка в коде, Н-39) — шесть glob-стабов → `sweep`, `false-zero` → `backend`, `accept-all` и `skip-nul-json` → `nul`. `W --stabs` rc 0 `SVJAZI=14 CAUGHT=14 LIVE=0`, шесть строк `CAUGHT … sweep`. Атрибуция каждого из шести — отдельный прогон `exercise_sweep(<стаб>)` с выводом stderr реального CLI (не побочный rc):
```
reject-edge-zero        RED length=1 batch=0 rc=1 'NUL в пути: 0'      0.26s
reject-whole-zero       RED length=1 batch=0 rc=1 'NUL в пути: 0'      0.26s
reject-middle-zero      RED length=5 batch=6 rc=1 'NUL в пути: 0/0/0'  12.10s
reject-double-edge-zero RED length=2 batch=1 rc=1 'NUL в пути: 00'     0.62s
reject-triple-zero      RED length=3 batch=2 rc=1 'NUL в пути: 000'    1.03s
reject-quoted-backslash RED length=2 batch=1 rc=1 'NUL в пути: \\0'    0.68s
```
Негатив `STAB_SURVIVED` жив: см. §Прогоны (in-memory стаб `*2*`, привязанный к sweep).

**П3 (14 прежних клеток) — ВЫПОЛНЕНО.** Дифф probe.py не трогает `project()`, CASES, REASONS, `exercise()`; `stab_facts.py`: `CASES 14 pos 8 neg 6 REASONS 6`; живой вывод W/--model — те же 14 имён и причины, что в v1b; `CELLS=15`.

**П4 (текст) — ВЫПОЛНЕНО.** И-1 `contracts/153…:25` — свойство над доменом Σ^{1..5}; домен и константы `:34`; приёмка `:36-39` — `CELLS=15 GREEN=6` (девять красных), `CELLS=15 GREEN=15` (seeds 1/7/42, `--seed` честно описан как имя временного корня :34), `SVJAZI=14 CAUGHT=14 LIVE=0`, п.4 — 15/15 и 14/14; цена `:43`; ЗАЩИЩАЕТ `:125` — ложный отказ на любом пути домена Σ^{1..5}; НЕ ЗАЩИЩАЕТ — все четыре пункта остатка арбитража: `:130` (символ вне Σ / длина > 5, ловец — ревьюер по диффу, ссылка на эту границу вместо нового круга), `:131` (обманки вне класса), `:133-134` (управляющие кроме NUL; jq 1.6), `:135` (`./a`, `a//b`, `a/./b`). Формулировки адаптированы под текст контракта (вместо «этого вердикта» — «этой границе», вместо «ПЕРЕСЕЧЕНИЕ :45» — «ПЕРЕСЕЧЕНИЕ implementer»), смысл каждого пункта сохранён — см. СОВЕТ 2.

**П5 — ВЫПОЛНЕНО.** `git diff --stat 67cb212d1 5f72912383 -- fixtures/workshop_project/nul_istochnika_153/probe.sh` → пусто (rc 0). Хунки диффа контракта — только `@@ -22,7`, `@@ -31,13`, `@@ -118,14` (И-1; приёмка+цена; модель угроз); ЗОНА/ПЕРЕСЕЧЕНИЕ (:47-113), ПРЕДПОСЫЛКИ (:115-116), ПРОВОДКА (:118-120) не изменены. Объём дельты — два файла зоны architect.

## Атака до кода (норма роли) — мутанты в памяти, клон не правился

Сверх шести обязательных — 12 собственных мутантов внутри Σ^{≤5} и обходов «смежным механизмом»; все красны клеткой sweep с атрибуцией по stderr:
```
c3-dash-zero            *0-0*                       RED len=3 'NUL в пути: 0-0'
c3-zero-dot             *0.*                        RED len=2 'NUL в пути: 0.'
c3-backslash-any        *\\*                        RED len=1 'NUL в пути: \\'
c3-dot-slash-prefix     ./*                         RED len=3 'NUL в пути: ./-'
c3-double-slash         *//*                        RED len=4 'NUL в пути: 0//0'
c3-five-zeros           *00000*                     RED len=5 'NUL в пути: 00000'
c3-slash0slash0         */0/0*                      RED len=5 'NUL в пути: 0/0/0'
c3-underscore0          *_0*                        RED len=2 'NUL в пути: _0'
c3-one-zero-one         *101*                       RED len=3 'NUL в пути: 101'
c3-bracket-outside-case [[ $p == *0 ]] && die (вне case)        RED len=1 'NUL в пути: 0'
c3-resolver-zero        resolver: contains(NUL) or endswith("0") RED len=1 'профиль: … path NUL'
c3-warn-stderr          rc 0 + WARN в stderr для *0             RED len=1 rc=0 stderr='WARN 0' gate=True
```
Остаток арбитража (ожидаемо зелёные, ссылка на `contracts-153-arbitraz.md` §НЕ ЗАЩИЩАЕТ / контракт :130, не блок):
```
rem-component-00  */00/*   GREEN paths=26502 batches=9  (триггер a/00/a = 6 > 5)
rem-digit2        *2*      GREEN paths=26502 batches=9  (`2` ∉ Σ)
rem-zero-z-zero   *0z0*    GREEN paths=26502 batches=9  (`z` ∉ Σ)
```
Вывод: любой детерминированный строковый ложный отказ с триггером в положительной части Σ^{≤5} краснеет по построению (гейт — последовательный `die` по всем источникам партии; потерянных путей нет — `accepted == 26502`).

## Прогоны (команда → сырой итог → rc)

```
$ bash fixtures/workshop_project/nul_istochnika_153/probe.sh                 → CELLS=15 GREEN=6 (8 прежних RED 'NUL в пути: <path>', sweep RED len=1 'NUL в пути: 0'); RC=1 WALL=3.38
$ … probe.sh --stabs                                                          → CAUGHT×14 (6× sweep), SVJAZI=14 CAUGHT=14 LIVE=0; RC=0 WALL=61.71
$ … probe.sh --model                                                          → CELLS=15 GREEN=15, sweep GREEN paths=26502 batches=9; RC=0 WALL=45.79
$ … probe.sh --model --seed 1                                                 → CELLS=15 GREEN=15; RC=0 WALL=50.39
$ … probe.sh --model --seed 7                                                 → CELLS=15 GREEN=15; RC=0 WALL=58.96 (параллельно с 996)
$ … probe.sh --model --seed 42                                                → CELLS=15 GREEN=15; RC=0 WALL=50.52
$ … probe.sh --repo                                                           → идентично W: CELLS=15 GREEN=6; RC=1
$ [worktree: удалена только :111] … probe.sh                                  → CELLS=15 GREEN=15, sweep GREEN paths=26502 batches=9; RC=0 WALL=53.92
$ [worktree: удалена только :111] … probe.sh --stabs                          → CAUGHT×14 (6× sweep), SVJAZI=14 CAUGHT=14 LIVE=0; RC=0 WALL=66.22
$ python3 negative_survived.py (in-memory стаб *2* → sweep, затем main --stabs) → STAB_SURVIVED rem-digit2 sweep: GREEN paths=26502 batches=9; SVJAZI=15 CAUGHT=14 LIVE=1; RC 1 (негатив жив)
$ python3 domain_count.py (независимый regex-классификатор)                   → strok 37448 putej 26502 grammatika 6530 ne-regular 4416 sum 37448
$ bash fixtures/workshop_project/rezhim_996/probe.sh                          → 996: examined=111 mutants=0 mismatches=0; rc=0
$ bash scripts/pre_critic.sh contracts/153-nul-v-puti-istochnika.md           → PREDPOSYLKI_OK … / КРИТИК: дверь зелёная; rc=0
$ bash scripts/check_ceilings.sh                                              → потолки в порядке; rc=0
$ bash scripts/check_provodka.sh . contracts/153-nul-v-puti-istochnika.md     → (пусто); rc=0
$ bash scripts/check_zones.sh --incr /tmp/dev-harness-verify/Crit153c/zones-cache (кэш засеян main 035bbd21c)
                                                                              → incr: check_zones судит 035bbd21..5f729123 (2 коммита); … проверено по зонам: 290; rc=0
$ bash scripts/check_threat_model.sh . contracts/153-nul-v-puti-istochnika.md → секция валидна (ЗАЩИЩАЕТ 3, НЕ ЗАЩИЩАЕТ 8); rc=0
$ bash scripts/check_precision_gate.sh . contracts/153-nul-v-puti-istochnika.md → OK; rc=0
```
Цена `--stabs` 61.71 с — в пределах арбитража (~1.5 мин). Скрипты атаки: `/tmp/dev-harness-verify/Crit153c/{mutants.py,negative_survived.py,domain_count.py,stab_facts.py,honest_repair.py,run_battery.sh,run_honest.sh}`.

## САМООПИСАНИЕ (полный список «число/адрес в тексте → живое значение»)

Контракт (OBJECT):
- :25 Σ = `0 1 a / . - _ \`, длины 1..5 → ALPHABET `01a/.-_\` (8), `range(1,6)`. Совпадает.
- :25 «исходные восемь входов … (из них `0` входит в этот домен)» → CASES rc 0: 8; из восьми над Σ только `0` (остальные содержат m/s/q/l/b/d/v/x ∉ Σ). Совпадает.
- :34 37448 / 26502 / 6530 / 4416, «четыре константы» → независимый пересчёт 37448/26502/6530/4416, сумма 37448; DOMAIN_COUNTS — 4 ключа. Совпадает.
- :34 «Остальные 14 клеток неизменны» → CASES 14 (8 pos / 6 neg), дифф их не трогает. Совпадает.
- :34 «`--seed` меняет только имя временного корня» → seed используется только в `prefix=` TemporaryDirectory (:167, exercise). Совпадает.
- :36 `CELLS=15 GREEN=6`, «восемь прежних путей … `NUL в пути`», sweep RED с первым путём `0` → живой W. Совпадает.
- :37 seeds 1/7/42, `CELLS=15 GREEN=15`; «девять красных» → живые 4 прогона 15/15; 15−6 = 9. Совпадает.
- :38 `SVJAZI=14 CAUGHT=14 LIVE=0`, «шесть glob-обманок … клеткой sweep», «четырнадцать связей = тринадцать различных изменений» → живой --stabs; STAB_CASE: sweep 6; `len({repr(v)})=13` (accept-directory = accept-fifo). Совпадает.
- :39 п.4 `CELLS=15 GREEN=15` и `SVJAZI=14 CAUGHT=14 LIVE=0`; «шесть отрицательных клеток» → честный ремонт в worktree: W 15/15; --stabs SVJAZI=14 CAUGHT=14 LIVE=0 (rc 0); REASONS 6. Совпадает.
- :43 цена `W` до ремонта 3.26 с → мой 3.38 с; `W --model` 45.35 с → мой 45.79 с; «W после ремонта ≈45 с» → физический ремонт 53.92 с (параллельно с другим прогоном); `W --stabs` 59.80 с → мой 61.71 с. Замеры станции, расхождение в пределах шума/нагрузки — не расхождение смысла.
- :125, :130 Σ^{1..5}, «длины > 5» → N=5. Совпадает.
- :130 примеры остатка `*2*`, `*0z0*`, `*/00/*` → живые GREEN в моём прогоне (остаток, не блок); `*0 0*`, `*000000*`, `*0/0/0/*`, кириллица, `[[:cntrl:]]` — не прогонялись мной (символ вне Σ / длина > 5 по построению; `*0/0/0/*` — триггер `0/0/0/a` длины 7).
- Адресов строк вида `:NN` в тексте контракта нет (grep `:[0-9]{2,3}` → только время 11:20 в :5).
Батарея / регресс:
- 996 «111 кейсов» (задание) → `examined=111`. Совпадает.
- probe.py `batches=9` (отчёт автора) → живое `batches=9`. Совпадает.
Расхождений, требующих правки текста, нет.

## СОВЕТЫ (не блокируют)

СОВЕТ fixtures/workshop_project/nul_istochnika_153/probe.py:278,292 — строка `DOMAIN …` печатает константы `DOMAIN_COUNTS`, а не живой подсчёт. При зелёном sweep они равны (сверка :144-146 обязательна), но при `RED DOMAIN_COUNTS` строка `DOMAIN` всё равно покажет ожидаемые числа; печать живого `counts` сделала бы вывод самодостаточным.
СОВЕТ contracts/153-nul-v-puti-istochnika.md:130 — П4 требовал остаток «дословно»; текст адаптирован («ПЕРЕСЕЧЕНИЕ implementer: удалить ровно одну строку», а :49 говорит «удалить лишь ложный NUL-case»). Смысл совпадает; при следующей правке можно сослаться на :49 буквально.
СОВЕТ (вне класса, справочно) — sweep создаёт пустые неотслеживаемые файлы, именованные клетки — непустые закоммиченные; обманки «по содержимому файла/статусу git» поэтому покрываются взаимно дополняющими входами лишь частично (класс вне «детерминированного отказа по строке пути», :131) — ловец остаётся ревьюер по диффу.

## Что НЕ проверено

- Реализация implementer (скрипт не правился); физический ремонт в одноразовом worktree — модель реализации, не она сама.
- CI-строка оркестратора и jq 1.6 (на станции jaq 2.3.0 по отчёту автора; мной не перепроверялось).
- Мутанты остатка вне Σ/длины > 5, кроме `*/00/*`, `*2*`, `*0z0*`; отрицательная выборка грамматических отказов из домена (П1: не обязательна, автор не добавлял).
- ПЕРЕСЕЧЕНИЯ/CI/996 по существу — вне объёма scoped-суда (только регресс rc).
