#!/usr/bin/env bash
# Клетка Б-5/Н-204 «незавершённый прогон» (контракт 098, §Инварианты Б-5 —
# полный применимый CI; вердикт адверсария contracts-098-v2 A-098-3 BLOCKS;
# вердикт арбитража contracts-098-sufficiency-v1 — ЗАМКНУТОЕ пространство
# предъявлений): завершённость прогона — ЛИТЕРАЛЬНОЕ поле .status ответа CI,
# единственное допустимое значение completed; критерий реализации — ТОЛЬКО
# позитивная сверка с completed. Чёрный список незавершённых значений ОТВЕРГНУТ
# даже исчерпывающий по алфавиту (замер 3 арбитража: пятизначный список
# публикует M на значении вне алфавита и на отсутствующем поле — пространство
# строк бесконечно, терминальное значение одно).
#
# Пространство значений status замкнуто ТРЕМЯ классами (§Критерий арбитража),
# каждое предъявление — на СВОЁМ мире: НОВЕЙШИЙ ПО id одноимённый ci-a,
# conclusion=success, происхождение конформно (head_sha=M, app.slug=пин ciApp,
# wfsha=доверенная), под ним валидная зелёная история ключа:
#   (α) парный позитив КАЖДОГО предъявления (β)/(γ): ТОТ ЖЕ run id, отличие
#       ровно в поле status → completed → ok-строка с run НОВЕЙШЕГО прогона,
#       PUBLISHED ровно M;
#   (β) незавершённые ДОКУМЕНТИРОВАННОГО алфавита — все пять: queued,
#       in_progress, waiting, requested, pending (схема check-run.status
#       OpenAPI GitHub: github/rest-api-description @ 58b1e0c0, enum из шести
#       минус completed; waiting/requested/pending зарезервированы GitHub
#       Actions — производственный CI проекта их ВСТРЕТИТ);
#   (γ) вне алфавита — ДВА свидетеля: (γ1) поле status ОТСУТСТВУЕТ в прогоне
#       (структурно del(.status), не пустая строка); (γ2) nonce — строка,
#       сгенерированная клеткой в МОМЕНТ ИСПОЛНЕНИЯ (x$(od -An -tx1 -N6
#       /dev/urandom | tr -d ' \n')), не равная ни одному значению алфавита —
#       свидетель, которого конечный чёрный список предвидеть не может.
# КАЖДЫЙ класс: писатель обязан отказать «прогон не завершён: ci-a» rc 1 БЕЗ
# записи check-строки (ok обещала бы факт, которого ещё НЕТ), дверь без строки
# — «нет обязательной проверки: ci-a», main неизменен, published нет; парный
# позитив (α) — ok с run НОВЕЙШЕГО и публикация ровно M.
# Почему замкнуто: писатель, зелёный на (β), не держит документированное
# незавершённое значение в белом списке; отвергающий nonce, которого не видел,
# и отсутствующее поле — сверяет ПОЗИТИВНО (чёрный список любой конечной
# длины на (γ2) проходит — замер 3 арбитража). Обман s24 (непустой conclusion
# приравнен завершённости) крас на первом же (β); обман s25 (исчерпывающий
# пятизначный чёрный список) проходит (α) и (β) и красеет (γ) — оба обязаны
# быть пойманы этой клеткой.
# Остаточный риск (арбитраж, НЕ в замороженном тексте): алфавит зафиксирован
# ревизией OpenAPI 58b1e0c0; новое НЕЗАВЕРШЁННОЕ значение API позитивную
# сверку не ослабляет (fail-closed — именованный отказ); новое ЗАВЕРШЁННОЕ
# значение (сегодня отсутствует) дало бы ЛОЖНЫЙ ОТКАЗ, не ложную публикацию —
# приемлемо и наблюдаемо по именованному отказу.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: nezavershennyj-progon: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W=""
trap '_d98_cleanup "${W:-}"' EXIT

