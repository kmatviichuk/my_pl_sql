-- 2. Створення механізму додавання нового співробітника:

-- Процедура add_employee з пакету util
PROCEDURE add_employee(p_first_name IN VARCHAR2,
                       p_last_name IN VARCHAR2,
                       p_email IN VARCHAR2,
                       p_phone_number IN VARCHAR2,
                       p_hire_date IN DATE DEFAULT trunc(SYSDATE, 'dd'),
                       p_job_id IN VARCHAR2,
                       p_salary IN NUMBER,
                       p_commission_pct IN VARCHAR2 DEFAULT NULL,
                       p_manager_id IN NUMBER DEFAULT 100,
                       p_department_id IN NUMBER) IS
    
    v_emp_id NUMBER;  
    v_jobs_count  NUMBER;
    v_department_count NUMBER;
    v_min_salary NUMBER;
    v_max_salary NUMBER;
    v_message logs.message%TYPE;
    
    FUNCTION get_emp_id RETURN NUMBER IS
      v_id NUMBER;
        BEGIN
           SELECT NVL(MAX(employee_id), 0)+1 INTO v_id FROM employees;
      RETURN v_id;
    END get_emp_id;
    
BEGIN
    log_util.log_start(p_proc_name => 'add_employee', p_text => 'Процедура додавання нового співробітника.');

    SELECT COUNT(*) INTO v_jobs_count FROM jobs WHERE job_id = p_job_id;
    IF v_jobs_count = 0 THEN
        v_message :=  'Введено неіснуючий код посади';
        raise_application_error(-20001, v_message);
    END IF;
    
    SELECT COUNT(*) INTO v_department_count FROM departments WHERE department_id = p_department_id;
    IF v_department_count = 0 THEN
        v_message := 'Введено неіснуючий ідентифікатор відділу';
        raise_application_error(-20002, v_message);
    END IF;  

    SELECT max_salary, min_salary INTO v_max_salary, v_min_salary FROM jobs WHERE job_id = p_job_id;
    IF p_salary > v_max_salary OR p_salary < v_min_salary THEN
        v_message := 'Введено неприпустиму заробітну плату для даного коду посади';
        RAISE_APPLICATION_ERROR(-20003, v_message);
    END IF;

    IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE = AMERICAN') IN ('SAT', 'SUN') 
       OR TO_CHAR(SYSDATE, 'HH24:MI') BETWEEN '18:01' AND '07:59' THEN
       v_message := 'Ви можете додавати нового співробітника лише в робочий час.';
       raise_application_error(-20004, v_message);
    END IF;        
    
    BEGIN
        v_emp_id := get_emp_id();
    
        INSERT INTO employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id)
        VALUES (v_emp_id, p_first_name, p_last_name, p_email, p_phone_number, p_hire_date, p_job_id, p_salary, p_commission_pct, p_manager_id, p_department_id);
    
        dbms_output.put_line('Співробітник ' || p_first_name || ' ' || p_last_name || ', ' || p_job_id || ', ' || p_department_id || ' успішно додано до системи');
    
    EXCEPTION
        WHEN OTHERS THEN log_util.log_error(p_proc_name => 'add_employee', p_sqlerrm => SQLERRM);
             RAISE;
    END;

    log_util.log_finish(p_proc_name => 'add_employee', p_text => 'Працівник успішно доданий.');
    
    COMMIT;
                       
END add_employee;
