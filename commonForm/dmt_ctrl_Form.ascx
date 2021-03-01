﻿<%@ Control Language="C#" ClassName="dmt_ctrl_form" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    //父控制項傳入的參數
    public Dictionary<string, string> SrvrVal = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public int HTProgRight = 0;


    protected string submitTask = "";
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//功能權限代碼
    protected string SQL = "";

    protected string html_ctrl = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        submitTask = (Request["submittask"] ?? "").Trim().ToUpper();

        html_ctrl = Sys.getCustCode("CT", "", "").Option("{cust_code}", "{code_name}");//管制種類

        PageLayout();
        this.DataBind();
    }

    private void PageLayout() {
        if (submitTask == "Q" || submitTask== "D") {
            Lock["Qdisabled"] ="Lock";
        }
    }

    private string QueryData() {
        if (prgid == "brta34") {//本發作業
            SQL = " select sqlno,ctrl_type,ctrl_remark,ctrl_date,null as resp_date,null as resp_grade from ctrl_dmt ";
            SQL += " where rs_no='" + Request["cr_rs_no"] + "' and ctrl_type='A1' ";
            SQL += " union select sqlno,ctrl_type,ctrl_remark,ctrl_date,resp_date,resp_grade from resp_dmt ";
            SQL += " where rs_no='" + Request["cr_rs_no"] + "' and ctrl_type='A1' ";
            SQL += " order by ctrl_date";
        } else if (prgid == "brta24" && SrvrVal.TryGet("from_flag") == "C") {//官收電子收文
            SQL = " select tctrl_sqlno as sqlno,ctrl_type,ctrl_remark,ctrl_date,null as resp_date,null as resp_grade ";
            SQL += " from ctrl_mgt_temp where temp_rs_sqlno=" + SrvrVal.TryGet("temp_rs_sqlno") + " and ctrl_type like 'A%' ";
            SQL += " union select null as sqlno,ctrl_type,ctrl_remark,ctrl_date,resp_date,mg_resp_step_grade as resp_grade ";
            SQL += " from resp_mgt_temp where temp_rs_sqlno=" + SrvrVal.TryGet("temp_rs_sqlno") + " and ctrl_type like 'A%' ";
        } else {
            SQL = " select sqlno,ctrl_type,ctrl_remark,ctrl_date,null as resp_date,null as resp_grade from ctrl_dmt ";
            SQL += " where rs_no='" + SrvrVal.TryGet("rs_no") + "'";
            SQL += " union select sqlno,ctrl_type,ctrl_remark,ctrl_date,resp_date,resp_grade from resp_dmt ";
            SQL += " where rs_no='" + SrvrVal.TryGet("rs_no") + "'";
            SQL += " order by ctrl_date";
        }

        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.None,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };

        return JsonConvert.SerializeObject(dt, settings).ToUnicode().Replace("\\", "\\\\").Replace("\"", "\\\"");
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<input type=hidden id=ctrlnum name=ctrlnum value=0><!--進度筆數-->
<TABLE id=tabctrl style="display:" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
    <thead>
	    <%if (submitTask != "Q" && submitTask != "D") { %>
	        <TR class=whitetablebg align=center id="ctrl_line1">
		        <TD colspan=7>
			        <input type=button value ="增加一筆管制" class="cbutton" id=Add_button name=Add_button onclick="ctrl_form.add_ctrl()">
			        <%if (submitTask == "A" || prgid == "brta24" || prgid == "brta38") {%><!--國內案官收確認作業//國內案官發確認作業-->
				        <input type=button value ="減少一筆管制" class="cbutton" id=res_button name=res_button onclick="ctrl_form.del_ctrl()">
			        <%}%>
			        <input type="hidden" name="rsqlno" id="rsqlno">
			        <%if (prgid != "brt51" && prgid != "brta22" && prgid != "brta78") {%><!--國內案客戶收文確認//國內案客戶收文作業//國內案確認轉案作業-->
			            <input type=button class="c1button" id="btndis" name="btndis" value ="進度查詢及銷管制">
			        <%}%>
			        <input type="button" class="c1button" value="查官收未銷法定期限" onclick="queryjob()" style="display:none" id="btnqrygrlastdate">
		        </TD>
	        </TR>
	    <%} else {%>
	        <TR class=whitetablebg align=center id="ctrl_line2">
		        <TD align=center colspan=7 class=lightbluetable1><font color=white>管&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;制&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;料</font></TD>
	        </TR>
	    <%}%>
	    <TR align=center class=lightbluetable>
		    <TD></TD><TD>管制種類</TD><TD>管制日期</TD><TD>說明</TD>
            <%if (submitTask == "U" || submitTask == "D" || submitTask == "Q") {%><TD>銷管日期</TD><TD>銷管進度</TD><%}%>
            <%if ((submitTask == "U" || submitTask == "D") && prgid != "brta34" && prgid != "brta38") {%><TD>刪除</TD><%}%><!--國內案本所發文作業//國內案官發確認作業-->
	    </TR>
    </thead>
    <tbody></tbody>
    <script type="text/html" id="ctrl_template"><!--管制期限樣板-->
	<tr id=tr_ctrl_##>
		<td class=whitetablebg align=center>
	        <input type=hidden id='io_flg_##' name='io_flg_##' value=Y>
	        <input type=hidden id='ctrl_step_grade_##' name='ctrl_step_grade_##'><!--客收之對應官收法定期限進度序號-->
	        <input type=hidden id='ctrl_rs_no_##' name='ctrl_rs_no_##'><!--客收之對應官收法定期限收文字號-->
	        <input type=hidden id='sqlno_##' name='sqlno_##'>
	        <input type=text id='ctrlnum_##' name='ctrlnum_##' class=SEdit readonly size=2 value='##'>.
		</td>
		<td class=whitetablebg align=center>
	        <input type=hidden id='octrl_type_##' name='octrl_type_##'>
	        <select id=ctrl_type_## name=ctrl_type_## class="<%=Lock.TryGet("Qdisabled")%>"><%=html_ctrl%></select>
		</td>
		<td class=whitetablebg align=center>
	        <input type=hidden id='octrl_date_##' name='octrl_date_##'>
	        <input type=text size=10 maxlength=10 id=ctrl_date_## name=ctrl_date_## onblur="ctrl_date_blur('##')" class="dateField <%=Lock.TryGet("Qdisabled")%>">
		</td>
		<td class=whitetablebg align=center>
	        <input type=hidden id='octrl_remark_##' name='octrl_remark_##'>
	        <input type=text id='ctrl_remark_##' name='ctrl_remark_##' class="dateField" size=30 maxlength=60>
            <label class="brta78"><input type=checkbox id='brctrl_mgt_##' name='brctrl_mgt_##' value='Y'>需總管處代管期限</label>
		</td>
        <%if (submitTask == "U" || submitTask == "D" || submitTask == "Q") {%>
		<td class=whitetablebg align=center>
		    <input type=hidden id='oresp_date_##' name='oresp_date_##'>
		    <input type=text id='resp_date_##' name='resp_date_##' style='text-align:center;' class=SEdit readonly size=10>
		</td>
		<td class=whitetablebg align=center>
		    <input type=hidden id='oresp_grade_##' name='oresp_grade_##'>
		    <input type=text id='resp_grade_##' name='resp_grade_##' style='text-align:center;' class=SEdit readonly size=4>
		</td>
        <%}%>
        <%if ((submitTask=="U" || submitTask=="D") && prgid!="brta34" && prgid!="brta38"){%>
		<td class=whitetablebg align=center>
            <input type=checkbox id='delchk_##' name='delchk_##' value="true">
		</td>
        <%}%>
	</tr>
