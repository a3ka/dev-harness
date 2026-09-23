reject

# Контракт 040 — adversary circle v4

Проверен `fac8fe6` против арбитража 040-II (`7c66a70`). Найден in-scope обход: Bash импортирует экспортированные функции из окружения до выполнения скрипта, а функция имеет приоритет над `$PATH`. Поэтому `export PATH=/usr/bin:/bin` не делает вызов `git` доверенным.

## Найденный обход

Toy был создан честным `/usr/bin/git` до атаки: frozen-контракт объявляет `agent-x: scripts/`; `agent-x` затем коммитит `plans/outside.md`. Далее экспортируется только Bash-функция `git`, которая делегирует в настоящий `/usr/bin/git` всё, кроме `git log --no-walk --stdin`; для batched author lookup она возвращает полный NUL-поток исходных SHA, но константный автор `not-an-announced-author`, rc=0. Записей в `/usr/bin:/bin`, root и подмены `/usr/bin/git` нет.

```bash
bash /tmp/dev-harness-verify/adversary040-function-shadow.sh
```

```text
rc=0
замороженных контрактов: 1 · объявленных авторов: 1 · коммитов в диапазонах: 1 · проверено по зонам: 0
```

Вне-зонный коммит объявленного автора исчез из суда и барьер стал зелёным. Сверка `author_map` закономерно проходит: все SHA полны и уникальны, ложно только вычисленное поле автора. Это не исключённый PATH-spy, а непривилегированное разрешение Bash-функции до PATH. `command -v git` также видит функцию; `command git` не лекарство. В результате п.1 v4 и заявленное закрытие подлинности не выполнены. Лечение должно до первого разрешения команды убрать импортированные функции для всех используемых имён (включая shell builtins пути) либо запускать доверенную часть из санитизированного окружения.

## Шесть пунктов v4: живые проверки

1. **PATH:** чистый пустой inherited PATH не создаёт ложного красного:
   ```bash
   env -i PATH=/tmp HOME="$HOME" /bin/bash scripts/check_zones.sh .
   ```
   rc=0. Однако описанная функция `git` обходит пин без запрещённых прав; пункт в целом отклонён.

2. **`--always` + `paths_raw`:**
   ```bash
   bash /tmp/dev-harness-verify/adversary040-honest-empty.sh
   # empty: headers=1 paths=0 barrier=0
   # outside: rc=1
   bash /tmp/dev-harness-verify/adversary040-paths-guard.sh
   # rc=1
   ```
   Честный `--allow-empty` получил один заголовок и ноль прежних per-commit путей без ложного красного; нейтрализация второго блока дала именованный fail-closed rc=1.

3. **`:306` fail-closed:**
   ```bash
   bash /tmp/dev-harness-verify/adversary040-rev-list-refusal.sh
   # rc=1
   # ОТКАЗ: git rev-list --no-merges --reverse отказал ...
   ```
   Пустого зелёного окна нет.

4. **Гарды кругов 1–2:**
   ```bash
   bash /tmp/dev-harness-verify/adversary040-author-guards.sh
   # refusal: rc=1
   # truncation: rc=1
   ```
   Отказ author-batch и успешное усечение до первой NUL-пары оба именованно красны.

5. **Реворк 2+1:**
   ```bash
   bash scripts/verify_antiplacebo.sh --scope check_zones
   ```
   rc=0: `барьеров: 1 · фикстур: 24 · предъявлено красным повторным прогоном: 24`.

   ```bash
   bash fixtures/check_zones/red_predel_git_vyzovov.sh
   ```
   rc=0, xtrace-счётчик живой: LOW=137, HIGH=137.

6. **Остаточный риск:** шапка `check_zones.sh` действительно называет `/usr/bin/git`, root/скомпрометированный пакет, неподписанные коммиты и signed-commit эскалацию. Но она не называет и не закрывает непривилегированную функцию, которая разрешается раньше PATH.

## Решение по изменению `red_predel_git_vyzovov.sh`

**Принимаю отклонение от буквального «не трогать».** После обязательного PATH-пина старый `run_spycount` через PATH-spy неизбежно видел бы 0 вызовов и стал бы молчаливым плацебо. Узкий переход к `run_trace` с `SHELLOPTS=xtrace BASH_XTRACEFD=9` измеряет реально исполняемые `git`-команды независимо от последующего изменения PATH; это уже применённый паттерн `fixtures/check_protected/red_predel_git_vyzovov_ours.sh:106-114`. Живой запуск дал 137/137. Оставить старый счётчик и лишь объявить его слепым было бы хуже: постоянная регресс-фикстура проходила бы с нулевым наблюдением. Это обоснованное исключение, но оно не меняет общего reject по независимому обходу.

## Обязательная приёмка

```bash
timeout 60 bash scripts/check_zones.sh .
```

rc=0; итог: `замороженных контрактов: 40 · объявленных авторов: 5 · коммитов в диапазонах: 1762 · проверено по зонам: 1178`.
