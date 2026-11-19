FAIL

OBJECT=95235b366a5d5d62807be58a37709d1bc7a0bc3d
СУД: repo=dev-harness; предмет=197; фаза=контракт v4 до заморозки; роль=critic; вызов=один узкий по дельте (г) по слову владельца 2026-11-19 ~00:18 UTC, прежний счёт сохраняется; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit197V10; модель-факт=openai-codex/gpt-6.1-terra (models_actual --bind: allowed); SHA=95235b366a5d5d62807be58a37709d1bc7a0bc3d; предыдущий=Crit197V9 accept OBJECT 35bb27a4369c2a1845af70e34f6056f02b4f852d; исключение=слово владельца, один узкий вызов по дельте (г).

БЛОКИРУЕТ contracts/197-mob-ci-artefakty-lokalno.md:93,194 — целостность оракула проверяется лишь при достижении s01, после зависящих от субъекта ранних выходов.
ОБЯЗАТЕЛЬСТВО: отсутствие/порча снимка — rc 2 `ORACLE_TAMPERED` во всех автономных режимах; область задания также требует того же при подмене пина.
СОСТОЯНИЕ: `--repo` получает копию модели с удалённым скриптом канона — прямо заявленный негативный сценарий контракта :77; одновременно в копии семьи отсутствует снимок (существующая мутация `stab_s01_snimok_otsutstvuet`) либо подменён его sha256. `_sudit_replay` в `fixtures/workshop_project/mob_ci_artifacts_local_197/probe.py:739-741` возвращает `SKRIPT_NET` до вызова `_zhivoj_agregat_143` :915; при несуществующем субъекте ранний выход также в :987-992.
НАБЛЮДЕНИЕ: в обоих вариантах с читаемым workflow получены rc 1 и 13 красных `SKRIPT_NET`, включая s01, без `ORACLE_TAMPERED`; при отсутствующем субъекте также rc 1 `SUBJECT_ABSENT`. Зелёные 32 стаба этого сочетания не различают: новые мутации запускаются на неповреждённой модели. Источник входа — обязательный сценарий удаления скрипта и добавленные мутации снимка; причина — расположение новой проверки за существующим ранним возвратом.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: в каждом автономном режиме, включая `--repo` с отсутствующим скриптом или субъектом и дочерние запуски, независимая проверка снимка/пина предшествует предметным отказам и при его недоступности/несовпадении возвращает rc 2 `ORACLE_TAMPERED`; адресные проверки различают также это сочетание, а не только честный субъект.
ПРОИСХОЖДЕНИЕ: дельта
КЛАСС: К-06

## Проверки

Рабочий клон `/tmp/dev-harness-verify/Crit197V10/repo`. `git show` оригинала fda1fc8 и `sha256sum` снимка дали одинаковый `e486e353f319ed2c0a65fc1092a0f16f8c9d8314bab4aed6e1d3619630d8fec6`, rc 0. Diff реестра, `scripts/run_ci_lane.sh` и `.github/workflows/ci.yml` пуст. `bash scripts/run_ci_lane.sh check:mob-ci-artifacts-local-197-family-selftest` rc 0: модель 29/29, стабов 32, непойманных 0; `stab_s01_bez_pary` пойман по `s01-styk-sbor-agregat`/`STYK_AGREGATA_OTKAZ`, новые два — каждый по своей rc 2/именованной причине. Привязка по коду, не по прозе. `sverka_inventarja_143.sh до` rc 0: побайтовая сверка, 197 29/29, шесть названных красных при commit `9d3ad2bea4f1f15be15a9d975966bb20451a9a54` и tree `89ccddf8281b15842eda6aa1a316bdde579845ee`; `proverka_sverki_143.sh --ref 0d391630a037d3c3e71d0795866dddba55f1fc57` rc 0, 12/12, ноль красных после. Строка РАЗРЕШИЛ в изменяющем коммите называет контракт первым токеном и цитирует адресное слово. Предел исторических байтов и станционный baseline сохранены.

### Атаки в одноразовой копии

Команда из корня клона:

```sh
mkdir -p /tmp/dev-harness-verify/Crit197V10/attack && cp -a fixtures/workshop_project/mob_ci_artifacts_local_197 /tmp/dev-harness-verify/Crit197V10/attack/family && python3 /tmp/dev-harness-verify/Crit197V10/attack/family/stabs/stab_s01_snimok_otsutstvuet.py /tmp/dev-harness-verify/Crit197V10/attack/family && bash /tmp/dev-harness-verify/Crit197V10/attack/family/red_mob_ci_artifacts_local_197.sh --repo /tmp/dev-harness-verify/Crit197V10/attack
```

