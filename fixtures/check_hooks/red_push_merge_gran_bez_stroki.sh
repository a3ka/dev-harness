#!/usr/bin/env bash
# ПРЕД-ЗАМОРОЗОЧНОЕ КРАСНОЕ контракта 022, инвариант И-1 — merge-грань устав-дельты
# без РАЗРЕШИЛ умирает ДО origin (ветвь A: .githooks/pre-push, scoped чартер-суд
# диапазона пуша).
#
# ВХОД (форма измеренной грани 7c90925 — evil merge): merge-коммит, чья дельта к
# ПЕРВОМУ родителю несёт изменение (M) замороженного contracts/001-x.md; ОБА родителя
# файл не трогают; строки РАЗРЕШИЛ в теле merge нет. Живой пуш main в toy bare-origin.
#
# СТАБ-ВХОД (Н-39 — привязка кодом фикстуры, не прозой): «no-op хук» (exit 0). Его
# дефект наблюдаем ИМЕННО на этом входе, и только на пуш-входе: стаб пропускает
# красный merge → origin-ref ДВИГАЕТСЯ. Требовать от no-op красноты на прогоне судьи
# без пуша — требовать лжи (стаб без побочного эффекта неотличим от честного). Фаза 1
# файла подставляет стаб и проверяет наблюдаемость; фаза 2 — честный механизм по
# договору. Вход, на котором стаб неотличим от честного, не доказывает механизм —
# потому фаза 1 живёт в файле навсегда, а не до реализации.
#
# ДОГОВОР (контракт 022, ветвь A): честный .githooks/pre-push на каждую строку stdin
# судит диапазон $remote_sha..$local_sha кольцом check_charter (импорт CHARTER_LIB,
# merge — по дельте к ^1); красный → пуш умер целиком, rc≠0, ПОЛНЫЙ диагноз в причине:
# ref (полный, refs/heads/main), полный sha коммита и путь уставного файла — фаза 2
# требует все три (критик 2f11b53, блокер 4: «только путь» неотличим от слабой формы).
#
# СЕГОДНЯ (хука в дереве нет) файл красен именованным отсутствием механизма — это и
# есть предъявляемое красное: та же дельта сегодня ловится только POST-push CI
# (боль Н-79: необратимо, 2× force-push). ПОСЛЕ реализации обе фазы зелёные;
# конверсия в case_* по протоколу раннера — пачка architect (А-82).
#
# Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (А-82): раннер судит стандарт-А и краснит
# CI на каждом пуше; до заморозки предмет предъявляется ПРЯМЫМ запуском этого файла.
#
# Прогон — только свежий WORK вне дерева (А-78, Н-74).
#
# Коды возврата: 0 — ворота пройдены (стаб наблюдаем ∧ честный механизм держит вход);
#               1 — именованный отказ (механизм отсутствует либо нарушил договор).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
WORK="$(mktemp -d /tmp/red022-merge.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT

HOOK_SRC="$REPO/.githooks/pre-push"
ORIG="$WORK/origin.git"
T="$WORK/toy"

# Построение — всегда мимо хуков (hooksPath /dev/null в каждом вызове).
eg() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}
# Судимые пуши — с ЖИВЫМ core.hooksPath из конфига toy.
jg() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -c commit.gpgsign=false "$@"
}
oref() { git -C "$ORIG" rev-parse --verify -q refs/heads/main || echo ПУСТО; }
oturn() { git -C "$ORIG" update-ref refs/heads/main "$1"; }

# ── toy: основание с замороженным контрактом + bare-origin на основании ───────
mkdir -p "$T/contracts"
git init -q --bare "$ORIG"
git -C "$ORIG" symbolic-ref HEAD refs/heads/main
eg init -q -b main "$T"
eg -C "$T" config user.name Фикстура
eg -C "$T" config user.email fixture@local
printf '# подставной контракт 001 (уставной с заморозки)\n' > "$T/contracts/001-x.md"
eg -C "$T" add -A
eg -C "$T" commit -q -m 'основание: подставной замороженный контракт'
eg -C "$T" tag -a frozen/contracts/001/1 -m 'заморозка'
BASE="$(eg -C "$T" rev-parse main)"
eg -C "$T" remote add origin "$ORIG"
eg -C "$T" push -q origin main
if [ "$(oref)" != "$BASE" ]; then
  printf 'ОТКАЗ: подготовка toy сломана — основание не на origin (%s != %s)\n' "$(oref)" "$BASE" >&2
  exit 1
