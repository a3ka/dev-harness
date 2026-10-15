ПРЕДМЕТ: n287-force-move-frozen-103-104 (forks/n287-force-move-frozen-103-104.md — запись заявлена оркестратором, на момент вердикта ОТСУТСТВУЕТ в origin/main@568684dc; вопрос реконструирован дословно из HANDOFF 568684dc и Н-287 NABLIUDENIA.md)
МОДЕЛЬ: zai/glm-5.3
ВОПРОС: Н-287: v2-перефриз НЕ чинит check_charter — since жёстко берётся от /1-тега; нужен ли force-move тега frozen/contracts/{103,104}/1, и на какой sha его ставить?
РЕКОМЕНДАЦИЯ: вариант — force-move аннотированных тегов на первый коммит РЕАЛЬНОЙ architect-ветки, несущий замороженный blob; альтернативы (re-freeze v2 на ветке-потомке; правка check_charter.sh на «последнюю версию тега») не работают/не нужны: v2-тег не меняет since (жёстко `/1` в scripts/check_charter.sh:449–450), а правка барьера меняет норму ради одного случая. Команды, готовые на подпись владельца (НЕ исполнять консультантом):

    git tag -f -a frozen/contracts/103/1 9af4dcd8ed2a3c7c97339cd52ab442e9c5807dbb -m "force-move Н-287: тег с параллельной реконструкции (ce5b310d, без ancestry с wip/103/architect) на первый коммит реальной ветки с замороженным blob 429c079d; текст контракта байт-в-байт, проверено consultant n287-force-move-frozen-103-104-v1"
    git tag -f -a frozen/contracts/104/1 c1f136ecc41f456ed7a596edc7aa6044d84d483b -m "force-move Н-287: тег с параллельной реконструкции (73a85203, без ancestry с wip/104/architect) на первый коммит реальной ветки с замороженным blob e4b1e185; текст контракта байт-в-байт, проверено consultant n287-force-move-frozen-103-104-v1"

Обоснование выбора sha (живой прогон в моём клоне):
- `git merge-base --is-ancestor frozen/contracts/103/1 origin/wip/103/architect` → rc=1 (и обратное направление rc=1): тег и ветка НЕ связаны ancestry; merge-base = 5d42b859 (общий main), т.е. тег стоит на параллельной реконструкции — заявление записи подтверждено.
- 103: blob контракта на теге = на tip ветки = 429c079daddf0dd53b3332ca285ff16ef7875896 (байт-в-байт). Первый коммит реальной ветки с этим blob — 9af4dcd8 (73865632 несёт черновой eb95a603). Окно после force-move: `git rev-list 9af4dcd8..origin/wip/103/architect -- contracts/103-*.md` = 0 коммитов — краснота уходит.
- 104: blob на теге = на tip ветки = e4b1e185fec0f6bf2f7d6e9a2fb80f0f9f457a93. Первый коммит реальной ветки с этим blob — c1f136ecc. Окно после force-move: `git rev-list c1f136ecc..origin/wip/104/architect -- contracts/104-*.md` = 0 коммитов.
- `git merge-base --is-ancestor 9af4dcd8 origin/wip/103/architect` → rc=0; `git merge-base --is-ancestor c1f136ecc origin/wip/104/architect` → rc=0 — оба кандидата предки своих веток, `since..HEAD` на PR-ветках становится корректным окном.
- До force-move окно `git rev-list frozen/contracts/103/1..origin/wip/103/architect -- contracts/103-*.md` = 2 коммита (9af4dcd8, 73865632), оба без строки РАЗРЕШИЛ-ВЛАДЕЛЕЦ → check_charter красит «уставной документ изменён без разрешения владельца» (Н-287 цитирует живой CI: `FAIL уставной документ изменён без разрешения владельца: contracts/103-profilnye-puti-vmesto-harness-layout.md в 9af4dcd8`).
- Замечание: теги frozen/contracts/{103,104}/2 на origin/main ОТСУТСТВУЕТ (git tag -l) — v2-перефриз из чекпойнта Н-287 не виден в refs origin; «v2 не чинит» остаётся верным тем более (since и так жёстко /1).

ОСНОВАНИЕ-ДЕРЕВО:
КОМАНДА: git rev-parse frozen/contracts/103/1
RC: 0
ВЫВОД-SHA256: a38e7e0f8287f6872f11631d3cf06321a617eae8a21a630cb5dde6bb8e28e190
КОМАНДА: git rev-parse origin/wip/103/architect
RC: 0
ВЫВОД-SHA256: 052f6e26c8972205fa1bfce488c7959a8e9235a96de965ca75f4270cb54188ef
КОМАНДА: git rev-parse frozen/contracts/103/1:contracts/103-profilnye-puti-vmesto-harness-layout.md origin/wip/103/architect:contracts/103-profilnye-puti-vmesto-harness-layout.md
RC: 0
ВЫВОД-SHA256: 8c796bc920c59d521f23ac9ac68a11a5c1858d9008f164f88d56e7f1341f2ee8
КОМАНДА: git rev-parse frozen/contracts/104/1:contracts/104-uzkij-doverennyj-gejt-sudi.md origin/wip/104/architect:contracts/104-uzkij-doverennyj-gejt-sudi.md
RC: 0
ВЫВОД-SHA256: 8b57b67b2e309660603f25b87a03c416a336dbff6ef1cf67078f283a8630014a
КОМАНДА: git log -n 2 --format=%h-%s origin/wip/103/architect -- contracts/103-profilnye-puti-vmesto-harness-layout.md
ВЫВОД-SHA256: 8dccf4f5447f07817b1740ac46dc0c4ef93a6bdcf72718fd69d21c9747988f08
КОМАНДА: git log -n 3 --format=%h-%s origin/main
RC: 0
ВЫВОД-SHA256: f08e540da231222a37e30e5b88dbe951d3d62d8e4e7fa3c10a6431dcac1e9f03
