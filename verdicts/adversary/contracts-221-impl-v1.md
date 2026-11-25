FAIL
OBJECT=7cd4dbbe51bc6ba0df021d3104134160a926dfc3
СУД: репо=dev-harness; предмет=221; фаза=реализация; роль=adversary; вызов=1; сессия=c907157c/Adv221; модель-факт=anthropic/claude-sonnet-5-5 (метаданные системного промпта сессии); автор Impl221 — implementer (MiniMax); класс=рисковый

# Атака на реализацию 221 — `scripts/mint_line.sh` (project-маршрут двери минта 031)

Итог одной строкой: честная production (`b18e1b4d5`) дефектов не показала — ни в трёх проверках области/регресса, ни в
доказанных достижимых состояниях. FAIL — ТОЛЬКО по К-08 (дыры батареи при честной production), по правилу остановки владельца:
сразу ревьюер, нового адверсария не будет. Батарея `--repo .` зелёная (17/0) против 19 живых мутантов, нарушающих
обязательства И1–И5 (шесть дыр К-08.1…К-08.6, список ниже); ещё 17 живых мутантов — эквиваленты/no-op/остатки (в Остатках).
Наблюдаемый контрпример (команда + вывод) исполнен для C05, C07, G04, G05, F03, H01, H03, I01, I02, E08 и парных честных контролей.

## Блоки

### К-08 — дыры батареи `probe221.py` при честной production (один блок, шесть дыр; каждая дыра = живые мутанты)

Все мутанты — СВОИ замены (`/tmp/dev-harness-verify/adv221-work/mut.py`, не из `stabs/`), применены к `scripts/mint_line.sh`
OBJECT, прогнаны `red_mint_line_proekt_221.sh --repo <каталог-мутанта>`; «живой» = `--repo` rc 0, 17/17 GREEN. Позитивный контроль:
`--repo .` на честной production rc 0, 17/0; `--model` rc 0, 17/0.

**К-08.1 — остаток одноразового хука вне `TMPDIR` не виден (И2: «одноразовый хук удаляется на выходе», приёмка «остатка
одноразового хука нет после каждого project-вызова»).** `once_hook_residue()` (probe221.py) сканирует только `<мир>/scratch`
(= TMPDIR, подставляемый пробой). Живые мутанты, не удаляющие хук (`CLEAN_RM` → `:`) и кладущие его:
- C05 `mktemp -d "$ROOT/.git/mint-hook.XXXXXX"` — rc 0, 17/17 GREEN;
- C07 `mktemp -d "$ROOT/.git/hooks/once.XXXXXX"` (подкаталог в `.git/hooks`; `hook_snapshot()` берёт только файлы) — rc 0, 17/17;
- C08 `mktemp -d "$ROOT/.git/info/once.XXXXXX"` — rc 0, 17/17;
- C06 `mktemp -d /tmp/mint-hook.XXXXXX` (мимо TMPDIR) — rc 0, 17/17; C09 `mktemp -d "$HOME/.mint-hook.XXXXXX"` — rc 0, 17/17.
Контрпример (explore2.py c05): мир p01, мутант C05 → `rc=0 residue_in_git=['…/product/.git/mint-hook.BDi9a6/pre-commit']`;
c07 (p07, отказ) → `rc=1 residue=['…/product/.git/hooks/once.2X2nMS/pre-commit']`. После прогона мутантов на станции остались
20 каталогов-остатков (`/tmp/mint-hook.*` ×10, `…/zones/dev/.mint-hook.*` ×10) — физическое доказательство, что батарея их не видит;
удалить их адверсарию запретил страж Н-85 (вне allowlist) — убрать вручную.
Чем чинить (совет, не правка): снимок рекурсивного списка `.git` (имена+типы) до/после вызова и сравнение; для /tmp и HOME — отдельный пустой TMPDIR/HOME мира и запрет, что хук ушёл мимо TMPDIR (мутанту C06/C09 нужен мир с `HOME`/`TMPDIR`, отличными от /tmp).

