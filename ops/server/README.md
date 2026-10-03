# ops/server — серверная обвязка станции (единый источник в репо)

Контракт 074: 9 файлов обвязки лежат в этом каталоге побайтно (сверяются
sha256 с живой станцией — `bash ops/server/install.sh verify`), установщик
ставит их из репо на `/home/harness/.local/bin/orch-loop` и
`/usr/local/sbin/orch-peak` + `/etc/systemd/system/*`, а `README` — инвентарь
для сессии, которая раньше обвязку не видела.

## Инвентарь механизмов (9 файлов, копии побайтно со станции 2026-10-02)

- **orch-loop** — обёртка хоста: перезапуск ведущей сессии по маркеру
  (`/tmp/dev-harness-verify/orch-restart`); живёт в tmux-сессии `orch` под
  harness. user-часть, режим 755, путь — `~/.local/bin/orch-loop`.
- **orch-peak** — пауза оркестратора на пиковые часы z.ai (команды
  `warn`, `stop`, `start`, `check`, `ctx`); root-часть, режим 755, путь —
  `/usr/local/sbin/orch-peak`, владелец `root:root` (harness не имеет права
  менять).
- **orch-peak@.service** — oneshot-шаблон systemd: `ExecStart=/usr/local/sbin/orch-peak %i`;
  параметр `%i` — имя действия (`warn`, `stop`, `start`, `ctx`).
- **orch-peak-warn.timer** — Mon..Fri 13:40 Asia/Singapore: предупреждение в
  панель оркестратора за 20 мин до пика.
- **orch-peak-stop.timer** — Mon..Fri 14:00 Asia/Singapore: проверка «всё
  закоммичено и отправлено», при необходимости ожидание, затем гашение omp.
- **orch-peak-start.timer** — Mon..Fri 18:00 Asia/Singapore: ввод команды
  запуска цикла в ту же панель (`cd ~/dev-harness && orch-loop`).
- **orch-peak-reenable.timer** — однократное включение паузы 2026-10-08 00:00
  Asia/Singapore (Persistent=true).
- **orch-peak-reenable.service** — oneshot-сервис: включает
  `orch-peak-warn/stop/start.timer`, выключает сам reenable.
- **orch-ctx.timer** — `*:0/15` (раз в 15 мин): сторож контекста ведущей
  сессии; > CTX_SOFT (300 000) — сообщение в панель, > CTX_HARD (500 000) —
  проверка сохранения с отсрочкой, потом маркер перезапуска.

Все юниты — `root:root` 644 в `/etc/systemd/system/`; `Persistent=false` на
регулярных таймерах.

## Журналы и состояние

- `~/orch-loop.log` — вывод обёртки `orch-loop` под harness (старт/стоп
  сессии, маркер, перезапуск).
- `/var/log/orch-peak.log` — вызовы `orch-peak` под root (warn/stop/start/ctx,
  send-keys в панель, маркер).
- `~/orch-peak-report.txt` — отчёт по несохранённому на момент stop'а.
- `/var/lib/orch-peak/{pane,state}` — состояние орк-peak (найденная панель
  tmux, прочие служебные файлы).
- `journalctl -u 'orch-peak@*' -t systemd` — журнал systemd по юнитам
  orch-peak (запуск таймером).

## Включение/выключение

**Включить** (root): `systemctl enable --now orch-peak-warn.timer
orch-peak-stop.timer orch-peak-start.timer`. До этого однократно
`systemctl enable --now orch-peak-reenable.timer` (если пауза ещё не
включена).

**Выключить** (root): `systemctl disable --now orch-peak-warn.timer
orch-peak-stop.timer orch-peak-start.timer`. Не трогать `orch-ctx.timer` —
сторож контекста работает независимо от пиковой паузы.

**Стоп обёртки** (harness): `touch ~/orch-loop.stop` — следующая итерация
цикла `orch-loop` снимет файл и завершится с rc 0.

## Касание сессии (send-keys / гашение omp / маркер)

