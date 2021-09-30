<%@ Control Language="C#" ClassName="brta23form" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>

<script runat="server">
    //期限管制明細欄位畫面
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

    protected string seq = "", seq1 = "", qtype = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Init(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        
        submitTask = (Request["submittask"] ?? "").Trim().ToUpper();
        seq = (Request["aseq"] ?? "");
        seq1 = (Request["aseq1"] ?? "");
        qtype = (Request["qtype"] ?? "").ToUpper();

        PageLayout();
        QueryData();
        this.DataBind();
    }

    private void PageLayout() {
        if ((prgid == "brta23" || prgid == "brta24") && submitTask != "D") {//官收維護/官收確認
            Lock["QLock"] = "";
        } else {
            if (prgid != "brta23"&& prgid != "brta24") {
                Lock["QLock"] = "Lock";
            } else {
                Lock["QLock"] = Lock.TryGet("Qdisabled");
            }
        }
    }

    private void QueryData() {
        SQL = "select * ";
        SQL += ",''tclass,''cgrs,''lcg,''lrs,''lrs_detail ";
        SQL += " From vstep_dmt ";
        SQL += " where branch='" + Session["seBranch"] + "'";
        SQL += " and seq='" + seq + "' and seq1='" + seq1 + "'";
        if (qtype == "N") {
            SQL += "and rs_no in (select distinct rs_no from ctrl_dmt where seq=" + seq + " and seq1='" + seq1 + "')";
        }
        SQL += " order by step_grade";
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

            //行樣式
            dr["tclass"] = (i + 1) % 2 == 1 ? "sfont9" : "lightbluetable3";

            //收發種類
            dr["cgrs"] = dr.SafeRead("cg", "") + dr.SafeRead("rs", "");
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
            
            //案性
            dr["lrs_detail"] = GetRsDetail(dr);
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    //案性
    protected string GetRsDetail(DataRow dr) {
        string cg = dr.SafeRead("cg", "");
        string rs = dr.SafeRead("rs", "");
        string rs_detail = "";
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
        return rs_detail;
    }

    //管制期限資料
    protected void dataRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            Repeater dtlRpt = (Repeater)e.Item.FindControl("dtlRepeater");

            if ((dtlRpt != null)) {
                string seq = DataBinder.Eval(e.Item.DataItem, "seq").ToString();
                string seq1 = DataBinder.Eval(e.Item.DataItem, "seq1").ToString();
                string step_grade = DataBinder.Eval(e.Item.DataItem, "step_grade").ToString();
                string opt_sqlno = DataBinder.Eval(e.Item.DataItem, "opt_sqlno").ToString();
                string opt_stat = DataBinder.Eval(e.Item.DataItem, "opt_stat").ToString();
                string rs_no = DataBinder.Eval(e.Item.DataItem, "rs_no").ToString();
                
                DataTable dtDtl = new DataTable();
                SQL = "select a.sqlno,ctrl_type,ctrl_date,ctrl_remark,'' as resp_date,'' as resp_grade,code_name,'' as resp_type,'' as resp_remark ";
                SQL += ",convert(varchar(20),b.remark) ctrl_type_mark,''ctrl_type_mname ";
                SQL += ",''tcolor,''resp_date_txt,''resp_grade_txt,''resp_txt,''edit_txt,''add_txt ";
                SQL += "  from ctrl_dmt a inner join cust_code b on a.ctrl_type = b.cust_code ";
                SQL += " where rs_no = '" + rs_no + "'";
                SQL += "   and b.code_type = 'CT'";
                SQL += " union ";
                SQL += "select a.sqlno,ctrl_type,ctrl_date,ctrl_remark,resp_date,resp_grade,code_name ";
                SQL += ",(select code_name from cust_code where code_type = 'RESP_TYPE' and cust_code = a.resp_type) as resp_type,resp_remark ";
                SQL += ",convert(varchar(20),b.remark) ctrl_type_mark,''ctrl_type_mname ";
                SQL += ",''tcolor,''resp_date_txt,''resp_grade_txt,''resp_txt,''edit_txt,''add_txt ";
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
                    
                    string ctrl_type_mark = dr.SafeRead("ctrl_type_mark", "");
                    if (ctrl_type_mark == "")
                        ctrl_type_mark = "N";
                    //若管制種類的mark=C(記錄於cust_code.code_type=CT and cust_code=code_type and mark=C)，則不能由此作業銷管，權限C除外
                    if (ctrl_type_mark == "C" || ctrl_type_mark == "B") {
                        if ((HTProgRight & 256) > 0) {
                            dr["ctrl_type_mname"] = "<font color=red>(" + ctrl_type_mark + ")</font>";
                            ctrl_type_mark = "N";
                        }
                    }

                    if (dr.GetDateTimeString("resp_date", "yyyy/M/d") != "1900/1/1") {
                        //有銷管就不能修改
                        dr["resp_date_txt"] = dr.GetDateTimeString("resp_date", "yyyy/M/d") + "<br>" + dr["resp_type"] + (dr.SafeRead("resp_remark", "") != "" ? "<br>" : "") + dr["resp_remark"];
                        dr["resp_grade_txt"] = dr.SafeRead("resp_grade", "");
                    } else {
                        //[銷管]
                        if (ctrl_type_mark != "C" && ctrl_type_mark != "B") {
                            dr["resp_txt"] = "<span style=\"cursor: pointer;\" onmouseover=\"this.style.color='red'\" onmouseout=\"this.style.color='black'\" onclick=\"brta23form.RespClick('" + dr["sqlno"] + "'," + seq + ", '" + seq1 + "','" + step_grade + "','" + dr["ctrl_type"] + "','" + dr.GetDateTimeString("ctrl_date", "yyyy/M/d") + "')\">[銷管]" + dr["ctrl_type_mname"] + "</span>";
                        }
                        //[修改]
                        if (ctrl_type_mark != "C") {
                            dr["edit_txt"] = "<span style=\"cursor: pointer;\" onmouseover=\"this.style.color='red'\" onmouseout=\"this.style.color='black'\" onclick=\"brta23form.UpdateClick('" + dr["sqlno"] + "'," + seq + ", '" + seq1 + "','" + step_grade + "','" + dr["ctrl_type"] + "','" + dr.GetDateTimeString("ctrl_date", "yyyy/M/d") + "','" + opt_sqlno + "','" + opt_stat + "')\">[修改]" + dr["ctrl_type_mname"] + "</span>";
                        }
                    }
                    //[新增]
                    if (i == 0) {//第一筆才顯示
                        dr["add_txt"] = "<span style=\"cursor: pointer;\" onmouseover=\"this.style.color='red'\" onmouseout=\"this.style.color='black'\" onclick=\"brta23form.AddClick(" + seq + ", '" + seq1 + "','" + step_grade + "')\">[新增]</span>";
                    }
                }
                dtlRpt.DataSource = dtDtl;
                dtlRpt.DataBind();

                Panel emptyCtrlPanel = (Panel)e.Item.FindControl("emptyCtrl");
                if (dtDtl.Rows.Count == 0)
                    emptyCtrlPanel.Visible = true;//沒有管制資料的話要補空格
            }
        }
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
    <div id="divPaging" style="display:<%#page.totRow==0?"none":""%>">
    <TABLE border=0 cellspacing=1 cellpadding=0 width="98%" align="center">
        <tr>
            <td colspan=2 align=center>
  		        <input type=hidden id=qtype name=qtype value="<%=qtype%>">
		        <input type=hidden id=aseq name=aseq value="<%=Request["aseq"]%>">
		        <input type=hidden id=aseq1 name=aseq1 value="<%=Request["aseq1"]%>">
                <label><input type=radio name=RQType value="A" onclick="brta23form.RQTypeClick()"><font size=2>所有進度</font></label>&nbsp;
		        <label><input type=radio name=RQType value="N" onclick="brta23form.RQTypeClick()"><font size=2>尚未銷管</font></label>
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
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	        <thead>
	            <TR>
		            <TD align=center colspan=11	class=lightbluetable1><font color=white>進&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;度&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;料</font></TD>
	            </TR>
	            <TR align=center class=lightbluetable>
		            <TD>進度<br>序號</TD>
		            <TD>收發<br>種類</TD>
		            <TD>進度日期</TD>
		            <TD>案性</TD>
		            <TD>進度內容</TD>
		            <TD>管制期限</TD>
		            <TD>銷管日期</TD>
		            <TD>銷管<br>進度</TD>
		            <TD>銷管</TD>
		            <TD>修改<br>管制</TD>
		            <TD>新增<br>管制</TD>
	            </TR>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			    <ItemTemplate>
		            <tr class="<%#Eval("tclass")%>">
		                <td align="center" nowrap style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="brta23form.StepGradeClick(<%=seq%>, '<%=seq1%>', '<%#Eval("rs_no")%>','<%#Eval("cgrs")%>')">
                            <%#Eval("step_grade")%>
		                </td>
		                <td align="center" nowrap style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="brta23form.StepGradeClick(<%=seq%>, '<%=seq1%>', '<%#Eval("rs_no")%>','<%#Eval("cgrs")%>')">
                            <%#Eval("lcg")%><%#Eval("lrs")%>
		                </td>
		                <td align="center" nowrap style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="brta23form.StepGradeClick(<%=seq%>, '<%=seq1%>', '<%#Eval("rs_no")%>','<%#Eval("cgrs")%>')">
                            <%#Eval("step_date","{0:yyyy/M/d}")%>
		                </td>
			            <td style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'"  onclick="brta23form.StepGradeClick(<%=seq%>, '<%=seq1%>', '<%#Eval("rs_no")%>','<%#Eval("cgrs")%>')" align="left">
                            <%#Eval("lrs_detail")%>
			            </td>
			            <td style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'"  onclick="brta23form.StepGradeClick(<%=seq%>, '<%=seq1%>', '<%#Eval("rs_no")%>','<%#Eval("cgrs")%>')" align="left">
                            <%#Eval("rs_detail")%>
			            </td>
                        <asp:Panel runat="server" ID="emptyCtrl" Visible="false"><!--沒有管制資料的話要補空格-->
				            <td></td><td></td><td></td><td></td><td></td>
                            <td align="center" style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="brta23form.AddClick(<%=seq%>, '<%=seq1%>','<%#Eval("step_grade")%>')">[新增]</td>
                        </asp:Panel>
                        <!--有管制資料-->
	                    <asp:Repeater id="dtlRepeater" runat="server">
                            <ItemTemplate>
                            <asp:Panel runat="server" Visible='<%#Container.ItemIndex != 0 %>'><!--第1筆期限顯示在上一層,其餘期限顯示在下層(要補前面的空格)-->
			                    <tr class="<%#DataBinder.Eval(((RepeaterItem)Container.Parent.Parent).DataItem, "tclass")%>"><td></td><td></td><td></td><td></td><td></td>
                            </asp:Panel>
                            <td nowrap>
                                <font color="<%#Eval("tcolor")%>"><%#Eval("code_name").ToString().Left(2)%>&nbsp;<%#Eval("ctrl_date","{0:yyyy/M/d}")%>
                                <%#(Eval("ctrl_remark").ToString()!=""?"<br>":"")%><%#Eval("ctrl_remark")%></font>
                            </td>
                            <td nowrap><%#Eval("resp_date_txt")%></td><!--銷管日期-->
                            <td align="center"><%#Eval("resp_grade_txt")%></td><!--銷管進度-->
                            <td align="center" nowrap><%#Eval("resp_txt")%></td><!--[銷管]-->
                            <td align="center" nowrap><%#Eval("edit_txt")%></td><!--[修改]-->
                            <td align="center" nowrap><%#Eval("add_txt")%></td><!--[新增]-->
                            </ItemTemplate>
			            </asp:Repeater>
		            </tr>
                </ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
    <br>
    <br>
