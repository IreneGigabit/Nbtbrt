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

string save1="";
if ((Request["tfy_arcase"] ?? "") == "FP1"){
	save1="tfg1";//���}�Y
}else if ((Request["tfy_arcase"] ?? "") == "FP2"){
	save1="tfg2";
}

	//***������
	if ((Request["ar_form"] ?? "") == "A9") {//���v
		ColMap.Clear();
		foreach (var key in Request.Form.Keys) {
			string colkey = key.ToString().ToLower();
			string colValue = Request[colkey];

			//��2~5�X
			if (colkey.Left(5).Substring(1) == save1) {
				if (colkey.Left(1) == "p") {
					ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
				} else if (colkey.Left(1) == "d") {
					ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
				} else {
					ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
				}
			}
		}

		ColMap["other_item"] = Util.dbchar(Request["O_item1"] + ";" + Request["O_item2"]);
		
		if ((Request["O_item3"] ?? "") != "") {
			ColMap["other_item1"] = Util.dbchar(Request["O_item3"] + ";" + Request["O_item4"]);
		}

		ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
		ColMap["in_no"] = "'" + RSno + "'";
		ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
		ColMap["tr_scode"] = "'" + Session["scode"] + "'";
		SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
		conn.ExecuteNonQuery(SQL);
	}


//*****�s�W�ץ󲧰ʩ�����,���Y�H
	if ((Request["ar_form"] ?? "") == "A9") {//���v
for (int i = 1; i <= Convert.ToInt32("0" + Request["ft_apnum"]); i++) {
            ColMap.Clear();
            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
            ColMap["in_no"] = "'" + RSno + "'";
            ColMap["mod_field"] = "'mod_ap'";
            ColMap["old_no"] = Util.dbchar(Request["tfr1_apcust_no_" + i]);
            ColMap["ocname1"] = Util.dbchar(Request["tfr1_ap_cname1_" + i]);
            ColMap["ocname2"] = Util.dbchar(Request["tfr1_ap_cname2_" + i]);
            ColMap["oename1"] = Util.dbchar(Request["tfr1_ap_ename1_" + i]);
            ColMap["oename2"] = Util.dbchar(Request["tfr1_ap_ename2_" + i]);
            ColMap["ocrep"] = Util.dbchar(Request["tfr1_ap_crep_" + i]);
            ColMap["oerep"] = Util.dbchar(Request["tfr1_ap_erep_" + i]);
            ColMap["ozip"] = Util.dbchar(Request["tfr1_ap_zip_" + i]);
            ColMap["oaddr1"] = Util.dbchar(Request["tfr1_ap_addr1_" + i]);
            ColMap["oaddr2"] = Util.dbchar(Request["tfr1_ap_addr2_" + i]);
            ColMap["oeaddr1"] = Util.dbchar(Request["tfr1_ap_eaddr1_" + i]);
            ColMap["oeaddr2"] = Util.dbchar(Request["tfr1_ap_eaddr2_" + i]);
            ColMap["oeaddr3"] = Util.dbchar(Request["tfr1_ap_eaddr3_" + i]);
            ColMap["oeaddr4"] = Util.dbchar(Request["tfr1_ap_eaddr4_" + i]);
            ColMap["otel0"] = Util.dbchar(Request["tfr1_apatt_tel0_" + i]);
            ColMap["otel"] = Util.dbchar(Request["tfr1_apatt_tel_" + i]);
            ColMap["otel1"] = Util.dbchar(Request["tfr1_apatt_tel1_" + i]);
            ColMap["ofax"] = Util.dbchar(Request["tfr1_apatt_fax_" + i]);
            ColMap["oapclass"] = Util.dbchar(Request["tfr1_oapclass_" + i]);
            ColMap["oap_country"] = Util.dbchar(Request["tfr1_oap_country_" + i]);
            ColMap["tran_code"] = "'N'";

            SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
            //Response.Write(SQL + "<HR>");
            conn.ExecuteNonQuery(SQL);
        }	
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