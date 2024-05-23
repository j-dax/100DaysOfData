-- https://techtfq.com/blog/learn-how-to-write-sql-queries-practice-complex-sql-queries

-------------------
-- Query 4:
-------------------

--Table Structure:

DROP TABLE IF EXISTS doctors;
CREATE TABLE doctors
(
id INT PRIMARY KEY,
name VARCHAR(50) NOT NULL,
speciality VARCHAR(100),
hospital VARCHAR(50),
city VARCHAR(50),
consultation_fee INT
);

INSERT INTO doctors VALUES
(1, 'Dr. Shashank', 'Ayurveda', 'Apollo Hospital', 'Bangalore', 2500),
(2, 'Dr. Abdul', 'Homeopathy', 'Fortis Hospital', 'Bangalore', 2000),
(3, 'Dr. Shwetha', 'Homeopathy', 'KMC Hospital', 'Manipal', 1000),
(4, 'Dr. Murphy', 'Dermatology', 'KMC Hospital', 'Manipal', 1500),
(5, 'Dr. Farhana', 'Physician', 'Gleneagles Hospital', 'Bangalore', 1700),
(6, 'Dr. Maryam', 'Physician', 'Gleneagles Hospital', 'Bangalore', 1500);

--Solution:

-- From the doctors table, fetch the details of doctors who work in the same hospital but in different speciality.
SELECT d1.*
FROM doctors d0
	JOIN doctors d1
		ON d0.hospital = d1.hospital
		AND d0.id <> d1.id
		AND d0.speciality <> d1.speciality;

--Sub Question:

-- Now find the doctors who work in same hospital irrespective of their speciality.
SELECT d1.*
FROM doctors d0
	JOIN doctors d1
	ON d0.hospital = d1.hospital AND d0.id <> d1.id;

--------------
-- Query 5
--------------

DROP TABLE IF EXISTS login_details;
CREATE TABLE login_details (
	id INT PRIMARY KEY,
	username VARCHAR(50),
	login_date DATE
);

INSERT INTO login_details VALUES
(101, 'Michael', date '2021-08-21'),
(102, 'James', date '2021-08-21'),
(103, 'Stewart', date '2021-08-22'),
(104, 'Stewart', date '2021-08-22'),
(105, 'Stewart', date '2021-08-22'),
(106, 'Michael', date '2021-08-23'),
(107, 'Michael', date '2021-08-23'),
(108, 'Stewart', date '2021-08-24'),
(109, 'Stewart', date '2021-08-24'),
(110, 'James', date '2021-08-25'),
(111, 'James', date '2021-08-25'),
(112, 'James', date '2021-08-26'),
(113, 'James', date '2021-08-27');

-- 5. From the login_details table, fetch the users who logged in consecutively 3 or more times.
WITH triple_consecutive_login AS (
	SELECT
		CASE
			WHEN username = LEAD(username) OVER (ORDER BY id) AND
				 username = LEAD(username, 2) OVER (ORDER BY id)
			THEN username
			ELSE NULL END repeated_names
	FROM login_details
)
SELECT DISTINCT *
FROM triple_consecutive_login
WHERE repeated_names IS NOT NULL

--------------
-- Query 6
--------------

DROP TABLE IF EXISTS students;
CREATE TABLE students (
	id INT PRIMARY KEY,
	student_name VARCHAR(50)
);

INSERT INTO students VALUES
(1, 'James'),
(2, 'Michael'),
(3, 'George'),
(4, 'Stewart'),
(5, 'Robin');

--- 6. From the students table, write a SQL query to interchange the adjacent student names.
SELECT *,
	CASE WHEN id % 2 = 0
		THEN LAG(student_name) OVER (ORDER BY id)
		ELSE LEAD(student_name, 1, student_name) OVER (ORDER BY id)
	END new_student_name
FROM students;

--------------
-- Query 7
--------------

DROP TABLE IF EXISTS weather;
CREATE TABLE weather (
	id INT,
	city VARCHAR(50),
	temperature INT,
	day DATE
);

INSERT INTO weather VALUES
(1, 'London', -1, DATE '2021-01-01'),
(2, 'London', -2, DATE '2021-01-02'),
(3, 'London', 4, DATE '2021-01-03'),
(4, 'London', 1, DATE '2021-01-04'),
(5, 'London', -2, DATE '2021-01-05'),
(6, 'London', -5, DATE '2021-01-06'),
(7, 'London', -7, DATE '2021-01-07'),
(8, 'London', 5, DATE '2021-01-08');

-- 7. From the weather table, fetch all the records when London had extremely cold temperature for 3 consecutive days or more.

