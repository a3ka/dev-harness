ФОРК: 175-uzkij-kritik-ispravitelnyj
ВОПРОС: разрешить ОДИН узкий исправительный вызов critic по 175 v2 сверх бюджета (ADR docs/owner/adr/2026-11-17-uzkij-kritik-konsultant-sessii.md, правило 1): прошлый вердикт Crit175V2 — FAIL (3 блока), architect предъявил дельта-лист, закрывающий именно их?
КЛАСС: инженерный
ПРИЗНАК: слово владельца №42 (вызов Crit175V2) исполнено и дало FAIL; вызовов по предмету сверх базового: 1 (Crit175V2); по правилу 1 допустимо не более двух
МАРШРУТ: консультант
ЗАВЕДЁН: 2026-11-17T22:20:00Z
АВТОР: anthropic/claude-sonnet-5-5
БЛОКИРУЕТ: freeze 175 v2 (табло — слот табло)
ОТВЕЧЕНО: снято — санкция Cons1117 исполнена: Crit175V3 accept на af88158f1016274ac1cfb4ff9e61f9781d2efd58, опубликована frozen/contracts/175/2; новый critic для этого запроса не нужен, консультант ConsBatch1118, модель openai-codex/gpt-6.1-sol.

ФАКТЫ (дерево, не память; все ссылки проверяемы):
- Прошлый вердикт: `wip/175/critic-v2` `b161a130` (клон `/tmp/dev-harness-verify/Crit175V2/repo`; материализован в PR #1071 как `verdicts/critic/contracts-175-v2-krug1-fail.md`), OBJECT `2cb947a978abb025880b3ecdb8486d1340eb60f3`: блоки (1) батарея не различает прямые и вложенные журналы (удаление любого glob проходит 22/22); (2) строгая граница свежести вместо включительной проходит 22/22; (3) батарея отвергает корректный поиск журналов прямым glob полного пути.
- Дельта-лист: `Arch175Fix1` коммит `138dfe0944` (поверх `2cb947a978`; свёрнуты в ОДИН коммит `af88158f10` с той же строкой РАЗРЕШИЛ «175 v+1 — да» в теле, дерево `^{tree}` идентично) — файлы ТОЛЬКО `contracts/175-tablo-bez-demo.md` и `fixtures/workshop_project/tablo_demo_175/{model.py,probe.py,red_tablo_demo_175.sh}` (зона architect 175); блок 1: миры mob_tolko_prjamoj_zhurnal / mob_tolko_vlozhennyj_zhurnal + стабы по коду tolko_prjamoj_glob / tolko_vlozhennyj_glob; блок 2: замороженные часы, миры mob_granica_okna (ровно 1200 с → ведущий есть) / mob_za_granicej_okna (1201 с), стабы strogaja_granica / okno_shire; блок 3: честные контроли honest_v2_fullpath / honest_v2_find / honest_v2_walk, фикстуры равноправны. Прогоны architect: голый rc 1 (5 красных до реализации / 21 зелёных), `--model` rc 0 26/26 + контроли 4 форм, `--stabs` rc 0 26 стабов 0 живых; соседи 139/995/085 fast rc 0; гейты pre_critic/spec_ready/precision/threat/ceilings/charter rc 0.
- Дельта узкая: проверка — только текст контракта и батарея предмета; продуктового кода 175 (`ops/server/user/orch-tablo`) не затронуто.
РЕКОМЕНДАЦИЯ: разрешить один узкий исправительный вызов critic на OBJECT `af88158f1016274ac1cfb4ff9e61f9781d2efd58` — только закрытие трёх блоков Crit175V2 и зависимый регресс; новых полных кругов нет; freeze — только после accept.
ОСНОВАНИЕ-ДЕРЕВО: `git show af88158f10 --stat`; `git -C /tmp/dev-harness-verify/Crit175V2/repo show b161a130:verdicts/critic/contracts-175-v2-krug1-fail.md`; ветка `wip/175/architect` (локальная; не опубликована до санкции).
