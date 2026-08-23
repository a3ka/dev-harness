accept

# Ревьюер-круг 2: контракт 006 — финальный гейт

Проверен HEAD `ba87d27907f8ba9ad9770a556ea05d7f23a8690f`. Чужой код, приёмка и контракт не изменялись; этот коммит меняет только данный вердикт.

## Снятая находка круга 1

Предыдущий отказ о послезаморозочной правке приёмки не повторён. По решению владельца он относится к его домену заморозки; независимо перепроверены оба заявленных основания: механизм действительно контролирует только Markdown в `plans/` и `contracts/`, а прецедент 005 содержит существенные послезаморозочные изменения барьера и фикстур до `done`.

```text
$ bash scripts/check_contract_frozen.sh; printf 'exit=%s\n' "$?"
  ok   contracts/001-fikstura-antiplacebo.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают
  ok   contracts/002-approval-mode-steward.md — заморожен v7, блоб совпадает побайтово, вердикты v1..v7 разрешают
  ok   contracts/003-skills-metta-adaptacija.md — заморожен v6, блоб совпадает побайтово, вердикты v1..v6 разрешают
  ok   contracts/004-potolki-dokumentov.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают
  ok   contracts/005-avtonomija-proksi.md — заморожен v2, блоб совпадает побайтово, вердикты v1..v2 разрешают
  ok   contracts/006-scoped-izolirovannyj-gejt.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают
  ok   plans/005-four-mechanisms.md — черновик, не заморожен
  ok   plans/006-approval-mode-and-steward.md — черновик, не заморожен
  ok   plans/007-reglament-vorkflou.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают
  ok   plans/008-skills-metta-adaptacija.md — черновик, не заморожен

планов и контрактов на HEAD: 10 · черновиков: 3 · заморожено: 7 · реестр: full
exit=0

$ git diff --stat frozen/contracts/005/2 done/contracts/005/1 -- fixtures/ scripts/; printf 'exit=%s\n' "$?"
git diff --stat: 15 files +682 -87
.../check_metering/case_e_rebuild_konstanta.sh     |  32 +++
.../check_metering/case_i_rotaciya_kesh_starta.sh  |  32 +++
fixtures/check_metering/case_k1_codegen_import.sh  |  35 +++
.../check_metering/case_k1_dinamicheskii_import.sh |  31 +++
fixtures/check_metering/case_k1_vendor_import.sh   |  31 +++
fixtures/check_metering/case_k2_computed_spawn.sh  |  37 +++
fixtures/check_metering/case_k2_process_binding.sh |  36 +++
.../check_metering/case_k2_vneshnii_protsess.sh   |  33 +++
fixtures/check_metering/case_l_i_ieee754.sh        |  36 +++
fixtures/check_metering/case_l_o_tsena_po_model.sh |  35 +++
.../check_metering/case_l_p_period_kesh_starta.sh  |  32 +++
.../check_metering/case_m_korreljator_poterjan.sh  |  32 +++
fixtures/check_metering/case_z_sekret_v_faile.sh   |  46 ++++
fixtures/check_metering/case_zh_unpriced_200.sh    |  41 ++++
scripts/check_metering.sh                          | 280 ++++++++++++++-------
exit=0
```

The inspected freeze mechanism uses `git ls-tree ... -- ':(literal)plans/' ':(literal)contracts/'` and then limits its inventory to `*.md`; it has no fixture/barrier path. The prior failure is therefore resolved by the owner's stated interpretation and is not a new gate finding.

## Behavioural evidence

Before and after reproductions, stale test processes were stopped with:

```text
$ pkill -9 -f 'verify_antiplacebo|check_scop' || true
exit=0
```

All generated probe material was created by the checks beneath repository `tmp/`.

