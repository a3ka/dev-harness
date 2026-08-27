FAIL

БЛОКИРУЕТ contracts/014-default-skratch-vne-dereva-pri-tmpdir.md:66 — объявленное расширение зоны записано как `contracts/013-*.md`, но единая грамматика `path_prefix_valid` запрещает `* ? [` (`scripts/lib_roles.sh:35-44`). Поэтому механизм не принимает новую зону и не покрывает ею два коммита 013 в диапазоне 014.
ОБХОД: при нынешнем блобе 8f7080b вердикт `accept` позволил бы создать тег v2, потому что барьер заморозки читает первую строку вердикта, но пробный `check_zones.sh` затем отвергает токен и оставляет `a84a93c7` и `bae6698b` вне зоны 014. То есть строка расширения и тег существуют, а машинной границы, ради которой сделана v2, нет.

Выход: заменить только `contracts/013-*.md` точным именем `contracts/013-processnye-artefakty-i-schet-krugov.md`; это имя не содержит запрещённых шаблонных символов и совпадает с обоими диагностированными путями вне зоны.

## Замеры

1. `git diff --no-ext-diff --unified=5 frozen/contracts/014/1 HEAD -- contracts/014-default-skratch-vne-dereva-pri-tmpdir.md` → rc=0: `1 file changed, 2 insertions(+), 1 deletion(-)`. Дифф содержит только добавление `contracts/013-*.md` в строку 66 и примечание v2 в строке 67; иных изменений против v1-блоба нет.
2. `path_prefix_valid` в `scripts/lib_roles.sh:35-44` дословно задаёт «без шаблонных `* ? [`» и веткой `*\**|*\?*|*\[*` возвращает 1. Прецедент `verdicts/arbitration/contract-010.md:41-44` требует для той же причины заменить `contracts/010-*.md` точным именем файла.
3. `bash scripts/check_charter.sh .` на HEAD `bae6698b` → rc=0. Релевантные строки: `ok   уставной документ изменён с разрешения владельца: contracts/014-default-skratch-vne-dereva-pri-tmpdir.md в 8f7080b4`; `уставных документов: 16 · изменений в них: 43 · с разрешения: 43`.
4. В чистом клоне поставлены пробные теги `frozen/contracts/014/2` → `8f7080b` и `frozen/contracts/013/3` → `bae6698`; `bash scripts/check_zones.sh .` → rc=1, не требуемый rc=0. Диагностика дословно:

   - `FAIL строка ЗОНА вне объявленной грамматики в contracts/014-default-skratch-vne-dereva-pri-tmpdir.md: путь «contracts/013-*.md» у автора «architect» — путь обязан быть относительным, без шаблонов, .. и пробелов; каталог завершается /`
   - `FAIL коммит вне зоны: architect a84a93c7 contracts/013-processnye-artefakty-i-schet-krugov.md — зона контракта 014: contracts/014-default-skratch-vne-dereva-pri-tmpdir.md fixtures/verify_antiplacebo/ NABLIUDENIA_ARCHITECT.md`
   - `FAIL коммит вне зоны: architect bae6698b contracts/013-processnye-artefakty-i-schet-krugov.md — зона контракта 014: contracts/014-default-skratch-vne-dereva-pri-tmpdir.md fixtures/verify_antiplacebo/ NABLIUDENIA_ARCHITECT.md`
   - `замороженных контрактов: 13 · объявленных авторов: 6 · коммитов в диапазонах: 288 · проверено по зонам: 201`

Серия 014 в диапазоне 013 выведена через `СПАСЕНО` (`8f7080b4` напечатан как спасённый); обратное покрытие двух коммитов 013 зоной 014 не состоялось именно из-за недопустимого шаблона.
