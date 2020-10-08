var meta = document.getElementsByTagName("meta");
var ieMeta = meta.length ? meta[0].getAttribute("content").split('=')[1] : "?";
var ieMode = document.documentMode;
document.getElementById("result").innerHTML = 
    "META=" + ieMeta + ",MODE=" + ieMode;