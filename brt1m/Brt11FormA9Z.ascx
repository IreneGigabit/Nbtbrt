﻿<%@ Control Language="C#" ClassName="Brt11FormA9Z" %>
<%@ Register Src="~/brt1m/CaseForm/A9Z_end.ascx" TagPrefix="uc1" TagName="A9Z_end" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //A5分割案交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string ar_form = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        ar_form = (Request["ar_form"] ?? "").Trim();
        PageLayout();
        this.DataBind();
    }
    
    private void PageLayout() {
        //交辦內容欄位畫面
        if (ar_form == "A3") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FFForm.ascx"));//註冊費
        } else if (ar_form == "A4") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FR1Form.ascx"));//延展
        } else if (ar_form == "A5") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FD1Form.ascx"));//分割
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FD2Form.ascx"));//分割
        } else if (ar_form == "A6") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FC1Form.ascx"));//變更
        } else if (ar_form == "A7") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FL1Form.ascx"));//授權
        } else if (ar_form == "A8") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FT1Form.ascx"));//移轉
        } else if (ar_form == "A9") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FP1Form.ascx"));//質權
        } else if (ar_form == "AA") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FN1Form.ascx"));//各種證明書
        } else if (ar_form == "AB") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FI1Form.ascx"));//補(換)發證
        } else if (ar_form == "AC") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FV1Form.ascx"));//閲案
        } else if (ar_form == "B") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/DO1Form.ascx"));//申請異議
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/DR1Form.ascx"));//申請廢止
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/DI1Form.ascx"));//申請評定
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/BZZ1Form.ascx"));//無申請書之交辦內容案
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/B5C1Form.ascx"));//聽證
        } else {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/ZZ1Form.ascx"));
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FOBForm.ascx"));
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/B5C1Form.ascx"));
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FOFForm.ascx"));
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FB7Form.ascx"));
        }
    }
