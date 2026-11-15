ФОРК: 140-merge-zona-verdikta
ВОПРОС: Кто и под какой identity может закоммитить intra-wip слияние wip/140/architect f18866ad6d в wip/140/implementer, если сливаемое дерево несёт verdicts/critic/contracts-140-v3.md (зона critic), а страж коммита (check_staged, зона по identity автора + «вне своей ветки wip/» для orchestrator) отказывает и implementer, и orchestrator?
КЛАСС: инженерный
ПРИЗНАК: отказ штатного стража коммита
МАРШРУТ: консультант
ЗАВЕДЁН: 2026-11-15T00:38:39Z
АВТОР: anthropic/claude-sonnet-5-5
БЛОКИРУЕТ: да
ОТВЕЧЕНО: нет

Факты. Impl140MergeFix (implementer-glm, zai/glm-5.3, isolated + пин) разрешил слияние: конфликт был один — scripts/zamok_predmeta.sh, выбрана сторона исполнителя (staged sha 890327ed…); fixtures/probe.py пришли от architect без конфликта. 50 staged-путей, MERGE_HEAD=f18866ad6d, HEAD=e86bab59d9, stash@{0} хранит 41 dirty-путь исполнителя (байтовая копия: /tmp/dev-harness-verify/preserve-140-impl-1115/).
Отказы:
1. identity implementer: «ОТКАЗ: вне зоны: verdicts/critic/contracts-140-v3.md» (единственный; 49 прочих путей прошли). Файл приходит из слияния байт-в-байт (коммит 1b7d4713a0 critic в ветке архитектора).
2. identity orchestrator (прецедент 187: intra-wip сведение daf3df46 коммитил orchestrator): «ОТКАЗ: вне своей ветки wip/ — автор «orchestrator» спавнен в worktree (жива wip/<NNN>/orchestrator), но коммитит в «wip/140/implementer»».
Обходы (--no-verify, дробление, чужая identity, git-plumbing) не применяются. Слияние осталось застейджено в WT wip-140-implementer; ничего не коммитилось и не публиковалось. Ответить агенту каналом agent:// ведущая сессия не может (Н-85), агент ждёт.
Варианты для консультанта: (а) назначить коммитера (identity/маршрут, проходящий оба стража); (б) расширить зону implementer на этот путь для данного merge; (в) исключить вердикт из слияния (меняет f18866ad6d как носитель — решение не моё); (г) иной маршрут сведения (напр. новая ветка поверх f18866ad6d без изменения вердиктного файла и перенос scripts/zamok_predmeta.sh отдельным коммитом implementer). Рекомендация: (г), т.к. не требует исключений стражей.
