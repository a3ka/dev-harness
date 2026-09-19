ПРЕДМЕТ: spaseno-031-v4 — свидетельство класса по инв. 2 контракта 029
МОДЕЛЬ: openai-codex/gpt-6-astra
ВОПРОС: ретро-зонирование трёх коммитов implementer (136ab1f0705b5b446aed18ad5d277cd95f1dd7dc, 67f7437c5b835a19b4b7c359cbcb8dcffd68c26e, b11943e124b2fd465be2dec24c408db967be18db) на старом пути fixtures/check_staged/case_dver_minta_priznanie.sh: lib_zones читает только последнюю заморозку (vmax) — перенос ЗОНА-строки в 031/2 выкинул v1-покрытие пути, три коммита законны по своим временным зонам, но выпадают из union (класс 75f5ffe, прецеденты 026v4/027v3/028v3). Требуется СПАСЕНО-строка в заморозке 031/4 + РАЗРЕШИЛ-ВЛАДЕЛЕЦ (правило 11) — единственный проектируемый выход; блокирует CI шаг 26 «Зоны исполнителей», а с ним done/034 и все суды (гейт 4б).
РЕКОМЕНДАЦИЯ: подтверждаю класс воля-владельца/норма; вариант — поимённый СПАСЕНО-респект трёх коммитов в 031 v4 при подписи владельца по правилу 11 и новом scoped-вердикте критика, без изменения ЗОНА-строк v3; это предложение, не разрешение и не исполнение.
ПОДТВЕРЖДЕНО: воля-владельца
ФОРК: spaseno-031-v4
КЛАСС: воля-владельца
ПРИЗНАК: норма

## Независимость и границы свидетельства

Запись прочитана из /tmp/dev-harness-verify/scratch/spaseno-031-v4.md. Её АВТОР: zai/glm-5.3, моя модель иная. В клоне не найден verdicts/arbitration/spaseno-031-v4-*.md: совмещения консультанта и арбитра на этом предмете нет.

Свидетельствуется КЛАСС решения, не дизайн 031 и не качество реализации. Замороженный текст не пересматривается консультантом. Проектируемое исключение из суда истории требует воли владельца: AGENTS.md, правило 11, относит замороженные contracts/ к уставным документам и требует РАЗРЕШИЛ-ВЛАДЕЛЕЦ в теле изменяющего коммита; строку вправе дать владелец либо сессия по его прямому слову. Инженерный агент не вправе объявить эту норму самостоятельно. Поэтому признак «норма» здесь содержательный, а не маскировка технического выбора.

Все прогоны ниже — в отдельном клоне /tmp/dev-harness-verify/consult-spaseno/repo, HEAD b73fcea404b00f70ce6cd48aface0620731468aa. Живой основной checkout не изменялся; контракт, скрипты, теги и коммиты клона мной не изменялись. Приземление свидетельства в verdicts/consultant/spaseno-031-v4-klass-v1.md выполняет оркестратор с author=consultant по заданной main-direct процедуре.

## 1. Единственный читатель: vmax, не union версий

Прогон:
```text
git show HEAD:scripts/lib_zones.sh
rc=0
```
Сырые строки из закоммиченного блоба, участок zones_load:189–202:
```bash
    vmax=0
    while IFS= read -r t; do
      if [[ "$t" =~ ^refs/tags/frozen/contracts/${nnn}/([0-9]+)$ ]]; then
        local k=$((10#${BASH_REMATCH[1]}))
        [ "$k" -gt "$vmax" ] && vmax="$k"
      fi
    done < <(git -C "$root" for-each-ref --format='%(refname)' 'refs/tags/frozen/contracts/' 2>/dev/null | sort)
    [ "$vmax" -gt 0 ] || continue

    vmax_tag="refs/tags/frozen/contracts/$nnn/$vmax"
    file="$(git -C "$root" ls-tree -r --name-only "${vmax_tag}^{commit}" -- ':(literal)contracts/' 2>/dev/null \
            | awk -v n="$nnn" 'index($0, "contracts/" n "-") == 1 { print; exit }')"
    [ -n "$file" ] || continue
    body="$(git -C "$root" cat-file -p "${vmax_tag}^{commit}:$file" 2>/dev/null || true)"
```
Вывод: на каждый номер контракта читается один body высшей числовой версии; затем объединяются зоны разных контрактов. Это НЕ накопительное объединение версий одного контракта. Для 031 текущий vmax=3; старый путь из v1 автоматически не сохраняется.

