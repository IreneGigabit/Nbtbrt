<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string HTProgCap = "國內案案件進度-查詢";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt62" ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string Title = "";

    protected string SQL = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string fseq = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string step_grade = "";
    protected string ctrl_type = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        seq = Request["seq"] ?? "";
        seq1 = Request["seq1"] ?? "";
        step_grade = Request["step_grade"] ?? "";
        ctrl_type = Request["ctrl_type"] ?? "";

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title+"-查詢";

        if (HTProgRight >= 0) {
            QueryData();

            this.DataBind();
        }
    }

    private void QueryData() {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false).Debug(Request["chkTest"] == "TEST")) {
            SQL = "Select b.*,''fseq,''cgrs_nm,''in_no";
            SQL+=",(select rs_detail from code_br where rs_type=b.rs_type and rs_class=b.rs_class and rs_code=b.rs_code) as rs_code_name";
            if (ctrl_type != "") {
                SQL += ",c.ctrl_date ";
            } else {
                SQL += ",''ctrl_date ";
            }
            SQL += " from vStep_dmt b ";
            if (ctrl_type != "") {
                SQL += " inner join ctrl_dmt c on b.rs_no=c.rs_no and c.ctrl_type='" + ctrl_type + "'";
            }
            SQL += " where b.step_grade<>0";
            if (seq != "") {
                SQL += " and b.seq=" + seq;
            }
            if (seq1 != "") {
                SQL += " and b.seq1='" + seq1 + "'";
            }
            if (step_grade != "") {
                if (Convert.ToInt16(step_grade) > 1) {
                    SQL += " and b.cg='G' and b.rs='R' ";
                }
            }

            if (ReqVal.TryGet("SetOrder") != "") {
                SQL += " order by " + ReqVal.TryGet("SetOrder");
            } else {
                SQL += " order by b.seq,b.seq1,b.step_grade desc";
            }

            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            //處理分頁
            int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
            int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "30"); //每頁筆數
            page = new Paging(nowPage, PerPageSize, SQL);
            page.GetPagedTable(dt);

            //分頁完再處理其他資料才不會虛耗資源
            for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
                DataRow dr = page.pagedTable.Rows[i];
                fseq = Sys.formatSeq(dr.SafeRead("Seq", "")
                    , dr.SafeRead("Seq1", "")
                    , ""
                    , Sys.GetSession("SeBranch")
                    , "T"
                    )+" "+dr.SafeRead("cappl_name","");
                
                //因客收才有對應交辦單
                if (dr.SafeRead("cg", "").ToUpper() == "C" && dr.SafeRead("rs", "").ToUpper() == "R") {
                    SQL = "select in_no from case_dmt where case_no='" + dr.SafeRead("case_no", "") + "'";
                    object objResult1 = conn.ExecuteScalar(SQL);
                    dr["in_no"] = (objResult1 == DBNull.Value || objResult1 == null) ? "" : objResult1.ToString();
                    dr["send_way"] = "";
                }else{
                    dr["case_no"] = "";
                    dr["send_way"] =dr.SafeRead("send_way", "");
                }
                
                if (dr.SafeRead("cg", "").ToUpper() == "C") {
                    dr["cgrs_nm"] = "客";
                } else if (dr.SafeRead("cg", "").ToUpper() == "G") {
                    dr["cgrs_nm"] = "官";
                } else {
                    dr["cgrs_nm"] = "本";
                }
                if (dr.SafeRead("rs", "").ToUpper() == "R" || dr.SafeRead("rs", "").ToUpper() == "Z") {
                    dr["cgrs_nm"] += "收";
                } else {
                    dr["cgrs_nm"] += "發";
                }

            }

            dataRepeater.DataSource = page.pagedTable;
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
        <td class="text9" nowrap="nowrap">&nbsp;【<%=HTProgCode%><%=HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <a class="imgCls" href="javascript:void(0);" >[關閉視窗]</a>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>
