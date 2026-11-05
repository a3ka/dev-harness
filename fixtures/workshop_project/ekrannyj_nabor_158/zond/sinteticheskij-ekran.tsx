// Синтетический экран набора ekrannyj_nabor_158 (клетка f02): ВСЕ допустимые
// способы задания эффективной зоны ≥44 px (SPEC §3, z01…z12). Каждый — один
// Pressable с testID nabor158-<z..> и видимой надписью «Z». Зонд обязан
// признать ВСЕ двенадцать зелёными (ЛОЖНЫХ ОТКАЗОВ НЕТ). Файл — носитель
// набора, копируется раннером рядом с зондом в mobile/src/__nabor158__/.
import React from 'react';
import { Pressable, Text, View } from 'react-native';

export const ZONY = [
  'z01', 'z02', 'z03', 'z04', 'z05', 'z06', 'z07', 'z08', 'z09', 'z10',
  'z11', 'z12',
] as const;

const BUKVA = { fontSize: 12, lineHeight: 12 } as const;
const nichego = (): void => undefined;

function Tsel({ id, style, hitSlop, kontent }: {
  id: string;
  style: object;
  hitSlop?: number;
  kontent?: object;
}) {
  return (
    <Pressable hitSlop={hitSlop} onPress={nichego} style={style} testID={'nabor158-' + id}>
      <Text style={kontent ?? BUKVA}>Z</Text>
    </Pressable>
  );
}

export function SinteticheskijEkran() {
  return (
    <View>
      {/* z01 width:44 + height:44 */}
      <Tsel id="z01" style={{ width: 44, height: 44 }} />
      {/* z02 height:36 + minHeight:44 */}
      <Tsel id="z02" style={{ width: 44, height: 36, minHeight: 44 }} />
      {/* z03 width/height 44 при меньших minWidth/minHeight */}
      <Tsel id="z03" style={{ width: 44, height: 44, minWidth: 20, minHeight: 20 }} />
      {/* z04 minHeight:44 при auto-высоте */}
      <Tsel id="z04" style={{ width: 44, minHeight: 44 }} />
      {/* z05 hitSlop расширяет бокс 20×20 до 44×44 */}
      <Tsel hitSlop={12} id="z05" style={{ width: 20, height: 20 }} />
      {/* z06 padding:22 при auto-боксе (контент 7×12 + 44) */}
      <Tsel id="z06" style={{ padding: 22 }} />
      {/* z07 padding:16 при контенте 12×12 (знак шириной 12 при кегле 24) */}
      <Tsel id="z07" kontent={{ fontSize: 24, lineHeight: 12 }} style={{ padding: 16 }} />
      {/* z08 paddingVertical + paddingHorizontal при auto-боксе */}
      <Tsel id="z08" style={{ paddingVertical: 20, paddingHorizontal: 20 }} />
      {/* z09 height:36 + paddingVertical:8 + minHeight:52 */}
      <Tsel id="z09" style={{ width: 44, height: 36, paddingVertical: 8, minHeight: 52 }} />
      {/* z10 flexBasis:44 в row-ряду */}
      <View style={{ flexDirection: 'row' }}>
        <Tsel id="z10" style={{ flexBasis: 44, height: 44 }} />
      </View>
      {/* z11 flex:1 в ряду известной длины и высоты ≥44 */}
      <View style={{ flexDirection: 'row', width: 390, height: 44 }}>
        <Tsel id="z11" style={{ flex: 1 }} />
      </View>
      {/* z12 minWidth:44 при auto-width */}
      <Tsel id="z12" style={{ minWidth: 44, minHeight: 44 }} />
    </View>
  );
}