</script>
<script language="javascript" type="text/javascript">
    var br_form = {};
    br_form.init = function () {
    }

    //檢查類別範圍0~45
    br_form.checkclass = function (xclass) {
        if (CInt(xclass) < 0 || CInt(xclass) > 45) {
            alert("商品類別需介於1~45之間,請重新輸入。");
            return false;
        }
    }
    
    //classCount:要改成幾筆,countTar:儲存畫面有上幾筆的欄位,template:樣板,appendTar:要append的位置
    br_form.Add_class = function (classCount, countTar, template, appendTar) {
        var doCount = Math.max(0, CInt(classCount));//要改為幾筆,最少是0
        var num = CInt($(countTar).val());//目前畫面上有幾筆
        if (doCount > num) {//要加
            for (var nRow = num2; nRow < doCount ; nRow++) {
                var copyStr = $(template).text() || "";
                copyStr = copyStr.replace(/##/g, nRow + 1);
                $(countTar).append(copyStr);
                $(countTar).val(nRow + 1);
            }
        } else {
            //要減
            for (var nRow = num; nRow > doCount ; nRow--) {
                $('.' + template.replace('#', '') + "_" + +nRow, $(appendTar)).remove();
                $(countTar).val(nRow - 1);
            }
        }
    }
    
    //依商品名稱計算商品項目數
    br_form.good_name_count = function (pVal, pTar) {
        var MyString = $("#" + pVal).val().trim();
        MyString = MyString.replace(/;/gm, "；");
        MyString = MyString.replace(/,/gm, "，");

        if (MyString.Right(1) == "；" || MyString.Right(1) == "，" || MyString.Right(1) == "、") {
            MyString = MyString.substring(0, MyString.length - 1);
        }

        if (MyString != "") {
            var myarray = MyString.split(/[；，、]/);
            $("#" + pVal).val(MyString);
            var aKind = myarray.length;//共幾類
            alert("商品內容共" + aKind + "項");
            if (pTar != "") {
                $("#" + pTar).val(aKind);
            }

            if (MyString.indexOf("及") > -1 || MyString.indexOf("或") > -1) {
                alert("【商品服務項目中包含有「及」、「或」等用語，請留意商品項目數。】");
            }
        }
    }
    
    //附件
    //selector:物件範圍,pfld:附件欄位名,tar:目的欄位
    br_form.AttachStr = function (selector, pfld, tar) {
        var strRemark1 = "";

        $(selector + " :checkbox").each(function (index) {
            var $this = $(this);
            if ($this.prop("checked")) {
                strRemark1 += $this.val()
                //其他文件輸入框
                if ($("#" + pfld + $this.val() + "t").length > 0) {
                    if ($("#" + pfld + $this.val() + "t").val() != "") {
                        strRemark1 += "|Z9-" + $("#" + pfld + $this.val() + "t").val() + "-Z9";
                    }
                }
                strRemark1 += "|";
            }
        });
        tar.value = strRemark1;
    }
</script>
<%=Sys.GetAscxPath(this)%>
<div id="load_form"></div>
<uc1:A9Z_end runat="server" ID="A9Z_end" />
<!--include file="../brt1m/CaseForm/A9Z_end.ascx"--><!--結案復案資料-->

<asp:PlaceHolder ID="tranHolder" runat="server"></asp:PlaceHolder><!--交辦內容.依ar_form動態載入form-->

<script language="javascript" type="text/javascript">
    //依案性切換要顯示的欄位
    br_form.changeTagA7 = function (T1) {
        var code3 = T1.Left(3).toUpperCase();//案性前3碼
        var arcase = T1;//案性
        var prt_code = $("#tfy_Arcase option:selected").attr("v1") || "";//載入form(code_br.prt_code)
        var pagt_no = $("#tfy_Arcase option:selected").attr("v2") || "";//案性預設出名代理人(code_br.remark)

        $("[id^='tabrem']").hide();
        var tabid=arcase.substr(2,1);
        if (arcase == "FL5")//授權一案多件同FL1
            tabid = "1";
        else if (arcase == "FL6")//再授權一案多件同FL2
            tabid = "2";
        $("#tabrem" + tabid).show();

        $("input[id^='v2'").val("");//清除專用權人資料
        //附件清空
        $("input[name^='ttz1_'").prop("checked", false);
        $("input[name^='ttz2_'").prop("checked", false);
        $("input[name^='ttz3_'").prop("checked", false);
        $("input[name^='ttz4_'").prop("checked", false);
        $("#tfzd_remark1").val("");

        /*
		document.all.tabfl5.style.display="none"	'FL5,FL6一案多件表格畫面
		Select case left(T1,3)
			Case "FL1","FL5"
				document.all.tg_FL1.style.display="none"
				document.all.tg_FL2.style.display="none"
				document.all.mark1.style.display=""
				document.all.mark2.style.display=""
				document.all.term.InnerHTML="柒、<u>授權期間："
				document.all.tg_term1.InnerHTML="授權期間"
				document.all.tg_term2.InnerHTML=""
				document.all.term1.colspan="3"
				document.all.term2.style.display=""
				document.all.td_tm1.rowspan="2"
				document.all.tr_claim1.style.display=""	'授權期間無迄日
				document.all.markA.InnerHTML="授權人(商標權人)"
				document.all.markB.InnerHTML=""
				document.all.span_FL.InnerHTML="貳、申請人(專用權人)"
				document.all.tg_type.InnerHTML="捌、授權性質"
				document.all.tg_area.InnerHTML="玖、授權區域"
				document.all.tg_good.InnerHTML="拾、<u>授權商品或服務："
				document.all.tr_type.style.display=""	'授權性質title
				document.all.tr_type1.style.display=""	'授權性質
				document.all.tr_area.style.display=""	'授權區域title
				document.all.tr_area1.style.display=""	'授權區域
				document.all.remark.style.display=""	
				document.all.remark1.style.display=""
				document.all.tg_attech.InnerHTML="<u>附件："
				document.all.oth_FL.InnerHtml="再授權案"
				document.all.O_item2(5).value="FL2"
				if left(T1,3)="FL5" then 
				   document.all.tabfl5.style.display=""
				   document.all.sp_titlecnt.innerhtml="授權"
				end if   
			Case "FL2","FL6"
				document.all.tg_FL1.style.display="none"	
				document.all.tg_FL2.style.display="none"
				document.all.mark1.style.display=""	'2012/7/1新申請書增加
				document.all.mark2.style.display=""	'2012/7/1新申請書增加
				document.all.markA.InnerHTML="授權人"
				document.all.markB.InnerHTML=""
				document.all.span_FL.InnerHTML="貳、申請人(授權人)"
				document.all.term.InnerHTML="柒、<u>再授權期間："
				document.all.tg_term1.InnerHTML="授權期間"
				document.all.tg_term2.InnerHTML=""
				document.all.term1.colspan="3"
				document.all.term2.style.display=""
				document.all.td_tm1.rowspan="2"
				document.all.tr_claim1.style.display=""	'授權期間無迄日
				document.all.tg_type.InnerHTML="捌、再授權性質"
				document.all.tg_area.InnerHTML="玖、再授權區域"
				document.all.tg_good.InnerHTML="拾、<u>再授權商品或服務："
				document.all.tr_type.style.display=""	'授權性質title
				document.all.tr_type1.style.display=""	'授權性質
				document.all.tr_area.style.display=""	'授權區域title
				document.all.tr_area1.style.display=""	'授權區域
				document.all.remark.style.display=""	
				document.all.remark1.style.display=""
				document.all.tg_attech.InnerHTML="<u>附件："
			    FL2_AP_Add_button_onclick
				document.all.oth_FL.InnerHtml="授權案"
				document.all.O_item2(5).value="FL1"
				if left(T1,3)="FL6" then 
					document.all.tabfl5.style.display=""
					document.all.sp_titlecnt.innerhtml="再授權"
				end if
			Case "FL3"	
				document.all.tg_FL1.style.display="none"	
				document.all.tg_FL2.style.display="none"
				document.all.mark1.style.display="none"
				document.all.mark2.style.display="none"
				document.all.markA.InnerHTML="授權人(商標權人)"
				document.all.markB.InnerHTML=""
				document.all.span_FL.InnerHTML="貳、申請人(商標權人)"
				document.all.term.InnerHTML="柒、<u>終止授權日期："
				document.all.tg_term1.InnerHTML="終止日期"
				document.all.tg_term2.InnerHTML="起廢止授權"
				document.all.term1.colspan="7"
				document.all.term2.style.display="none"
				document.all.td_tm1.rowspan="1"
				document.all.tr_claim1.style.display="none"	'授權期間無迄日
				document.all.tr_type.style.display="none"	'授權性質title
				document.all.tr_type1.style.display="none"	'授權性質
				document.all.tr_area.style.display="none"	'授權區域title
				document.all.tr_area1.style.display="none"	'授權區域
				document.all.remark.style.display="none"	
				document.all.remark1.style.display="none"	
				document.all.tg_attech.InnerHTML="<u>附件："
			Case "FL4"
				document.all.tg_FL1.style.display="none"	
				document.all.tg_FL2.style.display="none"
				document.all.mark1.style.display="none"
				document.all.mark2.style.display="none"
				document.all.markA.InnerHTML="授權人(係原再授權登記案之授權人)"
				document.all.markB.InnerHTML="(再授權使用人)"				
				document.all.span_FL.InnerHTML="參、申請人(授權人)"
				document.all.term.InnerHTML="柒、<u>廢止再授權日期："
				document.all.tg_term1.InnerHTML="終止日期"
				document.all.tg_term2.InnerHTML="起廢止再授權"
				document.all.term1.colspan="7"
				document.all.term2.style.display="none"
				document.all.td_tm1.rowspan="1"
				document.all.tr_claim1.style.display="none"	'授權期間無迄日
				document.all.tr_type.style.display="none"	'授權性質title
				document.all.tr_type1.style.display="none"	'授權性質
				document.all.tr_area.style.display="none"	'授權區域title
				document.all.tr_area1.style.display="none"	'授權區域
				document.all.remark.style.display="none"		
				document.all.remark1.style.display="none"		
				document.all.tg_attech.InnerHTML="<u>附件："
		end Select
	End Sub
        */

        //切換後重新綁資料
        br_form.bind();
    }

    //依案性切換要顯示的欄位
    br_form.changeTagA8 = function (T1) {
        var code3 = T1.Left(3).toUpperCase();//案性前3碼
        var arcase = T1;//案性
        var prt_code = $("#tfy_Arcase option:selected").attr("v1") || "";//載入form(code_br.prt_code)
        var pagt_no = $("#tfy_Arcase option:selected").attr("v2") || "";//案性預設出名代理人(code_br.remark)

        if (code3 == "FT1") {
            $("#tabft2").hide();
        } else if (code3 == "FT2") {
            $("#tabft2").show();
        }

        //切換後重新綁資料
        br_form.bind();
    }

    //依案性切換要顯示的欄位
    br_form.changeTagA9 = function (T1) {
        var code3 = T1.Left(3).toUpperCase();//案性前3碼
        var arcase = T1;//案性
        var prt_code = $("#tfy_Arcase option:selected").attr("v1") || "";//載入form(code_br.prt_code)
        var pagt_no = $("#tfy_Arcase option:selected").attr("v2") || "";//案性預設出名代理人(code_br.remark)

        if (code3 == "FP1") {
            $("#smark1,#smark2,#smark3").hide();
            $("#tabrem1").show();
            $("#tabrem2").hide();
            $("#tfzd_remark1").val("");
        } else if (code3 == "FP2") {
            $("#smark1,#smark2,#smark3").hide();
            $("#tabrem1").hide();
            $("#tabrem2").show();
            $("#tfzd_remark1").val("");
        }

        //切換後重新綁資料
        br_form.bind();
    }

    //依案性切換要顯示的欄位
    br_form.changeTagAA = function (T1) {
        //切換後重新綁資料
        br_form.bind();
    }

    //依案性切換要顯示的欄位
    br_form.changeTagAB = function (T1) {
        //切換後重新綁資料
        br_form.bind();
    }

    //依案性切換要顯示的欄位
    br_form.changeTagAB = function (T1) {
        //切換後重新綁資料
        br_form.bind();
    }

    //依案性切換要顯示的欄位
    br_form.changeTagAC = function (T1) {
        //切換後重新綁資料
        br_form.bind();
    }

    //依案性切換要顯示的欄位
    br_form.changeTagB = function (T1) {
        var d_agt_no1="";
        switch (main.branch) {
            case 'N':d_agt_no1="034";break;
            case 'C':d_agt_no1="027";break;
            case 'S':d_agt_no1="006";break;
            case 'K':d_agt_no1="006";break;
        }

        var code3 = T1.Left(3).toUpperCase();//案性前3碼
        var arcase = T1;//案性
        var prt_code = $("#tfy_Arcase option:selected").attr("v1") || "";//載入form(code_br.prt_code)
        var pagt_no = $("#tfy_Arcase option:selected").attr("v2") || "";//案性預設出名代理人(code_br.remark)

        //動態載入form
        if (prt_code == "DO1" || prt_code == "DR1" || prt_code == "DI1" || prt_code == "B5C1") {
            $("#load_form").load($("#div_" + prt_code).text());//動態載入form
        } else {
            $("#load_form").load($("#div_BZZ1").text());
        }

        //有案性預設出名代理人
        if (pagt_no != "") {
            $("#tfp4_agt_no").val(pagt_no);
        } else {
            $("#tfp4_agt_no").val(d_agt_no1);
        }

        //聽證B5C1控制
        if (code3 == "AD7"||code3 == "DE1") {
            $("#tr_remark3,#tr_tran_mark,#tr_de1_ap").show();
            $("#tr_de2_item,#tr_de2_item1").hide();
            $("#span_dmttemp_mark").html("評定案件或異議案件或廢止案件之<input type=radio name=fr4_Mark value='A'>申請人<input type=radio name=fr4_Mark value='I'>註冊人");
            $("#span_case").html("舉行");
            $("#span_case1").html("肆、對造當事人");
            $("#span_other_item2").html("代 理 人");
            $("#span_tran_remark1").html("<strong>伍、應舉行聽證之理由：</strong><font size='-2'>（請羅列聽證爭點要旨，逐項敘明理由，並檢附正副本各一份）</font>");
        } else if (code3 == "AD8"||code3 == "DE2") {
            $("#tr_remark3,#tr_de2_item,#tr_de2_item1").show();
            $("#tr_tran_mark,#tr_de1_ap").hide();
            $("#span_dmttemp_mark").html("<input type=radio name=fr4_Mark value='B'>爭議案申請人或異議人<input type=radio name=fr4_Mark value='I'>系爭商標商標權人<input type=radio name=fr4_Mark value='R'>利害關係人");
            $("#span_case").html("出席");
            $("#span_case1").html("參、出席代表姓名或代理姓名");
            $("#span_other_item").html("指定發言姓名");
            $("#span_other_item1").html("職　　稱");
            $("#span_other_item2").html("聯絡電話");
            $("#span_tran_remark1").html("<strong>附註：新事證及陳述意見書</strong>");
        }

        //切換後重新綁資料
        br_form.bind();
    }

    br_form.changeTagZZ = function (T1) {
        var code3 = T1.Left(3).toUpperCase();//案性前3碼
        var arcase = T1;//案性
        var prt_code = $("#tfy_Arcase option:selected").attr("v1")||"";//載入form(code_br.prt_code)
        var pagt_no = $("#tfy_Arcase option:selected").attr("v2") || "";//案性預設出名代理人(code_br.remark)

        //動態載入form
        if (prt_code == "FOB" || prt_code == "FOF" || prt_code == "FB7" || prt_code == "B5C1") {
            $("#load_form").load($("#div_" + prt_code).text());//動態載入form
        } else {
            $("#load_form").load($("#div_ZZ").text());
        }

        //預設代理人
        if ($("#d_agt_no1").val()==""){
            //2015/10/21改抓cust_code
            $("#d_agt_no1").val(get_tagtno("N"))
        }

        //有案性預設出名代理人
        if (pagt_no!=""){
            $("#tfg1_agt_no1").val(pagt_no);
            $("#tfp4_agt_no").val(pagt_no);
        }else{
            $("#tfg1_agt_no1").val($("#d_agt_no1").val());
            $("#tfp4_agt_no").val($("#d_agt_no1").val());
        }

        //申請撤回畫面控制
        if (arcase=="FW1"){
            $("#tr_zz").hide();
            $("#tr_fw1").show();
        }else{
            $("#tr_zz").show();
            $("#tr_fw1").hide();
        }

        //聽證B5C1控制
        if (code3 == "AD7") {
            $("#tr_remark3,#tr_tran_mark,#tr_de1_ap").show();
            $("#tr_de2_item,#tr_de2_item1").hide();
            $("#span_dmttemp_mark").html("評定案件或異議案件或廢止案件之<input type=radio name=fr4_Mark value='A'>申請人<input type=radio name=fr4_Mark value='I'>註冊人");
            $("#span_case").html("舉行");
            $("#span_case1").html("肆、對造當事人");
            $("#span_other_item2").html("代 理 人");
            $("#span_tran_remark1").html("<strong>伍、應舉行聽證之理由：</strong><font size='-2'>（請羅列聽證爭點要旨，逐項敘明理由，並檢附正副本各一份）</font>");
        } else if (code3 == "AD8") {
            $("#tr_remark3,#tr_de2_item,#tr_de2_item1").show();
            $("#tr_tran_mark,#tr_de1_ap").hide();
            $("#span_dmttemp_mark").html("<input type=radio name=fr4_Mark value='B'>爭議案申請人或異議人<input type=radio name=fr4_Mark value='I'>系爭商標商標權人<input type=radio name=fr4_Mark value='R'>利害關係人");
            $("#span_case").html("出席");
            $("#span_case1").html("參、出席代表姓名或代理姓名");
            $("#span_other_item").html("指定發言姓名");
            $("#span_other_item1").html("職　　稱");
            $("#span_other_item2").html("聯絡電話");
            $("#span_tran_remark1").html("<strong>附註：新事證及陳述意見書</strong>");
        }

        //影印內容
        $("input[name^='ttz1_P'").prop("checked", false);
        $("[id^='P'][id$='_new_no']").val("");
        $("[id^='P'][id$='_mod_dclass']").val("");
        $("input[name='fr_mark']").prop("checked", false);//程序種類

        //切換後重新綁資料
        br_form.bind();
    }
</script>