FAIL
OBJECT=67cb212d1ce3bacb9953e5be76979ef17c9d9671
СУД: repo=dev-harness; предмет=153; фаза=контракт (+красная батарея), scoped; роль=critic; вызов=2/2 (единственный scoped после полного); модель-план=anthropic/claude-opus-5-5; сессия=Crit153b; модель-факт=anthropic/claude-opus-5-5; SHA=67cb212d1ce3bacb9953e5be76979ef17c9d9671; предыдущий=FAIL verdicts/critic/contracts-153-v1-fail.md (OBJECT bcacc85ca, Crit153, Opus); исключение=нет. Автор дельты: architect (единственный коммит 46d2eedb4..67cb212d1, `%an`=architect), модель автора по /tmp/dev-harness-verify/Arch153b/report.md — openai-codex/gpt-6-sol; семейства разные, независимость соблюдена. `git cat-file -t 67cb212d1…` → commit. Судился только закоммиченный OBJECT в одноразовом клоне /tmp/dev-harness-verify/Crit153b/repo; мутанты — в отдельных одноразовых копиях (/tmp/dev-harness-verify/Crit153b/{mut,ext,noop}, удалены после прогона), клон не правился. Дельта автора = 2 файла: contracts/153-nul-v-puti-istochnika.md, fixtures/workshop_project/nul_istochnika_153/probe.py (прочие файлы в `bcacc85ca..67cb212d1` — перебазирование на main 46d2eedb4).

Итог: прошлый блок по букве закрывающего свойства закрыт (edge-zero и whole-zero красны собственными клетками, честные `0`, `0.md`, `v1.0`, `0/x.md`, `x/0` зелёны, старые клетки не ослаблены, 10/10 стабов). Но класс причины — «положительные входы — перечень конкретных строк; обманный glob по цифре 0, не совпадающий ни с одной из них, проходит всю приёмку» — НЕ закрыт: четыре новых мутанта строки 111 зелёные на `W` и `W --stabs` и ложно отказывают на допустимых путях с цифрой 0. Это второй FAIL по той же причине и исчерпание бюджета (2/2) → арбитраж (ниже). Самоописание: все 19 пунктов закрыты либо законно переданы; новых счётных расхождений в тексте контракта нет. FAIL — по содержательному блоку, стоячее правило «FAIL только по самоописанию» не применяется.

## БЛОКИРУЕТ

