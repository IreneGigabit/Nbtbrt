<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string HTProgCap = "案件交辦進度查詢";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Brt13";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string Title = "";

    protected string SQL = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected DataTable dt = new DataTable();

    protected string qs_dept = "";
    protected string apcode = "";
    protected string dowhat = "";
    protected string tblname = "";
    protected string todo_type = "";

    protected string name1 = "";
    protected string in_no = "";
    protected string case_no = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        qs_dept = (Request["qs_dept"] ?? "").ToLower();
        dowhat = (Request["dowhat"] ?? "").ToUpper();

        if (qs_dept == "t") {
            HTProgCode = "brt13";
            apcode = "'Si04W02','brt31','Brt51','brt63','brta38'";
            tblname = "todo_dmt";
            todo_type = "Ttodo";
        } else if (qs_dept == "e") {
            HTProgCode = "ext13";
            apcode = "'Si04W06','ext34','Ext51','Ext61','ext613','opte22'";
            tblname = "todo_ext";
            todo_type = "TEtodo";

            if (dowhat == "DI" || dowhat == "DE") {//智產or代收代付交辦帳款異動
                apcode += ",'Ext3e','Extd9','Extda'";
            } else {
                apcode += ",'Ext38','Ext81','Ext82','Ext52'";
            }
        }

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
        using (DBHelper conn = new DBHelper(Conn.btbrt, false).Debug(Request["chkTest"] == "TEST")) {
            //2010/5/17因應todo_dmt/todo_ext修改，因已處理流程未copy至todo_dmt/todo_ext，所以union查詢
            //2011/5/27因變更營洽todolist.in_scode及todo_ext.case_in_scode不會異動導致找不到資料且in_no唯一key,修改不加in_scode當條件
            SQL = "SELECT A.sqlno,a.apcode,a.step_date,a.in_no,a.case_no,a.resp_date,a.dowhat,a.job_scode,a.ap_scode,a.ctrl_date, B.sc_name AS name1, scode_1.sc_name AS name2, ";
            SQL += "(select sc_name from sysctrl.dbo.scode where scode=A.ap_scode) as ap_name, ";
            SQL += "(SELECT chrelname FROM relation WHERE A.job_status = chrelno AND chreltype = 'flow') AS status,'' as todo_name ";
            SQL += ",''dowhat_name,'' job_remark ";
            SQL += "FROM sysctrl.dbo.todolist A INNER JOIN sysctrl.dbo.scode B ON ";
            SQL += "A.in_scode = B.scode INNER JOIN sysctrl.dbo.scode scode_1 ON ";
            SQL += "A.job_scode = scode_1.scode ";
            SQL += "where A.in_no = '" + Request["in_no"] + "' AND syscode='" + Session["syscode"] + "' ";
            SQL += "AND apcode in (" + apcode + ") ";

            SQL += "union SELECT A.sqlno,a.apcode,a.in_date as step_date,a.in_no,a.case_no,a.resp_date,a.dowhat,a.job_scode,a.approve_scode as ap_scode,a.ctrl_date,";
            SQL += " B.sc_name AS name1, scode_1.sc_name AS name2, ";
            SQL += "(select sc_name from sysctrl.dbo.scode where scode=A.approve_scode) as ap_name, ";
            SQL += "(SELECT code_name FROM cust_code WHERE A.job_status = cust_code AND code_type = 'Tjob_status') AS status, ";
            SQL += "(select code_name from cust_code where a.dowhat = cust_code and code_type='" + todo_type + "') as todo_name ";
            SQL += ",''dowhat_name,'' job_remark ";
            SQL += "FROM " + tblname + " A INNER JOIN sysctrl.dbo.scode B ON ";
            SQL += "A.case_in_scode = B.scode INNER JOIN sysctrl.dbo.scode scode_1 ON ";
            SQL += "A.job_scode = scode_1.scode ";
            SQL += "WHERE A.in_no = '" + Request["in_no"] + "' AND (syscode='" + Session["syscode"] + "' or syscode='opt') ";
            SQL += "AND apcode in (" + apcode + ") order by step_date";

            if (prgid == "ext39" || prgid == "ext14" || prgid == "ext66") {
                SQL = "SELECT A.*, B.sc_name AS name1, scode_1.sc_name AS name2, ";
                SQL += "(select sc_name from sysctrl.dbo.scode where scode=A.ap_scode) as ap_name, ";
                SQL += "(SELECT chrelname FROM relation WHERE A.job_status = chrelno AND chreltype = 'flow') AS status,'' as todo_name ";
                SQL += ",''dowhat_name,'' job_remark ";
                SQL += "FROM sysctrl.dbo.todolist A INNER JOIN sysctrl.dbo.scode B ON ";
                SQL += "A.in_scode = B.scode INNER JOIN sysctrl.dbo.scode scode_1 ON ";
                SQL += "A.job_scode = scode_1.scode ";
                SQL += "WHERE  A.att_no = '" + Request["att_no"] + "' AND syscode='" + Session["syscode"];
                SQL += "' AND apcode in ('exta21','ext66','ext14','ext39') order by a.sqlno";
            }
            if (prgid == "ext3a") {
                SQL = "SELECT A.*, B.sc_name AS name1, scode_1.sc_name AS name2,a.approve_scode as ap_scode,exch_no as in_no, ";
                SQL += "'' as case_no,in_date as step_date,in_date as ctrl_date,resp_date as rec_date, ";
                SQL += "(select sc_name from sysctrl.dbo.scode where scode=A.approve_scode) as ap_name, ";
                SQL += "(SELECT chrelname FROM relation WHERE A.job_status = chrelno AND chreltype = 'flow') AS status,'' as todo_name ";
                SQL += ",''dowhat_name,'' job_remark ";
                SQL += "FROM todo_ext A INNER JOIN sysctrl.dbo.scode B ON ";
                SQL += "A.in_scode = B.scode INNER JOIN sysctrl.dbo.scode scode_1 ON ";
                SQL += "A.job_scode = scode_1.scode ";
                SQL += "WHERE  A.que_sqlno = '" + Request["que_sqlno"] + "' AND syscode='" + Session["syscode"];
                SQL += "' AND apcode in ('ext14','ext161') order by a.sqlno";
            }
            conn.DataTable(SQL, dt);
            //Sys.showLog(SQL);
            for (int i = 0; i < dt.Rows.Count; i++) {
                name1 = dt.Rows[i].SafeRead("name1", "");
                in_no = dt.Rows[i].SafeRead("in_no", "");
                case_no = dt.Rows[i].SafeRead("case_no", "");

                if (dt.Rows[i].SafeRead("todo_name", "") != "") {
                    dt.Rows[i]["dowhat_name"] = dt.Rows[i].SafeRead("todo_name", "");
                } else {
                    if (dt.Rows[i].SafeRead("dowhat", "") == "DI") {
                        dt.Rows[i]["dowhat_name"] = "智產交辦帳款異動";
                    } else if (dt.Rows[i].SafeRead("dowhat", "") == "DI") {
                        dt.Rows[i]["dowhat_name"] = "代收代付交辦帳款異動";
                    } else {
                        dt.Rows[i]["dowhat_name"] = "交辦";
                    }
                }

                SQL = "select approve_desc as job_remark from " + tblname + " where sqlno=" + dt.Rows[i]["sqlno"];
                object objResult = conn.ExecuteScalar(SQL);
                dt.Rows[i]["job_remark"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            }

            dataRepeater.DataSource = dt;
            dataRepeater.DataBind();
        }
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
		    <TD>營洽人員:<%#name1%></TD>
		    <TD>接洽序號:<%#in_no%></TD>
		    <TD>交辦序號:<%#case_no%></TD>
		    </Div>    
		    </TR> 
	    </table>	
        <br />
        <table style="display:<%#dt.Rows.Count==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="90%" align="center" id="dataList">
	        <thead>
                <TR>
	                <td align="center" class="lightbluetable">序號</td>
	                <td align="center" class="lightbluetable">分派日期</td>
	                <td align="center" class="lightbluetable">處理人員</td>
	                <td align="center" class="lightbluetable">處理事項</td>
	                <td align="center" class="lightbluetable">管制日期</td>
	                <td align="center" class="lightbluetable">完成日期</td>
	                <td align="center" class="lightbluetable">處理狀態</td>
	                <td align="center" class="lightbluetable">處理說明</td>
	            </TR>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			    <ItemTemplate>
                    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center">
	                    <td class="whitetablebg" align="center"><%#(Container.ItemIndex+1)%></td>
	                    <td class="whitetablebg" align="center"><%#Eval("step_date")%></td>
	                    <td class="whitetablebg" align="center">
                            <%#Eval("name2")%>
                            <%#Eval("ap_scode").ToString()!=""&&Eval("job_scode").ToString()!=Eval("ap_scode").ToString() ? "<font color=red>("+Eval("ap_name")+"代簽)</font>":""%>
                        </td>
	                    <td class="whitetablebg" align="center"><%#Eval("dowhat_name")%></td>
	                    <td class="whitetablebg" align="center"><%#Eval("ctrl_date")%></td>
	                    <td class="whitetablebg" align="center"><%#Eval("resp_date")%></td>
	                    <td class="whitetablebg" align="center"><%#Eval("status")%></td>
	                    <td class="whitetablebg" width="15%" align="center"><%#Eval("Job_remark")%></td>
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
