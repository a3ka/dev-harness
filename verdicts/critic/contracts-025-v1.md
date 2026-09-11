FAIL

Круг 3 по файлу, круг 1 по дельте v1→v2. Судимая дельта закоммичена на `3e3876103907454a8f722fa34461e61f8a07ada3`; набор артефактов полный: предмет, rc-критерии, исполнители и `ЗОНА`-строки названы.

БЛОКИРУЕТ contracts/025-sreda-cwd-rc.md:125-128,277-283 — новая форма И-6 объявляет относительный `| tee` «deny-стойкой» и требует дойти до стража, но предмет A-2 одновременно требует deny-паттерн именно на `tee` с относительным операндом. При выполненном A-2 этот шаг убивается user policy ДО стража и сам текст И-6 предписывает rc 2, поэтому rc 0 И-6 несовместим с выполнением предмета. И-3 проверяет только `sed -i`, `printf >>` и `>` и противоречие не обнаруживает.
ОБХОД: дерево с тремя deny-правилами `*sed -i *`, `* >> *`, `* > *`, но без deny для `tee`, удовлетворяет И-3 и позволяет И-6 получить rc 0 через path-guard, хотя требование A-2 о deny для `tee` не сделано. Именно такое состояние проверено в судейском клоне: `red_deni_patte_rny_zapisi.sh .` → rc 0 и `probe025_dochernij_vector.sh .` → rc 0.

БЛОКИРУЕТ contracts/025-sreda-cwd-rc.md:212-224,266-269 — новый предмет требует при `worktree:null` пропускать весь allowlist Г3, включая внутренние URI, но новая семиветочная rc-команда проверяет в непиннованном состоянии лишь scratch и `artifact://`; И-5 проверяет только `local://` и только без названного состояния `worktree:null`. Пункт нового предмета о внутренних URI при отсутствии пинна недоказуем названными командами.
ОБХОД: judge пропускает `artifact://` и scratch при `worktree:null`, пропускает `local://` только при непустом корректном пинне, а `local://`, `skill://`, `agent://`, `history://`, `xd://` при `worktree:null` блокирует. Семь ветвей `red_granica_nepin_pipe_tee.sh` проходят, девять ветвей И-5 проходят, И-6 внутренних URI не вызывает, но объявленный allowlist непиннованной записи не реализован.

Проверка границы дельты: `git diff frozen/contracts/025/1..3e38761 -- contracts/025-sreda-cwd-rc.md` и `git diff cb8c9cf..3e38761 -- contracts/025-sreda-cwd-rc.md` дали один SHA-256 `ef847efb5833d9c432021ef85556aa861db15f666ecd52291dafb112e821114b`. Контракт между базой и HEAD трогают только `5b4a193` и приземлённый `d25e9ce`; patch-id контрактной части `d25e9ce` совпадает с разрешённым `e880bb8`: `d734ed1f55b92519156e11e6c5bb04fa365f88b0`. Вне заявленных двух частей дрейфа нет. Коды готовности остались fail-on-nonzero; понижения прежнего rc-порога не найдено.

Исполнимость команд дельты в одноразовом клоне main:

- `bash fixtures/check_runner_hygiene/red_granica_nepin_pipe_tee.sh .` → rc 0; семь ветвей: непиннованный checkout/free-absolute block, scratch/artifact pass, relative block, пинн-острота block, in-pin pass.
- `bash fixtures/check_runner_hygiene/red_zond_dubl_toolcallid.sh .` → rc 0; синтетические режимы дали ожидаемые rc 2/0/1/2.
- `bash fixtures/check_runner_hygiene/probe025_dochernij_vector.sh .` → rc 0; живая таблица `MAIN edit=0 bash=0 false|true=ERR канарейки=OK/OK; CHILD edit=0 bash=0 false|true=ERR канарейки=OK/OK`, пинн-ребёнок `чекаут-запись=0 скратч-запись=OK`.

Зоны дельта не расширяет. Оба носителя проверки, `red_granica_nepin_pipe_tee.sh` и `red_zond_dubl_toolcallid.sh`, находятся в `fixtures/check_runner_hygiene/`, объявленном в `ЗОНА architect` (`contracts/025-sreda-cwd-rc.md:338`).

стенограмма: check_no_leak --check → rc=0
