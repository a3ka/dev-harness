FAIL
OBJECT=c41a1aa3fa362ec233c511924e22fec3ecb5229e

СУД: репо=dev-harness; предмет=226; фаза=реализация; роль=adversary; вызов=1 (полный); сессия=Adv226; модель-факт=openai-codex/gpt-6.1-terra; автор Impl226 — MiniMax (задание). `scripts/models_actual.sh --tsv --bind --session Adv226`: adversary openai-codex/gpt-6.1-terra allowed Adv226 c41a1aa3fa362ec233c511924e22fec3ecb5229e. Судья и автор — разные сессии.

## Карта классов

К-01: блок — обязательный режим синтаксиса отсутствует в CI
К-02: чисто — sourceCanon не объявлен; вход: контракт 226 и задание
К-03: чисто — регрессы 187, 186, 203, 201, 193, 170, 166, 169, 224, 996; diff 201 не меняет ожидания
К-04: чисто — diff 14ee4f7b0..OBJECT: 8 путей implementer, 201 dver_probe, SDACHA 226 и три файла CI
К-05: блок — CI не исполняет обязательную команду --sintaksis
К-06: чисто — пустая выборка и отсутствующий shellcheck дают rc 2
К-07: чисто — W --repo и W --model rc 0, 56 клеток, 0 красных
К-08: блок — два неправильных предиката грамматики проходят полные 56 клеток
К-09: блок — не различаются пробел в конце и символ `_` в начале владельца
К-10: чисто — вход: probe.py judge проверяет rc, каналы, причину и побочные эффекты
К-11: чисто — вход: literal CASES и независимый журнал argv gh в probe.py
К-12: чисто — вход: действующий profile_resolver.sh, jq и реальные Git-объекты
К-13: н/п — новых секретов и разрешений нет
К-14: чисто — минимальный честный owner/repo зелёный; CRLF/BOM исследованы отдельно
К-15: чисто — W --catalog: 56 клеток, 18 стабов, 25 связей; --stabs rc 0, живых 0
К-16: чисто — EACCES существующего профиля rc 1 с ARCH_PROFILE; исключения модели угроз указаны ниже
К-17: н/п — продуктовая архитектурная модель и writers не меняются

## Б-1. CI не исполняет обязательный синтаксический контроль

БЛОКИРУЕТ contracts/226-arch-door-profile-key.md:69; registry/ci-steps.tsv:339.
ОБЯЗАТЕЛЬСТВО: собственный CI step после реализации исполняет W --repo ., --stabs и --sintaksis; --sintaksis включает shellcheck 0.11.0 и сравнение новых диагностик.
СОСТОЯНИЕ: зафиксированный OBJECT, строка реестра генерируемого CI; это не локальная мутация.
НАБЛЮДЕНИЕ: `git show OBJECT:registry/ci-steps.tsv` даёт `step check:arch-door-profile-key-226-family-selftest 200 bash ... --repo . && bash ... --model && bash ... --stabs && bash ... --catalog`: --sintaksis отсутствует. `bash scripts/check_provodka.sh . contracts/226-arch-door-profile-key.md` rc 0, что не доказывает фактическое исполнение --sintaksis. Ручной вызов или pre_critic не заменяет обязательный CI step.
ОБХОД: новая shellcheck-диагностика в shell-носителе не будет проверена именно этим шагом, поскольку синтаксический режим не вызывается. Это отсутствие требуемой проводки, не утверждение о выявленной ошибке production.
ПРОИСХОЖДЕНИЕ: дельта
КЛАСС: К-01, К-05
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: CI исполняет --sintaksis с настоящим пинованным shellcheck и учитывает его код возврата.

## Б-2. Проверка принимает нарушенную грамматику

