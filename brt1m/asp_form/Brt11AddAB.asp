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

 //*****¸É´«µù¥UÀÉ
	//dmt_tran¤Jlog
	Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], "");	
	SQL = "UPDATE dmt_tran set ";
		ColMap.Clear();
		foreach (var key in Request.Form.Keys) {
			string colkey = key.ToString().ToLower();
			string colValue = Request[colkey];

			//¨ú1~4½X
			if (colkey.Left(4) == "tfg1") {
				ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
			}
		}

		if ((Request["O_item1"] ?? "") != "" || (Request["O_item2"] ?? "") != "") {//ªþµù
			ColMap["other_item"] = Util.dbchar(Request["O_item1"] + ";" + Request["O_item2"]);
		}
		if (ReqVal.TryGet("tfg1_mod_claim1")=="") {
			ColMap["mod_claim1"] = "'N'";
		}
		ColMap["tr_date"] = "getdate()";
		ColMap["tr_scode"] = "'" + Session["scode"] + "'";
		ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
		SQL += ColMap.GetUpdateSQL();
		SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
		conn.ExecuteNonQuery(SQL);

Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));

update_todo();

update_dmt();

update_in_scode();

insert_rec_log();

End sub '---- doUpdateDB() ----%>
