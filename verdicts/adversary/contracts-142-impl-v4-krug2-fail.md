FAIL
OBJECT=246be68a22c54111e4fd985acf08809eadc8faff
СУД: repo=dev-harness; предмет=142; фаза=реализация v4 (повтор после усиления); роль=adversary; вызов=2/2; модель-план=openai-codex/gpt-5.6-terra; сессия=Adv142v4b; модель-факт=openai-codex/gpt-5.6-terra; SHA=246be68a22c54111e4fd985acf08809eadc8faff; предыдущий=verdicts/adversary/contracts-142-impl-v4.md (1/2 FAIL); исключение=нет

# БЛОКИРУЕТ

## B3 — батарея не покрывает допустимый каноном токен authority с `"`

**ОБЯЗАТЕЛЬСТВО:** И-1/И-2 `contracts/142-skaner-sekretov.md` объявляют токен-ветвь единственным источником: `(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|...)`. В классе токена запрещены только `/`, `?`, `#` и `[[:space:]]`; байт `"` в этот запрет не входит. Следовательно `https://tok"quote@host.test/path` — непустой authority по канону и у адресного ключа обязан судиться. Значения определены как любые непустые байты строки; исключение И-3 применимо только без userinfo. Батарея заявлена как энфорсмент И-1…И-7.

**КЛАСС ПРИЧИНЫ:** правильный канон-литерал не доказывает его исполнимую семантику для полного класса. В копии SUBJECT сохранён канонический `USERINFO_RE` (так что r1 зелёная), но рабочая ветвь заменена более узким `USERINFO_TEST_RE`, который допускает все уже покрытые алфавиты k99–k120 — alnum, `.` `%` `~` и `!$&'()*+,;=` — но исключает `"`. Это другой мутант, не B2-стаб.

```sh
USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
USERINFO_TEST_RE="(^([A-Za-z0-9_.%~!\$&'()*+,;=-]+:)?//[A-Za-z0-9_.%~!\$&'()*+,;=-]+@|[^/@[:space:]]*:[^/@[:space:]]*@)"
# рабочий grep использует USERINFO_TEST_RE
```

**ДОСТИЖИМОЕ СОСТОЯНИЕ:** только копия интегрального дерева в `mutant-quote-token`; mktemp-мир содержит `X_URL=https://tok"quote@host.test/path`, а индексируемый `leak.txt` — то же синтетическое значение. Реальный дом секретов не читался.

**ВОСПРОИЗВЕДЕНИЕ (батарея):**

```text
$ env -i PATH=/home/harness/.local/bin:/usr/local/bin:/usr/bin:/bin HOME=/tmp bash repo/fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --repo mutant-quote-token
s142 repo: клеток 154, зелёных 154, красных 0
# rc=0
```

**ВОСПРОИЗВЕДЕНИЕ (наблюдаемый обход):**

```text
$ env -i PATH=/home/harness/.local/bin:/usr/local/bin:/usr/bin:/bin HOME=/tmp ./probe_quote_token.sh repo repo/scripts/connect_project.sh
value=https://tok"quote@host.test/path rc=1 calls=0 stderr=connect ОТКАЗ: sekret-v-dereve: значение дома секретов в файле «leak.txt», который git может проиндексировать — сессия не запускается
# rc=0 (проба напечатала результат честной двери)

$ env -i PATH=/home/harness/.local/bin:/usr/local/bin:/usr/bin:/bin HOME=/tmp ./probe_quote_token.sh repo mutant-quote-token/scripts/connect_project.sh
value=https://tok"quote@host.test/path rc=0 calls=1 stderr=
# rc=0
```

Батарея даёт ложную зелень, а ошибочная дверь запускает `workshop` при индексируемой утечке, которую канон требует судить.

**ЗАКРЫВАЮЩЕЕ СВОЙСТВО:** батарея краснит субъект, сохранивший канон-литерал, но сузивший исполнимый токен-класс и пропускающий `https://tok"quote@host.test/path`; минимум — клетка под порождённым адресным именем с rc 1, `sekret-v-dereve` и нулём запусков workshop. Для обеих заявленных URL-форм то же свойство проверяется и для `//tok"quote@host.test/path`.

# Подтверждённые контроли

```text
$ W --model  # три последовательных запуска
s142 model: клеток 154, зелёных 154, красных 0
s142 model: клеток 154, зелёных 154, красных 0
s142 model: клеток 154, зелёных 154, красных 0
# каждый rc=0

$ W
s142 subjekt: клеток 154, зелёных 154, красных 0
# rc=0

$ W --stabs
s142 model-opora-stabov: клеток 154, зелёных 154, красных 0
ПОЙМАН stab_uzkij-token-predikat @ k117-token-tochka-protsent-tilde
ПОЙМАН stab_uzkij-token-predikat @ k118-token-tpt-bez-shemy
ПОЙМАН stab_uzkij-token-predikat @ k119-token-ostalnaya-punktuaciya
ПОЙМАН stab_uzkij-token-predikat @ k120-token-punktuaciya-bez-shemy
s142 stabs: стабов 44, привязок 240, непойманных 0
# rc=0

$ W --repo ../main-v3
s142 repo: клеток 154, зелёных 144, красных 10
# rc=1; красны прежние шесть v4 k99–k101/k107/k114/r1 и четыре B2 k117–k120

$ sha256sum scripts/connect_project.sh fixtures/workshop_project/skaner_sekretov_142/model/connect_project.sh
# оба e2f5c3945a191c79e26757cb49b87348aad396abc69ebf7c709428716f693504
$ jq -r '"axes=\(.osi|length) stabs=\(.stab_vhod|length) bindings=\([.stab_vhod[]|length]|add)"' fixtures/workshop_project/skaner_sekretov_142/source.json
axes=154 stabs=44 bindings=240

$ P; Q
s125 red: зелёных 70, красных 0
sessii_136: клеток 87, зелёных 87, красных 0
# оба rc=0

$ bash fixtures/workshop_project/skaner_sekretov_142/red_skaner_sekretov_142.sh --model  # модель испорчена только в копии
s142: ORACLE_TAMPERED: sha256 модели ≠ source.json:.model_sha256
# rc=2

$ env -i PATH=/home/harness/.local/bin:/usr/local/bin:/usr/bin:/bin HOME=/tmp bash scripts/check_spec_ready.sh . contracts/142-skaner-sekretov.md
OK
# rc=0, 52.30 s

$ env -i PATH=/home/harness/.local/bin:/usr/local/bin:/usr/bin:/bin HOME=/tmp bash scripts/check_zones.sh .
замороженных контрактов: 141 · объявленных авторов: 5 · коммитов в диапазонах: 36183 · проверено по зонам: 8065
# rc=0, 323.51 s
```

B2 закрыт: `stab_uzkij-token-predikat` пойман на всех восьми назначенных клетках, включая k117–k120. B1 не оспаривается: в этом вызове не предъявлена достижимость без контроля PATH/среды; И-5 запрещает его правку в 142.

# НЕ ПРОВЕРЕНО

Названный OBJECT недоступен: `git cat-file -t 246be68a22c54111e4fd985acf08809eadc8faff` вернул rc 128 в указанном worktree и в изолированном клоне. Для проверок собран [INFERENCE] интегральный кандидат `e9ad5f7e7e0f8654f1fa7351f1623cfaeed0b531` merge `e7ae5f6a510461692ca3741015a8dcca6d9df96b` (усиленная батарея) + `4787e33d853ee80b6accbf760ce29359a7c9b6ad` (дверь v4); его дверь и модель имеют приведённый sha256. Тождество этого дерева отсутствующему OBJECT наблюдать невозможно.
