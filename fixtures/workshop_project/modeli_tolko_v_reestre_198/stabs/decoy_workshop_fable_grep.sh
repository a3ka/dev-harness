#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ (контракт 198): «шов --fable с жёстким семейством». Копия
# ДО-правки: модель режима читается grep-ом литерального семейства из
# config/agent_models.json, а не назначением роли consultant через единый
# резолвер. Устанавливается на место workshop в мутант-корне; ловится repo-
# клеткой repo_seam_no_registry_read (шов сам называет файл реестра —
# свойство, действующее на любую форму собственного чтения).
if [ "$FABLE" = "1" ]; then
  LIVE_MODEL="$(grep -oE '^\s+"fable":\s*"[^"]+"' "$HERE/config/agent_models.json" | sed 's/.*"\(.*\)"/\1/')"
  [ -n "$LIVE_MODEL" ] || die "семейство fable не объявлено в config/agent_models.json (секция models)"
  printf '  РЕЖИМ FABLE  консультант read-only на %s — параллельно оркестратору\n' "$LIVE_MODEL" >&2
fi
