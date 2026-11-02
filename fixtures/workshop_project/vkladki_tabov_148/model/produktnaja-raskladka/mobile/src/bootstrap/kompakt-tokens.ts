// 148 vkladki-tabov (И-12): значения nav/touch-target токенов
// пакета D24-Kompakt-1.1 для РЕАЛЬНЫХ компонентов лейсте —
// каноническое извлечение из docs/ux/05_Kompakt_D24/source/
// tokens.json (nav.height, nav.item.min-height,
// nav.label.font-size, nav.label.line-height, touch-target.min;
// поле $value, размерность px). Генерируется извлечением
// батареи 148 (produkt_sud.tokeny_modul) и руками не правится:
// продукт-судья сверяет байты с источником
// (TOKENY_MODUL_NE_IZ_ISTOCHNIKA), зонд судит СВЯЗЬ компонента
// с токеном подменой значения в изолированной копии (Crit148k2b
// Б1: высота лейсте и minHeight вкладок следуют за токеном).
export const navTokens = {
  height: 49,
  itemMinHeight: 48,
  labelFontSize: 10,
  labelLineHeight: 12,
  touchTargetMin: 44,
} as const;
