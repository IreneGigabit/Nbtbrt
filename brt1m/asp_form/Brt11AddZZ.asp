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

	//�g�J���ӽФH��
	insert_dmt_temp_ap(conn, RSno,"0");	

	//***������
	if ((Request["tfy_arcase"] ?? "").Left(3)=="FOB") {
		if ((Request["tfg1_other_item"] ?? "")!="") {
			SQL= "INSERT INTO dmt_tran(in_scode,in_no,other_item,tr_date,tr_scode,seq,seq1,agt_no1)";
		  SQL+=" values (" + Util.dbchar(Request["F_tscode"]) + ",'" + RSno + "'," + Util.dbnull(Request["tfg1_other_item"]) ;
		  SQL+=",'" + DateTime.Today.ToShortDateString() + "','" + Session["scode"] + "'" ;
		  SQL+=","+ Request["tfg1_seq"]+",'"+ Request["tfg1_seq1"]+"','"+ Request["tfg1_agt_no1"] +"')";
		  conn.ExecuteNonQuery(SQL);
		}
	}else if ((Request["tfy_arcase"] ?? "").Left(3)=="AD7") {
		SQL= "INSERT INTO dmt_tran(in_scode,in_no,other_item,other_item1,other_item2,tran_remark1,tran_mark,tr_date,tr_scode,seq,seq1)";
		SQL+=" values ('" + Request["F_tscode"] + "','" + RSno + "','" + Request["fr4_other_item"] + "'";
		SQL+=",'" + Request["fr4_other_item1"] + "','" + Request["fr4_other_item2"] + "'";
		SQL+=",'" + Request["fr4_tran_remark1"] + "','" + Request["fr4_tran_mark"] + "'";
		SQL+=",'" + DateTime.Today.ToShortDateString() + "','" + Session["scode"] + "'";
		SQL+=","+Request["tfg1_seq"] +",'"+ Request["tfzb_seq1"]+"')";
			conn.ExecuteNonQuery(SQL);

		//�s�W��ӷ�ƤH���
		        for (int k = 1; k <= Convert.ToInt32("0" + Request["de1_apnum"]); k++) {
			SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,naddr1) values (";
			SQL+= "'" + Request["F_tscode"] + "','" + RSno + "','mod_client'";
			SQL+= "," + Util.dbchar(Request["tfr4_ncname1_" + k]) ;
			SQL+= "," + Util.dbchar(Request["tfr4_naddr1_" + k]) + ")";
			conn.ExecuteNonQuery(SQL);
		}
	}else if ((Request["tfy_arcase"] ?? "").Left(3)=="AD8") {
		SQL= "INSERT INTO dmt_tran(in_scode,in_no,other_item,other_item1,other_item2,tran_remark1,tr_date,tr_scode,seq,seq1)";
			SQL+=" values ('" + Request["F_tscode"] + "','" + RSno + "','" + Request["fr4_other_item"] + "'";
			SQL+=",'" + Request["fr4_other_item1"] + "','" + Request["fr4_other_item2"] + "'";
			SQL+=",'" + Request["fr4_tran_remark1"] + "','" + DateTime.Today.ToShortDateString() + "','" + Session["scode"] + "'";
			SQL+="," +Request["tfg1_seq"] +",'"+ Request["tfzb_seq1"]+"')";
			conn.ExecuteNonQuery(SQL);
	}else if ((Request["tfy_arcase"] ?? "").Left(3)=="FOF") {
		SQL= "insert into dmt_tran(in_scode,in_no,seq,seq1,agt_no1,debit_money,other_item,other_item1,other_item2,tr_date,tr_scode) ";
			SQL+="values ('" + Request["F_tscode"] + "','" + RSno + "'," + Request["tfg1_seq"]	+",'" + Request["tfg1_seq1"] + "','" + Request["tfzf_agt_no1"] + "'";
			SQL+=","+Request["tfzf_debit_money"] + "," + Util.dbchar(Request["tfzf_other_item"]) + "," + Util.dbchar(Request["tfzf_other_item1"]) + "," + Util.dbchar(Request["tfzf_other_item2"]);
			SQL+=",getdate(),'" + Session["scode"] + "')";
			conn.ExecuteNonQuery(SQL);
	}else if ((Request["tfy_arcase"] ?? "").Left(3)=="FB7") {
		SQL= "insert into dmt_tran(in_scode,in_no,seq,seq1,agt_no1,other_item,tr_date,tr_scode) ";
			SQL+="values ('" + Request["F_tscode"] + "','" + RSno + "','" + Request["tfzb_seq"]+"','" + Request["tfzb_seq1"] + "','" + Request["tfb7_agt_no1"] + "'";
			SQL+=",'" + trim(Request["tfb7_other_item"]) + "'";
			SQL+=",getdate(),'" + Session["scode"] + "')";
			conn.ExecuteNonQuery(SQL);
	}else if ((Request["tfy_arcase"] ?? "").Left(3)=="FW1") {
		SQL= "INSERT INTO dmt_tran(in_scode,in_no,mod_claim1,tran_remark1,tr_date,tr_scode,seq,seq1,agt_no1,other_item)";
			SQL+=" values ('" + Request["F_tscode"] + "','" + RSno + "','" + Request["tfw1_mod_claim1"] + "'," + Util.dbnull(Request["tfw1_tran_remark1"])+"");
			SQL+=",'" + DateTime.Today.ToShortDateString() + "','" + Session["scode"] + "'";
			SQL+=",'" +Request["tfg1_seq"] +",'"+ Request["tfg1_seq1"]+"','"+ Request["tfg1_agt_no1"] +"','" + Request["tfw1_other_item"] + "')";
			conn.ExecuteNonQuery(SQL);
	}else{
		SQL= "INSERT INTO dmt_tran(in_scode,in_no,tran_remark1,tr_date,tr_scode,seq,seq1,agt_no1)";
			SQL+=" values ('" + Request["F_tscode"] + "','" + RSno + "'," + Util.dbnull(Request["tfg1_tran_remark1"])+"");
			SQL+=",'" + DateTime.Today.ToShortDateString() + "','" + Session["scode"] + "'";
			SQL+=",'" +Request["tfg1_seq"]+",'"+ Request["tfg1_seq1"]+"','"+ Request["tfg1_agt_no1"] +"')";
			conn.ExecuteNonQuery(SQL);
	}

if ((Request["tfg1_other_item"] ?? "")!="") {
	for (int i = 2; i <= 11; i++) {
		if ((Request["ttz1_P"+i] ?? "")!="") {
				SQL="INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,mod_type,mod_dclass,new_no) values (";
				SQL+= " '"+ Request["F_tscode"] +"','" + RSno + "','other_item','"+Request["ttz1_P"+i]+"'";
				SQL+= ","+Util.dbchar(Request["P"+i+"_mod_dclass"]) + ","+Util.dbchar(Request["P"+i+"_new_no"]) + ")";
			conn.ExecuteNonQuery(SQL);
		}	
	}
}
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