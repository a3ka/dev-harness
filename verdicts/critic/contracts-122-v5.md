accept
OBJECT=ae1e592529e1d2a34cbca8055ea912233a33d21c
СУД: repo=dev-harness; предмет=122; фаза=контракт v5, один узкий вызов по слову владельца ~18:58 UTC; роль=critic; вызов=1/1; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit122V5c; модель-факт=openai-codex/gpt-6.1-terra (allowed, models_actual --bind); SHA=ae1e592529e1d2a34cbca8055ea912233a33d21c; предыдущий=accept Crit122V5b на 5bf840b09e; исключение=слово владельца на объединённую дельту 205 и зависимый регресс.

Область — изменённая семантика station дельты 205 и зависимый регресс К-01/К-09/К-10, не новый полный суд. Класс берётся из job.env до проверки run/env; станцию определяет только буквальное значение station. Общая сверка secrets/vars и синтаксический разбор предшествуют этому, working-directory с наследованием и realpath-границей проверяется независимо от класса. p11 содержит парные свидетельства local/station и негатив вычисляемого маркера; сохранность демонстрируют p11 и мутанты. Код диагностики исходного пути и сканер кавычек остались действующими; p9/p10 зелены, соответствующие мутанты красны. В прозе контракта пары конкретного стаба с конкретной ветвью не добавлены; привязки находятся в шапках кода стабов (Н-39). Алфавит не расширен, заглушек новых контекстов нет; jobs=0/station=N прямо обозначен структурной проверкой, не заменой required CI, §4(б) не расширен. Оба разрешения находятся в коммите изменения, начинаются с пути и причины, их адресная область указана; 11 изменённых файлов входят в зону architect, зоны не изменены.

## Карта классов

К-01: чисто — вход: contracts/122-ci-proekta.md:53–68 и шапки двух новых stabs, Н-39.
К-02: чисто — вход: задание Crit122V5c и consult205-report.md:126,132; только дельта 205.
К-03: чисто — вход: contracts/122-ci-proekta.md:114–116, слово владельца и сообщение коммита OBJECT.
К-04: чисто — вход: git diff --name-status a05247cdaa..OBJECT и contracts/122-ci-proekta.md:72–80.
К-05: чисто — вход: contracts/122-ci-proekta.md:56–68, приёмочные rc-команды дельты.
К-06: н/п — средовая ветвь без изменений с Crit122V5b.
К-07: чисто — bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model, rc 0, 74/74/0.
К-08: чисто — два стаба station и соседняя мутация условия классификации, rc 1; результаты ниже.
К-09: чисто — вход: p10-format-skobka-v-stroke в --model и stab_preflight_kavychki_vyrazhenij, rc 1, 73/1.
К-10: чисто — вход: p9-наследование и побег в --model, stab_preflight_ws_bez_granicy rc 1, 69/5.
К-11: чисто — вход: p11_par в red_ci_proekta_122.sh:866–917, один шаблон на каждую пару, независимые литералы ожиданий.
К-12: н/п — форматный оракул без изменений с Crit122V5b.
К-13: чисто — вход: p11-station-sekret/var и stab_preflight_sverka_tolko_run, rc 1, 67/7; проверяется объявленность, не секретные значения.
К-14: чисто — вход: p11 station/local и вычисляемый маркер; соседняя мутация и честные station-пары ниже.
К-15: чисто — вход: --model 74/74/0; мутанты дельты 72/2 и 69/5, регресс 62/12, 69/5, 66/8, 73/1 и 67/7.
К-16: чисто — вход: contracts/122-ci-proekta.md:109–116; структурная зелень и станционный NOT_RUN названы остатком.
К-17: н/п — бриф архитектуры 188 отсутствует, без изменений с Crit122V5b.

## Сырые результаты

Ниже выдержки фактического вывода полных запусков; показаны все клетки p11 у честной модели, отличающиеся клетки у двух новых стабов и итоги. `B=fixtures/workshop_project/ci_proekta_122`.

