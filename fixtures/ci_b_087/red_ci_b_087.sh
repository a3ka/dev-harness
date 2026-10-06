#!/usr/bin/env bash
# fixtures/ci_b_087/red_ci_b_087.sh — красная батарея контракта 087 «CI-Б: классы изменений
# и результат по хешу кодового дерева». Прямое предъявление (вне case_*-глоба
# verify_antiplacebo.sh, семья probe-only 034), агрегатор — fixtures/_krasnye_087.sh.
#
#   bash fixtures/ci_b_087/red_ci_b_087.sh [<корень-субъекта>]  # клетки + стаб-пак
#   bash fixtures/ci_b_087/red_ci_b_087.sh --model              # клетки на честной модели
#
# rc 0 ⟺ все клетки зелёные И стаб-пак пойман целиком (каждый стаб красен на своём входе
# и зелен на диффпробе); rc 1 — красное (каждая клетка печатает «КРАСНО: <клетка>: …»);
# rc 2 — нечем проверить (нет git/python3/каркаса). Оракул — в памяти батареи
# (_orakul.py: хеш по определению И-1, свой разбор ci.yml), ожидания снимаются ДО вызова
# субъекта; каждый вход — своя строка ok/КРАСНО.
#
# Клетки (субъект → вход → наблюдение):
#   А0  предмет на месте (г0): ci_klass.sh, ci_vesa.sh, run_ci_lane.sh, реестр с uchet;
#   А1  hash/klass на toy-мире: формула И-1 == оракул; 13 учётных вариантов → uchet и
#       равный хеш; 13 кодовых вариантов (ловушки границы docsx/, HANDOFFxmd,
#       NABLIUDENIA_x/, sub/HANDOFF.md, verdicts.md, x/NABLIUDENIA.md, путь с переводом
#       строки, режим +x, переименование, реестр) → kod и иной хеш;
#   А2  расширение uchet тем же пушем (реестр — код, И-1) → kod;
#   А8  реестр судимого корня: строки uchet == U контракта (множество, И-1), строки legkij ⊇
#       {check:charter, check:zones, check:ids, check:protected, check:nabludenia,
#       check:contract-frozen} (И-2);
#   А3  dokaz: свой артефакт; нет; подложный (имя H, head_sha иного H); истёкший; форк;
#       имя с суффиксом; неизвестный sha; доказательство последним; отказ API; не JSON;
#   А4  vorota: учётный пуш без API; код без доказательства; код с доказательством; land
#       на ушедший кодом main; land на ушедший учётом main; расширение U; old без реестра;
#       отказ API на кодовом пуше;
#   А5  strip: свой хеш; чужой хеш (отказ ДО удаления); грязное дерево;
#   А6  reshenie: доказательство есть → reuse; нет → run; отказ API → run;
#   А7  реестр вне грамматики / накрывает машину классификатора → hash rc 1 (11 входов);
#   Б1  check_ci_gate: тот же хеш, другой sha → 0; подложный хеш → 1; legkij красное/нет
#       → 1; полный прогон без пропусков → 0; отказ API доказательства → 1;
#   Б2  gitw_preflight_071.sh (чек 5): код без PR → 1; учётный → 0; код с доказательством
#       → 0; land на ушедший кодом main → 1; land на ушедший учётом main → 0;
#   К1–К9  ci.yml: джобы; решение klass; тяжёлые условны; strip первым; итог-артефакт;
#       лёгкое — гейт и по реестру (К6, закрытый контур, арбитраж 063-b4: у джобы legkij
#       только runs-on/steps/timeout-minutes, у шага лёгкого только name/id/run/
#       timeout-minutes, у workflow нет defaults/env — if, continue-on-error, shell,
#       working-directory, env отключают шаг или гасят его отказ); ворота на push; нет
#       cancel-in-progress; общие шаги однажды; исполнение извлечённых команд
#       решения/strip/ворот/лёгкого (лёгкое — и с отказом КАЖДОГО ключа legkij по очереди:
#       шаг обязан упасть);
#   В1  run_ci_lane.sh: строка «замер: <ключ> <секунды>» на каждый ключ, legkij-ключи
#       исполняемы; В2 ci_vesa.sh: --write по максимуму замеров, --check ловит ручной вес,
#       ключ без замера — отказ без записи, приманка вне якоря не считается.
#
# Стаб-пак (Н-39: привязка стаба к входу, где его дефект НАБЛЮДАЕМ, живёт ЗДЕСЬ, в коде;
# каждый стаб — честная модель model/* с одним дефектом M087_STAB=<имя>; «пойман» =
# клетка-наблюдение КРАСНА; «диффпроба» = клетка, где дефект ненаблюдаем, ЗЕЛЕНА):
#   tree-hash            хеш всего дерева, U игнорируется     → А1:U_handoff | А1:K_content
#   prefix-bez-slesha    «docs/» матчит «docsx/»               → А1:K_docsx | А1:U_docs
#   regex-tochka         «HANDOFF.md» как regex               → А1:K_handoffx | А1:U_handoff
#   glob-vglub           «NABLIUDENIA*» сквозь «/»            → А1:K_nabl_dir | А1:U_nabl_arch
#   bez-rezhima          режим файла вне хеша                 → А1:K_mode | А1:K_content
#   imja-bez-pereschjota имени артефакта верит без пересчёта  → А3:chuzhoj | А3:svoj
#   istjokshie           истёкший артефакт принят             → А3:istjok | А3:svoj
#   fork                 артефакт форк-прогона принят         → А3:fork | А3:svoj
#   imja-prefiks         имя сверяется префиксом              → А3:imja | А3:svoj
#   pervyj-tolko         судит только первый артефакт         → А3:poslednij | А3:svoj
#   vorota-po-sha        класс по sha, не по хешу             → А4:uchet | А4:kod-bez
#   vorota-tolko-land    судит только land-мержи              → А4:kod-bez | А4:land-ushjol
#   vorota-vsegda-api    учётный пуш зависит от API           → А4:uchet | А4:kod-dokaz
#   strip-bez-proverki   strip не сверяет хеш                 → А5:chuzhoj | А5:ok
#   reshenie-api-reuse   отказ API → reuse                    → А6:api | А6:reuse
#   skipped-bez-dokaza   check_ci_gate: skipped без dokaz     → Б1:chuzhoj-hesh | Б1:tot-zhe-hesh
#   K-bez-uslovija       ci без if решения                    → К3:ci | К3:obshchij
#   K-otmena             cancel-in-progress: true             → К8 | К1
#   K-parity-v-lane      ci-parity в lane-джобе               → К9 | К5
#   K-strip-posle        strip после lane-шага                → К4:ci | К4:obshchij
#   K-legkij-podavlen    шаг лёгкого continue-on-error: true  → К6 | К-исп legkij
#   K-legkij-dzhoba      джоба legkij continue-on-error: true → К6 | К-исп legkij
#   K-legkij-obolochka   workflow defaults.run.shell: python  → К6 | К-исп legkij
#   bez-zamera           run_ci_lane без строки замера        → В1 | В2
#   derzhit-staryj       ci_vesa держит вес без замера        → В2 | В1
#   legkij-glotaet       гасит отказ последнего legkij-ключа  → К-исп legkij | В1
# (K-legkij-*: обход Critic087 по трём уровням — шаг, джоба, workflow; диффпроба К-исп
#  legkij зелена — исполнение извлечённой команды YAML-подавления не видит, ловит контур К6;
#  legkij-glotaet наблюдаем лишь при отказе ПОСЛЕДНЕГО ключа — К-исп legkij обходит все.)
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
for t in git python3; do
  command -v "$t" >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет %s\n' "$t" >&2; exit 2; }
