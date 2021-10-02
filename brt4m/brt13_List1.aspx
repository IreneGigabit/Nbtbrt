<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "案件資料異動清單";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Brt13";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult=null;
    
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected DataTable dt = new DataTable();

    protected string gs_dept = "";
    protected string strdept = "";
    protected string tblname = "";
    protected string appl_name = "";
    protected string fseq = "";
    
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

        if (prgid.IndexOf("brt") > -1) {//國內案
            gs_dept = "t";
            strdept = "T";
            tblname = "dmt";
        } else if (prgid.IndexOf("ext") > -1) {//出口案
            gs_dept = "e";
            strdept = "TE";
            tblname = "ext";
        }
        fseq = Sys.formatSeq(Request["seq"], Request["seq1"], "", "", "");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            QueryData();

            this.DataBind();
        }
    }

    private void QueryData() {
        SQL = "select appl_name from " + tblname + " where seq='" + Request["seq"] + "' and seq1='" + Request["seq1"] + "'";
        objResult = conn.ExecuteScalar(SQL);
        appl_name = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString().Trim();

        SQL = "SELECT a.*";
        SQL += ",(select sc_name from sysctrl.dbo.scode where scode=a.input_scode) as input_scodenm";
        SQL += ",(select sc_name from sysctrl.dbo.scode where scode=a.in_scode) as scodenm";
        SQL += ",(select ap_cname1+isnull(ap_cname2,'') from apcust where cust_area=a.cust_area and cust_seq=a.cust_seq) as ap_cname";
        SQL += ",''att_sqlnm,''arcase_casenm,''arcasenm,''tran_statusnm";
        SQL += " FROM casetran_brt a";
        SQL += " WHERE a.case_no = '" + Request["case_no"] + "' ";
        if (strdept == "T") SQL += " AND country='T'";
        if (strdept == "TE") SQL += "  AND country<>'T'";
        SQL += " and tran_status in ('CZ','DZ')";
        SQL += " order by sqlno desc";
        conn.DataTable(SQL, dt);
        //Sys.showLog(SQL);
        for (int i = 0; i < dt.Rows.Count; i++) {
            DataRow dr = dt.Rows[i];

            SQL = "select attention from custz_att where cust_area='" + dr["cust_area"] + "' and cust_seq=" + dr["cust_seq"];
            SQL += " and att_sql='" + dr["att_sql"] + "'";
            objResult = conn.ExecuteScalar(SQL);
            dr["att_sqlnm"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            if (strdept == "T") {
                SQL = "select code_name from cust_code where code_type='" + dr["arcase_type"] + "' and cust_code='" + dr["arcase_class"] + "'";
                objResult = conn.ExecuteScalar(SQL);
                dr["arcase_casenm"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

                SQL = "select rs_detail as case_name from code_br";
                SQL += " where dept='T' and cr='Y' and rs_type='" + dr["arcase_type"] + "' and rs_code='" + dr["arcase"] + "'";
                objResult = conn.ExecuteScalar(SQL);
                dr["arcasenm"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            } else if (strdept == "TE") {
                SQL = "select code_name from cust_code where code_type='T' and cust_code='" + dr["arcase_class"] + "'";
                objResult = conn.ExecuteScalar(SQL);
                dr["arcase_casenm"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

                SQL = "select rs_detail as case_name from code_brt";
                SQL += " where dept='TE' and cg='C' and rs='R' and no_code='N' and rs_code='" + dr["arcase"] + "'";
                objResult = conn.ExecuteScalar(SQL);
                dr["arcasenm"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            }
            if (dr.SafeRead("arcase_casenm", "") != "") {
                dr["arcase_casenm"] += "-";
            }

            switch (dr.SafeRead("tran_status", "").Left(1)) {
                case "C": dr["tran_statusnm"] = "更正"; break;
                case "D": dr["tran_statusnm"] = "註銷"; break;
            }
        }

        dataRepeater.DataSource = dt;
        dataRepeater.DataBind();
    }

    //[異動單]
    protected string Get81Link(RepeaterItem Container) {
        string source_ap = Eval("source_ap").ToString();
        if (source_ap == "") {
            //***todo異動
            return "<a href='" + Page.ResolveUrl("~/brt8m/brt81show.aspx") +
                    "?prgid=" + prgid + "submit=Q&qs_dept=" + gs_dept + "&sqlno=" + Eval("sqlno") + "&case_no=" + Eval("case_no") + "&in_no=" + Eval("in_no") + "' target='_blank'>[異動單]</a>";
        }
        return "";
    }
    
    //異動明細
    protected void dataRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            string sqlno = DataBinder.Eval(e.Item.DataItem, "sqlno").ToString();
            string cust_area = DataBinder.Eval(e.Item.DataItem, "cust_area").ToString();
            string cust_seq = DataBinder.Eval(e.Item.DataItem, "cust_seq").ToString();
            string arcase_type = DataBinder.Eval(e.Item.DataItem, "arcase_type").ToString();
            string case_no = DataBinder.Eval(e.Item.DataItem, "arcase_type").ToString();

            Repeater tranRpt = (Repeater)e.Item.FindControl("tranRepeater");
            Label trancount = (Label)e.Item.FindControl("trancount");
            if ((tranRpt != null)) {
                DataTable dtDtl = new DataTable();
                SQL = "select trand_sqlno,pr_meth,item_seq,cor_table,cor_item,cor_field,cor_content,ar_no";
                SQL += ",(select code_name from cust_code where code_type='cor_item' and cust_code=a.cor_item) as cor_itemnm";
                SQL += ",''cor_itemnm,''cor_fieldnm,''cor_contentnm";
                SQL += " from casetrand_brt a where tran_sqlno=" + sqlno + " and pr_meth<>'undo'";
                SQL += " order by trand_sqlno";
                conn.DataTable(SQL, dtDtl);

                trancount.Text = dtDtl.Rows.Count.ToString();

                for (int i = 0; i < dtDtl.Rows.Count; i++) {
                    DataRow dr = dtDtl.Rows[i];

                    string cor_field = dr.SafeRead("cor_field", "");
                    string cor_itemnm = "", cor_fieldnm = "", cor_contentnm = "";

                    cor_contentnm = dr.SafeRead("cor_content", "");

                    if (cor_field == "cust_seq") {
                        cor_fieldnm = "客戶編號";
                    } else if (cor_field == "att_sql") {
                        cor_fieldnm = "聯絡人";
                        SQL = "select attention from custz_att where cust_area='" + cust_area + "'";
                        SQL += " and cust_seq='" + cust_seq + "' and att_sql='" + dr["cor_content"] + "'";
                        cor_contentnm = dr["cor_content"] + "_" + conn.getString(SQL);
                    } else if (cor_field.IN("scode1,scode")) {
                        cor_fieldnm = "洽案營洽";
                        SQL = "select sc_name from scode where scode='" + dr["cor_content"] + "'";
                        cor_contentnm = conn.getString(SQL);
                    } else if (cor_field == "country") {
                        cor_fieldnm = "國籍";
                    } else if (cor_field == "arcase_type") {
                        cor_fieldnm = "案性代碼種類(版本)";
                    } else if (cor_field.IN("arcase_class,item")) {
                        cor_fieldnm = "案性類別";
                        if (strdept == "T") {
                            SQL = "select code_name from cust_code where code_type='" + arcase_type + "' and cust_code='" + dr["cor_content"] + "'";
                        } else if (strdept == "TE") {
                            SQL = "select code_name from cust_code where code_type='T' and cust_code='" + dr["cor_content"] + "'";
                        }
                        cor_contentnm = dr["cor_content"] + "_" + conn.getString(SQL);
                    } else if (cor_field.IN("arcase,arcase0")) {
                        cor_fieldnm = "主委辦案性";
                        if (strdept == "T") {
                            SQL = "select rs_detail as case_name from code_br";
                            SQL += " where dept='T' and cr='Y' and rs_type='" + arcase_type + "' and rs_code='" + dr["cor_content"] + "'";
                        } else if (strdept == "TE") {
                            SQL = "select rs_detail as case_name from code_brt";
                            SQL += " where dept='TE' and cg='C' and rs='R' and no_code='N' and rs_code='" + dr["cor_content"] + "'";
                        }
                        cor_contentnm = dr["cor_content"] + "_" + conn.getString(SQL);
                    } else if (cor_field.IN("arcase1,arcase2,arcase3,arcase4,arcase5")) {
                        cor_fieldnm = "次委辦案性";
                        if (strdept == "T") {
                            SQL = "select rs_detail as case_name from code_br";
                            SQL += " where dept='T' and cr='Y' and rs_type='" + arcase_type + "' and rs_code='" + dr["cor_content"] + "'";
                        } else if (strdept == "TE") {
                            SQL = "select rs_detail as case_name from code_brt";
                            SQL += " where dept='TE' and cg='C' and rs='R' and no_code='N' and rs_code='" + dr["cor_content"] + "'";
                        }
                        cor_contentnm = dr["cor_content"] + "_" + conn.getString(SQL);
                    } else if (cor_field == "arcase9") {
                        cor_fieldnm = "公簽證案性";
                        SQL = "select rs_detail as case_name from code_brt";
                        SQL += " where dept='TE' and cg='C' and rs='R' and no_code='N' and rs_code='" + dr["cor_content"] + "'";
                        cor_contentnm = dr["cor_content"] + "_" + conn.getString(SQL);
                    } else if (cor_field == "source") {
                        cor_fieldnm = "案源代碼";
                        SQL = "select code_name from cust_code where code_type='source' and cust_code='" + dr["cor_content"] + "'";
                        cor_contentnm = dr["cor_content"] + "_" + conn.getString(SQL);
                    } else if (cor_field.IN("service,service0")) {
                        cor_fieldnm = "主委辦服務費";
                    } else if (cor_field.IN("service1,service2,service3,service4,service5")) {
                        cor_fieldnm = "次委辦服務費";
                    } else if (cor_field.IN("service9")) {
                        cor_fieldnm = "公簽證服務費";
                    } else if (cor_field.IN("fees,fee,fees0")) {
                        cor_fieldnm = "主委辦規費";
                    } else if (cor_field.IN("fees1,fees2,fees3,fees4,fees5,fees6,fees7,fees8")) {
                        cor_fieldnm = "次委辦規費";
                    } else if (cor_field.IN("fees9")) {
                        cor_fieldnm = "公簽證規費";
                    } else if (cor_field == "oth_arcase") {
                        cor_fieldnm = "轉帳案性";
                        SQL = "select rs_detail as case_name from code_br";
                        SQL += " where dept='T' and rs_type='" + arcase_type + "' and rs_code='" + dr["cor_content"] + "'";
                        cor_contentnm = dr["cor_content"] + "_" + conn.getString(SQL);
                    } else if (cor_field.IN("tr_money,oth_money")) {
                        cor_fieldnm = "轉帳費用";
                    } else if (cor_field.IN("tr_dept,oth_code")) {
                        cor_fieldnm = "轉帳單位";
                        SQL = "select branchname from branch_code where branch='" + dr["cor_content"] + "'";
                        cor_contentnm = conn.getString(SQL);
                    } else if (cor_field.IN("ar_code")) {
                        cor_fieldnm = "請款是否開立完畢";
                    } else if (cor_field.IN("contract_no")) {
                        cor_fieldnm = "契約號碼";
                        if (dr.SafeRead("cor_content", "") == "A") {
                            cor_contentnm = "後續案無契約書";
                        } else if (dr.SafeRead("cor_content", "") == "B") {
                            cor_contentnm = "特案簽報";
                        } else if (dr.SafeRead("cor_content", "") == "C") {
                            cor_contentnm = "其他契約書無編號";
                        }
                    } else if (cor_field.IN("ar_mark")) {
                        cor_fieldnm = "請款註記";
                        SQL = "select code_name from cust_code where code_type='ar_mark' and cust_code='" + dr["cor_content"] + "'";
                        cor_contentnm = dr["cor_content"] + "_" + conn.getString(SQL);
                    } else if (cor_field.IN("discount")) {
                        cor_fieldnm = "折扣率";
                    } else if (cor_field.IN("spay_times")) {
                        cor_fieldnm = "繳年費起年";
                    } else if (cor_field.IN("epay_times")) {
                        cor_fieldnm = "繳年費迄年";
                    } else if (cor_field.IN("apcust_no")) {
                        cor_fieldnm = "申請人";
                        SQL = "select ap_cname1+isnull(ap_cname2,'') from apcust where apcust_no='" + dr["cor_content"] + "'";
                        cor_contentnm = dr["cor_content"] + "_" + conn.getString(SQL);
                    } else if (cor_field.IN("all")) {
                        cor_fieldnm = "註銷";
                        cor_contentnm = "註銷";
                    }

                    if (dr.SafeRead("cor_item", "") == "all") {
                        if (dr.SafeRead("cor_table", "").IN("case_dmt,case_ext")) {
                            cor_itemnm = "交辦註銷";
                            cor_fieldnm = "交辦單號";
                            cor_contentnm = case_no;
                        } else if (dr.SafeRead("cor_table", "").IN("artmain")) {
                            cor_itemnm = "請款註銷";
                            cor_fieldnm = "請款單號";
                            cor_contentnm = dr.SafeRead("ar_no", "");
                        } else {
                            cor_itemnm = "註銷";
                        }
                    } else {
                        cor_itemnm = dr.SafeRead("cor_itemnm", "");
                    }

                    dr["cor_itemnm"] = cor_itemnm;
                    dr["cor_fieldnm"] = cor_fieldnm;
                    dr["cor_contentnm"] = cor_contentnm;
                }

                if (dtDtl.Rows.Count > 0) {
                    tranRpt.DataSource = dtDtl;
                    tranRpt.DataBind();
                } else {
                    tranRpt.Visible = false;
                }
            }
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
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=prgid%><%=HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <a class="imgCls" href="javascript:void(0);" >[關閉視窗]</a>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>


<asp:Repeater id="dataRepeater" runat="server" OnItemDataBound="dataRepeater_ItemDataBound">
<HeaderTemplate>
    <table align=center width="90%">
	    <tr style="display:<%#dt.Rows.Count==0?"none":""%>">
            <td align=left class=gfont9><font size=2>交辦單號:<%=Request["case_no"]%>&nbsp;&nbsp;&nbsp;&nbsp;本所編號：<%=fseq%>&nbsp;&nbsp;<%=appl_name%></td>
		    <td align=right><a href="javascript:void(0)" id="showall" onclick="fshowall()" title="N"><span class=showallnm>全部展開</span><span class=showallnm style="display:none">全部關閉</span></a></td>
	    </tr>
	    <tr style="display:<%#dt.Rows.Count==0?"":"none"%>">
            <td align=left class=gfont9><font size=2>交辦單號:<%=Request["case_no"]%>&nbsp;&nbsp;&nbsp;&nbsp;本所編號：<%=fseq%>&nbsp;&nbsp;<%=appl_name%></td>
	    </tr>
	    <tr style="display:<%#dt.Rows.Count==0?"":"none"%>">
            <td align=center><div align="center"><font color="red">=== 目前無異動資料===</font></div></td>
	    </tr>
	</table>	
    <table style="display:<%#dt.Rows.Count==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="90%" align="center" id="dataList">
	    <thead>
            <TR align="center" class="greenths">
		        <td nowrap>流水號</td>
		        <td>營洽</td>
		        <td>客戶名稱</td>
		        <td>聯絡人</td>
		        <td>案性</td>
		        <td nowrap>異動狀態</td>
		        <td nowrap>填單人員</td>
		        <td nowrap>填單日期</td>
		        <td nowrap>異動資料</td>
	        </TR>
	    </thead>
	    <tbody>
</HeaderTemplate>
	<ItemTemplate>
        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center">
		    <td><%#Eval("sqlno")%></td>
		    <td title="<%#Eval("in_scode")%>"><%#Eval("scodenm")%></td>
		    <td><%#Eval("cust_area")%><%#Eval("cust_seq")%><%#Eval("ap_cname").ToString().Left(6)%></td>
		    <td><%#Eval("att_sql")%>_<%#Eval("att_sqlnm")%></td>
		    <td title="<%#Eval("arcase_type")%>-<%#Eval("arcase_class")%>-<%#Eval("arcase")%>"><%#Eval("arcase_casenm")%><%#Eval("arcase")%><%#Eval("arcasenm")%></td>
		    <td><%#Eval("tran_statusnm")%></td>
		    <td><%#Eval("input_scodenm")%></td>
		    <td><%#Eval("input_date")%></td>
		    <td nowrap>
                <%#Get81Link(Container)%><!--[異動單]-->
				<a href="javascript:void(0)" onclick="showdetail('<%#(Container.ItemIndex+1)%>')"><asp:Label ID="trancount" runat="server"></asp:Label>筆
					<img id="imgdetail_<%#(Container.ItemIndex+1)%>" src="../images/2.gif" border="0" WIDTH="11" HEIGHT="11" style="cursor:pointer">
				</a>
		    </td>
        </tr>
	    <tr id="detail_<%#(Container.ItemIndex+1)%>" style="display:none" class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		    <td colspan=12>
	            <asp:Repeater id="tranRepeater" runat="server">
                    <HeaderTemplate>
                        <table width="90%" border=1 cellspacing="1" cellpadding=0 align="right" style="color:darkblue;FONT-SIZE:9pt;border-top-width:1px;border-bottom-width:1px;border-left-width:0px;border-right-width:0px;">
		                <tr align="center"  bgcolor=Linen><td>異動項目</td><td>異動欄位</td><td>異動資料</td></tr>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center">
			                <td title="<%#Eval("cor_item")%>">&nbsp;<%#Eval("cor_itemnm")%></td>
			                <td title="<%#Eval("cor_field")%>">&nbsp;<%#Eval("cor_fieldnm")%></td>
			                <td title="<%#Eval("cor_content")%>">&nbsp;<%#Eval("cor_contentnm")%></td>
		                </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                        </table>
                    </FooterTemplate>
			    </asp:Repeater>
		    </td>
	    </tr>
	</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
</FooterTemplate>
</asp:Repeater>
<br>

<div id="dialog"></div>

</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "30%,70%";
        }
    });

    function fshowall(){
        $(".showallnm").toggle();
        if($("#showall").attr("title")=="N"){
           $("#showall").attr("title","Y");
            $("img[id^=imgdetail_").attr("src", "../images/1.gif");
            $("tr[id^=detail_]").show();
        }else{
           $("#showall").attr("title","N");
            $("img[id^=imgdetail_").attr("src", "../images/2.gif");
            $("tr[id^=detail_]").hide();
        }
    }

    function showdetail(k){
        $("#detail_"+k).toggle();
        if ($("#detail_"+k).is(":visible")) {
            $("#imgdetail_"+k).attr("src", "../images/1.gif");
        } else {
            $("#imgdetail_"+k).attr("src", "../images/2.gif");
        }
    }
</script>
