FAIL — A2 превращает отказ batched `git log` в ложное зелёное check_zones

## Обход: `git log --no-walk --stdin` с rc=127 выглядит как пустой список авторов

В A2-ветви `scripts/check_zones.sh` единственный batched lookup авторов намеренно
подавляет любой отказ:

```bash
g log --no-walk --format='%H%x00%an%x00' --stdin < "$TMP/commits" \
  > "$TMP/author_nul" 2>/dev/null || : > "$TMP/author_nul"
```

После rc=127 файл становится пустым. Последующие `awk` и цикл считают, что ни один
судимый коммит не имеет объявленного автора, и пропускают их. Это не fail-closed
`rc=1`/`rc=2`: нарушитель исчезает из суда, а весь барьер возвращает `rc=0`.

Воспроизведено живым toy-репозиторием. Сначала честный `git` даёт требуемое красное;
затем единственная подмена возвращает 127 **только** на аргументе `--no-walk` и
dелегирует каждый прочий вызов в `/usr/bin/git`:

```bash
ROOT="$PWD"
. fixtures/check_zones/_repo.sh
W="$(mktemp -d)"; trap 'rm -rf "$W"' EXIT
R="$W/repo"
make_repo "$R" 'ЗОНА agent-x: scripts/'
printf 'forbidden\n' > "$R/plans/002-outside.md"
commit_as "$R" agent-x 'declared agent writes outside zone'

bash "$ROOT/scripts/check_zones.sh" "$R"; printf 'honest rc=%s\n' "$?"
# honest rc=1; output names «коммит вне зоны: agent-x … plans/002-outside.md»

mkdir "$W/spy"
cat > "$W/spy/git" <<'SH'
#!/bin/sh
for arg in "$@"; do [ "$arg" = --no-walk ] && exit 127; done
exec /usr/bin/git "$@"
SH
chmod 755 "$W/spy/git"
PATH="$W/spy:$PATH" bash "$ROOT/scripts/check_zones.sh" "$R"
printf 'poisoned rc=%s\n' "$?"
```

Точный наблюдённый результат на текущем HEAD:

```text
honest rc=1
poisoned rc=0

процессных вне суда:

замороженных контрактов: 1 · объявленных авторов: 1 · коммитов в диапазонах: 1 · проверено по зонам: 0
```

Положительный контроль здесь существенный: та же история, тот же субъект и тот же
нарушающий коммит честно краснеют; зелёным его делает только проглоченный отказ
нового batched-запроса. Это ровно класс «отказ, выглядящий успехом», а не
постоянно-красная или постоянно-зелёная заглушка.

## Остальные выполненные пробы

- `bash fixtures/check_zones/red_predel_git_vyzovov.sh` — rc=0: LOW=141,
  HIGH=141, дифференциал 0<=15; оба toy ловят `agent03` вне зоны.
- `bash fixtures/check_protected/red_predel_git_vyzovov_ours.sh` — rc=0:
  LOW=29, HIGH=29, дифференциал 0<=15; `-s ours`, дубликат-блоб и три
  обязательных свойства `diff-tree --stdin` пойманы.
- `bash fixtures/check_zones/probe_ci_dostizhimost_predelov.sh .` — rc=0,
  обе budget-пробы подключены структурно и rc npm равен прямому запуску.
- Дифференциальные toy: batched author map из 420 коммитов (включая CR, TAB,
  VT и LF в переданной git identity) равен построчному map по SHA; `git log`
  меняет порядок вывода, но субъект обращается по SHA, поэтому это не обход.
  Пустой stdin действительно возвращает HEAD у `git log`; существующий guard
  `[ -s "$TMP/commits" ]` эту форму закрывает.
- Дифференциальный toy для `git diff-tree --stdin` на 420 коммитах дал то же
  отображение `SHA -> множество путей`, что и per-commit oracle.
- Octopus toy с тремя родителями, где защищённый `verdicts/adversary/v-b.md`
  существует лишь во втором родителе и скрыт `-s ours`, дал rc=1 с именем
  `v-b.md`; его честный минимальный контроль до merge дал rc=0. Scoped
  criss-cross case также зелёный: `bash scripts/verify_antiplacebo.sh --scope
  check_protected/case_merge_criss_cross_bez_allow` — rc=0.
- Не-ослабление: `git diff --exit-code --diff-filter=MD --no-renames
  f0b6de662d4826ed1707f2b97fef1c8aeeb06435 HEAD` по обоим `case_*`
  пространствам — rc=0. Полные scoped anti-placebo прогоны также зелёные:
  check_zones 21/21, check_protected 25/25.

Эти положительные результаты не компенсируют ложное зелёное A2 при отказе
единственного источника авторов. Правка предмета и фикстур остаётся за автором;
этот круг их не менял.
