--Функція get_sum_price_sales. Шматок коду з body пакету util

FUNCTION get_sum_price_sales(p_table IN VARCHAR2) RETURN NUMBER IS
    v_sum NUMBER;
    v_dynamic_sql VARCHAR2(50);
    v_message logs.message%TYPE;
BEGIN
    IF p_table NOT IN ('products', 'products_old') THEN
        v_message := 'Неприпустиме значення! Очікується produ?cts або produ?cts_old.';
 
        to_log(p_appl_proc => 'util.get_sum_price_sales', p_message => v_message); 
        raise_application_error(-20001,v_message);
    END IF;
    
    v_dynamic_sql := 'SELECT SUM(price_sales) FROM hr.'||p_table;
    
    EXECUTE IMMEDIATE v_dynamic_sql INTO v_sum;
    
    RETURN v_sum;

end get_sum_price_sales;