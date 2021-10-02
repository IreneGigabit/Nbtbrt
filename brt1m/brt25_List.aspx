<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案契約書後補作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt25";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";

    protected string SQL = "";
    protected Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string submittask = "";
    protected string td_tscode = "";
    protected string sales_scode="";
    protected string homelist="";
    protected string qryuse_datee="";
    protected string qryscode1="";
    protected string qryseq="";
    protected string qryseq1="";

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

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        submittask = (Request["submittask"] ?? "").Trim();
        homelist = (Request["homelist"] ?? "").Trim();
        qryuse_datee = (Request["qryuse_datee"] ?? "").Trim();
        qryscode1 = (Request["qryscode1"] ?? "").Trim();
        qryseq = (Request["qryseq"] ?? "").Trim();
        qryseq1 = (Request["qryseq1"] ?? "").Trim();

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
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>\n";
        //StrFormBtnTop += "<a class=\"imgQry\" href=\"javascript:void(0);\" >[查詢條件]</a>\n";
        if ((HTProgRight & 2) > 0) {
            //StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"查　詢\" class=\"cbutton bsubmit\" />\n";
            //StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
        }

        //抓取組主管所屬營洽
        sales_scode = Sys.getTeamScode(Sys.GetSession("SeBranch"), Sys.GetSession("scode"));

        //洽案營洽清單
        DataTable dt = new DataTable();
        //權限B：區所主管、專利主管
        //權限A：組主管
        if ((HTProgRight & 128) != 0) {
            //權限B為全部
            td_tscode = "<select id='qryscode1' name='qryscode1' ><option value=''>全部</option>";
            td_tscode += Sys.getLoginGrpSales("A", "").Option("{scode}", "{scode}_{sc_name}") + "</select>";
        } else if ((HTProgRight & 64) != 0) {
            //權限A為所屬營洽
            td_tscode = "<select id='qryscode1' name='qryscode1' ><option value=''>全部</option>";
            td_tscode += Sys.getLoginGrpSales("A", "and a.scode in (" + sales_scode + ")").Option("{scode}", "{scode}_{sc_name}") + "</select>";
        } else {
            td_tscode = "<input type='text' id='scode' name='scode' readonly class='SEdit' size=5 value='" + Session["se_scode"] + "'>-&nbsp;" + Session["sc_name"];
        }
    }

    private void QueryData() {
        string wsql = "";

        if (qryseq != "") {
            wsql += " and a.seq in('" + qryseq.Replace(",", "','") + "') ";
        }
        if (qryseq1 != "") {
            wsql += " and a.seq1='" + qryseq1 + "' ";
        }
        if (qryscode1 != "") {
            wsql += " and d.scode='" + qryscode1 + "' ";
        } else {
            if ((HTProgRight & 256) != 0) {//admin
            } else if ((HTProgRight & 128) != 0) {//區所主管、專利主管
            } else if ((HTProgRight & 64) != 0) {//組主管
                wsql += " and d.scode in (" + sales_scode + ")";
                if (homelist != "homelist") {
                    wsql += " and d.scode ='" + Session["session"] + "' ";
                }
            } else {
                wsql += " and d.scode ='" + Session["session"] + "' ";
            }
        }
        if (qryuse_datee != "") {
            wsql += " and c.ctrl_date<='" + qryuse_datee + "' ";
        }

        if (prgid.ToLower().Left(3) == "brt") {
            SQL = "select a.seq,a.seq1,a.in_scode,a.in_no,a.case_no,a.arcase_type,a.arcase_class,a.arcase,a.service,a.fees,a.oth_money,0 as tot_tax,a.discount";
            SQL += ",a.ar_mark,'' as country,d.scode,d.cust_area,d.cust_seq,d.appl_name";
            SQL += ",t.sqlno as todo_sqlno,t.step_grade,t.from_flag,t.dowhat,'step_dmt' as step_table,c.ctrl_date";
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode=d.scode) as scode1nm";
            SQL += ",(select ap_cname1+isnull(ap_cname2,'') from apcust where cust_area=d.cust_area and cust_seq=d.cust_seq) as ap_cname";
            SQL += ",''fseq,''rs_detail,''gs_flag,''totsum,''sign,''actbtn,''armark_txt,''todo_link ";
            SQL += " from case_dmt a ";
            SQL += " inner join dmt d on a.seq = d.seq and a.seq1 = d.seq1";
            SQL += " inner join todo_dmt t on a.seq = t.seq and a.seq1 = t.seq1 and a.case_no=t.case_no";
            SQL += " inner join ctrl_dmt c on t.seq = c.seq and t.seq1 = c.seq1 and t.step_grade=c.step_grade and c.ctrl_type='B9' ";
            SQL += " where a.stat_code='YZ'";
            SQL += wsql;
            SQL += " and (t.dowhat like 'contractL%') and t.job_status='NN'";
        } else if (prgid.ToLower().Left(3) == "ext") {
            SQL = "select a.seq,a.seq1,a.in_scode,a.in_no,a.case_no,a.arcase_type,a.arcase_class,a.arcase,a.tot_service as service,a.tot_fees as fees,a.oth_money,a.tot_tax,a.discount";
            SQL += ",a.ar_mark,d.country,d.scode,d.cust_area,d.cust_seq,d.appl_name";
            SQL += ",t.sqlno as todo_sqlno,t.step_grade,t.from_flag,t.dowhat,'step_ext' as step_table,c.ctrl_date";
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode=d.scode) as scode1nm";
            SQL += ",(select ap_cname1+isnull(ap_cname2,'') from apcust where cust_area=d.cust_area and cust_seq=d.cust_seq) as ap_cname";
            SQL += ",''fseq,''rs_detail,''gs_flag,''totsum,''sign,''actbtn,''armark_txt,''todo_link ";
            SQL += " from case_ext a ";
            SQL += " inner join ext d on a.seq = d.seq and a.seq1 = d.seq1";
            SQL += " inner join todo_ext t on a.seq = t.seq and a.seq1 = t.seq1 and a.case_no=t.case_no";
            SQL += " inner join ctrl_ext c on t.seq = c.seq and t.seq1 = c.seq1 and t.step_grade=c.step_grade and c.ctrl_type='B9' ";
            SQL += " where (a.stat_code='YZ' or a.stat_code like 'S%') ";
            SQL += wsql;
            SQL += " and (t.dowhat like 'contractL%') and t.job_status='NN'";
        }

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder"));
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        } else {
            SQL += " order by a.seq,a.seq1";
        }
        Sys.showLog(SQL);
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

            //組本所編號
            dr["fseq"] = Sys.formatSeq(dr.SafeRead("Seq", ""), dr.SafeRead("Seq1", ""), dr.SafeRead("country", ""), Sys.GetSession("SeBranch"), "T" + ((prgid.ToLower().Left(2) == "ex") ? "E" : ""));

            SQL = "select rs_detail from " + dr.SafeRead("step_table", "") + " ";
            SQL += "where seq=" + dr.SafeRead("Seq", "") + " ";
            SQL += "and seq1='" + dr.SafeRead("Seq1", "") + "' ";
            SQL += "and step_grade = '" + dr.SafeRead("step_grade", "") + "' ";
            object objResult0 = conn.ExecuteScalar(SQL);
            dr["rs_detail"] = ((objResult0 == DBNull.Value || objResult0 == null) ? "" : objResult0.ToString());

            //檢查是否已官發或聯發，因step_dmt沒記錄case_no且用attcase_dmt抓所費查詢成本較低，故商標改用attcase_dmt/attcase_ext
            if (prgid.ToLower().Left(3) == "brt") {
                SQL = "select count(*) as gs_cnt from attcase_dmt ";
                SQL += "where seq=" + dr.SafeRead("Seq", "") + " ";
                SQL += "and seq1='" + dr.SafeRead("Seq1", "") + "' ";
                SQL += "and case_no = '" + dr.SafeRead("case_no", "") + "' ";
                SQL += "and sign_stat='SZ' ";
                object objResult = conn.ExecuteScalar(SQL);
                int gs_cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                dr["gs_flag"] = (gs_cnt >= 1 ? "Y" : "N");
            } else if (prgid.ToLower().Left(3) == "ext") {
                SQL = "select count(*) as gs_cnt from attcase_ext ";
                SQL += "where seq=" + dr.SafeRead("Seq", "") + " ";
                SQL += "and seq1='" + dr.SafeRead("Seq1", "") + "' ";
                SQL += "and case_no = '" + dr.SafeRead("case_no", "") + "' ";
                SQL += "and sign_stat='SZ' ";
                object objResult = conn.ExecuteScalar(SQL);
                int gs_cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                dr["gs_flag"] = (gs_cnt >= 1 ? "Y" : "N");
            }
            dr["totsum"] = GetSum(dr);

            //符號
            string sign = "";
            if (dr.SafeRead("dowhat", "") == "contractLB") sign += "◎";//會計退回
            if (dr.SafeRead("gs_flag", "") == "Y") sign += "※";//官發/聯發
            dr["sign"] = sign;

            //dr["urlasp"] = "brt25Edit.aspx?prgid="+prgid+"&seq="+dr["seq"]+"&seq1="+dr["seq1"]+
            //    "&case_no="+dr["case_no"]+ "&todo_sqlno="+dr["todo_sqlno"]+ "&from_flag="+dr["from_flag"]+ 
            //    "&in_no="+dr["in_no"]+ "&in_scode=" +dr["in_scode"];
            string urlasp = "brt25_Edit.aspx?prgid=" + prgid + "&seq=" + dr["seq"] + "&seq1=" + dr["seq1"] +
                "&case_no=" + dr["case_no"] + "&todo_sqlno=" + dr["todo_sqlno"] + "&from_flag=" + dr["from_flag"] +
                "&in_no=" + dr["in_no"] + "&in_scode=" + dr["in_scode"];

            //按鈕
            string actbtn = "<a href=\"" + urlasp + "&submitTask=A\" target=\"Eblank\">[後補]</a>";
            if ((HTProgRight & 16) != 0 && (HTProgRight & 128) != 0) {
                actbtn += "&nbsp;&nbsp;";
                actbtn += "<a href=\"" + urlasp + "&submitTask=C\" target=\"Eblank\">[取消(送會計)]</a>";
                actbtn += "<a href=\"" + urlasp + "&submitTask=D\" target=\"Eblank\">[不需後補]</a>";
            }
            dr["actbtn"] = actbtn;
            dr["armark_txt"] = dr.SafeRead("ar_mark", "") != "N" ? "(" + dr.SafeRead("ar_mark", "") + ")" : "";

            //流程狀態查詢
            string todo_link = "";
            if (prgid.ToLower().Left(3) == "brt") {
                todo_link = "../brtam/brta61_list2.aspx?prgid=" + prgid + "&seq=" + dr["seq"] + "&seq1=" + dr["seq1"];
            } else if (prgid.ToLower().Left(3) == "ext") {
                //****todo出口案
                todo_link = "../brtam/exta61_list2.aspx?prgid=" + prgid + "&seq=" + dr["seq"] + "&seq1=" + dr["seq1"];
            }
            dr["todo_link"] = todo_link;
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    protected string GetSum(DataRow row) {
        int Service = Convert.ToInt32(row.SafeRead("Service", "0"));
        int fees = Convert.ToInt32(row.SafeRead("fees", "0"));
        int oth_money = Convert.ToInt32(row.SafeRead("oth_money", "0"));
        int tot_tax = Convert.ToInt32(row.SafeRead("tot_tax", "0"));
        return (Service + fees + oth_money + tot_tax).ToString();
    }

