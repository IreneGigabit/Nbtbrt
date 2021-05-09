<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string HTProgCap = "檢查國內所及總管處檢核資料";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string Title = "";

    protected string SQL = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();

    protected string temp_rs_sqlno = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string domark = "";
    protected string smgt_temp_mark = "";
    
   protected string fseq = "", appl_name = "";
   protected string cansave = "Y", havectrl="N";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

        temp_rs_sqlno = Request["temp_rs_sqlno"] ?? "";
        seq = Request["seq"] ?? "";
        seq1 = Request["seq1"] ?? "";
        domark = Request["domark"] ?? "";
        smgt_temp_mark = (Request["smgt_temp_mark"] ?? "").ToUpper();

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        Title = myToken.Title;

        if (HTProgRight >= 0) {
            QueryData();

            this.DataBind();
        }
    }

    private void QueryData() {
        DataTable dtHead = new DataTable();
        SQL = "select a.* from dmt a where a.seq = '" + seq + "' and a.seq1 = '" + seq1 + "'";
        
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                dr.Close();
                
                fseq = Sys.formatSeq(seq, seq1, "", Sys.GetSession("SeBranch"), Sys.GetSession("dept"));
                appl_name = dr.SafeRead("appl_name", "");

                if (domark == "A" || domark == "B") {//需立子案/已立案
                    SQL = "select a.gno_date as mg_apply_date,a.gno as mg_apply_no,b.issue_date as mg_issue_date,b.issue_no2 as mg_issue_no,b.issue_no3 as mg_rej_no,b.end_date as mg_end_date ";
                    SQL += ",''apply_date_color,''apply_no_color,''issue_no_color,''rej_no_color,''end_date_color ";
                    SQL += " from mgt_temp b inner join step_mgt_temp a on a.temp_rs_sqlno=b.temp_rs_sqlno ";
                    SQL += " where b.temp_rs_sqlno=" + temp_rs_sqlno;
                } else {
                    SQL = "select b.apply_date as mg_apply_date,b.apply_no as mg_apply_no,b.issue_date as mg_issue_date,b.issue_no2 as mg_issue_no,b.issue_no3 as mg_rej_no,b.end_date as mg_end_date ";
                    SQL += ",''apply_date_color,''apply_no_color,''issue_no_color,''rej_no_color,''end_date_color ";
                    SQL += " from mgt_temp b ";
                    SQL += " where b.temp_rs_sqlno=" + temp_rs_sqlno;
                }
                conn.DataTable(SQL, dtHead);

                if (dtHead.Rows.Count > 0) {
                    DataRow dr0 = dtHead.Rows[0];
                    if (ReqVal.TryGet("apply_date") != dr0.GetDateTimeString("mg_apply_date", "yyyy/M/d")) {
                        dr0["apply_date_color"] = "style='color:red'";
                        cansave = "N";
                    }
                    if (ReqVal.TryGet("apply_no") != dr0.SafeRead("mg_apply_no", "")) {
                        dr0["apply_no_color"] = "style='color:red'";
                        cansave = "N";
                    }
                    if (smgt_temp_mark != "IS") {
                        if (ReqVal.TryGet("issue_no") != dr0.SafeRead("mg_issue_no", "")) {
                            dr0["issue_no_color"] = "style='color:red'";
                            cansave = "N";
                        }
                    }
                    if (ReqVal.TryGet("rej_no") != dr0.SafeRead("mg_rej_no", "")) {
                        dr0["rej_no_color"] = "style='color:red'";
                        cansave = "N";
                    }
                    if (ReqVal.TryGet("end_date") != dr0.GetDateTimeString("mg_end_date", "yyyy/M/d")) {
                        dr0["end_date_color"] = "style='color:red'";
                        cansave = "N";
                    }
                }
            }
        }
        headRepeater.DataSource = dtHead;
        headRepeater.DataBind();


        DataTable dtCtrl = new DataTable();
        SQL = "select mg_step_grade,ctrl_type,ctrl_date,ctrl_remark,null as resp_date,null as mg_resp_step_grade,(select code_name from cust_code where code_type='ct' and cust_code=ctrl_mgt_temp.ctrl_type) as ctrl_type_name ";
        SQL += "from ctrl_mgt_temp where temp_rs_sqlno=" + temp_rs_sqlno + " and ctrl_type like 'A%' ";
        SQL += "union select mg_step_grade,ctrl_type,ctrl_date,ctrl_remark,resp_date,mg_resp_step_grade,(select code_name from cust_code where code_type='ct' and cust_code=resp_mgt_temp.ctrl_type) as ctrl_type_name ";
        SQL += "from resp_mgt_temp where temp_rs_sqlno=" + temp_rs_sqlno + " and ctrl_type like 'A%' ";
        conn.DataTable(SQL, dtCtrl);
        if (dtCtrl.Rows.Count > 0) {
            havectrl = "Y";

        }
        ctrlRepeater.DataSource = dtCtrl;
        ctrlRepeater.DataBind();
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="x-ua-compatible" content="IE=10">
<title><%=HTProgCap%></title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/toastr.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=prgid%><%=Title%>】<span style="color:blue"><%=HTProgCap%></span></td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <!--a class="imgCls" href="javascript:void(0);" >[關閉視窗]</a-->
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>

