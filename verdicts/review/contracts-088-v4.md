accept

# Ревью 088, круг 7 — «в полёте ничего»: дверь и указатель HANDOFF (после решения арбитра круга 5)

Предмет — локальный main оркестратора `a4915227d1dc37553d20b0280d6e663706fe68d2`, контракт
`frozen/contracts/088/1` (`79f0756`). Реализация:
- `b904116` (implementer) → land `a450fe6`;
- `f1c07a7` + `e5b9a45` (architect) → land `a491522`.

База сравнения — `fc5f5b6` (коммит арбитража круга 5). Решение:
`verdicts/arbitration/088-ukazatel-krug5.md`.

Клон: `/tmp/dev-harness-verify/rev7-088/repo` (`git clone /home/harness/dev-harness`, ветка `review-088-v4`).
Находки в reslop-формате: `.review/2026-10-07-01.md` (файл лежит в клоне). Коммит `.review/` под reviewer отвергнут check_zones: «ОТКАЗ: вне зоны: .review/2026-10-07-01.md». `--no-verify` не применялся, поэтому полный текст находок вложен ниже, в §Приложение. Блокирующих нет. Неблокирующих 8 (Н-1…Н-8).

Пробы одноразовые и не входят в коммит: `/tmp/dev-harness-verify/rev7-088/probes/*.sh`.
- `p_b.sh` — Б-1/Б-2: тоу-репо со `scripts/` и `.githooks/` судимого дерева, коммит живым способом оркестратора.
- `p_drift.sh` — сдвиг k7.
- `p_dver.sh` и `p_decoy.sh` — Б-3: шим `getent`, ловушечная сессия.
- `p_noesc.sh` — мутанты двери.
- `p_old.sh` — новая батарея против субъекта `fc5f5b6`.
- `p_accept.sh` — П1/П6/П7/П8.
- `p_merge.sh` — путь merge.

## 1. Область правки — в границах

Состав каждого коммита (`git diff --stat <c>^1 <c>`):
- `b904116`: `scripts/check_staged.sh` (+53/−26), `scripts/orch_restart.sh` (+26/−44) (`git diff --numstat`). Это ровно ЗОНА implementer 088.
- `f1c07a7`: только `fixtures/strazh_088/{.probe-only,_toy.sh,red_dver_088.sh,red_stuby_088.sh,red_ukazatel_088.sh}`.
  Это ЗОНА architect 088.
- `e5b9a45`: только `NABLIUDENIA_ARCHITECT.md` (+6, запись А-371). Файл в живой зоне architect 085/1, класс уже известен с прошлых кругов.

Merge-коммиты `a450fe6` и `a491522` несут тот же diff относительно первого родителя. Остальное в `fb08e98..a491522`
(`.githooks/pre-commit`, `scripts/*plan*`, ci.yml и т.д.) пришло из 083/084 (`6609f70` и др.), а не из 088.

Неприкосновенность проверена так:
- `git diff --stat fc5f5b6 a491522 -- contracts/ frozen/ scripts/lib_session.sh ops/ scripts/lib_zones.sh scripts/check_charter.sh`:
  пусто, кроме `.githooks/pre-commit` от `6609f70` (implementer 084).
- `git diff frozen/contracts/088/1 a491522 -- contracts/088-…md`: пусто. Замороженный текст не тронут.
- И-4 байт-в-байт: `sha256 scripts/lib_session.sh = ad8a0292…c5a2` на HEAD и на `frozen/contracts/088/1`.
  П7 `git diff --exit-code 592fc4e -- scripts/lib_session.sh ops/server/root/orch-peak` → rc 0.
  `orch-peak` после заморозки менял только `1f32180` (implementer 085). Коммиты 088 его не касаются.

## 2. Сырой вывод (своя мера, не доклад)

