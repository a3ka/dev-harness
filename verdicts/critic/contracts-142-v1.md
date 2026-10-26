accept
OBJECT=065f9ef3c907209d9abde14ee23ac24ab90016dd
СУД: repo=dev-harness; предмет=142; фаза=контракт; роль=critic-sol; вызов=3 (один дополнительный по решению арбитра после 2/2); модель-план=openai-codex/gpt-6-sol; сессия=Critic142c (назначение; trace ID не предоставлен); модель-факт=openai-codex/gpt-6-sol (workstation); SHA=065f9ef3c907209d9abde14ee23ac24ab90016dd; предыдущий=verdicts/critic/contracts-142-v1-krug1-fail.md, verdicts/critic/contracts-142-v1-krug2-fail.md + verdicts/arbitration/contracts-142-arbitraz.md; исключение=вызов сверх 2/2 разрешён заранее словом владельца 25.10 и решением арбитра, строго по перечню F.

Независимость: автор Architect142c — zai/glm-5.3 (задание), судья Critic142c — openai-codex/gpt-6-sol (факт workstation). Судился только HEAD отдельного SSH-клона: `git rev-parse HEAD` → `065f9ef3c907209d9abde14ee23ac24ab90016dd`, `git rev-parse HEAD^` → `0a8d9129f751d711b006bab1c5429af0818e06de`. Арбитражное решение прочитано из основного репозитория: указанного файла нет в ветке архитектора. Исходные мутанты только прочитаны; все изменения субъекта и модели — в одноразовых копиях `/tmp/dev-harness-verify/Critic142c/oneoff/`. Никаких commit/push.

## БЛОКИРУЕТ

Нет. Ранее зелёный белый список из 17 имён и предшествующий список пяти теперь оба красны ровно на k19–k30; иных блокирующих отклонений в закрытом перечне F не найдено.

## СОВЕТ

Нет. Объявленные арбитражем остатки (подгонка под бесконечный класс формы генератора, политика неизвестных имён, токен в path/query без userinfo) повторно не предъявлялись.

## Суд по перечню F

- **(i)** В одноразовой копии W: rc 1, 62/43/19; модель: rc 0, 62/62; `--stabs`: rc 0, модель-опора 62/62, 21 стаб / 66 связей / 0 непойманных; без субъекта: rc 1 и **62** отдельных `SUBJECT_ABSENT`; порча модели: rc 2 `ORACLE_TAMPERED`; модель как субъект: rc 0, 62/62. `pre_critic --repo`, `check_precision_gate`, `check_spec_ready`, `check_ceilings` — rc 0; соседи 125 — 70 зелёных / 0 красных, 136 — 87/87, оба rc 0. Вся среда вызовов из `run_f.py` равна `env -i PATH=/home/harness/.local/bin:/usr/bin:/bin`.
- **(ii)** `/tmp/dev-harness-verify/Critic142/mutate142.py` и `/tmp/dev-harness-verify/Critic142b/mutate142-expanded.py` независимо применены к двум *своим* клонам модели, не к кандидату. Четыре запуска `W --repo`: rc 1, каждый 62/50/12, красные идентификаторы по точному разбору строк — только k19–k30, без пробелов в диапазоне; оба повтора каждого мутанта дали различающиеся `imya=`. Новый штатный стаб `stab_belyj-spisok-17-imen` пойман на каждой из 12 привязок. Подмена субъекта честной моделью — rc 0, 62/62.
- **(iii)** `imya() { printf 'X%s%s' "$(rnd | tr a-f A-F)" "$1"; }` расположен сразу после `rnd()`; `rnd()` режет sha256 до 12 hex, `tr` переводит a–f к A–F. `source.json:.kanon`: маркеры `KEY TOKEN SECRET PASSWD PASSWORD PASSPHRASE PRIVATE AUTH COOKIE CREDENTIAL`; суффиксы `_URL _HOST _PORT _ADDR _ENDPOINT _NAME URL HOST PORT ADDR ENDPOINT NAME`. В каждом полном слове маркера/суффикса есть буква вне `0–9A–F`, ни один суффиксный токен не равен секретному маркеру; следовательно случайный префикс не вводит иной самостоятельный маркер или адресный суффикс, выбранный суффикс задаёт единственный класс (для `_URL` неизбежно вложенное `URL` того же адресного класса). Ведущая `X`, 12 `[0-9A-F]` и суффикс `[A-Z_]` соответствуют грамматике 125 `[A-Za-z_][A-Za-z0-9_]*`. В `kletka`: T1/T2 присваиваются до ветвей `case`, IMYA генерируется и дом секретов/носитель записываются до `run_dver`; `VID=sessija` для k19–k30, `VID=otkaz` для k31–k42. Ожидание задаётся до запуска субъекта, не выводится из ответа. Никакого перебора имён для этого довода не требовалось.
- **(iv)** `git diff --name-only 0a8d9129f..065f9ef3c` дал ровно контракт, раннер, `source.json`, новый стаб. Побайтовая сверка с `git show` и SHA: модель совпадает, pin `7437595aa8661f9be493b19e9181ab45baaee0f576e368ef1860b2c6752be2ba` совпадает с действительным sha256; 20 старых стабов и клетки k1–k18/z1–z7/f1–f7/d1–d5/r1 раннера байт-неизменны. В раннере diff ограничен `imya()` с пояснением, `local IMYA`, k19–k42 и двумя printf красных строк. В source.json только новые id k19–k42 при прежних осях/vid, перепривязка прежних двух списков и привязка нового, факультативная пояснительная строка; `.kanon`/`.model_sha256` без изменений. Тело нового `case` точно совпадает с 17 именами исходного `mutate142-expanded.py` (сравнение раскрытого списка). Контракт изменён только в пунктах D1–D6 арбитража: И-3, И-6, критерий, угроза/остаток и сдача; D7 не изменён. Структурные проверки `python3 /tmp/dev-harness-verify/Critic142c/check_delta_f.py` и `python3 /tmp/dev-harness-verify/Critic142c/check_contract_f.py` → rc 0 и `PASS` (протокол их stdout наблюдался отдельно).