**К-08.2 — локальные refs/теги не сравниваются (И4: «Теги/origin не изменяются»; И5: «HEAD … прежние»).** В `World.__init__` строка
`self.refs = self.git('show-ref').stdout` записана и НИГДЕ не читается (grep по probe221.py: единственное вхождение — присваивание); `observe()` сверяет
только `show-ref` ORIGIN (`obs[10]`). Живые мутанты, меняющие ЛОКАЛЬНЫЕ refs:
- G05 после успеха `git tag -d id/CONTRACT/NNN` — rc 0, 17/17;
- G07b после успеха `git tag -f -a id/CONTRACT/NNN` (тег переписан на новый объект, строка реестра указывает на старый sha) — rc 0, 17/17;
- G15 при отказе двери `git tag -d id/CONTRACT/NNN` — rc 0, 17/17;
- G04 создание `minted/NNN` — rc 0, 17/17; G09 `git branch minted-NNN` — rc 0, 17/17.
Контрпример (explore2.py g05): `G05 rc=0 tag_after=b''` (тег `id/CONTRACT/924` исчез локально после «успешного» минта, строка реестра в HEAD); g04: `tags=… minted/924`.
(Мутант G07 без identity упал ложно — «empty ident»; G07b с явным identity — живой.)

**К-08.3 — откат шире пути реестра не ловится (И5: «восстанавливает только путь реестра из HEAD»).** F03: после `checkout HEAD -- <реестр>` добавлено
`git clean -fdxq` — rc 0, 17/17 GREEN: мир без игнорируемых файлов, а `status --porcelain` чист по определению (неигнорируемые untracked отказали бы раньше).
Контрпример (explore2.py f03; мир p07 + `.gitignore` с `secret.env`, `build/`): `F03 rc=1 secret.env=False build=False` — ИГНОРИРУЕМЫЕ файлы проекта удалены при отказе двери.
Честная production в том же мире (explore.py ignored): `rc=1 secret.env=True build=True` — свойство соблюдено, батарея его не охраняет.
(F01 `reset --hard` и F02 `checkout HEAD -- .` эквивалентны при чистом дереве — в Остатки, не блок.)

**К-08.4 — признак project-маршрута (И1: «признак — harness.project.json в R») пробой не различается.** Каждый project-мир имеет и `harness.project.json`, и `.harness/project-layer.json`, и `.harness/`;
cwd вызова всегда = R (`run(args, self.root, env)`); станционные миры не имеют `harness.project.json`, но имеют `.harness/`. Живые мутанты условия ветви:
- H03 `[ -f harness.project.json ]` (в cwd, не в R) — rc 0, 17/17;
- H01 `[ -f "$ROOT/.harness/project-layer.json" ]` — rc 0, 17/17;
- H06 `git cat-file -e HEAD:harness.project.json` (признак только tracked) — rc 0, 17/17;
- H05 `… || [ -d "$ROOT/.workflow" ]`, H07 `… || [ -f "$ROOT/../harness.project.json" ]` — rc 0, 17/17.
Контрпример (explore2.py h03): `--root <project>` из другого cwd → `rc=1 ОТКАЗ: дверь 031 отключена конфигом (… без исполняемого pre-commit)` (project-ветвь не включилась); h01: мир БЕЗ `harness.project.json`, но с `.harness/project-layer.json` → `rc=0` (мутант вошёл в project-ветвь без признака).
Честная production тот же вызов из чужого cwd проходит (explore.py cwd: `rc=0 MINTED …`).

**К-08.5 — порядок «префлайт → нормализация» не проверяется (И3: «После project-префлайта удаляются ВСЕ локальные user.name/email»; Frontier: «после чистого main/git/profile-префлайта»).** Нет клетки «project + чужая identity + (битый профиль | HEAD не main | грязное дерево)».
- I01 (убран `project_paths_resolve "$ROOT" >/dev/null || exit 1`) — rc 0, 17/17;
- I02 (нормализация вынесена выше проверки `HEAD == main`) — rc 0, 17/17.
Контрпример (explore2.py i01/i02, мир p02 с чужим user.name): мутант I01 на битом профиле `rc=1 workflow ОТКАЗ…` и `cfg_name_left=False` (конфиг уже изменён при отказе);
мутант I02 на ветке `side` `rc=1`, `cfg_name_left=False`. Честная production (explore2.py honest_broken_profile): `rc=1 … файл не JSON`, `cfg_name_left=True` — конфиг не тронут.

