-- 5. Створення механізму копіювання потрібних таблиць у потрібну схему

-- Процедура copy_table з пакету util:
PROCEDURE copy_table (p_source_schema IN VARCHAR2,
                      p_target_schema IN VARCHAR2 DEFAULT USER,
                      p_list_table IN VARCHAR2,
                      p_copy_data IN BOOLEAN DEFAULT FALSE,
                      po_result OUT VARCHAR2) IS         

    v_ddl_code VARCHAR2(10000);
    v_table_name VARCHAR2(30);
    v_count NUMBER;

BEGIN
    FOR table_rec IN (
        SELECT table_name 
        FROM all_tables 
        WHERE owner = p_source_schema 
        AND table_name IN (SELECT * FROM TABLE(table_from_list(p_list_table)))
    ) LOOP
        v_table_name := table_rec.table_name;

        SELECT 'CREATE TABLE ' || p_target_schema || '.' || v_table_name || ' (' || LISTAGG(column_name || ' ' || data_type || 
          CASE 
            WHEN data_type = 'VARCHAR2' THEN '(' || data_length || ')'
            WHEN data_type = 'DATE' THEN NULL
            WHEN data_type = 'NUMBER' THEN replace( '('||data_precision||','||data_scale||')', '(,)', NULL) END, ', ') WITHIN GROUP (ORDER BY column_id) || ')'
        INTO v_ddl_code
        FROM all_tab_columns
        WHERE owner = p_source_schema AND table_name = v_table_name
        GROUP BY table_name;     
    
    BEGIN

        SELECT COUNT(*)
        INTO v_count
        FROM all_tables
        WHERE owner = p_target_schema AND table_name = v_table_name;

        IF v_count = 0 THEN
            EXECUTE IMMEDIATE v_ddl_code;
            to_log(p_appl_proc => 'util.copy_table', p_message => 'У схемі ' || p_target_schema || ' створена таблиця ' || v_table_name  || '.');

            IF p_copy_data THEN
               EXECUTE IMMEDIATE 'INSERT INTO ' || p_target_schema || '.' || v_table_name ||
                                 ' SELECT * FROM ' || p_source_schema || '.' || v_table_name;
               to_log(p_appl_proc => 'util.copy_table', p_message => 'Копіювання данних з таблиці ' || v_table_name || '.');
            ELSE 
               to_log(p_appl_proc => 'util.copy_table', p_message => 'Копіювання структури таблиці ' || v_table_name || ' . Данні не перенесені.');
            END IF;
        ELSE
            to_log(p_appl_proc => 'util.copy_table', p_message => 'Таблиця ' || v_table_name || ' вже існує в схемі ' || p_target_schema || '. Її копіювання не відбулось.');         
        END IF;

      EXCEPTION
         WHEN OTHERS THEN
            to_log(p_appl_proc => 'util.copy_table', p_message => 'При копіюванні таблиці ' || v_table_name || ' виникла помилка. Подробиці: ' || SQLERRM);
            CONTINUE;
    END;
        to_log(p_appl_proc => 'util.copy_table', p_message => 'Процедуру copy_table завершено. ');       
   END LOOP;

   po_result := 'Процедуру успішно завершено.';
   
   EXCEPTION
     WHEN OTHERS THEN
        to_log(p_appl_proc => 'util.copy_table', p_message => 'Виникла невідома помилка: ' || SQLERRM);        
        po_result := 'Виникла невідома помилка. Подробиці: ' || SQLERRM;
END copy_table;

-- Приклад виклику для тесту: 
DECLARE
    v_result VARCHAR2(10000);
BEGIN
    util.copy_table(
        p_source_schema => 'HR',
        p_target_schema => 'HRISTINA',
        p_list_table    => 'SALES,REGIONS',
        p_copy_data     => TRUE,
        po_result       => v_result
    );
    dbms_output.put_line(v_result);
END;
/
