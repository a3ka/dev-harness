accept
OBJECT=ab7ee6797e831bd4276ffb894269346f9b490493
СУД: repo=dev-harness; предмет=175; фаза=контракт; роль=critic; вызов=2/2; модель-план=zai/glm-5.3; сессия=Crit175R2b; модель-факт=openai-codex/gpt-5.6-terra; SHA=ab7ee6797e831bd4276ffb894269346f9b490493; предыдущий=verdicts/critic/contracts-175-v1-krug1-fail.md; исключение=нет

# Вердикт критика — контракт 175 «табло станции без демонстрационных PR», исправительный вызов 2

## Предмет, независимость и граница повтора

OBJECT подтверждён в одноразовом SSH-клоне: `git rev-parse HEAD` дал `ab7ee6797e831bd4276ffb894269346f9b490493` (rc 0). Автор кандидата — `architect <architect@dev-harness.local>`; судья — отдельная сессия `Crit175R2b`, собственную работу не судит. План модели задания — `zai/glm-5.3`; фактическая модель `openai-codex/gpt-5.6-terra` является разрешённым `autoFallback` `@gpt-terra` для critic-tier `apex-sol` (`config/agent_models.json:59-62,94`).

Это scoped-повтор после `verdicts/critic/contracts-175-v1-krug1-fail.md`: дельта меняет именно форму модели угроз, канал ПРОВОДКИ и семантику/набор случаев `probe.py`. Поэтому проверены закрытие трёх прежних классов и зависимые последствия этой дельты; неизменённые поверхности не исследовались заново. `git diff --stat 5517790c..ab7ee6797` показал ровно два изменённых пути: контракт и `fixtures/workshop_project/tablo_demo_175/probe.py`, оба в `ЗОНА architect` (`contracts/175-tablo-bez-demo.md:46`).

Набор артефактов полон: закоммичены предмет и rc-критерии (`contracts/175-tablo-bez-demo.md:21-32`), названы исполнители и шесть ЗОНА-строк (`:46-51`), а класс риска указан и соответствует предмету (`:3-5`). Сверка `NABLIUDENIA.md:8323` подтверждает тот же существующий шов `ops/server/user/orch-tablo`; специфичные demo-PR измерены и названы в контракте (`:9-10`), противоречия не найдено.

## Закрытие блоков круга 1

1. Форма секции угроз исправлена: самостоятельные `ЗАЩИЩАЕТ:` и `НЕ ЗАЩИЩАЕТ:` с буллетами находятся в `contracts/175-tablo-bez-demo.md:34-39`. `check_threat_model.sh` теперь возвращает rc 0. Граница также предметно соответствует заявленному фильтру и остаточному риску: входы — branch/title/marker обоих репозиториев, а намеренно неразмеченное демо и недоступность API вынесены в НЕ ЗАЩИЩАЕТ.
2. ПРОВОДКА отделена от предпосылок заголовком `## Предпосылки` (`:120-127`) и использует существующий предметный role-канал. Дословная норма существует в `roles/orchestrator.md:302`; `check_provodka.sh` на контракте вернул rc 0.
3. Семь прежних мутаций теперь предъявлены исполнимо, а не чтением: `case_sensitive_branch`, `case_sensitive_title`, `title_mob_only`, `marker_mob_only`, `exclude_harness_red`, `combined_one_only` и `break_filter` все выданы как `caught` при `--stabs`. Новый оракул (`probe.py:21-151`) проверяет отдельные строки и итог на конформных входах, включая регистр, оба репозитория, составные признаки и список demo→рабочий. Помимо семи прежних, шесть базовых стабов также пойманы; `ZHIV` отсутствует.

## Выполненные прогоны

