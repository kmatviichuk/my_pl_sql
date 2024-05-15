create or replace PACKAGE util AS
    
FUNCTION get_dep_name(p_employee_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_job_title(p_employee_id IN NUMBER) RETURN VARCHAR;

PROCEDURE del_jobs(p_job_id IN VARCHAR2,
                   po_result OUT VARCHAR2);

END util;