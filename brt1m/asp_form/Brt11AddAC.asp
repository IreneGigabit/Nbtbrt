<%
Sub doUpdateDB()
set cmd=Server.CreateObject("ADODB.command")
set cnn=Server.CreateObject("ADODB.connection")
set RSinfo=Server.CreateObject("ADODB.recordset")
cnn.Open session("btbrtdb")
cmd.ActiveConnection=cnn
cnn.BeginTrans	


//�g�JLog��
log_table(conn);

//SQL = "delete from caseitem_dmt where in_no='"+Request["in_no"]+"' and in_scode='"+Request["in_scode"]+"'";
//conn.ExecuteNonQuery(SQL);

//SQL = "delete from casedmt_good where in_no='"+Request["in_no"]+"' and in_scode='"+Request["in_scode"]+"'";
//conn.ExecuteNonQuery(SQL);

//�g�J�����O����(case_dmt)
update_case_dmt(conn);
	
//�g�J�����O���D��(dmt_temp)
update_dmt_temp(conn);

//�g�J�����O����(caseitem_dmt)
insert_caseitem_dmt(conn);

//�g�J�ӫ~���O��(casedmt_good)
insert_casedmt_good(conn);

'*****�ɴ����U��
	'dmt_tran�Jlog
	'call insert_log_table(cnn,"U",tprgid,"dmt_tran","in_no;in_scode",trim(request("in_no"))&";"&trim(request("in_scode"))) 
	ColMap.Clear();
	foreach (var key in Request.Form.Keys) {
		string colkey = key.ToString().ToLower();
		string colValue = Request[colkey];

		//��2~4�X
		if (colkey.Left(4).Substring(1) == "fg1") {
			if (colkey.Left(1) == "d") {
				ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
			} else {
				ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
			}
		}
	}

	ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
	ColMap["tr_scode"] = "'" + Session["scode"] + "'";
	ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
	ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
	ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
	SQL = "UPDATE dmt_tran set " + ColMap.GetUpdateSQL();
	SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
	conn.ExecuteNonQuery(SQL);
  
'�ӽФH�Jlog_table
	 'call insert_log_table(cnn,"U",tprgid,"dmt_temp_ap","in_no;case_sqlno",trim(request("in_no"))&";0")
//�g�J���ӽФH��(dmt_temp_ap)
insert_dmt_temp_ap(conn,"0");

//*****���W��
Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"]??""));

//��s�笢�x���T�{������(grconf_dmt.job_no)
upd_grconf_job_no(conn);

//��{�Ǧ��ק�_�שε��׵��O�ɳq���笢�H��
chk_end_back();
 
End sub '---- doUpdateDB() ----
%>