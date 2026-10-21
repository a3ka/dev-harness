FAIL
Ревьюер Rev121r2, контракт 121 (frozen/contracts/121/1), круг 2 scoped. OBJECT=501e369e827bd5e37000eb3fbff21f9eb80946ea (Complior-back PR#153, B=c525fd8d43ce3f243f8d92be72e1eedfe5375f22), батарея wip/121/architect @ f30b6b395c2681e4b6a53f9700317dc98bc3f7ed, 2026-10-21. Находки — `/tmp/dev-harness-verify/Rev121r2/review.md` (reslop, status: ready). Блокирует одна находка, R5.

Резюме. R1–R4 круга 1 закрыты по сути, каждый подтверждён своей мерой. Тесты теперь проверяют поведение и краснеют на 15 из 15 повреждений: на `bypass.sql`, на подмене guard и на 13 моих одиночных мутациях. Lane `postgres` на свежем PG18 даёт rc 0. Evidence стало записью прогона. Стандарты соблюдены. Блокирует строка приёмки 3: закоммиченная батарея на C даёт **rc 1** `evidence-deklaraciya: derevo`. Причина в том, что тесты ядра генерируют случайные UUID, которые попадают в текст SQL (`rls.test.js:101`) и в сообщения `UNBALANCED_JOURNAL` (`finance_journal.test.js:68,83`). Из-за этого честную запись дерева нельзя воспроизвести никаким прогоном. Это же нарушает `docs/CODING-STANDARDS.md` §10, стр. 122 («случайность — … с фиксированным значением в тесте»). Простая форма проходит: C с тремя постоянными UUID и перегенерированной записью (`var/v_det`) даёт **rc 0** на той же батарее.

## (а) Закрытие находок круга 1 — rc своих прогонов

| Находка | Своя мера | rc / результат |
|---|---|---|
| R1 тавтологии | `grep -E` 9 сигнатур пина по `tests/integration/core` | 0 совпадений (rc 1 grep) |
| R1 `bypass.sql` Rev121 | свежая БД → `run.js --through 004` → bypass.sql → `npm run -s test:core` | **rc 1**, tests 21 / pass 10 / fail 11; RUNTIME-запись не написана |
| R1 подмена `app.guard_immutable()` Adv121 | то же, `adv121_guard.sql` | **rc 1**, 21 / 16 / 5; запись не написана |
| R1 13 одиночных мутаций (`muts/*.sql`) | `fresh_core.sh` по одной на свежей БД | все **rc 1**: f_force 1 fail, f_bypassrls 3, f_immut_trig 3, f_journal_trig 1, guard_body 5, balance_body 2, using_true 2, grant_public 1, redaction_off 1, audit_erase 1, scope_access_true 2, outcome_body 1, audit_noctx 1; новых RUNTIME-записей 0 |
| R2 lane | свежий контейнер по digest (БД: postgres, template1, template0; ролей brokeros_* 0), `COMPLIOR_TEST_PG_ADMIN_URL=…/postgres python3 tests/tools/run_backend_ci.py --lane postgres` | **rc 0**: 6/6 PASS (манифест, sql-frozen, prepare, test:core, drop, test:integration 42.9 с) |
| R2 без предварительной миграции | `test:core` на пустой БД `r_empty` | **rc 0**, 21/21. Ядро применено в собственной БД, после прогона в `r_empty` схем app/control 0 |
| R3 запись | `cmp_ev.sh`: дерево против 2 свежих прогонов; ledger, run_key | sql 196 / errors 15, совпадение 195/196 и 13/15 (расхождение — случайные UUID, см. R5); `schema_migration.jsonl` 4 строки, sha = пин; run_key `77010476…f2d692b` = пин |
| R3 PGLITE | `sha256sum` источника, `grep` полей | `5561722…be81` совпал; `PostgreSQL 18.3 (PGlite 0.5.8)`, 17/17/0/80/3, роли api/gateway — не противоречит истории (неточность note — совет A6) |
| R4 | `fnlen.js` (acorn); `grep catch(()=>…)`; `npm run -s lint`; `npm run -s test:standards-lint` | 106 функций, max 41, >50: 0; swallow-catch 0; lint **rc 0**; standards-lint **rc 0** |
| FILES.sha256 | `sha256sum --quiet -c` | **rc 0**, 676 записей = 677 tracked − сам файл |

## (б) Оракул на продукте (батарея f30b6b39, копия `H` через `git archive`)

- `--model` → **rc 0**, «декоев отвергнуто ровно своими причинами: 24». Подсчёт своей мерой: `grep mut_` даёт 24, `.prichiny|length` 22, `.product.mutations.damage|length` 10, `.native_probes.probes` 18.
- `--repo co_B` → **rc 1** `testy-otsutstvuyut`.
- `--repo co_C` → **rc 1** `evidence-deklaraciya: derevo запись 20261021T074756Z.native` — **R5**.
- Диагностика: `Hdiag` отличается от H одной строкой — снята сверка записи дерева. На `co_C` он даёт **rc 0**, то есть остальные клетки C зелёные: 18 проб, lane на втором контейнере, свежая запись по журналу, 10 DAMAGE.
- Свидетель простой формы `var/v_det`: 3 постоянных UUID, запись перегенерирована своим `test:core`. Закоммиченная `H` на нём → **rc 0**.
- Мои мутации. Свойство ломается ПОСЛЕ зелёного `test:core` (тесты зелёные, ядро без свойства, `var/*` с `evil.js`), оракул H:
  - подмена guard → rc 1 `versii-ne-immutable: … update-document_version — не отклонена`;
  - USING(true) → rc 1 `rls-bez-force: … api-bez-konteksta «4|4»`;
  - GRANT PUBLIC → rc 1 `rls-bez-force: … public-app-tablica`;
  - пустое тело баланса → rc 1 `zhurnal-bez-balansa: … journal-unbalanced-commit`;
  - снятая redaction → rc 1 `evidence-sekrety: … audit-redakciya «2»`;
  - стирание аудита → rc 1 `audit-bez-konteksta: … audit-delete-runtime`;
  - BYPASSRLS → rc 1 `rls-bez-force: … api-bez-konteksta`.

  Пустое тело guard проверено и в DAMAGE (зелёный `Hdiag` прогнал DAMAGE `immutable_body`), и прямо в R1. Экспорт evidence константами с неисполненными строками (`v_ev_const`) → rc 1 `evidence-deklaraciya: svezhaya`. Константа-подмножество реальных операторов (`v_ev_const_det`) на `Hdiag` даёт rc 0 — это объявленная граница контракта, совет A1. В параллельном прогоне тот же вариант дал rc 1 `model-razbita` — совет A2.

## (в) Обязательная сверка «§Предмет РЕАЛИЗОВАН» на PG18

sha256 файлов `migrations/001–004` на B и на C совпадает с пином 4/4 (`git show <rev>:migrations/$f | sha256sum` против пина), `git diff --quiet c525fd8 OBJECT -- migrations app server` → rc 0. Строка 4а–в своей мерой (`row4abc.sh`): применение **rc 0**, ledger `4|1:001_core,2:002_rls,3:003_finance,4:004_runtime_role_fixes`; повтор **rc 0** «применено 0, в журнале 4», md5 ledger 54cf558b→54cf558b, отношений 242→242; копия с байтом в 003 → **rc 1** «SHA256 003_finance.sql не совпадает с манифестом», схем после отказа 0.

ПОВЕДЕНИЕМ на PG18 подтверждено (честные прогоны `test:core` зелёные, а каждая мутация из таблицы (а) краснит свой тест):
- UPDATE и DELETE `document_version`/`approval` отклоняются триггером (P0001), INSERT новой версии проходит;
- несбалансированный журнал и проводки одного знака падают на COMMIT `UNBALANCED_JOURNAL`, сбалансированный фиксируется;
- SUCCEEDED без receipt отклонён (`guard_outcome_evidence`);
- brokeros_api не видит чужой scope, чужой контекст обнуляет `has_scope_access`;
- PUBLIC доступа нет;
- изменение без админ-контекста → 42501 `ADMIN_AUDIT_CONTEXT_REQUIRED`, с контекстом пишется связная редактированная строка, runtime не может стереть аудит.

Независимо от тестов то же подтвердили 18 собственных проб оракула на C (зелёный прогон `Hdiag`).

## (г) Зоны

`git diff --name-only c525fd8..OBJECT` содержит 18 путей, все в ЗОНЕ implementer: `tests/integration/core/` ×8, `tests/helpers/pg18.js`, `docs/evidence/core/` ×4, `package.json`, `tests/tools/run_backend_ci.py`, `docs/VALIDATION.json`, `FILES.sha256`, `docs/VERSION_MANIFEST.json`.

ПЕРЕСЕЧЕНИЯ:
- в `package.json` добавлен только `test:core` (+1);
- в `run_backend_ci.py` добавлено 3 шага, чужие команды и лейны не тронуты;
- `pg18.js` расширен, из B удалена только строка `module.exports` (заменена расширенной);
- в `VALIDATION.json` добавлены только ключи yadro121.

`migrations/001–004` байт-в-байт совпадают с B.

## (д) Подгонка проверок под код

- Батарея: от freeze до f30b6b39 ровно один коммит автора architect. Контракт не тронут (`git diff --quiet frozen/contracts/121/1 f30b6b39 -- contracts/121-…` rc 0).
- Коммит батареи (07:56) моложе OBJECT (07:49), поэтому проверил, нет ли подгонки:
  - `grep` токенов, специфичных для продукта (`prepare_db`, `fixture.js`, `world.js`, `COMPLIOR_TEST_CORE_DB`, `pglite-baseline`, `yadro121_core`, `outcome`, имя записи) по оракулу и пину → 0;
  - батарея КРАСИТ C, то есть под C не подогнана.
- Продукт: тесты C не копия свидетеля архитектора V10. `diff` по каждому файлу даёт 200–270 изменённых строк из 123–198.
- Автор батареи не трогал продукт, автор продукта не трогал батарею: две ветки, два автора (`architect` / `implementer`).
- Требование «без случайных имён» (`Architect121r2/k2/msg_impl.txt`, mtime 08:02) появилось ПОСЛЕ OBJECT. R5 — новое требование батареи, implementer его ещё не видел. Нарушение стандарта §10, которое лежит в его корне, существовало и до этого.

## ПРОВОДКА (038)

`guard=fixtures/workshop_project/yadro_121/yadro_oracle.sh` существует и является барьером именно этого предмета: rc 0/1/2 по строкам 1–3 наблюдал выше. Продуктовая проводка подключена: `test:core` в lane postgres даёт rc 0 на свежем кластере.

## Паразитная сложность (050)

Таблица по каждому артефакту — в `review.md`. ACCIDENTAL нашёл два: `prepare_db.js` с env `COMPLIOR_TEST_CORE_DB` и тремя шагами lane (дубль `RUNNER`/`withDb`/`applyCore` из `pg18.js`), а также ключи `VALIDATION.json`/`VERSION_MANIFEST.json` без потребителя. Оба — советы: простую форму не прогонял.

## Чем закрыть

Закрыть R5: постоянные идентификаторы в `finance_journal.test.js:68,83` и `rls.test.js:101`, перегенерировать запись `docs/evidence/core/*.native` прогоном `test:core`, пересчитать `FILES.sha256`. Повторный суд на новом SHA: `bash <f30b6b39>/yadro_oracle.sh --repo C` должен дать rc 0 без снятых проверок.

## Гигиена

Мой контейнер `rev121r2-pg` и контейнер lane удалены. `yadro121-pg-*` моих прогонов оракул снял сам: после всех прогонов `docker ps` показывает только чужой `arch121r2-lane-freq`. Расходники удалены (`w_*`, `co_B`, 8 из 10 вариантов). Оставлены свидетели `var/v_det` и `var/v_ev_const_det`, журналы и скрипты. Push не делал. В основной чекаут харнесса ничего не писал (`PYTHONDONTWRITEBYTECODE=1`). Интеграцию вердикта в `verdicts/review/` делает Main, как и в круге 1.