БЛОКИРУЕТ contracts/226-arch-door-profile-key.md:36,62-66; fixtures/workshop_project/arch_door_profile_key_226/probe.py:38-59; scripts/profile_resolver.sh:960-963.
ОБЯЗАТЕЛЬСТВО: первый символ каждой половины `[A-Za-z0-9]`, прочие `[A-Za-z0-9_.-]`, конец значения точный; без trim, пробелов и искусственных исключений. Контракт требует различающую батарею и запрещающие пробы грамматики.
СОСТОЯНИЕ: поддерживаемая операция — запись `hooks.archBrief` в repo-профиль. Входы `owner/repo ` и `_owner/repo` прямо нарушают названный алфавит; первый прямо задан суду. Это не подмена PATH или TOCTOU. Мутации отдельно заменяют существующий jq-регекс production; формат проверки и ожидаемые результаты не меняются.
ОБХОД: в одноразовом клоне заменить в `scripts/profile_resolver.sh` окончание regex `[A-Za-z0-9_.-]*\\z` на `[A-Za-z0-9_.-]* ?\\z` (один необязательный завершающий пробел). `W --repo <клон>`: rc 0, сырой итог `KLETKI 56 KRASNYH 0 SVJAZI 0 ZHIVYH 0`. Для одного и того же реального Git/профильного мира с `hooks.archBrief="owner/repo "`: честный `bash scripts/profile_resolver.sh --repo <продукт>` rc 1, stdout пуст, `profile ОТКАЗ: значение вне алфавита: hooks.archBrief: ожидается false или owner/repo`; мутант rc 0 и печатает merged JSON. Клетка `bad-space` проверяет одновременно ведущий и конечный пробел (`' a/b '`), поэтому узкое разрешение конечного пробела проходит.
Независимо заменить первый алфавит владельца `^[A-Za-z0-9]` на `^[A-Za-z0-9_]`; для `_owner/repo` честный resolver rc 1 с тем же отказом, мутант rc 0; `W --repo <другой-клон>` rc 0, `KLETKI 56 KRASNYH 0 SVJAZI 0 ZHIVYH 0`. Оба свидетеля происходят из поддерживаемого профиля, механизм — замена уже существующего предиката, не искусственный отказ. Это дефект различимости батареи, не утверждение что честная production принимает эти значения.
ПРОИСХОЖДЕНИЕ: пропущен-ранее
КЛАСС: К-08, К-09
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: независимые отрицательные входы адресно проверяют каждую сторону предиката, включая только конечный пробел и первый символ каждой половины, при сохранении честного валидного контроля.

## Прогоны на неизменном OBJECT

W=`bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh`. Чистый origin-клон на OBJECT; TMPDIR внутри своей копии; VALIDATE_STD_SHELLCHECK указан на 0.11.0. Результаты — rc команды и сырые итоговые строки:

```
W --repo .       rc=0  KLETKI 56 KRASNYH 0 SVJAZI 0 ZHIVYH 0
W --model        rc=0  KLETKI 56 KRASNYH 0 SVJAZI 0 ZHIVYH 0
W --stabs        rc=0  KLETKI 56 KRASNYH 0 SVJAZI 25 ZHIVYH 0
W --sintaksis    rc=0  SINTAKSIS 25 SHELLCHECK_DIFFERENTIAL 6 BASELINE_DIAGNOSTICS 30
W --catalog      rc=0  KLETKI 56 STABY 18 SVJAZI 25
W --regression   rc=0  CELLS=21 STABS=0 FAILURES=0 ZHIVYH=0; REGRESSION 203 PIN186 rc=0
check_sdacha --run rc=0  СДАЧА: лист зелёный (двери=15 карта=17/17 дельта=3)
pre_critic       rc=0  КРИТИК: дверь зелёная
gen_ci_steps --check rc=0
201 --repo .     rc=0  CELLS=62 STABS=0 FAILURES=0
187 --repo .     rc=0  CELLS=111 STABS=0 FAILURES=0
```

База 14ee4f7b0: `W --repo <base>` rc 1, `KLETKI 56 KRASNYH 45 SVJAZI 0 ZHIVYH 0`. Соседи: 193 rc 0 `KLETKI=152 ZELENYE=152 KRASNYE=0`; 170 rc 0; 166 rc 0; 169 rc 0; 224 rc 0 `KLETKI 100 KRASNYH 0`; 996 rc 0 `examined=111 mutants=0 mismatches=0`. 995 --repo . rc 1 SUBJECT_ABSENT: эта батарея ожидает mobile-продукт, которого в станции нет; --model rc 0, `SVIP itog: N=20, krasnykh 0`. 186 pin проверен W --regression, пять отдельных клеток зелены; 203 — 21 клетка зелена.

## Независимые мутации и крайние состояния

Каждая мутация — отдельный клон; команда `W --repo <клон>`. Изменения production не доставляются. Повтор перечисленных в build.py стабов здесь включён для контраста; отсутствующий лист, завершающий пробел, null и три независимые ветви scope — дополнительные изменения.

