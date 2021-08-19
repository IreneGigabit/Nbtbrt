<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "電子送件資訊查詢作業";//;//HttpContext.Current.Request["prgname"];//功能名稱
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
    protected Dictionary<string, string> RS = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    protected string submitTask = "";
    protected string rs_no = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string step_grade = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connMG = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connMG != null) connMG.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        connMG = new DBHelper(Conn.MG).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        submitTask = ReqVal.TryGet("submittask").ToUpper();
        rs_no = (Request["rs_no"] ?? "").Trim();
        seq = (Request["seq"] ?? "").Trim();
        seq1 = (Request["seq1"] ?? "").Trim();
        step_grade = (Request["step_grade"] ?? "").Trim();

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = "電子送件資訊查詢作業";// myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            this.DataBind();
        }
    }

    private void PageLayout() {
        if (submitTask == "Q") {
            Lock["Qdisabled"] = "Lock";
        }

        if (submitTask == "Q") HTProgCap += "-<font color=blue>查詢</font>";

        SQL = "select * from vstep_dmt where seq='" + seq + "' and seq1='" + seq1 + "' and step_Grade='" + step_grade + "'";
        Sys.showLog(SQL);
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                RS["seq"] = dr.SafeRead("seq", "");
                RS["seq1"] = dr.SafeRead("seq1", "");
                RS["cg"] = dr.SafeRead("cg", "");
                RS["rs"] = dr.SafeRead("rs", "");
                RS["nstep_grade"] = dr.SafeRead("step_grade", "");
                RS["rs_detail"] = dr.SafeRead("rs_detail", "");
                RS["fees"] = dr.SafeRead("fees", "0");
                switch (dr.SafeRead("receipt_type", "").ToUpper()) {
                    case "P": RS["receipt_type"] = "紙本收據"; break;
                    case "E": RS["receipt_type"] = "電子收據"; break;
                }
                RS["fseq"] = Sys.formatSeq(RS["seq"], RS["seq1"], "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
            }
        }

        RS["mgt_send_way"] = "";
        RS["mgt_Send_status"] = "";
        RS["string_mgt_status"] = "";
        SQL = "select send_way,Send_status from mgt_send  where seq='" + seq + "' and seq1='" + seq1 + "' and br_step_grade='" + step_grade + "' and seq_area='" + Session["seBranch"] + "'";
        Sys.showLog(SQL);
        using (SqlDataReader dr = connMG.ExecuteReader(SQL)) {
            while (dr.Read()) {
                RS["mgt_send_way"] = dr.SafeRead("send_way", "").ToUpper();
                RS["mgt_Send_status"] = dr.SafeRead("send_status", "").ToUpper();
            }
        }
        switch (RS["mgt_Send_status"]) {
            case "":
            case "NN":
                if (RS["mgt_send_way"] == "E") {
                    RS["string_mgt_status"] = "總管處尚未送件";
                }
                break;
            case "SY": RS["string_mgt_status"] = "總管處已完成電子送件";
                break;
            case "YY":
                if (RS["mgt_send_way"] == "E" || RS["mgt_send_way"] == "EA") {
                    RS["string_mgt_status"] = "總管處尚未送件";
                }
                break;
            default:
                RS["string_mgt_status"] = "總管處尚未送件";
                break;
        }

        //親送:M  一般電子送件:E  年費電子送件:ES  註冊費電子送件:EA
        //A.總管處尚未送件			NN(E,ES,EA)
        //B.總管處已完成送件資料確認	SY(E)
        //C.總管處已完成電子送件		SY(ES,EA)
        //D.總管處已完成電子收據確認	YY(E,ES,EA)
        RS["esend_string"] = "";//電子送件時間

        if (RS["mgt_send_way"] == "E") {//一般電子送件資訊
            SQL = "select * from mgt_eset where seq='" + seq + "' and seq1='" + seq1 + "' and step_grade='" + step_grade + "' and seq_area='" + Session["seBranch"] + "'";
            Sys.showLog(SQL);
            using (SqlDataReader dr = connMG.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    RS["apply_no"] = dr.SafeRead("apply_no", "");//申請案號
                    RS["ipo_no"] = dr.SafeRead("ipo_no", "");//智慧局收文文號
                    RS["esend_string"] = dr.SafeRead("esend_date", "");//電子送件時間
                }
            }

        } else if (RS["mgt_send_way"] == "EA") {
            SQL = "select * from mgt_send where seq='" + seq + "' and seq1='" + seq1 + "' and br_step_grade='" + step_grade + "' and seq_area='" + Session["seBranch"] + "'";
            Sys.showLog(SQL);
            using (SqlDataReader dr = connMG.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    RS["apply_no"] = dr.SafeRead("apply_no", "");//申請案號
                }
            }
        }

        SQL = "select tsend_sqlno,* from send_mgt  where seq='" + seq + "' and seq1='" + seq1 + "' and br_step_grade='" + step_grade + "' and seq_area='" + Session["seBranch"] + "'";
        Sys.showLog(SQL);
        using (SqlDataReader dr = connMG.ExecuteReader(SQL)) {
            if (dr.Read()) {
                if (RS["mgt_send_way"] == "EA") {
                    RS["ipo_no"] = dr.SafeRead("ipo_no", "");//智慧局收文文號
                    RS["esend_string"] = dr.SafeRead("esend_date", "");//電子送件時間
                } else {
                    RS["receipt_no"] = dr.SafeRead("receipt_no", "");//電子收據號碼
                }
            }
        }

        if (Convert.ToInt32(RS.TryGet("fees", "0")) == 0) {
            RS["receipt_no"] = "無收據";
        } else {
            if (RS["mgt_Send_status"] == "YY") {
                if (RS.TryGet("receipt_no") == "") {
                    RS["receipt_no"] = "電子收據尚未補入";
                }
            } else {
                RS["receipt_no"] = "";
            }
        }
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
<uc1:head_inc_form runat="server" ID="head_inc_form" />
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
    <INPUT TYPE="hidden" id=seq name=seq value="<%=seq%>">
    <INPUT TYPE="hidden" id=seq1 name=seq1 value="<%=seq1%>">

     <table cellspacing="1" cellpadding="0" width="98%" border="0">
	    <tr>
	        <td valign="top" align="center">
			    <TABLE border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
		            <tr>
			            <TD align=center colspan=4 class=lightbluetable1>
                            <font color=white>電&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;子&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;送&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;件&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;訊</font>
			            </TD>
		            </tr>
		            <tr>
			            <TD align="center" class=whitetablebg colspan="4">
				            <font color ="bule" size = "4">
                                <%#RS.TryGet("fseq")%>
                                官方發文進度<%#RS.TryGet("nstep_grade")%>:<%#RS.TryGet("rs_detail")%>
				            </font>
			            </TD>
		            </tr>
		            <TR>
			            <TD class=lightbluetable align=right width="15%" >申請號碼：</TD>
			            <TD class=whitetablebg  colspan=3>
				            <input type="text" name="apply_no" size="10" value="<%#RS.TryGet("apply_no")%>" class="<%#Lock.TryGet("Qdisabled")%>">
			            </TD>
		            </TR>
		            <TR>
			            <TD class=lightbluetable align=right width="15%" >智慧局收文文號：</TD>
			            <TD class=whitetablebg >
				            <input type="text" name="ipo_no" size="20" value="<%#RS.TryGet("ipo_no")%>" class="<%#Lock.TryGet("Qdisabled")%>">
			            </TD>
			            <TD class=lightbluetable align=right width="10%">電子送件時間：</TD>
			            <TD class=whitetablebg>
				            <input type="text" name="esend_string" size="30" value="<%#RS.TryGet("esend_string")%>" class="<%#Lock.TryGet("Qdisabled")%>">
			            </TD>
		            </TR>
		            <TR>
			            <TD class=lightbluetable align=right width="10%">收據種類：</TD>
			            <TD class=whitetablebg colspan="3">
				            <input type="text" name="receipt_type" size="10" value="<%#RS.TryGet("receipt_type")%>" class="<%#Lock.TryGet("Qdisabled")%>">
			            </TD>
		            </TR>
		            <TR>
			            <TD class=lightbluetable align=right width="15%" >電子收據號碼：</TD>
			            <TD class=whitetablebg >
				            <input type="text" name="receipt_no" size="20" value="<%#RS.TryGet("receipt_no")%>" class="<%#Lock.TryGet("Qdisabled")%>">
			            </TD>
			            <TD class=lightbluetable align=right width="10%">目前送件狀態：</TD>
			            <TD class=whitetablebg>
				            <input type="text" name="string_mgt_status" size="44" value="<%#RS.TryGet("string_mgt_status")%>" class="<%#Lock.TryGet("Qdisabled")%>">
			            </TD>
		            </TR>
                </table>
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

<div align="left" style="color:blue">
◎說明：<br />
1. 目前送件狀態有：<br />
&nbsp;&nbsp;    A.總管處尚未送件<br />
&nbsp;&nbsp;    B.總管處已完成送件資料確認<br />
&nbsp;&nbsp;    C.總管處已完成電子送件<br />
&nbsp;&nbsp;    D.總管處已完成發文確認<br />
<br /><br />
2. 電子收據號碼，是在總管處已完成電子收據確認後，才會產生。<br /><br /><br />
3. 由於年費電子送件方式並非採用E-SET單筆送件，而是採用智慧局e網通批次匯入送件方式，<br />
因此上述送件資訊中有些欄位e網通並未即時提供，而是次/後日收到智慧局電子收據後，才會產生，<br />
例如：收文文號、送件時間、電子收據號碼。<br />
</div>

<div id="dialog"></div>

</body>
</html>


<script language="javascript" type="text/javascript">
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
</script>
