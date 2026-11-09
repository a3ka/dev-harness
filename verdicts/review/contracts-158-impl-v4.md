FAIL

OBJECT=2089cededdc1e41ee4464a923eb9f7080b90c724
КЛАСС=КОДОВЫЙ (КЛАСС РИСКА: обычный; ТРЕК набора: ПОЛНЫЙ)
СУД: repo=dev-harness (контракт frozen/contracts/158/3 → 033c3fa9); предмет=158; фаза=реализация (scoped, после ленда); роль=reviewer; сессия=Reviewer158RoundSeven; модель-план=@opus (config/agent_models.json roles.reviewer → tiers.audit) = anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5; вызов=6 (сверх капа 5 — слово владельца 2026-11-09 ~09:40, docs/owner/2026-11-09-arhitektura-i-poryadok-stancii.md п.3)
НЕЗАВИСИМОСТЬ: автор OBJECT — implementer (один коммит); ленд — orchestrator (71551fb1, PR #635); судья — reviewer, кода не правил; мутанты — в одноразовом worktree вне дерева.
НАХОДКИ: .review/2026-11-09-94.md — блоки Б-8 (architect v+1 → critic → freeze; повтор Б-7) и Б-9 (implementer/оркестратор, атомарность); советы С-15, С-16, С-17; повторы С-13, С-7, С-8, С-1; наблюдение О-1 (orchestrator). Закрыт С-14.

## Вердикт

FAIL. Код по своим строкам исполняется зелёно, все прогоны ниже дали rc 0. Блокируют две
вещи.

**Б-8 (= Б-7 Rev158r6, не закрыт).** Тег frozen/contracts/158/3 по тексту равен 158/2.
Критик v3 пишет об этом прямо: «текст == frozen/contracts/158/2 побайтово … Б-7 — маршрут
владельца на следующий v+1». Владелец 2026-11-09 ~09:40 распорядился: «158 — architect v+1
контракта/SPEC (Б-7 …)». Этого v+1 нет: на origin `wip/158/architect-r6` и `-r7` стоят на
ec495be2 (У-2), тега 158/4 нет. OBJECT при этом реализует правило «цель-иконка»
(`nadpis:null` ⇒ доступное имя хозяина вместо видимой надписи). Это видно в
`zond/nabor-zond-158.test.tsx:131-135`, `zond/helpery.ts:320-366`, клетках f34–f37, стабе st14
и новых причинах `KARTA_NADPIS_NE_SOVPALA`, `A11Y_IMJA_NE_OBYAVLENO`, `A11Y_IMJA_PUSTOE`.
Frozen И-2/И-1(г) и SPEC §4/§5 такого правила не знают: §6F кончается на f33, §7 — на st13.
Автор признаёт это в сообщении коммита: «Сам frozen/contracts/158/3 … этого правила ещё не
содержит».

Мой замер (F0 ниже): на честном mob-ref карта во frozen-формате (`nadpis` — строка) даёт
`shell-profile-entry 390|393 KRASNO NADPIS_NEVIDIMA`. Значит, зелёный `W --repo mob-ref`
держится на незамороженном правиле.

Адресат Б-8 — architect: v+1 по `/tmp/dev-harness-verify/orch/task-158-architect-vplus1.md`,
затем критик и freeze. Когда v+1 заморожен в нынешней форме, код ветки менять не нужно: мои
мутанты HZ1, HZ2, HZ4 пойманы своими клетками. Остаются С-15 и С-16.

**Б-9 (атомарность, норма 5).** OBJECT — один коммит на 68 файлов. В нём три задачи: батарея
по SPEC, гейт трека с ногой (д3) и расширение Б-7 вне frozen-текста. Контракт объединяет в
один коммит только гейт и ногу (§Порядок, И-6(д)). Атомарная история r6 (22 коммита, Б-5
закрыт Rev158r6) в main не попала: PR #621 закрыт без слияния. Из-за этого Б-7-расширение
нельзя откатить отдельно, а его судьба зависит от Б-8. Красное п.1 из истории main тоже не
воспроизводится. Я восстановил его сам (R-1 ниже).

СВЕРКА-СТАНДАРТОВ: не применимо — дифф в харнесе dev-harness (fixtures/ + scripts/);
документов docs/ARCHITECTURE.md / docs/CODING-STANDARDS.md продуктового бэкенда дифф не
касается; референсы mob-ref/ref-clean читаются, не правятся.

ПРОВОДКА (038): guard = `fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh`
существует. Это дверь именно этого предмета, побайтово равная тегу. CI-шаг 158 не подключён:
grep `ekrannyj_nabor_158` в `registry/ci-steps.tsv` и `.github/workflows/ci.yml` даёт 0 строк.
По контракту это окно оркестратора freeze..done, блоком accept реализации не считается.

## Проверки задания (сырой вывод, коды возврата)

Все команды выполнены в cwd `/tmp/dev-harness-verify/review-158-r7-1794249682` (HEAD = origin/main = 256c52dd, дерево OBJECT побайтово в зоне),
W = `bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh`; длинные прогоны шли через `reslop t --`.

```text
$ git merge-base --is-ancestor 2089cede HEAD                         → rc 0 (OBJECT в main; 71551fb1 = merge PR #635, второй родитель = OBJECT)
$ git diff --quiet frozen/contracts/158/3 HEAD -- contracts/158-ekrannyj-nabor.md \
    fixtures/workshop_project/ekrannyj_nabor_158/SPEC.md fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh   → rc 0
$ git diff --quiet frozen/contracts/158/3 2089cede -- (те же три пути)  → rc 0
$ git diff --quiet 033c3fa9 2089cede -- contracts/ fixtures/workshop_project/{gespraech_vhod_147,vkladki_tabov_148,gespraech_tekst_149,gespraech_otdacha_151,mob_ci_143,pustoj_produkt_159} scripts/sverka_maketa.py scripts/ekran_shablon.py scripts/check_pustoj_produkt.sh → rc 0
$ git diff --quiet 71551fb1^1 71551fb1 -- . ':!fixtures/workshop_project/ekrannyj_nabor_158' ':!scripts/check_trek_ekrana.sh' ':!scripts/pre_critic.sh' → rc 0
$ git diff --name-only 033c3fa9 2089cede | wc -l → 68; вне каталога набора — только scripts/check_trek_ekrana.sh, scripts/pre_critic.sh (ЗОНА implementer)
$ git diff 033c3fa9 2089cede -- scripts/pre_critic.sh → только нога (д3) после (д2) + 4 строки шапки (ПЕРЕСЕЧЕНИЕ 072/094/095/103/122/996 соблюдено)
$ reslop t -- bash scripts/check_zones.sh → exit 0 (ok: true, passed 98, failed 0; «замороженных контрактов: 158 · … проверено по зонам: 12283»)

$ reslop t -- bash W                → exit 0; «клеток 40, зелёных 40, красных 0» (wall 407 s)
$ reslop t -- bash W --model        → exit 0; «клеток 37, зелёных 37, красных 0» (wall 440 s)
$ reslop t -- bash W --stabs        → exit 0; «клеток 37, зелёных 37, красных 0»; 14 строк «STAB <файл> KRASEN»; «SVJAZI 29» (wall 535 s)
      PROSHYOL на отдельной связи: st03→b07, st06→e01 (каждый стаб пойман хотя бы на одном своём входе — SPEC §7 :446)
      st14-zond-bez-a11y.py: f34 KRASEN, f36 KRASEN, f37 KRASEN
$ reslop t -- bash W --repo /tmp/dev-harness-verify/Arch148t/mob-ref    → exit 0; «клеток 78, зелёных 78, красных 0» (wall 753 s); f00–f02, f34–f37, c05, g08 ok
$ reslop t -- bash W --repo /tmp/dev-harness-verify/Arch147t/ref-clean  → exit 0; «клеток 78, зелёных 78, красных 0» (wall 722 s)
$ bash scripts/check_trek_ekrana.sh . contracts/158-ekrannyj-nabor.md   → rc 0, «ТРЕК ЛЁГКИЙ (по умолчанию)» (С-1, повтор)

CI PR #635 (gh api …/commits/2089cede…/check-runs; run 42669260030, event pull_request, headSha 2089cede): 16 success, 1 skipped (vorota: if push) — зелёный.
CI main push 256c52dd (run 42675792627) — success. CI батарею 158 не прогоняет: grep ekrannyj_nabor_158 registry/ci-steps.tsv .github/workflows/ci.yml → 0.
```

### Счёты — моей мерой (вторая мера: source.json, не вывод батареи)

```text
$ python3 -c '… json.load(source.json) …'
vsego 78        ← = клеток --repo (78/78 на обоих референсах)
bez_F_c05 40    ← = клеток безфлагового W (40)
F 37            ; --model: 40 − {z01, z02, g08} = 37 ← = клеток --model (37)
stab 14 svjazi 29 ← = 14 строк «STAB … KRASEN» и «SVJAZI 29»
Перепись SPEC против оракула: вне SPEC — a14 (С-7), f34, f35, f36, f37 и st14 (Б-8); пропусков SPEC→оракул нет.
```

### Красное: гейт трека, нога (д3) (моя мера, worktree OBJECT вне дерева)

```text
R-1 (п.1: гейта нет) rm scripts/check_trek_ekrana.sh:  z01 rc 2 SUBJECT_ABSENT «scripts/check_trek_ekrana.sh в дереве отсутствует»; z02 rc 1 «ЖИВАЯ ДВЕРЬ НА РИСК-ЭКРАНЕ: rc=0 (ожидался 1)»
G1 (гейт всегда rc 0):                                 z01 rc 1 NE_SOVPAL_S_SUBJEKTOM; z02 rc 1 (то же)
L1 (нога (д3): `|| refuse` → `|| true`):                z01 rc 0 (не её предмет); z02 rc 1 «ЖИВАЯ ДВЕРЬ НА РИСК-ЭКРАНЕ: rc=0»
```

### Ветка цели-иконки — мои мутанты (зонд набора на одноразовых копиях mob-ref)

Мутанты хелпера (со сменой пина зонда в source.json копии, иначе ORACLE_TAMPERED `ORAKUL_PIN:NE_SOVPAL:zond/helpery.ts`):

```text
HZ1 (снят KARTA_NADPIS_NE_SOVPALA):        f35 → «ОЖИДАЛАСЬ ПРИЧИНА KARTA_NADPIS_NE_SOVPALA, ФАКТ: NADPIS_NEVIDIMA» — ПОЙМАН; f00 ok
HZ2 (не проверяется trim объявленного):    f37 → «ОЖИДАЛАСЬ ПРИЧИНА A11Y_IMJA_PUSTOE, ФАКТ: NADPIS_NEVIDIMA» — ПОЙМАН; f00 ok
HZ4 (необъявленное имя → null):            f36 → «ОЖИДАЛАСЬ ПРИЧИНА A11Y_IMJA_NE_OBYAVLENO, ФАКТ: —» — ПОЙМАН; f00 ok
HZ3 (`imya !== obyavlenie` → `false`):     f34 ok, f35 ok, f36 ok, f37 ok, f00 ok — ЖИВ (С-15)
```

Мутанты продукта/карты (зонд на копии, без смены кода набора):

```text
K0 контроль:                                   zond=10 ne_ok=0
F0 frozen-формат (`nadpis` строка у иконки):    shell-profile-entry 390|393 KRASNO NADPIS_NEVIDIMA   (Б-8)
R1 имя перенесено на дочерний Svg:              shell-profile-entry 390|393 KRASNO NADPIS_NEVIDIMA
R2 имя хозяина + хвостовой пробел:              shell-profile-entry 390|393 KRASNO NADPIS_NEVIDIMA
R3 вкладка start: карта nadpis:null+«Start», надписи вкладок opacity 0, хозяину accessibilityLabel="Start":
                                                start — ok; vorgaenge/schutz/post 390|393 KRASNO NADPIS_NEVIDIMA  (С-16)
R4 вкладка start объявлена иконкой при видимой надписи: shell-tab-start 390|393 KRASNO KARTA_NADPIS_NE_SOVPALA
R5 карта: nadpis "" у текстовой цели:           shell-tab-start 390|393 KRASNO A11Y_IMJA_PUSTOE  (С-17)
```

## Паразитная сложность (контракт 050) — дельта, которую суд видит впервые (r6 → OBJECT)

Ответы на пять вопросов: (1) свойство; (2) состояние; (3) сколько файлов меняется вместе;
(4) глубина; (5) потребитель.

- `a11yNadpis(hozjain, karta, shirina, vysota)` + `KartaCel` + константы причин
  (`zond/helpery.ts`, +45/−14). (1) Во frozen 158/3 свойства нет (Б-8), его требует только
  незамороженный v+1. (2) Состояние явное: поля карты `nadpis`/`accessibilityLabel`, причина
  попадает в трассу. (3) helpery.ts, зонд и probe.py (имена причин записаны дважды: TS и
  `probe.py:82-84`) — три файла. Копия хелпера st14 удалена, так что число не выросло, а
  упало (С-14). (4) Одна функция с четырьмя ветвями, интерфейс узкий. (5) f34–f37 и st14.
  Судьба артефакта — вместе с Б-8, отдельной находки 050 нет.
- `a11y_obrazec`, `stanciya_obrazca`, `cel_karty`, клетки `k_f35`–`k_f37` (`probe.py`,
  +131). (1) Образцы M2–M4 из задания architect v+1, во frozen их нет (Б-8). (2) Явное:
  фазы передаются аргументом, ожидание держится в памяти, контроль идёт до мутации. (3) Каждый
  новый образец — 1 файл плюс строка оракула. (4) Глубокий: один интерфейс фаз на три клетки.
  (5) Строки оракула f35–f37. Судьба — с Б-8.
- `model/mutanty/profil-pustoe-imja.py` (+32). Повторяет грамматику `_mutator.primenit`, свою
  логику не заводит. Судьба — с Б-8.
- `stubs/st14-zond-bez-a11y.py` (переписан, −337 строк копии). ESSENTIAL в пределах Б-8:
  один якорь вместо полной копии. С-14 закрыт.

Новых флагов, env-переменных и каталогов состояния дельта не вводит.
