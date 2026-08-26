accept

Узкая правка §Зоны из `913b6b4` закрывает единственную находку финального
ревьюера без изменения предмета, барьера или фикстур. `ЗОНА architect` теперь
прямо включает `NABLIUDENIA_ARCHITECT.md`
(`contracts/012-izoljacija-progonov.md:52`).

Декларация в `contracts/012-izoljacija-progonov.md:58-71` сверена с историей
`20fd5ad..frozen/contracts/012/1`: все четыре полных хеша существуют до первой
заморозки, имеют `%an=architect` и меняют `NABLIUDENIA_ARCHITECT.md`:

- `7e8852bfccc1a9e11aaa795d4a30168f9ebf7aec` — только
  `NABLIUDENIA_ARCHITECT.md`;
- `f6853785d60e5723f6795eca0d27915e535bb97d` —
  `NABLIUDENIA_ARCHITECT.md` и `scripts/check_runner_hygiene.sh`;
- `998459c59f67b2dcf5aa1e6c7a1db315caadbaf4` — только
  `NABLIUDENIA_ARCHITECT.md`;
- `8119cac8c5e3a773b6a3a2dfdc0beaae8dd055a6` — только
  `NABLIUDENIA_ARCHITECT.md`.

Тем самым смешанный состав `f685378` не скрыт: контракт прямо называет сочетание
разрешённой правки барьера и внезонной записи наблюдения одним коммитом
неатомарностью (`contracts/012-izoljacija-progonov.md:69-71`). Раздел истории
правок добавлен и фиксирует расширение зоны, четыре дозаморозочных хеша,
неатомарность и требование перезаморозки `frozen/contracts/012/2`
(`contracts/012-izoljacija-progonov.md:124-133`). На HEAD существует только тег
`frozen/contracts/012/1`, поэтому для этого круга сохранено требуемое имя
`verdicts/critic/contracts-012-v1.md`; следующая заморозка — `/2`.

Самостоятельные проверки на HEAD `e62bc2f`:

- `bash scripts/verify_antiplacebo.sh --scope check_runner_hygiene` — rc=0,
  40/40 фикстур предъявлены красным повторным прогоном;
- `npm run check:charter` — rc=0, 38/38 изменений уставных документов имеют
  разрешение, включая `913b6b4f` для контракта 012;
- `bash scripts/check_zones.sh` — rc=0, 163 коммита проверены по зонам.

Новых классов не пересуждалось. Блокирующих находок и советов нет.
