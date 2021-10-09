<%@ Control Language="C#" ClassName="homelist_job6" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>

<script runat="server">
    public Dictionary<string, string> rights = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> rightsE = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    string SQL = "";
    private void Page_Load(Object sender, EventArgs e) {
    }
</script>

<!--工作清單:會計(title6)-->
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
					<TD width="64%" colspan=2><P align=center><IMG src="images/flow/title6.gif"></P></TD>
					<TD width="18%" align=center><IMG src="images/flow/head03.gif"></TD>
					<TD width="18%" align=center class=data3h><IMG src="images/flow/head04.gif"></TD>
			   	</TR>
	 	        <TR bgcolor=lightblue>
	   	            <TD align=center width=18% class=data11></TD>
	   		        <TD align=center class=data10>請款單尚未送確認:<IMG src="images/flow/6.gif"></TD>
	   		        <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("6")%>"
			            attr-sql="select count(*) as num from account.dbo.artmain where ar_type='T' and ar_status like 'N%' and invoice_mark='B'"
			            attr-href="brt7m/ext76_list.aspx?qs_dept=t&todo=NN&homelist=homelist"
			            ></span>
			        </TD>
			        <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("6")%>"
			            attr-sql="select count(*) as num from account.dbo.artmain where ar_type='E' and ar_status like 'N%' and invoice_mark='B'"
			            attr-href="brt7m/ext76_list.aspx?qs_dept=e&todo=NN&homelist=homelist"
			            ></span>
			        </TD>
		        </TR>
		        <TR bgcolor=lightblue>
			        <TD align=center width=18% class=data11></TD>
			        <TD align=center class=data1><font color=blue>收據</font>契約書尚未檢核:</TD>
			        <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("6")%>"
			            attr-sql="select count(*) as num from todo_dmt where syscode='<%=Session["syscode"]%>' and apcode in('brt51','brt25','acc31at') and dowhat='contractA' and job_status='NN'"
			            attr-href="brt7m/brt7d_list.aspx?prgid=brt7d&qryseq_type=T&homelist=homelist"
			            ></span>
			        </TD>
			        <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("6")%>"
			            attr-sql="select count(*) as num from todo_ext a inner join case_ext b on a.in_no=b.in_no and b.invoice_chk='B' where syscode='<%=Session["syscode"]%>' and apcode in('brt51','brt25','acc31at') and dowhat='contractA' and job_status='NN'"
			            attr-href="brt7m/brt7d_list.aspx?prgid=brt7d&qryseq_type=TE&homelist=homelist"
			            ></span>
	   		        </TD>
		        </TR>
		        <TR bgcolor=lightblue>
		            <TD align=center width=18% class=data11></TD>
			        <TD align=center class=data1>請款單尚未確認:</TD>
			        <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("6")%>"
			            attr-sql="select count(*) as num from account.dbo.artmain a 
				        INNER JOIN sysctrl.dbo.todolist B ON a.branch=b.branch and B.syscode='<%=Session["syscode"]%>' and B.apcode='Brt72' and A.ar_no = B.in_no and A.in_scode=B.in_scode 
				        where b.job_scode='<%=Session["scode"]%>' and a.ar_type='T' and a.ar_status='YY' and b.job_status='NN'"
			            attr-hrefx="brt7m/ext74_list.aspx?conf_scode=<%=Session["scode"]%>&qs_dept=t&homelist=homelist"
			            ></span><!--個人,不顯示link-->
			            <span class="loadnumA" attr-right="<%=rights.TryGet("6")%>"
			            attr-sql="select count(*) as num from account.dbo.artmain where ar_type='T' and ar_status='YY' and invoice_mark='B'"
			            attr-hrefx="brt7m/ext74_list.aspx?qs_dept=t&homelist=homelist"
			            ></span><!--主管,不顯示link-->
			        </TD>
			        <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("6")%>"
			            attr-sql="select count(*) as num from account.dbo.artmain a
				        INNER JOIN sysctrl.dbo.todolist B ON a.branch=b.branch and B.apcode='ext72' and A.ar_no = B.in_no and A.in_scode=B.in_scode
				        where b.job_scode='<%=Session["scode"]%>' and a.ar_type='E' and a.ar_status='YY' and b.job_status='NN'"
			            attr-hrefx="brt7m/ext74_list.aspx?conf_scode=<%=Session["scode"]%>&qs_dept=e&homelist=homelist"
			            ></span><!--個人,不顯示link-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("6")%>"
			            attr-sql="select count(*) as num from account.dbo.artmain where ar_type='E' and ar_status='YY' and invoice_mark='B'"
			            attr-hrefx="brt7m/ext74_list.aspx?qs_dept=e&homelist=homelist"
			            ></span><!--主管,不顯示link-->
			        </TD>
		        </TR>
		        <TR bgcolor=lightblue>
		            <TD align=center width=18% class=data11></TD>
			        <TD align=center class=data1>更正註銷尚未確認:</TD>
			        <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("6")%>"
			            attr-sql="select count(*) as num from casetran_brt a inner join sysctrl.dbo.todolist s on a.sqlno=s.att_no
				        and s.apcode in('brt81','brt82','Brt38') and s.dowhat='DT' and s.job_status='NN' and s.job_scode='<%=Session["scode"]%>'
				        where a.country='T' and a.tran_status like '%Y'"
			            attr-hrefx="brt8m/Brt84_list.aspx?tfx_conf_scode=<%=Session["scode"]%>&qs_dept=t&homelist=homelist"
			            ></span><!--個人,不顯示link-->
			            <span class="loadnumA" attr-right="<%=rights.TryGet("6")%>"
			            attr-sql="select count(*) as num from casetran_brt where country='T' and tran_status like '%Y'"
			            attr-hrefx="brt8m/Brt84_list.aspx?qs_dept=t&homelist=homelist&submittask=Q"
			            ></span><!--主管,不顯示link-->
			        </TD>
			        <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("6")%>"
			            attr-sql="select count(*) as num from casetran_brt a inner join sysctrl.dbo.todolist s on a.sqlno=s.att_no
				        and s.apcode in('ext81','ext82','Ext38') and s.dowhat='DT' and s.job_status='NN' and s.job_scode='<%=Session["scode"]%>'
				        where a.country<>'T' and a.tran_status like '%Y'"
			            attr-hrefx="brt8m/Brt84_list.aspx?tfx_conf_scode=<%=Session["scode"]%>&qs_dept=e&homelist=homelist"
			            ></span><!--個人,不顯示link-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("6")%>"
			            attr-sql="select count(*) as num from casetran_brt where country<>'T' and tran_status like '%Y'"
			            attr-hrefx="brt8m/Brt84_list.aspx?qs_dept=e&homelist=homelist&submittask=Q"
			            ></span><!--主管,不顯示link-->
			        </TD>
		        </TR>
		        <TR bgcolor=lightblue>
	  	            <TD align=center width=18% class=data11></TD>
	   		        <TD align=center class=data10><font color=blue>智產</font>請款單尚未送確認:<IMG src="images/flow/6.gif"></TD>
	   		        <TD align=center class=data2>ｘ</TD><!--國內案-->
			        <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("6")%>"
			            attr-sql="select count(*) as num from account.dbo.artmain where ar_type='E' and ar_status like 'N%' and invoice_mark='A'"
			            attr-href="brtdm/extd6_list.aspx?qs_dept=e&todo=NN&homelist=homelist"
			            ></span>
			        </TD>
		        </TR>
		        <TR bgcolor=lightblue>
			        <TD align=center width=18% class=data11></TD>
			        <TD align=center class=data1><font color=blue>發票</font>契約書尚未檢核:</TD>
			        <TD align=center class=data2>ｘ</TD><!--國內案-->
			        <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("6")%>"
			            attr-sql="select count(*) as num from todo_ext a inner join case_ext b on a.in_no=b.in_no and b.invoice_chk='A' where syscode='<%=Session["syscode"]%>' and apcode in('ext51','ext25','acc31it') and dowhat='contractA' and job_status='NN'"
			            attr-href="brtdm/extd11_List.aspx?prgid=extd11&qs_dept=e&homelist=homelist"
			            ></span>
	   		        </TD>
	            </TR>
		        <TR bgcolor=lightblue>
			        <TD align=center width=18% class=data11></TD>
			        <TD align=center class=data1><font color=blue>智產</font>請款單尚未確認:</TD>
			        <TD align=center class=data2>ｘ</TD><!--國內案-->
			        <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("6")%>"
			            attr-sql="select count(*) as num from account.dbo.artmain a
				        INNER JOIN sysctrl.dbo.todolist B ON a.branch=b.branch and B.apcode='extd2' and A.ar_no = B.in_no and A.in_scode=B.in_scode 
				        where b.job_scode='<%=Session["scode"]%>' and a.ar_type='E' and ar_status='YY' and a.invoice_mark='A' and b.job_status='NN' "
			            attr-hrefx="brtdm/extd4list.aspx?conf_scode=<%=Session["scode"]%>&qs_dept=e&homelist=homelist"
			            ></span><!--個人,不顯示link-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("6")%>"
			            attr-sql="select count(*) as num from account.dbo.artmain where ar_type='E' and ar_status='YY' and invoice_mark='A'"
			            attr-hrefx="brtdm/extd4list.aspx?qs_dept=e&homelist=homelist"
			            ></span><!--主管,不顯示link-->
	   		        </TD>
		        </TR>
		        <TR bgcolor=lightblue>
		            <TD align=center width=18% class=data11></TD>
			        <TD align=center class=data1><font color=blue>智產</font>更正註銷尚未確認:</TD>
			        <TD align=center class=data2>ｘ</TD><!--國內案-->
			        <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("6")%>"
			            attr-sql="select count(*) as num from artran_invext a inner join sysctrl.dbo.todolist s on a.artran_sqlno=s.att_no
				        and s.apcode in('extd9','extda','Ext3e') and s.dowhat='DI' and s.job_status='NN' and s.job_scode='<%=Session["scode"]%>'
				        where a.artran_status like '%Y'"
			            attr-hrefx="brtdm/Extdb_list.aspx?tfx_conf_scode=<%=Session["scode"]%>&qs_dept=e&homelist=homelist&qryar_mark=A"
			            ></span><!--個人,不顯示link-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("6")%>"
			            attr-sql="select count(*) as num from artran_invext a inner join sysctrl.dbo.todolist s on a.artran_sqlno=s.att_no
				        and s.apcode in('extd9','extda','Ext3e') and s.dowhat='DI' and s.job_status='NN' 
				        where a.artran_status like '%Y'"
			            attr-hrefx="brtdm/Extdb_list.aspx?qs_dept=e&homelist=homelist&submittask=Q&qryar_mark=A"
			            ></span><!--主管,不顯示link-->
			        </TD>
		        </TR>
		        <TR bgcolor=lightblue>
	  	            <TD align=center width=18% class=data11></TD>
	   		        <TD align=center class=data10><font color=blue>代收代付</font>請款單尚未送確認:<IMG src="images/flow/6.gif"></TD>
	   		        <TD align=center class=data2>ｘ</TD><!--國內案-->
			        <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("6")%>"
			            attr-sql="select count(*) as num from account.dbo.artmain where ar_type='E' and ar_status like 'N%' and invoice_mark='E'"
			            attr-href="brtdm/extd6_list_emark.aspx?qs_dept=e&todo=NN&homelist=homelist"
			            ></span>
			        </TD>
		        </TR>
		        <TR bgcolor=lightblue>
			        <TD align=center width=18% class=data11></TD>
			        <TD align=center class=data1><font color=blue>代收代付</font>請款單尚未確認:</TD>
			        <TD align=center class=data2>ｘ</TD><!--國內案-->
			        <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("6")%>"
			            attr-sql="select count(*) as num from account.dbo.artmain a 
				        INNER JOIN sysctrl.dbo.todolist B ON a.branch=b.branch and B.apcode='extd2' and A.ar_no = B.in_no and A.in_scode=B.in_scode 
				        where b.job_scode='<%=Session["scode"]%>' and a.ar_type='E' and ar_status='YY' and a.invoice_mark='E' and b.job_status='NN'"
			            attr-hrefx="brtdm/extd4list_emark.aspx?conf_scode=<%=Session["scode"]%>&qs_dept=e&homelist=homelist"
			            ></span><!--個人,不顯示link-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("6")%>"
			            attr-sql="select count(*) as num from account.dbo.artmain where ar_type='E' and ar_status='YY' and invoice_mark='E'"
			            attr-hrefx="brtdm/extd4list_emark.aspx?qs_dept=e&homelist=homelist"
			            ></span><!--主管,不顯示link-->
	   		        </TD>
		        </TR>	
		        <TR bgcolor=lightblue>
			        <TD align=center width=18% class=data11></TD>
			        <TD align=center class=data1><font color=blue>代收代付</font>更正註銷尚未確認:</TD>
			        <TD align=center class=data2>ｘ</TD><!--國內案-->
			        <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("6")%>"
			            attr-sql="select count(*) as num from artran_invext a inner join sysctrl.dbo.todolist s on a.artran_sqlno=s.att_no
				        and s.apcode in('extd9','extda','Ext3e') and s.dowhat='DE' and s.job_status='NN' and s.job_scode='<%=Session["scode"]%>'
				        where a.artran_status like '%Y'"
			            attr-hrefx="brtdm/Extdb_list_emark.aspx?tfx_conf_scode=<%=Session["scode"]%>&qs_dept=e&homelist=homelist&qryar_mark=E"
			            ></span><!--個人,不顯示link-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("6")%>"
			            attr-sql="select count(*) as num from artran_invext a inner join sysctrl.dbo.todolist s on a.artran_sqlno=s.att_no
				        and s.apcode in('extd9','extda','Ext3e') and s.dowhat='DE' and s.job_status='NN' 
				        where a.artran_status like '%Y'"
			            attr-hrefx="brtdm/Extdb_list_emark.aspx?qs_dept=e&homelist=homelist&submittask=Q&qryar_mark=E"
			            ></span><!--主管,不顯示link-->
			        </TD>
		        </TR>
		        <TR bgcolor=lightblue>
			        <TD align=center width=18% class=data11></TD>
			        <TD align=center class=data1>結案案件尚未確認:</TD>
			        <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("6")%>"
			            attr-sql="select count(*) as num from todo_dmt where syscode='<%=Session["syscode"]%>' and dowhat='ACC_END' and job_status='NN'"
			            attr-href="brt7m/brt7b_list.aspx?prgid=brt7b&homelist=homelist"
			            ></span>
			        </TD>
			        <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("6")%>"
			            attr-sql="select count(*) as num from todo_ext where syscode='<%=Session["syscode"]%>' and dowhat='ACC_END' and job_status='NN'"
			            attr-href="brtdm/extdh_list.aspx?prgid=extdh&homelist=homelist"
			            ></span>
			        </TD>
		        </TR>
		        <TR bgcolor=lightblue>
			        <TD align=center width=18% class=data11></TD>
			        <TD align=center class=data1>扣收入案件尚未檢核:</TD>
			        <TD align=center class=data2>ｘ</TD><!--國內案-->
			        <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("6")%>"
			            attr-sql="select count(*) as num from todo_ext s where s.dowhat='acc_dchk' and s.job_status='NN' and s.job_scode='<%=Session["scode"]%>' and s.syscode='<%=Session["syscode"]%>'"
			            attr-href="brtdm/Extdg_list.aspx?tfx_conf_scode=<%=Session["scode"]%>&qs_dept=e&homelist=homelist"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("6")%>"
			            attr-sql="select count(*) as num from todo_ext s where s.dowhat='acc_dchk' and s.job_status='NN' and s.syscode='<%=Session["syscode"]%>'"
			            attr-href="brtdm/Extdg_list.aspx?qs_dept=e&homelist=homelist"
			            ></span><!--主管-->
			        </TD>
		        </TR>
		        <TR bgcolor=lightblue>
			        <TD align=center width=18% class=data11></TD>
			        <TD align=center class=data1>催帳尚未確認:</TD>
			        <TD align=center class=data2 colspan=2>
			            <span class="loadnum" attr-right="<%=rights.TryGet("6")%>" attr-rightE="<%=rightsE.TryGet("6")%>"
			            attr-sql="select count(*) as num from account.dbo.cust_step where step_class='db_ann' and step_stat='YN' and dept='<%=Session["dept"]%>'"
			            attr-hrefx="acc1m/acc121_list.aspx?prgid=acc121"
			            ></span><!--不顯示link-->
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