WITH frost AS ( 
	SELECT *,
		CASE WHEN temperature < 0
			AND ( -- beginning
			0 > LEAD(temperature) OVER (ORDER BY day) AND
		 	0 > LEAD(temperature, 2) OVER (ORDER by day)
			OR -- middle
			0 > LAG(temperature) OVER (ORDER BY day) AND
		 	0 > LEAD(temperature) OVER (ORDER by day)
			OR -- end
			0 > LAG(temperature) OVER (ORDER BY day) AND
			0 > LAG(temperature, 2) OVER (ORDER BY day)
		)
		THEN 'Frosty'
		ELSE NULL END frosty
	FROM weather
)
SELECT id, city, temperature, day
FROM frost
WHERE frosty IS NOT NULL

--------------
-- Query 8
--------------

DROP TABLE IF EXISTS patient_treatment;
DROP TABLE IF EXISTS physician_speciality;
DROP TABLE IF EXISTS event_category;
CREATE TABLE event_category (
	event_name VARCHAR(50),
	category VARCHAR(100)
);
INSERT INTO event_category VALUES
('Chemotherapy', 'Procedure'),
('Radiation', 'Procedure'),
('Immunosuppressants', 'Prescription'),
('BTKI', 'Prescription'),
('Biopsy', 'Test');

CREATE TABLE physician_speciality (
	id INTEGER PRIMARY KEY,
	speciality VARCHAR(50)
);
INSERT INTO physician_speciality VALUES
(1000, 'Radiologist'),
(2000, 'Oncologist'),
(3000, 'Hermatologist'),
(4000, 'Oncologist'),
(5000, 'Pathologist'),
(6000, 'Oncologist');

CREATE TABLE patient_treatment (
	patient_id INT,
	event_name VARCHAR(50),
	physician_id INT REFERENCES physician_speciality(id)
);
INSERT INTO patient_treatment VALUES
(1, 'Radiation', 1000),
(2, 'Chemotherapy', 2000),
(1, 'Biopsy', 1000),
(3, 'Immunosuppressants', 2000),
(4, 'BTKI', 3000),
(5, 'Radiation', 4000),
(4, 'Chemotherapy', 2000),
(1, 'Biopsy', 5000),
(6, 'Chemotherapy', 6000);

-- 8. From the following 3 tables (event_category, physician_speciality, patient_treatment)
-- 		write a SQL query to get the histogram of specialties
--		of the unique physicians who have done the procedures
--		but never prescribed anything.

WITH proc_and_pres AS (
	SELECT physician_id, category
	FROM event_category e
	JOIN patient_treatment p
	ON e.event_name = p.event_name
	ORDER BY physician_id
), physician_stat AS (
	SELECT
		DISTINCT physician_id,
		(SELECT COUNT(*)
			FROM proc_and_pres p1
			WHERE category = 'Procedure'
			AND p1.physician_id = p0.physician_id
		) sentProcedure,
		(SELECT COUNT(*)
			FROM proc_and_pres p1
			WHERE category = 'Prescription'
			AND p1.physician_id = p0.physician_id
		) sentPrescription
	FROM proc_and_pres p0
	ORDER BY physician_id
)
SELECT speciality, COUNT(speciality)
FROM physician_speciality psp
JOIN physician_stat pst
ON psp.id = pst.physician_id
WHERE pst.sentProcedure > 0 AND pst.sentPrescription = 0
GROUP BY speciality

--------------
-- Query 9
--------------

DROP TABLE IF EXISTS patient_treatment;
DROP TABLE IF EXISTS physician_speciality;
DROP TABLE IF EXISTS event_category;
CREATE TABLE event_category (
	event_name VARCHAR(50),
	category VARCHAR(100)
);
INSERT INTO event_category VALUES
('Chemotherapy', 'Procedure'),
('Radiation', 'Procedure'),
('Immunosuppressants', 'Prescription'),
('BTKI', 'Prescription'),
('Biopsy', 'Test');

CREATE TABLE physician_speciality (
	id INTEGER PRIMARY KEY,
	speciality VARCHAR(50)
);
INSERT INTO physician_speciality VALUES
(1000, 'Radiologist'),
(2000, 'Oncologist'),
(3000, 'Hermatologist'),
(4000, 'Oncologist'),
(5000, 'Pathologist'),
(6000, 'Oncologist');

