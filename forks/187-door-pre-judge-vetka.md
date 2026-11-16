ФОРК: 187-door-pre-judge-vetka
ВОПРОС: Как законно подготовить судью (pre_judge prepare) для ремонта двери 187а, если локальная ветка носителя штатного имени `wip/187/implementer` (tip eb136a26640f5aa7cc19991c300421076ba4682f) опубликована под ДРУГИМ удалённым именем `wip/187/implementer-door-1115` (по маршруту консультанта: удалённый носитель — новое имя через refspec, без force), а `origin/wip/187/implementer` существует со старым tip (f50aa6b58b, не предок)?
КЛАСС: инженерный
ПРИЗНАК: отказ штатной двери pre_judge (СТОП по условию консультанта «если land_agent/D9/pre_judge не принимают локальное имя при ином удалённом — СТОП и форк с сырым выводом»)
МАРШРУТ: консультант
ЗАВЕДЁН: 2026-11-15T14:50:00Z
АВТОР: anthropic/claude-sonnet-5-5
БЛОКИРУЕТ: да
ОТВЕЧЕНО: нет

СЫРОЙ ВЫВОД (rc 1): `bash scripts/pre_judge.sh prepare --repo /home/harness/dev-harness --branch wip/187/implementer --sostojanie /home/harness/.local/state/dev-harness-sessions/c907157c/zamok --timeout 30` →
«ОТКАЗ: VETKA_NE_OPUBLIKOVANA», следом строка «bash scripts/gitw push origin wip/187/implementer»; check_no_leak перед этим rc 0. Код отказа — по контракту 172 «origin/B отсутствует либо tip разошёлся с локальным»: origin/wip/187/implementer = f50aa6b58b72c6cc194253cc9b72494071cca7bf (старая история implementer 187), локальная wip/187/implementer = eb136a2664 (поверх 174c68f676 architect-door). Push `wip/187/implementer:refs/heads/wip/187/implementer` был бы не fast-forward (force запрещён).
Факты: PR #955 (head eb136a2664, удалённая ветка wip/187/implementer-door-1115) — CI run 43722128434 success, tyazhelyj-itog success. Мои проверки в WT: --repo CELLS=53 FAILURES=0; CI-шаг двери rc 0; arch_component_170 rc 0. D9 (OBJECT == tip ветки последнего рабочего START): START Impl187Door записан с branch wip/187/implementer, tip eb136a2664 — совпадает. Ревьюер: задание готово (/tmp/dev-harness-verify/rev187-door-task.txt, OBJECT=eb136a26640f5aa7cc19991c300421076ba4682f), не спавнено.
Варианты: (а) pre_judge/судейский спавн принимает remote-имя через явный параметр (нет такого в грамматике двери 172: argv замкнута, четыре формы); (б) переименовать локальную ветку носителя в имя удалённого `wip/187/implementer-door-1115` (если оно проходит VETKA_NE_FIT_AUTORA) — но START учтён с branch wip/187/implementer → D9 сверит tip ветки из START: потребуется решение по учёту (не правлю); (в) ротация старого origin/wip/187/implementer (архивирование/удаление удалённой ветки) — вне моих средств; (г) иной маршрут, по слову консультанта. Рекомендация: (б) если D9 читает tip по ИМЕНИ локальной ветки из START — не пройдёт; поэтому консультант решает (в) либо уточняет дверь. До ответа судья 187 НЕ спавнится, merge/ленд не делаются.
