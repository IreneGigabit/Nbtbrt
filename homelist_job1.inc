	<%if (rights.TryGet("1")!="") {
	SQL = "select count(*) as num from case_dmt ";
	SQL+= "where in_scode='" +Session["scode"]+ "' and stat_code='NN' and (mark='N' or mark is null)";
	string receipt_name = conn.getZero(SQL);
	%>
	*<%=receipt_name%>*
	<%}%>

	<%if (rights.TryGet("1")=="A") {
	SQL = "select count(*) as num from case_dmt where stat_code='NN' and (mark='N' or mark is null)";
	string receipt_name = conn.getZero(SQL);
	%>
	*<%=receipt_name%>*
	<%}%>
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
			   		<TD align=middle class=data2>
					</TD>
			   		<TD align=middle class=data3>
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