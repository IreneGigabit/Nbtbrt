<%
Sub doUpdateDB()
ntag = "1" 
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

stSQL = "delete from casedmt_good where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and case_sqlno=0"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "2=" & stSQL & "<hr>"
cmd.Execute(stSQL)

stSQL = "delete from casedmt_show where in_no='"&request("In_no")&"' and case_sqlno=0"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "3=" & stSQL & "<hr>"
cmd.Execute(stSQL)

stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_class'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "4=" & stSQL & "<hr>"
cmd.Execute(stSQL)
'刪除case_dmt1
dsql="delete from case_dmt1 where in_no='" & request("in_no") & "'"
cmd.CommandText=dsql
If Trim(Request("chkTest"))<>Empty Then Response.Write "5=" & dSQL & "<hr>"
cmd.Execute(dsql)
'刪除子案dmt_temp
dsql="delete from dmt_temp where in_no='" & request("in_no") & "' and case_sqlno<>0"
cmd.CommandText=dsql
If Trim(Request("chkTest"))<>Empty Then Response.Write "6=" & dSQL & "<hr>"
cmd.Execute(dsql)
'刪除子案casedmt_good
dsql="delete from casedmt_good where in_no='" & request("in_no") & "' and case_sqlno<>0"
cmd.CommandText=dsql
If Trim(Request("chkTest"))<>Empty Then Response.Write "7=" & dSQL & "<hr>"
cmd.Execute(dsql)
'刪除子案casedmt_show
dsql="delete from casedmt_show where in_no='" & request("in_no") & "' and case_sqlno<>0"
cmd.CommandText=dsql
If Trim(Request("chkTest"))<>Empty Then Response.Write "8=" & dSQL & "<hr>"
cmd.Execute(dsql)

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

//'dmt_tran入log
//'call insert_log_table(cnn,"U",tprgid,"dmt_tran","in_no;in_scode",trim(request("in_no"))&";"&trim(request("in_scode"))) 
//*****移轉檔
ColMap.Clear();
foreach (var key in Request.Form.Keys) {
	string colkey = key.ToString().ToLower();
	string colValue = Request[colkey];

	//取1~4碼
	if (colkey.Left(4) == "tfg1") {
		ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
	}
}

if ((Request["O_item1"] ?? "") != "" || (Request["O_item2"] ?? "") != "") {//附註
	ColMap["other_item"] = Util.dbchar(Request["O_item1"] + ";" + Request["O_item2"]);
}

if ((Request["other_item2"] ?? "") != "") {
	if ((Request["other_item2t"] ?? "") != "") {
		ColMap["other_item2"] = Util.dbchar(Request["other_item2"] + "," + Request["other_item2t"]);
	} else {
		ColMap["other_item2"] = Util.dbchar(Request["other_item2"]);
	}
}
ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
ColMap["tr_scode"] = "'" + Session["scode"] + "'";
ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);

