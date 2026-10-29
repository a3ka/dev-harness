FAIL
OBJECT=987f84cf975622df538d11351ef6db58e1597ea1
СУД: repo=dev-harness+Complior-mob; предмет=143; фаза=scoped-критик правки батареи реализации; роль=critic; вызов=2/2; сессия=Crit143y; модель-факт=openai-codex/gpt-6-sol; предыдущий=/tmp/dev-harness-verify/Crit143x/verdicts/critic/contracts-143-fix143b.md; класс находки=содержательный.

БЛОКИРУЕТ fixtures/workshop_project/mob_ci_143/probe.py:1499-1521 — повтор класса Crit143x: guard проверяет присутствие подстрок `git rev-parse HEAD`/`"$GITHUB_SHA"` в строке, начинающейся с `test `, но не исполняемость, честность операндов и обязательность отказа; `if` на шаге проверки не судится. Поздние действия над деревом фильтруются по конечному списку git-глаголов без `worktree` и без копирования содержимого. Рядом `model/.github/workflows/mobile.yml:405-411` — корректный эталон, но субъекту достаточно мимикрировать под него. Обязательство `contracts/143-mob-ci-razdelenie.md:48-49,112-120`: один APK именно проверяемой ревизии PR, красная батарея не даёт зелёный required-агрегат для APK чужого дерева.
КЛАСС ПРИЧИНЫ: содержательный — ложная достаточность source provenance: литерал проверки на месте, исполняемое иное (одна причина, несколько способов).
ОБХОД: (1) `run: test "$(git rev-parse HEAD)" = "$GITHUB_SHA" || true`: при несовпадении HEAD проверка возвращает успех, все 69 клеток зелены. (2) исходный правильный `run`, но `if: ${{ false }}` на шаге проверки: GitHub Actions пропускает проверку, 69/69. (3) `run: test "$GITHUB_SHA" = "$GITHUB_SHA" # git rev-parse HEAD`: строковые маркеры имеются, фактический HEAD не прочитан, 69/69. (4) после правильной проверки `git worktree add --detach elsewhere refs/heads/main && cp -a elsewhere/mobile/. mobile/`: при наличии локального `main` рабочие исходники mobile заменены чужой ревизией после сверки, git-глагол `worktree` не запрещён, 69/69. Digest/outputs после сборки чужих исходников остаются честными и не удостоверяют provenance. Закрывающее свойство: обязательная, не пропускаемая и не маскируемая сверка фактического рабочего HEAD с SHA запуска ДО потребления исходников плюс сохранение тождества собираемого дерева после неё по всей исполняемой цепочке (включая операции вне узкого списка git-глаголов), независимо от наличия текстового литерала.
АРБИТР: Astra — повторная неустранённая причина «исполняемая source provenance build-apk vs статическое присутствие литерала/ограниченный regex» после второго critic-FAIL; исчерпан бюджет 2/2, дальнейший critic не назначается автоматически.

Команды и сырые выводы (корень `/tmp/dev-harness-verify/Crit143y`, если не указан иной; исходный кандидат НЕ менялся):
```
$ git cat-file -t 987f84cf975622df538d11351ef6db58e1597ea1   # выполнено первым в author worktree
commit
rc=0
$ git rev-parse HEAD HEAD^ HEAD^^
987f84cf975622df538d11351ef6db58e1597ea1
4eb17a2e4ae38757f13f4232760696b41b78ccb0
7258ff957e18d0b0f1584eb9f58cf90effeb2340
rc=0
$ git diff --name-status 4eb17a2e^ 4eb17a2e
M fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml
M fixtures/workshop_project/mob_ci_143/source.json
rc=0
$ git diff --name-status 987f84cf^ 987f84cf
M fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml
M fixtures/workshop_project/mob_ci_143/probe.py
M fixtures/workshop_project/mob_ci_143/source.json
M fixtures/workshop_project/mob_ci_143/stabs/stab_y_agregat_bez_checkout.py
A fixtures/workshop_project/mob_ci_143/stabs/stab_y_bez_chistki.py
A fixtures/workshop_project/mob_ci_143/stabs/stab_y_chuzhoj_put.py
A fixtures/workshop_project/mob_ci_143/stabs/stab_y_chuzhoj_ref.py
A fixtures/workshop_project/mob_ci_143/stabs/stab_y_git_v_run.py
A fixtures/workshop_project/mob_ci_143/stabs/stab_y_glubina_fetch.py
A fixtures/workshop_project/mob_ci_143/stabs/stab_y_token_ostaetsja.py
A fixtures/workshop_project/mob_ci_143/stabs/stab_y_verify_ne_sha.py
A fixtures/workshop_project/mob_ci_143/stabs/stab_y_verify_pozdnij.py
A fixtures/workshop_project/mob_ci_143/stabs/stab_y_verify_udalen.py
A fixtures/workshop_project/mob_ci_143/stabs/stab_y_vtoroj_checkout.py
rc=0; вне fixtures/workshop_project/mob_ci_143/: 0 в обоих коммитах
$ git diff --exit-code 7258ff95 987f84cf -- contracts/143-mob-ci-razdelenie.md
[пусто]
rc=0
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --model
клеток 69, зелёных 69, красных 0
model_rc=0
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs
клеток 69, зелёных 69, красных 0
стабов 43, привязок 59, непойманных 0
stabs_rc=0
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Adv143/mob
клеток 69, зелёных 68, красных 1
КЛЕТКА y19-outputs-provodka: build-apk: сборка без checkout продукта первым шагом (needs не переносит checkout и не закрепляет runner — переиспользуемый раннер собирает остаточный workspace старой ревизии) КРАСНА
product_rc=1
```

