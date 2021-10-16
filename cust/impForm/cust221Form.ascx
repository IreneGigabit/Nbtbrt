<%@ Control Language="C#" ClassName="cust221Form" %>
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
	        <font color=white>委&nbsp;&nbsp;任&nbsp;&nbsp;書&nbsp;&nbsp;簽&nbsp;&nbsp;署&nbsp;&nbsp;之&nbsp;&nbsp;申&nbsp;&nbsp;請&nbsp;&nbsp;人&nbsp;&nbsp;設&nbsp;&nbsp;定</font>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type=button value="增加一筆" class="cbutton" tabindex="2" id="ref_Add_button" name="ref_Add_button" />
	    </TD>
	</TR>
	<TR align=center class=lightbluetable>
		<TD>序號</TD><TD>申請人統編/名稱</TD><TD>代表人</TD><TD>申請人種類</TD>
       
	</TR>
        <script type="text/html" id="cust_template"><!--契約書簽署之客戶設定樣板-->
        <tr>
		    <td class="whitetablebg" align="center" rowspan="2" nowrap>
                <span id="no_##"></span>
                <input type="hidden" name="chkInsert_##" id="chkInsert_##" value="Y">
                <input type="checkbox" name="refdel_flag_##" id="refdel_flag_##" style="vertical-align:middle;" onclick="cust221form.ChkInsertCust_seq('##')" >
                <span id="delStr_##">刪除</span>
		    </td>
		    <td class="whitetablebg">
                <input type="text" name="scust_area_##" id="scust_area_##" size=1 maxlength=1 class=SEdit readonly>-
                <input type="text" name="sapcust_no_##" id="sapcust_no_##" size="10" maxlength="10" onblur="cust221form.sapcust_no_onblur('##')" />
                <input type="button" name="btnquery_apcust_no_##" id="btnquery_apcust_no_##" class="cbutton" value="查詢" onclick="cust221form.QueryApcust_no('##')" >
			    <input type="button" name="btn_cust_seqDetail_##" id="btn_cust_seqDetail_##" class="cbutton" value="詳細" onclick="cust221form.GetApcustData('##')">
                <input type="text" name="sap_cname_##" id="sap_cname_##" size=30 class=SEdit readonly>
                <input type="hidden" name="sapsqlno_##" id="sapsqlno_##" />
                <%--<input TYPE="text" NAME="att_sql_##" id="att_sql_##" SIZE="5" MAXLENGTH="5" readonly class="sedit" value="">
                <input TYPE="button" NAME="btnattedit_##" id="btnattedit_##" class="cbutton" hidden="hidden" value="修改">--%>
		    </td>
		    <td class="whitetablebg" align="center">
                <input type="text" name="ap_crep_##" id="ap_crep_##" size=10 class=SEdit readonly>
		    </td>
		    <td class="whitetablebg" align="center">
			    <input type="text" name="apclassnm_##" id="apclassnm_##"  size=20 class=SEdit readonly>
		    </td>
	    </tr>
        <tr>
            <td class="whitetablebg" align="left" colspan="3">
                申請人地址:<input type="text" name="ap_addr_##" id="ap_addr_##" size="100" class="SEdit" readonly /><br />
                <input type="text" name="ap_eaddr_##" id="ap_eaddr_##" size="120" class="SEdit" readonly />
            </td>
        </tr>
            

        </script>
</TABLE>




