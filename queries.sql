--
-- Autor: Alejandro
-- Fecha: Noviembre 2026
-- Descripción: Creación de las consultas de grades_db
--

USE grades_db;


-- Consulta 1: Todas las asignaturas
SELECT * 
FROM subjects;


-- Consulta 2: Asignatura con acrónimo 'IISSI-1'
SELECT * 
FROM subjects s
WHERE s.acronym = 'IISSI-1';


-- Consulta 3: Nombres y acrónimos de todas las asignaturas
SELECT s.subject_name, s.acronym 
FROM subjects s;


-- Consulta 4: Asignaturas de formación básica
SELECT s.subject_name, s.acronym, s.subject_type
FROM subjects s
WHERE s.subject_type = 'Formación Básica';


-- Consulta 5: Estudiantes con método de acceso por Selectividad
SELECT p.first_name, p.last_name, st.access_method
FROM students st
JOIN people p ON st.student_id = p.person_id
WHERE st.access_method = 'Selectividad';


-- Consulta 6: Profesores con categoría Catedrático
SELECT p.first_name, p.last_name, pr.category
FROM professors pr
JOIN people p ON pr.professor_id = p.person_id
WHERE pr.category = 'Catedrático';


-- Vista: Profesores con información completa
CREATE OR REPLACE VIEW v_professors AS
SELECT 
    pr.professor_id,
    pr.category,
    p.person_id,
    p.dni,
    p.first_name,
    p.last_name,
    p.age,
    p.email
FROM professors pr
JOIN people p ON pr.professor_id = p.person_id;


-- Vista: Estudiantes con información completa
CREATE OR REPLACE VIEW v_students AS
SELECT 
    st.student_id,
    st.access_method,
    p.person_id,
    p.dni,
    p.first_name,
    p.last_name,
    p.age,
    p.email
FROM students st
JOIN people p ON st.student_id = p.person_id;


-- Consulta 7: Media de las notas del grupo con ID 1
SELECT AVG(g.grade_value) AS average_grade
FROM grades g
WHERE g.group_id = 1;


-- Consulta 8: Total de créditos de las asignaturas del grado con ID 3
SELECT SUM(s.credits) AS total_credits
FROM subjects s 
WHERE s.degree_id = 3;


-- Consulta 9: Número total de estudiantes
SELECT COUNT(*) AS total_students
FROM students;


-- Consulta 10: Número de grupos por tipo de actividad
SELECT activity, COUNT(*) AS total_groups
FROM groups
GROUP BY activity;


-- Consulta 11: Máxima nota obtenida
SELECT MAX(g.grade_value) AS max_grade
FROM grades g;


-- Consulta 12: Mínima nota obtenida
SELECT MIN(g.grade_value) AS min_grade
FROM grades g;


-- Consulta 13: Notas con valor menor que 5 o mayor que 9
SELECT g.grade_id, g.grade_value, g.exam_call
FROM grades g
WHERE g.grade_value < 5 OR g.grade_value > 9;


-- Consulta 14: Notas entre 5 y 7 (inclusive)
SELECT g.grade_id, g.grade_value, g.exam_call
FROM grades g
WHERE g.grade_value BETWEEN 5 AND 7;


-- Consulta 15: Asignaturas de 6 o 12 créditos
SELECT s.subject_name, s.credits
FROM subjects s
WHERE s.credits IN (6, 12);


-- Consulta 16: Personas con edad entre 20 y 30 años
SELECT p.first_name, p.last_name, p.age
FROM people p
WHERE p.age BETWEEN 20 AND 30;


-- Consulta 17: Nombres de grupos diferentes
SELECT DISTINCT g.group_name 
FROM groups g;


-- Consulta 18: Tipos de asignatura diferentes
SELECT DISTINCT s.subject_type
FROM subjects s;


-- Consulta 19: Años académicos registrados
SELECT DISTINCT g.academic_year
FROM groups g
ORDER BY g.academic_year DESC;


