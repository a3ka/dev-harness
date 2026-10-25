// Stand-in кода экрана батареи 138: каждый селектор флоя start-ekran обязан
// иметь носитель testID в коде экрана; свои селекторы — mobile/src/features/
// start, селекторы пути допуска — соседние экраны (onboarding 118, auth
// 135). В модели дерева носители — эти файлы (продукт несёт те же testID).
// Селекторы Start (внутри зоны 138), честный TSX:
<View testID="start_sostojanie_idle" />
<View testID="start_sostojanie_composer" />
<View testID="start_sostojanie_decision" />
<View testID="start_sostojanie_resume" />
<View testID="start_next_variant" />
