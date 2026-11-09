// Носитель эталона линта (набор ekrannyj_nabor_158, И-3): значение РАВНО
// токену (44), но источник ключ токена НЕ читает — равное число без
// связи (клетка c04). Подмена значения токена такое место НЕ тронет.
import { StyleSheet } from 'react-native';

export const styles = StyleSheet.create({
  touchTarget: {
    minWidth: 44,
    minHeight: 44,
  },
});