//*****新增案件異動明細檔，關係人資料
SQL="delete from dmt_tranlist where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "' and mod_field='mod_ap'";
conn.ExecuteNonQuery(SQL);
for (int i = 1; i <= Convert.ToInt32("0" + Request["fl_apnum"]); i++) {
	ColMap.Clear();
	ColMap["in_scode"] = Util.dbchar(Request["in_scode"]);
	ColMap["in_no"] = Util.dbchar(Request["in_no"]);
	ColMap["mod_field"] = "'mod_ap'";
	ColMap["old_no"] = Util.dbchar(Request["tfr_old_no_" + i]);
	ColMap["ocname1"] = Util.dbchar(Request["tfr_ocname1_" + i]);
	ColMap["ocname2"] = Util.dbchar(Request["tfr_ocname2_" + i]);
	ColMap["oename1"] = Util.dbchar(Request["tfr_oename1_" + i]);
	ColMap["oename2"] = Util.dbchar(Request["tfr_oename2_" + i]);
	ColMap["ocrep"] = Util.dbchar(Request["tfr_ocrep_" + i]);
	ColMap["oerep"] = Util.dbchar(Request["tfr_oerep_" + i]);
	ColMap["ozip"] = Util.dbchar(Request["tfr_ozip_" + i]);
	ColMap["oaddr1"] = Util.dbchar(Request["tfr_oaddr1_" + i]);
	ColMap["oaddr2"] = Util.dbchar(Request["tfr_oaddr2_" + i]);
	ColMap["oeaddr1"] = Util.dbchar(Request["tfr_oeaddr1_" + i]);
	ColMap["oeaddr2"] = Util.dbchar(Request["tfr_oeaddr2_" + i]);
	ColMap["oeaddr3"] = Util.dbchar(Request["tfr_oeaddr3_" + i]);
	ColMap["oeaddr4"] = Util.dbchar(Request["tfr_oeaddr4_" + i]);
	ColMap["otel0"] = Util.dbchar(Request["tfr_otel0_" + i]);
	ColMap["otel"] = Util.dbchar(Request["tfr_otel_" + i]);
	ColMap["otel1"] = Util.dbchar(Request["otel1_" + i]);
	ColMap["ofax"] = Util.dbchar(Request["ofax_" + i]);
	ColMap["oapclass"] = Util.dbchar(Request["tfr_oapclass_" + i]);
	ColMap["oap_country"] = Util.dbchar(Request["tfr_oap_country_" + i]);
	ColMap["tran_code"] = "'N'";

	SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
	conn.ExecuteNonQuery(SQL);
}

//*****新增案件異動明細檔	
if ((Request["tfy_arcase"] ?? "") == "FL1" || (Request["tfy_arcase"] ?? "") == "FL5") {
	for (int x = 1; x <= Convert.ToInt32("0" + Request["num2"]); x++) {
		SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,mod_type,mod_count,mod_dclass,new_no,list_remark)";
		SQL += "VALUES('" + Request["F_tscode"] + "','" + Request("in_no") + "','mod_class'";
		SQL += "," + Util.dbchar(Request["tfl1_mod_type"]) + "," + Util.dbchar(Request["mod_count"]);
		SQL += "," + Util.dbchar(Request["mod_dclass"]) + "," + Util.dbchar(Request["new_no_" + x]);
		SQL += "," + Util.dbchar(Request["list_remark_" + x]) + ")";
		conn.ExecuteNonQuery(SQL);
	}
} else if ((Request["tfy_arcase"] ?? "") == "FL2" || (Request["tfy_arcase"] ?? "") == "FL6") {
	for (int x = 1; x <= Convert.ToInt32("0" + Request["num2"]); x++) {
		SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,mod_type,mod_count,mod_dclass,new_no,list_remark)";
		SQL += "VALUES('" + Request["F_tscode"] + "','" + Request("in_no") + "','mod_class'";
		SQL += "," + Util.dbchar(Request["tfl1_mod_type"]) + "," + Util.dbchar(Request["mod_count"]);
		SQL += "," + Util.dbchar(Request["mod_dclass"]) + "," + Util.dbchar(Request["new_no_" + x]);
		SQL += "," + Util.dbchar(Request["list_remark_" + x]) + ")";
		conn.ExecuteNonQuery(SQL);
	}
	//商標權人資料
	SQL="delete from dmt_tranlist where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "' and mod_field='mod_ap'";
	conn.ExecuteNonQuery(SQL);
	for (int i = 1; i <= Convert.ToInt32("0" + Request["fl2_apnum"]); i++) {
		ColMap.Clear();
		ColMap["in_scode"] = Util.dbchar(Request["in_scode"]);
		ColMap["in_no"] = Util.dbchar(Request["in_no"]);
		ColMap["mod_field"] = "'mod_tap'";
		ColMap["new_no"] = Util.dbchar(Request["tfv_new_no_" + i]);
		ColMap["ncname1"] = Util.dbchar(Request["tfv_ncname1_" + i]);
		ColMap["ncname2"] = Util.dbchar(Request["tfv_ncname2_" + i]);
		ColMap["nename1"] = Util.dbchar(Request["tfv_nename1_" + i]);
		ColMap["nename2"] = Util.dbchar(Request["tfv_nename2_" + i]);
		ColMap["ncrep"] = Util.dbchar(Request["tfv_ncrep_" + i]);
		ColMap["nerep"] = Util.dbchar(Request["tfv_nerep_" + i]);
		ColMap["nzip"] = Util.dbchar(Request["tfv_nzip_" + i]);
		ColMap["naddr1"] = Util.dbchar(Request["tfv_naddr1_" + i]);
		ColMap["naddr2"] = Util.dbchar(Request["tfv_naddr2_" + i]);
		ColMap["neaddr1"] = Util.dbchar(Request["tfv_neaddr1_" + i]);
		ColMap["neaddr2"] = Util.dbchar(Request["tfv_neaddr2_" + i]);
		ColMap["neaddr3"] = Util.dbchar(Request["tfv_neaddr3_" + i]);
		ColMap["neaddr4"] = Util.dbchar(Request["tfv_neaddr4_" + i]);
		ColMap["ntel0"] = Util.dbchar(Request["tfv_ntel0_" + i]);
		ColMap["ntel"] = Util.dbchar(Request["tfv_ntel_" + i]);
		ColMap["ntel1"] = Util.dbchar(Request["tfv_ntel1_" + i]);
		ColMap["nfax"] = Util.dbchar(Request["tfv_nfax_" + i]);
		ColMap["napclass"] = Util.dbchar(Request["tfv_napclass_" + i]);
		ColMap["nap_country"] = Util.dbchar(Request["tfv_nap_country_" + i]);
		ColMap["tran_code"] = "'N'";

		SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
		conn.ExecuteNonQuery(SQL);
	}
}

