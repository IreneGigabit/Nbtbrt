<%@ Control Language="C#" ClassName="imp82Form" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Web.Script.Serialization" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>






<script runat="server">

    /// <summary>
    /// 報導承辦資料_共用表格
    /// </summary>

    //共用參數
    protected string prgid = HttpContext.Current.Request["prgid"];

    //畫面共用HTML
    //protected string html_work_team = "";//報導承辦組別
    //protected string html_work_scode = "";//報導承辦組別的人員

    //protected string html_signer = "";//簽名人

    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        QueryPageLayout();

    }


    private void QueryPageLayout()
    {

        //取得下拉選單HTML
        ////報導承辦組別
        //html_work_team = HtmlData.get_tf_work_Team("", "").GetOption("", "_", true);

        ////報導承辦組別的人員
        //html_work_scode = HtmlData.get_tf_work_scode("", "").GetOptionWithParent("", "_", true);

        ////簽名人
        //html_signer = HtmlData.get_signer().GetOption("", "", true);

        //取得下拉選單HTML end

    }
</script>

<table id="tfsend_imt_Table" width="100%" class="bluetable" border="0" cellspacing="1" cellpadding="2">
    <tr>
        <td class="lightbluetable" align="right">電文序號：</td>

        <td class="whitetablebg">
            <input class="auto-style1" name="tfsend_no" readonly size="11" value="2017060001" />
        </td>

        <td class="lightbluetable" align="right">進度序號：</td>

        <td class="whitetablebg">
            <input class="sedit" name="step_grade" readonly size="6" value="727" />
            <input name="rs_sqlno" type="hidden" />
            &nbsp;&nbsp;&nbsp;
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">作業日期：</td>

        <td class="whitetablebg">
            <input type="text" id="work_date" name="work_date" class="dateField" size="11" maxlength="10" value="2020/11/16">
        </td>

        <td class="lightbluetable" align="right">工作序號：</td>

        <td class="whitetablebg">
            <input class="sedit" name="job_sqlno" readonly size="6" value="" />
            <input name="job_comc_tot" type="hidden" value="1" />
            <input name="refc_job_sqlno" type="hidden" />
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">案件編號：</td>

        <td class="whitetablebg">
            <input class="sedit" name="seq" readonly size="6" value="709" />
            -<input class="sedit" name="seq1" readonly size="1" value="Z" />
            <input class="sedit" name="country" readonly size="2" value="AM" />
            <input id="seqbutton" class="cbutton" name="seqbutton" onclick="vbscript:seqbutton_onclick1" type="button" value="確定" width="21" />
            <input class="cbutton" name="btnseq" type="button" value="詳細" />
            <input disabled name="tfext_flag" type="checkbox" value="Y" />轉口案 （轉口案申請國別： 
            <input class="sedit" name="ext_country" readonly size="2" />） 
            <input name="keyinseq" type="hidden" value="Y" />
            <input name="oldseq" type="hidden" value="709" />
            <input name="oldseq1" type="hidden" value="Z" />
            <input name="ext_flag" type="hidden" value="N" />
            <input name="comC_seq" type="hidden" />
            <input name="comctot_flag" type="hidden" value="N" />
            <input name="combtot_flag" type="hidden" value="N" />
        </td>

        <td class="lightbluetable" align="right">專利種類：</td>

        <td class="whitetablebg">
            <input class="sedit" name="case_typenm" readonly size="10" value="新型" />
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">案件名稱：</td>

        <td class="whitetablebg" colspan="3">
            <input class="sedit" readonly size="80" value="支援北專MOLEX INCORPORATED請款專卷" name="eappl_name"></td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">對方號：</td>

        <td class="whitetablebg">
            <input class="sedit" readonly value="目前使用第11卷" name="your_no">
        </td>

        <td class="lightbluetable" align="right">証書號：</td>

        <td class="whitetablebg">
            <input class="sedit" name="issue_no2" readonly value="206366" />
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">申請號：</td>

        <td class="whitetablebg">
            <input class="sedit" name="apply_no" readonly value="91207628" />
        </td>

        <td class="lightbluetable" align="right">改請號：</td>

        <td class="whitetablebg">
            <input class="sedit" name="issue_no1" readonly value="" />
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">掃描文件：</td>

        <td class="whitetablebg" colspan="3">
            <input disabled name="pr_scan1" onclick="vbs:Send_pr_scan_onclick" type="radio" value="V1" />無 
            <input disabled name="pr_scan" onclick="vbs:Send_pr_scan_onclick" type="radio" value="V1" />有 ，共&nbsp;<input name="pr_scan_page" size="4" />&nbsp;頁 &nbsp;&nbsp;&nbsp;說明：<input name="pr_scan_remark" size="50" />
            <input name="pr_scan_path" type="hidden" />
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">申請人：</td>

        <td class="whitetablebg" colspan="3">
            <input id="apcustnm" class="sedit" name="apcustnm" readonly value="MOLEX INCORPORATED" />
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">案件代理人：</td>

        <td class="whitetablebg" colspan="3">
            <input maxlength="5" name="seqagent_no" size="5" value="D515" />-
            <input maxlength="1" name="seqagent_no1" size="1" value="_" />
            <input id="seqagent_nobutton" class="cbutton" name="seqagent_nobutton" onclick="vbscript:seqagent_no_onclick1 'seq'" type="button" value="確定" width="21" />
            <input class="cbutton" name="btnseqAgent" type="button" value="詳細" />
            <input class="sedit" name="seqagent_nonm" readonly size="60" value="MOLEX, LLC" />
            <input name="keyseqagent_no" type="hidden" value="Y" />
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">代理人地址：</td>

        <td class="whitetablebg" colspan="3">
            <input class="sedit" maxlength="40" name="addr1" readonly size="40" value="2222 WELLINGTON COURT," /><br />
            <input class="sedit" maxlength="40" name="addr2" readonly size="40" value="LISLE, IL 60532-1682" /><br />
            <input class="sedit" maxlength="40" name="addr3" readonly size="40" value="U. S. A." /><br />
            <input class="sedit" maxlength="40" name="addr4" readonly size="40" />
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">郵寄代理人：</td>

        <td class="whitetablebg" colspan="3">
            <input maxlength="5" name="sendagent_no" size="5" value="D515" />-
            <input maxlength="1" name="sendagent_no1" size="1" value="_" />
            <input id="sendagent_nobutton" class="cbutton" name="sendagent_nobutton" onclick="vbscript:seqagent_no_onclick1 'send'" type="button" value="確定" width="21" />
            <input class="cbutton" name="btnsendAgent" type="button" value="詳細" />
            <input class="sedit" name="sendagent_nonm" readonly size="60" value="MOLEX, LLC" />
            <input name="keysendagent_no" type="hidden" value="Y" />
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">郵寄地址：</td>

        <td class="whitetablebg">
            <input maxlength="40" name="sendaddr1" onblur="vbscript:fChkDataLen me,'郵寄地址1'" size="40" value="2222 WELLINGTON COURT," /><br />
            <input maxlength="40" name="sendaddr2" onblur="vbscript:fChkDataLen me,'郵寄地址2'" size="40" value="LISLE, IL 60532-1682" /><br />
            <input maxlength="40" name="sendaddr3" onblur="vbscript:fChkDataLen me,'郵寄地址3'" size="40" value="U. S. A." /><br />
            <input maxlength="40" name="sendaddr4" onblur="vbscript:fChkDataLen me,'郵寄地址4'" size="40" />
        </td>

        <td align="right" class="whitetablebg">請款單號：<br />
            請款金額：</td>

        <td class="whitetablebg">
            <input class="sedit" maxlength="10" name="ar_no" readonly size="10" />
            <br />
            NT$<input class="sedit" maxlength="10" name="ar_amt" readonly size="10" />
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">Attention：</td>

        <td class="whitetablebg" colspan="3">
            <input class="sedit" maxlength="80" name="attention" onblur="vbscript:fChkDataLen me,'Attention'" readonly size="80" />
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">RE：</td>

        <td class="whitetablebg" colspan="3">
            <input maxlength="100" name="re0" onblur="vbscript:fChkDataLen me,'RE'" size="80" value="Taiwan (R.O.C.) U.M. Patent No. 206366" />
            <span id="span_getdb_no">
                <br />
                <font onclick="vbs:qrydebit" style="cursor: pointer; color: darkblue">[抓取請款單主旨] </font></span>
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">發文對象(Dear)：</td>

        <td class="whitetablebg" colspan="3">
            <select disabled name="sendatt" onchange="vbscript:sendatt_onchange" size="1" value="0">
                <option selected="" value="">請選擇</option>
                <option value="1">Robert J. Zeitler</option>
                <option value="2">THOMAS D. PAULIUS</option>
                <option value="3">AGATHA MOREY</option>
                <option value="5">KERRI RICHARDSON</option>
                <option value="6">Ms. Jennifer Beedles</option>
                <option value="7">Erika Avitia</option>
                <option value="8">Timothy M. Morella</option>
                <option value="9">Diantha Lewis</option>
                <option value="10">Stephen L. Sheldon</option>
                <option value="11">Denise Ellison</option>
                <option value="12"></option>
                <option value="13"></option>
                <option value="14"></option>
                <option value="15"></option>
                <option value="4">Stephen Z. Weiss (離職)(離職)</option>
            </select>&nbsp;&nbsp;
            <input checked name="sendattdear" type="checkbox" value="" />Sirs &nbsp;&nbsp;
            <input maxlength="50" name="sendattdesc" onblur="vbscript:fChkDataLen me,'發文對象(Dear)'" size="50" value="Sirs" />
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">電文代碼：</td>

        <td class="whitetablebg" colspan="3">
            <select name="tf_code" size="1">
                <option style="color: blue" value="">請選擇</option>
                <option value="A01">A01_申請權准予讓渡</option>
                <option value="A02">A02_專利權准予讓渡</option>
                <option value="A03">A03_准予變更公司名稱</option>
                <option value="A04">A04_准予專利權授權登記</option>
                <option value="A05">A05_准予變更公司名稱-申請權</option>
                <option value="ADVA">ADVA_ADVANTEST通知信</option>
                <option value="APP">APP_訴願成立</option>
                <option value="B01">B01_催讓渡書(不可延)</option>
                <option value="B02">B02_催正式圖</option>
                <option value="B03">B03_催新式樣圖式</option>
                <option value="B07">B07_催各文(不可延)</option>
                <option value="B08">B08_催各文(可延)</option>
                <option value="B09">B09_通知期限(不可延)</option>
                <option value="B10">B10_催各文(不可延)-2</option>
                <option value="B11">B11_催各文－已有收據 (8天)</option>
                <option selected="" value="BLANK">BLANK_空白報導</option>
                <option value="CLOS1">CLOS1_專利權期滿</option>
                <option value="CLOSE">CLOSE_未繳年費專利權消滅</option>
                <option value="CLOSEHP">CLOSEHP_HP結案</option>
                <option value="CLOSEHP-1">CLOSEHP-1_HP結案併請款</option>
                <option value="COUNT">COUNT_被異議不成立</option>
                <option value="DN01">DN01_電子請款通知信</option>
                <option value="DN02">DN02_DN寄INTEL通知信</option>
                <option value="DN03">DN03_DN寄DOW通知信</option>
                <option value="DN04">DN04_DN和信分開寄</option>
                <option value="DN05">DN05_DN寄NOKIA通知信</option>
                <option value="E01">E01_催實審指示</option>
                <option value="E01-1">E01-1_催實審指示-生/農</option>
                <option value="E02">E02_通知實審期限</option>
                <option value="E03">E03_已申請實審定稿</option>
                <option value="E04">E04_日案已申請實審</option>
                <option value="E05">E05_已申請實審 (HP)</option>
                <option value="E06">E06_已申請實審併寄中說</option>
                <option value="E07">E07_電告已實審</option>
                <option value="E08">E08_E050催實審</option>
                <option value="E09">E09_已申請實審 (NXP)</option>
                <option value="E10">E10_已實審請款(Micron)</option>
                <option value="E11">E11_已申請實審 (Agilent)</option>
                <option value="E12">E12_已申請實審併寄中說 (HP)</option>
                <option value="E13">E13_催實審,未收逕提</option>
                <option value="E14">E14_催實審(Agilent)</option>
                <option value="E15">E15_催實審-未收指示不辦案+結案</option>
                <option value="E16">E16_HP催實審指示</option>
                <option value="E17">E17_已申實審(請款對象:Nokia)</option>
                <option value="E18">E18_已申實審(請款對象:Dow)</option>
                <option value="E19">E19_催實審(Alcon)</option>
                <option value="F01">F01_Response(可延)</option>
                <option value="F02">F02_Response(不可延)</option>
                <option value="F03">F03_改請</option>
                <option value="F04">F04_訴願</option>
                <option value="F05">F05_Intel催指示</option>
                <option value="F07">F07_行政訴訟(15天)</option>
                <option value="F12">F12_改請或訴願</option>
                <option value="F14">F14_訴願理由</option>
                <option value="F16">F16_期限前未指示遞延</option>
                <option value="FILING">FILING_催新案提申指示</option>
                <option value="FILING-1">FILING-1_催新案說明書</option>
                <option value="G">G_已領證及繳年費通知(批次用)</option>
                <option value="G01">G01_已領證/繳年費</option>
                <option value="G02">G02_催年費及預付款 (罰金)</option>
                <option value="G03">G03_催年費及預付款</option>
                <option value="G04">G04_E050催年費(罰金)</option>
                <option value="G05">G05_E050催年費</option>
                <option value="G06">G06_催繳年費指示及附帳單</option>
                <option value="G07">G07_催繳年費指示及預付款</option>
                <option value="G08">G08_催年費(罰金)</option>
                <option value="G08-1">G08-1_催年費(罰金)-Intel案</option>
                <option value="G09">G09_催年費</option>
                <option value="G09-1">G09-1_催年費-Intel案</option>
                <option value="G10">G10_催年費-未收相反指示逕移管</option>
                <option value="G1-1">G1-1_已領證並繳年費通知第一年</option>
                <option value="G12">G12_E305 已領証/年費</option>
                <option value="G1-2">G1-2_已領證並繳年費通知第一～二年</option>
                <option value="G13">G13_行政訴訟(8天)</option>
                <option value="G1-3">G1-3_已領證並繳年費通知第一～三年</option>
                <option value="G14">G14_FORMFACTOR 已領証/年費</option>
                <option value="G1-4">G1-4_已領證並繳年費通知第一～四年</option>
                <option value="G1-5">G1-5_已領證並繳年費通知第一～五年</option>
                <option value="G1-6">G1-6_已領證並繳年費通知第一～六年</option>
                <option value="G27">G27_催領証指示</option>
                <option value="G28">G28_催領證指示(Agilent)</option>
                <option value="ISSFJ">ISSFJ_富士通已領証/年費</option>
                <option value="ISSHP">ISSHP_已領証/年費</option>
                <option value="ISSU1">ISSU1_Applied Masterials 已領証</option>
                <option value="ISSU2">ISSU2_1892繳年費/領證費</option>
                <option value="ISSU3">ISSU3_intel繳領證/年費 (其它代理人指示)</option>
                <option value="ISSU4">ISSU4_Applied Materials 領証~其它代理人指示</option>
                <option value="ISSU5">ISSU5_Ford繳年費/領證費</option>
                <option value="ISSU6">ISSU6_領證並減免1-3年年費</option>
                <option value="J0001">J0001_日文一般</option>
                <option value="J07">J07_test</option>
                <option value="J1001">J1001_已申報導一般</option>
                <option value="J1002">J1002_已申報導松本</option>
                <option value="J1003">J1003_大自達定稿(程序)</option>
                <option value="J2001">J2001_大自達致代(中間)</option>
                <option value="J2002">J2002_答辯請款</option>
                <option value="JA01">JA01_寄公函-通知補文(讓委可延)</option>
                <option value="JA02">JA02_寄公函-通知補文(讓委不可延)</option>
                <option value="JA03">JA03_寄公函-待補中說</option>
                <option value="JA04">JA04_寄公函-索空白圖電子檔</option>
                <option value="JA05">JA05_寄公函-通知補文不可延</option>
                <option value="JA06">JA06_寄公函-通知答辯最遲何時指示</option>
                <option value="JA07">JA07_寄公函--通知補文(英摘空白圖等)</option>
                <option value="JA08">JA08_已補文並寄公函</option>
                <option value="JA09">JA09_已補文</option>
                <option value="NEWDG">NEWDG_通知已申-新式樣</option>
                <option value="NEWIG">NEWIG_通知已申-發明</option>
                <option value="NEWUG">NEWUG_通知已申-新型</option>
                <option value="NXP">NXP_NXP 已領証/年費</option>
                <option value="OPEN">OPEN_函知早期公開</option>
                <option value="OPEN-1">OPEN-1_寄早期公開並請款</option>
                <option value="OPEN-2">OPEN-2_寄早期公開並請款(Formfactor)</option>
                <option value="Q03">Q03_催國外申請資料</option>
                <option value="R-C">R-C_申請專利範圍修正</option>
                <option value="REM01">REM01_reminder</option>
                <option value="S01">S01_最後催優及讓渡書</option>
                <option value="S02">S02_催優先權文件(15天)</option>
                <option value="S03">S03_催優先權文件-多件(15天)</option>
                <option value="S04">S04_最後催優,委及讓渡書</option>
                <option value="S05">S05_HP催讓及優先權</option>
                <option value="S06">S06_催優先權文件及收據 (15天)</option>
                <option value="S07">S07_最後催優收據及讓渡書 (8天)</option>
                <option value="S08">S08_催優先權文件及收據-多件 (15天)</option>
                <option value="S09">S09_催優先權文件-多件缺一(15天)</option>
                <option value="S10">S10_催優先權及收據~多件缺一 (15天)</option>
                <option value="S11">S11_催優先權文件 (已收收據) -多件</option>
                <option value="S12">S12_催優先權文件(已收收據-多件缺一-(15天)</option>
                <option value="S13">S13_催優先權文件(已收收據 -15天)</option>
                <option value="S14">S14_最後催優,讓渡書及收據-單.多件(已告知)-8天</option>
                <option value="S15">S15_催優先權文件 - 月催</option>
                <option value="S16">S16_最後催優,讓渡書及收據-多件缺一(已告知)-8天</option>
                <option value="SP01">SP01_寄中說-發明</option>
                <option value="SP02">SP02_寄中說-新型</option>
                <option value="SP03">SP03_寄中說-新式樣</option>
                <option value="SP04">SP04_寄中說(NXP)</option>
                <option value="SP05">SP05_寄中說(ASTRA)</option>
                <option value="SP06">SP06_寄中說同時補文</option>
                <option value="SPC1">SPC1_寄中說及修申請專利範圍</option>
                <option value="TP-01">TP-01_北專請款-外文本提申+修正(發明)</option>
                <option value="TP-02">TP-02_北專請款 -外文本提申+修正(新型)</option>
                <option value="TP-03">TP-03_北專請款-外文本提申(設計)</option>
                <option value="TP-04">TP-04_北專請款-台灣指示提申附評價書(發明)</option>
                <option value="TP-05">TP-05_北專請款-台灣指示提申附評價書(新型)</option>
                <option value="TP-06">TP-06_北專請款-隆天指示提申(發明)</option>
                <option value="TP-07">TP-07_北專請款-隆天指示提申(新型)</option>
                <option value="TP-08">TP-08_北專請款-申復</option>
                <option value="TP-09">TP-09_北專請款-修正</option>
                <option value="TP-10">TP-10_北專請款-再審查</option>
                <option value="TP-11">TP-11_北專請款-改請</option>
                <option value="TP-12">TP-12_北專請款-領證</option>
                <option value="TP-13">TP-13_北專請款-隆天請款</option>
                <option value="TP-14">TP-14_北專請款-新加坡written authority</option>
                <option value="TP-15">TP-15_北專致代-年費通知</option>
                <option value="V01">V01_結案請款</option>
                <option value="V03">V03_結案請款(附收據)</option>
                <option value="V05">V05_結案請款(未提申)</option>
                <option value="W">W_已繳年費通知(批次用)</option>
                <option value="W01">W01_AWAPATENT繳年費</option>
                <option value="W02">W02_i2繳年費</option>
                <option value="W03">W03_寄年費收據(已收款)</option>
                <option value="W04">W04_郵寄年費請款</option>
                <option value="W05">W05_Avago繳年費</option>
                <option value="W06">W06_Intel繳年費</option>
                <option value="W07">W07_寄年費收據-罰金(已收款)</option>
                <option value="W08">W08_年金未繳(移管)</option>
                <option value="W09">W09_NXP繳年費報導</option>
                <option value="W10">W10_FORMFACTOR繳年費</option>
                <option value="W11">W11_已繳年費通知(電文用)</option>
                <option value="W12">W12_E305繳年費報導</option>
                <option value="W13">W13_Agilent繳年費報導</option>
                <option value="W14">W14_DEACONS繳年費併告知下次繳費年度</option>
                <option value="W15">W15_GE繳年費報導</option>
                <option value="W16">W16_0034 已繳年費通知</option>
                <option value="W17">W17_3309 繳年費報導</option>
                <option value="W18">W18_通知寬延期限併結案定稿</option>
                <option value="XX01">XX01_核准信通知_發明</option>
                <option value="XX01A">XX01A_核准信通知_發明(Nokia)</option>
                <option value="XX01C">XX01C_核准信通知_發明(附cls)</option>
                <option value="XX01H">XX01H_核准信通知_發明(HP)</option>
                <option value="XX01K">XX01K_核准信通知_發明(自動領證)</option>
                <option value="XX01KC">XX01KC_核准信通知_發明(自動領證，附cls)</option>
                <option value="XX01KD">XX01KD_核准信通知_發明(自動領證，不附審定書英譯)</option>
                <option value="XX01L">XX01L_核准信通知_發明(不附審定書中文)</option>
                <option value="XX02">XX02_核准信通知_新型</option>
                <option value="XX02A">XX02A_核准信通知_新型(Nokia)</option>
                <option value="XX02C">XX02C_核准信通知_新型(附cls)</option>
                <option value="XX02H">XX02H_核准信通知_新型(HP)</option>
                <option value="XX02K">XX02K_核准信通知_新型(自動領證)</option>
                <option value="XX02KC">XX02KC_核准信通知_新型(自動領證，附cls)</option>
                <option value="XX03">XX03_核准信通知_新式樣</option>
                <option value="XX03A">XX03A_核准信通知_新式樣(Nokia)</option>
                <option value="XX03H">XX03H_核准信通知_新式樣(HP)</option>
                <option value="XX03K">XX03K_核准信通知_新式樣(自動領證)</option>
                <option value="XX04">XX04_核准信通知_聯合新式樣</option>
                <option value="XX04A">XX04A_核准信通知_聯合新式樣(Nokia)</option>
                <option value="XX04H">XX04H_核准信通知_聯合新式樣(HP)</option>
                <option value="XX04K">XX04K_核准信通知_聯合新式樣(自動領證)</option>
                <option value="XX05">XX05_發證通知</option>
                <option value="XX05N">XX05N_發證通知 (Nokia)</option>
                <option value="XX06">XX06_發證通知_(94/7/1以前適用)</option>
                <option value="XY01">XY01_答辯期限通知</option>
                <option value="XY02">XY02_文件期限通知</option>
                <option value="XY03">XY03_變更答辯期限通知</option>
                <option value="XY04">XY04_訴願答辯文件通知</option>
                <option value="XZ01">XZ01_再審核准信通知_發明</option>
                <option value="XZ01A">XZ01A_再審核准信通知_發明(Nokia)</option>
                <option value="XZ01C">XZ01C_再審核准信通知_發明(附cls)</option>
                <option value="XZ01H">XZ01H_再審核准信通知_發明(HP)</option>
                <option value="XZ01K">XZ01K_再審核准信通知_發明(自動領證)</option>
                <option value="XZ01KC">XZ01KC_再審核准信通知_發明(自動領證，附cls)</option>
                <option value="XZ03">XZ03_再審核准信通知_新式樣</option>
                <option value="XZ03A">XZ03A_再審核准信通知_新式樣(Nokia)</option>
                <option value="XZ03H">XZ03H_再審核准信通知_新式樣(HP)</option>
                <option value="XZ03K">XZ03K_再審核准信通知_新式樣(自動領證)</option>
                <option value="XZ04">XZ04_再審核准信通知_聯合新式樣</option>
                <option value="XZ04A">XZ04A_再審核准信通知_聯合新式樣(Nokia)</option>
                <option value="XZ04H">XZ04H_再審核准信通知_聯合新式樣(HP)</option>
                <option value="XZ04K">XZ04K_再審核准信通知_聯合新式樣(自動領證)</option>
                <option value="YY01">YY01_年費稽催通知函(10年以內)</option>
                <option value="YY01E">YY01E_年費稽催通知函(10年以內)</option>
                <option value="YY02">YY02_年費稽催通知函(10年以後含10)</option>
                <option value="YY03">YY03_年費稽催通知函(寬限期 6 年以內)</option>
                <option value="YY04">YY04_年費稽催通知函(寬限期 6 年以後含6)</option>
                <option value="YY05">YY05_特定代理人年費稽催通知函</option>
                <option value="YY06">YY06_Intel 專用年費稽催通知函</option>
                <option value="ZG09">ZG09_轉口案-催年費</option>
                <option value="ZZ01">ZZ01_轉口案已申報導</option>
            </select>
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">使用空白報導說明：</td>

        <td class="whitetablebg" colspan="3">
            <input class="sedit" maxlength="40" name="blank_remark" onblur="vbscript:fChkDataLen me,'使用空白報導說明'" readonly size="40" />
            <input name="blank_reset" type="checkbox" />重寄 </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">發文代碼：</td>

        <td class="whitetablebg" colspan="3">
            <table border="0" cellpadding="2" cellspacing="1" class="bluetable" style="font-size: 9pt" width="100%">
                <tr>
                    <td class="whitetablebg" colspan="3">結構分類： 
                        <input name="rs_type0" type="hidden" value="P94" />
                        <input name="codenum0" type="hidden" value="0" />
                        <!--附屬代碼筆數-->
                        <span id="span_rs_class0">
                            <select name="rs_class0" onchange="vbscript:rs_class_onchange1">
                                <option selected="" style="color: blue" value="">請選擇</option>
                                <option value="AA">新申請案</option>
                                <option value="HA">申請中間程序</option>
                                <option value="AR">待實審</option>
                                <option value="AS">初審</option>
                                <option value="AB">再審查</option>
                                <option value="AT">新型形式審查</option>
                                <option value="AC">改請</option>
                                <option value="AE">補充修正</option>
                                <option value="AD">分割申請</option>
                                <option value="AF">變更</option>
                                <option value="AG">更正</option>
                                <option value="AH">公告</option>
                                <option value="AJ">專利證書</option>
                                <option value="AK">年費</option>
                                <option value="AL">申請權異動</option>
                                <option value="AM">專利權異動</option>
                                <option value="AN">申請發給文件</option>
                                <option value="BA">異議</option>
                                <option value="BB">舉發</option>
                                <option value="AP">代理人異動</option>
                                <option value="AQ">申請案其他</option>
                                <option value="BC">被異議</option>
                                <option value="BD">被舉發</option>
                                <option value="BE">被依職權審查</option>
                                <option value="BF">爭議案其他</option>
                                <option value="IA">Enhancement</option>
                                <option value="CA">訴願</option>
                                <option value="CB">參加訴願</option>
                                <option value="CF">訴願共同中間程序</option>
                                <option value="CC">訴願再審</option>
                                <option value="DA">行政訴訟</option>
                                <option value="DB">參加行訴</option>
                                <option value="EA">行政訴訟上訴</option>
                                <option value="EE">參加上訴</option>
                                <option value="EB">再審之訴</option>
                                <option value="EC">參加再審之訴</option>
                                <option value="GA">其他</option>
                                <option value="JA">寄存</option>
                                <option value="FB">申請證明</option>
                                <option value="FC">食研所其他</option>
                                <option value="FD">醫藥品專利延長/連結</option>
                                <option value="KA">轉口案</option>
                                <option value="FA">寄存事宜</option>
                                <option value="GE">調查案</option>
                                <option value="GF">報導</option>
                                <option value="GG">稽催</option>
                                <option value="GH">支援內專外文致代</option>
                                <option value="BG">第三人觀察程序</option>
                            </select>
                        </span>案性代碼： <span id="span_rs_code0">
                            <select name="rs_code0" onchange="vbscript:rs_code_onchange1">
                                <option selected="" style="color: blue" value="">請選擇</option>
                                <option value="AA3">申請新型專利</option>
                                <option value="AA4">申請設計專利</option>
                                <option value="AA5">申請聯合新式樣專利</option>
                                <option value="AA6">發明請求實體審查</option>
                                <option value="AA7">發明初審申復</option>
                                <option value="AA8">新型初審申復</option>
                                <option value="AA9">新式樣初審申復</option>
                                <option value="AA10">申請修正</option>
                                <option value="AA11">初審面詢</option>
                                <option value="AA14">撤回專利申請</option>
                                <option value="AB1">申請發明再審查</option>
                                <option value="AB3">申請設計再審查</option>
                                <option value="AB4">發明再審查申復</option>
                                <option value="AB6">新式樣再審查申復</option>
                                <option value="AB7">申請修正</option>
                                <option value="AB8">再審查申請面詢</option>
                                <option value="AB10">撤回再審查</option>
                                <option value="AC1">改請發明專利(請求實審)</option>
                                <option value="AC2">改請發明專利(不請求實審)</option>
                                <option value="AC3">改請新型專利</option>
                                <option value="AC4">改請設計專利</option>
                                <option value="AC5">改請聯合新式樣專利</option>
                                <option value="AD1">發明分割申請(請求實審)</option>
                                <option value="AD2">發明分割申請(不請求實審)</option>
                                <option value="AD3">新型分割申請</option>
                                <option value="AD4">設計分割申請</option>
                                <option value="AD7">分割改請新型</option>
                                <option value="AF1">申請變更</option>
                                <option value="AG1">更正說明書圖式</option>
                                <option value="AK4">加倍補繳年費</option>
                                <option value="AQ12">其他事項</option>
                                <option value="BA1">異議發明</option>
                                <option value="BA2">異議新型</option>
                                <option value="BA3">異議新式樣</option>
                                <option value="BA5">異議案申請閱卷</option>
                                <option value="BA6">異議案申請面詢</option>
                                <option value="BB1">舉發發明</option>
                                <option value="BB2">舉發新型</option>
                                <option value="BB3">舉發設計</option>
                                <option value="BB5">舉發案申請閱卷</option>
                                <option value="BB6">舉發案申請面詢</option>
                                <option value="BB8">撤回舉發</option>
                                <option value="BC1">被異議提答辯</option>
                                <option value="BC3">申請修正</option>
                                <option value="BC4">被異議案申請閱卷</option>
                                <option value="BC5">被異議申請面詢</option>
                                <option value="BC7">撤回被異議答辯</option>
                                <option value="BD1">被舉發提答辯</option>
                                <option value="BD4">被舉發案申請閱卷</option>
                                <option value="BD5">被舉發申請面詢</option>
                                <option value="BD7">撤回被舉發</option>
                                <option value="BE1">被依職權審查提答辯</option>
                                <option value="BE4">被依職權審查案申請閱卷</option>
                                <option value="BE5">被依職權審查申請面詢</option>
                                <option value="BE7">撤回被依職權審查答辯</option>
                                <option value="BF1">其他事項</option>
                                <option value="IA1">申請電路布局權</option>
                                <option value="CA1">提訴願</option>
                                <option value="CA2">補充訴願理由證據</option>
                                <option value="CA5">撤回訴願</option>
                                <option value="CB4">參加訴願申請</option>
                                <option value="CF1">訴願共同申請</option>
                                <option value="CC1">提訴願再審</option>
                                <option value="CC2">補充訴願再審理由證據</option>
                                <option value="CC4">撤回訴願再審</option>
                                <option value="DA4">行政訴訟判決</option>
                                <option value="DA5">撤回行政訴訟</option>
                                <option value="DA6">其他</option>
                                <option value="DB1">參加訴訟</option>
                                <option value="DB2">不參加訴訟</option>
                                <option value="DB3">參加訴訟裁定</option>
                                <option value="DB4">參加訴訟通知</option>
                                <option value="DB5">參加訴訟判決</option>
                                <option value="DB6">其他</option>
                                <option value="EA2">上訴裁定</option>
                                <option value="EA3">上訴通知</option>
                                <option value="EA4">上訴判決</option>
                                <option value="EA5">撤回上訴</option>
                                <option value="EA6">其他</option>
                                <option value="EE1">參加上訴</option>
                                <option value="EE2">不參加上訴</option>
                                <option value="EE3">參加上訴裁定</option>
                                <option value="EE5">參加上訴判決</option>
                                <option value="EE6">其他</option>
                                <option value="EB1">再審書狀</option>
                                <option value="EB2">再審裁定</option>
                                <option value="EB3">再審通知</option>
                                <option value="EB4">再審判決</option>
                                <option value="EB5">再審撤回</option>
                                <option value="EB6">其他</option>
                                <option value="EC1">參加再審</option>
                                <option value="EC3">參加再審通知</option>
                                <option value="EC4">參加再審判決</option>
                                <option value="EC5">其他</option>
                                <option value="GA2">詢問題</option>
                                <option value="GA3">專利調查</option>
                                <option value="JA1">寄存</option>
                                <option value="FC1">其他事項</option>
                                <option value="KA9">其他</option>
                                <option value="HA7">補正文件</option>
                                <option value="AA16">初審審定</option>
                                <option value="AB11">函知修正</option>
                                <option value="AB12">再審查面詢</option>
                                <option value="AB14">再審查審定</option>
                                <option value="AD8">分割改請發明</option>
                                <option value="AM15">專利權消滅</option>
                                <option value="BA9">異議案審查</option>
                                <option value="BA10">異議案審定</option>
                                <option value="BB9">舉發案審查</option>
                                <option value="BB10">舉發案審定</option>
                                <option value="BC8">被異議案審查</option>
                                <option value="BC9">被異議案審定</option>
                                <option value="BC10">函知修正</option>
                                <option value="BD8">被舉發案審查</option>
                                <option value="BD9">被舉發案審定</option>
                                <option value="BD12">被舉發面詢</option>
                                <option value="CA7">官函通知</option>
                                <option value="CA8">訴願決定</option>
                                <option value="CB5">參加訴願</option>
                                <option value="CB6">補充參加訴願理由證據</option>
                                <option value="CB7">官函通知</option>
                                <option value="CC5">訴願再審決定</option>
                                <option value="EC6">參加再審裁定</option>
                                <option value="GA36">其他事項</option>
                                <option value="HA9">延期補正文件</option>
                                <option value="AA17">初審申請現場勘驗</option>
                                <option value="AA18">補送國內優先權證明</option>
                                <option value="AG5">更正申請專利範圍</option>
                                <option value="BA14">異議案申請現場勘驗</option>
                                <option value="BB14">異議案申請現場勘驗</option>
                                <option value="BC15">被異議申請現場勘驗</option>
                                <option value="BD14">被異議申請現場勘驗</option>
                                <option value="BE13">被依職權審查申請現場勘驗</option>
                                <option value="CA9">訴願申請</option>
                                <option value="DA7">起訴書狀</option>
                                <option value="FA1">寄存</option>
                                <option value="AA21">申請發明專利</option>
                                <option value="AA22">已撤回主張國際優先權</option>
                                <option value="AA23">已撤回主張國內優先權</option>
                                <option value="AB17">再審查申請現場勘驗</option>
                                <option value="AF2">已申請變更</option>
                                <option value="AE1">已申請修正</option>
                                <option value="AG6">已申請更正說明書圖式</option>
                                <option value="AG7">已更正說明書圖式以外事項</option>
                                <option value="AH6">已申請更正公告</option>
                                <option value="AH7">已申請更正早期公開公報</option>
                                <option value="AH8">已申請不公告</option>
                                <option value="AJ6">已領證並繳年費</option>
                                <option value="AJ7">已領證並繳減免年費</option>
                                <option value="AJ8">已申請加註專利權</option>
                                <option value="AJ9">已申請補發專利證書</option>
                                <option value="AJ10">已申請換發專利證書</option>
                                <option value="AJ11">檢發專利證書</option>
                                <option value="AK5">已申請減免年費</option>
                                <option value="AK6">已申請抵減年費</option>
                                <option value="AK7">已繳年費</option>
                                <option value="AK8">已繳納減免年費</option>
                                <option value="AK9">已加倍補繳年費</option>
                                <option value="AL3">已讓與申請權登記</option>
                                <option value="AL4">已繼承申請權登記</option>
                                <option value="AM16">已讓與專利權登記</option>
                                <option value="AM17">已專利權授權登記</option>
                                <option value="AM18">已繼承專利權登記</option>
                                <option value="AM19">已專利權質權設定登記</option>
                                <option value="AM20">已專利權質權變更登記</option>
                                <option value="AM21">已專利權質權消滅登記</option>
                                <option value="AM22">已專利權信託登記</option>
                                <option value="AM23">已專利權信託塗銷登記</option>
                                <option value="AM24">已專利權信託變更登記</option>
                                <option value="AM25">已專利權信託歸屬登記</option>
                                <option value="AM26">已申請延長專利權</option>
                                <option value="AM27">已申請特許實施</option>
                                <option value="AM28">已被特許實施答辯</option>
                                <option value="AM29">已聲明放棄專利權</option>
                                <option value="AN4">已申請發給英文證明書</option>
                                <option value="AN5">已申請發給優先權證明書</option>
                                <option value="AN6">已申請新型技術報告書</option>
                                <option value="AP5">已申請委任專利代理人</option>
                                <option value="AP6">已申請變更代理人</option>
                                <option value="AP7">已聲明解除代理</option>
                                <option value="AP8">已申請複委任代理人</option>
                                <option value="AQ19">已查詢審查進度</option>
                                <option value="AQ20">已請求暫緩審定</option>
                                <option value="AQ21">已申請優先審查</option>
                                <option value="AQ22">已申請提早公開</option>
                                <option value="AQ23">已申請不早期公開</option>
                                <option value="AQ24">已申請更正公報</option>
                                <option value="AQ25">已申請繼續審查</option>
                                <option value="AQ26">已陳明</option>
                                <option value="AQ27">已申請閱卷</option>
                                <option value="AQ28">已申請退還</option>
                                <option value="AQ29">已補繳規費</option>
                                <option value="AQ30">已申請退費</option>
                                <option value="BA15">已補充異議理由證據</option>
                                <option value="BA16">已撤回異議</option>
                                <option value="BB15">已補充舉發理由證據</option>
                                <option value="BC16">已補充被異議答辯理由</option>
                                <option value="BD15">已補充被舉發答辯理由</option>
                                <option value="BE14">已補充被依職權審查答辯理由</option>
                                <option value="CB9">參加訴願決定</option>
                                <option value="DA8">行政訴訟裁定</option>
                                <option value="EA7">行政訴訟上訴</option>
                                <option value="EE7">參加上訟通知</option>
                                <option value="EC7">不參加再審之訴</option>
                                <option value="JA2">已寄存</option>
                                <option value="FB5">已申請寄存證明</option>
                                <option value="FB6">已申請存活證明</option>
                                <option value="GE1">調查報告</option>
                                <option value="GE2">調查結果分析</option>
                                <option value="GF1">其他公文報導</option>
                                <option value="GF2">進度報導</option>
                                <option value="GF3">致/覆代理人函</option>
                                <option value="GA38">確收</option>
                                <option value="GG1">催文件</option>
                                <option value="GG2">催指示</option>
                                <option value="GG3">催回覆</option>
                                <option value="GG4">催實審</option>
                                <option value="GG5">催領證</option>
                                <option value="GG6">催繳年費</option>
                                <option value="KA10">新案提申前詢問題</option>
                                <option value="KA11">詢問題及請確認</option>
                                <option value="KA12">已提申請及請款</option>
                                <option value="KA13">通知申請中進展</option>
                                <option value="KA14">通知實審</option>
                                <option value="KA15">函知核駁修正及請款</option>
                                <option value="KA16">已答辯修正及請款</option>
                                <option value="KA17">函知核准及繳領證費年費</option>
                                <option value="KA18">已繳領證費及請款</option>
                                <option value="KA19">已發證</option>
                                <option value="KA20">通知繳年費</option>
                                <option value="KA21">已繳年費及請款</option>
                                <option value="KA22">已讓渡及請款</option>
                                <option value="KA23">確收指示</option>
                                <option value="KA24">催指示</option>
                                <option value="KA25">已結案</option>
                                <option value="AA24">早期公開</option>
                                <option value="GF4">期限通知</option>
                                <option value="GA47">致/覆代理人</option>
                                <option value="AQ33">已增加發明人</option>
                                <option value="AQ34">已刪除發明人</option>
                                <option value="AQ38">已變更申請人資料</option>
                                <option value="AQ39">已變更發明人資料</option>
                                <option value="AQ43">已變更優先權資料</option>
                                <option value="AG11">已更正證書</option>
                                <option value="DA9">行訴書狀</option>
                                <option value="BA18">異議審查確定</option>
                                <option value="BB17">舉發審查確定</option>
                                <option value="BD16">被舉發審查確定</option>
                                <option value="AQ44">申請回復原狀</option>
                                <option value="AF5">已申請權申請變更</option>
                                <option value="AF6">已專利權申請變更</option>
                                <option value="AK14">已申請退費</option>
                                <option value="FD1">申請醫藥延長</option>
                                <option value="FA2">寄存文件事宜</option>
                                <option value="AQ47">已聲明放棄</option>
                                <option value="BD17">涉訟優先審查</option>
                                <option value="BB18">涉訟優先審查</option>
                                <option value="AQ49">已申請撤回</option>
                                <option value="DA10">智慧財產法院通知</option>
                                <option value="BG1">第三人提起實審</option>
                                <option value="BG2">第三人申請技術評估報告</option>
                                <option value="BG3">第三人提送證據</option>
                                <option value="BG4">無效鑑定</option>
                                <option value="AA30">致/覆代理人</option>
                                <option value="AM31">終止授權實施登記</option>
                                <option value="AK17">催繳年費</option>
                                <option value="HA10">致覆代理人</option>
                                <option value="AC6">改請為部分設計</option>
                                <option value="AS01">發明初審審查</option>
                                <option value="AS03">發明初審意見通知</option>
                                <option value="AS04">發明初審最後通知</option>
                                <option value="AS05">發明初審審定</option>
                                <option value="AS06">發明初審分割(母案)</option>
                                <option value="AS07">發明初審改請</option>
                                <option value="AS23">設計初審意見通知</option>
                                <option value="AS25">設計初審審定</option>
                                <option value="AS26">設計初審分割(母案)</option>
                                <option value="AS27">設計初審改請</option>
                                <option value="AR01">待請求實審修正</option>
                                <option value="AR07">待請求實審改請</option>
                                <option value="AR02">發明請求實審</option>
                                <option value="AR08">待請求實審其它</option>
                                <option value="AS51">初審面詢</option>
                                <option value="AS52">初審官方電話通知</option>
                                <option value="AA32">申請衍生設計</option>
                                <option value="AC7">改請為衍生設計</option>
                                <option value="AS53">撤回初審</option>
                                <option value="AB52">再審官方電話通知</option>
                                <option value="AB20">發明請求再審查</option>
                                <option value="AB21">發明再審審查</option>
                                <option value="AB23">發明再審意見通知</option>
                                <option value="AB24">發明再審最後通知</option>
                                <option value="AB25">發明再審審定</option>
                                <option value="AB26">發明再審分割(母案)</option>
                                <option value="AB27">發明再審改請</option>
                                <option value="AB51">再審面詢</option>
                                <option value="AB53">撤回再審查</option>
                                <option value="AB70">設計請求再審查</option>
                                <option value="AB73">設計再審意見通知</option>
                                <option value="AB75">設計再審審定</option>
                                <option value="AB76">設計再審分割(母案)</option>
                                <option value="AB77">設計再審改請</option>
                                <option value="HA12">發明補正文件</option>
                                <option value="HA14">發明延期補正文件</option>
                                <option value="HA15">設計補正文件</option>
                                <option value="HA17">設計延期補正文件</option>
                                <option value="AD20">發明待實審分割</option>
                                <option value="AD21">發明初審分割</option>
                                <option value="AD22">發明再審分割</option>
                                <option value="AD30">新型分割</option>
                                <option value="AD41">設計初審分割</option>
                                <option value="AD42">設計再審分割</option>
                                <option value="AT01">新型形式審查</option>
                                <option value="AT03">新型形式審查意見通知</option>
                                <option value="AT05">新型形式審查處分</option>
                                <option value="AT06">新型分割(母案)</option>
                                <option value="AT07">新型改請</option>
                                <option value="AT51">新型面詢</option>
                                <option value="AT52">新型官方電話通知</option>
                                <option value="HA18">新型補正文件</option>
                                <option value="HA19">衍生設計補正文件</option>
                                <option value="HA20">新型補正文件(HP)</option>
                                <option value="HA21">衍生設計補正文件(HP)</option>
                                <option value="HA22">新型延期補正文件</option>
                                <option value="HA23">新型延期補正文件(HP)</option>
                                <option value="HA24">設計延期補正文件(HP)</option>
                                <option value="HA25">衍生設計延期補正文件(HP)</option>
                                <option value="HA26">衍生設計延期補正文件</option>
                                <option value="AQ52">已回復優先權主張</option>
                                <option value="AJ13">電告已領證並繳年費</option>
                                <option value="AK18">電告已繳年費</option>
                                <option value="GG11">Reminder</option>
                                <option value="AA34">已申請修正</option>
                                <option value="FD2">醫藥品延長案審查意見通知</option>
                                <option value="GA69">電告已官發</option>
                                <option value="AA36">已申請延緩實體審查</option>
                                <option value="AQ54">已撤回優先權主張</option>
                                <option value="GA72">提供公函</option>
                                <option value="GH01">北專請款-提申</option>
                                <option value="GH02">北專請款-審查</option>
                                <option value="GH03">北專其他請款</option>
                                <option value="GH04">北專致代</option>
                            </select>
                        </span>
                        <!--iris&nbsp;&nbsp;&nbsp;&nbsp;<input type=button class="cbutton" name="btnqrs_code" value ="查詢代碼" >-->
                        <br />
                        承辦事項： 
                        <input name="act_sqlno0" type="hidden" />
                        <input name="old_report_flag0" type="hidden" />
                        <input name="report_flag0" type="hidden" />
                        <input name="out_flag0" type="hidden" />
                        <!-- 20041116 start -->
                        <input name="spe_ctrl0" type="hidden" />
                        <input name="old_spe_ctrl0" type="hidden" />
                        <!-- 20041116 end -->
                        <span id="span_act_code0">
                            <select name="act_code0">
                                <option selected="" style="color: blue" value="">請選擇</option>
                                <option value="0454">公函報導</option>
                                <option value="0455">早期公開通知</option>
                                <option value="0456">專利權消滅通知</option>
                                <option value="0457">加倍補繳年費通知</option>
                                <option value="0458">已修正</option>
                                <option value="0459">面詢後報導</option>
                                <option value="0460">函知修正</option>
                                <option value="0461">繳面詢規費</option>
                                <option value="0466">通知已申請實體審查</option>
                                <option value="0467">已變更申請人資料</option>
                                <option value="0468">已變更發明人資料</option>
                                <option value="0469">已變更優先權資料</option>
                                <option value="0477">補文</option>
                                <option value="0478">其他</option>
                                <option value="0480">函請更正</option>
                                <option value="0482">通知對造答辯內容</option>
                                <option value="0486">函知舉發</option>
                                <option value="0491">已申請回復原狀</option>
                                <option value="0500">申請加速審查</option>
                                <option value="0501">申請面詢</option>
                                <option value="0502">已申請醫藥延長</option>
                                <option value="0504">已聲明放棄</option>
                                <option value="0510">報導</option>
                                <option value="0513">通知已申請進口許可證</option>
                                <option value="0514">已寄存</option>
                                <option value="0523">專利調查</option>
                                <option value="0524">已終止授權實施登記</option>
                                <option value="0527">更正核准審定書</option>
                                <option value="0528">修正並提加速審查</option>
                                <option value="0529">請求PPH</option>
                                <option value="0530">撤回</option>
                                <option value="0600">函知申復(含檢索報告)</option>
                                <option value="0601">函知申復(不含檢索報告)</option>
                                <option value="0602">函知申復</option>
                                <option value="0603">呈送文件</option>
                                <option value="0605">訂正</option>
                                <option value="0606">訂正並修正</option>
                                <option value="0607">請延補申復理由(2個月)</option>
                                <option value="0609">請求AEP</option>
                                <option value="0610">申復並修正</option>
                                <option value="0611">申復並訂正</option>
                                <option value="0612">申復並修正與訂正</option>
                                <option value="0613">補充申復</option>
                                <option value="0614">補充申復並修正</option>
                                <option value="0615">補充申復並訂正</option>
                                <option value="0616">補充申復並訂正與修正</option>
                                <option value="0619">改請新型</option>
                                <option value="0620">准予設計專利</option>
                                <option value="0621">不准設計專利</option>
                                <option value="0622">准予衍生設計專利</option>
                                <option value="0623">不准衍生設計專利</option>
                                <option value="0624">改請衍生設計</option>
                                <option value="0625">改請部分設計</option>
                                <option value="0626">改請設計</option>
                                <option value="0628">撰寫原文答辯</option>
                                <option value="0638">陳明</option>
                                <option value="0641">並請求實審</option>
                                <option value="0642">不請求實審(管制3年)</option>
                                <option value="0643">不請求實審(管制30天)</option>
                                <option value="0644">並改請新型</option>
                                <option value="0645">並改請發明(不請求實審管制3年)</option>
                                <option value="0646">並改請發明(不請求實審管制30天)</option>
                                <option value="0647">並改請發明(並請求實審)</option>
                                <option value="0648">並改請衍生設計</option>
                                <option value="0649">並改請設計</option>
                                <option value="0650">並改請部分設計</option>
                                <option value="0651">補正</option>
                                <option value="0652">請求再審查並延4個月補理由及規費</option>
                                <option value="0653">再延2個月補再審理由及規費</option>
                                <option value="0654">補再審查理由(Stop-gap)</option>
                                <option value="0655">補再審查理由並修正</option>
                                <option value="0656">補再審查理由並訂正</option>
                                <option value="0657">補再審查理由並訂正與修正</option>
                                <option value="0658">補再審查理由(補充)</option>
                                <option value="0659">補再審查理由(補充)並修正</option>
                                <option value="0660">補再審查理由(補充)並訂正</option>
                                <option value="0661">補再審查理由(補充)並訂正與修正</option>
                                <option value="0662">已延補中文摘要,說明書,申請專利範圍,圖式</option>
                                <option value="0663">已延補中文說明書,圖式</option>
                                <option value="0664">已延補委</option>
                                <option value="0665">已延補委,優先權文件正本</option>
                                <option value="0666">已延補委,優先權文件正本,中文摘要,說明書,申請專利範圍,圖式</option>
                                <option value="0667">已延補委,優先權文件正本,中文說明書,圖式</option>
                                <option value="0668">已補中文摘要,說明書,申請專利範圍,圖式</option>
                                <option value="0669">已補中文說明書,圖式</option>
                                <option value="0670">已補委</option>
                                <option value="0671">已補委,中文摘要,說明書,申請專利範圍,圖式</option>
                                <option value="0672">已補委,中文說明書,圖式</option>
                                <option value="0673">已補委,優先權文件</option>
                                <option value="0674">已補委,優先權文件,中文摘要,說明書,申請專利範圍,圖式</option>
                                <option value="0675">已補委,優先權文件,中文說明書,圖式</option>
                                <option value="0676">已補優先權文件,中文摘要,說明書,申請專利範圍,圖式</option>
                                <option value="0677">已補優先權文件,中文說明書,圖式</option>
                                <option value="0718">電告已實審</option>
                                <option value="0719">請求PPH並修正</option>
                                <option value="0720">請求AEP並修正</option>
                                <option value="0721">提再審查分割</option>
                                <option value="0730">附引證檔案</option>
                                <option value="0741">函知申復(含檢索報告)-不可延</option>
                                <option value="0743">外文本提申+修正(發明)</option>
                                <option value="0744">外文本提申+修正(新型)</option>
                                <option value="0745">台灣指示提申附評價書(發明)</option>
                                <option value="0746">台灣指示提申附評價書(新型)</option>
                                <option value="0747">外文本提申(設計)</option>
                                <option value="0748">隆天指示提申(發明)</option>
                                <option value="0749">隆天指示提申(新型)</option>
                                <option value="0750">再審查</option>
                                <option value="0751">領證</option>
                                <option value="0752">隆天請款</option>
                                <option value="0753">新加坡written authority</option>
                                <option value="0754">年費通知</option>
                                <option value="D108">不准發明專利(自管)</option>
                                <option value="D600">函知申復(含檢索報告)(自管)</option>
                                <option value="D601">函知申復(不含檢索報告)(自管)</option>
                                <option value="D602">函知申復(自管)</option>
                                <option value="D628">撰寫原文答辯(自管)</option>
                                <option value="_">_</option>
                                <option value="0005">修正</option>
                                <option value="0010">補理由</option>
                                <option value="0013">說明書,申請專利範圍,圖式</option>
                                <option value="0014">說明書</option>
                                <option value="0015">申請專利範圍</option>
                                <option value="0016">圖式</option>
                                <option value="0017">提補正</option>
                                <option value="0045">言辯書狀</option>
                                <option value="0070">聲明參加再審並請求延補由</option>
                                <option value="0071">聲明不參加再審</option>
                                <option value="0072">撤回參加再審</option>
                                <option value="0102">函請補正</option>
                                <option value="0104">函知被他人請求實審</option>
                                <option value="0105">函知先行核駁請提申復</option>
                                <option value="0107">准予發明專利</option>
                                <option value="0108">不准發明專利</option>
                                <option value="0109">准予新型專利</option>
                                <option value="0110">不准新型專利</option>
                                <option value="0111">准予設計專利</option>
                                <option value="0112">不准設計專利</option>
                                <option value="0113">准予聯合新式樣專利</option>
                                <option value="0114">不准聯合新式樣專利</option>
                                <option value="0115">初審審定自行撤銷</option>
                                <option value="0116">准予</option>
                                <option value="0121">函請申復</option>
                                <option value="0123">通知面詢</option>
                                <option value="0124">不准</option>
                                <option value="0134">再審審定自行撤銷</option>
                                <option value="0175">異議成立</option>
                                <option value="0176">異議不成立</option>
                                <option value="0179">舉發成立</option>
                                <option value="0180">舉發不成立</option>
                                <option value="0186">被異議不成立</option>
                                <option value="0187">被異議成立</option>
                                <option value="0195">被舉發不成立</option>
                                <option value="0196">被舉發成立</option>
                                <option value="0206">通知關係人參加訴願</option>
                                <option value="0210">訴願決定不成立</option>
                                <option value="0211">訴願決定成立</option>
                                <option value="0213">不准參加訴願</option>
                                <option value="0216">被訴願不成立</option>
                                <option value="0217">被訴願成立</option>
                                <option value="0229">准予訴願再審</option>
                                <option value="0230">不准訴願再審</option>
                                <option value="0231">訴願再審成立</option>
                                <option value="0232">訴願再審駁回</option>
                                <option value="0242">訴訟成立</option>
                                <option value="0243">訴訟駁回</option>
                                <option value="0246">參加訴訟勝訴</option>
                                <option value="0247">參加訴訟敗訴</option>
                                <option value="0249">上訴成立</option>
                                <option value="0250">上訴駁回</option>
                                <option value="0254">參加上訴勝訴</option>
                                <option value="0255">參加上訴敗訴</option>
                                <option value="0295">申復</option>
                                <option value="0299">請延補申復理由</option>
                                <option value="0305">提再審查理由</option>
                                <option value="0306">提再審查理由+修正</option>
                                <option value="0309">補再審查理由</option>
                                <option value="0334">改請</option>
                                <option value="0350">申請寄存証明</option>
                                <option value="0351">申請存活証明</option>
                                <option value="0352">已補申請權證明文件,委,優先權文件</option>
                                <option value="0353">已補申請權證明文件,委,優先權文件,中說</option>
                                <option value="0354">已補申請權證明文件,委,優先權文件,申請書,中說,圖式</option>
                                <option value="0355">已補中說，圖式</option>
                                <option value="0356">已補優先權文件</option>
                                <option value="0357">已補延誤證明</option>
                                <option value="0358">已延補申請權證明文件,委,優先權文件正本</option>
                                <option value="0359">已延補讓,委,優先權文件正本,中說</option>
                                <option value="0360">已延補申請權證明文件,委,優先權文件正本,申請書,中說</option>
                                <option value="0361">已延補中說，圖式</option>
                                <option value="0362">已延補優先權文件正本</option>
                                <option value="0363">已延補延誤證明</option>
                                <option value="0364">通知已申</option>
                                <option value="0365">已提申</option>
                                <option value="0366">通知請求實體審查</option>
                                <option value="0367">已申請實體審查</option>
                                <option value="0368">已提申復</option>
                                <option value="0369">已提申復並修正</option>
                                <option value="0370">已申請延期補理由</option>
                                <option value="0371">已補理由</option>
                                <option value="0372">已補理由並修正</option>
                                <option value="0373">已補正</option>
                                <option value="0374">已申請面詢</option>
                                <option value="0375">已申請現場勘驗</option>
                                <option value="0376">已申請撤回</option>
                                <option value="0377">已提再審查</option>
                                <option value="0378">已補充理由或證據</option>
                                <option value="0379">已理由後補</option>
                                <option value="0380">已提改請申請</option>
                                <option value="0381">已提分割申請</option>
                                <option value="0382">已補充理由</option>
                                <option value="0383">已提分割改請</option>
                                <option value="0384">已申請異議</option>
                                <option value="0385">已補呈理由並修正</option>
                                <option value="0386">已申請閱卷</option>
                                <option value="0387">已申請舉發</option>
                                <option value="0388">已提答辯</option>
                                <option value="0389">已補證</option>
                                <option value="0390">已提訴願</option>
                                <option value="0391">已提訴願並延補由</option>
                                <option value="0392">已補理由</option>
                                <option value="0393">已提訴願補充理由／証據</option>
                                <option value="0394">已申請閱覽</option>
                                <option value="0395">已申請言詞辯論</option>
                                <option value="0396">已閱卷</option>
                                <option value="0397">已參加言詞辯論</option>
                                <option value="0398">已撤回訴願</option>
                                <option value="0399">已申請參加訴願</option>
                                <option value="0400">通知參加訴願</option>
                                <option value="0401">已參加訴願並補由</option>
                                <option value="0402">已參加訴願並請求延補由</option>
                                <option value="0403">已補參加理由</option>
                                <option value="0404">已補充參加訴願理由</option>
                                <option value="0405">已申請交付鑑定</option>
                                <option value="0406">已申請命提文書</option>
                                <option value="0407">已申請勘驗/呈樣品</option>
                                <option value="0408">已申請承受訴願</option>
                                <option value="0409">已申請變更代理人</option>
                                <option value="0410">已提訴願再審</option>
                                <option value="0411">已提訴願再審補充理由／証據</option>
                                <option value="0412">已撤回訴願再審</option>
                                <option value="0413">已起訴</option>
                                <option value="0414">已延補訴理由</option>
                                <option value="0415">已補起訴理由</option>
                                <option value="0416">已提起訴補充理由</option>
                                <option value="0417">已提呈陳報狀</option>
                                <option value="0418">已提呈聲請狀</option>
                                <option value="0419">已提呈準備書狀</option>
                                <option value="0420">已提呈言辯書狀</option>
                                <option value="0421">已提呈抗告狀</option>
                                <option value="0422">出庭報導</option>
                                <option value="0423">已撤回行訴</option>
                                <option value="0424">已聲請參加行訴(主動要求參加)</option>
                                <option value="0425">已聲明參加行訴(官方通知後參加)</option>
                                <option value="0426">已聲明參加行訴並請求延補由</option>
                                <option value="0427">已呈參加訴訟補充理由</option>
                                <option value="0428">已呈陳報狀</option>
                                <option value="0429">已呈聲請狀</option>
                                <option value="0430">已呈準備書狀</option>
                                <option value="0431">已呈言辯書狀</option>
                                <option value="0432">已聲明不參加行訴</option>
                                <option value="0433">已撤回參加訴願</option>
                                <option value="0434">已提抗告</option>
                                <option value="0435">已提上訴</option>
                                <option value="0436">已提上訴並後補由</option>
                                <option value="0437">已補上訴理由</option>
                                <option value="0438">已提上訴補充理由</option>
                                <option value="0439">已撤回上訴</option>
                                <option value="0440">已聲請參加上訴</option>
                                <option value="0441">已聲明參加上訴</option>
                                <option value="0442">已聲明參加上訴並請求延補由</option>
                                <option value="0443">已呈上訴參加補充狀</option>
                                <option value="0444">已聲明不參加上訴</option>
                                <option value="0445">已撤回參加上訴</option>
                                <option value="0446">已提再審</option>
                                <option value="0447">再審成立</option>
                                <option value="0448">再審駁回</option>
                                <option value="0449">聲請參加再審(主動要求參加)</option>
                                <option value="0450">聲明參加再審(官方通知後參加)</option>
                                <option value="0451">參加再審勝訴</option>
                                <option value="0452">參加再審敗訴</option>
                            </select>
                        </span>
                        <input name="ocase_stat0" size="10" type="hidden" />
                        <input name="ncase_stat0" size="10" type="hidden" />
                        <span id="span_case_desc0">&nbsp;&nbsp;&nbsp;&nbsp;案件狀態： </span><span id="span_case_stat0">
                            <input class="sedit" name="ncase_statnm0" readonly />
                        </span></td>
                </tr>
            </table>
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">發文內容：</td>

        <td class="whitetablebg" colspan="3">
            <input maxlength="100" name="rs_detail0" size="80" />
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">指定代發期限：</td>

        <td class="whitetablebg" colspan="3">
            <input class="sedit" name="tfsend_date" readonly size="10" />
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">代發交辦事項說明：</td>

        <td class="whitetablebg" colspan="3">
            <textarea id="as_remark" class="sedit" cols="80" name="as_remark" readonly rows="5"></textarea>
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">代發否：</td>

        <td class="whitetablebg">
            <input checked="true" disabled name="need_as1" onclick="" type="radio" value="V1" />是 
            <input checked="true" disabled name="need_as" onclick="" type="radio" value="V1" />否 </td>

        <td class="lightbluetable" align="right">信函署名：</td>

        <td class="whitetablebg">
            <table border="0" cellpadding="2" cellspacing="1" class="bluetable" style="font-size: 9pt" width="100%">
                <tr>
                    <td class="whitetablebg">
                        <select name="tf_sender" size="1">
                            <option style="color: blue" value="">請選擇</option>
                            <option value="02">Vera Kuo (ext. 661)</option>
                            <option value="06">Vera Kuo(ext. 661)/Samuel Cheng(ext. 196)</option>
                            <option selected="" value="03">Julia Y.M. Hung (ext. 210)</option>
                            <option value="05">Amanda Y. S. Liu (ext. 212)</option>
                        </select>
                    </td>
                </tr>
            </table>
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">收發種類：</td>

        <td class="whitetablebg">
            <select disabled name="tf_ag" size="1" value="A">
                <option style="color: blue" value="">請選擇</option>
                <option selected="" value="A">代理人</option>
                <option value="O">其他</option>
            </select>
        </td>

        <td class="lightbluetable" align="right">收/發文：</td>

        <td class="whitetablebg">
            <table border="0" cellpadding="2" cellspacing="1" class="bluetable" style="font-size: 9pt" width="100%">
                <tr>
                    <td class="whitetablebg">
                        <select disabled name="tf_rs" size="1" value="S">
                            <option value="">請選擇</option>
                            <option value="R">R_收</option>
                            <option selected="" value="S">S_發</option>
                        </select>
                    </td>
                </tr>
            </table>
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">承辦人員：</td>

        <td class="whitetablebg" colspan="3">
            <select name="work_team" size="1">
                <option style="color: blue" value="">請選擇</option>
                <option value="100M">工程師主管</option>
                <option value="100Z">支援人力</option>
                <option value="100ZM">專案支援</option>
                <option value="160E">(出口)工一組</option>
                <option value="170E">(出口)工二組</option>
                <option value="180E">(出口)工三組</option>
                <option value="200M">程序主管</option>
                <option value="210">程序1組</option>
                <option value="220">程序2組</option>
                <option value="230">程序3組</option>
                <option value="300">英文部主管</option>
                <option value="3A0">英文一部</option>
                <option selected="" value="3A1">英文一組</option>
                <option value="3B0">英文二部</option>
                <option value="3B2">英文二組</option>
                <option value="3B3">英文三組</option>
                <option value="410">日文組</option>
                <option value="TM000">管理部</option>
                <option value="TM100">管理一組</option>
                <option value="TM200">管理二組</option>
                <option value="1A1">一部一組</option>
                <option value="1B2">二部二組</option>
                <option value="1C1">三部一組</option>
                <option value="1C2">三部二組</option>
                <option value="1A2">一部二組</option>
                <option value="1B1">二部一組</option>
                <option value="1B3">二部三組</option>
                <option value="340">業務處專案室</option>
            </select>
            <span id="span_work_scode">
                <select name="work_scode" onchange="vbscript:work_scode_onchange()" size="1" value="t748">
                    <option value="">請選擇</option>
                    <option value="t340">t340_陳伶慧</option>
                    <option value="t593">t593_韓宣芬</option>
                    <option selected="" value="t748">t748_陳宜君</option>
                    <option value="t1081">t1081_許秀如</option>
                </select></span>

        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">發文方式：</td>

        <td class="whitetablebg" colspan="3">
            <input name="tf_send_way2" title="A1" type="checkbox" value="A1" />FAX<br />
            <input name="tf_send_way3" title="A3" type="checkbox" value="A3" />E-Mail
            <span id="span_tf_send_way3">&nbsp;&nbsp;
                <input id="sendagent_nobutton0" class="cbutton" name="sendagent_nobutton0" type="button" value="定稿發信" width="21" />&nbsp;&nbsp;
                <input id="sendagent_nobutton1" class="cbutton" name="sendagent_nobutton1" type="button" value="Reply 定稿發信" width="21" />&nbsp;&nbsp;
                <input id="sendagent_nobutton2" class="cbutton" name="sendagent_nobutton2" type="button" value="附件發信" width="21" />&nbsp;&nbsp;
                <input id="sendagent_nobutton3" class="cbutton" name="sendagent_nobutton3" type="button" value="Reply 附件發信" width="21" />
            </span>
            <br />
            <input name="tf_send_way4" title="A5" type="checkbox" value="A5" />平台&nbsp;&nbsp;<select name="tf_tsend_way_A5" size="1">
                <option selected="" style="color: blue" value="">請選擇</option>
                <option value="01">IP Case Mail</option>
                <option value="02">EDTS</option>
                <option value="03">PrimeDrive</option>
                <option value="04">InternetDisk ASP</option>
                <option value="05">ATMS/ZX</option>
                <option value="06">ipBOX</option>
                <option value="07">Anaqua</option>
                <option value="08">Novum</option>
                <option value="09">Aurora</option>
                <option value="10">Foundation IP</option>
                <option value="11">Filing FA Portal</option>
                <option value="12">First to File</option>
            </select>&nbsp;<br />
            <input name="tf_send_way5" title="A4" type="checkbox" value="A4" />快遞<br />
            <input name="tf_send_way" title="A2" type="checkbox" value="A2" />LETTER&nbsp;&nbsp;<select name="tf_send_way1" size="1">
                <option selected="" style="color: blue" value="">請選擇</option>
                <option value="3">航平</option>
                <option value="99">雙掛</option>
                <option value="97">限掛</option>
                <option value="96">印刷</option>
                <option value="98">快遞</option>
                <option value="5">航限</option>
                <option value="4">航掛</option>
                <option value="45">航限掛</option>
                <option value="6">航印</option>
                <option value="8">其他</option>
                <option value="93">平信</option>
                <option value="95">限時</option>
                <option value="94">掛號</option>
            </select>&nbsp;，補充<input maxlength="50" name="send_way_mark" size="50" /><input name="htf_send_way" type="hidden" /><input name="tf_send_way_cnt" type="hidden" value="5" />
        </td>

    </tr>
    <tr>
        <td class="lightbluetable" align="right">&nbsp;</td>

        <td class="whitetablebg" colspan="3">
            <input class="sedit" name="is_agt_db" readonly type="checkbox" value="Y" />
            <font color="purple">寫入帳款記錄 ，種類：
                <select class="sedit" name="agt_db_flag" readonly size="1">
                    <option selected="" style="COLOR: blue" value="">請選擇</option>
                    <option value="01">帳款</option>
                    <option value="02">催帳</option>
                </select> 
            </font>
        </td>

    </tr>
    <tr>

        <td class="whitetablebg" colspan="4">
            <input type="hidden" value="1" name="tf_cnt">
            <input type="hidden" value="0" name="getlast_datenum">
            <table id="tabcode" class="bluetable" cellspacing="1" cellpadding="2" width="100%" border="0" name="tabcode">
                <tbody>
                    <tr>
                        <td class="lightbluetable" colspan="2" align="left">輸入下列信函所需資料</td>
                        <td class="lightbluetable" colspan="2" align="right">
                            <input onclick="vbscript:show_resp" id="last_date_button" class="cbutton" type="button" value="查詢尚未銷管法定期限" name="last_date_button">
                            <input onclick="vbscript:show_prior" id="prior_button" class="cbutton" type="button" value="查詢案件主檔優先權資料" name="prior_button">
                        </td>
                    </tr>
                    <tr>
                        <td class="lightbluetable3" colspan="4" align="left">※若為打勾資料請給予全形 X，以利資料顯示美觀，謝謝。<br>
                            ※若為日期資料，只可輸入一個日期，且需輸入 YYYY/MM/DD 格式。 </td>
                    </tr>
                    <tr class="sfont9">
                        <td class="whitetablebg" align="center">
                            <input type="hidden" name="tfsendd_sqlno1"><input type="hidden" value="gs_date" name="tf_mod1"><input class="sedit" readonly size="2" value="01" name="tf_num1"></td>
                        <td class="whitetablebg" align="left">
                            <input class="sedit" style="font-align: right" readonly size="10" value="最近官發日" name="tf_name_use1"></td>
                        <td class="whitetablebg" align="left">
                            <input onblur="vbscript:data_onblur 1" maxlength="255" size="60" name="mod_datas1"><input type="hidden" value="date" name="tf_datatype1"><input type="hidden" value="N" name="tf_default1"><input type="hidden" value="step_imp" name="source_table1"><input type="hidden" value="gs_date" name="source_field1"><input type="hidden" value="Y" name="ctrl_input1"></td>
                    </tr>
                </tbody>
            </table>
            <script language="vbscript">

'msgbox reg.getlast_datenum.value
'增加一筆
function code_Add_button_onclick()
	reg.tf_cnt.value = reg.tf_cnt.value + 1
	set lRow = tabcode.insertRow()
	lRow.classname = "sfont9"
	'cell 1
	set lCell = lRow.insertCell()
	lCell.align = "center"
	lCell.classname = "whitetablebg"
	lCell.innerHTML = "<input type=hidden name='tfsendd_sqlno" & reg.tf_cnt.value & "'>"
	lCell.innerHTML = lCell.innerHTML & "<input type=hidden name='tf_mod" & reg.tf_cnt.value & "'>"
	lCell.innerHTML = lCell.innerHTML & "<input type=text name='tf_num" & reg.tf_cnt.value & "' class=sedit readonly size=2>"
	'cell 2
	set lCell = lRow.insertCell()
	lCell.align = "left"
	lCell.classname = "whitetablebg"
	lCell.innerHTML = "<input type=text name='tf_name_use" & reg.tf_cnt.value & "'  class=sedit readonly size=20 style='font-align:right'>"
	'cell 3
	set lCell = lRow.insertCell()
	lCell.align = "left"	
	lCell.classname = "whitetablebg"
	lCell.innerHTML = "<input type=text name='mod_datas" & reg.tf_cnt.value & "' size=60 maxlength=255  onblur='vbscript:data_onblur " & reg.tf_cnt.value & "'>"
	lCell.innerHTML = lCell.innerHTML & "<input type=hidden name='tf_datatype" & reg.tf_cnt.value & "'>"
	lCell.innerHTML = lCell.innerHTML & "<input type=hidden name='tf_default" & reg.tf_cnt.value & "'>"
	lCell.innerHTML = lCell.innerHTML & "<input type=hidden name='source_table" & reg.tf_cnt.value & "'>"
	lCell.innerHTML = lCell.innerHTML & "<input type=hidden name='source_field" & reg.tf_cnt.value & "'>"
	lCell.innerHTML = lCell.innerHTML & "<input type=hidden name='ctrl_input" & reg.tf_cnt.value & "'>"
end function
'減少一筆
function deletecode(pno)
	if reg.tf_cnt.value=0 or pno>reg.tf_cnt.value then exit function
	tabcode.deleteRow(pno+1) '由0起	
	reg.tf_cnt.value = reg.tf_cnt.value - 1
end function
function data_onblur(pno)
	if eval("reg.tf_datatype"&pno&".value")="date" then
		IF chkdateformat(eval("reg.mod_datas"&pno)) then exit function
	elseif eval("reg.tf_datatype"&pno&".value")="int" then
		IF chkNum1(eval("reg.mod_datas"&pno),eval("reg.tf_name_use"&pno&".value")) then exit function
	end if
	if eval("reg.tf_mod"&pno&".value")="copies" then
		if eval("reg.mod_datas"&pno&".value")="1" then
			execute "reg.mod_datas"&pno&".value=""one copy"""
		elseif eval("reg.mod_datas"&pno&".value")="2" then
			execute "reg.mod_datas"&pno&".value=""two copies"""
		elseif eval("reg.mod_datas"&pno&".value")="3" then
			execute "reg.mod_datas"&pno&".value=""three copies"""
		end if
	end if
end function
function show_resp()
'msgbox reg.getlast_datenum.value
	window.open "impform\RespEdit.asp?prgid=" &reg.prgid.value& "&qtype=N&seq=" &reg.seq.value& "&seq1=" &reg.seq1.value & "&getlast_datenum="& reg.getlast_datenum.value &"&submittask=Q" ,"","width=780 height=650 top=10 left=10 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes"
end function
function show_prior()
	window.open "show_form.asp?qtype=prior&prgid=" &reg.prgid.value& "&seq=" &reg.seq.value& "&seq1=" &reg.seq1.value & "&submittask=Q" ,"","width=780 height=650 top=10 left=10 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes"
end function
            </script>
            <!--電文變數畫面-->
        </td>

    </tr>
</table>

<%--分案事項--%>
<table id="tfsend_br_Table" width="100%" class="bluetable" border="0" cellspacing="1" cellpadding="2">
    <tr>
        <td class="lightbluetable1" align="center" colspan="2">
            <span style="color: white">分&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;案&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;事&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;項</span>
        </td>
    </tr>

    <tr>
        <td class="lightbluetable" align="right" width="20%">報導工作：</td>

        <td class="whitetablebg">
            <table border="0" cellpadding="2" cellspacing="1" class="bluetable" style="font-size: 9pt" width="100%">
                <tr id="tr_tf_work_type">
                    <td align="left" class="whitetablebg" colspan="3">
                        <select disabled name="tf_work_type" size="1" value="">
                            <option selected="" style="color: blue" value="">請選擇</option>
                            <option value="EA">EA_新申案/異動案階段</option>
                            <option value="EB">EB_審查階段</option>
                            <option value="S">S_特殊電文報導</option>
                        </select>
                        <span id="span_tf_work_code">
                            <select disabled name="tf_work_code" size="1" value="">
                            </select>
                        </span>
                        <input name="tf_br_team" type="hidden" value="E" />
                    </td>
                </tr>
            </table>
        </td>

    </tr>

    <tr>
        <td class="lightbluetable" align="right" width="20%">分案處理說明：</td>

        <td class="whitetablebg">
            <textarea id="process_desc" nam="process_desc" cols="60" rows="3"></textarea>
        </td>

    </tr>

    <tr>
        <td class="lightbluetable" align="right">是否判行：</td>

        <td class="whitetablebg">
            <input id="chk_flag_N" name="chk_flag" type="radio" value="N" />否
            <input id="chk_flag_Y" name="chk_flag" type="radio" value="Y" />是
            判行人員：
            <select id="chk_team" name="chk_team">
            </select>
            <select id="chk_scode" name="chk_scode">
            </select>
        </td>

    </tr>

</table>
<%--分案事項 end--%>


<%--承辦事項--%>
<table id="tfsend_job_Table" width="100%" class="bluetable" border="0" cellspacing="1" cellpadding="2">
    <tr>
        <td class="lightbluetable1" align="center" colspan="2">
            <span style="color: white">承&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;辦&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;事&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;項</span>
        </td>
    </tr>

    <tr>
        <td class="lightbluetable" align="right" width="20%">承辦點數：</td>

        <td class="whitetablebg">
            <input class="" maxlength="10" name="tf_work_point" size="10" value="2" />
        </td>

    </tr>

    <tr>
        <td class="lightbluetable" align="right">報導處理說明：</td>

        <td class="whitetablebg">
            <textarea id="" nam="" cols="60" rows="3"></textarea>
        </td>

    </tr>


</table>

<%--承辦事項 end--%>




<script type="text/javascript" language="javascript">


    //取得代理人資料
    function get_agent_data(pType){
    
        var agent_no="";
        var agent_no1="";
        var pTitle="";

        if (pType=="seqagent"){
        
            agent_no = $("#seqagent_no").val();
            agent_no1 = $("#seqagent_no1").val();
            pTitle = "案件代理人";

        }else if (pType=="sendagent"){
            
            agent_no = $("#sendagent_no").val();
            agent_no1 = $("#sendagent_no1").val();
            pTitle = "郵寄代理人";

        }


        ////取資料SQL
        var psql = "";
        psql = " select *, isnull(agent_na1,'')+' '+isnull(agent_na2,'') as agent_na ";
        psql += " ,case ar_stat when 'Y' then '正常' when 'N' then '異常' end as ar_statnm "; 
        psql += " ,(select coun_c from sysctrl.dbo.country where coun_code = agent.agcountry) as agcountry_nm "; 
        psql += " from agent where 1 = 1 "; 
        
        psql += " and agent_no = '" + agent_no + "' ";  
        psql += " and agent_no1 = '" + agent_no1 + "' "; 

        psql += " order by agent_no, agent_no1 "; 

        //console.log(psql);

        $.ajax(
        {
            cache: false,
            async: false,
            type: "GET",
            url: "../AJAX/AjaxGetSqlDataMulti.aspx?SQL=" + encodeURIComponent(psql),
            success: function (data) {
                var JSONdata = $.parseJSON(data);


                if (JSONdata.length>0){
                    //有資料
                    $.each(JSONdata, function (i, item) {

                        if (pType=="seqagent"){

                            $('#seqagent_nonm').val(item.agent_na);
                            $('#addr1').val(item.addr1);
                            $('#addr2').val(item.addr2);
                            $('#addr3').val(item.addr3);
                            $('#addr4').val(item.addr4);
      
                        }else if (pType=="sendagent"){
        
                            $('#sendagent_nonm').val(item.agent_na);
                            $('#sendaddr1').val(item.addr1);
                            $('#sendaddr2').val(item.addr2);
                            $('#sendaddr3').val(item.addr3);
                            $('#sendaddr4').val(item.addr4);

                        }

                    });

                }else{
                    //沒有資料

                    //清空，給預設值
                    if (pType=="seqagent"){

                        $("#seqagent_no").val("");
                        $("#seqagent_no1").val("_");


                        $('#seqagent_nonm').val("");
                        $('#addr1').val("");
                        $('#addr2').val("");
                        $('#addr3').val("");
                        $('#addr4').val("");
      
                    }else if (pType=="sendagent"){
        
                        $("#sendagent_no").val("");
                        $("#sendagent_no1").val("_");

                        $('#sendagent_nonm').val("");
                        $('#sendaddr1').val("");
                        $('#sendaddr2').val("");
                        $('#sendaddr3').val("");
                        $('#sendaddr4').val("");

                    }
                    alert(pTitle+"不存在，請重新輸入!!!");
                }


            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                console.log(jqXHR.url);
                console.log(textStatus);
                console.log(errorThrown);
                alert("\n資料擷取剖析錯誤 !\n 請查詢console");
            }
        });


    }

    ////次下拉選單區塊
    var opt_array = {};

    //先隱藏次選單的選項
    //有多組就要增加
    opt_array["work_scode"] = $("#work_scode").children('option').remove();


    //由主選單顯示次選單的選項
    function change_child(pObj, pTargetId) {

        var tmpObj = opt_array[pTargetId];
        //console.log(tmpObj);

        $("#" + pTargetId).children('option').remove();
        $("#" + pTargetId).append(tmpObj[0]);
        $("#" + pTargetId).val("");

        var pVal = pObj.value;

        for (var i = 1; i < tmpObj.length; i++) {

            if (tmpObj[i].attributes["parent"].value == pVal) {
                //console.log(tmpObj[i]);

                //$("#work_scode").append(opt_work_scode[i]);
                $("#" + pTargetId).append(tmpObj[i]);
            }

        }
    }

    //由次選單顯示主選單的選項
    function change_parent(pObj, pTargetId) {

        //console.log($(pObj).find("option:selected").attr('parent'));
        //取得選則的OPTION的屬性
        var pVal = $(pObj).find("option:selected").attr('parent');

        $("#" + pTargetId).val(pVal);
    }


    ////次下拉選單區塊 end



    //載入資料
    function load_tfsend(){
    
        //分案處理說明
        $("#process_desc").val("處理說明處理說明處理說明");

        //核稿
        $("#dchk_flag_Y").prop("checked",true);   
        $("#dchk_team").val("TSEB300");
        $("#dchk_scode").val("t644");

        //判行人  
        $("#chk_flag_Y").prop("checked",true);   
        $("#chk_team").val("TSEB300"); 
        $("#chk_scode").val("t644");

        //簽名人
        $("#sign_flag_Y").prop("checked",true);
        $("#signer").val("t891");

    }

    //鎖定表格欄位
    function lockTfsendBrTable() {

        $('#tfsend_br_Table tbody input').lock(true);
        $('#tfsend_br_Table tbody select').lock(true);
        $('#tfsend_br_Table tbody textarea').lock(true);

    }


</script>
