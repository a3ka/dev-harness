# PROVERKA — живые прогоны клеток 090 (architect + оркестратор-правка герметичности, 2026-10-07)

Субъекты:
- **HEAD** = worktree `wip/090/architect`, коммит `fbf7f86` (контракт, без фикса кода);
- **GREEN** = копия HEAD + ТРИ правки, предписанные §Диагноз контракта (посев
  `ORCH_SESS_GLOB="$SESS_GLOB"` до bootstrap; `UHOME="${ORCH_UHOME:-$(getent passwd "$U" |
  cut -d: -f6)}"` — тест-knob без изменения дефолтного поведения; чтение предусловий
  `install.sh` через `git config --file`), собранная в `/tmp/dev-harness-verify/090-green2`.

## 0. Герметичность (Н-219) — ПРАВКА этой итерации

Оригинальная `red_ctx_deep_no_home.sh` (архитектор, 21:56) сажала тест-сессию под РЕАЛЬНЫЙ
`$(getent passwd harness | cut -d: -f6)/.local/state/dev-harness-sessions/**` — живой
станционный `orch-peak` увидел её своим боевым циклом опроса (21:45 2026-10-07, ложный
«принудительный перезапуск», 15м GRACE; `NABLIUDENIA.md` Н-219). Починка: клетка сажает
сессию под ФЕЙКОВЫЙ home `$W/fakehome` (scratch текущего прогона,
`/tmp/dev-harness-verify/**`) и передаёт его субъекту через НОВЫЙ env-knob `ORCH_UHOME`
(третья правка §Диагноз — `UHOME="${ORCH_UHOME:-$(getent ...)}"`, приоритет ТОЛЬКО у
явного knob'а, дефолт без knob'а не меняется). Новая ОБЯЗАТЕЛЬНАЯ клетка
`red_hermetic_no_real_sessions.sh` гоняет всю семью под ФОНОВЫМ watcher (опрос реальных
путей каждые 0.05с, не однократный снимок до/после — транзитное присутствие снимок
до/после НЕ видит, ровно так и был пропущен оригинальный дефект) и красит находку по
ИМЕНИ (`*z090test*`) — редакция круга 0; фильтр по имени снят кругом 1 (см. §7.2),
инвариант сужен кругом 2 до множества чтения orch-peak (см. §8); баз-линия исключает
ПРЕДСУЩЕСТВОВАВШИЕ артефакты (напр. осиротевший
`/var/lib/orch-peak/ctx-090_z090test_1791409477_745374`, root-owned, от САМОГО инцидента
21:45 — не предмет этой клетки, предмет — НОВОЕ загрязнение текущим прогоном).

## 1. Красное на HEAD (до фикса) — ловит оба дефекта, герметично

```
$ ORCH090_SUBJECT=<HEAD> bash fixtures/fix_090_orch_peak_home/red_no_home_ctx.sh
КЛЕТКА-ОТКАЗ(090): лёгкая: env -u HOME ctx → rc=1, ожидался 0. stderr: …/scripts/lib_session.sh: line 18: HOME: unbound variable
rc=1

$ ORCH090_SUBJECT=<HEAD> bash fixtures/fix_090_orch_peak_home/red_ctx_deep_no_home.sh
КЛЕТКА-ОТКАЗ(090): глубокая: rc=1 (ожидался 0) — сценарий CTX_HARD не дошёл до конца. stderr: …/repo/scripts/lib_session.sh: line 18: HOME: unbound variable
rc=1

$ ORCH090_SUBJECT=<HEAD> bash fixtures/fix_090_orch_peak_home/red_install_local_config.sh
установлено: root-часть (orch-peak + 7 юнитов)
  ✗ A: предусловия выполнены → отказ только на chattr: в stderr ожидалось: Отказ: chattr +i на
  ✗ A: … в stderr не должно быть: core.hooksPath не установлен
  ✗ B: hooksPath=/evil/other → отказ с именованным значением: в stderr ожидалось: core.hooksPath не установлен (/evil/other)
  ✓ C: ключа нет → честный fail-closed
  ✗ D: autoSetupMerge=true → отказ с прочитанным значением: в stderr ожидалось: branch.autoSetupMerge не false (true)
КЛЕТКА-ОТКАЗ(090): install-клетка: см. ✗ выше (ложный отказ Н-216 либо сломанное чтение предусловий)
rc=1

$ ORCH090_SUBJECT=<HEAD> bash fixtures/fix_090_orch_peak_home/red_hermetic_no_real_sessions.sh
ЗЕЛЁНО(090-герметичность): семья прогнана целиком под фоновым watcher (опрос каждые 0.05с), ни одного НОВОГО *z090test* пути под <UHOME>/.local/state/dev-harness-sessions или /var/lib/orch-peak не замечено
rc=0
```

