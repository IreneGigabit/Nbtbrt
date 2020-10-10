﻿//*****顯示說明
var ztext = "<tr><td>◎商標法施行細則第二十八條規定：商標圖樣中包含說明性或不具特別顯著性之文字或圖形，若刪除該部分則失其商標圖樣完整性者，仍得以該整體圖樣申請註冊，但應聲明該部分與整體圖樣分離時，不單獨主張專用權。</td></tr>";
var ztextc = "<tr><td>◎中文字義：字典可查到的字義；如為自創字，請填寫「無義」或「自創字」。</td></tr>";
var ztextd = "<tr><td>◎圖形：請用文字描述。如兩隻獅子站在地球上之組合圖。</td></tr>";
var ztextd1 = "<tr><td>一、本申請書所載內容將一一輸入電腦，請一律由左至右橫式正確詳細填寫，字跡務必端正清晰，以免鍵入錯誤。</td></tr>" +
			 "<tr><td>二、以一案一商標為原則。</td></tr>" +
			 "<tr><td>三、申請異議／評定／廢止 □ 商標 □ 商標（92年修正前服務標章） □ 證明標章 □ 團體標章</td></tr>" +
			 "<tr><td>　　團體商標之註冊號數、商標種類及名稱，請務必確實ˇ選及填寫正確。</td></tr>";
var ztextd2 = "<tr><td>四、請填寫異議／評定/廢止商標圖樣違法部分之中文或英文或日文或記號或圖形或其他部分，俾便電腦鍵入作業。非英文或日文之外國文字、顏色、聲音、立體形狀等，請填寫其他欄位。</td></tr>";
var ztextd3 = "<tr><td>一、填寫異議／評定／廢止標的註冊號數、商標／標章名稱及勾選商標／標章種類。</td></tr>";
var ztextd4 = "<tr><td>二、對本件異議／廢止標的指定使用全部類別之商品或服務提出異議／廢止聲明者，請勾選第一空格欄。</td></tr>";
var ztextd5 = "<tr><td>三、類似商品及服務，請參考本局編輯之「商品及服務分類暨相互檢索參考資料」。</td></tr>";
var ztextd6 = "<tr><td>四、所謂「著名之商標或標章」，係指有客觀證據足以認定該商標或標章已廣為相關事業或消費者所普遍認知者而言，主張據以評定商標／標章係著名商標／標章者，請參考「商標法第30條第1項第11款著名商標保護審查基準」，並檢附相關著名商標／標章證據資料。</td></tr>";
var ztextd7 = "<tr><td>例如：與八十九年二月十四日註冊第00888168號商標異議案有關</td></tr>" +
			 "<tr><td>　　　與八十九年二月十四日註冊第00888168號商標變更申請人名稱案有關</td></tr>";
var ztextg0 = "<tr><td>◎未填寫商品／服務名稱者，無法取得申請日。</td></tr>";
var ztextg1 = "<TR><TD>◎類別欄中，請就指定商品及服務分類表<font color=red>第1至45類填寫，並得以一案多類商品或服務提出申請</font>。</TD>" +
			 "<TR><TD><font color=red>◎請按商品及服務分類表之類別順序，依序填寫組群代碼，並具體列舉商品／服務名稱。</font><TD></tr>";
var ztextg2 = "<TR><TD>◎所指定之商品名稱應具體明確，不得以概括性之語句，如「及不屬別類之一切商品」或「及應屬本類之一切商品」等字樣提出申請。</TD>" +
             "<TR><TD>◎無法得知商品組群碼，可不必填寫。</TD></TR>";
var ztextg3 = "<TR><TD><font color=red>◎商品類別與名稱，請參考商標法施行細則第○○○條規定及「商品及服務近似檢索參考資料」填寫</font>。商品名稱若不是「商品及服務近似檢索參考資料」所載之名稱者，請檢送商品型錄及商品功能或材質等相關說明資料供審酌。</TD></tr>";
var ztextg4 = "<tr><td>◎商品或服務類別與名稱請參考商標法施行細則第○○○條規定及「商品及服務近似檢索參考資料」填寫。若所指定名稱倘非「商品及服務近似檢索參考資料」所載之名稱者，請檢送相關說明資料以供審酌。（如：型錄、說明書、照片、樣品等）。</td></tr>" +
			 "<tr><td>◎所指定之商品／服務名稱應具體明確，不得以概括性之語句，如「及不屬別類之一切商品／服務」或「及應屬本類之一切商品／服務」等字樣提出申請。</td></tr>" +
			 "<tr><td>◎無法得知商品／服務組群碼，可不必填寫。</td></tr>";
var ztextm = "<tr><td>◎請將申請變更之註冊號數、商標種類（將代碼填寫於□格內）及商標／標章名稱填入適當之欄位。</td></tr>";
var ztexte = "<tr><td>◎讀音：可用KK音標、注音、羅馬拼音或其他拼法填寫。</td></tr>";
var ztextg = "<tr><td>◎請填寫本件（再）授權他人使用之商品或服務名稱。</td></tr>";
var ztexti = "<tr><td>【註冊號數、商標或標章種類務必填寫正確，可參考註冊證所載之資料】</td></tr>" +
			 "<tr><td>前大陸註冊商標，請在註冊號數前，加英文M字母，例如：M3426。</td></tr>";
var ztextl = "<tr><td>◎證明標章權、團體標章權或團體商標權不得授權他人使用，但其（再）授權他人使用，無損害消費者利益及違反公平競爭之虞，經商標主管機關核准者，不在此限。（商標法第七十八條之規定）</td></tr>";
var ztextp = "<tr><td>◎依商標法第○○○條規定主張優先權者，請於優先權欄位載明在外國之申請日(換算為國曆日期)及受理該申請之國家；<font color=red>未於申請時提出聲明，喪失優先權</font>。</td>" +
			 "<tr><td>◎在與我國未訂有相互承認優先權之國家申請註冊之案件，依法不得為主張優先權之依據。</td>" +
			 "<tr><td>◎<font color=red>未附優先權證明文件者，請於申請日次日起三個月內檢送，逾期即喪失優先權</font>。</td>" +
			 "<tr><td>◎未主張優先權者，此處免填。</td></tr>";
var ztexts = "<tr><td>◎記號：如阿拉伯數字等。</td></tr>";
var ztextz = "<tr><td>◎語文別：依據圖樣中之語文別填寫，如英文、德文、日文、法文等。</td></tr>";
var ztext05 = "<tr><td>◎變更之註冊號數超過五件時，請加註ˇ記，並於附頁填寫其餘變更之註冊號數。</td></tr>";

var zAttech = "<tr><td>◎提出申請時，所附之附件，請於該項文件前□框格內打V註記。</td></tr>";
var zAttechd = "<tr><td>請務必就理由書內所述證據依序一一檢附，並簡短說明證據名稱及份數，欲取回證據(附件)者，請另裝一袋，並以V表示；申請書/理由書及其相關附</td></tr>" +
             "<tr><td>件皆須完整列印1份為副本，以便本局送對造答辯。</td></tr>" +
             "<tr><td>□附件1、異議/評定人公司年報正本及影本 各 1 份 </td></tr>" +
             "<tr><td>□附件2、異議/評定人在各國刊登廣告影本 計： 1 份 </td></tr>" +
             "<tr><td>□附件3、異議/評定人商品在台灣廣告及銷售額影本 計： 1 份 </td></tr>" +
             "<tr><td>                                             合計： 1 袋 </td></tr>";
var zatteche1 = "<tr><td>提出申請時，所附之附件，請於該項文件前□框格內打V註記。</td></tr>" +
			 "<tr><td>◎申請人之身分證明文件：</td></tr>" +
			 "<tr><td>　指法人、團體、政府機關依法設立登記之證明文件影本。</td></tr>" +
			 "<tr><td>◎申請人得為證明之資格或能力之文件：</td></tr>" +
			 "<tr><td>　指申請人本身之營業範圍、職掌、人員、組織、技術、設備、財務等，足以為證明之資格或能力。</td></tr>";

var zatteche2 = "<tr><td>　＊標示標章之條件：</td></tr>" +
			 "<tr><td>　　指要符合某種標準、水準、程度、品質、性質、產地等才可使用本證明標章。</td></tr>" +
			 "<tr><td>　＊控制標章使用之方式：</td></tr>" +
			 "<tr><td>　　指符合標示標章之條件，經核准者才可使用；定期及不定期檢查之方式；商品或服務經確認不符合標示條件者，不得再使用，及其他相關規定。</td></tr>" +
			 "<tr><td>◎申請人不以本標章從事商品之製造、行銷或服務提供之聲明書：</td></tr>" +
			 "<tr><td>　指申請人不得以相同或近似於商標、服務或團體商標／標章之圖樣申請註冊，若已申請註冊者，應自請撤銷。且申請人不得產銷或提供所證明之商品或服務，並應檢具聲明書聲明不以本標章從事商品之製造、行銷或服務提供，加蓋申請人及代表人章。</td></tr>";