-- Consulta 20: Máxima nota del estudiante con ID 6
SELECT MAX(g.grade_value) AS max_grade
FROM grades g
WHERE g.student_id = 6;

-- Consulta 21: IDs de estudiantes del año académico 2024
SELECT DISTINCT ge.student_id
FROM students_groups ge
WHERE ge.group_id IN (
    SELECT g.group_id 
    FROM groups g 
    WHERE g.academic_year = 2024
);

-- Consulta 22: Asignaturas con más créditos que la media
SELECT s.subject_name, s.credits
FROM subjects s
WHERE s.credits > (SELECT AVG(credits) FROM subjects);


-- Consulta 23: Personas con DNI terminado en 'A'
SELECT p.first_name, p.last_name, p.dni
FROM people p
WHERE p.dni LIKE '%A';

-- Consulta 24: Asignaturas cuyo nombre empieza por 'Fundamentos'
SELECT s.subject_name
FROM subjects s
WHERE s.subject_name LIKE 'Fundamentos%';

-- Consulta 25: Personas con nombres de 5 letras (usar 5 guiones bajos)
SELECT p.first_name, p.last_name
FROM people p
WHERE p.first_name LIKE '_____';


-- Consulta 26: Grupos del año 2024
SELECT g.group_name, g.activity, g.academic_year
FROM groups g
WHERE g.academic_year = 2024;

-- Consulta 27: Grupos entre 2020 y 2023
SELECT g.group_name, g.activity, g.academic_year
FROM groups g
WHERE g.academic_year BETWEEN 2020 AND 2023
ORDER BY g.academic_year;


-- Vista 1: Notas con matrícula de honor
CREATE OR REPLACE VIEW v_grades_with_honors AS
SELECT g.grade_id, g.student_id, g.group_id, g.grade_value, g.exam_call
FROM grades g
WHERE g.with_honors = 1;

-- Vista 2: Notas de todos los estudiantes con información completa
CREATE OR REPLACE VIEW v_student_grades AS
SELECT 
    p.person_id,
    p.first_name,
    p.last_name,
    p.dni,
    g.grade_value,
    g.exam_call,
    g.with_honors,
    gr.group_name,
    gr.activity,
    gr.academic_year,
    s.subject_name,
    s.acronym,
    s.credits
FROM people p
JOIN students st ON p.person_id = st.student_id
JOIN grades g ON st.student_id = g.student_id
JOIN groups gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

-- Vista 3: Información de profesores con sus cargas docentes
CREATE OR REPLACE VIEW v_professor_loads AS
SELECT
    p.person_id,
    p.first_name,
    p.last_name,
    pr.category,
    tl.credits AS teaching_credits,
    gr.group_name,
    gr.activity,
    gr.academic_year,
    s.subject_name,
    s.acronym
FROM people p
JOIN professors pr ON p.person_id = pr.professor_id
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
JOIN groups gr ON tl.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

-- Vista 4: Estudiantes por grado
CREATE OR REPLACE VIEW v_degree_students AS
SELECT DISTINCT
    d.degree_id,
    d.degree_name,
    p.person_id,
    p.first_name,
    p.last_name,
    st.access_method,
    gr.academic_year
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN students_groups ge ON gr.group_id = ge.group_id
JOIN students st ON ge.student_id = st.student_id
JOIN people p ON st.student_id = p.person_id;

-- Uso de vistas: Consultas sobre las vistas creadas
-- Consulta 28: Total de matrículas de honor
SELECT COUNT(*) AS total_honors
FROM v_grades_with_honors;

-- Consulta 29: Nota media de cada estudiante
SELECT v.first_name, v.last_name, AVG(v.grade_value) AS average_grade
FROM v_student_grades v
GROUP BY v.person_id, v.first_name, v.last_name;


-- Consulta 30: Notas ordenadas por valor (de menor a mayor)
SELECT g.grade_id, g.student_id, g.grade_value, g.exam_call
FROM grades g
ORDER BY g.grade_value ASC;

