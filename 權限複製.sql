select * from ap where syscode='ntbrt'
select * from ap where syscode='nntbrt'

select * from loginap where syscode='ntbrt'
select * from loginap where syscode='nntbrt'
/*
insert into loginap 
select 'NNTBRT',logingrp,apcode,rights,beg_date,end_date,tran_date,tran_scode
from loginap where syscode='ntbrt' and apcode not in('ap1','ap2')
*/


select * from logingrp where syscode='ntbrt'
select * from logingrp where syscode='nntbrt'
/*
insert into logingrp 
select 'NNTBRT',logingrp,grpname,grptype,worktype,homegif,remark,beg_date,end_date,tran_date,tran_scode
from logingrp where syscode='ntbrt' and logingrp not in('BTBRTADMIN')
*/


select * from sysctrl where syscode='ntbrt'
select * from sysctrl where syscode='nntbrt'
/*
insert into sysctrl 
select scode,branch,dept,sysdefault,'NNTBRT',logingrp,beg_date,end_date,visit_date,tran_date,mark
from sysctrl where syscode='ntbrt' and scode not in('m1583')
*/