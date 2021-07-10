(function ($) {
    //#region Paging
    $.fn.paging = function (settings) {
        var defaultSettings = {
            noDataStr: "=== 目前無資料 ===",
            data:{},
            perPage: [10, 20, 30, 50],
            bind: 'mouseover',
            callSearch: function () {}
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
            var totRow = parseInt(_settings.data.totrow||0, 10);
            var totPage = parseInt(_settings.data.totpage||0, 10);
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

	//#region chkRequire
	$.fn.extend({
		chkRequire: function (option) {
			var defaults = {
				msg: "",
				br: false,
				depend: null
			};

			var settings = $.extend(defaults, option || {});
			var errflag = false;

			this.each(function () {
				var errmsg = "";

				if ($(this).parents("td:first").children(":gt(" + $(this).index() + ").errlog:first").length == 0) {
					$(this).parents("td:first").append("<span class='errlog'></span>");
				}

			    //$(this).nextAll(".errlog:eq(0)").html("");
				//$(this).parents("td:first").children(":gt("+$(this).index()+").errlog:first").html("");

				if (settings.depend != null && settings.depend != undefined && settings.depend != "") {
					//if (this.type == "radio" || this.type == "checkbox") {
					//	if ($(this).prop("checked") == false) {
					//		return false;
					//	}
					//} else
					if ($(settings.depend).val() == "") {
						return false;
					}
				}

				if (this.type == "select-one") {
					if ($(this).val() == "") {
						errmsg = settings.msg || "須選擇";
						errflag = true;
					}
				} else if (this.type == "textarea") {
					if ($(this).val() == "") {
						errmsg = settings.msg || "不可空白";
						errflag = true;
					}
				} else if (this.type == "radio") {
					if ($(this).prop("checked") == false) {
						errmsg = settings.msg || "radio須勾選";
						errflag = true;
					}
				} else if (this.type == "checkbox") {
					if ($(this).prop("checked") == false) {
						errmsg = settings.msg || "check須選擇";
						errflag = true;
					}
				} else {
					if ($(this).val() == "") {
						errmsg = settings.msg || "不可空白";
						errflag = true;
					}
				}
				//console.log($(this).index());
				//console.log($(this).parents("td:first").find(".errlog").index());
				//console.log($(this).parents("td:first").children(":gt("+$(this).index()+").errlog:first").length+",errmsg="+errmsg);
				//$(this).tooltipster({ trigger: 'custom', position: 'right', content: errmsg, multiple: true, theme: 'tooltipster-light' });
				if (errmsg != "") {
					$(this).addClass("chkError");
				    $(this).parents("td:first").children(":gt(" + $(this).index() + ").errlog:first").html((settings.br ? "<BR>" : "") + errmsg);
					//$(this).tooltipster('show');
				} else {
				    $(this).parents("td:first").children(":gt(" + $(this).index() + ").errlog:first").html("");
				    $(this).removeClass("chkError");
				    //$(this).tooltipster('hide');
				}
			});
			return errflag;
		}
	});
	//#endregion

    /*
	//#region chkNumber 
	$.fn.extend({
		chkNumber: function (option) {
			var defaults = {
				msg: "",
				br: false,
				min: null,
				max: null,
				require: false
			};

			var settings = $.extend(defaults, option || {});
			var errflag = false;

			this.each(function () {
				var errmsg = "";
				if ($(this).parents("td:first").children(":gt(" + $(this).index() + ").errlog:first").length == 0) {
					$(this).parents("td:first").append("<span class='errlog'></span>");
				}

			    //$(this).nextAll(".errlog:eq(0)").html("");
			    //$(this).parents("td:first").children(":gt("+$(this).index()+").errlog:first").html("");

				if (this.type == "text") {
					if (settings.require && $(this).val() == "") {
						errmsg = settings.msg || "須輸入數值";
						errflag = true;
					} else if (isNaN($(this).val())) {
						errmsg = settings.msg || "須為數值";
						errflag = true;
					} else if (settings.min != null && parseFloat($(this).val()) < settings.min) {
						errmsg = settings.msg || "須>=" + settings.min;
						errflag = true;
					}
				}

				if (errmsg != "") {
					$(this).addClass("chkError");
					$(this).parents("td:first").children(":gt(" + $(this).index() + ").errlog:first").html((settings.br ? "<BR>" : "") + errmsg);
				} else {
					if ($(this).parents("td:first").children(":gt(" + $(this).index() + ").errlog:first").html() == "") {
						$(this).removeClass("chkError");
					}
				}
			});
			return errflag;
		}
	});
	//#endregion

	//#region chkDate
	$.fn.extend({
		chkDate: function (option) {
			var defaults = {
				msg: "",
				br: false,
				require: false
			};

			var settings = $.extend(defaults, option || {});
			var errflag = false;

			this.each(function () {
				var errmsg = "";
				if ($(this).parents("td:first").children(":gt(" + $(this).index() + ").errlog:first").length == 0) {
					$(this).parents("td:first").append("<span class='errlog'></span>");
				}

			    //$(this).nextAll(".errlog:eq(0)").html("");
			    //$(this).parents("td:first").children(":gt("+$(this).index()+").errlog:first").html("");

				if (this.type == "text") {
				    if ($(this).val() != "") {
				        if (!$.isDate($(this).val())) {
							errmsg = settings.msg || "日期格式錯誤，請重新輸入!!! 日期格式:YYYY/MM/DD";
							errflag = true;
						}
				    } else {
				        if (settings.require) {
							errmsg = settings.msg || "日期格式錯誤，請重新輸入!!! 日期格式:YYYY/MM/DD";
							errflag = true;
						}
					}
				}

				if (errmsg != "") {
					$(this).addClass("chkError");
					$(this).parents("td:first").children(":gt(" + $(this).index() + ").errlog:first").html((settings.br ? "<BR>" : "") + errmsg);
				} else {
					if ($(this).parents("td:first").children(":gt(" + $(this).index() + ").errlog:first").html() == "") {
						$(this).removeClass("chkError");
					}
				}
			});
			return errflag;
		}
	});
	//#endregion

	//#region chkRequireGrp
	$.fn.extend({
		chkRequireGrp: function (option) {
			var defaults = {
				msg: "",
				br: false,
				alert: true,
				extcheck: function (hasFlag) { }
			};

			var settings = $.extend(defaults, option || {});
			var errflag = false;
			var errmsg = "";
			var hasFlag = false;

			hasFlag = settings.extcheck(hasFlag);
			this.each(function () {
				//if (this.type == "radio" || this.type == "checkbox") {
				//	if ($(this).prop("checked") != true) {
				//		hasFlag = hasFlag || true;
				//	}
				//} else
				//alert($(this).val());
				if ($(this).val() != "") {
					hasFlag = hasFlag || true;
				}
				//if (window.console) {
				//	console.log(this.type + "..hasFlag.." + hasFlag);
				//}
			});

			if (!hasFlag) {
				errflag = true;
				if (settings.alert) {
					alert(settings.msg || "至少輸入一項!!");
				} else {
					this.each(function () {
						if ($(this).parents("td:first").children(":gt(" + $(this).index() + ").errlog:first").length == 0) {
							$(this).parents("td:first").append("<span class='errlog'></span>");
						}

						errmsg = settings.msg || "至少輸入一項!!";
						//console.log(errmsg);
						$(this).addClass("chkError");
						$(this).parents("td:first").children(":gt(" + $(this).index() + ").errlog:first").html((settings.br ? "<BR>" : "") + errmsg);
					});
				}
			} else {
				this.each(function () {
					if ($(this).parents("td:first").children(":gt(" + $(this).index() + ").errlog:first").html() == "") {
						$(this).removeClass("chkError");
					}
				});
			}
			return errflag;
		}
	});
	//#endregion

	//#region chkLength
	$.fn.extend({
		chkLength: function (option) {
			var defaults = {
				msg: "",
				br: false,
				max:0
			};

			var settings = $.extend(defaults, option || {});
			var errflag = false;

			this.each(function () {
				var errmsg = "";

				if ($(this).parents("td:first").children(":gt(" + $(this).index() + ").errlog:first").length == 0) {
					$(this).parents("td:first").append("<span class='errlog'></span>");
				}

			    //$(this).nextAll(".errlog:eq(0)").html("");
			    //$(this).parents("td:first").children(":gt("+$(this).index()+").errlog:first").html("");

				if ($(this).val().CodeLength() > settings.max) {
					errmsg = settings.msg || "長度過長，請檢查！";
				}
				
				if (errmsg != "") {
					//$(this).parents("td:first").find(".errlog").html(errmsg);
					//$(this).nextAll(".errlog:eq(0)").html(errmsg);
					$(this).addClass("chkError");
					$(this).parents("td:first").children(":gt(" + $(this).index() + ").errlog:first").html((settings.br ? "<BR>" : "") + errmsg);
				} else {
					if ($(this).parents("td:first").children(":gt(" + $(this).index() + ").errlog:first").html() == "") {
						$(this).removeClass("chkError");
					}
				}

			});
			return errflag;
		}
	});
	//#endregion

	//#region chkErrorExt
	$.fn.extend({
		chkErrorExt: function (option) {
			var defaults = {
				msg: "資料有誤，請檢查!!",
				br: false,
				alert: false,
				checkErr: function (extFlag) { }
			};

			var settings = $.extend(defaults, option || {});
			var errflag = false;

			errflag = settings.checkErr(settings);

			if (errflag) {
				if (settings.alert) {
					alert(settings.msg);
				} else {
					this.each(function () {
						if ($(this).parents("td:first").children(":gt(" + $(this).index() + ").errlog:first").length == 0) {
							$(this).parents("td:first").append("<span class='errlog'></span>");
						}
						$(this).addClass("chkError");
						$(this).parents("td:first").children(":gt(" + $(this).index() + ").errlog:first").html((settings.br ? "<BR>" : "") + settings.msg);
					});
				}
			} else {
				this.each(function () {
					if ($(this).parents("td:first").children(":gt(" + $(this).index() + ").errlog:first").html() == "") {
						$(this).removeClass("chkError");
					}
				});
			}

			return errflag;
		}
	});
	//#endregion
    */
})(jQuery);