## Сырые измерения

Полные *несокращённые* объединённые stdout+stderr и rc каждой реально вызванной команды лежат в `/tmp/dev-harness-verify/Critic142c/raw-f/<метка>.txt`: `W`, `model`, `stabs`, `absent`, `tampered`, `modelsubject`, `mutate-mutant5`, `mutate-mutant17`, `mutant5-1`, `mutant5-2`, `mutant17-1`, `mutant17-2`, `precritic`, `precision`, `ready`, `ceilings`, `P`, `Q`. Ниже дословные строки решающих выходов; непоказанные зелёные клетки и остальные строки сохраняются в названных файлах. cwd `/tmp/dev-harness-verify/Critic142c/oneoff/clean`, кроме запуска порчи модели из `oneoff/tampered`; для каждого subprocess `env -i PATH=/home/harness/.local/bin:/usr/bin:/bin`. `W` ниже — `bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh`.

```text
$ W
rc=1
КЛЕТКА k5-url-adres КРАСНА: ждали сессию rc 0 (адрес/параметр не судится); rc=1 calls=0 (connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «.harness/verdicts/critic/contracts-006-krug1-fail.md», который git может проиндексировать — сессия не запускается)
КЛЕТКА k19-lyuboe-url КРАСНА: ждали сессию rc 0 (адрес/параметр не судится); rc=1 calls=0 (connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «reports.md», который git может проиндексировать — сессия не запускается) imya=X50CA8C4F599C_URL
КЛЕТКА k30-lyuboe-name-baz КРАСНА: ждали сессию rc 0 (адрес/параметр не судится); rc=1 calls=0 (connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «arch.md», который git может проиндексировать — сессия не запускается) imya=X4B7A58F90413NAME
КЛЕТКА r1-kanon-v-subekte КРАСНА: канон предиката не в субъекте байт в байт: нет канона секретных маркеров; нет канона адресных суффиксов; нет канона userinfo;
s142 subjekt: клеток 62, зелёных 43, красных 19
БОЛЬ-SEJCHAS: красные клетки перечислены выше (до реализации это ожидаемо)
$ W --model
rc=0
s142 model: клеток 62, зелёных 62, красных 0
$ W --stabs
rc=0
s142 model-opora-stabov: клеток 62, зелёных 62, красных 0
ПОЙМАН stab_belyj-spisok-17-imen @ k19-lyuboe-url
ПОЙМАН stab_belyj-spisok-17-imen @ k20-lyuboe-host
ПОЙМАН stab_belyj-spisok-17-imen @ k21-lyuboe-port
ПОЙМАН stab_belyj-spisok-17-imen @ k22-lyuboe-addr
ПОЙМАН stab_belyj-spisok-17-imen @ k23-lyuboe-endpoint
ПОЙМАН stab_belyj-spisok-17-imen @ k24-lyuboe-name
ПОЙМАН stab_belyj-spisok-17-imen @ k25-lyuboe-url-baz
ПОЙМАН stab_belyj-spisok-17-imen @ k26-lyuboe-host-baz
ПОЙМАН stab_belyj-spisok-17-imen @ k27-lyuboe-port-baz
ПОЙМАН stab_belyj-spisok-17-imen @ k28-lyuboe-addr-baz
ПОЙМАН stab_belyj-spisok-17-imen @ k29-lyuboe-endpoint-baz
ПОЙМАН stab_belyj-spisok-17-imen @ k30-lyuboe-name-baz
s142 stabs: стабов 21, привязок 66, непойманных 0
$ W --repo /tmp/dev-harness-verify/Critic142c/oneoff/absent
rc=1
КЛЕТКА k1-api-key КРАСНА: SUBJECT_ABSENT: /tmp/dev-harness-verify/Critic142c/oneoff/absent/scripts/connect_project.sh
КЛЕТКА r1-kanon-v-subekte КРАСНА: SUBJECT_ABSENT: /tmp/dev-harness-verify/Critic142c/oneoff/absent/scripts/connect_project.sh
s142 repo: клеток 62, зелёных 0, красных 62
$ W --repo /tmp/dev-harness-verify/Critic142c/oneoff/tampered (cwd oneoff/tampered)
rc=2
s142: ORACLE_TAMPERED: sha256 модели ≠ source.json:.model_sha256
$ W --repo /tmp/dev-harness-verify/Critic142c/oneoff/modelsubject
rc=0
s142 repo: клеток 62, зелёных 62, красных 0
```

