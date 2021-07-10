<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCap = "國內案本所發文作業";//HttpContext.Current.Request["prgname"];//功能名稱
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

    protected string submitTask = "";
    protected string td_tscode = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        submitTask = ReqVal.TryGet("submittask").ToUpper();

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        if (ReqVal.TryGet("qrysstep_date") == "")
            ReqVal["qrysstep_date"] = DateTime.Today.AddMonths(-3).ToString("yyyy/M/d");
        if (ReqVal.TryGet("qryestep_date") == "")
            ReqVal["qryestep_date"] = DateTime.Today.ToString("yyyy/M/d");
      
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

        //營洽清單
        if ((HTProgRight & 64) != 0) {
            td_tscode += "<select id='qryscode1' name='qryscode1'>";
            td_tscode += Sys.getLoginGrpSales().Option("{scode}", "{scode}_{sc_name}");
            td_tscode += "</select>";
        } else {
            td_tscode = "<input id=qryscode1 name=qryscode1 readonly class=SEdit size=5 value='" + Session["scode"] + "'>" + Session["sc_name"];
        }
    }

    private void QueryData() {
        SQL = "select a.rs_sqlno,a.rs_no,a.seq,a.seq1,a.step_grade,a.step_date,a.case_no,a.zs_rs_sqlno,b.class_count,b.appl_name,a.rs_code,a.rs_class";
        SQL += ",c.service+c.add_service+c.oth_money as  service,c.oth_money,c.fees+c.add_fees as fees";
        SQL += ",c.service+c.add_service+c.oth_money+c.fees+c.add_fees as total,c.discount";
        SQL += ",c.arcase_type,c.arcase_class,c.arcase,b.in_scode,b.in_no";
        SQL += ",(select rs_detail from code_br where dept='" + Session["dept"] + "' and cr='Y' and rs_type=a.rs_type and rs_class=a.rs_class and rs_code=a.rs_code) as rs_codenm";
        SQL += ",(select rtrim(sc_name) from sysctrl.dbo.scode where scode=b.in_scode) as sc_name";
        SQL += ",(select isnull(rtrim(ap_cname1),'')+isnull(rtrim(ap_cname2),'') from apcust where cust_area=c.cust_area and cust_seq=c.cust_seq) as cust_name";
        SQL += ",''fseq,''urlasp,''last_date";
        SQL += " from step_dmt a,dmt_temp b, case_dmt c,cust_code d where 1=1";
        SQL += " and cg = 'C' and rs = 'R'";
        SQL += " and rs_no = main_rs_no ";
        SQL += " and b.case_sqlno = 0 ";
        SQL += " and a.case_no = c.case_no";
        SQL += " and b.in_scode = c.in_scode and b.in_no = c.in_no";
        SQL += " and a.rs_type=d.code_type and a.rs_class=d.cust_code and (d.ref_code is null or d.ref_code <>'A') ";
        SQL += " and cust_area = '" + Session["seBranch"] + "'";

        if (ReqVal.TryGet("qrysstep_date") != "") {
            SQL += "AND Step_Date>='" + ReqVal["qrysstep_date"] + "' ";
        }
        if (ReqVal.TryGet("qryestep_date") != "") {
            SQL += "AND Step_Date<='" + ReqVal["qryestep_date"] + "' ";
        }
        if (ReqVal.TryGet("qrycust_seq") != "") {
            SQL += "AND cust_seq='" + ReqVal["qrycust_seq"] + "' ";
        }
        if (ReqVal.TryGet("qryscode1") != "") {
            SQL += "AND b.in_scode ='" + ReqVal["qryscode1"] + "' ";
        }

        if (ReqVal.TryGet("qrySeq") != "") {
            SQL += "AND a.Seq in ('" + ReqVal.TryGet("qrySeq").Replace(",", "','") + "') ";
        }
        if (ReqVal.TryGet("qrySeq1") != "") {
            SQL += "AND a.Seq1='" + ReqVal["qrySeq1"] + "' ";
        }

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "a.case_no"));
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }

        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            //案號
            dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
            //交辦畫面
            dr["urlasp"] =  Sys.getCase11Aspx(prgid, dr.SafeRead("in_no", ""), dr.SafeRead("in_scode", ""), "Show");
            //尚未銷管法定期限
            dr["last_date"] = GetLastDate(dr);
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }
    
    //服務費
    protected string GetOthMoney(RepeaterItem Container) {
        string oth_money = Eval("oth_money").ToString();
        if (oth_money != "0" && oth_money != "") {
            return "<font color=red>*</font>";
        } else {
            return "";
        }
    }

    //尚未銷管法定期限
    protected string GetLastDate(DataRow dr) {
        string rs_no = dr.SafeRead("rs_no", "");
        string last_date = "";
        //取得最近且尚未銷管制的法定管制期限, 若距今兩日內到期者顯示為紅字
        SQL = "select min(ctrl_date) as last_date from ctrl_dmt where rs_no = '" + rs_no + "' and ctrl_type = 'A1'";
        objResult = conn.ExecuteScalar(SQL);
        string a_last_date = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
        if (a_last_date != "") {
            string tcolor = Sys.getSetting(Sys.GetSession("dept"), "1", Util.parseDBDate(a_last_date, "yyyy/M/d"));
            if (tcolor != "") {
                last_date = "<font color=" + tcolor + ">" + Util.parseDBDate(a_last_date, "yyyy/M/d") + "</font>";
            }
        } else {
            last_date = a_last_date;
        }

        SQL = "select count(*) as last_count from ctrl_dmt where rs_no = '" + rs_no + "' and ctrl_type = 'A1'";
        objResult = conn.ExecuteScalar(SQL);
        int cc = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
        if (cc > 1) {
            last_date += "<font color=blue>(" + cc + ")</font>";
        }
        return last_date;
    }
    
    //[作業]
    protected string GetLink(RepeaterItem Container) {
        string last_date = Eval("last_date").ToString();
        string zs_rs_sqlno = "0" + Eval("zs_rs_sqlno").ToString();

        //檢查此筆客收是否已本發
        string zs_flag = "N";
        if (Convert.ToInt32(zs_rs_sqlno) > 0) {
            zs_flag = "Y";
        }

        //若已本發，檢查可否維護
        string upd_flag = "N";
        if (zs_flag == "Y") {
            upd_flag = "Y";

            SQL = "select count(*) from step_dmt where rs_sqlno = '" + zs_rs_sqlno + "' and conf_date is not null";
            int cc = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
            if (cc > 0) {
                upd_flag = "N";
            }
        }
        string url = "";
        if (submitTask != "Q") {
            if ((HTProgRight & 8) != 0) {
                if (zs_flag == "N") {
                    if (last_date == "") {
                        url = "<img src=\"../images/alarm.gif\">";
                    } else {
                        url = "<a href=\"brta34_edit.aspx?submitTask=A&prgid=" + prgid + "&cgrs=CR&cr_rs_no=" + Eval("rs_no") + "&cr_rs_sqlno=" + Eval("rs_sqlno") + "&cr_step_grade=" + Eval("step_grade") + "&seq=" + Eval("seq") + "&seq1=" + Eval("seq1") + "&zs_rs_sqlno=" + Eval("zs_rs_sqlno") + "&case_no=" + Eval("case_no") + "\" target=\"Eblank\">[本發]</a>";
                    }
                } else {
                    if (upd_flag == "Y") {
                        url = "<a href=\"brta34_edit.aspx?submitTask=U&prgid=" + prgid + "&cgrs=CR&cr_rs_no=" + Eval("rs_no") + "&cr_rs_sqlno=" + Eval("rs_sqlno") + "&cr_step_grade=" + Eval("step_grade") + "&seq=" + Eval("seq") + "&seq1=" + Eval("seq1") + "&zs_rs_sqlno=" + Eval("zs_rs_sqlno") + "&case_no=" + Eval("case_no") + "\" target=\"Eblank\">[維護]</a>";
                    } else {
                        url = "<a href=\"brta34_edit.aspx?submitTask=Q&prgid=" + prgid + "&cgrs=CR&cr_rs_no=" + Eval("rs_no") + "&cr_rs_sqlno=" + Eval("rs_sqlno") + "&cr_step_grade=" + Eval("step_grade") + "&seq=" + Eval("seq") + "&seq1=" + Eval("seq1") + "&zs_rs_sqlno=" + Eval("zs_rs_sqlno") + "&case_no=" + Eval("case_no") + "\" target=\"Eblank\">[已本發]</a>";
                    }
                }
            }
        } else {
            if (zs_flag == "N") {
                url = "<a href=\"brta22_edit.aspx?submitTask=Q&prgid=" + prgid + "&cgrs=CR&cr_rs_no=" + Eval("rs_no") + "&cr_rs_sqlno=" + Eval("rs_sqlno") + "&cr_step_grade=" + Eval("step_grade") + "&seq=" + Eval("seq") + "&seq1=" + Eval("seq1") + "&case_no=" + Eval("case_no") + "\" target=\"Eblank\">[客收查詢]</a>";
            } else {
                url = "<a href=\"brta34_edit.aspx?submitTask=Q&prgid=" + prgid + "&cgrs=CR&cr_rs_no=" + Eval("rs_no") + "&cr_rs_sqlno=" + Eval("rs_sqlno") + "&cr_step_grade=" + Eval("step_grade") + "&seq=" + Eval("seq") + "&seq1=" + Eval("seq1") + "&zs_rs_sqlno=" + Eval("zs_rs_sqlno") + "&case_no=" + Eval("case_no") + "\" target=\"Eblank\">[本發查詢]</a>";
            }
        }
        
        return url;
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
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
<script language="javascript" type="text/javascript">
    var main = {};
    main.branch = "<%#Session["SeBranch"]%>";
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
</script>

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
    <table border="0" cellspacing="1" cellpadding="2" width="100%">
        <tr>
	        <td class="text9">
		        ◎客收日期: <input type="text" name="qrysstep_date" id="qrysstep_date" size="10" value="<%#ReqVal.TryGet("qrysstep_date")%>" class="dateField">
                		~ <input type="text" name="qryestep_date" id="qryestep_date" size="10" value="<%#ReqVal.TryGet("qryestep_date")%>" class="dateField">
	        </td>
		    <TD class=whitetablebg align=left >
                ◎客戶編號：
			    <INPUT type="text" id="qrycust_area" name="qrycust_area" size="1" class=SEdit readonly maxlength="1" value="<%#Session["seBranch"]%>">-
			    <INPUT type="text" id="qrycust_seq" name="qrycust_seq" size="6" maxlength="6">
		    </TD>
        </tr>
        <tr>
	        <td class="text9">
		        ◎洽案營洽: <%#td_tscode%>
	        </td>
	        <td class="text9">
		        ◎本所編號:<input type="text" name="qrySeq" id="qrySeq" size="30" value="">-<input type="text" name="qrySeq1" id="qrySeq1" size="2" value="">
	        </td>
	        <td class="text9">
		        <input type="button" value="查詢" class="cbutton" onClick="$('#GoPage').val('1');goSearch()" id="qrybutton" name="qrybutton">
		        <input type="hidden" name="prgid" id="prgid" value="<%=prgid%>">
	        </td>
        </tr>
    </table>

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
			    </font>
		    </td>
	    </tr>
    </TABLE>
    </div>
</form>

<div align="center" id="noData" style="display:<%#page.totRow==0?"":"none"%>">
	<font color="red">=== 目前無資料 ===</font>
</div>

<form style="margin:0;" id="reg" name="reg" method="post">
    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                  <Tr class="lightbluetable">
 		            <td align="center" class="lightbluetable" nowrap>交辦單號</td>
		            <td align="center" nowrap>本所編號</td>
		            <td align="center" nowrap>進度<br>序號</td>
		            <td align="center" nowrap>營洽</td>
		            <td align="center">客戶名稱</td>
		            <td align="center" nowrap>類別</td>
		            <td align="center" >案件名稱</td>
		            <td align="center" >案性</td>
		            <td align="center" nowrap>服務費</td>
		            <td align="center" nowrap>規費</td>
		            <td align="center" nowrap>合計</td>
		            <td align="center" nowrap>尚未銷管<br>法定期限</td>
		            <td align="center" nowrap>作業</td>
                 </Tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			<ItemTemplate>
 		        <tr align="center" class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
                    <td align="center" nowrap style="cursor:pointer;color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'" onclick="CaseNoClick('<%#Eval("urlasp")%>')">
                        <%#Eval("case_no")%>
		            </td>
		            <td nowrap style="cursor:pointer;color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'" onclick="CapplClick('<%#Eval("seq")%>', '<%#Eval("seq1")%>')">
                        <%#Eval("fseq")%>
		            </td>
		            <td><%#Eval("step_grade")%></td>
		            <td><%#Eval("sc_name")%></td>		
		            <td><%#Eval("cust_name")%></td>
		            <td nowrap>共<%#Eval("class_count")%>類</td>
		            <td><%#Eval("appl_name").ToString().ToUnicode().Left(20)%></td>
		            <td><%#Eval("rs_codenm")%></td>
		            <td><%#Eval("service")%><%#GetOthMoney(Container)%></td>
		            <td><%#Eval("fees")%></td>
		            <td><%#Eval("total")%></td>
		            <td><%#Eval("last_date")%></td>
		            <td><%#GetLink(Container)%></td>
	            </tr>
			</ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
	    <BR>

        <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td>
			    <div style="color:blue">
                    備註:<br>
                    ※<img src="../images/alarm.gif">表無管制法定期限，無法執行本發，若確定要本發，請於本筆客收進度管制一筆法定期限<br>
                    ※服務費加註 <font color=red>*</font> 者, 表示該金額內含轉帳費用<br>
			    </div>
		    </td>
            </tr>
	    </table>
	    <br>
    </FooterTemplate>
    </asp:Repeater>

    <%#DebugStr%>
</form>

<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="500" style="display:none"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        this_init();
    });

    function this_init() {
        $("select[id^='act_code_']").each(function(idx) {
            $(this).trigger("change");
        });

        $(".Lock").lock();
        $("input.dateField").datepick();
    }

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //////////////////////
    function CaseNoClick(url){
        //$('#dialog')
        //.html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
        //.dialog({autoOpen: true,modal: true,height: 550,width: 800,title: "交辦內容"});
        //window.open(url, "", "width=800,height=540,resizable=yes,scrollbars=no,status=0,top=80,left=200");
        //window.showModalDialog(url, "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
        window.parent.Eblank.location.href=url;
    }

    function CapplClick(pseq,pseq1){
        window.showModalDialog(getRootPath() + "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + pseq + "&seq1=" + pseq1 + "&submittask=Q", "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
    }

    //單筆確認
    function linkedit(pno,tseq,tseq1,task,att_sqlno,fseq,todo_sqlno){
        //var url = getRootPath() + "/brt6m/Brt63_edit.aspx?prgid=brta38&cgrs=gs&seq=" + tseq + "&seq1=" + tseq1 + "&branch=<%=Session["seBranch"]%>&SubmitTask=" + task + "&att_sqlno=" + att_sqlno + "&fseq=" + fseq + "&todo_sqlno=" + todo_sqlno;
        var url = getRootPath() + "/brt6m/Brt63_edit.aspx?prgid=brta38&cgrs=gs&seq=" + tseq + "&seq1=" + tseq1 + "&branch=<%=Session["seBranch"]%>&SubmitTask=" + task + "&att_sqlno=" + att_sqlno + "&fseq=" + fseq + "&todo_sqlno=" + todo_sqlno+ "&in_no=" + $("#in_no_"+pno).val()+ "&case_no=" + $("#case_no_"+pno).val();
        window.parent.Eblank.location.href=url;
    }
</script>