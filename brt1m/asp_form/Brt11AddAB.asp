<%
Sub doUpdateDB()

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
	if ((Request["ar_form"] ?? "") == "AB") {//捕(換)發證
		ColMap.Clear();
		foreach (var key in Request.Form.Keys) {
			string colkey = key.ToString().ToLower();
			string colValue = Request[colkey];

			//取1~4碼
			if (colkey.Left(4) == "tfg1") {
				ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
			}
		}

		if ((Request["O_item1"] ?? "") != ""||(Request["O_item2"] ?? "") != "") {//附註
			ColMap["other_item"] = Util.dbchar(Request["O_item1"] + ";" + Request["O_item2"]);
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