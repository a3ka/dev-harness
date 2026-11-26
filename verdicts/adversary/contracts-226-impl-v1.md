FAIL
OBJECT=3e82f3cf7d6cb16a8d886804477f766e7518ab29

СУД: репо=dev-harness; предмет=226; фаза=реализация; роль=adversary; вызов=3 (узкий; по праву консультанта; по дельте Architect226e); сессия=Adv226c; модель-факт=openai-codex/gpt-6.1-terra; автор Impl226 — MiniMax; Architect226e — openai-codex/gpt-6.1-sol; предыдущий=archive/226/adversary-v2-fail-8d1ef6f516. `scripts/models_actual.sh --tsv --bind` подтвердил allowed для обеих сессий; автор и судья независимы. Источник входа — поддерживаемый repo-профиль; sourceCanon не объявлен.

## Карта классов

К-01: н/п — прежняя ошибка формы снята; текущий census rc 1 из-за позднего тега 223
К-02: чисто — sourceCanon не объявлен, контракт 226
К-03: чисто — регресс 187/186/203/201/193/224 rc 0
К-04: чисто — `git diff 8d1ef6f51 OBJECT -- scripts/` пуст
К-05: чисто — CI вызывает пять режимов, gen_ci_steps --check rc 0
К-06: чисто — пустая выборка и отсутствующий shellcheck rc 2; exit 127 пойман
К-07: чисто — честная production и эквивалентный предикат 933/0
К-08: блок — Б-1: изменённая существующая проверка наличия листа переживает полную батарею
К-09: блок — Б-1: CR в сетке проверяется только на вынутом jq, не через публичный resolver
К-10: блок — Б-1: публичные rc, stderr и пустой stdout не проверены для зелёной отрицательной клетки сетки
К-11: чисто — посимвольный A/B-оракул вычисляется до запуска субъекта
К-12: чисто — настоящий jq, Git и resolver в контроле, но сетка не проверяет управление resolver для каждого входа
К-13: н/п — новых секретов нет
К-14: чисто — честный и эквивалентный контроль 933/0
К-15: чисто — catalog 933 клеток, 47 стабов, 63 связи
К-16: блок — Б-1: поддерживаемый некорректный профиль может пройти проверку значения при зелёном W
К-17: н/п — продуктовая архитектурная модель не меняется

## Б-1. Сетка судит вынутый предикат, но не его достижимость в resolver

БЛОКИРУЕТ: contracts/226-arch-door-profile-key.md инвариант 1 и «Батарея и демаркация»; `verdicts/arbitration/contracts-226-impl-b1.md`, формула закрытия: отрицательный вход — rc 1, пустой stdout и предметная причина hooks.archBrief; `fixtures/workshop_project/arch_door_profile_key_226/probe.py:183-249`; `scripts/profile_resolver.sh:959-964`. Новый пакетный шов вытаскивает argv jq на единственном корректном значении `ab/cd`; на остальных входах исполняет отдельно извлечённый jq. Публичный resolver вызывается повторно только если этот изолированный jq уже расходится с оракулом (`if errors`, строка 239). Поэтому проверка адресной CR-клетки не обнаруживает, что существующий guard вообще пропустил jq в настоящем resolver. В честном контроле сама батарея печатает `GREEN grid-boundary-after-cr (1, b'false\\n', b'')`: это stdout/stderr отдельно запущенного jq, не пустой stdout и именованная причина публичной операции.

СОСТОЯНИЕ: штатная запись JSON-строки `"ab/cd\\r"` в `harness.project.json`, то есть CR — явно названная отрицательная ось арбитража и инварианта; не PATH, не TOCTOU. Источник механизма — замена уже существующей операции `has("archBrief")` в условии входа в валидацию, а не отдельный запрет значения: в одноразовом клоне на OBJECT изменить только условие

```text
.hooks | has("archBrief")
→ .hooks | has("archBrief") and ((.archBrief | type != "string") or (.archBrief | contains("\\r") | not))
```

ОБХОД: полный `bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --repo <мутированный-клон>` дал rc 0 и `KLETKI 933 KRASNYH 0 SVJAZI 0 ZHIVYH 0`. На одном и том же реальном мире `dver_brifa_203/probe.py:build` / `probe.py:install_profile` честный `bash scripts/profile_resolver.sh --repo <product>` вернул rc 1, stdout длины 0, `profile ОТКАЗ: значение вне алфавита: hooks.archBrief: ожидается false или owner/repo`; мутант вернул rc 0, stdout 2374 байта merged JSON, stderr пуст. Это не искусственное «исключение из допустимых значений»: изменён существующий guard, и нарушение — принятие явно запрещённого CR. Ограничение конечной сетки на произвольные невключённые значения здесь не применимо: сам `grid-boundary-after-cr` включён и объявлен зелёным.

