#!/usr/bin/env bash
# Клетка РЕШЁТКИ КОМПОЗИЦИЙ происхождения (контракт 098, §Инварианты Б-5 —
# отбор прогона; вердикт арбитража 098-a2 «композиции и ключ порядка», Т1,
# класс A-098-2): замороженное Решение 2/Б-5 называет РОВНО ТРИ сверки
# происхождения (app.slug/wfsha/head_sha); одиночные предъявления уже есть
# (red_novejshij_chuzhoj_zelenyj.sh — slug, red_novejshij_chuzhaja_versija.sh
# — wfsha, red_novejshij_ne_tot_kommit.sh — head_sha), эта клетка перечисляет
# В КОДЕ четыре недостающие непустые композиции {slug,wfsha}, {slug,head},
# {wfsha,head}, {slug,wfsha,head} — решётка программно: будущее поле
# происхождения расширяет цикл, а не порождает забытую клетку. База — как в
# одиночных клетках: ПОЛНОСТЬЮ валидная зелёная история ключа ci-a (run=1:
# обвязка, версия и head_sha=M) и НОВЕЙШИЙ зелёный одноимённый прогон,
# расходящийся с валидным РОВНО в полях S (jq-контроль мира фиксирует
# расхождение РОВНО в S и ровно одну валидную зелёную историю под новейшим;
# построение head-компоненты — как red_novejshij_ne_tot_kommit.sh:44-48,
# БЕЗ перезаписи валидной истории). Отбор — ПОСЛЕДНИЙ одноимённый по id:
# писатель обязан судить НОВЕЙШИЙ и отказаться ПО ЗАКРЕПЛЁННОМУ порядку сверок
# head_sha → исполнитель → версия: S∋head_sha — «прогон не того коммита:
# ci-a», S={slug,wfsha} — «проверка чужой обвязки: ci-a» (rc 1) БЕЗ записи
# check-строки — ok-строка СТАРОГО run=1 сертифицировала бы ПРОШЛОЕ состояние
# ключа. Обман (s22: селекция «зелёный новейший с чужыми wfsha И head_sha →
# отступить на последний полностью валидный» — дословный обходчик M12both
# вердикта 098-a2, привязан к композиции {wfsha,head}) пишет ok run=1 и
# публикует M → клетка красна. Дверь: без строки ci-a полный перечень не
# публикует («нет обязательной проверки: ci-a»), main неизменен, published
# нет. Парный позитив — существующие одиночные клетки (ok с run НОВОГО
# прогона, публикация ровно M) достаточны (вердикт Т1).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: kompozicii-proishozhdenija: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W=""
trap '[ -n "${W:-}" ] && _d98_cleanup "$W" || true' EXIT

