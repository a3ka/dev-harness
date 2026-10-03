FAIL
---
status: ready
contract: 071
round: r4 (после капа; гейт — список форм П4 арбитража verdicts/arbitration/071-kap-krugov.md)
judged_tree: proverka bb1ee569 (tree 843374c7) = 30d2d9e + a734f18 + c3cbfbb (impl, f5i) + f130a62 (arch, f5a)
judged_blobs: scripts/gitw dc796f55; scripts/gitw_preflight_071.sh d8e538b4; fixtures/gitw_predpolet/red_predpolet_071.sh 7a3f5532; contract 5c888442 (= frozen)
reviewer: Rev071r4
date: 2026-10-03
---

# Вердикт ревьюера 071 r4 — FAIL

Судимое дерево: локальный merge `proverka` bb1ee569 в клоне /tmp/dev-harness-verify/rev071r4/repo:
30d2d9e + f5i (a734f18, c3cbfbb) + f5a (f130a62) из бандла wip071fixr5b. Посторонний коммит
origin/main 52b6e5e3 («base», t@t.local) я не судил и на нём не строил. Push не делал. Все прогоны
шли строго последовательно (Н-164).

FAIL выставлен по четырём живым обходам из гейт-списка П4: F-6 в двух подклассах, F-5/F-2 со
значением после remote, F-7/-C. Кроме того, сломано свойство С2, а impl-4 арбитража не
исполнен. Все четыре причины относятся к классу «граница argv / грамматика
флагов-refspec». По П1 п.4 и §«Что дальше» арбитража r5 не открывается: **предмет уходит к
владельцу**.

## Прогоны (сырые строки)

| # | команда | дерево | rc | сырая строка |
|---|---|---|---|---|
| R1 | `bash fixtures/_krasnye_071.sh .` | proverka | 0 | «стаб-пак: 22/22 поймано, диффпроба 22/22» … «ok: п19б: -C <T> push origin main — судится T, отказ» / «честные клетки: 61/61 зелёные; стаб-пак 22/22 + дифф 22/22» (печатается непосредственно перед `exit 0`, :1477–1479) |
| R2 | `bash fixtures/_krasnye_045.sh /tmp/dev-harness-verify/rev071r4/repo/scripts/gitw` | proverka | 0 | «gitw/red_gitw_obmen.sh rc=0» / «итог: 1 файлов, провалов 0» |
| R3 | `git diff frozen/contracts/071/1^{commit}..proverka -- scripts/gitw \| grep __target_in_argv` | 989673d→bb1ee569 | — | одна строка: `+# состояния на этот счёт (раньше тут был __target_in_argv; С2 r3 +` — это КОММЕНТАРИЙ крюка (gitw:595), а не код; хунк в диффе один, `@@ -578,6 +578,60 @@` |
| R4 | мутант: `git checkout 30d2d9e -- scripts/gitw scripts/gitw_preflight_071.sh` (коммит ddad65ca, /tmp/dev-harness-verify/rev071r4/mut), затем `bash fixtures/_krasnye_071.sh .` | мутант | 1 | все клетки п0…п10г «ok», затем «ОТКАЗ: п10д: rc=0 (ожидался 1): To /tmp/gitw071.wWvkmD/p10d/b1 10335bd..e6de056 main -> main» |
| R5 | `probes.sh proverka gate` (31 проба) | proverka | — | таблица ниже |
| R6 | `probes.sh 30d2d9e gate` | 30d2d9e | — | таблица ниже |
| R7 | `probes.sh proverka new` + `probes_new2.sh proverka` (21 проба) | proverka | — | таблица ниже |
| R8 | то же на 30d2d9e | 30d2d9e | — | таблица ниже |
| R9 | `git diff --quiet 30d2d9e proverka -- contracts/ roles/ fixtures/gitw/ fixtures/_krasnye_071.sh fixtures/_krasnye_045.sh .github/ package.json` | — | 0 | дифф пуст |
| R10 | `git diff --stat frozen/contracts/071/1^{commit} proverka -- contracts/071-predpolet-gitw-push-main.md fixtures/gitw_predpolet/.probe-only` | — | 0 | пусто: блоб контракта 5c888442 совпадает с frozen |