var a1Eappl_name = "<tr><td>１、為提升審查資料之精確性及加速審查之效率，請務必填寫圖樣分析資料。</td> " +
			 "<tr><td>２、圖樣分析資料欄位，請依圖樣中所組成中文、外文、圖形或記號，一一填寫。</td>" +
		     ztextz + ztextc + ztexte + ztextd + ztexts + "</td></tr>";
var a1Rapcust = "<tr><td>◎請填寫被授權人之人名資料。</td>";
var a1Apcust = "<tr><td>◎請填寫本件專用權人之資料。人名資料填寫說明請詳參「貳、申請人（授權人）」</td></tr>";
var a1Term1 = "<tr><td>◎請分別依有明確起、迄日期或僅有起日而無明確迄日者勾選並填寫(再)授權期間之資料。◎再授權期間不得逾原授權期間（商標法施行細則第38條第5項之規定）</td>";
var a1Good = ztextg +
			 "<tr><td>◎授權使用之商品或服務，以商標權範圍為限。商標權人得就其所註冊之商品之全部或一部授權他人使用其商標。故授權使用商品之範圍應具體明確。</td></tr>";

var a2term1 = "<tr><td>◎再授權期間不得逾原授權期間。（商標法施行細則第二十九條第五項之規定）</td>" +
			 ztextl;
var a2Good = ztextg +
			 "<tr><td>◎再授權使用之商品或服務不得逾原授權使用商品或服務之範圍。（商標法施行細則第38條第5項之規定）。</td></tr>";

var a3Appl_name = "<TR><TD>◎商標／標章名稱應與所申請註冊之聲音商標／標章內容相符；商標／標章權以請准註冊之圖樣為限，商標／標章名稱不受商標法之保護。<font color=red>所載之商標／標章名稱，請以中文繁體字、英文或日文書寫</font>。</TD></TR>";
var a3Draw = "<tr><td>◎商標／標章圖樣應以樂譜（五線譜或簡譜）表示，無法以樂譜表示者，得以描述說明代之。故商標／標章圖樣得選擇樂譜（五線譜或簡譜）或單純以描述說明表示；以樂譜表示者，於「三、商標／標章圖樣描述」得為簡要描述說明；單純以描述說明表示者，於「三、商標／標章圖樣描述」應為詳細描述說明。</td>" +
             "<tr><td>◎虛線框內得黏貼聲音商標／標章之樂譜（五線譜或簡譜），樂譜得同時標示歌詞。</td>" +
             "<tr><td>◎商標／標章圖樣不論以樂譜（五線譜或簡譜）或單純以描述說明表示者，均應檢附載有本件聲音之.wav檔光碟片。</td></tr>";
var a3Good = ztextg0 + ztextg1 +
			 "<tr><td>◎格線可自行調整，惟不同類別間應空一行，以示區隔。</td></tr>" +
			 ztextg4;
var a3Remark1 = "<tr><td>◎商標／標章圖樣描述必須充分詳實，應足以使任何人閱讀後，均能得知本件聲音商標／標章之內容。</td>" +
			 "<tr><td>◎聲音或音樂得搭配文字，亦可不包括文字，其搭配文字部分，應於商標／標章圖樣描述欄中，詳實說明。</td>" +
			 "<tr><td>◎例如：（一）檢附樂譜者：本商標／標章如申請書所附之光碟片所載，係由女高音唱出申請書上所附之音符所構成。（二）未檢附樂譜單純以文字描述者：本件商標／標章如申請書所附之光碟片所載，係由牛走在石板路上的兩聲牛蹄聲，緊接著一聲牛叫聲所構成。</td></tr>";

var a4Appl_name = "<tr><td>◎商標／標章名稱應與所申請註冊之商標／標章圖樣相符；商標／標章權以請准註冊之商標／標章圖樣為限，商標／標章名稱不受商標法之保護。<font color=red>所載之商標／標章名稱，請以中文繁體字、英文或日文書寫。</font></td></tr>";
var a4Rapcust = "<tr><td>◎請填寫原授權使用人（被授權人）／終止再授權使用人（被授權人）之人名資料。</td></tr>";
var a4Term1 = "<tr><td>◎請填寫終止（再）授權之日期。</td></tr>";
var a4color = "<tr><td>◎商標圖樣全部為墨色者，應勾選墨色欄框；商標圖樣全部為彩色者或其中部分有彩色者，應勾選彩色欄框，如係顏色商標，請另填寫顏色商標註冊申請書辦理之。</td>" +
			 "<tr><td>◎圖樣應以實線將商品或其包裝、容器、設計外觀以立體圖表現出來，若為彩色者應於適當部分施以使用顏色；如特殊設計僅係產品或包裝容器一部分，應以虛線將商品實物描繪出來，並聲明該虛線之部分不專用。例如：立於汽車引擎蓋上之黑豹立體形狀，其汽車體部份應以虛線表示，黑豹立體形狀應以實線表示，並聲明該虛線之部分不專用。</td></tr>";
var a4Remark3M = "<tr><td>虛線框內請黏貼商標之主要立體圖樣一張，該立體圖樣應選擇最足以表現本商標圖樣之視圖。<font color=red>標章圖樣應清晰可辨，長、寬以五至八公分為標準</font>。</td></tr>";
var a4Remark3O = "<tr><td>◎虛線框計有六個，圖樣（一）主要立體圖，圖樣（二）～（六）請黏貼五張以下不同角度但相同比例之視圖或樣本。<font color=red>審查以黏貼之圖樣為準，務必正確</font>。</td>" +
		     "<tr><td>◎<font color=red>商標／標章圖樣應清晰可辨，長、寬以五至八公分為標準</font>，並以堅韌光潔之紙料為之（例如影印紙），請勿使用相片紙，以免褪色或無法黏貼於註冊證。</td>" +
		     "<tr><td>◎另請於附表「浮貼」商標／標章圖樣每張立體圖各一式五張，圖樣為彩色者，應附加浮貼每張立體圖各二張黑白（墨色）圖樣。</td></tr>";
var a4Remark1 = "<tr><td>一、請詳細說明立體商標實際使用於指定商品或服務之方式、位置、內容態樣，及申請註冊所欲保護的內容。</td>" +
		     "<tr><td>二、例如：（一）商品之形狀或其包裝容器者：本商標係由香水或古龍水之瓶子及瓶蓋之外型所構成，兩者從上往下看均有一個「Ｖ」字型。（二）非商品之形狀或其包裝容器者：本件商標如申請書所附之商標圖樣所示，係由公雞之立體形狀使用於汽車之車頂所構成，其中汽車形狀部分係以虛線描繪。</td></tr>";
var a4Good = "<tr><td>◎未填寫商品／服務名稱者，無法取得申請日。</td>" +
	 	     "<tr><td>◎類別欄中，請就商標及服務分類表第一至四十五類填寫，<font color=red>並得以一案多類商品或服務提出申請</font>。</td>" +
		     "<tr><td>◎請按商品及服務分類表之類別順序，<font color=red>依序</font>填寫組群代碼，並<font color=red>具體列舉</font>商品／服務名稱。</td>" +
			 "<tr><td>◎格線可自行調整，惟不同類別間應空一行，以示區隔。</td>" +
		     "<tr><td>◎商品或服務類別與名稱請參考商標法施行細則第○○○條規定及「商品及服務近似檢索參考資料」填寫。若所指定名稱倘非「商品及服務近似檢索參考資料」所載之名稱者，請檢送相關說明資料以供審酌。（如：型錄、說明書、照片、樣品等）。</td>" +
		     "<tr><td>◎所指定之商品／服務名稱應具體明確，不得以概括性之語句，如「及不屬別類之一切商品／服務」或「及應屬本類之一切商品／服務」等字樣提出申請。</td>" +
			 "<tr><td>◎無法得知商品／服務組群碼，可不必填寫。</td></tr>";

var a5Rapcust = "<tr><td>◎請填寫原質權人之人名資料。</td></tr>"
var a5Term1 = "<tr><td>◎請填寫塗銷質權之日期。</td></tr>";
var a5Attech = zAttech +
			 "<tr><td>◎申請人具法人資格之身分證明文件：</td>" +
			 "<tr><td>指向中央或地方主管機關立案登記並依法向該管法院辦理法人登記之法人登記證書影本。</td>" +
			 "<tr><td>◎(顏色)團體商標使用規範書，應載明：</td>" +
			 "<tr><td>＊申請人成員資格：</td>" +
			 "<tr><td>　指團體之組織章程等有規範加入團體成為成員資格之要件。</td>" +
			 "<tr><td>＊控制(顏色)團體商標之使用方式：</td>" +
			 "<tr><td>　如正式入會後才可使用；停權或違反團體規定時不得使用；退會或開除會籍時不得使用；違反使用規定如何處罰等。</td></tr>";
