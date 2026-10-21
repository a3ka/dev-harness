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
}