done
[ -f "$HERE/_toy.sh" ] && [ -f "$HERE/_orakul.py" ] \
  || { printf 'NOT_IMPLEMENTED: нет каркаса _toy.sh/_orakul.py\n' >&2; exit 2; }
# shellcheck disable=SC1091
. "$HERE/_toy.sh"
unset M087_STAB GITHUB_TOKEN CI_KLASS_API

MODE=subject
SUBJ="$REPO"
case "${1:-}" in
  --model) MODE=model ;;
  '') ;;
  *) SUBJ="$(cd "$1" && pwd)" || { printf 'NOT_IMPLEMENTED: корня нет: %s\n' "$1" >&2; exit 2; } ;;
esac

T="$(mktemp -d "${TMPDIR:-/tmp}/ci_b_087.XXXXXX")" || exit 2
trap 'rm -rf "$T"' EXIT
t87_setup "$T" || { printf 'NOT_IMPLEMENTED: toy-мир не построен\n' >&2; exit 2; }
t87_model_tree "$T/model" "$REPO" || { printf 'NOT_IMPLEMENTED: модель не построена\n' >&2; exit 2; }
[ "$MODE" = model ] && SUBJ="$T/model"
API='https://api.github.test/repos/toy/repo'
WF=.github/workflows/ci.yml

NOK=0; NBAD=0
R=''
pass() { NOK=$((NOK + 1)); printf '  ok   %s\n' "$1"; }
fail() { NBAD=$((NBAD + 1)); printf 'КРАСНО: %s: %s\n' "$1" "$2"; }
cell() {  # <метка> <функция> <S> <аргументы…>
  local label="$1"
  shift
  R=''
  if "$@"; then pass "$label"; else fail "$label" "$R"; fi
}

# sj <cwd> <скрипт> <аргументы…> → OUT, ERR, RC (поддельный curl первым в PATH)
sj() {
  local cwd="$1" ef
  shift
  ef="$T/err.$$.$RANDOM"
  OUT="$(cd "$cwd" && PATH="$T87_BIN:$PATH" CI_KLASS_API="$API" bash "$@" 2>"$ef")"
  RC=$?
  ERR="$(cat "$ef")"
  rm -f "$ef"
}
need() {  # <S> <отн-путь> — субъект на месте
  [ -f "$1/$2" ] && return 0
  R="предмет отсутствует: $2"
  return 1
}
clone_at() {  # <каталог> <sha>
  rm -rf "$1"
  t87_git clone -q "$T87_W" "$1" && t87_git -C "$1" checkout -q --detach "$2"
}
H() { t87_h "$1"; }
shaof() { local v="T87_$1"; printf '%s' "${!v}"; }