var a7Remark1 = "<tr><td>◎商標／標章圖樣描述必須充分詳實，應足以使任何人閱讀後，均能得知本件聲音商標／標章之內容。</td>" +
			 "<tr><td>◎聲音或音樂得搭配文字，亦可不包括文字，其搭配文字部分，應於商標／標章圖樣描述欄中，詳實說明。</td>" +
			 "<tr><td>◎例如：（一）檢附樂譜者：本商標／標章如申請書所附之光碟片所載，係由女高音唱出申請書上所附之音符所構成。（二）未檢附樂譜單純以文字描述者：本件商標／標章如申請書所附之光碟片所載，係由兩聲牛走在柏油路上的牛蹄聲，緊接著一聲牛叫聲所構成。</td></tr>";
var a9color = "<tr><td>◎標章圖樣全部為墨色者，應勾選墨色欄框；標章圖樣全部為彩色者或其中部分有彩色者，應勾選彩色欄框），如係顏色團體標章／顏色商標，請另填寫顏色團體標章／顏色商標註冊申請書辦理之。</td></tr>";

var aaRemark1 = "<tr><td>商標法施行細則第九條規定：申請註冊顏色團體／証明標章者，應於申請書中聲明，並載明該顏色及相關說明。前項標章，得以虛線表現實際使用之方式、位置或內容態樣。前項虛線部分，不屬於顏色(証明)商標／標章之一部分。</td>" +
			 "<tr><td>◎請詳細填寫顏色(証明)標章實際使用於所証明商品或服務之態樣（如顏色實際標示之特殊方式、位置、內容；亦得以實物、照片或型錄為說明）以及實際顏色（如色彩種類、明度、漸層等）之說明。</td></tr>";

var acColor = "<tr><td>◎標章圖樣全部為墨色者，應勾選墨色欄框；標章圖樣全部為彩色者或其中部分有彩色者，應勾選彩色欄框，如係顏色標章，請另填寫顏色標章註冊申請書辦理之。</td></tr>" +
			 "<tr><td>◎圖樣應以實線將設計外觀以立體圖表現出來，若為彩色者應於適當部分施以使用顏色；如特殊設計僅係實物之一部分，應將特殊設計以實線描繪出來，以虛線將該實物描繪出來，並聲明該虛線之部分不專用。例如：立於地球儀之獅子立體形狀，獅子及地球儀之立體形狀應以實線表示。</td></tr>";
var acRemark1 = "<tr><td>◎請詳細說明立體標章實際使用於表彰組織或會籍之方式、位置、內容態樣，及申請註冊所欲保護的內容。例如：本件標章如申請書所附之標章圖樣所示，係由兩隻獅子立於地球儀之外型所構成。</td></tr>";
var aeAttech = zatteche1 +
			 "<tr><td>◎請以書面檢附標示標章條件及控制標章使用方式。</td></tr>" +
			 "<tr><td>　＊標示標章之條件：</td></tr>" +
			 "<tr><td>　　指要符合某種標準、水準、程度、品質、性質、產地等才可使用本證明標章。</td></tr>" +
			 "<tr><td>　＊控制標章使用之方式：</td></tr>" +
			 "<tr><td>　　指符合標示標章之條件，經核准者才可使用；定期及不定期檢查之方式；商品或服務經確認不符合標示條件者，不得再使用，及其他相關規定。</td></tr>" +
			 "<tr><td>◎申請人不以本標章從事商品之製造、行銷或服務提供之聲明書：</td></tr>" +
			 "<tr><td>　指申請人不得以相同或近似於顏色商標、商標、或團體商標之圖樣申請註冊，若已申請註冊者，應自請撤銷。且申請人不得產銷或提供所證明之商品或服務，並應檢具聲明書聲明不以本標章從事商品之製造、行銷或服務提供，加蓋申請人及代表人章。</td></tr>";
var afAttech = zatteche1 +
			 "<tr><td>◎標章標示條件及控制標章使用方式：請以書面檢附</td></tr>" +
			 zatteche2;
var agRemark1 = "<tr><td>◎請詳細說明立體標章實際使用於證明內容之方式、位置、內容態樣，及申請註冊所欲保護的內容。例如：本件標章如申請書所附之標章圖樣所示，係由兩隻獅子立於地球儀之外型所構成。</td></tr>";
var aiRemark1 = "<tr><td>◎請詳細說明全像圖商標實際使用於指定商品或服務之顏色、方式、位置或內容態樣，及申請註冊所欲保護的內容。若全像圖因視角差異產生不同圖像變化時，應說明該變化情形。</td></tr>" +
             "<tr><td>◎商標樣本，指商標本身之樣品或存載商標之電子載體。全像圖商標樣本，指商標本身之樣品，如實際使用之全像圖，以輔助商標圖樣之審查。</td></tr>";
var ajRemark1 = "<tr><td>◎請詳細說明動態商標實際使用於指定商品或服務之顏色、方式、位置或內容態樣，及申請註冊所欲保護的內容。</td></tr>" +
             "<tr><td>◎商標樣本，指商標本身之樣品或存載商標之電子載體。動態商標樣本，指存載動態商標的電子載體等，以輔助商標圖樣之審查。</td></tr>"
var akRemark1 = "<tr><td>◎請詳細說明其他非傳統商標實際使用於指定商品或服務之顏色、方式、位置或內容態樣，及申請註冊所欲保護的內容。</td></tr>" +
             "<tr><td>◎商標樣本，指商標本身之樣品或存載商標之電子載體。其他商標樣本，指商標本身之樣品，如實際使用之樣品；存載商標的電子載體等，如存載影像或聲音之光碟片等，以輔助商標圖樣之審查。</td></tr>"

var b1Rapcust = "<tr><td>◎請填寫質權人之人名資料。</td></tr>" +
			 "<tr><td>◎質權人之質權設定如有清償順位時，請於質權人名稱後加註清償順位。</td></tr>";
var b1Remark1 = "<tr><td>請寫出其他防護商標（其正商標號數為本件註冊號數）與本件一併辦理設定質權者。</td></tr>"
var b1Remark2 = "<tr><td>請寫出其他防護商標號數（其正商標號數為本件註冊號數），並沒有與本件一併辦理設定質權者。</td></tr>" +
			 "<tr><td>防護商標未與正商標一併設定質權者，將來債務屆期未清償，設定質權之商標遭查封拍賣後，防護商標未與正商標一併拍賣移轉者，其商標權恐有消滅之虞。防護商標單獨移轉者，其移轉無效。（舊商標法第二十九條之規定）</td></tr>";
var b1Term1 = "<tr><td>請填寫設定質權起迄日期，質權設定期間，以商標權期間為限，所約定質權設定設定期間超過商標權期間者，以商標權期間屆滿日為質權期間之末日，商標權期間如經延展註冊，應另行申請質權登記。（商標法施行細則第二十三條第三項之規定）</td></tr>";
var b1Money = "<tr><td>設定質權之債權額度須明定其債權擔保之金額數目及貨幣單位，並與商標設定質權契約書所載者相同。</td></tr>";

var c1Rapcust = "<tr><td>◎請填寫讓與人〈移轉前原商標權人〉之人名資料。</td></tr>" +
			 "<tr><td>◎可參考註冊證所載之資料填寫。</td></tr>";
var c1Remark1 = "<tr><td>◎請寫出其他防護商標號數（其正商標號數為本件註冊號數）與本件一併辦理移轉者。</td></tr>" +
			 "<tr><td>◎防護商標單獨移轉者，其移轉無效。</td></tr>" +
			 "<tr><td>◎證明標章權、團體標章權或團體商標權不得移轉。但其移轉無損害消費者利益及違反公平競爭之虞，經商標專責機關核准者，不在此限。（商標法第七十八條規定）</td></tr>";
var c1Remark2 = "<tr><td>◎請寫出其他防護商標號數（其正商標號數為本件註冊號數），並沒有與本件一併辦理移轉者。</td></tr>" +
			 "<tr><td>◎防護商標未與正商標一併移轉者，其商標權消滅。</td></tr>" +
			 "<tr><td>◎如係正商標不一併移轉，應另案辦理正商標註冊自撤，本件防護商標並須另案辦理商標種類變更。</td></tr>";
var c1appl_name = "<tr><td>請將註冊申請案號、商標／標章名稱及商標種類填入適當之欄位。</td>" +
			 "<tr><td>【註冊申請案號、商標／標章名稱及商標種類務必填寫正確】</td></tr>";
var c1mod = "<tr><td>請將欲變更之事項填入適當之欄位。</td>" +
			 "<tr><td>（九十年十二月十四日起，單以變更申請人或代理人地址者，無庸繳交變更規費）</td></tr>";

