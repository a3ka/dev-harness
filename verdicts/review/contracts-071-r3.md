FAIL
---
status: ready
contract: 071
round: r3 (к3, после fixr4)
judged_tree: 86fdf18 (proverka = c963c73 + 5a110d3 impl + cf113ca arch)
reviewer: Rev071k3b (продолжение Rev071k3)
date: 2026-10-02
---

# Вердикт ревьюера 071 r3 (к3) — FAIL

Судимое дерево: 86fdf18 (merge f4a в proverka). Дельта к c963c73: 5a110d3 (implementer, scripts/gitw, +51/−11) и cf113ca (architect, fixtures/gitw_predpolet/red_predpolet_071.sh, +30).
Клон: /tmp/dev-harness-verify/rev071k3/repo. Мутант: /tmp/dev-harness-verify/rev071k3/mut/m, коммит 15139b1. Драйверы проб: /tmp/dev-harness-verify/rev071k3b/{probe.sh,probes.sh,probes2.sh,probes3.sh}.

## Прогоны (все строго последовательно)

| # | команда | дерево | rc | сырая строка |
|---|---|---|---|---|
| R1 | reslop t -- bash fixtures/_krasnye_071.sh | 86fdf18 | 0 | «стаб-пак: 20/20 поймано, диффпроба 20/20» … «ok: п10д: push --repo <значение> (до remote-токена) — значение не refspec, предполёт несётся (обе формы)» … «честные клетки: 42/42 зелёные; стаб-пак 20/20 + дифф 20/20» |
| R2 | reslop t -- bash fixtures/_krasnye_045.sh <abs>/scripts/gitw | 86fdf18 | 0 | «gitw/red_gitw_obmen.sh rc=0» / «итог: 1 файлов, провалов 0» |
| R3 | reslop t -- bash fixtures/_krasnye_071.sh | мутант 15139b1 (gitw = c963c73, blob 483275f; батарея = 86fdf18, blob c5f82dd) | 1 | все клетки п0…п10г «ok», затем «ОТКАЗ: п10д: rc=0 (ожидался 1): To /tmp/gitw071.hWA8wP/p10d/b1 f8ffdc8..c84dec0 main -> main» |
| R4 | git diff --exit-code --quiet frozen/contracts/071/1^{commit} proverka -- contracts/071-predpolet-gitw-push-main.md fixtures/gitw_predpolet/.probe-only | 989673d…→86fdf18 | 0 | ls-tree обеих сторон: 5c88844 (контракт), da6d3e6 (.probe-only) — блобы совпадают |
| R5 | probes.sh 86fdf18 (c01–c32) | 86fdf18 | — | таблица ниже |
| R6 | probes.sh c963c73 (c01–c32) | c963c73 | — | таблица ниже |
| R7 | probes2.sh + probes3.sh 86fdf18 (c33–c49) | 86fdf18 | — | таблица ниже |
| R8 | probes2.sh + probes3.sh c963c73 (c33–c49) | c963c73 | — | таблица ниже |

Мир живой пробы: свежий bare-origin B1 внутри песочницы; красный main (roles/orchestrator.md 60000 символов → check:ceilings); upstream main→origin/main; GIT_EXCHANGE_GUARD_CANONICAL=B1. Судимая пара (gitw и gitw_preflight_071.sh) берётся из `<ref>:scripts/`. «Двинут» означает: refs/heads/main у B1 до вызова ≠ после.

## Пункт 1. Мутант — красное ровно п10д: ПРОЙДЕН
R3: на gitw от c963c73 все клетки до п10г зелёные; первая и единственная красная — п10д (rc=0 при ожидаемом 1, bare двинут f8ffdc8→c84dec0). Батарея умирает на первой красной клетке. Значит, клетки после п10д на мутанте не исполнялись, и «ровно» здесь означает «первая красная — п10д, все предыдущие зелёные». На объединении (R1) п10д зелёная. Клетка судит фикс, а не среду.

## Пункт 2. Батарея 045 на объединении: ПРОЙДЕН
R2 rc 0. Пересечение 045 не нарушено.

## Пункт 4. Неизменность frozen-текста: ПРОЙДЕН
R4 rc 0, дифф пуст. Клетка п10д добавлена в батарею и не трогает контракт — это усиление (прецедент 005).

