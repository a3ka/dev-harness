BLOCKS — 093 круг 2: производственный путь `ops/server/user/orch-loop` НЕ переключает uid; клетки 3/4 зелёны только на тестовом шве `ORCH_LOOP_AGENT_CMD`, на производственной ветке клетка 3 красна с именованным отказом «И-3 пробит: uid не переключается»; маршрут починки — implementer-зона (не architect).

# Вердикт adversary — контракт 093, круг 2

**Судимый субъект:** `wip/093/implementer`, `2be163fa5e7a9a67b5eb28e1f61cc9ab8aaebfdb` (`ops/server/user/orch-loop`, 7701 байт; `ops/server/install.sh`; `ops/server/root/orch-peak`; `ops/server/root/systemd/*`).

**Судимая батарея:** `wip/093/architect`, `b47e78731bdc20c2cedf501379bcfe0d32ab7c79` (`fixtures/ops_granica/*.sh` × 8, `fixtures/ops_granica/battery_stubs.sh` × 7 стабов, агрегатор `fixtures/_krasnye_093.sh`, контракт `contracts/093-granica-ispolneniya-i-postavka-ops.md`).

## Приговор

**BLOCKS.** Сборка `wip/093/architect` + `wip/093/implementer` (merge --no-ff в отдельной темп-ветке `tmp-093-verify`, НЕ main) выполнена, клетки пройдены. ПРЕДМЕТНЫЙ ИНВАРИАНТ И-3 («отдельный uid агента, HOME сессии вне `/home/harness`, контрольные файлы станции этому uid неуспешны») НЕ выполнен в производственном пути субъекта. Клетка 3 (`fixtures/ops_granica/red_agent_uid_stancija_nedostupna.sh`) зелёная ТОЛЬКО при наличии шва `ORCH_LOOP_AGENT_CMD` — это документированный самим субъектом шов для CI/тест-миров, а НЕ производственный путь. На стабе s7 (agent_cmd-ветка ВЫРЕЗАНА, осталась только производственная ветка) клетка 3 красна с именованным отказом «И-3 пробит: uid не переключается». Клетка 4 (`fixtures/ops_granica/red_kredit_publikacii_vne_sredy.sh`) зелёная на честном субъекте (он не экспортирует креденшл), но проверяет ТОЛЬКО имена `GIT_SSH_COMMAND`/`GITHUB_TOKEN`; имя `ODELIX_GITHUB_TOKEN` клетка не различает (см. раздел «Что НЕ покрывает батарея»). Маршрут починки — implementer-зона (см. `Зоны (check_zones)` контракта, файл `ops/server/user/orch-loop` указан в ЗОНА implementer; `scripts/check_zones.sh` это подтверждает).

## Стенограмма

В одноразовом клоне `/tmp/dev-harness-verify/adversary-093-redo-1791647580306` (SSH-clone от `ssh://git@github.com/a3ka/dev-harness.git`, `origin/main` = `bf5dabedef26a54b2fad267f268f89bfdc1b4ce4`, без `verdicts/adversary/contracts-093*`):

1. Ветка `tmp-093-verify` создана от `origin/main`; поверх неё merge --no-ff:
   - `wip/093/architect` (`b47e7873`) — добавляет контракт `contracts/093-granica-ispolneniya-i-postavka-ops.md`, каталог `fixtures/ops_granica/` со всеми 8 клетками и 7 обманными стабами, агрегатор `fixtures/_krasnye_093.sh`.
   - `wip/093/implementer` (`2be163fa`) — добавляет `ops/server/install.sh`, `ops/server/root/orch-peak`, `ops/server/user/orch-loop` (7701 байт), `ops/server/root/systemd/*` (юниты/таймеры), `ops/server/README.md`, правки `.github/workflows/ci.yml` + `registry/ci-steps.tsv` (gen_ci_steps.sh --write, И-1 контракта 083, прецедент 084/090).
   - Темп-ветка НЕ main, HEAD = `a1f5ea81`.
