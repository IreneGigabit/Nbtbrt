<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCap = "國內案收發進度維護作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta21";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
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
    protected string cgrs = "";
    protected string cg = "";
    protected string rs = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connm = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper conni2 = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connm != null) connm.Dispose();
        if (conni2 != null) conni2.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        submitTask = ReqVal.TryGet("submittask").ToUpper();

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        connm = new DBHelper(Conn.MG).Debug(Request["chkTest"] == "TEST");
        conni2 = new DBHelper(Conn.account).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        cgrs = ReqVal.TryGet("cgrs").ToUpper();
        cg = ReqVal.TryGet("cgrs").Left(1);
        rs = ReqVal.TryGet("cgrs").Right(1);

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
        StrFormBtnTop += "<a href='" + HTProgPrefix + ".aspx?prgid=" + prgid + "'>[查詢畫面]</a>";
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";
    }

    private void QueryData() {
        SQL = "select 1 AS rank";
        SQL += ",*,''fseq,''urlasp,''a_last_date,''scode1_name,''lcg,''lrs ";
        SQL += " from vstep_dmt";
        SQL += " where 1=1";
        SQL += " and cg = '" + cg + "' and rs = '" + rs + "' ";
        SQL += " and main_rs_no = rs_no ";

        if (ReqVal.TryGet("seq") != "") {
            SQL += "AND Seq='" + ReqVal["seq"] + "' ";
        }
        if (ReqVal.TryGet("seq1") != "") {
            SQL += "AND Seq1='" + ReqVal["seq1"] + "' ";
        }
        if (ReqVal.TryGet("rs_no") != "") {
            SQL += "AND rs_no='" + ReqVal["rs_no"] + "' ";
        }
        if (ReqVal.TryGet("cust_area") != "") {
            SQL += "AND cust_area='" + ReqVal["cust_area"] + "' ";
        }
        if (ReqVal.TryGet("cust_seq") != "") {
            SQL += "AND cust_seq='" + ReqVal["cust_seq"] + "' ";
        }
        if (ReqVal.TryGet("ap_cname") != "") {
            SQL += "and ap_cname1 like'%" + ReqVal["ap_cname"] + "%' ";
        }
        if (ReqVal.TryGet("cappl_name") != "") {
            SQL += "and cappl_name like'%" + ReqVal["cappl_name"] + "%' ";
        }
        if (ReqVal.TryGet("rs_class") != "") {
            SQL += "AND rs_class='" + ReqVal["rs_class"] + "' ";
        }
        if (ReqVal.TryGet("rs_code") != "") {
            SQL += "AND rs_code='" + ReqVal["rs_code"] + "' ";
        }
        if (ReqVal.TryGet("act_code") != "") {
            SQL += "AND act_code='" + ReqVal["act_code"] + "' ";
        }
        if (ReqVal.TryGet("sstep_date") != "") {
            SQL += "AND step_date>='" + ReqVal["sstep_date"] + "' ";
        }
        if (ReqVal.TryGet("estep_date") != "") {
            SQL += "AND step_date<='" + ReqVal["estep_date"] + "' ";
        }
        if (ReqVal.TryGet("slast_date") != "" || ReqVal.TryGet("elast_date") != "") {
            string wSQL = "";
            if (ReqVal.TryGet("slast_date") != "") {
                wSQL += "AND ctrl_date>='" + ReqVal["slast_date"] + "' ";
            }
            if (ReqVal.TryGet("elast_date") != "") {
                wSQL += "AND ctrl_date<='" + ReqVal["elast_date"] + "' ";
            }
            string sSQL = "and convert(char,seq) + seq1 in ";
            sSQL += " (select distinct convert(char,seq) + seq1 from ctrl_dmt where ctrl_type = 'A1' {0} ";
            sSQL += " union ";
            sSQL += " select distinct convert(char,seq) + seq1 from resp_dmt where ctrl_type = 'A1' {0} )";

            SQL += string.Format(sSQL, wSQL);
        }
        if (ReqVal.TryGet("scode1") != "") {
            SQL += "AND dmt_scode='" + ReqVal["scode1"] + "' ";
        }

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "seq,seq1,step_grade"));
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }

        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "20"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            //收發種類
            if (cg == "C") {
                dr["lcg"] = "客";
            } else if (cg == "G") {
                dr["lcg"] = "官";
            } else {
                dr["lcg"] = "本";
            }
            if (rs == "R" || rs == "Z") {
                dr["lrs"] = "收";
            } else {
                dr["lrs"] = "發";
            }
            //案號
            dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
            //交辦畫面
            dr["urlasp"] = Sys.getCase11Aspx(prgid, dr.SafeRead("in_no", ""), dr.SafeRead("in_scode", ""), "Show");
            //尚未銷管法定期限
            dr["a_last_date"] = GetLastDate(dr);
            //洽案營洽
            dr["scode1_name"] = GetScode1Name(dr);
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    //尚未銷管法定期限
    protected string GetLastDate(DataRow dr) {
        string last_date = "";
            string rs_no = dr.SafeRead("rs_no", "");
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

    //營洽
    protected string GetScode1Name(DataRow dr) {
        string scode1_name = "";

        SQL = "select sc_name from scode where scode='" + dr.SafeRead("dmt_scode", "") + "'";
        objResult = cnn.ExecuteScalar(SQL);
        scode1_name = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
        return scode1_name;
    }
    
    //[作業]
    protected string GetLink(RepeaterItem Container) {
        string link = "";
        string editaspx = "";

        string act = "UDQ";
        if (cgrs == "CR") {//客收
            editaspx = "brta22_edit.aspx";
        } else if (cgrs == "GR") {//官收
            editaspx = "brta21_edit.aspx";
        } else if (cgrs == "GS") {//官發
            editaspx = "brta31_edit.aspx";
        } else if (cgrs == "CS") {//客發
            editaspx = "brta32_edit.aspx";
        } else if (cgrs == "ZS") {//本發
            act = "UQ";
            editaspx = "brta34_edit.aspx";
        }

        string chk_type = "";
        string send_status = "";
        if (cgrs == "GS") {
            //檢查array.account.plus_temp.chk_type='Y'表會計已確認不可刪除
            SQL = "select chk_type from plus_temp where branch='" + Session["seBranch"] + "' and dept='" + Session["dept"] + "'";
            SQL += " and rs_no='" + Eval("rs_no") + "' and chk_type='Y'";
            using (SqlDataReader dr = conni2.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    chk_type = dr.SafeRead("chk_type", "");
                } else {
                    chk_type = "N";
                }
            }
            //檢查sin09.simdbs.mgt_send.send_status='NN'or'NX'表總收發文未送件確認可修改，刪除有退件處理
            SQL = "select send_status from mgt_send where seq_area='" + Session["seBranch"] + "' and seq=" + Eval("seq") + " and seq1='" + Eval("seq1") + "' and rs_no='" + Eval("rs_no") + "'";
            using (SqlDataReader dr = connm.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    if (dr.SafeRead("send_status", "") == "NN" || dr.SafeRead("send_status", "") == "NX") {
                        send_status = "N";
                    } else {
                        send_status = "Y";
                    }
                }
            }
        } else {
            if (cgrs == "GR") {
                if (Eval("mg_step_grade").ToString() != "")
                    send_status = "Y";
            }
        }

        //[維護]
        if (act.IndexOf("U") > -1) {
            string linkU = "<a href=\"" + editaspx + "?submitTask=U&prgid=" + prgid + "&cgrs=" + cgrs + "&main_rs_no=" + Eval("main_rs_no") + "&rs_no=" + Eval("rs_no") + "&aseq=" + Eval("seq") + "&aseq1=" + Eval("seq1") + "&FrameBlank=50\" target=\"Eblank\">";
            if ((HTProgRight & 8) != 0) {
                if (cgrs == "GS") {
                    if (send_status != "Y") {
                        link += linkU + "[維護]</a>";
                    } else {
                        if ((HTProgRight & 256) != 0) {
                            link += linkU + "[維護](<font color=red>*權限C</font>)</a>";
                        } else {
                            link += "<font color=red>*</font>";
                        }
                    }
                } else {
                    link += linkU + "[維護]</a>";
                }
            }
        }

        //[刪除]
        if (act.IndexOf("D") > -1) {
            string linkD = "<a href=\"" + editaspx + "?submitTask=D&prgid=" + prgid + "&cgrs=" + cgrs + "&main_rs_no=" + Eval("main_rs_no") + "&rs_no=" + Eval("rs_no") + "&aseq=" + Eval("seq") + "&aseq1=" + Eval("seq1") + "&FrameBlank=50\" target=\"Eblank\">";
            if ((HTProgRight & 16) != 0 && Eval("step_grade").ToString() != "1") {
                if (cgrs == "GS") {
                    if (chk_type != "Y" && send_status == "") {
                        link += linkD + "[刪除]</a>";
                    } else {
                        if ((HTProgRight & 256) != 0 && Eval("step_grade").ToString() != "1") {
                            link += linkD + "[刪除](<font color=red>#權限C</font>)</a>";
                        } else {
                            link += "<font color=red>#</font>";
                        }
                    }
                } else {
                    if (send_status == "Y") {
                        if ((HTProgRight & 256) != 0 && Eval("step_grade").ToString() != "1") {
                            link += linkD + "[刪除]</a>";
                        } else {
                            link += "<font color=red>※</font>";
                        }
                    } else {
                        link += linkD + "[刪除]</a>";
                    }
                }
            }
        }
        
        //[查詢]
        if (act.IndexOf("Q") > -1) {
            link += "<a href=\"" + editaspx + "?submitTask=Q&prgid=" + prgid + "&cgrs=" + cgrs + "&main_rs_no=" + Eval("main_rs_no") + "&rs_no=" + Eval("rs_no") + "&aseq=" + Eval("seq") + "&aseq1=" + Eval("seq1") + "&FrameBlank=50\" target=\"Eblank\">[查詢]</a>";
        }
        
        //[列印]
        string step_date = Eval("step_date", "{0:yyyy/M/d}");
        if (cgrs == "GS") {
            link += "<a href=\"brta5m.aspx?prgid=brta5m&cgrs=gs&step_date=" + step_date + "&rs_no=" + Eval("rs_no") + "&FrameBlank=50\" target=\"Eblank\">[列印]</a>";
        } else if (cgrs == "GR") {
            link += "<a href=\"brta4m.aspx?prgid=brta4m&cgrs=gr&step_date=" + step_date + "&rs_no=" + Eval("rs_no") + "&FrameBlank=50\" target=\"Eblank\">[列印]</a>";
        }

        return link;
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
    <%#page.GetHiddenText("GoPage,PerPage,SetOrder")%>
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
 		            <td align="center" class="lightbluetable" nowrap>收/發</td>
		            <td align="center" nowrap>本所編號</td>
		            <td align="center" nowrap>進度<br>序號</td>
		            <td align="center" >案件名稱</td>
		            <td align="center">客戶名稱</td>
		            <td align="center" nowrap><span class=rsnotitle>收/發文</span>日期</td>
		            <td align="center"><span class=rsnotitle>收/發文</span>序號</td>
		            <td align="center"><span class=rsnotitle>收/發文</span>內容</td>
		            <td align="center" nowrap>尚未銷管之<br>法定期限</td>
			        <td align="center" nowrap>洽案營洽</td>
	                <td align="center" nowrap>作業</td>
                 </Tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			<ItemTemplate>
 		        <tr align="center" class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		            <td><%#Eval("lcg")%><%#Eval("lrs")%></td>
		            <td nowrap style="cursor:pointer;color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'" onclick="CapplClick('<%#Eval("seq")%>', '<%#Eval("seq1")%>')">
                        <%#Eval("fseq")%>
		            </td>
		            <td><%#Eval("step_grade")%></td>
		            <td><%#Eval("cappl_name")%></td>
			        <td><%#Eval("ap_cname1")%></td>
			        <td><%#Eval("step_date","{0:yyyy/M/d}")%></td>
	                <td><%#Eval("main_rs_no")%></td>
	                <td align="left"><%#Eval("rs_detail")%></td>
	                <td><%#Eval("a_last_date")%></td>
	                <td><%#Eval("scode1_name")%></td>
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
                    ◎<font color=blue size=2><font color=red>#</font>:表會計已確認或已官發至總管處。若會計已確認其中一筆規費或已官發至總管處，即不提供刪除功能，仍需刪除2008年10月前官發請敬會專案經理通知資訊部，2008年11月後官發請通知總管處。</font><br>
                    ◎<font color=blue size=2><font color=red>*</font>:表總管處已送件。若總管處已送件，即不提供維護功能，仍需維護請通知總管處。</font><br>
                    ◎<font color=blue size=2><font color=red>※</font>:表示官收確認產生的官收進度，即不提供刪除功能，仍需刪除請通知總管處及資訊部。</font><br>
                    <%if ((HTProgRight & 256) != 0) {%>
                      ◎<font color=blue size=2>若權限C才可維護刪除，當有規費(有入plus_temp)且已用電子送件官發，因plus_temp.mstat_flag在總收發文送件確認就給YE，系統無法刪除重入，所以要由後台處理plus_temp(如改案性、發文日期、交辦單號、金額)。</font><br>
                    <%}%>
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