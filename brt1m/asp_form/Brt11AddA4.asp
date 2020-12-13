<%
Sub doUpdateDB()
set cmd=Server.CreateObject("ADODB.command")
set cnn=Server.CreateObject("ADODB.connection")
set RSinfo=Server.CreateObject("ADODB.recordset")
cnn.Open session("btbrtdb")
cmd.ActiveConnection=cnn
cnn.BeginTrans	

//寫入Log檔
log_table(conn);

//SQL = "delete from caseitem_dmt where in_no='"+Request["in_no"]+"' and in_scode='"+Request["in_scode"]+"'";
//conn.ExecuteNonQuery(SQL);

//SQL = "delete from casedmt_good where in_no='"+Request["in_no"]+"' and in_scode='"+Request["in_scode"]+"'";
//conn.ExecuteNonQuery(SQL);

//SQL = "delete from casedmt_show where in_no='"+Request["in_no"]+"' and case_sqlno=0";
//conn.ExecuteNonQuery(SQL);

SQL = "delete from dmt_tranlist where in_no='"+Request["in_no"]+"' and in_scode='"+Request["in_scode"]+"' and mod_field='mod_dmt'";
conn.ExecuteNonQuery(SQL);

//寫入接洽記錄檔(case_dmt)
update_case_dmt(conn);

//寫入接洽記錄主檔(dmt_temp)
update_dmt_temp(conn);

//寫入接洽費用檔(caseitem_dmt)
insert_caseitem_dmt(conn);

//寫入商品類別檔(casedmt_good)
insert_casedmt_good(conn);

//寫入展覽會優先權檔(casedmt_show)
insert_casedmt_show(conn,"0");

//***異動檔
//dmt_tran入log
//call insert_log_table(cnn,"U",tprgid,"dmt_tran","in_no;in_scode",trim(request("in_no"))&";"&trim(request("in_scode"))) 

//***異動檔
ColMap.Clear();
foreach (var key in Request.Form.Keys) {
	string colkey = key.ToString().ToLower();
	string colValue = Request[colkey];

	//取1~4碼
	if (colkey.Left(4) == "tfgp") {
		ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
	}
}

//20161006因電子送件修改備註.2欄都可存檔(用|分隔)
if ((Request["O_item"] ?? "") != "") {
	string sqlvalue = "";
	if ((Request["O_item"] ?? "").IndexOf("1") > -1) {
		if ((Request["O_item1"] ?? "") != "" || (Request["O_item2"] ?? "") != "") {
			sqlvalue += "1," + Request["O_item1"] + ";" + Request["O_item2"];
		}
	}
	sqlvalue += "|";
	if ((Request["O_item"] ?? "").IndexOf("Z") > -1) {
		sqlvalue += "Z;ZZ," + Request["O_item2t"];
	}
	ColMap["other_item"] = Util.dbchar(sqlvalue);
} else {
	ColMap["other_item"] = "null";
}

ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
ColMap["tr_scode"] = "'" + Session["scode"] + "'";
SQL = "UPDATE case_dmt set " + ColMap.GetUpdateSQL();
SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
conn.ExecuteNonQuery(SQL);

//*****異動明細
if ((Request["tfgp_mod_dmt"] ?? "") == "Y") {//變更商標／標章名稱
	ColMap.Clear();
	ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
	ColMap["in_no"] = Util.dbchar(Request["In_no"]);
	ColMap["mod_field"] = "'mod_dmt'";
	ColMap["ncname1"] = Util.dbchar(Request["new_appl_name"]);

	SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
	conn.ExecuteNonQuery(SQL);
}

//申請人入log_table
//call insert_log_table(cnn,"U",tprgid,"dmt_temp_ap","in_no;case_sqlno",trim(request("in_no"))&";0")
//寫入交辦申請人檔(dmt_temp_ap)
insert_dmt_temp_ap(conn,"0");
	
//*****文件上傳
Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"]??""));

//更新營洽官收確認紀錄檔(grconf_dmt.job_no)
upd_grconf_job_no(conn);

//當程序有修改復案或結案註記時通知營洽人員
chk_end_back();

End sub '---- doUpdateDB() ----
%>
