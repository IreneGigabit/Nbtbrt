<%@ Control Language="C#" ClassName="homelist_job5" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>

<script runat="server">
    public Dictionary<string, string> rights = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> rightsE = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    string SQL = "";
    private void Page_Load(Object sender, EventArgs e) {
    }
</script>

<!--工作清單:承辦(title5)-->
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
					<TD width="64%" colspan=2><P align=center><IMG src="images/flow/title5.gif"></P></TD>
					<TD width="18%" align=center><IMG src="images/flow/head03.gif"></TD>
					<TD width="18%" align=center class=data3h><IMG src="images/flow/head04.gif"></TD>
			   	</TR>
			   	<TR bgcolor=lightblue>
			   	    <TD align=center width=18% class=data11></TD>
			   		<TD align=center class=data1>承辦申請書列印:</TD>
			   		<TD align=center class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("5")%>"
						attr-sql="select count(*) as num from case_dmt a
						inner join code_br b on a.arcase=b.rs_code and b.dept='<%=Session["dept"]%>' and b.cr='Y'
						and b.prt_code not in ('ZZ','null','D9Z','D3') and b.no_code = 'N' and b.rs_type=a.arcase_type
						left join attcase_dmt at on a.in_no=at.in_no and isnull(at.sign_stat,'') not in('XX') 
						where a.new='N' and (a.mark='N' or a.mark is null) and a.arcase not in ('DE2','AD8')
						and isnull(at.sign_stat,'') not in('SZ')"
						attr-href="brt1m/brt14_list.aspx?tfx_new=N&homelist=homelist"
						></span>
			   		</TD>
			   		<TD align=center class=data3>ｘ</TD><!--出口案-->
			   	</TR>
			   	<TR bgcolor=lightblue>
			   	    <TD align=center width=18% class=data11></TD>
			   		<TD align=center class=data1>客收尚未承辦:</TD>
			   		<TD align=center class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("5")%>"
						attr-sql="select count(*) as num from case_dmt a inner join todo_dmt b
						on a.in_no=b.in_no and b.syscode='<%=Session["syscode"]%>' and b.apcode in('Brt51','brta33','opt11','brta38')
						and b.job_status='NN' and b.dowhat='DP_GS' 
						where a.stat_code='YZ' and b.job_scode='<%=Session["scode"]%>' "
						attr-href="brt6m/brt63_list.aspx?prgid=brt63&homelist=homelist&qryjob_scode=<%=Session["scode"]%>"
						></span>
                        (<span class="loadnum" attr-right="<%=rights.TryGet("5")%>"
						attr-sql="select count(*) as num from case_dmt a inner join todo_dmt b
						on a.in_no=b.in_no and b.syscode='<%=Session["syscode"]%>' and b.apcode in('Brt51','brta33','opt11','brta38')
						and b.job_status='NN' and b.dowhat='DP_GS' 
						where a.stat_code='YZ' "
						attr-href="brt6m/brt63_list.aspx?prgid=brt63&homelist=homelist"
						></span>)
			   		</TD>
			   		<TD align=center class=data3>ｘ</TD><!--出口案-->
			   	</TR>
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11>(國外所)</TD>
		            <TD align=center class=data1>尚未指定代理人：</TD>
		            <TD align=center class=data2>ｘ</TD><!--國內案-->
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("5")%>"
			            attr-sql="select count(*) num from case_ext a 
		                inner join sysctrl.dbo.scode_group b on a.in_scode = b.scode 
		                where a.assign_agt='Y' and a.pr_scode is null and b.pr_scode='<%=Session["scode"]%>' and (mark='N' or mark is null)"
			            attr-href="brt6m/Ext63_list.aspx?new=send&pr_scode=<%=Session["scode"]%>&homelist=homelist&prgid=ext63"
			            ></span>
                        (<span class="loadnum" attr-right="<%=rightsE.TryGet("5")%>"
			            attr-sql="select count(*) num from case_ext a 
		                inner join sysctrl.dbo.scode_group b on a.in_scode = b.scode 
		                where a.assign_agt='Y' and a.pr_scode is null and (mark='N' or mark is null)"
			            attr-href="brt6m/Ext63_list.aspx?new=send&pr_scode=&homelist=homelist&prgid=ext63"
			            ></span>)
                        /
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("5")%>"
			            attr-sql="select count(*) num from case_ext where assign_agt='Y' and pr_scode='<%=Session["scode"]%>' and not re_scode is null and re_date between '<%=DateTime.Today.ToString("yyyy/M/1")%>' and '<%=DateTime.Today.ToString("yyyy/M/d")%> 23:59:59'"
			            attr-href="brt4m/Ext13listA.aspx?type=ext63&pr_scode=<%=Session["scode"]%>&qs_dept=e&homelist=homelist&beg_date=<%=DateTime.Today.ToString("yyyy/M/1")%>&end_date=<%=DateTime.Today.ToString("yyyy/M/d")%>"
			            ></span>
		            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11>(專案室)</TD>
		            <TD align=center class=data1>尚未交辦專案室：</TD>
		            <TD align=center class=data2>ｘ</TD><!--國內案-->
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("5")%>"
			            attr-sql="select count(*) num from todo_ext a 
		                where a.syscode='<%=Session["syscode"]%>' and (a.apcode='ext51' or a.apcode='exta34') and a.dowhat='DP_BS' and a.job_status='NN' and a.job_scode='<%=Session["scode"]%>'"
			            attr-href="brt6m/ext61_list.aspx?todo=S&homelist=homelist&qrydowhat=DP_BS"
			            ></span>
                        (<span class="loadnum" attr-right="<%=rightsE.TryGet("5")%>"
			            attr-sql="select count(*) num from todo_ext a where a.syscode='<%=Session["syscode"]%>' and (a.apcode='ext51' or a.apcode='exta34') and a.dowhat='DP_BS' and a.job_status='NN'"
			            attr-href="brt6m/ext61_list.aspx?todo=S&homelist=homelist&pr_scode=*&qrydowhat=DP_BS"
			            ></span>)
		            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11></TD>
		            <TD align=center class=data1>爭救案尚未回稿確認：</TD>
		            <TD align=center class=data2>ｘ</TD><!--國內案-->
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("5")%>"
			            attr-sql="select count(*) num from todo_ext a where a.syscode='OPT' and a.apcode='opte22' and a.dowhat='DP_RR' and a.job_status='NN' and a.job_scode='<%=Session["scode"]%>'"
			            attr-href="brt6m/ext613_list.aspx?homelist=homelist&qrypr_scode=<%=Session["scode"]%>&prgid=ext613"
			            ></span>
                        (<span class="loadnum" attr-right="<%=rightsE.TryGet("5")%>"
			            attr-sql="select count(*) num from todo_ext a where a.syscode='OPT' and a.apcode='opte22' and a.dowhat='DP_RR' and a.job_status='NN'"
			            attr-href="brt6m/ext613_list.aspx?homelist=homelist&prgid=ext613"
			            ></span>)
		            </TD>
	            </TR>	
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11>(國外所)</TD>
		            <TD align=center class=data1>尚未交辦國外所：</TD>
		            <TD align=center class=data2>ｘ</TD><!--國內案-->
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("5")%>"
			            attr-sql="select count(*) num from todo_ext a where a.syscode='<%=Session["syscode"]%>' and a.apcode in('ext51','ext613','exta34','ext36','ext52','opte11') and a.dowhat='DP_TS' and a.job_status='NN' and a.job_scode='<%=Session["scode"]%>'"
			            attr-href="brt6m/ext61_list.aspx?todo=S&homelist=homelist&qrydowhat=DP_TS"
			            ></span>
                        (<span class="loadnum" attr-right="<%=rightsE.TryGet("5")%>"
			            attr-sql="select count(*) num from todo_ext a where a.syscode='<%=Session["syscode"]%>' and a.apcode in('ext51','ext613','exta34','ext36','ext52','opte11') and a.dowhat='DP_TS' and a.job_status='NN'"
			            attr-href="brt6m/ext61_list.aspx?todo=S&homelist=homelist&pr_scode=*&qrydowhat=DP_TS"
			            ></span>)
		            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11></TD>
		            <TD align=center class=data1>聯絡書收文(代發)未確認：</TD>
		            <TD align=center class=data2>ｘ</TD><!--國內案-->
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("5")%>"
			            attr-sql="select count(*) num from attrec_ext a where a.conf_stat='YY' and a.pr_scode='<%=Session["scode"]%>' and a.pr_flag='N' and a.cg='A' and a.rs='S' group by a.cg,a.rs"
			            attr-href="brt6m/ext66_List.aspx?prgid=ext66&qrycgrs=AS&qrypr_scode=<%=Session["scode"]%>&homelist=homelist"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("5")%>"
			            attr-sql="select count(*) num from attrec_ext a where a.conf_stat='YY' and a.pr_flag='N' and a.cg='A' and a.rs='S'  group by a.cg,a.rs"
			            attr-href="brt6m/ext66_List.aspx?prgid=ext66&qrycgrs=AS&homelist=homelist"
			            ></span><!--主管-->
		            </TD>
	            </TR>
                <TR bgcolor=lightblue>
	                <TD align=center class=data11></TD>
		            <TD align=center class=data1>聯絡書收文(代收)未確認：</TD>
		            <TD align=center class=data2>ｘ</TD><!--國內案-->
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("5")%>"
			            attr-sql="select count(*) num from attrec_ext a where a.conf_stat='YY' and a.pr_scode='<%=Session["scode"]%>' and a.pr_flag='N' and a.cg='A' and a.rs='R' group by a.cg,a.rs"
			            attr-href="brt6m/ext66_List.aspx?prgid=ext66&qrycgrs=AR&qrypr_scode=<%=Session["scode"]%>&homelist=homelist"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("5")%>"
			            attr-sql="select count(*) num from attrec_ext a where a.conf_stat='YY' and a.pr_flag='N' and a.cg='A' and a.rs='R'  group by a.cg,a.rs"
			            attr-href="brt6m/ext66_List.aspx?prgid=ext66&qrycgrs=AR&homelist=homelist"
			            ></span><!--主管-->
		            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11></TD>
		            <TD align=center class=data1>聯絡書收文(本收)未確認：</TD>
		            <TD align=center class=data2>ｘ</TD><!--國內案-->
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("5")%>"
			            attr-sql="select count(*) num from attrec_ext a where a.conf_stat='YY' and a.pr_scode='<%=Session["scode"]%>' and a.pr_flag='N' and a.cg='Z' and a.rs='R' group by a.cg,a.rs"
			            attr-href="brt6m/ext66_List.aspx?prgid=ext66&qrycgrs=ZR&qrypr_scode=<%=Session["scode"]%>&homelist=homelist"
			            ></span><!--個人-->
			            <span class="loadnumA" attr-right="<%=rightsE.TryGet("5")%>"
			            attr-sql="select count(*) num from attrec_ext a where a.conf_stat='YY' and a.pr_flag='N' and a.cg='Z' and a.rs='R'  group by a.cg,a.rs"
			            attr-href="brt6m/ext66_List.aspx?prgid=ext66&qrycgrs=ZR&homelist=homelist"
			            ></span><!--主管-->
		            </TD>
	            </TR>
	            <TR bgcolor=lightblue>
	                <TD align=center class=data11></TD>
		            <TD align=center class=data1>溝通記錄尚未回覆：</TD>
		            <TD align=center class=data2>ｘ</TD><!--國內案-->
		            <TD align=center class=data3><!--出口案-->
			            <span class="loadnum" attr-right="<%=rightsE.TryGet("5")%>"
			            attr-sql="select count(*)  as num from prcom_ext a where a.com_scode='<%=Session["scode"]%>' and left(step_chk,1)='N' and pre_sqlno = 0 and a.com_branch='<%=Session["seBranch"]%>'"
			            attr-href="brt6m/ext3a6_list.aspx?prgid=ext6b1&qcom_branch=<%=Session["seBranch"]%>&qcom_scode=<%=Session["scode"]%>&qstep_chk=N2&homelist=homelist"
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