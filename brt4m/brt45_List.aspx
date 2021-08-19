<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內商標新申請案及延展案件數統計";//HttpContext.Current.Request["prgname"];//功能名稱
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

    protected bool ctrlquery = false;
    protected string qrytodo = "";
    protected string qrybranch = "";
    protected string qrystep_dates = "",qrystep_datee = "";
    protected string qrystep_yy = "",qrystep_mm = "";

    protected string html_branch = "";
    protected int fund_money = 0;
    protected int cnti = 0;
    protected int totT_A1_cnt = 0;//合計_內商新申請案件數
    protected int totT_A4_cnt = 0;//合計_內商延展案件數
    protected int totTE_A1_cnt = 0;//合計_外商新申請案件數
    protected int totTE_A5_cnt = 0;//合計_外商延展案件數
    protected int tot_cnt = 0;//合計_合計件數

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

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

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
        qrytodo=ReqVal.TryGet("qrytodo");
        if (qrytodo=="")qrytodo="qry";

        qrybranch = ReqVal.TryGet("qrybranch");
        if (qrybranch == "") qrybranch = Sys.GetSession("seBranch");

        qrystep_dates=ReqVal.TryGet("qrystep_dates");
        if (qrystep_dates=="") qrystep_dates=DateTime.Today.AddMonths(-1).ToString("yyyy/M/1");

        qrystep_datee=ReqVal.TryGet("qrystep_datee");
        if (qrystep_datee=="") qrystep_datee=DateTime.Now.AddDays(DateTime.Now.Day * -1).ToString("yyyy/M/d");

        qrystep_yy=ReqVal.TryGet("qrystep_yy");
        if (qrystep_yy=="") {
            if (qrystep_dates!=""){
                qrystep_yy=DateTime.Parse(qrystep_dates).Year.ToString();
            }else if (qrystep_datee!=""){
                  qrystep_yy=DateTime.Parse(qrystep_datee).Year.ToString();
          }
        }

        qrystep_mm=ReqVal.TryGet("qrystep_mm");
        if (qrystep_mm == "") {
            if (qrystep_dates != "") {
                qrystep_mm = DateTime.Parse(qrystep_dates).Month.ToString();
            } else if (qrystep_datee != "") {
                qrystep_mm = DateTime.Parse(qrystep_datee).Month.ToString();
            }
        }
        
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";
        if (qrytodo == "process") {
            if ((HTProgRight & 4) > 0) {
                StrFormBtn += "<br>\n";
                StrFormBtn += "<input type=button name='btnAdd' value='產生調整資料' class='c1button bsubmit' onClick='formAddSubmit()' >\n";
            }
            if ((HTProgRight & 16) > 0 && (HTProgRight & 256) > 0) {
                StrFormBtn += "<input type=button name='btnDel' value='刪除本月調整資料' class='redbutton bsubmit' onClick='formDelSubmit()' >\n";
            }
        }
        
        if (ReqVal.TryGet("ctrlquery") == "Y") {
            ctrlquery = true;
        }

        //單位
        if ((HTProgRight & 64) != 0) {
            SQL = "select branch,branchname from branch_code where mark='Y' and branch<>'J' order by sort";
            html_branch = Util.Option(conn, SQL, "{branch}", "{branchname}", false, qrybranch);
            if (qrytodo == "qry") {
                html_branch += "<option value='A'>全所</option>";
            }
        } else {
            html_branch += "<option value='"+Session["seBranch"]+"'>"+Session["SeBranchName"]+"</option>";
        }
    }

    private void QueryData() {
        //抓取提撥基金會單價
		SQL="select ref_code from cust_code where code_type='fund_money' and cust_code='T'";
        objResult = conn.ExecuteScalar(SQL);
        fund_money = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
           
        if (qrybranch != "A") {
            SQL = "select branch,branchname from branch_code ";
            SQL += "where mark='Y' and branch<>'J' and branch='" + qrybranch + "'";
            SQL += "order by sort";
        } else {
            SQL = "select branch,branchname from branch_code where mark='Y' and branch<>'J' order by sort";
        }
        DataTable dt = new DataTable();
        cnn.DataTable(SQL, dt);

        if (ctrlquery) {
            dataRepeater.DataSource = dt;
            dataRepeater.DataBind();
        }
    }

    //區所明細
    protected void dataRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        //if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            string branch = DataBinder.Eval(e.Item.DataItem,"branch").ToString();

            Repeater dtlRepeater = (Repeater)e.Item.FindControl("dtlRepeater");
            if ((dtlRepeater != null)) {
                using (DBHelper connbr = new DBHelper(Conn.brp(branch)).Debug(Request["chkTest"] == "TEST")) {
                    string wSQL = "";
                    if (qrystep_dates != "") {
                        wSQL += " and a.step_date >= '" + qrystep_dates + "'";
                    }
                    if (qrystep_datee != "") {
                        wSQL += " and a.step_date <= '" + qrystep_datee + "'";
                    }

                    SQL = "select '" + branch + "'branch,scode1,scode1nm,''tclass ";
                    SQL += ",sum(T_A1_cnt)T_A1_cnt,sum(T_A4_cnt)T_A4_cnt,sum(TE_A1_cnt)TE_A1_cnt,sum(TE_A5_cnt)TE_A5_cnt ";
                    SQL += ",sum(T_A1_cnt+T_A4_cnt+TE_A1_cnt+TE_A5_cnt) tot_cnt ";
                    SQL += "from ( ";
                    SQL += "select 'T' as dept,a.dmt_scode as scode1,(select sc_name from sysctrl.dbo.scode where scode=a.dmt_scode) as scode1nm ";
                    SQL += ",case when rs_class in('A0','A1') then 1 else 0 end T_A1_cnt ";
                    SQL += ",case when rs_class in('A4') then 1 else 0 end T_A4_cnt ";
                    SQL += ",0 TE_A1_cnt ";
                    SQL += ",0 TE_A5_cnt ";
                    SQL += "from vstep_dmt a  ";
                    SQL += "where a.cg='C' and a.rs='R' and a.rs_class in ('A1','A4','A0') " + wSQL;
                    SQL += "union all ";
                    SQL += "select 'TE' as dept,a.ext_scode as scode1,(select sc_name from sysctrl.dbo.scode where scode=a.ext_scode) as scode1nm ";
                    SQL += ",0 T_A1_cnt ";
                    SQL += ",0 T_A4_cnt ";
                    SQL += ",case when rs_class in('A1') then 1 else 0 end TE_A1_cnt ";
                    SQL += ",case when rs_class in('A5') then 1 else 0 end TE_A5_cnt ";
                    SQL += "from vstep_ext a  ";
                    SQL += "where a.cg='C' and a.rs='R' and a.rs_class in ('A1','A5') " + wSQL;
                    SQL += ")z ";
                    SQL += "group by scode1,scode1nm ";
                    SQL += "order by scode1,scode1nm ";

                    DataTable dtBr = new DataTable();
                    conn.DataTable(SQL, dtBr);
                    //Sys.showLog(SQL);

                    if (dtBr.Rows.Count == 0) {
                        ((Panel)e.Item.FindControl("noData")).Visible = true;
                    } else {
                        ((Panel)e.Item.FindControl("totData")).Visible = true;//合計列
                        ((Panel)e.Item.FindControl("btnData")).Visible = true;//按鈕
                    }

                    cnti=dtBr.Rows.Count;
                    for (int i = 0; i < dtBr.Rows.Count; i++) {
                        DataRow dr = dtBr.Rows[i];

                        //行樣式
                        dr["tclass"] = (i + 1) % 2 == 1 ? "sfont9" : "lightbluetable3";
                    }

                    dtlRepeater.DataSource = dtBr;
                    dtlRepeater.DataBind();
                }
            }
        //}
    }

    protected void dtlRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if (e.Item.ItemIndex == 0) {//因pagebind&repeater bind會讓repaeter觸發綁定2次.所以第一筆時總計要重算
            totT_A1_cnt = 0;
            totT_A4_cnt = 0;
            totTE_A1_cnt = 0;
            totTE_A5_cnt = 0;
            tot_cnt = 0;
        }

        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            totT_A1_cnt += (int)(DataBinder.Eval(e.Item.DataItem, "T_A1_cnt"));
            totT_A4_cnt += (int)(DataBinder.Eval(e.Item.DataItem, "T_A4_cnt"));
            totTE_A1_cnt += (int)(DataBinder.Eval(e.Item.DataItem, "TE_A1_cnt"));
            totTE_A5_cnt += (int)(DataBinder.Eval(e.Item.DataItem, "TE_A5_cnt"));
            tot_cnt += (int)(DataBinder.Eval(e.Item.DataItem, "tot_cnt"));
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
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
		<td width="100%" colspan="2" class="FormRtext">
			&nbsp;資料抓取：客收結構分類為「創設申請案」及「延展案」(包含結案)
		</td>
	</tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>

