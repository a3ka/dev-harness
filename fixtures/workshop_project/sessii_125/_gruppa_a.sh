#!/usr/bin/env bash
# Группа A батареи 125: сверщик сессий (субъект CHK). Источится раннером red_sessii_125.sh.
# Мир: дом зоны dev Z (профиль dev; конфигурация + живое состояние dev), установка H
# (политика, расширения, агенты), ОТДЕЛЬНЫЙ дом проекта P/home с честным севом
# (побайтные копии перечня сева, agent.db — симлинк W8, своё состояние проекта), проект R.
# Факты запусков пишет сама клетка в формате стаба-omp (argv по строке, env KEY=VALUE).
# Оракул — литерал ТОЧНОГО stdout клетки (все причины в порядке перечня, ни одной посторонней),
# снятый ДО вызова субъекта (правило 8); значения случайны.
a_world() { # $1 = каталог мира
  local W=$1 A PA f
  A="$W/Z/.omp/profiles/dev/agent"; PA="$W/P/home/.omp/profiles/dev/agent"
  mkdir -p "$A/agents" "$A/sessions/2026" "$A/blobs" "$A/terminal-sessions" "$A/custom-session-files" \
    "$W/H/.omp/extensions" "$W/H/.omp/agents" "$W/R/.git" "$PA/sessions"
  printf 'theme: toy-%s\n' "$RANDOM$RANDOM" > "$A/config.yml"
  for f in models.db agent.db skill-descriptions.db history.db; do printf '%s-%s' "$f" "$RANDOM$RANDOM" > "$A/$f"; done
  printf 'session-%s\n' "$RANDOM$RANDOM" > "$A/sessions/2026/s-$RANDOM.jsonl"
  printf 'blob-%s' "$RANDOM$RANDOM" > "$A/blobs/b-$RANDOM"
  printf 'term-%s\n' "$RANDOM" > "$A/terminal-sessions/t1"
  printf 'csf-%s\n' "$RANDOM" > "$A/custom-session-files/f.txt"
  printf '# role orchestrator %s\n' "$RANDOM" > "$A/agents/orchestrator.md"
  printf 'modelRoles:\n  default: "toy/m-%s"\n' "$RANDOM" > "$W/H/.omp/config.yml"
  printf '// ext\n' > "$W/H/.omp/extensions/guard-$RANDOM.ts"
  printf '# local agent %s\n' "$RANDOM" > "$W/H/.omp/agents/architect.md"
  cp "$W/H/.omp/agents/architect.md" "$A/agents/architect.md"   # честная раскладка ролей установки в профиль
  printf '# роль\n\n## Правила, каждое из которых уже стоило время\n- правило %s\n' "$RANDOM" > "$W/prompt-main.md"
  { cat "$W/prompt-main.md"; printf '## Маршруты проекта (R1-R3, контракт 060)\nHARNESS_WORKFLOW_ROOT=%s\n' "$W/R"; } > "$W/prompt-proj.md"
  # честный сев: побайтные копии перечня, agent.db — симлинк W8, роли — раскладка генератора
  for f in config.yml models.db skill-descriptions.db; do cp "$A/$f" "$PA/$f"; done
  ln -s "$A/agent.db" "$PA/agent.db"
  cp -R "$A/agents" "$PA/agents"
  # своё состояние проекта (не dev): своя сессия, своя история
  printf 'own-session-%s\n' "$RANDOM$RANDOM" > "$PA/sessions/own-$RANDOM.jsonl"
  printf 'own-history-%s' "$RANDOM$RANDOM" > "$PA/history.db"
}
a_main() { # $1 = мир; факты основной сессии (дев-вход: cwd = установка, без -e/--config)
  local W=$1
  printf '%s\n' --profile dev --model toy/m1 --append-system-prompt "$W/prompt-main.md" --tools read,bash > "$W/main.argv"
  printf 'HOME=%s\nPWD=%s\n' "$W/Z" "$W/H" > "$W/main.env"
}
a_proj() { # $1 = мир; $2.. = переопределения KEY=VAL (home pwd model tools approval cfg ext prompt profile)
  local W=$1; shift
  local home="$W/P/home" pwd="$W/R" model=toy/m1 tools=read,bash approval= cfg="$W/H/.omp/config.yml" prompt="$W/prompt-proj.md" profile=dev ext=
  ext=$(ls "$W"/H/.omp/extensions/*.ts)
  local kv; for kv in "$@"; do eval "${kv%%=*}=\"\${kv#*=}\""; done
  {
    printf '%s\n' --profile "$profile" --model "$model" --config "$cfg"
    [ -n "$ext" ] && printf '%s\n' -e "$ext"
    [ -n "$approval" ] && printf '%s\n' --approval-mode "$approval"
    printf '%s\n' --append-system-prompt "$prompt" --tools "$tools"
  } > "$W/proj.argv"
  printf 'HOME=%s\nPWD=%s\n' "$home" "$pwd" > "$W/proj.env"
}
a_run() { # $1 = мир → OUT, RC
  RC=0
  OUT=$(bash "$CHK" --main-argv "$1/main.argv" --main-env "$1/main.env" --project-argv "$1/proj.argv" --project-env "$1/proj.env" 2>"$1/chk.err") || RC=$?
}
a_cell() { # $1 = id клетки; $2 = ожидаемый rc; $3 = ТОЧНЫЙ ожидаемый stdout (строки через \n; пусто — пустой stdout); $4 = мир
  local id=$1 want=$2 exp=$3 W=$4 ok=1
  a_run "$W"
  [ "$RC" = "$want" ] || ok=0
  [ "$OUT" = "$exp" ] || ok=0     # точное множество причин в порядке перечня: ни недостающей, ни посторонней
  verdict "$id" "$ok" "rc=$RC ждали $want; ждали stdout «$(printf '%s' "$exp" | tr '\n' '|')»; вывод: «$(printf '%s' "$OUT" | tr '\n' '|')»"
}
r() { local p s=""; for p in "$@"; do s="$s${s:+$'\n'}РАСХОЖДЕНИЕ $p"; done; printf '%s' "$s"; }
a_new() { W=$(mktemp -d "$RUNDIR/a-XXXX"); a_world "$W"; a_main "$W"; PA="$W/P/home/.omp/profiles/dev/agent"; A="$W/Z/.omp/profiles/dev/agent"; }
# ── 125 v2: автосверка одной командой (И-9/И-10) ─────────────────────────────
# Мир a27+: дом проекта — ПО ФОРМУЛЕ 055 от XDG_STATE_HOME=<мир>; факты обеих сторон
# записаны «честным лаунчером» (тот же формат, что пишет субъект-workshop) ДО вызова
# субъекта; оракул — литерал ТОЧНОГО stdout/rc в памяти клетки (правило 8).
avto_new() {
  local f ext
  AV_PID=proj125a
  W=$(mktemp -d "$RUNDIR/av-XXXX")
  A="$W/Z/.omp/profiles/dev/agent"
  AV_PSTATE="$W/dev-harness-projects/$AV_PID"
  PA="$AV_PSTATE/home/.omp/profiles/dev/agent"
  mkdir -p "$A/sessions/2026" "$A/blobs" "$A/terminal-sessions" "$A/custom-session-files" "$A/agents" \
    "$W/H/.omp/extensions" "$W/H/.omp/agents" "$W/R/.git" "$PA/sessions"
  printf 'theme: toy-%s\n' "$RANDOM$RANDOM" > "$A/config.yml"
  for f in models.db agent.db skill-descriptions.db history.db; do printf '%s-%s' "$f" "$RANDOM$RANDOM" > "$A/$f"; done
  printf 'session-%s\n' "$RANDOM$RANDOM" > "$A/sessions/2026/s-$RANDOM.jsonl"
  printf 'blob-%s' "$RANDOM$RANDOM" > "$A/blobs/b-$RANDOM"
  printf 'term-%s\n' "$RANDOM" > "$A/terminal-sessions/t1"
  printf 'csf-%s\n' "$RANDOM" > "$A/custom-session-files/f.txt"
  printf '# role orchestrator %s\n' "$RANDOM" > "$A/agents/orchestrator.md"
  printf 'modelRoles:\n  default: "toy/m-%s"\n' "$RANDOM" > "$W/H/.omp/config.yml"
  printf '// ext\n' > "$W/H/.omp/extensions/guard-$RANDOM.ts"
  printf '# local agent %s\n' "$RANDOM" > "$W/H/.omp/agents/architect.md"
  cp "$W/H/.omp/agents/architect.md" "$A/agents/architect.md"
  printf '# роль\n\n## Правила, каждое из которых уже стоило время\n- правило %s\n' "$RANDOM" > "$W/prompt-main.md"
  { cat "$W/prompt-main.md"; printf '## Маршруты проекта (R1-R3, контракт 060)\nHARNESS_WORKFLOW_ROOT=%s\n' "$W/R"; } > "$W/prompt-proj.md"
  for f in config.yml models.db skill-descriptions.db; do cp "$A/$f" "$PA/$f"; done
  ln -s "$A/agent.db" "$PA/agent.db"
  cp -R "$A/agents" "$PA/agents"
  printf 'own-session-%s\n' "$RANDOM$RANDOM" > "$PA/sessions/own-$RANDOM.jsonl"
  printf 'own-history-%s' "$RANDOM$RANDOM" > "$PA/history.db"
  # 125-А1 (решение 6): профиль корня — В ФОРМЕ ДВЕРИ (резолвер 054): репо-слой
  # harness.project.json → projectLayer.profilePath → слой проекта .projectId
  mkdir -p "$W/R/.harness"
  printf '{"schemaVersion":1,"repoId":"%s","projectLayer":{"profilePath":".harness/project-layer.json"}}\n' "$AV_PID" > "$W/R/harness.project.json"
  printf '{"schemaVersion":1,"version":"v1","projectId":"%s","workspaceId":"%s"}\n' "$AV_PID" "$AV_PID" > "$W/R/.harness/project-layer.json"
  ext=$(ls "$W"/H/.omp/extensions/*.ts)
  mkdir -p "$W/Z/session-exec" "$AV_PSTATE/session-exec"
  printf '%s\n' --profile dev --model toy/m1 --append-system-prompt "$W/prompt-main.md" --tools read,bash > "$W/Z/session-exec/argv"
  printf 'HOME=%s\nPWD=%s\n' "$W/Z" "$W/H" > "$W/Z/session-exec/env"
  printf '{"rezhim":"main","projectId":null,"pid":111,"start":"2026-11-17T00:00:00Z","rol":"orchestrator"}\n' > "$W/Z/session-exec/meta"
  printf '%s\n' --profile dev --model toy/m1 --config "$W/H/.omp/config.yml" -e "$ext" --append-system-prompt "$W/prompt-proj.md" --tools read,bash > "$AV_PSTATE/session-exec/argv"
  printf 'HOME=%s\nPWD=%s\n' "$AV_PSTATE/home" "$W/R" > "$AV_PSTATE/session-exec/env"
  printf '{"rezhim":"project","projectId":"%s","pid":222,"start":"2026-11-17T00:00:01Z","rol":"orchestrator"}\n' "$AV_PID" > "$AV_PSTATE/session-exec/meta"
  { printf '{'; local sep=""
    for f in config.yml models.db skill-descriptions.db; do
      printf '%s"%s":{"sha-istochnik":"%s","sha-kopija":"%s"}' "$sep" "$f" \
        "$(sha256sum < "$A/$f" | cut -c1-64)" "$(sha256sum < "$PA/$f" | cut -c1-64)"; sep=,
    done; printf '}\n'; } > "$AV_PSTATE/session-exec/sev.json"
}
avto_run() { # $1 = мир; далее env KEY=VAL → OUT, RC (сверка «из основной сессии»)
  local W1=$1 kv
  local envs=(HARNESS_SESSION_HOME="$W1/Z" XDG_STATE_HOME="$W1" HOME="$W1/hh")
  for kv in "${@:2}"; do envs+=("${kv%%=*}=${kv#*=}"); done
  RC=0
  OUT=$(env "${envs[@]}" bash "$CHK" --avto "$W1/R" 2>"$W1/chk.err") || RC=$?
}
avto_cell() { # $1 id; $2 rc; $3 ТОЧНЫЙ stdout; $4 мир; далее env
  local id=$1 want=$2 exp=$3 W1=$4; shift 4
  avto_run "$W1" "$@"
  local ok=1
  [ "$RC" = "$want" ] || ok=0
  [ "$OUT" = "$exp" ] || ok=0
  verdict "$id" "$ok" "rc=$RC ждали $want; ждали stdout «$(printf '%s' "$exp" | tr '\n' '|')»; вывод: «$(printf '%s' "$OUT" | tr '\n' '|')»"
}
gruppa_a() {
  local W PA A pole fn
  a_new; a_proj "$W"
  a_cell a01-chestnaya 0 "" "$W"
  # вариант А (общий дом): сев — файлы дома dev, agent.db — сама база, живое состояние dev — в доме сессии
  a_new; a_proj "$W" home="$W/Z"
  a_cell a02-dom-obshij 1 "$(r dom config-yml models-db skill-descriptions-db agent-db ne-sessii)" "$W"
  for pole in config-yml:config.yml models-db:models.db skill-descriptions-db:skill-descriptions.db; do
    fn=${pole#*:}; pole=${pole%%:*}
    a_new; a_proj "$W"; printf ' drift-%s' "$RANDOM" >> "$PA/$fn"      # тот же файл есть, содержимое ушло
    a_cell "a03-drejf-$pole" 1 "$(r "$pole")" "$W"
  done
  for pole in config-yml:config.yml models-db:models.db; do
    fn=${pole#*:}; pole=${pole%%:*}
    a_new; a_proj "$W"; rm "$PA/$fn"; ln -s "$A/$fn" "$PA/$fn"   # сев ссылкой: запись проекта пишет в dev
    a_cell "a04-ssylka-$pole" 1 "$(r "$pole")" "$W"
  done
  a_new; a_proj "$W"; rm "$PA/config.yml"; ln "$A/config.yml" "$PA/config.yml"   # сев жёсткой ссылкой: тот же inode
  a_cell a04-zhestkaya-config-yml 1 "$(r config-yml)" "$W"
  a_new; a_proj "$W"; rm "$PA/config.yml"
  a_cell a05-net-config-yml 1 "$(r config-yml)" "$W"
  a_new; a_proj "$W"; rm "$PA/agent.db"; cp "$A/agent.db" "$PA/agent.db"
  a_cell a06-agentdb-kopiya 1 "$(r agent-db)" "$W"
  a_new; a_proj "$W"; cp -R "$A/sessions/2026" "$PA/sessions/2026"
  a_cell a07-sessii-kopiya 1 "$(r ne-sessii)" "$W"
  a_new; a_proj "$W"; rm "$PA/history.db"; ln -s "$A/history.db" "$PA/history.db"
  a_cell a07-history-ssylka 1 "$(r ne-sessii)" "$W"
  a_new; a_proj "$W"; cp -R "$A/blobs" "$PA/blobs"
  a_cell a07-blobs-kopiya 1 "$(r ne-sessii)" "$W"
  # живое состояние dev ПОД ДРУГИМ ИМЕНЕМ: сверка по содержимому и цели ссылки, не по имени
  a_new; a_proj "$W"; cp "$A/history.db" "$PA/imported-history.db"
  a_cell a07-history-pereimenovana 1 "$(r ne-sessii)" "$W"
  a_new; a_proj "$W"; cp "$A"/sessions/2026/*.jsonl "$PA/sessions/renamed.jsonl"
  a_cell a07-sessiya-pereimenovana 1 "$(r ne-sessii)" "$W"
  a_new; a_proj "$W"; mkdir -p "$W/P/home/.cache/x"; cp "$A"/blobs/* "$W/P/home/.cache/x/stash.bin"
  a_cell a07-vne-profilya 1 "$(r ne-sessii)" "$W"
  a_new; a_proj "$W"; ln -s "$A/history.db" "$PA/h2.db"
  a_cell a07-ssylka-pereimenovana 1 "$(r ne-sessii)" "$W"
  # ── Т-2 транзитивная достижимость каталога агента dev из дома проекта (закрытая таблица) ──
  a_new; a_proj "$W"; mkdir -p "$W/P/home/.cache"; ln -s "$A/models.db" "$W/P/home/.cache/m.db"
  a_cell a19-dost-fajl-dev 1 "$(r ne-sessii)" "$W"
  a_new; a_proj "$W"; ln -s "$A/agents" "$W/P/home/dev-agents"
  a_cell a20-dost-podkatalog 1 "$(r ne-sessii)" "$W"
  a_new; a_proj "$W"; ln -s "$A" "$W/P/home/dev-profile"           # сам каталог агента dev
  a_cell a21-dost-katalog-agenta 1 "$(r ne-sessii)" "$W"
  a_new; a_proj "$W"; ln -s "$W/Z" "$W/P/home/dev-home"            # РОДИТЕЛЬ: дом dev целиком
  a_cell a21-dost-roditel 1 "$(r ne-sessii)" "$W"
  a_new; a_proj "$W"; mkdir -p "$W/X"; ln -s "$W/Z/.omp/profiles/dev" "$W/X/c"; ln -s "$W/X/c" "$W/P/home/b"; ln -s "$W/P/home/b" "$W/P/home/a"
  a_cell a22-dost-cepochka 1 "$(r ne-sessii)" "$W"                 # A → B → C → предок агента dev
  a_new; a_proj "$W"; ln -s ../../Z/.omp/profiles "$W/P/home/rel"   # относительная ../..
  a_cell a23-dost-otnositelnaya 1 "$(r ne-sessii)" "$W"
  a_new; a_proj "$W"; mkdir -p "$W/X"; ln -s "$A/history.db" "$W/X/inner"; ln -s "$W/X" "$W/P/home/ext"
  a_cell a26-dost-cherez-katalog 1 "$(r ne-sessii)" "$W"           # каталог-ссылка наружу, внутри — ссылка в dev
  a_new; a_proj "$W"; mkdir -p "$W/P/home/.local"; ln "$A/history.db" "$W/P/home/.local/h.db"
  a_cell a24-dost-hardlink 1 "$(r ne-sessii)" "$W"
  a_new; a_proj "$W"; : > "$A/history.db"; mkdir -p "$W/P/home/.local"; ln "$A/history.db" "$W/P/home/.local/h.db"
  a_cell a25-dost-hardlink-pustoj 1 "$(r ne-sessii)" "$W"          # пустой: содержимым не виден, inode — виден
  # другой профиль, сам по себе засеянный честно — расходится ТОЛЬКО profil
  a_new; mkdir -p "$W/P/home/.omp/profiles/proj"; cp -R "$PA" "$W/P/home/.omp/profiles/proj/agent"; a_proj "$W" profile=proj
  a_cell a08-profil 1 "$(r profil)" "$W"
  a_new; a_proj "$W" approval=yolo
  a_cell a09-podtverzhdeniya 1 "$(r podtverzhdeniya)" "$W"
  a_new; a_proj "$W" model=toy/m2
  a_cell a10-model 1 "$(r model)" "$W"
  a_new; a_proj "$W" tools=read
  a_cell a11-instrumenty 1 "$(r instrumenty)" "$W"
  a_new; cp "$W/H/.omp/config.yml" "$W/cfg-copy.yml"; a_proj "$W" cfg="$W/cfg-copy.yml"
  a_cell a12-politika 1 "$(r politika)" "$W"
  a_new; a_proj "$W" ext=
  a_cell a13-rasshireniya 1 "$(r rasshireniya)" "$W"
  a_new; sed 's/^- правило /- ослаблено /' "$W/prompt-proj.md" > "$W/prompt-weak.md"; a_proj "$W" prompt="$W/prompt-weak.md"
  a_cell a14-pravila 1 "$(r pravila)" "$W"
  a_new; a_proj "$W"; rm "$PA/agents/architect.md"
  a_cell a15-agenty 1 "$(r agenty)" "$W"
  # составное расхождение: ровно три причины в порядке ПЕРЕЧНЯ (model раньше instrumenty — не алфавит)
  a_new; a_proj "$W" model=toy/m2 tools=read approval=yolo
  a_cell a16-tri-prichiny 1 "$(r model instrumenty podtverzhdeniya)" "$W"
  # rc 2: нечем проверить
  a_new; a_proj "$W"; : > "$W/proj.argv"
  a_cell a17-nechem-pustye-fakty 2 "НЕЧЕМ-ПРОВЕРИТЬ fakty-otsutstvuyut" "$W"
  a_new; a_proj "$W"; rm "$A/config.yml"
  a_cell a18-nechem-osnovnaya-bez-config 2 "НЕЧЕМ-ПРОВЕРИТЬ osnovnaya-bez-config-yml" "$W"
  # ── 125 v2: автосверка --avto <корень> (И-9/И-10); stdout/rc — ТОЧНЫЙ литерал ──
  # честный мир + ПОДДЕЛЬНЫЕ факты в дереве проекта: сверка им не доверяет (п.8)
  avto_new
  mkdir -p "$W/R/.harness/session-exec"
  printf '%s\n' --profile dev --model toy/m9 > "$W/R/.harness/session-exec/argv"
  printf 'HOME=%s\nPWD=%s\n' "$W/R" "$W/R" > "$W/R/.harness/session-exec/env"
  printf '{"rezhim":"project","projectId":"%s","pid":9,"start":"x","rol":"o"}\n' "$AV_PID" > "$W/R/.harness/session-exec/meta"
  avto_cell a27-avto-chestnaya 0 "" "$W"
  # запись проектных фактов несёт чужую модель — сверка судит ЗАПИСЬ, не реконструкцию
  avto_new
  awk -v m=toy/m2 '/^--model$/ {print; getline; print m; next} {print}' \
    "$AV_PSTATE/session-exec/argv" > "$AV_PSTATE/session-exec/argv.t"
  mv "$AV_PSTATE/session-exec/argv.t" "$AV_PSTATE/session-exec/argv"
  avto_cell a28-avto-model-chuzhoj 1 "$(r model)" "$W"
  avto_new
  awk 'p==1 {p=0; next} /^--config$/ {p=1; next} {print}' \
    "$AV_PSTATE/session-exec/argv" > "$AV_PSTATE/session-exec/argv.t"
  mv "$AV_PSTATE/session-exec/argv.t" "$AV_PSTATE/session-exec/argv"
  avto_cell a29-avto-politika 1 "$(r politika)" "$W"
  avto_new
  awk 'p==1 {p=0; next} /^-e$/ {p=1; next} {print}' \
    "$AV_PSTATE/session-exec/argv" > "$AV_PSTATE/session-exec/argv.t"
  mv "$AV_PSTATE/session-exec/argv.t" "$AV_PSTATE/session-exec/argv"
  avto_cell a30-avto-rasshireniya 1 "$(r rasshireniya)" "$W"
  # запись сева лжёт о побайтности (sha источника ≠ sha копии) — ровно своё поле
  avto_new
  jq --arg k "$(printf 'a%.0s' $(seq 64))" '.["models.db"]["sha-kopija"]=$k' \
    "$AV_PSTATE/session-exec/sev.json" > "$AV_PSTATE/session-exec/sev.json.t"
  mv "$AV_PSTATE/session-exec/sev.json.t" "$AV_PSTATE/session-exec/sev.json"
  avto_cell a31-avto-sev-zapisi 1 "$(r models-db)" "$W"
  # запись сева заявляет файл вне перечня (history.db — «никогда не сеется»)
  avto_new
  jq --arg k "$(printf 'b%.0s' $(seq 64))" '. + {"history.db":{"sha-istochnik":$k,"sha-kopija":$k}}' \
    "$AV_PSTATE/session-exec/sev.json" > "$AV_PSTATE/session-exec/sev.json.t"
  mv "$AV_PSTATE/session-exec/sev.json.t" "$AV_PSTATE/session-exec/sev.json"
  avto_cell a32-avto-sev-lishnee 1 "$(r ne-sessii)" "$W"
  avto_new; rm -rf "$W/Z/session-exec"
  avto_cell a33-avto-fakty-osnovnoj 2 "НЕЧЕМ-ПРОВЕРИТЬ fakty-osnovnoj-net" "$W"
  avto_new; rm -rf "$AV_PSTATE/session-exec"
  avto_cell a34-avto-fakty-proekta 2 "НЕЧЕМ-ПРОВЕРИТЬ fakty-proekta-net" "$W"
  # сверка, запущенная ВНУТРИ сессии проекта: фактов основной там нет — правдивый отказ
  avto_new
  avto_cell a35-avto-v-proektnoj 2 "НЕЧЕМ-ПРОВЕРИТЬ fakty-osnovnoj-net" "$W" HARNESS_SESSION_HOME="$AV_PSTATE/home"
  # основная перегенерила агенты ПОСЛЕ старта проекта — устаревшая сторона, честное поле
  avto_new; printf '\n- новая норма %s\n' "$RANDOM" >> "$A/agents/orchestrator.md"
  avto_cell a36-avto-storona-staree 1 "$(r agenty)" "$W"
  # живой omp переписал свою копию models.db после старта — сев судится записью (R15)
  avto_new; printf 'catalog-%s' "$RANDOM$RANDOM" > "$PA/models.db"
  avto_cell a37-avto-perezapis-omp 0 "" "$W"
  # факты проекта — только через env-цепочку базиса (не дефолтный $HOME/.local/state)
  avto_new
  avto_cell a38-avto-baza-env 0 "" "$W"
  avto_new; sed -i 's/"projectId":"proj125a"/"projectId":"Proj 125!"/' "$W/R/.harness/project-layer.json"
  avto_cell a39-avto-projectid-vne-klassa 2 "НЕЧЕМ-ПРОВЕРИТЬ projectid-vne-klassa" "$W"
  avto_new; sed -i 's/"projectId":"proj125a"/"projectId":"chuzhoj"/' "$AV_PSTATE/session-exec/meta"
  avto_cell a40-avto-fakty-chuzhie 2 "НЕЧЕМ-ПРОВЕРИТЬ fakty-proekta-chuzhie" "$W"
  avto_new; printf 'не json\n' > "$AV_PSTATE/session-exec/sev.json"
  avto_cell a41-avto-sev-povverzhen 2 "НЕЧЕМ-ПРОВЕРИТЬ sev-fakty-povverzdeny" "$W"
  avto_new; avto_run "$W"
  RC2=0; OUT2=$(env HARNESS_SESSION_HOME="$W/Z" XDG_STATE_HOME="$W" HOME="$W/hh" bash "$CHK" --avto "$W/koren-netu" 2>/dev/null) || RC2=$?
  ok=1; [ "$RC2" = 2 ] && [ "$OUT2" = "НЕЧЕМ-ПРОВЕРИТЬ koren-otsutstvuet" ] || ok=0
  verdict a42-avto-koren-otsutstvuet "$ok" "rc=$RC2 вывод «$(printf '%s' "$OUT2" | tr '\n' '|')» ждали koren-otsutstvuet"
  # предшествование базиса: HARNESS_SCRATCH выше XDG_STATE_HOME (как у лаунчера 055)
  avto_new; W2=$(mktemp -d "$RUNDIR/av2-XXXX"); mv "$W/dev-harness-projects" "$W2/dev-harness-projects"
  AV_PSTATE="$W2/dev-harness-projects/$AV_PID"
  sed -i "s|^HOME=$W/dev-harness-projects/|HOME=$W2/dev-harness-projects/|" "$AV_PSTATE/session-exec/env"
  avto_cell a43-avto-baza-predshhestvie 0 "" "$W" HARNESS_SCRATCH="$W2"
  # ── 125-А1 (арбитраж 1): решения 3–6 — изоляция сева в --avto, именованные отказы, CLI-стык ──
  # решение 3, класс (а): связь файла сева с dev видна и в --avto — inode всего перечня
  # (замер арбитра 2: --avto принимал hardlink config.yml → rc 0); положительный
  # контроль — a37 (omp-перезапись своей копии, rc 0): живые байты НЕ пересматриваются
  avto_new; rm "$PA/config.yml"; ln "$A/config.yml" "$PA/config.yml"
  rm "$PA/models.db"; ln "$A/models.db" "$PA/models.db"
  rm "$PA/skill-descriptions.db"; ln "$A/skill-descriptions.db" "$PA/skill-descriptions.db"
  avto_cell a44-avto-sev-inode 1 "$(r config-yml models-db skill-descriptions-db)" "$W"
  avto_new; rm "$PA/models.db"; ln -s "$A/models.db" "$PA/models.db"
  avto_cell a45-avto-sev-ssylka 1 "$(r models-db)" "$W"
  # решение 6, класс (д): файл-ключ рядом с --avto — kljuch-neizvesten (И-10.1)
  avto_new
  RC2=0; OUT2=$(env HARNESS_SESSION_HOME="$W/Z" XDG_STATE_HOME="$W" HOME="$W/hh" \
    bash "$CHK" --avto "$W/R" --main-argv "$W/Z/session-exec/argv" 2>/dev/null) || RC2=$?
  ok=1; [ "$RC2" = 2 ] && [ "$OUT2" = "НЕЧЕМ-ПРОВЕРИТЬ kljuch-neizvesten" ] || ok=0
  verdict a46-avto-fajl-kljuch "$ok" "rc=$RC2 вывод «$(printf '%s' "$OUT2" | tr '\n' '|')» ждали kljuch-neizvesten"
  # решение 6: отсутствующий sev.json — fakty-proekta-net, НЕ sev-fakty-povverzdeny (замер арбитра 3)
  avto_new; mv "$AV_PSTATE/session-exec/sev.json" "$AV_PSTATE/sev.saved"
  avto_cell a47-avto-sev-netu 2 "НЕЧЕМ-ПРОВЕРИТЬ fakty-proekta-net" "$W"
  avto_new; : > "$AV_PSTATE/session-exec/sev.json"
  avto_cell a48-avto-sev-pustoj 2 "НЕЧЕМ-ПРОВЕРИТЬ fakty-proekta-net" "$W"
  # неполная запись: файл сева есть, записи для него нет — расхождение своего поля (И-10.4)
  avto_new; jq 'del(.["models.db"])' "$AV_PSTATE/session-exec/sev.json" > "$AV_PSTATE/session-exec/sev.json.t"
  mv "$AV_PSTATE/session-exec/sev.json.t" "$AV_PSTATE/session-exec/sev.json"
  avto_cell a49-avto-zapis-nepolnaya 1 "$(r models-db)" "$W"
  # повреждённая СУЩЕСТВУЮЩАЯ запись: схема вне алфавита — povverzdeny
  avto_new; jq '.["models.db"] = {"sha":"x"}' "$AV_PSTATE/session-exec/sev.json" > "$AV_PSTATE/session-exec/sev.json.t"
  mv "$AV_PSTATE/session-exec/sev.json.t" "$AV_PSTATE/session-exec/sev.json"
  avto_cell a50-avto-shema-vne-alfavita 2 "НЕЧЕМ-ПРОВЕРИТЬ sev-fakty-povverzdeny" "$W"
  # объявленный порядок: чужая принадлежность прежде повреждённой записи
  avto_new; sed -i 's/"projectId":"proj125a"/"projectId":"chuzhoj"/' "$AV_PSTATE/session-exec/meta"
  printf 'не json\n' > "$AV_PSTATE/session-exec/sev.json"
  avto_cell a51-avto-chuzhie-ranshe 2 "НЕЧЕМ-ПРОВЕРИТЬ fakty-proekta-chuzhie" "$W"
  # решение 3, зависимый регресс: режим выбирается CLI, не служебными переменными среды
  a_new; a_proj "$W"; rm "$PA/config.yml"; ln "$A/config.yml" "$PA/config.yml"
  RC2=0; OUT2=$(env S125_AVTO=1 S125_SEV_ZAPIS=/dev/null bash "$CHK" \
    --main-argv "$W/main.argv" --main-env "$W/main.env" --project-argv "$W/proj.argv" --project-env "$W/proj.env" 2>/dev/null) || RC2=$?
  ok=1; [ "$RC2" = 1 ] && [ "$OUT2" = "$(r config-yml)" ] || ok=0
  verdict a52-rezhim-tolko-cli "$ok" "rc=$RC2 вывод «$(printf '%s' "$OUT2" | tr '\n' '|')» ждали файл-режим РАСХОЖДЕНИЕ config-yml"
  # решение 4: честный эквивалентный абсолютный путь базиса не отказывается
  avto_new; ln -s "$W" "$W/ekv-baza"
  avto_cell a53-avto-baza-ekvivalent 0 "" "$W" XDG_STATE_HOME="$W/ekv-baza"
}
