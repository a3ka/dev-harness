accept

Объект: 0e12b19d7fb21a8f2345030e86b8c93535957dc5.
База дельты: 9ff0cf74db64139641a363293f54451a9b66dc7d.

Сценарий A/B круга 1 воспроизведён на кандидате. В bare-цели main содержит
`contracts/130-t.md` с good text и accept-вердикт v1. Из A запущен gitw с
`-C B`; A хранит одноимённый годный тег, B — тег на коммите с bad text.
Результат: rc=1, remote_tag=no, stderr содержит именованный класс
`gitw ТЕГ-ОТКАЗ: frozen/contracts/130/1: текст не в main цели:`.

Контексты проверены в одном мире A/B, при сохранённом одноимённом годном теге
A. Для каждого из `-C B` из A, `--git-dir=B/.git` из A и запуска из B:
- тег B на коммите main с good text: rc=0, remote_tag=yes;
- тег B на коммите с bad text: rc=1, remote_tag=no и именованный отказ
  «текст не в main цели».

Батарея:
- дерево без предмета 371e0e388007ef2b136bfde82efda4fbf37855cc:
  `--model --seed 7` — rc=0, 48/48;
- то же дерево: `--stabs --seed 7` — rc=0, 29/29;
- кандидат: `--candidate /tmp/dev-harness-verify/adv130b --seed 1`, `7`,
  `42` — каждый rc=0, 48/48;
- кандидат: `--cell net-takoj --seed 7` — rc=2.

Зона: `git diff --name-status 9ff0cf74d..0e12b19d7` показал ровно
`M scripts/gitw_teg_130.sh` (24 additions, 7 deletions); frozen-пути и
`scripts/gitw` в дельте отсутствуют.

Итог scoped-круга 2: сценарий прошлого круга закрыт, контекстные формы и
приёмочная батарея сошлись.