## 2. Сверка замороженных блобов

Прогоны:
```text
git show frozen/contracts/031/1:contracts/031-strazh-semejstvo-mint-i-bazlajn.md
rc=0
git diff frozen/contracts/031/1 frozen/contracts/031/2 -- contracts/031-strazh-semejstvo-mint-i-bazlajn.md
rc=0
git diff frozen/contracts/031/2 frozen/contracts/031/3 -- contracts/031-strazh-semejstvo-mint-i-bazlajn.md
rc=0
git diff --quiet frozen/contracts/031/3 HEAD -- contracts/031-strazh-semejstvo-mint-i-bazlajn.md
rc=0; stdout пуст
```
Блобы контракта, соответственно v1/v2/v3:
```text
814852ac52d1faf483d9641c4e46608ef1d9d899
b3647c81af415d129c54944d8b008539b325419b
d4c62afc47bc1e410dd10ae6b5c44ec472df34b4
```
Сырая замена ЗОНА-строки в diff v1→v2:
```diff
-ЗОНА implementer: scripts/check_staged.sh scripts/check_zones.sh scripts/check_no_leak.sh scripts/lib_zones.sh fixtures/check_staged/case_dver_minta_legitimnyj.sh fixtures/check_staged/case_dver_minta_forma.sh fixtures/check_staged/case_dver_minta_reestr.sh fixtures/check_staged/case_dver_minta_provenans.sh fixtures/check_staged/case_dver_minta_vetka.sh fixtures/check_staged/case_dver_minta_priznanie.sh fixtures/check_judge_gate/case_peresnjatie_legitimnyj.sh fixtures/check_judge_gate/case_peresnjatie_forma.sh fixtures/check_judge_gate/case_peresnjatie_zony.sh fixtures/check_judge_gate/case_peresnjatie_porcelain.sh fixtures/check_judge_gate/case_peresnjatie_chitatel.sh
+ЗОНА implementer: scripts/check_staged.sh scripts/check_zones.sh scripts/check_no_leak.sh scripts/lib_zones.sh fixtures/check_staged/case_dver_minta_legitimnyj.sh fixtures/check_staged/case_dver_minta_forma.sh fixtures/check_staged/case_dver_minta_reestr.sh fixtures/check_staged/case_dver_minta_provenans.sh fixtures/check_staged/case_dver_minta_vetka.sh fixtures/check_zones/case_dver_minta_priznanie.sh fixtures/check_judge_gate/case_peresnjatie_legitimnyj.sh fixtures/check_judge_gate/case_peresnjatie_forma.sh fixtures/check_judge_gate/case_peresnjatie_zony.sh fixtures/check_judge_gate/case_peresnjatie_porcelain.sh fixtures/check_judge_gate/case_peresnjatie_chitatel.sh
```
В diff v2→v3 ни одной изменённой ЗОНА-строки нет. Добавленная v3 норма прямо сохраняет ЗОНА-строки дословно; это сохраняет v2, но не возвращает уже снятый в v2 старый путь v1. HEAD-контракт побайтово равен v3.

## 3. Три коммита: диапазон, автор, старый путь

