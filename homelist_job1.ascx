<%@ Control Language="C#" ClassName="homelist_job1" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    public Dictionary<string, string> rights = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> rightsE = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    string endtr_yy = "", endtr_mm = "";
    private void Page_Load(Object sender, EventArgs e) {
        //2020/5/22抓取會計結轉年月
        string SQL = "select sql from account.dbo.cust_code where code_type='Z' and cust_code='acc94' ";
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            string acc94sql = conn.getString(SQL);
            if (acc94sql != "") {
                endtr_yy = acc94sql.Left(4);
                endtr_mm = acc94sql.Right(2);
            }
        }
    }
</script>

<!--工作清單:營業(title1)-->
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
					<TD width="64%" colspan=2><P align=center><IMG src="images/flow/title1.gif"></P></TD>
					<TD width="18%" align=center><IMG src="images/flow/head03.gif"></TD>
					<TD width="18%" align=center class=data3h><IMG src="images/flow/head04.gif"></TD>
			   	</TR>
			   	<TR bgcolor=lightblue>
			   		<TD align=center width=18% class=data11>(未交辦)</TD>
			   	   	<TD align=center class=data1>營洽尚未交辦案件：</TD>
			   		<TD align=center class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_dmt where in_scode='<%=Session["scode"]%>' and stat_code='NN' and (mark='N' or mark is null)"
						attr-href="brt1m/brt12_list.aspx?stat_code=NN&tscode=<%=Session["scode"]%>&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_dmt where stat_code='NN' and (mark='N' or mark is null)"
						attr-href="brt4m/brt13_list.aspx?tfx_stat_code=NN&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   		<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_ext where in_scode='<%=Session["scode"]%>' and stat_code='NN' AND (mark='N' or mark is null)"
						attr-href="brt1m/ext12_list.aspx?stat_code=NN&tscode=<%=Session["scode"]%>&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where stat_code='NN' and (mark='N' or mark is null)"
						attr-href="brt4m/ext13_list.aspx?tfx_stat_code=NN&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   	</TR>
			   	<TR bgcolor=lightblue>
			   		<TD align=center class=data11>(未交辦)</TD>
			   		<TD align=center class=data1>交辦案件退回營洽：</TD>
			   		<TD align=center class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_dmt where in_scode='<%=Session["scode"]%>' and stat_code='NX' and (mark='N' or mark is null) and cust_area='<%=Session["seBranch"]%>'"
						attr-href="brt1m/brt12_list.aspx?tscode=<%=Session["scode"]%>&stat_code=NX&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_dmt where stat_code='NX' and (mark='N' or mark is null)"
						attr-href="brt4m/brt13_list.aspx?tfx_stat_code=NX&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   		<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_ext where in_scode='<%=Session["scode"]%>' and stat_code='NX' and (mark='N' or mark is null)"
						attr-href="brt1m/ext12_list.aspx?tscode=<%=Session["scode"]%>&stat_code=NX&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where stat_code='NX' and (mark='N' or mark is null)"
						attr-href="brt4m/ext13_list.aspx?tfx_stat_code=NX&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   	</TR>
			  	<TR bgcolor=lightblue>
			   		<TD align=center class=data11>(未確認)</TD>
			   		<TD align=center class=data10>已交辦未確認案件：<IMG src="images/flow/6.gif"></TD>
			   		<TD align=center class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_dmt where in_scode='<%=Session["scode"]%>' and stat_code like 'Y%' and stat_code<>'YZ' and (mark='N' or mark is null)"
						attr-href="brt4m/brt13_list.aspx?scode=<%=Session["scode"]%>&stat_code1=Y&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_dmt where stat_code like 'Y%' and stat_code<>'YZ' and (mark='N' or mark is null)"
						attr-href="brt4m/brt13_list.aspx?stat_code1=Y&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   		<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_ext where in_scode='<%=Session["scode"]%>' and stat_code like 'Y%' and stat_code<>'YZ' and (mark='N' or mark is null)"
						attr-href="brt4m/ext13_list.aspx?scode=<%=Session["scode"]%>&stat_code1=Y&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where stat_code like 'Y%' and stat_code<>'YZ' and (mark='N' or mark is null)"
						attr-href="brt4m/ext13_list.aspx?stat_code1=Y&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   	</TR>
			   	<TR bgcolor=lightblue>
			   		<TD align=center class=data11>(已交辦)</TD>
			   		<TD align=center class=data10>已交辦未檢核案件：<IMG src="images/flow/6.gif"></TD>
			   		<TD align=center class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_dmt where in_scode='<%=Session["scode"]%>' and cust_area='<%=Session["seBranch"]%>' and stat_code='YZ' and ar_code='N' and (mark='N' or mark is null) and (acc_chk='N' or acc_chk is null)"
						attr-href="brt4m/brt13_list.aspx?scode=<%=Session["scode"]%>&stat_code1=Z&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_dmt where stat_code='YZ' and ar_code='N' and (mark='N' or mark is null) and cust_area='<%=Session["seBranch"]%>'  and (acc_chk='N' or acc_chk is null)"
						attr-href="brt4m/brt13_list.aspx?stat_code1=Z&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   		<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_ext where in_scode='<%=Session["scode"]%>' and cust_area='<%=Session["seBranch"]%>' and (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and (mark='N' or mark is null) and (invoice_chk='B') and (acc_chk='N' or acc_chk is null)"
						attr-href="brt4m/ext13_list.aspx?scode=<%=Session["scode"]%>&stat_code1=ZB&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and (mark='N' or mark is null) and cust_area='<%=Session["seBranch"]%>' and (invoice_chk='B') and (acc_chk='N' or acc_chk is null)"
						attr-href="brt4m/ext13_list.aspx?stat_code1=ZB&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   	</TR>
			   	<TR bgcolor=lightblue>
			   		<TD align=center class=data11>(已交辦)</TD>
			   		<TD align=center class=data1>已交辦未請款案件：</TD>
			   		<TD align=center class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_dmt where in_scode='<%=Session["scode"]%>' and cust_area='<%=Session["seBranch"]%>' and stat_code='YZ' and ar_code='N' and (mark='N' or mark is null) and acc_chk='Y'"
						attr-href="brt7m/ext76_list.aspx?scode=<%=Session["scode"]%>&qs_dept=t&todo=X&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_dmt where stat_code='YZ' and ar_code='N' and (mark='N' or mark is null) and cust_area='<%=Session["seBranch"]%>' and acc_chk='Y'"
						attr-href="brt7m/ext76_list.aspx?qs_dept=t&todo=X&getdo=N&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   		<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_dmt where in_scode='<%=Session["scode"]%>' and cust_area='<%=Session["seBranch"]%>' and stat_code='YZ' and ar_code='N' and (mark='N' or mark is null) and acc_chk='Y'"
						attr-href="brt7m/ext76_list.aspx?scode=<%=Session["scode"]%>&qs_dept=e&todo=X&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and (mark='N' or mark is null) and cust_area='<%=Session["seBranch"]%>' and (invoice_chk='B' or invoice_chk='C') and acc_chk='Y'"
						attr-href="brt7m/ext76_list.aspx?qs_dept=e&todo=X&getdo=N&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   	</TR>
			   	<TR bgcolor=lightblue>
			   	    <TD align=center class=data11>(已交辦)</TD>
			   		<TD align=center class=data10>已交辦未檢核案件(<font color=blue>智產</font>)：<IMG src="images/flow/6.gif"></TD>
			   		<TD align=center class=data2>ｘ	</TD><!--國內案-->
			   		<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_ext where in_scode='<%=Session["scode"]%>' and cust_area='<%=Session["seBranch"]%>' and (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and (mark='N' or mark is null) and (invoice_chk='A') and (acc_chk='N' or acc_chk is null)"
						attr-href="brt4m/ext13_list.aspx?scode=<%=Session["scode"]%>&stat_code1=Z&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and (mark='N' or mark is null) and cust_area='<%=Session["seBranch"]%>' and (invoice_chk='A') and (acc_chk='N' or acc_chk is null) "
						attr-href="brt4m/ext13_list.aspx?stat_code1=Z&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   	</TR>
				<TR bgcolor=lightblue>
			   	    <TD align=center class=data11>(已交辦)</TD>
			   		<TD align=center class=data1>已交辦未請款案件(<font color=blue>智產</font>)：</TD>
			   		<TD align=center class=data2>ｘ	</TD><!--國內案-->
			   		<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_ext where in_scode='<%=Session["scode"]%>' and cust_area='<%=Session["seBranch"]%>' and (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and (mark='N' or mark is null) and (invoice_chk='A') and acc_chk='Y'"
						attr-href="brtdm/extd6l_ist.aspx?scode=<%=Session["scode"]%>&qs_dept=e&todo=X&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and (mark='N' or mark is null) and cust_area='<%=Session["seBranch"]%>' and (invoice_chk='A') and acc_chk='Y' "
						attr-href="brtdm/extd6_list.aspx?qs_dept=e&todo=X&getdo=N&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   	</TR>
				<TR bgcolor=lightblue>
			   	    <TD align=center class=data11>(已交辦)</TD>
			   		<TD align=center class=data1>已交辦未請款案件(<font color=blue>代收代付</font>)：</TD>
			   		<TD align=center class=data2>ｘ	</TD><!--國內案-->
			   		<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_ext where in_scode='<%=Session["scode"]%>' and cust_area='<%=Session["seBranch"]%>' and (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and (mark='N' or mark is null) and (invoice_chk='D') "
						attr-href="brtdm/extd6_list_emark.aspx?scode=<%=Session["scode"]%>&qs_dept=e&todo=X&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and (mark='N' or mark is null) and cust_area='<%=Session["seBranch"]%>' and (invoice_chk='D') "
						attr-href="brtdm/extd6_list_emark.aspx?qs_dept=e&todo=X&getdo=N&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   	</TR>
			   	<TR bgcolor=lightblue>
			   	    <TD align=right class=data11>(已發文)</TD>
			   		<TD align=center class=data1>已支出未請款案件：</TD>
			   		<TD align=center class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_dmt where in_scode='<%=Session["scode"]%>' and stat_code='YZ' and ar_code='N' and gs_fees>0 and (mark='N' or mark is null) and acc_chk='Y'"
						attr-href="brt7m/ext76_list.aspx?spkind=gs_fees&scode=<%=Session["scode"]%>&qs_dept=t&todo=X&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_dmt where stat_code='YZ' and ar_code='N' and gs_fees>0 and (mark='N' or mark is null) and acc_chk='Y'"
						attr-href="brt7m/ext76_list.aspx?spkind=gs_fees&qs_dept=t&todo=X&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   		<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_ext where in_scode='<%=Session["scode"]%>' and (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and gs_fees>0 and (mark='N' or mark is null) and (invoice_chk='B' or invoice_chk='C') and acc_chk='Y' "
						attr-href="brt7m/ext76_list.aspx?spkind=gs_fees&scode=<%=Session["scode"]%>&qs_dept=e&todo=X&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and gs_fees>0 and (mark='N' or mark is null) and (invoice_chk='B' or invoice_chk='C') and acc_chk='Y' "
						attr-href="brt7m/ext76_list.aspx?spkind=gs_fees&qs_dept=e&todo=X&homelist=homelist"
						></span><!--主管-->
			   		</TD>
				</TR>
				<TR bgcolor=lightblue>
			   	    <TD align=right class=data11>(已發文)</TD>
			   		<TD align=center class=data1>已支出未請款案件(<font color=blue>智產</font>)：</TD>
			   		<TD align=center class=data2>ｘ	</TD><!--國內案-->
			   		<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_ext where in_scode='<%=Session["scode"]%>' and (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and gs_fees>0 and (mark='N' or mark is null) and invoice_chk='A' and acc_chk='Y' "
						attr-href="brtdm/extd6_list.aspx?spkind=gs_fees&scode=<%=Session["scode"]%>&qs_dept=e&todo=X&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and gs_fees>0 and (mark='N' or mark is null) and invoice_chk='A' and acc_chk='Y' "
						attr-href="brtdm/extd6_list.aspx?spkind=gs_fees&qs_dept=e&todo=X&homelist=homelist"
						></span><!--主管-->
			   		</TD>
				</TR>
			  	<TR bgcolor=lightblue>
			   	    <TD align=center class=data11>(未送簽)</TD>
			   		<TD align=center class=data1>請款單尚未送確認(<font color=blue>一般</font>/英文Invoice)：</TD>
			   		<TD align=center class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_scode='<%=Session["scode"]%>' and ar_type='T' and ar_status like 'N%' and substring(ISNULL(mark_code,''),2,1) <>'Y'"
						attr-href="brt7m/ext72_list.aspx?scode=<%=Session["scode"]%>&prgid=brt721&todo=N&qs_dept=t&ar_mark=N"
						></span><!--個人,沒勾英文Invoice-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_type='T' and ar_status like 'N%' and substring(ISNULL(mark_code,''),2,1) <>'Y'"
						attr-href="brt7m/ext76_list.aspx?qs_dept=t&todo=NN&homelist=homelist"
						></span><!--主管,沒勾英文Invoice-->
						/
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_scode='<%=Session["scode"]%>' and ar_type='T' and ar_status like 'N%' and substring(ISNULL(mark_code,''),2,1) ='Y'"
						attr-href="brt7m/ext72_list.aspx?scode=<%=Session["scode"]%>&prgid=brt721&todo=N&qs_dept=t&ar_mark=N&e_invoice=Y"
						></span><!--個人,有勾英文Invoice-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_type='T' and ar_status like 'N%' and substring(ISNULL(mark_code,''),2,1) ='Y'"
						attr-href="brt7m/ext76_list.aspx?qs_dept=t&todo=NN&homelist=homelist&e_invoice=Y"
						></span><!--主管,有勾英文Invoice-->
			   		</TD>
			    	<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_scode='<%=Session["scode"]%>' and ar_type='E' and ar_status like 'N%' and invoice_mark='B' and substring(ISNULL(mark_code,''),2,1) <>'Y' "
						attr-href="brt7m/ext72_list.aspx?scode=<%=Session["scode"]%>&prgid=ext721&todo=N&qs_dept=e&ar_mark=N"
						></span><!--個人,沒勾英文Invoice-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_type='E' and ar_status like 'N%' and invoice_mark='B' and substring(ISNULL(mark_code,''),2,1) <>'Y' "
						attr-href="brtdm/extd6_list.aspx?qs_dept=e&todo=NN&homelist=homelist"
						></span><!--主管,沒勾英文Invoice-->
						/
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_scode='<%=Session["scode"]%>' and ar_type='E' and ar_status like 'N%' and invoice_mark='B' and substring(ISNULL(mark_code,''),2,1) ='Y'"
						attr-href="brt7m/ext72_list.aspx?scode=<%=Session["scode"]%>&prgid=ext721&todo=N&qs_dept=e&ar_mark=N&e_invoice=Y"
						></span><!--個人,有勾英文Invoice-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_type='E' and ar_status like 'N%' and invoice_mark='B' and substring(ISNULL(mark_code,''),2,1) ='Y'"
						attr-href="brtdm/extd6_list.aspx?qs_dept=e&todo=NN&homelist=homelist&e_invoice=Y"
						></span><!--主管,有勾英文Invoice-->
			    	</TD>
			    </TR>
				<TR bgcolor=lightblue>
			   	    <TD align=center class=data11>(未送簽)</TD>
			   		<TD align=center class=data1>請款單尚未送確認(<font color=blue>智產</font>/英文Invoice)：&nbsp;&nbsp;&nbsp;</TD>
			   		<TD align=center class=data2>ｘ	</TD><!--國內案-->
			    	<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_scode='<%=Session["scode"]%>' and ar_type='E' and ar_status like 'N%' and invoice_mark='A' and substring(ISNULL(mark_code,''),2,1) <>'Y' "
						attr-href="brtdm/extd2_list.aspx?scode=<%=Session["scode"]%>&prgid=extd21&todo=N&qs_dept=e&ar_mark=N"
						></span><!--個人,沒勾英文Invoice-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_type='E' and ar_status like 'N%' and invoice_mark='A' and substring(ISNULL(mark_code,''),2,1) <>'Y' "
						attr-href="brtdm/extd6_list.aspx?qs_dept=e&todo=NN&homelist=homelist"
						></span><!--主管,沒勾英文Invoice-->
						/
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_scode='<%=Session["scode"]%>' and ar_type='E' and ar_status like 'N%' and invoice_mark='A' and substring(ISNULL(mark_code,''),2,1) ='Y'"
						attr-href="brtdm/extd2_list.aspx?scode=<%=Session["scode"]%>&prgid=extd21&todo=N&qs_dept=e&ar_mark=N&e_invoice=Y"
						></span><!--個人,有勾英文Invoice-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_type='E' and ar_status like 'N%' and invoice_mark='A' and substring(ISNULL(mark_code,''),2,1) ='Y'"
						attr-href="brtdm/extd6_list.aspx?qs_dept=e&todo=NN&homelist=homelist&e_invoice=Y"
						></span><!--主管,有勾英文Invoice-->
			    	</TD>
			    </TR>
				<TR bgcolor=lightblue>
			   	    <TD align=center class=data11>(未送簽)</TD>
			   		<TD align=center class=data1>請款單尚未送確認(<font color=blue>代收代付</font>)：&nbsp;&nbsp;&nbsp;</TD>
			   		<TD align=center class=data2>ｘ	</TD><!--國內案-->
			    	<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_scode='<%=Session["scode"]%>' and ar_type='E' and ar_status like 'N%' and invoice_mark='E' "
						attr-href="brtdm/extd2_list_emark.aspx?scode=<%=Session["scode"]%>&prgid=extd21&todo=N&qs_dept=e&ar_mark=E"
						></span><!--個人,沒勾英文Invoice-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_type='E' and ar_status like 'N%' and invoice_mark='E' "
						attr-href="brtdm/extd6_list_emark.aspx?qs_dept=e&todo=NN&homelist=homelist"
						></span><!--主管,沒勾英文Invoice-->
			    	</TD>
			    </TR>
				<TR bgcolor=lightblue>
			   	    <TD align=center width=18% class=data11>(未交辦)</TD>
			   	   	<TD align=center class=data1>帳款異動尚未交辦：</TD>
			   		<TD align=center class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from casetran_brt where in_scode='<%=Session["scode"]%>' and tran_status like '%S' and country='T'"
						attr-href="Brt8m/Brt82_list.aspx?qs_dept=t&tfx_scode=<%=Session["scode"]%>&tfx_cust_area=<%=Session["seBranch"]%>&tran_status=S"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from casetran_brt where tran_status like '%S' and country='T'"
						attr-href="Brt8m/Brt82_list.aspx?qs_dept=t&tfx_scode=*&tfx_cust_area=<%=Session["seBranch"]%>&tran_status=S&homelist=homelist"
						></span><!--主管-->
					</TD>
			   		<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from casetran_brt where in_scode='<%=Session["scode"]%>' and tran_status like '%S' and country<>'T' "
						attr-href="Brt8m/Brt82_list.aspx?qs_dept=e&tfx_scode=<%=Session["scode"]%>&tfx_cust_area=<%=Session["seBranch"]%>&tran_status=S"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from casetran_brt where tran_status like '%S' and country<>'T' "
						attr-href="Brt8m/Brt82_list.aspx?qs_dept=e&tfx_scode=*&tfx_cust_area=<%=Session["seBranch"]%>&tran_status=S&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   	</TR>
				<TR bgcolor=lightblue>
			   	    <TD align=center width=18% class=data11>(未交辦)</TD>
			   	   	<TD align=center class=data1>帳款異動尚未交辦(<font color=blue>智產</font>)：</TD>
			   		<TD align=center class=data2>ｘ	</TD><!--國內案-->
			   		<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(distinct tran_no) as num from casetran_invext where in_scode='<%=Session["scode"]%>' and tran_status like '%S' and country<>'T' and invoice_chk='A' "
						attr-href="Brtdm/Extda_list.aspx?qs_dept=e&tfx_scode=<%=Session["scode"]%>&tfx_cust_area=<%=Session["seBranch"]%>&tran_status=S&ar_mark=A"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(distinct tran_no) as num from casetran_invext where tran_status like '%S' and country<>'T' and invoice_chk='A' "
						attr-href="Brtdm/Extda_list.aspx?qs_dept=e&tfx_scode=*&tfx_cust_area=<%=Session["seBranch"]%>&tran_status=S&homelist=homelist&ar_mark=A"
						></span><!--主管-->
			   		</TD>
			   	</TR>
				<TR bgcolor=lightblue>
			   	    <TD align=center width=18% class=data11>(未交辦)</TD>
			   	   	<TD align=center class=data1>帳款異動尚未交辦(<font color=blue>代收代付</font>)：</TD>
			   		<TD align=center class=data2>ｘ	</TD><!--國內案-->
			   		<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from casetran_invext where in_scode='<%=Session["scode"]%>' and tran_status like '%S' and country<>'T' and invoice_chk='D' "
						attr-href="Brtdm/Extda_list_emark.aspx?qs_dept=e&tfx_scode=<%=Session["scode"]%>&tfx_cust_area=<%=Session["seBranch"]%>&tran_status=S&ar_mark=E"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from casetran_invext where tran_status like '%S' and country<>'T' and invoice_chk='D' "
						attr-href="Brtdm/Extda_list_emark.aspx?qs_dept=e&tfx_scode=*&tfx_cust_area=<%=Session["seBranch"]%>&tran_status=S&homelist=homelist&ar_mark=E"
						></span><!--主管-->
			   		</TD>
			   	</TR>
				<TR bgcolor=lightblue>
			   	    <TD align=center width=18% class=data11>(未交辦)</TD>
			   	   	<TD align=center class=data1>帳款異動退回營洽：</TD>
			   		<TD align=center class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from casetran_brt where in_scode='<%=Session["scode"]%>' and tran_status like '%X' and country='T'"
						attr-href="Brt8m/Brt82_list.aspx?qs_dept=t&tfx_scode=<%=Session["scode"]%>&tfx_cust_area=<%=Session["seBranch"]%>&tran_status=X&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from casetran_brt where tran_status like '%X' and country='T'"
						attr-href="Brt8m/Brt82_list.aspx?qs_dept=t&tfx_scode=*&tfx_cust_area=<%=Session["seBranch"]%>&tran_status=X&homelist=homelist"
						></span><!--主管-->
					</TD>
			   		<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from casetran_brt where in_scode='<%=Session["scode"]%>' and tran_status like '%X' and country<>'T' "
						attr-href="Brt8m/Brt82_list.aspx?qs_dept=e&tfx_scode=<%=Session["scode"]%>&tfx_cust_area=<%=Session["seBranch"]%>&tran_status=X&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from casetran_brt where tran_status like '%X' and country<>'T' "
						attr-href="Brt8m/Brt82_list.aspx?qs_dept=e&tfx_scode=*&tfx_cust_area=<%=Session["seBranch"]%>&tran_status=X&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   	</TR>
				<TR bgcolor=lightblue>
			   	    <TD align=center width=18% class=data11>(未交辦)</TD>
			   	   	<TD align=center class=data1>帳款異動退回營洽(<font color=blue>智產</font>)：</TD>
			   		<TD align=center class=data2>ｘ	</TD><!--國內案-->
			   		<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(distinct tran_no) as num from casetran_invext where in_scode='<%=Session["scode"]%>' and tran_status like '%X' and country<>'T' and invoice_chk='A' "
						attr-href="Brtdm/Extda_list.aspx?qs_dept=e&tfx_scode=<%=Session["scode"]%>&tfx_cust_area=<%=Session["seBranch"]%>&tran_status=X&homelist=homelist&ar_mark=A"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(distinct tran_no) as num from casetran_invext where tran_status like '%X' and country<>'T' and invoice_chk='A' "
						attr-href="Brtdm/Extda_list.aspx?qs_dept=e&tfx_scode=*&tfx_cust_area=<%=Session["seBranch"]%>&tran_status=X&homelist=homelist&ar_mark=A"
						></span><!--主管-->
			   		</TD>
			   	</TR>
				<TR bgcolor=lightblue>
			   	    <TD align=center width=18% class=data11>(未交辦)</TD>
			   	   	<TD align=center class=data1>帳款異動退回營洽(<font color=blue>代收代付</font>)：</TD>
			   		<TD align=center class=data2>ｘ	</TD><!--國內案-->
			   		<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(distinct tran_no) as num from casetran_invext where in_scode='<%=Session["scode"]%>' and tran_status like '%X' and country<>'T' and invoice_chk='D' "
						attr-href="Brtdm/Extda_list_emark.aspx?qs_dept=e&tfx_scode=<%=Session["scode"]%>&tfx_cust_area=<%=Session["seBranch"]%>&tran_status=X&homelist=homelist&ar_mark=E"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(distinct tran_no) as num from casetran_invext where tran_status like '%X' and country<>'T' and invoice_chk='D' "
						attr-href="Brtdm/Extda_list_emark.aspx?qs_dept=e&tfx_scode=*&tfx_cust_area=<%=Session["seBranch"]%>&tran_status=X&homelist=homelist&ar_mark=E"
						></span><!--主管-->
			   		</TD>
			   	</TR>
				<TR bgcolor=lightblue>
					<TD align=center class=data11>(未交辦)</TD>
					<TD align=center class=data10>尚未交辦國外所：<IMG src="images/flow/6.gif"></TD>
					<TD align=center class=data2>ｘ	</TD><!--國內案-->
					<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_ext where in_scode='<%=Session["scode"]%>' and stat_code='YZ' "
						attr-href="brt4m/ext13_list.aspx?tfx_Cust_area=<%=Session["seBranch"]%>&scode=<%=Session["scode"]%>&prgid=ext13&tfx_stat_code=YZ&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where  stat_code='YZ' "
						attr-href="brt4m/ext13_list.aspx?tfx_Cust_area=<%=Session["seBranch"]%>&prgid=ext13&tfx_stat_code=YZ&homelist=homelist"
						></span><!--主管-->
	   				</TD>
				</TR>
				<TR bgcolor=lightblue>
					<TD align=center class=data11>(未確認)</TD>
					<TD align=center class=data10>聯絡書收文(代發)：<IMG src="images/flow/6.gif"></TD>
					<TD align=center class=data2>ｘ	</TD><!--國內案-->
					<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from attrec_ext a,ext b where b.scode='<%=Session["scode"]%>' and a.cg='A' and a.rs='S' and a.conf_stat='NN' and a.seq=b.seq and a.seq1=b.seq1 "
						attr-href="brtam/Exta21_List.aspx?qryscode=<%=Session["scode"]%>&prgid=exta21&cgrs=AS&qrycgrs=AS&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from attrec_ext a where  a.cg='A' and a.rs='S' and a.conf_stat='NN' "
						attr-href="brtam/Exta21_List.aspx?prgid=exta21&cgrs=AS&qrycgrs=AS&homelist=homelist"
						></span><!--主管-->
	   				</TD>
				</TR>
				<TR bgcolor=lightblue>
					<TD align=center class=data11>(未確認)</TD>
					<TD align=center class=data1>官方收文：&nbsp;&nbsp;&nbsp;</TD>
					<TD align=center class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from todo_dmt a where a.job_scode='<%=Session["scode"]%>' and a.dowhat='SALES_GR' and a.job_status='NN'"
						attr-href="brt1m/brt15_List.aspx?qryscode=<%=Session["scode"]%>&prgid=brt15&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from todo_dmt a where  a.dowhat='SALES_GR' and a.job_status='NN'"
						attr-href="brt1m/brt15_List.aspx?prgid=brt15&qryscode=&qryconf_date=&homelist=homelist"
						></span><!--主管-->
					</TD>
					<TD align=center class=data3>ｘ </TD><!--出口案-->
				</TR>
				<TR bgcolor=lightblue>
					<TD align=center class=data11>(未確認)</TD>
					<TD align=center class=data1>聯絡書收文(代收)：&nbsp;&nbsp;&nbsp;</TD>
					<TD align=center class=data2>ｘ	</TD><!--國內案-->
					<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from attrec_ext a,ext b where b.scode='<%=Session["scode"]%>' and (a.cg='A' or a.cg='Z') and a.rs='R' and a.conf_stat='YY' and a.sales_date is null and a.seq=b.seq and a.seq1=b.seq1 "
						attr-href="brt1m/ext14_List.aspx?qryscode=<%=Session["scode"]%>&prgid=ext14&qrycgrs=AR&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from attrec_ext a where (a.cg='A' or a.cg='Z') and a.rs='R' and a.conf_stat='YY' and a.sales_date is null "
						attr-href="brt1m/ext14_List.aspx?prgid=ext14&qrycgrs=AR&homelist=homelist"
						></span><!--主管-->
	   				</TD>
				</TR>
				<TR bgcolor=lightblue>
					<TD align=center class=data11>(未確認)</TD>
					<TD align=center class=data1><font color=red>聯絡書收文(代收)(10天前)：</font>&nbsp;&nbsp;&nbsp;</TD>
					<TD align=center class=data2>ｘ	</TD><!--國內案-->
					<TD align=center class=data3><!--出口案-->
						<%string conf_date=DateTime.Today.AddDays(-10).ToString("yyyy/M/d");%>
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from attrec_ext a,ext b where b.scode='<%=Session["scode"]%>' and (a.cg='A' or a.cg='Z') and a.rs='R' and a.conf_stat='YY' and a.sales_date is null and a.seq=b.seq and a.seq1=b.seq1 and a.conf_date<'<%=conf_date%>' "
						attr-href="brt1m/ext14_List.aspx?qryscode=<%=Session["scode"]%>&prgid=ext14&qrycgrs=AR&homelist=homelist&qryconf_date=<%=conf_date%>"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from attrec_ext a where (a.cg='A' or a.cg='Z') and a.rs='R' and a.conf_stat='YY' and a.sales_date is null and a.conf_date<'<%=conf_date%>' "
						attr-href="brt1m/ext14_List.aspx?prgid=ext14&qrycgrs=AR&homelist=homelist&qryconf_date=<%=conf_date%>"
						></span><!--主管-->
	   				</TD>
				</TR>
				<TR bgcolor=lightblue>
					<TD align=center class=data11></TD>
					<TD align=center class=data1>後續接洽案件：</TD>
					<TD align=center class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from grconf_dmt a,dmt b where b.scode='<%=Session["scode"]%>' and a.sales_status='YY' and job_type='case' and (a.job_no is null or a.job_no='') and a.seq=b.seq and a.seq1=b.seq1"
						attr-href="brt1m/brt151_List.aspx?qryscode=<%=Session["scode"]%>&prgid=brt151&qryjob_no=N&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from grconf_dmt a where  a.sales_status='YY' and job_type='case' and (a.job_no is null or a.job_no='')"
						attr-href="brt1m/brt151_List.aspx?prgid=brt151&qryscode=&qryjob_no=N&homelist=homelist"
						></span><!--主管-->
					</TD>
					<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from attrec_ext a,ext b where b.scode='<%=Session["scode"]%>' and (a.cg='A' or a.cg='Z') and a.rs='R' and a.conf_stat='YY' and a.sales_date is not null and job_type='case' and (a.job_no is null or a.job_no='') and a.seq=b.seq and a.seq1=b.seq1 "
						attr-href="brt1m/ext18_List.aspx?qryscode=<%=Session["scode"]%>&prgid=ext18&qryjob_no=N&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from attrec_ext a where (a.cg='A' or a.cg='Z') and a.rs='R' and a.conf_stat='YY' and a.sales_date is not null and job_type='case' and (a.job_no is null or a.job_no='') "
						attr-href="brt1m/ext18_List.aspx?prgid=ext18&qryjob_no=N&homelist=homelist"
						></span><!--主管-->
	   				</TD>
				</TR>
				<TR bgcolor=lightblue>
					<TD align=center class=data11></TD>
					<TD align=center class=data10>國外代理人請款：<IMG src="images/flow/6.gif"></TD>
					<TD align=center class=data2>ｘ	</TD><!--國內案-->
					<TD align=center class=data3><!--出口案-->
						<%string sdate=DateTime.Today.ToString("yyyy/M/1");%>
						<%string edate=DateTime.Now.AddMonths(1).AddDays(-DateTime.Now.AddMonths(1).Day).ToString("yyyy/M/d");%>
						<%string rs_type=Sys.getRsTypeExt();%>
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from vstep_ext where ext_scode='<%=Session["scode"]%>' and (cg='A' or cg='Z') and rs='R' and dn_flag='Y' and step_date>='<%=sdate%>' and step_date<='<%=edate%>' "
						attr-href="brt4m/ext41_list.aspx?qryscode=<%=Session["scode"]%>&prgid=ext41&qrydn_flag=Y&qrydate_type=step_date&sdate=<%=sdate%>&edate=<%=edate%>&rs_type=<%=rs_type%>&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from vstep_ext where (cg='A' or cg='Z') and rs='R' and dn_flag='Y' and step_date>='<%=sdate%>' and step_date<='<%=edate%>' "
						attr-href="brt4m/ext41_list.aspx?prgid=ext41&qrydn_flag=Y&qrydate_type=step_date&sdate=<%=sdate%>&edate=<%=edate%>&rs_type=<%=rs_type%>&homelist=homelist"
						></span><!--主管-->
	   				</TD>
				</TR>
				<TR bgcolor=lightblue>
					<TD align=center class=data11></TD>
					<TD align=center class=data1>暫緩結匯稽催尚未回覆：</TD>
					<TD align=center class=data2>ｘ	</TD><!--國內案-->
					<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from holdgs_exd where holdgs_branch='<%=Session["seBranch"]%>' and dept='<%=Session["dept"]%>' and holdgs_rscode='<%=Session["scode"]%>' and back_flag='N' "
						attr-href="brt1m/ext1h_list.aspx?qryholdgs_rscode=<%=Session["scode"]%>&prgid=ext1h&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from holdgs_exd where holdgs_branch='<%=Session["seBranch"]%>' and dept='<%=Session["dept"]%>' and back_flag='N' "
						attr-href="brt1m/ext1h_list.aspx?prgid=ext1h&homelist=homelist"
						></span><!--主管-->
	   				</TD>
				</TR>
				<TR bgcolor=lightblue>
					<TD align=center class=data11></TD>
					<TD align=center class=data1>請款問題尚未結案：</TD>
					<TD align=center class=data2>ｘ	</TD><!--國內案-->
					<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from exch_question a,exch_temp b,ext c where a.exch_no=b.exch_no and b.dept='T' and b.seq=c.seq and b.seq1=c.seq1 and c.scode='<%=Session["scode"]%>' and que_dowhat='qdw0' and que_status='NN' "
						attr-href="brt1m/ext161_list.aspx?qrystatus=P&qryscode=<%=Session["scode"]%>&prgid=ext161&qryjob_no=N&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from exch_question a,exch_temp b where a.exch_no=b.exch_no and b.dept='T' and que_dowhat='qdw0' and que_status='NN' "
						attr-href="brt1m/ext161_list.aspx?qrystatus=P&prgid=ext161&job_no=N&homelist=homelist"
						></span><!--主管-->
	   				</TD>
				</TR>
				<TR bgcolor=lightblue>
					<TD align=center class=data11></TD>
					<TD align=center class=data1>期限稽催尚未回覆：</TD>
					<TD align=center class=data2>ｘ	</TD><!--國內案-->
					<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from ctrlgs_ext where ctrlgs_rscode='<%=Session["scode"]%>' and ctrlgs_type='bsales' and back_flag='N' "
						attr-href="brt1m/ext15_List.aspx?qscode=<%=Session["scode"]%>&prgid=ext15&ctrlgs_type=bsales&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from ctrlgs_ext where  ctrlgs_type='bsales' and back_flag='N' "
						attr-href="brt1m/ext15_list.aspx?prgid=ext15&ctrlgs_type=bsales&homelist=homelist"
						></span><!--主管-->
	   				</TD>
				</TR>	
				<TR bgcolor=lightblue>
					<TD align=center class=data11></TD>
					<TD align=center class=data1>規費不足尚未銷管：</TD>
					<TD align=center class=data2>ｘ	</TD><!--國內案-->
					<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from feesctrl_ext where scode='<%=Session["scode"]%>' and fees_stat='N' "
						attr-href="brt1m/ext19_List.aspx?qryscode=<%=Session["scode"]%>&prgid=ext19&qrycgrs=AR&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from feesctrl_ext where fees_stat='N' "
						attr-href="brt1m/ext19_List.aspx?prgid=ext19&qrycgrs=AR&homelist=homelist&submittask=Q"
						></span><!--主管-->
	   				</TD>
				</TR>
				<TR bgcolor=lightblue>
					<TD align=center class=data11></TD>
					<TD align=center class=data1>轉案退回尚未處理：</TD>
					<TD align=center class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from todo_dmt where job_scode='<%=Session["scode"]%>' and job_status='NN' and dowhat='TRAN_NSB'"
						attr-href="brt1m/brt1b_List.aspx?qryscode=<%=Session["scode"]%>&prgid=brt1b&qryjob_status=NX&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from todo_dmt where job_status='NN' and dowhat='TRAN_NSB'"
						attr-href="brt1m/brt1b_List.aspx?prgid=brt1b&qryjob_status=NX&homelist=homelist"
						></span><!--主管-->
					</TD>
					<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from todo_ext where job_scode='<%=Session["scode"]%>' and job_status='NN' and dowhat='TRAN_NSB' "
						attr-href="brt1m/brt1b_List.aspx?qryscode=<%=Session["scode"]%>&prgid=brt1b&qryjob_status=NX&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from todo_ext where job_status='NN' and dowhat='TRAN_NSB' "
						attr-href="brt1m/brt1b_List.aspx?prgid=brt1b&qryjob_status=NX&homelist=homelist"
						></span><!--主管-->
	   				</TD>
				</TR>
			   	<TR bgcolor=lightblue>
		            <TD align=center class=data11></TD>
		            <TD align=center class=data1>規費不足扣收入尚未處理：</TD>
		            <TD align=center class=data2>ｘ	</TD><!--國內案-->
					<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num From account.dbo.tefee f inner join ext d on f.seq=d.seq and f.seq1=d.seq1 where substring(f.do_status,1,1)='N' and fees1+fees2-fees3-fees4<0 and d.scode='<%=Session["scode"]%>' and f.tr_yy='<%=endtr_yy%>' and f.tr_mm='<%=endtr_mm%>' "
						attr-href="acc2m/acc21_list.aspx?prgid=acc21&qrydept=<%=Session["dept"]%>&qryar_type=e&todo_flag=D&qry_yy=<%=endtr_yy%>&qry_mm=<%=endtr_mm%>&qryscode1=<%=Session["scode"]%>&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumAX" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num From account.dbo.tefee f where substring(f.do_status,1,1)='N' and fees1+fees2-fees3-fees4<0 "
						attr-hrefx="acc2m/acc21_list.aspx?prgid=acc21&submitTask=Q&qrydept=<%=Session["dept"]%>&qryar_type=e&todo_flag=D&qry_yy=<%=endtr_yy%>&qry_mm=<%=endtr_mm%>&homelist=homelist"
						></span><!--主管,不顯示-->
					</TD>
				</TR>	
			   	<TR bgcolor=lightblue>
		            <TD align=center class=data11></TD>
		            <TD align=center class=data1>規費餘額轉收入尚未處理(已結案)：</TD>
		            <TD align=center class=data2>ｘ	</TD><!--國內案-->
					<TD align=center class=data3><!--出口案,排除未回收案件-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num From account.dbo.tefee f inner join ext d on f.seq=d.seq and f.seq1=d.seq1
						where substring(f.do_status,1,1)='N' and fees1+fees2-fees3-fees4>0 and d.scode='<%=Session["scode"]%>'
						and not exists(select * from account.dbo.art where branch='NT' and country<>'T' and seq=f.seq and seq1=f.seq1 and country=f.country and change<>'X' and ar_mark not in ('D','M') having isnull(sum(fees),0)+isnull(sum(cfees),0)-isnull(sum(pin_fees),0)>0) 
						and d.end_date is not null and f.tr_yy='<%=endtr_yy%>' and f.tr_mm='<%=endtr_mm%>'"
						attr-href="acc2m/acc21_list.aspx?prgid=acc22&qrydept=<%=Session["dept"]%>&qryar_type=e&todo_flag=E&qry_yy=<%=endtr_yy%>&qry_mm=<%=endtr_mm%>&qryscode1=<%=Session["scode"]%>&opt_type=end&qrytype=end&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumAX" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num From account.dbo.tefee f inner join ext d on f.seq=d.seq and f.seq1=d.seq1
						where substring(f.do_status,1,1)='N' and fees1+fees2-fees3-fees4>0
						and not exists(select * from account.dbo.art where branch='NT' and country<>'T' and seq=f.seq and seq1=f.seq1 and country=f.country and change<>'X' and ar_mark not in ('D','M') having isnull(sum(fees),0)+isnull(sum(cfees),0)-isnull(sum(pin_fees),0)>0) 
	   					and d.end_date is not null and f.tr_yy='<%=endtr_yy%>' and f.tr_mm='<%=endtr_mm%>'"
						attr-href="acc2m/acc21_list.aspx?prgid=acc22&submitTask=Q&qrydept=<%=Session["dept"]%>&qryar_type=e&todo_flag=E&qry_yy=<%=endtr_yy%>&qry_mm=<%=endtr_mm%>&homelist=homelist"
						></span><!--主管,不顯示-->
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