<asp:Repeater id="headRepeater" runat="server">
<ItemTemplate>
    <table border=0 width="100%" cellspacing="1" cellpadding="1" class="bluetable">
	    <TR>
		    <TD align=center colspan=6 class=lightbluetable1><font color=white>國&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;內&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;所&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;及&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;總&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;收&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;發&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;主&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;檔&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;料</font></TD>
	    </TR>
	    <tr class="lightbluetable" height="20">
		    <td align="center" nowrap>欄位</td>
		    <td align="center" nowrap>國內所</td>
		    <td align="center" nowrap>總收發</td>
	    </tr>
	    <tr>
		    <td align="right" class="lightbluetable3" nowrap width="20%">本所編號：</td>
		    <td align="left" class="sfont9"><%=fseq%></td>
		    <td align="left" class="sfont9"><%=fseq%></td>
	    </tr>
	    <tr>
		    <td align="right" class="lightbluetable3" nowrap>案件中文名稱：</td>
		    <td align="left" class="sfont9" ><%=appl_name%></td>
		    <td align="left" class="sfont9" ><%=appl_name%></td>
	    </tr>
	    <tr>
		    <td align="right" class="lightbluetable3" nowrap>申請日期：</td>
		    <td align="left" class="sfont9" <%#Eval("apply_date_color")%>><%=ReqVal.TryGet("apply_date")%></td>
		    <td align="left" class="sfont9" <%#Eval("apply_date_color")%>><%#Eval("mg_apply_date", "{0:yyyy/M/d}")%></td>
	    </tr>
	    <tr>
		    <td align="right" class="lightbluetable3" nowrap>申請號碼：</td>
		    <td align="left" class="sfont9" <%#Eval("apply_no_color")%>><%=ReqVal.TryGet("apply_no")%></td>
		    <td align="left" class="sfont9" <%#Eval("apply_no_color")%>><%#Eval("mg_apply_no")%></td>
	    </tr>
	    <tr>
		    <td align="right" class="lightbluetable3" nowrap>註冊號碼：</td>
		    <td align="left" class="sfont9" <%#Eval("issue_no_color")%>><%=ReqVal.TryGet("issue_no")%></td>
		    <td align="left" class="sfont9" <%#Eval("issue_no_color")%>><%#Eval("mg_issue_no")%></td>
	    </tr>
	    <tr>
		    <td align="right" class="lightbluetable3" nowrap>核駁號碼：</td>
		    <td align="left" class="sfont9" <%#Eval("rej_no_color")%>><%=ReqVal.TryGet("rej_no")%></td>
		    <td align="left" class="sfont9" <%#Eval("rej_no_color")%>><%#Eval("mg_rej_no")%></td>
	    </tr>
	    <tr>
		    <td align="right" class="lightbluetable3" nowrap>結案日期：</td>
		    <td align="left" class="sfont9" <%#Eval("end_date_color")%>><%=ReqVal.TryGet("end_date")%></td>
		    <td align="left" class="sfont9" <%#Eval("end_date_color")%>><%#Eval("mg_end_date", "{0:yyyy/M/d}")%></td>
	    </tr>
    </table>
</ItemTemplate>
</asp:Repeater>

    <asp:Repeater id="ctrlRepeater" runat="server">
    <HeaderTemplate>
        <TABLE id=tabctrl_fext border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
	        <TR>
		        <TD align=center colspan=6 class=lightbluetable1><font color=white>總&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;收&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;發&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;管&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;制&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;料</font></TD>
	        </TR>
	        <tr class="lightbluetable" align="center">
		        <TD align="center">總收發進度</TD>
                <TD align="center">管制種類</TD>
                <TD align="center">管制日期</TD>
		        <TD align="center">說明</TD>
                <TD align="center">銷管日期</TD>
		        <TD align="center">銷管進度</TD>
	        </TR>
    </HeaderTemplate>
	<ItemTemplate>
	        <tr class="whitetablebg">
	            <td align="center"><%#Eval("mg_step_grade")%></td>
		        <td align="center"><%#Eval("ctrl_type_name")%></td>
		        <td align="center"><%#Eval("ctrl_date", "{0:yyyy/M/d}")%></td>
		        <td align="center"><%#Eval("ctrl_remark")%></td>
		        <td align="center"><%#Eval("resp_date", "{0:yyyy/M/d}")%></td>
		        <td align="center"><%#Eval("mg_resp_step_grade")%></td>
	        </tr>    
	</ItemTemplate>
    <FooterTemplate>
        </table>
</FooterTemplate>
</asp:Repeater>

<br>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
        <td width="100%" align="center">
		    <input type=button name="button1" value="關閉" class="greenbutton" onClick="winclose()">
	    </td>
	</tr>
</table>

<div id="dialog"></div>

</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }
    });

    //[關閉]
    function winclose() {
        $("#cansave", window.opener.document).val("<%=cansave%>");
        $("#havectrl", window.opener.document).val("<%=havectrl%>");
        window.close();
    };
</script>
