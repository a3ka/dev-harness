FAIL

OBJECT=0abf3c086791e97fcfa72af3ac97257c04434edc
СУД: repo=dev-harness; предмет=197; фаза=контракт v3 до заморозки; роль=critic; вызов=один узкий по слову владельца 2026-11-18 ~18:10 UTC, с сохранением прежнего счёта; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit197V8; модель-факт=openai-codex/gpt-6.1-terra (models_actual --bind: allowed); SHA=0abf3c086791e97fcfa72af3ac97257c04434edc; предыдущий=Crit197V7 FAIL, OBJECT 30816f1373b485a6e92c5fccaa0a9b0903295792; исключение=слово владельца батч №3 №1.

БЛОКИРУЕТ contracts/197-mob-ci-artefakty-lokalno.md:26,79; fixtures/workshop_project/mob_ci_artifacts_local_197/source.json:175 — закреплённый baseline отличается от конкретно названного в слове владельца.
ОБЯЗАТЕЛЬСТВО: слово владельца батча №3 №1, через дословную строку `/tmp/dev-harness-verify/station-batch2-1118.md` §9, разрешает адресную правку с привязкой красного-до к `frozen/contracts/143/4`; изменение замороженного текста вне разрешения не допускается. Вызов разрешён, но его наличие само по себе не заменяет конкретную границу правки.
СОСТОЯНИЕ: кандидат вместо этого требует commit `9d3ad2bea4f1f15be15a9d975966bb20451a9a54`, tree `89ccddf8281b15842eda6aa1a316bdde579845ee`. `git rev-parse 'frozen/contracts/143/4:fixtures/workshop_project/mob_ci_143' '9d3ad2bea4f1f15be15a9d975966bb20451a9a54:fixtures/workshop_project/mob_ci_143'` rc 0 возвращает соответственно `3ae3257d793d1bf2b1c8ffaad0203af128ae365c` и `89ccddf8281b15842eda6aa1a316bdde579845ee`. Сдаточный лист :4–7, :70–73 прямо называет замену baseline; там же указано, что frozen/143/4 даёт четыре, а не шесть красных.
НАБЛЮДЕНИЕ: это не идентичный закреплённый объект; назначенное владельцем состояние красного-до в приёмке отсутствует. Строка РАЗРЕШИЛ в теле OBJECT грамматична, но касается согласования имён child-evidence и отдельно оговаривает 143 v+1, а не замену указанного во втором слове baseline. Свойство закрытия: приёмка соответствует явно разрешённому baseline либо имеется адресное решение владельца на иную закреплённую версию без ослабления шестиклеточного обязательства; до разрешения противоречия freeze не допускать.
ПРОИСХОЖДЕНИЕ: дельта
КЛАСС: К-02

## Проверки

В одноразовом ssh-клоне на OBJECT выполнены `git fetch --tags origin` rc 0, команды `--model` и `--stabs` ниже rc 0. Двери и сдаточный лист повторно не запускались по заданию. Проверка дерева выполнена командой, указанной в блоке. Отдельная подмена или повтор ранее сообщённого прогона `proverka_sverki_143.sh` не выполнялись; наблюдения автора об этих клетках не выдаются за собственный прогон. Код проверки и привязки клеток прочитаны; область суда ограничена дельтой 143/197.

`bash fixtures/workshop_project/mob_ci_artifacts_local_197/red_mob_ci_artifacts_local_197.sh --model`, rc 0, сырой вывод:
```text
CASE a01-upload-artefakt-ostalsja ok
CASE a02-download-artefakt-ostalsja ok
CASE a03-gh-kanal-v-run ok
CASE b01-forma-pisatelja ok
CASE b02-imja-pisatelja-razreshimo ok
CASE b03-pisatel-s-run-argumentom ok
CASE c01-forma-chitatelja ok
CASE c02-imja-bez-pisatelja ok
CASE c03-run-para-iz-sborki ok
CASE d01-koren-vne-skripta ok
CASE d02-vyhod-za-koren ok
CASE e01-skript-pin ok
CASE e02-linei-npm ok
CASE g01-forma-nositelja ok
CASE g02-rabochij-katalog-nositelja ok
CASE i01-nositel-ispolnim ok
CASE i02-zamknutyj-inventar ok
CASE r01-krug-zapisi-chtenija ok
CASE r02-popytka-prodjusera ok
CASE r03-imja-pobeg ok
CASE r04-imja-razdelitel ok
CASE r05-run-nechislovoj ok
CASE r06-nepolnaja-identifikacija ok
CASE r07-shablon-sbor ok
CASE r08-istochnik-otsutstvuet ok
CASE r09-izoljacija-popytok ok
CASE r10-shablon-pusto ok
CASE r11-tochnoe-imja-otsutstvuet ok
CASE s01-styk-sbor-agregat ok
клеток 29, зелёных 29, красных 0
```