`reslop t -- bash fixtures/_krasnye_088.sh` → `exit: 0`. Хвост сырого лога:
```
red_dver_088.sh: зелёных 13, красных 0, пропусков 0
red_ukazatel_088.sh: зелёных 29, красных 0, пропусков 0
стаб-пак 088: 35/35 поймано, диффпроба 35/35
ИТОГ 088 (polnyj): rc=0
```
Счёт своей мерой, не по выводу автора:
- строк `ЗЕЛЕНО` в логе 42: L1 + D0–D11 = 13, B0–B9/B11/B13–B30 = 29;
- строк `стаб … пойман` 35;
- `grep -cE '^#   s[ab][0-9]+ →'` даёт 23 на `fc5f5b6` и 35 на HEAD.

Сводка «+12 новых клеток» неточна: стабов +12, клеток +16 (Н-6).

Строки приёмки (`p_accept.sh`):
```
P1_fast        rc=0  ИТОГ 088 (fast): rc=0
P6_072         rc=0  итог 072: rc-перезапуск=0 rc-дверь-перед-критиком=0
P6_080         rc=0  стабы 9/9 + дифф 9/9 + честные 31/31
P6_074         rc=1  итог 074: красных клеток=1 стабы=7/7   (КРАСНО: cell_k5b — станционная, как ДО)
P6_ap_staged   rc=1  фикстур: 33 · предъявлено красным 33 · расхождений: 1 (FAIL lib_plan.sh — 084, Н-7)
P6_ap_restart  rc=1  фикстур: 1 · расхождений: 1 (то же lib_plan.sh)
P7_592 / P7_fc5 rc=0
P8_pre_critic  rc=0  КРИТИК: дверь зелёная
P8_threat      rc=0  ЗАЩИЩАЕТ 3, НЕ ЗАЩИЩАЕТ 4
P8_ceilings    rc=0  потолки в порядке
```

## 3. Проверка не переписана под реализацию

- Коммит implementer `b904116` не трогает `fixtures/`. Коммит architect `f1c07a7` не трогает `scripts/`. Авторы различимы по `%an`/`%cn`.
- Мини-судья стаб-пака переведён на литерал `PTR_088` из памяти оракула. Это предписание арбитра (п.5), а не подгонка:
  оракул `PTR_088` по-прежнему снимается из 074 в `_toy.sh` ДО вызова субъекта (правило 8).

## 4. Красное предъявлено — своей мерой

- **Новая батарея против субъекта `fc5f5b6`** (`p_old.sh`):
  - `red_ukazatel_088.sh`: зелёных 18, красных 11 (КРАСНО B19–B29). B30 зелёная, это заявленный пара-негатив.
  - `red_dver_088.sh`: зелёных 10, красных 3 (КРАСНО D8, D9, D10). D11 — пара.
- **Дрейф k7** (`p_drift.sh`: в 074 `HANDOFF_PTR='… (дрейф)'`, `check_staged.sh` прежний):
  КРАСНО B0, B5, B8, B24, B26, B28, rc 1. Frontier п.6 и §Остаточный риск п.3 держатся. Это как раз то свойство, что было потеряно на fb08e98 (З-2).
- **Мутанты реального субъекта** (`p_noesc.sh`):
  - без экранирования дома ловушечные `st*ar`/`br[ack]et`/`q?m` уходят в чужую сессию: «HEAD расходится», живой субагент не виден;
  - без `IFS=$'\n'` дом с пробелом/TAB и шов с пробелом/TAB слепнут.
  - Честный субъект на тех же входах всё ловит (ниже).

## 5. Повтор живьём трёх фиксов арбитража — буквально против текста решения

### Б-1 — литерал, чтение 074 из production снято: ДА

`check_staged.sh:317`: `_handoff_ptr='- Серверная обвязка станции — единый источник: ops/server/README.md (инвентарь механизмов, установка, настройка).'`.
- `sha256` литерала равен `sha256` `HANDOFF_PTR` из 074 (`0d45c785…3d3b`), по одному присваиванию в каждом.
- В `check_staged.sh`/`orch_restart.sh` слово `red_server_obvjazka_074` осталось только в комментариях (`grep`), `git show :fixtures/…` нет.