| Изменение | rc | Сырой итог |
| --- | ---: | --- |
| ошибка resolver становится выключением (`return 2` → `return 0`) | 1 | KLETKI 56 KRASNYH 5 SVJAZI 0 ZHIVYH 0 |
| умолчание отсутствующего листа false → X/Y | 1 | KLETKI 56 KRASNYH 3 SVJAZI 0 ZHIVYH 0 |
| JSON 0 приравнен false | 1 | KLETKI 56 KRASNYH 1 SVJAZI 0 ZHIVYH 0 |
| JSON null приравнен false | 1 | KLETKI 56 KRASNYH 4 SVJAZI 0 ZHIVYH 0 |
| разрешён один завершающий пробел | 0 | KLETKI 56 KRASNYH 0 SVJAZI 0 ZHIVYH 0 |
| `_` разрешён первым символом owner | 0 | KLETKI 56 KRASNYH 0 SVJAZI 0 ZHIVYH 0 |
| неверный defaults-слой игнорируется | 1 | KLETKI 56 KRASNYH 6 SVJAZI 0 ZHIVYH 0 |
| pin берёт PRODUCT_REPO из env с приоритетом | 1 | RED pin-env PRODUCT_REPO_DEPENDENCY; KLETKI 56 KRASNYH 1 |
| make_task: guard `_scope_rc -le 1` → `-le 2` | 0 | KLETKI 56 KRASNYH 0 SVJAZI 0 ZHIVYH 0 |
| freeze_contract: то же, отдельно | 0 | KLETKI 56 KRASNYH 0 SVJAZI 0 ZHIVYH 0 |
| done_contract: то же, отдельно | 0 | KLETKI 56 KRASNYH 0 SVJAZI 0 ZHIVYH 0 |

Последние три живые мутации показывают слабость адресной изоляции ветви scope; сами по себе они не доказывают достижимый обход без запрещённого TOCTOU, поскольку раннее чтение профиля может отказать прежде (`make_task.sh:380-390,608-612`; отказные клетки freeze/done показывают ранний отказ workflowPaths). Поэтому отдельного блока о достижимой поломке дверей здесь нет. `--stabs` исполняет носители model/, а не каждую из этих мутаций; не объявляю его свидетельством адресной связи.

- Честный `W --model --cell minimal-value`: rc 0, `GREEN minimal-value`, `KLETKI 1 KRASNYH 0 SVJAZI 0 ZHIVYH 0`.
- `W --repo <пустой каталог> --cell literal-free`: rc 2, `NOT_IMPLEMENTED: EMPTY_STATIC_SAMPLE`.
- `VALIDATE_STD_SHELLCHECK=<отсутствующий путь> W --sintaksis`: rc 2, `NOT_IMPLEMENTED: SHELLCHECK_WRAPPER b'VALIDATOR_MISSING: shellcheck\n'`.
- В отдельном клоне resolver заменён на `exit 127`; `W --repo <клон> --cell other-enabled`: rc 1, `RED other-enabled DIAGNOSIS`, `KLETKI 1 KRASNYH 1`.
- Честная production, отдельный Git-мир: файл профиля mode 000 → rc 1, пустой stdout, Permission denied и ARCH_PROFILE. CRLF и BOM дошли до того же `ARCH_NOT_EVALUATED`, что обычный JSON, из-за отсутствующего snapshotDigest в этом упрощённом мире, rc 2; это не позитивный контроль пина. Двойной hooks: последний false даёт rc 0 ARCH_187A_SKIP, последний owner/repo доходит до проверки пина; jq применяет последний ключ. Сломанный JSON → rc 1 ARCH_PROFILE. Висячая ссылка при lock → ARCH_PROFILE_MISSING; без lock → ARCH_187A_SKIP.
- `W --repo <OBJECT> --cell unknown-layer-sibling`: rc 0, `GREEN unknown-layer-sibling`, `KLETKI 1 KRASNYH 0`; предупреждение defaults.hooks сохранено.
- Статика: архитектурный `a3ka/CompliorOS-architecture` в pin сохраняется вне предмета; Complior-back в make_task — комментарии. Diff 201 добавляет только объявление hooks в мир back.

## НЕ ЗАЩИЩАЕТ

Контракт не назначает adversary ловцом ни одной строки остатка: санкционированное отсутствие/false, опечатка неизвестного имени и отсутствие lock; доверенная установка, подмена PATH и TOCTOU; содержание модели и старые shellcheck-диагностики. `W --repo <OBJECT> --cell unknown-layer-sibling` rc 0 подтверждает предупреждение, а не отказ. Backend PR и живую проверку до cutover выполняют orchestrator/reviewer; здесь не утверждается их доставка.
