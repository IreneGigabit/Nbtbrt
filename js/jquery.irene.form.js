(function ($) {
	//#region labelfor 把radio/checkbox加上labelfor
	$.fn.labelfor = function () {
		return this.each(function () {
			if (this.type == "radio" || this.type == "checkbox") {
				if ($(this).attr("id") != "") {
					$(this).next("label").attr("for", $(this).attr("id"));
				}
			}
		});
	}
	//#endregion

	//#region lock 指定唯讀模式
	$.fn.lock = function (cond) {
	    return this.each(function () {
	        if (typeof cond === "undefined" || cond) {//符合條件 或 沒給條件
	            if ($(this).hasClass("dateField")) {
	                $(this).datepick("option", "showOnFocus", false).next(".datepick-trigger:first").hide();
	            }
	            if (this.type == "text" || this.type == "textarea") {
	                $(this).prop('readonly', true).addClass('SEdit');
	            } else {
	                $(this).prop('disabled', true);
	            }
	        }else{
		        if ($(this).hasClass("dateField")) {
		            $(this).datepick("option", "showOnFocus", true).next(".datepick-trigger:first").show();
		        }
		        $(this).prop('readonly', false).removeClass('SEdit').prop('disabled', false);
			}
		});
	}
	//#endregion

    //#region unlock 指定解鎖模式
	$.fn.unlock = function (cond) {
		return this.each(function () {
		    if (typeof cond === "undefined" || cond ) {//符合條件 或 沒給條件
		        if ($(this).hasClass("dateField")) {
		            $(this).datepick("option", "showOnFocus", true).next(".datepick-trigger:first").show();
		        }
		        $(this).prop('readonly', false).removeClass('SEdit').prop('disabled', false);
		    }else{
	            if ($(this).hasClass("dateField")) {
	                $(this).datepick("option", "showOnFocus", false).next(".datepick-trigger:first").hide();
	            }
	            if (this.type == "text" || this.type == "textarea") {
	                $(this).prop('readonly', true).addClass('SEdit');
	            } else {
	                $(this).prop('disabled', true);
	            }
			}
		});
	}
	//#endregion

    //#region hideFor 指定隱藏模式
	$.fn.hideFor = function (cond) {
	    return this.each(function () {
	        if (typeof cond === "undefined" || cond) {//符合條件 或 沒給條件
	            if ($(this).hasClass("dateField")) {
	                $(this).datepick("option", "showOnFocus", false).next(".datepick-trigger:first").hide();
	            }
	            $(this).hide();
	        } else {
	            if ($(this).hasClass("dateField")) {
	                $(this).datepick("option", "showOnFocus", true).next(".datepick-trigger:first").show();
	            }
	            $(this).show();
	        }
	    });
	}
    //#endregion

    //#region showFor 指定顯示模式
	$.fn.showFor = function (cond) {
	    return this.each(function () {
	        if (typeof cond === "undefined" || cond) {//符合條件 或 沒給條件
	            if ($(this).hasClass("dateField")) {
	                $(this).datepick("option", "showOnFocus", true).next(".datepick-trigger:first").show();
	            }
	            $(this).show();
	        } else {
	            if ($(this).hasClass("dateField")) {
	                $(this).datepick("option", "showOnFocus", false).next(".datepick-trigger:first").hide();
	            }
	            $(this).hide();
	        }
	    });
	}
    //#endregion

    //#region getOption
	$.fn.extend({
	    getOption: function (option) {
	        var obj = $(this);
	        var defaults = {
	            debug: false,
	            url: "",
	            data: null,
	            dataList: null,
	            showEmpty: true,//顯示"請選擇"
	            valueFormat: "",//option的value格式,用{}包住欄位,ex:{scode}
	            textFormat: "",//option的文字格式,用{}包住欄位,ex:{scode}_{sc_name}
	            attrFormat: "",//option的attribute格式,用{}包住欄位,ex:value1='{scode1}' value2='{sscode}'
	            firstOpt: "",//要在最上面額外增加option,ex:<option value='*'>全部<option>
	            lastOpt: "",//要在最下面額外增加option,ex:<option value='*'>全部<option>
	            setValue: ""//預設值
	        };
	        var settings = $.extend(defaults, option || {});  //初始化

	        var debugurl = settings.url + "?";// + unescape(unescape($.param(settings.data)));
	        if (settings.data != null) debugurl += unescape(unescape($.param(settings.data)));
	        if (settings.debug) {
	            if ($("body").find("#divDebug").length == 0) {
	                $("body").append("<div id=\"divDebug\" style=\"display:none;color:#1B3563\"></div>");
	            }
	            $("#divDebug").html("<a href=\"" + debugurl + "\" target=\"_blank\">Open getOption Debug Win<a>");
	            $("#divDebug").show();
	            $("#divDebug").fadeOut(5000);
	        }

	        return this.each(function () {
	            var obj = $(this);
	            obj.empty();

	            if (settings.dataList == null) {
	                $.ajax({
	                    async: false,
	                    cache: false,
	                    type: "get",
	                    data: settings.data,
	                    url: settings.url,
	                    success: function (json) {
	                        settings.dataList = $.parseJSON(json);
	                    },
	                    beforeSend: function (jqXHR, settings) {
	                        jqXHR.url = settings.url;
	                        //toastr.info("<a href='" + jqXHR.url + "' target='_new'>debug！\n" + jqXHR.url + "</a>");
	                    },
	                    error: function (jqXHR, textStatus, errorThrown) {
	                        //window.open(debugurl);
	                        //alert("載入查詢清單發生錯誤!!");
	                        toastr.error("<a href='" + jqXHR.url + "' target='_new'>載入查詢清單發生錯誤！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
	                    }
	                });
	            }

	            if (settings.firstOpt != "") {
	                obj.append(settings.firstOpt);
	            }
	            if (settings.showEmpty) {
	                obj.append("<option value='' style='COLOR:blue'>請選擇</option>");
	            }
	            $.each(settings.dataList, function (i, item) {
	                //處理value
	                var val = settings.valueFormat;
	                Object.keys(item).forEach(function (key) {
	                    var re = new RegExp("{" + key + "}", "ig");
	                    val = val.replace(re, item[key]);
	                });

	                //處理text
	                var txt = settings.textFormat;
	                Object.keys(item).forEach(function (key) {
	                    var re = new RegExp("{" + key + "}", "ig");
	                    txt = txt.replace(re, item[key]);
	                });

	                //處理attribute
	                var attr = settings.attrFormat;
	                Object.keys(item).forEach(function (key) {
	                    var re = new RegExp("{" + key + "}", "ig");
	                    attr = attr.replace(re, item[key]);
	                });
	                obj.append("<option value='" + val + "' " + attr + ">" + txt + "</option>");
	            });
	            if (settings.lastOpt != "") {
	                obj.append(settings.lastOpt);
	            }

	            obj.val(settings.setValue);


	        });
	    }
	});
    //#endregion

    //#region getRadio
	$.fn.extend({
	    getRadio: function (option) {
	        var obj = $(this);
	        var defaults = {
	            debug: false,
	            url: "",
	            data: null,
	            dataList: null,
	            mod: null,//幾個換行(<br>)
	            objName: "",//radio的name(群組名)
	            valueFormat: "",//radio的value格式,用{}包住欄位,ex:{scode}
	            textFormat: "",//radio的文字格式,用{}包住欄位,ex:{scode}_{sc_name}
	            attrFormat: "",//radio的attribute格式,用{}包住欄位,ex:value1='{scode1}' value2='{sscode}'
	            setValue: ""//預設值
	        };
	        var settings = $.extend(defaults, option || {});  //初始化

	        var debugurl = settings.url + "?";// + unescape(unescape($.param(settings.data)));
	        if (settings.data != null) debugurl += unescape(unescape($.param(settings.data)));
	        if (settings.debug) {
	            if ($("body").find("#divDebug").length == 0) {
	                $("body").append("<div id=\"divDebug\" style=\"display:none;color:#1B3563\"></div>");
	            }
	            $("#divDebug").html("<a href=\"" + debugurl + "\" target=\"_blank\">Open getRadio Debug Win<a>");
	            $("#divDebug").show();
	            $("#divDebug").fadeOut(5000);
	        }

	        return this.each(function () {
	            var obj = $(this);
	            obj.empty();

	            if (settings.dataList == null) {
	                $.ajax({
	                    async: false,
	                    cache: false,
	                    type: "get",
	                    data: settings.data,
	                    url: settings.url,
	                    success: function (json) {
	                        settings.dataList = $.parseJSON(json);
	                    },
	                    beforeSend: function (jqXHR, settings) {
	                        jqXHR.url = settings.url;
	                        //toastr.info("<a href='" + jqXHR.url + "' target='_new'>debug！\n" + jqXHR.url + "</a>");
	                    },
	                    error: function (jqXHR, textStatus, errorThrown) {
	                        //window.open(debugurl);
	                        //alert("載入查詢清單發生錯誤!!");
	                        toastr.error("<a href='" + jqXHR.url + "' target='_new'>載入查詢清單發生錯誤！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
	                    }
	                });
	            }

	            $.each(settings.dataList, function (i, item) {
	                //處理value
	                var val = settings.valueFormat;
	                Object.keys(item).forEach(function (key) {
	                    var re = new RegExp("{" + key + "}", "ig");
	                    val = val.replace(re, item[key]);
	                });

	                //處理text
	                var txt = settings.textFormat;
	                Object.keys(item).forEach(function (key) {
	                    var re = new RegExp("{" + key + "}", "ig");
	                    txt = txt.replace(re, item[key]);
	                });

	                //處理attribute
	                var attr = settings.attrFormat;
	                Object.keys(item).forEach(function (key) {
	                    var re = new RegExp("{" + key + "}", "ig");
	                    attr = attr.replace(re, item[key]);
	                });
	                if (val.toLowerCase() == settings.setValue.toLowerCase())
	                    obj.append("<label><input type='radio' id='" + settings.objName + val + "' name='" + settings.objName + "' value='" + val + "' " + attr + " checked>" + txt + "</label>");
	                else
	                    obj.append("<label><input type='radio' id='" + settings.objName + val + "' name='" + settings.objName + "' value='" + val + "' " + attr + ">" + txt + "</label>");

	                if (settings.mod != null) {
	                    if ((i + 1) % settings.mod == 0 && (i + 1) < settings.dataList.length) {
	                        obj.append("<BR>");
	                    }
	                }
	            });
	        });
	    }
	});
    //#endregion

    //#region getCheckbox
	$.fn.extend({
	    getCheckbox: function (option) {
	        var obj = $(this);
	        var defaults = {
	            debug: false,
	            url: "",
	            data: null,
	            dataList: null,
                mod:null,//幾個換行(<br>)
	            objName: "",//checkbox的name(群組名)
	            valueFormat: "",//checkbox的value格式,用{}包住欄位,ex:{scode}
	            textFormat: "",//checkbox的文字格式,用{}包住欄位,ex:{scode}_{sc_name}
	            attrFormat: "",//checkbox的attribute格式,用{}包住欄位,ex:value1='{scode1}' value2='{sscode}'
	            setValue: ""//預設值
	        };
	        var settings = $.extend(defaults, option || {});  //初始化

	        var debugurl = settings.url + "?";// + unescape(unescape($.param(settings.data)));
	        if (settings.data != null) debugurl += unescape(unescape($.param(settings.data)));
	        if (settings.debug) {
	            if ($("body").find("#divDebug").length == 0) {
	                $("body").append("<div id=\"divDebug\" style=\"display:none;color:#1B3563\"></div>");
	            }
	            $("#divDebug").html("<a href=\"" + debugurl + "\" target=\"_blank\">Open getcheckbox Debug Win<a>");
	            $("#divDebug").show();
	            $("#divDebug").fadeOut(5000);
	        }

	        return this.each(function () {
	            var obj = $(this);
	            obj.empty();

	            if (settings.dataList == null) {
	                $.ajax({
	                    async: false,
	                    cache: false,
	                    type: "get",
	                    data: settings.data,
	                    url: settings.url,
	                    success: function (json) {
	                        settings.dataList = $.parseJSON(json);
	                    },
	                    beforeSend: function (jqXHR, settings) {
	                        jqXHR.url = settings.url;
	                        //toastr.info("<a href='" + jqXHR.url + "' target='_new'>debug！\n" + jqXHR.url + "</a>");
	                    },
	                    error: function (jqXHR, textStatus, errorThrown) {
	                        //window.open(debugurl);
	                        //alert("載入查詢清單發生錯誤!!");
	                        toastr.error("<a href='" + jqXHR.url + "' target='_new'>載入查詢清單發生錯誤！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
	                    }
	                });
	            }

	            $.each(settings.dataList, function (i, item) {
	                //處理value
	                var val = settings.valueFormat;
	                Object.keys(item).forEach(function (key) {
	                    var re = new RegExp("{" + key + "}", "ig");
	                    val = val.replace(re, item[key]);
	                });

	                //處理text
	                var txt = settings.textFormat;
	                Object.keys(item).forEach(function (key) {
	                    var re = new RegExp("{" + key + "}", "ig");
	                    txt = txt.replace(re, item[key]);
	                });

	                //處理attribute
	                var attr = settings.attrFormat;
	                Object.keys(item).forEach(function (key) {
	                    var re = new RegExp("{" + key + "}", "ig");
	                    attr = attr.replace(re, item[key]);
	                });
	                if (val.toLowerCase() == settings.setValue.toLowerCase())
	                    obj.append("<label><input type='checkbox' id='" + settings.objName + val + "' name='" + settings.objName + "' value='" + val + "' " + attr + " checked>" + txt + "</label>");
	                else
	                    obj.append("<label><input type='checkbox' id='" + settings.objName + val + "' name='" + settings.objName + "' value='" + val + "' " + attr + ">" + txt + "</label>");

	                if (settings.mod != null) {
	                    if ((i + 1) % settings.mod == 0 && (i + 1) < settings.dataList.length) {
	                        obj.append("<BR>");
	                    }
	                }
	            });
	        });
	    }
	});
    //#endregion

    //#region Paging
	$.fn.paging = function (settings) {
	    var defaultSettings = {
	        noDataStr: "=== 目前無資料 ===",
	        data: {},
	        perPage: [10, 20, 30, 50],
	        bind: 'mouseover',
	        callSearch: function () { }
	    };
	    //將傳入的settings 覆蓋預設的 defaultSettings
	    var _settings = $.extend(defaultSettings, settings);
	    var tmpl = '\
<TABLE border=0 cellspacing=1 cellpadding=0 width="85%" align="center">\
    <tr>\
        <td colspan=2 align=center class=whitetablebg>\
            <font size="2" color="#3f8eba">\
            第<font color="red"><span id="NowPage"></span>/<span id="TotPage"></span></font>頁\
            | 資料共<font color="red"><span id="TotRec"></span></font>筆\
            | 跳至第\
            <select id="GoPage" name="GoPage" style="color:#FF0000"></select>\
            頁\
            <span id="PageUp">| <a href="javascript:void(0)" class="pgU" v1="">上一頁</a></span>\
            <span id="PageDown">| <a href="javascript:void(0)" class="pgD" v1="">下一頁</a></span>\
            | 每頁筆數:\
            <select id="PerPage" name="PerPage" style="color:#FF0000"></select>\
            <input type="hidden" name="SetOrder" id="SetOrder" />\
            </font>\
        </td>\
    </tr>\
</TABLE>';
	    var render = function (obj) {
	        $(obj).html(tmpl);
	        $(obj).hide();

	        //每頁筆數
	        var option = new Array(_settings.perPage.length);
	        $.each(_settings.perPage, function (i, value) {
	            option[i] = ['<option value="' + value + '">' + value + '</option>'].join("");
	        });
	        $("#PerPage", $(obj)).replaceWith('<select id="PerPage" name="PerPage" style="color:#FF0000">' + option.join("") + '</select>');
	        //console.log(_settings.data);
	        var totRow = parseInt(_settings.data.totrow || 0, 10);
	        var totPage = parseInt(_settings.data.totpage || 0, 10);
	        var nowPage = parseInt(_settings.data.nowpage || 0, 10);
	        var perPage = parseInt(_settings.data.perpage || 0, 10);
	        $("#NowPage", $(obj)).html(nowPage);
	        $("#TotPage", $(obj)).html(totPage);
	        $("#TotRec", $(obj)).html(totRow);
	        var i = totPage + 1, option = new Array(i);
	        while (--i) {
	            option[i] = ['<option value="' + i + '">' + i + '</option>'].join("");
	        }
	        $("#GoPage", $(obj)).replaceWith('<select id="GoPage" name="GoPage" style="color:#FF0000">' + option.join("") + '</select>');
	        $("#GoPage", $(obj)).val(nowPage);
	        $("#PerPage", $(obj)).val(perPage);

	        nowPage > 1 ? $("#PageUp", $(obj)).show() : $("#PageUp", $(obj)).hide();
	        nowPage < totPage ? $("#PageDown", $(obj)).show() : $("#PageDown", $(obj)).hide();
	        $("a.pgU", $(obj)).attr("v1", nowPage - 1);
	        $("a.pgD", $(obj)).attr("v1", nowPage + 1);
	        //$("#id-div-slide", $(obj)).slideUp("fast");

	        if (totRow > 0) {
	            $(obj).show();
	        } else {
	            $(obj).html(_settings.noDataStr);
	            if (_settings.noDataStr != "") {
	                $(obj).html("<font color='red'>" + _settings.noDataStr + "</font>");
	            }
	        }
	    };

	    //return 回去,this 指的是外面的 jQuey 物件
	    return this.each(function () {
	        var obj = this;
	        render(obj);

	        //每頁幾筆
	        $("#PerPage", obj).change(function (e) {
	            //console.log("PerPage change");
	            $("#GoPage", obj).val("1");
	            _settings.callSearch();
	        });
	        //指定第幾頁
	        $("#GoPage", obj).change(function (e) {
	            //$("#GoPage", obj).on("change", "#GoPage", function (e) {
	            //console.log("divPaging change");
	            _settings.callSearch();
	        });
	        //上下頁
	        $(".pgU,.pgD", obj).click(function (e) {
	            $("#GoPage", obj).val($(this).attr("v1"));
	            //console.log("pgU pgD click");
	            _settings.callSearch();
	        });

	        //console.log(this.id);
	        //$(this).bind(_settings.bind, _settings.callSearch);
	    });
	}
    //#endregion
})(jQuery);

