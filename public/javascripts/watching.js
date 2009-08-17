var h = 92;

var num_pass_bills = (window.oc_pass_bills == '' ? 0 : window.oc_pass_bills.split(",").length);
var num_dont_pass_bills = (window.oc_dont_pass_bills == '' ? 0 : window.oc_dont_pass_bills.split(",").length);

var frameHeight = 52;
frameHeight += (num_pass_bills + num_dont_pass_bills) * 53;
if (num_pass_bills > 0) {
  frameHeight += 18;
}
if (num_dont_pass_bills > 0) {
  frameHeight += 18;
}

if (window.navigator.userAgent.indexOf("MSIE")) {
	frameHeight = frameHeight + 7; 
}

document.write('<iframe name="oc_watching_frame" width="176" height="' + frameHeight + '" scrolling="no" frameborder="0" style="border-style: solid; border-width: 1px; border-color: #' + window.bordercolor + '" allowtransparency="true" hspace="0" vspace="0" marginheight="0" marginwidth="0" src="' + window.oc_host_url + 'resources/watching_panel?bg_color=' + window.oc_bgcolor + '&textcolor=' + window.oc_textcolor + '&pass_bills=' + window.oc_pass_bills + '&dont_pass_bills=' + window.oc_dont_pass_bills + '"></iframe>');

