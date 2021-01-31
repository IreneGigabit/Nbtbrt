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

//***²§°ÊÀÉ
//dmt_tran¤Jlog
Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], "");
//***²§°ÊÀÉ
ColMap.Clear();
switch ((Request["tfy_arcase"] ?? "").Left(3)) {
	case "FD1":
		ColMap["other_item"] = Util.dbchar(Request["O_item11"] + ";" + Request["O_item12"] + ";" + Request["O_item13"]);
		break;
	case "FD2":
	case "FD3":
		ColMap["other_item"] = Util.dbchar(Request["O_item21"] + ";" + Request["O_item22"] + ";" + Request["O_item23"]);
		break;
}
ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
ColMap["in_no"] = Util.dbchar(Request["In_no"]);
ColMap["tr_date"] = "getdate()";
ColMap["tr_scode"] = "'" + Session["scode"] + "'";
ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
ColMap["seq1"] = Util.dbnull(Request["tfzb_seq1"]);
SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
conn.ExecuteNonQuery(SQL);

Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));
 
update_todo();

update_dmt();

update_in_scode();

insert_rec_log();

End sub '---- doUpdateDB() ----%>
