FAIL

Предмет: `afe6fe2feb6b310a2a35dbca992572bf4318578a`.
Первый круг: `57c8141f1936847c565077dc95b5c108dbedabec`.

АРБИТР: `arbiter` — повтор причины блокера 1 первого круга: предмет требует три якоря dual-control, но rc-критерий по-прежнему допускает потребители без чтения манифеста с живой `origin/main` и без сверки SHA.

## Закрытие вердикта 57c8141

- Блокер 1 — **не закрыт**: `contracts/023-rezervacija-nomera-dver-po-tegu.md:121-127` требует «файл читается по ЖИВОЙ шапке `refs/heads/main` НА origin (ls-remote шапки → fetch объекта → show), НЕ по локальной ветке» и «sha-origin == sha-манифеста», но именованные ворота приёмки не различают эти свойства; блокирующая находка ниже.
- Блокер 2 — **закрыт**: `contracts/023-rezervacija-nomera-dver-po-tegu.md:261-269` требует, чтобы «каждый прогон черпит NNN из непересекающихся широких поддиапазонов», «basename toy-корней случаен», а субъект был «КОПИЕЙ scripts/ под случайным именем»; два живых прогона каждого `red_*` дали разные NNN и rc 1 с именованным отказом.
- Блокер 3 — **закрыт**: `contracts/023-rezervacija-nomera-dver-po-tegu.md:270-273` оставляет «привязка стабов к ветвям — кодом шапок red-файлов»; таблица пар удалена, `git grep -E '^\|[[:space:]]*С[0-9]+[[:space:]]*\|'` по контракту дал 0 совпадений.
- Блокер 4 — **закрыт**: `contracts/023-rezervacija-nomera-dver-po-tegu.md:81-91` требует норма-строку в `roles/orchestrator.md` при done и называет механизм-минимум: «гейт (ii) … отвергает `--nnn`-спавн без пары на origin»; `contracts/023-rezervacija-nomera-dver-po-tegu.md:421-422` делает приземление нормы условием готовности.
- Совет 1 — **закрыт**: `contracts/023-rezervacija-nomera-dver-po-tegu.md:398-400` прямо говорит: «Живая проба А-89 измерена … rc-набор её не несёт — файл в дереве не живёт, red-предъявление боли — в1 red_priznanie»; команды на `tmp/probe_*` в приёмке нет.
- Совет 2 — **закрыт**: `contracts/023-rezervacija-nomera-dver-po-tegu.md:423-424` называет rc-команду `bash scripts/check_ci_gate.sh . <done-SHA>`.
- Совет 3 — **закрыт**: `contracts/023-rezervacija-nomera-dver-po-tegu.md:354-357` фиксирует неперекрывающуюся границу: «каталоги fixtures/* целиком в зоне architect, файлов fixtures/ в зоне implementer НЕТ».

## Dual-control и генуинность

Три якоря в предмете названы (`contracts/023-rezervacija-nomera-dver-po-tegu.md:121-127`), исключительная зона и land-ловец названы (`contracts/023-rezervacija-nomera-dver-po-tegu.md:236-241,347-349`), отвергнутые альтернативы названы (`contracts/023-rezervacija-nomera-dver-po-tegu.md:139-146`). Остаток не скрыт: `contracts/023-rezervacija-nomera-dver-po-tegu.md:322-329` говорит «Single-uid identity-forgery (назван честно, НЕ „закрыто полностью“)» и относит GPG-подписи в «ОТДЕЛЬНЫЙ hardening-предмет, НЕ 023».

Обе заявленные отрицательные грани присутствуют в коде ворот: агентский push тега без манифеста — `red_dver` в8 и `red_gejt` в7; агентская строка манифеста на wip, которую land обязан отклонить, — `red_priznanie` в6. Однако первая грань проверяет только отсутствие строки повсюду, а положительные входы имеют одну и ту же правильную строку локально и на origin. Поэтому она не доказывает ни источник строки, ни равенство SHA.

БЛОКИРУЕТ contracts/023-rezervacija-nomera-dver-po-tegu.md:202-214,381-418 — предмет требует чтение манифеста именно с живой `origin/main` и совпадение `sha-origin == sha-манифеста`, но rc-критерий имеет только положительный полный резерв и отрицательный агентский push **без строки**. Нет отрицательного входа, где строка существует только локально, либо где строка на `origin/main` содержит чужой 40-hex SHA. Из-за этого команды не отличают все три якоря от проверки «origin-тег существует ∧ в локальной main есть любая грамматически верная строка N».
ОБХОД: реализовать обе двери так, чтобы они проверяли точный тег через `ls-remote origin`, но читали `registry/contracts.tsv` из локальной `refs/heads/main` и принимали любую строку `<NNN> → <40-hex>` без сравнения SHA. В независимом клоне такие два потребителя дали rc 0 обоим профильным `red_*` даже после замены положительного `mint_rezerv`: коммит манифеста оставлен только локально (на `origin/main` файла нет), а в строку записан SHA базового commit-object вместо SHA tag-object. Наблюдение отдельной пробой: `origin_manifest=absent`, `tag_object_sha != manifest_foreign_sha`, `origin_main != local_main`, слабая дверь вернула rc 0. Остальные ветви можно реализовать по предмету, не устраняя этот обход; тогда весь объявленный критерий готовности зелёный, а якоря (3б)/(3в) не сделаны.

## Прогоны в свежем клоне ветки

Явный cwd каждого прогона: `/tmp/critic/repo023r2`.

- `red_dver_po_tegu.sh`: rc 1 на NNN 134; rc 1 на NNN 143 — оба раза «дверь по тегу отсутствует … вне зоны».
- `red_gejt_javnogo_nomera.sh`: rc 1 на NNN 169; rc 1 на NNN 174 — оба раза «гейт явного номера отсутствует».
- `red_priznanie_po_nomery_puti.sh`: rc 1 на NNN 134; rc 1 на NNN 135 — оба раза «признание судит тег ОКНА, не номер пути».
- Scoped-семьи: `check_staged` — 23 case-файла, rc 0; `spawn_agent` — 2, rc 0; `check_zones` — 19, rc 0.
- `fixtures/check_zones/_schet_fixtur.sh` — rc 0; `scripts/check_nabludenia.sh .` — rc 0; `scripts/check_ceilings.sh .` — rc 0; `scripts/check_zones.sh .` — rc 0.
- Форма: `contracts/023-rezervacija-nomera-dver-po-tegu.md:426-427` — «Незаполненные требования: нет».

Новых советов нет.
