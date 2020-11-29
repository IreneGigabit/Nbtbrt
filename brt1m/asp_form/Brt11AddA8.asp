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

strSQL = "delete from caseitem_dmt where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' "
cmd.CommandText=strSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "1=" & strSQL & "<hr>"
cmd.Execute(strSQL)

stSQL = "delete from casedmt_good where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"'  and case_sqlno=0"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "2=" & stSQL & "<hr>"
cmd.Execute(stSQL)

stSQL = "delete from casedmt_show where in_no='"&request("In_no")&"' and case_sqlno=0"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "3=" & stSQL & "<hr>"
cmd.Execute(stSQL)

'刪除case_dmt1
dsql="delete from case_dmt1 where in_no='" & request("in_no") & "'"
cmd.CommandText=dsql
If Trim(Request("chkTest"))<>Empty Then Response.Write "4=" & dSQL & "<hr>"
cmd.Execute(dsql)
'刪除子案dmt_temp
dsql="delete from dmt_temp where in_no='" & request("in_no") & "' and case_sqlno<>0"
cmd.CommandText=dsql
If Trim(Request("chkTest"))<>Empty Then Response.Write "5=" & dSQL & "<hr>"
cmd.Execute(dsql)
'刪除子案casedmt_good
dsql="delete from casedmt_good where in_no='" & request("in_no") & "' and case_sqlno<>0"
cmd.CommandText=dsql
If Trim(Request("chkTest"))<>Empty Then Response.Write "6=" & dSQL & "<hr>"
cmd.Execute(dsql)
'刪除子案casedmt_show
dsql="delete from casedmt_show where in_no='" & request("in_no") & "' and case_sqlno<>0"
cmd.CommandText=dsql
If Trim(Request("chkTest"))<>Empty Then Response.Write "7=" & dSQL & "<hr>"
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


'*****移轉檔	
	'dmt_tran入log
	'call insert_log_table(cnn,"U",tprgid,"dmt_tran","in_no;in_scode",trim(request("in_no"))&";"&trim(request("in_scode"))) 
	sql = "UPDATE dmt_tran SET "   
	sqlWhere = ""
	for each x in request.form		
	     if mid(x,2,3) = "fg1" or mid(x,1,4) = "tfzb" then	  
		  			select case left(x,1)		       
						 case "d"
							 sql = sql & " " & mid(x,6) & "=" & pkStr(request(x),",")
						 case "n"
							 sql = sql & " " & mid(x,6) & "=" & drn(x)
						 case else
						 'Response.Write x&"<br>"
							 if x="tfzb_seq" then
								sql = sql & " " & mid(x,6) & "=" & drn(x)
							 else
							 sql = sql & " " & mid(x,6) & "=" & pkStr(request(x),",")
							 end if
					 end select
	     end if
  next
  if request("O_item1") <>empty or Request("O_item2") <>empty then
		 sql = sql & " other_item = '" & Request("O_item1") & ";" & Request("O_item2") & "'," 	
  end if  
  sql = sql & " tr_date  = '" & date() & "'," & _
			  " tr_scode = '" & session("se_scode") & "',"
  SQL=  sql & "in_scode = '" & request("F_tscode") & "',"
  sqlWhere = " where in_scode = '" & request("in_scode") & "' and in_no = '" & request("In_no") & "'" 
  sql = left(sql,len(sql)-1) & sqlWHERE   
  
  'Response.Write SQL&"<br><br><br>"
  'Response.End
  
  cmd.CommandText=SQL
	If Trim(Request("chkTest"))<>Empty Then Response.Write "14=" & SQL & "<hr>"
	cmd.Execute(SQL)
