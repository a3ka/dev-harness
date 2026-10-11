ФОРК: n272-fd2180af-079-grandfather
ВОПРОС: CI lane legkij (check:charter) красен на PR#65, ветка wip/087/implementer контракта
087, живьём подтверждено через gh api jobs logs эндпоинт GitHub, run 38110427036, job
114384657679:
FAIL уставной документ изменён без разрешения владельца: contracts/079-pokrytie-invariantov-083-088-krasnymi-kletkami.md
в fd2180af - тело коммита обязано нести строку РАЗРЕШИЛ-ВЛАДЕЛЕЦ:
contracts/079-pokrytie-invariantov-083-088-krasnymi-kletkami.md <причина> в первой колонке.

Коммит fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69, merge main into wip/087/implementer,
автор implementer (материализовано оркестратором git-плambингом после того, как первая
попытка 087-implementer'а зафлэттенила merge в один-родительский коммит b068c18c и НЕ
решила GitHub PR mergeable_state - живая проверка подтвердила: PR#65 оставался
CONFLICTING, 0 check-suites создавалось GitHub на push; настоящий --no-ff merge
потребовался именно для триггера CI). Родители e04e3177e2c3b9dd63afe67bdac37cfd7994d27d
и 19efb35c5573a2f9ec179039925a0689a21421b3 (origin/main на момент пуша). Живая сверка
командой git diff origin/main fd2180af -- contracts/079-pokrytie-invariantov-083-088-krasnymi-kletkami.md
даёт ПУСТОЙ diff - содержимое БАЙТОВО идентично main, merge принёс уже-санкционированный
на main текст через 3-way merge, не внёс новое.

Это ТОТ ЖЕ класс, что уже покрытые 15-я/16-я записи грандфазер-аллоулиста
scripts/check_charter.sh (строки 108-112, sync-merge main в wip/083/architect) и
ТОЛЬКО ЧТО заведённая n269-f9467024-roadmap-grandfather (092, идентичный класс на
ROADMAP.md) - третий по счёту инстанс одного и того же систематического эффекта:
check_charter.sh incr-окно красит ЛЮБОЙ sync-merge, затрагивающий charter-путь,
даже если merge лишь 3-way-переносит уже одобренное содержимое main без новых строк.

Коммит fd2180af УЖЕ является головой wip/087/implementer (единственный путь получить
зелёный PR-CI для 087 - Б-1 ревью-круга 1 требовал зелёный живой CI; без него land
087 недостижим per контракт 069 PR-маршрут). Переписать коммит означало бы заново решать
ту же git-mergeability-проблему. Единственный путь без потери истории - грандфазер-запись
для fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69 в scripts/check_charter.sh, тот же механизм,
применённый уже 25 раз (строки 99-140, включая свежую 25-ю для n269).

Дословный кандидат строки, вставляется в шапку check_charter.sh после строки 140 (после
будущей 25-й n269-записи), owner commit:

  fd2180afa3f69a2f2a3799cbafe8ea84e70e5b69  contracts/079-pokrytie-invariantov-083-088-krasnymi-kletkami.md
  26-я: sync-merge wip/087/implementer от 2026-10-11 (эта сессия) - необходим для
  устранения GitHub PR mergeable_state=CONFLICTING (0 check-suites на push, PR-CI не
  триггерился вовсе); merge принёс байтово main-идентичное contracts/079-*.md через 3-way
  merge, сам merge не менял строки вручную; грамматику razreshil() не менять, допущение -
  только для этой пары; слово владельца и дата подставляются при коммите.

КЛАСС: воля-владельца
ПРИЗНАК: риск
МАРШРУТ: батч
ЗАВЕДЁН: 2026-10-11T04:10:00Z
АВТОР: orchestrator
БЛОКИРУЕТ: да - land 087 не достижим без зелёного PR-CI (легkий lane), контракт 069
  PR-маршрут требует зелёный PR до land_agent; это ЧЕТВЁРТЫЙ owner-блокер этой ночи
  наряду с n263 (094), n266 (093 l5), n269 (092 l1) - тот же класс, что n269, кандидат
  на одно объединённое решение владельца по всем sync-merge-грандфазерам разом
ОТВЕЧЕНО: нет
