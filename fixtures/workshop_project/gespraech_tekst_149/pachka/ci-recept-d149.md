# Рецепт диагностического PR экрана 149 (gespraech-tekst) — по лекалу 143 v2

Поднимает ОРКЕСТРАТОР (scripts/push_product.sh) по sha кандидата; эта
пачка готовит рецепт: три парные правки ОДНОГО PR продукта (И-14/И-12
frozen 143/2), БЕЗ правки перечней/тела механизма 143.

## 1. Запись карты `mobile/ci-screens.json` (ekrany[])

```json
{
 "id": "gespraech-tekst",
 "kontrakty": ["149"],
 "status": "in-development",
 "job": "e2e-gespraech-tekst",
 "pack": "mobile/e2e-gespraech-tekst/",
 "flows": [
  "mobile/.maestro/gespraech-tekst.yaml",
  "mobile/.maestro/gespraech-tekst-393.yaml"
 ],
 "child_flows": [
  "mobile/.maestro/gespraech-tekst-prokhod.yaml"
 ],
 "puti": [
  "mobile/src/features/conversation/",
  "mobile/src/ui/conversation-composer/",
  "mobile/src/mocks/",
  "mobile/e2e-gespraech-tekst/"
 ],
 "h_checkout": [".harness149"],
 "output_namespace": "mobile/maestro-out-gespraech-tekst"
}
```

Статус `approved` — только по принятой поставке (И-1 143 v2). Корневые
флоу — два профильных; проход проходимости — child_flow (владение
выборочных режимов — карта, v2c/v2d 143 v2).

## 2. Инстанциация лекала `screen-job.template.yml` (frozen 143/2)

- `{{JOB_ID}}` = `e2e-gespraech-tekst`
- `{{SCREEN_ID}}` = `gespraech-tekst`
- `{{PACK}}` = `mobile/e2e-gespraech-tekst/`
- `{{FLOWS}}` = `gespraech-tekst,gespraech-tekst-393`
- `{{H_REF}}` = <sha принятого пина харнесса с реализацией 149 — ставит
  оркестратор на freeze `frozen/contracts/149/1`; плавающая ссылка на
  main недопустима>
- `{{H_PATH}}` = `.harness149`
- `{{AVD_PORT}}` = `5580` (5560 занят интеграцией, 5570 — vkladki 148)
- `{{EVIDENCE_NS}}` = `mobile/maestro-out-gespraech-tekst`

Второй эмулятор профиля 393 — тот же работник (e2e.sh читает
GESPRAECH_TEKST_SERIAL и GESPRAECH_TEKST_SERIAL_393; второй AVD внутри
работника, прецедент шаблона 132 v2).

## 3. Парные правки того же PR (И-12 143 v2)

1. `select-screens`: новый output `e2e-gespraech-tekst` + каноническое
   условие выбора работника.
2. needs PR-агрегата `android-e2e` += `e2e-gespraech-tekst`.
3. needs ночного `mobile-regression-signal` += `e2e-gespraech-tekst`.

## Что НЕ меняется в этом PR

Перечни/код селектора/агрегата/quality, тела legacy-работников,
H-пины чужих экранов, `screen-job.template.yml` (его пин правит только
подписанная дельта 143 v+1). Никаких пустых job будущих экранов.

## Живые гейты до заморозки 149 (норма 146+, слово владельца 29.10)

1. `quality` (jest/tsc/999/structure/lint) на sha кандидата — зелёный.
2. Шаг валидатора v3 на пачке: `python3 .harness149/scripts/
   ekran_shablon.py --pack mobile/e2e-gespraech-tekst --repo .
   --harness .harness149` — rc 0.
3. Шаг канона jest в среде продукта: `node mobile/e2e-gespraech-tekst/
   dvizhenie.mjs --json --outputFile mobile/e2e-gespraech-tekst/
   jest-otchet.json gespraech` — rc 0, отчёт свеж и полон.
4. Инвентаризация пачки `--mode inventar` называет
   `mobile/e2e-gespraech-tekst/` (вынос общего шага quality; личный mv
   не нужен).
