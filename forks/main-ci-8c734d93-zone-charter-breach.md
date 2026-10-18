ФОРК: main-ci-8c734d93-zone-charter-breach
ВОПРОС: Push-CI (push-событие, не pull_request) на `origin/main` упал гораздо
шире, чем ожидалось предыдущей сессией (не только ap2/l4/l7 — живой прогон
38256948403 на HEAD `54679aaf` дал failure на ap1/ap2/ap3/ap4/ap5/l1/l2/l3/l4/l5/l6/l7,
т.е. ВСЕ матрица-джобы). Корень — минимум ДВА отдельных пред-существующих дефекта,
оба в одном коммите `8c734d93` («freeze: registry 098 → fa42b75b...», identity
`orchestrator`, уже на main со времени 11:34 UTC этого дня, downstream на нём уже
стоят `f4dc877e`/`fac41836`/`3cfc067a`/`e250769a`/`54679aaf`):

1. **check_zones (l3) — «коммит вне зоны».** `8c734d93` авторства `orchestrator`
   трогает пути ЧУЖОЙ (architect) зоны контракта 098: `fixtures/dokazatelstva_098/
   red_pozdnij_krasnyj_progon.sh`, `red_semantika_008_bez_flaga.sh`,
   `red_smeshannaja_istorija.sh`, `red_zhurnal_vne_vetvi.sh`, плюс
   `registry/contracts.tsv` — «дверь минта 031: дельта манифеста не только-добавление
   (нет frozen-тегов для замены)». Живой вывод: `gh api repos/a3ka/dev-harness/actions/
   jobs/114837464100/logs`, строки 1265-1269.

2. **check_charter (l1) — «уставной документ изменён без разрешения».** Тот же
   `8c734d93` меняет `contracts/098-proizvodstvennye-dokazatelstva-do-publikacii.md`
   (добавлена строка КОНТЕКСТ: и переформулированы решения 2/4) без строки
   `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` в теле коммита. Живой вывод: `gh api repos/a3ka/dev-harness/
   actions/jobs/114837463802/logs`, строка 1150.

Похоже, это результат ручной материализации registry-строки «тем же способом»
(patch+apply+commit identity=orchestrator), которая должна была нести ТОЛЬКО
регистровую строку (per Урок #4 HANDOFF предыдущей сессии: «писать строку вручную ТЕМ
ЖЕ способом (patch+apply+commit, формат NNN → <tag-object-sha>, identity=orchestrator)
уже НА main ПОСЛЕ land»), но фактически перенесла ВЕСЬ диапазон содержимого
wip/098/architect (текст контракта + fixtures) одним коммитом orchestrator — то есть
по сути неавторизованный «land» мимо `land_agent.sh`/зон.

`8c734d93` уже является предком 5 последующих коммитов на main (включая вердикт
critic-097 круга 5 и HANDOFF). Переписать его означало бы rebase всей этой истории —
риск того же класса, что уже решался grandfather-записями (n263/n269/n272), но
МАСШТАБНЕЕ (check_zones.sh грандфазер-аллоулиста НЕ несёт — только check_charter.sh
его имеет). Нужен инженерный анализ: (а) возможен ли grandfather для check_zones.sh
(прецедента нет), (б) следует ли amend/rebase `8c734d93` на месте (5 потомков
сравнительно свежие, все судейские main-direct коммиты — технически возможно через
`git rebase --onto`), (в) любой третий путь.

МАРШРУТ: консультант
ЗАВЕДЁН: 2026-10-12T13:55:00Z
АВТОР: orchestrator
БЛОКИРУЕТ: нет напрямую (land_agent гейтится по PR-уровню head_sha, не по main push-CI
  — проверено живьём: `gh api .../actions/runs?event=pull_request&head_sha=<tip>` для
  097/098/093 веток даёт `conclusion: failure` ИЗ-ЗА собственных debt-джобов, НЕ из-за
  этого коммита); НО main push-CI никогда не станет зелёным, пока это не решено —
  структурный долг, растущий с каждым днём.
ОТВЕЧЕНО: да — устарел, закрыт консультантом по мандату 2026-10-18 (разбор открытых форков по просьбе владельца): grandfather (7c40cc589, owner); main CI Ð·ÐµÐ»ÑÐ½ÑÐ¹
