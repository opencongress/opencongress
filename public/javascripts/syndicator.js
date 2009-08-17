var h = 92;
if (window.navigator.userAgent.indexOf("MSIE")) {
	h = h + 7; 
}
var frameHeight = (window.oc_num_items *  53) + h;
document.write('<iframe name="oc_syndicator_frame" width="176" height="' + frameHeight + '" scrolling="no" frameborder="0" style="border-style: solid; border-width: 1px; border-color: #' + window.bordercolor + '" allowtransparency="true" hspace="0" vspace="0" marginheight="0" marginwidth="0" src="' + window.oc_host_url + 'resources/syndicator_panel?bg_color=' + window.oc_bgcolor + '&textcolor=' + window.oc_textcolor + '&num_items=' + window.oc_num_items + '&item_type=' + window.oc_item_type + '"></iframe>');

