# ОБМАННЫЙ СТАБ s03 «синхробаза от собственного снимка»: блок 199-baza
# создаёт ветку в копии от ТЕКУЩЕГО HEAD (снимок клона), не доставляя
# авторский tip носителя; блок 199-nositel не тронут. Различающие прогоны
# батареи: ц1 (носитель продвинут после снимка — копия остаётся на
# устаревшей базе) и ц5 (свежая копия следующего дозвона не встаёт на
# принятый tip).

```bash
# 199-baza-nachalo
git switch -C "$BRANCH"
git rev-parse HEAD
# 199-baza-konec
```

```bash
# 199-nositel-nachalo
[ -z "$(git -C "$WORKTREE" status --porcelain)" ] || { printf 'ОТКАЗ: носитель грязный до приёма — не лечить\n' >&2; exit 1; }
TIP="$(bash "$ACCEPT" --source "$SOURCE" --branch "$BRANCH" --author "$AUTHOR" --root "$ROOT" | sed -n 's/.*tip=\([0-9a-f]\{40\}\).*/\1/p')"
[ -n "$TIP" ] || { printf 'ОТКАЗ: приём не дал tip\n' >&2; exit 1; }
git -C "$WORKTREE" restore --source="$TIP" --staged --worktree -- .
# 199-nositel-konec
```
