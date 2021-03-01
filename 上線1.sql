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



--爭救案mail通知人員
begin tran
insert into scode_roles (scode,branch,dept,syscode,roles,sort) values
('k467','N','T','NTBRT','opt','01')
,('k1416','N','T','NTBRT','opt','02')
rollback tran
commit tran

begin tran
insert into scode_roles (scode,branch,dept,syscode,roles,sort) values
('k467','C','T','CTBRT','opt','01')
,('k1416','C','T','CTBRT','opt','02')
rollback tran
commit tran

begin tran
insert into scode_roles (scode,branch,dept,syscode,roles,sort) values
('k467','S','T','STBRT','opt','01')
,('k1416','S','T','STBRT','opt','02')
rollback tran
commit tran

begin tran
insert into scode_roles (scode,branch,dept,syscode,roles,sort) values
('k467','K','T','KTBRT','opt','01')
,('k1416','K','T','KTBRT','opt','02')
rollback tran
commit tran
