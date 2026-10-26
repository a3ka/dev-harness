accept
OBJECT=828a0864ca32051ef69188e3e978f87da0ec3423
СУД: repo=dev-harness; предмет=141; фаза=контракт; роль=critic-sol; вызов=3 (по решению арбитра, сверх 2/2); модель-план=openai-codex/gpt-6-sol; сессия=Critic141c; модель-факт=openai-codex/gpt-6-sol; SHA=828a0864ca32051ef69188e3e978f87da0ec3423; предыдущий=verdicts/critic/contracts-141-v1-krug1-fail.md, verdicts/critic/contracts-141-v1-krug2-fail.md + verdicts/arbitration/contracts-141-arbitraz.md; исключение=один дополнительный вызов по решению арбитра Q2 и слову владельца 25.10, предмет (i)–(v).
Независимость: автор Architect141c — zai/glm-5.3 (задание), судья Critic141c — openai-codex/gpt-6-sol (факт окружения). Судился коммит OBJECT в отдельном клоне; SSH-клон удалённого origin не содержал OBJECT, поэтому недостающий зафиксированный коммит доставлен `git fetch /home/harness/dev-harness 828a0864ca32051ef69188e3e978f87da0ec3423 && git checkout -q 828a0864ca32051ef69188e3e978f87da0ec3423` → rc 0; предмет HEAD именно указанный SHA. Оригиналы свидетелей/мутантов только читались; все запуски — на копиях внутри `/tmp/dev-harness-verify/Critic141c/witnesses/`. Изоляция всех W: `env -i PATH=/home/harness/.local/bin:/usr/bin:/bin`; без omp/сети.

## БЛОКИРУЕТ

Нет: исполнение закрытого перечня A–F / (i)–(v) подтверждено именованным отказом всех ранее зелёных оболочек; не найден маскирующий случай внутри J1–J3/W1–W2 с rc 0.

## СОВЕТ

СОВЕТ contracts/141-obryv-adb-diagnostika.md:183 — дословная строка §НЕ ЗАЩИЩАЕТ об ограничении значений зелёных ключей из решения арбитра заканчивается точкой, в контракте — точка с запятой. Единственное отклонение одного знака не меняет ни границу, ни исполняемость, ни проверяемость; под порогом инженерного блокирования.

## Вывод суда по перечню

- (i) `probe.py:334-399` — J1 ключи живой модели ∪ 4 зелёных; J2 проверки всех `needs` и транзитивной цепи без `if`; J3 integer ≥1 (bool отвергнут); W1 равенство `defaults`, W2 отсутствие `env`. Мёртвых `_istinnoe`, `_if_lozhnoe`, `JOB_IF_LOZH_SEMEJSTVO`, отдельного разбора `env.PATH` нет. `source.json` — 41 клетка: из предыдущих 39 изменилось лишь `opisanie` job-клетки, добавлены workflow и зелёная job-клетка; из предыдущих 38 стабов все сохранены, девять новых порождены функциями кода; кодогенерация каждого нового стаба YAML-эквивалентна соответствующему дереву арбитра. `--stabs` подтверждает девять красных связей; прежние 3 job-стаба краснеют новым диагнозом.
- (ii) оба сохранённых свидетеля в СВОИХ копиях → rc 1 с `UPRAVLYAYUSHCHIJ_KLYUCH` именно для `if` целевого шага и `continue-on-error` job соответственно.
- (iii) 22 маскирующих мутанта арбитра (№1–17, №19–23) → каждый rc 1 адресной структурной причиной; четыре зелёных мутанта №24–27 → rc 0 и 41/41 ok; №18 `container` вне маскирующего множества, по алфавиту красен [ИНФЕРЕНЦИЯ по J1; не запускался как часть обязательных 22].
- (iv) без субъекта 41/41 KRASNO, модель 41/41 ok (живой замер `time W --model`: real 0m11.758s < 60s), стабы 47 / 61 связей / 0 живых; порча модели/носителя → rc 2 `ORACLE_TAMPERED`; живой носитель 25 красных / 16 зелёных, все 5 управляющих зелёные; `pre_critic`, `check_ceilings`, `check_precision_gate`, `check_provodka` на копии с единственной CI-строкой — rc 0; соседние 138/139 `--stabs` rc 0, `SVJAZI 53/60`.
- (v) контракт явно не обещает проверки предшествующих целевым чужих шагов, поведения GitHub Actions при размещении runtime-вывода и живого состояния upstream jobs; остатки привязаны к ревью diff и первому живому прогону. Арбитражное предложение §НЕ ЗАЩИЩАЕТ воспроизведено по смыслу и по словам, кроме финального знака препинания.

