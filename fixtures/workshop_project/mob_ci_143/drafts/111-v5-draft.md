# Черновик 111 v5 — placement First-Run → задача e2e-first-run

Контракт 143 (mob-ci-razdelenie), адресная миграция проводки. База: `frozen/contracts/111/4` (текст в main байт-равен
тегу — сверено этой пачкой). Номер версии — по РЕАКТИСТРУ заморозок (фактический frozen-тег), не по заголовку
Markdown. Черновик НЕ является правкой frozen-текста: внедряется только после строки владельца
(все девять черновиков подписываются ОДНИМ разом после merge #124); `РАЗРЕШИЛ-ВЛАДЕЛЬЦ:` архитектор не пишет —
правило 11 (Н-59).

## Дифф относительно frozen (frozen/contracts/111/4)

```diff
--- frozen:111-cmp-mob-first-run.md
+++ v+1:111-cmp-mob-first-run.md
@@ -20,5 +20,5 @@
 обещание v4c «ПРИСУТСТВОВАТЬ = быть ВИДИМЫМ» снято как неисполнимое toJSON-пробой
 (замер 3 арбитража: шесть конформных мутаций вне перечня — все rc 0). Видимость строк
-НА ЭКРАНЕ судит сверка 123 в гейте 135 (шаг «135 first-run-ekran» job android-e2e:
+НА ЭКРАНЕ судит сверка 123 в гейте 135 (v5, 143: шаг «135 first-run-ekran» задачи e2e-first-run; транзитивно — под required-агрегатом android-e2e:
 элементы `podzagolovok`/`futer` манифеста `mobile/e2e-first-run/kadry.json`, порог
 0,600, без continue-on-error) — Модель угроз, критерий `gh pr checks`, §«Замер v4d».
@@ -320,5 +320,5 @@
   побайтово неизменны — их трогать нельзя, это зона 995).
 - Дано C в PR; `gh pr checks PR --repo a3ka/Complior-mob --required` → rc0, включая quality с
-  шагами 111 из H (обе пробы на disposable R) и android-e2e: Maestro start/rehearsal живы
+  шагами 111 из H (обе пробы на disposable R) и required-агрегатом android-e2e (выборка 143: e2e-pilot): Maestro start/rehearsal живы
   на новом First-Run (assertVisible first-run-continue, после нажатия — «Anmelden oder
   Konto erstellen»), и шаг «135 first-run-ekran» — гейт ВИДИМОСТИ строк макета НА
@@ -384,5 +384,5 @@
   строкой (copy-all-allowed: сокращённая форма саблайна) красят;
 - от невидимых строк макета (v4d, арбитраж 95f3b2c3): видимость подзаголовка/футера НА
-  ЭКРАНЕ судит механический rc-гейт продукта — шаг «135 first-run-ekran» job android-e2e
+  ЭКРАНЕ судит механический rc-гейт продукта — шаг «135 first-run-ekran» задачи e2e-first-run (143)
   (`gh pr checks --required`): валидатор 132 → сверка 123 по
   `mobile/e2e-first-run/kadry.json` — кадры «First-Run dark/light», элементы
```

## Изменяемая / сохраняемая норма / красное свидетельство

| Изменяемая норма | Сохраняемая норма | Красное свидетельство |
|---|---|---|
| placement-гейт: шаг 135 в монолитном android-e2e → задача e2e-first-run (+ транзитивная связь с required-агрегатом) | family/копия/порог/манифест kadry.json, пробы 111 в quality — дословно | батарея 143 y07/y17 (условие задачи, агрегат) |

ОЖИДАЕТСЯ-СЛОВО-ВЛАДЕЛЬЦА: contracts/111-cmp-mob-first-run.md v5 — placement-гейт видимости строк First-Run судится шагом «135 first-run-ekran» задачи e2e-first-run под required-агрегатом android-e2e (контракт 143 mob-ci-razdelenie); family, порог и пробы не меняются.
