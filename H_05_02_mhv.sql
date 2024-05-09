-- Сподіваюсь умову завдання зрозуміла правильно :)

--Код запису у файл: 
DECLARE 
    file_handle UTL_FILE.FILE_TYPE;
    file_location VARCHAR2(200) := 'FILES_FROM_SERVER';
    file_name VARCHAR2(200) := 'TOTAL_PROJ_INDEX_MHV.csv'; 
    file_content VARCHAR2(4000);
BEGIN

    FOR cc IN (SELECT d.department_name || ',' || 
                      COUNT(DISTINCT e.employee_id) || ',' || 
                      COUNT(DISTINCT e.manager_id) || ',' || 
                      SUM(e.salary) AS file_content
              FROM rep_project_dep_v rp
              JOIN employees e ON rp.department_id = e.department_id
              JOIN departments d ON rp.department_id = d.department_id
              GROUP BY d.department_name)
    LOOP
        file_content := file_content || cc.file_content || CHR(10);
    END LOOP;
    
    file_handle := UTL_FILE.FOPEN(file_location, file_name, 'W'); 

    UTL_FILE.PUT_RAW(file_handle, UTL_RAW.CAST_TO_RAW(file_content));

    UTL_FILE.FCLOSE(file_handle);
    
EXCEPTION
    WHEN OTHERS THEN 
        RAISE;
END;
/

-- Перевірка, код для зчитування з файлу TOTAL_PROJ_INDEX_MHV.csv:
SELECT department_name, count_employees, count_unique_managers, total_salary
FROM EXTERNAL ( ( department_name VARCHAR2(50),
                  count_employees NUMBER,
                  count_unique_managers NUMBER,
                  total_salary NUMBER,
                  type VARCHAR2(3) )
    TYPE oracle_loader DEFAULT DIRECTORY FILES_FROM_SERVER 
    ACCESS PARAMETERS ( records delimited BY newline
                        nologfile 
                        nobadfile
                        fields terminated BY ',' 
                        missing field VALUES are NULL )
LOCATION('TOTAL_PROJ_INDEX_MHV.csv')
REJECT LIMIT UNLIMITED);