Выполнены три пары команд (каждая пара через &&; каждая завершилась rc=0 и пустым stdout, следовательно обе команды пары rc=0):
```text
git merge-base --is-ancestor frozen/contracts/031/1 136ab1f0
git merge-base --is-ancestor 136ab1f0 HEAD
rc=0 для каждой
git merge-base --is-ancestor frozen/contracts/031/1 67f7437c
git merge-base --is-ancestor 67f7437c HEAD
rc=0 для каждой
git merge-base --is-ancestor frozen/contracts/031/1 b11943e1
git merge-base --is-ancestor b11943e1 HEAD
rc=0 для каждой
```
Прогон:
```text
git show --stat 136ab1f0 67f7437c b11943e1
rc=0
```
Сырые релевантные строки вывода (остальные пути первого коммита здесь не перепечатаны):
```text
commit 136ab1f0705b5b446aed18ad5d277cd95f1dd7dc
Author: implementer <implementer@dev-harness.local>
Date:   Sat Sep 19 15:44:00 2026 +0200
 fixtures/check_staged/case_dver_minta_priznanie.sh | 93 +++++++++++++++++++++
 11 files changed, 861 insertions(+)

commit 67f7437c5b835a19b4b7c359cbcb8dcffd68c26e
Author: implementer <implementer@dev-harness.local>
Date:   Sat Sep 19 18:11:52 2026 +0200
 .../case_dver_minta_priznanie.sh                   | 28 +++++-----------------
 1 file changed, 6 insertions(+), 22 deletions(-)

commit b11943e124b2fd465be2dec24c408db967be18db
Author: implementer <implementer@dev-harness.local>
Date:   Sat Sep 19 15:46:07 2026 +0200
 fixtures/check_staged/case_dver_minta_priznanie.sh | 48 ++++++++++++----------
 1 file changed, 27 insertions(+), 21 deletions(-)
```
Раскрытие сокращённого rename:
```text
git show --name-status --format=fuller 67f7437c
rc=0
R082	fixtures/check_staged/case_dver_minta_priznanie.sh	fixtures/check_zones/case_dver_minta_priznanie.sh
```
Существенная оговорка к дословному вопросу: три коммита не следует без различения объявлять законными «по действовавшим тогда ЗОНА-строкам». Создание 136ab1f0 и исправление b11943e1 относятся к старому пути v1; 67f7437c — перенос со снятием старого пути, выполненный после владельческого решения v2. В изменяющем v2 коммите 478b8143789b3c81a7566056c8b7ebffb2452797 (18:08:55 +0200) действительно есть РАЗРЕШИЛ-ВЛАДЕЛЕЦ на перенос из fixtures/check_staged/ в fixtures/check_zones/. Новый путь разрешён v2, старый уже снят. Поэтому респект удаления старого пути — нормативная часть решения, а не доказанное покрытие старого пути зоной v2.

Дополнительные проверки:
```text
git log -1 --format=fuller frozen/contracts/031/2
rc=0; commit 478b8143789b3c81a7566056c8b7ebffb2452797, Author: owner, CommitDate: Sat Sep 19 18:08:55 2026 +0200
git merge-base --is-ancestor frozen/contracts/031/2 67f7437c
rc=1; stdout пуст
git rev-parse 67f7437c^:contracts/031-strazh-semejstvo-mint-i-bazlajn.md
rc=0
814852ac52d1faf483d9641c4e46608ef1d9d899
```
Родитель переносного коммита ещё несёт v1-блоб; v2 не его предок. Дата/сообщение о следовании v2 не подменяют DAG-доказательство. Это не опровергает проверенный диапазон frozen/031/1..HEAD и класс нормативного исключения; оговорка исключает ложную аттестацию буквального временного покрытия.

## 4. Живой check_zones

