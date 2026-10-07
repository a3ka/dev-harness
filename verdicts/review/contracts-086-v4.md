FAIL

# Вердикт reviewer: контракт 086 (frozen/contracts/086/1), круг 5

Предмет: main @ `2e23370ead45fa845805516c118278c09435bf7c` — после круга 4 (`verdicts/review/contracts-086-v3.md`,
FAIL, Б-1..Б-4): `70d6033` (086 implementer-r7, ленд `70871be`), `55874d6` (086 implementer-r8, ленд `42e7d7c`).
Находки с чекбоксами — `.review/2026-10-07-05.md`. Клон `/tmp/dev-harness-verify/r086k5/repo`; worktree «ДО» —
`…/pre086` @ `64ac67b` (родитель c3bbb48), `…/at_df40823` @ `df40823` (предмет круга 4), `…/pre_r8` @ `70d6033`.
Пробы — throwaway `/tmp/dev-harness-verify/r086k5/probe_{okno,spy,fer,notags}.sh`.

Итог: из четырёх находок круга 4 закрыты буквально две (Б-2, Б-3 в мирах с уставом); Б-1 не закрыта и
обоснована ложным фактом (второй отказ — арбитр); Б-4 не закрыта: строка А8 `verify_antiplacebo --scope …` красна
61/73 тем же механизмом на фикстурах land_agent. Новые блоки: Б-5 (страж r8 — fail-open по И-5, клон без тегов,
проглоченный rc) и Б-6 (r7 меняет полный режим check_charter — И-5/ПЕРЕСЕЧЕНИЕ 065).

## 1. Сырой вывод guard — свой прогон

`bash fixtures/_krasnye_086.sh` на 2e23370, `BATTERY_RC=0 elapsed=111s`:

```text
стаб-пак 086: 13/13 поймано, диффпроба 13/13            — red_stuby_086.sh: rc=0
ИТОГ 086 red_accept_086.sh: зелёных 6, красных 0, не исполнено 0   — rc=0
ИТОГ 086 red_land_086.sh: зелёных 8, красных 0, не исполнено 0     — rc=0
ИТОГ 086 red_huk_spawn_086.sh: зелёных 5, красных 0, не исполнено 0 — rc=0
ЗЕЛЕНО: R1: зелёный за 12 с / R2: 19 с / R3: принятая находка (б 6ffc8f92)       — red_istorija_1: rc=0
ЗЕЛЕНО: R4: принятая находка (б f1d7f737) / R5: 11 с / R6: 14 с                  — red_istorija_2: rc=0
ЗЕЛЕНО: R7: 13 с / R8: зелёный за 16 с / R9: принятая находка (б 2c01b1ed)        — red_istorija_3: rc=0
БАТАРЕЯ gejt_svedenija: итог 4/4 классов закрыто                                 — rc=0
ИТОГ 086 (polnyj): rc=0
```

Своя мера счёта по строкам вывода: `ЗЕЛЕНО:` 6+8+5+9 = 28 (A1–A6, L1–L7 с L2b, H1–H3, S0, S1, R1–R9); «пойман» 13,
«диффпроба … зелёная» 13 (А6); 4 класса (А7). Худшее окно — R2 19 с ≤ 60 с (И-10). Заявление r7 «28 зелёных, 13
стаб-пака, 4/4, 116 с» — совпадает (у меня 111 с). Guard по-прежнему НЕ исполняет А8 (§3) и не несёт клеток под
И-5 судей (Н-6): на df40823 он тоже был зелёным при открытой Б-3.

## 2. Находки круга 4 — буквальное закрытие, своя мера

| Находка | Исход | Своя мера |
|---|---|---|
| Б-1 хунк 17/18 пар грандфазера в c3bbb48 | **НЕ закрыта** | `c3bbb48^:check_charter.sh` — 0 вхождений `6609f708` и `797a3129`; `git show c3bbb48` добавляет 2 строки `+…6609f708`; `git blame HEAD` строк `razreshil()` 262–264 → `c3bbb48a (implementer …)`; `merge-base --is-ancestor 0470895 c3bbb48^` → 1. Утверждение r7 «и на main, и в worktree файл уже несёт 6609f708/797a3129 … не новое добавление» — ложно. c3bbb48 не предок `origin/main` основного репо (`fb08e98`) — пересборка без ханка возможна, не сделана. |
| Б-2 строка `[ -s "$TMP/authors" ] \|\| continue` | закрыта | `git diff 64ac67b HEAD -- scripts/check_zones.sh`: строка на месте; прочие ханки — `okno_parse` и блоки под `[ -n "$OKNO_BASE" ]`; полный режим текстуально равен 64ac67b. |
| Б-3 И-5 судей: «коммита нет — rc 2», маркер | закрыта в мирах с `ustav/1` и с `frozen/*/1`; **снова открыта r8 в мире без тегов** (Б-5) | probe_okno.sh (ниже). Красное: df40823, мир ustav, база-несуществующий sha → charter rc 0, zones rc 0, marker 0; HEAD → rc 2/2, «ОТКАЗ 086: --okno: коммита нет»; база HEAD~2 → `окно 086: …..HEAD (2 коммит.)` ровно 1 строкой у обоих судей. |
| Б-4 А8 красна | **НЕ закрыта** | §3. |

