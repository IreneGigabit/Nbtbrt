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

    //重建暫存檔
	using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST")) {
		SQL="delete from dmt_temp_change where in_scode='"+Request["F_tscode"]+"' and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' and mark='T'";
		conn.ExecuteNonQuery(SQL);
		SQL="delete from casedmt_good_change where in_scode='"+Request["F_tscode"]+"' and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' and mark='T'";
		conn.ExecuteNonQuery(SQL);
		SQL="delete from casedmt_show_change where in_scode='"+Request["F_tscode"]+"' and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' and mark='T'";
		conn.ExecuteNonQuery(SQL);

		Datatable dt=new Datatable();
		SQL="select * from case_dmt1 where in_no= '"+RSno+"'";
		conn.DataTable(SQL, dt);
		for (int i = 0; i < dt.Rows.Count; i++) {
			SQL="insert into dmt_temp_change(s_mark,s_mark2,pul,appl_name,cappl_name,eappl_name";
			SQL+=",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
			SQL+=",zappl_name2,zname_type,oappl_name,Draw,symbol,color,prior_date,prior_no ";
			SQL+=",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
			SQL+=",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
			SQL+=",end_code,dmt_term1,dmt_term2,renewal,seq,seq1,draw_file,class_type ";
			SQL+=",class_count,class ";
			SQL+=",in_scode,cust_area,cust_seq,num,tr_date,tr_scode,mark) ";
			SQL+="Select s_mark,s_mark2 as ts_mark,pul,appl_name,cappl_name,eappl_name ";
			SQL+=",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
			SQL+=",zappl_name2,zname_type,oappl_name,Draw,symbol,color,prior_date,prior_no ";
			SQL+=",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
			SQL+=",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
			SQL+=",end_code,dmt_term1,dmt_term2,renewal,seq,seq1,draw_file,class_type ";
			SQL+=",class_count,class ";
			SQL+=",'"+Request["F_tscode"]+"','"+Request["F_cust_area"]+"','"+Request["F_cust_seq"]+"','"+(i+1)+"' ";
			SQL+=",getdate(),'" + Session["scode"] + "','T' ";
			SQL+="from dmt_temp where in_no='"+RSno+"' and case_sqlno="+dt.Rows[i]["case_sqlno"]+"";
			conn.ExecuteNonQuery(SQL);

			SQL = "INSERT INTO casedmt_good_change(in_scode,cust_area,cust_seq,num,class,dmt_grp_code";
			SQL+=",dmt_goodname,dmt_goodcount,tr_date,tr_scode,mark) ";
			SQL+="select '"+Request["F_tscode"]+"','"+Request["F_cust_area"]+"','"+Request["F_cust_seq"]+"','"+(i+1)+"'";
			SQL+=",class,dmt_grp_code,dmt_goodname,dmt_goodcount,getdate()'" + Session["scode"] + "','T' "
			SQL+="from casedmt_good where in_no='"+RSno+"' and case_sqlno="+dt.Rows[i]["case_sqlno"]+"";
			conn.ExecuteNonQuery(SQL);

			SQL = "INSERT INTO casedmt_show_change(in_scode,cust_area,cust_seq,num,show_no,show_date";
			SQL+=",show_name,tr_date,tr_scode,mark) ";
			SQL+="select '"+Request["F_tscode"]+"','"+Request["F_cust_area"]+"','"+Request["F_cust_seq"]+"','"+(i+1)+"'";
			SQL+=",ROW_NUMBER() OVER(ORDER BY show_sqlno),show_date,show_name,getdate()";
			SQL+=",'" + Session["scode"] + "','T' "
			SQL+="from casedmt_show where in_no='"+RSno+"' and case_sqlno="+dt.Rows[i]["case_sqlno"]+" order by show_sqlno";
			conn.ExecuteNonQuery(SQL);
		}
		conn.Commit();
	}

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

    //*****新增案件移轉檔
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

	//*****新增案件異動明細檔，關係人資料
	for (int i = 1; i <= Convert.ToInt32("0" + Request["ft_apnum"]); i++) {
		ColMap.Clear();
		ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
		ColMap["in_no"] = "'" + RSno + "'";
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
		ColMap["tran_code"] = "'N'";

		SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
		conn.ExecuteNonQuery(SQL);
	}
 
	//寫入交辦申請人檔
	insert_dmt_temp_ap(conn, RSno,"0");	

	//*****新增文件上傳
	insert_dmt_attach(conn, RSno);

	//移轉多件入檔	
	if((Request["tfy_arcase"] ?? "")=="FT2"){
		for (int i = 2; i <= Convert.ToInt32("0" + Request["nfy_tot_num"]); i++) {
			ColMap.Clear();
			ColMap["in_no"] = Util.dbchar(RSno);
			ColMap["seq"] = Util.dbnull(Request["dseqb_"+i]);
			ColMap["seq1"] = Util.dbnull(Request["dseq1b_"+i]);
			ColMap["Cseq"] = Util.dbnull(Request["dmseqb_"+i]);
			ColMap["Cseq1"] = Util.dbnull(Request["dmseq1b_"+i]);
			ColMap["case_stat1"] = ((Request["dseqb_"+i]??"")!=""?"OO":"NN");
			SQL = "insert into case_dmt1 " + ColMap.GetInsertSQL();
			conn.ExecuteNonQuery(SQL);

			//抓insert後的流水號
			SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
			object objResult1 = conn.ExecuteScalar(SQL);
			string case_sqlno = objResult1.ToString();

			if((Request["dseqb_"+i]??"")==""){
				//抓圖檔
				SQL="SELECT draw_file FROM dmt_temp_change where in_scode='"+Request["F_tscode"]+"' and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' and num='"+i+"' and mark='T'";
				object objResult2 = conn.ExecuteScalar(SQL);
				if (objResult2!=null){
					string draw_file = objResult2.ToString();
					//將檔案更改檔名
					string newfilename = move_file(RSno, draw_file,"-FT"+i);

					SQL="insert into dmt_temp(s_mark,s_mark2,pul,apsqlno,ap_cname,ap_cname1,ap_cname2 ";
					SQL+=",ap_ename,ap_ename1,ap_ename2,appl_name,cappl_name,eappl_name";
					SQL+=",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
					SQL+=",zappl_name2,zname_type,oappl_name,Draw,symbol,color,agt_no,prior_date,prior_no ";
					SQL+=",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
					SQL+=",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
					SQL+=",end_code,dmt_term1,dmt_term2,renewal,class_type,class_count,class ";
					SQL+=",in_scode,in_no,in_date,draw_file,tr_date,tr_scode,case_sqlno,seq1) ";
					SQL+="Select s_mark,s_mark2 as ts_mark,pul,"+Util.dbnull(Request["tfzp_apsqlno"])+" ";
					SQL+=","+Util.dbnull(Request["tfzp_ap_cname"])+","+Util.dbnull(Request["tfzp_ap_cname1"])+" ";
					SQL+=","+Util.dbnull(Request["tfzp_ap_cname2"])+","+Util.dbnull(Request["tfzp_ap_ename"])+" ";
					SQL+=","+Util.dbnull(Request["tfzp_ap_ename1"])+","+Util.dbnull(Request["tfzp_ap_ename2"])+" ";
					SQL+=",appl_name,cappl_name,eappl_name ";
					SQL+=",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
					SQL+=",zappl_name2,zname_type,oappl_name,Draw,symbol,color ";
					SQL+=","+Util.dbnull(Request["tfzd_agt_no"])+",prior_date,prior_no ";
					SQL+=",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
					SQL+=",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
					SQL+=",end_code,dmt_term1,dmt_term2,renewal,class_type,class_count,class ";
					SQL+=",'"+Request["F_tscode"]+"','"+RSno+"','"+DateTime.Today.ToShortDateString()+"','"+newfilename+"' ";
					SQL+=",'" + DateTime.Today.ToShortDateString() + "','" + Session["scode"] + "',"+case_sqlno+",'"+Request["dseq1b_"+i])+"' ";
					SQL+="from dmt_temp_change where in_scode='"+Request["F_tscode"]+"' ";
					SQL+="and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' ";
					SQL+="and num='"+i+"' and mark='T'";
					conn.ExecuteNonQuery(SQL);	

					//申請人資料畫面Apcust_FC_RE_form.inc
					//*****申請人檔
					insert_dmt_temp_ap(conn, RSno,case_sqlno);	
				}

				//商品類別
				SQL = "INSERT INTO casedmt_good(in_scode,in_no,case_sqlno,class,dmt_grp_code,dmt_goodname,dmt_goodcount,tr_date,tr_scode) ";
				SQL+="select '"+Request["F_tscode"]+"','"+RSno+"',"+case_sqlno+",class,dmt_grp_code,dmt_goodname,dmt_goodcount";
				SQL+=",getdate()','" + Session["scode"] + "' "
				SQL+="from casedmt_good_change where in_scode='"+Request["F_tscode"]+"' ";
				SQL+="and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' ";
				SQL+="and num='"+i+"' and mark='T' and (isnull(class,'')<>'' or isnull(dmt_goodname,'')<>'')";
				conn.ExecuteNonQuery(SQL);

				//展覽會優先權
				SQL = "INSERT INTO casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) ";
				SQL+="select '"+RSno+"',"+case_sqlno+",show_date,show_name,getdate()";
				SQL+="'" + Session["scode"] + "' "
				SQL+="from casedmt_show_change where in_scode='"+Request["F_tscode"]+"' ";
				SQL+="and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' ";
				SQL+="and num='"+i+"' and mark='T' order by show_no";
				conn.ExecuteNonQuery(SQL);
			}
		}
		//清空暫存檔
		SQL="delete from dmt_temp_change where in_scode='"+Request["F_tscode"]+"' and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' and mark='T'";
		conn.ExecuteNonQuery(SQL);
		SQL="delete from casedmt_good_change where in_scode='"+Request["F_tscode"]+"' and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' and mark='T'";
		conn.ExecuteNonQuery(SQL);
		SQL="delete from casedmt_show_change where in_scode='"+Request["F_tscode"]+"' and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' and mark='T'";
		conn.ExecuteNonQuery(SQL);
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