for S in "slug,wfsha" "slug,head" "wfsha,head" "slug,wfsha,head"; do
  W="$(_d98_world "kompozicii-${S//,/-}")" || exit 2
  pc="$(_d98_podgotovka "$W" T-1)" || exit 2
  read -r B C M OID <<<"$pc"
  J="$W/prinyato/registry/candidates.tsv"
  WFA="$(_d98_wfsha "$W/repo" "$B" ci-a)"
  CIAPP="$(_d98_ciapp "$W/repo" "$B")"
  CHUZHWF="$(printf 'run chuzhoe-opredelenie-kompozicii-proishozhdenija\n' | sha256sum | cut -d' ' -f1)"
  [ -n "$CIAPP" ] || { printf 'КРАСНО: kompozicii-proishozhdenija [%s]: мир неконформен — пин ciApp на base пуст\n' "$S" >&2; exit 1; }
  [ "$B" != "$M" ] || { printf 'КРАСНО: kompozicii-proishozhdenija [%s]: мир неконформен — B совпал с M\n' "$S" >&2; exit 1; }
  [ "$CHUZHWF" != "$WFA" ] || { printf 'КРАСНО: kompozicii-proishozhdenija [%s]: мир неконформен — чужая wfsha совпала с принятой\n' "$S" >&2; exit 1; }
  printf 'accept\n' >"$W/verdikt.md"; printf 'accept\n' >"$W/sankcia.md"
  PVB="$(_d98_pv "$W/repo" "$B")"; PVC="$(_d98_pv "$W/repo" "$C")"

  # предъявление: НОВЕЙШИЙ зелёный одноимённый, расходящийся РОВНО в полях
  # S; head-компонента (S∋head) — прогон на коммите B с jq-переносом в ответ
  # M (как red_novejshij_ne_tot_kommit.sh:44-48), иначе — добавление к ответу M
  pair="ci-a:success"
  case ",$S," in *,slug,*) pair="$pair:@foreign-ci" ;; *) pair="$pair:@$CIAPP" ;; esac
  case ",$S," in *,wfsha,*) pair="$pair:~$CHUZHWF" ;; esac
  case ",$S," in
    *,head,*)
      _d98_ci "$W" "$B" "$pair"
      jq --slurpfile chuzhoj "$W/fake/checkruns/$B.json" \
        '.total_count += 1 | .check_runs += [$chuzhoj[0].check_runs[0]]' \
        "$W/fake/checkruns/$M.json" >"$W/fake/checkruns/$M.json.new" \
        && mv "$W/fake/checkruns/$M.json.new" "$W/fake/checkruns/$M.json"
      ;;
    *) _d98_ci_add "$W" "$M" "$pair" ;;
  esac

  # jq-контроль: расхождение новейшего РОВНО в S (E* — ожидаемые значения,
  # для полей S — чужие), под новейшим ровно одна валидная зелёная история
  case ",$S," in *,head,*) EH="$B"; HH=1 ;; *) EH="$M"; HH=0 ;; esac
  case ",$S," in *,slug,*) ES="foreign-ci"; HS=1 ;; *) ES="$CIAPP"; HS=0 ;; esac
  case ",$S," in *,wfsha,*) EW="$CHUZHWF"; HW=1 ;; *) EW="$WFA"; HW=0 ;; esac
  jq -e --arg m "$M" --arg app "$CIAPP" --arg w "$WFA" \
    --arg eh "$EH" --arg es "$ES" --arg ew "$EW" \
    --argjson hh "$HH" --argjson hs "$HS" --argjson hw "$HW" '
    ([.check_runs[] | select(.name == "ci-a")] | sort_by(.id) | last) as $n
    | ([.check_runs[] | select(.name == "ci-a")] | length) == 2
      and $n.conclusion == "success"
      and $n.head_sha == $eh and $n.app.slug == $es and $n.wfsha == $ew
      and ($hh != 1 or $n.head_sha != $m)
      and ($hs != 1 or $n.app.slug != $app)
      and ($hw != 1 or $n.wfsha != $w)
      and ([.check_runs[] | select(.name == "ci-a" and .head_sha == $m
           and .app.slug == $app and .wfsha == $w and .conclusion == "success")] | length) == 1' \
    "$W/fake/checkruns/$M.json" >/dev/null \
    || { printf 'КРАСНО: kompozicii-proishozhdenija [%s]: мир неконформен — новейший расходится не ровно в S или под ним не ровно одна валидная зелёная история ci-a\n' "$S" >&2; exit 1; }

  # писатель обязан судить НОВЕЙШИЙ: именованный отказ ПО ЗАКРЕПЛЁННОМУ
  # порядку сверок head_sha → исполнитель → версия, check-строки ci-a НЕТ
  case ",$S," in
    *,head,*) OZHID="прогон не того коммита: ci-a" ;;
    *) OZHID="проверка чужой обвязки: ci-a" ;;
  esac
  out="$( _d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-a 2>&1)"; rc=$?
  if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq "$OZHID"; then
    printf 'КРАСНО: kompozicii-proishozhdenija [%s]: новейший композиции не опознан (%s) — селекция отступила к старому валидному (rc=%s, вывод: %s)\n' "$S" "$OZHID" "$rc" "$out" >&2; exit 1
  fi
  n="$(awk -F'\t' -v o="$OID" -v nm=ci-a '$1=="check" && $2==o && $3==nm' "$J" | wc -l)"
  [ "$n" -eq 0 ] || { printf 'КРАСНО: kompozicii-proishozhdenija [%s]: новейший композиции породил check-строку ci-a (строк=%s)\n' "$S" "$n" >&2; exit 1; }

  # дверь: честные ci-b/verdict/policy; без строки ci-a полный перечень не
  # публикует, main неизменен, published нет
  _d98_zov "$W" "$W/prinyato/scripts/check_ci_gate.sh" "$W/prinyato" "$M" --check-row "$OID" ci-b \
    || { printf 'КРАСНО: kompozicii-proishozhdenija [%s]: check-писатель отказал на честной ci-b\n' "$S" >&2; exit 1; }
  _d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --verdict-row T-1 "$OID" "$W/verdikt.md" \
    || { printf 'КРАСНО: kompozicii-proishozhdenija [%s]: verdict-писатель отказал\n' "$S" >&2; exit 1; }
  _d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --policy-row "$OID" "$PVB" "$PVC" "$W/sankcia.md" \
    || { printf 'КРАСНО: kompozicii-proishozhdenija [%s]: policy-писатель отказал\n' "$S" >&2; exit 1; }
  out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
    --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
    --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
  if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'нет обязательной проверки: ci-a'; then
    printf 'КРАСНО: kompozicii-proishozhdenija [%s]: дверь не отказала без строки ci-a (rc=%s, вывод: %s)\n' "$S" "$rc" "$out" >&2; exit 1
  fi
  [ "$(git -C "$W/repo" rev-parse main)" = "$B" ] \
    || { printf 'КРАСНО: kompozicii-proishozhdenija [%s]: отказ сдвинул main\n' "$S" >&2; exit 1; }
  grep -Fq 'published' "$J" \
    && { printf 'КРАСНО: kompozicii-proishozhdenija [%s]: отказ записал published\n' "$S" >&2; exit 1; }
  _d98_cleanup "$W"; W=""
done
exit 0
