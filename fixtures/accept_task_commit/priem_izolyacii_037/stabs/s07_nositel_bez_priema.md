# ОБМАННЫЙ СТАБ s07 «блок приёма — no-op»: чистота проверяется, но приём
# не исполняется вовсе — ветка не двинута, носитель не синхронизирован,
# ceremony имитируется проверкой без действия. Различающие прогоны батареи:
# ц2 (честная сдача обязана продвинуть ветку), ц4 и ц5.

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
: 'приём не нужен — носитель и так носит ветку'
# 199-nositel-konec
```