</script>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>
<script language="javascript" type="text/javascript">
    var main = {};
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
</script>
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

<form style="margin:0;" id="regPage" name="regPage" method="post">
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
    <input type="hidden" id="submittask" name="submittask" value="<%=submittask%>">

    <div id="id-div-slide">
        <table id="qryForm" border="0"  cellspacing="1" cellpadding="2" width="98%" align="center">	
			<TR>
		        <td>
			        ◎營洽： <%#td_tscode%>
			        &nbsp;&nbsp;&nbsp;&nbsp;◎契約書後補期限：～
			        <input type="text" name="qryuse_datee" size=11 maxlength=10 value="<%=qryuse_datee%>" class="dateField">
			        &nbsp;&nbsp;&nbsp;&nbsp;◎本所編號：
			        <INPUT type="text" name="qryseq" size="20" maxlength="20" value="<%=qryseq%>">-
			        <INPUT type="text" name="qryseq1" size="<%=Sys.DmtSeq1%>" maxlength="<%=Sys.DmtSeq1%>" value="<%=qryseq1%>">
			        <input type=button class="cbutton <%#Lock.TryGet("Qdisabled")%>" id="btnseqQ" name="btnseqQ" value="查詢">
		        </td>
            </TR>
        </table>
    </div>

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

<asp:Repeater id="dataRepeater" runat="server">
<HeaderTemplate>
<table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	<thead>
        <Tr>
		    <td align="center" class="lightbluetable" nowrap>作業</td>
		    <td align="center" class="lightbluetable" nowrap>營洽</td>
		    <td align="center" class="lightbluetable" nowrap>交辦單號</td>
		    <td align="center" class="lightbluetable" nowrap>客戶名稱</td>
		    <td align="center" class="lightbluetable" nowrap>後補期限</td>
		    <td align="center" class="lightbluetable" nowrap>本所編號</td>
		    <td align="center" class="lightbluetable" nowrap>案件名稱</td>
	        <td align="center" class="lightbluetable" nowrap>案性</td>
		    <td align="center" class="lightbluetable" nowrap>服務費</td>
		    <td align="center" class="lightbluetable" nowrap>規費</td>
		    <td align="center" class="lightbluetable" nowrap>轉帳費用</td>
		    <td align="center" class="lightbluetable" nowrap>合計</td>
		    <td align="center" class="lightbluetable" nowrap>折扣</td>
		    <td align="center" class="lightbluetable" nowrap>狀態</td>
	    </tr>
	</thead>
