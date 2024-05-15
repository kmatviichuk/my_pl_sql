--Процедура del_jobs. Шматок коду з body пакету util

PROCEDURE del_jobs(p_job_id IN VARCHAR2,
                   po_result OUT VARCHAR2) IS

v_delete_no_data_found EXCEPTION;

BEGIN

    check_work_time;
    
    BEGIN
        DELETE FROM jobs j
        WHERE j.job_id = p_job_id;
        
        IF SQL%rowcount = 0 THEN
            RAISE v_delete_no_data_found;
        END IF;
        
        EXCEPTION
            WHEN v_delete_no_data_found THEN raise_application_error(-20004, 'Посада '|| p_job_id || ' не існує. Код помилки: '||SQLERRM);
    END;

    po_result := 'Посада ' || p_job_id || ' успішно видалена';

    COMMIT; 
END del_jobs;