Драйверы проб: /tmp/dev-harness-verify/rev071r4/{probe.sh,probes.sh,probes_new2.sh}. Основа —
probe.sh Rev071k3b; я добавил миры wip-rp-glob, wip-rp-colon, wipgreen-rp-bare, wipgreen,
wipred-upstream-po, cwdW-push, green-main. Мир пробы: свежий bare B1; toy = `git archive <ref>`;
красный main (roles/orchestrator.md на 60000 символов → check:ceilings); upstream main→origin/main;
GIT_EXCHANGE_GUARD_CANONICAL=B1; API — закрытый порт. «ДА» значит, что refs/heads/main у B1
двинут.

### Счёт своей мерой
- В run_honest_cells 62 вызова `ok_cell` (awk по :825–1458). В выводе R1 тоже 62 строки «ok: п…».
  Батарея при этом печатает «61/61»: `CELLS=$((OKN - 1))` (:1476) вычитает само-проверку, но та
  засчитывается ДО сброса `OKN=0` (:416, :1461). Значит, вычитание лишнее, и заявленные «61» —
  недосчёт на 1 (С-3 ниже). Ни одна клетка от этого ложно не проходит: die_cell выходит с rc 1.
- 4а-исполнителя («61/61 + 22/22 + 22/22, rc 0») сходится с выводом батареи, но не с фактом:
  клеток 62. Клетки, новые относительно 30d2d9e (там 42 вызова): 62 − 42 = 20, то есть п10д и
  19 клеток п15а–п19б.

## Пункт (г). Красное для новых клеток — ПРОЙДЕН
- R4: на мутанте (impl обоих файлов = 30d2d9e) батарея падает rc 1 на п10д, bare двинут. Батарея
  останавливается на первой красной клетке, поэтому п15–п19 на мутанте не исполнялись.
- Каждую форму п15–п19 я проверил живой пробой на 30d2d9e (R6). Форма на 30d2d9e обходит, на
  proverka отказывает:
  c39/п17а, c43/(п17е-класс), c20/п17в, c42/п17г, c44/п16а, c45, c46/п16б, c47/п16в, c49/п16г,
  c24/п18а, c25/п18б, c26/п18в, c23/п19а — на 30d2d9e rc 0 и ДА, на proverka rc 1 (R5).
  c22/п19б на 30d2d9e отказывает с неверной причиной («src не разрешается: main»), на proverka —
  «чек красный: check:ceilings».
- Глоб (c27–c31, п15а–п15в) и c34/c35 (п17б) отказывают на ОБОИХ деревьях: на 30d2d9e
  регрессии fixr4 нет, она не лендилась. Поэтому эти клетки на чистом 30d2d9e могут быть
  зелёными; их красное — на fixr4-мутанте, как заявил architect (п15а/п15б/п17б). Сам я этот
  прогон не повторял.

## Пункт (д). Живые пробы гейт-списка П4