-- Consulta 31: Notas ordenadas por valor descendente
SELECT g.grade_id, g.student_id, g.grade_value, g.exam_call
FROM grades g
ORDER BY g.grade_value DESC;

-- Consulta 32: Las 5 mejores notas
SELECT g.grade_id, g.student_id, g.grade_value, g.exam_call
FROM grades g
ORDER BY g.grade_value DESC
LIMIT 5;

-- Consulta 33: Notas aprobadas ordenadas por estudiante
SELECT 
    st.first_name,
    st.last_name,
    g.grade_value,
    g.exam_call
FROM grades g
JOIN v_students st ON g.student_id = st.student_id
WHERE g.grade_value >= 5
ORDER BY st.last_name ASC, st.first_name ASC;

-- Consulta 34: Paginación - Segunda página de 5 notas
SELECT g.grade_id, g.student_id, g.grade_value
FROM grades g
ORDER BY g.grade_value DESC
LIMIT 5 OFFSET 5;

-- Consulta 35: Tercera página de 5 notas
SELECT g.grade_id, g.student_id, g.grade_value
FROM grades g
ORDER BY g.grade_value DESC
LIMIT 5 OFFSET 10;

-- Consulta 36: Grupos ordenados por año académico descendente
SELECT g.group_name, g.activity, g.academic_year
FROM groups g
ORDER BY g.academic_year DESC, g.group_name ASC;


-- Consulta 37: Estudiantes con sus grupos (INNER JOIN)
SELECT 
    st.first_name,
    st.last_name,
    gr.group_name,
    gr.activity,
    gr.academic_year
FROM v_students st
JOIN students_groups ge ON st.student_id = ge.student_id
JOIN groups gr ON ge.group_id = gr.group_id;



-- Consulta 38: Asignaturas con información del grado
SELECT 
    d.degree_name,
    s.subject_name,
    s.acronym,
    s.credits,
    s.course,
    s.subject_type
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
ORDER BY d.degree_name, s.course;


-- Consulta 39: Notas con nombre del estudiante y asignatura
SELECT 
    st.first_name,
    st.last_name,
    s.subject_name,
    s.acronym,
    g.grade_value,
    g.exam_call,
    gr.academic_year
FROM grades g
JOIN v_students st ON g.student_id = st.student_id
JOIN groups gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;


-- Consulta 40: Profesores con grupos que imparten
SELECT 
    pr.first_name,
    pr.last_name,
    pr.category,
    s.subject_name,
    gr.group_name,
    gr.activity,
    tl.credits AS teaching_credits
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
JOIN groups gr ON tl.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;


-- Consulta 41: Estudiantes matriculados en asignaturas (a través de grupos)
SELECT DISTINCT
    st.first_name,
    st.last_name,
    s.subject_name,
    s.acronym,
    gr.academic_year
FROM v_students st
JOIN students_groups ge ON st.student_id = ge.student_id
JOIN groups gr ON ge.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id
ORDER BY st.last_name, s.subject_name;


-- Consulta 42: LEFT JOIN - Todos los estudiantes, con o sin notas
SELECT 
    st.first_name,
    st.last_name,
    g.grade_value,
    g.exam_call
FROM v_students st
LEFT JOIN grades g ON st.student_id = g.student_id;


-- Consulta 43: Nota media de cada estudiante
SELECT 
    st.first_name,
    st.last_name,
    AVG(g.grade_value) AS average_grade,
    COUNT(*) AS total_grades
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
GROUP BY st.student_id, st.first_name, st.last_name;

-- Consulta 44: Número de estudiantes por método de acceso
SELECT 
    st.access_method,
    COUNT(*) AS total_students
FROM students st
GROUP BY st.access_method;

-- Consulta 45: Número de asignaturas por grado
SELECT 
    d.degree_name,
    COUNT(*) AS total_subjects
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
GROUP BY d.degree_id, d.degree_name;

