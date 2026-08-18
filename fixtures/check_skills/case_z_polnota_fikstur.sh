# ПРИЧИНА: полнота фикстур
#
# Ветвь (з): на родителе первого коммита по skills/ все 8 фикстур.
# Зелёный: фикстуры закоммичены РАНЬШЕ скилов → родитель skills-коммита содержит их → 0.
# Красное: скилы без фикстур на родителе → код 1.
set -euo pipefail

mk() { # <root> <fixtures_first>
  local r="$1" first="$2" f
  mkdir -p "$r/skills/grilling" "$r/skills/writing-for-agents" "$r/skills/tdd" "$r/skills/diagnosing-bugs" "$r/fixtures/check_skills" "$r/tmp"
  for s in grilling writing-for-agents tdd diagnosing-bugs; do
    printf -- '---\nname: %s\ndescription: stub\n---\n# grill-me\nstub\n' "$s" > "$r/skills/$s/SKILL.md"
  done
  if [ "$first" = yes ]; then
    for f in case_a_ne_obnaruzhen case_b_imja_kataloga case_v_hash_ne_sovpadaet case_g_katalog_vne_mnozhestva case_d_profil_iz_pustogo case_e_telo_ne_sovpadaet case_z_polnota_fikstur case_zh_psevdonim_grill_me; do
      printf "# stub\n" > "$r/fixtures/check_skills/${f}.sh"
    done
  fi
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r" >/dev/null
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.name F
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" config user.email f@l
  if [ "$first" = yes ]; then
    GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" add fixtures/
    GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" commit -q -m fixtures-first
  fi
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" add skills/
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" commit -q -m skills
  if [ "$first" != yes ]; then
    for f in case_a_ne_obnaruzhen case_b_imja_kataloga case_v_hash_ne_sovpadaet case_g_katalog_vne_mnozhestva case_d_profil_iz_pustogo case_e_telo_ne_sovpadaet case_z_polnota_fikstur case_zh_psevdonim_grill_me; do
      printf "# stub\n" > "$r/fixtures/check_skills/${f}.sh"
    done
    GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" add fixtures/
    GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r" commit -q -m fixtures-late
  fi
}

mk "$WORK/green" yes
"$BARRIER" "$WORK/green"

mk "$WORK/red" no
"$BARRIER" "$WORK/red"
