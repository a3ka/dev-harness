accept
OBJECT=a066baa574c91c5cc946195dd544980fb78e7d00

# Критик, круг 3 — контракт 994 (Н-303), закрытый предмет

МОДЕЛЬ: anthropic/claude-opus-5-5 (Critic994R3), 2026-10-18.
Предмет круга задан решением арбитра `735ed50ea:verdicts/arbitration/contracts-994-closed-class-v1.md`, Решение 3: (1) сверка П1–П6; (2) команды приёмки `:38–47` с прежними rc. Блокирует только неисполненный пункт П1–П6 либо новый обход с названным мутантом внутри закрытых границ решения.
Клон: `/tmp/dev-harness-verify/critic994r3/repo`, ssh-клон `ssh://git@github.com/a3ka/dev-harness.git`, `git checkout a066baa5`. `origin/wip/994/architect` содержит HEAD. Автор коммита — `architect <architect@dev-harness.local>`. Diff `d788a59f..a066baa5` затрагивает 3 файла: контракт, `models.py`, `probe.py`, всё в ЗОНА architect (`:62`).

## Блокирующие находки

Нет. Все пункты П1–П6 исполнены. Внутри закрытых границ нового обхода, который проходит батарею, я не нашёл. Мутант, который мне удалось построить, разобран ниже как СОВЕТ С1 вместе с причиной, почему он не блокирует.

## Сверка П1–П6

| П | где | что я проверил | итог |
|---|---|---|---|
| П1 | `contracts/994-provodka-vneshnij-ci-guard.md:42`, `fixtures/check_provodka/external_ci_994/probe.py:93-94` | Текст: «отрицание или приписка через `,` `!` `?` `:` `—` — закрытый перечень клеток `*_NEGATED_*`/`*_SUFFIX_*`». Кортеж `cases()` тот же: `,` `!` `?` `:` `—`. Байты сверены: в тексте и в кортеже стоит один символ, U+2014 (`\xe2\x80\x94`). Фраза про открытое дополнение («кроме `.`/`;`») удалена | исполнен |
| П2 | `:24` | «Множество разделителей — ровно два литерала одним production-примитивом. Что иной символ или последовательность тело не делит, держит построение и проверяет reviewer чтением этого примитива в diff. Батарея измеряет закрытый перечень пунктуации в приёмочном критерии, не дополнение». Вместо ссылки `:42` стоит её описание, смысл тот же | исполнен |
| П3 | `:57` | Новый буллет НЕ ЗАЩИЩАЕТ: U+2013, U+2026, скобки, ` - `; «Батарея — выборка, не класс»; ссылка на `verdicts/arbitration/contracts-994-closed-class-v1.md`. ЗАЩИЩАЕТ `:52` не менялся | исполнен |
| П4(а) | `:20` | Дописано дословно: «одна грамматика с циклом поля check_provodka: … `#` (включая `#x` без пробела) … префикс ``` (включая fence с языковым тегом). Вторая грамматика границы не вводится». Сверено с production: `scripts/check_provodka.sh:228-229` (`"#"*) break`, ``` \`\`\`*) break ```), локаль `C.UTF-8` (`:125`) | исполнен |
| П4(б) | `probe.py:74-75` | `AFTER_HASH_NO_SPACE_CONTINUATION` = `Локальная проверка;\n#заметка.\n<P993>` и `AFTER_FENCE_LANGUAGE_CONTINUATION` = `Локальная проверка;\n```text;\n<P993>`. В обеих rc 1 и `refusal()` по умолчанию `add()`. Формы совпадают с предписанием арбитра байт в байт | исполнен |
| П4(в) | `models.py:43-48`, `probe.py:202-203` | Режим `heading-space` = `re.match(r"#+( \|$)")` — предикат `m_heading`. Режим `bare-fence` = `line.strip() == "```"` — предикат `m_fence`. Каждый свидетель — своя новая клетка. На живом `--matrix` у обоих режимов `observed=1 valid=1` | исполнен |
| П5 | `:21`, `:42`, `probe.py:79` | Выбрана форма (а): «каждый фрагмент обрезается по краям ASCII-пробелом». Добавлена клетка `FRAGMENT_EDGE_NBSP` = `Внешняя;\u00a0<P991>.` → rc 1. В `:42` добавлено «или NBSP на краю фрагмента». Честная модель (`strip(" ")`) на этой клетке даёт rc 1, `m_strip` даёт rc 0 и краснеет | исполнен |
| П6 | транскрипт `history://Architect994Fix3` | Architect живьём прогнал `--cases`, `--matrix`, `--cases --subject` на `mut_heading`, `mut_fence`, `mut_dash`, а также `--legacy`, `--self-wiring`, `verify_antiplacebo --scope`, pre_critic и threat_model; результаты переданы в yield Main. Я всё воспроизвёл сам, сырой вывод ниже | исполнен |

