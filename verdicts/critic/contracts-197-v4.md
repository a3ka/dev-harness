accept
OBJECT=b09f3a335bae59a010ae14071f976b5c787df3a7
СУД: репо=dev-harness; предмет=197; роль=critic; вызов=1/2; фаза=v4; модель-план=openai-codex/gpt-6.1-terra; модель-факт=openai-codex/gpt-6.1-terra (контекст запуска); предыдущий=нет (фаза v4 новая); класс риска=обычный

## Карта классов
К-01: чисто — check_sdacha.sh --run rc 0 и pre_critic.sh rc 0
К-02: чисто — слово владельца в OBJECT и побайтное cmp с продуктом 6513a2af rc 0
К-03: чисто — sverka_inventarja_143.sh до rc 0 и тег frozen/contracts/197/3 сохранён
К-04: чисто — вход diff 6d311c00e..OBJECT и раздел зон контракта
К-05: чисто — вход раздел приёмки контракта и команды W для модели и продукта
К-06: чисто — --stabs rc 0 включает отказы ORACLE_TAMPERED rc 2 в четырёх режимах
К-07: чисто — W --model и W --repo на продукте 6513a2af rc 0 по 29 из 29
К-08: чисто — W --stabs rc 0 и адресная мутация отключения запрета перезаписи красна e01
К-09: чисто — вход И-10 охвачен байтовым пином и адресной заменой guard
К-10: чисто — вход e01 сравнивает sha256 полных байтов и replay проверяет транспорт
К-11: чисто — cmp с оригиналом из независимого продуктового git и снимок агрегата 143
К-12: чисто — вход оригинальный node-скрипт и закреплённый оригинал агрегата 143
К-13: н/п — секреты не являются предметом локального транспорта
К-14: чисто — W --model rc 0 и W --repo продукт 6513a2af rc 0
К-15: чисто — --model 29 из 29 и --stabs 38 из 38 и сверка 143 шесть из шести
К-16: чисто — вход КЛАСС РИСКА и секция Модель угроз контракта 197
К-17: н/п — проектная архитектурная модель 188 не объявлена для этой дельты

## Блоки

Блокирующих находок нет.

## Свидетельства

`check_sdacha.sh . contracts/197-mob-ci-artefakty-lokalno.md --run`: rc 0, двери 4, карта 17/17, дельта 2. `pre_critic`, `check_spec_ready`, `check_ids`, `check_ceilings`, `check_provodka --grammar`, `check_precision_gate`, `check_threat_model`, `check_predposylki`: rc 0 каждый. Первоначальный составной вызов неверно передал аргументы `check_provodka --grammar` и остановился с rc 1; правильный вызов `bash scripts/check_provodka.sh --grammar . contracts/197-mob-ci-artefakty-lokalno.md` дал rc 0.

`W --model`: rc 0, 29/29. `W --stabs`: rc 0, стабов 38, непойманных 0. `W --repo` на модели с абсолютным и относительным путём и на архиве продукта 6513a2af: каждый rc 0, 29/29. `W --repo` на архиве fda1fc8: rc 1, 11 зелёных и 18 красных, e01 и replay `SKRIPT_NET`; это соответствует п.2 контракта, а не предположению о единственном красном пине. `sverka_inventarja_143.sh до`: rc 0, снимок совпал, 197 зелена 29/29, шесть красных 143 совпали поимённо.

Продуктовый оригинал и модель совпали побайтно (`cmp` rc 0); независимые sha256 обоих — `f40a5afc4d8263436714d2f81bb1973209decacbec5942e23db5aaf0e21c47ec`, как оба пина в source.json. Удалённый clone продукта отказал `Repository not found` rc 128, использован доступный локальный продуктовый git только на чтение. `verify_ci_parity.sh` на 6513a2af rc 1, 29 расхождений; `git diff --exit-code 19a8171 6513a2af -- .github package.json .harness/registry` rc 0, поэтому входы паритета относительно названной базы не изменились. Это не утверждение о зелёном паритете. OBJECT содержит дословное разрешение владельца; тег frozen/contracts/197/3 указывает на 9380a79dcbb8a9a5a5155e6b9ddd358f9678aa6d и в дельте не перемещался.

## Адресная атака

На копии модели стаб заменил существующий `if (zapis_zanyat(naznachenie)) {` на `if (false) {`, отключив отказ повторной записи. Команды: `python3 .scratch-crit197v4/stab_povtor.py .scratch-crit197v4/mutant` и `bash fixtures/workshop_project/mob_ci_artifacts_local_197/red_mob_ci_artifacts_local_197.sh --repo .scratch-crit197v4/mutant`. Сырой rc 1; полный вывод:

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
CASE e01-skript-pin KRASNO: SKRIPT_PIN_RASHOZHDENIE: fcf17b3f4a586ef532afecfb0ea629bb755a66385105945629374ed39627efc5 != f40a5afc4d8263436714d2f81bb1973209decacbec5942e23db5aaf0e21c47ec
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
клеток 29, зелёных 28, красных 1
```

Причина поимки — строгий байтовый пин, а не поведенческий replay И-10; это именно объявленный контрактом механизм. Стаб создан только в одноразовой копии.

## НЕ ЗАЩИЩАЕТ

До вливания 211 новые байты не находятся в основной ветке продукта: строгая e01 закономерно отвергает отличающийся старый скрипт; fda1fc8 ещё и не содержит скрипта. Ловцы срока и совместимости — станционная поставка до вливания и продуктовый CI после ленда, как в разрешении владельца и п.6 контракта.
