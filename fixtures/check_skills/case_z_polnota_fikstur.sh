# ПРИЧИНА: полнота фикстур
# ОКРУЖЕНИЕ: PATH=$WORK/bin:$PATH
#
# Ветвь (з): на родителе первого коммита по skills/ лежат все 8 фикстур, и КАЖДЫЙ
# коммит, когда-либо затрагивавший fixtures/check_skills/, — от architect.
# Зелёный: фикстуры закоммичены РАНЬШЕ скилов, все авторы — architect → 0.
# Красное 1 (прежнее): скилы без фикстур на родителе → код 1.
# Красное 2 — из вердикта адверсария milestone-003-zakrytie §3: implementer
# коммитит правку фикстуры ПОСЛЕ стартового коммита архитектора — судятся все
# коммиты, не только первый.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
stub_omp "$WORK/bin"

mk() { # <root> <fixtures_first>
  local r="$1" first="$2" f
  mkdir -p "$r/skills/grilling" "$r/skills/writing-for-agents" "$r/skills/tdd" "$r/skills/diagnosing-bugs" "$r/fixtures/check_skills" "$r/tmp"
  for s in grilling writing-for-agents tdd diagnosing-bugs; do
    printf -- '---\nname: %s\ndescription: stub\n---\nstub body sentinel for %s\n' "$s" "$s" > "$r/skills/$s/SKILL.md"
  done
  printf '# grill-me\n' >> "$r/skills/grilling/SKILL.md"
  if [ "$first" = yes ]; then
    for f in case_a_ne_obnaruzhen case_b_imja_kataloga case_v_hash_ne_sovpadaet case_g_katalog_vne_mnozhestva case_d_profil_iz_pustogo case_e_telo_ne_sovpadaet case_z_polnota_fikstur case_zh_psevdonim_grill_me; do
      printf "# stub\n" > "$r/fixtures/check_skills/${f}.sh"
    done
  fi
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r" >/dev/null
  if [ "$first" = yes ]; then
    GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
      git -C "$r" -c user.name=architect -c user.email=architect@dev-harness.local add fixtures/
    GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
      git -C "$r" -c user.name=architect -c user.email=architect@dev-harness.local commit -q -m fixtures-first
  fi
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$r" -c user.name=architect -c user.email=architect@dev-harness.local add skills/
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$r" -c user.name=architect -c user.email=architect@dev-harness.local commit -q -m skills
  if [ "$first" != yes ]; then
    for f in case_a_ne_obnaruzhen case_b_imja_kataloga case_v_hash_ne_sovpadaet case_g_katalog_vne_mnozhestva case_d_profil_iz_pustogo case_e_telo_ne_sovpadaet case_z_polnota_fikstur case_zh_psevdonim_grill_me; do
      printf "# stub\n" > "$r/fixtures/check_skills/${f}.sh"
    done
    GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
      git -C "$r" -c user.name=architect -c user.email=architect@dev-harness.local add fixtures/
    GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
      git -C "$r" -c user.name=architect -c user.email=architect@dev-harness.local commit -q -m fixtures-late
  fi
}

mk "$WORK/green" yes
"$BARRIER" "$WORK/green"

# Порча 1: фикстуры закоммичены ПОЗЖЕ скилов — на родителе их нет
mk "$WORK/red" no
"$BARRIER" "$WORK/red"

# Порча 2: implementer правит фикстуру после стартового коммита архитектора
printf '# probe\n' >> "$WORK/green/fixtures/check_skills/case_b_imja_kataloga.sh"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/green" -c user.name=implementer -c user.email=implementer@dev-harness.local add -A fixtures/
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/green" -c user.name=implementer -c user.email=implementer@dev-harness.local commit -q -m 'probe fixture change'
"$BARRIER" "$WORK/green"
