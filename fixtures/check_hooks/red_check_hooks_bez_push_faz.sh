#!/usr/bin/env bash
# ПРЕД-ЗАМОРОЗОЧНОЕ КРАСНОЕ контракта 022, ветвь Проба (критик 2f11b53 блокер 3;
# круг 3 — e91c99a; круг 4 — РЕШЕНИЕ арбитража f712e6e): check_hooks несёт
# ПОВЕДЕНЧЕСКУЮ ДВУХФАЗНУЮ push-пробу pre-push, и фаза 2 пробы САМА судит
# ТРОЙКУ диагноза — полный ref, полный sha красного коммита, путь (арбитраж
# b43d7a0 п.2). Форма различения — ПЕР-ПОЛЕВАЯ (f712e6e, третий рецидив Н-75
# «барьер судит подмножество»): для каждого поля тройки существует вход,
# наблюдающий именно его отсутствие; пережить все входы может только проба,
# судящая каждое поле. Вход «молчат все три» (вход-2 круга 3) наблюдает лишь
# дизъюнкцию «судится хотя бы одно» — шесть слабых форм проходят его (замер 1
# f712e6e) — потому удалён как строго более слабый, чем диагональ (замер 2;
# п.3 РЕШЕНИЯ: носителем различения считаться не может).
#
# ВХОД-1 (no-op): подставной корень (архив HEAD дерева, А-78 — свежий WORK вне
# дерева), в котором .githooks/pre-push — САБОТАЖ: no-op (exit 0) с не-комментарной
# строкой связи с scripts/check_charter.sh (текст-ветвь связи проходит;
# поведенческой пробы подделка не переживает — урок 016 inert-heredoc-hook).
# Убивает форму «push-фаз нет»: честная проба обязана отвергнуть корень — no-op
# не отвергает красный диапазон.
# ДИАГОНАЛЬ «по-одному-полю-нет» (п.1 f712e6e): три подставных корня; в каждом
# pre-push пропускает чистый диапазон и отвергает красный причиной с ДВУМЯ
# полями тройки — вход-ref (полный sha и путь, молчит о полном ref), вход-sha
# (ref и путь, без sha), вход-path (ref и sha, без пути). Проба краснеет на
# входе H_без_i ⇔ судит поле i — пережить все три способна только полная
# тройка (замер 2 f712e6e: диагональ точная, без единого исключения).
#
# СТАБ-ПРИВЯЗКА (Н-39 — кодом этого файла, не прозой контракта): базовый стаб
# (судит только rc пуша и неподвижность origin-ref) КРАСЕН на входе-1 — no-op
# ловит даже слабейшая проба; ассерты входа-1 не меняются (п.2 f712e6e).
# Диагональ 3×3 (п.4): стаб «судит всё, кроме поля j» ЗЕЛЁНЫЙ на своём входе j
# (дефект наблюдаем именно там) и КРАСНЫЙ на двух чужих (стаб жив); полная
# матрица — цена < 2 с по замеру 3 f712e6e. Стаб-фазы живут в файле навсегда,
# а не до реализации (форма red_mera 021).
#
# СЕГОДНЯ (push-фаз нет) предмет даёт rc 0 на всех четырёх корнях — файл красен
# именованным отсутствием (умирает фаза 2; текст «Красного сейчас» контракта).
# ПОСЛЕ реализации: rc≠0 на всех четырёх корнях → файл зелёный; конверсия —
# семьёй case_push_proba (А-82; счёт семей объявляет пачка конверсии из факта
# дерева). Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (А-82). Прогон — только
# свежий WORK вне дерева (А-78, Н-74).
#
# Фазы: 1 — стабы: вход-1 базовым стабом красен + диагональ 3×3 (свой вход
# зелёен, чужие красны); 2 — предмет, вход-1 no-op (rc≠0 ∧ «pre-push»);
# 3 — предмет, диагональ: на каждом из трёх корней rc≠0 ∧ «pre-push». Итого
# ассертов 1+9+2+6=18; каждый вход красен СВОИМ предъявлением.
#
# Коды возврата: 0 — push-фазы поведенчески живы И фаза 2 судит каждое поле
#               тройки; 1 — именованный отказ.
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

# ДИАГОНАЛЬНЫЕ ВХОДЫ (п.1 f712e6e): H_без_<поле> — чистый диапазон проходит,
# красный отвергнут причиной с ДВУМЯ полями тройки; о названном поле причина
# молчит (о полном ref / полном sha / пути).
write_diagonal() {
  cat > "$COPY/.githooks/pre-push" <<DIAG
#!/usr/bin/env bash
# диагональный вход H_без_${1}: причина молчит о поле «${1}» (арбитраж f712e6e)
: 'scripts/check_charter.sh'
MOLCHIT='${1}'
zero=0000000000000000000000000000000000000000
while read -r lref lsha rref rsha; do
  [ -n "\${rsha:-}" ] || rsha="\$zero"
  [ "\$rsha" != "\$zero" ] || rsha="\$(git hash-object -t tree /dev/null)"
  paths="\$(git diff --name-only "\$rsha" "\$lsha" 2>/dev/null | grep -E '^(AGENTS\.md|ROADMAP\.md|(contracts|plans)/)' || true)"
  [ -z "\$paths" ] && continue
  p="\$(printf '%s\n' "\$paths" | head -n 1)"
  case "\$MOLCHIT" in
    ref)  printf 'ОТКАЗ: устав-дельта без РАЗРЕШИЛ: коммит %s, путь %s\n' "\$lsha" "\$p" >&2 ;;
    sha)  printf 'ОТКАЗ: устав-дельта без РАЗРЕШИЛ: %s, путь %s\n' "\$rref" "\$p" >&2 ;;
    path) printf 'ОТКАЗ: устав-дельта без РАЗРЕШИЛ: %s, коммит %s\n' "\$rref" "\$lsha" >&2 ;;
  esac
  exit 1
