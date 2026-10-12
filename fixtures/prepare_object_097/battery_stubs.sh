#!/usr/bin/env bash
# Обманный стаб-пак 097 (контракт 097, Н-39): порчи честной модели
# ../accept_publish_094/model/dover.sh (семья 094 НЕ правится — Решение 4
# контракта 097: стаб = КОПИЯ модели + подстановка по якорю + хвостовой маркер
# «# t97-mN», по которому порча проверяема). Каждая порча привязана к клетке,
# на чьём входе её дефект НАБЛЮДАЕМ (привязка — в ЭТОМ коде, не в прозе):
#
# # стаб | ослабляемая защита | порча (якорь → подстановка) | ловящая клетка
# m1  политика из кандидата (харнес)  show BASE→CAND       red_kandidat_ne_vybiraet_politiku.sh (А-1)
# m2  политика из кандидата (проект)  show BASE→CAND       red_podmena_istochnika_politiki.sh (А-2)
# m3  merge sha не печатается         printf → :           red_proizvodstvennyj_profil_M.sh (А-3)
# m4  родитель кандидата потерян      « -p "$CAND"» удалён  red_proizvodstvennyj_profil_M.sh (А-3)
# m5  prepare двигает target          + update-ref main    red_proizvodstvennyj_profil_M.sh (А-3)
# m6  задача не входит в id           «"$TASK" » выброшен   red_sostav_obekta_razlichim.sh (А-4)
# m7  пустой allowlist молчит         die грамматики → :   red_politika_bez_targetbranches.sh (А-6)
# m8  чужая строка политики принята   «*) die» → «*) :»    red_oba_profilya.sh (А-5)
# m9  автор merge не orchestrator     GIT_AUTHOR_NAME      red_identity_i_sankcii_podgotovki.sh (А-7)
# m10 коммиттер не orchestrator       GIT_COMMITTER_NAME   red_identity_i_sankcii_podgotovki.sh (А-7)
# m0  пустышка БЕЗ порчи              —                    ВСЕ 7 клеток обязаны быть ЗЕЛЁНЫ (анти-тавтология)
#
# Поимка — ТОЛЬКО rc 1 (урок А-398): rc 0 (стаб прошёл клетку) и rc 2 (нечем
# проверять) поимкой НЕ считаются — именованный отказ с кодом стаба.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODEL="$HERE/../accept_publish_094/model/dover.sh"
[ -f "$MODEL" ] || { printf 'NOT_IMPLEMENTED: нет модели %s\n' "$MODEL" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v sed >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет sed\n' >&2; exit 2; }
command -v cmp >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет cmp\n' >&2; exit 2; }
WORK="/tmp/dev-harness-verify/prepare-object-097-stubs-$$-${RANDOM}"
mkdir -p "$WORK" || { printf 'NOT_IMPLEMENTED: мир стабов не строится\n' >&2; exit 2; }
trap 'rm -rf "$WORK"' EXIT

# build_stub <имя> <якорь|-> <sed-подстановка|-> — копия модели + порча +
# хвостовой маркер. Якорь обязан встречаться в модели РОВНО один раз (порча
# попадает в задуманную строку); «порча применилась» = файл отличается от
# модели (cmp) — якорю разрешено выживать в замене (m5 печатает sha И двигает
# ref). Пустышка: якоря нет, меняется только маркер — клетка обязана быть
# зелёной, разница модели и пустышки ровно одна строка-маркер.
build_stub() {
  local name="$1" anchor="$2" swap="$3" f
  f="$WORK/$name.sh"
  cp "$MODEL" "$f" || return 2
  if [ "$anchor" != "-" ]; then
    [ "$(grep -Fc "$anchor" "$f")" -eq 1 ] || return 2
    [ "$swap" != "-" ] && { sed -i "$swap" "$f" || return 2; }
    ! cmp -s "$MODEL" "$f" || return 2
  fi
  printf '# t97-%s\n' "$name" >>"$f"
  [ "$(grep -Fc "# t97-$name" "$f")" -eq 1 ] || return 2
  chmod +x "$f"
  printf '%s\n' "$f"
}

itog=0
zapest() {  # <стаб-имя> <клетка-файл> <якорь> <подстановка>
  local name="$1" cell="$2" anchor="$3" swap="$4" f rc
  f="$(build_stub "$name" "$anchor" "$swap")"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'ОТКАЗ: стаб %s не строится (якорь/порча/маркер)\n' "$name" >&2; itog=2; return; }
  AP097_MODE=model AP097_ROOT="$HERE/../.." AP097_SUBJECT="$f" \
    bash "$HERE/$cell" >/dev/null 2>&1; rc=$?
  if [ "$rc" -eq 1 ]; then
    printf -- '— стаб %s ПОЙМАН клеткой %s\n' "$name" "$cell"
  else
    printf 'СТАБ УШЁЛ: %s не пойман клеткой %s (rc=%s; поимка — ТОЛЬКО rc 1, А-398)\n' "$name" "$cell" "$rc" >&2
    itog=1
  fi
}

zapest m1 red_kandidat_ne_vybiraet_politiku.sh \
  'show "$BASE:$POLICY_PATH"' \
  's@show "\$BASE:\$POLICY_PATH"@show "$CAND:$POLICY_PATH"@'
zapest m2 red_podmena_istochnika_politiki.sh \
  'show "$BASE:$POLICY_PATH"' \
  's@show "\$BASE:\$POLICY_PATH"@show "$CAND:$POLICY_PATH"@'
zapest m3 red_proizvodstvennyj_profil_M.sh \
  'printf '"'"'%s\n'"'"' "$m"' \
  's@printf '"'"'%s\\n'"'"' "\$m"@: "t97-m3 merge sha suppressed"@'
zapest m4 red_proizvodstvennyj_profil_M.sh \
  ' -p "$CAND"' \
  's@ -p "\$CAND"@@'
zapest m5 red_proizvodstvennyj_profil_M.sh \
  'printf '"'"'%s\n'"'"' "$m"' \
  's@printf '"'"'%s\\n'"'"' "\$m"@git -C "\$REPO" update-ref refs/heads/main "\$m" \&\& printf '"'"'%s\\n'"'"' "\$m"@'
zapest m6 red_sostav_obekta_razlichim.sh \
  '"$repoId" "$TASK"' \
  's@"\$repoId" "\$TASK" @"\$repoId" @'
zapest m7 red_politika_bez_targetbranches.sh \
  '] || die "политика: грамматика"' \
  's@] || die "политика: грамматика"@] || : "t97-m7 empty allowlist silent"@'
zapest m8 red_oba_profilya.sh \
  '    *) die "политика: грамматика"' \
  's@    \*) die "политика: грамматика"@    \*) : "t97-m8 unknown line accepted"@'
zapest m9 red_identity_i_sankcii_podgotovki.sh \
  'GIT_AUTHOR_NAME=orchestrator' \
  's@GIT_AUTHOR_NAME=orchestrator@GIT_AUTHOR_NAME=architect097@'
zapest m10 red_identity_i_sankcii_podgotovki.sh \
  'GIT_COMMITTER_NAME=orchestrator' \
  's@GIT_COMMITTER_NAME=orchestrator@GIT_COMMITTER_NAME=architect097@'

# пустышка: копия модели без порчи — каждая клетка обязана быть ЗЕЛЁНОЙ
# (клетка, красная всегда, «ловила» бы и пустышку — анти-тавтология)
f0="$(build_stub m0 - -)"; rc0=$?
[ "$rc0" -eq 0 ] || { printf 'ОТКАЗ: пустышка m0 не строится\n' >&2; itog=2; }
if [ "$rc0" -eq 0 ]; then
  for c in $(ls "$HERE"/red_*.sh | LC_ALL=C sort); do
    AP097_MODE=model AP097_ROOT="$HERE/../.." AP097_SUBJECT="$f0" \
      bash "$c" >/dev/null 2>&1; rc=$?
    if [ "$rc" -eq 0 ]; then
      printf -- '— пустышка m0 ЗЕЛЕНА клеткой %s\n' "$(basename "$c")"
    else
      printf 'КЛЕТКА ПУСТУЮ ЛОВИТ: %s красна на беспорчной копии модели (rc=%s) — тавтология\n' "$(basename "$c")" "$rc" >&2
      itog=1
    fi
  done
fi

printf 'ИТОГ стаб-пак 097: rc=%s\n' "$itog"
exit "$itog"