**К-08.6 — сохранность прочей конфигурации проверена только для двух ключей `[user]` (И3: «Остальная конфигурация сохраняет ключи/значения»).** `p12` кладёт лишь `user.signingkey`, `user.useConfigOnly`.
E08 (вместо `git config --unset-all` — `sed -i '/^[[:space:]]*name *=/d'` по всему `.git/config`) — rc 0, 17/17.
Контрпример (explore2.py e08): после мутанта `[alias]`, `[user "work"]` остались БЕЗ `name = …`/`email = …` (`…[alias]\n[user "work"]\n[user]\n`); честная production (honest_alias): `[alias] name=status email=log`, `[user "work"] name=keep-me` сохранены. Нужна клетка с одноимёнными ключами в иных секциях/подсекциях.

Блоков по ЧЕСТНОЙ production (дефектов реализации): нет. Область: implementer → ровно `scripts/mint_line.sh` (+81/−1); orchestrator → ровно `registry/ci-steps.tsv`, `registry/ci-zamery.tsv`, `.github/workflows/ci.yml` (К-01 не наступил).

## Остатки

(эквивалентные/названные/вне границ — НЕ блок)

- Строк остатка контракта «НЕ ЗАЩИЩАЕТ» с ловцом adversary в странице 221 нет (ловцы: изоляция станции, CI, reviewer, «отдельный предмет оркестратору»). Из «НЕ ЗАЩИЩАЕТ» косвенно подтверждён один пункт: остаток скратча двери `lib_zones.<hash>.*` — УКУСИЛ (наблюдён; вывод ниже: `post=['lib_zones.ad1ca848.GZFypl', 'lib_zones.ad1ca848.active']` после успешного project-минта в чистом TMPDIR). Остальные пункты (компрометация установки; `check_staged.sh:780/793`; конкурентная запись config) не атаковались — вне предмета.
- Эквиваленты (наблюдаемо неотличимы, доказательства): C04 `return 0` в EXIT-trap — `bash -c 'f(){ local r=$?; return 0; }; trap f EXIT; exit 1'` → rc 1 (статус выхода EXIT-ловушки не меняется; bash 5.2.21); F01 `reset --hard`/F02 `checkout HEAD -- .` — дерево чисто (порцелейн включает untracked); G08 push того же тега на origin — origin побайтно прежний; D04/I10/I14/J01 — no-op правки (`show-ref` и код неизменны); I13 хук `check_staged .` — cwd хука = корень рабочего дерева.
- E05 (rc удаления ключа проглочен): живой, но наблюдаемо отличается только stderr (честная: именованный `ОТКАЗ: не удалось удалить…`; мутант: отказ самой двери 080/4, rc тот же 1, коммита нет). Мир (`config.lock`) в батарее не строится. Эффект минта не меняется — остаток.
- I03 (нет `check_staged.sh` рядом → ожидается rc 2 NOT_IMPLEMENTED; мутант даёт rc 1 от упавшего хука) — живой; в И1–И6 rc этой ветви не объявлен.
- G06 `git fetch origin` (меняет remote-tracking refs, не origin), G10 `git gc`, G12 `touch .git/mint-marker` — живые; прямого обязательства И1–И6 не нарушают («Теги/origin не изменяются» — об origin и тегах).
- C11 (`chmod 777` каталога хука) — живой; права не заявлены обязательством (см. Советы).
- Станционная ветвь: 14-вариантный дифференциал база `880ff787e` vs OBJECT (station_diff.py: plain-hook, hooksPath=/dev/null, чужой config без хука, не-main, грязное, нет тега, нет origin, повтор, 1000, без аргументов, --help, неизвестный аргумент, не-репозиторий, лжепрофиль-файл) — rc/stdout/stderr/status/config/хуки/refs равны, различается только случайный суффикс `lib_zones.*` скратча двери (не mint_line).
- Сигналы (explore.py sig:*, check_staged с `sleep 6`): SIGTERM/SIGINT/SIGHUP на pid и на группу — EXIT-ловушка срабатывает, `tmp.*` убран, `index.lock` нет; SIGKILL оставляет `tmp.*/pre-commit` (неустранимо). При убийстве ГРУППЫ (двери и mint_line вместе) в дереве остаётся staged строка реестра (`M  .harness/registry/contracts.tsv`): откат не выполняется на сигнале. Это поведение станционного кода 068 (откат только по rc commit), не дельта 221 — остаток.
- Нормализация `user.name/email` постоянна и срабатывает также при ПОСЛЕДУЮЩИХ отказах (тег/origin/повтор) — по контракту И3 (p08 это проверяет), не дефект.
- 068-батарея: `fixtures/mint_line/red_mint_line_068.sh` rc 0, «ветвей 8, стабов 4, красных 0, зелёных 11, не прогнано 1»; в её выводе стабы стМ1/стМ2/стМ4 печатаются «мёртв» (`…/next_id.sh: No such file or directory` — стаб-копия без sibling next_id.sh, `. "$SELF_DIR/next_id.sh"` — строка 76, дельтой 221 не тронута; [INFERENCE] то же на базе, база для сравнения не прогонялась целиком).