Сырой вывод независимого одноразового испытания:

```text
bypass W rc 0
KLETKI 933 STABY 47 SVJAZI 63
KLETKI 933 KRASNYH 0 SVJAZI 0 ZHIVYH 0
honest rc 1 stdout length 0 stderr profile ОТКАЗ: значение вне алфавита: hooks.archBrief: ожидается false или owner/repo
mutant rc 0 stdout length 2374 stderr
```

Воспроизведение: создать одноразовый клон OBJECT; в нём заменить ровно приведённый jq guard в `scripts/profile_resolver.sh`; полный W направить на клон. Создать настоящий профиль через существующий `old.build` и `install_profile(product, 'ab/cd\\r', 'toy')` импортированного probe 226; вызвать `bash scripts/profile_resolver.sh --repo <product>` из чистого и мутированного клонов. Значение передаётся как реальный CR (Python `'ab/cd\r'`), не двумя символами обратного слеша.

ПРОИСХОЖДЕНИЕ: дельта Architect226e, новый пакетный шов вместо исполнения публичного resolver на всех клетках. КЛАСС: К-08, К-09, К-10, К-16. ЗАКРЫВАЮЩЕЕ СВОЙСТВО: различать фактическое поведение публичной операции и всех её guard/отказных каналов на предъявленных клетках, не только отдельно извлечённый jq, сохраняя честный и эквивалентный контроль. Конкретную технику реализации автор выбирает сам.

## НЕ ЗАЩИЩАЕТ

Контракт 226 не назначает adversary ловцом санкционированного отсутствия/false, TOCTOU/подмены PATH и дефектов модели. В SDACHA дельты явно назначен adversary ловцом остатка конечной сетки: ОСТАТОК: К-09 — укусил: включённая клетка `grid-boundary-after-cr`; команда и сырой вывод полного `W --repo <мутированный-клон>` приведены в Б-1. Это не свидетельство произвольной полноты сетки; оно предъявляет пропуск реального управления на уже выбранном входе.

### Воспроизводимая команда Б-1

В собственной копии с HEAD=OBJECT сохранить следующий текст в `tmp/repro.py` и выполнить `TMPDIR="$PWD/tmp/scratch" python3 "$PWD/tmp/repro.py"` (каталог scratch должен существовать). Скрипт изменяет только одноразовый клон, затем его удаляет; использует реальный строитель мира из батареи, а не собственную модель resolver.

```python
import importlib.util, os, pathlib, shutil, subprocess, tempfile
root = pathlib.Path.cwd()
env = os.environ.copy()
clone = root / 'tmp/repro-clone'
subprocess.run(['git', 'clone', '--no-hardlinks', str(root), str(clone)], check=True, env=env)
p = clone / 'scripts/profile_resolver.sh'
s = p.read_text()
old = 'if jq -e \' .hooks | has("archBrief")\' "$REPO_JSON_FD" >/dev/null; then'.replace("' .hooks", "'.hooks")
new = 'if jq -e \'.hooks | has("archBrief") and ((.archBrief | type != "string") or (.archBrief | contains("\\r") | not))\' "$REPO_JSON_FD" >/dev/null; then'
assert s.count(old) == 1
p.write_text(s.replace(old, new, 1))
w = 'fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh'
r = subprocess.run(['bash', w, '--repo', str(clone)], cwd=root, env=env, text=True, capture_output=True)
print('W rc', r.returncode)
print('\n'.join(x for x in r.stdout.splitlines() if x.startswith(('RED ', 'KLETKI '))))
spec = importlib.util.spec_from_file_location('probe226', root / 'fixtures/workshop_project/arch_door_profile_key_226/probe.py')
probe = importlib.util.module_from_spec(spec)
spec.loader.exec_module(probe)
with tempfile.TemporaryDirectory(dir=env['TMPDIR']) as td:
    product, arch, *_ = probe.old.build(pathlib.Path(td), 'product')
    probe.install_profile(product, 'ab/cd\r', 'toy')
    world_env = probe.old.env_for(product, arch)
    world_env['TMPDIR'] = env['TMPDIR']
    for label, tools in [('honest', root), ('mutant', clone)]:
        r = probe.call(['bash', tools / 'scripts/profile_resolver.sh', '--repo', product], product, world_env)
        print(label, 'rc', r.returncode, 'stdout length', len(r.stdout), 'stderr', r.stderr.decode(errors='replace').strip())
shutil.rmtree(clone)
```

