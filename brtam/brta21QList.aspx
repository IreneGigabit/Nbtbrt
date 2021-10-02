<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案收文作業-查詢本所編號畫面";//;//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta21";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = "brta21";//(HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    
    protected string SQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string cust_seq = "";
    protected string cgrs = "";
    protected string seqnum = "";//客發用，第幾筆seq
    protected string tot_num = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        cust_seq = (Request["cust_seq"] ?? "").Trim();
        cgrs = (Request["cgrs"] ?? "").Trim();
        seqnum = (Request["seqnum"] ?? "").Trim();//客發用，第幾筆seq
        tot_num = (Request["tot_num"] ?? "").Trim();

        TokenN myToken = new TokenN(HTProgCode);
        //HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        //if (HTProgRight >= 0) {
        PageLayout();
        QueryData();
        this.DataBind();
        //}
    }

    private void PageLayout() {
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";
        StrFormBtnTop += "<a href=" + HTProgPrefix + "Query.aspx?prgid=" + prgid + ">[回查詢]</a>";

        if (cust_seq != "") {
            Lock["QClass"] = "Lock";
        }
    }

    private void QueryData() {
        string seq = (Request["seq"] ?? "");
        string seq1 = (Request["seq1"] ?? "");
        string cust_seq = (Request["cust_seq"] ?? "");
        string ap_cname1 = (Request["ap_cname1"] ?? "");
        string s_mark = (Request["s_mark"] ?? "");
        string pul = (Request["pul"] ?? "");
        string appl_name = (Request["appl_name"] ?? "");
        string kind_no = (Request["kind_no"] ?? "");
        string ref_no = (Request["ref_no"] ?? "");
        string kind_date = (Request["kind_date"] ?? "");
        string sdate = (Request["sdate"] ?? "");
        string edate = (Request["edate"] ?? "");
        string tot_num = (Request["tot_num"] ?? "");
        using (DBHelper conn = new DBHelper(Conn.btbrt, false).Debug(Request["chkTest"] == "TEST")) {
            SQL = "select a.seq,a.seq1,a.in_date,appl_name,a.cust_area,a.cust_seq,apply_no,b.ap_cname1,''fseq ";
            SQL += " from dmt a ";
            SQL += " inner join apcust b on a.cust_area=b.cust_area and a.cust_seq=b.cust_seq ";
            SQL += " where 1=1 ";
            if (seq != "") {
                SQL += " and a.seq like '" + seq + "%'";
            }
            if (seq1 != "") {
                SQL += " and a.seq1 like '" + seq1 + "%'";
            }
            if (cust_seq != "") {
                SQL += " and a.cust_seq = '" + cust_seq + "'";
            }
            if (ap_cname1 != "") {
                SQL += " and b.ap_cname1 like '%" + ap_cname1 + "%'";
            }
            if (s_mark != "") {
                if (s_mark == "T") {
                    SQL += " and a.s_mark in ('T','') ";
                } else {
                    SQL += " and a.s_mark = '" + s_mark + "'";
                }
            }
            if (pul != "") {
                if (s_mark == "0") {
                    SQL += " and a.pul = ''";
                } else {
                    SQL += " and a.pul = '" + pul + "'";
                }
            }
            if (appl_name != "") {
                SQL += " and a.appl_name like '%" + appl_name + "%'";
            }
            if (kind_no != "") {
                SQL += " and a." + kind_no + " = '" + ref_no + "'";
            } else {
                if (ref_no != "") {
                    SQL += " and (a.Apply_No like '%" + ref_no + "%'";
                    SQL += " or a.Issue_No like '%" + ref_no + "%'";
                    SQL += " or a.Rej_No like '%" + ref_no + "%')";
                }
            }
            if (kind_date != "") {
                if (sdate != "") {
                    SQL += " and a." + kind_date + " >= '" + sdate + "'";
                }
                if (edate != "") {
                    SQL += " and a." + kind_date + " <= '" + edate + "'";
                }
            } else {
                if (sdate != "") {
                    SQL += " and (a.In_Date >= '" + sdate + "'";
                    SQL += "  or a.Apply_Date >= '" + sdate + "'";
                    SQL += "  or a.Issue_Date >= '" + sdate + "'";
                    SQL += "  or a.End_Date >= '" + sdate + "')";
                }
                if (edate != "") {
                    SQL += " and (a.In_Date <= '" + edate + "'";
                    SQL += "  or a.Apply_Date <= '" + edate + "'";
                    SQL += "  or a.Issue_Date <= '" + edate + "'";
                    SQL += "  or a.End_Date <= '" + edate + "')";
                }
            }
            SQL += " order by a.seq,a.seq1";
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

                //組本所編號
                dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", "", "");
            }

            dataRepeater.DataSource = page.pagedTable;
            dataRepeater.DataBind();
        }
    }
