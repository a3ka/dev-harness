# ПРИЧИНА: поведенческая проба связи — чистый staged отклонён
#
# Находка (б) адверсария (sniffer-форма): pre-commit нюхает среду пробы через
# `case "$(pwd)" …` и в `/tmp/*|*/mktemp-*` отдаёт фальшивый отказ (rc≠0, постоянное
# «ОТКАЗ: имя с control-символом…»), вне — честно зовёт судью scripts/check_staged.sh.
# Закрыто ЧИСТОЙ ФАЗОЙ двухфазной пробы (РЕШЕНИЕ 67fb3b1, §(в) замер 5): барьер в своём
# поведенческом scratch делает `mktemp -d` (TMPDIR=$WORK по умолчанию), pwd попадает в
# `*/mktemp-*` — sniffer красит ЧИСТЫЙ staged → «чистый staged отклонён». Каждый вход
# красен СВОИМ: sniffer ловится фазой 1, forged (case_huk_forged_output) — фазой 2.
#
# Sniffer-остаток с дискриминатором «в реальном корне — exit 0, иначе exec судья»
# (объявленный стандарт-А в шапке scripts/check_hooks.sh) — не закрывается пробой; ловец —
# доверенность среды/ревью коммиченного хука, вне 016.
set -uo pipefail
R="$WORK/meh"
# shellcheck disable=SC1091
. "$(dirname "$0")/_mehanizm.sh"
mehanizm "$R"

# Зелёный контроль: полный честный механизм → rc 0
out_green="$("$BARRIER" "$R" 2>&1)"
if [ "$?" -ne 0 ]; then
  printf 'ОТКАЗ: зелёный контроль не зелёный: %s\n' "$out_green" >&2; exit 1
fi

# Порча: sniffer-форма. Ключ — pwd каталога пробы (mktemp-шаблон или /tmp).
# В реальном репозитории зовёт судью; в toy-каталоге пробы — фальшивый отказ.
cat > "$R/.githooks/pre-commit" <<'SNIF'
#!/usr/bin/env bash
case "$(pwd)" in
  /tmp/*|*/mktemp-*)
    printf 'ОТКАЗ: имя с control-символом: sniffer_toy_refuse\n' >&2
    exit 1
    ;;
  *)
    exec bash "$(dirname "$0")/../scripts/check_staged.sh" "$(git rev-parse --show-toplevel)"
    ;;
esac
SNIF
chmod +x "$R/.githooks/pre-commit"

# Красное предъявление: фаза 1 «чистый staged» ловит sniffer-toy
out_red="$("$BARRIER" "$R" 2>&1 || true)"
if ! printf '%s\n' "$out_red" | grep -q 'чистый staged отклонён'; then
  printf 'ОТКАЗ: фикстура sniffer-toy не предъявила причину «чистый staged отклонён»: %s\n' \
    "$out_red" >&2
  exit 1
fi