probe_okno.sh (HEAD; три toy: без тегов / `ustav/1` / только `frozen/contracts/001/1`; в окне ROADMAP.md без строки):

```text
none check_charter --okno HEAD~2             rc=0 marker_lines=0 | …устав и замороженные контракты отсутствуют — в окне проверять нечего
none check_charter --okno <нет коммита>      rc=0 marker_lines=0 | …устав и замороженные контракты отсутствуют — в окне проверять нечего
none check_zones --okno HEAD~2               rc=0 marker_lines=1 | окно 086: b907f30a…..HEAD (2 коммит.)
none check_zones --okno <нет коммита>        rc=2 marker_lines=0 | ОТКАЗ 086: --okno: коммита нет: 0123…4567
ustav check_charter --okno HEAD~2            rc=1 marker_lines=1 | окно 086: … (2 коммит.)| FAIL … ROADMAP.md в 57748e7f
ustav check_charter --okno <нет коммита>     rc=2 marker_lines=0 | ОТКАЗ 086: --okno: коммита нет
ustav check_zones --okno HEAD~2              rc=0 marker_lines=1
ustav check_zones --okno <нет коммита>       rc=2 marker_lines=0 | ОТКАЗ 086: --okno: коммита нет
frozen check_charter --okno HEAD~2           rc=2 marker_lines=0 | NOT_IMPLEMENTED: устав не введён
frozen check_charter --okno <нет коммита>    rc=2 marker_lines=0 | NOT_IMPLEMENTED: устав не введён
frozen check_zones --okno HEAD~2             rc=0 marker_lines=1
frozen check_zones --okno <нет коммита>      rc=2 marker_lines=0 | ОТКАЗ 086: --okno: коммита нет
```

## 3. А8 — сырой вывод, своя мера

ПОСЛЕ = HEAD 2e23370, каждая команда строки отдельно:

| Команда А8 | ДО (контракт / круг 4 / своя мера @64ac67b) | ПОСЛЕ, своя мера |
|---|---|---|
| `verify_antiplacebo.sh --scope check_zones check_charter land_agent spawn_agent check_hooks` | rc 0, «барьеров: 5 · фикстур: 73 · предъявлено … 73» (своя мера, 90 с) | **rc 1**, «барьеров: 5 · фикстур: 73 · предъявлено красным повторным прогоном: 61 · расхождений: 12» (91 с) |
| `red_accept_task_commit.sh` | rc 0, 7/7 | rc 0, «прогнано 7, красных 0, зелёных 7» |
| `red_porjadok_diapazona_068.sh` | rc 0 | rc 0, «красных 0, зелёных 6, не построено 0» |
| `run_battery.sh accept_task_commit` | rc 0, 4/4 | rc 0, 4/4 |
| `run_battery.sh check_zones` | контракт: rc 1, 3/4; своя мера @64ac67b: rc 0, 4/4 (сдвиг union, не 086) | rc 0, 4/4 — равно ДО (+ stderr `profiles/check_zones.sh: line 156: 088: value too great for base`, Н-9) |

Расхождения verify_antiplacebo (дословно):

```text
FAIL check_charter/case_zloj_lend_bez_stroki_krasnyj.sh: барьер остался зелёным на обманном дереве — красное не предъявлено
FAIL land_agent/case_chuzoj_worktree.sh: барьер ответил «нечем проверить» (код 2) — …
FAIL land_agent/case_gryaznyj_main.sh … case_identity_rasscheplena … case_imja_podstroka_reestra … case_imja_vne_reestra
     … case_kommit_mimo_merge … case_merzh_ne_orkestrator … case_priyomka_bez_vetki … case_vetka_perezhila   (9× код 2)
FAIL spawn_agent/case_bez_identichnosti.sh: нет положительного контроля …          (форма П2 — разрешено арбитражем)
FAIL spawn_agent/case_octal_sdvig_znachenija.sh: нет положительного контроля …     (форма П2 — разрешено арбитражем)
```