Сырые атаки пяти/семнадцати имён: обе исходные программы были применены только к своим копиям; ниже фактические строки k19 и k30 каждого из четырёх прогонов, список **всех** двенадцати красных строк каждого находится в соответствующем raw-файле. Точный разбор программой проверил последовательность k19, k20, …, k30, и разные списки `imya=` между запусками каждого мутанта.

```text
$ python3 /tmp/dev-harness-verify/Critic142/mutate142.py /tmp/dev-harness-verify/Critic142c/oneoff/mutant5
rc=0
MUTATION: address suffix function accepts only five known public key names, preserves all three canon lines
$ W --repo /tmp/dev-harness-verify/Critic142c/oneoff/mutant5 [первый запуск]
rc=1
КЛЕТКА k19-lyuboe-url КРАСНА: ждали сессию rc 0 (адрес/параметр не судится); rc=1 calls=0 (connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «reports.md», который git может проиндексировать — сессия не запускается) imya=X7D4E236143DF_URL
КЛЕТКА k30-lyuboe-name-baz КРАСНА: ждали сессию rc 0 (адрес/параметр не судится); rc=1 calls=0 (connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «arch.md», который git может проиндексировать — сессия не запускается) imya=XBA1A9714F2FDNAME
s142 repo: клеток 62, зелёных 50, красных 12
$ W --repo /tmp/dev-harness-verify/Critic142c/oneoff/mutant5 [второй запуск]
rc=1
КЛЕТКА k19-lyuboe-url КРАСНА: ждали сессию rc 0 (адрес/параметр не судится); rc=1 calls=0 (connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «reports.md», который git может проиндексировать — сессия не запускается) imya=XB8B4B26CE653_URL
КЛЕТКА k30-lyuboe-name-baz КРАСНА: ждали сессию rc 0 (адрес/параметр не судится); rc=1 calls=0 (connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «arch.md», который git может проиндексировать — сессия не запускается) imya=XD97BF7B88D19NAME
s142 repo: клеток 62, зелёных 50, красных 12
$ python3 /tmp/dev-harness-verify/Critic142b/mutate142-expanded.py /tmp/dev-harness-verify/Critic142c/oneoff/mutant17
rc=0
MUTATION: address suffix function accepts exactly 17 positive fixture names, not any other valid suffix name; canonical strings unchanged
$ W --repo /tmp/dev-harness-verify/Critic142c/oneoff/mutant17 [первый запуск]
rc=1
КЛЕТКА k19-lyuboe-url КРАСНА: ждали сессию rc 0 (адрес/параметр не судится); rc=1 calls=0 (connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «reports.md», который git может проиндексировать — сессия не запускается) imya=X978BCC2B37FF_URL
КЛЕТКА k30-lyuboe-name-baz КРАСНА: ждали сессию rc 0 (адрес/параметр не судится); rc=1 calls=0 (connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «arch.md», который git может проиндексировать — сессия не запускается) imya=X5424275EE474NAME
s142 repo: клеток 62, зелёных 50, красных 12
$ W --repo /tmp/dev-harness-verify/Critic142c/oneoff/mutant17 [второй запуск]
rc=1
КЛЕТКА k19-lyuboe-url КРАСНА: ждали сессию rc 0 (адрес/параметр не судится); rc=1 calls=0 (connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «reports.md», который git может проиндексировать — сессия не запускается) imya=X4DEFA90FD0A4_URL
КЛЕТКА k30-lyuboe-name-baz КРАСНА: ждали сессию rc 0 (адрес/параметр не судится); rc=1 calls=0 (connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «arch.md», который git может проиндексировать — сессия не запускается) imya=X9D28CA3C368BNAME
s142 repo: клеток 62, зелёных 50, красных 12
```

Сырые строки остальных ворот:

```text
$ bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Critic142c/oneoff/clean contracts/142-skaner-sekretov.md
rc=0
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
КРИТИК: дверь зелёная
$ bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic142c/oneoff/clean contracts/142-skaner-sekretov.md
rc=0
OK
$ bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Critic142c/oneoff/clean contracts/142-skaner-sekretov.md
rc=0
OK
$ bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Critic142c/oneoff/clean
rc=0
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 137 черновик(ов) судится, замороженные — по тегам
потолки в порядке
$ bash fixtures/workshop_project/sessii_125/red_sessii_125.sh
rc=0
ЗЕЛЕНО c22-zhizn-imya
s125 red: зелёных 70, красных 0
$ bash fixtures/workshop_project/sessii_136/red_sessii_136.sh
rc=0
sessii_136: клеток 87, зелёных 87, красных 0
```

Решение: по зафиксированному OBJECT закрытый арбитражный пункт F исполнен; accept допускает freeze только этого кандидата, не меняет объявленные остаточные риски и не заменяет последующие роли implementer/adversary/reviewer.