<form style="margin:0;" id="reg" name="reg" method="post">
    <table border="0" cellspacing="1" cellpadding="2" width="100%">
	    <tr>
		    <td class="text9">
			    <input type="hidden" name="prgid" id="prgid" value="<%=prgid%>">
			    <input type="hidden" name="ctrlquery" id="ctrlquery" value="<%=ctrlquery%>">
                ◎作業選項：
			    <label><input type="radio" name="qrytodo" value="qry" <%=(qrytodo=="qry"?"checked":"")%>>件數統計查詢</label>
			    <label id="sp_todo"><input type="radio" name="qrytodo" value="process" <%=(qrytodo=="process"?"checked":"")%>>產生調整檔</label>
		    </td>
	    </tr>	
        <tr>
		    <td class="text9">
			◎單位：
			<select id=qrybranch name=qrybranch><%#html_branch%></select>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<span id="sp_step_date" style="display:<%#(qrytodo!="qry"?"none":"")%>">
			    ◎客收期間：
			    <input type="text" id="qrystep_dates" name="qrystep_dates" size="11" maxlength=10 value="<%#qrystep_dates%>" class="dateField">～
			    <input type="text" id="qrystep_datee" name="qrystep_datee" size="11" maxlength=10 value="<%#qrystep_datee%>" class="dateField">
			</span>
			<span id="sp_step_ym" style="display:<%#(qrytodo=="qry"?"none":"")%>">
			    ◎客收年月：
			    <input type="text" id="qrystep_yy" name="qrystep_yy" size="4" maxlength="4" value="<%=qrystep_yy%>" onblur="getstepdate()">年
			    <input type="text" id="qrystep_mm" name="qrystep_mm" size="2" maxlength="2" value="<%=qrystep_mm%>" onblur="getstepdate()">月
			</span>
			&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" value="查詢" class="cbutton" onClick="goSearch()" id=button1 name=button1>
		    </td>
	    </tr>	
    </table>

    <div align="center" id="noShow" style="display:<%#(!ctrlquery?"":"none")%>">
	    <br /><font color="red">=== 請先輸入查詢條件 ===</font>
    </div>

    <asp:Repeater id="dataRepeater" runat="server" OnItemDataBound="dataRepeater_ItemDataBound">
		<ItemTemplate>
 		    <table border=0 width="80%" cellspacing="1" cellpadding="1" class="bluetable" align="center">
			    <input type="hidden" id="<%#Eval("branch")%>fund_money" name="<%#Eval("branch")%>fund_money" value="<%=fund_money%>">
			    <tr align="center" class="lightbluetable1" height="20">
				    <td nowrap colspan=7><font color=white><%#Eval("branchname")%>商標新申請案及延展案件數</font></td>
			    </tr>
				<tr align="center" class="lightbluetable">
					<td nowrap>營洽</td>
					<td nowrap>內商新申請案件數</td>
					<td nowrap>內商延展案件數</td>
					<td nowrap>外商新申請案件數</td>
					<td nowrap>外商延展案件數</td>
					<td nowrap>合計件數</td>
					<td nowrap style="BACKGROUND-COLOR: gold" class="td_totmoney">合計金額</td>
				</tr>
                <asp:Panel runat="server" ID="noData" Visible="false">
			        <tr class="sfont9"><td colspan=7 align="center"><font color="red" size=2>=== 查無資料 ===</font></td></tr>
                </asp:Panel>
	            <asp:Repeater id="dtlRepeater" runat="server" OnItemDataBound="dtlRepeater_ItemDataBound">
                    <ItemTemplate>
						<tr align="center" class="<%#Eval("tclass")%>">
							<td nowrap>
                                <input name="<%#Eval("branch")%>scode<%#(Container.ItemIndex+1)%>" value="<%#Eval("scode1")%>" readonly size=6 class="SEdit">-
								<input name="<%#Eval("branch")%>scodenm<%#(Container.ItemIndex+1)%>" value="<%#Eval("scode1nm")%>" readonly size=12 class="SEdit">
							</td>
							<td nowrap><input name="A1_<%#Eval("branch")%>dmtcnt<%#(Container.ItemIndex+1)%>" value="<%#Eval("T_A1_cnt")%>" onclick="golist('<%#Eval("branch")%>','T','<%#Eval("scode1")%>','A1')" style="cursor: pointer;text-align:center;" readonly size=5 class="SEdit"></td>
							<td nowrap><input name="A4_<%#Eval("branch")%>dmtcnt<%#(Container.ItemIndex+1)%>" value="<%#Eval("T_A4_cnt")%>" onclick="golist('<%#Eval("branch")%>','T','<%#Eval("scode1")%>','A4')" style="cursor: pointer;text-align:center;" readonly size=5 class="SEdit"></td>
							<td nowrap><input name="A1_<%#Eval("branch")%>extcnt<%#(Container.ItemIndex+1)%>" value="<%#Eval("TE_A1_cnt")%>" onclick="golist('<%#Eval("branch")%>','TE','<%#Eval("scode1")%>','A1')" style="cursor: pointer;text-align:center;" readonly size=5 class="SEdit"></td>
							<td nowrap><input name="A5_<%#Eval("branch")%>extcnt<%#(Container.ItemIndex+1)%>" value="<%#Eval("TE_A5_cnt")%>" onclick="golist('<%#Eval("branch")%>','TE','<%#Eval("scode1")%>','A5')" style="cursor: pointer;text-align:center;" readonly size=5 class="SEdit"></td>
							<td nowrap><input name="<%#Eval("branch")%>totcnt<%#(Container.ItemIndex+1)%>" value="<%#Eval("tot_cnt")%>" onclick="golist('<%#Eval("branch")%>','','<%#Eval("scode1")%>','')" style="cursor: pointer;text-align:center;" readonly size=10 class="SEdit"></td>
							<td nowrap class="td_totmoney"><input name="<%#Eval("branch")%>totmoney<%#(Container.ItemIndex+1)%>" value="<%#Convert.ToInt32(Eval("tot_cnt"))*fund_money%>" onclick="golist('<%#Eval("branch")%>','','<%#Eval("scode1")%>','')" style="cursor: pointer;text-align:center;" readonly size=10 class="SEdit"></td>
						</tr>
                    </ItemTemplate>
			    </asp:Repeater>
                <asp:Panel runat="server" ID="totData" Visible="false">
				    <tr align="center" style="BACKGROUND-COLOR: #ffff99">
					    <td nowrap align="right">總　　計：&nbsp;&nbsp;</td>
					    <td nowrap><input name="A1_<%#Eval("branch")%>dmtcnt" value="<%#totT_A1_cnt%>" onclick="golist('<%#Eval("branch")%>','T','','A1')" style="cursor: pointer;text-align:center;BACKGROUND-COLOR: #ffff99;" readonly class=SEdit size=5 style="text-align:center;"></td>
					    <td nowrap><input name="A4_<%#Eval("branch")%>dmtcnt" value="<%#totT_A4_cnt%>" onclick="golist('<%#Eval("branch")%>','T','','A4')" style="cursor: pointer;text-align:center;BACKGROUND-COLOR: #ffff99;" readonly class=SEdit size=5 style="text-align:center;"></td>
					    <td nowrap><input name="A1_<%#Eval("branch")%>extcnt" value="<%#totTE_A1_cnt%>" onclick="golist('<%#Eval("branch")%>','TE','','A1')" style="cursor: pointer;text-align:center;BACKGROUND-COLOR: #ffff99;" readonly class=SEdit size=5 style="text-align:center;"></td>
					    <td nowrap><input name="A5_<%#Eval("branch")%>extcnt" value="<%#totTE_A5_cnt%>" onclick="golist('<%#Eval("branch")%>','TE','','A5')" style="cursor: pointer;text-align:center;BACKGROUND-COLOR: #ffff99;" readonly class=SEdit size=5 style="text-align:center;"></td>
					    <td nowrap><input name="<%#Eval("branch")%>totcnt" value="<%#tot_cnt%>" onclick="golist('<%#Eval("branch")%>','','','')" style="cursor: pointer;text-align:center;BACKGROUND-COLOR: #ffff99;" readonly class=SEdit size=10 style="text-align:center;"></td>
					    <td nowrap class="td_totmoney"><input name="<%#Eval("branch")%>totmoney" value="<%#tot_cnt*fund_money%>" onclick="golist('<%#Eval("branch")%>','','','')" style="cursor: pointer;text-align:center;BACKGROUND-COLOR: #ffff99;" readonly class=SEdit size=10 style="text-align:center;"></td>
				    </tr>
                    <input type=hidden id="<%#Eval("branch")%>cnti" name="<%#Eval("branch")%>cnti" value="<%#cnti%>">
                </asp:Panel>
            </table>
            <asp:Panel runat="server" ID="btnData" Visible="false">
                <div style="text-align:center"><%#StrFormBtn%></div>
            </asp:Panel>
		</ItemTemplate>
    </asp:Repeater>

    <%#DebugStr%>