| проба | форма | мир | proverka | 30d2d9e |
|---|---|---|---|---|
| c01 контроль | `push origin main` | main | rc 1 «чек красный: check:ceilings», нет | rc 1, нет |
| c27 F-1 | `push origin '*'`, cwd = корень | main | rc 1 «refspec не разбирается: *», нет | rc 1, нет |
| c28 F-1 | то же | wip | rc 1 «refspec не разбирается: *» | rc 1 |
| c29 F-1 | `-C T push origin 'refs/heads/*'` (zzz в cwd) | main | rc 1 «refspec не разбирается: refs/heads/*» | rc 1 |
| c30 F-1 | то же | wip | rc 1 | rc 1 |
| c31 F-1 | `-C T push origin 'refs/heads/*:refs/heads/*'` | wip | rc 1 «…: refs/heads/*:refs/heads/*» | rc 1 |
| c32 контроль | `push origin 'refs/heads/*'` без совпадений | wip | rc 1 «refspec не разбирается» | rc 1 |
| c34 F-2 | `push origin -o --repo main` (PO) | wip | rc 1 «чек красный: check:ceilings» | rc 1 |
| c35 F-2 | `push origin --push-option --repo main` (PO) | wip | rc 1 «чек красный» | rc 1 |
| c39 F-5 | `push origin -o x` (PO) | main | rc 1 «чек красный» | **rc 0, ДА 5625291c→80fead93** |
| c43 F-5/С1 | `push origin -o 'a b'` (PO) | main | rc 1 «чек красный» | **rc 0, ДА** |
| c20 F-4 | `push origin --receive-pack git-receive-pack` | main | rc 1 «чек красный» | **rc 0, ДА 2f014c47→be08233e** |
| c42 F-4 | `push origin --exec git-receive-pack` | main | rc 1 «чек красный» | **rc 0, ДА** |
| c17 | `push --receive-pack=git-receive-pack origin` | main | rc 1 «чек красный» | rc 1 |
| c18 | `push origin --receive-pack=git-receive-pack` | main | rc 1 «чек красный» | rc 1 |
| c16 | `push --push-option=x origin` (PO) | main | rc 1 | rc 1 |
| c41 | `push origin --push-option=x` (PO) | main | rc 1 | rc 1 |
| c44 F-3 | `push origin +main` | main | rc 1 «чек красный» | **rc 0, ДА** |
| c45 F-3 | `push origin +main` | wip | rc 1 | **rc 0, ДА** |
| c46 F-3 | `push origin +refs/heads/main` | wip | rc 1 | **rc 0, ДА** |
| c47 F-3 | `push origin @` | main | rc 1 | **rc 0, ДА («HEAD -> main»)** |
| c49 F-3 | `push origin +HEAD` | main | rc 1 | **rc 0, ДА** |
| c24 F-6 | `-c push.default=matching push origin` | wip | rc 1 «несудимая конфигурация refspec: явного dst нет при текущей ветке wip/071/x (push.default=matching)» | **rc 0, ДА** |
| c25 F-6 | `-c remote.origin.push=refs/heads/main:refs/heads/main push origin` | wip | rc 1 «чек красный» | **rc 0, ДА** |
| c26 F-6 | remote.origin.push=…main:…main в конфиге, `push origin` | wip | rc 1 «чек красный» | **rc 0, ДА** |
| c22 F-7 | `-C T push origin main` из чужого зелёного cwd | greencwd | rc 1 «чек красный: check:ceilings» | rc 1 «src не разрешается: main» |
| c23 F-7 | `-C T push origin` | greencwd | rc 1 «чек красный» | **rc 0, ДА** |
| c19 ПРЕДЕЛ | `push --receive-pack git-receive-pack origin` | main | rc 0, ДА 7993a58f→0fd87f1a, строк ПРЕДПОЛЁТ нет | rc 0, ДА |
| c21 ПРЕДЕЛ | `push --exec git-receive-pack origin` | main | rc 0, ДА c06a6027→4625a62f | rc 0, ДА |
| c36 ПРЕДЕЛ | `push -o --repo origin main` (PO) | wip | rc 0, ДА 70b7ef16→06e36922 | rc 0, ДА |
| c40 ПРЕДЕЛ | `push -o x origin` (PO) | main | rc 0, ДА 8ca3aff8→13c20969 | rc 0, ДА |

Итог по формам, которые назвал арбитр: все формы F-1, F-2/F-4/F-5 (значение после remote и
через `=`), F-3, F-6 (c24–c26), F-7 (c22/c23) на proverka отказывают именованно, bare не двинут.
c19/c21/c36/c40 — предел 071 (exec 045 срабатывает раньше крюка). Исход записан сырым; критерием
FAIL эти формы не служат и уходят к владельцу (вопрос 1 арбитража).

### Добор r4: формы тех же классов П4, которые арбитр перечислил, но клетки п15–п19 не покрывают

| проба | форма (класс) | мир | proverka | 30d2d9e |
|---|---|---|---|---|
| x1a | remote.origin.push=`refs/heads/*:refs/heads/*` в конфиге, `push origin` (F-6) | wip | **rc 0, ДА 0b77e117→51a3be11, строк ПРЕДПОЛЁТ нет** («main -> main») | rc 0, ДА |
| x1b | `-c remote.origin.push=refs/heads/*:refs/heads/* push origin` (F-6) | wip | **rc 0, ДА abe2e2cc→beb92d2a** | rc 0, ДА |
| x1c | remote.origin.push=`:` (matching) в конфиге (F-6) | wip | **rc 0, ДА ad31c2e6→cc06b784** | rc 0, ДА |
| x1d | `-c remote.origin.push=: push origin` (F-6) | wip | **rc 0, ДА 586ff827→9114e91b** | rc 0, ДА |
| x2a | remote.origin.push=`refs/heads/main` (без `:`) в конфиге; wip зелёная, локальная main красная (F-6) | wipgreen | **rc 0, ДА 9608d545→9ac55bb4, «gitw ПРЕДПОЛЁТ: чисто»** | rc 0, ДА |
| x2b | `-c remote.origin.push=refs/heads/main push origin` (F-6) | wipgreen | **rc 0, ДА, «ПРЕДПОЛЁТ: чисто»** | rc 0, ДА |
| x2c | `-c remote.origin.push=main push origin` (F-6) | wipgreen | **rc 0, ДА, «ПРЕДПОЛЁТ: чисто»** | rc 0, ДА |
| x3a | `push origin -o --all`; wip красная, branch.wip.merge=refs/heads/main, push.default=upstream, локальная main зелёная (F-5/F-2, значение после remote) | wipred-upstream-po | **rc 0, ДА e1bee093→2d891eea, «ПРЕДПОЛЁТ: чисто»** | rc 0, ДА, «чисто» |
| x3b | `push origin -o x--all`, тот же мир (F-5) | wipred-upstream-po | **rc 0, ДА a3057e0e→5754aa13, «ПРЕДПОЛЁТ: чисто»** | rc 0, ДА («wip/071/x -> main») |
| x3c контроль | `push origin -o x`, тот же мир | wipred-upstream-po | rc 1 «несудимая конфигурация refspec: … (upstream=main)» | rc 0, ДА |
| x4a | `-C push push origin`: cwd = каталог мира, `./push` → T (F-7 -C / граница argv) | cwdW-push | **rc 0, ДА 175e61ea→271cebe2, строк ПРЕДПОЛЁТ нет** | rc 0, ДА |
| x4b | `-C push push origin main` | cwdW-push | rc 1 «чек красный» | rc 1 «src не разрешается» |
| x4c | `--work-tree push push origin` из T, каталога push нет (граница argv) | main | **rc 0, ДА 080a3a55→19cefa34, строк ПРЕДПОЛЁТ нет** | rc 0, ДА |
| x4e контроль | `-C ./push push origin` | cwdW-push | rc 1 «чек красный» | rc 0, ДА |
| x5a | `push origin -d -f main`, зелёный мир (вне П4) | green-main | **rc 0, main на B1 УДАЛЁН (fc57d394→DELETED), «ПРЕДПОЛЁТ: чисто»** | rc 0, УДАЛЁН |
| x5b | `push origin --delete wip-nonexist main` | green-main | rc 1, нет, «ПРЕДПОЛЁТ: чисто» (отказал сам git) | rc 1, нет |
| x5c контроль | `push origin --delete main` | green-main | rc 1 «refspec не разбирается: удаление main» | rc 0, УДАЛЁН |
| x6a | `push origin --branches` (git 2.43: «alias of --all»; вне П4) | wip | **rc 0, ДА 0141d715→32b44875, строк ПРЕДПОЛЁТ нет** | rc 0, ДА |
| x6b | `push --branches origin` | wip | **rc 0, ДА a49e7ec8→940603e3** | rc 0, ДА |
| x6c контроль | `push origin --all` | wip | rc 1 «чек красный» | rc 1 |
| x4d | `--exec-path push push origin --receive-pack 'git receive-pack'` | main | rc 1 «gitw ОТКАЗ: URL origin не канонический: /usr/lib/git-core» — проба неинформативна | то же |

## Находки

### Блокирующие (гейт П4 и свойства С1–С4)

- [ ] **F4-1. Класс: живой обход F-6 (remote.<r>.push), предписание impl-4 не исполнено; блокер.**
  Арбитр (П2 impl-4) предписал: «`remote.<r>.push` с dst main — покрытие; иной
  `remote.<r>.push` — несудимая конфигурация (§2 fail-closed)». В коде
  (gitw_preflight_071.sh:338) есть только `if [ "$rp_count" -gt 0 ] && [ "$rp_has_main" -eq 1 ]`.
  Ветви «rp_count>0, но dst не литерал main» нет. Глоб `refs/heads/*:refs/heads/*` и matching `:`
  молча проходят: main_cov=0, rc 0, строк ПРЕДПОЛЁТ нет, а git отправляет красный main (x1a–x1d,
  ДА в конфиге и через `-c`). Это F-6 «во всех трёх формах конфига» из П4, а c25/c26 судят лишь
  литерал `…main:…main`. Обход есть и на 30d2d9e — значит, класс не закрыт.
  Нужно: rp_count>0 и не все значения разобраны как dst ≠ main без глоба → «несудимая
  конфигурация refspec». Клетка architect — remote.origin.push с глобом и с `:`.

- [ ] **F4-2. Класс: живой обход F-6 и нарушение И-3 (чеки не на отправляемом дереве); блокер.**
  gitw_preflight_071.sh:327 `rpsrc=""; rpdst="$rp"`: для refspec без `:` в remote.<r>.push src
  обнулён. Затем :340 `send_src="HEAD"` — чеки идут по текущей ветке, хотя git отправляет
  локальную refs/heads/main. Предполёт сам для CLI-refspec применяет верное правило («bare-форма:
  src — тот же токен», :247–250). Для конфига правило другое — это вторая грамматика refspec в
  одном файле. Замер x2a/x2b/x2c: wip зелёная, локальная main красная, «gitw ПРЕДПОЛЁТ: чисто»,
  rc 0, красный main на B1. Контракт И-3: «src берётся из refspec … без `:` — сам токен».

- [ ] **F4-3. Класс: живой обход F-5/F-2 (значение после remote) и слом С2 (грамматика флагов во
  втором месте); блокер.** Таблица флагов pf_parse_push_args значение `-o` поглощает верно.
  Однако :293–295 `case "${push_args[*]:-}" in *--all*|*--mirror*) all_or_mirror=1` повторно
  читает весь argv подстрокой по скалярной склейке, включая значения arity-1 опций и любые токены
  с подстрокой `--all`. Флаг all_or_mirror гасит unsupported_reason и ставит send_src=main
  (:368–379). Мир «upstream=main, wip красная»: `push origin -o --all` и `push origin -o x--all`
  → «ПРЕДПОЛЁТ: чисто», rc 0, git везёт красную wip в main (x3a/x3b). Контроль `-o x` без
  подстроки отказывает (x3c). x3b — новая регрессия этой правки: подстрочное сравнение впервые
  появилось в a734f18, на 30d2d9e было точное `--all|--mirror`.
  050: фрагмент :293–295; отсутствующее свойство — С2 «грамматика опций ровно в одном месте»;
  более простая форма — `all_or_mirror=1` внутри arity-0-ветви таблицы на точных токенах
  `--all|--mirror` (и `--branches`, см. Н-2). Она проходит те же строки приёмки (п10а–п10г,
  c07–c11). ACCIDENTAL, блокирует.

- [ ] **F4-4. Класс: живой обход F-7 (-C) / «граница argv» и слом С2 (грамматика в крюке);
  блокер.** Крюк scripts/gitw:614–622 заново ищет подкоманду: первый токен orig[], равный
  `push|fetch|pull`. Значение глобального флага (-C, --work-tree, --git-dir, --namespace) с
  текстом `push` принимается за подкоманду. Хвост сдвигается: предполёт получает `[push, origin]`,
  считает repository=`push`, refspec=`origin` → main_cov=0 → exit 0 без строки. Замер:
  `-C push push origin` (x4a) и `--work-tree push push origin` (x4c, каталог не нужен) — rc 0,
  красный main на B1. Контроль `-C ./push` (x4e) отказывает. Это нарушает С2 («в крюке — ни
  `--repo`, ни иной arity»): крюк держит свою грамматику позиции подкоманды без arity глобальных
  флагов, хотя И-2 её уже знает.
  050: фрагмент gitw:614–622; отсутствующее свойство — С1/С2 (токены доходят по правильной
  границе, грамматика одна); более простая форма — `post_sub_idx=$(( ${#ctx[@]} + ${#cfg[@]} + 1 ))`.
  Цикл И-2 (gitw:57–92) кладёт каждый токен до подкоманды ровно в ctx или cfg, неизвестный флаг
  выходит отказом. Новых строк в 045, нового состояния и цикла это не требует, и форма проходит
  те же строки приёмки (п19а/п19б, c22/c23). ACCIDENTAL, блокирует.

### Вне гейт-списка П4 (FAIL ими не обоснован; называю для владельца и следующей правки)

- [ ] **Н-1. Удаление main через `-d`, за которым идёт флаг (frozen §2: «удаление `:main` → отказ»;
  предписание арбитра: «`--delete main`/`-d main` → тот же отказ»).** :162
  `case "$tok" in --delete|-d) delete_active=1 ;; *) delete_active=0 ;; esac` сбрасывает режим
  удаления на любом arity-0-флаге. К тому же он действует только на ОДИН следующий позиционный
  токен, а git `--delete` удаляет ВСЕ перечисленные ref. Замер x5a: `push origin -d -f main` в
  зелёном мире → «ПРЕДПОЛЁТ: чисто», rc 0, refs/heads/main на B1 удалён. Литеральная форма
  x5c отказывает (на 30d2d9e — удаляла).
- [ ] **Н-2. `--branches` в таблице записан безвредным arity-0 флагом (:149), а в git 2.43 это
  «alias of --all» (`git push -h`).** x6a/x6b: красный main уходит молча (так же и на 30d2d9e).
  Арбитр (С3): «флаги, меняющие семантику refspec (… `--all` …), — в таблице же». Алиас --all
  классифицирован неверно.

### Советы (не блокируют)
- [ ] С-1: критерий (в) буквально не пуст: grep находит комментарий gitw:595 «раньше тут был
  __target_in_argv». Байты цикла И-4а равны frozen (хунк один, @@ -578), но историческое
  упоминание из шапки стоит снять, чтобы критерий был чистым.
- [ ] С-2: шапка предполёта :18–21 («первым токеном ИДЁТ подкоманда (push)») противоречит
  :116–117 и крюку: крюк передаёт `orig[@]:post_sub_idx`, то есть хвост уже ПОСЛЕ push. Арбитр
  требует, чтобы шапка описывала код.
- [ ] С-3 (architect): «честные клетки: 61/61» при фактических 62 (`CELLS=OKN-1`, :1476 — с
  r1-класса Р-11). Счётчик лжёт на 1, это та же болезнь «заявленное ≠ сделанное».
- [ ] С-4: ложные отказы fail-closed: голый `--force-with-lease` (в git это arity-0 форма) не в
  таблице; раздельная форма `--recurse-submodules <v>` тоже. Это не обход, но легальный push
  получает отказ.
- [ ] С-5: атомарность. Арбитр: «Коммиты атомарны по классам». a734f18 одним коммитом несёт
  impl-1…impl-4 (+347/−178), c3cbfbb — отдельная донастройка таблицы. Откатить по классам нельзя.

## С1–С4 (чтением кода и живой мерой)
- **С1 (без неквоченной скалярной подстановки на пути крюк→предполёт): соблюдено.** gitw:627 —
  `"$PF_SCRIPT" "$target" --pf-ctx-n "${#ctx[@]}" "${ctx[@]}" --pf-cfg-n "${#cfg[@]}" "${cfg[@]}" "${orig[@]:post_sub_idx}"`,
  всё в кавычках. Предполёт читает argv через `"${!i}"`. Живьём: c27–c31 (глоб доходит
  побайтово), c43 и клетка п17е (`-o 'a b'` одним токеном). Граница при этом считается неверно
  (F4-4) — это С2. Внутренняя скалярная склейка `${push_args[*]}` (:293) пути передачи не
  касается, но ломает С2 (F4-3).
- **С2 (грамматика опций push ровно в одном месте, в крюке ни --repo, ни arity, в цикле И-4а 0
  новых строк): НАРУШЕНО.** Цикл И-4а равен frozen (R3: хунк один) — эта часть выполнена. Но
  (а) у крюка своя грамматика позиции подкоманды, gitw:614–622 (F4-4); (б) у предполёта второй
  разбор флагов вне таблицы, :293–295 (F4-3); (в) у предполёта вторая грамматика refspec для
  remote.<r>.push, :321–328 против :247–250 (F4-2).
- **С3 (неизвестный флаг → именованный отказ): соблюдено по букве.** Таблица — явный список
  (:148–189), `-*)` даёт «несудимая конфигурация refspec: неразбираемый флаг <f>» (п17д зелёная,
  флаг `--nikogda-net-071`). Семантика таблицы при этом неверна: `--branches` (Н-2) и
  `-d`/`--delete` (Н-1).
- **С4 (ctx/cfg доходят до каждого git предполёта): соблюдено.** Все git-вызовы идут через
  `g() { git "${pf_ctx[@]}" "${pf_cfg[@]}" "$@"; }` (:113). Проверка: `git grep` голых
  `git <подкоманда>` вне комментариев — rc 1 (пусто). Живьём: c22–c26 и клетки п18/п19 зелёные.

## Зоны
- a734f18 и c3cbfbb — автор implementer <implementer@dev-harness.local>, файлы только
  scripts/gitw и scripts/gitw_preflight_071.sh (ЗОНА implementer). Дифф gitw к frozen — один
  хунк @@ -578 между И-7 (ls-remote, :573–580) и И-8 (exec): ПЕРЕСЕЧЕНИЕ 045 соблюдено, R2 rc 0.
- f130a62 — автор architect <architect@dev-harness.local>, только
  fixtures/gitw_predpolet/red_predpolet_071.sh (ЗОНА architect).
- R9: contracts/, roles/, fixtures/gitw/, раннеры, .github/, package.json не тронуты. Выхода за
  зону нет.

## Норма и frozen
Блоб контракта 5c888442 равен frozen (R10), нормативных правок в дельте нет. Батарея только
усилена: 20 клеток + стабы s21/s22, ни одна прежняя клетка не ослаблена (п10д стала строже —
полная причина).

## Н-39
«Стабы к ветвям привязывает architect по коду, НЕ проза контракта». Стабы s21 «plyus» и s22
«flagval» привязаны в коде батареи: таблица стаб-пака `"s21:plyus:чек красный: check:ceilings"`,
`"s22:flagval:…"`; эмуляция дефекта в mk_stub (`[ "$DEF" != "s21" ]`, `[ "$DEF" = "s22" ]`);
шапка батареи — «умирает на п16а / п17а». Контракт не тронут. Н-39 соблюдён.

## r2/r3-предметы
Сломанных нет. Клетки п0–п14б и стаб-пак 20→22 зелёные (R1). R-14 r2 (--all/--mirror) живьём
отказывает (x6c). Все формы F-1…F-7 r3 из списка арбитра отказывают (R5).

## Паразитная сложность (050)
- Сентинелы `--pf-ctx-n N … --pf-cfg-n M` (интерфейс предполёта). (1) С4. (2) Состояние явно
  видно в argv. (3) При правке свойства меняются два файла — столько же, сколько до правки.
  (4) Интерфейс вырос на два флага, функциональность на С4 — модуль не мельчает. (5) Потребители —
  п18/п19 и шаг CI. ESSENTIAL.
- pf_parse_push_args (таблица флагов). (1) С2/С3. (2) Состояние локальное (state, delete_active),
  видно только в результатах repo_token/refspecs; delete_active неявно сбрасывается (Н-1).
  (3) Одно место — но рядом живёт второй разбор :293 (F4-3). (4) Модуль глубокий. (5) Потребители —
  п17а–п17д. ESSENTIAL; дубль :293 — ACCIDENTAL (F4-3, блокирует).
- Скан post_sub_idx в крюке (gitw:614–622). (1) С1: граница хвоста. (2) Неявное состояние —
  позиция находится по совпадению текста, а не по разбору И-2. (3) При правке глобальных флагов
  045 меняются и И-2, и этот скан: +1 место. (4) Мелкий модуль, повторяет И-2 хуже оригинала.
  (5) Потребитель есть, но логику И-2 он повторяет. ACCIDENTAL, блокирует (F4-4: фрагмент,
  свойство и простая форма названы).
- Ветвь remote.<r>.push (:303–341). (1) F-6/impl-4. (2) Состояние rp_count/rp_has_main.
  (3) Вторая грамматика refspec рядом с :247–250 (F4-2). (4)–(5) Потребители — п18б/п18в.
  ESSENTIAL по цели, реализация неполна (F4-1/F4-2).
- Клетки п10д, п15а–п19б, стабы s21/s22 (одна семья). (1) Формы П4. (2) Миры явные. (3)–(5)
  Потребитель — раннер 071 и шаг CI; грамматику не повторяют. ESSENTIAL.

## Итог
FAIL. Живые обходы из гейт-списка П4 на proverka bb1ee569:
- F4-1 — F-6, remote.<r>.push с глобом и `:`;
- F4-2 — F-6, remote.<r>.push без `:`, чеки не на отправляемом дереве;
- F4-3 — F-5/F-2, значение `-o` после remote через подстроку `*--all*`;
- F4-4 — F-7/граница argv, значение глобального флага, равное `push`.

Свойство С2 нарушено, С1/С3/С4 соблюдены. Зоны чисты, frozen не тронут, Н-39 соблюдён, r2/r3
не сломаны. Формы, названные в П4 буквально (c27–c32, c34–c35, c39, c41–c47, c49, c16–c18, c20, c22–c26), закрыты.

По капу арбитража причины F4-1…F4-4 относятся к классам «граница argv» и «грамматика
флагов/refspec» — **r5 не открывается, предмет уходит к владельцу**. Владельцу вместе с этим
идут c19/c21/c36/c40 (предел 071, вопрос 1 арбитража) и Н-1/Н-2.