## Сырые измерения

Команды ниже записаны настоящим запуском из cwd `/tmp/dev-harness-verify/Critic141c/repo`; перед каждым вызовом установлен `env -i PATH=/home/harness/.local/bin:/usr/bin:/bin`. После `rc=` — не реконструкция, а объединённые stdout+stderr запуска. Сырые копии каждого вывода: `/tmp/dev-harness-verify/Critic141c/evidence/<имя>.log`. Записанные отдельные валидаторы (не включены в 33 W): `bash scripts/pre_critic.sh contracts/141-obryv-adb-diagnostika.md` rc 0, `  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=4` / `КРИТИК: дверь зелёная`; `bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Critic141c/repo` rc 0, `потолки в порядке`; `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic141c/repo contracts/141-obryv-adb-diagnostika.md` rc 0, `OK`; `bash scripts/check_provodka.sh /tmp/dev-harness-verify/Critic141c/provodka contracts/141-obryv-adb-diagnostika.md` rc 0, пустой вывод (единственная добавленная в копию строка `step\tcheck:obryv-adb-diagnostika-141-family-selftest\t18\tbash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --stabs`). `bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --stabs` rc 0, `SVJAZI 60`; `bash fixtures/workshop_project/start_ekran_138/red_start_ekran_138.sh --stabs` rc 0, `SVJAZI 53`; порча каждой копии отдельно в `/tmp/dev-harness-verify/Critic141c/witnesses/{model-corrupt,carrier-corrupt}` → `--model` rc 2, строки `ORACLE_TAMPERED: пин model/mobile.yml не сходится` и `ORACLE_TAMPERED: пин носителя mobile-bez-141.yml не сходится`.

Аудит сравнения `env -i PATH=/home/harness/.local/bin:/usr/bin:/bin python3 /tmp/dev-harness-verify/Critic141c/audit_fixtures.py` → `KEJSY: old=39 new=41 modified=['struktura-upravlenie-job']`, `STABY: old=38 new=47 old-unchanged=38 ...`; все девять новых функций `sdelat_stab` сопоставлены по YAML-дереву с подлинными мутантами арбитра, результаты в выводе аудита. `check_wording.py` → `LINE 1 expected length 595 present True`, `LINE 2 expected length 238 present False`, дельта только `replace '.' => ';'`.

