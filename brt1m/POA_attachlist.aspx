<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string Title = "";
    protected string DebugStr = "";

    protected string SQL = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string uploadfield = "attach";
    protected string kind = "";
    protected string allapsqlno = "";
    protected string cust_seq = "";
    protected string source = "";
    protected string dept = "";
    protected string upload_tabname = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        allapsqlno = Request["allapsqlno"] ?? "";
        kind = Request["kind"] ?? "";
        cust_seq = Request["cust_seq"] ?? "";
        source = (Request["source"] ?? "").ToString().ToLower();
        dept = (Request["dept"] ?? "").ToString().ToUpper();
        upload_tabname = Request["upload_tabname"] ?? "";
        
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;

        if (source == "contract")
            Title = "客戶契約書清單";
        else if (source == "poa")
            Title = "申請人委任書清單";

        if (HTProgRight >= 0) {
            QueryData();
            
            this.DataBind();
        }
    }

    private void QueryData() {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false).Debug(Request["chkTest"] == "TEST")) {
            SQL = "select distinct a.apattach_sqlno,a.apsqlno,a.cust_area,a.cust_seq,a.source,a.in_date,a.in_scode,a.in_prgid,a.contract_no";
            SQL += ",a.sign_flag,a.company,a.dept,a.country,a.sign_scode,a.agt_no,a.agent_no,a.agent_no1,a.attach_no,a.attach_path";
            SQL += ",a.doc_type,a.attach_desc,a.attach_name,a.source_name,a.attach_size,a.attach_flag,a.stop_remark,a.main_dept,a.main_seq,a.main_seq1";
            SQL += ",a.mcontract_no,a.mremark,a.use_dates,a.use_datee";
            SQL += ",(select agt_namefull from agt where agt_no=a.agt_no) as agt_nonm";
            SQL += ",(select agent_na1+isnull(agent_na2,'') from agent23 where agent_no=a.agent_no and agent_no1=a.agent_no1) as agent_na";
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode=a.tran_scode) as tran_scodenm";
            SQL += ",''sign_flagnm,''attach_flagnm,''ref_cust_seqtitle,''ref_cust_seq,''ref_cust_seqnm ";
            SQL += " From apcust_attach a inner join apcust_attach_ref b on a.apattach_sqlno=b.apattach_sqlno";
            SQL += " inner join apcust c on c.apsqlno=b.apsqlno";
            if (source == "contract") {
                string SQL1 = "select apsqlno from apcust where cust_area='" + Session["SeBranch"] + "' and cust_seq=" + cust_seq;
                object objResult1 = conn.ExecuteScalar(SQL1);
                allapsqlno = (objResult1 == DBNull.Value || objResult1 == null) ? allapsqlno : objResult1.ToString();

                SQL += " where b.apsqlno in (" + allapsqlno + ")";
            } else if (source == "poa") {
                if (allapsqlno.IndexOf(",") == -1) {
                    SQL += " where b.apsqlno=" + allapsqlno;
                    SQL += " and sign_flag='S'";
                } else {
                    SQL += " where b.apsqlno in (" + allapsqlno + ")";
                }
            }
            SQL += " and a.dept='" + dept + "' and a.source='" + source + "'";
            if (ReqVal.TryGet("SetOrder") != "") {
                SQL += " order by " + ReqVal.TryGet("SetOrder");
            } else {
                SQL += " order by a.apattach_sqlno";
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
                if (dr.SafeRead("sign_flag", "") == "S")
                    dr["sign_flagnm"] = "單一";
                else if (dr.SafeRead("sign_flag", "") == "M")
                    dr["sign_flagnm"] = "多個";

                if (dr.SafeRead("attach_flag", "") == "E") {
                    dr["attach_flagnm"] = "停用";
                } else {
                    if (dr.GetDateTime("use_datee") >= DateTime.Today) {
                        dr["attach_flagnm"] = "使用中";
                    } else {
                        dr["attach_flagnm"] = "已到期";
                    }
                }

                if (dr.SafeRead("agent_no1", "") != "_") {
                    dr["agent_no"] += "-" + dr.SafeRead("agent_no1", "");
                }

                string ref_cust_seq = "", ref_cust_seqnm = "", ref_cust_seqtitle = "";
                if (source == "contract") {
                    SQL = "select a.apsqlno,b.cust_area,b.cust_seq,(b.ap_cname1+isnull(b.ap_cname2,'')) as ap_cname";
                    SQL += " From apcust_attach_ref a left join apcust b on b.apsqlno=a.apsqlno";
                    SQL += " where apattach_sqlno='" + dr.SafeRead("apattach_sqlno", "") + "'";
                    DataTable dt1 = new DataTable();
                    conn.DataTable(SQL, dt1);
                    for (int d = 0; d < dt1.Rows.Count; d++) {
                        ref_cust_seq += (ref_cust_seq != "" ? "," : "") + dt1.Rows[i]["cust_area"] + dt1.Rows[i]["cust_seq"];
                        ref_cust_seqnm += (ref_cust_seqnm != "" ? "<br>" : "") + dt1.Rows[i]["cust_area"] + dt1.Rows[i]["cust_seq"] + dt.Rows[i].SafeRead("ap_cname", "").CutData(30);
                        ref_cust_seqtitle += (ref_cust_seqtitle != "" ? "、" : "") + dt1.Rows[i]["cust_area"] + dt1.Rows[i]["cust_seq"] + dt1.Rows[i]["ap_cname"];
                    }
                } else {
                    SQL = "select a.apsqlno,b.apcust_no,(b.ap_cname1+isnull(b.ap_cname2,'')) as ap_cname";
                    SQL += " From apcust_attach_ref a left join apcust b on b.apsqlno=a.apsqlno";
                    SQL += " where apattach_sqlno='" + dr.SafeRead("apattach_sqlno", "") + "'";
                    DataTable dt1 = new DataTable();
                    conn.DataTable(SQL, dt1);
                    for (int d = 0; d < dt1.Rows.Count; d++) {
                        ref_cust_seq += (ref_cust_seq != "" ? "," : "") + dt1.Rows[i]["apcust_no"];
                        ref_cust_seqnm += (ref_cust_seqnm != "" ? "、" : "") + dt1.Rows[i]["apcust_no"] + dt.Rows[i].SafeRead("ap_cname", "").CutData(20);
                        ref_cust_seqtitle += (ref_cust_seqtitle != "" ? "、" : "") + dt1.Rows[i]["apcust_no"] + dt1.Rows[i]["ap_cname"];
                    }
                }
                dr["ref_cust_seq"] = ref_cust_seq;
                dr["ref_cust_seqnm"] = ref_cust_seqnm;
                dr["ref_cust_seqtitle"] = ref_cust_seqtitle;

                dr["attach_path"] = Sys.Path2Nbtbrt(dr.SafeRead("attach_path", ""));
            }

            dataRepeater.DataSource = page.pagedTable;
            dataRepeater.DataBind();
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
        <td class="text9" nowrap="nowrap">&nbsp;【<%=prgid%><%=HTProgCap%>】<span style="color:blue"><%=Title%></span></td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <a class="imgCls" href="javascript:void(0);" >[關閉視窗]</a>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>