# ── А: ci_klass.sh ──────────────────────────────────────────────────────────────
A0() {
  local miss
  miss="$(t87_missing_subjects "$1")"
  [ -z "$miss" ] && return 0
  R="предмет отсутствует: $miss"
  return 1
}
A1_formula() {
  need "$1" scripts/ci_klass.sh || return 1
  local want
  want="$(H "$T87_C0")"
  sj "$T87_W" "$1/scripts/ci_klass.sh" hash "$T87_C0"
  [ "$RC" -eq 0 ] && [ "$OUT" = "$want" ] && return 0
  R="hash c0: rc $RC, «$OUT» ≠ оракул $want; $ERR"
  return 1
}
A1() {  # <S> <вариант>  — класс из имени варианта: U_* → uchet, K_* → kod
  need "$1" scripts/ci_klass.sh || return 1
  local v="$2" want h0 hv sha
  sha="$(shaof "$v")"
  case "$v" in U_*) want=uchet ;; *) want=kod ;; esac
  sj "$T87_W" "$1/scripts/ci_klass.sh" klass "$T87_C0" "$sha"
  [ "$RC" -eq 0 ] && [ "$OUT" = "$want" ] || { R="klass c0 $v: rc $RC, «$OUT» ≠ $want; $ERR"; return 1; }
  sj "$T87_W" "$1/scripts/ci_klass.sh" hash "$T87_C0"; h0="$OUT"
  sj "$T87_W" "$1/scripts/ci_klass.sh" hash "$sha"; hv="$OUT"
  if [ "$want" = uchet ] && [ "$h0" != "$hv" ]; then R="hash $v ≠ hash c0 при учётном изменении"; return 1; fi
  if [ "$want" = kod ] && [ "$h0" = "$hv" ]; then R="hash $v == hash c0 при кодовом изменении"; return 1; fi
  return 0
}
A2() {
  need "$1" scripts/ci_klass.sh || return 1
  sj "$T87_W" "$1/scripts/ci_klass.sh" klass "$T87_C0" "$T87_W_widen"
  [ "$RC" -eq 0 ] && [ "$OUT" = kod ] && return 0
  R="klass c0 W_widen (uchet fixtures/ и правка fixtures/ одним пушем): rc $RC, «$OUT» ≠ kod — реестр не учётный, его правка — код"
  return 1
}
A3_set() {  # <сценарий> — артефакты в поддельном API; печатает «<rev> <ожид-rc> <ожид-источник>»
  t87_fake_reset
  local hp hq
  hp="$(H "$T87_P")"; hq="$(H "$T87_Q")"
  case "$1" in
    svoj) t87_arts "$(t87_art "$T87_ART$hp" "$T87_P")"; echo "$T87_A 0 $T87_P" ;;
    net) t87_arts; echo "$T87_Q 1 -" ;;
    chuzhoj) t87_arts "$(t87_art "$T87_ART$hq" "$T87_P")"; echo "$T87_Q 1 -" ;;
    istjok) t87_arts "$(t87_art "$T87_ART$hq" "$T87_Q" true)"; echo "$T87_Q 1 -" ;;
    fork) t87_arts "$(t87_art "$T87_ART$hq" "$T87_Q" false 1 2)"; echo "$T87_Q 1 -" ;;
    imja) t87_arts "$(t87_art "$T87_ART${hq}x" "$T87_Q")"; echo "$T87_Q 1 -" ;;
    neizv) t87_arts "$(t87_art "$T87_ART$hq" ffffffffffffffffffffffffffffffffffffffff)"; echo "$T87_Q 1 -" ;;
    poslednij)
      t87_arts "$(t87_art "$T87_ART${hq}x" "$T87_Q")" "$(t87_art "$T87_ART$hq" "$T87_Q" true)" \
               "$(t87_art "$T87_ART$hq" "$T87_P")" "$(t87_art "$T87_ART$hq" "$T87_Q")"
      echo "$T87_Q 0 $T87_Q" ;;
    api) touch "$T87_FAKE/fail_artifacts"; echo "$T87_Q 2 -" ;;
    json) printf 'не json\n' > "$T87_FAKE/artifacts.json"; echo "$T87_Q 2 -" ;;
  esac
}
A3() {  # <S> <сценарий>
  need "$1" scripts/ci_klass.sh || return 1
  local rev erc esrc
  read -r rev erc esrc <<< "$(A3_set "$2")"
  sj "$T87_W" "$1/scripts/ci_klass.sh" dokaz "$rev"
  if [ "$RC" -ne "$erc" ]; then R="dokaz ($2): rc $RC ≠ $erc; out «$OUT»; $ERR"; return 1; fi
  if [ "$erc" -eq 0 ] && [ "$OUT" != "dokaz $esrc" ]; then R="dokaz ($2): «$OUT» ≠ «dokaz $esrc»"; return 1; fi
  if [ "$erc" -ne 0 ] && [ -n "$OUT" ]; then R="dokaz ($2): отказ с непустым stdout «$OUT»"; return 1; fi
  return 0
}
A4() {  # <S> <сценарий>
  need "$1" scripts/ci_klass.sh || return 1
  local old new erc phrase=''
  t87_fake_reset
  case "$2" in
    uchet) touch "$T87_FAKE/fail_artifacts"; old=$T87_C0; new=$T87_U_handoff; erc=0 ;;
    kod-bez) t87_arts; old=$T87_C0; new=$T87_Q; erc=1; phrase='код в main только через PR' ;;
    kod-dokaz) t87_arts "$(t87_art "$T87_ART$(H "$T87_Q")" "$T87_Q")"; old=$T87_C0; new=$T87_Q; erc=0 ;;
    land-ushjol) t87_arts "$(t87_art "$T87_ART$(H "$T87_P")" "$T87_P")"; old=$T87_M1; new=$T87_L_MOVED; erc=1; phrase='код в main только через PR' ;;
    land-ok) t87_arts "$(t87_art "$T87_ART$(H "$T87_P")" "$T87_P")"; old=$T87_M1U; new=$T87_L_OK; erc=0 ;;
    shirit) t87_arts; old=$T87_C0; new=$T87_W_widen; erc=1; phrase='код в main только через PR' ;;
    bez-reestra) old=$T87_N0; new=$T87_N1; erc=0 ;;
    api) touch "$T87_FAKE/fail_artifacts"; old=$T87_C0; new=$T87_Q; erc=2 ;;
  esac
  sj "$T87_W" "$1/scripts/ci_klass.sh" vorota "$old" "$new"
  if [ "$RC" -ne "$erc" ]; then R="vorota ($2): rc $RC ≠ $erc; out «$OUT»; $ERR"; return 1; fi
  if [ -n "$phrase" ] && [[ "$ERR" != *"$phrase"* ]]; then R="vorota ($2): нет фразы «$phrase»: $ERR"; return 1; fi
  return 0
}
uchet_left() {  # <каталог> → число отслеживаемых учётных путей, присутствующих в рабочем дереве
  python3 - "$1" "$T87_ORAKUL" <<'PY'
import os, subprocess, sys
d, orak = sys.argv[1], sys.argv[2]
sys.path.insert(0, os.path.dirname(orak))
import _orakul as o
ls = subprocess.run(['git', '-C', d, 'ls-files', '-z'], capture_output=True).stdout
n = 0
for raw in ls.split(b'\0'):
    p = raw.decode('utf-8', 'surrogateescape')
    if p and any(o.u_covers(u, p) for u in o.U87) and os.path.lexists(os.path.join(d, p)):
        n += 1
print(n)
PY
}
A5() {  # <S> <сценарий>
  need "$1" scripts/ci_klass.sh || return 1
  local d="$T/a5" arg left other
  clone_at "$d" "$T87_A" || { R='клон не построен'; return 1; }
  case "$2" in
    ok) arg="$(H "$T87_A")" ;;
    chuzhoj) arg="$(H "$T87_Q")" ;;
    grjaz) arg="$(H "$T87_A")"; printf 'echo dirty\n' > "$d/scripts/a.sh" ;;
  esac
  sj "$d" "$1/scripts/ci_klass.sh" strip "$arg"
  left="$(uchet_left "$d")"
  case "$2" in
    ok)
      [ "$RC" -eq 0 ] || { R="strip свой хеш: rc $RC; $ERR"; return 1; }
      [ "$left" = 0 ] || { R="strip: учётных путей осталось $left"; return 1; }
      other="$(t87_git -C "$d" status --porcelain=v1 --untracked-files=no | grep -v '^ D ' || true)"
      [ -z "$other" ] || { R="strip тронул не только учётные пути: $other"; return 1; }
      [ "$(t87_git -C "$d" rev-parse HEAD)" = "$T87_A" ] || { R='strip сдвинул HEAD'; return 1; } ;;
    chuzhoj)
      [ "$RC" -eq 1 ] && [[ "$ERR" == *'не совпадает'* ]] || { R="strip чужой хеш: rc $RC; $ERR"; return 1; }
      [ "$left" != 0 ] || { R='strip удалил учётные пути ДО отказа'; return 1; } ;;
    grjaz)
      [ "$RC" -eq 1 ] && [[ "$ERR" == *'рабочее дерево'* ]] || { R="strip грязное дерево: rc $RC; $ERR"; return 1; } ;;
  esac
  return 0
}
A6() {  # <S> <сценарий>
  need "$1" scripts/ci_klass.sh || return 1
  local d="$T/a6" want
  clone_at "$d" "$T87_A" || { R='клон не построен'; return 1; }
  t87_fake_reset
  case "$2" in
    reuse) t87_arts "$(t87_art "$T87_ART$(H "$T87_A")" "$T87_P")"; want="kod=$(H "$T87_A")|tyazh=reuse|istochnik=$T87_P" ;;
    run) t87_arts; want="kod=$(H "$T87_A")|tyazh=run|istochnik=-" ;;
    api) touch "$T87_FAKE/fail_artifacts"; want="kod=$(H "$T87_A")|tyazh=run|istochnik=-" ;;
  esac
  sj "$d" "$1/scripts/ci_klass.sh" reshenie
  [ "$RC" -eq 0 ] || { R="reshenie ($2): rc $RC; $ERR"; return 1; }
  [ "$(printf '%s' "$OUT" | tr '\n' '|')" = "$want" ] && return 0
  R="reshenie ($2): «$(printf '%s' "$OUT" | tr '\n' '|')» ≠ «$want»"
  return 1
}
A8() {  # <S> — реестр судимого корня: U == U контракта (множество), legkij ⊇ минимума И-2
  need "$1" registry/ci-steps.tsv || return 1
  local got want k leg miss=''
  got="$(python3 "$T87_ORAKUL" reg-keys "$1/registry/ci-steps.tsv" uchet | python3 -c 'import sys; print(" ".join(sorted(sys.stdin.read().split())))')"
  want="$(python3 -c 'import sys; sys.path.insert(0, sys.argv[1]); import _orakul as o; print(" ".join(sorted(o.U87)))' "$T87_HERE")"
  [ "$got" = "$want" ] || { R="строки uchet реестра «$got» ≠ U контракта «$want»"; return 1; }
  leg=" $(python3 "$T87_ORAKUL" reg-keys "$1/registry/ci-steps.tsv" legkij) "
  for k in check:charter check:zones check:ids check:protected check:nabludenia check:contract-frozen; do
    [[ "$leg" == *" $k "* ]] || miss="$miss $k"
  done
  [ -z "$miss" ] && return 0
  R="строк legkij нет для:$miss"
  return 1
}
A7() {  # <S> <вариант B_*>
  need "$1" scripts/ci_klass.sh || return 1
  sj "$T87_W" "$1/scripts/ci_klass.sh" hash "$(shaof "$2")"
  [ "$RC" -eq 1 ] && [ -z "$OUT" ] && [[ "$ERR" == *registry/ci-steps.tsv* ]] && return 0
  R="hash при плохой строке uchet ($2): rc $RC, out «$OUT»; $ERR"
  return 1
}