'*****新增案件異動明細檔，關係人資料
	'dmt_tranlist入log_table
	'call insert_log_table(cnn,"U",tprgid,"dmt_tranlist","in_no;in_scode",trim(request("in_no"))&";" & trim(request("in_scode")))	
    dsql="delete from dmt_tranlist where in_no='" & trim(request("in_no")) & "' and in_scode='" & trim(request("in_scode")) & "' and mod_field='mod_ap'"
    cmd.CommandText=dSQL
	If Trim(Request("chkTest"))<>Empty Then Response.Write "15=" & dSQL & "<hr>"
	cmd.Execute(dSQL)
	for k=1 to request("ft_apnum")
		 ocname1 = replace(trim(request("tfr_ocname1_" & k)),"'","’")
		 ocname1 = replace(ocname1,"&","＆")
		 ocname2 = replace(trim(request("tfr_ocname2_" & k)),"'","’")
		 ocname2 = replace(ocname2,"&","＆")
		 oename1 = replace(trim(request("tfr_oename1_" & k)),"'","’")
		 oename1 = replace(oename1,"&","＆")
		 oename2 = replace(trim(request("tfr_oename2_" & k)),"'","’")
		 oename2 = replace(oename2,"&","＆")
         sql3="insert into dmt_tranlist(in_scode,in_no,mod_field,old_no,ocname1,ocname2,oename1,oename2,"
         sql3=sql3 & "ocrep,oerep,ozip,oaddr1,oaddr2,oeaddr1,oeaddr2,oeaddr3,oeaddr4,otel0,otel,otel1,ofax,"
         sql3=sql3 & "tran_code) values('" & request("in_scode") & "','" & request("in_no") & "','mod_ap','" & request("tfr_old_no"&k) & "'"
         sql3=sql3 & ",'" & ocname1 & "','" & ocname2 & "','" & oename1 & "','" & oename2 & "','" & trim(request("tfr_ocrep"&k)) & "',"
         sql3=sql3 & "'" & trim(request("tfr_oerep"&k)) & "','" & trim(request("tfr_ozip"&k)) & "','" & trim(request("tfr_oaddr1_"&k)) & "',"
         sql3=sql3 & "'" & trim(request("tfr_oaddr2_"&k)) & "','" & trim(request("tfr_oeaddr1_" & k)) & "','" & trim(request("tfr_oeaddr2_" & k)) & "',"
         sql3=sql3 & "'" & trim(request("tfr_oeaddr3_"&k)) & "','" & trim(request("tfr_oeaddr4_"&k)) & "','" & trim(request("tfr_otel0_"&k)) & "',"
         sql3=sql3 & "'" & trim(request("tfr_otel"&k)) & "','" & trim(request("otel1_"&k)) & "','" & trim(request("ofax"&k)) & "','N')"
		 cmd.CommandText=SQL3	
'		 Response.Write "SQL_dmt_tranlist="&SQL3&"<br>"
'		 Response.End
	     If Trim(Request("chkTest"))<>Empty Then Response.Write "16=" & SQL3 & "<hr>"
		 cmd.Execute(SQL3)    
	 next    
  
'申請人入log_table
	 'call insert_log_table(cnn,"U",tprgid,"dmt_temp_ap","in_no;case_sqlno",trim(request("in_no"))&";0")
//寫入交辦申請人檔(dmt_temp_ap)
insert_dmt_temp_ap(conn,"0");

//*****文件上傳
Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"]??""));