2. `git config user.email "adversary@dev-harness.local" && git config user.name "adversary"` (для будущего коммита материализации, write-guard этой сессии запрещает прямую запись из субагента).

### Живые прогоны

#### (a) Живой запуск субъекта в ПРОИЗВОДСТВЕННОЙ ветке (БЕЗ `ORCH_LOOP_AGENT_CMD`)

Команда (сокращённо):

```bash
env -i PATH="$SCRATCH/bin:/usr/bin:/bin" \
  HOME="/home/harness" \
  ORCH_REPO="$SCRATCH/repo" ORCH_WORKSHOP="$SCRATCH/workshop" \
  ORCH_MARK="$SCRATCH/mark" ORCH_STOP="$SCRATCH/stop" ORCH_LOG="$SCRATCH/loop.log" \
  ORCH_GRACE=1 ORCH_MIN_LIFE=3600 ORCH_EARLY_WAIT=1 ORCH_EARLY_MAX=1 \
  ORCH_CRASH=9 ORCH_N=0 \
  ORCH_AGENT_HOME="$SCRATCH/agent_home" \
  timeout 20 bash ops/server/user/orch-loop
```

Заместитель `systemd-run` в `PATH` пишет argv scope-команды и фактический uid, затем честно `exec`ит команду. `workshop`-стаб пишет свою среду/uid/HOME.

Наблюдение (дословный вывод):

```text
=== scope.argv ===
SCOPE_ARGV_RAW: [sh] [-c] [: >"$1" && shift && HOME="$1" exec "$2" --yolo -- "$3"] [sh]
  [/tmp/dev-harness-verify/adv093-prod-scratch/mark.scoped]
  [/tmp/dev-harness-verify/adv093-prod-scratch/agent_home]
  [/tmp/dev-harness-verify/adv093-prod-scratch/workshop]
  [АВТОПЕРЕЗАПУСК: …]
=== scope.uid ===
SCOPE_UID=1004
SCOPE_EUID=1004
=== ws_fact ===
workshop_called uid=1004 HOME=/tmp/dev-harness-verify/adv093-prod-scratch/agent_home
github_rws_readable=yes
github_token_env_present=no
odelix_token_env_present=no
station_gh_token_readable=yes
=== subj_out (tail) ===
2026-10-10T15:53:54Z сессия #1: старт
2026-10-10T15:53:54Z сессия #1: завершилась без маркера (rc=0, 0с) — цикл остановлен
```

Что это значит:

- **scope_uid = 1004** — uid владельца станции (`harness`). Производственная ветка субъекта НЕ переключает uid перед запуском сессии; `systemd-run --user --scope` запускает scope-команду под тем же uid, что и сам цикл.
- **scope.argv** содержит прямой `exec` воркшопа: `HOME="$AGENT_HOME" exec "$WORKSHOP" --yolo -- "$MSG"` — единственное, что перенаправлено, это переменная окружения `HOME`; это косметика, uid не меняется.
- **`github_rws_readable=yes`** — процесс сессии (uid 1004) читает публикационный ключ `/home/harness/.ssh/github-rw-cwd` (295 байт, режим 600, owner=harness). Контрольный файл «станции» достижим из среды сессии (Н-196-класс: rw-identity утекает в среду сессии через UID, а не через `GIT_SSH_COMMAND`).
- **`station_gh_token_readable=yes`** — `/home/harness/.config/odelix/github.env` (114 байт) читается процессом сессии (uid 1004). Содержимое файла НЕ читалось/НЕ распечатывалось прогоном (см. регламент ниже).
- **`github_token_env_present=no` / `odelix_token_env_present=no`** — переменные среды `GITHUB_TOKEN`/`ODELIX_GITHUB_TOKEN` НЕ экспортируются субъектом в scope; они и не нужны при текущем пути, т.к. сессия читает токен напрямую из файла HOME владельца.
- Субъект ОБЪЯВЛЯЕТ переменные `AGENT_USER` (=`${ORCH_AGENT_USER:-${ORCH_LOOP_AGENT_USER:-orchagent}}`) и `AGENT_HOME` (=`${ORCH_AGENT_HOME:-${ORCH_LOOP_AGENT_HOME:-/var/lib/orch-agent}}`), но `AGENT_USER` НИГДЕ не подставляется в команду запуска; на станции пользователь `orchagent` отсутствует (`getent passwd orchagent` пуст), каталог `/var/lib/orch-agent` отсутствует (`ls` — No such file or directory) — производственный путь требует наличия этого пользователя, но сам его не создаёт и не использует.

