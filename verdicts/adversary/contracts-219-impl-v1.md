FAIL
OBJECT=89893e66aaa8de10ef07e9f44122cc6b4f066c5d
СУД: репо=dev-harness; предмет=219; фаза=реализация; роль=adversary; вызов=1 (полный); сессия=Adv219; модель-факт=openai-codex/gpt-6.1-terra; автор implementer — MiniMax, батарея Architect219; предыдущий=—; класс=рисковый

## Блоки

**К-01 — БЛОКИРУЕТ: обязательная проверка различимости не подключена к CI.** ОБЯЗАТЕЛЬСТВО: contracts/219-uchetnye-puti-ci-klass.md:70 требует в том же CI-шаге `--repo .` и `--stabs`. СОСТОЯНИЕ: registry/ci-steps.tsv:335 содержит только `bash fixtures/workshop_project/uchetnye_puti_219/red_uchetnye_puti_219.sh --repo .`. НАБЛЮДЕНИЕ: извлечение этой строки: `rows= 1`, `--stabs present= False`; generator `--check` rc 0, следовательно workflow соответствует неполному шагу. Исправляющее свойство: оба режима реально исполняются одним CI-шагом с распространением отказа.

**К-08 — БЛОКИРУЕТ отдельно: не испытано одновременное изменение U и исключённых данных.** Обязательство И3, contracts/219-uchetnye-puti-ci-klass.md:56, явно называет эту достижимую пару изменений штатным Git-коммитом. `probe.py:245-250` в клетках `reg-add`, `reg-remove`, `reg-replace` правит только реестр; `widen` правит реестр и *код*, но не учётные данные. ОБХОД: в отдельном клоне заменён вывод `c_klass` на следующий (остальные операции честные):

```python
    changed = git('diff', '--name-only', o, n)[1].decode().splitlines()
    if REG in changed and 'registry/pauzy.tsv' in changed:
        print('uchet')
    else:
        print('uchet' if kod_hash(o, pats) == kod_hash(n, pats) else 'kod')
```

`W --repo .` по мутанту: rc 0, `KLETKI=31 ZELENYE=31 KRASNYE=0`. Затем в настоящем Git-мире одним коммитом добавлена корректная строка `uchet<TAB>registry/new-example.tsv` в реестр и изменён `registry/pauzy.tsv`:

```text
$ bash scripts/ci_klass.sh klass 2b1e0cabf33040c3a218f0cf5bfc6795c63f62e5 HEAD
uchet
rc=0
```

И3 требует `kod`. Тот же поддерживаемый сценарий на честной production: add/remove/replace одновременно с изменением pauzy — все три rc 0, `kod`. Это не утверждение о неисправности неизменённой production; источник входа — явно предусмотренный И3 коммит, источник ошибочного механизма — замена существующего сравнения хешей условной ветвью. Исправляющее свойство: настоящие Git-миры совместных изменений каждой операции различают этот дефект и честный код. Это не распознавание конкретной фикстуры.

Правило R-0074 об исключительном К-08 здесь не применимо: отдельный блок К-01 касается самого предъявленного CI-подключения. Если после исправления останется только К-08 при честной production, маршрут — reviewer и owner-аттестат консультанта, не новый полный круг.

## Остатки

- ОСТАТОК: К-16 — не укусил. `bash scripts/ci_klass.sh klass <base> HEAD` при изменении учётного пути, в том числе mode и symlink, дал `uchet`, rc 0: это путевой классификатор, а не проверка правдивости данных. `scripts/zamok_predmeta.sh:625-655` читает первый столбец паузы, `scripts/done_contract.sh:637-657` выбирает место по ограниченной грамматике, `scripts/make_task.sh:871-882` интерполирует урок как текст; исполнения записанного shell не обнаружено.
- ОСТАТОК: К-16 — не укусил: будущая смена потребителя не предъявлена как изменение OBJECT; модель не обещает статический анализ будущего кода.
- ОСТАТОК: К-08 — укусил конкретным мутантом выше; это не подделка оракула общим uid и не распознавание конечной фикстуры. Произвольные API-отказы и универсальная безопасность политических реестров не доказаны.

## Регресс

Чистые одноразовые клоны с отдельным `.git`, origin GitHub, TMPDIR внутри копии. `git diff --name-status origin/main OBJECT`: только `.github/workflows/ci.yml`, `fixtures/ci_b_087/_orakul.py`, `registry/ci-steps.tsv`, `registry/ci-zamery.tsv`; риск и доставки не включены. W — `bash fixtures/workshop_project/uchetnye_puti_219/red_uchetnye_puti_219.sh`.