БЛОКИРУЕТ contracts/153-nul-v-puti-istochnika.md:25 (И-1 «Существующие относительные regular files … с цифрой 0 … дают rc 0»), :23 (предмет: «объявленный в sourceCanon относительный regular file с цифрой 0 проходит тот же публичный шлюз») и :34-37 (приёмка `W`, `W --model`, `W --stabs`) — критерий слабее предмета: восемь положительных клеток (fixtures/workshop_project/nul_istochnika_153/probe.py:44-46, :100-102) покрывают одиночный 0 в середине, на краях пути и целым компонентом в начале/конце, но не 0 целым компонентом в середине пути, не серии нулей (`00` на краю, `000` внутри — штатное имя миграций `0001_initial.py`) и не 0 рядом с не-буквенно-цифровым соседом (`\`).
ОБХОД: реализация заменяет строку 111 `*\0*)` (а не удаляет её) на любой из шаблонов `*/0/*)`, `00*|*00)`, `*000*)`, `*'\0'*)` с тем же `die "SOURCE_CANON_INVALID: NUL в пути: $p"` — каждый даёт `W` rc 0 `CELLS=14 GREEN=14` и `W --stabs` rc 0 `SVJAZI=10 CAUGHT=10 LIVE=0` (сырые выводы §А-2), а допустимые пути `a/0/b.md`, `00.md`, `v100`, `migrations/0001_initial.py`, `a\0.md` получают ложный отказ «NUL в пути» (§А-3; честная модель на тех же путях rc 0, gate=True — резолвер их принимает). Последний шаблон — самая правдоподобная честная ошибка ремонта («'\0' — это NUL, как в C»).
ОБЯЗАТЕЛЬСТВО: И-1 (:25) и предмет (:23); модель угроз :121 ЗАЩИЩАЕТ «ложный отказ на конформном пути с цифрой 0»; норма роли «Атака до кода» (мутация, прошедшая зелёной, закрывается добавлением красного теста до заморозки). Класс причины — ложная достаточность критерия: перечислительное недопокрытие положительных входов (тот же класс, что блок contracts-153-v1-fail.md; закрывающее свойство прошлого круга называло лишь позиции «первый/последний символ, целый компонент в начале/конце», дельта закрыла ровно их).
СОСТОЯНИЕ: дерево после реализации, где строка 111 заменена любым из четырёх шаблонов; резолвер и прочие ветви шлюза без изменений.
НАБЛЮДЕНИЕ: вся приёмка :34-37 зелёная; на живых допустимых путях rc 1 `ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: a/0/b.md` (и т.д., §А-3), gate не запускается.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: положительные входы батареи (перечнем или генерацией по `--seed` — выбор автора) покрывают цифру 0 по решётке «позиция × кратность»: позиции — начало/конец пути, начало/конец компонента, внутри компонента, целый компонент в начале/середине/конце; кратность — одиночный 0 и серии (`00`, `000`); плюс 0 рядом с не-буквенно-цифровым символом, допустимым резолвером (например `\`). Каждый из четырёх мутантов этого вердикта (`*/0/*)`, `00*|*00)`, `*000*)`, `*'\0'*)`) красен собственной клеткой в `W` (не побочным rc), честная модель зелёная, существующие 14 клеток не ослаблены. Перечислительная батарея конечна, а класс обманок по построению бесконечен; поэтому конечную границу класса (какая решётка достаточна) назначает арбитр, а не следующий круг критика.

АРБИТР: роль arbiter (config/agent_models.json tiers.plan → @fable = anthropic/claude-fable-5-1, fallback @gpt-astra; consultant — @gpt-astra, арбитр обязан быть не той же моделью). Предмет спора: (1) достаточна ли для 153 решётка «позиция × кратность × сосед» из закрывающего свойства выше либо иная конечная граница перечислительного класса «обманный glob по 0»; (2) входит ли мутант `*'\0'*` (литерал «обратная косая + 0») в обязательную границу. Основание созыва — второй FAIL по одной причине и исчерпание бюджета critic 2/2 (§Быстрый-процесс §Остановка). Решение арбитра не даёт accept и не открывает третий вызов: подпись критика для freeze — только по явному решению владельца о дополнительном вызове.

## САМООПИСАНИЕ (полный список «число/адрес в тексте → живое значение»; новых расхождений нет)

Текст контракта (OBJECT):
- :34 `CELLS=14 GREEN=6`, «восемь путей … красны, каждый по … `NUL в пути`» → живое `W` rc 1, `CELLS=14 GREEN=6`, RED backend/ten/nested/zero-first/zero-last/zero-whole/zero-head/zero-tail, у каждого `SOURCE_CANON_INVALID: NUL в пути: <path>`. Совпадает.
- :25 И-1 — 8 путей (`migrations/001_core.sql`, `10.sql`, `a0b/0.md`, `0.md`, `v1.0`, `0`, `0/x.md`, `x/0`) → probe.py:44-46 те же 8 путей, :100-102 ожидание (0, ''). Совпадает.
- :35 `W --model`, `--seed 1`, `--seed 7`, `--seed 42` → каждый rc 0 `CELLS=14 GREEN=14`. Совпадает (seed 0 = безфлаговый `--model`, тоже 14/14).
- :36 `SVJAZI=10 CAUGHT=10 LIVE=0` → живое `--stabs` rc 0, 10 строк CAUGHT (false-zero/backend, reject-edge-zero/zero-first, reject-whole-zero/zero-whole, accept-all/nul, skip-nul-json/nul, skip-absolute/absolute, skip-dotdot/dotdot, skip-canonical/outside, accept-directory/directory, accept-fifo/fifo). Совпадает.
- :36 «десять связей = девять различных изменений: directory и fifo — одна замена `-f`→`-e`» → STABS probe.py:75-92: 10 ключей, `accept-directory` и `accept-fifo` несут идентичную замену; различных правок 9. Совпадает.
- :36 негатив «выжившая обманка → rc 1 STAB_SURVIVED» → копия с no-op стабом `noop→zero-tail`: `STAB_SURVIVED noop zero-tail: rc=0 stderr='' gate=True`, `SVJAZI=11 CAUGHT=10 LIVE=1`, rc 1 (§А-4). Совпадает (цикл probe.py:170-179).
- :37 «`W --repo` — алиас безфлагового `W`» → probe.py:180 `mode = 'model' if args.model else 'repo'`; живые выводы `W` и `W --repo` идентичны (rc 1, 14/6). Совпадает — пункт 5 прошлого вердикта закрыт.
- :37 шесть отрицательных клеток (JSON NUL, absolute, dotdot, outside, directory, fifo) → CASES: 6 с rc 1, 8 с rc 0, всего 14; REASONS 6 ключей (probe.py:106). Совпадает.
- :9 `case "$p" in *\0*)` → scripts/check_project_sources.sh:108 / :111. Совпадает.
- :11 scan_canon `contains("\u0000")` path/gate → scripts/profile_resolver.sh:443 / :501. Совпадает.
- :19 `contains("..")` → profile_resolver.sh:444, :457. Совпадает.
- :13 «`registry/plan.tsv` содержит строку 153 (PR #470 `owner/plan-153`, в main 33f3e80d7)» → OBJECT registry/plan.tsv:86 `153	3	до V-2	-	docs/owner/2026-11-01-done-gate-nul.md#Порядок	autonomy`; 33f3e80d7 — предок OBJECT; pr://470 CLOSED, head owner/plan-153, комментарий «влито в main как 33f3e80d7». Совпадает — пункт 10 прошлого вердикта закрыт (привязки к ветке больше нет).
- :5 «142/143/144» → docs/owner/2026-11-01-done-gate-nul.md:11 «142/2, 143/1, 144/1». Совпадает. Соседний NABLIUDENIA.md:8279 (Н-405) «done 001/002 Complior-back» — журнал вне зоны architect, передан оркестратору (не блокер, как указано в задании).
- :26 причина `path NUL` → живое stderr `…sourceCanon.sources[0]: path NUL`. Совпадает. Остаток прошлого пункта 13 сохраняется как факт, не как расхождение числа: клетка судит подстроку `NUL` (probe.py:106, :146), не `path NUL` (см. СОВЕТ).
- :27 «источник вне репозитория», «источник не regular file» → живое stderr outside/directory/fifo. Совпадает.
- :38 996 rc 0; задание «111» → живое `996: examined=111 mutants=0 mismatches=0`, rc 0. Совпадает.
- :45-108 ПЕРЕСЕЧЕНИЕ → `grep -c`: ci.yml 44, ci-steps.tsv 17, ci-zamery.tsv 1, implementer 1 = 63 строки, первая :45, последняя :108; CI-подмножество 62; `check_precision_gate.sh` OK rc 0. Совпадает.
- :128 «на станции используется jaq 2.3.0» → `jq --version` → `jaq 2.3.0`. Совпадает.
- Модель угроз :118-133 → `check_threat_model.sh`: «ЗАЩИЩАЕТ 3, НЕ ЗАЩИЩАЕТ 5», rc 0 (было 3/4; +1 буллет jq 1.6 :128). Совпадает с отчётом автора.

Пункты задания/отчёта (вне текста контракта):
- задание «14 клеток» → 14; «неисправленный шлюз 6/14» → 6/14; «честная модель 14/14» → 14/14 (seeds 0/1/7/42 и честное удаление строки 111 в копии); «оба мутанта rc 1 с именованными RED» → edge-zero rc 1 `CELLS=14 GREEN=9` RED zero-first/zero-last/zero-whole/zero-head/zero-tail; whole-zero rc 1 `CELLS=14 GREEN=12` RED zero-whole/zero-tail — каждый собственной клеткой, причина «NUL в пути». Совпадает.
- задание «10/10 стабов» → 10/10; «батарея 996 (111) rc 0» → 111, rc 0. Совпадает.
- задание `red_*.sh` → батарея `fixtures/workshop_project/nul_istochnika_153/probe.sh` (+probe.py, .probe-only); `red_*.sh` нет. Расхождение текста исходного задания; контракт называет probe.sh — закрыто.
- отчёт «STABS=10, STAB_CASE=10, CASES=14, REASONS=6» → 10/10/14/6. Совпадает.
- отчёт «цикл отказа probe.py:171–179» → `caught = 0` :170, `for` :171, `return` :179. Совпадает (диапазон цикла).
- отчёт «lib_incr.sh: комментарий :109, исполняемый `if [ -z "$INCR_CACHE" ] … fi` :110–112» → :109 комментарий, :110 `if`, :111 `return 0`, :112 `fi`. Совпадает — пункт 18 закрыт.
- отчёт «resolver :443 (path), :501 (gate)» → совпадает (пункт 8 закрыт).
- отчёт «check_zones --incr …: 1 коммит 46d2eedb..67cb212d, проверено по зонам 145» → мой прогон с кэшем base=46d2eedb4: rc 0, «коммитов в диапазонах: 145 · проверено по зонам: 145», FAIL-строк нет; кэш после прогона = 67cb212d1, повторный прогон печатает `incr: check_zones судит 67cb212d..67cb212d (0 коммитов)`, rc 0. Совпадает.
- отчёт «полный check_zones --incr …zones-cache: 40429 коммитов в диапазонах / 9534 по зонам, без FAIL» → мой полный прогон (кэш отсутствовал): 40429 / 9534, rc 0. Совпадает.

Пункты 1-19 прошлого вердикта: 1-4, 6-9, 11, 14-17, 19 — совпадали и совпадают с новыми числами; 5 (W/--repo) закрыт формулировкой «алиас»; 10 (plan.tsv) закрыт без привязки к ветке; 12 (Н-405) передан оркестратору; 13 — остаток «NUL против path NUL» сохранён как факт; 18 (lib_incr) уточнён в отчёте. Открытых расхождений самоописания нет.

## СОВЕТ

СОВЕТ contracts/153-nul-v-puti-istochnika.md:35 — `--seed` меняет только префикс временного каталога (probe.py:133 `prefix=f'nul153-{seed}-{case}-'`); четыре seed — четыре прогона одного и того же набора путей. Если автор закроет блок генерацией положительных путей по seed, seeds начнут что-то измерять; иначе стоит написать в тексте, что seed варьирует лишь временной корень.
СОВЕТ :45 — мутант cntrl (`*[[:cntrl:]]*)` вместо строки 111) по-прежнему зелёный на `W` и `W --stabs` (§А-2); вводит новый отказ на управляющих символах — расширение замороженной грамматики, запрещённое ПЕРЕСЕЧЕНИЕМ «удалить лишь ложный NUL-case». Как и в прошлом круге, не блокирую: клетка «tab принимается» предрешила бы вопрос, переданный владельцу (:127). Держится ревьюером по диффу.
СОВЕТ :26 / probe.py:106 — клетка nul судит подстроку `NUL`, текст И-2 — `path NUL`; ужесточение REASONS до `path NUL` сделало бы клетку равной тексту.

## Атаки (команды и сырой вывод)

А-1 Мера приёмки на OBJECT (клон /tmp/dev-harness-verify/Crit153b/repo):
```
$ bash fixtures/workshop_project/nul_istochnika_153/probe.sh
RED backend: rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: migrations/001_core.sql' gate=False
RED ten: rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: 10.sql' gate=False
RED nested: rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: a0b/0.md' gate=False
RED zero-first: rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: 0.md' gate=False
RED zero-last: rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: v1.0' gate=False
RED zero-whole: rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: 0' gate=False
RED zero-head: rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: 0/x.md' gate=False
RED zero-tail: rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: x/0' gate=False
GREEN nul: rc=1 stderr='ОТКАЗ: профиль: SOURCE_CANON_INVALID: репо-слой.sourceCanon.sources[0]: path NUL' gate=False
GREEN absolute: rc=1 stderr='ОТКАЗ: профиль: SOURCE_CANON_INVALID: репо-слой.sourceCanon.sources[0]: path абсолютный' gate=False
GREEN dotdot: rc=1 stderr='ОТКАЗ: профиль: SOURCE_CANON_INVALID: репо-слой.sourceCanon.sources[0]: path ..' gate=False
GREEN outside: rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: источник вне репозитория: link.md' gate=False
GREEN directory: rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: источник не regular file: folder' gate=False
GREEN fifo: rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: источник не regular file: pipe' gate=False
CELLS=14 GREEN=6
rc=1
$ … --repo                                   → вывод идентичен; CELLS=14 GREEN=6; rc=1
$ … --model --seed 0 | 1 | 7 | 42            → каждый CELLS=14 GREEN=14; rc=0
$ … --stabs                                  → CAUGHT ×10 (см. САМООПИСАНИЕ); SVJAZI=10 CAUGHT=10 LIVE=0; rc=0
$ bash fixtures/workshop_project/rezhim_996/probe.sh   → … freeze-closures-preserved: rc=0 / freeze-head-plan-preserved: rc=0 / 996: examined=111 mutants=0 mismatches=0; rc=0
$ bash scripts/pre_critic.sh contracts/153-nul-v-puti-istochnika.md → «гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1» / «КРИТИК: дверь зелёная»; rc=0
$ bash scripts/check_ceilings.sh             → «потолки в порядке»; rc=0
$ bash scripts/check_provodka.sh . contracts/153-nul-v-puti-istochnika.md → (пусто); rc=0
$ bash scripts/check_precision_gate.sh . contracts/153-nul-v-puti-istochnika.md → OK; rc=0
$ bash scripts/check_threat_model.sh . contracts/153-nul-v-puti-istochnika.md → «модель угроз: секция валидна (ЗАЩИЩАЕТ 3 буллет(ов), НЕ ЗАЩИЩАЕТ 5 буллет(ов))»; rc=0
$ bash scripts/check_spec_ready.sh . contracts/153-nul-v-puti-istochnika.md → OK; rc=0
$ bash scripts/check_zones.sh --incr /tmp/dev-harness-verify/Crit153b/zones-cache-scoped   (кэш: 46d2eedb4cc643879d9e0b24e083ae8fb8ff0ba1)
  → «замороженных контрактов: 146 · объявленных авторов: 5 · коммитов в диапазонах: 145 · проверено по зонам: 145»; rc=0
$ (повтор) → «incr: check_zones судит 67cb212d..67cb212d (0 коммитов)»; rc=0
$ bash scripts/check_zones.sh --incr /tmp/dev-harness-verify/Crit153b/zones-cache   (кэш отсутствовал → «полный прогон (кеш отсутствует)»)
  → «замороженных контрактов: 146 · объявленных авторов: 5 · коммитов в диапазонах: 40429 · проверено по зонам: 9534», FAIL-строк нет; 381.97 s; rc=0
```

А-2 Мутанты строки 111 (/tmp/dev-harness-verify/Crit153b/mut.sh: копия scripts/+fixtures/ клона, строка 111 заменена шаблоном с тем же `die`, прогон реального `W` = probe.sh без флага):
```
honest            (удалить :111)   → W rc=0 CELLS=14 GREEN=14; W --stabs rc=0 SVJAZI=10 CAUGHT=10 LIVE=0
edge-zero         `0*|*0`          → W rc=1 RED zero-first/zero-last/zero-whole/zero-head/zero-tail; CELLS=14 GREEN=9
whole-zero        `0|*/0`          → W rc=1 RED zero-whole/zero-tail; CELLS=14 GREEN=12
mid-whole-zero    `*/0/*`          → W rc=0 CELLS=14 GREEN=14; W --stabs rc=0 SVJAZI=10 CAUGHT=10 LIVE=0   ← ВЫЖИЛ (БЛОКИРУЕТ)
double-edge-zero  `00*|*00`        → W rc=0 CELLS=14 GREEN=14; W --stabs rc=0 SVJAZI=10 CAUGHT=10 LIVE=0   ← ВЫЖИЛ (БЛОКИРУЕТ)
triple-zero       `*000*`          → W rc=0 CELLS=14 GREEN=14; W --stabs rc=0 SVJAZI=10 CAUGHT=10 LIVE=0   ← ВЫЖИЛ (БЛОКИРУЕТ)
quoted-bs-zero    `*'\0'*`         → W rc=0 CELLS=14 GREEN=14; W --stabs rc=0 SVJAZI=10 CAUGHT=10 LIVE=0   ← ВЫЖИЛ (БЛОКИРУЕТ)
cntrl             `*[[:cntrl:]]*`  → W rc=0 CELLS=14 GREEN=14; W --stabs rc=0 SVJAZI=10 CAUGHT=10 LIVE=0   ← ВЫЖИЛ (СОВЕТ)
any-two-zeros     `*0*0*`          → W rc=1 RED backend/nested; CELLS=14 GREEN=12
bracket-whole     `[0]`            → W rc=1 RED zero-whole; CELLS=14 GREEN=13
any-digit         `*[0-9]*`        → W rc=1 RED все 8 положительных; CELLS=14 GREEN=6
second-char       `?0*`            → W rc=1 RED ten/nested; CELLS=14 GREEN=12
single-char       `?`              → W rc=1 RED zero-whole; CELLS=14 GREEN=13
dollar-nul        `*$'\0'*`        → W rc=1 RED 8 положительных + outside/directory/fifo; CELLS=14 GREEN=3
comp-start-zero   `*/0*`           → W rc=1 RED backend/nested/zero-tail; CELLS=14 GREEN=11
comp-end-zero     `*0/*`           → W rc=1 RED zero-head; CELLS=14 GREEN=13
interior-zero     `?*0*?`          → W rc=1 RED backend/ten/nested; CELLS=14 GREEN=11
```
Сырой вывод выживших (дословно):
```
=== mutant mid-whole-zero: line111 -> */0/*
111:    */0/*) die "SOURCE_CANON_INVALID: NUL в пути: $p" ;;
W rc=0
CELLS=14 GREEN=14
W --stabs rc=0
SVJAZI=10 CAUGHT=10 LIVE=0
=== mutant double-edge-zero: line111 -> 00*|*00
111:    00*|*00) die "SOURCE_CANON_INVALID: NUL в пути: $p" ;;
W rc=0
CELLS=14 GREEN=14
W --stabs rc=0
SVJAZI=10 CAUGHT=10 LIVE=0
=== mutant quoted-backslash-zero: line111 -> *'\0'*
111:    *'\0'*) die "SOURCE_CANON_INVALID: NUL в пути: $p" ;;
W rc=0
CELLS=14 GREEN=14
W --stabs rc=0
SVJAZI=10 CAUGHT=10 LIVE=0
=== mutant cntrl: line111 -> *[[:cntrl:]]*
111:    *[[:cntrl:]]*) die "SOURCE_CANON_INVALID: NUL в пути: $p" ;;
W rc=0
CELLS=14 GREEN=14
W --stabs rc=0
SVJAZI=10 CAUGHT=10 LIVE=0
=== mutant triple-zero: line111 -> *000*
111:    *000*) die "SOURCE_CANON_INVALID: NUL в пути: $p" ;;
W rc=0
CELLS=14 GREEN=14
W --stabs rc=0
SVJAZI=10 CAUGHT=10 LIVE=0
```

А-3 Следствие на допустимых входах (/tmp/dev-harness-verify/Crit153b/ext.sh: копия probe.py с пятью добавленными положительными клетками и тем же оракулом — rc 0, пустые stdout/stderr, gate-observed == "executed"; пути: mid-whole=`a/0/b.md`, django=`migrations/0001_initial.py`, run-first=`00.md`, run-last=`v100`, backslash=`a\0.md`):
```
=== honest: line111 -> -
W(ext) rc=0
GREEN mid-whole: rc=0 stderr='' gate=True
GREEN django: rc=0 stderr='' gate=True
GREEN run-first: rc=0 stderr='' gate=True
GREEN run-last: rc=0 stderr='' gate=True
GREEN backslash: rc=0 stderr='' gate=True
CELLS=19 GREEN=19
=== mid-whole-zero: line111 -> */0/*
W(ext) rc=1
RED mid-whole: rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: a/0/b.md' gate=False
CELLS=19 GREEN=18
=== double-edge-zero: line111 -> 00*|*00
W(ext) rc=1
RED run-first: rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: 00.md' gate=False
RED run-last: rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: v100' gate=False
CELLS=19 GREEN=17
=== triple-zero: line111 -> *000*
W(ext) rc=1
RED django: rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: migrations/0001_initial.py' gate=False
CELLS=19 GREEN=18
=== quoted-backslash-zero: line111 -> *'\0'*
W(ext) rc=1
RED backslash: rc=1 stderr='ОТКАЗ: SOURCE_CANON_INVALID: NUL в пути: a\\0.md' gate=False
CELLS=19 GREEN=18
```
(в каждом мутанте остальные из пяти добавленных — GREEN; 14 исходных — GREEN.)

А-4 Негатив STAB_SURVIVED (/tmp/dev-harness-verify/Crit153b/noop.sh: копия с добавленным стабом `noop: (GATE, None)` → `zero-tail`):
```
STAB_SURVIVED noop zero-tail: rc=0 stderr='' gate=True
SVJAZI=11 CAUGHT=10 LIVE=1
W --stabs (noop) rc=1
```

## Регресс дельты
probe.py: только добавления (5 путей, 5 положительных CASES, 2 стаба, 2 связи STAB_CASE); оракулы и пути 9 прежних клеток не изменены; честное удаление строки 111 по-прежнему 14/14 и 10/10. Контракт: пункт 4 (:37) и CI-ПЕРЕСЕЧЕНИЕ теперь требуют `W --stabs` (совет прошлого круга принят), модель угроз +1 НЕ ЗАЩИЩАЕТ (jq 1.6), число ПЕРЕСЕЧЕНИЙ не изменилось (63). Батарея 996 дельтой не тронута (дельта — 2 файла зоны architect).

## НЕ проверено
- CI-раннер (версия jq на GitHub Actions) — не запускался.
- `gen_ci_steps.sh --write/--check` — шаг оркестратора после реализации, не исполнялся.
- Реализация — её нет на OBJECT; судились модель и мутанты.
- `--stabs` с seed ≠ 0 — не прогонялся (seed меняет только префикс временного каталога).
- TOCTOU и нестандартные ФС — объявлены НЕ ЗАЩИЩАЕТ, не атаковались; `x\ny.md` (НЕ ЗАЩИЩАЕТ :127) повторно не измерялся (измерен в прошлом круге).
