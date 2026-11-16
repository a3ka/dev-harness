#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ (контракт 198, мутация MU-2 по вердикту Crit198V1): «шов --fable
# с переиначенным grep семейства». Литеральная привязка в форме "fable"[ ]*:
# (без дословного "fable":) со строкой-упоминанием --resolve-model consultant:
# обходит дословную токен-клетку прежней батареи, оставаясь жёсткой привязкой
# к семейству и собственным чтением реестра лаунчером. Устанавливается на место
# workshop в мутант-корне; ловится repo-клеткой repo_seam_fable_no_registry_values
# (свойство: имена семейств/иды реестра запрещены в блоке ЗНАЧЕНИЯМИ живого
# реестра — переживают любую респелл-форму литерала).
if [ "$FABLE" = "1" ]; then
  # назначение роли consultant — как у roles.ts --resolve-model consultant
  LIVE_MODEL="$(grep -oE '^\s+"fable"[ ]*:\s*"[^"]+"' "$HERE/config/agent_models.json" | sed 's/.*"\(.*\)"/\1/')"
  [ -n "$LIVE_MODEL" ] || die "семейство fable не объявлено в config/agent_models.json (секция models)"
  printf '  РЕЖИМ FABLE  консультант read-only на %s — параллельно оркестратору\n' "$LIVE_MODEL" >&2
fi