Сырой вывод, rc 1:

```text
SUBJECT_ABSENT: .github/workflows/mobile.yml не читается
CASE a01-upload-artefakt-ostalsja KRASNO: SUBJECT_ABSENT
CASE a02-download-artefakt-ostalsja KRASNO: SUBJECT_ABSENT
CASE a03-gh-kanal-v-run KRASNO: SUBJECT_ABSENT
CASE b01-forma-pisatelja KRASNO: SUBJECT_ABSENT
CASE b02-imja-pisatelja-razreshimo KRASNO: SUBJECT_ABSENT
CASE b03-pisatel-s-run-argumentom KRASNO: SUBJECT_ABSENT
CASE c01-forma-chitatelja KRASNO: SUBJECT_ABSENT
CASE c02-imja-bez-pisatelja KRASNO: SUBJECT_ABSENT
CASE c03-run-para-iz-sborki KRASNO: SUBJECT_ABSENT
CASE d01-koren-vne-skripta KRASNO: SUBJECT_ABSENT
CASE d02-vyhod-za-koren KRASNO: SUBJECT_ABSENT
CASE e01-skript-pin KRASNO: SUBJECT_ABSENT
CASE e02-linei-npm KRASNO: SUBJECT_ABSENT
CASE g01-forma-nositelja KRASNO: SUBJECT_ABSENT
CASE g02-rabochij-katalog-nositelja KRASNO: SUBJECT_ABSENT
CASE i01-nositel-ispolnim KRASNO: SUBJECT_ABSENT
CASE i02-zamknutyj-inventar KRASNO: SUBJECT_ABSENT
CASE r01-krug-zapisi-chtenija KRASNO: SUBJECT_ABSENT
CASE r02-popytka-prodjusera KRASNO: SUBJECT_ABSENT
CASE r03-imja-pobeg KRASNO: SUBJECT_ABSENT
CASE r04-imja-razdelitel KRASNO: SUBJECT_ABSENT
CASE r05-run-nechislovoj KRASNO: SUBJECT_ABSENT
CASE r06-nepolnaja-identifikacija KRASNO: SUBJECT_ABSENT
CASE r07-shablon-sbor KRASNO: SUBJECT_ABSENT
CASE r08-istochnik-otsutstvuet KRASNO: SUBJECT_ABSENT
CASE r09-izoljacija-popytok KRASNO: SUBJECT_ABSENT
CASE r10-shablon-pusto KRASNO: SUBJECT_ABSENT
CASE r11-tochnoe-imja-otsutstvuet KRASNO: SUBJECT_ABSENT
CASE s01-styk-sbor-agregat KRASNO: SUBJECT_ABSENT
клеток 29, зелёных 0, красных 29
```

Команда при уже удалённом снимке:

```sh
cp -a fixtures/workshop_project/mob_ci_artifacts_local_197/model /tmp/dev-harness-verify/Crit197V10/attack/subject && python3 -c "from pathlib import Path; Path('/tmp/dev-harness-verify/Crit197V10/attack/subject/mobile/scripts/ci-artefakty.cjs').unlink()" && bash /tmp/dev-harness-verify/Crit197V10/attack/family/red_mob_ci_artifacts_local_197.sh --repo /tmp/dev-harness-verify/Crit197V10/attack/subject
```

Сырой вывод, rc 1:

```text
CASE a01-upload-artefakt-ostalsja ok
CASE a02-download-artefakt-ostalsja ok
CASE a03-gh-kanal-v-run ok
CASE b01-forma-pisatelja ok
CASE b02-imja-pisatelja-razreshimo ok
CASE b03-pisatel-s-run-argumentom ok
CASE c01-forma-chitatelja ok
CASE c02-imja-bez-pisatelja ok
CASE c03-run-para-iz-sborki ok
CASE d01-koren-vne-skripta ok
CASE d02-vyhod-za-koren ok
CASE e01-skript-pin KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE e02-linei-npm ok
CASE g01-forma-nositelja ok
CASE g02-rabochij-katalog-nositelja ok
CASE i01-nositel-ispolnim ok
CASE i02-zamknutyj-inventar ok
CASE r01-krug-zapisi-chtenija KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE r02-popytka-prodjusera KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE r03-imja-pobeg KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE r04-imja-razdelitel KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE r05-run-nechislovoj KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE r06-nepolnaja-identifikacija KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE r07-shablon-sbor KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE r08-istochnik-otsutstvuet KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE r09-izoljacija-popytok KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE r10-shablon-pusto KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE r11-tochnoe-imja-otsutstvuet KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE s01-styk-sbor-agregat KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
клеток 29, зелёных 16, красных 13
```

