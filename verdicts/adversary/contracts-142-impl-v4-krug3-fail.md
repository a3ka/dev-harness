FAIL
OBJECT=60824db442c0fa7695a4ede8118c268e4cd84bc0
СУД: repo=dev-harness; предмет=142; фаза=реализация v4; роль=adversary; вызов=3 (scoped Q4c арбитража); модель-план=openai-codex/gpt-5.6-terra; сессия=Adv142v4c; модель-факт=openai-codex/gpt-5.6-terra; SHA=60824db442c0fa7695a4ede8118c268e4cd84bc0; предыдущий=1/2 FAIL B1,B2; 2/2 FAIL B3; арбитраж Q4c; исключение=нет

# БЛОКИРУЕТ

## B4 — фиксированный полный токен позволяет подменить исполняемый предикат и пройти все 158 клеток

**ОБЯЗАТЕЛЬСТВО:** И-1 и И-2 frozen `contracts/142-skaner-sekretov.md`: канон `USERINFO_RE` — единственный источник семантики; userinfo в authority с токеном без `/`, `?`, `#` и `[[:space:]]` судится. Q4c прямо требует искать мутант, проходящий все 158 клеток при отличии исполняемого токен-предиката от канона; класс «зашитая константа вместо вычисления» обязателен для adversary.

**КЛАСС ПРИЧИНЫ:** k121/k122 используют один и тот же детерминированный sentinel: `ves_klass_tok()` всегда строит последовательность байтов `0x01..0x7f` в возрастающем порядке с фиксированными исключениями и фиксированным хвостом `éЖ中😀`. Имя ключа случайно, но значение токена — нет. Поэтому субъект может сохранить канон-литерал (r1 зелёна), исполнять токен-класс без `"`, и переключаться на канон только когда значение содержит фиксированную подпоследовательность `0x01 0x02 0x03 0x04 0x05`. Это не канонический предикат и не исключение, выявляемое k121/k122.

**ДОСТИЖИМОЕ СОСТОЯНИЕ:** только копия интегрального дерева `mutants/mut-sentinel-token/`. В ней строка `USERINFO_RE` оставлена байт-в-байт, рабочий `grep -Eq` получает `USERINFO_TEST_RE` с токен-классом `[^/?#"[:space:]]+`, но внутри цикла разбора значения с sentinel-подпоследовательностью переключается на `USERINFO_RE`. Синтетический конформный дом содержит `X_URL=https://tok"quote@host.test/path`, а индексируемый `leak.txt` содержит то же значение. Реальный дом секретов не читался.

**НАБЛЮДЕНИЕ:** полный запуск батареи принимает эту неверную реализацию; затем тот же конформный вход запускает workshop вместо отказа.

```text
$ python3 make_sentinel_mutant.py && bash -n mutants/mut-sentinel-token/scripts/connect_project.sh
# rc=0

$ env LC_ALL=C bash repo/fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --repo ../mutants/mut-sentinel-token
s142 repo: клеток 158, зелёных 158, красных 0
# rc=0

$ env LC_ALL=C ./probe_quote.sh repo/scripts/connect_project.sh
quote-token rc=1 calls=0 stderr=connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «leak.txt», который git может проиндексировать — сессия не запускается
# rc=0 (сама проба напечатала результат честной двери)

$ env LC_ALL=C ./probe_quote.sh mutants/mut-sentinel-token/scripts/connect_project.sh
quote-token rc=0 calls=1 stderr=
# rc=0 (пропуск утечки и запуск workshop)
```

**ЗАКРЫВАЮЩЕЕ СВОЙСТВО:** значения k121/k122 не могут быть фиксированным sentinel. Раннер обязан на каждом запуске порождать непредсказуемую для субъекта перестановку/обрамление полного канон-класса и отдельно проверять случайный токен с `"` (в обеих URL-формах): при утечке — rc 1, `sekret-v-dereve`, 0 workshop. Мутант, сохраняющий литерал, но исполняющий более узкий класс за исключением распознанного старого sentinel, обязан дать красную клетку.

# Подтверждённые контроли и требуемый периметр

## Точность объекта и позитивный контроль

```text
$ git cat-file -t 60824db442c0fa7695a4ede8118c268e4cd84bc0
commit
# rc=0

$ git -C repo fetch -q /home/harness/dev-harness 60824db442c0fa7695a4ede8118c268e4cd84bc0
$ git -C repo diff --quiet 60824db442c0fa7695a4ede8118c268e4cd84bc0 -- fixtures/workshop_project/skaner_sekretov_142
# rc=0

$ git -C repo fetch -q /home/harness/dev-harness 61ab259a4eed685a2407a0ab9931605ea2ab6cb0
$ git -C repo diff --quiet 61ab259a4eed685a2407a0ab9931605ea2ab6cb0 -- scripts/connect_project.sh
# rc=0

$ sha256sum repo/scripts/connect_project.sh repo/fixtures/workshop_project/skaner_sekretov_142/model/connect_project.sh
 e2f5c3945a191c79e26757cb49b87348aad396abc69ebf7c709428716f693504  repo/scripts/connect_project.sh
 e2f5c3945a191c79e26757cb49b87348aad396abc69ebf7c709428716f693504  repo/fixtures/workshop_project/skaner_sekretov_142/model/connect_project.sh
# rc=0

$ env LC_ALL=C bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh
s142 subjekt: клеток 158, зелёных 158, красных 0
# rc=0

$ env LC_ALL=C bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --model
s142 model: клеток 158, зелёных 158, красных 0
# rc=0
$ env LC_ALL=C.UTF-8 bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --model
s142 model: клеток 158, зелёных 158, красных 0
# rc=0
$ env LC_ALL=en_US.UTF-8 bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --model
s142 model: клеток 158, зелёных 158, красных 0
# rc=0

$ env LC_ALL=C bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --stabs
s142 model-opora-stabov: клеток 158, зелёных 158, красных 0
s142 stabs: стабов 48, привязок 251, непойманных 0
# rc=0
```

