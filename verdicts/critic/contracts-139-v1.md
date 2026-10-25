accept

OBJECT=af84bb639ded04f8bcdcfbf64c176f044c1609ef. Исправительный суд по закрытому перечню A–G РЕШЕНИЯ арбитража 139. **БЛОКИРУЕТ: нет. СОВЕТ: нет.** В своём SSH-клоне наложил три коммита автора на `9a083ee82`: `HEAD=e727e5e9bf630a635b0e3ebcf1ac4f24557f6a77`, `HEAD^{tree}=6e6a3f6828ec79ad327fe71ef97d4498b414edce=OBJECT^{tree}`. Предмет закоммичен, контракт и батарею не правил (`git status --short` пуст, `git diff --exit-code -- contracts/139-e2e-avtoperezapusk.md fixtures/workshop_project/e2e_avtoperezapusk_139/` rc 0).

СУД: repo=dev-harness; предмет=139; фаза=контракт; роль=critic-sol; вызов=3/3 (один дополнительный, разрешённый владельцем после 2/2 и арбитража); модель-план=openai-codex/gpt-6-sol; сессия=Critic139c; модель-факт=openai-codex/gpt-6-sol; SHA=af84bb639ded04f8bcdcfbf64c176f044c1609ef; предыдущий=/tmp/dev-harness-verify/orch/keep139-arbitraz.md; исключение=разрешённый владельцем 25.10 дополнительный вызов. Фактическая модель автора по предоставленной оркестратором трассе — `zai/glm-5.3`; семейства различны. Доступная мне история `history://Architect139` модель не показывает: не выдаю назначение модели за самостоятельно увиденный трейс.

## Измерения и атаки

Рабочий каталог относительных команд: `/tmp/dev-harness-verify/Critic139c/repo`. Здесь `W` обозначает **полную команду** `bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh`. Измерители и сохранённые деревья — только в `/tmp/dev-harness-verify/Critic139c/`. Их stdout включает реальные коды дочерних `W --repo`, число CASE и конкретные диагнозы, вместо повторения 42 строк каждого отдельного дерева.

1. `env -u MOB_REPO bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh` → rc 1; stdout начинается `SUBJECT_ABSENT: нет --repo/MOB_REPO с корнем продукта`, далее 42 `CASE … KRASNO (SUBJECT_ABSENT)`, первая `CASE infra-ofline KRASNO (SUBJECT_ABSENT)`, последняя `CASE struktura-skript-pereformat KRASNO (SUBJECT_ABSENT)`. `/usr/bin/time -f 'ELAPSED=%e' W --model` (с раскрытием W в полную команду) → rc 0, `ELAPSED=13.91`, ровно 42 `CASE … ok`, в том числе `CASE struktura-skript-pereformat ok`, `CASE dlinnyj-log-nachalo-2000000 ok`. Независимый `jq '{cases:(.kejsy|length),by_type:(.kejsy|to_entries|group_by(.value.tip)|map({tip:.[0].value.tip,n:length})),stubs:(.stab_vhod|length),links:(.stab_vhod|map(length)|add),models:(.nositeli|length)}' fixtures/workshop_project/e2e_avtoperezapusk_139/source.json` → cases 42 (replay 30 / struktura 11 / derevo 1), stubs 41, links 60, pinned carriers 3.
2. `W --stabs` → rc 0, 42 `CASE … ok`, 60 `STAB … KRASEN`, финал `SVJAZI 60`, живых 0. Сырые строки, предъявляющие разные клетки: `STAB s-skrytaja-vetv-github-actions struktura-skript KRASEN (SKRIPT_RASHOZHDENIE: строка 27: if [ "${GITHUB_ACTIONS:-}" = "true" ]; then (строк 29, в каноне 26))`; `STAB s-skrytaja-vetv-github-actions chistyj-proval KRASEN (@ACTIONS RC_RASHOZHDENIE: 127, ожидался 0)`; `STAB s-api-jobs-f chistyj-proval KRASEN (@CHISTYJ RC_RASHOZHDENIE: 127, ожидался 0)`; `STAB s-setevoj-python chistyj-proval KRASEN (@CHISTYJ RC_RASHOZHDENIE: 127, ожидался 0)`; `STAB s-dop-shag-run struktura-zamknutost KRASEN (ZAMKNUTOST: шагов 2, а не ровно один)`; `STAB s-rannij-grep-q dlinnyj-log-nachalo-2000000 KRASEN (@CHISTYJ STDOUT_RASHOZHDENIE: ['VHOD: run=40198247993 conclusion=failure attempt=1', 'SKIP: инфраструктурной сигнатуры в логе android-e2e нет — чистый провал проверки'], ожидался ['VHOD: run=40198247993 conclusion=failure attempt=1', 'POVTOR: android-e2e упал по инфраструктурной сигнатуре эмулятора (job 121190778790)'])`. По коду `stab_vhod`: 9 новых стабов имеют **именно** связи арбитра, 9 старых дополнительно привязаны к `struktura-skript`, прежние связи не потеряны.
3. `W --svideteli /tmp/dev-harness-verify/Critic139c/witnesses/v3` → rc 0, шесть деревьев. `git diff --no-index /tmp/dev-harness-verify/Critic139b/witnesses/hidden-api/.github/workflows/mobile-e2e-retry.yml /tmp/dev-harness-verify/Critic139c/witnesses/v3/kritik-hidden-api/.github/workflows/mobile-e2e-retry.yml` → rc 0, вывод пуст: старый свидетель дословен. `python3 /tmp/dev-harness-verify/Critic139c/measure.py` → rc 0; **сырые строки шести отдельных вызовов `W --repo`**:

