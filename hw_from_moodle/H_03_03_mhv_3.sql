create or replace PACKAGE BODY util AS

--Функція get_dep_name повертає назву департаменту, де працює співробітник
FUNCTION get_dep_name(p_employee_id IN NUMBER) RETURN VARCHAR2 IS 
    v_department_name hristina.departments.department_name%TYPE;
BEGIN
    SELECT d.department_name
    INTO v_department_name
    FROM hristina.departments d
    JOIN hristina.employees e ON d.department_id = e.department_id
    WHERE e.employee_id = p_employee_id;

    RETURN v_department_name;
END get_dep_name;

--Функція get_job_title повертає назву посади співробітника
FUNCTION get_job_title(p_employee_id IN NUMBER) RETURN VARCHAR IS
    v_job_title hristina.jobs.job_title%TYPE;
BEGIN
    SELECT j.job_title
    INTO v_job_title
    FROM hristina.employees em
    JOIN hristina.jobs j
    ON em.job_id = j.job_id
    WHERE em.employee_id = p_employee_id;

    RETURN v_job_title;
END get_job_title;

--Процедура del_jobs видаляє заданий job_id 
PROCEDURE del_jobs(p_job_id IN VARCHAR2,
                   po_result OUT VARCHAR2) IS
BEGIN

    SELECT COUNT(j.job_id)
    INTO po_result
    FROM hristina.jobs j
    WHERE j.job_id = p_job_id;

    IF po_result = 0 THEN
       po_result := 'Посада ' || p_job_id || ' не існує';
        RETURN;
    END IF;

    DELETE FROM hristina.jobs j
    WHERE j.job_id = p_job_id;

    po_result := 'Посада ' || p_job_id || ' успішно видалена';

    COMMIT; 
END del_jobs;

END util;