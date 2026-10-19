FAIL
OBJECT=0070c38ac300ff7fdc2c8ca48d5abfa001426582

Блокирующий обход записан в `harness/verdicts/adversary/contracts-107-impl-v3.md`: route Erstinformation стартует в W0, корректно не читает gate в W0, но не имеет достижимого перехода в W1A. Единственный setter W1A висит на Continue, которая видима только при уже W1A и доказанном gate. Поэтому корректный CURRENT_CONFIRMED runtime не достигает экрана; 107 22/22, 265/265 и матрицы 4/24 при этом зелёные. Исполнимый witness: rc=1 на реальном entry; позитивный W1A-control rc=0. `review.md` содержит reslop-находку.