</FooterTemplate>
</asp:Repeater>

<%if ((HTProgRight & 256) > 0) {%>
	<div align="left">
        <font size=2 color=blue>權限C備註：[銷管]<font color=red>(C)</font>表權限C才能在期限管制作業維護或銷管，否則應由正常作業銷管，如契約書後補期限要在契約書後補作業完成後銷管。</font>
    </div>
<%} %>

<script language="javascript" type="text/javascript">
    var brta23form = {};

    brta23form.init = function () {
        //顯示查詢銷管的條件
        $("input[name='RQType'][value='<%=qtype%>']").prop("checked", true);
    }

    brta23form.bind = function (jData) {
    }

    //銷管條件(所有進度/尚未銷管)
    brta23form.RQTypeClick = function () {
        $("#qtype").val($("input[name='RQType']:checked").val());
        goSearch();
    }

    //進度內容
    brta23form.StepGradeClick = function (seq, seq1, rs_no, cgrs) {
        var url = getRootPath() + "/brtam/brta61_QStep.aspx?prgid=<%=prgid%>&submitTask=Q&seq=" + seq + "&seq1=" + seq1 + "&rs_no=" + rs_no + "&cgrs=" + cgrs;
        window.showModalDialog(url, "", "dialogHeight: 520px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars=yes");
    }

    //[銷管]
    brta23form.RespClick = function (sqlno, seq, seq1, step_grade, ctrl_type, ctrl_date) {
        var url = getRootPath() + "/brtam/brta23_Ctrl.aspx?prgid=<%=prgid%>&submitTask=R&sqlno=" + sqlno + "&seq=" + seq + "&seq1=" + seq1 + "&step_grade=" + step_grade + "&ctrl_type=" + ctrl_type + "&ctrl_date=" + ctrl_date;
        //window.showModalDialog(url,"CtrlWinN","dialogHeight: 350px; dialogWidth: 720px; center: Yes;resizable: No; status: No;scrollbars=yes");
        $('#dialog')
        .html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
        .dialog({ autoOpen: true, modal: true, height: 420, width: 650, title: "銷管" });
        //reg.submit;
    }

    //[修改]
    brta23form.UpdateClick = function (sqlno, seq, seq1, step_grade, ctrl_type, ctrl_date, opt_sqlno, opt_stat) {
        if (opt_sqlno != "" && opt_stat == "Y") {//已交辦專案室
            if (ctrl_type == "A1") {
                alert("本進度已交辦專案室，如需修改法定期限，請至「國內爭救案交辦查詢作業」修改期限！");
                return false;
            }
        }
        var url = getRootPath() + "/brtam/brta23_Ctrl.aspx?prgid=<%=prgid%>&submitTask=U&sqlno=" + sqlno + "&seq=" + seq + "&seq1=" + seq1 + "&step_grade=" + step_grade + "&ctrl_type=" + ctrl_type + "&ctrl_date=" + ctrl_date;
        //window.showModalDialog(url,"CtrlWinN","dialogHeight: 350px; dialogWidth: 720px; center: Yes;resizable: No; status: No;scrollbars=yes");
        $('#dialog')
       .html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
       .dialog({ autoOpen: true, modal: true, height: 420, width: 650, title: "修改管制" });
        //reg.submit
    }

    //[新增]
    brta23form.AddClick = function (seq, seq1, step_grade) {
        var url = getRootPath() + "/brtam/brta23_Ctrl.aspx?prgid=<%=prgid%>&submitTask=A&seq=" + seq + "&seq1=" + seq1 + "&step_grade=" + step_grade;
        //window.showModalDialog(url,"CtrlWinN","dialogHeight: 350px; dialogWidth: 720px; center: Yes;resizable: No; status: No;scrollbars=yes");
        $('#dialog')
        .html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
        .dialog({ autoOpen: true, modal: true, height: 420, width: 650, title: "新增管制" });
        //reg.submit
    }
</script>
