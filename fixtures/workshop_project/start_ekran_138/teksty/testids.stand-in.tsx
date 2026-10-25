# Stand-in кода экрана батареи 138: каждый селектор флоя start-ekran обязан
# иметь носитель testID в коде экрана; свои селекторы — mobile/src/features/
# start/**, селекторы пути допуска — соседние экраны (onboarding 118, auth
# 135). В модели дерева носители — эти файлы (продукт несёт те же testID).
# Селекторы Start (внутри зоны 138):
testID="start_sostojanie_idle"
testID="start_sostojanie_composer"
testID="start_sostojanie_decision"
testID="start_sostojanie_resume"
testID="start_next_variant"
