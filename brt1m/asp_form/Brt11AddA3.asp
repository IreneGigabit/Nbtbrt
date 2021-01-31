<% 
Sub doUpdateDB(tno,tscode) 
dim RS
'SET inforcon = SERVER.CreateObject("ADODB.connecTION")	
Set RS = Server.Createobject("ADODB.recordset")
'inforcon.Open session("sinbrt")
conn.BeginTrans
'inforcon.BeginTrans	
tran_sqlno = ""
ixi = 0
intflg="N"

log_table();

update_case_dmt();

upd_grconf_job_no();

update_dmt_temp();

insert_casedmt_good();

insert_casedmt_show("0");

insert_dmt_temp_ap("0");

Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));

update_todo();
	 
update_dmt();

update_in_scode();

insert_rec_log();
 
End sub '---- doUpdateDB() ----%>
