FAIL
OBJECT=b3149e02663ba454635bfe1f7bfc2546ab7f2d14
СУД: repo=dev-harness; предмет=225; фаза=контракт; роль=critic; вызов=1/2 (полный; новый предмет); модель-план=openai-codex/gpt-6.1-terra; сессия=Crit225; модель-факт=openai-codex/gpt-6.1-terra; автор Architect225=openai-codex/gpt-6.1-sol; SHA=b3149e02663ba454635bfe1f7bfc2546ab7f2d14; предыдущий=нет; исключение=нет.

Фактические модели: `bash scripts/models_actual.sh --tsv --bind --session Crit225` и аналогично `Architect225`, rc 0: соответственно `critic openai-codex/gpt-6.1-terra allowed Crit225 b3149e02663ba454635bfe1f7bfc2546ab7f2d14` и `architect openai-codex/gpt-6.1-sol allowed Architect225 -`. Разные сессии и авторы. Сверка записи HANDOFF и трейса до материализации — за оркестратором. По runtime `uptime`: `load average: 18.60, 18.73, 25.82`.

## Блоки

БЛОКИРУЕТ contracts/225-ci-clean-vremennye-katalogi.md:35,49 — честная модель удаляет данные при неполном обзоре cgroup и получает зелёный контроль.
ПРОИСХОЖДЕНИЕ: пропущен-ранее
КЛАСС: К-08
ОБЯЗАТЕЛЬСТВО: нечитаемая cgroup/proc — rc 1 без удаления этого корня, рекурсивный осмотр всех worker; `--model` — честный контроль.
СОСТОЯНИЕ: в штатном игрушечном мире `World` создаётся `w.entry()` старше срока и `w.worker(nested=True)`; у дочерней cgroup временно сняты права чтения и обхода (`chmod(0)`), остальная среда исправна. На реальной cgroup при исполнении root аналогичную неопределённость может вызвать ошибка чтения/FS; права игрушки — воспроизводимый шов, не утверждение об обычных root-правах. Это явно предусмотренный отказной сценарий контракта, не гонка и не враждебный root.
НАБЛЮДЕНИЕ: `model/root/ci-clean.py:166` использует `os.walk(group, followlinks=False)` без обработки `onerror`; ошибка перечисления дочерней cgroup подавляется, worker не найден и старая запись удаляется. До исправления `--model` уже зелёный. Свойство закрытия: любую ошибку обхода всей cgroup трактовать как неопределённость с отказом без удаления, проверить реально наблюдаемыми rc/деревом и thaw, включая недоступную вложенную группу.

БЛОКИРУЕТ contracts/225-ci-clean-vremennye-katalogi.md:14,36,49,52 — сохранение существующего ENV-интерфейса 196 не выполнено моделью, хотя оба модельных контроля зелёные.
ПРОИСХОЖДЕНИЕ: пропущен-ранее
КЛАСС: К-03
ОБЯЗАТЕЛЬСТВО: сохранить bash CLI/ENV и отказы 196, кроме прямо изменённого источника значений по умолчанию; сохранить регресс 196.
СОСТОЯНИЕ: достижимый публичный вызов cleaner с `CI_ARTIFACTS_RETENTION_DAYS=''`, явным существующим игрушечным `CI_ARTIFACTS_ROOT` и корректным `CI_ARTIFACTS_REPOS`. Старый `ops/server/root/ci-artifacts-clean:15-17` использует `${VAR:-default}`: пустая переменная означает умолчание. Модель `model/root/ci-clean.py:108` использует `os.environ.get`: пустую строку принимает за явно заданный неверный срок. Такие же отличия есть у ROOT и REPOS в строках 111 и 117.
НАБЛЮДЕНИЕ: старый cleaner rc 0, модель rc 1 `ОТКАЗ: срок не целое ≥1:`; команды зелёной батареи не различают это состояние. Свойство закрытия: сохранить поведение незаданного и пустого ENV при чтении нового конфигурационного умолчания для каждого из трёх швов, с проверкой настоящих эффектов и rc, не восстанавливая старый 14-дневный литерал.

## Воспроизведение

Все миры — в собственной копии под TMPDIR; живые `/var/lib` и systemd не затрагивались. Обе пробы запускались `TMPDIR="$PWD/tmp/scratch-crit225" python3 "$PWD/tmp/scratch-crit225/<имя>.py"` (rc команды 0). Содержимое `cgroup_case.py`:

```python
import importlib.util, pathlib
p = pathlib.Path('fixtures/workshop_project/ci_clean_225/probe.py').resolve()
spec = importlib.util.spec_from_file_location('probe225', p)
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
with m.World(m.MODEL) as w:
    old = w.entry()
    w.worker(nested=True)
    child = w.root / 'cgroup/toy-a.service/child.scope'
    child.chmod(0)
    try:
        r = w.execute()
        print('rc=', r.returncode, 'old_exists=', old.exists())
        print('stdout:', r.stdout.strip())
        print('stderr:', r.stderr.strip())
    finally:
        child.chmod(0o700)
```

Сырой результат (префикс абсолютного временного пути приведён целиком):
```
rc= 0 old_exists= False
stdout: удалено: /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t8ddae7add/m/tmp/scratch-crit225/ci225-y_og86mh/runner one/job old
ci-tmp: toy-a.service: удалено 1, хранится 0
ci-tmp: toy-b.service: удалено 0, хранится 0
stderr:
```

`env_case.py`:
```python
import importlib.util, pathlib
p=pathlib.Path('fixtures/workshop_project/ci_clean_225/probe.py').resolve()
s=importlib.util.spec_from_file_location('p225',p); m=importlib.util.module_from_spec(s); s.loader.exec_module(m)
with m.World(m.MODEL) as w:
 w.cfg['artifacts']['repos']=['Repo-A']; w.save()
 env=dict(w.env,CI_ARTIFACTS_ROOT=str(w.root/'artifacts'),CI_ARTIFACTS_REPOS='Repo-A',CI_ARTIFACTS_RETENTION_DAYS='')
 old=m.run(['bash',str(pathlib.Path('ops/server/root/ci-artifacts-clean').resolve())],env)
 new=m.run(['bash',str(w.runtime/'ci-artifacts-clean')],env)
 print('old rc=',old.returncode,'stdout=',repr(old.stdout),'stderr=',repr(old.stderr))
 print('model rc=',new.returncode,'stdout=',repr(new.stdout),'stderr=',repr(new.stderr))
```
Результат:
```
old rc= 0 stdout= '' stderr= ''
model rc= 1 stdout= '' stderr= 'ОТКАЗ: срок не целое ≥1: \n'
```

Независимые мутации в отдельном `git clone --no-hardlinks --local "$PWD" "$PWD/tmp/clone-crit225"`. По одной подменялась операция в `clone-crit225/fixtures/workshop_project/ci_clean_225/model/root/ci-clean.py`; на каждой исполнялись все `m.CASES` через `m.cell(clone_model, None, cell)` из неизменённой пробы OBJECT; затем исходный файл восстанавливался. Команда: `TMPDIR="$PWD/tmp/scratch-crit225" python3 "$PWD/tmp/scratch-crit225/mutations.py"`, rc 0; ниже rc — агрегат соответствующей мутированной батареи. Замены:
1. `if entry.lstat().st_mtime >= cutoff:` → `if False and entry.lstat().st_mtime >= cutoff:`.
2. `if worker_present(conf, group):` → `if unit != 'toy-b.service' and worker_present(conf, group):`.
3. `ctl(conf, 'freeze', unit)` → `thaw = False; ctl(...); thaw = True` (три отдельные строки, тот же вызов); ошибка freeze больше не делает thaw.
4. `cutoff = time.time() - conf['retention_days'] * 86400` → `cutoff = time.time() - 86400`.
Сырой вывод:
```
delete-young rc= 1 red= 14 cells= 89 failures= [('old-young', 'YOUNG_REMOVED'), ('second-root', 'YOUNG_REMOVED'), ('young-inside', 'OLD_LIVE_REMOVED'), ('file-names', 'YOUNG_REMOVED'), ('busy-second', 'YOUNG_REMOVED'), ('idle-process', 'YOUNG_REMOVED'), ('inactive', 'YOUNG_REMOVED'), ('tmp-retention', 'OLD_LIVE_REMOVED'), ('entry-symlink', 'YOUNG_REMOVED'), ('nested-symlink', 'YOUNG_REMOVED'), ('thaw-fail', 'YOUNG_REMOVED'), ('artifact-age', 'ARTIFACT_CONFIG_IGNORED'), ('artifact-retention', 'ARTIFACT_CONFIG_IGNORED'), ('artifact-env', 'ARTIFACT_CONFIG_IGNORED')]
ignore-workers-second rc= 1 red= 1 cells= 89 failures= [('busy-second', 'OLD_LIVE_REMOVED')]
no-thaw-on-freeze-fail rc= 1 red= 1 cells= 89 failures= [('freeze-fail', 'QUIESCENCE_OR_RELEASE_MISSING')]
retention-one-day rc= 1 red= 1 cells= 89 failures= [('tmp-retention', 'OLD_LIVE_REMOVED')]
```

