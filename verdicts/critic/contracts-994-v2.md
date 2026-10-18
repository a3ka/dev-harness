FAIL

# Критик — контракт 994, круг 2

OBJECT=d788a59fef78ed53ff63861ca6a22f4965057d0c (ветка `wip/994/architect`)
Предмет: `contracts/994-provodka-vneshnij-ci-guard.md` + `fixtures/check_provodka/external_ci_994/`.
Клон: `/tmp/dev-harness-verify/critic994r2/repo`, ssh-клон, checkout OBJECT. Мутанты и свидетели лежат в `/tmp/dev-harness-verify/critic994r2/mut/`. Основной чекаут не трогался.
Круг 1: `1f8da8879:verdicts/critic/contracts-994-v1.md` (FAIL, Б1 и Б2, советы С1–С8).

АРБИТР: arbiter (roles/arbiter.md). Созываю сам: второй `FAIL` по той же причине, что Б1 круга 1. Предмет спора: может ли конечная выборка клеток доказать инвариант закрытого класса. Это инвариант 3 «разбиение ТОЛЬКО по `.` и `;`» и инвариант 2 «терминатор — ЛЮБАЯ строка с первым символом `#` либо с префиксом ```` ``` ````». Вторая позиция: батарея обязана покрывать класс целиком, генератором или дополнением. Автор закрыл Б1 ровно тем перечнем, который назвал я сам (`,` `!` `?` `:` `—`). Мутант с разделителем ВНЕ перечня по-прежнему зелен на 73/73, так что дефект остался на уровне класса. Это инженерный вопрос, не воля владельца.

## Закрытие круга 1 (живьём, в клоне на OBJECT)

| команда | rc | наблюдение |
|---|---|---|
| `probe.sh --cases` (пред-предметный субъект) | 1 | `CASES executed=73 mismatches=13`: EXTERNAL_991/993, WRAPPED_991/993, BLANK_BEFORE_PARAGRAPH, ROLE_/CHARTER_BEFORE_PARAGRAPH, EXTERNAL_THEN_BAD_ROLE/CHARTER, SHARED_PARAGRAPH, SECOND_GUARD_LOCAL, SECOND_GUARD_OWN, RENAMED_EXTERNAL. Совпадает с `:40` |
| `probe.sh --cases --subject /tmp/dev-harness-verify/critic994r1/mut/mutant.sh` (мутант Б1 круга 1, `[.;,!?]`) | **1** | `CASES executed=73 mismatches=12`: 991/993 × NEGATED/SUFFIX × COMMA/EXCLAMATION/QUESTION, у всех actual 0, expected 1. **Б1 круга 1 закрыт на названном мутанте** |
| `probe.sh --matrix` | 0 | honest valid=1; unchanged, substring, wide-delimiter (6 свидетелей), unicode-space, exit-after-grant, whole-file, later-paragraph, shared-global, missing-file — все valid=1; planned-wiring REGISTRY_ONLY 0 / WITHOUT_OWN_STEP 1 |
| `probe.sh --legacy` | 0 | `LEGACY executed=18 mismatches=0` |
| `probe.sh --self-wiring` | 1 | `SELF_WIRING MISSING_REAL_STEP []`: шага ещё нет, до реализации так и ожидается |
| `check_threat_model.sh "$PWD" contracts/994-…md` | **0** | `модель угроз: секция валидна (ЗАЩИЩАЕТ 1 буллет(ов), НЕ ЗАЩИЩАЕТ 2 буллет(ов))`. **Б2 круга 1 закрыт** |
| `check_precision_gate.sh "$PWD" contracts/994-…md` | 0 | `OK` (семья provodka, задача (б) пропущена по прецеденту 036 В4-3) |
| `verify_antiplacebo.sh --scope check_provodka` | 0 | `барьеров: 1 · фикстур: 28 · предъявлено красным повторным прогоном: 28` |
| `check_provodka.sh "$PWD" contracts/994-…md` | 0 | уже до реализации; теперь честно раскрыто на `:46` и `:56` (С1 закрыт) |
| `check_provodka.sh "$PWD" contracts/991-…md` / `993-…md` | 1 / 1 | `guard не подключён: fixtures/workshop_project/{rehearsal_991,validator_993}/probe.py` (Н-303 воспроизводится) |
| `sha256sum baseline_038.sh` против `git show {a3c8cb976,d125f4bab,origin/main}:scripts/check_provodka.sh` | — | все четыре дают `20db5210…04a3`, совпадает с константой в `probe.py`. С2 закрыт |

Советы круга 1 тоже закрыты. С3: клетки NBSP/EN_SPACE и мутант `unicode-space`. С4: клетки ROLE_/CHARTER_BEFORE_PARAGRAPH, BLANK_BEFORE_PARAGRAPH, NO_FOLLOWING_PARAGRAPH. С5: EXTERNAL_THEN_BAD_ROLE/CHARTER и мутант `exit-after-grant`. С6: литеральные команды на `:47`. С7: `:40`.

## Блокирующие находки

БЛОКИРУЕТ contracts/994-provodka-vneshnij-ci-guard.md:21,24,42 — повтор причины Б1 круга 1. Инвариант 3 закрывает разбиение множеством ровно из двух символов («по литеральным `.` и `;`»), а `:42` обещает rc 1 на «отрицание или приписку через пунктуацию кроме `.`/`;`». Клетки проверяют пять конкретных символов (`probe.py` `cases()`: `,` `!` `?` `:` `—`). Реализация, у которой к `.;` добавлены только символы вне этих пяти, зелена на всей батарее. Сюда входят en dash U+2013 (одна из двух типографских форм «тире», которое я назвал в круге 1), ASCII-тире ` - `, многоточие U+2026 и скобки.
ОБХОД: `/tmp/dev-harness-verify/critic994r2/mut/m_dash.py` — тот же код, что honest-ветка `models.py`; изменена одна строка, `separators = r"[.;–…()]|\s-\s"`. Прогон `probe.sh --cases --subject …/mut_dash.sh` даёт **`CASES executed=73 mismatches=0`, rc 0**. На естественной прозе `ПРОВОДКА-ЭНФОРСМЕНТ: Неверно – не добавлять в CI dev-harness зависимость от чужого checkout/SDK. Guard локальный и обязан быть в CI.` мутант даёт **rc 0** (wiring снят). Честная модель и baseline дают **rc 1** `проводка: guard не подключён: scripts/check_remote_994.sh …`. То же расхождение на ` - `, `…` и `(…)`: `witness2.py`, сырой вывод ниже. `--legacy`, `--self-wiring` и 991/993 этот мутант не затрагивают, `--matrix` production-субъект не исполняет.
Как закрыть (на усмотрение автора): класс, а не новый перечень. Например, один режим, который для КАЖДОГО символа Unicode-категорий P\*/S\* (BMP, без `.` и `;`) строит клетки `Неверно<c> <фраза>.` и `<фраза><c> Guard локальный.` с ожиданием rc 1. Порядок — ~800 символов Pd/Ps/Pe/Pi/Pf/Po × 2 формы × 2 фразы ≈ 3200 вызовов по ≈16 мс (замер: 73 клетки за 1.2 с), то есть около минуты. Добавить мутант `m_dash` в `--matrix` с назначенным свидетелем.

БЛОКИРУЕТ contracts/994-provodka-vneshnij-ci-guard.md:20,42,52 — новая находка, класс терминаторов. Инвариант 2 определяет терминатор как «строка с первым символом `#` либо префиксом из трёх обратных кавычек». `:42` обещает rc 1 на «текст за каждым терминатором», `:52` ЗАЩИЩАЕТ «от … тексту за терминатором». Клетки AFTER_HEADING / AFTER_HEADING_CONTINUATION / SECOND_FIELD / AFTER_FENCE / AFTER_FENCE_CONTINUATION используют только `## Другой раздел` (`#` с пробелом) и голую строку ```` ``` ````. Реализация, которая распознаёт более узкий класс терминаторов абзаца (markdown-заголовок `^#+( |$)` либо fence только как строку, равную ```` ``` ````), зелена на всей батарее.
ОБХОД: `/tmp/dev-harness-verify/critic994r2/mut/m_heading.py`: в честной модели граница поля `startswith(("#", "```"))` заменена на `re.match(r"#+( |$)") or startswith("```")`. `m_fence.py` аналогично меняет fence-терминатор на `strip() == "```"`. Оба дают на `probe.sh --cases --subject …` **`CASES executed=73 mismatches=0`, rc 0**. Свидетель для заголовка: тело поля `- guard=…` / `ПРОВОДКА-ЭНФОРСМЕНТ: Локальная проверка, обязана быть в CI.` / `#заметка.` / `Общий CI dev-harness не получает зависимость от внешнего checkout`. Мутант даёт **rc 0**, honest и baseline — **rc 1** `guard не подключён`. Тот же результат для ```` ```text; ```` (`witness.py`). Текст за терминатором снимает wiring, то есть ровно то, что обещает защищать `:52`.
Как закрыть (на усмотрение автора): клетки-продолжения с терминаторами `#x.` (без пробела), `#.` и ```` ```text; ```` (fence с языковым тегом), с ожиданием rc 1. Мутанты `m_heading` и `m_fence` добавить в `--matrix`.

## Советы (accept не отменяют, автор закрывает по усмотрению)

СОВЕТ contracts/994-provodka-vneshnij-ci-guard.md:21 — «каждый фрагмент обрезается по краям» не говорит, каким множеством. Честная модель режет `strip(" ")`. Мутант `m_strip.py` (`part.strip()`, то есть Unicode-пробелы на краю фрагмента) даёт `CASES executed=73 mismatches=0`. Смысловой утечки нет (NBSP на краю — та же оговорка), поэтому это совет: стоит либо назвать множество, либо добавить клетку `Внешняя;\u00a0<фраза>.`.

СОВЕТ fixtures/check_provodka/external_ci_994/probe.py (`matrix()`, мутант `wide-delimiter`) — у клеток COLON и DASH нет свидетеля среди мутантов: `wide-delimiter` режет только `[.;,!?]`. Сами клетки есть и краснят такой мутант. Измерено: `m_colondash.py` (`[.;:—]`) даёт `CASES executed=73 mismatches=9`, rc 1 (991/993 × NEGATED/SUFFIX × COLON/DASH и QUOTED_MARKER). Свидетель в матрице сделал бы это постоянным.

СОВЕТ contracts/994-provodka-vneshnij-ci-guard.md:20 — «первой пустой/пробельной строки» не сказано, какие пробелы. Bash-грамматика (`check_provodka.sh:223`, `[[:space:]]`) и Python `.strip()` модели могут по-разному решить, пуста ли строка из одного NBSP. Стоит назвать ASCII-множество так же, как в `:21`.

СОВЕТ 8 круга 1 (копирование точной фразы в чужой контракт) остаётся принятым остаточным риском `:55`. Это не находка.

## Сырой вывод

```
$ bash fixtures/check_provodka/external_ci_994/probe.sh --cases --subject /tmp/dev-harness-verify/critic994r1/mut/mutant.sh   (фильтр matched:false)
991_NEGATED_COMMA/_SUFFIX_COMMA/_NEGATED_EXCLAMATION/_SUFFIX_EXCLAMATION/_NEGATED_QUESTION/_SUFFIX_QUESTION actual 0 expected 1
993_… те же шесть actual 0 expected 1
CASES executed=73 mismatches=12
rc=1

