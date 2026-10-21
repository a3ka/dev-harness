FAIL

Найден именованный обход батареи P (блокер проверки, не реализации): `probe.py` строит все входы в каталоге с жёстким префиксом `/tmp/sverka123-*`. Обманный субъект `.adversary_path_bypass.py` делегировал настоящий `scripts/sverka_maketa.py` только при этом префиксе, а на любом другом пути печатал синтаксически корректные строки `KADR` со score `1.000` и rc 0. Прогон

`PYTHONDONTWRITEBYTECODE=1 python3 fixtures/workshop_project/mob_sverka_123/probe.py --subject .adversary_path_bypass.py`

дал rc=0 и все 29 `CASE ... ok`: проверка объявила некорректную реализацию годной. Тот же документированный плохой вход `first-run-58d`, созданный вне этого пути (`/tmp/adversary-123-*`), дал у настоящего субъекта `real_rc=1`, `NIZHE_POROGA<TAB>First-Run dark`; у обхода — `bypass_rc=0` без этого отказа. Следовательно P не обеспечивает инвариант 6 (результат — функция байтов кадра, макета и манифеста) и не ловит путь-зависимый пропуск реальных кадров. Нужно изменить батарею так, чтобы её входные корни не были распознаваемой постоянной и этот контрсубъект стал красным.

Закрытие R123-1/R123-2 отдельно наблюдалось, но не отменяет обход проверки:
- isolated product clone на `10cf6840598981dd50c89063354fb25fab117f76`: `merge-base --is-ancestor 1423b862... HEAD` rc=0; diff — только `.github/workflows/mobile.yml` (+22). Шаг 123 расположен после шага 117 и до `Артефакты 117`, использует `.harness123` pin `2cc58c...`, `set -o pipefail` и `mobile/maestro-out-117`.
- `PYTHONDONTWRITEBYTECODE=1 python3 fixtures/workshop_project/mob_sverka_123/probe.py` — rc=0, 29/29; `--model` — rc=0, 29/29; `--matrix` — rc=0: 29 CONTROL и 32 связи 19 стабов красные.
- `PYTHONDONTWRITEBYTECODE=1 python3 /tmp/dev-harness-verify/Impl123fix/smoke.py base` — rc=0; обрезанные PNG дают `KADR_NECHITAEM<TAB>Splash dark<TAB>struct.error`, остальные кадры судятся.

Обязательные классы стабов:
- отказ-код 127: субъект `sys.exit(127)` → P rc=1, все 29 случаев красные с rc=127;
- константа, пустой вход, ответ не на тот вопрос и нейтрализация — матрица s01–s19 отвергла все 32 назначенные связи;
- без PATH: `PATH=/nonexistent /usr/bin/python3 .../probe.py` → rc=0, 29/29, поскольку субъект запускается абсолютным `sys.executable` и мера stdlib-only.

Реальный GitHub не вызывался. Временные обманные субъекты и репро удалены после прогона.