### without-subject

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh
rc=1
SUBJECT_ABSENT: нет субъекта .github/workflows/mobile.yml; зелень без субъекта невозможна
CASE 135-oflin-povtor-spas KRASNO (SUBJECT_ABSENT)
CASE 135-adb-notfound KRASNO (SUBJECT_ABSENT)
CASE 135-serial-notfound KRASNO (SUBJECT_ABSENT)
CASE 135-devserverdied-povtor-krasen KRASNO (SUBJECT_ABSENT)
CASE 135-chistyj-proval KRASNO (SUBJECT_ABSENT)
CASE 135-zelenyj KRASNO (SUBJECT_ABSENT)
CASE 135-boot-ne-zagruzilsja KRASNO (SUBJECT_ABSENT)
CASE 135-stabil-nedostizhima KRASNO (SUBJECT_ABSENT)
CASE 135-emulator-log-hvost KRASNO (SUBJECT_ABSENT)
CASE 135-install-failed-bez-povtora KRASNO (SUBJECT_ABSENT)
CASE 135-pustoj-maestro-out KRASNO (SUBJECT_ABSENT)
CASE 118-oflin-povtor-spas KRASNO (SUBJECT_ABSENT)
CASE 118-devserverdied-povtor-spas KRASNO (SUBJECT_ABSENT)
CASE 118-povtor-tozhe-krasen KRASNO (SUBJECT_ABSENT)
CASE 118-chistyj-proval KRASNO (SUBJECT_ABSENT)
CASE 118-zelenyj KRASNO (SUBJECT_ABSENT)
CASE 118-boot-ne-zagruzilsja KRASNO (SUBJECT_ABSENT)
CASE 118-stabil-nedostizhima KRASNO (SUBJECT_ABSENT)
CASE 118-emulator-log-hvost KRASNO (SUBJECT_ABSENT)
CASE 995-diag-signatura KRASNO (SUBJECT_ABSENT)
CASE 995-chistyj-proval KRASNO (SUBJECT_ABSENT)
CASE 995-zelenyj KRASNO (SUBJECT_ABSENT)
CASE struktura-shag135 KRASNO (SUBJECT_ABSENT)
CASE struktura-shag118 KRASNO (SUBJECT_ABSENT)
CASE struktura-shag995 KRASNO (SUBJECT_ABSENT)
CASE struktura-pereformat135 KRASNO (SUBJECT_ABSENT)
CASE struktura-pereformat118 KRASNO (SUBJECT_ABSENT)
CASE struktura-pereformat995 KRASNO (SUBJECT_ABSENT)
CASE struktura-signatura135 KRASNO (SUBJECT_ABSENT)
CASE struktura-signatura118 KRASNO (SUBJECT_ABSENT)
CASE struktura-signatura995 KRASNO (SUBJECT_ABSENT)
CASE struktura-vyrazhenija KRASNO (SUBJECT_ABSENT)
CASE struktura-upravlenie-shag135 KRASNO (SUBJECT_ABSENT)
CASE struktura-upravlenie-shag118 KRASNO (SUBJECT_ABSENT)
CASE struktura-upravlenie-shag995 KRASNO (SUBJECT_ABSENT)
CASE struktura-upravlenie-job KRASNO (SUBJECT_ABSENT)
CASE struktura-upravlenie-workflow KRASNO (SUBJECT_ABSENT)
CASE derevo-bez-141 KRASNO (SUBJECT_ABSENT)
CASE derevo-chuzhoj-shag KRASNO (SUBJECT_ABSENT)
CASE derevo-job-zakonnaja-pravka KRASNO (SUBJECT_ABSENT)
CASE derevo-shag-net KRASNO (SUBJECT_ABSENT)
```

### model

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --model
rc=0
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job ok
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### stabs

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --stabs
rc=0
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job ok
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
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
STAB s-upr-continue-995 struktura-upravlenie-shag995 KRASEN
STAB s-upr-env-path-135 struktura-upravlenie-shag135 KRASEN
STAB s-upr-if-always-995 struktura-upravlenie-shag995 KRASEN
STAB s-upr-if-false-135 struktura-upravlenie-shag135 KRASEN
STAB s-upr-if-literal-118 struktura-upravlenie-shag118 KRASEN
STAB s-upr-job-continue struktura-upravlenie-job KRASEN
STAB s-upr-job-continue-vyrazhenie struktura-upravlenie-job KRASEN
STAB s-upr-job-defaults-shell struktura-upravlenie-job KRASEN
STAB s-upr-job-env-bash-env struktura-upravlenie-job KRASEN
STAB s-upr-job-env-path struktura-upravlenie-job KRASEN
STAB s-upr-job-if-dinam struktura-upravlenie-job KRASEN
STAB s-upr-job-if-false struktura-upravlenie-job KRASEN
STAB s-upr-job-matrix-continue struktura-upravlenie-job KRASEN
STAB s-upr-job-timeout-vyrazhenie struktura-upravlenie-job KRASEN
STAB s-upr-quality-if-false struktura-upravlenie-job KRASEN
STAB s-upr-shell-118 struktura-upravlenie-shag118 KRASEN
STAB s-upr-timeout-0-135 struktura-upravlenie-shag135 KRASEN
STAB s-upr-uses-135 struktura-upravlenie-shag135 KRASEN
STAB s-upr-workflow-defaults-shell struktura-upravlenie-workflow KRASEN
STAB s-upr-workflow-env-bash-env struktura-upravlenie-workflow KRASEN
STAB s-vyrazhenie-vne-alfavita struktura-vyrazhenija KRASEN
SVJAZI 61
zhivykh 0
```

