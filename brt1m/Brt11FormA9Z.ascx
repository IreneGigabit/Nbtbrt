<%@ Control Language="C#" ClassName="Brt11FormA9Z" %>
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
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FC11Form.ascx"));//變更
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FC2Form.ascx"));//變更
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FC21Form.ascx"));//變更
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FC3Form.ascx"));//變更
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FC4Form.ascx"));//變更
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
    br_form.bind = function () {
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
            for (var nRow = num; nRow < doCount ; nRow++) {
                var copyStr = $(template).text() || "";
                copyStr = copyStr.replace(/##/g, nRow + 1);
                $(appendTar).append(copyStr);
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
<!--div id="load_form"></div-->
<asp:PlaceHolder ID="tranHolder" runat="server"></asp:PlaceHolder><!--交辦內容.依ar_form動態載入form-->
<uc1:A9Z_end runat="server" ID="A9Z_end" />
<!--include file="../brt1m/CaseForm/A9Z_end.ascx"--><!--結案復案資料-->


<script language="javascript" type="text/javascript">
    //依案性切換要顯示的欄位
    br_form.changeTag = function (T1) {
        var code3 = T1.Left(3).toUpperCase();//案性前3碼
        var arcase = T1;//案性
        var prt_code = $("#tfy_Arcase option:selected").attr("v1") || "";//載入form(code_br.prt_code)
        var pagt_no = $("#tfy_Arcase option:selected").attr("v2") || "";//案性預設出名代理人(code_br.remark)

        $("[id^='div_Form_'").hide();//隱藏所有交辦form
        //console.log(code3, arcase, prt_code, pagt_no);
        //依ar_form執行對應的function
        switch (main.ar_form) {
            case "A3": case "A4": case "A5": case "A6": case "A7": case "A8": case "A9": case "AA": case "AB": case "AC": case "B":
                eval("br_form.changeTag" + main.ar_form + "('" + T1 + "','" + code3 + "','" + arcase + "','" + prt_code + "','" + pagt_no + "')");
                break;
            default:
                br_form.changeTagZZ(T1, code3, arcase, prt_code, pagt_no);
                break;
        }

        //切換後重新綁資料
        br_form.bind();
    }

    //依案性切換要顯示的欄位
    br_form.changeTagA3 = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FF").show();
        br_form.bind = br_form.bindFF;
        switch (code3) {
            case "FF0": case "FF4":
                $("#smark2,#smark").hide();
                $("#tabrem4").hide();//2015/1/30修改FF4商標復權申請之附件選項
                if (code3 == "FF0") {
                    $("#span_issue_money").html("自審定書送達之次日起2個月內，應繳納");
                } else {
                    $("#span_issue_money").html("自審定書送達之次日起2個月期限屆期後6個月內，應繳納2倍");
                    $("#tabrem4").show();
                }
                $("#no1,no2").show();
                $("#no3,no4").hide();
                break;
            case "FF1":
                $("#smark2,#smark").hide();
                $("#tabrem4").hide();//2015/1/30修改FF4商標復權申請之附件選項
                $("#span_issue_money").html("第一期(第一至第三年)");
                $("#no1,no2").show();
                $("#no3,no4").hide();
                break;
            case "FF2":
                $("#smark2,#smark").show();
                $("#tabrem4").hide();//2015/1/30修改FF4商標復權申請之附件選項
                $("#span_issue_money").html("第二期(第四至第十年)");
                $("#no1,no2").hide();
                $("#no3,no4").show();
                break;
            case "FF3":
                $("#smark2,#smark").show();
                $("#tabrem4").hide();//2015/1/30修改FF4商標復權申請之附件選項
                $("#span_issue_money").html("第一加倍繳納第二期(第四至第十年)");
                $("#no1,no2").hide();
                $("#no3,no4").show();
                break;
        }
    }

    br_form.changeTagA4 = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FR").show();
        br_form.bind = br_form.bindFR;
    }

    //依案性切換要顯示的欄位
    br_form.changeTagA5 = function (T1, code3, arcase, prt_code, pagt_no) {
        switch (code3) {
            case "FD1":
                $("#div_Form_FD2").show();
                br_form.bind = br_form.bindFD2;
                $("#smark").hide();
                $("#fr_smark1,#fr_smark3").show();
                $("#fr_smark2").hide();
                break;
            case "FD2": case "FD3":
                $("#div_Form_FD1").show();
                br_form.bind = br_form.bindFD1;
                $("#smark").show();
                $("#fr_smark1,#fr_smark3").show();
                $("#fr_smark2").hide();
                break;
        }
        $('#tfy_case_stat option:eq(1)').val("").text("");//案件種類
    }

    //依案性切換要顯示的欄位
    br_form.changeTagA6 = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#tabap,#FC0_tabap,#FC1_tabap").hide();
        $("#CTab td.tab[href='#apcust']").html("案件申請人(變更)");

        switch (arcase) {
            case "FC1": case "FC10": case "FC9": case "FCA": case "FCB": case "FCF":
                $("#FC1_tabap,#div_Form_FC1").show();
                br_form.bind = br_form.bindFC1;
                $("#smark").hide();
                if (arcase == "FCA") {
                    $("#FC1_tr_addagtno").show();//新增代理人
                } else {
                    $("#FC1_tr_addagtno").hide();
                }
                break;
            case "FC11": case "FC15": case "FC7": case "FCH":
                $("#FC1_tabap,#div_Form_FC11").show();
                br_form.bind = br_form.bindFC11;
                $("#smark").hide();
                $("#dseqa_1").lock().val("");
                $("#dseq1a_1").lock().val("_");
                $("#btndseq_oka_1,#btncasea_1").hide();
                $("#s_marka_1").val("");
                $("#appl_namea_1,#apply_noa_1").val("");
                $("#case_stat1a_1NN").prop("checked", true);
                break;
            case "FC2": case "FC20": case "FC0": case "FCC": case "FCD": case "FCG":
                $("#FC0_tabap,#div_Form_FC2").show();
                br_form.bind = br_form.bindFC2;
                $("#smark").hide();
                $("#tabbr2").show();
                if (arcase == "FCC") {
                    $("#FC2_tr_addagtno").show();//新增代理人
                } else {
                    $("#FC2_tr_addagtno").hide();
                }
                break;
            case "FC21": case "FC6": case "FC8": case "FCI":
                $("#FC0_tabap,#div_Form_FC21").show();
                br_form.bind = br_form.bindFC21;
                $("#smark").show();
                $("#dseqb_1").lock().val("");
                $("#dseq1b_1").lock().val("_");
                $("#btndseq_okb_1,#btncaseb_1").hide();
                $("#s_markb_1").val("");
                $("#appl_nameb_1,#issue_nob_1").val("");
                $("#case_stat1b_1NN").prop("checked", true);
                break;
            case "FC3":
                $("#tabap,#div_Form_FC3").show();
                br_form.bind = br_form.bindFC3;
                $("#CTab td.tab[href='#apcust']").html("案件申請人");
                $("#span_FC").html("貳、申請人");
                $("#smark").show();
                break;
            case "FC4":
                $("#tabap,#div_Form_FC4").show();
                br_form.bind = br_form.bindFC4;
                $("#span_FC").html("參、申請人(填寫變更後之正確資料)");
                $("#smark").show();
                break;
        }
        if (arcase == "FC11" || arcase == "FC21" || arcase == "FC5" || arcase == "FC6" || arcase == "FC7" || arcase == "FC8" || arcase == "FCH" || arcase == "FCI") {
            $('#tfy_case_stat option:eq(1)').val("").text("");//案件種類
        } else {
            $('#tfy_case_stat option:eq(1)').val("SN").text("新案(指定編號)");//案件種類
        }
    }

    //依案性切換要顯示的欄位
    br_form.changeTagA7 = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FL1").show();
        br_form.bind = br_form.bindFL1;
        $("[id^='tabrem']").hide();
        var tabid = arcase.substr(2, 1);
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

        $("#tabfl5").hide();//FL5,FL6一案多件表格畫面
        switch (code3) {
            case "FL1": case "FL5":
                $("#tg_FL1,#tg_FL2").hide();
                $("#mark1,#mark2").show();//2012/7/1新申請書增加
                $("#term").html("柒、<u>授權期間：</u>");
                $("#tg_term1").html("授權期間");
                $("#tg_term2").html("");
                $("#term1").attr("colspan", 3);
                $("#term2").show();
                $("#td_tm1").attr("rowspan", 2);
                $("#tr_claim1").show();//授權期間無迄日
                $("#markA").html("授權人(商標權人)");
                $("#markB").html("");
                $("#tg_type").html("捌、授權性質");
                $("#tg_area").html("玖、授權區域");
                $("#tg_good").html("拾、<u>授權商品或服務：</u>");
                //授權性質/授權區域/授權商品或服務
                $("#tr_type,#tr_type1,#tr_area,#tr_area1,#remark,#remark1").show();
                $("#tg_attech").html("<u>附件：</u>");
                $("#oth_FL").html("再授權案");
                $("#O_item2FL2").val("FL2");
                if (code3 == "FL5") {
                    $("#tabfl5").show();
                    $("#sp_titlecnt").html("授權");
                }
                break;
            case "FL2": case "FL6":
                $("#tg_FL1,#tg_FL2").hide();
                $("#mark1,#mark2").show();//2012/7/1新申請書增加
                $("#term").html("柒、<u>再授權期間：</u>");
                $("#tg_term1").html("授權期間");
                $("#tg_term2").html("");
                $("#term1").attr("colspan", 3);
                $("#term2").show();
                $("#td_tm1").attr("rowspan", 2);
                $("#tr_claim1").show();//授權期間無迄日
                $("#markA").html("授權人");
                $("#markB").html("");
                $("#tg_type").html("捌、再授權性質");
                $("#tg_area").html("玖、再授權區域");
                $("#tg_good").html("拾、<u>再授權商品或服務：</u>");
                //授權性質/授權區域/授權商品或服務
                $("#tr_type,#tr_type1,#tr_area,#tr_area1,#remark,#remark1").show();
                $("#tg_attech").html("<u>附件：</u>");
                //FL2_AP_Add_button_onclick
                $("#oth_FL").html("授權案");
                $("#O_item2FL2").val("FL1");
                if (code3 == "FL6") {
                    $("#tabfl5").show();
                    $("#sp_titlecnt").html("再授權");
                }
                break;
            case "FL3":
                $("#tg_FL1,#tg_FL2").hide();
                $("#mark1,#mark2").hide();
                $("#term").html("柒、<u>終止授權日期：</u>");
                $("#tg_term1").html("終止日期");
                $("#tg_term2").html("起廢止授權");
                $("#term1").attr("colspan", 7);
                $("#term2").hide();
                $("#td_tm1").attr("rowspan", 1);
                $("#tr_claim1").hide();//授權期間無迄日
                $("#markA").html("授權人(商標權人)");
                $("#markB").html("");
                //授權性質/授權區域/授權商品或服務
                $("#tr_type,#tr_type1,#tr_area,#tr_area1,#remark,#remark1").hide();
                $("#tg_attech").html("<u>附件：</u>");
                break;
            case "FL4":
                $("#tg_FL1,#tg_FL2").hide();
                $("#mark1,#mark2").hide();
                $("#term").html("柒、<u>廢止再授權日期：</u>");
                $("#tg_term1").html("終止日期");
                $("#tg_term2").html("起廢止再授權");
                $("#term1").attr("colspan", 7);
                $("#term2").hide();
                $("#td_tm1").attr("rowspan", 1);
                $("#tr_claim1").hide();//授權期間無迄日
                $("#markA").html("授權人(係原再授權登記案之授權人)");
                $("#markB").html("(再授權使用人)");
                //授權性質/授權區域/授權商品或服務
                $("#tr_type,#tr_type1,#tr_area,#tr_area1,#remark,#remark1").hide();
                $("#tg_attech").html("<u>附件：</u>");
                break;
        }
    }

    //依案性切換要顯示的欄位
    br_form.changeTagA8 = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FT1").show();
        br_form.bind = br_form.bindFT1;
        if (code3 == "FT1") {
            $("#tabft2").hide();
        } else if (code3 == "FT2") {
            $("#tabft2").show();
        }
    }

    //依案性切換要顯示的欄位
    br_form.changeTagA9 = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FP1").show();
        br_form.bind = br_form.bindFP1;
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
    }

    //依案性切換要顯示的欄位
    br_form.changeTagAA = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FN1").show();
        br_form.bind = br_form.bindFN1;
    }

    //依案性切換要顯示的欄位
    br_form.changeTagAB = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FI1").show();
        br_form.bind = br_form.bindFI1;
    }

    //依案性切換要顯示的欄位
    br_form.changeTagAC = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FV1").show();
        br_form.bind = br_form.bindFV1;
    }

    //依案性切換要顯示的欄位
    br_form.changeTagB = function (T1, code3, arcase, prt_code, pagt_no) {
        //動態載入form
        if (prt_code == "DO1") {
            $("#div_Form_DO1").show();
            br_form.bind = br_form.bindDO1;
        } else if (prt_code == "DR1") {
            $("#div_Form_DR1").show();
            br_form.bind = br_form.bindDR1;
        } else if (prt_code == "DI1") {
            $("#div_Form_DI1").show();
            br_form.bind = br_form.bindDI1;
        } else if (prt_code == "B5C1") {
            $("#div_Form_B5C1").show();
            br_form.bind = br_form.bindB5C1;
        } else {
            $("#div_Form_BZZ1").show();
            br_form.bind = br_form.bindBZZ1;
        }

        var d_agt_no1 = "";
        switch (main.branch) {
            case 'N': d_agt_no1 = "034"; break;
            case 'C': d_agt_no1 = "027"; break;
            case 'S': d_agt_no1 = "006"; break;
            case 'K': d_agt_no1 = "006"; break;
        }

        //有案性預設出名代理人
        if (pagt_no != "") {
            $("#tfp4_agt_no").val(pagt_no);
        } else {
            $("#tfp4_agt_no").val(d_agt_no1);
        }

        //聽證B5C1控制
        if (code3 == "AD7" || code3 == "DE1") {
            $("#tr_remark3,#tr_tran_mark,#tr_de1_ap").show();
            $("#tr_de2_item,#tr_de2_item1").hide();
            $("#span_dmttemp_mark").html("評定案件或異議案件或廢止案件之<input type=radio name=fr4_Mark value='A'>申請人<input type=radio name=fr4_Mark value='I'>註冊人");
            $("#span_case").html("舉行");
            $("#span_case1").html("肆、對造當事人");
            $("#span_other_item2").html("代 理 人");
            $("#span_tran_remark1").html("<strong>伍、應舉行聽證之理由：</strong><font size='-2'>（請羅列聽證爭點要旨，逐項敘明理由，並檢附正副本各一份）</font>");
        } else if (code3 == "AD8" || code3 == "DE2") {
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
    }

    br_form.changeTagZZ = function (T1, code3, arcase, prt_code, pagt_no) {
        //動態載入form
        if (prt_code == "FOB" || prt_code == "FOF" || prt_code == "FB7" || prt_code == "B5C1") {
            $("#div_Form_" + prt_code).show();
            eval("br_form.bind = br_form.bind" + prt_code);
        } else {
            $("#div_Form_ZZ1").show();
            br_form.bind = br_form.bindZZ1;
        }

        //預設代理人
        if ($("#d_agt_no1").val() == "") {
            //2015/10/21改抓cust_code
            $("#d_agt_no1").val(get_tagtno("N"))
        }

        //有案性預設出名代理人
        if (pagt_no != "") {
            $("#tfg1_agt_no1").val(pagt_no);
            $("#tfp4_agt_no").val(pagt_no);
        } else {
            $("#tfg1_agt_no1").val($("#d_agt_no1").val());
            $("#tfp4_agt_no").val($("#d_agt_no1").val());
        }

        //申請撤回畫面控制
        if (arcase == "FW1") {
            $("#tr_zz").hide();
            $("#tr_fw1").show();
        } else {
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
    }
    /*
    br_form.changeTag = function (T1) {
        var code3 = T1.Left(3).toUpperCase();//案性前3碼
        var arcase = T1;//案性
        var prt_code = $("#tfy_Arcase option:selected").attr("v1") || "";//載入form(code_br.prt_code)
        var pagt_no = $("#tfy_Arcase option:selected").attr("v2") || "";//案性預設出名代理人(code_br.remark)

        $("[id^='div_Form_'").hide();
        if (main.ar_form == "A3") {//註冊費
            $("#div_Form_FF").show();
        } else if (main.ar_form == "A4") {//延展
            $("#div_Form_FR").show();
        } else if (main.ar_form == "A5") {//分割
            switch (code3) {
                case "FD2": case "FD3":
                    $("#div_Form_FD2").show();
                    br_form.bind = br_form.bindFD2;
                    $("#smark").show();
                    $("#fr_smark1,#fr_smark3").show();
                    $("#fr_smark2").hide();
                    break;
                default:
                    $("#div_Form_FD1").show();
                    br_form.bind = br_form.bindFD1;
                    $("#smark").hide();
                    $("#fr_smark1,#fr_smark3").show();
                    $("#fr_smark2").hide();
                    break;
            }
            $('#tfy_case_stat option:eq(1)').val("").text("");//案件種類
        } else if (main.ar_form == "A6") {//變更
            $("#tabap,#FC0_tabap,#FC1_tabap").hide();
            $("#CTab td.tab[href='#apcust']").html("案件申請人(變更)");
            switch (arcase) {
                case "FC1": case "FC10": case "FC9": case "FCA": case "FCB": case "FCF":
                    $("#FC1_tabap,#div_Form_FC1").show();
                    br_form.bind = br_form.bindFC1;
                    $("#smark").hide();
                    if (arcase == "FCA") {
                        $("#FC1_tr_addagtno").show();//新增代理人
                    } else {
                        $("#FC1_tr_addagtno").hide();
                    }
                    break;
                case "FC11": case "FC5": case "FC7": case "FCH":
                    $("#FC1_tabap,#div_Form_FC11").show();
                    br_form.bind = br_form.bindFC11;
                    $("#smark").hide();
                    $("#dseqa_1").lock().val("");
                    $("#dseq1a_1").lock().val("_");
                    $("#btndseq_oka_1,#btncasea_1").hide();
                    $("#s_marka_1").val("");
                    $("#appl_namea_1,#apply_noa_1").val("");
                    $("#case_stat1a_1NN").prop("checked", true);
                    break;
                case "FC2": case "FC20": case "FC0": case "FCC": case "FCD": case "FCG":
                    $("#FC0_tabap,#div_Form_FC2").show();
                    br_form.bind = br_form.bindFC2;
                    $("#smark").hide();
                    $("#tabbr2").show();
                    if (arcase == "FCC") {
                        $("#FC2_tr_addagtno").show();//新增代理人
                    } else {
                        $("#FC2_tr_addagtno").hide();
                    }
                    break;
                case "FC21": case "FC6": case "FC8": case "FCI":
                    $("#FC0_tabap,#div_Form_FC21").show();
                    br_form.bind = br_form.bindFC21;
                    $("#smark").show();
                    $("#dseqb_1").lock().val("");
                    $("#dseq1b_1").lock().val("_");
                    $("#btndseq_okb_1,#btncaseb_1").hide();
                    $("#s_markb_1").val("");
                    $("#appl_nameb_1,#issue_nob_1").val("");
                    $("#case_stat1b_1NN").prop("checked", true);
                    break;
                case "FC3":
                    $("#tabap,#div_Form_FC3").show();
                    br_form.bind = br_form.bindFC3;
                    $("#CTab td.tab[href='#apcust']").html("案件申請人");
                    $("#span_FC").html("貳、申請人");
                    $("#smark").show();
                    break;
                case "FC4":
                    $("#tabap,#div_Form_FC4").show();
                    br_form.bind = br_form.bindFC4;
                    $("#span_FC").html("參、申請人(填寫變更後之正確資料)");
                    $("#smark").show();
                    break;
            }
            if (arcase == "FC11" || arcase == "FC21" || arcase == "FC5" || arcase == "FC6" || arcase == "FC7" || arcase == "FC8" || arcase == "FCH" || arcase == "FCI") {
                $('#tfy_case_stat option:eq(1)').val("").text("");//案件種類
            } else {
                $('#tfy_case_stat option:eq(1)').val("SN").text("新案(指定編號)");//案件種類
            }
        }

        //切換後重新綁資料
        br_form.bind();
    }*/
</script>