var c1Oapcust = "<tr><td>註冊申請案變更之性質，如果屬於原申請人權利讓與，請填寫原註冊申請案之申請人資料，以利審核。如果不是權利之讓與，本項資料不用填寫。</td></tr>";

var c2appl_name = ztextm + ztext05 + ztexti;

var c2apcust = "<tr><td>本「申請人」欄，請填寫變更後之申請人資料。若申請人並未變更，僅變更本註冊號數委任的新代理人，第二點之申請人各項資料亦均須填寫。</td>" +
			 "<tr><td>第一點：</td>" +
			 "<tr><td>註冊變更申請書，是提供商標（標章）權人、被授權人、再被授權人或質權人之資料變更使用，請選擇其一勾選。</td>" +
			 "<tr><td>第二點：</td>" +
			 "<tr><td>１、公司、行號、工廠、身分證<font color=red>統一編號欄：【務必填寫正確】</font></td>" +
			 "<tr><td>公司、行號、工廠請填營利事業登記證之統一編號，本國人請填身分證之統一編號，外國法人、外國人免填。</td>" +
			 "<tr><td>２、名稱或姓名（中文）／（英文）欄：</td>" +
		 	 "<tr><td>◎申請人不論為本國人或外國人均請填寫中、英文名稱<font color=red>【中文名稱請用正楷繁體字書寫】</font>，外國自然人或法人之<font color=red>外文請統一以英文填寫</font>。</td>" +
			 "<tr><td>◎書寫外國人名稱，請於名稱前加註國名別，例如：美商、日商、西班牙商。</td>" +
			 "<tr><td>◎大陸地區申請人名稱，請於名稱前加註「大陸地區」。</td>" +
			 "<tr><td>◎香港地區申請人名稱，請於名稱前加註「香港」。</td>" +
			 "<tr><td>◎澳門地區申請人名稱，請於名稱前加註「澳門」。</td>" +
			 "<tr><td>３、<font color=red>本國申請人中文地址請務必填寫郵遞區號</font>，英文地址免填。</td>";
var c2Other = "<tr><td>請於變更事項前之框格內□，以英文字母「v」選填。</td>" +
			 "<tr><td>變更商標／標章名稱之情況，</td>" +
			 "<tr><td>例如：</td>" +
			 "<tr><td>商標權人原為大力有限公司，註冊之商標名稱為：大力有限公司標章。</td>" +
			 "<tr><td>註冊變更後(公司更名)，</td>" +
			 "<tr><td>商標權人變更為特力股份有限公司，註冊之商標名稱變更為：特力股份有限公司標章</td></tr>";
var c21appl_name = "<tr><td>◎本書表供同一人有二以上已註冊商標，其變更事項相同者，同時申請變更時使用。</td></tr>" +
			 ztextm + ztext05 + ztexti;


var c3appl_name = "<tr><td>請將申請減縮之註冊號數、商標（標章）種類及商標／標章名稱填入適當之欄位。</td></tr>" +
			 ztexti;

var c4Appl_name = "<tr><td>請將申請變更之註冊號數、商標（標章）種類及商標／標章名稱填入適當之欄位。</td>" +
			 ztexti;

var d1apply_no = "<tr><td>◎請將分割前之原註冊申請案號、商標／標章名稱、商標種類、分割件數填入適當之欄位。</td></tr>" +
			 "<tr><td>◎請務必註明分割為幾件，俾便後續之審理。</td></tr>";
var d1class = "<tr><td>◎請就原申請案中所指定之商品／服務內容，依分割之情況，按商品及服務分類表之類別順序，依序填寫組群代碼，並具體列舉商品／服務名稱。</td></tr>" +
			 "<tr><td>◎申請分割不受商品組群或類別之限制，同一商品組群、同一類別亦可辦理分割之申請。</td></tr>";
var d1tran_remark = "<tr><td>◎若申請中商標／團體商標／證明標章分割註冊申請案件，需俟相關異議／評定／移轉／變更案／延展案確定後，再行審理者，請於備註欄以英文字母「V」於  內勾選，並填寫其相關申請或註冊號數。</td></tr>";
var d1attech = zAttech +
			 "<tr><td>◎分割申請書副本。例如分割為二件者，請檢送副本二份；如分割為三件者，請檢送副本三份，依此類推。</td></tr>" +
			 "<tr><td>◎分割後之商標／團體商標／證明標章註冊申請書正本及其申請商標註冊之相關文件。例如分割為二件者，應按分割後之商品／服務，分別檢送商標註冊申請書正本各一份，依此類推。</td></tr>";

var d2Issue_no = "<tr><td>◎請將原註冊號數／原註冊申請案號、商標／標章名稱、商標種類、分割件數填入適當之欄位。</tr></td>" +
			 "<tr><td>◎核准審定後註冊公告前之分割申請案，請填原註冊申請案號。</tr></td>" +
			 "<tr><td>◎已註冊之商標／團體商標／證明標章之分割申請案、被異議或評定之已註冊商標／團體商標／證明標章之分割申請案，請填註冊號數。</tr></td>" +
			 "<tr><td>◎請務必註明分割為幾件，俾便後續之審理。</tr></td>" +
			 "<tr><td>◎商標法施行細則第二十二條規定：核准審定後註冊公告前申請分割註冊申請案者，商標專責機關應於申請人繳納註冊費，商標經註冊公告後，再進行分割。</tr></td>";
var d2Class = "<tr><td>◎請就原核准審定後註冊公告前、已註冊之商標權／團體商標權／證明標章權、被異議或評定之已註冊商標權／團體商標權／證明標章權所指定之商品／服務內容，依分割之情況，按商品及服務分類表之類別順序，依序填寫組群代碼，並具體列舉商品／服務名稱。</td>" +
			 "<tr><td>◎申請分割不受商品組群或類別之限制，同一商品組群、同一類別亦可辦理分割之申請。</td></tr>";
var d2Tran_remark = "<tr><td>◎核准審定後註冊公告前之分割申請案件、已註冊之商標權／團體商標權／證明標章權之分割申請案件、被異議或評定之已註冊商標權／團體商標權／證明標章權之分割申請案件，需俟相關異議／評定／移轉／變更案／延展案確定後，再行審理者，請於備註欄以英文字母「V」於  內勾選，並填寫其相關申請或註冊號數。</tr></td>";
var d2Attech = Zattech +
			 "<tr><td>◎分割申請書副本。例如分割為二件者，則請檢送副本二份；如分割為三件者，則請檢送副本三份，依此類推。（每份分割申請書副本，應浮貼商標圖樣五張，圖樣為彩色，應另檢附黑白圖樣二張）</tr></td>";

var e1Class = "<tr><td>◎請於書表標題□框格內勾選申請之中文或英文證明書。＊書表左上方之英文字母Ｐ代表申請中文證明書；Ｍ代表申請英文證明書。</td></tr>" +
			 "<tr><td>◎請將申請、審定或註冊號數、商標（標章）種類及商標／標章名稱填入適當之欄位。<font color=red>【註冊號數、商標或標章種類務必填寫正確，可參考註冊證所載之資料】</font></td></tr>" +
			 "<tr><td>◎<font color=red>前大陸註冊商標，請在註冊號數前，加英文M字母或前商標局核准註冊字樣，例如：M3426。</font></td></tr>"
var e1Term1 = "<tr><td>◎商標權期間：已註冊者，請以中、英文繕寫商標權起迄日期，英文繕寫請依序註明月、日、年，例如：from Jan.1, 2001  to Dec. 31, 2010</td></tr>" +
			 "<tr><td>◎申請註冊日期：已註冊或申請中者，請以中、英文繕寫原商標申請註冊日期，英文繕寫請依序註明月、日、年，例如：Apr. 15, 2000</td></tr>" +
			 "<tr><td>◎申請中文證明書者，英文欄位部分免填。</td></tr>";
var e1Good = "<tr><td>◎請書寫原註冊時之商標法施行細則條款及商品或服務類別。</td></tr>" +
			 "<tr><td>◎商品（服務）名稱：請書寫最新資料。例如經延展核准商品（服務）名稱異動時，填寫核准延展後之商品（服務）名稱。</td></tr>";
var e1Draw = "<tr><td>◎每份英文證明書請浮貼兩張圖樣。</td></tr>" +
			 "<tr><td>◎已註冊者，浮貼之圖樣需與原註冊時之顏色及式樣相同。</td></tr>" +
			 "<tr><td>◎申請中者，浮貼之圖樣需與原申請時之顏色及式樣相同。</td></tr>";

var foBAppl_name = "<tr><td>請將申請影印之申請號數、註冊號數或核駁號數、商標種類及商標／標章名稱填入適當之欄位。</td></tr>" +
			 "<tr><td>【註冊號數、商標或標章種類務必填寫正確，已註冊者可參考註冊證所載之資料】</td></tr>" +
			 "<tr><td>前大陸註冊商標，請在註冊號數前，加註「前商標局」或加註英文M字母，例如：M3426。</td></tr>";
