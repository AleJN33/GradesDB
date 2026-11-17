--
-- Autor: Alejandro
-- Fecha: Noviembre 2026
-- Descripción: Ejecución de los procedimientos de procedures.sql
--

USE grades_db;



-- Borrar las notas del estudiante con DNI '10000006F'
-- CALL p_delete_student_grades('10000006F');
-- 
-- Verificar que se borraron
-- SELECT * FROM grades g
-- JOIN students s ON s.student_id = g.student_id
-- JOIN people p ON p.person_id = s.student_id
-- WHERE p.dni = '10000006F';
-- 
-- 
-- 
-- Borrar todos los datos (¡cuidado con esta operación!)
-- CALL p_delete_all_data();
-- 
-- Verificar que las tablas están vacías
-- SELECT COUNT(*) AS total_grades FROM grades;
-- SELECT COUNT(*) AS total_students FROM students;
-- SELECT COUNT(*) AS total_people FROM people;
-- 
-- 
-- Consultar la nota media del estudiante con ID 6
-- CALL p_student_average(6, @avg_student_6);
-- SELECT @avg_student_6 AS 'Promedio del estudiante 6';
-- 
-- Consultar para varios estudiantes
-- CALL p_student_average(7, @avg_student_7);
-- CALL p_student_average(8, @avg_student_8);
-- SELECT @avg_student_6, @avg_student_7, @avg_student_8;
-- 
-- 
-- 
-- Ver las notas del grupo 1 antes de la actualización
-- SELECT g.grade_id, p.first_name, p.last_name, g.grade_value, g.exam_call
-- FROM grades g
-- JOIN students s ON s.student_id = g.student_id
-- JOIN people p ON p.person_id = s.student_id
-- WHERE g.group_id = 1 AND g.exam_call = 'Primera'
-- ORDER BY g.grade_value;
-- 
-- Subir las notas del grupo 1 en la convocatoria 'Primera'
-- CALL p_boost_group_grades(1, 'Primera');
-- 
-- Verificar las notas después de la actualización
-- SELECT g.grade_id, p.first_name, p.last_name, g.grade_value, g.exam_call
-- FROM grades g
-- JOIN students s ON s.student_id = g.student_id
-- JOIN people p ON p.person_id = s.student_id
-- WHERE g.group_id = 1 AND g.exam_call = 'Primera'
-- ORDER BY g.grade_value;



-- Ver las notas del grupo 1 antes de asignar MH
-- SELECT g.grade_id, p.first_name, p.last_name, g.grade_value, 
--        g.with_honors, g.exam_call
-- FROM grades g
-- JOIN students s ON s.student_id = g.student_id
-- JOIN people p ON p.person_id = s.student_id
-- WHERE g.group_id = 1 AND g.exam_call = 'Primera'
-- ORDER BY g.grade_value DESC;
-- 
-- Asignar matrículas de honor al grupo 1 en la convocatoria 'Primera'
-- CALL p_assign_honors(1, 'Primera');
-- 
-- Verificar las matrículas asignadas
-- SELECT g.grade_id, p.first_name, p.last_name, g.grade_value, 
--        g.with_honors, g.exam_call
-- FROM grades g
-- JOIN students s ON s.student_id = g.student_id
-- JOIN people p ON p.person_id = s.student_id
-- WHERE g.group_id = 1 AND g.exam_call = 'Primera' AND g.with_honors = 1
-- ORDER BY g.grade_value DESC;



