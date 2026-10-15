#!/usr/bin/env bash
# Клетка И-4а «эталон стандарта зелен» (контракт 103). Complior-подобный
# toy (origin+main, профиль двух слоёв по .harness/*, lockfile, честные
# команды, AGENTS.md, карта map+rules, .env.example, .env игнорируется, пин
# харнеса) → check_project_standard.sh --repo R: rc 0 и stderr БЕЗ строк
# «ОТКАЗ: стандарт:». Обман (ложный отказ на эталоне) → красно.
#
# Источник слоя проекта (Frontier И-4: --layer-root > HARNESS_PROJECT_LAYER_ROOT
# > R) судится на том же эталоне (A103-1/Рв96-4 ST7):
#   prioritet  — слой в R; --layer-root R при HARNESS_PROJECT_LAYER_ROOT=<несуществующий>
#                → rc 0 (обман «env > CLI» → ищет слой в пустоте → rc 1 → красно);
#   sloj-vne   — слой ВЫНЕСЕН из R в <мир>/layer; HARNESS_PROJECT_LAYER_ROOT=<мир>/layer
#                без CLI → rc 0 (обман «слой всегда R» → rc 1 → красно);
#   sloj-vne-cli — тот же вынесенный слой через --layer-root при враждебном env → rc 0;
#   env-vrag (негатив) — вынесенный слой, env=<несуществующий>, без CLI → rc 1 и
#                строка «ОТКАЗ: стандарт: profil:» (слой действительно не найден);
#   pustoj-repo (негатив, A103-2/Рв96-5) — `--repo ""` → rc 2 и NOT_IMPLEMENTED,
#                без строки «ОТКАЗ: стандарт:» (нечем проверить, не авария shell).
# Клетка прогоняет все сценарии, каждый красен своей строкой.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t103_standard)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: standart-etalon: предмет отсутствует: scripts/check_project_standard.sh\n' >&2; exit 1; }
W="$(_t103_complior i4a)" || exit 2
trap '_t103_cleanup "$W"' EXIT
R="$W/repo"
VRAG="$W/hostile-layer"   # не существует намеренно
itog=0

zelen() {  # <id> <описание> -- <команда…>: ждём rc 0 и ни одной строки отказа
  local id="$1" what="$2" out rc; shift 2
  out="$(cd / && "$@" 2>&1)"; rc=$?
  if [ "$rc" -ne 0 ]; then
    printf 'КРАСНО: i4а/%s: %s: rc=%s (ждали 0): %s\n' "$id" "$what" "$rc" "$out" >&2; itog=1; return
  fi
  if printf '%s\n' "$out" | grep -Fq 'ОТКАЗ: стандарт:'; then
    printf 'КРАСНО: i4а/%s: %s: rc 0 при строках отказа: %s\n' "$id" "$what" "$out" >&2; itog=1; return
  fi
  printf -- '— i4а/%s: rc=0, отказов нет\n' "$id"
}

# эталон как есть (слой в R)
zelen etalon    'эталон' env HARNESS_PROJECT_LAYER_ROOT="$R" bash "$SUBJ" --repo "$R"
# приоритет CLI над env — рецепт A103-1
zelen prioritet '--layer-root R при враждебном env' env HARNESS_PROJECT_LAYER_ROOT="$VRAG" bash "$SUBJ" --repo "$R" --layer-root "$R"

# слой вынесен из репо (как Complior/odelix-stack): в R остаётся каталог
# .harness/registry (contracts.tsv), файла слоя там больше нет
mkdir -p "$W/layer/.harness/registry" || exit 2
mv "$R/.harness/registry/harness-project.json" "$W/layer/.harness/registry/harness-project.json" || exit 2
[ ! -e "$R/.harness/registry/harness-project.json" ] || { printf 'КРАСНО: i4а: мир сломан — слой остался в R\n' >&2; exit 2; }
zelen sloj-vne     'слой вне R через env'  env HARNESS_PROJECT_LAYER_ROOT="$W/layer" bash "$SUBJ" --repo "$R"
zelen sloj-vne-cli 'слой вне R через --layer-root при враждебном env' env HARNESS_PROJECT_LAYER_ROOT="$VRAG" bash "$SUBJ" --repo "$R" --layer-root "$W/layer"

# негатив: слоя по env нет, CLI не дан → именно profil, rc 1
out="$(cd / && HARNESS_PROJECT_LAYER_ROOT="$VRAG" bash "$SUBJ" --repo "$R" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s\n' "$out" | grep -Fq 'ОТКАЗ: стандарт: profil:'; then
  printf 'КРАСНО: i4а/env-vrag: слой по env не найден, а отказа profil нет (rc=%s): %s\n' "$rc" "$out" >&2; itog=1
else
  printf -- '— i4а/env-vrag: rc=1, profil назван\n'
fi

# негатив: пустой --repo — rc 2 «нечем проверить», не авария shell (A103-2)
out="$(cd / && HARNESS_PROJECT_LAYER_ROOT="$R" timeout 20 bash "$SUBJ" --repo "" 2>&1)"; rc=$?
if [ "$rc" -ne 2 ] || ! printf '%s\n' "$out" | grep -Fq 'NOT_IMPLEMENTED' || printf '%s\n' "$out" | grep -Fq 'ОТКАЗ: стандарт:'; then
  printf 'КРАСНО: i4а/pustoj-repo: --repo "" дал rc=%s (ждали 2 и NOT_IMPLEMENTED): %s\n' "$rc" "$out" >&2; itog=1
else
  printf -- '— i4а/pustoj-repo: rc=2, NOT_IMPLEMENTED\n'
fi
exit "$itog"
