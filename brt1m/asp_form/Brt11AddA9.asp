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

strSQL = "delete from caseitem_dmt where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"'"
cmd.CommandText=strSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "1=" & strSQL & "<hr>"
cmd.Execute(strSQL)

stSQL = "delete from casedmt_good where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "2=" & stSQL & "<hr>"
cmd.Execute(stSQL)

stSQL = "delete from casedmt_show where in_no='"&request("In_no")&"' and case_sqlno=0"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "3=" & stSQL & "<hr>"
cmd.Execute(stSQL)

stSQL = "delete from dmt_tran where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "4=" & stSQL & "<hr>"
cmd.Execute(stSQL)

stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "5=" & stSQL & "<hr>"
cmd.Execute(stSQL)

v=split(request("tfy_arcase"),"&")
arcase=v(0)
prt_code=v(1)

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

string save1 = "";
if ((Request["tfy_arcase"] ?? "") == "FP1") {
	save1 = "tfg1";//欄位開頭
} else if ((Request["tfy_arcase"] ?? "") == "FP2") {
	save1 = "tfg2";
}

//***異動檔
ColMap.Clear();
foreach (var key in Request.Form.Keys) {
	string colkey = key.ToString().ToLower();
	string colValue = Request[colkey];

	//取1~4碼
	if (colkey.Left(4) == save1) {
		ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
	}
}

ColMap["other_item"] = Util.dbchar(Request["O_item1"] + ";" + Request["O_item2"]);

if ((Request["O_item3"] ?? "") != "") {
	ColMap["other_item1"] = Util.dbchar(Request["O_item3"] + ";" + Request["O_item4"]);
}

ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
ColMap["in_no"] = Util.dbchar(Request["in_no"]);
ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
ColMap["tr_scode"] = "'" + Session["scode"] + "'";
SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
conn.ExecuteNonQuery(SQL);

//*****新增案件異動明細檔,關係人
for (int i = 1; i <= Convert.ToInt32("0" + Request["ft_apnum"]); i++) {
	ColMap.Clear();
	ColMap["in_scode"] = Util.dbchar(Request["in_scode"]);
	ColMap["in_no"] = Util.dbchar(Request["in_no"]);
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
	conn.ExecuteNonQuery(SQL);
}
	 
	 '申請人入log_table
	'call insert_log_table(cnn,"U",tprgid,"dmt_temp_ap","in_no;case_sqlno",trim(request("in_no"))&";0")
//寫入交辦申請人檔(dmt_temp_ap)
insert_dmt_temp_ap(conn,"0");

//*****文件上傳
Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"]??""));

//更新營洽官收確認紀錄檔(grconf_dmt.job_no)
upd_grconf_job_no(conn);

	'當程序有修改復案或結案註記時通知營洽人員
	if ucase(prgid)="BRT51" then
	   nback_flag=request("tfy_back_flag")
		if request("tfy_back_flag")=empty then nback_flag="N"
		oback_flag=request("oback_flag")
		if request("oback_flag")=empty then oback_flag="N"
		nend_flag=request("tfy_end_flag")
		if request("tfy_end_flag")=empty then nend_flag="N"
		oend_flag=request("oend_flag")
		if request("oend_flag")=empty then oend_flag="N"
	   	'Response.Write "b1:"&request("oback_flag") & ",b2:"&nback_flag&",e1:"&request("oend_flag") & ",e2:"&nend_flag
	   	'Response.End
	   if trim(nback_flag)<>trim(oback_flag) or trim(nend_flag)<> trim(oend_flag) then
	      Call Sendmail(nback_flag,nend_flag)		        
	      DoSendMail subject,body	
	   end if
	end if			
	
	If Trim(Request.Form("chkTest"))<>Empty Then
		cnn.RollbackTrans
		Response.Write "cnn.RollbackTrans...<br>"
		Response.End
	End If
	cnn.CommitTrans  
End sub '---- doUpdateDB() ----
%>