Команда с тем же субъектом и подменой пина вместо удаления снимка:

```sh
cp fixtures/workshop_project/mob_ci_artifacts_local_197/oracle143/ci-aggregate.cjs /tmp/dev-harness-verify/Crit197V10/attack/family/oracle143/ci-aggregate.cjs && python3 -c "import json; from pathlib import Path; p=Path('/tmp/dev-harness-verify/Crit197V10/attack/family/source.json'); d=json.loads(p.read_text()); d['agregat_143']['sha256']='0'*64; p.write_text(json.dumps(d))" && bash /tmp/dev-harness-verify/Crit197V10/attack/family/red_mob_ci_artifacts_local_197.sh --repo /tmp/dev-harness-verify/Crit197V10/attack/subject
```

Сырой вывод, rc 1 (в точности тот же вывод, что у предыдущей команды):

```text
CASE a01-upload-artefakt-ostalsja ok
CASE a02-download-artefakt-ostalsja ok
CASE a03-gh-kanal-v-run ok
CASE b01-forma-pisatelja ok
CASE b02-imja-pisatelja-razreshimo ok
CASE b03-pisatel-s-run-argumentom ok
CASE c01-forma-chitatelja ok
CASE c02-imja-bez-pisatelja ok
CASE c03-run-para-iz-sborki ok
CASE d01-koren-vne-skripta ok
CASE d02-vyhod-za-koren ok
CASE e01-skript-pin KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE e02-linei-npm ok
CASE g01-forma-nositelja ok
CASE g02-rabochij-katalog-nositelja ok
CASE i01-nositel-ispolnim ok
CASE i02-zamknutyj-inventar ok
CASE r01-krug-zapisi-chtenija KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE r02-popytka-prodjusera KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE r03-imja-pobeg KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE r04-imja-razdelitel KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE r05-run-nechislovoj KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE r06-nepolnaja-identifikacija KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE r07-shablon-sbor KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE r08-istochnik-otsutstvuet KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE r09-izoljacija-popytok KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE r10-shablon-pusto KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE r11-tochnoe-imja-otsutstvuet KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
CASE s01-styk-sbor-agregat KRASNO: SKRIPT_NET: mobile/scripts/ci-artefakty.cjs
клеток 29, зелёных 16, красных 13
```

## Карта классов

К-01: чисто — вход: лист `sdacha_197.md`, форма 193, слово владельца и разрешение в коммите.
К-02: чисто — вход: задание 197 вариант (г), консультация Cons197Ci и контракт :13,53,79,93,104.
К-03: чисто — вход: станционная проверка 143 до/после и 12/12; шесть имён и два пина сохранены.
К-04: чисто — вход: `git diff 98ca14e7a1 95235b366a --stat`, зоны контракта и пустой diff трёх CI-файлов.
К-05: чисто — вход: контракт :69-79, прежние команды и rc сохранены в затронутом срезе.
К-06: блок — целостность оракула проверяется лишь при достижении s01.
К-07: чисто — вход: selftest lane rc 0, 29/29 и 32/32; station до и после rc 0.
К-08: чисто — вход: selftest lane rc 0, кодовые мутации s01 и двух снимков пойманы своими причинами.
К-09: блок — тот же класс раннего обхода проверки оракула на `--repo` с отсутствующим скриптом.
К-10: чисто — вход: s01 и ожидаемая причина стаба, независимая поимённая сверка шести красных 143.
К-11: чисто — вход: независимый пин source.json и совпадающие хеши извлечённого оригинала и снимка вне model/.
К-12: чисто — вход: `git show`, sha256 и node-оригинал, не двойник.
К-13: н/п — секреты вне узкой дельты.
К-14: чисто — вход: побайтовый оригинал зелён в полном selftest; станционная сверка 12/12.
К-15: чисто — вход: lane rc 0, 29/29 и 32/32; станция шесть красных и проверка 12/12.
К-16: чисто — вход: контракт :3,93,104, класс риска неизменен и предел исторического снимка явно назван.
К-17: н/п — архитектурная модель 188 вне дельты.

## Развилки

После исправления нельзя переносить этот вердикт на новый OBJECT; дальнейший маршрут суда определяется адресным словом владельца и действующим бюджетом. После фактического freeze 143 остаётся обязательный повтор `после --ref <фактический frozen>` с карточкой ref/commit/tree/rc.