</form>

<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="300" style="display:none"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        this_init();
    });

    //執行查詢
    function goSearch() {
        $("#reg").submit();
    };

    function this_init() {
        if ((main.right & 4) == 0) {
            $("#sp_todo").hide();
        }else{
            $("#sp_todo").show();
        }

        $(".td_totmoney").hide();
        if("<%=qrytodo%>"=="process"){
            $(".td_totmoney").show();
        }

        $(".Lock").lock();
        $("input.dateField").datepick();
    }
    //////////////////////
    $("#sdate,#edate").blur(function (e){
        ChkDate(this);
    });

    //作業選項
    $("input[name='qrytodo']").click(function (e){
        $("#sp_step_date,#sp_step_ym").hide();
        if ($(this).val()=="qry") $("#sp_step_date").show();//客收期間
        if ($(this).val()=="process") $("#sp_step_ym").show();//客收年月
    });

    //依客收年月設定起迄期間
    function getstepdate(){
        if($("#qrystep_yy").val()!=""&&$("#qrystep_mm").val()!=""){
            $("#qrystep_dates").val($("#qrystep_yy").val()+"/"+$("#qrystep_mm").val()+"/1");
            $("#qrystep_datee").val(CDate($("#qrystep_dates").val()).addMonths(1).addDays(-1).format("yyyy/M/d"));
        }
    }

    //杳詢
    function goSearch(){
        var qrytodo=$("input[name='qrytodo']:checked").val();
        if (qrytodo=="qry"){//件數統計查詢
            if ($("#qrystep_dates").val()!=""&& ChkDate($("#qrystep_dates"))) return false;
            if ($("#qrystep_datee").val()!=""&& ChkDate($("#qrystep_datee"))) return false;

            if ($("#qrystep_dates").val() != "" && $("#qrystep_datee").val() != "") {
                if (CDate($("#qrystep_dates").val()).getTime() > CDate($("#qrystep_datee").val()).getTime()) {
                    alert("客收日期區間起始日不可大於迄止日!!!");
                    return false;
                }
            }
        }else if (qrytodo=="process"){//產生調整檔
            if ($("#qrystep_yy").val() == "" || $("#qrystep_mm").val() == "") {
                alert("請輸入客收年月！");
                return false;
            }
        }

        $("#ctrlquery").val("Y");
        $("#qrybranch").lock();
        reg.target = "_self";
        $("#reg").submit();
    }

    //明細
    function golist(pbranch,pdept,pscode1,prs_class){
        var urlasp="brt45_list2.aspx?prgid=<%=prgid%>";
        urlasp += "&branch="+pbranch+"&dept="+pdept+"&scode1="+pscode1+"&rs_class="+prs_class;
        urlasp += "&step_dates="+$("#qrystep_dates").val()+"&step_datee="+$("#qrystep_datee").val();
        window.parent.Eblank.location.href = urlasp;
    }

    //產生調整資料，存檔前檢查
    function formAddSubmit(){
        var rtnFlag = true;

        //檢查是否已產生調整檔,原則上轉入年月為客收年月之下一月，但怕發生同一月份轉入前2個月資料及調整檔無欄位可記錄客收年月，所以用cust_code判斷
        //經詢問後此轉檔作業為例行作業，若未執行則財務部會提醒，所以應不會發生同一月份轉入前2個月狀況，因此只要判斷轉入年月有資料則不能產生，如有例外，再視狀況處理
        var fsql="select * from account.dbo.acct_plus ";
        fsql+= " where plus_date >='" +Today().format("yyyy/M/1")+ "'";
        fsql +=" and plus_date < '" +CDate(Today().format("yyyy/M/1")).addMonths(1).format("yyyy/M/d")+"'";
        fsql+= " and class='F' and branch='" + $("#qrybranch").val()+ "' and dept='T'";
        //alert(fsql);
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: { sql: fsql },
            async: false,
            cache: false,
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length > 0) {
                    rtnFlag = false;
                    alert(Today().Year()+ "年" + Today().Month()+ "月已有「提撥新申請案，捐款聖島基金會」調整檔資料，請勿重覆產生並請檢查！");
                }
            },
            error: function (xhr) { 
                $("#dialog").html("<a href='" + this.url + "' target='_new'>查詢調整檔資料失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '查詢調整檔資料失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });

        if(!rtnFlag) return rtnFlag;
	
        //原則上客收年月應為作業日之前一個月ex:12月轉11月，不符規則作提醒
        var tran_date=CDate($("#qrystep_yy").val()+"/"+CInt($("#qrystep_mm").val())+"/1").addMonths(1);
        if (tran_date.format("yyyy/M")!=Today().format("yyyy/M")){
            if (!confirm("輸入客收年月與本月應轉入年月不符，是否確定繼續作業？")){
                return false;
            }
        }
	
        if (confirm("是否確定產生調整資料？")){
            //$(".bsubmit").lock();
            //reg.target = "Eblank";
            //reg.action = "brt45_update.aspx?submittask=A";
            //$("#reg").submit();
            postForm("brt45_update.aspx?submittask=A");
        }
    }

    //刪除調整資料，刪除前檢查
    function formDelSubmit(){
        var rtnFlag = true;

	    //檢查是否已產生傳票，acc_sqlno=0才能刪，所以只要有一筆acc_sqlno<>0即不能刪除
	    //因跨月調整檔不能刪除，所以只要判斷轉入作業年月，不用管客收年月(因有可能同一月份轉入前2個月資料)
        var fsql="select * from account.dbo.acct_plus ";
        fsql+= " where plus_date >='" +Today().format("yyyy/M/1")+ "'";
        fsql +=" and plus_date < '" +CDate(Today().format("yyyy/M/1")).addMonths(1).format("yyyy/M/d")+"'";
        fsql+= " and class='F' and branch='" + $("#qrybranch").val()+ "' and dept='T'";
	    fsql+= " and acc_sqlno<>0 "
        //alert(fsql);
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: { sql: fsql },
            async: false,
            cache: false,
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length > 0) {
                    rtnFlag = false;
                    alert("本月份調整檔已轉UNIX並產生傳票，無法刪除！");
                }
            },
            error: function (xhr) { 
                $("#dialog").html("<a href='" + this.url + "' target='_new'>查詢跨月調整檔資料失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '查詢跨月調整檔資料失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });

        if(!rtnFlag) return rtnFlag;

        if (confirm("是否確定刪除" + Today().Year()+ "年" + Today().Month()+ "月調整資料？")){
            //$(".bsubmit").lock();
            //reg.target = "Eblank";
            //reg.action = "brt45_update.aspx?submittask=D";
            //$("#reg").submit();
            postForm("brt45_update.aspx?submittask=D");
        }
    }

    function postForm(url){
        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        ajaxByForm(url,formData)
        .complete(function( xhr, status ) {
            $("#dialog").html(xhr.responseText);
            $("#dialog").dialog({
                title: '存檔訊息',modal: true,maxHeight: 500,width: 800,closeOnEscape: false
                ,buttons: {
                    確定: function() {
                        $(this).dialog("close");
                    }
                }
                ,close:function(event, ui){
                    if(status=="success"){
                        if(!$("#chkTest").prop("checked")){
                            //goSearch();//重新整理
                            window.parent.Etop.location.href= getRootPath() +'/brt4m/brt45_list.aspx?prgid=<%=prgid%>';
                        }
                    }
                }
            });
        });
    }
</script>