$ python3 run_mut.py heading fence dash        (probe.sh --cases --subject mut_<m>.sh)
  heading: CASES executed=73 mismatches=0
heading rc=0
  fence: CASES executed=73 mismatches=0
fence rc=0
  dash: CASES executed=73 mismatches=0
dash rc=0
$ python3 run_mut.py strip
  strip: CASES executed=73 mismatches=0
strip rc=0

$ python3 witness.py
heading  baseline rc=1 проводка: guard не подключён: scripts/check_remote_994.sh не вызывается в .githooks/ или .github/workflows/
heading  honest   rc=1 проводка: guard не подключён: scripts/check_remote_994.sh не вызывается в .githooks/ или .github/workflows/
heading  mutant   rc=0
fence    baseline rc=1 проводка: guard не подключён: scripts/check_remote_994.sh не вызывается в .githooks/ или .github/workflows/
fence    honest   rc=1 проводка: guard не подключён: scripts/check_remote_994.sh не вызывается в .githooks/ или .github/workflows/
fence    mutant   rc=0

$ python3 witness2.py
en-dash        baseline rc=1 проводка: guard не подключён: scripts/check_remote_994.sh не
en-dash        honest   rc=1 проводка: guard не подключён: scripts/check_remote_994.sh не
en-dash        mutant   rc=0
spaced-hyphen  baseline rc=1 / honest rc=1 / mutant rc=0
ellipsis       baseline rc=1 / honest rc=1 / mutant rc=0
parens         baseline rc=1 / honest rc=1 / mutant rc=0

$ bash fixtures/check_provodka/external_ci_994/probe.sh --matrix
MODEL honest observed=0 valid=1
MODEL unchanged observed=2 valid=1
MODEL substring observed=2 valid=1
MODEL wide-delimiter observed=6 valid=1
MODEL unicode-space observed=2 valid=1
MODEL exit-after-grant observed=2 valid=1
MODEL whole-file observed=3 valid=1
MODEL later-paragraph observed=1 valid=1
MODEL shared-global observed=2 valid=1
MODEL missing-file observed=1 valid=1
SELF REGISTRY_ONLY actual 0 expected 0 matched true
SELF WITHOUT_OWN_STEP actual 1 expected 1 matched true
rc=0

$ bash scripts/check_threat_model.sh "$PWD" contracts/994-provodka-vneshnij-ci-guard.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 1 буллет(ов), НЕ ЗАЩИЩАЕТ 2 буллет(ов))
rc=0
```
