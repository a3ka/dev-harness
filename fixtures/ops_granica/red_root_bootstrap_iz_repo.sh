#!/usr/bin/env bash
# Клетка 1 (И-1/И-2, «Выход» п.3 корневая половина) контракта 093.
# ПРЕДМЕТ (починка А-2 круга 2): прежняя редакция строила OPS_SERVER_LIB_DST
# голым cp честного источника и проверяла только яд в ${REPO} — подмена
# УСТАНОВЛЕННОГО адресата (прямо названный в И-1 случай: «её
# отсутствие/подмена sha256 → именованный отказ») не различалась: живой
# обход adversary исполнял подменённую библиотеку, клетка оставалась
# зелёной. Теперь честный установленный мир строится РЕАЛЬНЫМ install.sh
# root на toy-адресатах (прецедент клетки 6: шимы id/chown/chattr/lsattr/
# useradd/visudo/systemctl в PATH субъекта-установщика) — любые пины/
# сайдкары/метаданные установщика возникают сами и согласованы; субъект
# каждого прогона — УСТАНОВЛЕННЫЙ orch-peak. Три предъявления:
#   прогон A (позитив, И-1/И-2): установленная пара orch-peak+lib честна,
#     toy-REPO отравлен (scripts/lib_session.sh — валидный bash, пишет
#     SVID_REPO — невозможное событие для клетки); тогда: SVID_REPO НЕ
#     создан (bootstrap не из ${REPO}), ни один путь toy-REPO не изменён;
#   прогон B (негатив подмены, И-1 — А-2): содержимое УСТАНОВЛЕННОГО
#     $OPS_SERVER_LIB_DST перезаписано ядом (SVID_LIB) НА ТОМ ЖЕ ПУТИ,
#     inplace-редиректом — режим/владелец/сайдкары установщика не тронуты,
#     отличается ТОЛЬКО содержимое (sha256); тогда: SVID_LIB НЕ создан
#     (подменённый установленный bootstrap НЕ исполнен), SVID_REPO НЕ создан
#     (не тихий fallback на ${REPO}), rc≠0 И именованный отказ (маркер
#     И-1/подмены в выводе или журнале ORCH_LOG);
#   прогон C (негатив отсутствия, И-1): установленная lib удалена → rc≠0,
#     именованный отказ, SVID_REPO НЕ создан. Живой контроль различения:
#     отсутствие отказывается и на HEAD (orch-peak:174-177), подмена до
#     фикса А-1 НЕ отказывается — в этом и был дефект А-1/А-2.
# Прогон = warn: ветка bootstrap root-контекста исполняется при ЗАГРУЗКЕ
# файла, до диспетчеризации подкоманд (warn/stop/ctx для И-1 эквивалентны).
# На HEAD (до А-1): прогон B КРАСНЫЙ (яд установленного файла исполнен без
# sha-сверки — живой обход А-1 круга 2), прогоны A/C зелёные; после фикса
# А-1 (owner/mode/sha адресата ДО source) — все три зелёные.
# А-6: фикс А-1 сделал честный субъект и «bootstrap-из-репо»-мутанта
# НЕРАЗЛИЧИМЫМИ в безроотном toy-мире — реальный stat даёт uid
# тест-процесса ≠ 0 для ЛЮБОГО пути, оба отказывают на i1-проверке
# владельца до source, стаб s2 не ловился (батарея 5/7 на 5a089758).
# Модель станции (прецедент шимов id/chown): stat-шим с единственной
# ложью «%u установленной пары = 0» (install.sh root пишет root:root;
# режимы, %Y и все прочие пути — реальный stat). Честная пара ПРОХОДИТ
# i1 → прогон A завершается rc 0 (полный проход bootstrap, включая
# диспетчеризацию warn в шве ORCH_PEAK_TEST; STATE отведён в toy — И-8).
# Репо-путь шимом НЕ покрыт (реальный harness-uid): мутант s2 обязан
# либо отказаться (rc≠0 в прогоне A — регрессия доступности станции),
# либо исполнить отраву (свидетель SVID_REPO) — обе формы ловятся одним
# предъявлением прогона A (rc 0 + отсутствие SVID_REPO).
set -o pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${OPS093_ROOT:-$(cd "$HERE/../.." && pwd)}"
SUBJ="$ROOT/ops/server/root/orch-peak"
LIB="$ROOT/scripts/lib_session.sh"
INSTALL="$ROOT/ops/server/install.sh"
[ -f "$SUBJ" ] || { printf 'NOT_IMPLEMENTED: нет субъекта %s\n' "$SUBJ" >&2; exit 2; }
[ -f "$LIB" ] || { printf 'NOT_IMPLEMENTED: нет источника %s\n' "$LIB" >&2; exit 2; }
[ -f "$INSTALL" ] || { printf 'NOT_IMPLEMENTED: нет установщика %s\n' "$INSTALL" >&2; exit 2; }
[ -d "$ROOT/ops/server/root/systemd" ] || { printf 'NOT_IMPLEMENTED: нет юнитов субъекта\n' >&2; exit 2; }