var foBattech = "<tr><td>請於該項文件前□框格內打V註記。</td></tr>";

var g4Color = "<tr><td>◎標章圖樣全部為墨色者，應勾選墨色欄框；標章圖樣全部為彩色者或其中部分有彩色者，應勾選彩色欄框，如係顏色標章，請另填寫顏色標章註冊申請書辦理之。</td>" +
			 "<tr><td>◎圖樣應以實線將設計外觀以立體圖表現出來，若為彩色者應於適當部分施以使用顏色；如特殊設計僅係實物之一部分，應將特殊設計以實線描繪出來，以虛線將該實物描繪出來，並聲明該虛線之部分不專用。例如：立於地球儀之獅子立體形狀，獅子及地球儀之立體形狀應以實線表示。</td></tr>";

var h1Appl_name = "<tr><td>請將申請設定質權登記之註冊號數、商標種類及商標名稱填入適當之欄位。</td></tr>" +
			 ztexti;
var h1Rapcust = "<tr><td>◎請填寫質權人之人名資料。</td></tr>" +
			 "<tr><td>◎人名資料填寫說明請詳參「貳、申請人（商標權人）」。</td></tr>" +
			 "<tr><td>◎質權人之質權設定如有清償順位時，請於質權人名稱後加註清償順位。</td></tr>";
var h1Term1 = "<tr><td>請填寫質權消滅之日期。</td></tr>";

var i1Appl_name = "<tr><td>請將補（換）發之註冊號數、商標（標章）種類及商標／標章名稱填入適當之欄位。 </TD>" +
		     "<tr><td>【註冊號數、商標或標章種類務必填寫正確，可參考註冊證所載之資料】</td></tr>" +
			 "<tr><td>前大陸註冊商標，請在註冊號數前，加英文M字母或前商標局核准註冊字樣，例如：M3426。</td></tr>";

var i1new_no = ztextd3 +
			 "<tr><td>二、對本件評定標的（註冊號數）指定使用全部類別之商品或服務提出其註冊應予撤銷之聲明者，請勾選第一空格欄。</td></tr>" +
			 "<tr><td>三、依商標法第62條準用第48條第2項規定，評定得就註冊商標指定使用之部分商品或服務為之。</td></tr>" +
			 "<tr><td>　　1、就註冊商標（評定標的）指定使用部分類別之全部商品或服務提出評定聲明者，請勾選第二空格欄。</td></tr>" +
			 "<tr><td>　　2、就註冊商標（評定標的）指定使用部分類別之部分商品或服務提出評定聲明者，請勾選第三空格欄。若兩類以上之部分商品或服務提出評定聲明者，請自行增列。</td></tr>";
var i1other_item = "<tr><td>申請評定人另提起之相同或類似案情，或另繫屬之相關聯案件之申請日期、案由及註冊／申請號數，請務必詳盡填寫。</td></tr>" +
			 ztextd7 +
			 "<tr><td>　　　與八十九年二月十五日註冊第00556666號商標申請評定案有關</td></tr>";

var i1other_item1 = "<tr><td>一、書寫主張之商標法法條。</td></tr>" +
			 "<tr><td>　　例如：認為本件註冊標的僅為描述所指定商品或服務之品質、用途、原料、產地或相關特性之說明者。</td></tr>" +
			 "<tr><td>　　　　　請填寫主張法條為：商標法第29條第1項第1款。</td></tr>" +
			 "<tr><td>二、據以評定商標／標章業已於本局申請註冊者，請務必依序一一詳載申請或註冊號數，以免延宕本案之審理。（請先填寫主張法條，再依序填寫據以評定商標／標章號數）</td></tr>" +
			 "<tr><td>　　例如：商標法第30條第1項第10款</td></tr>" +
			 "<tr><td>　　　　　註冊第1023456號商標</td></tr>" +
			 "<tr><td>　　　　　商標法第30條第1項第11款</td></tr>" +
			 "<tr><td>　　　　　註冊第1023456、10234566、10234567號商標</td></tr>";
var i1tran_remark1 = "<tr><td>請敘明事實及理由，並注意以下5點：</td></tr>" +
			 "<tr><td>一、申請評定人具利害關係人身分之事實及理由：</td></tr>" +
			 "<tr><td>    依商標法第57條規定，請首先論述被申請評定商標之註冊對申請評定人之權利或利益有何影響關係，並檢附相關證據資料。利害關係之判斷，請參考商標法利害關係人認定要點。</td></tr>" +
			 "<tr><td>二、本案事實及理由：</td></tr>" +
			 "<tr><td>  ◎請具體說明被評定之註冊商標，係違反何商標法條款及其原因事實。</td></tr>" +
			 "<tr><td>  ◎主張法條為商標法第30條第1項第10款且據以評定商標註冊已滿3年者使用者，</td></tr>" +
			 "<tr><td>    依商標法第57條規定，應檢附於申請評定前3年有使用據以主張商品或服務之證據，</td></tr>" +
			 "<tr><td>    或其未使用有正當事由之事證。務請具體說明據以評定商標使用情形。</td></tr>" +
			 ztextd5 + ztextd6 +
			 "<tr><td>五、本欄位不敷使用時，請以加續頁方式附於本頁之後。</td></tr>";

var l1Appl_name = "<tr><td>請將申請（再）授權登記之註冊號數、商標（標章）種類及商標／標章名稱填入適當之欄位。</td>" +
			 ztexti;
var l1Apcust = "<tr><td><font color=red>請務必於授權人(商標權人)或被授權人欄位之 □ 內勾選</font>，以指明係由授權人(商標權人)或被授權人提出申請。</td></tr>";

var l2_New_no = "<tr><td>◎請填寫本件商標權人之資料。</td></tr>";

var l3Appl_name = "<tr><td>請將申請終止（再）授權登記之註冊號數、商標（標章）種類及商標／標章名稱填入適當之欄位。</td>" +
			 ztexti;

var m5Good1 = "<tr><td>◎第肆項欄位，請填寫欲減縮專用範圍之商品（服務）名稱。所擬減縮之商品(服務)，應在專用權範圍之內。</td></tr>" +
			 "<tr><td>◎請填寫清楚類別及商品及服務名稱。</td></tr>";
var m5Good2 = "<tr><td>◎第伍項欄位，請填寫減縮後專用範圍之商品（服務）名稱。所減縮後之商品或服務應具體明確，且不能超過原專用權範圍。</td></tr>" +
			 "<tr><td>◎請填寫清楚類別及商品及服務名稱。</td></tr>";

var n1Mark = "<tr><td>◎請於□框格內勾選申請之中文或英文證明書。</td></tr>";
var n1Appl_name = "<tr><td>◎請將申請、註冊號數、商標（標章）種類及商標／標章名稱填入適當之欄位。</td></tr>" +
			 ztexti;
var o1Appl_name = ztextd1 + ztextd2;
var o1Rapcust = "<tr><td>請填寫被異議／註冊人之名稱或姓名、地址，有代理人者，其姓名資料。</td></tr>";
var o1new_no = ztextd3 +
			 "<tr><td>二、對本件異議標的指定使用全部類別之商品或服務提出異議聲明者，請勾選第一空格欄。</td></tr>" +
			 "<tr><td>三、依商標法第48條第2項規定，異議得就註冊商標指定使用之部分商品或服務為之。</td></tr>" +
			 "<tr><td>　　1、就註冊商標（異議標的）指定使用部分類別之全部商品或服務提出異議聲明者，請勾選第二空格欄。</td></tr>" +
			 "<tr><td>　　2、就註冊商標（異議標的）指定使用部分類別之部分商品或服務提出異議聲明者，請勾選第三空格欄。若兩類以上之部分商品或服務提出異議聲明者，請自行增列。</td></tr>";
var o1Other_item = "<tr><td>異議人另提起之相同或類似案情，或另繫屬之相關聯案件之申請日期、案由及註冊號數，請務必詳盡填寫。</td></tr>";

var o1Other_item1 = "<tr><td>一、書寫主張之商標法法條。</td></tr>" +
			 "<tr><td>　　例如：認為本件註冊標的僅為描述所指定商品或服務之品質、用途、原料、產地或相關特性之說明者。</td></tr>" +
			 "<tr><td>　　　　　請填寫主張法條為：商標法第29條第1項第1款。</td></tr>" +
			 "<tr><td>二、據以異議商標／標章業已於本局申請註冊者，請務必一一詳載申請或註冊號數，以免延宕本案之審理。（請先填寫主張法條，再依序填寫據以異議商標／標章號數）</td></tr>" +
			 "<tr><td>　　例如：商標法第30條第1項第10款</td></tr>" +
			 "<tr><td>　　　　　註冊第1023456號商標</td></tr>" +
			 "<tr><td>　　　　　商標法第30條第1項第11款</td></tr>" +
			 "<tr><td>　　　　　註冊第1023456、10234566、10234567號商標</td></tr>";