```text
WITNESS env-ci rc= 1 ok= 33 red= 9 diagnosis= ['CASE struktura-skript KRASNO: SKRIPT_RASHOZHDENIE: строка 27: if [ "${CI:-}" = "true" ]; then (строк 29, в каноне 26)'] stderr= ''
WITNESS env-f-post rc= 1 ok= 33 red= 9 diagnosis= ['CASE struktura-skript KRASNO: SKRIPT_RASHOZHDENIE: строка 27: if [ -n "${GITHUB_RUN_ID:-}" ]; then (строк 29, в каноне 26)'] stderr= ''
WITNESS kritik-hidden-api rc= 1 ok= 33 red= 9 diagnosis= ['CASE struktura-skript KRASNO: SKRIPT_RASHOZHDENIE: строка 27: if [ "${GITHUB_ACTIONS:-}" = "true" ]; then (строк 29, в каноне 26)'] stderr= ''
WITNESS run-id-vne-batarei rc= 1 ok= 40 red= 2 diagnosis= ['CASE struktura-skript KRASNO: SKRIPT_RASHOZHDENIE: строка 27: case "${RUN_ID}" in (строк 30, в каноне 26)'] stderr= ''
WITNESS sandbox-tell-gh-bin rc= 1 ok= 40 red= 2 diagnosis= ['CASE struktura-skript KRASNO: SKRIPT_RASHOZHDENIE: строка 27: if ! sed -n \'1p\' "$(command -v gh)" | grep -q python; then (строк 29, в каноне 26)'] stderr= ''
WITNESS sandbox-tell-scenarij rc= 1 ok= 40 red= 2 diagnosis= ['CASE struktura-skript KRASNO: SKRIPT_RASHOZHDENIE: строка 27: if [ -z "${SCENARIJ_ZAPISI:-}" ]; then (строк 29, в каноне 26)'] stderr= ''
```

Тот же `measure.py` сохраняет собственные деревья `witnesses/normalization/`, судит `os_skript` на разобранном YAML и `W --repo` для here-doc. Сырые строки каждой синтаксической атаки:

```text
NORMALIZATION line-break changes_canon= True diagnosis= ['SKRIPT_RASHOZHDENIE: строка 23: gh run rerun --failed (строк 27, в каноне 26)']
NORMALIZATION continuation changes_canon= True diagnosis= ['SKRIPT_RASHOZHDENIE: строка 23: gh run rerun --failed \\ (строк 27, в каноне 26)']
NORMALIZATION case changes_canon= True diagnosis= ['SKRIPT_RASHOZHDENIE: строка 23: GH run rerun --failed "$RUN_ID"']
NORMALIZATION quoted-space changes_canon= True diagnosis= ['SKRIPT_RASHOZHDENIE: строка 23: gh run rerun --failed " $RUN_ID"']
NORMALIZATION token-space changes_canon= True diagnosis= ['SKRIPT_RASHOZHDENIE: строка 23: gh  run rerun --failed "$RUN_ID"']
NORMALIZATION heredoc changes_canon= True diagnosis= ["SKRIPT_RASHOZHDENIE: строка 23: cat <<'END_HERE' (строк 28, в каноне 26)"]
W_HEREDOC rc= 1 script= ["CASE struktura-skript KRASNO: SKRIPT_RASHOZHDENIE: строка 23: cat <<'END_HERE' (строк 28, в каноне 26)"]
```

Ещё четыре `CODE_STAB`-строки того же вывода (мутации КОДОМ, а не обещания прозой): `s-skrytaja-vetv-github-actions` красен `SKRIPT_RASHOZHDENIE: строка 27` и `@ACTIONS RC_RASHOZHDENIE: 127` с записью `VNE_ALFAVITA api -X POST`; `s-api-f-post` красен теми же осями с записью `VNE_ALFAVITA api … -f reason=x`; `s-pesochnica-scenarij` красен структурно, replay к нему не привязан; `s-api-jobs-f` красен на строке 11 и `@CHISTYJ RC_RASHOZHDENIE: 127`. Все `changed=True`; весь вывод измерителя оставлен в его tool-трейсе. Переформат с новыми комментариями/пустыми/хвостовыми пробелами зелёный (`CASE struktura-skript-pereformat ok`); значимые перенос строки, продолжение `\\`, here-doc, регистр и пробелы внутри кавычек/между токенами отвергнуты.

