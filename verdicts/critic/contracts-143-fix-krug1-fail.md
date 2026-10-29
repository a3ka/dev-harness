FAIL
OBJECT=b8f06fc253e89780f01e6ac99fcf8178a25e439d
СУД: repo=dev-harness+Complior-mob; предмет=143; фаза=правка батареи реализации после Adv143 FAIL; роль=critic; сессия=Crit143x; модель-факт=openai-codex/gpt-6-sol; предыдущий=/tmp/dev-harness-verify/Adv143/verdicts/adversary/contracts-143-impl-v1.md; класс находки=содержательный.

БЛОКИРУЕТ fixtures/workshop_project/mob_ci_143/probe.py:1461 — требование checkout первым шагом проверяет наличие и параметры, но не ревизию (`with.ref`), не EFFECTIVE checkout после первого шага и не фактический HEAD перед сборкой. В модели `fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml:398-406` отсутствует проверка `git rev-parse HEAD == GITHUB_SHA`; строка `github.sha` в `build-identichnost.txt` не доказывает, из какой ревизии собран APK. Названное обязательство: `contracts/143-mob-ci-razdelenie.md:48-49` (единственный APK именно проверяемого PR, required агрегат не зелёный для чужого APK).
КЛАСС ПРИЧИНЫ: содержательный, ложная достаточность проверки source provenance при честных digest/outputs.
ОБХОД: первый шаг `build-apk` — настоящий `actions/checkout@v7` с `persist-credentials: false`, `clean: true`, но `ref: refs/heads/main` вместо проверяемого SHA; на PR, у которого head отличается от main, сборка чужого дерева, digest/outputs честны, а новая батарея печатает 69/69 и rc 0. Второй вариант: после правильного первого checkout вставить ещё один checkout со старым `ref` перед source-consuming шагами — также 69/69 rc 0. Оба мутанта отличаются только кодом YAML субъекта; оракул и guard не менялись. Закрывающее свойство: до source-consuming шагов фактический рабочий HEAD однозначно равен `GITHUB_SHA` проверяемого запуска; guard красит `ref` иной ревизии и подмену эффективного checkout после первого (без диктовки единственной реализации).