var o1tran_remark1 = "<tr><td>請敘明事實及理由，並注意以下三點：</td></tr>" +
			 "<tr><td>一、依商標法第48條規定，商標之註冊違反第29條第1項、第30條第1項或第65條第3項規定之情形者，任何人得自商標註冊公告日後三個月內，向商標專責機關提出異議。</td></tr>" +
			 "<tr><td>二、類似商品及服務，請參考本局編輯之「商品及服務分類暨相互檢索參考資料」。</td></tr>" +
			 "<tr><td>三、所謂「著名之商標或標章」，係指有客觀證據足以認定該商標或標章已廣為相關事業或消費者所普遍認知者而言，主張據以異議／評定商標／標章係著名商標／標章者，請參考「商標法第30條第1項著名商標保護審查基準」，並檢附相關著名商標／標章證據資料。</td></tr>";


var p1Appl_name = "<tr><td>◎商標／標章名稱應與所申請註冊之商標／標章圖樣相符；商標／標章權以請准註冊之商標／標章圖樣為限，未載入圖樣中之商標／標章名稱，不受商標法之保護。<font color=red>所載之商標／標章名稱，請以中文繁體字、英文或日文書寫。</font></td></tr>";
var p1Oappl_name = "<tr><td>◎商標法第十九條規定：商標包含說明性或不具識別性之文字、圖形、記號、顏色或立體形狀，若刪除該部分則失其商標圖樣之完整性，而經申請人聲明該部分不在專用之列者，得以該商標申請註冊。但應聲明該部分與整體圖樣分離時，不單獨主張專用權。</td>" +
             "<tr><td>◎商標／標章圖樣中之文字、圖形、記號、顏色或立體形狀，符合前述規定者，請填寫於：商標／標章圖樣中之「  」不單獨主張專用權。</td></tr>";
var p1Color = "<tr><td>◎商標圖樣全部為墨色者，應勾選墨色欄框；商標圖樣全部為彩色者或其中部分有彩色者，應勾選彩色欄框，如係<font color=red>顏色(團體)商標，請另填寫顏色(團體)商標註冊申請書辦理之</font>。</td></tr>";
var p1Good = "<TR><TD><font color=red>◎商標註冊申請書未載明指定使用之商品或服務名稱者，以其補正齊備之日為申請日。</font></td></tr>" +
			 ztextg1 + ztextg3 + ztextg2;

var p1Pul = "<TR><TD>◎凡首次申請商標註冊者，應勾選「正商標」。</td>" +
             "<tr><td>◎第二次以後申請商標註冊者，與申請在先之正商標之圖樣相同，且指定使用之商品類似，或與申請再先之正商標之圖樣近似，且指定使之商品相同或類似時，請勾選「聯合商標」，並填寫正商標／標章之商標種類、註冊號數、名稱及商品或服務類別。</td>" +
             "<tr><td>◎第二次以後申請商標註冊者，與申請在先之正商標之圖樣相同，但指定使用之商品非相同或非類似而性質上相關聯時，得申請註冊為防護商標。請勾選「防護商標」，並填寫正商標／標章之商標種類、註冊號數、名稱及或服務類別。防護商標如為著名商標者，不受商品性質相關聯之限制，請依「著名商標或標章認定要點」辦理。</TD>" +
             "<tr><td>◎正、聯合或防護商標同日申請案件，聯合或防護商標案件中【正商標／標章號數】欄位，請填寫正商標申請號數或「同日申請」字樣。</td></tr>";

var p2Good = ztextg0 + ztextg1 +
			 "<tr><td><font color=red>◎商品類別與名稱，請參考商標法施行細則第○○○條規定及「商品及服務類似組群參考資料」填寫。</font>商品名稱若不是「商品及服務類似組群參考資料」所載之名稱者，請檢送商品型錄及商品功能或材質等相關說明資料供審酌。</td></tr>" +
			 ztextg2;

var p2Pul = "<TR><TD>◎凡首次申請服務標章註冊者，應勾選「正服務標章」。</td>" +
             "<tr><td>◎第二次以後申請服務標章註冊者，與申請在先之正服務標章之圖樣相同，且指定使用之服務類似，或與申請再先之正服務標章之圖樣近似，且指定使之服務相同或類似時，請勾選「聯合服務標章」，並填寫正商標／標章之商標種類、註冊號數、名稱及商品或服務類別。</td>" +
             "<tr><td>◎第二次以後申請服務標章註冊者，與申請在先之正服務標章之圖樣相同，但指定使用之服務非相同或非類似而性質上相關聯時，得申請註冊為防護服務標章。請勾選「防護服務標章」，並填寫正商標／標章之商標種類、註冊號數、名稱及或服務類別。防護服務標章如為著名商標者，不受商品性質相關聯之限制，請依「著名商標或標章認定要點」辦理。</TD>" +
             "<tr><td>◎正、聯合或防護服務標章同日申請案件，聯合或防護服務標章案件中【正商標／標章號數】欄位，請填寫正服務標章申請號數或「同日申請」字樣。</td></tr>";

var p3Appl_name = "<tr><td>◎商標／標章名稱應與所申請註冊之聲音商標／標章內容相符；商標／標章權以請准註冊之圖樣為限，商標／標章名稱不受商標法之保護。<font color=red>所載之商標／標章名稱，請以中文繁體字、英文或日文書寫。</font></td></tr>";
var p3Good = "<TR><TD>商標法第○○○條規定：團體標章之使用，指為表彰團體或其會員身分，而由團體或其會員將標章標示於相關物品或文書上。</td>" +
			 "<tr><td>◎團體標章表彰內容為：表彰申請人之組織或會員之會籍。</td>" +
			 "<tr><td>　例如：申請人如為中華民國全國工業總會時，寫「表彰中華民國全國工業總會之組織或會員之會籍」；</td>" +
			 "<tr><td>　例如：中華民國信用合作社聯合社時，寫「表彰中華民國信用合作社聯合社之組織或社員之社籍」。</td></tr>";
var p3Attech = zAttech +
			 "<tr><td>◎申請人具法人資格之身分證明文件：</td>" +
			 "<tr><td>指向中央或地方主管機關立案登記並依法向該管法院辦理法人登記之法人登記證書影本。</td>" +
			 "<tr><td>◎（團體）標章使用規範書，應載明：</td>" +
			 "<tr><td>＊申請人成員資格：</td>" +
			 "<tr><td>　指團體之組織章程等有規範加入團體成為成員資格之要件。</td>" +
			 "<tr><td>＊控制團體標章之使用方式：</td>" +
			 "<tr><td>　如正式入會後才可使用；停權或違反團體規定時不得使用；退會或開除會籍時不得使用；違反使用規定如何處罰等。</td></tr>";

var p4Good = "<tr><td>商標法第○○○條規定：證明標章之使用，指證明標章權人為證明他人商品或服務之特性、品質、精密度、產地或其他事項之意思，同意其於商品或服務之相關物品或文書上，標示該證明標章者。</td></tr>" +
			 "<tr><td>◎證明標的：商品或服務請於□勾選其一表示。</td></tr>" +
			 "<tr><td>◎證明標章表彰之內容：例如</td></tr>" +
			 "<tr><td>　＊證明有機農產品（含穀類、豆類、茶葉、蔬果、水果、保健植物、藻類、水產品、肉品、奶品、蛋品等）及其各類加工食品符合本協會「中華有機農業實施準則」之標準。</td></tr>" +
			 "<tr><td>　＊證明豬肉製品的包裝和經銷符合美國國家豬肉製造者協會所製定之標準。</td></tr>" +
			 "<tr><td>　＊證明產品中之黏核桃係產於美國加利福尼亞州，並證明美國加利福尼亞州黏核桃及混合水果皆依申請人制定之品質標準於加利福尼亞州包裝。</td></tr>" +
			 "<tr><td>　＊證明提供之商業管理服務，符合加拿大標準協會之標準。</td></tr>";
var p4Attech = zatteche1 +
			 "<tr><td>◎標章使用規範書：請以書面檢附，內容應包括</td></tr>" +
			 zatteche2;