```text
$ bash scripts/check_scope_select.sh "$PWD"; printf 'exit=%s\n' "$?"
  ok   (а) неизвестный ключ отвергнут
  ok   (б) пустой --scope отвергнут
  ok   (в) неизвестный case отвергнут
  ok   (г) доки-only → needs-full код 2, маркер SCOPED:
  ok   (д) нерезолвимая база и не-git дерево → 2
  ok   (е) правка b → scoped, ровно ключ b
  ok   (ж) правка библиотеки → full
  ok   (з) add/delete/rename/смена-роли → full
  ok   (и) case-уровень выбирает ровно свой case
  ok   (к) scoped и needs-full помечены SCOPED: (неавторитетность — у потребителя)
  ok   (л) git-отсутствие (PATH без git) → код 2 + SCOPED:
  ok   (м) правка барьера, сорсимого другим барьером → full
  ok   (н) динамический source → full
  ok   (о) не-барьер как --scope ключ → код 1
  ok   (п) смена шапки/кода барьера → full
  ok   (р) source через переменную → full
  ok   (т) traversal в case → код 1
  ok   (у) mid-line source (после ;) → full
  ok   (ф) source через симлинк → full
  ok   (х) exec-ребро (bash b.sh) → full
  ok   (ц) видимый динамический source → full
  ok   (ч) имя цели в строке-литерале → full
  ok   (ш) имя цели только в полном комментарии → scoped
  ok   (щ) правка независимого барьера → scoped ровно он
check_scope_select: ветви «all» зелены
exit=0

$ bash scripts/verify_antiplacebo.sh "$PWD" --scope check_scope_select; printf 'exit=%s\n' "$?"
SCOPED: барьеров 1 из выборки — не для приёмки
  ok   check_scope_select/case_vetv_a_neizvestnyj_kljuch.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «принят»
  ok   check_scope_select/case_vetv_b_pustoj_scope.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «принят»
  ok   check_scope_select/case_vetv_c_dyncfg.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «невычислимая цель»
  ok   check_scope_select/case_vetv_ch_literal.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «по имени»
  ok   check_scope_select/case_vetv_d_baza_ne_rezolvitsja.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «fail-closed»
  ok   check_scope_select/case_vetv_e_suzhenie.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «не сужена»
  ok   check_scope_select/case_vetv_f_symlink.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «через ссылку»
  ok   check_scope_select/case_vetv_g_dokifull.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «ожидался 2»
  ok   check_scope_select/case_vetv_h_exec.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «выборка полная»
  ok   check_scope_select/case_vetv_i_case_uroven.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «не выбрал»
  ok   check_scope_select/case_vetv_k_marker.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «не напечатал машинный маркер»
  ok   check_scope_select/case_vetv_l_git_net_v_path.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «fail-closed»
  ok   check_scope_select/case_vetv_m_sourced.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «недобор»
  ok   check_scope_select/case_vetv_n_dynamic.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «не сужение»
  ok   check_scope_select/case_vetv_o_nebarrier.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «принят»
  ok   check_scope_select/case_vetv_p_header.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «не сужение»
  ok   check_scope_select/case_vetv_r_source_var.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «не-литеральным»
  ok   check_scope_select/case_vetv_shch_pozitiv.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «позитив жив»
  ok   check_scope_select/case_vetv_sh_comment.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «вычет комментариев»
  ok   check_scope_select/case_vetv_t_traversal.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «принят»
  ok   check_scope_select/case_vetv_u_midline.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «полной»
  ok   check_scope_select/case_vetv_v_neizvestnyj_case.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «принят»
  ok   check_scope_select/case_vetv_z_add_full.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «обязаны вести»
  ok   check_scope_select/case_vetv_zh_biblioteka_full.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «недобор»

барьеров: 1 · фикстур: 24 · предъявлено красным повторным прогоном: 24
exit=0

$ bash scripts/check_scoped_run.sh; printf 'exit=%s\n' "$?"
  ok   (л) фильтр: прогнан ровно выбранный b, RC=0
  ok   (м1) отказ «красное не предъявлено» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (м2) отказ «код 2 (нечем проверить)» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (м3) отказ «необъявленный код 7» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (н) отказ «дерево изменилось вне $WORK» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (case) --scope key/case прогоняет ровно 1 case, несуществующий case → fail-closed
  ok   (изол) HOME изолирован per-fixture: leak-игрушка отвергнута («красное не предъявлено»)
check_scoped_run: ветви «all» зелены
exit=0

$ bash scripts/check_zones.sh; printf 'exit=%s\n' "$?"
замороженных контрактов: 6 · объявленных авторов: 2 · коммитов в диапазонах: 171 · проверено по зонам: 113
exit=0

$ bash scripts/verify_ci_parity.sh; printf 'exit=%s\n' "$?"
workflow-команд: 19 · скриптов в приёмке: 31 · объявленных исключений: 12 · расхождений: 0
exit=0
```