-- Consulta 46: Número de grupos por asignatura
SELECT 
    s.subject_name,
    s.acronym,
    COUNT(*) AS total_groups
FROM subjects s
JOIN groups gr ON s.subject_id = gr.subject_id
GROUP BY s.subject_id, s.subject_name, s.acronym;

-- Consulta 47: Nota media por convocatoria
SELECT 
    g.exam_call,
    AVG(g.grade_value) AS average_grade,
    COUNT(*) AS total_grades
FROM grades g
GROUP BY g.exam_call;

-- Consulta 48: Nota media por asignatura en cada convocatoria
SELECT 
    s.subject_name,
    g.exam_call,
    AVG(g.grade_value) AS average_grade,
    COUNT(*) AS total_grades
FROM grades g
JOIN groups gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id
GROUP BY s.subject_id, s.subject_name, g.exam_call
ORDER BY s.subject_name, g.exam_call;

-- Consulta 49: Número de estudiantes por año académico
SELECT 
    gr.academic_year,
    COUNT(DISTINCT ge.student_id) AS total_students
FROM groups gr
JOIN students_groups ge ON gr.group_id = ge.group_id
GROUP BY gr.academic_year
ORDER BY gr.academic_year DESC;

-- Consulta 50: Carga docente total por profesor
SELECT 
    pr.first_name,
    pr.last_name,
    pr.category,
    SUM(tl.credits) AS total_credits
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
GROUP BY pr.professor_id, pr.first_name, pr.last_name, pr.category;


-- Consulta 51: Estudiantes con nota media superior a 7
SELECT 
    st.first_name,
    st.last_name,
    AVG(g.grade_value) AS average_grade
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
GROUP BY st.student_id, st.first_name, st.last_name
HAVING AVG(g.grade_value) > 7;

-- Consulta 52: Asignaturas con más de 3 grupos
SELECT 
    s.subject_name,
    COUNT(*) AS total_groups
FROM subjects s
JOIN groups gr ON s.subject_id = gr.subject_id
GROUP BY s.subject_id, s.subject_name
HAVING COUNT(*) > 3;

-- Consulta 53: Grupos con más de 15 estudiantes
SELECT 
    gr.group_name,
    gr.activity,
    COUNT(*) AS total_students
FROM groups gr
JOIN students_groups ge ON gr.group_id = ge.group_id
GROUP BY gr.group_id, gr.group_name, gr.activity
HAVING COUNT(*) > 15;

-- Consulta 54: Asignaturas con nota media superior a 5.5
SELECT 
    s.subject_name,
    AVG(g.grade_value) AS average_grade,
    COUNT(*) AS total_grades
FROM subjects s
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN grades g ON gr.group_id = g.group_id
GROUP BY s.subject_id, s.subject_name
HAVING AVG(g.grade_value) > 5.5;


-- Consulta 55: Top 3 asignaturas con más estudiantes en 2024
SELECT 
    s.subject_name,
    COUNT(DISTINCT ge.student_id) AS total_students
FROM subjects s
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN students_groups ge ON gr.group_id = ge.group_id
WHERE gr.academic_year = 2024
GROUP BY s.subject_id, s.subject_name
ORDER BY total_students DESC, s.subject_name ASC
LIMIT 3;

-- Consulta 56: Estudiantes con más de 1 matrícula de honor
SELECT 
    st.first_name,
    st.last_name,
    COUNT(*) AS total_honors
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
WHERE g.with_honors = 1
GROUP BY st.student_id, st.first_name, st.last_name
HAVING COUNT(*) > 1;

-- Consulta 57: Grados con más estudiantes en 2024
SELECT 
    d.degree_name,
    COUNT(DISTINCT ge.student_id) AS total_students
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN students_groups ge ON gr.group_id = ge.group_id
WHERE gr.academic_year = 2024
GROUP BY d.degree_id, d.degree_name
ORDER BY COUNT(DISTINCT ge.student_id) DESC;

