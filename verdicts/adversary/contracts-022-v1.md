FAIL

# Суд 022 — pre-push charter / отсутствие автопуша

Судимая база: `main` `65f1f87569a5e64bf22982f4a4481bcf903ed7cd`; frozen-контракт: `27cca53`.
Проверка выполнялась только в одноразовом клоне `/tmp/adversary022/repo` на этой базе. Полный CI намеренно не запускался.

## Блокер: stale `origin/*` даёт обычный обход суда

**Класс: блокер.** В `.githooks/pre-push` диапазон задан безусловно как

```bash
git rev-list "$deref" --not --remotes=origin/*
```

То есть любой локальный `refs/remotes/origin/*` считается доказательством того, что коммит уже принят настоящим `origin`. Это неверно: remote-tracking ref — только локальный снимок и может быть stale, либо указывать на удалённую ветку, которой на origin уже нет.

Контрольный эксперимент был живым toy с file-path bare `origin`, настоящим хуком и настоящим импортированным кольцом. Я создал красный commit `contracts/001-x.md` без `РАЗРЕШИЛ`, записал его только в локальный `refs/remotes/origin/ghost`, отдельно проверил, что `refs/heads/ghost` в bare-origin отсутствует, после чего обычным (без `--no-verify`) `git push origin main` отправил этот commit.

```text
$ bash /tmp/adversary022/range_counterexamples.sh
stale_tracking_ghost rc=0 origin_main_is_bad=yes
```

Вывод push содержал обычное продвижение `main -> main`, без диагноза хука. Тем самым уставная дельта впервые попала на origin и не была осуждена; это прямой контрпример инварианту Н-86(б) «каждый устав-коммит судится раз при первом попадании на origin, обхода нет». Не требуется ни отсутствие PATH-инструмента, ни пустой вход, ни `--no-verify`.

Проверка `probe_push_svezhij_sverh_origin_umiraet.sh` покрывает лишь свежий commit, отсутствующий во *всех* локальных remote-tracking refs. Она не строит stale `origin/*`; поэтому действующая проверка принимает эту слабую реализацию.

**Требуемое исправление автором:** исключать только коммиты, действительно достижимые из актуального remote-side состояния выбранного destination remote/ref (либо передавать проверенный снимок), а не доверять произвольному локальному `refs/remotes/origin/*`; добавить живую case/пробу с ghost tracking ref и обычным push, которая обязана получить rc≠0, полный ref/SHA/path и неподвижный origin ref.

## Диапазоны: остальные контрольные эксперименты

| Вход / команда | rc | Наблюдение |
|---|---:|---|
| `bash fixtures/check_hooks/red_push_istoricheskij_legit_prohodit.sh` | 0 | Принятая origin-история не пересуживается. |
| `bash fixtures/check_hooks/probe_push_svezhij_sverh_origin_umiraet.sh` | 0 | Свежая дельта сверх нормального origin блокируется. |
| Обычный `push HEAD:refs/heads/wip/adversary` в том же live toy | 1 | Ветка `wip/*` не является незащищённой: хук отказал с полным ref/SHA/path. |
| Тот же commit, сначала `push --no-verify ...wip/adversary`, затем `fetch origin`, затем обычный push в `main` | `0; 0; 0` | После санкционированного контрактом обхода `--no-verify` в `main` диапазон пуст и commit проходит. Это известный, явно принятый контрактом post-push остаток, не самостоятельная находка этого суда. |
| `bash /tmp/adversary022/force_control.sh` | 0 (внутренний red push: 1) | Новый красный commit в force-rewrite отвергнут; origin остался на старом SHA, диагностика содержит SHA красного commit. |

Последняя строка — положительный контроль для force-грани. Ранее подготовленный диагностический toy намеренно не засчитывался: `reset --hard` удалил скопированный (и случайно закоммиченный) hook, поэтому push вернул 0/без вызова hook. Исправленный контроль копирует живой hook и кольцо после reset; приведён только его валидный результат.

## Genuine-конверсия и слабые формы

```text
$ bash scripts/check_hooks.sh . --scope check_hooks
rc=0

$ bash fixtures/check_hooks/probe_check_hooks_krasnyj.sh
ok: стаб честной формы (фазы 1-8) — все 11 case: зелёный контроль + красное повтором
ok: стаб хук-декой пойман на входе case_huk_ne_vedet_k_sude
ok: стаб установщик-декой пойман на входе case_bez_ustanovshhika
ok: стаб проба-слеп пойман на входе case_inert_heredoc_hook
ok: стаб ф1-декой пойман на входе case_huk_sniffer_toy
ok: стаб ф2-фикс-декой пойман на входе case_huk_forged_output
ok: механизм установки хука цел на живом дереве (pre-commit + pre-push)
rc=0
```

