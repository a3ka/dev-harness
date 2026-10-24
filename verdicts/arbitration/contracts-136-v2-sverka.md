accept
OBJECT=56e0f1dcd45e04fa89061b3782b526f8c5b2a364

# Сверка 136 v2-достройки по закрытому перечню арбитража (вариант Б владельца 2026-10-24 18:55 UTC)

Дата: 2026-10-24. Роль: arbiter (Arbiter136b), модель anthropic/claude-fable-5-1. Автор конструкции (Architect136v2) — GLM; критики r1/r2 — openai-codex/gpt-6-astra. Совпадения модели арбитра с автором нет (разные семейства). Предмет — ветка `wip/136/architect-v2` @ OBJECT (один коммит поверх 59ba025a, `%an = architect`).

Перечень — ЗАКРЫТЫЙ: п. 3(а) и таблица осей A–D п. 1 моего же вердикта `/tmp/dev-harness-verify/orch/keep136v2/arbitration-136v2.md`. Нового поиска мутантов и нового круга критика нет; всё, что вне перечня, — только советом.

Записано только в `/tmp/dev-harness-verify/Arbiter136b/`: копия клона `repo/` (cp -r со своим .git, HEAD = OBJECT, статус чист), `scratch/` (копии раннеров и логи), этот файл. Основной чекаут, чужие каталоги, origin — не тронуты; push не выполняется.

## Инструмент замера

- `scratch/arb_run_136.sh` — копия `fixtures/workshop_project/sessii_136/red_sessii_136.sh` @ OBJECT; дельта к оригиналу ТОЛЬКО: корни миров `/tmp/dev-harness-verify/sessii-136-*` → `…/Arbiter136b/scratch/tmp/dev-harness-verify/sessii-136-*`, fakehome `/tmp/dev-harness-fakehome-136/` → `…/Arbiter136b/scratch/fh136/` (ВНЕ scratch-allowlist — контроль a7 честный), `B=` абсолютный путь на копию клона, строка `DOOR="${ARB_DOOR:-$DOOR}"; PAR="${ARB_PAR:-$PAR}"` после определения PAR (подстановка субъекта). Та же схема, что в арбитраже 136v2 (`Arbiter136/scratch/arb_run_136.sh`, diff сверен). Клетки, оракулы, `source.json`, модели, стабы не менялись.
- `scratch/arb_run_136_impl.sh` — то же + `MKT="${ARB_MKT:-$MKT}"` (нужен только для п. (vi): у 3cee078b все три скрипта).
- `scratch/arb_run_125.sh` — копия `sessii_125/red_sessii_125.sh` с `WORLDS=` и `BATT=` на мой каталог (иначе батарея пишет в общий `/tmp/dev-harness-verify/s125`).
- `scratch/run_mutants.sh`, `scratch/run_impl3cee.sh` — циклы прогона с логами в `scratch/logs/`.
- Мутанты — файлы критиков как есть: `Critic136v2/mutants/m01–m12` (побайтово равны копиям в `Critic136v2b/mutants/`, cmp по всем 12), `Critic136v2b/mutants/n01–n07`.

## Замеры (сырой вывод)