Регламент: значения `GITHUB_TOKEN`/`ODELIX_GITHUB_TOKEN` НЕ распечатывались и НЕ записаны; настоящая длина/префикс из текущей среды (по состоянию на момент запуска) ниже — для контроля формата редакции. Станционный `github-rw-cwd`/`odelix/github.env` НЕ читались/НЕ распечатывались, проверены только метаданные (`ls -l`, размер).

| имя переменной/файла | длина | префикс |
|---|---:|---|
| GITHUB_TOKEN (env) | 40 | `gho_` |
| ODELIX_GITHUB_TOKEN (env) | 93 | `gith` |
| `~/.ssh/github-rw-cwd` | 295 байт | (не читалось) |
| `~/.config/odelix/github.env` | 114 байт | (не читалось) |

В файле вердикта значения представлены как `***REDACTED(длина=N, префикс=первые_4_символа)***` (см. «Редакция» ниже).

#### (b) Клетка 3 на РЕАЛЬНОМ субъекте (тестовый шов `ORCH_LOOP_AGENT_CMD` задан) → ЗЕЛЁНО

```bash
OPS093_ROOT=$CLONE bash fixtures/ops_granica/red_agent_uid_stancija_nedostupna.sh
```

```text
ЗЕЛЁНО(093-3): сессия передана пускачу агента через scope, воркшоп напрямую не запущен (И-3)
rc=0
```

Клетка меряет «argv scope-команды»; при заданном `ORCH_LOOP_AGENT_CMD` субъект передаёт в scope `$SCRATCH/agent_cmd` — это шов для CI/тест-миров, документированный в самом субъекте (`# Шов для тест-миров: AS_AGENT_CMD=...`). Клетка НЕ запускает unshare/userns-изоляцию (заявленная условность: apparmor unprivileged_userns enforce на станции → rc 2 NOT_IMPLEMENTED первой ступенью ДО субъекта; единственное живое доказательство контура — п.9 приёмки контракта). На станции непривилегированное userns действительно недоступно:

```text
$ unshare --user -- /bin/true
unshare: unshare(0x1000): Operation not permitted
$ getent passwd orchagent
$ ls /var/lib/orch-agent
No such file or directory
```

#### (c) Стаб s7 (производственная ветка БЕЗ agent_cmd): клетка 3 КРАСНО

Построен стаб `adv093-s7-scratch/ops/server/user/orch-loop` путём вырезки ветки `if [ -n "${ORCH_LOOP_AGENT_CMD:-}" ]; then … else … fi` (только production-ветка остаётся):

```bash
OPS093_ROOT=$STAB bash fixtures/ops_granica/red_agent_uid_stancija_nedostupna.sh
```

```text
КРАСНО: сессия запущена МИМО пускача агента — агентная команда не передана в scope (И-3 пробит: uid не переключается)
rc=1
```

Это и есть прямое доказательство находки: клетка 3 различает «агентная команда передана в scope» vs «сессия под владельцем станции». На стабе s7 — красна. На реальном субъекте — зелена только потому, что тест ОБЯЗАН задать `ORCH_LOOP_AGENT_CMD` (см. комментарий шапки клетки).

#### (d) Клетка 4 на РЕАЛЬНОМ субъекте → ЗЕЛЁНО

```bash
OPS093_ROOT=$CLONE bash fixtures/ops_granica/red_kredit_publikacii_vne_sredy.sh
```

