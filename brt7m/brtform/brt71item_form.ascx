<%@ Control Language="C#" ClassName="brt71item_form" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //父控制項傳入的參數
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public int HTProgRight = 0;
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        this.DataBind();
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<div align=right>
<input type="text" value="0" id="curr" name="curr">
<input type="button" value="增加其他案件" class="cbutton" onClick="brt71item_form.formAdd()" id="btnadd" name="btnadd">
</div>
<table id="arList" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
    <thead>
    <tr align="left"> 
	    <td align="center" class="lightbluetable" width=4%>NO.</td>   
  	    <td align="center" class="lightbluetable" width=10%>交辦單號(契約號碼)</td>
  	    <td align="center" class="lightbluetable" width=10%>案件編號</td>
  	    <td align="center" class="lightbluetable" width=20%>案件名稱</td>
	    <td align="center" class="lightbluetable" width=6%>請款註記</td>
  	    <td align="center" class="lightbluetable" width=14%>案性</td>
	    <td align="center" class="lightbluetable" width=8%>服務費</td>
	    <td align="center" class="lightbluetable" width=8%>規費</td>
	    <td align="center" class="lightbluetable">小計</td>
        <td align="center" class="lightbluetable">請款作業</td>
    </tr>
    </thead>
    <tbody></tbody>
    <script type="text/html" id="mcase_template"><!--主案性樣板-->
	    <tr id=tr_mcase_##>
	        <td class=whitetablebg align="center">##
                <input TYPE="hidden" name="modify_##" id="modify_##">
                <input type="hidden" name="tin_no_##" id="tin_no_##">
                <input type="hidden" name="tin_scode_##" id="tin_scode_##">
                <input TYPE="hidden" name="case_no_##" id="case_no_##">
	        </td>
	        <td class=whitetablebg align="center">{{case_no}}({{strcontract_no}})</td>
	        <td class=whitetablebg align="center">{{fseq}}</td>	
	        <td class=whitetablebg align="center">{{appl_name}}</td>
	        <td class=whitetablebg align="center">{{strar_mark}}</td>
	        <td class=whitetablebg align="center">{{case_name}}</td>
	        <td class=whitetablebg align=right>{{ar_service}}<span id="span_tr_money_##" style="display:none"><font color=red>*</font></span></td>
	        <td class=whitetablebg align=right>{{ar_fees}}</td>
	        <td class=whitetablebg align=left style="BACKGROUND-COLOR:#ccffff">
                <input style="text-align:right;BACKGROUND-COLOR:#ccffff" type=text name="ar_money_{{nRow}}" id="ar_money_{{nRow}}" readonly class="SEdit" size=8>
	        </td>
	        <td class=whitetablebg align="center">
		        <input type=button name="btn1" class="cbutton" value="編修" onclick="brt71item_form.formEdit('##', 'M')">
		        <input type=button name="btn2" class="cbutton" value="刪除" onclick="brt71item_form.formEdit('##', 'D')">
	        </td>
        </tr>
    </script>
    <script type="text/html" id="ocase_template"><!--次委辦案性樣板-->
	    <tr id=tr_ocase_##>
		    <td class=whitetablebg align="center"></td>
		    <td class=whitetablebg align="center"></td>		
		    <td class=whitetablebg align="center"></td>	
		    <td class=whitetablebg align="center"></td>
		    <td class=whitetablebg align="center"></td>
	        <td class=whitetablebg align="center">{{case_name}}</td>
	        <td class=whitetablebg align=right>{{ar_service}}<span id="span_tr_money_##" style="display:none"><font color=red>*</font></span></td>
	        <td class=whitetablebg align=right>{{ar_fees}}</td>
	        <td class=whitetablebg align=left style="BACKGROUND-COLOR:#ccffff">
                <input style="text-align:right;BACKGROUND-COLOR:#ccffff" type=text name="ar_money_{{nRow}}" id="ar_money_{{nRow}}" readonly class="SEdit" size=8>
	        </td>
	        <td class=whitetablebg align="center"></td>
        </tr>
    </script>
    <tfoot>
	<tr>
		<td align="right" class="whitetablebg" colspan=6>合計：</td>
		<td class=whitetablebg align=right><span id="span_sum_service"></span><input type="text" name="sum_service" id="sum_service"></td>
		<td class=whitetablebg align=right><span id="span_sum_fees"></span></td>
		<td align="left" class="whitetablebg" style="BACKGROUND-COLOR: #ccffff">
            <input type=text style="text-align:right;BACKGROUND-COLOR: #ccffff" name="tot_money" id="tot_money" size=8 readonly class="SEdit">
		</td>
        <td class=whitetablebg></td>
	</tr>
	<tr align="left"> 
	    <td align="right" class="lightbluetable"  colspan=3>-已預收未請款金額：</td>
	    <td align="center" class="whitetablebg"  ><input type=text name="pre_money" id="pre_money" size=8 value=0 onblur="brt71item_form.unrec_chk(this.value) "></td>
	    <td align="right" class="lightbluetable" colspan=4>=本次應付金額：</td>
	    <td align="left" class="whitetablebg"  style="BACKGROUND-COLOR: #ccffff">
            <input type=text style="text-align:right;BACKGROUND-COLOR: #ccffff" name="unre_money" id="unre_money" size=8 readonly class="SEdit">
	        <input type="text" name="tot_ar_money" id="tot_ar_money">
	    </td>   
        <td class=whitetablebg></td>
	</tr>
	<tr>
		<TD class="lightbluetable" align="right" colspan=3>開立種類：</TD>
		<td class=whitetablebg colspan=7>
			<input type=text id="hdrec_type" name="hdrec_type" value="A">
			<label><input type=radio name="rec_type" value="A" onclick="brt71item_form.rectype_chk('A')">僅開服務費(規費附官方收據)</label>
			<label><input type=radio name="rec_type" value="C" onclick="brt71item_form.rectype_chk('C')">僅開服務費(規費開代收轉帳收據)</label>
			<label><input type=radio name="rec_type" value="B" onclick="brt71item_form.rectype_chk('B')">全額開本所收據</label>
        </td>
	</tr>
 	<tr>
		<TD class="lightbluetable" align="right" colspan=3>請款單顯示：</TD>
		<td class=whitetablebg colspan=7>
			<input type=text id="hdtdshow" name="hdtdshow" value="D">
			<label><input type=radio name="tdshow" value="D" disabled checked onclick="brt71item_form.tdshow_chk()">服務費與規費分開</label>
			<label><input type=radio name="tdshow" value="T" disabled onclick="brt71item_form.tdshow_chk()">服務費與規費合併</label>
		</td>
	</tr>
	<tr>
		<TD class="lightbluetable" align="right" colspan=3>代扣稅款：</TD>
		<td class=whitetablebg colspan=7>
			<input type=text id="hdtaxchk" name="hdtaxchk" value="N">
			<label><input type=radio name="tax_chk" value="N" onclick="brt71item_form.tax_chk71()">不顯示</label>
			<label><input type=radio name="tax_chk" value="Y" onclick="brt71item_form.tax_chk71()">要顯示&nbsp;&nbsp;<font color=red>代扣稅款：<input type=text name="tax_money" id="tax_money" size=6 style="color:red" readonly class="SEdit" value=0></font></label>
			<label><input type=radio name="tax_chk" value="X" onclick="brt71item_form.tax_chk71()">稅款少於2000不需扣繳</label>
			<label><input type=radio name="tax_chk" value="B" onclick="brt71item_form.tax_chk71()">個人不需扣繳</label>
		</td>
	</tr>
	<tr>
		<TD class="lightbluetable" align="right" colspan=3>請款說明：</TD>
		<td class=whitetablebg colspan=7>
			<input type=text id="hdmark_code1" name="hdmark_code1" value="N">
			<input type=text id="hdmark_code2" name="hdmark_code2" value="N">
			<label><input type="checkbox" name="mark_code1" value="Y" onclick="brt71item_form.markcode_chk71()">已付回郵</label>
			<label><input type="checkbox" name="mark_code2" value="Y" onclick="brt71item_form.markcode_chk71()">開立英文invoice</label>
			<br><textarea name="remark" id="remark" rows=3 cols=70></textarea>
		</td>
	</tr>
   </tfoot>
