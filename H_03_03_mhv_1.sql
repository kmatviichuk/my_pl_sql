--������� ������� ��������� � ������
DECLARE
v_result VARCHAR2(100);
BEGIN
    hristina.util.del_jobs(p_job_id => 'AD_ASST',
             po_result => v_result);
    dbms_output.put_line(v_result);
END;
/

--������� ������� ������� � ������
DECLARE
    v_employee_id NUMBER := 146;
    v_department_name VARCHAR2(100);
BEGIN
    v_department_name := hristina.util.get_dep_name(v_employee_id);
    DBMS_OUTPUT.PUT_LINE('���������, ID '|| v_employee_id || ' � ������������ ' || v_department_name);
END;
/