CREATE TABLE patient_treatment (
	patient_id INT,
	event_name VARCHAR(50),
	physician_id INT REFERENCES physician_speciality(id)
);
INSERT INTO patient_treatment VALUES
(1, 'Radiation', 1000),
(2, 'Chemotherapy', 2000),
(1, 'Biopsy', 1000),
(3, 'Immunosuppressants', 2000),
(4, 'BTKI', 3000),
(5, 'Radiation', 4000),
(4, 'Chemotherapy', 2000),
(1, 'Biopsy', 5000),
(6, 'Chemotherapy', 6000);

-- 8. From the following 3 tables (event_category, physician_speciality, patient_treatment)
-- 		write a SQL query to get the histogram of specialties
--		of the unique physicians who have done the procedures
--		but never prescribed anything.

WITH prescription AS (
	SELECT physician_id
	FROM patient_treatment pt
	JOIN event_category ec
	ON ec.event_name = pt.event_name
	WHERE category = 'Prescription'
)
SELECT speciality, COUNT(1) speciality_count
FROM patient_treatment pt
JOIN event_category ec ON pt.event_name = ec.event_name
JOIN physician_speciality ps ON ps.id = pt.physician_id
WHERE category = 'Procedure' AND
	pt.physician_id NOT IN (SELECT * FROM prescription)
GROUP BY speciality

--------------
-- Query 10
--------------

DROP TABLE IF EXISTS weather CASCADE;
CREATE TABLE weather (
	id INT PRIMARY KEY,
	city VARCHAR(50) NOT NULL,
	temperature INT NOT NULL,
	day DATE NOT NULL
);
INSERT INTO weather VALUES
(1, 'London', -1, date '2021-01-01'),
(2, 'London', -2, date '2021-01-02'),
(3, 'London', 4, date '2021-01-03'),
(4, 'London', 1, date '2021-01-04'),
(5, 'London', -2, date '2021-01-05'),
(6, 'London', -5, date '2021-01-06'),
(7, 'London', -7, date '2021-01-07'),
(8, 'London', 5, date '2021-01-08'),
(9, 'London', -20, date '2021-01-09'),
(10, 'London', 20, date '2021-01-10'),
(11, 'London', 22, date '2021-01-11'),
(12, 'London', -1, date '2021-01-12'),
(13, 'London', -2, date '2021-01-13'),
(14, 'London', -2, date '2021-01-14'),
(15, 'London', -4, date '2021-01-15'),
(16, 'London', -9, date '2021-01-16'),
(17, 'London', 0, date '2021-01-17'),
(18, 'London', -10, date '2021-01-18'),
(19, 'London', -11, date '2021-01-19'),
(20, 'London', -12, date '2021-01-20'),
(21, 'London', -11, date '2021-01-21');

-- 10. Write a query to fetch N consecutive records and that satisfies the following condition
-- 10a. N consecutive days freezing with PK.

WITH t1 AS (
	SELECT *,
		id - ROW_NUMBER() OVER (ORDER BY id) diff
	FROM weather
	WHERE temperature < 0
), t2 AS (
	SELECT *, COUNT(*) OVER (PARTITION BY diff ORDER BY diff) cnt
	FROM t1
)
SELECT *
FROM t2
WHERE cnt = 5;

-- 10b. When the table does not have a primary key
CREATE OR REPLACE VIEW vw_weather AS
	SELECT city, temperature FROM weather;

WITH t0 AS (
	SELECT *, ROW_NUMBER() OVER (PARTITION by city) id
	FROM vw_weather
), t1 AS (
	SELECT *,
		id - ROW_NUMBER() OVER (ORDER BY id) diff
	FROM t0
	WHERE temperature < 0
), t2 AS (
	SELECT *, COUNT(*) OVER (PARTITION BY diff ORDER BY diff) cnt
	FROM t1
)
SELECT *
FROM t2
WHERE cnt = 4;

-- 10c. Query logic based on data field

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
	order_id VARCHAR(20) NOT NULL,
	order_date DATE NOT NULL
);
INSERT INTO orders VALUES
('ORD1001', DATE '2021-01-01'),
('ORD1002', DATE '2021-02-01'),
('ORD1003', DATE '2021-02-02'),
('ORD1004', DATE '2021-02-03'),
('ORD1005', DATE '2021-03-01'),
('ORD1006', DATE '2021-06-01'),
('ORD1007', DATE '2021-12-25'),
('ORD1008', DATE '2021-12-26');

WITH day_year AS (
	SELECT *,
		order_date - DATE '2021-01-01' day_of_year
	FROM orders
), day_cnt AS (
	SELECT *,
		day_of_year - ROW_NUMBER() OVER (ORDER BY order_id) cnt
	FROM day_year
)
SELECT order_id, order_date
FROM day_cnt
WHERE cnt = 29;
