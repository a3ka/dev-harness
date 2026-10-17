ФОРК: n-993-zona-generatora-za-predelami-4
ВОПРОС: docs/owner/2026-10-17-resheniya-back-992-993.md §4 разрешает контракту 993
ровно семь путей (`tests/validate_contract_v3_9.py`, `contracts/`,
`tools/generate_derived.py`, `evidence/contracts/`, `README_RU.md`,
`VALIDATION.json`, `FILES.sha256`). Живая проверка architect993
(`/tmp/dev-harness-verify/architect993-cback`, HEAD `842f4e99d`) показала: честная
поставка по DECISIONS-121.md §6.2–6.3 требует ТАКЖЕ:
- `VERSION_MANIFEST.json` (re-freeze VS01 под новый example — владелец уже разрешил
  erratum в §3а, но путь физически вне семи перечисленных);
- `tools/validate_alignment_11782_31422.py` (`:23,36,45-54,86` — закрепляет версию
  5.8.2 и source-hash константы, требует синхронной правки при bump 5.8.2→5.8.3);
- побочные производные генератора `tools/generate_derived.py`, НЕ входящие в семь
  путей: `data/client-field-decisions-v3_10.json`, `tests/acceptance-ux1175.json`,
  `server/mock-5_8.json` (сам генератор уже в зоне, но он ПИШЕТ эти файлы — без
  допуска на них `generate_derived.py` отказывает либо правка остаётся частичной).

Без расширения зоны честная поставка 5.8.3 (не формальная, а реально зелёный
`validate_contract_v3_9.py` + согласованные производные) недостижима в рамках §4.
Architect993 остановился на этой границе, зафиксировал PARTIAL_BLOCKED, НЕ
расширил зону молча (commit `0477b8586`, `contracts/993-cmp-bck-121-validator-5-8-3.md`
§Незаполненные требования несёт те же три пункта).

КЛАСС: дизайн
ПРИЗНАК: кросс-репо
МАРШРУТ: со-ревью

ЗАВЕДЁН: 2026-10-17T14:45:00Z
АВТОР: orchestrator (anthropic/claude-sonnet-5)
ВЫЗВАН: architect (openai-codex/gpt-6-astra), коммит 0477b8586

БЛОКИРУЕТ: да — без решения владельца о расширении §4 критик 993 либо примет контракт
с формально признанным, но нереализуемым до конца минимумом (зона остаётся семью
путями, реализация ограничена ими, честный `FAIL_STATIC` на полном комплекте
сохраняется задокументированным пределом), либо implementer получит задание сверх
§4 без разрешения владельца — оба исхода хуже явного вопроса.

ОТВЕЧЕНО: да — docs/owner/2026-10-17-resheniya-1810.md §3 (слово владельца 2026-10-17
~18:10, рекомендованный текст со-ревью консультанта verdicts/consultant/n-993-zona-
generatora-za-predelami-4-soreview-v1.md дословно + доп. путь tools/verify_handoff.py)