//寫入交辦申請人檔(dmt_temp_ap)
insert_dmt_temp_ap(conn,"0");

//*****文件上傳
Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"]??""));

//授權及被授權多件入檔	
if ((Request["tfy_arcase"] ?? "") == "FL5" || (Request["tfy_arcase"] ?? "") == "FL6") {
	for (int i = 2; i <= Convert.ToInt32("0" + Request["nfy_tot_num"]); i++) {
		ColMap.Clear();
		ColMap["in_no"] = Util.dbchar(Request["in_no"]);
		ColMap["seq"] = Util.dbnull(Request["dseqb_" + i]);
		ColMap["seq1"] = Util.dbnull(Request["dseq1b_" + i]);
		ColMap["Cseq"] = Util.dbnull(Request["dseqb_" + i]);
		ColMap["Cseq1"] = Util.dbnull(Request["dseq1b_" + i]);
		ColMap["case_stat1"] = ((Request["dseqb_" + i] ?? "") != "" ? "'OO'" : "'NN'");
		SQL = "insert into case_dmt1 " + ColMap.GetInsertSQL();
		conn.ExecuteNonQuery(SQL);

		//抓insert後的流水號
		SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
		object objResult1 = conn.ExecuteScalar(SQL);
		string case_sqlno = objResult1.ToString();

		if ((Request["dseqb_" + i] ?? "") == "") {
			//抓圖檔
			SQL = "SELECT draw_file FROM dmt_temp_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and num='" + i + "' and mark='L'";
			object objResult2 = conn.ExecuteScalar(SQL);
			if (objResult2 != null) {
				string draw_file = objResult2.ToString();
				//將檔案更改檔名
				string newfilename = move_file(Request["in_no"], draw_file, "-FC" + i);

				SQL = "insert into dmt_temp(s_mark,s_mark2,pul,apsqlno,ap_cname,ap_cname1,ap_cname2 ";
				SQL += ",ap_ename,ap_ename1,ap_ename2,appl_name,cappl_name,eappl_name";
				SQL += ",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
				SQL += ",zappl_name2,zname_type,oappl_name,Draw,symbol,color,agt_no,prior_date,prior_no ";
				SQL += ",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
				SQL += ",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
				SQL += ",end_code,dmt_term1,dmt_term2,renewal,class_type,class_count,class ";
				SQL += ",in_scode,in_no,in_date,draw_file,tr_date,tr_scode,case_sqlno,seq1) ";
				SQL += "Select s_mark,s_mark2 as ts_mark,pul," + Util.dbnull(Request["tfzp_apsqlno"]) + " ";
				SQL += "," + Util.dbnull(Request["tfzp_ap_cname"]) + "," + Util.dbnull(Request["tfzp_ap_cname1"]) + " ";
				SQL += "," + Util.dbnull(Request["tfzp_ap_cname2"]) + "," + Util.dbnull(Request["tfzp_ap_ename"]) + " ";
				SQL += "," + Util.dbnull(Request["tfzp_ap_ename1"]) + "," + Util.dbnull(Request["tfzp_ap_ename2"]) + " ";
				SQL += ",appl_name,cappl_name,eappl_name ";
				SQL += ",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
				SQL += ",zappl_name2,zname_type,oappl_name,Draw,symbol,color ";
				SQL += "," + Util.dbnull(Request["tfzd_agt_no"]) + ",prior_date,prior_no ";
				SQL += ",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
				SQL += ",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
				SQL += ",end_code,dmt_term1,dmt_term2,renewal,class_type,class_count,class ";
				SQL += ",'" + Request["in_scode"] + "','" + Request["in_no"] + "','" + DateTime.Today.ToShortDateString() + "','" + newfilename + "' ";
				SQL += ",'" + DateTime.Today.ToShortDateString() + "','" + Session["scode"] + "'," + case_sqlno + ",'" + Request["dseq1b_" + i] + "' ";
				SQL += "from dmt_temp_change where in_scode='" + Request["F_tscode"] + "' ";
				SQL += "and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' ";
				SQL += "and num='" + i + "' and mark='L'";
				conn.ExecuteNonQuery(SQL);

				//申請人資料畫面Apcust_FC_RE_form.inc
				//*****申請人檔
				insert_dmt_temp_ap(conn, Request["in_no"], case_sqlno);
			}

			//商品類別
			SQL = "INSERT INTO casedmt_good(in_scode,in_no,case_sqlno,class,dmt_grp_code";
			SQL += ",dmt_goodname,dmt_goodcount,tr_date,tr_scode) ";
			SQL += "select '" + Request["in_scode"] + "','" + Request["in_no"] + "'," + case_sqlno + ",class,dmt_grp_code,dmt_goodname,dmt_goodcount";
			SQL += ",getdate(),'" + Session["scode"] + "' ";
			SQL += "from casedmt_good_change where in_scode='" + Request["F_tscode"] + "' ";
			SQL += "and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' ";
			SQL += "and num='" + i + "' and mark='L' and (isnull(class,'')<>'' or isnull(dmt_goodname,'')<>'')";
			conn.ExecuteNonQuery(SQL);

			//展覽會優先權
			SQL = "INSERT INTO casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) ";
			SQL += "select '" + Request["in_no"] + "'," + case_sqlno + ",show_date,show_name,getdate()";
			SQL += ",'" + Session["scode"] + "' ";
			SQL += "from casedmt_show_change where in_scode='" + Request["F_tscode"] + "' ";
			SQL += "and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' ";
			SQL += "and num='" + i + "' and mark='L' order by show_no";
			conn.ExecuteNonQuery(SQL);
		}
	}
	//清空暫存檔
	SQL = "delete from dmt_temp_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and mark='L'";
	conn.ExecuteNonQuery(SQL);
	SQL = "delete from casedmt_good_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and mark='L'";
	conn.ExecuteNonQuery(SQL);
	SQL = "delete from casedmt_show_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and mark='L'";
	conn.ExecuteNonQuery(SQL);
}

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
