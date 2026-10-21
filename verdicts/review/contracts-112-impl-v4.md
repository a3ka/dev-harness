FAIL
Ревьюер Rev112r4, контракт 112 (frozen/contracts/112/2), круг 4 (scoped: B1 + LF), OBJECT=47edb2120e93eb51e4aace56820018a3e81101cc (refs/union/112-r4: implementer 61260217c+f27db3964+9f549bec5+2a51862f4, architect a0deff1c6+32face307+47edb2120). Что в порядке: B1 круга 3 закрыт в продукте и в модели — кавычки `'` `"`, `\`, `{a,}`, `~`, глоб и `npm --prefix ~ test` дают rc 1 `komandy`. canonicalRemote с LF/NUL/CR/TAB в любой позиции даёт rc 1 `kanon-remote`. Зоны чисты, контракт не тронут, модель только ужесточена, батарея 63/63. Блокируют две находки. B1r4: регресс source-canon — каталог как источник был rc 1 в круге 3, теперь rc 0, модель даёт 1. B2: хвостовой LF в workflowPaths/state продукт не ловит по форме; при существующем LF-имени rc 0, модель даёт 1, потребитель `jq -r` уходит наружу.

---
status: ready
object: 47edb2120e93eb51e4aace56820018a3e81101cc
contract: frozen/contracts/112/2
reviewer: Rev112r4 (anthropic/claude-opus-5-5)
date: 2026-10-21
round: 4
---

## Блокирующие находки

- [ ] **B1r4 [РЕГРЕСС, п.(2) мандата; продукт слабее модели на входе объявленной грамматики; зона implementer] `sourceCanon.sources[].path`, указывающий на КАТАЛОГ, снова принимается.**
  Вход из круга 3 (`n-src-dir` в `Rev112r3/probe_b.sh`): `.sourceCanon={sources:[{path:"docs",priority:0}],gate:["python3","gate.py"]}`. Резолвер его пропускает.
  ```
  impl 9f549bec5 (круг 3)  rc=1  ОТКАЗ: подключение: source-canon: источник отсутствует: docs (real: …/docs)
  impl 2a51862f4 (круг 4)  rc=0
  model 47edb2120          rc=1
  (то же для path:"mobile": impl 0 / model 1)
  ```
  Свидетели: `/tmp/dev-harness-verify/Rev112r4/probe_r4.sh` → `probe_r4.out` (строки `r3impl-n-src-dir`, `r4-n-src-dir`, `r4-n-src-dir-mobile`) и `regress.out` (`n-src-dir … <<< MODEL1/IMPL0`).
  Причина. В круге 3 вызов был таким: `if canon_R "$sp" … "file" source-canon; then [ -f "$REAL" ] || fail …; fi` (`git show 9f549bec5:scripts/check_project_connection.sh:254-256`). Коммит 2a51862f4 заменил его на `canon_R "$sp" "источник #$idx" "file" source-canon || true` (`:375`) и положился на внутренний `[ -f "$file_real" ]` в `canon_R`. Но в `canon_R` условие `if [ "$kind" = "dir" ] || [ -d "$target" ]; then` (`:180`) отправляет каталог в ветвь каталога и возвращает 0 при kind=file. До проверки regular file дело не доходит. Батарея 63/63 зелёная: клетки на каталог как источник нет.
  Простейшая форма. Ветвь каталога брать только при `kind=dir`, а kind=file при `-d` отвергать («не regular file»). Либо вернуть `[ -f "$REAL" ]` в source-canon. Architect: клетка «source-canon — каталог»; она должна быть красной на 2a51862f4 и зелёной на 9f549bec5.

- [ ] **B2 [LF, п.(1) мандата «workflowPaths/sources — байт-в-байт»; продукт слабее модели; заявленное ≠ сделанному; зоны implementer + architect] `read_strict` не обнаруживает хвостовой LF. Продукт отвергает его только тогда, когда LF-имени нет на диске.**
  Механика. `read_strict` (`:112-146`) кладёт значение между sentinel-ами, поэтому хвостовой `\n` значения остаётся в `VAL`. Длины jq и bash совпадают, `return 0`. Значит, LF ловит не форма, а отсутствие пути. Наблюдаемо: на `.workflowPaths.contracts += "\n"` продукт пишет `workflowPaths.contracts: не каталог: .harness/contracts`, а НЕ свою причину `содержит хвостовые \n/NUL/управляющие`. Клетка D56 зелёная по неверной причине. Её комментарий: «каталог `.harness/contracts` (без LF) СУЩЕСТВУЕТ: дефект — форма значения, не отсутствие цели». Шапка `:60-64` и текст `fail` обещают отказ по форме. Обещание не выполнено.
  Вход, где LF-имя существует (мир mob; та же техника литеральных имён, что в принятых клетках D39/D40/D49–D52):
  ```
  wp-lf-dir-exists  contracts=".harness/contracts\n"; в дереве: каталог ".harness/contracts\n", а ".harness/contracts" -> <вне>/state
                    impl rc=0  model rc=1 (`workflowPaths.contracts несёт управляющий байт`)
  st-lf-dir-exists  state="st\n"; в дереве: каталог "st\n", "st" -> <вне>/state
                    impl rc=0  model rc=1
  потребитель (образец next_id.sh:469 `$(jq -r '.workflowPaths.contracts.value')`):
                    [.harness/contracts] -> /tmp/dev-harness-verify/Rev112r4/scratch/outside/state
  ```
  Свидетели: `probe_r4.sh`/`probe_r4.out` (`wp-lf-dir-exists`, `st-lf-dir-exists`), `probe_reasons.sh`/`probe_reasons.out`. Проверка признаёт путь `X\n` внутри дерева. Потребитель срезает LF и работает с `X`, который смотрит наружу. Это то же свойство, что B1 круга 3: проверен один путь, использован другой. NUL закрыт: `wp-nul-*`, `st-nul-tail` и `rem-nul-*` дают rc 1 своей именованной причиной.
  Простейшая форма. После чтения отвергать `VAL` с LF/CR/TAB, например `case "$VAL" in *[$'\n\r\t']*) return 1;; esac`, симметрично модели `upravljajushhij_bajt`. Либо проверять управляющие на стороне jq: `test("[\u0000-\u001f]")`. Architect: вариант D56 (и аналог для state), где LF-имя каталога существует, чтобы отказ шёл по форме. Сейчас эта клетка красна только против модели.

## Советы (не блокируют)

- [ ] A1 (A3 круга 3, вне B1/LF) Лист `package.json` symlink наружу: impl 0, model 1 (`regress.out`: `n-pkgjson-leaf-symlink <<< MODEL1/IMPL0`; на 9f549bec5 тоже 0 — не регресс). Исполнение `npm --prefix mobile test` запускает внешний `package.json` (`probe_exec4.out`: `EXECUTED-OUTSIDE-PKGJSON`). Коммит 2a51862f4 заявляет «лист-symlink realpath» (A3), но `pj="$dir/package.json"; [ -f "$pj" ]` (`:348-349`) лист не канонизирует. Комментарий D59 говорит «листья … package.json — тот же класс», а клетка есть только для node.
- [ ] A2 (класс A4, принятый в круге 3; эскалация владельцу) LF МЕЖДУ строками команды: `node mobile/scripts/gen.js\nnode ../outside/evil.js` даёт impl 0 / model 0. Шаг CI исполняет внешний файл (`probe_exec4.out`: `honest-in-tree EXECUTED-OUTSIDE-TREE …/outside/evil.js`, rc 0). Белый набор этого не видит: `toks=($v)` срезает LF как IFS ДО `tok_safe`. Заявления «управляющие … отвергаются» (коммит 2a51862f4, модель `:108-109`) для LF неверны. Контракт (закрытый набор `node|python3 <файл>`) двухстрочную форму не допускает.
- [ ] A3 (новый класс) Option-injection литеральным файлом-опцией: `node --require ../outside/evil.js mobile/scripts/gen.js` при файле `--require` в корне даёт impl 0, model 1. Модель отвергает случайно: `dirname "--require"` без `--`. Исполнение загружает внешний модуль (`probe_exec4.out`). Решение — запрет ведущего `-` у токена файла.
- [ ] A4 Запятая. `tok_safe` (`:158`) — `[^A-Za-z0-9._/@:=+-]`, без `,`. Шапка, комментарий и текст отказа (`[A-Za-z0-9._/@:=+,-]`) и модель запятую включают. `node mobile/scripts/gen.js --only=a,b` даёт impl 1, model 0. Честные литералы CI/фикстур запятых не несут (проверено grep), поэтому ложных отказов на честных профилях нет.
- [ ] A5 Зависимость от локали. `read_strict` сравнивает `jq length` (кодточки) с `${#VAL}` (символы локали). При `LC_ALL=C` честный не-ASCII путь отвергается: `docs/Карта.md` и `.harness/контракты` дают impl 1, model 0 (`probe_r4.out`: `utf8-*-LC_C`). При UTF-8 обе стороны дают 0. Решение — `utf8bytelength` и `LC_ALL=C` с обеих сторон, либо форма B2 на стороне jq.
- [ ] A6 NUL в хвосте команды: impl 1 / model 0 (продукт строже, безвредно). Комментарий `:267-268` («обход `npm --prefix mobile test\n` проходил» — теперь ловится) неверен: хвостовой LF в команде срезается IFS и принимается (безвредно).
- [ ] A7 `kind=file` и basename. `base="$(basename -- "$target")"` (`:195`) срезает хвостовой LF имени, поэтому при существующем `X\n` лист проверяется под именем `X`. Сейчас это безвредно, отказ уходит раньше. Закрывается формой B2.

## (1) B1 и LF — закрыты?

B1: закрыт, продукт и модель rc 1 `komandy` на всех входах ревьюера круга 3. Своя мера — `regress.out`:
```
n-tilde-prefix 'npm --prefix ~ test'           impl 1 model 1  токен вне белого алфавита (токен: ~)
n-brace-node-escape 'node {../outside/evil.js,}' impl 1 model 1
n-squote-node-escape "node '../outside/evil.js'" impl 1 model 1
n-dquote-node-escape 'node "../outside/evil.js"' impl 1 model 1
n-backslash-node-escape 'node \../outside/evil.js' impl 1 model 1
r2-npm-glob 'npm --prefix mob* run lint'         impl 1 model 1
```
Клетки D49–D54 (impl union 0 ×6) против impl 9f549bec5 красны ×6, то есть честные. canonicalRemote: закрыт. `rem-lf-tail/lead/mid`, `rem-cr-tail`, `rem-tab-tail`, `rem-space-tail` дают rc 1 `kanon-remote` (≠ байт в байт). `rem-nul-tail/mid` дают rc 1 своей причиной «содержит … NUL». Модель на всех этих входах тоже 1. workflowPaths/state/sources: NUL закрыт; LF — **B2**.

## (2) Регресс входов кругов 1–3

Своя мера: `regress.sh` перепроигрывает все строки `probe` из `Rev112r3/probe.sh` и `probe_b.sh`. Это входы Rev112/Adv112 (круг 1), Rev112r2/Adv112r2 (круг 2), Rev112r3 и `n-remote-trailing-nl` Adv112r3 (круг 3). `grep -c '^P ' regress.out` = **127** прогонов (с повторами между двумя файлами).
- Все дефектные входы кругов 1–3 дают rc 1 с именованной причиной (`komandy` / `workflowPaths` / `kanon-remote` / `source-canon` / `profil`). Исключение — `n-src-dir`, он даёт 0 (**B1r4**).
- Честные `honest`, `node-honest-arg`, `tabs-sep`, `state-dotdot-into`, `src-honest` (с gate) — rc 0/0. Батарея: M1-back-model / M2-mob-model зелёные (литералы CI: `npm --prefix backend run smoke:image`, `node backend/scripts/gen-contracts.js --check`, `npm --prefix mobile run typecheck|lint|test`).
- Строки «модель 1 / продукт 0»: `n-src-dir` (B1r4) и `n-pkgjson-leaf-symlink` (A1). «Продукт 1 / модель 0»: `n-cmd-nul-tail` (A6).
- Принятые 0/0 прежних кругов без изменений: A4 newline, `n-remote-insteadof/pushurl/two-urls`, `.git` как state.

## (3) Зоны, frozen, модель

```
61260217c implementer: .github/workflows/ci.yml package.json registry/ci-steps.tsv scripts/check_project_connection.sh scripts/profile_resolver.sh
f27db3964 / 9f549bec5 / 2a51862f4 implementer: scripts/check_project_connection.sh
a0deff1c6 / 32face307 / 47edb2120 architect: fixtures/workshop_project/podklyuchenie_112/{model_check_connection.sh,red_podkljuchenie_112.sh}
git diff frozen/contracts/112/2^{commit}..HEAD -- contracts/112-podklyuchenie-proekta.md → 0 строк
```
Модель (`git diff 32face307 47edb2120`, все `-`-строки прочитаны) только ужесточена. Чтение `$(jq -r)` заменено на `jq -j`-файл с отказом по управляющим байтам. `!=` для remote заменён на `cmp` байтов. Чёрный `op_obolochki` заменён на белый набор. `[ -f "$fp" ]` и `[ -f "$pj" ]` заменены на `readlink -f` + префикс + `-f`. source-canon `[ -f "$R/$sp" ]` заменён на `readlink -f` + префикс + `-f`. Батарея: все 52 прежние метки `case` на месте (своя мера — цикл по меткам 32face307, `MISSING` = 0). `KLETKI_112` = 63 уникальных имени; метки `case` = 63. Анти-плацебо (4) берёт список из массива (A7 круга 3 закрыт). `usage` определён (A6 закрыт). `$1` в диагностике вернулся: `--bogus x` → `неизвестный аргумент: --bogus`, rc 2 (A5 закрыт).

## (4) Прогоны (клон `/tmp/dev-harness-verify/Rev112r4/m` @ 47edb2120; свидетель `runs.sh`)

| команда | rc | вывод |
|---|---|---|
| `red_podkljuchenie_112.sh` | 0 | `ИТОГ 112: клеток 63, зелёных 63, красных 0, rc=0` (`bat.log`) |
| `--model` | 0 | `ИТОГ 112: клеток 63, зелёных 63, красных 0, rc=0` (`batm.log`) |
| `--cell net-takoj-kletki` | 2 | `использование: red_podkljuchenie_112.sh [--model] \| --cell <имя клетки>` |
| state-слепая контрмодель `--cell D14` / `D16` | 1 / 1 | |
| komandy-слепая контрмодель, все `D*-komanda-*` (23) | 1 ×23 | D2, D34–D54, D59 |
| impl union `--cell D49…D59` | 0 ×11 | |
| impl 9f549bec5 `--cell D49…D59` | 1 ×11 | полный: `клеток 63, зелёных 52, красных 11, rc=1` — новые клетки честные |
| п.6 jq package.json / awk ci-steps.tsv | 0 / 0 | |
| `gen_ci_steps.sh --check` | 0 | `git status --porcelain` → 0 строк |
| `verify_ci_parity.sh` | 0 | `… расхождений: 0` |
| `run_battery.sh profile_resolver` | 0 | `итог 4/4 классов закрыто` |
| `_krasnye_054.sh` | 0 | `итог 054: rc=0` |
| `check_provodka.sh . contracts/112-…md` | 0 | |
| `check_threat_model.sh . contracts/112-…md` | 0 | `ЗАЩИЩАЕТ 6, НЕ ЗАЩИЩАЕТ 4` |

Счёт 63 своей мерой: элементы `KLETKI_112` (awk) = 63, метки `case` (grep) = 63. Это две разные команды, и обе расходятся с раннером только числом, не составом.

## Паразитная сложность (050) — артефакты круга 4

- `read_strict` (impl). (1) Буквальное равенство remote (стр. 84) и чтение путей без потери байтов. (2) Глобальные `VAL`, `PODKL_A`, `PODKL_B` — состояние неявное, утекает в скрипт. (3) Один файл; модель решает то же другой техникой (`jq -j` в файл + `tr`/`cmp`). (4) Мелкий модуль: 30 строк, два вызова jq, приём sentinel + длина. Он не ловит хвостовой LF (B2) и зависит от локали (A5). (5) Потребители — 4 ветви. **ACCIDENTAL** (фрагмент `:112-146`; отсутствующее свойство — отказ по LF/управляющим; более простая форма — `jq -e '…|test("[\u0000-\u001f]")|not'` и `jq -e --arg o "$orig" '.git.value.canonicalRemote == $o'`, она проходит те же строки приёмки D55–D58). Блокирует в составе B2.
- `tok_safe` (impl) и белый `op_obolochki` (model). (1) Закрытая форма komandy (стр. 85), B1. (2) Без состояния. (3) 2 файла — неизбежная пара модель/продукт; наборы расходятся на `,` (A4). (4) Глубокий: один `case`. (5) D49–D54. ESSENTIAL.
- `canon_R` (листовая канонизация, impl). (1) «В дереве» (§Конструкция), A3. (2) Глобальная `REAL`. (3) Один хелпер. (4) Ветвь `|| [ -d "$target" ]` при kind=file — источник B1r4. (5) D5/D6/D10/D13/D14/D16/D17/D34–D59. ESSENTIAL; дефект — B1r4.
- `upravljajushhij_bajt` + файл `CHISTYJ_112` (model). (1) Отказ по форме LF/NUL. (2) Временный файл явный, удаляется. (5) D55–D58. ESSENTIAL.
- Клетки D49–D59 (семья). (1) B1/A2/A3 круга 3. (2) Миры в `$SCRATCH`. (3) Батарея; список анти-плацебо производный. (4) По одной мутации. (5) Полный прогон и CI-шаг. ESSENTIAL. Неполнота: нет клеток на каталог в source-canon (B1r4), на существующее LF-имя (B2) и на лист `package.json` (A1).

## Починка (норма 050)

- implementer, `scripts/check_project_connection.sh`: B1r4 — kind=file не уходит в ветвь каталога (или вернуть `[ -f "$REAL" ]` в source-canon). B2 — отказ по LF/CR/TAB в значении после `read_strict` (или jq-side `test`). По желанию A1/A3/A4/A5.
- architect, `fixtures/workshop_project/podklyuchenie_112/`: клетка «source-canon — каталог» (красная на 2a51862f4). Варианты D56/state с существующим LF-именем (красные на 2a51862f4). По желанию — клетка на лист `package.json`.

Свидетели: `/tmp/dev-harness-verify/Rev112r4/{lib.sh,regress.sh,regress.out,probe_r4.sh,probe_r4.out,probe_reasons.sh,probe_reasons.out,probe_exec4.sh,probe_exec4.out,runs.sh,bat.log,batm.log}`.