`bash fixtures/workshop_project/mob_ci_artifacts_local_197/red_mob_ci_artifacts_local_197.sh --stabs`, rc 0, сырой вывод:
```text
CASE a01-upload-artefakt-ostalsja ok
CASE a02-download-artefakt-ostalsja ok
CASE a03-gh-kanal-v-run ok
CASE b01-forma-pisatelja ok
CASE b02-imja-pisatelja-razreshimo ok
CASE b03-pisatel-s-run-argumentom ok
CASE c01-forma-chitatelja ok
CASE c02-imja-bez-pisatelja ok
CASE c03-run-para-iz-sborki ok
CASE d01-koren-vne-skripta ok
CASE d02-vyhod-za-koren ok
CASE e01-skript-pin ok
CASE e02-linei-npm ok
CASE g01-forma-nositelja ok
CASE g02-rabochij-katalog-nositelja ok
CASE i01-nositel-ispolnim ok
CASE i02-zamknutyj-inventar ok
CASE r01-krug-zapisi-chtenija ok
CASE r02-popytka-prodjusera ok
CASE r03-imja-pobeg ok
CASE r04-imja-razdelitel ok
CASE r05-run-nechislovoj ok
CASE r06-nepolnaja-identifikacija ok
CASE r07-shablon-sbor ok
CASE r08-istochnik-otsutstvuet ok
CASE r09-izoljacija-popytok ok
CASE r10-shablon-pusto ok
CASE r11-tochnoe-imja-otsutstvuet ok
CASE s01-styk-sbor-agregat ok
клеток 29, зелёных 29, красных 0
STAB stab_a01_upload_ostalsja KRASEN: a01-upload-artefakt-ostalsja: UPLOAD_ARTIFAKT_OSTALSJA
STAB stab_a03_gh_ostalsja KRASEN: a03-gh-kanal-v-run: GH_KANAL_V_RUN
STAB stab_b01_argumenty KRASEN: b01-forma-pisatelja: FORMA_PISATELJA
STAB stab_c01_nepolnaja KRASEN: c01-forma-chitatelja: NEPOLNAJA_IDENTIFIKACIJA_RUNA
STAB stab_c02_chtenie_bez_pisatelja KRASEN: c02-imja-bez-pisatelja: IMJA_BEZ_PISATELJA
STAB stab_c03_bez_pary KRASEN: c03-run-para-iz-sborki: CHITATEL_APK_BEZ_PARY
STAB stab_c03_run_para_literal KRASEN: c03-run-para-iz-sborki: RUN_PARA_NE_IZ_SBORKI
STAB stab_d01_put_bez_popytki KRASEN: d01-koren-vne-skripta: KOREN_VNE_SKRIPTA
STAB stab_d02_vyhod_za_koren KRASEN: d02-vyhod-za-koren: VYHOD_ZA_KOREN
STAB stab_g01_chtenie_s_true KRASEN: g01-forma-nositelja: FORMA_NOSITELJA_VNE_GRAMMATIKI
STAB stab_g01_ekranirovannaja_kavychka KRASEN: g01-forma-nositelja: FORMA_NOSITELJA_VNE_GRAMMATIKI
STAB stab_g01_kavochnaja_para KRASEN: g01-forma-nositelja: FORMA_NOSITELJA_VNE_GRAMMATIKI
STAB stab_g01_khvost_argumentov KRASEN: g01-forma-nositelja: FORMA_NOSITELJA_VNE_GRAMMATIKI
STAB stab_g01_ohrana_do_vyzova KRASEN: g01-forma-nositelja: FORMA_NOSITELJA_VNE_GRAMMATIKI
STAB stab_g01_perenos_posle_operatora KRASEN: g01-forma-nositelja: FORMA_NOSITELJA_VNE_GRAMMATIKI
STAB stab_g01_podavlenie_posle KRASEN: g01-forma-nositelja: FORMA_NOSITELJA_VNE_GRAMMATIKI
STAB stab_g01_povtor_kljucha KRASEN: g01-forma-nositelja: FORMA_NOSITELJA_VNE_GRAMMATIKI
STAB stab_g01_sputnik_cp KRASEN: g01-forma-nositelja: FORMA_NOSITELJA_VNE_GRAMMATIKI
STAB stab_g02_kljuch_otsutstvuet KRASEN: g02-rabochij-katalog-nositelja: NOSITEL_BEZ_WORKING_DIRECTORY
STAB stab_i01_if_false KRASEN: i01-nositel-ispolnim: NOSITEL_NEISPOLNIM
STAB stab_i01_job_if_false KRASEN: i01-nositel-ispolnim: JOB_NOSITELJA_OTKLJUCHEN
STAB stab_i01_job_if_never KRASEN: i01-nositel-ispolnim: JOB_NOSITELJA_OTKLJUCHEN
STAB stab_i01_job_provaly KRASEN: i01-nositel-ispolnim: PROVALY_PODAVLENY
STAB stab_i01_provaly_podavleny KRASEN: i01-nositel-ispolnim: PROVALY_PODAVLENY
STAB stab_i01_strategija_provaly KRASEN: i01-nositel-ispolnim: PROVALY_PODAVLENY
STAB stab_i02_heredok_nositel KRASEN: i02-zamknutyj-inventar: KATEGORIJA_BEZ_PISATELJA
STAB stab_r09_skript_bez_popytki KRASEN: r09-izoljacija-popytok: POPYTKI_SLILIS
STAB stab_r10_shablon_padaet KRASEN: r10-shablon-pusto: SHABLON_PUSTO_OTKAZ
STAB stab_r11_imja_ticho KRASEN: r11-tochnoe-imja-otsutstvuet: TOCHNOE_IMJA_TICHO_PROSHLO
STAB stab_s01_bez_pary KRASEN: s01-styk-sbor-agregat: STYK_AGREGATA_OTKAZ
стабов 30, непойманных 0
```

