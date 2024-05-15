DECLARE 
    v_recipient VARCHAR2(50);
    v_subject VARCHAR2(50) := 'Тест звіт!';
    v_mes VARCHAR2(5000) := 'Вітаю! </br> Звіт по кількості працівників в розрізі департаментів: </br></br>';

    BEGIN
        SELECT email || '@enamine.net' INTO v_recipient
        FROM employees
        WHERE employee_id = 207;

        SELECT
           v_mes||'<!DOCTYPE html>
            <html>
                <head>
                    <title></title>
                    <style>
                        table, th, td {border: 1px solid;}
                        .center{text-align: center;}
                    </style>
                </head>
                <body>
                    <table border=1 cellspacing=0 cellpadding=2 rules=GROUPS frame=HSIDES>
                        <thead>
                            <tr align=left>
                                <th>ID Департаменту</th>
                                <th>Кількість співробітників</th>
                            </tr>
                        </thead>
                        <tbody>
                        '|| list_html || '
                        </tbody>
                    </table>
                </body>
            </html>' AS html_table
            INTO v_mes
        FROM(
        SELECT
            LISTAGG('<tr align=left>
            <td>'|| department_id || '</td>' || '
                <td class=''center''> ' || count_emps|| '</td>
            </tr>', '<tr>') 
            WITHIN GROUP(ORDER BY count_emps) AS list_html
                FROM(
                    SELECT department_id, COUNT(*) AS count_emps
                        FROM employees 
                        GROUP BY department_id));
    
    sys.sendmail(p_recipient => v_recipient,
                 p_subject => v_subject,
                 p_message => v_mes || ' ');
    END;
/