## Приёмка `:38–47` — прежние rc, живой прогон в клоне

Субъект — пред-предметный `scripts/check_provodka.sh` на OBJECT.

```
== --cases rc=1
CASES executed=76 mismatches=13
== --legacy rc=0
LEGACY executed=18 mismatches=0
== --self-wiring rc=1
SELF_WIRING MISSING_REAL_STEP []
== --matrix rc=0
CASES executed=76 mismatches=0
MODEL honest observed=0 valid=1
MODEL unchanged observed=2 valid=1
MODEL substring observed=2 valid=1
MODEL wide-delimiter observed=6 valid=1
MODEL unicode-space observed=2 valid=1
MODEL heading-space observed=1 valid=1
MODEL bare-fence observed=1 valid=1
MODEL exit-after-grant observed=2 valid=1
MODEL whole-file observed=3 valid=1
MODEL later-paragraph observed=1 valid=1
MODEL shared-global observed=2 valid=1
MODEL missing-file observed=1 valid=1
SELF {"name": "REGISTRY_ONLY", "actual": 0, "expected": 0, "matched": true, "output": ""}
SELF {"name": "WITHOUT_OWN_STEP", "actual": 1, "expected": 1, "matched": true, ...}
```

`--cases` rc 1, 13 расхождений. Красные клетки: EXTERNAL_991/993, WRAPPED_991/993, BLANK_BEFORE_PARAGRAPH, ROLE_/CHARTER_BEFORE_PARAGRAPH, EXTERNAL_THEN_BAD_ROLE/CHARTER, SHARED_PARAGRAPH, SECOND_GUARD_LOCAL, SECOND_GUARD_OWN, RENAMED_EXTERNAL. Состав совпадает с `:40`. Три новые клетки на пред-предметном субъекте совпадают с ожиданием, то есть ложного красного нет:
```
AFTER_HASH_NO_SPACE_CONTINUATION 1 1 True
AFTER_FENCE_LANGUAGE_CONTINUATION 1 1 True
FRAGMENT_EDGE_NBSP 1 1 True
```
`--self-wiring` rc 1 (`MISSING_REAL_STEP`) — ожидаемое состояние до реализации: строку реестра добавляет implementer (`:26-30`, ЗОНА implementer). Это то же rc, что в прошлых кругах.

`--cases --subject` на мутантах; источники только читались:
```
critic994r2/mut/mut_heading.sh   rc=1  CASES executed=76 mismatches=1  AFTER_HASH_NO_SPACE_CONTINUATION actual=0 expected=1
critic994r2/mut/mut_fence.sh     rc=1  CASES executed=76 mismatches=1  AFTER_FENCE_LANGUAGE_CONTINUATION actual=0 expected=1
critic994r2/mut/mut_dash.sh      rc=0  CASES executed=76 mismatches=0   (записанный остаток П3)
critic994r2/mut/mut_strip.sh     rc=1  CASES executed=76 mismatches=1  FRAGMENT_EDGE_NBSP actual=0 expected=1
critic994r2/mut/mut_colondash.sh rc=1  CASES executed=76 mismatches=9  (QUOTED_MARKER, 99[13]_{NEGATED,SUFFIX}_{COLON,DASH})
arbiter994/mut/subj_honest.sh    rc=0  CASES executed=76 mismatches=0
arbiter994/mut/subj_spaced.sh    rc=0  CASES executed=76 mismatches=0   (остаток П3, ` - `)
arbiter994/mut/subj_heading.sh   rc=1  mismatches=1  AFTER_HASH_NO_SPACE_CONTINUATION
arbiter994/mut/subj_fence.sh     rc=1  mismatches=1  AFTER_FENCE_LANGUAGE_CONTINUATION
critic994r3/mut/subj_honest_obj.sh (models.py с OBJECT, honest) rc=0  CASES executed=76 mismatches=0
```
`m_heading` и `m_fence` краснеют каждый ровно на своей новой клетке. `m_dash` и `m_spaced` зелены — это остаток, принятый арбитражем, и его наблюдаемость честная.

