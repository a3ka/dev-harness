FAIL
Один скоуплённый проход по П1–П7: заданные арбитром 16 свидетелей, модель, гейты и прежний регресс воспроизводятся. Однако П4 и П5 не выполнены буквально: точное равенство JSON-строк заменено сравнением после удаления завершающих LF. Три живые пробы дают ложный rc 0. Расхождение старого cleanup_schema_control из-за seed='seed' НЕ является основанием FAIL.

Предмет: contracts/121-cmp-bck-003-yadro-bd.md на закоммиченном OBJECT 6b3a528123bfec0c290e3bc38bdb0de3b245cf08, ветка wip/121/architect. Судился отдельный clone /tmp/dev-harness-verify/Critic121r3/repo; git rev-parse HEAD → указанный OBJECT, rc 0. База B извлечена git archive c525fd8d43ce3f243f8d92be72e1eedfe5375f22. Worktree автора не изменялся. Контракт, пин и оракул не исправлялись. Все записи этого прохода — внутри /tmp/dev-harness-verify/Critic121r3/. Коммит вердикта — оркестратор; push не выполнялся.

Граница суда: только закрытый перечень verdicts/arbitration/121-mutatsii-i-evidence.md:39–59 и неослабление прежних причин/клеток. Новые требования к SQL-семантике, глубине assertions, CI или распознаванию проб не вводятся. Предмет, критерий с командами, исполнители и ЗОНА-строки присутствуют; неполного набора нет.

## Блокирующие находки — только невыполненные пункты перечня

### П4 / соответствующая часть П3: роль не проверяется точным равенством

БЛОКИРУЕТ contracts/121-cmp-bck-003-yadro-bd.md:45 — обещанное ТОЧНОЕ равенство роли множеству пина не обеспечено. Основание закрытого перечня: verdicts/arbitration/121-mutatsii-i-evidence.md:47 (П4, обе категории записей) и :45 (П3, свежая запись). Механизм: fixtures/workshop_project/yadro_121/yadro_oracle.sh:142 извлекает роль через $(jq -r ...); command substitution удаляет завершающие переводы строк до сравнения.
ОБХОД: штатный арбитражный arb-core.js с честными schema-assertions и правильным seed пишет свежую запись с единственной подменой role="brokeros_api\n". Такой JSON-строки в runtime_roles НЕТ. Тем не менее неизменённый --repo возвращает rc 0. Отдельный вариант с этой ролью только в seed-записи дерева, при правильной свежей записи, также даёт rc 0. Это именно непринадлежность роли заданному множеству П4, не новая ось за пределами перечня и не семантика SQL вне грамматики.

Прогон: python3 /tmp/dev-harness-verify/Critic121r3/exact_equality.py → rc 1 сборщика, потому что требуемые отказы не получены. Внутренние результаты: exact_control → rc 0; P4_fresh_role_LF → rc 0 вместо 1 evidence-ne-native; P4_tree_role_LF → rc 0 вместо 1 evidence-ne-native. Независимое сравнение исходных JSON-значений с массивом пина в обоих случаях: role_exactly_in_pin=false. Сырьё: evidence/exact-equality.json и evidence/equality-runs.jsonl. Свидетель не ветвится на окружении/имени мутации/порядке вызовов; изменено только значение поля уже объявленной грамматики.

### П5: run_key записи дерева не проверяется на равенство константе

БЛОКИРУЕТ contracts/121-cmp-bck-003-yadro-bd.md:45 — требование run_key каждой RUNTIME-записи дерева == константе пина не выполнено. Основание закрытого перечня: verdicts/arbitration/121-mutatsii-i-evidence.md:49. Механизм: fixtures/workshop_project/yadro_121/yadro_oracle.sh:151,164 — K извлекается через command substitution, теряет завершающий LF и лишь затем сравнивается с run_key_expected.
ОБХОД: в seed.native/run.json положено run_key="77010476dc47dd83ac3f9dd02c1244924a201f589ddc8bb7379dfa849f2d692b\n"; это НЕ константа пина. Остальной seed правильный, честный arb-core.js пишет свежий правильный ключ. Неизменённый --repo возвращает rc 0 вместо требуемого П5 rc 1 evidence-chuzhoj-klyuch.

