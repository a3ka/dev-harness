FAIL

# Вердикт adversary: контракт 103, PR #96, v2

Проверен PR #96, head `3936e0613ed78cc7f8fa4094d23ae169be5f4f9a`
(`wip/103/implementer2`), base `main`, в одноразовом SSH-клоне
`/tmp/dev-harness-verify/adversary103-1792065764384817580`. Push не выполнялся.

**Модель моей роли:** `adversary` из семейства исполнения — строю живой
мутант субъекта и требую, чтобы батарея его отвергла. **Модель автора:**
`implementer` из семейства реализации — меняет четырёх потребителей и
CI-строку. Семейства различны, поэтому авторская рамка не наследовалась.

## Снимок и честный контроль

```text
git rev-parse HEAD
# 3936e0613ed78cc7f8fa4094d23ae169be5f4f9a

git rev-parse 3936e0613ed78cc7f8fa4094d23ae169be5f4f9a:contracts/103-profilnye-puti-vmesto-harness-layout.md
# 429c079daddf0dd53b3332ca285ff16ef7875896
git rev-parse frozen/contracts/103/1:contracts/103-profilnye-puti-vmesto-harness-layout.md
# 429c079daddf0dd53b3332ca285ff16ef7875896
git merge-base --is-ancestor frozen/contracts/103/1 3936e0613ed78cc7f8fa4094d23ae169be5f4f9a
# rc=0
```

`gh pr checks 96` предъявил все 12 checks как `pass`.

Честный контроль на голове пройден:

```text
bash fixtures/_krasnye_103.sh
# ИТОГ стаб-пак 103: rc=0; 11 клеток rc=0; ИТОГ 103: rc=0

bash fixtures/_krasnye_103.sh --model
# ИТОГ стаб-пак 103: rc=0; 11 клеток rc=0; ИТОГ 103: rc=0
```

В частности, стаб-пак поймал 14/14 собственных мутаций (`s1`…`s14`).

## BLOCKS — A103-1: батарея не проверяет приоритет `--layer-root` над окружением

Контракт в Frontier И-4 задаёт точный порядок источника слоя проекта:

```text
--layer-root > HARNESS_PROJECT_LAYER_ROOT > R
```

Однако все клетки стандарта вызывают субъект только с
`HARNESS_PROJECT_LAYER_ROOT="$R"`; ни одна не передаёт одновременно явный
`--layer-root` и конфликтующее окружение. Поэтому батарея не отличает
корректный приоритет от ошибочного «env всегда побеждает CLI».

### Исполненный мутант («нейтрализация через env»)

В отдельном worktree от head в `scripts/check_project_standard.sh` заменена
ровно инициализация слоя:

```bash
# честно
[ -n "$LAYER" ] || LAYER="${HARNESS_PROJECT_LAYER_ROOT:-$R}"

# мутант
LAYER="${HARNESS_PROJECT_LAYER_ROOT:-${LAYER:-$R}}"
```

Мутант нарушает И-4: при явном `--layer-root L` он вместо `L` читает слой из
`HARNESS_PROJECT_LAYER_ROOT`. Это правдоподобная ошибка при склейке двух
источников конфигурации; остальные проверки субъекта оставлены исходными.

Несмотря на нарушение, вся реальная батарея против мутанта зелёная:

```text
cd /tmp/dev-harness-verify/adversary103-1792065764384817580-mutant
bash fixtures/_krasnye_103.sh
# ИТОГ стаб-пак 103: rc=0
# — red_brief_iz_profilnogo_puti.sh: rc=0
# — red_frozen_iz_profilnogo_puti.sh: rc=0
# — red_frozen_koren_ne_istochnik.sh: rc=0
# — red_kontrakt_iz_profilnogo_puti.sh: rc=0
# — red_koren_harnesa_ne_istochnik.sh: rc=0
# — red_pre_critic_cwd.sh: rc=0
# — red_puti_vne_repo.sh: rc=0
# — red_spawn_reestr_proekta.sh: rc=0
# — red_standart_etalon.sh: rc=0
# — red_standart_narushenija.sh: rc=0
# — red_standart_polnyj_nabor.sh: rc=0
# ИТОГ 103: rc=0
```

Проба на эталонном мире Complior отделяет честную реализацию от мутанта.
Оба запуска получают годный явный слой `--layer-root "$REPO"`; окружение
умышленно указывает на несуществующий `$WORLD/hostile-layer`.

```text
# голова
bash priority_probe_103.sh scripts/check_project_standard.sh
# target=scripts/check_project_standard.sh rc=0

# мутант
cd /tmp/dev-harness-verify/adversary103-1792065764384817580-mutant
bash /tmp/dev-harness-verify/adversary103-1792065764384817580/priority_probe_103.sh scripts/check_project_standard.sh
# target=scripts/check_project_standard.sh rc=1
# ОТКАЗ: стандарт: profil: слой проекта не найден: .harness/registry/harness-project.json
```

Это именно дыра батареи, не дефект мутанта: корректный субъект на том же
живом мире зелёный, а субъект, отвечающий на другой источник слоя, проходит
все 11 клеток и 14 стабов.

### Необходимое закрытие

В `fixtures/project_paths_103/` добавить клетку для конфликта источников:

1. создать Complior-мир с годным слоем в `R`;
2. передать `--layer-root R` и `HARNESS_PROJECT_LAYER_ROOT=<несуществующий>`;
3. требовать rc 0;
4. добавить стаб, меняющий приоритет на `env > CLI`, и требовать, чтобы
   поймала именно эта клетка.

## BLOCKS — A103-2: пустой путь репозитория возвращает rc=1, хотя контракта требует rc=2

Для стандарта контракт задаёт `rc 2 — нечем проверить (нет репо/jq)`.
Пустое значение `--repo` — это отсутствие репо, но фактическая подстановка
`${2:?}` аварийно завершает shell до ветви, печатающей
`NOT_IMPLEMENTED: нет репо`:

```text
bash scripts/check_project_standard.sh --repo ""; printf 'rc=%s\n' "$?"
# scripts/check_project_standard.sh: line 31: 2: parameter null or not set
# rc=1
```

Это самостоятельное нарушение заявленной классификации rc; существующие
клетки подают только непустой годный путь и его не предъявляют.

## Исполненные прямые пробы

- **Инструмент мимо PATH:**

  ```text
  PATH=/__pp103_no_path /bin/bash scripts/check_project_standard.sh --repo .
  # NOT_IMPLEMENTED: нет jq
  # rc=2
  ```

  Отсутствующий `jq` не объявлен успехом: fail-closed работает.

- **Нейтрализация через env без CLI:** на эталонном мире
  `HARNESS_PROJECT_LAYER_ROOT="$WORLD/hostile-layer"` без `--layer-root`
  вернуло ожидаемый отказ, а не ложный rc=0:

  ```text
  target=scripts/check_project_standard.sh rc=1
  ОТКАЗ: стандарт: profil: слой проекта не найден: .harness/registry/harness-project.json
  ```

- **Позитивный контроль:** честный субъект прошёл и полную батарею, и
  конфликтную пробу с приоритетом `--layer-root` (rc=0), приведённые выше.

Норма и её frozen-блоб не изменялись. Исправление A103-1 принадлежит зоне
architect (семья и раннер), исправление A103-2 — зоне implementer
(`scripts/check_project_standard.sh`).
