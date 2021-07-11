<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案洽案交辦查詢";// HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Brt13";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;
    
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";

    protected string submitTask = "";
    protected string homelist = "";

    DataTable dt = new DataTable();
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

        ReqVal = Util.GetRequestParam(Context,Request["chkTest"] == "TEST");
        submitTask = Request["submitTask"] ?? "";

        homelist = ReqVal.TryGet("homelist").ToLower();

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            QueryData();
            PageLayout();

            this.DataBind();
        }
    }

    private void PageLayout() {
        //StrFormBtnTop += "<a href=\"javascript:location.reload()\" >[重新整理]</a>";
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";
        //StrFormBtnTop += "<a href=\"javascript:window.history.back()\" >[回上頁]</a>";
        StrFormBtnTop += "<a href=\"" + HTProgPrefix + ".aspx?prgid=" + prgid + "\" >[回查詢]</a>";

        if (homelist == "homelist") {
            FormName = "備註:<br>\n";
            FormName += "1.案性前的「<img src=\"" + Page.ResolveUrl("~/images/todolist01.jpg") + "\" style=\"cursor:pointer\" align=\"absmiddle\"  border=\"0\">」表示無收費標準<br>\n";
            FormName += "2.在檢核後的<font color=red>*</font>表示本筆交辦案件無上傳文件，會計無法檢核。<br>\n";
            FormName += "3.在「複製」前顯示<font color=red>*</font>表示該客戶債信不良，無法複製交辦<br>\n";
        } else {
            FormName = "備註:<br>\n";
            FormName += "1.案性前的「<img src=\"" + Page.ResolveUrl("~/images/todolist01.jpg") + "\" style=\"cursor:pointer\" align=\"absmiddle\"  border=\"0\">」表示無收費標準<br>\n";
            FormName += "2.狀態(檢核)的檢核「Y」表示會計已檢核文件，「N」表示會計尚未檢核文件，「X」表示不需檢核(指不需請款或扣收入之交辦案件)。<br>\n";
            FormName += "3.在檢核後的<font color=red>*</font>表示本筆交辦案件無上傳文件，會計無法檢核。<br>\n";
            FormName += "4.在「複製」前顯示<font color=red>*</font>表示該客戶債信不良，無法複製交辦<br>\n";
        }
    }

    private void QueryData() {
		SQL =  "SELECT a.in_scode, a.in_no, a.service, a.fees,a.oth_money,isnull(b.seq,a.seq)seq,isnull(b.seq1,a.seq1)seq1, b.appl_name, a.case_date ";
		SQL +=",b.class, a.arcase, a.ar_mark, ISNULL(a.discount, 0) AS discount, d.cust_name ";
		SQL +=",a.case_num, a.stat_code, a.cust_area, a.cust_seq,a.arcase_type,a.arcase_class ";
		SQL +=",a.ar_code,a.ar_curr,a.change,a.trancase_sqlno,a.acc_chk,a.add_service,a.add_fees";
		SQL +=",a.case_no,a.contract_flag,a.contract_flag_date,a.contract_no,a.contract_type,(select sc_name from sysctrl.dbo.scode where scode = a.in_scode) as sc_name ";
		SQL +=",(SELECT code_name FROM cust_code WHERE code_type ='scode' AND cust_code = a.stat_code) AS Nstat_code ";
		SQL +=",(SELECT rs_detail FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' and rs_type=a.arcase_type) AS case_name ";	
		SQL +=",(SELECT rs_class FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' and rs_type=a.arcase_type) AS Ar_form ";
		SQL +=",(SELECT prt_code FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' and rs_type=a.arcase_type) AS prt_code ";
		SQL +=",(SELECT classp FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' and rs_type=a.arcase_type) AS classp ";
		SQL +=",isnull((select count(*) from dmt_attach where in_no=a.in_no),0) as attach_num ";
        SQL += ",a.service+isnull(a.add_service,0) as a_service,a.fees+isnull(a.add_fees,0) as a_fees ";
        SQL += ",d.rmark_code ";
        SQL += ",''fseq,''new_form,''urlasp,''strcontract_no,''strcontract_flag ";
		SQL +=" FROM case_dmt a INNER JOIN dmt_temp b ON a.in_scode = b.in_scode AND a.in_no = b.in_no ";
		SQL +=" INNER JOIN VIEW_Cust d ON a.cust_seq = d.cust_seq AND a.cust_area = d.cust_area ";
        SQL += " WHERE a.cust_area like '" + Request["tfx_cust_area"] + "%' ";
        SQL += " and case_sqlno=0 and (a.mark='N' or a.mark is null) ";

        if (ReqVal.TryGet("tfx_cust_seq") != "") {
            SQL += "AND a.cust_seq ='" + Request["tfx_cust_seq"] + "' ";
        }

        if (ReqVal.TryGet("tfx_Arcase") != "") {
            SQL += "AND a.Arcase ='" + Request["tfx_Arcase"] + "' ";
        }

        if (ReqVal.TryGet("tfx_case_no") != "") {
            SQL += "AND a.case_no ='" + Request["tfx_case_no"] + "' ";
        }

        if (ReqVal.TryGet("pfx_seq") != "") {
            SQL += "AND b.seq ='" + Request["pfx_seq"] + "' ";
        }

        if (ReqVal.TryGet("scode") != ""&&ReqVal.TryGet("scode") != "*") {
            SQL += "AND a.in_scode ='" + Request["scode"] + "' ";
        }

        if (ReqVal.TryGet("pfx_Cust_name") != "") {
            SQL += "AND d.cust_name like '%" + Request["pfx_Cust_name"] + "%' ";
        }

        if (ReqVal.TryGet("tfx_contract_no") != "") {
            SQL += "AND a.contract_no like '%" + Request["tfx_contract_no"] + "%' ";
        }

		//2016/2/24增加契約書種類
        if (ReqVal.TryGet("contract_no_type") != ""&&ReqVal.TryGet("contract_no_type") != "*") {
            SQL += "AND a.contract_type ='" + Request["contract_no_type"] + "' ";
        }

		//2016/2/24增加契約書後補狀態
        if (ReqVal.TryGet("contract_flag") != "") {
            SQL += " and a.contract_flag='" + Request["contract_flag"] + "'";
            if (ReqVal.TryGet("contract_flag1") == "N") {
                SQL += " and a.contract_flag_date is null ";
            } else if (ReqVal.TryGet("contract_flag1") == "Y") {
                SQL += " and a.contract_flag_date is not null ";
            }
        }
        
        if (ReqVal.TryGet("stat_code1") == "Y") {
			 SQL += " and a.stat_code like 'Y%' and a.stat_code<>'YZ'";
        } else if (ReqVal.TryGet("stat_code1") == "Z") {
            //2013/9/10增加，工作清單之已交辦未經會計契約書檢核
            SQL += " and stat_code='YZ' and a.ar_code='N' and (a.acc_chk='N' or a.acc_chk is null) ";
        } else {
            if (ReqVal.TryGet("tfx_stat_code") != "") {
                string Sql13 = " and a.stat_code = '" + Request["tfx_stat_code"] + "'";
                if (ReqVal.TryGet("tfx_stat_code") == "YY" && ReqVal.TryGet("item") == "s2") {
                    Sql13 = " and (a.stat_code = '" + Request["tfx_stat_code"] + "' or a.stat_code = 'YZ') and a.case_date between '" + Request["STdate"] + "' and '" + Request["ENdate"] + "'";
                }
                if (ReqVal.TryGet("tfx_stat_code") == "YN") {
                    Sql13 = " and (a.stat_code = '" + Request["tfx_stat_code"] + "' or a.stat_code = 'YT')";
                }
                SQL += Sql13;
            }
        }

        if (ReqVal.TryGet("ChangeDate") != "") {
            if (ReqVal.TryGet("ChangeDate") == "A") {
                SQL += "and a.in_date between '" + Request["CustDate1"] + "' and '" + Request["CustDate2"] + "' ";
            } else {
                SQL += "and a.case_date between '" + Request["CustDate1"] + "' and '" + Request["CustDate2"] + "' ";
            }
        }

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "a.in_no"));
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));

            string ar_form, prt_code, classp, new_form;
            Sys.getCaseDmtAspx(dr.SafeRead("arcase_type", ""), dr.SafeRead("arcase", ""), out ar_form, out prt_code, out classp, out new_form);
            dr["ar_form"] = ar_form;
            dr["prt_code"] = prt_code;
            dr["classp"] = classp;
            dr["new_form"] = new_form;
            //Sys.showLog(dr.SafeRead("arcase_type", ""));
            //Sys.showLog(dr.SafeRead("arcase", ""));
            dr["cust_name"] = dr.SafeRead("cust_name", "").ToUnicode().Left(5);
            dr["appl_name"] = dr.SafeRead("appl_name", "").ToUnicode().Left(20);
            dr["case_name"] = dr.SafeRead("case_name", "").ToUnicode().Left(6);

            string strcontract_no = "";
            switch (dr.SafeRead("contract_type", ""))
	        {
                case "A":
                    strcontract_no = "後續案無契約書"; break;
                case "C":
                    strcontract_no = "其他契約書無編號/特案簽報"; break;
                case "M":
                    strcontract_no = "總契約書："+dr.SafeRead("contract_no", ""); break;
		        default:
                    strcontract_no=dr.SafeRead("contract_no", ""); break;
	        }
            dr["strcontract_no"] = (strcontract_no != "" ? "<br><font color=red>(" + strcontract_no + ")</font>" : "");

            string strcontract_flag = "";
            if(dr.SafeRead("contract_flag", "")=="Y"){
                strcontract_flag+="<br><font color=red>(契約書後補";
                if (dr.SafeRead("contract_flag_date", "") != "") {//有日期表示已補
                    strcontract_flag+="，"+dr.GetDateTimeString("contract_flag_date", "yyyy/M/d")+"完成";
                }
                strcontract_flag+=")</font>";
            }
            dr["strcontract_flag"] = strcontract_flag;
            
            //連結的url
            dr["urlasp"] = Sys.getCase11Aspx(prgid, dr.SafeRead("in_no",""), dr.SafeRead("in_scode",""), "Show");
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    //狀態(檢核)
    protected string GetNXLink(RepeaterItem Container) {
        string change = Eval("change").ToString();
        string acc_chk = Eval("acc_chk").ToString();
        string attach_num = Eval("attach_num").ToString();
        string stat_code = Eval("stat_code").ToString();
        string ar_code = Eval("ar_code").ToString();

        string strstat_code = Eval("Nstat_code").ToString();
        if (change == "X") {
            strstat_code = "註銷";
        }
        if (change == "Y") {
            strstat_code = "異動請核中";
        }

        string stracc_chk = "";
        switch (acc_chk) {
            case "Y":
                stracc_chk = "(Y)"; break;
            case "N":
                if (Convert.ToInt32("0"+attach_num) == 0) {
                    stracc_chk = "(N<font color=red>*</font>)";
                } else {
                    stracc_chk = "(N)";
                }
                break;
            case "X":
                stracc_chk = "(X)"; break;
            default:
                if (stat_code == "YZ") {
                    if (ar_code == "X") {
                        stracc_chk = "(X)";
                    }
                } else {
                    if (Convert.ToInt32("0" + attach_num) == 0) {
                        stracc_chk = "(N<font color=red>*</font>)";
                    } else {
                        stracc_chk = "(N)";
                    }
                }
                break;
        }

        if (stat_code != "NN") {
            return "<a href='" + Page.ResolveUrl("~/Brt4m/Brt13_ListA.aspx") +
                    "?prgid=" + prgid +
                    "&in_scode=" + Eval("in_scode") +
                    "&in_no=" + Eval("in_no") +
                    "&ar_form=" + Eval("ar_form") +
                    "&homelist=" + Request["homelist"] +
                    "&qs_dept=T' target='Eblank'>" + strstat_code + stracc_chk + "</a>";
        } else {
            return strstat_code + stracc_chk;
        }
    }

    //異動
    protected string GetTranLink(RepeaterItem Container) {
        string trancase_sqlno = Eval("trancase_sqlno").ToString();
        if (Eval("trancase_sqlno").ToString() != "") {
            //***todo
            return "<a href='" + Page.ResolveUrl("~/Brt4m/Brt13_List1.aspx") + "?prgid=" + prgid + "&case_no=" + Eval("case_no") + "&seq=" + Eval("seq") + "&seq1=" + Eval("seq1") + "' target='Eblank'>明細</a>";
        }
        return "";
    }

    //作業
    protected string GetCopyLink(RepeaterItem Container) {
        string rmark_code = Eval("rmark_code").ToString();
        if (rmark_code.Left(2) != "E2") {
            return "<a href='javascript:void(0);' onclick='copycase(" + (Container.ItemIndex + 1) + ")'>複製</a>";
        } else {
            return "<font color=red>*</font>複製";//債信不良不可複製
        }
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
<input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
<INPUT TYPE="hidden" name=submitTask id=submitTask value="AddNext">
<INPUT TYPE="hidden" name=uploadtype id=uploadtype value="case">
<INPUT TYPE="hidden" name=tscode id=tscode />
<INPUT TYPE="hidden" name=cust_area id=cust_area />
<INPUT TYPE="hidden" name=cust_seq id=cust_seq />
<INPUT TYPE="hidden" name=in_no id=in_no />
<INPUT TYPE="hidden" name=ar_form id=ar_form />
<INPUT TYPE="hidden" name=prt_code id=prt_code />
<INPUT TYPE="hidden" name=code_type id=code_type  value="<%=Sys.getRsType()%>"/>
<INPUT TYPE="hidden" name=new_form id=new_form />
<INPUT TYPE="hidden" name=add_arcase id=add_arcase />

<asp:Repeater id="dataRepeater" runat="server">
<HeaderTemplate>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	    <thead>
            <Tr class="lightbluetable">
                <td align="center" nowrap>接洽序號</td>
                <td align="center" nowrap>交辦單號</td>
	            <td align="center" nowrap>案件編號</td>
	            <td align="center" nowrap>客戶名稱</td>
	            <td align="center" nowrap>案件名稱</td>	
	            <td align="center">類別</td>
	            <td align="center" width="15%">案性</td>
	            <td align="center">服務費</td>
	            <td align="center">規費</td>
	            <td align="center">轉帳<br>費用</td>
	            <td align="center">狀態(檢核)</td>
	            <td align="center">異動</td>
                <%if(prgid=="brt12"){%>
	            <td align="center">作業</td>
                <%}%>
            </Tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
                    <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("In_scode")%>-<%#Eval("in_no")%><%#Eval("strcontract_no")%></a></td>
	                <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("case_no")%><%#Eval("strcontract_flag")%></a></td>
	                <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("fseq")%></a></td>
	                <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("cust_name")%></a></td>
	                <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("appl_name")%></a></td>
	                <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("Class")%></a></td>
	                <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("case_name")%></a></td>
	                <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("a_service")%></a></td>
	                <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("a_fees")%></a></td>
	                <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("oth_money")%></a></td>
	                <td align="center"><%#Eval("stat_code")%><%#GetNXLink(Container)%></td>
		            <td align="center"><%#GetTranLink(Container)%></td>
                    <%if(prgid=="brt12"){%>
                        <td align="center"><%#GetCopyLink(Container)%>
                            <INPUT TYPE=hidden id=tscode_<%#(Container.ItemIndex+1)%> value="<%#Eval("in_scode")%>">
                            <INPUT TYPE=hidden id=cust_area_<%#(Container.ItemIndex+1)%> value="<%#Eval("cust_area")%>">
                            <INPUT TYPE=hidden id=cust_seq_<%#(Container.ItemIndex+1)%> value="<%#Eval("cust_seq")%>">
                            <INPUT TYPE=hidden id=in_no_<%#(Container.ItemIndex+1)%> value="<%#Eval("in_no")%>">
                            <INPUT TYPE=hidden id=ar_form_<%#(Container.ItemIndex+1)%> value="<%#Eval("ar_Form")%>">
                            <INPUT TYPE=hidden id=prt_code_<%#(Container.ItemIndex+1)%> value="<%#Eval("prt_code")%>"><!--arcase_class-->
                            <INPUT TYPE=hidden id=new_form_<%#(Container.ItemIndex+1)%> value="<%#Eval("new_form")%>">
                            <INPUT TYPE=hidden id=add_arcase_<%#(Container.ItemIndex+1)%> value="<%#Eval("arcase")%>">
                        </td>
                    <%}%>
				</tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
	<BR>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		<tr class="FormName"><td><div align="left" style="color:blue"><%#FormName%></div></td></tr>
	</table>
	<br>
</FooterTemplate>
</asp:Repeater>

<%#DebugStr%>
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

    //複製
    function copycase(i) {
        $("#tscode").val($("#tscode_" + i).val());
        $("#cust_area").val($("#cust_area_" + i).val());
        $("#cust_seq").val($("#cust_seq_" + i).val());
        $("#in_no").val($("#in_no_" + i).val());
        $("#ar_form").val($("#ar_form_" + i).val());
        $("#prt_code").val($("#prt_code_" + i).val());
        $("#new_form").val($("#new_form_" + i).val());
        $("#add_arcase").val($("#add_arcase_" + i).val());

        reg.action = getRootPath() + "/brt1m/Brt11Add" + $("#new_form").val() + ".aspx";
        reg.submitTask.value = "AddNext";
        reg.submit();
    }
</script>
