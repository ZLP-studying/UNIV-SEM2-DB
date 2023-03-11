-----------------------
-- Заполнение таблиц --
-----------------------
-- «Тип» - types
INSERT INTO types (name) VALUES
('Квартира'),
('Дом'),
('Апартаменты'),
('Трущебы');

-- «Районы» - districts
INSERT INTO districts (name) VALUES
('Ленинский'),
('Митино'),
('Марьино'),
('Гольяново');

-- «Материалы зданий» - materials
INSERT INTO materials (name) VALUES
('Панель'),
('Кирпич'),
('Пена'),
('Дерево');

-- «Объект недвижимости» - objects
INSERT INTO objects
(district_id, address, floor, rooms_count, type_id, status, cost, object_desc, material_id, square, date)
VALUES
--- ... ---

-- «Критерии оценки» - parameters
INSERT INTO parameters (name) VALUES
('Экология'),
('Чистота'),
('Соседи'),
('Условия для детей'),
('Магазины'),
('Безопасность');

-- «Оценки» - rates
INSERT INTO rates (object_id, date, parameter_id, score) VALUES
--- ... ---

-- «Риэлторы» - realtors
INSERT INTO realtors
(s_name, f_name, t_name, phone_num) VALUES
('Иванов', 'Иван', 'Петрович', '89608521245'),
('Кузнецов', 'Антон', 'Васильевич', '12234567899'),
('Продолговатый', 'Петр', 'Лисов', '98765432101'),
('Меньших', 'Афанасий', 'Евгеньевич', '65784932013'),
('Аккредитованный', 'Георгий', 'Колобков', '89690137888');

-- «Продажи» - sales
INSERT INTO sales
(reo_id, date, realtor_id, cost) VALUES
--- ... ---