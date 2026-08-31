accept

# Ревью контракта 017 «де-флейк метеринга»

Предмет — диапазон `0e6b5f7^..c425818`, заморозка
`frozen/contracts/017/1`, реализация `205355d`, усиление проб `e84923e` и
вердикты critic / arbiter / adversary. Проверка выполнена на живом HEAD
`c425818`; для пробы сохранения RUN задан `TMPDIR="$PWD/tmp"` (А-59).

## Вердикт

**accept.** Блокирующих находок нет: область соответствует каналам и зонам,
после заморозки норма контракта не менялась, а каждый реализуемый срез имеет
код в коммите implementer `205355d`. Пробы принадлежат architect, не автору
механизма; поздняя дельта `e84923e` усиливает, а не ослабляет их.

## 1. Область, авторство и атомарность

Сырой собственный history по зонам:

```text
$ git log --format='%h %an %s' 0e6b5f7^..c425818 --author=architect -- contracts/017-deflejk-metiringa.md fixtures/verify_antiplacebo/ NABLIUDENIA_ARCHITECT.md
185a12a architect А-69: последовательные правки одного файла — номера из ответа предыдущей (замер на пробах 017 этого вызова)
e84923e architect 017: усиление проб И-3/И-4 по находкам адверсария (ea091d1)
4ce57f5 architect А-66: адрес приведён к грамматике целей (CI шаг 11) — очередь автономности/фикс Н-72(б)
1f0bf27 architect 017 v3 (architect): фикс-дельта по РЕШЕНИЮ арбитража a9e14eb — p0.i наблюдает ВСЕ --config из argv спавна (единственность закрывает дублирование как класс, порядок неважен); страж И-4 на независимой базе (node + замороженный прокси + свой конфиг, без кода зоны implementer; фактор 6 по замеру отношения полный/база); граница стандарт-А в шапке probe_port0
e29d212 architect 017 v2 (architect): фикс-дельта по вердикту критика v1 — блокеры 2/3/4

$ git log --format='%h %an %s' 0e6b5f7^..c425818 --author=implementer -- scripts/check_metering.sh scripts/verify_antiplacebo.sh
205355d implementer 017: де-флейк метеринга — срезы 1-3, 5 (events instead of scans)

$ git log --format='%h %an %s' 0e6b5f7^..c425818 --author='Alex K' -- contracts/017-deflejk-metiringa.md
f7f2fc2 Alex K 017 v3: контракт-дельта по вердикту критика v2 — пачка architect (владелец-канал, draft-контракт, Н-72)
2d1731c Alex K 017 v2: контракт-дельта по вердикту критика v1 — пачка architect (владелец-канал: страж блокирует draft-контракт, Н-72)
0e6b5f7 Alex K 017: контракт дефлейка метеринга — пачка architect (коммит владельцем-каналом: страж блокирует новый draft-контракт вне активной зоны, Н-72)

$ git diff --name-only 0e6b5f7^..c425818 | wc -l
13
```

Три посадки `Alex K` в контрактный файл — разрешённый владелец-канал Н-72;
`ROADMAP.md`, `HANDOFF.md` и `NABLIUDENIA.md` принадлежат сессионной записи
orchestrator, а `NABLIUDENIA_ARCHITECT.md` — architect. Verdict-пути изменяли
только соответствующие critic, arbiter и adversary. `205355d` атомарно меняет
ровно два implementer-файла (128 добавлений, 138 удалений), `e84923e` — ровно
dва architect-proof-файла (71 добавление, 33 удаления). Смешения реализации с
пробами или нормативными файлами в этих коммитах нет.

Собственный независимый страж зон завершился успешно; последние строки сырого
вывода:

```text
$ bash scripts/check_zones.sh
  ok   contracts/017-deflejk-metiringa.md — зона: adversary → verdicts/adversary/ 017
  ok   contracts/017-deflejk-metiringa.md — зона: architect → contracts/017-deflejk-metiringa.md 017
  ok   contracts/017-deflejk-metiringa.md — зона: architect → fixtures/verify_antiplacebo/ 017
  ok   contracts/017-deflejk-metiringa.md — зона: architect → NABLIUDENIA_ARCHITECT.md 017
  ok   contracts/017-deflejk-metiringa.md — зона: critic → verdicts/critic/ 017
  ok   contracts/017-deflejk-metiringa.md — зона: implementer → scripts/check_metering.sh 017
  ok   contracts/017-deflejk-metiringa.md — зона: implementer → scripts/verify_antiplacebo.sh 017
  ok   contracts/017-deflejk-metiringa.md — зона: reviewer → verdicts/review/ 017
  ok   contracts/017-deflejk-metiringa.md — работа не раздаётся: fixtures/check_metering/ (нулевой churn — фикстуры зовут $BARRIER без аргументов и портов не выбирают) scripts/proxy/metering_proxy.ts (предмет 005, репорт уже есть) config/metering.json
замороженных контрактов: 16 · объявленных авторов: 5 · коммитов в диапазонах: 388 · проверено по зонам: 289
check_zones rc=0
```

## 2. §Предмет → реализация (построчно)

| Срез §Предмет | Реализующий коммит | Функции и наблюдённое изменение кода |
|---|---|---|
| 1. upstream-событие | `205355d` | `stub_upstream()` запускает Node с `listen(0)`, внутри listen-callback получает `server.address().port` и записывает `$dir/port`; затем ждёт файл при `kill -0`, различая гибель и «не репортит порт». Удалены прежние `free_port`, `ss`-poll и retry `EADDRINUSE` фикстурного пути. |
| 2. ветвь (и) на `:0` | `205355d` | `branch_и()` задаёт `proxy_port=0`, вызывает `proxy_up`, затем читает фактический `.port` обратно из `bcfg` перед запросами. |
| 3. `proxy_up`: событие → healthz; удалить `portup` | `205355d` | `proxy_up()` ждёт `<data_dir>/.actual_port` от живого процесса, переписывает `cfg.port`, и лишь затем циклически проверяет healthz; retry `EADDRINUSE` удален. `gen_config()` удаляет `portup="$(free_port)"` и мёртвый upstream-порт, ставит фиктивный `:1`, который `main()` заменяет фактическим upstream. |
| 5. А-19 + честный комментарий | `205355d` | `release()` в `scripts/verify_antiplacebo.sh` удаляет `$RUN` и собственный scratch только при `fails=0`; при отказе сохраняет RUN и `invocations.log`. Комментарий в `stub_upstream()` заменяет ложное утверждение о параллельных десятках фикстур на фактический последовательный раннер. |

Срез 4 намеренно не указан как реализация: это барьер architect в
`fixtures/verify_antiplacebo/probe_port0.sh`, а не код предмета implementer.

Сырой фрагмент собственной сверки реализации:

```text
$ git diff --unified=3 205355d^ 205355d -- scripts/check_metering.sh scripts/verify_antiplacebo.sh
-  PORT="$port" DIR="$dir" \
+  PORT="0" DIR="$dir" \
...
+    server.listen(0, "127.0.0.1", () => {
+      const addr = server.address();
+      const actualPort = (typeof addr === "object" && addr) ? addr.port : 0;
+      fs.writeFileSync(dir + "/port", String(actualPort));
...
-  portup="$(free_port)"
+  local role provider model token proxy_port
...
-  proxy_port="$(free_port)"
+  proxy_port=0
...
+  proxy_port="$(jq -r '.port' "$bcfg")"
...
-  rm -rf "$RUN" 2>/dev/null || true
+  if [ "${fails:-0}" -eq 0 ]; then
+    rm -rf "$RUN" 2>/dev/null || true
+    if [ "$OWN_SCRATCH" = 1 ]; then rm -rf "$SCRATCH" 2>/dev/null || true; fi
+  fi
```

## 3. Сырые прогоны живого дерева