# ── Б: check_ci_gate.sh и предполёт ─────────────────────────────────────────────
B1() {  # <S> <сценарий>
  need "$1" scripts/check_ci_gate.sh || return 1
  local skip=(ci:skipped antiplacebo:skipped obshchij:skipped tyazhelyj-itog:skipped) erc phrase=''
  t87_fake_reset
  t87_git -C "$T87_CG" update-ref refs/remotes/origin/main "$T87_A"
  t87_git -C "$T87_CG" checkout -q --detach "$T87_A"
  case "$2" in
    tot-zhe-hesh) t87_runs "$T87_A" klass:success legkij:success vorota:success "${skip[@]}"
                  t87_arts "$(t87_art "$T87_ART$(H "$T87_A")" "$T87_P")"; erc=0 ;;
    chuzhoj-hesh) t87_runs "$T87_A" klass:success legkij:success vorota:success "${skip[@]}"
                  t87_arts "$(t87_art "$T87_ART$(H "$T87_A")" "$T87_Q")"; erc=1; phrase='тяжёл' ;;
    legkij-krasnyj) t87_runs "$T87_A" klass:success legkij:failure vorota:success "${skip[@]}"
                    t87_arts "$(t87_art "$T87_ART$(H "$T87_A")" "$T87_P")"; erc=1; phrase='legkij' ;;
    legkij-net) t87_runs "$T87_A" klass:success vorota:success "${skip[@]}"
                t87_arts "$(t87_art "$T87_ART$(H "$T87_A")" "$T87_P")"; erc=1; phrase='legkij' ;;
    polnyj) t87_runs "$T87_A" klass:success legkij:success vorota:success ci:success \
              antiplacebo:success obshchij:success tyazhelyj-itog:success; erc=0 ;;
    api) t87_runs "$T87_A" klass:success legkij:success vorota:success "${skip[@]}"
         touch "$T87_FAKE/fail_artifacts"; erc=1; phrase='не ответил' ;;
  esac
  sj "$T87_CG" "$1/scripts/check_ci_gate.sh" "$T87_CG" "$T87_A"
  if [ "$RC" -ne "$erc" ]; then R="check_ci_gate ($2): rc $RC ≠ $erc; $ERR"; return 1; fi
  if [ -n "$phrase" ] && [[ "$ERR" != *"$phrase"* ]]; then R="check_ci_gate ($2): нет фразы «$phrase»: $ERR"; return 1; fi
  return 0
}
B2() {  # <S> <сценарий>
  need "$1" scripts/gitw_preflight_071.sh || return 1
  local rmain send erc phrase=''
  t87_fake_reset
  t87_pr_runs_green
  case "$2" in
    kod-bez-pr) rmain=$T87_C0; send=$T87_Q; t87_arts; erc=1; phrase='код в main только через PR' ;;
    uchet) rmain=$T87_C0; send=$T87_U_handoff; touch "$T87_FAKE/fail_artifacts"; erc=0 ;;
    kod-dokaz) rmain=$T87_C0; send=$T87_Q; t87_arts "$(t87_art "$T87_ART$(H "$T87_Q")" "$T87_Q")"; erc=0 ;;
    land-ushjol) rmain=$T87_M1; send=$T87_L_MOVED; t87_arts "$(t87_art "$T87_ART$(H "$T87_P")" "$T87_P")"; erc=1; phrase='код в main только через PR' ;;
    land-ok) rmain=$T87_M1U; send=$T87_L_OK; t87_arts "$(t87_art "$T87_ART$(H "$T87_P")" "$T87_P")"; erc=0 ;;
  esac
  t87_git -C "$T87_W" push -q -f "$T87_O" "$rmain:refs/heads/main" || { R='цель не выставлена'; return 1; }
  GITW_PREFLIGHT_071_API="$API" sj "$T87_W" "$1/scripts/gitw_preflight_071.sh" "$T87_O" "$send:main"
  if [ "$RC" -ne "$erc" ]; then R="предполёт ($2): rc $RC ≠ $erc; $ERR"; return 1; fi
  if [ -n "$phrase" ] && [[ "$ERR" != *"$phrase"* ]]; then R="предполёт ($2): нет фразы «$phrase»: $ERR"; return 1; fi
  return 0
}

