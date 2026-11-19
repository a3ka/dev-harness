# ОБМАННЫЙ СТАБ s06 «update-ref достаточно для носителя»: блок проверяет
# чистоту и принимает сдачу, но НЕ синхронизирует файлы/индекс носителя с
# принятым tip. Различающий прогон батареи: ц4 — после приёма носитель
# обязан стоять на принятом tip с чистым индексом/деревом; стаб оставляет
# закономерное расхождение.

```bash
# 199-baza-nachalo
git fetch --no-tags "$WORKTREE" "refs/heads/$BRANCH"
git switch -C "$BRANCH" FETCH_HEAD
git rev-parse HEAD
# 199-baza-konec
```

```bash
# 199-nositel-nachalo
[ -z "$(git -C "$WORKTREE" status --porcelain)" ] || { printf 'ОТКАЗ: носитель грязный до приёма — не лечить\n' >&2; exit 1; }
TIP="$(bash "$ACCEPT" --source "$SOURCE" --branch "$BRANCH" --author "$AUTHOR" --root "$ROOT" | sed -n 's/.*tip=\([0-9a-f]\{40\}\).*/\1/p')"
[ -n "$TIP" ] || { printf 'ОТКАЗ: приём не дал tip\n' >&2; exit 1; }
# 199-nositel-konec
```
