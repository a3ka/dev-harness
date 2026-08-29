FAIL

Судился живой HEAD `9a6497f` и фикс `269e76d..9a6497f`. Предмет и проверки не менялись. Все обманные субъекты жили только в `/tmp`; live-tree MD5-сторож `NABLIUDENIA.md` до и после **каждого** прогона ниже: `35ccdd6086b421be5d2a1350e322d608`.

## 1. Находка круга 2 закрыта

В `/tmp/adv015c-hybrid` подложен бесмаркерный гибрид `scripts/nabludenia_digest.sh`: он честно сообщает открытую запись (либо `открытых: 0`), но безусловно печатает `непушенных тегов: 0` и `статус: чисто`. На новом HEAD:

```sh
cd /tmp/adv015c-hybrid
bash scripts/verify_antiplacebo.sh --scope drill_startup_digest
```

дал **rc=1**: все 12 fixture получили «нет положительного контроля». Это ожидаемое красное: новая real-ветвь строит git-root с непушенным тегом и грязным файлом, а гибрид не называет ни тег, ни аномалию статуса. Прежняя бесмаркерная ложь кругa 2 больше не проходит.

## 2. Новые обходы: FAIL

### 2.1 Субъект честен только на имени управляемого корня

В `/tmp/adv015c-selector` подложен бесмаркерный digest. Он распознаёт basename `real-ctrl-<pid>` и только для него печатает ровно требуемые real-ветвью:

```text
открытых: 0
непушенных тегов: 1
  drill-real-<pid>
статус: аномалии
  ?? drill-untracked-<pid>.txt
```

На **любом другом** `--root` он лжёт `непушенных тегов: 0` и `статус: чисто`. В его тексте нет маркера fixture; строка `# ГРАММАТИКА:` сохранена, чтобы не подменять предмет грамматической fixture. Команда:

```sh
cd /tmp/adv015c-selector
bash scripts/verify_antiplacebo.sh --scope drill_startup_digest
```

дала **rc=0, 12/12**. Следовательно, дрилл проверяет только предсказуемый `real-ctrl-$$` и не доказывает контракт digest для другого допустимого `--root`. Это обход проверки, а не реализация контракта.

### 2.2 Субъект уничтожает управляемый корень до сверки

В `/tmp/adv015c-destroy` подложен бесмаркерный digest, который после разбора `--root` выполняет:

```sh
rm -rf -- "$root"
printf 'открытых: 0\n'
```

и завершается `0`. Команда:

```sh
cd /tmp/adv015c-destroy
bash scripts/verify_antiplacebo.sh --scope drill_startup_digest
```

дала **rc=0, 12/12**. Причина измерена по коду: после вызова digest real-ветвь вычисляет `remote_tags`, `unpushed_n` и `status_short`; удалённый `$CTRLR` превращает локальные git-вызовы в пустой результат, поэтому условия проверки тегов и статуса отключаются. Сверка «открытых: 0» остаётся выполнимой. Дрилл не сохраняет и не сверяет управляемое состояние до вызова субъекта и не требует, чтобы `$CTRLR` всё ещё был git-root.

Требуемая правка за автором: создать непредсказуемый управляемый путь вне пространства, доступного для подмены по basename, либо предъявить минимум два независимо сформированных корня; до запуска digest снять в памяти ожидаемые `tag/status` и после запуска fail-closed проверить существование, git-идентичность и неизменность контролируемого root. Нельзя гасить условия тегов/статуса при ошибке чтения контролируемого root.

## 3. Позитивный контроль и живое дерево

Сам живой subject прошёл scoped-предъявления, каждый с MD5-сторожем до/после:

- `bash scripts/verify_antiplacebo.sh --scope check_nabludenia` — **rc=0, 12/12**;
- `bash scripts/verify_antiplacebo.sh --scope drill_gate_draft` — **rc=0, 7/7**;
- `bash scripts/verify_antiplacebo.sh --scope drill_startup_digest` — **rc=0, 12/12**;
- `bash scripts/verify_antiplacebo.sh --scope drill_nabludenia_nechitaemo` — **rc=0, 1/1**.

Пять отдельных проб также дали **rc=0** при неизменном MD5:

```sh
bash fixtures/check_nabludenia/probe_nabludenia_krasnoe.sh
bash fixtures/drill_gate_draft/probe_gate_draft_krasnyj.sh
bash fixtures/drill_startup_digest/probe_digest_krasnyj.sh
bash scripts/drill_nabludenia_nechitaemo.sh
bash fixtures/check_nabludenia/probe_migracija_adresov.sh
```

`bash scripts/check_contract_frozen.sh` дал **rc=0**: 15 заморожено, 3 черновика. Живое дерево зелёное, но два бесмаркерных кандидата выше прошли scoped 12/12; поэтому acceptance проверки не достигнут.
