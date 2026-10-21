FAIL
OBJECT=7e10a3762723322a5483567e86955953a4c58804

(4) Найден новый (не translateX) обход батареи 117: в эталонной реализации
одно значение `zIndex: 1000` на `splash-overlay` заменено на `zIndex: -1`.
Во время splash View и Image остаются смонтированы, видимы для RNTL,
absoluteFill, с каноническим require и корректным размером; но рисуются под
полноэкранным `FirstRunScreen` (SafeAreaView `flex: 1`), то есть пользователь
видит First-Run вместо Splash.png/Splash-Hell.png. Это нарушает frozen 117 v2,
инвариант 8: оверлей должен быть последним ребёнком ПОВЕРХ дерева оболочки,
и инвариант 9: видимый снимок splash должен соответствовать макету.

Исполненный мутант в одноразовой копии:
`PYTHONDONTWRITEBYTECODE=1 python3 /tmp/dev-harness-verify/Adv117v3/run_zindex_mutant.py`
дал `ZINDEX_BEHAVIORAL_RED []`, `ZINDEX_STATIC_RED []`,
`ZINDEX_INFRASTRUCTURE []`: обе части батареи 117 зелёные на неверной
реализации. Это именно нейтрализация слоя, а не изменение PNG или
translateX.

Пиксельный отрицательный контроль: реальные кадры First-Run dark/light были
подставлены как `vkhod-117-splash` и проверены точной копией
`sverka_maketa.py` (sha256 совпадает с `/home/harness/dev-harness/scripts/sverka_maketa.py`).
Результат: `Splash dark 0.000 < 0.600 NIZHE_POROGA` и
`Splash light 0.000 < 0.600 NIZHE_POROGA` (худший элемент wordmark).
Таким должен быть снимок при overlay под full-bleed FirstRun. Значит e2e
сверка 123 ловит данный сценарий, если действительно исполняется, но сама
батарея 117/матрица не имеет этой обманной ветви и локально пропускает
неканонический экран.

Позитивный контроль текущего OBJECT в независимой одноразовой копии:
`vkhod_probe.py --repo .../repro` -> `behavioral 26/26`; 
`vkhod_static_probe.py --repo .../repro` -> `static 40/40`.
Все предоставленные кадры splash dark/light и оба PNG-макета просмотрены:
знак, wordmark, tagline и тема соответствуют; артефакт 123 содержит
`Splash dark 0.783 OK`, `Splash light 0.782 OK`.

(1) Иконка и производные визуально несут каноническую круглую дугу; Б-1/Б-2
на текущем OBJECT закрыты. Цветная точка `#d6f75a` в
`android-icon-monochrome.png` не является нарушением frozen v2: инвариант 1
предписывает monochromeImage как производную того же `complior-app-icon`, а
канон SVG задаёт точку именно `#d6f75a`. Если Android требует одноцветный
resource, это конфликт внешней семантики с закреплённым каноном, а не
основание судье подменять контракт.

Требуемая правка автора проверки: добавить z-order/overlap негативный мутант
(например `zIndex: -1` либо непрозрачный sibling выше overlay), требовать
ровно соответствующую красную клетку и запускать её из `--matrix`.