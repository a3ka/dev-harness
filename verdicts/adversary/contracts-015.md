FAIL

Судился контракт 015 v1 и реализация живого дерева; стаб-копия: `/tmp/adv015.mTJpUP/repo`. Предмет и проверка не менялись. Найдены два проходящих обманных субъекта: при их фактически неверном поведении scoped-приёмка остаётся зелёной. Причина общая: `drill_gate_draft.sh` и `drill_startup_digest.sh` выбирают проверяемый сценарий по известным строковым маркерам в исходнике. Нестандартный стаб без такого маркера объявляется `real`; его «зелёная» ветвь проверяет лишь один успешный вызов (drafter) либо только `rc=0` (digest), затем case подменяют субъект известными стабами и успешно проверяют уже их.

## Находки, воспроизведённые в /tmp

1. **FAIL — черновик без дедупа проходит scoped-приёмку.** Заменён `scripts/draft_nabludenia.sh` стабом без маркера сценария: каждый вызов создаёт `draft-$RANDOM-$$.md`, всегда с `повторов: 1`.

   ```sh
   cd /tmp/adv015.mTJpUP/repo
   d=$(mktemp -d /tmp/adv015-dedup.XXXXXX)
   TMPDIR="$d" bash scripts/draft_nabludenia.sh scripts/check_charter.sh 'FAIL charter: adversary'
   TMPDIR="$d" bash scripts/draft_nabludenia.sh scripts/check_charter.sh 'FAIL charter: adversary'
   bash scripts/verify_antiplacebo.sh --scope drill_gate_draft
   ```

   Два файла наблюдались (`draft-3949-284239.md`, `draft-28541-284236.md`), то есть контрактный дедуп нарушен. Несмотря на это scoped дал `rc=0`, `7/7` case зелёные. Реальная ветвь дрилла вызывает drafter один раз и требует только `n >= 1`; без известного маркера сценария ветвь дедупа не исполняется.

2. **FAIL — дайджест, лгущий нулями, проходит scoped-приёмку.** Заменён `scripts/nabludenia_digest.sh` стабом без маркера сценария, печатающим константы `ОТКРЫТЫЕ: 0`, `ahead 0, behind 0`, `теги: 0`, `черновиков: 0`, `чисто`; сохранена ненулевая строка `# ГРАММАТИКА:` только чтобы предъявление рассинхронизации могло выполниться.

   ```sh
   cd /tmp/adv015.mTJpUP/repo
   bash scripts/nabludenia_digest.sh --for-session --root .
   bash scripts/verify_antiplacebo.sh --scope drill_startup_digest
   ```

   Неверный вывод предъявлен непосредственно; затем scoped дал `rc=0`, `12/12` case зелёные. Ветка `real` `drill_startup_digest.sh` требует лишь `rc=0` и вообще не судит секции; case снова тестируют только свои узнаваемые стабы.

## Пойманные собственные стабы и контроли

3. **Барьер, пропускающий новый класс адреса:** обёртка пропускала `адрес: контракт 01p` (латинский суффикс вместо требуемого номера). Прямой вызов на `/tmp/adv015.mTJpUP/address-root` дал ошибочный `rc=0`; `bash scripts/verify_antiplacebo.sh --scope check_nabludenia` дал `rc=1`: `case_unicode_sklejka.sh` не предъявил красное. Пойман.

4. **Барьер с мерой want−have вместо равенства:** обёртка пропускала `Н-36` с `адрес: контракт 015 контракт 016`. Команда

   ```sh
   bash scripts/verify_antiplacebo.sh --scope check_nabludenia/case_lishnee_naznachenie
   ```

   дала `rc=1`: «барьер остался зелёным на обманном дереве». Пойман именно постоянным case лишнего назначения.

5. **Черновик, пишущий в дерево:** стаб писал в `$PWD/dev-harness-nabludenia/drafts/`. Его прямой вызов создал файл внутри временного дерева; затем `bash scripts/verify_antiplacebo.sh --scope drill_gate_draft` дал `rc=1`, включая `FAIL дерево изменилось вне $WORK`. Пойман.

6. **Инструмент мимо PATH:**

   ```sh
   PATH=/nonexistent /bin/bash scripts/check_nabludenia.sh "$(mktemp -d /tmp/adv015-empty.XXXXXX)"
   ```

   дал корректный `rc=2`, `NOT_IMPLEMENTED: нет python3`, а не ложный успех. Пойманный отказ.

7. **Пустой вход:** настоящий барьер на пустом временном корне дал предусмотренный `rc=0` с именованным `неприменимо: NABLIUDENIA.md и NABLIUDENIA_ARCHITECT.md отсутствуют …`; это не объявлено «нарушений не найдено» молча.

## Живая приёмка и сторож

Все ниже перечисленные **принятые** живые прогоны обрамлены `md5sum NABLIUDENIA.md`; до/после совпали `35ccdd6086b421be5d2a1350e322d608`:

- `bash scripts/verify_antiplacebo.sh --scope check_nabludenia` → `rc=0`, 12/12.
- `bash scripts/verify_antiplacebo.sh --scope drill_gate_draft` → `rc=0`, 7/7.
- `bash scripts/verify_antiplacebo.sh --scope drill_startup_digest` → `rc=0`, 12/12.
- `bash scripts/verify_antiplacebo.sh --scope drill_nabludenia_nechitaemo` → `rc=0`, 1/1.
- Пять проб: `probe_nabludenia_krasnoe.sh`, `probe_gate_draft_krasnyj.sh`, `probe_digest_krasnyj.sh`, прямой `scripts/drill_nabludenia_nechitaemo.sh`, `probe_migracija_adresov.sh` — каждая `rc=0`; прямой дрилл подтвердил `rc=2`-ветвь в собственной песочнице, живой `NABLIUDENIA.md` не изменён.
- `bash scripts/check_contract_frozen.sh` → `rc=0`; тот же md5-сторож чист.

Один первый scoped-прогон digest был отброшен как недостоверный: между его md5 (`3a6f4255…`) и окончанием файла изменился на `35ccdd60…`, и раннер назвал внешнее изменение `./NABLIUDENIA.md`. Файл не откатывался и не редактировался мной; повтор после стабилизации приведён выше и чист. Поэтому md5-сторож для всех засчитанных результатов чист.

Требуемая правка за автором: дриллы не должны классифицировать правильность субъекта по добровольным строковым маркерам. Каждая контрактная инварианта должна предъявляться поведенчески и для любого содержимого субъекта; зелёный контроль drafter обязан включать повтор и in-tree TMPDIR, а зелёный контроль digest — содержимое непустых секций/тегов, не только возврат `0`.
