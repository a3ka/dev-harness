FAIL
OBJECT=c978eeaec8cc25952dcc097d8572024241dc7fd5
СУД: repo=dev-harness; предмет=141; фаза=контракт; роль=critic-sol; вызов=1/2; модель-план=openai-codex/gpt-6-sol; сессия=Critic141; модель-факт=openai-codex/gpt-6-sol; SHA=c978eeaec8cc25952dcc097d8572024241dc7fd5; предыдущий=нет; исключение=нет
Независимость: автор Architect141 — zai/glm-5.3 (трасса в задании); судья Critic141 — openai-codex/gpt-6-sol (фактическая модель окружения). Предмет судился в SSH-клоне на указанном OBJECT, контракт не редактировался. По первому доказанному блокеру исследование остановлено: неисполненным проверкам результата не приписываю.

## Блокирует

БЛОКИРУЕТ contracts/141-obryv-adb-diagnostika.md:31 — критерий `:36`, `:54` и утверждение защиты от зелени без реализации `:159`, скрытых ветвей `:167` судят только строковое тело `run:` и игнорируют управляющие свойства *самого целевого шага* GitHub Actions. Класс причины: несовпадение исполняемого шага с извлечённым фрагментом; метаданные шага не входят ни в канон, ни в replay. Это не чужой шаг: `if:` принадлежит именно `135 first-run-ekran`, а допустимый по §Демаркация субъект — YAML с тремя названными шагами.
ОБХОД: оставить `run:` всех трёх целевых шагов байт-в-байт моделью и добавить `if: ${{ false }}` к шагу `135 first-run-ekran`. Батарея `W --repo /tmp/dev-harness-verify/Critic141/attack-if-false` вернула rc 0, все 35 CASE ok; в реальном GH Actions этот шаг никогда не выполняется: нет ни диагностики adb, ни повтора, ни валидатора, ни красного итога первого обрыва. То же семейство затрагивает `continue-on-error: true`, `shell:` и иные свойства управляющей оболочки; их отдельно не прогонял. Свидетель оставлен в `attack-if-false/.github/workflows/mobile.yml`, генератор — `attack_step_metadata.py`, обе вещи только вне основного дерева.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: красная приёмка проверяет исполняемость и сохранение красного результата *каждого* из трёх выбранных шагов с учётом их управляющих свойств (например, обманное `if: false` обязано краснеть), не пиня байты всего mobile.yml; красные тесты на такую мутацию — до заморозки. Ограничение diff исполнителя до трёх тел не заменяет проверки фактического субъекта: он может получить неверные управляющие свойства после merge ветки-основы, а зелёный `W --repo` всё равно удостоверит неисполняемый `run:`.

## Проведённые измерения и сырые выводы

Рабочая копия: `git clone ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/Critic141/repo` → rc 0, `Cloning into '/tmp/dev-harness-verify/Critic141/repo'...`; `git checkout -q c978eeaec8cc25952dcc097d8572024241dc7fd5` → rc 0, вывод пуст.

Во всех следующих вызовах `W` — `bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh`; cwd `/tmp/dev-harness-verify/Critic141/repo`; запускаются через `env -i PATH=/home/harness/.local/bin:/usr/bin:/bin`, без omp/сети.

- `env -i PATH=/home/harness/.local/bin:/usr/bin:/bin W` (развёрнуто полным путём скрипта) → rc 1. Первая строка `SUBJECT_ABSENT: нет субъекта .github/workflows/mobile.yml; зелень без субъекта невозможна`; далее ровно 35 строк `CASE <имя> KRASNO (SUBJECT_ABSENT)`, от `CASE 135-oflin-povtor-spas KRASNO (SUBJECT_ABSENT)` до `CASE derevo-shag-net KRASNO (SUBJECT_ABSENT)`.
- `env -i PATH=/home/harness/.local/bin:/usr/bin:/bin W --model` → rc 0, ровно 35 строк `CASE <имя> ok`, от `CASE 135-oflin-povtor-spas ok` до `CASE derevo-shag-net ok`.
- `env -i PATH=/home/harness/.local/bin:/usr/bin:/bin W --stabs` → rc 0. Сырой вывод атаки (35 контрольных + 41 красная связь, 27 разных стабов):

