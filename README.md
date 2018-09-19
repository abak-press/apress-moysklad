# Apress::Moysklad

Библиотека для работы с онлайн-сервисом [МойСклад](https://online.moysklad.ru/api/remap/1.1/doc/index.html)

Получение ассортимента акаунта:

```ruby
Apress::Moysklad::Readers::Assortment.new(login: login, password: password).each_row do |row|
  ...
end
```