fi

# feat-ветка по имени: two-step (merge --no-commit по точному sha).
build_evil() {  # без аргументов; использует фиксированную ветку feat-x
  eg -C "$T" checkout -q -B feat-x main
  printf 'нейтральный предмет ветки\n' > "$T/feature.txt"
  eg -C "$T" add -A
  eg -C "$T" commit -q -m 'feature: нейтральная ветка'
  eg -C "$T" checkout -q main
  FEAT="$(eg -C "$T" rev-parse feat-x)"
  eg -C "$T" merge --no-ff --no-commit "$FEAT" >/dev/null 2>&1
  printf '\nуставная правка злом merge-грани\n' >> "$T/contracts/001-x.md"
  eg -C "$T" add -A
  eg -C "$T" commit -q -m 'land: wip/001/implementer'
  eg -C "$T" branch -D feat-x >/dev/null 2>&1
}

mkdir -p "$T/.githooks"
install_hook_from() {  # <файл-источник>
  cp "$1" "$T/.githooks/pre-push"
  chmod +x "$T/.githooks/pre-push"
  eg -C "$T" config core.hooksPath "$T/.githooks"
}

# ── фаза 1 (стаб-подстановка «no-op хук»): вход обязан стаб ловить ────────────
STAB="$WORK/stab_noop.sh"
cat > "$STAB" <<'STAB'
#!/usr/bin/env bash
# стаб «no-op хук» (контракт 022, И-1): всегда exit 0 — судьи нет вовсе.
exit 0
STAB
install_hook_from "$STAB"
build_evil
set +e
p1="$(jg -C "$T" push origin main 2>&1)"; p1_rc=$?
set -e
if [ "$p1_rc" -eq 0 ] && [ "$(oref)" != "$BASE" ]; then
  :  # стаб наблюдаем: красный merge прошёл, ref двинулся — вход доказателен
else
  printf 'ОТКАЗ: вход не ловит стаб «no-op» — пуш красного merge прошёл без движения ref (rc=%s): %s\n' "$p1_rc" "$p1" >&2
  exit 1
fi

# ── фаза 2 (честный механизм): красный merge умирает до origin ────────────────
if [ ! -f "$HOOK_SRC" ]; then
  printf 'ОТКАЗ: механизм pre-push отсутствует (.githooks/pre-push нет в дереве) — merge-грань устав-дельты без РАЗРЕШИЛ прошла бы на origin (боль Н-79: POST-push ловит только CI, необратимо)\n' >&2
  exit 1
fi
mkdir -p "$T/scripts"
cp "$REPO/scripts/check_charter.sh" "$T/scripts/"
cp "$REPO/scripts/next_id.sh" "$T/scripts/"
cp "$REPO/scripts/lib_registry.sh" "$T/scripts/"
oturn "$BASE"
eg -C "$T" reset -q --hard "$BASE"
install_hook_from "$HOOK_SRC"
build_evil
MERGE="$(eg -C "$T" rev-parse main)"
set +e
p2="$(jg -C "$T" push origin main 2>&1)"; p2_rc=$?
set -e
if [ "$p2_rc" -eq 0 ]; then
  printf 'ОТКАЗ: пуш merge-грани без РАЗРЕШИЛ прошёл (rc=0) — судьи диапазона нет: %s\n' "$p2" >&2
  exit 1
fi
if [ "$(oref)" != "$BASE" ]; then
  printf 'ОТКАЗ: пуш отвергнут, но origin-ref двинулся (%s → %s) — отвержение не атомарно\n' "$BASE" "$(oref)" >&2
  exit 1
fi
if ! printf '%s\n' "$p2" | grep -qF 'contracts/001-x.md'; then
  printf 'ОТКАЗ: отказ без именованной причины (путь уставного файла не назван): %s\n' "$p2" >&2
  exit 1
fi
if ! printf '%s\n' "$p2" | grep -qF "$MERGE"; then
  printf 'ОТКАЗ: причина не называет КОММИТ (полный sha %s отсутствует) — диагноз неполон: %s\n' "$MERGE" "$p2" >&2
  exit 1
fi
if ! printf '%s\n' "$p2" | grep -qF 'refs/heads/main'; then
  printf 'ОТКАЗ: причина не называет REF (полный refs/heads/main отсутствует) — диагноз неполон: %s\n' "$p2" >&2
  exit 1
fi

exit 0