4. `python3 /tmp/dev-harness-verify/Critic139c/replay.py` → rc 0; сырой stdout прямого `probe.replay` на `chistyj-proval`:

```text
MODEL CHISTYJ rc= 0 stdout= ['VHOD: run=40198243018 conclusion=failure attempt=1', 'SKIP: инфраструктурной сигнатуры в логе android-e2e нет — чистый провал проверки'] calls= ['API_JOBS 40198243018', 'API_LOGS 121184287236'] bad= False
MODEL ACTIONS rc= 0 stdout= ['VHOD: run=40198243018 conclusion=failure attempt=1', 'SKIP: инфраструктурной сигнатуры в логе android-e2e нет — чистый провал проверки'] calls= ['API_JOBS 40198243018', 'API_LOGS 121184287236'] bad= False
ENV_BRANCH CHISTYJ rc= 0 stdout= ['VHOD: run=40198243018 conclusion=failure attempt=1', 'SKIP: инфраструктурной сигнатуры в логе android-e2e нет — чистый провал проверки'] calls= ['API_JOBS 40198243018', 'API_LOGS 121184287236'] bad= False
ENV_BRANCH ACTIONS rc= 127 stdout= ['VHOD: run=40198243018 conclusion=failure attempt=1', 'SKIP: инфраструктурной сигнатуры в логе android-e2e нет — чистый провал проверки'] calls= ['API_JOBS 40198243018', 'API_LOGS 121184287236', 'VNE_ALFAVITA api\x1f-X\x1fPOST\x1frepos/a3ka/Complior-mob/actions/runs/40198243018/rerun'] bad= False
GH_POST_FIELD CHISTYJ rc= 127 stdout= ['VHOD: run=40198243018 conclusion=failure attempt=1'] calls= ['VNE_ALFAVITA api\x1frepos/a3ka/Complior-mob/actions/runs/40198243018/jobs\x1f-f\x1fx=1\x1f--jq\x1f.jobs[] | select(.name == "android-e2e" and .conclusion == "failure") | .id'] bad= False
GH_POST_FIELD ACTIONS rc= 127 stdout= ['VHOD: run=40198243018 conclusion=failure attempt=1'] calls= ['VNE_ALFAVITA api\x1frepos/a3ka/Complior-mob/actions/runs/40198243018/jobs\x1f-f\x1fx=1\x1f--jq\x1f.jobs[] | select(.name == "android-e2e" and .conclusion == "failure") | .id'] bad= False
NO_PYTHON CHISTYJ rc= 127 stdout= ['VHOD: run=40198243018 conclusion=failure attempt=1', 'SKIP: инфраструктурной сигнатуры в логе android-e2e нет — чистый провал проверки'] calls= ['API_JOBS 40198243018', 'API_LOGS 121184287236'] bad= False
NO_PYTHON ACTIONS rc= 127 stdout= ['VHOD: run=40198243018 conclusion=failure attempt=1', 'SKIP: инфраструктурной сигнатуры в логе android-e2e нет — чистый провал проверки'] calls= ['API_JOBS 40198243018', 'API_LOGS 121184287236'] bad= False
```

`probe.py:48-101,903-981`: ровно три argv-формы gh; всё вне алфавита `VNE_ALFAVITA`/127. Шим получает абсолютный shebang `sys.executable`; PATH — один `bindir` с симлинками `{bash,sed,grep,tr,mktemp,rm}`, python3/curl недоступны. `GITHUB_EVENT_PATH` в ACTIONS — JSON события конкретного кейса (`probe.py:884-900`). Код `sudit` исполняет каждый из 30 replay-кейсов в CHISTYJ и ACTIONS против **одного** оракула и печатает одну CASE-строку, при отказе указывает `@CHISTYJ`/`@ACTIONS` (`probe.py:1017-1071`). Окружение — свидетель env-инвариантности модели, *не* объявлено замыканием класса; замыкание даёт канон модели с пином sha256.

5. `python3 /tmp/dev-harness-verify/Critic139c/structure.py` → rc 0; сырой stdout старых двух свидетелей (`W --repo` внутри):

```text
extra-step rc= 1 ok= 40 red= 2 ZAMKNUTOST= ['CASE struktura-zamknutost KRASNO: ZAMKNUTOST: шагов 2, а не ровно один'] stderr= ''
extra-job rc= 1 ok= 40 red= 2 ZAMKNUTOST= ["CASE struktura-zamknutost KRASNO: ZAMKNUTOST: jobs ['retry', 'unguarded'], а не ровно один retry"] stderr= ''
```

