/*!
* jQuery Snoopy Date Library v1.0.0
*
* Date: 2010-08-24 21:29
* Revision: 0001
*/
(function ($) {
	$.isDate = function(strDate) {
		//alert(strDate);
		if (strDate == null) return false;
		if (strDate == undefined) return false;
		var dt_reg = new RegExp(/^\d{4}(\D)\d{1,2}(\D)\d{1,2}$/);
		var b = dt_reg.test(strDate);
		var s1 = "-";
		var s2 = "-";
		//console.log(strDate,b);
		if (b) {
			var dareDec = dt_reg.exec(strDate);
			s1 = dareDec[1];
			s2 = dareDec[2];
			var nn = Date.parse(strDate.replace(/\D/g, "/"));
			//alert(nn);
			if (isNaN(nn))
				b = false;
			else
				b = true;
		} else b = false;

		if (b) {
		    //console.log(strDate, b);
		    var nndt = new Date(strDate.replace(/\D/g, "/"));
			var str2 = nndt.getFullYear() + s1 + (nndt.getMonth() + 1) + s2 + nndt.getDate();
			//alert(str2);
			b = false;
			if (str2 == strDate.replace(s1 + "0", s1).replace(s2 + "0", s2)) b = true;
		}

		return b;
	}

	$.isNDate = function(strDate) {
		return !$.isDate(strDate);
	}

	$.Date2Str = function(date) {
		var dStr = "";
		if (date == null || date == undefined) return dStr;
		if (typeof (date) == "object") {
			dStr = date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate();
		} else { dStr = date.toString(); }
		return dStr;
	}

	$.Str2Date = function(dStr) {
		var date = null;

		if (typeof (dStr) == "string") {
			if ($.isNDate(dStr)) throw (" incorrct date formation !");
			date = new Date(dStr.replace(/\D/g, "/"));
		} else { dStr = date.toString(); }
		return date;
	}

	$.DateAdd = function(interval, number, date) {
		var xnum = 0;
		var xdate = null;
		var day1 = 0, day2 = 0;

		xnum = parseInt(number, 10);
		if (typeof (date) == "string") xdate = new Date($.Str2Date(date));
		else xdate = new Date(date);

		day1 = xdate.getDate();
		switch (interval) {
			case "yyyy":
			case "Y": xdate.setFullYear(xdate.getFullYear() + xnum); break;
			case "m":
			case "M": xdate.setMonth(xdate.getMonth() + xnum); break;
			case "d":
			case "D": xdate.setDate(xdate.getDate() + xnum); break;
			case "ww":
			case "W": xdate.setDate(xdate.getDate() + 7 * xnum); break;
		}
		day2 = xdate.getDate();
		if ((interval == "yyyy" || interval == "m" || interval == "Y" || interval == "M") && day1 != day2) {
			xdate.setDate(xdate.getDate() - day2);
		}
		return xdate;
	}

	$.DateDiff = function(interval, date1, date2) {
		var num = 0;
		var xdate1, xdate2;

		if (typeof (date1) == "string") xdate1 = new Date($.Str2Date(date1));
		else xdate1 = new Date(date1);
		if (typeof (date2) == "string") xdate2 = new Date($.Str2Date(date2));
		else xdate2 = new Date(date2);

		if (xdate1 != xdate2) {
			if (xdate1 < xdate2) {
				num = -1;
				while (xdate1 <= xdate2) {
					xdate1 = $.DateAdd(interval, 1, xdate1);
					num++;
				}
			} else {
				num = 1;
				while (xdate1 >= xdate2) {
					xdate1 = $.DateAdd(interval, -1, xdate1);
					num--;
				}
			}
		}

		return num;
	}

	$.getSelText = function(oID) {
		var sRet = "";
		if ($("select[name='" + oID + "']")) {
			sRet = $("select[name='" + oID + "'] option:selected").text();
			var idx = sRet.indexOf("_");
			if (idx >= 0) sRet = sRet.substr(idx + 1);
		}
		return sRet;
	}

	$.endMonth = function(date1) {
		var xdate1;
		if (typeof (date1) == "string") xdate1 = $.Str2Date(date1);
		else xdate1 = date1;

		xdate1 = new Date(xdate1.getFullYear(), xdate1.getMonth() + 1, 1)
		xdate1 = $.DateAdd("d", -1, xdate1);
		return xdate1
	}

	$.radioValue = function(x, v) {
	    //if (v != null && v != undefined) $("input:radio[name='" + x + "'][value='" + v + "']").prop("checked", true);
		//return $("input:radio[name='" + x + "']:checked").val();
		var sObj = $("input:radio[name='" + x + "']");
		if (sObj == null) return "";
		if (v != null && v != undefined) $(sObj).filter("[value='" + v + "']").prop("checked", true);
		return $(sObj).filter(":checked").val();
	}

	$.toFixedLen = function(value, length, fill) {
		var ret = value.toString();
		if (!fill) fill = "0";
		var padding = length - ret.length;
		if (padding < 0) ret = ret.substr(-padding);
		else {
			for (var i = 0; i < padding; i++) ret = fill + ret;
		}
		return ret;
	}

	//$.fn.outerHTML = function(s) { return ((s) ? $(this).replaceWith(s) : $(this).clone().wrap('').parent().html()); }

	$.fn.extend({
		outerHTML: function(value) {
			// If there is no element in the jQuery object
			if (!this.length)
				return null;
			// Returns the value
			else if (value === undefined) {
				var element = (this.length) ? this[0] : this, result;
				// Return browser outerHTML (Most newer browsers support it)
				if (element.outerHTML)
					result = element.outerHTML;
				// Return it using the jQuery solution
				else
					result = $(document.createElement("div")).append($(element).clone()).html();
				// Trim the result
				if (typeof result === "string")
					result = $.trim(result);
				return result;
			}
			// Deal with function
			else if ($.isFunction(value)) {
				this.each(function(i) {
					var $this = $(this);
					$this.outerHTML(value.call(this, i, $this.outerHTML()));
				});
			}
			// Replaces the content
			else {
				var $this = $(this),
					replacingElements = [],
					$value = $(value),
					$cloneValue;
				for (var x = 0; x < $this.length; x++) {
					// Clone the value for each element being replaced
					$cloneValue = $value.clone(true);
					// Use jQuery to replace the content
					$this.eq(x).replaceWith($cloneValue);
					// Add the replacing content to the collection
					for (var i = 0; i < $cloneValue.length; i++)
						replacingElements.push($cloneValue[i]);
				}
				// Return the replacing content if any
				return (replacingElements.length) ? $(replacingElements) : null;
			}
		},
		setSelectWidth: function() {
			/*var nW = 0;
			var nW0 = 0;
			alert("3");
			$("option", this).each(function(n) {
			nW0 = $(this).width();
			alert(nW0 + ": " + $(this).text());
			if (nW0 > nW) nW = nW0;
			});
			if (nW > 0) {
			$(this).width(nW0 + 30);
			}*/
			return this;
		},
		outerSEL: function(s) { return ((s) ? $(this).replaceWith(s) : $(this).clone().wrap('<' + this[0].tagName + '></' + this[0].tagName + '>').parent().html()); },
		selectRange: function (start, end) {
			if (end === undefined) {
				end = start;
			}
			return this.each(function () {
				if ('selectionStart' in this) {
					this.selectionStart = start;
					this.selectionEnd = end;
				} else if (this.setSelectionRange) {
					this.setSelectionRange(start, end);
				} else if (this.createTextRange) {
					var range = this.createTextRange();
					range.collapse(true);
					range.moveEnd('character', end);
					range.moveStart('character', start);
					range.select();
				}
			});
		}
	});

})(jQuery);