<script language="javascript" type="text/javascript">
    //****每個form都有自已的別名
    var cust221form = {};
    //畫面初始化
    cust221form.init = function () {
        if ('<%=submitTask%>' == "Q") {
            //$("#ref_Add_button").hide();
        }

    }
    //資料綁定
    cust221form.bind = function (jData) {
        $("#hatt_sql").val("0");
        $.each(jData, function (i, item) {
            cust221form.addAtt();//新增一筆
            var nRow = $("#hatt_sql").val();
            $("#refdel_flag_1").lock();

            //$("#no_" + nRow).text(nRow + ". ");
            $("#scust_area_" + nRow).val(item.cust_area);
            $("#sapcust_no_" + nRow).val(item.apcust_no);
            $("#sap_cname_" + nRow).val(item.ap_cname1 + item.ap_cname2);
            $("#ap_crep_" + nRow).val(item.ap_crep);
            $("#apclassnm_" + nRow).val(item.apclass+item.apclassnm);
            $("#sapsqlno_" + nRow).val(item.apsqlno);
            $("#ap_addr_" + nRow).val(item.ap_addr1+item.ap_addr2);
            $("#ap_eaddr_" + nRow).val(item.ap_eaddr1+item.ap_eaddr2);

        })
    }

    //[增加一筆]
    cust221form.addAtt = function () {
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
        cust221form.addAtt();
    });


    cust221form.SetReadOnly = function () {
        $("#ref_Add_button").hide();
        $(":checkbox").hide();
        $("span[id^='delStr']").hide();
        $("input[id^='sapcust_no']").lock();
        $("input[id^='btnquery_apcust_no']").lock();

    }

    cust221form.ChkInsertCust_seq = function (nRow) {
        if ($("#refdel_flag_" + nRow).prop("checked") == true) {
            $("#chkInsert_" + nRow).val("N");
        }
        else {
            $("#chkInsert_" + nRow).val("Y");
        }

    }

    cust221form.QueryApcust_no = function (nRow) {
        var url = "cust13.aspx?prgid=cust22&submitTask=Q&no="+nRow;
        //window.open(url, "_blank");
        window.open(url, "myWindowQ", "width=1024 height=768 top=20 left=20 toolbar=no, menubar=no, location=no, directories=no resizable=yes status=yes scrollbars=yes");
    }

    cust221form.sapcust_no_onblur = function (nRow) {

        //var cust_areaStr = NulltoEmpty($("#scust_area_" + nRow).val()); 
        var apcust_noStr = NulltoEmpty($("#sapcust_no_" + nRow).val());
        if (apcust_noStr == "") return false;

        //2016/3/31修改，經與雅卿確認，簽屬委任狀之申請人有可能不是客戶，而申請人不會記錄cust_area及cust_seq，所以不加cust_area條件
        //var dept = '<%=Sys.GetSession("dept").ToLower()%>';
        var SQLStr = "select a.apsqlno,a.ap_cname1,a.ap_cname2,a.apclass,a.ap_crep,a.ap_erep, ";
        SQLStr += "a.ap_addr1,a.ap_addr2,a.ap_eaddr1,a.ap_eaddr2,a.ap_eaddr3,a.ap_eaddr4, ";
        SQLStr += "(select code_name From cust_code where Code_type='apclass' and cust_code=a.apclass) as apclassnm, ";
        SQLStr += "(select mark From cust_code where Code_type='apclass' and cust_code=a.apclass) as mark "
        SQLStr += "from apcust a WHERE a.apcust_no = '" + apcust_noStr + "'" ;

        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx",
            type: "get",
            async: false,
            cache: false,
            data: { sql: SQLStr },
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length != 0) {

                    $("#sap_cname_" + nRow).val(JSONdata[0]["ap_cname1"] + JSONdata[0]["ap_cname2"]);
                    $("#ap_crep_" + nRow).val(JSONdata[0]["ap_crep"]);
                    $("#apclassnm_" + nRow).val(JSONdata[0]["apclass"] + JSONdata[0]["apclassnm"]);
                    $("#sapsqlno_" + nRow).val(JSONdata[0]["apsqlno"]);
                    $("#ap_addr_" + nRow).val(JSONdata[0]["ap_addr1"] + JSONdata[0]["ap_addr2"]);
                    $("#ap_eaddr_" + nRow).val(JSONdata[0]["ap_eaddr1"] + JSONdata[0]["ap_eaddr2"] + JSONdata[0]["ap_eaddr3"] + JSONdata[0]["ap_eaddr4"]);
                }
                else {
                    alert("此申請人編號不存在!");
                    $("#sap_cname_" + nRow).val('');
                    $("#ap_crep_" + nRow).val('');
                    $("#apclassnm_" + nRow).val('');
                    $("#sapsqlno_" + nRow).val('');
                    $("#ap_addr_" + nRow).val('');
                    $("#ap_eaddr_" + nRow).val('');
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
    }//sapcust_no_onblur

    cust221form.GetApcustData = function (nRow) {
        var SQLStr = "select apsqlno, apcust_no from apcust where apsqlno <> ''";
        SQLStr += " AND apsqlno = '" + $.trim($("#sapsqlno_" + nRow).val()) + "'";
        SQLStr += " AND apcust_no = '" + $.trim($("#sapcust_no_" + nRow).val()) + "'";

        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx",
            type: "get",
            async: false,
            cache: false,
            data: { sql: SQLStr },
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length != 0) {
                    var url = "cust13_Edit.aspx?prgid=cust13_2&submitTask=Q&apsqlno=" + $.trim($("#sapsqlno_" + nRow).val()) + "&apcust_no=" + $.trim($("#sapcust_no_" + nRow).val());
                    window.open(url, "_blank");

                }
                else {
                    alert("此申請人編號不存在!");
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

