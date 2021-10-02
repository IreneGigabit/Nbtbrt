<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案接洽客戶後續查詢作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult = null;
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";

    protected string code_type = "";
    
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

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            QueryData();
            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";
        StrFormBtnTop += "<a href='" + HTProgPrefix + ".aspx?prgid=" + prgid + "'>[查詢畫面]</a>";

        code_type = Sys.getRsType();
    }

    private void QueryData() {
        DataTable dt = new DataTable();
        SQL = "select a.*,b.cappl_name as appl_name,b.step_date,b.mp_date,b.rs_detail";
        SQL += ",(select sc_name from sysctrl.dbo.scode where scode=b.dmt_scode) as sc_name,cust_seq";
        SQL += ",(SELECT code_name FROM cust_code WHERE code_type='TCASE_STAT' AND CUST_CODE = b.now_stat) AS now_stat_name ";
        SQL += ",(SELECT Code_name FROM Cust_code where Code_type='t92' and cust_code=a.job_case) AS job_casenm ";
        SQL += ",''fseq,''rmark_code,''job_nonm,''urlasp";
        SQL += " from grconf_dmt a ";
        SQL += "inner join vstep_dmt  as b on a.seq=B.seq and a.seq1=b.seq1 and a.step_grade=b.step_grade ";
        SQL += "where sales_status='YY' and job_type='case' ";
        
        if (ReqVal.TryGet("qSeq") != "") {
            SQL += " and a.seq = '" + Request["qSeq"] + "'";
        }
        if (ReqVal.TryGet("qSeq1") != "") {
            SQL += " and a.seq1 = '" + Request["qSeq1"] + "'";
        }
        if (ReqVal.TryGet("scode") != "") {
            SQL += " and b.dmt_scode = '" + Request["scode"] + "'";
        }
        if (ReqVal.TryGet("qcust_seq") != "") {
            SQL += " and b.cust_area='" + Request["qcust_area"] + "' and b.cust_seq= '" + Request["qcust_seq"] + "'";
        }
        if (ReqVal.TryGet("qjob_case") != "") {
            SQL += " and a.job_case = '" + Request["qjob_case"] + "'";
        }
        if (ReqVal.TryGet("qryjob_no") != "") {
            if (ReqVal.TryGet("qryjob_no") == "Y") {
                SQL += " and isnull(job_no,'')<>''";
            } else if (ReqVal.TryGet("qryjob_no") == "N") {
                SQL += " and isnull(job_no,'')=''";
            }
        }
        if (ReqVal.TryGet("kind_date") != "") {
            if (ReqVal.TryGet("sdate") != "") {
                SQL += " and a." + Request["kind_date"] + " >= '" + Request["sdate"] + "'";
            }
            if (ReqVal.TryGet("edate") != "") {
                SQL += " and a." + Request["kind_date"] + " <= '" + Request["edate"] + "'";
            }
        }

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "a.sconf_date,a.seq,a.seq1"));
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }

        Sys.showLog(SQL);
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "30"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            //案號
            dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));

            //收文內容
            if (dr.SafeRead("rs_detail", "").Length > 20) {
                dr["rs_detail"] = dr.SafeRead("rs_detail", "").CutData(20);
            }
            dr["urlasp"] = "Brt15_Edit.aspx?prgid=" + prgid + "&menu=Y&submittask=Q&grconf_sqlno=" + dr["grconf_sqlno"] + "&seq=" + dr["seq"] + "&seq1=" + dr["seq1"] + "&step_grade=" + dr["step_grade"] + "&closewin=Y";

            //接洽狀態
            if (dr.SafeRead("job_no", "") == "") {
                dr["job_nonm"] = "尚未接洽";
                //2012/2/17修改增加抓取客戶債信，因營洽交辦時會檢查客戶債信不良不能交辦，但從此作業進入遺漏判斷
                SQL = "select rmark_code from custz where cust_area='" + Session["seBranch"] + "' and cust_seq=" + dr["cust_seq"];
                objResult = conn.ExecuteScalar(SQL);
                dr["rmark_code"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            } else {
                dr["job_nonm"] = "已接洽";
            }
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    //[作業]
    protected string GetButton(RepeaterItem Container) {
        string job_no = Eval("job_no").ToString();
        string job_case = Eval("job_case").ToString();
        //string rtn = "<td nowrap align=\"center\" style=\"cursor: pointer;color:darkblue\" onmouseover=\"this.style.color='red'\" onmouseout=\"this.style.color='darkblue'\" ";
        string rtn = "";

        string ar_form = "", prt_code = "", new_form = "";
        if (job_case != "") {//有後續案性
            SQL = "SELECT Cust_code,form_name,remark FROM Cust_code";
            SQL += " WHERE Code_type = '" + code_type + "' AND form_name is not null AND Cust_code ='" + job_case + "' ";
            SQL += "order by cust_code";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    ar_form = dr.SafeRead("Cust_code", "");
                    prt_code = dr.SafeRead("form_name", "");
                    new_form = dr.SafeRead("remark", "");
                }
            }
        } else {
            SQL = "select b.rs_class,a.arcase_class from case_dmt a ";
            SQL += "inner join code_br b on a.arcase_type=b.rs_type and a.arcase=b.rs_code and b.cr='Y' ";
            SQL += "where a.in_no='" + job_no + "' ";
        }

        if (job_no == "") {
            rtn += " onClick=\"Formadd('" + Session["seBranch"] + "','" + Eval("cust_seq") + "','" + ar_form + "','" + prt_code + "','" + new_form + "','" + Eval("grconf_sqlno") + "','" + Eval("seq") + "','" + Eval("seq1") + "','" + Eval("rmark_code") + "')\" >";
            rtn += "[後續交辦]";
        } else {
            //rtn += " onClick=\"Formshow('" + Session["seBranch"] + "','" + Eval("cust_seq") + "','<%=toadd%>','" + Eval("job_no") + "')\" >";
            string urlasp =  Sys.getCaseDmt11Aspx(prgid, job_no, "", "Show");
            rtn += " onClick=\"Formshow('" + urlasp + "')\" >";
            rtn += "[查詢]";
        }
        //rtn += "</td>";

        return rtn;
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=prgid%> <%=HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>

