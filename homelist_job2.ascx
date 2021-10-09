<%@ Control Language="C#" ClassName="homelist_job2" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>

<script runat="server">
    public Dictionary<string, string> rights = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> rightsE = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    int rights_acc12=0;
    string SQL ="",endtr_yy = "", endtr_mm = "";
    private void Page_Load(Object sender, EventArgs e) {
        //2020/5/22抓取特殊權限
        SQL = "Select rights from loginAP where syscode='" + Session["Syscode"] + "' and loginGrp='" + Session["LoginGrp"] + "' and beg_date<=GETDATE() and end_date>=GETDATE() AND (APcode='acc12') ";
        using (DBHelper connsys = new DBHelper(Conn.ODBCDSN).Debug(false)) {
            rights_acc12 = Convert.ToInt32(connsys.getZero(SQL));
        }
        //抓取最後結算年月
        SQL = "select top 1 tr_yy,tr_mm from account.dbo.vfeesall where dept='" + Session["dept"] + "' order by tr_yy desc,tr_mm desc";
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            using (SqlDataReader sdr = conn.ExecuteReader(SQL)) {
                if (sdr.Read()) {
                    endtr_yy = sdr.SafeRead("tr_yy", "");
                    endtr_mm = sdr.SafeRead("tr_mm", "");
                }
            }
        }
    }
</script>

