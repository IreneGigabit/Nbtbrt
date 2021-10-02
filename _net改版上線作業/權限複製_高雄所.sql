select * from SYScode where syscode='nnbrt'
select * from SYScode where syscode='nkbrt'
/*
insert into SYScode 
select 'NKBRT','高雄所商標網路作業系統(新)',sysnameE,'web08','/nbtbrtK','K',ClassCode,'07',corp_user,main_user,sys_user,online_date,beg_date,end_date,sysremark,mark
from SYScode where syscode='nnbrt'
*/


select * from loginap where syscode='nnbrt'
select * from loginap where syscode='nkbrt'
/*
insert into loginap 
select 'NKBRT',logingrp,apcode,rights,beg_date,end_date,tran_date,tran_scode
from loginap where syscode='nnbrt'-- and apcode not in('ap1','ap2')
*/


select * from logingrp where syscode='nnbrt'
select * from logingrp where syscode='nkbrt'
/*
insert into logingrp 
select 'NKBRT',logingrp,grpname,grptype,worktype,homegif,remark,beg_date,end_date,tran_date,tran_scode
from logingrp where syscode='nnbrt'-- and logingrp not in('BTBRTADMIN')
*/


select * from sysctrl where syscode='nnbrt'
select * from sysctrl where syscode='nkbrt'
/*
insert into sysctrl 
select scode,'K',dept,sysdefault,'NKBRT',logingrp,beg_date,end_date,visit_date,tran_date,mark
from sysctrl where syscode='nnbrt'-- and scode not in('m1583')
*/


select * from ap where syscode='nnbrt' 
select * from ap where syscode='nkbrt' 
/*
insert into ap 
select 'NKBRT',apcode,apnamee,apnamec,apcat,apserver,replace(appath,'nBTBRT/','nBTBRTK/'),aporder,apgrpclass,end_level,remark,beg_date,end_date,tran_date,tran_scode
from ap where syscode='nnbrt'
*/

select * from APcat where syscode='nnbrt'
select * from APcat where syscode='nkbrt'
/*
insert into APcat 
select 'NKBRT',APcatID,APcatCName,APcatEName,APseq
from APcat where syscode='nnbrt'-- and apcatid in(select distinct APcat from sysctrl.dbo.ap where syscode='NNBRT')
*/
