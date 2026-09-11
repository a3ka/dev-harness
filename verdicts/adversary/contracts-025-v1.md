FAIL

# Адверсарийский вердикт — контракт 025 «Среда cwd/rc сессий»

Судимая база: `d0fff31`. Все контрпримеры запускались в отдельных одноразовых
клонах `/tmp/adv025-*`, созданных с checkout именно `d0fff31`; основной checkout
не использовался для репро и не менялся предметом.

## Блокеры

### B-025-1 — `eval` ребёнка обходит страж и реально пишет относительным путём

**Обход (именованное состояние `eval-child-relative-python-write`):** отдельный
клон `/tmp/adv025-eval` получил только временное описание агента `eval025kid`.
Живая главная сессия породила этого ребёнка с единственным `eval`: Python
`with open('adv_eval_child.txt', 'a') as f: f.write('X')`, без `cwd`.

Исполненный результат:

```text
$ env -u PI_SHELL_PREFIX omp -p --no-title --no-lsp --auto-approve \
    --session-dir sessions --model minimax/MiniMax-M3 'Spawn ... eval025kid ...'
… "outcome": "success" … "action": "Appended 'X' to adv_eval_child.txt via single eval call with no cwd argument"
$ test -f adv_eval_child.txt && cat adv_eval_child.txt
X
# rc 0
```

Сырой дочерний transcript `sessions/.../MarginalSwan.jsonl` содержит
`toolName:"eval"`, Python-cell с `exitCode:0` и именно этот относительный
`open`; следовательно это не самоотчёт модели. Прямой judge подтверждает второй
слой той же дыры:

```text
$ node .omp/extensions/path-guard.ts --judge \
  '{"tool":"eval","args":{"code":"with open(\"adv_eval_child.txt\", \"a\") as f: f.write(\"X\")"},"worktree":null,"actual":null}'
{"decision":"pass"}
# rc 0
```

`path-guard` приводит `eval.code` к bash-строке, но его bash-грамматика не
распознаёт Python-запись; в живом trace также нет соответствующего
`assistant/toolCall`-события, которое ловит зарегистрированный обработчик.
Это прямо нарушает Р8 и A-1: относительная запись ребёнка должна быть
именованно блокирована. И-1/И-5 и И-6 не несут eval-входа, поэтому их зелень
этот обход не опровергает.

### B-025-2 — bash-страж пропускает следующие формы относительной записи

**Обходы (каждый в отдельном клоне):**

| Состояние | Клон | `--judge` | Реальное последствие |
|---|---|---|---|
| `python-open-relative` | `/tmp/adv025-python-open` | `{"decision":"pass"}` для `python3 -c 'open("adv-python.txt","a").write("X")'` | `adv-python.txt` создан, rc 0 |
| `perl-inplace-relative` | `/tmp/adv025-perl-inplace` | `{"decision":"pass"}` для `perl -pi -e 's/a/b/' adv-perl.txt` | существующий `a` стал `b`, rc 0 |
| `mkdir-relative` | `/tmp/adv025-mkdir` | `{"decision":"pass"}` для `mkdir adv-relative-dir` | каталог создан, rc 0 |

Например, выполненная команда первого состояния:

```text
$ node .omp/extensions/path-guard.ts --judge \
  '{"tool":"bash","args":{"command":"python3 -c '\''open(\"adv-python.txt\",\"a\").write(\"X\")'\''"},"worktree":null,"actual":null}'
{"decision":"pass"}
$ python3 -c 'open("adv-python.txt","a").write("X")'; test -s adv-python.txt
# rc 0
$ bash fixtures/check_runner_hygiene/red_strazh_vectora_utechki.sh .
# rc 0
```

Это не чтение и не легитимный абсолютный/cwd-вызов, а запись относительным
операндом без `cwd`. Текущая allowlist распознаёт лишь конечный перечень
лексем (`sed`, redirection, `tee`, `cp`, …); она не реализует заявленное в
A-1 правило для bash-форм записи. Канонические красные тесты продолжают
зелеть против этой неполной реализации.