## Регресс (rc/числа)

Окружение: `TMPDIR=/tmp/dev-harness-verify/scratch-adv221`, `VALIDATE_STD_SHELLCHECK=…/shellcheck/0.11.0/shellcheck`; HEAD == OBJECT (`git rev-parse HEAD` = 7cd4dbbe5…).

| команда | результат |
|---|---|
| `W --repo .` | rc 0; `KLETKI 17 KRASNYH 0` (p01–p12, s01–s05 GREEN) |
| `W --model` | rc 0; `KLETKI 17 KRASNYH 0` |
| `W --stabs` | rc 0; `STABY 14 SVJAZI 18 ZHIVYH 0` |
| `W --sintaksis` | rc 0; `SINTAKSIS 17 SHELLCHECK 2` |
| `bash -n scripts/mint_line.sh` | rc 0 |
| shellcheck пин `-S warning scripts/mint_line.sh` | rc 1; ровно одна SC2034 `NEXT_ID_LIB` (строка 76, как на базе) |
| `red_mint_line_068.sh` | rc 0; 8 ветвей, 4 стаба, красных 0 |
| `red_charter_tekst_do_tega_210.sh --repo .` | rc 0; `KLETKI=342 ZELENYE=342 KRASNYE=0` |
| `red_limit_aktivnyh_078.sh` | rc 1; `л0 КРАСНАЯ — предмет отсутствует`, `красных 1, зелёных 22, не исполнено 31` (как на базе по заданию) |
| `gen_ci_steps.sh --check` | rc 0 |
| `check_provodka.sh . contracts/221-mint-line-proekt.md` | rc 0 |
| `pre_critic`/`check_sdacha --run` | НЕ прогонялись (известно: красная строка 15 «Red-do» листа — ряд правит architect после ленда; не блок) |

## Мутации (замена → красные клетки / живой)

Драйвер `/tmp/dev-harness-verify/adv221-work/mut.py` (87 строк таблицы; первая редакция E01 не применилась — заменена E01b). «красные» — список клеток `--repo`, rc 1; «ЖИВОЙ» — rc 0, красных 0.