## Требуемые мутации Q4c

```text
$ env LC_ALL=C bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --repo ../mutants/mut-b3
s142 repo: клеток 158, зелёных 156, красных 2
# rc=1; красны ровно k121-token-ves-klass, k122-token-ves-klass-bez-shemy

$ env LC_ALL=C bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --repo ../mutants/mut-bez-kavychki
s142 repo: клеток 158, зелёных 156, красных 2
# rc=1; ровно k121,k122

$ env LC_ALL=C bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --repo ../mutants/mut-ascii
s142 repo: клеток 158, зелёных 156, красных 2
# rc=1; ровно k121,k122

$ env LC_ALL=C bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --repo ../mutants/mut-colon-bez-kavychki
s142 repo: клеток 158, зелёных 157, красных 1
# rc=1; ровно k123-userinfo-ves-klass

$ env LC_ALL=C bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --repo ../mutants/mut-bez-space
s142 repo: клеток 158, зелёных 157, красных 1
# rc=1; ровно k124-granica-probelnye
```

`mut-b3` и `mut-bez-kavychki` сохраняют канон-литерал и исполняют токен-ветвь без `"`; `mut-ascii` — печатный ASCII перечислением без диапазонов; `mut-colon-bez-kavychki` сужает только user/pass-ветвь; `mut-bez-space` расширяет токен-ветвь до `[^/?#]+`.

## Честная дверь, k124 и починенные стабы

```text
$ env LC_ALL=C ./sweep.sh
fixture=tok-https locale=C rc=1 calls=0
fixture=tok-sr locale=C rc=1 calls=0
fixture=colon locale=C rc=1 calls=0
fixture=granica locale=C rc=0 calls=1
fixture=plain-address locale=C rc=0 calls=1
# rc=0

$ env LC_ALL=en_US.UTF-8 ./sweep.sh
fixture=tok-https locale=en_US.UTF-8 rc=1 calls=0
fixture=tok-sr locale=en_US.UTF-8 rc=1 calls=0
fixture=colon locale=en_US.UTF-8 rc=1 calls=0
fixture=granica locale=en_US.UTF-8 rc=0 calls=1
fixture=plain-address locale=en_US.UTF-8 rc=0 calls=1
# rc=0

$ env LC_ALL=C ./probe_stab_defect.sh stabs-check/dubli.sh d4
case=d4 rc=0 calls=1 stderr=
# rc=0
$ env LC_ALL=C ./probe_stab_defect.sh stabs-check/suffiks.sh k17
case=k17 rc=0 calls=1 stderr=
# rc=0
$ env LC_ALL=C ./probe_k1.sh stabs-check/dubli.sh
k1 rc=1 calls=0 stderr=connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «leak.txt», который git может проиндексировать — сессия не запускается
# rc=0
$ env LC_ALL=C ./probe_k1.sh stabs-check/suffiks.sh
k1 rc=1 calls=0 stderr=connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «leak.txt», который git может проиндексировать — сессия не запускается
# rc=0
```

`--stabs` также наблюдал `ПОЙМАН stab_dubli-klyucha @ d4-dubl-klyucha` и `ПОЙМАН stab_suffiks-pobezhdaet-marker @ k17-marker-chem-suffiks`: оба стаба дают свой fail-open на своей клетке и не падают по `set -u` в k1-мире.

## Регрессии двери-по-модели

```text
$ env LC_ALL=C bash fixtures/workshop_project/sessii_125/red_sessii_125.sh --model
s125 model: зелёных 70, красных 0
# rc=0

$ env LC_ALL=C bash fixtures/workshop_project/sessii_136/red_sessii_136.sh --model
sessii_136: клеток 87, зелёных 87, красных 0
# rc=0
```

# НЕ ПРОВЕРЕНО

- Полные CI, `check_zones.sh`, `check_spec_ready.sh` и форматтеры/линтеры не запускались: вне scoped-задания.
- Объявленные арбитром остатки не являются этим блокером и не исследовались как новый периметр: локале-зависимые одиночные `0x80..0xff`/Unicode-пробелы, позиционные предикаты, N≥128, контекстные/схемные предикаты, grep rc 2 на неканоническом мутанте, неполнота дополнительных привязок и B1.
