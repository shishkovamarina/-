DROP DATABASE IF EXISTS hospital;
CREATE DATABASE hospital;
USE hospital;


CREATE TABLE patients (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    firstname VARCHAR(50),
    lastname VARCHAR(50) COMMENT 'Фамилия', 
    patronymic VARCHAR(50) COMMENT 'Отчество',
    gender CHAR(1),
    adress VARCHAR(120),
 	phone BIGINT UNSIGNED UNIQUE, 
	insurance BIGINT UNSIGNED UNIQUE,
    birthday DATE,
        
    INDEX patients_firstname_lastname_idx(firstname, lastname)
) COMMENT 'пациенты';

    
DROP TABLE IF EXISTS sick_list; -- больничный лист
CREATE TABLE sick_list (
id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT unique,
open_sick_list DATE,
close_sick_list DATE,
card_id BIGINT UNSIGNED NOT NULL, 
reception_id BIGINT UNSIGNED NOT NULL,

FOREIGN KEY (card_id) REFERENCES patients(id)
);

DROP TABLE IF EXISTS survey; -- обследования
CREATE TABLE survey (
id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT unique,
description_survey VARCHAR(100)
);

DROP TABLE IF EXISTS diagnosis; -- диагнозы
CREATE TABLE diagnosis (
id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT unique,
description_survey VARCHAR(30)
);

DROP TABLE IF EXISTS appointment; -- приемы
CREATE TABLE appointment (
id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT unique, -- номер записи
doctor_id BIGINT UNSIGNED NOT NULL,
date_appointment DATE
);

DROP TABLE IF EXISTS specialty; -- специализации
CREATE TABLE specialty (
id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT unique,
description_specialty VARCHAR(30),
count_appointment int
);

DROP TABLE IF EXISTS parcel; -- номер участка
CREATE TABLE parcel (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT unique,
    name_parcel VARCHAR(30),
    adress_parcel VARCHAR(100)
);
 
 DROP TABLE IF EXISTS tametable; -- расписание
CREATE TABLE tametable (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT unique,
    date_tametable DATE,
    start_tametable TIME,
    finish_tametable TIME,
    room BIGINT UNSIGNED NOT NULL
);

CREATE TABLE doctors (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT unique, 
    firstname VARCHAR(50),
    lastname VARCHAR(50) COMMENT 'Фамилия', 
    patronymic VARCHAR(50) COMMENT 'Отчество',
    adress VARCHAR(120) UNIQUE,
 	phone BIGINT UNSIGNED UNIQUE, 
	birthday DATE,
    tametable_id BIGINT UNSIGNED NOT NULL,
    specialty_id BIGINT UNSIGNED NOT NULL,
    parcel_number BIGINT UNSIGNED, -- номер участка
    
    FOREIGN KEY (specialty_id) REFERENCES specialty(id),
    FOREIGN KEY (tametable_id) REFERENCES tametable(id),
    FOREIGN KEY (parcel_number) REFERENCES parcel(id)
    );

DROP TABLE IF EXISTS reception; -- посещения
CREATE TABLE reception (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT unique, -- код посещения
    diagnosis_id BIGINT UNSIGNED NOT NULL, -- код диагноза
    appointment_record VARCHAR(150), -- запись о посещении
    card_id BIGINT UNSIGNED NOT NULL, -- номер карты
    appointment_id BIGINT UNSIGNED NOT NULL, -- номер записи
    complaint VARCHAR(200),   --  жалобы
    survey_id BIGINT UNSIGNED NOT NULL, -- код обследования
    
    FOREIGN KEY (card_id) REFERENCES patients(id),
    FOREIGN KEY (diagnosis_id) REFERENCES diagnosis(id),
    FOREIGN KEY (appointment_id) REFERENCES appointment(id),
    FOREIGN KEY (survey_id) REFERENCES survey(id)
);

ALTER TABLE hospital.sick_list
ADD CONSTRAINT sick_list_fk 
FOREIGN KEY (reception_id) REFERENCES reception(id);

ALTER TABLE hospital.appointment
ADD CONSTRAINT appointment_fk 
FOREIGN KEY (doctor_id) REFERENCES doctors(id);

