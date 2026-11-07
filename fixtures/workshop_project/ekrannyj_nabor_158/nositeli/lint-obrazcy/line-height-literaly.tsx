// Носитель эталона линта (набор ekrannyj_nabor_158, И-3): литерал 21 в
// месте lineHeight — грамматика требует токен nav.label.line-height; ключ
// токена источник НЕ читает (клетка c02).
import { StyleSheet } from 'react-native';

export const styles = StyleSheet.create({
  navLabel: {
    fontSize: 15,
    lineHeight: 21,
  },
});