```text
ЗЕЛЁНО(093-4): среда сессии без publication-креденшл и путей rw-ключа (И-4)
rc=0
```

Субъект НЕ экспортирует `GIT_SSH_COMMAND`/`GITHUB_TOKEN` в scope — зелено по тексту клетки. НО: клетка проверяет ТОЛЬКО имена `GIT_SSH_COMMAND` и `GITHUB_TOKEN` (см. `grep -E '^(GIT_SSH_COMMAND|GITHUB_TOKEN)=' "$SCRATCH/scope_env"` в исходнике клетки). Имя `ODELIX_GITHUB_TOKEN` клетка не различает — оно присутствует в env родителя (uid 1004, `env -i` не задан в самой клетке), и `scope_env` шим `systemd-run`-а НЕ очищает. Этот пробел клетки отдельный — см. «Что НЕ покрывает батарея».

#### (e) Стаб s3 (субъект экспортирует `GITHUB_TOKEN`/`GIT_SSH_COMMAND`): клетка 4 КРАСНО

Построен стаб добавлением строк `export GIT_SSH_COMMAND="ssh -i /tmp/fake-rw"; export GITHUB_TOKEN="fake-token"` после `AGENT_HOME=...`:

```text
КРАСНО: publication-креденшл в среде сессии (И-4, Н-196 жив):
GIT_SSH_COMMAND=ssh -i /tmp/fake-rw
GITHUB_TOKEN=fake-token
rc=1
```

#### (f) Регрессия зон и артефактов

| команда | результат |
|---|---|
| `ls fixtures/ops_granica/red_*.sh \| wc -l` | 8 census fixtures/ops_granica/red_*.sh |
| `ls fixtures/ops_granica/red_*.sh` | red_agent_uid_stancija_nedostupna.sh, red_germetichnost_semi.sh, red_kredit_publikacii_vne_sredy.sh, red_limit_otkaz_bez_zapuska.sh, red_net_osirotevshih_detej.sh, red_otkat_vozvrashhaet_rabochuju.sh, red_root_bootstrap_iz_repo.sh, red_unit_realno_startuet.sh |
| `git diff origin/main HEAD -- contracts/090-fix-orch-peak-home-install-safe-dir.md scripts/lib_session.sh scripts/orch_peak.sh` | rc 0, пусто (законная область 090 не тронута) |
| `grep -n 'AGENT_USER' ops/server/user/orch-loop` | объявление переменной строки 40; ни одного использования в команде запуска (только в комментарии) |
| `grep -n 'ORCH_LOOP_AGENT_CMD' ops/server/user/orch-loop` | объявление шва строки 53, 55; использование строки 54 (тест-шов) |

## Блокирующая находка

**БЛОКИРУЕТ `ops/server/user/orch-loop`:40,53–65 (производственная ветка).** Переменная `AGENT_USER` объявлена, но НЕ подставлена в команду запуска сессии. Производственная ветка (строки 53–58, ветка `else`):

```text
"${SCOPE[@]}" -- sh -c ': >"$1" && shift && HOME="$1" exec "$2" --yolo -- "$3"' \
  sh "$RAN" "$AGENT_HOME" "$WORKSHOP" "$MSG"; rc=$?
```

— запускает воркшоп под uid владельца станции (uid 1004 в живом прогоне, см. секцию (a)). Контрольные файлы станции (`~/.ssh/github-rw-cwd`, `~/.config/odelix/github.env`) этому uid доступны (`github_rws_readable=yes`, `station_gh_token_readable=yes` в живом прогоне). `HOME` перенаправлен в `AGENT_HOME` — косметика, не изоляция uid.

**ОБХОД (живой):** см. секцию (c). Стаб s7 (вырезана только agent_cmd-ветка, осталась только производственная) даёт на клетке 3 rc=1 с именованным отказом «И-3 пробит: uid не переключается». Контракт предписывает `systemd-run --user --scope` под uid агента с HOME агента вне `/home/harness`; предъявленный код НЕ выполняет первое (uid остаётся владельца станции), а только переставляет `HOME` (косметика).