SCRATCH="$(mktemp -d /tmp/dev-harness-verify/ops-granica-1-XXXXXX)" || { printf 'NOT_IMPLEMENTED: mktemp\n' >&2; exit 2; }
trap 'rm -rf "$SCRATCH"' EXIT

# Свидетели отравы — фиксированные пути: bootstrap не знает $SCRATCH клетки,
# яд обязан быть самодостаточным валидным bash (замер: строка с ведущим «!#»
# bash трактует как command-not-found и touch недостижим).
SVID_REPO="/tmp/dev-harness-verify/ops-granica-1-svid-repo"
SVID_LIB="/tmp/dev-harness-verify/ops-granica-1-svid-lib"
rm -f "$SVID_REPO" "$SVID_LIB"

# toy-REPO с отравленным bootstrap: scripts/lib_session.sh — валидный bash,
# пишущий свидетеля, если его ИСТОЧАТ или исполняют.
TOY_REPO="$SCRATCH/toy-repo"
mkdir -p "$TOY_REPO/scripts"
printf '%s\n' '#!/usr/bin/env bash' "touch '$SVID_REPO'" > "$TOY_REPO/scripts/lib_session.sh"

# Toy-мир установщика (прецедент клетки 6): шимы в PATH, toy-main для
# блока 081 (chattr-замок .git/config), toy-адресаты OPS_SERVER_*.
mkdir -p "$SCRATCH/bin" "$SCRATCH/main/.git" "$SCRATCH/main/.githooks" \
  "$SCRATCH/sbin" "$SCRATCH/etc" "$SCRATCH/bindst" "$SCRATCH/sudoers" \
  "$SCRATCH/agent_home" "$SCRATCH/rollback"

# id: root-гарды субъекта обязаны проходить (модель euid 0, прецедент 090/6).
printf '%s\n' '#!/usr/bin/env bash' \
  '[ "${1:-}" = "-u" ] && { printf "0\n"; exit 0; }' \
  'printf "uid=0(root) gid=0(root) groups=0(root)\n"; exit 0' > "$SCRATCH/bin/id"
chmod 755 "$SCRATCH/bin/id"

# systemctl — симулятор клеток 5/6 (общая ФОРМА): состояние из файла,
# журнал вызовов, самопроверка первой ступенью.
CTL_STATE="$SCRATCH/unit_state"; CTL_LOG="$SCRATCH/systemctl.log"
printf 'inactive\n' > "$CTL_STATE"
printf '%s\n' '#!/usr/bin/env bash' \
  'set -u' \
  "ST='$CTL_STATE'" \
  "J='$CTL_LOG'" \
  '[ -f "$ST" ] || { printf "systemctl-шим: нет файла состояния\n" >&2; exit 2; }' \
  '[ "$#" -ge 1 ] || { printf "systemctl-шим: нет подкоманды\n" >&2; exit 2; }' \
  'printf '"'"'%s\n'"'"' "$*" >> "$J"' \
  'case "$1" in' \
  '  is-active)' \
  '    s="$(cat "$ST")"; printf '"'"'%s\n'"'"' "$s"' \
  '    if [ "$s" = active ]; then exit 0; fi' \
  '    exit 3 ;;' \
  '  daemon-reload) exit 0 ;;' \
  '  restart|start) printf '"'"'active\n'"'"' > "$ST"; exit 0 ;;' \
  '  stop) printf '"'"'inactive\n'"'"' > "$ST"; exit 0 ;;' \
  'esac' > "$SCRATCH/bin/systemctl"
chmod 755 "$SCRATCH/bin/systemctl"

# chown/chattr/lsattr/useradd/visudo — модель root-станции (реальные под
# harness отказали бы EPERM; euid-0 шим id их не меняет) — прецедент клетки 6.
printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "$SCRATCH/bin/chown"
printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "$SCRATCH/bin/chattr"
printf '%s\n' '#!/usr/bin/env bash' \
  'for a in "$@"; do [ "$a" = "--" ] && continue; case "$a" in -*) continue;; esac' \
  '  printf -- "----i--------- %s\n" "$a"; break; done' \
  'exit 0' > "$SCRATCH/bin/lsattr"
printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "$SCRATCH/bin/useradd"
printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "$SCRATCH/bin/visudo"
chmod 755 "$SCRATCH"/bin/{chown,chattr,lsattr,useradd,visudo}

printf '%s\n' '[core]' '	hooksPath = .githooks' '[branch]' '	autoSetupMerge = false' \
  > "$SCRATCH/main/.git/config"

# Честная установка root-части РЕАЛЬНЫМ установщиком из дерева субъекта:
# устанавливаются настоящие orch-peak + lib_session.sh + юниты; любые
# пины/сайдкары фикса А-1 возникают самим установщиком и согласованы.
env PATH="$SCRATCH/bin:$PATH" HOME="$SCRATCH" \
  OPS_SERVER_SRC="$ROOT/ops/server" \
  OPS_SERVER_BIN_DST="$SCRATCH/bindst" \
  OPS_SERVER_SBIN_DST="$SCRATCH/sbin" \
  OPS_SERVER_ETC_DST="$SCRATCH/etc" \
  OPS_SERVER_MAIN="$SCRATCH/main" \
  OPS_SERVER_ROLLBACK_BACKUP="$SCRATCH/rollback" \
  OPS_SERVER_AGENT_USER="toyagent" \
  OPS_SERVER_AGENT_HOME="$SCRATCH/agent_home" \
  OPS_SERVER_SUDOERS_DROP="$SCRATCH/sudoers/launch" \
  OPS_SERVER_SYSTEMCTL="$SCRATCH/bin/systemctl" \
  OPS_SERVER_UNIT="toy-peak@0" \
  bash "$INSTALL" root >"$SCRATCH/install_out" 2>&1
inst_rc=$?
if [ "$inst_rc" -ne 0 ]; then
  printf 'КРАСНО: install root отказал в toy-мире на честном дереве (rc=%s): %s\n' \
    "$inst_rc" "$(tr '\n' ' ' < "$SCRATCH/install_out")" >&2
  exit 1
fi
[ -f "$SCRATCH/sbin/orch-peak" ] && [ -f "$SCRATCH/sbin/lib_session.sh" ] || {
  printf 'NOT_IMPLEMENTED: установщик не положил orch-peak/lib_session.sh в toy-sbin\n' >&2
  exit 2
}
SBIN="$SCRATCH/sbin"

# stat-шим (А-6): установленная пара (bootstrap-библиотека + её
# sha256-манифест) — единственные пути с моделируемым root-владением
# (форма вызова субъекта: stat -c %u <путь>); режимы, %Y и все прочие
# пути — реальный /usr/bin/stat. Репо-путь шимом НЕ покрыт: мутант,
# предпочитающий ${REPO}, обязан наткнуться на реальный harness-uid.
cat > "$SCRATCH/bin/stat" <<SHIM
#!/usr/bin/env bash
set -u
for last in "\$@"; do :; done
if [ "\${2:-}" = "%u" ] && { [ "\$last" = "$SBIN/lib_session.sh" ] || [ "\$last" = "$SBIN/lib_session.sh.sha256" ]; }; then
  printf '0\n'
  exit 0
fi
exec /usr/bin/stat "\$@"
SHIM
chmod 755 "$SCRATCH/bin/stat"

# Снимок всех файлов toy-REPO ДО прогонов субъекта (И-2).
find "$TOY_REPO" -type f | LC_ALL=C sort | xargs -I {} stat -c '%n %Y' {} > "$SCRATCH/repo_before"
[ -s "$SCRATCH/repo_before" ] || { printf 'ОТКАЗ: toy-REPO пуст\n' >&2; exit 2; }

# Прогон субъекта: УСТАНОВЛЕННЫЙ orch-peak, root-ветка (id-шим), шов
# OPS_SERVER_LIB_DST на установленную lib, отравленный toy-REPO.
run_subj() { # $1=метка прогона → rc в $subj_rc
  local tag="$1"
  mkdir -p "$SCRATCH/test_$tag"
  env PATH="$SCRATCH/bin:$PATH" \
    OPS_SERVER_LIB_DST="$SBIN/lib_session.sh" \
    ORCH_STATE="$SCRATCH/state_$tag" \
    ORCH_REPO="$TOY_REPO" \
    ORCH_USER="nobody" \
    ORCH_UHOME="/nonexistent-home-1" \
    ORCH_SESS_GLOB="/nonexistent-sess-1" \
    ORCH_PEAK_TEST="$SCRATCH/test_$tag" \
    ORCH_LOG="$SCRATCH/peak_log_$tag" \
    bash "$SBIN/orch-peak" warn >"$SCRATCH/out_$tag" 2>&1
  subj_rc=$?
}

