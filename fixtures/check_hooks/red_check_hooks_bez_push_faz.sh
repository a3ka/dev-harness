#!/usr/bin/env bash
# ПРЕД-ЗАМОРОЗОЧНОЕ КРАСНОЕ контракта 022, ветвь Проба (критик 2f11b53 блокер 3;
# круг 3 — единственный блокер e91c99a): check_hooks несёт ПОВЕДЕНЧЕСКУЮ
# ДВУХФАЗНУЮ push-пробу pre-push, и фаза 2 пробы САМА судит тройку диагноза —
# полный ref, полный sha красного коммита, путь (арбитраж b43d7a0 п.2: «Push-проба
# check_hooks (ветвь Проба, фаза 2) — тоже все три, не "путь и sha"»).
#
# ВХОД-1 (no-op): подставной корень (архив HEAD дерева, А-78 — свежий WORK вне
# дерева), в котором .githooks/pre-push — САБОТАЖ: no-op (exit 0) с не-комментарной
# строкой связи с scripts/check_charter.sh (текст-ветвь связи проходит;
# поведенческой пробы подделка не переживает — урок 016 inert-heredoc-hook).
# Убивает форму «push-фаз нет»: честная проба обязана отвергнуть корень — no-op
# не отвергает красный диапазон.
# ВХОД-2 (немой отказ — закрытие последней дыры, e91c99a): подставной корень, в
# котором pre-push пропускает чистый диапазон и отвергает красный НЕМОЙ причиной
# — без полного ref, полного sha и пути в выводе. Убивает слабую форму «push-фазы
# есть, тройка не проверяется» (ОБХОД e91c99a: в красной фазе проверяются только
# rc пуша и неподвижность origin-ref): такая проба вход-2 пропускает, честная
# (ассертит все три поля) — корень отвергает. Закрытый конечный набор форм
# push-пробы (нет фаз / фазы без тройки / честные) покрыт двумя входами.
#
# СТАБ-ВХОД (Н-39 — привязка кодом фикстуры, не прозой): СЛАБЫЙ БАРЬЕР —
# исполняемая слабая форма ОБХОДА e91c99a: push-фазы поведенчески живы (фаза 1 —
# чистый диапазон проходит; фаза 2 — красный отвергнут ∧ origin-ref неподвижен),
# вывод отказа НЕ судится. Дефект стаба наблюдаем ИМЕННО на входе-2 и только на
# нём; на входе-1 стаб ведёт себя честно (no-op им ловится) — требовать его
# красноты там значит требовать лжи в диагнозе. Фаза 1 гоняет стаб по ОБОИМ
# входам и требует (вход-1 → rc≠0) ∧ (вход-2 → rc 0): наблюдаемость входов кодом.
# Фаза живёт в файле навсегда, а не до реализации (форма red_mera 021).
#
# СЕГОДНЯ (push-фаз нет) предмет даёт rc 0 на обоих входах — файл красен
# именованным отсутствием (умирает фаза 2; текст «Красного сейчас» контракта).
# ПОСЛЕ реализации: rc≠0 на обоих корнях → файл зелёный; конверсия — семьёй
# case_push_proba (А-82; счёт семей объявляет пачка конверсии из факта дерева).
# Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (А-82). Прогон — только свежий WORK
# вне дерева (А-78, Н-74).
#
# Фазы: 1 — стаб-подстановка слабого барьера на оба входа (2 ассерта); 2 —
# предмет, вход-1 no-op (rc≠0 ∧ «pre-push»); 3 — предмет, вход-2 немой отказ
# (rc≠0 ∧ «pre-push»). Итого 6 ассертов; каждый вход красен СВОИМ предъявлением.
#
# Коды возврата: 0 — push-фазы поведенчески живы И фаза 2 судит тройку;
#               1 — именованный отказ.
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

# ВХОД-1: саботаж no-op — связь объявлена (не-комментарно), суда нет.
write_noop() {
  cat > "$COPY/.githooks/pre-push" <<'SAB'
#!/usr/bin/env bash
# саботаж пробы push-фаз: связь объявлена, суда нет
: 'scripts/check_charter.sh'
exit 0
SAB
  chmod +x "$COPY/.githooks/pre-push"
}

# ВХОД-2: немой отказ — чистый диапазон пропускает, красный отвергает БЕЗ тройки
# (причина не содержит ни refs/…, ни sha, ни пути уставного файла).
write_nemoj() {
  cat > "$COPY/.githooks/pre-push" <<'NEMOJ'
#!/usr/bin/env bash
# немой отказ: судит диапазон по путям устава, диагноз не называет ничего
: 'scripts/check_charter.sh'
zero=0000000000000000000000000000000000000000
while read -r lref lsha rref rsha; do
  [ -n "${rsha:-}" ] || { printf 'ОТКАЗ: устав-дельта без РАЗРЕШИЛ\n' >&2; exit 1; }
  [ "$rsha" != "$zero" ] || { printf 'ОТКАЗ: устав-дельта без РАЗРЕШИЛ\n' >&2; exit 1; }
  if git diff --name-only "$rsha" "$lsha" 2>/dev/null \
     | grep -Eq '^(AGENTS\.md|ROADMAP\.md|(contracts|plans)/)'; then
    printf 'ОТКАЗ: устав-дельта без РАЗРЕШИЛ\n' >&2
    exit 1
  fi
done
exit 0
NEMOJ
  chmod +x "$COPY/.githooks/pre-push"
}

