# Происхождение живого референса mob-ref (станция)

Запись — о том, КАК собран референс `/tmp/dev-harness-verify/Arch148t/mob-ref`,
которым судят карту `model/karta-mob-ref.json` (клетка f00, d01). Референс
живёт вне дерева харнеса; запись ведётся здесь, чтобы происхождение входа
не потерялось вместе со станцией.

## Сборка — ВАРИАНТ B (решение оркестратора по У-3)

Эталон mob-ref = **продукт 148 со СВОИМ экраном**: `mobile/src/bootstrap/
tab-shell.tsx` берётся из клона продукта как есть. Экран продукта НЕ
подменяется экраном носителя и ни один файл продукта НЕ правится: зона
входа профиля в продукте уже задана (44×44), а надпись входа — значок с
доступным именем (`accessibilityLabel`), без видимого текста.

Прежняя сборка (рецепт `build-refs.sh`) переписывала экран продукта экраном
носителя 148 и дописывала в файл продукта `style={styles.profileZone}` —
это нарушало независимость входа (У-3); такой референт в приёмку не входит.

| Что | Откуда | Проверка |
|---|---|---|
| `mobile/**` (180 файлов) | клон продукта `/tmp/dev-harness-verify/Impl148h/mob` (ветка `wip/148/implementer`, tip `6b5ef76`), копия без `node_modules` | `sha256` экрана в референсе = `558f71f3499dab79eb9853b85fb34b92e033cba6f1ab2c0a6b9bad292f50e290` = тому же в продукте |
| `mobile/node_modules` | установка станции продукта — симлинком | — |
| `docs/ux/05_Kompakt_D24/source/tokens.json` | носитель батареи 147 `fixtures/workshop_project/gespraech_vhod_147/nositeli/kompakt11/tokens.json` (пакет токенов D24-Kompakt-1.1; зонд читает оттуда `touch-target.min`) | `sha256 cb39fb94cb0d775c6c739561315eebe87c207c3244f0dab2c4a42660acd06cb2` |
| `mobile/src/bootstrap/kompakt-tokens.ts` | носитель батареи 148 `fixtures/workshop_project/vkladki_tabov_148/model/produktnaja-raskladka/mobile/src/bootstrap/kompakt-tokens.ts` — ТОЛЬКО модуль токенов (продукт его не несёт) | `sha256 2261a3e5c2d4a5ee9ad4b70d46773569a0205e6c200cd6e0d3bf54ea46a660ec` |

## Рецепты (вне дерева харнеса)

* `/tmp/dev-harness-verify/scratch158/build-mob-ref-b.sh` — сборка референса
  (вариант B); первый аргумент — путь назначения.
* `/tmp/dev-harness-verify/scratch158/snyat-karta-mob-ref.py` — снятие карты
  целей с референса (процедура SPEC §4/§6 d01: цели и надписи — из файлов
  референса, не руками под результат).

## Состояния карты mob-ref (снято с этого референса)

`start` — табы; `profil` — поверхность профиля (вход `shell-profile-entry`).
Цели: `shell-tab-start`, `shell-tab-vorgaenge`, `shell-tab-schutz`,
`shell-tab-post` (видимые надписи `Start`, `Vorgänge`, `Schutz`, `Post`) и
`shell-profile-entry` — иконка: видимой надписи нет, обязательное доступное
имя `accessibilityLabel` = `Profil und Einstellungen` (каталог копий
`proposed.kompakt.header.profile.a11y`; видимая надпись `Profil bearbeiten`
у этого экрана — заголовок самой поверхности профиля, не имя входа).