| мутант (замена в `scripts/mint_line.sh`) | результат |
|---|---|
| A01 хук `: %q %q` | красные (p01–p07,p11,p12) |
| A02 `bash check_staged … \|\| true` в хуке | красная p07 |
| A03 `bash check_staged …; exit 0` в хуке | красная p07 |
| A04 хук — комментарий | красные |
| A05 хук печатает «judged: ok» и не вызывает дверь | красные |
| B01 `--no-verify` всегда | красные (p01–p07,p11,p12,s01,s03,s05) |
| B02 `--no-verify` только в project | красные |
| B03 `-c core.hooksPath=/dev/null` в commit | красные |
| B04 `GIT_CONFIG_*`=hooksPath /dev/null на самом commit | красные |
| B05 `commit … \|\| true; false` (rc commit подавлен) | красные p07,s03,s05 |
| C01 cleanup только при успехе | красные p07,p08 |
| C02 cleanup только при отказе | красные |
| C03 удаляется файл, каталог остаётся | красные |
| C04 cleanup `return 0` | ЖИВОЙ — эквивалент (rc выхода ловушки не меняется) |
| C05 хук в `.git/mint-hook.*`, не удаляется | ЖИВОЙ — К-08.1 |
| C06 хук в `/tmp/mint-hook.*`, не удаляется | ЖИВОЙ — К-08.1 |
| C07 хук в `.git/hooks/once.*`, не удаляется | ЖИВОЙ — К-08.1 |
| C08 хук в `.git/info/once.*`, не удаляется | ЖИВОЙ — К-08.1 |
| C09 хук в `$HOME/.mint-hook.*`, не удаляется | ЖИВОЙ — К-08.1 |
| C10 фиксированный `/tmp/mint221-fixed-hook` (убирается) | ЖИВОЙ — предсказуемый путь, не обязательство (Советы) |
| C11 `chmod 777` | ЖИВОЙ — права не заявлены (Советы) |
| D01 `core.hooksPath` пишется постоянно | красные |
| D02 хук копируется в `.git/hooks/pre-commit` | красные |
| D03 ключ `core.hooksPathX` (hooksPath не задан) | красные |
| D04 no-op правка порядка | ЖИВОЙ — эквивалент |
| E01b `--unset` вместо `--unset-all` | красная p11 |
| E02 только user.name | красные (p02,p03,p04,p11,p12) |
| E03 только user.email | красные |
| E04 `--remove-section user` | красная p12 |
| E05 ошибка удаления проглочена | ЖИВОЙ — остаток (только stderr) |
| E06 удалять только непустые | красная p03 |
| E07 дополнительно снесён user.signingkey | красная p12 |
| E08 `sed -i` по всему config вместо unset-all | ЖИВОЙ — К-08.6 |
| E09 постоянно `core.autocrlf false` | красные |
| E10 снесён user.useConfigOnly | красная p12 |
| E11 после минта `user.name` пишется в config | красные |
| E12 после минта `user.email` пишется | красные |
| E13–E16 по одному полю GIT_AUTHOR/COMMITTER из окружения | красная p05 (каждый) |
| E17 `--author=` | красные |
| F01 откат `reset --hard` | ЖИВОЙ — эквивалент (чистое дерево) |
| F02 откат `checkout HEAD -- .` | ЖИВОЙ — эквивалент |
| F03 откат + `git clean -fdxq` | ЖИВОЙ — К-08.3 |
| F04 откат `reset --soft` | красные p07,s03,s05 |
| F05 откат `reset -- <реестр>` (index only) | красные p07,s03,s05 |
| F06 откат пропущен в project | красная p07 |
| F07 после отказа exit 0 | красные p07,s03,s05 |
| F08 после отказа exit 2 | красные p07,s03,s05 |
| G01 stdout без `\n` | красные |
| G02 sha/commit переставлены | красные |
| G03 `git push origin main` | красные |
| G04 локальный тег `minted/NNN` | ЖИВОЙ — К-08.2 |
| G05 удаление локального `id/CONTRACT/NNN` после успеха | ЖИВОЙ — К-08.2 |
| G06 `git fetch origin` | ЖИВОЙ — остаток |
| G07 `tag -f -a` без identity | красные (ложно: «empty ident») — заменён на G07b |
| G07b `tag -f -a id/CONTRACT/NNN` с identity | ЖИВОЙ — К-08.2 |
| G08 push того же тега `--force` | ЖИВОЙ — эквивалент |
| G09 локальная ветка `minted-NNN` | ЖИВОЙ — К-08.2 |
| G10 `git gc --prune=now` | ЖИВОЙ — остаток |
| G11 `git stash create` | ЖИВОЙ — эквивалент (no-op) |
| G12 `touch .git/mint-marker` | ЖИВОЙ — остаток |
| G13 `git notes add` | красные |
| G14 лишний пустой коммит | красные |
| G15 удаление локального тега при отказе двери | ЖИВОЙ — К-08.2 |
| G16 `push origin :refs/tags/frozen/…` | красные |
| H01 признак `.harness/project-layer.json` | ЖИВОЙ — К-08.4 |
| H02 признак `-d .harness` | красные s02,s03 |
| H03 признак в cwd, не в R | ЖИВОЙ — К-08.4 |
| H04 признак `HARNESS_PROJECT_LAYER_ROOT` | красные s02,s03 |
| H05 признак `… \|\| -d .workflow` | ЖИВОЙ — К-08.4 |
| H06 признак «tracked в HEAD» | ЖИВОЙ — К-08.4 |
| H07 признак `… \|\| ../harness.project.json` | ЖИВОЙ — К-08.4 |
| I01 убран префлайт профиля | ЖИВОЙ — К-08.5 |
| I02 нормализация выше проверки main | ЖИВОЙ — К-08.5 |
| I03 убрана проверка `check_staged.sh` рядом | ЖИВОЙ — остаток |
| I04 убрана проверка исполняемости хука (step 0) | красная s02 |
| I06 повтор → rc 2 | красные p08,s04 |
| I07 не-репозиторий → rc 1 | красная p10 |
| I08 `--no-verify` принимается | красная p09 |
| I09 реестр зашит `registry/contracts.tsv` | красные |
| I10 no-op | ЖИВОЙ — эквивалент |
| I11 хук зовёт `$ROOT/scripts/check_staged.sh` | красные |
| I12 хук получает `$SELF_DIR` вместо R | красные |
| I13 хук получает `.` вместо R | ЖИВОЙ — эквивалент |
| I14 no-op после trap | ЖИВОЙ — эквивалент |
| I15 станционный отказ только при наличии профиля | красная s02 |
| J01 хук передаёт `"$@"` | ЖИВОЙ — эквивалент (git вызывает pre-commit без аргументов) |
| J02 хук создаёт `leftover.tmp` в рабочем дереве | красные |

