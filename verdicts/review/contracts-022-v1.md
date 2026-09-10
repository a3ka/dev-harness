accept

# Ревью контракта 022, финальный круг

Судимая база: `main` = `90bfc7ec500fcf99ccc73648ff4caa70bcb26ead`.
Frozen-контракт: `frozen/contracts/022/1` = `27cca53`. Все эксперименты и
прогоны выполнены в одноразовом клоне `/tmp/review022.90uagr`; основной
чекаут до записи этого вердикта не менялся. Полный прогон намеренно не
запускался: CI уже зелёный, а Н-48 предписывает судье scoped-регресс
затронутых барьеров и frozen-diff.

## 1. Блокер `c000ed1`: stale-зеркало закрыто

Контрольный эксперимент собственной формой выполнен против старого субъекта:
current fixture временно скопирована в одноразовый клон на `c000ed1`; её rc
зафиксирован до продолжения оболочки.

```text
$ bash fixtures/check_hooks/red_push_stale_zerkalo_iskljuchaet.sh
вход: RAND=r2040722611 ghost=ghost-r2040722611 vetka=vetka-r2040722611 ohrana=ohrana-r2040722611
вход: RED=49e17a83a3b7da95a1efb2c28023b199e2cadc72 HIST=158826b772b86a82a901275416fd70269289da2f TIP2=64ff08f9bdd9a330d9eb0569ab69b0a78272c2b7 TIP3=2452d59b7cc7927c994530c8a42aacdb47279291
ОТКАЗ: обход жив (блокер c000ed1, красное-до-реализации по А-107): красный коммит 49e17a83a3b7da95a1efb2c28023b199e2cadc72 ... исключён зеркалом refs/remotes=origin/* и уехал на origin обычным live push (rc=0, origin/vetka-r2040722611=64ff08f9bdd9a330d9eb0569ab69b0a78272c2b7).
RC=1
```

До `326a832` обход действительно жив: stale `origin/ghost` исключает
коммит, отсутствующий в живом origin, и обычный push его сажает.

После фикса та же fixture дважды прошла с разными входами:

```text
$ bash fixtures/check_hooks/red_push_stale_zerkalo_iskljuchaet.sh
вход: RAND=r1471112812 ghost=ghost-r1471112812 vetka=vetka-r1471112812 ohrana=ohrana-r1471112812
вход: RED=7c066a423f4579f0749d19d834b094d960698582 HIST=87c1f33e735591d7514abcb2ad65a1e877520f8b TIP2=5b851552d5d948dc24f3da0aa7eb1d625e1d8cd4 TIP3=70d546321d04ae053d65c76750ec2fec50d51bc3
RC=0

$ bash fixtures/check_hooks/red_push_stale_zerkalo_iskljuchaet.sh
вход: RAND=r60217601 ghost=ghost-r60217601 vetka=vetka-r60217601 ohrana=ohrana-r60217601
вход: RED=b0dbf375c86ba7b5626adee686ca4e5a73e7a2fc HIST=996e37f63b44540ba15169bc35fcc1e7ff244262 TIP2=2f991fef7d422dbe2cdf6773a24531d35dea2845 TIP3=d2f254a92ad7ef03ea8c2f2dd1bfc07911162afb
RC=0
```

Fixture сама требует отказа обычного live push с полной тройкой
`ref+sha+путь`, неподвижным origin-ref и зелёной охраной исторического
коммита из живого origin. Субъект ей соответствует: `.githooks/pre-push`
делает один `git ls-remote origin` до разбора push-строк, локальные
`refs/remotes/origin/*` в `LIVE_EXCLUDES` не участвуют.

## 2. Инвариант Н-86(б) и прямые red/probe

Исполненный цикл (без пайпов; останавливается на первом ненулевом rc):