## Пункт 3. Живые пробы на красном дереве: ПРОВАЛЕН — есть живые обходы

### 3a. Обходы, которые внёс фикс 5a110d3 (на c963c73 отказ, на 86fdf18 rc 0 и bare двинут)

- [ ] **F-1 (класс: живой обход, регрессия фикса; блокер).** Глоб в refspec проходит молча. Причина: `scripts/gitw` вызывает `"$PF_SCRIPT" "$target" $pre_tail_args $post_tail_args` без кавычек. Bash раскрывает `*` по файлам в cwd, поэтому предполёт получает имена файлов, а не глоб. Ветвь «refspec не разбирается» (контракт §2, «глоб в refspec → именованный отказ fail-closed ДО отправки») не срабатывает, main_cov=0, и exec уносит исходный `*` в git.
  - c27 `push origin '*'` (ветка main, cwd = корень дерева). 86fdf18: rc=0, bare_moved=ДА d7d7205f→679672ef, строк ПРЕДПОЛЁТ нет. c963c73: rc=1, «gitw ПРЕДПОЛЁТ-ОТКАЗ: refspec не разбирается: *».
  - c28 то же, ветка wip/071/x. 86fdf18: rc=0, ДА 7589335f→ee6fc402. c963c73: rc=1, тот же отказ.
  - c29 `-C <T> push origin 'refs/heads/*'`, в cwd лежит refs/heads/zzz. 86fdf18: rc=0, ДА 359e7321→1c8a2970. c963c73: rc=1, «refspec не разбирается: refs/heads/*».
  - c30 то же, ветка wip. 86fdf18: rc=0, ДА 2ad8f5b1→686814. c963c73: rc=1.
  - c31 `-C <T> push origin 'refs/heads/*:refs/heads/*'`, в cwd лежит refs/heads/a:refs/heads/b. 86fdf18: rc=0, ДА 67eeeaac→e8db5563. c963c73: rc=1.
  - Контроль c32 `push origin 'refs/heads/*'` без совпадений в cwd: rc=1 «refspec не разбирается» на обоих деревьях. Поэтому клетка п6в зелёная, но этот дефект не ловит.
  - Тот же несквотированный разворот режет значения по IFS. Пример — c43 ниже: `-o 'a b'` приходит в предполёт двумя токенами.

- [ ] **F-2 (класс: живой обход, регрессия фикса; блокер).** `__scan_tail` выбрасывает пару «--repo <следующий токен>», даже когда `--repo` — это ЗНАЧЕНИЕ другой arity-2 опции (-o/--push-option). Настоящий git читает `-o --repo` как push-option, а `main` как refspec. Предполёт же `main` не видит: saw_ref=0, на ветке wip main_cov=0.
  - c34 `push origin -o --repo main` (ветка wip, bare принимает push-options). 86fdf18: rc=0, ДА 6688be58→8dfe11d2. c963c73: rc=1, «чек красный: check:ceilings».
  - c35 `push origin --push-option --repo main` (то же). 86fdf18: rc=0, ДА a709b2db→63b63f79. c963c73: rc=1.
  - c33: то же на bare без push-options. rc=128 «the receiving end does not support push options», bare не двинут. Обход зависит от того, рекламирует ли сервер push-options; поддержку на стороне GitHub я не замерял [INFERENCE].

### 3b. Обходы, которые были и на r3 (rc 0 и bare двинут на ОБОИХ деревьях; фикс их не вносил и не закрыл)

- [ ] **F-3 (класс: живой обход; блокер по правилу FAIL).** Форма refspec с принуждением `+`, а также `@`. Git читает их как main/HEAD, а парсер предполёта сверяет только литералы `main` / `refs/heads/main` / `HEAD`. Отдельный флаг для этого не нужен, обход доступен из штатного рабочего дерева.
  - c44 `push origin +main` (main): 86fdf18 ДА 8cae5949→4c1525a0; c963c73 ДА.
  - c45 `push origin +main` (wip): 86fdf18 ДА d77225cf→767aec80; c963c73 ДА.
  - c46 `push origin +refs/heads/main` (wip): 86fdf18 ДА 93c8e49b→1424d281; c963c73 ДА.
  - c47 `push origin @` (main): 86fdf18 ДА 5ff408c6→e87c8772 («HEAD -> main»); c963c73 ДА.
  - c49 `push origin +HEAD` (main): 86fdf18 ДА 6d41dcb2→d27f4894; c963c73 ДА.
- [ ] **F-4 (класс: живой обход; блокер).** Раздельное значение `--receive-pack` / `--exec` попадает в предполёт как refspec: saw_ref=1, main_cov=0.
  - c19 `push --receive-pack git-receive-pack origin`: ДА eddccb8d→e5848133.
  - c20 `push origin --receive-pack git-receive-pack`: ДА 64869126→7c3f8474.
  - c21 `push --exec git-receive-pack origin`: ДА 9bcd633a→3f4c7735.
  - c42 `push origin --exec git-receive-pack`: ДА 4d4d0407→7d2cc58a.
  - На c963c73 все четыре тоже ДА. Формы через `=` (c17, c18) отказывают «чек красный».
- [ ] **F-5 (класс: живой обход; блокер).** Значение `-o` / `--push-option` в раздельной форме читается как refspec. Срабатывает на bare, который принимает push-options.
  - c39 `push origin -o x` (main): ДА 43bec9ed→87a1402a.
  - c40 `push -o x origin`: ДА cf4dd777→0f4323e5.
  - c36 `push -o --repo origin main` (wip): ДА e30ebaef→c241f329.
  - c43 `push origin -o 'a b'`: ДА b54134aa→b22a77b9.
  - На c963c73 все четыре тоже ДА. Без push-options на bare (c12–c15) — rc=128, bare не двинут. Форма `--push-option=x` (c16, c41) отказывает.
- [ ] **F-6 (класс: живой обход; блокер).** Покрытие main через конфиг, который предполёт не видит.
  - c24 `-c push.default=matching push origin` (wip): ДА bf4da7ac→1423a0ab.
  - c25 `-c remote.origin.push=refs/heads/main:refs/heads/main push origin` (wip): ДА 49f53b88→f39333a0.
  - c26: remote.origin.push=refs/heads/main:refs/heads/main в конфиге репозитория, затем `push origin` (wip): ДА 67710ab3→f28efc90.
  - Предполёт читает только push.default и branch.*.merge из своего cwd: глобальный конфиг у него /dev/null, `-c` из ctx не пробрасывается, remote.<r>.push не судится. Контракт §2 прямо требует отказа, когда «push.default (matching/upstream) может неявно отправить main». На c963c73 все три тоже ДА.
- [ ] **F-7 (класс: живой обход; блокер).** `-C <путь>` из чужого cwd: предполёт судит cwd, а не цель `-C`.
  - c23: cwd — зелёный клон на неродившейся ветке, вызов `-C <T> push origin` без refspec. 86fdf18 ДА b5728590→de8c869c; c963c73 ДА.
  - С явным refspec (c22 `-C <T> push origin main`) именованный отказ есть: «отправляемый src не разрешается: main».

### 3c. Пробы, отказавшие именованно или не двинувшие bare (86fdf18)
- Именованный ПРЕДПОЛЁТ-ОТКАЗ «чек красный: check:ceilings»: c01, c04 `--repo origin` (на c963c73 было ДА — фикс закрыл), c05 `--repo=origin`, c06 `--repo <путь-к-bare>` (на c963c73 было ДА — фикс закрыл), c07 `--repo origin --all`, c08 `--all`, c09 `--mirror`, c10 `--all origin`, c11 `--mirror origin`, c16 `--push-option=x origin`, c17/c18 `--receive-pack=…` до и после remote, c37/c38 `-o x … main`, c41 `--push-option=x origin`.
- «refspec не разбирается»: c32.
- «отправляемый src не разрешается: main»: c22.
- Отказ самого git, rc 128, bare не двинут: c02/c03 `--repo origin main` / `--repo=origin main` (git берёт `main` как позиционный репозиторий: «Please make sure you have the correct access rights…»), c12–c15 и c33 (нет push-options), c48 `main:` («invalid refspec»).

## Зоны
- 5a110d3: author implementer <implementer@dev-harness.local>, правит только scripts/gitw — это ЗОНА implementer (контракт :186). Хунк @@ -616 лежит внутри крюка 071 после И-7 и до И-8, ПЕРЕСЕЧЕНИЕ 045 соблюдено (R2 rc 0).
- cf113ca: author architect <architect@dev-harness.local>, правит только fixtures/gitw_predpolet/red_predpolet_071.sh — это ЗОНА architect (:184).
- `git log c963c73..86fdf18 -- contracts/ roles/ .probe-only scripts/gitw_preflight_071.sh` пуст. Выхода за зону нет.

## Норма и frozen
Контракт и .probe-only не тронуты (R4). Нормативных правок в дельте нет.

## Н-39-сверка
Задания Arch071p10v и Impl071fix4 несут инвариант («значение --repo — не remote и не refspec; на красном дереве — именованный отказ») и rc-команды (_krasnye_071 / _krasnye_045 / живая проба). Задание architect прямо оговаривает: «стаб привязан к ветви по коду клетки, не прозой». Стаб-пак не расширялся (20/20). В дельте нет прозаической привязки стаба к ветви. Комментарий «клетка стаба s17» у п11а существовал и до дельты. Н-39 соблюдён.

## r2/r3-предметы
Клетки п7–п14б, стаб-пак 20/20 и дифф-проба 20/20 зелёные на объединении (R1). Боевые ноги r3 (`--all`/`--mirror` до и после remote) отказывают живьём (c07–c11). Батарею эти предметы не ломают. Зато живьём ломается §2-обязательство «глоб → отказ» (F-1) — это нарушение r1-предмета п6в в живой форме, которое клетка п6в не видит.

## Паразитная сложность (050)
- `__scan_tail` (новая функция) и строки `pre_tail_args`/`post_tail_args`. (1) Свойство: значение --repo не должно читаться как refspec — ESSENTIAL по цели. (2) Состояние — две newline-строки; разворачиваются неявно, по IFS и glob, и это не видно ни в аргументах, ни в выводе. (3) Грамматика arity у --repo теперь живёт в двух местах (цикл И-4а :210–223 и `__scan_tail`); при следующей правке arity (-o/--receive-pack/--exec) нужно синхронно менять оба места плюс предполёт — дифф увеличил число таких мест на 1. (4) Модуль мелкий: он повторяет разбор, вместо того чтобы взять индексы, которые цикл цели уже знает. (5) Потребитель есть (п10д), но грамматику функция дублирует. Вывод: ACCIDENTAL, и находка блокирующая, потому что названы все три части. Фрагмент: `$pre_tail_args $post_tail_args` + `__scan_tail`. Отсутствующее свойство: сохранность токенов argv (F-1, F-2). Более простая форма: в самом цикле цели копить индексы опций-значений в bash-массив и передавать `"${pre[@]}" "${post[@]}"` в кавычках. Она проходит R1 и R2 и закрывает c27–c31; отдельный разбор arity-2 для всех опций со значением — работа на F-2/F-4/F-5.
- Клетка п10д: (1) регрессия --repo, ESSENTIAL. (2) Явное состояние: мир p10d/p10d2. (3)–(5) Потребитель — раннер 071 / шаг CI; грамматику не повторяет. ESSENTIAL.

## Советы (не блокируют)
- [ ] С-1: п10д проверяет только префикс «gitw ПРЕДПОЛЁТ-ОТКАЗ: ». Соседние клетки (п10а/п10б) проверяют полную причину «чек красный: check:ceilings». Стоит проверять полную причину, чтобы «несудимая конфигурация» не засчитывалась за прохождение предполёта.
- [ ] С-2: шапка крюка в scripts/gitw (около :598–603) всё ещё описывает `post_tail = orig[i..]` и срез `orig[post_sub_idx..i-2]`, хотя теперь это `__scan_tail`. Комментарий устарел.
- [ ] С-3 (architect): батарее нужны клетки-регрессии на F-1…F-7. Первая — глоб с совпадением в cwd (`push origin '*'` из корня дерева): п6в зелёная на дефектном коде, потому что её мир не содержит совпадающих путей.

## Итог
FAIL. Живые обходы (молчаливый rc 0 и двинутый bare на красном main): F-1 и F-2 внёс фикс 5a110d3; F-3…F-7 были и на r3 и остались незакрытыми. Пункты 1, 2 и 4 пройдены. Зоны чисты, frozen не тронут, Н-39 соблюдён.
