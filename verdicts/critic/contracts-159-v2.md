accept
СУД: repo=dev-harness; предмет=159; фаза=v+1 (v2); роль=critic; вызов=1/2; модель-план=openai-codex/gpt-5.6-terra; сессия=Crit159v2; модель-факт=openai-codex/gpt-5.6-terra; SHA=7aaac68594da6969fb553aa3843e9609d438a0d9; OBJECT=7aaac68594da6969fb553aa3843e9609d438a0d9; предыдущий=verdicts/critic/contracts-159-v1.md; исключение=нет

Кандидат — закоммиченный `7aaac68594da6969fb553aa3843e9609d438a0d9` ветки `wip/159/architect-r4`; его автор — `architect <architect@dev-harness.local>`. Фактические модели взяты из `/tmp/dev-harness-verify/orch/trace-critic-terra-0811.tsv`: critic `openai-codex/gpt-5.6-terra`, architect `openai-codex/gpt-6-sol`. Независимость установлена: судья не автор кандидата.

## Предмет и граница v+1

Сверен `git diff e549e42a9 origin/wip/159/architect-r4 -- contracts/`: изменён только `contracts/159-pustoj-produkt-krasnyj.md`, 9 вставок и 8 удалений. Дельта ровно снимает суффикс заголовка, приводит счёт к 51/18, называет защищённый минимальный набор п. 7 и явно описывает остаточный риск в `НЕ ЗАЩИЩАЕТ` (строки 40–50 и 165). Она не ослабляет именованные защищённые пути: собственная нить, `os.posix_spawn`, `os.system`, `fork+exec` и `subprocess.Popen` остаются обязательными для rc 1 и rc 2; прочие пути отделены как принятый владельцем остаточный риск. В прозе нет утверждения пары «стаб↔ветвь»: эта привязка остаётся в `probe.py`.

Полнота контракта сохранена: предмет и кодовый класс риска названы в строках 3–5; исполнимые критерии имеют rc-команды в строках 38–52; все исполнители и их зоны названы в строках 56–61; форма модели угроз с непустыми `ЗАЩИЩАЕТ`/`НЕ ЗАЩИЩАЕТ` присутствует в строках 140–165. Блокирующих находок нет.

## Выполненные проверки

```text
$ bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Crit159v2/clone contracts/159-pustoj-produkt-krasnyj.md
OK

$ bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Crit159v2/clone contracts/159-pustoj-produkt-krasnyj.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1
КРИТИК: дверь зелёная

$ bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Crit159v2/clone contracts/159-pustoj-produkt-krasnyj.md
OK

$ ls fixtures/workshop_project/pustoj_produkt_159/stabs/s*.py | wc -l
18

$ bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh --model
клеток 23, зелёных 23, красных 0; режим model

$ bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh --stabs
SVJAZI 18
клеток 23, зелёных 23, красных 0; режим stabs

$ bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh
клеток 51, зелёных 51, красных 0; режим derevo
```

Пять собственных одноразовых мутаций запускались через тот же `sudit_provodku` W-оракула на обоих обязательных входах; каждая порождала собственную клетку после честного отказа гейта. Сырой вывод:

```text
thread a-forma-pusta: POBOCHNYJ_EFFEKT; дерево прогона (baza) изменилось за время прогона; traces=1
thread d1-karta-nechitaema: POBOCHNYJ_EFFEKT; дерево прогона (baza) изменилось за время прогона; traces=1
posix_spawn a-forma-pusta: POBOCHNYJ_EFFEKT; дерево прогона (baza) изменилось за время прогона; traces=1
posix_spawn d1-karta-nechitaema: POBOCHNYJ_EFFEKT; дерево прогона (baza) изменилось за время прогона; traces=1
popen a-forma-pusta: POBOCHNYJ_EFFEKT; дерево прогона (baza) изменилось за время прогона; traces=1
popen d1-karta-nechitaema: POBOCHNYJ_EFFEKT; дерево прогона (baza) изменилось за время прогона; traces=1
fork_exec a-forma-pusta: POBOCHNYJ_EFFEKT; дерево прогона (baza) изменилось за время прогона; traces=1
fork_exec d1-karta-nechitaema: POBOCHNYJ_EFFEKT; дерево прогона (baza) изменилось за время прогона; traces=1
os_system a-forma-pusta: POBOCHNYJ_EFFEKT; дерево прогона (baza) изменилось за время прогона; traces=1
os_system d1-karta-nechitaema: POBOCHNYJ_EFFEKT; дерево прогона (baza) изменилось за время прогона; traces=1
```

Это закрывает проверяемое свойство п. 7 для перечисленного минимального набора: исполненная клетка не остаётся незамеченной независимо от итогового rc W. Одноразовые мутации и проверочный клон очищены от изменений до вынесения вердикта.