Механизм land_agent: toy фикстуры — `frozen/contracts/900/1` без `ustav/1` (`work/repo`: `git tag` →
`frozen/contracts/900/1`); `case.out`: `окно 086: a9f3fd5e…..2ba901f2… (1 коммит.)` →
`NOT_IMPLEMENTED: устав не введён` → «main не сдвинут вызовом». Страж r8 по замыслу architect (§4.6 его анализа)
в мире «frozen без ustav» не срабатывает. r8 закрыл три accept-строки и не закрыл первую строку А8; его сообщение
перечисляет «А8 (ДО → ПОСЛЕ)» без неё. Вопрос круга 4 «реализация или текст А8» адресован арбитру/владельцу;
в `verdicts/arbitration/` по 086 — только круг 3; решение вынес architect (`/tmp/…/architect086b4/086-B4-analiz.md`
§0 «не развилка», в репо не закоммичено). Для `land_agent` и `case_zloj_lend` решения нет ни в каком виде.

## 4. Новые находки

**Б-5 (блок; И-5; fail-open стража r8, `scripts/check_charter.sh:384`).** Страж «нет ни `ustav/1`, ни
`refs/tags/frozen/*` → rc 0» стоит до проверки базы и маркера (`:418-425`), до `registry_state` (`:398`) и глотает
rc `for-each-ref` (`$(… 2>/dev/null)`):

```text
(а) probe_okno.sh, мир без тегов: check_charter --okno <нет коммита> → rc=0 marker=0      (И-5: rc 2 + маркер)
(б) probe_notags.sh, git clone --no-tags мира ustav с ROADMAP.md без строки в окне:
    r7   check_charter --okno → rc=2 NOT_IMPLEMENTED: устав не введён
    HEAD check_charter --okno → rc=0 «…отсутствуют — в окне проверять нечего»
    клон --no-tags мира frozen: check_zones --okno → rc=1 «реестр заморозок … недоступен: missing-remote»;
                                check_charter --okno → rc=0
(в) probe_fer.sh, мир frozen без ustav, PATH-spy for-each-ref → 127:
    spy=no  rc=2 NOT_IMPLEMENTED: устав не введён
    spy=yes rc=0 «…отсутствуют — в окне проверять нечего»
```

(б) опровергает «асимметрия с check_zones согласована» (55874d6): check_zones сверяет реестр до вывода «нечего
проверять». (в) — тот же класс «проглоченный rc → пустое множество → зелёное», который 70d6033 закрыл двумя
десятками строк ниже. Более простая форма, проходящая те же строки приёмки: страж после блока `cat-file`/маркера,
с условием `registry_state` ∈ {full, unknown-remote} для `ustav/` и `frozen/` и явным rc `for-each-ref`; toy А8 без
origin дают `full`, accept-строки остаются зелёными.

**Б-6 (блок; И-5 «без `--okno` побайтово прежнее»; ПЕРЕСЕЧЕНИЕ «check_charter.sh — 065 … 086 добавляет только режим
окна --okno»).** 70d6033 сделал фатальным общий `g rev-list "$since..HEAD"` (`:483-487`) в полном режиме и метит отказ
«--okno». probe_spy.sh (spy `rev-list …..HEAD` → 127, без `--okno`, мир ustav с ROADMAP.md без строки):

```text
pre086  spy=no  rc=1 | FAIL … ROADMAP.md в 57748e7f | уставных документов: 2 · изменений в них: 1
pre086  spy=yes rc=0 | уставных документов: 2 · изменений в них: 0 · с разрешения: 0
HEAD    spy=no  rc=1 | FAIL … ROADMAP.md в 57748e7f | уставных документов: 2 · изменений в них: 1
HEAD    spy=yes rc=2 | ОТКАЗ 086: --okno: rev-list отказал (rc=127, since=ustav/1) — нечем проверить
```

Закрытие fail-open полного режима — предмет 065 и его санкции; внутри 086 — молчаливая правка прежней ветви (тот же
класс, что Б-2 круга 4). Простая форма: rc-проверка под `[ -n "$OKNO_BASE" ]`, полный режим — прежнее `|| : >`.

## 5. Область правки, identity, атомарность, норма

