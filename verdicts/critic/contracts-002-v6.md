FAIL

БЛОКИРУЕТ contracts/002-approval-mode-steward.md:68 — контракт относит собственный файл к зоне `architect`, но исправляющий HEAD `858c045576c7531be16f9d6a80afb3d3dd503b13` имеет `%an = critic` и меняет именно этот контракт. `critic` не назван исполнителем и по границе роли контракт не правит. Успешный `check_zones.sh` этого не опровергает: механизм проверяет только авторов, перечисленных в `ЗОНА`-строках, и молча пропускает коммит неизвестного автора. Поэтому на HEAD не выполнено объявление «кто в каких границах исполняет», хотя названные команды зелёные.
ОБХОД: сохранить `%an = critic`, поставить `frozen/contracts/002/6` на этот HEAD и выполнить оба барьера. `check_charter.sh` и `check_zones.sh` завершаются с кодом 0, но запрещённая роль остаётся автором правки файла, отданного `architect`.

Это не повтор причины круга 1: путь `plans/008-skills-metta-adaptacija.md` теперь включён в зону `architect`, и коммит `50abc250` барьер принимает; новый дефект — авторство самого исправляющего коммита.

Проверено на HEAD `858c045576c7531be16f9d6a80afb3d3dd503b13`:

- `git diff frozen/contracts/002/5..HEAD -- contracts/002-approval-mode-steward.md` — 8 вставок, 2 удаления;
- `git diff 9b70176..HEAD -- contracts/002-approval-mode-steward.md` — одна замена строки зоны: добавлен `plans/008-skills-metta-adaptacija.md`;
- `bash scripts/check_charter.sh` завершилась с кодом 0;
- на временном теге `frozen/contracts/002/6` команда `bash scripts/check_zones.sh` завершилась с кодом 0: 2 контракта, 2 объявленных автора, 37 коммитов, 26 проверок по зонам;
- временный тег `frozen/contracts/002/6` удалён;
- `git log -1` показывает автора `critic <critic@dev-harness.local>` и коммиттера `architect <architect@dev-harness.local>`.
