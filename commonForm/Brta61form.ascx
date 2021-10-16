<%@ Control Language="C#" ClassName="brta61form" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data"%>

<script runat="server">
    //進度查詢明細欄位畫面
    //父控制項傳入的參數
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public int HTProgRight = 0;
    
    protected string submitTask = "";
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//功能權限代碼
    protected string SQL = "";
    protected object objResult = null;
    protected Paging page = null;

    protected string seq = "", seq1 = "", qtype = "", type = "", branch = "";
        
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Init(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        
        submitTask = (Request["submittask"] ?? "").Trim().ToUpper();
        seq = (Request["aseq"] ?? Request["seq"]);
        seq1 = (Request["aseq1"] ?? Request["seq1"]);
        qtype = (Request["qtype"] ?? "A").ToUpper();
        type = (Request["type"] ?? "");
        branch = (Request["branch"] ?? "");
        
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        if (type == "brtran") {
            conn = new DBHelper(Conn.brp(branch)).Debug(Request["chkTest"] == "TEST");
        }

        PageLayout();
        QueryData();
        this.DataBind();
    }

    private void PageLayout() {
    }

    private void QueryData() {
        SQL = "select * ";
        SQL += ",''tclass,''cgrs,''lcg,''lrs,''case_stat_nm,''rs_class_nm,''lrs_detail,''string_ges,''case_asp,''Doc_flag ";
        SQL += " From vstep_dmt ";
        if (ReqVal.TryGet("type") == "brtran" && ReqVal.TryGet("branch") != "") {
            SQL += " where branch = '" + Request["branch"] + "'";
        } else {
            SQL += " where branch = '" + Session["seBranch"] + "'";
        }
        SQL += " and seq='" + seq + "' and seq1='" + seq1 + "'";
        if (qtype == "N") {
            SQL += "and rs_no in (select distinct rs_no from ctrl_dmt where seq=" + seq + " and seq1='" + seq1 + "')";
        }
        SQL += " order by step_grade desc";
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

            string cgrs = dr.SafeRead("cg", "") + dr.SafeRead("rs", "");

            //行樣式
            dr["tclass"] = (i + 1) % 2 == 1 ? "sfont9" : "lightbluetable3";

            //收發種類
            dr["cgrs"] = cgrs;
            if (dr.SafeRead("cg", "") == "C") {
                dr["lcg"] = "客";
            } else if (dr.SafeRead("cg", "") == "G") {
                dr["lcg"] = "官";
            } else {
                dr["lcg"] = "本";
            }

            if (dr.SafeRead("rs", "") == "R" || dr.SafeRead("rs", "") == "Z") {
                dr["lrs"] = "收";
            } else {
                dr["lrs"] = "發";
            }

            //案件狀態/結構分類/案性
            string rs_detail = "", case_stat_nm = "", rs_class_nm = "";
            GetRsDetail(dr, ref case_stat_nm, ref rs_class_nm, ref rs_detail);
            dr["case_stat_nm"] = case_stat_nm;
            dr["rs_class_nm"] = rs_class_nm;
            dr["lrs_detail"] = rs_detail;

            //20180430新增顯示 電子送件資訊查詢
            string string_ges = "";
            if (cgrs == "GS" && (dr.SafeRead("send_way", "") == "EA" || dr.SafeRead("send_way", "") == "E")) {
                string_ges = "<img src=\"" + Page.ResolveUrl("~/images/gs_img1.png") + "\" WIDTH=\"20\" HEIGHT=\"20\" title=\"電子送件資訊查詢\" style=\"cursor:pointer\" ";
                string_ges += " onclick=\"brta61form.GesViewClick('" + dr["seq"] + "','" + dr["seq1"] + "','" + dr["rs_no"] + "','" + dr["step_grade"] + "')\" >";
            }
            dr["string_ges"] = string_ges;

            string case_asp = "";
            if (dr.SafeRead("case_no", "") != "") {
                SQL = "select a.* from case_dmt as a where a.case_no = '" + dr["case_no"] + "' ";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        case_asp = "brta61form.CaseNoClick('" + Sys.getCaseDmt11Aspx(prgid, dr0.SafeRead("in_no", ""), dr0.SafeRead("in_scode", ""), "Show") + "')";
                    }
                }
            } else {
                case_asp = "brta61form.StepGradeClick(" + seq + ", '" + seq1 + "', '" + dr["rs_no"] + "','" + dr["cgrs"] + "')";
            }
            dr["case_asp"] = case_asp;

            //附件
            SQL = "select count(*) from dmt_attach";
            SQL += " where seq = " + seq;
            SQL += "   and seq1 = '" + seq1 + "'";
            SQL += "   and step_grade = '" + dr["step_grade"] + "'";
            SQL += "   and attach_flag <> 'D' ";
            objResult = conn.ExecuteScalar(SQL);
            int attachCount = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);

            if (attachCount > 0) {
                dr["Doc_flag"] = "<img title=\"顯示附件資料\" onclick=\"$('#detailDoc_" + (i + 1) + "').toggle()\" src=\"../images/2.gif\" border=\"0\" WIDTH=\"11\" HEIGHT=\"11\" style=\"cursor:pointer\">";
            }
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    //案性
    protected void GetRsDetail(DataRow dr, ref string case_stat_nm, ref string rs_class_nm, ref string rs_detail) {
        string cg = dr.SafeRead("cg", "");
        string rs = dr.SafeRead("rs", "");
        if (cg == "Z" && rs == "S") {
            cg = "C";//因本發代碼同客收
            rs = "R";
        }

        if (cg != "Z" && rs != "Z") {
            SQL = "select rs_detail from code_br ";
            SQL += " where " + cg + rs + "='Y'";
            SQL += "   and dept = '" + Session["dept"] + "'";
            SQL += "   and rs_type = '" + dr.SafeRead("rs_type", "") + "'";
            SQL += "   and rs_class = '" + dr.SafeRead("rs_class", "") + "'";
            SQL += "   and rs_code = '" + dr.SafeRead("rs_code", "") + "'";
            objResult = conn.ExecuteScalar(SQL);
            rs_detail = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
        }

        SQL = "select rs_class_name, rs_detail,case_stat_name";
        SQL += "  from vcode_act ";
        SQL += " where cg = '" + cg + "'";
        SQL += "   and rs = '" + rs + "'";
        SQL += "   and dept = '" + Session["dept"] + "'";
        SQL += "   and rs_type = '" + dr.SafeRead("rs_type", "") + "'";
        SQL += "   and rs_class = '" + dr.SafeRead("rs_class", "") + "'";
        SQL += "   and rs_code = '" + dr.SafeRead("rs_code", "") + "'";
        SQL += "   and act_code = '" + dr.SafeRead("act_code", "") + "'";
        using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
            if (dr0.Read()) {
                case_stat_nm = dr0.SafeRead("case_stat_name", "");
                rs_class_nm = dr0.SafeRead("rs_class_name", "");
            }
        }
    }

    //管制期限/附件資料
    protected void dataRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            string seq = DataBinder.Eval(e.Item.DataItem, "seq").ToString();
            string seq1 = DataBinder.Eval(e.Item.DataItem, "seq1").ToString();
            string step_grade = DataBinder.Eval(e.Item.DataItem, "step_grade").ToString();
            string opt_sqlno = DataBinder.Eval(e.Item.DataItem, "opt_sqlno").ToString();
            string opt_stat = DataBinder.Eval(e.Item.DataItem, "opt_stat").ToString();
            string rs_no = DataBinder.Eval(e.Item.DataItem, "rs_no").ToString();
            
            //管制期限
            Repeater ctrlRpt = (Repeater)e.Item.FindControl("ctrlRepeater");
            if ((ctrlRpt != null)) {
                DataTable dtDtl = new DataTable();
                SQL = "select a.sqlno,ctrl_type,ctrl_date,ctrl_remark,'' as resp_date,'' as resp_grade,code_name,'' as resp_type,'' as resp_remark ";
                SQL += ",convert(varchar(20),b.remark) ctrl_type_mark ";
                SQL += ",''tcolor,''resp_date_txt,''resp_grade_txt ";
                SQL += "  from ctrl_dmt a inner join cust_code b on a.ctrl_type = b.cust_code ";
                SQL += " where rs_no = '" + rs_no + "'";
                SQL += "   and b.code_type = 'CT'";
                SQL += " union ";
                SQL += "select a.sqlno,ctrl_type,ctrl_date,ctrl_remark,resp_date,resp_grade,code_name ";
                SQL += ",(select code_name from cust_code where code_type = 'RESP_TYPE' and cust_code = a.resp_type) as resp_type,resp_remark ";
                SQL += ",convert(varchar(20),b.remark) ctrl_type_mark ";
                SQL += ",''tcolor,''resp_date_txt,''resp_grade_txt ";
                SQL += "  from resp_dmt a inner join cust_code b on a.ctrl_type = b.cust_code  ";
                SQL += " where seq = " + seq;
                SQL += "   and seq1 = '" + seq1 + "'";
                SQL += "   and step_grade = '" + step_grade + "'";
                SQL += "   and b.code_type = 'CT'";
                SQL += " order by ctrl_date ";
                conn.DataTable(SQL, dtDtl);

                for (int i = 0; i < dtDtl.Rows.Count; i++) {
                    DataRow dr = dtDtl.Rows[i];

                    //管制顏色
                    string tcolor = Sys.getSetting(Sys.GetSession("dept"), "1", Util.parseDBDate(dr.SafeRead("ctrl_date", ""), "yyyy/M/d"));
                    if (tcolor == "red" && dr.GetDateTimeString("resp_date", "yyyy/M/d") == "1900/1/1") {
                        dr["tcolor"] = tcolor;
                    } else {
                        dr["tcolor"] = "black";
                    }

                    if (dr.GetDateTimeString("resp_date", "yyyy/M/d") != "1900/1/1") {
                        dr["resp_date_txt"] = dr.GetDateTimeString("resp_date", "yyyy/M/d") + "<br>" + dr["resp_type"] + (dr.SafeRead("resp_remark", "") != "" ? "<br>" : "") + dr["resp_remark"];
                        dr["resp_grade_txt"] = dr.SafeRead("resp_grade", "");
                    }
                }
                ctrlRpt.DataSource = dtDtl;
                ctrlRpt.DataBind();

                Panel emptyCtrlPanel = (Panel)e.Item.FindControl("emptyCtrl");
                if (dtDtl.Rows.Count == 0)
                    emptyCtrlPanel.Visible = true;//沒有管制資料的話要補空格
            }

            //附件
            Repeater attachRpt = (Repeater)e.Item.FindControl("attachRepeater");
            if ((attachRpt != null)) {
                string where ="";
                where+= " and seq = " + seq;
                where += " and seq1 = '" + seq1 + "'";
                where += " and step_grade = '" + step_grade + "'";
                where += " and attach_flag <> 'D' ";
                DataTable dtDtl = Sys.DmtAttach(conn, where);
                
                for (int i = 0; i < dtDtl.Rows.Count; i++) {
                    DataRow dr = dtDtl.Rows[i];
                }
                attachRpt.DataSource = dtDtl;
                attachRpt.DataBind();
            }
        }
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
    <div id="divPaging" style="display:<%#page.totRow==0?"none":""%>">
    <TABLE border=0 cellspacing=1 cellpadding=0 width="100%" align="center">
        <tr>
            <td colspan=2 align=center>
  		        <input type=hidden id=qtype name=qtype value="<%=qtype%>">
		        <input type=hidden id=aseq name=aseq value="<%=Request["aseq"]%>">
		        <input type=hidden id=aseq1 name=aseq1 value="<%=Request["aseq1"]%>">
                <label><input type=radio name=RQType value="A" onclick="brta61form.RQTypeClick()"><font size=2>所有進度</font></label>&nbsp;
		        <label><input type=radio name=RQType value="N" onclick="brta61form.RQTypeClick()"><font size=2>尚未銷管</font></label>
                &nbsp;&nbsp;&nbsp;
                <font size="2" color="#3f8eba"> 
                第<font color="red"><span id="NowPage"><%#page.nowPage%></span>/<span id="TotPage"><%#page.totPage%></span></font>頁
                | 資料共 <font color="red"><span id="TotRec"><%#page.totRow%></span></font> 筆
                | 跳至第<select id="GoPage" name="GoPage" style="color:#FF0000"><%#page.GetPageList()%></select>頁
                <span id="PageUp" style="display:<%#page.nowPage>1?"":"none"%>">| <a href="javascript:void(0)" class="pgU" v1="<%#page.nowPage-1%>">上一頁</a></span>
                <span id="PageDown" style="display:<%#page.nowPage<page.totPage?"":"none"%>">| <a href="javascript:void(0)" class="pgD" v1="<%#page.nowPage+1%>">下一頁</a></span>
                <input type="hidden" name="SetOrder" id="SetOrder" value="<%#ReqVal.TryGet("qryOrder")%>" />
                </font>
            </td>
        </tr>
    </TABLE>
    </div>

    <div align="center" id="noData" style="display:<%#page.totRow==0?"":"none"%>">
	    <font color="red">=== 資料不存在 ===</font>
    </div>

    <input type=hidden id=ctrlnum name=ctrlnum value=0><!--進度筆數-->
    <asp:Repeater id="dataRepeater" runat="server" OnItemDataBound="dataRepeater_ItemDataBound">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
	            <TR>
		            <TD align=center colspan=12	class=lightbluetable1><font color=white>進&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;度&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;料</font></TD>
	            </TR>
	            <TR align=center class=lightbluetable>
		            <TD>進度<br>序號</TD>
		            <TD>收發<br>種類</TD>
		            <TD>進度日期</TD>
		            <TD>案件狀態</TD>
		            <TD>結構分類</TD>
		            <TD>案性</TD>
		            <TD>進度內容<br>(交辦序號)</TD>
		            <TD>客戶<br>報導</TD>
		            <TD>附件</TD>
		            <TD>管制期限</TD>
		            <TD>銷管日期</TD>
		            <TD>銷管<br>進度</TD>
	            </TR>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			    <ItemTemplate>
		            <tr class="<%#Eval("tclass")%>">
		                <td align="center" nowrap style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="brta61form.StepGradeClick(<%=seq%>, '<%=seq1%>', '<%#Eval("rs_no")%>','<%#Eval("cgrs")%>')">
                            <%#Eval("step_grade")%>
		                </td>
		                <td align="center" nowrap>
                            <%#Eval("lcg")%><%#Eval("lrs")%><%#Eval("string_ges")%>
		                </td>
		                <td align="center" nowrap style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="brta61form.StepGradeClick(<%=seq%>, '<%=seq1%>', '<%#Eval("rs_no")%>','<%#Eval("cgrs")%>')">
                            <%#Eval("step_date","{0:d}")%>
		                </td>
			            <td align="center" style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'"  onclick="brta61form.StepGradeClick(<%=seq%>, '<%=seq1%>', '<%#Eval("rs_no")%>','<%#Eval("cgrs")%>')" align="left">
                            <%#Eval("case_stat_nm")%>
			            </td>
			            <td align="center" style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'"  onclick="brta61form.StepGradeClick(<%=seq%>, '<%=seq1%>', '<%#Eval("rs_no")%>','<%#Eval("cgrs")%>')" align="left">
                            <%#Eval("rs_class_nm")%>
			            </td>
			            <td align="center" style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'"  onclick="brta61form.StepGradeClick(<%=seq%>, '<%=seq1%>', '<%#Eval("rs_no")%>','<%#Eval("cgrs")%>')" align="left">
                            <%#Eval("lrs_detail")%>
			            </td>
			            <td align="center" style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'"  onclick="<%#Eval("case_asp")%>">
                            <%#Eval("rs_detail")%><%#(Eval("case_no").ToString()!=""?"<br>("+Eval("case_no")+")":"")%>
			            </td>
                        <td align="center">
                            <%#(Eval("cs_rs_no").ToString()!=""?"Y":"N")%>
                        </td>
                        <td align="center">
                            <%#Eval("Doc_flag")%>
                        </td>
                        <asp:Panel runat="server" ID="emptyCtrl" Visible="false"><!--沒有管制資料的話要補空格-->
				            <td></td><td></td><td></td>
                        </asp:Panel>
                        <!--有管制資料-->
	                    <asp:Repeater id="ctrlRepeater" runat="server">
                            <ItemTemplate>
                            <asp:Panel runat="server" Visible='<%#Container.ItemIndex != 0 %>'><!--第1筆期限顯示在上一層,其餘期限顯示在下層(要補前面的空格)-->
			                    <tr class="<%#DataBinder.Eval(((RepeaterItem)Container.Parent.Parent).DataItem, "tclass")%>"><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>
                            </asp:Panel>
                            <td nowrap>
                                <font color="<%#Eval("tcolor")%>"><%#Eval("code_name").ToString().Left(2)%>&nbsp;<%#Eval("ctrl_date","{0:d}")%>
                                <%#(Eval("ctrl_remark").ToString()!=""?"<br>":"")%><%#Eval("ctrl_remark")%></font>
                            </td>
                            <td nowrap><%#Eval("resp_date_txt")%></td><!--銷管日期-->
                            <td align="center"><%#Eval("resp_grade_txt")%></td><!--銷管進度-->
                            </ItemTemplate>
			            </asp:Repeater>
		            </tr>
                    <!--附件資料-->
			        <tr id="detailDoc_<%#(Container.ItemIndex+1)%>" style="display:none" class="sfont9">
                        <td colspan=12>
	                        <asp:Repeater id="attachRepeater" runat="server">
                                <HeaderTemplate>
				                    <table width="92%" align="right" border="0" cellspacing="1" cellpadding="0" style="FONT-SIZE:9pt;COLOR:navy;border-width:1px;background-color:gray">
				                    <tr align="center" style="BACKGROUND-COLOR:Cornsilk">
					                    <td nowrap width="50%">附件名稱</td>
					                    <td nowrap width="50%">附件說明</td>
				                    </tr>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
					                    <td title="<%#Eval("source")%>" align="left" style="cursor:pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="brta61form.doc_click('<%#Eval("view_path")%>')">
                                            <%#Eval("attach_name")%>
                                            <%#(Eval("file_flag").ToString()=="Y"?"<img src=\""+Page.ResolveUrl("~/images/annex.gif")+"\">":"") %>
                                            <%#Eval("file_flagnm")%>
                                        </td>
                                        <td>&nbsp;<%#Eval("attach_desc")%></td>
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
    <br>
    <br>