</HeaderTemplate>
		<ItemTemplate>
 	    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		    <td align="center">
		        <span style="color:red"><%#Eval("sign")%></span><%#Eval("actbtn")%>
		        <input type="hidden" name="seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq")%>">
		        <input type="hidden" name="seq1_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq1")%>">
		    </td>
		    <td align="center" nowrap title="<%#Eval("scode")%>-<%#Eval("in_no")%>"><%#Eval("scode1nm")%></td>
		    <td align="center" nowrap><%#Eval("case_no")%></td>
		    <td align="center" title="<%#Eval("cust_area")%>-<%#Eval("cust_seq")%>"><%#Eval("ap_cname")%></td>
		    <td align="center" nowrap><%#Eval("ctrl_date","{0:d}")%></td>
		    <td align="center" nowrap onclick="Qseqdetail(<%#Eval("seq")%>,'<%#Eval("seq1")%>')" style="cursor:pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" nowrap>
                <%#Eval("fseq")%>
		    </td>
		    <td align="center"><%#Eval("appl_name")%></td>
            <td align="center" title="<%#Eval("arcase_class")%>-<%#Eval("arcase")%>-"><%#Eval("rs_detail")%></td>
            <td align="center"><%#Eval("service")%></td>
            <td align="center"><%#Eval("fees")%></td>
            <td align="center"><%#Eval("oth_money")%></td>
            <td align="center"><%#Eval("totsum")%></td>
            <td align="center"><%#Eval("discount")%><font style="color:red"><%#Eval("armark_txt")%></font></td>
            <td align="center" title="流程狀態查詢"><a href="<%#Eval("todo_link")%>" target="Eblank"><img src="<%=Page.ResolveUrl("~/images/ok.gif")%>" border=0 ></a></td>
       </tr>
		</ItemTemplate>
    <FooterTemplate>
        </table>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName">
                <td><div align="left" style="color:blue">
                    <br />備註：
                    <br />1.此作業提供需契約書後補交辦案件，可補入契約書號碼及將契約書或相關檔案上傳，若為總契約書則需對應總契約書檔，
                    <br />  完成後系統將銷管契約書後補期限並將此筆交辦寫入「會計契約書檢核作業」，同時會EMAIL通知會計。
                    <br />2.<font color=red>◎</font><font color=blue>表會計退回</font>
                    <br />3.<font color=red  size="3">※</font><font color=blue>表已官發/聯發</font>
                    <%if ((HTProgRight & 16)!=0 && (HTProgRight & 128)!=0){%>
                    <br />※[取消(送會計)]：表取消後補送會計契約書檢核
                    <br />※[不需後補]：契約書已上傳，不需後補
                    <%}%>
		        </div></td>
            </tr>
	    </table>

    </FooterTemplate>
    </asp:Repeater>

