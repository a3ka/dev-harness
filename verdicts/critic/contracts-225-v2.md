FAIL
OBJECT=c11a5b323883547ea1140b42195b3e22d340c20c
СУД: repo=dev-harness; предмет=225; фаза=контракт; роль=critic; вызов=2/2 (исправительный; дельта Architect225b); модель-план=openai-codex/gpt-6.1-terra; сессия=Crit225b; модель-факт=openai-codex/gpt-6.1-terra; автор Architect225b=openai-codex/gpt-6.1-sol; SHA=c11a5b323883547ea1140b42195b3e22d340c20c; предыдущий=archive/225/critic-v1-fail-c71f93117a; исключение=нет.

`models_actual.sh --tsv --bind --session Crit225b` и `--session Architect225b` rc 0: разные сессии, фактические модели и роли соответствуют указанным. Задание на этот OBJECT сообщает санкцию R-0085 п.2; окончательная сверка записи HANDOFF с трассой — оркестратору. Основание scoped-поиска: ремонт Б-2 утверждает сохранение всего ENV-интерфейса 196 и меняет чтение всех трёх переменных; проверены также соседние непустые значения. Проверка каталога прежних атак прямо требуется нормой 192. Остальные поверхности повторно полностью не исследовались.

## Блоки

БЛОКИРУЕТ contracts/225-ci-clean-vremennye-katalogi.md:36,50 — класс сохранения ENV-интерфейса 196 закрыт только на пустой строке; честная модель противоречит существующему поведению на соседнем доступном входе.
ПРОИСХОЖДЕНИЕ: узкое-закрытие
КЛАСС: К-03
ОБЯЗАТЕЛЬСТВО: сохранить грамматику, stdout и ENV-поведение 196, за исключением явно изменённого источника умолчаний; модель должна быть честным контролем.
СОСТОЯНИЕ: публичный вызов с `CI_ARTIFACTS_REPOS=' '` (один пробел), корректным сроком `4` и существующим игрушечным ROOT. Значение непустое: bash использует его, а не default. Это поддерживаемый ENV-шов, а не специально внесённая мутация.
НАБЛЮДЕНИЕ: исходный cleaner 196 возвращает rc 0 и пустые stdout/stderr, поскольку цикл `for r in $REPOS_ENV` не выполняется и пустая строка `REPOS` не совпадает с case `' '`. Модель 225 после `.split()` отказывает с rc 1 `ОТКАЗ: список репо пуст`. `--model` и `--delta` при этом зелёные; последний не включает этот соседний вход. Проверяемое закрывающее свойство: совпадение 196 по rc, stdout/stderr и эффекту для непустых ENV в области обещанной совместимости, включая whitespace-only REPOS, с различающей проверкой на настоящем исходнике 196. Менять frozen-поведение или сужать обязательство без полномочного решения нельзя.

АРБИТР: повтор класса Б-2 о сохранении ENV 196; вопрос — как закрыть совместимость непустого whitespace-only REPOS без изменения frozen-обязательства. Второй FAIL по той же причине; созывается арбитр, а не автоматический дополнительный круг.

БЛОКИРУЕТ contracts/225-ci-clean-vremennye-katalogi.md:51 — отсутствуют обязательные адресные стабы мутаций из предыдущего вердикта.
ПРОИСХОЖДЕНИЕ: узкое-закрытие
КЛАСС: К-01
ОБЯЗАТЕЛЬСТВО: roles/critic.md, §Связка с автором (контракт 192): каждая мутация критика из вердикта после исправления становится адресным стабом батареи и проверяется `--stabs`.
СОСТОЯНИЕ: вердикт v1 документирует четыре реально исполненные мутации: игнорирование young-проверки, пропуск worker только второго юнита, постановка `thaw=True` только после успешного freeze, хардкод срока в один день. Дифф семейства и каталог `stabs/` OBJECT проверены; точных мутаций нет. Близкие s05 игнорирует ВСЕ worker, s07 отключает ВСЕ thaw, s01 задаёт ДВА дня; это не четыре адресных предъявления из вердикта. В частности поиск `if False and entry.lstat`, `unit != 'toy-b.service'`, `time.time() - 86400` и шаблона `ctl(conf, 'freeze', unit)` непосредственно перед `thaw = True` по каталогу стабов не дал совпадений.
НАБЛЮДЕНИЕ: `--stabs` rc 0, `STABY=48 SVJAZI=68 ZHIVYH=0`, но этих четырёх обязательных адресных предъявлений не исполняет. Свойство закрытия: все четыре мутации из v1 присутствуют как отдельные адресные стабы с собственными связями и действительно краснеют; изменения модели/каталога учитывают её нынешний код. Н-39 соблюдается: привязки по коду делает architect, а не контрактная проза.

## Проверки закрытия и последствия дельты

