// Носитель эталона линта (набор ekrannyj_nabor_158, И-3): литерал 500 в
// месте delayLongPress — грамматика требует токен press-long; ключ токена
// источник НЕ читает (клетка c03).
import { StyleSheet } from 'react-native';

export const styles = StyleSheet.create({
  pillButton: {
    delayLongPress: 500,
  },
});
