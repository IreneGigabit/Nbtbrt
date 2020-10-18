//數字轉成國字
function NumberToChinese(SendNumber) {
    var chnNumChar = ["零", "壹", "貳", "參", "肆", "伍", "陸", "柒", "捌", "玖"];

    return chnNumChar[SendNumber];
}

//數字轉大寫
function NumberToCh(SendNumber) {
    var chnNumChar = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九"
        ,"十", "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九"
        ,"二十", "二十一", "二十二", "二十三", "二十四", "二十五", "二十六", "二十七", "二十八", "二十九"
        ,"三十", "三十一", "三十二", "三十三", "三十四", "三十五", "三十六", "三十七", "三十八", "三十九"
    ];
    return chnNumChar[SendNumber];
}
