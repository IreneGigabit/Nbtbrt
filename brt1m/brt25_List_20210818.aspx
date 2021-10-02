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
    protected string json = "";
    protected Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();

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

        json = (Request["json"] ?? "").Trim().ToUpper();
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
            if (json == "Y") {
                QueryData();
            } else {
                PageLayout();
            }
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
            SQL = "SELECT distinct a.scode, b.sc_name,b.sscode ";
            SQL += "FROM scode_group a ";
            SQL += "JOIN scode b ON a.scode=b.scode ";
            SQL += "JOIN grpid c ON a.grpclass=c.grpclass AND a.grpid=c.grpid ";
            SQL += "WHERE c.work_type='sales' ";
            SQL += "and c.grpclass='" + Session["SeBranch"] + "' and c.grpid not like '%x%' ";
            SQL += "and (substring(c.grpid,1,1)='T' or c.grpid='000') ";
            SQL += "and (b.end_date is null or b.end_date >=getdate()) ";//增加判斷未離職人員
            SQL += "order by b.sscode,a.scode,b.sc_name";
            cnn.DataTable(SQL, dt);
            td_tscode = "<select id='qryscode1' name='qryscode1' ><option value=''>全部</option>" + dt.Option("{scode}", "{sc_name}") + "</select>";
        } else if ((HTProgRight & 64) != 0) {
            //權限A為所屬營洽
            SQL = "SELECT distinct a.scode, b.sc_name,b.sscode ";
            SQL += "FROM scode_group a ";
            SQL += "JOIN scode b ON a.scode=b.scode ";
            SQL += "JOIN grpid c ON a.grpclass=c.grpclass AND a.grpid=c.grpid ";
            SQL += "WHERE c.work_type='sales' ";
            SQL += "and c.grpclass='" + Session["SeBranch"] + "' and c.grpid not like '%x%' ";
            SQL += "and (substring(c.grpid,1,1)='T' or c.grpid='000') and a.scode=b.scode ";
            SQL += "and a.scode in (" + sales_scode + ") ";
            SQL += "and (b.end_date is null or b.end_date >=getdate() )";//增加判斷未離職人員
            SQL += "order by b.sscode,a.scode,b.sc_name";
            cnn.DataTable(SQL, dt);
            td_tscode = "<select id='qryscode1' name='qryscode1' >" + dt.Option("{scode}", "{sc_name}") + "</select>";
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

        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
        Paging page = new Paging(nowPage, PerPageSize, SQL);
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

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.None,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };

        Response.Write(JsonConvert.SerializeObject(page, settings).ToUnicode());
        Response.End();
        //return JsonConvert.SerializeObject(dt, settings).ToUnicode().Replace("\\", "\\\\").Replace("\"", "\\\"");
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

<form id="regPage" name="regPage" method="post">
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

    <div id="divPaging" style="display:none">
    <TABLE border=0 cellspacing=1 cellpadding=0 width="98%" align="center">
	    <tr>
		    <td colspan=2 align=center>
			    <font size="2" color="#3f8eba">
				    第<font color="red"><span id="NowPage"></span>/<span id="TotPage"></span></font>頁
				    | 資料共<font color="red"><span id="TotRec"></span></font>筆
				    | 跳至第<select id="GoPage" name="GoPage" style="color:#FF0000"></select>頁
				    <span id="PageUp">| <a href="javascript:void(0)" class="pgU" v1="">上一頁</a></span>
				    <span id="PageDown">| <a href="javascript:void(0)" class="pgD" v1="">下一頁</a></span>
				    | 每頁筆數:<select id="PerPage" name="PerPage" style="color:#FF0000">
					    <option value="10" selected>10</option>
					    <option value="20">20</option>
					    <option value="30">30</option>
					    <option value="50">50</option>
				    </select>
                    <input type="hidden" name="SetOrder" id="SetOrder" />
			    </font>
		    </td>
	    </tr>
    </TABLE>
    </div>
    <%#DebugStr%>
</form>

<div align="center" class="noData" style="display:none">
	<font color="red">=== 目前無資料 ===</font>
</div>

<table style="display:" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
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
	<tbody>
	</tbody>
    <script type="text/html" id="data_template"><!--清單樣板-->
        <tr class='{{tclass}}' id='tr_data_{{nRow}}'>
		    <td align="center">
		        <span style="color:red">{{sign}}</span>{{actbtn}}
		        <input type="hidden" name="seq_{{nRow}}" value="{{seq}}">
		        <input type="hidden" name="seq1_{{nRow}}" value="{{seq1}}">
		    </td>
		    <td align="center" nowrap title="{{scode}}-{{in_no}}">{{scode1nm}}</td>
		    <td align="center" nowrap>{{case_no}}</td>
		    <td align="center" title="{{cust_area}}-{{cust_seq}}">{{ap_cname}}</td>
		    <td align="center" nowrap>{{ctrl_date}}</td>
		    <td align="center" nowrap onclick="Qseqdetail({{seq}},'{{seq1}}')" style="cursor:pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" nowrap>{{fseq}}</td>
		    <td align="center">{{appl_name}}</td>
            <td align="center" title="{{arcase_class}}-{{arcase}}-">{{rs_detail}}</td>
            <td align="center">{{service}}</td>
            <td align="center">{{fees}}</td>
            <td align="center">{{oth_money}}</td>
            <td align="center">{{totsum}}</td>
            <td align="center">{{discount}}<font style="color:red">{{armark_txt}}</font></td>
            <td align="center" title="流程狀態查詢"><a href="{{todo_link}}" target="Eblank"><img src="<%=Page.ResolveUrl("~/images/ok.gif")%>" border=0 ></a></td>
       </tr>
    </script>