В чистом origin-only клоне OBJECT, TMPDIR внутри собственной копии, без обращения к живым `/var/lib` и systemd. `git diff b3149e026 c11a5b323 -- fixtures/workshop_project/ci_clean_225/probe.py`: прежние тела клеток не удалены, добавлены `uncertainty_case`, `env_case`, перечни и диспетчер; изменение syntax добавляет все shims. Риск повышен обоснованно: root-удаление данных живого раннера при неполном обзоре cgroup; после реализации порядок судов adversary → reviewer.

Б-1: дословный `cgroup_case.py` из v1 запущен в том же `World` с chmod 0. Сырой вывод:
```
rc= 1 old_exists= True
stdout: ci-tmp: toy-b.service: удалено 0, хранится 0
stderr: ОТКАЗ: RUNNER_STATE_UNAVAILABLE [Errno 13] Permission denied: '/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/te1d83e4a2/m/tmp/scratch-crit225b/ci225-b4p2oz51/cgroup/toy-a.service/child.scope'
```
`--delta` дополнительно наблюдает freeze→thaw, frozen 0 и обработку соседа. Соседние самостоятельные швы: `scandir` EMFILE и ENOENT, `stat` EACCES, вложенный symlink и `io.open` EACCES для cgroup.procs дают rc 1, старое дерево сохранено, сосед очищен, thaw вызван. Первый вариант шва `builtins.open` не перехватывал `pathlib`, а первоначальный вариант `io.open` мешал pipe-дескрипторам subprocess; они не засчитываются как доказательство. Исправленный шов:
```
procs-denied rc= 1 old= True neighbor= False thaw= True stderr= "ОТКАЗ: RUNNER_STATE_UNAVAILABLE [Errno 13] injected: PosixPath('/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/te1d83e4a2/m/tmp/scratch-crit225b/ci225-xm2o872p/cgroup/toy-a.service/child.scope/cgroup.procs')\n"
```
Собственная соседняя мутация в одноразовом overlay: существующий `except OSError as exc: unavailable(exc)` в `worker_present` заменён на `except OSError as exc: return True`, то есть неопределённость маскируется под обычный BUSY вместо rc 1. Исполнены адресные `m.cell(m.MODEL, overlay, name)`; команда драйвера `TMPDIR="$PWD/../scratch-crit225b" PYTHONDONTWRITEBYTECODE=1 python3 "$TMPDIR/mutation.py"`, rc 0, сырой вывод:
```
cgroup-procs-unreadable green= False reason= 'UNCERTAINTY_RC 0: '
proc-comm-unreadable green= False reason= 'UNCERTAINTY_RC 0: '
cgroup-stat-error green= False reason= 'UNCERTAINTY_RC 0: '
```
Для данного класса отказа Б-1 закрыт; честные busy/idle проходят модель.

Б-2: дословный `env_case.py` из v1 дал:
```
old rc= 0 stdout= '' stderr= ''
model rc= 0 stdout= '' stderr= ''
```
Пустые три шва и их комбинация проверены также `--delta`. Проверка соседних значений `' '`, `'0'`, `'-1'` каждого ENV по отдельности через публичные bash-входы выявила только расхождение, приведённое в блоке. Воспроизведение блока (запуск из корня клона, `TMPDIR` — каталог внутри своей копии; `World` создаёт и удаляет только игрушечные пути):
```python
import importlib.util, pathlib
p=pathlib.Path('fixtures/workshop_project/ci_clean_225/probe.py').resolve()
s=importlib.util.spec_from_file_location('p225',p); m=importlib.util.module_from_spec(s); s.loader.exec_module(m)
with m.World(m.MODEL) as w:
    w.cfg['artifacts']['repos']=['Repo-A']; w.save()
    env=dict(w.env, CI_ARTIFACTS_ROOT=str(w.root/'artifacts'), CI_ARTIFACTS_REPOS=' ', CI_ARTIFACTS_RETENTION_DAYS='4')
    old=m.run(['bash',str(pathlib.Path('ops/server/root/ci-artifacts-clean').resolve())],env)
    new=m.run(['bash',str(w.runtime/'ci-artifacts-clean')],env)
    print('old',old.returncode,repr(old.stdout),repr(old.stderr),'new',new.returncode,repr(new.stdout),repr(new.stderr))
```
Сырой вывод более широкого прогона `TMPDIR="$PWD/../scratch-crit225b" PYTHONDONTWRITEBYTECODE=1 python3 "$TMPDIR/env_neighbors.py"`, rc 0:
```
CI_ARTIFACTS_RETENTION_DAYS ' ' old 1 '' 'ОТКАЗ: срок не целое ≥1:  \n' new 1 '' 'ОТКАЗ: срок не целое ≥1:  \n'
CI_ARTIFACTS_RETENTION_DAYS '0' old 1 '' 'ОТКАЗ: срок не целое ≥1: 0\n' new 1 '' 'ОТКАЗ: срок не целое ≥1: 0\n'
CI_ARTIFACTS_RETENTION_DAYS '-1' old 1 '' 'ОТКАЗ: срок не целое ≥1: -1\n' new 1 '' 'ОТКАЗ: срок не целое ≥1: -1\n'
CI_ARTIFACTS_ROOT ' ' old 1 '' 'ОТКАЗ: корень не каталог:  \n' new 1 '' 'ОТКАЗ: корень не каталог:  \n'
CI_ARTIFACTS_ROOT '0' old 1 '' 'ОТКАЗ: корень не каталог: 0\n' new 1 '' 'ОТКАЗ: корень не каталог: 0\n'
CI_ARTIFACTS_ROOT '-1' old 1 '' 'ОТКАЗ: корень не каталог: -1\n' new 1 '' 'ОТКАЗ: корень не каталог: -1\n'
CI_ARTIFACTS_REPOS ' ' old 0 '' '' new 1 '' 'ОТКАЗ: список репо пуст\n'
CI_ARTIFACTS_REPOS '0' old 0 '' '' new 0 '' ''
CI_ARTIFACTS_REPOS '-1' old 1 '' 'ОТКАЗ: недопустимое имя репо: -1\n' new 1 '' 'ОТКАЗ: недопустимое имя репо: -1\n'
```

