# ПРИЧИНА: коммит вне зоны
# ОКРУЖЕНИЕ: PATH=$WORK/bin:$PATH
#
# Контракт 040, арбитраж 040-II (verdicts/arbitration/contracts-040-batching-
# dostatochnost-oraculu.md, Граница v4 п.5). После доверенного PATH инъекция спая ниже
# МЕРТВА — та же полярность-переворот, что у case_batch_avtorov_otkaz.sh (см. тот файл
# за общим объяснением пина, круга 1 `dd2befe` и доктрины). Этот спай воспроизводит
# замер З-D арбитра («rev-list без нарушающего SHA», фальсификация ВХОДНОГО множества,
# а не вывода author-lookup): делегирует настоящему `git rev-list --no-merges --reverse`
# (окно `:306`/`:348`) и ВЫБОРОЧНО вырезает из его вывода SHA единственного коммита, чьё
# сообщение несёт известный маркер, — остальные SHA (включая легитимный первый коммит)
# проходят нетронутыми. Это КЛАСС, который НЕ ловится НИКАКОЙ проверкой полноты ВНУТРИ
# барьера (ни круг-1/2 гарды author_map, ни paths_raw-сверка Границы v4 п.2): те
# проверки сверяют author_map/paths_raw ПРОТИВ `$TMP/commits`, а здесь лжёт САМ
# `$TMP/commits` — «вход и выход согласованно лживы» (арбитраж, замер З-D). Единственная
# защита — ПИН.
#
# Зелёный контроль: чистое дерево сразу после заморозки (окно ещё без коммитов) → 0;
# легитимный коммит объявленного автора в своей зоне под честным git → 0. Красное: тот
# же автор коммитит ВТОРЫМ вне своей зоны (сообщение несёт маркер), спай присутствует в
# PATH-окружении вызывающего — барьер ОБЯЗАН назвать ИМЕННО «коммит вне зоны» (rc=1), а
# не смолчать rc=0 из-за отфильтрованного входного SHA.
#
# Мутант, потерявший `export PATH=/usr/bin:/bin` в check_zones.sh, оживляет спай: SHA
# нарушающего коммита исчезает из `$TMP/commits` ДО того, как author-lookup/diff-tree
# успевают его увидеть — нарушитель ИСЧЕЗАЕТ из суда зон целиком, барьер отвечает rc=0 —
# красный прогон этой фикстуры пропадает, что ловится антиплацебо-протоколом («барьер
# остался зелёным на обманном дереве»).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R" 'ЗОНА agent-x: scripts/'
"$BARRIER" "$R"

printf 'легитимная правка в зоне\n' >> "$R/scripts/a.sh"
commit_as "$R" agent-x 'легитимный коммит в зоне'
"$BARRIER" "$R"

mkdir -p "$R/plans"
printf 'forbidden\n' > "$R/plans/002-outside.md"
commit_as "$R" agent-x 'нарушающий коммит вне зоны — маркер для спая rev-list'

REALGIT="$(command -v git)"
mkdir -p "$WORK/bin"
cat > "$WORK/bin/git" <<EOF
#!/bin/sh
is_window=0
has_reverse=0
repo_root=""
prev=""
for arg in "\$@"; do
  [ "\$arg" = --no-merges ] && is_window=1
  [ "\$arg" = --reverse ] && has_reverse=1
  [ "\$prev" = -C ] && repo_root="\$arg"
  prev="\$arg"
done
if [ "\$is_window" = 1 ] && [ "\$has_reverse" = 1 ]; then
  "$REALGIT" "\$@" | while IFS= read -r sha; do
    subj="\$("$REALGIT" -C "\$repo_root" log -1 --format=%s "\$sha" 2>/dev/null)"
    case "\$subj" in
      *'маркер для спая rev-list'*) ;;
      *) printf '%s\n' "\$sha" ;;
    esac
  done
  exit 0
fi
exec "$REALGIT" "\$@"
EOF
chmod +x "$WORK/bin/git"
"$BARRIER" "$R"