-- Consulta 58: Nota máxima de cada estudiante con nombre y apellidos
SELECT 
    st.first_name,
    st.last_name,
    MAX(g.grade_value) AS max_grade
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
GROUP BY st.student_id, st.first_name, st.last_name
ORDER BY MAX(g.grade_value) DESC;

-- Consulta 59: Profesores que imparten en más de 1 grupo
SELECT 
    pr.first_name,
    pr.last_name,
    COUNT(DISTINCT tl.group_id) AS total_groups
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
GROUP BY pr.professor_id, pr.first_name, pr.last_name
HAVING COUNT(DISTINCT tl.group_id) > 1;

-- Consulta 60: Asignaturas que pertenecen a grados con más de 15 asignaturas
SELECT DISTINCT s.subject_name, d.degree_name
FROM subjects s
JOIN degrees d ON s.degree_id = d.degree_id
WHERE d.degree_id IN (
    SELECT degree_id
    FROM subjects
    GROUP BY degree_id
    HAVING COUNT(*) > 15
);


-- Consulta 61: Estudiantes que nunca han suspendido (todas sus notas ≥ 5)
SELECT st.student_id, st.first_name, st.last_name, MIN(g.grade_value) as min_grade
FROM v_students st
JOIN grades g ON st.student_id = g.student_id 
GROUP BY st.student_id, st.first_name, st.last_name
HAVING MIN(g.grade_value) >= 5;


-- Consulta 62: Profesores que solo imparten teoría (no laboratorios)
SELECT DISTINCT pr.professor_id, pr.first_name, pr.last_name, pr.category
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
WHERE pr.professor_id NOT IN (
	SELECT tl2.professor_id
	FROM teaching_loads tl2
	JOIN groups gr ON tl2.group_id = gr.group_id
	WHERE gr.activity = 'Laboratorio'
);


-- Consulta 63: Asignaturas sin grupos creados (usar LEFT JOIN)
SELECT s.subject_id, s.subject_name, s.acronym, s.credits, s.course, s.subject_type
FROM subjects s
LEFT JOIN groups gr ON s.subject_id = gr.subject_id
WHERE gr.group_id IS NULL;


-- Consulta 64: Nota media de cada grado en el año 2024
SELECT d.degree_id, d.degree_name, AVG(g.grade_value) AS average_grade, COUNT(*) AS total_grades
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN grades g ON gr.group_id = g.group_id
WHERE gr.academic_year = 2024
GROUP BY d.degree_id, d.degree_name;


-- Consulta 65: Estudiantes con la mejor nota de cada asignatura
SELECT DISTINCT v1.subject_name, v1.acronym, v1.first_name, v1.last_name, v1.grade_value AS max_grade
FROM v_student_grades v1
WHERE v1.grade_value = (
	SELECT MAX(v2.grade_value)
	FROM v_student_grades v2
	WHERE v2.acronym = v1.acronym
)
ORDER BY v1.subject_name ASC;


-- Consulta 66: Grupos ordenados por número de estudiantes matriculados
SELECT gr.group_id, s.acronym, gr.group_name, gr.activity, gr.academic_year, COUNT(ge.student_id) AS total_students
FROM groups gr
JOIN subjects s ON gr.subject_id = s.subject_id
LEFT JOIN students_groups ge ON gr.group_id = ge.group_id
GROUP BY gr.group_id, s.acronym, gr.group_name, gr.activity, gr.academic_year
ORDER BY total_students DESC, gr.group_id ASC;


-- Consulta 67:Profesores con carga docente superior a 15 créditos
SELECT pr.professor_id, pr.first_name, pr.last_name, pr.category, SUM(tl.credits) AS total_credits
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
GROUP BY pr.professor_id, pr.first_name, pr.last_name, pr.category
HAVING SUM(tl.credits) > 15;