# predjavlenie <незавершённый status | ABSENT> — полный цикл на СВОЁМ мире:
# отказ без строки → дверь без строки → парный позитив (тот же run id →
# completed). ABSENT — γ1: поле status СТРУКТУРНО удалено из новейшего прогона
# (jq del(.status), не пустая строка); значение — β/γ2: литеральная строка
# статуса (в том числе nonce).
predjavlenie() {
  local st="$1" pc B C M OID J WFA MTREE CIAPP PVB PVC RID out rc n statcond lbl
  if [ "$st" = ABSENT ]; then lbl='<status отсутствует>'; else lbl="$st"; fi
  [ -z "$W" ] || _d98_cleanup "$W"
  W="$(_d98_world nezavershennyj-progon)" || exit 2
  pc="$(_d98_podgotovka "$W" T-1)" || exit 2
  read -r B C M OID <<<"$pc"
  J="$W/prinyato/registry/candidates.tsv"
  # оракулы — в ПАМЯТЬ ДО вызова субъекта (правило 8)
  WFA="$(_d98_wfsha "$W/repo" "$B" ci-a)"
  MTREE="$(_d98_tree "$W/repo" "$M")"
  CIAPP="$(_d98_ciapp "$W/repo" "$B")"
  [ -n "$CIAPP" ] || { printf 'КРАСНО: nezavershennyj-progon: мир неконформен — пин ciApp на base пуст\n' >&2; exit 1; }
  printf 'accept\n' >"$W/verdikt.md"; printf 'accept\n' >"$W/sankcia.md"
  PVB="$(_d98_pv "$W/repo" "$B")"; PVC="$(_d98_pv "$W/repo" "$C")"

  # предъявление: НОВЕЙШИЙ ПО id одноимённый ci-a — status=<st> (незавершённое
  # состояние) либо БЕЗ поля status (γ1, del), conclusion=success, происхождение
  # конформно; под ним валидная зелёная история ключа (ok старого run —
  # обход «перебор до подходящего»)
  if [ "$st" = ABSENT ]; then
    _d98_ci_add "$W" "$M" "ci-a:success"
    RID="$(jq -r '[.check_runs[] | select(.name == "ci-a")] | sort_by(.id) | last | .id' "$W/fake/checkruns/$M.json")"
    jq --argjson r "$RID" \
      '.check_runs = [ .check_runs[]
                       | if (.name == "ci-a" and .id == $r) then del(.status) else . end ]' \
      "$W/fake/checkruns/$M.json" | tee "$W/fake/checkruns/$M.json.new" >/dev/null \
      && mv "$W/fake/checkruns/$M.json.new" "$W/fake/checkruns/$M.json"
    statcond='($n | has("status") | not)'
  else
    _d98_ci_add "$W" "$M" "ci-a:success:!$st"
    RID="$(jq -r '[.check_runs[] | select(.name == "ci-a")] | sort_by(.id) | last | .id' "$W/fake/checkruns/$M.json")"
    statcond='$n.status == $s'
  fi
  jq -e --arg m "$M" --arg app "$CIAPP" --arg w "$WFA" --argjson r "$RID" --arg s "$st" '
    ([.check_runs[] | select(.name == "ci-a")] | sort_by(.id) | last) as $n
    | ([.check_runs[] | select(.name == "ci-a")] | length) == 2
      and $n.id == $r and '"$statcond"'
      and $n.conclusion == "success" and $n.head_sha == $m
      and $n.app.slug == $app and $n.wfsha == $w
      and ([.check_runs[] | select(.name == "ci-a" and .head_sha == $m and .app.slug == $app
           and .wfsha == $w and .conclusion == "success" and .status == "completed")] | length) == 1' \
    "$W/fake/checkruns/$M.json" >/dev/null \
    || { printf 'КРАСНО: nezavershennyj-progon: мир неконформен — новейший ci-a не %s+success с конформным происхождением над валидной зелёной историей\n' "$lbl" >&2; exit 1; }

  # писатель обязан отказаться ЛИТЕРАЛЬНО по status (Н-204): именованный отказ,
  # check-строки ci-a НЕТ (ok старого run — обход «перебор до подходящего»);
  # чёрный список документированных значений красеется свидетелем (γ)
  out="$( _d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a 2>&1)"; rc=$?
  if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'прогон не завершён: ci-a'; then
    printf 'КРАСНО: nezavershennyj-progon: незавершённый прогон (status=%s, conclusion=success) принят как доказательство (rc=%s, вывод: %s)\n' "$lbl" "$rc" "$out" >&2; exit 1
  fi
  n="$(awk -F'\t' -v o="$OID" -v nm=ci-a '$1=="check" && $2==o && $3==nm' "$J" | wc -l)"
  [ "$n" -eq 0 ] || { printf 'КРАСНО: nezavershennyj-progon: незавершённый прогон породил check-строку ci-a (строк=%s)\n' "$n" >&2; exit 1; }

  # дверь: честные ci-b/verdict/policy; без строки ci-a полный перечень не
  # публикует, main неизменен, published нет
  _d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-b \
    || { printf 'КРАСНО: nezavershennyj-progon: check-писатель отказал на честной ci-b\n' >&2; exit 1; }
  _d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --verdict-row T-1 "$OID" "$W/verdikt.md" \
    || { printf 'КРАСНО: nezavershennyj-progon: verdict-писатель отказал\n' >&2; exit 1; }
  _d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --policy-row "$OID" "$PVB" "$PVC" "$W/sankcia.md" \
    || { printf 'КРАСНО: nezavershennyj-progon: policy-писатель отказал\n' >&2; exit 1; }
  out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
    --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
    --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
  if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'нет обязательной проверки: ci-a'; then
    printf 'КРАСНО: nezavershennyj-progon: дверь не отказала без строки ci-a (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
  fi
  [ "$(git -C "$W/repo" rev-parse main)" = "$B" ] \
    || { printf 'КРАСНО: nezavershennyj-progon: отказ сдвинул main\n' >&2; exit 1; }
  grep -Fq 'published' "$J" \
    && { printf 'КРАСНО: nezavershennyj-progon: отказ записал published\n' >&2; exit 1; }

  # парный позитив (α): ТОТ ЖЕ запуск (id сохранён), отличие ровно в поле
  # status → completed; писатель пишет ok с run НОВЕЙШЕГО прогона, дверь
  # публикует ровно M
  jq --argjson r "$RID" \
    '.check_runs = [ .check_runs[]
                     | if (.name == "ci-a" and .id == $r) then .status = "completed" else . end ]' \
    "$W/fake/checkruns/$M.json" | tee "$W/fake/checkruns/$M.json.new" >/dev/null \
    && mv "$W/fake/checkruns/$M.json.new" "$W/fake/checkruns/$M.json"
  jq -e --arg m "$M" --arg app "$CIAPP" --arg w "$WFA" --argjson r "$RID" '
    ([.check_runs[] | select(.name == "ci-a")] | sort_by(.id) | last) as $n
    | $n.id == $r and $n.status == "completed"
      and $n.conclusion == "success" and $n.head_sha == $m
      and $n.app.slug == $app and $n.wfsha == $w' \
    "$W/fake/checkruns/$M.json" >/dev/null \
    || { printf 'КРАСНО: nezavershennyj-progon: мир неконформен — позитив не перевёл ТОТ ЖЕ запуск в completed\n' >&2; exit 1; }
  out="$( _d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a 2>&1)"; rc=$?
  if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq "run=$RID"; then
    printf 'КРАСНО: nezavershennyj-progon: завершённый тот же прогон не дал ok с run новейшего (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
  fi
  _d98_check_stroka "$J" "$OID" ci-a ok "$WFA" "$MTREE" \
    || { printf 'КРАСНО: nezavershennyj-progon: нет ровно одной ok-строки ci-a с принятыми wfsha/tree\n' >&2; exit 1; }
  awk -F'\t' -v o="$OID" -v r="$RID" '$1=="check" && $2==o && $3=="ci-a" && $4=="ok" && $5==r {n++} END { exit (n==1 ? 0 : 1) }' "$J" \
    || { printf 'КРАСНО: nezavershennyj-progon: ok-строка несёт run не НОВЕЙШЕГО прогона (ожидался %s)\n' "$RID" >&2; exit 1; }
  out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
    --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
    --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
  if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq "PUBLISHED target=main merge=$M"; then
    printf 'КРАСНО: nezavershennyj-progon: publish не зелёный на полном журнале (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
  fi
  [ "$(git -C "$W/repo" rev-parse main)" = "$M" ] \
    || { printf 'КРАСНО: nezavershennyj-progon: целевая ветка не на ЛИТЕРАЛЬНОМ M: %s\n' "$(git -C "$W/repo" rev-parse main)" >&2; exit 1; }
  _d98_cleanup "$W"; W=""
}

# (β) все пять документированных незавершённых значений алфавита check-run.status
for st in queued in_progress waiting requested pending; do
  predjavlenie "$st"
done
# (γ2) nonce времени исполнения — вне алфавита, конечным чёрным списком не
# предвиден (арбитраж, замер 3); генерируется ДО мира предъявления
NONCE="x$(od -An -tx1 -N6 /dev/urandom | tr -d ' \n')"
case "$NONCE" in queued|in_progress|completed|waiting|requested|pending)
  printf 'КРАСНО: nezavershennyj-progon: nonce %s совпал со значением алфавита — свидетель не вне алфавита\n' "$NONCE" >&2; exit 1 ;; esac
predjavlenie "$NONCE"
# (γ1) поле status ОТСУТСТВУЕТ — структурно (del(.status))
predjavlenie ABSENT
exit 0