Прямой запуск:
```text
bash scripts/check_zones.sh /tmp/dev-harness-verify/consult-spaseno/repo
rc=1
```
Ровно три FAIL «коммит вне зоны», все под implementer на старом пути; иных FAIL нет. Ниже дословные префиксы трёх строк, общий длинный перечень зон справа опущен явно:
```text
  FAIL коммит вне зоны: implementer 136ab1f0 fixtures/check_staged/case_dver_minta_priznanie.sh
  FAIL коммит вне зоны: implementer 67f7437c fixtures/check_staged/case_dver_minta_priznanie.sh
  FAIL коммит вне зоны: implementer b11943e1 fixtures/check_staged/case_dver_minta_priznanie.sh
```
Сырой итог:
```text
замороженных контрактов: 32 · объявленных авторов: 3 · коммитов в диапазонах: 1197 · проверено по зонам: 770
```
Чтобы сохранить длинные строки без усечения интерфейсом, выполнен дополнительный захват:
```text
script --quiet --return --command 'bash scripts/check_zones.sh /tmp/dev-harness-verify/consult-spaseno/repo' /tmp/dev-harness-verify/consult-spaseno/zones.typescript
rc=1
```
Полное сырьё: /tmp/dev-harness-verify/consult-spaseno/zones.typescript; FAIL на строках 44–46, итог на 50, COMMAND_EXIT_CODE="1" на 52. Этот файл — стенограмма с PTY/служебными строками, НЕ нормализованный stdout для инв. 9. Скриптовый запуск и merge-base приведены как требовавшиеся живые пробы, а не как команды закрытого белого списка блока ОСНОВАНИЕ-ДЕРЕВО.

## 5. Прецеденты и предел их силы

Прогон:
```text
git show bd3853f 9dd59e9 75f5ffe f7c6183
rc=0
```
Сырые строки:
```text
commit bd3853f62b9e00ecccfe0a7ca97dd5c94ee37c59
+СПАСЕНО architect: dad01175e995584c6528baab1eb38ae3012ef2e9 8662a6617d955f70e8868d2f1522227f47729274 — легальная посадка/перенос проб лаунчера по ЗОНЕ v1 (fixtures/workshop/ была зоной architect до v2-респека); v2 снял путь — ретро-де-зонирование класса 75f5ffe, коммиты легальны в своё время; РАЗРЕШИЛ-ВЛАДЕЛЕЦ v3 (слово владельца 2026-09-17).

commit 9dd59e988e450b948f4b11c5372a13d62e4d7bdb
    РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/028-home-sessii-vne-dereva.md v3 — СПАСЕНО-респек dad01175+8662a66 + ЗОНА arbiter: verdicts/arbitration/ (корень Н-83); кроме двух строк ничего не меняется (слово владельца 2026-09-17)

commit f7c61830311d44bcf36bbc008ab4445fd9b0941d
+СПАСЕНО orchestrator: 75f5ffeda43e90983335790c16de0c6690856e23 — административный zone-респект: v2-зона-экспансия 027 совершена orchestrator-каналом (решение владельца 2026-09-16, критик accept ad045dd); класс легализован прозой 026 v3:72 (orchestrator-канал по прецеденту owner-channel d28c688), грамматика ЗОНА класс прозой не выражает — вывод из суда по грамматике 003-v3 (Н-100, остаток union-фикса)
```
Дополнительно:
```text
git show frozen/contracts/026/4:contracts/026-zhnec-tmp.md
rc=0
```
В закоммиченном frozen/026/4 имеется та же СПАСЕНО orchestrator-строка для полного 75f5ffeda43e90983335790c16de0c6690856e23. Уточнение: сам 75f5ffe — commit расширения зон 027, а не коммит добавления СПАСЕНО в 026. Наиболее прямой прецедент снятия старого пути — bd3853f (028 v3); 026/027 показывают конечный поимённый административный респект. Эти прецеденты обосновывают класс, но НЕ заменяют новую подпись владельца на 031 v4.

## Точная предлагаемая дельта v4

Единственная правка contracts/031-strazh-semejstvo-mint-i-bazlajn.md — вставить следующий блок непосредственно перед существующим заголовком «## Остаточный риск (назван прямо)», после завершения секции «## Поправка v3». Между блоком и соседними секциями — одна пустая строка. Остальные байты файла, включая все ЗОНА-строки v3, остаются неизменны.

