# ОБМАННЫЙ СТАБ s05 «носитель лечится без проверки чистоты»: блок приёма
# принимает и синхронизирует носитель, но не останавливается на грязном ДО
# приёма носителе — чужая незакоммиченная работа затирается, приём
# исполняется вопреки стопу. Различающий прогон батареи: ц3 — грязные байты
# носителя обязаны сохраниться, сдача не принимается.

```bash
# 199-baza-nachalo
git fetch --no-tags "$WORKTREE" "refs/heads/$BRANCH"
git switch -C "$BRANCH" FETCH_HEAD
git rev-parse HEAD
# 199-baza-konec
```

```bash
# 199-nositel-nachalo
TIP="$(bash "$ACCEPT" --source "$SOURCE" --branch "$BRANCH" --author "$AUTHOR" --root "$ROOT" | sed -n 's/.*tip=\([0-9a-f]\{40\}\).*/\1/p')"
[ -n "$TIP" ] || { printf 'ОТКАЗ: приём не дал tip\n' >&2; exit 1; }
git -C "$WORKTREE" restore --source="$TIP" --staged --worktree -- .
# 199-nositel-konec
```