# ── К: .github/workflows/ci.yml ─────────────────────────────────────────────────
KS() {  # <S> <клетка> — структура (оракул _orakul.py kcheck)
  local out
  out="$(python3 "$T87_ORAKUL" kcheck "$2" "$1/$WF" "$1/registry/ci-steps.tsv" 2>&1)" && return 0
  R="$(printf '%s' "$out" | tr '\n' ';')"
  return 1
}
kx_cmd() {  # <S> <что> → CMD (извлечённая команда шага) | rc 1
  CMD="$(python3 "$T87_ORAKUL" kcmd "$2" "$1/$WF" 2>&1)" && [ -n "$CMD" ] && return 0
  R="в ci.yml нет шага «$2» в грамматике К-клеток"
  return 1
}
kx_legkij_mir() {  # <каталог> <S> <ключи legkij> <позиция отказа | -1> — toy-корень шага
  # лёгкого: раннер субъекта, реестр из ключей legkij; ключ на позиции отказа — «exit
  # <позиция+1>», прочие пишут своё имя в журнал
  local d="$1" bad="$4" k i=0
  rm -rf "$d"; mkdir -p "$d/scripts" "$d/registry"
  cp "$2/scripts/run_ci_lane.sh" "$d/scripts/run_ci_lane.sh"
  : > "$d/journal"
  {
    printf 'lanes\t6\n'
    for k in $3; do
      if [ "$i" -eq "$bad" ]; then printf 'legkij\t%s\t1\texit %d\n' "$k" "$((i + 1))"
      else printf 'legkij\t%s\t1\tprintf %%s\\\\n %s >> %s\n' "$k" "$k" "$d/journal"; fi
      i=$((i + 1))
    done
  } > "$d/registry/ci-steps.tsv"
}
KX() {  # <S> <исполнение>
  local d="$T/kx" cmd f
  case "$2" in
    reshenie/*) kx_cmd "$1" reshenie || return 1 ;;
    strip/*) kx_cmd "$1" strip || return 1 ;;
    vorota/*) kx_cmd "$1" vorota || return 1 ;;
    legkij) kx_cmd "$1" legkij || return 1 ;;
  esac
  need "$1" scripts/ci_klass.sh || return 1
  t87_fake_reset
  case "$2" in
    reshenie/*)
      clone_at "$d" "$T87_A" || { R='клон не построен'; return 1; }
      cp "$1/scripts/ci_klass.sh" "$d/scripts/ci_klass.sh"
      f="$T/kx.out"; : > "$f"
      if [ "$2" = reshenie/reuse ]; then t87_arts "$(t87_art "$T87_ART$(H "$T87_A")" "$T87_P")"; else t87_arts; fi
      (cd "$d" && PATH="$T87_BIN:$PATH" CI_KLASS_API="$API" GITHUB_OUTPUT="$f" bash -eo pipefail -c "$CMD") >/dev/null 2>&1 \
        || { R="шаг решения упал: $CMD"; return 1; }
      grep -qx "kod=$(H "$T87_A")" "$f" || { R="GITHUB_OUTPUT без kod=<H(A)>: $(tr '\n' '|' < "$f")"; return 1; }
      if [ "$2" = reshenie/reuse ]; then grep -qx 'tyazh=reuse' "$f" || { R="нет tyazh=reuse: $(tr '\n' '|' < "$f")"; return 1; }
      else grep -qx 'tyazh=run' "$f" || { R="нет tyazh=run: $(tr '\n' '|' < "$f")"; return 1; }; fi ;;
    strip/*)
      clone_at "$d" "$T87_A" || { R='клон не построен'; return 1; }
      cp "$1/scripts/ci_klass.sh" "$d/scripts/ci_klass.sh"
      if [ "$2" = strip/svoj ]; then cmd="${CMD//'${{ needs.klass.outputs.kod }}'/$(H "$T87_A")}"
      else cmd="${CMD//'${{ needs.klass.outputs.kod }}'/$(H "$T87_Q")}"; fi
      (cd "$d" && PATH="$T87_BIN:$PATH" bash -eo pipefail -c "$cmd") >/dev/null 2>&1
      local rc=$? left
      left="$(uchet_left "$d")"
      if [ "$2" = strip/svoj ]; then
        [ "$rc" -eq 0 ] && [ "$left" = 0 ] || { R="strip-шаг своим хешем: rc $rc, учётных осталось $left"; return 1; }
      else
        [ "$rc" -ne 0 ] && [ "$left" != 0 ] || { R="strip-шаг чужим хешем: rc $rc, учётных осталось $left"; return 1; }
      fi ;;
    vorota/*)
      clone_at "$d" "$T87_C0" || { R='клон не построен'; return 1; }
      cp "$1/scripts/ci_klass.sh" "$d/scripts/ci_klass.sh"
      t87_arts
      if [ "$2" = vorota/kod-bez-pr ]; then cmd="${CMD//'${{ github.event.before }}'/$T87_C0}"; cmd="${cmd//'${{ github.sha }}'/$T87_Q}"
      else cmd="${CMD//'${{ github.event.before }}'/$T87_C0}"; cmd="${cmd//'${{ github.sha }}'/$T87_U_handoff}"; fi
      local out rc
      out="$(cd "$d" && PATH="$T87_BIN:$PATH" CI_KLASS_API="$API" bash -eo pipefail -c "$cmd" 2>&1)"; rc=$?
      if [ "$2" = vorota/kod-bez-pr ]; then
        [ "$rc" -eq 1 ] && [[ "$out" == *'код в main только через PR'* ]] || { R="шаг ворот, код без PR: rc $rc; $out"; return 1; }
      else
        [ "$rc" -eq 0 ] || { R="шаг ворот, учётный пуш: rc $rc; $out"; return 1; }
      fi ;;
    legkij)
      need "$1" scripts/run_ci_lane.sh || return 1
      local keys k i=0
      keys="$(python3 "$T87_ORAKUL" reg-keys "$1/registry/ci-steps.tsv" legkij)"
      kx_legkij_mir "$d" "$1" "$keys" -1
      (cd "$d" && bash -eo pipefail -c "$CMD") >/dev/null 2>&1 || { R="шаг лёгкого упал: $CMD"; return 1; }
      [ "$(tr '\n' ' ' < "$d/journal")" = "$keys " ] || { R="журнал лёгкого «$(tr '\n' ' ' < "$d/journal")» ≠ ключам legkij «$keys»"; return 1; }
      # лёгкое — гейт: отказ КАЖДОГО ключа legkij по очереди (позиция i, rc i+1) роняет шаг
      for k in $keys; do
        kx_legkij_mir "$d" "$1" "$keys" "$i"
        if (cd "$d" && bash -eo pipefail -c "$CMD") >/dev/null 2>&1; then
          R="шаг лёгкого rc 0 при отказе ключа $k (позиция $i, rc $((i + 1))) — отказ лёгкой проверки погашен: $CMD"
          return 1
        fi
        i=$((i + 1))
      done ;;
  esac
  return 0
}

# ── В: замеры и веса ────────────────────────────────────────────────────────────
V1() {
  need "$1" scripts/run_ci_lane.sh || return 1
  local d="$T/v1" out k n
  rm -rf "$d"; mkdir -p "$d/scripts" "$d/registry" "$d/sk"
  cp "$1/scripts/run_ci_lane.sh" "$d/scripts/"
  printf 'echo k1 >> %s/journal\n' "$d" > "$d/sk/k1.sh"
  printf 'sleep 1; echo k2 >> %s/journal\n' "$d" > "$d/sk/k2.sh"
  printf 'echo l1 >> %s/journal\n' "$d" > "$d/sk/l1.sh"
  printf 'lanes\t6\nstep\tk1\t1\tbash sk/k1.sh\nstep\tk2\t1\tbash sk/k2.sh\nlegkij\tl1\t1\tbash sk/l1.sh\n' > "$d/registry/ci-steps.tsv"
  out="$(cd "$d" && bash scripts/run_ci_lane.sh k1 k2 l1 2>&1)" || { R="run_ci_lane k1 k2 l1: rc≠0: $out"; return 1; }
  [ "$(tr '\n' ' ' < "$d/journal")" = 'k1 k2 l1 ' ] || { R="журнал «$(tr '\n' ' ' < "$d/journal")» ≠ k1 k2 l1"; return 1; }
  for k in k1 k2 l1; do
    n="$(printf '%s\n' "$out" | grep -cE "^замер: $k [0-9]+\$")"
    [ "$n" = 1 ] || { R="строк «замер: $k <секунды>» $n ≠ 1"; return 1; }
  done
  n="$(printf '%s\n' "$out" | sed -nE 's/^замер: k2 ([0-9]+)$/\1/p')"
  [ "$n" -ge 1 ] || { R="замер k2 = $n < 1 при sleep 1"; return 1; }
  return 0
}
V2() {
  need "$1" scripts/ci_vesa.sh || return 1
  local d="$T/v2" out rc before
  rm -rf "$d"; mkdir -p "$d/scripts" "$d/registry"
  cp "$1/scripts/ci_vesa.sh" "$d/scripts/"
  printf '# комментарий\nlanes\t6\nuchet\tdocs/\nstep\tk1\t5\tbash a.sh\nstep\tk2\t7\tbash b.sh\nlegkij\tl1\t3\tbash c.sh\nshard\tap1\tx y\n' > "$d/registry/ci-steps.tsv"
  printf 'ci (l1)\tLane l1\t2026-10-06T00:00:01.0000000Z замер: k1 12\nci (l1)\tLane l1\t2026-10-06T00:00:02.0000000Z замер: k2 3\nci (l1)\tLane l1\t2026-10-06T00:00:03.0000000Z + echo замер: k2 99\n' > "$d/log1"
  printf '2026-10-06T00:00:04.0000000Z замер: k1 15\n2026-10-06T00:00:05.0000000Z замер: l1 4\n' > "$d/log2"
  out="$(cd "$d" && bash scripts/ci_vesa.sh --write log1 log2 2>&1)" || { R="--write: rc≠0: $out"; return 1; }
  [ "$(cat "$d/registry/ci-steps.tsv")" = "$(printf '# комментарий\nlanes\t6\nuchet\tdocs/\nstep\tk1\t15\tbash a.sh\nstep\tk2\t3\tbash b.sh\nlegkij\tl1\t4\tbash c.sh\nshard\tap1\tx y')" ] \
    || { R="реестр после --write ≠ ожиданию (k1=15 max, k2=3 приманка вне якоря, l1=4, прочие байты целы): $(tr '\t\n' ' |' < "$d/registry/ci-steps.tsv")"; return 1; }
  out="$(cd "$d" && bash scripts/ci_vesa.sh --check log1 log2 2>&1)" || { R="--check после --write: rc≠0: $out"; return 1; }
  sed -i 's/^step\tk2\t3\t/step\tk2\t9\t/' "$d/registry/ci-steps.tsv"
  out="$(cd "$d" && bash scripts/ci_vesa.sh --check log1 log2 2>&1)"; rc=$?
  [ "$rc" -eq 1 ] && [[ "$out" == *k2* ]] || { R="--check при ручном весе k2=9: rc $rc; $out"; return 1; }
  printf 'step\tk3\t2\tbash d.sh\n' >> "$d/registry/ci-steps.tsv"
  before="$(cat "$d/registry/ci-steps.tsv")"
  out="$(cd "$d" && bash scripts/ci_vesa.sh --write log1 log2 2>&1)"; rc=$?
  [ "$rc" -eq 1 ] && [[ "$out" == *k3* ]] || { R="--write при ключе без замера k3: rc $rc; $out"; return 1; }
  [ "$(cat "$d/registry/ci-steps.tsv")" = "$before" ] || { R='--write с отказом изменил реестр'; return 1; }
  return 0
}

# ── прогон клеток ───────────────────────────────────────────────────────────────
S="$SUBJ"
printf 'батарея 087: субъект %s (%s)\n' "$S" "$MODE"
cell 'А0 предмет на месте' A0 "$S"
cell 'А1 формула хеша == оракул' A1_formula "$S"
for v in $(python3 "$T87_ORAKUL" variants uchet) $(python3 "$T87_ORAKUL" variants kod); do
  cell "А1 $v" A1 "$S" "$v"
done
cell 'А2 расширение uchet — код' A2 "$S"
cell 'А8 реестр: U и минимум legkij' A8 "$S"
for sc in svoj net chuzhoj istjok fork imja neizv poslednij api json; do cell "А3 dokaz:$sc" A3 "$S" "$sc"; done
for sc in uchet kod-bez kod-dokaz land-ushjol land-ok shirit bez-reestra api; do cell "А4 vorota:$sc" A4 "$S" "$sc"; done
for sc in ok chuzhoj grjaz; do cell "А5 strip:$sc" A5 "$S" "$sc"; done
for sc in reuse run api; do cell "А6 reshenie:$sc" A6 "$S" "$sc"; done
for v in $(python3 "$T87_ORAKUL" variants bad); do cell "А7 реестр:$v" A7 "$S" "$v"; done
for sc in tot-zhe-hesh chuzhoj-hesh legkij-krasnyj legkij-net polnyj api; do cell "Б1 check_ci_gate:$sc" B1 "$S" "$sc"; done
for sc in kod-bez-pr uchet kod-dokaz land-ushjol land-ok; do cell "Б2 предполёт:$sc" B2 "$S" "$sc"; done
for k in K1 K2 K3:ci K3:antiplacebo K3:obshchij K4:ci K4:antiplacebo K4:obshchij K5 K6 K7 K8 K9; do
  cell "${k/K/К}" KS "$S" "$k"
done
for x in reshenie/reuse reshenie/run strip/svoj strip/chuzhoj vorota/kod-bez-pr vorota/uchet legkij; do
  cell "К-исп $x" KX "$S" "$x"
done
cell 'В1 строки замера' V1 "$S"
cell 'В2 веса по замерам' V2 "$S"

# ── стаб-пак: всегда против честной модели с одним дефектом ────────────────────
SP_OK=0; SP_N=0
stab_tree() {  # <стаб> → каталог-субъект (для K-стабов — модель с мутацией ci.yml)
  local st="$1" m="$T/stab_$1"
  case "$st" in
    K-*)
      rm -rf "$m"; cp -a "$T/model" "$m"
      python3 - "$m/$WF" "$st" <<'PY'
import sys
p, st = sys.argv[1], sys.argv[2]
t = open(p, encoding='utf-8').read()
cut = t.index('\n  ci:\n')
head, ci = t[:cut], t[cut:]
if st == 'K-bez-uslovija':
    ci = ci.replace("    if: needs.klass.outputs.tyazh == 'run'\n", '', 1)
elif st == 'K-otmena':
    head = head.replace('\njobs:\n', '\nconcurrency:\n  group: ci-${{ github.ref }}\n  cancel-in-progress: true\n\njobs:\n', 1)
elif st == 'K-parity-v-lane':
    ci = ci.replace('      - name: Lane ${{ matrix.lane }}\n', '      - run: npm run check:ci-parity\n      - name: Lane ${{ matrix.lane }}\n', 1)
elif st == 'K-strip-posle':
    s = '      - run: bash scripts/ci_klass.sh strip ${{ needs.klass.outputs.kod }}\n'
    ci = ci.replace(s, '', 1)
    i = ci.index('        run: bash scripts/run_ci_lane.sh ${{ matrix.keys }}\n') + len('        run: bash scripts/run_ci_lane.sh ${{ matrix.keys }}\n')
    ci = ci[:i] + s + ci[i:]
elif st == 'K-legkij-podavlen':
    s = '      - name: Лёгкое задание (устав, зоны, ids, protected, грамматика 015)\n'
    head = head.replace(s, s + '        continue-on-error: true\n', 1)
elif st == 'K-legkij-dzhoba':
    s = '  legkij:\n    runs-on: ubuntu-latest\n'
    head = head.replace(s, s + '    continue-on-error: true\n', 1)
elif st == 'K-legkij-obolochka':
    head = head.replace('\njobs:\n', '\ndefaults:\n  run:\n    shell: python {0}\n\njobs:\n', 1)
open(p, 'w', encoding='utf-8').write(head + ci)
PY
      printf '%s' "$m" ;;
    *) printf '%s' "$T/model" ;;
  esac
}
stab() {  # <стаб> <клетка-наблюдение…> -- <клетка-диффпроба…>
  local st="$1" m obs=() dif=() o d
  shift
  while [ "$1" != -- ]; do obs+=("$1"); shift; done
  shift
  dif=("$@")
  SP_N=$((SP_N + 1))
  m="$(stab_tree "$st")"
  R=''; if M087_STAB="$st" "${obs[0]}" "$m" "${obs[@]:1}"; then o=зелена; else o=красна; fi
  local ro="$R"
  R=''; if M087_STAB="$st" "${dif[0]}" "$m" "${dif[@]:1}"; then d=зелена; else d=красна; fi
  if [ "$o" = красна ] && [ "$d" = зелена ]; then
    SP_OK=$((SP_OK + 1))
    printf '  ok   стаб %s: пойман на %s (%s); диффпроба %s зелена\n' "$st" "${obs[*]}" "$ro" "${dif[*]}"
  else
    NBAD=$((NBAD + 1))
    printf 'КРАСНО: стаб %s: наблюдение %s %s, диффпроба %s %s (%s)\n' "$st" "${obs[*]}" "$o" "${dif[*]}" "$d" "$R"
  fi
}
stab tree-hash A1 U_handoff -- A1 K_content
stab prefix-bez-slesha A1 K_docsx -- A1 U_docs
stab regex-tochka A1 K_handoffx -- A1 U_handoff
stab glob-vglub A1 K_nabl_dir -- A1 U_nabl_arch
stab bez-rezhima A1 K_mode -- A1 K_content
stab imja-bez-pereschjota A3 chuzhoj -- A3 svoj
stab istjokshie A3 istjok -- A3 svoj
stab fork A3 fork -- A3 svoj
stab imja-prefiks A3 imja -- A3 svoj
stab pervyj-tolko A3 poslednij -- A3 svoj
stab vorota-po-sha A4 uchet -- A4 kod-bez
stab vorota-tolko-land A4 kod-bez -- A4 land-ushjol
stab vorota-vsegda-api A4 uchet -- A4 kod-dokaz
stab strip-bez-proverki A5 chuzhoj -- A5 ok
stab reshenie-api-reuse A6 api -- A6 reuse
stab skipped-bez-dokaza B1 chuzhoj-hesh -- B1 tot-zhe-hesh
stab K-bez-uslovija KS K3:ci -- KS K3:obshchij
stab K-otmena KS K8 -- KS K1
stab K-parity-v-lane KS K9 -- KS K5
stab K-strip-posle KS K4:ci -- KS K4:obshchij
stab K-legkij-podavlen KS K6 -- KX legkij
stab K-legkij-dzhoba KS K6 -- KX legkij
stab K-legkij-obolochka KS K6 -- KX legkij
stab bez-zamera V1 -- V2
stab derzhit-staryj V2 -- V1
stab legkij-glotaet KX legkij -- V1

printf 'ИТОГ 087: клеток ok=%d КРАСНО=%d; стаб-пак: поймано %d/%d (%s)\n' \
  "$NOK" "$((NBAD - (SP_N - SP_OK)))" "$SP_OK" "$SP_N" "$MODE"
[ "$NBAD" -eq 0 ]
