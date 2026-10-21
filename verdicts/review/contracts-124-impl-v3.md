accept
Ревью 124 «push-produkta», реализация, круг 3 из 3 (scoped на R124-3). OBJECT=ad18565442e1b07fead598835ca90139644b9552
(`wip/124/implementer`, родитель d7bd9afd8), контракт `frozen/contracts/124/1` (тег 5dfc7278), батарея `wip/124/architect` @ 375576909.
Ревьюер Rev124d. Сессия Rev124c оборвалась без вердикта; все числа ниже — мои прогоны в моём клоне, не её логи.
Находки и замеры: `/tmp/dev-harness-verify/Rev124d/review.md` (reslop, status: ready).

1. R124-3 и С-4 закрыты на настоящем git 2.43.0. Мир: подмодуль `sub` с неопубликованным коммитом S1, remote подмодуля —
   bare `dev-harness.git`; аннотированный тег на SHA. Ключи ставил в конфиг клона, в глобальный конфиг, через env
   GIT_CONFIG_COUNT/GIT_CONFIG_PARAMETERS и через include.path. Снимок refs всех bare брал до и после.
   На OBJECT во всех 14 случаях подмодулей и followTags: rc 0, Δref ровно `Complior-mob.git refs/heads/rev124d/proba <SHA>`
   (`count.sh`: 0 сдвигов `dev-harness.git main`, 0 тегов в каноне).
   На родителе d7bd9afd8 тот же репро красный в 13 случаях из 14: `dev-harness.git refs/heads/main` сдвинут в 10 случаях,
   `Complior-mob.git refs/tags/v9-local` создан в 5. Четырнадцатый случай, `push.recurseSubmodules=check`, на родителе
   даёт rc 1 без Δref: это контроль. `repro.sh` вернул rc 0 на обеих дверях.
2. Зона: `git diff --numstat d7bd9afd8 OBJECT` → `6 1 scripts/push_product.sh`. Дифф roles d7bd..OBJECT пустой (0 строк),
   c68c143e..OBJECT → `2 0 roles/orchestrator.md`: пустой разделитель и одна норма-строка. Строка байт-в-байт совпадает с `role=`
   ПРОВОДКИ frozen 124/1 (`grep -Fxc` → 1, 552 байта без LF). Коммиты c68c..OBJECT не трогают fixtures/contracts/verdicts/.review/frozen
   (0 строк).
3. Батарея на OBJECT: rc 0, «клеток 70, зелёных 70, красных 0». `--model`: rc 0, 70/70. Своей мерой: в обоих логах 70 строк
   `КЛЕТКА`, 70 уникальных ID, у всех «ЗЕЛЁНАЯ».
4. Нового достижимого обхода класса «конфигурация/окружение клона переадресует push» в закрытом перечне нет. Проверил
   push.default=matching/current, remote.pushDefault, push.autoSetupRemote, remote.<канон>.push|mirror|tagOpt|vcs|receivepack,
   url.* через env GIT_CONFIG_COUNT/GIT_CONFIG_PARAMETERS, GIT_SSH_COMMAND и core.sshCommand. Каждый случай кончается одним
   из двух исходов: rc 0 и Δref только ветки канона либо rc 1 без Δref.
   Хуки pre-push (`.git/hooks` и `core.hooksPath` в глобальном конфиге): rc 0 и лишний Δref `dev-harness.git refs/heads/hookproof`.
   Это НЕ блокер, находка Н-4 в review.md. Хук не переадресует push двери: цель и Δref канона остаются точными. Лишний push
   делает произвольный код владельца клона с правами того же пользователя ОС и тем же общедоступным `gh auth git-credential`.
   Это класс «НЕ ЗАЩИЩАЕТ п.1» контракта, а не перенаправление через конфиг. Нужна ли строка контракта о хуках или
   `--no-verify` — вопрос владельцу: на freeze такой меры не было.
Блокирующих находок нет. С-5 (клетка батареи к R124-3) и С-6 из круга 2 остаются советами и не блокируют.