var p5Smark = "<tr><td>◎請於書表標題勾選申請顏色組合□商標或□服務標章。</td></tr>";
var p5Pul = "<TR><TD>◎凡首次申請商標／服務標章註冊者，應勾選「正商標／標章」。</td>" +
             "<tr><td>◎第二次以後申請商標／服務標章註冊者，與申請在先之正商標／服務標章之圖樣相同，且指定使用之商品或服務類似，或與申請再先之正商標／服務標章之圖樣近似，且指定使之商品或服務相同或類似時，請勾選「聯合商標／標章」，並填寫正商標／標章之商標種類、註冊號數、名稱及商品或服務類別。</td>" +
             "<tr><td>◎第二次以後申請商標／服務標章註冊者，與申請在先之正商標／服務標章之圖樣相同，但指定使用之商品或服務非相同或非類似而性質上相關聯時，得申請註冊為防護商標／標章。請勾選「防護商標／標章」，並填寫正商標／標章之商標種類、註冊號數、名稱及或服務類別。防護商標／標章如為著名商標者，不受商品性質相關聯之限制，請依「著名商標或標章認定要點」辦理。</TD>" +
             "<tr><td>◎正、聯合或防護商標／標章同日申請案件，聯合或防護商標／標章案件中【正商標／標章號數】欄位，請填寫正商標／標章申請號數或「同日申請」字樣。</td></tr>";
var p5Appl_name = "<tr><td>◎商標／標章名稱應與所申請註冊之標章圖樣相符；商標／標章專用權以請准註冊之圖樣為限，未載入圖樣中之商標／標章名稱，不受商標法之保護。<font color=red>所載之商標／標章名稱，請以中文繁體字、英文或日文書寫。</font></td></tr>";
var p5Oappl_name = "<TR><TD>◎圖樣應使用虛線將商品或其包裝、容器態樣表現出來，於適當部分施以使用顏色，並聲明商品或其包裝、容器或其他營業相關物品之形狀不屬於商標之一部分。</TD></TR>";
var p5Remark1 = "<tr><td>商標法施行細則第九條規定：申請註冊顏色團體商標者，應於申請書中聲明，並載明該顏色及相關說明。前項商標，得以虛線表現實際使用於指定商品或服務之方式、位置或內容態樣。前項虛線部分，不屬於顏色商標之一部分。</td></tr>" +
			 "<tr><td>◎請詳細填寫顏色團體商標實際使用於指定商品或其包裝、容器、或其他營業相關物品上之態樣（如顏色實際標示之特殊方式、位置、內容；亦得以實物、照片或型錄為說明）以及實際顏色（如色彩種類、明度、漸層等）之說明。</td></tr>" +
			 "<tr><td>顏色團體商標使用於液狀或粉狀商品，若從包裝、容器外觀可明顯辨識者，亦適用顏色團體商標之申請。</td></tr>";
var p5Good = ztextg0 + ztextg1 + ztextg3 + ztextg2;
var p5Attech = zAttech +
             "<TR><TD>◎申請人具法人資格之身分證明文件：</td>" +
			 "<TR><TD>指向中央或地方主管機關立案登記並依法向該管法院辦理法人登記之法人登記證書影本。</td>" +
			 "<TR><TD>◎（顏色）團體商標使用規範書，應載明：</td>" +
			 "<TR><TD>＊申請人成員資格：</td>" +
			 "<TR><TD>指團體之組織章程等有規範加入團體成為成員資格之要件。</td>" +
			 "<TR><TD>＊控制（顏色）團體商標之使用方式：</td>" +
			 "<TR><TD>如正式入會後才可使用；停權或違反團體規定時不得使用；退會或開除會籍時不得使用；違反使用規定如何處罰等。</td></tr>";

var r1Appl_name = ztextd1 + ztextd2;
var r1Issue = "<tr><td>註冊號數、商標／九十二年修正前服務標章名稱及商標或標章種類請務必填寫正確，請參考註冊證所載之資料。</td></tr>";
var r1Term1 = "<tr><td>防護商標／標章於其專用期間屆滿前，應申請變更為獨立之註冊商標或標章；屆期未申請變更者，商標權消滅。</td></tr>";
var r1Term2 = "<tr><td>請參考註冊證所載之資料。</td></tr>";
var r1Remark1 = "<tr><td>若同時辦理移轉、授權或補證等相關案件時，務請於本□框內以英文字母「v」選填，並載明申請日期。</td></tr>";
var r1Good = "<tr><td>◎勾選全部延展者，毋庸填寫二、部分延展之商品／服務名稱。</TD>" +
			 "<TR><TD>◎<font color=red>勾選部分延展者，僅能就其原列專用商品／服務名稱做刪減；刪減後若有增列或變更商品／服務者，請另案辦理商品減縮。</font>（例如：原專用商品為中藥、西藥、衛生醫療補助品，僅得刪減中藥、西藥或衛生醫療補助品，欲將衛生醫療補助品變更為冰枕、眼罩、耳塞、擠青春痘棒者，須另案辦理商品減縮）；類別：請參考註冊證所載之資料。</TD>";
var r1new_no = ztextd3 +
			 "<tr><td>二、對本件廢止標的指定使用全部類別之商品或服務申請廢止者，請勾選第一空格欄。</td></tr>" +
			 "<tr><td>三、依商標法第63條第4項規定，廢止之事由僅存在於註冊商標所指定使用之部分商品或服務者，得就該部分之商品或服務廢止其註冊。</td></tr>" +
			 "<tr><td>1、對商標權範圍聲明廢止指定使用部分類別之全部商品或服務者，請勾選第二空格欄。</td></tr>" +
			 "<tr><td>2、對商標權範圍聲明廢止指定使用部分類別之部分商品或服務者，請勾選第三空格欄。若兩類以上之不份商品或服務提出廢止聲明者，請自行增列。</td></tr>";
var r1Other_item = "<tr><td>申請廢止人另提起之相同或類似案情，或另繫屬之相關聯案件之申請日期、案由及註冊號數，請務必詳盡填寫。</td></tr>" +
			 ztextd7 +
 			 "<tr><td>　　　與八十九年二月十四日註冊第00888169號商標申請廢止案情類似</td></tr>";
var r1Other_item1 = "<tr><td>一、請書寫主張之商標法法條。</td></tr>" +
			 "<tr><td>　　例如：認為本件廢止標的無正當事由迄未使用或繼續停止使用已滿三年，請填寫主張法條為：商標法第63條第1項第2款。</td></tr>" +
			 "<tr><td>二、主張商標法第63條第1項第1款或第3款者，請務必填寫據以廢止商標／標章號數，以免延宕本案之審理。</td></tr>" +
			 "<tr><td>　　例如：註冊第123456號商標</td></tr>";
var r1tran_remark1 = "<tr><td>一、請依主張條款，論述申請廢止商標／標章之具體違法事實及理由，並檢附明確之證據資料，以免因申請無具體事證或主張顯無理由，依商標法第65條第1項但書規定遭駁回申請之處分。</td></tr>" +
			 "<tr><td>二、依商標法第63條第1項第1款規定主張系爭商標／標章應廢止商標權者：</td></tr>" +
			 "<tr><td>◎應檢送系爭商標／標章變換加附記使用之證據，其內容應包括變換加附記使用人名稱、商標／標章及商品、時間等重要事項。</td></tr>" +
			 "<tr><td>◎據以廢止商標註冊已滿3年者，依商標法第67條準用第57條第2項規定，應檢附於申請廢止前3年有使用據以主張商品或服務之證據，或其未使用有正當事由之事證。務請具體說明據以廢止商標使用情形。</td></tr>" +
			 "<tr><td>三、依商標法第63條第1項第2款規定主張系爭商標／標章應廢止商標權者，應檢送系爭商標／標章未使用或繼續停止使用已滿3年之合理可疑事證，例如國內相關商品市場或同業間3家以上之訪查報告。申請廢止系爭商標／標章之部分商品或服務者，亦同。</td></tr>" +
			 "<tr><td>四、本欄位不敷使用時，請以加續頁方式附於本頁之後。</td></tr>";

var s1Claim1 = "<tr><td>◎註冊證遺失申請補發，請勾選第一點 V 註冊證遺失聲明。</td></tr>";

var t1Appl_name = "<tr><td>請將申請移轉之註冊號數、商標（標章）種類及商標／標章名稱填入適當之欄位。</td>" +
			 ztexti;
var t1Apcust = "<tr><td>本「申請人」欄，請填寫受讓人之資料。</td>" +
			 "<TR><TD>１、公司、行號、工廠、身分證統一編號欄：<font color=red>【務必填寫正確】</font></td>" +
			 "<TR><TD>公司、行號、工廠請填營利事業登記證之統一編號，本國人請填身分證之統一編號，外國法人、外國人免填。</td>" +
			 "<TR><TD>２、名稱或姓名（中文）／（英文）欄：</td>" +
			 "<TR><TD>◎申請人不論為本國人或外國人均請填寫中、英文名稱<font color=red>【中文名稱請用正楷繁體字書寫】</font>，外國自然人或法人之<font color=red>外文請統一以英文填寫</font>。</td>" +
			 "<TR><TD>◎書寫外國人名稱，請於名稱前加註國名別，例如：美商、日商、西班牙商。</td>" +
			 "<TR><TD>◎大陸地區申請人名稱，請於名稱前加註「大陸地區」。</td>" +
			 "<TR><TD>◎香港地區申請人名稱，請於名稱前加註「香港」。</td>" +
			 "<TR><TD>◎澳門地區申請人名稱，請於名稱前加註「澳門」。</td>" +
			 "<TR><TD>３、<font color=red>本國申請人中文地址請務必填寫郵遞區號</font>，英文地址免填。</td>" +
			 "<TR><TD>４、申請移轉登記若受讓人（申請人）名稱、代表人名稱、地址有變更時，得檢附變更證明文件併案辦理，毋庸另案申請變更。</td></tr>";

