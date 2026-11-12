--
-- Autor: Alejandro
-- Fecha: Noviembre 2026
-- Descripción: Creación del esquema de la base de datos grades_db
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