-- Consulta 68: Año académico con más matrículas de honor
SELECT gr.academic_year, COUNT(*) AS total_honors
FROM grades g
JOIN groups gr ON g.group_id = gr.group_id
WHERE g.with_honors = 1
GROUP BY gr.academic_year
ORDER BY total_honors DESC
LIMIT 1;

-- Consulta 69: Asignaturas con mayor dispersión de notas (usando STD o VARIANCE)
SELECT s.subject_id, s.subject_name, s.acronym, ROUND(AVG(g.grade_value), 2) AS average_grade, ROUND(STD(g.grade_value), 2) AS std_deviation, ROUND(VARIANCE(g.grade_value), 2) AS variance_grade
FROM subjects s
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN grades g ON gr.group_id = g.group_id
GROUP BY s.subject_id, s.subject_name, s.acronym
ORDER BY std_deviation DESC;

-- Consulta 70: Estudiantes matriculados en todas las asignaturas de primer curso
SELECT st.student_id, st.first_name, st.last_name, COUNT(DISTINCT ss.subject_id) AS first_year_subjects
FROM v_students st
JOIN students_subjects ss ON st.student_id = ss.student_id
JOIN subjects s ON ss.subject_id = s.subject_id
WHERE s.course = 1
GROUP BY st.student_id, st.first_name, st.last_name
HAVING COUNT(DISTINCT ss.subject_id) = (
    SELECT COUNT(*)
    FROM subjects
    WHERE course = 1
);


-- TESTS PARA EJECUTAR LOS EJEMPLOS DEL LAB 5 DE FUNCIONES AUXILIARES --
-- Cálculo nota media estudiante.
-- Usar en una consulta SELECT
SELECT f_student_average(6) AS 'Promedio del estudiante 6';

-- Usarla junto con otros datos
SELECT p.person_id, p.first_name, p.last_name,
       f_student_average(s.student_id) AS promedio
FROM people p
JOIN students s ON s.student_id = p.person_id
ORDER BY promedio DESC;

-- Usar en una cláusula WHERE
SELECT p.first_name, p.last_name
FROM people p
JOIN students s ON s.student_id = p.person_id
WHERE f_student_average(s.student_id) >= 7.0;


-- Verificación si un estudiante está matriculado en una asignatura.
-- Listar asignaturas con indicador de matrícula del estudiante 6 del grado 3
SELECT s.subject_id, s.subject_name,
       f_is_student_enrolled(6, s.subject_id) AS matriculado
FROM subjects s
WHERE s.degree_id = 3;

-- Usar en un WHERE
SELECT s.subject_name
FROM subjects s
WHERE f_is_student_enrolled(6, s.subject_id) = TRUE;



-- Verificación límite de grupos por asignatura
-- Verificar si la asignatura 1 ya tiene el máximo de grupos de teoría en 2025
SELECT f_subject_group_limit_reached(1, 'Teoría', 2025) AS 'Límite alcanzado';

-- Listar asignaturas que han alcanzado el límite de grupos de teoría
SELECT s.subject_id, s.subject_name, s.acronym
FROM subjects s
WHERE f_subject_group_limit_reached(s.subject_id, 'Teoría', 2025) = TRUE;



-- TESTS PARA EJECUTAR LOS EJERCICIOS PROPUESTO DEL LAB 5
-- Ejercicio 1
-- Caso 1: Un alumno con varias notas en la misma convocatoria
SELECT f_count_student_grades(6, 'Primera') AS notas_alumno_6_primera;

-- Caso 2: Un alumno con 1 nota en Segunda convocatoria
SELECT f_count_student_grades(16, 'Segunda') AS notas_alumno_16_segunda;

-- Caso 3: Un alumno sin notas en esa convocatoria
SELECT f_count_student_grades(6, 'Extraordinaria') AS notas_alumno_6_extra;


-- Ejercicio 2
-- Caso 1: Profesor 1
SELECT f_professor_total_credits(1) AS creditos_profesor_1;

