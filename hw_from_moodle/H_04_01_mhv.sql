--Приклад оголошення процедури check_work_time в пакеті util. Spec & body

CREATE OR REPLACE PACKAGE util AS
    PROCEDURE check_work_time;
END util;
/

CREATE OR REPLACE PACKAGE BODY util AS

PROCEDURE check_work_time IS
BEGIN 
    IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE = AMERICAN') IN ('SAT', 'SUN') THEN
        raise_application_error (-20205, 'Ви можете вносити зміни лише у робочі дні');
    END IF;
END check_work_time;

END util;
/