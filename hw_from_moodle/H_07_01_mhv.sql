--Оголошення в специфікації пакету util: 
FUNCTION get_region_cnt_emp(p_department_id IN NUMBER DEFAULT NULL) RETURN region_cnt_emp_tab PIPELINED;

--Блок в body:
FUNCTION get_region_cnt_emp(p_department_id IN NUMBER DEFAULT NULL) RETURN region_cnt_emp_tab PIPELINED IS

    out_rec region_cnt_emp_tab := region_cnt_emp_tab();
    l_cur SYS_REFCURSOR;
    
    BEGIN
      OPEN l_cur FOR
        SELECT r.region_name, COUNT(e.employee_id) AS employee_count
        FROM hr.employees e
        JOIN hr.departments d ON e.department_id = d.department_id
        JOIN hr.locations l ON d.location_id = l.location_id
        JOIN hr.countries c ON l.country_id = c.country_id
        JOIN hr.regions r ON c.region_id = r.region_id
        WHERE e.department_id = p_department_id OR p_department_id IS NULL
        GROUP BY r.region_name;
        
            LOOP
                EXIT WHEN l_cur%NOTFOUND;
                FETCH l_cur BULK COLLECT
                    INTO out_rec;
                    FOR i IN 1 .. out_rec.count LOOP
                        PIPE ROW(out_rec(i)); 
                    END LOOP;
            END LOOP;
            CLOSE l_cur;
        
            EXCEPTION 
                WHEN OTHERS THEN 
                    IF (l_cur%ISOPEN) THEN 
                        CLOSE l_cur;
                        RAISE;
                    ELSE
                        RAISE;
                    END IF;
END get_region_cnt_emp;

--Тести виклику:
SELECT *
FROM TABLE(util.get_region_cnt_emp());

SELECT *
FROM TABLE(util.get_region_cnt_emp(10));