main.savechk = function () {
    //�Ȥ��p���H�ˬd
    if (main.chkCustAtt() == false) return false;
	
    //�ӽФH�ˬd
    if (main.chkApp() == false) return false;
	
	//����榡�ˬd,��class=dateField,����J�h�ˬd
    if (main.chkDate("#case") == false) { alert("����榡���~,���ˬd"); return false; }
    if (main.chkDate("#dmt") == false) { alert("����榡���~,���ˬd"); return false; }
    if (main.chkDate("#tran") == false) { alert("����榡���~,���ˬd"); return false; }

 	//�ӼЦW���ˬd
    if (main.chkApplName() == false) return false;

    //��������ˬd
    if (main.chkRequire() == false) return false;

   //�������e�����ˬd
    if (main.chkCaseForm() == false) return false;

    //�s/�®׸�
    if (main.chkNewOld() == false) return false;

	//�X�W�N�z�H�ˬd
	if (main.chkAgt("apnum","apclass","tfzd_agt_no") == false) return false;

	$("#tfzd_color").val($("input[name='tfzy_color']:checked").val()||"");
	$("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val()||"");
	$("#tfzd_Pul").val($("#tfzy_Pul").val());
    $("#tfzd_Zname_type").val($("#tfzy_Zname_type").val());
    $("#tfzd_prior_country").val($("#tfzy_prior_country").val());	
	
    //�D�ɰӫ~���O�ˬd
    if (main.chkGood() == false) return false;
	
    //���״_���ˬd
    if (main.chkEndBack() == false) return false;

    //�ˬd�j���׽дڵ��O�ˬd&����
    if (main.chkAr() == false) return false;

	$("#F_tscode,#tfzd_Tcn_mark").unlock();
    $("#tfg1_seq").val($("#tfzb_seq").val());
    $("#tfg1_seq1").val($("#tfzb_seq1").val());

	//reg.action="Brt11AddAC.asp"	
    //$("#submittask").val("Add");
	//If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	//reg.Submit
}