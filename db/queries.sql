-- =====================================================================
-- db/queries.sql — SQL-запросы для приложения (пара 11)
-- БД: rahmabatt_kari
-- Знак ? — параметр, который в C# подставляется через параметры команды
-- (MySqlCommand.Parameters), а НЕ склейкой строк.
-- Для проверки в Workbench используйте строки "ТЕСТ" ниже запроса.
-- =====================================================================
USE `rahmabatt_kari`;

-- ---------------------------------------------------------------------
-- Этап 4. Вход в приложение (чек-лист 2.5, 2.6, 3.17)
-- Пустой результат = «неправильный логин/пароль»
-- ---------------------------------------------------------------------
SELECT u.id, u.full_name, r.name AS role
FROM users u
JOIN roles r ON r.id = u.role_id
WHERE u.login = '94d5ous@gmail.com' AND u.password = 'uzWC67';

-- ТЕСТ (должна вернуться ровно 1 строка: Никифорова Весения Николаевна, Администратор):


-- ---------------------------------------------------------------------
-- Этап 5. Каталог товаров (чек-лист 2.7–2.11; окна Гостя и Администратора)
-- ---------------------------------------------------------------------
SELECT p.id, p.article, p.name, p.unit, p.price, p.discount, p.stock_qty,
       p.description, p.photo,
       c.name AS category, m.name AS manufacturer, s.name AS supplier
FROM products p
JOIN categories c    ON c.id = p.category_id
JOIN manufacturers m ON m.id = p.manufacturer_id
JOIN suppliers s     ON s.id = p.supplier_id;


-- ---------------------------------------------------------------------
-- Этап 6. Поиск + фильтр + сортировка одним запросом (чек-лист 3.2–3.6)
-- ---------------------------------------------------------------------
SELECT p.id, p.article, p.name, p.unit, p.price, p.discount, p.stock_qty,
       p.description, p.photo,
       c.name AS category, m.name AS manufacturer, s.name AS supplier
FROM products p
JOIN categories c    ON c.id = p.category_id
JOIN manufacturers m ON m.id = p.manufacturer_id
JOIN suppliers s     ON s.id = p.supplier_id
WHERE p.name LIKE CONCAT('%', 'Туфли', '%')
  AND p.supplier_id = 1
ORDER BY p.stock_qty DESC;


-- Вариант, где каждое условие необязательно (если из формы пришёл NULL — условие игнорируется).
-- Порядок параметров: поиск, поиск, поставщик, поставщик. Сортировка (ASC/DESC) задаётся
-- в C# выбором одной из двух готовых строк, а не параметром.
SELECT p.id, p.article, p.name, p.price, p.discount, p.stock_qty, s.name AS supplier
FROM products p
JOIN suppliers s ON s.id = p.supplier_id
WHERE (? IS NULL OR p.name LIKE CONCAT('%', 'Туфли', '%'))
  AND (? IS NULL OR p.supplier_id = 1)
ORDER BY p.stock_qty ASC;   -- или DESC (3.2–3.3)


-- ---------------------------------------------------------------------
-- Этап 7. Добавление / редактирование товара (чек-лист 3.7, 3.10, 3.12, 3.19)
-- ---------------------------------------------------------------------
-- справочники для выпадающих списков в форме
SELECT id, name FROM categories;
SELECT id, name FROM manufacturers;
SELECT id, name FROM suppliers;

-- добавление товара
INSERT INTO products
  (article, name, unit, price, discount, stock_qty, description, photo,
   category_id, manufacturer_id, supplier_id)
VALUES ('TEST01', 'Тест', 'шт.', 1000.00, 5, 10, 'Тестовый товар', NULL, 1, 1, 1);

-- открыть товар для редактирования — заполнить все поля сразу
SELECT * FROM products WHERE id = LAST_INSERT_ID();

-- сохранить изменения
UPDATE products
SET article='TEST01', name='Тест 2', unit='шт.', price=1500.00, discount=10,
    stock_qty=20, description='Изменено', photo=NULL,
    category_id=1, manufacturer_id=1, supplier_id=1
WHERE id = LAST_INSERT_ID();


-- ---------------------------------------------------------------------
-- Этап 8. Удаление товара и защита от удаления купленного (чек-лист 3.16)
-- ---------------------------------------------------------------------
-- 1) проверка ДО удаления — чтобы показать понятное предупреждение
SELECT COUNT(*) AS used_in_orders FROM prodorders WHERE product_id = 1;

-- 2) удаление (если used_in_orders = 0). Если товар есть в заказах, БД сама откажет:
--    Error 1451: Cannot delete or update a parent row: a foreign key constraint fails
DELETE FROM products WHERE id = 1;
