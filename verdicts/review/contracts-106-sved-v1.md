FAIL
OBJECT=f3a433298782edf1bfc05956f594fda947695774

Reviewer: Rev106s · 2026-10-19 · сведение ветки 106 с origin/main 4542e4e · находки: review.md (status: ready)

Блокер:
- F1 (заявленное ≠ сделанному + семантический конфликт сведения): `python tools/run_backend_ci.py --local` → RC=1,
  lane backend: `npm --prefix backend test` RC=1, http.test.js:154 `428 !== 200` (`PRECONDITION_REQUIRED, нужен If-Match`).
  5.8.4 (106) добавил If-Match/x-cas-semantics к acknowledgeDisclosure; f3a4332 пересобрал backend/app/contracts под 5.8.4;
  тест бэкенда из main шлёт команду без If-Match. 4542e4e: 63/0 rc 0; 4def36e: 62/1; f3a4332: 62/1.
  ОБХОД: консультант расширяет область сведения на backend/tests/contract/http.test.js (или обработчик) → повтор полного
  прогона, rc 0 на новом SHA.

Не блокируют: F2 (совет — устаревшие тексты «неблокирующий режим до 5.8.4» в run_backend_ci.py; hunk 106 отброшен
без функциональной потери), F3 (наблюдение — 4 удалённых evidence/ux175/<ts> отслеживались в origin/main, это не хвосты прогонов).

Подтверждено своей мерой: область п.1 (backend/ci.yml/run_backend_ci = main байт-в-байт, кроме регенерации backend contract;
106-файлы = 36d101a), lane @contract-validator и три замка #147 на месте, known-failures пуст и проходит «база ⊆ origin/main (57 ID)»,
расширение базы → rc 1, sha256sum -c RC=0 (615), generate_derived no-op, валидатор rc 0 PASS_STATIC failures=[],
j2 probe.py 2b7eac14… RC=0 27/27, m3/m4/m5 → validator rc 1 + lane rc 1 «НОВЫЙ отказ» с именованными причинами.