```text
$ bash scripts/pre_critic.sh contracts/175-tablo-bez-demo.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
  ok   гейт трека: 
КРИТИК: дверь зелёная
[rc=0]

$ bash scripts/pre_critic.sh --repo . contracts/175-tablo-bez-demo.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
  ok   гейт трека: 
КРИТИК: дверь зелёная
[rc=0]

$ bash scripts/check_precision_gate.sh . contracts/175-tablo-bez-demo.md
OK
[rc=0]

$ bash scripts/check_ceilings.sh
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 161 черновик(ов) судится, замороженные — по тегам
потолки в порядке
[rc=0]

$ bash scripts/check_threat_model.sh . contracts/175-tablo-bez-demo.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 1 буллет(ов), НЕ ЗАЩИЩАЕТ 1 буллет(ов))
[rc=0]

$ bash scripts/check_provodka.sh . contracts/175-tablo-bez-demo.md
[нет stdout/stderr]
[rc=0]

$ bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --repo .
175 demo_branch KRASNO rows=1 expected=0 rc=0
175 demo_title KRASNO rows=1 expected=0 rc=0
175 do_not_merge KRASNO rows=1 expected=0 rc=0
175 real_green ok rows=1 expected=1 rc=0
175 real_red ok rows=1 expected=1 rc=0
175 not_demo_word ok rows=1 expected=1 rc=0
175 harness_demo KRASNO rows=1 expected=0 rc=0
175 harness_real ok rows=1 expected=1 rc=0
175 upper_branch KRASNO rows=1 expected=0 rc=0
175 lower_title KRASNO rows=1 expected=0 rc=0
175 harness_title KRASNO rows=1 expected=0 rc=0
175 harness_marker KRASNO rows=1 expected=0 rc=0
175 harness_red ok rows=1 expected=1 rc=0
175 combined_demo KRASNO rows=1 expected=0 rc=0
175 multirow KRASNO rows=4 expected=2 rc=0
[rc=1 — ожидаемое красное состояние до реализации]

$ bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --model
175 demo_branch ok rows=0 expected=0 rc=0
175 demo_title ok rows=0 expected=0 rc=0
175 do_not_merge ok rows=0 expected=0 rc=0
175 real_green ok rows=1 expected=1 rc=0
175 real_red ok rows=1 expected=1 rc=0
175 not_demo_word ok rows=1 expected=1 rc=0
175 harness_demo ok rows=0 expected=0 rc=0
175 harness_real ok rows=1 expected=1 rc=0
175 upper_branch ok rows=0 expected=0 rc=0
175 lower_title ok rows=0 expected=0 rc=0
175 harness_title ok rows=0 expected=0 rc=0
175 harness_marker ok rows=0 expected=0 rc=0
175 harness_red ok rows=1 expected=1 rc=0
175 combined_demo ok rows=0 expected=0 rc=0
175 multirow ok rows=2 expected=2 rc=0
[rc=0]

$ bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --stabs
175 demo_branch ok rows=0 expected=0 rc=0
175 demo_title ok rows=0 expected=0 rc=0
175 do_not_merge ok rows=0 expected=0 rc=0
175 real_green ok rows=1 expected=1 rc=0
175 real_red ok rows=1 expected=1 rc=0
175 not_demo_word ok rows=1 expected=1 rc=0
175 harness_demo ok rows=0 expected=0 rc=0
175 harness_real ok rows=1 expected=1 rc=0
175 upper_branch ok rows=0 expected=0 rc=0
175 lower_title ok rows=0 expected=0 rc=0
175 harness_title ok rows=0 expected=0 rc=0
175 harness_marker ok rows=0 expected=0 rc=0
175 harness_red ok rows=1 expected=1 rc=0
175 combined_demo ok rows=0 expected=0 rc=0
175 multirow ok rows=2 expected=2 rc=0
175 demo_title KRASNO rows=1 expected=0 rc=0
175 STAB branch_only caught @ demo_title
175 demo_branch KRASNO rows=1 expected=0 rc=0
175 STAB title_only caught @ demo_branch
175 do_not_merge KRASNO rows=1 expected=0 rc=0
175 STAB marker_ignored caught @ do_not_merge
175 real_green KRASNO rows=0 expected=1 rc=0
175 STAB exclude_every_mob_pr caught @ real_green
175 real_red KRASNO rows=0 expected=1 rc=0
175 STAB exclude_red_ci caught @ real_red
175 not_demo_word KRASNO rows=0 expected=1 rc=0
175 STAB word_substring caught @ not_demo_word
175 upper_branch KRASNO rows=1 expected=0 rc=0
175 STAB case_sensitive_branch caught @ upper_branch
175 lower_title KRASNO rows=1 expected=0 rc=0
175 STAB case_sensitive_title caught @ lower_title
175 harness_title KRASNO rows=1 expected=0 rc=0
175 STAB title_mob_only caught @ harness_title
175 harness_marker KRASNO rows=1 expected=0 rc=0
175 STAB marker_mob_only caught @ harness_marker
175 harness_red KRASNO rows=0 expected=1 rc=0
175 STAB exclude_harness_red caught @ harness_red
175 combined_demo KRASNO rows=1 expected=0 rc=0
175 STAB combined_one_only caught @ combined_demo
175 multirow KRASNO rows=0 expected=2 rc=0
175 STAB break_filter caught @ multirow
[rc=0]
```

## Итог

Ни один из трёх блокирующих классов круга 1 не воспроизводится на OBJECT; новая семантика дельты доказана красной фазой, независимой честной моделью и всеми адресными стабами. Блокирующих находок по §Быстрый-процесс §Порог нет. `accept` разрешает заморозку этого неизменённого OBJECT.
