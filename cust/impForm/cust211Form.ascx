<%@ Control Language="C#" ClassName="cust211Form" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace = "System.Text"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Web.Script.Serialization"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected string submitTask = "";
    protected string seBranch = "";


    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        submitTask = Request["submitTask"];
        seBranch = Sys.GetSession("seBranch");
                
        prgid = Request["prgid"].ToString();
    }
    
    
</script>




<input type="hidden" id="hatt_sql" name="hatt_sql" value=""><!--位於第幾位-->
<input type=hidden name=refnum value=0><!--進度筆數-->
<TABLE id="tabref" name="tabref" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<TR>
	    <TD colspan=7 align=center class=greentext1>
	        <font color=white>契&nbsp;&nbsp;約&nbsp;&nbsp;書&nbsp;&nbsp;簽&nbsp;&nbsp;署&nbsp;&nbsp;之&nbsp;&nbsp;客&nbsp;&nbsp;戶&nbsp;&nbsp;設&nbsp;&nbsp;定</font>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type=button value="增加一筆" class="cbutton" tabindex="2" id="ref_Add_button" name="ref_Add_button" />
	    </TD>
	</TR>
	<TR align=center class=lightbluetable>
		<TD>序號</TD><TD>客戶編號/名稱</TD><TD>客戶等級</TD><TD>營洽</TD>
       
	</TR>
        <script type="text/html" id="cust_template"><!--契約書簽署之客戶設定樣板-->
        <tr>
		    <td class="whitetablebg" align="center" nowrap>
                <span id="no_##"></span>
                <input type="hidden" name="chkInsert_##" id="chkInsert_##" value="Y">
                <input type="checkbox" name="refdel_flag_##" id="refdel_flag_##" style="vertical-align:middle;" onclick="cust211form.ChkInsertCust_seq('##')" >
                <span id="delStr_##">刪除</span>
		    </td>
		    <td class="whitetablebg">
                <input type="text" name="scust_area_##" id="scust_area_##" size=1 maxlength=1 class=SEdit readonly>
                <input type="text" name="scust_seq_##" id="scust_seq_##" size="6" maxlength="6" onblur="cust211form.scust_seq_onblur('##')" />
                <input type="button" name="btnquery_cust_seq_##" id="btnquery_cust_seq_##" class="cbutton" value="查詢" onclick="cust211form.QueryCust_seq('##')" >
			    <input type="button" name="btn_cust_seqDetail_##" id="btn_cust_seqDetail_##" class="cbutton" value="詳細" onclick="cust211form.GetCustzData('##')">
                <input type="text" name="scust_name_##" id="scust_name_##" size=30 class=SEdit readonly>
                <input type="hidden" name="sapsqlno_##" id="sapsqlno_##" />
                <%--<input TYPE="text" NAME="att_sql_##" id="att_sql_##" SIZE="5" MAXLENGTH="5" readonly class="sedit" value="">
                <input TYPE="button" NAME="btnattedit_##" id="btnattedit_##" class="cbutton" hidden="hidden" value="修改">--%>
		    </td>
		    <td class="whitetablebg" align="center">
                <input type="text" name="aplevelnm_##" id="aplevelnm_##" size=10 class=SEdit readonly>
		    </td>
		    <td class="whitetablebg" align="center">
			    <input type="text" name="scodenm_##" id="scodenm_##"  size=10 class=SEdit readonly>
		    </td>
	    </tr>
        </script>
</TABLE>