```text
$ bash $B/red_ci_proekta_122.sh --model
CASE p11-run-local-vyrazhenie: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ github.run_id }} ЗЕЛЁНАЯ
CASE p11-run-station-propusk: rc=0 want=0 причина=STATION-JOB: e2e-screen ЗЕЛЁНАЯ
CASE p11-env-local-vyrazhenie: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ github.sha }} ЗЕЛЁНАЯ
CASE p11-env-station-propusk: rc=0 want=0 причина=STATION-JOB: e2e-screen ЗЕЛЁНАЯ
CASE p11-station-sekret-ne-perechislen: rc=1 want=1 причина=sekrety-ne-perechisleny: PILOT_DEMO_CODE ЗЕЛЁНАЯ
CASE p11-station-var-ne-perechislena: rc=1 want=1 причина=sekrety-ne-perechisleny: NPM_TOKEN ЗЕЛЁНАЯ
CASE p11-station-yaml-nevaliden: rc=1 want=1 причина=yaml-nevaliden ЗЕЛЁНАЯ
CASE p11-station-wd-vne-kopii: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. ЗЕЛЁНАЯ
CASE p11-station-marker-ne-literal: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ github.run_id }} ЗЕЛЁНАЯ
ИТОГ 122 (model): клеток 74, зелёных 74, красных 0
rc=0

$ CI_PROEKTA_122_PREFLIGHT=$B/stabs/stab_preflight_stantsiya_ne_propuskaet.sh bash $B/red_ci_proekta_122.sh --model
CASE p11-run-station-propusk: rc=1 want=0 причина=STATION-JOB: e2e-screen КРАСНАЯ (rc 1 вместо 0; нет причины)
    | preflight ОТКАЗ: vyrazhenie-ne-podderzhano: ${{ github.run_id }}
CASE p11-env-station-propusk: rc=1 want=0 причина=STATION-JOB: e2e-screen КРАСНАЯ (rc 1 вместо 0; нет причины)
    | preflight ОТКАЗ: vyrazhenie-ne-podderzhano: ${{ github.sha }}
ИТОГ 122 (model): клеток 74, зелёных 72, красных 2
rc=1

$ CI_PROEKTA_122_PREFLIGHT=$B/stabs/stab_preflight_stantsiya_propuskaet_vse.sh bash $B/red_ci_proekta_122.sh --model
CASE p2-working-directory-otsutstvuet: rc=0 want=1 причина=working-directory-otsutstvuet КРАСНАЯ (rc 0 вместо 1; нет причины)
    | STATION-JOB: e2e
    | CIPREFLIGHT_OK jobs=1 station=1
CASE p5-station-sekret-ne-perechislen: rc=0 want=1 причина=sekrety-ne-perechisleny: PILOT_DEMO_CODE КРАСНАЯ (rc 0 вместо 1; нет причины)
    | STATION-JOB: android-e2e
    | CIPREFLIGHT_OK jobs=0 station=1
CASE p11-station-sekret-ne-perechislen: rc=0 want=1 причина=sekrety-ne-perechisleny: PILOT_DEMO_CODE КРАСНАЯ (rc 0 вместо 1; нет причины)
    | STATION-JOB: e2e-screen
    | CIPREFLIGHT_OK jobs=0 station=1
CASE p11-station-var-ne-perechislena: rc=0 want=1 причина=sekrety-ne-perechisleny: NPM_TOKEN КРАСНАЯ (rc 0 вместо 1; нет причины)
    | STATION-JOB: e2e-screen
    | CIPREFLIGHT_OK jobs=0 station=1
CASE p11-station-wd-vne-kopii: rc=0 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. КРАСНАЯ (rc 0 вместо 1; нет причины)
    | STATION-JOB: e2e-screen
    | CIPREFLIGHT_OK jobs=0 station=1
ИТОГ 122 (model): клеток 74, зелёных 69, красных 5
rc=1
```

Зависимый регресс, полные прогоны через `CI_PROEKTA_122_PREFLIGHT=$B/stabs/<имя> bash $B/red_ci_proekta_122.sh --model`, сырые итоговые строки:

```text
stab_preflight_bez_workspace.sh: ИТОГ 122 (model): клеток 74, зелёных 62, красных 12
stab_preflight_ws_bez_granicy.sh: ИТОГ 122 (model): клеток 74, зелёных 69, красных 5
stab_preflight_bez_otkaza_vyrazhenij.sh: ИТОГ 122 (model): клеток 74, зелёных 66, красных 8
stab_preflight_kavychki_vyrazhenij.sh: ИТОГ 122 (model): клеток 74, зелёных 73, красных 1
stab_preflight_sverka_tolko_run.sh: ИТОГ 122 (model): клеток 74, зелёных 67, красных 7
```

Каждый из пяти вернул rc 1. Остальные прежние стабы в этом узком вызове отдельно не перезапускались; новые двери и сдаточный лист не повторялись по заданию.

## Собственная соседняя мутация

В одноразовой обёртке `mutant-critic-122.sh` существующее условие `if cls not in ne_suditsya_run_env:` заменено на `if cls == 'local':`: любой иной маркер ошибочно получает пропуск. Исходный достижимый вход — поддерживаемый workflow с вычисляемым маркером p11; мутация меняет операцию классификации из дельты. Честная модель на этом входе отказывает как local, а пара с буквальной станцией проходит. Обёртка удалена после пробы.

```text
$ CI_PROEKTA_122_PREFLIGHT=mutant-critic-122.sh bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p11
CASE p11-run-local-vyrazhenie: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ github.run_id }} ЗЕЛЁНАЯ
CASE p11-run-station-propusk: rc=0 want=0 причина=STATION-JOB: e2e-screen ЗЕЛЁНАЯ
CASE p11-env-local-vyrazhenie: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ github.sha }} ЗЕЛЁНАЯ
CASE p11-env-station-propusk: rc=0 want=0 причина=STATION-JOB: e2e-screen ЗЕЛЁНАЯ
CASE p11-station-sekret-ne-perechislen: rc=1 want=1 причина=sekrety-ne-perechisleny: PILOT_DEMO_CODE ЗЕЛЁНАЯ
CASE p11-station-var-ne-perechislena: rc=1 want=1 причина=sekrety-ne-perechisleny: NPM_TOKEN ЗЕЛЁНАЯ
CASE p11-station-yaml-nevaliden: rc=1 want=1 причина=yaml-nevaliden ЗЕЛЁНАЯ
CASE p11-station-wd-vne-kopii: rc=1 want=1 причина=working-directory-vne-kopii: ${{ github.workspace }}/.. ЗЕЛЁНАЯ
CASE p11-station-marker-ne-literal: rc=1 want=1 причина=vyrazhenie-ne-podderzhano: ${{ github.run_id }} КРАСНАЯ (нет причины)
    | preflight ОТКАЗ: shag-upal: e2e-screen/ident
ИТОГ 122 (--cell p11): зелёных 8, красных 1
rc=1
```

## Развилки

Дельта не делает станционные джобы выполненными и не заменяет живой required CI; дальнейшая продуктовая разметка и станционные прогоны лежат вне этого суда.