var vAppl_name = "<tr><td>請將申請閱卷之申請號數、註冊號數或核駁號數、商標種類及商標／標章名稱填入適當之欄位。</td></tr>" +
			 "<tr><td>【號數、商標或標章種類務必填寫正確，已註冊者可參考註冊證所載之資料】</td></tr>" +
			 "<tr><td>前大陸註冊商標，請在註冊號數前，加註「前商標局」或加註英文M字母，例如：M3426。</td></tr>";
var vread_reason = "<tr><td>本局商標檔卷依案由裝訂存檔，請務必敘明何種案由之卷宗及原由，俾便調卷。</td></tr>" +
			 "<tr><td>例如：因商標評定案，須調閱移轉案之移轉契約生效日期。</td><tr>";

var zApcust = "<tr><td>１、公司、行號、工廠、身分證統一編號欄：<font color=red>【務必填寫正確】</font>公司、行號、工廠請填營利事業登記證之統一編號，本國人請填身分證之統一編號，外國法人、外國人免填。</td></tr>" +
			 "<tr><td>２、名稱或姓名（中文）／（英文）欄：</td></tr>" +
			 "<tr><td>◎申請人不論為本國人或外國人均請填寫中、英文名稱<font color=red>【中文名稱請用正楷繁體字書寫】</font>，外國自然人或法人之<font color=red>外文請統一以英文填寫</font>。</td></tr>" +
			 "<tr><td>◎書寫外國人名稱，請於名稱前加註國名別，例如：美商、日商、西班牙商。</td></tr>" +
			 "<tr><td>◎大陸地區申請人中文名稱，請於名稱前加註「大陸地區」。</td></tr>" +
			 "<tr><td>◎香港地區申請人中文名稱，請於名稱前加註「香港」。</td></tr>" +
			 "<tr><td>◎澳門地區申請人中文名稱，請於名稱前加註「澳門」。</td></tr>" +
			 "<tr><td>３、本國申請人中文地址請務必填寫郵遞區號，英文地址免填。</td></tr>";

var zPrior = ztextp;
var zAppl_name = "<tr><td>標章名稱應與所申請註冊之標章圖樣相符；標章專用權以請准註冊之標章圖樣為限，未載入圖樣中之標章名稱，不受商標法之保護。<font color=red>所載之標章名稱，請以中文繁體字、英文或日文書寫。</font></td></tr>";
var zOappl_name = ztext + "<tr><td>◎標章圖樣中之文字或圖形，符合前述規定者，請填寫於：標章圖樣中之「  」不單獨主張專用權。</TD></TR>";
var zCappl_name = "<tr><td>圖樣分析資料欄位，請依圖樣中所組成中文、外文、圖形或記號，一一填寫。</td></tr>" + textz + ztextc + ztexte + ztextd + ztexts;
var zColor = "<tr><td>◎標章圖樣全部為墨色者，應勾選墨色欄框；標章圖樣全部為彩色者或其中部分有彩色者，應勾選彩色欄框，如係顏色組合商標／標章，請另填寫顏色組合商標／標章註冊申請書辦理之。</td></tr>";

var FOFappl_name = "<tr><td>註冊號數、商標/92年修正前服務標章名稱及商標或標章種類請務必填寫正確，請參考註冊證所載之資料。</td></tr>";
var FOFmark = "<tr><td>◎	國庫支票抬頭名稱、退費金額、規費收據號碼及本局通知退費函字號等欄位請填寫清楚，以利本局確認。</td><tr>";

var FB7appl_name = "<tr><td>請將註冊申請案號、商標/標章名稱及商標種類填入適當之欄位。</td></tr>" +
            "<tr><td><font color=red>註冊申請案號、商標/標章名稱及商標種類務必填寫正確</font></td></tr>";
var FB7mark = "<tr><td>◎	提出申請時，所補送之附件，請於該項文件前□框格內打V註記。</td><tr>";
var FW1remark = "<tr><td>◎請於「本申請案自請撤回」項目打V註記，並於申請人(代表人)處簽章。</td><tr>" +
             "<tr><td>◎如有其他有關自請撤回聲明事項，請於「其他聲明事項欄」敘明。</td><tr>";
var FW1mark = "<tr><td>提出申請時，所附之附件，請於該項文件前□框格內打V註記。</td></tr>";

if ($("body").find("#PEND").length == 0) {
    $("body").append("<div id=PEND style='display:none;position:absolute;right:50px;background-color:LightCyan;border-style:groove;border-color:red'></div> ");
}

function Getpx(obj) {
    var parObj = obj.offsetParent;
    if (parObj.tagName == "BODY")
        return obj.offsetLeft;
    else
        return Getpx(parObj) + obj.offsetLeft;
}

function Getpy(obj) {
    var parObj = obj.offsetParent;

    if (parObj.tagName == "BODY")
        return obj.offsetTop;
    else
        return Getpy(parObj) + obj.offsetTop;
}

function PMARK(A) {
    var sObj= event.srcElement ? event.srcElement : event.target;
    var xp = Getpx(sObj) + 80;
    var yp = Getpy(sObj);
    var strcase = reg.tfy_Arcase.value.Left(3);
    switch (strcase) {
        case "FA1" :
        case "FA2" :
        case "FA3" :
        case "FA4" :
            if( A==a5attech) A=zAttech;
            break
        case "FA5" :
            if (A==p1Good) A=p5Good;
            break;
        case "FA6" :
            if (A==p2Good) A=p5Good;
            break;
        case "FA7" :
            if (A==a3Appl_name) A=p3Appl_name;
            if (A==a3remark1) A=a7remark1;
            break;
        case "FA9" :
            if (A==p1Color)  A=a9Color;
            if (A==a5Attech) A=p3Attech;
            break;
        case "FAA":
            if (A==p5Remark1) A=aaRemark1;
            if (A==a5Attech) A=p3Attech;
            break;
        case "FAB":
            if (A==a3Appl_name) A=p3Appl_name;
            if (A==a5Attech) A=p3Attech;
            break;
        case "FAC":
            if (A==a4Color) A=acColor;
            if (A==a4Remark1) A=acRemark1;
            if (A==a5Attech) A=p3Attech;
            break;
        case "FAD":
            if (A==p1Color ) A=a9Color;
            if (A==a5Attech) A=p4Attech;
            break;
        case "FAE":
            if (A==p5Remark1) A=aaRemark1;
            if (A==a5Attech) A=aeAttech;
            break;
        case "FAF":
            if (A==a3Good ) A=p4Good;
            if (A==a5Attech) A=afAttech;
            break;
        case "FAG":
            if (A==a4Remark1) A=agRemark1;
            if (A==a5Attech) A=afAttech;
            if (A==a4color) A=g4color;
            break;
        case "FAI":
            if (A == a4Remark1) A = aiRemark1;
            break;
        case "FAJ":
            if (A == a4Remark1) A = ajRemark1;
            break;
        case "FAK":
            if (A == a4Remark1) A = akRemark1;
            break;
        case "FL2":
        case "FL6":
            if (A==a1Term1) A=a2Term1;
            if (A==a1Good ) A=a2Good;
            break;
        case "FL3":
        case "FL4":
            if (A==a1Term1) A=a4Term1;
            if (A==L1Appl_name) A=L3Appl_name;
            break;
    }

    if($('#PEND').is(':visible')){
        $('#PEND').hide();
        $("#tfz1_prior_country").show();
        $("#tfz1_zname_type").show();
        $("#tfz2_prior_country").show();
        $("#tfz3_prior_country").show();
        $("#tfz4_prior_country").show();
        $("#apclass").show();
        $("#ap_country").show();
    }else{
        var contStr = "<TABLE WIDTH='100%'>" + A + "</table>";
        $("#PEND").empty();
        $("#PEND").append(contStr);
        $("#PEND").show();
        $("#PEND").css({top: yp, left: xp, fontSize:10});

        $("#tfz1_prior_country").hide();
        $("#tfz1_zname_type").hide();
        $("#tfz2_prior_country").hide();
        $("#tfz3_prior_country").hide();
        $("#tfz4_prior_country").hide();
        $("#apclass").hide();
        $("#ap_country").hide();
    }
}

$("#PEND").on("click", function (e) {
    $(this).hide();
});
