#!/usr/bin/env bash
# Клетка Б-5/Н-204 «незавершённый прогон» (контракт 098, §Инварианты Б-5 —
# полный применимый CI; вердикт адверсария contracts-098-v2 A-098-3 BLOCKS;
# усиление по вердикту критика contracts-098-v3): завершённость прогона —
# ЛИТЕРАЛЬНОЕ поле .status ответа CI, единственное допустимое значение
# completed; непустой conclusion синонимом завершения НЕ является, а
# требование завершённости НЕ ЗАМЕНЯЕТСЯ чёрным списком отдельных
# незавершённых состояний: обход критика v3 — писатель «запретить только
# in_progress» ([ "$stat" != "in_progress" ]) — проходил прежнюю клетку
# (единственное предъявление in_progress) и всю батарею, публикуя M по
# новейшему queued+success. Предъявление — на ДВУХ незавершённых
# состояниях, каждое с конформным происхождением (head_sha=M, app.slug=пин
# ciApp, wfsha=доверенная) и валидной зелёной историей ключа под новейшим:
# in_progress (проба адверсария) и queued (обход критика v3). Писатель
# обязан отказать «прогон не завершён: ci-a» (rc 1) БЕЗ записи check-строки
# в КАЖДОМ предъявлении — ok-строка обещала бы факт, которого ещё НЕТ;
# чёрный список из ОДНОГО состояния красен предъявлением ДРУГОГО. Парный
# позитив для КАЖДОГО состояния: ТОТ ЖЕ запуск (id сохранён, отличие РОВНО
# в поле status → completed) — ok-строка с run НОВЕЙШЕГО прогона и
# публикация ровно M. Пара состояний — свидетели класса «отказ по
# НЕ-completed», не исчерпание словаря статусов: словарь живёт в
# замороженном тексте (решение 2: ЛИТЕРАЛЬНАЯ сверка с completed), она
# зелёна на обоих предъявлениях, чёрный список любого одного из них красится
# вторым.
# Обман (s24: непустой conclusion приравнен завершённости — дословный дефект
# обходчика-делегатора вердикта) пишет ok и закрывает ключ → клетка красна.
# Дверь: без строки ci-a полный перечень не публикует («нет обязательной
# проверки: ci-a»), main неизменен, published нет.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: nezavershennyj-progon: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W=""
trap '_d98_cleanup "${W:-}"' EXIT

# predjavlenie <незавершённый status> — полный цикл на СВОЁМ мире: отказ без
# строки → дверь без строки → парный позитив (тот же run id → completed).
predjavlenie() {
  local st="$1" pc B C M OID J WFA MTREE CIAPP PVB PVC RID out rc n
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
  # состояние), conclusion=success, происхождение конформно; под ним валидная
  # зелёная история ключа (ok старого run — обход «перебор до подходящего»)
  _d98_ci_add "$W" "$M" "ci-a:success:!$st"
  RID="$(jq -r '[.check_runs[] | select(.name == "ci-a")] | sort_by(.id) | last | .id' "$W/fake/checkruns/$M.json")"
  jq -e --arg m "$M" --arg app "$CIAPP" --arg w "$WFA" --argjson r "$RID" --arg s "$st" '
    ([.check_runs[] | select(.name == "ci-a")] | sort_by(.id) | last) as $n
    | ([.check_runs[] | select(.name == "ci-a")] | length) == 2
      and $n.id == $r and $n.status == $s
      and $n.conclusion == "success" and $n.head_sha == $m
      and $n.app.slug == $app and $n.wfsha == $w
      and ([.check_runs[] | select(.name == "ci-a" and .head_sha == $m and .app.slug == $app
           and .wfsha == $w and .conclusion == "success" and .status == "completed")] | length) == 1' \
    "$W/fake/checkruns/$M.json" >/dev/null \
    || { printf 'КРАСНО: nezavershennyj-progon: мир неконформен — новейший ci-a не %s+success с конформным происхождением над валидной зелёной историей\n' "$st" >&2; exit 1; }

  # писатель обязан отказаться ЛИТЕРАЛЬНО по status (Н-204): именованный отказ,
  # check-строки ci-a НЕТ (ok старого run — обход «перебор до подходящего»);
  # чёрный список одного состояния красится ВТОРЫМ предъявлением
  out="$( _d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a 2>&1)"; rc=$?
  if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'прогон не завершён: ci-a'; then
    printf 'КРАСНО: nezavershennyj-progon: незавершённый прогон (status=%s, conclusion=success) принят как доказательство (rc=%s, вывод: %s)\n' "$st" "$rc" "$out" >&2; exit 1
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

  # парный позитив: ТОТ ЖЕ запуск (id сохранён), отличие РОВНО в поле status →
  # completed; писатель пишет ok с run НОВЕЙШЕГО прогона, дверь публикует ровно M
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

for st in in_progress queued; do
  predjavlenie "$st"
done
exit 0
