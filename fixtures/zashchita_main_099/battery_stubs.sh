#!/usr/bin/env bash
# Обманный стаб-пак 099 (контракт 099, Н-39/А-398): двенадцать обманных
# субъектов (круг 3: t99-m9 spawn_agent-нога удалён арбитражем 099 — она не
# судила ни одного реального запроса; добавлены t99-m10..m13 на хук З-7),
# каждый привязан к клетке и входу, на котором его дефект НАБЛЮДАЕМ
# (привязка живёт В ЭТОМ КОДЕ, не в прозе контракта).
# Пойман = связанная клетка против стаба даёт rc 1 (КРАСНО); rc 0 и rc 2 — НЕ пойман.
#
# # стаб | дефект обмана | ловящая клетка и вход
# t99-m1 проверка всегда зелёная (всегда ДОПУСК)   red_perehodnyj_gheit_perechen (вход в: неизвестный отказ l7)
# t99-m2 судит head PR, не объект слияния          red_pr_dopusk_sudit_merge_resultat (вход а: head зелёный, у объекта нет результата)
# t99-m3 вернул «sha ∈ origin/main» (семантика 087) red_pr_dopusk_obekt_vne_main (объект вне main обязан допускаться)
# t99-m4 теги не сверяет                            red_pr_dopusk_soderzhatelnye_cheki (локальный тег вне origin)
# t99-m5 сравнивает КОЛИЧЕСТВО красных проверок    red_perehodnyj_gheit_perechen (вход д: то же число, иной текст)
# t99-m6 land_agent --pr двигает main (поведение 016) red_land_agent_pr_rezhim (main обязан быть не двинут)
# t99-m7 дверь судьи всегда rc 0                    red_sud_model_dver_spavna (вход 2: спавн на модели автора)
# t99-m8 --verdict всегда rc 0                      red_sud_model_materializatsija (вход 1: критик на glm)
# t99-m10 хук task: всегда undefined (не судит)     red_huk_task_spavna (вход 1: task-спавн без явного agent не отказан)
# t99-m11 хук task: "task" В алфавите                red_huk_task_spavna (вход 1: тихий дефолт допущен)
# t99-m12 хук task: batch-элементы не судятся       red_huk_task_spavna (вход 4: один плохой среди хороших прошёл)
# t99-m13 хук task: битый input → undefined          red_huk_task_spavna (вход 8: fail-closed нет)
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAM="$HERE"
Z99_BASE="${Z99_BASE:-/tmp/dev-harness-verify}"
command -v bash >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет bash\n' >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v curl >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет curl\n' >&2; exit 2; }
command -v sed >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет sed\n' >&2; exit 2; }

WORK="$Z99_BASE/zashchita-099-stubs-$$-${RANDOM}"
mkdir -p "$WORK" || { printf 'ОТКАЗ: мир стабов не строится\n' >&2; exit 2; }
trap 'rm -rf "$WORK"' EXIT

# ── производные стабы pr_dopusk ──
PR_ARGS='root=""; pr=""
while [ $# -gt 0 ]; do
  case "$1" in
    --pr) pr="${2:-}"; shift 2 ;;
    *) root="$1"; shift ;;
  esac
done
[ -n "$pr" ] || pr=7
api="${PR_DOPUSK_API:-}"
merge_sha=""
if [ -n "$api" ]; then
  merge_sha="$(curl -fsS -m 5 "$api/repos/o/r/pulls/$pr" 2>/dev/null | sed -n "s/.*\"merge_commit_sha\":\"\([0-9a-f]*\)\".*/\1/p" | head -1)"
  head_sha="$(curl -fsS -m 5 "$api/repos/o/r/pulls/$pr" 2>/dev/null | sed -n "s/.*\"head\":{\"sha\":\"\([0-9a-f]*\)\".*/\1/p" | head -1)"
fi
[ -n "$merge_sha" ] || merge_sha="$(git -C "$root" rev-parse pr/099/demo 2>/dev/null || echo unknown)"'