Атаки: `python3 /tmp/dev-harness-verify/attack143y.py` (одноразовый генератор отдельных копий `model/` в `/tmp/dev-harness-verify/Crit143y-attacks/`, меняет ТОЛЬКО mobile.yml субъекта, PyYAML safe_dump; команда каждой проверки выведена самим генератором). Сырые результаты по каждому субъекту:
```
COMMAND=bash /tmp/dev-harness-verify/Crit143y/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Crit143y-attacks/wrong-ref
клеток 69, зелёных 68, красных 1
КЛЕТКА y19-outputs-provodka: build-apk: checkout с ref: 'refs/heads/main' — чужая ревизия вместо проверяемой (позиция 0) КРАСНА
CASE=wrong-ref rc=1
COMMAND=bash /tmp/dev-harness-verify/Crit143y/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Crit143y-attacks/second-checkout
клеток 69, зелёных 68, красных 1
КЛЕТКА y19-outputs-provodka: build-apk: второй checkout (позиция 2) подменяет рабочее дерево сборки КРАСНА
CASE=second-checkout rc=1
COMMAND=bash /tmp/dev-harness-verify/Crit143y/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Crit143y-attacks/expression-ref
клеток 69, зелёных 68, красных 1
КЛЕТКА y19-outputs-provodka: build-apk: checkout с ref: '${{ github.event.repository.default_branch }}' — чужая ревизия вместо проверяемой (позиция 0) КРАСНА
CASE=expression-ref rc=1
COMMAND=bash /tmp/dev-harness-verify/Crit143y/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Crit143y-attacks/verify-or-true
клеток 69, зелёных 69, красных 0
CASE=verify-or-true rc=0
COMMAND=bash /tmp/dev-harness-verify/Crit143y/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Crit143y-attacks/verify-continue-on-error
клеток 69, зелёных 68, красных 1
КЛЕТКА y05-net-continue-on-error: есть continue-on-error КРАСНА
CASE=verify-continue-on-error rc=1
COMMAND=bash /tmp/dev-harness-verify/Crit143y/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Crit143y-attacks/verify-if-false
клеток 69, зелёных 69, красных 0
CASE=verify-if-false rc=0
COMMAND=bash /tmp/dev-harness-verify/Crit143y/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Crit143y-attacks/verify-false-positive
клеток 69, зелёных 69, красных 0
CASE=verify-false-positive rc=0
COMMAND=bash /tmp/dev-harness-verify/Crit143y/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Crit143y-attacks/git-worktree
клеток 69, зелёных 69, красных 0
CASE=git-worktree rc=0
COMMAND=bash /tmp/dev-harness-verify/Crit143y/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Crit143y-attacks/git-worktree-repoint
клеток 69, зелёных 69, красных 0
CASE=git-worktree-repoint rc=0
COMMAND=bash /tmp/dev-harness-verify/Crit143y/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Crit143y-attacks/git-c-switch
клеток 69, зелёных 68, красных 1
КЛЕТКА y19-outputs-provodka: build-apk: run-шаг меняет рабочее дерево git-командой «git … switch» (позиция 3) КРАСНА
CASE=git-c-switch rc=1
COMMAND=bash /tmp/dev-harness-verify/Crit143y/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Crit143y-attacks/git-checkout-B
клеток 69, зелёных 68, красных 1
КЛЕТКА y19-outputs-provodka: build-apk: run-шаг меняет рабочее дерево git-командой «git … checkout» (позиция 3) КРАСНА
CASE=git-checkout-B rc=1
COMMAND=bash /tmp/dev-harness-verify/Crit143y/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Crit143y-attacks/verify-env-override
клеток 69, зелёных 69, красных 0
CASE=verify-env-override rc=0
COMMAND=bash /tmp/dev-harness-verify/Crit143y/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Crit143y-attacks/verify-wrong-dir
клеток 69, зелёных 69, красных 0
CASE=verify-wrong-dir rc=0
```
Последние `verify-env-override`/`verify-wrong-dir` — только зелень статической батареи, не объявлены доказанным runtime-обходом (подстановка в env не выполняется shell, несуществующий cwd сам краснит GitHub job); `git-worktree` с одним `cd elsewhere` также не объявлен runtime-обходом (следующий шаг снова исполняется в своём cwd). Для `git-worktree-repoint` выполнена дополнительная адресная атака: исправлена полезная нагрузка так, чтобы НЕ копировать `.git`-файл нового worktree поверх `.git`-каталога основного, а копировать чужие исходники `mobile/`:
```
$ python3 -c 'import yaml,pathlib; p=pathlib.Path("/tmp/dev-harness-verify/Crit143y-attacks/git-worktree-repoint/.github/workflows/mobile.yml"); w=yaml.safe_load(p.read_text()); s=w["jobs"]["build-apk"]["steps"]; s[3]["run"]="git worktree add --detach elsewhere refs/heads/main && cp -a elsewhere/mobile/. mobile/"; p.write_text(yaml.safe_dump(w,sort_keys=False,allow_unicode=True))' && bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Crit143y-attacks/git-worktree-repoint
клеток 69, зелёных 69, красных 0
worktree_source_copy_rc=0
$ GITHUB_SHA=expected bash -c 'test "$(printf other)" = "$GITHUB_SHA" || true'
masked_assertion_rc=0
$ GITHUB_SHA=expected bash -c 'if false; then test "other" = "$GITHUB_SHA"; fi'
skipped_assertion_rc=0
```
Проверка модели и дверей:
```
$ python3 -c 'import yaml,pathlib; p=pathlib.Path("fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml"); w=yaml.safe_load(p.read_text()); b=w["jobs"]["build-apk"]["steps"]; print("YAML_OK jobs=%d first=%s second=%s checkouts=%d"%(len(w["jobs"]),b[0]["uses"],b[1]["run"],sum(str(s.get("uses","")).startswith("actions/checkout") for s in b))); print("workers=%d same_build_needs=%s"%(sum(k.startswith("e2e-") for k in w["jobs"]),all("build-apk" in w["jobs"][k].get("needs",[]) for k in w["jobs"] if k.startswith("e2e-"))))'
YAML_OK jobs=10 first=actions/checkout@v7 second=test "$(git rev-parse HEAD)" = "$GITHUB_SHA" checkouts=1
workers=5 same_build_needs=True
rc=0
$ python3 -c 'import yaml,pathlib; w=yaml.safe_load(pathlib.Path("fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml").read_text())["jobs"]; names=[j for j in w if j.startswith("e2e-")]; bad=[]; lines=[];[(lines.append((j, next((s.get("run","") for s in w[j]["steps"] if "ZHELANYJ_DIGEST" in s.get("run","")), ""))) for j in names)];[(bad.append(j)) for j,run in lines if "APK_DIGEST_RASKHOZHDENIE" not in run or "needs.build-apk.outputs.artifact_name" not in str(w[j]["steps"])];print("workers=%d digest_bad=%s"%(len(names),bad))'
workers=5 digest_bad=[]
rc=0
$ bash scripts/pre_critic.sh --repo . contracts/143-mob-ci-razdelenie.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=4
КРИТИК: дверь зелёная
pre_critic_rc=0
$ bash scripts/check_precision_gate.sh . contracts/143-mob-ci-razdelenie.md
OK
precision_rc=0
$ bash scripts/check_spec_ready.sh . contracts/143-mob-ci-razdelenie.md
OK
spec_ready_rc=0
$ bash scripts/check_ceilings.sh .
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 139 черновик(ов) судится, замороженные — по тегам
потолки в порядке
ceilings_rc=0
$ bash scripts/check_threat_model.sh . contracts/143-mob-ci-razdelenie.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 9 буллет(ов), НЕ ЗАЩИЩАЕТ 9 буллет(ов))
threat_model_rc=0
$ bash scripts/check_predposylki.sh . contracts/143-mob-ci-razdelenie.md
PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=4
predposylki_rc=0
$ bash scripts/check_contract_frozen.sh .
  ok   contracts/143-mob-ci-razdelenie.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают
планов и контрактов на HEAD: 143 · черновиков: 3 · заморожено: 140 · реестр: full
frozen_rc=0
$ bash scripts/check_zones.sh .; printf 'check_zones_rc=%s\n' "$?"   # ПОСЛЕДНИЙ gate, timeout=1200, [async-result], полный сырой вывод artifact://13890
процессных вне суда:
замороженных контрактов: 142 · объявленных авторов: 5 · коммитов в диапазонах: 37558 · проверено по зонам: 8398
check_zones_rc=0
```
СОВЕТ fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml:404-411 — эталонный YAML синтаксически парсится и задаёт честный `checkout@v7`/проверку `HEAD == $GITHUB_SHA`; тот же digest в пяти работниках по outputs проверяется. Сама правильная модель не закрывает зелёные контрпримеры к батарее: implementer скопирует модель в продукт PR #136, но батарея должна отвергать иные исполняемые деревья субъекта.

НЕ ПРОВЕРЕНО: живой CI продукта PR #136, runner slots, сборка/загрузка/установка APK, фактическая настройка required branch protection; не запускались gh run, push, commit, actionlint (бинаря нет). Статический YAML-pass, shell-проверка маскируемого assertion и локальный запуск батареи — не замена будущего живого CI после правки implementer. Вердикт локальный по прямому запрету commit/push задания; оригинальная ветка architect и frozen-контракт не менялись.
