accept
OBJECT=0d4647307f3a5a34ce493ba0019f6be6e95db147

Круг 3, только дельта a294171fb..b726bae8d. Нового наблюдаемого обхода или ложного красного не найдено. Б-2 и Б-3 закрыты по существу; frozen-контракт и pin_120.json в рассматриваемой дельте не менялись (git diff --quiet: rc=0).

Позитивные и анти-плацебо контроли:
- живой оракул на OBJECT: rc=0, `MOBILITY120_OK processes=5 new_operations=7 errors=15 nodes=20 pin=real`;
- `--model`: rc=0, 52 клетки, зелёных 52, красных 0;
- `--stabs`: rc=0, строк 18, расхождений 0;
- отсутствующий `python3` через PATH: rc=2 (`нечем судить: нет python3`); отсутствующий MOBILITY120_ORACLE: rc=1, фактический rc оракула 127 не засчитан зелёным; пустой выбор клетки: rc=2.

Б-2 — локальные способы скрытия неотслеживаемого `server/src/evil.js`:
- `.git/info/exclude`: rc=1, `vne-zony (server/src/evil.js)`;
- `core.excludesFile`: rc=1, `vne-zony (server/src/evil.js)`;
- неотслеживаемый самоигнорирующий `server/src/.gitignore`: rc=1, `vne-zony (server/src/.gitignore)`;
- изменение tracked `app/config/log.js` под assume-unchanged: rc=1, `vne-zony (app/config/log.js)`;
- удаление tracked `app/config/log.js` под skip-worktree: rc=1, `vne-zony (app/config/log.js)`.
Позитивный дифференциал: `node_modules/x/a.js` под отслеживаемым `.gitignore` — rc=0.

Б-3 — два конформных по frozen И-5/И-7 мира воспроизведены в собственных одноразовых клонах и приняты новым оракулом:
- пять существующих не-deprecated операций lifecycle при пустом `KENNZEICHEN_WUNSCH.new_operations`: rc=0, `new_operations=2`, `nodes=20`;
- удалён только EXTERNAL `communications_admission` и зависимость от него: rc=0, `new_operations=7`, `nodes=19`.
Это подтверждает откат сверхконтрактных `wunsch_tipizirovany` и обратной половины `graf_vneshnie`; обходы (2) и (3) не объявлены находками согласно scoped frozen-тексту.

Sparse-клетка d52 в модели даёт предписанный rc=2; стаб, отключающий только sparse guard, ловится на ней с rc батареи 1. Дельта ограничена девятью путями `fixtures/workshop_project/mobility_spec_120/`.