<form id="regPage" name="regPage" method="post">
    <%#page.GetHiddenText("GoPage,PerPage,SetOrder")%>
    <div id="divPaging" style="display:<%#page.totRow==0?"none":""%>">
    <TABLE border=0 cellspacing=1 cellpadding=0 width="98%" align="center">
        <tr>
            <td colspan=2 align=center>
                <font size="2" color="#3f8eba">
                第<font color="red"><span id="NowPage"><%#page.nowPage%></span>/<span id="TotPage"><%#page.totPage%></span></font>頁
                | 資料共 <font color="red"><span id="TotRec"><%#page.totRow%></span></font> 筆
                | 跳至第<select id="GoPage" name="GoPage" style="color:#FF0000"><%#page.GetPageList()%></select>頁
                <span id="PageUp" style="display:<%#page.nowPage>1?"":"none"%>">| <a href="javascript:void(0)" class="pgU" v1="<%#page.nowPage-1%>">上一頁</a></span>
                <span id="PageDown" style="display:<%#page.nowPage<page.totPage?"":"none"%>">| <a href="javascript:void(0)" class="pgD" v1="<%#page.nowPage+1%>">下一頁</a></span>
                | 每頁筆數:
                <select id="PerPage" name="PerPage" style="color:#FF0000">
                 <option value="10" <%#page.perPage==10?"selected":""%>>10</option>
                 <option value="20" <%#page.perPage==20?"selected":""%>>20</option>
                 <option value="30" <%#page.perPage==30?"selected":""%>>30</option>
                 <option value="30" <%#page.perPage==40?"selected":""%>>40</option>
                 <option value="50" <%#page.perPage==50?"selected":""%>>50</option>
                </select>
                <input type="hidden" name="SetOrder" id="SetOrder" value="<%#ReqVal.TryGet("qryOrder")%>" />
                </font>
            </td>
        </tr>
    </TABLE>
    </div>
</form>

	<input type="text" id="seqnum" name="seqnum" value="<%=Request["seqnum"]%>"><!--文件掃描新增作業用-->

    <div align="center" id="noData" style="display:<%#page.totRow==0?"":"none"%>">
	    <font color="red">=== 查無案件資料 ===</font>
    </div>

    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
        <div class=whitetablebg align="left">本所編號：<%=fseq%></div>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	        <thead>
                <TR>
			        <TD class=lightbluetable align=center>進度序號</TD>
			        <TD class=lightbluetable align=center>進度日期</TD>
			        <TD class=lightbluetable align=center>進度內容</TD>
			        <%if (prgid=="brt51" || prgid=="brt19"){%>
			             <TD  class=lightbluetable align=center>法定期限</TD>
			        <%}%>
			        <TD class=lightbluetable align=center>作業</TD>
	            </TR>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			    <ItemTemplate>
                    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center">
				        <td>
                            <%#Eval("step_grade")%>-<%#Eval("cgrs_nm")%>
  				            <input type="hidden" id="seq_<%#(Container.ItemIndex+1)%>" name="seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq")%>">
				            <input type="hidden" id="seq1_<%#(Container.ItemIndex+1)%>" name="seq1_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq1")%>">
				            <input type="hidden" id="step_grade_<%#(Container.ItemIndex+1)%>" name="step_grade_<%#(Container.ItemIndex+1)%>" value="<%#Eval("step_grade")%>">
				            <input type="hidden" id="rs_no_<%#(Container.ItemIndex+1)%>" name="rs_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_no")%>">
				            <input type="hidden" id="pcg_<%#(Container.ItemIndex+1)%>" name="pcg_<%#(Container.ItemIndex+1)%>" value="<%#Eval("cg")%>">
				            <input type="hidden" id="prs_<%#(Container.ItemIndex+1)%>" name="prs_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs")%>">
				            <input type="hidden" id="case_no_<%#(Container.ItemIndex+1)%>" name="case_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_no")%>">
				            <input type="hidden" id="in_no_<%#(Container.ItemIndex+1)%>" name="in_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("in_no")%>">
				            <input type="hidden" id="cgrs_nm_<%#(Container.ItemIndex+1)%>" name="cgrs_nm_<%#(Container.ItemIndex+1)%>" value="<%#Eval("cgrs_nm")%>">
				            <input type="hidden" id="rs_detail_<%#(Container.ItemIndex+1)%>" name="rs_detail_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_detail")%>">
				            <input type="hidden" id="send_way_<%#(Container.ItemIndex+1)%>" name="send_way_<%#(Container.ItemIndex+1)%>" value="<%#Eval("send_way")%>">
				            <input type="hidden" id="step_date_<%#(Container.ItemIndex+1)%>" name="step_date_<%#(Container.ItemIndex+1)%>" value="<%#Eval("step_date","{0:yyyy/M/d}")%>">
				            <input type="hidden" id="rs_code_name_<%#(Container.ItemIndex+1)%>" name="rs_code_name_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_code_name")%>">
				        </td>
				        <td nowrap><%#Eval("step_date","{0:yyyy/M/d}")%></td>
				        <td align=left ><%#Eval("rs_detail")%></td>
			            <%if (prgid=="brt51" || prgid=="brt19"){%>
				            <td align=left ><%#Eval("ctrl_date")%>
				                <input type="text" id="ctrl_date_<%#(Container.ItemIndex+1)%>" name="ctrl_date_<%#(Container.ItemIndex+1)%>" value="<%#Eval("ctrl_date")%>">
                            </td>
			            <%}%>
				        <td nowrap align="center">
					        <font style="cursor: pointer;color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'"  onclick="getstep('<%#(Container.ItemIndex+1)%>')">[選取]</font>
				        </td>
		            </tr>
			    </ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
    <br>
    <p style="text-align:center;display:<%#page.totRow==0?"none":""%>">
	    <font color=blue>***請按下 [選取] 帶回對應進度資料***</font>
    </p>