- 70d6033: `scripts/check_charter.sh`, `scripts/check_zones.sh`; 55874d6: `scripts/check_charter.sh` — в ЗОНА
  implementer. Ленды `70871be` (`--stat` = те же 2 файла, +78/−5), `42e7d7c` (1 файл, +15; дерево файла равно
  55874d6). architect после df40823 в зоны 086 не коммитил (`git log df408239..HEAD -- <зоны 086>` → только 70d6033,
  55874d6).
- Identity: `git log frozen/contracts/086/1..HEAD --no-merges -- <зоны 086>`: 086-коммиты — `implementer|implementer`
  (c3bbb48, 7ca53be, 70d6033, 55874d6, 0470895) и `architect|architect` (bb0d6a4, 8d6fa6c, 51ca9eb); ленды —
  `orchestrator`. Job-имена `implementer-incr`/`implementer-incr2` — коммиты 083 (b58907f, e6c338e, d4527e4, 9cd64a5),
  к 086 не относятся.
- Атомарность: 70d6033 несёт три находки (Б адверсария, Б-2, Б-3) и отказ по Б-1 — одна задача «круг 7 по 086»,
  прецедент c3bbb48 круга 4; не отказ.
- Норма: `git diff --quiet frozen/contracts/086/1 HEAD -- contracts/086-*` → rc 0; нормативные документы r7/r8 не
  трогали. Проверки не переписаны автором реализации (implementer в `fixtures/` не коммитил).
- Заявленное ≠ сделанное (п. 7): 70d6033 — «c3bbb48^ уже несёт пары» (ложно, Б-1); 55874d6 — «А8 ДО→ПОСЛЕ» без
  красной строки verify_antiplacebo и «асимметрия согласована» (ложно, Б-5б); HANDOFF 2e23370 — «находки ВСЕ закрыты
  round7/round8, живьём подтверждено» (ложно, Н-8).

## 6. ПРОВОДКА (контракт 038)

`guard=fixtures/_krasnye_086.sh` существует и является барьером этого предмета (зовёт семью
`fixtures/gejty_svedenija_086/` и профиль `gejt_svedenija`). Канал не подключён: `scripts/check_provodka.sh .
contracts/086-…` → rc 1 «guard не подключён: fixtures/_krasnye_086.sh не вызывается в .githooks/ или
.github/workflows/». ПРОВОДКА-ЭНФОРСМЕНТ честно обосновывает чистый энфорсмент (норм-строк ролей нет), подключение —
оркестратору после ленда 083. П-1 открыт, блокирует done.

## 7. Паразитная сложность (контракт 050) — артефакты круга 5

| Артефакт | (1) свойство | (2) состояние | (3) файлов на правку свойства | (4) глубина | (5) потребитель / повтор | Класс |
|---|---|---|---|---|---|---|
| страж «устава нет» в `--okno` (`check_charter.sh:384`, +15) | А8 (accept-строки на toy без устава) | `incr_finish 0` — сброс incr-кеша побочно, в выводе не виден | 1 | без новых флагов; новая ветвь rc 0 | А8 accept-строки; повторяет «нечего проверять» check_zones, но без сверки реестра | ESSENTIAL по (1); форма дефектна — Б-5 |
| `cat-file -e` + маркер в обоих судьях (+9 строк ×2) | И-5 | нет | 2 (две копии) — выросло | без новых флагов | И-5; копия — продолжение совета Н-5 круга 4 (общий дом вне зон) | ESSENTIAL (+совет) |
| rc-проверки `rev-list`/`grep -Fxf` в `--okno` | И-5, Frontier 7 «нечем проверить» | нет | 1 на судью | без новых флагов | Б адверсария круга 4 | ESSENTIAL |
| rc-проверка общего `rev-list "$since..HEAD"` (`:483-487`) | свойства 086 нет (полный режим — 065) | нет | 1 | — | потребителя в строках 086 нет | **ACCIDENTAL, блок Б-6**: фрагмент `:483-487`; потерянное свойство И-5; простая форма — под `[ -n "$OKNO_BASE" ]` |
| возврат строки `authors … continue` | И-5 | — | — | — | — | снимает ACCIDENTAL круга 4 |

## 8. Что дальше

Б-1 — второй отказ по той же причине: созывается арбитр (роль reviewer не решает спор, где стала стороной).
Б-4 — к арбитру/владельцу, как в круге 4: land_agent ×9 и `case_zloj_lend` красны; решение architect арбитражем не
является и в репо не записано. Б-5, Б-6 — implementer (зона implementer, предмет не запушен). Н-6 — architect.
Н-7..Н-9, П-1 — оркестратор. Этот вердикт относится только к блобам на 2e23370.