## Карта классов

К-01: чисто — вход: текст п.8, сдаточный лист и грамматика строки в теле OBJECT; двери по заданию не повторялись.
К-02: блок — baseline расходится с буквальным словом владельца.
К-03: чисто — вход: п.1 сохраняет обязательный 143 v+1 и отдельную приёмку на кандидате и frozen; ограничение слова владельца отмечено К-02.
К-04: чисто — вход: пять изменённых файлов в зоне architect, зоны и пересечения не менялись.
К-05: чисто — вход: п.8 называет исполнимые команды и rc для двух режимов.
К-06: чисто — вход: `sverka_inventarja_143.sh` ветви проверки отсутствующего commit и несовпадения tree дают именованный rc 2.
К-07: чисто — вход: режимы до/после извлекают явные источники независимо от соседнего каталога; воспроизводимость на выбранном baseline заявлена автором, иной baseline блокирован К-02.
К-08: чисто — вход: `proverka_sverki_143.sh` связывает в коде проверки с rc и диагностикой; `--stabs` rc 0, 30 поймано.
К-09: чисто — вход: `sverka_inventarja_143.sh` принимает до, после --ref и после --dir; контроль эквивалентных источников в коде проверки.
К-10: чисто — вход: код сверяет полный список красных, rc и наличие непустой сводки.
К-11: чисто — вход: source.json загружается до исполнения проверяемой батареи, baseline извлекается из git по commit/tree.
К-12: чисто — вход: запускается настоящий runner 143 из git archive или явного каталога.
К-13: н/п — секреты не предмет адресной дельты.
К-14: чисто — вход: контроль после по ref и эквивалентному каталогу записан в коде проверки.
К-15: чисто — `--model` rc 0 29/29, `--stabs` rc 0 30/30; расхождение tree показано в блоке.
К-16: чисто — вход: дельта не изменяет заявленный обычный риск или модель угроз.
К-17: н/п — проектная архитектурная модель 188 не изменяется.

## Развилки

Определение допустимой замены прямо названного владельцем baseline — решение владельца, не решение критика. Данный вердикт не разрешает новый вызов.
