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
