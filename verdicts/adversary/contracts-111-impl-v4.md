FAIL

OBJECT=ae0ec97d88188c6749f460e3ab433f2616f957d8

Вердикт: RESTYLE_GUARD_995 неполон. Он пропускает рестайл кадров 995 вне
F03.01 и welcome, а также платформенно-условный рестайл самого F03.01 на
Android. Это нарушает scope Р2: frozen-правило и дельта требуют сохранить
#FFFFFF и 48/16/16 на F03.01+ и welcome, а не только в двух маршрутах
Jest-мока.

Наблюдаемые обходы (в disposable clone /tmp/dev-harness-verify/Adv111r4/mob,
с собственным .git; после каждой пробы восстановлен):

1. Другая рамка 995. Я заменил завершающую else-ветвь root-style в
mobile/src/bootstrap/pilot-app.tsx так, что только frame === 'code' получает
[styles.root, { backgroundColor: tokens.ground }], тогда как first-run,
email/F03.01 и welcome остаются честными. Это рестайлит F03.02 (часть
«F03.01+») в dark #0a0a0a, при сохранённых paddingTop:48,
paddingHorizontal:16, paddingBottom:16.

   `python3 fixtures/workshop_project/first_run_111/first_run_probe.py --repo
   /tmp/dev-harness-verify/Adv111r4/mob` завершился rc=0, honest 19/19:
   все четыре RESTYLE_GUARD_995_F03_01/WELCOME × dark/light зелёны.

   Отдельный временный живой Jest/RNTL smoke провёл first-run -> F03.01 ->
demo-entry -> F03.02 и наблюдал корень `{backgroundColor:'#0a0a0a',
paddingTop:48, paddingHorizontal:16, paddingBottom:16}`; rc=0. Тем самым
проба ответила правильно лишь о F03.01/welcome, но не о требовании «F03.01+».

2. Платформенный обход. Я добавил Platform в импорт и заменил else-ветвь
root-style на:

   `Platform.OS === 'android' ? [styles.root, { backgroundColor:
   tokens.ground }] : styles.root`

   Это рестайлит каждый не-first-run кадр на Android, включая F03.01 и
welcome. Обычный behavioral probe снова rc=0, honest 19/19. В отдельном
Jest/RNTL smoke `Platform.OS` был временно установлен в android, пройден
first-run -> F03.01, и корень наблюдался как
`{backgroundColor:'#0a0a0a', paddingTop:48, paddingHorizontal:16,
paddingBottom:16}`; smoke rc=0. Следовательно, существующие клетки не
исполняют Android-вариант, хотя продукт и release-APK целятся в Android.

Матрица ловит только свои заранее заданные формы, но не оба обхода:
`first_run_probe.py --matrix` rc=0; исполнены 24 мутанта, включая
restyle-995-ground, restyle-welcome-ground, restyle-995-no-padding и
restyle-995-padding-shifted. Это не опровергает найденные зелёные мутанты:
ни один из 24 не делает F03.02-only или Android-only подмену.

Положительный контроль и регресс на чисто восстановленном OBJECT:

* first_run_static_probe.py rc=0, static 16/16;
* first_run_probe.py rc=0, honest 19/19;
* first_run_static_probe.py --matrix rc=0, 15 мутантов;
* first_run_probe.py --matrix rc=0, 24 мутанта;
* 995 `probe.py --check-frozen` rc=0, 14/14;
* 999 nav/ui/shell_static/copy probes rc=0;
* 108 start_static_probe.py rc=0, 22/22; start_probe.py rc=0, 336/336;
* `npm test && npm run lint && npm run typecheck` rc=0 (14 Jest tests,
  lint structure OK, tsc OK).

Обязательные отрицательные контроли проверки:

* отсутствие node в PATH: `env PATH=/tmp /usr/bin/python3
  first_run_static_probe.py --repo ...` -> rc=2 INFRASTRUCTURE
  (FileNotFoundError), не ложная зелень;
* пустой seam: временно удалён first-run-screen.tsx ->
  first_run_probe.py rc=1 `FIRST_RUN_SEAM_ABSENT`, не «нарушений нет»;
* нейтрализация root-padding и ground/welcome форм покрыта матрицей и даёт
  именованную красноту, как перечислено выше.

Проверка области: `git diff --name-only 5ab34ce06
 ae0ec97d88188c6749f460e3ab433f2616f957d8` вывел только
.github/workflows/mobile.yml и mobile/src/bootstrap/pilot-app.tsx. После
восстановления мутаций `git status --short --untracked-files=all` в
adversary-клоне пуст.

Нужна правка автора проверки: клетки должны живо проходить все достижимые
кадры 995 (как минимум F03.02 code, F03.04 recovery и unavailable) и обе
целевые платформы, asserting literals #FFFFFF/48/16/16 для каждого.