- **send-keys в панель** — `orch-peak` через `tmux send-keys -t $pane -l "..."
+ Enter` отправляет сообщения владельцу (warn, «всё закоммичено?»,
  подсказка перезапуска). Панель с циклом ищется `find_pane` (PID-дерево
  `orch-loop` ↔ tmux-панели), запоминается в `/var/lib/orch-peak/pane`.
- **гашение omp** — kill процесса `omp --profile` (pgrep по PID родителя
  orch-loop, дочерние через `pgrep -P`): SIGTERM с ожиданием, затем SIGKILL.
  Маркер при этом не ставится — цикл сам проверяет наличие процесса и при
  отсутствии выходит.
- **маркер** — `/tmp/dev-harness-verify/orch-restart`. Ставится
  ЕДИНСТВЕННОЙ дверью `scripts/orch_restart.sh` (контракт 072) либо
  сторожем контекста `orch-peak ctx` при CTX_HARD. Обёртка `orch-loop`
  видит маркер, ждёт GRACE (20 с) и инициирует рестарт с чистым контекстом;
  новая сессия читает HANDOFF и продолжает автономно.

## Настройка станции (harness@148.251.131.204)

Параметры окружения, без которых обвязка не работает или работает не на ту
сессию:

- **Пользователь `harness` без sudo** — все root-операции (orch-peak,
  systemd-юниты, /var/log, /var/lib) делаются под root отдельным вызовом
  `sudo bash ops/server/install.sh root`; под harness sudo не нужен.
- **Rootless Docker** — `docker context` указывает на `rootless`; харнесс
  не нуждается в `/var/run/docker.sock`.
- **Node 26** — `node --version` начинается с `v26.`; `omp` запускается
  `node --enable-source-maps .../omp.js --yolo --profile dev ...`.
- **omp по пину** — версия `omp` зафиксирована в `package.json` (`omp`),
  без `^v` — никакого автоматического обновления.
- **`gh` вход как a3ka** — `gh auth status` показывает `a3ka`; PR открывается
  `gh pr create`, токен берётся из `/home/harness/dev-harness/.env`
  абсолютным путём (`~/` гвардом переписывается).
- **`GITHUB_TOKEN` в `.env`** — файл `/home/harness/dev-harness/.env` хранит
  `GITHUB_TOKEN` для `gh`/`git push`; коммитится только `.env.example`.
- **Клоны `~/odelix/*`** — соседние каталоги `~/odelix/odx-stack`,
  `~/odelix/odx-rshnn`, и т. п. (по числу пилотных репозиториев), на них
  может указывать пилот A3 — обвязка не лезет в них сама, но `orch-loop`
  стартует `workshop --yolo` именно в текущем `~/dev-harness`.

## Установка из репо

```sh
# user-часть (под harness): ~/.local/bin/orch-loop, режим 755
bash ops/server/install.sh user

# root-часть (под root): /usr/local/sbin/orch-peak + 7 юнитов /etc/systemd/system/
sudo bash ops/server/install.sh root

# сверка установленного с репо (любой пользователь, только читает):
# rc 0 + «сверка: 9/9» — установленное == репо; rc != 0 — зовёт файл по имени.
bash ops/server/install.sh verify
```

Шов `OPS_SERVER_SRC` (умолчание — каталог скрипта) позволяет подставить
другой источник; `OPS_SERVER_BIN_DST`, `OPS_SERVER_SBIN_DST`,
`OPS_SERVER_ETC_DST` — другие адресаты (тесты, песочница).

## Чего обвязка НЕ делает

- Не коммитит и не пушит в репо (только проверяет «всё ли закоммичено» в
  `stop`).
- Не открывает PR и не зовёт владельца напрямую — только `send-keys` в
  панель tmux.
- Не редактирует `~/odelix/*` (обвязка знает только `~/dev-harness`).
- Не сжимает роль и не перезапускает сессию изнутри майлстоуна — это
  решение оркестратора после `done` пары майлстоунов.