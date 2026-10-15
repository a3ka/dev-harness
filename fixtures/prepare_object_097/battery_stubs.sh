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
# m11 prepare создаёт нецелевую ref   + update-ref tag     red_ni_odna_ref_ne_dvinuta.sh (А-8)
# m12 лёгкий тег -> symref на ветку (замер 1 арбитража, член 1; наблюдатель (2))  + symbolic-ref   red_ni_odna_ref_ne_dvinuta.sh (А-8)
# m13 отказ создаёт ref (член 2; отказный вызов, критерий А-8 на отказе)          + update-ref    red_politika_bez_targetbranches.sh (А-6)
# m14 create+delete временной ref (член 3; наблюдатель (1))                       + update-ref ±-d red_ni_odna_ref_ne_dvinuta.sh (А-8)
# m15 HEAD отсоединён на тот же OID (член 4; оба наблюдателя)                     + --no-deref    red_ni_odna_ref_ne_dvinuta.sh (А-8)
# m16 main перезаписан на тот же OID (член 5; наблюдатель (1))                    + update-ref    red_ni_odna_ref_ne_dvinuta.sh (А-8)
# m17 rc успешного проектного prepare подменён (блокер критика v4; обёртка над неизменной моделью — класс вне порчи по якорю)  rc 0→1 при projectLayer  red_oba_profilya.sh (А-5)
# m18 успешный проектный prepare печатает base вместо M (вердикт адверсария v2 А-5; обёртка над неизменной моделью — класс m17)  stdout M→BASE при projectLayer  red_oba_profilya.sh (А-5, положительная проба проекта)
# m19 пустой CSV-компонент «mandatory=» принят (вердикт адверсария v2 И-0)  «''|» выброшен из case mandatory + «[ -n "$mandatory" ] &&» выброшен  red_oba_profilya.sh (А-5, входы «пустой mandatory=» обоих профилей)
# m0  пустышка БЕЗ порчи              —                    ВСЕ 8 клеток обязаны быть ЗЕЛЁНЫ (анти-тавтология)
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
zapest m11 red_ni_odna_ref_ne_dvinuta.sh \
  'printf '"'"'%s\n'"'"' "$m"' \
  's@printf '"'"'%s\\n'"'"' "\$m"@printf '"'"'%s\\n'"'"' "\$m"; git -C "\$REPO" update-ref refs/tags/097-prepared "\$m"@'
zapest m12 red_ni_odna_ref_ne_dvinuta.sh \
  'printf '"'"'%s\n'"'"' "$m"' \
  's@printf '"'"'%s\\n'"'"' "\$m"@printf '"'"'%s\\n'"'"' "\$m"; git -C "\$REPO" symbolic-ref refs/tags/light-base refs/heads/aux/non-target@'
zapest m13 red_politika_bez_targetbranches.sh \
  '] || die "политика: грамматика"' \
  's@] || die "политика: грамматика"@] || { git -C "\$REPO" update-ref refs/tags/097-failed HEAD 2>/dev/null; die "политика: грамматика"; }@'
zapest m14 red_ni_odna_ref_ne_dvinuta.sh \
  'printf '"'"'%s\n'"'"' "$m"' \
  's@printf '"'"'%s\\n'"'"' "\$m"@printf '"'"'%s\\n'"'"' "\$m"; git -C "\$REPO" update-ref refs/tags/097-transient HEAD 2>/dev/null; git -C "\$REPO" update-ref -d refs/tags/097-transient 2>/dev/null@'
zapest m15 red_ni_odna_ref_ne_dvinuta.sh \
  'printf '"'"'%s\n'"'"' "$m"' \
  's@printf '"'"'%s\\n'"'"' "\$m"@printf '"'"'%s\\n'"'"' "\$m"; git -C "\$REPO" update-ref --no-deref HEAD "\$BASE"@'
zapest m16 red_ni_odna_ref_ne_dvinuta.sh \
  'printf '"'"'%s\n'"'"' "$m"' \
  's@printf '"'"'%s\\n'"'"' "\$m"@printf '"'"'%s\\n'"'"' "\$m"; git -C "\$REPO" update-ref refs/heads/main "\$BASE"@'
zapest m19 red_oba_profilya.sh \
  'mandatory=*) v="${line#mandatory=}"; case "$v" in '"'"''"'"'|' \
  's@\(mandatory=\*) v="\${line#mandatory=}"; case "\$v" in \)'"'"''"'"'|@\1@;s@\[ -n "\$mandatory" \] \&\& @@'