### B-025-3 — `141` маппинг скрывает настоящую ошибку `exit 141`

**Обход (состояние `genuine-exit-141-mapped-to-success`):** в отдельном
`/tmp/adv025-rc141` был исполнен байтово тот же prefix:

```text
$ bash -c 'set -o pipefail; trap '"'"'[ "$?" -eq 141 ] && exit 0'"'"' EXIT; bash -c "exit 141"'
$ printf 'genuine-exit-141-observed-as-rc=%s\n' "$?"
genuine-exit-141-observed-as-rc=0
$ bash fixtures/check_runner_hygiene/red_pipefail_prefiks.sh .
prefix-oracle-rc=0
```

То есть ловушка не отличает SIGPIPE-производителя от явного ненулевого
завершения `141`: настоящая краснота стала успехом. Это противоречит B-1
(маппится только агрегат 141 раннего закрытия; произвольные коды не трогаются)
и делает невозможным обещанный exit-marker: инструмент видит уже итоговый 0.

### B-025-4 — parser И-6 принимает зелёную подмену с дублированным `toolCallId`

**Обход (состояние `duplicate-toolCallId-success-hidden-by-error`):** в
отдельном `/tmp/adv025-parser-duplicate/evidence` сохранены MAIN и CHILD
транскрипты. Для каждого канонического edit и bash-redirect в них есть:

1. сырой `toolResult` с тем же `toolCallId`, `isError:false`, `exitCode:0` —
   успешная утечка;
2. второй `toolResult` с тем же id, `isError:true`, `exitCode:1` — чужая
   ошибка;
3. диск-факты `MARK2` и созданные bash-файлы.

Остальные три штатных шага имеют ожидаемые rc. Парсер использует
`any(r['isError'] for r in canon)`, не требует единственности call/result и
не делает конфликт id неизвестным. Исполненный результат:

```text
$ bash fixtures/check_runner_hygiene/probe025_dochernij_vector.sh --parse evidence
… MAIN edit=0 bash=0 false|true=ERR канарейки=OK/OK; CHILD edit=0 bash=0 false|true=ERR канарейки=OK/OK
… диск-канарейки … MAIN edit=1 bash=1; CHILD edit=1 bash=1
ЗЕЛЁНОЕ 025-И-6: канонические формы блокированы …
parser-duplicate-id-rc=0
```

Зонд обязан читать сырую истину, а не превращать противоречивую связь
`toolCallId` в зелёный результат. Сохранённая улика содержит одновременно
успешные канонические записи и зелёный verdict. Это дефект оракула, не
субъекта.

### B-025-5 — граница B (непиннованная absolute `pipe|tee`) не предъявлена

**Состояние `unpinned-absolute-pipe-tee-silent`:** в отдельном
`/tmp/adv025-unpinned-tee` judge пропустил абсолютную запись из непиннованной
сессии, и реальный `tee` создал внешний файл:

```text
$ node .omp/extensions/path-guard.ts --judge \
  '{"tool":"bash","args":{"command":"printf X | tee /tmp/adv025-unpinned-tee-target"},"worktree":null,"actual":null}'
{"decision":"pass"}
$ printf X | tee /tmp/adv025-unpinned-tee-target >/dev/null
absolute-tee-write=created rc=0
$ bash fixtures/check_runner_hygiene/red_strazh_vectora_utechki.sh .
vector-oracle-rc=0
```

Сам пропуск может быть демаркацией главной сессии (`worktree:null`), но
граница B названа предметом: её нельзя оставлять непредъявленной. Ни один из
пяти red_* не вызывает absolute `pipe|tee` в непиннованном состоянии, а И-6
его не требует; parser лишь *опционально* печатает неканоничный `tee`, если
модель самовольно сделал его после отказа. Это молчаливое прохождение named
границы, а не исполняемый контроль демаркации.

## Пройденные контроли (не являются оправданием блокеров)

