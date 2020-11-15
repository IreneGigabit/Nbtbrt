<%
sub doUpdateDB()

set RS=Server.CreateObject("ADODB.recordset")
set RSinfo=Server.CreateObject("ADODB.recordset")
set cmd=Server.CreateObject("ADODB.command")
set cnn=Server.CreateObject("ADODB.connection")
cnn.Open session("btbrtdb")
cmd.ActiveConnection=cnn
cnn.BeginTrans
	
'******************產生流水號

	SQLno="SELECT MAX(in_no) FROM case_dmt WHERE (LEFT(in_no, 4) = YEAR(GETDATE()))"

	//寫入case_dmt
	insert_case_dmt(conn, RSno);

	//寫入dmt_temp
	insert_dmt_temp(conn, RSno);

	//寫入接洽費用檔
	insert_caseitem_dmt(conn, RSno);

	//寫入商品類別檔
	insert_casedmt_good(conn, RSno);

	//****新增展覽優先權資料
	insert_casedmt_show(conn, RSno,"0");

	//***異動檔
	if ((Request["ar_form"] ?? "") == "A4") {//延展
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

		ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
		ColMap["in_no"] = "'" + RSno + "'";
		ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
		ColMap["tr_scode"] = "'" + Session["scode"] + "'";
		SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
		conn.ExecuteNonQuery(SQL);
	}

	//寫入交辦申請人檔
	insert_dmt_temp_ap(conn, RSno,"0");	
	
	//*****新增文件上傳
	insert_dmt_attach(conn, RSno);	
	
	//*****異動明細
	if ((Request["ar_form"] ?? "") == "A4") {//延展
		if ((Request["tfgp_mod_dmt"] ?? "") == "Y") {//變更商標／標章名稱
			ColMap.Clear();
			ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
			ColMap["in_no"] = "'" + RSno + "'";
			ColMap["mod_field"] = "'mod_dmt'";
			ColMap["ncname1"] = Util.dbchar(Request["new_appl_name"]);

			SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
			conn.ExecuteNonQuery(SQL);
		}
	}

	//後續交辦作業，更新營洽官收確認紀錄檔grconf_dmt.job_no
	upd_grconf_job_no(conn, RSno);

	//更新客戶主檔最近立案日
	upd_dmt_date(conn, RSno);
	
	If Trim(Request.Form("chkTest"))<>Empty Then
		cnn.RollbackTrans
		Response.Write "cnn.RollbackTrans...<br>"
		Response.End
	End If
	cnn.CommitTrans	
End sub
%>

<!--#include file="CaseForm/ShowDoneBox.inc"-->