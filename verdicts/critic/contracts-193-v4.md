accept
OBJECT=1eac9b927baa02741e12640e2267865c7c99010c

СУД: repo=dev-harness; предмет=193; фаза=контракт v+1/v4, узкий26строкR0168; роль=critic; вызов=11; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit193V4Scoped11; модель-факт=openai-codex/gpt-6.1-terra; SHA=1eac9b927baa02741e12640e2267865c7c99010c; предыдущий=verdicts/critic/contracts-193-v3.md (Crit193V9 accept); исключение=SANKCIJAК2026-11-27T21:49:05Z ADR2026-11-24/m2696.

## Область

Только 26 добавленных строк contracts/193-svyazka-sdatochnyj-list.md:74–99 относительно frozen/contracts/193/3 и непосредственно зависимый регресс. Прочитан полный настоящий вердикт V9 с OBJECT; его К-09 не переоткрывается. Доступный Crit232cDay accept из archive/232/critic-v3-accept-bc2a7cbb3 судил тот же OBJECT: его результаты — чужое свидетельство, не собственный прогон. Сверены контракт 232, исходный код модели, привязки в build.py и приёмка. Production ещё не реализует эту дельту; зелень старой двери не доказывает новую. Остаточная конкурентная подмена после двери вне заявленной защиты 232; ловцы — повтор двери и HEAD-only freeze. Фикс авторизован коммитом f875c2f6183b1c51755c6690e8955c35f44500eb, строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ. Ни новый полный суд 193/232, ни проверка неизменённых И1–И10 не проводились.

`bash scripts/models_actual.sh --tsv --bind --session Crit193V4Scoped11` → rc 0; две одинаковые строки `critic openai-codex/gpt-6.1-terra allowed Crit193V4Scoped11 1eac9b927baa02741e12640e2267865c7c99010c`. Автор дельты — другая роль и сессия; независимость фактической bind-трассы при материализации сверяет оркестратор.

`git hash-object --no-filters -- fixtures/workshop_project/karta_krome_232/live178.md` → rc 0, `0c079b17b3d1a3fee5cf58c5daf19ea9c156d713`; `sha256sum` того же файла → rc 0, `0a7d5c84b0cbebc8e9e61bfd58db185f6d4f38c0ae711842a7b72c820aacae66`. Это разные идентификаторы одних байтов.

## Карта классов

К-01: чисто — вход: дельта и сдаточный лист 193.
К-02: чисто — вход: R-0168, contract 232:30–46 и diff 193.
К-03: чисто — вход: неизменённые HEAD-only И5/И7, принятые свидетелем Crit232cDay регрессии 193/224.
К-04: чисто — вход: frozen/contracts/193/3 зона critic и зона перехода contracts/232:78.
К-05: чисто — вход: contracts/193:99 ссылается на исполняемую приёмку contracts/232:48–60.
К-06: без изменений с вызова 9.
К-07: чисто — вход: свои честные unstaged/staged LF и CRLF ниже, ранее принятые Crit232cDay соседние сценарии.
К-08: чисто — вход: собственная мутация индексной сверки ниже и binding st29/st30 в build.py.
К-09: чисто — вход: индекс/current/last FAIL и точный blob в contracts/232:33–40, адресные клетки probe.py.
К-10: чисто — вход: собственные stdout/stderr/rc и проверки HEAD/файла ниже; дополнительная сверка индекса — чужой Crit232cDay.
К-11: чисто — вход: штатная модель и отдельный оракул 232, не production.
К-12: чисто — вход: Git hash-object --no-filters и штатная грамматика 193 в модели 232.
К-13: н/п — секретные входы не вводятся.
К-14: чисто — вход: собственный честный LF/text и честный до add; CRLF/raw сосед в Crit232cDay.
К-15: чисто — вход: фактические raw Git и probe результаты ниже; счёт батареи не переизмерялся.
К-16: чисто — вход: contracts/232 модель угроз и граница конкурентной подмены; новый риск text-фильтра не исключён.
К-17: н/п — архитектура продукта 188 не объявлена; станционные двери.

## Собственная адресная атака

`env TMPDIR=/tmp/dev-harness-verify VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck VALIDATE_STD_PYTHON=/usr/bin/python3 PYTHONDONTWRITEBYTECODE=1 python3 -B "$PWD/tmp/critic193v4scoped11/probe.py"` → rc 0. Скрипт и одноразовые Git-миры с собственными .git сохранены в tmp судейской копии. В копии model/pre_judge заменено условие существующей сверки index_blob/file_blob на `if false; then`; честный сценарий и мутант запускаются сначала до add, затем после add. Это проверка модели, не production и не полная батарея. Сырой stdout:

```text
honest pj-index-text-normalized first 0 b'VERDICT_BRANCH=wip/178/critic\n' b'' staged 1 b'' b'\xd0\x9e\xd0\xa2\xd0\x9a\xd0\x90\xd0\x97: KARTA_NE_SHTATNA\n\xd0\xba\xd0\xb0\xd1\x80\xd1\x82\xd0\xb0 \xd0\xbd\xd0\xb5 \xd1\x88\xd1\x82\xd0\xb0\xd1\x82\xd0\xbd\xd0\xb0\xd1\x8f: \xd0\xb8\xd0\xbd\xd0\xb4\xd0\xb5\xd0\xba\xd1\x81 \xd0\xbe\xd1\x82\xd0\xbb\xd0\xb8\xd1\x87\xd0\xb0\xd0\xb5\xd1\x82\xd1\x81\xd1\x8f \xd0\xbe\xd1\x82 --file\n' HEAD_unchanged True file_unchanged True
honest pj-index-text-lf first 0 b'VERDICT_BRANCH=wip/178/critic\n' b'' staged 0 b'VERDICT_BRANCH=wip/178/critic\n' b'' HEAD_unchanged True file_unchanged True
no-index-check pj-index-text-normalized first 0 b'VERDICT_BRANCH=wip/178/critic\n' b'' staged 0 b'VERDICT_BRANCH=wip/178/critic\n' b'' HEAD_unchanged True file_unchanged True
no-index-check pj-index-text-lf first 0 b'VERDICT_BRANCH=wip/178/critic\n' b'' staged 0 b'VERDICT_BRANCH=wip/178/critic\n' b'' HEAD_unchanged True file_unchanged True
```

Различение покрыто уже имеющимися адресными st29/st30; скрипт отдельно подтверждает поведение модели на реальной операции add с фильтром. Ни полнота всех входов, ни состояние production из этого прогона не следуют.

## Сдаточный лист

`env TMPDIR=/tmp/dev-harness-verify VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck VALIDATE_STD_PYTHON=/usr/bin/python3 PYTHONDONTWRITEBYTECODE=1 SDACHA_TIMEOUT_SEK=300 SDACHA_BUDZHET_SEK=900 timeout --kill-after=30s 1200s bash scripts/check_sdacha.sh "$PWD" contracts/193-svyazka-sdatochnyj-list.md --run` → rc 0, сырой stdout `СДАЧА: лист зелёный (двери=2 карта=17/17 дельта=3)`; 492.22 с. Выполнен один раз в своей копии.
