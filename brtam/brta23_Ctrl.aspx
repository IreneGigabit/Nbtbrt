<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>

<script runat="server">
    protected string HTProgCap = "國內案期限管制維護作業";//;//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";
    protected object objResult = null;

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    protected string submitTask = "";
    protected string sqlno = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string step_grade = "";
    protected string ctrl_type = "";
    protected string ctrl_date = "";
    protected string ctrl_remark = "";
    protected string resp_date = "";

    protected string html_ctrl = "", html_resp="";
    
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        submitTask = ReqVal.TryGet("submittask").ToUpper();
        sqlno = (Request["sqlno"] ?? "").Trim();
        seq = (Request["seq"] ?? "").Trim();
        seq1 = (Request["seq1"] ?? "").Trim();
        step_grade = (Request["step_grade"] ?? "").Trim();
        ctrl_type = (Request["ctrl_type"] ?? "").Trim();
        ctrl_date = (Request["ctrl_date"] ?? "").Trim();
        resp_date = DateTime.Today.ToShortDateString();

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            this.DataBind();
        }
    }

    private void PageLayout() {
        if (submitTask == "R") {
            Lock["Qdisabled"] = "Lock";
        }

        if (submitTask == "A") HTProgCap += "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap += "-<font color=blue>修改</font>";
        if (submitTask == "R") HTProgCap += "-<font color=blue>銷管</font>";

        if (submitTask != "Q") {
            if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0 || (HTProgRight & 16) > 0 || (HTProgRight & 64) > 0) {
                if (((HTProgRight & 4) > 0 && submitTask == "A") || ((HTProgRight & 8) > 0 && submitTask == "U") || ((HTProgRight & 8) > 0 && submitTask == "R")) {
                    StrFormBtn += "<input type=button id='button1' value='存　檔' class='cbutton bsubmit' onClick='formAddSubmit()'>\n";
                }
                StrFormBtn += "<input type=button value='重　填' class='cbutton' onclick='this_init()'>\n";
                StrFormBtn += "<input type=button value='關　閉' class='cbutton imgCls'>\n";
            }
        }

        html_ctrl = Sys.getCustCode("CT", "", "").Option("{cust_code}", "{code_name}", true, ctrl_type);
        html_resp = Sys.getCustCode("RESP_TYPE", "", "").Option("{cust_code}", "{code_name}");

        if (submitTask == "U" || submitTask == "R") {
            //取得管制資料
            SQL = "select ctrl_remark from ctrl_dmt ";
            SQL += " where sqlno = " + sqlno;
            SQL += "   and seq = " + seq;
            SQL += "   and seq1 = '" + seq1 + "'";
            SQL += "   and step_grade = '" + step_grade + "'";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    ctrl_remark = dr.SafeRead("ctrl_remark", "");
                } else {
                    Response.Write("資料有誤, 請洽系統管理人員!!");
                    Response.End();
                }
            }
        }
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="x-ua-compatible" content="IE=10">
<title><%#HTProgCap%></title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/toastr.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%#prgid%> <%#HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>