# m17 — обёртка rc-подмены проектного профиля (блокер критика круга 4): класс
# ВНЕ порчи по якорю — обёртка вызывает НЕИЗМЕННУЮ модель (cmp-порча модели
# невозможна по построению), а при verb=prepare && rc=0 читает принятый
# harness.project.json на base; ключ "projectLayer" переводит rc успешного
# prepare в 1, stdout/объекты/refs не трогает. На харнесе и на отказных
# ветках обёртка честна — дефект наблюдаем ТОЛЬКО положительной пробой
# проектного профиля клетки А-5, обязанной требовать rc 0 на КАЖДОМ профиле.
f17="$WORK/m17.sh"
cat >"$f17" <<'WRAP'
#!/usr/bin/env bash
# t97-m17: обёртка rc-подмены проектного профиля (блокер критика круга 4)
set -uo pipefail
MODEL="__T97_MODEL__"
orig=("$@")
verb="${1:-}"
REPO=""; BASE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:-}"; shift 2 ;;
    --base) BASE="${2:-}"; shift 2 ;;
    *) shift ;;
  esac
done
"$MODEL" "${orig[@]}"
rc=$?
if [ "$verb" = "prepare" ] && [ "$rc" -eq 0 ] && [ -n "$REPO" ] && [ -n "$BASE" ]; then
  if git -C "$REPO" show "$BASE:harness.project.json" 2>/dev/null | grep -Fq '"projectLayer"'; then
    exit 1
  fi
fi
exit "$rc"
WRAP
sed -i "s@__T97_MODEL__@$MODEL@" "$f17" && chmod +x "$f17"
# sudit_obertku <стаб-имя> <клетка-файл> <файл-обёртки> — суд стаба класса
# «обёртка над неизменной моделью» (поимка — ТОЛЬКО rc 1, А-398)
sudit_obertku() {
  local name="$1" cell="$2" f="$3" rc
  if [ -x "$f" ] && [ "$(grep -Fc "# t97-$name" "$f")" -eq 1 ]; then
    AP097_MODE=model AP097_ROOT="$HERE/../.." AP097_SUBJECT="$f" \
      bash "$HERE/$cell" >/dev/null 2>&1; rc=$?
    if [ "$rc" -eq 1 ]; then
      printf -- '— стаб %s ПОЙМАН клеткой %s\n' "$name" "$cell"
    else
      printf 'СТАБ УШЁЛ: %s не пойман клеткой %s (rc=%s; поимка — ТОЛЬКО rc 1, А-398)\n' "$name" "$cell" "$rc" >&2
      itog=1
    fi
  else
    printf 'ОТКАЗ: стаб %s не строится (маркер/исполняемость)\n' "$name" >&2
    itog=2
  fi
}
sudit_obertku m17 red_oba_profilya.sh "$f17"

# m18 — обёртка подмены stdout успешного проектного prepare (вердикт адверсария
# v2 А-5): тот же класс, что m17 — вызывает НЕИЗМЕННУЮ модель, а при
# verb=prepare && rc=0 и ключе "projectLayer" в принятом harness.project.json
# на base печатает SHA самой базы вместо созданного M: rc 0, валидный 40-hex,
# refs/объекты не тронуты. На харнесе и на отказных ветках честна — дефект
# наблюдаем ТОЛЬКО положительной пробой проектного профиля клетки А-5,
# обязанной сверять напечатанный sha с M (родители base+cand, дерево оракула).
f18="$WORK/m18.sh"
cat >"$f18" <<'WRAP'
#!/usr/bin/env bash
# t97-m18: обёртка подмены stdout успешного проектного prepare (base вместо M)
set -uo pipefail
MODEL="__T97_MODEL__"
orig=("$@")
verb="${1:-}"
REPO=""; BASE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:-}"; shift 2 ;;
    --base) BASE="${2:-}"; shift 2 ;;
    *) shift ;;
  esac
done
out="$("$MODEL" "${orig[@]}")"
rc=$?
if [ "$verb" = "prepare" ] && [ "$rc" -eq 0 ] && [ -n "$REPO" ] && [ -n "$BASE" ]; then
  if git -C "$REPO" show "$BASE:harness.project.json" 2>/dev/null | grep -Fq '"projectLayer"'; then
    printf '%s\n' "$BASE"
    exit 0
  fi
fi
[ -n "$out" ] && printf '%s\n' "$out"
exit "$rc"
WRAP
sed -i "s@__T97_MODEL__@$MODEL@" "$f18" && chmod +x "$f18"
sudit_obertku m18 red_oba_profilya.sh "$f18"

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
