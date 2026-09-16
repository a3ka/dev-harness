FAIL

# Адверсарий контракта 026 — TMP-РЕАП

Судимый предмет: свежий `origin`-клон на `7bb768af1702d76ba5438c1d320aef1ab00808ce`.
Предмет и его фикстуры не менялись. Заглушки и toy-репозитории жили вне клона;
вердикт составлен по исполненным контрпримерам.

## Реальные обходы

1. **Возрастной порог неверен на всей полосе `(N, N+1)` суток.** Контракт требует удалить анонимную запись, чей `mtime` *старше N дней*. Реализация сначала округляет возраст вниз до целых суток (`int((now - st.st_mtime) / 86400)`), затем применяет `age_days > tmp_reap_age`. В toy с `tmp/boundary-anon/`, mtime `7d+1s` назад, `--tmp-reap-apply` вернул `0`, а запись осталась. Она строго старше заданных 7 суток и должна быть кандидатом.

2. **NNN-нормализация пропускает перекрывающийся номер.** В имени `tmp/x0026/` есть активный распознанный `026`, поэтому старый скратч активного контракта обязан выжить. `grep -oE '0[0-9][0-9]'` забирает неперекрывающийся `002` и больше не видит суффикс `026`. На mtime `40d` apply вернул `0` и удалил `x0026/`. Контроли `x026/` и `x026-021/` в том же toy выжили; это обход нормализации, а не отсутствие защиты активных номеров.

3. **Имя с LF ослепляет источник кандидатов.** Источник начинает с `git ls-files --others -z`, но далее реализация преобразует NUL в newline и хранит список как newline-разделённый. Untracked done-имя `tmp/$'old\n021'/` (mtime `10d`) распалось на ложные строки, apply вернул `0`, а исходная запись пережила. Допустимое POSIX-имя не оговорено как исключение контрактом; кандидат с `021` и done-тегом обязан быть реапнут независимо от возраста.

4. **Отказ источника маскируется под успешный пустой список.** Заглушка `git`, делегирующая все вызовы реальному git, но возвращающая `1` только для `git -C <toy> ls-files --others ...`, дала: apply `rc=0`, старый `tmp/anon10d/` остался. Причина — конвейер построения `reap_candidates` заканчивается `|| :`. Отказ проверки «untracked-only» выглядит как «кандидатов нет», вместо fail-closed (`rc=2`/именованный отказ).

5. **Набор 026 не держит `--tmp-reap-age`.** Построена заглушка-обёртка, которая удаляет из argv только `--tmp-reap-age <N>` и делегирует всё остальное настоящему `gc_agent_branches.sh`. На `--tmp-reap-age 1` запись возраста 2d сохранилась с `rc=0`, то есть заглушка нарушает параметризованный порог. При этом все семь имеющихся проб 026 зелёные: `red_zhnets_reap_stale.sh`, `red_zhnets_aktiv_vyzhivaet.sh`, `red_zhnets_tracked_netrogat.sh`, `red_regress_024_noga2.sh`, `case_zhnets_reapstale.sh`, `case_zhnets_aktiv_vyzhivaet.sh`, `case_zhnets_tracked_netrogat.sh`. Следовательно, проверка пропускает зашитую константу вместо вычисления из флага.

## Отработанные негативные классы

- Tracked-прямой файл сохранился; untracked symlink и hard-link на него реапнулись только как собственные directory entry, сохранив tracked target.
- Symlink `tmp/external021` на каталог вне дерева был реапнут как untracked entry; внешний marker сохранился. Это соответствует инварианту «untracked под tmp/» и исключает traversal наружу.
- Dry-run, активный обычный `026`, активный+done `026-021` и свежий аноним покрыты зелёными предъявлениями.
- `uid=1000`; `sudo -n true` требует пароль, поэтому привилегированный sudo-сценарий Н/А. Непривилегированный отказ удаления уже исполнен в `case_zhnets_reapstale.sh` (закрытый `tmp/`, требуемый `rc=1`) и зелёный.
- PATH-контроль отсутствующего `python3` корректен: изолированный PATH без python3 дал `rc=2`, не ложный успех.

## Позитивный контроль

Все прямые предъявления `red_zhnets_{reap_stale,aktiv_vyzhivaet,tracked_netrogat}.sh`, `red_regress_024_noga2.sh` и три новые `case_zhnets_*.sh` завершились `rc=0`. `bash scripts/verify_antiplacebo.sh --scope gc_agent_branches` завершился `rc=0`: 5/5 case с зелёным контролем и повторным именованным красным. Также `rc=0` дали `probe_slabyh_detektora.sh` (честная форма и 18 слабых форм), `canary_zhivoj_024.sh /tmp/adversary026-k1` и последовательный `canary_vremya_024.sh` (`t_raw=12ms`, `t_check=2925ms`, порог `3036ms`).

СТЕНГРАММА: fresh origin clone HEAD=7bb768af1702d76ba5438c1d320aef1ab00808ce; 4 red + 3 new case direct rc=0; scoped gc_agent_branches rc=0 (5/5); probe_slabyh rc=0; canary_zhivoj rc=0; canary_vremya rc=0 (2925ms<=3036ms); attack harness reproduced age-boundary, NNN-overlap, LF-path, swallowed-ls-files and constant-age coverage breaches; check_no_leak.sh --check /tmp/adversary026-k1: rc=0.