## Повтор блока грамматики и новых предикатов

Полный W --repo на отдельных клонах; значения rc и именованные сырые строки (KLETKI всегда 933, если не указан отказ среды). Старые непосредственные предикатные свидетели пойманы, но Б-1 выше сохраняет класс обхода на guard:

```text
*\\z → * ?\\z: rc 1; RED bad-trailing-space; RED grid-boundary-after-sp; KRASNYH 3
^[A-Za-z0-9] → ^[A-Za-z0-9_]: rc 1; RED bad-owner-underscore; RED grid-ascii-owner-first-095; KRASNYH 2
if . == false → if . == false or . == "FALSE" or . == "False": rc 1; RED grid-false-case-01; RED grid-false-case-31; KRASNYH 2
repo first + '.': rc 1; RED bad-repo-dot; RED grid-ascii-repo-first-046; KRASNYH 2
repo first + '.-': rc 1; RED bad-repo-hyphen, bad-repo-dot; KRASNYH 4
\\z → $: rc 1; RED bad-newline, bad-trailing-lf, grid-boundary-after-lf; KRASNYH 4
owner rest + SP: rc 1; RED bad-owner-internal-space, grid-boundary-owner-sp; KRASNYH 4
length <= 1024: rc 1; RED grid-length-owner, grid-length-repo, grid-length-both; KRASNYH 3
owner rest * → +: rc 1; RED minimal-value, grid-separator-07, grid-separator-08; KRASNYH 4
repo rest * → +: rc 1; RED minimal-value, grid-separator-07, grid-separator-08; KRASNYH 4
repo rest + SP: rc 1; RED bad-repo-internal-space, grid-boundary-repo-sp; KRASNYH 6
owner first без цифр: rc 2; NOT_IMPLEMENTED: Expecting value: line 1 column 1 (char 0)
repo rest без '-': rc 2; RED backend-enabled DIAGNOSIS; RED mixed-case DIAGNOSIS; NOT_IMPLEMENTED: Expecting value: line 1 column 1 (char 0)
```

Два последних rc 2 не выдаются за пойманные стабы: проба прекращена как инфраструктурная. Область BLOCK выше — измеренное ложное зелёное, а не эта отдельная классификация. Сетевой jq-регекс production неизменён в OBJECT; независимый oracle `grammar_accepts` проверяет членство в множествах A/B посимвольно, а не копирует regex. `git diff 8d1ef6f51 OBJECT -- .../probe.py` сохраняет прежние блоки и добавляет сетку/связи; `git diff 8d1ef6f51 OBJECT -- scripts/` пуст.

Честный W --repo .: rc 0, `KLETKI 933 KRASNYH 0 SVJAZI 0 ZHIVYH 0`, 79.9 с. Эквивалентная запись `(test(...) == true)` в одноразовом клоне: rc 0, те же 933/0. W --catalog: rc 0, `KLETKI 933 STABY 47 SVJAZI 63`; axis type 9, false 34, separator 11, ascii 768, boundary 20, unicode 17, length 3. W --sintaksis с shellcheck 0.11.0: rc 0, `SINTAKSIS 54 SHELLCHECK_DIFFERENTIAL 6 BASELINE_DIAGNOSTICS 30`.

Отказные контроли: `W --repo <пустой-каталог> --cell literal-free` rc 2 `NOT_IMPLEMENTED: EMPTY_STATIC_SAMPLE`; `VALIDATE_STD_SHELLCHECK=<несуществующий> W --sintaksis` rc 2 `VALIDATOR_MISSING: shellcheck`; замена resolver на `exit 127`, `W --repo <клон> --cell other-enabled` rc 1 `RED other-enabled DIAGNOSIS`, `KLETKI 1 KRASNYH 1`.

CI: строка `check:arch-door-profile-key-226-family-selftest`, вес 240, содержит --repo/--model/--stabs/--catalog/--sintaksis и curl shellcheck v0.11.0; registry/ci-zamery.tsv сообщает 150; `bash scripts/gen_ci_steps.sh --check` rc 0. Наблюдаемый 79.9 с замер относится только к --repo, не к совокупности всей CI-цепочки.