mkdir -p "$WORK/t99-m1"
cat > "$WORK/t99-m1/pr_dopusk.sh" <<EOF
#!/usr/bin/env bash
# t99-m1 порча: проверка всегда зелёная — не глядя судит «ДОПУСК»
set -uo pipefail
$PR_ARGS
printf 'ДОПУСК: %s %s\n' "\$pr" "\$merge_sha"
exit 0
EOF

mkdir -p "$WORK/t99-m2"
cat > "$WORK/t99-m2/pr_dopusk.sh" <<EOF
#!/usr/bin/env bash
# t99-m2 порча: судит head PR (зелёный у head), объект слияния не смотрит
set -uo pipefail
$PR_ARGS
if [ -n "\$api" ] && [ -n "\$head_sha" ]; then
  body="\$(curl -fsS -m 5 "\$api/repos/o/r/commits/\$head_sha/check-runs" 2>/dev/null)"
  if printf '%s' "\$body" | grep -q '"conclusion":"failure"'; then
    printf 'ОТКАЗ: обязательная проверка красна (head)\n' >&2; exit 1
  fi
fi
printf 'ДОПУСК: %s head\n' "\$pr"
exit 0
EOF

mkdir -p "$WORK/t99-m3"
cat > "$WORK/t99-m3/pr_dopusk.sh" <<EOF
#!/usr/bin/env bash
# t99-m3 порча: вернул требование «sha ∈ origin/main» (семантика 087)
set -uo pipefail
$PR_ARGS
git -C "\$root" merge-base --is-ancestor "\$merge_sha" origin/main 2>/dev/null \\
  || { printf 'ОТКАЗ: коммит %s не на origin/main — CI по нему не запускался\n' "\$merge_sha" >&2; exit 1; }
printf 'ДОПУСК: %s\n' "\$pr"
exit 0
EOF

mkdir -p "$WORK/t99-m4"
cat > "$WORK/t99-m4/pr_dopusk.sh" <<EOF
#!/usr/bin/env bash
# t99-m4 порча: теги не сверяет (пропускает локальный тег вне origin)
set -uo pipefail
$PR_ARGS
printf 'ДОПУСК: %s %s (теги не смотрю)\n' "\$pr" "\$merge_sha"
exit 0
EOF

mkdir -p "$WORK/t99-m5"
cat > "$WORK/t99-m5/pr_dopusk.sh" <<EOF
#!/usr/bin/env bash
# t99-m5 порча: сравнивает КОЛИЧЕСТВО красных проверок с числом строк базы
set -uo pipefail
$PR_ARGS
base_n=0
if [ -f "\$root/config/transition_defects_099.tsv" ]; then
  base_n=\$(grep -c . "\$root/config/transition_defects_099.tsv" || true)
fi
red=0
if [ -n "\$api" ] && [ -n "\$merge_sha" ]; then
  red=\$(curl -fsS -m 5 "\$api/repos/o/r/commits/\$merge_sha/check-runs" 2>/dev/null | grep -o '"conclusion":"failure"' | wc -l)
fi
if [ "\$red" -ne "\$base_n" ]; then
  printf 'ОТКАЗ: число красных (%s) != базе (%s)\n' "\$red" "\$base_n" >&2; exit 1
fi
printf 'ДОПУСК: %s по счёту\n' "\$pr"
exit 0
EOF

mkdir -p "$WORK/t99-m6"
cat > "$WORK/t99-m6/land_agent.sh" <<'EOF'
#!/usr/bin/env bash
# t99-m6 порча: поведение 016 — merge прямо в main, ветка снесена, но напечатал PREREADY
set -uo pipefail
branch=""; wt=""; root=""
while [ $# -gt 0 ]; do
  case "$1" in
    --branch) branch="${2:-}"; shift 2 ;;
    --worktree) wt="${2:-}"; shift 2 ;;
    --root) root="${2:-}"; shift 2 ;;
    *) shift ;;
  esac
done
git -C "$root" merge --no-ff -m "land: $branch" "$branch" >/dev/null 2>&1
git -C "$root" branch -D "$branch" >/dev/null 2>&1
printf 'PREREADY branch=pr/099/demo sha=%s\n' "$(git -C "$root" rev-parse HEAD)"
exit 0
EOF

