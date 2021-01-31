<% 
Sub doUpdateDB(tno,tscode) 
log_table();

update_case_dmt();

upd_grconf_job_no();

update_dmt_temp();
	
insert_casedmt_good();

insert_dmt_temp_ap("0");

	//*****¸É´«µù¥UÀÉ
	//dmt_tran¤Jlog
	Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], "");

	SQL = "UPDATE dmt_tran set ";
	ColMap.Clear();
	foreach (var key in Request.Form.Keys) {
		string colkey = key.ToString().ToLower();
		string colValue = Request[colkey];
		//¨ú2~4½X
		if (colkey.Left(4).Substring(1) == "fg1") {
			if (colkey.Left(1) == "d") {
				ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
			} else {
				ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
			}
		}
	}

	ColMap["tr_date"] = "getdate()";
	ColMap["tr_scode"] = "'" + Session["scode"] + "'";
	ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
	SQL +=ColMap.GetUpdateSQL();
	SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
	conn.ExecuteNonQuery(SQL); 	 	

Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));

update_todo();
   	  
update_dmt();

update_in_scode();

insert_rec_log();

End sub '---- doUpdateDB() ----%>