Кейс A — дословный ложный отказ Н-216 («core.hooksPath не установлен» при
реально установленном ключе), C зелёный и до, и после — пин fail-closed, не
дискриминатор. Герметичность — ЗЕЛЁНА уже на HEAD (функциональные клетки красные по
СВОЕМУ предмету, но ни одна не трогает реальный каталог сессий — починка по Н-219
действует независимо от состояния фикса П1/П2).

## 2. Зелёное на эталонном патче (та же клетка, другой субъект)

```
$ ORCH090_SUBJECT=<GREEN> bash fixtures/fix_090_orch_peak_home/red_no_home_ctx.sh
ЗЕЛЁНО(090-лёгкая): orch-peak ctx под env -u HOME -u ORCH_SESS_GLOB → rc 0, unbound нет
rc=0

$ ORCH090_SUBJECT=<GREEN> bash fixtures/fix_090_orch_peak_home/red_ctx_deep_no_home.sh
ЗЕЛЁНО(090-глубокая): ctx CTX_HARD под env -u HOME -u ORCH_SESS_GLOB ORCH_UHOME=<fakehome>: rc 0, маркер, say, «погибнут: LIBSRC:Agent090», ГЕРМЕТИЧНО (нет путей вне $W)
rc=0

$ ORCH090_SUBJECT=<GREEN> bash fixtures/fix_090_orch_peak_home/red_install_local_config.sh
установлено: root-часть (orch-peak + 7 юнитов)
  ✓ A: предусловия выполнены → отказ только на chattr
  ✓ B: hooksPath=/evil/other → отказ с именованным значением
  ✓ C: ключа нет → честный fail-closed
  ✓ D: autoSetupMerge=true → отказ с прочитанным значением
ЗЕЛЁНО(090-install): предусловия 081 читаются из файла (не через --local), ложный отказ Н-216 ушёл, fail-closed жив
rc=0

$ ORCH090_SUBJECT=<GREEN> bash fixtures/fix_090_orch_peak_home/red_hermetic_no_real_sessions.sh
ЗЕЛЁНО(090-герметичность): семья прогнана целиком под фоновым watcher (опрос каждые 0.05с), ни одного НОВОГО *z090test* пути под <UHOME>/.local/state/dev-harness-sessions или /var/lib/orch-peak не замечено
rc=0
```

Отказ «chattr +i» в кейсе A — ожидание непривилегированного тест-мира
(immutable-бит ставит только root); на станции под root шаг завершится rc 0.
Доказательство глубокой клетки: полный CTX_HARD-путь дошёл до маркера, say.log
непуст, отчёт несёт «живые субагенты погибнут: LIBSRC:Agent090» — субагент
найден по ФЕЙКОВОМУ UHOME-глобу (`ORCH_UHOME`), библиотека подключилась в главном
шелле (префикс LIBSRC из помеченной копии), РЕАЛЬНЫЙ каталог сессий не тронут.

## 3. Батарея обманных стабов (Н-39) — пойманы в ОБОИХ состояниях субъекта

```
$ ORCH090_SUBJECT=<HEAD>  bash fixtures/fix_090_orch_peak_home/battery_stubs.sh
✓ стаб1 decoy-глоб пойман (rc=1)
✓ стаб2 subshell-глушение пойман (rc=1)
✓ стаб3 hardcode-hooksPath пойман (rc=1)
ЗЕЛЁНО(090-батарея): 3/3 обманных стабов пойманы своими клетками
rc=0

$ ORCH090_SUBJECT=<GREEN> bash fixtures/fix_090_orch_peak_home/battery_stubs.sh
✓ стаб1 decoy-глоб пойман (rc=1)
✓ стаб2 subshell-глушение пойман (rc=1)
✓ стаб3 hardcode-hooksPath пойман (rc=1)
ЗЕЛЁНО(090-батарея): 3/3 обманных стабов пойманы своими клетками
rc=0
```