</FooterTemplate>
</asp:Repeater>

<div id="dialog"></div>

</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }
    });

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };

    //取回進度項目
    function getstep(pno) {
        var seqnum=$("#seqnum").val();
        if ("<%=prgid%>" == "brt62") {
            window.opener.reg.step_grade.value = $("#step_grade_" + pno).val();
            window.opener.reg.attach_step_grade.value = $("#step_grade_" + pno).val();
            window.opener.reg.pcg.value = $("#pcg_" + pno).val();
            window.opener.reg.prs.value = $("#prs_" + pno).val();
            window.opener.reg.cgrs.value = $("#pcg_" + pno).val() + $("#prs_" + pno).val();//2012/12/24因應電子申請增加
            window.opener.reg.send_way.value = $("#send_way_" + pno).val();//2012/12/24因應電子申請增加
            window.opener.reg.step_date.value = $("#step_date_" + pno).val();//2012/12/24因應電子申請增加
            window.opener.reg.rs_code_name.value = $("#rs_code_name_" + pno).val();//2012/12/24因應電子申請增加
            window.opener.reg.cgrs_nm.value = $("#cgrs_nm_" + pno).val();
            window.opener.reg.attach_in_no.value = $("#in_no_" + pno).val();
            window.opener.reg.attach_case_no.value = $("#case_no_" + pno).val();
            if ($("#pcg_" + pno).val() == "C" && $("#prs_" + pno).val() == "R") {
                window.opener.reg.uploadsource.value = "CASE";
            }
            window.opener.getSeq();
        } else if ("<%=prgid%>" == "brt611") {
            $("#step_grade_" + seqnum, window.opener.document).val($("#step_grade_" + pno).val());
            $("#cgrs_nm_" + seqnum, window.opener.document).val($("#cgrs_nm_" + pno).val());
            $("#span_rs_detail_" + seqnum, window.opener.document).html($("#cgrs_nm_" + pno).val());
        } else if ("<%=prgid%>" == "brt51") {
            if (CInt(seqnum) == 0) {
                alert("期限管制種類尚未選取「法定期限」，系統無法將選取法定期限資料帶回！！");
            } else {
                $("#ctrl_date_" + seqnum, window.opener.document).val($("#ctrl_date_" + pno).val());
                $("#ctrl_step_grade_" + seqnum, window.opener.document).val($("#step_grade_" + pno).val());
                $("#ctrl_rs_no_" + seqnum, window.opener.document).val($("#rs_no_" + pno).val());
                $("#ctrl_date_" + seqnum, window.opener.document).prop("disabled", true);
                $("#imgctrldate_" + seqnum, window.opener.document).prop("disabled", true);
            }
        } else if ("<%=prgid%>" == "brt19") {
            window.opener.reg.last_date.value = $("#ctrl_date_" + pno).val();
            window.opener.reg.from_step_grade.value = $("#step_grade_" + pno).val();
            window.opener.reg.from_rs_no.value = $("#rs_no_" + pno).val();
            window.opener.reg.last_date.disabled = true;
            window.opener.reg.imglastdate.disabled = true;
            window.opener.reg.from_flag.value = "Y";
        }
        window.close();
    }
</script>
