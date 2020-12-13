<%@ Page Language="C#" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Word=Microsoft.Office.Interop.Word" %>
<%@ Import Namespace = "iTextSharp.text" %>
<%@ Import Namespace = "iTextSharp.text.pdf" %>
<%@ Import Namespace = "System.Xml" %>

<script runat="server">
	protected object wdCell=Word.WdUnits.wdCell;
	protected object wdCharacter = Word.WdUnits.wdCharacter;
	protected object wdCharacterFormatting = Word.WdUnits.wdCharacterFormatting;
	protected object wdColumn = Word.WdUnits.wdColumn;
	protected object wdItem = Word.WdUnits.wdItem;
	protected object wdLine = Word.WdUnits.wdLine;
	protected object wdParagraph = Word.WdUnits.wdParagraph;
	protected object wdParagraphFormatting = Word.WdUnits.wdParagraphFormatting;
	protected object wdRow = Word.WdUnits.wdRow;
	protected object wdScreen = Word.WdUnits.wdScreen;
	protected object wdSection = Word.WdUnits.wdSection;
	protected object wdSentence = Word.WdUnits.wdSentence;
	protected object wdStory = Word.WdUnits.wdStory;
	protected object wdTable = Word.WdUnits.wdTable;
	protected object wdWindow = Word.WdUnits.wdWindow;
	protected object wdWord = Word.WdUnits.wdWord;
	protected object wdExtend = 1;

	protected Word._Application wordApp = null;
	protected object oMissing = System.Reflection.Missing.Value;
	protected object oCount=1;

	private void Page_Load(System.Object sender, System.EventArgs e) {
		using (DBHelper conn = new DBHelper(Session["btbrtdb"].ToString())) {
			string SQL = "select * from dmt_attach ";
			SQL += "where seq = '" + Request["seq"] + "' ";
			SQL += "and seq1 = '" + Request["seq1"] + "' ";
			SQL += "and (source_name like '%.doc' or source_name like '%.docx') ";
			SQL += "and source = '" + Request["source"] + "' ";
			SQL += "and attach_desc like '%申請書%' ";
			SQL += "and att_sqlno = '" + Request["att_sqlno"] + "' ";
			SQL += "and attach_flag<>'D' ";
			SQL += "and doc_flag<>'E' ";
			DataTable dt = new DataTable();
			conn.DataTable(SQL, dt);

			Response.Write("$('#msg').html('');\r\n");
			if (dt.Rows.Count == 0) {
				Response.Write("$('#msg').html('<Font align=left color=\"red\" size=3>找不到申請書Word檔，請先上傳!!〈word檔判斷規則：副檔名為.doc或.docx，附件說明含有「申請書」字樣，不可勾□電子送件檔〉</font><BR>');\r\n");
				if ((Request["debug"] ?? "").ToUpper() == "Y") {
					Response.Write("$('#msg').append('" + SQL.Replace("'", "\\'") + "<BR>');\r\n");
				}
				Response.End();
			} else if (dt.Rows.Count > 1) {
				Response.Write("$('#msg').html('<Font align=left color=\"red\" size=3>找到多個申請書Word檔，請確認!!</font><BR>');\r\n");
				if ((Request["debug"] ?? "").ToUpper() == "Y") {
					Response.Write("$('#msg').append('" + SQL.Replace("'", "\\'") + "<BR>');\r\n");
				}
				Response.End();
			} else {
				string orgPath = dt.Rows[0]["attach_path"].ToString();
				if (orgPath.IndexOf(@"/btbrt/") == 0) {//『/btbrt/』開頭要換掉
					orgPath=orgPath.Substring(7);
				}
				string FileName = Server.MapPath("~/"+orgPath);
				if (!File.Exists(FileName)) {
					Response.Write("$('#msg').html('<Font align=left color=\"red\" size=3>找不到申請書Word檔(" + FileName.Replace("\\", "\\\\") + ")!!</font><BR>');\r\n");
					if ((Request["debug"] ?? "").ToUpper() == "Y") {
						Response.Write("$('#msg').append('虛擬目錄:~/" + orgPath + "<BR>');\r\n");
						Response.Write("$('#msg').append('轉換後:" + FileName.Replace("\\", "\\\\") + "<BR>');\r\n");
					}
					Response.End();
				}

				wordApp = new Word.Application();

				object oFalse = false;//執行過程不在畫面上開啟 Word
				object oTrue = true;//唯讀模式
				object oFilePath = FileName;    //檔案路徑
				Word._Document myDoc = wordApp.Documents.Open(ref oFilePath, ref oMissing, ref oTrue, ref oMissing,
									ref oMissing, ref oMissing, ref oMissing, ref oMissing,
									ref oMissing, ref oMissing, ref oMissing, ref oFalse,
									ref oMissing, ref oMissing, ref oMissing, ref oMissing);
				myDoc.Activate();
				try {
					Response.Write("var TagItem = new Array();\r\n");
					Response.Write("var tagCount=0;\r\n");
					Response.Write("var errFlag=false;\r\n");
					
					//20170808 增加檢查案件名稱
					string title_line = Get_name("【");
                    string required_name = title_line.Replace("【", "\\[").Replace("】", "\\]");
                    title_line = title_line.Replace("【", "").Replace("】", "");
                    SQL = " select form_name from cust_code where Code_type='rpt_pr_t' and convert(varchar,remark)='" + title_line + "' ";
					using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
						if (!dr.Read()) {
							Response.Write("$('#msg').append('<Font align=left color=\"red\" size=3>找不到申請書設定，請聯繫資訊人員!!</font><BR>');\r\n");
							if ((Request["debug"] ?? "").ToUpper() == "Y") {
								Response.Write("$('#msg').append('" + SQL.Replace("'", "\\'") + "<BR>');\r\n");
							}
						} else {
							string appl_line = Get_name(dr.SafeRead("form_name", ""));
							string[] split_appl = appl_line.Split('】');
							dr.Close();

							SQL = "select appl_name from dmt a where seq = '" + Request["seq"] + "' and seq1 = '" + Request["seq1"] + "' ";
							using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
								if (!dr1.Read()) {
									Response.Write("	errFlag=true;\r\n");
									Response.Write("	$('#msg').append('<Font align=left color=\"red\" size=3>" + split_appl[0] + "】找不到案件主檔!!</font><BR>');\r\n");
									if ((Request["debug"] ?? "").ToUpper() == "Y") {
										Response.Write("$('#msg').append('" + SQL.Replace("'", "\\'") + "<BR>');\r\n");
									}
								} else {
									if (dr1.SafeRead("appl_name", "").Trim().ToXmlUnicode() != split_appl[1].Trim().ToXmlUnicode()) {
										Response.Write("	errFlag=true;\r\n");
										Response.Write("	$('#msg').append('<Font align=left color=\"red\" size=3>" + split_appl[0] + "】申請書案件名稱(" + split_appl[1].Trim().Replace("'", "\\'") + ")與案件主檔(" + dr1.SafeRead("appl_name", "").Trim().Replace("'", "\\'") + ")不符!!</font><BR>');\r\n");
									}
								}
							}
						}
					}
                    
                    //20191017 增加檢查申請書檔名
                    string brseq = Request["Branch"] + "T" + Request["seq"] + (Request["seq1"] != "_" ? "-" + Request["seq1"] : "");
                    SQL = " select * from dmt_attach a ";
                    SQL += "where seq = '" + Request["seq"] + "' ";
                    SQL += " and seq1 = '" + Request["seq1"] + "' ";
                    SQL += " and source_name like '%" + required_name + "%' ESCAPE '\\' ";//中括號在SQL是關鍵字,要用跳脫字元
                    SQL += " and source_name like '%" + brseq + "%' ";//20201021增加案號檢查
                    SQL += " and source = '" + Request["source"] + "' ";
                    SQL += " and att_sqlno = '" + Request["att_sqlno"] + "' ";
                    SQL += " and attach_flag<>'D' ";
                    SQL += " and doc_flag='E' ";
                    string applyOrgPath = "";
                    using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                        if (!dr1.Read()) {
                            Response.Write("	errFlag=true;\r\n");
                            Response.Write("	$('#msg').append('<Font align=left color=\"red\" size=3>申請書PDF檔名有誤，檔名須含有<font color=\"black\">" + required_name + "</font>及案號(<font color=\"black\">" + brseq + "</font>)，透過增益集轉檔後產生的檔名請勿任意修改!!</font><BR>');\r\n");
                            if ((Request["debug"] ?? "").ToUpper() == "Y") {
                                Response.Write("$('#msg').append('" + SQL.Replace("'", "\\'") + "<BR>');\r\n");
                            }
                        } else {
                            applyOrgPath = dr1.SafeRead("attach_path", "");
                        }
                    }
                    //20191017 增加申請書增益集版本
                    if (applyOrgPath != "") {
                        if (applyOrgPath.IndexOf(@"/btbrt/") == 0) {//『/btbrt/』開頭要換掉
                            applyOrgPath = applyOrgPath.Substring(7);
                        }
                        string pdfFileName = Server.MapPath("~/" + applyOrgPath);
                        if (!File.Exists(pdfFileName)) {//檢查申請書PDF是否存在
                            Response.Write("	errFlag=true;\r\n");
                            Response.Write("	$('#msg').append('<Font align=left color=\"red\" size=3>找不到申請書PDF檔(" + pdfFileName.Replace("\\", "\\\\") + ")!!</font><BR>');\r\n");
                            if ((Request["debug"] ?? "").ToUpper() == "Y") {
                                Response.Write("$('#msg').append('虛擬目錄:~/" + applyOrgPath + "<BR>');\r\n");
                                Response.Write("$('#msg').append('轉換後:" + pdfFileName.Replace("\\", "\\\\") + "<BR>');\r\n");
                            }
                        } else {
                            PdfReader reader = null;
                            try {
                                reader = new PdfReader(pdfFileName);
                                if (!reader.Info.ContainsKey("XmlData")) {
                                    Response.Write("	errFlag=true;\r\n");
                                    Response.Write("	$('#msg').append('<Font align=left color=\"red\" size=3>申請書PDF檔未使用增益集轉檔!!</font><BR>');\r\n");
                                } else {
                                    XmlDocument xml = new XmlDocument();
                                    xml.LoadXml(reader.Info["XmlData"]);
                                    string pdfV = xml.GetElementsByTagName("version")[0].InnerText;

                                    //cust_code=最低可用版本
                                    SQL = "select cust_code lowest from cust_code ";
                                    SQL += "where code_type = 'ESET' ";
                                    string strBaseVer = (conn.ExecuteScalar(SQL) ?? "").ToString();
                                    if (strBaseVer == "") {
                                        Response.Write("	errFlag=true;\r\n");
                                        Response.Write("	$('#msg').append('<Font align=left color=\"red\" size=3>找不到版本檢查設定，請聯繫資訊人員!!</font><BR>');\r\n");
                                    } else {
                                        System.Version baseVer = new System.Version(strBaseVer);
                                        System.Version pdfVer = new System.Version(pdfV);
                                        if (baseVer > pdfVer) {
                                            Response.Write("errFlag=true;\r\n");
                                            Response.Write("$('#msg').append('<Font align=left color=\"red\" size=3>申請書PDF版本過舊(" + pdfVer.ToString() + ")，請使用最新版的增益集重新轉檔 !!</font><BR>');\r\n");
                                        }
                                    }
                                }
                            }
                            finally {
                                //一定要資源釋放，否則會Lock
                                reader.Dispose();
                                reader.Close();
                            }
                        }
                    }
                    
					//20170808 增加檢查規費
					string fee_line = Get_name("【繳費金額】");
					string[] split_fee = fee_line.Split('】');
					if (split_fee.Length == 2) {
						Response.Write("var fee=document.getElementsByName('fees')[0].value;\r\n");
						Response.Write("if (fee!='" + split_fee[1].Trim() + "'){\r\n");
						Response.Write("	errFlag=true;\r\n");
						Response.Write("	$('#msg').append('<Font align=left color=\"red\" size=3>【繳費金額】官發應繳規費('+fee+')與申請書填寫金額(" + split_fee[1].Trim() + ")不符!!</font><BR>');\r\n");
						Response.Write("}\r\n");
					}

					//20180331 增加檢查收據抬頭
					string receipt_line = Get_name("【收據抬頭】");
					string[] split_receipt = receipt_line.Split('】');
					string receipt_type = "B";
					string receipt_text = "空白";
					if (split_receipt.Length == 2) {
						if (split_receipt[1].IndexOf("(代繳人") > -1) {
							receipt_type = "C";
							receipt_text = "案件申請人(代繳人)";
						} else if (split_receipt[1].Trim() != "") {
							receipt_type = "A";
							receipt_text = "專利權人";
						}
					}
					Response.Write("var receipt_title=document.getElementsByName('receipt_title')[0].value;\r\n");
					Response.Write("var receipt_text=$('#receipt_title :selected').text();\r\n");
					Response.Write("if (receipt_title!='" + receipt_type + "'){\r\n");
					Response.Write("	errFlag=true;\r\n");
					Response.Write("	$('#msg').append('<Font align=left color=\"red\" size=3>【收據抬頭】申請書抬頭種類(" + receipt_text + ")與官發收據種類('+receipt_text+')不符!!</font><BR>');\r\n");
					Response.Write("}\r\n");

					//檢查附送書件
					List<string> attachList = Get_AttachBlock();
					for (int z = 0; z < attachList.Count; z++) {
						if (attachList[z] != "") {
							string[] split_line = attachList[z].Replace("　", "").Split('】');
							if (split_line.Length == 2) {
								SQL = " select * from dmt_attach a ";
								SQL += "where seq = '" + Request["seq"] + "' ";
								SQL += " and seq1 = '" + Request["seq1"] + "' ";
								SQL += " and source_name='" + split_line[1].Trim() + "' ";
								SQL += " and source = '" + Request["source"] + "' ";
								SQL += " and att_sqlno = '" + Request["att_sqlno"] + "' ";
								SQL += " and attach_flag<>'D' ";
								SQL += " and doc_flag='E' ";
								using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
									if (!dr1.HasRows) {
										Response.Write("TagItem[tagCount] = new Array();\r\n");
										Response.Write("TagItem[tagCount][0] = '" + split_line[0] + "】';\r\n");
										Response.Write("TagItem[tagCount][1] = '" + split_line[1].Trim() + "';\r\n");
										Response.Write("tagCount+=1;\r\n");
									}
								}
							}
						}
					}

					Response.Write("for(var x=0;x<tagCount;x++)\r\n");
					Response.Write("{\r\n");
					Response.Write("	var chkOK=false;\r\n");
					Response.Write("	var filenum = document.getElementById('attachfilenum').value;\r\n");
					Response.Write("	for (var no = 1; no <= filenum; no++) {\r\n");
					Response.Write("		if (document.getElementById('source_name'+no).value!=''&&document.getElementById('source_name'+no).value==TagItem[x][1]&&document.getElementById('doc_flag'+no).checked==true){\r\n");
					Response.Write("			chkOK=true;\r\n");
					Response.Write("			break;\r\n");
					Response.Write("		}else if (document.getElementById('source_name'+no).value==''&&document.getElementById('attach_name'+no).value==TagItem[x][1]&&document.getElementById('doc_flag'+no).checked==true){\r\n");
					Response.Write("			chkOK=true;\r\n");
					Response.Write("			break;\r\n");
					Response.Write("		}\r\n");
					Response.Write("	}\r\n");
					Response.Write("	if(!chkOK)\r\n");
					Response.Write("	{\r\n");
					Response.Write("		errFlag=true;\r\n");
					Response.Write("		$('#msg').append('<Font align=left color=\"red\" size=3>'+TagItem[x][0]+'<b>'+TagItem[x][1]+'</b> 抓取對應附件有錯誤，請檢查附送書件之檔案是否已經上傳 !!</font><BR>');\r\n");
					Response.Write("	}\r\n");
					Response.Write("}\r\n");

					Response.Write("if (!errFlag){\r\n");
					Response.Write("	$('#msg').html('<Font align=left color=\"darkblue\" size=3>檢查完成，請執行確認!!</font><BR>');\r\n");
					Response.Write("	$('#button0').attr('disabled', true);\r\n");
					Response.Write("}\r\n");
				}
				catch (Exception ex) {
					Response.Write("errFlag=true;\r\n");
					Response.Write("$('#msg').html('<Font align=left color=\"red\" size=3>Eeception - " + ex.Message + "!!</font><BR>');\r\n");
				}
				finally {
					wordApp.ActiveDocument.Close(ref oMissing, ref oMissing, ref oMissing);
					wordApp.Quit(ref oMissing, ref oMissing, ref oMissing);
					if (myDoc != null)
						System.Runtime.InteropServices.Marshal.ReleaseComObject(myDoc);
					if (wordApp != null)
						System.Runtime.InteropServices.Marshal.ReleaseComObject(wordApp);
					myDoc = null;
					wordApp = null;
					GC.Collect();
				}
			}
		}
	}

	//尋找特定tag
	protected string Get_name(string pTag_name) {
		string get_value = "";
		wordApp.Selection.HomeKey(ref wdStory, ref oMissing);
		wordApp.Selection.Find.ClearFormatting();
		wordApp.Selection.Find.Text = pTag_name;
		wordApp.Selection.Find.Forward = true;
		wordApp.Selection.Find.MatchWholeWord = true;

		if (wordApp.Selection.Find.Execute(ref oMissing,
				ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing,
				ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing,
				ref oMissing, ref oMissing)) {
			wordApp.Selection.HomeKey(ref wdLine, ref oMissing);
			wordApp.Selection.MoveDown(ref wdParagraph, ref oCount, ref wdExtend);//ctrl+shift+↓
			wordApp.Selection.Copy();

			get_value = wordApp.Selection.Text;
			get_value = get_value.Replace(((char)13).ToString(), "");//整行複製會帶最後的換行符號
			//get_value = get_value.Replace("　", "");//全形空白
            get_value = ReplaceStart(get_value, "　", "");//開頭全形空白
            get_value = ReplaceEnd(get_value, "　", "");//結尾全形空白
            get_value = get_value.Replace(((char)9).ToString(), "");//tab
		}

		return get_value;
	}
	
	//擷取word【附送書件】區塊,找到具結為止
	protected List<string> Get_AttachBlock() {
		List<string> attach_list = new List<string>();
		
		wordApp.Selection.HomeKey(ref wdStory, ref oMissing);
		wordApp.Selection.Find.ClearFormatting();
		wordApp.Selection.Find.Text = "【附送書件】";
		wordApp.Selection.Find.Forward = true;
		wordApp.Selection.Find.MatchWholeWord = true;

		if (wordApp.Selection.Find.Execute(ref oMissing,
				ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing,
				ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing,
				ref oMissing, ref oMissing)) {
			int i = 0;
			while (++i < 100) {//防止無限迴圈
				wordApp.Selection.MoveDown(ref wdParagraph, ref oCount, ref oMissing);//ctrl+↓
				wordApp.Selection.MoveDown(ref wdParagraph, ref oCount, ref wdExtend);//ctrl+shift+↓
				wordApp.Selection.Copy();

				string strTemp = wordApp.Selection.Text;
				strTemp = strTemp.Replace(((char)13).ToString(), "");//整行複製會帶最後的換行符號
				strTemp = strTemp.Replace("　", "");//全形空白
				strTemp = strTemp.Replace(((char)9).ToString(), "");//tab
				strTemp = strTemp.Replace(((char)12).ToString(), "");//換頁
				strTemp = strTemp.Trim();

				if (strTemp == "【本申請書所填寫之資料係為真實】") {
					break;
				} else if (strTemp.IndexOf("【其他】") > -1 
                    || strTemp.IndexOf("【文件描述】") > -1 
                    || strTemp == "【附送書件】" 
                    || strTemp == ""
                    || (strTemp.IndexOf("【基本資料表") > -1 && strTemp.IndexOf("未變更本案基本資料") > -1)
                    ) {
					continue;
				} else {
					strTemp = strTemp.Replace("【文件檔名】", "【其他】");
					attach_list.Add(strTemp);
				}
				//Response.Write(i + strTemp + "<BR>");
			}
		}
		return attach_list;
	}
	
	//正規切割(測試)
	protected void MatchTag(string content) {
		MatchCollection Matches = Regex.Matches(content, @"【(?<tag>.*)】(?<value>.*)", RegexOptions.IgnoreCase);
		foreach (Match match in Matches) {
			//attach_list.Add(new Content() { Tag = match.Groups["tag"].Value, Value = match.Groups["value"].Value });
		}
	}

    protected string ReplaceStart(string Source, string Find, string Replace) {
        string regex = @"(^" + Find + "+)";
        return Regex.Replace(Source, regex, Replace);
    }

    protected string ReplaceEnd(string Source, string Find, string Replace) {
        string regex = @"(" + Find + "+$)";
        return Regex.Replace(Source, regex, Replace);
    }
</script>