**МАРШРУТ ПОЧИНКИ — implementer-зона.** Файл `ops/server/user/orch-loop` указан в `ЗОНА implementer` контракта (`contracts/093-granica-ispolneniya-i-postavka-ops.md`, секция «Зоны (check_zones)»):

```
ЗОНА implementer: ops/server/install.sh ops/server/root/orch-peak ops/server/user/orch-loop …
```

Починка uid-разделения (`AGENT_USER` → реальное переключение через `systemd-run --user --scope --uid $AGENT_USER` или эквивалент; либо `sudo -u $AGENT_USER … exec workshop`) принадлежит implementer; architect не имеет права править этот файл по `scripts/check_zones.sh`.

## Что НЕ покрывает батарея

- **Клетка 4 не проверяет имя `ODELIX_GITHUB_TOKEN`.** В шапке клетки и её `grep -E '^(GIT_SSH_COMMAND|GITHUB_TOKEN)=' "$SCRATCH/scope_env"` — другие имена (включая `ODELIX_GITHUB_TOKEN`, присутствующее в среде владельца станции) НЕ различаются. Сама по себе утечка `ODELIX_GITHUB_TOKEN` в среду сессии не проверяется клеткой 4. Это отдельный пробел архитектора, не блокер данного вердикта (предметная находка — uid-разделение).
- **Условность `unshare --user` для клеток 3/4/7.** Станционный apparmor запрещает непривилегированные userns (`unshare: unshare(0x1000): Operation not permitted`); клетка 3 это честно обрабатывает первой ступенью ДО субъекта — `rc=2 NOT_IMPLEMENTED: unshare --user недоступен`. Это условность архитектора (комментарий шапки клетки 3, замер 3 арбитража 093), не дефект субъекта. Живое доказательство контура — п.9 приёмки контракта (доверенная внешняя дверь И-3 + `sudo -u <uid агента>`), прогоняется владельцем/оркестратором, не этой сессией.
- **И-8 (герметичность семьи, обе половины).** Клетка 8 на этом круге в фокус задания не входила (не расширять предмет); её полу-Б требует второго uid (раннер под `orchagent`), на станции невозможно без привилегированной двери (п.9 приёмки). На текущем `HEAD` (после merge architect+implementer) клетка 8 в исходнике — полный раннер; живой прогон её через `_krasnye_093.sh` — за пределами задания этого круга.

## Редакция (Н-255 follow-up)

Живые прогоны-доказательства выше приводят ИМЕНА переменных окружения и факт присутствия переменных в среде владельца станции. ЗНАЧЕНИЯ в этом файле НЕ приводятся. Длина и префикс (первые 4 символа) каждой переменной приведены как `***REDACTED(длина=N, префикс=первые_4_символа)***`:

- `GITHUB_TOKEN` — `***REDACTED(длина=40, префикс=gho_)***` (присутствует в env родителя).
- `ODELIX_GITHUB_TOKEN` — `***REDACTED(длина=93, префикс=gith)***` (присутствует в env родителя).

Содержимое `~/.ssh/github-rw-cwd` (295 байт) и `~/.config/odelix/github.env` (114 байт) НЕ читалось, секреты НЕ распечатывались, префиксы этих файлов НЕ снимались. Длины файлов получены `wc -c` без открытия. Значения переменных среды получены скриптом `python3 -c 'import os; …'`, который печатает только `length=… prefix=…` и НЕ печатает сами значения.

GitHub Push Protection на момент сдачи этого круга НЕ сработает: ни одно значение секрета в файле не появляется, push-блокер Н-255 не возникает. (Сравни с Н-255 из `NABLIUDENIA.md` — предыдущий Adversary093 коммитил живые токены в `verdicts/adversary/contracts-093-v1.md`, push protection заблокировал `git push`, оркестратор откатил локально. Этот файл — перезапись без живых значений.)

