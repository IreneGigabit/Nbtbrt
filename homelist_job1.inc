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
					<TD width="64%" colspan=2>
					<P align=center><IMG src="images/flow/title1.gif"></P></TD>
					<TD width="18%" align=middle><IMG src="images/flow/head03.gif"></STRONG></FONT></TD>
					<TD width="18%" align=middle><IMG src="images/flow/head04.gif"></STRONG></FONT></TD>
			   	</TR>
			   	<TR bgcolor=lightblue align=center>
			   		<TD align=middle width=18% class=data11>(未交辦)</TD>
			   	   	<TD align=middle class=data1>營洽尚未交辦案件：</TD>
			   		<TD align=middle class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_dmt where in_scode='<%=Session["scode"]%>' and stat_code='NN' and (mark='N' or mark is null)"
						attr-href="homeFrame.asp?tpath=brt1m&tprgid=brt12list&tFrame=Eblank&stat_code=NN&tscode=<%=Session["scode"]%>&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_dmt where stat_code='NN' and (mark='N' or mark is null)"
						attr-href="brt4m/brt13list.asp?tfx_stat_code=NN&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   		<TD align=middle class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_ext where in_scode='<%=Session["scode"]%>' and stat_code='NN' AND (mark='N' or mark is null)"
						attr-href="homeFrame.asp?tpath=brt1m&tprgid=ext12list&tFrame=Brt12blank&stat_code=NN&tscode=<%=Session["scode"]%>&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where stat_code='NN' and (mark='N' or mark is null)"
						attr-href="brt4m/ext13list.asp?tfx_stat_code=NN&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   	</TR>
			   	<TR bgcolor=lightblue>
			   		<TD align=middle class=data11>(未交辦)</TD>
			   		<TD align=middle class=data1>交辦案件退回營洽：</TD>
			   		<TD align=middle class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_dmt where in_scode='<%=Session["scode"]%>' and stat_code='NX' and (mark='N' or mark is null) and cust_area='<%=Session["seBranch"]%>'"
						attr-href="homeFrame.asp?tpath=brt1m&tprgid=brt12list&tFrame=Eblank&tscode=<%=Session["scode"]%>&stat_code=NX&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_dmt where stat_code='NX' and (mark='N' or mark is null)"
						attr-href="brt4m/brt13list.asp?tfx_stat_code=NX&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   		<TD align=middle class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_ext where in_scode='<%=Session["scode"]%>' and stat_code='NX' and (mark='N' or mark is null)"
						attr-href="homeFrame.asp?tpath=brt1m&tprgid=ext12list&tFrame=Brt12blank&tscode=<%=Session["scode"]%>&stat_code=NX&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where stat_code='NX' and (mark='N' or mark is null)"
						attr-href="brt4m/ext13list.asp?tfx_stat_code=NX&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   	</TR>
			  	<TR bgcolor=lightblue>
			   		<TD align=middle class=data11>(未確認)</TD>
			   		<TD align=middle class=data10>已交辦未確認案件：<IMG src="images/flow/6.gif"></TD>
			   		<TD align=middle class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_dmt where in_scode='<%=Session["scode"]%>' and stat_code like 'Y%' and stat_code<>'YZ' and (mark='N' or mark is null)"
						attr-href="brt4m/brt13list.asp?scode=<%=Session["scode"]%>&stat_code1=Y&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_dmt where stat_code like 'Y%' and stat_code<>'YZ' and (mark='N' or mark is null)"
						attr-href="brt4m/brt13list.asp?stat_code1=Y%&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   		<TD align=middle class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_ext where in_scode='<%=Session["scode"]%>' and stat_code like 'Y%' and stat_code<>'YZ' and (mark='N' or mark is null)"
						attr-href="brt4m/ext13list.asp?scode=<%=Session["scode"]%>&stat_code1=Y&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where stat_code like 'Y%' and stat_code<>'YZ' and (mark='N' or mark is null)"
						attr-href="brt4m/ext13list.asp?stat_code1=Y%&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   	</TR>
			   	<TR bgcolor=lightblue>
			   		<TD align=middle class=data11>(已交辦)</TD>
			   		<TD align=middle class=data10>已交辦未檢核案件：<IMG src="images/flow/6.gif"></TD>
			   		<TD align=middle class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_dmt where in_scode='<%=Session["scode"]%>' and cust_area='<%=Session["seBranch"]%>' and stat_code='YZ' and ar_code='N' and (mark='N' or mark is null) and (acc_chk='N' or acc_chk is null)"
						attr-href="brt4m/brt13list.asp?scode=<%=Session["scode"]%>&stat_code1=Z&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_dmt where stat_code='YZ' and ar_code='N' and (mark='N' or mark is null) and cust_area='<%=Session["seBranch"]%>'  and (acc_chk='N' or acc_chk is null)"
						attr-href="brt4m/brt13list.asp?stat_code1=Z%&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   		<TD align=middle class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_ext where in_scode='<%=Session["scode"]%>' and cust_area='<%=Session["seBranch"]%>' and (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and (mark='N' or mark is null) and (invoice_chk='B') and (acc_chk='N' or acc_chk is null)"
						attr-href="brt4m/ext13list.asp?scode=<%=Session["scode"]%>&stat_code1=ZB&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and (mark='N' or mark is null) and cust_area='<%=Session["seBranch"]%>' and (invoice_chk='B') and (acc_chk='N' or acc_chk is null)"
						attr-href="brt4m/ext13list.asp?stat_code1=ZB%&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   	</TR>
			   	<TR bgcolor=lightblue>
			   		<TD align=middle class=data11>(已交辦)</TD>
			   		<TD align=middle class=data1>已交辦未請款案件：</TD>
			   		<TD align=middle class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_dmt where in_scode='<%=Session["scode"]%>' and cust_area='<%=Session["seBranch"]%>' and stat_code='YZ' and ar_code='N' and (mark='N' or mark is null) and acc_chk='Y'"
						attr-href="brt7m/ext76list.asp?scode=<%=Session["scode"]%>&qs_dept=t&todo=X&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_dmt where stat_code='YZ' and ar_code='N' and (mark='N' or mark is null) and cust_area='<%=Session["seBranch"]%>' and acc_chk='Y'"
						attr-href="brt7m/ext76list.asp?qs_dept=t&todo=X&getdo=N&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   		<TD align=middle class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_dmt where in_scode='<%=Session["scode"]%>' and cust_area='<%=Session["seBranch"]%>' and stat_code='YZ' and ar_code='N' and (mark='N' or mark is null) and acc_chk='Y'"
						attr-href="brt7m/ext76list.asp?scode=<%=Session["scode"]%>&qs_dept=e&todo=X&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and (mark='N' or mark is null) and cust_area='<%=Session["seBranch"]%>' and (invoice_chk='B' or invoice_chk='C') and acc_chk='Y'"
						attr-href="brt7m/ext76list.asp?qs_dept=e&todo=X&getdo=N&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   	</TR>
			   	<TR bgcolor=lightblue>
			   	    <TD align=middle class=data11>(已交辦)</TD>
			   		<TD align=middle class=data10>已交辦未檢核案件(<font color=blue>智產</font>)：<IMG src="images/flow/6.gif"></TD>
			   		<TD align=middle class=data2>ｘ	</TD><!--國內案-->
			   		<TD align=middle class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_ext where in_scode='<%=Session["scode"]%>' and cust_area='<%=Session["seBranch"]%>' and (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and (mark='N' or mark is null) and (invoice_chk='A') and (acc_chk='N' or acc_chk is null)"
						attr-href="brt4m/ext13list.asp?scode=<%=Session["scode"]%>&stat_code1=Z&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and (mark='N' or mark is null) and cust_area='<%=Session["seBranch"]%>' and (invoice_chk='A') and (acc_chk='N' or acc_chk is null) "
						attr-href="brt4m/ext13list.asp?stat_code1=Z%&tfx_cust_area=<%=Session["seBranch"]%>&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   	</TR>
				<TR bgcolor=lightblue>
			   	    <TD align=middle class=data11>(已交辦)</TD>
			   		<TD align=middle class=data1>已交辦未請款案件(<font color=blue>智產</font>)：</TD>
			   		<TD align=middle class=data2>ｘ	</TD><!--國內案-->
			   		<TD align=middle class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_ext where in_scode='<%=Session["scode"]%>' and cust_area='<%=Session["seBranch"]%>' and (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and (mark='N' or mark is null) and (invoice_chk='A') and acc_chk='Y'"
						attr-href="brtdm/extd6list.asp?scode=<%=Session["scode"]%>&qs_dept=e&todo=X&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and (mark='N' or mark is null) and cust_area='<%=Session["seBranch"]%>' and (invoice_chk='A') and acc_chk='Y' "
						attr-href="brtdm/extd6list.asp?qs_dept=e&todo=X&getdo=N&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   	</TR>
				<TR bgcolor=lightblue>
			   	    <TD align=middle class=data11>(已交辦)</TD>
			   		<TD align=middle class=data1>已交辦未請款案件(<font color=blue>代收代付</font>)：</TD>
			   		<TD align=middle class=data2>ｘ	</TD><!--國內案-->
			   		<TD align=middle class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_ext where in_scode='<%=Session["scode"]%>' and cust_area='<%=Session["seBranch"]%>' and (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and (mark='N' or mark is null) and (invoice_chk='D') "
						attr-href="brtdm/extd6list_emark.asp?scode=<%=Session["scode"]%>&qs_dept=e&todo=X&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and (mark='N' or mark is null) and cust_area='<%=Session["seBranch"]%>' and (invoice_chk='D') "
						attr-href="brtdm/extd6list_emark.asp?qs_dept=e&todo=X&getdo=N&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   	</TR>
			   	<TR bgcolor=lightblue>
			   	    <TD align=right class=data11>(已發文)</TD>
			   		<TD align=middle class=data1>已支出未請款案件：</TD>
			   		<TD align=middle class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_dmt where in_scode='<%=Session["scode"]%>' and stat_code='YZ' and ar_code='N' and gs_fees>0 and (mark='N' or mark is null) and acc_chk='Y'"
						attr-href="brt7m/ext76list.asp?spkind=gs_fees&scode=<%=Session["scode"]%>&qs_dept=t&todo=X&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_dmt where stat_code='YZ' and ar_code='N' and gs_fees>0 and (mark='N' or mark is null) and acc_chk='Y'"
						attr-href="brt7m/ext76list.asp?spkind=gs_fees&qs_dept=t&todo=X&homelist=homelist"
						></span><!--主管-->
			   		</TD>
			   		<TD align=middle class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_ext where in_scode='<%=Session["scode"]%>' and (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and gs_fees>0 and (mark='N' or mark is null) and (invoice_chk='B' or invoice_chk='C') and acc_chk='Y' "
						attr-href="brt7m/ext76list.asp?spkind=gs_fees&scode=<%=Session["scode"]%>&qs_dept=e&todo=X&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and gs_fees>0 and (mark='N' or mark is null) and (invoice_chk='B' or invoice_chk='C') and acc_chk='Y' "
						attr-href="brt7m/ext76list.asp?spkind=gs_fees&qs_dept=e&todo=X&homelist=homelist"
						></span><!--主管-->
			   		</TD>
				</TR>
				<TR bgcolor=lightblue>
			   	    <TD align=right class=data11>(已發文)</TD>
			   		<TD align=middle class=data1>已支出未請款案件(<font color=blue>智產</font>)：</TD>
			   		<TD align=middle class=data2>ｘ	</TD><!--國內案-->
			   		<TD align=middle class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from case_ext where in_scode='<%=Session["scode"]%>' and (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and gs_fees>0 and (mark='N' or mark is null) and invoice_chk='A' and acc_chk='Y' "
						attr-href="brtdm/extd6list.asp?spkind=gs_fees&scode=<%=Session["scode"]%>&qs_dept=e&todo=X&homelist=homelist"
						></span><!--個人-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from case_ext where (stat_code='YZ' or stat_code like 'S%') and ar_code='N' and gs_fees>0 and (mark='N' or mark is null) and invoice_chk='A' and acc_chk='Y' "
						attr-href="brtdm/extd6list.asp?spkind=gs_fees&qs_dept=e&todo=X&homelist=homelist"
						></span><!--主管-->
			   		</TD>
				</TR>
			  	<TR bgcolor=lightblue>
			   	    <TD align=middle class=data11>(未送簽)</TD>
			   		<TD align=middle class=data1>請款單尚未送確認(<font color=blue>一般</font>/英文Invoice)：</TD>
			   		<TD align=middle class=data2><!--國內案-->
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_scode='<%=Session["scode"]%>' and ar_type='T' and ar_status like 'N%' and substring(ISNULL(mark_code,''),2,1) <>'Y'"
						attr-href="brt7m/ext72list.asp?scode=<%=Session["scode"]%>&prgid=brt721&todo=N&qs_dept=t&ar_mark=N"
						></span><!--個人,沒勾英文Invoice-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_type='T' and ar_status like 'N%' and substring(ISNULL(mark_code,''),2,1) <>'Y'"
						attr-href="brt7m/ext76list.asp?qs_dept=t&todo=NN&homelist=homelist"
						></span><!--主管,沒勾英文Invoice-->
						/
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_scode='<%=Session["scode"]%>' and ar_type='T' and ar_status like 'N%' and substring(ISNULL(mark_code,''),2,1) ='Y'"
						attr-href="brt7m/ext72list.asp?scode=<%=Session["scode"]%>&prgid=brt721&todo=N&qs_dept=t&ar_mark=N&e_invoice=Y"
						></span><!--個人,有勾英文Invoice-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_type='T' and ar_status like 'N%' and substring(ISNULL(mark_code,''),2,1) ='Y'"
						attr-href="brt7m/ext76list.asp?qs_dept=t&todo=NN&homelist=homelist&e_invoice=Y"
						></span><!--主管,有勾英文Invoice-->
			   		</TD>
			    	<TD align=middle class=data3><!--出口案-->
						<span class="loadnum" attr-right="<%=rightsE.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_scode='<%=Session["scode"]%>' and ar_type='E' and ar_status like 'N%' and invoice_mark='B' and substring(ISNULL(mark_code,''),2,1) <>'Y' "
						attr-href="brt7m/ext72list.asp?scode=<%=Session["scode"]%>&prgid=ext721&todo=N&qs_dept=e&ar_mark=N"
						></span><!--個人,沒勾英文Invoice-->
						<span class="loadnumA" attr-right="<%=rightsE.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_type='E' and ar_status like 'N%' and invoice_mark='B' and substring(ISNULL(mark_code,''),2,1) <>'Y' "
						attr-href="brtdm/extd6list.asp?qs_dept=e&todo=NN&homelist=homelist"
						></span><!--主管,沒勾英文Invoice-->
						/
						<span class="loadnum" attr-right="<%=rights.TryGet("1")%>" title="個人案件"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_scode='<%=Session["scode"]%>' and ar_type='E' and ar_status like 'N%' and invoice_mark='B' and substring(ISNULL(mark_code,''),2,1) ='Y'"
						attr-href="brt7m/ext72list.asp?scode=<%=Session["scode"]%>&prgid=ext721&todo=N&qs_dept=e&ar_mark=N&e_invoice=Y"
						></span><!--個人,有勾英文Invoice-->
						<span class="loadnumA" attr-right="<%=rights.TryGet("1")%>" title="全部營洽"
						attr-sql="select count(*) as num from account.dbo.artmain where ar_type='E' and ar_status like 'N%' and invoice_mark='B' and substring(ISNULL(mark_code,''),2,1) ='Y'"
						attr-href="brtdm/extd6list.asp?qs_dept=e&todo=NN&homelist=homelist&e_invoice=Y"
						></span><!--主管,有勾英文Invoice-->
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