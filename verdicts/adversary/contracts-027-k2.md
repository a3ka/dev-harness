FAIL

Судимая база: 5fa3895, фикс 75f0c0d. Воспроизведения выполнены в отдельном клоне `/tmp/dev-harness-verify/adv-027-k2/repo`; игрушки — под `/tmp/dev-harness-verify/adv-027-k2/`.

## Закрытые контрпримеры к1

Все пять исходных контрпримеров повторены против настоящего `scripts/check_document.ts`; каждый честный положительный контроль вернул rc=0.

1. `commit:path -> чужой blob`: положительный rc=0; подмена blob возвращает rc=1 с `не разрешается в объявленный blob`.
2. RFC6901 `/`: положительный `/n` rc=0; `/` без пустого ключа возвращает rc=1.
3. Явный `sh -c`: положительный `python3 probe.py` rc=0; `sh` возвращает schema rc=1.
4. Выход outputs через симлинк: положительный внутренний путь rc=0; внешний симлинк возвращает rc=1.
5. Probe rc=1: положительный probe rc=0 даёт checker rc=0; rc=1 (также при JSON в stdout) даёт checker rc=1, rc=2 даёт checker rc=2.

`bash scripts/verify_antiplacebo.sh --scope check_document render_document freeze_contract check_check_contract_ready` завершился rc=0: 4 барьера, 22 фикстуры. `python3 fixtures/check_check_contract_ready/_doc027.py regressions` завершился rc=0.

## Проходящие неверные реализации / контрпримеры фикса

### 1. Git source принимает не полный commit OID

Честный контроль с полными OID commit и blob: rc=0. Затем тот же реальный `commit:path -> blob`, но `source.commit` заменён на 12-символьный short SHA: checker rc=0. Требование задаёт полный OID commit. Далее `source.commit` заменён на полный OID аннотированного frozen-тега, а не commit: checker снова rc=0. `validateSource` проверяет только непустую строку, а `git rev-parse <строка>:<path>` допускает оба представления. Связка blob теперь проверяется, но тип и полнота идентификатора commit — нет.

Воспроизведение: `python3 /tmp/dev-harness-verify/adv-027-k2/new_fix_attacks.py` до первой независимой argv-пробы; наблюдено `OID positive full commit/blob: rc=0`, `OID short commit counterexample: rc=0`, `OID annotated tag-object counterexample: rc=0`.

### 2. Shell-блоклист обходится программными загрузчиками и маскированными именами

Честный `python3 probe.py` возвращает rc=0, прямой `env sh -c ...` корректно отвергается schema rc=1. Но checker принимает rc=0 для `python3 -c 'import probe'`, `node -e "import './probe.mjs'"`, и `xargs -0 -a args python3`, где файл args передаёт Python ключ `-c` и код. То есть код из frozen argv выполняется через разрешённые загрузчики, несмотря на отсутствие shell-имени/ASCII-метасимвола в argv.

Отдельно checker принимает rc=0 для исполняемого файла с именем `./'sh'` и для `./sh；`; оба содержат shebang `/bin/sh` и печатают ожидаемый JSON. Базовое имя не совпадает с фиксированным набором, а U+FF1B не попадает в ASCII-регулярное выражение. Следовательно, проверка списка не обеспечивает требование запуска probe «без shell».

Воспроизведения: `python3 /tmp/dev-harness-verify/adv-027-k2/new_fix_attacks.py` (positive, Python и Node); `python3 /tmp/dev-harness-verify/adv-027-k2/xargs_probe.py`; `python3 /tmp/dev-harness-verify/adv-027-k2/argv_rest_probe.py`.

### 3. Некорректный RFC6901 escape `~~` принят как ключ

Честный pointer `/ok` возвращает rc=0. Источник `{"~~":8}` с pointer `/~~`, expected/value `8` также возвращает rc=0. По RFC6901 в token допустимы только escape `~0` и `~1`; `~~` невалиден. Реализация заменяет известные пары и молча сохраняет остальные `~`, поэтому даёт ответ на другой вопрос. Контроль для массива с `/-0` корректно возвращает rc=1, а JSON unicode escape `\u00e9` положительно разрешается; они не снимают дефект `~~`.

Воспроизведение: `python3 /tmp/dev-harness-verify/adv-027-k2/pointer_edge_probe.py`.

### 4. `resolveSafePath` содержит TOCTOU между `realpath` и чтением

Честный внутренний evidence даёт rc=0; путь `docs/proc/status` через симлинк на `/proc/self` корректно отвергается rc=1. Однако `resolveSafePath` возвращает строку канонического пути, после чего `readFile` повторно разрешает эту строку. LD_PRELOAD-контрольный эксперимент заменяет `docs/result.json` на симлинк внешнего valid JSON именно при `open` после успешного `realpath`; исходный внутренний файл к этому моменту намеренно неконформен. Настоящий CLI вернул rc=0, а файл стал внешним симлинком. Канонизация не защищает использование пути от подмены после проверки.

Воспроизведения: `python3 /tmp/dev-harness-verify/adv-027-k2/proc_path_probe.py`; затем `gcc -shared -fPIC -o race_open.so race_open.c -ldl && python3 /tmp/dev-harness-verify/adv-027-k2/toctou_path_probe.py`.

## Граница

Вес `copyProjectShallow` перенесён из к1 по заданию: в к2 не оценивается и не является этой находкой.

Н-39 дословно: «стабы к ветвям привязывает architect по коду, НЕ проза контракта; контракт несёт инварианты + rc-команды».

Н-101: blob этого текста записан и добавлен в index через `hash-object -w`/`update-index --cacheinfo`; identity коммита задана явно как adversary, а не унаследована от автора или реле. Н-73: использована нейтральная терминология контрольных экспериментов и контрпримеров.