## Проверки чистого OBJECT и граница окружения

Клон на точном `3e82f3cf7d6cb16a8d886804477f766e7518ab29`, последовательно, shellcheck 0.11.0:

```text
W --model       rc 0  KLETKI 933 KRASNYH 0 SVJAZI 0 ZHIVYH 0
W --stabs       rc 0  KLETKI 933 KRASNYH 0 SVJAZI 63 ZHIVYH 0
187 --repo .    rc 0  CELLS=111 STABS=0 FAILURES=0
186 pin --repo  rc 0  pin_merged, lock_missing, pin_missing, pin_wrong, pin_arch_head ok
203 --repo .    rc 0  CELLS=21 STABS=0 FAILURES=0 ZHIVYH=0
201 --repo .    rc 0  CELLS=62 STABS=0 FAILURES=0
193 --repo .    rc 0  KLETKI=152 ZELENYE=152 KRASNYE=0
224 --repo .    rc 0  KLETKI 100 KRASNYH 0
check_sdacha    rc 1  ОТКАЗ: строка 21: фактический rc=1 ≠ заявленного 0: fixtures/workshop_project/arch_door_profile_key_226/context.py
pre_critic      rc 1  ОТКАЗ: сдаточный лист красен (rc=1): ОТКАЗ: строка 21: фактический rc=1 ≠ заявленного 0: fixtures/workshop_project/arch_door_profile_key_226/context.py
```

Прежний отказ формы на строке 92 исчез: обе команды дошли до исполняемого census. Причина нынешнего отказа установлена отдельным диагностическим вызовом context.py: `FROZEN 203 BLOBS 202 OVERLAPS 124 MISSING 1`, `MISSING implementer scripts/done_contract.sh 223`. Тег `frozen/contracts/223/1` указывает на `59719f4043d2eb6a11d9151bb65b98251669acc4`, commit dated 2026-11-26 10:32:20 +0000, не предок OBJECT (проверка merge-base rc 1); OBJECT dated 06:42. Это последующий live frozen census, не повтор прежней ошибки формы и не показанное нарушение узкой дельты; обе обязательные команды на текущем полном наборе тегов не зелёные, подмены/удаления тега не было. Это наблюдение окружения для оркестратора, не отдельный блок о candidate. Живой cutover backend этим судом не подтверждается.

СОВЕТ из вызова 1: прежнее достижение ветви freeze/done с отсутствующим профилем и lock показывало более поздний отказ вместо `ARCH_PROFILE_MISSING`, но не успешный freeze/done и не обход на честной неизменной production; make_task перед scope уже проверяет resolver. Честной достижимой поломки от этих трёх мутаций этот повтор не утверждает. Их воспроизведение W и коды — ниже.

## Повтор исторических мутаций поведения

Тот же полный W --repo, по одной мутации на отдельный клон:

```text
ошибка resolver → return 0: rc 1; RED bad-door, missing-layer-door, malformed-profile-door, malformed-layer-door, layer-door; KRASNYH 5
profile_get default false → X/Y: rc 1; RED other-absent, backend-absent, pin-absent; KRASNYH 3
JSON 0 приравнен false: rc 1; RED bad-zero, grid-type-zero; KRASNYH 2
JSON null приравнен false: rc 1; RED bad-null, bad-door, bad-freeze, bad-done, grid-type-null; KRASNYH 5
defaults guard выключен: rc 1; RED layer-cannot-enable, layer-conflict, layer-false, layer-door, layer-freeze, layer-done; KRASNYH 6
PRODUCT_REPO env первичен: rc 1; RED pin-env PRODUCT_REPO_DEPENDENCY; KRASNYH 1
make_task: _scope_rc -le 1 → -le 2: rc 0; KLETKI 933 KRASNYH 0
freeze_contract: то же отдельно: rc 0; KLETKI 933 KRASNYH 0
done_contract: то же отдельно: rc 0; KLETKI 933 KRASNYH 0
```

Положительный исход последних трёх мутантов не объявляется сам по себе блоком: предыдущий суд показал достижение ошибочной ветви в freeze/done, но не показал успешного обхода или вредного эффекта на честной production; production не менялась. См. совет выше. Это не подменяет найденный Б-1: в нём дополнительно наблюдён настоящий публичный resolver на одном и том же профиле.
