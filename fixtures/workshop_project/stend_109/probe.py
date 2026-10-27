#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Батарея контракта 109 (CMP-BCK-004): изолированный стенд и сбор HTTP/SQL evidence 5.8.2.
Круг 3 (арбитраж contracts-109-cep-zhivogo-fakta-v1, замкнутый перечень К1–К6):
живые факты судят ВСЮ цепь — правило Ц: вызов точкой входа поставки → запись
субъектом в sink → чтение ожиданий из sink; мутанты-обходы байт-в-байт к
деревьям критика кругов 1–2.

Структура Complior-back (слово консультанта 14:30 UTC 2026-10-20): репозиторий
перестроен по эталону — backend/ растворён (app/, server/, tests/ и корневые
файлы пакета — в корне репозитория), tools + backend/scripts → tests/tools/,
db → migrations/, infra/migrations|release → server/infrastructure/,
contracts|sources|ux|data|evidence → docs/, корневой server →
tests/historical-server/. Пути батареи, обязанные пережить ОБЕ структуры,
разрешаются по факту дерева ПЕРЕМЕННОЙ (package.json в корне — новая
структура, в backend/ — старая; производные пути — из одной колонки PATHS),
не жёстким литералом.

Парсер — Python 3 stdlib. Батарея поднимает НЕ стенд, а ИСПОЛНЯЕТ предмет:
раннер миграций 129 (node), точку входа drill-коллектора (node, команда
scripts['drill:evidence'] из package.json, два различимых входа),
recordInteraction harness (node, три различимые записи — по одной на режим) и
разрешение сетей docker compose config (без подъёма контейнеров). Живой стенд
(docker compose up -d --wait, повтор, повреждённая копия, реальный маршрут
egress из запущенного сервиса; npm test:integration на native PG18) — отдельные
строки приёмки контракта. Структурные проверки — сверх-приближение; измеренный
живой факт раннера: отказ на повреждённой копии db/ и манифесте с пропуском ДО
соединения с БД (rc 1, «SHA256 … не совпадает с манифестом»).

ПРАВИЛО Ц (цепь; арбитраж 109): живой факт зелен только если измерены все три
звена — (1) ВЫЗОВ: субъект запущен командой/точкой входа, которую объявляет
ПОСТАВКА (скрипт package.json, вызов из harness/теста), а не файлом,
который батарея нашла сама; (2) ЗАПИСЬ: субъект сам создал артефакт в sink
(файл evidence), батарея его не подменяет; (3) ЧТЕНИЕ: ожидания сравниваются
со значениями, ПРОЧИТАННЫМИ из sink, по независимым литералам батареи;
возвращённое значение/stdout — дополнительный, не замещающий источник. Вход
факта проходит по заявленному пути: сентинел — в сериализуемом поле наблюдения;
каждое объявленное значение конечной оси mode (FIXTURE_5_8_2 / SYNTHETIC /
RUNTIME) — отдельное наблюдение.

Выход: rc 0 — контроль зелен, все факты True (перечень фактов — по кругам
ниже; на черновике v2 их пятнадцать; True — не None/False) и каждый
мутант отвергнут ровно своей причиной (ожидается на честном C); rc 1 — контроль
красен (честное red на до-предметном B), факт False или мутант не отвергнут /
изоляция нарушена; rc 2 — UNMEASURABLE / EMPTY_SELECTION / NOOP_MUTATION /
NEEDS_ENV (факт None — не измерено, контроль не зелен: гейт не зеленее CI).

