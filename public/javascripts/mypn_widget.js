var h = 92;
if (window.navigator.userAgent.indexOf("MSIE")) {
	h = h + 7; 
}
var frameHeight = (window.oc_mypn_num_items *  53) + h;
document.write('<iframe name="oc_mypn_frame" width="176" height="' + frameHeight + '" scrolling="no" frameborder="0" style="border-style: solid; border-width: 1px; border-color: #' + window.bordercolor + '" allowtransparency="true" hspace="0" vspace="0" marginheight="0" marginwidth="0" src="' + window.oc_mypn_host_url + 'resources/mypn_panel?user=' + window.oc_mypn_user + '&bg_color=' + window.oc_mypn_bgcolor + '&textcolor=' + window.oc_mypn_textcolor + '&num_items=' + window.oc_mypn_num_items + '&item_type=' + window.oc_mypn_item_type + '"></iframe>');

