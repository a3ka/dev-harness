FAIL
OBJECT=fc525aad2af575f97cec806a210d2d3f6e2dda1c

СУД: репо=dev-harness; предмет=226; фаза=реализация; роль=adversary; вызов=2 (scoped; по дельте Architect226d + CI); сессия=Adv226b; модель-факт=openai-codex/gpt-6.1-terra; автор Impl226 — MiniMax; предыдущий=archive/226/adversary-v1-fail-b4c6d8e2fa. `scripts/models_actual.sh --tsv --bind --session Adv226b`: adversary, allowed, этот OBJECT; судья — другая сессия.

## Карта классов

К-01: блок — Б-3: обязательные check_sdacha и pre_critic на OBJECT возвращают rc 1
К-02: чисто — без изменений с вызова 1; sourceCanon не объявлен
К-03: чисто — регрессы 187/186/203/201/193/224 rc 0, числа ниже
К-04: чисто — git diff c41a1aa3f..OBJECT: scripts/ неизменны, CI.yml меняется в генерируемой секции
К-05: чисто — gen_ci_steps.sh --check rc 0; строка CI исполняет все пять режимов
К-06: чисто — без изменений с вызова 1; пустая выборка и отсутствующий валидатор возвращали rc 2
К-07: чисто — W --repo и --model rc 0, KLETKI 71 KRASNYH 0
К-08: блок — Б-2: FALSE/False принимаются мутированным предикатом при зелёной батарее
К-09: блок — батарея не различает строки FALSE/False и недопустимое значение
К-10: чисто — без изменений с вызова 1; оракул проверяет rc, канал, причину, побочные эффекты
К-11: чисто — без изменений с вызова 1; CASES и argv-свидетель вне субъекта
К-12: чисто — без изменений с вызова 1; используются реальный jq и resolver
К-13: н/п — без изменений с вызова 1; новых секретов нет
К-14: чисто — честный resolver принимает валидное значение длиной 1026
К-15: чисто — W --catalog rc 0, 71 клетка, 24 стаба, 32 связи; прежние связи не удалены
К-16: чисто — без изменений с вызова 1; граница модели угроз 226 сохранена
К-17: н/п — без изменений с вызова 1; продуктовую архитектуру не меняют

## Б-3. Сдаточная форма дельты не проходит обязательную дверь

БЛОКИРУЕТ contracts/226-arch-door-profile-key.md:68; fixtures/workshop_project/arch_door_profile_key_226/SDACHA.md:92; scripts/check_sdacha.sh. ОБЯЗАТЕЛЬСТВО: check_sdacha --run и pre_critic обязаны возвращать rc 0. СОСТОЯНИЕ: чистый клон на точном OBJECT, валидатор shellcheck 0.11.0, TMPDIR внутри собственной копии, SDACHA_TIMEOUT_SEK=1200, SDACHA_BUDZHET_SEK=2400. НАБЛЮДЕНИЕ:

```
bash scripts/check_sdacha.sh <чистый-клон> contracts/226-arch-door-profile-key.md --run
rc 1: ОТКАЗ: строка 92: ряд таблицы («- ») вне машинной секции: - W --repo .: rc 0, `KLETKI 71 KRASNYH 0 SVJAZI 0 ZHIVYH 0`.
bash scripts/pre_critic.sh contracts/226-arch-door-profile-key.md
rc 1: ОТКАЗ: сдаточный лист красен (rc=1): ОТКАЗ: строка 92: ряд таблицы («- ») вне машинной секции: - W --repo .: rc 0, `KLETKI 71 KRASNYH 0 SVJAZI 0 ZHIVYH 0`.
```

Это не таймаут и не отказ shellcheck: обе команды отвергают форму до исполнения листа. Источник — добавленный дельтой SDACHA-раздел с маркированным перечислением вне машинной секции. Требуемое свойство: лист на OBJECT принимается действующей дверью и обе обязательные команды реально зелёные.
ПРОИСХОЖДЕНИЕ: дельта
КЛАСС: К-01

## Б-2. Регистр строки false не различён