<script language="javascript" type="text/javascript">
    //****每個form都有自已的別名
    var cust211form = {};
    //畫面初始化
    cust211form.init = function () {
        if ('<%=submitTask%>' == "Q") {
            //$("#ref_Add_button").hide();
        }

    }
    //資料綁定
    cust211form.bind = function (jData) {
        $("#hatt_sql").val("0");
        $.each(jData, function (i, item) {
            cust211form.addAtt();//新增一筆
            var nRow = $("#hatt_sql").val();
            $("#refdel_flag_1").lock();

            //$("#no_" + nRow).text(nRow + ". ");
            $("#scust_area_" + nRow).val(item.cust_area); //$("input[name=oattention]").val(item.attention);
            $("#scust_seq_" + nRow).val(item.cust_seq); //$("input[name=oatt_title]").val(item.att_title);
            $("#scust_name_" + nRow).val(item.ap_cname1+item.ap_cname2); //$("input[name=oatt_dept]").val(item.att_dept);
            $("#aplevelnm_" + nRow).val(item.levelnm); 
            $("#scodenm_" + nRow).val(item.scode + item.scodenm);
            $("#sapsqlno_" + nRow).val(item.apsqlno);
        })
    }

    //[增加一筆]
    cust211form.addAtt = function () {
        var nRow = CInt($("#hatt_sql").val()) + 1;//畫面顯示NO
        //複製樣板
        var copyStr = $("#cust_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);
        //$("#tbl_att>tbody").append(copyStr);
        $("#tabref").append(copyStr);
        $("#no_" + nRow).text(nRow + ". ");
        $("#scust_area_" + nRow).val('<%=seBranch%>');
        $("#hatt_sql").val(nRow);

        if (nRow == 1) {
            $("#refdel_flag_1").lock();//固定第一筆不能勾選刪除
        }
    }
    

    $("#ref_Add_button").click(function (e) {
        cust211form.addAtt();
    });


    cust211form.SetReadOnly = function () {
        $("#ref_Add_button").hide();
        $(":checkbox").hide();
        $("span[id^='delStr']").hide();
        $("input[id^='scust_seq']").lock();
        $("input[id^='btnquery_cust_seq']").lock();

    }

    cust211form.ChkInsertCust_seq = function (nRow) {
        if ($("#refdel_flag_" + nRow).prop("checked") == true) {
            $("#chkInsert_" + nRow).val("N");
        }
        else {
            $("#chkInsert_" + nRow).val("Y");
        }

    }

    cust211form.QueryCust_seq = function (nRow) {
        var url = "cust11_1.aspx?prgid=cust21&submitTask=Q&no="+nRow;
        //window.open(url, "_blank");
        window.open(url, "myWindowQ", "width=1024 height=768 top=20 left=20 toolbar=no, menubar=no, location=no, directories=no resizable=yes status=yes scrollbars=yes");
    }

    cust211form.scust_seq_onblur = function (nRow) {

        var cust_areaStr = NulltoEmpty($("#scust_area_" + nRow).val()); 
        var cust_seqStr = NulltoEmpty($("#scust_seq_" + nRow).val());
        if (cust_seqStr == "") return false;

        var dept = '<%=Sys.GetSession("dept").ToLower()%>';
        var SQLStr = "SELECT a.cust_area, a.cust_seq, b.apcust_no, b.ap_cname1, b.ap_cname2, b.ap_crep, b.ap_country, a."+dept+"scode as scode, b.apsqlno, ";
        SQLStr += "(select sc_name from sysctrl.dbo.scode where scode = a."+dept+"scode) as scodename, ";
        SQLStr += "(select code_name from cust_code where code_type='level' and cust_code=a."+dept+"level) as levelnm ";
        SQLStr += "FROM custz a LEFT JOIN apcust b ON a.cust_seq=b.cust_seq WHERE a.cust_area = '" + cust_areaStr + "' AND a.cust_seq = " + cust_seqStr;

        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx",
            type: "get",
            async: false,
            cache: false,
            data: { sql: SQLStr },
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length != 0) {

                    $("#scust_name_" + nRow).val(JSONdata[0]["ap_cname1"] + JSONdata[0]["ap_cname2"]);
                    $("#aplevelnm_" + nRow).val(JSONdata[0]["levelnm"]);
                    $("#scodenm_" + nRow).val(JSONdata[0]["scode"] + JSONdata[0]["scodename"]);
                    $("#sapsqlno_" + nRow).val(JSONdata[0]["apsqlno"]);
                }
                else {
                    alert("此客戶編號不存在!");
                    $("#scust_name_" + nRow).val('');
                    $("#aplevelnm_" + nRow).val('');
                    $("#scodenm_" + nRow).val('');
                    $("#sapsqlno_" + nRow).val('');
                    return;
                }
            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });
    }//scust_seq_onblur

    cust211form.GetCustzData = function (nRow) {
        var SQLStr = "select apsqlno, cust_seq from apcust where apsqlno <> ''";
        SQLStr += " AND cust_seq is not null and cust_seq <> 0";
        SQLStr += " AND cust_seq = '" + $.trim($("#scust_seq_" + nRow).val()) + "'";

        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx",
            type: "get",
            async: false,
            cache: false,
            data: { sql: SQLStr },
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length != 0) {
                    var url = "cust11_Edit.aspx?prgid=cust11_2&submitTask=Q&cust_area=<%=Sys.GetSession("seBranch")%>&cust_seq=" + $.trim($("#scust_seq_" + nRow).val());
                    window.open(url, "_blank");

                }
                else {
                    alert("此客戶編號不存在!");
                    return;
                }
            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });
    }//GetCustzData
   


</script>