Гейты:
```
bash scripts/check_threat_model.sh "$PWD" contracts/994-provodka-vneshnij-ci-guard.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 1 буллет(ов), НЕ ЗАЩИЩАЕТ 3 буллет(ов))      rc=0
bash scripts/check_precision_gate.sh "$PWD" contracts/994-provodka-vneshnij-ci-guard.md
precision-гейт 043: семья provodka — барьер правится этим же черновиком, задача (б) для неё пропущена (прецедент 036 В4-3)
OK                                                                                 rc=0
bash scripts/pre_critic.sh contracts/994-provodka-vneshnij-ci-guard.md
КРИТИК: дверь зелёная                                                              rc=0
bash scripts/verify_antiplacebo.sh --scope check_provodka
барьеров: 1 · фикстур: 28 · предъявлено красным повторным прогоном: 28             rc=0
bash scripts/check_no_leak.sh --check /home/harness/dev-harness   (из основного чекаута, только чтение)
основной чекаут чист                                                               rc=0
```

## Советы (НЕ блокируют, автор закрывает по усмотрению)

СОВЕТ С1 `fixtures/check_provodka/external_ci_994/probe.py:74`, `contracts/994-provodka-vneshnij-ci-guard.md:20` — в тексте `:20` стоит литерал «`#x` без пробела», а клетка проверяет `#заметка` (кириллица). Я построил мутант `critic994r3/mut/m_ascii_hash.py` (sha256 `a77b808b…`): терминатор `re.match(r"#(?![A-Za-z])")`, то есть `#`, за которым идёт ASCII-буква, не считается терминатором. Он проходит батарею: `subj_ascii_hash.sh rc=0 CASES executed=76 mismatches=0`. Почему это не блокер:
- что угодно, кроме пробела, после `#` — открытое множество символов. Это тот же тип дополнения, что у разделителей, и арбитр закрыл его построением: П4(а) «одна грамматика с циклом поля», «вторая грамматика границы не вводится», reviewer читает diff;
- клетки П4(б) заданы арбитром точно, и правило «пункты, решённые здесь, не переоткрываются» запрещает их переоспаривать;
- мутант искусственный. Реалистичный «hashtag»-вариант `'#'[[:alpha:]]*` в production-локали `C.UTF-8` (`scripts/check_provodka.sh:125`) захватывает и кириллицу, поэтому его ловит `#заметка.`.

Что можно сделать за одну клетку: `#x.` с ASCII-буквой, чтобы литерал `:20` был измерен буквально.

СОВЕТ С2 — совет С1 арбитра (клетки U+2013/U+2026) не исполнен. Это допустимо: арбитр назвал его советом, а не условием.

СОВЕТ С3 (операционный, для судей) — `probe.sh` пишет деревья в `<клон>/tmp/provodka-994-*`. Если параллельно запустить `verify_antiplacebo.sh --scope check_provodka` в том же клоне, тот видит чужие файлы и отказывает. Мой первый прогон дал `FAIL дерево изменилось вне $WORK — файлы: ./tmp/provodka-994-…`. Отдельный повторный прогон дал rc 0. Это моя интерференция, а не дефект предмета. Пробы и antiplacebo нужно гонять в одном клоне последовательно.

## Артефакты

`/tmp/dev-harness-verify/critic994r3/`:
- `repo/` — ssh-клон на OBJECT, не изменён; `tmp/` создала проба;
- `logs/` — сырые логи `cases`, `legacy`, `self-wiring`, `matrix`, `subj_*`;
- `mut/` — `baseline.sh` (sha256 `20db5210…04a3`, сверено), `m_honest_obj.py` (копия `models.py` с OBJECT), `m_ascii_hash.py` (мутант С1), обёртки `subj_*.sh`;
- `run.sh` — одноразовый прогонщик.

Основной чекаут не тронут, push не делался. Вердикт не закоммичен (запрет Н-85 в брифе). Коммит в `verdicts/critic/contracts-994-v3.md` под `user.name=critic` делает вызвавшая сторона.