</table>

<script language="javascript" type="text/javascript">
    var brt71item_form={};
    brt71item_form.init = function () {
        $("#arList>tbody").empty();
        $("#curr").val("0");

        //開立種類
        if ((main.right & 128) != 0) {
            $("input[name='rec_type']").unlock();
        } else {
            $("input[name='rec_type']").lock();
        }
        var rec_type = "<%=Request["rec_type"]%>";
        if (rec_type == "") rec_type = "A";
        $("input[name='rec_type'][value='" + rec_type + "']").prop("checked", true).triggerHandler("click");

        //請款單顯示
        var tdshow = "<%=Request["tdshow"]%>";
        if (tdshow == "") tdshow = "D";
        $("input[name='tdshow'][value='" + tdshow + "']").prop("checked", true).triggerHandler("click");

        //代扣稅款
        var tax_chk = "<%=Request["tax_chk"]%>";
        if (tax_chk == "") tax_chk = "N";
        $("input[name='tax_chk'][value='" + tax_chk + "']").prop("checked", true).triggerHandler("click");

        //請款說明
        $("input[name='mark_code1'][value='<%=Request["mark_code1"]%>']").prop("checked", true);
        $("input[name='mark_code2'][value='<%=Request["mark_code2"]%>']").prop("checked", true);
        $("input[name='mark_code2']:checked").triggerHandler("click");
        $("#remark").val("<%=Request["remark"]%>");
    }

    brt71item_form.bind = function (jData) {
        var sum_service = 0, sum_fees = 0, tot_ar_money = 0;//合計

        $.each(jData.ar_item, function (i, item) {
            var curr = item.curr;//行號
            $("#curr").val(curr);

            var copyStr = "";
            if (item.item_sql == "0") {
                copyStr = $("#mcase_template").text() || "";//主辦性樣板
                copyStr = copyStr.replace(/##/g, curr);
            } else {
                copyStr = $("#ocase_template").text() || "";//次委辦案性樣板
                copyStr = copyStr.replace(/##/g, curr);
            }

            if (curr % 2 == 1) tclass = "sfont9"; else tclass = "lightbluetable3";
            copyStr = copyStr.replace(/{{tclass}}/g, tclass);
            copyStr = copyStr.replace(/{{case_no}}/g, item.case_no);
            copyStr = copyStr.replace(/{{strcontract_no}}/g, item.strcontract_no);
            copyStr = copyStr.replace(/{{fseq}}/g, item.fseq);
            copyStr = copyStr.replace(/{{appl_name}}/g, item.appl_name);
            copyStr = copyStr.replace(/{{strar_mark}}/g, item.strar_mark);
            copyStr = copyStr.replace(/{{case_name}}/g, item.case_name);
            copyStr = copyStr.replace(/{{ar_service}}/g, item.ar_service);
            copyStr = copyStr.replace(/{{ar_fees}}/g, item.ar_fees);
            copyStr = copyStr.replace(/{{nRow}}/g, i);

            $("#arList>tbody").append(copyStr);
            $("#modify_" + curr).val(item.modify);
            $("#tin_no_" + curr).val(item.in_no);
            $("#tin_scode_" + curr).val(item.in_scode);
            $("#case_no_" + curr).val(item.case_no);
            if (item.oth_money > 0) {
                $("#span_tr_money_" + curr).show();
            }
            $("#ar_money_" + i).val(item.ar_money.format());

            sum_service += item.ar_service;
            sum_fees += item.ar_fees;
            tot_ar_money += item.ar_money;
        });

        $("#span_sum_service").html(sum_service);//合計服務費費
        $("#sum_service").val(sum_service);//合計服務費
        $("#span_sum_fees").html(sum_fees);//合計規費
        $("#tot_money").val(tot_ar_money.format());//總計
        $("#tot_ar_money").val(tot_ar_money);//總計
        $("#unre_money").val(tot_ar_money.format());//本次應付金額
    }

    //重新載入明細
    brt71item_form.reload = function () {
        $("#arList>tbody").empty();
        $("#curr").val("0");
        loadData();
        brt71item_form.bind(jMain);
    }

    //計算本次應付金額
    brt71item_form.unrec_chk = function (tmoney) {
        $("#unre_money").val((CDbl($("#tot_ar_money").val())-CDbl(tmoney)).format());
    }

    //抓取請款單顯示
    brt71item_form.rectype_chk = function (stype) {
	if (stype == "A" || stype == "C"){//僅開服務費
        //服務費與規費分開
        $("input[name='tdshow'][value='D']").prop("checked",true).triggerHandler("click");
	}
	if (stype == "B"){
		//服務費與規費合併
        $("input[name='tdshow'][value='T']").prop("checked",true).triggerHandler("click");
	}
        $("#hdrec_type").val(stype);
	    brt71item_form.get_taxmoney();
    }

    //抓取請款單顯示值
    brt71item_form.tdshow_chk = function () {
        $("#hdtdshow").val($("input[name='tdshow']:checked").val()||"");
	    brt71item_form.get_taxmoney();
    }

    //計算代扣稅款
    brt71item_form.get_taxmoney = function () {
        if($("#apclass").val()=="B"){//本國人(身份證10碼)
            $("#tax_money").val("0");
            //個人不需扣繳
            $("input[name='tax_chk'][value='B']").prop("checked",true).triggerHandler("click");
        }else{
            if($("#hdtdshow").val()=="T"){//服務費與規費合併
                $("#tax_money").val(CInt($("#tot_money").val())*0.1+0.5);//用合計(服務費+規費)算
            }
            if($("#hdtdshow").val()=="D"){//服務費與規費分開
                $("#tax_money").val(CInt($("#sum_service").val())*0.1+0.5);//用合計服務費算
            }

            if(CInt($("#tax_money").val())<=2000){
                $("#tax_money").val("0");
                //稅款少於2000不需扣繳
                $("input[name='tax_chk'][value='X']").prop("checked",true).triggerHandler("click");
            }else{
                //要顯示
                $("input[name='tax_chk'][value='Y']").prop("checked",true).triggerHandler("click");
            }
        }
    }

    //代扣稅款選項
    brt71item_form.tax_chk71 = function () {
        if($("#apclass").val()=="B"){//本國人(身份證10碼)
            //個人不需扣繳
            $("input[name='tax_chk'][value='B']").prop("checked",true);
        }else{
            if(CInt($("#tax_money").val())<=2000){
                $("#tax_money").val("0");
                //稅款少於2000不需扣繳
                $("input[name='tax_chk'][value='X']").prop("checked",true);
            }else{
                if($("input[name='tax_chk'][value='N']").prop("checked")==true){//不顯示
                    //2015/2/25修改，林和宗反應外國公司不用代扣，經與薇娟確認可不用代扣，先預設要代扣，但可選擇不代扣	
                    if($("#apclass").val()!="CA"&&$("#apclass").val()!="CB"&&$("#apclass").val()!="CT"){
                        //014/9/26修改，依2014/5月份帳款系統會議，>2000預設要顯示且不能修改
                        $("input[name='tax_chk'][value='Y']").prop("checked",true);
                    }
                }else{
                    //2014/9/26修改，依2014/5月份帳款系統會議，>2000預設要顯示且不能修改
                    $("input[name='tax_chk'][value='Y']").prop("checked",true);
                }
		    }
	    }

        $("#hdtaxchk").val($("input[name='tax_chk']:checked").val()||"");
    }

    //請款說明選項
    brt71item_form.markcode_chk71 = function () {
        if($("input[name='mark_code1']").prop("checked")==true){//已付回郵
            $("#hdmark_code1").val("Y");
        }else{
            $("#hdmark_code1").val("N");
        }

        if($("input[name='mark_code2']").prop("checked")==true){//開立英文invoice
            $("#hdmark_code2").val("Y");
        }else{
            $("#hdmark_code2").val("N");
        }
    }

    //[增加其他案件]
    brt71item_form.formAdd = function () {
        $('#dialog').html('<iframe id="itemFrame" name="itemFrame" style="border: 0px;" src="about:blank" width="100%" height="100%"></iframe>')
        .dialog({autoOpen: true,modal: true,height: 540,width: "95%",title: "增加其他案件"});

	    var url="Ext71_List.aspx?modify=U&qs_dept=t&Type=N&tot_count="+$("#curr").val()+"&scode="+ $("#Scode").val();
        reg.target="itemFrame";
        reg.action=url;
        reg.submit();
    }

    //[編修][刪除]
    brt71item_form.formEdit = function (curr,task) {
        if (task == "M") {
            reg.action="Brt71_Modify.asp?apsqlno="+$("#apsqlno").val()+"&serial_no="+ curr + "&Task=" + task + "&att_sql="+ $("#att_sql").val()+  "&scode="  + $("#Scode").val();
            reg.submit();
        }

        if (task == "D") {
            if(CInt($("#curr").val())==1){
                alert("該筆請款單僅有一筆請款案件，不能刪除！");
                return false;
            }
            if (confirm("是否確認此筆交辦案件不列入請款？")){
                var url="Brt71_SaveItem.aspx?apsqlno="+$("#apsqlno").val()+"&modify=U&serial_no=" + curr + "&Task=" + task + "&tdshow=" + $("#hdtdshow").val()+ "&att_sql=" + $("#att_sql").val()+ "&scode=" + $("#Scode").val();
		        //reg.action=url;
                //reg.submit();

                var formData = new FormData($('#reg')[0]);
                $.ajax({
                    url: url,
                    type: "post",
                    data: formData,
                    contentType: false,
                    cache: false,
                    processData: false,
                    success: function (json) {
                        //重load明細就好.畫面不重新整理
                        brt71item_form.reload();
                    },
                    error: function (xhr) {
                        $("#dialog").html("<a href='" + this.url + "' target='_new'>新增請款資料失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                        $("#dialog").dialog({ title: '新增請款資料失敗！', modal: true, maxHeight: 500, width: "90%" });
                    }
                });
            }
	    }
    }
</script>