Итого по таблице (87 строк): красных 51 (включая ложный красный G07 — «empty ident», заменён G07b), живых 36; из живых 19 нарушают
обязательства И1–И5 и составляют К-08.1…К-08.6 (C05–C09; G04, G05, G07b, G09, G15; F03; H01, H03, H05, H06, H07; I01, I02; E08),
17 — эквиваленты/no-op/остатки (C04, C10, C11, D04, E05, F01, F02, G06, G08, G10, G11, G12, I03, I10, I13, I14, J01).

## НЕ ЗАЩИЩАЕТ

Подтверждаю границы контракта и добавляю наблюдённое:
- Батарея не защищает от: остатка хука вне `TMPDIR` мира (К-08.1); изменения локальных refs/тегов (К-08.2); сноса игнорируемых файлов откатом (К-08.3); неверного условия ветви при cwd≠R / лишнем маркере (К-08.4); порядка префлайт→нормализация (К-08.5); коллизий одноимённых ключей в иных секциях config (К-08.6).
- Контракт: нормализация постоянна; сигнал на группу процессов оставляет staged-строку (поведение 068); SIGKILL оставляет хук в TMPDIR; скратч `lib_zones.*` в TMPDIR — дефект станционного инструмента (наблюдён).
- Не атаковались (вне предмета/нет носителя): `check_staged.sh:780/793`, конкурентная запись в config, компрометация PATH/установки, `pre_critic`/`check_sdacha --run`.

## Советы

