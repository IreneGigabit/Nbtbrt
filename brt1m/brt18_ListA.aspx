<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "爭救案進度查詢";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();

    protected string case_no = "";
    protected string branch = "";
    protected string fseq = "";
    protected string in_scode = "";
    protected string scode_name = "";

    DataTable dt = new DataTable();
    DBHelper connopt = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (connopt != null) connopt.Dispose();
    }
   
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        connopt = new DBHelper(Conn.optK).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        
        case_no = (Request["case_no"] ?? "").Trim();
        branch = (Request["branch"] ?? "").Trim();
        fseq = (Request["fseq"] ?? "").Trim();
        in_scode = (Request["in_scode"] ?? "").Trim();
        scode_name = (Request["scode_name"] ?? "").Trim();

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;

        if (HTProgRight >= 0) {
            QueryData();

            this.DataBind();
        }
    }

    private void QueryData() {
        SQL = "select * ";
        SQL += ",(select code_name from cust_code where code_type='ODowhat' and cust_code = a.dowhat) as dowhat_nm ";
        SQL += ",(SELECT sc_name FROM sysctrl.dbo.scode WHERE scode = a.approve_scode) AS approve_scode_nm ";
        SQL += ",(select code_name from cust_code where code_type='OJOB_STAT' and cust_code = a.job_status) as job_status_nm ";
        SQL += " from todo_opt as a ";
        SQL += " where case_no =  '" + case_no + "'";
        SQL += " and branch =  '" + branch + "'";
        //Sys.showLog(SQL);
        connopt.DataTable(SQL, dt);

        for (int i = 0; i < dt.Rows.Count; i++) {
        }

        dataRepeater.DataSource = dt;
        dataRepeater.DataBind();
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
<uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=prgid%><%=HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <a class="imgCls" href="javascript:void(0);" >[關閉視窗]</a>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>

    <div align="center" id="noData" style="display:<%#dt.Rows.Count==0?"":"none"%>">
	    <font color="red">=== 查無案件資料 ===</font>
    </div>

    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
      <table align=center style="color:blue" class="bluetable1">
		    <TR>
		    <Div>
		    <TD>營洽人員:<font color="red"><%=scode_name%></font></TD>
		    <TD>本所編號:<font color="red"><%=fseq%></font></TD>
		    <TD>交辦序號:<font color="red"><%=case_no%></font></TD>
		    </Div>
		    </TR> 
	    </table>
        <br />
        <table style="display:<%#dt.Rows.Count==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="90%" align="center" id="dataList">
	        <thead>
                <TR>
		            <td class=lightbluetable align="center">序號</td>
		            <td class=lightbluetable align="center">分派日期</td>	
		            <td class=lightbluetable align="center">簽核人員</td>
		            <td class=lightbluetable align="center">完成日期</td>
		            <td class=lightbluetable align="center">簽核狀態</td>
		            <td class=lightbluetable align="center">簽核說明</td>
	            </TR>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			    <ItemTemplate>
                    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center">
	                    <td class="whitetablebg" align="center"><%#(Container.ItemIndex+1)%></td>

	                    <td class="whitetablebg" align="center"><%#Eval("in_date")%></td>
		                <td><%#Eval("approve_scode_nm")%>&nbsp;</td>
		                <td><%#Eval("resp_date")%>&nbsp;</td>
		                <td><%#Eval("dowhat_nm")%>-<%#Eval("job_status_nm")%>&nbsp;</td>
		                <td nowrap><%#Eval("approve_desc")%>&nbsp;</td>
                    </tr>
			    </ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
    <br>
</FooterTemplate>
</asp:Repeater>

<div id="dialog"></div>

</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "*,2*";
        }
    });
</script>
