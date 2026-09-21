#!/usr/bin/env bash
# ПРИЧИНА: ПОТРЕБИТЕЛЬ-проба красна
# Барьер check_consumers.sh судит покрытие пробой исполнения (п3): для каждой
# пары (тронутый писатель, его потребитель) контракт обязан нести ПОТРЕБИТЕЛЬ-
# строку, гейт ИСПОЛНЯЕТ её (правило 8: оракул — сам потребитель). Стаб-
# привязка (Н-39): стаб «наличие строки = верифицирован» ловится здесь — проба
# rc≠0 должна отвергаться, не «пройдена как зелёная».
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts" "$G/fixtures" "$G/contracts" "$G/scripts/consumers.d"
printf 'scripts/freeze_contract.sh\tfixtures/reader.sh\n' > "$G/scripts/consumers.d/freeze_contract.sh__reader_sh.tsv"
printf 'scripts/lib_registry.sh\tscripts/spawner.sh\n'    > "$G/scripts/consumers.d/lib_registry.sh__spawner_sh.tsv"
printf 'scripts/done_contract.sh\tscripts/speccer.sh\n'   > "$G/scripts/consumers.d/done_contract.sh__speccer_sh.tsv"
printf '#!/usr/bin/env bash\nexit 0\n' > "$G/scripts/freeze_contract.sh"
printf '#!/usr/bin/env bash\nexit 0\n' > "$G/scripts/lib_registry.sh"
printf '#!/usr/bin/env bash\nexit 0\n' > "$G/scripts/done_contract.sh"
printf '#!/usr/bin/env bash\nexit 0\n' > "$G/scripts/spawner.sh"
printf '#!/usr/bin/env bash\nexit 0\n' > "$G/scripts/speccer.sh"
printf '# consumer fixture\n' > "$G/fixtures/reader.sh"
printf '#!/usr/bin/env bash\nexit 0\n' > "$G/probe_green.sh"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$G" init -q
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$G" config user.name Fixture
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$G" config user.email fixture@local
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$G" add -A
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$G" commit -q -m 'v1 base'
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$G" tag -a frozen/contracts/001/1 -m 'boundary'
printf '#!/usr/bin/env bash\n# pravka v okne\nexit 0\n' > "$G/scripts/freeze_contract.sh"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$G" add -A
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$G" commit -q -m 'pravka pisatelja v okne'
cat > "$G/contracts/001-x.md" <<'MD'
# kontrakt 001 v2

замер: `cat scripts/consumers.d/*.tsv | wc -l` = 3 census scripts/consumers.d/*.tsv

ПОТРЕБИТЕЛЬ fixtures/reader.sh: bash probe_green.sh
MD
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$G" add -A
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$G" commit -q -m 'chernovik v2'
"$BARRIER" "$G" contracts/001-x.md

R="$WORK/red"; mkdir -p "$R/scripts" "$R/fixtures" "$R/contracts" "$R/scripts/consumers.d"
cp -r "$G/." "$R/"
printf '#!/usr/bin/env bash\nexit 1\n' > "$R/probe_red.sh"
cat > "$R/contracts/001-x.md" <<'MD'
# kontrakt 001 v2 red

замер: `cat scripts/consumers.d/*.tsv | wc -l` = 3 census scripts/consumers.d/*.tsv

ПОТРЕБИТЕЛЬ fixtures/reader.sh: bash probe_red.sh
MD
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" add -A
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" commit -q -m 'pravka + krasnaja proba'
"$BARRIER" "$R" contracts/001-x.md