```text
$ for f in fixtures/check_hooks/red_push_istoricheskij_legit_prohodit.sh fixtures/check_hooks/probe_push_svezhij_sverh_origin_umiraet.sh fixtures/check_hooks/red_check_hooks_bez_push_faz.sh fixtures/check_hooks/red_push_dobavlenie_ustavnogo_svobodno.sh fixtures/check_hooks/red_push_lechenie_ne_blokiruetsja.sh fixtures/check_hooks/red_push_merge_gran_bez_stroki.sh fixtures/check_hooks/red_push_nulevoj_ref_scoped.sh fixtures/check_hooks/red_push_teg_annotirovannyj_suditsja.sh fixtures/check_hooks/red_push_vetochnaja_gran_bez_merge.sh fixtures/check_hooks/red_push_vtoroj_remote_sushhij_ref.sh fixtures/check_hooks/probe_check_hooks_krasnyj.sh fixtures/land_agent/red_push_net_avtopusha.sh; do printf '\n=== %s ===\n' "$f"; bash "$f"; rc=$?; printf 'RC=%s\n' "$rc"; [ "$rc" -eq 0 ] || exit "$rc"; done
=== fixtures/check_hooks/red_push_istoricheskij_legit_prohodit.sh ===
вход: RAND=r78974766 ветка=feat-r78974766
RC=0
=== fixtures/check_hooks/probe_push_svezhij_sverh_origin_umiraet.sh ===
вход: RAND=r839913998 ветка=feat-r839913998
RC=0
=== fixtures/check_hooks/red_check_hooks_bez_push_faz.sh ===
RC=0
=== fixtures/check_hooks/red_push_dobavlenie_ustavnogo_svobodno.sh ===
RC=0
=== fixtures/check_hooks/red_push_lechenie_ne_blokiruetsja.sh ===
RC=0
=== fixtures/check_hooks/red_push_merge_gran_bez_stroki.sh ===
RC=0
=== fixtures/check_hooks/red_push_nulevoj_ref_scoped.sh ===
RC=0
=== fixtures/check_hooks/red_push_teg_annotirovannyj_suditsja.sh ===
RC=0
=== fixtures/check_hooks/red_push_vetochnaja_gran_bez_merge.sh ===
RC=0
=== fixtures/check_hooks/red_push_vtoroj_remote_sushhij_ref.sh ===
RC=0
=== fixtures/check_hooks/probe_check_hooks_krasnyj.sh ===
RC=0
=== fixtures/land_agent/red_push_net_avtopusha.sh ===
RC=0
```

Историческая допустимая дельта, достижимая из живого origin, проходит;
свежая красная сверх origin умирает внутри своей fixture, поэтому сама
fixture возвращает 0. Все остальные перечисленные заказчиком red/probe также
вернули 0.

## 3. Genuine-конверсия и красное предъявление

```text
$ bash scripts/verify_antiplacebo.sh --scope check_hooks
SCOPED: барьеров 1 из выборки — не для приёмки
  ok   check_hooks/case_bez_huka.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «механизм установки без хука»
  ok   check_hooks/case_bez_ustanovshhika.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «нет механизма установки»
  ok   check_hooks/case_huk_forged_output.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «не упомянут»
  ok   check_hooks/case_huk_kommentarij_vmesto_zapuska.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «хук не ведёт к судье»
  ok   check_hooks/case_huk_ne_vedet_k_sude.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «хук не ведёт к судье»
  ok   check_hooks/case_huk_sniffer_toy.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «поведенческая проба связи — чистый staged отклонён»
  ok   check_hooks/case_inert_heredoc_hook.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «поведенческая проба связи — pre-commit вернул rc=0»
  ok   check_hooks/case_push_proba_bez_puti.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «путь уставного файла не назван»
  ok   check_hooks/case_push_proba_bez_ref.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «без полного refs/heads/main»
  ok   check_hooks/case_push_proba_bez_sha.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «без полного sha красного коммита»
  ok   check_hooks/case_push_proba_noop.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «pre-push не судит или fail-open»
барьеров: 1 · фикстур: 11 · предъявлено красным повторным прогоном: 11
RC=0

$ bash fixtures/check_hooks/probe_check_hooks_krasnyj.sh
ok: стаб честной формы (фазы 1-8) — все 11 case: зелёный контроль + красное повтором
ok: стаб хук-декой пойман на входе case_huk_ne_vedet_k_sude
ok: стаб установщик-декой пойман на входе case_bez_ustanovshhika
ok: стаб проба-слеп пойман на входе case_inert_heredoc_hook
ok: стаб ф1-декой пойман на входе case_huk_sniffer_toy
ok: стаб ф2-фикс-декой пойман на входе case_huk_forged_output
ok: механизм установки хука цел на живом дереве (pre-commit + pre-push)
RC=0
```

Фаза 1 проверяет fixtures против честного стаба, а все поименованные слабые
формы предъявлены красной повторной фазой: проверка не подогнана под код.

## 4. Отклонение `d8cd857` (`land --no-verify`)

Сам `MERGE_HEAD` после завершения merge не существует; независимый
постоянный след — marker и родители:

