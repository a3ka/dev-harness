accept

# Ревью контракта 023 v2 — закрытие `da27fab`

Судимая база: `65f1f87569a5e64bf22982f4a4481bcf903ed7cd` (`main`).
Репро и контрольные эксперименты выполнены в одноразовом клоне
`/tmp/Reviewer023k2/repo`; основной checkout до записи этого вердикта был
чист. Полный прогон не запускался: по ПРИЁМКЕ-СУДЬИ v2 он уже предъявлен CI,
ниже только scoped-регресс, живые затронутые барьеры и frozen-проверка.

## 1. Блокер `da27fab` закрыт

Проверен постоянным входом `red_gejt_manifest_tolko_na_origin.sh`. Он строит
пару authority/subject: в subject локально есть только тег, а коммит
`origin/main` с манифестной строкой отсутствует в object database. В м1
честный полный резерв обязан пройти; в м2 `ls-remote` остаётся доступен, но
`fetch` объекта принудительно отказывает, и ожидается именно «авторитет
недоступен». Оба условия проверяются самой фикстурой до её rc 0 (м1:
`rc == 0`, `WORKTREE=`, точный `BRANCH`; м2: `rc == 1` и строка
`авторитет недоступен`).

```text
$ bash fixtures/spawn_agent/red_gejt_manifest_tolko_na_origin.sh; rc1=$?; printf 'RUN_1_RC=%d\n' "$rc1"
отпечаток м1: N=955 subject=/tmp/red023-manifest.jcDkC7/kor-44809431-m1-subj subj-copy=/tmp/red023-manifest.jcDkC7/subj-44809431 origin=/tmp/red023-manifest.jcDkC7/kor-44809431-m1-auth-origin.git origin_main=b0a96a4acd43aba0fc62e3d7af4ffd9cf44e3a14 tag=df20b9b6f6cf6587c1638b606d1258e87b9023ad
отпечаток м2: N=991 subject=/tmp/red023-manifest.jcDkC7/kor-44809432-m2-subj subj-copy=/tmp/red023-manifest.jcDkC7/subj-44809431 origin=/tmp/red023-manifest.jcDkC7/kor-44809432-m2-auth-origin.git origin_main=0b0793fced1060c51593c563e1ca03693de885c4(объект нечитаем) tag=ba2bd373e768139ce6722160133efcf74565f15a fetch_rc=128
RUN_1_RC=0

$ sleep 2 && bash fixtures/spawn_agent/red_gejt_manifest_tolko_na_origin.sh; rc=$?; printf 'RUN_3_RC=%d\n' "$rc"
отпечаток м1: N=962 subject=/tmp/red023-manifest.IYTOS5/kor-44355937-m1-subj subj-copy=/tmp/red023-manifest.IYTOS5/subj-44355937 origin=/tmp/red023-manifest.IYTOS5/kor-44355937-m1-auth-origin.git origin_main=50059fcfd4713c22e0ef6bed42738537432f322e tag=be1c53bd84845eec29b9d90d9ab8a28a5e32ba8b
отпечаток м2: N=971 subject=/tmp/red023-manifest.IYTOS5/kor-44355938-m2-subj subj-copy=/tmp/red023-manifest.IYTOS5/subj-44355937 origin=/tmp/red023-manifest.IYTOS5/kor-44355938-m2-auth-origin.git origin_main=ee449c7a5a7e2f77a434b59414d29cba054631c8(объект нечитаем) tag=8b72a6458041f251b2e8868a429dd2b105e75097 fetch_rc=128
RUN_3_RC=0
```

Входы различны (`955/991` и `962/971`). Тем самым показаны обе стороны
контрольного эксперимента: честный резерв пропускается, а отказ fetch
сохраняет fail-closed имя «авторитет недоступен», не ложное «не выдан
авторитетом».

Проверка кода гейта подтверждает путь именно между живой шапкой и чтением:

```text
$ sed -n '154,170p;186,203p' scripts/spawn_agent.sh; rc=$?; printf 'GATE_SOURCE_RC=%d\n' "$rc"
main_out="$(git -C "$ROOT" ls-remote "origin" "refs/heads/main" 2>/dev/null)"
main_rc=$?
if [ "$main_rc" -ne 0 ]; then printf "NETERR|main\n"; exit 0; fi
origin_main_sha="$(printf "%s\n" "$main_out" | head -1 | awk "{print \$1}")"
if [ -z "$origin_main_sha" ]; then printf "EMPTY|main\n"; exit 0; fi
if ! git -C "$ROOT" fetch origin refs/heads/main 2>/dev/null; then
  printf "NETERR|fetch\n"; exit 0
fi
manifest_text="$(git -C "$ROOT" cat-file -p "${origin_main_sha}:registry/contracts.tsv" 2>/dev/null)"
...
NETERR\|fetch)
  printf 'ОТКАЗ: авторитет недоступен: fetch origin refs/heads/main отказал — fail-closed, обрыв сети НЕ открывает дверь\n' >&2
  exit 1
  ;;
MISSING\|manifest)
  printf 'ОТКАЗ: тег %s не выдан авторитетом: манифест registry/contracts.tsv отсутствует на origin/main (3б)\n' "$nnn_padded_gate" >&2
  exit 1
  ;;
GATE_SOURCE_RC=0
```

## 2. Постоянный вход и красный контроль слабой формы

Новый вход запускался выше дважды с разными параметрами. Его независимость от
реализации установлена историей: `125abb0` и `f2b4b65` — два потомка
`da27fab`, первый автор `implementer`, второй `architect`; ни один не предок
другого.

```text
$ git show -s --format='125abb0%nparents=%P%nauthor=%an%ntitle=%s%n' 125abb0
125abb0
parents=da27fab05b4e5efc6532c87f748d58b943b2b292
author=implementer
title=023 implementer фикс-2: fetch между ls-remote и cat-file в spawn_agent + косметика check_staged

$ git show -s --format='f2b4b65%nparents=%P%nauthor=%an%ntitle=%s%n' f2b4b65
f2b4b65
parents=da27fab05b4e5efc6532c87f748d58b943b2b292
author=architect
title=023 фикс-раунд №2 (architect): постоянный вход «манифест только на origin» для гейта (ii) — da27fab

$ git merge-base --is-ancestor f2b4b65 125abb0; fixture_before_implementer_rc=$?; printf 'FIXTURE_BEFORE_IMPLEMENTER_RC=%d\n' "$fixture_before_implementer_rc"
FIXTURE_BEFORE_IMPLEMENTER_RC=1
$ git merge-base --is-ancestor 125abb0 f2b4b65; implementer_before_fixture_rc=$?; printf 'IMPLEMENTER_BEFORE_FIXTURE_RC=%d\n' "$implementer_before_fixture_rc"
IMPLEMENTER_BEFORE_FIXTURE_RC=1
```

Контрольная слабая форма создана в отдельном worktree: `spawn_agent.sh` взят
ровно из предфиксового `da27fab`, а новый вход — из `f2b4b65`. Это декой
**по коду гейта**: единственная функциональная разница с починенной формой —
отсутствуют `fetch`, `NETERR|fetch` и его диагноз. На м1 декой краснеет
именем исходного дефекта, а не посторонней ошибкой:

```text
$ git -C /tmp/Reviewer023k2/weak-no-fetch diff --no-index -- scripts/spawn_agent.sh /tmp/Reviewer023k2/repo/scripts/spawn_agent.sh; diff_rc=$?; printf 'DECOY_DIFF_RC=%d\n' "$diff_rc"
@@ -156,8 +156,15 @@ if [ -n "$nnn" ]; then
-      # 2в: registry/contracts.tsv по ЖИВОЙ шапке origin/main. Объект читается прямо из
-      # .git/objects — origin в toy bare рядом, fetch не нужен.
+      # 2в. fetch объекта с origin (контракт 023: ls-remote шапки → fetch объекта → show).
+      if ! git -C "$ROOT" fetch origin refs/heads/main 2>/dev/null; then
+        printf "NETERR|fetch\n"; exit 0
+      fi
@@ -180,6 +187,10 @@ if [ -n "$nnn" ]; then
+    NETERR\|fetch)
+      printf 'ОТКАЗ: авторитет недоступен: fetch origin refs/heads/main отказал — fail-closed, обрыв сети НЕ открывает дверь\n' >&2
+      exit 1
+      ;;
DECOY_DIFF_RC=1

$ bash fixtures/spawn_agent/red_gejt_manifest_tolko_na_origin.sh; rc=$?; printf 'WEAK_NO_FETCH_RC=%d\n' "$rc"
отпечаток м1: N=964 subject=/tmp/red023-manifest.uy3z6i/kor-79688985-m1-subj subj-copy=/tmp/red023-manifest.uy3z6i/subj-79688985 origin=/tmp/red023-manifest.uy3z6i/kor-79688985-m1-auth-origin.git origin_main=704c839d77dd6364a5a6a40e0b7492f916d71d70 tag=8b6b23ea7856a5d6ddb8ce79f5f9dc30b87f5d42
ОТКАЗ (da27fab): гейт (ii) без fetch — честный полный резерв (манифест «964 → 8b6b23ea7856a5d6ddb8ce79f5f9dc30b87f5d42» только на origin, объект не реплицирован) отвергнут/не завершён (rc 1, ожидан rc 0, BRANCH=wip/964/architect): ОТКАЗ: тег 964 не выдан авторитетом: манифест registry/contracts.tsv отсутствует на origin/main (3б)
WEAK_NO_FETCH_RC=1
```

Это предъявляет красное именно против дефекта `da27fab`: доступный authority
с выданной строкой ошибочно был объявлен «не выдан авторитетом».

## 3. Совет по `check_staged.sh`

`Ветка` восстановлено на строке 126; последний байт `0x0a`. Единственная
дельта относительно `94beb17` — этот один символ и финальный LF (в выводе
word-diff финальная пустая строка отображает LF):

```text
$ git diff --word-diff=plain 94beb17..125abb0 -- scripts/check_staged.sh; diff_rc=$?; printf 'CHECK_STAGED_DIFF_RC=%d\n' "$diff_rc"
# причиной. [-Ветва-]{+Ветка+} «не судится» ниже срабатывает ТОЛЬКО когда автор ВИДЕН и не объявлен
@@ -399,4 +399,4 @@ done
 exit "$rc"
CHECK_STAGED_DIFF_RC=0

$ sed -n '126p' scripts/check_staged.sh; line_rc=$?; printf 'LINE_126_RC=%d\n' "$line_rc"
# причиной. Ветка «не судится» ниже срабатывает ТОЛЬКО когда автор ВИДЕН и не объявлен
LINE_126_RC=0

$ bytes=$(wc -c < scripts/check_staged.sh); last=$(od -An -t x1 -j $((bytes-1)) -N 1 scripts/check_staged.sh | tr -d '[:space:]'); od_rc=${PIPESTATUS[0]}; printf 'CHECK_STAGED_BYTES=%s LAST_BYTE=0x%s OD_RC=%d\n' "$bytes" "$last" "$od_rc"
CHECK_STAGED_BYTES=29859 LAST_BYTE=0x0a OD_RC=0
```

## 4. Затронутый регресс и живые барьеры

```text
$ bash scripts/verify_antiplacebo.sh . --scope check_staged; rc=$?; printf 'SCOPE_CHECK_STAGED_RC=%d\n' "$rc"
барьеров: 1 · фикстур: 23 · предъявлено красным повторным прогоном: 23
SCOPE_CHECK_STAGED_RC=0

$ bash scripts/verify_antiplacebo.sh . --scope check_zones; rc=$?; printf 'SCOPE_CHECK_ZONES_RC=%d\n' "$rc"
барьеров: 1 · фикстур: 19 · предъявлено красным повторным прогоном: 19
SCOPE_CHECK_ZONES_RC=0

$ bash scripts/verify_antiplacebo.sh . --scope spawn_agent; rc=$?; printf 'SCOPE_SPAWN_AGENT_RC=%d\n' "$rc"
барьеров: 1 · фикстур: 2 · предъявлено красным повторным прогоном: 2
SCOPE_SPAWN_AGENT_RC=0

$ bash scripts/check_zones.sh .; rc=$?; printf 'CHECK_ZONES_RC=%d\n' "$rc"
замороженных контрактов: 21 · объявленных авторов: 2 · коммитов в диапазонах: 531 · проверено по зонам: 363
CHECK_ZONES_RC=0

$ bash scripts/check_ids.sh .; rc=$?; printf 'CHECK_IDS_RC=%d\n' "$rc"
  ok   номера уникальны и согласованы с регистром выдачи
CHECK_IDS_RC=0

$ bash fixtures/spawn_agent/red_gejt_javnogo_nomera.sh; rc=$?; printf 'RED_SPAWN_RC=%d\n' "$rc"
Deleted tag 'id/CONTRACT/911' (was 52b946c)
RED_SPAWN_RC=0
$ bash fixtures/check_staged/red_dver_po_tegu.sh; rc=$?; printf 'RED_STAGED_RC=%d\n' "$rc"
Deleted tag 'id/CONTRACT/884' (was eafae04)
RED_STAGED_RC=0
$ bash fixtures/check_zones/red_priznanie_po_nomery_puti.sh; rc=$?; printf 'RED_ZONES_RC=%d\n' "$rc"
RED_ZONES_RC=0
```