## Independence of the new N acceptance tests

The source history shows that the new test/barrier commit was authored by `architect`, while the N implementation is the separate `implementer` commit:

```text
$ git show --no-ext-diff --format='commit=%H%nauthor=%an <%ae>%nsubject=%s' --name-status 85ce6f7 1aa64d1 21568bc; printf 'exit=%s\n' "$?"
commit=85ce6f7ce879ffad92d3deac08713bd2dc309434
author=implementer <implementer@dev-harness.local>
subject=006 арбитраж (ea138fb): инвариант N — N1 байт-скан имени цели (алиасы+симлинк-канонизация, вычет комментариев) + N2 source после разделителей→нелитеральный basename→full. Закрывает mid-line/симлинк/exec/cfg-динамику одним механизмом

M	scripts/scope_select.sh
commit=1aa64d16929d8b195aa072a1d9bfdd155dec3f1e
author=architect <architect@dev-harness.local>
subject=006 арбитраж (ea138fb): 7 приёмочных ветвей у–щ check_scope_select + 7 фикстур (mid-line/симлинк/exec/dyn-cfg/литерал → full; комментарий/независимый → scoped). Все 24 фикстуры красны против обмана

A	fixtures/check_scope_select/case_vetv_c_dyncfg.sh
A	fixtures/check_scope_select/case_vetv_ch_literal.sh
A	fixtures/check_scope_select/case_vetv_f_symlink.sh
A	fixtures/check_scope_select/case_vetv_h_exec.sh
A	fixtures/check_scope_select/case_vetv_sh_comment.sh
A	fixtures/check_scope_select/case_vetv_shch_pozitiv.sh
A	fixtures/check_scope_select/case_vetv_u_midline.sh
M	scripts/check_scope_select.sh
commit=21568bc8d307a4875d66d508238c8ee72fa3f183
author=architect <architect@dev-harness.local>
subject=NABLIUDENIA Н-45: метеринг k2 флейкует зелёный контроль на CI под контеншеном (d1cbb33); честный барьер локально зелён 27с, правка 006 инертна в полном прогоне — не дефект предмета

M	NABLIUDENIA.md
exit=0

$ git log --format='commit=%h author=%an subject=%s' -- scripts/check_scope_select.sh fixtures/check_scope_select/ | sed -n '1,6p'; printf 'exit=%s\n' "$?"
commit=1aa64d1 author=architect subject=006 арбитраж (ea138fb): 7 приёмочных ветвей у–щ check_scope_select + 7 фикстур (mid-line/симлинк/exec/dyn-cfg/литерал → full; комментарий/независимый → scoped). Все 24 фикстуры красны против обмана
commit=ac750a2 author=architect subject=006 круг 2 пробы: ветви check_scope_select п (шапка→full) / р (source-переменная→full) / т (case-traversal→1) + фикстуры красными
commit=ebd455c author=architect subject=006 адверсарий-пробы: ветви check_scope_select м/н/о (source-граф/динамика/не-барьер) + check_scoped_run изол (HOME per-fixture) + фикстуры красными; _ref_va зеркалит HOME-изоляцию; реворд шапки (bp→b)
commit=7a3ea8d author=architect subject=006: ремеди арбитра (7 пунктов) — (м)→м1/м2/м3 равенство кодов, (н) исполняемо, диспетчеры fail-closed, case-фильтр в раннере, SCOPED: на needs-full, git-отсутствие исполняемым тестом, (л) RC==0, §Предмет гарантия=проба. V1-V5 зелёные
commit=f206da7 author=architect subject=006: критик v2 обходы 1,4 — проба check_scope_select расширена (д+не-git, з A/D/R/роль), снят blacklist (к); контракт: тир2→check_scoped_run, зоны сведены. Тир2 проба СТРОИТСЯ
commit=bef4b43 author=architect subject=контракт 006 + проба check_scope_select + 10 красных фикстур (тир 1 предъявлен)
exit=0
```

