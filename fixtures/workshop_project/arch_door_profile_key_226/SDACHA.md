# СДАЧА 226 — профильная дверь архитектуры

Обещание: политика hooks.archBrief вместо селектора имени и адреса продукта. Наблюдение: полный CLI на настоящих Git/Node/профильных мирах, раздельные stdout/stderr, HEAD/refs/файлы и отдельно argv gh. Ожидания литеральны и в памяти до субъекта. База 5b8ae0cdca9429d9d651c19d2775016e57ce271f; production/реестры/CI/чужие фикстуры в сдаче не изменены. Эталонные изменения последних лежат только в model/ для будущего implementer.

Frontier: repo-only hooks.archBrief = false либо owner/repo; нет ключа — выключено, неверное значение/битый профиль — отказ. Resolver валидирует до profile_get; PRODUCT_REPO env не используется. Backend-ключ — отдельный PR в его harness.project.json до установки 226, не файл станции. Это определённый заданием выбор доставки, не выдуманная санкция владельца.

КЛЕТКИ: 45. МУТАЦИИ: 15. СВЯЗИ: 18. Носители: 23 (8 честных файлов, 15 изменённых); shell-носители вместе с обёрткой: 22. Другие меры: CASES/probe.py и MUTATIONS/build.py; source.json с sha256 и связями; --stabs реально исполняет каждую связь. Батарея 203: 21 клетка; прежний pin186: 5 клеток. Полный --regression на честном overlay дал rc 0 для обеих семей без изменения их ожиданий.

## Двери

- Red-do · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --repo . · 1 · 1
- Model · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --model · 0 · 0
- Stabs · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --stabs · 0 · 0
- Sintaksis · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --sintaksis · 0 · 0
- Catalog · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --catalog · 0 · 0
- Regression · bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh --regression · 0 · 0
- Context · fixtures/workshop_project/arch_door_profile_key_226/context.py · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/226-arch-door-profile-key.md · 0 · 0
- Spec-ready · bash scripts/check_spec_ready.sh . contracts/226-arch-door-profile-key.md · 0 · 0
- Threat-model · bash scripts/check_threat_model.sh . contracts/226-arch-door-profile-key.md · 0 · 0
- Predposylki · bash scripts/check_predposylki.sh . contracts/226-arch-door-profile-key.md · 0 · 0
- Ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- Ids · bash scripts/check_ids.sh . · 0 · 0
- Provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/226-arch-door-profile-key.md · 0 · 0
- CI-canon · bash scripts/gen_ci_steps.sh --check · 0 · 0

## Карта классов

- К-01 · чисто · вход: двери листа, тип кодовый, рисковый процессный страж; никакой production до freeze · - · -
- К-02 · чисто · вход: R-0103/R-0102 и Л10 плана; другие ключи Ш-5 не входят · - · -
- К-03 · чисто · вход: 203/1 187/3 170/1 188/2 186/2 193/3 184/1 996/2; явная миграция профилей миров без смены ожиданий · - · -
- К-04 · чисто · вход: context.py --sources/--emit, высшие frozen, точные зоны и отдельный backend PR · - · -
- К-05 · чисто · вход: W --model; поля JSON судит существующий resolver, HTTP-шов только metadata · - · -
- К-06 · чисто · вход: ошибки среды/носителя rc 2; INVALID_MUTANT не засчитывает инфраструктурный отказ как поимку · - · -
- К-07 · чисто · вход: полный make_task и pin CLI, реальные объекты pin/HEAD/merge; честный --model 45/0 · - · -
- К-08 · чисто · вход: W --stabs, 15 копий/18 отдельно исполненных связей; игнорирование ключа, ноль, регистр, длина и подстроки · - · -
- К-09 · чисто · вход: отсутствие/false и backend без ключа; bad-null/zero/one/true/array/object/string-false/empty/NUL/LF/space/slashes; минимальный, длинный, смешанный регистр · - · -
- К-10 · чисто · вход: rc и диагностика в stderr, пустой stdout отказа, отсутствие тегов/изменения HEAD, байты файлов pin-мира · - · -
- К-11 · чисто · вход: ожидания CASES в памяти; gh-calls — наблюдение argv, не источник ожидаемого repo; хеши носителей до субъекта · - · -
- К-12 · чисто · вход: настоящий jq/resolver, git plumbing, node, bash -n и пинованный shellcheck JSON differential; не двойник валидатора · - · -
- К-13 · н/п · новых секретов/сетевых разрешений нет, батарея offline; существующий gh-субъект прежний · - · -
- К-14 · чисто · вход: minimal/mixed-case/long-value, explicit-false, backend-brief, legacy-local и unknown-sibling с предупреждением М-0 · - · -
- К-15 · чисто · вход: catalog 45/15/18 и carriers 23; отдельные model/stabs/regression как другая мера · - · -
- К-16 · чисто · вход: смена ключа на одном мире и независимый журнал product PR argv; М-0 не отменён, backend cutover требует профиль проекта · - · -
- К-17 · н/п · станционный конфигурационный предмет, продуктовую модель/writers/isolationKeys не меняет · - · -