-- Caso 2: Profesor 5
SELECT f_professor_total_credits(5) AS creditos_profesor_5;

-- Caso 3: Todos los profesores con su carga total calculada con la función
SELECT pr.professor_id, pr.first_name, pr.last_name, f_professor_total_credits(pr.professor_id) AS total_credits
FROM v_professors pr
ORDER BY total_credits DESC;

-- Caso 4: Un ID de profesor que no exista
SELECT f_professor_total_credits(999) AS creditos_inexistente;



-- Ejercicio 3:
-- Vemos que el grado 3 tiene 132 créditos
SELECT COALESCE(SUM(credits), 0) AS creditos_actuales
FROM subjects
WHERE degree_id = 3;

-- Insertamos asignaturas de 12 créditos hasta quedarnos justo en 240
INSERT INTO subjects (degree_id, subject_name, acronym, credits, course, subject_type) VALUES
    (3, 'Prueba 240 - 1', 'P240_1', 12, 4, 'Optativa'),
    (3, 'Prueba 240 - 2', 'P240_2', 12, 4, 'Optativa'),
    (3, 'Prueba 240 - 3', 'P240_3', 12, 4, 'Optativa'),
    (3, 'Prueba 240 - 4', 'P240_4', 12, 4, 'Optativa'),
    (3, 'Prueba 240 - 5', 'P240_5', 12, 4, 'Optativa'),
    (3, 'Prueba 240 - 6', 'P240_6', 12, 4, 'Optativa'),
    (3, 'Prueba 240 - 7', 'P240_7', 12, 4, 'Optativa'),
    (3, 'Prueba 240 - 8', 'P240_8', 12, 4, 'Optativa'),
    (3, 'Prueba 240 - 9', 'P240_9', 12, 4, 'Optativa');

-- Intentamos meter otros 6 créditos
INSERT INTO subjects (degree_id, subject_name, acronym, credits, course, subject_type) VALUES
    (3, 'Prueba 240 - 10', 'P240_10', 6, 4, 'Optativa');

-- Probamos con UPDATE
UPDATE subjects SET credits = 12 WHERE subject_id = 4;

-- Limpiamos los cambios
DELETE FROM subjects WHERE acronym LIKE 'P240_%';



-- Ejercicio 4
-- Vemos cuántos créditos tiene ahora mismo el alumno 6 en 2024
SELECT SUM(t.credits) AS creditos_2024
FROM (
    SELECT DISTINCT g.subject_id, s.credits
    FROM students_groups sg
    JOIN groups g ON g.group_id = sg.group_id
    JOIN subjects s ON s.subject_id = g.subject_id
    WHERE sg.student_id = 6 AND g.academic_year = 2024
) t;

-- Matriculamos al alumno 6 en 4 asignaturas más de 6 créditos para llegar a 60
INSERT INTO students_subjects (student_id, subject_id) VALUES (6, 3), (6, 4), (6, 5), (6, 6), (6, 7);
INSERT INTO groups (group_id, subject_id, group_name, activity, academic_year) VALUES
    (101, 3, 'T1', 'Teoría', 2024),
    (102, 4, 'T1', 'Teoría', 2024),
    (103, 5, 'T1', 'Teoría', 2024),
    (104, 6, 'T1', 'Teoría', 2024),
    (105, 7, 'T1', 'Teoría', 2024);
INSERT INTO students_groups (student_id, group_id) VALUES (6, 101), (6, 102), (6, 103), (6, 104);

-- Intentamos matricularlo en la 5ª. DEBE FALLAR
INSERT INTO students_groups (student_id, group_id) VALUES (6, 105);

-- Limpiamos los cambios
DELETE FROM students_groups WHERE group_id >= 101;
DELETE FROM groups WHERE group_id >= 101;
DELETE FROM students_subjects WHERE student_id = 6 AND subject_id IN (3, 4, 5, 6, 7);