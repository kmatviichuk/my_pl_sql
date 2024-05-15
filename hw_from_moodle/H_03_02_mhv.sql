CREATE OR REPLACE FUNCTION get_dep_name(p_employee_id IN NUMBER) RETURN VARCHAR2 IS 
    v_department_name hristina.departments.department_name%TYPE;
BEGIN
    SELECT d.department_name
    INTO v_department_name
    FROM hristina.departments d
    JOIN hristina.employees e 
    ON d.department_id = e.department_id
    WHERE e.employee_id = p_employee_id;
    
    RETURN v_department_name;
END get_dep_name;
/

--Приклад селекту
SELECT e.employee_id, 
       e.first_name, 
       e.last_name, 
       e.email, 
       e.phone_number, 
       e.hire_date, 
       get_job_title(e.employee_id) as job_title, 
       e.salary, 
       e.commission_pct, 
       e.manager_id, 
       get_dep_name(e.employee_id) as dept_name
FROM hristina.employees e;