## Сырые результаты до формальных дверей

W --repo .: rc 1, KLETKI 45 KRASNYH 35. Именованные красные: backend-absent/backend-false, other-enabled/mixed-case/long-value/minimal-value/with-component, неконформные известные значения, публичные bad-door/bad-freeze/bad-done, merged/sibling, профильный pin и literal-free/key-toggle. Зеленые контроли включают backend-enabled/backend-brief/pin-backend, иные проекты без ключа/с false, документный класс, legacy и отсутствие пина.

W --model: rc 0, KLETKI 45 KRASNYH 0. W --stabs: rc 0, SVJAZI 18 ZHIVYH 0. W --regression: rc 0, CELLS=21 FAILURES=0, pin186 5/5. Последовательный суммарный вызов model/stabs/regression занял 129.12 с, не выдаётся за замер отдельной команды.

W --sintaksis: rc 0, SINTAKSIS 22 SHELLCHECK_DIFFERENTIAL 6 BASELINE_DIAGNOSTICS 30. Новый wrapper прошёл validate_std; остальные шесть скриптов сравниваются с именованной базой по code/message/source-line, без исключения кодов, флагов подавления и исправления чужих диагностик. Первый полный shellcheck был красен на inherited 2034/2043/1003/2317 резолвера; новый реальный 2034 в pin import устранён inline assignment при source. Это не заявление, что весь прежний код lint-чистый.

Первый мутант pin-constant давал rc 2 от строгого HTTP-двойника, поэтому НЕ был засчитан. Проверка исправлена по причине: metadata-шов допускает любой product repo при том же PR, отдельно логирует настоящий argv. После этого адресные pin-constant/env/case копии возвращают обычный результат команды, но краснеют по PRODUCT_REPO_DEPENDENCY, а честный контроль зелён. Исполняемая связь остаётся в build.py/source.json, не в контракте.

## Наблюдение процесса

Runtime isolated-копия отличается от WORKTREE-адреса доставки задания; пишется только собственная копия, ведущему передаются фактические pwd/sha, push не выполняется. Журнал NABLIUDENIA_ARCHITECT.md в wip не правится. Кандидат наблюдения для записи main без самовольного А-номера: строгий сетевой двойник может превращать содержательную ошибку адресации в infra rc 2 и делать обманку невалидной. Источник — первый --stabs st12, цена один прогон 65.59 с. Закрыто наблюдением argv независимо от metadata-ответа и полным повтором честного/адресных контролей. Другой нового класса процесса для следующей пачки не выявлено.

## Финальные двери

Чистый сетевой клон в `tmp/clean226` внутри собственной isolated-копии, база та же; remote только origin=ssh://git@github.com/a3ka/dev-harness.git. В него перенесён только scoped-кандидат (контракт и семья), без чужих remotes/контекста сессии. Полные проверки запускались последовательно, не параллельно, с VALIDATE_STD_SHELLCHECK и SDACHA_TIMEOUT_SEK=600 / SDACHA_BUDZHET_SEK=2400; TMPDIR внутри клона.

`bash scripts/pre_critic.sh contracts/226-arch-door-profile-key.md` → rc 0, `КРИТИК: дверь зелёная`. Затем отдельным вызовом `bash scripts/check_sdacha.sh . contracts/226-arch-door-profile-key.md --run` → rc 0, `СДАЧА: лист зелёный (двери=15 карта=17/17 дельта=0)`. Суммарная стена обоих вызовов 427.63 с; таймаута не было. Слова «красна/красен» после `ok` в логе pre_critic — его статические подписи ног, не ненулевые rc.

Первый pre_critic отказал до прогона листа: его CLI-грамматика допускает bash-файл либо исполняемый путь, не `python3 файл`. В строке Context заменена только форма запуска на собственный executable context.py; повтор полного pre_critic и отдельный check_sdacha выше зелёные. Двери/порог/семантика не выключались. Временный проверочный драйвер и клон не входят в сдачу.