The seven added fixture files were replayed directly. Each reports its green control and its red repeat against the deceptive stub, including the named reason:

```text
$ bash scripts/verify_antiplacebo.sh "$PWD" --scope check_scope_select/case_vetv_u_midline check_scope_select/case_vetv_f_symlink check_scope_select/case_vetv_h_exec check_scope_select/case_vetv_c_dyncfg check_scope_select/case_vetv_ch_literal check_scope_select/case_vetv_sh_comment check_scope_select/case_vetv_shch_pozitiv; printf 'exit=%s\n' "$?"
SCOPED: барьеров 1 из выборки — не для приёмки
  ok   check_scope_select/case_vetv_c_dyncfg.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «невычислимая цель»
  ok   check_scope_select/case_vetv_ch_literal.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «по имени»
  ok   check_scope_select/case_vetv_f_symlink.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «через ссылку»
  ok   check_scope_select/case_vetv_h_exec.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «выборка полная»
  ok   check_scope_select/case_vetv_shch_pozitiv.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «позитив жив»
  ok   check_scope_select/case_vetv_sh_comment.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «вычет комментариев»
  ok   check_scope_select/case_vetv_u_midline.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «полной»

барьеров: 1 · фикстур: 7 · предъявлено красным повторным прогоном: 7
exit=0
```

## N1/N2 and scope/CI audit

`verdicts/arbitration/source-porog-scoped.md` requires: (N1) a byte search of `k.sh` plus canonicalized `scripts/` symlink aliases in every other `scripts/*.sh` and `fixtures/*/*`, excluding only full-line comments, the target, and its own fixtures; and a full fallback for opaque/out-of-tree symlinks. It requires (N2) `source`/`.` detection at logical-line start and after `;`, `&&`, `||`, `|`, `&`, `(`, `{`, or backtick, with a nonliteral `.sh` basename forcing full. The inspected `scripts/scope_select.sh` implements those conditions in its N1-guard/N1 loop and `source_arg_lines`/`is_static_source` N2 checks, including the BASE-end N2 check. This matches the binding ruling; no variance was observed.

The commit-path audit above establishes atomic ownership and zone conformity for `85ce6f7` (only `scripts/scope_select.sh`, implementer), `1aa64d1` (only `scripts/check_scope_select.sh` plus seven `fixtures/check_scope_select/` files, architect), and `21568bc` (only `NABLIUDENIA.md`, architect). The general zone gate independently returned zero. Historical CI was checked through the live check-run API rather than a local re-run:

```text
$ bash scripts/check_ci_gate.sh "$PWD" 21568bc; printf 'exit=%s\n' "$?"
  ok   CI зелёный: проверок 1, все success, по 21568bc8d307 (a3ka/dev-harness)
exit=0
```

## Verdict

No new genuine finding remains. The owner-resolved freeze issue is not a basis for a second refusal. Contract 006 is accepted for `done/contracts/006/1`.
