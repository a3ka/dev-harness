// Носитель эталона линта (набор ekrannyj_nabor_158, И-3): ЗЕЛЁНЫЙ контроль —
// источник ЧИТАЕТ ключ токена, литерала в месте токена нет. Файл —
// выписка экрана, а не код продукта; суд — линт набора (model/lint в
// probe.py), значение токена — nositeli/tokens-vy-piska.json.
import { StyleSheet } from 'react-native';

import kompakt from '../../../../docs/ux/05_Kompakt_D24/source/tokens.json';

const ziel = Number(kompakt['touch-target'].min.$value.replace('px', ''));

export const styles = StyleSheet.create({
  touchTarget: {
    minWidth: ziel,
    minHeight: ziel,
  },
});