Стабы строятся ИЗ текущего субъекта (копия + порча с проверкой якоря), поэтому
батарея осмыслена и до, и после фикса: «decoy-глоб» после фикса портит сам посев
(`ORCH_SESS_GLOB="/nonexistent-090-stub"` — выглядит как фикс, глоб неверен), до
фикса — классический `export HOME=/nonexistent-090-stub`.

## 4. Воспроизведение Н-217 без фикстур (живой дым, HEAD)

```
$ env -u HOME -u ORCH_SESS_GLOB ORCH_PEAK_TEST=… ORCH_REPO=<HEAD> … bash ops/server/root/orch-peak ctx
<HEAD>/scripts/lib_session.sh: line 18: HOME: unbound variable
RC=1
```

Дословно совпадает со станционным журналом Н-217 (NABLIUDENIA.md).

## 5. Новая клетка `red_hermetic_no_real_sessions.sh` — доказательство НЕ-таутологии (Н-39)

Декой: КОПИЯ `red_ctx_deep_no_home.sh` БЕЗ fakehome-изоляции (оригинальная архитекторская
версия ДО этой правки — сажает сессию под РЕАЛЬНЫЙ `$(getent passwd harness|cut -d: -f6)`).

```
$ ORCH090_SUBJECT=<HEAD> bash <декой-набор>/red_hermetic_no_real_sessions.sh
КЛЕТКА-ОТКАЗ(090): герметичность нарушена: НОВЫЕ *z090test* замечены под реальными каталогами во время прогона: /home/harness/.local/state/dev-harness-sessions/z090test_1791413033_2359985;/home/harness/.local/state/dev-harness-sessions/z090test_1791413033_2360396;…
rc=1
```

Клетка ловит ИМЕННО регресс Н-219 (транзитное присутствие, даже когда декой успевает
вычистить себя на exit — watcher фоновый, опрашивает каждые 0.05с ВО ВРЕМЯ прогона, не
снимок до/после). На ГЕРМЕТИЧНОМ наборе (текущие фикстуры этой правки) — ЗЕЛЁНО (§1, §2
выше). Реальный каталог сессий подтверждён чистым (`find … -iname '*z090test*'` → пусто)
ДО и ПОСЛЕ каждого прогона этой PROVERKA.

## 6. Остаточное наблюдение (НЕ предмет 090, станция)

`/var/lib/orch-peak/ctx-090_z090test_1791409477_745374` — осиротевший файл САМОГО
инцидента Н-219 (root-owned, timestamp 21:45 2026-10-07), подтверждён живым `cat`/`ls -la`
этой сессией. НЕ может быть убран harness-пользователем (нет прав на root-owned файл в
`/var/lib/`); НЕ блокирует эту PROVERKA (базлайн-исключение §0 его игнорирует) и НЕ
блокирует 090 — передано в доклад владельцу/консультанту как станционная уборка, вне
зоны этого контракта.


## 7. Круг 1 critic — FAIL, 4 блокера, все починены живьём (оркестратор)

Вердикт: `verdicts/critic/contracts-090-v1.md` (main, коммит `1b5ff93`).

1. **ЗОНА-строки не машиночитаемы** (markdown-обёртка, `/**`, запятые). Починка:
   литеральные строки `ЗОНА <автор>: <путь>…` (без обёртки, без `*`, каталог с
   финальным `/`), добавлена `ПЕРЕСЕЧЕНИЕ implementer: .github/workflows/ci.yml — 011/015
   <причина>` (две строки — коллизия с ДВУМЯ историческими architect-заявками, прецедент
   084). Живой `bash scripts/check_precision_gate.sh . contracts/090-*.md` → `OK`, rc 0
   (было: зона-коллизия, НЕ видел зоны вовсе).