<form style="margin:0;" id="regPage" name="regPage" method="post">
    <%#page.GetHiddenText("GoPage,PerPage,SetOrder,chktest")%>
    <div id="divPaging" style="display:<%#page.totRow==0?"none":""%>">
    <TABLE border=0 cellspacing=1 cellpadding=0 width="98%" align="center">
	    <tr>
		    <td colspan=2 align=center>
			    <font size="2" color="#3f8eba">
				    第<font color="red"><span id="NowPage"><%#page.nowPage%></span>/<span id="TotPage"><%#page.totPage%></span></font>頁
				    | 資料共<font color="red"><span id="TotRec"><%#page.totRow%></span></font>筆
				    | 跳至第
				    <select id="GoPage" name="GoPage" style="color:#FF0000"><%#page.GetPageList()%></select>
				    頁
				    <span id="PageUp" style="display:<%#page.nowPage>1?"":"none"%>">| <a href="javascript:void(0)" class="pgU" v1="<%#page.nowPage-1%>">上一頁</a></span>
				    <span id="PageDown" style="display:<%#page.nowPage<page.totPage?"":"none"%>">| <a href="javascript:void(0)" class="pgD" v1="<%#page.nowPage+1%>">下一頁</a></span>
				    | 每頁筆數:
				    <select id="PerPage" name="PerPage" style="color:#FF0000">
					    <option value="10" <%#page.perPage==10?"selected":""%>>10</option>
					    <option value="20" <%#page.perPage==20?"selected":""%>>20</option>
					    <option value="30" <%#page.perPage==30?"selected":""%>>30</option>
					    <option value="50" <%#page.perPage==50?"selected":""%>>50</option>
				    </select>
                    <input type="hidden" name="SetOrder" id="SetOrder" value="<%#ReqVal.TryGet("qryOrder")%>" />
			    </font><%#DebugStr%>
		    </td>
	    </tr>
    </TABLE>
    </div>
</form>

<div align="center" id="noData" style="display:<%#page.totRow==0?"":"none"%>">
	<font color="red">=== 目前無資料 ===</font>