```
$ env TMPDIR=…/scratch/tmp bash scratch/arb_run_136.sh --model
sessii_136: клеток 69, зелёных 69, красных 0
rc=0   (real 0m25.5s)

$ env TMPDIR=…/scratch/tmp bash scratch/arb_run_136.sh --stabs
sessii_136 --stabs: стабов 37, привязок 54, непойманных 0
rc=0   (real 0m32.2s)

$ jq '(.kletki|keys|length), (.osi|length), (.vne_osi|length), ([.stab_vhod[]|length]|add), (.stab_vhod|length)' source.json ; ls stabs | wc -l
69 55 14 54 37 ; 37
$ jq -c '([.osi[].kletka] + .vne_osi | sort) == (.kletki | keys | sort)' source.json
true
$ jq -r '.osi[].os' source.json | sort | uniq -c
37 A ; 3 B ; 4 C ; 11 D
$ jq -r '.osi[] | select(.os=="A") | .sostojanie' | sort | uniq -c
17 NEXT_TASK непуст ; 17 task-file ; 2 бриф (NEXT_TASK отсутствует) ; 1 бриф (NEXT_TASK пуст)

$ cmp stabs/s3N/… Critic136v2b/mutants/n0K/…   (все шесть — IDENT, cmp молчит)
s31-dver-brief-s-kornem == n01-brief-extra-root
s32-dver-taskfile-bez-orakula == n02-taskfile-skip-oracle
s33-dver-nulevoj-strazh-svoj == n03-empty-guard-fallback
s34-parity-proverjaet-standart == n04-check-wrong-layer
s35-parity-vlozhennoe-harness == n05-nested-layer-harness
s36-dver-pustoj-next-vybran == n07-empty-next-selected
$ diff model/connect_project.sh stabs/s37-dver-jq-molcha/connect_project.sh
101c101  < …printf 'connect ОТКАЗ: trassa-net-konfiga…' >&2; exit 1; }   > || :
$ jq -c '.stab_vhod | to_entries[] | select(.key|test("^s3[1-7]"))'
s31→[a47-brief-struktura]  s32→[a49-cr-para-v-taskfile]  s33→[a50-strazh-nulevoj-fajl]
s34→[d9-sloi-drugoe-imja-poterjan]  s35→[d10-sloi-vlozhennoe-imja, d11-sloi-vlozhennoe-poterjan]
s36→[a48-pustoj-next-brief]  s37→[b5-jq-net-possev]

$ bash scratch/run_mutants.sh Critic136v2/mutants m01…m12      (real 3m55s)
m01-noroot               rc=2 | клеток 69, зелёных 63, красных 6 | a25 a26 a28 a29 a47 a48
m02-root-in-msg          rc=2 | 63/6 | a25 a26 a28 a29 a47 a48
m03-root-after-separator rc=2 | 63/6 | a25 a26 a28 a29 a47 a48
m04-foreign-root         rc=2 | 63/6 | a25 a26 a28 a29 a47 a48
m05-duplicate-root       rc=2 | 63/6 | a25 a26 a28 a29 a47 a48
m06-taskfile-noroot      rc=2 | 68/1 | a28
m07-no-final-oracle      rc=2 | 66/3 | a30 a49 a50
m08-node-fallback        rc=2 | 68/1 | a31
m09-exact-layer-only     rc=2 | 65/4 | d6 d9 d10 d11
m10-parity-jq-fallback   rc=2 | 68/1 | d7
m11-allow-duplicate      rc=2 | 65/4 | a10 a19 a21 a43
m12-append-root-to-msg   rc=2 | 64/5 | a25 a26 a28 a47 a48

$ bash scratch/run_mutants.sh Critic136v2b/mutants n01…n07     (real 2m26s)
n01-brief-extra-root        rc=2 | 67/2 | a47 a48
n02-taskfile-skip-oracle    rc=2 | 68/1 | a49
n03-empty-guard-fallback    rc=2 | 68/1 | a50
n04-check-wrong-layer       rc=2 | 67/2 | d9 d11
n05-nested-layer-harness    rc=2 | 67/2 | d10 d11
n06-broken-profile-accepted rc=2 | 68/1 | d8
n07-empty-next-selected     rc=2 | 68/1 | a48

$ bash scratch/run_impl3cee.sh   (три скрипта `git show 3cee078b:scripts/*`, cmp == копии Architect136v2/impl_3cee078b/)
impl3cee078b rc=2 | клеток 69, зелёных 56, красных 13 |
  a25 a26 a27 a28 a31 a47 a48 b3 d5 d7 d8 d9 d11

$ bash scripts/pre_critic.sh contracts/136-dovodka-sessij-proektov.md   (в копии клона)
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
КРИТИК: дверь зелёная
rc=0

$ bash scratch/arb_run_125.sh          → s125 red: зелёных 70, красных 0   rc=0
$ bash scratch/arb_run_125.sh --model  → s125 model: зелёных 70, красных 0 rc=0

$ git diff --stat 59ba025a 56e0f1dc
 contracts/136-dovodka-sessij-proektov.md |  18 +-   (10 ins, 8 del)
 sessii_136/red_sessii_136.sh             | 174 ++-
 sessii_136/source.json                   | 901 ++-
 sessii_136/stabs/s31…s37/*               | +7 файлов
 10 files changed   — sessii_125/, scripts/ в diff ОТСУТСТВУЮТ (0 строк)
$ git diff --word-diff=porcelain 59ba025a 56e0f1dc -- contracts/136-*.md | grep '^[-+]'
  строка ВЕРСИЯ: +1 предложение «Достройка v2 по арбитражу 136v2 …»
  И-6: +«Страж ЕСТЬ, но пуст или не исполняется — именованный отказ rc 1 ДО exec без вызова двойника (у честной модели — `PIN_CHUZHOJ`: извлечение из пустого стража пусто).»
  И-1…И-5, И-7, И-8: изменений НЕТ (строки не в diff)
  Критерий: +абзац ТАБЛИЦА ОСЕЙ; п.1–5: 48→69, 43→64, 30→37, 46→54, +перечни новых клеток/стабов, +jq-мера osi/vne_osi
  п.7: префикс 2553 символа байт-в-байт = 59ba025a; +1 предложение в конце «Достройка (арбитраж 136v2, замер …): ВСЕ мутанты … КРАСНЫЕ; m01–m05 … n07 — на {a48}.»
  Разделы «Зоны и раздача», ПРОВОДКА, Модель угроз, Демаркация, NOT_RUN: hunks нет
$ md5sum строки РАЗРЕШИЛ-ВЛАДЕЛЕЦ в теле 1be3128f / 59ba025a / 56e0f1dc
b69f8f7bce2bec87ca58bb7f44e046a6 ×3 (дословно одна)
```

## Таблица пунктов перечня

| П. | Требование | Статус | Основание (путь:строка / замер) |
|---|---|---|---|
| (i) | строка таблицы осей A–D ↔ клетка; `osi ∪ vne_osi == kletki`; счёт кодом в раннере; числа контракта = выводу | **выполнен** | `source.json`: osi 55 + vne_osi 14 = 69 = `.kletki` (jq-равенство множеств `true`); раннер `red_sessii_136.sh:684–688` — симметричная разница ORDER↔(osi+vne_osi) и счёт `len(osi)+len(vne_osi)` на каждом прогоне, rc 2 при расхождении; контракт п.5 (:62 OBJECT) и абзац ТАБЛИЦА ОСЕЙ — 55/14/69/54/37, A 37/B 3/C 4/D 11 — все равны выводу jq |
| (i) | покрытие осей против моей таблицы | **выполнен, недостающих клеток нет** | A: argv × {task-file a28, NEXT непуст a25, бриф-отсутствует a29+a47 (структурно), бриф-пуст a48} = 5; формы пина 15 × {NEXT a8–a20,a23,a24 ; taskfile a21,a22,a34–a46} = 30 (15 shape в `k_pin_case` :234–250, taskfile-ветвь :254–258; run_cell :655–667); `\r`-пара × {a30, a49} = 2 → 37. B: нет файла a27, нет node a31, нулевой a50 = 3 (состояние «страж и node есть» — положительный оракул, наблюдаем a30/a49; контракт это оговаривает явно). C: есть c3, нет b3, битый b4, jq нет при посеве b5 = 4. D: профиля нет d2; вне .harness d4; стандарт-есть d1,d3; стандарт-потерян d5; иное-есть d6; иное-потерян при приманке d9; вложенное-есть d10; вложенное-потерян d11; jq нет d7; битый d8 = 11 |
| (ii) | `--model` N/N rc 0 | **выполнен** | `клеток 69, зелёных 69, красных 0`, rc 0 |
| (iii) | `--stabs` 0 непойманных; n01–n05/n07 в стабах; привязки к СВОИМ строкам (Н-39) | **выполнен** | `стабов 37, привязок 54, непойманных 0`, rc 0; s31–s36 побайтово = n01/n02/n03/n04/n05/n07 (cmp); привязки `source.json:.stab_vhod` s31→a47 (строка A «бриф структурно»), s32→a49 (A «\r × task-file»), s33→a50 (B «нулевой»), s34→d9 (D «иное потерян при приманке»), s35→d10+d11 (D «вложенное»), s36→a48 (A «бриф (NEXT_TASK пуст)»), s37→b5 (C «jq нет») — ровно строки моей таблицы п.2 арбитража; привязки берутся раннером из `source.json`, не из прозы (:714) |
| (iv) | m01–m12 красные; n01–n07 красные | **выполнен** | 19/19 мутантов красны на моих прогонах (сырой вывод выше); множества красных клеток совпадают с заявленными в теле коммита и в п.7 контракта по каждому мутанту |
| (v) | норма И-1…И-8 и зоны дословно (допуск: фраза И-6 о нулевом страже, пересчёт счётчиков) | **выполнен** | единственная правка нормы — одна фраза в И-6 (дозволена п.3(а).3 моего вердикта); И-1…И-5, И-7, И-8 и раздел «Зоны и раздача» вне diff |
| (v) | правило 7 / `_gruppa_c.sh` 125 без изменений | **выполнен по существу; литеральное отклонение — см. ниже** | `_gruppa_c.sh`, вся `sessii_125/`, `scripts/` — вне diff (0 строк); п.7: нормативный текст (11 батарей, 125 тот же rc, c01 70/70, c12) байт-в-байт; в конец абзаца ДОПИСАНО одно предложение-протокол замера мутантов (того же жанра, что уже имеющиеся записи круга-2 в том же абзаце) |
| (v) | 125 plain / `--model` 70/70 | **выполнен** | `s125 red: зелёных 70, красных 0` rc 0; `s125 model: зелёных 70, красных 0` rc 0 |
| (v) | строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ в теле 56e0f1dc дословно как в 1be3128f/59ba025a | **выполнен** | md5 трёх строк равны |
| (vi) | дискриминация против 3cee078b — только число | **13 красных** (заявлено 13; критик r2 на 48 клетках — 9: a25 a26 a27 a28 a31 b3 d5 d7 d8 — все 9 входят, +a47 a48 d9 d11) | `impl3cee078b: зелёных 56, красных 13` |
| (vii) | pre_critic rc 0 | **выполнен** | `КРИТИК: дверь зелёная`, rc 0 |

## Названные обходы

Нет. Ни одна находка не является обходом: нет входа, которому текст назначает исход, а батарея на OBJECT принимает нарушающий субъект (все 19 мутантов красны; 3cee078b красна на 13).

## Отклонения без обхода и советы (не блокируют)

1. **П.7 контракта дописан** (`contracts/136-dovodka-sessij-proektov.md:64` OBJECT, последнее предложение): протокол «ВСЕ мутанты критиков m01–m12 и n01–n07 — КРАСНЫЕ; m01–m05 красны на {…}; …». Мой п.3(а).4 требовал «правило 7 — без изменений»; нормативная часть не тронута, дописана запись замера — того же жанра, что записи круга-2 уже стоящие в этом абзаце (их я принял в арбитраже как часть законной спецификации). Содержание предложения мной ПЕРЕМЕРЕНО и совпадает по всем 19 мутантам. Обхода нет; совет архитектору — при желании вынести протокол в ПРОВОДКУ/тело коммита, чтобы п.7 нёс только норму.
2. **Строка ВЕРСИЯ** (:3) дополнена предложением о достройке — заголовок, не норма и не зоны; перечень о нём молчит; совет: не трогать дальше.
3. **a50 фиксирует имя отказа** (`red_sessii_136.sh:414` — `grep -q 'PIN_CHUZHOJ'`), тогда как фраза И-6 имени не фиксирует («именованный отказ… у честной модели — PIN_CHUZHOJ»). Мой вердикт советовал клетке принимать любой именованный отказ rc 1 без exec. Это строже нормы, не слабее — обхода нет; следствие для implementer: на нулевом страже реализация обязана выдать именно `PIN_CHUZHOJ` (а не, например, `strazh-net`), иначе a50 красна. Совет архитектору: либо расширить a50 до `grep -Eq 'PIN_CHUZHOJ|strazh-net'`, либо зафиксировать имя в И-6 явно — чтобы критерий и норма говорили одно.
4. Состояние оси B «страж и node есть» строки таблицы не имеет — контракт прямо объясняет это (наблюдаемо a30/a49). Согласен: отдельной клетки правило выразимости не требует.

## Итог

Все семь пунктов закрытого перечня исполнены; обходов нет. Числа: клеток 69 (osi 55 + vne_osi 14), `--model` 69/69 rc 0, `--stabs` 37/54/0 rc 0, мутантов красных 19/19 (m01–m12, n01–n07), 3cee078b — 13 красных, 125 plain 70/70 и `--model` 70/70, pre_critic rc 0. Нужен ли после этой сверки круг критика перед freeze — вопрос владельца (его слово 18:55: вариант Б, вместо круга). Дальше работает архитектор/оркестратор; арбитр кода не пишет.
