select * from SYScode where syscode='ntbrt'
select * from SYScode where syscode='nnbrt'
/*
insert into SYScode 
select 'NNBRT','台北所商標網路作業系統(新)',sysnameE,'web08','/nbtbrt',DataBranch,ClassCode,'07',corp_user,main_user,sys_user,online_date,beg_date,end_date,sysremark,mark,dbserver,dbname
from SYScode where syscode='ntbrt'
*/


select * from loginap where syscode='ntbrt'
select * from loginap where syscode='nnbrt'
/*
insert into loginap 
select 'NNBRT',logingrp,apcode,rights,beg_date,end_date,tran_date,tran_scode
from loginap where syscode='ntbrt'-- and apcode not in('ap1','ap2')
*/


select * from logingrp where syscode='ntbrt'
select * from logingrp where syscode='nnbrt'
/*
insert into logingrp 
select 'NNBRT',logingrp,grpname,grptype,worktype,homegif,remark,beg_date,end_date,tran_date,tran_scode
from logingrp where syscode='ntbrt'-- and logingrp not in('BTBRTADMIN')
*/


select * from sysctrl where syscode='ntbrt'
select * from sysctrl where syscode='nnbrt'
/*
insert into sysctrl 
select scode,branch,dept,sysdefault,'NNBRT',logingrp,beg_date,end_date,visit_date,tran_date,mark
from sysctrl where syscode='ntbrt'-- and scode not in('m1583')
*/


select * from ap where syscode='ntbrt' 
select * from ap where syscode='nnbrt' 
/*
用複製貼上
*/

select * from APcat where syscode='ntbrt'
select * from APcat where syscode='nnbrt'
/*
insert into APcat 
select 'NNBRT',APcatID,APcatCName,APcatEName,APseq
from APcat where syscode='ntbrt' and apcatid in(select distinct APcat from sysctrl.dbo.ap where syscode='NNBRT')
*/