### critic-if-false

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/critic-if-false
rc=1
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
CASE struktura-upravlenie-shag135 KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: shag 135: лишние ключи: if)
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job ok
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### critic-job-continue

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/critic-job-continue
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: лишние ключи: continue-on-error)
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### job-coe-vyrazhenie-true

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/job-coe-vyrazhenie-true
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: лишние ключи: continue-on-error)
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### job-coe-vyrazhenie-1eq1

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/job-coe-vyrazhenie-1eq1
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: лишние ключи: continue-on-error)
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### job-coe-matrix

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/job-coe-matrix
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: лишние ключи: continue-on-error, strategy)
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### job-coe-yes

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/job-coe-yes
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: лишние ключи: continue-on-error)
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### job-coe-str-true

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/job-coe-str-true
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: лишние ключи: continue-on-error)
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### job-coe-bool-tag

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/job-coe-bool-tag
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: лишние ключи: continue-on-error)
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### job-if-vyrazhenie-dinam

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/job-if-vyrazhenie-dinam
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: лишние ключи: if)
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### job-if-false-literal

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/job-if-false-literal
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: лишние ключи: if)
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### job-if-0

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/job-if-0
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: лишние ключи: if)
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### job-if-null-str

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/job-if-null-str
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: лишние ключи: if)
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### job-defaults-shell-true

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/job-defaults-shell-true
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: лишние ключи: defaults)
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### top-defaults-shell-true

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/top-defaults-shell-true
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job ok
CASE struktura-upravlenie-workflow KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: workflow: defaults={'run': {'working-directory': 'mobile', 'shell': 'true {0}'}} (в модели {'run': {'working-directory': 'mobile'}}))
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### top-defaults-shell-cat

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/top-defaults-shell-cat
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job ok
CASE struktura-upravlenie-workflow KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: workflow: defaults={'run': {'working-directory': 'mobile', 'shell': 'cat {0}'}} (в модели {'run': {'working-directory': 'mobile'}}))
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### job-env-bash-env

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/job-env-bash-env
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: лишние ключи: env)
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### job-env-path

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/job-env-path
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: лишние ключи: env)
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### top-env-path

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/top-env-path
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job ok
CASE struktura-upravlenie-workflow KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: workflow: env вне модели: ['PATH'])
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### top-env-bash-env

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/top-env-bash-env
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job ok
CASE struktura-upravlenie-workflow KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: workflow: env вне модели: ['BASH_ENV'])
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### job-timeout-vyrazhenie

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/job-timeout-vyrazhenie
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: timeout-minutes='${{ 0 }}')
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### job-timeout-0

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/job-timeout-0
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: timeout-minutes=0)
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### job-needs-net

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/job-needs-net
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: needs на несуществующую работу 'net-takoj')
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### quality-if-false

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/quality-if-false
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: upstream quality несёт if='${{ false }}')
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### job-needs-drugaja

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/job-needs-drugaja
rc=1
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: upstream deploy несёт if=False)
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### job-runs-on-drugoj

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/job-runs-on-drugoj
rc=0
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job ok
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### job-timeout-50

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/job-timeout-50
rc=0
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job ok
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### job-permissions

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/job-permissions
rc=0
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job ok
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### job-name

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/job-name
rc=0
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job ok
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### kontrol-model

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/kontrol-model
rc=0
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
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job ok
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

### live

