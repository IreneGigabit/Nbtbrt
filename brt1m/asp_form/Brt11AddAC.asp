<%
Sub doUpdateDB()

set RS=Server.CreateObject("ADODB.recordset")
set RSinfo=Server.CreateObject("ADODB.recordset")
set cmd=Server.CreateObject("ADODB.command")
set cnn=Server.CreateObject("ADODB.connection")
cnn.Open session("btbrtdb")
cmd.ActiveConnection=cnn
cnn.BeginTrans	
	
'******************���ͬy����

	SQLno="SELECT MAX(in_no) FROM case_dmt WHERE (LEFT(in_no, 4) = YEAR(GETDATE()))"
	
	//�g�Jcase_dmt
	insert_case_dmt(conn, RSno);

	//�g�Jdmt_temp
	insert_dmt_temp(conn, RSno);

	//�g�J�����O����
	insert_caseitem_dmt(conn, RSno);

	//�g�J�ӫ~���O��
	insert_casedmt_good(conn, RSno);

	//***������
	if ((Request["ar_form"] ?? "") == "AC") {//�\��
		ColMap.Clear();
		foreach (var key in Request.Form.Keys) {
			string colkey = key.ToString().ToLower();
			string colValue = Request[colkey];

			//��2~4�X
			if (colkey.Left(4).Substring(1) == "fg1") {
				if (colkey.Left(1) == "p") {
					ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
				} else if (colkey.Left(1) == "d") {
					ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
				} else {
					ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
				}
			}
		}

		ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
		ColMap["in_no"] = "'" + RSno + "'";
		ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
		ColMap["tr_scode"] = "'" + Session["scode"] + "'";
		SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
		conn.ExecuteNonQuery(SQL);
	}
	
	//�g�J���ӽФH��
	insert_dmt_temp_ap(conn, RSno,"0");	

	//*****�s�W���W��
	insert_dmt_attach(conn, RSno);

	//������@�~�A��s�笢�x���T�{������grconf_dmt.job_no
	upd_grconf_job_no(conn, RSno);

	//��s�Ȥ�D�ɳ̪�߮פ�
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