</script>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

<body onload="window.focus();">
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
<asp:Repeater id="dataRepeater" runat="server">
<HeaderTemplate>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	<thead>
      <Tr>
		<TD class=lightbluetable align=center>本所編號</TD>
		<TD class=lightbluetable align=center>立案日期</TD>
		<TD class=lightbluetable align=center>案件名稱</TD>
		<TD class=lightbluetable align=center>客戶</TD>
		<TD class=lightbluetable align=center>申請號碼</TD>
		<TD class=lightbluetable align=center>詳細資料</TD>
      </tr>
	</thead>
</HeaderTemplate>
<ItemTemplate>
 	<tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
        <td align=center style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" nowrap onclick="SeqClick('<%#Eval("seq")%>','<%#Eval("seq1")%>')"><%#Eval("fseq")%></td>
		<td align=center nowrap><%#Eval("in_date")%></td>
		<td align=center nowrap><%#Eval("appl_name")%></td>
		<td align=center nowrap><%#Eval("ap_cname1")%></td>
		<td align=center nowrap><%#Eval("apply_no")%></td>
		<td align=center nowrap style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CapplClick('<%#Eval("seq")%>', '<%#Eval("seq1")%>')">[詳細資料]</td>
    </tr>
</ItemTemplate>
<FooterTemplate>
</TABLE>
</FooterTemplate>
</asp:Repeater>
<br />
<div align="center" id="haveData" style="display:<%#page.totRow==0?"":"none"%>">
	<center><font color='blue'>*** 請點選本所編號將資料帶回收發文作業 ***</font></center>
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

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //////////////////////

    //帶回資料
    function SeqClick(x1, x2) {
        if ($("#cgrs").val() == "CS") {
            var nRow = $("#seqnum").val();
            $("#seq_" + nRow, opener.document).val(x1);
            $("#aseq1_" + nRow, opener.document).val(x2);
            $("#seq_" + nRow, opener.document).focus();
        } else {
            var fld = $("#tot_num").val() || "";
            if (fld == "" || fld == "a_1" || fld == "b_1") {
                //window.opener.reg.old_seq.value = x1;
                //window.opener.reg.old_seq1.value = x2;
                //window.opener.reg.keyseq.value = "N";
                //window.opener.reg.btnseq_ok.disabled = false;
                //window.opener.reg.old_seq.focus();
                $("#old_seq", opener.document).val(x1);
                $("#old_seq1", opener.document).val(x2);
                $("#keyseq", opener.document).val("N");
                $("#btnseq_ok", opener.document).triggerHandler("click");
            } else {
                $("#dseq" + fld, opener.document).val(x1)
                $("#dseq1" + fld, opener.document).val(x2);
                $("#keydseq" + fld, opener.document).val("N");
                $("#btndseq_ok" + fld, opener.document).triggerHandler("click");
            }
        }
        window.close();
    }
    //[詳細資料]
    function CapplClick(x1, x2) {
        var url = getRootPath() + "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + x1 + "&seq1=" + x2 + "&submittask=Q";
        window.showModalDialog(url, "", "dialogHeight: 520px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
    }
</script>
