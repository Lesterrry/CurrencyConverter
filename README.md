# CurrencyConverter – Мультивалютный Конвертер
  - Выполнены все 4 этапа конкурса
  - Курсы валют автоматически обновляются при каждом запуске приложения
  - Интерфейс адаптивен под любые размер ориентацию экрана, тему.
  - Дополнительно добавлен виджет, отслеживающий курс рубля в реальном времени
### Пояснения:
Переключение между нижней и верхней валютой, значение которой меняется интерфейсом PickerView, осуществляется нажатием кнопки со значком валюты.
Переключившись, можно выбирать вводимую валюту, и валюту выходного значения.
Редактирование текста по умолчанию предусмотрено для верхнего левого текстового поля, но возможен также ввод в нижнее правое текстовое поле, в таком случае конверсия произойдет реверсивно.
### Примечание:
Предложенный на странице с описанием задания к конкурсу API сервис 'https://exchangeratesapi.io' по неизвестным причинам задерживает обновление курсов валют. На 31.05.2020 запрос `https://api.exchangeratesapi.io/latest?symbols=EUR,USD&base=RUB` возвращает данные, актуальные на 29.05.2020.