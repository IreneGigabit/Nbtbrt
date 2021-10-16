(function ($) {
    //#region labelfor 把radio/checkbox加上labelfor
    $.fn.labelfor = function () {
        var selectedObjects = this;
        $(selectedObjects).each(function () {
            var input = $(this);
            if (input.type == "radio" || input.type == "checkbox") {
                if ($(input).attr("id") != "") {
                    $(input).next("label").attr("for", $(input).attr("id"));
                }
            }
        });
        return selectedObjects;
    }
    //#endregion

    //#region lock 指定唯讀模式
    $.fn.lock = function (cond) {
        var selectedObjects = this;
        $(selectedObjects).each(function () {
            var input = $(this);
            if (typeof cond === "undefined" || cond) {//符合條件 或 沒給條件
                if ($(input).hasClass("dateField")) {
                    //$(input).datepick("option", "showOnFocus", false).next(".datepick-trigger:first").hide();
                    $(input).datepick('destroy');
                }
                if (this.type == "text" || this.type == "textarea" || this.type == "hidden") {
                    $(input).prop('readonly', true).addClass('SEdit');
                } else {
                    $(input).prop('disabled', true);
                }
            } else {
                if ($(input).hasClass("dateField")) {
                    //$(input).datepick("option", "showOnFocus", true).next(".datepick-trigger:first").show();
                    $(input).datepick('destroy');
                }
                $(input).prop('readonly', false).removeClass('SEdit').prop('disabled', false);
            }
        });
        return selectedObjects;
    }
	//#endregion

    //#region unlock 指定解鎖模式
	$.fn.unlock = function (cond) {
	    var selectedObjects = this;
	    $(selectedObjects).each(function () {
	        var input = $(this);
	        if (typeof cond === "undefined" || cond) {//符合條件 或 沒給條件
	            if ($(input).hasClass("dateField")) {
	                //$(input).datepick("option", "showOnFocus", true).next(".datepick-trigger:first").show();
	                $(input).datepick();
		        }
	            $(input).prop('readonly', false).removeClass('SEdit').prop('disabled', false);
		    }else{
	            if ($(input).hasClass("dateField")) {
	                //$(input).datepick("option", "showOnFocus", false).next(".datepick-trigger:first").hide();
	                $(input).datepick();
	            }
	            if (this.type == "text" || this.type == "textarea" || this.type == "hidden") {
	                $(input).prop('readonly', true).addClass('SEdit');
	            } else {
	                $(input).prop('disabled', true);
	            }
			}
		});
	    return selectedObjects;
	}
	//#endregion

    //#region hideFor 指定隱藏模式
	$.fn.hideFor = function (cond) {
	    var selectedObjects = this;
	    $(selectedObjects).each(function () {
	        var input = $(this);
	        if (typeof cond === "undefined" || cond) {//符合條件 或 沒給條件
	            if ($(input).hasClass("dateField")) {
	                $(input).datepick("option", "showOnFocus", false).next(".datepick-trigger:first").hide();
	            }
	            $(input).hide();
	        } else {
	            if ($(input).hasClass("dateField")) {
	                $(input).datepick("option", "showOnFocus", true).next(".datepick-trigger:first").show();
	            }
	            $(input).show();
	        }
	    });
	    return selectedObjects;
	}
    //#endregion

    //#region showFor 指定顯示模式
	$.fn.showFor = function (cond) {
	    var selectedObjects = this;
	    $(selectedObjects).each(function () {
	        var input = $(this);
	        if (typeof cond === "undefined" || cond) {//符合條件 或 沒給條件
	            if ($(input).hasClass("dateField")) {
	                $(input).datepick("option", "showOnFocus", true).next(".datepick-trigger:first").show();
	            }
	            $(input).show();
	        } else {
	            if ($(input).hasClass("dateField")) {
	                $(input).datepick("option", "showOnFocus", false).next(".datepick-trigger:first").hide();
	            }
	            $(input).hide();
	        }
	    });
	    return selectedObjects;
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
	                    },
	                    error: function (xhr) { 
	                        $("#dialog").html("<a href='" + this.url + "' target='_new'>載入查詢清單發生錯誤(getOption)！<u>(點此顯示詳細訊息)</u></a><hr>"+xhr.responseText);
	                        $("#dialog").dialog({ title: '載入查詢清單發生錯誤(getOption)！', modal: true, maxHeight: 500, width: "90%" });
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
	                //Object.keys(item).forEach(function (key) {
	                //    var re = new RegExp("{" + key + "}", "ig");
	                //    val = val.replace(re, item[key]);
	                //});
	                jQuery.each(Object.keys(item), function (ix, key) {
	                    var re = new RegExp("{" + key + "}", "ig");
	                    val = val.replace(re, item[key]);
	                });

	                //處理text
	                var txt = settings.textFormat;
	                //Object.keys(item).forEach(function (key) {
	                //    var re = new RegExp("{" + key + "}", "ig");
	                //    txt = txt.replace(re, item[key]);
	                //});
	                jQuery.each(Object.keys(item), function (ix, key) {
	                    var re = new RegExp("{" + key + "}", "ig");
	                    txt = txt.replace(re, item[key]);
	                });

	                //處理attribute
	                var attr = settings.attrFormat;
	                //Object.keys(item).forEach(function (key) {
	                //    var re = new RegExp("{" + key + "}", "ig");
	                //    attr = attr.replace(re, item[key]);
	                //});
	                jQuery.each(Object.keys(item), function (ix, key) {
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
	                    },
	                    error: function (xhr) {
	                        $("#dialog").html("<a href='" + this.url + "' target='_new'>載入查詢清單發生錯誤(getRadio)！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
	                        $("#dialog").dialog({ title: '載入查詢清單發生錯誤(getRadio)！', modal: true, maxHeight: 500, width: "90%" });
	                    }
	                });
	            }

	            $.each(settings.dataList, function (i, item) {
	                //處理value
	                var val = settings.valueFormat;
	                //Object.keys(item).forEach(function (key) {
	                //    var re = new RegExp("{" + key + "}", "ig");
	                //    val = val.replace(re, item[key]);
	                //});
	                jQuery.each(Object.keys(item), function (ix, key) {
	                    var re = new RegExp("{" + key + "}", "ig");
	                    val = val.replace(re, item[key]);
	                });

	                //處理text
	                var txt = settings.textFormat;
	                //Object.keys(item).forEach(function (key) {
	                //    var re = new RegExp("{" + key + "}", "ig");
	                //    txt = txt.replace(re, item[key]);
	                //});
	                jQuery.each(Object.keys(item), function (ix, key) {
	                    var re = new RegExp("{" + key + "}", "ig");
	                    txt = txt.replace(re, item[key]);
	                });

	                //處理attribute
	                var attr = settings.attrFormat;
	                //Object.keys(item).forEach(function (key) {
	                //    var re = new RegExp("{" + key + "}", "ig");
	                //    attr = attr.replace(re, item[key]);
	                //});
	                jQuery.each(Object.keys(item), function (ix, key) {
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
	                    },
	                    error: function (xhr) {
	                        $("#dialog").html("<a href='" + this.url + "' target='_new'>載入查詢清單發生錯誤(getCheckbox)！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
	                        $("#dialog").dialog({ title: '載入查詢清單發生錯誤(getCheckbox)！', modal: true, maxHeight: 500, width: "90%" });
	                    }
	                });
	            }

	            $.each(settings.dataList, function (i, item) {
	                //處理value
	                var val = settings.valueFormat;
	                //Object.keys(item).forEach(function (key) {
	                //    var re = new RegExp("{" + key + "}", "ig");
	                //    val = val.replace(re, item[key]);
	                //});
	                jQuery.each(Object.keys(item), function (ix, key) {
	                    var re = new RegExp("{" + key + "}", "ig");
	                    val = val.replace(re, item[key]);
	                });

	                //處理text
	                var txt = settings.textFormat;
	                //Object.keys(item).forEach(function (key) {
	                //    var re = new RegExp("{" + key + "}", "ig");
	                //    txt = txt.replace(re, item[key]);
	                //});
	                jQuery.each(Object.keys(item), function (ix, key) {
	                    var re = new RegExp("{" + key + "}", "ig");
	                    txt = txt.replace(re, item[key]);
	                });

	                //處理attribute
	                var attr = settings.attrFormat;
	                //Object.keys(item).forEach(function (key) {
	                //    var re = new RegExp("{" + key + "}", "ig");
	                //    attr = attr.replace(re, item[key]);
	                //});
	                jQuery.each(Object.keys(item), function (ix, key) {
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
})(jQuery);