Сырые команды/вывод и коды (корень `/tmp/dev-harness-verify/Crit143x`, кроме отмеченного):
```
git -C /tmp/dev-harness-worktrees/c907157c/wip-143-architect cat-file -t b8f06fc253e89780f01e6ac99fcf8178a25e439d
commit
rc=0

git diff --name-only 4eb17a2e^ 4eb17a2e
fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml
fixtures/workshop_project/mob_ci_143/source.json
rc=0

git diff --name-only b8f06fc2^ b8f06fc2
fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml
fixtures/workshop_project/mob_ci_143/probe.py
fixtures/workshop_project/mob_ci_143/source.json
fixtures/workshop_project/mob_ci_143/stabs/stab_y_agregat_bez_checkout.py
rc=0

git diff 7258ff95 b8f06fc2 -- 'contracts/143-*'
[пусто]
rc=0

# прежний guard с worktree 4eb17a2e, субъект — неизменная копия продукта Adv143/mob @15e298206088015c7d039dc38b7754c35465f241
bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Adv143/mob
клеток 69, зелёных 69, красных 0
rc=0
# тот же вызов с новым guard b8f06fc2
клеток 69, зелёных 68, красных 1
КЛЕТКА y19-outputs-provodka: build-apk: сборка без checkout продукта (needs не переносит checkout и не закрепляет runner — переиспользуемый раннер собирает остаточный workspace старой ревизии) КРАСНА
rc=1

bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --model
клеток 69, зелёных 69, красных 0
rc=0
bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs
клеток 69, зелёных 69, красных 0
стабов 33, привязок 49, непойманных 0
rc=0

# python3 attack143.py — одноразовый генератор пяти РАЗНЫХ копий model/,
# только build-apk YAML, затем вызов того же red_mob_ci_143.sh --repo <копия>;
# файл генератора удалён после прогона, копии /tmp/dev-harness-verify/Crit143x-mutants/
CASE=checkout-late rc=1
клеток 69, зелёных 68, красных 1
КЛЕТКА y19-outputs-provodka: build-apk: checkout не первый шаг (позиция 1, до него 1 шагов — source-consuming шаги читают workspace до checkout) КРАСНА
CASE=credentials-persisted rc=1
клеток 69, зелёных 68, красных 1
КЛЕТКА y19-outputs-provodka: build-apk: checkout без persist-credentials: false (позиция 0) КРАСНА
CASE=unclean-tree rc=1
клеток 69, зелёных 68, красных 1
КЛЕТКА y19-outputs-provodka: build-apk: checkout без clean: true — остатки старого дерева выживают (позиция 0) КРАСНА
CASE=wrong-ref rc=0
клеток 69, зелёных 69, красных 0
CASE=second-checkout-wrong-ref rc=0
клеток 69, зелёных 69, красных 0
python3 attack143.py: rc=0 (коды каждого субъекта — строки CASE)

python3 -c 'import yaml; p="fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml"; d=yaml.safe_load(open(p)); s=d["jobs"]["build-apk"]["steps"]; print("YAML_OK jobs=%d build-apk.first=%s with=%s"%(len(d["jobs"]),s[0]["uses"],s[0]["with"])); print("build-apk.checkouts=%d"%sum(str(x.get("uses", "")).startswith("actions/checkout") for x in s))'
YAML_OK jobs=10 build-apk.first=actions/checkout@v7 with={'persist-credentials': False, 'clean': True}
build-apk.checkouts=1
rc=0

bash scripts/check_precision_gate.sh . contracts/143-mob-ci-razdelenie.md
OK
rc=0
bash scripts/check_spec_ready.sh . contracts/143-mob-ci-razdelenie.md
OK
rc=0
bash scripts/check_ceilings.sh .
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 139 черновик(ов) судится, замороженные — по тегам
потолки в порядке
rc=0
bash scripts/check_threat_model.sh . contracts/143-mob-ci-razdelenie.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 9 буллет(ов), НЕ ЗАЩИЩАЕТ 9 буллет(ов))
rc=0
bash scripts/check_predposylki.sh . contracts/143-mob-ci-razdelenie.md
PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=4
rc=0
bash scripts/pre_critic.sh --repo . contracts/143-mob-ci-razdelenie.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=4
КРИТИК: дверь зелёная
rc=0
bash scripts/check_provodka.sh . contracts/143-mob-ci-razdelenie.md
проводка: guard не подключён: fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh не вызывается в .githooks/ или .github/workflows/
rc=1
bash scripts/check_contract_frozen.sh .
  ok   contracts/143-mob-ci-razdelenie.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают
планов и контрактов на HEAD: 143 · черновиков: 3 · заморожено: 140 · реестр: full
rc=0 (между названной строкой и итогом барьер печатает другие замороженные контракты)

bash scripts/check_zones.sh .; printf 'check_zones rc=%s\n' "$?"  # timeout=1200, последний gate, [async-result]
процессных вне суда:
замороженных контрактов: 142 · объявленных авторов: 5 · коммитов в диапазонах: 37558 · проверено по зонам: 8398
check_zones rc=0
[между командой и приведёнными последними строками — многочисленные строки «ok», полный сырой вывод artifact://13649]
```

СОВЕТ contracts/143-mob-ci-razdelenie.md:159-161 — `check_provodka` не зелён именно потому, что guard ещё не подключён в CI харнесса; по буквальному порядку контракта подключение step-строкой делает оркестратор после implementer. Это отдельная незавершённая стадия, не новая причина для изменения замороженного текста и не доказательство обхода source provenance.

Предпосылка/живая приёмка: YAML модели парсится PyYAML, первый шаг `actions/checkout@v7` и его опции синтаксически корректны, тот же `actions/checkout@v7` уже есть в `quality`, `select-screens` и пяти workers текущего workflow продукта. Модель заявлена byte-copy-эталоном для implementer; поэтому запуск всего CI продукта по SHA ДО правки продукта технически не может подтвердить fix: продукт сейчас ожидаемо красный по `y19`. Доказательство живого выполнения build на обоих runner slots и required `android-e2e` — PR Complior-mob#136 ПОСЛЕ копирования исправленной модели implementer; статический YAML-pass не заменяет этот будущий запуск. До ленда батареи необходимо устранить настоящий обход `ref`/effective checkout, иначе будущая зелень guard недостаточна.

НЕ ПРОВЕРЕНО: живой CI PR #136, исполнение actions/checkout@v7 в новой build-apk на обоих слотах, сборка/установка APK и настройка required branch protection; не делались gh run, push, commit или правка чужой рабочей копии. Инструмента actionlint здесь нет (`command -v actionlint` не нашёл бинарь), YAML парсился PyYAML.
