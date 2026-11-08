accept

СУД: repo=dev-harness; предмет=166; фаза=v+1 (v2); роль=critic; вызов=2 (исправительный); модель-план=openai-codex/gpt-5.6-terra; сессия=Crit166v2c; модель-факт=openai-codex/gpt-5.6-terra; OBJECT=b4fc71e04786a59350730cc270f18979dcf8f8e7; предыдущий=wip/166/critic-v2a-keep bcc3958d3; исключение=Terra временно назначена оверлеем apex-sol вместо исчерпанного GLM.

## Предмет, границы и независимость

Судится только закоммиченный OBJECT `b4fc71e04786a59350730cc270f18979dcf8f8e7`. Автор и committer OBJECT — `architect`; модель автора по выданному заданию — Sol, фактическая модель судьи — Terra, поэтому судья не судит собственную работу и независимость соблюдена.

Трёхточечный diff `origin/main...OBJECT` содержит ровно два пути:

```
contracts/166-snyatie-ogranichitelya-modelej.md
fixtures/workshop_project/model_choice_166/red_model_choice_166.sh
```

Пересобранный объект сохраняет текст прежнего кандидата: `git diff --exit-code 5df77074cf291227ce60900fc5459d3a92961898 b4fc71e04786a59350730cc270f18979dcf8f8e7 -- contracts/166-snyatie-ogranichitelya-modelej.md` вернул rc 0. Относительно `origin/main` v2 только усиливает исполнимость: добавляет конкретную безаргументную CI-команду для раннера, строку CI с TAB-разделителями, требуемые `- ` у четырёх каналов ПРОВОДКИ и заголовок порядка; прежние предмет, модель угроз, зоны, красные/зелёные проверки и неизменяемые защиты не ослаблены.

Набор артефактов полон: есть предмет, проверяемый критерий с rc-командами, именованные исполнители и ЗОНА-строки; класс риска «обычный» соответствует предмету. Секция модели угроз имеет 3 свойства ЗАЩИЩАЕТ и 3 НЕ ЗАЩИЩАЕТ. Критерий не может быть удовлетворён пустым раннером: безаргументный раннер запускает живой субъект, честную модель и собственные мутации; возвращённый семейный отказ наблюдаемо делает его красным.

Н-39 соблюдён: адресное соответствие мутантов и клеток объявлено только в `probe.py`; в прозе контракта нет пары «стаб ↔ ветвь». `pre_critic` прошёл его проверку.

## Результаты проверок

В одноразовом клоне с собственным `.git` `/tmp/dev-harness-verify/Crit166v2c/clone`, HEAD которого был OBJECT, выполнены:

```
bash scripts/pre_critic.sh --repo . contracts/166-snyatie-ogranichitelya-modelej.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
КРИТИК: дверь зелёная
rc=0

bash scripts/check_provodka.sh . contracts/166-snyatie-ogranichitelya-modelej.md
проводка: guard не подключён: scripts/make_task.sh не вызывается в .githooks/ или .github/workflows/
rc=1
```

Последний результат — единственный и ожидаемый остаток до интеграционного CI-коммита orchestrator: контракт называет точную строку `registry/ci-steps.tsv`, назначает её orchestrator и требует rc 0 до done. Это не ложное зелёное и не ослабление критерия.

```
bash scripts/check_precision_gate.sh . contracts/166-snyatie-ogranichitelya-modelej.md
OK
rc=0

bash scripts/check_threat_model.sh . contracts/166-snyatie-ogranichitelya-modelej.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 3 буллет(ов), НЕ ЗАЩИЩАЕТ 3 буллет(ов))
rc=0
```

Безаргументный CI-раннер на живом субъекте, честной модели и своих трёх стабаx:

```
bash fixtures/workshop_project/model_choice_166/red_model_choice_166.sh
166 critic_sol_sol: OK rc=0 stderr=''
166 reviewer_glm_glm: OK rc=0 stderr=''
166 reviewer_cross: OK rc=0 stderr=''
166 critic_no_author: OK rc=1 stderr='ОТКАЗ: свидетельство не той роли: architect'
166 reviewer_no_author: OK rc=1 stderr='ОТКАЗ: свидетельство не той роли: implementer'
166 critic_no_judge: OK rc=1 stderr='ОТКАЗ: свидетельство не той роли: critic'
166 reviewer_no_task: OK rc=1 stderr='ОТКАЗ: нет выданного задания: 777'
166 critic_sol_sol: OK rc=0 stderr=''
166 reviewer_glm_glm: OK rc=0 stderr=''
166 reviewer_cross: OK rc=0 stderr=''
166 critic_no_author: OK rc=1 stderr='ОТКАЗ: свидетельство не той роли: architect'
166 reviewer_no_author: OK rc=1 stderr='ОТКАЗ: свидетельство не той роли: implementer'
166 critic_no_judge: OK rc=1 stderr='ОТКАЗ: свидетельство не той роли: critic'
166 reviewer_no_task: OK rc=1 stderr='ОТКАЗ: нет выданного задания: 777'
166 critic_sol_sol: OK rc=0 stderr=''
166 reviewer_glm_glm: OK rc=0 stderr=''
166 reviewer_cross: OK rc=0 stderr=''
166 critic_no_author: OK rc=1 stderr='ОТКАЗ: свидетельство не той роли: architect'
166 reviewer_no_author: OK rc=1 stderr='ОТКАЗ: свидетельство не той роли: implementer'
166 critic_no_judge: OK rc=1 stderr='ОТКАЗ: свидетельство не той роли: critic'
166 reviewer_no_task: OK rc=1 stderr='ОТКАЗ: нет выданного задания: 777'
166 stub missing_author: CAUGHT
166 reviewer_glm_glm: RED rc=0 stderr=''
166 stub forged_trace: CAUGHT
166 reviewer_glm_glm: RED rc=1 stderr='ОТКАЗ: судья на модели автора: glm'
166 stub reviewer_blocked: CAUGHT
RC_RUNNER=0
```

Собственная мутация в disposable-клоне вернула запрет reviewer до авторского свидетеля:

```
if [ "$ROLE" = "reviewer" ]; then die "судья на модели автора: synthetic"; fi
```

На различающем входе раннер стал красным, что доказывает наблюдаемость возвращённого предметного отказа:

```
bash fixtures/workshop_project/model_choice_166/red_model_choice_166.sh --repo .
166 critic_sol_sol: OK rc=0 stderr=''
166 reviewer_glm_glm: RED rc=1 stderr='ОТКАЗ: судья на модели автора: synthetic'
166 reviewer_cross: RED rc=1 stderr='ОТКАЗ: судья на модели автора: synthetic'
166 critic_no_author: OK rc=1 stderr='ОТКАЗ: свидетельство не той роли: architect'
166 reviewer_no_author: RED rc=1 stderr='ОТКАЗ: судья на модели автора: synthetic'
166 critic_no_judge: OK rc=1 stderr='ОТКАЗ: свидетельство не той роли: critic'
166 reviewer_no_task: RED rc=1 stderr='ОТКАЗ: судья на модели автора: synthetic'
RC_MUTANT=1
```

Заморозка разрешена.