Пробы (`p_b.sh`, staged HANDOFF.md без строки):
```
P0 control bad staged                    rc=1 moved=no otkaz=yes
P1 rm --cached 074                       rc=1 moved=no otkaz=yes
P1b 074 gone everywhere (HEAD+wt)        rc=1 moved=no otkaz=yes
P2 two HANDOFF_PTR                       rc=1 moved=no otkaz=yes
P3 074=attacker + HANDOFF attacker       rc=1 moved=no otkaz=yes
P3b 074 double-quoted                    rc=1 moved=no otkaz=yes
P4 good, 074 removed (accept)            rc=0 moved=yes ptr_in_HEAD=yes
P5 env PTR_088/HANDOFF_PTR/_handoff_ptr  rc=1 moved=no otkaz=yes
```

### Б-2 — индекс коммита: ДА

Код: `_orig_idx` снимается до `unset` (`:86`). Обратно он принимается под `--absolute-git-dir`, только если файл существует (`:261-273`),
и происходит это до staged-выборки (`git diff --cached`, `:284`). Ни одного `exit 0` до ветви 088 нет (awk по `NR<330`).
```
Q1 commit -a bad wt                      rc=1 otkaz=yes
Q2 commit -- HANDOFF.md bad wt           rc=1 otkaz=yes
Q3 commit -i HANDOFF.md bad wt           rc=1 otkaz=yes
Q4 commit -o HANDOFF.md bad wt           rc=1 otkaz=yes
Q5 idx bad, wt good, -a                  rc=0 ptr_in_HEAD=yes
Q6 idx bad, wt good, -- path             rc=0 ptr_in_HEAD=yes
Q7 idx good, wt bad, plain               rc=0 ptr_in_HEAD=yes
Q8 rm wt + commit -a (D)                 rc=1 otkaz=yes
Q8b git rm HANDOFF.md plain              rc=1 otkaz=yes
Q9 commit --amend -a bad wt              rc=1 otkaz=yes
Q10 commit -- README.md HANDOFF.md       rc=1 otkaz=yes
Q11 commit -a из подкаталога             rc=1 otkaz=1
Q12 GIT_INDEX_FILE=<abs>/.git/alt bad    rc=1 otkaz=yes
Q15 linked worktree -a bad               rc=1 otkaz=yes
Q16 linked worktree plain bad            rc=1 otkaz=yes
Q17 linked worktree -a good              rc=0 ptr_in_HEAD=yes
Q13 GIT_INDEX_FILE=.git/alt (отн.) bad   rc=0 moved=yes ptr_in_HEAD=no   ← Н-1
Q14 GIT_INDEX_FILE=<вне git-dir> bad     rc=0 moved=yes ptr_in_HEAD=no   ← Н-2 (предписано арбитром)
эхо-хук: plain → IDX=.git/index; отн. alt → IDX=.git/alt; linked wt plain → IDX=<repo>/.git/worktrees/wt/index
```

Новый контрпример сверх 35 клеток — Q13. Почему он не блокирует:
- эталонный вариант арбитра из 20 строк (З-4) этот случай тоже отбрасывает;
- силу обхода Q13 не увеличивает, она равна Q14, а Q14 арбитр вывел за предмет гигиеной 016.

Один шаг до закрытия Q13 есть: резолвить относительный путь от `$ROOT`. Полный разбор — Н-1/Н-2.

### Б-3 + D1-general: перебивка снята, вызов идёт через `IFS=$'\n'` + `set +o pipefail` в подоболочке, дом экранируется — ДА

- Блок `current_session_dir() { … }` двери удалён целиком (−42 строки), в двери нет второй грамматики глоба.
- Вызов (`:305-310`): `SESS_DIR="$( IFS=$'\n'; set +o pipefail; current_session_dir … )"`.
- Дом: `_orch_uh_glob="${_orch_uh//[][\*?\\]/\\&}"` (`:109`), затем `HOME="$_orch_uh_glob" . lib_session.sh`.
  Экранирование проверено на bash 5.2.21: `/h/a[b*c?d\e]` → `/h/a\[b\*c\?d\\e\]`.