```text
$ bash fixtures/verify_antiplacebo/probe_port0.sh
  ok   port0.gen: gen_config эмитит port:0 (bind :0, без free_port-скана)
  ok   port0.up: штатный proxy_up на port:0 → эфемерный 44571, cfg.port переписан, healthz 200
  ok   port0.conc: два конкурентных port:0 → РАЗНЫЕ OS-эфемерные порты (38441 ≠ 35481), оба healthz 200
  ok   port0.src: metering_proxy.ts репортит фактический порт от server.address() реальным writeFileSync(.actual_port)
  ok   port0.stub: тело stub_upstream без free_port и ss-скана — порт upstream назначает ОС, готовность событием
  ok   port0.stub: порт-файл upstream пишет сам слушатель — погибший до listen node не оставляет порта
  ok   port0.stub: upstream поднимается и отвечает при нерабочем ss — порт 34131 репортирован слушателем, не найден сканом
  ok   port0.i: ветвь (и) прошла под ss-лгуном; на спавне ЕДИНСТВЕННЫЙ --config с "port": 0, фактический 46839 из события .actual_port — прокси ветви на OS-эфемерном, выбор порта до слушателя и дублирование конфига мертвы
  ok   port0.noreport: живой стаб без порт-файла — именованный отказ «не репортит порт» (различим с мёртвым и с медленным)
probe_port0 rc=0

$ TMPDIR="$PWD/tmp" bash fixtures/verify_antiplacebo/probe_release_hranit_run.sh
  ok   (хранит) rc=1, RUN пережил отказ (/home/aka/Documents/dev-harness/tmp/probe017.JOmm6q/skr1/run-3104326 ), причина «ОТКАЗ: игрушка сломана» — в invocations.log упавшей ветви: отказ диагностируем
  ok   (убирает) rc=0 и run-каталогов не осталось — хранение RUN только при fails>0, не вечно
probe_release_hranit_run TMPDIR rc=0

$ bash scripts/check_metering.sh
  ok   а: healthz 200
  ok   б: 401 на неизвестный токен, строки в журнале нет
  ok   в: POST 201, тело и заголовки дословно, журнал 11 полей, usd=3409
  ok   г: 200 при переходе потолка, budget после=1000001404 > ceiling=1000000000, usd=2404
  ok   д: 502 при обрыве upstream, строка 11 полей status=502 tokens/usd=0
  ok   е: budget.json после rebuild равен свёртке calls.jsonl (непустой, побайтово)
  ok   ж: 503 на unpriced, upstream не вызван, строки нет
  ok   з: буквальное значение секрета не найдено (обход без ./tmp и ./.git — объявленное исключение)
  ok   и: ротация в одном pid: T1→T2→401, role=echbgbcc
  ok   к1: только статические node:-импорты в /home/aka/Documents/dev-harness/scripts/proxy/metering_proxy.ts
  ok   к2: child_process и внешних процессов в /home/aka/Documents/dev-harness/scripts/proxy/metering_proxy.ts нет
  ok   л: 2026-01 и 2026-02 различимы в ОДНОМ живом процессе; два int64-вектора точны
  ok   м: x-request-id прошёл client→upstream и в журнал дословно

барьер зелёный: 15 ветвей пройдены
check_metering default rc=0

$ bash scripts/check_metering.sh --port0
  ok   port0.gen: gen_config эмитит port:0 (bind :0, без free_port-скана)
  ok   port0.up: штатный proxy_up на port:0 → эфемерный 42085, cfg.port переписан, healthz 200
  ok   port0.conc: два конкурентных port:0 → РАЗНЫЕ OS-эфемерные порты (46507 ≠ 33445), оба healthz 200
  ok   port0.src: metering_proxy.ts репортит фактический порт от server.address() реальным writeFileSync(.actual_port)
  ok   port0.stub: тело stub_upstream без free_port и ss-скана — порт upstream назначает ОС, готовность событием
  ok   port0.i: ветвь (и) прошла под ss-лгуном; на спавне ЕДИНСТВЕННЫЙ --config с "port": 0, фактический 37303 из события .actual_port
  ok   port0.noreport: живой стаб без порт-файла — именованный отказ «не репортит порт»
check_metering --port0 rc=0

$ bash fixtures/verify_antiplacebo/probe_vetvi_ne_zamedleny.sh
фактор 6 · ветвей 15 (измерено = заявлено) · независимая база мс 685 (медиана 685/696/643) · полный мс 20391 · порог мс 61650
  ok   полный барьер 20391 мс внутри порога 61650 мс (фактор 6 × 15 ветвей × независимая база 685 мс) — замедления нет
probe_vetvi_ne_zamedleny rc=0

$ npm run check:contract-ready
npm notice run dev-harness@0.0.0 check:contract-ready
npm notice run bash scripts/check_check_contract_ready.sh
  ok   (зоны) без зон → RC≠0, названо «зон»
  ok   (зонаформ) малформед «ЗОН» → RC≠0, названо «зон»
  ok   (проба) зелёная проба → RC≠0, названо «проб»
  ok   (пробаф) проба на несуществующий файл → RC≠0, названо «проб»
  ok   (счёт) рассогласованный счёт → RC≠0, названо «счёт»
  ok   (арбитраж) несуществующий арбитражный пункт → RC≠0, названо «арбитраж»
  ok   (готов) готовый контракт → RC=0 + «OK» в выводе
check_check_contract_ready: ветви «all» зелены
check:contract-ready rc=0

$ git diff --exit-code frozen/contracts/017/1 HEAD -- contracts/017-deflejk-metiringa.md
frozen-contract-diff rc=0 (empty output above)
```