Scoped runner исполнил 11 конвертированных case, в том числе четыре `case_push_proba_{noop,bez_ref,bez_sha,bez_puti}` со своими стабами. `probe_check_hooks_krasnyj.sh` дополнительно подставил слабые формы на живом механизме и поймал декой неполной формы по именованным входам. Совет: добавить к этой же suite stale-`origin/*` контрпример из блокера — текущие диагонали полноты диагноза не проверяют истинность источника исключения диапазона.

## `razreshil` API и живое поведение hook

Все нижеследующие прямые red/probe-прогоны завершились `rc=0` против живого механизма:

```text
bash fixtures/check_hooks/red_check_hooks_bez_push_faz.sh
bash fixtures/check_hooks/red_push_dobavlenie_ustavnogo_svobodno.sh
bash fixtures/check_hooks/red_push_lechenie_ne_blokiruetsja.sh
bash fixtures/check_hooks/red_push_merge_gran_bez_stroki.sh
bash fixtures/check_hooks/red_push_nulevoj_ref_scoped.sh
bash fixtures/check_hooks/red_push_teg_annotirovannyj_suditsja.sh
bash fixtures/check_hooks/red_push_vetochnaja_gran_bez_merge.sh
bash fixtures/check_hooks/red_push_vtoroj_remote_sushhij_ref.sh
bash fixtures/check_hooks/red_push_istoricheskij_legit_prohodit.sh
bash fixtures/check_hooks/probe_push_svezhij_sverh_origin_umiraet.sh
bash fixtures/check_hooks/probe_check_hooks_krasnyj.sh
bash fixtures/land_agent/red_push_net_avtopusha.sh
```

Это подтверждает перечисленные положительные контроли (включая второй remote, annotated tag, лечение и именованную тройку), но не отменяет отдельный stale-ref обход выше.

## ОТКЛОНЕНИЕ `d8cd857`: `--no-verify` при land

**Вердикт отклонения: соответствует санкционированному направлению Н-82; не блокирует этот суд.**

Постоянные свидетельства проверены в судимом клоне:

```text
$ git show --no-patch --format='commit=%H author=%an committer=%cn subject=%s' d8cd857
commit=d8cd857e424273183ef269babc19bcd7b80aa9fc author=orchestrator committer=orchestrator subject=land: wip/022/architect

$ git show --no-patch --format='parents=%P' d8cd857
parents=f61248d... 1453cc4...

$ git diff-tree --no-commit-id -r --name-only d8cd857^1 d8cd857
NABLIUDENIA_ARCHITECT.md
fixtures/check_hooks/_mehanizm.sh
fixtures/check_hooks/case_push_proba_bez_puti.sh
fixtures/check_hooks/case_push_proba_bez_ref.sh
fixtures/check_hooks/case_push_proba_bez_sha.sh
fixtures/check_hooks/case_push_proba_noop.sh
fixtures/check_hooks/probe_check_hooks_krasnyj.sh
fixtures/check_hooks/probe_push_svezhij_sverh_origin_umiraet.sh
fixtures/check_hooks/red_push_istoricheskij_legit_prohodit.sh
fixtures/check_hooks/stab_push_proba_bez_puti.sh
fixtures/check_hooks/stab_push_proba_bez_ref.sh
fixtures/check_hooks/stab_push_proba_bez_sha.sh
fixtures/check_hooks/stab_push_proba_noop.sh
```

1. Committer — `orchestrator`.
2. Маркерное сообщение — ровно `land: wip/022/architect`; второй parent `1453cc4` имеет subject фикс-раунда architect. `MERGE_HEAD` по природе исчезает после завершения merge, поэтому непосредственно послефактум он не читаем; неизменяемые parent и marker являются сохраняющимся свидетельством заявленного `MERGE_HEAD=wip/022/architect`.
3. Все изменения относительно первого parent находятся в объявленной зоне architect 022: `fixtures/check_hooks/` и общий журнал `NABLIUDENIA_ARCHITECT.md` (зона перечислена в frozen contract, строки 202–203).

Пост-суд: `bash scripts/check_nabludenia.sh .` → `rc=0`; `bash scripts/check_hooks.sh . --scope check_hooks` → `rc=0`; перечисленные выше живые controls также зелёные. Следовательно, разовая санкция применена узко, с маркером и без выхода за зону. Совет: будущее устранение Н-82 должно оставить проверяемое постоянное свидетельство исходного `MERGE_HEAD`, а не только запись сессии.

## Остальные проверки базы

```text
$ bash scripts/check_charter.sh .
rc=0

$ git diff --quiet 27cca53..65f1f87 -- contracts/022-pre-push-charter-i-bez-avtopusha.md
rc=0

$ bash fixtures/land_agent/red_push_net_avtopusha.sh
rc=0
```

Код `scripts/land_agent.sh` также не содержит вызова `git push`; поведенческий toy подтверждает, что успешный land не двигает `origin/main`.

Итог `FAIL` обусловлен только обычным stale-remote-tracking обходом диапазона Н-86(б).