</script>
</TABLE>

<script language="javascript" type="text/javascript">
    var ctrl_form = {};

    ctrl_form.init = function () {
        if(main.submittask!="Q"&&main.submmittask!="D"){
            $("#ctrl_line1").show();
            $("#ctrl_line2").hide();
        }else{
            $("#ctrl_line1").hide();
            $("#ctrl_line2").show();
        }


        if (main.prgid == "brta24") {//國內案官收確認作業
            $(".brta24").lock();
        }
    }

    //管制期限增加一筆
    ctrl_form.add_ctrl = function () {
        var nRow = CInt($("#ctrlnum").val()) + 1;
        //複製樣板
        var copyStr = $("#ctrl_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);
        $("#tabctrl tbody").append(copyStr);
        $("#ctrlnum").val(nRow);
        $(".dateField", $('#tr_ctrl_' + nRow)).datepick();

        if (main.prgid == "brta78") {//轉案
            $(".brta78").show();
        } else {
            $(".brta78").hide();
        }
    }

    //管制期限減少一筆
    ctrl_form.del_ctrl = function () {
        var nRow = CInt($("#ctrlnum").val());
        if(main.prgid=="brta34"){
            if($("#io_flg_"+nRow).val()=="N"){
                alert("本筆期限為客收管制期限，不能減少管制！");
                return false;
            }
        }

        $('#tr_ctrl_' + nRow).remove();
        $("#ctrlnum").val(Math.max(0, nRow - 1));
    }

    //設定欄位開關
    function ctrl_line_lock(nRow) {
        if ($("#resp_date_" + nRow).val() != "") {
            $("#io_flg_" + nRow).val("N");//該筆資料不可修改 & 不用入檔
            $("#ctrl_type_" + nRow).lock();
            $("#ctrl_date_" + nRow).lock();
            $("#ctrl_remark_" + nRow).lock();
            if ("<%=submitTask%>" == "U" || "<%=submitTask%>" == "D") {
                $("#delchk_").lock();
            }
        } else {
            $("#io_flg_" + nRow).val("Y");
            if ("<%=prgid%>" == "brta24") {
                $("#delchk_").lock();
            }
        }
        if ("<%=submitTask%>" == "U" || "<%=submitTask%>" == "D") {
            $("#delchk_").lock();
        }
        if ("<%=submitTask%>" == "U" || "<%=prgid%>" == "brta34") {//本發作業
            $("#delchk_").lock();
            $("#ctrl_type_" + nRow).lock();
            $("#ctrl_date_" + nRow).lock();
            $("#ctrl_remark_" + nRow).lock();
        }
    }

    function ctrl_date_blur(nRow) {
        var tctrl_date=$("#ctrl_date_"+nRow).val();
        if (tctrl_date=="") return false;
        if (CDate(tctrl_date).getTime() < Today().getTime()) {
            alert("管制日期不可小於今天!!!");
            $("#ctrl_date_"+nRow).focus();
        }
    }

    //[進度查詢及銷管制]
    $("#btndis").click(function (e) {
        //***todo
        var tlink = getRootPath() + "/brtam/brta21disEdit.aspx?branch=<%=Session["seBranch"]%>&seq=" + $("#seq").val() + "&seq1=" + $("#seq1").val() + "&rsqlno=" + $("#rsqlno").val() + "&step_grade=" + $("#nstep_grade").val();
        //本發只能進度查詢
        if ("<%=prgid%>" == "brta34") {
            tlink += "&qtype=R&submitTask=Q";
        } else {
            if ("<%=submitTask%>" == "A") {
                tlink += "&qtype=N&submitTask=A";
            } else if ("<%=submitTask%>" == "U") {
                if ("<%=prgid%>" == "brta24" || "<%=prgid%>" == "brta38") {
                    //官收確認或官發確認之進度銷管同新增
                    tlink += "&qtype=N&submitTask=A";
                } else {
                    tlink += "&qtype=R&submitTask=U";
                }
            } else if ("<%=submitTask%>" == "D") {
                tlink += "&qtype=R&submitTask=D";
            } else if ("<%=submitTask%>" == "Q") {
                tlink += "&qtype=R&submitTask=Q";
            } else if ("<%=submitTask%>" == "R") {//20160901 增加[退回]功能(R)
                tlink += "&qtype=R&submitTask=Q";
            }
        }

        window.open(tlink, "", "width=780 height=490 top=10 left=10 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    });

    //[查官收未銷法定期限]
    function queryjob() {
        if (($("#seq").val() || "") == "") {
            alert("無案件編號，無法查詢!!");
            return false;
        }

        var pseqnum = 0;
        for (var n = 1; n <= CInt($("#ctrlnum").val()) ; n++) {
            if ($("#ctrl_type_" + n).val() == "A1") {
                pseqnum = n;
                break;
            }
        }

        //***todo
        var tlink = getRootPath() + "/brt6m/brt62_steplist.aspx?seq=" + $("#seq").val() + "&seq1=" + $("#seq1").val() + "&step_grade=" + $("#nstep_grade").val() + "&ctrl_type=A1&prgid=<%=prgid%>&seqnum=" + pseqnum;
        window.open(tlink, "mywindowN", "width=700,height=480,toolbar=yes,menubar=yes,resizable=yes,scrollbars=yes,status=0,top=50,left=80");
    }
</script>