`p_dver.sh` — свежий `LiveSub`, во всех строках маркер не поставлен:
```
home: plain / sp ace / $'t\tab' / br[ack]et / st*ar / q?m / back\slash / 'all [*?\] x' /
      .local/state/y z / a]b / semi;co$(id) / dash -n / !bang{a,b}~   → rc=1 ОТКАЗ: живые субагенты: LiveSub (13/13)
seam: 'seam plain' / 'seam sp ace' / $'seam\ttab' / 'seam/.local/state/q r' / escaped \[x\] / */sess/*.jsonl
                                                                       → rc=1 ОТКАЗ: живые субагенты: LiveSub (6/6)
control: только старый журнал                                          → rc=1 ОТКАЗ: HEAD расходится с origin/main
home 'many sp' + 600 session-журналов (pipefail+IFS вместе)            → rc=1 ОТКАЗ: живые субагенты: LiveSub
```
`p_decoy.sh`: дом с метасимволом и рядом более свежая ловушка (`stXar`, `braet`, `qZm`) без живых → все 3 дают «живые субагенты: LiveSub».

Граница шва «неэкранированный `[x]` — неконформно» записана в шапке `red_dver_088.sh` (D11 + абзац «Граница конформности»), как и требует арбитр.

## 6. Норма не тронута

Нормативные документы (`roles/`, `norms/`, контракт) в диффе 088 отсутствуют. `NABLIUDENIA_ARCHITECT.md` — журнал наблюдений, а не норма.

## 7. ПРОВОДКА (038)

- `guard=fixtures/_krasnye_088.sh` существует, и это барьер именно этого предмета: он гонит `red_dver_088.sh`, `red_ukazatel_088.sh` и `red_stuby_088.sh`, rc 0 (выше).
- ПРОВОДКА-ЭНФОРСМЕНТ обоснована честно: норм-строк ролей нет, механизм двух точек. CI-шаг отложен текстом контракта (живые зоны 083/084/087).
- В `ci.yml` его нет (`grep _krasnye_088` пусто), и это соответствует §Зоны «РАБОТА НЕ РАЗДАЁТСЯ».

## 8. Паразитная сложность (050) — по артефактам диффа

| Артефакт | (1) свойство | (2) состояние | (3) файлов на правку | (4) глубина | (5) потребитель | Класс |
|---|---|---|---|---|---|---|
| `check_staged.sh` литерал `_handoff_ptr` | Frontier п.5/п.6, Ост. риск п.3, Б-1 | константа, явна | 2: литерал + k7 074; дрейф краснит B0 — не выросло | блок чтения 074 заменён одним присваиванием, интерфейс прежний | B0/B1/B19–B22 | ESSENTIAL |
| `check_staged.sh` `_orig_idx` + принятие `GIT_INDEX_FILE` | И-5 + ЗАЩИЩАЕТ п.3, Б-2 | 1 переменная до `unset`, `export` по проверке; в выводе не видна, но rc/отказ наблюдаемы | 1 | +20 строк, новых флагов/rc нет | B23–B30 | ESSENTIAL |
| `orch_restart.sh` `_orch_uh_glob` | И-1, D7/D8, Б-3 | локальная, сразу `unset` | 1 | 1 строка | D7, D8 | ESSENTIAL (Н-4 — совет по форме) |
| `orch_restart.sh` `IFS=$'\n'` в подоболочке | И-2′, D1-general | только подоболочка | 1 | 3 строки | D6, D9, D10 | ESSENTIAL |
| `orch_restart.sh` удаление перебивки `current_session_dir` | Frontier п.1(ii)/п.2 | −состояние | −1 грамматика | −42 строки | D8 | снижение |
| `red_ukazatel_088.sh` B19–B30 (одна семья) | решение арбитра п.5 (Б-4) | нет | 1 | клетки на общем каркасе | П3, `_krasnye_088.sh` | ESSENTIAL |
| `red_dver_088.sh` D8–D11 + `shov_kletka` | Б-3, граница шва | нет | 1 | 1 функция на 3 клетки | П2 | ESSENTIAL |
| `red_stuby_088.sh` sa9–sa11, sb16–sb24, литерал в `shapka` | стаб на каждую новую ветвь (Н-39), арбитр п.5 | нет | 1 (+ таблица PAK в шапке) | `porcha` переиспользован | П4 | ESSENTIAL |
| `_toy.sh` `kommit … -- <форма>`, `case "$SCR"` | B23–B29 (формы commit), D9–D11 (скратч буквально в шве) | нет; отказ rc 2 именован | 1 | парсинг `--`, без новых env | B23–B29, D9–D11 | ESSENTIAL |

