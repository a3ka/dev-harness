FAIL

# Адверсарий к8 контракта 024 — детектор утечек основного чекаута

Судимый свежий клон: `/tmp/dev-harness-024-k8`, HEAD
`096d6526ccb8e74baf337fcfafaac7d8eca3e1c7`.

Обязательная стенограмма перед записью вердикта:

```text
bash scripts/check_no_leak.sh --check /tmp/dev-harness-024-k8 → rc=0
основной чекаут чист
```

## Б3 — симлинк `.git/info/exclude` фиксируется как строка цели, но не как её содержимое

`emit_dotgit_manifest_walk` для любого симлинка печатает только
`DOTGIT:SYMLINK:<readlink-цель>` и делает `continue`; содержимое цели не
хешируется. Поэтому уже существовавший на снимке симлинк
`.git/info/exclude -> ../hidden-exclude` сохраняет ту же строку манифеста,
когда атакующий меняет `.git/hidden-exclude`. Git следует симлинку, начинает
игнорировать утечку, а `git status` и dot-git манифест одновременно становятся
пустыми относительно снимка.

Воспроизведено не описанием, а живой пробой:

```text
$ python3 /tmp/dev-harness-verify/k8_compound_link_probe.py
compound-dotdot positive-control: rc=1 named=visible
compound-dotdot attack: porcelain='' check-rc=0 output='основной чекаут чист'
FINDING .git/info/exclude -> ../hidden-exclude target mutation is invisible
```

Позитивный контроль использует тот же baseline-симлинк, но добавляет обычный
`visible`: `--check` возвращает rc=1 и называет `visible`. В атаке после
повторного снимка меняется только цель `../hidden-exclude` на правило
`compound-hidden`, затем создаётся одноимённый файл утечки. `git status
--porcelain -uall` фактически пуст, однако файл физически остаётся в toy
чекауте; `--check` фактически возвращает rc=0 и «основной чекаут чист».

Второй независимый носитель того же дефекта также воспроизведён — симлинк на
файл вне `.git` целиком:

```text
$ python3 /tmp/dev-harness-verify/k8_dotgit_attack.py
external-symlink positive-control: rc=1 named=visible-control
external-symlink attack: git-status-rc=0 porcelain='' check-rc=0 output='основной чекаут чист'
FINDING external-symlink target mutation bypasses dotgit manifest
```

Это не закрытый симлинк-класс `.git/hooks/` и не BASH_ENV: симлинк расположен
в `.git/info/exclude`, а выполняется штатный `bash scripts/check_no_leak.sh` с
честными системными утилитами и без враждебного окружения. Это прямой обход
именно того класса, ради закрытия которого внесён walk по `.git/info/`.

## Б4 — гонка между porcelain и dot-git walk допускает ложный «чисто»

Одна сверка читает состояние неатомарно: сначала `emit_manifest` получает
`git status`, затем `emit_dotgit_manifest` отдельно обходит `.git/info`.
Атакующий кладёт в `exclude` правило, скрывающее утечку, и возвращает
исходные байты `exclude` до второго прохода. Тогда status уже не содержит
утечку, а dot-git walk уже не содержит дельту rules-файла.

Воспроизведено против текущего кода. Проба заранее кладёт 9000
baseline-файлов `.git/info/aNNNNN`, чтобы второй проход длился достаточно и
переключение было наблюдаемым, а не однокадровой удачей. Повторный прогон
даёт детерминированный результат 5 из 5:

```text
$ python3 /tmp/dev-harness-verify/k8_toctou_repeat.py
attempt 0: rc=0 leak_on_disk=True output='основной чекаут чист'
attempt 1: rc=0 leak_on_disk=True output='основной чекаут чист'
attempt 2: rc=0 leak_on_disk=True output='основной чекаут чист'
attempt 3: rc=0 leak_on_disk=True output='основной чекаут чист'
attempt 4: rc=0 leak_on_disk=True output='основной чекаут чист'
false-clean attempts: 5/5
```

Каждая попытка: `exclude` изменён на `timing-leak`, файл `timing-leak`
физически лежит в корне toy-чекаута (`leak_on_disk=True` замерен после
завершения сверки), через 60 ms `exclude` возвращён к байтам снимка.
Фактический rc — 0 с маркером «основной чекаут чист». Это отвечает атаке
задания «два быстрых подряд изменения между snapshot и check»; drift
`.git/info/refs` тут вообще не нужен.

## Что удержалось

Все текущие `fixtures/check_judge_gate/*_024.sh` прошли rc=0:
`red_dotgit_info_exclude_024`, `red_info_refs_drift_024`,
`red_norma_stroka_024`, `red_path_fake_utilit_024`,
`red_stenogrammy_sudej_024` и `canary_zhivoj_024`.

```text
$ python3 /tmp/dev-harness-verify/k8_b2_refs_probe.py
B2 review-directory negative control: rc=1 output='ОТКАЗ: вердикт без стенограммы детектора: verdicts/review/k8-missing-transcript.md\n…'
HELD B2: actual reviewer verdict directory is included
refs-plus-exclude final-state control: rc=1 output='ОТКАЗ: основной чекаут загрязнён: .git/info/exclude'
HELD refs carve-out remains exact with simultaneous exclude change
```

Следовательно Б2 действительно закрыт: свежий post-boundary вердикт в
настоящем `verdicts/review/` без стенограммы ловится поимённо. Поиск по всему
дереву даёт литерал `verdicts/reviewer` только в прозе (HANDOFF.md, вердикты
ревьюера и критика), ни одного исполняемого якоря с ним нет. Также финальное
сочетание refs-drift с изменением exclude возвращает rc=1 и называет exclude:
именной пропуск `.git/info/refs` не расползся.

Остальные специально проверенные формы удержались: новый regular
`.git/info/newdir/rules` даёт rc=1, изменение содержимого через hardlink даёт
rc=1, симлинк самого каталога `.git/info` на внешний каталог приводит к
хешированию его regular `exclude` и тоже даёт rc=1. Изменение только
mtime/размера без изменения байтов отдельным обходом не является: манифест
намеренно судит содержимое, и для git rules-файлов такая метадатная смена не
меняет семантику игнора.

`bash scripts/verify_antiplacebo.sh . --scope check_judge_gate` → rc=0
(1 барьер, 3 фикстуры, все предъявлены красным повторным прогоном).

Вердикт: **FAIL**. Б3 и Б4 — новые реальные ложные зелёные вне капа
BASH_ENV-тредмилла. Предмет и фикстуры не правились; зона исправления —
реализация `scripts/check_no_leak.sh` и новые независимые red-ветви за
architect.