## 5. Frozen

```text
$ bash scripts/check_contract_frozen.sh .; rc=$?; printf 'FROZEN_CHECK_RC=%d\n' "$rc"
  ok   contracts/023-rezervacija-nomera-dver-po-tegu.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают
планов и контрактов на HEAD: 26 · черновиков: 4 · заморожено: 22 · реестр: full
FROZEN_CHECK_RC=0

$ git diff --name-status 854d151..65f1f87 -- contracts plans; rc=$?; printf 'FROZEN_DELTA_RC=%d\n' "$rc"
A	contracts/022-pre-push-charter-i-bez-avtopusha.md
FROZEN_DELTA_RC=0
```

Единственный путь в этой дельте — новый контракт 022; это не изменение
существующего frozen-блоба. Проверка frozen выше отдельно и побайтно сверила
все 22 frozen-объекта с их тегами, включая 023.

## 6. Область и атомарность

Проверены сами грани фикса, а не только конечное дерево. Реальная цепочка 023
`da27fab → {125abb0,f2b4b65} → {ce4f256,df98885}` меняет только два
implementer-пути и два architect-пути. Они являются подмножеством frozen
ЗОНА-строк 023: `scripts/{spawn_agent,check_staged}.sh` у implementer и
`fixtures/spawn_agent/`, `NABLIUDENIA_ARCHITECT.md` у architect. Ни контракт,
ни другой нормативный документ не изменялись. Два рабочих коммита атомарны:
один закрывает кодовый блокер и названный косметический совет, второй добавляет
его независимый постоянный красный вход; merge-грани не добавляют постороннего.

```text
$ git diff-tree -r --no-commit-id --name-status 125abb0; rc=$?; printf 'IMPLEMENTER_EDGE_RC=%d\n' "$rc"
M	scripts/check_staged.sh
M	scripts/spawn_agent.sh
IMPLEMENTER_EDGE_RC=0

$ git diff-tree -r --no-commit-id --name-status f2b4b65; rc=$?; printf 'ARCHITECT_EDGE_RC=%d\n' "$rc"
M	NABLIUDENIA_ARCHITECT.md
A	fixtures/spawn_agent/red_gejt_manifest_tolko_na_origin.sh
ARCHITECT_EDGE_RC=0

$ git diff-tree -r -m --no-commit-id --name-status ce4f256 df98885; rc=$?; printf 'MERGE_EDGES_RECURSIVE_RC=%d\n' "$rc"
M	NABLIUDENIA_ARCHITECT.md
A	fixtures/spawn_agent/red_gejt_manifest_tolko_na_origin.sh
MERGE_EDGES_RECURSIVE_RC=0

$ git diff --name-status da27fab..df98885; rc=$?; printf 'CHAIN_DELTA_RC=%d\n' "$rc"
M	NABLIUDENIA_ARCHITECT.md
A	fixtures/spawn_agent/red_gejt_manifest_tolko_na_origin.sh
M	scripts/check_staged.sh
M	scripts/spawn_agent.sh
CHAIN_DELTA_RC=0
```

## Итог

Блокер `da27fab` закрыт воспроизводимым контрольным экспериментом с красным
контрпримером слабой формы. Прочие проверки моего круга 1 и frozen/zone
границы проходят. На этом основании — `accept`.