mkdir -p "$WORK/t99-m7" "$WORK/t99-m8"
cat > "$WORK/t99-m7/check_sud_model.sh" <<'EOF'
#!/usr/bin/env bash
# t99-m7 порча: дверь судьи всегда зелёная (rc 0 на любом спавне)
printf 'СУДЬЯ СВОЕЙ МОДЕЛИ: ok\n'
exit 0
EOF
cat > "$WORK/t99-m8/check_sud_model.sh" <<'EOF'
#!/usr/bin/env bash
# t99-m8 порча: --verdict всегда rc 0 — вердикт материализуется без сверки трассы
printf 'СУДЬЯ СВОЕЙ МОДЕЛИ: verdict ok\n'
exit 0
EOF
mkdir -p "$WORK/t99-m10" "$WORK/t99-m11" "$WORK/t99-m12" "$WORK/t99-m13"

# Общий честный каркас стабов хука (мутация — одна строка на стаб, помечена ПОРЧА);
# каркас байт-в-байт повторяет суд предмета, чтобы дефект был наблюдаем ТОЛЬКО
# на своём входе (Н-39).
cat > "$WORK/t99-m10/spawn-guard.ts" <<'EOF'
// t99-m10 порча: хук ничего не судит — всегда undefined; дефект наблюдаем
// ровно на входе 1 клетки (task-спавн без явного agent не отказан).
type PiLike10 = { on?: (name: string, handler: (...args: unknown[]) => unknown) => unknown };
export default function register(pi: unknown): void {
  if (typeof pi !== 'object' || pi === null) return;
  const p = pi as PiLike10;
  if (typeof p.on !== 'function') return;
  p.on('tool_call', () => undefined);
}
EOF

cat > "$WORK/t99-m11/spawn-guard.ts" <<'EOF'
// t99-m11 порча: тихий дефолт "task" признаётся допустимым типом (нет ветки
// явного отказа task и task добавлен в алфавит); на остальных входах честен.
// Дефект наблюдаем ровно на входе 1 клетки.
import { readFileSync as rf11 } from 'node:fs';
import { join as j11 } from 'node:path';
const HARNESS11 = ['scout', 'task']; // ПОРЧА: task в алфавите
type Block11 = { block: true; reason: string };
function isObject11(v: unknown): v is Record<string, unknown> {
  return typeof v === 'object' && v !== null && !Array.isArray(v);
}
function alphabet11(cwd: string): ReadonlySet<string> {
  const cfg = JSON.parse(rf11(j11(cwd, 'config', 'agent_models.json'), 'utf8')) as unknown;
  if (!isObject11(cfg) || !isObject11(cfg.roles)) throw new Error('нет roles');
  const set = new Set<string>(Object.keys(cfg.roles));
  for (const t of HARNESS11) set.add(t);
  return set;
}
function judge11(input: unknown, alphabet: ReadonlySet<string>): Block11 | undefined {
  let items: unknown[];
  if (isObject11(input) && 'tasks' in input) {
    if (!Array.isArray(input.tasks)) throw new Error('tasks не массив');
    items = input.tasks;
  } else {
    items = [input];
  }
  for (const item of items) {
    if (!isObject11(item)) throw new Error('битый элемент');
    const agent = item.agent;
    if (agent === undefined) return { block: true, reason: 'ОТКАЗ: спавн без явного agent: task' };
    if (typeof agent !== 'string') throw new Error('agent не строка');
    if (!alphabet.has(agent)) return { block: true, reason: `ОТКАЗ: тип агента вне алфавита: ${agent}` };
    // ПОРЧА: ветки agent === 'task' НЕТ — тихий дефолт идёт в алфавит
  }
  return undefined;
}
type PiLike11 = { on?: (name: string, handler: (...args: unknown[]) => unknown) => unknown };
export default function register(pi: unknown): void {
  if (!isObject11(pi)) return;
  const p = pi as PiLike11;
  if (typeof p.on !== 'function') return;
  p.on('tool_call', (call: unknown): Block11 | undefined => {
    try {
      if (!isObject11(call)) return undefined;
      if (call.toolName !== 'task') return undefined;
      return judge11(call.input, alphabet11(process.cwd()));
    } catch {
      return { block: true, reason: 'ОТКАЗ: спавн-страж сломан (fail-closed, Н-270)' };
    }
  });
}
EOF