## Прогоны

Команды из `fixtures/workshop_project/ci_clean_225/SDACHA.md`, исполненные в origin-only клоне с `VALIDATE_STD_SHELLCHECK` на установленный пин, TMPDIR внутри копии:
```
check_sdacha.sh "$PWD" contracts/225-ci-clean-vremennye-katalogi.md --run: rc 0
СДАЧА: лист зелёный (двери=16 карта=17/17 дельта=3)
pre_critic.sh contracts/225-ci-clean-vremennye-katalogi.md: rc 0
КРИТИК: дверь зелёная
check_precision_gate.sh "$PWD" contracts/225-ci-clean-vremennye-katalogi.md: rc 0
OK
225 --repo .: rc 1
ИТОГ 225: KLETKI=104 KRASNYH=104
225 --model: rc 0
ИТОГ 225: KLETKI=104 KRASNYH=0
225 --delta: rc 0
ИТОГ 225: KLETKI=15 KRASNYH=0
225 --stabs: rc 0
STABY=48 SVJAZI=68 ZHIVYH=0
225 --sintaksis: rc 0
SINTAKSIS=53 JSON_SCHEMA=0
225 --catalog: rc 0
KLETKI=104 STABY=48 SVJAZI=68 NOSITELI=62
196 --repo .: rc 0
ИТОГ 196: rc=0 KLETKI=25 ZELENYE=25 KRASNYE=0
196 --model: rc 0
ИТОГ 196: rc=0 KLETKI=25 ZELENYE=25 KRASNYE=0
196 --stabs: rc 0
ИТОГ 196: rc=0 OBMANOK=34 POIMANY=34 ZHIVYH=0
```
Красные 225 — неготовые новые production/config/unit/install поверхности: `CONFIG_ABSENT`, `UNIT_ABSENT`, `SUBJECT_ABSENT`, отсутствующая ветвь установки и связанные ожидания, не отказ среды. После freeze implementer должен реализовать указанный инвентарь и сохранить 196/074, а не ослабить батарею. `uptime` до прогонов: `load average: 17.89, 18.51, 18.66`.

## Карта классов

К-01: блок — не перенесены четыре адресные мутации v1
К-02: без изменений с вызова 1
К-03: блок — непустой whitespace REPOS расходится с 196
К-04: без изменений с вызова 1
К-05: без изменений с вызова 1
К-06: без изменений с вызова 1
К-07: без изменений с вызова 1
К-08: чисто — исходная ошибка cgroup и соседняя мутация дают отказ и thaw
К-09: блок — непустой whitespace REPOS не проверяется дельтой
К-10: без изменений с вызова 1
К-11: без изменений с вызова 1
К-12: без изменений с вызова 1
К-13: без изменений с вызова 1
К-14: чисто — --model rc 0 и честные busy/idle и empty ENV проходят
К-15: чисто — catalog 104/48/68/62 и прямые прогоны выше
К-16: чисто — рисковый класс root-удаления обоснован
К-17: без изменений с вызова 1

## НЕ ЗАЩИЩАЕТ

Остатки контракта: враждебный root/конкурентная смена FS и cgroup, SIGKILL между freeze и thaw, отличия реального systemd от игрушки. Ловцы — reviewer production-diff, операторское восстановление и обязательная живая приёмка до done; это не исключает обещанную обработку ошибок чтения.

## Советы

СОВЕТ contracts/225-ci-clean-vremennye-katalogi.md:56 — прежний совет о заранее воспроизводимой операторской процедуре сохраняется; живая проверка остаётся за оператором.