<!--工作清單:主管(title2) -->
<TABLE cellpadding="0" cellspacing="0" align=center width="100%">
<TBODY>
	<TR>
		<TD><IMG height=15 src="images/table/L_upb.gif" width=15 border=0></TD>
		<TD background="images/table/upb.gif" width="100%" height="15" border="0"></TD>
		<TD><IMG height=15 src="images/table/R_upb.gif" width=15 border=0></TD>
	</TR>
    <TR>
		<TD background="images/table/leftb.gif" height="15" border="0"></TD>
		<TD>
			<TABLE WIDTH="95%" align=center>
				<TR>
					<TD width="64%" colspan=2><P align=center><IMG src="images/flow/title2.gif"></P></TD>
					<TD width="18%" align=center><IMG src="images/flow/head03.gif"></TD>
					<TD width="18%" align=center class=data3h><IMG src="images/flow/head04.gif"></TD>
			   	</TR>
                <TR bgcolor=lightblue>
			   	    <TD width="18%" align=center class=data11>(已交辦)</TD>
			   	   	<TD align=center class=data1>主管尚未簽准案件：</TD>
			   		<TD align=center class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("2")%>" title="個人案件"
						attr-sql="select count(*) as num from todo_dmt t,case_dmt a
		                where t.job_status='NN' and t.syscode='<%=Session["syscode"]%>' and t.apcode='Si04W02' and t.job_scode='<%=Session["scode"]%>'
		                and a.in_scode=t.case_in_scode and a.in_no=t.in_no and  (stat_code='YN' or stat_code='YT') and (a.mark='N' or a.mark is null)"
						attr-href="brt3m/brt31_list.aspx?job_scode=<%=Session["scode"]%>&qs_dept=t&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("2")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_dmt where (stat_code='YN' or stat_code='YT') and (mark='N' or mark is null)"
						attr-href="brt4m/brt13_list.aspx?tfx_stat_code=YN&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--主管-->
					</TD>
			   		<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("2")%>" title="個人案件"
						attr-sql="select count(*) as num from todo_ext t,case_ext a 
		                where t.job_status='NN' and t.syscode='<%=Session["syscode"]%>' and t.apcode='Si04W06' and t.job_scode='<%=Session["scode"]%>'
		                and a.in_scode=t.case_in_scode and a.in_no=t.in_no and  (stat_code='YN' or stat_code='YT') and (a.mark='N' or a.mark is null)"
						attr-href="brt3m/brt31_list.aspx?homelist=homelist&job_scode=<%=Session["scode"]%>&qs_dept=e"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("2")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where cust_area='<%=Session["seBranch"]%>' and (stat_code='YN' or stat_code='YT') and (mark='N' or mark is null)"
						attr-href="brt4m/ext13_list.aspx?tfx_stat_code=YN&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   	</TR>
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11></TD>
		            <TD align=center class=data1>國內案官發/出口案發文未簽核：</TD>
		            <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) num from todo_dmt  where syscode='<%=Session["syscode"]%>' and apcode='brt63' and dowhat='DB_GS' and job_status='NN' and job_scode='<%=Session["scode"]%>'"
			            attr-href="brt3m/Ext36_list.aspx?job_status=NN&job_scode=<%=Session["scode"]%>&homelist=homelist&qs_dept=t"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rights.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) num from todo_dmt  where syscode='<%=Session["syscode"]%>' and apcode='brt63' and dowhat='DB_GS' and job_status='NN'"
			            attr-href="brt4m/ext13_listA.aspx?prgid=brt36&type=brt36&homelist=homelist&qs_dept=t"
			            ></span><!--主管-->
		            </TD>
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) num from todo_ext  where syscode='<%=Session["syscode"]%>' and apcode='Ext61' and job_status='NN' and job_scode='<%=Session["scode"]%>' and dowhat='DB_TS'"
			            attr-href="brt3m/Ext36_list.aspx?job_status=NN&job_scode=<%=Session["scode"]%>&homelist=homelist&qs_dept=e"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) num from attcase_ext where sign_stat='SN' or sign_stat='ST'"
			            attr-href="brt4m/ext13_listA.aspx?type=ext36&homelist=homelist&qs_dept=e"
			            ></span><!--主管-->
		            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11></TD>
		            <TD align=center class=data1>請款問題主管簽核：</TD>
		            <TD align=center class=data2>ｘ</TD><!--國內案-->
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) num from todo_ext where syscode='<%=Session["syscode"]%>' and (apcode='ext14' or apcode='ext161') and (dowhat='dw1' or dowhat='dw2' or dowhat='dw3') and job_status='NN' and job_scode='<%=Session["scode"]%>'"
			            attr-href="brt3m/ext3a_list.aspx?prgid=ext3a&job_status=NN&job_scode=<%=Session["scode"]%>&homelist=homelist&qs_dept=e"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) num from exch_question a,todo_ext b where a.que_sqlno=b.que_sqlno and b.syscode='<%=Session["syscode"]%>' and (apcode='ext14' or apcode='ext161') and b.dowhat in ('dw1','dw2','dw3') and b.job_status='NN'"
			            attr-href="brt3m/ext3a_list.aspx?prgid=ext3a&job_status=NN&homelist=homelist&submittask=Q"
			            ></span><!--主管-->
		            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11></TD>
		            <TD align=center class=data1>請款問題結果確認：</TD>
		            <TD align=center class=data2>ｘ</TD><!--國內案-->
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) num from todo_ext  where syscode='<%=Session["syscode"]%>' and apcode='ext161' and dowhat='qdw1' and job_status='NN' and job_scode='<%=Session["scode"]%>'"
			            attr-href="brt3m/ext3b_list.aspx?prgid=ext3b&job_status=NN&job_scode=<%=Session["scode"]%>&homelist=homelist&qs_dept=e"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) num from exch_question a,todo_ext b where a.que_sqlno=b.que_sqlno and b.syscode='<%=Session["syscode"]%>' and apcode='ext161' and b.dowhat in ('qdw1') and b.job_status='NN'"
			            attr-href="brt3m/ext3b_list.aspx?prgid=ext3b&job_status=NN&homelist=homelist&submittask=Q"
			            ></span><!--主管-->
		            </TD>
	            </TR> 
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11></TD>
		            <TD align=center class=data1>客戶函寄發未簽核：</TD>
		            <TD align=center class=data2>ｘ</TD><!--國內案-->
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) num from todo_ext  where syscode='<%=Session["syscode"]%>' and (apcode='Ext14' or apcode='ext66') and job_status='NN' and job_scode='<%=Session["scode"]%>' and dowhat='cs_dw'"
			            attr-href="brt3m/ext3c_list.aspx?job_status=NN&job_scode=<%=Session["scode"]%>&homelist=homelist&prgid=ext3c"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) num from todo_ext  where syscode='<%=Session["syscode"]%>' and (apcode='Ext14' or apcode='ext66') and job_status='NN' and dowhat='cs_dw'"
			            attr-href="brt3m/ext3c_list.aspx?job_status=NN&homelist=homelist&prgid=ext3c&submittask=Q"
			            ></span><!--主管-->
		            </TD>
	            </TR>  	
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11></TD>
		            <TD align=center class=data1>規費不足管制未簽核：</TD>
		            <TD align=center class=data2>ｘ</TD><!--國內案-->
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) num from todo_ext  where syscode='<%=Session["syscode"]%>' and (apcode='Ext14' ) and job_status='NN' and job_scode='<%=Session["scode"]%>' and dowhat='fc_dw'"
			            attr-href="brt3m/ext3d_list.aspx?job_status=NN&job_scode=<%=Session["scode"]%>&homelist=homelist&prgid=ext3d"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) num from todo_ext where syscode='<%=Session["syscode"]%>' and (apcode='Ext14') and job_status='NN' and dowhat='fc_dw'"
			            attr-href="brt3m/ext3d_list.aspx?job_status=NN&homelist=homelist&prgid=ext3d&submittask=Q"
			            ></span><!--主管-->
		            </TD>
	            </TR>
			   	<TR bgcolor=lightblue>
			   	    <TD align=center class=data11></TD>
			   		<TD align=center class=data1>更正註銷尚未簽核：&nbsp;&nbsp;&nbsp;</TD>
			   		<TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) as num from casetran_brt a inner join sysctrl.dbo.todolist s on a.sqlno=s.att_no
		                and (s.apcode='brt81' or s.apcode='brt82') and s.dowhat='DT' and s.job_status='NN' and s.job_scode='<%=Session["scode"]%>'
		                where a.country='T'"
			            attr-href="brt3m/Ext38_list.aspx?qs_dept=t&job_status=NN&job_scode=<%=Session["scode"]%>
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rights.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) num from casetran_brt where country='T' and (tran_status like '%N' or tran_status like '%T')"
			            attr-href="Brt8m/Brt83_list.aspx?homelist=homelist&qs_dept=t&tran_status=N"
			            ></span><!--主管-->
					</TD>
			   		<TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) as num from casetran_brt a inner join sysctrl.dbo.todolist s on a.sqlno=s.att_no
		                and (s.apcode='ext81' or s.apcode='ext82') and s.dowhat='DT' and s.job_status='NN' and s.job_scode='<%=Session["scode"]%>'
		                where a.country<>'T' "
			            attr-href="brt3m/Ext38_list.aspx?qs_dept=e&job_status=NN&job_scode=<%=Session["scode"]%>"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) num from casetran_brt where country<>'T' and (tran_status like '%N' or tran_status like '%T')"
			            attr-href="brt8m/Brt83_list.aspx?homelist=homelist&qs_dept=e&tran_status=N"
			            ></span><!--主管-->
			   		</TD>
			   	</TR>
			   <TR bgcolor=lightblue>
			   	    <TD align=center class=data11></TD>
			   		<TD align=center class=data1>更正註銷尚未簽核(<font color=blue>智產</font>)：&nbsp;&nbsp;&nbsp;</TD>
			   		<TD align=center class=data2>ｘ	</TD><!--國內案-->
			   		<TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(distinct a.tran_no) as num from casetran_invext a inner join sysctrl.dbo.todolist s on a.tran_no=s.att_no
		                and (s.apcode='extd9' or s.apcode='extda') and s.dowhat='DI' and s.job_status='NN' and s.job_scode='<%=Session["scode"]%>'
		                where a.country<>'T' "
			            attr-href="brt3m/Ext3e_list.aspx?qs_dept=e&job_status=NN&job_scode=<%=Session["scode"]%>&qryar_mark=A"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(distinct tran_no) num from casetran_invext where country<>'T' and (tran_status like '%N' or tran_status like '%T') and invoice_chk='A'"
			            attr-href="brt3m/Ext3e_list.aspx?homelist=homelist&qs_dept=e&job_status=NN&qryar_mark=A"
			            ></span><!--主管-->
			   		</TD>
			   	</TR>
			   <TR bgcolor=lightblue>
			   	    <TD align=center class=data11></TD>
			   		<TD align=center class=data1>更正註銷尚未簽核(<font color=blue>代收代付</font>)：&nbsp;&nbsp;&nbsp;</TD>
			   		<TD align=center class=data2>ｘ	</TD><!--國內案-->
			   		<TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(distinct a.tran_no) as num from casetran_invext a inner join sysctrl.dbo.todolist s on a.tran_no=s.att_no
		                and (s.apcode='extd9' or s.apcode='extda') and s.dowhat='DE' and s.job_status='NN' and s.job_scode='<%=Session["scode"]%>'
		                where a.country<>'T' "
			            attr-href="brt3m/Ext3e_list.aspx?qs_dept=e&job_status=NN&job_scode=<%=Session["scode"]%>&qryar_mark=E"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(distinct tran_no) num from casetran_invext where country<>'T' and (tran_status like '%N' or tran_status like '%T') and invoice_chk='D'"
			            attr-href="brt3m/Ext3e_list.aspx?homelist=homelist&qs_dept=e&job_status=NN&qryar_mark=E"
			            ></span><!--主管-->
			   		</TD>
			   	</TR>
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11></TD>
		            <TD align=center class=data1>結案案件尚未簽核：</TD>
		            <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) num from todo_dmt where syscode='<%=Session["syscode"]%>' and job_status='NN' and job_scode='<%=Session["scode"]%>' and dowhat='DB_END'"
			            attr-href="brt3m/brt3f_list.aspx?job_status=NN&job_scode=<%=Session["scode"]%>&homelist=homelist&prgid=brt3f"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rights.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) num from todo_dmt where syscode='<%=Session["syscode"]%>' and job_status='NN' and dowhat='DB_END'"
			            attr-href="brt3m/brt3f_list.aspx?job_status=NN&homelist=homelist&prgid=brt3f&submittask=Q"
			            ></span><!--主管-->
		            </TD>
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) num from todo_ext where syscode='<%=Session["syscode"]%>' and job_status='NN' and job_scode='<%=Session["scode"]%>' and dowhat='DB_END' "
			            attr-href="brt3m/ext3f_list.aspx?job_status=NN&job_scode=<%=Session["scode"]%>&homelist=homelist&prgid=ext3f"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) num from todo_ext where syscode='<%=Session["syscode"]%>' and job_status='NN' and dowhat='DB_END'"
			            attr-href="brt3m/ext3f_list.aspx?job_status=NN&homelist=homelist&prgid=ext3f&submittask=Q"
			            ></span><!--主管-->
		            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11></TD>
		            <TD align=center class=data1>轉案案件尚未簽核：</TD>
		            <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) num from todo_dmt where syscode='<%=Session["syscode"]%>' and job_status='NN' and job_scode='<%=Session["scode"]%>' and dowhat='TRAN_NM'"
			            attr-href="brt3m/brt3g_list.aspx?job_status=NN&job_scode=<%=Session["scode"]%>&homelist=homelist&prgid=brt3g&qs_dept=t"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rights.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) num from todo_dmt where syscode='<%=Session["syscode"]%>' and job_status='NN' and dowhat='TRAN_NM'"
			            attr-href="brt3m/brt3g_list.aspx?job_status=NN&homelist=homelist&prgid=brt3g&submittask=Q&qs_dept=t"
			            ></span><!--主管-->
		            </TD>
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) num from todo_ext where syscode='<%=Session["syscode"]%>' and job_status='NN' and job_scode='<%=Session["scode"]%>' and dowhat='TRAN_NM' "
			            attr-href="brt3m/brt3g_list.aspx?job_status=NN&job_scode=<%=Session["scode"]%>&homelist=homelist&prgid=ext3g&qs_dept=e"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) num from todo_ext where syscode='<%=Session["syscode"]%>' and job_status='NN' and dowhat='TRAN_NM'"
			            attr-href="brt3m/brt3g_list.aspx?job_status=NN&homelist=homelist&prgid=ext3g&submittask=Q&qs_dept=e"
			            ></span><!--主管-->
		            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11></TD>
		            <TD align=center class=data1>確認轉案尚未處理：</TD>
		            <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) num from todo_dmt where syscode='<%=Session["syscode"]%>' and job_status='NN' and job_scode='<%=Session["scode"]%>' and dowhat='TRAN_EM' and apcode='brta76'"
			            attr-href="brt3m/brt3h_list.aspx?job_status=NN&job_scode=<%=Session["scode"]%>&homelist=homelist&prgid=brt3h&qs_dept=t"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rights.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) num from todo_dmt where syscode='<%=Session["syscode"]%>' and job_status='NN' and dowhat='TRAN_EM' and apcode='brta76' "
			            attr-href="brt3m/brt3h_list.aspx?job_status=NN&homelist=homelist&prgid=brt3h&qs_dept=t"
			            ></span><!--主管-->
		            </TD>
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) num from todo_ext where syscode='<%=Session["syscode"]%>' and job_status='NN' and job_scode='<%=Session["scode"]%>' and dowhat='TRAN_EM' and apcode='exta76' "
			            attr-href="brt3m/brt3h_list.aspx?job_status=NN&job_scode=<%=Session["scode"]%>&homelist=homelist&prgid=ext3h&qs_dept=e"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) num from todo_ext where syscode='<%=Session["syscode"]%>' and job_status='NN' and dowhat='TRAN_EM' and apcode='exta76'"
			            attr-href="brt3m/brt3h_list.aspx?job_status=NN&homelist=homelist&prgid=ext3h&qs_dept=e"
			            ></span><!--主管-->
		            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11></TD>
		            <TD align=center class=data1>確認轉案尚未簽核：</TD>
		            <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) num from todo_dmt where syscode='<%=Session["syscode"]%>' and job_status='NN' and job_scode='<%=Session["scode"]%>' and dowhat='TRAN_EM' and apcode='brt3h'"
			            attr-href="brt3m/brt3h1_list.aspx?job_status=NN&job_scode=<%=Session["scode"]%>&homelist=homelist&prgid=brt3h1&qs_dept=t"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rights.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) num from todo_dmt where syscode='<%=Session["syscode"]%>' and job_status='NN' and dowhat='TRAN_EM' and apcode='brt3h' "
			            attr-href="brt3m/brt3h1_list.aspx?job_status=NN&homelist=homelist&prgid=brt3h1&submittask=Q&qs_dept=t"
			            ></span><!--主管-->
		            </TD>
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) num from todo_ext where syscode='<%=Session["syscode"]%>' and job_status='NN' and job_scode='<%=Session["scode"]%>' and dowhat='TRAN_EM' and apcode='ext3h' "
			            attr-href="brt3m/brt3h1_list.aspx?job_status=NN&job_scode=<%=Session["scode"]%>&homelist=homelist&prgid=ext3h1&qs_dept=e"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) num from todo_ext where syscode='<%=Session["syscode"]%>' and job_status='NN' and dowhat='TRAN_EM' and apcode='ext3h'"
			            attr-href="brt3m/brt3h1_list.aspx?job_status=NN&homelist=homelist&prgid=ext3h1&submittask=Q&qs_dept=e"
			            ></span><!--主管-->
		            </TD>
	            </TR> 
	            <%if( (rights_acc12 & 4) != 0 ){%>
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11></TD>
		            <TD align=center class=data1>不催帳尚未簽核：</TD>
		            <TD align=center class=data2 colspan=2><!--R特殊條件-->
			            <span class="loadnumR" attr-right="<%=(rights_acc12 & 64)%>"
			            attr-sql="select count(*) as num from account.dbo.cust_step s where dept='<%=Session["dept"]%>' and (s.step_class='db_no' ) and s.step_stat='NN' "
			            attr-href="acc1m/acc12_list.aspx?prgid=acc12&homelist=homelist"
			            attr-hrefA="acc1m/acc11_list1.aspx?prgid=acc14&qrytodo=Q&qrydept=<%=Session["dept"]%>&qrystep_stat=NN&homelist=homelist"
			            ></span><!--attr-href:權限(rights_acc12 & 64==0)的link,attr-hrefA:權限(rights_acc12 & 64!=0)的link-->
		            </TD>
	            </TR> 
	            <%}%>
   	            <TR bgcolor=lightblue>
                    <TD align=center class=data11></TD>
                    <TD align=center class=data1>規費不足扣收入尚未處理：</TD>
		            <TD align=center class=data2>ｘ	</TD><!--國內案-->
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) as num From account.dbo.tefee f inner join ext d on f.seq=d.seq and f.seq1=d.seq1 where substring(f.do_status,1,1)='N' and fees1+fees2-fees3-fees4<0 and d.scode='<%=Session["scode"]%>' "
			            attr-href="acc2m/acc21_list.aspx?prgid=acc21&qrydept=<%=Session["dept"]%>&qryar_type=e&todo_flag=D&qry_yy=<%=endtr_yy%>&qry_mm=<%=endtr_mm%>&qryscode1=<%=Session["scode"]%>&homelist=homelist"
			            ></span><!--個人-->
			            <span class="loadnumAX" attr-right="<%=rightsE.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) as num From account.dbo.tefee f where substring(f.do_status,1,1)='N' and fees1+fees2-fees3-fees4<0"
			            attr-href="acc2m/acc21_list.aspx?prgid=acc21&submitTask=Q&qrydept=<%=Session["dept"]%>&qryar_type=e&todo_flag=D&qry_yy=<%=endtr_yy%>&qry_mm=<%=endtr_mm%>&homelist=homelist"
			            ></span><!--主管,不顯示-->
		            </TD>
	            </TR>	
   	            <TR bgcolor=lightblue>
                    <TD align=center class=data11></TD>
                    <TD align=center class=data1>規費餘額轉收入尚未處理：</TD>
		            <TD align=center class=data2>ｘ	</TD><!--國內案-->
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) as num From account.dbo.tefee f inner join ext d on f.seq=d.seq and f.seq1=d.seq1 where substring(f.do_status,1,1)='N' and fees1+fees2-fees3-fees4>0 and d.scode='<%=Session["scode"]%>' "
			            attr-href="acc2m/acc21_list.aspx?prgid=acc22&qrydept=<%=Session["dept"]%>&qryar_type=e&todo_flag=E&qry_yy=<%=endtr_yy%>&qry_mm=<%=endtr_mm%>&qryscode1=<%=Session["scode"]%>&homelist=homelist"
			            ></span><!--個人-->
			            <span class="loadnumAX" attr-right="<%=rightsE.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) as num From account.dbo.tefee f where substring(f.do_status,1,1)='N' and fees1+fees2-fees3-fees4>0"
			            attr-href="acc2m/acc21_list.aspx?prgid=acc21&submitTask=Q&qrydept=<%=Session["dept"]%>&qryar_type=e&todo_flag=E&qry_yy=<%=endtr_yy%>&qry_mm=<%=endtr_mm%>&homelist=homelist"
			            ></span><!--主管,不顯示-->
		            </TD>
	            </TR>
                <TR bgcolor=lightblue>
	                <TD align=center class=data11></TD>
		            <TD align=center class=data1>規費不足扣收入/暫緩扣收入尚未簽核：</TD>
		            <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) as num From todo_dmt where from_flag='accfee' and dowhat='FEE_MD' and job_status='NN' and job_scode='<%=Session["scode"]%>'"
			            attr-href="acc2m/acc23_list.aspx?prgid=acc23&apdept=T&qrydept=<%=Session["dept"]%>&qryar_type=t&todo_flag=D&qryjob_scode=<%=Session["scode"]%>&homelist=homelist"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rights.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) as num From todo_dmt where from_flag='accfee' and dowhat='FEE_MD' and job_status='NN' "
			            attr-href="acc2m/acc23_list.aspx?prgid=acc23&apdept=T&submitTask=Q&qrydept=<%=Session["dept"]%>&qryar_type=t&todo_flag=D&homelist=homelist"
			            ></span><!--主管-->
		            </TD>
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) as num From todo_ext where from_flag='accfee' and dowhat='FEE_MD' and job_status='NN' and job_scode='<%=Session["scode"]%>'"
			            attr-href="acc2m/acc23_list.aspx?prgid=acc23&apdept=T&qrydept=<%=Session["dept"]%>&qryar_type=e&todo_flag=D&qryjob_scode=<%=Session["scode"]%>&homelist=homelist"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) as num From todo_ext where from_flag='accfee' and dowhat='FEE_MD' and job_status='NN'"
			            attr-href="acc2m/acc23_list.aspx?prgid=acc23&apdept=T&submitTask=Q&qrydept=<%=Session["dept"]%>&qryar_type=e&todo_flag=D&homelist=homelist"
			            ></span><!--主管-->
		            </TD>
	            </TR> 
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11></TD>
		            <TD align=center class=data1>規費餘額轉收入尚未簽核：</TD>
		            <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) as num From todo_dmt where from_flag='accfee' and dowhat='FEE_ME' and job_status='NN' and job_scode='<%=Session["scode"]%>'"
			            attr-href="acc2m/acc23_list.aspx?prgid=acc23&apdept=T&qrydept=<%=Session["dept"]%>&qryar_type=t&todo_flag=E&qryjob_scode=<%=Session["scode"]%>&homelist=homelist"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rights.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) as num From todo_dmt where from_flag='accfee' and dowhat='FEE_ME' and job_status='NN' "
			            attr-href="acc2m/acc23_list.aspx?prgid=acc23&apdept=T&submitTask=Q&qrydept=<%=Session["dept"]%>&qryar_type=t&todo_flag=E&homelist=homelist"
			            ></span><!--主管-->
		            </TD>
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) as num From todo_ext where from_flag='accfee' and dowhat='FEE_ME' and job_status='NN' and job_scode='<%=Session["scode"]%>'"
			            attr-href="acc2m/acc23_list.aspx?prgid=acc23&apdept=T&qrydept=<%=Session["dept"]%>&qryar_type=e&todo_flag=E&qryjob_scode=<%=Session["scode"]%>&homelist=homelist"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) as num From todo_ext where from_flag='accfee' and dowhat='FEE_ME' and job_status='NN'"
			            attr-href="acc2m/acc23_list.aspx?prgid=acc23&apdept=T&submitTask=Q&qrydept=<%=Session["dept"]%>&qryar_type=e&todo_flag=E&homelist=homelist"
			            ></span><!--主管-->
		            </TD>
	            </TR> 
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11></TD>
		            <TD align=center class=data1>請款單預定回收日修改尚未簽核：</TD>
		            <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) as num from account.dbo.todo_acc s where syscode='<%=Session["syscode"]%>'
			            and (s.apcode ='acc2at' or s.apcode='acc2b') and (s.dowhat='chgpre_m' ) and s.job_status='NN' and s.ar_type='T' and s.job_scode='<%=Session["scode"]%>'"
			            attr-href="acc2m/acc2b_list.aspx?prgid=acc2b&apdept=T&qrydept=T&qryar_type=T&qryjob_scode=<%=Session["scode"]%>&homelist=homelist"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rights.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) as num from account.dbo.todo_acc s where syscode='<%=Session["syscode"]%>'
			            and (s.apcode ='acc2at' or s.apcode='acc2b') and (s.dowhat='chgpre_m' ) and s.job_status='NN' and s.ar_type='T'"
			            attr-href="acc2m/acc2b_list.aspx?prgid=acc2b&apdept=T&qrydept=T&qryar_type=T&homelist=homelist&submittask=Q"
			            ></span><!--主管-->
		            </TD>
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(*) as num from account.dbo.todo_acc s where syscode='<%=Session["syscode"]%>'
			            and (s.apcode ='acc2at' or s.apcode='acc2b') and (s.dowhat='chgpre_m' ) and s.job_status='NN' and s.ar_type='E' and s.job_scode='<%=Session["scode"]%>'"
			            attr-href="acc2m/acc2b_list.aspx?prgid=acc2b&apdept=T&qrydept=T&qryar_type=E&qryjob_scode=<%=Session["scode"]%>&homelist=homelist"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(*) as num from account.dbo.todo_acc s where syscode='<%=Session["syscode"]%>'
			            and (s.apcode ='acc2at' or s.apcode='acc2b') and (s.dowhat='chgpre_m' ) and s.job_status='NN' and s.ar_type='E'"
			            attr-href="acc2m/acc2b_list.aspx?prgid=acc2b&apdept=T&qrydept=T&qryar_type=E&homelist=homelist&submittask=Q"
			            ></span><!--主管-->
		            </TD>
	            </TR> 
	            <TR bgcolor=lightblue>
		            <TD align=center class=data11></TD>
		            <TD align=center class=data1>英文Invoice尚未簽核：</TD>
		            <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(distinct a.ar_no) as num from account.dbo.artmain_e a 
		                inner join sysctrl.dbo.todolist s on a.branch=s.branch and a.ar_no=s.in_no 
		                and (s.apcode='Brt7h') and s.dowhat='DA' and s.job_status='NN' and s.job_scode='<%=Session["scode"]%>'
		                where a.ar_type='T' "
			            attr-href="brt3m/brt3j_list.aspx?prgid=brt3j&homelist=homelist&qs_dept=t&job_scode=<%=Session["scode"]%>&qryar_mark=A&ar_mark=A"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rights.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(distinct a.ar_no) as num from account.dbo.artmain_e a
		                inner join sysctrl.dbo.todolist s on a.branch=s.branch and a.ar_no=s.in_no 
		                and (s.apcode='Brt7h') and s.dowhat='DA' and s.job_status='NN' 
		                where a.ar_type='T' "
			            attr-href="brt3m/brt3j_list.aspx?prgid=brt3j&homelist=homelist&qs_dept=t&qryar_mark=A&ar_mark=A&modify=Q"
			            ></span><!--主管-->
		            </TD>
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("2")%>" title="個人案件"
			            attr-sql="select count(distinct a.ar_no) as num from account.dbo.artmain_e a 
	                    inner join sysctrl.dbo.todolist s on a.branch=s.branch and a.ar_no=s.in_no 
	                    and (s.apcode='Ext7h') and s.dowhat='DA' and s.job_status='NN' and s.job_scode='<%=Session["scode"]%>'
	                    where a.ar_type='E' "
			            attr-href="brt3m/brt3j1_list.aspx?prgid=brt3j1&homelist=homelist&qs_dept=e&job_scode=<%=Session["scode"]%>&qryar_mark=A&ar_mark=A"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(distinct a.ar_no) as num from account.dbo.artmain_e a 
			            inner join sysctrl.dbo.todolist s on a.branch=s.branch and a.ar_no=s.in_no 
			            and (s.apcode='Ext7h') and s.dowhat='DA' and s.job_status='NN' 
			            where a.ar_type='E' "
			            attr-href="brt3m/brt3j1_list.aspx?prgid=brt3j1&homelist=homelist&qs_dept=e&qryar_mark=A&ar_mark=A&modify=Q"
			            ></span><!--主管-->
			   		</TD>
			   	</TR>
			   <TR bgcolor=lightblue>
			   	    <TD align=center class=data11></TD>
			   		<TD align=center class=data1>英文Invoice尚未簽核(<font color=blue>智產</font>)：</TD>
			   		<TD align=center class=data2>ｘ	</TD><!--國內案-->
			   		<TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("2")%>" title="個人案件"
			            attr-sql= "select count(distinct a.ar_no) as num from account.dbo.artmain_e a 
		                inner join sysctrl.dbo.todolist s on a.branch=s.branch and a.ar_no=s.in_no 
		                and (s.apcode='Extdi') and s.dowhat='DA' and s.job_status='NN' and s.job_scode='<%=Session["scode"]%>'
		                where a.ar_type='E' "
			            attr-href="brt3m/ext3j_list.aspx?prgid=ext3j&homelist=homelist&qs_dept=e&job_scode=<%=Session["scode"]%>&qryar_mark=A&ar_mark=A"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("2")%>" title="全部營洽"
			            attr-sql="select count(distinct a.ar_no) as num from account.dbo.artmain_e a 
			            inner join sysctrl.dbo.todolist s on a.branch=s.branch and a.ar_no=s.in_no 
			            and (s.apcode='Extdi') and s.dowhat='DA' and s.job_status='NN' 
			            where a.ar_type='E' "
			            attr-href="brt3m/ext3j_list.aspx?prgid=ext3j&homelist=homelist&qs_dept=e&qryar_mark=A&ar_mark=A&modify=Q"
			            ></span><!--主管-->
		            </TD>
	            </TR>
			</TABLE>
		</TD>
		<TD background="images/table/rightb.gif" height="15" border="0"></TD>
	</TR>
	<TR>
		<TD><IMG height=15 src="images/table/L_downb.gif" width=15 border=0></TD>
		<TD background="images/table/downb.gif" height="15" border="0"></TD>
		<TD><IMG height=15 src="images/table/R_downb.gif" width=15 border=0></TD>
	</TR>
</TBODY>
</TABLE>