<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="300" style="display:none"></iframe>
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
    }

    //[查詢]
    $("#btnseqQ").click(function (e) {
        if((main.right&64)==0){
            if ($("#qryscode1").val() == "") {
                alert("營洽必須選擇!");
                return false;
            }
        }

        $("#dataList>thead tr .setOdr span").remove();
        $("#SetOrder").val("");

        goSearch();
    });

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //////////////////////

    //[重填]
    $("#btnRest").click(function (e) {
        regPage.reset();
        this_init();
    });

    $("#Sfx_in_date,#Efx_in_date").blur(function (e) {
        ChkDate(this);
    });

    //詳細案件資料
    function Qseqdetail(pseq,pseq1){
        var urlasp=getRootPath();
        if(main.prgid.Left(3)=="brt"){
            urlasp += "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + pseq + "&seq1=" + pseq1 + "&submittask=Q";
        }else{
            //***todo出口案
            urlasp += "/brt5m/ext54_Edit.aspx?seq=" + pseq + "&seq1=" + pseq1 + "&submittask=DQ&winact=Y&prgid="+main.prgid;
        }
        window.open(urlasp,"myWindowOneN", "width=950 height=700 top=20 left=20 toolbar=no, menubar=no, location=no, directories=no resizable=yes status=yes scrollbars=yes");
    }
</script>
