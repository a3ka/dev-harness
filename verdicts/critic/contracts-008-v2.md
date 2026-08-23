accept

# Вердикт критика — контракт 008 v2, зоны

Предмет проверки — закоммиченный HEAD
`f0056d14c382c5ba467ccb7655d5c3ef43016796`. Проверена только v2-правка объявления раздачи
`contracts/008-deshevye-sudejskie-krugi.md:45-50`; предмет и приёмочный критерий этого контракта
не пересматривались.

## Покрытие коммит × файл

Диапазон `frozen/contracts/008/1..HEAD` содержит семь немержевых коммитов, и все семь судимы:
шесть с автором `architect`, один с автором `implementer`. Проверены все 18 пар коммит × файл:

- `f0056d14c382c5ba467ccb7655d5c3ef43016796` (`architect`):
  `contracts/008-deshevye-sudejskie-krugi.md` — точный файл зоны architect.
- `14c3a8d0b70ae8d50d950c01bf9ea0f3cb940c62` (`architect`): `HANDOFF.md` — точный файл зоны
  architect.
- `59e2738d72c6909980f829cace265b24c97531b7` (`architect`): `HANDOFF.md` — точный файл зоны
  architect.
- `67dd3a77c5e97a0202da9972d8509d7d95b79236` (`architect`):
  `fixtures/check_check_contract_ready/case_gotov_strict.sh`,
  `fixtures/check_check_contract_ready/case_zony_lax.sh`,
  `fixtures/check_judge_gate/case_krasnyj_lax.sh`,
  `fixtures/check_judge_gate/case_zelenyj_bypass_sha.sh`,
  `scripts/check_check_contract_ready.sh`, `scripts/check_judge_gate.sh` — все шесть файлов в
  объявленных каталогах либо точных файлах зоны architect.
- `c1f86e62d30b5a0d754508457957ab54fa379935` (`implementer`):
  `.github/workflows/ci.yml`, `package.json`, `scripts/check_check_contract_ready.sh`,
  `scripts/check_contract_ready.sh`, `scripts/check_judge_gate.sh`, `scripts/judge_gate.sh` —
  коммит целиком и по точному полному хешу выведен строкой `СПАСЕНО implementer`.
- `8add1ca66449916547e833b9715898cef23c3fad` (`architect`): `HANDOFF.md`,
  `scripts/check_check_contract_ready.sh` — оба точных файла зоны architect.
- `8648f4924ef630b1a8d1a2b60bf71b7cf2612b84` (`architect`): `HANDOFF.md` — точный файл зоны
  architect.

Итого: 12 пар architect покрыты зонами; шесть пар единственного implementer-коммита покрыты
одним конечным per-commit `СПАСЕНО`. Судимых файлов вне зоны и вне `СПАСЕНО` нет.

## Грамматика и конечность

- Обе `ЗОНА`-строки (`contracts/008-deshevye-sudejskie-krugi.md:47-48`) имеют объявленных
  авторов и непустые пути. Все пути относительные, без пробелов, кавычек, шаблонов и `..`;
  каталоги оканчиваются `/`, точные файлы не оканчиваются `/`.
- `СПАСЕНО` (`contracts/008-deshevye-sudejskie-krugi.md:50`) называет автора `implementer`, уже
  объявленного своей `ЗОНА`-строкой, непустую причину и ровно один 40-символьный lowercase-hex
  `c1f86e62d30b5a0d754508457957ab54fa379935`. Коммит существует и является потомком
  `frozen/contracts/008/1` и предком HEAD; `done/contracts/008/1` отсутствует, поэтому это
  именно действующий диапазон барьера.
- Парсер `scripts/check_zones.sh:192-244` записывает в `saved` отдельную тройку
  `автор + полный хеш + номер контракта`, а проверка `scripts/check_zones.sh:311-314` исключает
  коммит только по точному совпадению этой тройки. Строка не является префиксом диапазона и не
  спасает следующий либо будущий коммит implementer.
- Имена каталогов фикстур совпадают с ключами, которые `scripts/verify_antiplacebo.sh:66-67,145`
  выводит из имён барьеров: `scripts/check_check_contract_ready.sh` →
  `fixtures/check_check_contract_ready/`, `scripts/check_judge_gate.sh` →
  `fixtures/check_judge_gate/`.

## Доказательство будущего состояния заморозки

После ручной сверки в отдельном клоне на коммит `f0056d1` локально поставлен моделирующий тег
`frozen/contracts/008/2`, затем выполнено `bash scripts/check_zones.sh`: RC=0; вывод перечислил
все 12 зон контракта 008 и отдельно подтвердил
`коммит c1f86e62 (implementer) — СПАСЕНО, из суда зон выведен`. Это не подменяет ручное покрытие
выше: моделирующий тег нужен только потому, что барьер читает объявление из блоба высшей
заморозки.

## Обходы

Обходов не найдено. Ни состояния с судимым файлом вне зоны и вне `СПАСЕНО`, ни открытого
исключения, способного молча пропустить будущий выход за зону, в объявлении v2 нет.
