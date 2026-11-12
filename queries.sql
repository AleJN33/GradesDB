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