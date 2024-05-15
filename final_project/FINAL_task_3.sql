-- 3. Створення механізму звільнення існуючого співробітника.

-- Процедура fire_an_employee з пакету util
PROCEDURE fire_an_employee(p_employee_id IN NUMBER) IS
  
  v_employee_name employees.first_name%TYPE;
  v_employee_last_name employees.last_name%TYPE;
  v_job_id employees.job_id%TYPE;
  v_department_id employees.department_id%TYPE;
  v_delete_no_data_found EXCEPTION;
  
BEGIN
  
  log_util.log_start(p_proc_name => 'fire_an_employee', p_text => 'Видалення співробітника.');
  
  check_work_time;
  
  SELECT e.first_name, e.last_name, e.job_id, e.department_id
  INTO v_employee_name, v_employee_last_name, v_job_id, v_department_id
  FROM employees e
  WHERE e.employee_id = p_employee_id;

    BEGIN
        DELETE FROM employees e
        WHERE e.employee_id = p_employee_id;
        
        IF SQL%rowcount = 0 THEN
            RAISE v_delete_no_data_found;
        END IF;
        
        EXCEPTION
            WHEN v_delete_no_data_found THEN raise_application_error(-20004, 'Переданий співробітник '|| p_employee_id || ' не існує. Код помилки: '||SQLERRM);
            WHEN OTHERS THEN log_util.log_error(p_proc_name => 'fire_an_employee', p_sqlerrm => SQLERRM);
            raise_application_error(-20001, 'При видаленні співробітника виникла помилка. Подробиці: ' || SQLERRM);
    END;
    
  dbms_output.put_line('Співробітник ' || v_employee_name || ' ' || v_employee_last_name || ', ' || v_job_id || ', ' || v_department_id || ' успішно видалено');
  
  log_util.log_finish(p_proc_name => 'fire_an_employee', p_text => 'Працівник успішно видалений.');
    
  COMMIT;
    
END fire_an_employee;

/* Для історичних записів була створена таблиця employees_history яка має параметри employee_id NUMBER, hire_date DATE, fired_date DATE. 
Оновлення таблиці відбувається при додаванні та видаленні співробітника за тригером*/

CREATE OR REPLACE TRIGGER employees_history
	AFTER INSERT OR DELETE ON employees
	FOR EACH ROW
DECLARE
    v_fired_date DATE;
    v_emp_exists NUMBER;
BEGIN
    IF INSERTING THEN
        INSERT INTO employees_history (employee_id, hire_date)
        VALUES (:NEW.employee_id, TRUNC(SYSDATE, 'DD'));
    ELSIF DELETING THEN
        SELECT COUNT(*) INTO v_emp_exists FROM employees_history WHERE employee_id = :OLD.employee_id;
        IF v_emp_exists > 0 THEN
            UPDATE employees_history SET fired_date = TRUNC(SYSDATE, 'DD') WHERE employee_id = :OLD.employee_id;
        ELSE
            INSERT INTO employees_history (employee_id, hire_date, fired_date)
            VALUES (:OLD.employee_id, :OLD.hire_date, TRUNC(SYSDATE, 'DD'));
        END IF;
    END IF;		
END employees_history;
