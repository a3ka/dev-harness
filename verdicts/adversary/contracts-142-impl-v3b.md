accept
OBJECT=f056f52cb239f16a54a9ff90651278cbfe56028c
СУД: repo=dev-harness; предмет=142; фаза=реализация (v3); роль=adversary; вызов=2/2 (scoped); модель-план=роль adversary по config/agent_models.json (@gpt-terra); сессия=Adv142d; модель-факт=openai-codex/gpt-5.6-terra; SHA=f056f52cb239f16a54a9ff90651278cbfe56028c; предыдущий=verdicts/adversary/contracts-142-impl-v3.md (FAIL); исключение=нет

# БЛОКИРУЕТ

Нет.

# СОВЕТ

СОВЕТ — позднее место NUL-предпроверки относительно создания каркаса проекта не нарушает обязательство контракта или воли владельца.

Обязательная формулировка И-7 (`contracts/142-skaner-sekretov.md:47`): «ЛЮБОЙ байт NUL (0x00) в СЫРОМ файле дома секретов → именованный отказ `sekret-v-dereve` с категорией „NUL“ … ДО цикла `while IFS='=' read` и ДО workshop, rc 1, fail-closed». Она не требует отказа до записи каркаса. И-5 (`contracts/142-skaner-sekretov.md:45`) закрепляет прежний момент отказа как «rc 1 ДО сессии». Воля владельца, записанная для v3 в §«Воля владельца» контракта, также требует NUL-отказ «до workshop», но не «до любых действий»; отдельного `docs/owner/`-документа с иной обязанностью нет. Поэтому добавленное оркестратором в первом вызове требование «ДО любых действий» не является обязательством предмета.

Наблюдаемое состояние не является новой утечкой: .harness/.env, профиль и trace создаются до стража и в принятой main-норме стража 125. Различены «каркас создан» и «секрет утёк/сессия запущена»: в обоих живых мирах сессия не запущена; на OBJECT отказ не печатает значение.

# Живое воспроизведение

Проверялся только scoped-блокер. Реальный дом секретов не читался: оба мира созданы с поддельным HOME, синтетическими значениями `probe`/`probe-nul-value` и двойником workshop. Предварительно:

```text
$ git cat-file -t f056f52cb239f16a54a9ff90651278cbfe56028c
commit
# rc=0
```

На main значение секретного ключа в индексируемом `leak.txt` вызывает старый отказ после создания каркаса:

```text
$ bash live_guard_probe.sh /tmp/dev-harness-verify/Adv142d/main main-value /tmp/dev-harness-verify/Adv142d/world-main
artifact .harness/.env=yes
artifact harness.project.json=yes
artifact .harness/registry/trace.tsv=yes
case=main-value rc=1 calls=0
stderr=connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «leak.txt», который git может проиндексировать — сессия не запускается
# probe rc=0
```

На OBJECT мир `FOO_URL\\0=probe-nul-value` плюс индексируемый `leak.txt` даёт обязательный NUL-отказ: rc 1 двери, workshop не вызван, значение не содержится в stderr. Каркас создан тем же прежним порядком:

```text
$ bash live_guard_probe.sh /tmp/dev-harness-verify/Adv142d/repo object-nul /tmp/dev-harness-verify/Adv142d/world-object
artifact .harness/.env=yes
artifact harness.project.json=yes
artifact .harness/registry/trace.tsv=yes
case=object-nul rc=1 calls=0
stderr=connect ОТКАЗ: sekret-v-dereve: NUL (байт 0x00) в доме секретов «/tmp/dev-harness-verify/Adv142d/world-object/home/.config/dev-harness/secrets.env» — файл не читается как KEY=VALUE; сессия не запускается
# probe rc=0
```

Кодовое положение согласуется с наблюдением: main создаёт каркас до существующего блока стража (`main/scripts/connect_project.sh:182–260`, страж с `:276`); OBJECT сохраняет каркас (`scripts/connect_project.sh:181–260`) и ставит NUL-предпроверку в этом блоке (`:287`).
