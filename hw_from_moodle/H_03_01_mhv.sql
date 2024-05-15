CREATE OR REPLACE PROCEDURE del_jobs(p_job_id IN VARCHAR2,
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
/