<%@ Control Language="C#" ClassName="brta32form" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    //客發作業案件清單欄位畫面
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    protected string submitTask = "";
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//功能權限代碼
    protected string SQL = "";

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

        PageLayout();
        this.DataBind();
    }

    private void PageLayout() {
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<input type=hidden id=seqnum name=seqnum value=0><!--本所編號筆數-->
<TABLE id=tabbr1 border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
    <thead>
	    <TR id="tr_btn1">
		    <TD class=whitetablebg colspan=5>
			    <input type=button class="cbutton" name="btnadd" id="btnadd" value="新增一筆" onclick="brta32form.add_seq()">
			    <input type=button class="cbutton" name="btndel" id="btndel" value="減少一筆" onclick="brta32form.del_seq()">
		    </TD>
	    </TR>
		<TR>
            <td align="center" class="lightbluetable"></td>
		    <td align="center" class="lightbluetable">本所編號</td>
		    <td align="center" class="lightbluetable">案件名稱</td>	
		    <td align="center" class="lightbluetable">客戶名稱</td>
		    <td align="center" class="lightbluetable">類別</td>
	    </tr>
    </thead>
    <tbody></tbody>
    <script type="text/html" id="seq_template"><!--本所編號樣板-->
	<tr id=tr_seq_##>
		<td class=whitetablebg align=center>
	        ##.
		</td>
		<td class=whitetablebg align=center>
	        <input type='hidden' name='keyseq_##' id='keyseq_##' value='N'>
	        <input type='hidden' name='branch_##' id='branch_##'>
	        <input type='hidden' name='oldseq_##' id='oldseq_##'>
	        <input type='hidden' name='oldaseq1_##' id='oldaseq1_##'>
	        <input type=text size=6 id=seq_## name=seq_## onblur="brta32form.seqblur('##')" class="<%=Lock.TryGet("QLock")%>">
	        <input type=text size=1 maxlength=1 id=aseq1_## name=aseq1_## onblur="brta32form.seqblur('##')" value='_'class="<%=Lock.TryGet("QLock")%>">
			<input type=button class='cbutton' id='btnQuery_##' name='btnQuery_##' title='查詢本所編號' value='查' onclick="brta32form.btnQuery('##')">
			<input type=button class='cbutton' id=btncase_## name=btncase_##  title='案件主檔查詢' value='主' onclick="brta32form.btncase('##')">
		</td>
		<td class=whitetablebg align=center>
	        <span id=span_appl_name_##></span>
		</td>
		<td class=whitetablebg>
	        <input type='hidden' name='cust_seq_##' id='cust_seq_##'>
	        <input type='hidden' name='att_sql_##' id='att_sql_##'>
	        <span id=span_ap_name_##></span>
		</td>
		<td class=whitetablebg align=center>
		    <span id=span_class_##></span>
		</td>
	</tr>
    </script>
</table>

<script language="javascript" type="text/javascript">
    var brta32form = {};

    brta32form.init = function () {
    }

    brta32form.bind = function (jData) {
        $("#tabbr1 tbody").empty();
        if (main.submittask == "A") {
            brta32form.add_seq();//增加一筆
        }

        $.each(jData, function (i, item) {
            var fld = $("#uploadfield").val();
            brta32form.add_seq();//增加一筆
            var nRow = $("#seqnum").val();
            $("#seq_" + nRow).val(item.seq);
            $("#aseq1_" + nRow).val(item.seq1);
            brta32form.seqblur(nRow);
            if (main.submittask == "Q" || main.submittask == "D") {
                $("#seq_" + nRow).lock();
                $("#aseq1_" + nRow).lock();
                $("#btnQuery_" + nRow).lock();
                $("#tr_btn1").hide();
            }
        });
    }

    //案號增加一筆
    brta32form.add_seq = function () {
        var nRow = CInt($("#seqnum").val()) + 1;
        //複製樣板
        var copyStr = $("#seq_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);
        $("#tabbr1 tbody").append(copyStr);
        $("#seqnum").val(nRow);
        $(".dateField", $('#tr_seq_' + nRow)).datepick();
    }

    //案號減少一筆
    brta32form.del_seq = function () {
        var nRow = CInt($("#seqnum").val());

        $('#tr_seq_' + nRow).remove();
        $("#seqnum").val(Math.max(0, nRow - 1));
    }

    //本所編號抓取資料
    brta32form.seqblur = function (nRow) {
        var seq = $("#seq_" + nRow).val();
        var seq1 = $("#aseq1_" + nRow).val();

        if (chkNum(seq, "本所編號")) return false;

        if (seq != "" && seq1 != "") {
            var dmt_data = {};
            $.ajax({
                type: "get",
                url: getRootPath() + "/ajax/json_dmt.aspx?prgid=" + $("#prgid").val() + "&seq=" + seq + "&seq1=" + seq1,
                async: false,
                cache: false,
                success: function (json) {
                    dmt_data = $.parseJSON(json);
                },
                error: function (xhr) {
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>抓取案件主檔失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                    $("#dialog").dialog({ title: '抓取案件主檔失敗！', modal: true, maxHeight: 500, width: "90%" });
                }
            });

            if (dmt_data.length == 0) {
                alert(seq + "-" + seq1 + "不存在於案件主檔內，請重新輸入!!!");
                $("#seq_" + nRow).val("");
                $("#aseq1_" + nRow).val("");
                $("#seq_" + nRow).focus();
                return false;
            }

            $("#span_appl_name_" + nRow).html(dmt_data[0].appl_name);
            $("#span_ap_name_" + nRow).html(dmt_data[0].cust_area + dmt_data[0].cust_seq + dmt_data[0].cust_name);
            $("#span_class_" + nRow).html(dmt_data[0].class);
            $("#branch_" + nRow).val(dmt_data[0].cust_area);
            $("#cust_seq_" + nRow).val(dmt_data[0].cust_seq);
            $("#att_sql_" + nRow).val(dmt_data[0].att_sql);

            if (dmt_data[0].end_date != "") {
                alert("該案件已結案，不可客戶發文!!!");
                $("#seq_" + nRow).val("");
                $("#seq_" + nRow).focus();
            }
        }
    }

    //[查詢本所編號]
    brta32form.btnQuery = function (nRow) {
        window.open(getRootPath() + "/brtam/brta21Query.aspx?cgrs=CS&seqnum=" + nRow, "myWindowOneN", "width=650 height=420 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //[案件主檔查詢]
    brta32form.btncase = function (nRow) {
        var tseq = $("#seq_" + nRow).val();
        var tseq1 = $("#aseq1_" + nRow).val();
        if (tseq == "") {
            alert("請先輸入本所編號!!!");
            return false;
        }

        window.open(getRootPath() + "/brt5m/brt15ShowFP.aspx?submittask=Q&seq=" + tseq + "&seq1=" + tseq1 + "&cgrs=CS&seqnum=" + nRow + "&prgid=<%=prgid%>&winact=Y", "DmtmyWindowOne", "width=800 height=520 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }
</script>