<form id="regPage" name="regPage" method="post">
    <%#page.GetHiddenText("GoPage,PerPage,SetOrder,chktest")%>
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
                </font><%#DebugStr%>
            </td>
        </tr>
    </TABLE>
    </div>
</form>

    <div align="center" id="noData" style="display:<%#page.totRow==0?"":"none"%>">
	    <font color="red">=== 資料不存在 ===</font>
    </div>

    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	        <thead>
                <Tr>
		            <td class="bluetext2" align="center" nowrap>勾選</td>
		            <td class="bluetext2" align="center" nowrap>種類</td>
                    <%if (source == "contract") {%>
			            <td class="bluetext2" align="center" nowrap>契約書編號</td>
			            <td class="bluetext2" align="center" nowrap>有效期限</td>
			            <td class="bluetext2" align="center" nowrap>單位</td>
			            <td class="bluetext2" align="center" nowrap>客戶編號</td>
                    <%}else{%>
                        <td class="bluetext2" align="center" nowrap>建檔日期</td>
			            <td class="bluetext2" align="center" nowrap>單位</td>
			            <%if (dept == "PE" || dept == "TE") {%>
				            <td class="bluetext2" align="center" nowrap>國別</td> 
				            <td class="bluetext2" align="center" nowrap>代理人</td> 
			            <%}else{%>
				            <td class="bluetext2" align="center" nowrap>出名代理人</td> 
			            <%}%>
			            <td class="bluetext2" align="center" nowrap>申請人編號</td>
                    <%}%>
		            <td class="bluetext2" align="center" nowrap>檔案</td> 
		            <td class="bluetext2" align="center" nowrap>狀態</td>
                </tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			    <ItemTemplate>
 		            <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center">
		                <TD>
                            <%if (kind == "S") {%>
		                        <input type="radio" id="chk_flag<%#(Container.ItemIndex+1)%>" name="chk_flag" value="<%#(Container.ItemIndex+1)%>" <%#Eval("attach_flagnm").ToString()!="使用中"?"disabled":""%>>
                            <%}else{%>
		                        <input type="checkbox" id="chk_flag<%#(Container.ItemIndex+1)%>" name="chk_flag" value="<%#(Container.ItemIndex+1)%>" <%#Eval("attach_flagnm").ToString()!="使用中"?"disabled":""%>>
                            <%}%>
		                </TD>
		                <td nowrap title="<%#Eval("apattach_sqlno")%>"><%#Eval("sign_flagnm")%></td>
                        <%if (source == "contract") {%>
			                <td nowrap><%#Eval("company")%>-<%#Eval("apattach_sqlno")%></td>	
			                <td><%#Eval("use_dates", "{0:d}")%>～<%#Eval("use_datee", "{0:d}")%></td>
			                <td nowrap><%#Eval("cust_area")%><%#Eval("dept")%></td>
                         <%}else{%>
			                <td nowrap><%#Eval("in_date")%></td>
			                <td nowrap><%#Eval("cust_area")%><%#Eval("dept")%></td>
			                <%if (dept == "PE" || dept == "TE") {%>
				                <td nowrap><%#Eval("country")%></td>
				                <td nowrap title="<%#Eval("agent_na")%>">
					                <%#Eval("agent_no")%>
				                </td>
			                <%}else{%>
				                <td nowrap title="<%#Eval("agt_no")%>-<%#Eval("agt_nonm")%>">
					                <%#Eval("agt_no")%>
				                </td>
			                <%}%>
                        <%}%>
		                <td nowrap title="<%#Eval("ref_cust_seqtitle")%>"><%#Eval("ref_cust_seq")%></td>
		                <td nowrap>
		                    <INPUT TYPE="hidden" id="<%=uploadfield%>_apattach_sqlno<%#(Container.ItemIndex+1)%>" name="<%=uploadfield%>_apattach_sqlno<%#(Container.ItemIndex+1)%>" value="<%#Eval("apattach_sqlno")%>">
		                    <INPUT TYPE="hidden" id="<%=uploadfield%><%#(Container.ItemIndex+1)%>" name="<%=uploadfield%><%#(Container.ItemIndex+1)%>" value="<%#Eval("attach_path")%>">
		                    <INPUT TYPE="hidden" id="<%=uploadfield%>_attach_no<%#(Container.ItemIndex+1)%>" name="<%=uploadfield%>_attach_no<%#(Container.ItemIndex+1)%>" value="<%#Eval("attach_no")%>">
		                    <INPUT TYPE="hidden" id="<%=uploadfield%>_path<%#(Container.ItemIndex+1)%>" name="<%=uploadfield%>_path<%#(Container.ItemIndex+1)%>" value="<%#Eval("attach_path")%>">
		                    <INPUT TYPE="hidden" id="<%=uploadfield%>_doc_type<%#(Container.ItemIndex+1)%>" name="<%=uploadfield%>_doc_type<%#(Container.ItemIndex+1)%>" value="<%#Eval("doc_type")%>">
		                    <INPUT TYPE="hidden" id="<%=uploadfield%>_desc<%#(Container.ItemIndex+1)%>" name="<%=uploadfield%>_desc<%#(Container.ItemIndex+1)%>" value="<%#Eval("attach_desc")%>">
		                    <INPUT TYPE="hidden" id="<%=uploadfield%>_name<%#(Container.ItemIndex+1)%>" name="<%=uploadfield%>_name<%#(Container.ItemIndex+1)%>" value="<%#Eval("attach_name")%>">
		                    <INPUT TYPE="hidden" id="<%=uploadfield%>_source_name<%#(Container.ItemIndex+1)%>" name="<%=uploadfield%>_source_name<%#(Container.ItemIndex+1)%>" value="<%#Eval("source_name")%>">
		                    <INPUT TYPE="hidden" id="<%=uploadfield%>_size<%#(Container.ItemIndex+1)%>" name="<%=uploadfield%>_size<%#(Container.ItemIndex+1)%>" value="<%#Eval("attach_size")%>">
		                    <img src="../images/annex.gif" onclick="PreviewAttach(<%#(Container.ItemIndex+1)%>)" style="cursor:pointer;">
		                </td>
		                <td nowrap title="有效期限：<%#Eval("use_dates", "{0:d}")%>～<%#Eval("use_datee", "{0:d}")%>"><%#Eval("attach_flagnm")%></td>
				    </tr>
			    </ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
    <br>
    <TABLE style="display:<%#page.totRow==0?"none":""%>" border=0 class="greentable" cellspacing=0 cellpadding=0 width="100%">
	    <TR align=center>
		    <TD class=whitetablebg nowrap>
			    <input type=button class="greenbutton" id="btn_attachcopy" name="btn_attachcopy" value="複製至個案使用">
		    </td>
	    </tr>
    </TABLE>
    <br>
    <div style="display:<%#page.totRow==0?"none":""%>" align=left><font color=blue>
    註：若委任書是單一申請人簽署，則只要交辦中有該筆申請人即顯示。
    <br>　　若委任書是多個申請人簽署，則需要簽署的多人皆為該案件之申請人才會符合條件。
    <!--請勾選此案使用之委任書(可複選)，點選[複製至個案使用]，系統存檔時即會在該筆交辦附件寫入一筆連結申請人委任書檔之記錄，
    若有異動可至案件附件檔刪除此筆連結，但此處刪除只會刪除該筆交辦連結申請人委任書之記錄，不會刪除實際在申請人檔作業上傳之委任書。-->
    </font></div>
    <INPUT TYPE="hidden" id="kind" name="kind" value="<%#kind%>">
    <INPUT TYPE="hidden" id="cnt" name="cnt" value="<%#page.totRow%>">
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

        //若交辦畫面已有連結要勾選
        var fld = "<%=uploadfield%>";
        var mcnt = CInt($("#" + fld + "_filenum", window.opener.document).val());
        for (var m = 1; m <= mcnt; m++) {
            for (var k = 1; k <= $("#cnt").val() ; k++) {
                if ($("#" + fld + "_apattach_sqlno_" + m, window.opener.document).val() == $("#" + fld + "_apattach_sqlno" + k).val()) {
                    $("#chk_flag" + k).prop("checked", true);
                }
            }
        }
    });

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //////////////////////
    //檢視圖檔
    function PreviewAttach(pno){
        if($("#attach"+pno).val()!=""){
            window.open($("#attach" + pno).val());
        }
    }

    //複製至個案使用
    $("#btn_attachcopy").click(function (e) {
        var fld = "<%=uploadfield%>";
        var source = "<%=source%>";
        var dept = "<%=dept%>";

        if ($("#kind").val() == "S") {//單筆
            $("input[id^='chk_flag']").each(function (i) {
                if ($(this).prop("checked")) {
                    var k = $(this).val();
                    $("#" + fld, window.opener.document).val($("#" + fld + k).val());
                    $("#" + fld + "_path", window.opener.document).val($("#" + fld + "_path" + k).val());
                    $("#" + fld + "_desc", window.opener.document).val($("#" + fld + "_desc" + k).val());
                    $("#" + fld + "_name", window.opener.document).val($("#" + fld + "_name" + k).val());
                    $("#" + fld + "_source_name", window.opener.document).val($("#" + fld + "_source_name" + k).val());
                    $("#" + fld + "_size", window.opener.document).val($("#" + fld + "_size" + k).val());
                    $("#" + fld + "_doc_type", window.opener.document).val("081");//另設總契約書，由08改為081
                    $("#" + fld + "_apattach_sqlno", window.opener.document).val($("#" + fld + "_apattach_sqlno" + k).val());
                    $("#mcontract_no", window.opener.document).val($("#" + fld + "_apattach_sqlno" + k).val());
                    $("#mcontract_path", window.opener.document).val($("#" + fld + "_path" + k).val());
                }
            });
        } else {
            window.opener.settab("#<%#upload_tabname%>");

            var mcnt = CInt($("#" + fld + "_filenum", window.opener.document).val());
            for (var k = 1; k <= CInt($("#cnt").val()) ; k++) {
                if ($("#chk_flag" + k).prop("checked")) {
                    //檢查，若附件畫面已有，則不再加入
                    var chkadd = true;
                    for (var m = 1; m <= mcnt; m++) {
                        if ($("#" + fld + "_apattach_sqlno_" + m, window.opener.document).val() == $("#" + fld + "_apattach_sqlno" + k).val()) {
                            chkadd = false;
                            break;
                        }
                    }

                    if (chkadd) {
                        window.opener.upload_form.appendFile();
                        var pno = $("#" + fld + "_filenum", window.opener.document).val();
                        $("#" + fld + "_" + pno, window.opener.document).val($("#" + fld + k).val());

                        if (source == "contract") {
                            if (dept == "T") {
                                $("#doc_type_" + pno, window.opener.document).val("081");//內外商皆相同契約書doc_type=08，另設總契約書，由08改為081
                            } else if (dept == "TE") {
                                $("#doc_code_" + pno, window.opener.document).val("081");//內外商皆相同契約書doc_type=08，外商欄位為doc_code，另設總契約書，由08改為081
                            }
                            $("#Mcontract_no", window.opener.document).val($("#" + fld + "_apattach_sqlno" + k).val());//帶回總契約號碼
                        } else {
                            if (dept == "T") {
                                $("#doc_type_" + pno, window.opener.document).val("02");//內外商皆相同契約書doc_type=02
                            } else if (dept == "TE") {
                                $("#doc_code_" + pno, window.opener.document).val("02");//內外商皆相同契約書doc_type=02，外商欄位為doc_code
                            }
                        }

                        $("#" + fld + "_desc_" + pno, window.opener.document).val($("#" + fld + "_desc" + k).val());
                        $("#" + fld + "_name_" + pno, window.opener.document).val($("#" + fld + "_name" + k).val());
                        $("#source_name_" + pno, window.opener.document).val($("#" + fld + "_source_name" + k).val());
                        $("#" + fld + "_size_" + pno, window.opener.document).val($("#" + fld + "_size" + k).val());
                        $("#" + fld + "_apattach_sqlno_" + pno, window.opener.document).val($("#" + fld + "_apattach_sqlno" + k).val());
                        $("#btn" + fld + "_" + pno, window.opener.document).prop("disabled", true);
                        $("#attach_flag_" + pno, window.opener.document).val("A");
                    }
                }
            }
        }

        $(".imgCls").click();
    });
</script>