БЛОКИРУЕТ contracts/226-arch-door-profile-key.md:36,62-66; scripts/profile_resolver.sh:961; fixtures/workshop_project/arch_door_profile_key_226/probe.py:55-71. ОБЯЗАТЕЛЬСТВО: ровно JSON false или грамматически верная строка owner/repo, без casefold; различающая проверка. Эта дельта расширяет грамматику после прежнего Б-2.

СОСТОЯНИЕ: поддерживаемая операция — запись JSON-строки `"FALSE"` или `"False"` в repo-профиль `hooks.archBrief`. Механизм ошибки — изменение существующего предиката `if . == false then true` на `if . == false or . == "FALSE" or . == "False" then true`; не ошибка среды и не подмена PATH. В каждом эксперименте одна мутация, файл восстановлен между экспериментами.

ОБХОД: `W --repo .` на мутанте возвращает rc 0, `KLETKI 71 KRASNYH 0 SVJAZI 0 ZHIVYH 0`, хотя реальный resolver на поддерживаемом профильном Git-мире с `"FALSE"` возвращает rc 0 и merged JSON вместо отказа. На той же записи честный resolver rc 1, `profile ОТКАЗ: значение вне алфавита: hooks.archBrief: ожидается false или owner/repo`. Старая клетка проверяет только `"false"`, а добавленные — разделители и алфавит owner/repo. Ошибку предъявляет реальный resolver, не подсчёт теста.
ПРОИСХОЖДЕНИЕ: узкое-закрытие
КЛАСС: К-08, К-09
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: различать неверный регистр на достижимом профильном входе, сохраняя честный положительный контроль и независимый оракул.

Это повтор класса Б-2 при исчерпанном бюджете 1+1: требуется арбитраж конечной границы по §Остановка; новый полный вызов автоматически не назначается.

## Б-1 и прежние два свидетеля Б-2

Б-1 закрыт: `registry/ci-steps.tsv` step `check:arch-door-profile-key-226-family-selftest` запускает `--repo .`, `--model`, `--stabs`, `--catalog`, скачивает shellcheck v0.11.0 и запускает `--sintaksis` с `VALIDATE_STD_SHELLCHECK`. `bash scripts/gen_ci_steps.sh --check` rc 0. Diff CI.yml ограничен генерируемым разделом матрицы. `git diff c41a1aa3f fc525aad2 -- scripts/` пуст. Diff probe.py и build.py только добавления; source.json сохраняет прежние носители и связи.

В одноразовом клоне на OBJECT, W=`bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh`, каждая мутация отдельно, полный `W --repo .`:

```
*\\z -> * ?\\z: rc 1 RED bad-trailing-space RC,DIAGNOSIS,PARTIAL_OUTPUT; KLETKI 71 KRASNYH 1
^[A-Za-z0-9] -> ^[A-Za-z0-9_]: rc 1 RED bad-owner-underscore RC,DIAGNOSIS,PARTIAL_OUTPUT; KLETKI 71 KRASNYH 1
/[A-Za-z0-9] -> /[A-Za-z0-9.]: rc 1 RED bad-repo-dot RC,DIAGNOSIS,PARTIAL_OUTPUT; KLETKI 71 KRASNYH 1
/[A-Za-z0-9] -> /[A-Za-z0-9.-]: rc 1 RED bad-repo-hyphen, bad-repo-dot; KLETKI 71 KRASNYH 2
\\z -> $: rc 1 RED bad-newline, bad-trailing-lf; KLETKI 71 KRASNYH 2
[A-Za-z0-9_.-]*/ -> [A-Za-z0-9_. -]*/: rc 1 RED bad-owner-internal-space; KLETKI 71 KRASNYH 1
elif type == "string" then test( -> elif type == "string" then (length <= 1024) and test(: rc 0 KLETKI 71 KRASNYH 0
if . == false -> if . == false or . == "FALSE" or . == "False": rc 0 KLETKI 71 KRASNYH 0
```

Два прежних мутанта и соседние знаки/якорь/внутренний пробел теперь пойманы; их исходные свидетели закрыты, но более широкий класс ещё нет. Проба длины: в том же реальном world-builder значение из 1024 букв owner, `/R` — честный resolver rc 0; мутант с лимитом rc 1 и `значение вне алфавита`. СОВЕТ: этот конкретный лимит — специально добавленный запрет; без документированного источника такого фильтра §Порог не превращает его один в блок, несмотря на живую мутацию. Он не доказывает дефект честной production; конечная батарея не обещает полноту произвольных реализаций.

