#!/usr/bin/env bash
# ПРЕД-ЗАМОРОЗОЧНОЕ КРАСНОЕ контракта 022, ветвь Проба (критик 2f11b53,
# блокер 3): check_hooks несёт ПОВЕДЕНЧЕСКУЮ push-пробу pre-push. Красное ДО
# реализации — именованное отсутствие push-фаз: today `check_hooks.sh` зелёеет
# на no-op pre-push с не-комментарной связью, потому что pre-push не проверяет
# вовсе.
#
# ВХОД: подставной корень (архив HEAD дерева, А-78 — свежий WORK вне дерева), в
# котором .githooks/pre-push — САБОТАЖ: no-op (exit 0) с не-комментарной строкой
# ссылки на scripts/check_charter.sh (текст-ветвь связи, если она появится,
# проходит; поведенческой пробы подделка не переживает — урок 016
# inert-heredoc-hook). Прогон `bash scripts/check_hooks.sh <корень>`.
# Честная реализация (с двухфазной push-пробой) ОТВЕРГАЕТ сабояжный корень:
# no-op не отвергает красный диапазон в toy bare-origin.
# СЕГОДНЯ (push-фаз нет) прогон даёт rc 0 — файл красен именованным отсутствием.
#
# СТАБ-ВХОД (Н-39 — привязка кодом фикстуры): «push-фаз нет» — сам текущий
# check_hooks.sh; его дефект наблюдаем ИМЕННО на этом входе (rc 0 на сабояжном
# pre-push). Красное живой боли, не подставной.
#
# ПОСЛЕ реализации: rc≠0 на сабояжном корне → файл зелёный; конверсия — семьёй
# case_push_proba (А-82; счёт семей объявляет пачка конверсии из факта дерева).
# Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (А-82).
#
# Коды возврата: 0 — push-фазы поведенчески живы; 1 — именованный отказ.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
WORK="$(mktemp -d /tmp/red022-faz.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT

BARRIER="$REPO/scripts/check_hooks.sh"
[ -f "$BARRIER" ] || { printf 'ОТКАЗ: барьера нет — %s\n' "$BARRIER" >&2; exit 1; }

# Подставной корень — архив коммита HEAD (дерево без мутации; скратч вне дерева).
COPY="$WORK/copy"
mkdir -p "$COPY"
git -C "$REPO" archive HEAD | tar -x -C "$COPY"

# Саботаж: no-op pre-push с НЕ-КОММЕНТАРНОЙ связью с кольцом (текст-ветвь
# проходит; судить нечего — поведенческая проба обязана это поймать).
mkdir -p "$COPY/.githooks"
cat > "$COPY/.githooks/pre-push" <<'SAB'
#!/usr/bin/env bash
# саботаж пробы push-фаз: связь объявлена, суда нет
: 'scripts/check_charter.sh'
exit 0
SAB
chmod +x "$COPY/.githooks/pre-push"

set +e
out="$(bash "$COPY/scripts/check_hooks.sh" "$COPY" 2>&1)"; rc=$?
set -e

if [ "$rc" -eq 0 ]; then
  printf 'ОТКАЗ: push-фазы отсутствуют в check_hooks — барьер зелёеет на no-op pre-push с не-комментарной связью (ветвь Проба контракта 022: двухфазная поведенческая push-проба не реализована)\n' >&2
  exit 1
fi
if ! printf '%s\n' "$out" | grep -q 'pre-push'; then
  printf 'ОТКАЗ: check_hooks красен, но не называет pre-push — отказ мимо предмета: %s\n' "$out" >&2
  exit 1
fi

exit 0
