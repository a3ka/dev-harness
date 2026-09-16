accept

# Контракт 024, адверсарий к15 — финальный аудит фикса k14

Судимый HEAD: `24b80e9133069ee57b8a2e91c210a0ebcab398b8` (`origin`, свежий клон `/tmp/adversary024k15`). Клон сохранён. Предмет и проверки не менялись; этот вердикт — единственный артефакт аудита.

СТЕНОГРАММА: `bash scripts/check_no_leak.sh --check /tmp/adversary024k15 -> rc=0; основной чекаут чист`

## Позитивный контроль

Все прямые прогоны из свежего клона завершились `rc=0`:

- все 15 `fixtures/check_judge_gate/red_*.sh`: `red_detektor_utechek` (18/18 ворот), `red_excludes_target`, `red_toctou_manifest` (5/5 попыток), оба `red_rootcut_*` (8/8 и 6/6 контролей), `red_separate_gitdir`, `red_symlink_target_content`, `red_index_flags`, `red_git_config_env`, `red_gitignore_selfhide`, `red_info_refs_drift`, `red_dotgit_info_exclude`, `red_path_fake_utilit`, `red_stenogrammy_sudej`, `red_norma_stroka`;
- `probe_slabyh_detektora.sh`: честная форма прошла 18 ворот; все 17 слабых форм пойманы по своему номеру ворота и причине; плацебо `exit 1` отвергнуто;
- `canary_zhivoj_024.sh /tmp/adversary024k15`: snapshot → check → повторный check, все три `rc=0`;
- `canary_vremya_024.sh` изолированно: `t_raw=5 мс`, `t_snapshot=749 мс`, `t_check=1746 мс`, порог `3015 мс`, `rc=0`;
- отдельные `--snapshot` и `--check` чистого клона: `rc=0`.

При первом запуске `canary_vremya` одновременно с восемью тяжёлыми red-прогонами она дала `rc=1` (`t_check=4516 мс`, порог `3069 мс`); изолированный повтор выше зелёный. Это известный carve-out канарейки под параллельной нагрузкой, не регрессия и не основание для FAIL.

## Финальная атака на все строки манифеста

Статический аудит каждой фактической точки эмиссии `TRACKED`, `UNTRACKED`, `UNTRACKED-REPO`, `UNTRACKED-DIR`, `DOTGIT`, `DOTGIT:SYMLINK`, `DOTGIT:CONTENT` и `DOTGIT:DANGLING` показал: каждое значение, контролируемое именем/путём (tracked и untracked путь, `prefix`, имя вложенного репозитория, имя `.git/modules`, `readlink`-цель `$target`, `readlink -f` `$resolved`) перед построчными `sort`/`comm` проходит `enc_path`. Другие значения в строках — sha256, staged object ID и `HEAD` — выводы пинованных утилит/git в hex-формате либо константные маркеры. Внешняя цель `core.excludesFile` не входит в манифест v6: её скрывающий эффект нейтрализован UNTRACKED-ногой, что подтверждено `red_excludes_target_024.sh`.

Исполненный контрпример прежнего класса был повторён в `/tmp/dev-harness-verify/adversary024-k15-injection-audit.sh`: у carrier-hook в `.git/hooks` и raw `$target`, и `$resolved` содержали literal LF/TAB и `DOTGIT:DANGLING`-подобный фрагмент. После snapshot carrier удалён, создан новый dangling hook `payload`. Проверка вернула `rc=1` и назвала `.git/hooks/payload`; ложного `rc=0` нет. Это непосредственно проверяет обе точки, которые были сырыми в k14.

Отдельно проверен stderr-вектор: untracked имя содержало отдельную строку `основной чекаут чист`, затем делалось нечитаемым. `--check` вернул именованный fail-closed `rc=2` («не смог прочитать»), а не `rc=0`. stderr остаётся вне stdout манифеста: `manifest()` получает только stdout трёх producer-функций, а `comm` работает только с `cur` и `base`; диагностические строки не являются входом line-oriented сравнения.

Найденные ранее классы также удерживаются исполнением: producer failure/127 и константы ERR/`-` — ворота 15–18 и слабые стабы; фальшивые инструменты/пустой вывод PATH — `red_path_fake_utilit`; неверный cwd/пустая база/всегда-чисто и нейтрализация отдельных проверок — соответствующие слабые формы в probe.

## Вердикт

**accept.** Воспроизведённый k14 обход через `$target`/`$resolved` больше не проходит: все контролируемые текстовые поля строк манифеста кодируются до `sort`/`comm`, а диагностические строки не смешиваются с манифестом. Позитивный контроль зелёный, слабые реализации проверкой ловятся, и чистый клон проходит снимок/сверку с `rc=0`.