```text
$ git show --no-patch --format='commit=%H%nauthor=%an <%ae>%ncommitter=%cn <%ce>%nparents=%P%nsubject=%s' d8cd857
commit=d8cd857e424273183ef269babc19bcd7b80aa9fc
author=orchestrator <orchestrator@dev-harness.local>
committer=orchestrator <orchestrator@dev-harness.local>
parents=f61248db0d8c41b04c71441905ecd96f6ec862a0 1453cc4609b2af798c8d5d698abaa0d3b4ff4a09
subject=land: wip/022/architect

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

Это подтверждает три узких условия Н-82: committer — `orchestrator`, второй
parent — `1453cc4` (сохранившаяся форма заявленного
`MERGE_HEAD=wip/022/architect`), staged-дельта только в
`fixtures/check_hooks/` и `NABLIUDENIA_ARCHITECT.md`, то есть frozen
architect-зоне 022. Marker ровно `land: wip/022/architect`.

Обе стороны общего журнала сохранены: итоговый
`NABLIUDENIA_ARCHITECT.md` содержит подряд `А-103` … `А-109`; пост-суд:

```text
$ bash scripts/check_nabludenia.sh
RC=0
```

Отклонение узко соответствует санкционированной Н-82 семантике; блокера нет.

## 5. Автопуш демонтирован

Собственный поиск в `scripts/land_agent.sh` по `git .*push|\bpush\b` не
вернул строк. Поведенческий toy:

```text
$ bash fixtures/land_agent/red_push_net_avtopusha.sh
RC=0
```

Код не содержит вызова `git push`; live toy подтверждает, что успешный
`land_agent` не продвигает `origin/main`.

## 6. Frozen и неизменность нормы

```text
$ bash scripts/check_contract_frozen.sh
  ok   contracts/022-pre-push-charter-i-bez-avtopusha.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают
планов и контрактов на HEAD: 26 · черновиков: 4 · заморожено: 22 · реестр: full
RC=0

$ git diff --name-only 27cca53 90bfc7e -- contracts plans
RC=0
```

Вторая команда не вывела путей. Значит дельта не трогает frozen `contracts/`
или `plans/`, в частности не переписывает текст 022 под код.

## 7. Область, зоны и атомарность

Frozen строки 202–203:

```text
ЗОНА architect: contracts/022-pre-push-charter-i-bez-avtopusha.md fixtures/check_hooks/ fixtures/land_agent/ NABLIUDENIA_ARCHITECT.md
ЗОНА implementer: scripts/land_agent.sh .githooks/ scripts/check_hooks.sh scripts/check_charter.sh
```

Собственная выборка путей для `9a8380c`, `6f6bf96`, `3c5e902`, `e30b1fb`,
`e2d5e47`, `9ff808a`, `1453cc4`, `326a832`, `8b8504e`, `b2329d3` дала ровно
`.githooks/pre-push`, разрешённые scripts, `fixtures/check_hooks/` и
`NABLIUDENIA_ARCHITECT.md`. Границы land:

```text
$ git diff-tree -m --no-commit-id -r --name-only --first-parent 6056524
.githooks/pre-push

$ git diff-tree -m --no-commit-id -r --name-only --first-parent 90bfc7e
NABLIUDENIA_ARCHITECT.md
fixtures/check_hooks/red_push_stale_zerkalo_iskljuchaet.sh
.githooks/pre-push

$ bash scripts/check_zones.sh
замороженных контрактов: 21 · объявленных авторов: 2 · коммитов в диапазонах: 537 · проверено по зонам: 366
RC=0
```

`f61248d` и `d8cd857` — marker-land границы; 022-стороны содержат
соответственно `.githooks/pre-push` и только architect-зону, показанную в
разделе 4. Остальные пути этих merge принадлежат уже сведённому предмету 023
либо процессному журналу; автор merge — orchestrator, это не выход
исполнителя из зоны. Каждая содержательная пачка имеет отдельный авторский
commit и отдельную marker-границу land; молча расширяющего задачу коммита нет.

## 8. Фикстуры не подогнаны после адверсария

```text
$ git diff --name-only c000ed1 90bfc7e -- fixtures/
fixtures/check_hooks/red_push_stale_zerkalo_iskljuchaet.sh

$ git log --format='%H %an <%ae> %s' c000ed1..90bfc7e -- fixtures/
8b8504e73bafe2f7085f87f153cbac7cb6fd842c architect <architect@dev-harness.local> architect: red-вход stale-грани зеркала (блокер c000ed1, фикс-раунд 3)
RC=0
```

Точная мера строже заявленного: после `c000ed1` fixture-дельта содержит
только новый stale-вход `8b8504e`; `b2329d3` меняет наблюдения, не fixture.
Фаза 1 и шесть named-decoy предъявлений выше дополнительно показывают, что
старые red-контроли не переписаны под реализацию.

## Scoped-регресс затронутых барьеров

```text
$ bash scripts/verify_antiplacebo.sh --scope check_hooks land_agent check_charter
SCOPED: барьеров 3 из выборки — не для приёмки
барьеров: 3 · фикстур: 28 · предъявлено красным повторным прогоном: 28
RC=0
```

Полный наблюдённый вывод содержал все 8 `check_charter`, 11 `check_hooks` и
9 `land_agent` fixture с зелёным контролем и повторным красным кодом 1.

## Находки

- **Блокеры:** нет.
- **Советы:** нет.

Вердикт: `accept`.
