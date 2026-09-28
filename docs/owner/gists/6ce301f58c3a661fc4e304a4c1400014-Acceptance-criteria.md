# Acceptance criteria как контракт

Зачем acceptance criteria

Acceptance criteria как рабочий контракт между продуктом, разработкой, QA и стейкхолдерами для User story


Что именно фиксируют AC:
- границы задачи
- ожидаемое поведение и
- условия готовности

- Scenario-based acceptance criteria соответствует формату:
  Дано/Когда/Тогда - Given/When/Then

- Rule-Based Acceptance Criteria это простой список "правил"

- Без AC задача остается интерпретацией а не договоренностью

- Хороший AC - проверяемое утверждение, а не пожелание или намерение

- Проверяемые AC: есть входные условия, действие и наблюдаемый результат

- Непроверяемые AC: размытые формулировки, субъективные оценки, неопределенные слова и скрытые допущения

Примеры плохих AC:
- работает быстро
- интерфейс понятный
- ошибок быть не должно

Примеры хороших AC:
- при неверном пароле показывается сообщение
- после сохранения запись видна в списке
- нельзя отправить пустую форму

Разница между "система должна быть удобной"
- Система позволяет авторизоваться только при вводе email и пароля
- Если данные введены неверно система показывает сообщение...
- Ввод пароля скрыт звездочками
- Кнопка "Войти" становится активной только после заполнения обоих полей.

- Почему непроверяемые AC создают конфликты на приемке и разное понимание done

- Связь AC с тестируемостью: если критерий нельзя проверить, его нельзя надежно принять

- AC как основа для тест-кейсов, автотестов и ручной проверки

- Связь AC с декомпозицией: маленькая задача обычно допускает точные и конечные критерии

- Как по AC определить, что задача готова к разработке, а не только к обсуждению

- Почему большие и расплывчатые задачи почти всегда порождают слабые AC

- Как AC уменьшают количество уточнений по ходу работы и снижают стоимость изменений

- Роль негативных сценариев в acceptance criteria: не только что система делает, но и что она запрещает или отклоняет

Example:
- Given a registered user
- When password reset is requested
- Then password reset email should be sent
- And email should expire in 30 minutes

```js
test('request password reset', async () => {
  const user = await users.create({
    email: 'user@example.com',
    password: 'secret',
  });
  await auth.requestPasswordReset(user.email);
  const email = await outbox.find(user.email);
  assert.equal(email.type, 'password-reset');
  assert.equal(email.expiresInMinutes, 30);
});
```

- Given a registered user
- And the user is on the login page
- When the user requests password reset
- Then the system sends a reset link to their email
- And the link expires after 30 minutes

```js
test('request password reset', async () => {
  const email = 'user@example.com';
  const app = await startTestApp();
  await app.api.register({
    email, password: 'old-password',
  });
  await app.api.requestPasswordReset({
    email
  });
  const message = await mailbox.find(email);
  const { token } = message.links.passwordReset;
  await app.clock.forward({ minutes: 31 });
  const result = await app.api.resetPassword({
    token, password: 'new-password',
  });
  assert.equal(result.status, 400);
  assert.equal(result.error.code, 'EXPIRED');
});
```

Задача: Найдите тесты на user story
- восстановите из них AC при помощи AI
- в новом контексте пусть AI напишет тесты
- повторите с человеком
- сделайте AC, чтоб не деградировал тест
