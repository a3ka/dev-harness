// Expo Router: глобальный Stack. Дочерние маршруты сами выбирают стартовый
// раздел и тему; корневой layout ничего не подменяет.
//
// 148 vkladki-tabov (Б-3, слово владельца 2026-11-11): SafeAreaProvider —
// источник инсетов устройства (safe-area): нижняя лейсте стоит НАД
// системной жестовой полосой. Провайдер не меняет раскладку (нативный
// контейнер на всю площадь), он только публикует инсеты. Начальные
// метрики окна — чтобы первый кадр не ждал Insets.
import { Stack } from 'expo-router';
import { SafeAreaProvider, initialWindowMetrics } from 'react-native-safe-area-context';

export default function RootStack() {
  return (
    <SafeAreaProvider initialMetrics={initialWindowMetrics}>
      <Stack screenOptions={{ headerShown: false }} />
    </SafeAreaProvider>
  );
}
