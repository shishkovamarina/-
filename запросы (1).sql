 -- 6. скрипты характерных выборок (включающие группировки, JOIN'ы, вложенные таблицы)
 -- выбрать пациентов старше 1980-01-01
select*
from patients 
where birthday >'1980-01-01';

-- выбрать пациентов, адресс и их диагнозы
select card_id as 'id',firstname as 'Имя', lastname as 'Фамилия', patronymic as 'Отчество', adress as 'Адрес', description_survey as 'Диагноз'
from reception 
join patients on card_id=patients.id
join diagnosis on diagnosis_id=diagnosis.id;

-- кто из врачей больше всех принял 
select doctor_id as 'id', count(*) as 'Количество посещений'
from appointment
group by doctor_id
order by count(*) desc;

-- кто больше всех принес прибыль
select description_specialty as 'Специалист', sum(count_appointment) as 'Заработано'
from doctors 
join specialty on doctors.id=specialty.id
join appointment on appointment.id=appointment.id
group by description_specialty
order by sum(count_appointment) desc;

-- кто работал 2020-08-10
select * 
from doctors
where tametable_id in (select id from tametable where date_tametable='2020-08-10');

-- Кто имеет больничный лист, их дата обращения
select reception.card_id,firstname, lastname, date_appointment, open_sick_list, close_sick_list
from reception 
join sick_list on reception_id=reception.id
join appointment on appointment_id=appointment.id
join patients on reception.card_id=patients.id;





-- 7.представления (минимум 2)
-- Представление "Режим работы"
CREATE OR REPLACE VIEW work AS
SELECT firstname, lastname, description_specialty, date_tametable, start_tametable, finish_tametable FROM doctors d,tametable t, specialty s
WHERE d.tametable_id=t.id and d.specialty_id=s.id;
-- проверка
SELECT * FROM work;

-- Представление "Информация по посещению"
CREATE OR REPLACE VIEW visit AS
SELECT p.id, p.firstname, p.lastname, date_appointment, description_survey, d.firstname as d_firstname, d.lastname as d_lastname, description_specialty 
FROM reception r, patients p, doctors d, appointment a, specialty s, diagnosis dia
WHERE r.card_id=p.id and r.diagnosis_id=dia.id and r.appointment_id=a.id and d.specialty_id=s.id and a.doctor_id=d.id;
-- проверка
SELECT * FROM visit;




-- 8. хранимые процедуры / триггеры;

--  хранимая процедура, процедура скидка в 20 %
DROP procedure IF EXISTS sp_newstoimost;
DELIMITER //
CREATE PROCEDURE sp_newstoimost() 
BEGIN
UPDATE specialty
set count_appointment=count_appointment*0.8;
END//
DELIMITER ;
CALL sp_newstoimost;
-- проверка
select * from specialty;

--  хранимая процедура, сколько человек определенного пола
DROP procedure IF EXISTS sp_gender;
DELIMITER //
CREATE PROCEDURE sp_gender(IN c CHAR(3), OUT num SMALLINT)
BEGIN
SELECT count(*) INTO num
from patients
where gender=c;
END//
DELIMITER ;
CALL sp_gender('f', @sum);
SELECT @sum;

--  хранимая процедура изменения имени
DROP procedure IF EXISTS sp_change_user_name;
DELIMITER //
CREATE PROCEDURE sp_change_user_name (patients_id_in int, firstname_in varchar(45), lastname_in varchar(45), patronymic_in varchar(45))
BEGIN
UPDATE patients
SET firstname=firstname_in,
    lastname=lastname_in,
    patronymic=patronymic_in
WHERE patients.id=patients_id_in;
END//
DELIMITER ;
CALL sp_change_user_name('1', 'Ivanov', 'Ivan', 'Ivanovich');
select * from patients;


-- хранимая процедура, которая определяет количество посещений за период дат, полученных в аргументах.
DROP procedure IF EXISTS best_people;
DELIMITER //
CREATE PROCEDURE best_people (d1 DATE, d2 DATE)
BEGIN
    SELECT doctor_id as id, firstname as 'Имя', lastname as 'Фамилия', count(*) AS "Количество посещений"
    FROM appointment a
    INNER JOIN doctors ON doctors.id = a.doctor_id
    and date_appointment BETWEEN d1 and d2
    GROUP BY doctor_id
    ORDER BY count(*) DESC;
    END // 
DELIMITER ; 
CALL best_people ('2020-08-03', '2020-08-10');


-- Действие этого триггера направлено на то чтобы пользователь не мог изменить на отрицательные знания в поле description_survey (cтоимость приема)
DROP TRIGGER IF EXISTS trigger1;
DELIMITER //
CREATE TRIGGER trigger1
BEFORE UPDATE
ON specialty
FOR EACH ROW
IF not exists(SELECT* FROM specialty WHERE count_appointment<0) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Ошибка цена не может быть меньше 0';
END IF //
DELIMITER ; 
Update specialty set count_appointment='-5' where id='2';
select * from specialty

-- Функция триггера состоит в том, чтобы проверить, превышает ли значение birthday, вставляемое в таблицу patients, сегодняшную дату, и выдать ошибку, если это так.
DROP TRIGGER IF EXISTS trigger2
DELIMITER //
CREATE TRIGGER trigger2
BEFORE INSERT
ON patients
FOR EACH ROW
IF NEW.birthday>now() THEN
SIGNAL SQLSTATE '55000'
SET MESSAGE_TEXT = 'Не верная дата рождения';
END IF//
DELIMITER ;
Insert into patients values('61','Ava','Connelly','Wehner','m','62836 Margarette Walk Apt. 505','89702271023','5798','2021-04-08');