<form id="reg" name="reg" method="post">
    <INPUT TYPE="hidden" id=prgid name=prgid value="<%=prgid%>">
    <INPUT TYPE="hidden" id=submittask name=submittask value="<%=submitTask%>">
    <INPUT TYPE="hidden" id=sqlno name=sqlno value="<%=sqlno%>">

    <table cellspacing="1" cellpadding="0" width="98%" border="0">
	    <tr>
	        <td width="100%" colspan="6" height="245" valign="top" align="center">
				<TABLE id=tabbr1 border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="50%">
					<TR>
						<TD class=lightbluetable align=right nowrap>本所編號：</TD>
						<TD class=whitetablebg><%=Session["seBranch"]%><%=Sys.GetSession("dept").ToUpper()%>
							<input type=text size=6 maxlength="<%=Sys.DmtSeq%>" id=seq name=seq value="<%=seq%>" class="gSEdit" readonly>
							-<input type=text size=2 maxlength="<%=Sys.DmtSeq1%>" id=seq1 name=seq1 value="<%=seq1%>" class="gSEdit" readonly>
						</TD>
					</TR>
					<TR>
					    <TD class=lightbluetable align=right nowrap>進度序號：</TD>
						<TD class=whitetablebg>
							<input type=text size=6 maxlength=6 id=step_grade name=step_grade value="<%=step_grade%>" class="gSEdit" readonly>
						</TD>
					</TR>
				</Table>
                <br />
				<TABLE id=tabctrl border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
					<tr align="center" class="lightbluetable">
						<TD>管制種類</TD><TD>管制日期</TD><TD>管制說明</TD>
					</TR>
		            <tr>
                        <TD class=whitetablebg >
			                <SELECT name=ctrl_type id=ctrl_type class="<%#Lock.TryGet("Qdisabled")%>"><%=html_ctrl%></select>
		                </TD>
		                <TD class=whitetablebg >
                            <input type="text" id="ctrl_date" name="ctrl_date" size=10 maxlength=10 value="<%=ctrl_date%>" class="dateField <%#Lock.TryGet("Qdisabled")%>">
		                </TD>
		                <TD class=whitetablebg >
			                <input type="text" id="ctrl_remark" name="ctrl_remark" size=30 maxlength=30 value="<%=ctrl_remark%>" class="<%#Lock.TryGet("Qdisabled")%>">
		                </TD>
			        </tr>
	                <%if (submitTask == "R") {%>
					    <tr align="center" class="lightbluetable">
			                <TD>銷管方式</TD><TD>銷管日期</TD><TD>銷管說明</TD>
		                </TR>
		                <TR>
			                <TD class=whitetablebg >
					            <SELECT name=resp_type id=resp_type><%=html_resp%></select>
				            </TD>
			                <TD class=whitetablebg >
	                            <input type="text" id="resp_date" name="resp_date" size=10 maxlength=10 value="<%=resp_date%>" class="dateField">
			                </TD>
			                <TD class=whitetablebg >
				                <input type="text" id="resp_remark" name="resp_remark" size=30 maxlength=30>
			                </TD>
		                </TR>
	                <%}%>
				</Table>
                <br />
                <table border="0" width="98%" cellspacing="0" cellpadding="0">
                <tr>
                    <td width="100%" align="center">
                        <%#StrFormBtn%>
                    </td>
                </tr>
                </table>
		    </td>
	    </tr>
    </table>

    <%#DebugStr%>
</form>

<div id="dialog"></div>

</body>
</html>


<script language="javascript" type="text/javascript">
    var rpno = $("#pno").val();
    $(function () {
        this_init();
    });

    function this_init() {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        $("input.dateField").datepick();
        $(".Lock").lock();
    }

    //[存　檔]
    function formAddSubmit() {
        if ($("#submittask").val() == "A" || $("#submittask").val() == "U") {
            if (chkNull("管制種類", $("#ctrl_type"))) return false;
            if (chkNull("管制日期", $("#ctrl_date"))) return false;
        }
        if ($("#submittask").val() == "R") {
            if (chkNull("銷管方式", $("#resp_type"))) return false;
            if (chkNull("銷管日期", $("#resp_date"))) return false;
        }

        var url = "brta23_Update.aspx";
        if ($("#submittask").val() == "R") {
            var ans = confirm("是否確定銷管!!!");
            if (ans == true) {
                postForm(url, { task: "R", prgid: $("#prgid").val(), sqlno: $("#sqlno").val(), seq: $("#seq").val(), seq1: $("#seq1").val(), grade: $("#step_grade").val(), rtype: $("#resp_type").val(), rdate: $("#resp_date").val(), rmark: $("#resp_remark").val(), chkTest: $("#chkTest:checked").val() })
            }
        } else if ($("#submittask").val() == "A") {
            postForm(url, { task: "A", prgid: $("#prgid").val(), sqlno: $("#sqlno").val(), seq: $("#seq").val(), seq1: $("#seq1").val(), grade: $("#step_grade").val(), ctype: $("#ctrl_type").val(), cdate: $("#ctrl_date").val(), cmark: $("#ctrl_remark").val(), chkTest: $("#chkTest:checked").val() })
        } else if ($("#submittask").val() == "U") {
            postForm(url, { task: "U", prgid: $("#prgid").val(), sqlno: $("#sqlno").val(), seq: $("#seq").val(), seq1: $("#seq1").val(), grade: $("#step_grade").val(), ctype: $("#ctrl_type").val(), cdate: $("#ctrl_date").val(), cmark: $("#ctrl_remark").val(), chkTest: $("#chkTest:checked").val() })
        }
    }

    function postForm(url,param) {
        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        ajaxByPost(url, param)
        .complete(function (xhr, status) {
            if (status == "success") {
                if ($("#chkTest").prop("checked")) {
                    document.write(xhr.responseText);
                } else {
                    eval(xhr.responseText);
                    parent.goSearch();//主畫面重新整理
                    $(".imgCls").click();
                }
            } else if (status == "error") {
                document.write(xhr.responseText);
            }
        });
    }
</script>