2. **Watcher герметичности слеп к не-`z090test`-порче** (критик: декой с ДРУГИМ именем
   файла дал `WATCHER_RC=0 POLLUTION_EXISTS=True`). Починка: `red_hermetic_no_real_sessions.sh`
   переписан — БЕЗ фильтра по имени (полный список путей+mtime под СКОУПОМ
   `.../zones/dev/.omp/profiles/dev/agent/sessions/--home-harness-dev-harness--/**`, НЕ
   всё дерево `dev-harness-sessions` — там живёт `agent.db-shm`/`agent.db-wal` СОБСТВЕННОЙ
   живой omp-сессии, churnит каждую секунду, даёт ложные срабатывания, НЕ relevant для
   orch-peak glob'а). ФАКТ ПО ПОПРАВКЕ АРБИТРА (замер 1, варианты A/C/D): декой ловится
   rc 1 с НАЗВАННЫМ путём ТОЛЬКО когда файл положен ВНУТРЬ подпути SESS_GLOB (вариант C:
   `…/ordinary-session/zones/dev/.omp/profiles/dev/agent/sessions/--home-harness-dev-harness--/journal.jsonl`,
   транзитно); размещение ВНЕ подпути — транзитное (вариант A:
   `dev-harness-sessions/ordinary-session/journal.jsonl`) ИЛИ постоянное (вариант D,
   файл не удалён) — клеткой НЕ ловится (rc 0); это измерено арбитром живьём, не
   теоретическая оговорка. Формулировка круга 1 «декой пишет
   `.../ordinary-session/journal.jsonl` под реальный UHOME → ловит rc 1» была ошибкой
   автора: названный путь лежит ВНЕ подпути. Вне-подпути записи не входят в множество
   чтения orch-peak (не вызывают Н-219) и остаются под write-allowlist Н-85/А-122.
   Хермет-фикстуры на честном субъекте — rc 0 в CI (нет живой сессии); на станции
   возможен ложный красный от журналов живых субагентов внутри подпути (контрзамер
   арбитра — см. ОСТАТОЧНЫЙ РИСК в шапке клетки).
3. **Н-39 остался в §Приёмочный критерий п.1/2/5** (прозой привязаны «decoy-глоб →
   эта клетка rc 0», «стабы → отказ глубокой», «декой → rc 1 с реальными путями»).
   Починка: ВСЕ «негативная пара»-предложения вычищены из §Приёмочный критерий; то же
   — из таблицы §Красные предъявления и абзаца «Обманные стабы и где различимы»
   (переписан на generic-указатель «привязка — в коде battery_stubs.sh/клетки, Н-39»,
   без имён стабов и их конкретного катч-входа в прозе).
4. **ПРОВОДКА не читается механизмом** (`## ПРОВОДКА` вместо `ПРОВОДКА:`, guard=каталог,
   backtick-обёртка ЭНФОРСМЕНТ). Починка: литеральный `ПРОВОДКА:` заголовок,
   `guard=fixtures/_krasnye_090.sh` (НОВЫЙ агрегатор семьи, файл а не каталог, матчит
   house-конвенцию `_krasnye_NNN.sh`), ЭНФОРСМЕНТ-абзац без обёртки объясняет отложенное
   подключение (implementer wires CI ПОСЛЕ реализации — прецедент 074/085). Живой
   `bash scripts/check_provodka.sh . contracts/090-*.md` → rc 1 «guard не подключён»
   (ОЖИДАЕМО на этой стадии — check_provodka ГЕЙТИТ `done_contract.sh` шаг 6, НЕ critic/
   freeze; guard будет подключён implementer'ом при лендинге, тогда и позеленеет).

Пре-критик дверь после всех фиксов: `bash scripts/pre_critic.sh contracts/090-*.md` →
`КРИТИК: дверь зелёная`, rc 0.

Новый агрегатор `fixtures/_krasnye_090.sh` (house-конвенция, аналог `_krasnye_080.sh`/
`_krasnye_088.sh`): прогоняет все 5 клеток семьи последовательно, печатает `— <файл>: rc=N`
по каждой, ИТОГ = первая красная (rc=1) или первая NOT_IMPLEMENTED (rc=2) или 0. Живой
прогон на HEAD (без фикса): 3 красных (лёгкая/глубокая/install — ОЖИДАЕМО, предмет ещё не
реализован), 2 зелёных (батарея/герметичность — инварианты, независимые от П1/П2) → ИТОГ
rc=1.

## 8. Круг 2 критика + арбитраж — инвариант П3 сужен до множества чтения orch-peak

Вердикт критика круг 2: `verdicts/critic/contracts-090-v2.md` (main `d5ff378`) — FAIL, 2
блокера. Арбитраж: `verdicts/arbitration/contracts-090-vopros-watcher-i-provodka.md`
(main `f5e4c49`): вопрос 1 (watcher) — критик прав по факту/классу, автор по объёму;
вопрос 2 (`guard=fixtures/`) — находка СНЯТА, правка не нужна. Применено (текст контракта
+ шапка/сообщения клетки; скан-логика watcher'а — предикат, цикл, скоуп find — НЕ менялась):

1. Инвариант П3/Н-219 переформулирован одинаково во всех нормативных местах контракта
   (Существующее/Н-219, §Предмет П3, §Диагноз П3, таблица предъявлений, преамбула и п.5
   §Приёмочный критерий): «ни одна клетка этой семьи не создаёт и не изменяет файл под
   множеством чтения реального orch-peak — подпуть SESS_GLOB … и `/var/lib/orch-peak/**`
   — ни при каком сценарии, даже транзитно» (полный путь и цитаты строк — в контракте).
2. Оговорка сужения — в §Приёмочный критерий: сужение обосновано диагнозом по коду
   (orch-peak читает под `dev-harness-sessions` только SESS_GLOB) и замером станции
   арбитра (12,5 тыс. файлов; churn `agent.db-wal`/`agent.db-shm`, mtime-окно 1.5-2с —
   сплошной 0.05с-скан красен на первом же опросе; фильтр по имени = класс слепоты
   v1-Б2). Записи ВНЕ подпути остаются под write-allowlist Н-85/А-122.
3. Сообщения клетки (ЗЕЛЁНО/КЛЕТКА-ОТКАЗ) называют РЕАЛЬНО сканируемый скоуп
   (подпуть SESS_GLOB + `/var/lib/orch-peak/**`), не каталог сессий целиком; шапка
   «ОСТАТОЧНЫЙ РИСК» дополнена контрзамером арбитра (журналы живых субагентов и
   `*.bash.log` внутри подпути — ложный красный на станции, CI чист) и оговоркой про
   `$UHOME/orch-peak-report.txt`/`$UHOME/orch-loop.stop` (orch-peak:25-26, вне обоих
   каталогов, watcher'ом не сторожатся — закрывает write-allowlist Н-85/А-122).

Живой прогон этой правки — безопасная реплика методики арбитра: копия семьи в
`/tmp/dev-harness-verify/arch090-arbfix/cell-*`, ДВЕ подмены (`REAL_UHOME` → `/tmp/dev-harness-verify/arch090-arbfix/ch`, `REAL_STATE` → `/tmp/dev-harness-verify/arch090-arbfix/st`,
контролируемые каталоги), в реальные `~/.local/state/dev-harness-sessions/**` и
`/var/lib/orch-peak/**` — ни байта; декой — пятый `run_cell` (транзитный:
запись → `sleep 0.3` → удаление), арбитровы варианты C и A:

```
$ ORCH090_SUBJECT=/tmp/dev-harness-worktrees/c907157c/wip-090-architect bash /tmp/dev-harness-verify/arch090-arbfix/cell-green/red_hermetic_no_real_sessions.sh
ЗЕЛЁНО(090-герметичность): семья прогнана целиком под фоновым watcher (опрос каждые 0.05с, полный список путей+mtime, БЕЗ фильтра по имени) по множеству чтения реального orch-peak: ни одного НОВОГО/ИЗМЕНИВШЕГОСЯ пути под подпутём SESS_GLOB /tmp/dev-harness-verify/arch090-arbfix/ch/.local/state/dev-harness-sessions/*/zones/dev/.omp/profiles/dev/agent/sessions/--home-harness-dev-harness--/** или под /tmp/dev-harness-verify/arch090-arbfix/st/** не замечено
rc=0

$ ORCH090_SUBJECT=/tmp/dev-harness-worktrees/c907157c/wip-090-architect bash /tmp/dev-harness-verify/arch090-arbfix/cell-in/red_hermetic_no_real_sessions.sh
КЛЕТКА-ОТКАЗ(090): герметичность нарушена: НОВЫЕ/ИЗМЕНИВШЕЕСЯ пути под множеством чтения реального orch-peak во время прогона (подпуть SESS_GLOB: /tmp/dev-harness-verify/arch090-arbfix/ch/.local/state/dev-harness-sessions/*/zones/dev/.omp/profiles/dev/agent/sessions/--home-harness-dev-harness--/**; state: /tmp/dev-harness-verify/arch090-arbfix/st/**): /tmp/dev-harness-verify/arch090-arbfix/ch/.local/state/dev-harness-sessions/ordinary-session/zones/dev/.omp/profiles/dev/agent/sessions/--home-harness-dev-harness--/journal.jsonl;
rc=1

$ ORCH090_SUBJECT=/tmp/dev-harness-worktrees/c907157c/wip-090-architect bash /tmp/dev-harness-verify/arch090-arbfix/cell-out/red_hermetic_no_real_sessions.sh
ЗЕЛЁНО(090-герметичность): … (дословно как в зелёном прогоне) …
rc=0
```

Три различающих входа совпадают с замером 1 арбитра: честная семья → rc 0; декой ВНУТРЬ
подпути (вариант C) → rc 1 с названным путём; декой ВНЕ подпути (вариант A,
`dev-harness-sessions/ordinary-session/journal.jsonl`) → rc 0 — задокументированная
граница скоупа (вне множества чтения orch-peak, оговорка сужения в контракте), не
скрытая дыра. Прогоны этой сессии в реальное дерево сессий/орч-стейт НЕ писали
(единственные записи — `/tmp/dev-harness-verify/**`).


## 9. Круг 2 адверсария — стаб «дефолт-константа» дефолтной ветви UHOME; закрыт шестой клеткой (architect, 2026-10-08)

Находка (Adversary090): мутация строки 18 orch-peak
`UHOME="${ORCH_UHOME:-$(getent passwd "$U" | cut -d: -f6)}"` →
`UHOME="${ORCH_UHOME:-/nonexistent-090-wrong-default}"` (дефолтная ветвь заменена константой)
проходила ВСЕ 5 клеток зелёным — каждая задавала `ORCH_UHOME` явно, дефолтная ветвь не
тестировалась вовсе. Дефект КЛЕТКИ (покрытия), не реализации: код implementer'а (90e82e0)
уже дословно соответствует §Регрессионная граница. Закрытие: клетка
`red_ctx_deep_uhome_default.sh` — `ORCH_UHOME` изъят (`env -u`), home субъекта достижим
ТОЛЬКО через дефолтную getent-ветвь (синтетический `ORCH_USER`, отсутствующий в реальном
passwd — первая ступень; getent-шим с полем 6 = `$W/fakehome` — вторая), + стаб 4
«дефолт-константа» в `battery_stubs.sh` (якорь `^UHOME=` — обе легитимные формы субъекта).

Прогоны (сессия architect, worktree wip/090/architect):

### 9.1. HEAD без фикса — КРАСНАЯ (норма: нет ни knob'а, ни посева)

```
$ bash fixtures/fix_090_orch_peak_home/red_ctx_deep_uhome_default.sh
КЛЕТКА-ОТКАЗ(090): дефолт-getent: rc=1, Н-217 жив (нет посева ORCH_SESS_GLOB): …/repo/scripts/lib_session.sh: line 18: HOME: unbound variable
rc=1
```

### 9.2. Честный implementer (git archive 90e82e0 → /tmp/dev-harness-verify/090-impl-subject) — ЗЕЛЁНАЯ

```
$ ORCH090_SUBJECT=/tmp/dev-harness-verify/090-impl-subject bash fixtures/fix_090_orch_peak_home/red_ctx_deep_uhome_default.sh
ЗЕЛЁНО(090-дефолт-getent): ctx CTX_HARD при env -u ORCH_UHOME: UHOME вычислен из дефолтной getent-ветви (синтетический passwd → fakehome), rc 0, маркер, say, «погибнут: LIBSRC:Agent090», ГЕРМЕТИЧНО (нет путей вне $W)
rc=0
```

### 9.3. Стаб в СВОЁМ worktree (мутация строки 18, сразу откачена) — КРАСНАЯ

```
$ python3 …/stubify.py ops/server/root/orch-peak        # → UHOME="${ORCH_UHOME:-/nonexistent-090-wrong-default}"
$ bash fixtures/fix_090_orch_peak_home/red_ctx_deep_uhome_default.sh
КЛЕТКА-ОТКАЗ(090): дефолт-getent: rc=1, Н-217 жив (нет посева ORCH_SESS_GLOB): … line 18: HOME: unbound variable
rc=1
$ git checkout -- ops/server/root/orch-peak             # восстановлено: строка 18 = getent
```

### 9.4. Изоляция находки: стаб на дереве implementer'а + обновлённая семья (ORCH_USER=root — прецедент круга адверсария: watcher герметичности сканирует /root, живых сессий нет). ЕДИНСТВЕННАЯ функциональная красная — новая клетка; батарея ловит стаб 4

```
— red_no_home_ctx.sh: rc=0
— red_ctx_deep_no_home.sh: rc=0
КЛЕТКА-ОТКАЗ(090): дефолт-getent: маркер перезапуска не поставлен — субъект НЕ нашёл тест-сессию через дефолтную ветку UHOME (getent): дефолт подменён константой (стаб адверсария?) либо пуст глоб сессий
— red_ctx_deep_uhome_default.sh: rc=1
— red_install_local_config.sh: rc=0 (кейсы A–D ✓)
✓ стаб1 decoy-глоб пойман (rc=1)
✓ стаб2 subshell-глушение пойман (rc=1)
✓ стаб3 hardcode-hooksPath пойман (rc=1)
✓ стаб4 дефолт-константа пойман (rc=1)
ЗЕЛЁНО(090-батарея): 4/4 обманных стабов пойманы своими клетками
— battery_stubs.sh: rc=0
ИТОГ 090: rc=1
```

Красная герметичности в прогоне 9.4 — станционный флейк риска №1 (шапка клетки): живой
orch-peak станции написал в окно прогона `/var/lib/orch-peak/ctx-<id живой сессии
архитектора>*`, `.warned`, `pane` — файлы названы id сессии (01a11acb…, родилась
09:15:33Z), клетки семьи писали только в свои `$W` (их ЗЕЛЁНО-строки это утверждают).

### 9.5. Guard ЦЕЛИКОМ на честном implementer (та же методика) — всё зелёное

```
— red_ctx_deep_uhome_default.sh: rc=0
ЗЕЛЁНО(090-батарея): 4/4 обманных стабов пойманы своими клетками
— battery_stubs.sh: rc=0
ЗЕЛЁНО(090-герметичность): … ни одного НОВОГО/ИЗМЕНИВШЕГОСЯ пути … не замечено
— red_hermetic_no_real_sessions.sh: rc=0
ИТОГ 090: rc=0
```

### 9.6. Не-таутология герметичности ОБНОВЛЁННОЙ семьи (реплика-методика §8: подмены REAL_UHOME/REAL_STATE на контролируемые каталоги, в реальные деревья — ни байта; декой — вариант C арбитра, транзитный журнал ВНУТРЬ подпути SESS_GLOB реплики)

```
$ bash …/repl/cell-green/red_hermetic_no_real_sessions.sh      # семья, вкл. новая клетка
ЗЕЛЁНО(090-герметичность): … не замечено
rc=0
$ bash …/repl/cell-red/red_hermetic_no_real_sessions.sh        # + пятый run_cell «декой»
КЛЕТКА-ОТКАЗ(090): герметичность нарушена: … /ordinary-session/zones/dev/.omp/profiles/dev/agent/sessions/--home-harness-dev-harness--/journal.jsonl;
rc=1
```

### 9.7. Семья на HEAD worktree (предметные клетки красные — нет фикса, норма; батарея обязана ловить 4/4 и на HEAD-форме строки UHOME=)

```
— red_no_home_ctx.sh: rc=1
— red_ctx_deep_no_home.sh: rc=1
— red_ctx_deep_uhome_default.sh: rc=1
— red_install_local_config.sh: rc=1
ЗЕЛЁНО(090-батарея): 4/4 обманных стабов пойманы своими клетками
— battery_stubs.sh: rc=0
— red_hermetic_no_real_sessions.sh: rc=0
ИТОГ 090: rc=1
```
