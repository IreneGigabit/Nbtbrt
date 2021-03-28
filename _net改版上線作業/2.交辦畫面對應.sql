--交辦畫面各案性入口
SELECT Cust_code ar_form, Code_name,form_name prt_code,* FROM Cust_code 
--update Cust_code set remark='A11'
WHERE Code_type = 'T92' AND form_name is not null and cust_code in('A0','A1')
order by cust_code	

SELECT Cust_code ar_form, Code_name,form_name prt_code,* FROM Cust_code 
--update Cust_code set remark='A9Z'
WHERE Code_type = 'T92' AND form_name is not null and cust_code not in('A0','A1')
order by cust_code	


SELECT Cust_code ar_form, Code_name,form_name prt_code,remark,* FROM Cust_code 
--update Cust_code set remark='A9Z'
WHERE Code_type = 'T92' --AND form_name is not null
and (cust_code like 'B%' or cust_code like 'C%' or cust_code like 'D%' or cust_code like 'Y%')
order by cust_code	

