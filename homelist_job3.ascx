<%@ Control Language="C#" ClassName="homelist_job3" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>

<script runat="server">
    public Dictionary<string, string> rights = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> rightsE = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    string SQL = "";
    private void Page_Load(Object sender, EventArgs e) {
    }
</script>

<!--工作清單:程序(title3)-->
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
					<TD width="64%" colspan=2><P align=center><IMG src="images/flow/title3.gif"></P></TD>
					<TD width="18%" align=center><IMG src="images/flow/head03.gif"></TD>
					<TD width="18%" align=center class=data3h><IMG src="images/flow/head04.gif"></TD>
			   	</TR>
		        <TR bgcolor=lightblue>
		            <TD align=center width=18% class=data11>(未簽准)</TD>
			        <TD align=center class=data10>營洽已交辦未簽准案件：<IMG src="images/flow/6.gif"></TD>
			        <TD align=center class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("3")%>"
						attr-sql="select count(*) as num from case_dmt where (stat_code='YN' or stat_code='YT') and (mark='N' or mark is null)"
						attr-href="brt4m/brt13_list.aspx?tfx_stat_code=YN&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span>
			        </TD>
			        <TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("3")%>"
						attr-sql="select count(*) as num from case_ext where (stat_code='YN' or stat_code='YT') and (mark='N' or mark is null)"
						attr-href="brt4m/ext13_list.aspx?tfx_stat_code=YN&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span>
			        </TD>
		        </TR>
			   	<TR bgcolor=lightblue>
			   	    <TD align=center class=data11>(已簽准)</TD>
			   	   	<TD align=center class=data1>客戶收文尚未確認：</TD>
			   		<TD align=center class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("3")%>"
						attr-sql="select count(*) as num from case_dmt where stat_code='YY' and (mark='N' or mark is null) and arcase_type<>'T'"
						attr-href="brt5m/brt51_list.aspx?tfx_stat_code=YY&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span>
					</TD>
			   		<TD align=center class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("3")%>"
						attr-sql="select count(*) as num from case_ext where stat_code='YY' and (mark='N' or mark is null)"
						attr-href="brt5m/ext51_list.aspx?tfx_stat_code=YY&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span>
			   		</TD>
			   	</TR>
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11></TD>
	   	            <TD align=center class=data1>官方發文(非電子/電子)尚未確認：</TD>
		            <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("3")%>"
			            attr-sql="SELECT count(*) as num 
			            FROM attcase_dmt a 
			            inner join todo_dmt b on a.att_sqlno=b.temp_rs_sqlno 
			            where a.conf_date is null and b.dowhat='DC_GS' and b.job_status='NN' 
                        and isnull(a.send_way,'') not in('E','EA') "
			            attr-href="brtam/brta38_List.aspx?prgid=brta38&homelist=homelist&qrysend_way=M"
			            ></span>
                        /
			            <span class="loadnum" attr-right="<%=rights.TryGet("3")%>"
			            attr-sql="SELECT count(*) as num 
			            FROM attcase_dmt a 
			            inner join todo_dmt b on a.att_sqlno=b.temp_rs_sqlno 
			            where a.conf_date is null and b.dowhat='DC_GS' and b.job_status='NN' 
                        and isnull(a.send_way,'') in('E','EA') "
			            attr-href="brtam/brta38_List.aspx?prgid=brta38&homelist=homelist&qrysend_way=E"
			            ></span>
		            </TD>
		            <TD align=center class=data3>ｘ</TD><!--出口案-->
	            </TR>
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11></TD>
	   	            <TD align=center class=data1>官發回條/<font color=red>退件</font>尚未確認：</TD>
		            <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("3")%>"
			            attr-sql="select count(*) as num from todo_dmt where dowhat='GS' and job_status='NN'"
			            attr-href="brtam/brta33_List.aspx?prgid=brta33&qrydowhat=mg_gs&homelist=homelist&cgrs=gs"
			            ></span>
                        /
			            <span class="loadnum" attr-right="<%=rights.TryGet("3")%>"
			            attr-sql="select count(*) as num from todo_dmt where (dowhat='GSB' or dowhat='GSBS') and job_status='NN'"
			            attr-href="brtam/brta33_List.aspx?prgid=brta33&qrydowhat=mg_gs_back&homelist=homelist&cgrs=gs"
			            ></span>
		            </TD>
		            <TD align=center class=data3>ｘ</TD><!--出口案-->
	            </TR>	
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11></TD>
	   	            <TD align=center class=data1>官方收文(紙本/電子/電子公文)尚未確認：</TD>
		            <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("3")%>"
			            attr-sql="select count(*) as num from step_mgt_temp a,todo_dmt b where a.cg='G' and a.rs='R' and (a.from_flag<>'C' and a.from_flag<>'J') and a.into_date is null and a.temp_rs_sqlno=b.temp_rs_sqlno and b.dowhat='GR' and b.job_status='NN'"
			            attr-href="brtam/brta24_List.aspx?prgid=brta24&qryfrom_flag=P&homelist=homelist&cgrs=gr"
			            ></span>
                        /
                        <span class="loadnum" attr-right="<%=rights.TryGet("3")%>"
			            attr-sql="select count(*) as num from step_mgt_temp a,todo_dmt b where a.cg='G' and a.rs='R' and a.from_flag='C' and a.into_date is null and a.temp_rs_sqlno=b.temp_rs_sqlno and b.dowhat='GR' and b.job_status='NN'"
			            attr-href="brtam/brta24_List.aspx?prgid=brta24&qryfrom_flag=C&homelist=homelist&cgrs=gr"
			            ></span>
                        /
                        <span class="loadnum" attr-right="<%=rights.TryGet("3")%>"
			            attr-sql="select count(*) as num from step_mgt_temp a,todo_dmt b where a.cg='G' and a.rs='R' and a.from_flag='J' and a.into_date is null and a.temp_rs_sqlno=b.temp_rs_sqlno and b.dowhat='GR' and b.job_status='NN'"
			            attr-href="brtam/brta24_List.aspx?prgid=brta24&qryfrom_flag=J&homelist=homelist&cgrs=gr"
			            ></span>
		            </TD>
		            <TD align=center class=data3>ｘ</TD><!--出口案-->
	            </TR>
	            <TR bgcolor=lightblue>
		            <TD align=center width=18% class=data11>(未簽准)</TD>
			        <TD align=center class=data10>承辦已交辦國外所未簽准案件：<IMG src="images/flow/6.gif"></TD>
			        <TD align=center class=data2>ｘ</TD><!--國內案-->
			        <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("3")%>"
			            attr-sql="select count(*) as num from todo_ext where job_status='NN' and dowhat='DB_TS' and syscode='<%=Session["syscode"]%>' and apcode='Ext61'"
			            attr-href="brt4m/ext13_list.aspx?tfx_stat_code=ST&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
			            ></span>
			        </TD>
	            </TR>
	            <TR bgcolor=lightblue>
		            <TD align=center class=data1></TD>
		            <TD align=center class=data1>國外所發文未確認：</TD>
		            <TD align=center class=data2>ｘ</TD><!--國內案-->
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("3")%>"
			            attr-sql="select count(*) as num from attcase_ext a
		                inner join todo_ext t on a.in_scode=t.case_in_scode and a.in_no=t.in_no
		                where t.syscode='<%=Session["syscode"]%>' and t.apcode='ext61' and t.job_status='NN'
		                and t.dowhat='DS' and a.sign_stat='SY' "
			            attr-href="brt5m/ext52_list.aspx?homelist=homelist"
			            ></span>
		            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
		            <TD align=center class=data1></TD>
		            <TD align=center class=data1>聯絡書收文(代發)未確認：</TD>
		            <TD align=center class=data2>ｘ</TD><!--國內案-->
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("3")%>"
			            attr-sql="select count(*) as num from attrec_ext a where a.cg='A' and a.rs='S' and a.conf_stat='NN' and branch='<%=Session["seBranch"]%>'"
			            attr-href="brtam/Exta21_List.aspx?prgid=exta21&cgrs=AS&qrycgrs=AS&homelist=homelist"
			            ></span>
		            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
		            <TD align=center class=data1></TD>
		            <TD align=center class=data1>聯絡書收文(代收)未確認：</TD>
		            <TD align=center class=data2>ｘ</TD><!--國內案-->
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("3")%>"
			            attr-sql="select count(*) as num from attrec_ext a where a.cg='A' and a.rs='R' and a.conf_stat='NN' and (a.pr_scan='N' or a.pr_scan_page >0 or a.pr_scan_date is not null) and branch='<%=Session["seBranch"]%>'"
			            attr-href="brtam/Exta21_List.aspx?prgid=exta21&cgrs=AR&qrycgrs=AR&qryispr_scan=Y&homelist=homelist"
			            ></span>
		            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
		            <TD align=center class=data1></TD>
		            <TD align=center class=data1>聯絡書收文(本收)未確認：</TD>
		            <TD align=center class=data2>ｘ</TD><!--國內案-->
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("3")%>"
			            attr-sql="select count(*) as num from attrec_ext a where a.cg='Z' and a.rs='R' and a.conf_stat='NN' and branch='<%=Session["seBranch"]%>'"
			            attr-href="brtam/Exta21_List.aspx?prgid=exta21&cgrs=ZR&qrycgrs=ZR&homelist=homelist"
			            ></span>
		            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
		            <TD align=center class=data1></TD>
		            <TD align=center class=data1>結案案件/<font color=red>退件</font>未處理：</TD>
		            <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("3")%>"
			            attr-sql="select count(*) as num from todo_dmt where syscode='<%=Session["syscode"]%>' and job_status='NN' and dowhat='DC_END1' and from_flag='END'"
			            attr-href="brtam/brta74_List.aspx?prgid=brta74&qfrom_flag=END&homelist=homelist"
			            ></span>
                        /
			            <span class="loadnum" attr-right="<%=rights.TryGet("3")%>"
			            attr-sql="select count(*) as num from todo_dmt where syscode='<%=Session["syscode"]%>' and job_status='NN' and dowhat='DC_END1' and (from_flag='END_DB' or from_flag='END_ACC')"
			            attr-href="brtam/brta74_List.aspx?prgid=brta74&qfrom_flag=BACK&homelist=homelist"
			            ></span>
		            </TD>
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("3")%>"
			            attr-sql="select count(*) as num from todo_ext a,ctrl_ext b 
		                where a.seq=b.seq and a.seq1=b.seq1 and a.rs_sqlno=b.rs_sqlno 
		                and a.syscode='<%=Session["syscode"]%>' and a.job_status='NN' and a.dowhat='DC_END1' and a.from_flag='END' 
		                and b.ctrl_type='B6' and b.ctrl_date <='<%=DateTime.Today.ToShortDateString()%>'"
			            attr-href="brtam/exta74_List.aspx?prgid=exta74&qfrom_flag=END&homelist=homelist&edate=<%=DateTime.Today.ToShortDateString()%>"
			            ></span>
                        (<span class="loadnum" attr-right="<%=rightsE.TryGet("3")%>"
			            attr-sql="select count(*) as num from todo_ext where syscode='<%=Session["syscode"]%>' and job_status='NN' and dowhat='DC_END1' and from_flag='END'"
			            attr-href="brtam/exta74_List.aspx?prgid=exta74&qfrom_flag=END&homelist=homelist"
			            ></span>)
                        /
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("3")%>"
			            attr-sql="select count(*) as num from todo_ext where syscode='<%=Session["syscode"]%>' and job_status='NN' and dowhat='DC_END1' and (from_flag='END_DB' or from_flag='END_ACC')"
			            attr-href="brtam/exta74_List.aspx?prgid=exta74&qfrom_flag=BACK&homelist=homelist"
			            ></span>
		            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
		            <TD align=center class=data1></TD>
		            <TD align=center class=data1>結案確認尚未確認：</TD>
		            <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("3")%>"
			            attr-sql="select count(*) as num from todo_dmt where syscode='<%=Session["syscode"]%>' and job_status='NN' and dowhat='DC_END2'"
			            attr-href="brtam/brta75_List.aspx?prgid=brta75&homelist=homelist"
			            ></span>
		            </TD>
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("3")%>"
			            attr-sql="select count(*) as num from todo_ext where syscode='<%=Session["syscode"]%>' and job_status='NN' and dowhat='DC_END2'"
			            attr-href="brtam/exta75_List.aspx?prgid=exta75&homelist=homelist"
			            ></span>
		            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
		            <TD align=center class=data1></TD>
		            <TD align=center class=data1>轉案發文尚未確認：</TD>
		            <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("3")%>"
			            attr-sql="select count(*) as num from todo_dmt where syscode='<%=Session["syscode"]%>' and job_status='NN' and dowhat='TRAN_ND'"
			            attr-href="brtam/brta76_List.aspx?prgid=brta76&homelist=homelist&qs_dept=t"
			            ></span>
		            </TD>
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("3")%>"
			            attr-sql="select count(*) as num from todo_ext where syscode='<%=Session["syscode"]%>' and job_status='NN' and dowhat='TRAN_ND'"
			            attr-href="brtam/brta76_List.aspx?prgid=exta76&homelist=homelist&qs_dept=e"
			            ></span>
		            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
		            <TD align=center class=data1></TD>
		            <TD align=center class=data1>轉案完成尚未確認：</TD>
		            <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("3")%>"
			            attr-sql="select count(*) as num from todo_dmt where syscode='<%=Session["syscode"]%>' and job_status='NN' and dowhat='TRAN_ED1'"
			            attr-href="brtam/brta77_List.aspx?prgid=brta77&homelist=homelist&qs_dept=t"
			            ></span>
		            </TD>
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("3")%>"
			            attr-sql="select count(*) as num from todo_ext where syscode='<%=Session["syscode"]%>' and job_status='NN' and dowhat='TRAN_ED1'"
			            attr-href="brtam/brta77_List.aspx?prgid=exta77&homelist=homelist&qs_dept=e"
			            ></span>
		            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
		            <TD align=center class=data1></TD>
		            <TD align=center class=data1>確認轉案尚未處理：</TD>
		            <TD align=center class=data2><!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("3")%>"
			            attr-sql="select count(*) as num from todo_dmt where syscode='<%=Session["syscode"]%>' and job_status='NN' and dowhat='TRAN_ED'"
			            attr-href="brtam/brta78_List.aspx?prgid=brta78&homelist=homelist&qs_dept=t"
			            ></span>
		            </TD>
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("3")%>"
			            attr-sql="select count(*) as num from todo_ext where syscode='<%=Session["syscode"]%>' and job_status='NN' and dowhat='TRAN_ED'"
			            attr-href="brtam/brta78_List.aspx?prgid=exta78&homelist=homelist&qs_dept=e"
			            ></span>
		            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
		            <TD align=center class=data11>(未確收)</TD>
		            <TD align=center class=data10>已確認未確收案件(代收)：<IMG src="images/flow/6.gif"></TD>
		            <TD align=center class=data2>ｘ</TD><!--國內案-->
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("3")%>"
			            attr-sql="select count(*) as num from attrec_ext a where a.cg='A' and a.rs='R' and a.conf_stat='YY' and a.sales_date is null"
			            attr-href="brt1m/ext14_List.aspx?prgid=ext14&qrycgrs=AR&homelist=homelist"
			            ></span>
	   	            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
		            <TD align=center class=data11>(未銷管)</TD>
		            <TD align=center class=data10>規費不足尚未銷管：<IMG src="images/flow/6.gif"></TD>
		            <TD align=center class=data2>ｘ</TD><!--國內案-->
		            <TD align=center class=data3><!--出口案-->
                        <span class="loadnum" attr-right="<%=rightsE.TryGet("3")%>"
                        attr-sql="select count(*) as num from feesctrl_ext a where a.fees_stat='N'"
                        attr-href="brt1m/ext19_List.aspx?prgid=ext19&qrycgrs=AR&homelist=homelist&submittask=Q"
                        ></span>
	   	            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
		            <TD align=center class=data1></TD>
		            <TD align=center class=data1>催帳單尚未列印暨寄出確認：</TD>
		            <TD align=center class=data2>聖島：<!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("3")%>"
			            attr-sql="select count(*) as num from account.dbo.cust_step where dept='<%=Session["dept"]%>' and step_class='db_ann' and invoice_mark='B' and step_stat='YY'"
			            attr-href="acc1m/acc132_list.aspx?prgid=acc132&qrycs_type=db_ann_B&homelist=homelist"
			            ></span>
		            </TD>
		            <TD align=center class=data3>聖智：<!--出口案-->
                        <span class="loadnum" attr-right="<%=rightsE.TryGet("3")%>"
                        attr-sql="select count(*) as num from account.dbo.cust_step where dept='<%=Session["dept"]%>' and step_class='db_ann' and invoice_mark='A' and step_stat='YY'"
                        attr-href="acc1m/acc132_list.aspx?prgid=acc132&qrycs_type=db_ann_A&homelist=homelist"
                        ></span>
		            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
		            <TD align=center class=data11>(未確認)</TD>
		            <TD align=center class=data10>催帳會計未確認：<IMG src="images/flow/6.gif"></TD>
		            <TD align=center class=data2>聖島：<!--國內案-->
			            <span class="loadnum" attr-right="<%=rights.TryGet("3")%>"
			            attr-sql="select count(*) as num from account.dbo.cust_step where dept='<%=Session["dept"]%>' and step_class='db_ann' and invoice_mark='B' and step_stat='YN'"
			            attr-href="acc1m/acc11_list1.aspx?prgid=acc14&qrytodo=Q&qrydept=<%=Session["dept"]%>&qryinvmark=B&qrystep_stat=YN&homelist=homelist"
			            ></span>
		            </TD>
		            <TD align=center class=data3>聖智：<!--出口案-->
                        <span class="loadnum" attr-right="<%=rightsE.TryGet("3")%>"
                        attr-sql="select count(*) as num from account.dbo.cust_step where dept='<%=Session["dept"]%>' and step_class='db_ann' and invoice_mark='A' and step_stat='YN'"
                        attr-href="acc1m/acc11_list1.aspx?prgid=acc14&qrytodo=Q&qrydept=<%=Session["dept"]%>&qryinvmark=A&qrystep_stat=YN&homelist=homelist"
                        ></span>
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