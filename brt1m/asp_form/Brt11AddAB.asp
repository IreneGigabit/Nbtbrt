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
	
	//****�s�W�i���u���v���
	insert_casedmt_show(conn, RSno,"0");

	//***������
	if ((Request["ar_form"] ?? "") == "AB") {//��(��)�o��
		ColMap.Clear();
		foreach (var key in Request.Form.Keys) {
			string colkey = key.ToString().ToLower();
			string colValue = Request[colkey];

			//��1~4�X
			if (colkey.Left(4) == "tfg1") {
				ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
			}
		}

		if ((Request["O_item1"] ?? "") != ""||(Request["O_item2"] ?? "") != "") {//����
			ColMap["other_item"] = Util.dbchar(Request["O_item1"] + ";" + Request["O_item2"]);
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