ГРАММАТИКА МАРКЕРОВ (что ищет батарея; смысл доказывают живые строки приёмки и
судьи — батарея сверх-приближение по правилу 7 AGENTS, не интерпретатор):

  compose (compose.dev.yml в корне репозитория; текстовые якоря, не YAML-парсер):
    - сервис миграций '^  migrat…:' и сервис '^  api:';
    - migrate-before-API: literal 'service_completed_successfully' в файле и
      зависимость api от сервиса миграций;
    - образы: каждая строка 'image:' несёт тег (не ':latest'); PG-образ содержит
      ':18' или '@sha256:';
    - volume-строка с prod|dump|medical в хостевом пути — запрещена;
    - блоку api запрещены env MIGRATION_DATABASE_URL и переменные
      ^(MIGRATION|DDL|GATEWAY);
    - сервисы worker|sandbox|document: сети, ПЕРЕЧИСЛЕННЫЕ в их блоке networks:,
      существуют и ВСЕ internal: true (верхний раздел networks:); «internal: true
      где-то в файле» недостаточно — оракул судит назначенные сервисам сети;
    - опубликованный порт СЕРВИСА PG — только '127.0.0.1:';
    - данные PG — именованный volume ('- имя:/…') и верхний раздел volumes:.

  harness (tests/helpers/harness.js, CommonJS):
    - append-only: флаг 'wx' (или O_EXCL / flag 'x') при создании файлов evidence;
    - scrubber: вызов scrub*/redact*/sanitiz* над сериализованным текстом
      (аргумент содержит JSON.stringify);
    - SQL before/after: литералы 'sql_before' и 'sql_after';
    - runtime role: литералы 'current_user' и 'runtime_role';
    - provider-call count: литерал 'provider_call';
    - hash manifest: литералы 'sha256' и 'input_hashes';
    - честность: литерал 'NOT_RUN' (недоступная БД — не успех);
    - различение режимов: литералы 'FIXTURE_5_8_2', 'SYNTHETIC', 'RUNTIME';
    - ЗАМКНУТЫЙ КОРТЕЖ ОСЕЙ: один массив шести токенов по порядку
      http_request … http_response … sql_before … sql_after … runtime_role …
      provider_calls — произведение осей на каждую запись взаимодействия.

  drill-коллектор (точка входа поставки — package.json
  scripts['drill:evidence']; имя скрипта — единый источник ЗДЕСЬ; команда
  вызывает коллектор tests/tools/*.js с литералами drill+rpo+rto в одном
  файле; упоминание basename коллектора в description/комментарии проводом
  НЕ считается):
    - грамматика CLI: `node <коллектор> --out DIR [--input FILE]`; без входа
      пишет DIR/drill-evidence.json со status NOT_RUN и целевыми константами
      target_rpo_minutes=15, target_originals_within_minutes=60,
      target_rto_minutes=240; со входом — status MEASURED, db_hash/object_hash/
      key_hash = sha256 полей db_dump/objects_dump/keys_dump входа, измеренные
      measured_rpo_minutes/measured_rto_minutes/measured_at ИЗ входа (не цели),
      целевые константы рядом и отдельно.

  проводка:
    - файл в tests/integration/**, содержащий 'helpers/harness';
    - package.json: скрипт test:integration покрывает этот файл своим glob.

  факты (зелены и на B, и на C; красный факт = UNMEASURABLE, не мок-зелёный;
  None = NEEDS_ENV — честный NOT_RUN с границей «что именно не проверено»):
    - ROOT_SERVER_PRESENT: tests/historical-server/test/harness.ts и
      tests/historical-server/src/app.ts на месте
      И байты совпадают с закреплёнными sha256 пина B (пустышка не проходит);
    - RUNNER_DAMAGE_GUARD: раннер 129 отказывает на повреждённой копии db/ и на
      манифесте с пропуском. NEEDS_ENV, если нет node или node_modules/pg;
    - EGRESS_GUARD (живой): docker compose config по РАЗРЕШЁННОЙ конфигурации —
      сети, реально назначенные worker/sandbox/document, существуют и все
      internal; NEEDS_ENV без docker compose (граница: назначение сетей и живой
      маршрут egress НЕ проверены);
    - DRILL_EVIDENCE_GUARD (живой; правило Ц): КОМАНДА поставки
      scripts['drill:evidence'] ИСПОЛНЯЕТСЯ в disposable-копии корня пакета — без
      входа NOT_RUN, с двумя различимыми входами точные sha256-хэши и
      измеренные значения каждого входа, sink читается из DIR/drill-evidence.json
      самой команды; чужой snapshot и константа не проходят; команда, не
      указывающая на коллектор tests/tools, — красна;
    - HARNESS_TUPLE_GUARD (живой; правило Ц): recordInteraction(observation,
      dir) — синхронная функция harness.js; ТРИ различимые записи — по одной на
      каждый режим FIXTURE_5_8_2 / SYNTHETIC / RUNTIME; из СОХРАНЁННОГО файла,
      сопоставленного наблюдению по порядку создания, читаются mode (седьмое
      сверяемое поле), шесть осей (сентинел-несущее значение поля: присутствует,
      непусто, сентинела нет; прочие — точно равны наблюдению) и
      input_hashes[name] = sha256 каждого observation.inputs; возвращённый
      кортеж — дополнительная, не замещающая сверка; после трёх вызовов ровно
      три файла, прежние неизменны (append-only); строки observation.secrets
      (сентинел помещён в сериализуемое поле — сверка не вакуумна) отсутствуют
      в файлах evidence.
  НОВЫЕ ФАКТЫ КРУГА 2 (пост-заморозочное усиление гейта по вердиктам судей
  реализации — F1–F5/Б1–Б3; frozen-контракт не меняется, мутанты — байт-в-байт
  к дефектным ветвям коммита C a9569176c):
    - DRILL_INPUT_GUARD (живой; правило Ц): команда scripts['drill:evidence'] в
      disposable-копии: вход с measured_* null ИЛИ не-числом/не-ISO-строкой
      («ok»/«fine»/«never») → rc ≠ 0 и sink без MEASURED; валидный вход →
      MEASURED; повторный прогон без входа в ТОТ ЖЕ --out — файл
      drill-evidence.json байтово неизменен (append-only, не перезапись);
    - HARNESS_HONESTY_GUARD (живой; круг 3): поверхность честности — названная
      контрактом recordInteraction (синхронная) и живой путь поставки «реальный
      HTTP между SQL-снимками» recordInteractionAsync (объявлен тестом поставки
      tests/integration/harness.test.js; имена внутренних функций не
      закрепляются): наблюдение БЕЗ mode → отказ (throw) и файл не создаётся,
      не «mode: RUNTIME» по умолчанию; mode вне трёх литералов (MOCK_SUCCESS) →
      throw на синхронной И на живой ветке; валидный mode при недоступной БД
      (COMPLIOR_HARNESS_DATABASE_URL на закрытый порт 127.0.0.1:1) → throw
      ИЛИ статус NOT_RUN, никогда MEASURED/успех;
    - HARNESS_PII_GUARD (живой; правило Ц, чтение из sink): recordInteraction
      с НЕОБЪЯВЛЕННЫМИ Bearer-токеном/cookie/email/телефоном и объявленным
      секретом, содержащим кавычку и обратный слеш: сохранённый файл —
      парсящийся JSON (потребитель поставки читает evidence JSON.parse'ом;
      scrubber чистит значения, не разрушая структуру), в нём нет ни raw-, ни
      JSON-экранированной формы каждого; запись не вакуумна (authorization
      непуст, «patient» в теле сохранён, mode из файла равен наблюдению);
    - STEND_UP_GUARD (живой): docker compose -p <уникальный> -f
      compose.dev.yml up -d --wait → rc 0; SELECT count(*) из
      control.schema_migration = N (числу записей манифеста миграций
      дерева под проверкой, v4); повторный up rc 0 и ledger прежний;
      после прогона — down -v. Ловит том PG18 вне /var/lib/postgresql
      (образ 18+ отказывается от data-подпути) и migrator на образе без node
      (postgres:18 + command node → exit 127). NEEDS_ENV без docker compose
      (граница: живой подъём стенда, миграция до API и ledger НЕ проверены);
    - FILES_SHA256_GUARD: каждая непустая строка FILES.sha256 (<sha256>␣␣<путь>)
      — путь ЕСТЬ в коммите (git cat-file -e HEAD:<путь>) и sha256 blob из
      HEAD совпадает с строкой. NEEDS_ENV без FILES.sha256 или без .git
      (граница: соответствие производных коммиту НЕ проверено).
  НОВЫЕ ФАКТЫ КРУГА 3 РЕАЛИЗАЦИИ (пост-заморозочное усиление по вердиктам
  impl-круга 2: F2'/F3'/F4'/A2/Б2′/С5/С7; frozen-контракт не меняется,
  мутанты — настоящего кода d1cece28, якоря байт-в-байт):
    - ASYNC_TUPLE_GUARD (живой; правило Ц, оракул — сторона сервера И БД, не
      возврат вызывающего): disposable PG18 (docker, digest-образ из compose)
      с таблицей стенда; PRESET-строка вставлена ДО вызова, MARKER-строку
      вставляет реальный TCP-сервер ПО ПРИХОДУ запроса. recordInteractionAsync
      (экспорт harness.js) вызывается с COMPLIOR_HARNESS_DATABASE_URL на эту
      БД и http_request на этот сервер: (1) запрос ПРИШЁЛ (журнал прибытий
      сервера); (2) sink-файл парсится как JSON и содержит PRESET ровно 2
      раза (измеренные строки таблицы ДО и ПОСЛЕ запроса) и MARKER ровно 1
      раз (только в после-снимке: HTTP между снимками); (3) runtime_role из
      файла = current_user БД-сессии, не заявление вызывающего. Имена
      внутренних функций реализации сверх экспортов harness.js не
      закрепляются. NEEDS_ENV без docker/node/node_modules/pg;
    - ASYNC_PII_GUARD (живой; правило Ц, чтение из sink): recordInteractionAsync
      с РЕАЛЬНЫМ HTTP-ответом, несущим Set-Cookie-МАССИВ из двух значений, и
      запросом с cookie «a=1; session=X»; тело ответа несёт экранированную
      cookie-форму {\"cookie\":\"…\"} и литеральный текст «Set-Cookie: …» с
      секретом. В sink-файле каждый секрет отсутствует raw- и в JSON-форме,
      файл парсится как JSON (потребитель читает JSON.parse'ом), ответ
      измерен (status 200, маркер тела сохранён);
    - LANE_HYGIENE_GUARD (живой): lane stend109 (tests/tools/run_backend_ci.py)
      исполняется с COMPLIOR_STEND109_H_CHECKOUT на ЧИСТЫЙ git-checkout тега
      frozen/contracts/109/2 (живая батарея тега; рекурсия погашена маркером
      глубины STEND109_LANE_DEPTH — см. блок круга 4/v2 ниже) — lane PASS;
      тот же checkout с НЕЗАКОММИЧЕННОЙ подменой probe.py на sys.exit(0) —
      lane обязан отказать (rc ≠ 0): грязное рабочее дерево H-checkout не
      исполняется как frozen-батарея (A2/С3). NEEDS_ENV, если lane stend109,
      git или docker отсутствуют;
    - DRILL_INPUT_GUARD (расширен, F2'/С5): каждое измеренное поле портится
      В ОТДЕЛЬНОСТИ (остальные чисты): measured_at «never»/«ok»/не-ISO и
      отрицательные measured_rpo_minutes/measured_rto_minutes → rc ≠ 0 и в
      sink нет MEASURED; валидный вход → MEASURED; повторный прогон без
      входа в тот же --out не перезаписывает измеренный evidence;
    - STEND_UP_GUARD (расширен, С7): (а) LOGIN-роль role-bootstrap (env
      ROLE_NAME в compose) существует живьём в pg_roles: rolcanlogin=t и
      rolsuper=f; (б) пользователь DATABASE_URL блока api — это ROLE_NAME, а
      не суперпользователь postgres-сервиса (POSTGRES_USER); (в) ledger
      control.schema_migration между повторными up сравнивается ПО
      СОДЕРЖИМОМУ строк (version, name, file_sha256, applied_by), не только
      по count: переписанные при up записи — RED.
  НОВЫЕ ФАКТЫ/ЯКОРЯ КРУГА 4 (по РЕШЕНИЮ арбитра contracts-109-impl-perechen:
  пере-якорение на байты OBJECT-4 dd8e533f, NOOP громкий, расширенные формы
  A-3…A-8; замороженный контракт 109/1 НЕ меняется):
    - NOOP громкий (A-2/С8): пропавший якорь мутанта на ЗЕЛЁНОЙ базе —
      rc 2 NOOP_MUTATION (не тихий BLOCKED rc 0); BLOCKED — только когда база
      уже красна; для fact-целей «overlay == база» проверяется ДО вызова
      факта; контроль HARNESS_NO_SCRUBBER якорится на scrubRecord( в едином
      пути записи (I-9), не на scrub*(JSON.stringify);
    - ASYNC_TUPLE_GUARD (расширен, A-3/A-5): ПАРАЛЛЕЛЬНОСТЬ — N=2
      одновременных recordInteractionAsync (Promise.all, быстрый/медленный
      HTTP) с различимыми текстами: sql_before/sql_after КАЖДОЙ записи из
      файла — тексты СВОЕГО наблюдения (модульного snapshotContext нет, I-3);
      МУЛЬТИСТЕЙТМЕНТ — sql_before 'SELECT 1; COMMIT; INSERT …' в таблицу
      факта: из файла status NOT_RUN с причиной «read-only/мультистейтмент»,
      строки таблицы после прогона = до (I-4); оракул таблицы — psql, не файл;
    - DRILL_INPUT_GUARD (расширен, A-4): строгая ISO-грамматика по ПОЛЯМ —
      «never 1», «1», «May 5», «12/31/2026», «2026-02-31»,
      «2026-02-31T00:00:00Z», дата-без-времени, время-без-зоны → rc ≠ 0 без
      MEASURED; «2026-10-19T09:30:00.123+03:00» → MEASURED; клетка
      drill_at_not_iso: MODEL — строгая функция dd8e533, ДЕКОЙ — тело
      isValidIso8601 8aca71a байт-в-байт (I-2);
    - HARNESS_PII_GUARD/ASYNC_PII_GUARD (расширен, A-6): замкнутый перечень
      форм — cookie без «=», cookie-массив, set-cookie без «=»,
      Authorization: Basic, authorization без схемы, proxy-authorization,
      x-api-key, тела «Cookie: …»/«Authorization: …»/{"cookie":[…]}/
      {"authorization":…}, телефоны РФ 89160000000 и 8 916 000 00 00;
      ожидание — сентинел отсутствует, ПОЛЕ присутствует и непусто (форма К4),
      JSON цел; литерал [REDACTED] не навязывается (I-6);
    - ASYNC_PII_GUARD (расширен, A-7): DB-less async — runtime_role из файла
      == 'NOT_RUN' (не заявление); два объектных входа {a:{x:1}}/{a:{y:2}} —
      input_hashes из файла РАЗЛИЧАЮТСЯ (каноническая форма не навязывается;
      I-7/I-8);
    - LANE_HYGIENE_GUARD (переписан, A-8; v2 — форк n109-lane-v2): lane
      stend109 судится на ЖИВОМ H-checkout пина (clone тега
      frozen/contracts/109/2; HEAD == STEND109_PIN, hash-object probe.py ==
      блоб пина) на дереве ПОД испытанием (HEAD; зелёный корень v1 8aca71a —
      наследие v1): чистый — lane rc 0; три обхода — незакоммиченная подмена
      probe.py, подмена под update-index --assume-unchanged, коммит подмены
      + git tag -f — каждый rc ≠ 0 (I-5). Рекурсия lane→батарея v2→lane-факт
      →lane разорвана маркером STEND109_LANE_DEPTH='1' от внешнего факта:
      вложенный факт — зелёный пропуск (гигиену судит внешний); глубина ≥2 —
      громкий красный «рекурсия lane-факта» сразу; незавершающийся прогон —
      красный таймаутом run_lane (rc 124) за конечное время; клетка
      lane_dirty_checkout_ok во вложенном прогоне — поименованный пропуск
      SKIP_NESTED_DEPTH (судит внешний). Остаточный риск cognitive-only —
      подмена env-маркера в CI.
  НОВЫЕ ФАКТЫ ЧЕРНОВИКА v2 (форк n109-krug4-fail, находки круга 4 adversary
  I-1/I-10; замороженный текст 109/1 меняется только перезаморозкой 109/2):
    - BACKEND_LINT_GUARD (живой, I-1): npm run -s lint (eslint . и
      prettier --check) в disposable-копии HEAD-дерева (+оверлей мутанта,
      симлинк node_modules) — rc 0; мутант backend_lint_unused_const (один
      неиспользуемый const в harness.js, форма mut-i1) — rc != 0, батарея
      отвергает клеткой; до v2 батарея принимала дерево, не проходящее
      собственный required-lane;
    - DELIVERY_TEST_RED_CONTROL (статически+живо, I-10): тело ИМЕНОВАННОГО
      теста «живое наблюдение: server+PG18…» — строго span САМОГО вызова
      test(…) до его закрытия по балансу скобок: токены
      (recordInteractionAsync/readSink/MEASURED/runtime_role/ledger
      N-по-манифесту/http_response) и assert-проверки (≥5) считаются ТОЛЬКО внутри
      span — заимствование исполняемых проверок соседнего теста (обход
      критика круга 1 v2: пустое тело + переставленный сосед с живым
      assert) не засчитывается; И файл исполняется зелёно (node --test
      на disposable PG18); подмена тела на async () => {} (форма mut-i10)
      — батарея отвергает. Граница: интерпретация JS-тела не выполняется
      — токены-без-исполнения (ветвление) статическая часть не
      различает (сверх-приближение, правило 7 AGENTS); сканер баланса не
      разбирает regex-литералы с неспаренными кавычками/скобками —
      якорные байты dd8e533 их не содержат.
  НОВОЕ v4 (слово владельца 2026-10-26: проба берёт ЧИСЛО МИГРАЦИЙ из
  манифеста репозитория продукта, а не из зашитой константы 14 — без
  этого бэкенд не вольёт готовый 007, добавляющий миграции):
    - единый источник ожидания — manifest_entries(tree): записи
      PATHS['manifest'] ДЕРЕВА ПОД ПРОВЕРКОЙ (тот же файл читает мигратор
      129 run.js loadPlan; «migrations/» и «server/infrastructure/…» —
      обе структуры через PATHS); константы в судействе больше нет;
    - STEND_UP_GUARD: ledger == len(записей манифеста), повторный up —
      ledger прежний ПО СОДЕРЖИМОМУ строк; раннер повреждает ПОСЛЕДНИЙ
      .sql каталога (жёсткий 013_* ломал миры с N<13);
    - манифест отсутствует/нечитаем/пуст/без перечня/несовпадает с
      набором *.sql каталога — отказ fail-closed: CLI rc 2
      `109 UNMEASURABLE: MANIFEST_<причина>` ДО любого суда, клетка
      факта — красная с именованной причиной (не молчаливое 14);
    - DELIVERY_TEST_RED_CONTROL: токен числа в span именованного теста —
      str(N) по манифесту; продукт, добавивший миграции и не обновивший
      тест (класс 007-до-правки), красен — клетка delivery_token_stale;
    - мир классов входов (N: 1, 14, 15, 17, база+1; недокат/перекат/
      подложный ledger) и обманные стабы судятся срез-раннером
      red_migracii_109.sh (грамматика — контракт §Приёмочный критерий;
      оракул каждого мира — его манифест, вычислен ДО вызова субъекта).
"""

import argparse
import fnmatch
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import time
import tempfile
import uuid
from pathlib import Path

UNMEASURABLE = '109 UNMEASURABLE'


# ------------------------------------------------ структура Complior-back
# Карта путей консультанта 14:30 UTC 2026-10-20 (дословно): backend/app →
# app/, backend/server → server/, backend/tests → tests/, tools +
# backend/scripts → tests/tools/, db → migrations/, infra/migrations|release
# → server/infrastructure/, contracts|sources|ux|data|evidence → docs/,
# корневой server → tests/historical-server/, корневые файлы backend
# (package.json, compose.dev.yml, node_modules, …) → в корень репозитория.
# Пути, обязанные пережить ОБЕ структуры, батарея разрешает по факту дерева
# (переменная, не жёсткий литерал — рекомендация консультанта): package.json
# в корне — новая структура, в backend/ — старая; производные пути выводятся
# из выбранной колонки ЕДИНЫМ источником (Н-39: привязка стабов — по коду).
LAYOUT_NEW = 'new'
LAYOUT_OLD = 'old'
PATHS = {
    LAYOUT_NEW: {
        'pkg_root': '', 'compose': 'compose.dev.yml', 'pkg': 'package.json',
        'harness': 'tests/helpers/harness.js', 'integ_dir': 'tests/integration',
        'scripts_dir': 'tests/tools', 'lane': 'tests/tools/run_backend_ci.py',
        'db_dir': 'migrations',
        # 604fad1b/11432a3: run.js:10 «server/infrastructure/migrations/
        # manifest.json», package.json scripts.migrate — тот же каталог
        'runner': 'server/infrastructure/migrations/run.js',
        'manifest': 'server/infrastructure/migrations/manifest.json',
        'node_modules': 'node_modules',
        'root_server': 'tests/historical-server',
    },
    LAYOUT_OLD: {
        'pkg_root': 'backend', 'compose': 'backend/compose.dev.yml',
        'pkg': 'backend/package.json',
        'harness': 'backend/tests/helpers/harness.js',
        'integ_dir': 'backend/tests/integration',
        'scripts_dir': 'backend/scripts', 'lane': 'tools/run_backend_ci.py',
        'db_dir': 'db', 'runner': 'infra/migrations/run.js',
        'manifest': 'infra/migrations/manifest.json',
        'node_modules': 'backend/node_modules', 'root_server': 'server',
    },
}


def detect_layout(repo):
    """Новая структура — package.json в корне; старая — в backend/."""
    r = Path(repo)
    for lay in (LAYOUT_NEW, LAYOUT_OLD):
        if (r / PATHS[lay]['pkg']).is_file():
            return lay
    return None


def p_of(repo, key):
    """Путевой литерал по репо без Tree (факты, принимающие Path)."""
    return PATHS[detect_layout(repo) or LAYOUT_OLD][key]


# ---------------------------------------------------------------- tree overlay

class Tree:
    """Чтение репо R с поверх мутированного оверлея (байты только в памяти)."""

    def __init__(self, repo, overlay=None):
        self.repo = Path(repo)
        self.overlay = overlay or {}
        self.layout = detect_layout(self.repo)

    def p(self, key):
        """Путевой литерал выбранной структуры (единый источник путей)."""
        return PATHS[self.layout or LAYOUT_OLD][key]

    def pkg_root(self):
        """Корень пакета Node (новая структура — корень репо, старая — backend/)."""
        pr = self.p('pkg_root')
        return self.repo if not pr else self.repo / pr

    def get(self, rel):
        if rel in self.overlay:
            return self.overlay[rel]
        try:
            return (self.repo / rel).read_text(encoding='utf-8')
        except (OSError, UnicodeDecodeError):
            return None

    def sql_names(self, dir_rel):
        """Имена *.sql каталога с учётом оверлея: на диске ∪ оверлей −
        удаления (None). Список файлов — не текст: get() его не читает."""
        names = set()
        try:
            names |= {f for f in os.listdir(self.repo / dir_rel)
                      if f.endswith('.sql')}
        except OSError:
            pass
        prefix = dir_rel + '/'
        for orel, obody in self.overlay.items():
            if not orel.startswith(prefix):
                continue
            name = orel[len(prefix):]
            if '/' in name:
                continue
            if obody is None:
                names.discard(name)
            elif name.endswith('.sql'):
                names.add(name)
        return names


class ManifestError(Exception):
    """Манифест миграций репозитория под проверкой не даёт ожидания
    (v4): отказ fail-closed с именованной причиной, а не молчаливая
    константа. Причины замкнуты: MANIFEST_MISSING, MANIFEST_UNPARSEABLE,
    MANIFEST_NO_LIST, MANIFEST_EMPTY, MANIFEST_ENTRY_FILE,
    MANIFEST_MISMATCH_FILES."""

    def __init__(self, reason):
        super().__init__(reason)
        self.reason = reason


def manifest_entries(tree):
    """Записи манифеста миграций ДЕРЕВА ПОД ПРОВЕРКОЙ (v4, единый источник
    ожидаемого ledger): PATHS['manifest'] — тот же файл, который читает
    сам мигратор 129 (run.js loadPlan: doc.migrations, каталог миграций
    обязан совпадать с манифестом до любого DDL). Подмножество правил
    loadPlan (файл есть в каталоге; .sql вне манифеста нет) — вторую
    грамматику (версии/SHA256) не изобретаем: их судит живой раннер
    (RUNNER_DAMAGE_GUARD). Возвращает список записей; сломан — raise
    ManifestError."""
    body = tree.get(tree.p('manifest'))
    if body is None:
        raise ManifestError('MANIFEST_MISSING')
    try:
        doc = json.loads(body)
    except ValueError:
        raise ManifestError('MANIFEST_UNPARSEABLE')
    entries = doc.get('migrations') if isinstance(doc, dict) else None
    if not isinstance(entries, list):
        raise ManifestError('MANIFEST_NO_LIST')
    if not entries:
        raise ManifestError('MANIFEST_EMPTY')
    files = []
    for e in entries:
        if not isinstance(e, dict) or not isinstance(e.get('file'), str):
            raise ManifestError('MANIFEST_ENTRY_FILE')
        files.append(e['file'])
    listed = set(files)
    if len(listed) != len(files):
        raise ManifestError('MANIFEST_ENTRY_FILE')
    present = tree.sql_names(tree.p('db_dir'))
    if listed != present:
        raise ManifestError('MANIFEST_MISMATCH_FILES')
    return entries

def code_only(text):
    """JS без блочных и строчных комментариев: маркер в комментарии не считается
    (замер: защита «строки нет» однажды прошла из-за комментария)."""
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.S)
    return re.sub(r'//[^\n]*', '', text)

def services_section(text):
    """Часть файла до первого верхнего раздела вне services: (networks/volumes/…)."""
    m = re.search(r'^(networks|volumes|configs|secrets):\s*$', text, re.M)
    return text[:m.start()] if m else text


# ---------------------------------------------------------------- compose ctrl

def service_blocks(text):
    """{'api': 'тело', …} по строкам '^  имя:' (уровень сервисов)."""
    blocks, cur, buf = {}, None, []
    for line in text.splitlines():
        m = re.match(r'^  ([A-Za-z0-9_-]+):\s*$', line)
        if m:
            if cur is not None:
                blocks[cur] = '\n'.join(buf)
            cur, buf = m.group(1), []
        elif cur is not None:
            if line.startswith(' '):
                buf.append(line)
            else:
                blocks[cur] = '\n'.join(buf)
                cur, buf = None, []
    if cur is not None:
        blocks[cur] = '\n'.join(buf)
    return blocks
def internal_networks(text):
    """Имена сетей с internal: true из верхнего раздела networks:."""
    nets, cur = set(), None
    for line in text.splitlines():
        if cur == 'net':
            m = re.match(r'^  ([A-Za-z0-9_-]+):\s*$', line)
            if m:
                cur = m.group(1)
            elif line.strip() and not line.startswith('  '):
                cur = None
        elif isinstance(cur, str):
            if re.match(r'^\s{4,}internal:\s*true\s*$', line):
                nets.add(cur)
            m = re.match(r'^  ([A-Za-z0-9_-]+):', line)
            if m or (line.strip() and not line.startswith('  ')):
                cur = m.group(1) if m else None
        elif re.match(r'^networks:\s*$', line):
            cur = 'net'
    return nets


def service_network_names(block):
    """Сети, перечисленные в networks: блока сервиса (список или отображение)."""
    names, in_nets = [], False
    for line in block.splitlines():
        if in_nets:
            m = re.match(r'^\s+-\s+([A-Za-z0-9_-]+)\s*$', line)
            k = re.match(r'^\s{4,}([A-Za-z0-9_-]+):\s*$', line)
            if m:
                names.append(m.group(1))
            elif k:
                names.append(k.group(1))
            elif line.strip() and not line.startswith('      '):
                in_nets = False
        elif re.match(r'^\s+networks:\s*$', line):
            in_nets = True
    return names


def check_compose(tree):
    """(fired, blocked) группы стенда."""
    text = tree.get(tree.p('compose'))
    if text is None:
        return {'COMPOSE_MISSING'}, set()
    fired = set()
    blocks = service_blocks(text)
    mig = [n for n in blocks if re.match(r'migrat', n)]
    api = blocks.get('api', '')
    gate = ('service_completed_successfully' in text
            and bool(mig)
            and any(re.search(r'\b%s\b' % re.escape(n), api) for n in mig))
    if not gate:
        fired.add('COMPOSE_API_BEFORE_MIGRATION')
    images = re.findall(r'image:\s*(\S+)', text)
    untagged = [i for i in images if ':' not in i or i.endswith(':latest')]
    pg = [i for i in images if 'postgres' in i]
    if untagged or not pg or not all((':18' in i or '@sha256:' in i) for i in pg):
        fired.add('COMPOSE_IMAGE_UNPINNED')
    for line in text.splitlines():
        if re.match(r'^\s*-\s*(\./)?\S*(prod|dump|medical)\S*\s*:', line, re.I):
            fired.add('COMPOSE_PROD_DUMP_MOUNTED')
            break
    api_envs = re.findall(r'^\s+-?\s*([A-Z0-9_]+)\s*[:=]', api, re.M)
    if any(re.match(r'MIGRATION|DDL|GATEWAY', v) for v in api_envs) or 'MIGRATION_DATABASE_URL' in api:
        fired.add('COMPOSE_DDL_SECRETS_TO_API')
    internal_nets = internal_networks(text)
    svcs = service_blocks(services_section(text))
    for name in svcs:
        if re.search(r'worker|sandbox|document', name):
            attached = service_network_names(svcs[name])
            if not attached or not all(n in internal_nets for n in attached):
                fired.add('COMPOSE_EGRESS_OPEN')
    pgsvc = blocks.get(next((n for n in blocks if 'postgres' in n or n == 'db'), ''), '')
    for m in re.finditer(r'^\s*-\s*["\']?([0-9.]+:)?\d+:\d+["\']?', pgsvc, re.M):
        if not (m.group(1) or '').startswith(('127.0.0.1:', 'localhost:')):
            fired.add('COMPOSE_DB_EXPOSED_UNRESTRICTED')
            break
    named = re.search(r'^\s*-\s+[A-Za-z_][A-Za-z0-9_-]*:/\S', pgsvc, re.M)
    if not (named and re.search(r'^volumes:\s*$', text, re.M)):
        fired.add('COMPOSE_EPHEMERAL_DB')
    return fired, set()


# ---------------------------------------------------------------- harness ctrl

def check_harness(tree):
    text = tree.get(tree.p('harness'))
    if text is None:
        return {'HARNESS_MISSING'}, set()
    text = code_only(text)
    fired = set()
    if tree.p('harness') not in tree.overlay:  # синтаксис — только на живом файле
        pkg = tree.get(tree.p('pkg')) or ''
        chk = subprocess.run(['node', '--check', str(tree.repo / tree.p('harness'))],
                             capture_output=True)
        if chk.returncode != 0 or '"type"' in pkg and '"module"' in pkg:
            fired.add('HARNESS_NOT_CJS')
    m = re.search(r"\[[^\]\n]*http_request[^\]\n]*http_response[^\]\n]*sql_before"
                  r"[^\]\n]*sql_after[^\]\n]*runtime_role[^\]\n]*provider_calls[^\]\n]*\]", text)
    axis_line = m.group(0) if m else ''
    if not axis_line:
        fired.add('HARNESS_RECORD_AXIS_TUPLE')
    rest = text.replace(axis_line, '') if axis_line else text
    if not re.search(r"['\"]wx['\"]|O_EXCL|flag:\s*['\"]x['\"]", text):
        fired.add('HARNESS_EVIDENCE_OVERWRITES')
    # круг 4 (A-1, I-9): единый путь записи — appendExclusive(..., scrubRecord(out, ...));
    # якорь — вызов scrubRecord( в коде (не «scrub(JSON.stringify)» старой формы)
    if not re.search(r'scrubRecord\s*\(', text):
        fired.add('HARNESS_NO_SCRUBBER')
    for lit, reason, scope in [('sql_before', 'HARNESS_NO_SQL_BEFORE_AFTER', rest),
                               ('sql_after', 'HARNESS_NO_SQL_BEFORE_AFTER', rest),
                               ('current_user', 'HARNESS_NO_RUNTIME_ROLE', rest),
                               ('runtime_role', 'HARNESS_NO_RUNTIME_ROLE', rest),
                               ('provider_call', 'HARNESS_NO_PROVIDER_COUNT', rest),
                               ('sha256', 'HARNESS_NO_MANIFEST_HASHES', text),
                               ('input_hashes', 'HARNESS_NO_MANIFEST_HASHES', text),
                               ('NOT_RUN', 'HARNESS_DB_DOWN_MOCK_SUCCESS', text),
                               ('FIXTURE_5_8_2', 'HARNESS_NO_MODE_LABEL', text),
                               ('SYNTHETIC', 'HARNESS_NO_MODE_LABEL', text),
                               ('RUNTIME', 'HARNESS_NO_MODE_LABEL', text)]:
        if lit not in scope:
            fired.add(reason)
    return fired, set()


# ---------------------------------------------------------------- wiring ctrl

def script_candidates(tree):
    """[(rel, тело)] *.js каталога инструментов (tests/tools) с литералами drill+rpo+rto."""
    out = []
    for n in scripts_names(tree):
        rel = '%s/%s' % (tree.p('scripts_dir'), n)
        body = tree.get(rel)
        if body and all(l in code_only(body).lower() for l in ('drill', 'rpo', 'rto')):
            out.append((rel, body))
    return out

def scripts_names(tree):
    d = tree.repo / tree.p('scripts_dir')
    return sorted(p.name for p in d.glob('*.js')) if d.is_dir() else []



def find_harness_tests(tree):
    out = []
    d = tree.repo / tree.p('integ_dir')
    for p in sorted(d.rglob('*.test.js')) if d.is_dir() else []:
        rel = str(p.relative_to(tree.repo))
        if rel in tree.overlay:
            body = tree.overlay[rel]
            if body is None:
                continue
        else:
            body = None
            try:
                body = p.read_text(encoding='utf-8')
            except OSError:
                continue
        if 'helpers/harness' in body:
            out.append(rel)
    return out


DRILL_SCRIPT = 'drill:evidence'  # единый источник имени — докстринг грамматики (К2)


def drill_entry_command(tree):
    """Команда точки входа поставки: scripts['drill:evidence'] (правило Ц, звено 1)."""
    pkg = tree.get(tree.p('pkg'))
    if pkg is None:
        return None
    try:
        cmd = json.loads(pkg)['scripts'][DRILL_SCRIPT]
    except (ValueError, KeyError, TypeError):
        return None
    return cmd if isinstance(cmd, str) and cmd.strip() else None


def check_wiring(tree):
    fired = set()
    tests = find_harness_tests(tree)
    cmd = drill_entry_command(tree)
    cands = script_candidates(tree)
    wired = cmd is not None and any(rel.split('/')[-1] in cmd for rel, _ in cands)
    if not wired:
        fired.add('DRILL_MEASUREMENTS_ABSENT')
    if not tests:
        return fired | {'HARNESS_INTEGRATION_TEST_MISSING'}, {'TEST_INTEGRATION_NOT_WIRED'}
    pkg = tree.get(tree.p('pkg')) or ''
    try:
        script = json.loads(pkg)['scripts']['test:integration']
    except (ValueError, KeyError, TypeError):
        script = ''
    covered = False
    pkg_rel = tree.p('pkg_root')
    for t in tests:
        base = t[len(pkg_rel) + 1:] if pkg_rel and t.startswith(pkg_rel + '/') else t
        for pat in re.findall(r'"([^"]+)"', script):
            p2 = pat.replace('**/', '').replace('**', '*')
            if fnmatch.fnmatch(base, p2) or fnmatch.fnmatch(base, p2.replace('tests/', '')):
                covered = True
    if not covered:
        fired.add('TEST_INTEGRATION_NOT_WIRED')
    return fired, set()
CHECKS = [check_compose, check_harness, check_wiring]
def subject_control(tree):
    fired, blocked = set(), set()
    for fn in CHECKS:
        f, b = fn(tree)
        fired |= f
        blocked |= b
    return fired, {b for b in blocked if b not in fired}


# ---------------------------------------------------------------- факты

ROOT_SERVER_SHA = {
    # перебазирование 604fad1b адаптировало ПУТЯНЫЕ литералы исторического
    # SYNTHETIC-сервера к новой раскладке (server/ → tests/historical-server/,
    # db/ → migrations/, '../..' → '../../..'; diff 9+/8-, непутевых строк нет,
    # src/app.ts байтово прежний) — пин следует живому дереву, защитная функция
    # (необъявленная правка historical-байтов = красный) сохранена
    'test/harness.ts': '2ea5d921ed4a05c76a6f7ba5930e1196d2358ec793c99c29c26c37102c54eb8e',
    'src/app.ts': 'b852e8427cfc49b8c772b2835b619931b4dae2ee4b891474a80965f8d026b02e',
}


def sha256_text(s):
    return hashlib.sha256(s.encode('utf-8')).hexdigest()


def runner_damage_fact(r, node):
    nm_rel = p_of(r, 'node_modules')
    if not node or not (r / nm_rel / 'pg/package.json').is_file():
        return (None, 'NEEDS_ENV: node=%s, %s/pg=%s (npm ci в корне пакета)' % (
            bool(node), nm_rel, (r / nm_rel / 'pg/package.json').is_file()))
    with tempfile.TemporaryDirectory(prefix='stend109-') as tmp:
        dbdir = Path(tmp) / 'db-dir'
        shutil.copytree(r / p_of(r, 'db_dir'), dbdir)
        # v4: повреждается ПОСЛЕДНИЙ по сортировке .sql каталога — цель
        # выводится из дерева (миры с N<13 не имеют 013_*; жёсткий литерал
        # ломал бы факт на усечённом мире). Семантика прежняя: SHA256
        # повреждённого файла ≠ манифест → rc 1 ДО соединения с БД.
        dmg = dbdir / sorted(
            f for f in os.listdir(dbdir) if f.endswith('.sql'))[-1]
        dmg.write_bytes(dmg.read_bytes() + b'\n-- damaged\n')
        env = dict(os.environ, MIGRATION_DATABASE_URL='postgres://u:p@127.0.0.1:1/none')

        def run(*a):
            return subprocess.run([node, str(r / p_of(r, 'runner')), *a],
                                  env=env, capture_output=True, text=True, timeout=120)
        res1 = run('--db-dir', str(dbdir))
        manifest = json.loads((r / p_of(r, 'manifest')).read_text())
        entries = manifest.get('migrations') if isinstance(manifest, dict) else manifest
        res2 = None
        if isinstance(entries, list) and entries:
            man = json.loads(json.dumps(manifest))
            (man.get('migrations') if isinstance(manifest, dict) else man).pop()
            mpath = Path(tmp) / 'manifest.json'
            mpath.write_text(json.dumps(man))
            res2 = run('--db-dir', str(r / p_of(r, 'db_dir')), '--manifest', str(mpath))
        ok1 = res1.returncode != 0 and 'манифест' in (res1.stderr or '')
        ok2 = res2 is None or res2.returncode != 0
        return (ok1 and ok2,
                'повреждённый файл rc=%d «%s»; пропуск в манифесте rc=%s' % (
                    res1.returncode, (res1.stderr or '').strip()[:100],
                    'n/a' if res2 is None else res2.returncode))


def egress_fact(repo, tree=None):
    """Живой разбор сетей docker compose config: worker/sandbox/document только internal."""
    tree = tree or Tree(repo)
    compose = tree.get(tree.p('compose'))
    if compose is None:
        return (None, 'NEEDS_ENV: compose.dev.yml отсутствует (контроль судит COMPOSE_MISSING); '
                      'живой маршрут document-worker НЕ проверен')
    try:
        dc = subprocess.run(['docker', 'compose', 'version'], capture_output=True, text=True, timeout=30)
    except (OSError, subprocess.TimeoutExpired):
        dc = None
    if dc is None or dc.returncode != 0:
        return (None, 'NEEDS_ENV: docker compose недоступен — назначенные сервисам сети '
                      'и живой маршрут egress НЕ проверены')
    with tempfile.TemporaryDirectory(prefix='stend109-eg-') as tmp:
        cf = Path(tmp) / 'compose.dev.yml'
        cf.write_text(compose, encoding='utf-8')
        try:
            r = subprocess.run(['docker', 'compose', '-f', str(cf), 'config', '--format', 'json'],
                               capture_output=True, text=True, timeout=60)
        except subprocess.TimeoutExpired:
            return (False, 'docker compose config: таймаут')
    if r.returncode != 0:
        return (False, 'docker compose config rc=%d: %s' % (r.returncode, (r.stderr or '')[:150]))
    try:
        cfg = json.loads(r.stdout)
    except ValueError:
        return (False, 'docker compose config: вывод не JSON')
    nets = {k: bool(v.get('internal')) for k, v in (cfg.get('networks') or {}).items()}
    bad = []
    for name, svc in (cfg.get('services') or {}).items():
        if re.search(r'worker|sandbox|document', name):
            attached = list((svc.get('networks') or {}).keys())
            if not attached or not all(nets.get(n) for n in attached):
                bad.append('%s→%s' % (name, ','.join(attached) or 'default'))
    if bad:
        return (False, 'сервисы вне internal-сетей (живой разбор): %s' % '; '.join(bad))
    return (True, 'живой разбор compose: worker/sandbox/document только в internal-сетях')


DRILL_INPUTS = (
    {'db_dump': 'db-dump-one', 'objects_dump': 'obj-dump-one', 'keys_dump': 'key-dump-one',
     'measured_rpo_minutes': 17, 'measured_rto_minutes': 253, 'measured_at': '2026-10-19T09:30:00Z'},
    {'db_dump': 'db-dump-two', 'objects_dump': 'obj-dump-two', 'keys_dump': 'key-dump-two',
     'measured_rpo_minutes': 23, 'measured_rto_minutes': 311, 'measured_at': '2026-10-19T11:00:00Z'},
)
DRILL_TARGETS = {'target_rpo_minutes': 15, 'target_originals_within_minutes': 60,
                 'target_rto_minutes': 240}


def drill_fact(repo, tree=None):
    """Живой вызов ТОЧКИ ВХОДА ПОСТАВКИ (правило Ц, К2): команда
    scripts['drill:evidence'] исполняется в disposable-копии корня пакета, sink
    читается из DIR/drill-evidence.json самой команды."""
    tree = tree or Tree(repo)
    cmd = drill_entry_command(tree)
    if cmd is None:
        return (None, 'NEEDS_ENV: scripts[%r] в package.json отсутствует '
                      '(контроль судит DRILL_MEASUREMENTS_ABSENT); живой вызов '
                      'коллектора командой поставки НЕ проверен' % DRILL_SCRIPT)
    node = shutil.which('node')
    if not node:
        return (None, 'NEEDS_ENV: node отсутствует')
    cands = script_candidates(tree)
    coll = next(((rel, body) for rel, body in cands
                 if rel.split('/')[-1] in cmd), None)
    if coll is None:
        return (False, 'scripts[%s] не указывает на коллектор tests/tools '
                       '(drill+rpo+rto): %r' % (DRILL_SCRIPT, cmd[:100]))
    rel = coll[0]
    notes, oks = [], []
    with tempfile.TemporaryDirectory(prefix='stend109-drill-') as tmp:
        pr = tree.p('pkg_root')
        be = Path(tmp) / (pr or 'repo')
        shutil.copytree(tree.pkg_root(), be,
                        ignore=shutil.ignore_patterns('node_modules', '.git'))
        prefix = pr + '/' if pr else ''
        for orel, obody in (tree.overlay or {}).items():  # оверлей мутанта — в копию
            dest = be / orel[len(prefix):]
            if obody is None:
                if dest.is_file():
                    dest.unlink()
            else:
                dest.parent.mkdir(parents=True, exist_ok=True)
                dest.write_text(obody, encoding='utf-8')

        def run(tag, input_path=None):
            c = re.sub(r'(--out[ =])\S+', lambda m: m.group(1) + tag, cmd, count=1)
            if c == cmd and '--out' not in cmd:
                c = '%s --out %s' % (cmd, tag)
            if input_path is not None:
                c = '%s --input %s' % (c, input_path)
            return subprocess.run(['/bin/sh', '-c', c], capture_output=True,
                                  text=True, timeout=60, cwd=str(be))

        def read_ev(tag):
            try:
                return json.loads((be / tag / 'drill-evidence.json')
                                  .read_text(encoding='utf-8'))
            except (OSError, ValueError):
                return {}
        r0 = run('A')
        ev = read_ev('A')
        ok0 = (r0.returncode == 0 and ev.get('status') == 'NOT_RUN'
               and all(ev.get(k) == v for k, v in DRILL_TARGETS.items())
               and not ev.get('measured_rpo_minutes'))
        oks.append(ok0)
        notes.append('команда поставки без входа: rc=%d status=%r' % (
            r0.returncode, ev.get('status')))
        for i, inp in enumerate(DRILL_INPUTS):
            ipath = Path(tmp) / ('in%d.json' % i)
            ipath.write_text(json.dumps(inp), encoding='utf-8')
            ri = run('B%d' % i, str(ipath))
            evi = read_ev('B%d' % i)
            want = {'status': 'MEASURED', 'db_hash': sha256_text(inp['db_dump']),
                    'object_hash': sha256_text(inp['objects_dump']),
                    'key_hash': sha256_text(inp['keys_dump']),
                    'measured_rpo_minutes': inp['measured_rpo_minutes'],
                    'measured_rto_minutes': inp['measured_rto_minutes'],
                    'measured_at': inp['measured_at']}
            want.update(DRILL_TARGETS)
            bad = ['%s=%r≠%r' % (k, evi.get(k), v) for k, v in want.items() if evi.get(k) != v]
            oks.append(ri.returncode == 0 and not bad)
            notes.append('вход%d: rc=%d status=%r %s' % (
                i, ri.returncode, evi.get('status'), '; '.join(bad[:3]) or 'ок'))
    return (all(oks), 'команда поставки scripts[%s] → %s: %s' % (
        DRILL_SCRIPT, rel, ' | '.join(notes)))


HARNESS_OBS = (
    {'mode': 'FIXTURE_5_8_2',
     'http_request': {'method': 'POST', 'url': '/api/v1/documents/one',
                      'headers': {'authorization': 'tok_SENTINEL_A1'}},
     'http_response': {'status': 201, 'body': 'created-one'},
     'sql_before': 'SELECT count(*) FROM documents /* BEFORE-ONE */',
     'sql_after': 'SELECT count(*) FROM documents /* AFTER-ONE */',
     'runtime_role': 'hc_api_role_one', 'provider_calls': 2,
     'inputs': {'payload_one': 'omega-bytes-one', 'meta_one': '111'},
     'secrets': ['tok_SENTINEL_A1']},
    {'mode': 'SYNTHETIC',
     'http_request': {'method': 'GET', 'url': '/api/v1/documents/two'},
     'http_response': {'status': 200, 'body': 'fetched-two for sentinel-two@example.com'},
     'sql_before': 'SELECT id FROM documents /* BEFORE-TWO */',
     'sql_after': 'SELECT id FROM documents /* AFTER-TWO */',
     'runtime_role': 'hc_api_role_two', 'provider_calls': 5,
     'inputs': {'payload_two': 'sigma-bytes-two'},
     'secrets': ['sentinel-two@example.com']},
    {'mode': 'RUNTIME',
     'http_request': {'method': 'PUT', 'url': '/api/v1/documents/three',
                      'headers': {'authorization': 'tok_SENTINEL_B2'}},
     'http_response': {'status': 200,
                       'body': 'updated-three note:SENTINEL_PLAIN_C4'},
     'sql_before': 'SELECT id FROM documents /* BEFORE-THREE */',
     'sql_after': 'SELECT id FROM documents /* AFTER-THREE */',
     'runtime_role': 'hc_api_role_three', 'provider_calls': 7,
     'inputs': {'payload_three': 'theta-bytes-three'},
     'secrets': ['tok_SENTINEL_B2', 'SENTINEL_PLAIN_C4']},
)

HARNESS_DRIVER = """
'use strict';
const fs = require('fs'), path = require('path');
const harness = require(process.argv[2]);
const dir = process.argv[3], obsList = JSON.parse(fs.readFileSync(process.argv[4], 'utf8'));
const list = () => fs.readdirSync(dir).sort().map(n => [n, fs.readFileSync(path.join(dir, n), 'utf8')]);
try {
  fs.mkdirSync(dir, { recursive: true });
  const before = list();
  const entries = [], afters = [];
  for (const obs of obsList) {
    entries.push(harness.recordInteraction(JSON.parse(JSON.stringify(obs)), dir));
    afters.push(list());
  }
  console.log(JSON.stringify({ entries, before, afters }));
} catch (e) {
  console.log(JSON.stringify({ error: String((e && e.message) || e) }));
}
"""


HARNESS_AXES = ('http_request', 'http_response', 'sql_before', 'sql_after',
                'runtime_role', 'provider_calls')


def leaf_match(exp, act, secrets):
    """Сверка значения оси (правило Ц, звено 3 — чтение из sink): строка,
    несущая сентинел, обязана в файле присутствовать, быть непустой и без
    сентинела (форма К4 «не равно сентинелу и не пусто»); прочее — exact."""
    if isinstance(exp, dict):
        if not isinstance(act, dict) or set(exp) != set(act):
            return False
        return all(leaf_match(exp[k], act[k], secrets) for k in exp)
    if isinstance(exp, list):
        if not isinstance(act, list) or len(exp) != len(act):
            return False
        return all(leaf_match(x, y, secrets) for x, y in zip(exp, act))
    if isinstance(exp, str) and any(s in exp for s in secrets):
        return (isinstance(act, str) and act != ''
                and not any(s in act for s in secrets))
    return exp == act


def harness_fact(repo, tree=None):
    """Живое исполнение recordInteraction (правило Ц): mode, шесть осей и
    input_hashes читаются из СОХРАНЁННЫХ файлов, сопоставленных наблюдениям
    по порядку создания; return — дополнительная сверка; append-only — ровно
    три файла, прежние неизменны; сентинелы в файлах отсутствуют."""
    tree = tree or Tree(repo)
    body = tree.get(tree.p('harness'))
    if body is None:
        return (None, 'NEEDS_ENV: harness.js отсутствует (контроль судит HARNESS_MISSING)')
    node = shutil.which('node')
    if not node:
        return (None, 'NEEDS_ENV: node отсутствует')
    with tempfile.TemporaryDirectory(prefix='stend109-h-') as tmp:
        h = Path(tmp) / 'harness.js'
        h.write_text(body, encoding='utf-8')
        driver = Path(tmp) / 'driver.js'
        driver.write_text(HARNESS_DRIVER, encoding='utf-8')
        obs = Path(tmp) / 'obs.json'
        obs.write_text(json.dumps(HARNESS_OBS), encoding='utf-8')
        try:
            r = subprocess.run([node, str(driver), str(h), str(Path(tmp) / 'ev'), str(obs)],
                               capture_output=True, text=True, timeout=60, cwd=tmp)
        except subprocess.TimeoutExpired:
            return (False, 'драйвер recordInteraction: таймаут')
        try:
            out = json.loads(r.stdout)
        except ValueError:
            return (False, 'драйвер rc=%d: stdout=%r stderr=%r' % (
                r.returncode, r.stdout[:120], r.stderr[:200]))
    if 'error' in out:
        return (False, 'recordInteraction: %s' % out['error'][:200])
    entries, notes = out.get('entries') or [], []
    afters = [out.get('before') or []] + list(out.get('afters') or [])
    ok = len(entries) == len(HARNESS_OBS) and len(afters) == len(HARNESS_OBS) + 1
    if not ok:
        notes.append('записей %d (ожидалось %d)' % (len(entries), len(HARNESS_OBS)))
    # сопоставление файлов наблюдениям по порядку создания (звено 2: субъект
    # сам создаёт sink; батарея его не подменяет)
    prev, files_by_obs = {}, []
    for i, step in enumerate(afters[1:]):
        cur = {n: c for n, c in step}
        for n, c in prev.items():
            if cur.get(n) != c:
                ok = False
                notes.append('append-only: %s изменён после записи %d' % (n, i))
        new = [n for n in cur if n not in prev]
        if len(new) != 1:
            ok = False
            notes.append('запись %d: новых файлов %d (ожидался 1)' % (i, len(new)))
            files_by_obs.append(None)
        else:
            files_by_obs.append(new[0])
        prev = cur
    final_map = {n: c for n, c in afters[-1]} if afters else {}
    for i, obs_i in enumerate(HARNESS_OBS):
        # звено 3: ожидания сравниваются со значениями, ПРОЧИТАННЫМИ из файла
        if i < len(files_by_obs) and files_by_obs[i] is not None:
            name = files_by_obs[i]
            raw = final_map.get(name)
            try:
                f = json.loads(raw)
            except ValueError:
                ok = False
                notes.append('запись %d: %s не JSON' % (i, name))
                f = None
            if f is not None:
                if f.get('mode') != obs_i['mode']:
                    ok = False
                    notes.append('запись %d: mode из файла %r≠%r' % (
                        i, f.get('mode'), obs_i['mode']))
                for axis in HARNESS_AXES:
                    if not leaf_match(obs_i[axis], f.get(axis), obs_i['secrets']):
                        ok = False
                        notes.append('запись %d: ось %s из файла ≠ наблюдению' % (i, axis))
                want_hashes = {k: sha256_text(v) for k, v in obs_i['inputs'].items()}
                if f.get('input_hashes') != want_hashes:
                    ok = False
                    notes.append('запись %d: input_hashes из файла ≠ sha256 входов' % i)
                for s in obs_i['secrets']:
                    if s in (raw or ''):
                        ok = False
                        notes.append('scrubber: %s в %s' % (s, name))
        # возвращённый кортеж — дополнительная, не замещающая сверка
        if i < len(entries):
            e = entries[i] or {}
            for axis in HARNESS_AXES:
                if e.get(axis) != obs_i[axis]:
                    ok = False
                    notes.append('взаимодействие%d: ось %s (return)=%r≠%r' % (
                        i, axis, e.get(axis), obs_i[axis]))
            for k, v in obs_i['inputs'].items():
                if (e.get('input_hashes') or {}).get(k) != sha256_text(v):
                    ok = False
                    notes.append('взаимодействие%d: input_hashes[%s] (return)≠%s' % (
                        i, k, sha256_text(v)))
    all_secrets = [s for o in HARNESS_OBS for s in o['secrets']]
    for name, text_file in (afters[-1] if afters else []):
        for s in all_secrets:
            if s in text_file:
                ok = False
                notes.append('scrubber: %s в %s' % (s, name))
    return (ok, 'живое recordInteraction: %s' % (
        '; '.join(notes[:6]) or 'режимы/оси/хэши из файла, append-only, scrubber ок'))


# ---------------------------------------------------------------- факты круга 2

def drill_input_fact(repo, tree=None):
    """Живая честность входов drill-коллектора (F2): measured_* null/строка —
    отказ rc≠0 без MEASURED; повторный прогон в тот же --out не перезаписывает
    измеренный evidence (байты файла неизменны)."""
    tree = tree or Tree(repo)
    cmd = drill_entry_command(tree)
    if cmd is None:
        return (None, 'NEEDS_ENV: scripts[%r] в package.json отсутствует '
                      '(контроль судит DRILL_MEASUREMENTS_ABSENT); валидация входов '
                      'и append-only drill-evidence НЕ проверены' % DRILL_SCRIPT)
    node = shutil.which('node')
    if not node:
        return (None, 'NEEDS_ENV: node отсутствует')
    cands = script_candidates(tree)
    coll = next(((rel, body) for rel, body in cands
                 if rel.split('/')[-1] in cmd), None)
    if coll is None:
        return (False, 'scripts[%s] не указывает на коллектор tests/tools '
                       '(drill+rpo+rto): %r' % (DRILL_SCRIPT, cmd[:100]))
    notes, oks = [], []
    with tempfile.TemporaryDirectory(prefix='stend109-drillin-') as tmp:
        pr = tree.p('pkg_root')
        be = Path(tmp) / (pr or 'repo')
        shutil.copytree(tree.pkg_root(), be,
                        ignore=shutil.ignore_patterns('node_modules', '.git'))
        prefix = pr + '/' if pr else ''
        for orel, obody in (tree.overlay or {}).items():
            dest = be / orel[len(prefix):]
            if obody is None:
                if dest.is_file():
                    dest.unlink()
            else:
                dest.parent.mkdir(parents=True, exist_ok=True)
                dest.write_text(obody, encoding='utf-8')

        def run(tag, input_path=None):
            c = re.sub(r'(--out[ =])\S+', lambda m: m.group(1) + tag, cmd, count=1)
            if c == cmd and '--out' not in cmd:
                c = '%s --out %s' % (cmd, tag)
            if input_path is not None:
                c = '%s --input %s' % (c, input_path)
            return subprocess.run(['/bin/sh', '-c', c], capture_output=True,
                                  text=True, timeout=60, cwd=str(be))

        def ev(tag):
            try:
                return (be / tag / 'drill-evidence.json').read_text(encoding='utf-8')
            except OSError:
                return None
        badnull = {'db_dump': 'DB', 'objects_dump': 'OBJ', 'keys_dump': 'KEYS',
                   'measured_rpo_minutes': None, 'measured_rto_minutes': None,
                   'measured_at': None}
        good = {'db_dump': 'DB-REAL', 'objects_dump': 'OBJ', 'keys_dump': 'KEYS',
                'measured_rpo_minutes': 7, 'measured_rto_minutes': 90,
                'measured_at': '2026-10-20T00:00:00Z'}
        # F2'/С5 (круг 3): каждое измеренное поле портится В ОТДЕЛЬНОСТИ —
        # остальные чисты. Круг 4 (A-4, I-2): строгая ISO-грамматика ПО ПОЛЯМ —
        # формы, которые Date.parse-декой 8aca71a ПРОПУСКАЕТ (З-1 арбитража),
        # строгая грамматика OBJECT-4 обязана отвергать
        perfield = (('at_never', {'measured_at': 'never'}),
                    ('at_ok', {'measured_at': 'ok'}),
                    ('at_noniso', {'measured_at': '2026-13-45T99:99:99Z'}),
                    ('at_never1', {'measured_at': 'never 1'}),
                    ('at_one', {'measured_at': '1'}),
                    ('at_may5', {'measured_at': 'May 5'}),
                    ('at_mmddyyyy', {'measured_at': '12/31/2026'}),
                    ('at_feb31', {'measured_at': '2026-02-31'}),
                    ('at_feb31t', {'measured_at': '2026-02-31T00:00:00Z'}),
                    ('at_dateonly', {'measured_at': '2026-10-20'}),
                    ('at_nozone', {'measured_at': '2026-10-20T03:00:00'}),
                    ('rpo_negative', {'measured_rpo_minutes': -5}),
                    ('rto_negative', {'measured_rto_minutes': -1}),
                    ('rpo_string', {'measured_rpo_minutes': 'ok'}),
                    ('rto_string', {'measured_rto_minutes': 'fine'}))
        runs = [('badnull', badnull)]
        for ptag, patch in perfield:
            payload = dict(good)
            payload.update(patch)
            runs.append((ptag, payload))
        for fname, payload in runs:
            ip = Path(tmp) / ('%s.json' % fname)
            ip.write_text(json.dumps(payload), encoding='utf-8')
            r = run('D_' + fname, str(ip))
            text = ev('D_' + fname)
            leaked = bool(text and 'MEASURED' in text)
            oks.append(r.returncode != 0 and not leaked)
            notes.append('%s: rc=%d MEASURED-в-файле=%s' % (
                fname, r.returncode, leaked))
        ip = Path(tmp) / 'good.json'
        ip.write_text(json.dumps(good), encoding='utf-8')
        r1 = run('KEEP', str(ip))
        first = ev('KEEP')
        ok1 = r1.returncode == 0 and first is not None and '"MEASURED"' in first
        oks.append(ok1)
        notes.append('измеренный: rc=%d MEASURED=%s' % (
            r1.returncode, bool(first and '"MEASURED"' in first)))
        r2 = run('KEEP')
        second = ev('KEEP')
        oks.append(ok1 and second == first)
        notes.append('повтор в тот же --out: rc=%d файл-неизменен=%s' % (
            r2.returncode, second == first))
        # A-4 (I-2): положительная форма со смещённой зоной и дробной секундой
        good_off = dict(good, measured_at='2026-10-19T09:30:00.123+03:00')
        ipo = Path(tmp) / 'good_offset.json'
        ipo.write_text(json.dumps(good_off), encoding='utf-8')
        ro = run('KOFF', str(ipo))
        fo = ev('KOFF')
        oks.append(ro.returncode == 0 and fo is not None and '"MEASURED"' in fo)
        notes.append('измеренный +03:00: rc=%d MEASURED=%s' % (
            ro.returncode, bool(fo and '"MEASURED"' in fo)))
    return (all(oks), 'drill входы/append-only: %s' % ' | '.join(notes))


HARNESS_HONESTY_DRIVER = """
'use strict';
const fs = require('fs'), path = require('path');
const harness = require(process.argv[2]);
const base = process.argv[3];
process.env.COMPLIOR_HARNESS_DATABASE_URL = 'postgres://x:y@127.0.0.1:1/z';
const attempt = (fn) => Promise.resolve()
  .then(fn)
  .then((r) => ({ threw: false, result: r }))
  .catch((e) => ({ threw: true, err: String((e && e.message) || e) }));
const obsBase = { http_request: { method: 'GET', url: 'http://127.0.0.1:1/fixture' },
  http_response: { status: 200 }, sql_before: 'S1', sql_after: 'S2',
  runtime_role: 'hc_fixture', provider_calls: 0, inputs: {} };
(async () => {
  const out = { has_rec: typeof harness.recordInteraction === 'function' };
  out.has_async = typeof harness.recordInteractionAsync === 'function';
  out.no_mode = await attempt(() => harness.recordInteraction(
    Object.assign({}, obsBase), path.join(base, 'h1')));
  out.mock_mode = await attempt(() => harness.recordInteraction(
    Object.assign({}, obsBase, { mode: 'MOCK_SUCCESS' }), path.join(base, 'h4')));
  if (out.has_async) {
    out.mock_mode_async = await attempt(() => harness.recordInteractionAsync(
      Object.assign({}, obsBase, { mode: 'MOCK_SUCCESS' }), path.join(base, 'h5')));
    out.db_down = await attempt(() => harness.recordInteractionAsync(
      Object.assign({}, obsBase, { mode: 'RUNTIME' }), path.join(base, 'h3')));
  } else {
    out.db_down = await attempt(() => harness.recordInteraction(
      Object.assign({}, obsBase, { mode: 'RUNTIME' }), path.join(base, 'h3')));
  }
  out.files = {};
  for (const d of ['h1', 'h4', 'h5', 'h3']) {
    try {
      out.files[d] = fs.readdirSync(path.join(base, d))
        .map((n) => fs.readFileSync(path.join(base, d, n), 'utf8'));
    } catch (e) { out.files[d] = null; }
  }
  console.log(JSON.stringify(out));
})().catch((e) => console.log(JSON.stringify({ fatal: String((e && e.message) || e) })));
"""


def harness_honesty_fact(repo, tree=None):
    """Живая честность записи harness (F3) на поверхности ПОСТАВКИ: контракт
    называет recordInteraction; живой путь «реальный HTTP между SQL-снимками»
    поставка объявляет recordInteractionAsync (harness.test.js; имя внутренней
    функции-детали не закрепляется). Без mode → отказ (throw) И файл не
    создаётся; mode только из трёх литералов (обе ветки); недоступная БД →
    throw ИЛИ NOT_RUN, никогда MEASURED/успех."""
    tree = tree or Tree(repo)
    body = tree.get(tree.p('harness'))
    if body is None:
        return (None, 'NEEDS_ENV: harness.js отсутствует (контроль судит HARNESS_MISSING)')
    node = shutil.which('node')
    if not node:
        return (None, 'NEEDS_ENV: node отсутствует')
    with tempfile.TemporaryDirectory(prefix='stend109-hon-') as tmp:
        h = Path(tmp) / 'harness.js'
        h.write_text(body, encoding='utf-8')
        d = Path(tmp) / 'driver.js'
        d.write_text(HARNESS_HONESTY_DRIVER, encoding='utf-8')
        ev = Path(tmp) / 'ev'
        try:
            r = subprocess.run([node, str(d), str(h), str(ev)],
                               capture_output=True, text=True, timeout=60, cwd=tmp)
        except subprocess.TimeoutExpired:
            return (False, 'драйвер честности: таймаут')
        try:
            out = json.loads(r.stdout)
        except ValueError:
            return (False, 'драйвер честности rc=%d: stdout=%r stderr=%r' % (
                r.returncode, r.stdout[:100], (r.stderr or '')[:150]))
    if 'fatal' in out:
        return (False, 'честность записи: %s' % out['fatal'][:200])
    if not out.get('has_rec'):
        return (False, 'recordInteraction не экспортирован — поверхность '
                       'честности (mode/NOT_RUN), названная контрактом, '
                       'недоступна вызывающему')
    notes, ok = [], True
    if not (out.get('no_mode') or {}).get('threw'):
        ok = False
        notes.append('без mode: отказа нет (mode выдуман)')
    if not (out.get('mock_mode') or {}).get('threw'):
        ok = False
        notes.append('MOCK_SUCCESS принят (recordInteraction)')
    if out.get('has_async') and not (out.get('mock_mode_async') or {}).get('threw'):
        ok = False
        notes.append('MOCK_SUCCESS принят (recordInteractionAsync)')
    dd = out.get('db_down') or {}
    honest_down = dd.get('threw') or (isinstance(dd.get('result'), dict) and (
        (dd['result'].get('db_snapshot') or {}).get('status') == 'NOT_RUN'
        or dd['result'].get('status') == 'NOT_RUN'))
    if not honest_down:
        ok = False
        notes.append('БД недоступна: не отказ и не NOT_RUN')
    files = out.get('files') or {}
    for dname in ('h1', 'h4', 'h5'):
        if files.get(dname):
            ok = False
            notes.append('файл записан при отказном mode (%s) — выдумка в sink' % dname)
    for dname, texts in files.items():
        for t in texts or []:
            if 'MEASURED' in t:
                ok = False
                notes.append('MEASURED в файле %s при недоступной БД' % dname)
    return (ok, 'честность записи (recordInteraction%s): %s' % (
        '/recordInteractionAsync' if out.get('has_async') else '',
        '; '.join(notes[:5]) or
        'без mode → отказ и без файла; литералы на обеих ветках; '
        'БД недоступна → NOT_RUN'))


# круг 4 (A-6, I-6): входы по ВСЕМ формам замкнутого перечня арбитража —
# закрытый язык (ключи из K в заголовках, все формы значений) и открытый
# (тела: «Cookie:», «Authorization:», JSON-формы, телефоны РФ двумя формами)
HARNESS_PII_OBS = {
    'mode': 'RUNTIME',
    'http_request': {'method': 'GET', 'url': '/api/v1/patients/1',
                     'headers': {'authorization': 'BARESYNCTOKEN77',
                                 'cookie': ['session=SECRETSESSION; x=y',
                                            'RAWCOOKIEARRSYNC2'],
                                 'proxy-authorization': 'Basic cHJ4eHlzeW5jOTE=',
                                 'x-api-key': 'XAPIKEYSYNC88',
                                 'x-doc-token': 'Bearer eyJhbGciOiJIUzI1NiJ9.REAL.TOKEN',
                                 'x-claim': 'tok"Q\\Z'}},
    'http_response': {'status': 200,
                      'headers': {'set-cookie': 'NOEQSETCOOKIESYNC',
                                  'authorization': 'Basic dXNlcjpwYXNzSYNC'},
                      'body': ('patient ivan.petrov@clinic.ru, phone +7 916 000-00-00\n'
                               'Cookie: sid=BODYCOOKIESYNC5\n'
                               'Authorization: Basic BODYAUTHSYNC6\n'
                               '{"cookie":["BODYJSONCKSYNC7"]}\n'
                               '{"authorization":"BODYJSONAUTHSYNC8"}\n'
                               'телефоны: 89160000000 и 8 916 000 00 00')},
    'sql_before': 'SELECT 1 /* PII-B */',
    'sql_after': 'SELECT 2 /* PII-A */',
    'runtime_role': 'hc_api_role_pii', 'provider_calls': 1,
    'inputs': {'note': 'kappa-bytes-pii'},
    'secrets': ['tok"Q\\Z'],
}

PII_FORBIDDEN = ['eyJhbGciOiJIUzI1NiJ9.REAL.TOKEN', 'SECRETSESSION',
                 'ivan.petrov@clinic.ru', '+7 916 000-00-00', 'tok"Q\\Z',
                 'BARESYNCTOKEN77', 'RAWCOOKIEARRSYNC2', 'cHJ4eHlzeW5jOTE=',
                 'XAPIKEYSYNC88', 'NOEQSETCOOKIESYNC', 'dXNlcjpwYXNzSYNC',
                 'BODYCOOKIESYNC5', 'BODYAUTHSYNC6', 'BODYJSONCKSYNC7',
                 'BODYJSONAUTHSYNC8', '89160000000', '8 916 000 00 00']

HARNESS_PII_DRIVER = """
'use strict';
const fs = require('fs'), path = require('path');
const harness = require(process.argv[2]);
const dir = process.argv[3], obs = JSON.parse(fs.readFileSync(process.argv[4], 'utf8'));
const rec = harness.recordInteraction(obs, dir);
const files = fs.readdirSync(dir).sort()
  .map((n) => [n, fs.readFileSync(path.join(dir, n), 'utf8')]);
console.log(JSON.stringify({ rec, files }));
"""


def harness_pii_fact(repo, tree=None):
    """Живой scrubber PII (F4): необъявленные Bearer/cookie/email/phone и
    объявленный секрет с "/\\ не попадают в sink ни raw-, ни JSON-экранированной
    формой; запись не вакуумна (правило Ц, звено 3 — чтение из файла)."""
    tree = tree or Tree(repo)
    body = tree.get(tree.p('harness'))
    if body is None:
        return (None, 'NEEDS_ENV: harness.js отсутствует (контроль судит HARNESS_MISSING)')
    node = shutil.which('node')
    if not node:
        return (None, 'NEEDS_ENV: node отсутствует')
    with tempfile.TemporaryDirectory(prefix='stend109-pii-') as tmp:
        h = Path(tmp) / 'harness.js'
        h.write_text(body, encoding='utf-8')
        d = Path(tmp) / 'driver.js'
        d.write_text(HARNESS_PII_DRIVER, encoding='utf-8')
        o = Path(tmp) / 'obs.json'
        o.write_text(json.dumps(HARNESS_PII_OBS), encoding='utf-8')
        ev = Path(tmp) / 'ev'
        try:
            r = subprocess.run([node, str(d), str(h), str(ev), str(o)],
                               capture_output=True, text=True, timeout=60, cwd=tmp)
        except subprocess.TimeoutExpired:
            return (False, 'драйвер PII: таймаут')
        try:
            out = json.loads(r.stdout)
        except ValueError:
            return (False, 'драйвер PII rc=%d: stdout=%r stderr=%r' % (
                r.returncode, r.stdout[:100], (r.stderr or '')[:150]))
    files = out.get('files') or []
    if not files:
        return (False, 'recordInteraction не создал файл evidence')
    forbidden = []
    for v in PII_FORBIDDEN:
        forbidden.append(v)
        esc = json.dumps(v)[1:-1]
        if esc != v:
            forbidden.append(esc)
    notes, ok = [], True
    for name, text_file in files:
        for v in forbidden:
            if v in text_file:
                ok = False
                notes.append('утечка %r в %s' % (v[:26], name))
    rec = None
    for name, text_file in files:
        try:
            rec = json.loads(text_file)
        except ValueError as e:
            pos = getattr(e, 'pos', None)
            frag = ('…%s…' % text_file[max(0, pos - 45):pos + 45].replace(
                '\n', '\\n')) if isinstance(pos, int) else text_file[:90]
            return (False, 'файл evidence %s не JSON (правило Ц, звено 3: '
                           'потребитель поставки читает evidence JSON.parse — '
                           'scrubber разрушил структуру сериализованного '
                           'текста): %s' % (name, frag))
    headers = (rec.get('http_request') or {}).get('headers') or {}
    if not isinstance(headers.get('authorization'), str) or not headers.get('authorization'):
        ok = False
        notes.append('authorization выпадена (вакуумная вырезка)')
    # круг 4 (A-6): форма К4 — сентинела нет, но ПОЛЕ присутствует и непусто
    # (маскирование не равно вырезанию оси; литерал [REDACTED] не навязывается)
    ck = headers.get('cookie')
    if not (isinstance(ck, list) and ck
            and all(isinstance(x, str) and x for x in ck)):
        ok = False
        notes.append('cookie-массив выпаден/пуст (%r)' % (ck,))
    for hkey in ('proxy-authorization', 'x-api-key'):
        if not isinstance(headers.get(hkey), str) or not headers.get(hkey):
            ok = False
            notes.append('%s выпаден (вакуумная вырезка)' % hkey)
    rheaders = (rec.get('http_response') or {}).get('headers') or {}
    for hkey in ('set-cookie', 'authorization'):
        if not isinstance(rheaders.get(hkey), str) or not rheaders.get(hkey):
            ok = False
            notes.append('response %s выпаден (вакуумная вырезка)' % hkey)
    resp_body = (rec.get('http_response') or {}).get('body')
    if not isinstance(resp_body, str) or 'patient' not in resp_body:
        ok = False
        notes.append('тело ответа потеряно (вакуумная вырезка)')
    if rec.get('mode') != HARNESS_PII_OBS['mode']:
        ok = False
        notes.append('mode из файла %r' % rec.get('mode'))
    return (ok, 'PII/scrubber: %s' % ('; '.join(notes[:5]) or
            'Bearer/cookie/email/phone/экранированный секрет отсутствуют в sink'))


def stend_up_fact(repo, tree=None):
    """Живой подъём стенда одной командой (F1/Б1): up -d --wait rc 0,
    ledger control.schema_migration = N — числу записей манифеста
    МИГРАЦИЙ ДЕРЕВА ПОД ПРОВЕРКОЙ (v4: без зашитой константы; манифест
    сломан — красная клетка с именованной причиной, не молчаливое
    ожидание), повтор rc 0 и ledger прежний; down -v после прогона;
    уникальный -p, published-портов не занимается."""
    tree = tree or Tree(repo)
    compose = tree.get(tree.p('compose'))
    if compose is None:
        return (None, 'NEEDS_ENV: compose.dev.yml отсутствует (контроль судит '
                      'COMPOSE_MISSING); живой подъём стенда НЕ проверен')
    try:
        expected = str(len(manifest_entries(tree)))
    except ManifestError as e:
        return (False, 'манифест миграций дерева под проверкой: %s — '
                       'ожидание ledger не выводимо (fail-closed, v4); '
                       'живой стенд с достоверным ожиданием невозможен' % e.reason)
    try:
        dc = subprocess.run(['docker', 'compose', 'version'],
                            capture_output=True, text=True, timeout=30)
        if dc.returncode != 0:
            dc = None
    except (OSError, subprocess.TimeoutExpired):
        dc = None
    if dc is None:
        return (None, 'NEEDS_ENV: docker compose недоступен — живой подъём стенда '
                      '(миграция до API, ledger=N по манифесту (%s), повтор, том '
                      'PG18) НЕ проверен' % expected)
    project = 'stend109up%s' % uuid.uuid4().hex[:8]
    repo_p = Path(repo)
    cwd = repo_p
    cf = repo_p / tree.p('compose')
    tmpdir = None
    becopy = None
    if tree.overlay:
        # релоцированная копия: относительные bind-пути → абсолютные от корня
        # ПАКЕТА (новая структура — корень репо, старая — backend/). Оверлей
        # под пакет (например role-bootstrap M7) обязан попасть в
        # bind-монтируемое дерево — иначе мутант не наблюдается живьём.
        pkg_rel = tree.p('pkg_root')
        pkg_p = tree.pkg_root()
        prefix = pkg_rel + '/' if pkg_rel else ''
        if any(k == pkg_rel or k.startswith(prefix) for k in tree.overlay):
            becopy = Path(tempfile.mkdtemp(prefix='stend109-pkg-')) / (pkg_rel or 'repo')
            shutil.copytree(pkg_p, becopy,
                            ignore=shutil.ignore_patterns('node_modules', '.git'))
            for orel, obody in tree.overlay.items():
                if orel != pkg_rel and not orel.startswith(prefix):
                    continue
                dest = becopy / orel[len(prefix):]
                if obody is None:
                    if dest.is_file():
                        dest.unlink()
                else:
                    dest.parent.mkdir(parents=True, exist_ok=True)
                    dest.write_text(obody, encoding='utf-8')
            os.symlink(repo_p / tree.p('node_modules'), becopy / 'node_modules')
        tmpdir = tempfile.mkdtemp(prefix='stend109-up-')
        text = compose
        base = becopy if becopy is not None else pkg_p
        if becopy is not None:
            text = re.sub(r'^(\s*-\s*)\.\./backend/([^:\s]+):',
                          lambda m: '%s%s:' % (m.group(1), becopy / m.group(2)),
                          text, flags=re.M)
            text = re.sub(r'^(\s*-\s*)\.\./backend:',
                          lambda m: '%s%s:' % (m.group(1), becopy), text, flags=re.M)
        text = re.sub(r'^(\s*-\s*)\./:$',
                      lambda m: '%s%s:' % (m.group(1), base), text, flags=re.M)
        text = re.sub(r'^(\s*-\s*)\./([^:\s]+):',
                      lambda m: '%s%s:' % (m.group(1), base / m.group(2)),
                      text, flags=re.M)
        text = re.sub(r'^(\s*-\s*)\.\./([^:\s]+):',
                      lambda m: '%s%s:' % (m.group(1), (repo_p / m.group(2)).resolve()),
                      text, flags=re.M)
        text = re.sub(r'context:\s*\.\s*$', 'context: %s' % base, text, flags=re.M)
        cf = Path(tmpdir) / 'compose.dev.yml'
        cf.write_text(text, encoding='utf-8')
        cwd = Path(tmpdir)
    notes, oks = [], []
    try:
        def dcompose(*a, timeout=420):
            return subprocess.run(['docker', 'compose', '-p', project, '-f', str(cf), *a],
                                  capture_output=True, text=True, timeout=timeout,
                                  cwd=str(cwd))
        def psql(sql, timeout=60):
            return dcompose('exec', '-T', pgsvc, 'sh', '-lc',
                            'psql -U "${POSTGRES_USER:-postgres}" '
                            '-d "${POSTGRES_DB:-postgres}" -tAc "%s"' % sql,
                            timeout=timeout)
        ledger_sql = ('SELECT count(*) FROM control.schema_migration')
        ledger_rows_sql = ('SELECT version, name, file_sha256, applied_by '
                           'FROM control.schema_migration ORDER BY version')
        blocks = service_blocks(services_section(compose))
        pgsvc = next((n for n, blk in blocks.items()
                      if re.search(r'image:\s*\S*postgres', blk or '')), None)
        # С7/M8: пользователь DATABASE_URL блока api — ROLE_NAME role-bootstrap,
        # не суперпользователь postgres-сервиса
        role_m = re.search(r'ROLE_NAME:\s*(\S+)',
                           blocks.get('role-bootstrap', '') or '')
        role_name = role_m.group(1) if role_m else 'hc_synthetic_only'
        api_m = re.search(r'DATABASE_URL:\s*postgres://([^:@/\s]+):',
                          blocks.get('api', '') or '')
        api_user = api_m.group(1) if api_m else None
        su_m = re.search(r'POSTGRES_USER:\s*(\S+)',
                         blocks.get(pgsvc, '') or '') if pgsvc else None
        su_user = su_m.group(1) if su_m else 'postgres'
        r1 = dcompose('up', '-d', '--wait')
        oks.append(r1.returncode == 0)
        notes.append('up -d --wait: rc=%d %s' % (
            r1.returncode, (r1.stderr or '').strip()[:110]))
        rows1 = None
        if r1.returncode == 0:
            if pgsvc is None:
                oks.append(False)
                notes.append('сервис PG не найден для ledger-проверки')
            else:
                q = psql(ledger_sql)
                led = (q.stdout or '').strip()
                oks.append(q.returncode == 0 and led == expected)
                notes.append('ledger=%r rc=%d' % (led, q.returncode))
                # С7/M7: LOGIN-роль role-bootstrap живьём в pg_roles — не суперпользователь
                qr = psql("SELECT rolsuper::int || '|' || rolcanlogin::int "
                          "FROM pg_roles WHERE rolname = '%s'" % role_name)
                rl = (qr.stdout or '').strip()
                oks.append(qr.returncode == 0 and rl == '0|1')
                notes.append('роль %s: rolsuper|canlogin=%r' % (role_name, rl))
                ql = psql(ledger_rows_sql)
                rows1 = (ql.stdout or '').strip()
            # С7/M8: api ходит в БД заявленной LOGIN-ролью, не суперпользователем
            ok_ident = (api_user is not None and api_user == role_name
                        and api_user != su_user)
            oks.append(ok_ident)
            notes.append('api DATABASE_URL user=%r (ROLE_NAME=%r, суперпользователь=%r)'
                         % (api_user, role_name, su_user))
            r2 = dcompose('up', '-d', '--wait')
            led2, rows2 = None, None
            if pgsvc is not None:
                q2 = psql(ledger_sql)
                led2 = (q2.stdout or '').strip()
                ok3 = r2.returncode == 0 and q2.returncode == 0 and led2 == expected
                # С7/M9: ledger между повторными up неизменен ПО СОДЕРЖИМОМУ строк
                q3 = psql(ledger_rows_sql)
                rows2 = (q3.stdout or '').strip()
                ok3 = ok3 and q3.returncode == 0 and rows2 == rows1 and bool(rows1)
            else:
                ok3 = False
            oks.append(ok3)
            notes.append('повтор: rc=%d ledger=%r содержимое-строк-неизменно=%s'
                         % (r2.returncode, led2, rows2 == rows1 and bool(rows1)))
    finally:
        try:
            subprocess.run(['docker', 'compose', '-p', project, '-f', str(cf),
                            'down', '-v', '--remove-orphans'],
                           capture_output=True, text=True, timeout=120, cwd=str(cwd))
        except (OSError, subprocess.TimeoutExpired):
            pass
        if tmpdir:
            shutil.rmtree(tmpdir, ignore_errors=True)
    return (all(oks), 'живой стенд (проект %s): %s' % (
        project, ' | '.join(notes)))


def files_sha_fact(repo, tree=None):
    """Производные FILES.sha256 (F5/Б3): каждая строка — файл ЕСТЬ в коммите и
    sha256 blob из HEAD совпадает (оракул независим: git + hashlib, не
    tools/verify_handoff.py)."""
    tree = tree or Tree(repo)
    text = tree.get('FILES.sha256')
    if text is None:
        return (None, 'NEEDS_ENV: FILES.sha256 отсутствует — соответствие '
                      'производных коммиту НЕ проверено')
    if not (Path(repo) / '.git').exists():
        return (None, 'NEEDS_ENV: нет .git — соответствие FILES.sha256 коммиту '
                      'НЕ проверено')
    bad = []
    lines = [ln for ln in text.splitlines() if ln.strip()]
    for ln in lines:
        m = re.match(r'^([0-9a-f]{64})  (.+)$', ln)
        if not m:
            bad.append('формат строки: %s' % ln[:60])
            continue
        want, rel = m.groups()
        e = subprocess.run(['git', '-C', str(repo), 'cat-file', '-e',
                            'HEAD:%s' % rel], capture_output=True)
        if e.returncode != 0:
            bad.append('нет в коммите: %s' % rel)
            continue
        blob = subprocess.run(['git', '-C', str(repo), 'show', 'HEAD:%s' % rel],
                              capture_output=True)
        if hashlib.sha256(blob.stdout).hexdigest() != want:
            bad.append('sha256 расходится: %s' % rel)
    return (not bad, '%d строк; %s' % (len(lines), '; '.join(bad[:4])
            or 'все строки — файлы коммита, sha256 сходится'))

# ------------------------------------------------- факты круга 3 реализации
# (вердикты impl-круга 2: Б2′/F3' reviewer+adversary, F4', F2', A2/С3, С5, С7)

PG18_IMAGE = ('postgres:18@sha256:74935e72241653ca55e0414067e6d8763aceb'
              '8a810eb51b452253ec3dcfc4336')


def _walk_key(obj, key):
    """Все значения ключа key в вложенной структуре (ось — объявлена контрактом)."""
    out = []
    if isinstance(obj, dict):
        for k, v in obj.items():
            if k == key:
                out.append(v)
            out.extend(_walk_key(v, key))
    elif isinstance(obj, list):
        for x in obj:
            out.extend(_walk_key(x, key))
    return out


ASYNC_TUPLE_DRIVER = """
'use strict';
const fs = require('fs'), http = require('http'), path = require('path');
const { Client } = require('pg');
const harness = require(process.argv[2]);
const base = process.argv[3], obs = JSON.parse(fs.readFileSync(process.argv[4], 'utf8'));
const pgUrl = process.env.COMPLIOR_HARNESS_DATABASE_URL;
const arrivals = [];
const srv = http.createServer((req, res) => {
  arrivals.push({ t: new Date().toISOString(), url: req.url });
  if (req.url.indexOf('/ms') !== -1) { res.statusCode = 200; res.end('ms'); return; }
  const c = new Client({ connectionString: pgUrl });
  c.connect()
    .then(() => c.query('INSERT INTO stend109_markers VALUES ($1)', [process.env.STEND109_MARKER]))
    .then(() => c.end())
    .then(() => {
      if (req.url.indexOf('/parB') !== -1) {
        setTimeout(() => { res.statusCode = 200; res.end('PROBE-ASYNC-PAR-B'); }, 500);
        return;
      }
      res.statusCode = 200; res.end('PROBE-ASYNC-OK');
    })
    .catch(() => { res.statusCode = 500; res.end('marker insert failed'); });
});
const readDir = (d) => fs.readdirSync(d).sort()
  .map((n) => [n, fs.readFileSync(path.join(d, n), 'utf8')]);
srv.listen(0, '127.0.0.1', async () => {
  const port = srv.address().port;
  const d1 = path.join(base, 'one'), d2 = path.join(base, 'par'), d3 = path.join(base, 'ms');
  for (const d of [d1, d2, d3]) fs.mkdirSync(d, { recursive: true });
  const out = { arrivals, err: null };
  // фаза 1 (M1–M4): одиночная запись — реальный TCP между двумя снимками таблицы
  try {
    obs.http_request.url = 'http://127.0.0.1:' + port + '/marker';
    await harness.recordInteractionAsync(obs, d1);
  } catch (e) { out.err = String((e && e.message) || e); }
  out.files1 = readDir(d1);
  // фаза 2 (A-3, I-3): N=2 ПАРАЛЛЕЛЬНЫХ записи (Promise.all) с различимыми
  // текстами осей; /parB отвечает с задержкой — модульное состояние (8aca71a
  // snapshotContext) подменяет after-снимок быстрой записи чужим текстом
  const mkPar = (tag, url) => ({
    mode: 'RUNTIME',
    http_request: { method: 'GET', url },
    sql_before: "SELECT 'STEND109_PAR_" + tag + "1' AS tag",
    sql_after: "SELECT 'STEND109_PAR_" + tag + "2' AS tag",
    runtime_role: 'par-claimed-' + tag, provider_calls: 0, inputs: {}, secrets: [],
  });
  try {
    await Promise.all([
      harness.recordInteractionAsync(mkPar('A', 'http://127.0.0.1:' + port + '/parA'), d2),
      harness.recordInteractionAsync(mkPar('B', 'http://127.0.0.1:' + port + '/parB'), d2),
    ]);
  } catch (e) { out.err_par = String((e && e.message) || e); }
  out.files2 = readDir(d2);
  // фаза 3 (A-5, I-4): мультистейтмент — после хвостовых ';' остался ';';
  // smuggling-COMMIT делает INSERT персистентным на дереве без отказа
  try {
    await harness.recordInteractionAsync({
      mode: 'RUNTIME',
      http_request: { method: 'GET', url: 'http://127.0.0.1:' + port + '/ms' },
      sql_before: "SELECT 1; COMMIT; INSERT INTO stend109_markers VALUES ('STEND109_MS_SENTINEL')",
      sql_after: 'SELECT val FROM stend109_markers ORDER BY val',
      runtime_role: 'ms-claimed', provider_calls: 0, inputs: {}, secrets: [],
    }, d3);
  } catch (e) { out.err_ms = String((e && e.message) || e); }
  out.files3 = readDir(d3);
  console.log(JSON.stringify(out));
  srv.close();
});
"""


def await_disposable_pg18(cid, role, budget=60):
    """Детерминированная готовность disposable PG18. Флейк pg_isready (живой,
    круг r7): при первом старте postgres:18 поднимает ВРЕМЕННЫЙ
    инициализационный сервер (только unix-сокет) — pg_isready зелёен на нём,
    затем инициализация перезапускает сервер, и psql после «готовности»
    падает «the database system is shutting down». Честная готовность:
    строка «database system is ready to accept connections» в docker logs
    ДВАЖДЫ (инициализационный и финальный серверы) И, после второй строки,
    psql select 1 два раза подряд с паузой ≥1 с между успехами. Общий бюджет
    budget секунд. Возвращает (True, notes) либо (False, причину); тайм-аут
    НЕ краснит факт — вызывающий обязан вернуть NEEDS_ENV (честный NOT_RUN по
    грамматике пробы), не ложный красный/зелёный факт."""
    line = 'database system is ready to accept connections'
    deadline = time.monotonic() + budget
    notes = []
    seen = 0
    while time.monotonic() < deadline:
        try:
            lg = subprocess.run(['docker', 'logs', cid],
                                capture_output=True, text=True, timeout=15)
        except (OSError, subprocess.TimeoutExpired):
            lg = None
        seen = ((lg.stdout or '') + (lg.stderr or '')).count(line) if lg else 0
        if seen >= 2:
            break
        time.sleep(1)
    if seen < 2:
        return (False, 'ready-строк в logs %d (нужно 2: инициализационный '
                       'и финальный серверы) за %d с' % (seen, budget))
    streak = 0
    while time.monotonic() < deadline:
        try:
            q = subprocess.run(['docker', 'exec', cid, 'psql', '-U', role,
                                '-d', 'probe', '-tAc', 'select 1'],
                               capture_output=True, text=True, timeout=15)
        except (OSError, subprocess.TimeoutExpired):
            q = None
        if q is not None and q.returncode == 0 \
                and (q.stdout or '').strip() == '1':
            streak += 1
            if streak >= 2:
                return (True, ['ready-строк в logs: %d' % seen,
                               'psql select 1: 2 успеха подряд, пауза 1 с'])
        else:
            streak = 0
            notes.append('psql rc=%s %s' % (
                q.returncode if q is not None else 'timeout',
                (q.stderr or '').strip()[:60] if q is not None else ''))
        time.sleep(1)
    return (False, 'psql select 1 не подтвердил двумя успехами подряд после '
                   'второй ready-строки: ' + '; '.join(notes[-3:] or ['-']))


def async_tuple_fact(repo, tree=None):
    """Живая связка «реальный TCP HTTP между SQL-снимками строк таблицы» с
    runtime_role из БД-сессии (Б2′/F3', M1–M4 и мутант «константы»): оракул —
    журнал прибытий сервера, строки таблицы и ось runtime_role из sink-файла."""
    tree = tree or Tree(repo)
    body = tree.get(tree.p('harness'))
    if body is None:
        return (None, 'NEEDS_ENV: harness.js отсутствует (контроль судит HARNESS_MISSING)')
    node = shutil.which('node')
    if node is None:
        return (None, 'NEEDS_ENV: node отсутствует — живой путь recordInteractionAsync НЕ проверен')
    nm = Path(repo) / tree.p('node_modules')
    if not (nm / 'pg').is_dir():
        return (None, 'NEEDS_ENV: node_modules/pg отсутствует — SQL-путь harness НЕ проверен')
    try:
        v = subprocess.run(['docker', 'version', '--format', '{{.Server.Version}}'],
                           capture_output=True, text=True, timeout=30)
        docker_ok = v.returncode == 0
    except (OSError, subprocess.TimeoutExpired):
        docker_ok = False
    if not docker_ok:
        return (None, 'NEEDS_ENV: docker недоступен — живая связка HTTP↔SQL↔роль '
                      '(disposable PG18) НЕ проверена')
    preset = 'STEND109_PRESET_' + uuid.uuid4().hex[:12]
    marker = 'STEND109_MARKER_' + uuid.uuid4().hex[:12]
    role = 'stend109_hc'
    cid = 'stend109async' + uuid.uuid4().hex[:8]
    notes, oks = [], []
    with tempfile.TemporaryDirectory(prefix='stend109-asynct-') as tmp:
        try:
            r = subprocess.run(['docker', 'run', '-d', '--name', cid,
                                '-e', 'POSTGRES_USER=%s' % role,
                                '-e', 'POSTGRES_PASSWORD=probe',
                                '-e', 'POSTGRES_DB=probe',
                                '-p', '127.0.0.1::5432', PG18_IMAGE],
                               capture_output=True, text=True, timeout=180)
            if r.returncode != 0:
                return (False, 'docker run PG18: rc=%d %s' % (
                    r.returncode, (r.stderr or '').strip()[:120]))
            port = None
            for _ in range(30):
                q = subprocess.run(['docker', 'port', cid, '5432/tcp'],
                                   capture_output=True, text=True)
                m = re.search(r'127\.0\.0\.1:(\d+)', q.stdout or '')
                if m:
                    port = m.group(1)
                    break
                time.sleep(1)
            if port is None:
                return (False, 'порт disposable PG18 не получен')
            ready, why = await_disposable_pg18(cid, role)
            if not ready:
                return (None, 'NEEDS_ENV: disposable PG18 не готов за 60 с — '
                              'живая связка HTTP↔SQL↔роль НЕ проверена (%s)' % why)
            setup = subprocess.run(
                ['docker', 'exec', cid, 'psql', '-U', role, '-d', 'probe',
                 '-c', 'CREATE TABLE stend109_markers (val text)',
                 '-c', "INSERT INTO stend109_markers VALUES ('%s')" % preset],
                capture_output=True, text=True, timeout=60)
            if setup.returncode != 0:
                return (False, 'таблица стенда: rc=%d %s' % (
                    setup.returncode, (setup.stderr or '').strip()[:120]))

            def psql_rows():
                q = subprocess.run(
                    ['docker', 'exec', cid, 'psql', '-U', role, '-d', 'probe',
                     '-tAc', 'SELECT val FROM stend109_markers ORDER BY val'],
                    capture_output=True, text=True, timeout=30)
                if q.returncode != 0:
                    return None
                return [ln for ln in (q.stdout or '').splitlines() if ln]

            rows_before = psql_rows()
            h = Path(tmp) / 'harness.js'
            h.write_text(body, encoding='utf-8')
            d = Path(tmp) / 'driver.js'
            d.write_text(ASYNC_TUPLE_DRIVER, encoding='utf-8')
            obs = {'mode': 'RUNTIME',
                   'http_request': {'method': 'GET', 'url': 'http://127.0.0.1:1/marker'},
                   'sql_before': 'SELECT val FROM stend109_markers ORDER BY val',
                   'sql_after': 'SELECT val FROM stend109_markers ORDER BY val',
                   'runtime_role': 'claimed-role-' + uuid.uuid4().hex[:8],
                   'provider_calls': 3, 'inputs': {}, 'secrets': []}
            o = Path(tmp) / 'obs.json'
            o.write_text(json.dumps(obs), encoding='utf-8')
            env = dict(os.environ,
                       NODE_PATH=str(nm),
                       COMPLIOR_HARNESS_DATABASE_URL='postgres://%s:probe@127.0.0.1:%s/probe' % (role, port),
                       STEND109_MARKER=marker)
            try:
                rr = subprocess.run([node, str(d), str(h), str(Path(tmp) / 'ev'), str(o)],
                                    capture_output=True, text=True, timeout=90, cwd=tmp, env=env)
            except subprocess.TimeoutExpired:
                return (False, 'драйвер async-связки: таймаут')
            try:
                out = json.loads(rr.stdout)
            except ValueError:
                return (False, 'драйвер async-связки rc=%d: stdout=%r stderr=%r' % (
                    rr.returncode, rr.stdout[:120], rr.stderr[:200]))
            rows_after = psql_rows()
        finally:
            subprocess.run(['docker', 'rm', '-f', cid],
                           capture_output=True, text=True, timeout=60)
    # фаза 2 (A-3, I-3): ПАРАЛЛЕЛЬНОСТЬ — N=2 recordInteractionAsync (Promise.all)
    # с различимыми текстами; ожидание ИЗ ФАЙЛОВ, запись сопоставлена наблюдению
    # по http_request.url: каждая ось — тексты СВОЕГО наблюдения (модульного
    # состояния между вызовами нет; 8aca71a snapshotContext смешивает — З-2)
    files2 = out.get('files2') or []
    oks.append(len(files2) == 2)
    notes.append('параллельных записей: файлов %d (ожидалось 2)' % len(files2))
    for fname2, ftext2 in files2:
        try:
            frec2 = json.loads(ftext2)
        except ValueError:
            oks.append(False)
            notes.append('параллельная запись %s не JSON' % fname2)
            continue
        url2 = ((frec2.get('http_request') or {}).get('url') or '')
        tag2 = 'A' if url2.endswith('/parA') else ('B' if url2.endswith('/parB') else None)
        if tag2 is None:
            oks.append(False)
            notes.append('параллельная запись: неизвестный url %r' % url2[-24:])
            continue
        for axis2, suf2 in (('sql_before', '1'), ('sql_after', '2')):
            snap2 = frec2.get(axis2) or {}
            want2 = 'STEND109_PAR_%s%s' % (tag2, suf2)
            rows2 = snap2.get('rows')
            good2 = (snap2.get('status') == 'MEASURED' and isinstance(rows2, list)
                     and len(rows2) == 1 and rows2[0] == {'tag': want2})
            oks.append(good2)
            if not good2:
                notes.append('параллельная %s: ось %s из файла %r ≠ %r (снимки смешаны)' % (
                    tag2, axis2, ((rows2 or [])[:1] or [snap2.get('status')]),
                    {'tag': want2}))
    # фаза 3 (A-5, I-4): МУЛЬТИСТЕЙТМЕНТ — отказ ДО подключения с правдивой
    # причиной; smuggling-COMMIT на дереве без отказа делает INSERT персистентным
    files3 = out.get('files3') or []
    oks.append(len(files3) == 1)
    if len(files3) == 1:
        _, mtext = files3[0]
        try:
            mrec = json.loads(mtext)
        except ValueError:
            oks.append(False)
            notes.append('мультистейтмент: файл не JSON')
            mrec = {}
        sb3 = mrec.get('sql_before') or {}
        reason3 = str(sb3.get('reason') or '').lower()
        oks.append(sb3.get('status') == 'NOT_RUN'
                   and ('read-only' in reason3 or 'мультистейтмент' in reason3))
        notes.append('мультистейтмент: status=%r reason=%r' % (
            sb3.get('status'), str(sb3.get('reason') or '')[:70]))
        # сентинел в ПОЛЕ sql (текст запроса) законен; незаконна — строка
        # ДАННЫХ таблицы в измеренных строках после-снимка (файловый уровень;
        # серверский оракул — psql ниже)
        rows3 = (mrec.get('sql_after') or {}).get('rows')
        ok_rows3 = (isinstance(rows3, list)
                    and all(not (isinstance(r, dict)
                                 and r.get('val') == 'STEND109_MS_SENTINEL') for r in rows3))
        oks.append(ok_rows3)
        if not ok_rows3:
            notes.append('sql_after: сентинел-строка в измеренных строках таблицы')
    else:
        notes.append('мультистейтмент: файлов %d (ожидался 1)' % len(files3))
    # оракул таблицы — psql ДО/ПОСЛЕ драйвера (сторона сервера, не файл):
    # новые строки — ТОЛЬКО MARKER прибытий сервера, прежние не тронуты
    if rows_before is None or rows_after is None:
        oks.append(False)
        notes.append('psql-оракул таблицы недоступен (до=%s после=%s)' % (
            rows_before is not None, rows_after is not None))
    else:
        cnt = {}
        for v_ in rows_before:
            cnt[v_] = cnt.get(v_, 0) + 1
        for v_ in rows_after:
            cnt[v_] = cnt.get(v_, 0) - 1
        gone = sorted(k for k, n in cnt.items() if n > 0)
        added = [k for k, n in cnt.items() if n < 0 for _ in range(-n)]
        oks.append(not gone and all(v_ == marker for v_ in added))
        notes.append('таблица: исчезло %r, добавилось %r' % (
            gone[:3], sorted(set(added))[:3]))
    if out.get('err'):
        return (False, 'recordInteractionAsync: %s' % str(out['err'])[:200])
    arrivals = out.get('arrivals') or []
    oks.append(len(arrivals) >= 1)
    notes.append('прибытий на сервер: %d' % len(arrivals))
    files = out.get('files1') or []
    oks.append(len(files) == 1)
    if len(files) != 1:
        return (False, 'async-связка: файлов evidence %d (ожидался 1); %s' % (
            len(files), '; '.join(notes)))
    name, text = files[0]
    try:
        rec = json.loads(text)
    except ValueError:
        return (False, 'async-связка: %s не JSON; %s' % (name, '; '.join(notes)))
    cpreset, cmarker = text.count(preset), text.count(marker)
    oks.append(cpreset == 2)
    notes.append('PRESET в файле %d (ожидалось 2: снимки ДО и ПОСЛЕ)' % cpreset)
    oks.append(cmarker == 1)
    notes.append('MARKER в файле %d (ожидался 1: только после-снимок)' % cmarker)
    oks.append('MEASURED' in text)
    roles = [r for r in _walk_key(rec, 'runtime_role') if isinstance(r, str)]
    ok_role = role in roles and all(r != obs['runtime_role'] for r in roles) and len(roles) >= 1
    oks.append(ok_role)
    notes.append('runtime_role из файла %r (ожидался current_user %r)' % (
        roles[:2], role))
    return (all(oks), 'живая связка async (правило Ц): %s' % (
        '; '.join(notes) or 'HTTP пришёл, снимки вокруг запроса, роль из БД'))


ASYNC_PII_SECRETS = ['SETCOOKIESECRET123', 'SETCOOKIE2SECRET456', 'MULTICOOKIESECRET',
                     'ESCCOOKIESECRET', 'BODYLITERALSECRET', 'NOEQSETCOOKIEASYNC45',
                     'RAWCOOKIEASYNCNOEQ44', 'ASYNCAUTHBASIC41', 'ASYNCPROXYBASIC42',
                     'ASYNCXKEY43', 'ASYNCBODYCOOKIE9', 'ASYNCBODYAUTH9',
                     'ASYNCJSONCK11', 'ASYNCJSONAUTH12', '89160000000',
                     '8 916 000 00 00']

ASYNC_PII_DRIVER = """
'use strict';
const fs = require('fs'), http = require('http'), path = require('path');
const harness = require(process.argv[2]);
const dir = process.argv[3];
const body = '{\\"cookie\\":\\"ESCCOOKIESECRET\\"} tail\\n'
  + 'Set-Cookie: session value BODYLITERALSECRET\\n'
  + 'Cookie: sid=ASYNCBODYCOOKIE9\\n'
  + 'Authorization: Basic ASYNCBODYAUTH9\\n'
  + '{"cookie":["ASYNCJSONCK11"]}\\n'
  + '{"authorization":"ASYNCJSONAUTH12"}\\n'
  + 'phone 89160000000 и 8 916 000 00 00\\nPROBE-ASYNC-PII';
const srv = http.createServer((req, res) => {
  res.setHeader('Content-Type', 'text/plain');
  res.setHeader('Set-Cookie', ['sid=SETCOOKIESECRET123; Path=/; HttpOnly',
                               'sid2=SETCOOKIE2SECRET456; Path=/',
                               'NOEQSETCOOKIEASYNC45']);
  res.end(body);
});
srv.listen(0, '127.0.0.1', async () => {
  delete process.env.COMPLIOR_HARNESS_DATABASE_URL;
  delete process.env.DATABASE_URL;
  let err = null;
  try {
    await harness.recordInteractionAsync({
      mode: 'RUNTIME',
      http_request: { method: 'GET',
                      url: 'http://127.0.0.1:' + srv.address().port + '/pii',
                      headers: { cookie: 'a=1; session=MULTICOOKIESECRET; RAWCOOKIEASYNCNOEQ44',
                                 authorization: 'Basic ASYNCAUTHBASIC41',
                                 'proxy-authorization': 'Basic ASYNCPROXYBASIC42',
                                 'x-api-key': 'ASYNCXKEY43' } },
      sql_before: 'S1', sql_after: 'S2', runtime_role: 'claimed',
      provider_calls: 0,
      inputs: { o1: { a: { x: 1 } }, o2: { a: { y: 2 } } },
    }, dir);
  } catch (e) { err = String((e && e.message) || e); }
  const files = fs.readdirSync(dir).sort()
    .map((n) => [n, fs.readFileSync(path.join(dir, n), 'utf8')]);
  console.log(JSON.stringify({ files, err }));
  srv.close();
});
"""


def async_pii_fact(repo, tree=None):
    """Живой scrubber + честность на async-пути (F4'/M5/M6; круг 4 — A-6/A-7):
    Set-Cookie-массив (в т.ч. элемент без '='), multicookie, cookie-пару без
    '=', Authorization/proxy-authorization/x-api-key, тела «Cookie:»/
    «Authorization:»/JSON-формы, телефоны РФ — секретов в sink нет, поля
    непусты (К4), JSON цел; DB-less: runtime_role из файла == 'NOT_RUN',
    input_hashes двух объектных входов различны."""
    tree = tree or Tree(repo)
    body = tree.get(tree.p('harness'))
    if body is None:
        return (None, 'NEEDS_ENV: harness.js отсутствует (контроль судит HARNESS_MISSING)')
    node = shutil.which('node')
    if node is None:
        return (None, 'NEEDS_ENV: node отсутствует — живой async-scrubber НЕ проверен')
    with tempfile.TemporaryDirectory(prefix='stend109-apii-') as tmp:
        h = Path(tmp) / 'harness.js'
        h.write_text(body, encoding='utf-8')
        d = Path(tmp) / 'driver.js'
        d.write_text(ASYNC_PII_DRIVER, encoding='utf-8')
        try:
            r = subprocess.run([node, str(d), str(h), str(Path(tmp) / 'ev')],
                               capture_output=True, text=True, timeout=60, cwd=tmp)
        except subprocess.TimeoutExpired:
            return (False, 'драйвер async-PII: таймаут')
        try:
            out = json.loads(r.stdout)
        except ValueError:
            return (False, 'драйвер async-PII rc=%d: stdout=%r stderr=%r' % (
                r.returncode, r.stdout[:120], r.stderr[:200]))
    if out.get('err'):
        return (False, 'recordInteractionAsync: %s' % str(out['err'])[:200])
    files = out.get('files') or []
    if len(files) != 1:
        return (False, 'async-PII: файлов evidence %d (ожидался 1)' % len(files))
    name, text = files[0]
    try:
        rec = json.loads(text)
    except ValueError:
        return (False, 'async-PII: файл evidence %s не JSON (scrubber разрушил '
                       'структуру сериализованного текста)' % name)
    forbidden = []
    for v in ASYNC_PII_SECRETS:
        forbidden.append(v)
        esc = json.dumps(v)[1:-1]
        if esc != v:
            forbidden.append(esc)
    notes, ok = [], True
    for v in forbidden:
        if v in text:
            ok = False
            notes.append('утечка %r' % v[:26])
    resp = rec.get('http_response') or {}
    if resp.get('status') != 200:
        ok = False
        notes.append('ответ не измерен (status=%r)' % resp.get('status'))
    rbody = resp.get('body')
    if not isinstance(rbody, str) or 'PROBE-ASYNC-PII' not in rbody:
        ok = False
        notes.append('тело ответа потеряно (вакуумная вырезка)')
    hdrs = resp.get('headers') or {}
    sc = hdrs.get('set-cookie') or hdrs.get('Set-Cookie')
    if not (isinstance(sc, list) and len(sc) >= 2 and all(isinstance(x, str) and x for x in sc)):
        ok = False
        notes.append('Set-Cookie-массив не сохранён (%r)' % (sc,))
    if rec.get('mode') != 'RUNTIME':
        ok = False
        notes.append('mode из файла %r' % rec.get('mode'))
    # круг 4 (A-7, I-7): DB-less async — ось runtime_role ИЗ ФАЙЛА равна
    # литералу 'NOT_RUN' (не заявление вызывающего 'claimed')
    if rec.get('runtime_role') != 'NOT_RUN':
        ok = False
        notes.append('runtime_role из файла %r ≠ NOT_RUN (заявление вместо '
                     'измерения при не измеренной БД)' % rec.get('runtime_role'))
    # круг 4 (A-7, I-8): два РАЗНЫХ объектных входа — input_hashes ИЗ ФАЙЛА
    # различаются (каноническая форма не навязывается; схлопывание хэшей
    # {a:{x:1}}/{a:{y:2}} — дефект M15/А1 круга 3)
    ih = rec.get('input_hashes') or {}
    h1, h2 = ih.get('o1'), ih.get('o2')
    hexok = all(isinstance(x, str) and len(x) == 64 and re.fullmatch(r'[0-9a-f]{64}', x)
                for x in (h1, h2))
    if not (hexok and h1 != h2):
        ok = False
        notes.append('input_hashes объектных входов не различаются '
                     '(o1=%r… o2=%r…)' % (str(h1)[:12], str(h2)[:12]))
    # круг 4 (A-6, форма К4): замкнутые поля присутствуют и непусты
    qhdr = (rec.get('http_request') or {}).get('headers') or {}
    for qk in ('authorization', 'proxy-authorization', 'x-api-key'):
        if not isinstance(qhdr.get(qk), str) or not qhdr.get(qk):
            ok = False
            notes.append('request %s выпаден (вакуумная вырезка)' % qk)
    return (ok, 'async scrubber: %s' % ('; '.join(notes[:5]) or
            'Set-Cookie-массив/multicookie/экранированная форма/литерал чисты, JSON цел'))


LANE_FROZEN_TAG = 'frozen/contracts/109/3'
# v2 (форк n109-lane-v2, рекомендация А): тег 109/2 указывает на батарею v2;
# корень lane-прогона — дерево ПОД испытанием (HEAD продукта: батарея v2
# зелёна на нём). Отдельный зелёный корень v1 (8aca71a) — наследие v1, где
# замороженная 109/1 была зелёна только на старом дереве (С11 закрыт
# перезаморозкой 109/2).
#
# Рекурсия lane → батарея v2 → lane-факт → lane … (в v1 вложенная батарея не
# содержала lane-факта) разорвана МАРКЕРОМ ГЛУБИНЫ: внешний факт выставляет
# '1' в окружении вложенного lane-запуска; вложенный lane-факт при маркере —
# зелёный по построению (гигиену судит внешний факт), при глубине ≥2 —
# громкий красный 'рекурсия lane-факта' сразу; прогон без маркера, не
# завершающийся за бюджет run_lane, красен таймаутом за конечное время.
# Остаточный риск (cognitive-only): подмена env-маркера в CI извне.
LANE_DEPTH_MARKER = 'STEND109_LANE_DEPTH'


def lane_depth_env():
    """Числовая глубина LANE_DEPTH_MARKER для диспетчера клеток; мусорный
    маркер трактуется как вложенный прогон (клетка lane-гигиены не судится —
    её судит внешний факт; сама факт-ветка проверки при мусорном маркере
    краснеет именованной причиной)."""
    try:
        return int(os.environ.get(LANE_DEPTH_MARKER, '0') or '0')
    except ValueError:
        return 1


def lane_hygiene_fact(repo, tree=None):
    """Гигиена H-checkout lane stend109 (A2/С3; круг 4 — A-8, I-5; v2 — форк
    n109-lane-v2): lane судится на ЖИВОМ пин-чекауте (локальный clone тега
    frozen/contracts/109/2 из репозитория батареи: HEAD == STEND109_PIN,
    hash-object probe.py == блоб пина) на дереве ПОД испытанием (HEAD
    продукта). Чистый checkout — lane rc 0; три обхода — незакоммиченная
    подмена probe.py (sys.exit(0)), подмена под update-index
    --assume-unchanged (прячется от status --porcelain, но не от
    hash-object), коммит подмены + git tag -f (дерево чисто, тег переведён)
    — каждый обязан давать lane rc ≠ 0. Рекурсия (lane на H = батарея v2
    запускает ту же пробу с lane-фактом) разорвана маркером глубины
    LANE_DEPTH_MARKER (Н-39, привязка стаб↔ветвь в коде): внешний факт
    выставляет '1' в окружении вложенного lane-запуска — вложенный факт
    возвращает зелёный пропуск (гигиену судит внешний); прямой вызов
    frozen-пробы с маркером '2' — громкий красный 'рекурсия lane-факта'
    сразу; прогон без маркера, не завершающийся за бюджет run_lane, красен
    таймаутом (rc 124) за конечное время. Остаточный риск (cognitive-only):
    подмена env-маркера в CI — контролирующий окружение способен снять
    защиту; отдельного ловца нет, среда CI считается доверенной."""
    # v2: маркер глубины проверяется ПЕРВОЙ ветвью — до docker/тега/clone:
    # вложенный прогон не должен порождать новые lane-запуски ни при каком
    # NEEDS/ошибочном окружении
    raw_depth = os.environ.get(LANE_DEPTH_MARKER, '').strip()
    if raw_depth:
        try:
            depth = int(raw_depth)
        except ValueError:
            return (False, '%s=%r не целое — маркер глубины испорчен '
                           '(остаточный риск cognitive-only: подмена '
                           'окружения)' % (LANE_DEPTH_MARKER, raw_depth))
        if depth >= 2:
            return (False, 'рекурсия lane-факта: %s=%d — внешний lane-факт '
                           'не выставил/продублировал маркер глубины'
                    % (LANE_DEPTH_MARKER, depth))
        if depth == 1:
            return (True, 'вложенный прогон: lane-факт пропущен внешним '
                          'фактом (%s=1)' % LANE_DEPTH_MARKER)
        # '0' и отрицательные — полный прогон (маркер «вне глубины»)
    tree = tree or Tree(repo)
    lane = tree.get(tree.p('lane'))
    if lane is None or 'stend109' not in lane:
        return (None, 'NEEDS_ENV: lane stend109 в %s отсутствует '
                      '— гигиена H-checkout НЕ проверена' % tree.p('lane'))
    if shutil.which('git') is None:
        return (None, 'NEEDS_ENV: git отсутствует — гигиена H-checkout НЕ проверена')
    try:
        v = subprocess.run(['docker', 'version', '--format', '{{.Server.Version}}'],
                           capture_output=True, text=True, timeout=30)
        docker_ok = v.returncode == 0
    except (OSError, subprocess.TimeoutExpired):
        docker_ok = False
    if not docker_ok:
        return (None, 'NEEDS_ENV: docker недоступен — замороженная батарея на чистом '
                      'H требует EGRESS_GUARD, lane гигиена НЕ проверена')
    devharness = Path(__file__).resolve().parents[3]
    have_tag = subprocess.run(
        ['git', '-C', str(devharness), 'rev-parse', LANE_FROZEN_TAG + '^{commit}'],
        capture_output=True, text=True)
    if have_tag.returncode != 0:
        return (None, 'NEEDS_ENV: тег %s отсутствует в %s — пин-чекаут H '
                      'не собирается' % (LANE_FROZEN_TAG, devharness))
    pin_sha = (have_tag.stdout or '').strip()
    # v2 (форк n109-lane-v2): корень lane-прогона — дерево ПОД испытанием
    # (HEAD): батарея v2 зелёна на нём; зелёный корень v1 (8aca71a) был
    # нужен только замороженной 109/1 (С11 закрыт перезаморозкой 109/2)
    root_commit = 'HEAD'
    lay = detect_layout(repo) or LAYOUT_OLD
    nm_src = Path(repo) / PATHS[lay]['node_modules']
    if not (nm_src / 'pg').is_dir():
        return (None, 'NEEDS_ENV: %s/pg в %s отсутствует — '
                      'RUNNER_DAMAGE_GUARD замороженной батареи не измерим, lane '
                      'гигиена НЕ проверена' % (PATHS[lay]['node_modules'], repo))
    notes, oks = [], []
    with tempfile.TemporaryDirectory(prefix='stend109-lane-') as tmp:
        # ROOT: зелёное для замороженной батареи дерево + lane-скрипт
        # (возможно, мутированный оверлеем) из дерева ПОД испытанием (Н-364)
        lane_repo = Path(tmp) / 'r'
        lane_repo.mkdir()
        arc = subprocess.run(
            ['/bin/sh', '-c',
             'git -C %s archive %s | tar -x -C %s' % (repo, root_commit, lane_repo)],
            capture_output=True, text=True, timeout=120)
        if arc.returncode != 0:
            return (False, 'ROOT-извлечение %s: rc=%d %s' % (
                root_commit, arc.returncode, (arc.stderr or '')[:120]))
        lane_rel = tree.p('lane')
        (lane_repo / lane_rel).parent.mkdir(parents=True, exist_ok=True)
        (lane_repo / lane_rel).write_text(lane, encoding='utf-8')

        # v2: вложенной батарее нужен git-оракул — FILES_SHA256_GUARD читает
        # 'HEAD:<rel>' блобы, _head_worktree делает git archive HEAD, а
        # git archive не несёт .git. Материализуем извлечённое дерево ЕДИНЫМ
        # коммитом (изоляция: lane_repo в tmpdir, репо продукта не мутируется;
        # коммит содержит оверлей lane-скрипта — мутант честно красит FILES_SHA)
        for a_ in (['init', '-q'], ['add', '-A'],
                   ['-c', 'user.name=stend109-lane',
                    '-c', 'user.email=stend109-lane@dev-harness.local',
                    'commit', '-q', '-m', 'stend109: lane tree under test']):
            g_ = subprocess.run(['git', '-C', str(lane_repo)] + a_,
                                capture_output=True, text=True, timeout=180)
            if g_.returncode != 0:
                return (False, 'lane_repo git %s: rc=%d %s' % (
                    a_[0], g_.returncode, (g_.stderr or '')[:120]))
        # node_modules-симлинк — ПОСЛЕ коммита (в реальном репо untracked):
        # archive HEAD с симлинком в дереве ломает вложенную _head_worktree
        # (повторный os.symlink → FileExistsError, измерено на repro)
        os.symlink(str(nm_src), str(lane_repo / PATHS[lay]['node_modules']))
        # H: пин-чекаут замороженного тега (HEAD == пину по построению клона)
        h = Path(tmp) / 'h'
        clone = subprocess.run(
            ['git', 'clone', '-q', '--no-hardlinks', '--depth', '1',
             '--branch', LANE_FROZEN_TAG, str(devharness), str(h)],
            capture_output=True, text=True, timeout=120)
        if clone.returncode != 0:
            return (False, 'clone пин-тега %s: rc=%d %s' % (
                LANE_FROZEN_TAG, clone.returncode, (clone.stderr or '')[:120]))
        probe_rel = 'fixtures/workshop_project/stend_109/probe.py'
        probe = h / 'fixtures' / 'workshop_project' / 'stend_109' / 'probe.py'
        # v2: маркер глубины '1' — вложенный lane-запуск гасит рекурсию:
        # батарея из H видит маркер и пропускает свой lane-факт (зелёный
        # по построению), гигиену судит ЭТОТ внешний факт
        env = dict(os.environ, COMPLIOR_STEND109_H_CHECKOUT=str(h),
                   **{LANE_DEPTH_MARKER: '1'})

        def git_h(*a):
            return subprocess.run(['git', '-C', str(h)] + list(a),
                                  capture_output=True, text=True, timeout=60)

        def run_lane(tag_):
            # v2: рекурсия lane→батарея→lane-факт→lane разорвана маркером
            # LANE_DEPTH_MARKER='1' (см. env). Если frozen-батарея маркер НЕ
            # выставляет (дефект), вложенный прогон не завершается —
            # таймаут даёт красный ЗА КОНЕЧНОЕ ВРЕМЯ (rc 124, как у
            # coreutils timeout), а не падение пробы исключением
            argv_ = [sys.executable, str(lane_repo / lane_rel),
                     '--lane', 'stend109', '--out', str(Path(tmp) / ('laneout-' + tag_))]
            try:
                return subprocess.run(argv_, capture_output=True, text=True,
                                       timeout=900, env=env, cwd=str(lane_repo))
            except subprocess.TimeoutExpired:
                return subprocess.CompletedProcess(
                    argv_, 124, '',
                    'таймаут 900 c: вложенный lane не завершается '
                    '(рекурсия lane-факта — маркер глубины не выставлен?)')

        clean = run_lane('clean')
        oks.append(clean.returncode == 0)
        notes.append('чистый пин-чекаут: lane rc=%d %s' % (
            clean.returncode, (clean.stderr or '').strip()[:80]))
        # v2, красное предъявление маркера глубины (Н-39, привязка к ветвям
        # проверки): прямой вызов frozen-пробы из h — (1) маркер '1' обязан
        # давать зелёный-пропуск вложенного прогона, (2) маркер '2' — ГРОМКИЙ
        # красный 'рекурсия lane-факта' СРАЗУ (конечное время). Если frozen-
        # батарея маркер не понимает, вызов уходит в полную гигиену и убивается
        # таймаутом контроля — контроль красный (пропуск не сработал)
        drv = ('import sys; sys.path.insert(0, sys.argv[1]); import probe; '
               'v, n = probe.lane_hygiene_fact(sys.argv[2]); '
               'print(v); print(n); sys.exit(0 if v is True else 1)')
        for mk_, rc_, tok_ in (('1', 0, 'вложенный прогон'),
                               ('2', 1, 'рекурсия lane-факта')):
            c_, ok_, head_ = None, False, 'таймаут 60 c'
            try:
                c_ = subprocess.run(
                    [sys.executable, '-c', drv, str(probe.parent), str(h)],
                    capture_output=True, text=True, timeout=60,
                    env=dict(os.environ, **{LANE_DEPTH_MARKER: mk_}))
                head_ = (c_.stdout or '').split('\n')[0].strip()
                ok_ = c_.returncode == rc_ and tok_ in (c_.stdout or '')
            except subprocess.TimeoutExpired:
                pass
            oks.append(ok_)
            notes.append('маркер %s=%s: rc=%s %s' % (
                LANE_DEPTH_MARKER, mk_,
                c_.returncode if c_ is not None else 'timeout', head_[:60]))
        sub = 'import sys; sys.exit(0)\n'
        # обход 1 (A2 круга 2): незакоммиченная подмена probe.py
        probe.write_text(sub, encoding='utf-8')
        dirty = run_lane('dirty')
        oks.append(dirty.returncode != 0)
        notes.append('грязный (подмена не закоммичена): rc=%d' % dirty.returncode)
        git_h('checkout', '--', probe_rel)
        # обход 2 (A-8/I-5): подмена под assume-unchanged — status чист,
        # hash-object НЕ сходится с блобом пина
        git_h('update-index', '--assume-unchanged', probe_rel)
        probe.write_text(sub, encoding='utf-8')
        assumed = run_lane('assume')
        oks.append(assumed.returncode != 0)
        notes.append('assume-unchanged (status чист, хэш чужой): rc=%d' % assumed.returncode)
        git_h('update-index', '--no-assume-unchanged', probe_rel)
        git_h('checkout', '--', probe_rel)
        # обход 3 (A-8/I-5): коммит подмены + git tag -f — дерево чисто,
        # HEAD больше не пин
        probe.write_text(sub, encoding='utf-8')
        git_h('add', '-A')
        git_h('-c', 'user.name=architect', '-c', 'user.email=architect@dev-harness.local',
              'commit', '-q', '-m', 'retag probe')
        git_h('tag', '-f', LANE_FROZEN_TAG)
        retag = run_lane('retag')
        oks.append(retag.returncode != 0)
        notes.append('коммит подмены + tag -f: rc=%d' % retag.returncode)
        git_h('reset', '-q', '--hard', pin_sha)
        git_h('tag', '-f', LANE_FROZEN_TAG, pin_sha)
    return (all(oks), 'lane stend109 гигиена H-checkout (пин %s): %s' % (
        pin_sha[:12], ' | '.join(notes)))

def _head_worktree(repo, tree, dest):
    """Материализация HEAD-дерева репо в dest (git archive) с наложением
    оверлея батареи (байты мутанта) и симлинком node_modules пакета.
    Возвращает (True, '') либо (False, причину)."""
    arc = subprocess.run(
        ['/bin/sh', '-c',
         'git -C %s archive HEAD | tar -x -C %s' % (repo, dest)],
        capture_output=True, text=True, timeout=120)
    if arc.returncode != 0:
        return (False, 'HEAD-извлечение: rc=%d %s' % (
            arc.returncode, (arc.stderr or '').strip()[:120]))
    pkg_rel = tree.p('pkg_root')
    for rel, data in (tree.overlay or {}).items():
        if pkg_rel and rel != pkg_rel and not rel.startswith(pkg_rel + '/'):
            continue
        p = dest / rel
        if data is None:
            if p.exists():
                p.unlink()
            continue
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(data, encoding='utf-8')
    nm = Path(repo) / tree.p('node_modules')
    if (nm / 'pg').is_dir():
        os.symlink(str(nm), str(dest / tree.p('node_modules')))
    return (True, '')


def backend_lint_fact(repo, tree=None):
    """I-1 (круг 4, adversary mut-i1): required-lane барьер lint —
    «npm run -s lint» в корне пакета — rc 0 на HEAD-дереве (арбитраж I-1:
    «rc 0 на HEAD»). Живой прогон в disposable-копии (git archive HEAD +
    оверлей мутанта + симлинк node_modules): eslint . И prettier --check.
    Мутант backend_lint_unused_const (РОВНО один неиспользуемый const в
    harness.js) обязан давать rc != 0."""
    tree = tree or Tree(repo)
    npm = shutil.which('npm')
    if npm is None:
        return (None, 'NEEDS_ENV: npm отсутствует — backend lint НЕ проверен (I-1)')
    nm = Path(repo) / tree.p('node_modules')
    if not ((nm / '.bin' / 'eslint').exists() and (nm / '.bin' / 'prettier').exists()):
        return (None, 'NEEDS_ENV: node_modules без eslint/prettier — '
                      'lint НЕ проверен (I-1)')
    with tempfile.TemporaryDirectory(prefix='stend109-lint-') as tmp:
        dest = Path(tmp) / 'r'
        dest.mkdir()
        ok, why = _head_worktree(repo, tree, dest)
        if not ok:
            return (False, why)
        try:
            pkg_rel = tree.p('pkg_root')
            r = subprocess.run([npm, 'run', '-s', 'lint'],
                               cwd=str(dest / pkg_rel) if pkg_rel else str(dest),
                               capture_output=True, text=True, timeout=300)
        except subprocess.TimeoutExpired:
            return (False, 'npm run -s lint: таймаут 300 с')
    if r.returncode == 0:
        return (True, 'npm run -s lint (HEAD+оверлей): rc 0')
    tail = ((r.stdout or '') + (r.stderr or '')).strip()
    errs = [ln.strip() for ln in tail.splitlines()
            if ' error ' in ln or ln.startswith('error')][:3]
    return (False, 'lint rc=%d: %s' % (r.returncode, '; '.join(errs)[:200] or tail[:200]))


def delivery_rel(t):
    return t.p('integ_dir') + '/harness-live.test.js'
DELIVERY_TEST_TITLE = 'живое наблюдение: server+PG18'
def delivery_noop_body(n):
    return ("test('живое наблюдение: server+PG18 — оси ПРОЧИТАНЫ из sink "
            "(MEASURED, роль hc_*, ledger %d)', async () => {});" % n)


def delivery_span_tokens(n):
    """Токены span именованного delivery-теста; число ledger — из манифеста
    дерева под проверкой (v4): продукт обязан мерить СВОЁ текущее число
    миграций (007-класс правки обновляет тест вместе с манифестом)."""
    return ('recordInteractionAsync(', 'readSink(', 'MEASURED',
            'runtime_role', str(n), 'http_response')


def _js_call_end(body, p):
    """Индекс ЗА закрывающей ')' вызова, открывающая скобка которого в
    body[p] == '(': баланс ()/{} с учётом строк ' " ` (экранирование
    учтено) и комментариев // /*. Regex-литералы с неспаренными
    кавычками/скобками не разбираются — якорные байты dd8e533 их не
    содержат. None — вызов не закрыт (обрезанный/hostile файл)."""
    depth, k, n, st = 0, p, len(body), None
    while k < n:
        c = body[k]
        nx = body[k + 1] if k + 1 < n else ''
        if st is None:
            if c in '\'"`':
                st = c
            elif c == '/' and nx == '/':
                st = '//'
                k += 1
            elif c == '/' and nx == '*':
                st = '/*'
                k += 1
            elif c in '([{':
                depth += 1
            elif c in ')]}':
                depth -= 1
                if depth == 0:
                    return k + 1
        elif st in ('\'', '"', '`'):
            if c == '\\':
                k += 1
            elif c == st:
                st = None
        elif st == '//':
            if c == '\n':
                st = None
        else:  # '/*'
            if c == '*' and nx == '/':
                st = None
                k += 1
        k += 1
    return None


def _delivery_span(body):
    """(начало, конец) вызова test('живое наблюдение…' СТРОГО до закрытия
    САМОГО вызова: конец — за закрывающей ')' (и ';') по балансу скобок.
    Круг 1 v2 (обход критика, delivery-boundary.json): поиск первой
    строки `});` в колонке 0 выходил в соседний тест, когда именованный
    тест свёрнут в одну строку async () => {} — заимствованные
    токены/assert соседа засчитывались. Теперь span не пересекает границу
    теста: токены и assert-проверки факта считаются только внутри него."""
    i = body.find("test('" + DELIVERY_TEST_TITLE)
    if i < 0:
        return (None, None)
    p = body.find('(', i)
    if p < 0:
        return (None, None)
    j = _js_call_end(body, p)
    if j is None:
        return (None, None)
    if body[j] == ';':
        j += 1
    return (i, j)


def delivery_test_fact(repo, tree=None):
    """I-10 (круг 4, adversary mut-i10): delivery-тест живого наблюдения
    обязан ДОКАЗЫВАТЬ наблюдение, а не присутствовать в отчёте. Статически:
    тело ИМЕНОВАННОГО теста «живое наблюдение: server+PG18…» — span вызова
    test(…) до его закрытия по балансу скобок — несёт вызов
    recordInteractionAsync, чтение sink (readSink) и измеренные ожидания
    (MEASURED/runtime_role/ledger N — число записей манифеста дерева под
    проверкой, v4 — константы нет), ≥5 assert-проверок;
    токены/assert ТОЛЬКО внутри span — заимствование соседнего теста не
    считается (обход критика круга 1 v2). Подмена тела на async () => {}
    выхолащивает их. Живо: файл ИСПОЛНЯЕТСЯ (node --test на disposable
    PG18, правила Ц) — на честном дереве rc 0. Граница:
    токены-без-исполнения статическая часть не различает."""
    tree = tree or Tree(repo)
    try:
        tokens = delivery_span_tokens(len(manifest_entries(tree)))
    except ManifestError as e:
        return (False, 'манифест миграций дерева под проверкой: %s — '
                       'токен ledger именованного теста не выводим '
                       '(fail-closed, v4)' % e.reason)
    body = tree.get(delivery_rel(tree))
    if body is None:
        return (None, 'NEEDS_ENV: %s отсутствует — красный контроль '
                      'delivery-теста (I-10) НЕ проверен' % delivery_rel(tree))
    span_i, span_j = _delivery_span(body)
    if span_i is None:
        return (False, 'тест «%s…» не найден/не закрыт в harness-live.test.js'
                % DELIVERY_TEST_TITLE)
    span = body[span_i:span_j]
    missing = [tok for tok in tokens if tok not in span]
    n_asserts = span.count('assert.')
    if missing or n_asserts < 5:
        return (False, 'тело теста «%s…» выхолащено (I-10): отсутствуют '
                       'токены %s, assert-проверок %d < 5 — тест не '
                       'доказывает живое наблюдение' % (
                           DELIVERY_TEST_TITLE, ','.join(missing) or '-', n_asserts))
    node = shutil.which('node')
    if node is None:
        return (None, 'NEEDS_ENV: node отсутствует — delivery-тест (I-10) НЕ исполнен')
    nm = Path(repo) / tree.p('node_modules')
    if not (nm / 'pg').is_dir():
        return (None, 'NEEDS_ENV: node_modules/pg отсутствует — '
                      'delivery-тест НЕ исполнен')
    try:
        v = subprocess.run(['docker', 'version', '--format', '{{.Server.Version}}'],
                           capture_output=True, text=True, timeout=30)
        docker_ok = v.returncode == 0
    except (OSError, subprocess.TimeoutExpired):
        docker_ok = False
    if not docker_ok:
        return (None, 'NEEDS_ENV: docker недоступен — delivery-тест на PG18 НЕ исполнен')
    role = 'stend109_dl'
    cid = 'stend109dlv' + uuid.uuid4().hex[:8]
    with tempfile.TemporaryDirectory(prefix='stend109-dliv-') as tmp:
        try:
            r = subprocess.run(['docker', 'run', '-d', '--name', cid,
                                '-e', 'POSTGRES_USER=%s' % role,
                                '-e', 'POSTGRES_PASSWORD=probe',
                                '-e', 'POSTGRES_DB=probe',
                                '-p', '127.0.0.1::5432', PG18_IMAGE],
                               capture_output=True, text=True, timeout=180)
            if r.returncode != 0:
                return (False, 'docker run PG18: rc=%d %s' % (
                    r.returncode, (r.stderr or '').strip()[:120]))
            port = None
            for _ in range(30):
                q = subprocess.run(['docker', 'port', cid, '5432/tcp'],
                                   capture_output=True, text=True)
                m = re.search(r'127\.0\.0\.1:(\d+)', q.stdout or '')
                if m:
                    port = m.group(1)
                    break
                time.sleep(1)
            if port is None:
                return (False, 'порт disposable PG18 не получен')
            ready, why = await_disposable_pg18(cid, role)
            if not ready:
                return (None, 'NEEDS_ENV: disposable PG18 не готов за 60 с — '
                              'delivery-тест НЕ исполнен (%s)' % why)
            dest = Path(tmp) / 'r'
            dest.mkdir()
            ok, why2 = _head_worktree(repo, tree, dest)
            if not ok:
                return (False, why2)
            env = dict(os.environ,
                       COMPLIOR_TEST_PG_ADMIN_URL='postgres://%s:probe@127.0.0.1:%s/probe'
                                                  % (role, port))
            try:
                rr = subprocess.run(
                    [node, '--test', '--test-concurrency=1',
                     delivery_rel(tree)],
                    cwd=str(dest / tree.p('pkg_root')) if tree.p('pkg_root') else str(dest),
                    capture_output=True, text=True,
                    timeout=300, env=env)
            except subprocess.TimeoutExpired:
                return (False, 'node --test harness-live: таймаут 300 с')
        finally:
            subprocess.run(['docker', 'rm', '-f', cid],
                           capture_output=True, text=True, timeout=60)
    if rr.returncode == 0:
        passed = len(re.findall(r'^\s*✔', rr.stdout or '', re.M))
        return (True, 'тело теста несёт наблюдение (assert-проверок %d); '
                      'node --test harness-live на PG18: rc 0 (✔ %d)' % (
                          n_asserts, passed))
    tail = ((rr.stdout or '') + (rr.stderr or '')).strip()
    fails = [ln.strip() for ln in tail.splitlines()
             if '✖' in ln or 'fail' in ln.lower()][:4]
    return (False, 'node --test harness-live rc=%d: %s' % (
        rr.returncode, '; '.join(fails)[:240] or tail[:240]))

def check_facts(repo, tree=None):
    """{имя: (True|False|None, пояс)}; None = NEEDS_ENV (честный NOT_RUN)."""
    facts = {}
    r = Path(repo)
    tree = tree or Tree(repo)
    root_ok, root_notes = True, []
    for rel, want_sha in ROOT_SERVER_SHA.items():
        body = tree.get(tree.p('root_server') + '/' + rel)
        sha = sha256_text(body) if body is not None else None
        if sha != want_sha:
            root_ok = False
            root_notes.append('%s sha=%s' % (rel, (sha or 'нет')[:12]))
    facts['ROOT_SERVER_PRESENT'] = (
        root_ok, 'historical SYNTHETIC bytes по sha256: %s' % ('ок' if root_ok else '; '.join(root_notes)))
    node = shutil.which('node')
    facts['RUNNER_DAMAGE_GUARD'] = runner_damage_fact(r, node)
    facts['EGRESS_GUARD'] = egress_fact(repo, tree)
    facts['DRILL_EVIDENCE_GUARD'] = drill_fact(repo, tree)
    facts['HARNESS_TUPLE_GUARD'] = harness_fact(repo, tree)
    facts['DRILL_INPUT_GUARD'] = drill_input_fact(repo, tree)
    facts['HARNESS_HONESTY_GUARD'] = harness_honesty_fact(repo, tree)
    facts['HARNESS_PII_GUARD'] = harness_pii_fact(repo, tree)
    facts['STEND_UP_GUARD'] = stend_up_fact(repo, tree)
    facts['ASYNC_TUPLE_GUARD'] = async_tuple_fact(repo, tree)
    facts['ASYNC_PII_GUARD'] = async_pii_fact(repo, tree)
    facts['LANE_HYGIENE_GUARD'] = lane_hygiene_fact(repo, tree)
    facts['FILES_SHA256_GUARD'] = files_sha_fact(repo, tree)
    facts['BACKEND_LINT_GUARD'] = backend_lint_fact(repo, tree)
    facts['DELIVERY_TEST_RED_CONTROL'] = delivery_test_fact(repo, tree)
    return facts


# ---------------------------------------------------------------- мутанты

def need(text):
    return text is not None

def mut_compose_delete(t):
    return {t.p('compose'): None} if t.get(t.p('compose')) is not None else None



def mut_api_before_migration(t):
    b = t.get(t.p('compose'))
    return {t.p('compose'): b.replace('service_completed_successfully', 'service_started')} if need(b) else None


def mut_image_unpinned(t):
    b = t.get(t.p('compose'))
    return {t.p('compose'): re.sub(r'postgres:18\S*', 'postgres:latest', b)} if need(b) else None


def mut_prod_dump(t):
    b = t.get(t.p('compose'))
    return {t.p('compose'): b + '\n      - ./data/prod_dump:/var/lib/postgresql/dump:ro\n'} if need(b) else None


def mut_ddl_secrets(t):
    b = t.get(t.p('compose'))
    if not need(b):
        return None
    lines = b.split('\n')
    for i, line in enumerate(lines):
        if line.rstrip() == '  api:':
            lines.insert(i + 1, '      MIGRATION_DATABASE_URL: postgres://m:m@db:5432/app')
            break
    else:
        return None
    return {t.p('compose'): '\n'.join(lines)}


def mut_harness_delete(t):
    return {t.p('harness'): None} if t.get(t.p('harness')) is not None else None


def mut_egress_open(t):
    b = t.get(t.p('compose'))
    return {t.p('compose'): b.replace('internal: true', 'internal: false')} if need(b) else None


def mut_db_exposed(t):
    b = t.get(t.p('compose'))
    return {t.p('compose'): b.replace('127.0.0.1:5432', '0.0.0.0:5432')} if need(b) else None


def mut_ephemeral_db(t):
    b = t.get(t.p('compose'))
    return {t.p('compose'): re.sub(r'^(\s*)- [A-Za-z_][A-Za-z0-9_-]*:(/\S*)$',
                                              r'\1- /tmp/pg\2', b, flags=re.M)} if need(b) else None



def mut_harness_overwrite(t):
    b = t.get(t.p('harness'))
    return {t.p('harness'): b.replace("'wx'", "'w'").replace('"wx"', '"w"')} if need(b) else None


def mut_no_scrubber(t):
    b = t.get(t.p('harness'))
    return {t.p('harness'): re.sub(r'(scrub|redact|sanitiz)\w*\(', 'identity(', b)} if need(b) else None


def mut_no_sql(t):
    b = t.get(t.p('harness'))
    if not need(b):
        return None
    return {t.p('harness'): '\n'.join(
        line if 'RECORD_AXES' in line
        else line.replace('sql_before', 'sql').replace('sql_after', 'sql')
        for line in b.split('\n'))}


def mut_no_role(t):
    b = t.get(t.p('harness'))
    return {t.p('harness'): b.replace('current_user', 'session_user')} if need(b) else None


def mut_no_provider(t):
    b = t.get(t.p('harness'))
    if not need(b):
        return None
    return {t.p('harness'): '\n'.join(
        line if 'RECORD_AXES' in line else line.replace('provider_call', 'provider')
        for line in b.split('\n'))}


def mut_no_hashes(t):
    b = t.get(t.p('harness'))
    return {t.p('harness'): b.replace('input_hashes', 'inputs')} if need(b) else None


def mut_mock_success(t):
    b = t.get(t.p('harness'))
    return {t.p('harness'): b.replace("'NOT_RUN'", "'SUCCESS'").replace('"NOT_RUN"', '"SUCCESS"')} if need(b) else None


def mut_no_mode_label(t):
    b = t.get(t.p('harness'))
    return {t.p('harness'): b.replace('FIXTURE_5_8_2', 'FIXTURE')} if need(b) else None


def mut_axis_drop(t):
    b = t.get(t.p('harness'))
    return {t.p('harness'): re.sub(r",\s*['\"]provider_calls['\"]", '', b)} if need(b) else None


def mut_integ_delete(t):
    """HARNESS_INTEGRATION_TEST_MISSING: все harness-тесты удалены. Круг 4:
    I-10 добавил второй живой тест — удаление ОДНОГО файла оставляет провод
    (контроль не краснеет), мутант обязан снимать ВСЮ поверхность."""
    tests = find_harness_tests(t)
    return {rel: None for rel in tests} if tests else None


def mut_script_unwire(t):
    b = t.get(t.p('pkg'))
    if not need(b):
        return None
    return {t.p('pkg'): b.replace('tests/integration/**/*.test.js',
                                              'tests/integration/migrations/**/*.test.js')}


def mut_drill_absent(t):
    for rel in ([t.p('harness')] +
                ['%s/%s' % (t.p('scripts_dir'), n) for n in scripts_names(t)]):
        b = t.get(rel)
        if b and 'drill' in b.lower():
            return {rel: re.sub(r'drill', 'restor', b, flags=re.I)}
    return None


def mut_root_server_delete(t):
    return {t.p('root_server') + '/test/harness.ts': None}

DRILL_DEAD = "const drill = {rpo: 15, rto: 240, state: 'NOT_RUN'};"


def mut_drill_dead_file(t):
    """Обход Б2 круга 1: файл с литералами drill/rpo/rto/NOT_RUN, ничего не исполняет."""
    for rel, _body in script_candidates(t):
        return {rel: DRILL_DEAD + '\n'}
    return None


HARNESS_DECOY = ("module.exports = {recordInteraction: () => "
                 "({mode: 'RUNTIME', http_response: {status: 200}})};")


def mut_harness_decoy(t):
    """Обход Б3 круга 1: record возвращает декой без кортежа/хэшей/provider count."""
    return {t.p('harness'): HARNESS_DECOY} if t.get(t.p('harness')) is not None else None


def mut_egress_unused_net(t):
    """Обход Б1 круга 1: unused-сеть с internal:true, document-worker на default."""
    b = t.get(t.p('compose'))
    if not need(b):
        return None
    lines, out, svc, i = b.split('\n'), [], None, 0
    while i < len(lines):
        line = lines[i]
        m = re.match(r'^  ([A-Za-z0-9_-]+):\s*$', line)
        if m:
            svc = m.group(1)
        if svc and re.search(r'worker|sandbox|document', svc) and re.match(r'^\s+networks:\s*$', line):
            i += 1
            while i < len(lines) and (re.match(r'^\s+-\s+[A-Za-z0-9_-]+\s*$', lines[i])
                                      or re.match(r'^\s{6,}[A-Za-z0-9_-]+:', lines[i])):
                i += 1
            continue
        out.append(line)
        i += 1
    text = '\n'.join(out)
    if re.search(r'^networks:\s*$', text, re.M):
        text = re.sub(r'^networks:\s*$', 'networks:\n  unused_guard:\n    internal: true',
                      text, count=1, flags=re.M)
    else:
        text += '\nnetworks:\n  unused_guard:\n    internal: true\n'
    return {t.p('compose'): text}

def mut_harness_sink_decoy(t):
    """Обход Б1 круга 2: честный return, в sink пишется '{}' — чтение из sink
    (К1) ловит; дельта критика байт-в-байт (writeSync(fd, '{}'))."""
    b = t.get(t.p('harness'))
    if not need(b):
        return None
    return {t.p('harness'): b.replace('fs.writeSync(fd, text);', "fs.writeSync(fd, '{}');")}


def mut_drill_unwired(t):
    """Обход Б2 круга 2: живой коллектор отвязан от поставки — scripts['drill:evidence']
    удалён, require/тест drill удалены, basename только в description; дельта
    критика байт-в-байт."""
    pkg = t.get(t.p('pkg'))
    if not need(pkg) or '"%s"' % DRILL_SCRIPT not in pkg:
        return None
    out = []
    for ln in pkg.split('\n'):
        if '"%s"' % DRILL_SCRIPT in ln:
            if out and out[-1].rstrip().endswith(','):
                out[-1] = out[-1].rstrip()[:-1]
            continue
        out.append(ln)
    pkg2 = re.sub(r'"description": "[^"]*"',
                  '"description": "drill-measure.js"', '\n'.join(out), count=1)
    overlay = {t.p('pkg'): pkg2}
    for rel in find_harness_tests(t):
        body = t.get(rel)
        if not body or 'drill-measure' not in body:
            continue
        keep = [ln for ln in body.splitlines(keepends=True)
                if ln.strip() == "'use strict';" or 'helpers/harness' in ln]
        overlay[rel] = ''.join(keep)
        break
    return overlay


# якорь mode_collapse круга 4 (A-1): байты dd8e533 — запись mode в sync-ветке
# (комментарий отличает пин от рефакторинга судей: на чужой форме мутант
# обязан быть громким NOOP, а не тихой подменой — арбитраж A-2, мера cl55)
MODE_WRITE_BLOCK = ("    // mode уже проверен выше (валидный режим — один из MODE_LABELS), "
                    "подменять нечего.\n    mode: rec.mode,\n")

def mut_harness_mode_collapse(t):
    """Обход Б3 круга 2: все режимы пишутся RUNTIME; mode из sink (К3) ловит.
    Круг 4 (A-1): мёртвый || 'RUNTIME' снят по I-9 — якорь байт-в-байт к
    записи OBJECT-4 (комментарий + строка mode), мутация mode: rec.mode, →
    mode: 'RUNTIME',; якоря нет (иной рефакторинг) — громкий NOOP (A-2)."""
    b = t.get(t.p('harness'))
    if not need(b) or MODE_WRITE_BLOCK not in b:
        return None
    return {t.p('harness'): b.replace(
        MODE_WRITE_BLOCK,
        MODE_WRITE_BLOCK.replace('mode: rec.mode,', "mode: 'RUNTIME',"), 1)}


def mut_scrubber_identity(t):
    """Обход К4 круга 2: scrubSecrets вырожден в identity — сентинел из
    сериализуемого поля остаётся в sink; дельта критика байт-в-байт."""
    b = t.get(t.p('harness'))
    if not need(b):
        return None
    honest = ("function scrubSecrets(text, secrets) {\n"
              "  let out = text;\n"
              "  for (const s of secrets || []) out = out.split(String(s)).join('[REDACTED]');\n"
              "  return out;\n"
              "}")
    decoy = "function scrubSecrets(text, secrets) { return text; }"
    if honest not in b:
        return None
    return {t.p('harness'): b.replace(honest, decoy)}

# ------------------------------------------------- мутанты круга 2 (байт-в-байт
# к дефектным ветвям коммита C a9569176c; на дереве без честного входа мутант
# возвращает None → BLOCKED_BY_RED_CONTROL, не NOOP)

def drill_rel(t):
    return t.p('scripts_dir') + '/drill-measure.js'

# честная валидация чисел measured_* (байты d1cece28; span уточнён кругом 3
# реализации: только блок чисел — at-check вынесен в пару C_AT_WEAK/MODEL_AT_ISO,
# чтобы якорь жил и в честной модели с ISO-валидацией) — мутант удаляет блок:
# measured_* null/строка принимаются, в sink попадает MEASURED с мусором
DRILL_HONEST_VALIDATION = """    if (typeof parsed[k] !== 'number' || !Number.isFinite(parsed[k])) {
      const err = new Error(
        `drill: ${k} обязан быть числом (Number.isFinite); получено ${JSON.stringify(parsed[k])}`,
      );
      err.drillStatus = 'NOT_RUN';
      err.drillCode = 'NOT_MEASURED';
      throw err;
    }
"""

# честная append-only запись 'wx' в writeEvidenceAppendOnly (байты C r4) —
# мутант подменяет на writeFileSync-перезапись: повторный прогон в тот же
# --out затирает измеренный evidence
DRILL_WX_WRITE = """  const fd = fs.openSync(file, 'wx');
  try {
    fs.writeSync(fd, text);
  } finally {
    fs.closeSync(fd);
  }"""
DRILL_C_WRITE = "  fs.writeFileSync(file, text);"

# второй рубеж append-only: pre-check существующего файла в main (байты C r4);
# мутант overwrite снимает ОБА рубежа (pre-check + wx) — один не ломает
# наблюдаемое поведение (defense-in-depth честной ветви)
DRILL_EXISTS_CHECK = """  if (fs.existsSync(target)) {
    process.stderr.write(
      `drill: drill-evidence.json уже существует в ${args.out} (append-only); прежний прогон не перезаписан\\n`,
    );
    process.exit(1);
  }
"""

# валидация mode в recordInteraction — синхронная ветка контракта (байты
# честной ветви C r4 9282c51); мутант удаляет её: без mode срабатывает
# фольбэк || 'RUNTIME' (литерал уже в C) — mode выдумывается в sink
REC_MODE_CHECK = """  if (!MODE_LABELS.includes(rec.mode)) {
    throw new Error(
      `mode обязан быть одним из ${MODE_LABELS.join('/')}; получено ${JSON.stringify(rec.mode)}`,
    );
  }
"""

# валидация mode в recordInteractionAsync — живой путь «реальный HTTP между
# SQL-снимками», объявленный тестом поставки (байты честной ветви C r4);
# мутант удаляет её: MOCK_SUCCESS принимается на живой ветке
ASYNC_MODE_CHECK = """  if (!MODE_LABELS.includes(obs.mode)) {
    throw new Error(
      `mode обязан быть одним из ${MODE_LABELS.join('/')}; получено ${JSON.stringify(obs.mode)}`,
    );
  }
"""

C_PG18_IMAGE = ('postgres:18@sha256:74935e72241653ca55e0414067e6d8763aceb'
                '8a810eb51b452253ec3dcfc4336')
C_PGDATA_SUBPATH = '      - pgdata:/var/lib/postgresql/data\n'
MODEL_PGDATA = '      - pgdata:/var/lib/postgresql\n'

C_PHANTOM_LINES = (
    '3097d4d3d5722554f171e6b0b09e039c1d2fe5fe07d25b6c5264b8850138a083  '
    'evidence/ux175/20261020T013957.891448Z/results.json',
    '3097d4d3d5722554f171e6b0b09e039c1d2fe5fe07d25b6c5264b8850138a083  '
    'evidence/ux175/20261020T014056.435629Z/results.json',
)

# применение паттернов Bearer/cookie/email/phone в scrubRecord (байты честной
# ветви C r4) — мутант удаляет проход: необъявленные Bearer/cookie/email/phone
# утекают в sink
PATTERNS_APPLY = """  for (const p of SCRUBBER_PATTERNS) {
    out = out.replace(p.re, p.replacement);
  }
"""

# bearer-паттерн C r4 9282c51 — ДЕФЕКТ (живой красный факт HARNESS_PII_GUARD):
# префикс \\\\?"? съедает открывающую кавычку JSON-значения authorization,
# replacement её не возвращает — сохранённый evidence не парсится (потребитель
# поставки harness.test.js читает его JSON.parse). MODEL_BEARER — честная
# форма модели (значение чистится, структура цела); пара живёт здесь, чтобы
# модель строилась из констант батареи байт-в-байт.
C_BEARER = r'''  { name: 'bearer', re: /\\?"?Bearer\s+[A-Za-z0-9\-._~+/]+=*/gi, replacement: 'Bearer [REDACTED]' },'''
MODEL_BEARER = r'''  { name: 'bearer', re: /Bearer\s+[A-Za-z0-9\-._~+/]+=*/gi, replacement: 'Bearer [REDACTED]' },'''


def mut_drill_invalid_input(t):
    """F2: measured_* null/строка принимаются (ветвь C — проверки нет)."""
    b = t.get(drill_rel(t))
    if not need(b) or DRILL_HONEST_VALIDATION not in b:
        return None
    return {drill_rel(t): b.replace(DRILL_HONEST_VALIDATION, '', 1)}


def mut_drill_overwrite(t):
    """F2: повторный прогон перезаписывает измеренный evidence — сняты ОБА
    рубежа append-only (existsSync-pre-check и 'wx'), ветвь writeFileSync."""
    b = t.get(drill_rel(t))
    if not need(b) or DRILL_WX_WRITE not in b or DRILL_EXISTS_CHECK not in b:
        return None
    b2 = b.replace(DRILL_EXISTS_CHECK, '', 1).replace(DRILL_WX_WRITE, DRILL_C_WRITE, 1)
    return {drill_rel(t): b2}


def mut_harness_mode_fabricated(t):
    """F3: валидации mode в recordInteraction нет — фольбэк || 'RUNTIME'
    (литерал C r4) пишет RUNTIME без mode; красное предъявление — файл в sink."""
    b = t.get(t.p('harness'))
    if not need(b) or REC_MODE_CHECK not in b:
        return None
    return {t.p('harness'): b.replace(REC_MODE_CHECK, '', 1)}


def mut_harness_mock_mode(t):
    """F3: произвольный mode (MOCK_SUCCESS) принимается на живой ветке
    recordInteractionAsync — валидации нет."""
    b = t.get(t.p('harness'))
    if not need(b) or ASYNC_MODE_CHECK not in b:
        return None
    return {t.p('harness'): b.replace(ASYNC_MODE_CHECK, '', 1)}


def mut_harness_pii_leak(t):
    """F4: scrubber чистит только объявленные secrets — проход паттернов
    Bearer/cookie/email/phone удалён, необъявленные утекают в sink."""
    b = t.get(t.p('harness'))
    if not need(b) or PATTERNS_APPLY not in b:
        return None
    return {t.p('harness'): b.replace(PATTERNS_APPLY, '', 1)}


def mut_compose_pg18_volume_subpath(t):
    """F1/Б1: том pgdata смонтирован в data-подпуть — PG18 отказывается."""
    b = t.get(t.p('compose'))
    if not need(b) or MODEL_PGDATA not in b:
        return None
    return {t.p('compose'): b.replace(MODEL_PGDATA, C_PGDATA_SUBPATH, 1)}


def mut_compose_migrator_pg_image(t):
    """F1/Б1: migrator на образе postgres:18 без node → exec node exit 127."""
    b = t.get(t.p('compose'))
    if not need(b):
        return None
    blocks = service_blocks(services_section(b))
    mig = next((n for n in blocks if re.match(r'migrat', n)), None)
    if mig is None:
        return None
    blk = blocks[mig]
    m = re.search(r'^(\s*)image:\s*\S+\s*$', blk, re.M)
    if m is None or 'postgres' in m.group(0):
        return None
    new_blk = blk[:m.start()] + '%simage: %s' % (m.group(1), C_PG18_IMAGE) + blk[m.end():]
    return {t.p('compose'): b.replace(blk, new_blk, 1)}


def mut_files_sha256_phantom(t):
    """F5/Б3: строки FILES.sha256 ссылаются на файлы вне коммита."""
    b = t.get('FILES.sha256')
    if not need(b) or C_PHANTOM_LINES[0] in b:
        return None
    sep = '' if b.endswith('\n') else '\n'
    return {'FILES.sha256': b + sep + '\n'.join(C_PHANTOM_LINES) + '\n'}

# ------------------------------------------------- мутанты круга 3 реализации
# (настоящий код d1cece28, якоря байт-в-байт; честные формы модели, которых в
# d1cece28 нет (F2'-ISO, отрицательные, гигиена lane), живут парами
# МОДЕЛЬ→ДЕФЕКТ по образцу C_BEARER/MODEL_BEARER)

ASYNC_HTTP_CALL = "    httpResponse = await sendHttpRequest(obs.http_request);\n"
# круг 4 (A-1, I-3): captureSql получил текст оси ВТОРЫМ аргументом — модульного
# состояния больше нет; якоря байт-в-байт к dd8e533
ASYNC_SNAP_BEFORE = ("  const dbBefore = await captureSql('BEFORE', "
                     "snapshotStatement(obs, SNAPSHOT_AXES.BEFORE));\n")
ASYNC_SNAP_AFTER = ("  const dbAfter = await captureSql('AFTER', "
                    "snapshotStatement(obs, SNAPSHOT_AXES.AFTER));\n")
ASYNC_M3_BLOCK = (ASYNC_SNAP_BEFORE + "  let httpResponse = obs.http_response;\n"
                  "  if (obs.http_request && typeof obs.http_request === 'object') {\n"
                  + ASYNC_HTTP_CALL + "  }\n" + ASYNC_SNAP_AFTER)
ASYNC_M3_REORDERED = (ASYNC_SNAP_BEFORE + ASYNC_SNAP_AFTER +
                      "  let httpResponse = obs.http_response;\n"
                      "  if (obs.http_request && typeof obs.http_request === 'object') {\n"
                      + ASYNC_HTTP_CALL + "  }\n")
ASYNC_CONST_SNAP = ("{ sql: 'X', status: 'NOT_RUN', "
                    "reason: 'connect ECONNREFUSED (constant, no I/O)' }")
ASYNC_CONST_HTTP = ('    httpResponse = { status: 200, body: \'{"ok":true}\', '
                    'headers: {}, latency_ms: 0 };\n')
# круг 4 (A-1, I-6): set-cookie теперь структурный ключ SECRET_KEYS (замкнутый
# перечень K арбитража), не текстовый паттерн — якорь к dd8e533
SECRETKEYS_SETCOOKIE = ("  'set-cookie': redactSetCookieOne,\n"
                        "  setcookie: redactSetCookieOne,\n")
# круг 4 (A-1, I-7/I-9): якоря байт-в-байт к dd8e533 — измеренная ось роли
# (тернар NOT_RUN) и единая строка async-записи со scrubRecord
ASYNC_ROLE_HONEST = ("    runtime_role: dbBefore.status === 'MEASURED' "
                     "? dbBefore.current_user : 'NOT_RUN',\n")
ASYNC_WRITE_SCRUB = ("  appendExclusive(evidenceFileName(dir, out), "
                     "scrubRecord(out, obs.secrets || []));\n")
ROLE_BOOTSTRAT_NOSUPER = ('NOSUPERUSER NOCREATEDB NOCREATEROLE NOBYPASSRLS '
                          'IN ROLE brokeros_api')
API_DB_URL_BLOCK = ('    DATABASE_URL: postgres://hc_synthetic_only:synthetic'
                    '@postgres:5432/complior\n      HOST: 0.0.0.0\n      PORT: "8080"')
API_DB_URL_SUPERUSER = ('    DATABASE_URL: postgres://postgres:ci-synthetic-only'
                        '@postgres:5432/complior\n      HOST: 0.0.0.0\n      PORT: "8080"')
MIGRATOR_CMD_LINES = {
    # команда migrator в compose — якорь байт-в-байт к ЖИВОМУ дереву, не к карте:
    # починенный продукт (b73ad11, CMP-BCK-004/stend) в НОВОЙ колонке несёт
    # «node server/infrastructure/migrations/run.js» (= PATHS[LAYOUT_NEW]
    # ['runner'] и scripts.migrate пакета; тома ./server/infrastructure/
    # migrations, ./migrations, ./node_modules); СТАРАЯ колонка — прежние байты
    # «node infra/migrations/run.js». Якорь обязан следовать живым байтам:
    # расхождение с деревом — громкий NOOP_MUTATION (A-2), не молчание.
    LAYOUT_NEW: '    command: ["node", "server/infrastructure/migrations/run.js"]\n',
    LAYOUT_OLD: '    command: ["node", "infra/migrations/run.js"]\n',
}


def _js_fromchar(s):
    return 'String.fromCharCode(%s)' % ','.join(str(ord(c)) for c in s)


def m9_rewrite_cmd(layout):
    """С7/M9: команда мутанта сохраняет ЖИВОЙ раннер раскладки
    (PATHS[layout]['runner'] — мигратор обязан отработать, счёт остаётся N)
    и дописывает перезапись applied_by: редкость ловится сравнением
    содержимого строк ledger между повторными up, а не падением migrator."""
    return (
        '    command: ["sh", "-c", "node %s && node -e '
        "'const { Client } = require(%s); const c = new Client({ connectionString: "
        'process.env.MIGRATION_DATABASE_URL }); c.connect().then(() => c.query(%s))'
        ".then(() => c.end()).catch((e) => { console.error(e.message); "
        "process.exit(1); })'\"]\n" % (
            PATHS[layout]['runner'],
            _js_fromchar('pg'),
            _js_fromchar('UPDATE control.schema_migration SET applied_by=md5(applied_by)')))

# честная ISO-валидация measured_at (модель круга 3) и дефектная ветвь d1cece28
# (только непустота: «never»/«ok» проходят как MEASURED — F2')
MODEL_AT_ISO = """  if (typeof parsed.measured_at !== 'string' || !isValidIso8601(parsed.measured_at)) {
    const err = new Error(
      `drill: measured_at обязан быть строкой ISO-8601; получено ${JSON.stringify(parsed.measured_at)}`,
    );
    err.drillStatus = 'NOT_RUN';
    err.drillCode = 'NOT_MEASURED';
    throw err;
  }
"""
C_AT_WEAK = """  if (typeof parsed.measured_at !== 'string' || parsed.measured_at.length === 0) {
    const err = new Error(
      `drill: measured_at обязан быть непустой строкой ISO; получено ${JSON.stringify(parsed.measured_at)}`,
    );
    err.drillStatus = 'NOT_RUN';
    err.drillCode = 'NOT_MEASURED';
    throw err;
  }
"""
# честная неотрицательность measured_* (модель круга 3; в d1cece28 ветви нет — С5)
MODEL_NEG_CHECK = """    if (parsed[k] < 0) {
      const err = new Error(`drill: ${k} не может быть отрицательным; получено ${parsed[k]}`);
      err.drillStatus = 'NOT_RUN';
      err.drillCode = 'NOT_MEASURED';
      throw err;
    }
"""
# гигиена H-checkout в lane stend109: якорь круга 4 (A-1, A-8) — байты
# dd8e533 (I-5 вернул pin+hash-object; сообщение переформатировано) —
# мутант удаляет проверку чистоты: грязный probe.py проходит
MODEL_LANE_HYGIENE = """        # A2/С3 (круг 2): рабочее дерево обязано быть чистым — незакоммиченная подмена файлов
        # не исполняется как frozen-батарея.
        dirty = subprocess.run(
            ['git', '-C', str(h_root), 'status', '--porcelain'],
            capture_output=True, text=True,
        )
        if dirty.returncode != 0 or dirty.stdout.strip():
            return 1, (
                f'{h_root}: рабочее дерево не чистое ({dirty.stdout.strip()[:200]}); батарея '
                f'исполняется только из чистого checkout тега {tag}.\\n'
            )
"""

# круг 4 (A-8, I-5): второй рубеж гигиены — hash-object-сверка байтов пробы с
# блобом пина (байты dd8e533); мутант lane_dirty снимает ОБА рубежа (этот и
# MODEL_LANE_HYGIENE) — один не ломает наблюдаемое поведение (defense-in-depth)
LANE_HASH_BLOCK = """        got = subprocess.run(
            ['git', '-C', str(h_root), 'hash-object', str(probe)],
            capture_output=True, text=True,
        )
        if got.returncode != 0:
            return 1, f'{h_root}: hash-object не отработал: {got.stderr[:300]}'
        if got.stdout.strip() != blob.stdout.strip():
            return 1, (
                f'{h_root}: байты {STEND109_PROBE} ({got.stdout.strip()}) не совпадают с блобом '
                f'пина {STEND109_PIN} ({blob.stdout.strip()}); подмена батареи.\\n'
            )
"""


def mut_harness_async_no_http(t):
    """Б2′/F3'/M1: реальный HTTP не делается — ответ из заявления наблюдения."""
    b = t.get(t.p('harness'))
    if not need(b) or ASYNC_HTTP_CALL not in b:
        return None
    return {t.p('harness'): b.replace(ASYNC_HTTP_CALL,
                               "    httpResponse = obs.http_response;\n", 1)}


def mut_harness_async_sql_const(t):
    """Б2′/F3'/M2: SQL-снимок всегда NOT_RUN константой (живой SQL не меряется)."""
    b = t.get(t.p('harness'))
    old = "  const url = process.env.COMPLIOR_HARNESS_DATABASE_URL || process.env.DATABASE_URL;\n"
    if not need(b) or old not in b:
        return None
    return {t.p('harness'): b.replace(old, "  const url = null;\n", 1)}


def mut_harness_async_http_after(t):
    """Б2′/F3'/M3: HTTP после обоих SQL-снимков (не «между»)."""
    b = t.get(t.p('harness'))
    if not need(b) or ASYNC_M3_BLOCK not in b:
        return None
    return {t.p('harness'): b.replace(ASYNC_M3_BLOCK, ASYNC_M3_REORDERED, 1)}


def mut_harness_async_role_claimed(t):
    """Б2′/F3'/M4: runtime_role — заявление вызывающего, не измерение БД.
    Круг 4 (A-1, I-7): честная форма dd8e533 — тернар «MEASURED? current_user
    : NOT_RUN»; мутация возвращает заявление. На 8aca71a/М15 якоря нет — NOOP."""
    b = t.get(t.p('harness'))
    if not need(b) or ASYNC_ROLE_HONEST not in b:
        return None
    return {t.p('harness'): b.replace(ASYNC_ROLE_HONEST,
                               "    runtime_role: obs.runtime_role,\n", 1)}


def mut_harness_async_constants(t):
    """Б2′ (обход reviewer круга 2): recordInteractionAsync без всякого I/O —
    снимки и ответ заменены константами; строки 1–3 и 5 были зелёные."""
    b = t.get(t.p('harness'))
    if not need(b) or any(x not in b for x in (ASYNC_SNAP_BEFORE,
                                               ASYNC_HTTP_CALL,
                                               ASYNC_SNAP_AFTER)):
        return None
    out = b.replace(ASYNC_SNAP_BEFORE, "  const dbBefore = %s;\n" % ASYNC_CONST_SNAP, 1)
    out = out.replace(ASYNC_HTTP_CALL, ASYNC_CONST_HTTP, 1)
    out = out.replace(ASYNC_SNAP_AFTER, "  const dbAfter = %s;\n" % ASYNC_CONST_SNAP, 1)
    return {t.p('harness'): out}


def mut_harness_async_no_scrub(t):
    """F4'/M5: async-ветка пишет нескрабленный JSON.stringify (без scrubRecord).
    Круг 4 (A-1, I-9): единый путь записи appendExclusive(..., scrubRecord(...)) —
    якорь к строке async-записи dd8e533, не к хвосту файла."""
    b = t.get(t.p('harness'))
    if not need(b) or ASYNC_WRITE_SCRUB not in b:
        return None
    return {t.p('harness'): b.replace(
        ASYNC_WRITE_SCRUB,
        "  appendExclusive(evidenceFileName(dir, out), "
        "JSON.stringify(out, null, 2));\n", 1)}


def mut_harness_no_setcookie_pattern(t):
    """F4'/M6: структурная маскировка set-cookie удалена — Set-Cookie-массив
    реального ответа уносит секрет в sink. Круг 4 (A-1, I-6): носитель —
    SECRET_KEYS (замкнутый перечень K), не текстовый паттерн."""
    b = t.get(t.p('harness'))
    if not need(b) or SECRETKEYS_SETCOOKIE not in b:
        return None
    return {t.p('harness'): b.replace(SECRETKEYS_SETCOOKIE, '', 1)}


# круг 4 (A-4): MODEL — строгий isValidIso8601 OBJECT-4 (dd8e533) байт-в-байт;
# ДЕКОЙ — тело 8aca71a байт-в-байт (Date.parse + round-trip: пропускает «1»,
# «May 5», «12/31/2026», «2026-02-31», дату без зоны — З-1 арбитража)
ISO_STRICT_FN = """const isValidIso8601 = (s) => {
  if (typeof s !== 'string' || s.length === 0) return false;
  const m = ISO8601_WITH_ZONE.exec(s);
  if (!m) return false;
  const [, ys, mons, ds, hs, mins, secs, zone] = m;
  const year = Number(ys);
  const month = Number(mons);
  const day = Number(ds);
  if (month < 1 || month > 12) return false;
  if (Number(hs) > 23 || Number(mins) > 59 || Number(secs) > 59) return false;
  // Календарная дата: собираем её и сверяем ОБРАТНО в y/m/d. Несуществующий день откатывается
  // в следующий месяц (2026-02-31 → 2026-03-03, 2027-02-29 → 2027-03-01) и не совпадает.
  // setUTCFullYear, а не конструктор с 4-мя аргументами: years 0..99 в Date.UTC получают 1900+y.
  const cal = new Date(0);
  cal.setUTCHours(0, 0, 0, 0);
  cal.setUTCFullYear(year, month - 1, day);
  if (
    cal.getUTCFullYear() !== year ||
    cal.getUTCMonth() !== month - 1 ||
    cal.getUTCDate() !== day
  ) {
    return false;
  }
  if (zone !== 'Z') {
    const zh = Number(zone.slice(1, 3));
    const zm = Number(zone.slice(4, 6));
    if (zh > 14 || zm > 59) return false;
  }
  return true;
};"""
ISO_DATEPARSE_DECOY = """const isValidIso8601 = (s) => {
  if (typeof s !== 'string' || s.length === 0) return false;
  const ts = Date.parse(s);
  if (!Number.isFinite(ts)) return false;
  // round-trip: перепарсинг через Date(toISOString()) должен дать тот же ts.
  const d = new Date(ts);
  const iso = d.toISOString();
  // для строк с timezone '2026-10-20T03:00:00.000Z' — точное совпадение.
  // для строк без timezone '2026-10-20' — iso будет '2026-10-20T00:00:00.000Z'; принимаем.
  return Number.isFinite(Date.parse(iso));
};"""

def mut_drill_at_not_iso(t):
    """F2'/круг 4 (A-4): строгий isValidIso8601 OBJECT-4 заменён ДЕКОЕМ 8aca71a
    байт-в-байт (Number.isFinite(Date.parse) + round-trip): «1»/«May 5»/
    «12/31/2026»/«2026-02-31»/дата-без-зоны проходят как MEASURED."""
    b = t.get(drill_rel(t))
    if not need(b) or ISO_STRICT_FN not in b:
        return None
    return {drill_rel(t): b.replace(ISO_STRICT_FN, ISO_DATEPARSE_DECOY, 1)}


def mut_drill_negative_accepted(t):
    """С5: отрицательные measured_rpo/rto принимаются как MEASURED."""
    b = t.get(drill_rel(t))
    if not need(b) or MODEL_NEG_CHECK not in b:
        return None
    return {drill_rel(t): b.replace(MODEL_NEG_CHECK, '', 1)}


def mut_stend_role_superuser(t):
    """С7/M7: LOGIN-роль role-bootstrap создаётся суперпользователем."""
    b = t.get(t.p('scripts_dir') + '/role-bootstrap.js')
    if not need(b) or ROLE_BOOTSTRAT_NOSUPER not in b:
        return None
    return {t.p('scripts_dir') + '/role-bootstrap.js': b.replace(
        ROLE_BOOTSTRAT_NOSUPER, 'SUPERUSER IN ROLE brokeros_api', 1)}


def mut_stend_api_superuser_url(t):
    """С7/M8: api ходит в БД под суперпользователем postgres."""
    b = t.get(t.p('compose'))
    if not need(b) or API_DB_URL_BLOCK not in b:
        return None
    return {t.p('compose'): b.replace(API_DB_URL_BLOCK,
                                                 API_DB_URL_SUPERUSER, 1)}


def mut_stend_ledger_rewritten(t):
    """С7/M9: каждый up переписывает ledger (applied_by=md5(applied_by)),
    count остаётся N — сравнение содержимого строк ловит подмену."""
    lay = t.layout or LAYOUT_OLD
    b = t.get(t.p('compose'))
    if not need(b) or MIGRATOR_CMD_LINES[lay] not in b:
        return None
    return {t.p('compose'): b.replace(MIGRATOR_CMD_LINES[lay],
                                      m9_rewrite_cmd(lay), 1)}


def mut_lane_dirty_checkout_ok(t):
    """A2/С3 + круг 4 (A-8): гигиена H-checkout снята ЦЕЛИКОМ — оба рубежа
    (hash-object-сверка байтов пробы с блобом пина и проверка чистоты
    дерева): незакоммиченная подмена probe.py и подмена под
    assume-unchanged исполняются как frozen-батарея (pin-check HEAD остаётся
    — мутант обходит «грязный»/«assume-unchanged», не «retag»)."""
    b = t.get(t.p('lane'))
    if not need(b) or MODEL_LANE_HYGIENE not in b or LANE_HASH_BLOCK not in b:
        return None
    return {t.p('lane'): b.replace(LANE_HASH_BLOCK, '', 1)
                                         .replace(MODEL_LANE_HYGIENE, '', 1)}

def mut_backend_lint_unused_const(t):
    """I-1 (форма mut-i1 adversary): РОВНО один неиспользуемый const в
    harness.js — lint падает (no-unused-vars), поведение harness не меняет
    ни один исполняемый байт. Якорь — строка SNAPSHOT_AXES dd8e533
    (единственная, наименьшая стабильная точка вставки); на деревьях без
    якоря — громкий NOOP_MUTATION (A-2)."""
    b = t.get(t.p('harness'))
    if not need(b):
        return None
    anchor = "const SNAPSHOT_AXES = { BEFORE: 'sql_before', AFTER: 'sql_after' };"
    if b.count(anchor) != 1:
        return None
    return {t.p('harness'): b.replace(
        anchor, 'const stend109LintUnused = 1;\n' + anchor, 1)}


def mut_delivery_live_noop(t):
    """I-10 (форма mut-i10 adversary): тело delivery-теста «живое
    наблюдение: server+PG18…» заменено на async () => {} — файл, имя теста,
    before/after и соседние тесты не тронуты; test:integration остаётся
    зелёным (44/44), а наблюдение перестаёт доказываться. Якорь — строка
    теста; на деревьях без файла/строки — NOOP_MUTATION (A-2)."""
    b = t.get(delivery_rel(t))
    if not need(b):
        return None
    try:
        n = len(manifest_entries(t))
    except ManifestError:
        return None
    i, j = _delivery_span(b)
    if i is None:
        return None
    return {delivery_rel(t): b[:i] + delivery_noop_body(n) + b[j:]}

DELIVERY_NEIGHBOR_READ = 'const raw = readSink(dir);'
DELIVERY_NEIGHBOR_ASSERT = ("  assert.equal(raw.http_response.status, 200, "
                            "'ответ настоящего сервера');")


def mut_delivery_noop_borrow_neighbor(t):
    """Обход критика круга 1 v2 (delivery-boundary.json): тело ИМЕНОВАННОГО
    теста выхолощено в ОДНУ строку async () => {} (форма mut-i10), а
    соседний multistatement-тест переставлен СРАЗУ за пустым тестом и
    усилен живым assert http_response сразу после readSink — проверки
    соседа исполняются по-настоящему, наблюдение именованного теста не
    доказывается. Span-граница обязана закрыться на строке самого пустого
    теста: заимствованные токены/assert НЕ считаются. Якорь — байты
    dd8e533 (строка именованного теста + readSink в соседнем top-level
    тесте); на деревьях без якоря — громкий NOOP_MUTATION (A-2)."""
    b = t.get(delivery_rel(t))
    if not need(b):
        return None
    i, j = _delivery_span(b)
    if i is None:
        return None
    try:
        n = len(manifest_entries(t))
    except ManifestError:
        return None
    nb = None
    for m in re.finditer(r'(?m)^test\(', b):
        if m.start() == i:
            continue
        p2 = b.find('(', m.start())
        end2 = _js_call_end(b, p2) if p2 >= 0 else None
        if end2 is not None and b[end2] == ';':
            end2 += 1
        if end2 is None:
            continue
        seg = b[m.start():end2]
        if 'readSink(dir)' in seg and DELIVERY_TEST_TITLE not in seg:
            nb = (m.start(), end2, seg)
            break
    if nb is None:
        return None
    if nb[2].count(DELIVERY_NEIGHBOR_READ) != 1:
        return None
    seg = nb[2].replace(DELIVERY_NEIGHBOR_READ,
                        DELIVERY_NEIGHBOR_READ + '\n' + DELIVERY_NEIGHBOR_ASSERT, 1)
    out = b[:i] + delivery_noop_body(n) + '\n\n' + seg
    mid = b[j:nb[0]].strip('\n')
    if mid:
        out += '\n\n' + mid
    out += '\n'
    return {delivery_rel(t): out}


def mut_manifest_absent(t):
    """v4: манифест миграций удалён из дерева под проверкой — ожидание
    ledger не выводимо; честная батарея ОТКАЗЫВАЕТСЯ с именованной
    причиной (rc 2 MANIFEST_MISSING на CLI; факт STEND_UP_GUARD красен),
    а не судит по молчаливой константе."""
    if t.get(t.p('manifest')) is None:
        return None
    return {t.p('manifest'): None}


def mut_manifest_empty(t):
    """v4: манифест с пустым перечнем migrations: [] — fail-closed
    MANIFEST_EMPTY (rc 2 CLI; факт STEND_UP_GUARD красен), не «принят
    как ноль»."""
    body = t.get(t.p('manifest'))
    if not need(body):
        return None
    return {t.p('manifest'): '{"source": "migrations/", "migrations": []}\n'}


def mut_manifest_extra_file(t):
    """v4: .sql вне манифеста (лишний файл каталога) — несоответствие
    манифеста набору файлов; сам раннер 129 отказал бы ДО DDL; проба —
    fail-closed MANIFEST_MISMATCH_FILES (rc 2 CLI; факт красен)."""
    try:
        entries = manifest_entries(t)
    except ManifestError:
        return None
    extra = 'zzz_vne_manifesta_109.sql'
    if extra in {e['file'] for e in entries}:
        return None
    return {t.p('db_dir') + '/' + extra:
            '-- файл вне манифеста: раннер 129 отказывает до DDL\n'
            'BEGIN;\nSELECT 1;\nCOMMIT;\n'}


def mut_delivery_token_stale(t):
    """v4: манифест ведёт N миграций, а delivery-тест всё ещё мерит
    прежнее число (класс 007: продукт добавил миграции, тест не догнал) —
    span теряет токен str(N), факт DELIVERY_TEST_RED_CONTROL красен:
    константа в тесте не может пережить изменение манифеста."""
    b = t.get(delivery_rel(t))
    if not need(b):
        return None
    try:
        n = len(manifest_entries(t))
    except ManifestError:
        return None
    if n < 1:
        return None
    stale, fresh = n - 1, n
    i, j = _delivery_span(b)
    if i is None or ('ledger %d' % fresh) not in b[i:j]:
        return None
    span = b[i:j]
    # застаивают ВСЕ числовые формы ожидания в span: заголовок, assert
    # длины и текст сообщения — одна оставшаяся форма проходит токен-проверку
    for a, c in (('ledger %d', 'ledger %d'),
                 ('rows.length, %d', 'rows.length, %d'),
                 ('измерен: %d строк', 'измерен: %d строк')):
        span = span.replace(a % fresh, c % stale)
    return {delivery_rel(t): b[:i] + span + b[j:]}


CASES = [
    ('compose_delete', 'COMPOSE_MISSING', mut_compose_delete),
    ('compose_api_before_migration', 'COMPOSE_API_BEFORE_MIGRATION', mut_api_before_migration),
    ('compose_image_unpinned', 'COMPOSE_IMAGE_UNPINNED', mut_image_unpinned),
    ('compose_prod_dump', 'COMPOSE_PROD_DUMP_MOUNTED', mut_prod_dump),
    ('compose_ddl_secrets', 'COMPOSE_DDL_SECRETS_TO_API', mut_ddl_secrets),
    ('compose_egress_open', 'COMPOSE_EGRESS_OPEN', mut_egress_open),
    ('compose_db_exposed', 'COMPOSE_DB_EXPOSED_UNRESTRICTED', mut_db_exposed),
    ('compose_ephemeral_db', 'COMPOSE_EPHEMERAL_DB', mut_ephemeral_db),
    ('harness_delete', 'HARNESS_MISSING', mut_harness_delete),
    ('harness_overwrite', 'HARNESS_EVIDENCE_OVERWRITES', mut_harness_overwrite),
    ('harness_no_scrubber', 'HARNESS_NO_SCRUBBER', mut_no_scrubber),
    ('harness_no_sql', 'HARNESS_NO_SQL_BEFORE_AFTER', mut_no_sql),
    ('harness_no_role', 'HARNESS_NO_RUNTIME_ROLE', mut_no_role),
    ('harness_no_provider', 'HARNESS_NO_PROVIDER_COUNT', mut_no_provider),
    ('harness_no_hashes', 'HARNESS_NO_MANIFEST_HASHES', mut_no_hashes),
    ('harness_mock_success', 'HARNESS_DB_DOWN_MOCK_SUCCESS', mut_mock_success),
    ('harness_no_mode_label', 'HARNESS_NO_MODE_LABEL', mut_no_mode_label),
    ('harness_axis_drop', 'HARNESS_RECORD_AXIS_TUPLE', mut_axis_drop),
    ('integ_test_delete', 'HARNESS_INTEGRATION_TEST_MISSING', mut_integ_delete),
    ('script_unwire', 'TEST_INTEGRATION_NOT_WIRED', mut_script_unwire),
    ('drill_absent', 'DRILL_MEASUREMENTS_ABSENT', mut_drill_absent),
    ('root_server_delete', 'ROOT_SERVER_PRESENT', mut_root_server_delete),
    ('compose_egress_unused_net', 'COMPOSE_EGRESS_OPEN', mut_egress_unused_net),
    ('drill_dead_file', 'DRILL_EVIDENCE_GUARD', mut_drill_dead_file),
    ('harness_tuple_decoy', 'HARNESS_TUPLE_GUARD', mut_harness_decoy),
    ('harness_sink_decoy', 'HARNESS_TUPLE_GUARD', mut_harness_sink_decoy),
    ('drill_unwired', 'DRILL_MEASUREMENTS_ABSENT', mut_drill_unwired),
    ('harness_mode_collapse', 'HARNESS_TUPLE_GUARD', mut_harness_mode_collapse),
    ('harness_scrubber_identity', 'HARNESS_TUPLE_GUARD', mut_scrubber_identity),
    ('drill_invalid_input', 'DRILL_INPUT_GUARD', mut_drill_invalid_input),
    ('drill_overwrite_evidence', 'DRILL_INPUT_GUARD', mut_drill_overwrite),
    ('harness_mode_fabricated', 'HARNESS_HONESTY_GUARD', mut_harness_mode_fabricated),
    ('harness_mock_mode_accepted', 'HARNESS_HONESTY_GUARD', mut_harness_mock_mode),
    ('harness_pii_leak', 'HARNESS_PII_GUARD', mut_harness_pii_leak),
    ('compose_pg18_volume_subpath', 'STEND_UP_GUARD', mut_compose_pg18_volume_subpath),
    ('compose_migrator_pg_image', 'STEND_UP_GUARD', mut_compose_migrator_pg_image),
    ('files_sha256_phantom', 'FILES_SHA256_GUARD', mut_files_sha256_phantom),
    ('harness_async_no_http', 'ASYNC_TUPLE_GUARD', mut_harness_async_no_http),
    ('harness_async_sql_const', 'ASYNC_TUPLE_GUARD', mut_harness_async_sql_const),
    ('harness_async_http_after', 'ASYNC_TUPLE_GUARD', mut_harness_async_http_after),
    ('harness_async_role_claimed', 'ASYNC_TUPLE_GUARD', mut_harness_async_role_claimed),
    ('harness_async_constants', 'ASYNC_TUPLE_GUARD', mut_harness_async_constants),
    ('harness_async_no_scrub', 'ASYNC_PII_GUARD', mut_harness_async_no_scrub),
    ('harness_no_setcookie_pattern', 'ASYNC_PII_GUARD', mut_harness_no_setcookie_pattern),
    ('drill_at_not_iso', 'DRILL_INPUT_GUARD', mut_drill_at_not_iso),
    ('drill_negative_accepted', 'DRILL_INPUT_GUARD', mut_drill_negative_accepted),
    ('stend_role_superuser', 'STEND_UP_GUARD', mut_stend_role_superuser),
    ('stend_api_superuser_url', 'STEND_UP_GUARD', mut_stend_api_superuser_url),
    ('stend_ledger_rewritten', 'STEND_UP_GUARD', mut_stend_ledger_rewritten),
    ('lane_dirty_checkout_ok', 'LANE_HYGIENE_GUARD', mut_lane_dirty_checkout_ok),
    ('backend_lint_unused_const', 'BACKEND_LINT_GUARD', mut_backend_lint_unused_const),
    ('delivery_live_noop_body', 'DELIVERY_TEST_RED_CONTROL', mut_delivery_live_noop),
    ('delivery_noop_borrow_neighbor', 'DELIVERY_TEST_RED_CONTROL', mut_delivery_noop_borrow_neighbor),
    ('stend_manifest_absent', 'STEND_UP_GUARD', mut_manifest_absent),
    ('stend_manifest_empty', 'STEND_UP_GUARD', mut_manifest_empty),
    ('stend_manifest_extra_file', 'STEND_UP_GUARD', mut_manifest_extra_file),
    ('delivery_token_stale', 'DELIVERY_TEST_RED_CONTROL', mut_delivery_token_stale),
]

# фактов пятнадцать, клеток пятьдесят семь (круг 4: пере-якорение dd8e533,
# A-3…A-8 расширены внутри существующих фактов/клеток; черновик v2 (форк
# n109-krug4-fail) добавляет BACKEND_LINT_GUARD и DELIVERY_TEST_RED_CONTROL
# с клетками форм mut-i1/mut-i10; v2b закрывает обход критика круга 1:
# span именованного теста по балансу скобок + клетка
# delivery_noop_borrow_neighbor; v4 (слово владельца 2026-10-26) добавляет
# ЧЕТЫРЕ клетки fail-closed манифеста/токена — прежние клетки не меняются,
# константа 14 в судействе заменена ожиданием из манифеста дерева):
# run_case вызывает ТОЛЬКО целевой факт мутанта, не пересчитывая все
# (живые docker-факты дорогие); семантика прежних целей не меняется.
FACT_FUNCS = {
    'RUNNER_DAMAGE_GUARD': lambda repo, tree: runner_damage_fact(repo, shutil.which('node')),
    'EGRESS_GUARD': egress_fact,
    'DRILL_EVIDENCE_GUARD': drill_fact,
    'HARNESS_TUPLE_GUARD': harness_fact,
    'DRILL_INPUT_GUARD': drill_input_fact,
    'HARNESS_HONESTY_GUARD': harness_honesty_fact,
    'HARNESS_PII_GUARD': harness_pii_fact,
    'STEND_UP_GUARD': stend_up_fact,
    'FILES_SHA256_GUARD': files_sha_fact,
    'ASYNC_TUPLE_GUARD': async_tuple_fact,
    'ASYNC_PII_GUARD': async_pii_fact,
    'LANE_HYGIENE_GUARD': lane_hygiene_fact,
    'BACKEND_LINT_GUARD': backend_lint_fact,
    'DELIVERY_TEST_RED_CONTROL': delivery_test_fact,
}


def run_case(repo, name, base_fired, base_facts_red):
    entry = next((c for c in CASES if c[0] == name), None)
    if entry is None:
        return {'error': 'EMPTY_SELECTION'}
    _, target, mut = entry
    overlay = mut(Tree(repo))
    if overlay is None:
        # круг 4 (A-2, арбитраж С8/С-ЯКОРЬ + мера M15): пропавший якорь —
        # громкий NOOP_MUTATION (rc 2); BLOCKED_BY_RED_CONTROL — только при
        # красном КОНТРОЛЕ базы (замороженный контракт, строка 3: «no-op
        # мутация — rc 2»). Красный ФАКТ базы не глушит NOOP: арбитражная
        # мера «--case harness_async_role_claimed на M15 → rc 2» предписана
        # дереву, чья цель факта красна самим A-3 (8aca71a-семейство)
        if base_fired:
            return {'name': name, 'target': target, 'applied': False,
                    'verdict': 'BLOCKED_BY_RED_CONTROL', 'depends': [],
                    'note': 'вход мутации отсутствует (контроль базы красен)'}
        return {'name': name, 'target': target, 'applied': False,
                'verdict': 'NOOP_MUTATION', 'depends': [],
                'note': 'якорь мутанта отсутствует на базе — батарея '
                        'требует переякоривания (A-1)'}
    tree = Tree(repo, overlay)
    # круг 4 (A-2): overlay == база (мутация не изменила НИ ОДИН байт) ⇒
    # NOOP ДО вызова факта — дорогой живой факт не исполняется впустую
    if all(tree.get(rel) == Tree(repo).get(rel) for rel in overlay):
        return {'name': name, 'target': target, 'applied': False,
                'verdict': 'NOOP_MUTATION', 'depends': [],
                'note': 'мутация не изменила ни один файл (overlay == база)'}
    if target == 'ROOT_SERVER_PRESENT':
        newly = {'ROOT_SERVER_PRESENT'} if tree.get(
            tree.p('root_server') + '/test/harness.ts') is None else set()
        newly -= base_facts_red
        return {'name': name, 'target': target, 'applied': True,
                'verdict': 'REJECTED_EXACT' if newly == {'ROOT_SERVER_PRESENT'} else 'NOT_REJECTED',
                'depends': sorted(newly)}
    if target in FACT_FUNCS:
        mut_v = FACT_FUNCS[target](repo, tree)[0]
        if target in base_facts_red:
            # цель мутанта уже красна на базе (именованное красное дерева):
            # кейс не судится — BLOCKED_BY_RED_CONTROL, как и структурный путь
            return {'name': name, 'target': target, 'applied': True,
                    'verdict': 'BLOCKED_BY_RED_CONTROL', 'depends': [],
                    'note': 'цель мутанта уже красна на базе (дефект дерева)'}
        if target == 'LANE_HYGIENE_GUARD' and lane_depth_env() >= 1:
            # v2: вложенный (внутри lane-факта) прогон батареи НЕ судит
            # lane-гигиену — её судит ВНЕШНИЙ факт (маркер глубины); клетка
            # не красна и не зелена — поименованный пропуск, не NOT_REJECTED
            return {'name': name, 'target': target, 'applied': True,
                    'verdict': 'SKIP_NESTED_DEPTH', 'depends': [],
                    'note': 'вложенный прогон (%s≥1): lane-гигиена судится '
                            'внешним lane-фактом' % LANE_DEPTH_MARKER}
        newly = {target} if mut_v is False else set()
        return {'name': name, 'target': target, 'applied': True,
                'verdict': 'REJECTED_EXACT' if newly == {target} else 'NOT_REJECTED',
                'depends': sorted(newly)}
    fired, _ = subject_control(tree)
    newly = fired - base_fired
    if newly == {target}:
        verdict = 'REJECTED_EXACT'
    elif not newly:
        verdict = 'BLOCKED_BY_RED_CONTROL'
    else:
        verdict = 'NOT_REJECTED'
    return {'name': name, 'target': target, 'applied': True, 'verdict': verdict,
            'depends': sorted(newly)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', required=True)
    ap.add_argument('--out')
    ap.add_argument('--case')
    ap.add_argument('--matrix', action='store_true')
    args = ap.parse_args()
    repo = Path(args.repo).resolve()
    if detect_layout(repo) is None:
        print('%s: REPO_NOT_RESOLVED: нет package.json ни в корне (новая '
              'структура), ни в backend/ (старая)' % UNMEASURABLE)
        return 2
    try:
        manifest_entries(Tree(repo))
    except ManifestError as e:
        print('%s: %s: ожидание ledger не выводимо из манифеста миграций '
              'репозитория под проверкой (fail-closed, v4; константы нет)' % (
                  UNMEASURABLE, e.reason))
        return 2
    base_fired, base_blocked = subject_control(Tree(repo))
    facts = check_facts(repo)
    facts_red = {k for k, (v, _) in facts.items() if v is False}
    facts_none = {k for k, (v, _) in facts.items() if v is None}

    if args.case:
        res = run_case(repo, args.case, base_fired, facts_red)
        if 'error' in res:
            print('%s: EMPTY_SELECTION' % UNMEASURABLE)
            return 2
        out = {'case': res, 'base_fired': sorted(base_fired)}
        print(json.dumps(out, ensure_ascii=False, indent=1))
        if res['verdict'] == 'NOOP_MUTATION':
            print('%s: NOOP_MUTATION' % UNMEASURABLE)
            return 2
        if res['verdict'] not in ('REJECTED_EXACT', 'BLOCKED_BY_RED_CONTROL'):
            return 1
        if facts_none:  # К5: факт None ⇒ rc ≠ 0 (NEEDS_ENV, не зелёный)
            for k in sorted(facts_none):
                print('%s: NEEDS_ENV: %s' % (UNMEASURABLE, facts[k][1]))
            return 2
        return 0

    results = [run_case(repo, n, base_fired, facts_red) for n, _, _ in CASES]
    not_rejected = [r for r in results if r['verdict'] == 'NOT_REJECTED']
    noop = [r for r in results if r['verdict'] == 'NOOP_MUTATION']
    report = {
        'contract': '109',
        'repo': str(repo),
        'control_green': not base_fired and not facts_red and not facts_none,
        'control_red': sorted(base_fired),
        'control_blocked': sorted(base_blocked),
        'facts': {k: {'green': v, 'note': m} for k, (v, m) in facts.items()},
        'cases_total': len(CASES),
        'rejected_exact': sum(r['verdict'] == 'REJECTED_EXACT' for r in results),
        'blocked_by_red_control': sum(r['verdict'] == 'BLOCKED_BY_RED_CONTROL' for r in results),
        'not_rejected': len(not_rejected),
        'cases': results,
    }
    if args.out:
        outdir = Path(args.out)
        outdir.mkdir(parents=True, exist_ok=True)
        (outdir / 'raw.json').write_text(
            json.dumps(report, ensure_ascii=False, indent=1) + '\n', encoding='utf-8')
    if args.matrix:
        for r in results:
            print('%-28s -> %-24s depends=%s' % (
                r['name'], r['verdict'], ','.join(r.get('depends') or []) or '-'))
    else:
        print(json.dumps({k: v for k, v in report.items() if k != 'cases'},
                         ensure_ascii=False, indent=1))
        print('cases: %d (%d rejected_exact, %d blocked, %d not_rejected)' % (
            len(CASES), report['rejected_exact'], report['blocked_by_red_control'],
            len(not_rejected)))
    if noop:
        print('%s: NOOP_MUTATION: %s' % (UNMEASURABLE, ','.join(r['name'] for r in noop)))
        return 2
    if facts_none:
        for k in sorted(facts_none):
            print('NEEDS_ENV: %s: %s' % (k, facts[k][1]))
    if base_fired:
        print('109 RED: контроль красен: %s' % ','.join(sorted(base_fired)))
        return 1
    if facts_red or not_rejected:
        return 1
    if facts_none:  # К5: контроль не зелен, пока хоть один факт не измерен
        print('%s: NEEDS_ENV: факты не измерены: %s' % (
            UNMEASURABLE, ','.join(sorted(facts_none))))
        return 2
    return 0


if __name__ == '__main__':
    sys.exit(main())