## Прогоны неизменного OBJECT

Чистый клон, по одной команде, настоящий shellcheck. Сырые итоги:

```
W --repo .       rc 0  KLETKI 71 KRASNYH 0 SVJAZI 0 ZHIVYH 0
W --model        rc 0  KLETKI 71 KRASNYH 0 SVJAZI 0 ZHIVYH 0
W --stabs        rc 0  KLETKI 71 KRASNYH 0 SVJAZI 32 ZHIVYH 0
W --sintaksis    rc 0  SINTAKSIS 31 SHELLCHECK_DIFFERENTIAL 6 BASELINE_DIAGNOSTICS 30
W --catalog      rc 0  KLETKI 71 STABY 24 SVJAZI 32
187 --repo .     rc 0  CELLS=111 STABS=0 FAILURES=0
186 pin --repo . rc 0  pin_merged, lock_missing, pin_missing, pin_wrong, pin_arch_head ok
203 --repo .     rc 0  CELLS=21 STABS=0 FAILURES=0 ZHIVYH=0
201 --repo .     rc 0  CELLS=62 STABS=0 FAILURES=0
193 --repo .     rc 0  KLETKI=152 ZELENYE=152 KRASNYE=0
224 --repo .     rc 0  KLETKI 100 KRASNYH 0
check_sdacha     rc 1  строка 92: ряд таблицы вне машинной секции
pre_critic       rc 1  сдаточный лист красен, строка 92
```

`--stabs` в частности вывел `CAUGHT st21-trailing-space bad-trailing-space`, `CAUGHT st22-owner-initial-underscore bad-owner-underscore`, `CAUGHT st23-repo-initial-underscore bad-repo-underscore`, `CAUGHT st24-repo-initial-hyphen bad-repo-hyphen`, `CAUGHT st25-final-lf bad-trailing-lf`, две связи st26. Это исполняемые связи из build.py/source.json, не утверждение прозы контракта.

## Scope из совета первого вызова

`make_task.sh:388-390,565-573` требует файл профиля и успешный resolver прежде scope; без запрещённой TOCTOU смены состояния rc 2 по ошибке профиля через эту ветвь не показан. Для freeze/done предположение о раннем resolver не универсально: при отсутствующем файле профиля `project_paths_resolve` законно использует legacy-fallback, а lock остаётся. В реальном Git-мире с перенесённым в корневой contracts/ предметом честные freeze и done дали rc 1 `ARCH_PROFILE_MISSING: harness.project.json`. Отдельно заменив `[ "$_scope_rc" -le 1 ]` на `-le 2`, freeze дошёл до отказа `заморозка v1 без вердикта критика`, done — до `нет заморозки frozen/contracts/777/*`. Ошибочная ветвь scope достижима без TOCTOU и мутанты проходят дальше без правильной причины, но полный успешный freeze/done и вредный побочный эффект здесь не показаны. СОВЕТ: адресные сценарии отсутствующего файла с lock для этих потребителей; обход честной production не утверждается.

## НЕ ЗАЩИЩАЕТ

Контракт не назначает adversary ловцом строк остатка: санкционированное отсутствие/false и отсутствие lock, опечатка неизвестного имени, подмена доверенного PATH/Git, TOCTOU, содержимое модели и inherited shellcheck-диагностики ловятся другими названными ролями. sourceCanon не объявлен.

Заданная команда `bash scripts/check_verdict_karta.sh "$PWD" verdicts/adversary/contracts-226-impl-v1.md` до коммита: rc 1 `ОТКАЗ: путь вердикта вне грамматики verdicts/critic/…`. На OBJECT validator безусловно принимает только путь critic и читает только HEAD-блоб. Получить rc 0 для заданного adversary-пути до коммита невозможно без изменения инструмента/цели; подмена пути не выполнялась. `pre_judge.sh verdict --repo <своя-копия> --file <абсолютный-вердикт>` rc 0, `VERDICT_BRANCH=wip/226/adversary`. Н-85 также отклонил попытку сообщить блокер через agent://Main; чужую копию не использовал.