# ── Прогон A: честная установленная пара (позитив И-1/И-2) ────────────────────
run_subj A
if [ -e "$SVID_REPO" ]; then
  printf 'КРАСНО: bootstrap исполнен из репо: root запускает неустановленный код — свидетель %s создан (И-1/И-2 пробито)\n' "$SVID_REPO" >&2
  exit 1
fi
if [ "$subj_rc" -ne 0 ]; then
  printf 'КРАСНО: прогон A отказал (rc=%s) — честная установленная пара (root-модель stat-шима А-6) не принята bootstrap-ом: %s\n' "$subj_rc" "$(tr '\n' ' ' < "$SCRATCH/out_A")" >&2
  exit 1
fi

# ── Прогон B: подмена СОДЕРЖИМОГО установленного bootstrap (негатив И-1, А-2) ─
# Inplace-перезапись: путь/режим/владелец/сайдкары установщика не тронуты,
# отличается только содержимое — живой обход adversary из §verification
# круга 2 (POISON_EXECUTED).
printf '%s\n' '#!/usr/bin/env bash' "touch '$SVID_LIB'" > "$SBIN/lib_session.sh"
run_subj B
if [ -e "$SVID_LIB" ]; then
  printf 'КРАСНО: подменённый установленный bootstrap исполнен: root источает OPS_SERVER_LIB_DST без sha-сверки — свидетель %s создан (И-1, обход А-1 круга 2)\n' "$SVID_LIB" >&2
  exit 1
fi
if [ -e "$SVID_REPO" ]; then
  printf 'КРАСНО: подмена установленного bootstrap ушла тихим fallback на ${REPO} — свидетель %s создан (И-1)\n' "$SVID_REPO" >&2
  exit 1
fi
if [ "$subj_rc" -eq 0 ]; then
  printf 'КРАСНО: подмена установленного bootstrap не отказана (rc=0 — библиотека принята без sha-сверки, И-1)\n' >&2
  exit 1
fi
if ! grep -Eq 'И-1|подмен|bootstrap-библиотек|sha256' "$SCRATCH/out_B" "$SCRATCH/peak_log_B" 2>/dev/null; then
  printf 'КРАСНО: отказ подмены установленного bootstrap не именован (нет маркера И-1/подмены ни в выводе, ни в журнале, И-1)\n' >&2
  exit 1
fi

# ── Прогон C: отсутствие установленного bootstrap (негатив И-1) ──────────────
rm -f "$SBIN/lib_session.sh"
run_subj C
if [ "$subj_rc" -eq 0 ]; then
  printf 'КРАСНО: отсутствие установленного bootstrap не отказано (rc=0, И-1)\n' >&2
  exit 1
fi
if [ -e "$SVID_REPO" ]; then
  printf 'КРАСНО: при отсутствии bootstrap исполнен код из ${REPO} — свидетель %s создан (И-1)\n' "$SVID_REPO" >&2
  exit 1
fi
if ! grep -Eq 'И-1|подмен|bootstrap-библиотек|sha256' "$SCRATCH/out_C" "$SCRATCH/peak_log_C" 2>/dev/null; then
  printf 'КРАСНО: отказ отсутствия bootstrap не именован (нет маркера И-1 в выводе/журнале, И-1)\n' >&2
  exit 1
fi

# ── Свидетель И-2: ни один путь toy-REPO не изменён всеми тремя прогонами ────
find "$TOY_REPO" -type f | LC_ALL=C sort | xargs -I {} stat -c '%n %Y' {} > "$SCRATCH/repo_after"
if ! /usr/bin/cmp -s "$SCRATCH/repo_before" "$SCRATCH/repo_after"; then
  printf 'КРАСНО: toy-REPO изменён субъектом (И-2)\n' >&2
  diff "$SCRATCH/repo_before" "$SCRATCH/repo_after" >&2
  exit 1
fi

printf 'ЗЕЛЁНО(093-1): установленный bootstrap честно исполнен, подмена установленного файла и его отсутствие — именованный отказ без fallback, ${REPO} не тронут (И-1/И-2)\n' >&2
exit 0
