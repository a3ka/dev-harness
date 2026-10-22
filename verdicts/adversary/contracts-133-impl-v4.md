accept
OBJECT=bb939b788ddd677e43118f8ff69c78bec41bf2a4

Scoped микро-круг B2 принят. Судились только пункты «Приёмки микро-круга» арбитража `verdicts/arbitration/contracts-133-impl-kap.md`; новых классов за её перечнем не искалось и не квалифицировалось как блокеры.

## Прямой контрпример и честные входы

В чистых независимых mktemp-мирах выполнен прямой вызов `bash scripts/dovodka_ui.sh zadanie` с продуктовым git-репозиторием, замороженным mini-harness (`frozen/contracts/132/1`), UI-зоной `mobile/src/`, тиром `probe/vision`, двойниками `omp`/`overlay` и единственной capability `probe/vision images=yes`.

* Вход из допустимой красной строки `KADR\tred\t0.100\t0.600\tbad\tNIZHE_POROGA` и следующей дословной строки `POSTSCRIPT\tthis is not a KADR record` вернул `rc=2`. Единственная stderr-строка дословно: `НЕЧЕМ СУДИТЬ dovodka: строка сверки вне грамматики: POSTSCRIPT\tthis is not a KADR record`. Файл задания отсутствует; оба `refs/dovodka/{baza,zadanie}` отсутствуют.
* Та же единственная красная KADR-строка с хвостовым LF дала `rc=0`, вывод `DOVODKA: задание …; красных кадров 1`, файл задания и оба refs выданы. Вариант без хвостового LF также дал `rc=0` с тем же наблюдаемым успехом.
* KADR-строка с добавочным пустым рекордом (`\n\n`) дала `rc=2`, без задания и refs: решение арбитража о пустой строке соблюдено.

## Батарея и обманные кандидаты

Все прогоны выполнены из этого клона на `--seed 314`:

* `--model` → `rc=0`, 34/34.
* `--stabs` → `rc=0`, 20/20 поймано; в частности нейтрализующий стаб `s20-postscript-ignoriruetsya` пойман в `c31-postscript-v-sverke` по `RC,PRICHINA,ARTEFAKT,VYDACHA`.
* `--candidate /tmp/dev-harness-verify/Adv133d` → `rc=0`, 34/34.
* Старый субъект `/tmp/dev-harness-verify/J133c` (OBJECT `603f7d940`) через `--candidate` → `rc=1`, 33/34; единственное расхождение — `c31-postscript-v-sverke`.
* Tac-кандидат `/tmp/dev-harness-verify/Arbiter133k3-cand` через `--candidate` → `rc=1`, 28/34, поэтому батарея не принимает известную подмену.

## Зоны

* `git diff --name-only d8e1065bc HEAD` вывел ровно `scripts/dovodka_ui.sh`.
* `git diff --name-only 706a6f2c0 d8e1065bc` вывел только `fixtures/workshop_project/dovodka_ui_133/model/dovodka_ui.sh` и `fixtures/workshop_project/dovodka_ui_133/source.json`, обе внутри разрешённого дерева architect.

Блокеров: 0.
