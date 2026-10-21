FAIL
OBJECT=7a976e236e3679a419ef827c9c5babe7946cc88e

Суд Rev117v2 (reviewer). Предмет — реализация 117 v2 «Splash + иконка по макету D2.2.5.1» (Complior-mob#114,
ветка cmp-mob-117/vkhod). Контракт — frozen/contracts/117/2 (ce0b74a19). Находки в формате reslop:
`/tmp/dev-harness-verify/Rev117v2/review.md` (status: ready).

Изображения я посмотрел сам (скриншоты эмулятора, макеты PNG, растры иконки и знаков), затем проверил их
своими скриптами; авторским выводом я не пользовался.

## Кадры JS-оверлея splash: расхождений нет
- Splash dark: эмулятор `/tmp/dev-harness-verify/J117/frames117/dark/2026-10-21_203943/117 — splash + First-Run после снятия оверлея (схема устройства)/takeScreenshot/vkhod-117-splash.png`
  против макета `/tmp/dev-harness-verify/Impl117/mob/docs/ux/02_Design_System_D2_2_5_1_Visual_Reference/screens/Splash.png`.
  Расхождений нет. Знак, wordmark и tagline стоят на местах артборда при вписывании contain (≤ 2 px при
  масштабе 2.769). Фон #0a0a0a, чернила #f2f1ec, точка #d6f75a. IoU переднего плана 0.9932.
- Splash light: эмулятор `/tmp/dev-harness-verify/J117/frames117/light/2026-10-21_203956/…/takeScreenshot/vkhod-117-splash.png`
  против макета `…/screens/Splash-Hell.png`. Расхождений нет. Фон #f3f2ee, чернила #121211, точка
  #d6f75a, IoU 0.9927.
- Статус-бар контрастен ground, это оговорено инвариантом 6. Хрома ОС, чужого экрана или оверлея системы
  нет. Мера 123 (0.783 / 0.782, OK) не противоречит моей.

## Почему FAIL
1. Б-1 (блок): иконка приложения и её производные (icon, adaptive foreground/monochrome, favicon) нарисованы
   со срезанным концом дуги (butt). У канона `complior-app-icon.svg` стоит `stroke-linecap="round"`.
   У верхнего конца не хватает 3105 px — это полудиск круглого конца. Батарея зелёная, потому что согласие
   классов 0.9961 ≥ 0.97.
2. Б-2 (блок): знак нативного splash `splash-sign-{dark,light}.png` тоже со срезанным концом, а у знака
   артборда Splash.png/Splash-Hell.png конец круглый. Кадра нативного splash в артефакте нет, и мера 123
   его не видит. В «НЕ ЗАЩИЩАЕТ» ловцом назначен ревьюер.
3. Б-3 (условие ленда): пин `.harness123` = e79c1069 — это коммит accept критика 123 v2, а не тег freeze.
   Есть только тег frozen/contracts/123/1. Заморозку 123 v2 блокирует форк n12x-predposylki (не отвечен).
   Содержимое пина правильное: kadry_117 = Splash dark/light, sha256 макетов совпадают.

Вопросы (не блок): В-1 — ПЕРЕСЕЧЕНИЕ «правка текста шагов 123 — отказ ревьюера 117» против поручения
оркестратора delta-impl117pin6 (нужен оркестратор или арбитр); В-2 — устаревший комментарий в mobile.yml;
В-3 — владельцу: мягкость глифов композита 390×844 при апскейле.

Проверено и чисто: объём правки — 13 файлов от merge-base с canon/main, все в ЗОНЕ implementer;
`git diff --exit-code --stat 8748a7a3… HEAD -- mobile/src/features/auth/` → rc=0, вывод пуст;
последний коммит трогает только `.github/workflows/mobile.yml` (ref и комментарий).

Н-39: стабы к ветвям привязывает architect по коду. Пробел меры (модель знака и иконки без формы конца)
передан архитектору советом в Б-2, implementer его не чинит.