```markdown
## СПАСЕНО (ретро-зонирование по грамматике 003-v3)

СПАСЕНО implementer: 136ab1f0705b5b446aed18ad5d277cd95f1dd7dc 67f7437c5b835a19b4b7c359cbcb8dcffd68c26e b11943e124b2fd465be2dec24c408db967be18db — ретро-зонирование класса 75f5ffe: перенос ЗОНА-пути в 031 v2 из fixtures/check_staged/case_dver_minta_priznanie.sh в fixtures/check_zones/case_dver_minta_priznanie.sh снял v1-покрытие старого пути при чтении только vmax; 136ab1f0 и b11943e1 создавали и исправляли файл по ЗОНЕ v1, 67f7437c исполнял авторизованный владельцем перенос v2 со снятием старого пути; поимённый нормативный респект истории и переноса, без расширения действующих зон и без изменения ЗОНА-строк v3.
```

Причина намеренно различает v1-работу и перенос v2 вместо недоказанной общей формулы «все три покрывались тогдашними зонами». Грамматика соблюдена: существующий объявленный автор implementer, три полных 40-hex через пробел, U+2014, непустая причина. Оба конца диапазона проверены для всех трёх хешей. check_zones.sh:188–235 читает СПАСЕНО из высшей заморозки и проверяет эти условия; исключение привязано к перечисленным коммитам, не создаёт разрешения будущих правок старого пути. Проба зелёного результата после v4 не выполнялась: контракт не менялся и новая заморозка консультантом не создавалась.

## Рекомендация владельцу

Предлагаю подписать РАЗРЕШИЛ-ВЛАДЕЛЕЦ по правилу 11 именно на приведённую единственную СПАСЕНО-секцию при новом scoped-вердикте критика; затем автор предмета/оркестратор проводят положенную заморозку 031/4. Это конечная нормативная легализация трёх названных коммитов, не изменение lib_zones/check_zones, не union всех версий и не снятие суда истории целиком. До прямой подписи разрешение не выдано; настоящее свидетельство её не заменяет.

Измеренный красный check_zones соответствует CI-шагу «Зоны исполнителей» (.github/workflows/ci.yml:242–246, npm run check:zones; в задании обозначен шагом 26). Блокирование done/034 и судов ночи через гейт 4б — контекст форк-записи; удалённый CI и все судебные запуски отдельно не проверялись. Рекомендация устраняет предъявленную нормативную причину, но не объявляет весь CI зелёным и не обещает отсутствие иных независимых блокеров.

## Воспроизводимое основание инв. 9

Следующая команда реально исполнена из корня клона в env -i с PATH=/usr/bin, LC_ALL=C.UTF-8, GIT_CONFIG_GLOBAL=/dev/null, GIT_CONFIG_SYSTEM=/dev/null, GIT_OPTIONAL_LOCKS=0 и git -c core.hooksPath=/tmp/dev-harness-verify/consult-spaseno/empty-hooks.inusOK (пустой каталог вне дерева). В командной строке блока указаны только переисполняемые argv белого списка. Вывод нормализован удалением конечных LF; SHA256 вычислен собственным sha256sum по сохранённым 163 байтам четырёх идентификаторов, не взят из памяти. Пин на проверенный commit вместо HEAD сохраняет воспроизводимость при последующем приземлении свидетельства.

ОСНОВАНИЕ-ДЕРЕВО:
КОМАНДА: git rev-parse frozen/contracts/031/1:contracts/031-strazh-semejstvo-mint-i-bazlajn.md frozen/contracts/031/2:contracts/031-strazh-semejstvo-mint-i-bazlajn.md frozen/contracts/031/3:contracts/031-strazh-semejstvo-mint-i-bazlajn.md b73fcea404b00f70ce6cd48aface0620731468aa:scripts/lib_zones.sh
RC: 0
ВЫВОД-SHA256: 7dd5411d662f2099ea695a698a298bd297fb1df37729bca2d21a76013982545f
