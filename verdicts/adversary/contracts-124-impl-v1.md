FAIL

OBJECT=9cf50668def256303d77dbca42ccbe28b0f95374

Найден обход красной батареи 124: она принимает дверь, которая распознаёт
свой тестовый мир по переменной `P124_WORLD` и только в нём передаёт управление
честной модели. Вне этого мира стаб без проверок возвращает `push_product ОК` и
не выполняет push/PR. Это нарушает инварианты 1, 3, 5 и 6: rc 0 выдаётся без
пуша проверенного HEAD и без PR. `P124_WORLD` неизбежно передаётся батареей через
`run_door`, но ни t01–t26, ни С01–С30 не проверяют отсутствие такой развилки.

Воспроизведение (в одноразовом клоне):

```bash
RED124_DOOR=./adversary_bypass_124.sh \
  bash fixtures/workshop_project/push_produkta_124/red_124.sh
```

Стаб:

```bash
if [ -n "${P124_WORLD:-}" ]; then
  exec bash /tmp/dev-harness-verify/Adv124/fixtures/workshop_project/push_produkta_124/model/push_product.sh "$@"
fi
printf 'push_product ОК: a3ka/Complior-mob bypass 0000000000000000000000000000000000000000 PR https://github.com/a3ka/Complior-mob/pull/999 создан\n'
```

Результат: rc 0; `red_124: клеток 57, зелёных 57, красных 0`.
Отдельный внебатарейный запуск того же стаба с `P124_WORLD` удалённым дал rc 0,
строку ложного успеха и `remote-refs=` (пусто), то есть push не был сделан.

Позитивные контроли:

* Реализация OBJECT: `bash fixtures/workshop_project/push_produkta_124/red_124.sh` — rc 0, 57/57.
* Честная модель: `bash fixtures/workshop_project/push_produkta_124/red_124.sh --model` — rc 0, 57/57.

Дополнительно, вне основного обхода: diff `origin/main...OBJECT` добавляет в
`roles/orchestrator.md` шесть строк (заголовок, маркер и пустые строки плюс
норма), хотя frozen 124/1 ограничивает это пересечение одной норма-строкой.
Коммит OBJECT также не содержит `РАЗРЕШИЛ-ВЛАДЕЛЕЦ`; это отмечено в задании как
не предмет кода, но объём правки роли всё равно выходит за буквальную границу.

Использовались только локальные двойники; реальный GitHub, токены и push в origin
не вызывались.