# СТАБ-БАРЬЕР (Н-39): слабая форма «push-фазы есть, тройка не проверяется».
STAB="$WORK/stab_check_hooks_bez_trojjki.sh"
cat > "$STAB" <<'STABB'
#!/usr/bin/env bash
# СТАБ-БАРЬЕР (Н-39): слабая форма ОБХОДА e91c99a — двухфазная push-проба жива
# поведенчески (фаза 1: чистый диапазон проходит; фаза 2: красный отвергнут ∧
# origin-ref неподвижен), вывод отказа НЕ судится — тройку проба не ассертит.
set -uo pipefail
ROOT="${1:?корень}"
HOOK="$ROOT/.githooks/pre-push"
[ -f "$HOOK" ] || { printf 'ОТКАЗ: pre-push отсутствует\n' >&2; exit 1; }
[ -x "$HOOK" ] || { printf 'ОТКАЗ: pre-push не исполняем\n' >&2; exit 1; }
grep -q 'scripts/check_charter.sh' "$HOOK" || { printf 'ОТКАЗ: pre-push без связи с кольцом\n' >&2; exit 1; }
W="$(mktemp -d "${TMPDIR:-/tmp}/stabfaz.XXXXXX")" || exit 1
trap 'rm -rf "$W"' EXIT
mkdir -p "$W/hooks"
cp "$HOOK" "$W/hooks/pre-push"
eg() { GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }
jg() { GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -c commit.gpgsign=false -c core.hooksPath="$W/hooks" "$@"; }
O="$W/origin.git"; T="$W/toy"
git init -q --bare "$O"
git -C "$O" symbolic-ref HEAD refs/heads/main
eg init -q -b main "$T"
eg -C "$T" config user.name Фикстура
eg -C "$T" config user.email fixture@local
mkdir -p "$T/contracts"
printf '# подставной контракт 001 (уставной с заморозки)\n' > "$T/contracts/001-x.md"
eg -C "$T" add -A
eg -C "$T" commit -q -m 'основание: подставной замороженный контракт'
eg -C "$T" tag -a frozen/contracts/001/1 -m 'заморозка'
eg -C "$T" remote add origin "$O"
eg -C "$T" push -q origin main
printf 'нейтральный предмет\n' > "$T/feature.txt"
eg -C "$T" add -A
eg -C "$T" commit -q -m 'нейтральный коммит'
jg -C "$T" push -q origin main >/dev/null 2>&1; prc=$?
[ "$prc" -eq 0 ] || { printf 'ОТКАЗ: фаза 1 — чистый диапазон отвергнут pre-push\n' >&2; exit 1; }
GREEN="$(git -C "$O" rev-parse --verify refs/heads/main)"
printf '\nуставная дельта без строки\n' >> "$T/contracts/001-x.md"
eg -C "$T" add -A
eg -C "$T" commit -q -m 'красный: устав-дельта M без РАЗРЕШИЛ'
jg -C "$T" push origin main >/dev/null 2>&1; prc=$?
[ "$prc" -ne 0 ] || { printf 'ОТКАЗ: фаза 2 — красный диапазон прошёл pre-push\n' >&2; exit 1; }
NOW="$(git -C "$O" rev-parse --verify refs/heads/main)"
[ "$NOW" = "$GREEN" ] || { printf 'ОТКАЗ: фаза 2 — origin-ref двинулся\n' >&2; exit 1; }
printf 'ok: push-фазы живы (rc и неподвижность), тройка не судится\n'
exit 0
STABB
chmod +x "$STAB"

# ── фаза 1 (стаб-подстановка слабого барьера): входы обязаны различать ────────
write_noop
set +e
s1="$(bash "$STAB" "$COPY" 2>&1)"; s1_rc=$?
set -e
if [ "$s1_rc" -eq 0 ]; then
  printf 'ОТКАЗ: слабый барьер зелёен на входе-1 (no-op) — поведенческих фаз нет вовсе, вход-1 перестал различать: %s\n' "$s1" >&2
  exit 1
fi
write_nemoj
set +e
s2="$(bash "$STAB" "$COPY" 2>&1)"; s2_rc=$?
set -e
if [ "$s2_rc" -ne 0 ]; then
  printf 'ОТКАЗ: слабый барьер красен на входе-2 (немой отказ) — вход-2 перестал различать слабую и честную формы: %s\n' "$s2" >&2
  exit 1
fi

# ── фаза 2 (предмет, вход-1 no-op): push-фазы отсутствуют именованно ──────────
write_noop
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

# ── фаза 3 (предмет, вход-2 немой отказ): фаза 2 пробы судит ТРОЙКУ ───────────
# Слабая форма (ОБХОД e91c99a) проходит вход-1 и умирает именно здесь: немой
# отказ даёт rc≠0 и неподвижность, но не тройку — проба без трёх ассертов
# корень пропускает.
write_nemoj
set +e
out="$(bash "$COPY/scripts/check_hooks.sh" "$COPY" 2>&1)"; rc=$?
set -e
if [ "$rc" -eq 0 ]; then
  printf 'ОТКАЗ: push-фаза 2 не судит тройку диагноза — барьер зелёеет на немом отказе pre-push (слабая форма «фазы без тройки» вердикта e91c99a: rc пуша и неподвижность origin-ref проверены, полный ref/sha/путь — нет)\n' >&2
  exit 1
fi
if ! printf '%s\n' "$out" | grep -q 'pre-push'; then
  printf 'ОТКАЗ: check_hooks красен, но не называет pre-push — отказ мимо предмета: %s\n' "$out" >&2
  exit 1
fi

exit 0
