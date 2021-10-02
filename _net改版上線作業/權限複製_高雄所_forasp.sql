select * from SYScode where syscode='ntbrt'
select * from SYScode where syscode='ktbrt'
/*
insert into SYScode 
select 'KTBRT','高雄所商標網路作業系統',sysnameE,'web08',syspath,'K',ClassCode,'07',corp_user,main_user,sys_user,online_date,beg_date,end_date,sysremark,mark
from SYScode where syscode='ntbrt'
*/


select * from loginap where syscode='ntbrt'
select * from loginap where syscode='ktbrt'
/*
insert into loginap 
select 'KTBRT',logingrp,apcode,rights,beg_date,end_date,tran_date,tran_scode
from loginap a where syscode='ntbrt' --and logingrp not in('BTBRTADMIN','NTIB')
and not exists (select 1 from loginap where syscode='ktbrt' and logingrp=a.logingrp and apcode=a.apcode)
*/


select * from logingrp where syscode='ntbrt'
select * from logingrp where syscode='ktbrt'
/*
insert into logingrp 
select 'KTBRT',logingrp,grpname,grptype,worktype,homegif,remark,beg_date,end_date,tran_date,tran_scode
from logingrp a where syscode='ntbrt' 
and not exists (select 1 from logingrp where syscode='ktbrt' and logingrp=a.logingrp)
*/


select * from sysctrl where syscode='ntbrt'
select * from sysctrl where syscode='ktbrt'
/*
insert into sysctrl 
select scode,'K',dept,sysdefault,'KTBRT',logingrp,beg_date,end_date,visit_date,tran_date,mark
from sysctrl a where syscode='ntbrt'
and not exists (select 1 from sysctrl where syscode='ktbrt' and logingrp=a.logingrp and scode=a.scode)
*/


select * from ap where syscode='ntbrt' 
select * from ap where syscode='ktbrt' 
/*
insert into ap 
select 'KTBRT',apcode,apnamee,apnamec,apcat,apserver,appath,aporder,apgrpclass,end_level,remark,beg_date,end_date,tran_date,tran_scode,apremark
from ap a where syscode='ntbrt'
and not exists (select 1 from ap where syscode='ktbrt' and apcode=a.apcode)
*/

select * from APcat where syscode='ntbrt'
select * from APcat where syscode='ktbrt'
/*
insert into APcat 
select 'KTBRT',APcatID,APcatCName,APcatEName,APseq
from APcat a where syscode='ntbrt'
and not exists (select 1 from APcat where syscode='ktbrt' and apcatid=a.apcatid)
*/
