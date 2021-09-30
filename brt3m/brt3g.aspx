<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "轉案案件簽核(轉出)";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt3g";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    protected string qs_dept = "";
    protected string todo_tblnm = "";
    protected string td_jscode = "";
    protected string td_tscode = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        qs_dept = (Request["qs_dept"] ?? "").ToLower();
        
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
        if ((HTProgRight & 2) > 0) {
            StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"查　詢\" class=\"cbutton bsubmit\" />\n";
            StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
        }

        if (qs_dept == "t") {
            todo_tblnm = "todo_dmt";
        } else {
            todo_tblnm = "todo_ext";
        }
        
        //Sys.getGrpidDown("N", "T110").ShowTable();
        //Sys.getGrpidDown("N", "T100").ShowTable();
        //Sys.getGrpidDown("N", "T000").ShowTable();
        //Sys.getGrpidDown("N", "000").ShowTable();
        //Sys.getGrpidDown("N", "zzz").ShowTable();
        //Sys.getGrpidDown("N", "").ShowTable();

        //Sys.getGrpidUp("N", "").ShowTable();
        //Sys.getGrpidUp("N", "zzz").ShowTable();
        //Sys.getGrpidUp("N", "000").ShowTable();
        //Sys.getGrpidUp("N", "T000").ShowTable();
        //Sys.getGrpidUp("N", "T100").ShowTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            //主管清單
            DataTable dt = new DataTable();
            if ((HTProgRight & 256) != 0) {
                SQL = "select a.job_scode,b.sc_name from " + todo_tblnm + " a ";
                SQL += "inner join sysctrl.dbo.scode b on a.job_scode=b.scode ";
                SQL += "where a.job_status='NN' and  (a.dowhat='TRAN_NM') and a.syscode='" + Session["syscode"] + "' ";
                SQL += "group by a.job_scode,b.sc_name";
            } else {
                SQL = "select A.job_scode,d.sc_name from " + todo_tblnm + " a ";
                SQL += "left outer join sysctrl.dbo.scode_group C on a.job_scode = c.scode and c.GrpClass=a.branch ";
                SQL += "left outer join sysctrl.dbo.grpid B on c.grpclass=b.grpclass and c.grpid=b.grpid and (substring(b.grpid,1,1)='T' or substring(b.grpid,1,3)='000' or substring(b.grpid,1,1)='A' ) ";
                SQL += "inner join sysctrl.dbo.scode D on a.job_scode=d.scode ";
                SQL += "where a.job_status='NN' and (a.dowhat='TRAN_NM') and a.syscode='" + Session["syscode"] + "' ";
                SQL += "group by a.job_scode,D.sc_name";
            }
            Sys.showLog(SQL);
            conn.DataTable(SQL, dt);

            if (dt.Rows.Count > 0) {
                if ((HTProgRight & 256) != 0) {
                    td_jscode += dt.Option("{job_scode}", "{sc_name}", false);
                } else {
                    for (int i = 0; i < dt.Rows.Count; i++) {
                        if (Convert.ToInt32(dt.Rows[i].SafeRead("grplevel", "0")) > Convert.ToInt32(Sys.GetSession("se_grplevel"))) {
                            if (dt.Rows[i].SafeRead("job_scode", "") != Sys.GetSession("scode")) {
                                td_jscode += "<option value='" + dt.Rows[i]["job_scode"] + "'>" + dt.Rows[i]["sc_name"] + "</option>";
                            }
                        } else {
                            if ((HTProgRight & 128) != 0) {//權限B代理區所主管
                                //if (dt.Rows[i].SafeRead("grpid", "") == "000") {
                                if (Convert.ToInt32(dt.Rows[i].SafeRead("grplevel", "0")) >= 1) {
                                    if (dt.Rows[i].SafeRead("job_scode", "") != Sys.GetSession("scode")) {
                                        td_jscode += "<option value='" + dt.Rows[i]["job_scode"] + "'>" + dt.Rows[i]["sc_name"] + "</option>";
                                    }
                                }
                            } else if ((HTProgRight & 64) != 0) {//權限A代理部門主管
                                //if (dt.Rows[i].SafeRead("grpid", "") == "T000") {
                                if (Convert.ToInt32(dt.Rows[i].SafeRead("grplevel", "0")) >= 2) {
                                    if (dt.Rows[i].SafeRead("job_scode", "") != Sys.GetSession("scode")) {
                                        td_jscode += "<option value='" + dt.Rows[i]["job_scode"] + "'>" + dt.Rows[i]["sc_name"] + "</option>";
                                    }
                                }
                            }
                            if (dt.Rows[i].SafeRead("job_scode", "") == Sys.GetSession("scode")) {
                                td_jscode += "<option value='" + dt.Rows[i]["job_scode"] + "'>" + dt.Rows[i]["sc_name"] + "</option>";
                            }
                        }
                    }
                }
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
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
    <input type=hidden name=qs_dept id=qs_dept value=<%=qs_dept%>>

    <div id="id-div-slide">
        <table id="qryForm" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="70%" align="center">	
            <tr>
		        <td class="lightbluetable" align="right">簽核主管:</td>
		        <td class="whitetablebg" align="left">
                    <select id='job_scode' name='job_scode' onchange="searchScode(this.value,'from_scode','TRANt0')" >
                        <%#td_jscode%>
                    </select>
                </td>
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right">案件營洽:</td>
		        <td class="whitetablebg" align="left">
                    <select id='from_scode' name='from_scode'></select>
		        </td>
	        </tr>
	        <tr>
                <td class="lightbluetable" align="right">送簽日期：</td>
		        <td class="whitetablebg" align="left" >
			        <input type="text" id="sdate" name="sdate" size="10" class="dateField">～
			        <input type="text" id="edate" name="edate" size="10" class="dateField">
		        </td>
	        </TR>

        </table>
        <br>
        <%#DebugStr%>
        <table id="tabBtn" border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
	        <tr><td width="100%" align="center">
			    <%#StrFormBtn%>
	        </td></tr>
        </table>
    </div>
</form>

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

        $("#job_scode").triggerHandler("change");
    }

    //[查詢]
    $("#btnSrch").click(function (e) {
        if (ChkDate($("#sdate")[0])) return false;
        if (ChkDate($("#edate")[0])) return false;

        if ($("#sdate").val() != "" && $("#edate").val() != "") {
            if (CDate($("#sdate").val()).getTime() > CDate($("#edate").val()).getTime()) {
                alert("起日不得大於迄日!!");
                return false;
            }
        }

        reg.action = "<%=HTProgPrefix%>_List.aspx";
        //reg.target = "Eblank";
        reg.submit();
    });


    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    function searchScode(fld1, fld2, fld3) {
        var chktest = ($("#chkTest:checked").val() || "");

        var url = getRootPath() + "/brt3m/brt3_Scode.aspx?fld1=" + fld1 + "&fld2=" + fld2 + "&fld3=" + fld3 + "&chkTest=" + chktest;
        ajaxScriptByGet("營洽清單", url);
    }
</script>
