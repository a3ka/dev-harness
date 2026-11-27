accept
OBJECT=1eac9b927baa02741e12640e2267865c7c99010c
СУД: репо=dev-harness; предмет=232; фаза=контракт; роль=critic; вызов=3 (узкий, по праву консультанта; исполнение Arb232); сессия=Crit232cDay; модель-факт=openai-codex/gpt-6.1-terra; автор Architect232d — openai-codex/gpt-6.1-sol.

## Область и решение

Судилось только исполнение `verdicts/arbitration/contracts-232-b1.md`, не повторный полный проход. Crit232b К-08 закрыт: модель различает сырые рабочие и индексные байты после обычного add, финальная дверь отказывает, оба честных соседа допускаются. `fixtures/workshop_project/karta_krome_232/build.py:171–173` связывает st30 именно с возвратом фильтрующего `hash-object --`, а не `--path`; `probe.py:319–334` вызывает дверь до add и после add, при отказе не коммитит. Остаточная конкурентная подмена после двери названа прежней границей, новый риск text-фильтров не принят.

Diff 193 относительно прошлого OBJECT ограничен абзацем черновика v+1; git log показал в теле f875c2f6183b1c51755c6690e8955c35f44500eb строку `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/193-svyazka-sdatochnyj-list.md — R-0168 ...` первой колонкой. Старые батареи 193/224 не изменены. `bash scripts/models_actual.sh --tsv --bind --session Crit232cDay` и та же команда для Architect232d rc 0: разрешённые Terra и Sol соответственно. Remote origin в копии не настроен; OBJECT имелся локально и checkout выполнен по полному SHA. Санкция на OBJECT дана в задании; самостоятельный ledger в копии не найден.

## Карта классов

К-01: чисто — вход: без изменений с вызова 2.
К-02: чисто — вход: без изменений с вызова 2.
К-03: чисто — вход: diff 193 и регресс 193/224.
К-04: чисто — вход: context.py rc 0 и зона 193 контракта 232.
К-05: чисто — вход: без изменений с вызова 2.
К-06: чисто — вход: без изменений с вызова 2.
К-07: чисто — вход: reproduce.py до/после и честные staged-соседи.
К-08: чисто — вход: index_filter.py до/после и адресный st30.
К-09: чисто — вход: без изменений с вызова 2.
К-10: чисто — вход: снимки индекса, рабочих байтов и HEAD в index_filter.py.
К-11: чисто — вход: без изменений с вызова 2.
К-12: чисто — вход: без изменений с вызова 2.
К-13: н/п — секретные входы не вводятся.
К-14: чисто — вход: LF/text и CRLF/raw приняты до и после add.
К-15: чисто — вход: catalog и проход модели и стабов.
К-16: чисто — вход: contracts/232 модель угроз, риск штатных text-фильтров не объявлен принятым.
К-17: н/п — продуктовая модель 188 не объявлена.

## Воспроизведения

`python3 -B fixtures/workshop_project/karta_krome_232/index_filter.py --before` и без `--before`, затем `reproduce.py --before` и без: цепочка rc 0. Снимки каждого вызова проверяли неизменность HEAD, индексной записи и рабочего файла. Существенный сырой вывод:

```text
ДО pj-index-text-normalized unstaged rc= 0 stdout= b'VERDICT_BRANCH=wip/178/critic\n' stderr= b''
ДО pj-index-text-normalized staged= b'be050a1b0a0be911950356926920c3d927559d0a\n' raw= b'b73f98cb5211388f1a4599047b5b511e15cc151d\n'
ДО pj-index-text-normalized staged rc= 0 stdout= b'VERDICT_BRANCH=wip/178/critic\n' stderr= b''
ПОСЛЕ pj-index-text-normalized unstaged rc= 0 stdout= b'VERDICT_BRANCH=wip/178/critic\n' stderr= b''
ПОСЛЕ pj-index-text-normalized staged= b'be050a1b0a0be911950356926920c3d927559d0a\n' raw= b'b73f98cb5211388f1a4599047b5b511e15cc151d\n'
ПОСЛЕ pj-index-text-normalized staged rc= 1 stdout= b'' stderr= b'\xd0\x9e\xd0\xa2\xd0\x9a\xd0\x90\xd0\x97: KARTA_NE_SHTATNA\n\xd0\xba\xd0\xb0\xd1\x80\xd1\x82\xd0\xb0 \xd0\xbd\xd0\xb5 \xd1\x88\xd1\x82\xd0\xb0\xd1\x82\xd0\xbd\xd0\xb0\xd1\x8f: \xd0\xb8\xd0\xbd\xd0\xb4\xd0\xb5\xd0\xba\xd1\x81 \xd0\xbe\xd1\x82\xd0\xbb\xd0\xb8\xd1\x87\xd0\xb0\xd0\xb5\xd1\x82\xd1\x81\xd1\x8f \xd0\xbe\xd1\x82 --file\n'
pj-index-text-lf unstaged rc= 0 stdout= b'VERDICT_BRANCH=wip/178/critic\n' stderr= b''
pj-index-text-lf staged= b'be050a1b0a0be911950356926920c3d927559d0a\n' raw= b'be050a1b0a0be911950356926920c3d927559d0a\n'
pj-index-text-lf staged rc= 0 stdout= b'VERDICT_BRANCH=wip/178/critic\n' stderr= b''
pj-index-crlf-raw unstaged rc= 0 stdout= b'VERDICT_BRANCH=wip/178/critic\n' stderr= b''
pj-index-crlf-raw staged= b'b73f98cb5211388f1a4599047b5b511e15cc151d\n' raw= b'b73f98cb5211388f1a4599047b5b511e15cc151d\n'
pj-index-crlf-raw staged rc= 0 stdout= b'VERDICT_BRANCH=wip/178/critic\n' stderr= b''
```

Оба соседа дали те же строки до ремонта. `reproduce.py --before`: новый файл rc 1, плохая замена rc 0; после ремонта rc 0 и rc 1 соответственно, после коммита плохой замены HEAD-дверь rc 1.

Самостоятельные сценарии `python3 -B "$PWD/tmp/critic232-independent.py"`, rc 0: для `core.autocrlf=true`, `.gitattributes text eol=crlf`, и подмены файла между add и финальной дверью первый вызов rc 0, финальный rc 1 с пустым stdout и тем же сырым stderr выше. Первые два staged/raw be050a1b0a0be911950356926920c3d927559d0a/b73f98cb5211388f1a4599047b5b511e15cc151d; подмена staged b73f98cb5211388f1a4599047b5b511e15cc151d, raw 6b89e1f6e5a06c5d4724d4be77ec8108606c3279; HEAD не менялся.

## Машинные результаты

B=`bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh`:

```text
B --model: rc 0; KLETKI 73 KRASNYH 0
B --stabs: rc 0; STABY 30 SVJAZI 45 ZHIVYH 0
st30-filtered-index-hash pj-index-text-normalized RED PJ_RC,PJ_REASON,PJ_REFUSAL_FORM,PJ_DETAIL rc= 0 stdout= b'VERDICT_BRANCH=wip/178/critic\n' stderr= b''
B --sintaksis: rc 0; SINTAKSIS 20 SHELLCHECK 4 JSON_SCHEMA 1
B --catalog: rc 0; KLETKI 73 STABY 30 SVJAZI 45
B --repo .: rc 1; KLETKI 73 KRASNYH 50
context.py: rc 0; ДЕКЛАРАЦИИ 74
check_precision_gate.sh . contracts/232-gramm-karta-krome.md: rc 0; OK
193 --repo .: rc 0; ИТОГ 193: rc=0 KLETKI=152 ZELENYE=152 KRASNYE=0
224 --repo .: rc 0; KLETKI 100 KRASNYH 0
```

B --repo красен по умыслу до реализации. Первый `--sintaksis` без явно указанного пина отказал rc 2 `VALIDATOR_MISSING: shellcheck`; повтор с `VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck` дал показанный rc 0. Преддверие задания сообщило pre_critic и check_sdacha --run rc 0; здесь они не перезапускались.