Находок ACCIDENTAL нет.

## Итог

Все три фикса по решению арбитра круга 5 выполнены буквально и повторены живьём. Б-1: удаление, дублирование и кавычки в 074 не выключают суд,
дрейф k7 краснит B0. Б-2: формы `-a`, `--`, `-i` и `-o` судят индекс коммита в обе стороны, в том числе в связанном worktree.
Б-3: дома с пробелом, TAB и метасимволами, а также нестандартные швы находят живого субагента.

Новые контрпримеры сверх 35 клеток нашлись, но не блокируют. Q13 — относительный альтернативный индекс (Н-1). Q14 — индекс вне git-dir, вывод за предмет предписан арбитром (Н-2).
Чистый `git merge` вне pre-commit (Н-3) — новый сценарий, вне замороженного предмета. Остальное (Н-4…Н-8) — советы и счёт.
Всё перечисленное — вопросы владельцу и советы, слияние они не держат.

**accept** — предмет `a4915227d1dc37553d20b0280d6e663706fe68d2` (контракт `frozen/contracts/088/1`).

## Приложение — `.review/2026-10-07-01.md` (дословно)

````markdown
---
status: ready
subject: contracts/088 (frozen/contracts/088/1 @ 79f0756), локальный main оркестратора @ a491522 (land wip/088/implementer a450fe6 ← b904116; land wip/088/architect a491522 ← f1c07a7 + e5b9a45)
verdict: verdicts/review/contracts-088-v4.md (accept, круг 7)
reviewer: reviewer
prev: verdicts/arbitration/088-ukazatel-krug5.md (решение круга 5: Б-1, Б-2, Б-3+D1-general)
---

# Review 088, круг 7 — находки

Клон: `/tmp/dev-harness-verify/rev7-088/repo` (`git clone /home/harness/dev-harness`, ветка `review-088-v4` от `a491522`).
Пробы одноразовые, вне дерева: `/tmp/dev-harness-verify/rev7-088/probes/{p_b,p_drift,p_dver,p_decoy,p_noesc,p_old,p_accept,p_merge}.sh`.
Что делает каждая и что она показала, записано в вердикте, поэтому файлы можно удалить.

## Блокирующие

Нет.

## Неблокирующие (вопрос владельцу / совет; слияние не держат)

- [ ] **Н-1** (Б-2, расхождение с замечанием арбитра «Внимание implementer»). `scripts/check_staged.sh:261-273`.
  Конструкция `case "$_orig_idx" in /*) …` молча отбрасывает ЛЮБОЙ относительный `GIT_INDEX_FILE` хука.
  Арбитр (З-4) писал: «относительный путь резолвить от `$ROOT` (cwd хука)».
  Мера Q13: `cd repo && GIT_INDEX_FILE=.git/alt git commit`, где в `.git/alt` staged HANDOFF.md без строки, а в `.git/index` строка есть.
  Хук получил `IDX=.git/alt` (эхо-хук), исход `rc=0 moved=yes ptr_in_HEAD=no`: в HEAD нет строки-указателя.
  Тот же индекс абсолютным путём (Q12) даёт `rc=1 otkaz=yes`. Почему не блок: эталонный вариант арбитра из 20 строк
  (З-4: «относительный `.git/index` … валидацию не проходит») ведёт себя так же. Силы обхода сверх Н-2 это не добавляет.
  Более простая форма, которая проходит те же строки: перед `case` выполнить `case "$_orig_idx" in /*) ;; *) _orig_idx="$ROOT/$_orig_idx" ;; esac`.