Тот же прогон exact_equality.py: P5_tree_key_LF → внутренний rc 0; независимое сравнение JSON-значения с пином: seed_key_exactly_pin=false. Этот вариант оставлен в equality-product/. Прямое воспроизведение на сохранённом дереве: TMPDIR=/tmp/dev-harness-verify/Critic121r3 bash /tmp/dev-harness-verify/Critic121r3/repo/fixtures/workshop_project/yadro_121/yadro_oracle.sh --repo /tmp/dev-harness-verify/Critic121r3/equality-product. Именно такой вызов исполнен сборщиком; оракул не патчился. Сырьё: evidence/exact-equality.json.

Оба дефекта относятся к точному равенству, уже предписанному арбитром; устранение не требует расширять грамматику или предмет. Сравнение исходного JSON-значения внутри jq, а не его lossy-представления в shell, соответствует предписанному П4 IN/index и П5 ==.

Арбитр: Arbiter121. Предмет при несогласии автора — выполнение уже обязательного точного равенства П4/П5; это остаток прежнего Б2, не открытие иной оси. Повторный инженерный спор передаётся арбитру, автор не выступает судьёй. Дополнительный круг реализации/критика настоящим файлом не назначается.

## Что подтверждено по П1–П7

Основной сборщик: python3 /tmp/dev-harness-verify/Critic121r3/verify.py → rc 0. Его rc означает совпадение перечисленных ниже ожиданий, не отсутствие блокеров exact_equality.py. Сырьё: evidence/results.json, отдельные evidence/*.log, evidence/runs.jsonl.

| Пункт | Наблюдение |
|---|---|
| П1 | B1a_select1_mkdir, B1b_select1_keydir, B1c_select1_create_role → rc 1 testy-ne-zelenye с точным уточнением «контроль перед мутацией force». В коде контроль на целом мире стоит в цикле перед каждым DAMAGE, продукт использует тот же CP; toy сначала запускается без sed. |
| П2 | control_schema_restore → rc 0; B1e_schema_NO_restore, restoreRole=false → rc 0. Все четыре damage-записи имеют revert; его исполняет оракул, контейнер удаляется trap/финальной очисткой. |
| П3 | Общая zapis_grammatika вызывается для дерева и всех свежих продуктовых run.json. B2a/B2d/B2g → rc 1 evidence-otsutstvuet; B2b/B2c/B2e/B2f → rc 1 evidence-ne-native. Частный дефект точного равенства роли указан выше, поэтому полное выполнение П3 не объявляется. |
| П4 | B2h (роль-подстрока дерева) → rc 1 evidence-ne-native; B2i (пустые errors дерева) → rc 1 evidence-otsutstvuet; свежие errors=[] также красны. errors_min product=1, toy=0. Но точное равенство роли не выполнено: блокер выше. |
| П5 | seed-unverifiable → rc 1 evidence-chuzhoj-klyuch; live K сравнивается с константой, честный контроль проходит. Но ключ дерева с LF принят: блокер выше. |
| П6 | --model → rc 0, вывод 14 отвергнутых декоев. Независимый разбор массива dekos: 11 прежних строк сохранены дословно, добавлены ровно 3 заданных декоя. |
| П7 | Инварианты 3/4, счёты 20/14, защита и cognitive-only остаток внесены. check_precision_gate.sh → rc 0; check_threat_model.sh → rc 0 (12/10 буллетов); pre_critic.sh → rc 0. Обязательные 16 арбитражных строк совпали с таблицей РЕШЕНИЯ; оговорка старого свидетеля ниже. |

Полная таблица 16 арбитражных строк:

| Случай | rc | Причина |
|---|---:|---|
| control_schema_restore | 0 | честный контроль |
| B1e_schema_NO_restore | 0 | честный кандидат без собственного teardown роли |
| B1a_select1_mkdir | 1 | testy-ne-zelenye, контроль force |
| B1b_select1_keydir | 1 | testy-ne-zelenye, контроль force |
| B1c_select1_create_role | 1 | testy-ne-zelenye, контроль force |
| B1d_select1_no_oneshot | 1 | testy-pustye |
| B2a_fresh_sql_empty | 1 | evidence-otsutstvuet |
| B2b_fresh_role_postgres | 1 | evidence-ne-native |
| B2c_fresh_sqlstate_wrong | 1 | evidence-ne-native |
| B2d_fresh_errors_empty | 1 | evidence-otsutstvuet |
| B2e_fresh_mode_pglite | 1 | evidence-ne-native |
| B2f_fresh_second_bad | 1 | evidence-ne-native |
| B2g_fresh_no_role_field | 1 | evidence-otsutstvuet |
| B2h_seed_role_substring | 1 | evidence-ne-native |
| B2i_seed_errors_empty | 1 | evidence-otsutstvuet |
| p5_seed_unverifiable | 1 | evidence-chuzhoj-klyuch |

Изоляция свидетелей: алгоритм arb-core.js, варианты его config и seed из таблицы сохранены; вместо записи в чужой /tmp/dev-harness-verify/Arbiter121/evidence/runs.jsonl перенесён только абсолютный путь лога в наш каталог. setup/run_case воспроизведены сборщиком на собственной копии продукта, чтобы не писать в чужие артефакты. Оракул — байты HEAD (независимая проверка в compare.py).

## Конфликт старого cleanup_schema_control с П5

СОВЕТ contracts/121-cmp-bck-003-yadro-bd.md:131 — прежние one-shot.py/followup.py больше нельзя использовать как независимое доказательство закрытия каждой внутренней клетки: они сами пишут run_key='seed', поэтому ранний отказ П5 маскирует дальнейшие изменения evidence. Это НЕ дефект автора и НЕ основание FAIL; автор явно и достоверно сообщил расхождение.

Копии старых свидетелей исполнены с переносом O, R и абсолютных путей логов в наш каталог, без исправления seed и логики. old_one-shot.py и old_followup.py → rc 0 сборщиков. Их внутренние результаты: one-shot и cleanup_schema_control → rc 1 evidence-chuzhoj-klyuch; остальные обходные случаи → rc 1 (роль-подстрока — evidence-ne-native, остальные — evidence-chuzhoj-klyuch). Следовательно, ожидание rc 0 для старого cleanup_schema_control конфликтует с новым обязательным П5. Честный путь с правильным ключом тем же арбитражным arb-core.js принят: control_schema_restore → rc 0; отдельный exact_control тоже → rc 0. Ослаблять П5 ради seed='seed' нельзя. Закрытие свежих полей доказано не этими замаскированными отказами, а таблицей B2 выше.

## Неослабление и регресс

- B без дополнительных файлов → rc 1 testy-otsutstvuyut; неверный флаг → rc 2.
- Noop-runner process.exit(0) → rc 1 ranner-ne-otkazyvaet; изменение байтов 003_finance.sql → rc 1 migracii-izmeneny.
- Отсутствующие runner/test, четыре набора markers, npm-проводка, native/PGlite evidence и строковый secret_locator → rc 1 каждой ожидаемой прежней причиной. Отдельные результаты сохранены в evidence/results.json.
- Независимое сравнение пинов: исходных имён 16, предыдущих 20, текущих 20; removed_original=[], removed_previous=[] (evidence/summary.json). Это счёт состава, не заявление о принудительном исполнении всех meta-ветвей.
- python3 /tmp/dev-harness-verify/Critic121r3/compare.py → rc 0: прежние 11 декой-строк не удалены/не изменены; добавлены 3, всего 14; toy-дерево не менялось. evidence/nonweakening.json и evidence/scoped.diff. Удалённые фрагменты прежней evidence-грамматики перенесены в общую функцию, а не убраны; структурные клетки, runner damage_probe и toy_trio сохранены. Блокеры точного равенства выше не маскируются этим регрессом.
- Полный CI, lint, project-wide suites, реализация будущего C и проводка CI не судились. Проводка — оркестратор.

Пять вопросов роли применены только к закрытому предмету: критерий допускает имитацию П4/П5 — три измеренных rc 0 выше; названная команда не доказывает эти равенства; новое решение исполнителю не навязывается (== уже предписано); границы и исполнители названы; гейты нормы проходят, но не подменяют поведенческое доказательство.

Контейнеры PG были одноразовыми; docker ps -a --filter name=yadro121-pg- --format '{{.Names}} {{.Status}}' после всех прогонов → rc 0, вывод пуст: контейнеров этой семьи не осталось. Клон сохранён до коммита вердикта оркестратором. Попытка отправить Main короткое уведомление о блокерах отклонена инструментом как непиннованный agent URI (Н-85); сам вердикт и итоговый структурированный доклад сохраняют результат.