</TABLE>
<BR>
<div align=left style="font-size:10pt;color:blue" class="haveData">
<br />備註：
<br />1.此作業提供需契約書後補交辦案件，可補入契約書號碼及將契約書或相關檔案上傳，若為總契約書則需對應總契約書檔，
<br />  完成後系統將銷管契約書後補期限並將此筆交辦寫入「會計契約書檢核作業」，同時會EMAIL通知會計。
<br />2.<font color=red>◎</font><font color=blue>表會計退回</font>
<br />3.<font color=red  size="3">※</font><font color=blue>表已官發/聯發</font>
<%if ((HTProgRight & 16)!=0 && (HTProgRight & 128)!=0){%>
<br />※[取消(送會計)]：表取消後補送會計契約書檢核
<br />※[不需後補]：契約書已上傳，不需後補
<%}%>
</div>

<div id="dialog"></div>

</body>
</html>


<script language="javascript" type="text/javascript">
    $(function () {
        this_init();
        goSearch();
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
        window.parent.tt.rows = '100%,0%';
        $("#divPaging,#dataList,.noData,.haveData").hide();
        $("#dataList>tbody tr").remove();
        nRow = 0;

        $.ajax({
            url: "<%#HTProgPrefix%>_List.aspx?json=Y",
            type: "get",
            async: false,
            cache: false,
            data: $("#regPage").serialize(),
            success: function (json) {
                if (!isJson(json) || $("#chkTest").prop("checked")) {
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>Debug！<u>(點此顯示詳細訊息)</u></a><hr>" + json);
                    $("#dialog").dialog({ title: 'Debug！', modal: true, maxHeight: 500, width: "90%" });
                    return false;
                }
                var JSONdata = $.parseJSON(json);
                //////更新分頁變數
                var totRow = parseInt(JSONdata.totrow, 10);
                if (totRow > 0) {
                    $("#divPaging,#dataList,.haveData").show();
                } else {
                    $(".noData").show();
                }

                var nowPage = parseInt(JSONdata.nowpage, 10);
                var totPage = parseInt(JSONdata.totpage, 10);
                $("#NowPage").html(nowPage);
                $("#TotPage").html(totPage);
                $("#TotRec").html(totRow);
                var i = totPage + 1, option = new Array(i);
                while (--i) {
                    option[i] = ['<option value="' + i + '">' + i + '</option>'].join("");
                }
                $("#GoPage").replaceWith('<select id="GoPage" name="GoPage" style="color:#FF0000">' + option.join("") + '</select>');
                $("#GoPage").val(nowPage);
                nowPage > 1 ? $("#PageUp").show() : $("#PageUp").hide();
                nowPage < totPage ? $("#PageDown").show() : $("#PageDown").hide();
                $("a.pgU").attr("v1", nowPage - 1);
                $("a.pgD").attr("v1", nowPage + 1);
                //$("#id-div-slide").slideUp("fast");

                $.each(JSONdata.pagedtable, function (i, item) {
                    nRow++;
                    //複製樣板
                    var copyStr = $("#data_template").text() || "";
                    copyStr = copyStr.replace(/##/g, nRow);
                    var tclass = "";
                    if (nRow % 2 == 1) tclass = "sfont9"; else tclass = "lightbluetable3";
                    copyStr = copyStr.replace(/{{tclass}}/g, tclass);
                    copyStr = copyStr.replace(/{{nRow}}/g, nRow);

                    copyStr = copyStr.replace(/{{seq}}/gi, item.seq);
                    copyStr = copyStr.replace(/{{seq1}}/gi, item.seq1);
                    copyStr = copyStr.replace(/{{sign}}/gi, item.sign);
                    copyStr = copyStr.replace(/{{actbtn}}/gi, item.actbtn);
                    copyStr = copyStr.replace(/{{scode}}/gi, item.scode);
                    copyStr = copyStr.replace(/{{in_no}}/gi, item.in_no);
                    copyStr = copyStr.replace(/{{scode1nm}}/gi, item.scode1nm);
                    copyStr = copyStr.replace(/{{case_no}}/gi, item.case_no);
                    copyStr = copyStr.replace(/{{cust_area}}/gi, item.cust_area);
                    copyStr = copyStr.replace(/{{cust_seq}}/gi, item.cust_seq);
                    copyStr = copyStr.replace(/{{ap_cname}}/gi, item.ap_cname);
                    copyStr = copyStr.replace(/{{ctrl_date}}/gi, dateReviver(item.ctrl_date, "yyyy/M/d"));
                    copyStr = copyStr.replace(/{{fseq}}/gi, item.fseq);
                    copyStr = copyStr.replace(/{{appl_name}}/gi, item.appl_name);
                    copyStr = copyStr.replace(/{{arcase_class}}/g, item.arcase_class);
                    copyStr = copyStr.replace(/{{arcase}}/g, item.arcase);
                    copyStr = copyStr.replace(/{{rs_detail}}/g, item.rs_detail);
                    copyStr = copyStr.replace(/{{service}}/gi, item.service);
                    copyStr = copyStr.replace(/{{fees}}/gi, item.fees);
                    copyStr = copyStr.replace(/{{oth_money}}/gi, item.oth_money);
                    copyStr = copyStr.replace(/{{totsum}}/gi, item.totsum);
                    copyStr = copyStr.replace(/{{discount}}/gi, item.discount);
                    copyStr = copyStr.replace(/{{armark_txt}}/gi, item.armark_txt);
                    copyStr = copyStr.replace(/{{todo_link}}/gi, item.todo_link);

                    $("#dataList>tbody").append(copyStr);
                });
            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>資料擷取剖析錯誤！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '資料擷取剖析錯誤！', modal: true, maxHeight: 500, width: 800 });
                //toastr.error("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
            }
        });
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