```text
CASE 135-oflin-povtor-spas ok
CASE 135-adb-notfound ok
CASE 135-serial-notfound ok
CASE 135-devserverdied-povtor-krasen ok
CASE 135-chistyj-proval ok
CASE 135-zelenyj ok
CASE 135-boot-ne-zagruzilsja ok
CASE 135-stabil-nedostizhima ok
CASE 135-emulator-log-hvost ok
CASE 135-install-failed-bez-povtora ok
CASE 135-pustoj-maestro-out ok
CASE 118-oflin-povtor-spas ok
CASE 118-devserverdied-povtor-spas ok
CASE 118-povtor-tozhe-krasen ok
CASE 118-chistyj-proval ok
CASE 118-zelenyj ok
CASE 118-boot-ne-zagruzilsja ok
CASE 118-stabil-nedostizhima ok
CASE 118-emulator-log-hvost ok
CASE 995-diag-signatura ok
CASE 995-chistyj-proval ok
CASE 995-zelenyj ok
CASE struktura-shag135 ok
CASE struktura-shag118 ok
CASE struktura-shag995 ok
CASE struktura-pereformat135 ok
CASE struktura-pereformat118 ok
CASE struktura-pereformat995 ok
CASE struktura-signatura135 ok
CASE struktura-signatura118 ok
CASE struktura-signatura995 ok
CASE struktura-vyrazhenija ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-shag-net ok
STAB s-995-adb-glotnuto 995-diag-signatura KRASEN
STAB s-995-adb-glotnuto 995-chistyj-proval KRASEN
STAB s-995-bez-diag 995-diag-signatura KRASEN
STAB s-995-bez-diag 995-chistyj-proval KRASEN
STAB s-995-shagovoj-povtor 995-diag-signatura KRASEN
STAB s-adb-glotnuto-135 135-oflin-povtor-spas KRASEN
STAB s-adb-glotnuto-135 135-emulator-log-hvost KRASEN
STAB s-adb-glotnuto-135 135-devserverdied-povtor-krasen KRASEN
STAB s-bez-diag-118 118-chistyj-proval KRASEN
STAB s-bez-diag-118 118-oflin-povtor-spas KRASEN
STAB s-bez-diag-118 118-devserverdied-povtor-spas KRASEN
STAB s-bez-diag-135 135-chistyj-proval KRASEN
STAB s-bez-diag-135 135-oflin-povtor-spas KRASEN
STAB s-bez-diag-135 135-adb-notfound KRASEN
STAB s-bez-diag-135 135-serial-notfound KRASEN
STAB s-bez-diag-135 135-devserverdied-povtor-krasen KRASEN
STAB s-bez-itoga-stabil-118 118-stabil-nedostizhima KRASEN
STAB s-bez-itoga-stabil-135 135-stabil-nedostizhima KRASEN
STAB s-bez-povtora-118 118-oflin-povtor-spas KRASEN
STAB s-bez-povtora-118 118-devserverdied-povtor-spas KRASEN
STAB s-bez-signaturnogo-filtra-135 135-install-failed-bez-povtora KRASEN
STAB s-boot-bez-diag-135 135-boot-ne-zagruzilsja KRASEN
STAB s-diag-zaglushen-135 135-oflin-povtor-spas KRASEN
STAB s-diag-zaglushen-135 135-devserverdied-povtor-krasen KRASEN
STAB s-dva-povtora-118 118-povtor-tozhe-krasen KRASEN
STAB s-dva-povtora-135 135-devserverdied-povtor-krasen KRASEN
STAB s-emulator-log-uterjan-135 135-emulator-log-hvost KRASEN
STAB s-kanon-stroka-118 struktura-shag118 KRASEN
STAB s-kanon-stroka-135 struktura-shag135 KRASEN
STAB s-kanon-stroka-995 struktura-shag995 KRASEN
STAB s-podmena-signatury-diag-118 struktura-signatura118 KRASEN
STAB s-podmena-signatury-diag-135 struktura-signatura135 KRASEN
STAB s-podmena-signatury-diag-135 135-adb-notfound KRASEN
STAB s-podmena-signatury-diag-995 struktura-signatura995 KRASEN
STAB s-povtor-bez-perezapuska-135 135-oflin-povtor-spas KRASEN
STAB s-shag-pereimenovan-135 struktura-shag135 KRASEN
STAB s-signatura-rasshirena-135 135-install-failed-bez-povtora KRASEN
STAB s-signatura-suzhena-135 135-devserverdied-povtor-krasen KRASEN
STAB s-signatura-suzhena-135 struktura-signatura135 KRASEN
STAB s-tail-korotkij-135 135-emulator-log-hvost KRASEN
STAB s-vyrazhenie-vne-alfavita struktura-vyrazhenija KRASEN
SVJAZI 41
zhivykh 0
```

Собственная атака:

```text
$ python3 /tmp/dev-harness-verify/Critic141/attack_step_metadata.py
witness: /tmp/dev-harness-verify/Critic141/attack-if-false/.github/workflows/mobile.yml
name: 135 first-run-ekran (валидатор 132 + cmp + проверка происхождения, Maestro × тема)
if: ${{ false }}
run unchanged: True
[exit=0]
$ env -i PATH=/home/harness/.local/bin:/usr/bin:/bin bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141/attack-if-false
CASE 135-oflin-povtor-spas ok
CASE 135-adb-notfound ok
CASE 135-serial-notfound ok
CASE 135-devserverdied-povtor-krasen ok
CASE 135-chistyj-proval ok
CASE 135-zelenyj ok
CASE 135-boot-ne-zagruzilsja ok
CASE 135-stabil-nedostizhima ok
CASE 135-emulator-log-hvost ok
CASE 135-install-failed-bez-povtora ok
CASE 135-pustoj-maestro-out ok
CASE 118-oflin-povtor-spas ok
CASE 118-devserverdied-povtor-spas ok
CASE 118-povtor-tozhe-krasen ok
CASE 118-chistyj-proval ok
CASE 118-zelenyj ok
CASE 118-boot-ne-zagruzilsja ok
CASE 118-stabil-nedostizhima ok
CASE 118-emulator-log-hvost ok
CASE 995-diag-signatura ok
CASE 995-chistyj-proval ok
CASE 995-zelenyj ok
CASE struktura-shag135 ok
CASE struktura-shag118 ok
CASE struktura-shag995 ok
CASE struktura-pereformat135 ok
CASE struktura-pereformat118 ok
CASE struktura-pereformat995 ok
CASE struktura-signatura135 ok
CASE struktura-signatura118 ok
CASE struktura-signatura995 ok
CASE struktura-vyrazhenija ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-shag-net ok
[exit=0]
```

## Не выполнено после блокера

Порча модели/носителя; `pre_critic`, precision gate, `check_ceilings`, `check_provodka`, соседи 138/139; сверка frozen-блобов, живого PR #124 и дополнительных привязок стаб↔ветвь. Их исход не заявляю. Splash 0.000/Н-409 прямо исключены из предмета (:32), здесь не атакованы. СОВЕТ: нет; один доказанный класс блокера достаточен для остановки по заданию.