1. К-08.1: сравнивать рекурсивный список `.git` до/после (имена, типы), а не только файлы в `.git/hooks`; хук-остаток в `/tmp`/`HOME` ловить заданием мирового `TMPDIR` И `HOME`.
2. К-08.2: использовать уже собранный `world.refs` — сравнить `show-ref` (и `for-each-ref`) после вызова с исходным во всех project-клетках; включить `git tag -l`.
3. К-08.3: добавить `.gitignore` и игнорируемый файл/каталог в мир отказа (p07) и требовать, чтобы они пережили отказ.
4. К-08.4: клетка «project вызван из чужого cwd при `--root R`»; клетка «`.harness/project-layer.json` без `harness.project.json`» (станционная ветвь обязана остаться станционной); клетка «`harness.project.json` в родителе R».
5. К-08.5: клетки «project + чужая identity + {битый профиль, не-main, грязное дерево}» с требованием `.git/config` без изменений.
6. К-08.6: в p12 добавить `[alias] name = …`, `[user "x"] name = …`, `[sendemail] …` и сравнивать побайтно (RAW_CONFIG_PARITY уже есть — расширить мир).
7. Станция: `mktemp -d` даёт 0700; хук-каталог приемлем. Если появится требование «права одноразового хука» — добавить проверку в хук-пробу (хук сам печатает `stat` своего каталога). Предсказуемый путь (C10) конфликтует с параллельными минтами — мутант не обязателен для контракта, но реалистичен.
8. 221: на сигнале откат реестра не выполняется (унаследовано от 068) — если нужно, отдельным предметом `trap 'git checkout HEAD -- reg' INT TERM`.

## Сырой вывод ключевых прогонов

Честная production, `bash fixtures/workshop_project/mint_line_proekt_221/red_mint_line_proekt_221.sh --repo .`:
```
REPO p01-no-hook GREEN … REPO s05-live-door-refusal GREEN
KLETKI 17 KRASNYH 0                                  (rc 0, 16 s)
```
`--model`: `KLETKI 17 KRASNYH 0` (rc 0). `--stabs`: `STABY 14 SVJAZI 18 ZHIVYH 0` (rc 0). `--sintaksis`: `SINTAKSIS 17 SHELLCHECK 2` (rc 0).

Мутант C05 против `--repo` (mut.py): `C05-cleanup-hook-in-git-dir-left rc=0` (красных нет); контрпример:
```
C05 rc=0 residue_in_git=['…/m-C05-cleanup-hook-in-git-dir-left/product/.git/mint-hook.BDi9a6/pre-commit']
C07 rc=1 residue=['…/product/.git/hooks/once.2X2nMS/pre-commit']
G05 rc=0 tag_after=b''
G04 rc=0 tags=b'frozen/contracts/001/1\nid/CONTRACT/924\nminted/924\n'
F03 rc=1 secret.env=False build=False
H03 (cwd!=root) rc=1 stderr='ОТКАЗ: дверь 031 отключена конфигом (эффективный hooks-каталог …/product/.git/hooks без исполняемого pre-commit) …'
H01 (layer file, no profile) rc=0 stderr='не судится: автор «orchestrator» не объявлен ни в одной заморозке'
I01 rc=1 cfg_name_left=False stderr='workflow ОТКАЗ: профиль битый или workflowPaths вне репо'
I02 rc=1 cfg_name_left=False
HONEST broken-profile rc=1 cfg_name_left=True stderr='файл не JSON: …/harness.project.json' residue=[]
E08 rc=0 cfg='…[alias]\n[user "work"]\n[user]\n'
HONEST alias/user-subsection rc=0 cfg_tail='…[alias]\n\tname = status\n\temail = log\n[user "work"]\n\tname = keep-me\n'
```
Честная production, особые пути: путь мира с пробелами/кавычками/`$`/backtick (`w s'q$x(1)/pro duct'$HOME `x``) — `rc=0 MINTED …`, residue=[]; `--root` из чужого cwd и относительный `--root` — rc 0; чужой `GIT_CONFIG_COUNT/KEY_0=core.hooksPath=/dev/null` в окружении вызывающего — rc 0, минт прошёл через хук, остатка нет (свои пары добавляются в КОНЕЦ — побеждают).
Сигналы: `TERM-pid rc=-15 … residue=[] index.lock=False`; `TERM-group/INT-group/HUP-group rc=-15/-2/-1 post=[] status='M  .harness/registry/contracts.tsv'`; `KILL-pid rc=-9 residue=['tmp.5kP3mkZXCC','tmp.5kP3mkZXCC/pre-commit']`.

Артефакты прогона (одноразовые, вне репо): `/tmp/dev-harness-verify/adv221-work/{mut.py,explore.py,explore2.py,station_diff.py}`.
