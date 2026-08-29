FAIL

# Исполнительный круг adversary 015 — HEAD 4a330e4

Судился только `scripts/drill_startup_digest.sh`, перенос пп. 1–5 решения
`verdicts/arbitration/contracts-015-orakul-drilla-v-pamjati.md`. До и после **каждого**
прогона ниже MD5-сторож живого `NABLIUDENIA.md` был одинаковым:
`35ccdd6086b421be5d2a1350e322d608`.

## Воспроизведённые три приёмки арбитра (/tmp)

В `/tmp/adv015exec-selector` — копия предмета; менялся только
`/tmp/adv015exec-selector/scripts/nabludenia_digest.sh`.

1. Реконструированный селектор: честен лишь при старом предсказуемом basename
   `real-ctrl-*`, иначе печатает `непушенных тегов: 0` и `статус: чисто`.

   ```sh
   cd /tmp/adv015exec-selector
   bash scripts/verify_antiplacebo.sh --scope drill_startup_digest
   ```

   rc=**1**, 0/12 положительных контролей: именованно
   `нет положительного контроля`. Это ожидаемое красное: новый `c.XXXXXXXXXX`
   не удовлетворяет селектору.

2. Уничтожитель после разбора `--root` выполняет `rm -rf -- "$root"` и печатает
   нули. Та же scoped-команда дала rc=**1**, 0/12 положительных контролей.
   Прямой прогон показал именованную причину: rc=**1**,
   `FAIL real: управляемый корень исчез после вызова субъекта`.

3. Честный `scripts/nabludenia_digest.sh` в этой же копии:

   ```sh
   cd /tmp/adv015exec-selector
   bash scripts/verify_antiplacebo.sh --scope drill_startup_digest
   ```

   rc=**0**, **12/12**; каждый fixture имел зелёный контроль и красный повтор.

Нейтрализация HEAD также поймана: стаб делает пустой commit в переданном `--root`.
Прямой прогон дал rc=**1** с `FAIL real: HEAD управляемого корня изменился`.
Отсутствующий инструмент (`nonexistent_digest_tool`, rc=127) также пойман прямым
прогоном: rc=**1**, `FAIL real: дайджест упал (rc=127)`.

## Блокер: правильные токены не в тех полях проходят

Построен бесмаркерный стаб, который для **любого** переданного git-root читает его
один локальный tag и untracked `duntracked-*` (это обычные входы дайджеста), но
выдаёт ложный отчёт `состояние дерева: чисто`. Требуемые токены он помещает только
в не-семантические строки:

```text
диагностика: непушенных тегов: 1; <tag>
архив ошибки: статус: аномалии; <dirty-file>
```

То есть стаб не печатает секцию дерева в контрактной форме и утверждает чистое
дерево; подстроки лишь процитированы как диагностика. Это не правило-8: ожидания
проверяющего не читаются с диска после вызова. Это не fingerprint: стаб не
различает и не принимает честно только специальную форму песочницы — его ложная
раскладка одинакова для каждого допустимого `--root`; tag/file он читает ровно как
предметный дайджест обязан читать свои входные данные.

```sh
cd /tmp/adv015exec-selector
bash scripts/drill_startup_digest.sh
bash scripts/verify_antiplacebo.sh --scope drill_startup_digest
```

Обе команды **прошли**: прямая rc=**0** (`ok real`), scoped rc=**0**, **12/12**.
Причина по коду: real-ветвь сверяет независимые подстроки `$out` (строки 182–205),
а не поля/секции вывода. В частности, count ищется первым regex-совпадением, а tag,
статус и файл — просто где угодно в `$out`. Поэтому мера принимает ответ на другой
вопрос. Это вход внутри заданных границ и проходящий при неверном поведении —
**блокер**.

## Живое дерево

Все команды дали rc=**0**, а MD5-сторож до/после каждой — указанный выше digest:

```sh
bash scripts/verify_antiplacebo.sh --scope check_nabludenia             # 12/12
bash scripts/verify_antiplacebo.sh --scope drill_gate_draft             # 7/7
bash scripts/verify_antiplacebo.sh --scope drill_startup_digest         # 12/12
bash scripts/verify_antiplacebo.sh --scope drill_nabludenia_nechitaemo  # 1/1

bash fixtures/check_nabludenia/probe_nabludenia_krasnoe.sh
bash fixtures/drill_gate_draft/probe_gate_draft_krasnyj.sh
bash fixtures/drill_startup_digest/probe_digest_krasnyj.sh
bash scripts/drill_nabludenia_nechitaemo.sh
bash fixtures/check_nabludenia/probe_migracija_adresov.sh

bash scripts/check_contract_frozen.sh  # 15 заморожено, 3 черновика
```

Зелёные живые проверки не снимают блокер: обманный вывод выше проходит и прямую
проверку, и полный scoped-набор 12/12.
