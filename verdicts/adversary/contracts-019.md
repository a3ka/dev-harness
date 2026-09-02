FAIL

## Контрпример: константа вместо `next_id_peek`

Слабая реализация `scripts/next_id.sh` оставляет все инварианты И-1…И-7 и охрану И-6 зелёными, но не вычисляет следующий номер CONTRACT: `next_id_peek` всегда печатает `002`. В контрольном эксперименте в одноразовом клоне я заменил только этот интерфейс константой, сохранив остальные экспортируемые функции и CLI-ветку неизвестного класса.

Прогон против такой реализации завершился rc 0 для всех обязательных scoped-приёмок: семи адресных И-1…И-5/И-7, а также `--scope check_staged`, `check_charter`, `spawn_agent`, `next_id` и `check_hooks`. Положительные контроли фикстур также были зелёными.

При этом репозиторий с замороженным `contracts/019-base.md` и staged `contracts/020-draft.md` под автором `architect` получил rc 1 и `ОТКАЗ: вне зоны: contracts/020-draft.md`. Корректное вычисление максимума по истории обязано вернуть `020` и пропустить этот draft-путь без суда зон. Следовательно, ветвь draft-пуска проверена только для единственного значения `002`, а предмет «следующий свободный номер» не доказан.

Команда воспроизведения контрпримера после установки описанной слабой реализации в одноразовом клоне:

```bash
bash /tmp/dev-harness-adv019/repro-constant-peek.sh
```

Наблюдённый вывод:

```text
check_staged rc=1
judged: contracts/020-draft.md
ОТКАЗ: вне зоны: contracts/020-draft.md
```

Команда проверки, которую слабая реализация проходит:

```bash
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope check_staged/case_ustav_bez_razreshenija
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope check_staged/case_ustav_bez_puti
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope check_staged/case_ustav_bez_priciny
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope check_staged/case_draft_sledujushhij_id
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope check_staged/case_ustav_koltso_zamorozki
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope spawn_agent/case_octal_sdvig_znachenija
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope check_charter/case_merge_delta_bez_razreshenija
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope check_staged
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope check_charter
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope spawn_agent
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope next_id
bash scripts/verify_antiplacebo.sh /tmp/dev-harness-adv019/repo --scope check_hooks
```

## Советы

Добавить в `fixtures/check_staged/case_draft_sledujushhij_id.sh` серийный вход с уже занятым CONTRACT-номером выше `001` (например, `019`) и staged `<max+1>` (`020`); сохранить соседний номер как отрицательный вход. Отдельный scoped-case для `next_id_peek` должен проверять минимум два разных максимума и отсутствие нового `id/CONTRACT/*` тега.

## Контрольные прогоны исходной пачки

До контрольного эксперимента обязательные scoped-прогоны и `bash scripts/check_contract_frozen.sh` на исходном клоне завершились rc 0. `git diff 09ad72b..HEAD --stat -- contracts/ plans/` не вывел изменений замороженного текста.