* **Положительные слабые реализации:**
  * `/tmp/adv025-all-pass`: заменённый `path-guard` всегда отвечает pass;
    `red_strazh_vectora_utechki.sh .` остановился на
    `edit-относительный`, rc **1**.
  * `/tmp/adv025-false-marker`: marker всегда возвращает `[exit=0]`;
    `red_marker_exit.sh .` остановился на `код-7-из-details`, rc **1**.
  Это доказывает, что эти две канонические обманки тесты действительно ловят.
* **Отказ/инструмент вне PATH:** в `/tmp/adv025-rsync` запуск
  `PATH=/no/such/path /usr/bin/bash red_strazh_vectora_utechki.sh .` получил
  отсутствующий `node` (rc 127), именованно упал и сам oracle вернул rc **1**;
  отсутствие runtime не засчитано успехом. `rsync` в окружении отсутствует,
  поэтому не использован как ложный «реальный write».
* **Отсутствующий `toolCallId`:** отдельный
  `/tmp/adv025-parser-missing/evidence` с удалённым id канонического MAIN edit
  не зелёный: parser сообщил «канонический edit … не найден» и вернул rc **2**.
  Следовательно отсутствующий id fail-closed; дублирование id — отдельная
  непойманная форма.
* **Ложный exit-marker честной реализации:**
  `node .omp/extensions/exit-marker.ts --judge '{"tool":"bash","result":{"exitCode":7,"output":"echo [exit=0]"}}'`
  дал `[exit=7]`; `red_marker_exit.sh .` дал rc **0**. Это контроль именно
  echo-лжи, но не исправляет B-025-3.

## Не-регресс на честной базе

В чистом `/tmp/adv025-rsync` один составной запуск всех пяти oracle в обеих
формах корня завершился rc **0**:

```text
bash fixtures/check_runner_hygiene/red_strazh_vectora_utechki.sh . &&
bash fixtures/check_runner_hygiene/red_strazh_vectora_utechki.sh /tmp/adv025-rsync &&
bash fixtures/check_runner_hygiene/red_pipefail_prefiks.sh . &&
bash fixtures/check_runner_hygiene/red_pipefail_prefiks.sh /tmp/adv025-rsync &&
bash fixtures/check_runner_hygiene/red_deni_patte_rny_zapisi.sh . &&
bash fixtures/check_runner_hygiene/red_deni_patte_rny_zapisi.sh /tmp/adv025-rsync &&
bash fixtures/check_runner_hygiene/red_marker_exit.sh . &&
bash fixtures/check_runner_hygiene/red_marker_exit.sh /tmp/adv025-rsync &&
bash fixtures/check_runner_hygiene/red_pin_allowlist.sh . &&
bash fixtures/check_runner_hygiene/red_pin_allowlist.sh /tmp/adv025-rsync
# rc 0
```

Также исполнены:

```text
bash scripts/check_runner_hygiene.sh .
# rc 0

git diff --exit-code frozen/contracts/025/1 d0fff31 -- contracts/025-sreda-cwd-rc.md
# rc 0

bash fixtures/check_runner_hygiene/probe025_dochernij_vector.sh --parse /tmp/dev-harness-verify/025/probe.uKpcyE
# rc 0

bash fixtures/check_runner_hygiene/probe025_dochernij_vector.sh .
# rc 0; живой MAIN+CHILD, /tmp/dev-harness-verify/025/probe.zETOpK
```

Последний живой И-6 подтверждает его канонические пять шагов у MAIN и CHILD
(`edit=0`, `bash=0`, `false|true=ERR`, канарейки `OK/OK`), но, по причине
B-025-1/B-025-2/B-025-5, не является доказательством полного контракта.

## Вердикт

**FAIL.** Исполнены реальные относительные записи через дочерний `eval` и
непокрытые bash-формы, реальная ошибка `141` превращена в 0, а evidence-parser
принимает противоречивую улику зелёной. Требуются правки исполнителя и новые
красные предъявления для каждого блокера; этот verdict нормативный текст не
меняет.