cat > "$WORK/t99-m12/spawn-guard.ts" <<'EOF'
// t99-m12 порча: batch-форма (input.tasks[]) не судится вовсе — только flat;
// дефект наблюдаем ровно на входе 4 клетки (один плохой среди хороших прошёл).
import { readFileSync as rf12 } from 'node:fs';
import { join as j12 } from 'node:path';
const HARNESS12 = ['scout'];
type Block12 = { block: true; reason: string };
function isObject12(v: unknown): v is Record<string, unknown> {
  return typeof v === 'object' && v !== null && !Array.isArray(v);
}
function alphabet12(cwd: string): ReadonlySet<string> {
  const cfg = JSON.parse(rf12(j12(cwd, 'config', 'agent_models.json'), 'utf8')) as unknown;
  if (!isObject12(cfg) || !isObject12(cfg.roles)) throw new Error('нет roles');
  const set = new Set<string>(Object.keys(cfg.roles));
  for (const t of HARNESS12) set.add(t);
  set.delete('task');
  return set;
}
function judge12(input: unknown, alphabet: ReadonlySet<string>): Block12 | undefined {
  let items: unknown[];
  if (isObject12(input) && 'tasks' in input) {
    if (!Array.isArray(input.tasks)) throw new Error('tasks не массив');
    items = input.tasks;
  } else {
    items = [input];
  }
  for (const item of items) {
    if (!isObject12(item)) throw new Error('битый элемент');
    const agent = item.agent;
    if (agent === undefined) return { block: true, reason: 'ОТКАЗ: спавн без явного agent: task' };
    if (typeof agent !== 'string') throw new Error('agent не строка');
    if (agent === 'task') return { block: true, reason: `ОТКАЗ: спавн без явного agent: ${agent}` };
    if (!alphabet.has(agent)) return { block: true, reason: `ОТКАЗ: тип агента вне алфавита: ${agent}` };
  }
  return undefined;
}
type PiLike12 = { on?: (name: string, handler: (...args: unknown[]) => unknown) => unknown };
export default function register(pi: unknown): void {
  if (!isObject12(pi)) return;
  const p = pi as PiLike12;
  if (typeof p.on !== 'function') return;
  p.on('tool_call', (call: unknown): Block12 | undefined => {
    try {
      if (!isObject12(call)) return undefined;
      if (call.toolName !== 'task') return undefined;
      const input = call.input;
      if (isObject12(input) && Array.isArray(input.tasks)) return undefined; // ПОРЧА: batch не судится
      return judge12(input, alphabet12(process.cwd()));
    } catch {
      return { block: true, reason: 'ОТКАЗ: спавн-страж сломан (fail-closed, Н-270)' };
    }
  });
}
EOF