</FooterTemplate>
</asp:Repeater>

<script language="javascript" type="text/javascript">
    var brta61form = {};

    brta61form.init = function () {
        //顯示查詢銷管的條件
        $("input[name='RQType'][value='<%=qtype%>']").prop("checked", true);
    }

    brta61form.bind = function (jData) {
    }

    //銷管條件(所有進度/尚未銷管)
    brta61form.RQTypeClick = function () {
        $("#qtype").val($("input[name='RQType']:checked").val());
        goSearch();
    }

    //檢視附件
    brta61form.doc_click = function (url) {
        window.open(url, "", "width=1000 height=700 top=20 left=20 toolbar=yes, menubar=no, location=no, directories=no resizeable=no status=yes scrollbars=yes");
    }

    //電子送件資訊查詢
    brta61form.GesViewClick = function (seq, seq1, step_sqlno, step_grade) {
        var url = "brta61_GS_view.aspx?prgid=<%=prgid%>&submitTask=Q&seq=" + seq + "&seq1=" + seq1 + "&step_sqlno=" + step_sqlno + "&step_grade=" + step_grade;
        //window.open(url, "", "width=1000px height=720px top=10 left=10 toolbar=no, menubar=no, location=no, directories=no resizable=YES status=no scrollbars=no");
        $('#dialog').html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
        .dialog({ autoOpen: true, modal: true, height: 540, width: 800, title: "電子送件資訊" });
    }

    //交辦內容
    brta61form.CaseNoClick = function (url) {
        window.showModalDialog(url, "", "dialogHeight: 520px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars=yes");
        //$('#dialog').html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
        //.dialog({ autoOpen: true, modal: true, height: 540, width: 800, title: "電子送件資訊" });
    }

    //進度內容
    brta61form.StepGradeClick = function (seq, seq1, rs_no, cgrs) {
        var url = getRootPath() + "/brtam/brta61_QStep.aspx?prgid=<%=prgid%>&submitTask=Q&seq=" + seq + "&seq1=" + seq1 + "&rs_no=" + rs_no + "&cgrs=" + cgrs;
        //window.showModalDialog(url, "", "dialogHeight: 520px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars=yes");
        $('#dialog').html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
        .dialog({ autoOpen: true, modal: true, height: 540, width: "80%", title: "進度內容" });
    }
</script>
