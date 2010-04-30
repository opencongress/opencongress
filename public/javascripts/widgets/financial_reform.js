var fHeight = 0;
if (oc_path == "financial_reform_panel") {
    fHeight = 359;
    fWidth = 320;
} else if (oc_path == "financial_reform_panel_sm") {
    fHeight = 296;
    fWidth = 161;
}
if (window.navigator.userAgent.indexOf("MSIE")) {
	fHeight += 7;
}
document.write('<iframe id="financial_reform_panel" name="oc_financial_reform_frame" width="' + fWidth + '" height="' + fHeight + '" scrolling="no" frameborder="0" style="border: 0;" allowtransparency="true" hspace="0" vspace="0" marginheight="0" marginwidth="0" src="' + window.oc_host_url + 'resources/' + window.oc_path + '"></iframe>');