cat > "$WORK/t99-m13/spawn-guard.ts" <<'EOF'
// t99-m13 порча: fail-closed НЕТ — исключение/битый вход дают undefined;
// дефект наблюдаем ровно на входе 8 клетки (битый input проходит молча).
import { readFileSync as rf13 } from 'node:fs';
import { join as j13 } from 'node:path';
const HARNESS13 = ['scout'];
type Block13 = { block: true; reason: string };
function isObject13(v: unknown): v is Record<string, unknown> {
  return typeof v === 'object' && v !== null && !Array.isArray(v);
}
function alphabet13(cwd: string): ReadonlySet<string> {
  const cfg = JSON.parse(rf13(j13(cwd, 'config', 'agent_models.json'), 'utf8')) as unknown;
  if (!isObject13(cfg) || !isObject13(cfg.roles)) throw new Error('нет roles');
  const set = new Set<string>(Object.keys(cfg.roles));
  for (const t of HARNESS13) set.add(t);
  set.delete('task');
  return set;
}
function judge13(input: unknown, alphabet: ReadonlySet<string>): Block13 | undefined {
  let items: unknown[];
  if (isObject13(input) && 'tasks' in input) {
    if (!Array.isArray(input.tasks)) throw new Error('tasks не массив');
    items = input.tasks;
  } else {
    items = [input];
  }
  for (const item of items) {
    if (!isObject13(item)) throw new Error('битый элемент');
    const agent = item.agent;
    if (agent === undefined) return { block: true, reason: 'ОТКАЗ: спавн без явного agent: task' };
    if (typeof agent !== 'string') throw new Error('agent не строка');
    if (agent === 'task') return { block: true, reason: `ОТКАЗ: спавн без явного agent: ${agent}` };
    if (!alphabet.has(agent)) return { block: true, reason: `ОТКАЗ: тип агента вне алфавита: ${agent}` };
  }
  return undefined;
}
type PiLike13 = { on?: (name: string, handler: (...args: unknown[]) => unknown) => unknown };
export default function register(pi: unknown): void {
  if (!isObject13(pi)) return;
  const p = pi as PiLike13;
  if (typeof p.on !== 'function') return;
  p.on('tool_call', (call: unknown): Block13 | undefined => {
    try {
      if (!isObject13(call)) return undefined;
      if (call.toolName !== 'task') return undefined;
      return judge13(call.input, alphabet13(process.cwd()));
    } catch {
      return undefined; // ПОРЧА: fail-closed нет — битый вход молчит
    }
  });
}
EOF

chmod +x "$WORK"/t99-m*/{pr_dopusk.sh,land_agent.sh,check_sud_model.sh} 2>/dev/null \
  || chmod +x "$WORK"/t99-m*/*.sh

# прогон: стаб пойман ⟺ связанная клетка на стабе даёт rc 1
itog=0; caught=0; total=0
progon() { # <маркер> <клетка>
  local marker="$1" cell="$2" rc
  [ -d "$WORK/$marker" ] || { printf 'ОТКАЗ: стаб %s не построен\n' "$marker" >&2; itog=2; return; }
  [ -f "$FAM/$cell" ] || { printf 'ОТКАЗ: клетка %s не найдена\n' "$cell" >&2; itog=2; return; }
  total=$((total+1))
  D99_SUBJECTS_DIR="$WORK/$marker" Z99_SPAWN_GUARD="$WORK/$marker/spawn-guard.ts" \
    bash "$FAM/$cell" >/dev/null 2>&1
  rc=$?
  if [ "$rc" -eq 1 ]; then
    caught=$((caught+1)); printf -- '— %s пойман (%s)\n' "$marker" "$cell" >&2
  else
    printf '— %s НЕ ПОЙМАН (rc=%s, клетка %s) — дефект жив\n' "$marker" "$rc" "$cell" >&2
    itog=1
  fi
}

# Н-39: каждый стаб — к входу, где его дефект наблюдаем (таблица в шапке)
progon t99-m1 red_perehodnyj_gheit_perechen.sh
progon t99-m2 red_pr_dopusk_sudit_merge_resultat.sh
progon t99-m3 red_pr_dopusk_obekt_vne_main.sh
progon t99-m4 red_pr_dopusk_soderzhatelnye_cheki.sh
progon t99-m5 red_perehodnyj_gheit_perechen.sh
progon t99-m6 red_land_agent_pr_rezhim.sh
progon t99-m7 red_sud_model_dver_spavna.sh
progon t99-m8 red_sud_model_materializatsija.sh
progon t99-m10 red_huk_task_spavna.sh
progon t99-m11 red_huk_task_spavna.sh
progon t99-m12 red_huk_task_spavna.sh
progon t99-m13 red_huk_task_spavna.sh

printf 'стаб-пак: %s/%s поймано\n' "$caught" "$total"
[ "$total" -eq 12 ] || { printf 'ОТКАЗ: стабов прогнано %s, ожидалось 12\n' "$total" >&2; exit 2; }
[ "$itog" -eq 0 ] || exit "$itog"
exit 0