'移轉多件入檔	
if arcase="FT2" then
	if request("nfy_tot_num")<>empty then
		for i=2 to request("nfy_tot_num")
			if trim(request("dseqb"&i))<>empty then
				SQL = "INSERT INTO case_dmt1(in_no,seq,seq1,Cseq,Cseq1,case_stat1)"
				SQL = SQL & "values ('"&request("in_no")&"',"&trim(request("dseqb"&i))&",'"&trim(request("dseq1b"&i))&"','"&trim(request("dmseqb"&i))&"','"&trim(request("dmseq1b"&i))&"','OO')"
				If Trim(Request("chkTest"))<>Empty Then Response.Write "19=" & SQL & "<hr>"
				Conn.Execute(SQL)
			Else
				IF trim(request("dseqb"&i))<>empty then
					dseqb=trim(request("dseqb"&i))
				Else
					dseqb="null"
				End IF
				SQL = "INSERT INTO case_dmt1(in_no,seq,seq1,Cseq,Cseq1,case_stat1,end_code,end_type,end_remark,end_flag)"
				SQL = SQL & "values ('"&request("in_no")&"',"&dseqb&",'"&trim(request("dseq1b"&i))&"','"& trim(request("dmseqb"&i)) &"','"&trim(request("dmseq1b"&i))&"','NN','" & trim(request("end_code51b"&i)) & "','" & trim(request("end_type51b"&i)) & "','" & trim(request("end_remark51b"&i)) & "','" & trim(request("endflag51b"&i)) & "')"
				Response.Write sql&"<br>"
				'Response.End
				If Trim(Request("chkTest"))<>Empty Then Response.Write "20=" & SQL & "<hr>"
				Conn.Execute(SQL)
			End IF
			SQLno="SELECT MAX(case_sqlno) AS case_sqlno FROM case_dmt1 "
			rsi.open sqlno,conn,1,1
			Case_sqlno=trim(rsi("case_sqlno"))
			rsi.close
			if trim(request("dseqb"&i))=empty then
				SQL3="SELECT * FROM  dmt_temp_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and num='"&i&"' and mark='T'"
				RCreg.open SQL3,conn,1,1
				IF not RCreg.EOF Then
					filepath="/btbrt/" & session("se_branch") & "t/temp"
					'Response.Write filepath
					filename = request("in_no")&"-FT"&i
					aa=trim(RCreg("draw_file"))
					if trim(aa) <> empty then
						'IF ubound(split(trim(RCreg("draw_file")),"\"))=0 then
						IF ubound(split(trim(RCreg("draw_file")),"/"))=0 then
							'filesource = server.MapPath(filepath) & "\" & aa 'temp
							'newfilename = server.MapPath(filepath) & "\" & filename & "." & right(aa,len(aa)-InstrRev(aa,"."))
							'fso.MoveFile filesource,newfilename
							'aa=filename & "." & right(aa,len(aa)-InstrRev(aa,"."))
							'2013/11/26修改可以中文檔名上傳及虛擬路徑
							strpath="/btbrt/" & session("se_branch") & "T/temp"
							attach_name = filename & "." & right(aa,len(aa)-InstrRev(aa,"."))	'重新命名檔名
							newfilename = strpath & "/" & attach_name	'存在資料庫路徑
							call renameFile_nobackup(strpath,aa,attach_name)
						else
							newfilename = trim(RCreg("draw_file"))
						End IF
					else
						newfilename = ""
					end if
			
						sql = "INSERT INTO dmt_temp("
								sqlValue = ") VALUES("
								IF trim(RCreg("S_mark"))<>empty then
									sql=sql&"s_mark,"
									sqlValue=sqlValue& "'"&Trim(RCreg("S_mark"))&"',"
								End IF
								IF trim(RCreg("s_mark2"))<>empty then
									sql=sql&"s_mark2,"
									sqlValue=sqlValue& "'"&Trim(RCreg("s_mark2"))&"',"
								End IF
								IF trim(RCreg("pul"))<>empty then
									sql=sql&"pul,"
									sqlValue=sqlValue& "'"&Trim(RCreg("pul"))&"',"
								End IF
								IF trim(request("tfzp_apsqlno"))<>empty then
									sql=sql&"apsqlno,"
									sqlValue=sqlValue& "'"&trim(request("tfzp_apsqlno"))&"',"
								End IF
								IF trim(request("tfzp_ap_cname"))<>empty then
									sql=sql&"ap_cname,"
									sqlValue=sqlValue& "'"&Trim(request("tfzp_ap_cname"))&"',"
								End IF
								IF trim(request("tfzp_ap_cname1"))<>empty then
									sql=sql&"ap_cname1,"
									sqlValue=sqlValue& "'"&trim(request("tfzp_ap_cname1"))&"',"
								End IF
								IF trim(request("tfzp_ap_cname2"))<>empty then
									sql=sql&"ap_cname2,"
									sqlValue=sqlValue& "'"&trim(request("tfzp_ap_cname2"))&"',"
								End IF
								IF trim(request("tfzp_ap_ename"))<>empty then
									sql=sql&"ap_ename,"
									sqlValue=sqlValue& "'"&trim(request("tfzp_ap_ename"))&"',"
								End IF
								IF trim(request("tfzp_ap_ename1"))<>empty then
									sql=sql&"ap_ename1,"
									sqlValue=sqlValue& "'"&trim(request("tfzp_ap_ename1"))&"',"
								End IF
								IF trim(request("tfzp_ap_ename2"))<>empty then
									sql=sql&"ap_ename2,"
									sqlValue=sqlValue& "'"&trim(request("tfzp_ap_ename2"))&"',"
								End IF
								IF trim(RCreg("Appl_name"))<>empty then
									sql=sql&"appl_name,"
									sqlValue=sqlValue& "'"&Trim(RCreg("Appl_name"))&"',"
								End IF
								IF trim(RCreg("cappl_name"))<>empty then
									sql=sql&"cappl_name,"
									sqlValue=sqlValue& "'"&trim(RCreg("cappl_name"))&"',"
								End IF
								IF trim(RCreg("eappl_name"))<>empty then
									sql=sql&"eappl_name,"
									sqlValue=sqlValue& "'"&trim(RCreg("eappl_name"))&"',"
								End IF
								IF trim(RCreg("eappl_name1"))<>empty then
									sql=sql&"eappl_name1,"
									sqlValue=sqlValue& "'"&trim(RCreg("eappl_name1"))&"',"
								End IF
								IF trim(RCreg("eappl_name2"))<>empty then
									sql=sql&"eappl_name2,"
									sqlValue=sqlValue& "'"&trim(RCreg("eappl_name2"))&"',"
								End IF
								IF trim(RCreg("jappl_name"))<>empty then
									sql=sql&"jappl_name,"
									sqlValue=sqlValue& "'"&trim(RCreg("jappl_name"))&"',"
								End IF
								IF trim(RCreg("jappl_name1"))<>empty then
									sql=sql&"jappl_name1,"
									sqlValue=sqlValue& "'"&trim(RCreg("jappl_name1"))&"',"
								End IF
								IF trim(RCreg("jappl_name2"))<>empty then
									sql=sql&"jappl_name2,"
									sqlValue=sqlValue& "'"&trim(RCreg("jappl_name2"))&"',"
								End IF
								IF trim(RCreg("zappl_name1"))<>empty then
									sql=sql&"zappl_name1,"
									sqlValue=sqlValue& "'"&trim(RCreg("zappl_name1"))&"',"
								End IF
								IF trim(RCreg("zappl_name2"))<>empty then
									sql=sql&"zappl_name2,"
									sqlValue=sqlValue& "'"&trim(RCreg("zappl_name2"))&"',"
								End IF
								IF trim(RCreg("zname_type"))<>empty then
									sql=sql&"zname_type,"
									sqlValue=sqlValue& "'"&trim(RCreg("zname_type"))&"',"
								End IF
								IF trim(RCreg("oappl_name"))<>empty then
									sql=sql&"oappl_name,"
									sqlValue=sqlValue& "'"&trim(RCreg("oappl_name"))&"',"
								End IF
								IF trim(RCreg("Draw"))<>empty then
									sql=sql&"Draw,"
									sqlValue=sqlValue& "'"&trim(RCreg("Draw"))&"',"
								End IF
								IF trim(RCreg("symbol"))<>empty then
									sql=sql&"symbol,"
									sqlValue=sqlValue& "'"&trim(RCreg("symbol"))&"',"
								End IF
								IF trim(RCreg("color"))<>empty then
									sql=sql&"color,"
									sqlValue=sqlValue& "'"&trim(RCreg("color"))&"',"
								End IF
								IF trim(request("tfzd_agt_no"))<>empty then
									sql=sql&"agt_no,"
									sqlValue=sqlValue& "'"&trim(request("tfzd_agt_no"))&"',"
								End IF
								IF trim(RCreg("prior_date"))<>empty then
									sql=sql&"prior_date,"
									sqlValue=sqlValue& "'"&trim(RCreg("prior_date"))&"',"
								End IF
								IF trim(RCreg("prior_no"))<>empty then
									sql=sql&"prior_no,"
									sqlValue=sqlValue& "'"&trim(RCreg("prior_no"))&"',"
								End IF
								IF trim(RCreg("prior_country"))<>empty then
									sql=sql&"prior_country,"
									sqlValue=sqlValue& "'"&trim(RCreg("prior_country"))&"',"
								End IF
								IF trim(RCreg("ref_no"))<>empty then
									sql=sql&"ref_no,"
									sqlValue=sqlValue& "'"&trim(RCreg("ref_no"))&"',"
								End IF
								IF trim(RCreg("ref_no1"))<>empty then
									sql=sql&"ref_no1,"
									sqlValue=sqlValue& "'"&trim(RCreg("ref_no1"))&"',"
								End IF
								'IF trim(request("tfzb_seq"))<>empty then
								'	sql=sql&"Mseq,"
								'	sqlValue=sqlValue& "'"&trim(request("tfzb_seq"))&"',"
								'End IF
								'IF trim(request("tfzb_seq1"))<>empty then
								'	sql=sql&"Mseq1,"
								'	sqlValue=sqlValue& "'_',"
								'End IF
								IF trim(RCreg("tcn_ref"))<>empty then
									sql=sql&"tcn_ref,"
									sqlValue=sqlValue& "'"&trim(RCreg("tcn_ref"))&"',"
								End IF
								IF trim(RCreg("tcn_class"))<>empty then
									sql=sql&"tcn_class,"
									sqlValue=sqlValue& "'"&trim(RCreg("tcn_class"))&"',"
								End IF
								IF trim(RCreg("tcn_name"))<>empty then
									sql=sql&"tcn_name,"
									sqlValue=sqlValue& "'"&trim(RCreg("tcn_name"))&"',"
								End IF
								IF trim(RCreg("tcn_mark"))<>empty then
									sql=sql&"tcn_mark,"
									sqlValue=sqlValue& "'"&trim(RCreg("tcn_mark"))&"',"
								End IF
								IF trim(RCreg("apply_date"))<>empty then
									sql=sql&"apply_date,"
									sqlValue=sqlValue& "'"&trim(RCreg("apply_date"))&"',"
								End IF
								IF trim(RCreg("apply_no"))<>empty then
									sql=sql&"apply_no,"
									sqlValue=sqlValue& "'"&trim(RCreg("apply_no"))&"',"
								End IF
								IF trim(RCreg("issue_date"))<>empty then
									sql=sql&"issue_date,"
									sqlValue=sqlValue& "'"&trim(RCreg("issue_date"))&"',"
								End IF
								IF trim(RCreg("issue_no"))<>empty then
									sql=sql&"issue_no,"
									sqlValue=sqlValue& "'"&trim(RCreg("issue_no"))&"',"
								End IF
								IF trim(RCreg("open_date"))<>empty then
									sql=sql&"open_date,"
									sqlValue=sqlValue& "'"&trim(RCreg("open_date"))&"',"
								End IF
								IF trim(RCreg("rej_no"))<>empty then
									sql=sql&"rej_no,"
									sqlValue=sqlValue& "'"&trim(RCreg("rej_no"))&"',"
								End IF
								IF trim(RCreg("end_date"))<>empty then
									sql=sql&"end_date,"
									sqlValue=sqlValue& "'"&trim(RCreg("end_date"))&"',"
								End IF
								IF trim(RCreg("end_code"))<>empty then
									sql=sql&"end_code,"
									sqlValue=sqlValue& "'"&trim(RCreg("end_code"))&"',"
								End IF
								IF trim(RCreg("dmt_term1"))<>empty then
									sql=sql&"dmt_term1,"
									sqlValue=sqlValue& "'"&trim(RCreg("dmt_term1"))&"',"
								End IF
								IF trim(RCreg("dmt_term2"))<>empty then
									sql=sql&"dmt_term2,"
									sqlValue=sqlValue& "'"&trim(RCreg("dmt_term2"))&"',"
								End IF
								IF trim(RCreg("renewal"))<>empty then
									sql=sql&"renewal,"
									sqlValue=sqlValue& "'"&trim(RCreg("renewal"))&"',"
								End IF
							sql=sql & "class_type,class_count,class,"
							sqlValue = sqlvalue & " '" & trim(RCreg("class_type")) & "','" & trim(RCreg("class_count")) & "','"&trim(RCreg("class"))&"',"
							SQL=SQL & "in_scode,in_no,In_date,draw_file,tr_date,tr_scode,case_sqlno,seq1,"
							sqlvalue= sqlvalue & "'" & Request("in_scode") & "','" & request("in_no") & "','" & date() & "','" & newfilename & "','" & date() & "','" & session("se_scode") & "',"& case_sqlno &",'"&trim(request("dseq1b"&i))&"',"
							SQL7 = left(sql,len(sql)-1) & left(sqlValue,len(sqlValue)-1) & ")"
							'if session("se_scode")="m802" then
							'Response.Write "SQL7:"&SQL7&"<br><br><br><br>"
							'Response.End
							'else
							'Conn.execute(SQL7)
							IF SQL7<>empty then
							  cmd.CommandText=SQL7
							  If Trim(Request("chkTest"))<>Empty Then Response.Write "21=" & SQL7 & "<hr>"
							  cmd.Execute(SQL7)
							end if  
							'end if
							'申請人資料畫面Apcust_FC_RE_form.inc
							'*****申請人檔
							for apnum=1 to trim(request("apnum"))
								ap_cname = replace(trim(request("ap_cname" & apnum)),"'","’")
								if len(ap_cname) > 0 then
									if instr(ap_cname,"&#") > 0 then
									else
										ap_cname = replace(ap_cname,"&","＆")
									end if
								end if   
								ap_cname1 = replace(trim(request("ap_cname1_" & apnum)),"'","’")
								if len(ap_cname1) > 0 then
									if instr(ap_cname1,"&#") > 0 then
									else
										ap_cname1 = replace(ap_cname1,"&","＆")
									end if
								end if	
								ap_cname2 = replace(trim(request("ap_cname2_" & apnum)),"'","’")
								if len(ap_cname2) > 0 then
									if instr(ap_cname2,"&#") > 0 then
									else
										ap_cname2 = replace(ap_cname2,"&","＆")
									end if
								end if	
								ap_ename = replace(trim(request("ap_ename" & apnum)),"'","’")
								if len(ap_ename) > 0 then
									if instr(ap_ename,"&#") > 0 then
									else
										ap_ename = replace(ap_ename,"&","＆")
									end if
								end if	
								ap_ename1 = replace(trim(request("ap_ename1_" & apnum)),"'","’")
								if len(ap_ename1) > 0 then
									if instr(ap_ename1,"&#") > 0 then
									else
										ap_ename1 = replace(ap_ename1,"&","＆")
									end if
								end if	
								ap_ename2 = replace(trim(request("ap_ename2_" & apnum)),"'","’")
								if len(ap_ename2) > 0 then
									if instr(ap_ename2,"&#") > 0 then
									else
										ap_ename2 = replace(ap_ename2,"&","＆")
									end if
								end if	
								'2009/2/17增加申請人姓及名
								ap_fcname = replace(trim(request("ap_fcname_" & apnum)),"'","’")
								if len(ap_fcname) > 0 then
									if instr(ap_fcname,"&#") > 0 then
									else
										ap_fcname = replace(ap_fcname,"&","＆")
									end if
								end if
								ap_lcname = replace(trim(request("ap_lcname_" & apnum)),"'","’")
								if len(ap_lcname) > 0 then
									if instr(ap_lcname,"&#") > 0 then
									else
										ap_lcname = replace(ap_lcname,"&","＆")
									end if
								end if   
								ap_fename = replace(trim(request("ap_fename_" & apnum)),"'","’")
								if len(ap_fename) > 0 then
									if instr(ap_fename,"&#") > 0 then
									else
										ap_fename = replace(ap_fename,"&","＆")
									end if
								end if
								ap_lename = replace(trim(request("ap_lename_" & apnum)),"'","’")
								if len(ap_lename) > 0 then
									if instr(ap_lename,"&#") > 0 then
									else
										ap_lename = replace(ap_lename,"&","＆")
									end if
								end if
								SQL7 = "insert into dmt_temp_ap (in_no,case_sqlno,apsqlno,Server_flag,apcust_no,ap_cname,ap_cname1,ap_cname2 "
								SQL7 = SQL7 & ",ap_ename,ap_ename1,ap_ename2,tran_date,tran_scode,ap_fcname,ap_lcname,ap_fename,ap_lename"
								SQL7 = SQL7 & ",ap_sql,ap_zip,ap_addr1,ap_addr2,ap_eaddr1,ap_eaddr2,ap_eaddr3,ap_eaddr4"
								SQL7 = SQL7 & " ) values ("
								SQL7 = SQL7 & "'"& request("in_no") &"'," & case_sqlno & ",'"& trim(request("apsqlno"& apnum)) &"','"& trim(request("ap_server_flag" & apnum)) &"'"
								SQL7 = SQL7 & ",'"& trim(request("apcust_no"& apnum)) &"','"& trim(ap_cname) &"','"&trim(ap_cname1)&"'"
								SQL7 = SQL7 & ",'"& trim(ap_cname2) &"','"& trim(ap_ename) &"','"&trim(ap_ename1)&"','"& trim(ap_ename2) &"'"
								SQL7 = SQL7 & ",getdate(),'"& session("se_scode") &"','" & ap_fcname & "','" & ap_lcname & "','" & ap_fename & "','" & ap_lename & "'"
								SQL7 = SQL7 & "," & chkzero(request("ap_sql"&apnum),2) & ",'" & trim(request("ap_zip"&apnum)) & "','" & trim(request("ap_addr1_"&apnum)) & "','" & trim(request("ap_addr2_"&apnum)) & "'"
								SQL7 = SQL7 & ",'" & trim(request("ap_eaddr1_"&apnum)) & "','" & trim(request("ap_eaddr2_"&apnum)) & "','" & trim(request("ap_eaddr3_"&apnum)) & "','" & trim(request("ap_eaddr4_"&apnum)) & "')" 
								'Response.Write "apnum="&SQL7&"<br>"
								'Response.End
								'if session("se_scode")="m802" then
								'	Response.Write "SQL7:"&SQL7&"<br><br><br><br>"
									'Response.End
								'else
									IF SQL7<>empty then
										cmd.CommandText=SQL7
										If Trim(Request("chkTest"))<>Empty Then Response.Write "22=" & SQL7 & "<hr>"
										cmd.Execute(SQL7)
									End IF
								'end if	
								'Response.Write "apnum="&SQL7&"<br>"
							next
				End IF
				RCreg.Close
				
				'商品類別	
				SQLno="SELECT *  FROM casedmt_good_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and num='"&i&"' and mark='T'"
				RCreg.open sqlno,conn,1,1
				IF not RCreg.EOF then
					For x=1 to RCreg.RecordCount
						if trim(RCreg("class"))<>empty or trim(RCreg("dmt_goodname"))<>empty then '2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
							SQL6 = "INSERT INTO casedmt_good(in_scode,in_no,case_sqlno,class,dmt_grp_code,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
							SQL6=SQL6&"('" & request("in_scode") & "','" & request("in_no") & "',"&case_sqlno&",'"&trim(RCreg("class"))&"','"&trim(RCreg("dmt_grp_code"))&"'"
							SQL6=SQL6&",'"&trim(RCreg("dmt_goodname"))&"','"&trim(RCreg("dmt_goodcount"))&"',"
							SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
						ELSE
							SQL6=""
						end if
						'Response.Write "SQL6_casedmt_good="&SQL6&"<br><br><br>"
						'if session("se_scode")="m802" then
						'	Response.Write "SQL6:"&SQL6&"<br><br><br><br>"
							'Response.End
						'else
							IF SQL6<>EMPTY THEN
								'Conn.Execute(SQL6)
								cmd.CommandText=SQL6
								If Trim(Request("chkTest"))<>Empty Then Response.Write "23=" & SQL6 & "<hr>"
								cmd.Execute(SQL6)
							END IF
						'end if	
						RCreg.MoveNext
					Next
				End IF
				RCreg.Close
				'展覽會優先權	
				SQLno="SELECT *  FROM casedmt_show_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and num='"&i&"' and mark='T'"
				SQLno=SQLno & " order by show_no "
				RCreg.open sqlno,conn,1,1
				IF not RCreg.EOF then
					For x=1 to RCreg.RecordCount
						if trim(RCreg("show_date"))<>empty or trim(RCreg("show_name"))<>empty then
							SQL6 = "INSERT INTO casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) values"
							SQL6=SQL6&"('" & request("in_no") & "',"&case_sqlno&",'"&trim(RCreg("show_date"))&"','"&trim(RCreg("show_name"))&"'"
							SQL6=SQL6&",getdate(),'" & session("se_scode") & "')"
						ELSE
							SQL6=""
						end if
						Response.Write "SQL6_casedmt_show="&SQL6&"<br><br><br>"
						'if session("se_scode")="m802" then
						'	Response.Write "SQL6:"&SQL6&"<br><br><br><br>"
							'Response.End
						'else
							IF SQL6<>EMPTY THEN
								'Conn.Execute(SQL6)
								cmd.CommandText=SQL6
								If Trim(Request("chkTest"))<>Empty Then Response.Write "24=" & SQL6 & "<hr>"
								cmd.Execute(SQL6)
							END IF
						'end if	
						RCreg.MoveNext
					Next
				End IF
				RCreg.Close
			End IF
		next
		'if session("se_scode")="m802" then
		'	Response.End
		'end if
		SQL="delete from dmt_temp_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark='T'"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "25=" & SQL & "<hr>"
		Conn.execute(SQL)
		SQL="delete from casedmt_good_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark='T'"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "26=" & SQL & "<hr>"
		Conn.execute(SQL)
		SQL="delete from casedmt_show_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark='T'"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "27=" & SQL & "<hr>"
		Conn.execute(SQL)
	End IF
End IF		

//更新營洽官收確認紀錄檔(grconf_dmt.job_no)
upd_grconf_job_no(conn);

	'當程序有修改復案或結案註記時通知營洽人員
	if ucase(prgid)="BRT51" then
	    nback_flag=request("tfy_back_flag")
		if request("tfy_back_flag")=empty then nback_flag="N"
		nend_flag=request("tfy_end_flag")
		if request("tfy_end_flag")=empty then nend_flag="N"
	   	'Response.Write "b1:"&request("oback_flag") & ",b2:"&nback_flag&",e1:"&request("oend_flag") & ",e2:"&nend_flag
	   	'Response.End
	   if trim(nback_flag)<>trim(request("oback_flag")) or trim(nend_flag)<> trim(request("oend_flag")) then
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