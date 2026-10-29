#!/usr/bin/env bash
# Контракт 145 (faden-dvizok): проба LIVE-PUT — исполнимость режима L до
# уровня, доступного без RN-рантайма (правка по scoped-критику 3/3,
# блокер B.6/B.8/C.11: FileNotFoundError на пути компонента в копии).
# Свойства (оба — именованные исходы, НЕ падение):
#   (1) продукт-форма батареи БЕЗ jest-среды → rc 2 LIVE_PREDPOSYLKA
#       с перечнем недостающего;
#   (2) продукт-форма с ФИКТИВНОЙ средой (package.json, jest.config,
#       метаданные трёх пакетов, фиктивный node_modules/.bin/jest с
#       минимальным зелёным jest-JSON) → путь компонента в изолированной
#       копии РАЗРЕШАЕТСЯ: контроль доходит до запуска jest, исходы
#       именованные (фиктивный jest ничего не ассертит → первый мутант
#       LIVE_MUTANT_ZHIV, rc 1). Фиктивная среда НЕ объявляет работающий
#       RN-рантайм: положительных live-зелёных чисел матрицы проба не
#       печатает и не доказывает — живая матрица остаётся за приёмкой
#       («Живые измерения реализации»).
# Коды: 0 — оба свойства держатся; 1 — именованный отказ PROBA_LIVE_PUT
# (с хвостом прогона как свидетелем); 2 — нечем проверять. Самодостаточна
# (node + python3, без сети), как батарея.
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
W="$HERE/red_faden_dvizok_145.sh"
FORMA="$HERE/produkt"
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }

VREM="$(mktemp -d)" || exit 2
trap 'rm -rf "$VREM"' EXIT

# (1) продукт-форма без jest-среды — именованная предпосылка, не падение
"$W" --live-component --repo "$FORMA" >"$VREM/1.out" 2>"$VREM/1.err"; RC1=$?
if [ "$RC1" -ne 2 ] || ! grep -q 'LIVE_PREDPOSYLKA: ' "$VREM/1.err" \
   || grep -q -e Traceback -e FileNotFoundError "$VREM/1.out" "$VREM/1.err"; then
  echo "PROBA_LIVE_PUT: без среды rc=$RC1 (ожидание: 2 LIVE_PREDPOSYLKA с перечнем, без трейсбека)" >&2
  tail -n 3 "$VREM/1.err" >&2
  exit 1
fi

# (2) фиктивная среда: путь компонента в копии разрешается, jest запускается
FEJK="$VREM/fejk"
mkdir -p "$FEJK/mobile/node_modules/.bin" \
         "$FEJK/mobile/node_modules/jest-expo" \
         "$FEJK/mobile/node_modules/react-native-svg" \
         "$FEJK/mobile/node_modules/@testing-library/react-native" || exit 2
cp -R "$FORMA/mobile/src" "$FEJK/mobile/src" || exit 2
for paket in jest-expo react-native-svg @testing-library/react-native; do
  printf '{"name":"%s","version":"0.0.0-fejk"}\n' "$paket" >"$FEJK/mobile/node_modules/$paket/package.json" || exit 2
done
printf '{"name":"mobile-fejk","private":true}\n' >"$FEJK/mobile/package.json"
printf 'module.exports = {};\n' >"$FEJK/mobile/jest.config.js"
cat >"$FEJK/mobile/node_modules/.bin/jest" <<'JEJT'
#!/bin/sh
# фиктивный jest пробы LIVE-PUT — НЕ продуктовый движок: минимальный
# зелёный итог, чтобы режим L дошёл до классификации мутантов
printf '%s\n' '{"success":true,"numPassedTests":3,"numTotalTestSuites":2,"numTotalTests":3,"testResults":[{"assertionResults":[{"status":"passed"}]}]}'
JEJT
chmod +x "$FEJK/mobile/node_modules/.bin/jest" || exit 2

"$W" --live-component --repo "$FEJK" >"$VREM/2.out" 2>"$VREM/2.err"; RC2=$?
if [ "$RC2" -ne 1 ] || ! grep -q 'LIVE kontrol: ZELEN' "$VREM/2.out" \
   || ! grep -q 'LIVE_MUTANT_ZHIV' "$VREM/2.err" \
   || grep -q -e Traceback -e FileNotFoundError "$VREM/2.out" "$VREM/2.err"; then
  echo "PROBA_LIVE_PUT: фиктивная среда rc=$RC2 (ожидание: контроль ZELEN, затем rc 1 LIVE_MUTANT_ZHIV; без трейсбека/падения на пути)" >&2
  tail -n 5 "$VREM/2.err" >&2
  exit 1
fi
echo 'PROBA_LIVE_PUT: без среды rc 2 LIVE_PREDPOSYLKA (перечень); фиктивная среда — контроль ZELEN, мутант именован LIVE_MUTANT_ZHIV rc 1; путь компонента в копии достигнут'
exit 0
