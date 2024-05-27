-- 6. Створення механізму синхронізації даних з API у базу даних

-- Процедура api_nbu_sync з пакету util:
PROCEDURE api_nbu_sync IS

    v_list_currencies sys_params.value_text%TYPE;
    
BEGIN
  
  BEGIN
	SELECT value_text INTO v_list_currencies
	FROM sys_params
	WHERE param_name = 'list_currencies';
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		log_util.log_error(p_proc_name => 'api_nbu_sync', p_sqlerrm => 'Список валют не знайдено.');
		raise_application_error(-20001, 'Список валют не знайдено. Перевірте коректність даних.');
  END;

      FOR cc IN 
        (SELECT value_list AS curr FROM TABLE(util.table_from_list(v_list_currencies)))
      LOOP
          BEGIN
              INSERT INTO cur_exchange (r030, txt, rate, cur, exchangedate, change_date)
              SELECT r030, txt, rate, cur, exchangedate, SYSDATE
              FROM TABLE(util.get_currency(cc.curr));
          END;
      END LOOP;

  log_util.log_finish(p_proc_name => 'api_nbu_sync', p_text => 'Синхронізація курс валют успішно завершена.');

EXCEPTION
    WHEN OTHERS THEN
        log_util.log_error(p_proc_name => 'api_nbu_sync', p_sqlerrm => SQLERRM);
        raise_application_error(-20002, 'Виникла невідома помилка. Подробиці: ' || SQLERRM);
END api_nbu_sync;

-- Для оновлення данних(кожного дня о 6 ранку) був створений шедулер JOB_API_NBU_SYNC:
BEGIN
    sys.dbms_scheduler.create_job (
        job_name        => 'JOB_API_NBU_SYNC',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN util.api_nbu_sync; END;',
        start_date      => SYSDATE,
        repeat_interval => 'FREQ=DAILY; BYHOUR=6; BYMINUTE=00',
	end_date        => TO_DATE(NULL),
        enabled         => TRUE,
	auto_drop       => FALSE,
        comments        => 'Оновлення курс валют'
    );
END;
/