</div>

<form style="margin:0;" id="reg" name="reg" method="post">
<INPUT TYPE="hidden" id=prgid name=prgid value="<%=prgid%>">
<INPUT TYPE="hidden" id=Ar_Form name=Ar_Form value="">
<INPUT TYPE="hidden" id=prt_code name=prt_code value="">
<INPUT TYPE="hidden" id=new_form name=new_form value="">
<INPUT TYPE="hidden" id=cust_area name=cust_area value="">
<INPUT TYPE="hidden" id=cust_seq name=cust_seq value="">
<INPUT TYPE="hidden" id=submitTask name=submitTask value="">
<INPUT TYPE="hidden" id=closeframe name=closeframe value="Y">
<INPUT TYPE="hidden" id=code_type name=code_type value="<%=code_type%>">
<INPUT TYPE="hidden" id=uploadtype name=uploadtype value="case">
<INPUT TYPE="hidden" id=qgrconf_sqlno name=qgrconf_sqlno value="">
<INPUT TYPE="hidden" id=in_no name=in_no value="">
<INPUT TYPE="hidden" id=country name=country value="">
<INPUT TYPE="hidden" id=seq name=seq value="">
<INPUT TYPE="hidden" id=seq1 name=seq1 value="">

<asp:Repeater id="dataRepeater" runat="server">
<HeaderTemplate>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	    <thead>
            <Tr>
	            <td  class="lightbluetable" align="center">作業</td>
	            <td  class="lightbluetable" align="center">本所編號</td>
	            <td  class="lightbluetable" width="12%" align="center">案件名稱</td>
	            <td  class="lightbluetable" align="center">營洽</td>
	            <td  class="lightbluetable" align="center">區所收文日</td>
	            <td  class="lightbluetable" align="center">總管處收文日</td>
	            <td  class="lightbluetable" align="center">收文內容</td>
	            <td  class="lightbluetable" align="center">後續案性</td>
	            <td  class="lightbluetable" align="center">接洽狀態</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
	                <td nowrap align="center" style="cursor:pointer;color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'" <%#GetButton(Container)%></td>
		            <td style="cursor:pointer;color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'" onclick="CapplClick('<%#Eval("seq")%>','<%#Eval("seq1")%>')"><%#Eval("fseq")%></td>
		            <td><%#Eval("appl_name")%></td>
		            <td><%#Eval("sc_name")%></td>
		            <td nowrap align=left ><%#Eval("step_date","{0:yyyy/M/d}")%></td>
		            <td nowrap align=left ><%#Eval("mp_date","{0:yyyy/M/d}")%></td>
		            <td><A href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("rs_detail").ToString().CutData(40)%></A></td>
		            <td align="center"><%#Eval("job_casenm")%></td>
		            <td nowrap><%#Eval("job_nonm")%></td>
				</tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
</FooterTemplate>
</asp:Repeater>
</form>

<div id="dialog"></div>

</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        $(".Lock").lock();
        $("input.dateField").datepick();
    });
    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //////////////////////
    //案件主檔查詢
    function CapplClick(pseq, pseq1) {
        window.showModalDialog(getRootPath() + "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + pseq + "&seq1=" + pseq1 + "&submittask=Q", "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
    }

    function Formadd(x, y, ar_from, prt_code, new_form, k, a, b, pmark_code) {
        if (ar_from == "") {
            return false;
        }
        //2012/2/17修改
        if (pmark_code.Left(2) == "E2") {
            alert("此客戶(" + x + y + ")債信不良，無法後續交辦！");
            return false;
        }
        $("#cust_area").val(x);
        $("#cust_seq").val(y);
        $("#submitTask").val("Add");
        $("#Ar_Form").val(ar_from);
        $("#prt_code").val(prt_code);
        $("#new_form").val(new_form);
        $("#qgrconf_sqlno").val(k);
        $("#seq").val(a);
        $("#seq1").val(b);
        reg.target = "Eblank";
        reg.action = "Brt11Add" + reg.new_form.value + ".aspx";
        reg.submit();
    }

    function Formshow(url) {
        reg.target = "Eblank";
        reg.action = url;
        reg.submit();
    }
</script>