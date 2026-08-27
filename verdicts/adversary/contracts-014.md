accept

# Контракт 014 v2 — адверсарный круг реализации

Проверено на исходном `HEAD df010eb`. Рабочее дерево предмета и пробы не
менялись: каждый мутатор был отдельной минимальной копией в
`/tmp/adversary014/<имя>/`, где неизменёнными остались проба и все остальные
байты раннера. В каждом случае изменено ровно одно правило, то есть это не
«всегда красный» заменитель, а исходный честный фильтр с одним нарушенным
инвариантом.

## Положительный контроль

```sh
bash fixtures/verify_antiplacebo/probe_tmpdir_raven_koren.sh
```

→ `rc=0`; зелены все 14 сообщений: обычные восемь ветвей, две проверки
корня `/tmp` и две транс-проверки с терминальным маркером.

## Обманные реализации — все пойманы

Команды ниже запускались из соответствующего `/tmp`-корня. Каждый прогон
возвратил `rc=1`; следовательно, ни один неверный раннер не прошёл пробу.

1. **`lexical-tmpdir`** — единственная подмена: база берётся как
   `${TMPDIR:-/tmp}`, без `canonicalize_path`. Это нарушение единой
   канонической меры (в частности, TMPDIR через симлинк внутрь корня).

   ```sh
   (cd /tmp/adversary014/lexical-tmpdir && \
     bash fixtures/verify_antiplacebo/probe_tmpdir_raven_koren.sh)
   ```

   → красные `симлинк-внутрь`, `алиасы-хеша` и
   `tmp-симлинк-внутрь-корня`; последний получил именно общий страж вместо
   именованного отказа. Неверная ветка не была принята за успех.

2. **`lexical-hash`** — единственная подмена: `HASH8` вычисляется от
   лексического `$ROOT`, не от `$ROOT_CANON`.

   ```sh
   (cd /tmp/adversary014/lexical-hash && \
     bash fixtures/verify_antiplacebo/probe_tmpdir_raven_koren.sh)
   ```

   → красная ровно вторая ветвь `алиасы-хеша`: предсказанный канонический
   путь скратча не наблюдался (`seen=0`). Это положительная нейтрализация:
   годный прогон по прямому имени остался зелёным, нарушенный алиас — красным.

3. **`premature-mkdir`** — единственная подмена: до выбора базы добавлен
   `mkdir -p "${TMPDIR:-/tmp}"`.

   ```sh
   (cd /tmp/adversary014/premature-mkdir && \
     bash fixtures/verify_antiplacebo/probe_tmpdir_raven_koren.sh)
   ```

   → красная ровно `без-mkdir`: несуществующий
   `TMPDIR=$W/novyj` материализован внутри стерегомого дерева. Остальные
   контрольные ветви зелены.

4. **`generic-refusal`** — единственная подмена: условие именованного
   отказа проверяет только пустую запасную базу и больше не отклоняет
   запасную базу, канонически лежащую внутри корня. Дальше срабатывает общий
   страж явного scratch.

   ```sh
   (cd /tmp/adversary014/generic-refusal && \
     bash fixtures/verify_antiplacebo/probe_tmpdir_raven_koren.sh)
   ```

   → красные `корень-tmp` и `tmp-симлинк-внутрь-корня`: оба увидели rc=2, но
   проба отвергла чужой текст общего стража и отсутствие именованного отказа
   инварианта 2.

5. **`transient-create`** — единственная подмена: непосредственно перед
   именованным отказом создаётся и тут же удаляется
   `$ROOT_CANON/.adversary014-transient-$$`. Остальная логика раннера честна.

   ```sh
   (cd /tmp/adversary014/transient-create && \
     bash fixtures/verify_antiplacebo/probe_tmpdir_raven_koren.sh)
   ```

   → красные обе транс-ветви: `корень-tmp-транс` и
   `tmp-симлинк-транс` получили `MON-EVENT создание путь
   .adversary014-transient-…`. Значит финальный слепок не маскирует
   create+remove до отказа, а терминальный монитор действительно участвует.

Итого: построены и исполнены 5 собственных обманных реализаций (требуемый
минимум — 4); все были пойманы. Блокирующего обхода не найдено.

## За границей модели угроз

Вооружённая реализация, которая ищет/убивает монитор либо подделывает файл
`MON-EVENT` и выдаёт чужое событие за терминальный маркер, — `cognitive-only`
риск, прямо исключённый владельцем и контрактом. Он не является находкой
этого круга и не меняет `accept`: текущая проба в пределах модели требует
точный `MON-EVENT создание путь .probe014-mark-<метка>` и отвергает любое
чужое событие как `others`.

## Scoped-регресс и заморозка

```sh
bash scripts/check_runner_hygiene.sh . scratchdef
bash scripts/check_runner_hygiene.sh . lockdef
bash scripts/check_runner_hygiene.sh . techka
bash fixtures/verify_antiplacebo/probe_tmpdir_raven_koren.sh
bash scripts/check_contract_frozen.sh .
git diff --no-ext-diff --exit-code \
  frozen/contracts/014/2:contracts/014-default-skratch-vne-dereva-pri-tmpdir.md \
  HEAD:contracts/014-default-skratch-vne-dereva-pri-tmpdir.md
```

Все шесть команд дали `rc=0`. Scoped-ветви 011/012 подтвердили соответственно
внешний default-scratch, общий lock default-scratch и очистку созданного
каталога; `check_contract_frozen` подтвердил 014 v2, а последний diff пуст.