-- =============================================================
-- TABLA DE RESULTADOS
-- Un registro por test: PASS si la operación prohibida se rechazó,
-- FAIL si se permitió
-- =============================================================
CREATE OR REPLACE TABLE test_results (
    test_id VARCHAR(20) PRIMARY KEY,
    test_name VARCHAR(200) NOT NULL,
    test_message VARCHAR(500) NOT NULL,
    test_status ENUM('PASS','FAIL') NOT NULL,
    execution_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================
-- PROCEDIMIENTO AUXILIAR
-- Registra el resultado de un test. El nombre es el texto del mensaje
-- anterior a ':' (SUBSTRING_INDEX), por ejemplo 'RN01'
-- =============================================================
DELIMITER //
CREATE OR REPLACE PROCEDURE p_log_test(
    IN p_test_id VARCHAR(20),
    IN p_message VARCHAR(500),
    IN p_status ENUM('PASS','FAIL')
)
BEGIN
    INSERT INTO test_results(test_id, test_name, test_message, test_status)
    VALUES (p_test_id, SUBSTRING_INDEX(p_message, ':', 1), p_message, p_status);
END //
DELIMITER ;

-- =============================================================
-- TESTS DE RESTRICCIONES DECLARATIVAS
-- Todos siguen el mismo esquema:
-- 1. Un handler: si la operación lanza un error (SQLEXCEPTION), registra
--    PASS y sale del procedimiento (EXIT).
-- 2. p_populate() restaura los datos iniciales.
-- 3. Se intenta la operación que la regla prohíbe.
-- 4. Si la ejecución llega a la última línea, no hubo error: FAIL.
-- =============================================================

-- Test RN01: Matrícula de honor requiere nota >= 9
DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn01_mh_requirement()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN01', 'RN01: La MH requiere nota >= 9', 'PASS');

    CALL p_populate();

    UPDATE grades SET with_honors = 1 WHERE grade_id = 21;

    CALL p_log_test('RN01', 'ERROR: Se permitió MH con nota inferior a 9', 'FAIL');
END //
DELIMITER ;

-- Test RN09: Los atributos obligatorios no pueden quedar a NULL
DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn09_not_null_attributes()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN09', 'RN09: Los atributos obligatorios no pueden quedar a NULL', 'PASS');

    CALL p_populate();

    INSERT INTO people (person_id, dni, first_name, last_name, age, email)
        VALUES (103, '20000003C', NULL, 'Campos', 22, 'null@alum.us.es');

    CALL p_log_test('RN09', 'ERROR: Se permitió dejar atributos obligatorios a NULL', 'FAIL');
END //
DELIMITER ;

-- Test RN10: Los créditos de una asignatura pueden ser 6 o 12
DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn10_subject_credits()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN10', 'RN10: Los créditos de una asignatura pueden ser 6 o 12', 'PASS');

    CALL p_populate();

    INSERT INTO subjects (subject_id, degree_id, subject_name, acronym, credits, course, subject_type)
        VALUES (31, 3, 'Asignatura Créditos Inválidos', 'ACI', 8, 2, 'Obligatoria');

    CALL p_log_test('RN10', 'ERROR: Se permitió una asignatura con créditos inválidos', 'FAIL');
END //
DELIMITER ;

-- Test RN11: El valor de la nota está comprendido entre 0 y 10
DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn11_grade_range()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN11', 'RN11: La nota debe estar entre 0 y 10', 'PASS');

    CALL p_populate();

    INSERT INTO grades (grade_id, student_id, group_id, grade_value, exam_call, with_honors)
        VALUES (201, 6, 1, 11.0, 'Segunda', 0);

    CALL p_log_test('RN11', 'ERROR: Se permitió una nota fuera de rango', 'FAIL');
END //
DELIMITER ;

-- Test RN12: La edad de las personas está entre 16 y 70 años
DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn12_people_age()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN12', 'RN12: La edad de las personas debe estar entre 16 y 70', 'PASS');

    CALL p_populate();

    INSERT INTO people (person_id, dni, first_name, last_name, age, email)
        VALUES (105, '20000005E', 'Edad', 'Fuera', 80, 'edad@us.es');

    CALL p_log_test('RN12', 'ERROR: Se permitió una edad fuera de rango', 'FAIL');
END //
DELIMITER ;

-- Test RN13: Los años de un grado están entre 3 y 6
DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn13_degree_years()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN13', 'RN13: Los grados deben tener entre 3 y 6 años', 'PASS');

    CALL p_populate();

    INSERT INTO degrees (degree_id, degree_name, duration_years)
        VALUES (10, 'Grado Experimental', 2);

    CALL p_log_test('RN13', 'ERROR: Se permitió un grado con años fuera de rango', 'FAIL');
END //
DELIMITER ;

-- Test RN14: El DNI está formado por 8 números y una letra
DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn14_dni_format()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN14', 'RN14: El DNI debe tener 8 dígitos y una letra', 'PASS');

    CALL p_populate();

    INSERT INTO people (person_id, dni, first_name, last_name, age, email)
        VALUES (106, 'INVALIDO', 'DNI', 'Incorrecto', 30, 'dni@us.es');

    CALL p_log_test('RN14', 'ERROR: Se permitió un DNI con formato inválido', 'FAIL');
END //
DELIMITER ;

-- Test RN15: El año académico está entre 2000 y 2100
DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn15_academic_year()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN15', 'RN15: El año académico debe estar entre 2000 y 2100', 'PASS');

    CALL p_populate();

    INSERT INTO groups (group_id, subject_id, group_name, activity, academic_year)
        VALUES (20, 12, 'MD-T2025', 'Teoría', 1999);

    CALL p_log_test('RN15', 'ERROR: Se permitió un año académico fuera de rango', 'FAIL');
END //
DELIMITER ;

-- Test RN16: El curso de una asignatura está entre 1 y 6
DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn16_course_range()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN16', 'RN16: El curso de una asignatura debe estar entre 1 y 6', 'PASS');

    CALL p_populate();

    INSERT INTO subjects (subject_id, degree_id, subject_name, acronym, credits, course, subject_type)
        VALUES (30, 3, 'Asignatura Fuera de Curso', 'AFC', 6, 0, 'Obligatoria');

    CALL p_log_test('RN16', 'ERROR: Se permitió un curso fuera de rango', 'FAIL');
END //
DELIMITER ;

-- =============================================================
-- ORQUESTADOR DE RESTRICCIONES DECLARATIVAS
-- Vacía los resultados anteriores, ejecuta todos los tests y muestra el
-- resultado de cada uno y el total de PASS y FAIL
-- =============================================================
DELIMITER //
CREATE OR REPLACE PROCEDURE p_run_tests()
BEGIN
    DELETE FROM test_results;

    CALL p_test_rn01_mh_requirement();
    CALL p_test_rn09_not_null_attributes();
    CALL p_test_rn10_subject_credits();
    CALL p_test_rn11_grade_range();
    CALL p_test_rn12_people_age();
    CALL p_test_rn13_degree_years();
    CALL p_test_rn14_dni_format();
    CALL p_test_rn15_academic_year();
    CALL p_test_rn16_course_range();

    SELECT * FROM test_results ORDER BY execution_time, test_id;
    SELECT test_status, COUNT(*) AS total FROM test_results GROUP BY test_status;
END //
DELIMITER ;

CALL p_run_tests();

