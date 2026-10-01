accept

# Адверсарий — контракт 067, круг 2

Судимый предмет: `29abd26de22172dd581afae3580a687cabfa25eb` (implementer), land
`f38faa5`; судимый HEAD `2bbe8a2ba08d303a0023ed0104849abeee41bfed` =
`origin/main`. Два верхних HANDOFF-коммита предмет не меняют. Проверка была
исполнена против обманных реализаций в одноразовом SSH-клоне; предмет и его
проверка не правились.

## Стенограммы положительного контроля

| команда | rc | наблюдённый результат |
|---|---:|---|
| `bash fixtures/check_runner_hygiene/red_izolcfg_backend_avto_067.sh .` | 0 | `ИТОГ 067: ветвей 13, красных 0, зелёных 13` |
| `bash scripts/check_runner_hygiene.sh . izolcfg` | 0 | `ok (izolcfg) … enabled: true + … backend: auto` |
| `bash scripts/verify_antiplacebo.sh . --scope check_runner_hygiene/case_izolcfg_bez_kljucha check_runner_hygiene/case_klon_v_dereve check_runner_hygiene/case_izolnorm_bez_isolated` | 0 | 1 барьер, 3 фикстуры, все три повторно предъявлены красным |
| `git diff --exit-code frozen/contracts/067/1 HEAD -- 'contracts/067-*.md'` | 0 | пусто |
| `git diff --exit-code 29abd26 HEAD -- scripts/check_runner_hygiene.sh fixtures/check_runner_hygiene/red_izolcfg_backend_avto_067.sh fixtures/check_runner_hygiene/_lib.sh` | 0 | пусто |
| `git show 29abd26:scripts/check_runner_hygiene.sh \| grep -c ENABLED_INVALID` | 1 | `0` (мёртвая ветвь удалена) |

Первые три прогона проведены на неизменённом судимом HEAD. Батарея — также
положительный контроль честной минимальной реализации: она не вечно-красная.

## Мутанты (оракул — живая батарея)

Каждая строка — отдельный подставной корень: в нём заменён только
`scripts/check_runner_hygiene.sh`, а батарея и её входы взяты из судимого
коммита. `пойман` означает rc=1 батареи, то есть неверная реализация не смогла
пройти все клетки.

| мутант / правка | итог батареи | пойман / ускользнул |
|---|---|---|
| **к1: структурно слепой grep-стаб**: принимает любой `enabled: true` и `^  backend: auto$`, не ведёт контекст YAML | rc=1; 10 красных, в частности к9, к10 и к13 ложно rc=0 | **пойман** |
| **инструмент мимо PATH**: перед единственным `awk` задан `PATH=/definitely-no-awk` | rc=1; 13 красных. к2–к7 все красны: вместо требуемых `LEGACY_MODE` / `PINNED_BACKEND` / `enabled: false` / `HALF` / `LEGACY_PATH` вывод пустой причины | **пойман**; Д2 закрыт |
| **к9, нейтрализация catch-all**: удален сброс всего контекста на чужой top-level ключ | rc=1; ровно к9 ложно rc=0 (`ok (izolcfg)`) вместо `HALF` | **пойман** |
| **к10, слабый якорь enabled**: любой отступ `enabled: true` считается task.isolation | rc=1; к10 ложно rc=0 (также к9/к13) | **пойман** |
| **к11, ответ на первый токен**: полное `backend` заменено на первое слово значения | rc=1; ровно к11 ложно rc=0 вместо `PINNED_BACKEND` | **пойман** |
| **к12, слабый якорь top.backend**: `backend` допускается на любой глубине верхнего isolation-контекста | rc=1; ровно к12 отклонена с неверным `PINNED_BACKEND` вместо требуемого `HALF` | **пойман** |
| **к13, нейтрализация sibling-сброса**: удален сброс `in_task_isol` на соседнем ключе глубины 2 | rc=1; ровно к13 ложно rc=0 вместо `enabled: false` | **пойман** |
| **пустой вход**: пустой `.omp/config.yml` при существующем toy-runner | прямой `bash scripts/check_runner_hygiene.sh <root> izolcfg` → rc=1, `NO_KEYS` | **пойман** |

Ключевые дословные стенограммы мутантов:

```text
catch-all disabled:
  ВЕТВЬ к9-sibling-stab красная: ожидался … HALF, получено rc=0: ok (izolcfg)
  ИТОГ 067: ветвей 13, красных 1, зелёных 12
  rc=1

backend = first word:
  ВЕТВЬ к11-trailing-backend красная: ожидался … PINNED_BACKEND, получено rc=0: ok (izolcfg)
  ИТОГ 067: ветвей 13, красных 1, зелёных 12
  rc=1

sibling reset disabled:
  ВЕТВЬ к13-chuzhoj-enabled красная: ожидался … enabled: false, получено rc=0: ok (izolcfg)
  ИТОГ 067: ветвей 13, красных 1, зелёных 12
  rc=1

empty input:
  ОТКАЗ ветвь (izolcfg): NO_KEYS: .omp/config.yml не несёт ни
  task.isolation.enabled, ни верхнеуровневого isolation.backend …
  rc=1
```

## Итог

Д1 круга 1 закрыт: grep-стаб и точечные нейтрализации catch-all, якорей
глубины и полного значения `backend` каждый подают неверную ветвь, а батарея
их ловит соответствующими к9–к13. Д2 закрыт: отсутствие `awk` делает к2–к7
красными именно потому, что батарея теперь пинует каждую именованную причину.
Новых блокеров не найдено. Вердикт: **accept**.
