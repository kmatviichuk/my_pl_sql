--1. Створюємо view interbank_index_ua_v на основі виклику API через функцію SYS.GET_NBU:
CREATE OR REPLACE VIEW interbank_index_ua_v AS
SELECT
    TO_DATE(tt.dt,'dd.mm.yyyy') as dt,
    tt.id_api,
    tt.value AS value,
    tt.special
FROM (SELECT sys.get_nbu(p_url => 'https://bank.gov.ua/NBU_uonia?id_api=UONIA_UnsecLoansDepo&json') AS json_value FROM dual)
CROSS JOIN json_table
(
    json_value, '$[*]'
    COLUMNS (
            dt VARCHAR2(10) PATH '$.dt',
            id_api VARCHAR2(100) PATH '$.id_api',
            value NUMBER PATH '$.value',
            special VARCHAR2(1) PATH '$.special'
        )
)tt;


--2. Створюємо процедуру download_ibank_index_ua, яка повинна вставляти дані з view interbank_index_ua_v в таблицю interbank_index_ua_history:
CREATE OR REPLACE PROCEDURE download_ibank_index_ua AS
BEGIN
    INSERT INTO interbank_index_ua_history (dt, id_api, value, special)
    SELECT dt, id_api, value, special
    FROM interbank_index_ua_v;
    
    COMMIT;

END download_ibank_index_ua;
/


--3. Процедуру download_ibank_index_ua ставимо на шедулер з інтервалом кожен день в 9 ранку:
BEGIN
    sys.dbms_scheduler.create_job(job_name => 'ibank_index_ua',
                                  job_type => 'PLSQL_BLOCK',
                                  job_action => 'begin download_ibank_index_ua(); end;',
                                  start_date => SYSDATE,
                                  repeat_interval => 'FREQ=DAILY;BYHOUR=9;BYMINUTE=00',
                                  end_date => TO_DATE(NULL),
                                  job_class => 'DEFAULT_JOB_CLASS',
                                  enabled => TRUE,
                                  auto_drop => FALSE,
                                  comments => 'Оновлення Українського індексу міжбанківських ставок овернайт.');
END;
/