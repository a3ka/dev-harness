# ПРИЧИНА: предмет исчез
# ОКРУЖЕНИЕ: PATH=$WORK/repo/bin:$PATH
#
# Круг 4 адверсария, находка 1 (verdicts/adversary/milestone-003-zakrytie-3.md):
# удаление skills/ и .agents/skills в чекауте, где ИСТОРИЯ коммитов по skills/ есть,
# проходило как базовый, так и --live барьер. Порченный чекаут предмета — не
# изолированный контракт: исчезновение предмета обязано быть отказом.
# Зелёный контроль: дерево с историей целиком → 0. Красное: skills/ и .agents/skills
# удалены из того же дерева → код 1.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_tree "$R"
for f in case_a_ne_obnaruzhen case_b_imja_kataloga case_v_hash_ne_sovpadaet case_g_katalog_vne_mnozhestva case_d_profil_iz_pustogo case_e_telo_ne_sovpadaet case_z_polnota_fikstur case_zh_psevdonim_grill_me; do
  printf "# stub\n" > "$R/fixtures/check_skills/${f}.sh"
done
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$R" >/dev/null
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" -c user.name=architect -c user.email=architect@dev-harness.local add fixtures/
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" -c user.name=architect -c user.email=architect@dev-harness.local commit -q -m fixtures-first
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" -c user.name=architect -c user.email=architect@dev-harness.local add -A
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" -c user.name=architect -c user.email=architect@dev-harness.local commit -q -m 'предмет целиком'
"$BARRIER" --live "$R"

# Порча: предмет исчез из чекаута, история осталась
rm -rf "$R/skills" "$R/.agents"
"$BARRIER" --live "$R"
