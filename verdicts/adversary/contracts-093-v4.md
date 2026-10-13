# Контракт 093, круг 4 — runtime агента: stale `.env` переживает честную установку

**Вердикт: BLOCKS.** Судимая ветка/HEAD: `origin/wip/int-093/architect`, `96ec3a5b`. Судья: `adversary`; модель по Н-270 явно сверена: `advisor → openai-codex/gpt-5.6-terra` (`config/agent_models.json`, `.omp/config.yml:51`).

## Новая живая находка: исключённый stale `.env` остаётся в `/opt/orch-agent`

`provision_agent_code()` в `ops/server/install.sh` заявляет зеркальную поставку кода агента без `.env*` и отсутствие публикационного токена у агента. Однако реальная команда:

```bash
rsync -a --delete --exclude='.env' --exclude='.env.*' --exclude='.ssh' \
  "$MAIN_DST"/ "$AGENT_ROOT"/
```

не удаляет уже существующий у адресата файл, который сам исключает. `rsync` с `--delete` защищает excluded-записи от удаления, если не указан `--delete-excluded`. Поэтому ранее оставленный `/opt/orch-agent/.env` сохраняется при честном `install.sh root`. После последующего `chown -R root:root` файл с обычным режимом `0644` по-прежнему читаем uid агента; это именно путь к публикационному credential, который И-4 обещает убрать.

Живое воспроизведение сделано **на неизменённом честном** `96ec3a5b`, в toy-root того же вида, что клетка 9:

1. До запуска создан `$AGENT_ROOT/.env` с безопасным искусственным содержимым `OLD-RW-CREDENTIAL-SENTINEL`, режим `0644`.
2. Созданы toy `$MAIN_DST/workshop`, `.git/config`, швы адресатов root-установщика и root-шмы `id/chown/chattr/lsattr`; вызван реальный `ops/server/install.sh root` с `OPS_SERVER_AGENT_ROOT=$AGENT_ROOT`.
3. Установщик вернул `rc=0`; после него файл всё ещё существует и содержит тот же sentinel:

```text
PROVED: honest provision_agent_code preserves pre-existing excluded .env in AGENT_ROOT
```

Это не чтение какого-либо станционного секрета: sentinel был создан только в `/tmp/dev-harness-verify` для пробы.

## Почему клетка 9 даёт ложный зелёный

Позитивный контроль честной клетки прошёл:

```text
bash fixtures/ops_granica/red_agent_runtime_vne_home.sh  → rc=0
ЗЕЛЁНО(093-9) … install root доставляет workshop побайтовно в мирах F/S
```

Но её мир S подменяет **только** `$AGENT_ROOT/workshop`. Она не кладёт предсуществующий `.env`/`.env.*` или иной excluded файл и после установки сверяет только sha256 `workshop` с оракулом в памяти. Следовательно честный субъект с описанным stale `.env` получает тот же зелёный результат: `workshop` обновлён побайтно, а credential-файл остаётся вне измерения.

Отдельная mutation-проба подтвердила границу уже добавленного исправления: `skip-if-exists` для `workshop` вернул клетке 9 `rc=1` в мире S (`устаревший/подменённый workshop пережил install`). Это закрывает именно предыдущий no-copy обход, но не оставленные excluded-файлы.

## Обязательные прогоны круга

| Проверка | Фактический результат |
|---|---|
| Повтор прошлой атаки: `bash fixtures/ops_granica/battery_stubs.sh` | `rc=0`; s9 `no-copy runtime` пойман клеткой 9 с `rc=1`; батарея `9/9` |
| Честный позитивный контроль клетки 9 | `rc=0` |
| Полный `bash fixtures/_krasnye_093.sh` | `rc=1` **только** ожидаемая И-8б: `red_germetichnost_semi.sh` сообщает, что раннер запущен под uid владельца станции; остальные восемь клеток и батарея зелёные |
| `bash fixtures/_krasnye_074.sh` | `rc=1`, ровно ожидаемая `k5b` (станционный `/home/harness/.local/bin/orch-loop` разошёлся с пином); честная часть `7/7`, стабы `7/7` |
| `bash fixtures/_krasnye_090.sh` | `rc=0`, все шесть клеток зелёные; прежний session-JSONL шум не воспроизвёлся |

## Маршрут починки

Нужна поведенческая негативная проба клетки 9: в мире S заранее создать читаемый stale `.env` (и отдельно `.env.*`), после реального `install.sh root` потребовать его отсутствия/недоступности uid агента. Реализация должна удалять такие старые credential-носители до/при зеркалировании (например, осознанной семантикой `rsync --delete-excluded` с нужными исключениями) либо доказуемо делать их нечитаемыми агенту. Текстовый якорь s9 и sha256 одного `workshop` этого свойства не доказывают.

Править предмет или проверку в этом круге судья не стал: `ops/server/install.sh` — implementer-зона, а `fixtures/ops_granica/red_agent_runtime_vne_home.sh` — architect-зона.