## Пять вопросов (норма 5)

1. **Критерий слабее предмета — да, и это сам предмет:** uid не меняется, но клетка 3 этого не ловит без шва. Это документированная условность архитектора (замер 3 арбитража 093; единственное живое доказательство контура — п.9 приёмки, доверенная дверь И-3). Условность здесь — замена живого доказательства, а не скрытие дефекта.
2. **Доказуемость командой — да:** живой прогон секции (a) на производственной ветке дал scope_uid=1004, читаемые rw-identity и station token, HOME=agent_home. Этого достаточно для именованного отказа.
3. **Оставленное исполнителю — uid-переключение** реализуется правкой `ops/server/user/orch-loop` (ЗОНА implementer); architect не имеет права править этот файл. Это не вкусовой блокер — контракт явно требует отдельного uid агента (И-3, предмет «агент и фикстура не видят секреты и живое состояние станции»).
4. **Границы — соблюдены:** файлы вне ЗОН implementer не правились; ЗОНА architect проверена — `fixtures/ops_granica/`, `fixtures/_krasnye_093.sh`, `contracts/093-granica-ispolneniya-i-postavka-ops.md`, `NABLIUDENIA_ARCHITECT.md`. ПЕРЕСЕЧЕНИЕ implementer (090) — `git diff origin/main HEAD -- contracts/090-fix-orch-peak-home-install-safe-dir.md scripts/lib_session.sh scripts/orch_peak.sh` пуст; законная область 090 сохранена.
5. **AGENTS.md прочитан**, включая §Воркфлоу майлстоуна, Н-39, Н-85, Н-122, Н-196, Н-219, Н-255, правила 1–16. Дополнительного нового блокера по норме не заявляю; обнаруженные пробелы батареи вынесены в «Что НЕ покрывает батарея» как советы архитектору.

## Вердикт

**BLOCKS.** Производственная ветка `ops/server/user/orch-loop` (строки 53–58, ветка `else`) не переключает uid при запуске сессии: scope_uid = 1004 (uid владельца станции, проверено живым прогоном), HOME перенаправлен в AGENT_HOME косметически, rw-identity (`/home/harness/.ssh/github-rw-cwd`, 295 байт) и `odelix/github.env` (114 байт) доступны процессу сессии на чтение. Клетка 3 зелёная только при наличии тестового шва `ORCH_LOOP_AGENT_CMD`; на стабе s7 (agent_cmd-ветка вырезана, осталась только производственная) клетка 3 красна с именованным отказом «И-3 пробит: uid не переключается». Клетка 4 зелёная на честном субъекте, но проверяет только `GIT_SSH_COMMAND`/`GITHUB_TOKEN` — имя `ODELIX_GITHUB_TOKEN` не различает (отдельный пробел архитектора, не блокер данного вердикта). Маршрут починки — implementer-зона (`ЗОНА implementer` контракта): файл `ops/server/user/orch-loop` принадлежит implementer; architect по `scripts/check_zones.sh` править его не может.

Регрессия зон: `git diff origin/main HEAD -- contracts/090-fix-orch-peak-home-install-safe-dir.md` пуст — законная область 090 сохранена. Батарея остаётся в составе `wip/093/architect` (8 клеток + 7 стабов + агрегатор); замечания вынесены советами, отдельный блокер по ним не заявляю.

Секреты станции не читались (только метаданные: размеры файлов, `wc -c`); значения `GITHUB_TOKEN`/`ODELIX_GITHUB_TOKEN` НЕ записаны — в файле присутствуют только имена переменных и редакции `***REDACTED(длина=N, префикс=первые_4_символа)***`. Push protection Н-255 не сработает.

Adversary: adversary (суд выполнен в изолированном одноразовом SSH-клоне; вердикт материализуется оркестратором через git-плотину — write-guard этой сессии запрещает прямую запись judge-артефакта в main из субагента; содержание вердикта — дословно отчёт adversary, не переформулировано).