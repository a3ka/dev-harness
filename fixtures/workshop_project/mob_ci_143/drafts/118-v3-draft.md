# Черновик 118 v3 — проводка: H-checkout/CI-job → e2e-erstinformation; same-job Jest сохранён

Контракт 143 (mob-ci-razdelenie), адресная миграция проводки. База: `frozen/contracts/118/2` (текст в main байт-равен
тегу — сверено этой пачкой). Номер версии — по РЕАКТИСТРУ заморозок (фактический frozen-тег), не по заголовку
Markdown. Черновик НЕ является правкой frozen-текста: внедряется только после строки владельца
(все девять черновиков подписываются ОДНИМ разом после merge #124); `РАЗРЕШИЛ-ВЛАДЕЛЬЦ:` архитектор не пишет —
правило 11 (Н-59).

## Дифф относительно frozen (frozen/contracts/118/2)

```diff
--- frozen:118-erstinformation.md
+++ v+1:118-erstinformation.md
@@ -60,10 +60,10 @@
 - setting тег frozen/contracts/117/3 (миграция 117 v3 заморожена; команда проверки — раздел «Зависимость замороженного корня»); без него продуктовая приёмка блокирована.
 - setting CI Android emulator, Maestro, H-checkout, пробы 107/117, включая Г0 dark/light; новых secrets/variables/environments нет.
-- setting ленд данных 995 (fixtures/workshop_project/pilot_995/source.json, ТОЛЬКО session.expires_at — слово владельца 25.10, зона 995/владелец; дата-литерал батареи 2099-12-31T00:00:00Z — вопрос подтверждения владельца, арбитраж 118 v2 §Q4.4) и перепин H в .github/workflows/mobile.yml (оба checkout: quality и android-e2e) на ревизию с этими данными ДО продуктового зелёного; cmp-шаг frozen pilot.test.tsx+source.json требует равенства продукта и H.
+- setting ленд данных 995 (fixtures/workshop_project/pilot_995/source.json, ТОЛЬКО session.expires_at — слово владельца 25.10, зона 995/владелец; дата-литерал батареи 2099-12-31T00:00:00Z — вопрос подтверждения владельца, арбитраж 118 v2 §Q4.4) и перепин H в .github/workflows/mobile.yml (v3, 143: checkout quality и задача e2e-erstinformation; монолитного android-e2e больше нет) на ревизию с этими данными ДО продуктового зелёного; cmp-шаг frozen pilot.test.tsx+source.json требует равенства продукта и H.
 
 ## ПРОВОДКА
 ПРОВОДКА:
 - guard=fixtures/workshop_project/erstinformation_118/red_erstinformation_118.sh
-ПРОВОДКА-ЭНФОРСМЕНТ: CI --stabs до ленда 132, затем W; mob CI: production flow + отдельная интеграционная проба gate/admission + шаг `npm test -- --json --outputFile=` ДО checker'а с `--jest-otchet` (судья исполнения 13 клеток) + 123 + H-check + Г0 117.
+ПРОВОДКА-ЭНФОРСМЕНТ (v3, 143): CI --stabs до ленда 132, затем W; mob CI: экранная пачка исполняется задачей e2e-erstinformation: production flow + отдельная интеграционная проба gate/admission + шаг `npm test -- --json --outputFile=` ДО checker'а В ТОЙ ЖЕ задаче с `--jest-otchet` (судья исполнения 13 клеток) + 123 (H-checkout .harness118 и .harness123/scripts в задаче) + Г0 117 в quality.
 
 ## Модель угроз
```

## Изменяемая / сохраняемая норма / красное свидетельство

| Изменяемая норма | Сохраняемая норма | Красное свидетельство |
|---|---|---|
| именованные H-checkout/CI-job монолита → задача e2e-erstinformation (+ .harness123/scripts, скрытая зависимость) | экран, пачка, данные, expiry-клетки, same-job порядок Jest→checker, гейт миграции 117/3 — дословно | батарея 143 y14 (same-job Jest до checker), y15 (оба H-checkout в задаче) |

ОЖИДАЕТСЯ-СЛОВО-ВЛАДЕЛЬЦА: contracts/118-erstinformation.md v3 — экранная пачка 118 исполняется задачей e2e-erstinformation с её же H-checkout (.harness118 и .harness123/scripts) и same-job Jest-отчётом ДО checker (контракт 143 mob-ci-razdelenie); экран, данные, гейт миграции и порядок шагов не меняются.