## Остальные свидетельства

- `SDACHA_TIMEOUT_SEK=1200 SDACHA_BUDZHET_SEK=2400 bash scripts/check_sdacha.sh "$PWD" contracts/225-ci-clean-vremennye-katalogi.md --run` rc 0: `СДАЧА: лист зелёный (двери=15 карта=17/17 дельта=0)`. Он исполнил заявленные 15 дверей, включая model/stabs, регресс 196 и precision; это не доказывает два отсутствующих состояния выше.
- `bash scripts/pre_critic.sh contracts/225-ci-clean-vremennye-katalogi.md` rc 0: `КРИТИК: дверь зелёная`.
- `bash scripts/check_precision_gate.sh "$PWD" contracts/225-ci-clean-vremennye-katalogi.md` rc 0: `OK`.
- `bash fixtures/workshop_project/ci_clean_225/red_ci_clean_225.sh --repo .` rc 1: `ИТОГ 225: KLETKI=89 KRASNYH=89`; начало `defaults: KRASNO CONFIG_ABSENT`, `units: KRASNO UNIT_ABSENT ci-runner-tmp-clean.service`, `readme: KRASNO README_SECTION_ABSENT`, `lock-busy: KRASNO SUBJECT_ABSENT ci-runner-tmp-clean`. Основание красного — новый инвентарь отсутствует; implementer должен реализовать перечисленные production-файлы, установить общий helper/config/schema и сохранить действующие 196/074, а не переписать их отрицательные ожидания.
- `git show b3149e026 -- fixtures/workshop_project/ops_ci_artifacts_196/probe.py`: подготовлены реальные предусловия соседнего mob-tmpdir в игрушке, относительный `--repo` разрешается до смены cwd, D1/D2 не удалены. Отдельный CI-шаг после freeze — зона orchestrator, поэтому отсутствие полного check_provodka на OBJECT не объявлено дефектом.

## Карта классов

К-01: чисто — check_sdacha --run rc 0 и pre_critic rc 0
К-02: чисто — вход R-0101/R-0102 и model/ci-clean.json пути и сроки
К-03: блок — пустые ENV меняют frozen-интерфейс 196
К-04: чисто — check_precision_gate rc 0 и инвентарь ЗОНА контракта
К-05: чисто — вход приёмочные rc-команды и отдельная операторская приёмка
К-06: чисто — вход SDACHA и BadWorld rc 2
К-07: чисто — вход model bash/Python и отдельный живой контроль ядра оператором
К-08: блок — нечитаемая вложенная cgroup молча пропущена моделью
К-09: блок — отказной вход cgroup и пустые ENV не различаются батареей
К-10: чисто — вход снимки дерева и журнал freeze/thaw probe.py
К-11: чисто — вход snapshot до вызова World и внешний sentinel
К-12: чисто — вход JSON Schema и структурный INI-канон
К-13: н/п — секретов и новых CI credentials предмет не вводит
К-14: чисто — вход old/young busy/idle и четыре независимые мутации выше
К-15: чисто — --repo rc 1 KLETKI=89 KRASNYH=89 и сдаточный лист rc 0
К-16: чисто — вход обычный риск по списку оснований и явная граница root/TOCTOU
К-17: н/п — продуктовая архитектура 188 не изменяется

## НЕ ЗАЩИЩАЕТ

Контракт ограничивает произвольные конкурентные смены путей/cgroup, злонамеренный root, SIGKILL и реальные отличия systemd от шима. Ловцы — production reviewer и обязательная живая операторская приёмка. Это не исключает отдельно обещанный отказ на ошибку чтения cgroup.

## Советы

СОВЕТ contracts/225-ci-clean-vremennye-katalogi.md:56 — для живой приёмки заранее записать команды получения и проверки свидетельств long-job, idle и Persistent; операторская процедура не должна зависеть от догадки исполнителя.