done
exit 0
DIAG
  chmod +x "$COPY/.githooks/pre-push"
}

# СТАБ-БАРЬЕР (Н-39): параметрическая слабая форма push-пробы — двухфазная
# поведенчески жива (фаза 1: чистый диапазон проходит; фаза 2: красный отвергнут
# ∧ origin-ref неподвижен), из полей тройки судятся только перечисленные в
# аргументе 2 (⊆ {ref sha path}); пусто — базовая слабая форма e91c99a.
# Стаб «судит всё, кроме j» зелёен на входе j, красен на чужих (п.4 f712e6e).
STAB="$WORK/stab_check_hooks_bez_trojjki.sh"
cat > "$STAB" <<'STABB'
#!/usr/bin/env bash
# СТАБ-БАРЬЕР (Н-39): слабая форма push-пробы — судит rc пуша, неподвижность
# origin-ref и только перечисленные поля тройки (аргумент 2).
set -uo pipefail
ROOT="${1:?корень}"
FIELDS="${2:-}"
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
RED="$(git -C "$T" rev-parse --verify HEAD)"
jg -C "$T" push origin main >"$W/krasny.out" 2>&1; prc=$?
[ "$prc" -ne 0 ] || { printf 'ОТКАЗ: фаза 2 — красный диапазон прошёл pre-push\n' >&2; exit 1; }
NOW="$(git -C "$O" rev-parse --verify refs/heads/main)"
[ "$NOW" = "$GREEN" ] || { printf 'ОТКАЗ: фаза 2 — origin-ref двинулся\n' >&2; exit 1; }
for f in $FIELDS; do
  case "$f" in
    ref)  tok='refs/heads/main';    what='полного ref' ;;
    sha)  tok="$RED";               what='полного sha' ;;
    path) tok='contracts/001-x.md'; what='пути' ;;
  esac
  grep 'ОТКАЗ' "$W/krasny.out" | grep -qF "$tok" \
    || { printf 'ОТКАЗ: фаза 2 — причина без %s\n' "$what" >&2; exit 1; }
done
printf 'ok: push-фазы живы (rc и неподвижность), судятся поля: %s\n' \
  "${FIELDS:-нет — только rc и неподвижность}"
exit 0
STABB
chmod +x "$STAB"

# ── фаза 1 (стабы, Н-39): входы обязаны различать ─────────────────────────────
# Вход-1 базовым стабом — красен: no-op ловит даже проба, судящая только rc и
# неподвижность (ассерты входа-1 не меняются, п.2 f712e6e).
write_noop
set +e
s1="$(bash "$STAB" "$COPY" 2>&1)"; s1_rc=$?
set -e
if [ "$s1_rc" -eq 0 ]; then
  printf 'ОТКАЗ: слабый барьер зелёен на входе-1 (no-op) — поведенческих фаз нет вовсе, вход-1 перестал различать: %s\n' "$s1" >&2
  exit 1
fi
# Диагональ 3×3 (п.4 f712e6e): стаб «судит всё, кроме j» зелёен на СВОЁМ входе
# j, красен на двух чужих.
for i in ref sha path; do
  write_diagonal "$i"
  for j in ref sha path; do
    case "$j" in
      ref)  SS='sha path' ;;
      sha)  SS='ref path' ;;
      path) SS='ref sha' ;;
    esac
    set +e
    s="$(bash "$STAB" "$COPY" "$SS" 2>&1)"; src=$?
    set -e
    if [ "$j" = "$i" ]; then
      if [ "$src" -ne 0 ]; then
        printf 'ОТКАЗ: стаб «судит всё, кроме %s» красен на СВОЁМ входе %s — дефект стаба там не наблюдаем: %s\n' "$j" "$i" "$s" >&2
        exit 1
      fi
    else
      if [ "$src" -eq 0 ]; then
        printf 'ОТКАЗ: стаб «судит всё, кроме %s» зелёен на ЧУЖОМ входе %s — стаб мёртв, различения нет: %s\n' "$j" "$i" "$s" >&2
        exit 1
      fi
    fi
  done
done

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

# ── фаза 3 (предмет, диагональ «по-одному-полю-нет»): фаза 2 пробы судит ──────
# КАЖДОЕ поле тройки. Проба, не судящая поле i, зелёен на входе H_без_i и умирает
# именно там; честная (все три) красна на всех трёх (f712e6e п.1).
for i in ref sha path; do
  write_diagonal "$i"
  set +e
  out="$(bash "$COPY/scripts/check_hooks.sh" "$COPY" 2>&1)"; rc=$?
  set -e
  if [ "$rc" -eq 0 ]; then
    printf 'ОТКАЗ: push-фаза 2 не судит поле «%s» — барьер зелёеет на входе, чья причина молчит именно о нём (диагональ f712e6e: пер-полевое различение)\n' "$i" >&2
    exit 1
  fi
  if ! printf '%s\n' "$out" | grep -q 'pre-push'; then
    printf 'ОТКАЗ: check_hooks красен (вход-%s), но не называет pre-push — отказ мимо предмета: %s\n' "$i" "$out" >&2
    exit 1
  fi
done

exit 0