`python3 /tmp/dev-harness-verify/Critic139c/long_logs.py` → rc 0; на двух длинных логах модель повторяет, ранний `grep -q` даёт ложный SKIP, при длинном эхе повторов нет. Сырые строки для 2 млн строк:

```text
dlinnyj-log-nachalo-2000000 model CHISTYJ rc= 0 end= 'POVTOR: android-e2e упал по инфраструктурной сигнатуре эмулятора (job 121190778790)' last_call= 'RERUN --failed 40198247993' bad= False
dlinnyj-log-nachalo-2000000 model ACTIONS rc= 0 end= 'POVTOR: android-e2e упал по инфраструктурной сигнатуре эмулятора (job 121190778790)' last_call= 'RERUN --failed 40198247993' bad= False
dlinnyj-log-nachalo-2000000 early-grep CHISTYJ rc= 0 end= 'SKIP: инфраструктурной сигнатуры в логе android-e2e нет — чистый провал проверки' last_call= 'API_LOGS 121190778790' bad= False
dlinnyj-log-nachalo-2000000 early-grep ACTIONS rc= 0 end= 'SKIP: инфраструктурной сигнатуры в логе android-e2e нет — чистый провал проверки' last_call= 'API_LOGS 121190778790' bad= False
```

`python3 /tmp/dev-harness-verify/Critic139c/negatives.py` → rc 0, сырой stdout:

```text
MODEL_REPO rc= 0 ok= 42 red= 0 first= 'CASE infra-ofline ok' stderr= ''
MOBILE_CHANGED rc= 1 ok= 0 red= 0 first= '' stderr= 'MOBILE_YML_IZMENEN: байты /tmp/dev-harness-verify/Critic139c/witnesses/negatives/mobile-edited/.github/workflows/mobile.yml не равны пину канона'
SUBJECT_MISSING rc= 1 ok= 0 red= 42 first= 'SUBJECT_ABSENT: /tmp/dev-harness-verify/Critic139c/witnesses/negatives/missing/.github/workflows/mobile-e2e-retry.yml' stderr= ''
CARRIER_TAMPERED rc= 2 ok= 0 red= 0 first= '' stderr= 'ORACLE_TAMPERED: sha256 носителя mobile.yml'
MODEL_TAMPERED rc= 2 ok= 0 red= 0 first= '' stderr= 'ORACLE_TAMPERED: sha256 носителя model/mobile-e2e-retry.yml'
```

## Текст, границы, гейты

`contracts/139-e2e-avtoperezapusk.md:26,29,40,48,50-57,59-67,85-110`: нарезка Д/З, инварианты 2/10, критерии с командами и rc, названные исполнители/ЗОНА, ПРОВОДКА отдельной строкой, Демаркация, «Незаполненные требования:» и следующей строкой `нет`. Оба буллета `НЕ ЗАЩИЩАЕТ` (`:98-99`) дословно из РЕШЕНИЯ: конечность replay с названным **каноном**, живой GitHub API с ловцом на первом реальном флейке после merge. Реальный GitHub не вызывался и как проверенный результат здесь не предъявляется.

`python3 /tmp/dev-harness-verify/Critic139c/zones.py` → rc 0: чтение живых блобов последних frozen-версий 995/1,108/1,111/4,117/3,118/1,135/1,123/2,132/1; `.github/workflows/mobile.yml` — соседние implementer-зоны, `.github/workflows/mobile-e2e-retry.yml` отсутствует в них. `git diff --name-only 9a083ee82..HEAD` → ровно `contracts/139-e2e-avtoperezapusk.md` и семь файлов `fixtures/workshop_project/e2e_avtoperezapusk_139/`, зона architect. В SSH-клоне `origin/main` уже продвинулся относительно фиксированного родителя OBJECT: буквальный `git diff --name-only origin/main..HEAD` показывает ещё чужие файлы нового main; вывод о зоне сделан по фиксированному родителю, не по движущемуся ref.

`bash scripts/pre_critic.sh contracts/139-e2e-avtoperezapusk.md` → rc 0, `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3` / `КРИТИК: дверь зелёная`; одиночный `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic139c/repo contracts/139-e2e-avtoperezapusk.md` → rc 0 `OK`; `bash scripts/check_ceilings.sh` → rc 0 `потолки в порядке`. `python3 /tmp/dev-harness-verify/Critic139c/provodka.py` → rc 0, `CHECK_PROVODKA 'step\tcheck:e2e-avtoperezapusk-139-family-selftest\t21\tbash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --stabs\n' rc= 0 stdout= '' stderr= ''`: изолированная копия дерева с одной добавленной строкой ci-steps; интеграционную проводку кладёт названный оркестратор, не судья.
