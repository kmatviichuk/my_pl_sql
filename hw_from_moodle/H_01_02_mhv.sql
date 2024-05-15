DECLARE
    v_date DATE := TO_DATE('01.04.2024', 'DD.MM.YYYY');
    v_day NUMBER;
BEGIN

    v_day := TO_NUMBER(TO_CHAR(v_date, 'dd'));
  
    IF v_day = EXTRACT(DAY FROM LAST_DAY(TRUNC(SYSDATE))) THEN
        DBMS_OUTPUT.PUT_LINE('Виплата зарплати');
    ELSIF v_day = 15 THEN
        DBMS_OUTPUT.PUT_LINE('Виплата авансу');
    ELSIF v_day < 15 THEN 
        DBMS_OUTPUT.PUT_LINE('Чекаємо на аванс');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Чекаємо на зарплату');
    END IF;
    
END;
/