## 4. Пробы не подогнаны к реализации; красное предъявлено

`205355d` изменяет только `scripts/check_metering.sh` и
`scripts/verify_antiplacebo.sh`; файлов `fixtures/verify_antiplacebo/` автор
implementer не менял. История proof-слоя принадлежит architect (`e29d212`,
`1f0bf27`, `e84923e`). Следовательно, автор механизма не переписывал свои
проверки.

Собственный diff `ea091d1..e84923e` показывает именно усиление двух прежних
слабых утверждений: в И-3 `invocations.log` размера `+0` заменён обязательным
точным присутствием die-причины в журнале **упавшей** ветви; в И-4 формула
`6 × N × база` заменена на `6 × M × база`, где `M` — независимо пересчитанное
множество уникальных строк исполнения, а `N` сверяется с `M`. Новых зелёных
обходов дельта не вводит.

Красные пары зафиксированы до усиления в `ea091d1` и перепроверены после него
в `c425818`: (И-3) журнал с одной строкой метаданных, другой строкой или
обрывком даёт `rc=1` и поимённый отказ о неточной/отсутствующей причине;
старый `-size +0` контроль на первом состоянии давал `rc=0`. (И-4) отчёт
`100` при реально исполненных 15, как с задержкой 20 с, так и без неё, даёт
`rc=1` с `заявленное ветвей 100 ≠ измеренному 15`; старая проба на чистом
`100` давала `rc=0`. Это не повтор декларации: в adversary-вердикте приведены
варианты журналов и счётные мутации, не изменяющие сами пробы.

Свой контролируемый red-path И-4 также выполнен:

```text
$ TMPDIR="$PWD/tmp" bash fixtures/verify_antiplacebo/probe_vetvi_ne_zamedleny.sh --selftest
фактор 6 · ветвей 15 (измерено = заявлено) · независимая база мс 413 (медиана 631/413/237) · полный мс 21683 · порог мс 37170
  ok   честная мера внутри порога (21683 ≤ 37170 мс) — подкладываю sleep ровно в порог
  ok   selftest: обёртка (sleep 38 с = порог) замерена 59623 мс > порога 37170 мс — ЛОВЕЦ КРАСИТ замедление
probe_vetvi_ne_zamedleny --selftest rc=0
```

Заморозка не переписана: raw `git diff --exit-code` выше пуст и имеет `rc=0`.

## Находки

- **Блокер:** нет.
- **Совет:** нет.

Вердикт разрешает оркестратору поставить `done/contracts/017/1`.
