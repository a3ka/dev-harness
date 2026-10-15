BLOCKS

Предмет: `origin/wip/097/architect` @ `8ac9e0be57a6e1002afd8121e667e90665ae98b0`. Контракт сверен с frozen `frozen/contracts/097/1`; судится семья `fixtures/_krasnye_097.sh` и восемь клеток `fixtures/prepare_object_097/` на этой ревизии.

## Блокер А-1/А-2: отказ успешного `prepare` принимается за успех

Независимый мутант `tmp/adversary097-policy-change-rc1.sh` в точности делегирует честной модели всю работу и её stdout, но после успешного `prepare` возвращает `rc=1`, если policy-carriers кандидата отличаются от base (`registry/ci-steps.tsv`, `harness.project.json` или `harness/policy`). Это не неконформный случай: именно такие различия являются положительными входами А-1 и А-2.

Отдельная живая проба А-1 построила base и кандидата, который сузил список шагов и расширил allowlist, затем вызвала мутант. Наблюдено:

```text
PROOF valid candidate policy change refused: rc=1 merge=59ef7a54cd9d38f261d18c0dfd65adf43ad8c501
```

То есть M корректно создан и напечатан, но команда отказала. А-1 и А-2 сохраняют `$rc`, но проверяют только формат stdout; обязательного `[ "$rc" -eq 0 ]` нет. Поэтому их собственные прогоны завершились зелёно с этим неверным субъектом. Все восемь клеток были отдельно запущены против него с `AP097_MODE=model`, `AP097_ROOT=.` и `AP097_SUBJECT=tmp/adversary097-policy-change-rc1.sh`; каждая вернула `rc=0`.

Воспроизводимая форма, например:

```sh
bash tmp/adversary097-policy-change-rc1-probe.sh
# PROOF valid candidate policy change refused: rc=1 merge=<40-hex>
env AP097_MODE=model AP097_ROOT=. \
  AP097_SUBJECT=tmp/adversary097-policy-change-rc1.sh \
  bash fixtures/prepare_object_097/red_kandidat_ne_vybiraet_politiku.sh
# rc=0
```

Нужно требовать `rc=0` до принятия stdout на каждой положительной пробе `prepare`, прежде всего А-1, А-2, А-3, А-6 и А-7. Это не проверка формата ошибки: отрицательная команда с валидным SHA уже наблюдаемо проходит А-1/А-2.

## Блокер И-0: пустой `targetBranches=` принимается

Независимый мутант `tmp/adversary097-empty-targetbranches.sh` — копия модели с ровно одним ослаблением грамматики: присутствующее `targetBranches=` сохраняет непустой внутренний маркер, так что оно проходит проверку наличия поля, но отсутствующий ключ по-прежнему отвергается. Все остальные ветви модели неизменны.

На отдельном проектном toy-мире в принятом base была политика:

```text
repoId=toy-proj-097
mandatory=p-a,p-b
targetBranches=
```

Контрактная демаркация прямо относит пустой CSV-компонент к неконформным. Однако мутант успешно создал M:

```text
PROOF empty targetBranches accepted: rc=0 merge=0fe99971338cbffb1777b72b87cc1e42b799e81d
```

Затем каждая из восьми клеток отдельно была запущена с этим субъектом и вернула `rc=0`, включая А-6: она ловит *отсутствующий* ключ, но не присутствующий пустой компонент. А-5 проверяет пустой `mandatory=`, ветку вне алфавита и чужую строку, но не `targetBranches=`.

Воспроизводимая форма:

```sh
bash tmp/adversary097-empty-targetbranches-probe.sh
# PROOF empty targetBranches accepted: rc=0 merge=<40-hex>
env AP097_MODE=model AP097_ROOT=. \
  AP097_SUBJECT=tmp/adversary097-empty-targetbranches.sh \
  bash fixtures/prepare_object_097/red_oba_profilya.sh
# rc=0
env AP097_MODE=model AP097_ROOT=. \
  AP097_SUBJECT=tmp/adversary097-empty-targetbranches.sh \
  bash fixtures/prepare_object_097/red_politika_bez_targetbranches.sh
# rc=0
```

Нужна отрицательная проба с буквально `targetBranches=` (как минимум на проектном профиле; по заявленной А-5 грамматике — на обоих профилях), требующая именованный `rc=1` `политика: грамматика` и неизменность refs.

## Проверка закрытых v2 и независимые контроли

- Положительный контроль: `bash fixtures/_krasnye_097.sh --model` вернул `rc=0`: все восемь клеток зелёны, `m0` зелёный, `m1`–`m19` пойманы. В частности вывод содержит `— стаб m18 ПОЙМАН клеткой red_oba_profilya.sh` и `— стаб m19 ПОЙМАН клеткой red_oba_profilya.sh`.
- Красный контроль отсутствующего предмета: `bash fixtures/_krasnye_097.sh` вернул `rc=1`, восемь именованных `предмет отсутствует`, а стаб-пак — `rc=0`.
- Новый А-5 действительно больше не сравнивает stdout проектного `prepare` только с literal base: в положительной пробе проверяются родители напечатанного SHA (`base candidate`) и его tree против независимого `merge-tree`-оракула. Мутант, печатающий base, ловится `m18`.
- Дополнительно был построен мутант, который в проектном профиле печатает другой commit с теми же родителями и tree, но identity `adversary`. Проба наблюдала `identity=adversary <adversary@dev-harness.local> / adversary <adversary@dev-harness.local>`; А-5 его структурно принимает, но А-7 (проектный профиль) ловит с `КРАСНО: a7: identity merge нарушен (016)`. Полный набор поэтому не обходится этим вариантом.
- `m19` строится через `build_stub`: уникальный исполняемый якорь parser-строки `mandatory=*) ... case "$v" in ''|`, `sed`-порча и `cmp` с моделью. Это кодовая, не комментарийная привязка. `m18` не является порчей модели по якорю: код прямо объявляет его «обёртка ... ВНЕ порчи по якорю», а `sudit_obertku` проверяет только marker/executable и затем поведение клетки. Функционально m18 пойман, но утверждение §Приёмки «порча по якорю `# t97-mN`» для него буквально не выполнено; это надо либо привести к якорной порче, либо явно оформить как исключение в норме.

Мутанты и throwaway-пробы не входят в коммит: это вердикт о дырках проверки, не правка предмета или клеток.
