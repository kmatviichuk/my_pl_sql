DECLARE 
    v_employee_id hr.employees.employee_id%type := 110;
    v_job_id hr.jobs.job_id%type;
    v_job_title hr.jobs.job_title%type;
    
BEGIN 

    SELECT e.job_id 
    INTO v_job_id
    FROM hr.employees e
    WHERE e.employee_id = v_employee_id;
            
    SELECT j.job_title 
    INTO v_job_title
    FROM hr.jobs j
    WHERE j.job_id = v_job_id;
    
    dbms_output.put_line('Співробітник, з ID ' || v_employee_id || ', має посаду: ' || v_job_title);
    
END;
/