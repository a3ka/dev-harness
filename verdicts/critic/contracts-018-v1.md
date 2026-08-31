accept

Судимый срез — закоммиченный HEAD `534507bb27f8fa231ea76baf8a37fcc47adff046`.
Решение арбитража `857b19d` входит в его историю (`git merge-base --is-ancestor 857b19d HEAD` → rc 0).
Все изменяющие репродукции выполнены в одноразовом клоне `$TMPDIR/c018v3`; основной чекаут не
переключался. Прототипы накладывались только на `scripts/check_staged.sh` клона и после каждой
пробы снимались обратным patch.

## Красное текущего дерева

На исходном HEAD, где страж ветки ещё не реализован, все четыре требуемых свидетеля красны
по-стабно и одинаково диагностируют «красное не предъявлено»:

- `TMPDIR="$PWD/tmp" bash scripts/verify_antiplacebo.sh . --scope check_staged/case_vetka_rabochij_na_main` → **rc 1**;
- `TMPDIR="$PWD/tmp" bash scripts/verify_antiplacebo.sh . --scope check_staged/case_vetka_chuzhaja_wip` → **rc 1**;
- `TMPDIR="$PWD/tmp" bash scripts/verify_antiplacebo.sh . --scope check_staged/case_vetka_detached` → **rc 1**;
- `TMPDIR="$PWD/tmp" bash scripts/verify_antiplacebo.sh . --scope check_staged/case_vetka_pohozhaja_wip` → **rc 1**.

Это поимённо предъявляет Р1 `main`, Р2 точную чужую `wip/018/architect`, Р3 detached HEAD и
Р4 похожую чужую `wip/018/implementerXyz`. Р3 и Р4 находятся в отдельных case-файлах и являются
единственными красными входами своих case (`fixtures/check_staged/case_vetka_detached.sh:1-34`,
`fixtures/check_staged/case_vetka_pohozhaja_wip.sh:1-34`). ЗЗ — своя
`wip/019/implementer` — единственный зелёный контроль case Р3.

## Прототип общего предиката

Контрольный прототип использовал одну меру: при живой собственной `wip/*/<committer>` текущий
checkout считается своим только при префиксе `wip/` и точном равенстве последнего компонента
имени ветки committer; отсутствие ветки также означает «не своя». На нём:

- `TMPDIR="$PWD/tmp" bash scripts/verify_antiplacebo.sh . --scope check_staged` → **rc 0**;
- раннер поимённо принял все 10 case `check_staged`, включая четыре веточных case и
  `case_vetka_sudja_i_vladelec`;
- у `case_vetka_detached` подтверждён зелёный контроль ЗЗ и повторный красный Р3 с причиной
  `вне своей ветки wip/`;
- Р1, Р2 и Р4 также повторно красны с той же именованной причиной.

После снятия patch `git diff --exit-code -- scripts/check_staged.sh` → **rc 0**.

## Два независимых плацебо

Оба плацебо построены в этом круге отдельными patch, не взяты из арбитражного стенда.

1. **Литеральное множество `{main, wip/018/architect}`.** При живой собственной ветке страж
   отвергал только эти два checkout и передавал остальные прежнему суду зон.
   `TMPDIR="$PWD/tmp" bash scripts/verify_antiplacebo.sh . --scope check_staged` → **rc 1**:
   `case_vetka_detached` и `case_vetka_pohozhaja_wip` оба сообщили «красное не предъявлено»;
   предъявлено повторным красным 8 из 10 case. Значит новые свидетели не сводятся к прежним
   двум литералам.
2. **Подстрока `wip/*<committer>*`.** При живой собственной ветке страж считал своей любую
   wip-ветку, содержащую committer, вместо точного равенства последнего компонента.
   `TMPDIR="$PWD/tmp" bash scripts/verify_antiplacebo.sh . --scope check_staged` → **rc 1**:
   Р3 detached был принят как красный, но `case_vetka_pohozhaja_wip` сообщил «красное не
   предъявлено»; предъявлено повторным красным 9 из 10 case. Значит Р4 независимо удерживает
   операцию точного сравнения и не заменяется Р3.

После каждой пробы patch снят. Финально в клоне `git status --porcelain`,
`git tag --list 'frozen/contracts/018/*'` и `git diff --exit-code -- scripts/check_staged.sh`
не напечатали строк; рабочее дерево и временные refs восстановлены.

## Сверка текста и пачки v3

- И-1 называет четыре scoped rc-команды по-стабно и пинует класс «префикс `wip/` И последний
  компонент имени ветки == committer» (`contracts/018-vetka-na-agenta.md:90-109`).
- И-2 пинует зелёную границу другого NNN, `wip/019/implementer`, единственным зелёным контролем
  case Р3 и теми же rc-командами (`contracts/018-vetka-na-agenta.md:110-117`).
- Разделы «Красное сейчас» и «После реализации» называют переходы rc и охрану существующего
  (`contracts/018-vetka-na-agenta.md:148-181`).
- (Q1)–(Q4), явный `land_agent`, merge `--no-ff` и close-out через `gc_agent_branches` сохранены
  (`contracts/018-vetka-na-agenta.md:25-84`).
- Привязка входов к стабам оставлена коду фикстур; текст не объявляет пару «обманный стаб ↔
  ветвь реализации». Счёт фикстур и ветвей прямо не заморожен
  (`contracts/018-vetka-na-agenta.md:143-146`).
- Для проверки грамматики в клоне на время был поставлен числовой тег
  `frozen/contracts/018/1`. `bash scripts/check_zones.sh .` разобрал все строки 018: пять
  `ЗОНА`-авторов, пути architect/implementer/судей и явное `РАБОТА НЕ РАЗДАЁТСЯ`; **rc 0**.
  Тег затем удалён.

## История v1 → v2 → v3

- **v1:** критерий различал лишь «любая `wip/*`» против не-wip; рабочий автор на чужой
  `wip/018/architect` оставался зелёным.
- **v2:** Р2 закрыл точный обход v1, но литеральный страж `{main, wip/018/architect}` проходил
  весь тогдашний scoped-контур, пропуская detached и похожую чужую wip. Второй одноимённый
  FAIL созвал арбитра.
- **РЕШЕНИЕ `857b19d`:** обязательны отдельные Р3 detached, Р4
  `wip/018/implementerXyz` и зелёный ЗЗ другого NNN; Р3 и Р4 взаимонезаменимы.
- **v3:** два новых отдельных case, ЗЗ, четыре по-стабные rc-команды и точный класс добавлены.
  Прогоны общего предиката и двух плацебо выше подтверждают исполнение именно испытаний
  решения, без расширения предмета.

Блокирующих находок в исполнении решения арбитража нет. `accept` — законный выход сверх капа:
арбитраж `857b19d` находится на HEAD и его решение исполнено.
