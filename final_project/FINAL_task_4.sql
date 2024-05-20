-- 4. Створення механізму зміни атрибутів співробітника.

-- Процедура change_attribute_employee з пакету util:

PROCEDURE change_attribute_employee(p_employee_id       IN NUMBER,
                                    p_first_name        IN VARCHAR2 DEFAULT NULL,
                                    p_last_name         IN VARCHAR2 DEFAULT NULL,
                                    p_email             IN VARCHAR2 DEFAULT NULL,
                                    p_phone_number      IN VARCHAR2 DEFAULT NULL,
                                    p_job_id            IN VARCHAR2 DEFAULT NULL,
                                    p_salary            IN NUMBER DEFAULT NULL,
                                    p_commission_pct    IN NUMBER DEFAULT NULL,
                                    p_manager_id        IN NUMBER DEFAULT NULL,
                                    p_department_id     IN NUMBER DEFAULT NULL) IS
                                    
    v_sql VARCHAR2(1000);
    
BEGIN
  
    log_util.log_start(p_proc_name => 'change_attribute_employee', p_text => 'Запуск процедури зміни атрибутів співробітника.');

    IF COALESCE(p_first_name, p_last_name, p_email, p_phone_number, p_job_id, to_char(p_salary), to_char(p_commission_pct), to_char(p_manager_id), to_char(p_department_id)) IS NULL THEN
       log_util.log_finish(p_proc_name => 'change_attribute_employee', p_text => 'Немає данних для оновлення.');      
       raise_application_error(-20000, 'Немає данних для оновлення. Внесіть хочаб один атрибут. '); 
      RETURN;
    END IF;

    FOR atr IN (
        SELECT 'first_name' AS atr_name, p_first_name AS atr_value FROM dual UNION ALL
        SELECT 'last_name' AS atr_name, p_last_name AS atr_value FROM dual UNION ALL
        SELECT 'email' AS atr_name, p_email AS atr_value FROM dual UNION ALL
        SELECT 'phone_number' AS atr_name, p_phone_number AS atr_value FROM dual UNION ALL
        SELECT 'job_id' AS atr_name, p_job_id AS atr_value FROM dual UNION ALL
        SELECT 'salary' AS atr_name, to_char(p_salary) AS atr_value FROM dual UNION ALL
        SELECT 'commission_pct' AS atr_name, to_char(p_commission_pct) AS atr_value FROM dual UNION ALL
        SELECT 'manager_id' AS atr_name, to_char(p_manager_id) AS atr_value FROM dual UNION ALL
        SELECT 'department_id' AS atr_name, to_char(p_department_id) AS atr_value FROM dual
    )LOOP
        IF atr.atr_value IS NOT NULL THEN
            v_sql := v_sql || atr.atr_name || ' = ';
            
            IF NOT regexp_like(atr.atr_value, '^-?\d+(\.\d+)?$') THEN
                v_sql := v_sql || '''' || atr.atr_value || '''' || ', ';
            ELSE
                v_sql := v_sql || atr.atr_value || ', ';
            END IF;
        END IF;
    END LOOP;         
    
    v_sql := 'UPDATE employees SET ' || RTRIM(v_sql, ', ') || ' WHERE employee_id = :p_employee_id';
      
    BEGIN
        EXECUTE IMMEDIATE v_sql USING p_employee_id;
           dbms_output.put_line('У співробітника ' || p_employee_id || ' успішно оновлені атрибути.');
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            log_util.log_error(p_proc_name => 'change_attribute_employee', p_sqlerrm => SQLERRM);
            raise_application_error(-20001, 'При зміні атрибутів виникла помилка. Подробиці: ' || SQLERRM);
    END;  
    
    log_util.log_finish(p_proc_name => 'change_attribute_employee', p_text => 'Зміна атрибутів співробітника ' || p_employee_id || ' завершена.');
    
END change_attribute_employee;

-- Приклад виклику для тесту: 
BEGIN
    util.change_attribute_employee(
        p_employee_id => 205,
        p_first_name => 'Shanin',
	p_salary =>  11500
    );
END;
/