```text
$ bash /tmp/dev-harness-verify/Critic141c/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Critic141c/witnesses/live
rc=1
CASE 135-oflin-povtor-spas KRASNO (CHISTYJ: rc=1 (ожидался 0))
CASE 135-adb-notfound KRASNO (CHISTYJ: rc=1 (ожидался 0))
CASE 135-serial-notfound KRASNO (CHISTYJ: rc=1 (ожидался 0))
CASE 135-devserverdied-povtor-krasen KRASNO (CHISTYJ: записи: ['EMULATOR ci135-401407-1', 'PRIEMKA 135 rc=1'] (ожидались ['EMULATOR ci135-401407-1', 'PRIEMKA 135 rc=1', 'ADB_DEVICES', 'EMULATOR ci135-401407-1', 'PRIEMKA 135 rc=1', 'ADB_DEVICES']))
CASE 135-chistyj-proval KRASNO (CHISTYJ: записи: ['EMULATOR ci135-401407-1', 'PRIEMKA 135 rc=1'] (ожидались ['EMULATOR ci135-401407-1', 'PRIEMKA 135 rc=1', 'ADB_DEVICES']))
CASE 135-zelenyj ok
CASE 135-boot-ne-zagruzilsja KRASNO (CHISTYJ: записи: ['EMULATOR ci135-401407-1'] (ожидались ['EMULATOR ci135-401407-1', 'ADB_DEVICES']))
CASE 135-stabil-nedostizhima KRASNO (CHISTYJ: rc=0 (ожидался 1))
CASE 135-emulator-log-hvost KRASNO (CHISTYJ: rc=1 (ожидался 0))
CASE 135-install-failed-bez-povtora KRASNO (CHISTYJ: записи: ['EMULATOR ci135-401407-1', 'PRIEMKA 135 rc=1'] (ожидались ['EMULATOR ci135-401407-1', 'PRIEMKA 135 rc=1', 'ADB_DEVICES']))
CASE 135-pustoj-maestro-out KRASNO (CHISTYJ: записи: ['EMULATOR ci135-401407-1', 'PRIEMKA 135 rc=1'] (ожидались ['EMULATOR ci135-401407-1', 'PRIEMKA 135 rc=1', 'ADB_DEVICES']))
CASE 118-oflin-povtor-spas KRASNO (CHISTYJ: rc=1 (ожидался 0))
CASE 118-devserverdied-povtor-spas KRASNO (CHISTYJ: rc=1 (ожидался 0))
CASE 118-povtor-tozhe-krasen KRASNO (CHISTYJ: записи: ['EMULATOR ci118-401407-1', 'PRIEMKA 118 rc=1'] (ожидались ['EMULATOR ci118-401407-1', 'PRIEMKA 118 rc=1', 'ADB_DEVICES', 'EMULATOR ci118-401407-1', 'PRIEMKA 118 rc=1', 'ADB_DEVICES']))
CASE 118-chistyj-proval KRASNO (CHISTYJ: записи: ['EMULATOR ci118-401407-1', 'PRIEMKA 118 rc=1'] (ожидались ['EMULATOR ci118-401407-1', 'PRIEMKA 118 rc=1', 'ADB_DEVICES']))
CASE 118-zelenyj ok
CASE 118-boot-ne-zagruzilsja KRASNO (CHISTYJ: записи: ['EMULATOR ci118-401407-1'] (ожидались ['EMULATOR ci118-401407-1', 'ADB_DEVICES']))
CASE 118-stabil-nedostizhima KRASNO (CHISTYJ: rc=0 (ожидался 1))
CASE 118-emulator-log-hvost KRASNO (CHISTYJ: rc=1 (ожидался 0))
CASE 995-diag-signatura KRASNO (CHISTYJ: записи: ['PROBA995 rc=1'] (ожидались ['PROBA995 rc=1', 'ADB_DEVICES']))
CASE 995-chistyj-proval KRASNO (CHISTYJ: записи: ['PROBA995 rc=1'] (ожидались ['PROBA995 rc=1', 'ADB_DEVICES']))
CASE 995-zelenyj ok
CASE struktura-shag135 KRASNO (SKRIPT_RASHOZHDENIE: shag 135: строка 18: 'emulator -avd "$AVD" -port "$PORT" -no-window -no-audio -no-boot-anim -no-snapshot \\' ≠ 'boot135() {')
CASE struktura-shag118 KRASNO (SKRIPT_RASHOZHDENIE: shag 118: строка 18: 'emulator -avd "$AVD" -port "$PORT" -no-window -no-audio -no-boot-anim -no-snapshot \\' ≠ 'boot118() {')
CASE struktura-shag995 KRASNO (SKRIPT_RASHOZHDENIE: shag 995: строка 3: 'python3 .harness/fixtures/workshop_project/pilot_995/maestro_probe.py \\' ≠ 'set +e')
CASE struktura-pereformat135 ok
CASE struktura-pereformat118 ok
CASE struktura-pereformat995 ok
CASE struktura-signatura135 KRASNO (PODMENA_SIGNATURY: вхождений канона 0, ожидалось 2)
CASE struktura-signatura118 KRASNO (PODMENA_SIGNATURY: вхождений канона 0, ожидалось 2)
CASE struktura-signatura995 KRASNO (PODMENA_SIGNATURY: вхождений канона 0, ожидалось 1)
CASE struktura-vyrazhenija ok
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job ok
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
```