После: W `--repo .` rc 0, 31/31, KRASNYE=0; `--model` rc 0, 31/31; `--stabs` rc 0, MUTACII=13 SVJAZI=28 POIMANY=28 ZHIVYH=0; `--sintaksis`, `--catalog` rc 0. `--model --compat`, `--repo . --compat`, отдельно `bash fixtures/ci_b_087/red_ci_b_087.sh`, `bash scripts/gen_ci_steps.sh --check`, `bash scripts/check_provodka.sh . contracts/219-uchetnye-puti-ci-klass.md` — rc 0; 087 110/110 и 31/31 стабов, А8 зелена. Первый вызов generator с несуществующим TMPDIR дал ошибку mktemp; повтор с TMPDIR внутри копии прошёл, отказ среды не дефект.

До (a32c577f292a2e925417d78a85cdb00abf25fae3): W `--repo .` rc 1, 20/31, KRASNYE=11, ожидаемый негатив; `--model` rc 0, 31/31; `--stabs` rc 0, 28/28, ZHIVYH=0; `--sintaksis`, `--catalog`, `--model --compat` rc 0; 087 rc 0, 110/110, стабы 31/31; generator и provodka rc 0.

Сырой ключевой вывод:
```text
KLETKI=31 ZELENYE=20 KRASNYE=11
W repo rc=1
KLETKI=31 ZELENYE=31 KRASNYE=0
SVJAZI=28 POIMANY=28 ZHIVYH=0
ИТОГ 087: клеток ok=110 КРАСНО=0; стаб-пак: поймано 31/31 (subject)
COMPAT red_ci_b_087.sh rc=0
COMPAT gen_ci_steps.sh rc=0
COMPAT check_provodka.sh rc=0
```

## Мутации и наблюдения

Изменения только в одноразовых клонах. `hash HEAD` с добавлением `uchet registry/risk-legacy.tsv` и `uchet registry/dostavki/` дал rc 0: эти риск-пути не часть PROTECT. Это неконформное расширение U, отсекаемое snapshot, не баг production: контракт требует отказ только для PROTECT. Для registry/ci-steps.tsv, scripts/ci_klass.sh, .github/workflows/ci.yml и registry/ — hash rc 1, пустой stdout, диагноз «накрывает машину классификатора». `registry/*.tsv`, пробел вместо TAB и ведущий пробел — rc 1 с диагнозом грамматики. `pauzy.tsv`, `x/registry/pauzy.tsv`, `registry/pauzy.tsv/`, повтор точного пути — грамматически разрешены hash rc 0, но не являются каноническим U; точный snapshot отклоняет расширения/дубликаты. Модификация режима и замена учётного файла на symlink дали klass `uchet`, rc 0: метаданные кодовых, не исключённых путей участвуют в H. Независимые сценарии add/remove/replace U вместе с pauzy дали `kod`, rc 0.

Собственные обманки против W --repo: `exit 127` → rc 1, 30 красных; константа `uchet` → rc 1, 14 красных; сравнение старого хеша с самим собой → rc 1, 14 красных; вызов несуществующего инструмента вместо python → rc 1, 30 красных. Пустой набор uchet → rc 2 NOT_IMPLEMENTED (не ложная зелень; в одном мире фикстурный commit оказался пустым). Штатная нейтрализация `STRIP_NOOP` поймана, STRIP_LEFT_ACCOUNTING; проверка strip сохраняет байты code, HEAD и удаляет учётное. Честный контроль и 28 дифференциальных контролей зелены. Снимок множества проверяется отдельно чтением строк, остальные клетки исполняют hash/klass/strip на Git-деревьях; это не просто поиск строк, но комбинация И3 отсутствует.

А8: `fixtures/ci_b_087/red_ci_b_087.sh:331-336` сравнивает полные сортированные наборы, не subset; oracle расширяется каноном в `_orakul.py:15-22`. Собственная атака: добавить в реестр клона `uchet<TAB>registry/unknown219.tsv`, запустить `bash fixtures/ci_b_087/red_ci_b_087.sh`: rc 1, `КРАСНО: А8 реестр: U и минимум legkij: строки uchet реестра ... registry/unknown219.tsv ... ≠ U контракта ...`, `ИТОГ 087: клеток ok=109 КРАСНО=1; стаб-пак: поймано 31/31`.

## НЕ ЗАЩИЩАЕТ

Результаты относятся к указанному OBJECT и испытанным мирам; не доказывают отсутствие всех будущих атак на данные, API, владельца или будущие потребители. Синтетический мутант не является утверждением, что текущий классификатор содержит эту ошибку. Независимый reviewer должен судить область и интеграцию после исправления.

## Советы

Закрепить одновременные операции U+учётные данные отдельными реальными Git-мирами; не подменять их правками одного реестра либо проверкой текста. Не расширять PROTECT ad hoc для risk/dostavki: механизм защиты этих путей здесь — точный состав U и кодовость изменений списка.
