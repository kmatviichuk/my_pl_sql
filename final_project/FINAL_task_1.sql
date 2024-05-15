-- 1. Створення механізму логування будь-якого процесу:

--Specification пакету LOG_UTIL
CREATE OR REPLACE PACKAGE log_util IS

PROCEDURE log_start(p_proc_name IN VARCHAR2, p_text IN VARCHAR2 DEFAULT NULL);
PROCEDURE log_finish(p_proc_name IN VARCHAR2, p_text IN VARCHAR2 DEFAULT NULL);
PROCEDURE log_error(p_proc_name IN VARCHAR2, p_sqlerrm IN VARCHAR2, p_text IN VARCHAR2 DEFAULT NULL);

END log_util;

--Body пакету LOG_UTIL
CREATE OR REPLACE PACKAGE BODY log_util IS

PROCEDURE to_log(p_appl_proc IN VARCHAR2,
                 p_message   IN VARCHAR2) IS
    PRAGMA autonomous_transaction;
BEGIN
    INSERT INTO logs(id, appl_proc, message) 
    VALUES(log_seq.NEXTVAL, p_appl_proc, p_message); 
    COMMIT;
END;

PROCEDURE log_start(p_proc_name IN VARCHAR2, 
                    p_text      IN VARCHAR2 DEFAULT NULL) IS

  v_text logs.message%TYPE;
    
  BEGIN
    IF p_text IS NULL THEN
      v_text := 'Старт логування, назва процесу = ' || p_proc_name;
    ELSE
      v_text := p_text;
    END IF;

  log_util.to_log(p_appl_proc => p_proc_name, p_message => v_text);
  
END log_start;

PROCEDURE log_finish(p_proc_name IN VARCHAR2, 
                     p_text      IN VARCHAR2 DEFAULT NULL) IS
                     
  v_text logs.message%TYPE;
    
  BEGIN
    IF p_text IS NULL THEN
      v_text := 'Завершення логування, назва процесу = ' || p_proc_name;
    ELSE
      v_text := p_text;
    END IF;

  log_util.to_log(p_appl_proc => p_proc_name, p_message => v_text);
  
END log_finish;

PROCEDURE log_error(p_proc_name IN VARCHAR2, 
                    p_sqlerrm   IN VARCHAR2, 
                    p_text      IN VARCHAR2 DEFAULT NULL) IS
                    
  v_text logs.message%TYPE;
    
  BEGIN
    IF p_text IS NULL THEN
      v_text := 'В процедурі ' || p_proc_name || ' сталася помилка. ' || p_sqlerrm;
    ELSE
      v_text := p_text;
    END IF;

  log_util.to_log(p_appl_proc => p_proc_name, p_message => v_text);
  
END log_error;                        

END log_util;