- [ ] **Н-2** (вопрос владельцу, модель угроз). Класс «коммит из индекса вне git-dir». Мера Q14:
  `GIT_INDEX_FILE=/…/altx git commit` (в altx HANDOFF.md без строки) → `rc=0 moved=yes ptr_in_HEAD=no`.
  Git коммитит именно этот индекс, а судья его игнорирует. Это предписано арбитром («подложный `GIT_INDEX_FILE` вне git-dir игнорируется (гигиена 016)»),
  поэтому здесь не FAIL. Однако §Модель угроз НЕ ЗАЩИЩАЕТ этот класс не перечисляет, а ЗАЩИЩАЕТ п.3 обещает «судится то, что попадёт в коммит».
  Предложение: явно записать класс в НЕ ЗАЩИЩАЕТ / «не контрпример» следующей редакции либо различать в судье вызов из хука и прямой вызов.
- [ ] **Н-3** (новый сценарий, вне замороженного предмета — предложение владельцу). Чистый `git merge` двух ветвей,
  каждая из которых прошла pre-commit (rc 0), даёт HANDOFF.md, где строка-указатель вне первой секции.
  `git merge` не вызывает pre-commit, а `.githooks/pre-merge-commit` нет. Мера `p_merge.sh`: `A rc=0, B rc=0, merge rc=0`,
  «pointer NOT in first section», HEAD — merge-коммит с двумя родителями. Предмет Б — «отказывается pre-commit'ом», И-8 —
  хук не правится, поэтому здесь не FAIL. Ловец — k7 на CI после пуша [INFERENCE: k7 на CI мной не прогонялся].
- [ ] **Н-4** (совет, переносимость). `scripts/orch_restart.sh:109` `${_orch_uh//[][\*?\\]/\\&}` полагается на `patsub_replacement`
  (bash ≥ 5.2). При `shopt -u patsub_replacement` (поведение bash ≤ 5.1) получается `/h/a[b` → `/h/a\&b` (замер). Для дома с метасимволами
  это fail-open: каталог не находится, нога (1) пройдена. На станции bash 5.2.21, CI `ubuntu-latest` — не дефект среды предмета.
  Форма без зависимости — та, что у мини-двери architect: `sed 's/[][\\*?]/\\&/g'`.
- [ ] **Н-5** (атомарность, замечание). `b904116` закрывает три пункта арбитража (Б-1, Б-2, Б-3) одним коммитом в двух файлах.
  Задача одна (implementer круга 6 по одному решению арбитра), ссылка на предмет есть — это не отказ. Откатить её по частям нельзя.
- [ ] **Н-6** (заявленное ≠ сделанному, счёт). Сводка оркестратора: «35/35 стаб-пак (было 23, +12 новых клеток B19-B30+D8-D11)».
  Своя мера: стабов 23 → 35 (`grep -cE '^#   s[ab][0-9]+ →'` на fc5f5b6 / a491522), то есть +12 стабов.
  Новых КЛЕТОК 16 (B19-B30 — 12, D8-D11 — 4). Всего клеток 42: B 29 + L1/D 13 (подсчёт строк ЗЕЛЕНО в сыром логе).
- [ ] **Н-7** (вне 088, сосед). `verify_antiplacebo.sh --scope check_staged|orch_restart` даёт rc 1 с 1 расхождением, как и ДО по П6.
  Причина сейчас — `FAIL lib_plan.sh: не классифицирован` (зона 084), не 088. Отметка оркестратору для 084.
- [ ] **Н-8** (гигиена сессии). Первый клон `…/wt/t268cac903/m/rev7` (до перехода в `/tmp/dev-harness-verify/`) удалить
  не дала политика Н-85 (allowlist записи). Он в изолированном worktree судьи и в историю не попадает.
````
